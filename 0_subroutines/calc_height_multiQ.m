function height=calc_height_multiQ(PAR, Q_hkl);
% height=calc_height_multiQ(PAR, Q_hkl);
%	Calculates height of phonons based on switches.  Accepts multiQ input
%	Output is N_modes x Nq

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

energy=VECS.energies;
strufac=VECS.strufac;

if size(energy,2) ~= size(Q_hkl,1)
	warning(' Energy should have size(nPhonon x nQ), Q_hkl should have nQ rows')
end


% === Q^2 ===
if INFO.Q_squared;
	[Q_mag, Q_prm]=calc_Q_ang_cnv(XTAL, Q_hkl, EXP);
	Q_mag = Q_mag(:)';
	Q2 = repmat(Q_mag.^2, 3*XTAL.N_atom, 1);			% N_modes x Nq

%% alternate method ( when phonons not same in all Q ):
%	[row, Qind] = ind2sub(size(PAR.VECS.energies), good_cens);
%	Q=calc_Q_ang_cnv(XTAL, PAR.VECS.Q_points(Qind,:), EXP);
%	Q2=Q.^2;

else
	Q2 = ones(size(energy));
end


% === bose factor ===
if INFO.bose;
	bose =calc_bose(energy, INFO.degrees, INFO.bragg_handling);

	% one_ovr_omega only allowed if gamma-points have already been handled
	if INFO.one_ovr_omega
		bose= bose ./ energy;
	end

else
	bose = ones(size(energy));
end


% === Ki/Kf ===
% skip for x-ray (where the factor is 1) or tas (included in ResLib)
if strcmp(EXP.experiment_type,'xray') || strcmp(EXP.experiment_type,'tas')
	INFO.kfki=0;
end

if INFO.kfki==1;
	if EXP.infin==-1 % fixed E_i
		Kf_array=calc_eng_to_mom(EXP.efixed-energy);
		KfKi=Kf_array./calc_eng_to_mom(EXP.efixed);

	else 			% fixed E_f
		Ki_array=calc_eng_to_mom(energy+EXP.efixed);
		KfKi=calc_eng_to_mom(EXP.efixed)./Ki_array;
	end
else
	KfKi = ones(size(energy));
end


% XTAL.N_atom normalizes so that, e.g., orth/tet calcs yield same intensity
height = strufac .* Q2 .* bose .* KfKi ./ XTAL.N_atom;


