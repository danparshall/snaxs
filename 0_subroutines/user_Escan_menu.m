function PAR= user_Escan_menu(PAR);
% PAR= user_Escan_menu(PAR);
%	Prompt user for data needed to simulate E-scan at a single Q-point, then 
%	call to anapert()/phonopy and display results.
%	Easter egg: type "i" to see structure factor data

run=1;
while run 				% runs until Q-input received is 'x'
	disp(' ')
	disp(' === Simulating E-scan at fixed Q ===')

	% === get user input / Q,===
	disp(' Input Q as "H K L", or "x" to exit');
	[Q_in,PAR]=user_vector(PAR.INFO.Q, PAR, {'i' 'q' } ); % default is INFO.Q
		if Q_in=='x'; run=0; break; end

	% === display strufac info ===
	if Q_in=='i';
		display_strufac_data(PAR);
		continue; 
	end;

	% === display primitive-q info ===
	%		very useful for confirming that EXP.basis_user is set correctly
	if Q_in=='q'
		if 1
			this_q= make_string_vector(PAR.VECS.qs(1,:));
			cnv=calc_prm_to_cnv(PAR.XTAL, PAR.VECS.qs(1,:), PAR.EXP);
			this_cnv=make_string_vector(cnv);
			disp(['  In primitive coordinates, this is : ' this_q]);
			disp(['  Which translates to user basis of : ' this_cnv]);
			continue;
		else
			disp(' Turn on primitive-q comparison by editing "user_Escan_menu"');
			continue;
		end
	end

	% === if no special outputs, then update ===
	PAR.INFO.Q=Q_in;

	% === write data to P_INP, calculate structure factors, etc ===
	PAR=simulate_single(PAR);

	% === generate scan ===
	PAR=simulate_Escan(PAR);


	% === plot data ===
	if length(PAR.DATA.centers)>0
		PAR=plot_Escan(PAR);
	else
		clf(gcf);
		warning off backtrace
		warning([' There are no accessible phonons at that Q-point ' ...
			'between ' num2str(PAR.INFO.e_min) ' and ' num2str(PAR.INFO.e_max) ' meV']);
		warning on backtrace
	end
end

