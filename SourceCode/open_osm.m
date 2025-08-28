function open_osm
% - Ask path and filename of the OSM-file
% - Ask path of the elevation-files
% - Load elevation data
% - Load OSM data or only OSM limits
% - Assign elevation data
% - Edit OSM data: nodes
% - Edit OSM data: ways
% - Edit OSM data: relations
% - Indexing keys and values
% - Sort the tags by the number of their appearance
% - Open or clear map figure

global APP PP OSMDATA ELE GV GV_H WAITBAR SETTINGS

try
	
	testplot			= 0;
	
	% Initializations:
	sort_the_tags	= false;		% sort the tags by the number of their appearance (takes much time): true/false
	
	%------------------------------------------------------------------------------------------------------------------
	% Display state
	%------------------------------------------------------------------------------------------------------------------
	t_start_statebusy	= clock;
	display_on_gui('state','Load OSM and elevation data ...','busy','add');
	
	
	%---------------------------------------------------------------------------------------------------------
	% Ask:	- paths of the OSM- and elevation-files
	%			- OSM-filename
	%---------------------------------------------------------------------------------------------------------
	
	if isempty(PP)
		errortext	= sprintf([...
			'The project parameters have not yet been loaded.\n',...
			'First load the project parameters.']);
		errormessage(errortext);
	end
	
	% Get the OSM data osm_pathname und osm_filename:
	if ~isfield(GV,'osm_pathfilename')
		osm_pathname				= SETTINGS.osm_pathfilename;
	else
		if isempty(GV.osm_pathfilename)
			osm_pathname			= SETTINGS.osm_pathfilename;
		else
			% The OSM data has already been loaded before:
			osm_pathname			= GV.osm_pathfilename;
		end
	end
	if isnumeric(osm_pathname)
		osm_pathname				= SETTINGS.default_pathname;
	else
		if exist(osm_pathname,'file')~=2
			% The file does not exist:
			osm_pathname			= SETTINGS.default_pathname;
		end
	end
	figure(APP.MapLab3D);	% This is a test to prevent the uiget window from being opened behind another window.
	[osm_filename,osm_pathname]	= uigetfile_local({'*.osm'},'Select the OSM data file',osm_pathname);
	figure(APP.MapLab3D);	% This brings the app figure to the foreground.
	if isequal(osm_filename,0)||isequal(osm_pathname,0)
		display_on_gui('state',...
			sprintf('Load OSM and elevation data ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
			'notbusy','replace');
		set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
		set(GV_H.text_waitbar,'String','');
		drawnow;
		return
	end
	% Check the OSM file extension:
	k					= find(osm_filename=='.');
	file_extension	= osm_filename((k(end)+1):end);
	if ~strcmp(file_extension,'osm')
		errortext	= sprintf([...
			'The file extension .%s is not supported.\n',...
			'The permitted file extension is: %s'],file_extension,'.osm');
		errormessage(errortext)
	end
	
	% Get the elevation data pathname:
	if APP.LoadSettingsElevationDataMenu.Checked
		if ~isfield(GV,'ele_pathname')
			ele_pathname				= SETTINGS.ele_pathname;
		else
			if isempty(GV.ele_pathname)
				ele_pathname			= SETTINGS.ele_pathname;
			else
				% The OSM data has already been loaded before:
				ele_pathname			= GV.ele_pathname;
			end
		end
		if isnumeric(ele_pathname)
			ele_pathname				= SETTINGS.default_pathname;
		else
			if exist(ele_pathname,'dir')~=7
				% The file does not exist:
				ele_pathname			= SETTINGS.default_pathname;
			end
		end
		figure(APP.MapLab3D);	% This is a test to prevent the uiget window from being opened behind another window.
		ele_pathname			= uigetdir_local(ele_pathname,'Select the elevation data directory');
		figure(APP.MapLab3D);	% This brings the app figure to the foreground.
		if isequal(ele_pathname,0)
			display_on_gui('state',...
				sprintf('Load OSM and elevation data ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
			set(GV_H.text_waitbar,'String','');
			drawnow;
			return
		end
		if ~strcmp(ele_pathname(end),'\')
			ele_pathname	= [ele_pathname '\'];
		end
	end
	
	if APP.LoadSettingsCompleteOSMfileMenu.Checked
		% Load the complete OSM-data
		osm_pathfilename_local	= [osm_pathname osm_filename];
		osmfilter_command			= '';
	elseif APP.LoadSettingsFilteredOSMfileMenu.Checked
		% Load the filtered OSM-data:
		% Call osmfilter:
		try
			[osm_filename_filt,osm_pathname_filt,osmfilter_command]	= call_osmfilter(osm_filename,osm_pathname,1);
		catch ME
			errormessage('',ME);
		end
		osm_pathfilename_local	= [osm_pathname_filt osm_filename_filt];
	elseif APP.LoadSettingsOnlyOSMboundariesMenu.Checked
		% Load only the OSM limits:
		% Call osmfilter:
		% [pathname,~,~]	= fileparts(mfilename('fullpath'));
		% if ~strcmp(pathname(end),'\')
		% 	pathname	= [pathname '\'];
		% end
		[pathname_osmfilterexe,~,~]	= fileparts(mfilename('fullpath'));
		if ~strcmp(pathname_osmfilterexe(end),'\')
			pathname_osmfilterexe	= [pathname_osmfilterexe '\'];
		end
		cd(pathname_osmfilterexe);
		osm_pathfilename_local	= [GV.projectdirectory osm_filename(1:(end-4)) '_empty.osm'];
		osmfilter_command	= sprintf('!osmfilter "%s" --drop-nodes --drop-ways --drop-relations >"%s"',...
			[osm_pathname osm_filename],osm_pathfilename_local);
		msg	= sprintf('Calling osmfilter. This may take some time ... ');
		set(GV_H.text_waitbar,'String',msg);
		drawnow;
		try
			eval(osmfilter_command);
		catch ME
			errormessage('',ME);
		end
		osmfilter_command		= '';
	else
		errormessage;
	end
	% Assign the user inputs:
	GV.osm_filename		= osm_filename;
	GV.osm_pathname		= osm_pathname;
	GV.osm_pathfilename	= [osm_pathname osm_filename];
	GV.osmfilter_command	= osmfilter_command;
	if APP.LoadSettingsElevationDataMenu.Checked
		GV.ele_pathname			= ele_pathname;
		SETTINGS.ele_pathname	= GV.ele_pathname;
	end
	SETTINGS.osm_pathfilename	= GV.osm_pathfilename;
	set_settings('save');
	% Display the user inputs:
	display_on_gui('pathfilenames');
	
	
	
	%---------------------------------------------------------------------------------------------------------
	% Waitbar
	%---------------------------------------------------------------------------------------------------------
	% Calculation of the remaining time:
	% x = (t1-t0)/(tend-t0) ,  dt10 = t1-t0  ==>  tend = t0+dt10/x
	% tremaining = tend-t1 = t0+dt10/x-t1 = dt10/x-(t1-t0) = dt10/x-dt10 = dt10*(1-x)/x
	
	% Calibration of WAITBAR.dx: dx=WAITBAR.dt/sum(WAITBAR.dt)
	WAITBAR				= [];
	if APP.LoadSettingsOnlyOSMboundariesMenu.Checked&&APP.LoadSettingsElevationDataMenu.Checked
		% Load only OSM-boundaries and elevation data:
		WAITBAR.dx(1,1)	= 0.1772;									% Length of each phase:	1) load OSM-data
		WAITBAR.dx(2,1)	= 0.81868;									%								2) assign elevation-data
		WAITBAR.dx(3,1)	= 0;											%								3) edit OSM-data: nodes
		WAITBAR.dx(4,1)	= 0;											%								4) edit OSM-data: ways
		WAITBAR.dx(5,1)	= 0.0013736;								%								5) edit OSM-data: relations
		WAITBAR.dx(6,1)	= 0.0027473;								%								6) indexing keys and values
		if sort_the_tags
			WAITBAR.dx(7,1)	= 0;										%								7) sort the tags
		end
	elseif APP.LoadSettingsOnlyOSMboundariesMenu.Checked&&APP.LoadSettingsDoNotLoadElevationDataMenu.Checked
		% Load only OSM-boundaries, no elevation data:
		WAITBAR.dx(1,1)	= 0.30249;									% Length of each phase:	1) load OSM-data
		WAITBAR.dx(2,1)	= 0.68327;									%								2) assign elevation-data
		WAITBAR.dx(3,1)	= 0;											%								3) edit OSM-data: nodes
		WAITBAR.dx(4,1)	= 0;											%								4) edit OSM-data: ways
		WAITBAR.dx(5,1)	= 0.0035587;								%								5) edit OSM-data: relations
		WAITBAR.dx(6,1)	= 0.010676;									%								6) indexing keys and values
		if sort_the_tags
			WAITBAR.dx(7,1)	= 0;										%								7) sort the tags
		end
	elseif APP.LoadSettingsFilteredOSMfileMenu.Checked&&APP.LoadSettingsDoNotLoadElevationDataMenu.Checked
		% Load OSM-file with filtering, no elevation data:
		WAITBAR.dx(1,1)	= 0.16673;									% Length of each phase:	1) load OSM-data
		WAITBAR.dx(2,1)	= 0.006568;									%								2) assign elevation-data
		WAITBAR.dx(3,1)	= 0.092147;									%								3) edit OSM-data: nodes
		WAITBAR.dx(4,1)	= 0.3363;									%								4) edit OSM-data: ways
		WAITBAR.dx(5,1)	= 0.17809;									%								5) edit OSM-data: relations
		WAITBAR.dx(6,1)	= 0.22016;									%								6) indexing keys and values
		if sort_the_tags
			WAITBAR.dx(7,1)	= 0;										%								7) sort the tags
		end
	else
		% Load OSM-file with filtering and elevation data:
		WAITBAR.dx(1,1)	= 0.16439;									% Length of each phase:	1) load OSM-data
		WAITBAR.dx(2,1)	= 0.020734;									%								2) assign elevation-data
		WAITBAR.dx(3,1)	= 0.09026;									%								3) edit OSM-data: nodes
		WAITBAR.dx(4,1)	= 0.32809;									%								4) edit OSM-data: ways
		WAITBAR.dx(5,1)	= 0.17708;									%								5) edit OSM-data: relations
		WAITBAR.dx(6,1)	= 0.21945;									%								6) indexing keys and values
		if sort_the_tags
			WAITBAR.dx(7,1)	= 0.1992;								%								7) sort the tags
		end
	end
	WAITBAR.dx			= WAITBAR.dx/sum(WAITBAR.dx);			%
	WAITBAR.x0			= cumsum(WAITBAR.dx)-WAITBAR.dx;		% Begin each phase at x0(i)
	WAITBAR.dt			= zeros(size(WAITBAR.dx));				% measured time of each phase, for calibration of WAITBAR.dx
	WAITBAR.i			= 0;											% Current phase index
	WAITBAR.k			= 0;											% number of loops
	WAITBAR.kmax		= 1;											% maximum number of loops
	WAITBAR.t0_phase	= clock;										% Start time of the current phase
	WAITBAR.t0			= clock;										% Start time
	WAITBAR.t1			= clock;										% Time of the last update
	WAITBAR.name		= 'Open OSM-data';						% Name of the waitbar
	% WAITBAR.formatOut	= 'yyyy-mm-dd HH:MM:SS';			% Format of the "estimated end time" (see datestr)
	WAITBAR.formatOut	= 'HH:MM:SS';								% Format of the "estimated end time" (see datestr)
	WAITBAR.inapp		= 1;											% waitbar: 1: show in the app, 0: show separatly
	WAITBAR.h			= -1;											% Handle of the waitbar
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Phase 1: Load OSM data
	%------------------------------------------------------------------------------------------------------------------
	% Size of the OSM data = "size of entire map with the planned maximum dimensions":
	% OSMDATA.bounds.minlon
	% OSMDATA.bounds.maxlon
	% OSMDATA.bounds.minlat
	% OSMDATA.bounds.maxlat
	
	% Prepare the waitbar:
	WAITBAR.i			= 1;
	WAITBAR.k			= 0;
	WAITBAR.kmax		= 0;
	WAITBAR.t0_phase	= clock;
	
	% Measure WAITBAR.kmax:
	x		= 0;
	msg	= sprintf('Loading OSM data. This may take some time ...');
	set(GV_H.patch_waitbar,'XData',[0 x x 0]);
	set(GV_H.text_waitbar,'String',msg);
	drawnow;
	
	% Load OSM-data:
	OSMDATA	= readstruct(osm_pathfilename_local,'FileType','xml','AttributeSuffix','');
	
	% Map-dimensions: Convert to double:
	% After setting the map-dimensions: set the value of GV.map_origin:
	set_gv_map_origin;
	% AFter setting the value of GV.map_origin: lon,lat-x,y-calculator: Reset OSM data:
	calculator_latlonxy_reset('OSM');
	
	% ellipsoidal model of the figure of the Earth (needed for grn2eqa)
	OSMDATA.ellipsoid		= referenceSphere('Earth');
	
	% OSMDATA.bounds conversion of lat, lon from degrees to x,y in mm:
	set(GV_H.text_waitbar,'String',sprintf('Converting the OSM data from degree to mm... '));
	drawnow;
	[  OSMDATA.bounds.xmin_mm,...						% xmin_mm
		OSMDATA.bounds.xmax_mm,...						% xmax_mm
		OSMDATA.bounds.ymin_mm,...						% ymin_mm
		OSMDATA.bounds.ymax_mm]=...					% ymax_mm
		calculator_latlon_xy(...
		[],...												% dataset
		OSMDATA.bounds.minlon,...						% lonmin_deg
		OSMDATA.bounds.maxlon,...						% lonmax_deg
		OSMDATA.bounds.minlat,...						% latmin_deg
		OSMDATA.bounds.maxlat,...						% latmax_deg
		GV.map_origin(1,2),...							% lonorigin_deg
		GV.map_origin(1,1),...							% latorigin_deg
		PP.project.scale,...								% scale
		0);													% dist_osm_printout
	
	% Initialize maximum number of tags:
	OSMDATA.no_tags			= 0;
	
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Phase 2: Load elevation data
	%------------------------------------------------------------------------------------------------------------------
	
	% Prepare the waitbar:
	WAITBAR.i					= 2;
	WAITBAR.k					= 0;
	WAITBAR.kmax				= 2;
	WAITBAR.t0_phase			= clock;
	
	% Load the elevation data:
	msg	= sprintf('Loading elevation data. This may take some time ...');
	k		= 1;
	x		= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*k/WAITBAR.kmax;
	set(GV_H.patch_waitbar,'XData',[0 x x 0]);
	set(GV_H.text_waitbar,'String',msg);
	drawnow;
	
	% If a mat file is loaded, the loading time is relatively short, otherwise it is difficult to estimate.
	if APP.LoadSettingsElevationDataMenu.Checked
		[lonv_file,latv_file,elem_file]	= open_ele(ele_pathname);
		if isempty(elem_file)
			% Warning message:
			warntext	= sprintf([...
				'Warning:\n',...
				'The directory\n',...
				'%s\n',...
				'does not contain any height data!\n',...
				'All heights are set to zero.'],...
				GV.ele_pathname);
			GV_H.warndlg.open_osm_load_ele		= warndlg(warntext,'Warning');
			GV_H.warndlg.open_osm_load_ele.Tag	= 'maplab3d_figure';
		end
	else
		lonv_file	= [];
		latv_file	= [];
		elem_file	= [];
	end
	
	% Load the elevation data:
	msg	= sprintf('Preparing elevation data. This may take some time ...');
	k		= 2;
	x		= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*k/WAITBAR.kmax;
	set(GV_H.patch_waitbar,'XData',[0 x x 0]);
	set(GV_H.text_waitbar,'String',msg);
	drawnow;
	
	% When creating maps with great scale factor, there are much more points in original resolution than interpolated.
	% In this case, the filtersize of the project parameters is automatically increased.
	% The number of points must be reduced BEFORE interpolation (griddata)!
	% Only the ele_reduction-th value will be kept.
	% Filtersize: e.g.: ele_reduction  =  1  2  3  4  5 ...
	%                   filtersize     =  1  3  3  5  5 ...
	
	% Different spacings in latv_file and lonv_file are possible!
	if APP.LoadSettingsElevationDataMenu.Checked&&~isempty(elem_file)
		% Elevation data is loaded:
		dlon		= lonv_file(2)-lonv_file(1);
		dlat		= latv_file(2)-latv_file(1);
	else
		% Elevation data is not loaded:
		nlon_est	= 10;
		nlat_est	= 10;
		dlon		= (OSMDATA.bounds.maxlon-OSMDATA.bounds.minlon)/nlon_est;
		dlat		= (OSMDATA.bounds.maxlat-OSMDATA.bounds.minlat)/nlat_est;
	end
	% Estimated number of points:
	nx_est	= (OSMDATA.bounds.xmax_mm-OSMDATA.bounds.xmin_mm)/PP.general.dxy_ele_mm;
	ny_est	= (OSMDATA.bounds.ymax_mm-OSMDATA.bounds.ymin_mm)/PP.general.dxy_ele_mm;
	nlon_est	= (OSMDATA.bounds.maxlon-OSMDATA.bounds.minlon)/dlon;
	nlat_est	= (OSMDATA.bounds.maxlat-OSMDATA.bounds.minlat)/dlat;
	% Data reduction ratio:
	ele_reduction_lon	= floor(nlon_est/nx_est);
	ele_reduction_lat	= floor(nlat_est/ny_est);
	ele_reduction_lon	= max(1,ele_reduction_lon);
	ele_reduction_lat	= max(1,ele_reduction_lat);
	% Filter settings:
	GV.ele_filtset_lon_filtersize	= ones(size(PP.colorspec,1),1);
	GV.ele_filtset_lat_filtersize	= ones(size(PP.colorspec,1),1);
	GV.ele_filtset_lon_sigma		= ones(size(PP.colorspec,1),1)*0.5;
	GV.ele_filtset_lat_sigma		= ones(size(PP.colorspec,1),1)*0.5;
	for icolspec=1:size(PP.colorspec,1)
		% filtersize must be an odd number:
		GV.ele_filtset_lon_filtersize(icolspec,1)	= max(...
			floor(PP.colorspec(icolspec,1).ele_filtset.filtersize/2)*2+1,...
			floor(ele_reduction_lon                              /2)*2+1);
		GV.ele_filtset_lat_filtersize(icolspec,1)	= max(...
			floor(PP.colorspec(icolspec,1).ele_filtset.filtersize/2)*2+1,...
			floor(ele_reduction_lat                              /2)*2+1);
		if    (GV.ele_filtset_lon_filtersize(icolspec,1)>PP.colorspec(icolspec,1).ele_filtset.filtersize)||...
				(GV.ele_filtset_lat_filtersize(icolspec,1)>PP.colorspec(icolspec,1).ele_filtset.filtersize)
			% Replace sigma:
			% Default filtersize: filtersize = 2*ceil(2*sigma)+1 (see MATLAB function "imgaussfilt")   ==>
			% Default sigma:      sigma = (filtersize-1)/4
			GV.ele_filtset_lon_sigma(icolspec,1)	= max([1e-6,...
				PP.colorspec(icolspec,1).ele_filtset.sigma,...
				(GV.ele_filtset_lon_filtersize(icolspec,1)-1)/4]);
			GV.ele_filtset_lat_sigma(icolspec,1)	= max([1e-6,...
				PP.colorspec(icolspec,1).ele_filtset.sigma,...
				(GV.ele_filtset_lat_filtersize(icolspec,1)-1)/4]);
		else
			% Do not replace sigma:
			GV.ele_filtset_lon_sigma(icolspec,1)	= max(1e-6,...
				PP.colorspec(icolspec,1).ele_filtset.sigma);
			GV.ele_filtset_lat_sigma(icolspec,1)	= max(1e-6,...
				PP.colorspec(icolspec,1).ele_filtset.sigma);
		end
	end
	ele_filtersize_used_lon_max	= max(GV.ele_filtset_lon_filtersize);
	ele_filtersize_used_lat_max	= max(GV.ele_filtset_lat_filtersize);
	% Extend the limits of the required elevation data for filtering:
	% The elevation data must be greater than the OSM-data to avoid problems when filtering/interpolating at the edge:
	if ele_filtersize_used_lon_max>1
		ext_lon_margin	= (ceil(2*ele_filtersize_used_lon_max)+6)*dlon;		% with reserve
	else
		ext_lon_margin	= 6*dlon;	% Take at least 6 points more than necessary for interpolation of data at the margin.
	end
	if ele_filtersize_used_lat_max>1
		ext_lat_margin	= (ceil(2*ele_filtersize_used_lat_max)+6)*dlat;		% with reserve
	else
		ext_lat_margin	= 6*dlat;	% Take at least 6 points more than necessary for interpolation of data at the margin.
	end
	minlon		= OSMDATA.bounds.minlon-ext_lon_margin;
	maxlon		= OSMDATA.bounds.maxlon+ext_lon_margin;
	minlat		= OSMDATA.bounds.minlat-ext_lat_margin;
	maxlat		= OSMDATA.bounds.maxlat+ext_lat_margin;
	% Extend the limits of the required elevation data for interpolating:
	xmin_mm		= OSMDATA.bounds.xmin_mm-5*PP.general.dxy_ele_mm;
	xmax_mm		= OSMDATA.bounds.xmax_mm+5*PP.general.dxy_ele_mm;
	ymin_mm		= OSMDATA.bounds.ymin_mm-5*PP.general.dxy_ele_mm;
	ymax_mm		= OSMDATA.bounds.ymax_mm+5*PP.general.dxy_ele_mm;
	x_corners_mm_v	= [...
		xmin_mm;...
		xmax_mm;...
		xmin_mm;...
		xmax_mm];
	y_corners_mm_v	= [...
		ymin_mm;...
		ymin_mm;...
		ymax_mm;...
		ymax_mm];
	x_corners_m_v	= x_corners_mm_v/1000*PP.project.scale;
	y_corners_m_v	= y_corners_mm_v/1000*PP.project.scale;
	[lat_corners_v,lon_corners_v]	= eqa2grn(x_corners_m_v,y_corners_m_v,GV.map_origin,OSMDATA.ellipsoid);
	minlon		= floor(min([minlon;lon_corners_v])/dlon)*dlon;
	maxlon		= ceil( max([maxlon;lon_corners_v])/dlon)*dlon;
	minlat		= floor(min([minlat;lat_corners_v])/dlat)*dlat;
	maxlat		= ceil( max([maxlat;lat_corners_v])/dlat)*dlat;
	
	% Assign the elevation data: Result of the previous steps:
	% Elevation data:
	%		lonv_file
	%		latv_file
	%		elem_file
	%		dlon
	%		dlat
	% OSM data:
	%		minlon									The loaded height data must cover this range.
	%		maxlon
	%		minlat
	%		maxlat
	%		ele_reduction_lon
	%		ele_reduction_lat
	%		GV.ele_filtset_lon_filtersize(icolspec,1)
	%		GV.ele_filtset_lat_filtersize(icolspec,1)
	%		GV.ele_filtset_lon_sigma(icolspec,1)
	%		GV.ele_filtset_lat_sigma(icolspec,1)
	
	% Initialize the elevation data:
	ELE											= [];
	
	% Collect the indices icolspec of equal color specific settings
	%    GV.ele_filtset_lon_filtersize(icolspec,1)
	%    GV.ele_filtset_lat_filtersize(icolspec,1)
	%    GV.ele_filtset_lon_sigma(icolspec,1)
	%    GV.ele_filtset_lat_sigma(icolspec,1)
	% in ELE.elefiltset(ifs,1).icolspec_v:
	% The first element ELE.elefiltset(1,1) contains always the tile base data (should be icolspec=1)!
	% Results:
	%		ELE.elefiltset(ifs,1).icolspec_v		Vector of colorspec indices with idential filter settings.
	%		ELE.ifs_v(icolspec,1)					Indices ifs of the filter settings.
	color_prio_v		= [PP.color.prio];
	icol_tilebase		= find(color_prio_v==0,1);
	icolspec_tilebase	= PP.color(icol_tilebase,1).spec;
	ifs					= 1;
	ELE.elefiltset(ifs,1).icolspec_v		= icolspec_tilebase;
	for icolspec=1:size(PP.colorspec,1)
		ifs					= 1;
		while ifs<=size(ELE.elefiltset,1)
			if any(...
					(GV.ele_filtset_lon_filtersize(icolspec,1)==GV.ele_filtset_lon_filtersize(ELE.elefiltset(ifs,1).icolspec_v,1))&...
					(GV.ele_filtset_lat_filtersize(icolspec,1)==GV.ele_filtset_lat_filtersize(ELE.elefiltset(ifs,1).icolspec_v,1))&...
					(GV.ele_filtset_lon_sigma(     icolspec,1)==GV.ele_filtset_lon_sigma(     ELE.elefiltset(ifs,1).icolspec_v,1))&...
					(GV.ele_filtset_lat_sigma(     icolspec,1)==GV.ele_filtset_lat_sigma(     ELE.elefiltset(ifs,1).icolspec_v,1))    )
				% The element ifs has already elements with the same filter settings:
				% Add icolspec to ELE.elefiltset(ifs,1).icolspec_v:
				ELE.elefiltset(ifs,1).icolspec_v	= unique([ELE.elefiltset(ifs,1).icolspec_v;icolspec]);
				break
			end
			ifs					= ifs+1;
		end
		if ifs>size(ELE.elefiltset,1)
			% The filter settings are new:
			ELE.elefiltset(ifs,1).icolspec_v	= icolspec;
		end
		ELE.ifs_v(icolspec,1)	= ifs;
	end
	
	% Assign the data for all given filter settings:
	for ifs=1:size(ELE.elefiltset,1)
		icolspec										= ELE.elefiltset(ifs,1).icolspec_v(1,1);
		
		% Get lonv, lonm, latv, latm, elem: Only elevation data inside the OSM boundaries.
		if APP.LoadSettingsElevationDataMenu.Checked&&~isempty(elem_file)
			% Elevation data is loaded:
			% Only use loaded elevation data that lies within the required OSM boundary box:
			
			% Step 1: Reduce the loaded elevation data to the required range:
			% Reduce longitude vector:
			klonv_keep		= (lonv_file>=(minlon-dlon))&(lonv_file<=(maxlon+dlon));
			lonv				= lonv_file(1,klonv_keep);
			% Reduce latitude vector:
			klatv_keep		= (latv_file>=(minlat-dlat))&(latv_file<=(maxlat+dlat));
			latv				= latv_file(klatv_keep,1);
			% Reduce elevation matrix:
			elem				= elem_file(klatv_keep,klonv_keep);
			
			% Step 2: Expand the loaded elevation data if it does not cover the OSM boundary box:
			% Extend lonv at the start:
			extend_lonv		= (minlon:dlon:(lonv(1)-dlon));
			if ~isempty(extend_lonv)
				lonv			= [extend_lonv lonv];
				elem			= [nan(size(elem,1),size(extend_lonv,2)) elem];
			end
			% Extend lonv at the end:
			extend_lonv		= ((lonv(end)+dlon):dlon:maxlon);
			if ~isempty(extend_lonv)
				lonv			= [lonv extend_lonv];
				elem			= [elem nan(size(elem,1),size(extend_lonv,2))];
			end
			% Extend latv at the start:
			extend_latv		= (minlat:dlat:(latv(1)-dlat))';
			if ~isempty(extend_latv)
				latv			= [extend_latv;latv];
				elem			= [nan(size(extend_latv,1),size(elem,2));elem];
			end
			% Extend latv at the end:
			extend_latv		= ((latv(end)+dlat):dlat:maxlat)';
			if ~isempty(extend_latv)
				latv			= [latv;extend_latv];
				elem			= [elem;nan(size(extend_latv,1),size(elem,2))];
			end
			
		else
			% Elevation data is not loaded:
			lonv			= (minlon:dlon:maxlon);
			latv			= (minlat:dlat:maxlat)';
			elem			= zeros(size(latv,1),size(lonv,2));
		end
		[lonm,latm]	= meshgrid(lonv,latv);
		
		% If the elevation data is not complete: show a message.
		if APP.LoadSettingsElevationDataMenu.Checked&&~isempty(elem_file)
			[rlat_isnan,~]		= find(isnan(elem),1);
			if ~isempty(rlat_isnan)
				% Show the missing data:
				% Data reduction:
				nmax			= GV.nmax_elevation_data_reduction;
				kredlon		= ceil(length(lonv)/nmax);
				kredlat		= ceil(length(latv)/nmax);
				lonv_red		= lonv(1,1:kredlon:end);
				latv_red		= latv(1:kredlat:end,1);
				elem_red		= elem(1:kredlat:end,1:kredlon:end);
				% Plot:
				[lonm_red,latm_red]	= meshgrid(lonv_red,latv_red);
				hf		= figure(3254900);
				clf(hf,'reset');
				set(hf,'Tag','maplab3d_figure');
				ha		= axes;
				hold(ha,'on');
				set(hf,'Name','Elevation');
				set(hf,'NumberTitle','off');
				title_str	= sprintf([...
					'!!! THE ELEVATION DATA IS NOT COMPLETE !!!\n',...
					'%s\n',...
					'Required longitude range: %g° .. %g°\n',...
					'Required latitude range: %g° .. %g°'],...
					ele_pathname,...
					minlon,maxlon,...
					minlat,maxlat);
				title(ha,title_str,'Interpreter','none');
				s=surf(lonm_red,latm_red,elem_red);
				s.EdgeAlpha		= 0;
				x	= [minlon maxlon maxlon minlon minlon];
				y	= [minlat minlat maxlat maxlat minlat];
				plot3(ha,x,y,min(elem_red,[],'all')*ones(size(x)),'LineWidth',5,'LineStyle','-','Color','k');
				xlabel(ha,'lon / °');
				ylabel(ha,'lat / °');
				zlabel(ha,'z / m');
				cameratoolbar(hf,'Show');
				view(ha,3);
				drawnow;
				% Warning message:
				warntext	= sprintf([...
					'Warning:\n',...
					'The elevation data in\n',...
					'%s\n',...
					'does not fully cover the required range:\n',...
					'Longitude: %g° .. %g°\n',...
					'Latitude: %g° .. %g°\n',...
					'The missing values have been replaced by zeros.'],...
					GV.ele_pathname,...
					minlon,...
					maxlon,...
					minlat,...
					maxlat);
				GV_H.warndlg.open_osm_load_ele		= warndlg(warntext,'Warning');
				GV_H.warndlg.open_osm_load_ele.Tag	= 'maplab3d_figure';
				elem(isnan(elem))	= 0;
			end
		elseif APP.LoadSettingsDoNotLoadElevationDataMenu.Checked||isempty(elem_file)
			% Do not load elevation-data: nop
		else
			errormessage;
		end
		
		% Results of the previous steps: lonv, latv, lonm, latm, elem: Loaded elevation data at the required range.
		
		% 3D preview of the map (create_map_3dpreview): used variables, must have the same size:
		% resolution   = 'original'					-->  ELE.elefiltset(ifs,1).xom_mm
		%                                              ELE.elefiltset(ifs,1).yom_mm
		%                                              ELE.elefiltset(ifs,1).zom_mm
		% resolution   = 'original_filtered'		-->  ELE.elefiltset(ifs,1).xofm_mm
		%                                              ELE.elefiltset(ifs,1).yofm_mm
		%                                              ELE.elefiltset(ifs,1).zofm_mm
		% resolution   = 'interpolated_filtered'	-->  ELE.elefiltset(ifs,1).xm_mm
		%                                              ELE.elefiltset(ifs,1).ym_mm
		%                                              ELE.elefiltset(ifs,1).zm_mm
		
		% Conversion of the elevation to model scale (unit mm), taking into account scale and superelevation:
		% (Superelevation: Enlargement of the height scale compared to the length scale)
		ELE.elefiltset(ifs,1).zom_mm			= double(elem)*1000/PP.project.scale*PP.general.superelevation;
		[  ELE.elefiltset(ifs,1).xom_mm,...												% [x,y]  = grn2eqa(lat,lon,origin)
			ELE.elefiltset(ifs,1).yom_mm]	= grn2eqa(latm,lonm,GV.map_origin,OSMDATA.ellipsoid);
		ELE.elefiltset(ifs,1).xom_mm			= ELE.elefiltset(ifs,1).xom_mm*1000/PP.project.scale;
		ELE.elefiltset(ifs,1).yom_mm			= ELE.elefiltset(ifs,1).yom_mm*1000/PP.project.scale;
		
		% Filtering of the elevation-data:
		% Do not overwrite lonv, latv, lonm, latm, elem!
		if    (GV.ele_filtset_lon_filtersize(icolspec,1)>1)||...
				(GV.ele_filtset_lat_filtersize(icolspec,1)>1)
			% Filtered elevation matrix:
			% xom_mm: nearly equal rows   , different columns  (xv=xom_mm(1,:))
			% yom_mm: nearly equal columns, different rows     (yv=yom_mm(:,1))
			sigma_v		= [...
				GV.ele_filtset_lat_sigma(icolspec,1) ...
				GV.ele_filtset_lon_sigma(icolspec,1)    ];
			filtersize_v		= [...					% two-dimensional filter (example: fspecial("gaussian",[3 5],1000))
				GV.ele_filtset_lat_filtersize(icolspec,1) ...			% number of rows    (y-values)
				GV.ele_filtset_lon_filtersize(icolspec,1)    ];			% number of columns (x-values)
			ELE.elefiltset(ifs,1).zofm_mm = imgaussfilt(ELE.elefiltset(ifs,1).zom_mm,sigma_v,'FilterSize',filtersize_v);
			% After filtering, N values ​​at the edge are no longer valid and must be cut off:
			Nlat			= floor(GV.ele_filtset_lat_filtersize(icolspec,1)/2)+1;				% +1: reserve
			Nlon			= floor(GV.ele_filtset_lon_filtersize(icolspec,1)/2)+1;				% +1: reserve
			kredlat		= ((1+Nlat):(size(latv,1)-Nlat));
			kredlon		= ((1+Nlon):(size(lonv,2)-Nlon));
			latfm			= latm(kredlat,kredlon);
			lonfm			= lonm(kredlat,kredlon);
			if isempty(latfm)||isempty(lonfm)
				errortext	= sprintf([...
					'There is no elevation data. Try this:\n',...
					'1) Increase the latitude/longitude range of the OSM data\n',...
					'2) Decrease the project parameters colorspec.ele_filtset.filtersize']);
				errormessage(errortext);
			end
			ELE.elefiltset(ifs,1).xofm_mm	= ELE.elefiltset(ifs,1).xom_mm(kredlat,kredlon);
			ELE.elefiltset(ifs,1).yofm_mm	= ELE.elefiltset(ifs,1).yom_mm(kredlat,kredlon);
			ELE.elefiltset(ifs,1).zofm_mm	= ELE.elefiltset(ifs,1).zofm_mm(kredlat,kredlon);
		else
			ELE.elefiltset(ifs,1).xofm_mm	= ELE.elefiltset(ifs,1).xom_mm;
			ELE.elefiltset(ifs,1).yofm_mm	= ELE.elefiltset(ifs,1).yom_mm;
			ELE.elefiltset(ifs,1).zofm_mm	= ELE.elefiltset(ifs,1).zom_mm;
			latfm			= latm;
			lonfm			= lonm;
		end
		
		% Limit the size of the matrices to at maximum GV.nmax_elevation_data_reduction:
		kredlon			= ceil(size(ELE.elefiltset(ifs,1).zom_mm,2)/GV.nmax_elevation_data_reduction);
		kredlat			= ceil(size(ELE.elefiltset(ifs,1).zom_mm,1)/GV.nmax_elevation_data_reduction);
		ELE.elefiltset(ifs,1).zom_mm		= ELE.elefiltset(ifs,1).zom_mm(1:kredlat:end,1:kredlon:end);
		ELE.elefiltset(ifs,1).xom_mm		= ELE.elefiltset(ifs,1).xom_mm(1:kredlat:end,1:kredlon:end);
		ELE.elefiltset(ifs,1).yom_mm		= ELE.elefiltset(ifs,1).yom_mm(1:kredlat:end,1:kredlon:end);
		
		% Reduction of the elevation-data:
		% Reduction before conversion from degrees to mm (faster conversion),
		% the original resolution data will be overwritten:
		if (ele_reduction_lon>1)||(ele_reduction_lat>1)
			lonv_mask	= false(1,size(lonfm,2));
			latv_mask	= false(size(latfm,1),1);
			lonv_mask(1:ele_reduction_lon:size(lonfm,2))	= true;
			latv_mask(1:ele_reduction_lat:size(latfm,1))	= true;
			lonfredm		= lonfm(latv_mask,lonv_mask);
			latfredm		= latfm(latv_mask,lonv_mask);
			zfredm_mm	= ELE.elefiltset(ifs,1).zofm_mm(latv_mask,lonv_mask);
			clear lonv_mask latv_mask
		else
			zfredm_mm	= ELE.elefiltset(ifs,1).zofm_mm;
			lonfredm		= lonfm;
			latfredm		= latfm;
		end
		clear lonfm latfm
		
		% Limit the size of the matrices to at maximum GV.nmax_elevation_data_reduction:
		kredlonf			= ceil(size(ELE.elefiltset(ifs,1).zofm_mm,2)/GV.nmax_elevation_data_reduction);
		kredlatf			= ceil(size(ELE.elefiltset(ifs,1).zofm_mm,1)/GV.nmax_elevation_data_reduction);
		ELE.elefiltset(ifs,1).zofm_mm		= ELE.elefiltset(ifs,1).zofm_mm(1:kredlatf:end,1:kredlonf:end);
		ELE.elefiltset(ifs,1).xofm_mm		= ELE.elefiltset(ifs,1).xofm_mm(1:kredlatf:end,1:kredlonf:end);
		ELE.elefiltset(ifs,1).yofm_mm		= ELE.elefiltset(ifs,1).yofm_mm(1:kredlatf:end,1:kredlonf:end);
		
		% Conversion of lat, lon from degrees to x,y in mm ([x,y]  = grn2eqa(lat,lon,origin)):
		[xfredm_mm,yfredm_mm]		= grn2eqa(latfredm,lonfredm,GV.map_origin,OSMDATA.ellipsoid);
		xfredm_mm		= xfredm_mm*1000/PP.project.scale;
		yfredm_mm		= yfredm_mm*1000/PP.project.scale;
		% For safe interpolation at the edge with griddata: Do not use values ​​at the edge:
		xfredm_min_mm	= max(xfredm_mm((2:(end-1)),      2),[],'all');
		xfredm_max_mm	= min(xfredm_mm((2:(end-1)),(end-1)),[],'all');
		yfredm_min_mm	= max(yfredm_mm(      2,(2:(end-1))),[],'all');
		yfredm_max_mm	= min(yfredm_mm((end-1),(2:(end-1))),[],'all');
		
		% Interpolate to constant distances between the x and y values:
		ELE.elefiltset(ifs,1).dx_mm		= PP.general.dxy_ele_mm;
		ELE.elefiltset(ifs,1).dy_mm		= PP.general.dxy_ele_mm;
		ELE.elefiltset(ifs,1).xmin_mm	= ceil(xfredm_min_mm/ELE.elefiltset(ifs,1).dx_mm)*ELE.elefiltset(ifs,1).dx_mm;
		ELE.elefiltset(ifs,1).ymin_mm	= ceil(yfredm_min_mm/ELE.elefiltset(ifs,1).dy_mm)*ELE.elefiltset(ifs,1).dy_mm;
		ELE.elefiltset(ifs,1).xv_mm		= (ELE.elefiltset(ifs,1).xmin_mm:ELE.elefiltset(ifs,1).dx_mm:xfredm_max_mm)';
		ELE.elefiltset(ifs,1).yv_mm		= (ELE.elefiltset(ifs,1).ymin_mm:ELE.elefiltset(ifs,1).dy_mm:yfredm_max_mm)';
		ELE.elefiltset(ifs,1).xmax_mm	= ELE.elefiltset(ifs,1).xv_mm(end);
		ELE.elefiltset(ifs,1).ymax_mm	= ELE.elefiltset(ifs,1).yv_mm(end);
		ELE.elefiltset(ifs,1).nx			= length(ELE.elefiltset(ifs,1).xv_mm);
		ELE.elefiltset(ifs,1).ny			= length(ELE.elefiltset(ifs,1).yv_mm);
		mapsize_x_mm	= ELE.elefiltset(ifs,1).xmax_mm-ELE.elefiltset(ifs,1).xmin_mm;
		mapsize_y_mm	= ELE.elefiltset(ifs,1).ymax_mm-ELE.elefiltset(ifs,1).ymin_mm;
		if (mapsize_x_mm>1000)||(mapsize_y_mm>1000)
			question	= sprintf(['The map dimension is %gmm x %gmm.\n',...
				'This will lead to a long execution time\n',...
				'and a high memory requirement.\n',...
				'Maybe you should adapt the project scale (%g).'],mapsize_x_mm,mapsize_y_mm,PP.project.scale);
			answer	= questdlg_local(question,'Continue?','Continue','Cancel','Cancel');
			if isempty(answer)||strcmp(answer,'Cancel')
				display_on_gui('state',...
					sprintf('Load OSM and elevation data ... canceled (%s).',...
					dt_string(etime(clock,t_start_statebusy))),'notbusy','replace');
				set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
				set(GV_H.text_waitbar,'String','');
				drawnow;
				return
			end
		else
			if (ELE.elefiltset(ifs,1).nx>1000)||(ELE.elefiltset(ifs,1).ny>1000)
				question	= sprintf(['The the grid of elevation data is %g x %g points.\n',...
					'This will lead to a long execution time\n',...
					'and a high memory requirement.\n',...
					'Maybe you should adapt\n',...
					'- the project scale (%g) or the\n',...
					'- the grid spacing of the elevation data (%gmm).'],...
					ELE.elefiltset(ifs,1).nx,...
					ELE.elefiltset(ifs,1).ny,...
					PP.project.scale,...
					PP.general.dxy_ele_mm);
				answer	= questdlg_local(question,'Continue?','Continue','Cancel','Cancel');
				if isempty(answer)||strcmp(answer,'Cancel')
					display_on_gui('state',...
						sprintf('Load OSM and elevation data ... canceled (%s).',...
						dt_string(etime(clock,t_start_statebusy))),'notbusy','replace');
					set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
					set(GV_H.text_waitbar,'String','');
					drawnow;
					return
				end
			end
		end
		[  ELE.elefiltset(ifs,1).xm_mm,...
			ELE.elefiltset(ifs,1).ym_mm]	= meshgrid(ELE.elefiltset(ifs,1).xv_mm,ELE.elefiltset(ifs,1).yv_mm);
		ELE.elefiltset(ifs,1).zm_mm					= griddata(...
			xfredm_mm,yfredm_mm,zfredm_mm,...
			ELE.elefiltset(ifs,1).xm_mm,ELE.elefiltset(ifs,1).ym_mm,...
			PP.general.interpolation_method);
		clear zfredm_mm
		
		% Show elevation data for testing purposes:
		if ifs==1
			% Show the tile base settings:
			if testplot==1
				hf		= figure(200000);
				clf(hf,'reset');
				set(hf,'Tag','maplab3d_figure');
				ha		= axes;
				hold(ha,'on');
				set(hf,'Name','open_osm: elem');
				set(hf,'NumberTitle','off');
				title(sprintf('Elevation\n%s',GV.osm_pathfilename),'Interpreter','none');
				surf(lonm,latm,elem);
				xlabel(ha,'lon / °');
				ylabel(ha,'lat / °');
				zlabel(ha,'z / m');
				cameratoolbar(hf,'Show');
				view(ha,3);
			end
			if testplot==1
				hf		= figure(200001);
				clf(hf,'reset');
				set(hf,'Tag','maplab3d_figure');
				ha		= axes;
				hold(ha,'on');
				set(hf,'Name','open_osm: zm_mm');
				set(hf,'NumberTitle','off');
				title(sprintf('Elevation\n%s',GV.osm_pathfilename),'Interpreter','none');
				surf(ELE.elefiltset(ifs,1).xv_mm,ELE.elefiltset(ifs,1).yv_mm,ELE.elefiltset(ifs,1).zm_mm);
				xlabel(ha,'x / mm');
				ylabel(ha,'y / mm');
				zlabel(ha,'z / mm');
				cameratoolbar(hf,'Show');
				axis(ha,'equal');
				view(ha,3);
			end
		end
		
	end
	
	clear lonv latv lonm latm elem
	clear elem_file lonv_file latv_file
	
	for colno=1:size(PP.color,1)
		icolspec									= PP.color(colno,1).spec;
		ELE.elecolor(colno,1).icolspec	= icolspec;
		ELE.elecolor(colno,1).colprio		= PP.color(colno,1).prio;
		ELE.elecolor(colno,1).ifs			= ELE.ifs_v(icolspec,1);
		ELE.elecolor(colno,1).elepoly		= [];
	end
	
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Phase 3: Edit OSM data: nodes
	%------------------------------------------------------------------------------------------------------------------
	
	% number of nodes:
	if ~isfield(OSMDATA,'node')
		OSMDATA.node			= [];
	end
	inmax		= size(OSMDATA.node,2);
	
	% Prepare the waitbar:
	WAITBAR.i					= 3;
	WAITBAR.k					= 0;
	WAITBAR.kmax				= max(1,inmax);
	WAITBAR.t0_phase			= clock;
	
	% Edit nodes:
	
	% Vector of all id's for better searchability:
	OSMDATA.id.node			= arrayfun(@(x) uint64(x.id), OSMDATA.node);
	
	% Vectors of logical values, whether there is a tag specified or not:
	OSMDATA.istag.node		= false(1,inmax);
	
	% Conversion of lat, lon from degrees to x,y in mm:
	if ~isempty(OSMDATA.node)
		lat_v							= [OSMDATA.node.lat];
		lon_v							= [OSMDATA.node.lon];
		[x_m_v,y_m_v]				= grn2eqa(lat_v,lon_v,GV.map_origin,OSMDATA.ellipsoid);
		OSMDATA.node_x_mm			= x_m_v(:)'*1000/PP.project.scale;
		OSMDATA.node_y_mm			= y_m_v(:)'*1000/PP.project.scale;
	else
		OSMDATA.node_x_mm			= [];
		OSMDATA.node_y_mm			= [];
	end
	
	% Object number:
	OSMDATA.iobj.node			= zeros(1,inmax);
	
	for in=1:inmax
		
		% Waitbar:
		WAITBAR.k	= WAITBAR.k+1;
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
			t_remaining	= etime(WAITBAR.t1,WAITBAR.t0)*(1-x)/x;		% remaining time as number of seconds
			t_end			= datenum(WAITBAR.t1)+t_remaining/86400;		% end time as fractional number of days
			msg			= sprintf([...
				'Editing node %1.0f/%1.0f ...   /   ',...
				'Estimated remaining time: %s   /   ',...
				'Estimated end time: %s'],...
				in,inmax,...
				dt_string(t_remaining),...
				datestr(t_end,WAITBAR.formatOut));
			set(GV_H.patch_waitbar,'XData',[0 x x 0]);
			set(GV_H.text_waitbar,'String',msg);
			drawnow;
		end
		
		% Vectors of logical values, whether there is a tag specified or not:
		if ~ismissing(OSMDATA.node(1,in).tag(1,1))
			OSMDATA.istag.node(1,in)	= true;
			% Maximum number of tags:
			no_tags							= size(OSMDATA.node(1,in).tag,2);
			OSMDATA.no_tags				= max(OSMDATA.no_tags,no_tags);
		end
		
		% Convert strings to character arrays:
		if OSMDATA.istag.node(1,in)
			for int=1:size(OSMDATA.node(1,in).tag,2)
				if     isstring(OSMDATA.node(1,in).tag(1,int).k)
					OSMDATA.node(1,in).tag(1,int).k	= convertStringsToChars(OSMDATA.node(1,in).tag(1,int).k);
				elseif isnumeric(OSMDATA.node(1,in).tag(1,int).k)
					OSMDATA.node(1,in).tag(1,int).k	= num2str(OSMDATA.node(1,in).tag(1,int).k);
				elseif isdatetime(OSMDATA.node(1,in).tag(1,int).k)       ||...
						iscalendarduration(OSMDATA.node(1,in).tag(1,int).k)||...
						isduration(OSMDATA.node(1,in).tag(1,int).k)
					OSMDATA.node(1,in).tag(1,int).k	= char(OSMDATA.node(1,in).tag(1,int).k);
				else
					if ~isdeployed
						in
						int
						test=OSMDATA.node(1,in).tag(1,int)
						errormessage('Unkown data type');
					else
						OSMDATA.node(1,in).tag(1,int).k	= '???';
					end
				end
				if     isstring(OSMDATA.node(1,in).tag(1,int).v)
					OSMDATA.node(1,in).tag(1,int).v	= convertStringsToChars(OSMDATA.node(1,in).tag(1,int).v);
				elseif isnumeric(OSMDATA.node(1,in).tag(1,int).v)
					OSMDATA.node(1,in).tag(1,int).v	= num2str(OSMDATA.node(1,in).tag(1,int).v);
				elseif isdatetime(OSMDATA.node(1,in).tag(1,int).v)       ||...
						iscalendarduration(OSMDATA.node(1,in).tag(1,int).v)||...
						isduration(OSMDATA.node(1,in).tag(1,int).v)
					OSMDATA.node(1,in).tag(1,int).v	= char(OSMDATA.node(1,in).tag(1,int).v);
				else
					if ~isdeployed
						in
						int
						test=OSMDATA.node(1,in).tag(1,int)
						errormessage('Unkown data type');
					else
						OSMDATA.node(1,in).tag(1,int).v	= '???';
					end
				end
			end
		end
		
	end
	
	% Remove fields:
	if ~isempty(OSMDATA.node)
		OSMDATA.node				= rmfield(OSMDATA.node,'id');
		OSMDATA.node				= rmfield(OSMDATA.node,'lat');
		OSMDATA.node				= rmfield(OSMDATA.node,'lon');
	end
	
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Phase 4: Edit OSM data: ways
	%------------------------------------------------------------------------------------------------------------------
	
	% number of ways:
	if ~isfield(OSMDATA,'way')
		OSMDATA.way				= [];
	end
	iwmax		= size(OSMDATA.way,2);
	
	% Prepare the waitbar:
	WAITBAR.i					= 4;
	WAITBAR.k					= 0;
	WAITBAR.kmax				= max(1,iwmax);
	WAITBAR.t0_phase			= clock;
	
	% Edit ways:
	
	% Vector of all id's for better searchability:
	OSMDATA.id.way				= arrayfun(@(x) uint64(x.id), OSMDATA.way);
	
	% Vectors of logical values, whether there is a tag specified or not:
	OSMDATA.istag.way			= false(1,iwmax);
	
	% Object number:
	OSMDATA.iobj.way			= zeros(1,iwmax);
	
	for iw=1:iwmax
		
		% Waitbar:
		WAITBAR.k	= WAITBAR.k+1;
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
			t_remaining	= etime(WAITBAR.t1,WAITBAR.t0)*(1-x)/x;		% remaining time as number of seconds
			t_end			= datenum(WAITBAR.t1)+t_remaining/86400;		% end time as fractional number of days
			msg			= sprintf([...
				'Editing way %1.0f/%1.0f ...   /   ',...
				'Estimated remaining time: %s   /   ',...
				'Estimated end time: %s'],...
				iw,iwmax,...
				dt_string(t_remaining),...
				datestr(t_end,WAITBAR.formatOut));
			set(GV_H.patch_waitbar,'XData',[0 x x 0]);
			set(GV_H.text_waitbar,'String',msg);
			drawnow;
		end
		
		% Vectors of logical values, whether there is a tag specified or not:
		if ~ismissing(OSMDATA.way(1,iw).tag(1,1))
			OSMDATA.istag.way(1,iw)	= true;
			% Maximum number of tags:
			no_tags							= size(OSMDATA.way(1,iw).tag,2);
			OSMDATA.no_tags				= max(OSMDATA.no_tags,no_tags);
		end
		
		% Convert strings to character arrays:
		if OSMDATA.istag.way(1,iw)
			for iwt=1:size(OSMDATA.way(1,iw).tag,2)
				if     isstring(OSMDATA.way(1,iw).tag(1,iwt).k)
					OSMDATA.way(1,iw).tag(1,iwt).k	= convertStringsToChars(OSMDATA.way(1,iw).tag(1,iwt).k);
				elseif isnumeric(OSMDATA.way(1,iw).tag(1,iwt).k)
					OSMDATA.way(1,iw).tag(1,iwt).k	= num2str(OSMDATA.way(1,iw).tag(1,iwt).k);
				elseif isdatetime(OSMDATA.way(1,iw).tag(1,iwt).k)       ||...
						iscalendarduration(OSMDATA.way(1,iw).tag(1,iwt).k)||...
						isduration(OSMDATA.way(1,iw).tag(1,iwt).k)
					OSMDATA.way(1,iw).tag(1,iwt).k	= char(OSMDATA.way(1,iw).tag(1,iwt).k);
				else
					if ~isdeployed
						iw
						iwt
						test=OSMDATA.way(1,iw).tag(1,iwt)
						errormessage('Unkown data type');
					else
						OSMDATA.way(1,iw).tag(1,iwt).k	= '???';
					end
				end
				if     isstring(OSMDATA.way(1,iw).tag(1,iwt).v)
					OSMDATA.way(1,iw).tag(1,iwt).v	= convertStringsToChars(OSMDATA.way(1,iw).tag(1,iwt).v);
				elseif isnumeric(OSMDATA.way(1,iw).tag(1,iwt).v)
					OSMDATA.way(1,iw).tag(1,iwt).v	= num2str(OSMDATA.way(1,iw).tag(1,iwt).v);
				elseif isdatetime(OSMDATA.way(1,iw).tag(1,iwt).v)       ||...
						iscalendarduration(OSMDATA.way(1,iw).tag(1,iwt).v)||...
						isduration(OSMDATA.way(1,iw).tag(1,iwt).v)
					OSMDATA.way(1,iw).tag(1,iwt).v	= char(OSMDATA.way(1,iw).tag(1,iwt).v);
				else
					if ~isdeployed
						iw
						iwt
						test=OSMDATA.way(1,iw).tag(1,iwt)
						errormessage('Unkown data type');
					else
						OSMDATA.way(1,iw).tag(1,iwt).v	= '???';
					end
				end
			end
		end
		
		% vectors of all x,y-values:
		iwnmax	= size(OSMDATA.way(1,iw).nd,2);
		OSMDATA.way(1,iw).x_mm	= zeros(1,iwnmax);
		OSMDATA.way(1,iw).y_mm	= zeros(1,iwnmax);
		for iwn=1:iwnmax
			OSMDATA.way(1,iw).nd(1,iwn).ref	= uint64(OSMDATA.way(1,iw).nd(1,iwn).ref);
			in		= find(OSMDATA.id.node==OSMDATA.way(1,iw).nd(1,iwn).ref,1);
			if isscalar(in)
				OSMDATA.way(1,iw).x_mm(1,iwn)	= OSMDATA.node_x_mm(1,in);
				OSMDATA.way(1,iw).y_mm(1,iwn)	= OSMDATA.node_y_mm(1,in);
			else
				OSMDATA.way(1,iw).x_mm(1,iwn)	= nan;
				OSMDATA.way(1,iw).y_mm(1,iwn)	= nan;
			end
		end
		while ~isempty(OSMDATA.way(1,iw).x_mm)&&~isempty(OSMDATA.way(1,iw).y_mm)&&...
				(isnan(OSMDATA.way(1,iw).x_mm(1,1))||isnan(OSMDATA.way(1,iw).y_mm(1,1)))
			OSMDATA.way(1,iw).x_mm(:,1)	= [];
			OSMDATA.way(1,iw).y_mm(:,1)	= [];
		end
		while ~isempty(OSMDATA.way(1,iw).x_mm)&&~isempty(OSMDATA.way(1,iw).y_mm)&&...
				(isnan(OSMDATA.way(1,iw).x_mm(1,end))||isnan(OSMDATA.way(1,iw).y_mm(1,end)))
			OSMDATA.way(1,iw).x_mm(:,end)	= [];
			OSMDATA.way(1,iw).y_mm(:,end)	= [];
		end
		
		% Downsampling:
		dmin				= PP.general.load_osm_data.dmin_ways;		% Minimum distance between vertices
		if dmin>0
			dmax				= [];
			nmin				= [];
			[  xred_mm,...
				yred_mm]	= changeresolution_xy(...
				OSMDATA.way(1,iw).x_mm,...
				OSMDATA.way(1,iw).y_mm,dmax,dmin,nmin,1);				% Keep the first and the last point of the line!
			iwnmax	= size(xred_mm,2);
			if    (iwnmax<=3)                         && ...
					(abs(xred_mm(end)-xred_mm(1))<1e-8) && ...
					(abs(yred_mm(end)-yred_mm(1))<1e-8)
				% The first and last vertex are equal (closed way) and
				% The closed way has less than 4 vertices:
				% The closed way could not be plotted as area any more and possibly it is the position of a symbol:
				% Do not delete it and keep a minimum of 4 vertices in order to avoid problems:
				ixy_4	= size(OSMDATA.way(1,iw).x_mm,2);
				ixy_1	= 1;
				ixy_2	= 1+round((ixy_4-1)  /3);
				ixy_3	= 1+round((ixy_4-1)*2/3);
				ixy_v	= unique(sort([ixy_1 ixy_2 ixy_3 ixy_4]));
				OSMDATA.way(1,iw).x_mm	= OSMDATA.way(1,iw).x_mm(1,ixy_v);
				OSMDATA.way(1,iw).y_mm	= OSMDATA.way(1,iw).y_mm(1,ixy_v);
				iwnmax						= size(OSMDATA.way(1,iw).x_mm,2);
			else
				OSMDATA.way(1,iw).x_mm	= xred_mm;
				OSMDATA.way(1,iw).y_mm	= yred_mm;
			end
		end
		
		% number of the nodes:
		OSMDATA.way(1,iw).no_nodes	= iwnmax;
		
		% dimensions in x- and y-direction:
		if iwnmax>=2
			OSMDATA.way_xmin_mm(1,iw)	= min(OSMDATA.way(1,iw).x_mm);
			OSMDATA.way_xmax_mm(1,iw)	= max(OSMDATA.way(1,iw).x_mm);
			OSMDATA.way_ymin_mm(1,iw)	= min(OSMDATA.way(1,iw).y_mm);
			OSMDATA.way_ymax_mm(1,iw)	= max(OSMDATA.way(1,iw).y_mm);
		else
			OSMDATA.way_xmin_mm(1,iw)	= 0;
			OSMDATA.way_xmax_mm(1,iw)	= 0;
			OSMDATA.way_ymin_mm(1,iw)	= 0;
			OSMDATA.way_ymax_mm(1,iw)	= 0;
		end
		
		% length of the way:
		if iwnmax>=2
			iwn	= 1:(iwnmax-1);
			iwnp1	= 2:iwnmax;
			OSMDATA.way(1,iw).length_mm	= sum(sqrt(...
				(OSMDATA.way(1,iw).x_mm(iwnp1)-OSMDATA.way(1,iw).x_mm(iwn)).^2+...
				(OSMDATA.way(1,iw).y_mm(iwnp1)-OSMDATA.way(1,iw).y_mm(iwn)).^2    ));
		else
			OSMDATA.way(1,iw).length_mm	= 0;
		end
		
		% area of the way if it is closed (if first and last point are identical):
		if    (iwnmax>=4)                                                       && ...
				(abs(OSMDATA.way(1,iw).x_mm(end)-OSMDATA.way(1,iw).x_mm(1))<1e-8) && ...
				(abs(OSMDATA.way(1,iw).y_mm(end)-OSMDATA.way(1,iw).y_mm(1))<1e-8)
			% The way is closed:
			if GV.warnings_off
				warning('off','MATLAB:polyshape:repairedBySimplify');
				warning('off','MATLAB:polyshape:boolOperationFailed');
			end
			OSMDATA.way(1,iw).area_mm2	= area(polyshape(OSMDATA.way(1,iw).x_mm,OSMDATA.way(1,iw).y_mm));
			if GV.warnings_off
				warning('on','MATLAB:polyshape:repairedBySimplify');
				warning('on','MATLAB:polyshape:boolOperationFailed');
			end
		else
			% The way is not closed:
			OSMDATA.way(1,iw).area_mm2	= 0;
		end
		
	end
	
	% Remove fields:
	if ~isempty(OSMDATA.way)
		OSMDATA.way				= rmfield(OSMDATA.way,'id');
		OSMDATA.way				= rmfield(OSMDATA.way,'nd');
	end
	
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Phase 5: Edit OSM data: relations
	%------------------------------------------------------------------------------------------------------------------
	
	% number of relations:
	if ~isfield(OSMDATA,'relation')
		OSMDATA.relation			= [];
	end
	irmax								= size(OSMDATA.relation,2);
	
	% Prepare the waitbar:
	WAITBAR.i						= 5;
	WAITBAR.k						= 0;
	WAITBAR.kmax					= 0;
	if ~isempty(OSMDATA.relation)
		for ir=1:irmax
			if ~ismissing(OSMDATA.relation(1,ir).member(1,1))
				for irm=1:size(OSMDATA.relation(1,ir).member,2)
					WAITBAR.kmax	= WAITBAR.kmax+1;
				end
			else
				WAITBAR.kmax		= WAITBAR.kmax+1;
			end
		end
	else
		WAITBAR.kmax				= WAITBAR.kmax+1;
	end
	WAITBAR.t0_phase				= clock;
	WAITBAR.kmax					= max(1,WAITBAR.kmax);
	
	% Edit relations:
	
	% Vector of all id's for better searchability:
	OSMDATA.id.relation			= arrayfun(@(x) uint64(x.id), OSMDATA.relation);
	
	% Vectors of logical values, whether there is a tag specified or not:
	OSMDATA.istag.relation		= false(1,irmax);
	
	% Object number:
	OSMDATA.iobj.relation		= zeros(1,irmax);
	
	% in_relation_v:	vector of the same size as OSMDATA.node
	%						true if the single node is part of the relation (not as way)
	in_relation_v					= false(1,size(OSMDATA.node,2));
	
	for ir=1:irmax
		
		% Waitbar:
		WAITBAR.k	= WAITBAR.k+1;
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
			t_remaining	= etime(WAITBAR.t1,WAITBAR.t0)*(1-x)/x;		% remaining time as number of seconds
			t_end			= datenum(WAITBAR.t1)+t_remaining/86400;		% end time as fractional number of days
			msg			= sprintf([...
				'Editing relation %1.0f/%1.0f ...   /   ',...
				'Estimated remaining time: %s   /   ',...
				'Estimated end time: %s'],...
				ir,irmax,...
				dt_string(t_remaining),...
				datestr(t_end,WAITBAR.formatOut));
			set(GV_H.patch_waitbar,'XData',[0 x x 0]);
			set(GV_H.text_waitbar,'String',msg);
			drawnow;
		end
		
		% Vectors of logical values, whether there is a tag specified or not:
		if ~ismissing(OSMDATA.relation(1,ir).tag(1,1))
			OSMDATA.istag.relation(1,ir)	= true;
			% Maximum number of tags:
			no_tags							= size(OSMDATA.relation(1,ir).tag,2);
			OSMDATA.no_tags				= max(OSMDATA.no_tags,no_tags);
		end
		
		% Convert strings to character arrays:
		if OSMDATA.istag.relation(1,ir)
			for irt=1:size(OSMDATA.relation(1,ir).tag,2)
				if     isstring(OSMDATA.relation(1,ir).tag(1,irt).k)
					OSMDATA.relation(1,ir).tag(1,irt).k	= convertStringsToChars(OSMDATA.relation(1,ir).tag(1,irt).k);
				elseif isnumeric(OSMDATA.relation(1,ir).tag(1,irt).k)
					OSMDATA.relation(1,ir).tag(1,irt).k	= num2str(OSMDATA.relation(1,ir).tag(1,irt).k);
				elseif isdatetime(OSMDATA.relation(1,ir).tag(1,irt).k)       ||...
						iscalendarduration(OSMDATA.relation(1,ir).tag(1,irt).k)||...
						isduration(OSMDATA.relation(1,ir).tag(1,irt).k)
					OSMDATA.relation(1,ir).tag(1,irt).k	= char(OSMDATA.relation(1,ir).tag(1,irt).k);
				else
					if ~isdeployed
						in
						int
						test=OSMDATA.relation(1,ir).tag(1,irt)
						errormessage('Unkown data type');
					else
						OSMDATA.relation(1,ir).tag(1,irt).k	= '???';
					end
				end
				if     isstring(OSMDATA.relation(1,ir).tag(1,irt).v)
					OSMDATA.relation(1,ir).tag(1,irt).v	= convertStringsToChars(OSMDATA.relation(1,ir).tag(1,irt).v);
				elseif isnumeric(OSMDATA.relation(1,ir).tag(1,irt).v)
					OSMDATA.relation(1,ir).tag(1,irt).v	= num2str(OSMDATA.relation(1,ir).tag(1,irt).v);
				elseif isdatetime(OSMDATA.relation(1,ir).tag(1,irt).v)       ||...
						iscalendarduration(OSMDATA.relation(1,ir).tag(1,irt).v)||...
						isduration(OSMDATA.relation(1,ir).tag(1,irt).v)
					OSMDATA.relation(1,ir).tag(1,irt).v	= char(OSMDATA.relation(1,ir).tag(1,irt).v);
				else
					if ~isdeployed
						ir
						irt
						test=OSMDATA.relation(1,ir).tag(1,irt)
						errormessage('Unkown data type');
					else
						OSMDATA.relation(1,ir).tag(1,irt).v	= '???';
					end
				end
			end
		end
		
		% Convert member ref to uint64 and strings to character arrays:
		for irm=1:size(OSMDATA.relation(1,ir).member,2)
			OSMDATA.relation(1,ir).member(1,irm).ref	= uint64(OSMDATA.relation(1,ir).member(1,irm).ref);
			OSMDATA.relation(1,ir).member(1,irm).role	= char(OSMDATA.relation(1,ir).member(1,irm).role);
			OSMDATA.relation(1,ir).member(1,irm).type	= char(OSMDATA.relation(1,ir).member(1,irm).type);
		end
		
		% Search all members of the relation:
		connways			= connect_ways([]);
		[  OSMDATA.relation(1,ir).no_nodes,...			% no_nodes
			OSMDATA.relation(1,ir).no_ways,...			% no_ways
			OSMDATA.relation(1,ir).no_relations,...	% no_relations
			connways,...
			in_relation_v]=getdata_relation(ir,connways,0,0,[],in_relation_v);
		
		% Calculate the dimensions in x- and y-direction:
		[  OSMDATA.relation_xmin_mm(1,ir),...
			OSMDATA.relation_xmax_mm(1,ir),...
			OSMDATA.relation_ymin_mm(1,ir),...
			OSMDATA.relation_ymax_mm(1,ir)]	= connways_dim(connways);

		% Calculate the length of the whole relation (ways and areas):
		OSMDATA.relation(1,ir).length_mm		= connways_length(connways);
		
		% Calculate the area:
		OSMDATA.relation(1,ir).area_mm2		= connways_area(connways);
		
	end
	
	% Remove fields:
	if ~isempty(OSMDATA.relation)
		OSMDATA.relation				= rmfield(OSMDATA.relation,'id');
	end
	
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	
	%------------------------------------------------------------------------------------------------------------------
	% delete nodes without tag and that are not used as single node by a relation
	% The coordinates of the nodes that are part of ways are already stored in OSMDATA.way(1,iw).x_mm/y_mm.
	%------------------------------------------------------------------------------------------------------------------
	
	in_delete	= ~in_relation_v & ~OSMDATA.istag.node;
	OSMDATA.id.node(:,in_delete)		= [];
	OSMDATA.istag.node(:,in_delete)	= [];
	OSMDATA.iobj.node(:,in_delete)	= [];
	OSMDATA.node(:,in_delete)			= [];
	OSMDATA.node_x_mm(:,in_delete)	= [];
	OSMDATA.node_y_mm(:,in_delete)	= [];
	
	
	%------------------------------------------------------------------------------------------------------------------
	% indexing keys and values
	%------------------------------------------------------------------------------------------------------------------
	
	% Prepare the waitbar:
	WAITBAR.i			= 6;
	WAITBAR.k			= 0;
	WAITBAR.kmax		= max(1,2*(inmax+iwmax+irmax));
	WAITBAR.t0_phase	= clock;
	
	% Indexing keys and values:
	OSMDATA.keys		= zeros(0,1);
	OSMDATA.values		= zeros(0,1);
	OSMDATA.keys_no	= uint64(zeros(0,1));
	OSMDATA.values_no	= uint64(zeros(0,1));
	indexing_kv('keys'  ,'k','node'    ,'in');
	indexing_kv('keys'  ,'k','way'     ,'iw');
	indexing_kv('keys'  ,'k','relation','ir');
	indexing_kv('values','v','node'    ,'in');
	indexing_kv('values','v','way'     ,'iw');
	indexing_kv('values','v','relation','ir');
	% Sort the keys by number:
	if ~isempty(OSMDATA.keys)
		[~,I]						= sort([OSMDATA.keys.N],'descend');
		OSMDATA.keys			= OSMDATA.keys(I,1);
	else
		OSMDATA.keys.k			= '';
		OSMDATA.keys.N			= [];
		OSMDATA.keys.in		= [];
		OSMDATA.keys.iw		= [];
		OSMDATA.keys.ir		= [];
		OSMDATA.keys.int		= [];
		OSMDATA.keys.iwt		= [];
		OSMDATA.keys.irt		= [];
	end
	% Sort the values by number:
	if ~isempty(OSMDATA.values)
		[~,I]						= sort([OSMDATA.values.N],'descend');
		OSMDATA.values			= OSMDATA.values(I,1);
	else
		OSMDATA.values.v		= '';
		OSMDATA.values.N		= [];
		OSMDATA.values.in		= [];
		OSMDATA.values.iw		= [];
		OSMDATA.values.ir		= [];
		OSMDATA.values.int	= [];
		OSMDATA.values.iwt	= [];
		OSMDATA.values.irt	= [];
	end
	
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	
	%------------------------------------------------------------------------------------------------------------------
	% sort the tags by the number of their appearance
	%------------------------------------------------------------------------------------------------------------------
	
	if sort_the_tags
		
		% Prepare the waitbar:
		WAITBAR.i			= 7;
		WAITBAR.k			= 0;
		WAITBAR.kmax		= max(1,inmax+iwmax+irmax);
		WAITBAR.t0_phase	= clock;
		
		% sort the tags of the nodes:
		for in=1:inmax
			
			% Waitbar:
			WAITBAR.k	= WAITBAR.k+1;
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1	= clock;
				x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
				t_remaining	= etime(WAITBAR.t1,WAITBAR.t0)*(1-x)/x;		% remaining time as number of seconds
				t_end			= datenum(WAITBAR.t1)+t_remaining/86400;		% end time as fractional number of days
				msg			= sprintf([...
					'Sorting tags %1.0f/%1.0f ...   /   ',...
					'Estimated remaining time: %s   /   ',...
					'Estimated end time: %s'],...
					in,inmax+iwmax+irmax,...
					dt_string(t_remaining),...
					datestr(t_end,WAITBAR.formatOut));
				set(GV_H.patch_waitbar,'XData',[0 x x 0]);
				set(GV_H.text_waitbar,'String',msg);
				drawnow;
			end
			
			if isfield(OSMDATA.node(1,in),'tag')
				if ~ismissing(OSMDATA.node(1,in).tag(1,1))
					% Sort the tags by the number of appearance of the keys:
					N	= zeros(size(OSMDATA.node(1,in).tag));
					for int=1:size(OSMDATA.node(1,in).tag,2)
						for ik=1:size(OSMDATA.keys,1)
							if strcmp(OSMDATA.node(1,in).tag(1,int).k,OSMDATA.keys(ik,1).k)
								N(1,int)	= N(1,int)+OSMDATA.keys(ik,1).N;
								break
							end
						end
					end
					[~,I]								= sort(N,'descend');
					OSMDATA.node(1,in).tag		= OSMDATA.node(1,in).tag(1,I);
					% Overwrite OSMDATA.keys(ik,1).int:
					for ik=1:size(OSMDATA.keys,1)
						i	= find(OSMDATA.keys(ik,1).in==in,1);
						if ~isempty(i)
							for int=1:size(OSMDATA.node(1,in).tag,2)
								if strcmp(OSMDATA.keys(ik,1).k,OSMDATA.node(1,in).tag(1,int).k)
									OSMDATA.keys(ik,1).int(1,i)	= int;
								end
							end
						end
					end
					% Overwrite OSMDATA.values(iv,1).int:
					for iv=1:size(OSMDATA.values,1)
						i	= find(OSMDATA.values(iv,1).in==in,1);
						if ~isempty(i)
							for int=1:size(OSMDATA.node(1,in).tag,2)
								if strcmp(OSMDATA.values(iv,1).v,OSMDATA.node(1,in).tag(1,int).v)
									OSMDATA.values(iv,1).int(1,i)	= int;
								end
							end
						end
					end
				end
			end
			
		end
		
		% sort the tags of the ways:
		for iw=1:iwmax
			
			% Waitbar:
			WAITBAR.k	= WAITBAR.k+1;
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1	= clock;
				x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
				t_remaining	= etime(WAITBAR.t1,WAITBAR.t0)*(1-x)/x;		% remaining time as number of seconds
				t_end			= datenum(WAITBAR.t1)+t_remaining/86400;		% end time as fractional number of days
				msg			= sprintf([...
					'Sorting tags %1.0f/%1.0f ...   /   ',...
					'Estimated remaining time: %s   /   ',...
					'Estimated end time: %s'],...
					inmax+iw,inmax+iwmax+irmax,...
					dt_string(t_remaining),...
					datestr(t_end,WAITBAR.formatOut));
				set(GV_H.patch_waitbar,'XData',[0 x x 0]);
				set(GV_H.text_waitbar,'String',msg);
				drawnow;
			end
			
			if isfield(OSMDATA.way(1,iw),'tag')
				if ~ismissing(OSMDATA.way(1,iw).tag(1,1))
					% Sort the tags by the number of appearance of the keys:
					N	= zeros(size(OSMDATA.way(1,iw).tag));
					for iwt=1:size(OSMDATA.way(1,iw).tag,2)
						for ik=1:size(OSMDATA.keys,1)
							if strcmp(OSMDATA.way(1,iw).tag(1,iwt).k,OSMDATA.keys(ik,1).k)
								N(1,iwt)	= N(1,iwt)+OSMDATA.keys(ik,1).N;
								break
							end
						end
					end
					[~,I]								= sort(N,'descend');
					OSMDATA.way(1,iw).tag		= OSMDATA.way(1,iw).tag(1,I);
					% Overwrite OSMDATA.keys(ik,1).iwt:
					for ik=1:size(OSMDATA.keys,1)
						i	= find(OSMDATA.keys(ik,1).iw==iw,1);
						if ~isempty(i)
							for iwt=1:size(OSMDATA.way(1,iw).tag,2)
								if strcmp(OSMDATA.keys(ik,1).k,OSMDATA.way(1,iw).tag(1,iwt).k)
									OSMDATA.keys(ik,1).iwt(1,i)	= iwt;
								end
							end
						end
					end
					% Overwrite OSMDATA.values(iv,1).iwt:
					for iv=1:size(OSMDATA.values,1)
						i	= find(OSMDATA.values(iv,1).iw==iw,1);
						if ~isempty(i)
							for iwt=1:size(OSMDATA.way(1,iw).tag,2)
								if strcmp(OSMDATA.values(iv,1).v,OSMDATA.way(1,iw).tag(1,iwt).v)
									OSMDATA.values(iv,1).iwt(1,i)	= iwt;
								end
							end
						end
					end
				end
			end
			
		end
		
		% sort the tags of the relations:
		for ir=1:irmax
			
			% Waitbar:
			WAITBAR.k	= WAITBAR.k+1;
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1	= clock;
				x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
				t_remaining	= etime(WAITBAR.t1,WAITBAR.t0)*(1-x)/x;		% remaining time as number of seconds
				t_end			= datenum(WAITBAR.t1)+t_remaining/86400;		% end time as fractional number of days
				msg			= sprintf([...
					'Sorting tags %1.0f/%1.0f ...   /   ',...
					'Estimated remaining time: %s   /   ',...
					'Estimated end time: %s'],...
					inmax+iwmax+ir,inmax+iwmax+irmax,...
					dt_string(t_remaining),...
					datestr(t_end,WAITBAR.formatOut));
				set(GV_H.patch_waitbar,'XData',[0 x x 0]);
				set(GV_H.text_waitbar,'String',msg);
				drawnow;
			end
			
			if isfield(OSMDATA.relation(1,ir),'tag')
				if ~ismissing(OSMDATA.relation(1,ir).tag(1,1))
					% Sort the tags by the number of appearance of the keys:
					N	= zeros(size(OSMDATA.relation(1,ir).tag));
					for irt=1:size(OSMDATA.relation(1,ir).tag,2)
						for ik=1:size(OSMDATA.keys,1)
							if strcmp(OSMDATA.relation(1,ir).tag(1,irt).k,OSMDATA.keys(ik,1).k)
								N(1,irt)	= N(1,irt)+OSMDATA.keys(ik,1).N;
								break
							end
						end
					end
					[~,I]									= sort(N,'descend');
					OSMDATA.relation(1,ir).tag		= OSMDATA.relation(1,ir).tag(1,I);
					% Overwrite OSMDATA.keys(ik,1).irt:
					for ik=1:size(OSMDATA.keys,1)
						i	= find(OSMDATA.keys(ik,1).ir==ir,1);
						if ~isempty(i)
							for irt=1:size(OSMDATA.relation(1,ir).tag,2)
								if strcmp(OSMDATA.keys(ik,1).k,OSMDATA.relation(1,ir).tag(1,irt).k)
									OSMDATA.keys(ik,1).irt(1,i)	= irt;
								end
							end
						end
					end
					% Overwrite OSMDATA.values(iv,1).irt:
					for iv=1:size(OSMDATA.values,1)
						i	= find(OSMDATA.values(iv,1).ir==ir,1);
						if ~isempty(i)
							for irt=1:size(OSMDATA.relation(1,ir).tag,2)
								if strcmp(OSMDATA.values(iv,1).v,OSMDATA.relation(1,ir).tag(1,irt).v)
									OSMDATA.values(iv,1).irt(1,i)	= irt;
								end
							end
						end
					end
				end
			end
			
		end
		
		% Execution time of the current phase:
		WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
		
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Open or clear map figure
	%------------------------------------------------------------------------------------------------------------------
	create_map_figure;
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Show the nodes and ways for testing purposes
	%------------------------------------------------------------------------------------------------------------------
	
	if testplot==1
		% ifs_tb: Index of the tile base filter settings in ELE.elefiltset.
		color_prio_v		= [PP.color.prio];
		icol_tilebase		= find(color_prio_v==0,1);
		icolspec_tilebase	= PP.color(icol_tilebase,1).spec;		% should be =1
		ifs_tb				= ELE.ifs_v(icolspec_tilebase,1);
		hf		= figure(200001);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha		= axes;
		hold(ha,'on');
		set(hf,'Name','open_osm: nodes ways');
		set(hf,'NumberTitle','off');
		title(sprintf('nodes and ways\n%s',GV.osm_pathfilename),'Interpreter','none');
		plot(ha,[...
			OSMDATA.bounds.xmin_mm ...
			OSMDATA.bounds.xmax_mm ...
			OSMDATA.bounds.xmax_mm ...
			OSMDATA.bounds.xmin_mm ...
			OSMDATA.bounds.xmin_mm],[...
			OSMDATA.bounds.ymin_mm ...
			OSMDATA.bounds.ymin_mm ...
			OSMDATA.bounds.ymax_mm ...
			OSMDATA.bounds.ymax_mm ...
			OSMDATA.bounds.ymin_mm],'-g');
		plot(ha,[...
			ELE.elefiltset(ifs_tb,1).xmin_mm ...
			ELE.elefiltset(ifs_tb,1).xmax_mm ...
			ELE.elefiltset(ifs_tb,1).xmax_mm ...
			ELE.elefiltset(ifs_tb,1).xmin_mm ...
			ELE.elefiltset(ifs_tb,1).xmin_mm],[...
			ELE.elefiltset(ifs_tb,1).ymin_mm ...
			ELE.elefiltset(ifs_tb,1).ymin_mm ...
			ELE.elefiltset(ifs_tb,1).ymax_mm ...
			ELE.elefiltset(ifs_tb,1).ymax_mm ...
			ELE.elefiltset(ifs_tb,1).ymin_mm],'-m');
		for iw=1:iwmax
			plot(ha,OSMDATA.way(1,iw).x_mm,OSMDATA.way(1,iw).y_mm,'-b');
		end
		plot(ha,OSMDATA.node_x_mm,OSMDATA.node_y_mm,'.r');
		xlabel(ha,'x / mm');
		ylabel(ha,'x / mm');
		axis(ha,'equal');
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Display state
	%------------------------------------------------------------------------------------------------------------------
	
	% Execution time:
	t_end_statebusy					= clock;
	dt_statebusy						= etime(t_end_statebusy,t_start_statebusy);
	dt_statebusy_str					= dt_string(dt_statebusy);
	if   ~APP.LoadSettingsOnlyOSMboundariesMenu.Checked&&...
			APP.LoadSettingsElevationDataMenu.Checked
		if dt_statebusy>GV.exec_time.open_osm.dt
			GV.exec_time.open_osm.name			= APP.LoadOSMandElevationDataMenu.Text;
			GV.exec_time.open_osm.t_start		= t_start_statebusy;
			GV.exec_time.open_osm.t_end		= t_end_statebusy;
			GV.exec_time.open_osm.dt			= dt_statebusy;
			GV.exec_time.open_osm.dt_str		= dt_statebusy_str;
		end
	end
	fprintf(1,'Execution time (h:m:s): %s\n',dt_statebusy_str);
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Autosave
	%------------------------------------------------------------------------------------------------------------------
	
	if    ~APP.LoadSettingsDoNotLoadElevationDataMenu.Checked&&...
			~APP.LoadSettingsOnlyOSMboundariesMenu.Checked
		% Save only, if the complete data is loaded:
		filename_add			= ' - after load osm ele data';
		[map_filename,~,~]	= filenames_savefiles(filename_add);
		set(GV_H.text_waitbar,'String',sprintf('Autosave "%s"',map_filename));
		save_project(0,filename_add);
	end
	
	% Reset waitbar:
	set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
	set(GV_H.text_waitbar,'String','');
	drawnow;
	
	% Display state:
	display_on_gui('state',...
		sprintf('Load OSM and elevation data ... done (%s).',dt_statebusy_str),...
		'notbusy','replace');
	
catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
% Adds the fields "keys" and "values" to the structure OSMDATA
%------------------------------------------------------------------------------------------------------------------

function indexing_kv(fn_keyval,fn_kv,fn_nwr,fn_inwr)
% Syntax:
% indexing_kv('keys'  ,'k','node'    ,'in');			-->	fn_keyval='keys'
% indexing_kv('keys'  ,'k','way'     ,'iw');					fn_kv    ='k'
% indexing_kv('keys'  ,'k','relation','ir');					fn_nwr   ='node'
% indexing_kv('values','v','node'    ,'in');					fn_inwr  ='in'
% indexing_kv('values','v','way'     ,'iw');
% indexing_kv('values','v','relation','ir');

global OSMDATA WAITBAR GV GV_H

try
	
	switch fn_keyval
		case 'keys'
			fn_kv_no	= 'keys_no';
		case 'values'
			fn_kv_no	= 'values_no';
	end
	
	di_sort	= 50;		% after this number of loops the keys/values will be sorted anew for faster comparing
	inwrmax	= size(OSMDATA.(fn_nwr),2);
	fn_inwrt	= [fn_inwr 't'];
	for inwr=1:inwrmax
		
		% Waitbar:
		WAITBAR.k	= WAITBAR.k+1;
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
			t_remaining	= etime(WAITBAR.t1,WAITBAR.t0)*(1-x)/x;		% remaining time as number of seconds
			t_end			= datenum(WAITBAR.t1)+t_remaining/86400;		% end time as fractional number of days
			msg			= sprintf([...
				'Indexing keys and values: %1.0f/%1.0f ...   /   ',...
				'Estimated remaining time: %s   /   ',...
				'Estimated end time: %s'],...
				inwr,inwrmax,...
				dt_string(t_remaining),...
				datestr(t_end,WAITBAR.formatOut));
			set(GV_H.patch_waitbar,'XData',[0 x x 0]);
			set(GV_H.text_waitbar,'String',msg);
			drawnow;
		end
		
		if OSMDATA.istag.(fn_nwr)(1,inwr)
			for itag=1:size(OSMDATA.(fn_nwr)(1,inwr).tag,2)
				kv_string	= OSMDATA.(fn_nwr)(1,inwr).tag(1,itag).(fn_kv);
				kv_no	= uint64(length(kv_string))+1000*sum(uint64(kv_string));			% 7.110 / 0.094
				% kv_no	= length(kv_string)+10000*sum(uint64(kv_string).*uint64(1:length(kv_string)));		% 14.119s
				% kv_no	= uint64(length(kv_string))+1000*sum(uint64(kv_string).*uint64(10*(1:length(kv_string))));		%
				% kv_no	= uint64(length(kv_string))+1000*sum(uint64(kv_string).*uint64(2.^(1:length(kv_string))));		% 8.454 s) / 0.99
				ikmax	= size(OSMDATA.(fn_keyval),1);
				if ikmax==0
					ik		= 1;
				else
					% The calculated number kv_no is not unique, maybe different texts have the same number:
					ik_v	= find(OSMDATA.(fn_kv_no)==kv_no);
					if isempty(ik_v)
						ik		= size(OSMDATA.(fn_keyval),1)+1;
					else
						ik		= [];
						for i_ik_v=1:length(ik_v)
							if strcmp(kv_string,OSMDATA.(fn_keyval)(ik_v(i_ik_v),1).(fn_kv))
								% The key or value character array kv_string already exists at position ik_v(i_ik_v):
								ik		= ik_v(i_ik_v);
								break
							end
						end
						if isempty(ik)
							% At least one other character array has the same number as kv_string, kv_string is new:
							ik		= size(OSMDATA.(fn_keyval),1)+1;
						end
					end
				end
				if ik>ikmax
					% new key string:
					OSMDATA.(fn_keyval)(ik,1).(fn_kv)	= kv_string;
					OSMDATA.(fn_keyval)(ik,1).N			= 0;
					OSMDATA.(fn_keyval)(ik,1).in			= [];
					OSMDATA.(fn_keyval)(ik,1).iw			= [];
					OSMDATA.(fn_keyval)(ik,1).ir			= [];
					OSMDATA.(fn_keyval)(ik,1).int			= [];
					OSMDATA.(fn_keyval)(ik,1).iwt			= [];
					OSMDATA.(fn_keyval)(ik,1).irt			= [];
					OSMDATA.(fn_kv_no)(ik,1)				= kv_no;
				end
				OSMDATA.(fn_keyval)(ik,1).N				= OSMDATA.(fn_keyval)(ik,1).N+1;
				OSMDATA.(fn_keyval)(ik,1).(fn_inwr)		= [OSMDATA.(fn_keyval)(ik,1).(fn_inwr)  inwr];
				OSMDATA.(fn_keyval)(ik,1).(fn_inwrt)	= [OSMDATA.(fn_keyval)(ik,1).(fn_inwrt) itag];
			end
		end
	end
	
	% Sort the keys/values by number:
	if ~isempty(OSMDATA.(fn_keyval))
		[~,I]					= sort([OSMDATA.(fn_keyval).N],'descend');
		OSMDATA.(fn_keyval)	= OSMDATA.(fn_keyval)(I,1);
		OSMDATA.(fn_kv_no)	= OSMDATA.(fn_kv_no)(I,1);
	end
	
catch ME
	errormessage('',ME);
end

