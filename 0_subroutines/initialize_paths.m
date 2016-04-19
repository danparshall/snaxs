function check=initialize_paths
% check=initialize_paths
%	Called once when starting SNAXS to search for critical folders/files,
%	and add paths if found.  If paths given in DEFAULTS.m are not correct, this
%	will make some guesses.  If SNAXS still can't find the files, it displays a
%	warning.
%
%	Searches for:
%		ResLib folder
%		exp folder (optional)
%		simulate_Escan.m (a proxy for the general subroutines)
%		ResMat.m (a proxy for the ResLib library)
%		anapert binary file
%		phonopy script file
%
%	Also turns off some warning messages in Octave

check=1;

%% === entirely optional, but it's nice to have one place for all EXP files ===
optional_exp_folder=DEFAULTS('exp_folder');
if ~isempty(optional_exp_folder);
	if exist(optional_exp_folder,'dir')==7
		disp('  SNAXS found an (optional) EXP folder as given in DEFAULTS.m');
		addpath(optional_exp_folder);
	end
end


%% === add ResLib ===
reslib_path = DEFAULTS('reslib_path');
if isempty(reslib_path);
	if exist('ResLib','dir')==7;
		warning(' No for ResLib folder given in DEFAULTS.m, but SNAXS took a guess');
		addath('ResLib');
	else
		warning(' Path to ResLib not found.  Triple-axis calls will crash.');
	end
else
	if exist(reslib_path,'dir')==7;
		addpath(reslib_path);
	else
		warning(' Path for ResLib given in "DEFAULTS.m" can not be found. Triple-axis calls will crash.');
	end
end


%% === 'simulate_Escan' should be in subroutines folder ===
if exist('simulate_Escan.m') == 2
%	disp('  SNAXS found "simulate_Escan.m", and presumably other subroutines')
else
	error('initError:simulate_Escan', ...
		['  SNAXS can''t find "simulate_Escan.m"; this is a Bad Thing.\n' ...
		'	Be sure the folder containing the SNAXS subroutines is on your path.']);
	check=0;
end


%% === make sure ResLib can be found ===
if exist('ResMat.m') == 2
%	disp('  SNAXS found "ResMat.m", and presumably the rest of ResLib');
else
	warning('  SNAXS can''t find "ResMat.m"; attempts to simulate neutrons will crash')
end


%% ANAPERT %%
%% === make sure anapert binary exists in correct location ===

% take a guess as to what it should be called
if isunix
	if ismac
		anapert_default_name='anapert.mac';
	else
		anapert_default_name='anapert.linux';
	end

elseif ispc
	anapert_default_name='anapert.exe';
end


% check to see if the standard file is found.  Warn if more than one version.
if system_octave
	anapert_found_path=which(anapert_default_name);	% octave only gives first path
else
	anapert_found_path=which(anapert_default_name,'-all');
	if ~isempty(anapert_found_path)
		if length(anapert_found_path)>1
			warning('  Multiple versions of anapert binary have been found.');
			for ind=1:length(anapert_found_path)
				disp(anapert_found_path{ind});
			end
			warning('  Will use path in DEFAULTS.m if it exists, or the first of these if not.')
		end
		anapert_found_path=anapert_found_path{1};
	end
end

% if the path in DEFAULTS agrees with the path found, there's no conflict
anapert_given_path=DEFAULTS('anapert');

if strcmp(anapert_given_path, anapert_found_path)
	anafound=1;

% if anapert_found_path doesn't exist, then use DEFAULTS path (if it exists)
elseif isempty(anapert_found_path)
	if exist(anapert_given_path,'file')==2
		anafound=1;
	else
		anafound=0;
		warning('  SNAXS can''t find the anapert binary.  Calls to anapert will crash')
	end

% if version wasn't given in DEFAULTS.m, but snaxs found a version anyway, use that
elseif isempty(anapert_given_path)
	anafound=1;
	warning(['  Didn''t find anapert binary at DEFAULTS.m location.  Using alternate path found at : ' anapert_found_path]);

% If there's a possible conflict, check to be sure they're not actually the same
% due to Relative vs. Absolute paths.  If they are, warn the user but go with DEFAULTS.m
else
	anafound=1;

	% given path, which depends on system separation character
	% this is a check in case DEFAULTS.m contains a Relative path
	% comparison of absolute paths was done above
	if ispc
		given = [pwd '\' anapert_given_path];
	else
		given = [pwd '/' anapert_given_path];
	end

	if ~strcmp(anapert_found_path, given)
		warning(['  Multiple versions of the anapert binary have been found.  Using DEFAULTS.m location : ' DEFAULTS('anapert') ]);
	end
end



%% PHONOPY %%
%% === make sure phonopy script exists in correct location ===

% take a guess as to what it should be called
if isunix
	phonopy_default_name='phonopy.linux';
end

% check to see if the standard file is found.  Warn if more than one version.
if system_octave
	phonopy_found_path=which(phonopy_default_name);	% octave only gives first path
else
	phonopy_found_path=which(phonopy_default_name,'-all');
	if ~isempty(phonopy_found_path)
		if length(phonopy_found_path)>1
			warning('  Multiple versions of phonopy script have been found.');
			for ind=1:length(phonopy_found_path)
				disp(phonopy_found_path{ind});
			end
			warning('  Will use path in DEFAULTS.m if it exists, or the first of these if not.')
		end
		phonopy_found_path=phonopy_found_path{1};
	end
end

% if the path in DEFAULTS agrees with the path found, there's no conflict
phonopy_given_path=DEFAULTS('phonopy');
if strcmp(phonopy_given_path, phonopy_found_path)
	phonofound=1;

% if phonopy_found doesn't exist, then use DEFAULTS path (if it exists)
elseif isempty(phonopy_found_path)
	if exist(phonopy_given_path,'file')==2
		phonofound=1;
	else
		phonofound=0;
		warning('  SNAXS can''t find the phonopy script.  Calls to phonopy will crash')
	end

% if version wasn't given in DEFAULTS.m, but snaxs found a version anyway, use that
elseif isempty(phonopy_given_path)
	phonofound=1;
	warning(['  Didn''t find phonopy script at DEFAULTS.m location.  Using alternate path found at : ' phonopy_found_path]);

% if there's a conflict, warn the user but go with DEFAULTS.m
else
	phonofound=1;

	% given path, which depends on system separation character
	% this is a check in case DEFAULTS.m contains a Relative path
	% comparison of absolute paths was done above
	if ispc
		given = [pwd '\' anapert_given_path];
	else
		given = [pwd '/' anapert_given_path];
	end

	if ~strcmp(phonopy_found_path, given)
		warning('  Multiple versions of the phonopy script have been found.  Using DEFAULTS.m location.');
	end
end



%% FINAL %%
%% === make sure at least one calculation program was found ===
calcfound= anafound | phonofound;
if ~calcfound;
	error(' At least one calculation program must be found');
end

check = check & calcfound;


%% === turn off an obnoxious warnings ===
if system_octave
	warning('off', 'Octave:possible-matlab-short-circuit-operator');
	warning('off', 'get: allowing markers to match line property markersize');
	warning('off', 'warning: implicit conversion from matrix to sq_string');
end

