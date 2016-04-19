function atom_handles=draw_phonon_frame(PAR,theta,mode_index)
% atom_handles=draw_phonon(PAR,theta,mode_index)
%	Draws the atoms from a particular phonon mode with the phase set by theta.
%	The calculation of the atomic positions is done within "calc_motion", but 
%	the drawing is done here.


ind_q=1;
eigvec=PAR.VECS.vecs(:,ind_q,:);  % rows are dir / pages are mode
[ATOMS,expabs]=make_SUPERCELL(PAR);
mode_data=repmat( eigvec, prod(expabs), 1);


%% === calculate displaced atomic positions for this frame ===
DISPLACED=calc_motion(PAR,ATOMS,theta,mode_index,mode_data);
pos=DISPLACED.atom_position;
type=DISPLACED.atom_type;


%% === draw atoms ===
N_atoms=size(pos,1);
r_array=zeros(N_atoms,1);
color_array=zeros(N_atoms,3);

for ind=1:N_atoms
	[r_array(ind),color_array(ind,:)]=get_drawing_species_data(type{ind});
end

r_array= r_array * PAR.PLOT.scale_atom;
atom_handles = bubbleplot3( pos(:,1), pos(:,2), pos(:,3), r_array, color_array );


%% === adjust lighting ===
if ~system_octave
	camlight('headlight');
	camlight(180,60);
	camlight(180,-60);
	%set(atom_handles,'interp', 'FaceLighting', 'gouraud');
end

