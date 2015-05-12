function PAR=phonon_scandata_xray(PAR,STRUFAC_data)
% PAR=phonon_scandata_xray(PAR,STRUFAC_data)
% 	Return DATA structure based on PAR
% 	Restricts phonons to just those allowed by user

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
DATA=make_DATA(INFO);

% === set phonon widths ===
if isfield(STRUFAC_data,'widths')
	widths = STRUFAC_data.something;	% this will crash, but is obvious fix
else
	widths = zeros(numrows(STRUFAC_data),1);
end

% === set range to user constraint (no kinematic restriction for x-ray) ===
e_upper = INFO.e_max;
e_lower = INFO.e_min;


% === apply restrictions to phonons ===
centers = STRUFAC_data(:,1);
DATA.allcenters=centers;

good_cens=find((centers > e_lower) & (centers < e_upper));
DATA.centers=centers(good_cens);

allstrufac=NaN*STRUFAC_data;
allstrufac(good_cens,:)=STRUFAC_data(good_cens,:);
structure_factors=STRUFAC_data(good_cens,:);

DATA.allheights = calc_height(allstrufac, PAR);
DATA.heights=DATA.allheights(good_cens);

DATA.linewidths=linewidths(good_cens);

% === make mask (no kinematic constraints for xray) ===
% if Q not accessible, mask is NaN
if calc_Q_ang_cnv(XTAL, INFO.Q, EXP) > EXP.instrument_Qmax;			% 
	DATA.mask = NaN * ones(size(DATA.eng));
else
	DATA=make_mask(DATA,e_upper,e_lower);
end

PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
