function ax_2dmap_zoominbutton_bgdcolor

global APP GV

try
	
	if APP.MapView_In_Button.Value==0
		if APP.MapLab3D.Theme.BaseColorStyle=="light"
			APP.MapView_In_Button.BackgroundColor	= GV.defsettings.uibutton.BackgroundColor.light;
			APP.MapView_In_Button.FontColor			= GV.defsettings.uibutton.FontColor.light;
		else
			APP.MapView_In_Button.BackgroundColor	= GV.defsettings.uibutton.BackgroundColor.dark;
			APP.MapView_In_Button.FontColor			= GV.defsettings.uibutton.FontColor.dark;
		end
	else
		APP.MapView_In_Button.BackgroundColor		= [0 1 0];
		APP.MapView_In_Button.FontColor				= GV.defsettings.uibutton.FontColor.light;
	end
	
catch ME
	errormessage('',ME);
end

