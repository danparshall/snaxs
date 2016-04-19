function mom=calc_eng_to_mom(eng);
% MOM=calc_eng_to_mom(ENG);
% 	Calculates neutron momentum (inv Angstroms) from energy (meV)

mom = sqrt(eng/2.072);

