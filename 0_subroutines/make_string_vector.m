function string_out=make_string_vector(vector);
% string_out=make_string_vector(vector);
%	Translates a 2- or 3-vector into cleanly-formatted string

if length(vector) == 3;
	H=num2str(vector(1));
	K=num2str(vector(2));
	L=num2str(vector(3));

	string_out=['[ ' H '  ' K '  ' L ' ].'];

elseif length(vector) == 2;
	firstval = num2str(vector(1));
	secondval = num2str(vector(2));

	string_out=['[ ' firstval '  ' secondval ' ]'];

else
	warning(' Input not a 2- or 3-vector');
end

