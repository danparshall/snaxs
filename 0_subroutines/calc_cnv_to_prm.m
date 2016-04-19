function prm=calc_cnv_to_prm(XTAL, cnv, EXP);
% prm=calc_cnv_to_prm(XTAL, cnv, EXP);
%	convert convential unit cell values into primitive unit cell values
%	needed for anapert() or phonopy()
% 	cnv and prm are Nx3 matrices, where N is number of Q-points

if size(cnv,2) ~= 3;
	error(' Input "cnv" must be 3-column');
	prm=[];
	return
end

basis_user=[];
if exist('EXP')
	if isfield(EXP,'basis_user');
		basis_user=EXP.basis_user;
	end
end

if isempty(basis_user)
	basis_user=eye(3);
end

prm = cnv * inv(basis_user);

