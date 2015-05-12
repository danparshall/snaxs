function PAR=phonon_scandata_neutron(PAR, STRUFAC_data);
% PAR=phonon_scandata_neutron(PAR, STRUFAC_data);
%	Return DATA structure based on PAR
%	Restricts phonons to just those allowed (whether by kinematics or user)

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

% === set phonon widths ===
if isfield(STRUFAC_data,'ph_widths')
	ph_widths = STRUFAC_data.something;	% this will crash, but is obvious fix
else
	ph_widths = zeros(size(STRUFAC_data,1),1);
end


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
centers = STRUFAC_data(:,1);
DATA.allcenters=centers;
good_cens=find((centers > e_lower) & (centers < e_upper));
DATA.centers=centers(good_cens);

allstrufac=NaN*STRUFAC_data;
allstrufac(good_cens,:)=STRUFAC_data(good_cens,:);
structure_factors=STRUFAC_data(good_cens,:);

DATA.allheights = calc_height(allstrufac, PAR);
allhts=DATA.allheights;
DATA.heights=DATA.allheights(good_cens);
DATA.ph_widths=ph_widths(good_cens);

DATA=make_mask(DATA,e_upper,e_lower);
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
