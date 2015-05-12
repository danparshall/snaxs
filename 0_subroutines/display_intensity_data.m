function display_intensity_data(STRUFAC,PAR);
% display_intensity_data(STRUFAC,PAR);
%	Displays intensity data with mode index, energy, and intensity for each mode
%	Currently only used for Escans, so it's presumed that the only Q
%	of interest is the first one.  

if isempty(STRUFAC);
	disp('  Can''t display structure factors, no STRUFAC data has been calculated')

else

	[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
	q_ind = 1;
	STRUFAC_data=STRUFAC.data(:,:,q_ind);
	height_data=calc_height(STRUFAC_data,PAR);

	this_q= make_string_vector(STRUFAC.qs(1,:));
	cnv=calc_prm_to_cnv(PAR.XTAL,STRUFAC.qs(1,:),PAR.EXP);
	this_cnv=make_string_vector(cnv);
	disp(['  In primitive coordinates, this q-point is: ' this_q]);
	disp(['  Which translates to: ' this_cnv]);

	Nmodes=numrows(STRUFAC_data);

	disp(' ');
	disp('  Mode Energy Intensity');
	for ind=1:Nmodes;
		if i<10;
			string_ind= [' ' sprintf('%2.0f',ind) ')'];
		else
			string_ind= [ sprintf('%2.0f',ind) ')'];
		end

		energy=STRUFAC_data(ind,1);
		if energy < 10;
			string_eng = ['  ' sprintf('%3.2f',energy)];
		else
			string_eng = [' ' sprintf('%3.2f',energy)];
		end

		height=height_data(ind);
		if height == 0;
			string_height = '    0';
		elseif height < 10
			string_height = [' ' sprintf('%3.2f', height)];
		else
			string_height = [ sprintf('%3.2f', height)];
		end

		display([' ' string_ind ' ' string_eng '  ' string_height]);
	end
end

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
