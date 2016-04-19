function DATA=make_mask(DATA,e_upper,e_lower)
% DATA=make_mask(DATA,e_upper,e_lower)
% 	Make mask based on upper/lower energy bounds set by either user or kinematics
% 	Mask has values either 1 or NaN.

mask_hi = DATA.eng < e_upper;
mask_lo = DATA.eng > e_lower;
DATA.mask = mask_hi .* mask_lo;

DATA.mask(DATA.mask==0) = NaN;

