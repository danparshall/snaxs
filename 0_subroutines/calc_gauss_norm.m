function gauss=calc_gauss_norm(x_array, center, HWHM)
% gauss=calc_gauss_norm(x_array, center, HWHM)
%	Calculates gaussion with standard definition (area 1 when integrated properly)
% 	x_array is vector
%	center & HWHM can be scalar or vector, but must have the same length
%
%	Output 'gauss' has size length(x_array) x length(center)

if ~isvector(x_array) || ~isvector(center) || ~isvector(HWHM)
	error(' All inputs must be vectors.')
elseif length(center) ~= length(HWHM);
	error(' Inputs "centers" and "widths" must be same length');
end

x_array=x_array(:);		% column vector
center=center(:)';		% row vector
HWHM= HWHM(:)';			% row vector

eng =repmat(x_array, 1, length(center));
cens=repmat(center, length(x_array), 1);
wid =repmat(HWHM, length(x_array), 1);

sig = wid ./ sqrt(2*log(2));
gauss = 1./(sig*sqrt(2*pi)) .* exp( -(eng - cens).^2 ./ (2*(sig.^2)) );

