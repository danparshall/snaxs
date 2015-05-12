function [PAR,check]=initialize_EXP(PAR)
% [PAR,check]=initialize_EXP(PAR)
% 	Check that EXP is a structure.  Warns the user of most likely error if not.
% 	Confirm experiment type, user basis, lattice constants, etc

EXP=PAR.EXP;
EXP.title='Parameters for a particular experimental configuration.';

check=1;
disp(' Checking the EXP structure ...');
if ischar(EXP)
	error(' The EXP class is "character". Did you put it in quotes?')
	check=0;

%% === proceed ===
elseif isstruct(EXP)

	%% === validate experiment type
	if ~isfield(EXP,'experiment_type')
		EXP.experiment_type = 'tas';
		disp(' Using default experiment type (tas)');
	end

	exp_type=EXP.experiment_type;
	FLAG=0;
	if ~ischar(exp_type)
		FLAG=1;
	elseif ~strcmp(exp_type,'tas') && ~strcmp(exp_type,'tof') && ~strcmp(exp_type,'xray')
		FLAG=1;
	end

	if FLAG
		error('flagError:expType',[' That experiment type is not valid.\n' ... 
 		 ' Make sure that the EXP file contains one of the following lines:\n' ... 
 		 '	EXP.experiment_type=''tas'';\n' ... 
 		 '	EXP.experiment_type=''tof'';\n' ... 
 		 '	EXP.experiment_type=''xray'';'])
		check=0;
	end

	disp(['     The experiment type is: ' EXP.experiment_type]);


	%% === check experiment-dependent fields ===
	if strcmp(EXP.experiment_type,'xray')	% if this is x-ray experiment
		check= check & isfield(EXP,'xray_res') & isfield(EXP,'instrument_Qmax')
		if ~check; 
			warning('      ... failed x-ray check'); 
		end

	else	% otherwise assume this is neutron experiment
		check = check & isfield(EXP,'efixed');
		if ~check; 
			warning('      ... failed neutron check; some energy must be fixed'); 
		end

		if ~isfield(EXP,'infin');
			EXP.infin=1;	% if not specified, final energy is fixed
		end

		if abs(EXP.infin)~=1;
			check = 0;
			error('      ... ERROR in "initialize_EXP", EXP.infin must be +1 or -1');
		end
	end



	%% === check lattice constants ===
	if ~isfield(EXP.sample,'a')
		check=0;
		error('      ... ERROR in "initialize_EXP" : at least one lattice parameter must be given.');

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
end

%% === assign basis_user if not given ===
if ~isfield(EXP,'basis_user')
	EXP.basis_user=eye(3);
end


%% === report final status ===
if check
	disp('      ... the EXP structure seems to be OK')
else
	error('      ... there seems to be a problem with the EXP structure.');
end

PAR.EXP=EXP;

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
