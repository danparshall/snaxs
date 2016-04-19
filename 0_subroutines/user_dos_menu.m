function PAR=user_phonon_dos(PAR);
% PAR=user_phonon_dos(PAR);
%	Calculate density-of-states using either MP option in phonopy, or anapert
%	control parameter 70.  Default values for energy and resolution are
%	estimated, then confirmed with the user.  All other options hard-coded
%	within the "simulate_DOS" subroutine.

% Keep orig version, because this will overwrite DATA.centers, and allows e=0
% Final version is swapped out at the end of this function.
PARorig=PAR;

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);


disp(' ');
disp(' === Simulating phonon density-of-states ===');

%% === set default min/max energy ===
emin=0;

if strcmp(EXP.experiment_type, 'xray')
	emax = INFO.e_max;
else
	if EXP.infin == 1	% fixed Ei
		if EXP.efixed > INFO.e_max ;
			emax=INFO.e_max;
		else
			emax=EXP.efixed;
		end

	elseif EXP.infin == -1  % fixed Ef
		emax=INFO.e_max;

	else
		error(' Which energy is fixed?');
	end
end

%% === get min/max energy from user; sanitize ===
disp(' Input minimum and maximum of energy range:')
[minmax,PAR]=user_minmax([emin emax], PAR);
	if minmax=='x'; run=0; return; end
[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

% check emax for neutron experiments
if strcmp(EXP.experiment_type, 'xray')
	emax = minmax(2);

else	% for neutrons
	if (EXP.efixed < minmax(2)) & EXP.infin == 1
		disp([' Maximum allowed energy transfer is Ei= ' num2str(EXP.efixed) ])
		emax=EXP.efixed;
	else
		emax=minmax(2);
	end
end

% check emin
if emin < 0
	warning off backtrace
	warning(' Negative energy may cause problems; resetting to 0');
	warning on backtrace
	emin=0;
else
	emin=minmax(1);
end

eng=[ emin emax INFO.e_step];
INFO.e_min=emin;
INFO.e_max=emax;
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);
[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);


%% === get resolution FWHM at min/max energy of interest ===
if strcmp(EXP.experiment_type,'tof')

	% for TOF, width depends only on E
	DATA.centers=[emin emax];
	PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);
	wids=res_widths_tof(PAR);


elseif strcmp(EXP.experiment_type,'tas')

	% min Q goes like sqrt(E), add kf to get mean of Qmin/Qmax
	Qmin=calc_eng_to_mom(emin) + calc_eng_to_mom(EXP.efixed);
	Qmax=calc_eng_to_mom(emax) + calc_eng_to_mom(EXP.efixed);

	% determine width for min Q-E and max Q-E
	centers = [emin emax];
	Qvals = [Qmin Qmax];
	[R0,RMS]=ResMat(Qvals, centers, EXP);

	wids(1)=sqrt(2*log(2)./RMS(3,3,1));
	wids(2)=sqrt(2*log(2)./RMS(3,3,2));


elseif strcmp(EXP.experiment_type, 'xray')

	% x-ray resolution independent of energy transfer
	wids(1) = EXP.xray_res;
	wids(2) = EXP.xray_res;
end



%% === confirm smearing width with user (anapert allows min/max, phonopy only 1)
if strcmp(XTAL.calc_method,'phonopy');
	disp(' Input width of energy resolution (smearing function):')
	[wids,PAR]=user_scalar(mean(wids), PAR);
		if wids=='x'; run=0; return; end

elseif strcmp(XTAL.calc_method,'anapert');
	disp(' Input FWHM of energy resolution at minimum/maximum of energy range:')
	[wids,PAR]=user_minmax(wids, PAR, {'h'});
		if wids=='x'; run=0; return; end
end
[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);



%% === default mesh grid ===
nxyz=[10 10 10];
disp(' Input number of sampling points for the Brillouin zone mesh:')
[vec,PAR]=user_vector(nxyz, PAR);
	if vec=='x'; run=0; return; end
nxyz=round(vec);


%% === now calculate, plot, update ===
DOS.nxyz=nxyz;
DOS.eng=eng;
DOS.wids=wids;
PAR = simulate_DOS(PAR,DOS);

plot_GDOS(PAR);

