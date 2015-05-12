function mom=calc_eng_to_mom(eng);
% MOM=calc_eng_to_mom(ENG);
% 	Calculates neutron momentum (inv Angstroms) from energy (meV)

mom = sqrt(eng/2.072);

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
