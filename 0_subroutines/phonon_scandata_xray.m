function PAR=phonon_scandata_xray(PAR)
% PAR=phonon_scandata_xray(PAR)
% 	Return DATA structure based on PAR
% 	Restricts phonons to just those allowed by user

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);


% === set range to user constraint (no kinematic restriction for x-ray) ===
e_upper = INFO.e_max;
e_lower = INFO.e_min;

[Q_mag, Q_prm]=calc_Q_ang_cnv(XTAL, INFO.Q, EXP);
if Q_mag > EXP.instrument_Qmax
	warning off backtrace
	warning(' Q not accessible on this instrument');
	warning on backtrace
end


%% === apply restrictions to phonons ===
good_cens=find((VECS.energies > e_lower) & (VECS.energies < e_upper));
DATA.heights = calc_height(PAR, good_cens);

DATA.allheights = NaN * VECS.strufac;
DATA.allheights(good_cens) = DATA.heights;

DATA.allcenters = VECS.energies;
DATA.centers = VECS.energies(good_cens);

DATA=make_mask(DATA,e_upper,e_lower);


% === set phonon widths ===
if isfield(VECS,'phWidths')
	DATA.ph_widths = VECS.phWidths(good_cens);
else
	warning(' Setting intrinsic linewidth to zero.');
	DATA.ph_widths = zeros(size(DATA.centers));
end


% === make mask (no kinematic constraints for xray) ===

% if Q not accessible, mask is NaN
if calc_Q_ang_cnv(XTAL, INFO.Q, EXP) > EXP.instrument_Qmax;			% 
	DATA.mask = NaN * ones(size(DATA.eng));
else
	DATA=make_mask(DATA,e_upper,e_lower);
end

PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);

