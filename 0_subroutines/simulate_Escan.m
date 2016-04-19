function PAR=simulate_Escan(PAR);
% PAR=simulate_Escan(PAR);
% 	Simulate escan at single Q-point
%	strufac_data is (N_modes x 2) (energies/intensities)
%
%	For each scan:
% 		List of phonon centers, intensities, widths
%		Resolution width at each phonon center
%		Calculate profile for each phonon, sum, apply mask to non-kinematic area


PAR.DATA=make_DATA(PAR);
[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

% === Switch for tas, tof, xray ===
switch PAR.EXP.experiment_type
	case {'xray'} % ===============
		if PAR.INFO.warn_exp_type==1
			disp(' This seems to be an x-ray experiment')
			PAR.INFO.warn_exp_type=0;
		end
		PAR=phonon_scandata_xray(PAR);
		res_widths=res_widths_xray(PAR);
		PAR=phonon_profile_xray(PAR,res_widths);


	case {'tof'} % =================
		if PAR.INFO.warn_exp_type==1
			disp(' This seems to be a time-of-flight experiment');
			PAR.INFO.warn_exp_type=0;
		end

		PAR=phonon_scandata_neutron(PAR);
		res_widths=res_widths_tof(PAR);
		PAR=phonon_profile_tas(PAR,res_widths);


	case {'tas'} % =================
		if PAR.INFO.warn_exp_type==1
			disp(' This seems to be a triple-axis experiment');
			PAR.INFO.warn_exp_type=0;
		end
		PAR=phonon_scandata_neutron(PAR);

		if length(PAR.DATA.centers) > 0;
			[res_widths,PAR]=res_widths_tas(PAR);
			PAR=phonon_profile_tas(PAR,res_widths);
		end

	otherwise
		error(' EXP.experiment_type unknown.')
		return
end

% === only apply mask if it's been created ===
if isfield(PAR.DATA,'mask');
	PAR.DATA.int = PAR.DATA.int .* PAR.DATA.mask;
end

% INFO flags may have been updated, DATA was updated in subroutines
INFO=PAR.INFO;
DATA=PAR.DATA;
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);

