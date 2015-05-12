% This is an example of use for ResPlot3D.m.
% It plots a 3-D representation of the spin wave dispersion
% in a  a 1-dimensional S=1 antiferromagnet near the 1D 
% zone-center. On top of that, it shows resolution ellipsoids
% for each point of a pre-defined constant-Q scan, as well as
% preojections of these ellipsoids on the coordinate planes.
% ResLib v.3.4
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory


% Set up experimental conditions
setup=MakeExp; 
setup.sample.mosaic=60;
setup.sample.vmosaic=60;
setup.sample.a=3.8;  
setup.sample.b=5.8;
setup.sample.c=11.7;
setup.hcol=[60 40 40 120];  
setup.orient1=[1 0 0];  
setup.orient2=[0 0 -1];
setup.efixed=14.7;

% Set up parameters for the SMADemo.m cross section
p(1)=9;                 % Gap at the AF zone-center in meV for x-axis mode
p(2)=15;                    % Gap at the AF zone-center in meV for y-axis mode
p(3)=15;                    % Gap at the AF zone-center in meV for z-axis mode
p(4)=100;               % Bandwidth in meV 
p(5)=0.4;               % Intrinsic Lorentzian HWHM of exccitation in meV
p(6)=1;                 % Intensity prefactor
p(7)=3;                 % Flat background

% Define a constant-Q scan
H=1.5; 
K=0;
L=0.2;
W=linspace(4,24,7);



% Define plotting range in reciprocal angstroms
RANGE=[1.4*2*pi/setup.sample.a 1.6*2*pi/setup.sample.a -0.5*2*pi/setup.sample.c 0 0 30];


% Define a mesh of (x,y) points for ploting the dispersion surface.
SX=linspace(RANGE(1),RANGE(2),100);
SY=linspace(RANGE(3),RANGE(4),40);
[SXg,SYg]=meshgrid(SX,SY);
   
% Mask one quadrant in the mesh to "cut open" the dispersion surface for a better visibility
% of resolution ellipsoids
SXg(SXg<1.5*2*pi/3.8 & SYg<-0.15)=NaN;
   
% Plot resolution ellipsoids and dispersion surface
figure(1); clf;
ResPlot3D(H,K,L,W,setup,RANGE,'Yellow','r','r','r','SMADemo',p,SXg,SYg);

%Select nice color map for dispersion surface
colormap cool;
