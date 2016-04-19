function DISPLACED=calc_phonon_frame(PAR,theta,mode_index)
% DISPLACED=calc_phonon_frame(PAR,theta,mode_index)
%	calculates atomic positions for a particular phonon mode and theta

ind_q=1;

eigvec=PAR.VECS.vecs(:,ind_q,:);  % rows are dir / pages are mode

mode_list=[real(eigvec) imag(eigvec)];

[ATOMS,expabs]=make_SUPERCELL(PAR);
mode_data=repmat( mode_list, prod(expabs), 1);

% === calculate displaced atomic positions for this frame ===
DISPLACED=calc_motion(PAR,ATOMS,theta,mode_index,mode_data);
DISPLACED.pos=DISPLACED.atom_position-ATOMS.atom_position;

pos=DISPLACED.atom_position;
type=DISPLACED.atom_type;

