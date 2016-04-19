function plot_SQW(PAR);
% plot_SQW(PAR)
%	Use imagesc to produce colorplot of S(q,w).  Includes energy and Q scales.
%	For Matlab, sets NaNs to be transparent.

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
hold off;

[maxval,maxidx]=max(abs(DATA.Q_delta));
Q_array= DATA.Q_hkl(:,maxidx);
eng = DATA.eng;


if ~isreal(DATA.SQE_array)
	warning(' SQE_array not real; error in calculation; taking real part of data.');
	DATA.SQE_array=real(DATA.SQE_array);
end


%% === generate figure, set visible status ===
if ~isempty(findobj('type','figure'))
	clf;
	fh = gcf;
else
	if PLOT.quiet
		fh = figure('visible','off');
	else
		fh = figure('visible','on');
	end
end


% === plot in linear or log scale ===
if PLOT.semilog
	logdat=log(DATA.SQE_array);
	mval=max(max(logdat));
	mins=mval-PLOT.decades;
	logdat(logdat < mins) = mins;
	fh = imagesc(Q_array, eng, logdat, [mval-PLOT.decades mval] );
else % plot linear
	fh = imagesc(Q_array, eng, DATA.SQE_array);
end
axis on
axis tight normal		% seems to be default in Matlab, useful in Octave
fa=gca;

% === plot NaNs in white on Matlab systems ===
if ~system_octave
	set(fa,'color',[1 1 1]);
	set(fh, 'AlphaData', ~isnan(DATA.SQE_array));
	if isunix
		disp('  NOTE : alpha setting screws up saving as .png on *nix.');
	end
end


%% === prettify ===
set(fa,'YDir','normal');
set(gcf,'name','Sqw');
colorbar;
plot_pretty(PAR,fh,fa,'sqw');

