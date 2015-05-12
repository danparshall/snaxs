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

H=linspace(  3,  3.3, 30);
K=linspace(-0.1, 0.1, 30);


cen_H=3.17;
cen_K=0;
cen_L=0;
cc=0;
Deltax=0;
% Calculate the dispersion
omegax=sqrt(cc^2*(sin(2*pi*(H-cen_H))).^2+Deltax^2);
size(omegax)

% SNAXS says 10meV/0.5 rlu, or 20 meV/1.587, 12.60 meV.ang
%cen_x=3.17; % center of Bragg peak/disp
%cen_y=0;
Hs=(H-cen_H);
Ks=(K-cen_K);
[gH,gK]=meshgrid(Hs,Ks);
rad=sqrt( gH.^2 + gK.^2 );
surf(H,K,rad)
%omega=12.60*rad;

w0(1,:)=omegax;
w0(2,:)=omegay;
w0(3,:)=omegaz;

w0(1,:)=12.6*(cen_H-H);
w0(2,:)=12.6*(cen_K-K);

w0=12.6*rad;

% Intensity 
S=ones(size(w0));

% Now set all energy widths of all branches to Gamma
HWHM=ones(size(S))*Gamma;
