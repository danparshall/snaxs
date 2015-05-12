function [x,y,z]=vector(x1,y1,z1,x2,y2,z2,lattice)
%===================================================================================
% [x,y,z]=vector(x1,y1,z1,x2,y2,z2,lattice)
%  ResLib v.3.4
%===================================================================================
%
%  Calculates the fractional cell coordinates or Miller indexes of a vectorproduct of 
%  two vectors, defined by their fractional cell coordinates or Miller indexes.
%
%
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%====================================================================================

[V,Vstar,latticestar]=star(lattice);

u=V*(y1.*z2-y2.*z1)/2/pi;
v=V*(z1.*x2-z2.*x1)/2/pi;
w=V*(x1.*y2-x2.*y1)/2/pi;

[x,y,z]=reciprocate(u,v,w,lattice);
