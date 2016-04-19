function vel=calc_eng_to_vel(eng);
% vel=calc_eng_to_vel(eng);
% 	Calculates neutron velocity (m/s) from energy (meV)

vel = 630.2*2*pi*sqrt(eng/81.82);

