function [tau, q, Q_prm]=calc_tau_q(PAR, Q_hkl, varargin);
% [tau, q, Q_prm]=calc_tau_q(PAR, Q_hkl, varargin);
%	Generate tau and q of primitive lattice, given conventional Q
%	Q_hkl is optional value of Q in conventional basis, and must be (Nq x 3).  
%	If not given then it defaults to INFO.Q.
%
%	tau, q, and Qprm are all (Nq x 3) row vectors

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

if nargin < 2
	Q_hkl=INFO.Q;
end

if size(Q_hkl,2) ~= 3;
	error(' Input "Q_hkl" must be 3-column')
end

% === set tau / q in primitive basis ===
[Q_mag, Q_prm]=calc_Q_ang_cnv(XTAL, Q_hkl, EXP);
tau=round(Q_prm);
q=Q_prm-tau;

