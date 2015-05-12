function PAR=simulate_SQW(PAR);
% PAR=simulate_SQW(PAR);
%	Calculates and constructs a slice of S(q,w).  This entire slice can be shown
%	to the user (as in, e.g., "user_SQW_menu"), or just a line scan can be 
%	shown (as in "user_Qscan_menu").

tic
[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

if isfield(XTAL,'calc_method')
	calc=XTAL.calc_method;
else
	error(' Calculation method known');
end

% === initialize arrays, index variables ===
[unique_tau, cellarray_qs, Q_hkl, Q_delta]=generate_tau_q_from_Q(PAR);
e_array= [INFO.e_min : INFO.e_step : INFO.e_max];
SQE_array=zeros( length(e_array), INFO.Q_npts);


% === generate VECS, and in turn STRUFAC ===
PAR=simulate_multiQ(PAR, Q_hkl);
[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);


% === now calculate intensities based on STRUFAC ===
if 1
	for k=1:size(VECS.Q_points,1)
		PAR.INFO.Q=Q_hkl(k,:);
		PAR=simulate_Escan(PAR, VECS.strufac_data(:,:,k));
		SQE_array(:,k)=PAR.DATA.int;

		if ~isreal(PAR.DATA.int)
			warning(['Imaginary data at index k=' num2str(k)]);
		end
	end

else

	% I should put something here, but it will mean tearing apart all the
	% subroutines within "simulate_Escan".  Going to punt till a later date.


end


% === make sure some values have been calculated ===
SQE_check=SQE_array;
SQE_check(isnan(SQE_check)) = 0 ;

if sum(sum(SQE_check))==0;
	warning off backtrace
	warning(' No accessible phonons in the range of S(Q,w) that you selected');
	warning on backtrace
end


% === update ===
DATA.SQE_array=SQE_array;
DATA.Q_hkl=Q_hkl;
DATA.E_array=e_array;
DATA.Q_delta=Q_delta;
PAR=params_update(XTAL,EXP,INFO,PLOT,DATA,VECS);
toc;

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
