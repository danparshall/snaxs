function PAR=simulate_SQW(PAR,Q_hkl);
% PAR=simulate_SQW(PAR);
%	Calculates and constructs a slice of S(q,w).  This entire slice can be shown
%	to the user (as in, e.g., "user_SQW_menu"), or just a line scan can be 
%	shown (as in "user_Qscan_menu").

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
DATA = make_DATA(PAR);

if isfield(XTAL,'calc_method')
	calc=XTAL.calc_method;
else
	error(' Calculation method known');
end

% === initialize arrays, index variables ===
if ~exist('Q_hkl')
	[unique_tau, cellarray_qs, Q_hkl, Q_delta]=generate_tau_q_from_Q(PAR);
	DATA.Q_delta=Q_delta;
else
	INFO.Q_npts = size(Q_hkl,1);
	[unique_tau, cellarray_qs, Q_hkl, Q_delta]=generate_tau_q_from_Q(PAR,Q_hkl);
	DATA.Q_delta=Q_delta;
end	
eng = DATA.eng;
SQE_array=zeros( length(eng), INFO.Q_npts);


% === generate VECS (including structure factor) ===
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);
PAR=simulate_multiQ(PAR, Q_hkl);
[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);


tic;
% === now calculate intensities based on VECS.strufac ===
if 1		%% === stable version ===

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

	% these two lines are probably redundant/a bug
%	DATA = make_DATA(PAR);
%	DATA.Q_delta=Q_delta;
else		%% === experimental version! ===

	warning(' Running the TEST VERSION of simulate_SQW : toggle line29 for stable version');

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


	% update 2015/12/16: I have implemented the scheme described above in this
	% section.  The indexing seems to be accurate, and is around 30% faster than 
	% the stable version (call time to phonopy is unchanged, obviously).

	% Considered moving "make_STRUFAC" from "simulate_multiQ" and have it called 
	% only when needed (thinking it would speed calls to plot_dispersion, etc),
	% but the total time for 200 unique q-points of MgB2 was only 10ms... 

	% TODO:
	% Xray will require Lorentzian an option, and skipping check_kinematics
	% TAS will require calling ResLib

	% need to change simulate_Escan to follow this method (minus fancy indexing)
	% need to adjust sqwphonon.m to be sure the updated versions are compatible

	% Once these are implemented, can get rid of:
	%	phonon_scandata_xray
	%	phonon_scandata_neutron
	%	phonon_profile_xray
	%	phonon_profile_neutron

	% currently, "generate_q_tau_from_Q" copies over Q_hkl.  This is a bug which
	% hasn't bit me so far.  But it should be removed, and Q_hkl should be 
	% generated just once (probably in user_menu_SQW).


	nHt = 3*XTAL.N_atom;
	nQ = INFO.Q_npts;
	DATA = make_DATA(PAR);

	%% calculate heights for all phonons, at all Q 
	% (even kinematically inaccessible, but that shouldn't make much diffence)
	ht = calc_height_multiQ(PAR, Q_hkl);
	DATA.allheights = ht;


	%% === make kinematic mask ===
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
%		kMask Q-mag
		[Q_mag, Q_prm]=calc_Q_ang_cnv(XTAL, INFO.Q, EXP);
		if Q_mag > EXP.instrument_Qmax; end
	end


	%% === get resolution width based upon energy (and evenutally, HKL) ===
	goodCens = logical( (ht>0) .* ~isnan(ht) .* kMask );	% marks good phonons at each Q
	DATA.centers = VECS.energies(goodCens);
	DATA.heights = DATA.allheights(goodCens);
	PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);
	res_width=res_widths_tof(PAR);
	H = repmat(Q_hkl(:,1), 1, nHt);
	K = repmat(Q_hkl(:,2), 1, nHt);
	L = repmat(Q_hkl(:,3), 1, nHt);


	%% === calculate intensity profile for every individual phonon ===
	eng = DATA.eng;
	width = zeros(size(DATA.centers));
	pVoigt = calc_pvoigt( eng, DATA.centers, DATA.heights, 0, res_width); % length(eng) x length(find(goodCens))


	%% === sum intensity profiles for different phonons at the same HKL/Q ===
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
DATA.Q_delta=Q_delta;
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);
toc;

