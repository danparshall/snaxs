function phi=angle(x1,y1,z1,x2,y2,z2,lattice)
%===================================================================================
%  function phi=angle(x1,y1,z1,x2,y2,z2,lattice)
%  ResLib v.3.4
%===================================================================================
%
%  Calculate the angle between two vectors.
%
% A. Zheludev, 1999-2005
% Oak Ridge National Laboratory
%====================================================================================

phi=acos(scalar(x1,y1,z1,x2,y2,z2,lattice)./modvec(x1,y1,z1,lattice)./modvec(x2,y2,z2,lattice));
