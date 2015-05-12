function varargout=anymate(varargin)
%ANYMATE Animate Handle Graphics objects
%   ANYMATE analyzes the changes in the properties of Handle Graphics
%   objects and can interpolate between these changes to generate a smooth
%   transition between each given state, here called a break. To generate
%   an animation, ANYMATE collects the values of all Handle Graphics objects
%   for each break and then weeds out only the true changes between these
%   breaks.
%
%   SYNTAX
%
%   ANYMATE groups figures by the same type and number of objects and then
%   tries to animate the group holding the most figures.
%
%   ANYMATE(FIGHANDLES) animates the figures specified by FIGHANDLES.
%
%   FUNS=ANYMATE returns a struct of function handles with members
%   'Collect' and 'Play'. Call FUNS.COLLECT() or FUNS.COLLECT(HANDLE) for
%   every new interpolation break. Call FUNS.PLAY() when all breaks have
%   been collected.
%
%   H=ANYMATE(FUN,DATA) with function handle FUN and non-cell matrix DATA,
%   calls FUN N=size(DATA,NDIMS(DATA)) times. DATA's last index is
%   incremented for each call i.e. FUN(DATA(:,...,1)), FUN(DATA(:,...,2))
%   ... FUN(DATA(:,...,N)). FUN is supposed to return all handles that are
%   affected by the call. If FUN doesn't return anything, all objects in
%   the current figure are scanned for changes. If DATA is a cell array, it
%   must be encapsulated by yet another cell as in ANYMATE(FUN,{DATA}), for
%   it to be recognized as cell input. The output of ANYMATE, H,  will be
%   the same as a single call to FUN, i.e. valid handles to the animated
%   objects.
%
%   ...=ANYMATE(FUN,{DATA1, DATA2, ..., DATAK}), where the sizes of the
%   last dimensions of each DATA item are equal, i.e.
%   SIZE(DATA1,NDIMS(DATA1)) equals SIZE(DATA2,NDIMS(DATA2)) etc., calls
%   FUN N=size(DATA1, NDIMS(DATA1)) times. FUN is called with parameters
%   (DATA1, DATA2,..., DATAN). Each DATA's last index are incremented for
%   each call:
%      FUN(DATA1(:,...,1), DATA2(:,...,1), ..., , DATAK(:,...,1))
%      FUN(DATA1(:,...,2), DATA2(:,...,2), ..., , DATAK(:,...,2))
%      ...
%      FUN(DATA1(:,...,N), DATA2(:,...,N), ..., , DATAK(:,...,N))
%
%   The exception to the above rule is when all DATA1 to DATAK are of type
%   char, making the composite variable a cell string. In that case, FUN is
%   called as FUN(DATA1), FUN(DATA2), ..., FUN(DATAK).
%
%   ...=ANYMATE(FUN, DATA), with B-by-A cell array DATA, calls FUN with
%   arguments:
%      FUN(DATA{1,1}, DATA{1,2}, ..., DATA{1,A})
%      FUN(DATA{2,1}, DATA{2,2}, ..., DATA{2,A})
%      ...
%      FUN(DATA{B,1}, DATA{B,2}, ..., DATA{B,A})
%
%   ...=ANYMATE(..., LABELS)
%   ...=ANYMATE(..., TICKS)
%   ...=ANYMATE(..., TICKS, LABELS)
%   ...=ANYMATE(..., LABELS, TICKS)
%	If no LABELS are given, the default labels '1','2', ... 'N' are used.
%	LABELS is a cell array of strings and the number of elements must equal
%	nummber of breaks, N. TICKS are the distance in time, expressed in
%	arbitrary unit, between breaks. ANYMATE will keep the time between
%	breaks proportionally to the distance between TICKS. Length of TICKS
%	can be N or N+1. If N+1 TICKS are given, the (N+1)'th tick holds the
%	distance from the last tick to the first, in case of circular
%	animation.
%
%   ANYMATE accepts a number of parameters entered as named parameters of
%   the form ...=ANYMATE(..., 'Name', VAL). The parameters can be
%   concatenated in arbitrary order. 'Name' is not case sensitive and can
%   be abbreviated as long as it is unique among the alternatives.
%
%   'Fps'	     Sets number of frames per second to VAL.
%   'Duration'   Sets duration of one cycle, 1 through N, of breaks to VAL
%                seconds.
%   'RunMode'    Sets the run mode to either 'forward', 'pingpong' or
%                'circle'.
%   'Method'     Sets the type if interpolation to either 'linear' or
%                'pchip'.
%   'Spread'     If VAL is true, spreads the last dimension into separate
%                variables when calling FUN and assumes that the
%                penultimate dimension holds the different breaks. Useful
%                when FUN wants e.g. X, Y, Z as separate variables.
%   'Parameters' Propagates cell array VAL as parameters to FUN,
%                concatenated with DATA, i.e. FUN is called like
%                FUN(DATA,VAL{:}).
%   'Play'       If VAL is true, animation is started immediately.
%   'Tick'       Same as positional parameter TICK above.
%   'TickLabel'  Same as positional parameter TICKLABEL above.
%   'Axis'       If VAL is true (default), a timeline is shown at the
%                bottom of the animated figure, otherwise the timeline is
%                invisible.
%   'Include'    Struct of properties that should be animated even though
%                they by default are not. Following properties are not
%                animated by default:
%                   Type    Properties
%                   figure  Position
%                   axes    ALim, CameraPosition, CameraTarget,
%                           CameraUpVector ,CameraViewAngle, CLim,
%                           DataAspectRatio, PlotBoxAspectRatio,
%                           OuterPosition, Position, TickDir, View,
%                           XLim, XTickLabel, XTick, YLim, YTickLabel,
%                           YTick, ZLim, ZTickLabel, ZTick
%                   patch   CData, XData, YData, ZData
%                The property to include is specified in a struct. E.g.
%                VAL=STRUCT('axes',{{'ALim','CLim'}}) will animate the
%                ALIM and CLIM properties of axes. Note the required use of
%                double cell markers when defining a struct of cell arrays.
%
%                There are two short-forms available. Instead of the struct,
%                one of the following two strings can be entered:
%                   String   Short for
%                   'Limits' struct('axes', {{'ALim', 'CLim', 'XLim', ...
%                                             'YLim', 'ZLim', ...
%                                             'DataAspectRatio'}}
%                   'Camera' struct('axes', {{'CameraPosition', 'CameraTarget', ...
%                                             'CameraUpVector', 'CameraViewAngle', ...
%                                             'View'}}
%
%   'Exclude'    Struct of properties that should not be animated even
%                though they change. A number of properties are disabled by
%                default, see 'Include' above. Also see 'Include' for
%                syntax. Properties specified by 'Exclude' are excluded
%                after the 'Included' part. This means that properties
%                included by a short-form with 'Include' can be selectively
%                excluded.
%
%   'WholeFigure'If set, ANYMATE does not try to get the objects to animate
%                from the output of the supplied function when using the
%                ANYMATE(@FUN,DATA,...) call form. ANYMATE will instead
%                inspect all visible objects of GCF. This can be be useful
%                for animating functions like MEMBRANE, which doesn't
%                produce any graphics when called with an output argument.
%
%   The various Lim properties of axes do play a role in the animation,
%   even when they are not animated. Before collecting Handle Graphics
%   property values, the corresponding Mode property is set to 'auto',
%   rendering the Lim-property a setting that fits the current axes. These
%   settings are then collected and before the animation starts, the axes
%   are set to limits that will encompass all the following frames.
%
%   Examples:
%      anymate(@plot,rand(5,5));
%
%      anymate(@plot,rand(5,5,5), 'Play', true);
%
%      h=anymate(@(x,y)plot(x,y,'.'),rand(5,5,2), 'Spread', true);
%      set(h, 'MarkerSize', 20);
%
%      h=anymate(@(x,y,z)plot3(x,y,z,'.'),rand(5,5,5,3), 'Spread', true);
%      set(h, 'MarkerSize', 20);grid
%
%      anymate(@surf,rand(5,5,5))
%
%      [x,y,z]=sphere;
%      anymate(@surf,{cat(3,x,.2*x+1) cat(3,y,y) cat(3,z,2*z)});
%      colormap(jet);
%
%      anymate(@bar3,rand(3,4,5))
%
%      % Define following function in its own file doplot.m
%      function h=doplot(x1,x2)
%         subplot(121);
%         h(1)=plot(x1);
%         subplot(122);
%         h(2)=surf(x2);
%         end
%      % Then, at the commandline, do:
%      anymate(@doplot,{rand(4,5) rand(4,3,5)});

% About ANYMATE
% The author of ANYMATE is Jerker W�gberg. Contact information:
%
%  Jerker W�gberg
%  More Research
%  SE-891 80  SWEDEN
%  E-mail: jerker dot wagberg (at) more dot se
%  Tel: +46 660 75094
%
% Terms of use
% ANYMATE was written by Jerker W�gberg, More Research, Sweden. It is
% hereby released as free software. You can use it as you please as long as
% you don't claim you wrote it, but instead give the author due credit. If used
% in public and you're not comfortable with pronouncing the author's
% first name, you can try to pronounce it in Swedish; Yeahrker ...

% 080103    1.0.0  First release to FEX
% 080108    1.0.1  Made sure that the animation figures title bar is
%                  visible when created and when undocked without raising a
%                  warning.
% 080211    1.0.2  Fixed mangled argument passing. Did not work for ticks
%                  and/or tick-labels on command line.
% 080401    1.0.3  Fixed typo in 'fun=anymate(...)' calling sequence.
%                  Thanks to Andres T�nnesmann for pointing that out.
%                  Documented a way to alleviate out-of-memory problems.

	Defaults=struct( ...
		  'Fps', anigetpref('Fps') ...	% Frames per second. Use the one prefered earlier
		, 'Duration', [] ...			% Duration of one pass through the breaks
		, 'RunMode', 'pingpong' ...		% One of 'forward', 'pingpong' or circle
		, 'Spread', false ...			% Single parameter is spread if set, ie xyz ->x,y,z
		, 'Parameters', {{}} ...		% Parameters to send to FUN
		, 'Play', false ...				% Start animating right away
		, 'Axis', true ...				% Show the timeline
		, 'Include', struct ...			% Animate these, even if not included by default
		, 'Exclude', struct ...			% Do not animate these properties
		, 'Tick', [] ...
		, 'TickLabel', [] ...
		, 'Method', 'pchip' ...		    % Interpolation method to use
		, 'Unwrap', false ...			% Unwraps (presumably) angular data when 'circle', (not really supported yet)
		, 'WholeFigure', false ...		% Try to get handles from the output of user function
		, 'Filename', '' ...			% If animating directly to a file
		);

	[fun,DataFuns,hf,par,msg]=animate_argcheck(Defaults, varargin);
	error(msg);
	[par,msg]=parcheck(par);
	error(msg);
	error(nargoutchk(0,2,nargout, 'struct'));
	vargout=cell(0,1);
	if ~isempty(fun)
		vargout=cell(1,2);
		try
			% AnimateByCallback may warn once if there are no handles
			% output from FUN and will then return with the warning state
			% disabled. Therefore, we save the state of
			% 'anymate:NoHandleOutput' so we can restore it after the call.
			ws=warning('query','anymate:NoHandleOutput');
			[vargout{1:2}]=AnimateByCallback(fun,DataFuns,par);
		catch
			warning(ws);
			rethrow(lasterror);
			end
		warning(ws);
	elseif ~isempty(hf)
		AnimateByFigures(hf, par);
	elseif nargout==0
		AnimateByEverything(par);
	elseif nargout==1
		vargout{1}=AnimateByFunction(par);
		end
	
	if ~isequal(par.Fps, Defaults.Fps)
		anisetpref('Fps', par.Fps);
		end
	if nargout>length(vargout)
		error('anymate:TooManyOutputs', 'Too many output arguments');
		end
	varargout=vargout(1:nargout);
	end

function fun=StartAnimation(handles, HgAnim, iData, par)
	% Need a rock solid handle to the figure for resetting callbacks
	hFig=ancestor(handles(1), 'figure');

	% Set the fixed properties, {XYZCA}Lim
	setFixedProps(handles, HgAnim);

	% Fire up the animation
	fun=animation(hFig, HgAnim, handles, iData ...
		, 'Duration', par.Duration ...
		, 'Frequency', par.Fps, 'RunMode', par.RunMode ...
		, 'TTick', par.Tick, 'TTickLabel', par.TickLabel ...
		, 'Play', par.Play, 'Method', par.Method ...
		, 'Filename', par.Filename ...
		, 'Unwrap', par.Unwrap ...
		, 'Axis', par.Axis);
	end

function setFixedProps(handles, HgAnim)
	function SetProps(Hg)
		for i = 1:size(Hg.Fixed,1)
			set(handles(Hg.Handles(i)), Hg.Fixed{i});
			end
		end
		
	structfun(@SetProps, HgAnim);
	end

function z=AllHandles(plothandles)
	ax=AxesHandles(plothandles);
	% Remove possible duplicates of axes in plothandles, without reordering
	ix=arrayfun(@(x)find(plothandles==x),ax, 'Uniform', false);
	plothandles([ix{:}])=[];
	% Append axes handles
	z=[plothandles;ax];
	end

function hax=AxesHandles(handles)
%AXESHANDLES Get parental axeses to handles
	hax=strippedancestor(handles,'axes');
	hax=unique(hax);
	hfig=strippedancestor(hax,'figure');
	if diff(hfig) ~= 0
		error('Can not handle objects in more than one figure');
		end
	hax=hax(:);
	end

function [HgAnim, iData]=ExtractAnimationData(HgSpec, par)
	% Find properties that have changed and return these properties
	% together with the property names. Properties will be grouped into
	% types and stored in separate fields in HgSpec.

	if isempty(HgSpec)
		error('anymate:NothingToAnimate', 'There is nothing to animate');
		end;

	% This is where the true action of animate takes place. Property data
	% are analysed and only the properties that the user have actively
	% changed are kept.

	HgSpec = structfun(@TraverseData,HgSpec, 'Uni', false);
	
	% Include user's properties
	HgSpec = IncludeIncludes(HgSpec, par.Include);

	% Exclude user's properties
	
	HgSpec = ExcludeCallerVoids(HgSpec, par.Exclude);

	% Remove properties that don't change numerically
	HgSpec = structfun(@ExcludeConstants,HgSpec, 'Uni', false);

	% Get the size specs for the remaining properties
	HgSpec = structfun(@CalculateSizes,HgSpec, 'Uni', false);

	% Compress data into a 2D array
	[HgSpec,iData] = CompressData(HgSpec);
	
	% We do not need all of the collected Data anymore, so we copy the
	% necessary parts of HgSpec into HgAnim and return that instead.
	
	HgAnim=structfun(@GetAnimSpec, HgSpec, 'Uni', false);
	end

function HgAnim=GetAnimSpec(HgSpec)
	HgAnim.Handles=HgSpec.Handles;
	HgAnim.Fixed = HgSpec.Fixed;
	nh=size(HgSpec.Mask,1);
	
	% For each handle, extract the properties that have valid changes
	% and their corresponding range specifications and data

	for i=1:nh
		prop=HgSpec.Props(HgSpec.Mask(i,:));
		Class=HgSpec.Class(HgSpec.Mask(i,:));
		np=length(prop);
		% Make sure there is at least an empty struct
		HgAnim.Prop{i} = struct;
		for j=1:np
			HgAnim.Prop{i}.(prop{j}) = struct( ...
				  'range',   HgSpec.szSpec.offset + HgSpec.szSpec.htot(i) ...
						   + [HgSpec.szSpec.cum{i}(j)+1 HgSpec.szSpec.cum{i}(j+1)] ...
				, 'sz'   , HgSpec.szSpec.sz{i}{j} ...
				, 'class', Class{j});
			end
		end
	end

function varargout=structfunex(fun, target, key)
	fn=fieldnames(target);
	varargout{1:nargout}=cell2struct(repmat({[]},length(fn),1),fn,1);
	for ctype = fieldnames(target)'
		type = ctype{1};
		vargout=cell(1,nargout);
		if isfield(key, type)
			arg=key.(type);
		else
			arg=[];
			end
		[vargout{:}]=fun(target.(type), arg);
		for i=1:nargout
			varargout{i}.(type)=vargout{i};
			end
		end
	end

function z=keyfun(fun, target, key)
	z=zeros(1,length(key));
	for i=1:length(key)
		z(i)=fun(target, key{i});
		end
	end

function z=partialmatchix(varargin)
	[qq,z]=partialmatch(varargin{[2 1]},varargin{3:end});
	end

function HgSpec = ExcludeCallerVoids(HgSpec, Void)
	function targ=ExFun(targ,key)
		if ~isempty(key)
			targ.Mask(keyfun(@partialmatchix,targ.Props,key))=false;
			end
		end
	HgSpec=structfunex(@ExFun,HgSpec,Void);
	end

function HgSpec = IncludeIncludes(HgSpec, Inc)
	function targ=IncFun(targ,key)
		if ~isempty(key)
			targ.Mask(keyfun(@partialmatchix,targ.Props,key))=true;
			end
		end
	HgSpec=structfunex(@IncFun,HgSpec,Inc);
	end

function HgSpec = TraverseData(HgSpec)

	% Some types have properties, like XLim, YLim, VertexNormals, that are
	% set automatically by HG. We do not want to interpolate them. But some
	% of them, like {XYZAC}Lim, we want to set in the beginning of the
	% animation, so that they are fixed when animating.

	% Do not animate any active 'auto' property
	HgSpec = ExcludeAutos(HgSpec);
	% It's diffcult to interpolate strings so we keep just the numerals...
	HgSpec = ExcludeNonNumerics(HgSpec);
	% Remove all properties that changes size
	HgSpec = ExcludeVariableSized(HgSpec);
	% Remove properties that look like handles
	HgSpec = ExcludeHandleProps(HgSpec);
	% Calculate the min and max for {XYZC}Lim et.al
	HgSpec = FindFixed(HgSpec);
	% There are some properties for some types we just don't want to
	% interpolate.
	HgSpec = ExcludeVoids(HgSpec);
	end

function [HgSpec,iData] = CompressData(HgSpec)

	function injectType(HgSpec)
		% Number of [handles, properties, breaks]
		[nh,np,nb]=size(HgSpec.Data);
		% Pick up a copy of offset data with shorter names
		offset=HgSpec.szSpec.offset;
		cumh=HgSpec.szSpec.htot;
		% For each handle in type
		for i=1:nh
			% Get the names of properties to change
			p=HgSpec.Data(i,HgSpec.Mask(i,:),:);
			% Array of offsets for each property
			cumo=HgSpec.szSpec.cum{i};
			% For each changed property
			for j=1:sum(HgSpec.Mask(i,:))
				% For each break
				for k=1:nb
					% Put the data as a part of the column vector Data.
					iData(offset+cumh(i)+((cumo(j)+1):cumo(j+1)),k)=reshape(p{1,j,k},[],1);
					end
				end
			end
		end

	% Put all numeric data into one 2D array with variable data for each
	% break in successive columns. We are going to interpolate between
	% the columns later, when animating.

	% Find the total number of items for each break
	cumTot = [0;cumsum(structfun(@(x)x.szSpec.htot(end),HgSpec))];

	% Inject the offset for each type into the specs
	fn=fieldnames(HgSpec)';
	nBreaks = size(HgSpec.(fn{1}).Data,3);
	iData=zeros(cumTot(end), nBreaks, 'single');
	
	for itype=1:length(fn)
		HgSpec.(fn{itype}).szSpec.offset = cumTot(itype);
		injectType(HgSpec.(fn{itype}));
		end
	end

function HgSpec=CalculateSizes(HgSpec)
	% Add a size specification for each handle and property
	
	% Get number of handles of this type
	nh=size(HgSpec.Data,1);
	% Initialize the needed number of values for all handes an properties
	% of this type
	tot=zeros(1,nh);
	% For each handle
	for i=1:nh
		% Build a cell array containing a size specification for each property
		HgSpec.szSpec.sz{i}=cellfun(@size,HgSpec.Data(i,HgSpec.Mask(i,:),1),'Uni',false);
		% Save a cumulative offset for the properties of this handle
		HgSpec.szSpec.cum{i}=[0 cumsum(cellfun(@prod,HgSpec.szSpec.sz{i}))];
		% Update total number of values for this type
		tot(i)=HgSpec.szSpec.cum{i}(end);
		end
	% Save a cumulative list of offsets for the data of each handle
	HgSpec.szSpec.htot=[0 cumsum(tot)];
	end

function HgSpec = ExcludeVariableSized(HgSpec)
	% Find all properties that change their size from break to
	% break and exclude them from the animation

	CellSz=cellfun(@size,HgSpec.Data, 'Uniform', false);
	sameSz=cellfun(@(x)isequal(x{:}),dim2cell(CellSz,3));
	HgSpec.Mask = HgSpec.Mask & sameSz;
	end

function z=AxesAutoProps
	Auto={ ...
		 'ALim','CameraPosition','CameraTarget','CameraUpVector' ...
		,'CameraViewAngle', 'CLim','DataAspectRatio' ...
		,'PlotBoxAspectRatio','TickDir','XLim','XTickLabel' ...
		,'XTick','YLim','YTickLabel','YTick','ZLim' ...
		,'ZTickLabel','ZTick'};
	z.Prop = Auto;
	z.Flag = strcat(Auto,'Mode');
	end

function SetAuto(hax, Exceptions)
	if isfield(Exceptions, 'axes')
		ex=Exceptions.axes;
	else
		ex={};
		end
	AutoAx=AxesAutoProps;
	ix=strmatchex(AutoAx.Prop, ex);
	ix=setdiff(1:length(AutoAx.Prop),ix);
	set(hax, AutoAx.Flag(ix), repmat({'auto'}, length(hax), length(ix)));
	end

function h=ClanHandles(hp)
% Return all ordinary visible descendants of a handle
% Remove some objects that can't be animated

	h=findobj(hp);
	% Don't want to animate various ui-objects and findobj doesn't allow
	% '-regexp' on 'type'
	h(strmatch('ui',get(h,'type')))=[];
	end

function [z,fun]=AnimateByCallback(fun, DataFuns, par)
	% Step through the animation for all data
	HgSpec = CollectHGData(fun,DataFuns,par);

	% Get the iData for all scenes of the animation, together with axis
	% and caxis limits
	[HgAnim, iData]=ExtractAnimationData(HgSpec, par);

	% Now we know how the handles and data are structured.
	% Do an initial call with the first set of data to get the handles established.
	
	plothandles = CallbackCall(fun, DataFuns.BreakData(1), par);

	% Add the axeses to handles 
	handles=AllHandles(plothandles(:));

	z=plothandles;
	fun=StartAnimation(handles, HgAnim, iData, par);
	end

function funs=AnimateByFunction(par)
	function Collect(h)
		if PlayIsCalled
			error('anymate:Collect', 'Can not Collect after Play has been called');
			end
		if nargin<1; h=gcf; end
		iBreak=iBreak+1;
		handles=ClanHandles(h);
		if iBreak==1
			[HgHandles, hgTypes, HgSpec]=CollectionSpec(par, handles);
			end
		HgSpec=CollectInstance(iBreak, HgSpec, handles, HgHandles, hgTypes, par);
		LastCollected=h;
		LastType=get(LastCollected, 'type');
		end

	function funs=Play
		if ishandle(LastCollected)
			PlayIsCalled=true;
			funs=AnimateInCopy(ancestor(LastCollected, 'figure'),HgSpec,par);
		else
			emsg='Can not create animation figure.\n';
			if strcmp(LastType, 'figure')
				emsg=[emsg 'The last figure collected must not be deleted before Play is called.'];
			else
				emsg=[emsg 'The figure containing the last collected object must not be deleted before Play is called.'];
				end
			error('anymate:Play:NoFigure', emsg);
			end
		end

	LastCollected=[];
	LastType='';
	PlayIsCalled=false;
	HgSpec=[];
	iBreak = 0;
	HgHandles=[];
	hgTypes=[];
	funs = struct( ...
		  'Collect', @Collect ...
		, 'Play', @Play ...
		);
	end

function [NewTitles, NewLabels]=Titles2Labels(OldTitles,OldLabels)
	% If titles change cross breaks
	NumAx=size(OldTitles,1);
	Mask=false(NumAx,1);
	for i=1:NumAx
		Mask(i)=isequal(OldTitles{i,:});
		end
	NewTitles(1:NumAx,1)={''};
	NewTitles(Mask)=OldTitles(Mask);
	if isempty(OldLabels) && NumAx==1 && ~any(cellfun(@isempty,OldTitles))
		NewLabels=OldTitles;
	else
		NewLabels=OldLabels;
		end
	end

function fun=AnimateInCopy(hf, HgSpec, par)
	[HgAnim, iData]=ExtractAnimationData(HgSpec, par);
	hf=copyobjnc(hf(1), 0);
	ws=warning('off','MATLAB:Figure:SetPosition');
	set(hf ...
		, 'Name', 'Anymation' ...
		, 'Units', 'pixels' ...
		, 'Position', get(0,'DefaultFigurePosition') ...
		);
	warning(ws);
	hc=ClanHandles(hf);
	if isfield(HgSpec, 'axes')
		[titles,par.TickLabel]=Titles2Labels(HgSpec.axes.TitleText, par.TickLabel);
		ht=get(hc(HgSpec.axes.Handles), {'Title'});
		ht=[ht{:}];
		set(ht, {'String'}, titles);
		end
	fun=StartAnimation(ClanHandles(hf), HgAnim, iData, par);
	end

function funs=AnimateByFigures(hf,par)
	nBreaks=length(hf);
	for iBreak=1:nBreaks
		% Use a copy of the figure since we are might change a few
		% properties while collecting property data.
		h=copyobjnc(hf(iBreak), 0);
		% Get all visible descendants of the figure
		handles=ClanHandles(h);
		% Set up collecting structs if first time through
		if iBreak==1
			[HgHandles, hgTypes, HgSpec]=CollectionSpec(par, handles, nBreaks);
			end
		% Collect property values for this break
		HgSpec=CollectInstance(iBreak, HgSpec, handles, HgHandles, hgTypes, par);
		delete(h);
		end
	funs=AnimateInCopy(hf,HgSpec,par);
	end

function funs=AnimateByEverything(par)
	% Find all ordinary figure windows, get the type of all objects in them
	% and establish which plot type that is most frequent, i.e. the figures
	% that have the same objects in the same order.
	
	% Get all figure handles
	hf=findobj(0,'type', 'figure');
	% Remove figures that are animation figures
	haxtimeline=findall(hf, 'type', 'axes', 'Tag', 'JWTimeAxis');
	hf=setdiff(hf, ancestor(haxtimeline, 'figure'));
	if length(hf)<2
		error('anymate:TooFewBreaks', 'Must have at least two figures');
		end
	% Get a length(hf) cell column vector of cell row vectors containing
	% all the types of objects in each figure, e.g.
	% types{1}={'axes','line','line'}
	types=arrayfun(@(x)get(ClanHandles(x), {'type'})',hf, 'Uni', false);
	% Find the maximum number of types in each figure
	mxobj=max(cellfun(@(x)size(x,2),types));
	% Pad rows in types with '' to make them "concatenable" and then
	% concatenate
	types=cellfun(@(x)[x repmat({''},1,mxobj-size(x,2))],types, 'Uni', false);
	types=cat(1,types{:});
	% Sort them so that figures having same objects come together
	[types,ix]=sortrows(types);
	% Get a boolean vector where true indicates that this figure has the same
	% type and number of objects as the next
	eq=all(strcmp(types(1:end-1,:),types(2:end,:)),2);
	% Run length encode the equalities
	i = [find(eq(1:end-1) ~= eq(2:end));length(eq)];
	len = diff([0;i]);
	val = eq(i);
	% Find the longest stretch of, hopefully, ones.
	[dummy,ix2]=sortrows([val len]);
	i=ix2(end);
	if val(i)==0
		error('anymate:TooFewBreaks', 'Must have at least two congruents figures');
		end
	% Get the figures to animate in presumably creation order
	hf=sort(hf(ix(i+(0:len(i)))));
	funs=AnimateByFigures(hf, par);
	end

function [HgHandles, hgTypes, HgSpec]=CollectionSpec(par, handles, nBreaks)
	if nargin<3; nBreaks=0;end

	% Get the unique HG object types
	handleTypes=get(handles,{'type'})';
	hgTypes=unique(handleTypes);

	% The handle values themselves can change for every new call
	% to the user supplied plot function. However, the order of the
	% handles do not change, i.e. we assume that a handle
	% in one position of HANDLES allways refer to the "same" object
	% so we create a storage for these indices, HGHANDLES.
	% It will typically have a format like:
	%	HgHandles = 
	%		axes:  4
	%		line:  1 2
	%		patch: 3

	indh=cellfun(@(x)strmatch(x,handleTypes), hgTypes, 'Uni',false);
	HgHandles=cell2struct(indh, hgTypes,2);

	% Set various 'auto'-properties to true so they do not participate in
	% the animation. However, leave the ones that the user specifically
	% included.

	if isfield(HgHandles, 'axes')
		SetAuto(handles(HgHandles.axes), par.Include);
		% Declare variable for title text. We might want to use them as
		% ticklabels.
		HgSpec.axes.TitleText=cell(length(HgHandles.axes), nBreaks);
		end

	% Get one handle, the first, from each handle type
	HandleSample=structfun(@(ix)handles(ix(1)), HgHandles, 'Uni', false);

	% For each type, collect the fieldnames and the indices to
	% handles. Also collect the storage type for every item.
	for ctype=hgTypes
		type=ctype{:};
		Props=get(HandleSample.(type));
		HgSpec.(type).Class=struct2cell(structfun(@class,Props,'Uni',false))';
		HgSpec.(type).Props=fieldnames(Props)';
		HgSpec.(type).Handles=HgHandles.(type);
		HgSpec.(type).Data = cell(length(HgSpec.(type).Handles), length(HgSpec.(type).Props), nBreaks);

		% Add a mask for all properties. Initialize it to all true.
		% It will not be used here, but later on it will mark which
		% properties to interpolate. Also, add the correct
		% specification for the auto properties.

		HgSpec.(type).Mask=true(length(HgHandles.(type)),length(HgSpec.(type).Props));
		HgSpec.(type).PropSpec=GetPropSpec(HandleSample.(type),par);
		end
	end

function HgSpec=CollectInstance(iBreak, HgSpec, handles, HgHandles, hgTypes, par)
	if isfield(HgHandles, 'axes')
		SetAuto(handles(HgHandles.axes), par.Include);
		ht=get(handles(HgHandles.axes), {'Title'});
		ht=[ht{:}];
		s=get(ht, {'String'});
		HgSpec.axes.TitleText(:,iBreak)=cellfun(@strlineate,s, 'UniformOutput', false);
		end
	for ctype=hgTypes
		type=ctype{:};
		HgSpec.(type).Data(:,:,iBreak) = get(handles(HgHandles.(type)),HgSpec.(type).Props);
		HgSpec.(type).IsHandle(:,:,iBreak)=cellfun(@AllAreHandles, HgSpec.(type).Data(:,:,iBreak));
		end
	end

function plothandles=CallbackCall(fun,Data, par)
	if par.WholeFigure || nargout(fun)==0
		vargout={};
	else
		vargout=cell(1,1);
		end
	[vargout{:}]=fun(Data{:}, par.Parameters{:});
	if isempty(vargout)
		% Get all visible descendants of the figure
		plothandles=ClanHandles(gcf);
	elseif ~all(reshape(ishandle(vargout{1}),[],1))
		plothandles=ClanHandles(gcf);
		warning('anymate:NoHandleOutput' ...
			, [ 'Output of ''%s'' were not handles. Inspecting all of GCF.\n' ...
				'Use ANYMATE(...,''WholeFigure'', true)'] ...
			, func2str(fun));
		warning off last
	else
		plothandles = vargout{1};
		end
	if isempty(plothandles)
		error('anymate:NoHandles' ...
			, 'There where no graphical output from the ''%s'' function' ...
			, char(fun));
		end
	end

function HgSpec=CollectHGData(fun,DataFuns,par)
% Step through the animation and collect all HG properties for each step

	nBreaks=DataFuns.NumBreaks();
	for iBreak=1:nBreaks

		% Call the given function. It is supposed the return all handles
		% created. If it doesn't return anything, assume that e.g. the view
		% is changing and collect data for gca.
		
		plothandles = CallbackCall(fun, DataFuns.BreakData(iBreak), par);

		% Add the axes handles. It can be that there is an axes in
		% plothandles, and that is OK too.

		handles=AllHandles(plothandles(:));

		% Collect the properties of all handles

		if iBreak==1	% If first time ...
			% Set up HgSpec containing the specification of 
			[HgHandles, hgTypes, HgSpec]=CollectionSpec(par, handles, nBreaks);
			
			% The user might create the HG objects from fresh every time,
			% or he might just SET new data. In case he creates them, we
			% want to delete them, but keep them in case they are just set.
			% We take a first time copy to later determine whether we
			% should to delete them or not.

			firsthandles = handles;
			end

		HgSpec=CollectInstance(iBreak, HgSpec, handles, HgHandles, hgTypes, par);

		if iBreak > 1
			% Delete the handles that have been created since the first
			% break
			if length(handles)~=length(firsthandles)
				error('anymate:VaryingHGObjects', 'The number of Handle Graphics objects changed between breaks');
				end
			ixdiffs=handles ~= firsthandles;
			delete(handles(ixdiffs));
			if iBreak == 2
				% Delete the handles from the first break that where
				% "replaced" but not deleted in the second break
				fh=firsthandles(ixdiffs);
				delete(fh(ishandle(fh)));
				end
			end
		end
	end

function z=AllAreHandles(x)
	if isa(x,'function_handle')
		z=true;
	elseif isa(x,'hg.Annotation');
		z=true;
	elseif iscell(x)
		z=all(cellfun(@AllAreHandles,x));
	else
		x=x(:);
		z=isa(x,'double') && all(ishandle(x) & floor(x)~=x);
		end
	end

function HgSpec = ExcludeConstants(HgSpec)
% Remove properties that doesn't change
	const=cellfun(@(x)isequalwithequalnans(x{:}), dim2cell(HgSpec.Data,3));
	HgSpec.Mask = HgSpec.Mask & ~const;
	end

function HgSpec = ExcludeNonNumerics(HgSpec)
% Remove properties that are empty or non-numerical
	HgSpec.Mask = HgSpec.Mask  ...
			& all(cellfun(@(x)~isempty(x) && (isnumeric(x) || islogical(x)), HgSpec.Data),3);
	end

function HgSpec = ExcludeHandleProps(HgSpec)
% Remove properties that seems to be handles
	HgSpec.Mask=HgSpec.Mask & ~all(HgSpec.IsHandle,3);
	end

function HgSpec = ExcludeVoids(HgSpec)
	if isfield(HgSpec.PropSpec,'Void')
		flagix=strmatchex(HgSpec.Props,HgSpec.PropSpec.Void);
		HgSpec.Mask(:,flagix)=false;
		end
	end

function z=getautos(h, Voids)
%GETAUTOS Return numeric properties that have an auto setting
%   Z=GETAUTOS(H) returns all properties in H that:
%   1) can be set to 'auto' or 'manual'
%   2) are currently are set to 'auto'.
%   The returned Z is a struct with fields 'Flag' and 'Prop'. The field
%   'Flag' holds a cell char array of mode property names and 'Prop' holds the
%   names of corresponding numeric properties.
%
%   Example:
%      cla
%      z=getautos(gca);
%      [z.Flag;z.Prop]'
%      ans = 
%          'ALimMode'               'ALim'              
%          'CameraPositionMode'     'CameraPosition'    
%          'CameraTargetMode'       'CameraTarget'      
%          ...                      ...

	% Get all writeable properties into a three-column cell array, first
	% column holds the names, second column holds current value and third
	% column holds possible fixed alternatives for the property. In case
	% there are no fixed set of values, the value is an empty cell.
	SetProps = set(h);
	SetNames=fieldnames(SetProps);
	Fields=[SetNames  get(h, SetNames)' struct2cell(SetProps)];

	% Discard properties specified by Voids
	Fields(strmatchex(Fields(:,1), Voids),:)=[];
	% Find properties that can be set to either 'auto' or 'manual'
	% exclusively.
	AutoIx=find(cellfun(@(x)isequal(x,{'auto';'manual'}),Fields(:,3)));
	% Find all non-empty numeric properties
	NumIx=find(cellfun(@(x)~isempty(x) && isnumeric(x), Fields(:,2)));
	% For every "AutoIx" property, there is a corresponding numeric
	% property that, when set, will change the "AutoIx" property from
	% 'auto' to 'manual'. To find these relations, we iterate through the
	% numeric properties, and set them to their present value and see if
	% any of the "AutoIx" properties have changed.
	Autos=cell(length(AutoIx),2);
	CurAuto=0;
	for ix=NumIx(:)'
		% Set the numeric property to its present value
		set(h, Fields{ix,1:2});
		% Get the values of all 'auto'-'manual' flags
		NewGet=get(h,Fields(AutoIx,1))';
		% Did anyone of them change? If so, save the name of the flags
		% together with the name of the corresponding numerical property.
		ThisAuto=find(cellfun(@(x,y)~strcmp(x,y),Fields(AutoIx,2), NewGet));
		if ~isempty(ThisAuto)
			if length(ThisAuto)>1
				mp=strcat('''',Fields(AutoIx(ThisAuto),1),''',');
				mp{end}=mp{end}(1:end-1);
				mp=[mp{:}];
				warning('anymate:getautos:InconsistentAuto' ...
					, ['The property ''%s'' of ''%s'' affects more than\n' ...
					   'one mode property, (%s). This breaks ANYMATIONS\n' ...
					   'assumption that it can affect only one. Animation may be erratic.'] ...
					, Fields{ix,1}, get(h, 'Type'), mp);
				end
			ThisAuto=ThisAuto(1);
			CurAuto=CurAuto+1;
			Autos(CurAuto,:)=[Fields(AutoIx(ThisAuto),1) Fields(ix,1)];
			% Restore the flag
			set(h,Fields{AutoIx(ThisAuto),1},'auto');
			end
		end
	% If we for some reason, e.g. we were wrong in the assumption that only
	% a numeric property can change a corresponding flag-property from
	% 'auto' to 'manual', we silently adjust the number of Autos here.
	Autos=Autos(1:CurAuto,:);
	% Return the result as a struct
	z=struct('Flag', {Autos(:,1)'}, 'Prop', {Autos(:,2)'});
	end

function z=GetPropSpec(h,par)
% Return struct
%    .Void   Names of properties the are not allowed to be animated
%    .Auto   struct containing pairs of property names of auto properties,
%            such as 'XLimMode' and 'XLim'
%               .Flag  Name of "Mode"-property
%               .Prop  Name of corresponding auto property
%    .Lim    Name of a Lim property that are to be collected and set once
%            before animation starts.
%

	% These are the limits we know of today (2007b)
	LimSpecs = struct( ...
		  'axes', {{'ALim' 'CLim' 'XLim' 'YLim' 'ZLim'}} ...
		);

	% We definitely do not want to animate read-only properties
	z.Void = roproperties(h);
	% Concatenate with the special cases
	type = get(h, 'Type');
	VoidSpecs=AnimationVoids;
	if isfield(VoidSpecs, type)
		Voids=VoidSpecs.(type);
	else
		Voids={};
		end
	z.Void = [z.Void Voids];
	% Find all the auto-properties
	z.Auto = getautos(h,Voids);
	% If any of the Lims we know of are set to 'auto', we return
	% the names of them in 'Lim'
 	if isfield(LimSpecs, type)
		ix=cellfun(@(x)any(strcmp(x,LimSpecs.(type))), z.Auto.Prop);
 		z.Lim=z.Auto.Prop(ix);
 		end
	end

function HgSpec = ExcludeAutos(HgSpec)
	[m,n]=size(HgSpec.Mask);
	HgSpec.Autos=false([m n]);
	if isfield(HgSpec.PropSpec, 'Auto')
		% All handles of a type have a common set of properties, so we can
		% compute the indices of where the flags are outside the loop.
		flagix=strmatchex(HgSpec.Props,HgSpec.PropSpec.Auto.Flag);
		% Find the indices of the corresponding values
		propix=strmatchex(HgSpec.Props,HgSpec.PropSpec.Auto.Prop);
		% For each handle of this type
		for i=1:m
			% Which ones are set to 'auto' for all breaks?
			autoix=all(strcmp('auto',HgSpec.Data(i,flagix,:)),3);
			% find indices in HgSpec for possible auto data
			HgSpec.Autos(i, propix(autoix)) = true;
			end
		end
	% The autos are not to be interpolated, so we remove them from Mask
	HgSpec.Mask = HgSpec.Mask & ~HgSpec.Autos;
	end

function z=strmatchex(targ,keys)
	z=arrayfun(@(x)strmatch(x,targ,'exact'), keys, 'Uniform', false);
	z=[z{:}];
	end

function HgSpec=FindFixed(HgSpec)
% Retrieve minimum and maximum over all breaks of pertinent *Lim properties
% Return them as an array of structs in HgSpec.Fixed
	if  isfield(HgSpec.PropSpec, 'Auto') ...
		&& isfield(HgSpec.PropSpec, 'Lim') ...
		&& ~isempty(HgSpec.PropSpec.Lim)

		% Get number of handles of this type
		nh=size(HgSpec.Data,1);
		% Where in .Props are .Lim, the properties we are interested in
		limix=strmatchex(HgSpec.Props, HgSpec.PropSpec.Lim);
		% Get all limits into an ordinary array,
		% (NumHandles-by-2*NumLimProps-by-NumBreaks). Odd indices in the
		% second dimension will hold minima, while even indices will hold
		% maxima.
		allmnmx=cell2mat(HgSpec.Data(:,limix,:));
		% Preallocate the minmax
		mnmx=zeros(nh,2*length(limix));
		% Retrieve minima and maxima
		mnmx(:,1:2:end-1,:) = min(allmnmx(:,1:2:end-1,:),[],3);
		mnmx(:,2:2:end,:) = max(allmnmx(:,2:2:end,:),[],3);
		% Convert to a cell array of min-max pairs
		cmnmx=mat2cell(mnmx,ones(1,nh),2*ones(1,length(limix)));
		% We just want to set the Lim properties that where set to 'auto',
		% so get those set to auto into autoix
		autoix=HgSpec.Autos(:,limix);
		% Preallocate
		HgSpec.Fixed=cell(nh,1);
		% For each handle in type
		for i=1:nh
			% Find property names of auto properties
			f=HgSpec.Props(limix(autoix(i,:)));
			% Values of corresponding auto properties
			c=cmnmx(i,autoix(i,:));
			HgSpec.Fixed{i}=cell2struct(c,f,2);
			end
	else
		HgSpec.Fixed={};
		end
	end

function z=isTimeTick(ax,nb)
% Check if AX can be a TimeTick vector. Must be a vector, numeric, length
% equal to number of ticklabels or one more and must be monotonically
% increasing.
	z=isnumeric(ax) && isvector(ax) && (nb == length(ax) || nb + 1 == length(ax)) && all(diff(ax)>0);
	end

function [par, msg]=parcheck(par)
	msg(1).identifier='anymate:IllPar';
	if ~isempty(par.Include)
		s=par.Include;
		if ~isstruct(s)
			if ischar(s)
				s=cellstr(s);
				end
			if ~iscellstr(s)
				msg.message('Include argument must be a struct or one of ''Camera'' or ''Limits''');
				return
				end
			ShortCuts={'Camera', 'Limits'};
			Expands={ {'CameraPosition', 'CameraTarget', 'CameraUpVector', 'CameraViewAngle', 'View'}
					  {'ALim', 'CLim', 'XLim', 'YLim', 'ZLim','DataAspectRatio'}
					  };
			ix=keyfun(@partialmatchix,ShortCuts,s);
			par.Include=struct;
			par.Include.axes=[Expands{ix}];
			end
		end
	msg=[];
	end

function [fun, DataFuns, hf, par, msg]=animate_argcheck(Defaults, vargin)
	% Separate positional and named arguments
	[args,parms]=parseparams(vargin);
	% Put named arguments into a struct
	par=args2struct(Defaults, parms);
	% Put single parameter into a cell
	if ~iscell(par.Parameters)
		par.Parameters = {par.Parameters};
		end

	nargs=length(args);
	msg=nargchk(0,4,nargs, 'struct');
	if ~isempty(msg); return;end
	fun=[];
	DataFuns=[];
	hf=[];
	msg(1).identifier='anymate:IllPar';
	msg(1).message='';
	if nargs==1
		if ~all(ishandle(args{1}))
			msg.message='Single parameter must be handles to figures';
			return;
			end
		hf=args{1};
	elseif nargs>1
		fun=args{1};
		if ~isa(fun, 'function_handle')
			msg.message='First parameter must be a function handle';
			return;
			end
		[DataFuns,msg.message]=datahandler(args{2}, par.Spread);
		if isempty(DataFuns)
			return;
			end
		end
	Tick=[];
	TickLabel={};
	base=3;
	while base <= nargs
		if iscellstr(args{base})
			if ~isempty(TickLabel)
				msg.message='Ticklabel is set twice';
				return
				end
			if length(args{base})~=DataFuns.NumBreaks();
				msg.message='Number of TickLabels must be the same as number of breaks';
				return
				end
			TickLabel=args{base};
			base=base+1;
		elseif isnumeric(args{base})
			if ~isTimeTick(args{base}, DataFuns.NumBreaks())
				msg.message ='Invalid time ticks';
				return;
				end
			Tick=args{base};
			base=base+1;
		else
			msg.message= 'Illegal parameter type';
			return;
			end
		end
	par.Tick = Tick;
	par.TickLabel = TickLabel;
	msg=[];
	end
% File: animation.m ######################################################################
function fun=animation(varargin)
%ANIMATION Animate a sequence linearly
%   ANIMATION(varargin)

	% Make sure "global" variables are defined.

	G = struct( ...
		  'ic', [] ...				% Holds icons for play button
		, 'TimeLineFuns', []	...	% function handles to timeline functions
		, 'ShuttingDown', false ...	% Are we shutting down the animation
		, 'HgAnim',[] ...			% Specifies where property data will go
		, 'iData', [] ...			% Pure animation data
		, 'handles', [] ...			% Live handles of the animation objects
		, 'h', struct(		...		% Handles of our own GUI objects
			  'fig', []	...			%   Main figure
			, 'SetupFig', []...		%   Controls dialog
			, 'AniToolbar', [] ...	%   Figure toolbar
			, 'Save', []	...		%      Save button
			, 'Rewind', []	...		%      To beginning
			, 'StepB', []	...		%      Single step backwards
			, 'Play', []	...		%      Play
			, 'StepF', []	...		%      Single step forward
			, 'ToEnd', []	...		%      To end
			, 'Setup', []	...		%      Display controls dialog
			) ...
		);
	TS.Stop=@NullFun;				% Timeslice object with fake stop, in case we panic during setup
	TL=NullTimeLine;				% Timeline object
 	try
		main(varargin{:});
	catch
		le=lasterror;
		% Make sure everything is restored if
		% user have entered somthing stupid.
		try
			ShutDown;
		catch
			end
		rethrow(le);
		end
	fun.ShutDown=@ShutDown;
	return

%==========================================================================
%- Utility functions ------------------------------------------------------
%==========================================================================

	function AssertTitleBar(hf)
	% When adding a toolbar, the title bar may move upwards and become
	% unaccessable.
		if ~strcmp(get(hf, 'WindowStyle'), 'docked')
			Units=pushprop(hf, 'Units', 'pixel');
			pos=get(hf, 'OuterPosition');
			ssz=get(0, 'ScreenSize');
			pos(2)=pos(2)+min(0,ssz(4)-sum(pos([2 4])));
			set(hf, 'OuterPosition', pos);
			Units.pop();
			end
		end
	function varargout=NullFun(varargin)
		varargout{1}=[];
		end

	function EnableButton(h,enable)
		set(h,'Enable', onoff(enable));
		end

	function z=isnear(a,b)
		if nargin<2; b=0; end
		z=abs(a-b)<=sqrt(eps);
		end

%==========================================================================
%- Utility functions ------------------------------------------------------
%==========================================================================

	function z=RunMode(rm)
	% If the Circle tool is disabled, the runmode is set by another GUI
	% that can also set the runmode to 'forward'. Since the tool just has
	% two states, we do the best and show it as pingpong. However, if the
	% control is enabled, it is forced to pingpong.

		if nargin<1
			z=TS.RunMode();
		else
			switch rm
				case 'circle', State='on';
				case 'pingpong', State='off';
				otherwise
					State='off';
					if onoff(get(G.h.Circle, 'Enable'))
						rm='pingpong';
						end
				end
			set(G.h.Circle, 'State', State);
			TS.RunMode(rm);
			TL.RunMode(rm);
			end
		end

	function z=RunMethod(rm)
	% If the Pchip tool is disabled, the runmethod is set by another GUI
	% that can also set the runmethod to 'spline'. Since the tool just has
	% two states, we do the best and show it as pchip. However, if the
	% control is enabled, we force it to pchip.

		if nargin<1
			z=TS.Method();
		else
			switch rm
				case 'pchip', State='on';
				case 'linear', State='off';
				otherwise
					State='on';
					if onoff(get(G.h.Pchip, 'Enable'))
						rm='pchip';
						end
				end
			set(G.h.Pchip, 'State', State);
			TS.Method(rm);
			end
		end

	function z=AxisVisible(State)
		if nargin<1
			z=TL.Visible();
		else
			TL.Visible(State);
			set(G.h.Timeline, 'State', onoff(State));
			end
		end

	function z=FigureResizeFcn(obj, event) %#ok<INUSD>
		NewStyle=get(obj, 'WindowStyle');
		if ~strcmp(NewStyle, 'docked') && strcmp(G.FigureWindowStyle, 'docked')
			AssertTitleBar(obj);
			end
		G.FigureWindowStyle=NewStyle;
		z=true;
		end

	function FigureCreateFcn(obj, event) %#ok<INUSD>
		function CheckDelayedPlay
			if TS.IsPlaying() && onoff(get(G.h.Play, 'State'))
				% We come here if the animation was saved in a running
				% state. Even though IsPlaying is true, the timer isn't
				% running, since it has no timer object at this point. We
				% sync the states of the Play button with the timeslice
				% object by cycling a full Stop/Play. This will turn off
				% IsPlaying in TS and then turn it on again, in sync with
				% timer creation.
				set(G.h.Play, 'State', 'off');
				set(G.h.Play, 'State', 'on');
				end
			end

		function LoadHung
			warning('animation:LoadHung' ...
				, [	'Animation took more than 10 seconds to load from file.\n' ...
					'Can not initiate check to start animation']);
			end

		G.h.fig = obj;
		% Are we created from file? Guess we never land here if we aren't,
		% but better safe than sorry. If we are, we must wait until all
		% objects are finished loading and then see if we are to fire up
		% the animation. There ought to be a documented way to accomplish
		% this...
		if ~isempty(getappdata(0,'BusyDeserializing'))
			% If the user has disabled the warning for LoadHung, guess he
			% knows what he's doing and wait forever for figure to load.
			warnstate=warning('query','animation:LoadHung');
			if onoff(warnstate.state)
				TimeoutArgs={'Timeout', 10, 'TimeoutFcn', @LoadHung};
			else
				TimeoutArgs={};
				end
			% Check for animation start when the whole figure is loaded
			callwhen( ...
				  @()isempty(getappdata(0,'BusyDeserializing')) ...
				, @CheckDelayedPlay ...
				, TimeoutArgs{:} ...
				);
			end
		drawnow;
		end

	function UpdateEnabling(Running) %#ok<INUSD>
		% Placeholder for setting GUI state. Have been in use in
		% previous versions, but made obsolete when all the states went
		% away.
		if ~onoff(get(G.h.fig,'BeingDeleted'))
			end
		end

%==========================================================================
% Timeslice callbacks. These functions are called from the timeslice object
%==========================================================================

	function TimerStart(obj, event) %#ok<INUSD>
		UpdateEnabling(true);
		set(G.h.Play,'CData', G.ic.Pause);
		end

	function TimerStop(obj, event) %#ok<INUSD>
		if ishandle(G.h.fig) ...
			&& ~onoff(get(G.h.fig,'BeingDeleted')) ...
			&& ~G.ShuttingDown
			set(G.h.Play,'CData', G.ic.Play, 'State', 'off');
			UpdateEnabling(false);
			end
		end

	function TimerFcn(Data,t)
	% Time to render a new frame. Forward the data to the animated objects
	% and also to the timeline.
		RenderFrame(Data);
		TL.Time(t);
		% Make sure we process the event queue so we can stop the animation
		% if we are overloaded.
		drawnow;
		end

%==========================================================================
%- Toolbar callbacks ------------------------------------------------------
%==========================================================================

	function ButtonStartTimer(obj,event) %#ok<INUSD>
		% This routine can, under normal circumstances, only be called when
		% the TS.IsPlaying is false. If TS.IsPlaying and button state is
		% out of sync, we are loaded from file that holds a runing
		% animation. Since there possibly are objects that aren't loaded
		% yet, we can't start the timer right now. Instead, this will be
		% taken care of by the figure's CreateFcn.

		if ~TS.IsPlaying()
			TS.Play();
			end
		end

	function ButtonStopTimer(obj,event) %#ok<INUSD>
		TS.Stop();
		end

	function ButtonRewind(obj,event) %#ok<INUSD>
	% Go to the first breakpoint
		tt=TS.TTick();
		GotoViewPoint(tt(1));
		end

	function ButtonStepB(obj,event) %#ok<INUSD>
	% Go to the previous breakpoint. If we are not on a breakpoint, we go
	% to the nearest previous.
		Time=TS.Time();
		TTick=TS.TTick();

		TickNo=find(isnear(Time,TTick));
		if isempty(TickNo)
			TickNo=find(TTick < Time,1, 'last');
		else
			% Go to previous or to the last if already at the beginning
			TickNo=mod(TickNo-2,length(TTick))+1;
			end
		GotoViewPoint(TTick(TickNo));
		end

	function ButtonStepF(obj,event) %#ok<INUSD>
	% Go to the next breakpoint. If we are not on a breakpoint, we go
	% to the nearest next.
		Time=TS.Time();
		TTick=TS.TTick();

		TickNo=find(isnear(Time,TTick));
		if isempty(TickNo)
			TickNo=find(TTick > Time,1);
			if isempty(TickNo)
				% We're circling and past last tick
				TickNo=1;
				end
		else
			TickNo=mod(TickNo,length(TTick))+1;
			end
		GotoViewPoint(TTick(TickNo));
		end

	function ButtonToEnd(obj,event) %#ok<INUSD>
	% Go to the last breakpoint.
		tt=TS.TTick();
		GotoViewPoint(tt(end));
		end

	function ButtonSave(obj,event) %#ok<INUSD>
	% Save the animation to memory(TODO) or file.
		% Get the filetype to save in and also the current state of the
		% animation window. Saving will resize the figure window for some
		% filetypes and figSave will enable us to restore it.
		[ftype,figSave]=anifile(G.h.fig);
		if isempty(ftype)
			return;
			end
		[fn,p]=uiputfile(['*.' ftype], 'Save animation as');
		if isnumeric(fn)
			set(G.h.fig, figSave);
			return;
			end
		fn=fullfile(p,fn);
		% Make it hard to interrupt the save
		hButtons=[G.h.Save G.h.Rewind G.h.Play G.h.ToEnd G.h.StepB G.h.StepF];
		EnableButton(hButtons,false);
		set(G.h.fig, 'pointer','watch');
		try
			% Save running state and "time" position
			SavedIsPlaying=TS.IsPlaying();
			SavedTime=TS.Time();
			TS.Stop();
			tmp=[];
			GotErr=false;
			if strcmp(ftype, 'wmv')

				% If we land here, we're on a PC and have the WMV-encoder
				% installed. Animate to an AVI and then start up the
				% encoder as a separate process to convert to WMV. Really
				% wanted to do this in TMP-dir, but I can't get the
				% WMV-encoder to encode files located under that dir!

				tmp=sprintf('t%.15e.avi', rand);
				AnimateToFile(TS,tmp,G.h.fig,'avi');
				encodewmv(tmp, fn);
				delete(tmp);
			else
				AnimateToFile(TS,fn,G.h.fig,ftype);
				end
		catch
			GotErr=true;
			delete(tmp);
			end
		set(G.h.fig, 'pointer','arrow');
		% Supress warning if figure is docked
		s=warning('off', 'MATLAB:Figure:SetPosition');
		set(G.h.fig, figSave);
		warning(s);
		EnableButton(hButtons,true);
		TS.Time(SavedTime);
		if SavedIsPlaying
			TS.Play();
			end
		if GotErr
			rethrow(lasterror);
			end
		end

	function ButtonSetup(obj,event) %#ok<INUSD>
	% Let the user change some parameters interactively. If it already
	% exists, just bring to top.

		function z=ControlDeleted(obj,event) %#ok<INUSD>
			G.h.SetupFig = [];
			RunMode(RunMode());
			RunMethod(RunMethod());
			set([G.h.Circle;G.h.Pchip],{'Enable'}, {onoff(TS.CanCircle());'on'});
			set([G.h.Circle;G.h.Pchip], {'Tooltip'}, oldtip);
			% Let other callbacks be called to.
			z=true;
			end

		if ~isempty(G.h.SetupFig)
			figure(G.h.SetupFig);
		else
			% Disable setting RunMode and RunMethod from the toolbar, since
			% it will be handled by the anicontrol dialog. Also indicate to
			% the user that the window is open.
			ht=[G.h.Circle;G.h.Pchip];
			oldtip=get(ht, {'ToolTip'});
			set(ht, 'Enable', 'off');
			set(ht, 'ToolTip', 'Use the open anicontrol dialog to set this parameter');
			% Setup function arguments for anicontrol to get/set the
			% parameters in question.
			funs = struct( ...
				  'Duration'	, TS.Duration ...
				, 'Frequency'	, TS.Frequency ...
				, 'RunMode'		, @RunMode ...
				, 'Loop'		, TS.Loop ...
				, 'Method'		, @RunMethod ...
				);
			rofuns = struct( ...
				  'CanCircle'   , TS.CanCircle ...
				);
			% Bring up the settings dialog
			G.h.SetupFig = anicontrol(funs,rofuns);
			% Make sure we're notfied when the dialog is closed.
			chaincallback(G.h.SetupFig, 'DeleteFcn', @ControlDeleted);
			end
		end

	function ButtonRunMode(obj,evt) %#ok<INUSD>
	% Callback for RunMode toolbar button
		if onoff(get(obj, 'State'))
			RunMode('circle');
		else
			RunMode('pingpong');
			end
		end

	function ButtonPchip(obj,evt) %#ok<INUSD>
	% Callback for RunMethod toolbar button
		if onoff(get(obj, 'State'))
			RunMethod('pchip');
		else
			RunMethod('linear');
			end
		end

	function ButtonTime(obj,event) %#ok<INUSD>
	% Callback for timeline toolbar button
		% Toggle timeline visibility
		TL.Visible(onoff(get(obj,'State')));
		end

%==========================================================================
%- Objects callbacks ------------------------------------------------------
%==========================================================================

	function GenericCreateFcn(obj, event) %#ok<INUSD>
	% Tags are carefully selected to be used as names in the G.h struct.
	% This create-function will give us valid handles even when the
	% animation is reloaded from file.
	
		G.h.(get(obj, 'Tag')) = obj;
		end
	
	function GotoViewPoint(t)
		TS.Time(t);
		UpdateEnabling(TS.IsPlaying());
		end

	function SafeDelete(h)
		delete(h(ishandle(h)));
		end

	function AnimObjDeleteFcn(h, evt) %#ok<INUSD>
		G.handles(G.handles==h)=0;
		if ~G.ShuttingDown
			% Check if there are any objects, except for figure and axes,
			% left to animate. We've really never animate 'root', but
			% G.handles have zeroes as placeholders for deleted objects
			types=get(G.handles, {'Type'});
			if ~any(cellfun(@isempty,regexp(types,'(axes|figure|root)')));
				ShutDown;
				end
			end
		end

	function ShutDown(obj,event) %#ok<INUSD>
	% Shut down the animation; Stop possible animation, delete everything
	% that has directly to do with the animation and die. This routine must
	% cope with being called repetitively at shutdown.
	% The previous statement was true once upon a time. The logic was 
	% changed when removing a single object without closing down the
	% animation became allowed.

		if ~G.ShuttingDown
			% Only need one pass through
			G.ShuttingDown = true;
			TS.Stop('panic');
			if ishandle(G.h.fig)

				% We don't want to be called back when user tries to
				% zoom/pan/rotate anymore.

				ExploreException(G.h.fig, []);
				
				% Restore some figure callbacks
				unchaincallback(G.h.fig, 'CreateFcn', G.RestoreId.FigureCreateFcn);
				unchaincallback(G.h.fig, 'DeleteFcn', G.RestoreId.FigureDeleteFcn);

				% We might be shutting down because object(s) were deleted
				% by the user. In that case, we must take care in not
				% unchaining callbacks of non-existing objects.

				ix=ishandle(G.handles);
				unchaincallback(G.handles(ix), 'CreateFcn', G.RestoreId.AnimObjCreateFcn(ix));
				unchaincallback(G.handles, 'DeleteFcn', G.RestoreId.AnimObjDeleteFcn(ix));
				
				% Make sure the toolbar and possible setup dialog are
				% deleted.
				
				SafeDelete([G.h.SetupFig G.h.AniToolbar]);
				G.h.SetupFig = [];
				G.h.AniToolbar=[];
				
				% Remove the timeline.
				TL.Close();
				end
			end
		end

%==========================================================================
%- Animation Objects Callbacks --------------------------------------------
%==========================================================================

	function ObjectCreateFcn(h,evt,ix) %#ok<INUSL,INUSD>
		G.handles(ix)=h;
		end

%==========================================================================
%- Initialization routines ------------------------------------------------
%==========================================================================

	function BuildToolbar
		fn={'Tool'			'Name'      'Callbacks'					'Separator' 'ToolTip'};
		dt={
			@uipushtool		'Save',		{'Clicked'	@ButtonSave}	'off'	'Save Animation'
			@uitoggletool	'Play'		{'On'		@ButtonStartTimer;'Off', @ButtonStopTimer} 'on' 'Play animation'
			@uipushtool		'Rewind'	{'Clicked'	@ButtonRewind}	'on'	'Go to beginning'
			@uipushtool		'StepB'		{'Clicked'	@ButtonStepB}	'off'	'Step backward'
			@uipushtool		'StepF'		{'Clicked'	@ButtonStepF}	'off'	'Step forward'
			@uipushtool		'ToEnd'		{'Clicked'	@ButtonToEnd}	'off'	'Go to end'
			@uitoggletool	'Pchip'		{'Clicked'	@ButtonPchip}	'on'	'Smooth interpolation'
			@uitoggletool	'Circle'	{'Clicked'	@ButtonRunMode}	'off'	'Run mode'
			@uipushtool		'Setup'		{'Clicked'	@ButtonSetup}	'off'	'Set parameters'
			@uitoggletool	'Timeline'	{'Clicked'	@ButtonTime}	'on'	'Show time axis'
			};

		% Transform specification into a struct
		s=cell2struct(dt,fn,2);
		% Load the icons to be used
%		ic=load(fullfile(fileparts(mfilename('fullpath')),'private','ani_icons')); % Works better with MCC
		ic=ani_icons;
		prevToolbar = findobj(G.h.fig, 'Type', 'uitoolbar','Tag','AniToolbar');
		if ~isempty(prevToolbar)
			delete(prevToolbar);
			end
		% Create the empty toobar
		uitoolbar(G.h.fig ...
			, 'Tag', 'AniToolbar' ...
			, 'CreateFcn', @GenericCreateFcn ...
			, 'HandleVisibility', 'off');
		% For each tool
		for i=1:length(s)
			% Shorter version of name of tool
			name = s(i).Name;
			% Build a cell array of callbacks for this tool
			Callbacks=cell(2,size(s(i).Callbacks,1));
			for j=1:size(s(i).Callbacks,1)
				Callbacks{1,j}=[s(i).Callbacks{j,1} 'Callback'];
				Callbacks{2,j}=s(i).Callbacks{j,2};
				end
			% Create the tool and set various scalar items. The CreateFcn
			% will create an entry in G.h with the resulting handle.
			s(i).Tool(G.h.AniToolbar ...
				, 'CData', ic.(name) ...
				, 'Tag', name ...
				, 'Separator', s(i).Separator ...
				, 'TooltipString', s(i).ToolTip ...
				, 'CreateFcn', @GenericCreateFcn ...
				, Callbacks{:} ...
				);
			end

		% Some icons are changed dynamically so we save the lot "globally"
		set(G.h.Circle, 'Enable', onoff(TS.CanCircle()));
		G.ic=ic;
		end

%==========================================================================
%- Animation renderer -----------------------------------------------------
%==========================================================================

	function RenderFrame(Data)
	%RENDERFRAME Unpack properties and set corresponding HG objects
	%   This is the animation workhorse and is called for every frame of
	%   the animation. DATA is a column vector of Handle Graphics property
	%   data, one column for each break. These floating point values are
	%   unpacked into cell arrays, specified by HgAnim and handles.
		
		function z=getData(Prop)
		% Extract data for a single property and return it with proper size
		% and class.
		
			z=reshape(cast(Data(Prop.range(1):Prop.range(2)),Prop.class), Prop.sz);
			end

		function setType(HgAnim)
		% This function is called once for each HG type. Since the number
		% of properties can change for each object, we must loop through
		% all the individual handles.

			nh=length(HgAnim.Handles);
			for i=1:nh
				h=G.handles(HgAnim.Handles(i));
				% Make sure the object hasn't been deleted
				if h~=0
					% Collect data for all properties for this handle
					s=structfun(@getData, HgAnim.Prop{i}, 'Uni', false);
					% No use setting an empty struct
					if ~isequal(s,struct)
						set(h, s);
						end
					end
				end
			end

		%
		% Render each HG type; axes, patch, surface, text, etc.
		%
		structfun(@setType, G.HgAnim);
		end

%==========================================================================
%- Null Timeline struct ---------------------------------------------------
%==========================================================================

	function z=NullTimeLine
		z = struct( ...
			  'Time', @NullFun ...
			, 'Order', @NullFun ...
			, 'Close', @NullFun ...
			, 'RunMode', @NullFun ...
			);
		end

%==========================================================================
%- Main function ----------------------------------------------------------
%==========================================================================

	function main(varargin)
		[args,par]=parseparams(varargin);
		error(nargchk(4,4,length(args), 'struct'));
		Defaults=struct( ...
			  'Filename'	, ''			... % Filename, if animating directly to file
			, 'Duration'	, []			... % Default duration time for one cycle
			, 'Frequency'	,  10			...	% Frames per second
			, 'Method'		, 'linear'		...	% Interpolation method to use
			, 'RunMode'		, 'pingpong'	...	% 'circle, 'forward', 'pingpong'
			, 'Loop'		, true			... % Let animation loop continuously
			, 'TTick'		, []			... % Assume equidistant breakpoints
			, 'TTickLabel'	, []			... % No time tick labels
			, 'Axis'		, true			... % Show timeaxis
			, 'Play'		, false			... % Let the user start the animation
			, 'Unwrap'		, false			... % Unwraps (presumably) angular data
			);

		par=args2struct(Defaults, par);
		G.h.fig = args{1};
		dbgcallback(G.h.fig);
		G.HgAnim = args{2};
		G.handles = args{3};
	
		% In case this animation is saved to a fig-file and later restored,
		% the actual values of the handles will have changed. In order to
		% work with valid handle values, we make sure the new handle values
		% are recorded by their CreateFcn. We also save their old callbacks
		% in case we must restore them. The figure window gets it's own
		% CreateFcn, since its Tag could have been set by the user and we
		% don't want to mess things up for him/her.

		m=length(G.handles);
		cb=dim2cell([repmat({@ObjectCreateFcn},m,1) num2cell((1:m)')],2);
		G.RestoreId.AnimObjCreateFcn=chaincallback(G.handles,{'CreateFcn'}, cb);
		G.RestoreId.FigureCreateFcn=chaincallback(G.h.fig, 'CreateFcn', @FigureCreateFcn);

		% If any of the objects participating in the animation is deleted,
		% we make sure the animation stops and remove our callbacks from
		% the other objects, making it a normal figure window.

		G.RestoreId.FigureDeleteFcn=chaincallback(G.h.fig, 'DeleteFcn', @ShutDown);
		G.RestoreId.AnimObjDeleteFcn=chaincallback(G.handles,'DeleteFcn', @AnimObjDeleteFcn);

		% By default, we set the Duration to 0.5 second per break, but no
		% more than ten seconds.

		nc=size(args{4},2);
		if isempty(par.Duration)
			par.Duration = min(10, nc/2);
			end

		% Create a timeslice "object". The timeslice object holds the timer
		% that will call our TimerFcn with interpolated data at a
		% par.Frequency rate.

		TS=timeslice( ...
			  @TimerFcn							...	% Function to be called at regular intervals
			, args{4}							...	% Data to be interpolated
			, par.TTick							... % 
			, 'StartFcn'	, @TimerStart		... % We want to be notified when the animation starts
			, 'StopFcn'		, @TimerStop		... %   and when it stops.
			, 'Frequency'	, par.Frequency		... % Frame rate. TimesliceFcn will be called this many times per second
			, 'Duration'	, par.Duration		...	% The duration of one cycle
			, 'RunMode'		, par.RunMode		...	% circle | forward | pingpong
			, 'Method'		, par.Method		... % Same options as method in ordinary interp1
			, 'Loop'		, par.Loop			... % Set if we want an infinite loop
			, 'Unwrap'		, par.Unwrap		... % Unwraps (hopefully) angular data
			);

		% Determine timeline lables.
		if isempty(par.TTickLabel)
			if isempty(par.TTick)
				TTickLabel=1:nc;
			else
				TTickLabel=arrayfun(@num2str,par.TTick(1:nc), 'Uniform', false);
				end
		else
			TTickLabel=par.TTickLabel;
			end
		
		% Create the timeline object.
		TL=timeline(G.h.fig ...
			, TTickLabel ...
			, par.TTick ...
			, 'RunMode', par.RunMode ...
			, 'TimeCallback', TS.Time ...
			, 'OrderCallback', TS.TickOrder ...
			, 'ShutDownCallback', @ShutDown ...
			);
		
		% Are we animating to a file or should we bring up the GUI ?
		if isempty(par.Filename)
			BuildToolbar;

			% Get the current window state. We need it so we can determine
			% when the reason for resize callback to be triggered is an
			% undocking operation.
			G.RestoreId.FigureResizeFcn=chaincallback(G.h.fig, 'ResizeFcn', @FigureResizeFcn);
			G.FigureWindowStyle = get(G.h.fig, 'WindowStyle');
			if ~strcmp(G.FigureWindowStyle, 'docked')
				% Adding the toolbar can make the figure title bar go off
				% screen, so we make sure it's visible again.
				AssertTitleBar(G.h.fig);
				end
			UpdateEnabling(false);
			AxisVisible(par.Axis);
			RunMethod(par.Method);
			RunMode(par.RunMode);
			if par.Play
				drawnow
				set(G.h.Play, 'State', 'on');
				end
		else
			AnimateToFile(TS,par.Filename,G.h.fig);
			ShutDown;
			end
		end

	end

function z=fileextension(fn)
	[p,f,e]=fileparts(fn);
	z=strrep(e,'.','');
	end

%==========================================================================
%- Save to file -----------------------------------------------------------
%==========================================================================

function AnimateToFile(ts,fn,hf, ftype)

	function QueryClose(obj, event) %#ok<INUSD>
		selection = questdlg(  'Closing will end saving to file prematurely. Really close?' ...
							 , 'Close Request Function' ...
							 , 'Yes','No','Yes');
		switch selection
			case 'Yes',
				delete(hf);
			case 'No'
				return
			end
		end
		
	function QueryCancel(obj, event) %#ok<INUSD>
		if double(get(gcf, 'CurrentCharacter'))==27
			selection = questdlg(  'Really cancel?' ...
								 , 'Cancel saving' ...
								 , 'Yes','No','No');
			Cancel=strcmp(selection, 'Yes');
			end
		end
		

	function z=AviCollect
		[X,map]=frame2im(getframe(hf));
		if ~isempty(map)
			avipar={'colormap', map};
		else
			avipar={};
			end
		avi=addframe(avi,X,avipar{:});
		z=~Cancel;
		end

	function z=GifCollect
		[X,map]=frame2im(getframe(hf));
		if isempty(map)
			[ind,map]=rgbconvert(X);
		else
			ind=X;
			end
		if FrameCount==1
			imwrite(ind,map,fn,'gif' ...
				, 'DelayTime',1/ts.Frequency() ...
				, 'WriteMode','overwrite' ...
				, LoopArg{:} ...
				);
		else
			imwrite(ind,map,fn,'gif' ...
				, 'DelayTime',1/ts.Frequency() ...
				, 'WriteMode','append' ...
				);
			end
		FrameCount = FrameCount + 1;
		z=~Cancel;
		end
	
	function [ind,map]=rgb2indproxy(x)
		[ind,map]=rgb2ind(x,256);
		end

	if nargin<4
		ftype = fileextension(fn);
		end
	% Make sure no explorer mode is active
	uim=animuimode(hf, 'off');
	RestoreProperties={'CloseRequestFcn' 'KeyPressFcn'};
	Restore=get(hf, RestoreProperties);
	set(hf,{'CloseRequestFcn' 'KeyPressFcn'}, {@QueryClose @QueryCancel});
	Cancel=false;
	try
		switch ftype
			case 'gif'
				if exist('rgb2ind', 'file')==2
					rgbconvert=@rgb2indproxy;
				else
					rgbconvert=@rgb2ind256;
					end
				
				FrameCount = 1;
				if ts.Loop()
					LoopArg = {'LoopCount',Inf};
				else
					LoopArg = {};
					end
				ts.PlaySequence(@GifCollect);
			case 'avi'
				avi=avifile(fn, 'compression', anigetpref('AviCompression'), 'fps', ts.Frequency());
				try
					ts.PlaySequence(@AviCollect);
				catch
					le=lasterror;
					close(avi);
					rethrow(le);
					end
				avi=close(avi);
			end
	catch
		set(hf, RestoreProperties, Restore);
		animuimode(hf, uim);
		rethrow(lasterror);
		end
	set(hf, RestoreProperties, Restore);
	animuimode(hf, uim);
	end
% File: AnimationVoids.m ######################################################################
function z=AnimationVoids
%ANIMATIONVOIDS Specify non-animated properties.
%   The properties specified in this file are not to be animated by
%   default. If needed, they must be enabled in the call to ANYMATE as
%   ANYMATE(..., 'Include', <propspec>).
%
%   Insert new properties if/when Mathworks ships new objects that have
%   properties that ought not be animated.

%   Animating the figures position can be fun, but it can also be a bit
%   hard to turn the animation off, since you have may have to chase the
%   figure around the screen...
%
%   Axes' Parent property can look like a property to animate, so we
%   exclude it here to be safe. 'Position' and 'Outerposition' can move
%   slightly even when they shouldn't, resulting in a jerky animation. The
%   View is included here, but not CameraPosition since the CameraPosition
%   get's excluded if its mode is set to auto. View doesn't have a mode.
%
%   Patches can be set using either [XData,YData,ZData,CData] or
%   [Faces,Vertices,FaceVertexCData]. The latter is much quicker and more
%   general so we skip the former.

	z = struct( ...
		   'figure', {{'Position'}} ...
		 , 'axes', {{ 'Position' 'OuterPosition' 'Parent' 'View'}} ...
		 , 'patch', {{ 'XData' 'YData' 'ZData' 'CData'}} ...
		);

	end
% File: animuimode.m ######################################################################
function z=animuimode(hf,state)
	ToolEnable=exploreaccessors(hf);
	z=ToolEnable();
	if nargin>1
		ToolEnable(state);
		end
	end
% File: ani_icons.m ######################################################################
function z=ani_icons
	persistent retz
	if isempty(retz)
		ic.Circle.len=[256 7 2 11 8 7 2 6 2 5 2 8 2 3 2 10 2 2 2 11 1 1 5 9 1 1 5 9 2 1 3 10 2 2 1 11 2 14 1 14 2 13 2 5 2 6 2 6 9 8 1 2 3 13 2 11 8 7 2 6 2 5 2 8 2 3 2 10 2 2 2 11 1 1 5 9 1 1 5 9 2 1 3 10 2 2 1 11 2 14 1 14 2 13 2 5 2 6 2 6 9 8 1 2 3 6 7 2 11 8 7 2 6 2 5 2 8 2 3 2 10 2 2 2 11 1 1 5 9 1 1 5 9 2 1 3 10 2 2 1 11 2 14 1 14 2 13 2 5 2 6 2 6 9 8 1 2 3 6];
		ic.Circle.val=[0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
		ic.Pause.len=[256 84 9 7 9 39 9 7 9 167 9 7 9 39 9 7 9 83 84 9 7 9 39 9 7 9 83];
		ic.Pause.val=[0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
		ic.Pchip.len=[40 1 12 1 1 1 12 1 14 1 31 1 16 1 16 1 18 1 16 1 63 1 6 8 1 15 1 14 1 1 11 1 1 1 1 11 1 1 14 1 14 2 15 1 15 1 1 15 1 1 1 15 2 1 15 1 1 15 1 15 1 15 1 15 1 14 1 15 1 14 1 1 11 1 1 1 1 11 1 1 14 1 14 2 15 1 15 1 1 15 1 1 1 15 2 1 15 1 1 15 1 15 1 15 1 15 1 6 8 1 15 1 14 2 11 4 11 2 14 1 14 2 15 1 15 2 15 3 15 3 15 2 15 1 15 1 15 1 15 1 6];
		ic.Pchip.val=[0 0.01 0 0.01 0 0.01 0 0.01 0 0.01 0 0.01 0 0 0 0 0 0.01 0 0 0 0.01 0 1 0 1 0 1 0 0.01 1 0 0.01 0 0.01 1 0 0.01 1 0.01 1 0 1 0.01 1 0 0 1 0 0 0 1 0 0.01 1 0 0 1 0 1 0 1 0 1 0.01 1 0 1 0 1 0 0.01 1 0 0.01 0 0.01 1 0 0.01 1 0.01 1 0 1 0.01 1 0 0 1 0 0 0 1 0 0.01 1 0 0 1 0 1 0 1 0 1 0.01 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
		ic.Play.len=[256 100 9 8 7 10 5 12 3 14 1 187 9 8 7 10 5 12 3 14 1 87 100 9 8 7 10 5 12 3 14 1 87];
		ic.Play.val=[0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
		ic.Rewind.len=[256 20 9 7 9 27 1 14 3 12 5 10 7 8 9 27 1 14 3 12 5 10 7 8 9 39 9 7 9 27 1 14 3 12 5 10 7 8 9 27 1 14 3 12 5 10 7 8 9 19 20 9 7 9 27 1 14 3 12 5 10 7 8 9 27 1 14 3 12 5 10 7 8 9 19];
		ic.Rewind.val=[0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
		ic.Save.len=[34 12 10 6 4 6 1 1 8 6 1 1 8 2 9 5 3 7 6 4 5 7 5 3 8 6 1 1 1 3 4 6 1 1 1 3 10 2 8 1 1 10 34 17 13 3 1 12 1 2 7 6 1 2 1 6 1 1 5 2 1 6 1 1 5 2 1 2 11 2 1 3 10 2 1 4 9 2 1 5 8 2 1 6 1 1 1 3 1 2 1 6 1 1 1 3 1 2 7 2 5 2 1 1 1 10 1 2 14 34 13 3 14 2 14 2 1 6 7 2 1 6 7 2 1 2 11 2 1 3 10 2 1 4 9 2 1 5 8 2 1 6 3 3 1 2 1 6 3 3 1 2 14 2 1 1 12 2 14 17 17 13 3 14 2 14 2 14 2 14 2 14 2 14 2 14 2 14 2 14 2 14 2 14 2 14 2 14 17];
		ic.Save.val=[0 0.45 0 0.45 0 0.83 0 0.45 0 0.83 0 0.45 0 0.83 1 0 0.83 1 0 0.83 1 0 0.83 1 0 0.83 1 0.45 0 0.83 0 0.83 0 0.45 0 0.83 0 0.45 0 0.83 0 0.45 0 1 0 1 0 0.45 0 1 0 0.45 0 1 0 0.82 0 0.45 0 1 0 0.82 0 0.45 0 1 0 0.82 0 1 0 0.82 0 1 0 0.82 0 1 0 0.82 0 1 0 0.82 0 0.45 0 0.82 0 1 0 0.82 0 0.45 0 0.82 0 1 0 0.45 0 1 0 0.82 0 0.45 0 1 0 1 0 1 0 1 0 1 0 0.78 0 1 0 0.78 0 1 0 0.78 0 1 0 0.78 0 1 0 0.78 0 1 0 0.78 0 1 0 0.78 0 0.78 0 1 0 0.78 0 0.78 0 1 0 1 0 0.78 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
		ic.Setup.len=[256 86 2 1 2 11 2 1 2 11 2 1 2 11 2 1 2 11 2 1 2 11 2 1 2 171 2 1 2 11 2 1 2 11 2 1 2 11 2 1 2 11 2 1 2 11 2 1 2 85 86 2 1 2 11 2 1 2 11 2 1 2 11 2 1 2 11 2 1 2 11 2 1 2 85];
		ic.Setup.val=[0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
		ic.StepB.len=[256 56 1 14 3 12 5 10 7 8 9 23 9 7 9 139 1 14 3 12 5 10 7 8 9 23 9 7 9 83 56 1 14 3 12 5 10 7 8 9 23 9 7 9 83];
		ic.StepB.val=[0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
		ic.StepF.len=[256 84 9 7 9 23 9 8 7 10 5 12 3 14 1 139 9 7 9 23 9 8 7 10 5 12 3 14 1 55 84 9 7 9 23 9 8 7 10 5 12 3 14 1 55];
		ic.StepF.val=[0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
		ic.Timeline.len=[22 4 1 3 1 1 6 3 2 1 2 1 1 6 4 1 1 3 1 6 4 2 2 1 1 6 5 3 1 1 6 5 2 2 1 6 5 1 3 1 6 5 2 2 1 6 3 2 3 1 1 6 4 1 3 1 1 6 3 2 1 3 1 6 4 1 3 1 1 6 5 3 1 1 6 4 4 1 1 16 26 1 3 1 1 9 2 1 2 1 1 10 1 1 3 1 10 2 2 1 1 11 3 1 1 11 2 2 1 11 1 3 1 11 2 2 1 9 2 3 1 1 10 1 3 1 1 9 2 1 3 1 10 1 3 1 1 11 3 1 1 10 4 1 1 42 1 3 1 1 9 2 1 2 1 1 10 1 1 3 1 10 2 2 1 1 11 3 1 1 11 2 2 1 11 1 3 1 11 2 2 1 9 2 3 1 1 10 1 3 1 1 9 2 1 3 1 10 1 3 1 1 11 3 1 1 10 4 1 1 16 22 10 6 10 6 10 6 10 6 10 6 10 6 10 6 10 6 10 6 10 6 10 6 10 6 10 6 10 16];
		ic.Timeline.val=[0 1 0 0.96 0.07 0.96 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0.96 0.07 0.96 0 1 0 0.96 0.07 0.96 1 0 1 1 0 1 1 0 1 0 1 1 0 1 0 1 1 1 0 1 1 1 0 1 1 1 0 1 1 1 0 1 1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 1 1 0 1 1 0.96 0.07 0.96 1 0 0.96 0.07 0.96 1 0 1 1 0 1 1 0 1 0 1 1 0 1 0 1 1 1 0 1 1 1 0 1 1 1 0 1 1 1 0 1 1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 1 1 0 1 1 0.96 0.07 0.96 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
		ic.ToEnd.len=[256 20 9 8 7 10 5 12 3 14 1 27 9 8 7 10 5 12 3 14 1 27 9 7 9 39 9 8 7 10 5 12 3 14 1 27 9 8 7 10 5 12 3 14 1 27 9 7 9 19 20 9 8 7 10 5 12 3 14 1 27 9 8 7 10 5 12 3 14 1 27 9 7 9 19];
		ic.ToEnd.val=[0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
		retz=structfun(@decompress, ic, 'UniformOutput', false);
		end
	z=retz;
	end

function z=decompress(x)
	i = cumsum([1 x.len]);
	j = zeros(1,i(end)-1);
	j(i(1:end-1)) = 1;
	z = reshape(x.val(cumsum(j)),[16 16 4]);
	ixnum=z(:,:,4);
	z=z(:,:,1:3);
	z(~logical(ixnum))=nan;
	end
% File: <..\jwtools\jwgeneral\>appdata.m ######################################################################
function z=appdata(h, field, value)
%APPDATA Handle setting of data in objects appdata property
%   Z=APPDATA(H,'Field') retrieves a named value 'Field' out of the
%   appdata property of the object with handle H. The 'Field' is stored as
%   a struct field in APPDATA.
%   Z=APPDATA(H,{'Field1' 'Field2'... 'FieldN'} retrives the value stored
%   at GET(H,'ApplicationData').Field1.Field2...FieldN. If any of the fields
%   'Field1' through 'FieldN' does not exist, the empty value, [], is returned.
%   APPDATA(H,'Field', VAL) assigns the value VAL to the name 'Field' at
%   the the top of the appdata structure.
%   APPDATA(H,{'Field1' 'Field2'... 'FieldN'},VAL) assigns VAL to
%   <APPDATA>.Field1.Field2...FieldN. The specified fields not not need to
%   exist before the call to APPDATA. If VAL is empty the corresponding
%   field, and all other predecessor fields in <APPDATA> is removed.
%
%   Remark:
%   The fact that all 'unnecessary' fields are removed, makes it easy to
%   use the appdata property in a 'clean' fashion. Although the
%   usefulness of the appdata property has lessened with the introduction
%   of nested functions, it still can be useful for mass storage of
%   handles that need to be refreshed when objects are restored from file.
%
%   Example:
%   The example shows that the APPDATA can coexist with other methods of
%   storing data in the appdata property.
%
%   set(gcf, 'ApplicationData', struct('OldMethod', 4711));
%   appdata(gcf, {'MyHandles', 'h1'}, subplot(121));
%   appdata(gcf, {'MyHandles', 'h2'}, subplot(122));
%   appdata(gcf, 'MyHandles')              % Retrieves both handles;
%   get(gcf, 'ApplicationData')	                % Check actual storage
%	appdata(gcf, {'MyHandles', 'h1'}, []); % Delete first handle
%   appdata(gcf, {'MyHandles', 'h2'}, []); % And the second
%   get(gcf,'ApplicationData')                     % Verify that no trace is left

	error(nargchk(2,3,nargin, 'struct'));
	if ~isscalar(h) || ~ishandle(h)
		error('appdata:InvalidHandle', 'Handle is not valid');
		end
	if ~ischar(field) && ~iscellstr(field)
		error('appdata:StringRequired', 'Field name must be string or cell string');
		end
	if ischar(field)
		field=regexp(field,'[^.]*', 'match');
		end
	field = cellstr(field);
	appfield=field{1};
	s=[repmat({'.'},1,length(field));field(:)'];
	tmp.(appfield)=getappdata(h,appfield);
	S=substruct(s{:});
	if nargin < 3
		try
			z=subsref(tmp,S);
		catch
			z=[];
			end
	else
		tmp=subsasgn(tmp, S, value);
		while length(S)>1 && isempty(subsref(tmp, S))
			field=S(end).subs;
			S=S(1:end-1);
			sub=rmfield(subsref(tmp,S),field);
			if isempty(fieldnames(sub))
				sub=[];
				end
			tmp=subsasgn(tmp,S,sub);
			end
		if isempty(tmp.(appfield))
			if isappdata(h, appfield)
				rmappdata(h, appfield);
				end
		else
			setappdata(h, appfield, tmp.(appfield));
			end
		end
	end
% File: args2struct.m ######################################################################
function [z,err]=args2struct(Defaults, Args, generror)
%ARGS2STRUCT Parse input parameters into a struct.
%   ARGS2STRUCT aids parsing of parameters, so that the call of
%   a function can contain both positional and named parameters
%   as e.g Handle Graphics calls.

% Author:  Jerker W�gberg, More Research, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: $

	err=[];
	z=[];
	if nargin<3;generror=true;end
	if nargin==1
		z=Defaults;
		return;
		end
	fnDefaults=fieldnames(Defaults);
	[reg, prop]=parseparams(Args);
	if length(fnDefaults) < length(reg)
		err=illpar('Too many input arguments');
		if generror; error(err);else return;end
		end
	for i=1:length(reg)
		Defaults.(fnDefaults{i})=reg{i};
		end
	n=length(prop);
	if rem(n,2)
		err=illpar('Parameter/value pairs must come in PAIRS');
		if generror; error(err);else return;end
		end
	fnLowerDefaults=lower(fnDefaults);
	for i=0:n/2-1
		ixp=2*i+1;
		ix=strmatch(lower(prop{ixp}), fnLowerDefaults,'exact');
		if isempty(ix)
			ix=strmatch(lower(prop{ixp}), fnLowerDefaults);
			end
		if length(ix)==1
			Defaults.(fnDefaults{ix}) = prop{ixp+1};
		else
			if isempty(ix)
				err=illpar('Invalid named parameter: ''%s''.', prop{ixp});
			else
				err=illpar('Ambigously named parameter: ''%s''.', prop{ixp});
				end
			if generror; error(err);else return;end
			end
		end
	z=Defaults;
	end
% File: <..\jwtools\jwgeneral\>callcallback.m ######################################################################
function z=callcallback(fun,varargin)
%CALLCALLBACK Call a callback function
%   CALLCALLBACK(FUN, ARG1, ARG2,...) calls the function FUN
%   following protocol � la Handle Graphics.
%
%   If FUN is:
%      * a string; 'FUN' is evaluated in base workspace.
%      * a function handle; FUN(OBJ, EVT) is evaluated in
%        its original workspace.
%      * a cellstr; 'FUN{1}'(VARARGIN{:}, FUN{2:end}) is
%        evaluated in base workspace.
%      * a cell array with a function handle FUN{1};
%        FUN{1}(VARARGIN{:}, FUN{2:end}) is evaluated in
%        its original workspace.
%
%   Z=CALLCALLBACK(FUN,...) calls FUN according to the rules above but also
%   returns a supposed logical argument from FUN. If type of FUN is any of
%   the last three listed and has one output argument, it is assumed to
%   output a scalar logical value, indicating whether or not FUN considers
%   the execution of the callback should be propagated to other callbacks
%   or if the execution should stop. If FUN is a string or FUN does not
%   return an argument, FALSE is allways returned, meaning that execution
%   does not propagate.
%
%   See also: CHAINCALLBACK, UNCHAINCALLBACK

	error(nargchk(1,inf,nargin,'struct'));
	error(nargoutchk(0,1,nargout,'struct'));
	z=false;
	if ~isempty(fun)
		if ischar(fun)
			eval(fun);
		elseif isa(fun, 'function_handle')
			if nargout && (nargout(fun) ~= 0)
				z =fun(varargin{:});
			else
				fun(varargin{:});
				end
		elseif iscellstr(fun)
			CB=str2func(fun{1});
			if nargout && (nargout(CB) ~= 0)
				z=CB(varargin{:}, fun{2:end});
			else
				CB(varargin{:}, fun{2:end});
				end
		elseif iscell(fun) && isa(fun{1}, 'function_handle')
			if nargout && nargout(fun{1}) ~= 0
				z = fun{1}(varargin{:}, fun{2:end});
			else
				fun{1}(varargin{:}, fun{2:end});
				end
		elseif ~isempty(fun)
			error('callcallback:IllFun', 'Not a callback function');
			end
		end
	end
% File: callwhen.m ######################################################################
function hTimer=callwhen(condfun,execfun,varargin)
%CALLWHEN Call a specified routine when a condition is true
%   CALLWHEN(CONDFUN,EXECFUN) will call the function CONDFUN ten times a
%   second and when this function returns a non-zero value it will call
%   EXECFUN. CONDFUN and EXECFUN follow the same calling convention,
%   based on the same principles as Handle Graphics event callback
%   functions, except that there is no handle and eventdata arguments.
%
%   If FUN is:
%      * a string; 'FUN' is evaluated in base workspace.
%      * a function handle; FUN() is evaluated in its
%        original workspace.
%      * a cellstr; FUN{1}(FUN{2:end}) is evaluated
%        in base workspace.
%      * a cell array with a function handle FUN{1};
%        FUN{1}(FUN{2:end}) is evaluated in its
%        original workspace.
%
%   CALLWHEN(..., 'Rate',HZ) will call CONDFUN HZ times per second.
%	CALLWHEN(..., 'Timeout', TO) will stop checking CONDFUN after TO
%	seconds.
%   CALLWHEN(..., 'TimeoutFcn', TOFUN) will call the TOFUN function if the
%   condition have not been met within TO seconds.
%
%   CONFUN can also directly be set to logical value for a call to EXECFUN
%   through a timer callback. This is useful to start up operations without
%   needing to wait for EXECFUN to return.
%
%   Example
%      clear foobar
%      callwhen(@()evalin('base','exist(''foobar'',''var'');') ...
%          , @()disp('foobar has come to life!'),'Rate',.2);
%      pause(1);
%      foobar=4711;
%
%   See also

% Author:  Jerker W�gberg
% Created: 2006-10-10
% Copyright � 2006 More Research.

	function NullFcn(varargin)
		end

	function StopFcn(obj, evt) %#ok<INUSD>
		delete(hTimer);
		try
			if ConditionOK
				SimpleCallCallback(execfun, false);
			else
				SimpleCallCallback(par.TimeoutFcn,false);
				end
		catch
			if ConditionOK
				warning('callwhen:InvalidCallback', 'Invalid callback');
			else
				warning('callwhen:InvalidTimeoutCallback', 'Invalid Timeout callback');
				end
			end
		end
		
	function TimerFcn(obj, evt) %#ok<INUSD>
		if SimpleCallCallback(condfun, true)
			ConditionOK=true;
			stop(hTimer);
			end
		end

	par=struct( ...
		  'Rate', 10 ...
		, 'Timeout', Inf ...
		, 'TimeoutFcn', @NullFcn ...
		);

	par=args2struct(par, varargin);
	if islogical(condfun) && ~condfun
		if isinf(par.Timeout)
			error('Hey, this timer will never stop!')
			end
		par.Rate = 1/par.Timeout;
		par.TimeoutFcn=execfun;
		end

	hTimer = timer( ...
		  'Name', 'CallWhen' ...
		, 'StartDelay', 0 ...
		, 'BusyMode', 'drop' ...
		, 'ExecutionMode', 'fixedRate' ...
		, 'TasksToExecute', par.Timeout*par.Rate+1 ...
		, 'TimerFcn', @TimerFcn ... 
		, 'Period', 1/par.Rate ...
		, 'StopFcn', @StopFcn ...
		);
	ConditionOK=false;
	start(hTimer);
	end

function z=SimpleCallCallback(fun, ArgOut)
	if islogical(fun)
		z=fun;
	else
		if ArgOut
			varg=cell(1,1);
		else
			varg={};
			end
		if ischar(fun)
			[varg{:}]=eval(fun);
		elseif isa(fun, 'function_handle')
			[varg{:}]=fun();
		elseif iscellstr(fun)
			CB=str2func(fun{1});
			[varg{:}]=CB(fun{2:end});
		elseif iscell(fun) && isa(fun{1}, 'function_handle')
			[varg{:}]=fun{1}(fun{2:end});
		elseif ~isempty(fun)
			error([mfilename ':IllFun'], 'Not a Handle Graphics callback function');
			end
		if ArgOut
			z=varg{:};
			end
		end
	end
% File: <..\jwtools\jwgeneral\>chaincallback.m ######################################################################
function Id=chaincallback(h, type, fun)
%CHAINCALLBACK Install callback(s) without destroying previous callback(s).
%   CHAINCALLBACK(H, CALLBACKNAME, FUN) installs FUN as the callback to use
%   by Handle Graphics objects H when an event specified by CALLBACKNAME
%   happens. The previous callbacks of the handles are saved and the
%   execution of the callbacks may propagate to the saved callbacks.
%
%   FUN can be specified as string, a function handle, a cell array of
%   strings or as a cell array with a function handle in its first cell. If
%   FUN is any of the last three and has one output argument, that argument
%   is assumed to be a scalar boolean, indicating wether or not to
%   propagate the execution.
%
%   UNFUN=CHAINCALLBACK(...) returns an Id to be used by UNCHAINCALLBACK
%   to restore the callback.
%
%   Example:
%      id=chaincallback(gcf, 'ResizeFcn', @MyResizeFun);
%      unchaincallback(gcf, 'ResizeFcn', id);
%
%   See also: UNCHAINCALLBACK, callcallback

	function z=CallbackChain(h,type)
		cb=chainlist('table', h, type);
		z=cb(:,1);
		end

	function GenericCallback(obj, eventdata, name)
		cb=CallbackChain(obj,name);
		i=length(cb);
		while i>=1 && callcallback(cb{i}, obj, eventdata)
			i=i-1;
			end
		end

	function Id=ChainOne(h, type, fun)
		if isempty(CallbackChain(h, type))
			% Save original callback in chain of callbacks
			chainlist('add', h, type, get(h, type));
			% Install our own routine
			set(h, type, {@GenericCallback type});
			end
		% Prepend function to callback chain.
		Id=chainlist('add', h, type, fun);
		end
	
	error(nargchk(3,3,nargin,'struct'));
	if ~isonedim(h,1)
		error('chaincallback:IllPar', 'Handles must be scalar or column vector');
		end
	if ~isonedim(type,2)
		error('chaincallback:IllPar', 'Type must be scalar or row vector');
		end
	type = lower(type);
	if iscellstr(type)
		Id=zeros(length(h), length(type));
		if ~iscell(fun) || ~isequal(size(fun),size(Id))
			error('chaincallback:IllPar', 'callbacks are not consistent with other parameters');
			end
		for ih=1:length(h)
			for j=1:length(type)
				Id(ih,j)=ChainOne(h(ih), type{j}, fun{ih,j});
				end
			end
	else
		Id=zeros(size(h));
		for ih=1:length(h)
			Id(ih)=ChainOne(h(ih), type, fun);
			end
		end
	end
	
function z=isonedim(x,dim)
	sz=size(x);
	if dim<=length(sz)
		sz(dim)=[];
		end
	z=all(sz==1);
	end
% File: <..\jwtools\jwgeneral\>chainlist.m ######################################################################
function z=chainlist(Op, h, ftype, IdFun)
%CHAINLIST Helper function for CHAINCALLBACK and UNCHAINCALLBACK
%   See also: CHAINCALLBACK, UNCHAINCALLBACK

% Author:  Jerker W�gberg
% Created: 2006-10-09
% Copyright � 2006 More Research.

	persistent CBCount

	function z=Callbacks(h, type)
		z=appdata(h, {ap type});
		if isempty(z)
			z=cell(0,2);
			end
		end

	function z=NextCallbackId
		if isempty(CBCount)
			CBCount= 1;
			end
		z=CBCount;
		CBCount=CBCount+1;
		end

	function RemoveAll(h)
	% Remove callbacks of deleted handles
		appdata(h, ap, []);
		end

	function Id=AddCallback(h, type, fun)
		Id=NextCallbackId;
		CB=Callbacks(h, type);
		if isempty(CB)
			CB={fun Id};
		else
			CB(end+1,:) = {fun Id};
			end
		appdata(h, {ap, type}, CB);
		end

	function RemoveCallback(h, type, Id)
		CB=Callbacks(h, type);
		if isempty(Id)
			ix=size(CB,1);
		else
			ix=[CB{:,2}]==Id;
			end
		if any(ix)
			CB(ix,:)=[];
			if size(CB,1)==1
				set(h, type, CB{1,1});
				CB=[];
				end
		else
%			warning('chaincallback:NoSuchCallback', 'Tried to remove nonexistent callback');
			end
		appdata(h, {ap type}, CB);
		end

	ap = 'chncb';
	if nargin<4; IdFun=[]; end
	if nargin==0
		Op = 'table';
		end
	switch partialmatch(Op, {'add', 'rm', 'table', 'rmall'})
		case 'table'
			z=Callbacks(h, ftype);
		case 'add'
			if     nargin<4 ...
				|| ~ishandle(h) ...
				|| ~ischar(ftype)
				error('chaincallback:IllPar', 'Illegal parameters');
				end
			z=AddCallback(h, ftype, IdFun);
		case 'rm'
			if     nargin<3 ...
				|| ~ishandle(h) ...
				|| ~ischar(ftype)
				error('chaincallback:IllPar', 'Illegal parameters');
				end
			RemoveCallback(h, ftype,IdFun);
		case 'rmall'
			RemoveAll(h);
		end
	end
% File: datahandler.m ######################################################################
function [fun,emsg]=datahandler(Data, spread)
%DATAHANDLER Handle ANYMATE's passing of arguments to a user function
% In its most general form, the input data arument to ANYMATE is a
% two-dimensional B-by-A cell array with number of breaks, B, running
% downwards over rows and number of arguments, A, running cross over
% columns. In this general form, user function FUN is called as:
%    Call 1: FUN(DATA{1,1}, DATA{1,2}, ..., DATA{1,A})
%    Call 2: FUN(DATA{2,1}, DATA{2,2}, ..., DATA{2,A})
%    ...     ...
%    Call B: FUN(DATA{B,1}, DATA{B,2}, ..., DATA{B,A})
%
% There is seldom need for this general form. In most cases there are short
% forms that are more convenient, but all forms can be expressed in the
% above general form. To form an animation, there must be at least two
% breaks, B>1, so if the input is a cell row vector the following two short
% forms apply:
%
% A cell string row vector is transposed into a column vector, generating
% the calls:
%    Call 1: FUN(DATA{1})
%    Call 2: FUN(DATA{2})
%    ...     ...
%    Call B: FUN(DATA{B})
%
% A cell row vector DATA, 1-by-A, holding matrices where each matrix's last
% index is the same, B, will generate the calls:
%    Call 1: FUN(DATA{1}(:,:,...,1), DATA{2}(:,:,...,1), ..., DATA{A}(:,:,...,1)
%    Call 2: FUN(DATA{1}(:,:,...,2), DATA{2}(:,:,...,2), ..., DATA{A}(:,:,...,2)
%    ...     ...
%    Call B: FUN(DATA{1}(:,:,...,B), DATA{2}(:,:,...,B), ..., DATA{A}(:,:,...,B)
%
% Note that the different arguments in the call do not need to have the same
% dimensionality nor class. The only requirement is that the last dimension
% have the same number of elements. An N-by-1 column vector will have its
% first dimension considered as its last.
%
% A non-cell matrix DATA, M-by-N-by-...-by-B, with SPREAD false, will
% generate the calls:
%    Call 1: FUN(DATA(:,:,...,1))
%    Call 2: FUN(DATA(:,:,...,2))
%    ...     ...
%    Call B: FUN(DATA(:,:,...,B))
%
% A non-cell matrix DATA, M-by-N-by-...by-B-by-A, with SPREAD true, will
% generate the calls:
%    Call 1: FUN(DATA(:,:,...,1,1), DATA(:,:,...,1,2), ..., DATA(:,:,...,1,A)
%    Call 2: FUN(DATA(:,:,...,2,1), DATA(:,:,...,2,2), ..., DATA(:,:,...,2,A)
%    ...     ...
%    Call B: FUN(DATA(:,:,...,B,1), DATA(:,:,...,B,2), ..., DATA(:,:,...,B,A)
%
% To apply the last two shortcuts to a cell array, the array must be
% enclosed in a scalar cell.

	function z=BreakData(iBreak)
		function z=OneChunk(Data)
			dim=ndims(Data);
			ix=repmat({':'},1,dim);
			ix{dim}=iBreak;
			z=Data(ix{:});
			end

		if isvector(Data)
			if iscellstr(Data)
				z=Data(iBreak);
			else
				z=cellfun(@OneChunk,Data,'UniformOutput', false);
				end
		else
			z=Data(iBreak, :);
			end
		end

	fun=[];
	emsg='';
	if ~iscell(Data)
		Data={Data};
		end
	if isscalar(Data)
		if spread
			% Transform it to the cell row vector special case
			Data=reshape(dim2cell(Data{:},1:ndims(Data{:})-1),1,[]);
			
			% Transpose internal column vectors to row vectors to make
			% their last dimension really last.
			[Data{:}]=VectorAlong(2,Data{:});
			
			NumBreaks=size(Data{1},ndims(Data{1}));
		else
			Data{1}=VectorAlong(2, Data{1});
			NumBreaks=size(Data{1},ndims(Data{1}));
			end
	else
		if ndims(Data)>2
			emsg='Cell input can not have more than two dimensions';
			return
			end
		if isvector(Data)
			if iscellstr(Data)
				Data=VectorAlong(1,Data);
				NumBreaks=length(Data);
			else
				% Transpose internal column vectors to row vectors to make
				% their last dimension really last.
				[Data{:}]=VectorAlong(2,Data{:});
				
				% Get the size of the last dimension for every matrix and
				% check that they are equal
				NumBreaks=cellfun(@(x)size(x,ndims(x)),Data);
				if any(diff(NumBreaks))
					emsg=sprintf(['The last dimension of each data argument must have the same number of elements\n' ...
						'If the intention was to pass the cell items as arguments to a function taking a single argument,\n' ...
						'the cell must be contained in yet another cell. See help anymate.']);
					return;
					end
				NumBreaks=NumBreaks(1);
				end
		else
			NumBreaks=size(Data,1);
			end
		end
	if NumBreaks<2
		emsg='There must be at least two breaks to form an animation';
		return;
		end

	fun=struct( ...
		  'NumBreaks', @()NumBreaks ...
		, 'BreakData', @BreakData ...
		);
	end

function varargout=VectorAlong(dim,varargin)
% Assert that vectors are vectors along dimension dim. Arrays are untouched.
	function z=ShapeOne(x)
		if isanyvector(x)
			sz=ones(1,max(2,dim));
			sz(dim)=numel(x);
			z=reshape(x,sz);
		else
			z=x;
			end
		end
	varargout=cellfun(@ShapeOne, varargin,'UniformOutput', false);
	end

function z=isanyvector(x)
%ISANYVECTOR Return true if input argument  is a vector of any dimensionality
	sz=size(x);
	z=sum(sz<=1)>=length(sz)-1;
	end
% File: dbgcallback.m ######################################################################
function dbgcallback(arg)
%DBGCALLBACK Easy WindowButton...Callbacks debugging
%   Debugging callbacks can be hard, especially when callbacks trigger when
%   your'e allready at a breakpoint. Call this routine with a TRUE argument
%   before ANYMATE is called, and there will not be any disturbing calls.
	persistent DBG
	
	if isempty(DBG), DBG=false; end
	if islogical(arg)
		DBG=arg;
	else
		Fields={
			'Interruptible'
			'BusyAction'
			};
		Options={
		%   Release		Debug
			'on'		,'off'
			'queue',	'queue'	
			};
		setdata=cell2struct(Options, Fields, 1);
		set(arg, setdata(DBG+1));
		end
	end
% File: exploreaccessors.m ######################################################################
function [EnableFun, FilterFun,AllowAxesFun]=exploreaccessors(hf)
	function AllowAxes(ax,state)
		ho=cellfun(@getone,funs, 'UniformOutput', false);
		if ~isempty(ho{1}); setAllowAxesZoom(ho{1},ax,state); end
		if ~isempty(ho{2}); setAllowAxesPan(ho{2},ax,state); end
		if ~isempty(ho{3}); setAllowAxesRotate(ho{3},ax,state); end
		end


	function Filter(fun)
		ho=cellfun(@getone,funs, 'UniformOutput', false);
		cellfun(@(x)set(x,'ButtonDownFilter', fun), ho);
		end
	
	function z=Enable(state)
		function z=getstate(fun)
			obj=getone(fun);
			if isempty(obj)
				z='off';
			else
				z=get(obj, 'Enable');
				end
			end

		if nargin<1
			z=cellfun(@getstate,funs, 'UniformOutput', false);
		else
			if ischar(state)
				state=repmat({state},length(funs),1);
				end
			cellfun(@(fun,s)fun(s),funs(:),state(:));
			end
		end

	function z=getone(fun)
		% zoom, pan et.al sometimes don't return a handle.
		% This is a way to get around it
		try
			% Rotate3D creates a visible uicontextmenu when returning a
			% rotate object. We correct that by setting its handle to
			% invisible.
			ho=get(hf, 'Children');
			z=fun(hf);
			hn=get(hf, 'Children');
			if ~isequal(ho,hn)
				hn=setdiff(hn,ho);
				if strcmp(get(hn,'type'), 'uicontextmenu')
					set(hn, 'HandleVisibility', 'off');
					end
				end
		catch
			z=[];
			end
		end

	if nargin<1; hf=gcf; end
	funs={@zoom @pan @rotate3d};
	EnableFun=@Enable;
	FilterFun=@Filter;
	AllowAxesFun=@AllowAxes;
	end
% File: ExploreException.m ######################################################################
function ExploreException(hf,ax)
%EXPLOREEXCEPTION Set axes exception for pan, zoom and rotate

	function z=FilterFcn(h, evt) %#ok<INUSD>
		z=any(h==[ax;allchild(ax)]);
		end

	[ToolEnable,Filter,AllowAxis]=exploreaccessors(hf);
	if isempty(ax)
		Filter('');
	else
		Filter(@FilterFcn);
		AllowAxis(ax,false);
		end
	end
% File: <..\jwtools\jwgraphics\>copyobjnc.m ######################################################################
function h=copyobjnc(h,p)
%COPYOBJNC Copy objects without callbacks
%   Same functionality as COPYOBJ but resets the callback functions to ''
%   before the copying, so a possible CreateFcn will not be called. The
%   callbacks are then restored for the original object.
%
%   Used for copying objects from an involved plot that may have various
%   callbacks that only makes sense within the plot.

	hc=[h;allchild(h)];
	cb={'CreateFcn' 'DeleteFcn' 'ButtonDownFcn'};
	funs=get(hc, cb);
	set(hc,cb,arrayfun(@(x){''},funs));
	h=copyobj(h,p);
	set(hc,cb,funs);
	end
% File: numedit.m ######################################################################
function [zfun,hc]=numedit(varargin)
%NUMEDIT Create a lightweight numberic editing object

% Author:  Jerker W�gberg
% Created: 2006-06-17
% Copyright � 2006 More Research.

	function z=ControlVal(Val, varargin)
		if nargin<1
			z=get(hc, 'UserData');
		elseif isempty(Val)
			valids=struct( ...
				  'Enable', get(hc, 'Enable') ...
				  );
			p=args2struct(valids, varargin);
			set(hc, 'Enable', p.Enable);
		else
			set(hc, 'UserData', Val);
			if Val<100
				StrVal=num2str(Val,3);
			else
				StrVal=num2str(round(Val));
				end
			set(hc, 'String', StrVal);
			callcallback(par.Callback, Val);
			end
		end

	function ControlCallbackFcn(hobject, eventdata) %#ok<INUSD>
		StrVal=get(hobject, 'String');
		Val=str2double(StrVal);
		if isnan(Val)
			Val=get(hobject,'UserData');
			end
		ControlVal(Val);
		end

	[par,msg]=argcheck(varargin);
	if ~isempty(msg), error('MATLAB:dropdown:IllPar', msg), end
	hc=uicontrol( ...
		  'Style', 'edit' ...
		, 'Parent', par.hf ...
		, 'Units', 'character' ...
		, 'Position', [par.pos par.Width 1.2] ...
		, 'Callback', @ControlCallbackFcn ...
		, 'BackgroundColor', [1 1 1] ...
		, 'ForegroundColor', [0 0 0] ...
		);
	if ~isempty(par.Label)
		numedit_SetLabel(hc,par);
		end
	ControlVal(par.Default);
	zfun=@ControlVal;
	end

function numedit_SetLabel(h,par)
	Height=get(h, 'Position');
	Height=Height(4);
	if ~isempty(par.Label)
		text(-.2,Height/2,par.Label ...
			, 'Parent',h ...
			, 'VerticalAlign', 'middle' ...
			, 'HorizontalAlign', 'right' ...
			, 'units', 'character' ...
			);
		end
	end

function [z,msg]=argcheck(vargin)
	z=[];
	nargs=length(vargin);
	msg=nargchk(2,inf,nargs);
	if ~isempty(msg)
		return
		end
	base=1;
	if nargs<2
		msg='Must have at least two parameters';
		return
		end
	if ishandle(vargin{base})
		switch get(vargin{base}, 'type')
			case {'figure', 'uipanel'}
			otherwise
				msg='Parameter 1 must be handle to figure or panel';
				return;
			end
		par.hf=vargin{base};
		base=base+1;
		nargs=nargs-1;
	else
		par.hf=gcf;
		end
	if nargs<2
		msg='Must have at least a function handle and a position';
		return
		end
	if ~iscell(vargin{base}) && ~isempty(vargin{base}) && ~isa(vargin{base}, 'function_handle')
		msg='Parameter must be a function handle';
		return
		end
	par.Callback=vargin{base};
	par.pos=vargin{base+1};
	base=base+2;
	if ~isequal(size(par.pos),[1 2])
		msg='Size must be 1x2';
		return
		end
	par.Default = 0;
	par.Label = '';
	par.Width=10;
	z=args2struct(par,vargin(base:end));
	end
% File: private\anicontrol.m ######################################################################
function hf=anicontrol(funs, rofuns)

	function ClickRadio(hObject,eventdata) %#ok<INUSD>
		GroupTag=get(hObject,'Tag');
		Tag=get(get(hObject,'SelectedObject'),'Tag');
		funs.(GroupTag(4:end))(lower(Tag(4:end)));
		end

	function ClickRadioMode(hObject,eventdata) %#ok<INUSD>
		Tag=get(get(hObject,'SelectedObject'),'Tag');
		Mode = lower(Tag(4:end));
		funs.RunMode(Mode);
		end

	function chkLoop(hObject, eventdata) %#ok<INUSD>
		funs.Loop(get(hObject, 'Value'));
		end

	function FrequencyCallback(Value)
		if Value < 0.1
			h.txtFrequency(0.1);
		else
			funs.Frequency(Value);
			end
		end

	function DurationCallback(Value)
		funs.Duration(Value);
		end

	function cmdOKCallback(hObject, eventdata) %#ok<INUSD>
		if ~isequal(Old.Frequency{2},funs.Frequency())
			anisetpref('Fps',funs.Frequency());
			end
		% All possible changes done will be retained, so we flag that by
		% emptying Old.
		Old=[];
		delete(hf);
		end
	
	function cmdCancelCallback(hObject, eventdata) %#ok<INUSD>
		delete(hf);
		end

	function DeleteFcn(hObject, eventdata) %#ok<INUSD>
		if ~isempty(Old)
			% Reset timeslice object to original settings
			structfun(@(x)x{1}(x{2}), Old);
			end
		end

	error(nargchk(2,2,nargin));

	% Save a copy of original values together with a function handle to
	% reset them, if needed.
	
	Old = structfun(@(x){x x()},funs, 'Uni', false);

	butMethod=RadioVector({'linear','spline','pchip'},funs.Method());
	butRunMode=RadioVector({'forward', 'circle', 'pingpong'},funs.RunMode());
	bgc=[0.831 0.816 0.784];
	hf = figure(...
		'Units','characters' ...
		, 'Color',bgc ...
		, 'IntegerHandle','off' ...
		, 'MenuBar','none' ...
		, 'Name','anicontrol' ...
		, 'NumberTitle','off' ...
		, 'Position',[80 53 80 9.2] ...
		, 'Resize','off' ...
		, 'WindowStyle', 'normal' ... %'modal' ...
		, 'HandleVisibility','callback' ...
		, 'Tag','JWfigAniControl' ...
		, 'Visible','on' ...
		, 'DefaultUIPanelUnits', 'characters' ...
		, 'DefaultUIControlUnits', 'characters' ...
		, 'DefaultUIControlClipping', 'on' ...
		, 'DeleteFcn', @DeleteFcn ...
		);
	hb = uibuttongroup(...
		'Parent',hf,...
		'Title','Interpolation',...
		'Tag','rgpMethod',...
		'Position',[31 0.7 16 7.2],...
		'SelectionChangeFcn',  @ClickRadio ...
		);

	hbm = uibuttongroup(...
		'Parent',hf,...
		'Title','RunMode',...
		'Tag','rgpRunMode',...
		'Position',[49 0.7 16 7.2],...
		'SelectionChangeFcn',  @ClickRadioMode ...
		);

	fn={'Parent' 'Position','BackgroundColor','HorizontalAlignment','String','Style','Tag','Value','Callback','Enable'};
	cd={
		hf	[2 6.5 8 1.5]		bgc		'left'		'Duration'	'text'			'lblPeriod'		0				''					'on'
		hf	[2   4 8 1.5]		bgc		'left'		'Fps'		'text'			'lblFps'		0				''					'on'
		hf	[2  5.8 15 1]	[1 1 1]		'right'		''			@slidertext		'txtDuration'	[1 20 funs.Duration()]		@DurationCallback		'on'
		hf	[2  3.3 15 1]	[1 1 1]		'right'		''			@slidertext		'txtFrequency'	[1 30 funs.Frequency()]		@FrequencyCallback		'on'
		hb	[1.5 4.6 13 1.3]	bgc		'right'		'Linear'	'radiobutton'	'radLinear'		butMethod(1)	''					'on'
		hb	[1.5 3.2 13 1.3]	bgc		'right'		'Spline'	'radiobutton'	'radSpline'		butMethod(2)	''					'on'
		hb	[1.5 1.8 13 1.3]	bgc		'right'		'Pchip'		'radiobutton'	'radPchip'		butMethod(3)	''					'on'
		hbm	[1.5 4.6 13 1.3]	bgc		'right'		'Forward'	'radiobutton'	'radForward'	butRunMode(1)	''					'on'
		hbm	[1.5 3.2 13 1.3]	bgc		'right'		'Circle'	'radiobutton'	'radCircle'		butRunMode(2)	''					onoff(rofuns.CanCircle())
		hbm	[1.5 1.8 13 1.3]	bgc		'right'		'PingPong'	'radiobutton'	'radPingPong'	butRunMode(3)	''					'on'
		hbm	[1.5 0.4 13 1.3]	bgc		'right'		'Loop'		'checkbox'		'chkLoop'		funs.Loop()		@chkLoop			'on'
		hf	[70 6.4 9 1.5]		bgc		'center'	'OK'		'pushbutton'	'cmdOK'			0				@cmdOKCallback		'on'
		hf	[70 4.4 9 1.5]		bgc		'center'	'Cancel'	'pushbutton'	'cmdCancel'		0				@cmdCancelCallback	'on'
		};
	fn=[{'Units'} fn];
	cd=[repmat({'character'},size(cd,1),1) cd];
	spec=cell2struct(cd,fn,2);
	h=struct;
	for i=1:length(spec)
		s=spec(i);
		if isa(s.Style, 'function_handle')
			h.(s.Tag)=s.Style(s.Parent, s.Callback, s.Position ...
				, 'Scale', s.Value(1:2) ...
				, 'Default', s.Value(3) ...
				, 'Gamma', 3);
		else
			h.(s.Tag)=uicontrol(s);
			end
		end
	end
% File: private\anifile.m ######################################################################
function [filetype, figSave]=anifile(hfig)
%ANIFILE Display Filetype selection dialog
	function ClickSizeCallback(hObject,eventdata,varargin) %#ok<INUSD>
		Tag=get(get(hb,'SelectedObject'),'Tag');
		saveUnit=get(hfig,'Units');
		set(hfig, 'WindowStyle', 'normal', 'Units', 'pixels');
		movegui(hfig);
		pos=get(hfig,'Position');
		sz=sscanf(Tag(4:end),'%dx%d')';
		pos=[pos(1) pos(2)-sz(2)+pos(4) sz];
		set(hfig, 'Position', pos, 'Units', saveUnit);
		movegui(hfig);
		figure(hf);
		end

	function SetFileType
		Tag=get(get(hbm,'SelectedObject'),'Tag');
		switch Tag(4:end)
			case {'avi', 'wmv'}
				set(get(hb, 'Children'), 'Enable', 'on');
				ClickSizeCallback;
			case 'gif'
				set(get(hb, 'Children'), 'Enable', 'off');
			end
		end

	function ClickFileTypeCallback(hObject,eventdata,varargin) %#ok<INUSD>
		SetFileType;
		end

	function cmdCancelCallback(hObject, eventdata, varargin) %#ok<INUSD>
		if ~control('chkKeep')
			s=warning('off'); %#ok<WNOFF>
			set(hfig, figSave);
			warning(s);
			end
		delete(hf);
		filetype=[];
		end

	function z=control(Tag, Value)
		hc=findobj(hf, 'Tag', Tag);
		if nargin<2
			z=get(hc, 'Value');
		else
			set(hc, 'Value', Value);
			end
		end

	function cmdOKCallback(hObject, eventdata, varargin) %#ok<INUSD>
		Tag=get(get(hbm,'SelectedObject'),'Tag');
		filetype=Tag(4:end);
		if control('chkKeep')
			figSave=struct;
			end
		delete(hf);
		end

	% Save a copy of original values together with a function_handle to
	% reset them, if needed.
	Props={'Position', 'Units', 'WindowStyle'};
	figSave=cell2struct(get(hfig, Props),Props,2);

	butSize=RadioVector({'320x240','640x480', '1024x768','1280x720'},'640x480');
	butFileType=RadioVector({'gif','avi', 'wmv'}, 'gif');
	bgc=get(gcf, 'defaultUIPanelBackground');
	hf = figure(...
		  'Units','characters' ...
		, 'Color',bgc ...
		, 'IntegerHandle','off' ...
		, 'MenuBar','none' ...
		, 'Name','anicontrol' ...
		, 'NumberTitle','off' ...
		, 'Position',[80 48 48 9.9] ...
		, 'Resize','off' ...
		, 'WindowStyle', 'normal' ...
		, 'HandleVisibility','callback' ...
		, 'Tag','JWfigAniFile' ...
		, 'Visible','on' ...
		, 'DefaultUIPanelUnits', 'characters' ...
		, 'DefaultUIControlUnits', 'characters' ...
		, 'DefaultUIControlClipping', 'on' ...
		);

	hbm = uibuttongroup(...
		'Parent',hf,...
		'Title','File type',...
		'Tag','rgpFileType',...
		'Position',[1 3.7 16 5.8],...
		'SelectionChangeFcn',  @ClickFileTypeCallback ...
		);

	hb = uibuttongroup(...
		'Parent',hf,...
		'Title','Size',...
		'Tag','rgpSize',...
		'Position',[19 .7 16 8.8],...
		'SelectionChangeFcn',  @ClickSizeCallback ...
		);

	fn={'Parent' 'Position','BackgroundColor','HorizontalAlignment','String','Style','Tag'		,'Value'		,'Callback'};
	cd={
		hbm	[1.5 3.2 13 1.3]	bgc		'right'		'gif'		'radiobutton'	'radgif'		butFileType(1)	''
		hbm	[1.5 1.8 13 1.3]	bgc		'right'		'avi'		'radiobutton'	'radavi'		butFileType(2)	''
		hbm	[1.5 0.4 13 1.3]	bgc		'right'		'wmv'		'radiobutton'	'radwmv'		butFileType(3)	''
		hb	[1.5 6.0 13 1.3]	bgc		'right'		'320x240'	'radiobutton'	'rad320x240'	butSize(1)		''
		hb	[1.5 4.6 13 1.3]	bgc		'right'		'640x480'	'radiobutton'	'rad640x480'	butSize(2)		''
		hb	[1.5 3.2 13 1.3]	bgc		'right'		'1024x768'	'radiobutton'	'rad1024x768'	butSize(3)		''
		hb	[1.5 1.8 13 1.3]	bgc		'right'		'1280x720'	'radiobutton'	'rad1280x720'	butSize(4)		''
		hb	[1.5 0.4 13 1.3]	bgc		'right'		'Keep'		'checkbox'		'chkKeep'		0				''
		hf	[37 7.5 9 1.5]		bgc		'center'	'OK'		'pushbutton'	'cmdOK'			0				@cmdOKCallback
		hf	[37 5.5 9 1.5]		bgc		'center'	'Cancel'	'pushbutton'	'cmdCancel'		0				@cmdCancelCallback
		};
	% Make sure all units are set to character
	fn=[{'Units'} fn];
	cd=[repmat({'character'},size(cd,1),1) cd];
	% Create the controls
	s=cell2struct(cd,fn,2);
	h=zeros(length(s),1);
	for i=1:length(s)
		h(i)=uicontrol(s(i));
		end
	SetFileType;
	filetype=[];
	uiwait(hf);
	end
% File: private\anigetpref.m ######################################################################
function z=anigetpref(pref)
	PREF=struct( ...
		  'AviCompression', 'Indeo5' ...
		, 'GlobalUnWrap' , false ...
		, 'Fps' , 20 ...
		  );
	group='anymate';
	if ispref(group,pref)
		z=getpref(group,pref);
	else
		z=PREF.(pref);
		end
	end
% File: private\anisetpref.m ######################################################################
function anisetpref(pref,val)
	group='anymate';
	if ispref(group,pref)
		setpref(group,pref,val);
	else
		addpref(group,pref,val);
		end
	end
% File: private\dim2cell.m ######################################################################
function z=dim2cell(x,dim)
%DIM2CELL Break matrix up into a cell array of matrices.
%   C = DIM2CELL(X,DIM) breaks up the multidimensional array X and returns
%   a multidimensional cell array of adjacent submatrices of X. The
%   dimensions of C equals the dimensions of X, except for dimension DIM,
%   which is always one. Default DIM is the last dimension of X.
%
%   DIM2CELL is can be used instead of MAT2CELL in the frequent special
%   cases where whole dimensions are to be collapsed into a cell array.
%
%   If SIZE(X)=[D1,..., DK,..., DN],
%
%      DIM2CELL(X,K) == MAT2CELL( ...
%                           X,ONES(1,D1),..., DK, ..., ONES(1,DN))
%
%   DIM2CELL supports all array types.
%
%	Example:
%	   x = [1 2 3 4; 5 6 7 8; 9 10 11 12];
%	   c = dim2cell(x,2)
%	    
%	See also MAT2CELL, CELL2MAT, NUM2CELL

% Author:  Jerker W�gberg
% Created: 2006-10-05
% Copyright � 2006 More Research.

	if nargin<2; dim = ndims(x); end
	if any(dim)>ndims(x)
		error('dim2cell:IllegalDimension', 'Given dimension(s) excceds array dimensions');
		end
	p=arrayfun(@(x)ones(x,1),size(x),'Uniform', false);
	p(dim)=arrayfun(@(d)size(x,d),dim, 'Uniform', false);
	z=mat2cell(x,p{:});
	end
% File: private\disperror.m ######################################################################
function disperror
%DISPERROR Display latest error message and where the error occured.
%   DISPERROR displays the message of the last error and also where this
%   error occured. This is helpful when the error was captured by a try-
%   catch block and then rethrown. Matlab will show the error message, but
%   unfortunately not where the error occured. DISPERROR displays the error
%   message and the error stack, complete with hyperlinks.
%
%   Another use for DISPERROR is with callbacks containing try-catch
%   block(s). In this case, however, the call to disperror must be in the
%   catch part of a try-catch block, such as:
%
%     set(gcf, 'ButtonDownFcn', 'try;fun;catch disperror;end');
%   or
%     set(gcf, 'ButtonDownFcn', 'try;fun;catch disperror;rethrow(lasterror);end');
%
%   The latter usage will cause the error message to be repeated, but will also
%   give information on which callback that was executed.
%
%   Example:
%
%      function testdisperror
%         try
%            a=[1 2 3];
%            b=a(4711);  % Index error
%         catch
%            % possibly do some housekeeping here
%            rethrow(lasterror);
%            end
%
%      >> testdisperror
%      ??? Attempted to access a(4711); index out of bounds because numel(a)=3.
%
%      >> disperror
%      ??? Attempted to access a(4711); index out of bounds because numel(a)=3.
%      Error in ==> testdisperror at 4
%                   ------------------  % <- Hyperlink
%
%   =======================
%   Version: 1.0 2006-02-27
%   Author: Jerker W�gberg, More Research, SWEDEN
%   email: char(hex2dec(reshape('6A65726B65722E77616762657267406D6F72652E7365',2,[])')')

	err = lasterror;
	% See if it is a syntax error
	match=regexp(err.message ...
			, {'(?<=File: *)([^ ].*)(?= *Line:)','(?<=Line: *)\d+'} ...
			, 'match');
	sp=1;
	mf=[];
	if any(cellfun('isempty',match))
		% Not syntax error, mimic Matlabs first error line
		disp(['??? ' err.message]);
		if ~isempty(err.stack)
			[mf,fn,line]=editem(err.stack(1));
			sp=2;
			end
	else
		% Syntax error, first line of message contains info for hyperlink
		mf=char(match{1});
		line=str2double(char(match{2}));
		% Show the actual error
		disp(['??? ' char(regexp(err.message,'(?<=\n)(.*)','match'))]);
		[fn,fn]=fileparts(mf);
		end
	if ~isempty(mf)
		% Show the error stack
		disp(sprintf('Error in ==> <a href="matlab:opentoline(''%s'',%d)">%s at %d</a>',mf,line,fn,line));
		for i=sp:length(err.stack)
			[mf,fn,line]=editem(err.stack(i));
			disp(sprintf('  In <a href="matlab:opentoline(''%s'',%d)">%s at %d</a>',mf,line,fn,line));
			end
		end
	end

function [mf,fn,line]=editem(x)
	% Build the function name
	[p,mnam]=fileparts(x.file);
	fn=x.name;
	if ~strcmpi(regexp(fn,'^[^/]+', 'match'),mnam)
		fn = [mnam '>' fn];
		end
	mf=x.file;
	line=x.line;
	end
% File: private\encodewmv.m ######################################################################
function encodewmv(input,output)
	if ~gotwmv
		error('WMV encoder not installed');
		end
	CLSID=winqueryreg('HKEY_CLASSES_ROOT','WMEncEng.WMEncoder\CLSID');
	eng=winqueryreg('HKEY_CLASSES_ROOT',['CLSID\' CLSID '\InprocServer32']);
	pth=fileparts(eng);
	wmcmd=fullfile(pth, 'wmcmd.vbs');
	parms='-v_mode 3 -v_performance 100 -v_bitrate 2000000 -silent';
	dos(sprintf('cscript.exe "%s" %s -input "%s" -output "%s"', wmcmd, parms, input, output));
	end
% File: private\gotwmv.m ######################################################################
function z=gotwmv
%Return true if the Windows WMV-encoder is installed
	z=false;
	if ispc
		try
			winqueryreg('HKEY_CLASSES_ROOT','WMEncEng.WMEncoder');
			z=true;
		catch
			end
		end
	end
% File: private\illpar.m ######################################################################
function z=illpar(msg,varargin)
%ILLPAR Return illegal parameter error struct.

% Part of the anymate toolbox
% Author:  Jerker W�gberg, More Research, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id:  $

	if isstruct(msg)
		msg=regexprep(msg.message,'^Error using ==> .*\n','');
	else
		msg=sprintf(msg,varargin{:});
		end
	z=struct('identifier','anymate:IllPar', 'message', msg);
	end
% File: private\onoff.m ######################################################################
function z=onoff(x)
%ONOFF Convert between 'on'/'off' setting and true/false
%   If input is a 'on'/'off', output is corresondingly true/false and vice
%   versa. Works with scalars and (cell-) arrays.
%
%   Example:
%      onoff('on')
%      onoff(false)

	if ischar(x) || iscellstr(x)
		x=cellstr(x);
		z=strcmp('on',x);
		ixoff=strcmp('off', x);
		if any(z == ixoff)
			error('Invalid input');
			end
	elseif islogical(x)
		oo={'off' 'on'};
		z=cell(size(x));
		z(:)=oo(double(x)+1);
		if isscalar(z)
			z=z{:};
			end
	else
		error('Invalid input');
		end
	end
% File: private\partialmatch.m ######################################################################
function [z,ix]=partialmatch(str,Options, noerr)
%PARTIALMATCH  Finds string matches � la Handle Graphics
%   Z=PARTIALMATCH(S,OPT) returns the string in OPT that either matches
%   exactly or unambiguously matches from the start. Comparisons are made
%   without regard to case. If no match can be established, an error is
%   raised.
%   Z=PARTIALMATCH(S,OPT, 'noerror') works like the previous but does not
%   raise an error if there is no match, instead an error message struct is
%   return with the field 'message' holding appropriate message.
%
%   Example:
%      partialmatch('abc',  {'Abc', 'abcdef'})
%      partialmatch('abcd', {'Abc', 'abcdef'})
%      partialmatch('ab'  , {'Abc', 'abcdef'})
%
%   See also: STRCMP, STRCMPI, STRMATCH, PARTIALINDEX

% Author:  Jerker W�gberg, More Research, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: partialmatch.m 23 2007-01-28 22:55:34Z jerkerw $

	if nargin<3 || isempty(noerr)
		noerr=false;
	else
		if isempty(strmatch(lower(noerr), 'noerror'))
			error('partialmatch:IllPar', 'Third argument can only be empty or ''noerror''');
			end
		noerr=true;
		end
	ix=find(strcmpi(str, Options));
	if ~isempty(ix)
		z=Options{ix};
	else
		ix=strmatch(lower(str), lower(Options));
		switch length(ix)
			case 0
				z=struct( ...
					  'message', sprintf('Option ''%s'' is not valid', str) ...
					, 'identifier', 'PartialMatch:NoMatch');
			case 1
				z=Options{ix};
			otherwise
				z=struct( ...
					  'message', sprintf('Option ''%s'' is ambiguous', str) ...
					, 'identifier', 'PartialMatch:AmbiguousMatch');
			end
		if isstruct(z) && ~noerr
			error(z);
			end
		end
	end
% File: private\RadioVector.m ######################################################################
function z=RadioVector(Choices,choice)
	ix=strmatch(choice, Choices);
	z=false(1,length(Choices));
	z(ix)=1;
	end
% File: private\roproperties.m ######################################################################
function Fields=roproperties(h)
%ROPROPERTIES  Get the read only properties of a Handle Graphics object
%   output = roproperties(input)
%
%   Example
%      roproperties
%
%   See also

% Author:  Jerker W�gberg
% Created: 2006-10-05
% Copyright � 2006 More Research.

	GetFields = fieldnames(get(h));
	SetFields = fieldnames(set(h));
	Fields=setdiff(GetFields,SetFields)';
	end
% File: pushprop.m ######################################################################
function z=pushprop(h, varargin)
%PUSHPROP Get, set and restore Handle Graphics objects
%   PUSHPROP is used to temporarily save and optionally set one or more
%   properties of one or more Handle Graphics objects.
%
%   SFUN=PUSHPROP(H,'PropertyName') gets the current value of the named
%   property and returns a restore struct SFUN, containing one field, the
%   function handle 'pop'. Calling SFUN.pop() will reset the object to the
%   previous value.
%
%   SFUN=PUSHPROP(H,pn) saves the current values of properties specified by
%   cell array pn and returns the restore function SFUN.
%
%   SFUN=PUSHPROP(H,'PropertyName',PropertyValue, ...) will save the
%   current values of the properties and also set the object's property to
%   PropertyValue.
%
%   SFUN=PUSHPROP(H,pn,MxN_pv) saves n property values from each of m
%   graphics objects, where m=length(H) and n is equal to the number of
%   property names contained in the cell array pn and then sets the same
%   objects to the new values MxN_pv. This allows you to set a given group
%   of properties to different values on each object.
%
%   PUSHPROP is used in passages normally coded like this:
%
%      SavedProp = get(h, 'Property');
%      set(h, 'Property', newval);
%      ... interact some more with object h
%      set(h, 'Property', SavedProp;
%
%   With PUSHPROP, the above segment can be written as
%
%      SavedProp = pushprop(h, 'Property', newval);
%      %      ... interact some more with object h
%      SavedProp.pop();
%
%   Although it does save you one line of code, the real advantage is that
%   the saved and restored property name(s) only need to be entered once,
%   making the code easier to maintain and also makes the coder's
%   intentions more transparent.
%
%   Remarks:
%   PUSHPROP closely mimics the syntax of SET, except for the output. Also,
%   it behaves consistently for a structure array, in that it treats the
%   elements in the array as individual setting for each handle. SET uses
%   the last element of the struct for all objects.
%
%   Example:
%      % Set the current figure's background color to red for two seconds.
%      SavedColor=pushprop(gcf, 'Color', [1 0 0]);
%      pause(2);
%      SavedColor.pop();
%
%   See also: SET, GET

%   071122 Version 1.0 Released to FEX
%   071123 Version 1.1 Realized that some settings depend on the order they
%                      are set. Fixed by restoring in reverse order.
%
%   Author: Jerker W�gberg, More Research, SWEDEN
%   email: char(hex2dec(reshape('6A65726B65722E77616762657267406D6F72652E7365',2,[])')')

	% Check for correct number of arguments. Not much more error checking
	% to do since GET and SET seem to return meaningful error messages.
	error(nargchk(2,inf,nargin, 'struct'));
	nargs=length(varargin);

	if nargin==2 && ~isstruct(varargin{1})
		% Caller just wants some properties saved.
		saved{1}=cellstr(varargin{1});
		saved{2} = get(h,saved{1});
	else
		% Preallocate storage for saved properties. Too big if structs are
		% used, but we correct that later.
		saved=cell(2,(nargs+rem(nargs,2))/2);

		% Initilize the saved setting counter
		ns=0;
		i=1;
		while i<=nargs
			ns=ns+1;
			if isstruct(varargin{i})
				s=varargin{i};
				saved{1,ns}=flipud(fieldnames(s));
				saved{2,ns}=get(h, saved{1,ns});
				% Fix for SET's questionable behaviour when input is a
				% structure array.
				set(h,flipud(saved{1,ns}),struct2cell(s(:))');
				i=i+1;
			else
				saved{1,ns}=cellstr(varargin{i});
				% Get in reverse order so we can set in back correctly
				saved{1,ns}=flipud(saved{1,ns}(:));
				saved{2,ns} = get(h,saved{1,ns});
				if i==nargs
					error('pushprop:MissingValues', 'Argument/Value pairs must come in pairs');
					end
				set(h, varargin{i}, varargin{i+1});
				i=i+2;
				end
			end
		% Trim the saved properties array
		saved(:,nargs+1:end)=[];
		saved=fliplr(saved);
		end
	z.pop=@()set(h, saved{:});
	end
% File: rgb2ind256.m ######################################################################
function [z,map]=rgb2ind256(rgb)
%RGB2IND256 Naive true color to indexed color converter

	[r,g,b]=ndgrid(linspace(0,255,8),linspace(0,255,8),linspace(0,255,4));
	map=round([r(:) g(:) b(:)])/255;
	z=uint8(bitshift(bitand(rgb(:,:,1),224),-5)+bitshift(bitand(rgb(:,:,2),224),-2)+bitand(rgb(:,:,3),192));
	end
% File: rtslider.m ######################################################################
function [zfun,hs]=rtslider(varargin)
%RTSLIDER Create a leightweight real-time slider control object
%   rtslider({hf}, fun, pos, {'scale',...|'Orientation',...|}

% Author:  Jerker W�gberg
% Created: 2006-06-15
% Copyright � 2006 More Research.

	[par,msg]=rtslider_argcheck(varargin);
	if strcmp(par.Action, 'clear')
		setappdata(gcf, 'sliderListeners',[]);
	else
		if ~isempty(msg), error('slider:IllPar', msg), end
		[zfun,hs]=createSlider(par);
		end
	end

function [zfun,hs]=createSlider(par)

	function z=raw2scaled(Tap)
		z=diff(par.Scale) * min(1,max(0,Tap)).^par.Gamma + par.Scale(1);
		end

	function z=scaled2raw(Tap)
		z=min(1,max(0,(Tap-par.Scale(1))/diff(par.Scale))).^(1/par.Gamma);
		end

	function SetControl(vargin)
		valids=struct( ...
			  'Scale', [] ...
			, 'Value', [] ...
			, 'Enable', par.Enable ...
			  );
		p=args2struct(valids, vargin);
		if par.Enable ~= onoff(p.Enable)
			par.Enable=onoff(p.Enable);
			set(hs, 'Enable', p.Enable);
			end
		if ~isempty(p.Scale)
			par.Scale=p.Scale;
			end
		if isempty(p.Value)
			ControlVal(CurTap);
		else
			ControlVal(p.Value);
			end
		end

	function z=ControlVal(Val, varargin)
		if nargin<1
			z=CurTap;
		elseif isempty(Val)
			SetControl(varargin);
		else
			ix=abs(Val-par.Scale)<=sqrt(eps);
			if any(ix)
				Val=par.Scale(ix);
				end
			RawTap=scaled2raw(Val);
			set(hs, 'Value', RawTap);
			CurTap=Val;
			if ~isequal(par.SelectionType, 'extend')
				callcallback(par.Callback, CurTap);
				end
			end
		end

	function SliderAction(hobject, ev, varargin) %#ok<INUSD>
		if par.Enable
			CurTap=raw2scaled(get(hobject, 'Value'));
			if ~isequal(par.SelectionType, 'extend')
				callcallback(par.Callback, CurTap);
				end
			end
		end
	
	function SliderDeleteFcn(h, evt) %#ok<INUSD>
		ls=getappdata(par.hf, 'sliderListeners');
		ls(ls==hSliderListener)=[];
		setappdata(par.hf,'sliderListeners', ls);
		end

	CurTap=0;
	hs=uicontrol( ...
				'Parent', par.hf ...
			, 'Style', 'slider' ...
			, 'Units', par.Units ...
			, 'Position', par.pos ...
			, 'Min', 0 ...
			, 'Max', 1 ...
			);
	if usejava('awt')
		chaincallback(hs, 'DeleteFcn', @SliderDeleteFcn);
		hSliderListener = handle.listener(hs,'ActionEvent',@SliderAction);
		ls=getappdata(par.hf, 'sliderListeners');
		setappdata(par.hf,'sliderListeners', [ls;hSliderListener]);
	else
		set(hs,'callback',@SliderAction);
		end

	par.SelectionType='';
	ControlVal(par.Default);
	zfun=@ControlVal;
	end

function [z,msg]=rtslider_argcheck(vargin)
	z=[];
	nargs=length(vargin);
	msg=nargchk(2,inf,nargs);
	if ~isempty(msg)
		return
		end
	base=1;
	if nargs<2
		error('slider:IllPar', 'Must have at least two parameters');
		end
	if ishandle(vargin{base})
		switch get(vargin{base}, 'type')
			case {'figure', 'uipanel'}
			otherwise
				error('MATLAB:rtslider:IllPar', 'Parameter 1 must be handle to figure or panel');
			end
		par.hf=vargin{base};
		base=base+1;
		nargs=nargs-1;
	else
		par.hf=gcf;
		end
	if nargs<2
		error('slider:IllPar', 'Must have at least a function handle and a position');
		end
	if ~isempty(vargin{base}) 
		if ischar(vargin(base))
			if strcmpi(vargin{base},'clear')
				z=par;
				z.Action='clear';
				return;
			else
				error('rtslider:IllPar', 'String parameter can only be ''clear''');
				end
		else
			if ~isa(vargin{base}, 'function_handle')
				error('slider:IllPar', 'Parameter must be a function handle');
				end
			par.Action='set';
			end
		end
	par.Callback=vargin{base};
	par.pos=vargin{base+1};
	base=base+2;
	if ~isequal(size(par.pos),[1 4])
		error('slider:IllPar', 'Size must be 1x4');
		end
	par.Scale = [0 1];
	par.Default = 0;
	par.Gamma = 1;
	par.Enable=true;
	par.Units='character';
	z=args2struct(par,vargin(base:end));
	end
% File: setdiffx.m ######################################################################
function z=setdiffx(a,b)
%SETDIFFX Find set difference of two vectors and keep order
%   Example:
%      See the difference between SETDIFFX and SETDIFF
%      setdiffx([6 5 4 3 2 1],[5 7])
%      setdiff([6 5 4 3 2 1],[5 7])
%
%   See also: SETDIFF

% Author:  Jerker W�gberg
% Created: 2006-10-23
% Copyright � 2006 More Research.

	[c,i]=setdiff(a,b);
	z=a(sort(i));
	end
% File: slidertext.m ######################################################################
function [zfun,hs,ht]=slidertext(varargin)
%SLIDERTEXT Create a combined lightweight numedit and slider object

% Author:  Jerker W�gberg
% Created: 2006-06-16
% Copyright � 2006 More Research.

	function SetControl(vargin)
		valids=struct( ...
			  'Scale', [] ...
			, 'Value', [] ...
			, 'PostLabel', 0 ...
			, 'Enable', par.Enable ...
			  );
		p=args2struct(valids, vargin);
		if ~isempty(p.Scale) && ~isempty(p.Value);
			funslid([],'Scale', p.Scale, 'Value', p.Value); %#ok<NOEFF>
			end
		if isempty(p.PostLabel) || ischar(p.PostLabel)
			par.PostLabel=p.PostLabel;
			par=SetLabel(hs,par,9);
			end
		par.Enable=p.Enable;
		funslid([], 'Enable', par.Enable); %#ok<NOEFF>
		funedit([], 'Enable', par.Enable); %#ok<NOEFF>
		end

	function z=ControlVal(val, varargin)
		if nargin<1
			z=funedit();
		elseif isempty(val)
			SetControl(varargin);
		else
			par.ForwardCallback=false;
			funslid(val);	%#ok
			funedit(val);	%#ok
			par.ForwardCallback=true;
			ForwardCallback(val);
			end
		end

	function ForwardCallback(Val)
		if par.ForwardCallback
			callcallback(par.Callback, Val);
			end
		end

	function ExclusiveSet(fun, Val)
		if ~par.InUpdate
			par.InUpdate=true;
			if ~isempty(fun)
				fun(Val);
				end
			par.InUpdate=false;
			ForwardCallback(Val);
			end
		end

	function NumCallbackFcn(Val)
		ExclusiveSet(funslid, Val);
		end

	function SliderCallback(Val)
		ExclusiveSet(funedit, Val);
		end

	[par,msg]=slidertext_argcheck(varargin);
	par.ForwardCallback = false;
	par.Enable = 'on';
	if ~isempty(msg), error('slidertext:IllPar', msg), end
	funedit=[];
	funslid=[];
	par.InUpdate=false;
	par.ForwardCallback=false;
	[funslid,hs]=rtslider( ...
		  par.hf ...
		, @SliderCallback ...
		, par.pos ...
		, 'Scale', par.Scale ...
		, 'Default', par.Default ...
		, 'Gamma', par.Gamma ...
		);
	pos=get(hs,'Position');
	[funedit,ht]=numedit( ...
		  par.hf ...
		, @NumCallbackFcn ...
		, [pos(1)+pos(3)+1 pos(2)] ...
		, 'Width', 8 ...
		, 'Default', par.Default ...
		);
	par.hLabel = [];
	par.hPostLabel = [];
	if ~isempty(par.Label) || ~isempty(par.PostLabel)
		par=SetLabel(hs,par,9);
		end
	par.ForwardCallback=true;
	ControlVal(par.Default);
	zfun=@ControlVal;
	end

function par=SetLabel(ha,par, extra)
	Height=get(ha, 'Position');
	Height=Height(4);
	txt={'Label' 'PostLabel'};
	if ~isempty(par.hPostLabel)
		delete(par.hPostLabel);
		par.hPostLabel=[];
		end
	for i=1:2
		if ~isempty(par.(['h' txt{i}]));
			delete(par.(['h' txt{i}]));
			par.(['h' txt{i}])=[];
			end
		if ~isempty(par.(txt{i}))
			ht=text(0,Height/2,par.(txt{i}), 'Parent',ha, 'VerticalAlign', 'middle');
			set(ht, 'Units', 'character', 'FontSize', 8);
			if i==1
				ext=get(ht, 'Extent');
				pos=get(ht, 'Position');
				set(ht, 'Position', pos-[ext(3)+.2 0 0]);
			else
				set(ht, 'Position', pos+[par.pos(3)+extra+1 0 0]);
				end
			set(ht, 'Units', 'data');
			par.(['h' txt{i}])=ht;
			end
		end
	end

function [z,msg]=slidertext_argcheck(vargin)
	z=[];
	nargs=length(vargin);
	msg=nargchk(2,inf,nargs);
	if ~isempty(msg)
		return
		end
	base=1;
	if nargs<2
		msg='Must have at least two parameters';
		return;
		end
	if ishandle(vargin{base})
		switch get(vargin{base}, 'type')
			case {'figure', 'uipanel'}
			otherwise
				msg='Parameter 1 must be handle to figure or panel';
				return;
			end
		par.hf=vargin{base};
		base=base+1;
		nargs=nargs-1;
	else
		par.hf=gcf;
		end
	if nargs<2
		msg='Must have at least a function handle and a position';
		return
		end
	if ~iscell(vargin{base}) && ~isempty(vargin{base}) && ~isa(vargin{base}, 'function_handle')
		msg='Parameter must be a function handle';
		return;
		end
	par.Callback=vargin{base};
	par.pos=vargin{base+1};
	base=base+2;
	if ~isequal(size(par.pos),[1 4])
		msg='Size must be 1x4';
		return;
		end
	par.Scale = [0 1];
	par.Default = 0;
	par.Label = '';
	par.PostLabel='';
	par.Gamma = 1;
	z=args2struct(par,vargin(base:end));
	end
% File: strippedancestor.m ######################################################################
function z=strippedancestor(handles, type)
%STRIPPEDANCESTOR  Get object ancestor
%    P = STRIPPEDANCESTOR(H,TYPE) returns the handle of the closest
%    ancestor of h that matches one of the types in TYPE. TYPE may be a
%    single string (single type) or cell array of strings (types). If H is
%    a vector of handles then P is a vector holding the ancestors of H that
%    it could find. This means that P does not have to be the same lenght
%    as H. If H is one of the specified types then ancestor 
%    returns H. 
%
%   Example:
%      strippedancestor(gca, 'figure');
%
%   See also: ANCESTOR

% Author:  Jerker W�gberg
% Created: 2006-10-11
% Copyright � 2006 More Research.

	z=ancestor(handles, type);
	if iscell(z)
		ix=~cellfun(@isempty,z);
		z=[z{ix}];
		end
	end
% File: strlineate.m ######################################################################
function z=strlineate(s)
	c=strcat(cellstr(s),{char(10)});
	z=[c{:}];
	z=z(1:end-1);
	end
% File: timeline.m ######################################################################
function RetFuns=timeline(hf, OrgTickLabel, varargin)
%TIMELINE Create and operate a time-axis control
%   [FUN,HAX]=TIMELINE(HF, TTICKLABEL, TTICK) creates an axes object at the
%   bottom of a figure HF. Labels in char array TTICKLABEL are plotted at
%   x-coordinates specified in TTICK. The axes' XLIM are set so that the
%   labels do not overlap, but have enough space between the labels to
%   cleary separate them. In the middle of the x-axis, a marker is plotted to
%   indicate current time. When the timeline has been created, the axis can
%   be scrolled so that the label corresponding to current time is located
%   in the middle of the axis. 
%
%   Example:
%      figure
%      fun=timeline(gcf,{'Low', 'Middle', 'High'},[1 2 4]);
%      drawnow; pause(.5);
%      for t=linspace(1,4,20);
%         fun.Time(t);
%         pause(.1);
%         end
%
%   See also:

% Author:  Jerker W�gberg
% Created: 2006-10-11
% Copyright � 2006 More Research.

%==========================================================================
%- Object Utility functions -----------------------------------------------
%==========================================================================

	function z=Clip(t)
	% Make sure the argument t is within range.
		if strcmp(G.RunMode, 'circle')
			if G.PseudoTime
				z=mod(t-1,G.nTicks)+1;
			else
				off=G.Tick(1);
				z=mod(t-off, OrgTick(end) - off) + off;
				end
		else
			if G.PseudoTime
				z=min(max(t,1), G.nTicks);
			else
				z=min(max(t, G.Tick(1)), G.Tick(end));
				end
			end
		end

	function z=CurX
	% Get the current point from timeline, i.e. the x-coordinate of the
	% point most recently clicked on by the user.

		cp=get(G.hax,'CurrentPoint');
		z=cp(1);
		end

%==========================================================================
%- Time marker object, the little black triangle in the bottom ------------
%==========================================================================

	function funs=TimeMarker

		function Visible(v)
			set(hp, 'Visible', onoff(v));
			end

		function z=Time(t)
		% Set the current time. We do that in somewhat unorthodox way, in
		% that we set the axis so that the current time is in the middle of
		% the axis and the time marker is moved to this middle point. This
		% gives the effect that the time marker is fixed in the middle,
		% while the labels scrolls by, since they do not move relative the
		% axis.

			if nargin<1
				z=CurTime;
			else
				if ~isscalar(t) || ~isnumeric(t)
					error('timeline:Time must be numeric scalar');
					end
				t=Clip(t);
				if G.hax
					% Set the current time as the value in the middle
					set(G.hax, 'XLim', t + G.RangeX * [-1 1]/2);
					% Also move the time marker to the middle
					v=Vertices*G.Pix2Data+repmat([t 0],size(Vertices,1),1);
					set(hp, 'Vertices', v);
					end
				% Save as current time
				CurTime=t;
				end
			end

		function CreateFcn(obj, eventdata) %#ok<INUSD>
			hp=obj;
			end
		
		function Refresh
			Time(CurTime);
			end

		%------------------------------------------------------------------
		%- TimeMarker Main 
		%------------------------------------------------------------------

		% Declare a variable for the Current Time
		CurTime = 0;

		% Declare handle to patch. Will be set by CreateFcn.
		hp=[];
		
		% Define the marker as a transparent triangle, 1 charachter wide
		% and 0.3 chars high.
		Vertices=[-1 0;0 1;1 0];
		Vertices=Vertices .* repmat( ...
								  G.CharInPixels .* [1 .3] ...
								, size(Vertices,1),1);
		
		% Make sure the marker can be seen
		if all(get(G.hax,'Color')>.5)
			EdgeColor='k';
		else
			EdgeColor='w';
			end
			
		% Create the patch
		patch('Parent', G.hax ...
			, 'Faces', [1 2 3] ...
			, 'Vertices', Vertices ...
			, 'FaceColor', 'none' ...
			, 'EdgeColor', EdgeColor ...
			, 'Hittest', 'off' ...
			, 'CreateFcn', @CreateFcn ...
			);
		
		% Export the functions controlling the time marker.
		funs=struct( ...
			  'Time', @Time ...
			, 'Visible', @Visible ...
			, 'Refresh', @Refresh ...
			);
		end

%==========================================================================
%- TimeLabels object ------------------------------------------------------
%==========================================================================

	function funs=TimeLabels(NewOrderFun)
	
		function NewLabelSet(ht)
			function LabelCopyCreateFcn(h, evt, ix) %#ok<INUSL>
				G.ht(ix,1)=h;
				end

			% Get copies of labels, but take care not to invoke any
			% CreateFcns
			sv=pushprop(ht, 'CreateFcn', '');
			G.ht=copyobj(ht, G.hax);
			sv.pop();
			
			m=length(ht);
			reps=m/G.nTicks;
			cr8funs=dim2cell([repmat({@LabelCopyCreateFcn}, m, 1) num2cell((1:m)')],2);
			if G.PseudoTime
				d=G.nTicks;
			else
				d=diff(OrgTick([1 end]));
				end
			Tick=repmat(G.Tick, reps, 1) - d*(reps-1)/2;
			Tick=Tick + d*floor(((1:m)'-1)/G.nTicks);
			pos=dim2cell([Tick .5*ones(m,1), zeros(m,1)],2);
			set(G.ht, {'CreateFcn'}, cr8funs, {'Position'}, pos);
			end
	
		function PlaceLabels
			% Delete all currently visible labels
			delete(G.ht);
			G.ht=[];
			
			% Get a set of template handles whos subsequent copies are to be visible
			ht=G.htpl(G.TickOrder);
			
			% If we are circling, we need some extra labels
			if strcmp(G.RunMode, 'circle')
				% Position the first and the last label
				rng=[1 length(ht)];
				set(ht(rng), {'Position'}, dim2cell([G.Tick(rng) .5*ones(2,1), zeros(2,1)],2));
				% Find the extents of the labels
				ext=get(ht([1 end]), 'Extent');
				ext=cat(1,ext{:});
				% Calculate the width from the first character in the first
				% label to the last character in the second label
				width=sum(ext(2,[1 3]))-ext(1,1);
				% How many such widths does it take to cover half the timeline?
				% We then add sets of labels to fill up the whole timeline.
				% We calculate it like this, since we start with the first
				% label in the middle of the timeline.
				n=ceil(G.RangeX/2/width);
				ht=repmat(ht, 2*n+1,1);
				end
			
			% Create copies of the labels. Will set G.ht to the created
			% handles.
			NewLabelSet(ht);
			
			cpos=get(G.ht, {'Position'});
			pos=cat(1, cpos{:});
			set(G.hax,'XTick', pos(:,1));
			set(G.ht, 'Visible', onoff(G.Visible));
			end

		function RunMode(mode)
			G.RunMode=mode;
			Refresh;
			end

		function TemplateCreateFcn(obj,evt,ix) %#ok<INUSL>
			G.htpl(ix,1)=obj;
			end

		function z=SameLabels(ix)
		% Return all handles that represents the same original label as h.
		% This can be more than one if RunMode is 'circle'

			z=findall(G.ht, 'UserData', ix);
			end

		function LabelButtonDownFcn(hCur, evt) %#ok<INUSD>

			function z=LabelMoveFcn(obj, evt) %#ok<INUSD>
				CurIx=find(G.TickOrder==Cur);
				x=CurX;
				dir=x-OldX;
				OldX=x;
				n=G.nTicks;
				if strcmp(G.RunMode, 'circle')
					x=mod(x-1,n)+1;
					if dir<0
						x=ceil(x);
						if x>n, x=1; end
					else
						x=floor(x);
						if x<1, x=n; end
						end
				else
					x=min(n,max(1,x));
					if dir<0
						x=ceil(x);
					else
						x=floor(x);
						end
					end
				if x~=CurIx
					G.TickOrder(CurIx)=[];
					Order([G.TickOrder(1:x-1) Cur G.TickOrder(x:end)]);
					set(SameLabels(Cur), 'FontWeight', 'bold');
					end
				setappdata(hCurMenu, 'HaveMoved', true);
				z=false;
				end

			function z=LabelUpFcn(obj,evt) %#ok<INUSD>
				if G.PseudoTime
					unchaincallback(hf,'WindowButtonMotionFcn');
					G.InNewOrder=false;
					if getappdata(hCurMenu, 'HaveMoved')
						Order(Order);
						end
					end
				unchaincallback(hf,'WindowButtonUpFcn');
				set(SameLabels(Cur), 'FontWeight', 'normal');
				animuimode(hf,explorestate);
				z=false;
				end

			%------------------------------------------------------------------
			%- LabelButtonDownFcn Main 
			%------------------------------------------------------------------

			Cur = get(hCur, 'UserData');
			SelectionType = get(hf, 'SelectionType');
			OldX=CurX;
			switch SelectionType
				case 'alt'
					explorestate=animuimode(hf, 'off');
					if G.PseudoTime
						chaincallback(hf,'WindowButtonMotionFcn', @LabelMoveFcn);
						G.InNewOrder=true;
						end
					chaincallback(hf,'WindowButtonUpFcn', @LabelUpFcn);
					set(SameLabels(Cur), 'FontWeight', 'bold');
					
					% Communicate with context menu function callbacks via
					% appdata of the menu.
					hCurMenu=get(hCur, 'UIContextMenu');
					setappdata(hCurMenu, 'ClickedIx', Cur);
					setappdata(hCurMenu, 'HaveMoved', false);
				case 'normal'
					callcallback(get(G.hax, 'ButtonDownFcn'), G.hax, []);
				case 'open'
					set(hCur, 'Editing', 'on');
					waitfor(hCur, 'Editing', 'off');
					% Check that the figure wasn't deleted by user
					if ishandle(hCur)
						set(G.htpl(Cur), 'String', get(hCur, 'String'))
						G.LabelWidthsInPixels(Cur) = GetExtents(hCur, G.hax);
						Refresh;
						end
				end
			end

		function SizeAxis
		% Calculate G.RangeX and G.PixData. Both are needed by TimeMarker.
		% G.RangeX can be retrieved as diff(xlim(G.hax)) and G.PixData is
		% used to convert from pixel coordinates into data oordinates.

			% Get the width of the figure in pixels
			pos=GetInUnits(hf,'Position', 'Pixel');
			HorPix=pos(3);

			% Calculate the widths between the midpoints of two subsequent
			% labels as parts of the whole axis, assuming they are just
			% separated by GUTTERWIDTH, <GW>.
			%   Label01<GW>lb2<GW>AReallyLongLabel3
			%      |<--W1-->|<-----W2---->|
			
			n=G.nTicks;
			if strcmp(G.RunMode, 'circle')
				LeftIx=1:n;
				RightIx=[2:n 1];
			else
				LeftIx=1:n-1;
				RightIx=2:n;
				end
			TickWidths= (GUTTERWIDTH*G.CharInPixels(1) ...
							+ ( ...
								  G.LabelWidthsInPixels(G.TickOrder(LeftIx)) ...
								+ G.LabelWidthsInPixels(G.TickOrder(RightIx)) ...
							   )/ 2) ...
						/ HorPix; ...

			% Calculate how many axis intervalls there are for each
			% intervall. By choosing the intervall that would be repeated
			% the least number of times as the range for XLim, i.e.
			% diff(xlim), we guarantee that there is at least GUTTERWIDTH
			% between the labels.
			G.RangeX=min(diff(AxisTicks) ./ TickWidths);

			% TimeMarker object is defined in pixels. To place it in the
			% axis, we need a conversion from pixels to axis data.
			yl=get(G.hax, 'YLim');
			G.Pix2Data=diag([G.RangeX diff(yl)] ./ [HorPix G.CharInPixels(2)]);
			end

		function z=AxisTicks
		% Return the basic tick positions for calculation of axis scaling.
		% If not in circle mode, it's just the basic ticks, but if we are
		% circling, we concatenate with the last tick plus one if in
		% PseudoTime, and with the first shown tick plus range of ticks if
		% not in PseudoTime.
		
			if strcmp(G.RunMode, 'circle')
				if G.PseudoTime
					z=(1:G.nTicks+1)';
				else
					z=[G.Tick;diff(OrgTick([1 end]))+OrgTick(G.TickOrder(1))];
					end
			else
				z=G.Tick;
				end
			end

		function SetOrder(to)
			G.TickOrder=to;
			G.nTicks=length(to);
			if G.PseudoTime
				G.Tick=1:length(to);
			else
				G.Tick=OrgTick(to);
				end
			G.Tick=G.Tick(:);
			G.TickLabel=OrgTickLabel(to);
			Refresh;
			end
		
		function Refresh
			if isempty(G.TickOrder)
				error('timeline:TimeLabels:IllegalCallOrder', 'TimeLabel.Order must be called before Refresh');
				end
			SizeAxis;
			PlaceLabels;
			G.RetFuns.Time(G.RetFuns.Time());
			end

		function z=Order(to)
			if nargin<1
				z=G.TickOrder;
			else
				if isempty(to)
					error('timeline:timelabels:InvalidOrder' ...
						, 'Must have at least one tick');
					end
				if ~all(ismember(to,1:length(OrgTickLabel)))
					error('timeline:timelabels:InvalidOrder' ...
						, 'Invalid time tick order');
					end
				if ~G.PseudoTime && any(diff(to)<1)
					error('timeline:timelabels:InvalidOrder' ...
						, 'Ticks must be increasing for real time ticks');
					end
				SetOrder(to);
				Refresh;
				NewOrderFun(G.TickOrder);
				if ~isequal(G.TimeCallback, @NullCallback)
					G.TimeCallback(G.TimeCallback());
					end
				end
			end
	
		function BuildLabels

			function Buildcmenu(obj, evt) %#ok<INUSD>

				function HideLabel(obj, evt) %#ok<INUSD>
					Order(setdiffx(Order, ClickedIx));
					end

				function ReInstate(obj,evt,CurIx)		%#ok
					Order(sort([Order,CurIx]));
					end

				function ShowBefore(obj, evt, CurIx)	%#ok
					Ord=Order;
					ix=find(Ord==ClickedIx);
					Order([Ord(1:ix-1) CurIx Ord(ix:end)]);
					end

				function ShowAll(obj, evt) %#ok<INUSD>
					Order(1:length(OrgTickLabel));
					end

				%------------------------------------------------------------------
				%- BuildCMenu Main 
				%------------------------------------------------------------------

				delete(get(obj, 'Children'));
				if ~getappdata(obj, 'HaveMoved')
					ClickedIx=getappdata(obj, 'ClickedIx');
					uimenu(obj ...
						, 'Label', 'Hide' ...
						, 'Callback', @HideLabel ...
						, 'Enable', onoff(length(Order) > 2) ...
						);
					uimenu(obj ...
						, 'Label', 'Reset' ...
						, 'Callback', @ShowAll ...
						, 'Enable', onoff(~isequal(Order, 1:length(OrgTickLabel))) ...
						);
					if G.PseudoTime
						lbl='Insert';
						cb=@ShowBefore;
					else
						lbl='Reinstate';
						cb=@ReInstate;
						end
					hm=uimenu(obj ...
						, 'Label', lbl ...
						, 'Enable', onoff(length(Order) < length(OrgTickLabel)) ...
						);
					IxHidden=setdiff(1:length(OrgTickLabel),Order);
					lbl=get(G.htpl(IxHidden), {'String'});
					[qq, ix]=sort(lbl);
					arrayfun(@(x)uimenu(hm,'Label', lbl{x}, 'Callback', {cb IxHidden(x)}), ix);
					end
				end

			%------------------------------------------------------------------
			%- BuildLabels Main 
			%------------------------------------------------------------------

			% Create templates for labels. Never mind the positions, they
			% will be set for the copies of these templates.

			% Store each templates index in G.htpl in UserData of each
			% text. It will come to use when these invisible labels are
			% copied in NewLabelSet. Also build a cell array of CreateFcn
			% that will ensure we get valid handles when recreated from a
			% .fig file.

			m=length(OrgTickLabel);
			rng=num2cell((1:m))';
			cr8funs=dim2cell([repmat({@TemplateCreateFcn}, m, 1) rng],2);

			% Use a common contextmenu, that are created dynamically
			uictx=uicontextmenu('Callback', @Buildcmenu, 'HandleVisibility', 'off');
			
			% Create the labels. G.htpl will hold handles to all templates,
			% by means of the TemplateCreateFcn.
			text(zeros(m,1), zeros(m,1), OrgTickLabel ...
				, 'HorizontalAlignment', 'center' ...
				, 'VerticalAlignment', 'baseline' ...
				, 'FontUnits', 'pixel' ...
				, 'FontSize', G.CharInPixels(2)*.5 ...
				, 'Parent', G.hax ...
				, 'ButtonDownFcn', @LabelButtonDownFcn ...
				, 'UIContextMenu',  uictx ...
				, {'CreateFcn'}, cr8funs ...
				, {'UserData'}, rng ...
				, 'Clipping', 'off' ...
				, 'Interruptible', 'off' ...
				, 'BusyAction', 'cancel' ...
				, 'Visible', 'off' ...
				);
			dbgcallback(G.htpl);
			G.LabelWidthsInPixels=GetExtents(G.htpl,G.hax);
			end

		%------------------------------------------------------------------
		%- TimeLabels Main 
		%------------------------------------------------------------------
		BuildLabels;
		funs.Order=@Order;
		funs.RunMode = @RunMode;
		funs.Refresh= @Refresh;
		end

%==========================================================================
%- TimeAxis "object" ------------------------------------------------------
%==========================================================================

	function funs=TimeAxis

		function z=Visible(mode)
			if nargin==0
				z=G.Visible;
			else
				G.Visible=mode;
				set(G.hax, 'Visible', onoff(G.Visible));
				TimeLabelsFuns.Refresh();
				TimeMarkerFuns.Visible(G.Visible);
				end
			end

		function varargout=Time(varargin)
			varargout=cell(1,nargout);
			if DragInProgress
				% Ignore setting of timeline when user is dragging the
				% timeline. Return current time if no input arguments.
				if nargin==0
					[varargout{:}]=TimeMarkerFuns.Time();
					end
			else
				[varargout{:}]=TimeMarkerFuns.Time(varargin{:});
				end
			end

		function ListenNewOrder(Order)
		% Report back the new order to caller, unless user is in process of
		% dragging a label.
			if ~G.InNewOrder
				G.OrderCallback(Order);
				end
			end

		function PositionAxis
			% Get the figure's position
			pos=GetInUnits(hf,'Position', 'Pixel');
			HorPix=pos(3);
			% Position the timeline at the bottom of the figure, all the
			% way, from left to right.
			set(G.hax, 'Position',[1 1 HorPix G.CharInPixels(2)]);
			end

		function Refresh
			PositionAxis;
			TimeLabelsFuns.Refresh();
			TimeMarkerFuns.Refresh();
			end

		function z=FigureResizeFcn(hf,evt) %#ok<INUSD>
		% Figure has been resized.
			Refresh();
			z=true; % We want this call to propagate to others
			end

		function z=AxesButtonDownFcn(obj,evt) %#ok<INUSD>

			function AxesMoveFcn(obj, evt) %#ok<INUSD>
			% User is dragging the axis. Calculate the new time and set
			% Timemarker. Also notify the intial caller of timeline.
				NewTime=Clip(TimeMarkerFuns.Time()-(CurX-OldX));
				TimeMarkerFuns.Time(NewTime);
				G.TimeCallback(NewTime);
				OldX=CurX;
				% Do not pass this event on to previous users of this hook
				z=false;
				end

			function z=AxesUpFcn(obj,evt) %#ok<INUSD>
			% User has quit dragging. Restore the callbacks and possibly
			% PAN, ZOOM or ROTATE.
				unchaincallback(hf,'WindowButtonUpFcn', FigResUp);
				unchaincallback(hf,'WindowButtonMotionFcn', FigResId);
 				DragInProgress=false;
				animuimode(hf,uim);
				% Do not pass this event on to previous users of this hook
				z=false;
				end

			%------------------------------------------------------------------
			%- AxesButtonDownFcn Main 
			%------------------------------------------------------------------
			
			OldX=CurX;
			DragInProgress=true;
			
			% Disable PAN, ZOOM and ROTATE so the WindowButtonUpFcn can be
			% set. Save their state, so they can be reenabled when user
			% quits dragging.

			uim=animuimode(hf, 'off');

			% Hook up to functions
			FigResUp=chaincallback(hf,'WindowButtonUpFcn', @AxesUpFcn);
			FigResId=chaincallback(hf,'WindowButtonMotionFcn', @AxesMoveFcn);
			end

		function AxesCreateFcn(obj, eventdata) %#ok<INUSD>
			G.hax=obj;
			hf=ancestor(G.hax,'figure');
			end

		function AxesDeleteFcn(src,evt) %#ok<INUSD>
			unchaincallback(hf, 'ResizeFcn', FigureResizeFcnId);
			G.ShutDownCallback();
			G.hax=[];
			end

		function CloseFcn
		% Commit suicide, unless already dead.
			delete(G.hax(ishandle(G.hax)));
			end

		%------------------------------------------------------------------
		%- TimeAxis Main 
		%------------------------------------------------------------------

		% The user is not currently dragging the timeline
		DragInProgress=false;

		% Make sure the axis is the only one within this figure
		delete(findall(hf, 'Tag', 'JWTimeAxis'));
		
		% Save, possibly empty, current axes so we can restore it as gca
		prevax=pushprop(hf, 'CurrentAxes');
		
		% Create axes to be used as timeline
		axes( ...
			  'Tag', 'JWTimeAxis' ...						% Tag it with a unique tag
			, 'DeleteFcn', @AxesDeleteFcn ...
			, 'HitTest', 'on' ...
			, 'CreateFcn', @AxesCreateFcn ...
			, 'ButtonDownFcn', @AxesButtonDownFcn ...
			, 'Units', 'pixel' ...
			, 'XTickMode', 'manual' ...
			, 'XTickLabelMode', 'manual' ...
			, 'YTick', [] ...
			, 'YLim', [0 1] ...
			, 'YColor', get(hf, 'DefaultAxesColor') ...		% We don't want to see this axis
			, 'HandleVisibility', 'off' ...
			, 'Visible', onoff(G.Visible) ...
			);
		% Restore previous gca
		prevax.pop();

		% Tell ZOOM, PAN and ROTATE to ignore this axis
		ExploreException(hf,G.hax);

		% Put axes on z-top
		ch=get(hf,'children');
		ch=[G.hax;ch(ch~=G.hax)];
		set(hf,'children',ch);

		% Get the pixel extents of a 1 character wide and 2 charachters high unit from the axes

		saveax=pushprop(G.hax,{'Units','Position'});
		set(G.hax ...
			, 'Units', 'character' ...
			, 'Position', [0 0 1 2] ...
			, 'Units', 'pixels');
		pos=get(G.hax, 'Position');
		saveax.pop();
		G.CharInPixels=pos(3:4);

		% Get TimeMarker and TimeLabels objects
		TimeMarkerFuns = TimeMarker;
		TimeLabelsFuns = TimeLabels(@ListenNewOrder);

		% Setup return functions
		funs = struct( ...
			  'Time', @Time ...
			, 'Order', TimeLabelsFuns.Order ...
			, 'Close', @CloseFcn ...
			, 'RunMode', TimeLabelsFuns.RunMode ...
			, 'Visible', @Visible ...
			);
		
		% make sure we are notified of figure resizes
		FigureResizeFcnId=chaincallback(hf, 'ResizeFcn',@FigureResizeFcn);
		
		% Put the timeline in its place, intialize current time and
		PositionAxis;
		end

%==========================================================================
%- TimeLine main ----------------------------------------------------------
%==========================================================================

	error(nargchk(2,inf,nargin,'struct'));

	% If the ticklabels are numeric we convert them to numeric strings
	if isnumeric(OrgTickLabel)
		OrgTickLabel = cellstr(num2str(OrgTickLabel(:)))';
		end

	% Separate possibly empty OrgTick and the named arguments
	[OrgTick,vargin]=parseparams(varargin);

	% If OrgTick is empty, we make a note of the fact and assign
	% equidistant ticks
	PseudoTime = isempty(OrgTick) || isempty(OrgTick{:});
	if PseudoTime
		OrgTick=1:length(OrgTickLabel)+1;
	else
		OrgTick=OrgTick{:};
		end
	
	% Set up default named arguments and parse input
	par=struct( ...
		  'TimeCallback'		, @NullCallback ...
		, 'OrderCallback'		, @NullCallback ...
		, 'RunMode'				, 'forward' ...
		, 'Time'				, OrgTick(1) ...
		, 'ShutDownCallback'	, @NullCallback ...
		);
	par=args2struct(par,vargin);
	
	% Define the number of characters between labels.

	GUTTERWIDTH=3;

	% Define object globals
	G=struct( ...
		  'CharInPixels'	, [] ...						A 1x2 character in pixels
		, 'CurTime'			, par.Time ...					Current time
		, 'DeltaX'			, [] ...
		, 'InNewOrder'		, false ...						Prevent recursion when rearranging
		, 'LabelWidthsInPixels' , [] ...
		, 'OrderCallback'	, par.OrderCallback ...			Whom to call when user changes the order of labels
		, 'Pix2Data'		, [] ...
		, 'PseudoTime'		, PseudoTime ...				Set if no explicit tick given. Means that we can
							...								run in circle mode and rearrange breaks.
		, 'RunMode'			, par.RunMode ...				'forward', 'pingpong' or 'circle'
		, 'ShutDownCallback', par.ShutDownCallback ...		Whom to call when the timeline gets deleted
	    , 'Tick'			, [] ...
		, 'TickLabel'		, [] ...
		, 'TickOrder'		, [] ...						Default order of labels
		, 'TimeCallback'	, par.TimeCallback ...			Whom to call when user drags the timeline
		, 'Visible'			, true ...						True if timeline visible
		, 'hax'				, [] ...						Axes handle
		, 'htpl'			, [] ...						Handles to label templates. These are never visible.
		, 'ht'				, [] ...						Handles to visible labels.
		, 'nTicks'			, [] ...						Number of TickLabels
		, 'RetFuns'			, [] ...
		);
	
	% Create the timeline
	G.RetFuns=TimeAxis;
	
	% Set the default order and the current time
	G.RetFuns.Order(1:length(OrgTickLabel));
	G.RetFuns.Time(par.Time);
	RetFuns=G.RetFuns;
	end

%==========================================================================
%- Utility functions ------------------------------------------------------
%==========================================================================

function NullCallback(varargin)
	end

function z=GetInUnits(h,prop,unit)
% Get a property in given units
	oldunit=get(h, {'Units'});
	set(h, 'Units', unit);
	z=get(h, prop);
	set(h, {'Units'}, oldunit);
	end

function z=GetExtents(ht, hax)
	% Get the horizontal extents of labels in pixels. Setting the units to
	% pixels can make them move a little so do it with a copy.

	sv=pushprop(ht, 'CreateFcn', '');
	ht=copyobj(ht, hax);
	sv.pop();

	set(ht, 'Units', 'pixels');
	ext=get(ht,{'Extent'});
	delete(ht);
	ext=cat(1,ext{:});
	z=ext(:,3);
	end
% File: timeslice.m ######################################################################
function ts=timeslice(OrgFun, OrgData, varargin)
%TIMESLICE Handle timer and interpolation for the animation routine
	%======================================================================
	%- Time data functions ------------------------------------------------
	%======================================================================

	function t=Frame2Time(Frame)
	% Convert from frame number to simulated time
		t=diff(G.Range) / (G.Frames-G.Bump) * (Frame-1) + G.Range(1);
		end

	function Frame=Time2Frame(t)
	% Convert from frame time to frame number. Note that the frame number
	% need not be an integer.
	
		if G.Circling
			Frame= G.Frames * mod(t-G.Range(1),diff(G.Range))/diff(G.Range) + 1;
		else
			Frame=min(G.Frames, max(1,(t-G.Range(1))*(G.Frames-1)/diff(G.Range)+1));
			end
		end

	function NewPP
	% Calculate a new piecewise polynomial.
		function z=GetMethod(Breaks)
			if ~any(diff(Breaks,2))
				z=['*' G.Method];
			else
				z=G.Method;
				end
			end
		
		function z=mod1(x,y)
			z=mod(x-1,y)+1;
			end

		function [z,mask]=myinterp1pp(x,y,method)
		% If the interpolation method is some kind of spline, there must me
		% at least two valid, (not nans), data points per column. If not,
		% we substitute the nans for zeroes here and return the mask for
		% use in TimerFcn.

			if isempty(strfind(method, 'linear'))
				mask=sum(~isnan(y))<2;
				y(:,mask)=0;
			else
				mask=[];
				end
			z=interp1(x,y,method,'pp');
			end

		n=length(G.TickOrder);
		ws=warning('off','MATLAB:interp1:NaNinY');
		pad=2;
		switch G.RunMode
			case 'forward'
				if G.IsPseudoTime
					Breaks=1:n;
				else
					Breaks = G.TTick(G.TickOrder);
					end
				G.Range=Breaks([1 n]);
				G.CurDir = 1;
				G.Bump = 1;
				Method=GetMethod(Breaks);
				[G.PP,G.NanMask]=myinterp1pp(cast(Breaks, class(G.Data)),G.Data(:,G.TickOrder)',Method);

			case 'pingpong'
				% To get a smooth interpolation when spline is active, we
				% must take care of the endpoints. We mirror break two
				% around break 1 and in the same manner, mirror break n-1
				% around break n.

				tix=mod1([pad+1:-1:2 1:n  n-1:-1:n-pad],n);
				if G.IsPseudoTime
					Breaks=1-pad:n+pad;
				else
					off=G.TTick(1)-sum(abs(diff(G.TTick(G.TickOrder(tix(1:pad+1))))));
					Breaks=cumsum([0 abs(diff(G.TTick(G.TickOrder(tix))))]) + off;
					end
				G.Range=Breaks([1 n]+pad);
				G.Bump = 1;
				Method=GetMethod(Breaks);
				[G.PP,G.NanMask]=myinterp1pp(cast(Breaks, class(G.Data)),G.Data(:,G.TickOrder(tix))',Method);

			case 'circle'
				% To get a smooth interpolation when circle is active, we
				% must take care of the endpoints. We therefore put
				% break one after break n and in the same manner,
				% put break n-1 before break 1. Must also take care
				% when we have just two breaks.

				ext=1-pad:n+1+pad;
				if G.IsPseudoTime
					Breaks=ext;
				else
					r=floor((ext-1)/n);
					OrdIx=mod1(ext,n);
					Breaks=r*diff(G.TTick([1 end]))+G.TTick(G.TickOrder(OrdIx));
					end
				G.Range=Breaks([1 n+1]+pad);
				G.CurDir = 1;
				G.Bump = 0;
				Method=GetMethod(Breaks);
				ud=G.Data(:,G.TickOrder(mod1(ext,n)))';
				if G.Unwrap
					ud=180/pi*unwrap(pi/180*ud);
					end
				[G.PP,G.NanMask]=myinterp1pp(Breaks,ud,Method);
			end
		warning(ws);
		end

	function AdjustFrequency
	% Calculate the timer period and the number of frames in the animation.
	% These can change while the timer is running, so, to keep the animation
	% as smooth as possible, we try to restart the animation at the same
	% Time as the present.

	
		% Two functions involved in setting the timer on the fly
		function TimerUpdate(varargin)
			set(G.hTimer ...
				, 'StopFcn', G.StopFcn ...
				, 'StartFcn', @TimerRestoreUser ...
				, 'Period', G.Period);
			start(G.hTimer);
			end

		function TimerRestoreUser(varargin)
			set(G.hTimer, 'StartFcn', G.StartFcn);
			end

		SaveTime=Time;

		% Calculate the period and number of frames with reasonable
		% accuracy. The timer can not handle periods and/or fractions less
		% than 1 ms.

		G.Period= round(max(1,1000/G.Frequency))/1000;
		G.Frames=ceil(G.Duration * G.Frequency);

		if ~isempty(G.hTimer) && onoff(get(G.hTimer, 'Running'))
			% Change period on the fly. Involves some convolved settings of
			% StopFcn and StartFcn ...
			set(G.hTimer, 'StopFcn', @TimerUpdate)
			stop(G.hTimer);
			end
		% Try to go back to the good old Time
		Time(SaveTime);
		end

	%======================================================================
	%- Timer callback -----------------------------------------------------
	%======================================================================

	function TimerFcn(varargin)
	% Encapsulate the action to get a chance to display a decent error
	% message.

		try
			InnerTimerFcn(varargin{:});
		catch
			% Don't show any error messages if we're going south
			if ~G.Panic
				disperror;
				rethrow(lasterror);
				end
			end
		end

	function InnerTimerFcn(varargin)
	% This function is called for every timer tick
	% 1) We evaluate the callback at a certain calculated time
	% 2) We determine if we are back at the first point or down at the last
	% 3) Depending on the run mode, we go forwards, backwards or stop

		function StopIfNoLoop
			if ~G.Loop, InternalStop; end
			end

		EvalAt(Frame2Time(G.Frame));
		
		% It may seem funny that the test for UpAtFirst stops before
		% actually reaching the first frame. The reason is that with
		% 'pingpong' we want all frames to render twice, except the first
		% and the last.

		UpAtFirst = G.CurDir<0 && G.Frame <= 2;
		DownAtLast = G.CurDir>0 && G.Frame >= G.Frames;

		if  UpAtFirst || DownAtLast
			switch G.RunMode
				case {'forward', 'circle'}
					G.Frame=1;
					StopIfNoLoop;
				case 'pingpong'
					G.CurDir=-G.CurDir;
					if UpAtFirst
						G.Frame = 1;
						StopIfNoLoop;
					else
						G.Frame=G.Frame+G.CurDir;
						end
				end
		else
			G.Frame=min(G.Frames, max(1,(G.Frame+G.CurDir)));
			end
		end

	function EvalAt(t)
	% Evaluate the piecewise polynomial at the specified time and call the
	% given callback
		if isempty(G.PP)
			v=[];
		else
			v=ppval(G.PP,t)';
			if ~isempty(G.NanMask)
				v(G.NanMask)=NaN;
				end
			end
		switch nargin(G.TimeSliceFcn)
			case 0
				% Wonder why he uses this timeslice function with no data,
				% but give what he's (not) asking for.
				G.TimeSliceFcn();
			case 1
				G.TimeSliceFcn(v);
			otherwise
				G.TimeSliceFcn(v,t);
			end
		end

	function InternalStop
	% Stop the current animation
		if ~isempty(G.hTimer)
			stop(G.hTimer);
			delete(G.hTimer);
			G.hTimer = [];
			end
		G.IsPlaying = false;
		end

	%======================================================================
	%- Read/Write Property callbacks --------------------------------------
	%======================================================================

	function z=TimeSliceFcn(x)
		if nargin<1
			z=G.TimeSliceFcn;
		else
			if ~isa(x, 'function_handle')
				error('timeslice:IllPar', 'Invalid function handle');
				end
			G.TimeSliceFcn=x;
			end
		end

	function z=Data(x,tick)
		% Get/Set Data to interpolate
		% Data is a 2D numeric array, one column for each break
		% Tick is a vector holding the relative time for each break. If
		% tick is empty, the relative distance in time is supposed to be 1.
		% If length of tick is one more than the number of breaks, the
		% last tick is associated with the first break, in case of circular
		% animation. I.e. we are using the last tick to get the distance in
		% time between the last data column and the first data column.
		% If tick is empty and circular animation is active, the distance
		% between the last tick and the first is also 1.

		if nargin<1
			z=G.Data;
		else
			if ndims(x)>2 || isscalar(x) % || ~(isa(x, 'double') || isa(x, 'single'))
				error(ILLPAR, 'Data must be 2D double data');
				end
			if isscalar(x)
				error(ILLPAR, 'Data can not be scalar');
				end
			if isvector(x)
				x=x(:)';
				end
			G.Data=x;
			if nargin==2 && ~isempty(tick)
				if     ~isvector(tick) ...
					|| ~isnumeric(tick) ...
					|| ~ismember(length(tick),size(G.Data,2)+[0 1])
					error(ILLPAR, 'Ticks not compatible with data');
					end
				G.TTick = [tick repmat(nan, 1, length(tick) == size(G.Data,2))];
				G.CanCircle = ~isnan(G.TTick(end));
				G.IsPseudoTime = false;
			else
				G.TTick=1:size(G.Data,2)+1;
				G.CanCircle = true;
				G.IsPseudoTime = true;
				end
			if ~ismember(length(G.TickOrder),size(G.Data,2)+[0 1])
				G.TickOrder=1:size(G.Data,2);
				end
			if ~G.CanCircle && G.Circling
				RunMode('pingpong');
				end
			NewPP;
			end
		end

	function z=TTick
		% External TTick is not necessarily the same as the internal
		if G.CanCircle
			z=1:length(G.TickOrder);
		else
			z=G.TTick(G.TickOrder);
			end
		end

	function z=TickOrder(to)
	% Get/Set TickOrder. The new TickOrder 
		if nargin<1
			z=G.TickOrder;
		else
			ILLID='timeslice:TickOrder:InvalidOrder';
			if length(to)<2
				error(ILLID, 'Must have at least two ticks');
				end
			if ~all(ismember(to,1:size(G.Data,2)))
				error(ILLID, 'Invalid time tick order');
				end
			if ~G.IsPseudoTime && any(diff(to)<1)
				error(ILLID, 'Ticks must be increasing for real time ticks');
				end
			if G.IsPseudoTime
				% User might have changed the numberof breaks. We try to
				% keep the apparent speed constant.
				Duration(G.Duration*length(to)/length(G.TickOrder));
				end
			G.TickOrder=to;
			NewPP;
			end
		end

	function z=Frequency(x)
		if nargin<1
			z=1/G.Period;
		else
			G.Frequency=x;
			AdjustFrequency;
			end
		end

	function z=Duration(x)
		if nargin<1
			z=G.Duration;
		else
			G.Duration=x;
			AdjustFrequency;
			end
		end

	function z=RunMode(x)
		if nargin<1
			z=G.RunMode;
		else
			rm=partialmatch(x,{'forward','circle','pingpong'});
			if isempty(rm)
				error('timeslice:IllegalRunMode', 'No such runmode');
			elseif strcmp(rm, 'circle') && ~G.CanCircle
				error('timeslice:CanNotCircle', 'Can not circle. Add one more TTick.');
				end
			G.Circling = strcmp(rm, 'circle');
			if ~strcmp(G.RunMode, rm)
				G.RunMode = rm;
				NewPP;
				end
			end
		end

	function z=CanCircle
		z=G.CanCircle;
		end

	function z=Method(x)
		if nargin<1
			z=G.Method;
		else
			% Let interp1 do the error checking to allow for
			% new interpolation methods
			try
				interp1([0 1],[0 1],.5,x);
			catch
				error(ILLPAR, 'Invalid Method');
				end
			if ~strcmp(G.Method, x)
				G.Method = x;
				NewPP;
				end
			end
		end

	function z=Loop(x)
		if nargin<1
			z=G.Loop;
		else
			if isequal(x,0) || isequal(x,1)
				x=logical(x);
			elseif ~isscalar(x) || ~islogical(x)
				error(ILLPAR, 'Loop parameter must be a scalar logical');
				end
			G.Loop=x;
			end
		end

	function z=Unwrap(x)
		if nargin<1
			z=G.Unwrap;
		else
			if isequal(x,0) || isequal(x,1)
				x=logical(x);
			elseif ~isscalar(x) || ~islogical(x)
				error(ILLPAR, 'Unwrap parameter must be a scalar logical');
				end
			G.Unwrap=x;
			end
		end

	function z=StartFcn(x)
	% Set or return the Start callback function.
		if nargin<1
			z=G.StartFcn;
		else
			if ~isa(x, 'function_handle')
				error(ILLPAR, 'Invalid function handle');
				end
			G.StartFcn=x;
			end
		end

	function z=StopFcn(x)
	% Set or return the Stop callback function.
		if nargin<1
			z=G.StopFcn;
		else
			if ~isa(x, 'function_handle')
				error(ILLPAR, 'Invalid function handle');
				end
			G.StopFcn=x;
			end
		end

	function z=Time(x)
	% Set or return simulated time.
		if nargin<1
			z=Frame2Time(G.Frame);
		else
			Frame(Time2Frame(x));
			end
		end

	function z=Frame(x)
	% Set or return current frame number.
		if nargin<1
			z=G.Frame;
		else
			G.Frame = max(1,min(G.Frames,x));
			EvalAt(Frame2Time(G.Frame));
			end
		end

	%======================================================================
	%- Read Only Property callbacks --------------------------------------
	%======================================================================

	function z=Frames
		z=G.Frames;
		end

	function z=IsPlaying
		z=G.IsPlaying;
		end

	%======================================================================
	%- Method callbacks ---------------------------------------------------
	%======================================================================

	function Play
	% Play the animation. Create a unique timer, set it up and let go
	
		nTimer=1;
		timerExists = true;
		% Find a unique timer name
		while timerExists
			TimerName=sprintf('JWTimeSlice-%d', nTimer);
			timerExists=~isempty(timerfind('Name', TimerName));
			nTimer=nTimer+1;
			end

		G.hTimer = timer( ...
				  'Name', TimerName ...
				, 'StartDelay', 0 ...
				, 'BusyMode', 'drop' ...
				, 'ExecutionMode', 'fixedRate' ...
				, 'TasksToExecute', Inf ...
				, 'TimerFcn', @TimerFcn ... 
				, 'Period', G.Period ...
				, 'StartFcn', G.StartFcn ...
				, 'StopFcn', G.StopFcn ...
				);
		G.IsPlaying = true;
		start(G.hTimer);
		end

	function Stop(Reason)
	% The complement to Play. Stops a running timer animation
	% If Panic, we 

		if nargin<1
			G.Panic = false;
		elseif strcmp(Reason, 'panic')
			G.Panic = true;
		else
			error('timeslice:stop:IllPar', 'Illegal parameter');
			end
		InternalStop;
		end

	function PlaySequence(collectFun)
	% This function steps through the animation step by step, honoring
	% RunMode, but not Loop, settings. It runs as fast as it can with no
	% timer involved and calls COLLECTFUN to signal that there is updated
	% data to be collected.

		if nargin < 1; collectFun = []; end
		% Start the animation from the beginning
		G.CurDir = 1;
		G.Frame = 1;
		G.IsPlaying = true;
		SaveLoop = G.Loop;
		try
			G.Loop = false;
			while G.IsPlaying
				TimerFcn;
				if ~isempty(collectFun)
					G.IsPlaying = G.IsPlaying && collectFun();
					end
				end
			G.Loop = SaveLoop;
		catch
			G.Loop = SaveLoop;
			end
		end


	%======================================================================
	%- Helper functions, nested because we want to use ILLPAR -------------
	%======================================================================

	function ProcessNamedParameters(setfuns, vargin)
	% Handle the named parameters. If a name exists among the fields in
	% SETFUNS, the corresponding function is called with the parameter's
	% value. It is up to the called function to do error checking.

		narg=length(vargin);
		if mod(narg,2)==1 || ~all(cellfun(@ischar,vargin(1:2:end)))
			error(ILLPAR, 'Named argument pairs must come in PAIRS');
			end

		validFields=fieldnames(setfuns);
		for i=1:2:narg-1
			field=partialmatch(vargin{i}, validFields);
			if isempty(field)
				error(ILLPAR, 'Invalid named argument');
				end
			% Do error checking and set value
			setfuns.(field)(vargin{i+1});	
			end
		end

	%======================================================================
	%- Main function ------------------------------------------------------
	%======================================================================

	ILLPAR='timeslice:IllPar';

	% The struct below holds "global" data that needs to be kept between
	% timer ticks.

	G=struct( ...
		...
		... % The first part of G has it's counterpart in ts below. They can
		... % be set by caller at initialization time. Semi-constant.
		...
		  'TimeSliceFcn'	, [] ...			% User function to be called every timer tick
		, 'Data'			, [] ...			% User supplied data to be interpolated
		, 'TTick'			, [] ...			% User supplied time ticks.
		, 'TickOrder'		, [] ...			% Order of ticks if in pseudo time.
		...										% If not, holds enabled ticks.
		, 'Frequency'		, 4 ...				% Frames per second
		, 'Duration'		, 3 ...				% Real duration of animation
		, 'RunMode'			, 'pingpong' ...	% circle | forward | {pingpong}
		, 'Method'			, 'linear' ...		% {linear} | spline | pchip
		, 'Loop'			, false ...			% True if "infinite" loop wanted
		, 'StartFcn'		, [] ...			% User supplied function called when timer starts
		, 'StopFcn'			, [] ...			% User supplied function called when timer stops
		, 'Unwrap'			, false ...			% Unwrap (hopefully) angular data
		...
		... % Variables that actively changes during animation.
		...
		, 'Frame'			, 1 ...				% Current frame number
		, 'CurDir'			, 1 ...				% Current direction
		, 'PP'				, [] ...			% pp-struct for interpolation
		, 'NanMask'			, [] ...			% Set these to nan
		, 'IsPlaying'		, false ...			% Set if animation is active
		, 'hTimer'			, [] ...			% Handle to the timer
		, 'Panic'			, false ...			% Set if figure is deleting when stopping
		...
		... % Convenience variables.
		...
		, 'Period'			, [] ...			% Basically 1/Frequency
		, 'CanCircle'		, true ...			% true if length(TTick) = length(Data)+1
		, 'Frames'			, 13 ...			% Basically 'Frequency' * 'Duration' + 1
		, 'Range'			, [0 1] ...			% TTick([1 end]) or TTick([1 end-1])
		, 'Circling'		, false ...			% =strcmp(G.RunMode, 'circle')
		, 'Bump'			, 0 ...				% 0 if G.Circling, Time correction otherwise
		);

	% These functions are callable after timeslice returns.
	% They also double as parameter names, and are called for each
	% set parameter. When input parsing is finished, functions
	% needed at runtime are added.

	ts=struct( ...
		  'Frequency'	, @Frequency ...		% Frames per second
		, 'Duration'	, @Duration ...			% Real duration of animation
		, 'RunMode'		, @RunMode ...			% circle | forward | {pingpong}
		, 'Method'		, @Method ...			% {linear} | spline | pchip
		, 'Loop'		, @Loop ...				% True if "infinite" loop wanted
		, 'StartFcn'	, @StartFcn ...			% User supplied function called when timer starts
		, 'StopFcn'		, @StopFcn ...			% User supplied function called when timer stops
		, 'Unwrap'		, @Unwrap ...			% Unwrap (hopefully) angular data
		);

	% Make sure number of frames is set correctly

	G.Period=round(max(1,1000/G.Frequency))/1000;
	G.Frames=ceil(G.Duration * G.Frequency);

	% Process user parameters

	error(nargchk(2,inf,nargin, 'struct'));
	TimeSliceFcn(OrgFun);
	[OrgTTick,vargin]=parseparams(varargin);
	Data(OrgData,OrgTTick{:});
	ProcessNamedParameters(ts, vargin);

	% Add runtime properties and methods

	ts.TimeSliceFcn	= @TimeSliceFcn; 		% User function to be called every timer tick
	ts.Data			= @Data;				% User supplied data to be interpolated
	ts.TTick		= @TTick;				% User supplied time ticks. Read only.
	ts.Time			= @Time;				% Get/Set current animated time
	ts.Frame		= @Frame;				% Get/Set current frame. NB: Can be fractional
	ts.Frames		= @Frames;				% Get total number of frames in animation
	ts.IsPlaying	= @IsPlaying;			% Get status of animation
	ts.CanCircle	= @CanCircle;			% Can we run in circle mode ?

	ts.Play	= @Play;
	ts.Stop	= @Stop;
	ts.PlaySequence = @PlaySequence;
	ts.TickOrder = @TickOrder;
	end
% File: unchaincallback.m ######################################################################
function unchaincallback(h, type, Id)
%UNCHAINCALLBACK Restore calback function
%   output = unchaincallback(input)
%
%   Example
%      unchaincallback
%
%   See also: CHAINCALLBACK

% Author:  Jerker W�gberg
% Created: 2006-10-09
% Copyright � 2006 More Research.

	if nargin<3; Id=[]; end
	type = lower(type);
	for i=1:numel(h)
		if isempty(Id)
			chainlist('rm', h(i), type);
		else
			chainlist('rm', h(i), type, Id(i));
			end
		end
	end

