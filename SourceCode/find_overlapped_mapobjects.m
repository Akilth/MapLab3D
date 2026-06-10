function errortext=find_overlapped_mapobjects
% Looks for overlapping texts and symbols and displays the first overlap on the map.

global MAP_OBJECTS APP GV GV_H PP

try
	
	if isempty(PP)
		errortext	= sprintf([...
			'The project parameters have not yet been loaded.\n',...
			'First load the project parameters.']);
		errormessage(errortext);
	end
	if isempty(MAP_OBJECTS)
		errortext	= sprintf([...
			'The map has not yet been created.\n',...
			'First create the map.']);
		errormessage(errortext);
	end
	
	% Display state:
	t_start_statebusy		= clock;
	display_on_gui_str	= 'Find overlap ...';
	display_on_gui('state',display_on_gui_str,'busy','add');
	
	% Initializations:
	errortext				= '';
	zoomin_xy				= zeros(1,4);
	waitbar_t1				= clock;
	colno_v					= [];
	imapobj_max				= size(MAP_OBJECTS,1);
	imapobj_overlap_v		= [];
	zoom_in_overlap		= false;							% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	poly_overlap			= polyshape();
	poly_all_gr_objprio					= struct;
	mapobj					= struct;
	
	% Deselect all objects:
	plot_modify('deselect',-1,0);
	
	% Detect existing map object numbers:
	imapobj_overlapping_objects_preview	= [];
	dscr_prev	= sprintf('%s: results',APP.MapEdit_DetectOverlappedTextsSymbols_Menu.Text);
	text_prev	= sprintf('created %s',datestr(now));
	for imapobj=1:imapobj_max
		if strcmp(MAP_OBJECTS(imapobj,1).dscr,dscr_prev)
			imapobj_overlapping_objects_preview	= [imapobj_overlapping_objects_preview;imapobj];
		end
	end
	% If there is more than one preview plot object: Delete the rest:
	if length(imapobj_overlapping_objects_preview)>=2
		plot_modify('delete',imapobj_overlapping_objects_preview(2:end));		% Includes also display_map_objects
		imapobj_overlapping_objects_preview	= imapobj_overlapping_objects_preview(1);
	end
	% Hide the old results:
	plot_modify('hide',imapobj_overlapping_objects_preview);
	
	% Get all visible map objects with iobj>0 sorted by object priority in ascending order:
	% mapobj(imo,1).shape			polygon shape
	% mapobj(imo,1).shape_buff		polygon shape buffered by d_side
	% mapobj(imo,1).isfgd			is foreground (true/false)
	% mapobj(imo,1).icol				index in colno_v
	% mapobj(imo,1).istsc			is text, symbol or connection line (true/false)
	% mapobj(imo,1).prio				object priority
	% mapobj(imo,1).iobj				object number
	% mapobj(imo,1).imapobj			index MAP_OBJECTS(imapobj,1)
	% mapobj(imo,1).tesy_colno_v	if the object is a text or symbol: vector of the fore- and background color numbers
	imo				= 0;
	for imapobj=1:imapobj_max
		for rpoly=1:size(MAP_OBJECTS(imapobj,1).h,1)
			if strcmp(MAP_OBJECTS(imapobj,1).h(rpoly,1).Type,'polygon')
				if    MAP_OBJECTS(imapobj,1).h(rpoly,1).Visible                                        &&...
						isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
						isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).FaceAlpha,GV.visibility.show.facealpha)&&...
						(numboundaries(MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape)>0)
					ud	= MAP_OBJECTS(imapobj,1).h(rpoly,1).UserData;
					if length(ud)~=1
						errormessage;
					end
					if isfield(ud,'color_no')&&isfield(ud,'prio')&&isfield(ud,'iobj')&&isfield(ud,'level')
						if (ud.iobj>0)&&(ud.prio>0)
							imo							= imo+1;
							% index MAP_OBJECTS(imapobj,1):
							mapobj(imo,1).imapobj	= imapobj;
							% Object number:
							mapobj(imo,1).iobj		= ud.iobj;
							% Object priority:
							mapobj(imo,1).prio		= ud.prio;
							% Polygon shape:
							mapobj(imo,1).shape		= MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape;
							% Color number:
							icol							= find(colno_v==ud.color_no);
							if isempty(icol)
								icol						= size(colno_v,1)+1;
							end
							colno_v(icol,1)			= ud.color_no;
							mapobj(imo,1).icol		= icol;
							% Level: (fore-/background):
							if ud.level==1
								% level=1: foreground:
								mapobj(imo,1).isfgd	= true;
							else
								% level=0: background:
								mapobj(imo,1).isfgd	= false;
							end
							% Is text, symbol or connection line (true/false):
							if    strcmp(MAP_OBJECTS(imapobj,1).disp,'text')           ||...
									strcmp(MAP_OBJECTS(imapobj,1).disp,'symbol')         ||...
									strcmp(MAP_OBJECTS(imapobj,1).disp,'connection line')
								mapobj(imo,1).istsc	= true;
							else
								mapobj(imo,1).istsc	= false;
							end
							% Polygon shape buffered by d_side:
							mapobj(imo,1).shape_buff		= mapobj(imo,1).shape;
							if ud.color_no>0
								icolspec		= PP.color(ud.color_no).spec;
								d_side		= PP.colorspec(icolspec).d_side;
							else
								d_side		= 0;
							end
							if d_side>0
								if strcmp(GV.jointtype_bh,'miter')
									mapobj(imo,1).shape_buff	= polybuffer(mapobj(imo,1).shape_buff,d_side,...
										'JointType','Miter','MiterLimit',miterlimit);
								else
									mapobj(imo,1).shape_buff	= polybuffer(mapobj(imo,1).shape_buff,d_side,...
										'JointType',GV.jointtype_bh);
								end
							end
							% If the object is a text or symbol: vector of the fore- and background color numbers:
							if    strcmp(MAP_OBJECTS(imapobj,1).disp,'text')           ||...
									strcmp(MAP_OBJECTS(imapobj,1).disp,'connection line')
								mapobj(imo,1).tesy_colno_v	= unique([...
									PP.obj(ud.iobj,1).textpar.color_no_letters;...
									PP.obj(ud.iobj,1).textpar.color_no_bgd]);
							elseif strcmp(MAP_OBJECTS(imapobj,1).disp,'symbol')
								mapobj(imo,1).tesy_colno_v	= unique([...
									PP.obj(ud.iobj,1).symbolpar.color_no_symbol;...
									PP.obj(ud.iobj,1).symbolpar.color_no_bgd]);
							else
								mapobj(imo,1).tesy_colno_v	= [];
							end
						end
					end
				end
			end
		end
	end
	[~,isort]		= sort([mapobj.prio]);
	mapobj			= mapobj(isort,:);
	imo_max			= size(mapobj,1);
	
	% Unite all objects that have greater priority than object imo (falling order):
	% poly_all_gr_objprio(imo,1).onlyfgd(icol,1)
	% poly_all_gr_objprio(imo,1).fgdbgd(icol,1)
	for imo=imo_max:-1:1
		% Waitbar:
		if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
			waitbar_t1	= clock;
			progress		= min((imo_max-imo)/imo_max,1)/4;
			set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
			set(GV_H.text_waitbar,'String',sprintf('%s - preparation (%1.0f/%1.0f)',...
				APP.MapEdit_DetectOverlappedTextsSymbols_Menu.Text,...
				imo_max-imo+1,2*imo_max));
			drawnow;
		end
		if imo==imo_max
			for icol=1:size(colno_v,1)
				poly_all_gr_objprio(imo,1).onlyfgd(icol,1)	= polyshape();
				poly_all_gr_objprio(imo,1).fgdbgd(icol,1)		= polyshape();
			end
		else
			for icol=1:size(colno_v,1)
				poly_all_gr_objprio(imo,1).onlyfgd(icol,1)	= poly_all_gr_objprio(imo+1,1).onlyfgd(icol,1);
				poly_all_gr_objprio(imo,1).fgdbgd(icol,1)		= poly_all_gr_objprio(imo+1,1).fgdbgd(icol,1);
			end
		end
		icol		= mapobj(imo,1).icol;
		if mapobj(imo,1).isfgd
			% is foreground:
			poly_all_gr_objprio(imo,1).onlyfgd(icol,1)		= union(...
				poly_all_gr_objprio(imo,1).onlyfgd(icol,1),...
				mapobj(imo,1).shape,...
				'KeepCollinearPoints',false);
		end
		poly_all_gr_objprio(imo,1).fgdbgd(icol,1)	= union(...
			poly_all_gr_objprio(imo,1).fgdbgd(icol,1),...
			mapobj(imo,1).shape,...
			'KeepCollinearPoints',false);
	end
	
	% Unite all objects that have smaller priority than object imo (rising order):
	% poly_all_sm_objprio(imo,1).onlyfgd(icol,1)
	% poly_all_sm_objprio(imo,1).fgdbgd(icol,1)
	for imo=1:imo_max
		% Waitbar:
		if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
			waitbar_t1	= clock;
			progress		= 0.25+min(imo/imo_max,1)/4;
			set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
			set(GV_H.text_waitbar,'String',sprintf('%s - preparation (%1.0f/%1.0f)',...
				APP.MapEdit_DetectOverlappedTextsSymbols_Menu.Text,...
				imo+imo_max,2*imo_max));
			drawnow;
		end
		if imo==1
			for icol=1:size(colno_v,1)
				% poly_all_sm_objprio(imo,1).onlyfgd(icol,1)	= polyshape();
				poly_all_sm_objprio(imo,1).fgdbgd(icol,1)		= polyshape();
			end
		else
			for icol=1:size(colno_v,1)
				% poly_all_sm_objprio(imo,1).onlyfgd(icol,1)	= poly_all_sm_objprio(imo-1,1).onlyfgd(icol,1);
				poly_all_sm_objprio(imo,1).fgdbgd(icol,1)		= poly_all_sm_objprio(imo-1,1).fgdbgd(icol,1);
			end
		end
		icol		= mapobj(imo,1).icol;
		% if mapobj(imo,1).isfgd
		% 	% is foreground:
		% 	poly_all_sm_objprio(imo,1).onlyfgd(icol,1)		= union(...
		% 		poly_all_sm_objprio(imo,1).onlyfgd(icol,1),...
		% 		mapobj(imo,1).shape,...
		% 		'KeepCollinearPoints',false);
		% end
		poly_all_sm_objprio(imo,1).fgdbgd(icol,1)	= union(...
			poly_all_sm_objprio(imo,1).fgdbgd(icol,1),...
			mapobj(imo,1).shape,...
			'KeepCollinearPoints',false);
	end
	
	% Detect overlaps:
	for imo=1:imo_max
		if mapobj(imo,1).istsc
			% The object is a text, symbol or connection line:
			imapobj			= mapobj(imo,1).imapobj;
			icol				= mapobj(imo,1).icol;
			colno				= colno_v(icol,1);
			colprio			= PP.color(colno,1).prio;
			
			% Waitbar:
			if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
				waitbar_t1	= clock;
				progress		= 0.5+min(imo/imo_max,1)/2;
				set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
				set(GV_H.text_waitbar,'String',sprintf('%s - detection (%1.0f/%1.0f)',...
					APP.MapEdit_DetectOverlappedTextsSymbols_Menu.Text,...
					imo,imo_max));
				drawnow;
			end
			
			% Check for overlap:
			if any(overlaps(mapobj(imo,1).shape,GV_H.poly_map_printout_obj_limits.Shape))
				% The polygon mapobj(imo,1).shape is inside the map printout limits:
				poly_overlap_imo	= polyshape();
				overlap_detected				= false;
				% Check all objects with higher object priority for overlaps against mapobj(imo,1).shape:
				for icol_all=1:length(colno_v)
					% colno:			color number of:	the current object (text, symbol, connection line)
					%											mapobj(imo,1).shape
					% colno_all:	color number of:	all united objects with higher priority
					%											poly_all_gr_objprio(imo+1,1).onlyfgd(icol_all,1)
					%											poly_all_gr_objprio(imo+1,1).fgdbgd(icol_all,1)
					colno_all	= colno_v(icol_all,1);
					colprio_all	= PP.color(colno_all,1).prio;
					
					% Check if the text or symbol overlaps any other object with a greater object priority:
					if imo<imo_max
						if (colno==colno_all)&&mapobj(imo,1).isfgd
							% Same color: Only check the foreground for overlap and do not consider d_side:
							if overlaps(mapobj(imo,1).shape,poly_all_gr_objprio(imo+1,1).onlyfgd(icol_all,1))
								overlap_detected			= true;
								imapobj_overlap_v			= [imapobj_overlap_v;imapobj];
								poly_overlap_imo	= union(...
									poly_overlap_imo,intersect(...
									mapobj(imo,1).shape,...
									poly_all_gr_objprio(imo+1,1).fgdbgd(icol_all,1)));
							end
						elseif (colno~=colno_all)&&~(...
								any(colno    ==mapobj(imo,1).tesy_colno_v)&&...
								any(colno_all==mapobj(imo,1).tesy_colno_v)     )
							% The colors are different and
							% they are not both the foreground and background colors of the current text or symbol:
							% Check for overlap and consider d_side:
							if overlaps(mapobj(imo,1).shape_buff,poly_all_gr_objprio(imo+1,1).fgdbgd(icol_all,1))
								overlap_detected			= true;
								imapobj_overlap_v			= [imapobj_overlap_v;imapobj];
								poly_overlap_imo	= union(...
									poly_overlap_imo,intersect(...
									mapobj(imo,1).shape_buff,...
									poly_all_gr_objprio(imo+1,1).fgdbgd(icol_all,1)));
							end
						end
					end
					
					% Check if the text or symbol overlaps any other object with a smaller object priority,
					% but greater color priority (in that case, the other object would be cut off by the text).
					if imo>1
						if (colprio_all>colprio)
							% Greater color priority: check for overlap and consider d_side:
							if overlaps(mapobj(imo,1).shape_buff,poly_all_sm_objprio(imo-1,1).fgdbgd(icol_all,1))
								overlap_detected			= true;
								imapobj_overlap_v			= [imapobj_overlap_v;imapobj];
								poly_overlap_imo	= union(...
									poly_overlap_imo,intersect(...
									mapobj(imo,1).shape_buff,...
									poly_all_sm_objprio(imo-1,1).fgdbgd(icol_all,1)));
							end
						end
					end
					
				end
				if overlap_detected
					% Overlap detected:
					
					% Add the object to poly_overlap:
					poly_overlap	= union(poly_overlap,poly_overlap_imo);
					
					% Zoom on the overlapping object:
					if zoom_in_overlap
						text_str		= '';
						if ~isempty(MAP_OBJECTS(imapobj,1).dscr)
							text_str		= sprintf('%s',MAP_OBJECTS(imapobj,1).dscr);
						end
						for itext=1:size(MAP_OBJECTS(imapobj,1).text,1)
							if itext==1
								if ~isempty(text_str)
									text_str		= sprintf('%s - %s',text_str,MAP_OBJECTS(imapobj,1).text{itext,1});
								else
									text_str		= sprintf('%s',MAP_OBJECTS(imapobj,1).text{itext,1});
								end
							else
								text_str		= sprintf('%s - %s',text_str,MAP_OBJECTS(imapobj,1).text{itext,1});
							end
							if text==size(MAP_OBJECTS(imapobj,1).text,1)
								text_str		= sprintf('%s)',text_str);
							end
						end
						[xlim,ylim]			= boundingbox(mapobj(imo,1).shape);
						zoomin_xy([1 3])	= xlim+[-1 1]*(xlim(2)-xlim(1))*2.0;
						zoomin_xy([2 4])	= ylim+[-1 1]*(ylim(2)-ylim(1))*2.0;
						ax_2dmap_zoom('set',zoomin_xy(1),zoomin_xy(2),zoomin_xy(3),zoomin_xy(4));
						figure(GV_H.fig_2dmap);
						% User confirmation:
						question	= sprintf([...
							'Overlap detected between %s\n',...
							'PlotNo %g (%s)\n',...
							'and other map objects with higher object priority.\n',...
							'\n',...
							'You can cancel or continue searching for overlapped\n',...
							'texts and symbols. If you continue, all overlapped\n',...
							'texts and symbols are displayed as a preview object.'],...
							MAP_OBJECTS(imapobj,1).disp,imapobj,text_str);
						answer			= '';
						while isempty(answer)
							answer	= questdlg_local(question,'Continue?',...
								'Continue','Continue without confirmation','Cancel','Continue');
						end
						if strcmp(answer,'Cancel')
							break
						elseif strcmp(answer,'Continue without confirmation')
							zoom_in_overlap	= false;
						end
					end
					
				end
				
			end
			
		end
	end
	imapobj_overlap_v		= unique(imapobj_overlap_v);
	
	% Display all overlapping objects as preview objects:
	% Plot the overlapping objects:
	if numboundaries(poly_overlap)>0
		if isempty(imapobj_overlapping_objects_preview)
			imapobj_overlapping_objects_preview		= plot_modify('new_poly',0,...
				poly_overlap,...				% preview polygon
				dscr_prev,...						% description
				text_prev,...						% text
				false);								% select (true/false)
		else
			% Overwrite the old results:
			[xcenter,ycenter]																	= centroid(poly_overlap);
			MAP_OBJECTS(imapobj_overlapping_objects_preview,1).h(1,1).Shape	= poly_overlap;
			MAP_OBJECTS(imapobj_overlapping_objects_preview,1).x					= xcenter;
			MAP_OBJECTS(imapobj_overlapping_objects_preview,1).y					= ycenter;
			MAP_OBJECTS(imapobj_overlapping_objects_preview,1).text				= {text_prev};
			% Update MAP_OBJECTS_TABLE:
			plot_modify('deselect',-1,0);
			plot_modify('show',imapobj_overlapping_objects_preview);
			display_map_objects(imapobj_overlapping_objects_preview);
		end
	end
	
	% Show the whole map (zoom fit):
	SizeChangedFcn_fig_2dmap([],[],1,1);
	figure(GV_H.fig_2dmap);
	
	% Results:
	if isfield(GV_H.warndlg,'find_overlapped_mapobjects')
		if ishandle(GV_H.warndlg.find_overlapped_mapobjects)
			close(GV_H.warndlg.find_overlapped_mapobjects);
		end
	end
	Nmax_lines		= 15;
	i_line			= 1;
	if ~isempty(imapobj_overlap_v)
		warntext	= sprintf([...
			'The following texts and symbols are\n',...
			'overlapped by other map objects,\n',...
			'therefore they cover each other\n',...
			'or cut into each other:\n',...
			'PlotNo = \n']);
		for i=1:size(imapobj_overlap_v,1)
			warntext	= sprintf('%s%12.0f',warntext,imapobj_overlap_v(i,1));
			if mod(i,4)==0
				warntext	= sprintf('%s\n',warntext);
				i_line			= i_line+1;
			end
			if i_line>Nmax_lines
				warntext	= sprintf('%s...',warntext);
				break
			end
		end
		GV_H.warndlg.find_overlapped_mapobjects		= warndlg(warntext,'Warning');
	else
		warntext	= sprintf('No overlapped texts or symbols detected.');
		GV_H.warndlg.find_overlapped_mapobjects		= helpdlg(warntext,'Check successful');
	end
	GV_H.warndlg.find_overlapped_mapobjects.Tag	= 'maplab3d_figure';
	
	% Display state:
	if isempty(imapobj_overlap_v)
		log_str	= 'nothing to do';
		waitbar_str	= sprintf('%s ... nothing detected, no preview polygon created.',...
			APP.MapEdit_DetectOverlappedTextsSymbols_Menu.Text);
	else
		if size(imapobj_overlap_v,1)==1
			log_str	= '1 overlap detected';
		else
			log_str	= sprintf('%g overlaps detected',size(imapobj_overlap_v,1));
		end
		waitbar_str	= sprintf('%s ... %s, 1 preview polygon created (PlotNo %1.0f).',...
			APP.MapEdit_DetectOverlappedTextsSymbols_Menu.Text,log_str,imapobj_overlapping_objects_preview);
	end
	display_on_gui('state',...
		sprintf('%s %s (%s).',display_on_gui_str,log_str,dt_string(etime(clock,t_start_statebusy))),...
		'notbusy','replace');
	
	% Reset waitbar:
	set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
	set(GV_H.text_waitbar,'String',waitbar_str);
	
catch ME
	errormessage('',ME);
end

