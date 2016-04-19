function PAR=user_main_menu(PAR);
% PAR=user_main_menu(PAR);
% 	Main menu screen for SNAXS.  Passes PAR if called.

%
%	=== MAIN MENU ===
%
choice = 0;
while choice >= 0;
	if choice ==0;

		% always options
		disp(' ')
		disp(' MAIN MENU:')
		disp('   1) Simulate E-scan at fixed Q')
		disp('   2) Simulate Q-scan at fixed E')
		disp('   3) Simulate slice of S(Q,w)')
		disp('   4) Plot dispersion (energy vs Q, no intensities)')	
		disp('   5) Calculate phonon density-of-states')


		% conditional options
		if strcmp(PAR.EXP.experiment_type,'tas')
			numtas='   6)';
		else
			numtas='  ***';
		end
		disp([numtas ' Perform TAS full convolution']);

		% uses anymate; only available in Matlab
		if system_octave
			numany='  ***';
		else
			numany='   8)';
		end
			disp([numany ' Get eigenvectors (and energies) for single Q-point'])

		disp('   9) Check current parameters, crystal data, etc.')
		disp('   x) Exit')
	end

	% === handle selection ===
	disp(' ')
	choice=input('  Enter your choice: ','s');

	if length(choice)==0;
		choice=0;

	elseif choice=='x';		% exit
		choice = -1;
		disp(' Good-bye')

	elseif choice=='l'		% toggle linear/log plotting
		PAR=plot_toggle_linlog(PAR);
		choice=0;

	elseif choice=='s'
		write_PAR(PAR);
		choice=0;

	else
		choice=str2num(choice);

		if choice == 1;
			PAR=user_Escan_menu(PAR);
			choice=0;

		elseif choice ==2;
			PAR=user_Qscan_menu(PAR);
			choice=0;

		elseif choice ==3;
			PAR=user_SQW_menu(PAR);
			choice=0;

		elseif choice ==4;
			PAR=user_dispersion_menu(PAR);
			choice=0;

		elseif choice ==5;
			user_dos_menu(PAR);
			choice=0;

		elseif choice ==6;
			PAR=user_resconv_menu(PAR);
			choice=0;

		elseif choice ==8;
			PAR=user_eigenvectors(PAR);
			choice=0;

		elseif choice ==9;
			display_current_data(PAR);
			choice=0;

		else
			disp(' Sorry, that choice is currently unavailable');
			choice=0;
		end
	end
end

