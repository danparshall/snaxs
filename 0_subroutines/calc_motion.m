function [DISPLACED,polarization]=calc_motion(PAR,ATOMS,theta,mode_index,mode_data,scale);
% [DISPLACED,polarization]=calc_motion(PAR,ATOMS,theta,mode_index,mode_data,scale);
%	Calculate atomic motion at given theta (i.e., omega*t)
%
% 	In a semi-classical picture, the displacement as a function of time is 
% 	proportional to
% 
% 	 Real( p *exp(-i omega*t))
% 
% 	where p is the polarization vector. A complex p gives a phase shift and 
% 	changes the time where the displacement reaches its maximal amplitude.
% 
% 	There is a difference between the eigenvector e and the polarization 
% 	vector p:
% 
% 	 p = 1/sqrt(M)*exp(i q*R) * e
% 
% 	where M is the mass, R the position of the atom in the unit cell.
% 	p is more directly linked to the amplidue than e, as it contains the 
% 	weighting with 1/sqrt(M).
% 
% 	In anapert, both e and p are normalized in the printout: the sum of |e|^2 
% 	or |p|^2  over all components and atoms in the unit cell is set to 100, so 
% 	the values do not represent physical distances. 

% 	scale for motion.  Total eigenvector=1, so multiply by N_atom

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
if ~exist('scale')
	scale=XTAL.N_atom*PLOT.scale_disp;
end

[tau,q]=calc_tau_q(PAR);
qc=q*XTAL.basis_recip;

DISPLACED=ATOMS;
polarization=zeros(size(ATOMS.atom_type,1),3);

for ind_atom=1:size(ATOMS.atom_type,1);
	atom_mass=get_mass(ATOMS.atom_type{ind_atom});

	this_atom_ind=( (3*ind_atom)-2 : (3*ind_atom) );	% to select xyz components

	this_eig= mode_data(this_atom_ind,1,mode_index);
	this_eig=this_eig(:)';		% now have a complex row-vector

	phaze=exp(i*dot(qc,ATOMS.atom_position(ind_atom,:)));

	this_pol=scale/sqrt(atom_mass)*phaze.*this_eig;
	DISPLACED.atom_position(ind_atom,:)=real(this_pol*exp(i*theta))+ATOMS.atom_position(ind_atom,:);
	polarization(ind_atom,:)=this_pol;
end

