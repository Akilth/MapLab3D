function calculator_latlonxy_format
% Editbox formatting

try
	
	format_editfield('LatLonXYTab_OSM_lonminEditField'    ,'LatLonXYTab_OSM_lonmaxEditField'    );
	format_editfield('LatLonXYTab_OSM_latminEditField'    ,'LatLonXYTab_OSM_latmaxEditField'    );
	format_editfield('LatLonXYTab_Osmosis_lonminEditField','LatLonXYTab_Osmosis_lonmaxEditField');
	format_editfield('LatLonXYTab_Osmosis_latminEditField','LatLonXYTab_Osmosis_latmaxEditField');
	format_editfield('LatLonXYTab_Map_lonminEditField'    ,'LatLonXYTab_Map_lonmaxEditField'    );
	format_editfield('LatLonXYTab_Map_latminEditField'    ,'LatLonXYTab_Map_latmaxEditField'    );
	
	format_editfield('LatLonXYTab_OSM_xminmmEditField'    ,'LatLonXYTab_OSM_xmaxmmEditField'    );
	format_editfield('LatLonXYTab_OSM_yminmmEditField'    ,'LatLonXYTab_OSM_ymaxmmEditField'    );
	format_editfield('LatLonXYTab_Osmosis_xminmmEditField','LatLonXYTab_Osmosis_xmaxmmEditField');
	format_editfield('LatLonXYTab_Osmosis_yminmmEditField','LatLonXYTab_Osmosis_ymaxmmEditField');
	format_editfield('LatLonXYTab_Map_xminmmEditField'    ,'LatLonXYTab_Map_xmaxmmEditField'    );
	format_editfield('LatLonXYTab_Map_yminmmEditField'    ,'LatLonXYTab_Map_ymaxmmEditField'    );
	
catch ME
	errormessage('',ME);
end



function format_editfield(fieldname_min,fieldname_max)

global APP GV

try
	
	if APP.(fieldname_min).Value<APP.(fieldname_max).Value
		if APP.MapLab3D.Theme.BaseColorStyle=="light"
			APP.(fieldname_min).BackgroundColor	= GV.defsettings.uieditfield.BackgroundColor.light;
			APP.(fieldname_max).BackgroundColor	= GV.defsettings.uieditfield.BackgroundColor.light;
			APP.(fieldname_min).FontColor			= GV.defsettings.uieditfield.FontColor.light;
			APP.(fieldname_max).FontColor			= GV.defsettings.uieditfield.FontColor.light;
		else
			APP.(fieldname_min).BackgroundColor	= GV.defsettings.uieditfield.BackgroundColor.dark;
			APP.(fieldname_max).BackgroundColor	= GV.defsettings.uieditfield.BackgroundColor.dark;
			APP.(fieldname_min).FontColor			= GV.defsettings.uieditfield.FontColor.dark;
			APP.(fieldname_max).FontColor			= GV.defsettings.uieditfield.FontColor.dark;
		end
	else
		if APP.MapLab3D.Theme.BaseColorStyle=="light"
			APP.(fieldname_min).BackgroundColor	= [1 0 0];
			APP.(fieldname_max).BackgroundColor	= [1 0 0];
			APP.(fieldname_min).FontColor			= GV.defsettings.uieditfield.FontColor.light;
			APP.(fieldname_max).FontColor			= GV.defsettings.uieditfield.FontColor.light;
		else
			APP.(fieldname_min).BackgroundColor	= [0.5 0 0];
			APP.(fieldname_max).BackgroundColor	= [0.5 0 0];
			APP.(fieldname_min).FontColor			= GV.defsettings.uieditfield.FontColor.dark;
			APP.(fieldname_max).FontColor			= GV.defsettings.uieditfield.FontColor.dark;
		end
	end
	
catch ME
	errormessage('',ME);
end

