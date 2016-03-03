%% An example of how to run SNAXS in an automated mode.
%% This script generates a 3-D array, "slab" which has constant-energy cuts
%% of the HK0 plane (similar to how MACS collects data).


% high-level functions in SNAXS pass data with PAR structure, "auto_PAR" loads it
PAR = auto_PAR(EXPtas);
[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);


% define HK grid
Hvals = [0 : 0.05 : 5];
Kvals = [0 : 0.05 : 3];


% define Energy max/min/step
PAR.INFO.e_max= 20;
PAR.INFO.e_step= 1;
PAR.INFO.e_min=PAR.INFO.e_step;



eng = [PAR.INFO.e_min : PAR.INFO.e_step : PAR.INFO.e_max]';
Hpts = length(Hvals)
Kpts = length(Kvals)
Epts = length(eng)

% initialize empty 3-D array
slab = zeros(Hpts,Kpts,Epts);


% this loop stiches together many slices of S(q,w).  This is the same routine
% called by the menu-driven version.  In this case we are updating the range
% within a loop, instead of by asking the user to manually input values.
for iH = 1:Hpts
	iH
	PAR.INFO.Q_min = [Hvals(iH), Kvals(1), 0];
	PAR.INFO.Q_max = [Hvals(iH), Kvals(end), 0];
	PAR.INFO.Q_npts = Kpts;

	PAR=simulate_SQW(PAR);

	imagesc(PAR.DATA.SQE_array)
	if system_octave;
		drawnow()
	end
	slab(iH,:,:) = PAR.DATA.SQE_array';

end

% plot a constant-energy slice at E = 17 meV
imagesc(Hvals,Kvals,slab(:,:,17)');
axis on
fa=gca;
axis tight normal
set(fa,'YDir','normal');
