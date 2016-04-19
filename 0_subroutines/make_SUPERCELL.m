function [SUPER,expabs]=make_supercell(PAR,expansion)
% [SUPER,expabs]=make_supercell(PAR,expansion)
% 	Copies unit cell to make supercell, returns Cartesian values
% 	Default is given in PLOT (which gets it from DEFAULTS.m), but if 3-vector 
%	input 'expansion' is present, uses that.  Barring all else, goes to 2x2x2.

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

%% === determine expansion in x,y,z ===
if ~exist('expansion');
	expansion=PLOT.expansion;
	expabs=abs(expansion);

else % exist('expansion');
	expabs=abs(expansion);
	if (sum(expabs-ceil(expabs)) ~=0) || sum(expabs)==0;
	disp(' NOTE in "make_SUPERCELL" : invalid expansion, using default (222)')
		if sum(expabs)==0;
			expansion=[2 2 2];
			expabs=[2 2 2];
		else
			expansion=sign(expansion).*ceil(expabs);
		end
	else
		expansion=expansion;
	end
end
expsgn=sign(expansion);

%% === be sure this is a 3-vec ===
if size(expansion)~=[1 3]
	warning(' Expansion is not 3-vec. Going to crash.');
end


% === make supercell expansion in cartesian coordinates ===
start_position=XTAL.atom_position*XTAL.basis_real;

z_position=[];
dir_z=repmat(XTAL.basis_real(3,:),XTAL.N_atom,1);
for ind_z=1:expabs(3)
	trans_z=(ind_z-1)*expsgn(3);
	z_position=[z_position; start_position + dir_z*trans_z];
end

y_position=[];
dir_y=repmat(XTAL.basis_real(2,:),size(z_position,1),1);
for ind_y=1:expabs(2)
	trans_y=(ind_y-1)*expsgn(2);
	y_position=[y_position; z_position + dir_y*trans_y];
end

SUPER.atom_position=[];
dir_x=repmat(XTAL.basis_real(1,:),size(y_position,1),1);
for ind_x=1:expabs(1)
	trans_x=(ind_x-1)*expsgn(1);
	SUPER.atom_position=[SUPER.atom_position; y_position + dir_x*trans_x];
end


% === makes 'atom_type' vector ===
type=cell(XTAL.N_atom,1);
for ind=1:XTAL.N_atom
	type{ind}=XTAL.atom_types{XTAL.atom_kind(ind)};
end
SUPER.atom_type=repmat( type, prod(expabs), 1);

