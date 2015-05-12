% This is an example of use for ResPlot.m.
% It calculates projections of resolution ellipsoids
% in a conastant-Q scan across gapped  excitations in a 1-dimensional 
% S=1 antiferromagnet. "a" is assumed to be the chain axis. The
% dispersion is plotted using SMADemo.m.
%  ResLib v.3.4

% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory

% Set up experimental conditions
setup=MakeExp; 
setup.sample.mosaic=25;
setup.sample.vmosaic=35;
setup.sample.a=6;  
setup.sample.b=7;
setup.sample.c=8;
setup.hcol=[80 40 40 80];  
setup.orient1=[1 0 0];  
setup.orient2=[0 0 1]; 

% Set up parameters for the SMADemo.m cross section

p(1)=3;                 % Gap at the AF zone-center in meV for x-axis mode
p(2)=5;                 % Gap at the AF zone-center in meV for y-axis mode
p(3)=3;                 % Gap at the AF zone-center in meV for z-axis mode
p(4)=30;                % Bandwidth in meV 
p(5)=0.4;               % Intrinsic Lorentzian HWHM of exccitation in meV
p(6)=1;                 % Intensity prefactor
p(7)=3;                 % Flat background


% Define a constant-Q scan

H=1.52; 
K=0;
L=0.0;
W=linspace(0,20,7);

% Plot resolution parameters


setup.method=0;
figure(2); clf;
ResPlot(H,K,L,W,setup,'SMADemo',p);
