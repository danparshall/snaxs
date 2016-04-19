function [Q_mag, Q_prm]=calc_Q_ang_cnv(XTAL, cnv, EXP);
% [Q_mag, Q_prm]=calc_Q_ang_cnv(XTAL, cnv, EXP);
%	Given a Q-point in conventional units, return the magnitude of Q in 
%	inverse Angstroms, along with the location of the Q-point in primitive
%	coordinates (which is calculated in "calc_Q_ang_prm").
%	cnv must be Nx3. Q_mag is Nx1 vector, Q_prm is Nx3

if size(cnv,2) ~= 3;
	error(' Input "cnv" must be 3-column')
end

Q_prm=calc_cnv_to_prm(XTAL, cnv, EXP);
Q_mag=calc_Q_ang_prm(XTAL, Q_prm);

