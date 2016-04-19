function display_strufac_data(PAR);
% display_strufac_data(PAR);
%	Displays strufac data with mode index, energy, and strufac for each mode
%	Currently only used to show eigenvectors, so it's presumed that the only Q
%	of interest is the first one.

if ~isfield(PAR.VECS,'strufac');
	disp('  Can''t display structure factors, haven''t been calculated')

else
	[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
	q_ind = 1;
	this_q= make_string_vector(VECS.qs(1,:));
	cnv=calc_prm_to_cnv(PAR.XTAL,VECS.qs(1,:),PAR.EXP);
	this_cnv=make_string_vector(cnv);
	disp(['  In primitive coordinates, this is : ' this_q]);
	disp(['  Which translates to user basis of : ' this_cnv]);

	Nmodes=size(VECS.energies,1);

	disp(' ');
	disp('  Mode Energy Str.Factor  Height');
	for ind=1:Nmodes;
		if i<10;
			string_ind= [' ' sprintf('%2.0f',ind) ')'];
		else
			string_ind= [ sprintf('%2.0f',ind) ')'];
		end

		energy=VECS.energies(ind,q_ind);
		if energy < 10;
			string_eng = ['  ' sprintf('%3.2f',energy)];
		else
			string_eng = [' ' sprintf('%3.2f',energy)];
		end

		strufac=VECS.strufac(ind,q_ind);
		if strufac == 0;
			string_strufac = '    0';
		elseif strufac < 10
			string_strufac = [' ' sprintf('%3.2f', strufac)];
		else
			string_strufac = [ sprintf('%3.2f', strufac)];
		end

		% use height data if available
		if isfield(DATA,'allheights')
			height = DATA.allheights(ind,q_ind);
		else
			height = NaN;
		end
		if height == 0;
			string_ht = '      0';
		elseif height < 10;
			string_ht = ['   ' sprintf('%3.2f',height)];
		elseif height < 100;
			string_ht = ['  ' sprintf('%3.2f',height)];
		else
			string_ht = '   --.--';
		end

		disp([' ' string_ind '  ' string_eng '   ' string_strufac '  ' string_ht]);
	end
end

