function EXP=demoEXP_tof
%===============================================================================
% function EXP=demoEXP_tof
% adaption from ResLib. Q-resolution is not considered, so only need to indicate
% the parameters listed in this file.
%
%	Required:
%		experiment_type='tof'
%		efixed
%		infin
%		sample.a/b/c
%
%	Optional:
%		basis_user			% can switch between various bases
%		calculation_path	% if provided, SNAXS will load this automatically
%		instrument			% Default is ARCS, others will be implemented in the future
%===============================================================================

% === for neutron time-of-flight, very little information is needed ===
EXP.experiment_type = 'tof';	% if not specified, SNAXS defaults to 'tas'
EXP.efixed=150;					% Fixed neutron energy in meV
EXP.infin=1;					% Fixed energy (pos. for fixed Ei)
EXP.instrument='ARCS';			% Used to determine Energy resolution (and someday, Q-resolution). 
								% Only ARCS is currently implemented. Hope to add MERLIN soon.


EXP.dim=[3 3 2];
EXP.calculation_path='phonopy_files/example/MgB2/POSCAR';

% === if desired, user can select between multiple calculations and/or basis ===
coordinates='hex';	% use 'orth' or 'hex'
inplane=  3.091;	% 3.091 is experimental, 3.05573 is anapert, 3.07516 is phonopy
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

%% ## This file distributed with SNAXS beta 0.9.9, released 07-Apr-2015 ## %%
