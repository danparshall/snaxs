function frac_positions=calc_atom_pos_frac(PAR);
% atom_positions=calc_atom_positions(PAR);
%	Given the data from XTAL and EXP, returns the location of the atoms in
%	the user's basis, in fractions of a unit cell

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
frac_positions = XTAL.atom_position * inv(EXP.basis_user)';

