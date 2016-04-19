function bose = calc_bose(energy, degrees, gamma_handling)
% bose=CALC_BOSE(energy, degrees, gamma_handling)
% 	Calculate Bose factor array from given energy array (meV) and 
%	temperature (K).  Properly deals with negatives.  Gamma points/ zero 
%	energy handled as special exception:
%		1 resets a peak at zero energy to 0.1meV, then calculates
%		0 sets the Bose factor to zero, killing the peak

bose = zeros(size(energy));
zero_flag=0;
meV_to_K=11.604519;

if ~exist('gamma_handling')
		disp(' NOTE in "calc_bose" : gamma_handling not set in "DEFAULTS.m"');
		disp(' Using default handling of setting to Bose factor to zero');
elseif exist('gamma_handling') && gamma_handling ~=0 && gamma_handling ~=1
		disp(' NOTE in "calc_bose" : gamma_handling value not allowed');
		disp(' Using default handling of setting to Bose factor to zero');
end

%% === avoid divide-by-zero error ===
if degrees == 0;
	degrees = 0.0001;
end


% === energy-loss side ===
eLoss = find(energy > 0);
bose(eLoss) = 1 + 1./ ( exp( meV_to_K * energy(eLoss)./degrees) -1);


% === energy-gain side ===
eGain = find(energy < 0);
if numel(eGain>0);
	% take absolute value so that peak doesn't become negative
	bose(eGain) = 1./ ( exp(meV_to_K*abs(energy(eGain)./degrees)) -1);
end


% === Gamma points / Bragg peaks ===
elast = find(energy == 0);
if numel(elast > 0)
	if gamma_handling == 1;
		energy(elast)=.1;
		bose(elast) = 1 + 1./ ( exp( meV_to_K * energy(elast)./degrees) -1);
		if zero_flag ==0;
			disp(' NOTE in "calc_bose.m" : Energy of zero was encountered.') 
			disp('   Energy of Gamma-point acoustic phonons set to .1 meV.')
			zero_flag = 1;
		end

	else
		bose(elast) = 0;
		if zero_flag == 0;
			disp(' NOTE in "calc_bose.m" : Energy of zero was encountered.') 
			disp('   Height for Gamma-point acoustic phonons set to zero.');
			zero_flag = 1;
		end
	end
end


