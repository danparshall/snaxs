function PAR=user_Qscan_resconv(PAR);
% PAR=user_Qscan_resconv(PAR);
%	Simulates a constant-energy scan, convolving the resolution function with the
%	phonon simulation.  Uses ResLib function ConvSMA.  Values for Accuracy and
%	Method are set from DEFAULTS.m.  When using Fixed method, number of points
%	is chosen such that the computation time is approximately equal to the 
%	computation time when using MonteCarlo with the same Accuracy.
%	Output is plotted, but also saved to disk (in the same file as PAR).
%
%	The values for INFO are done as per a normal Q-scan (although only at a
%	single energy).  The convolved intensity is added to the DATA structure.
%
%	Also, should implement saving file at every datapoint- that way the user can
%	interrupt and still have something valuable.  This means hacking ResLib :/


[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

run=1;
while run 				% runs until some input received is 'x'
	disp(' ')
	disp(' === Simulating CONVOLVED Q-scan at fixed E === ')

	%% === get inputs from user ===
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
	
	%% === ResLib chokes if given unphysical value, so first test all values ===
	[XTAL,EXP,~,PLOT,DATA,VECS]=params_fetch(PAR);
	PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);
	[PARtest,goodvals]=check_ResLib(PAR);
	
	if length(goodvals)==0;
		disp(' ')
		disp('  Sorry, no valid Q-points found.')
		return;
	elseif length(goodvals)~=Q_npts;
		Q_npts=length(goodvals);
		Qmin=make_string_vector(PARtest.INFO.Q_min);
		Qmax=make_string_vector(PARtest.INFO.Q_max);
		disp(' Reducing range due to kinematic restrictions')
		disp(['  Q_min is now ' Qmin '.']);
		disp(['  Q_max is now ' Qmax '.']);
		disp(['  Npts is now ' num2str(Q_npts) '.']);
		PAR.INFO.Q_min=PARtest.INFO.Q_min;
		PAR.INFO.Q_max=PARtest.INFO.Q_max;
		PAR.INFO.Q_pts=Q_npts;
	end


	% === let user have one last chance to change accuracy, update as needed ===
	display_time_estimate(Q_npts, INFO);
	disp(' ')
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


	% === update all values in PAR, etc., then begin ===
	[Q_hkl,Q_delta]=make_graded_3vec(INFO.Q_max, INFO.Q_min, INFO.Q_npts);
	PAR.DATA.Q_hkl=Q_hkl;
	PAR.DATA.Q_delta=Q_delta;
	[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
	
	H=Q_hkl(:,1);
	K=Q_hkl(:,2);
	L=Q_hkl(:,3);
	E=INFO.E_const;

	tic;
	disp([ ' Starting convolution at ' datestr(now)])
	ts=clock;
	if strcmp(INFO.convmethod,'fixed')
		disp(' Starting FIXED-GRID convolution')
		fixres=display_time_estimate(Q_npts, INFO);

		convolution=ConvResSMA('sqwphonon',[],H,K,L,E,PAR.EXP,'fix',fixres,PAR);
		filename=['resconv__fix_' num2str(fixres(1)) '_' num2str(fixres(2)) '__Npts_' num2str(INFO.Q_npts) '__' datestr(now,30) ];

	elseif strcmp(INFO.convmethod,'mc')
		disp(' Starting MONTECARLO convolution')
		randres=INFO.accuracy;
		display_time_estimate(Q_npts, INFO);

		convolution=ConvResSMA('sqwphonon',[],H,K,L,E,PAR.EXP,'mc',randres,PAR);
		filename=['resconv__rand_' num2str(randres) '__Npts_' num2str(INFO.Q_npts) '__' datestr(now,30) ];
	else
		disp(' ERROR in "user_Qscan_resconv" : method must be "mc" or "fixed"');
		return;
	end
	save(filename,'PAR','convolution')
	% display elapsed time
	disp([ 'Completed convolution at ' datestr(now)])
	te=clock;

	disp([' Elaspsed time is ' num2str(round(etime(te,ts)/60)) ' minutes.'])

	% update DATA
	PAR.DATA.convolution=convolution;

	% plot convoluted data
	plot_Qscan_resconv(PAR,convolution);


	%% === this routine can change method, so reset to default values ===
	[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
	defINFO=DEFAULTS('INFO');
	INFO.convmethod= defINFO.convmethod;
	PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);
end


%% === this routine can change method, so reset following loop ===
[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
defINFO=DEFAULTS('INFO');
INFO.convmethod= defINFO.convmethod;
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);

