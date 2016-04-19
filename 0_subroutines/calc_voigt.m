function [voigt_y]=calc_voigt(x_array, center, height, width_L, width_G);
% [voigt_y]=calc_voigt(x_array, center, height, width_L, width_G);
%
%	This voigt profile is only accurate in certain regimes, need to allow fork
%	based on width ratio.
%
%	Some work has already been done, see:
%		https://groups.google.com/forum/#!topic/comp.soft-sys.matlab/3LUg1DNThu4
%	
% FOR VERY SMALL width_L/width_G < .001, this gives errors, poss not acceptable.
% example: vt=calc_voigt(eng, 0.723, 4.2579, .00007, 2);

% calculates Voigt profile using the Hui approximation
% estimated accuracy better than 1 part in 10^10
% for more information, see
%
% Schreier, "Optimized implementations of rational approximations 
%				for the Voigt and complex error function"
%	JQSRT(2011),doi:10.1016/j.jqsrt.2010.12.010


% confirm all peak params are vectors
if ~isvector(center) || ~isvector(height) || ~isvector(width_L) || ~isvector(width_G)
	error(' Peak parameters must be vectors.')
end

% make sure all peak params have the same length
lc=length(center);
lh=length(height);
ll=length(width_L);
lg=length(width_G);
if numel(unique([lc ll lh lg]))~=1
	error(' Peak parameters must be same length');
end


x_array=x_array(:);		% column vector
center=center(:)';		% row vector
height=height(:)';		% row vector
width_L=width_L(:)';		% row vector
width_G=width_G(:)';		% row vector

eng =repmat(x_array, 1, length(center));
cens=repmat(center, length(x_array), 1);
hts=repmat(height, length(x_array), 1);
widl=repmat(width_L, length(x_array), 1);
widg=repmat(width_G, length(x_array), 1);




disp('  NOTE in "calc_voigt" : expand to cover all ranges of width_L/width_G, etc')

x_array=x_array(:);					% force column vector

%	cerf calculeted using x,y in complex plane
%	this normalizes input values

cnst = sqrt(log(2));
y = cnst .* widl./widg;
x = (cnst ./ widg) .* (cens - eng);


%	=== CODE FROM D. HOLMGREN ===
% Function to evaluate complex error function for any
% z = x + i*y.  This uses Hui's rational approximation.
% Real part is Voigt function, imaginary part is dispersion
% (ie., complex index of refraction).  Works for both scalars
% and vectors.  Have not yet made function applicable to whole
% z-plane.
% by D. Holmgren, July 23 95.
% function f = cerf(z)
% coefficients of rational approximation...      
      a0 = 37.24429446739879 + 0*i;
      a1 = 57.90331938807185 + 0*i;
      a2 = 43.16280063072749 + 0*i;
      a3 = 18.64649990312317 + 0*i;
      a4 = 4.67506018267650 + 0*i;
      a5 = 0.56418958297228 + 0*i;
      b0 = 37.2442945086 + 0*i;
      b1 = 99.9290005933 + 0*i;
      b2 = 118.6763981260 + 0*i;
      b3 = 80.6459493922 + 0*i;
      b4 = 33.5501020941 + 0*i;
      b5 = 8.2863279156 + 0*i;
% evaluate complex error function...      
%      x = real(z); y = imag(z); 
nl = length(x);
% z is a scalar...      
      if nl == 1,
      zh = y - i*x;
      voigt_y=(((((a5*zh+a4)*zh+a3)*zh+a2)*zh+a1)*zh+a0) / ...
		((((((zh+b5)*zh+b4)*zh+b3)*zh+b2)*zh+b1)*zh+b0);
      end
% z is a vector...      
      if nl ~= 1,
      zh = y - i.*x;
      voigt_y=(((((a5 .*zh+a4).*zh+a3).*zh+a2).*zh+a1).*zh+a0) ./ ...
		((((((zh+b5).*zh+b4).*zh+b3).*zh+b2).*zh+b1).*zh+b0);
      end

%	=== SCALE HEIGHT ===
pknorm = repmat(1./max(voigt_y),length(eng),1);
voigt_y = real(voigt_y) .* hts .* pknorm;

