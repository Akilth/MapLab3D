function calculator_latlonxy_plot(source)
% source = 'OSM', 'Osmosis', 'Map'

global APP GV_H

try

	% Testing:
	if nargin==0
		calculator_latlonxy_plot('Map');			% 'OSM' / 'Osmosis' / 'Map'
		return
	end

	origin_deg			= [...
		APP.LatLonXYTab_OriginLatitudeEditField.Value ...		% latorigin_deg
		APP.LatLonXYTab_OriginLongitudeEditField.Value];		% lonorigin_deg
	switch source
		case 'OSM'
			% OSM data:
			xmin_mm		= APP.LatLonXYTab_OSM_xminmmEditField.Value;
			xmax_mm		= APP.LatLonXYTab_OSM_xmaxmmEditField.Value;
			ymin_mm		= APP.LatLonXYTab_OSM_yminmmEditField.Value;
			ymax_mm		= APP.LatLonXYTab_OSM_ymaxmmEditField.Value;
			lonmin_deg	= APP.LatLonXYTab_OSM_lonminEditField.Value;
			lonmax_deg	= APP.LatLonXYTab_OSM_lonmaxEditField.Value;
			latmin_deg	= APP.LatLonXYTab_OSM_latminEditField.Value;
			latmax_deg	= APP.LatLonXYTab_OSM_latmaxEditField.Value;
			ntx			= str2double(APP.LatLonXYTab_OSM_NoTilesW_Label.Text);
			nty			= str2double(APP.LatLonXYTab_OSM_NoTilesH_Label.Text);
			if APP.LatLonXYTab_OSM_SetOriginToBBC_CheckBox.Value
				origin_deg			= [...
					APP.LatLonXYTab_OSM_LatCenter_EditField.Value ...		% latorigin_deg
					APP.LatLonXYTab_OSM_LonCenter_EditField.Value];			% lonorigin_deg
			end
			title_str	= APP.LatLonXYTab_OSM_Label.Text;
		case 'Osmosis'
			% Osmosis settings:
			xmin_mm		= APP.LatLonXYTab_Osmosis_xminmmEditField.Value;
			xmax_mm		= APP.LatLonXYTab_Osmosis_xmaxmmEditField.Value;
			ymin_mm		= APP.LatLonXYTab_Osmosis_yminmmEditField.Value;
			ymax_mm		= APP.LatLonXYTab_Osmosis_ymaxmmEditField.Value;
			lonmin_deg	= APP.LatLonXYTab_Osmosis_lonminEditField.Value;
			lonmax_deg	= APP.LatLonXYTab_Osmosis_lonmaxEditField.Value;
			latmin_deg	= APP.LatLonXYTab_Osmosis_latminEditField.Value;
			latmax_deg	= APP.LatLonXYTab_Osmosis_latmaxEditField.Value;
			ntx			= str2double(APP.LatLonXYTab_Osmosis_NoTilesW_Label.Text);
			nty			= str2double(APP.LatLonXYTab_Osmosis_NoTilesH_Label.Text);
			if APP.LatLonXYTab_Osmosis_SetOriginToBBC_CheckBox.Value
				origin_deg			= [...
					APP.LatLonXYTab_Osmosis_LatCenter_EditField.Value ...		% latorigin_deg
					APP.LatLonXYTab_Osmosis_LonCenter_EditField.Value];		% lonorigin_deg
			end
			title_str	= APP.LatLonXYTab_Osmosis_Label.Text;
		case 'Map'
			% Map printout:
			lonmin_deg	= APP.LatLonXYTab_Map_lonminEditField.Value;
			lonmax_deg	= APP.LatLonXYTab_Map_lonmaxEditField.Value;
			latmin_deg	= APP.LatLonXYTab_Map_latminEditField.Value;
			latmax_deg	= APP.LatLonXYTab_Map_latmaxEditField.Value;
			xmin_mm		= APP.LatLonXYTab_Map_xminmmEditField.Value;
			xmax_mm		= APP.LatLonXYTab_Map_xmaxmmEditField.Value;
			ymin_mm		= APP.LatLonXYTab_Map_yminmmEditField.Value;
			ymax_mm		= APP.LatLonXYTab_Map_ymaxmmEditField.Value;
			ntx			= str2double(APP.LatLonXYTab_Map_NoTilesW_Label.Text);
			nty			= str2double(APP.LatLonXYTab_Map_NoTilesH_Label.Text);
			title_str	= APP.LatLonXYTab_Map_Label.Text;
	end

	% Ellipsoidal model of the figure of the Earth (needed for grn2eqa)
	ellipsoid			= referenceSphere('Earth');

	% Corners of the lon,lat rectangle in the x,y plane:
	lon_v					= [...
		lonmin_deg;...
		lonmin_deg;...
		lonmax_deg;...
		lonmax_deg];
	lat_v					= [...
		latmin_deg;...
		latmax_deg;...
		latmax_deg;...
		latmin_deg];
	[x_m_bounds,y_m_bounds]	=grn2eqa(lat_v,lon_v,origin_deg,ellipsoid);
	x_mm_bounds	= x_m_bounds*1000/APP.LatLonXYTab_ScaleEditField.Value;
	y_mm_bounds	= y_m_bounds*1000/APP.LatLonXYTab_ScaleEditField.Value;

	% lon,lat rectangle shape in the xy plane:
	lon_v		= [...
		lonmin_deg;...
		lonmax_deg;...
		lonmax_deg;...
		lonmin_deg;...
		lonmin_deg];
	lat_v		= [...
		latmin_deg;...
		latmin_deg;...
		latmax_deg;...
		latmax_deg;...
		latmin_deg];
	% High resolution:
	% changeresolution_xy:
	% 1)	If dmax is not empty:
	%		Inserts vertices to polyin, so that the distance between two vertices is less than dmax
	% 2)	If dmin is not empty:
	%		Deletes vertices in polyin, so that the distance between two vertices is at least dmin
	%		Possibly there remains no data in polyout!
	% 3)	If nmin is not empty:
	%		Insert at least nmin vertices between 2 vertices in polyin (AFTER deleting vertices according dmin)
	% 4)	keep_flp=1: Keep the first and the last point of the line (default).
	%		keep_flp=0: The first and the last point of the line will possibly be deleted.
	[  lon_hr_v,...						% x
		lat_hr_v...						% y
		]	= changeresolution_xy(...
		lon_v,...		% x0
		lat_v,...		% y0
		[],...							% dmax
		[],...							% dmin
		1000,...						% nmin
		1);								% keep_flp
	% Conversion of lat, lon from degrees to x,y in mm:
	[x_hr_m_bounds,y_hr_m_bounds]	= grn2eqa(lat_hr_v,lon_hr_v,origin_deg,ellipsoid);
	x_hr_mm_bounds		= x_hr_m_bounds*1000/APP.LatLonXYTab_ScaleEditField.Value;
	y_hr_mm_bounds		= y_hr_m_bounds*1000/APP.LatLonXYTab_ScaleEditField.Value;
	x_v	= [...
		xmin_mm;...
		xmax_mm;...
		xmax_mm;...
		xmin_mm;...
		xmin_mm];
	y_v	= [...
		ymin_mm;...
		ymin_mm;...
		ymax_mm;...
		ymax_mm;...
		ymin_mm];

	% Distance between OSM-data and map printout limits / mm
	if APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Value>0
		poly_xy				= polyshape(x_v,y_v);
		poly_xy_buff		= polybuffer(poly_xy,APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Value,'JointType','miter');
		poly_xy				= addboundary(poly_xy,poly_xy_buff.Vertices);
	end

	% Frame:
	if APP.LatLonXYTab_FrameWidth_EditField.Value>0
		poly_frame			= polyshape(x_v,y_v);
		poly_frame_buff	= polybuffer(poly_frame,APP.LatLonXYTab_FrameWidth_EditField.Value,'JointType','miter');
		poly_frame			= addboundary(poly_frame,poly_frame_buff.Vertices);
	end

	% Plot:
	create_fig_latlonxy	= true;
	if isfield(GV_H,'fig_latlonxy')
		if ~isempty(GV_H.fig_latlonxy)
			if isvalid(GV_H.fig_latlonxy)
				clf(GV_H.fig_latlonxy,'reset');
				figure_theme(GV_H.fig_latlonxy,'set',[],'light');
				create_fig_latlonxy	= false;
			end
		end
	end
	if create_fig_latlonxy
		GV_H.fig_latlonxy	= figure;
		figure_theme(GV_H.fig_latlonxy,'set',[],'light');
	end
	figure(GV_H.fig_latlonxy);
	set(GV_H.fig_latlonxy,'Tag','maplab3d_figure');
	GV_H.fig_latlonxy.Name	= 'LatLonXY';
	GV_H.fig_latlonxy.NumberTitle	= 'off';
	GV_H.ax_latlonxy	= axes(GV_H.fig_latlonxy);
	hold(GV_H.ax_latlonxy,'on');
	GV_H.ax_latlonxy.Box	= 'on';
	grid(GV_H.ax_latlonxy,'on');
	title_str		= sprintf([...
		'%s\n',...
		'Conversion from Greenwich to equal area coordinates'],title_str);
	title(GV_H.ax_latlonxy,title_str);
	xlabel(GV_H.ax_latlonxy,'x / mm');
	ylabel(GV_H.ax_latlonxy,'y / mm');
	axis(GV_H.ax_latlonxy,'equal');

	% Distance between the (outer) OSM data and the (inner) map printout limits / mm:
	if APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Value>0
		h0	= plot(GV_H.ax_latlonxy,poly_xy,...
			'FaceColor','k',...
			'EdgeColor','k',...
			'DisplayName','Distance between OSM data and map printout limits');
	end

	% Frame:
	if APP.LatLonXYTab_FrameWidth_EditField.Value>0
		h5	= plot(GV_H.ax_latlonxy,poly_frame,...
			'FaceColor','g',...
			'EdgeColor','g',...
			'DisplayName','Frame');
	end

	% Tiles:
	ntx_nty_max		= 1000;
	tile_width		= APP.LatLonXYTab_TileWidth_EditField.Value;
	tile_height		= APP.LatLonXYTab_TileHeight_EditField.Value;
	tile_origin_x	= 999999;
	tile_origin_y	= 999999;
	if (ntx*nty)<ntx_nty_max
		[poly_tiles_v,~,~]=...
			calculate_poly_tiles(...
			tile_width,...				% tile_width
			tile_height,...			% tile_height
			tile_origin_x,...			% tile_origin_x
			tile_origin_y,...			% tile_origin_y
			xmin_mm-APP.LatLonXYTab_FrameWidth_EditField.Value,...		% xmin_mm
			xmax_mm+APP.LatLonXYTab_FrameWidth_EditField.Value,...		% xmax_mm
			ymin_mm-APP.LatLonXYTab_FrameWidth_EditField.Value,...		% ymin_mm
			ymax_mm+APP.LatLonXYTab_FrameWidth_EditField.Value);			% ymax_mm
		for tile_no=1:size(poly_tiles_v,1)
			if tile_no==1
				h4	= plot(GV_H.ax_latlonxy,poly_tiles_v(tile_no,1),...
					'LineWidth'    ,2,...
					'LineStyle'    ,'-',...
					'EdgeColor'    ,'c',...
					'FaceAlpha'    ,0,...
					'DisplayName','Tiles');
			else
				plot(GV_H.ax_latlonxy,poly_tiles_v(tile_no,1),...
					'LineWidth'    ,2,...
					'LineStyle'    ,'-',...
					'EdgeColor'    ,'c',...
					'FaceAlpha'    ,0);
			end
		end
	end

	% Lines:
	plot(GV_H.ax_latlonxy,x_v,y_v,...
		'Color','b',...
		'LineWidth',2,...
		'LineStyle','-');
	plot(GV_H.ax_latlonxy,x_hr_mm_bounds,y_hr_mm_bounds,...
		'Color','r',...
		'LineWidth',2,...
		'LineStyle','--');

	% Corners:
	h2	= plot(GV_H.ax_latlonxy,x_v,y_v,...
		'Color','b',...
		'LineStyle','none',...
		'LineWidth',2,...
		'Marker','x',...
		'MarkerSize',10,...
		'DisplayName','x,y coordinates: full rectangle within the lon,lat coordinates');
	h1	= plot(GV_H.ax_latlonxy,x_mm_bounds,y_mm_bounds,...
		'Color','r',...
		'LineStyle','none',...
		'LineWidth',2,...
		'Marker','+',...
		'MarkerSize',10,...
		'DisplayName','lon,lat rectangle transformed into the x,y plane');
	h3	= plot(GV_H.ax_latlonxy,0,0,...
		'Color','k',...
		'LineStyle','none',...
		'LineWidth',2,...
		'Marker','+',...
		'MarkerSize',10,...
		'DisplayName','Origin transformed into the x,y plane');

	% Legend:
	subset_legend_v	= [h1 h2 h3];
	if (ntx*nty)<ntx_nty_max
		subset_legend_v	= [h4 subset_legend_v];
	end
	if APP.LatLonXYTab_FrameWidth_EditField.Value>0
		subset_legend_v	= [h5 subset_legend_v];
	end
	if APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Value>0
		subset_legend_v	= [h0 subset_legend_v];
	end
	legend(GV_H.ax_latlonxy,subset_legend_v);

catch ME
	errormessage('',ME);
end

