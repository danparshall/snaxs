function write_PAR(PAR)
% write_PAR(PAR)
%	Save the current PAR structure to file.

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

filename=[ 'PAR_' datestr(now,30) '.mat'];
disp(['  Saving to "' filename '"']);

save(filename, '-struct','PAR');	% this should save the fields of PAR

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
