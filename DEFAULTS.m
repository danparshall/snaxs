function output=DEFAULTS(request);
% lookup for default values.

%	=== CALCULATOR PATH ===
%	This is the path to the calculator binary (anapert or phonopy)
anapert='0_subroutines/anapert.exe';
phonopy='phonopy_files/phonopy.linux';


% 	=== ResLib PATH ===
%	path to the ResLib package by A. Zheludev (availble from ORNL).
reslib_path='0_subroutines/ResLib/';


%	=== subroutine path ===
subroutine_path='0_subroutines';


%  === EXP path ===
%	optional path to folder containing EXP files.
exp_folder = '0_EXP_files';


%	=== PLOT ===
	PLOT.markers=1;					% shows a '*' for the peak energy and height
	PLOT.semilog=0;					% plots intensity on logarithmic scale
	PLOT.decades=10;				% max number of decades visible in semilog Escan or SQE_array
	PLOT.y_limit=[0 5];
	PLOT.scale_atom = 0.5;			% scale factor for atom radius
	PLOT.scale_disp = 1.5;			% scale between polarization vector and displacement
	PLOT.expansion = [5 5 2];		% supercell expansion
	PLOT.quiet = 0;					% 0 displays graph; 1 saves to figure


%	=== INFO ===
%	anapert() and phonopy give S(q,w) as function of Q.  All scans are built by 
%	generating an E-scan at a single Q. Those scans are then assembled for more 
%	complex data such as Q-scans and S(q,w)

	INFO.scantype=1;		% 1 for HKL units, 2 for Q_mag

	% === determining height (all scans) ===
	INFO.bose = 1;			% include bose factor
	INFO.degrees = 1;		% temperature
	INFO.Q_squared = 1;		% include Q^2 if 1, set to 0 if not
	INFO.one_ovr_omega=1;	% include 1/omega factor for scattering
	INFO.bragg_handling= 0;	% if 1 set eng to 0.1meV, if 0 set height to 0
	INFO.kfki=1;			% include kf/ki factor

	% === for energy-scan at fixed Q (all scans) ===
	INFO.Q = [ 0 3.85 0];	% Q-point
	INFO.e_max=110;			% also used for S(q,w) and dispersion plots
	INFO.e_step=0.1;
	INFO.e_min=INFO.e_step;

	% === for S(q,w) & q-scan at fixed energy ===
	INFO.Q_min = [0 0 0];		% starting Q for S(q,w), dispersion, Q-scans
	INFO.Q_npts= 401;
	INFO.Q_max = [0 4 0];		% ending Q for S(q,w), dispersion, Q-scans
	INFO.E_const= 6.5;			% constant energy for Q-scans

	% === warnings ===
	INFO.warn_tof_res=1;	% warning about tof approximation
	INFO.warn_exp_type=1;	% inform user whether this is tas,tof,xray
	INFO.warn_strfac_test=1;%

	% === resolution convolution ===
	INFO.timescale=7.5;			% ~seconds to compute 1000 Q-points on this machine.
	INFO.accuracy=1;			% accuracy setting for ResLib ConvResSMA.
	INFO.convmethod='mc';		% 'fixed' = fixed grid, 'mc' = montecarlo
	INFO.resconv='qscan';		% flag for convolving 'escan' or 'qscan'


	% === other ===
	INFO.voigt = 0;			% if 0 use pseudo-voigt (faster), if 1 use Hui-Voigt (more accurate)


%	=== ANALYZE_MODES ===
%
ANALYZE_MODES.list_q = [];
ANALYZE_MODES.list_tau=[];
ANALYZE_MODES.symm_info = 'yes';
ANALYZE_MODES.vector_info = 'no';
ANALYZE_MODES.epc_info = 'yes';
ANALYZE_MODES.scattering_factors =[];


% === SWITCH LOGIC TO DELIVER REQUESTED DATA ================================
%
%		DO **NOT** CHANGE THIS
%
%
switch request

	case {'anapert'}
		if exist('anapert','var')
			output = anapert;
		else
			output = [];
		end

	case {'phonopy'}
		if exist('phonopy','var')
			output = phonopy;
		else
			output = [];
		end

	case {'subroutine_path'}
		if exist('subroutine_path','var')
			output = subroutine_path;
		else
			output = [];
		end

	case {'reslib_path'}
		if exist('reslib_path','var');
			output = reslib_path;
		else
			output = [];
		end

	case {'exp_folder'}
		if exist('exp_folder')
			output = exp_folder;
		else
			disp(' ERROR in "DEFAULTS.m" : No exp_path defined.')
			output=[];
		end

	case {'INFO'};
		output = INFO;

	case {'PLOT'}
		output = PLOT;

	case {'ANALYZE_MODES'}
		output = ANALYZE_MODES;

	otherwise
		disp('  ERROR in "DEFAULTS.m" : the requested data could not be found')
end

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
