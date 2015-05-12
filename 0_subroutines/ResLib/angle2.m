function phi=angle2(x,y,z,h,k,l,lattice)
%===================================================================================
%  phi=angle2(x,y,z,h,k,l,lattice)
%  ResLib v.3.4
%===================================================================================
%
%  Calculate the angle between vectors in real and reciprocal space. x,y and z are
%  fractional cell coordinates of the first vector, and h,k, and l are Miller indexes
%  of the second vector.
%
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%====================================================================================

[V,Vstar,latticestar]=star(lattice);

phi=acos(2*pi*(h.*x+k.*y+l.*z)./modvec(x,y,z,lattice)./modvec(h,k,l,latticestar));
