function XTAL = read_POSCAR(XTAL)
% XTAL = read_POSCAR(XTAL)
% 	Creates XTAL structure from phonopy's POSCAR file
%	Analagous to read_ANALYSIS_DATA.m
%
%	This subroutine was written by Paul Neves.  Has seen only limited use, may
%	have bugs in unusual situations.
%

% open file in read-text mode (windows compatible)
if exist(XTAL.data_path,'file');
	fid=fopen(XTAL.data_path, 'rt');
else
	error(' POSCAR file not found.');
	XTAL=[];
	return
end

% === finds name for XTAL.name
atoms = fgetl(fid);
XTAL.name = atoms;


% === finds real basis for XTAL.basis_real
multiple = str2num(fgetl(fid));
row1 = str2num(fgetl(fid));
row2 = str2num(fgetl(fid));
row3 = str2num(fgetl(fid));
basis_real = multiple*[row1;row2;row3];
XTAL.basis_real = basis_real;


% === generates reciprocal basis from real basis for XTAL.basis_recip
% 		reciprocal basis is transpose of 2pi * inv(basis)
XTAL.basis_recip = 2*pi*inv(XTAL.basis_real)';


% === finds total # of atoms for XTAL.N_atom
nextLine = strtrim(fgetl(fid));
if isfinite(find(size(str2num(nextLine)) == 0))% possible for this line to be either the atoms or their numbers
	atoms = nextLine;
	nextLine = strtrim(fgetl(fid));
end
atom_quantities = str2num(nextLine);
XTAL.N_atom = sum(atom_quantities);


% === finds number of different types of atoms for XTAL.N_type
XTAL.N_type = length(atom_quantities);


% === creates index of all the atoms for XTAL.atom_kind
atom_kind = [];
for ind = 1:XTAL.N_type
	atom_kind = [atom_kind; repmat(ind,atom_quantities(ind),1)];
end
XTAL.atom_kind = atom_kind;


% ===check for comment indicator
iHash=regexp(atoms,'#');
if ~isempty(iHash);
	atoms=atoms([1:iHash(1)-1]);
end

iPcnt=regexp(atoms,'%');

if ~isempty(iPcnt);
	atoms=atoms([1:iPcnt(1)-1]);
end

% === convert atom string into cell ===
if 1
	XTAL.atom_types=strsplit(strtrim(atoms));

else	% old method
	iSpace=regexp(atoms,' ');
	N_spcs=length(iSpace);
	atom_types=cell(N_spcs,1);

	% if spaces were found, use them to parse
	if ~isempty(iSpace)
		for ind=1:N_spcs
			if iSpace(1)==1	% leading 
				if ind==N_spcs
					atom_types{ind}=strtrim(atoms([iSpace(ind):end]));
				else
					atom_types{ind}=strtrim(atoms([iSpace(ind):iSpace(ind+1)]));
				end
			elseif iSpace(end)==length(atoms)
				if ind==1
					atom_types{ind}=strtrim(atoms([1:iSpace(ind)]));
				else
					atom_types{ind}=strtrim(atoms([iSpace(ind-1):iSpace(ind)]));
				end
			end
		end
		XTAL.atom_types = atom_types;
	% if not, assume there is only one atom type
	else
		XTAL.atom_types{1}=atoms;
	end
	XTAL.atom_types=XTAL.atom_types(:)';	% row vector
end

% === finds location of atoms for XTAL.atom_position
fgetl(fid);% the next line is always "Direct," so we don't care
atom_position = [];
for ind = 1:XTAL.N_atom
	atom = sscanf(fgetl(fid), '%f %f %f %*s');
	atom_position = [atom_position; atom(:)'];
end

% check that atom_position is well-formed
[nRow,nCol]=size(atom_position);
if (nRow~=XTAL.N_atom) | (nCol~=3)
	warning('atom_position is not correct shape')
end
XTAL.atom_position = atom_position;

