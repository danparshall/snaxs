function display_atom_positions(PAR)
% display_atom_positions(PAR)

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

disp('=== Primitive cell atoms & coordinates ===');
disp(' ');

% === makes 'atom_type' vector ===
type=cell(XTAL.N_atom,1);
for ind=1:XTAL.N_atom
	type{ind}=XTAL.atom_types{XTAL.atom_kind(ind)};
end

% === determine atom positions ===
unit_cell_pos=calc_atom_pos_frac(PAR);

for ind_atom=1:size(unit_cell_pos,1)
	this_atom=unit_cell_pos(ind_atom,:);

	coord_str=sprintf('%2.3f, %2.3f, %2.3f', this_atom);

	if length(type{ind_atom})==2
		type_str = type{ind_atom};
	elseif length(type{ind_atom})==1
		type_str = [' ' type{ind_atom}];
	else
		error(' Atom type string not formatted correctly.');
		type_str = type{ind_atom};
	end

	disp([ '      ' type_str '  ' coord_str])
end
disp(' ');

