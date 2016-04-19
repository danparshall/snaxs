function cnv=calc_prm_to_cnv(XTAL, prm, EXP);
% cnv=calc_prm_to_cnv(XTAL, prm, EXP);
% 	convert primitive unit cell values used by anapert() and phonopy()
% 	into conventional cell values preferred by humans
% 	cnv and prm are Nq x 3 matrices

if size(prm,2) ~= 3;
	error(' Input "prm" must be 3-column');
	cnv=[];
	return;
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

cnv = prm * basis_user;

