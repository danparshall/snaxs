function PAR=user_eigenvectors(PAR);
% PAR=user_eigenvectors(PAR);
% 	Prompt user for q-point at which the eigenvector should be calculated, then 
%	call to anapert(), which writes results to P_OUT and 'phonon_modes' files.
%	Then passes user to "user_draw_modes" which allows the user to select which
%	mode to display.


if isfield(PAR.XTAL,'calc_method')
	calc=PAR.XTAL.calc_method;
else
	error(' Calculation method unknown; probably crashing.');
	calc=[];
end

% strip 'allheights' so height data isn't displayed / doesn't have to be calculated
if isfield(PAR.DATA,'allheights')
	PAR.DATA = rmfield(PAR.DATA, 'allheights');
end


run=1;
while run 				% runs until Q-input received is 'x'
	[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
	disp(' ')
	disp(' === Simulating eigenvectors at fixed Q ===')


	%% === get user input / Q,===
	disp(' Input Q of desired eigenvector as "H K L"');
	[Q_in,PAR]=user_vector(PAR.INFO.Q,PAR);		% default is INFO.Q
	if Q_in=='x'; run=0; break; end
	PAR.INFO.Q=Q_in;


	%% === set tau / q in primitive basis ===
	[tau, q]=calc_tau_q(PAR);


	%% === calculate eigenvectors ===
	if calc=='phonopy'
		%% call phonopy, read data
		system_cleanup('phonopy');
		write_phonopy(PAR, q);
		system_phonopy(PAR,'eigs');
		PAR.VECS=read_phonopy_VECS(PAR, q);

	elseif calc=='anapert'
		%% call anapert, read data
		system_cleanup('anapert');
		write_anapert(PAR, q);
		system_anapert(XTAL);
		PAR.VECS=read_anapert_VECS(PAR, q);
	end


	%% === structure factor ===
	PAR.VECS=make_STRUFAC(PAR,Q_in);


	%% === plot ===
	if system_octave;
		warning([' Sorry, eigenvector animation is not implemented for Octave.\n' ...
		' However, the mode data has been saved within the PAR.VECS structure.\n' ...
		' Animation could probably be implemented using octave-geometry package'],[]);
	else
		PAR=user_draw_modes(PAR);
	end
end

