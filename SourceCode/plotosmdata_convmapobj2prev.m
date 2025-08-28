function plotosmdata_convmapobj2prev
% Convert map object to preview:
% One map object (one row) in MAP_OBJECTS_TABLE must be selected.
% The polygon will be converted into a preview polygon object.

global GV GV_H MAP_OBJECTS

try

	% Assigne imapobj_plotno:
	imapobj_plotno				= zeros(0,1);
	for imapobj=1:size(MAP_OBJECTS,1)
		for r=1:size(MAP_OBJECTS(imapobj,1).h,1)
			for c=1:size(MAP_OBJECTS(imapobj,1).h,2)
				if MAP_OBJECTS(imapobj,1).h(r,c).Selected
					imapobj_plotno				= [imapobj_plotno;imapobj];
				end
			end
		end
	end
	imapobj_plotno	= unique(imapobj_plotno);
	if isempty(imapobj_plotno)
		errormessage(sprintf(['Error:\n',...
			'One object must be selected to use this function.']));
	end

	% Display state:
	t_start_statebusy	= clock;
	display_on_gui_str	= sprintf('Convert PlotNo=%g to preview ...',imapobj_plotno);
	display_on_gui('state',display_on_gui_str,'busy','add');

	% Plot the preview:
	poly_bgd_prev		= polyshape();			% ud.level=0: background
	poly_fgd_prev		= polyshape();			% ud.level=1: foreground
	dscr_prev			= MAP_OBJECTS(imapobj_plotno(1,1),1).dscr;
	text_prev			= MAP_OBJECTS(imapobj_plotno(1,1),1).text;
	for k=1:size(imapobj_plotno,1)
		if (MAP_OBJECTS(imapobj_plotno(k,1),1).iobj<0)||~strcmp(MAP_OBJECTS(imapobj_plotno(k,1),1).h(1,1).Type,'polygon')
			if ~isempty(MAP_OBJECTS(imapobj_plotno(k,1),1).dscr)
				dscr_str		= sprintf(' (%s)',MAP_OBJECTS(imapobj_plotno(k,1),1).dscr);
			else
				dscr_str		= '';
			end
			errormessage(sprintf(['Error:\n',...
				'The conversion of the selected object\n',...
				'PlotNo=%g%s\n',...
				'into a preview object is not possible\n',...
				'because it is already a preview object'],...
				imapobj_plotno(k,1),dscr_str));
		end
		for i=1:size(MAP_OBJECTS(imapobj_plotno(k,1),1).h,1)
			level			= 0;
			if isfield(MAP_OBJECTS(imapobj_plotno(k,1),1).h(i,1).UserData,'level')
				level			= MAP_OBJECTS(imapobj_plotno(k,1),1).h(i,1).UserData.level;
			end
			if level==0
				poly_bgd_prev		= union(poly_bgd_prev,MAP_OBJECTS(imapobj_plotno(k,1),1).h(i,1).Shape);
			else
				poly_fgd_prev		= union(poly_fgd_prev,MAP_OBJECTS(imapobj_plotno(k,1),1).h(i,1).Shape);
			end
			if ~strcmp(dscr_prev,MAP_OBJECTS(imapobj_plotno(k,1),1).dscr)||isempty(dscr_prev)
				dscr_prev	= 'converted map objects';
			end
			if ~strcmp(text_prev,MAP_OBJECTS(imapobj_plotno(k,1),1).text)
				text_prev	= {''};
			end
		end
	end

	imapobj_new_v		= [];
	for level=0:1
		if level==0
			poly_prev		= poly_bgd_prev;
			if isempty(dscr_prev)
				dscr_prev_ext	= sprintf('background',dscr_prev);
			else
				dscr_prev_ext	= sprintf('%s: background',dscr_prev);
			end
		else
			poly_prev		= poly_fgd_prev;
			if isempty(dscr_prev)
				dscr_prev_ext	= sprintf('foreground',dscr_prev);
			else
				dscr_prev_ext	= sprintf('%s: foreground',dscr_prev);
			end
		end
		if numboundaries(poly_prev)>0
			imapobj_new		= size(MAP_OBJECTS,1)+1;
			imapobj_new_v	= [imapobj_new_v;imapobj_new];
			% Userdata:
			ud					= [];
			ud.color_no		= 0;
			ud.color_no_pp	= 0;
			ud.in				= [];
			ud.iw				= [];
			ud.ir				= [];
			ud.rotation		= 0;
			ud.shape0		= poly_prev;
			% Plot the preview as polygon:
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
			end
			h_poly	= plot(GV_H.ax_2dmap,...
				poly_prev,...
				'EdgeColor',GV.preview.EdgeColor,...
				'FaceColor',GV.preview.FaceColor,...
				'EdgeAlpha', GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha,...
				'Visible'  ,'on',...
				'LineStyle',GV.preview.LineStyle,...
				'LineWidth',GV.preview.LineWidth,...
				'UserData',ud,...
				'ButtonDownFcn',@ButtonDownFcn_ax_2dmap);
			% Save relevant data in the structure MAP_OBJECTS:
			[xcenter,ycenter]						= centroid(poly_prev);
			MAP_OBJECTS(imapobj_new,1).disp	= 'preview polygon';
			MAP_OBJECTS(imapobj_new,1).h		= h_poly;
			MAP_OBJECTS(imapobj_new,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
			MAP_OBJECTS(imapobj_new,1).dscr	= dscr_prev_ext;
			MAP_OBJECTS(imapobj_new,1).x		= xcenter;
			MAP_OBJECTS(imapobj_new,1).y		= ycenter;
			MAP_OBJECTS(imapobj_new,1).text	= text_prev;
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

