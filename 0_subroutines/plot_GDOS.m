function plot_GDOS(PAR);
% plot_GDOS(PAR);
%	Plot generalized density-of-states as calculated by anapert or phonopy.

if ~isfield(PAR,'DOS');
	error(' DOS field not present.  Has it been calculated?');
end

energy=PAR.DOS.energy;
gdos=PAR.DOS.gdos;

% ===  plot, set title, prettify ===
hold off;
fh=plot(energy,gdos);
fa=gca;
plot_pretty(PAR,fh,fa,'gdos');

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
