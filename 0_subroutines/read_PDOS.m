function PAR=read_PDOS(PAR,DOS);
% PAR=read_PDOS(PAR);
%	Reads the partial density-of-states file (whether from phonopy or anapert).
%	Multiplies pDOS from each atom by the cross-section/mass factor to produce
%	generalized DOS as measured in experiment.

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

%% === throw error if file not found (or calc_method unknown) ===
if strcmp(XTAL.calc_method,'phonopy');
	if ~exist('partial_dos.dat','file')
		error(' The partial_das.dot file could not be found. Possibly an error with the phonopy binary.');
		end
elseif strcmp(XTAL.calc_method,'anapert')
	if ~exist('P_DOS','file');
		error(' The P_DOS file could not be found. Possibly an error with the anapert binary.');
		end
else
	error(' Calculation method unknown.');
	end


%% === phonopy returns 1 + N_atom columns (energy plus each individual atom)
%	   Must combine like atoms to produce DOS, and scale by xsec/mass factor
if strcmp(XTAL.calc_method,'phonopy')
	rawtext=fileread('partial_dos.dat');
	endline=regexp(rawtext,'\n','once');
	pdos=str2num(rawtext(endline+1 : end));

	THz2meV = 4.13567;			%phonopy uses THz for energy, we want meV
	energy=pdos(:,1) * THz2meV;	% first col is energy, others are partials
	pdos=pdos(:,[2:end]);		% remove energy, leave only partials

	gdos=zeros(length(energy), XTAL.N_type+1); % first col is total
	gdos(:,1)=sum(pdos,2);					% first col is total		

	for ind=1:XTAL.N_type
		indAtom=find(XTAL.atom_kind==ind);	   % find all atoms of this type
		gdos(:,ind+1)=sum(pdos(:,indAtom),2);  % sum contributions from this atom
		end
	pdos=gdos;		% now that atoms are summed


%% === anapert returns 1 + N_type columns (energy plus each type)
elseif strcmp(XTAL.calc_method,'anapert')
	pdos=load('P_DOS');
	gdos=pdos(:,[2:end]);	% gdos first col is total, others are partials
	energy=pdos(:,1);
	pdos=pdos(:,[3:end]);	% cut out cols with energy and tot, keep partials
end


%% === generalize by scaling factor ===
xsect = str2num(PAR.XTAL.scatt_xsect);	% looked up during init_XTAL, good for neutron or x-ray
for ind=1:XTAL.N_type
	mass=get_mass(XTAL.atom_types{ind});
	gdos(:,ind+1)=gdos(:,ind+1) * xsect(ind) / mass;
	end

gdos(:,1)=sum(gdos(:,[2:end]),2);	% recalculate sum, following scaling


%% === normalize ===
norm=sum(gdos(:,1));
gdos=gdos./norm;
gdos=gdos/INFO.e_step;

%% === update ===
DOS.pdos=pdos;
DOS.gdos=gdos;
DOS.energy=energy;
PAR.DOS=DOS;

