function Q_mag=calc_Q_sample(XTAL, cnv, EXP);
% Q_mag=calc_Q_sample(XTAL, cnv, EXP);
%	Given a Q-point in conventional units, return the magnitude of Q in 
%	inverse Angstroms, calculated using the sample parameters given in the
%	EXP file.  For 'tas' setting, this is the same measurement used by ResLib, 
%	and prevents scattering triangle errors arising from discrepancies between
%	ResLib and SNAXS.  For other types, uses internal SNAXS code (so that a user
%	without ResLib can still simulate 'tof' and 'xray' experiments).
%	EXP input is required for all cases; XTAL is required when type is not 'tas'


if size(cnv,2) ~= 3;
	error(' Input "cnv" must be 3-column')
end

if strcmp(EXP.experiment_type,'tas');
	[lattice,rlattice]=GetLattice(EXP);
	Q_mag=modvec(cnv(:,1),cnv(:,2),cnv(:,3),rlattice);
else
	Q_mag=calc_Q_ang_cnv(XTAL, cnv, EXP);
end

