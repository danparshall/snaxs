%% An example of how to run SNAXS in an automated mode.
%% This script generates resolution-convolved acoustic branches
%% Basically this runs "user_Qscan_resconv" inside of a loop, and stiches
%% together the separate Q-scans in order to produce a slice of S(q,w)
%% Each Q-scan is saved separately, in case it's needed later.


% high-level functions in SNAXS pass data with PAR structure, "auto_PAR" loads it
PAR = auto_PAR(EXPtas);
[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);


%% === set Q-range ===
Q_npts = 101;
INFO.Q_min= [-0.25 2 0];
INFO.Q_max= [ 0.25 2 0];
INFO.Q_npts=Q_npts;
INFO.accuracy = 3;
INFO.convmethod='mc';


%% === set energy range ===
energy_values = [1 : 0.5 : 10 ];
E_npts = length(energy_values);


%% === default values for this script take ~ 12 hours on my machine ===
display_time_estimate(Q_npts*E_npts, INFO);


%% === each iteration calculates a single convolved Q-scan, appends to fullmat 
fullmat = [];
for ind = 1:E_npts

	%% === update energy ===
	INFO.E_const = energy_values(ind);

	
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
		disp(' ERROR : method must be "mc" or "fixed"');
		return;
	end
	save(filename,'PAR','convolution')
	% display elapsed time
	disp([ 'Completed convolution at ' datestr(now)])
	te=clock;

	disp([' Elaspsed time is ' num2str(round(etime(te,ts)/60)) ' minutes.'])

	% update DATA, fullmat
	PAR.DATA.convolution=convolution;
	fullmat = [fullmat; convolution(:)'];

	% plot convoluted data
	plot_Qscan_resconv(PAR,convolution);

	if system_octave;
		drawnow()
	end
end


imagesc(log(fullmat));
axis on
axis tight normal
fa=gca;
set(fa,'YDir','normal');
