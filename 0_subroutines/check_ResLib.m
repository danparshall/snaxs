function [PAR,good_vals]=check_ResLib(PAR);
% [PAR,good_vals]=check_ResLib(PAR);
% 	Checks kinematics using ResLib code.  There are two reasons to do this:
%		1) ResLib doesn't check physical conditions such as closed triangle
%		2) ResLib energy/momentum conversions are very slightly different from
%		SNAXS, so on rare occasions SNAXS will pass a phonon energy that ResLib
%		finds inaccessible.
%		This is somewhat ad-hoc, because all it does is check for imaginary
%		result coming from atan, asin, acos terms in ResMat.m

[XTAL,EXP_orig,INFO,PLOT,DATA,VECS]=params_fetch(PAR);

scan=INFO.resconv;

if scan=='qscan'
	[Q_hkl,Q_delta]=make_graded_3vec(INFO.Q_max, INFO.Q_min, INFO.Q_npts);
	H=Q_hkl(:,1);
	K=Q_hkl(:,2);
	L=Q_hkl(:,3);
	W=INFO.E_const;
	good_vals=ones(size(H));
elseif scan=='escan'
	W=DATA.centers;
	H=INFO.Q(1);
	K=INFO.Q(2);
	L=INFO.Q(3);
	good_vals=ones(size(W));
else
	error(' Scantype not defined')
end

if numel(W)==0 % ResLib code chokes if len(W)==0
	warning(' No energy points to calculate.')
	return;
end

% === Begin code from ResMat.m, to compare directly ===
CONVERT1=0.4246609*pi/60/180;
CONVERT2=2.072;

[len,H,K,L,W,EXP]=CleanArgs(H,K,L,W,EXP_orig);
[x,y,z,sample,rsample]=StandardSystem(EXP);
Q=modvec(H,K,L,rsample);
[len,Q,W,EXP]=CleanArgs(Q,W,EXP);


for ind=1:len
	%-----------------------------------------------------------------------
	%Assign default values and decode parameters
	moncor=1;
	if isfield(EXP(ind),'moncor')
		moncor = EXP(ind).moncor;
	end;
	alpha = EXP(ind).hcol*CONVERT1;
	beta =  EXP(ind).vcol*CONVERT1;
	mono=EXP(ind).mono;
	etam = mono.mosaic*CONVERT1;
	etamv=etam;
	if isfield(mono,'vmosaic')
		etamv = mono.vmosaic*CONVERT1;
	end;
	ana=EXP(ind).ana;
	etaa = ana.mosaic*CONVERT1;
	etaav=etaa;
	if isfield(ana,'vmosaic')
		etaav = ana.vmosaic*CONVERT1;
	end;
	sample=EXP(ind).sample;
	infin=-1;
	if isfield(EXP(ind),'infin')
		infin = EXP(ind).infin;
	end;
	efixed=EXP(ind).efixed;
	epm=1;
	if isfield(EXP(ind),'dir1')
		epm= EXP(ind).dir1;
	end;
	ep=1;
	if isfield(EXP(ind),'dir2')
		ep= EXP(ind).dir2;
	end;
	monitorw=1;
	monitorh=1;
	beamw=1;
	beamh=1;
	monow=1;
	monoh=1;
	monod=1;
	anaw=1;
	anah=1;
	anad=1;
	detectorw=1;
	detectorh=1;
	sshape=eye(3);
	L0=1;
	L1=1;
	L1mon=1;
	L2=1;
	L3=1;        
	monorv=1e6;
	monorh=1e6;
	anarv=1e6;
	anarh=1e6;
	if isfield(EXP(ind),'beam')
		beam=EXP(ind).beam;
		if isfield(beam,'width')
			beamw=beam.width^2;
		end;
		if isfield(beam,'height')
			beamh=beam.height^2;
		end;
	end;
	bshape=diag([beamw,beamh]);
	if isfield(EXP(ind),'monitor')
		monitor=EXP(ind).monitor;
		if isfield(monitor,'width')
			monitorw=monitor.width^2;
		end;
		monitorh=monitorw;
		if isfield(monitor,'height')
			monitorh=monitor.height^2;
		end;
	end;
	monitorshape=diag([monitorw,monitorh]);
	if isfield(EXP(ind),'detector')
		detector=EXP(ind).detector;
		if isfield(detector,'width')
			detectorw=detector.width^2;
		end;
		if isfield(detector,'height')
			detectorh=detector.height^2;
		end;
	end;
	dshape=diag([detectorw,detectorh]);
	if isfield(mono,'width')
		monow=mono.width^2;
	end;
	if isfield(mono,'height')
		monoh=mono.height^2;
	end;
	if isfield(mono,'depth')
		monod=mono.depth^2;
	end;
	mshape=diag([monod,monow,monoh]);
	if isfield(ana,'width')
		anaw=ana.width^2;
	end;
	if isfield(ana,'height')
		anah=ana.height^2;
	end;
	if isfield(ana,'depth')
		anad=ana.depth^2;
	end;
	ashape=diag([anad,anaw,anah]);
	if isfield(sample,'shape')
		sshape=sample.shape;
	end;
	if isfield(EXP(ind),'arms')
		arms=EXP(ind).arms;
		L0=arms(1);
		L1=arms(2);
		L2=arms(3);
		L3=arms(4);
		L1mon=L1;
		if length(arms)>4
			L1mon=arms(5);
		end
	end;
	if isfield(mono,'rv')
		monorv=mono.rv;
	end;
	if isfield(mono,'rh')
		monorh=mono.rh;
	end;
	if isfield(ana,'rv')
		anarv=ana.rv;
	end;
	if isfield(ana,'rh')
		anarh=ana.rh;
	end;
	method=0;
	if isfield(EXP(ind),'method')
		method=EXP(ind).method;
	end;

	taum=GetTau(mono.tau);
	taua=GetTau(ana.tau);

	horifoc=-1;
	if isfield(EXP(ind),'horifoc')
		horifoc=EXP(ind).horifoc;
	end;
	if horifoc==1 
		alpha(3)=alpha(3)*sqrt(8*log(2)/12); 
	end;

	em=1;
		if isfield(EXP(ind),'mondir')

		em= EXP(ind).mondir;
	end;

	%-----------------------------------------------------------------------
	%Calculate angles and energies
	w=W(ind);
	q=Q(ind);
	ei=efixed;
	ef=efixed;

	if infin>0 ef=efixed-w; else ei=efixed+w; end;
	ki = sqrt(ei/CONVERT2);
	kf = sqrt(ef/CONVERT2);

	thetam=asin(taum/(2*ki))*sign(epm)*sign(em); % added sign(em) K.P.
	thetaa=asin(taua/(2*kf))*sign(ep)*sign(em); 
	s2theta=-acos( (ki^2+kf^2-q^2)/(2*ki*kf))*sign(em); %2theta sample

	if 0
	    thetas=s2theta/2;
	    phi=atan2(-kf*sin(s2theta), ki-kf*cos(s2theta)); %Angle from ki to Q
		A3=thetas*180/pi()
		KiQ=phi*180/pi()
	end

	%-----------------------------------------------------------------------
	% === End of ResLib code ===


	% === test various ways ResLib can choke ===
	c1= isreal(thetam);		% must have lambda/2d_mono <1
	c2= isreal(thetaa);		% must have lambda/2d_ana <1
	c3= isreal(s2theta);	% generally from rounding error

	good_vals(ind)= c1 & c2 & c3 ;	% if any are bad, so is this point

end % end of ResLib loop




% === now apply more restricted centers ===
good_vals=find(good_vals);

if scan=='qscan'
	INFO.Q_npts=length(good_vals);

	if INFO.Q_npts > 0
		INFO.Q_min=Q_hkl(good_vals(1),:);
		INFO.Q_max=Q_hkl(good_vals(end),:);
	end

elseif scan=='escan'
	DATA.centers=DATA.centers(good_vals);
	DATA.heights=DATA.heights(good_vals);
	DATA.ph_widths=DATA.ph_widths(good_vals);
end

PAR=params_update(XTAL,EXP_orig,INFO,PLOT,DATA,VECS);

