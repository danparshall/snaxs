function [pvoigt_y]=calc_pvoigt(x_array, center, height, L_width, G_width)
% [pvoigt_y]=calc_pvoigt(x_array, center, height, L_width, G_width)
%	Calculates pseudo-voigt based on input mixing parameter and half-width
%	Produces output with same width as a Voigt function with these width 
%	components.  More information in:
% 		Vogh, "Alternative form for the pseudo-Voigt peak shape", 
%		Rev Sci Inst 76, 056107 (2005)
%
% 	x_array is vector
%	center & HWHM can be scalar or vector, but must have the same length
%	output has size ( length(x_array) x length(center) )

V_width=(G_width.^5 ...
		+ 2.69296*G_width.^4 .* L_width ...
		+ 2.42843*G_width.^3 .* L_width.^2 ...
		+ 4.47163*G_width.^2 .* L_width.^3 ...
		+ 0.07842*G_width    .* L_width.^4 ...
		+ 					    L_width.^5).^(1/5);

mix = 1.36603*(L_width./V_width) ...
	- 0.47719*(L_width./V_width).^2 ...
	+ 0.11116*(L_width./V_width).^3;


% Lorentzian function
lorentz_y= calc_lorentz(x_array, center, ones(size(center)), V_width);


% Gaussian
gaussian_y= calc_gauss_norm(x_array, center, V_width);
maxgauss= repmat( 1./max(gaussian_y), length(x_array), 1);
gaussian_y= gaussian_y .* maxgauss;


% Pseudovoigt
eta= repmat(mix(:)', length(x_array), 1);
hts= repmat(height(:)', length(x_array), 1);

pvoigt_y= eta.*lorentz_y + (1-eta).*gaussian_y;
pknorm = repmat( max(pvoigt_y), length(x_array), 1);
pvoigt_y= hts .* pvoigt_y ./ pknorm;

