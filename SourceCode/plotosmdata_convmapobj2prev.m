function plotosmdata_convmapobj2prev
% Convert map object to preview:
% One map object (one row) in MAP_OBJECTS_TABLE must be selected.
% The polygon will be converted into a preview polygon object.

global GV GV_H MAP_OBJECTS

try
	
	% Assigne imapobj_plotno:
	imapobj_plotno				= false(size(MAP_OBJECTS,1),1);
	for imapobj=1:size(MAP_OBJECTS,1)
		for r=1:size(MAP_OBJECTS(imapobj,1).h,1)
			for c=1:size(MAP_OBJECTS(imapobj,1).h,2)
				if MAP_OBJECTS(imapobj,1).h(r,c).Selected
					imapobj_plotno(imapobj,1)	= true;
				end
			end
		end
	end
	imapobj_plotno	= find(imapobj_plotno);
	if isempty(imapobj_plotno)
		errormessage(sprintf(['Error:\n',...
			'At least one object must be selected to use this function.']));
	end
	
	% Display state:
	t_start_statebusy	= clock;
	display_on_gui_str	= sprintf('Convert PlotNo=%g to preview ...',imapobj_plotno);
	display_on_gui('state',display_on_gui_str,'busy','add');
	
	% Get the preview data:
	lines_prev			= [];
	poly_bgd_prev		= [];			% ud.level=0: background
	poly_fgd_prev		= [];			% ud.level=1: foreground
	dscr_prev			= MAP_OBJECTS(imapobj_plotno(1,1),1).dscr;
	text_prev			= MAP_OBJECTS(imapobj_plotno(1,1),1).text;
	for k=1:size(imapobj_plotno,1)
		lines_prev(k,1).segm			= zeros(0,1);
		poly_bgd_prev(k,1).poly		= polyshape();
		poly_fgd_prev(k,1).poly		= polyshape();
		for i=1:size(MAP_OBJECTS(imapobj_plotno(k,1),1).h,1)
			switch MAP_OBJECTS(imapobj_plotno(k,1),1).h(i,1).Type
				case 'line'
					% Line:
					lines_prev(k,1).segm(end+1,1).xy	= [...
						MAP_OBJECTS(imapobj_plotno(k,1),1).h(i,1).XData(:) ...
						MAP_OBJECTS(imapobj_plotno(k,1),1).h(i,1).YData(:)];
					lines_prev(k,1).dscr	= MAP_OBJECTS(imapobj_plotno(k,1),1).dscr;
					lines_prev(k,1).text	= MAP_OBJECTS(imapobj_plotno(k,1),1).text;
				case 'polygon'
					% Polygon:
					level			= 0;
					if isfield(MAP_OBJECTS(imapobj_plotno(k,1),1).h(i,1).UserData,'level')
						level			= MAP_OBJECTS(imapobj_plotno(k,1),1).h(i,1).UserData.level;
					end
					if level==0
						poly_bgd_prev(k,1).poly(i,1)	= MAP_OBJECTS(imapobj_plotno(k,1),1).h(i,1).Shape;
						poly_bgd_prev(k,1).dscr	= MAP_OBJECTS(imapobj_plotno(k,1),1).dscr;
						poly_bgd_prev(k,1).text	= MAP_OBJECTS(imapobj_plotno(k,1),1).text;
					else
						poly_fgd_prev(k,1).poly(i,1)	= MAP_OBJECTS(imapobj_plotno(k,1),1).h(i,1).Shape;
						poly_fgd_prev(k,1).dscr	= MAP_OBJECTS(imapobj_plotno(k,1),1).dscr;
						poly_fgd_prev(k,1).text	= MAP_OBJECTS(imapobj_plotno(k,1),1).text;
					end
			end
		end
	end
	
	% Create preview objects:
	imapobj_new_v		= [];
	for k=1:size(imapobj_plotno,1)
		
		isline		= false;
		ispoly_bgd	= false;
		ispoly_fgd	= false;
		if size(lines_prev(k,1).segm,1)>=1
			isline		= true;
			dscr_prev	= lines_prev(k,1).dscr;
			text_prev	= lines_prev(k,1).text;
		end
		if any(numboundaries(poly_bgd_prev(k,1).poly)>=1)
			ispoly_bgd		= true;
			dscr_prev_bgd	= poly_bgd_prev(k,1).dscr;
			text_prev_bgd	= poly_bgd_prev(k,1).text;
		end
		if any(numboundaries(poly_fgd_prev(k,1).poly)>=1)
			ispoly_fgd		= true;
			dscr_prev_fgd	= poly_fgd_prev(k,1).dscr;
			text_prev_fgd	= poly_fgd_prev(k,1).text;
		end
		if ispoly_bgd&&ispoly_fgd
			dscr_prev_bgd	= sprintf('%s: background',poly_bgd_prev(k,1).dscr);
			dscr_prev_fgd	= sprintf('%s: foreground',poly_fgd_prev(k,1).dscr);
		end
		
		if isline
			imapobj_new		= size(MAP_OBJECTS,1)+1;
			imapobj_new_v	= [imapobj_new_v;imapobj_new];
			% Userdata:
			ud					= [];
			ud.in				= [];
			ud.iw				= [];
			ud.ir				= [];
			ud.rotation		= 0;
			% Plot the way as preview:
			for i=1:size(lines_prev(k,1).segm,1)
				x					= lines_prev(k,1).segm(i,1).xy(:,1);
				y					= lines_prev(k,1).segm(i,1).xy(:,2);
				ud.xy0			= [x(:) y(:)];
				if ~ishandle(GV_H.ax_2dmap)
					errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
				end
				if isscalar(x)
					MAP_OBJECTS(imapobj_new,1).h(i,1)		= plot(GV_H.ax_2dmap,x,y,...
						'Color'        ,GV.preview.Color,...
						'LineStyle'    ,GV.preview.LineStyle,...
						'LineWidth'    ,GV.preview.LineWidth,...
						'Marker'       ,GV.preview.Marker,...
						'MarkerSize'   ,GV.preview.MarkerSize,...
						'UserData'     ,ud,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
				else
					MAP_OBJECTS(imapobj_new,1).h(i,1)		= plot(GV_H.ax_2dmap,x,y,...
						'Color'        ,GV.preview.Color,...
						'LineStyle'    ,GV.preview.LineStyle,...
						'LineWidth'    ,GV.preview.LineWidth,...
						'UserData'     ,ud,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
				end
			end
			% Save relevant data in the structure MAP_OBJECTS:
			MAP_OBJECTS(imapobj_new,1).disp	= 'preview line';
			MAP_OBJECTS(imapobj_new,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
			MAP_OBJECTS(imapobj_new,1).dscr	= dscr_prev;
			MAP_OBJECTS(imapobj_new,1).x		= mean(x(~isnan(x)));
			MAP_OBJECTS(imapobj_new,1).y		= mean(y(~isnan(y)));
			MAP_OBJECTS(imapobj_new,1).text	= text_prev;
			MAP_OBJECTS(imapobj_new,1).mod	= false;
			MAP_OBJECTS(imapobj_new,1).cncl	= 0;
			MAP_OBJECTS(imapobj_new,1).cnuc	= 0;
			MAP_OBJECTS(imapobj_new,1).vis0	= 1;
		end
		
		if ispoly_bgd
			imapobj_new		= size(MAP_OBJECTS,1)+1;
			imapobj_new_v	= [imapobj_new_v;imapobj_new];
			% Userdata:
			ud					= [];
			ud.in				= [];
			ud.iw				= [];
			ud.ir				= [];
			ud.rotation		= 0;
			% Plot the preview as polygon:
			i_h				= 0;
			for i=1:size(poly_bgd_prev(k,1).poly,1)
				if numboundaries(poly_bgd_prev(k,1).poly(i,1))>0
					ud.shape0		= poly_bgd_prev(k,1).poly(i,1);
					i_h		= i_h+1;
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
					end
					MAP_OBJECTS(imapobj_new,1).h(i_h,1)	= plot(GV_H.ax_2dmap,...
						poly_bgd_prev(k,1).poly(i,1),...
						'EdgeColor',GV.preview.EdgeColor,...
						'FaceColor',GV.preview.FaceColor,...
						'EdgeAlpha', GV.visibility.show.edgealpha,...
						'FaceAlpha',GV.visibility.show.facealpha,...
						'Visible'  ,'on',...
						'LineStyle',GV.preview.LineStyle,...
						'LineWidth',GV.preview.LineWidth,...
						'UserData',ud,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
				end
			end
			% Save relevant data in the structure MAP_OBJECTS:
			[xcenter,ycenter]						= centroid(poly_bgd_prev(k,1).poly);
			MAP_OBJECTS(imapobj_new,1).disp	= 'preview polygon';
			MAP_OBJECTS(imapobj_new,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
			MAP_OBJECTS(imapobj_new,1).dscr	= dscr_prev_bgd;
			MAP_OBJECTS(imapobj_new,1).x		= xcenter;
			MAP_OBJECTS(imapobj_new,1).y		= ycenter;
			MAP_OBJECTS(imapobj_new,1).text	= text_prev_bgd;
			MAP_OBJECTS(imapobj_new,1).mod	= false;
			MAP_OBJECTS(imapobj_new,1).cncl	= 0;
			MAP_OBJECTS(imapobj_new,1).cnuc	= 0;
			MAP_OBJECTS(imapobj_new,1).vis0	= 1;
		end
		
		if ispoly_fgd
			imapobj_new		= size(MAP_OBJECTS,1)+1;
			imapobj_new_v	= [imapobj_new_v;imapobj_new];
			% Userdata:
			ud					= [];
			ud.in				= [];
			ud.iw				= [];
			ud.ir				= [];
			ud.rotation		= 0;
			% Plot the preview as polygon:
			i_h				= 0;
			for i=1:size(poly_fgd_prev(k,1).poly,1)
				if numboundaries(poly_fgd_prev(k,1).poly(i,1))>0
					ud.shape0		= poly_fgd_prev(k,1).poly(i,1);
					i_h		= i_h+1;
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
					end
					MAP_OBJECTS(imapobj_new,1).h(i_h,1)	= plot(GV_H.ax_2dmap,...
						poly_fgd_prev(k,1).poly(i,1),...
						'EdgeColor',GV.preview.EdgeColor,...
						'FaceColor',GV.preview.FaceColor,...
						'EdgeAlpha', GV.visibility.show.edgealpha,...
						'FaceAlpha',GV.visibility.show.facealpha,...
						'Visible'  ,'on',...
						'LineStyle',GV.preview.LineStyle,...
						'LineWidth',GV.preview.LineWidth,...
						'UserData',ud,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
				end
			end
			% Save relevant data in the structure MAP_OBJECTS:
			[xcenter,ycenter]						= centroid(poly_fgd_prev(k,1).poly);
			MAP_OBJECTS(imapobj_new,1).disp	= 'preview polygon';
			MAP_OBJECTS(imapobj_new,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
			MAP_OBJECTS(imapobj_new,1).dscr	= dscr_prev_fgd;
			MAP_OBJECTS(imapobj_new,1).x		= xcenter;
			MAP_OBJECTS(imapobj_new,1).y		= ycenter;
			MAP_OBJECTS(imapobj_new,1).text	= text_prev_fgd;
			MAP_OBJECTS(imapobj_new,1).mod	= false;
			MAP_OBJECTS(imapobj_new,1).cncl	= 0;
			MAP_OBJECTS(imapobj_new,1).cnuc	= 0;
			MAP_OBJECTS(imapobj_new,1).vis0	= 1;
		end
		
	end
	
	% Create/modify legend:
	create_legend_mapfigure;
	
	% Update MAP_OBJECTS_TABLE:
	plot_modify('deselect',-1,0);
	plot_modify('select',imapobj_new_v,0);
	display_map_objects(imapobj_new_v);
	
	% The map has been changed:
	GV.map_is_saved	= 0;
	
	% Finish updating:
	drawnow;
	
	% Display state:
	display_on_gui('state',...
		sprintf('%s done (%s).',display_on_gui_str,dt_string(etime(clock,t_start_statebusy))),...
		'notbusy','replace');
	
catch ME
	errormessage('',ME);
end

