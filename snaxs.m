function PAR=snaxs(exp_name, calculation_path);
% PAR=snaxs(exp_name, calculation_path);
%
% SNAXS: Simulating Neutron And X-ray Scans
% 	a CLI wrapper to anapert and phonopy
% 	SNAXS was written by Dan Parshall: 
% 	anapert was written by Rolf Heid
% 	phonopy was written by Atz Togo: http://sourceforge.net/projects/phonopy/
% 	use: PAR=snaxs(exp_name,'calculation_path');
%
% When calling with inputs directly from command line, exp_name is without 
% quotes or .m extension, calculation_path is with quotes

% This is basically just an intialization routine, which then calls the
% main menu.  


%%	=== find DEFAULTS.m, initialize paths therein ===
if ~exist('DEFAULTS.m', 'file');
	error( 'noDEFAULTS:FileNotFound', [' SNAXS can''t find "DEFAULTS.m"; this is a Bad Thing.\n' ...
			'\t Make sure DEFAULTS.m is either in your working directory, your \n' ...
			'\t system-specific MATLAB folder, or edit "snaxs.m" and use the \n' ...
			'\t "addpath" function to include the folder containing DEFAULTS.m']);
end

	% add subroutine path
	subroutine_path = DEFAULTS('subroutine_path');
	if ~isempty(subroutine_path);
		% if DEFAULTS returned a path, try it
		if exist(subroutine_path,'dir')==7;
			addpath(subroutine_path);
		else
			disp(' Path for subroutines given in "DEFAULTS.m" can''t be found.  Likely to crash.');
		end
	else
		% if not, see if "0_subroutines" is here
		if exist('0_subroutines','dir')==7
			addpath('0_subroutines');
		else
			disp(' Path to subroutines not found.  Likely to crash.');
		end
	end

	if ~initialize_paths;
		PAR=[];
		error(' Initialize failed.');
		return;
	end


%% ======== welcome screen ============
display_welcome_screen;


%% === INITIALIZE EXP STRUCTURE ===
if ~exist('exp_name')
	PAR.EXP=input(' Please input name of the EXP.m to use (no quotes or .m): ');
else
	PAR.EXP=exp_name;
end
[PAR, check]=initialize_EXP(PAR);

	% if EXP isn't good, abort
	if ~check
		error(' EXP structure failed');
		return;
	end

%% === INITIALIZE XTAL ===
if ~exist('calculation_path')
	if isfield(PAR.EXP,'calculation_path')
		calculation_path=PAR.EXP.calculation_path;
	else
		calculation_path=input(' Please input the path to the calculation file (no quotes): ','s');
	end
end % set calculation_path

PAR=initialize_XTAL(PAR,calculation_path);

	% if XTAL isn't good, abort
	if ~PAR.XTAL.check
		error(' XTAL structure failed.');
		return;
	end


%% === INITIALIZE OTHERS ===
if ~isfield(PAR,'INFO'); PAR.INFO=DEFAULTS('INFO'); end
if ~isfield(PAR,'PLOT'); PAR.PLOT=DEFAULTS('PLOT'); end
PAR.INFO.title='Metadata about the scans to be calculated.';
PAR.DATA.title='Calculated data for a particular scan.';
PAR.VECS.title='Eigenvectors and structure factors.';
system_initialize(PAR);


%% === HACK TO PREVENT WINDOWCRASH ===
if ~isempty(findobj('type','figure'))
% The problem is that plot_SQW (and others) use DATA.Q_delta.  But DATA gets
%	renewed when starting SNAXS.  So if a user leaves a figure open, and then
%	starts SNAXS, and then tries to plot_toggle_linlog, SNAXS will "re-plot"...
%	except that the DATA structure doesn't exist, so it crashes.
%
%	The graceful solution to this problem is probably to read the axes from the
%	current figure in order to produce the data.  But that will take some work
%	to handle correctly.  This is a stopgap that might be annoying, but at least
%	doesn't crash.
%
%	Related: plot_SQW, plot_Qscan, and plot_Qscan_resconv all use different
%	methods to get the Q array for the x-axis.  That should be standardized.

	warning('  So sorry about this, but I have to close any currently-opened figures.  Later I will try to handle this more gracefully. ')
	close all;


end

%% === MAIN MENU ===
PAR=user_main_menu(PAR);


%% === CLEANUP WHEN CLOSING === (comment out this line to save output)
system_cleanup(PAR.XTAL.calc_method);

