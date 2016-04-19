function animate_phonon(PAR,mode_index);
% animate_phonon(PAR,mode_index);
%	Given a mode_index, draw multiple frames at various phases.  Use the package
%	"anymate" (from the Matlab FileExchange) to stitch together the separate
%	frames.

disp('  Drawing, this may take a moment...');
tic;

cab;		% close all figures, just to be safe


%% === draw separate frames ===
N_thetas=8;
thetas=(2*pi* [1:N_thetas]/N_thetas )-pi/2;
cab;

for ind=1:N_thetas
	figure(ind);
	draw_phonon_frame(PAR,thetas(ind),mode_index);
end


%% === call anymate ===
%	anymate uses a legacy version of "interp1" on line 4876.  This needs to be
%	updated to "griddedInterp", but I haven't dug through the code yet.

if 0
	% safe-but-slower.  Have to turn off autoplay, or else anymate doesn't
	% signal final release (so the windows will close, but snaxs doesn't resume)
	anymate('RunMode','circle');
	pause(2);		

else
	% faster, but sometimes anymate isn't done when CAB closes the other windows
	anymate('RunMode','circle','Play','true');	
end

cab('last');	% close all but last (which has the anymation)

disp('  ...finished! Press PLAY (single triangle) button to run.');
toc;

