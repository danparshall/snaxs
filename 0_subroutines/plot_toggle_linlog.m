function PAR=plot_toggle_linlog(PAR);
% PAR=plot_toggle_linlog(PAR);
% 	Toggle intensity plotting between linear and log scales


%% first update plotting style
if PAR.PLOT.semilog == 1;
	PAR.PLOT.semilog = 0;
	disp('  Plotting set to linear');
elseif PAR.PLOT.semilog == 0;
	PAR.PLOT.semilog = 1;
	disp('  Plotting set to logarithmic');
else
	disp('  There may be a problem with toggling linear/log');
end


%% now check if a figure currently exists (and if so, update)
figList = findobj('type','figure');

if ~isempty(figList);

	% match based upon name of current figure
	nameStr = get(gcf, 'name');

	if strcmp(nameStr, 'Sqw');
		plot_SQW(PAR);

	elseif strcmp(nameStr, 'Q-scan');
		plot_Qscan(PAR);

	elseif strcmp(nameStr, 'E-scan');
		plot_Escan(PAR);

	else
		warning(' Figure type not specified.');
	end % matching on nameStr
end % if figure exists


