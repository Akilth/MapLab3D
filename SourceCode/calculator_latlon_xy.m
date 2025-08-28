function [xmin_mm,xmax_mm,ymin_mm,ymax_mm]=...
	calculator_latlon_xy(...
	dataset,...
	lonmin_deg,...
	lonmax_deg,...
	latmin_deg,...
	latmax_deg,...
	lonorigin_deg,...
	latorigin_deg,...
	scale,...
	dist_osm_printout)
% This function calculates the xy coordinates of a rectangle in the mm,
% which is completely within a rectangle in latlon coordinates in degrees.

global APP

try

	testing	= 0;
	if nargin==0
		testing	= 0;
		if testing==1
			dataset	= 'Map';					% 'OSM', 'Osmosis', 'Map', 'Test'
			switch dataset
				case 'Test'
					lonmin_deg			=  8.433;
					lonmax_deg			=  8.548;
					latmin_deg			= 49.464;
					latmax_deg			= 49.514;
					lonorigin_deg		= (lonmin_deg+lonmax_deg)/2;
					latorigin_deg		= (latmin_deg+latmax_deg)/2;
					scale					= 50000;
					dist_osm_printout	= 0;
				case 'Map'
					lonmin_deg			= APP.LatLonXYTab_Map_lonminEditField.Value;
					lonmax_deg			= APP.LatLonXYTab_Map_lonmaxEditField.Value;
					latmin_deg			= APP.LatLonXYTab_Map_latminEditField.Value;
					latmax_deg			= APP.LatLonXYTab_Map_latmaxEditField.Value;
					lonorigin_deg		= APP.LatLonXYTab_OriginLongitudeEditField.Value;
					latorigin_deg		= APP.LatLonXYTab_OriginLatitudeEditField.Value;
					scale					= APP.LatLonXYTab_ScaleEditField.Value;
					dist_osm_printout	= APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Value;
			end
		else
			% OSM data:
			calculator_latlon_xy('OSM');													% dataset
			% Osmosis settings:
			calculator_latlon_xy('Osmosis');												% dataset
			% Map printout:
			calculator_latlon_xy('Map');													% dataset
			return
		end
	end

	if nargin==1
		lonorigin_deg	= APP.LatLonXYTab_OriginLongitudeEditField.Value;		% lonorigin_deg
		latorigin_deg	= APP.LatLonXYTab_OriginLatitudeEditField.Value;		% latorigin_deg
		switch dataset					% 'OSM', 'Osmosis', 'Map'

			case 'OSM'
				% OSM data:
				[  APP.LatLonXYTab_OSM_LatCenter_EditField.Value,...				% latcenter
					APP.LatLonXYTab_OSM_LonCenter_EditField.Value]=...				% loncenter
					calculator_latlon_center(...
					APP.LatLonXYTab_OSM_latminEditField.Value,...					% latmin
					APP.LatLonXYTab_OSM_latmaxEditField.Value,...					% latmax
					APP.LatLonXYTab_OSM_lonminEditField.Value,...					% lonmin
					APP.LatLonXYTab_OSM_lonmaxEditField.Value);						% lonmax
				APP.LatLonXYTab_OSM_CurrOriginNotAtBBCenter_Label.Visible		= 'off';
				if APP.LatLonXYTab_OSM_SetOriginToBBC_CheckBox.Value
					lonorigin_deg	= APP.LatLonXYTab_OSM_LonCenter_EditField.Value;
					latorigin_deg	= APP.LatLonXYTab_OSM_LatCenter_EditField.Value;
				end
				[  APP.LatLonXYTab_OSM_xminmmEditField.Value,...					% xmin_mm
					APP.LatLonXYTab_OSM_xmaxmmEditField.Value,...					% xmax_mm
					APP.LatLonXYTab_OSM_yminmmEditField.Value,...					% ymin_mm
					APP.LatLonXYTab_OSM_ymaxmmEditField.Value]=...					% ymax_mm
					calculator_latlon_xy(...
					[],...																		% dataset
					APP.LatLonXYTab_OSM_lonminEditField.Value,...					% lonmin_deg
					APP.LatLonXYTab_OSM_lonmaxEditField.Value,...					% lonmax_deg
					APP.LatLonXYTab_OSM_latminEditField.Value,...					% latmin_deg
					APP.LatLonXYTab_OSM_latmaxEditField.Value,...					% latmax_deg
					lonorigin_deg,...															% lonorigin_deg
					latorigin_deg,...															% latorigin_deg
					APP.LatLonXYTab_ScaleEditField.Value,...							% scale
					APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Value);		% dist_osm_printout
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
				[  APP.LatLonXYTab_Osmosis_LatCenter_EditField.Value,...			% latcenter
					APP.LatLonXYTab_Osmosis_LonCenter_EditField.Value]=...		% loncenter
					calculator_latlon_center(...
					APP.LatLonXYTab_Osmosis_latminEditField.Value,...				% latmin
					APP.LatLonXYTab_Osmosis_latmaxEditField.Value,...				% latmax
					APP.LatLonXYTab_Osmosis_lonminEditField.Value,...				% lonmin
					APP.LatLonXYTab_Osmosis_lonmaxEditField.Value);					% lonmax
				APP.LatLonXYTab_Osmosis_CurrOriginNotAtBBCenter_Label.Visible	= 'off';
				if APP.LatLonXYTab_Osmosis_SetOriginToBBC_CheckBox.Value
					lonorigin_deg	= APP.LatLonXYTab_Osmosis_LonCenter_EditField.Value;
					latorigin_deg	= APP.LatLonXYTab_Osmosis_LatCenter_EditField.Value;
				end
				[  APP.LatLonXYTab_Osmosis_xminmmEditField.Value,...				% xmin_mm
					APP.LatLonXYTab_Osmosis_xmaxmmEditField.Value,...				% xmax_mm
					APP.LatLonXYTab_Osmosis_yminmmEditField.Value,...				% ymin_mm
					APP.LatLonXYTab_Osmosis_ymaxmmEditField.Value]=...				% ymax_mm
					calculator_latlon_xy(...
					[],...																		% dataset
					APP.LatLonXYTab_Osmosis_lonminEditField.Value,...				% lonmin_deg
					APP.LatLonXYTab_Osmosis_lonmaxEditField.Value,...				% lonmax_deg
					APP.LatLonXYTab_Osmosis_latminEditField.Value,...				% latmin_deg
					APP.LatLonXYTab_Osmosis_latmaxEditField.Value,...				% latmax_deg
					lonorigin_deg,...															% lonorigin_deg
					latorigin_deg,...															% latorigin_deg
					APP.LatLonXYTab_ScaleEditField.Value,...							% scale
					APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Value);		% dist_osm_printout
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
				[  APP.LatLonXYTab_Map_LatCenter_EditField.Value,...				% latcenter
					APP.LatLonXYTab_Map_LonCenter_EditField.Value]=...				% loncenter
					calculator_latlon_center(...
					APP.LatLonXYTab_Map_latminEditField.Value,...					% latmin
					APP.LatLonXYTab_Map_latmaxEditField.Value,...					% latmax
					APP.LatLonXYTab_Map_lonminEditField.Value,...					% lonmin
					APP.LatLonXYTab_Map_lonmaxEditField.Value);						% lonmax
				APP.LatLonXYTab_Map_CurrOriginNotAtBBCenter_Label.Visible		= 'off';
				[  APP.LatLonXYTab_Map_xminmmEditField.Value,...					% xmin_mm
					APP.LatLonXYTab_Map_xmaxmmEditField.Value,...					% xmax_mm
					APP.LatLonXYTab_Map_yminmmEditField.Value,...					% ymin_mm
					APP.LatLonXYTab_Map_ymaxmmEditField.Value]=...					% ymax_mm
					calculator_latlon_xy(...
					[],...																		% dataset
					APP.LatLonXYTab_Map_lonminEditField.Value,...					% lonmin_deg
					APP.LatLonXYTab_Map_lonmaxEditField.Value,...					% lonmax_deg
					APP.LatLonXYTab_Map_latminEditField.Value,...					% latmin_deg
					APP.LatLonXYTab_Map_latmaxEditField.Value,...					% latmax_deg
					lonorigin_deg,...															% lonorigin_deg
					latorigin_deg,...															% latorigin_deg
					APP.LatLonXYTab_ScaleEditField.Value,...							% scale
					APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Value);		% dist_osm_printout
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

	% Assign origin:
	origin_deg		= [latorigin_deg lonorigin_deg];

	% Ellipsoidal model of the figure of the Earth (needed for grn2eqa)
	ellipsoid		= referenceSphere('Earth');

	% % Conversion of lat, lon from degrees to x,y in mm:
	limits_c	= cell(0,0);
	% Left limit:
	limits_c{1,1}		= [lonmin_deg lonmin_deg];		% lon
	limits_c{1,2}		= [latmin_deg latmax_deg];		% lat
	limits_c{1,3}		= 'xmin_mm=max(x_v_mm); xmin_mm=ceil(xmin_mm*100)/100+0.01;';		% command
	% Right limit:
	limits_c{2,1}		= [lonmax_deg lonmax_deg];		% lon
	limits_c{2,2}		= [latmin_deg latmax_deg];		% lat
	limits_c{2,3}		= 'xmax_mm=min(x_v_mm); xmax_mm=floor(xmax_mm*100)/100-0.01;';		% command
	% Bottom limit:
	limits_c{3,1}		= [lonmin_deg lonmax_deg];		% lon
	limits_c{3,2}		= [latmin_deg latmin_deg];		% lat
	limits_c{3,3}		= 'ymin_mm=max(y_v_mm); ymin_mm=ceil(ymin_mm*100)/100+0.01;';		% command
	% Top limit:
	limits_c{4,1}		= [lonmin_deg lonmax_deg];		% lon
	limits_c{4,2}		= [latmax_deg latmax_deg];		% lat
	limits_c{4,3}		= 'ymax_mm=min(y_v_mm); ymax_mm=floor(ymax_mm*100)/100-0.01;';		% command
	xmin_mm	= 999999;
	xmax_mm	= 999999;
	ymin_mm	= 999999;
	ymax_mm	= 999999;
	% Testing:
	if testing==1
		hf	= figure(475924);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha	= axes;
		hold(ha,'on');
		xlabel(ha,'x / mm');
		ylabel(ha,'y / mm');
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
		[  lon_v,...						% x
			lat_v...							% y
			]	= changeresolution_xy(...
			limits_c{i_lim,1},...		% x0
			limits_c{i_lim,2},...		% y0
			[],...							% dmax
			[],...							% dmin
			10000,...						% nmin
			1);								% keep_flp
		% Conversion of lat, lon from degrees to x,y in mm:
		try
			[x_v_m,y_v_m]	= grn2eqa(lat_v,lon_v,origin_deg,ellipsoid);
			% disp('Test in calculator_latlon_xy');
			% a=1, a(2)
		catch ME
			errormessage('Invalid input.',ME);
		end
		x_v_mm			= x_v_m*1000/scale;
		y_v_mm			= y_v_m*1000/scale;
		% Command
		eval(limits_c{i_lim,3});
		% Testing:
		if testing==1
			plot(ha,x_v_mm,y_v_mm)
		end
	end

	% Distance between the (outer) OSM data and the (inner) map printout limits / mm:
	xmin_mm	= round(xmin_mm,2)+dist_osm_printout;
	xmax_mm	= round(xmax_mm,2)-dist_osm_printout;
	ymin_mm	= round(ymin_mm,2)+dist_osm_printout;
	ymax_mm	= round(ymax_mm,2)-dist_osm_printout;

	% Testing:
	if (nargin==0)&&(testing==1)
		switch dataset
			case 'Map'
				APP.LatLonXYTab_Map_xminmmEditField.Value	= xmin_mm;
				APP.LatLonXYTab_Map_xmaxmmEditField.Value	= xmax_mm;
				APP.LatLonXYTab_Map_yminmmEditField.Value	= ymin_mm;
				APP.LatLonXYTab_Map_ymaxmmEditField.Value	= ymax_mm;
		end
		% Editbox formatting:
		calculator_latlonxy_format;
		fprintf(1,'lonmin_deg = %g\n',lonmin_deg);
		fprintf(1,'lonmax_deg = %g\n',lonmax_deg);
		fprintf(1,'latmin_deg = %g\n',latmin_deg);
		fprintf(1,'latmax_deg = %g\n',latmax_deg);
		fprintf(1,'xmin_mm = %g\n',xmin_mm);
		fprintf(1,'xmax_mm = %g\n',xmax_mm);
		fprintf(1,'ymin_mm = %g\n',ymin_mm);
		fprintf(1,'ymax_mm = %g\n',ymax_mm);
		if strcmp(dataset,'OSM')||strcmp(dataset,'Osmosis')||strcmp(dataset,'Map')
			[  lonmin_deg,...
				lonmax_deg,...
				latmin_deg,...
				latmax_deg]=...
				calculator_xy_latlon(...
				dataset,...
				xmin_mm,...
				xmax_mm,...
				ymin_mm,...
				ymax_mm,...
				lonorigin_deg,...
				latorigin_deg,...
				scale,...
				dist_osm_printout);
			fprintf(1,'lonmin_deg = %g\n',lonmin_deg);
			fprintf(1,'lonmax_deg = %g\n',lonmax_deg);
			fprintf(1,'latmin_deg = %g\n',latmin_deg);
			fprintf(1,'latmax_deg = %g\n',latmax_deg);
			calculator_latlonxy_plot(dataset);
		end
	end

catch ME
	errormessage('',ME);
end

