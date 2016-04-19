function tf=isclose(x,y,tolerance);
% tf = isclose(x,y,tolerance);
%	Compares x,y on elementwise basis and checks to see if they are within a 
%	tolerance.

if ~exist('tolerance');
	tolerance= 10 ^ -10;
end

tf = isequal( size(x),size(y) )   &&   all( abs(x(:)-y(:)) < tolerance );

