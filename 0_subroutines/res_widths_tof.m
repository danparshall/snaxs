function res_width=res_widths_tof(PAR)
% res_width=res_widths_tof(PAR)
%	Calculate resolution HWHM for TOF.

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

if ~isfield(EXP,'instrument');
	EXP.instrument='ARCS';
end


% === Diverts to appropriate instrument.
if EXP.instrument=='ARCS';
	E_i=PAR.EXP.efixed;
	eng=PAR.DATA.centers;

	%	generate HWHM based on ARCS instrument specs
	L1=11.61;
	L2=1.99;
	L3=3.;	% up to 3.5- check variation

	dL3=0.03;
	dt_mod= 0.0000172;  % parametric source width
	dt_chop=0.0000088; % 8.8 usec (varies depending on chopper freq)

	v_i=calc_eng_to_vel(E_i);
	v_f=calc_eng_to_vel(E_i-eng);

	t_1=L1/v_i;
	V= v_f ./ v_i;

	% Rev Sci Instr uses factor of 2, gives FWHM
	dE_mod =E_i * ( (1+(L2/L3).*V.^3)*(dt_mod/t_1) );
	dE_chop=E_i * ( (1+((L1+L2)/L3).*V.^3)*(dt_chop/t_1));
	dE_L3 = E_i * (dL3/L3).*V.^2;

	res_width = sqrt(dE_mod.^2 + dE_chop.^2 + dE_L3.^2);

elseif EXP.instrument=='MERLIN'
	error(' reswidths calculation not written');

else
	error(' Instrument unknown');
end

