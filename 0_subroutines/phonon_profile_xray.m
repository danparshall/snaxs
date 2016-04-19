function PAR=phonon_profile_xray(PAR,res_widths);
% PAR=phonon_profile_xray(PAR,res_widths);
%	Calculate intensity profile for a single phonon
%	Selects function, uses res_width, calculates

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

% make matrix with dimensions (N_phonon, energy_bins)
N_phonon = length(DATA.centers);


% x-ray resolution function is lorentzian, so add widths linearly
DATA.linewidths= DATA.ph_widths + res_widths;


% === calculate profile for this set of phonons ===
if DATA.linewidths < INFO.e_step 	% Lorentzian if width too small
	allphonons = calc_lorentz(DATA.eng, DATA.centers, DATA.heights, res_widths);

										% Voigt if turned on & width finite
elseif (DATA.linewidths > INFO.e_step) & (INFO.voigt == 1);
	allphonons = calc_voigt(DATA.eng, DATA.centers, DATA.heights, DATA.linewidths, res_widths);
disp(' using Voigt')

else									% else use pseudo-Voigt
	allphonons = calc_pvoigt(DATA.eng, DATA.centers, DATA.heights, DATA.linewidths, res_widths);
end

DATA.int = sum(allphonons,2);
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);

