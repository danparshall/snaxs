function Qmax=calc_Qmax(PAR);
% Qmax=calc_Qmax(PAR);
%	Calculates maximum Q (inv Angstroms) obtainable with this range of energy.
%	Depends only on fixed energy (initial or final) and energy range of interest
%	which was set by the user.

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

if ~isfield(EXP, 'infin')
	mode = 1;
else
	mode = EXP.infin;
end

edge=.005; % included to avoid numerical issues near edge of scattering triangle

% === make calculation ===
if mode== 1;	% fixed final energy (mode = 1)
	k_i_max = calc_eng_to_mom(EXP.efixed + INFO.e_max);
	Qmax = k_i_max - calc_eng_to_mom(EXP.efixed) - edge;

elseif mode== -1;	% fixed incident energy (mode = -1)
	k_f_max =  calc_eng_to_mom(EXP.efixed - INFO.e_min);
	Qmax = k_f_max + calc_eng_to_mom(EXP.efixed);


else % error handling 
	error(' Which energy is fixed?');
end

if Qmax < 0;
	error(' Qmax is negative');
end

