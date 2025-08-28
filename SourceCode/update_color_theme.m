function update_color_theme(par,disp_on_gui)
% Color themes light/dark:
% Get initial values when starting the app:
% update_color_theme('init',false);
% Update color scheme:
% update_color_theme('set',false);

global APP GV GV_H

try
	
	% Testing:
	if nargin==0
		par			= 'set';
		disp_on_gui	= true;
	end
	
	% Display state:
	if disp_on_gui
		stateisbusy	= display_on_gui('state','','isbusy');
		if ~stateisbusy
			display_on_gui('state','Update color theme ...','busy','add');
		end
	end
	
	switch par
		case 'init'
			fn						= fieldnames(APP);
			% strcmp(APP.(fn{k,1}).Type,'uibutton')
			% strcmp(APP.(fn{k,1}).Type,'uibuttongroup')
			% strcmp(APP.(fn{k,1}).Type,'uitogglebutton')
			% strcmp(APP.(fn{k,1}).Type,'uistatebutton')
			% strcmp(APP.(fn{k,1}).Type,'uinumericeditfield')
			% strcmp(APP.(fn{k,1}).Type,'uieditfield')
			% strcmp(APP.(fn{k,1}).Type,'uidropdown')
			% strcmp(APP.(fn{k,1}).Type,'uislider')
			% strcmp(APP.(fn{k,1}).Type,'uitable')
			% strcmp(APP.(fn{k,1}).Type,'uicheckbox')
			
			% uiimage
			for k=1:size(fn,1)
				switch APP.(fn{k,1}).Type
					case 'uiimage'
						info	= imfinfo(APP.(fn{k,1}).ImageSource);
						if strcmp(info.Transparency,'none')
							APP.(fn{k,1}).UserData.ImageSource_file	= APP.(fn{k,1}).ImageSource;
							im														= imread(APP.(fn{k,1}).ImageSource);
							APP.(fn{k,1}).UserData.ImageSource_light	= im;
							APP.(fn{k,1}).UserData.ImageSource_dark	= fliplightness(im);
						end
					case 'uibutton'
						if ~isempty(APP.(fn{k,1}).Icon)
							info	= imfinfo(APP.(fn{k,1}).Icon);
							if strcmp(info.Transparency,'none')
								APP.(fn{k,1}).UserData.Icon_file			= APP.(fn{k,1}).Icon;
								im													= imread(APP.(fn{k,1}).Icon);
								APP.(fn{k,1}).UserData.Icon_light		= im;
								APP.(fn{k,1}).UserData.Icon_dark			= fliplightness(im);
							end
						end
				end
			end
			
			% Map view undo button:
			% APP.MapView_UnDo_Button.UserData		= [];
			im			= imread('UnDo.png');
			APP.MapView_UnDo_Button.UserData.Icon_UnDo_light				= im;
			APP.MapView_UnDo_Button.UserData.Icon_UnDo_dark					= fliplightness(im);
			im			= imread('UnDo_grayedout.png');
			APP.MapView_UnDo_Button.UserData.Icon_UnDo_grayedout_light	= im;
			APP.MapView_UnDo_Button.UserData.Icon_UnDo_grayedout_dark	= fliplightness(im);
			
			% Map view redo button:
			% APP.MapView_ReDo_Button.UserData		= [];
			im			= imread('ReDo.png');
			APP.MapView_ReDo_Button.UserData.Icon_ReDo_light				= im;
			APP.MapView_ReDo_Button.UserData.Icon_ReDo_dark					= fliplightness(im);
			im			= imread('ReDo_grayedout.png');
			APP.MapView_ReDo_Button.UserData.Icon_ReDo_grayedout_light	= im;
			APP.MapView_ReDo_Button.UserData.Icon_ReDo_grayedout_dark	= fliplightness(im);
			
		case 'set'
			
			GV.Theme_BaseColorStyle				= APP.MapLab3D.Theme.BaseColorStyle;
			
			fn						= fieldnames(APP);
			for k=1:size(fn,1)
				switch APP.(fn{k,1}).Type
					case 'uiimage'
						% Uiimages:
						if ~isempty(APP.(fn{k,1}).UserData)
							if APP.MapLab3D.Theme.BaseColorStyle=="light"
								APP.(fn{k,1}).ImageSource		= APP.(fn{k,1}).UserData.ImageSource_light;
							else
								APP.(fn{k,1}).ImageSource		= APP.(fn{k,1}).UserData.ImageSource_dark;
							end
						end
					case {'uistatebutton','uibutton','uitogglebutton'}
						% Backgroundcolor and Fontcolor of Uibuttons:
						if ~(strcmp(fn{k,1},'MapView_In_Button')&&(APP.MapView_In_Button.Value~=0))
							if APP.MapLab3D.Theme.BaseColorStyle=="light"
								APP.(fn{k,1}).BackgroundColor	= GV.defsettings.uibutton.BackgroundColor.light;
								APP.(fn{k,1}).FontColor			= GV.defsettings.uibutton.FontColor.light;
							else
								APP.(fn{k,1}).BackgroundColor	= GV.defsettings.uibutton.BackgroundColor.dark;
								APP.(fn{k,1}).FontColor			= GV.defsettings.uibutton.FontColor.dark;
							end
						end
						% Uibuttons with Icon:
						if ~isempty(APP.(fn{k,1}).UserData)
							if APP.MapLab3D.Theme.BaseColorStyle=="light"
								APP.(fn{k,1}).Icon				= APP.(fn{k,1}).UserData.Icon_light;
							else
								APP.(fn{k,1}).Icon				= APP.(fn{k,1}).UserData.Icon_dark;
							end
						end
					case 'figure'
						% Backgroundcolor of figures:
						if APP.MapLab3D.Theme.BaseColorStyle=="light"
							APP.(fn{k,1}).Color					= GV.defsettings.figure.color.light;
						else
							APP.(fn{k,1}).Color					= GV.defsettings.figure.color.dark;
						end
					case 'uitab'
						% Backgroundcolor of uitabs:
						if APP.MapLab3D.Theme.BaseColorStyle=="light"
							APP.(fn{k,1}).BackgroundColor		= GV.defsettings.uitab.BackgroundColor.light;
						else
							APP.(fn{k,1}).BackgroundColor		= GV.defsettings.uitab.BackgroundColor.dark;
						end
					case {'uinumericeditfield' 'uieditfield'}
						% Backgroundcolor of uieditfields:
						if ~isequal(APP.(fn{k,1}).BackgroundColor,[1 0 0])
							if APP.MapLab3D.Theme.BaseColorStyle=="light"
								APP.(fn{k,1}).BackgroundColor		= GV.defsettings.uieditfield.BackgroundColor.light;
								APP.(fn{k,1}).FontColor				= GV.defsettings.uieditfield.FontColor.light;
							else
								APP.(fn{k,1}).BackgroundColor		= GV.defsettings.uieditfield.BackgroundColor.dark;
								APP.(fn{k,1}).FontColor				= GV.defsettings.uieditfield.FontColor.dark;
							end
						end
					case 'axes'
						% Backgroundcolor of axes:
						if APP.MapLab3D.Theme.BaseColorStyle=="light"
							APP.(fn{k,1}).Color					= GV.defsettings.axes.Color.light;
						else
							APP.(fn{k,1}).Color					= GV.defsettings.axes.Color.dark;
						end
						
				end
			end
			
			% Event display:
			if APP.MapLab3D.Theme.BaseColorStyle=="light"
				GV_H.text_waitbar.Color			= GV.defsettings.text.FontColor.light;
				GV_H.patch_waitbar.FaceColor	= [0 1 0];
			else
				GV_H.text_waitbar.Color			= GV.defsettings.text.FontColor.dark;
				GV_H.patch_waitbar.FaceColor	= [0 0.5 0];
			end
			
			% Map view undo/redo button:
			ax_2dmap_zoom('button_update')
			
		otherwise
			errormessage;
	end
	
	% Display state:
	if disp_on_gui
		if ~stateisbusy
			display_on_gui('state','Update color theme ... finished','notbusy','replace');
		end
	end
	
catch ME
	errormessage('',ME);
end










