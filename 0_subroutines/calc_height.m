function height=calc_height(STRUFAC_data, PAR);
% height=calc_height(STRUFAC_data, PAR);
%	Calculates height of phonons based on switches
%	STRUFAC_data is (N_modes x 2) array (eng, strufac)
%	should update this to use VECS.energies and STRUFAC.strufac
%	calc_height_multiQ may work, but will have to see where this gets passed in from

[XTAL,EXP,INFO]=params_fetch(PAR);
energy=STRUFAC_data(:,1);

% === Q^2 ===
if INFO.Q_squared;
	Q=calc_Q_ang_cnv(XTAL, INFO.Q, EXP);
	Q2=Q^2;
else
	Q2 = 1;
end

% === bose factor ===
if INFO.bose;
	bose = calc_bose(STRUFAC_data(:,1), INFO.degrees, INFO.bragg_handling);

	% one_ovr_omega only allowed if gamma-points have already been handled
	if INFO.one_ovr_omega
		bose= bose./energy;
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
	else % fixed E_f
		Ki_array=calc_eng_to_mom(energy+EXP.efixed);
		KfKi=calc_eng_to_mom(EXP.efixed)./Ki_array;
	end
else
	KfKi=ones(size(energy));
end


% XTAL.N_atom normalizes so that, e.g., orth/tet calcs yield same intensity
height = STRUFAC_data(:,2) .* Q2 .* bose .* KfKi ./ XTAL.N_atom;

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
