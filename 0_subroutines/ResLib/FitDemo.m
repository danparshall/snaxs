% ResLib v.3.4
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory

EXP=MakeExp;
EXP.sample.mosaic=60*3;
EXP.sample.vmosaic=60*3;
EXP.sample.b=18.046;
EXP.sample.a=6.148;  %chain axis
EXP.sample.c=8.013;
EXP.hcol=[30 80 860 400];
EXP.efixed=2.8;  %in meV
EXP.infin=-1; % Fixed final energy
EXP.horifoc=1; %The data were taken with a horizontally-focusing analyzer
EXP.ana.Q=0.1287;           %Kinematic reflectivity coefficient for PG(002)
EXP.orient1=[0 1 0];  
EXP.orient2=[1 0 0];  
EXP.method=-1; %Need to use method=0 to use focusing analyzer

data=load('Demo.dat','-ASCII');
H=data(:,3);
L=data(:,2);
K=data(:,1);
W=data(:,4);
I=data(:,5);
dI=data(:,6);





Db=0.412064;
Dc=0.5;
Da=1.85;
cc=6.4362;

intensity=2e4;
background=45;

InitialGuess=[ Da Db Dc cc 0.05 intensity background];
Variables=[ 1 0 1 0 0 1 1];

figure(1);clf;

disp('Welcome to the ResLib 3.3 fitting demo!');
disp(' ');
disp('Here is a const-Q|| scan measured on the SPINS spectrometer at NIST.');
disp('The material is NDMAP, a Haldane-gap system.');
disp('The two peaks are Haldane modes polarized perpendicular (low energy)');
disp('or parallel to the chain-axis (high energy)');
disp(' ');
figure(1); errorbar(W,I,dI,'.k');
xlabel('E (meV)'); ylabel('Intensity (arb. u.)');
disp(['The initial guess for parameters is :']);
disp( num2str(InitialGuess) );
disp(' ');


disp('First, lets rebin these data to have fewer data points to deal with.');
disp('The bin size will be 0.1 rlu along k and 0.075meV in energy.');
disp('Hit any key to proceed...');
pause;

[I,dI,H,K,L,W]=Rebin(I,dI,H,K,L,W,[0.05,0.1,0.05,0.075]);

disp(' ');
figure(1); hold on; errorbar(W,I,dI,'ob');

disp('Now, lets simulate this scan using initial parameters.');
disp('This may take a few seconds.');
disp('Hit any key to start...');
pause;

Initial=ConvResSMA('SMADemo','PrefDemo',H,K,L,W,EXP,'fix',[15 0],InitialGuess);
figure(1); hold on; plot(W,Initial,'g');

disp(' ');
disp('Now lets refine parameters 1, 2, 3, 6 and 7.');
disp('The scan was taken in a highly focusing configuration,');
disp('so a large number of integration points will be needed.');
disp('This may take a LONG time.');
disp('Hit any key to start and be patient...');
pause;



[Parameters,Errors,chisqN,Final,CN,PQ,nit,kvg,details]=...
   FitConvSMA(H,K,L,W,EXP,I,dI,'SMADemo','PrefDemo',InitialGuess,Variables,'fix',[15 0]);


disp(' ');
disp('Done!');
disp('A simulation based on refined parameter values is shown in red.');
figure(1); hold on; plot(W,Final,'r');
