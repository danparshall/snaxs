function fixres=display_time_estimate(Npts, INFO);
% fixres=display_time_estimate(Npts, INFO);
%	This function estimates the time to calculate a resolution-convolved scan.
% 	INFO.timescale is number of seconds to call a calculation 1000 times. 
%	This is machine-dependent, and should be set by the user for best accuracy.
%	Value can be set in DEFAULTS.m, as INFO.timescale.
%
% 	So if PLOT.accuracy=1, method='mc', and Npts=21, a scan should take
%   	T = INFO.timescale * 1 * 21 seconds to complete
%	If the convolution method is 'fixed', then this function also selects values
%	acc1 and acc2 for the in- and out-of-plane grid, such that the overall time 
%	to calculate the full scan is around half the time if the method were 'mc'.

fixres=[];
estime=[];

if strcmp(INFO.convmethod,'fixed');

	if 1
		% fixed assignment from INFO.accuracy to in-plane/out-of-plane values
		% These are set so to be fairly close to 500 calls per scan point
%		a1=4+round(abs(INFO.accuracy));							% in-plane
%		a2=abs(floor(((500*INFO.accuracy/(2*a1+1)^2 )-1)/2));	% out-of-plane
		cbrt=(INFO.accuracy*1000/14)^(1/3);
		acc1=round(cbrt);
		acc2=round(0.666*cbrt);	% out-of-plane
	else
		% for testing purposes.  Means 3*3*3=27 calls per point
		disp(' NOTE in "display_time_estimate" : using override/testing values')

		if INFO.accuracy==0;
			acc1=0; acc2=0;	% should be more accurate version of generic Q_scan
		else
			acc1=1; acc2=1;
		end
	end

	Ncalc=(2*acc1 + 1)^2 * (2*acc2 + 1);	% should be close to 500*Accuracy

	estime= Ncalc/1000 * Npts * INFO.timescale /60;

	fixres=[acc1 acc2];
	fixstr=make_string_vector(fixres);

	disp([' Fixed-grid resolution set to : ' fixstr]);


elseif strcmp(INFO.convmethod,'mc');
	% By definition, Accuracy=1000 calls per scan point when using montecarlo
	estime= INFO.accuracy * Npts * INFO.timescale /60;

else
	error(' Method must be "mc" or "fixed"');
	return;
end

disp(' ')
disp(' Given these parameters:');
disp(['   Method : ' INFO.convmethod ]);
disp(['   Number of points : ' num2str(Npts) ]);
disp(['   INFO.timescale : ' num2str(INFO.timescale) ]);
disp(['   Accuracy : ' num2str(INFO.accuracy) ]);
disp(['   This convolution will take ~' num2str(round(estime)) ' minutes to complete']);

if estime > 600
	disp('     You look tired, go home and get some rest!');
elseif estime > 120
	disp('     That''s plenty of time for dinner.');
elseif estime > 10
	disp('     You probably have time for coffee.');
end

