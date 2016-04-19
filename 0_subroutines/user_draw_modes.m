function PAR=user_draw_modes(PAR);
% PAR=user_draw_modes(PAR);
%	For an already-determined Q-point, prompts user for which mode to animate.

display_strufac_data(PAR);

prev_mode=0;
run=1;
while run 	% runs until input received is 'x'

	%% === get user input ===
	disp(' Input index number of desired eigenvector, or 0 to see list');
	[mode_index,PAR]=user_scalar(prev_mode,PAR);
		if mode_index=='x'; run=0; break; end


	%% === sanitize, because some users are jerks === 
	mode_index=round(mode_index);
	if mode_index > 3*PAR.XTAL.N_atom | mode_index < 0
		warning off backtrace
		display('  You must select one of the available phonons');
		warning on backtrace
		mode_index=prev_mode;
	end


	%% === display mode data if requested ===
	if mode_index==0;
		display_strufac_data(PAR);
		mode_index=prev_mode;
	end


	%% === draw stuff, if new ===
	if mode_index ~= prev_mode;
		animate_phonon(PAR,mode_index);
		prev_mode=mode_index;
	else
		disp('  Please select a new mode.');
	end

end

