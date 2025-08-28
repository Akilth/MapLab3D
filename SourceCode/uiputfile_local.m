function [file_str,location_str] = uiputfile_local(filter_str,title_str,defname_str)
% Execution of the function with display of the title string in the event display.

global GV APP GV_H

try

	if (nargin~=3)||(nargout~=2)
		errormessage;
	end
	text_waitbar_str				= GV_H.text_waitbar.String;
	GV_H.text_waitbar.String	= sprintf('Waiting for user input: %s',title_str);
	if APP.MapLab3D.Theme.BaseColorStyle=="light"
		APP.WaitbarUIAxes.Color		= GV.waitbar_color_userinput;
	else
		APP.WaitbarUIAxes.Color		= GV.waitbar_color_userinput/2;
	end
	[file_str,location_str]		= uiputfile(filter_str,title_str,defname_str);
	GV_H.text_waitbar.String		= text_waitbar_str;
	if APP.MapLab3D.Theme.BaseColorStyle=="light"
		APP.WaitbarUIAxes.Color		= GV.defsettings.axes.Color.light;
	else
		APP.WaitbarUIAxes.Color		= GV.defsettings.axes.Color.dark;
	end

catch ME
	errormessage('',ME);
end

