function PAR=simulate_SQW(PAR);
% PAR=simulate_SQW(PAR);
%	Calculates and constructs a slice of S(q,w).  This entire slice can be shown
%	to the user (as in, e.g., "user_SQW_menu"), or just a line scan can be 
%	shown (as in "user_Qscan_menu").

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

if isfield(XTAL,'calc_method')
	calc=XTAL.calc_method;
else
	error(' Calculation method known');
end

% === initialize arrays, index variables ===
[unique_tau, cellarray_qs, Q_hkl, Q_delta]=generate_tau_q_from_Q(PAR);
e_array= [INFO.e_min : INFO.e_step : INFO.e_max];
SQE_array=zeros( length(e_array), INFO.Q_npts);


% === generate VECS (including structure factor) ===
PAR=simulate_multiQ(PAR, Q_hkl);
[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);


% === now calculate intensities based on VECS.strufac ===
if 0

	for k=1:size(VECS.Q_points,1)

		PAR.INFO.Q=Q_hkl(k,:);
		PAR.VECS.strufac = VECS.strufac(:,k);
		PAR.VECS.energies = VECS.energies(:,k);
		PAR=simulate_Escan(PAR);
		SQE_array(:,k)=PAR.DATA.int;

		if ~isreal(PAR.DATA.int)
			warning(['Imaginary data at index k=' num2str(k)]);
		end
	end

else

	% I should put something here, but it will mean tearing apart some of the
	% subroutines within "simulate_Escan".  Going to punt till a later date.
	%
	% For large unit cells, the bulk of the time is spent in anapert/phonopy,
	% so speeding this up by removing the for loop is a marginal improvement.
	%
	% Most of the subroutines could handle multiple Q at the same time.  The
	% bottleneck is calculating intensity profiles.  Could possibly speed it up
	% by transforming to a 3D array and summing the intensities along the third
	% direction.  But that would mean doing some indexing to avoid calculating
	% lots of exponentials, which might not be faster than the FOR loop here.
	%
	% Should switch to using "calc_height_multiQ" within "simulate_multiQ"; all
	% those could then go into DATA.allheights (DATA.allcenters should be an
	% expansion of VECS.energies).  Then do check_kinematics, and build a mask 
	% based on that (this is largely what happens in phonon_scandata_neutron).
	% Use mask and make things NaN if masked.  Then pass only allowed (good) cen
	% good_cens = intersect(find(tst), find(~isnan(tst)))
	% 
	warning(' Running the TEST VERSION of simulate_SQW : toggle line29 for stable version');


	% update : the indexing seems to be accurate, and is around 30% faster than 
	% the stable version above (call time to phonopy is unchanged, obviously).
	% Need to set this up for xray and tas.  Should probably move "make_STRUFAC"
	% from simulate_multiQ and have it called separately when needed (that will
	% speed up calls to display dispersion, etc.  

	% Xray will require Lorentzian an option, and skipping check_kinematics
	% TAS will require calling ResLib


	nHt = 3*XTAL.N_atom;
	nQ = INFO.Q_npts;
	DATA = make_DATA(PAR);

	%% calculate heights for all phonons, at all Q 
	% (even kinematically inaccessible, but that shouldn't make much diffence)
	ht = calc_height_multiQ(PAR, Q_hkl);
	DATA.allheights = ht;


	%% make kinematic mask
	cen = VECS.energies;

	if 1
		% NEUTRONS - works for TOF, but need to use ResLib for TAS
		[EtMax, EtMin] = check_kinematics(PAR, Q_hkl);
		tMax = repmat(EtMax(:)', nHt, 1);
		tMin = repmat(EtMin(:)', nHt, 1);
		kMask = (cen < tMax) & (cen > tMin) & (cen < INFO.e_max) & (cen > INFO.e_min);
	else
		% XRAYS - need work!
		kMask = (cen < INFO.e_max) & (cen > INFO.e_min);
		kMask Q-mag
		[Q_mag, Q_prm]=calc_Q_ang_cnv(XTAL, INFO.Q, EXP);
		if Q_mag > EXP.instrument_Qmax; end
	end

	%% get resolution width based upon energy (and evenutally, HKL)
	goodCens = logical( (ht>0) .* ~isnan(ht) .* kMask );	% marks good phonons at each Q
	DATA.centers = VECS.energies(goodCens);
	DATA.heights = DATA.allheights(goodCens);
	PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);
	res_width=res_widths_tof(PAR);
	H = repmat(Q_hkl(:,1), 1, nHt);
	K = repmat(Q_hkl(:,2), 1, nHt);
	L = repmat(Q_hkl(:,3), 1, nHt);


	%% calculate intensity profile for every individual phonon
	eng = DATA.eng;
	width = zeros(size(DATA.centers));
	pVoigt = calc_pvoigt( eng, DATA.centers, DATA.heights, 0, res_width); % length(eng) x length(find(goodCens))


	%% sum intensity profiles for different phonons at the same HKL/Q
	iCens = find(goodCens);
	for iq = 1:nQ

		% figure out indices for good phonons at this particular Q
		tmp = find(goodCens(:, iq));										% goodCens at this Q
		thisCens = sub2ind( size(goodCens), tmp, iq*ones(size(tmp)) );		% linear indices
		[dummy, ind] = intersect( iCens, thisCens );						% ind is correct columns *of pVoigt*

		% sum their profiles
		profile = sum(pVoigt(:,ind), 2);
		SQE_array(:,iq) = profile;
	end

end


% === make sure some values have been calculated ===
SQE_check=SQE_array;
SQE_check(isnan(SQE_check)) = 0 ;


if sum(sum(SQE_check))==0;
	warning off backtrace
	warning(' No accessible phonons in the range of S(Q,w) that you selected');
	warning on backtrace
end


% === update ===
DATA.SQE_array=SQE_array;
DATA.Q_hkl=Q_hkl;
DATA.E_array=e_array;
DATA.Q_delta=Q_delta;
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);
toc;

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
