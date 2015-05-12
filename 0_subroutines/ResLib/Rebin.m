function [yb,dyb,varargout]=Rebin(y,dy,varargin)
%===================================================================================
%  function [yb,dyb,x1b,x2b...]=Rebin(y,dy,x1,x2,...,[b1,b2...])
%  ResLib v.3.4
%===================================================================================
%
%  Simple re-binning of statistical data. Vector y is the data set (dependent variable), 
%  vector dy contains the standard deviations (error bars), vector x1,... are the dependent 
%  variables, and b1,.. are the bin sizes for each independent variable. All vectors
%  must be of the same length or scalars.
%
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%====================================================================================


M=length(varargin)-1;  
if M<0 error('Error: At least one independent variable is required'); end;
if M<1 error('Error: Bin size required.'); end;
tol=varargin{end};
if ~(length(tol)==M) error('Error: Bin dimension must match number of independent variables.'); end;
indep=deal(varargin(1:M));

lengths=zeros(1,M);
for ind=1:M
    indep{ind}=indep{ind}(:)';
    lengths(ind)=length(indep{ind});
end
N=max([lengths,length(y),length(dy)]);
if (N<1), error('Error: No data!'); end;

bad=find(lengths==1);
for ind=1:length(bad)
    indep{bad(ind)}=repmat(indep{bad(ind)}(1),1,N);
    lengths(bad(ind))=N;
end


if ~isempty(find(lengths<N)), error('Error: All independent variables must have the same lengths.'); end;
if ~(length(y)==N)|~(length(dy)==N), error('Error: Dependent variables, standard deviations and intependent variables must be all of the same length.'); end;

N=length(indep{1});

yb=y(1);
dyb=dy(1);
for j=1:M
    varargout{j}=indep{j}(1);
end


for ind=2:N,
    test=ones(1,length(varargout{1}));
        for j=1:M,
             test=test & ( abs(varargout{j}-indep{j}(ind))<=tol(j));
        end
        close=find(test);
        if isempty(close)
            for j=1:M,
                varargout{j}=[varargout{j} indep{j}(ind)];
            end
            yb=[yb y(ind)];
            dyb=[dyb dy(ind)];
        else
            close=close(1);
            denom=1/dyb(close)^2+1/dy(ind)^2;
            yb(close)=(yb(close)/dyb(close)^2+y(ind)/dy(ind)^2)/denom;
            dyb(close)=1/sqrt(denom);
        end;
end;
