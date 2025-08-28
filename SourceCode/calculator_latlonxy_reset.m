function reset_values=calculator_latlonxy_reset(source,recalculate)
% lon,lat-x,y-calculator reset

global OSMDATA APP PP

try

	reset_values		= [];

	if nargin==0

		% Reset the general data:
		% Reset scale:
		calculator_latlonxy_reset('Scale',0);
		% Reset origin:
		calculator_latlonxy_reset('Origin',0);
		% Reset distance between the (outer) OSM data and the (inner) map printout limits:
		calculator_latlonxy_reset('Distance_OSM_MapPrintout',0);
		% Reset tile size:
		calculator_latlonxy_reset('TileSize',0);
		% Reset frame width:
		calculator_latlonxy_reset('FrameWidth',0);

		% Reset the check boxes:
		if isempty(PP)
			APP.LatLonXYTab_OSM_SetOriginToBBC_CheckBox.Value					= false;
			APP.LatLonXYTab_Osmosis_SetOriginToBBC_CheckBox.Value				= false;
		else
			if (PP.general.origin_user_lat~=999999)&&(PP.general.origin_user_lon~=999999)
				APP.LatLonXYTab_OSM_SetOriginToBBC_CheckBox.Value					= false;
				APP.LatLonXYTab_Osmosis_SetOriginToBBC_CheckBox.Value				= false;
			else
				APP.LatLonXYTab_OSM_SetOriginToBBC_CheckBox.Value					= true;
				APP.LatLonXYTab_Osmosis_SetOriginToBBC_CheckBox.Value				= true;
			end
		end

		% Reset the latlon-xy data AFTER resetting the general data:
		% Reset OSM data:
		calculator_latlonxy_reset('OSM');
		% Reset osmosis data:
		calculator_latlonxy_reset('Osmosis');
		% Reset map printout data:
		calculator_latlonxy_reset('Map');

		% Reset labels:
		if ~isempty(PP)
			APP.LatLonXYTab_Scale_Label.Text						= sprintf('%g:',PP.TABLE_ROWNO.project.scale);
			APP.LatLonXYTab_OriginLongitude_Label.Text		= sprintf('%g:',PP.TABLE_ROWNO.general.origin_user_lon);
			APP.LatLonXYTab_OriginLatitude_Label.Text			= sprintf('%g:',PP.TABLE_ROWNO.general.origin_user_lat);
			APP.LatLonXYTab_Dist_OSM_MapPrintout_Label.Text	= sprintf('%g:',PP.TABLE_ROWNO.general.dist_osm_printout);
			APP.LatLonXYTab_FrameWidth_Label.Text		= sprintf('%g:',PP.TABLE_ROWNO.frame.b2);
			APP.LatLonXYTab_TileWidth_Label.Text		= sprintf('%g:',PP.TABLE_ROWNO.general.tile_width_preset);
			APP.LatLonXYTab_TileHeight_Label.Text		= sprintf('%g:',PP.TABLE_ROWNO.general.tile_depth_preset);
			APP.LatLonXYTab_Osmosis_lonmin_Label.Text	= sprintf('%g:',PP.TABLE_ROWNO.general.bounding_box.lonmin_degree);
			APP.LatLonXYTab_Osmosis_lonmax_Label.Text	= sprintf('%g:',PP.TABLE_ROWNO.general.bounding_box.lonmax_degree);
			APP.LatLonXYTab_Osmosis_latmin_Label.Text	= sprintf('%g:',PP.TABLE_ROWNO.general.bounding_box.latmin_degree);
			APP.LatLonXYTab_Osmosis_latmax_Label.Text	= sprintf('%g:',PP.TABLE_ROWNO.general.bounding_box.latmax_degree);
			APP.LatLonXYTab_Map_xminmm_Label.Text		= sprintf('%g:',PP.TABLE_ROWNO.general.map_printout.xmin_mm);
			APP.LatLonXYTab_Map_xmaxmm_Label.Text		= sprintf('%g:',PP.TABLE_ROWNO.general.map_printout.xmax_mm);
			APP.LatLonXYTab_Map_yminmm_Label.Text		= sprintf('%g:',PP.TABLE_ROWNO.general.map_printout.ymin_mm);
			APP.LatLonXYTab_Map_ymaxmm_Label.Text		= sprintf('%g:',PP.TABLE_ROWNO.general.map_printout.ymax_mm);
			APP.LatLonXYTab_Scale_Label.Visible						= 'on';
			APP.LatLonXYTab_OriginLongitude_Label.Visible		= 'on';
			APP.LatLonXYTab_OriginLatitude_Label.Visible			= 'on';
			APP.LatLonXYTab_Dist_OSM_MapPrintout_Label.Visible	= 'on';
			APP.LatLonXYTab_FrameWidth_Label.Visible		= 'on';
			APP.LatLonXYTab_TileWidth_Label.Visible		= 'on';
			APP.LatLonXYTab_TileHeight_Label.Visible		= 'on';
			APP.LatLonXYTab_Osmosis_lonmin_Label.Visible	= 'on';
			APP.LatLonXYTab_Osmosis_lonmax_Label.Visible	= 'on';
			APP.LatLonXYTab_Osmosis_latmin_Label.Visible	= 'on';
			APP.LatLonXYTab_Osmosis_latmax_Label.Visible	= 'on';
			APP.LatLonXYTab_Map_xminmm_Label.Visible		= 'on';
			APP.LatLonXYTab_Map_xmaxmm_Label.Visible		= 'on';
			APP.LatLonXYTab_Map_yminmm_Label.Visible		= 'on';
			APP.LatLonXYTab_Map_ymaxmm_Label.Visible		= 'on';
		else
			APP.LatLonXYTab_Scale_Label.Visible						= 'off';
			APP.LatLonXYTab_OriginLongitude_Label.Visible		= 'off';
			APP.LatLonXYTab_OriginLatitude_Label.Visible			= 'off';
			APP.LatLonXYTab_Dist_OSM_MapPrintout_Label.Visible	= 'off';
			APP.LatLonXYTab_FrameWidth_Label.Visible		= 'off';
			APP.LatLonXYTab_TileWidth_Label.Visible		= 'off';
			APP.LatLonXYTab_TileHeight_Label.Visible		= 'off';
			APP.LatLonXYTab_Osmosis_lonmin_Label.Visible	= 'off';
			APP.LatLonXYTab_Osmosis_lonmax_Label.Visible	= 'off';
			APP.LatLonXYTab_Osmosis_latmin_Label.Visible	= 'off';
			APP.LatLonXYTab_Osmosis_latmax_Label.Visible	= 'off';
			APP.LatLonXYTab_Map_xminmm_Label.Visible		= 'off';
			APP.LatLonXYTab_Map_xmaxmm_Label.Visible		= 'off';
			APP.LatLonXYTab_Map_yminmm_Label.Visible		= 'off';
			APP.LatLonXYTab_Map_ymaxmm_Label.Visible		= 'off';
		end

		% Reset Tooltips:
		set_tooltips('latlonxytab');

		return
	end
	if nargin<2
		recalculate		= 1;
	end

	% OSM bounds:
	osmdata_loaded	= false;
	if isfield(OSMDATA,'bounds')
		minlon_osmbounds	= OSMDATA.bounds.minlon;
		maxlon_osmbounds	= OSMDATA.bounds.maxlon;
		minlat_osmbounds	= OSMDATA.bounds.minlat;
		maxlat_osmbounds	= OSMDATA.bounds.maxlat;
		osmdata_loaded		= true;
	end
	if ~osmdata_loaded
		minlon_osmbounds	= -180;
		maxlon_osmbounds	= 180;
		minlat_osmbounds	= -90;
		maxlat_osmbounds	= 90;
	end

	switch source

		case 'Origin'
			set_gv_map_origin;
			% Recalculate all lon,lat-x,y-calculator data:
			if recalculate~=0
				calculator_latlonxy_recalculate;
			end

		case 'Scale'
			scale	= 100000;
			if ~isempty(PP)
				if isfield(PP,'project')
					if isfield(PP.project,'scale')
						scale	= PP.project.scale;
					end
				end
			end
			APP.LatLonXYTab_ScaleEditField.Value	= scale;
			% Recalculate all lon,lat-x,y-calculator data:
			if recalculate~=0
				calculator_latlonxy_recalculate;
			end

		case 'Distance_OSM_MapPrintout'
			dist_osm_printout	= 0;
			if ~isempty(PP)
				if isfield(PP,'general')
					if isfield(PP.general,'dist_osm_printout')
						dist_osm_printout	= PP.general.dist_osm_printout;
					end
				end
			end
			APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Value	= dist_osm_printout;
			% Recalculate all lon,lat-x,y-calculator data:
			if recalculate~=0
				calculator_latlonxy_recalculate;
			end

		case 'TileSize'
			tile_width		= 200;
			tile_height		= 200;
			if ~isempty(PP)
				if isfield(PP,'general')
					if isfield(PP.general,'tile_width_preset')
						tile_width	= PP.general.tile_width_preset;
					end
					if isfield(PP.general,'tile_depth_preset')
						tile_height	= PP.general.tile_depth_preset;
					end
				end
			end
			APP.LatLonXYTab_TileWidth_EditField.Value		= tile_width;
			APP.LatLonXYTab_TileHeight_EditField.Value	= tile_height;
			% Recalculate all printout sizes:
			if recalculate~=0
				calculator_latlonxy_recalculate('PrintoutSize');
			end

		case 'FrameWidth'
			frame_width		= 20;
			if ~isempty(PP)
				if isfield(PP,'frame')
					if isfield(PP.frame,'b2')
						frame_width	= PP.frame.b2;
					end
				end
			end
			APP.LatLonXYTab_FrameWidth_EditField.Value		= frame_width;
			% Recalculate all printout sizes:
			if recalculate~=0
				calculator_latlonxy_recalculate('PrintoutSize');
			end

		case 'OSM'
			% OSM data:
			APP.LatLonXYTab_OSM_lonminEditField.Value	= minlon_osmbounds;
			APP.LatLonXYTab_OSM_lonmaxEditField.Value	= maxlon_osmbounds;
			APP.LatLonXYTab_OSM_latminEditField.Value	= minlat_osmbounds;
			APP.LatLonXYTab_OSM_latmaxEditField.Value	= maxlat_osmbounds;
			calculator_latlon_xy('OSM');

		case 'Osmosis'
			% Osmosis settings:
			if ~isempty(PP)
				APP.LatLonXYTab_Osmosis_lonminEditField.Value	= PP.general.bounding_box.lonmin_degree;
				APP.LatLonXYTab_Osmosis_lonmaxEditField.Value	= PP.general.bounding_box.lonmax_degree;
				APP.LatLonXYTab_Osmosis_latminEditField.Value	= PP.general.bounding_box.latmin_degree;
				APP.LatLonXYTab_Osmosis_latmaxEditField.Value	= PP.general.bounding_box.latmax_degree;
			else
				APP.LatLonXYTab_Osmosis_lonminEditField.Value	= minlon_osmbounds;
				APP.LatLonXYTab_Osmosis_lonmaxEditField.Value	= maxlon_osmbounds;
				APP.LatLonXYTab_Osmosis_latminEditField.Value	= minlat_osmbounds;
				APP.LatLonXYTab_Osmosis_latmaxEditField.Value	= maxlat_osmbounds;
			end
			calculator_latlon_xy('Osmosis');

		case 'Map'
			% Map printout:
			if    ~isempty(PP)
				APP.LatLonXYTab_Map_xminmmEditField.Value	= PP.general.map_printout.xmin_mm;
				APP.LatLonXYTab_Map_xmaxmmEditField.Value	= PP.general.map_printout.xmax_mm;
				APP.LatLonXYTab_Map_yminmmEditField.Value	= PP.general.map_printout.ymin_mm;
				APP.LatLonXYTab_Map_ymaxmmEditField.Value	= PP.general.map_printout.ymax_mm;
			else
				APP.LatLonXYTab_Map_xminmmEditField.Value	= -1000;
				APP.LatLonXYTab_Map_xmaxmmEditField.Value	= 1000;
				APP.LatLonXYTab_Map_yminmmEditField.Value	= -1000;
				APP.LatLonXYTab_Map_ymaxmmEditField.Value	= 1000;
			end
			calculator_xy_latlon('Map');

	end

catch ME
	errormessage('',ME);
end

