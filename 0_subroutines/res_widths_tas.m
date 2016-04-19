function [res_width,PAR]=res_widths_tas(PAR)
% [res_width,PAR]=res_widths_tas(PAR)
% 	Calculate resolution width for TAS using ResLib.  Includes scaling of height
%	by the Cooper-Nathans prefactor.

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
len=length(DATA.centers);

[R0,RMS]=ResMatS(INFO.Q(1), INFO.Q(2), INFO.Q(3), DATA.centers, EXP);

DATA.heights=DATA.heights .* R0';	% include Cooper-Nathans prefactor

resmatcol=zeros(len,1);
resmatcol(:)=RMS(3,3,:);	% 3,3 is HWHM energy resolution for given energy
res_width=sqrt(2*log(2)./resmatcol);

if ~isreal(res_width);
	warning(' Scattering triangle imaginary for some phonons.');
	ratio=imag(res_width)./real(res_width);
	
	disp([' Max imag/real ratio is ' num2str(max(ratio)) ])
	res_width=real(res_width);
end

PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);

