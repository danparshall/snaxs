function res_widths=res_widths_xray(PAR);
% res_widths=res_widths_xray(PAR);
%	Since x-ray resolution is constant with energy, read EXP file for width, 
%	return array with length equal to number of phonons.
%	

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

if isfield(EXP,'xray_res')
	HWHM=EXP.xray_res;
else
	disp(' NOTE: No value given for EXP.xray_res, using default HWHM of 1.5 meV')	
	HWHM = 1.5;
end

res_widths=HWHM*ones(size(DATA.centers));

