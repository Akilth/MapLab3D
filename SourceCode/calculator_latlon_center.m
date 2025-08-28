function [latcenter,loncenter]=calculator_latlon_center(latmin,latmax,lonmin,lonmax)
% Calculates the center of a lon,lat bounding box.

try

	testing		= false;
	if testing
		testdata		= 2;
		switch testdata
			case 1
				latmin	= -80;		% -90..90
				latmax	= 80;
				lonmin	= -170;		% -180..180
				lonmax	= 170;
			case 2
				latmin	= 80;		% -90..90
				latmax	= -80;
				lonmin	= 170;		% -180..180
				lonmax	= -170;
		end
	end

	latcenter	= (latmax+latmin)/2;
	% latcenter		= mod(latcenter+ 90,180)- 90;

	if lonmax>=lonmin
		loncenter	= (lonmax+lonmin)/2;
	else
		loncenter	= (lonmax+360+lonmin)/2;
	end
	loncenter		= mod(loncenter+180,360)-180;

	if testing
		latcenter
		loncenter
	end

catch ME
	errormessage('',ME);
end

