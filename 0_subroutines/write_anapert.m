function write_anapert(PAR,VAR)
% write_anapert(PAR,VAR)
%	General function for writing the P_INP file which is to be read by anapert
%	VAR can be either a list of q, or a structure.  If a list of q, then P_INP 
%	is for option 55 (used for calculating eigenvectors).  If VAR is a structure
%	then P_INP is for option 70 (calculating DOS) 

[XTAL,EXP,INFO,PLOT,DATA,VECS]=params_fetch(PAR);
if ~exist('VAR','var'); error(' VAR input is required'); end


%% === Open new file for writing text (discards any current contents) ===
fid=fopen('P_INP','wt');


%% === Option 55, eigenvectors ===
if isnumeric(VAR)
	if size(VAR,2)==3;	% confirm Q-list is Nx3
		unique_q=VAR;

		% === print line 1 ===
		fprintf(fid, '%s\n', XTAL.name);

		% === print line 2, control flag (55 for mode analysis) ===
		fprintf(fid, '55\n');

		% === print line 3.  In pert_doc, this is called 'Line 1' ===
		fprintf(fid, ['eig=yes nrq=%d '],size(unique_q,1));
		fprintf(fid, 'epc=yes ');
		fprintf(fid, 'ntau=0\n');

		% === print list_q; width=6, precision=4 should be adequate for anything ===
		for ind = 1:size(unique_q,1);			% ind goes to number of rows
			this_q=unique_q(ind,:);
			fprintf(fid, '  %6.4f %6.4f %6.4f \n', this_q);
		end

	else
		error(' VAR input must be Nx3 for Option 55')
	end

%% === Option 70, phonon DOS ===
elseif isstruct(VAR);

	if isfield(VAR,'nxyz') & isfield(VAR,'eng') & isfield(VAR,'wids');
		nxyz = VAR.nxyz;
		eng  = VAR.eng;
		wids = VAR.wids;

		nqxyz = ['nqxyz= ' num2str(nxyz) ];
		nom =   [' nom=' num2str(eng(3))];		% number of energy points
		ommin = [' ommin=' num2str(eng(1))];	% min energy/ omega
		ommax = [' ommax=' num2str(eng(2))];	% max energy/ omega


		% integration method.  Anapert's default is t; options are:
			%	t	Tetrahedron
			%	g	Gaussian
			%	h	Hermite
			%	s	Gaussian+Spectral
			%	l	Gaussian+Lorentzian
		intmeth=' intmeth=g';


		% FWHM of gaussian or gauss-hermite broadening
		width =[' width=' num2str(2*wids(1))];
		width2=[' width2=' num2str(2*wids(2))];


		%% === if calculating GDOS with anapert ===
		if 0
			gdos=' gdos=yes';

			% generate xsectt/mass factor
			sigm=[];
			for ind=1:XTAL.N_type
				mass=get_mass(XTAL.atom_types{ind});
				xsec=str2num(get_xsect_neutron(XTAL.atom_types{ind}));

				thisSigm=xsec./mass;
				sigm=[ sigm thisSigm ];
			end
			line2=num2str(sigm);
		else
			gdos=[];
			line2=[];
		end


		%% === assemble ===
		line1=[nqxyz nom ommin ommax intmeth width width2 gdos];

		%% === write to P_INP file ===
		fprintf(fid,'\n');		% must start P_INP with blank/placeholder line
		fprintf(fid,'70\n');
		fprintf(fid,[ line1 '\n']);
		fprintf(fid,[ line2 '\n']);

	%%%% example used for MgB2 :
	%
	%70
	%nqxyz= 10 10 10 nom=480 ommax=120 intmeth=g width=2.8 width2=0.8 gdos=yes
	%0.14939     0.32747
	%00
	else
		error(' VAR input must contain nxyz, eng, & wids to use Option 70');
	end

else
	error(' VAR input not recognized');
end

% === print '00' for end of sequence, then close ===
fprintf(fid, '00\n');
fclose(fid);

