function PAR=phonon_scandata_neutron(PAR);
% PAR=phonon_scandata_neutron(PAR);
%	Return DATA structure based on PAR
%	Restricts phonons to just those allowed (whether by kinematics or user)

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);


%% === set range to narrower of kinematic or user constraint ===
[E_trans_max, E_trans_min]=check_kinematics(PAR);
if INFO.e_min > E_trans_min
	e_lower = INFO.e_min;
else
	e_lower = E_trans_min;
end

if INFO.e_max < E_trans_max
	e_upper = INFO.e_max;
else
	e_upper = E_trans_max;
end


% === this is an ugly hack to keep the max/min values from being masked ===
%		there's a chance it could break things
step=INFO.e_step;
e_upper=e_upper+(step/10);
e_lower=e_lower-(step/10);
% ===


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

PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);

