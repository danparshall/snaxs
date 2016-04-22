function PAR=auto_PAR(EXPfile);
% PAR=auto_PAR(EXPfile);
%	Automatically generate PAR structure without any user input.  Useful for 
%	scripts, etc.  Still does most sanity checks and gives warnings if files
%	not found.



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
		disp(' Path for subroutines given in "DEFAULTS.m" can not be found.  Likely to crash.');
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


PAR.EXP=EXPfile;
[PAR,pass]=initialize_EXP(PAR);

% if EXP isn't good, abort
if ~pass
	return;
end


%% === INITIALIZE XTAL ===
if ~isfield(PAR.EXP,'calculation_path')
	error(' The EXP file must contain a path to the calculation file.');
else
	calculation_path=PAR.EXP.calculation_path;
end

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

