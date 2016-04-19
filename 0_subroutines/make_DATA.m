function DATA=make_DATA(PAR);
% DATA=make_DATA(INFO);
%	Generates minimal required fields for DATA structure

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

DATA.eng=[INFO.e_min : INFO.e_step : INFO.e_max]'; % column
DATA.int = zeros(size(DATA.eng));
DATA.linewidths=[];
DATA.mask=[];

