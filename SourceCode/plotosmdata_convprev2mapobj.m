function plotosmdata_convprev2mapobj(iobj)
% Convert preview to map object:
% One preview object (one row) in MAP_OBJECTS_TABLE must be selected.
% The line or polygon will be converted into a map object using the parameters of object number iobj.

global PP GV GV_H APP MAP_OBJECTS PLOTDATA WAITBAR OSMDATA

try
	
	WAITBAR.t1			= clock;										% Time of the last update
	
	if iobj<1
		errormessage(sprintf(['Error:\n',...
			'The minimum object number is ObjNo=1.']));
	end
	if iobj>size(PP.obj,1)
		errormessage(sprintf(['Error:\n',...
			'The maximum object number is ObjNo=%g.'],size(PP.obj,1)));
	end
	if  ~(( PP.obj(iobj).display==1                                                           )||...
			((PP.obj(iobj).symbolpar.display==1)&&APP.CreatemapSettingsCreateSymbolsMenu.Checked)||...
			((PP.obj(iobj).textpar.display  ==1)&&APP.CreatemapSettingsCreateTextsMenu.Checked  )     )
		errormessage(sprintf(['Error:\n',...
			'Object number ObjNo=%g\n',...
			'(%s):\n',...
			'The display of lines, areas, texts\n',...
			'and symbols is switched off.'],iobj,PP.obj(iobj).description));
		% Remark: Texts of a preview will not be displayed, because a preview has no tags.
	end
	msg		= [APP.Mod_ConvPrevToMapobj_Button.Text ' ...'];				% 'Polygon to map object'
	
	% Assign imapobj_v:
	imapobj_v				= zeros(0,1);
	for imapobj=1:size(MAP_OBJECTS,1)
		for r=1:size(MAP_OBJECTS(imapobj,1).h,1)
			for c=1:size(MAP_OBJECTS(imapobj,1).h,2)
				if MAP_OBJECTS(imapobj,1).h(r,c).Selected
					imapobj_v				= [imapobj_v;imapobj];
				end
			end
		end
	end
	imapobj_v	= unique(imapobj_v);
	if isempty(imapobj_v)
		errormessage(sprintf(['Error:\n',...
			'At least one object must be selected to use this function.']));
	end
	for i_imapobj=1:length(imapobj_v)
		imapobj	= imapobj_v(i_imapobj);
		if (MAP_OBJECTS(imapobj,1).iobj>=0)&&(...
				strcmp(MAP_OBJECTS(imapobj,1).disp,'area')           ||...
				strcmp(MAP_OBJECTS(imapobj,1).disp,'line')           ||...
				strcmp(MAP_OBJECTS(imapobj,1).disp,'text')           ||...
				strcmp(MAP_OBJECTS(imapobj,1).disp,'connection line')||...
				strcmp(MAP_OBJECTS(imapobj,1).disp,'symbol')              )
			if ~isempty(MAP_OBJECTS(imapobj,1).dscr)
				dscr_str		= sprintf(' (%s)',MAP_OBJECTS(imapobj,1).dscr);
			else
				dscr_str		= '';
			end
			errormessage(sprintf(['Error:\n',...
				'The conversion of the selected object\n',...
				'PlotNo=%g%s\n',...
				'into a map object is not possible\n',...
				'because it is already a map object\n',...
				'You have to select a preview map object.'],...
				imapobj,dscr_str));
		end
		if (MAP_OBJECTS(imapobj,1).iobj>=0)&&~isequal(MAP_OBJECTS(imapobj,1).iobj,iobj)
			% errormessage(sprintf(['Error:\n',...
			% 	'To convert the selected object PlotNo=%g\n',...
			% 	'you have to enter ObjNo=%g.'],imapobj,MAP_OBJECTS(imapobj,1).iobj));
			question	= sprintf([...
				'The object with PlotNo=%g has the object number\n',...
				'ObjNo=%g (%s).\n',...
				'Are you sure you want to convert it \n',...
				'to an object with the object number\n',...
				'ObjNo=%g (%s)?'],imapobj,...
				MAP_OBJECTS(imapobj,1).iobj,PP.obj(MAP_OBJECTS(imapobj,1).iobj,1).description,...
				iobj,PP.obj(iobj,1).description);
			answer	= questdlg_local(question,'Preview to map object','Yes','No','No');
			if strcmp(answer,'No')
				return
			end
		end
		if strcmp(MAP_OBJECTS(imapobj,1).disp,'area - not closed')
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'line')
					if    (abs(MAP_OBJECTS(imapobj,1).h(i,1).XData(1)-MAP_OBJECTS(imapobj,1).h(i,1).XData(end))>GV.tol_1)||...
							(abs(MAP_OBJECTS(imapobj,1).h(i,1).YData(1)-MAP_OBJECTS(imapobj,1).h(i,1).YData(end))>GV.tol_1)
						errormessage(sprintf(['Error:\n',...
							'The selected object PlotNo=%g\n',...
							'may only consist of closed lines.'],imapobj));
					end
				end
			end
		end
	end
	
	% Display state:
	t_start_statebusy	= clock;
	if length(imapobj_v)==1
		imapobj_v_str			= sprintf('%g',imapobj_v);
	else
		imapobj_v_str			= sprintf('%g..%g',min(imapobj_v),max(imapobj_v));
	end
	display_on_gui_str	= sprintf('Convert PlotNo=%s to map object ...',imapobj_v_str);
	display_on_gui('state',display_on_gui_str,'busy','add');
	
	% Delete legend:
	if length(imapobj_v)>1
		if ~APP.Mod_MergeWithExistObj_CheckBox.Value
			legend(GV_H.ax_2dmap,'off');
		end
	end
	
	imapobj_v		= sort(unique(imapobj_v),'descend');
	
	if APP.Mod_MergeWithExistObj_CheckBox.Value
		% Merge with existing objects:
		
		% User confirmation:
		question	= sprintf([...
			'Add the data of PlotNo=%s to ObjNo=%g?\n',...
			'This operation cannot be undone.\n',...
			'\n',...
			'Because the "Merge" checkbox is activated:\n',...
			'- All objects with the object number %g are recreated.\n',...
			'- If objects were previously added without activating\n',...
			'  "Merge", they are lost.\n',...
			'- All manual modifications to texts and symbols will be lost.\n'],imapobj_v_str,iobj,iobj);
		if GV.map_is_saved==0
			question	= sprintf('%s\nThe project should be saved first.\n',question);
		end
		answer	= questdlg_local(question,'Continue?','Continue','Cancel','Cancel');
		if isempty(answer)||strcmp(answer,'Cancel')
			display_on_gui('state',...
				sprintf('%s Canceled (%s).',display_on_gui_str,dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			return
		end
		
		% Delete the old objects:
		imapobj_existing	= find([MAP_OBJECTS.iobj]==iobj);
		
		% Add the colornumber to PLOTDATA.colno_v:
		if isequal(PP.obj(iobj).display,1)
			PLOTDATA.obj(iobj,1).colno_fgd	= PP.obj(iobj).color_no_fgd;
			PLOTDATA.obj(iobj,1).colno_bgd	= PP.obj(iobj).color_no_bgd;
			if ~isequal(PLOTDATA.obj(iobj,1).colno_fgd,0)
				PLOTDATA.colno_v			= unique([PLOTDATA.colno_v;PLOTDATA.obj(iobj,1).colno_fgd]);
			end
			if ~isequal(PLOTDATA.obj(iobj,1).colno_bgd,0)
				PLOTDATA.colno_v			= unique([PLOTDATA.colno_v;PLOTDATA.obj(iobj,1).colno_bgd]);
			end
		end
		
		% Total line width:
		if PP.obj(iobj).display_as_line~=0
			[~,~,~,~,PLOTDATA.obj(iobj,1).linewidth]	= line2poly(...
				[],...										% x
				[],...										% y
				PP.obj(iobj).linepar,...				% par
				PP.obj(iobj).linestyle,...				% style
				iobj);										% iobj
		else
			PLOTDATA.obj(iobj,1).linewidth			= [];
		end
		
		% Add the preview data to PLOTDATA:
		connways_preview			= connect_ways([]);
		if isempty(PLOTDATA.obj(iobj,1).connways)
			lino_new_min	= 1;
		else
			lino_new_min	= PLOTDATA.obj(iobj,1).connways.lino_max+1;
		end
		
		k_line_delete		= [];
		for i_imapobj=1:length(imapobj_v)
			imapobj	= imapobj_v(i_imapobj);
			tag		= MAP_OBJECTS(imapobj,1).text{1,1};
			
			% Add the preview data to PLOTDATA:
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				
				% Relation number of the preview:
				if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'relid')
					relid		= MAP_OBJECTS(imapobj,1).h(i,1).UserData.relid;
					ir			= find(OSMDATA.id.relation==relid,1);
				else
					relid		= uint64(0);
					ir			= 0;
				end
				
				% Add the data to connways_preview:
				switch MAP_OBJECTS(imapobj,1).h(i,1).Type
					case 'polygon'
						% x		= MAP_OBJECTS(imapobj,1).h(i,1).Shape.Vertices(:,1);
						% y		= MAP_OBJECTS(imapobj,1).h(i,1).Shape.Vertices(:,2);
						% Additional userdata:
						in		= 0;
						iw_v	= 0;
						if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'iw')
							if ~isempty(MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw)
								iw_v	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw(:);
							end
						end
						for ib=1:numboundaries(MAP_OBJECTS(imapobj,1).h(i,1).Shape)
							[x,y] = boundary(MAP_OBJECTS(imapobj,1).h(i,1).Shape,ib);
							x		= x(:);
							y		= y(:);
							if ishole(MAP_OBJECTS(imapobj,1).h(i,1).Shape,ib)
								role	= 'inner';
							else
								role	= 'outer';
							end
							connways_preview		= ...
								connect_ways(...							%								Defaultvalues:
								connways_preview,...						% connways					-
								[],...										% connways_merge			[]
								x,...											% x							[]
								y,...											% y							[]
								iobj,...										% iobj						[]
								[],...										% lino						[]
								PLOTDATA.obj(iobj,1).linewidth,...	% liwi						[]
								in,...										% in							0
								iw_v,...										% iw_v						0
								ir,...										% ir							0
								1,...											% l2a							1
								1,...											% s							1
								lino_new_min,...							% lino_new_min				1
								role,...										% role						'inner'/'outer'
								relid,...									% relid						uint64(0)
								tag,...										% tag							''
								GV.tol_1,...								% tol							GV.tol_1
								true,...										% conn_with_rev			true
								true);										% connect					true
						end
					case 'line'
						x		= MAP_OBJECTS(imapobj,1).h(i,1).XData;
						y		= MAP_OBJECTS(imapobj,1).h(i,1).YData;
						x		= x(:);
						y		= y(:);
						% Additional userdata:
						in		= 0;
						iw_v	= 0;
						if size(x,1)==1
							if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'in')
								if ~isempty(MAP_OBJECTS(imapobj,1).h(i,1).UserData.in)
									% "in" must be scalar: use only the first element:
									in		= MAP_OBJECTS(imapobj,1).h(i,1).UserData.in(1,1);
								end
							end
						else
							if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'iw')
								if ~isempty(MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw)
									iw_v	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw(:);
								end
							end
						end
						connways_preview		= ...
							connect_ways(...							%								Defaultvalues:
							connways_preview,...						% connways					-
							[],...										% connways_merge			[]
							x,...											% x							[]
							y,...											% y							[]
							iobj,...										% iobj						[]
							[],...										% lino						[]
							PLOTDATA.obj(iobj,1).linewidth,...	% liwi						[]
							in,...										% in							0
							iw_v,...										% iw_v						0
							ir,...										% ir							0
							1,...											% l2a							1
							1,...											% s							1
							lino_new_min,...							% lino_new_min				1
							'outer',...									% role						'outer'
							relid,...									% relid						uint64(0)
							tag,...										% tag							''
							GV.tol_1,...								% tol							GV.tol_1
							true,...										% conn_with_rev			true
							true);										% connect					true
				end
				
				% Delete the open lines 'area - not closed':
				% Disabled: the open lines should be retained to control the manual correction.
				delete_open_lines		= false;
				if delete_open_lines
					if    (abs(x(1)-x(end))<GV.tol_1)&&...
							(abs(y(1)-y(end))<GV.tol_1)
						% The preview is a closed line or a polygon:
						k_line_v		= find(PLOTDATA.obj(iobj,1).connways.lines_relid==relid);
						for ik_line=1:length(k_line_v)
							k_line		= k_line_v(ik_line);
							% The line k_line has the same relation number than the preview:
							if strcmp(PLOTDATA.obj(iobj,1).connways.lines(k_line,1).tag,tag)
								% The line k_line has the same tag than the preview:
								line_xy		= PLOTDATA.obj(iobj,1).connways.lines(k_line,1).xy(:,1:2);
								% Downsampling like the preview lines in plotosmdata_plotdata_li_ar.m:
								% Otherwise the use of isvertexmember below does not work.
								dmax				= [];
								nmin				= [];
								dmin_lines		= PP.obj(iobj).reduce_lines.dmin;			% minimum distance between vertices
								if dmin_lines>0
									[line_x,line_y]	= changeresolution_xy(...
										line_xy(:,1),...
										line_xy(:,2),dmax,dmin_lines,nmin);
									line_xy		= [line_x line_y];
								end
								% Points inside the map limits:
								in				= inpolygon(...
									line_xy(:,1),...																% xq
									line_xy(:,2),...																% yq
									GV_H.poly_map_printout_obj_limits.Shape.Vertices(:,1),...		% xv
									GV_H.poly_map_printout_obj_limits.Shape.Vertices(:,2));			% yv
								line_inside_map_limits_xy		= line_xy(in,:);
								i_va			= isvertexmember(...
									line_inside_map_limits_xy,...												% va
									[x y],...																		% vb
									GV.tol_1);																		% tol
								if isequal(i_va,true(size(line_inside_map_limits_xy,1),1))
									% All points of
									% PLOTDATA.obj(iobj,1).connways.lines(k_line,1).xy(1:2,:)
									% on the map area (inside GV_H.poly_map_printout_obj_limits) lie on the preview line
									% MAP_OBJECTS(imapobj,1).h(i,1).Shape
									% and have the same relation number:
									% It is highly likely that the line PLOTDATA.obj(iobj,1).connways.lines(k_line,1) was modified.
									% Delete this line so it does not appear again on the map:
									k_line_delete		= [k_line_delete;k_line];
									break
								end
							end
						end
					end
				end
				
				% Additional userdata:
				if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'in')
					PLOTDATA.obj(iobj,1).ud_in_v	= ...
						[PLOTDATA.obj(iobj,1).ud_in_v(:);MAP_OBJECTS(imapobj,1).h(i,1).UserData.in(:)];
				end
				if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'iw')
					PLOTDATA.obj(iobj,1).ud_iw_v	= ...
						[PLOTDATA.obj(iobj,1).ud_iw_v(:);MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw(:)];
				end
				if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'ir')
					PLOTDATA.obj(iobj,1).ud_ir_v	= ...
						[PLOTDATA.obj(iobj,1).ud_ir_v(:);MAP_OBJECTS(imapobj,1).h(i,1).UserData.ir(:)];
				end
				
			end
		end
		
		% Try to connect the remaining open lines with increased tolerance:
		if PP.obj(iobj,1).connect_ways_with_rev~=0
			conn_with_rev		= true;
		else
			conn_with_rev		= false;
		end
		connect_ways_tol	= PP.obj(iobj,1).connect_ways_tol;
		if connect_ways_tol>GV.tol_1
			connways_preview		= connect_ways_apply_tol(...
				connways_preview,...				% connways
				connect_ways_tol,...				% tol
				conn_with_rev);					% conn_with_rev
		end
		
		% Add connways_preview to PLOTDATA.obj(iobj,1).connways:
		if ~isempty(k_line_delete)
			k_line_delete																	= unique(k_line_delete);
			PLOTDATA.obj(iobj,1).connways.lines(k_line_delete,:)				= [];
			PLOTDATA.obj(iobj,1).connways.lines_isouter(k_line_delete,:)	= [];
			PLOTDATA.obj(iobj,1).connways.lines_isinner(k_line_delete,:)	= [];
			PLOTDATA.obj(iobj,1).connways.lines_relid(k_line_delete,:)		= [];
			PLOTDATA.obj(iobj,1).connways.xy_start(k_line_delete,:)			= [];
			PLOTDATA.obj(iobj,1).connways.xy_end(k_line_delete,:)				= [];
		end
		PLOTDATA.obj(iobj,1).connways		= connect_ways(PLOTDATA.obj(iobj,1).connways,connways_preview);
		PLOTDATA.obj(iobj,1).ud_in_v		= unique(PLOTDATA.obj(iobj,1).ud_in_v);
		PLOTDATA.obj(iobj,1).ud_iw_v		= unique(PLOTDATA.obj(iobj,1).ud_iw_v);
		PLOTDATA.obj(iobj,1).ud_ir_v		= unique(PLOTDATA.obj(iobj,1).ud_ir_v);
		
		% Reduce plot data:
		plotosmdata_reducedata(msg);
		
		% Plot the data:
		size_map_objects_0		= size(MAP_OBJECTS,1);
		if ~isempty(PLOTDATA.obj(iobj,1).connways)
			plotosmdata_plotdata(iobj,msg);			% The legend will be updated also
		end
		no_added_objects			= size(MAP_OBJECTS,1)-size_map_objects_0;
		
		% Delete the old objects:
		% The new objects have been added at the end of MAP_OBJECTS, so the indices imapobj_existing did not change.
		plot_modify('delete',imapobj_existing);		% Includes also display_map_objects
		
		% Arrange new map objects (includes also display_map_objects):
		if APP.AutoSortNewMapObjects_Menu.Checked
			set(GV_H.text_waitbar,'String',sprintf('%s Reorder map objects table',msg));
			arrange_map_objects;				% includes also display_map_objects
		end
		
		% Update MAP_OBJECTS_TABLE: already executed by arrange_map_objects
		if ~APP.AutoSortNewMapObjects_Menu.Checked
			display_map_objects;
		end
		
		
	else
		% Do not merge with existing objects (same procedure as in plotosmdata_plotdata.m):
		
		for i_imapobj=1:length(imapobj_v)
			imapobj	= imapobj_v(i_imapobj);
			tag		= MAP_OBJECTS(imapobj,1).text{1,1};
			
			% Create the structure connways_preview:
			connways_preview			= connect_ways([]);
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				
				% Relation number of the preview:
				if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'relid')
					relid		= MAP_OBJECTS(imapobj,1).h(i,1).UserData.relid;
					ir			= find(OSMDATA.id.relation==relid,1);
				else
					relid		= uint64(0);
					ir			= 0;
				end
				
				% Add the data to connways_preview:
				switch MAP_OBJECTS(imapobj,1).h(i,1).Type
					case 'polygon'
						% x		= MAP_OBJECTS(imapobj,1).h(i,1).Shape.Vertices(:,1);
						% y		= MAP_OBJECTS(imapobj,1).h(i,1).Shape.Vertices(:,2);
						% Additional userdata:
						in		= 0;
						iw_v	= 0;
						if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'iw')
							if ~isempty(MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw)
								iw_v	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw(:);
							end
						end
						for ib=1:numboundaries(MAP_OBJECTS(imapobj,1).h(i,1).Shape)
							[x,y] = boundary(MAP_OBJECTS(imapobj,1).h(i,1).Shape,ib);
							x		= x(:);
							y		= y(:);
							if ishole(MAP_OBJECTS(imapobj,1).h(i,1).Shape,ib)
								role	= 'inner';
							else
								role	= 'outer';
							end
							connways_preview		= ...
								connect_ways(...							%								Defaultvalues:
								connways_preview,...						% connways					-
								[],...										% connways_merge			[]
								x,...											% x							[]
								y,...											% y							[]
								iobj,...										% iobj						[]
								[],...										% lino						[]
								PLOTDATA.obj(iobj,1).linewidth,...	% liwi						[]
								in,...										% in							0
								iw_v,...										% iw_v						0
								ir,...										% ir							0
								1,...											% l2a							1
								1,...											% s							1
								1,...											% lino_new_min				1
								role,...										% role						'inner'/'outer'
								relid,...									% relid						uint64(0)
								tag,...										% tag							''
								GV.tol_1,...								% tol							GV.tol_1
								true,...										% conn_with_rev			true
								true);										% connect					true
						end
					case 'line'
						x		= MAP_OBJECTS(imapobj,1).h(i,1).XData;
						y		= MAP_OBJECTS(imapobj,1).h(i,1).YData;
						x		= x(:);
						y		= y(:);
						% Additional userdata:
						in		= 0;
						iw_v	= 0;
						if size(x,1)==1
							if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'in')
								if ~isempty(MAP_OBJECTS(imapobj,1).h(i,1).UserData.in)
									% "in" must be scalar: use only the first element:
									in		= MAP_OBJECTS(imapobj,1).h(i,1).UserData.in(1,1);
								end
							end
						else
							if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'iw')
								if ~isempty(MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw)
									iw_v	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw(:);
								end
							end
						end
						connways_preview		= ...
							connect_ways(...							%								Defaultvalues:
							connways_preview,...						% connways					-
							[],...										% connways_merge			[]
							x,...											% x							[]
							y,...											% y							[]
							iobj,...										% iobj						[]
							[],...										% lino						[]
							PLOTDATA.obj(iobj,1).linewidth,...	% liwi						[]
							in,...										% in							0
							iw_v,...										% iw_v						0
							ir,...										% ir							0
							1,...											% l2a							1
							1,...											% s							1
							1,...											% lino_new_min				1
							'outer',...									% role						'outer'
							relid,...									% relid						uint64(0)
							tag,...										% tag							''
							GV.tol_1,...								% tol							GV.tol_1
							true,...										% conn_with_rev			true
							true);										% connect					true
				end
			end
			
			% Try to connect the remaining open lines with increased tolerance:
			if PP.obj(iobj,1).connect_ways_with_rev~=0
				conn_with_rev		= true;
			else
				conn_with_rev		= false;
			end
			connect_ways_tol	= PP.obj(iobj,1).connect_ways_tol;
			if connect_ways_tol>GV.tol_1
				connways_preview		= connect_ways_apply_tol(...
					connways_preview,...				% connways
					connect_ways_tol,...				% tol
					conn_with_rev);					% conn_with_rev
			end
			
			% Simplify and plot lines and areas:
			if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'in')
				ud_in_v	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.in;
			else
				ud_in_v	= [];
			end
			if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'iw')
				ud_iw_v	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw;
			else
				ud_iw_v	= [];
			end
			if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'ir')
				ud_ir_v	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.ir;
			else
				ud_ir_v	= [];
			end
			plotosmdata_plotdata_li_ar(iobj,connways_preview,ud_in_v,ud_iw_v,ud_ir_v,msg,0);
			
		end
		
		% Create/modify legend:
		if isscalar(imapobj_v)
			create_legend_mapfigure;
		end
		
		% Delete the old objects:
		% The new objects have been added at the end of MAP_OBJECTS, so the indices imapobj_v did not change.
		plot_modify('delete',imapobj_v);		% Includes also display_map_objects
		
	end
	
	% Create/modify legend:
	if length(imapobj_v)>1
		if ~APP.Mod_MergeWithExistObj_CheckBox.Value
			create_legend_mapfigure;
		end
	end
	
	% Deselect all:
	plot_modify('deselect',-1,0);
	
	% The map has been changed:
	GV.map_is_saved	= 0;
	
	% Reset waitbar:
	set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
	set(GV_H.text_waitbar,'String','');
	
	% Finish updating:
	drawnow;
	
	% Display state:
	display_on_gui('state',...
		sprintf('%s done (%s).',display_on_gui_str,dt_string(etime(clock,t_start_statebusy))),...
		'notbusy','replace');
	
catch ME
	errormessage('',ME);
end

