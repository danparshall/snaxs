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

cen_H=2.0;
cen_K=0;
cen_L=0;
Gamma=0.1;

% Calculate the dispersion
H
r_H=H-cen_H
r_K=K-cen_K;

Xpts=sqrt(length(H))
Ypts=Xpts;

size( r_H)
rad=sqrt( r_H.^2 + r_K.^2 );
size(rad)
Z_mat=reshape(rad,Xpts,Ypts);


size(rad)
size(r_H)
size(r_K)
w0=12.6*rad;

X_vec=reshape(r_H,Xpts,Ypts);
Y_vec=reshape(r_K,Xpts,Ypts);
X_vec=X_vec(1,:);
Y_vec=Y_vec(:,1);
hold off
size(X_vec)
size(Y_vec)
surf(X_vec,Y_vec,Z_mat)

%surf(r_H,r_K,w0)

% Intensity 
S=ones(size(w0));

% Now set all energy widths of all branches to Gamma
HWHM=ones(size(S))*Gamma;
