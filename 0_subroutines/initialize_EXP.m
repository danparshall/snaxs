function [PAR,pass]=initialize_EXP(PAR)
% [PAR,pass]=initialize_EXP(PAR)
% 	Check that EXP is a structure.  Warns the user of most likely error if not.
%	Performs a series of sanity checks, sets default values as appropriate.
%	Returns updated PAR structure, as well as the "pass" Boolean
%
% 	Confirms:
%		EXP is a structure
%		experiment type
%			- neutrons must list fixed energy
%			- x-rays must have resolution and max_Q
%		lattice consts
%			- sample.a must be defined, others can default to that
%		lattice angles
%			- default to 90 degrees
%		user basis
%			- default to eye(3) 


% normal input is PAR, but if EXP is received, use it
if isfield(PAR,'EXP')
	EXP=PAR.EXP;	% get EXP from PAR
else
	EXP=PAR;		% since EXP wasn't a field, the input must have been EXP
end


%pass=1;
disp(' Checking the EXP structure ...');

%% === proceed if this is a structure ===
if isstruct(EXP)
	EXP.title='Parameters for a particular experimental configuration.';

	%% === validate experiment type ===
	if ~isfield(EXP,'experiment_type')
		EXP.experiment_type = 'tas';
		disp(' Using default experiment type (tas)');
	end

	exp_type=EXP.experiment_type;
	isTas = strcmp(exp_type,'tas');
	isTof = strcmp(exp_type,'tof');
	isXray = strcmp(exp_type,'xray');

	if ~isTas && ~isTof && ~isXray
%		error(" EXP.experiment_type must be either 'tas', 'tof', or 'xray'.");
		pass=0;
	end

	disp(['     The experiment type is: ' EXP.experiment_type]);


	%% === check experiment-dependent fields ===
	if strcmp(EXP.experiment_type,'xray')	% if this is x-ray experiment

		% confirm xray_res is a number > 0
		if isfield(EXP,'xray_res')
			if isnumeric(EXP.xray_res);
				res = EXP.xray_res > 0;
			end
		end

		% confirm instrument_Qmax is a number > 0
		if isfield(EXP,'instrument_Qmax')
			if isnumeric(EXP.instrument_Qmax);
				Qmax = EXP.instrument_Qmax > 0;
			end
		end

		% generate warning
		pass = res & Qmax;
		if ~pass; 
			warning('      ... failed x-ray check'); 
		end
		if ~res;
			error(' EXP.xray_res must be a number greater than 0.');
		end
		if ~Qmax;
			error(' EXP.instrument_Qmax must be a number greater than 0.');
		end


	else	% if this is neutron experiment

		% confirm efixed is a number greater than 0
		if isfield(EXP,'efixed');
			if isnumeric(EXP.efixed);
				eFixed = EXP.efixed > 0;
			end
		end

		% check fixed energy
		if ~isfield(EXP,'infin');
			EXP.infin=1;	% default
			infin = 1;
		else
			infin = sign(EXP.infin+eps); % in case the user puts something crazy
		end

		if ~exist('eFixed'); 
			error(' Failed neutron check; which energy is fixed?'); 
		end

		pass = infin & eFixed;

	end % experiment_type



	%% === check lattice constants ===
	if ~isfield(EXP.sample,'a')
		pass=0;
		error('At least one lattice parameter must be given.');

	else
		if ~isfield(EXP.sample,'b')
			disp('     NOTE in "initialize_EXP" : no value given for sample.b; using sample.a');
			EXP.sample.b=EXP.sample.a;
		end

		if ~isfield(EXP.sample,'c')
			disp('     NOTE in "initialize_EXP" : no value given for sample.c; using sample.a');
			EXP.sample.c=EXP.sample.a;
		end
	end


	%% === set default unit cell angles ===
	if ~isfield(EXP.sample,'alpha')
		disp('     NOTE in "initialize_EXP" : no value given for sample.alpha; using 90');
		EXP.sample.alpha=90;
	end

	if ~isfield(EXP.sample,'beta')
		disp('     NOTE in "initialize_EXP" : no value given for sample.beta; using 90');
		EXP.sample.beta=90;
	end

	if ~isfield(EXP.sample,'gamma')
		disp('     NOTE in "initialize_EXP" : no value given for sample.gamma; using 90');
		EXP.sample.gamma=90;
	end


	%% === assign basis_user if not given ===
	if ~isfield(EXP,'basis_user')
		EXP.basis_user=eye(3);
	end

% not a structure, check if this is a character
else 
	pass=0;
	if ischar(EXP)
		error(' The EXP class is "character". Did you put it in quotes?')
	end
end % isstruct(EXP)


%% === report final status ===
if pass
	disp('      ... the EXP structure seems to be OK')
else
	error('      ... there seems to be a problem with the EXP structure.');
end

PAR.EXP=EXP;

