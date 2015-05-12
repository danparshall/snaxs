function tau=GetTau(x)
%===================================================================================
%  function TAU=GetTau(tau)
%  ResLib v.3.4
%===================================================================================
%
%  Tau-values for common monochromator crystals
%
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%====================================================================================
if isnumeric(x)
    tau = x;
else
    switch lower(x)
    case 'pg(002)', tau=1.87325;
    case 'pg(004)', tau=3.74650;
    case 'ge(111)', tau=1.92366;
    case 'ge(220)', tau=3.14131;
    case 'ge(311)', tau=3.68351;
    case 'be(002)', tau=3.50702;
    case 'pg(110)', tau=5.49806;
    end;
end;
