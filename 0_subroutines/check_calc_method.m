function method=check_calc_method(data_path);
% method=check_calc_method(data_path);
%	Read title of structure file to determine calculation method which was used.
%	POSCAR is phonopy, ANALYSIS_DATA is anapert


% if file exists, determine if POSCAR/ANALYSIS_DATA
if exist(data_path,'file')==2

	% take just first 6 characters of filename
	[pathstr,filename,ext] = fileparts(data_path);
	calcfile=filename(1:6);

	% compare to known names
	if calcfile=='POSCAR'
		method='phonopy';
	elseif calcfile=='ANALYS'
		method='anapert';
	else
		error(' Calculation method could not be determined from force-constant file.')
	end

% if file doesn't exist, warn user
else
	error(' Force-constant file not found. Crashing.');
	method=[];
	return;
end

