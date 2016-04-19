function plot_pretty(PAR,fh,fa,type);
% plot_pretty(PAR, fh,fa,type);
%	fh = figure handle
%	fa = figure axes
%	type = string indicating sqw, escan, qscan, etc


[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);


%% === E-scans ===
if strcmp(type, 'escan')
	Q=INFO.Q;
	hTitle  = title (fa, ['Q = [' num2str(Q(1)) ', ' num2str(Q(2)) ', ' num2str(Q(3)) ' ]' ]);
	hYLabel = ylabel(fa, 'Intensity (arb. units)');
	hXLabel = xlabel(fa, ' Energy (meV)');


%% === S(q,w) ===
elseif strcmp(type,'sqw')
	[maxval,maxidx]=max(abs(DATA.Q_delta));
	if maxidx==1
		dir='H';
	elseif maxidx==2;
		dir='K';
	elseif maxidx==3;
		dir='L';
	else
		warning(' Scan direction not determined');
	end

	hTitle  = title (fa, ' S(Q,\omega)');
	hXLabel = xlabel(fa, [ dir ' (r.l.u.)']);
	hYLabel = ylabel(fa, ' Energy (meV)');


%% === Q-scans ===
elseif strcmp(type,'qscan')
	[maxval,maxidx]=max(abs(DATA.Q_delta));
	if maxidx==1
		dir='H';
	elseif maxidx==2;
		dir='K';
	elseif maxidx==3;
		dir='L';
	else
		warning(' Scan direction not determined');
	end

	hTitle  = title (fa, ['E = ' num2str(INFO.E_const) ' meV ' ]);
	hXLabel = xlabel(fa, [ dir ' (r.l.u.)']);
	hYLabel = ylabel(fa, 'Intensity (arb. units)');


%% === dispersion ===
elseif strcmp(type, 'disp');
	[maxval,maxidx]=max(abs(DATA.Q_delta));
	if maxidx==1
		dir='H';
	elseif maxidx==2;
		dir='K';
	elseif maxidx==3;
		dir='L';
	else
		warning(' Scan direction not determined');
	end
	hTitle  = title (' Dispersion');
	hXLabel = xlabel([ dir ' (r.l.u.)']);
	hYLabel = ylabel(' Energy (meV)');


%% === g-DOS ===
elseif strcmp(type, 'gdos')

	vec=axis;
	vec(1)=INFO.e_min;
	vec(2)=INFO.e_max;
	axis(vec);

	labels{1}='Total';
	labels= [labels XTAL.atom_types];
	titlestr=['Generalized Density-Of-States' ];
	
	hTitle  = title(titlestr);
	hYLabel = ylabel('Phonon DOS (states/meV)');
	hXLabel = xlabel(' Energy (meV)');

	[hLeg, hObj, hOut ] =legend(labels);
	set(hLeg, 'fontsize', 24)
	set(hObj, 'linewidth', 2)
	set(hOut, 'linewidth', 2)

%% === error ===
else
	warning(' Plot type unknown');
end % match on type


%% === set values for font, size, etc ===

%set( gca                       , ...
%    'FontName'   , 'Helvetica' );
%set([hTitle hXLabel hYLabel], ...
%    'FontName'   , 'AvantGarde');

set( [hXLabel hYLabel]  , ...
	'FontSize'   , 18 );

set( hTitle                    , ...
	'FontSize'   , 30          , ... 	
	'FontWeight' , 'bold'      );

set(fa						, ...
	'FontSize'	,	14			);


%% === update drawing ===
pause(0.1);
refresh;

