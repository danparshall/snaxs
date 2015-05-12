function conv=ConvResSMA(sqw,pref,H,K,L,W,EXP,METHOD,ACCURACY,p)
%===================================================================================
%  function conv=ConvResSMA(sqw,pref,H,K,L,W,EXP,METHOD,ACCURACY,p)
%  ResLib v.3.4
%===================================================================================
%
% Numerically calculate the convolution of a user-defined single-mode cross-section 
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


Mww(1:len)=RMS(3,3,1:len); Mxw(1:len)=RMS(1,3,1:len); Myw(1:len)=RMS(2,3,1:len);

GammaFactor=sqrt(Mww/2); OmegaFactorx=Mxw./sqrt(2*Mww); OmegaFactory=Myw./sqrt(2*Mww);

Mzz(1:len)=RMS(4,4,1:len); Mxx(1:len)=RMS(1,1,1:len); Mxx=Mxx-Mxw.^2./Mww; 
Myy(1:len)=RMS(2,2,1:len); Myy=Myy-Myw.^2./Mww; Mxy(1:len)=RMS(1,2,1:len);
Mxy=Mxy-Mxw.*Myw./Mww;

detxy=sqrt(Mxx.*Myy-Mxy.^2); detz=sqrt(Mzz);

tqz=1./detz; tqy=sqrt(Mxx)./detxy;
tqxx=1./sqrt(Mxx); tqxy=Mxy./sqrt(Mxx)./detxy;

%================================================================================================
[disp,int,WL0]=feval(sqw,H,K,L,p);
[modes,points]=size(disp);

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
      r=randn(3,1000)*pi-pi/2;
      cx=r(1,:); cy=r(2,:); cz=r(3,:);
      tx=tan(cx(1:end)); ty=tan(cy(1:end)); tz=tan(cz(1:end));
      norm=exp(-0.5*(tx.^2+ty.^2+tz.^2)).*(1+tx.^2).*(1+ty.^2).*(1+tz.^2);
      dQ1=tqxx(i)*tx-tqxy(i)*ty;
      dQ2=tqy(i)*ty;
      dQ4=tqz(i)*tz;
      H1=H(i)+dQ1*xvec(1,i)+dQ2*yvec(1,i)+dQ4*zvec(1,i);
      K1=K(i)+dQ1*xvec(2,i)+dQ2*yvec(2,i)+dQ4*zvec(2,i);
      L1=L(i)+dQ1*xvec(3,i)+dQ2*yvec(3,i)+dQ4*zvec(3,i);
      [disp,int,WL]=feval(sqw,H1,K1,L1,p);
      [modes,points]=size(disp);
      for j=1:modes
         Gamma=WL(j,:)*GammaFactor(i);
         Omega=GammaFactor(i)*(disp(j,:)-W(i))+OmegaFactorx(i)*dQ1+OmegaFactory(i)*dQ2;
         add=int(j,:).*voigt(Omega,Gamma).*norm/detxy(i)/detz(i);
         convs(j,i)=convs(j,i)+sum(add);
      end; end;
      conv(i)=sum( convs(:,i).*prefactor(:,i) );
   end;
   conv=conv/M/1000*pi^3;
end;


%========================= fix  method =============================================================

if strcmp(METHOD,'fix') 
   found=1;
   if isempty(ACCURACY)
      ACCURACY=[7 0];
   end;
   M=ACCURACY;
   step1=pi/(2*M(1)+1);
   step2=pi/(2*M(2)+1);
   dd1=linspace(-pi/2+step1/2,pi/2-step1/2,(2*M(1)+1));
   dd2=linspace(-pi/2+step2/2,pi/2-step2/2,(2*M(2)+1));
   convs=zeros(modes,len);
   conv=zeros(1,len);
   [cx,cy]=ndgrid(dd1,dd1);
   tx=tan(cx(1:end)); ty=tan(cy(1:end)); 
   tz=tan(dd2);
   norm=exp(-0.5*(tx.^2+ty.^2)).*(1+tx.^2).*(1+ty.^2);
   normz=exp(-0.5*(tz.^2)).*(1+tz.^2);
   for iz=1:length(tz)
   for i=1:len
      dQ1=tqxx(i)*tx-tqxy(i)*ty;
      dQ2=tqy(i)*ty;
      dQ4=tqz(i)*tz(iz);
      H1=H(i)+dQ1*xvec(1,i)+dQ2*yvec(1,i)+dQ4*zvec(1,i);
      K1=K(i)+dQ1*xvec(2,i)+dQ2*yvec(2,i)+dQ4*zvec(2,i);
      L1=L(i)+dQ1*xvec(3,i)+dQ2*yvec(3,i)+dQ4*zvec(3,i);
      [disp,int,WL]=feval(sqw,H1,K1,L1,p);
      [modes,points]=size(disp);
      for j=1:modes
         Gamma=WL(j,:)*GammaFactor(i);
         Omega=GammaFactor(i)*(disp(j,:)-W(i))+OmegaFactorx(i)*dQ1+OmegaFactory(i)*dQ2;
         add=int(j,:).*voigt(Omega,Gamma).*norm*normz(iz)/detxy(i)/detz(i);
         convs(j,i)=convs(j,i)+sum(add);
      end;
      conv(i)=sum( convs(:,i).*prefactor(:,i) );
   end;end;
   conv=conv*step1^2*step2;
   if M(2)==0 conv=conv*0.79788; end;
   if M(1)==0 conv=conv*0.79788^2; end;
end;

%==================================================================================================

if found==0
   error('??? Error in ConvRes: Unknown convolution method! Valid options are: "fix" or "mc".');
end;   
conv=conv.*R0;
conv=conv+bgr;   

%==================================================================================================
%==================================================================================================
%==================================================================================================

function y=voigt(x,a)
nx=length(x);
if length(a)==1, a(1:nx)=a; end;
y(1:nx)=0;

t=a-j*x; ax=abs(x); s=ax + a; u=t.^2;
good=find(a==0); y(good)=exp(-x(good).^2);
good=find(a>=15 | s>=15); y(good)=approx1(t(good));
good=find(s<15 & a<15 & a>=5.5); y(good)=approx2(t(good),u(good));   
good=find(s<15 & s>=5.5 & a<5.5); y(good)=approx2(t(good),u(good));   
good=find(s<5.5 & a<5.5 & a>=0.75); y(good)=approx3(t(good));
good=find(s<5.5 & a>=0.195*ax-0.176 & a<0.75); y(good)=approx3(t(good));
good=find(~(s<5.5 & a>=0.195*ax-0.176) & a<0.75); y(good)= exp(u(good))-approx4(t(good),u(good));

y=real(y);      

      
function y=approx1(t) 
y=(t*.5641896)./(.5 + t.^2);

function y=approx2(t,u)
y=(t.*(1.410474 + u*.5641896))./(.75+(u.*(3.+u)));

function y=approx3(t)
y=(16.4955+t.*(20.20933+t.*(11.96482+t.*(3.778987+0.5642236*t))))...
     ./ (16.4955+t.*(38.82363+t.*(39.27121+t.*(21.69274+t.*(6.699398+t)))));
     
function y=approx4(t,u)
y=(t.*(36183.31-u.*(3321.99-u.*(1540.787-u.*(219.031-u.*(35.7668-u.*(1.320522-u*.56419))))))...
     ./ (32066.6-u.*(24322.8-u.*(9022.23-u.*(2186.18-u.*(364.219-u.*(61.5704-u.*(1.84144-u))))))));
      
%==================================================================================================
