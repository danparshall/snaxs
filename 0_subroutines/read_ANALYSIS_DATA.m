function dataout=read_ANALYSIS_DATA(XTAL, token_name)
% dataout=read_ANALYSIS_DATA(XTAL, token_name)
%	Reads the datafile until it finds a given token_name (i.e, variable name)
%	Token lines start with #, to improve human-readability (could change symbol)
%	Once token is found, add each line to 'data' until next token is reached


%% === open file in read-text mode (windows compatible) ===
if exist(XTAL.data_path,'file')==2;
	fid=fopen(XTAL.data_path, 'rt');
else
	error(' ANALYSIS_DATA file not found.');
	return
end

%% === define loop variables ===
token = ['# ' token_name];				% comment/token lines start with #
search = 0;
data = [];

while (search == 0);
	current = fgetl(fid);								% get the whole line
	if ~ischar(current), break, end						% exit loop at eof 

	search= strncmp(current, token, length(token));	% token test
	if (search == 1);
		search_inner = 1;
		while search_inner;							% search to next '#'
			curr_inner = fgets(fid);				% get new line
			if strncmp(curr_inner, '#', 1)			% token test for next #
				search_inner = 0;					% end while loop
			else
				if ~ischar(curr_inner), break, end	% exit loop if eof 
				data= [data; curr_inner]; 			% add this line to data
				% if searching for 'kind_name', and the ANADATA file has been modified, and some elements are 2 chars, others are 1, then this can break.  Solution should be to put the 'kind_name' condition in here
			end
		end
	end
end

%% === special case; atom_type and structure_name are strings ===
%   atom_kinds stored as strings in cell array; allows for isotope-specific data
if	strcmp('kind_name', token_name);
	temp_str=[];
	data_cell={};
	for ind= 1:size(data,1);	% up to number of rows
		temp_str = data(ind,:);					% get first row
		temp_str = strtrim(temp_str);			% strip trailing whitespace
		data_cell{ind} = temp_str;				% assign to next slot
	ind=ind+1;
	end
	dataout = data_cell;
elseif strcmp('structure_name', token_name)
	dataout=data;
else
	dataout = str2num(data);
end

fclose(fid);

