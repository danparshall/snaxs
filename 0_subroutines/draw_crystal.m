function SUPER=draw_crystal(PAR,expansion)
% draw_crystal(PAR,expansion)
%	draws crystal in undisplaced state.  
%	Could also use "draw_phonon" with theta = 0, mode = 1 (or any)

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

cab;
SUPER=make_SUPERCELL(PAR,expansion);
draw_atoms(PAR,SUPER.atom_position,SUPER.atom_type);

% adjust lighting
if ~system_octave
	camlight('headlight');
	camlight(180,60);
	camlight(180,-60);
	%camlight(0,-90);
end

