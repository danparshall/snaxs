function ResPlot(H,K,L,W,EXP,SMA,SMAp)
%===================================================================================
%  function ResPlot(H,K,L,W,EXP,SMA,SMAp)
%  ResLib v.3.4
%===================================================================================
%
% For a specified scan, plot the projections of resolution ellipsoids and calculate 
% useful resolution parameters for center-point of scan. If a SMA cross section is
% specified, the calculated dispersion is plotted as well.
%
% A. Zheludev, 1999-2007
% Oak Ridge National Laboratory
%====================================================================================

if nargin < 6 , SMA=''; end;
if nargin < 7 | isempty(SMAp), SMAp=[]; end;
   
[len,H,K,L,W,EXP]=CleanArgs(H,K,L,W,EXP);

center=round(length(H)/2);
if center<1, center=1; end;
if center>length(H), center=length(H); end;
EXP=EXP(center);
Style1='';
Style2='--';

XYAxesPosition=[0.1 0.6 0.3 0.3];
XEAxesPosition=[0.1 0.1 0.3 0.3];
YEAxesPosition=[0.6 0.6 0.3 0.3];
TextAxesPosition=[0.45 0.0 0.5 0.5];
GridPoints=101;



[R0,RMS]=ResMatS(H,K,L,W,EXP);
[xvec,yvec,zvec,sample,rsample]=StandardSystem(EXP);
qx=scalar(xvec(1,:),xvec(2,:),xvec(3,:),H,K,L,rsample);
qy=scalar(yvec(1,:),yvec(2,:),yvec(3,:),H,K,L,rsample);
qw=W;

%========================================================================================================
%find reciprocal-space directions of X and Y axes

o1=EXP.orient1;
o2=EXP.orient2;
pr=scalar(o2(1),o2(2),o2(3),yvec(1),yvec(2),yvec(3),rsample);
o2(1)=yvec(1)*pr; 
o2(2)=yvec(2)*pr; 
o2(3)=yvec(3)*pr; 

if abs(o2(1))<1e-5, o2(1)=0; end;
if abs(o2(2))<1e-5, o2(2)=0; end;
if abs(o2(3))<1e-5, o2(3)=0; end;

if abs(o1(1))<1e-5, o1(1)=0; end;
if abs(o1(2))<1e-5, o1(2)=0; end;
if abs(o1(3))<1e-5, o1(3)=0; end;

%========================================================================================================
%determine the plot range
XWidth=max(fproject (RMS,1));
YWidth=max(fproject (RMS,2));
WWidth=max(fproject (RMS,3));
   XMax=(max(qx)+XWidth*1.5);
   XMin=(min(qx)-XWidth*1.5);
   YMax=(max(qy)+YWidth*1.5);
   YMin=(min(qy)-YWidth*1.5);
   WMax=(max(qw)+WWidth*1.5);
   WMin=(min(qw)-WWidth*1.5);
   

%========================================================================================================
% plot XE projection

XEAxes=axes('position',XEAxesPosition); axis([XMin XMax WMin WMax]); box on; hold on;
XEAxis2=axes('position',XEAxesPosition,'XAxisLocation','top','Ytickmode','manual','TickDir','out');
omax=XMax/modvec(o1(1),o1(2),o1(3),rsample);
omin=XMin/modvec(o1(1),o1(2),o1(3),rsample);
olab=['Qx ( units of [' num2str(o1(1)) ' ' num2str(o1(2)) ' ' num2str(o1(3)) '] )'];
axis([omin omax WMin WMax]); xlabel(olab);
axes(XEAxes); xlabel('Qx (Å-1)'); ylabel('E (meV)');
[proj,sec]=project(RMS,2);   
PlotEllipse(proj,qx,qw,Style1);
PlotEllipse(sec,qx,qw,Style2);
Qxgrid=linspace(XMin,XMax,GridPoints);
Qygrid(1:GridPoints)=qy(center);
Hgrid=Qxgrid*xvec(1)+Qygrid*yvec(1);
Kgrid=Qxgrid*xvec(2)+Qygrid*yvec(2);
Lgrid=Qxgrid*xvec(3)+Qygrid*yvec(3);
if ~isempty(SMA)
   [disp,int,WL]=feval(SMA,Hgrid,Kgrid,Lgrid,SMAp);
   [modes,points]=size(disp);
   for mode=1:modes
      plot(Qxgrid,disp(mode,:),Style1);
   end;
end;
   
%========================================================================================================
% plot YE projection

YEAxes=axes('position',YEAxesPosition); axis([YMin YMax WMin WMax]); box on; hold on;
YEAxis2=axes('position',YEAxesPosition,'XAxisLocation','top','Ytickmode','manual','TickDir','out');
omax=YMax/modvec(o2(1),o2(2),o2(3),rsample);
omin=YMin/modvec(o2(1),o2(2),o2(3),rsample);
olab=['Qy ( units of [' num2str(o2(1)) ' ' num2str(o2(2)) ' ' num2str(o2(3)) '] )'];
axis([omin omax WMin WMax]); xlabel(olab);
axes(YEAxes); xlabel('Qy (Å-1)'); ylabel('E (meV)');
[proj,sec]=project(RMS,1);   
PlotEllipse(proj,qy,qw,Style1);
PlotEllipse(sec,qy,qw,Style2);
Qygrid=linspace(YMin,YMax,GridPoints);
Qxgrid(1:GridPoints)=qx(center);
Hgrid=Qxgrid*xvec(1)+Qygrid*yvec(1);
Kgrid=Qxgrid*xvec(2)+Qygrid*yvec(2);
Lgrid=Qxgrid*xvec(3)+Qygrid*yvec(3);
if ~isempty(SMA)
   [disp,int,WL]=feval(SMA,Hgrid,Kgrid,Lgrid,SMAp);
   [modes,points]=size(disp);
   for mode=1:modes
      plot(Qygrid,disp(mode,:),Style1);
   end;
end;

%========================================================================================================
% plot XY projection

XYAxes=axes('position',XYAxesPosition); axis([XMin XMax YMin YMax]); box on; hold on;
XYAxis2=axes('position',XYAxesPosition,'XAxisLocation','top','YAxisLocation','right','TickDir','out');
oxmax=XMax/modvec(o1(1),o1(2),o1(3),rsample);
oxmin=XMin/modvec(o1(1),o1(2),o1(3),rsample);
oymax=YMax/modvec(o2(1),o2(2),o2(3),rsample);
oymin=YMin/modvec(o2(1),o2(2),o2(3),rsample);
oxlab=['Qx ( units of [' num2str(o1(1)) ' ' num2str(o1(2)) ' ' num2str(o1(3)) '] )'];
oylab=['Qy ( units of [' num2str(o2(1)) ' ' num2str(o2(2)) ' ' num2str(o2(3)) '] )'];
axis([oxmin oxmax oymin oymax]); xlabel(oxlab); ylabel(oylab);
axes(XYAxes); xlabel('Qx (Å-1)'); ylabel('Qy (Å-1)');
[proj,sec]=project(RMS,3);   
PlotEllipse(proj,qx,qy,Style1);
PlotEllipse(sec,qx,qy,Style2);


h=gcf;
pos=get(h,'Position');
set(h,'Position',[pos(1), pos(2)+pos(4)-480,640,480]);

XWidth=fproject (RMS,1);
YWidth=fproject (RMS,2);
WWidth=fproject (RMS,3);
ZWidth=sqrt(2*log(2))./sqrt(RMS(4,4,:));

XBWidth=sqrt(2*log(2))./sqrt(RMS(1,1,:));
YBWidth=sqrt(2*log(2))./sqrt(RMS(2,2,:));
WBWidth=sqrt(2*log(2))./sqrt(RMS(3,3,:));


ResVol=(2*pi)^2/sqrt(det(RMS(:,:,center)));




TextAxis=axes('position',TextAxesPosition,'Visible','off');
text(0.0,0.97,['Scan center (point # ',int2str(center),'):']);
txt=['H=', num2str(H(center),4),'  K=', num2str(K(center),4),' L=', num2str(L(center),4),'  E=', num2str(W(center),4),' meV'];
text(0.05,0.9,txt);
text(0.0,0.8,'Projections on principal axes (FWHM):');
txt=['Qx: ', num2str(XWidth(center)*2,4),' Å-1   Qy: ', num2str(YWidth(center)*2,4),' Å-1    Qz: ', num2str(ZWidth(center)*2,4),' Å-1' ];text(0.05,0.73,txt);
txt=['E: ', num2str(WWidth(center)*2,4),' meV'];text(0.05,0.64,txt);
text(0.0,0.55,'Bragg widths (FWHM):');
txt=['Qx: ', num2str(XBWidth(center)*2,4),' Å-1   Qy: ', num2str(YBWidth(center)*2,4),' Å-1   E: ', num2str(WBWidth(center)*2,4),' meV'];
text(0.05,0.48,txt);
text(0.0,0.4,'Resolution volume:');
txt=[num2str(ResVol*2,5),' meV/Å3'];
text(0.05,0.33,txt);
text(0.0,0.25,'Intensity prefactor');
txt=['R0= ',num2str(R0(center),5)];
text(0.05,0.18,txt);





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

%========================================================================================================
%========================================================================================================
%========================================================================================================

function PlotEllipse(mat,x0,y0,style)
[a,b,c]=size(mat);
phi=0:2*pi/3000:2*pi;
for i=1:c
   r=sqrt(2*log(2)./(mat(1,1,i)*cos(phi).^2+mat(2,2,i)*sin(phi).^2+2*mat(1,2,i)*cos(phi).*sin(phi)));
   x=r.*cos(phi)+x0(i);
   y=r.*sin(phi)+y0(i);
   hold on; plot(x,y,style);
end;

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
%========================================================================================================
