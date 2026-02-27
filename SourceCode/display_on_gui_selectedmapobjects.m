function display_on_gui_selectedmapobjects
% Display number and PlotNo of selected map objects:

global GV GV_H PP APP MAP_OBJECTS

try
	
	if isempty(MAP_OBJECTS)
		return
	end
	
	% Set GV.selected_plotobjects and GV.no_selected_plotobjects:
	GV.selected_plotobjects	= false(size(MAP_OBJECTS,1),1);
	for imapobj=1:size(MAP_OBJECTS,1)
		if ~isempty(MAP_OBJECTS(imapobj,1).h)
			if ~isnumeric(MAP_OBJECTS(imapobj,1).h)
				if isvalid(MAP_OBJECTS(imapobj,1).h)
					if MAP_OBJECTS(imapobj,1).h(1,1).Selected
						GV.selected_plotobjects(imapobj,1)	= true;
					end
				end
			end
		end
	end
	GV.selected_plotobjects		= find(GV.selected_plotobjects);
	GV.no_selected_plotobjects	= length(GV.selected_plotobjects);
	
	% Display number and PlotNo of selected map objects:
	no_sel_plotobj_max	= 20;
	plotno_str				= '';
	for i=1:min(no_sel_plotobj_max,length(GV.selected_plotobjects))
		if i==1
			plotno_str		= sprintf('%g',GV.selected_plotobjects(i,1));
		else
			plotno_str		= sprintf('%s, %g',plotno_str,GV.selected_plotobjects(i,1));
		end
	end
	if length(GV.selected_plotobjects)>no_sel_plotobj_max
		plotno_str		= sprintf('%s ...',plotno_str);
	end
	if GV.no_selected_plotobjects==0
		set(GV_H.text_waitbar,'String','No plot objects selected.');
		APP.Mod_Polygons_PlotNo1_EditField.Value			= 0;
		APP.Mod_Polygons_PlotNo2_EditField.Value			= 0;
		% APP.Mod_AddPrevToOutput_ObjNo_EditField.Value	= 0;		% Keep the last value
	elseif GV.no_selected_plotobjects==1
		imapobj					= GV.selected_plotobjects;
		obj_info_str		= '';
		% Object information: object number:
		if MAP_OBJECTS(imapobj,1).iobj>0
			obj_info_str		= sprintf('ObjNo %1.0f',MAP_OBJECTS(imapobj,1).iobj);
		end
		% Object information: color number:
		if MAP_OBJECTS(imapobj,1).iobj>=0
			colno_v	= [];
			d_side_v	= [];
			if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'color_no')
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					colno			= MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no;
					colno_v		= [colno_v;colno];
					if colno>0
						icolspec		= PP.color(colno).spec;
						d_side		= PP.colorspec(icolspec).d_side;
						d_side_v		= [d_side_v;d_side];
					end
				end
			end
			colno_v	= unique(colno_v);
			d_side_v	= unique(d_side_v);
			if (length(colno_v)>=1)&&(length(colno_v)<=2)
				if isscalar(colno_v)
					colno_str	= sprintf('ColNo: %g',colno_v);
				else
					colno_str	= sprintf('ColNo: %g, %g',colno_v(1),colno_v(2));
				end
				d_side		= max(d_side_v);
				if isempty(d_side)
					d_side_str	= '';
				else
					d_side_str	= sprintf(' (d_side=%gmm)',d_side);
				end
				if isempty(obj_info_str)
					obj_info_str		= sprintf('%s%s',colno_str,d_side_str);
				else
					obj_info_str		= sprintf('%s  /  %s%s',obj_info_str,colno_str,d_side_str);
				end
			end
		end
		% Object information: description:
		if ~isempty(MAP_OBJECTS(imapobj,1).dscr)
			if isempty(obj_info_str)
				obj_info_str		= sprintf('%s',MAP_OBJECTS(imapobj,1).dscr);
			else
				obj_info_str		= sprintf('%s  /  %s',obj_info_str,MAP_OBJECTS(imapobj,1).dscr);
			end
		end
		% Object information: Text/Tag:
		text_tag_str		= '';
		for itext=1:size(MAP_OBJECTS(imapobj,1).text,1)
			if itext==1
				text_tag_str	= MAP_OBJECTS(imapobj,1).text{itext,1};
			else
				text_tag_str	= strcat(text_tag_str," ",MAP_OBJECTS(imapobj,1).text{itext,1});
			end
		end
		if ~isempty(text_tag_str)
			if isempty(obj_info_str)
				obj_info_str		= sprintf('%s',text_tag_str);
			else
				obj_info_str		= sprintf('%s  /  %s',obj_info_str,text_tag_str);
			end
		end
		% Object information: display as:
		if ~isempty(MAP_OBJECTS(imapobj,1).disp)
			if isempty(obj_info_str)
				obj_info_str		= sprintf('%s',MAP_OBJECTS(imapobj,1).disp);
			else
				obj_info_str		= sprintf('%s  /  %s',obj_info_str,MAP_OBJECTS(imapobj,1).disp);
			end
		end
		% Object information:
		if ~isempty(obj_info_str)
			obj_info_str			= sprintf(' (%s)',obj_info_str);
		end
		% Object information: number of regions:
		no_regions					= 0;
		for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
			if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
				poly_reg				= regions(MAP_OBJECTS(imapobj,1).h(i,1).Shape);
				no_regions			= no_regions+size(poly_reg,1);
			end
		end
		if no_regions==0
			no_regions_str			= '';			% Line object
		elseif no_regions==1
			no_regions_str			= '1 region';
		else
			no_regions_str			= sprintf('%1.0f regions',no_regions);
		end
		if ~isempty(no_regions_str)
			obj_info_str		= sprintf(': %s%s',no_regions_str,obj_info_str);
		end
		% Display object information:
		set(GV_H.text_waitbar,'String',sprintf('1 plot object selected: PlotNo = %s%s',plotno_str,obj_info_str));
		APP.Mod_Polygons_PlotNo2_EditField.Value			= 0;
		if MAP_OBJECTS(imapobj,1).iobj>0
			APP.Mod_AddPrevToOutput_ObjNo_EditField.Value	= MAP_OBJECTS(imapobj,1).iobj;
		end
	else
		set(GV_H.text_waitbar,'String',sprintf('%g plot objects selected: PlotNo = %s',...
			GV.no_selected_plotobjects,plotno_str));
	end
	
catch ME
	errormessage('',ME);
end

