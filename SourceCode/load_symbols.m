function load_symbols(get_userinput)
% - Opens the symbol parameters file (Excel)
% - loads all symbol bitmaps into the workspace
% - converts all symbol bitmaps to polygons
% - saves the symbol polygons als mat-file for faster loading
% The columns in the symbol parameter file are assigned to the global variable SY:
% SY(isym,1).k        = KEY
% SY(isym,1).v        = VALUE
% SY(isym,1).fn       = FILENAME
% SY(isym,1).dpi      = DPI
% SY(isym,1).dimx     = DIMX
% SY(isym,1).dimy     = DIMY
% SY(isym,1).diag     = DIAG
% SY(isym,1).dmin     = DISTNODESMIN
% SY(isym,1).poly_sym = poylgon object of the symbol foreground (symbol sketch)
% SY(isym,1).poly_bgd = poylgon object of the symbol background (footprint, overall outline)

global SY GV GV_H APP

try

	% Display state:
	t_start_statebusy	= clock;
	display_on_gui('state','Loading symbols ...','busy','add');

	if nargin==0
		get_userinput_file	= 0;
		get_userinput_dir		= 0;
	else
		get_userinput_file	=	get_userinput;
		get_userinput_dir		=	get_userinput;
	end

	%------------------------------------------------------------------------------------------------------------------
	% Get filename:
	if isempty(GV)
		% GV does not yet exist:
		get_userinput_file	= 1;
		[symbols_pathname,~,~]			= fileparts(mfilename('fullpath'));
	else
		% GV already exists:
		if ~isfield(GV,'symbols_pathfilename')
			get_userinput_file	= 1;
			[symbols_pathname,~,~]		= fileparts(mfilename('fullpath'));
		else
			symbols_pathname				= GV.symbols_pathfilename;
		end
	end
	if isnumeric(symbols_pathname)
		get_userinput_file	= 1;
		[symbols_pathname,~,~]		= fileparts(mfilename('fullpath'));
	else
		if exist(symbols_pathname,'file')~=2
			% The file does not exist:
			get_userinput_file		= 1;
			[symbols_pathname,~,~]		= fileparts(mfilename('fullpath'));
		end
	end

	% Ask for the symbol parameter file:
	if get_userinput_file~=0
		figure(APP.MapLab3D);	% This is a test to prevent the uiget window from being opened behind another window.
		[symbols_filename,symbols_pathname]	= ...
			uigetfile_local('*.*','Select the symbol parameters file',symbols_pathname);
		figure(APP.MapLab3D);	% This brings the app figure to the foreground.
		% If the user clicks Cancel or the window close button (X):
		if isequal(symbols_filename,0)||isequal(symbols_pathname,0)
			% Display state:
			display_on_gui('state',...
				sprintf('Loading symbols ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			return
		end
		GV.symbols_pathfilename	= [symbols_pathname symbols_filename];
		% Check the file extension:
		extensions		= {'txt';'dat';'csv';'xls';'xlsb';'xlsm';'xlsx';'xltm';'xltx';'ods'};
		k					= find(symbols_filename=='.');
		file_extension	= symbols_filename((k(end)+1):end);
		wrong_ext		= true;
		for i=1:length(extensions)
			if strcmp(file_extension,extensions{i})
				wrong_ext	= false;
				break;
			end
		end
		if wrong_ext
			GV.symbols_pathfilename	= [];
			errortext	= sprintf([...
				'The file extension .%s is not supported.\n',...
				'Permitted file extensions are:\n.%s'],file_extension,extensions{1});
			for i=2:length(extensions)
				errortext	= sprintf('%s, .%s',errortext,extensions{i});
			end
			errormessage(errortext)
		end
	end

	%------------------------------------------------------------------------------------------------------------------
	% Get symbol directory (location of the symbol bitmaps):
	if isempty(GV)
		% GV does not yet exist:
		get_userinput_dir			=	1;
		[symbolsdirectory,~,~]	= fileparts(mfilename('fullpath'));
	else
		if ~isfield(GV,'symbolsdirectory')
			% The path name has not yet been requested:
			get_userinput_dir			=	1;
			[symbolsdirectory,~,~]	= fileparts(mfilename('fullpath'));
		else
			% The path name has already been requested:
			symbolsdirectory			= GV.symbolsdirectory;
		end
	end
	if isnumeric(symbolsdirectory)
		get_userinput_dir			= 1;
		[symbolsdirectory,~,~]	= fileparts(mfilename('fullpath'));
	else
		if exist(symbolsdirectory,'file')~=7
			% The symbol directory does not exist:
			get_userinput_dir			= 1;
			[symbolsdirectory,~,~]	= fileparts(mfilename('fullpath'));
		end
	end

	% Ask for the symbol directory:
	if get_userinput_dir~=0
		figure(APP.MapLab3D);	% This is a test to prevent the uiget window from being opened behind another window.
		symbolsdirectory		= uigetdir_local(symbolsdirectory,'Select the symbol bitmaps directory');
		figure(APP.MapLab3D);	% This brings the app figure to the foreground.
		if isequal(symbolsdirectory,0)
			% If the user clicks Cancel or the window close button (X):
			if get_userinput_dir==1
				display_on_gui('state',...
					sprintf('Loading symbols ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
					'notbusy','replace');
			end
			return
		end
		if ~strcmp(symbolsdirectory(end),'\')
			symbolsdirectory	= [symbolsdirectory '\'];
		end
		GV.symbolsdirectory	= symbolsdirectory;
	end

	%------------------------------------------------------------------------------------------------------------------
	% Read file:
	try
		% Waitbar:
		if ~isempty(APP)
			set(GV_H.text_waitbar,'String','Loading symbol parameters ...');
			drawnow;
		end
		% Load file:
		opts	= detectImportOptions(GV.symbols_pathfilename,'Sheet','SP');
	catch ME
		errortext	= sprintf('Error when loading the symbol parameters:\n%s',GV.symbols_pathfilename);
		errormessage(errortext,ME);
	end
	for i=1:length(opts.VariableNames)
		if    strcmp(opts.VariableNames{i},'DPI')||...
				strcmp(opts.VariableNames{i},'DIMX')||...
				strcmp(opts.VariableNames{i},'DIMY')||...
				strcmp(opts.VariableNames{i},'DIAG')||...
				strcmp(opts.VariableNames{i},'DISTNODESMIN')||...
				strcmp(opts.VariableNames{i},'XSYM')||...
				strcmp(opts.VariableNames{i},'YSYM')||...
				strcmp(opts.VariableNames{i},'XBGD')||...
				strcmp(opts.VariableNames{i},'YBGD')
			opts.VariableTypes{i}	= 'double';
		else
			opts.VariableTypes{i}	= 'char';
		end
	end
	T_lino_start	= 3;							% Data starts in line number T_lino_start
	opts.DataRange	= sprintf('A%1.0f',T_lino_start);		% 'A3'
	T					= readtable(GV.symbols_pathfilename,opts);

	% Extend the table by one empty row (beacuse of (r>rmax) below):
	rmax				= size(T,1);
	T(rmax+1,:)		= T(rmax,:);
	for i=1:length(opts.VariableNames)
		if isnumeric(T.(opts.VariableNames{i})(end))
			T.(opts.VariableNames{i})(end)	= nan;
		else
			T.(opts.VariableNames{i})(end)	= {''};
		end
	end

	% Assign the table to the structure SY_temp:
	SY_temp			= [];
	dt_update		= 0.5;						% Time between two updates of the waitbar
	t_update			= clock;
	isym				= 0;
	xy_sym			= [];
	xy_bgd			= [];
	for r=1:(rmax+1)

		% Waitbar:
		if etime(clock,t_update)>=dt_update
			t_update	= clock;
			if ~isempty(APP)
				progress		= min(r/rmax,1);
				set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
				drawnow;
			end
		end

		if	   ~isempty(xy_sym)   &&...
				~isempty(xy_bgd)   && (...
				~isempty(T.KEY{r})        ||...
				~isempty(T.VALUE{r})      ||...
				~isnan(T.DIMX(r))         ||...
				~isnan(T.DIMY(r))         ||...
				~isnan(T.DIAG(r))         ||...
				~isempty(T.FILENAME{r})   ||...
				~isnan(T.DPI(r))          ||...
				~isnan(T.DISTNODESMIN(r)) ||...
				(r>rmax)                       )
			%------------------------------------------------------------------------------------------------------------
			% Create the symbol by user-defined vertices:
			if isequal(isnan(xy_sym(:,1)),isnan(xy_sym(:,1)))
				[xdata, ydata] = removeExtraNanSeparators(xy_sym(:,1),xy_sym(:,2));
			end
			SY_temp(isym,1).poly_sym		= polyshape(xdata,ydata);
			if isequal(isnan(xy_bgd(:,1)),isnan(xy_bgd(:,1)))
				[xdata, ydata] = removeExtraNanSeparators(xy_bgd(:,1),xy_bgd(:,2));
			end
			SY_temp(isym,1).poly_bgd		= polyshape(xdata,ydata);
			% The symbol should not overlap the background:
			[  SY_temp(isym,1).poly_bgd]	= union(...
				SY_temp(isym,1).poly_bgd,...
				SY_temp(isym,1).poly_sym);
			% Scaling:
			[  SY_temp(isym,1).poly_sym,...
				SY_temp(isym,1).poly_bgd]	= scaling_local(...
				SY_temp(isym,1),...
				SY_temp(isym,1).poly_sym,...
				SY_temp(isym,1).poly_bgd);
			% Create and save the preview figure:
			preview_local(...
				SY_temp(isym,1),...
				isym,...
				SY_temp(isym,1).poly_sym,...
				SY_temp(isym,1).poly_bgd);
			% Clear the vectors:
			xy_sym	= [];
			xy_bgd	= [];
		end

		if    ~isempty(T.KEY{r})   &&...
				~isempty(T.VALUE{r}) &&...
				~isnan(T.DIMX(r))    &&...
				~isnan(T.DIMY(r))    &&...
				~isnan(T.DIAG(r))
			% Create next symbol:

			if	   ~isempty(T.FILENAME{r})   &&...
					~isnan(T.DPI(r))          &&...
					~isnan(T.DISTNODESMIN(r)) &&...
					isnan(T.XSYM(r))          &&...
					isnan(T.YSYM(r))          &&...
					isnan(T.XBGD(r))          &&...
					isnan(T.YBGD(r))
				%---------------------------------------------------------------------------------------------------------
				% The symbol will be created by loading a user-defined bitmap:
				isym						= isym+1;
				SY_temp(isym,1).k		= T.KEY{r};
				SY_temp(isym,1).v		= T.VALUE{r};
				SY_temp(isym,1).dimx	= T.DIMX(r);
				SY_temp(isym,1).dimy	= T.DIMY(r);
				SY_temp(isym,1).diag	= T.DIAG(r);
				SY_temp(isym,1).fn	= T.FILENAME{r};
				SY_temp(isym,1).dpi	= T.DPI(r);
				SY_temp(isym,1).dmin	= T.DISTNODESMIN(r);
				% Check whether the current bitmap-file has already been loaded before:
				isym_samefilename	= 0;
				for k=(isym-1):-1:1
					if strcmp(SY_temp(k,1).fn,SY_temp(isym,1).fn)
						isym_samefilename	= k;
						break;
					end
				end
				if isym_samefilename>0
					% Assign an already loaded bitmap:
					SY_temp(isym,1).poly_sym		= SY_temp(isym_samefilename,1).poly_sym;
					SY_temp(isym,1).poly_bgd		= SY_temp(isym_samefilename,1).poly_bgd;
				else
					% Load a new bitmap:
					[  SY_temp(isym,1).poly_sym,...
						SY_temp(isym,1).poly_bgd]=load_bitmap_local(...
						SY_temp(isym,1));
					% The symbol should not overlap the background:
					[  SY_temp(isym,1).poly_bgd]	= union(...
						SY_temp(isym,1).poly_bgd,...
						SY_temp(isym,1).poly_sym);
					% Scaling:
					[  SY_temp(isym,1).poly_sym,...
						SY_temp(isym,1).poly_bgd]	= scaling_local(...
						SY_temp(isym,1),...
						SY_temp(isym,1).poly_sym,...
						SY_temp(isym,1).poly_bgd);
					% Create and save the preview figure:
					preview_local(...
						SY_temp(isym,1),...
						isym,...
						SY_temp(isym,1).poly_sym,...
						SY_temp(isym,1).poly_bgd);
				end

			elseif isempty(T.FILENAME{r})  &&...
					isnan(T.DPI(r))          &&...
					isnan(T.DISTNODESMIN(r)) &&...
					~isnan(T.XSYM(r))        &&...
					~isnan(T.YSYM(r))        &&...
					~isnan(T.XBGD(r))        &&...
					~isnan(T.YBGD(r))
				%---------------------------------------------------------------------------------------------------------
				% The symbol will be created by user-defined vertices: Start collecting the values:
				isym						= isym+1;
				SY_temp(isym,1).k		= T.KEY{r};
				SY_temp(isym,1).v		= T.VALUE{r};
				SY_temp(isym,1).fn	= T.FILENAME{r};
				SY_temp(isym,1).dpi	= T.DPI(r);
				SY_temp(isym,1).dimx	= T.DIMX(r);
				SY_temp(isym,1).dimy	= T.DIMY(r);
				SY_temp(isym,1).diag	= T.DIAG(r);
				SY_temp(isym,1).dmin	= T.DISTNODESMIN(r);
				xy_sym					= [T.XSYM(r) T.YSYM(r)];
				xy_bgd					= [T.XBGD(r) T.YBGD(r)];

			else
				%---------------------------------------------------------------------------------------------------------
				% Missing data:
				errortext	= sprintf([...
					'Error when loading the symbol parameters:\n',...
					'%s\n',...
					'\n',...
					'Line number %g:\n',...
					'Key = %s\n',...
					'Value = %s\n',...
					'\n',...
					'You must define either\n',...
					'1) FILENAME and DPI or\n',...
					'2) 4 start values XSYM, YSYM, XBGD, YBGD'],...
					GV.symbols_pathfilename,...
					T_lino_start+r-1,T.KEY{r},T.VALUE{r});
				errormessage(errortext);
			end

		elseif ~isempty(xy_sym)        &&...
				~isempty(xy_bgd)         &&...
				isempty(T.KEY{r})        &&...
				isempty(T.VALUE{r})      &&...
				isnan(T.DIMX(r))         &&...
				isnan(T.DIMY(r))         &&...
				isnan(T.DIAG(r))         &&...
				isempty(T.FILENAME{r})   &&...
				isnan(T.DPI(r))          &&...
				isnan(T.DISTNODESMIN(r))
			%------------------------------------------------------------------------------------------------------------
			% The symbol will be created by user-defined vertices: Continue collecting the values:
			xy_sym	= [xy_sym;T.XSYM(r) T.YSYM(r)];
			xy_bgd	= [xy_bgd;T.XBGD(r) T.YBGD(r)];

		elseif isempty(xy_sym)         &&...
				isempty(xy_bgd)          &&...
				isempty(T.KEY{r})        &&...
				isempty(T.VALUE{r})      &&...
				isnan(T.DIMX(r))         &&...
				isnan(T.DIMY(r))         &&...
				isnan(T.DIAG(r))         &&...
				isempty(T.FILENAME{r})   &&...
				isnan(T.DPI(r))          &&...
				isnan(T.DISTNODESMIN(r)) &&...
				isnan(T.XSYM(r))         &&...
				isnan(T.YSYM(r))         &&...
				isnan(T.XBGD(r))         &&...
				isnan(T.YBGD(r))
			%------------------------------------------------------------------------------------------------------------
			% Empty line: do nothing

		else
			%------------------------------------------------------------------------------------------------------------
			% Incorrect data:
			errortext	= sprintf([...
				'Error when loading the symbol parameters:\n',...
				'%s\n',...
				'\n',...
				'Incorrect data in line number %g.'],...
				GV.symbols_pathfilename,...
				T_lino_start+r-1);
			errormessage(errortext);
		end

	end

	% If there was no error up to this point:
	% Assign and save the structure SY:
	SY								= SY_temp;
	[symbols_pathname,~,~]	= fileparts(mfilename('fullpath'));
	save([symbols_pathname '\symbols.mat'],'SY');

	% Reset waitbar:
	if ~isempty(APP)
		set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
		set(GV_H.text_waitbar,'String','');
		drawnow;
	end

	% Display state:
	display_on_gui('state',...
		sprintf('Loading symbols ... done (%s).',dt_string(etime(clock,t_start_statebusy))),...
		'notbusy','replace');

catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
function [poly_sym,poly_bgd]=load_bitmap_local(SY_temp_isym)
% Load a new bitmap:

global GV

try

	% Testplot:
	testplot					= 0;
	testplot_image2poly	= 0;

	% Check whether the picture exists:
	image_fn					= [GV.symbolsdirectory SY_temp_isym.fn];
	if exist(image_fn,'file')~=2
		errortext	= sprintf([...
			'Error when loading symbols:\n',...
			'The file\n',...
			'%s\n',...
			'does not exist in the directory\n',...
			'%s'],SY_temp_isym.fn,GV.symbolsdirectory);
		errormessage(errortext);
	end
	% Check whether the picture is a true color image:
	info						= imfinfo(image_fn);
	if ~isequal(info.BitDepth,24)||~strcmp(info.ColorType,'truecolor')
		errortext	= sprintf([...
			'Error when loading symbols:\n',...
			'The file\n',...
			'%s\n',...
			'is not a 24Bit true color picture:\n',...
			'ColorType: %s\n',...
			'BitDepth: %g'],SY_temp_isym.fn,info.ColorType,info.BitDepth);
		errormessage(errortext);
	end

	% Read the image and convert it to:
	% RGB:		Color of the pixels:						black	white	red	green	blue	yllw	mag	cyan
	%				red:		obj_image_rgb(x,y,1) =		0		255	255	0		0		255	255	0
	%				green:	obj_image_rgb(x,y,2) =		0		255	0		255	0		255	0		255
	%				blue		obj_image_rgb(x,y,3) =		0		255	0		0		255	0		255	255
	% Binary:													0		1
	image_rgb		= imread(image_fn);
	image_sym		= imbinarize(image_rgb(:,:,1),graythresh(image_rgb(:,:,1)));	% symbol:  only yellow
	image_bgd		= imbinarize(image_rgb(:,:,2),graythresh(image_rgb(:,:,2)));	% backgrd: green and yellow
	nx					= size(image_rgb,2);
	ny					= size(image_rgb,1);
	h_image_inch	= ny/SY_temp_isym.dpi;		% inch
	w_image_inch	= nx/SY_temp_isym.dpi;		% inch
	h_image			= h_image_inch*25.4;				% mm
	w_image			= w_image_inch*25.4;				% mm
	dxy_pixel		= w_image/nx;

	% Convert the images to polygons:
	[~,...							% poly_bgd
		poly_sym] = ...			% poly_obj
		image2poly(...
		~image_sym,...				% obj_image
		h_image,...					% height_image
		0,...							% rotation
		[],...						% obj_extent
		1,...							% no_frame: 1 = no frame
		{},...						% par_frame
		1,...							% no_bgd: 1 = no background
		{},...						% par_bgd
		testplot_image2poly);	% testplot
	[~,...							% poly_bgd
		poly_bgd] = ...			% poly_obj
		image2poly(...
		~image_bgd,...				% obj_image
		h_image,...					% height_image
		0,...							% rotation
		[],...						% obj_extent
		1,...							% no_frame: 1 = no frame
		{},...						% par_frame
		1,...							% no_bgd: 1 = no background
		{},...						% par_bgd
		testplot_image2poly);	% testplot

	% Change resolution: This will possibly reduce the number of nodes.
	if SY_temp_isym.dmin>0
		poly_sym	= changeresolution_poly(poly_sym,[],SY_temp_isym.dmin,[]);
		poly_bgd	= changeresolution_poly(poly_bgd,[],SY_temp_isym.dmin,[]);
	end

	% Reduce the size of the background by one pixel: This possibly will reduce the number of nodes.
	poly_bgd	= polybuffer(poly_bgd,-dxy_pixel,'JointType','miter','MiterLimit',2);

	% Testplot:
	if testplot==1
		[xlim,ylim] = boundingbox(poly_bgd);
		xmin			= xlim(1);
		ymin			= ylim(1);
		xmax			= xlim(2);
		ymax			= ylim(2);
		hf_testplot	= figure(948264869);
		figure_theme(hf_testplot,'set',[],'light');
		clf(hf_testplot,'reset');
		figure_theme(hf_testplot,'set',[],'light');
		set(hf_testplot,'Tag','maplab3d_figure');
		% Axis 1: original colors:
		ha_testplot(1,1)	= subplot(3,1,1);
		image(ha_testplot(1,1),image_rgb);
		map(1,:)	= [1 1 1]*0.0;				% objects
		map(2,:)	= [1 1 1];					% background (white)
		colormap(hf_testplot,map);
		title(ha_testplot(1,1),SY_temp_isym.fn,'Interpreter','none');
		set(ha_testplot(1,1),'XLim',[1 nx]);
		set(ha_testplot(1,1),'YLim',[1 ny]);
		% Axis 1: symbol:
		ha_testplot(2,1)	= subplot(3,1,2);
		image(ha_testplot(2,1),...
			[-1,1]*w_image/2,...
			[-1,1]*h_image/2,...
			~image_sym(end:-1:1,:),...
			'CDataMapping','scaled');
		hold(ha_testplot(2,1),'on');
		plot(ha_testplot(2,1),poly_sym.Vertices(:,1),poly_sym.Vertices(:,2),...
			'Color','r','Marker','.','MarkerSize',15);
		title(ha_testplot(2,1),'symbol');
		set(ha_testplot(2,1),'XLim',[xmin,xmax]*w_image/(xmax-xmin));
		set(ha_testplot(2,1),'YLim',[ymin,ymax]*h_image/(ymax-ymin));
		set(ha_testplot(2,1),'YDir','normal');
		% Axis 1: background:
		ha_testplot(3,1)	= subplot(3,1,3);
		image(ha_testplot(3,1),...
			[-1,1]*w_image/2,...
			[-1,1]*h_image/2,...
			~image_bgd(end:-1:1,:),...
			'CDataMapping','scaled');
		hold(ha_testplot(3,1),'on');
		plot(ha_testplot(3,1),poly_bgd.Vertices(:,1),poly_bgd.Vertices(:,2),...
			'Color','r','Marker','.','MarkerSize',15);
		title(ha_testplot(3,1),'background');
		set(ha_testplot(3,1),'XLim',[xmin,xmax]*w_image/(xmax-xmin));
		set(ha_testplot(3,1),'YLim',[ymin,ymax]*h_image/(ymax-ymin));
		set(ha_testplot(3,1),'YDir','normal');
		% Formatting:
		set(ha_testplot,'Clipping','off');
		axis(ha_testplot,'equal');
	end

catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
function preview_local(SY_temp_isym,isym,poly_sym,poly_bgd)
% Create and save the preview figure:

global GV

try

	if isym==18
		setbreakpoint=1;
	end

	[xlim,ylim] = boundingbox(poly_bgd);
	xmin			= xlim(1);
	ymin			= ylim(1);
	xmax			= xlim(2);
	ymax			= ylim(2);

	% Create the preview figure:
	symbol_preview_userdata	= 'opensymbols_symbolpreviewuserdata';
	hf_symbol_preview	= findobj('UserData',symbol_preview_userdata);
	if isempty(hf_symbol_preview)
		hf_symbol_preview	= figure;
		figure_theme(hf_symbol_preview,'set',[],'light');
	end
	hf_symbol_preview	= hf_symbol_preview(1);

	figure(hf_symbol_preview);
	clf(hf_symbol_preview,'reset');
	figure_theme(hf_symbol_preview,'set',[],'light');
	set(hf_symbol_preview,'Tag','maplab3d_figure');
	set(hf_symbol_preview,'NumberTitle','off');
	set(hf_symbol_preview,'UserData',symbol_preview_userdata);
	set(hf_symbol_preview,'Name','Symbol preview');
	pos		= get(hf_symbol_preview,'Position');
	pos(1)	= max(pos(1),1);
	pos(2)	= max(pos(2),1);
	pos(3)	= 560;	% standard figure width
	pos(4)	= 420;	% standard figure height
	set(hf_symbol_preview,'Position',pos);
	set(hf_symbol_preview,'PaperOrientation','portrait');
	set(hf_symbol_preview,'PaperPositionMode','auto');
	ha_symbol_preview	= axes(hf_symbol_preview);
	hold(ha_symbol_preview,'on');
	hpoly(1)=plot(ha_symbol_preview,poly_sym,'FaceColor','y');
	hpoly(2)=plot(ha_symbol_preview,subtract(poly_bgd,poly_sym),'FaceColor','g');
	plot(ha_symbol_preview,poly_bgd.Vertices(:,1),poly_bgd.Vertices(:,2),...
		'Color','k','Marker','.','MarkerSize',6);
	plot(ha_symbol_preview,poly_sym.Vertices(:,1),poly_sym.Vertices(:,2),...
		'Color','k','Marker','.','MarkerSize',6);
	set(ha_symbol_preview,'XLim',[xmin,xmax]+[-1 1]*(xmax-xmin)*0.05);
	set(ha_symbol_preview,'YLim',[ymin,ymax]+[-1 1]*(ymax-ymin)*0.05);
	set(ha_symbol_preview,'Clipping','off');
	set(ha_symbol_preview,'Box','on');
	axis(ha_symbol_preview,'equal');
	xcenter		= (xmin+xmax)/2;
	ycenter		= (ymin+ymax)/2;
	xlimits		= ha_symbol_preview.XLim;
	ylimits		= ha_symbol_preview.YLim;
	ha_symbol_preview.XLim	= [ha_symbol_preview.XLim]+xcenter-mean(xlimits);
	ha_symbol_preview.YLim	= [ha_symbol_preview.YLim]+ycenter-mean(ylimits);
	nodes_sym	= unique(round(poly_sym.Vertices(:,1)+1i*poly_sym.Vertices(:,2),6));
	nodes_bgd	= unique(round(poly_bgd.Vertices(:,1)+1i*poly_bgd.Vertices(:,2),6));
	nodes_sym	= nodes_sym(~isnan(nodes_sym));
	nodes_bgd	= nodes_bgd(~isnan(nodes_bgd));
	if ~isnan(SY_temp_isym.dpi)&&~isnan(SY_temp_isym.dmin)
		dpidmin_str	= sprintf(', DPI=%1.0f, DISTNODESMIN=%gmm',SY_temp_isym.dpi,SY_temp_isym.dmin);
	else
		dpidmin_str	= '';
	end
	title(ha_symbol_preview,...
		sprintf([...
		'Symbol %g\n',...
		'key: %s\n',...
		'value: %s\n',...
		'xmin=%1.1fmm, xmax=%1.1fmm, xmax-xmin=%1.1fmm\n',...
		'ymin=%1.1fmm, ymax=%1.1fmm, ymax-ymin=%1.1fmm\n',...
		'diagonal=%1.1fmm%s\n',...
		'number of nodes =%1.0f'],...
		isym,SY_temp_isym.k,SY_temp_isym.v,...
		xmin,xmax,xmax-xmin,ymin,ymax,ymax-ymin,...
		sqrt((xmax-xmin)^2+(ymax-ymin)^2),dpidmin_str,...
		length(nodes_sym)+length(nodes_bgd)),...
		'Interpreter','none');
	xlabel(ha_symbol_preview,'x / mm');
	ylabel(ha_symbol_preview,'y / mm');
	grid(ha_symbol_preview,'on');
	legend(ha_symbol_preview,hpoly,'symbol foreground','symbol background');

	% Create the directory symbolsdirectory_results:
	symbolsdirectory_results	= [GV.symbolsdirectory 'Preview\'];
	if exist(symbolsdirectory_results,'dir')~=7
		[status,msg] = mkdir(symbolsdirectory_results);
		if status~=1
			errortext	= sprintf([...
				'Error when creating the directory:\n',...
				'%s\n',...
				'\n',...
				'%s'],symbolsdirectory_results,msg);
			errormessage(errortext);
		end
	end

	% Delete an existing preview in symbolsdirectory_results:
	nmax_kvstr	= 50;		% max. length of key and value strings in the filename
	keystr		= validfilename(SY_temp_isym.k);
	keystr(strfind(keystr,'_'))		= '';
	keystr(strfind(keystr,'-'))		= '';
	keystr(strfind(keystr,' '))		= '';
	if isempty(keystr)
		keystr	= 'x';
	elseif length(keystr)>nmax_kvstr
		keystr	= keystr(1:nmax_kvstr);
	end
	valuestr		= validfilename(SY_temp_isym.v);
	valuestr(strfind(valuestr,'_'))	= '';
	valuestr(strfind(valuestr,'-'))	= '';
	valuestr(strfind(valuestr,' '))	= '';
	if isempty(valuestr)
		valuestr	= 'x';
	elseif length(valuestr)>nmax_kvstr
		valuestr	= valuestr(1:nmax_kvstr);
	end
	filename_preview	= sprintf('S%1.0f_K_%s_V_%s',isym,keystr,valuestr);
	filename_preview=validfilename(filename_preview);
	listing = dir(symbolsdirectory_results);
	for k=1:length(listing)
		if (listing(k).isdir==0)&&strcmp(listing(k).name,[filename_preview '.jpg'])
			delete([symbolsdirectory_results listing(k).name]);
		end
	end

	% Save the symbol preview:
	drawnow;		% First finish plotting
	print(hf_symbol_preview,'-r150','-djpeg',[symbolsdirectory_results filename_preview]);

catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
function [poly_sym,poly_bgd]=scaling_local(SY_temp_isym,poly_sym,poly_bgd)

global GV

try

	% The symbol must not be empty:
	if numboundaries(poly_sym)==0
		errortext	= sprintf([...
			'Error when loading the symbol parameters:\n',...
			'%s\n',...
			'\n',...
			'Key = %s\n',...
			'Value = %s\n',...
			'\n',...
			'The symbol foreground is empty!'],...
			GV.symbols_pathfilename,...
			SY_temp_isym.k,SY_temp_isym.v);
		errormessage(errortext);
	end
	if numboundaries(poly_bgd)==0
		errortext	= sprintf([...
			'Error when loading the symbol parameters:\n',...
			'%s\n',...
			'\n',...
			'Key = %s\n',...
			'Value = %s\n',...
			'\n',...
			'The symbol background is empty!'],...
			GV.symbols_pathfilename,...
			SY_temp_isym.k,SY_temp_isym.v);
		errormessage(errortext);
	end

	% Scaling:
	[xlim,ylim] = boundingbox(poly_bgd);
	xmin			= xlim(1);
	ymin			= ylim(1);
	xmax			= xlim(2);
	ymax			= ylim(2);
	if SY_temp_isym.dimx~=0
		K	= SY_temp_isym.dimx/(xmax-xmin);
	elseif SY_temp_isym.dimy~=0
		K	= SY_temp_isym.dimy/(ymax-ymin);
	elseif SY_temp_isym.diag~=0
		K	= SY_temp_isym.diag/sqrt((xmax-xmin)^2+(ymax-ymin)^2);
	else
		K	= 1;
	end
	if K~=1
		poly_sym = scale(poly_sym,K);
		poly_bgd = scale(poly_bgd,K);
	end

catch ME
	errormessage('',ME);
end

