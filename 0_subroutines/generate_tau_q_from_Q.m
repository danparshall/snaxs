function [unique_tau, cellarray_qs, Q_hkl, Q_delta]=generate_tau_q_from_Q(PAR,Q_hkl);
% [unique_tau, cellarray_qs, Q_hkl, Q_delta]=generate_tau_q_from_Q(PAR,Q_hkl)
%	Go from Q (user-friendly) to primitive q/tau (needed by anapert/phonopy) 
%	Q_hkl can be provided explicitly, but if not provided it is generated using 
%	make_graded_3vec(INFO.Q_max, INFO.Q_min, INFO.Q_npts)
%	
%	unique_tau is a (Ntau x 3) array
%
%	cellarray_qs has length(Ntau); each cell contains a chunk of qs.  The sum of
%	all rows of all cells is equal to Nrows(Q_hkl)
%
%	Q_hkl is the values used to calculate tau/q (whether assigned or generated)
%	
%	Q_delta is empty if Q_hkl was assigned.  Otherwise it is the step size used
%	to make Q_hkl

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

if ~exist('Q_hkl');
	% === Make Q_hkl array from start and step for each direction ===
	[Q_hkl,Q_delta]=make_graded_3vec(INFO.Q_max, INFO.Q_min, INFO.Q_npts);
else
	Q_delta=[];
end

%% === convert to primitive basis
[tau, q]=calc_tau_q(PAR, Q_hkl);


%% === iRecon allows reconstruction of original tau array
[unique_tau, iTau, iRecon] = unique(tau,'rows');


%% === for each value of tau, place the corresponding qs into a separate cell
nTau=size(unique_tau,1);
cellarray_qs= cell(nTau,1);
for ind=1:nTau
	cellarray_qs{ind}= q( iRecon==ind , :);
end

%% === for future reference / debugging ===
% the original values of tau/q can be generated (albeit out-of-order) via:
%recon=[];
%for ind=1:nTau;
%	qset=cellarray_qs{ind}
%	recon= [ recon; repmat(unique_tau(ind,:),size(qset,1),1) + cellarray_qs{ind}];
%end

