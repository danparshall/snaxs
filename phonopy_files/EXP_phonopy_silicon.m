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
EXP.efixed=100;					% Fixed neutron energy in meV
EXP.infin=1;					% Fixed energy (pos. for fixed Ei)


EXP.calculation_path='phonopy_files/example/Si/POSCAR';

EXP.basis_user= [ -1  1  1 ; 
				   1 -1  1 ; 
				   1  1 -1 ];

%-------------------------   Sample -------------------------------------------------------
EXP.sample.a=5.4;      %A: angstroms

%% ## This file distributed with SNAXS beta 0.9.9, released 07-Apr-2015 ## %%
