function PAR=simulate_DOS(PAR,DOS);
% PAR=simulate_DOS(PAR,DOS);
%	simulate generalized phonon density-of-states

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

eng=DOS.eng;
if eng(1) > 0
	disp(' NOTE in "simulate_DOS" : normalization may be incorrect.')
end

tic;
disp(' Calculating phonon density-of-states...');


%% === phonopy ===
if strcmp(XTAL.calc_method,'phonopy');
	write_phonopy(PAR,DOS);
	system_phonopy(PAR, 'pdos');
	disp('   ... done!');


%% === anapert ===
elseif strcmp(XTAL.calc_method,'anapert');
	eng=[eng(1) : eng(3) : eng(2)];				% convert from [min max step]
	DOS.eng=[eng(1) eng(end) length(eng)-1];	% convert to min max Npts

	write_anapert(PAR,DOS);
	system_anapert(XTAL);
	disp('   ... done!');


else
	error(' Calculation method unknown.')
end

PAR=read_PDOS(PAR,DOS);
toc;

