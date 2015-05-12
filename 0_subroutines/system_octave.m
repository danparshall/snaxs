function OctaveMode=system_octave;
% OctaveMode=system_octave;
%	Returns 1 if using Octave, else 0

if size(ver('Octave'),1)
    OctaveMode = 1;
else
    OctaveMode = 0;
end

%% ## This file distributed with SNAXS beta 0.99, released 12-May-2015 ## %%
