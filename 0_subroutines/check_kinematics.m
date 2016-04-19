function [E_trans_max, E_trans_min]=check_kinematics(PAR,Qhkl);
% [E_trans_max, E_trans_min]=check_kinematics(PAR);
%	Checks what range of energy transfer is allowed at this Q
%	Note that ResLib uses EXP.infin=-1 for fixed Ef (ResLib documentation is in
%	error, claims +1 in fixed Ef)

[XTAL,EXP,INFO]=params_fetch(PAR);

if ~exist('Qhkl','var');
	Q_mag=calc_Q_sample(XTAL, INFO.Q, EXP);
else
	Q_mag=calc_Q_ang_cnv(XTAL, Qhkl, EXP);
end

edge=.1;  % included to avoid numerical issues near edge of scattering triangle

% === fixed final energy (infin = -1) ===
if EXP.infin==-1;
	k_f = calc_eng_to_mom(EXP.efixed);

	k_i_max = k_f + Q_mag;
	k_i_min = k_f - Q_mag;

	E_i_max = calc_mom_to_eng(k_i_max);
	E_i_min = calc_mom_to_eng(k_i_min);

	E_trans_max = E_i_max - EXP.efixed - edge;
	E_trans_min = E_i_min - EXP.efixed + edge;


% === fixed incident energy (infin = 1) ===
elseif EXP.infin==1;
	k_i = calc_eng_to_mom(EXP.efixed);

	if Q_mag < k_i;
		k_f_max = k_i - Q_mag;
	else
		k_f_max = Q_mag - k_i;
	end

	E_f_max = calc_mom_to_eng(k_f_max);
	E_trans_max = EXP.efixed - E_f_max - edge;

	k_f_min = k_i + Q_mag;
	E_f_min = calc_mom_to_eng(k_f_min);
	E_trans_min = EXP.efixed - E_f_min + edge;


% === error handling ===
else
	error(' Which energy is fixed?');
end

