function dlatlon_max_percent=get_difference_maporigin_boundingboxcenter(...
	lonmin,...			% lonmin
	lonmax,...			% lonmax
	latmin,...			% latmin
	latmax,...			% latmax
	lon_center,...		% lon_center
	lat_center,...		% lat_center
	lon_origin,...		% lon_origin
	lat_origin)			% lat_origin

try

	if nargin==0
		lonmin			= -50;		% lonmin
		lonmax			= 50;			% lonmax
		latmin			= -50;		% latmin
		latmax			= 50;			% latmax
		lon_center		= 0;			% lon_center
		lat_center		= 0;			% lat_center
		lon_origin		= 0;			% lon_origin
		lat_origin		= 1;			% lat_origin
	end

	dlon		= abs((lon_center-lon_origin)/(lonmax-lonmin));
	dlat		= abs((lat_center-lat_origin)/(latmax-latmin));
	dlatlon_max_percent	= max(dlon,dlat)*100;

catch ME
	errormessage('',ME);
end

