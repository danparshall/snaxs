function PAR=user_resconv_menu(PAR);
% PAR=user_resconv_menu(PAR);
% 	Simulate a constant-Q or constant-E scan using ConvResSMA from ResLib, 
% 	which uses the Single-Mode Approximation to treat the full 4D convolution
% 	as 3D.

if strcmp(PAR.EXP.experiment_type,'tas');
	stop=0;
	while stop==0 				% runs until input received is 'x'
		disp(' ')
		disp(' === Simulating TAS resolution convolution ===');
		disp(' Simulate Q-scan or E-scan?');
		disp('    1) Q-scan');
		disp('    2) E-scan');
		user_input=input('  Enter value (or "x" to exit): ','s'); % accept input as string

		if ~exist('user_input');						% don't panic on return
			stop=0;

		elseif length(user_input)==0;					% use default if 'return'
			if exist('default');
				output=default;
				stop=1;
			else
				stop=0;
			end

		elseif user_input=='x';						% exit option
			output='x';
			stop=1;
		
		elseif user_input=='1';
			% Q-SCAN
			PAR.INFO.resconv='qscan';
			PAR=user_Qscan_resconv(PAR);
		
		elseif user_input=='2';
			% E-SCAN
			PAR.INFO.resconv='escan';
			PAR=user_Escan_resconv(PAR);

		else
			disp(' That value was not understood');
		end
	end

else % if not a TAS
	disp('  This isn''t a triple-axis experiment. Try again.');
end

