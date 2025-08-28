function answer = inputdlg_local(prompt,dlgtitle,fieldsize,definput)
% Execution of the function with display of the title string in the event display.

global GV APP GV_H

try
	
	if nargout~=1
		errormessage;
	end
	text_waitbar_str					= GV_H.text_waitbar.String;
	GV_H.text_waitbar.String		= sprintf('Waiting for user input: %s',dlgtitle);
	if APP.MapLab3D.Theme.BaseColorStyle=="light"
		APP.WaitbarUIAxes.Color		= GV.waitbar_color_userinput;
	else
		APP.WaitbarUIAxes.Color		= GV.waitbar_color_userinput/2;
	end
	switch nargin
		case 4
			answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
		case 2
			answer = inputdlg(prompt,dlgtitle);
		otherwise
			errormessage;
	end
	GV_H.text_waitbar.String		= text_waitbar_str;
	if APP.MapLab3D.Theme.BaseColorStyle=="light"
		APP.WaitbarUIAxes.Color		= GV.defsettings.axes.Color.light;
	else
		APP.WaitbarUIAxes.Color		= GV.defsettings.axes.Color.dark;
	end
	
catch ME
	errormessage('',ME);
end

