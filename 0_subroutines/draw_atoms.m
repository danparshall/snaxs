function atom_handles=draw_atoms(PAR,atom_position,atom_type);
% atom_handles=draw_atoms(PAR,atom_position,atom_type);
%	Create drawing of a given set of atoms.
%	atom_position is a (N_atom x 3) matrix
%	atom_type is a (N_atom x 1) cell array; sets properties of radius and color

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

N_atoms=size(atom_position,1);
r_array=zeros(N_atoms,1);
color_array=zeros(N_atoms,3);

for ind=1:N_atoms %length(atom_type);
	[r_array(ind),color_array(ind,:)]=get_drawing_species_data(atom_type{ind});
end

r_array= r_array * PLOT.scale_atom;

atom_handles = bubbleplot3( atom_position(:,1), atom_position(:,2), ...
								atom_position(:,3), r_array, color_array );

