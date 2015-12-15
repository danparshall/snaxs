function ResPlot3D(H,K,L,W,EXP,RANGE,EllipsoidStyle,XYStyle,XEStyle,YEStyle,SMA,SMAp,SXg,SYg)
%===================================================================================
%  function ResPlot3D(
%         H,K,L,W,EXP,RANGE,EllipsoidStyle,XYStyle,XEStyle,YEStyle,SMA,SMAp,SXg,SYg)
%  ResLib v.3.4
%===================================================================================
%
% For a specified scan, plot pretty  resolution ellipsoids in 3D.
% If a SMA cross section is specified, the calculated dispersion is plotted as well.
%
% A. Zheludev, 1999-2007
% Oak Ridge National Laboratory
%====================================================================================

SMAGridPoints=40;
EllipsoidGridPoints=40;

if nargin < 7 | isempty(EllipsoidStyle), EllipsoidStyle='Red'; end;
if nargin < 8 | isempty(XYStyle), XYStyle=''; end;
if nargin < 9 | isempty(XEStyle), XEStyle=''; end;
if nargin < 10 | isempty(YEStyle), YEStyle=''; end;
if nargin < 11, SMA=[]; end;
if nargin < 12 | isempty(SMAp), SMAp=[]; end;
if nargin < 13 , SXg=[]; end;
if nargin < 14 , SYg=[]; end;
if ~isempty(SMA) &((isempty(SXg) & ~isempty(SYg))|(isempty(SYg) & ~isempty(SXg)) )
   error('Dispersion surface grid: must provide both SXg & SYg or neither.'); end;
if ~isempty(SMA) & isempty(SXg) & isempty(SYg)
   SX=linspace(RANGE(1),RANGE(2),SMAGridPoints);
   SY=linspace(RANGE(3),RANGE(4),SMAGridPoints);
   [SXg,SYg]=meshgrid(SX,SY);
end;


if( length(RANGE)<6), error('Range must have the form [Xmin Xmax Ymin Ymax Emin Emax]'); end;

[len,H,K,L,W,EXP]=CleanArgs(H,K,L,W,EXP);

center=round(length(H)/2);
if center<1, center=1; end;
if center>length(H), center=length(H); end;
EXP=EXP(center);


[R0,RMS]=ResMatS(H,K,L,W,EXP);
[xvec,yvec,zvec,sample,rsample]=StandardSystem(EXP);
qx=scalar(xvec(1,:),xvec(2,:),xvec(3,:),H,K,L,rsample);
qy=scalar(yvec(1,:),yvec(2,:),yvec(3,:),H,K,L,rsample);
qw=W;

figure(1); clf; axis(RANGE); hold on;
xlabel('Qx (Å-1)'); ylabel('Qy (Å-1)'); zlabel('E (meV)');

%plot ellipsoids
wx=fproject(RMS,1); wy=fproject(RMS,2); ww=fproject(RMS,3);
for point=1:len
   x=linspace(-wx(point)*1.5,wx(point)*1.5,EllipsoidGridPoints)+qx(point);
   y=linspace(-wy(point)*1.5,wy(point)*1.5,EllipsoidGridPoints)+qy(point);
   z=linspace(-ww(point)*1.5,ww(point)*1.5,EllipsoidGridPoints)+qw(point);
   [xg,yg,zg]=meshgrid(x,y,z);
   ee=RMS(1,1,point)*(xg-qx(point)).^2+RMS(2,2,point)*(yg-qy(point)).^2+RMS(3,3,point)*(zg-qw(point)).^2+...
      2*RMS(1,2,point)*(xg-qx(point)).*(yg-qy(point))+...
      2*RMS(1,3,point)*(xg-qx(point)).*(zg-qw(point))+...
      2*RMS(3,2,point)*(zg-qw(point)).*(yg-qy(point));
   p = patch(isosurface(xg, yg, zg, ee, 2*log(2)));
   isonormals(xg,yg,zg,ee,p)
   set(p, 'FaceColor', EllipsoidStyle, 'EdgeColor', 'none','BackFaceLighting','reverselit');
end;


%plot dispersion surfaces
if ~isempty(SMA)
   Hgrid=SXg(1:end)*xvec(1,1)+SYg(1:end)*yvec(1,1);
   Kgrid=SXg(1:end)*xvec(2,1)+SYg(1:end)*yvec(2,1);
   Lgrid=SXg(1:end)*xvec(3,1)+SYg(1:end)*yvec(3,1);
   [disp,int,WL]=feval(SMA,Hgrid,Kgrid,Lgrid,SMAp);
   [modes,points]=size(disp);
   [a b]=size(SXg);
   for mode=1:modes
      SZ=reshape(disp(mode,:),a,b);
      SZ(SZ>RANGE(6))=NaN;
      SZ(SZ<RANGE(5))=NaN;
      surf(SXg,SYg,SZ,'BackFaceLighting','reverselit');
   end;
end;

%plot projections
[proj3,sec]=project(RMS,3);
[proj2,sec]=project(RMS,2);
[proj1,sec]=project(RMS,1);
phi=0.1:2*pi/3000:2*pi+0.1;
for i=1:len
   r3=sqrt(2*log(2)./(proj3(1,1,i)*cos(phi).^2+proj3(2,2,i)*sin(phi).^2+2*proj3(1,2,i)*cos(phi).*sin(phi)));
   r2=sqrt(2*log(2)./(proj2(1,1,i)*cos(phi).^2+proj2(2,2,i)*sin(phi).^2+2*proj2(1,2,i)*cos(phi).*sin(phi)));
   r1=sqrt(2*log(2)./(proj1(1,1,i)*cos(phi).^2+proj1(2,2,i)*sin(phi).^2+2*proj1(1,2,i)*cos(phi).*sin(phi)));
   xproj3=r3.*cos(phi)+qx(i);   yproj3=r3.*sin(phi)+qy(i);   zproj3=ones(size(xproj3))*RANGE(5);
   xproj2=r2.*cos(phi)+qx(i);   zproj2=r2.*sin(phi)+qw(i);   yproj2=ones(size(xproj2))*RANGE(4);
   yproj1=r1.*cos(phi)+qy(i);   zproj1=r1.*sin(phi)+qw(i);   xproj1=ones(size(yproj1))*RANGE(2);
   if ~strcmp(YEStyle,'none'), plot3(xproj1,yproj1,zproj1,YEStyle); end;
   if ~strcmp(XEStyle,'none'), plot3(xproj2,yproj2,zproj2,XEStyle); end;
   if ~strcmp(XYStyle,'none'), plot3(xproj3,yproj3,zproj3,XYStyle); end;
end;



%finalize 3D plot
box on; grid on;
camlight headlight;
lighting phong;
material shiny;
da=daspect;
daspect([da(2) da(2) da(3)]);

%========================================================================================================
%========================================================================================================
%========================================================================================================

function hwhm=fproject (mat,i)
if (i==1) v=3;j=2;end;
if (i==2) v=1;j=3;end;
if (i==3) v=1;j=2;end;
[a,b,c]=size(mat);
proj=zeros(2,2,c);
proj(1,1,:)=mat(i,i,:)-mat(i,v,:).^2./mat(v,v,:);
proj(1,2,:)=mat(i,j,:)-mat(i,v,:).*mat(j,v,:)./mat(v,v,:);
proj(2,1,:)=mat(j,i,:)-mat(j,v,:).*mat(i,v,:)./mat(v,v,:);
proj(2,2,:)=mat(j,j,:)-mat(j,v,:).^2./mat(v,v,:);
hwhm=proj(1,1,:)-proj(1,2,:).^2./proj(2,2,:);
hwhm=sqrt(2*log(2))./sqrt(hwhm);


function [proj, sec]=project (mat,v)
if v == 3, i=1;j=2; end;
if v == 1, i=2;j=3; end;
if v == 2, i=1;j=3; end;
[a,b,c]=size(mat);
proj=zeros(2,2,c);
sec=zeros(2,2,c);
proj(1,1,:)=mat(i,i,:)-mat(i,v,:).^2./mat(v,v,:);
proj(1,2,:)=mat(i,j,:)-mat(i,v,:).*mat(j,v,:)./mat(v,v,:);
proj(2,1,:)=mat(j,i,:)-mat(j,v,:).*mat(i,v,:)./mat(v,v,:);
proj(2,2,:)=mat(j,j,:)-mat(j,v,:).^2./mat(v,v,:);
sec(1,1,:)=mat(i,i,:);
sec(1,2,:)=mat(i,j,:);
sec(2,1,:)=mat(j,i,:);
sec(2,2,:)=mat(j,j,:);
