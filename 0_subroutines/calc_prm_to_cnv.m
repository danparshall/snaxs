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

if exist('EXP')
	if isfield(EXP,'basis_user');
		basis_user=EXP.basis_user;
	else
		basis_user=eye(3);
	end
else
	basis_user=eye(3);
end

cnv = prm * basis_user;

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
