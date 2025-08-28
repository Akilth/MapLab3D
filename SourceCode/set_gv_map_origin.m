function set_gv_map_origin
% Set the value of GV.map_origin after loading the project parameters or the OSM data

global PP APP GV OSMDATA

try

	if isempty(PP)
		% No project loaded:
		GV.map_origin(1,1)	= 0;	% Latitude
		GV.map_origin(1,2)	= 0;	% Longitude
	else
		% Project already loaded:
		if (PP.general.origin_user_lat~=999999)&&(PP.general.origin_user_lon~=999999)
			GV.map_origin(1,1)	= PP.general.origin_user_lat;	% Latitude
			GV.map_origin(1,2)	= PP.general.origin_user_lon;	% Longitude
		else
			data_loaded	= false;
			if isfield(OSMDATA,'bounds')
				% The OSM data has been loaded:
				GV.map_origin(1,1)	= ...
					(OSMDATA.bounds.minlat+OSMDATA.bounds.maxlat)/2;	% Latitude
				GV.map_origin(1,2)	= ...
					(OSMDATA.bounds.minlon+OSMDATA.bounds.maxlon)/2;	% Longitude
				data_loaded	= true;
			end
			if ~data_loaded
				% The OSM data has not been loaded:
				GV.map_origin(1,1)	= 0;	% Latitude
				GV.map_origin(1,2)	= 0;	% Longitude
			end
		end
	end

	% Update the lon,lat-x,y-calculator settings:
	if    ~isequal(APP.LatLonXYTab_OriginLatitudeEditField.Value ,GV.map_origin(1,1))||...
			~isequal(APP.LatLonXYTab_OriginLongitudeEditField.Value,GV.map_origin(1,2))
		% The origin has changed:
		APP.LatLonXYTab_OriginLatitudeEditField.Value	= GV.map_origin(1,1);	% Latitude
		APP.LatLonXYTab_OriginLongitudeEditField.Value	= GV.map_origin(1,2);	% Longitude
		% Recalculate all lon,lat-x,y-calculator data:
		calculator_latlonxy_recalculate;
	end

catch ME
	errormessage('',ME);
end

