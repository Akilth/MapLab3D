function selpath_str = uigetdir_local(path_str,title_str)
% Execution of the function with display of the title string in the event display.

global GV APP GV_H

try

	if (nargin~=2)||(nargout~=1)
		errormessage;
	end
	text_waitbar_str					= GV_H.text_waitbar.String;
	GV_H.text_waitbar.String		= sprintf('Waiting for user input: %s',title_str);
	if APP.MapLab3D.Theme.BaseColorStyle=="light"
		APP.WaitbarUIAxes.Color		= GV.waitbar_color_userinput;
	else
		APP.WaitbarUIAxes.Color		= GV.waitbar_color_userinput/2;
	end
	% If path_str='C:\', the start path is the current directory instead of 'C:\': MATLAB bug:
	% previous_folder					= cd(path_str);					% This does not work in this case
	selpath_str							= uigetdir(path_str,title_str);
	% cd(previous_folder);
	GV_H.text_waitbar.String		= text_waitbar_str;
	if APP.MapLab3D.Theme.BaseColorStyle=="light"
		APP.WaitbarUIAxes.Color		= GV.defsettings.axes.Color.light;
	else
		APP.WaitbarUIAxes.Color		= GV.defsettings.axes.Color.dark;
	end

catch ME
	errormessage('',ME);
end



