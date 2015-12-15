% This is an example of use for ConvRes.m. and ConvResSMA.m 
% It simulates inelastic scans for gapped  excitations in a 1-dimensional 
% S=1 antiferromagnet. "a" is assumed to be the chain axis. The
% scan is simulated using ConvRes.m, the cross section defined 
% in SqwDemo.m and the "slow" prefactor and background in PrefDemo.m. 
% The same scan is the simulated with ConvResSMA.m, the dispersion defined in 
% SMADemo.m and prefactor in PrefSMA.m. 
%  ResLib v.3.4

% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory


%Define experimental geometry and smaple parameters

setup=MakeExp; 
setup.sample.a=6;  
setup.sample.b=7;
setup.sample.c=8;
setup.hcol=[80 40 40 80];  
setup.orient1=[1 0 0];  
setup.orient2=[0 0 1];  

%Parameter values for the cross section

p(1)=3;                 % Gap at the AF zone-center in meV for x-axis mode
p(2)=3;                 % Gap at the AF zone-center in meV for y-axis mode
p(3)=3;                 % Gap at the AF zone-center in meV for z-axis mode
p(4)=30;                % Bandwidth in meV 
p(5)=0.4;               % Intrinsic Lorentzian HWHM of exccitation in meV
p(6)=6e4;                   % Intensity prefactor
p(7)=40;                 % Flat background

%Define a constant-Q the scan to be simulated (1.5,0,0.35)

H1=1.5; 
K1=0;
L1=0.35;
W1=20:-0.5:0;


%=========================================== 4D convolution
fprintf('Welcome to the ResLib 3.3 demo!\n');
fprintf('\n');
fprintf('This script uses ConvRes and ConvResSMA to simulate scans based on the SQWDemo and SMADemo cross section functions.\n');
fprintf('1) Simulate a constant-Q scan at (1.5,0,0.35) using [5 0] accuracy.\n');
fprintf('Hit any key to start...\n');
pause;
fprintf('This will take a minute...');
pause(0.1);
figure(1);clf;
I11=ConvRes('SqwDemo','PrefDemo',H1,K1,L1,W1,setup,'fix',[5 0],p);
figure(1); clf; plot(W1,I11,'r--');
xlabel('E (meV)'); ylabel('Intensity (arb. u.)');
fprintf('...done!\n');
fprintf('Note the wiggles at high energy. Not enough sampling points.\n');
fprintf('2) Lets try to simulate the same scan using [15 0] accuracy.\n'); 
fprintf('Hit any key to start...\n');
pause;
fprintf('This will take much longer...');
pause(0.1);
I12=ConvRes('SqwDemo','PrefDemo',H1,K1,L1,W1,setup,'fix',[15 0],p);
figure(1); hold on; plot(W1,I12,'r');
fprintf('...done!\n');
fprintf('Note that the wiggles are almost gone!\n');

fprintf('3) Now lets simulate the same scan using Monte Carlo integration (10k points).\n');
fprintf('Hit any key to start...\n');
pause;
fprintf('This will take some time...');
pause(0.1);
I13=ConvRes('SqwDemo','PrefDemo',H1,K1,L1,W1,setup,'mc',[],p);
figure(1); hold on; plot(W1,I13,'ro');
fprintf('...done!\n');


fprintf('4) Simulating the same scan with [15 0] accuracy using ConvResSMA.m will be MUCH faster!\n');
fprintf('Hit any key to start...');
pause;
I14=ConvResSMA('SMADemo','PrefDemo',H1,K1,L1,W1,setup,'fix',[15 0],p);
figure(1); hold on; plot(W1,I14,'g');
fprintf('...done!\n');

fprintf('5) Simulating the same scan using Monte Carlo integration in ConvResSMA.m (1k points)...\n');
fprintf('Hit any key to start...');
pause;
I15=ConvResSMA('SMADemo','PrefDemo',H1,K1,L1,W1,setup,'mc',[1],p);
figure(1); hold on; plot(W1,I15,'go');
fprintf('...done!\n');
fprintf('Bye!\n');
pause;
