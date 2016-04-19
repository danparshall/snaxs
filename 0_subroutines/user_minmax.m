function [output,PAR]=user_minmax(default,PAR,special);
% [output,PAR]=user_minmax(default,PAR,special)
% 	Accepts string input and returns 2-vector as a row
% 	Handles default values, exit, etc
%	should always call "params_fetch" immediately after this
%	'special' is a cell array of special inputs that can be accepted & returned

if system_octave; fflush(stdout); end		% fflush if using Octave

if ~exist('special'); special=[]; end
spec={'X' 'S' 'L'};			% default specials for eXit, Save, Log toggle
spec=lower([spec special]);	% make all lowercase

stop=0;
while stop == 0;

	%% === display default value ===
	if exist('default');
		default_string=make_string_vector(default);
		disp(['  The default is ' default_string ]);
	end

	%% === accept input as string, trim whitespace ===
	user_input=strtrim(input('  Enter min/max (or "x" to exit): ','s'));

	%% === now handle the input ===
	if isempty('user_input');					% don't panic if no input

	elseif length(user_input) == 0;				% use default if 'return'
		if exist('default');
			output=default(:)';
			stop=1;
		end

	%% === check for special character ===
	elseif sum(find(strcmp(spec,user_input)))

		% save
		if user_input=='s'
			write_PAR(PAR);

		% log toggle
		elseif user_input=='l'
			PAR=plot_toggle_linlog(PAR);

		% return input (may be : x, h, i, q etc)
		else
			output=user_input;
			stop=1;
		end

	%% === if no match on special character, treat as numeric ===
	else
		%% === sanitize user input ===
		if ~system_octave
			if ~isempty(regexp(user_input,']')) | ~isempty(regexp(user_input,'['))
				disp('  >> Brackets are ignored.');
			end
		end
		if ~isempty(regexp(user_input,';'))
			disp('  >> Semicolons are ignored.');
		end
		if ~isempty(regexp(user_input,','))
			disp('  >> Commas are ignored.');
		end

		user_input(user_input==',')=' ';	% strip commas
		user_input(user_input==';')=' ';	% strip semicolons
		user_input(user_input==']')='';		% strip brackets
		user_input(user_input=='[')='';

		%% === read in as numeric ===
		output=sscanf(user_input, '%f');

		if length(output) ~= 2;
			disp(' You must input a numeric 2-vector.')
		else								% successful 2-vector
			output=sort(output(:)');

			if output(1)==output(2)
				disp(' Values can not be equal.')
			else
				stop=1;
			end
		end
	end
end

if isnumeric(output) & length(output)~=2
	warning(' Wrong output length.');
end

