function EXP=MakeExp
%=========================================================================================
% function EXP=MakeExp
%  ResLib v.3.4
%=========================================================================================
% This script is used to "manually" set up all the parameters for resolution calculations.
% The returned value is a structure that can be directly passed to the ResMat or
% ResMatS functions. The user is encouraged to make copies of this m-file and edit them 
% to generate particular experimental setups.
%
%-----------------------------------------------------------------------------------------
% See also: ResMat.m, ResMatS.m
%
%-----------------------------------------------------------------------------------------
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%=========================================================================================

% this file is set up for a triple-axis instrument such as BT-7, using fixed Ef=14.7 meV

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

%% ========= standard ResLib inputs are below ==================================


%-------------------------   Computation type    -----------------------------------------
%EXP.method=0; %Cooper-Nathans approximation by default.
%EXP.method=1; % Popovici approximation.
%EXP.moncor=1; % Intensity normalized to flux on monitor by default...
%EXP.moncor=0; % Intensity normalization to white beam flux.

%-------------------------   Monochromator and analyzer    -------------------------------
EXP.mono.tau='PG(002)';     %PG(002), PG(004), GE(111), GE(220),GE(311),BE(002) or PG(110)...
%EXP.mono.tau=3.74650;      %...or any manual input, in reciprocal angstroms
EXP.mono.mosaic=120;         %Minutes of arc
%EXP.mono.vmosaic=45;       %...For anisotropic mosaic: vertical mosaic, minutes of arc
EXP.ana.tau='PG(002)';      %PG(002)
EXP.ana.mosaic=120;          %Minutes of arc
%EXP.ana.vmosaic=25;        %...For anisotropic mosaic: vertical mosaic, minutes of arc

%-------------------------   Soller and neutron guide collimation    ----------------------
EXP.hcol=[80 80 80 80];         % Horizontal collimation: FWHM minutes of arc
EXP.vcol=[80 80 80 80];     % Vertical collimation: FWHM minutes of arc
                                % If the beam divergence is limited by a neutron guide, 
                                % the parameter value is the negative of the guide's m-value. 
                                % For example, for a 58-Ni guide (m=1.2) the corresponding 
                                % values in EXP.hcol and EXP.vcol is -1.2.

%-------------------------   Fixed neutron energy    --------------------------------------
EXP.efixed=14.7;    %Fixed neutron energy in meV
EXP.infin=-1;      % Fixed final energy: default value
%EXP.infin=1;       % .. negative for fixed incident energy

%-------------------------   Experimental geometry    -------------------------------------
%EXP.dir1=1;        %  Monochromator scattering direction opposite to sample scattering by default
EXP.dir1=-1;       %  ...negative if scattering directions are the same.
%EXP.dir2=1;        %  Analyzer scattering direction opposite to sample scattering by default
EXP.dir2=-1;       %  ...negative if scattering directions are the same.
%EXP.mondir=1;      %  Monochromator scattering angle is positive by default

EXP.orient1=[1 0 0]; %First orienting vector in scattering plane
EXP.orient2=[0 1 0]; %Second orienting vector in scattering plane

%-------------------------   Analyzer reflectivity parameters ----------------------------
% Do not assign these fields if no reflectivity corrections are to be made
%EXP.ana.thickness=0.2;     %Analyzer thickness
%EXP.ana.Q=0.1287;			%Kinematic reflectivity coefficient for PG(002)


%-------------------------   Horizontally focusing analyzer  ----------------------------
% These fields are used only if mode=0
%EXP.horifoc=1;  %Horizontally-focused analyzer
EXP.horifoc=-1; %Flat analyzer

%-------------------------   Spatial parameters     --------------------------------------
% All of these are optional and used only if mode=1 (Popovici approximation). 
% The default values correspond to the Cooper-Nathans limit.

% Component dimensions. For each object the "sizes" along a given coordinate axis X are 
% defined as sqrt( <x x> ). For a rectangular shape of width A along the Y axis, 
% for example, the correct input would be width=A/sqrt(12). For a spherical object
% of diameter D, one would input width=D/4.
%EXP.beam.width=2/sqrt(12); %Width of source in length units
%EXP.beam.height=2/sqrt(12); %Height of source in length units
%EXP.detector.width=2/sqrt(12); %Width of detector in length units
%EXP.detector.height=2/sqrt(12); %Height of detector in length units
%EXP.mono.width=2/sqrt(12); %Width of monochromator
%EXP.mono.height=2/sqrt(12); %Height of monochromator
%EXP.mono.depth=0.2/sqrt(12); %Thickness of monochromator
%EXP.ana.width=2/sqrt(12); %Width of analyzer.
%EXP.ana.height=2/sqrt(12); %Height of analyzer
%EXP.ana.depth=0.2/sqrt(12); %Thickness of analyzer
%EXP.monitor.width=4/sqrt(12); %Width of monitor
%EXP.monitor.heigth=4/sqrt(12); %Height of monitor

% The following matrix describes the sample shape. The components of S(i,j) matrix are  
% defined as <x_i x_j> for the sample. In ResMat it is assumed that this equation is written 
% in the coordinate system defined by the scattering vector. In ResMatS the sample coordinate 
% system, defined by the orienting vectors, is used instead.
%EXP.sample.shape=diag([0.2 0.2 1].^2/12);    %In this example the rectangular sample is 1 
%                                             %units tall and 0.2 units in diameter.

% Spectrometer arms
%EXP.arms=[150 150 150 150 100];  %Distances between the white beam aperture and monochromator,
                                  %monochromator and sample, sample and analyzer, analyzer and
                                  %detector, monochromator and monitor,
% Crystal curvatures
%EXP.mono.rv=150; %vertical curvature radius of monochromator
%EXP.mono.rh=150; %horizontal curvature radius of monochtor
%EXP.ana.rv=150; %vertical curvature radius of analyzer
%EXP.ana.rh=150; %horizontal curvature radius of analyzer
                            
%-------------------------   Smoothing parameters     -------------------------------------
% Do not assign these fields if no Gaussian smoothing was used on the data. This correction
% is only performed at the level of ResMatS, not at the level of ResMat.

%EXP.Smooth.E=1;    %Smoothing FWHM in energy (meV)
%EXP.Smooth.X=1E-4; %Smoothing FWHM along the first orienting vector  (x axis) 
                    %in rec. Angstroms. A small number means "no smoothing".
%EXP.Smooth.Y=0.2;  %Smoothing FWHM along the y axis (rec. Angstroms). 
%EXP.Smooth.Z=1E-4; %Smoothing FWHM along the vertical direction (z axis) in rec. Angstroms

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
