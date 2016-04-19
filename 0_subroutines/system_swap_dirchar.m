function pathout=system_swap_dirchar(pathin);
% pathout=system_swap_dirchar(pathin);
%	Given pathin, swap the directory separation characters to be consistent with
%	the operating system of this machine.


pathout=pathin;

if isunix
	pathout(pathin=='\')='/';
elseif ispc
	pathout(pathin=='/')='\';
else
	error(' System unknown.');
end

