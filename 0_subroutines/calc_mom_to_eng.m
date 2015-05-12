function eng=calc_mom_to_eng(mom);
% eng=calc_mom_to_eng(mom);
%	Calculates neutron energy (meV) from momentum (inv Angstroms)

eng = 2.072 * mom.^2;

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
