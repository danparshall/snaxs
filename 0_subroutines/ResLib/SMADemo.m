function [w0,S,HWHM]=SMADemo(H,K,L,p)
% This is an example of a cross section function for use with ConvResSMA.m.
% This particular function calculates the cross section for a gapped  
% excitations in a 1-dimensional S=1 antiferromagnet. "a" is the chain axis.
% The polarization factors for each mode are NOT calculated here, but
% should be included in the prefactor function instead. This function is
% meant to be used together with the prefactor function PrefDemo.m
% Arguments H-W and are vectors, so don't forget to use ".*" instead of "*", etc.
%  ResLib v.3.4
% A. Zheludev, 1999-2007
% Oak Ridge National Laboratory

% Extract the three parameters contained in "p":
Deltax=p(1);                    % Gap at the AF zone-center in meV for x-axis mode
Deltay=p(2);                    % Gap at the AF zone-center in meV for y-axis mode
Deltaz=p(3);                    % Gap at the AF zone-center in meV for z-axis mode
cc=p(4);                        % Bandwidth in meV 
Gamma=p(5);                     % Intrinsic HWHM of excitation in meV
%I=p(6);                        % Intensity prefactor. This parameter is used only in PrefDemo.m
%bgr=p(7);                      % A flat background. This parameter is used only in PrefDemo.m


% Calculate the dispersion
omegax=sqrt(cc^2*(sin(2*pi*H)).^2+Deltax^2);
omegay=sqrt(cc^2*(sin(2*pi*H)).^2+Deltay^2);
omegaz=sqrt(cc^2*(sin(2*pi*H)).^2+Deltaz^2);
w0(1,:)=omegax;
w0(2,:)=omegay;
w0(3,:)=omegaz;

% Intensity scales as (1-cos(2*pi*H))/omega0:
S(1,:)=(1-cos(pi*H))./omegax/2;
S(2,:)=(1-cos(pi*H))./omegay/2;
S(3,:)=(1-cos(pi*H))./omegaz/2;

% Now set all energy widths of all branches to Gamma
HWHM=ones(size(S))*Gamma;
