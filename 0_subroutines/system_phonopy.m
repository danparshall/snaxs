function [status,result]=system_phonopy(XTAL, call);
% [status,result]=system_phonopy(XTAL, call);
%	Call phonopy depending on system OS, and what is being called
%	The 'call' input is a 4-character string specifying the calling routine.
%
%	General prodcedure:
%	 1) remove old file if present
%	 2) create new link to data
%	 3) call phonopy


if ~exist('call');
	call='eigs';
	warning(' Call not specified; defaulting to "eigs"');
end

phonopy=DEFAULTS('phonopy');

% === if binary doesn't exist at location specified, make an attempt to find it
if ~exist(phonopy,'file')
	if isunix
		if exist('phonopy.linux','file')==2;
			phonopy=which('phonopy.linux');
%			disp('  NOTE in "system_phonopy" : didn''t find phonopy binary at DEFAULTS.m location.  Using alternate path.');
%			disp(['  The binary in use was found at : ' phonopy]);
		end
	elseif ispc
		error(' Phonopy is not supported under Windows.  You can learn more at http://phonopy.sourceforge.net');
	end
end


%% === LINUX ===
if isunix
	% confirm exectuable permissions on phonopy binary ===
	[bin,perms]=system(['stat -c %A ' phonopy]);
	if ~strcmp(perms(4),'x');
		warning(' phonopy binary is not executable');
	end

	%% === execute system call ===

	if call=='test'
		% call calcprog()
		[status,result]=system([phonopy ' -q']);

		if status==0
			% disp(' Phonopy seems to be working');
		elseif status==126
			warning(' Phonopy can''t run, possibly due to permissions error.');
		elseif status==127
			warning(' Phonopy path may be bad');
		end

	% density-of-states, using MP
	elseif call=='pdos'
	
		% remove old stuff if present
		system('rm -f mesh.yaml');

		% call calcprog()
		[status,result]=system([phonopy ' -q MP']);


	% eigenvectors, using QPOINTS
	elseif call=='eigs'

		% remove old qpoints.yaml if present
		system('rm -f qpoints.yaml');

		% call calcprog()
		[status,result]=system([phonopy ' -q --eigenvectors QPOINTS']);


	% call unknown
	else
		error(' Call request not recognized.');
	end



%% === WINDOWS ===
elseif ispc
	error(' Phonopy is not supported under Windows.  You can learn more at http://phonopy.sourceforge.net');

else
	error(' Operating system unknown.');
end



%% === check output for errors ===
if status	% system returns 0 if everything is fine, any other value is an error
	warning(' There was a problem when calling phonopy : ')
	disp(result);


	lapack=regexp(result,'liblapack.so.3');
	if ~isempty(lapack)
		error('	It seems phonopy could not find liblapack.so.3');
	end
end

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
