function PAR=user_SQW_menu(PAR);
% PAR= user_SQW_menu(PAR);
%	Prompt user for data needed to simulate a slice of S(q,w), then call
%	to anapert() and display results

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

% ===
disp(' ')
disp(' === Simulating slice of S(q,w) === ')


% === get Q_min, Q_max, Q_npts from user ===
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


% === generate SQE_array ===
disp(' Calculating...');
PAR=simulate_SQW(PAR);


% === plot ===
plot_SQW(PAR);


% === cleanup ===
disp(' ... finished!');

