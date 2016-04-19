function PAR=initialize_XTAL(PAR,optional_path);
% PAR=initialize_XTAL(EXP,optional_path);
%	Creates XTAL structure from calculation file.
%
%	Well-formed XTAL will have:
%		N_atom
%		basis_real (bravis basis in real space)
%		atom_types
%		atom_kind	(N_atoms long, indicating which type for each atom)
%		atom_position (in PRIMITIVE basis; conventional is atom_position*basis_real)

EXP=PAR.EXP;
XTAL.title='Parameters from a particular force-constant calculation.';

%% === determine or set path to calculation file ===
if exist('optional_path')
	optional_path=strtrim(optional_path);
	XTAL.data_path=optional_path;
else
	% assign datapath
	path_string=input(' Please input the path to the ANALYSIS_DATA file: ','s');
	path_string=strtrim(path_string);
	XTAL.data_path=path_string;
end
XTAL.data_path=system_swap_dirchar(XTAL.data_path);


%% === load data ===
calc_method=check_calc_method(XTAL.data_path);
XTAL.calc_method=calc_method;

if calc_method=='phonopy'
	disp(' Initializing XTAL from POSCAR calculation file')
	XTAL=read_POSCAR(XTAL);
	if isempty(XTAL); 
		error(' XTAL is empty, snaxs will crash soon');
		return; 
	end

elseif calc_method=='anapert'
	disp(' Initializing XTAL from ANALYSIS_DATA calculation file')
	% === this provides the correspondance between Rolf's variable names and mine
	XTAL.name=read_ANALYSIS_DATA(XTAL,'structure_name');
	XTAL.N_atom=read_ANALYSIS_DATA(XTAL,'n_atoms');
	XTAL.N_type=read_ANALYSIS_DATA(XTAL,'n_atomkinds');
	XTAL.atom_types=read_ANALYSIS_DATA(XTAL,'kind_name');
	XTAL.atom_position=read_ANALYSIS_DATA(XTAL,'atom_coord');
	XTAL.basis_real=read_ANALYSIS_DATA(XTAL,'bravis_basis');
	XTAL.basis_recip=read_ANALYSIS_DATA(XTAL,'reciprocal_basis');
	XTAL.atom_kind=read_ANALYSIS_DATA(XTAL,'atom_kind');
end


% === basis cross-check ===
% reciprocal basis is transpose of 2pi * inv(basis_real)
check=(2*pi*inv(XTAL.basis_real))';

if ~isclose(check,XTAL.basis_recip,6)
	warning(' XTAL.basis_recip ~= 2*pi*inv(basis_real)'' within tolerance.');
end


%% === get scattering cross-sections for these atoms based on neutron/xray ===
scatt_xsect = [];

switch EXP.experiment_type
	case {'xray'}
		for ind=1:XTAL.N_type;
			new_xsect = get_xsect_xray(XTAL.atom_types{ind});
			scatt_xsect = [scatt_xsect ' ' new_xsect];
		end

	case {'tas'}
		for ind=1:XTAL.N_type;
			new_xsect = get_xsect_neutron(XTAL.atom_types{ind});
			scatt_xsect = [scatt_xsect ' ' new_xsect];
		end

	case {'tof'}
		for ind=1:XTAL.N_type;
			new_xsect = get_xsect_neutron(XTAL.atom_types{ind});
			scatt_xsect = [scatt_xsect ' ' new_xsect];
		end

	otherwise
		error(' Experiment_type unknown');
end

XTAL.scatt_xsect=scatt_xsect;


%% === verify structure, warn if there's a problem
check=0;
if class(XTAL)=='struct'
	check = isfield(XTAL,'N_atom') & isfield(XTAL,'basis_real') & ...
		isfield(XTAL,'atom_types') & isfield(XTAL,'atom_kind') & ...
		isfield(XTAL,'atom_position');
end

if check
	disp('      ... the XTAL structure seems to be OK')
else
	error('      ... there seems to be a problem with the XTAL structure.');
end

XTAL.check=check;
PAR.XTAL=XTAL;

