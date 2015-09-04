function VECS=make_STRUFAC(PAR,Q_hkl,vecs);
% VECS=make_STRUFAC(PAR,Q_hkl,vecs, varargin);
%	Generate STRUFAC (structure factor) structure.
%	Q_hkl is Nq x 3
%	'vecs' input is optional override, otherwise calculates STRUFAC from VECS
% 	STRUFAC.qs is 2D matrix (Nq x 3), has h,k,l for each of the Nq rows
%	STRUFAC.strufac is 2D matrix (N_modes x Nq)
%
%	For backwards compatibility, there is also STRUFAC.data, but it will be deprecated
% 	STRUFAC.data is 3D matrix (N_modes x 2 x Nq) with Nq pages, each page has 
%	energy and intensity for each of the N_modes rows
%
% 	This normalizes strufac to 100 (like anapert).

% Cross-section for one-phonon coherent scattering can be found in:
%	Squires, Introduction to the theory of thermal neutron scattering, Eqn 3.120
%
% The structure factor term (which is calculated here) is contained within the
% magnitude bars (ignoring the Debeye-Waller factor).  In Squires, it is:
%	sumon_d (b_d/sqrt(M_d)) * exp(i K.d) * (K.eig_ds)
% where b_d is cross section for each atom, M_d is mass for each atom
% d is the position of each atom, K is the momentum transfer Q, and eig_ds
% is the polarization vector.
%
% The code below is closely based on Rolf Heid's "print_strufa" subroutine, from
% forcon.f90.  The basic equation used is:
%	cs = sum_k scat_k/sqrt(m_k) * exp(-i tau R_k) * (q+tau)*z_k
% where z_k is the complex displacement of the k_th atom
%
% I tested carefully by comparing the results output from this routine, to the
% results coming from anapert.  They agreed for multiple ANALYSIS_DATA files and
% along all directions tested.  Also agrees when using phonopy, and compared to
% experimental data on silicon. 
%
% So while it's a huge mess of indexing, I'm confident in the results, and thus:
%
% /* you are not expected to understand this */
%

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
N_atom=XTAL.N_atom;
Nq = size(Q_hkl,1);
N_modes=3*N_atom;

atom_kind=cell(N_atom,1);
for ind_at=1:N_atom
	atom_kind{ind_at}= XTAL.atom_types{XTAL.atom_kind(ind_at)};
end


%%%%%%%%%%%%%%
% generate cdis (complex polarization vector)
if ~exist('vecs')
	% vecs is organized (3dir*N_atom, Nq, Nmodes)
	vecs=VECS.vecs;
end

if size(vecs,2)~=Nq;
	error(' Dimensions of "vecs" and "Q_hkl" are inconsistent.');
end

size(vecs)
%%%%%%%%%%%
%% common to all Q (fac is prefactor which normalizes sum to 100)
scatt = [];
mass = [];
for ind_at=1:N_atom
	scatt = [scatt; str2num(get_xsect_neutron(atom_kind{ind_at}))];
	mass = [mass; get_mass(atom_kind{ind_at})];
end
fac=100/sum(scatt.^2./mass);


%%%%%%%%%%
% here we calculate exp(-i tau R_k)
Qprm=calc_cnv_to_prm(XTAL, Q_hkl, EXP);
tau=round(Qprm);					% Nq x 3
taumat=reshape(tau,[1 Nq 3]);
taumat=repmat(taumat,[N_atom 1 1]);	% N_atom x Nq x 3

atoms=XTAL.atom_position;
atoms=reshape(atoms, [N_atom 1 3]);
atoms=repmat(atoms,[1 Nq 1]);

% good place to include scatt/mass term 
cfac=exp(-2*i*pi*dot(taumat,atoms,3)) .*repmat(scatt./sqrt(mass),[1 Nq]); % N_at x N_q
cfac=repmat(cfac,[1 1 N_modes]); % cfac same for all modes. (N_at x Nq x N_modes)


%%%%%%%%%%%%
%% calculate (q+tau)*z_k (that is, Q.eig)
% vecs is 3*Natom x Nq x Nmodes
% for each atom, take Q.eig, then sum contribution from each atom

% Qc is cartesian directions, but for non-cubic systems in different from Q_hkl
Qc=Qprm*XTAL.basis_recip;			% Nq x 3
Qc_mat=repmat(Qc',[1 1 N_modes]);	% 3 x Nq x N_modes

pol=zeros(N_atom, Nq, N_modes);
for ind_at=1:N_atom
	xyz= 3*ind_at +[-2 -1 0];	% indices for xyz disp of atom
	pol(ind_at,:,:)=dot(Qc_mat,vecs(xyz,:,:),1); % must use Q.vec; vec.Q can cause change of sign for imaginary component.
end


%%%%%%%%%%%%
% now combine all terms, starting with complex structure factor cs:
cs=pol.*cfac;	% N_atom rows, Nq cols, N_modes pages
cs=sum(cs,1);	% sum contribution from all atoms. (1 x Nq x N_modes)
cs=reshape(cs, [Nq N_modes])';	% with transpose, reshapes to (N_modes x Nq)


% take magnitude of cs, normalize by Q^2 and fac
Qc2=sum(Qc.^2,2);					% Nq x 1
strufac= cs .* conj(cs) .* repmat(1./Qc2',N_modes,1) *fac;


%%% OUTPUT %%%
VECS.strufac=strufac;
VECS.qs=Qprm;


% this is for backwards compatibility.  Should update all routines to use
% STRUFAC.strufac and VECS.energies
dataE=reshape(VECS.energies, [N_modes 1 Nq] );
dataI=reshape(strufac, [N_modes 1 Nq] );
VECS.strufac_data=[dataE dataI];

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
