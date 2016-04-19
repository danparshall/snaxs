function system_cleanup(calc);
% system_cleanup(calc);
%	Cleans up junk files.  
%	Files depend on calc ('phonopy' or 'anapert').


if ~exist('calc')
	disp(' ERROR in "system_cleanup" : calculation unknown ')
end

%% === anapert cleanup ===
if calc=='anapert';

	if isunix
		system('rm -f phonon_modes P_INP P_LOG P_OUT P_STAT P_TIME strufac_* epc_linewidth P_DOS P_GDOS');

	elseif ispc
		system('del phonon_modes P_INP P_LOG P_OUT P_STAT P_TIME strufac_* epc_linewidth P_DOS P_GDOS');

	else
		error(' Operating system unknown');
	end

%% === phonopy cleanup ===
elseif calc=='phonopy'

	if isunix
		system('rm -f QPOINTS qpoints.yaml MP mesh.yaml partial_dos.dat');

	elseif ispc
		system('del QPOINTS qpoints.yaml MP mesh.yaml partial_dos.dat');

	else
		error(' Operating system unknown');
	end

end

