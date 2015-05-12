function [H,K,L,q]=S2R(qx,qy,qz,EXP)
%===================================================================================
%  function [H,K,L,q]=S2R(qx,qy,qz,EXP)
%  ResLib v.3.4
%===================================================================================
%
% Given cartesian coordinates of a vector in the S-system, calculate its
% reciprocal-space coordinates (Miller indexes).
%
% A. Zheludev, 1999-2007
% Oak Ridge National Laboratory
%====================================================================================

[x,y,z]=StandardSystem(EXP);
H=qx.*x(1,:)+qy.*y(1,:)+qz.*z(1,:);
K=qx.*x(2,:)+qy.*y(2,:)+qz.*z(2,:);
L=qx.*x(3,:)+qy.*y(3,:)+qz.*z(3,:);
q=sqrt(qx.^2+qy.^2+qz.^2);
