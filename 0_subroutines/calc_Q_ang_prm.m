function Q_mag=calc_Q_ang_prm(XTAL, Q_prm);
% Q_mag=calc_Q_ang_prm(XTAL, Q_prm);
% 	Convert Q expressed in primitive cell coordinates into inverse angstroms.
%	Q_prm should be Nx3. Q_mag is Nx1 vector.
%	Because this routine converts to Cartesian coordinates, it should apply for 
%	non-orthogonal systems.
%	This subroutine uses the Angstrom/ A.U. conversion

if size(Q_prm,2)~=3
	error(' Input "Q_prm" must be 3-column');
end

direction = Q_prm * XTAL.basis_recip;
Q_mag = sqrt( sum(direction.^2,2) );

if strcmp(XTAL.calc_method,'anapert');
	Q_mag = Q_mag/0.529177;	% correction for atomic units vs angstroms
end

