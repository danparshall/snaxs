function PAR=user_dispersion_menu(PAR);
% PAR= user_dispersion_menu(PAR);
%	Prompt user for data needed to plot dispersion and display results

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

%% ===
disp(' ')
disp(' === Calculate dispersion === ')

%% === get Q_min, Q_max, Q_npts from user ===
disp(' Input Q_min as "H K L", or "x" to exit');
[Q_min,PAR]=user_vector(INFO.Q_min,PAR);
	if Q_min=='x'; run=0; return; end			% exit if input is 'x'
PAR.INFO.Q_min=Q_min;

disp(' Input Q_max as "H K L", or "x" to exit');
[Q_max,PAR]=user_vector(INFO.Q_max,PAR);
	if Q_max=='x'; run=0; return; end			% exit if input is 'x'
PAR.INFO.Q_max=Q_max;

disp(' Input number of points (odd for symmetric scans)');
[Q_npts,PAR]=user_scalar(INFO.Q_npts,PAR);
	if Q_npts=='x'; run=0; return; end
PAR.INFO.Q_npts=Q_npts;

%% === initialize arrays, index variables ===
[unique_tau, cellarray_qs, Q_hkl, Q_delta]=generate_tau_q_from_Q(PAR);
e_array= [INFO.e_min : INFO.e_step : INFO.e_max];

%% === update ===
PAR.DATA.Q_hkl=Q_hkl;
PAR.DATA.E_array=e_array;
PAR.DATA.Q_delta=Q_delta;

%% === generate VECS ===
PAR=simulate_multiQ(PAR, Q_hkl);

%% === plot ===
plot_dispersion(PAR);

