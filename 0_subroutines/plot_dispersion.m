function plot_dispersion(PAR);
% plot_dispersion(PAR);
%	This is a hack; an advanced version would plot things based upon symmetry, 
%	include crossings, etc


[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

%% === determine direction / arrays ===
del=DATA.Q_delta;
[maxval,maxidx]=max(abs(del));
Q_array= DATA.Q_hkl(:,maxidx);
E_array= DATA.E_array;


%% === plot & prettify ===
hold off;
fh=plot(Q_array, VECS.energies', 'k-');	% make all lines black
fa=gca;
axis([min(Q_array) max(Q_array) min(E_array) max(E_array)]);
plot_pretty(PAR,fh,fa,'disp');

