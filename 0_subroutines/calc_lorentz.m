function lorentz_y=calc_lorentz(x_array, center, height, hwhm)
% lorentz=calc_lorentz(x_array, center, height, hwhm)
%	Calculates Lorentzian based on input
% 	x_array is vector
%	center & hwhm can be scalar or vector, but must have the same length
%
%	Output 'lorentz' has size ( length(x_array) x length(center) )


if ~isvector(x_array) || ~isvector(center) || ~isvector(hwhm) || ~isvector(height)
	error(' All inputs must be vectors.')
elseif length(center) ~= length(hwhm);
	error(' Inputs "centers" and "hwhm" must be same length');
end


x_array=x_array(:);		% column vector
center=center(:)';		% row
height = height(:)';	% row
hwhm= hwhm(:)';			% row


eng =repmat(x_array, 1, length(center));
cens=repmat(center, length(x_array), 1);
hts =repmat(height, length(x_array), 1);
wid =repmat(hwhm, length(x_array), 1);


%Lorentzian function
lorentz= wid ./ ( (eng-cens).^2 + (wid.^2) );
pknorm = repmat(1./max(lorentz), length(x_array), 1);
lorentz_y= hts .* lorentz .* pknorm;

