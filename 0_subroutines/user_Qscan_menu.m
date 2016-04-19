function PAR=user_Qscan_menu(PAR);
% PAR=user_Qscan_menu(PAR)
%	prompt user for data needed to simulate Q-scan at single energy, then call 
%	anapert() and display results.  Uses "simulate_SQW" to generate slice of
%	S(q,w), and pulls fixed row from that



first=1;
run=1;
while run 			% runs until some input received is 'x'

	% update each iteration, so that new E_const is received, etc.
	[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

	disp(' ')
	disp(' === Simulating Q-scan at fixed E === ')

	% === get inputs from user ===
	% === on first pass, get all inputs === 
	if first==1;
		disp(' Input Q_min as "H K L", or "x" to exit');
		[Q_min,PAR]=user_vector(INFO.Q_min,PAR);
			if Q_min=='x'; run=0; break; end			% exit if input is 'x'
		INFO.Q_min=Q_min;

		disp(' Input Q_max as "H K L", or "x" to exit');
		[Q_max,PAR]=user_vector(INFO.Q_max,PAR);
			if Q_max=='x'; run=0; break; end			% exit if input is 'x'
		INFO.Q_max=Q_max;

		disp(' Input number of points (odd for symmetric scans)');
		[Q_npts,PAR]=user_scalar(INFO.Q_npts,PAR);
			if Q_npts=='x'; run=0; break; end
		INFO.Q_npts=Q_npts;

		disp(' Input constant energy, or "x" to quit and enter a new Q-range');
		[E_const,PAR]=user_scalar(INFO.E_const,PAR);
			if E_const=='x'; run=0; break; end
		INFO.E_const=E_const;

		% === generate SQE_array on first pass only ===
		disp(' Calculating...');
		DATA=make_DATA(PAR);
		PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);
		PAR=simulate_SQW(PAR);
		[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
		first=0;
		disp(' ...finished!');


	% === on later passes, just get new E_const, since the calc is already done
	else
		disp(' Input constant energy, or "x" to quit and enter a new Q-range');
		[E_const,PAR]=user_scalar(INFO.E_const,PAR);
			if E_const=='x'; run=0; break; end
		PAR.INFO.E_const=E_const;
	end


	% === plot ===
	PAR=plot_Qscan(PAR);
end

