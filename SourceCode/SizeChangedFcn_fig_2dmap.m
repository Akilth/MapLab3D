function SizeChangedFcn_fig_2dmap(src,event,reset,fit)
% Syntax:
% SizeChangedFcn_fig_2dmap([],[],0,0);		Set the axis position after changing the figure size.
% SizeChangedFcn_fig_2dmap([],[],1,0);		Reset also the axis scaling: to the current zoom values
% SizeChangedFcn_fig_2dmap([],[],1,1);		Reset also the axis scaling: Fit: Zoom on the printout limits.
% SizeChangedFcn_fig_2dmap([],[],1,2);		Reset also the axis scaling: All: Zoom on the OSM data and the tiles.

global GV_H

% Because this function can be called directly by the user through a callback,
% a try/catch statement must be used here:
try

	if ~isfield(GV_H,'fig_2dmap')
		return
	end
	if ~ishandle(GV_H.fig_2dmap)
		return
	end
	if ~isfield(GV_H,'ax_2dmap')
		return
	end
	if ~ishandle(GV_H.ax_2dmap)
		return
	end

	% Axis position:
	GV_H.ax_2dmap.PositionConstraint		= 'innerposition';
	margin_left		= 60;		% 60: -9000..+9000
	margin_right	= 15;		% 12: +9000 / 15: equal to top
	margin_bottom	= 42;		% 42: x10^4
	margin_top		= 15;		% 5: Standard / 15: x10^4
	fig_2dmap_w	= GV_H.fig_2dmap.Position(1,3);
	fig_2dmap_h	= GV_H.fig_2dmap.Position(1,4);
	ax_2dmap_w	= fig_2dmap_w-(margin_left+margin_right);
	ax_2dmap_h	= fig_2dmap_h-(margin_bottom+margin_top);
	GV_H.ax_2dmap.InnerPosition		= [...
		margin_left ...			% left
		margin_bottom ...			% bottom
		ax_2dmap_w ...				% width
		ax_2dmap_h];				% height
	
	% Reset axis scaling:
	if reset==1
		
		% Autoscale:
		GV_H.ax_2dmap.XLimMode						= 'auto';
		GV_H.ax_2dmap.YLimMode						= 'auto';
		GV_H.ax_2dmap.PlotBoxAspectRatioMode	= 'auto';
		GV_H.ax_2dmap.DataAspectRatioMode		= 'auto';
		
		% Now the GV_H.ax_2dmap.InnerPosition should be as assigned above.
		pbar			= GV_H.ax_2dmap.PlotBoxAspectRatio;			% save the axis box size
		GV_H.ax_2dmap.DataAspectRatio				= [1 1 1];		% this changes the axis box size
		GV_H.ax_2dmap.PlotBoxAspectRatioMode	= 'manual';
		dy_dx			= diff(GV_H.ax_2dmap.YLim)/diff(GV_H.ax_2dmap.XLim);
		pbar_h_w		= pbar(2)/pbar(1);
		% or: pbar_h_w = GV_H.ax_2dmap.InnerPosition(4)/GV_H.ax_2dmap.InnerPosition(3)
		% After setting the DataAspectRatio=[1 1 1] or axis(GV_H.ax_2dmap,'equal') the values
		% GV_H.ax_2dmap.InnerPosition are wrong (Matlab bug?).
		% Increas the axis box size by changing the axis limits:
		if dy_dx>pbar_h_w
			% Set XLim:
			GV_H.ax_2dmap.XLim	= mean(GV_H.ax_2dmap.XLim)+[-0.5 0.5]*diff(GV_H.ax_2dmap.XLim)*dy_dx/pbar_h_w;
		else
			% Set YLim:
			GV_H.ax_2dmap.YLim	= mean(GV_H.ax_2dmap.YLim)+[-0.5 0.5]*diff(GV_H.ax_2dmap.YLim)*pbar_h_w/dy_dx;
		end
		
		% Save the axis limits in the userdata, will be used in ButtonDownFcn_ax_2dmap for the zoom in function:
		ud				= [];
		ud.xlim0		= GV_H.ax_2dmap.XLim;
		ud.ylim0		= GV_H.ax_2dmap.YLim;
		xlim_new		= GV_H.ax_2dmap.XLim;
		ylim_new		= GV_H.ax_2dmap.YLim;
		GV_H.ax_2dmap.UserData	= ud;
		
		% Set the axis limits:
		if fit~=0
			% Set map limits:
			% fit=1: Zoom on the printout limits.
			% fit=2: Zoom on the OSM data and the tiles.		
			if isfield(GV_H,'poly_map_printout_obj_limits')
				if numboundaries(GV_H.poly_map_printout_obj_limits.Shape)>0
					tile_no_max		= 0;
					if isfield(GV_H,'poly_tiles')
						tile_no_max		= size(GV_H.poly_tiles,1);
					end
					imax			= 3+tile_no_max;
					i				= 0;
					xlim			= ones(imax,2)*1e10;
					ylim			= ones(imax,2)*1e10;
					xlim(:,2)	= -xlim(:,2);
					ylim(:,2)	= -ylim(:,2);
					i = i+1; [xlim(i,:),ylim(i,:)] = boundingbox(GV_H.poly_map_printout_obj_limits.Shape);
					i = i+1; [xlim(i,:),ylim(i,:)] = boundingbox(GV_H.poly_map_printout_obj_limits.Shape);
					if fit==2
						if    isfield(GV_H,'poly_limits_osmdata')         &&...
								isfield(GV_H,'poly_tiles')
							if    (numboundaries(GV_H.poly_limits_osmdata.Shape)         >0)&&...
									iscell(GV_H.poly_tiles)
								i = i+1; [xlim(i,:),ylim(i,:)] = boundingbox(GV_H.poly_limits_osmdata.Shape);
								for tile_no=1:tile_no_max
									i = i+1; [xlim(i,:),ylim(i,:)] = boundingbox(GV_H.poly_tiles{tile_no,1}.Shape);
								end
							end
						end
					end
					xmin			= min(xlim(:,1));
					xmax			= max(xlim(:,2));
					ymin			= min(ylim(:,1));
					ymax			= max(ylim(:,2));
					xlim_new		= [xmin xmax]+[-1 1]*(xmax-xmin)*0.025;
					ylim_new		= [ymin ymax]+[-1 1]*(ymax-ymin)*0.025;
				end
			end
			% Set the axis limits:
			ax_2dmap_zoom('set',xlim_new(1),ylim_new(1),xlim_new(2),ylim_new(2));
		else
			% Reset the axis limits to the previous/current values:
			ax_2dmap_zoom('reset_zoom');
		end
		
	end
	
	
	% % Testing:
	% method	= 4;
	% switch method
	% 	case 1
	% 		axis(GV_H.ax_2dmap,'normal');
	% 		% Data aspect ratio:
	% 		dar	= (diff(GV_H.ax_2dmap.YLim)/ax_2dmap_h) / (diff(GV_H.ax_2dmap.XLim)/ax_2dmap_w);
	% 		if dar>1
	% 			% GV_H.ax_2dmap.YLimMode='auto';
	% 			GV_H.ax_2dmap.XLim		= mean(GV_H.ax_2dmap.XLim)+[-0.5 0.5]*diff(GV_H.ax_2dmap.XLim)*dar;
	% 		else
	% 			% GV_H.ax_2dmap.XLimMode='auto';
	% 			GV_H.ax_2dmap.YLim		= mean(GV_H.ax_2dmap.YLim)+[-0.5 0.5]*diff(GV_H.ax_2dmap.YLim)/dar;
	% 		end
	% 		GV_H.ax_2dmap.DataAspectRatio=[1 1 1];
	% 		GV_H.ax_2dmap.PlotBoxAspectRatioMode	= 'manual';
	% 	case 2
	% 		axis(GV_H.ax_2dmap,'equal');
	% 	case 3
	% 		a = getpixelposition(GV_H.ax_2dmap);
	% 		set(GV_H.ax_2dmap,'DataAspectRatio',[1 1 1]);
	% 		dx = diff(get(GV_H.ax_2dmap,'xlim'));
	% 		dy = diff(get(GV_H.ax_2dmap,'ylim'));
	% 		dz = 1;
	% 		if hasZProperties(handle(GV_H.ax_2dmap))
	% 			dz = diff(get(GV_H.ax_2dmap,'ZLim'));
	% 		end
	% 		set(GV_H.ax_2dmap,'PlotBoxAspectRatioMode','auto')
	% 		pbar = get(GV_H.ax_2dmap,'PlotBoxAspectRatio');
	% 		set(GV_H.ax_2dmap,'PlotBoxAspectRatio', ...
	% 			[a(3) a(4) dz*min(a(3),a(4))/min(dx,dy)]);
	% 		% Change the unconstrained axis limit to auto based
	% 		% on the PBAR.
	% 		if pbar(1)/a(3) < pbar(2)/a(4)
	% 			set(GV_H.ax_2dmap,'xlimmode','auto')
	% 		else
	% 			set(GV_H.ax_2dmap,'ylimmode','auto')
	% 		end
	% 	case 4
	% 		% nop
	% end
	% InnerPosition	= GV_H.ax_2dmap.InnerPosition
	% Position			= GV_H.ax_2dmap.Position
	
	
catch ME
	errormessage('',ME);
end

