function plot_SQW(PAR);
% plot_SQW(PAR)
%	Use imagesc to produce colorplot of S(q,w).  Includes energy and Q scales.
%	For Matlab, sets NaNs to be transparent.

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
hold off;

[maxval,maxidx]=max(abs(DATA.Q_delta));
Q_array= DATA.Q_hkl(:,maxidx);
E_array= DATA.E_array;


if ~isreal(DATA.SQE_array)
	error(' SQE_array not real; error in calculation.\n Taking real part of data.');
	DATA.SQE_array=real(DATA.SQE_array);
end


if system_octave
	disp(' OCTAVE COLORMAP')

	% === plot in linear or log scale ===
	if PLOT.semilog
		logdat=log(DATA.SQE_array);
		mval=max(max(logdat));
		mins=mval-PLOT.decades;
		logdat(logdat < mins) = mins;
		fh=imagesc(Q_array, E_array, logdat, [mval-PLOT.decades mval] );
	else % plot linear
		fh=imagesc(Q_array, E_array, DATA.SQE_array);
	end
	axis on
	axis tight normal		% seems to be default in Matlab, useful in Octave
	fa=gca;

else
	disp(' MATLAB COLORMAP')

	% === Matlab allows setting alpha values (can make NaNs transparent)
	% === the NaNs are made transparent in imagesc2   ===
	% see http://stackoverflow.com/questions/8481324/contrasting-color-for-nans-in-imagesc

	% === plot in linear or log scale ===
	if PLOT.semilog
		logdat=log(DATA.SQE_array);
		mval=max(max(logdat));
		mins = mval - PLOT.decades;
		logdat(logdat < mins) = mins;
		fh=imagesc2(Q_array, E_array, logdat, [mval-PLOT.decades mval] );
	else % plot linear
		fh=imagesc2(Q_array, E_array, DATA.SQE_array);
	end
	axis on
	axis tight normal		% seems to be default in Matlab, useful in Octave
	fa=gca;

	% === set background color to white, for the NaNs ===
	set(fa,'color',[1 1 1]);
end

%% === prettify ===
set(fa,'YDir','normal');
set(gcf,'name','Sqw');
colorbar;
plot_pretty(PAR,fh,fa,'sqw');

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
