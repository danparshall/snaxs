function system_initialize(PAR);
% system_initialize(PAR);
%	Like a clean-up and refresh on startup.  Deletes all old files, creates new
%	links to calculation file.

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

%% === check for libblas and lapack ===
if isunix

	if ~ismac
	% general *nix behavior (ismac is special case of isunix)
		if 0	% libblas may not be critical
			[bin,blas]=system('locate libblas.so.3gf');
			if isempty(blas);
				warning(' Unable to locate libblas.so.3gf : may cause problems.');
			end
		end

		if 1	% liblapack is critical for both phonopy and anapert
			[bin,lapack]=system('locate liblapack.so.3');
			if isempty(lapack);
				error(' Unable to locate liblapack.so.3');
			end
		end
	
	%else
	% may include checking of mac libraries in the future

	end % ~ismac
end % isunix


%% === phonopy ===
if strcmp(XTAL.calc_method,'phonopy')

	%% === linux ===
	if isunix

		[status,result]=system('file POSCAR');
		if ~status 						% delete old (but only if a soft link)
			if regexp(result, 'symbolic link')
				system('rm -f POSCAR');
			else
				warning(' POSCAR is not a softlink.  Best practice is to point to POSCAR using EXP.calculation_path');
			end
		end

		[status,result]=system('file FORCE_SETS');
		if regexp(result, 'symbolic link')
			system('rm -f FORCE_SETS');
		end

		[status,result]=system('file FORCE_CONSTANTS');
		if regexp(result, 'symbolic link')
			system('rm -f FORCE_CONSTANTS');
		end

		[status,result]=system('file BORN');
		if regexp(result, 'symbolic link')
			system('rm -f BORN');
		end


		% link to calculations, verify in place
		thisdir=pwd;
		system(['ln -s ' XTAL.data_path ' ./POSCAR']);
		if ~exist([thisdir '/POSCAR'],'file');
			warning('	POSCAR not found in working directory.')
		end

		basedir=XTAL.data_path;
		ind=find(basedir=='/');
		basedir=basedir(1:ind(end));		% ind(end) is last '/'

		if exist([basedir 'BORN'])
			system(['ln -s ' basedir 'BORN ./BORN']);
			if ~exist([thisdir '/BORN'],'file');
				warning('	BORN not found in working directory.')
			end
		end

		if exist([basedir 'FORCE_SETS'],'file')
			system(['ln -s ' basedir 'FORCE_SETS ./FORCE_SETS']);
			if ~exist([thisdir '/FORCE_SETS'],'file');
				warning('	FORCE_SETS not found in working directory.')
			end

		elseif exist([basedir 'FORCE_CONSTANTS'],'file')
			system(['ln -s ' basedir 'FORCE_CONSTANTS ./FORCE_CONSTANTS']);
			if ~exist([thisdir '/FORCE_CONSTANTS'],'file');
				warning('	FORCE_CONSTANTS not found in working directory.')
			end
		else
			warning(' FORCE_SETS file was not found, has it been generated?');
		end


		% check to be sure that phonopy binary works
		system_phonopy(PAR,'test');


	%% === windows ===
	elseif ispc
		error(' Phonopy is not supported in Windows.')
	end % isunix / ispc


%% === anapert ===
elseif strcmp(XTAL.calc_method,'anapert');

	%% === linux ===
	if isunix

		% delete old anapert files
		system('rm -f phonon_modes P_INP P_LOG P_OUT P_STAT P_TIME strufac_* epc_linewidth P_DOS P_GDOS');

		% delete old ANALYSIS_DATA (but only if a soft link)
		[status,result]=system('file ANALYSIS_DATA');
		if regexp(result, 'symbolic link')
			system('rm -f ANALYSIS_DATA');
		elseif regexp(result, 'ASCII text');
			warning(' ANALYSIS_DATA is not a softlink.  Best practice is to point to ANALYSIS_DATA using EXP.calculation_path');
		end

		% check that anapert works
%		[status,result]=system_anapert(XTAL,[],'test');


		% create new link to data
		system(['ln -s ' XTAL.data_path ' ./ANALYSIS_DATA']);

	%% === windows ===
	elseif ispc
		% delete old
		system('del FORCE_SETS POSCAR QPOINTS qpoints.yaml MP mesh.yaml partial_dos.dat');

		% Windows requires admin privilege to make a link, so we have to *copy*
		system(['copy ' XTAL.data_path ' ANALYSIS_DATA' ]);

	end % isunix / ispc

end % strcmp(method)

