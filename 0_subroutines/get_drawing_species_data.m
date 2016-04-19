function [radius,color]=draw_species_data(atom_kind);
% [radius,color]=draw_species_data(atom_kind);
%	Given atom_kind string, determine atomic number, and then look up values for
%	radius and color.
%
% 	radius is roughly 1 ~ 100pm
%	Color can be overridden, but defaults are here for:
%		non-metals			:	hot pink
%		alkali 				:	green
%		alkali earth		:	green
%		transition metals	:	blueish
%		semimetals			:	magenta
%		lathanides			:	grey
%		actinides			:	grey
%		catch-all			:	grey 

atom_number=get_atom_number(atom_kind);

% stops on first successful match, so put exceptions first
% RGB scheme; G+B = cyan, G+R = yel, B+R = mag;

% oxygen
if atom_number == 8;
%	color = [0.2 0.7 0.7];		% cyan
	color = [0.1 0.1 0.7];		% dark blue
	radius = 0.7;

% hydrogen
elseif atom_number == 1
	color = [0.1 0.1 0.1]; 
	radius = 0.53;

% carbon
elseif atom_number == 6
	color = [0.2 0.7 0.2];	% green
	radius = 0.91;

% nitrogen
elseif atom_number == 7
	color = [0.9 0.1 0.1];	% red
	radius = 0.92;

% copper
elseif atom_number == 29	
	color = [0.9 0.3 0.3];	% reddish
	radius = 1.28;

% lead
elseif atom_number == 82	
	color = [0.9 0.3 0.3];	% reddish
	color = [0.1 0.1 0.7];		% dark blue
	radius = 1.28;

% mercury
elseif atom_number == 80
	color = [0.3 0.3 0.3];	% dark grey
	radius = 1.5;

% arsenic
elseif atom_number == 33
	color = [1.0 0.412 0.706];	% hot pink
	radius = 1.1;

% non-metals
elseif ismember(atom_number,[6 7 8 15 16 34]);
	color = [0.2 0.7 0.7];		% cyan
	radius = 0.9;

% alkali
elseif ismember(atom_number,[1 3 11 19 37 55 87]);
	color = [0.2 0.7 0.2];		% green
	radius = 1;

% alkaline earths
elseif ismember(atom_number,[4 12 20 38 56 88]);
	color = [0.2 0.8 0.2];		% green
	radius = 1.5;

% transition metals
elseif ismember(atom_number,[[21:30] [39:48] [71:80]]);
	color = [0.3 0.3 1.0];		% blueish
	radius = 1.4;

% semimetals
elseif ismember(atom_number,[5 13 14 31 32 33 49 50 51 52 81 82 83 84]);
	color = [0.7 0.2 0.7];		% magenta
	radius = 1.2;


% these are all grey, but could be re-assigned
% lanthanides
elseif ismember(atom_number,[57:70])
	color = [0.5 0.5 0.5];
	radius = 1.7;

% actinides
elseif ismember(atom_number,[89:102])
	color = [0.5 0.5 0.5];
	radius = 1.7;

% catch-all
else
	color = [0.5 0.5 0.5]; 
	radius = 1.0;
	disp('  NOTE in "get_drawing_species_data" : atom not found, using defaults');
end

