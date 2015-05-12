function PAR=phonon_profile_xray(PAR,res_widths);
% PAR=phonon_profile_xray(PAR,res_widths);
%	Calculate intensity profile for a single phonon
%	Selects function, uses res_width, calculates

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

% make matrix with dimensions (N_phonon, energy_bins)
N_phonon = length(DATA.centers);
intensity=zeros(N_phonon,length(DATA.eng));

% x-ray resolution function is lorentzian, so add widths linearly
DATA.linewidths= DATA.ph_widths + res_widths;

for i=1:N_phonon;

	% === calculate profile for this phonon ===
	if DATA.linewidths(i) < INFO.e_step 	% Lorentzian if width too small
		current = calc_lorentz(DATA.eng, DATA.centers(i), ...
				DATA.heights(i), res_widths(i));

											% Voigt if turned on & width finite
	elseif (DATA.linewidths(i) > INFO.e_step) & (INFO.voigt == 1);
		current = calc_voigt(DATA.eng, DATA.centers(i), ...
				DATA.heights(i), DATA.linewidths(i), res_widths(i));
disp(' using Voigt')

	else									% else use pseudo-Voigt
		current = calc_pvoigt(DATA.eng, DATA.centers(i), ...
				DATA.heights(i), DATA.linewidths(i), res_widths(i), INFO.e_step);
	end

	% === put this phonon into intensity array ===
	intensity(i,:)=current;
end

DATA.int=sum(intensity,1)';		% sum col and transp to produce row vector
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
