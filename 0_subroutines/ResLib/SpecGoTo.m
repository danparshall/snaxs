function [M1,M2,S1,S2,A1,A2]=SpecGoTo(H,K,L,E,EXP)
%===================================================================================
%  function [M1,M2,S1,S2,A1,A2]=SpecGoTo(H,K,L,E,EXP)
%  ResLib v.3.4
%===================================================================================
%
%  Calculate shaft angles given momentum transfer H, K, L, energy transfer E, and 
%  spectrometer and smaple parameters in EXP. 
%
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%====================================================================================
CONVERT2=2.072;

[len,H,K,L,E,EXP]=CleanArgs(H,K,L,E,EXP);


mono=[EXP.mono];
for ind=1:len taum(ind)=GetTau(mono(ind).tau);end;
ana=[EXP.ana];
for ind=1:len taua(ind)=GetTau(ana(ind).tau); end;

if ~isfield(EXP,'infin') infin(1:len)=-1; else infin=[EXP.infin]; end;
if ~isfield(EXP,'dir1') dir1(1:len)=1; else dir1=[EXP.dir1]; end;
if ~isfield(EXP,'dir2') dir2(1:len)=1; else dir2=[EXP.dir2]; end;
if ~isfield(EXP,'mondir') mondir(1:len)=1; else mondir=[EXP.mondir]; end;
   
efixed=[EXP.efixed];
[qx,qy,qz,Q]=R2S(H,K,L,EXP);



dir=zeros(3,len);
dir(1,:)=mondir;
dir(2,:)=-dir(1,:).*dir1;
dir(3,:)=-dir(2,:).*dir2;

ei=efixed+E;
ef=efixed;
change=find(infin>0);
if ~isempty(change) 
    ef(change)=efixed(change)-E(change);
    ei(change)=efixed(change);
end;

ki = sqrt(ei/CONVERT2);
kf = sqrt(ef/CONVERT2);

M1=asin(taum./(2.*ki)).*sign(dir(1,:)); 
M2=2*M1;
A1=asin(taua./(2.*kf)).*sign(dir(3,:)); 
A2=2*A1;
S2=acos( (ki.^2+kf.^2-Q.^2)./(2*ki.*kf)).*sign(dir(2,:));

phi=atan2(-kf.*sin(S2), ki-kf.*cos(S2)); 
psi=atan2(qy,qx);
S1=-psi+phi;


bad=find(ei<0 | ef<0 | abs(taum./(2.*ki))>1 | abs(taua./(2.*kf))>1 | abs ( (ki.^2+kf.^2-Q.^2)./(2*ki.*kf))>1);
M1(bad)=NaN;
M2(bad)=NaN;
S1(bad)=NaN;
S2(bad)=NaN;
A1(bad)=NaN;
A2(bad)=NaN;
