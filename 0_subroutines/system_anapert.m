function [status,result]=system_anapert(XTAL, anapert_path, call);
% [status,result]=system_anapert(XTAL, anapert_path,call); 
%	Call anapert() depending on system 
%	General procedure is:
%	 1) remove old output files if present
%	 2) call anapert()		

if ~exist('call');
	call='norm';
end

%=== set anapert path variable ===
if exist('anapert_path','var')==2;
	anapert=anapert_path;
else
	anapert=DEFAULTS('anapert');
end


% === if binary doesn't exist at location specified, make an attempt to find it
if ~exist(anapert,'file')

	if isunix

		% general *nix (mac is a special case of isunix)
		if ~ismac
			if exist('anapert.linux','file')==2;
				anapert=which('anapert.linux');
			end
%			disp('  NOTE in "system_anapert" : didn''t find anapert binary at DEFAULTS.m location.  Using alternate path.');
%			disp(['  The binary in use was found at : ' anapert]);

		% macs
		else
			if exist('anapert.mac','file')==2;
				anapert=which('anapert.mac');
			end
		end


	elseif ispc
		if exist('anapert.exe','file')==2;
			anapert=which('anapert.exe');
%			disp('  NOTE in "system_anapert" : didn''t find anapert binary at DEFAULTS.m location.  Using alternate path.');
%			disp([  'The binary in use was found at : ' anapert]);
		end
	end
end


%% === write generic P_INP file ===
if call=='test'
	fid=fopen('P_INP','wt');

	teststring{1}='55';
	teststring{2}='eig=yes nrq=1 epc=yes ntau=0';
	teststring{3}=' 0 0 0';
	teststring{4}='00';

	for ind=1:length(teststring)
		fprintf(fid,'\n%s',teststring{ind});
	end

	fclose(fid);
end

% === execute system call ===
if isunix
	% remove old files
	system('rm -f strufac_* phonon_modes');

	% confirm exectuable permissions on anapert binary
	[bin,perms]=system(['stat -c %A ' anapert]);
	if ~strcmp(perms(4),'x');
		warning(' anapert binary is not executable');
	end

	% call anapert()
	[status,result]=system(anapert);


elseif ispc

	% remove old files
	system('del strufac_* phonon_modes');

	% call anapert()
	[status,result]=system(anapert);
end



%% === check output for errors ===

if status % system returns 0 if everything is fine, any other value is an error
	warning(' There was a problem when calling anapert : ')
	disp(result);

	if isunix
		exe=regexp(result,'.exe');
		if exe
			warning(' Are you running the Windows version of anapert?');
		end

		if status==127
			error(' Possible that path to anapert binary is not valid.');
		elseif status==126
			error(' Possible permissions error with anapert');
		end
	end

	lapack=regexp(result,'liblapack');
	if ~isempty(lapack)
		error('	It seems anapert could not find liblapack library');
	end
end

