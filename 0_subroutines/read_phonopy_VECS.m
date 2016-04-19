function VECS = read_phonopy_VECS(PAR,Q_list)
% VECS = read_phonopy_VECS(PAR,Q_list)
% 	Obtain eigenvectors for given Q-points by calling phonopy
% 	Q_points must be a Nx3 matrix where N is the number of Q-points to look at
% 	This requires that the qpoints.yaml be in the working directory
%
%	VECS is a structure which contains:
%		title
% 		list of Q_points
% 		data array (cell array Nq long x 2 )
%
% 		the two columns of the data array are:
% 			list of energies (Nph long)
%			mode_data array (3*N_atom rows, 2 cols (real/imag), Nph pages)
%			each page is a single energy, and the 3*N_atom rows are XYZ for each atom
%
%	This subroutine was written by Paul Neves.  Has seen only limited use, may
%	have bugs in unusual situations.
%	TODO : read electron-phonon coupling as well (currently assigned to 0)

%% can probably pull energy/vecs assignment out of the FOR loop near line 74

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
N_atom=XTAL.N_atom;
Nq = size(Q_list,1);
Nph = 3*N_atom;


%% === throw error if file not found ===
if strcmp(XTAL.calc_method,'phonopy');
	if ~exist('qpoints.yaml','file')
		error(' The qpoints.yaml file could not be found. Possibly an error with the phonopy binary, or with finding "liblapack.so.3"');
	end
end

%% === initialize VECS, arrays ===
% vecs is organized (3dir*N_atom, Nq, Nmodes)
if ~isfield(VECS,'title')
	VECS.title='VECS';
end
VECS.Q_points=zeros(Nq,3);
VECS.energies=zeros(Nph,Nq);
VECS.vecs=zeros(3*N_atom,Nq,Nph);

mode_data=zeros(3*N_atom,2,Nph);
energy_data=zeros(Nph,1);

%% === read and parse data file ===
raw_text = fileread(['qpoints.yaml']);
[junk,freq_ind_info] = regexp(raw_text,'frequency:');
[junk,eig_ind_info] = regexp(raw_text,'      - \[');

frequency = zeros(Nph,Nq);
eigenvectors = zeros(Nph,Nq,Nph);
for point = 1:Nq
	for pho = 1:Nph
		index = freq_ind_info(1,(point-1)*Nph+pho)+1;
		frequency(pho,point) = str2num(raw_text(index:index+15));
		for atom = 1:Nph/3
			for ind = 1:3
				index = eig_ind_info(1,(point-1)*Nph^2+(pho-1)*Nph+3*(atom-1)+ind)+1;
				realimag = str2num(raw_text(index:index+37));
				eigenvectors((atom-1)*3+ind,point,pho) = realimag(1)+i*realimag(2);
			end
		end
	end
end

% update VECS
THz2meV = 4.13567;			%phonopy uses THz for energy, we want meV
VECS.energies=frequency*THz2meV;
VECS.vecs=eigenvectors;

for ind_Q=1:Nq;
	VECS.Q_points(ind_Q,:) = calc_prm_to_cnv(XTAL,Q_list(ind_Q,:),EXP);% add to VECS.qs array
end

%% === someday this will read the linewidths as well ===
VECS.phWidths=zeros(size(VECS.energies));

