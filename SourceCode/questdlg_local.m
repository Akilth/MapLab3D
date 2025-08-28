function answer = questdlg_local(quest,dlgtitle,par1,par2,par3,par4)
% Execution of the function with display of the title string in the event display.
% Syntax:
% answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn)
% answer = questdlg(quest,dlgtitle,btn1,btn2,btn3,defbtn)

global GV APP GV_H

try

	if nargout~=1
		errormessage;
	end
	text_waitbar_str				= GV_H.text_waitbar.String;
	GV_H.text_waitbar.String	= sprintf('Waiting for user input: %s',dlgtitle);
	if APP.MapLab3D.Theme.BaseColorStyle=="light"
		APP.WaitbarUIAxes.Color		= GV.waitbar_color_userinput;
	else
		APP.WaitbarUIAxes.Color		= GV.waitbar_color_userinput/2;
	end
	switch nargin
		case 5
			% answer = questdlg(quest,dlgtitle,btn1,btn2,defbtn)
			if ~ischar(par3)
				% If syntax is: answer = questdlg(quest,dlgtitle,btn1,btn2,opts)
				errormessage;
			end
			answer = questdlg(quest,dlgtitle,par1,par2,par3);
		case 6
			% answer = questdlg(quest,dlgtitle,btn1,btn2,btn3,defbtn)
			if ~ischar(par4)
				% If syntax is: answer = questdlg(quest,dlgtitle,btn1,btn2,btn3,opts)
				errormessage;
			end
			answer = questdlg(quest,dlgtitle,par1,par2,par3,par4);
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

