function conv=ConvRes(sqw,pref,H,K,L,W,EXP,METHOD,ACCURACY,p)
%===================================================================================
%  function conv=ConvRes(sqw,pref,H,K,L,W,EXP,METHOD,ACCURACY,p)
%  ResLib v.3.4
%===================================================================================
%
% Numerically calculate the convolution of a user-defined cross-section 
% function with the Cooper-Nathans resolution function for a 3-axis neutron 
% scattering experiment. See manual for details.
%
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%====================================================================================

[len,H,K,L,W,EXP]=CleanArgs(H,K,L,W,EXP);


%Get standard orthonormnal coordinate system, cell parameters and reciprocal cell parameters...
[xvec,yvec,zvec,sample,rsample]=StandardSystem(EXP);

%Calculate the resolution matrix...
[R0,RMS]=ResMatS(H,K,L,W,EXP);

Mzz(1:len)=RMS(4,4,1:len); Mww(1:len)=RMS(3,3,1:len); Mxx(1:len)=RMS(1,1,1:len);
Mxy(1:len)=RMS(1,2,1:len); Mxw(1:len)=RMS(1,3,1:len); Myy(1:len)=RMS(2,2,1:len);
Myw(1:len)=RMS(2,3,1:len);


Mxx=Mxx-Mxw.^2./Mww; Mxy=Mxy-Mxw.*Myw./Mww; Myy=Myy-Myw.^2./Mww; MMxx=Mxx-Mxy.^2./Myy;

detM=MMxx.*Myy.*Mzz.*Mww;


tqz=1./sqrt(Mzz); tqx=1./sqrt(MMxx);
tqyy=1./sqrt(Myy); tqyx=-Mxy./Myy./sqrt(MMxx);
tqww=1./sqrt(Mww); tqwy=-Myw./Mww./sqrt(Myy);
tqwx=-(Mxw./Mww-Myw./Mww.*Mxy./Myy)./sqrt(MMxx);


%================================================================================================
int=feval(sqw,H,K,L,W,p);
[modes,points]=size(int);

if isempty(pref)
   prefactor=ones(modes,points);
   bgr=0;
else 
    switch nargout(pref)
    case 2
        [prefactor,bgr]=feval(pref,H,K,L,EXP,p);
    case 1        
        prefactor=feval(pref,H,K,L,EXP,p);
        bgr=0;
    otherwise 
        error('Fata error: invalid number or output arguments in prefactor function');           
    end
end;

found=0;
%========================= fix  method ===========================================================

if strcmp(METHOD,'fix') 
   found=1;
   if isempty(ACCURACY)
      ACCURACY=[7 0];
   end;
   M=ACCURACY;
   step1=pi/(2*M(1)+1); step2=pi/(2*M(2)+1);
   dd1=linspace(-pi/2+step1/2,pi/2-step1/2,(2*M(1)+1));
   dd2=linspace(-pi/2+step2/2,pi/2-step2/2,(2*M(2)+1));
   convs=zeros(modes,len);
   conv=zeros(1,len);
   [cx,cy,cw]=ndgrid(dd1,dd1,dd1);
   tx=tan(cx(1:end)); ty=tan(cy(1:end)); tw=tan(cw(1:end)); 
   tz=tan(dd2);
   norm=exp(-0.5*(tx.^2+ty.^2)).*(1+tx.^2).*(1+ty.^2).*exp(-0.5*(tw.^2)).*(1+tw.^2);
   normz=exp(-0.5*(tz.^2)).*(1+tz.^2);
   for iz=1:length(tz);
   for i=1:len
      dQ1=tqx(i)*tx;
      dQ2=tqyy(i)*ty+tqyx(i)*tx;
      dW=tqwx(i)*tx+tqwy(i)*ty+tqww(i)*tw;
      dQ4=tqz(i)*tz(iz);
      H1=H(i)+dQ1*xvec(1,i)+dQ2*yvec(1,i)+dQ4*zvec(1,i);
      K1=K(i)+dQ1*xvec(2,i)+dQ2*yvec(2,i)+dQ4*zvec(2,i);
      L1=L(i)+dQ1*xvec(3,i)+dQ2*yvec(3,i)+dQ4*zvec(3,i);
      W1=W(i)+dW;
      int=feval(sqw,H1,K1,L1,W1,p);
      for j=1:modes
          add=int(j,:).*norm*normz(iz);
          convs(j,i)=convs(j,i)+sum(add);
      end
      conv(i)=sum( convs(:,i).*prefactor(:,i) );
   end;end;
   conv=conv*step1^3*step2./sqrt(detM);
   if M(2)==0 conv=conv*0.79788; end;
   if M(1)==0 conv=conv*0.79788^3; end;
end;

%========================= mc  method =============================================================

if strcmp(METHOD,'mc') 
   found=1;
   if isempty(ACCURACY)
      ACCURACY=10;
   end;
   M=ACCURACY;
   convs=zeros(modes,len);
   conv=zeros(1,len);
   for i=1:len
   for MonteCarlo=1:M
      r=randn(4,1000)*pi-pi/2;
      cx=r(1,:); cy=r(2,:); cz=r(3,:);cw=r(4,:);
      tx=tan(cx(1:end)); ty=tan(cy(1:end)); tz=tan(cz(1:end)); tw=tan(cw(1:end));
      norm=exp(-0.5*(tx.^2+ty.^2+tz.^2+tw.^2)).*(1+tx.^2).*(1+ty.^2).*(1+tz.^2).*(1+tw.^2);
      dQ1=tqx(i)*tx;
      dQ2=tqyy(i)*ty+tqyx(i)*tx;
      dW=tqwx(i)*tx+tqwy(i)*ty+tqww(i)*tw;
      dQ4=tqz(i)*tz;
      H1=H(i)+dQ1*xvec(1,i)+dQ2*yvec(1,i)+dQ4*zvec(1,i);
      K1=K(i)+dQ1*xvec(2,i)+dQ2*yvec(2,i)+dQ4*zvec(2,i);
      L1=L(i)+dQ1*xvec(3,i)+dQ2*yvec(3,i)+dQ4*zvec(3,i);
      W1=W(i)+dW;
      int=feval(sqw,H1,K1,L1,W1,p);
      for j=1:modes
          add=int(j,:).*norm;
          convs(j,i)=convs(j,i)+sum(add);
      end
      conv(i)=sum( convs(:,i).*prefactor(:,i) );
  end;end;
   conv=conv/M/1000*pi^4./sqrt(detM);
end;
%==================================================================================================

if found==0
   error('??? Error in ConvRes: Unknown convolution method! Valid options are: "fix",  "mc".');
end;   
conv=conv.*R0;
conv=conv+bgr;   
