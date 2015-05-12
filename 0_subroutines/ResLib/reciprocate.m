function [h,k,l]=reciprocate(x,y,z,lattice)
%===================================================================================
% function [h,k,l]=reciprocate(x,y,z,lattice)
%  ResLib v.3.4
%===================================================================================
%
%  Calculate the Miller indexes of a vector defined by its fractional cell coordinates,
%  or vice versa.
%
%
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%====================================================================================

g=gtensor(lattice);

h=( g(1,1,:).*x+g(2,1,:).*y+g(3,1,:).*z )/2/pi;
k=( g(1,2,:).*x+g(2,2,:).*y+g(3,2,:).*z )/2/pi;
l=( g(1,3,:).*x+g(2,3,:).*y+g(3,3,:).*z )/2/pi;
