function PAR=phonon_profile_tas(PAR,res_widths);
% PAR=phonon_profile_tas(PAR,res_widths);
%	Calculate intensity profile for a single Q
%	Selects function, uses res_widths, calculates

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

% make matrix with dimensions (N_phonon, energy_bins)
N_phonon = length(DATA.centers);


DATA.linewidths= sqrt(DATA.ph_widths + res_widths);	% Gaussian; add widths in quadrature
%DATA.linewidths= DATA.ph_widths;						% or not...


% === calculate profile for this set of phonons ===
									% Voigt if turned on & width finite
if (DATA.linewidths > INFO.e_step) & (INFO.voigt == 1);
	allphonons = calc_voigt(DATA.eng, DATA.centers, DATA.heights, DATA.linewidths, res_widths);

else									% else use pseudo-Voigt
	allphonons = calc_pvoigt(DATA.eng, DATA.centers, DATA.heights, DATA.linewidths, res_widths);
end

DATA.int = sum(allphonons,2);

PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);

