function outdata=force_pzero(indata);
% outdata=force_pzero(indata);
%	Forces all zeros to be positive.  Important for, e.g., writing filenames.

outdata=indata;
outdata(indata==0)=0;

