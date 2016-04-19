function write_phonopy(PAR,VAR);
% write_phonopy(PAR,VAR);
%	General function for writing any file which is to be read by phonopy
%	VAR can take various forms


[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

THz2meV = 4.13567;


if isfield(EXP,'dim');
	dim=EXP.dim;
else
	disp(' NOTE in "write_phonopy" : using default size for DIM');
	dim=[2 2 2];
end

%% check if FORCE_CONSTANTS file is in use, set flag if it is
[status,results]=system('ls FORCE_CONSTANTS');
if status==0	% 0 because bash
	fcm=1;
else
	fcm=0;
end

%% check if BORN file is in use, flag if so
[stat, res] = system('ls BORN');	% Octave bug: prints res to screen if not found
if stat==0	% because bash
	born=1;
else
	born=0;
end

% === phonon DOS ===
if isstruct(VAR);
	if isfield(VAR,'nxyz') & isfield(VAR,'eng') & isfield(VAR,'wids');
		nxyz = VAR.nxyz;
		eng  = VAR.eng / THz2meV;
		wids = VAR.wids/ THz2meV;


		%% === phonopy uses commas to separate atom types for pDOS ===
		pdos='1';
		comma=unique(XTAL.atom_kind,'first');
		for ind=2:XTAL.N_atom
			if ismember(ind,comma);
				pdos = [pdos ','];
			end
			pdos = [pdos ' ' num2str(ind)];
		end


		%% === write input file.  See phonopy documentation 
		fid=fopen('MP','wt');
		fprintf(fid,['DIM = ' num2str(dim) '\n']);
		if fcm;
			fprintf(fid,'FORCE_CONSTANTS = READ\n');
		end
		if born
			fprintf(fid,'NAC = .TRUE.\n');
		end
		fprintf(fid,['MP = ' num2str(nxyz) '\n']);
		fprintf(fid,['GAMMA_CENTER = .TRUE.\n']);
		fprintf(fid,['DOS_RANGE = ' num2str(eng) '\n']);
		fprintf(fid,['PDOS = ' pdos '\n']);
		fprintf(fid,['SIGMA = ' num2str(wids) '\n']);


		fclose(fid);

	else
		error(' VAR input must contain nxyz, eng, & wids');
	end



% === write QPOINTS ===
elseif isnumeric(VAR)
	if size(VAR,2)==3;
		%INPUTS:
		%	unique_q -- Input of locations in Brillouin zone (can be Nx3 matrix 
		%	where N is the number of Q-points); must be given in primitive basis

		unique_q = VAR;

		num_points = size(unique_q,1);

		% phonopy has all q-points on a single line, just reads in batches of 3
		sym_point = unique_q';

		QPOINTS = fopen('QPOINTS','wt');
		fprintf(QPOINTS,['DIM = ' num2str(dim) '\n']);
		if fcm;
			fprintf(QPOINTS,'FORCE_CONSTANTS = READ\n');
		end
		if born
			fprintf(QPOINTS,'NAC = .TRUE.\n');
		end
		fprintf(QPOINTS,'QPOINTS = ');
		fprintf(QPOINTS,'%g ',sym_point);
		fclose(QPOINTS);
	else
		error(' Numeric input must have a size of Nx3.');
	end
end

