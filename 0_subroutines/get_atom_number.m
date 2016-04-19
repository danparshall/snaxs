function atom_number=get_atom_number(atom_type);
% atom_number=get_atom_number(atom_type);
%	Given atom_type (a string of the atomic symbol), return atom_number (the 
%	number of protons).  Ignores case.
%
%	Has some crude logic in here to strip off isotope notation


atom_list={
    'H'
    'He'
    'Li'
    'Be'
    'B'
    'C'
    'N'
    'O'
    'F'
    'Ne'
    'Na'
    'Mg'
    'Al'
    'Si'
    'P'
    'S'
    'Cl'
    'Ar'
    'K'
    'Ca'
    'Sc'
    'Ti'
    'V'
    'Cr'
    'Mn'
    'Fe'
    'Co'
    'Ni'
    'Cu'
    'Zn'
    'Ga'
    'Ge'
    'As'
    'Se'
    'Br'
    'Kr'
    'Rb'
    'Sr'
    'Y'
    'Zr'
    'Nb'
    'Mo'
    'Tc'
    'Ru'
    'Rh'
    'Pd'
    'Ag'
    'Cd'
    'In'
    'Sn'
    'Sb'
    'Te'
    'I'
    'Xe'
    'Cs'
    'Ba'
    'La'
    'Ce'
    'Pr'
    'Nd'
    'Pm'
    'Sm'
    'Eu'
    'Gd'
    'Tb'
    'Dy'
    'Ho'
    'Er'
    'Tm'
    'Yb'
    'Lu'
    'Hf'
    'Ta'
    'W'
    'Re'
    'Os'
    'Ir'
    'Pt'
    'Au'
    'Hg'
    'Tl'
    'Pb'
    'Bi'
    'Po'
    'At'
    'Rn'
    'Fr'
    'Ra'
    'Ac'
    'Th'
    'Pa'
    'U'
    'Np'
    'Pu'
    'Am'
    'Cm'
    'Bk'
    'Cf'
    'Es'
    'Fm'
    'Md'
    'No'
    'Lr'
    'Rf'
    'Db'
    'Sg'
    'Bh'
    'Hs'
    'Mt'
    'Ds'
    'Rg'
    'Cn'
    'Uut'
    'Uuq'
    'Uup'
    'Uuh'
    'Uus'
    'Uuo'
};


run=1;
while run
	% if first character is a number, strip it
	if ~isempty(str2num(atom_type(1)));
		atom_type=atom_type([2:end]);

	% once first character is no longer a number, proceed
	else
		run=0;
	end
end

atom_number=find(strcmpi(atom_list, atom_type));

if isempty(atom_number)
	error(' The given atom can not be found');
end

