function EXP=demoEXP_xray
%===============================================================================
% function EXP=demoEXP_xray
% adaption from ResLib. Q-resolution is not considered, so only need to indicate
% the parameters listed in this file.
%
%	Required:
%		experiment_type='xray'
%		xray_res=
%		instrument_Qmax=
%		sample.a/b/c
%
%	Optional:
%		basis_user			% can switch between various bases
%		calculation_path	% if provided, SNAXS will load this automatically
%===============================================================================

% === for inelastic x-ray scattering (IXS), very little information is needed ===
EXP.experiment_type = 'xray';		% if not specified, SNAXS defaults to 'tas'


EXP.xray_res = 1.5;					% HWHM of Lorentzian resolution function
% hwhm depends on analyzer reflection.  Typically the best value is 0.75 meV,
% and some instruments have higher-flux settings with broader resolution


EXP.instrument_Qmax = 7.5;			% Max Q in inverse Angstrom
% typical Q_max (depends mostly on maximum two-theta): 
%	3.4 for Sector 3 HERIX (APS)
%	7.5 for Sector 30 HERIX (APS)
%	10 for ID28 (ESRF)
%	10 for BL35XU (SPring-8)


% Space group P6/mmm, #191.  No HKL conditions.
EXP.calculation_path='ANALYSIS_DATA.mgb2_q666';

% === if desired, user can select between multiple calculations and/or basis ===
coordinates='orth';	% use 'orth' or 'hex'
inplane=  3.091;	% 3.091 is experimental, 3.05573 is anapert
outofplane=3.529;

switch(coordinates)
	% hexagonal
	case 'hex'

		disp(' Using hexagonal basis')
		%-------------------------   Sample -------------------
		% MgB2 is hexagonal, so only values of a & c must be specified

		EXP.sample.a=  inplane;		%A: angstroms
		EXP.sample.c=  outofplane;		%C: angstroms

		EXP.sample.alpha=90;    %Alpha: degrees of arc
		EXP.sample.beta=90;     %Beta: degrees of arc
		EXP.sample.gamma=120;    %Gamma: degrees of arc

		EXP.basis_user=eye(3);


	% orthorhombic
	case  'orth',
		% in this choice, the [-120] hexagonal is the same as [020] orthorhombic
		% 
		disp(' Using orthorhombic basis; [020]orth=[-120]hex.')

		EXP.basis_user=[2 0 0; 1 1 0; 0 0 1];

		EXP.sample.a= inplane * sqrt(3);		%A: angstroms
		EXP.sample.b= inplane;					%B: angstroms
		EXP.sample.c= outofplane;				%C: angstroms

		EXP.sample.alpha=90;    %Alpha: degrees of arc
		EXP.sample.beta=90;     %Beta: degrees of arc
		EXP.sample.gamma=90;    %Gamma: degrees of arc

end

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
