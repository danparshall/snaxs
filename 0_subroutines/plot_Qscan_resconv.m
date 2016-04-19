function plot_Qscan_resconv(PAR,convolution);

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
hold off;

[unique_tau, cellarray_qs, Q_hkl, Q_delta]=generate_tau_q_from_Q(PAR);

int=convolution;
del=Q_delta;
[maxval,maxidx]=max(abs(del));
Q_array= DATA.Q_hkl(:,maxidx);


% === plot with markers for phonon centers ===
%if PLOT.markers
%    if PLOT.semilog
%        semilogy(Q_array, int, centers, heights, '*');
%    else % === linear plotting ===
%        plot(Q_array, int, centers, heights, '*');
%    end

% === plot without markers for phonon centers ===
%else
    if PLOT.semilog
        semilogy(Q_array, int,'*-');
    else % plot linear
        plot(Q_array, int,'*-');
    end
%end

% === set axis limits for semilog plots (could do linear later) ===
%	this is because when plotting semilog, a tiny residual intensity
%	can skew the whole graph.
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

% === add labels, etc ===

if maxidx==1
	dir='H';
elseif maxidx==2;
	dir='K';
elseif maxidx==3;
	dir='L';
else
	warning(' Scan direction not known');
end

hTitle  = title (['E = ' num2str(INFO.E_const) ' meV ' ]);
hXLabel = xlabel([ dir ' (r.l.u.)']);
hYLabel = ylabel('Intensity (arb. units)');

%set( gca                       , ...
%    'FontName'   , 'Helvetica' );
%set([hTitle hXLabel hYLabel], ...
%    'FontName'   , 'AvantGarde');
%set([hLegend, gca]             , ...
%    'FontSize'   , 8           );
set([hXLabel hYLabel]  , ...
	'FontSize'   , 18          );
set( hTitle                    , ...
	'FontSize'   , 22          , ...
	'FontWeight' , 'bold'      );
set(gca						, ...
	'FontSize'	,	12			);

