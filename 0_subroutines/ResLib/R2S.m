function [qx,qy,qz,q]=R2S(H,K,L,EXP)
%===================================================================================
%  function [qx,qy,qz,q]=R2S(H,K,L,EXP)
%  ResLib v.3.4
%===================================================================================
%
% Given reciprocal-space coordinates of a vector, calculates its cartesian
% coordinates in the S-System.
%
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%====================================================================================


[x,y,z,sample,rsample]=StandardSystem(EXP);
qx=scalar(H,K,L,x(1,:),x(2,:),x(3,:),rsample);
qy=scalar(H,K,L,y(1,:),y(2,:),y(3,:),rsample);
qz=scalar(H,K,L,z(1,:),z(2,:),z(3,:),rsample);
q=modvec(H,K,L,rsample);
