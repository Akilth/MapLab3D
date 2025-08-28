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
	poly_overlap_buff		= polyshape();
	poly_all					= struct;

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

	% Used colors: colno_v:
	for imapobj=1:imapobj_max
		if   (strcmp(MAP_OBJECTS(imapobj,1).disp,'text')  ||...
				strcmp(MAP_OBJECTS(imapobj,1).disp,'symbol')     )&&...
				(MAP_OBJECTS(imapobj,1).iobj>0)
			% Consider only texts and symbols:
			for rpoly=1:size(MAP_OBJECTS(imapobj,1).h,1)
				if    MAP_OBJECTS(imapobj,1).h(rpoly,1).Visible                                        &&...
						isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
						isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).FaceAlpha,GV.visibility.show.facealpha)
					ud	= MAP_OBJECTS(imapobj,1).h(rpoly,1).UserData;
					if length(ud)~=1
						errormessage;
					end
					if isfield(ud,'color_no')&&isfield(ud,'prio')&&isfield(ud,'iobj')
						if ud.iobj>0
							icol							= find(colno_v==ud.color_no);
							if isempty(icol)
								icol						= size(colno_v,1)+1;
							end
							colno_v(icol,1)			= ud.color_no;
						end
					end
				end
			end
		end
	end

	% All visible polygon map objects sorted by object priority:
	mapobj_prio_v	= -1*ones(size(MAP_OBJECTS,1),1);
	for imapobj=1:imapobj_max
		prio_imapobj_max		= -1;
		for rpoly=1:size(MAP_OBJECTS(imapobj,1).h,1)
			if strcmp(MAP_OBJECTS(imapobj,1).h(rpoly,1).Type,'polygon')
				if    MAP_OBJECTS(imapobj,1).h(rpoly,1).Visible                                        &&...
						isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
						isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).FaceAlpha,GV.visibility.show.facealpha)
					ud	= MAP_OBJECTS(imapobj,1).h(rpoly,1).UserData;
					if length(ud)~=1
						errormessage;
					end
					if isfield(ud,'color_no')&&isfield(ud,'prio')&&isfield(ud,'iobj')
						if ud.iobj>0
							prio_imapobj_max		= max(prio_imapobj_max,ceil(ud.prio));
							icol							= find(colno_v==ud.color_no);
							if isempty(icol)
								icol						= size(colno_v,1)+1;
							end
							colno_v(icol,1)			= ud.color_no;
						end
					end
				end
			end
		end
		mapobj_prio_v(imapobj,1)		= prio_imapobj_max;
	end
	[mapobj_prio_ascend_v,imapobj_ascend_v]			= sort(mapobj_prio_v);
	imapobj_ascend_v(mapobj_prio_ascend_v<=0)			= [];
	mapobj_prio_ascend_v(mapobj_prio_ascend_v<=0)	= [];

	% Unite all objects except the object imapobj (falling order):
	for imapobj_sort=length(imapobj_ascend_v):-1:1
		% Waitbar:
		if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
			waitbar_t1	= clock;
			progress		= min((length(imapobj_ascend_v)-imapobj_sort)/length(imapobj_ascend_v),1)/2;
			set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
			set(GV_H.text_waitbar,'String',sprintf('%s - preparation (%1.0f/%1.0f)',...
				APP.MapEdit_DetectOverlappedTextsSymbols_Menu.Text,...
				length(imapobj_ascend_v)-imapobj_sort+1,length(imapobj_ascend_v)));
			drawnow;
		end
		imapobj			= imapobj_ascend_v(imapobj_sort,1);
		if imapobj_sort==length(imapobj_ascend_v)
			for icol=1:size(colno_v,1)
				poly_all(imapobj_sort,1).onlyforeground(icol,1)	= polyshape();
				poly_all(imapobj_sort,1).forebackground(icol,1)	= polyshape();
			end
		else
			for icol=1:size(colno_v,1)
				poly_all(imapobj_sort,1).onlyforeground(icol,1)	= poly_all(imapobj_sort+1,1).onlyforeground(icol,1);
				poly_all(imapobj_sort,1).forebackground(icol,1)	= poly_all(imapobj_sort+1,1).forebackground(icol,1);
			end
		end
		for rpoly=1:size(MAP_OBJECTS(imapobj,1).h,1)
			if    MAP_OBJECTS(imapobj,1).h(rpoly,1).Visible                                        &&...
					isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
					isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).FaceAlpha,GV.visibility.show.facealpha)
				ud	= MAP_OBJECTS(imapobj,1).h(rpoly,1).UserData;
				if length(ud)~=1
					errormessage;
				end
				if isfield(ud,'color_no')&&isfield(ud,'prio')&&isfield(ud,'iobj')
					if ud.iobj>0
						if isfield(ud,'level')
							icol							= find(colno_v==ud.color_no);
							if ud.level==1
								% level=1: foreground
								poly_all(imapobj_sort,1).onlyforeground(icol,1)	= union(...
									poly_all(imapobj_sort,1).onlyforeground(icol,1),...
									MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape,...
									'KeepCollinearPoints',false);
							end
							poly_all(imapobj_sort,1).forebackground(icol,1)	= union(...
								poly_all(imapobj_sort,1).forebackground(icol,1),...
								MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape,...
								'KeepCollinearPoints',false);

						else
							errormessage;
						end
					end
				end
			end
		end
	end

	% Detect overlaps:
	for imapobj_sort=1:length(imapobj_ascend_v)
		imapobj			= imapobj_ascend_v(imapobj_sort,1);

		if mapobj_prio_ascend_v(imapobj_sort)<mapobj_prio_ascend_v(end)
			% The object priority is less than the maximum object priority:

			% Waitbar:
			if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
				waitbar_t1	= clock;
				progress		= 0.5+min(imapobj_sort/length(imapobj_ascend_v),1)/2;
				set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
				set(GV_H.text_waitbar,'String',sprintf('%s - detection (%1.0f/%1.0f)',...
					APP.MapEdit_DetectOverlappedTextsSymbols_Menu.Text,...
					imapobj_sort,length(imapobj_ascend_v)));
				drawnow;
			end
			if   (strcmp(MAP_OBJECTS(imapobj,1).disp,'text')           ||...
					strcmp(MAP_OBJECTS(imapobj,1).disp,'symbol')         ||...
					strcmp(MAP_OBJECTS(imapobj,1).disp,'connection line')     )&&...
					(MAP_OBJECTS(imapobj,1).iobj>0)
				% Consider only texts and symbols:

				% poly_imapobj: Current map object (text or symbol):
				poly_imapobj		= polyshape();
				ud_maxlevel			= -1;
				for rpoly=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if    MAP_OBJECTS(imapobj,1).h(rpoly,1).Visible                                        &&...
							isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
							isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).FaceAlpha,GV.visibility.show.facealpha)
						ud	= MAP_OBJECTS(imapobj,1).h(rpoly,1).UserData;
						if length(ud)~=1
							errormessage;
						end
						if isfield(ud,'color_no')&&isfield(ud,'prio')&&isfield(ud,'iobj')
							if ud.iobj>0
								% A plot object can consist of more than one color:
								icol							= find(colno_v==ud.color_no);
								if icol>size(poly_imapobj,1)
									poly_imapobj(icol,1)	= MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape;
								else
									poly_imapobj(icol,1)	= union(poly_imapobj(icol,1),...
										MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape,...
										'KeepCollinearPoints',false);
								end
								ud_maxlevel					= max(ud_maxlevel,ud.level);
							end
						end
					end
				end

				% Polygon imapobj buffered by d_side:
				poly_imapobj_buff		= poly_imapobj;
				for icol=1:size(poly_imapobj,1)
					if numboundaries(poly_imapobj(icol,1))>0
						colno				= colno_v(icol,1);
						if colno>0
							icolspec		= PP.color(colno).spec;
							d_side		= PP.colorspec(icolspec).d_side;
						else
							d_side		= 0;
						end
						if d_side>0
							if strcmp(GV.jointtype_bh,'miter')
								poly_imapobj_buff(icol,1)	= polybuffer(poly_imapobj_buff(icol,1),d_side,...
									'JointType','Miter','MiterLimit',miterlimit);
							else
								poly_imapobj_buff(icol,1)	= polybuffer(poly_imapobj_buff(icol,1),d_side,...
									'JointType',GV.jointtype_bh);
							end
						end
					end
				end

				% Check for overlap:
				if any(overlaps(poly_imapobj,GV_H.poly_map_printout_obj_limits.Shape))
					% The polygon poly_imapobj is inside the map printout limits:
					poly_overlap_buff_imapobj	= polyshape();
					overlap_detected				= false;
					for icol_all=1:length(colno_v)
						for icol=1:size(poly_imapobj,1)
							if numboundaries(poly_imapobj(icol,1))>0
								colno_all	= colno_v(icol_all,1);
								colno			= colno_v(icol,1);
								if (colno==colno_all)&&(ud_maxlevel~=0)
									% Same color: Do not consider d_side and only check the foreground for overlap:
									if overlaps(poly_imapobj(icol,1),poly_all(imapobj_sort+1,1).onlyforeground(icol_all,1))
										overlap_detected				= true;
										imapobj_overlap_v				= [imapobj_overlap_v;imapobj];
										poly_overlap_buff_imapobj	= union(...
											poly_overlap_buff_imapobj,intersect(...
											poly_imapobj(icol,1),...
											poly_all(imapobj_sort+1,1).forebackground(icol_all,1)));
									end
								elseif colno~=colno_all
									% Different colors: Consider d_side:
									if overlaps(poly_imapobj_buff(icol,1),poly_all(imapobj_sort+1,1).forebackground(icol_all,1))
										overlap_detected		= true;
										imapobj_overlap_v		= [imapobj_overlap_v;imapobj];
										poly_overlap_buff_imapobj	= union(...
											poly_overlap_buff_imapobj,intersect(...
											poly_imapobj_buff(icol,1),...
											poly_all(imapobj_sort+1,1).forebackground(icol_all,1)));
									end
								end
							end
						end
					end
					if overlap_detected
						% Overlap detected:
						% Add the object to poly_overlap_buff:
						poly_overlap_buff	= union(poly_overlap_buff,poly_overlap_buff_imapobj);
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
							[xlim,ylim]			= boundingbox(poly_imapobj);
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
	end
	imapobj_overlap_v		= unique(imapobj_overlap_v);

	% Display all overlapping objects as preview objects:
	% Plot the overlapping objects:
	if numboundaries(poly_overlap_buff)>0
		if isempty(imapobj_overlapping_objects_preview)
			imapobj_overlapping_objects_preview		= plot_modify('new_poly',0,...
				poly_overlap_buff,...			% preview polygon
				dscr_prev,...						% description
				text_prev,...						% text
				false);								% select (true/false)
		else
			[xcenter,ycenter]																	= centroid(poly_overlap_buff);
			MAP_OBJECTS(imapobj_overlapping_objects_preview,1).h(1,1).Shape	= poly_overlap_buff;
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
	if ~isempty(imapobj_overlap_v)
		warntext	= sprintf([...
			'The following texts and symbols are\n',...
			'overlapped by other map objects: PlotNo = \n']);
		for i=1:size(imapobj_overlap_v,1)
			warntext	= sprintf('%s%12.0f',warntext,imapobj_overlap_v(i,1));
			if mod(i,4)==0
				warntext	= sprintf('%s\n',warntext);
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

