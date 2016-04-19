function PAR=plot_Qscan(PAR);
% PAR=plot_Qscan(PAR);
%	Given a PAR structure, identify (crudely) the direction of the Q-scan, and
%	plot.  
%
%	Future improvements would have:
%		points for estimated phonon centers
%		better handling of Q direction (i.e., show [HH0] instead of just H)


[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
hold off;

% === identify E_const line of SQE_array by finding eng closest to E_const ===
[dval,eng_index]=min(abs(DATA.eng - INFO.E_const));
INFO.E_const=DATA.eng(eng_index);
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);


%% === scan direction ===
delta = find(DATA.Q_delta,1,'first'); % returns index of first changing direction
Q_pts=DATA.Q_hkl(:,delta);


%% === plot linescan with points ===
int=DATA.SQE_array(eng_index, :); 
int = int(:);
if PLOT.semilog
    fh=semilogy(Q_pts, int,'*-');
else % plot linear
    fh=plot(Q_pts, int,'*-');
end
fa=gca;


%% === set intensity axis limits for semilog plots  ===
%	this is because a tiny residual intensity can skew the whole graph.
if PLOT.semilog
	vec=axis; % vec(3) and vec(4) are ymin and ymax

	% set upper bound of graph
	vec(4)=10^ceil(log10(max(int)));

	% set lower bound of graph
	if log10(vec(4)/vec(3))>PLOT.decades
		vec(3)=vec(4)/10^PLOT.decades;
	end

	axis(vec);
end

%% === add labels, etc ===
set(gcf,'name','Q-scan');
plot_pretty(PAR,fh,fa,'qscan');

