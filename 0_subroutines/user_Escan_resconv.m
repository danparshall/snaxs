function PAR=user_Escan_resconv(PAR);
% PAR=user_Escan_resconv(PAR);
%	Simulates a constant-Q scan, convolving the resolution function with the
%	phonon simulation.  Uses ResLib function ConvSMA.  Values for Accuracy and
%	Method are set from DEFAULTS.m.  When using Fixed method, number of points
%	is chosen such that the computation time is approximately equal to the 
%	computation time when using MonteCarlo with the same Accuracy.
%	Output is plotted, but also saved to disk (in the same file as PAR).
%
%	The values for INFO are done as per a normal E-scan (although only at a
%	single energy).  The convolved intensity is added to the DATA structure.
%
%	Also, should implement saving file at every datapoint- that way the user can
%	interrupt and still have something valuable.  This means hacking ResLib :/


[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

run=1;
while run 				% runs until input received is 'x'
	disp(' ')
	disp(' === Simulating CONVOLVED E-scan at fixed Q ===')
	
	disp(' Input Q as "H K L", or "x" to exit');
	[Q_in,PAR]=user_vector(PAR.INFO.Q,PAR);
	if Q_in=='x'; run=0; break; end
	PAR.INFO.Q=Q_in;


	%% === make calculation at nominal value so PAR has all fields correct ===
	PAR=simulate_single(PAR);
	PAR=simulate_Escan(PAR,PAR.VECS.strufac_data);
	
	disp(' Input minimum and maximum energy, or "x" to exit');
	[erange,PAR]=user_minmax([INFO.e_min INFO.e_max],PAR);
	if erange=='x'; run=0; break; end
	PAR.INFO.e_min=erange(1);
	PAR.INFO.e_max=erange(2);
	
	disp(' Input energy step, or "x" to exit');
	[e_step,PAR]=user_scalar(INFO.e_step,PAR);
	if e_step=='x'; run=0; break; end
	PAR.INFO.e_step=e_step;
	E=[PAR.INFO.e_min : PAR.INFO.e_step : PAR.INFO.e_max];


	%% === ResLib chokes if given unphysical value, so first test all values ===
	PARtest=PAR;
	PARtest.DATA.centers=E;
	PARtest.DATA.heights=ones(size(E));
	PARtest.DATA.ph_widths=ones(size(E));
	PARtest=check_ResLib(PARtest);

	if numel(PARtest.DATA.centers)==0;
		disp(' ');
		disp('  Sorry, no accessible energy range.');
		return;
	elseif numel(PARtest.DATA.centers)~=length(E);
		Emin=min(PARtest.DATA.centers);
		Emax=max(PARtest.DATA.centers);
		disp(' Reducing range due to kinematic restrictions')
		disp(['  e_min is now ' num2str(Emin) ])
		disp(['  e_max is now ' num2str(Emax) ]);
		PAR.INFO.e_min=Emin;
		PAR.INFO.e_max=Emax;
		E=[PAR.INFO.e_min : PAR.INFO.e_step : PAR.INFO.e_max];
	end


	% === let user have one last chance to change accuracy, update as needed ===
	display_time_estimate(length(E), INFO);
	disp(' ');
	disp(' Input convolution accuracy, or "x" to exit');
	[accuracy,PAR]=user_scalar(INFO.accuracy,PAR);
		if accuracy=='x'; run=0; break; end

	if accuracy<0
		disp(' Accuacy must be non-negative');
		accuracy = 0
	end

	PAR.INFO.accuracy=round(accuracy);
	if PAR.INFO.accuracy==0;
		PAR.INFO.convmethod='fixed';
	end

	[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);


	% === begin convolution ===	
	H=INFO.Q(:,1);
	K=INFO.Q(:,2);
	L=INFO.Q(:,3);

	tic;
	disp([ ' Starting convolution at ' datestr(now)])
	ts=clock;
	if strcmp(INFO.convmethod,'fixed')
		disp(' Starting FIXED-GRID convolution')
		fixres=display_time_estimate(length(E), INFO);

		convolution=ConvResSMA('sqwphonon',[],H,K,L,E,PAR.EXP,'fix',fixres,PAR);
		filename=['resconv__fix_' num2str(fixres(1)) '_' num2str(fixres(2)) '__Escan__Npts_' num2str(length(E)) '__' datestr(now,30) ];

	elseif strcmp(INFO.convmethod,'mc')
		disp(' Starting MONTECARLO convolution')
		randres=INFO.accuracy;
		display_time_estimate(length(E), INFO);

		convolution=ConvResSMA('sqwphonon',[],H,K,L,E,PAR.EXP,'mc',randres,PAR);
		filename=['resconv__rand_' num2str(randres) '__Escan__Npts_' num2str(length(E)) '__' datestr(now,30) ];

	else
		error(' Method must be "mc" or "fixed"');
		return;
	end

	% display elapsed time, save
	disp([ 'Completed convolution at ' datestr(now)]);
	disp([' Elaspsed time is ' num2str(round(etime(clock,ts)/60)) ' minutes.']);
	save(filename,'PAR','convolution');


	% === update DATA ===
	PAR=simulate_Escan(PAR);
	PAR.DATA.int=convolution;
	PAR.DATA.convolution=convolution;


	% === plot convoluted data ===
	if ~isempty(PAR.DATA.centers)
		PAR=plot_Escan(PAR);
	else
		disp(['  Sorry, there are no accessible phonons at that Q-point between ' num2str(INFO.e_min) ' and ' num2str(INFO.e_max) ' meV']);
	end

	%% === this routine can restrict energy range, so reset to default values ===
	[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
	defINFO=DEFAULTS('INFO');
	INFO.e_max = defINFO.e_max;
	INFO.e_step= defINFO.e_step;
	INFO.e_min = defINFO.e_min;
	INFO.convmethod= defINFO.convmethod;
	PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);
end


%% === reset to default values (used following while loop in case of 'x' ) ===
[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
defINFO=DEFAULTS('INFO');
INFO.e_max = defINFO.e_max;
INFO.e_step= defINFO.e_step;
INFO.e_min = defINFO.e_min;
INFO.convmethod= defINFO.convmethod;
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);

