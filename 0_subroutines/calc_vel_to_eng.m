function eng=calc_vel_to_eng(vel);
% eng=calc_vel_to_eng(vel);
%	Calculates neutron energy (meV) from velocity (m/s)

eng = 81.82/630.2*(vel./(2*pi))^2;

