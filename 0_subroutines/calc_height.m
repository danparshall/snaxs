function height=calc_height(PAR, good_cens);
% height=calc_height(PAR, good_cens);
%	Calculates height of phonons based on switches
%	calc_height_multiQ may work, but will have to see where this gets passed in from
% 	This *should* work 

if ~exist('good_cens');
	good_cens= [1:numel(PAR.VECS.energies)];
end

[XTAL,EXP,INFO]=params_fetch(PAR);
energy=PAR.VECS.energies(good_cens);
strufac=PAR.VECS.strufac(good_cens);

% === Q^2 ===
if INFO.Q_squared;
%	[row, Qind] = ind2sub(size(PAR.VECS.energies), good_cens);
	Q=calc_Q_ang_cnv(XTAL, PAR.INFO.Q, EXP);
	Q2=Q.^2;
else
	Q2 = 1;
end


% === bose factor ===
if INFO.bose;
	bose = calc_bose(energy, INFO.degrees, INFO.bragg_handling);

	% one_ovr_omega only allowed if gamma-points have already been handled
	if INFO.one_ovr_omega

		for iEng = 1:length(energy)
			if energy(iEng)~=0
				bose(iEng) = bose(iEng)./energy(iEng);
			end
		end
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

% XTAL.N_atom normalizes so supercell calcs give same intensity (e.g., ortho/tet)
height = strufac .* Q2 .* bose .* KfKi ./ XTAL.N_atom;

