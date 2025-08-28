function timer_timerfcn
% Timer callback function

global APP GV GV_H TIMERPROCESS TIMERPROCESS_RESTART

% Because this function can be called through a callback, a try/catch statement must be used here:
try
	
	% Switch on ShowHiddenHandles: problem:
	% HandleVisibility=callback applies to the app's figure handles to protect them from unauthorized user input.
	% However, when functions from the timer process access the interface, these handles are not visible!
	% Therefore, all handles must be made visible to the timer process.
	set(0,'ShowHiddenHandles','on');
	
	if ~isempty(APP)
		if isvalid(APP)
			if isvalid(APP.MapLab3D)
				% The app is running:
				
				% --------------------------------------------------------------------------------------------------------
				% Insert regularly executed code here:
				
				% In MATLAB 2025a, you can create a ThemeChanged callback and it works initially, but after restarting
				% the app designer, the message "MapLab3DThemeChanged is not associated with a component" appears in
				% the list of callbacks for this function and the callback is no longer called:
				% % % % Theme changed function: MapLab3D
				% % % function MapLab3DThemeChanged(app, event)
				% % % 	try
				% % % 		update_color_theme('set',false);
				% % % 	catch ME
				% % % 		errormessage('',ME);
				% % % 	end
				% % %
				% % % end
				% Perhaps it will work in a later version. Then the code here can be hidden and the timer turned off:
				% GV.timer_activated=false;
				
				% Check wether the color theme (light/dark) has been changed:
				if isfield(GV,'Theme_BaseColorStyle')
					% if    ~isequal(GV.Theme_BaseColorStyle,APP.MapLab3D.Theme.BaseColorStyle)||(...
					% 		isequal(APP.MapLab3D.Color,GV.defsettings.FigureColor.light)&&...
					% 		strcmp(APP.MapLab3D.Theme.BaseColorStyle,'light')                 )||(...
					% 		isequal(APP.MapLab3D.Color,GV.defsettings.FigureColor.dark )&&...
					% 		strcmp(APP.MapLab3D.Theme.BaseColorStyle,'dark')                  )
					if    ~isequal(GV.Theme_BaseColorStyle,APP.MapLab3D.Theme.BaseColorStyle)
						update_color_theme('set',false);
						fprintf(1,'\nColor theme updated\n\n');
					end
				end
				
				% Deactivated !!!
				% A better solution is to set APP.MapLab3D.Resize=true: The figure size can be set manually
				% (APP.MapLab3D.AutoResizeChildren: off)
				check_figsize		= 0;
				switch check_figsize
					case 1
						% This does not work if the app is shifted to a second screen, that has different screen size!
						
						% Sometimes it happens that the window has the same dimensions after standby mode, but the content is
						% enlarged. This can be recognized and corrected using the width or height in APP.MapLab3D.Position:
						if APP.MapLab3D.Position(3)~=GV_H.maplab3d.figure.mot_off.pos0(3)
							t_pause		= 0.5;
							% Current upper position:
							y_top			= APP.MapLab3D.Position(2)+APP.MapLab3D.Position(4);
							% Position at app start: nominal width and height:
							if GV_H.maplab3d.mapobjectstable_ison
								% The map objects table is not hidden:
								pos0		= GV_H.maplab3d.figure.mot_on.pos0;
							else
								% The map objects table is hidden:
								pos0		= GV_H.maplab3d.figure.mot_off.pos0;
							end
							
							% % Limit y_top to the initial value to prevent the app from moving off the screen:
							% screen_size	= get(0,'ScreenSize');
							% y_top			= min(y_top,pos0(2)+pos0(4));
							% y_top			= min(y_top,screen_size(4));
							
							% Nominal bottom position:
							y_bot			= y_top-pos0(4);
							% % Limit y_bot to the initial value to prevent the app from moving off the screen:
							% y_bot			= max(y_bot,pos0(2));
							
							% % Limit the position in x-direction:
							% x_min			= 1;
							% x_max			= screen_size(3)-pos0(3);
							
							i		= 1;
							if ~isdeployed
								fprintf(1,'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
								fprintf(1,'%s\n',datetime('now','Format','yyyy-MMM-dd HH.mm.ss'));
								fprintf(1,'Change MapLab3D figure size\n');
								fprintf(1,'pos0                  = [%g %g %g %g]\n',pos0(1),pos0(2),pos0(3),pos0(4));
								fprintf(1,'y_top                 = %g\n',y_top);
								fprintf(1,'y_bot                 = %g\n',y_bot);
								fprintf(1,'APP.MapLab3D.Position = [%g %g %g %g]\n',...
									APP.MapLab3D.Position(1),...
									APP.MapLab3D.Position(2),...
									APP.MapLab3D.Position(3),...
									APP.MapLab3D.Position(4));
							end
							while (i<=100)&&(...
									(APP.MapLab3D.Position(3)~=pos0(3))||...
									(APP.MapLab3D.Position(4)~=pos0(4))     )
								APP.MapLab3D.Position(3)	= pos0(3);
								pause(t_pause);
								APP.MapLab3D.Position(4)	= pos0(4);
								pause(t_pause);
								APP.MapLab3D.Position(2)	= y_bot;
								pause(t_pause);
								
								% if APP.MapLab3D.Position(1)<x_min
								% 	APP.MapLab3D.Position(1)	= x_min;
								% 	pause(t_pause);
								% end
								% if APP.MapLab3D.Position(1)>x_max
								% 	APP.MapLab3D.Position(1)	= x_max;
								% 	pause(t_pause);
								% end
								
								if ~isdeployed
									fprintf(1,'APP.MapLab3D.Position = [%g %g %g %g] ;  i = %g\n',...
										APP.MapLab3D.Position(1),...
										APP.MapLab3D.Position(2),...
										APP.MapLab3D.Position(3),...
										APP.MapLab3D.Position(4),i);
								end
								i									= i+1;
							end
							if ~isdeployed
								fprintf(1,'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
							end
						end
						
				end
				
				% Indication with flashing light that the timer is active:
				if GV.timer_signal_lamp_blink
					stateisbusy	= display_on_gui('state','','isbusy');
					if stateisbusy
						% State is 'busy' (red):
						% nop
					else
						% State is 'notbusy' (green):
						if isequal(APP.StateTextArea.BackgroundColor,[0 1 0])		% green
							% switch off:
							APP.StateTextArea.BackgroundColor		= [0.7 1 0.7];
						else
							% switch on:
							APP.StateTextArea.BackgroundColor		= [0 1 0];
						end
					end
				end
				
				% --------------------------------------------------------------------------------------------------------
				
			else
				% The app has been closed:
				TIMERPROCESS_RESTART		= 0;
				stop(TIMERPROCESS);
				delete(TIMERPROCESS);
			end
		else
			% The app has been closed:
			TIMERPROCESS_RESTART		= 0;
			stop(TIMERPROCESS);
			delete(TIMERPROCESS);
		end
	else
		% The app has not been started:
		TIMERPROCESS_RESTART		= 0;
		stop(TIMERPROCESS);
		delete(TIMERPROCESS);
	end
	
	% Switch off ShowHiddenHandles:
	set(0,'ShowHiddenHandles','off');
	
catch ME
	errormessage('',ME);
end




