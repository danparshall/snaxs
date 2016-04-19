function display_current_data(PAR)
% display_current_data(PAR)
%	prints data from all structures to the screen

	disp(' ')
	disp(' NOTE in "display_current_data" : working on user info option')
	disp('  These are your current settings:');

	disp(' EXP:')
	disp(PAR.EXP);
	disp(' ')

	disp(' XTAL:')
	disp(PAR.XTAL)
	disp(' ')

	disp(' INFO:')
	disp(PAR.INFO)
	disp(' ')

	disp(' PLOT:')
	disp(PAR.PLOT)
	disp(' ')

	disp(' DATA:')
	disp(PAR.DATA)
	disp(' ')

	disp(' VECS:')
	disp(PAR.VECS)
	disp(' ')

	display_atom_pos(PAR);
	draw_crystal(PAR,PAR.PLOT.expansion);

