function [lonv,latv,elem]=open_ele(ele_pathname_source,ele_pathname_destination)
% Loads all elevation data files in the directory ele_pathname_source and collects the data in the matrix elem.
% If the points per degree values in the loaded files differ, the result is interpolated to the highest resolution.
% Missing data is filled with nans.
%
% Variables:
% lonv		1xn longitude vector
% latv		mx1 latitude vector
% elem		mxn elevation data matrix
% ele_pathname_source			pathname of the source files
%										The ele_pathname_source directory may only contain elevation data.
% ele_pathname_destination		pathname of the destination *.mat file
%										(optional)
%
% Syntax:
% 1)	Select a source and destination directory and convert the source files to the mat format:
%		open_ele;
% 2)	Only load the files in ele_pathname_source (call from open_osm.m):
%		[lonv,latv,elem]=open_ele(ele_pathname_source);

global GV GV_H WAITBAR SETTINGS APP PP

try
	
	% Display state:
	if nargin==0
		text_disp_on_gui	= 'Convert elevation data';
	else
		text_disp_on_gui	= 'Load elevation data';
	end
	stateisbusy				= display_on_gui('state','','isbusy');
	if ~stateisbusy
		t_start_statebusy	= clock;
		display_on_gui('state',sprintf('%s ...',text_disp_on_gui),'busy','add');
	end
	
	% Initializations:
	if nargin<1
		ele_pathname_source	= '';
	else
		if ~strcmp(ele_pathname_source(end),'\')
			ele_pathname_source	= [ele_pathname_source '\'];
		end
	end
	if nargin<2
		ele_pathname_destination	= '';
	else
		if ~strcmp(ele_pathname_destination(end),'\')
			ele_pathname_destination	= [ele_pathname_destination '\'];
		end
	end
	tol								= 1e-10;
	lonv								= [];
	latv								= [];
	elem								= [];
	WAITBAR.i						= 2;					% Prepare the waitbar for open_osm.m
	WAITBAR.k						= 0;
	WAITBAR.t0_phase				= clock;
	if nargin==0
		WAITBAR.i						= 1;				% Prepare the waitbar (no call from open_osm.m)
		WAITBAR.dx						= 1;
		WAITBAR.x0						= 0;
		WAITBAR.t0						= clock;
		WAITBAR.t1						= clock;
		WAITBAR.formatOut				= 'HH:MM:SS';
	end
	
	% Testing:
	testing				= 0;
	if testing~=0
		testplot	= 0;
		testout	= 1;
		data_no	= 10;
		switch data_no
			case 1		% 1.03s
				ele_pathname_source			= 'C:\Daten\MapLab3D\Elevation\MAHD_SRTM\';
				ele_pathname_destination	= 'C:\Daten\MapLab3D\Elevation\MAHD_MAT\';
			case 2		% 50.97s		Loading and saving with repairing
				ele_pathname_source			= 'C:\Daten\MapLab3D\Elevation\BW_Sued_SRTM\';
				ele_pathname_destination	= 'C:\Daten\MapLab3D\Elevation\BW_Sued_MAT\';
			case 3		% 12.45		Loading and saving the same data as mat is faster.
				ele_pathname_source			= 'C:\Daten\MapLab3D\Elevation\BW_Sued_MAT\';
				ele_pathname_destination	= 'C:\Daten\MapLab3D\Elevation\Test\';
			case 4		% 39.54s		Loading without saving with repairing
				ele_pathname_source			= 'C:\Daten\MapLab3D\Elevation\BW_Sued_SRTM\';
				ele_pathname_destination	= '';
			case 5		% 1.14		Loading without saving the same data as mat is faster.
				ele_pathname_source			= 'C:\Daten\MapLab3D\Elevation\BW_Sued_MAT\';
				ele_pathname_destination	= '';
			case 10		%
				ele_pathname_source			= 'C:\Daten\MapLab3D\Elevation\Test_SRTM\';
				ele_pathname_destination	= 'C:\Daten\MapLab3D\Elevation\Test\';
		end
	else
		testplot	= 0;
		testout	= 0;
	end
	
	% Ask for the source pathname:
	if (nargin==0)&&isempty(ele_pathname_source)
		ele_pathname_source					= SETTINGS.conv_ele_pathname_source;
		if exist(ele_pathname_source,'dir')~=7
			% The directory does not exist:
			ele_pathname_source				= SETTINGS.default_pathname;
		end
		figure(APP.MapLab3D);	% This is a test to prevent the uiget window from being opened behind another window.
		ele_pathname_source					= uigetdir_local(ele_pathname_source,...
			'Select the elevation source data directory');
		figure(APP.MapLab3D);	% This brings the app figure to the foreground.
		if isequal(ele_pathname_source,0)
			display_on_gui('state',...
				sprintf('%s ... canceled (%s).',text_disp_on_gui,dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
			set(GV_H.text_waitbar,'String','');
			drawnow;
			return
		end
		if ~strcmp(ele_pathname_source(end),'\')
			ele_pathname_source	= [ele_pathname_source '\'];
		end
	end
	
	% Ask for the destination pathname:
	if (nargin==0)&&isempty(ele_pathname_destination)
		ele_pathname_destination					= SETTINGS.conv_ele_pathname_destination;
		if exist(ele_pathname_destination,'dir')~=7
			% The directory does not exist:
			ele_pathname_destination				= SETTINGS.default_pathname;
		end
		if strcmp(ele_pathname_destination,SETTINGS.default_pathname)
			k		= strfind(ele_pathname_source,'\');
			if length(k)>=2
				ele_pathname_destination	= ele_pathname_source(1:k(end-1));
				
			end
		end
		figure(APP.MapLab3D);	% This is a test to prevent the uiget window from being opened behind another window.
		ele_pathname_destination					= uigetdir_local(ele_pathname_destination,...
			'Select the elevation destination data directory');
		figure(APP.MapLab3D);	% This brings the app figure to the foreground.
		if isequal(ele_pathname_destination,0)
			display_on_gui('state',...
				sprintf('%s ... canceled (%s).',text_disp_on_gui,dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
			set(GV_H.text_waitbar,'String','');
			drawnow;
			return
		end
		if ~strcmp(ele_pathname_destination(end),'\')
			ele_pathname_destination	= [ele_pathname_destination '\'];
		end
	end
	
	% Save the user inputs:
	SETTINGS.conv_ele_pathname_source		= ele_pathname_source;
	SETTINGS.conv_ele_pathname_destination	= ele_pathname_destination;
	set_settings('save');
	
	% Extract bounding box:
	lonmin_degree	= -180;
	lonmax_degree	= 180;
	latmin_degree	= -90;
	latmax_degree	= 90;
	N_extra_points	= 100;
	if (nargin==0)&&APP.Convert_GeoRasterDataSettings_ExtractBB_Menu.Checked
		if APP.Convert_GeoRasterDataSettings_CrIndFiles_Menu.Checked
			% Create individual files: Extraction of a bounding box is not possible:
			errormessage(sprintf([...
				'Extraction of a bounding box is not\n',...
				'possible when creating individual files.\n',...
				'Select either "%s"\n',...
				'or select "%s".'],...
				APP.Convert_GeoRasterDataSettings_WholeArea_Menu.Text,...
				APP.Convert_GeoRasterDataSettings_CrSFile_Menu.Text));
		else
			% Create a single file: Ask for the bounding box:
			if ~isempty(GV.open_ele.definput_bb)
				lonmin_degree	= GV.open_ele.definput_bb{1,1};
				lonmax_degree	= GV.open_ele.definput_bb{2,1};
				latmin_degree	= GV.open_ele.definput_bb{3,1};
				latmax_degree	= GV.open_ele.definput_bb{4,1};
				N_extra_points	= GV.open_ele.definput_bb{5,1};
			elseif ~isempty(PP)
				lonmin_degree	= PP.general.bounding_box.lonmin_degree;
				lonmax_degree	= PP.general.bounding_box.lonmax_degree;
				latmin_degree	= PP.general.bounding_box.latmin_degree;
				latmax_degree	= PP.general.bounding_box.latmax_degree;
				if ~isempty(GV.open_ele.definput_bb)
					N_extra_points	= GV.open_ele.definput_bb{5,1};
				else
					N_extra_points	= 100;
				end
			end
			definput		= {...
				sprintf('%3.15g',lonmin_degree);...
				sprintf('%3.15g',lonmax_degree);...
				sprintf('%3.15g',latmin_degree);...
				sprintf('%3.15g',latmax_degree);...
				sprintf('%g',N_extra_points)};
			prompt		= {...
				'Longitude of the left edge of the bounding box (default -180°)';...
				'Longitude of the right edge of the bounding box (default 180°)';...
				'Latitude of the bottom edge of the bounding box (default -90°)';...
				'Latitude of the top edge of the bounding box (default 90°)';...
				'Number of additional sampling points on all sides'};
			dlgtitle		= 'Enter bounding box limits';
			warntext		= 'xxxxx';
			while ~isempty(warntext)
				answer		= inputdlg_local(prompt,dlgtitle,1,definput);
				if size(answer,1)~=5
					display_on_gui('state',...
						sprintf('%s ... canceled (%s).',text_disp_on_gui,dt_string(etime(clock,t_start_statebusy))),...
						'notbusy','replace');
					set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
					set(GV_H.text_waitbar,'String','');
					drawnow;
					return
				end
				warntext		= '';
				if    ~isempty(strfind(answer{1,1},','))||...
						~isempty(strfind(answer{2,1},','))||...
						~isempty(strfind(answer{3,1},','))||...
						~isempty(strfind(answer{4,1},','))||...
						~isempty(strfind(answer{5,1},','))
					warntext	= sprintf([...
						'Error:\n',...
						'Invalid character '',''.\n',...
						'Use the decimal point ''.'' as decimal separator .']);
				else
					lonmin_degree	= str2double(answer{1,1});
					lonmax_degree	= str2double(answer{2,1});
					latmin_degree	= str2double(answer{3,1});
					latmax_degree	= str2double(answer{4,1});
					N_extra_points	= str2double(answer{5,1});
					if    isnan(lonmin_degree )||...
							isnan(lonmax_degree )||...
							isnan(latmin_degree )||...
							isnan(latmax_degree )||...
							isnan(N_extra_points)
						warntext	= sprintf([...
							'Error:\n',...
							'Invalid longitude and/or latitude.\n',...
							'You must enter four numbers.']);
					end
				end
				if ~isempty(warntext)
					if isfield(GV_H.warndlg,'open_ele')
						if ishandle(GV_H.warndlg.open_ele)
							close(GV_H.warndlg.open_ele);
						end
					end
					warntext	= sprintf('%s\nPress OK to repeat.',warntext);
					GV_H.warndlg.open_ele		= warndlg(warntext,'Warning');
					GV_H.warndlg.open_ele.Tag	= 'maplab3d_figure';
					while ishandle(GV_H.warndlg.open_ele)
						pause(0.2);
					end
				end
			end
			lonmin_degree					= round(lonmin_degree,10);
			lonmax_degree					= round(lonmax_degree,10);
			latmin_degree					= round(latmin_degree,10);
			latmax_degree					= round(latmax_degree,10);
			N_extra_points					= round(N_extra_points);
			GV.open_ele.definput_bb		= {...
				lonmin_degree;...
				lonmax_degree;...
				latmin_degree;...
				latmax_degree;...
				N_extra_points};
		end
	end
	
	% Initialize the resolution:
	if (nargin==0)&&APP.Convert_GeoRasterDataSettings_SetRes_Menu.Checked
		% Ask for the resolution:
		prompt		= {...
			'Enter the number of points per degree of longitude:';...
			'Enter the number of points per degree of latitude:'};
		dlgtitle		= 'Enter the resolution';
		definput		= {...
			num2str(GV.open_ele.definput_res{1,1});...			% ppdlon
			num2str(GV.open_ele.definput_res{2,1})};				% ppdlat
		warntext		= 'xxxxx';
		while ~isempty(warntext)
			answer		= inputdlg_local(prompt,dlgtitle,1,definput);
			if size(answer,1)~=2
				display_on_gui('state',...
					sprintf('%s ... canceled (%s).',text_disp_on_gui,dt_string(etime(clock,t_start_statebusy))),...
					'notbusy','replace');
				set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
				set(GV_H.text_waitbar,'String','');
				drawnow;
				return
			end
			warntext		= '';
			ppdlon_0		= str2double(answer{1,1});
			ppdlat_0		= str2double(answer{2,1});
			if    ~isempty(strfind(answer{1,1},','))||...
					~isempty(strfind(answer{2,1},','))
				warntext	= sprintf([...
					'Error:\n',...
					'Invalid input: \n',...
					'The character '','' is not allowed.']);
			end
			if isempty(warntext)
				if    isnan(ppdlon_0)||...
						isnan(ppdlat_0)
					warntext	= sprintf([...
						'Error:\n',...
						'Invalid input: \n',...
						'You must enter numbers.']);
				end
			end
			if isempty(warntext)
				if    (abs(ppdlon_0-round(ppdlon_0))>GV.tol_1)||...
						(abs(ppdlat_0-round(ppdlat_0))>GV.tol_1)
					warntext	= sprintf([...
						'Error:\n',...
						'Invalid input: \n',...
						'You must enter whole numbers.']);
				end
			end
			if ~isempty(warntext)
				if isfield(GV_H.warndlg,'open_ele')
					if ishandle(GV_H.warndlg.open_ele)
						close(GV_H.warndlg.open_ele);
					end
				end
				warntext	= sprintf('%s\nPress OK to repeat.',warntext);
				GV_H.warndlg.open_ele		= warndlg(warntext,'Warning');
				GV_H.warndlg.open_ele.Tag	= 'maplab3d_figure';
				while ishandle(GV_H.warndlg.open_ele)
					pause(0.2);
				end
			end
		end
		GV.open_ele.definput_res{1,1}	= ppdlon_0;					% Points per degree: lon
		GV.open_ele.definput_res{2,1}	= ppdlat_0;					% Points per degree: lat
		SampleSpacingInLongitude_0		= 1/ppdlon_0;
		SampleSpacingInLatitude_0		= 1/ppdlat_0;
	else
		% Use the highest available resolution:
		ppdlon_0								= [];							% Points per degree: lon
		ppdlat_0								= [];							% Points per degree: lat
		SampleSpacingInLongitude_0		= [];
		SampleSpacingInLatitude_0		= [];
	end
	ppdlon								= ppdlon_0;							% Points per degree: lon
	ppdlat								= ppdlat_0;							% Points per degree: lat
	SampleSpacingInLongitude		= SampleSpacingInLongitude_0;
	SampleSpacingInLatitude			= SampleSpacingInLatitude_0;
	
	% Get all files in ele_pathname_source and sort them by relevance if "Extract bounding box" is enabled:
	listing				= dir(ele_pathname_source);
	if (nargin==0)&&APP.Convert_GeoRasterDataSettings_ExtractBB_Menu.Checked
		dist_bb_center_v	= 1e20*ones(length(listing),1);
		for k_listing=1:length(listing)
			dist_bb_center		= get_dist_bb_center(...
				listing(k_listing).name,...
				lonmin_degree,...
				lonmax_degree,...
				latmin_degree,...
				latmax_degree);
			if isscalar(dist_bb_center)
				dist_bb_center_v(k_listing,1)		= dist_bb_center;
			end
		end
		[~,ksort_listing]		= sort(dist_bb_center_v);
		listing					= listing(ksort_listing,:);
	end
	
	% Read all files in ele_pathname_source and collect the elevation data in the variable elem:
	WAITBAR.kmax			= max(1,length(listing));
	continue_load_ele		= true;
	k_listing				= 0;
	while (k_listing<length(listing))&&continue_load_ele
		k_listing			= k_listing+1;
		if listing(k_listing).isdir==0
			ele_filename_source	= listing(k_listing).name;
			if testout==1
				fprintf(1,'File %s\n',ele_filename_source);
			end
			
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1	= clock;
				x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*k_listing/WAITBAR.kmax;
				t_remaining	= etime(WAITBAR.t1,WAITBAR.t0)*(1-x)/x;		% remaining time as number of seconds
				t_end			= datenum(WAITBAR.t1)+t_remaining/86400;		% end time as fractional number of days
				msg			= sprintf([...
					'Reading %s ...   /   ',...
					'Estimated remaining time: %s   /   ',...
					'Estimated end time: %s'],...
					ele_filename_source,...
					dt_string(t_remaining),...
					datestr(t_end,WAITBAR.formatOut));
				set(GV_H.patch_waitbar,'XData',[0 x x 0]);
				set(GV_H.text_waitbar,'String',msg);
				drawnow;
			end
			
			% Load elevation data:
			% Example:
			% size(A) =  [3601 3601]
			% R =
			%   GeographicPostingsReference with properties:
			%
			%               LatitudeLimits: [49 50]
			%              LongitudeLimits: [8 9]
			%                   RasterSize: [3601 3601]
			%         RasterInterpretation: 'postings'
			%             ColumnsStartFrom: 'north'
			%                RowsStartFrom: 'west'
			%      SampleSpacingInLatitude: 1/3600
			%     SampleSpacingInLongitude: 1/3600
			%       RasterExtentInLatitude: 1
			%      RasterExtentInLongitude: 1
			%             XIntrinsicLimits: [1 3601]
			%             YIntrinsicLimits: [1 3601]
			%         CoordinateSystemType: 'geographic'
			%                GeographicCRS: [1×1 geocrs]
			%                    AngleUnit: 'degree'
			try
				if strcmp(ele_filename_source((end-3):end),'.mat')
					load([ele_pathname_source ele_filename_source]);		% Variables: A, R
				else
					[A,R] = readgeoraster([ele_pathname_source ele_filename_source]);
					A		= double(A);
				end
			catch ME
				errortext	= sprintf([...
					'The selected directory\n',...
					'%s\n',...
					'may only contain:\n',...
					'1) MapLab3D elevation data (MapLab3D_Ele_*.mat) or\n',...
					'2) Geospatial raster data.\n',...
					'   Supported file formats include: GeoTIFF, DTED,\n',...
					'   Esri Binary Grid and Esri GridFloat.\n',...
					'   For a full list of supported formats see\n',...
					'   MATLAB-function "readgeoraster".'],...
					ele_pathname_source);
				errormessage(errortext,ME);
			end
			if ~strcmp(R.AngleUnit,'degree')
				errortext	= sprintf([...
					'Error in %s%s:\n',...
					'The angle unit is ''%s'', but must be ''degree''.'],...
					ele_pathname_source,ele_filename_source,R.AngleUnit);
				errormessage(errortext);
			end
			if strcmp(R.ColumnsStartFrom,'north')
				% invert latitude-order:
				A		= A((end:-1:1),:);
			end
			if strcmp(R.RowsStartFrom,'east')
				% invert longitude-order:
				A		= A(:,(end:-1:1));
			end
			
			% Repair corrupt data:
			lonv_file	= (...
				round(R.LongitudeLimits(1),10):...
				R.SampleSpacingInLongitude :...
				round(R.LongitudeLimits(2),10));		% one row
			latv_file	= (...
				round(R.LatitudeLimits(1),10) :...
				R.SampleSpacingInLatitude  :...
				round(R.LatitudeLimits(2),10))';		% one colummn
			if any(A==-32767,'all')
				% There is corrupt data:
				[lonm_file,latm_file]	= meshgrid(lonv_file,latv_file);
				set(GV_H.text_waitbar,'String',sprintf('Repairing %s, this may take some time ... ',...
					ele_filename_source));
				drawnow;
				k_nodata		= find(A==-32767);
				k_data		= find(A~=-32767);
				A(k_nodata)	= griddata(...
					lonm_file(k_data),...
					latm_file(k_data),...
					A(k_data),...
					lonm_file(k_nodata),...
					latm_file(k_nodata),...
					'linear');
			end
			if testplot==1
				[lonm_file,latm_file]	= meshgrid(lonv_file,latv_file);
				hf		= figure(32548901);
				clf(hf,'reset');
				set(hf,'Tag','maplab3d_figure');
				ha		= axes;
				hold(ha,'on');
				set(hf,'Name','open_ele: elem');
				set(hf,'NumberTitle','off');
				title(ha,sprintf('Elevation after repairing: %s\nLon %g ppd / Lat %g ppd',...
					ele_filename_source,...
					1/R.SampleSpacingInLongitude,...
					1/R.SampleSpacingInLatitude),'Interpreter','none');
				s=surf(lonm_file,latm_file,A);
				s.EdgeAlpha		= 0;
				xlabel(ha,'lon / deg');
				ylabel(ha,'lat / deg');
				zlabel(ha,'z / m');
				cameratoolbar(hf,'Show');
				view(ha,3);
				drawnow;
				setbreakpoint=1;
			end
			
			% Interpolation of data from different files to an identical grid:
			lonv_new				= [];
			latv_new				= [];
			lonv_file_new		= [];
			latv_file_new		= [];
			% Spacing in longitude:
			if isempty(ppdlon)
				ppdlon							= 1/R.SampleSpacingInLongitude;
				SampleSpacingInLongitude	= R.SampleSpacingInLongitude;
			else
				if abs(ppdlon-1/R.SampleSpacingInLongitude)>tol
					% The grid of the current file or the previous files must be adapted:
					if 1/R.SampleSpacingInLongitude>ppdlon
						if APP.Convert_GeoRasterDataSettings_SetRes_Menu.Checked
							% The resolution in the current file is higher than the resolution set by the user:
							% Decrease the resolution of the current file:
							N					= round((lonv_file(end)-lonv_file(1))/SampleSpacingInLongitude);	% no of elements
							dlon				= (lonv_file(end)-lonv_file(1))/N;
							lonv_file_new	= (lonv_file(1):dlon:lonv_file(end));										% one row
						else
							% The resolution in the current file is higher than in the previous files:
							% Increase the resolution of the previous files:
							ppdlon							= 1/R.SampleSpacingInLongitude;
							SampleSpacingInLongitude	= R.SampleSpacingInLongitude;
							N					= round((lonv(end)-lonv(1))/SampleSpacingInLongitude);				% no of elements
							dlon				= (lonv(end)-lonv(1))/N;
							lonv_new			= (lonv(1):dlon:lonv(end));													% one row
						end
					else
						% The resolution in the current file is lower than in the previous files:
						% Increase the resolution of the current file:
						N					= round((lonv_file(end)-lonv_file(1))/SampleSpacingInLongitude);	% no of elements
						dlon				= (lonv_file(end)-lonv_file(1))/N;
						lonv_file_new	= (lonv_file(1):dlon:lonv_file(end));										% one row
					end
				end
			end
			% Spacing in latitude:
			if isempty(ppdlat)
				ppdlat							= 1/R.SampleSpacingInLatitude;
				SampleSpacingInLatitude		= R.SampleSpacingInLatitude;
			else
				if abs(ppdlat-1/R.SampleSpacingInLatitude)>tol
					% The grid of the current file or the previous files must be adapted:
					if 1/R.SampleSpacingInLatitude>ppdlat
						if APP.Convert_GeoRasterDataSettings_SetRes_Menu.Checked
							% The resolution in the current file is higher than the resolution set by the user:
							% Decrease the resolution of the current file:
							N					= round((latv_file(end)-latv_file(1))/SampleSpacingInLatitude);	% no of elements
							dlat				= (latv_file(end)-latv_file(1))/N;
							latv_file_new	= (latv_file(1):dlat:latv_file(end))';										% one colummn
						else
							% The resolution in the current file is higher than in the previous files:
							% Increase the resolution of the previous files:
							ppdlat						= 1/R.SampleSpacingInLatitude;
							SampleSpacingInLatitude	= R.SampleSpacingInLatitude;
							N					= round((latv(end)-latv(1))/SampleSpacingInLatitude);					% no of elements
							dlat				= (latv(end)-latv(1))/N;
							latv_new			= (latv(1):dlat:latv(end))';													% one colummn
						end
					else
						% The resolution in the current file is lower than in the previous files:
						% Increase the resolution of the current file:
						N					= round((latv_file(end)-latv_file(1))/SampleSpacingInLatitude);	% no of elements
						dlat				= (latv_file(end)-latv_file(1))/N;
						latv_file_new	= (latv_file(1):dlat:latv_file(end))';										% one colummn
					end
				end
			end
			% Interpolation of the previous files:
			if ~isempty(lonv_new)||~isempty(latv_new)
				if isempty(lonv_new)
					N						= round((lonv(end)-lonv(1))/SampleSpacingInLongitude);				% no of elements
					dlon					= (lonv(end)-lonv(1))/N;
					lonv_new				= (lonv(1):dlon:lonv(end));													% one row
				end
				if isempty(latv_new)
					N						= round((latv(end)-latv(1))/SampleSpacingInLatitude);					% no of elements
					dlat					= (latv(end)-latv(1))/N;
					latv_new				= (latv(1):dlat:latv(end))';													% one colummn
				end
				set(GV_H.text_waitbar,'String',sprintf('Interpolating, this may take some time ... '));
				[lonm    ,latm    ]	= meshgrid(lonv,latv);
				[lonm_new,latm_new]	= meshgrid(lonv_new,latv_new);
				elem						= interp2(...
					lonm,...					% coordinates of the sample points
					latm,...					% coordinates of the sample points
					elem,...					% function values at each sample point
					lonm_new,...			% query points
					latm_new,'linear');
				lonv						= lonv_new;
				latv						= latv_new;
			end
			% Interpolation of the current file data:
			if ~isempty(lonv_file_new)||~isempty(latv_file_new)
				if isempty(lonv_file_new)
					N					= round((lonv_file(end)-lonv_file(1))/SampleSpacingInLongitude);		% no of elements
					dlon				= (lonv_file(end)-lonv_file(1))/N;
					lonv_file_new	= (lonv_file(1):dlon:lonv_file(end));											% one row
				end
				if isempty(latv_file_new)
					N					= round((latv_file(end)-latv_file(1))/SampleSpacingInLatitude);		% no of elements
					dlat				= (latv_file(end)-latv_file(1))/N;
					latv_file_new	= (latv_file(1):dlat:latv_file(end))';											% one colummn
				end
				set(GV_H.text_waitbar,'String',sprintf('Interpolating, this may take some time ... '));
				[lonm_file    ,latm_file    ]	= meshgrid(lonv_file    ,latv_file    );
				[lonm_file_new,latm_file_new]	= meshgrid(lonv_file_new,latv_file_new);
				A						= interp2(...
					lonm_file,...			% coordinates of the sample points
					latm_file,...			% coordinates of the sample points
					A,...						% function values at each sample point
					lonm_file_new,...		% query points
					latm_file_new,'linear');
				lonv_file			= lonv_file_new;
				latv_file			= latv_file_new;
			end
			if testplot==1
				[lonm_file,latm_file]	= meshgrid(lonv_file,latv_file);
				hf		= figure(32548902);
				clf(hf,'reset');
				set(hf,'Tag','maplab3d_figure');
				ha		= axes;
				hold(ha,'on');
				set(hf,'Name','open_ele: elem');
				set(hf,'NumberTitle','off');
				title(ha,sprintf('Elevation after interpolation: %s\nLon %g ppd / Lat %g ppd',...
					ele_filename_source,...
					1/SampleSpacingInLongitude,...
					1/SampleSpacingInLatitude),'Interpreter','none');
				s=surf(lonm_file,latm_file,A);
				s.EdgeAlpha		= 0;
				xlabel(ha,'lon / deg');
				ylabel(ha,'lat / deg');
				zlabel(ha,'z / m');
				cameratoolbar(hf,'Show');
				view(ha,3);
				drawnow;
				setbreakpoint=1;
			end
			
			% Collect the data:
			if isempty(elem)
				lonv		= lonv_file;
				latv		= latv_file;
				elem		= A;
			else
				% Extend lonv at the start:
				extend_lonv	= (round(R.LongitudeLimits(1),10):SampleSpacingInLongitude:(lonv(1)-SampleSpacingInLongitude));
				if ~isempty(extend_lonv)
					lonv	= [extend_lonv lonv];
					elem	= [nan(size(elem,1),size(extend_lonv,2)) elem];
				end
				% Extend lonv at the end:
				extend_lonv	= ((lonv(end)+SampleSpacingInLongitude):SampleSpacingInLongitude:round(R.LongitudeLimits(2),10));
				if ~isempty(extend_lonv)
					lonv	= [lonv extend_lonv];
					elem	= [elem nan(size(elem,1),size(extend_lonv,2))];
				end
				% Extend latv at the start:
				extend_latv	= (round(R.LatitudeLimits(1),10):SampleSpacingInLatitude:(latv(1)-SampleSpacingInLatitude))';
				if ~isempty(extend_latv)
					latv	= [extend_latv;latv];
					elem	= [nan(size(extend_latv,1),size(elem,2));elem];
				end
				% Extend latv at the end:
				extend_latv	= ((latv(end)+SampleSpacingInLatitude):SampleSpacingInLatitude:round(R.LatitudeLimits(2),10))';
				if ~isempty(extend_latv)
					latv	= [latv;extend_latv];
					elem	= [elem;nan(size(extend_latv,1),size(elem,2))];
				end
				% Assign elem:
				[~,rmin]			= min(abs(latv-latv_file(  1)));
				[~,rmax]			= min(abs(latv-latv_file(end)));
				[~,cmin]			= min(abs(lonv-lonv_file(  1)));
				[~,cmax]			= min(abs(lonv-lonv_file(end)));
				r_v				= (rmin:rmax)';
				c_v				= (cmin:cmax)';
				elem(r_v,c_v)	= A;
				
			end
			
			% Cancel loading the files if the required area is already complete when extracting a bounding box:
			% ("Create individual files" and "Extract bounding box" cannot be active at the same time.)
			if (nargin==0)&&APP.Convert_GeoRasterDataSettings_ExtractBB_Menu.Checked
				if    (lonv(1,1)  >lonmin_degree)||...
						(lonv(1,end)<lonmax_degree)||...
						(latv(1,1)  >latmin_degree)||...
						(latv(end,1)<latmax_degree)
					% Der Bereich der Höhendaten ist noch kleiner als die bounding box: weitermachen.
				else
					k_lonmin						= find(lonv<=lonmin_degree,1,'last');
					k_lonmax						= find(lonv>=lonmax_degree,1,'first');
					k_latmin						= find(latv<=latmin_degree,1,'last');
					k_latmax						= find(latv>=latmax_degree,1,'first');
					if    ((k_lonmin-N_extra_points)<1           )||...
							((k_lonmax+N_extra_points)>size(lonv,2))||...
							((k_latmin-N_extra_points)<1           )||...
							((k_latmax+N_extra_points)>size(latv,1))
						% Der Bereich der Höhendaten ist noch kleiner als die um N_extra_points vergrößerte bounding box:
						% weitermachen.
					else
						% Der Bereich der Höhendaten ist größer als die um N_extra_points vergrößerte bounding box:
						k_lonmin		= k_lonmin-N_extra_points;
						k_lonmax		= k_lonmax+N_extra_points;
						k_latmin		= k_latmin-N_extra_points;
						k_latmax		= k_latmax+N_extra_points;
						if any(isnan(elem(k_latmin:k_latmax,k_lonmin:k_lonmax)),'all')
							% In der um N_extra_points vergrößerten bounding box gibt es nans: weitermachen.
						else
							% In der um N_extra_points vergrößerten bounding box gibt es keine nans:
							% Laden der Höhendaten beenden:
							continue_load_ele		= false;
						end
					end
				end
			end
			
			% Create individual files:
			if APP.Convert_GeoRasterDataSettings_CrIndFiles_Menu.Checked&&~isempty(ele_pathname_destination)
				save_ele_local(...
					ele_pathname_source,...
					ele_pathname_destination,...
					lonv,...
					latv,...
					elem,...
					R,...
					SampleSpacingInLongitude,...
					SampleSpacingInLatitude,...
					ppdlon,...
					ppdlat);
				% Reset:
				lonv								= [];
				latv								= [];
				elem								= [];
				ppdlon							= ppdlon_0;
				ppdlat							= ppdlat_0;
				SampleSpacingInLongitude	= SampleSpacingInLongitude_0;
				SampleSpacingInLatitude		= SampleSpacingInLatitude_0;
			end
			
		end
	end
	
	% Create a single file:
	if APP.Convert_GeoRasterDataSettings_CrSFile_Menu.Checked&&~isempty(ele_pathname_destination)
		warntext							= '';
		
		if APP.Convert_GeoRasterDataSettings_ExtractBB_Menu.Checked
			% Extract bounding box:
			
			% Check if there is data inside the bounding box:
			if    (lonmin_degree>lonv(1,end))||...
					(lonmax_degree<lonv(1,1  ))||...
					(latmin_degree>latv(end,1))||...
					(latmax_degree<latv(1  ,1))
				errortext	= sprintf([...
					'Error:\n',...
					'The bounding box:\n',...
					'    longitude: %g ° ... %g °\n',...
					'    latitude: %g ° ... %g °\n',...
					'is outside the range of the imported data:\n',...
					'    longitude: %g ° ... %g °\n',...
					'    latitude: %g ° ... %g °'],...
					lonmin_degree,lonmax_degree,...
					latmin_degree,latmax_degree,...
					lonv(1,1),lonv(1,end),...
					latv(1,1),latv(end,1));
				errormessage(errortext);
			end
			
			% Check if the bounding box is greater than the data:
			bb_is_greater_than_data		= false;
			if lonmin_degree<lonv(1,1)
				k_lonmin						= 1;
				bb_is_greater_than_data	= true;
			else
				k_lonmin						= find(lonv<=lonmin_degree,1,'last');
			end
			if lonmax_degree>lonv(1,end)
				k_lonmax						= size(lonv,2);
				bb_is_greater_than_data	= true;
			else
				k_lonmax						= find(lonv>=lonmax_degree,1,'first');
			end
			if latmin_degree<latv(1,1)
				k_latmin						= 1;
				bb_is_greater_than_data	= true;
			else
				k_latmin						= find(latv<=latmin_degree,1,'last');
			end
			if latmax_degree>latv(end,1)
				k_latmax						= size(latv,1);
				bb_is_greater_than_data	= true;
			else
				k_latmax						= find(latv>=latmax_degree,1,'first');
			end
			if bb_is_greater_than_data
				if ~isempty(warntext)
					warntext		= sprintf('%s\n\n',warntext);
				end
				warntext		= sprintf(['%s',...
					'The bounding box:\n',...
					'    longitude: %g ° ... %g °\n',...
					'    latitude: %g ° ... %g °\n',...
					'is greater than the range of the imported data:\n',...
					'    longitude: %g ° ... %g °\n',...
					'    latitude: %g ° ... %g °'],...
					warntext,...
					lonmin_degree,lonmax_degree,...
					latmin_degree,latmax_degree,...
					lonv(1,1),lonv(1,end),...
					latv(1,1),latv(end,1));
			end
			
			% Additional sampling points:
			N_extra_points_left		= min(N_extra_points,k_lonmin-1);
			N_extra_points_right		= min(N_extra_points,size(lonv,2)-k_lonmax);
			N_extra_points_bot		= min(N_extra_points,k_latmin-1);
			N_extra_points_top		= min(N_extra_points,size(latv,1)-k_latmax);
			k_lonmin						= k_lonmin-N_extra_points_left;
			k_lonmax						= k_lonmax+N_extra_points_right;
			k_latmin						= k_latmin-N_extra_points_bot;
			k_latmax						= k_latmax+N_extra_points_top;
			if    (N_extra_points_left ~=N_extra_points)||...
					(N_extra_points_right~=N_extra_points)||...
					(N_extra_points_bot  ~=N_extra_points)||...
					(N_extra_points_top  ~=N_extra_points)
				if ~isempty(warntext)
					warntext		= sprintf('%s\n\n',warntext);
				end
				warntext		= sprintf(['%s',...
					'The area of the imported data is not\n',...
					'large enough on all sides for the given\n',...
					'number of additional sampling points.\n',...
					'Actual number of additional sampling points:\n',...
					'    left side: %g\n',...
					'    right side: %g\n',...
					'    bottom side: %g\n',...
					'    top side: %g'],...
					warntext,...
					N_extra_points_left,...
					N_extra_points_right,...
					N_extra_points_bot,...
					N_extra_points_top);
			end
			
			% Extract the bounding box:
			lonv			= lonv(1,k_lonmin:k_lonmax);
			if isempty(lonv)
				errormessage;		% This should not happen.
			end
			latv			= latv(k_latmin:k_latmax,1);
			if isempty(latv)
				errormessage;		% This should not happen.
			end
			elem			= elem(k_latmin:k_latmax,k_lonmin:k_lonmax);
			if isempty(elem)
				errormessage;		% This should not happen.
			end
			
		end
		
		% Warnings:
		if ~isempty(warntext)
			if isfield(GV_H.warndlg,'open_ele')
				if ishandle(GV_H.warndlg.open_ele)
					close(GV_H.warndlg.open_ele);
				end
			end
			GV_H.warndlg.open_ele		= warndlg(warntext,'Warning');
			GV_H.warndlg.open_ele.Tag	= 'maplab3d_figure';
		end
		
		% Save the single file:
		save_ele_local(...
			ele_pathname_source,...
			ele_pathname_destination,...
			lonv,...
			latv,...
			elem,...
			R,...
			SampleSpacingInLongitude,...
			SampleSpacingInLatitude,...
			ppdlon,...
			ppdlat);
		
	end
	
	% Reset waitbar:
	set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
	set(GV_H.text_waitbar,'String','');
	
	% Display state:
	if ~stateisbusy
		t_end_statebusy		= clock;
		dt_statebusy			= etime(t_end_statebusy,t_start_statebusy);
		dt_statebusy_str		= dt_string(dt_statebusy);
		display_on_gui('state',...
			sprintf('%s ... done (%s).',text_disp_on_gui,dt_statebusy_str),...
			'notbusy','replace');
	end
	
catch ME
	errormessage('',ME);
end



% -----------------------------------------------------------------------------------------------------------------
function save_ele_local(...
	ele_pathname_source,...
	ele_pathname_destination,...
	lonv,...
	latv,...
	A,...
	R,...
	SampleSpacingInLongitude,...
	SampleSpacingInLatitude,...
	ppdlon,...
	ppdlat)
% Save the mat-file

global APP GV GV_H

try
	
	% Replace missing data with zeros:
	if APP.Convert_GeoRasterDataSettings_ReplMissData_Menu.Checked
		A(isnan(A))		= 0;
	end
	
	% Query whether files are missing:
	[rlat_isnan,clon_isnan]		= find(isnan(A),1);
	
	% if ~isempty(rlat_isnan)
	% 	% Data is missing:
	% 	errortext		= sprintf([...
	% 		'The elevation data files in the directory\n',...
	% 		'%s\n',...
	% 		'do not contain a complete rectangle; data is \n',...
	% 		'missing in at least one area. This concerns\n',...
	% 		'the following area and possibly others:\n',...
	% 		'Longitude from %g°\n',...
	% 		'Latitude from %g°\n',...
	% 		'Complete the files and run the function again.'],...
	% 		ele_pathname_source,...
	% 		lonv(1,clon_isnan),...					% The column number clon in A or elem is the index in lonv.
	% 		latv(rlat_isnan,1));						% The row    number rlat in A or elem is the index in latv.
	% 	errormessage(errortext);
	% end
	
	% Save data:
	minlon					= min(lonv);
	maxlon					= max(lonv);
	minlat					= min(latv);
	maxlat					= max(latv);
	R.ColumnsStartFrom			= 'south';
	R.RowsStartFrom				= 'west';
	R.LongitudeLimits				= [minlon maxlon];
	R.LatitudeLimits				= [minlat maxlat];
	R.SampleSpacingInLongitude	= SampleSpacingInLongitude;	% Reset these values because they change
	R.SampleSpacingInLatitude	= SampleSpacingInLatitude;		% automatically if the limits are changed.
	
	% Filename:
	if     minlon>0
		minlon_str			= sprintf('e%g',abs(minlon));
	elseif minlon<0
		minlon_str			= sprintf('w%g',abs(minlon));
	else
		minlon_str			= '0';
	end
	if     maxlon>0
		maxlon_str			= sprintf('e%g',abs(maxlon));
	elseif maxlon<0
		maxlon_str			= sprintf('w%g',abs(maxlon));
	else
		maxlon_str			= '0';
	end
	if     minlat>0
		minlat_str			= sprintf('n%g',abs(minlat));
	elseif minlat<0
		minlat_str			= sprintf('s%g',abs(minlat));
	else
		minlat_str			= '0';
	end
	if     maxlat>0
		maxlat_str			= sprintf('n%g',abs(maxlat));
	elseif maxlat<0
		maxlat_str			= sprintf('s%g',abs(maxlat));
	else
		maxlat_str			= '0';
	end
	ppdlon_str				= sprintf('%1.0f',ppdlon);
	ppdlat_str				= sprintf('%1.0f',ppdlat);
	minlon_str(strfind(minlon_str,'.'))	= 'p';
	maxlon_str(strfind(maxlon_str,'.'))	= 'p';
	minlat_str(strfind(minlat_str,'.'))	= 'p';
	maxlat_str(strfind(maxlat_str,'.'))	= 'p';
	ppdlon_str(strfind(ppdlon_str,'.'))	= 'p';
	ppdlat_str(strfind(ppdlat_str,'.'))	= 'p';
	ele_filename_destination	= sprintf('MapLab3D_Ele_Lon_%s_%s_%s_Lat_%s_%s_%s',...
		minlon_str,maxlon_str,ppdlon_str,...
		minlat_str,maxlat_str,ppdlat_str);
	if isempty(rlat_isnan)
		ele_filename_destination	= sprintf('%s.mat',ele_filename_destination);
	else
		ele_filename_destination	= sprintf('%s_incomplete.mat',ele_filename_destination);
	end
	
	% Save:
	set(GV_H.text_waitbar,'String',sprintf('Saving %s, this may take some time ... ',ele_filename_destination));
	save([ele_pathname_destination ele_filename_destination],'R','A','-v7.3');
	
	% Testplot:
	if APP.Convert_GeoRasterDataSettings_Testplot_Menu.Checked||~isempty(rlat_isnan)||~isempty(clon_isnan)
		% Data reduction:
		kredlon		= ceil(length(lonv)/GV.nmax_elevation_data_reduction);
		kredlat		= ceil(length(latv)/GV.nmax_elevation_data_reduction);
		lonv_red		= lonv(1,1:kredlon:end);
		latv_red		= latv(1:kredlat:end,1);
		elem_red		= A(1:kredlat:end,1:kredlon:end);
		% Plot:
		[lonm_red,latm_red]	= meshgrid(lonv_red,latv_red);
		hf		= figure(3254900);
		figure_theme(hf,'set',[],'light');
		clf(hf,'reset');
		figure_theme(hf,'set',[],'light');
		set(hf,'Tag','maplab3d_figure');
		ha		= axes;
		hold(ha,'on');
		set(hf,'Name','Elevation');
		set(hf,'NumberTitle','off');
		title_str	= sprintf([...
			'%s\n%s\n',...
			'Longitude %g° .. %g°, %g points/°  /  ',...
			'Latitude %g° .. %g°, %g points/°'],...
			ele_pathname_destination,ele_filename_destination,...
			minlon,maxlon,1/R.SampleSpacingInLongitude,...
			minlat,maxlat,1/R.SampleSpacingInLatitude);
		if ~isempty(rlat_isnan)
			title_str	= sprintf('%s\n!!! THE DATA IS NOT COMPLETE !!!',title_str);
		end
		title(ha,title_str,'Interpreter','none');
		s=surf(lonm_red,latm_red,elem_red);
		s.EdgeAlpha		= 0;
		xlabel(ha,'lon / °');
		ylabel(ha,'lat / °');
		zlabel(ha,'z / m');
		cameratoolbar(hf,'Show');
		view(ha,3);
		drawnow;
		setbreakpoint=1;
	end
	
catch ME
	errormessage('',ME);
end


function dist_bb_center=get_dist_bb_center(ele_filename,minlon_bb,maxlon_bb,minlat_bb,maxlat_bb)
% Get the distance between the given bounding box center and the center of the area in ele_filename.
% Example: ele_filename = 'MapLab3D_Ele_Lon_e10p4_e10p6_900_Lat_n50p4_n50p6_900.mat';
% dist_bb_center=[]  -->	It was not possible to determine the boundaries of the area based on the file name.

% Initializations:
dist_bb_center	= [];				% distance between the bounding box centers / degree

% Get the bounding box from the filename:
% Example: ele_filename = 'MapLab3D_Ele_Lon_e10p4_e10p6_900_Lat_n50p4_n50p6_900.mat'
%                          k4:     1   2   3     4     5   6   7     8     9
str1			= 'MapLab3D_Ele_Lon_';
str2			= '_Lat_';
str3			= '.mat';
str4			= '_';
k1				= strfind(ele_filename,str1);
k2				= strfind(ele_filename,str2);
k3				= strfind(ele_filename,str3);
k4				= strfind(ele_filename,str4);
if    ~isequal(k1,1)                     ||...
		~isscalar(k2)                      ||...
		~isequal(k3,length(ele_filename)-3)||...
		~isequal(length(k4),9)
	return
end
minlon_str	= ele_filename((k4(3)+1):(k4(4)-1));
maxlon_str	= ele_filename((k4(4)+1):(k4(5)-1));
minlat_str	= ele_filename((k4(7)+1):(k4(8)-1));
maxlat_str	= ele_filename((k4(8)+1):(k4(9)-1));
minlon_str(strfind(minlon_str,'p'))	= '.';
maxlon_str(strfind(maxlon_str,'p'))	= '.';
minlat_str(strfind(minlat_str,'p'))	= '.';
maxlat_str(strfind(maxlat_str,'p'))	= '.';
if strcmp(minlon_str,'0')
	minlon		= 0;
elseif strcmp(minlon_str(1),'e')&&(length(minlon_str)>=2)
	minlon		= str2double(minlon_str(2:end));
elseif strcmp(minlon_str(1),'w')&&(length(minlon_str)>=2)
	minlon		= -str2double(minlon_str(2:end));
else
	minlon		= NaN;
end
if strcmp(maxlon_str,'0')
	maxlon		= 0;
elseif strcmp(maxlon_str(1),'e')&&(length(maxlon_str)>=2)
	maxlon		= str2double(maxlon_str(2:end));
elseif strcmp(maxlon_str(1),'w')&&(length(maxlon_str)>=2)
	maxlon		= -str2double(maxlon_str(2:end));
else
	maxlon		= NaN;
end
if strcmp(minlat_str,'0')
	minlat		= 0;
elseif strcmp(minlat_str(1),'n')&&(length(minlat_str)>=2)
	minlat		= str2double(minlat_str(2:end));
elseif strcmp(minlat_str(1),'s')&&(length(minlat_str)>=2)
	minlat		= -str2double(minlat_str(2:end));
else
	minlat		= NaN;
end
if strcmp(maxlat_str,'0')
	maxlat		= 0;
elseif strcmp(maxlat_str(1),'n')&&(length(maxlat_str)>=2)
	maxlat		= str2double(maxlat_str(2:end));
elseif strcmp(maxlat_str(1),'s')&&(length(maxlat_str)>=2)
	maxlat		= -str2double(maxlat_str(2:end));
else
	maxlat		= NaN;
end
if    isnan(minlon)||...
		isnan(maxlon)||...
		isnan(minlat)||...
		isnan(maxlat)
	return
end

% Distance between the bounding box centers in degree:
if maxlon<minlon
	maxlon		= maxlon+360;				% longitude: -180° .. +180°
end
if maxlon_bb<minlon_bb
	maxlon_bb	= maxlon_bb+360;
end
if maxlat<minlat								% latitude: -90° .. +90°
	maxlat		= maxlat+180;
end
if maxlat_bb<minlat_bb
	maxlat_bb	= maxlat_bb+180;
end
dist_bb_center_lon	= (minlon+maxlon)/2-(minlon_bb+maxlon_bb)/2;
dist_bb_center_lat	= (minlat+maxlat)/2-(minlat_bb+maxlat_bb)/2;
dist_bb_center_lon	= mod(dist_bb_center_lon+180,360)-180;
dist_bb_center_lat	= mod(dist_bb_center_lat+90,180)-90;
dist_bb_center			= sqrt(dist_bb_center_lon^2+dist_bb_center_lat^2);


