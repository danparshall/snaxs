function PAR=plot_Escan(PAR);
% PAR=plot_Escan(PAR);
% 	Plot 2D data in system-dependent way
% 	Structure PLOT contains information about display of plot itself

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

eng=DATA.eng;
int=DATA.int;
centers=DATA.centers;
heights=DATA.heights;

%% === plot profile ===
hold off;
if PLOT.semilog
    fh=semilogy(eng, int, 'linewidth', 3);
else % plot linear
    fh=plot(eng, int, 'linewidth', 3);
end


%% === plot markers === 
if PLOT.markers
	hold on;
	if system_octave;
		plot(centers, heights, '.', 'markers', 12, 'color', 'red');
	else
		plot(centers, heights, 'o', 'markers', 6, 'color', 'red', 'markerfacecolor', 'red');
	end
	hold off;
end
fa=gca;


% === set intensity axis limits for semilog plots  ===
%	this is because a tiny residual intensity can skew the whole graph.
if PLOT.semilog
	vec=axis; % vec(3) and vec(4) are ymin and ymax

	% set upper bound of graph
	vec(4)=10^ceil(log10(max(int)));

	% set lower bound of graph
	if log10(vec(4)/vec(3))>PLOT.decades
		vec(3)=vec(4)/10^PLOT.decades;
		axis(vec);
	end
end


%% === set energy scale, prettify ===
vec=axis;
vec(1)=INFO.e_min;
vec(2)=INFO.e_max;
axis(vec);

set(gcf,'name','E-scan');
plot_pretty(PAR,fh,fa,'escan');

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
