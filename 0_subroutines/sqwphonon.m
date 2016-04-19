function [w0,S,HWHM]=sqwphonon(H,K,L,PAR);
% [w0,S,HWHM]=sqwphonon(H,K,L,PAR);
%	Function defined as per ResLib's convolution requirement.  For each HKL
%	this will return centers and heights of all phonons (based upon structure 
%	factor).  Presumes that HKL are all the same length. 
%	Outputs all have size Nmodes x Nq
%
%	Allows phonon energies to be rescaled using PAR.rescale.  This is a hack for
%	the time being, but it works

Q_hkl=[H(:), K(:), L(:)];

PAR=simulate_multiQ(PAR, Q_hkl);
S=calc_height_multiQ(PAR, Q_hkl);
w0=PAR.VECS.energies;
HWHM=PAR.VECS.phWidths;

if isfield(PAR,'rescale_energy')
	rescale_energy=PAR.rescale_energy;	% multiply phonon energies by this factor
	VECS.energies = VECS.energies * rescale_energy;
end

if isfield(PAR.VECS,'phWidths')
	HWHM=PAR.VECS.phWidths;
end


% multiply phonon heights by rescaling factor if present
PAR.rescale_height=300;
if isfield(PAR,'rescale_height')
	S= S * PAR.rescale_height;
else
	disp(' Rescaling by default factor of 2000')
	S= S * 2000;
end

if length(find(S==0)) == numel(S)
	disp(' WARNING in "sqwphonon" : no intensity.');
end

toc

