function [pa,dpa,chisqN,sim,CN,PQ,nit,kvg,details]=...
   FitConvSMA(H,K,L,W,EXP,Iobs,dIobs,sqw,pref,pa,ia,METHOD, ACCURACY,nitmax,tol,dtol)
%==================================================================================
%  function [pa,dpa,chisqN,sim,CN,PQ,nit,kvg,details]=...
%   FitConvSMA(H,K,L,W,EXP,Iobs,dIobs,sqw,pref,pa,ia,METHOD, ACCURACY,nitmax,tol,dtol)
%
%  ResLib v.3.4
%==================================================================================
% Fit a user-supplied parametrized model SMA cross section function convoluted with the
% spectrometer resolution function to experimental 3-axis data. Levenberg-Marquardt 
% least squares algorithm is used. See NR 15.5. The current version does not support
% analytic derivatives.
%
%
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%=====================================================================================




%----------------------------------------------------------------------------------------------------------------
% check defaults and initial conditions
tic;
global GLOBAL_FUNCOUNT____
GLOBAL_FUNCOUNT____=0;
[len,H,K,L,W,EXP,Iobs]=CleanArgs(H,K,L,W,EXP,Iobs);
if isempty(dIobs), dIobs=ones(size(H)); end;
dIobs=dIobs(:)';
if ~(len==length(dIobs)) error('Fata error: size mismatch between H,K,L,W or EXP and dIobs'); end; 
if isempty(ia) ,ia=ones(1,length(pa)); end;
   
if (nargin < 12 | isempty(METHOD)), METHOD='fix2'; end %warning('Using default "fix2" integration method'); end;
if (nargin < 13 | isempty(ACCURACY)), ACCURACY=[7 0]; end %warning('Using default density of point sampling: ACCURACY=[7 0]'); end; 
if (nargin < 14 | isempty(nitmax)), nitmax=20; end %warning('Using default limit on number of iterations: nitmax=20'); end; 
if (nargin < 15 | isempty(tol)), tol=0.001; end %warning('Using default tolerance: tol=0.001'); end; 
if (nargin < 16 | isempty(dtol)), dtol=1e-5; end %warning('Using default tolerance: dtol=1e-5'); end;


dpa=zeros(size(ia)); %default error is zero (applies to fixed parameters)
ivar=find(ia); %list of elements corresponding to varying parameters
DF=length(Iobs)-length(ivar); % degrees of freedom
lamda = 0.001; % initial Marquardt parameter
nit=0; % initial number of iterations
chisq_old=realmax; %initial chisq_old huge to ensure iteration

dispia=(ia>0);
fprintf('Fitting ''%s'' to %d data using %d free and %d fixed parameters.\n',sqw,length(Iobs),sum(dispia), length(pa)-sum(dispia)); 
fprintf('\n');

%----------------------------------------------------------------------------------------------------------------
[chisq,alpha,beta]=marqit(H,K,L,W,EXP,Iobs,dIobs,sqw,pref,pa,ivar,METHOD,ACCURACY,tol,dtol);
disp ('Iteration #   FunCount         chi^2        lambda          time');
% begin iterations
while (abs(chisq_old-chisq)> tol*chisq)
   if (nit >=nitmax),break,end 
        dpa(ivar)=(alpha+lamda*diag(diag(alpha)))\beta(:); 
        pt=pa+dpa; % new trial parameters
    [chisq_trial]=marqit(H,K,L,W,EXP,Iobs,dIobs,sqw,pref,pt,ivar,METHOD,ACCURACY,tol,dtol);% get trial chi_squared
   if (chisq_trial > chisq) % chisq increases ?
      lamda=10*lamda; % increase lamda and try again
      if(lamda > 1e13),chisq_old=chisq;end %punt if lamda is stuck beyond reason
   else %chisq decreased
        chisq_old=chisq; %update old chi-squared
        lamda=lamda/10; %decrease lamda
        pa=pt; % update parameters
        nit=nit+1; % call it an iteration
        [chisq,alpha,beta]=marqit(H,K,L,W,EXP,Iobs,dIobs,sqw,pref,pa,ivar,METHOD,ACCURACY,tol,dtol); %recalculate alpha,beta,chi-squared
        fprintf(' %10d %10d %13g %13g %13.1f\n',nit,GLOBAL_FUNCOUNT____,chisq/DF,lamda,round(toc*10)/10);   
    end    
end 
%----------------------------------------------------------------------------------------------------------------
% check convergence:
if (nit >= nitmax | lamda > 1e13),kvg=0;
elseif (lamda > 0.001),kvg=2;
else kvg=1;
end
%----------------------------------------------------------------------------------------------------------------
% now that converged or kicked out calculate error quantities with lamda=0
C=inv(alpha); % raw correlation matrix
dpa(ivar)=sqrt(diag(C)); % error in a(j) is sqrt(Cjj)
chisqN=chisq/DF; %normalized chi-squared
CN=C./sqrt(abs(diag(C)*diag(C)')); % normalized correlation matrix C(ij)/sqrt[C(ii)*C(jj)]
if (nargout >=5),PQ=1-gammainc(chisq/2,DF/2); end
%----------------------------------------------------------------------------------------------------------------
if (nargout>=8)
    sim = ConvResSMA(sqw,pref,H,K,L,W,EXP,METHOD,ACCURACY,pa);
   GLOBAL_FUNCOUNT____=GLOBAL_FUNCOUNT____+1;
end;   
if (nargout==9),
    details = struct('chisq',1,'Ndata',1,'Npar',1,'Nvar',1,'DF',1,'C',1,'final_lamda',1,'yf',zeros(size(Iobs)));
    details.chisq=chisq; %raw chi-squared
    details.Ndata=length(Iobs); % number of data points
    details.Npar=length(pa); %total number of parameters
    details.Nvar=length(ivar); %number of parameters varied
    details.DF=DF; %degrees of freedom
    details.C=C; %raw covariance matrix
    details.final_lamda=lamda; %final value of lamda used in the fitting process
end
fprintf('\n');
if kvg==0 disp('Stop: max allowed number of iterations exceeded.'); end;
if kvg==1 disp(['Stop: Converged normally in ',int2str(nit),' iterations.']); end;
if kvg==2 disp('Stop: Convergence questionable.'); end;
fprintf('\n');
fprintf('Final parameters:\n');
for i=1:length(pa) fprintf('%10d %10g (%g)\n',i,pa(i),dpa(i)); end
%=================================================================================================================

function dfp=dfdp(H,K,L,W,EXP,Iobs,dIobs,sqw,pref,pa,ivar,METHOD,ACCURACY,dtol)
global GLOBAL_FUNCOUNT____
np=length(H);
dfp=zeros(np,length(ivar)); %preallocate space for dfdp as zeros
for n=1:length(ivar) %loop through varying parameters
   h=zeros(size(pa)); %initialize h
   t=pa(ivar(n))+dtol*pa(ivar(n));
   h(ivar(n))=t-pa(ivar(n)); 
   if(pa(ivar(n))==0),h(ivar(n))=1+1e-8-1;end %protect against zero values
   pa1=pa+h;
   pa2=pa-h;
   f1=ConvResSMA(sqw,pref,H,K,L,W,EXP,METHOD,ACCURACY,pa1);GLOBAL_FUNCOUNT____=GLOBAL_FUNCOUNT____+1;
   f2=ConvResSMA(sqw,pref,H,K,L,W,EXP,METHOD,ACCURACY,pa2);GLOBAL_FUNCOUNT____=GLOBAL_FUNCOUNT____+1;
   dfp(:,n)=(f1(:)-f2(:))/(2*h(ivar(n)));
end
%=================================================================================================================

function [chisq,alpha,beta] = marqit(H,K,L,W,EXP,Iobs,dIobs,sqw,pref,pa,ivar,METHOD,ACCURACY,tol,dtol)
global GLOBAL_FUNCOUNT____
   f=ConvResSMA(sqw,pref,H,K,L,W,EXP,METHOD,ACCURACY,pa); GLOBAL_FUNCOUNT____=GLOBAL_FUNCOUNT____+1;
   wdiff=(Iobs-f)./dIobs; %weighted difference
   chisq=sum(wdiff.^2); % chi_squared
   if  nargout==1, return; end;%only chisq requested
   dfp=dfdp(H,K,L,W,EXP,Iobs,dIobs,sqw,pref,pa,ivar,METHOD,ACCURACY,dtol);   
   NP=length(ivar);%number of varying parameters
   beta=sum(repmat(wdiff(:)./dIobs(:),1,NP).*dfp)';
   alpha=dfp./repmat(dIobs(:),1,NP); %normalize derivative by sigma
   alpha=alpha'*alpha; %product alpha'*alpha to get the correct sum
%=================================================================================================================
