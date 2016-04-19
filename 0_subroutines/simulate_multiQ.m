function PAR=simulate_multiQ(PAR, Q_hkl);
% PAR=simulate_SQW(PAR);
%	For arbitrary list of Q-points, determines eigenvector / structure factor.
%	Loads that data into VECS
%	All other simulation routines (simulate_SQW, simulate_single, etc) call this

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

if isfield(XTAL,'calc_method')
	calc=XTAL.calc_method;
else
	error(' Calculation method not identified.');
end


%% === one call to calculation, getting only unique q (hence eigenvectors) ===
Qprm=calc_cnv_to_prm(XTAL, Q_hkl, EXP);
tau=round(Qprm);	% Nq x 3
q=Qprm-tau;			% Nq x3
tol=10;				% setting tolerance of q
q=round(q.*(10^tol))/(10^tol);
[unique_q,~,ind_q]=unique(q,'rows');	 % ind_q allows regeneration from unique


%% === call to calculation program, read data ===
%     PHONOPY
if strcmp(calc, 'phonopy')
	system_cleanup('phonopy');
	write_phonopy(PAR, unique_q);
	system_phonopy(PAR,'eigs');
	VECS=read_phonopy_VECS(PAR, unique_q);

%     ANAPERT
elseif strcmp(calc,'anapert')
	system_cleanup('anapert');
	write_anapert(PAR, unique_q);
	system_anapert(XTAL);
	VECS=read_anapert_VECS(PAR,unique_q);

else
	error(' Calculation method unknown.')
end


%% === expand unique q to full array ===
VECS.Q_points=VECS.Q_points(ind_q,:)+tau;
VECS.energies=VECS.energies(:,ind_q);
VECS.phWidths=VECS.phWidths(:,ind_q);
VECS.vecs=VECS.vecs(:,ind_q,:);
PAR.VECS=VECS;


%% === now calculate structure factor for VECS ===
VECS=make_STRUFAC(PAR,Q_hkl);					% only 10 ms for 200 Q-points
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);

