function [...
	lonmin_deg,...
	lonmax_deg,...
	latmin_deg,...
	latmax_deg...
	]=calculator_xy_latlon(...
	dataset,...
	xmin_mm,...
	xmax_mm,...
	ymin_mm,...
	ymax_mm,...
	lonorigin_deg,...
	latorigin_deg,...
	scale,...
	dist_osm_printout)
% This function calculates the latlon coordinates of a rectangle in degrees
% that is required to generate a complete rectangle in xy coordinates in mm.

global APP

try
	
	testing	= 0;
	if nargin==0
		testing	= 0;
		if testing==1
			dataset	= 'Map';					% 'OSM', 'Osmosis', 'Map'
			switch dataset
				case 'Map'
					xmin_mm		= APP.LatLonXYTab_Map_xminmmEditField.Value;
					xmax_mm		= APP.LatLonXYTab_Map_xmaxmmEditField.Value;
					ymin_mm		= APP.LatLonXYTab_Map_yminmmEditField.Value;
					ymax_mm		= APP.LatLonXYTab_Map_ymaxmmEditField.Value;
					lonorigin_deg	= APP.LatLonXYTab_OriginLongitudeEditField.Value;
					latorigin_deg	= APP.LatLonXYTab_OriginLatitudeEditField.Value;
					scale				= APP.LatLonXYTab_ScaleEditField.Value;
			end
		else
			% OSM data:
			calculator_xy_latlon('OSM');													% dataset
			% Osmosis settings:
			calculator_xy_latlon('Osmosis');												% dataset
			% Map printout:
			calculator_xy_latlon('Map');													% dataset
			return
		end
	end
	
	if nargin==1
		lonorigin_deg	= APP.LatLonXYTab_OriginLongitudeEditField.Value;
		latorigin_deg	= APP.LatLonXYTab_OriginLatitudeEditField.Value;
		switch dataset					% 'OSM', 'Osmosis', 'Map'
			case 'OSM'
				% OSM data:
				% If xy-values are changed, the checkbox must not be set, because the center
				% of the bounding box also changes again after each change of the xy-values.
				APP.LatLonXYTab_OSM_SetOriginToBBC_CheckBox.Value	= false;
				[  APP.LatLonXYTab_OSM_lonminEditField.Value,...					% lonmin_deg
					APP.LatLonXYTab_OSM_lonmaxEditField.Value,...					% lonmax_deg
					APP.LatLonXYTab_OSM_latminEditField.Value,...					% latmin_deg
					APP.LatLonXYTab_OSM_latmaxEditField.Value]=...					% latmax_deg
					calculator_xy_latlon(...
					'OSM',...																	% dataset
					APP.LatLonXYTab_OSM_xminmmEditField.Value,...					% xmin_mm
					APP.LatLonXYTab_OSM_xmaxmmEditField.Value,...					% xmax_mm
					APP.LatLonXYTab_OSM_yminmmEditField.Value,...					% ymin_mm
					APP.LatLonXYTab_OSM_ymaxmmEditField.Value,...					% ymax_mm
					lonorigin_deg,...															% lonorigin_deg
					latorigin_deg,...															% latorigin_deg
					APP.LatLonXYTab_ScaleEditField.Value,...							% scale
					APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Value);		% dist_osm_printout
				% Set and check the bounding box center AFTER calculation of the lon,lat-values:
				[  APP.LatLonXYTab_OSM_LatCenter_EditField.Value,...				% latcenter
					APP.LatLonXYTab_OSM_LonCenter_EditField.Value]=...				% loncenter
					calculator_latlon_center(...
					APP.LatLonXYTab_OSM_latminEditField.Value,...					% latmin
					APP.LatLonXYTab_OSM_latmaxEditField.Value,...					% latmax
					APP.LatLonXYTab_OSM_lonminEditField.Value,...					% lonmin
					APP.LatLonXYTab_OSM_lonmaxEditField.Value);						% lonmax
				% Compare the mean value after the calculation with the displayed center of the bounding box:
				dlatlon_max_percent		= get_difference_maporigin_boundingboxcenter(...
					APP.LatLonXYTab_OSM_lonminEditField.Value,...				% lonmin
					APP.LatLonXYTab_OSM_lonmaxEditField.Value,...				% lonmax
					APP.LatLonXYTab_OSM_latminEditField.Value,...				% latmin
					APP.LatLonXYTab_OSM_latmaxEditField.Value,...				% latmax
					APP.LatLonXYTab_OSM_LonCenter_EditField.Value,...			% lon_center
					APP.LatLonXYTab_OSM_LatCenter_EditField.Value,...			% lat_center
					lonorigin_deg,...														% lon_origin
					latorigin_deg);														% lat_origin
				if dlatlon_max_percent<1
					% The displayed center of the bounding box is equal to the mean value:
					APP.LatLonXYTab_OSM_CurrOriginNotAtBBCenter_Label.Visible		= 'off';
				else
					% The displayed center of the bounding box is equal to the mean value:
					APP.LatLonXYTab_OSM_CurrOriginNotAtBBCenter_Label.Text{1,1}		= ...
						sprintf('The origin differs to the');
					APP.LatLonXYTab_OSM_CurrOriginNotAtBBCenter_Label.Text{2,1}		= ...
						sprintf('bounding box center by %1.0f%%',round(dlatlon_max_percent));
					APP.LatLonXYTab_OSM_CurrOriginNotAtBBCenter_Label.Visible		= 'on';
				end
				% Recalculate OSM data printout size:
				calculator_latlonxy_recalculate('PrintoutSize_OSM');
				
			case 'Osmosis'
				% Osmosis settings:
				% If xy-values are changed, the checkbox must not be set, because the center
				% of the bounding box also changes again after each change of the xy-values.
				APP.LatLonXYTab_Osmosis_SetOriginToBBC_CheckBox.Value	= false;
				[  APP.LatLonXYTab_Osmosis_lonminEditField.Value,...				% lonmin_deg
					APP.LatLonXYTab_Osmosis_lonmaxEditField.Value,...				% lonmax_deg
					APP.LatLonXYTab_Osmosis_latminEditField.Value,...				% latmin_deg
					APP.LatLonXYTab_Osmosis_latmaxEditField.Value]=...				% latmax_deg
					calculator_xy_latlon(...
					'Osmosis',...																% dataset
					APP.LatLonXYTab_Osmosis_xminmmEditField.Value,...				% xmin_mm
					APP.LatLonXYTab_Osmosis_xmaxmmEditField.Value,...				% xmax_mm
					APP.LatLonXYTab_Osmosis_yminmmEditField.Value,...				% ymin_mm
					APP.LatLonXYTab_Osmosis_ymaxmmEditField.Value,...				% ymax_mm
					lonorigin_deg,...															% lonorigin_deg
					latorigin_deg,...															% latorigin_deg
					APP.LatLonXYTab_ScaleEditField.Value,...							% scale
					APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Value);		% dist_osm_printout
				% Set and check the bounding box center AFTER calculation of the lon,lat-values:
				[  APP.LatLonXYTab_Osmosis_LatCenter_EditField.Value,...			% latcenter
					APP.LatLonXYTab_Osmosis_LonCenter_EditField.Value]=...		% loncenter
					calculator_latlon_center(...
					APP.LatLonXYTab_Osmosis_latminEditField.Value,...				% latmin
					APP.LatLonXYTab_Osmosis_latmaxEditField.Value,...				% latmax
					APP.LatLonXYTab_Osmosis_lonminEditField.Value,...				% lonmin
					APP.LatLonXYTab_Osmosis_lonmaxEditField.Value);					% lonmax
				% Compare the mean value after the calculation with the displayed center of the bounding box:
				dlatlon_max_percent		= get_difference_maporigin_boundingboxcenter(...
					APP.LatLonXYTab_Osmosis_lonminEditField.Value,...			% lonmin
					APP.LatLonXYTab_Osmosis_lonmaxEditField.Value,...			% lonmax
					APP.LatLonXYTab_Osmosis_latminEditField.Value,...			% latmin
					APP.LatLonXYTab_Osmosis_latmaxEditField.Value,...			% latmax
					APP.LatLonXYTab_Osmosis_LonCenter_EditField.Value,...		% lon_center
					APP.LatLonXYTab_Osmosis_LatCenter_EditField.Value,...		% lat_center
					lonorigin_deg,...														% lon_origin
					latorigin_deg);														% lat_origin
				if dlatlon_max_percent<1
					% The displayed center of the bounding box is equal to the mean value:
					APP.LatLonXYTab_Osmosis_CurrOriginNotAtBBCenter_Label.Visible		= 'off';
				else
					% The displayed center of the bounding box is equal to the mean value:
					APP.LatLonXYTab_Osmosis_CurrOriginNotAtBBCenter_Label.Text{1,1}		= ...
						sprintf('The origin differs to the');
					APP.LatLonXYTab_Osmosis_CurrOriginNotAtBBCenter_Label.Text{2,1}		= ...
						sprintf('bounding box center by %1.0f%%',round(dlatlon_max_percent));
					APP.LatLonXYTab_Osmosis_CurrOriginNotAtBBCenter_Label.Visible		= 'on';
				end
				% Recalculate Osmosis settings printout size:
				calculator_latlonxy_recalculate('PrintoutSize_Osmosis');
				
			case 'Map'
				% Map printout:
				[  APP.LatLonXYTab_Map_lonminEditField.Value,...					% lonmin_deg
					APP.LatLonXYTab_Map_lonmaxEditField.Value,...					% lonmax_deg
					APP.LatLonXYTab_Map_latminEditField.Value,...					% latmin_deg
					APP.LatLonXYTab_Map_latmaxEditField.Value]=...					% latmax_deg
					calculator_xy_latlon(...
					'Map',...																	% dataset
					APP.LatLonXYTab_Map_xminmmEditField.Value,...					% xmin_mm
					APP.LatLonXYTab_Map_xmaxmmEditField.Value,...					% xmax_mm
					APP.LatLonXYTab_Map_yminmmEditField.Value,...					% ymin_mm
					APP.LatLonXYTab_Map_ymaxmmEditField.Value,...					% ymax_mm
					lonorigin_deg,...															% lonorigin_deg
					latorigin_deg,...															% latorigin_deg
					APP.LatLonXYTab_ScaleEditField.Value,...							% scale
					APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Value);		% dist_osm_printout
				% Set and check the bounding box center AFTER calculation of the lon,lat-values:
				[  APP.LatLonXYTab_Map_LatCenter_EditField.Value,...				% latcenter
					APP.LatLonXYTab_Map_LonCenter_EditField.Value]=...				% loncenter
					calculator_latlon_center(...
					APP.LatLonXYTab_Map_latminEditField.Value,...					% latmin
					APP.LatLonXYTab_Map_latmaxEditField.Value,...					% latmax
					APP.LatLonXYTab_Map_lonminEditField.Value,...					% lonmin
					APP.LatLonXYTab_Map_lonmaxEditField.Value);						% lonmax
				% Compare the mean value after the calculation with the displayed center of the bounding box:
				dlatlon_max_percent		= get_difference_maporigin_boundingboxcenter(...
					APP.LatLonXYTab_Map_lonminEditField.Value,...				% lonmin
					APP.LatLonXYTab_Map_lonmaxEditField.Value,...				% lonmax
					APP.LatLonXYTab_Map_latminEditField.Value,...				% latmin
					APP.LatLonXYTab_Map_latmaxEditField.Value,...				% latmax
					APP.LatLonXYTab_Map_LonCenter_EditField.Value,...			% lon_center
					APP.LatLonXYTab_Map_LatCenter_EditField.Value,...			% lat_center
					lonorigin_deg,...														% lon_origin
					latorigin_deg);														% lat_origin
				if dlatlon_max_percent<1
					% The displayed center of the bounding box is equal to the mean value:
					APP.LatLonXYTab_Map_CurrOriginNotAtBBCenter_Label.Visible		= 'off';
				else
					% The displayed center of the bounding box is equal to the mean value:
					APP.LatLonXYTab_Map_CurrOriginNotAtBBCenter_Label.Text{1,1}		= ...
						sprintf('The origin differs to the');
					APP.LatLonXYTab_Map_CurrOriginNotAtBBCenter_Label.Text{2,1}		= ...
						sprintf('bounding box center by %1.0f%%',round(dlatlon_max_percent));
					APP.LatLonXYTab_Map_CurrOriginNotAtBBCenter_Label.Visible		= 'on';
				end
				% Recalculate map printout data printout size:
				calculator_latlonxy_recalculate('PrintoutSize_Map');
				
		end
		% Editbox formatting:
		calculator_latlonxy_format;
		return
	end
	
	% Ellipsoidal model of the figure of the Earth (needed for grn2eqa)
	ellipsoid		= referenceSphere('Earth');
	
	% Assign origin:
	origin_deg		= [latorigin_deg lonorigin_deg];
	
	% Distance between the (outer) OSM data and the (inner) map printout limits / mm:
	xmin_mm			= xmin_mm-dist_osm_printout;
	xmax_mm			= xmax_mm+dist_osm_printout;
	ymin_mm			= ymin_mm-dist_osm_printout;
	ymax_mm			= ymax_mm+dist_osm_printout;
	
	% Conversion of x, y from mm to lat, lon in degree:
	limits_c	= cell(0,0);
	% Left limit:
	limits_c{1,1}		= [xmin_mm xmin_mm]-0.01;		% x
	limits_c{1,2}		= [ymin_mm ymax_mm];				% y
	limits_c{1,3}		= 'lonmin_deg=min(lon_v); lonmin_deg=floor(lonmin_deg*100000)/100000;';		% command
	% Right limit:
	limits_c{2,1}		= [xmax_mm xmax_mm]+0.01;		% x
	limits_c{2,2}		= [ymin_mm ymax_mm];				% y
	limits_c{2,3}		= 'lonmax_deg=max(lon_v); lonmax_deg=ceil(lonmax_deg*100000)/100000;';		% command
	% Bottom limit:
	limits_c{3,1}		= [xmin_mm xmax_mm];				% x
	limits_c{3,2}		= [ymin_mm ymin_mm]-0.01;		% y
	limits_c{3,3}		= 'latmin_deg=min(lat_v); latmin_deg=floor(latmin_deg*100000)/100000;';		% command
	% Top limit:
	limits_c{4,1}		= [xmin_mm xmax_mm];				% x
	limits_c{4,2}		= [ymax_mm ymax_mm]+0.01;		% y
	limits_c{4,3}		= 'latmax_deg=max(lat_v); latmax_deg=ceil(latmax_deg*100000)/100000;';		% command
	lonmin_deg	= 999999;
	lonmax_deg	= 999999;
	latmin_deg	= 999999;
	latmax_deg	= 999999;
	% Testing:
	if testing==1
		hf	= figure(475923);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha	= axes;
		hold(ha,'on');
		xlabel(ha,'lon / degree');
		ylabel(ha,'lat/ degree');
	end
	for i_lim=1:4
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
		[  x_v_mm,...						% x
			y_v_mm...						% y
			]	= changeresolution_xy(...
			limits_c{i_lim,1},...		% x0
			limits_c{i_lim,2},...		% y0
			[],...							% dmax
			[],...							% dmin
			10000,...						% nmin
			1);								% keep_flp
		% Conversion of x, y from mm to lat, lon in degree:
		x_v_m	= x_v_mm/1000*scale;
		y_v_m	= y_v_mm/1000*scale;
		try
			[lat_v,lon_v]	= eqa2grn(x_v_m,y_v_m,origin_deg,ellipsoid);
		catch ME
			% The xy-values are invalid:
			% Replace them by the values calculated with the latlon-values:
			try
				calculator_latlon_xy(dataset);
				switch dataset
					case 'OSM'
						lonmin_deg	= APP.LatLonXYTab_OSM_lonminEditField.Value;
						lonmax_deg	= APP.LatLonXYTab_OSM_lonmaxEditField.Value;
						latmin_deg	= APP.LatLonXYTab_OSM_latminEditField.Value;
						latmax_deg	= APP.LatLonXYTab_OSM_latmaxEditField.Value;
					case 'Osmosis'
						lonmin_deg	= APP.LatLonXYTab_Osmosis_lonminEditField.Value;
						lonmax_deg	= APP.LatLonXYTab_Osmosis_lonmaxEditField.Value;
						latmin_deg	= APP.LatLonXYTab_Osmosis_latminEditField.Value;
						latmax_deg	= APP.LatLonXYTab_Osmosis_latmaxEditField.Value;
					case 'Map'
						lonmin_deg	= APP.LatLonXYTab_Map_lonminEditField.Value;
						lonmax_deg	= APP.LatLonXYTab_Map_lonmaxEditField.Value;
						latmin_deg	= APP.LatLonXYTab_Map_latminEditField.Value;
						latmax_deg	= APP.LatLonXYTab_Map_latmaxEditField.Value;
				end
				lon_v		= [lonmin_deg lonmax_deg];
				lat_v		= [latmin_deg latmax_deg];
			catch ME
				errormessage('x,y - lon,lat: Invalid input.',ME);
			end
		end
		% Command
		eval(limits_c{i_lim,3});
		% Testing:
		if testing==1
			plot(ha,lon_v,lat_v)
		end
	end
	lonmin_deg	= round(lonmin_deg,5);
	lonmax_deg	= round(lonmax_deg,5);
	latmin_deg	= round(latmin_deg,5);
	latmax_deg	= round(latmax_deg,5);
	
	% Testing:
	if (nargin==0)&&(testing==1)
		switch dataset
			case 'Map'
				APP.LatLonXYTab_Map_lonminEditField.Value	= lonmin_deg;
				APP.LatLonXYTab_Map_lonmaxEditField.Value	= lonmax_deg;
				APP.LatLonXYTab_Map_latminEditField.Value	= latmin_deg;
				APP.LatLonXYTab_Map_latmaxEditField.Value	= latmax_deg;
		end
		% Editbox formatting:
		calculator_latlonxy_format;
	end
	
	% old:
	% % Conversion of x, y from mm to lat, lon in degree:
	% xy_bounds_mm	= [...
	% 	xmin_mm		ymin_mm;...
	% 	xmax_mm		ymin_mm;...
	% 	xmax_mm		ymax_mm;...
	% 	xmin_mm		ymax_mm];
	% xy_bounds_m	= xy_bounds_mm/1000*scale;
	% [lat_bounds,lon_bounds]	= eqa2grn(xy_bounds_m(:,1),xy_bounds_m(:,2),origin_deg,ellipsoid);
	%
	% % The latlon area must cover at least this dimensions:
	% lonmin_deg		= min(lon_bounds([1 4]));
	% lonmax_deg		= max(lon_bounds([2 3]));
	% latmin_deg		= min(lat_bounds([1 2]));
	% latmax_deg		= max(lat_bounds([3 4]));
	
catch ME
	errormessage('',ME);
end


