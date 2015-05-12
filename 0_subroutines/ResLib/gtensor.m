function g=gtensor(lattice)
%===================================================================================
% function function g=gtensor(lattice)
%  ResLib v.3.4
%===================================================================================
%
%  Calculates the metric tensor for a crystal lattice.
%
%
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%====================================================================================

g(1,1,:)=lattice.a.^2;
g(1,2,:)=lattice.a.*lattice.b.*cos(lattice.gamma);
g(1,3,:)=lattice.a.*lattice.c.*cos(lattice.beta);

g(2,1,:)=g(1,2,:);
g(2,2,:)=lattice.b.^2;
g(2,3,:)=lattice.c.*lattice.b.*cos(lattice.alpha);

g(3,1,:)=g(1,3,:);
g(3,2,:)=g(2,3,:);
g(3,3,:)=lattice.c.^2;
