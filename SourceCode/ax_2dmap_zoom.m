function ax_2dmap_zoom(action,x1,y1,x2,y2)
% Zoom into the 2D map:
% -	ax_2dmap_zoom('set',x1,y1,x2,y2)							Set the axis limits
% -	ax_2dmap_zoom('reset_zoom',x1,y1,x2,y2)				Reset the axis limits to the previous/current values
% -	ax_2dmap_zoom('reset_zoom_history',x1,y1,x2,y2)		Reset the zoom history (when creating the map anew)
% -	ax_2dmap_zoom('undo',x1,y1,x2,y2)						Undo change to the map view
% -	ax_2dmap_zoom('redo',x1,y1,x2,y2)						Redo change to the map view
% -	ax_2dmap_zoom('button_update')							Update only the button appearance

global GV GV_H APP

% Because this function can be called directly by the user through a callback,
% a try/catch statement must be used here:
try
	
	if ~strcmp(action,'button_update')
		
		if ~isfield(GV_H,'ax_2dmap')
			return
		end
		if ~ishandle(GV_H.ax_2dmap)
			return
		end
		if    isfield(GV,'ax_2dmap_xlim_last')&&...
				isfield(GV,'ax_2dmap_ylim_last')&&...
				isfield(GV,'ax_2dmap_i_xylim_last')
			if ~isequal(size(GV.ax_2dmap_xlim_last),size(GV.ax_2dmap_ylim_last))||...
					(GV.ax_2dmap_i_xylim_last>size(GV.ax_2dmap_xlim_last,1))
				errormessage;
			end
		end
		
		% Maximum number of undo and redo actions:
		no_undo_redo_max	= 100;
		
		switch action
			case 'set'
				% Set the axis limits:
				[x1,y1,x2,y2]=ax_2dmap_zoomin(x1,y1,x2,y2);
				% Save the axis limits:
				if    ~isfield(GV,'ax_2dmap_xlim_last')||...
						~isfield(GV,'ax_2dmap_ylim_last')||...
						~isfield(GV,'ax_2dmap_i_xylim_last')
					% Set the axis limits the first time:
					GV.ax_2dmap_xlim_last		= GV_H.ax_2dmap.XLim;
					GV.ax_2dmap_ylim_last		= GV_H.ax_2dmap.YLim;
					GV.ax_2dmap_i_xylim_last	= 1;
				else
					% Save the new axis limits:
					if    (abs(GV.ax_2dmap_xlim_last(GV.ax_2dmap_i_xylim_last,1)-min([x1 x2]))>GV.tol_1)||...
							(abs(GV.ax_2dmap_xlim_last(GV.ax_2dmap_i_xylim_last,2)-max([x1 x2]))>GV.tol_1)||...
							(abs(GV.ax_2dmap_ylim_last(GV.ax_2dmap_i_xylim_last,1)-min([y1 y2]))>GV.tol_1)||...
							(abs(GV.ax_2dmap_ylim_last(GV.ax_2dmap_i_xylim_last,2)-max([y1 y2]))>GV.tol_1)
						% The new axis limits are different from the current axis limits:
						GV.ax_2dmap_i_xylim_last												= GV.ax_2dmap_i_xylim_last+1;
						GV.ax_2dmap_xlim_last(GV.ax_2dmap_i_xylim_last,:)				= GV_H.ax_2dmap.XLim;
						GV.ax_2dmap_ylim_last(GV.ax_2dmap_i_xylim_last,:)				= GV_H.ax_2dmap.YLim;
						% Delete possibly redo actions:
						GV.ax_2dmap_xlim_last((GV.ax_2dmap_i_xylim_last+1):end,:)	= [];
						GV.ax_2dmap_ylim_last((GV.ax_2dmap_i_xylim_last+1):end,:)	= [];
						% Keep the maximum number of undo and redo actions:
						if size(GV.ax_2dmap_xlim_last,1)>no_undo_redo_max
							GV.ax_2dmap_i_xylim_last		= GV.ax_2dmap_i_xylim_last-1;
							GV.ax_2dmap_xlim_last(1,:)		= [];
							GV.ax_2dmap_ylim_last(1,:)		= [];
						end
					end
				end
				
			case 'reset_zoom'
				% Reset the axis limits to the previous/current values:
				if    isfield(GV,'ax_2dmap_xlim_last')&&...
						isfield(GV,'ax_2dmap_ylim_last')&&...
						isfield(GV,'ax_2dmap_i_xylim_last')
					x1									= GV.ax_2dmap_xlim_last(GV.ax_2dmap_i_xylim_last,1);
					x2									= GV.ax_2dmap_xlim_last(GV.ax_2dmap_i_xylim_last,2);
					y1									= GV.ax_2dmap_ylim_last(GV.ax_2dmap_i_xylim_last,1);
					y2									= GV.ax_2dmap_ylim_last(GV.ax_2dmap_i_xylim_last,2);
					ax_2dmap_zoomin(x1,y1,x2,y2);
				end
				
			case 'reset_zoom_history'
				% Reset the zoom history (when creating the map anew):
				GV		= rmfield(GV,'ax_2dmap_xlim_last');
				GV		= rmfield(GV,'ax_2dmap_ylim_last');
				GV		= rmfield(GV,'ax_2dmap_i_xylim_last');
				xlim_new		= GV_H.ax_2dmap.XLim;
				ylim_new		= GV_H.ax_2dmap.YLim;
				ax_2dmap_zoom('set',xlim_new(1),ylim_new(1),xlim_new(2),ylim_new(2));
				
			case 'undo'
				if GV.ax_2dmap_i_xylim_last>1
					% Axis limits:
					GV.ax_2dmap_i_xylim_last	= GV.ax_2dmap_i_xylim_last-1;
					x1									= GV.ax_2dmap_xlim_last(GV.ax_2dmap_i_xylim_last,1);
					x2									= GV.ax_2dmap_xlim_last(GV.ax_2dmap_i_xylim_last,2);
					y1									= GV.ax_2dmap_ylim_last(GV.ax_2dmap_i_xylim_last,1);
					y2									= GV.ax_2dmap_ylim_last(GV.ax_2dmap_i_xylim_last,2);
					% Set the axis limits:
					ax_2dmap_zoomin(x1,y1,x2,y2);
				end
				
			case 'redo'
				if GV.ax_2dmap_i_xylim_last<size(GV.ax_2dmap_xlim_last,1)
					% Axis limits:
					GV.ax_2dmap_i_xylim_last	= GV.ax_2dmap_i_xylim_last+1;
					x1									= GV.ax_2dmap_xlim_last(GV.ax_2dmap_i_xylim_last,1);
					x2									= GV.ax_2dmap_xlim_last(GV.ax_2dmap_i_xylim_last,2);
					y1									= GV.ax_2dmap_ylim_last(GV.ax_2dmap_i_xylim_last,1);
					y2									= GV.ax_2dmap_ylim_last(GV.ax_2dmap_i_xylim_last,2);
					% Set the axis limits:
					ax_2dmap_zoomin(x1,y1,x2,y2);
				end
				
		end
	end
	
	% Button appearance:
	if ~isfield(GV,'ax_2dmap_i_xylim_last')
		undo_grayedout		= true;
	else
		if GV.ax_2dmap_i_xylim_last==1
			undo_grayedout		= true;
		else
			undo_grayedout		= false;
		end
	end
	if ~isfield(GV,'ax_2dmap_i_xylim_last')||~isfield(GV,'ax_2dmap_xlim_last')
		redo_grayedout		= true;
	else
		if GV.ax_2dmap_i_xylim_last==size(GV.ax_2dmap_xlim_last,1)
			redo_grayedout		= true;
		else
			redo_grayedout		= false;
		end
	end
	if undo_grayedout
		if APP.MapLab3D.Theme.BaseColorStyle=="light"
			APP.MapView_UnDo_Button.Icon	= APP.MapView_UnDo_Button.UserData.Icon_UnDo_grayedout_light;
		else
			APP.MapView_UnDo_Button.Icon	= APP.MapView_UnDo_Button.UserData.Icon_UnDo_grayedout_dark;
		end
	else
		if APP.MapLab3D.Theme.BaseColorStyle=="light"
			APP.MapView_UnDo_Button.Icon	= APP.MapView_UnDo_Button.UserData.Icon_UnDo_light;
		else
			APP.MapView_UnDo_Button.Icon	= APP.MapView_UnDo_Button.UserData.Icon_UnDo_dark;
		end
	end
	if redo_grayedout
		if APP.MapLab3D.Theme.BaseColorStyle=="light"
			APP.MapView_ReDo_Button.Icon	= APP.MapView_ReDo_Button.UserData.Icon_ReDo_grayedout_light;
		else
			APP.MapView_ReDo_Button.Icon	= APP.MapView_ReDo_Button.UserData.Icon_ReDo_grayedout_dark;
		end
	else
		if APP.MapLab3D.Theme.BaseColorStyle=="light"
			APP.MapView_ReDo_Button.Icon	= APP.MapView_ReDo_Button.UserData.Icon_ReDo_light;
		else
			APP.MapView_ReDo_Button.Icon	= APP.MapView_ReDo_Button.UserData.Icon_ReDo_dark;
		end
	end
	
catch ME
	errormessage('',ME);
end
