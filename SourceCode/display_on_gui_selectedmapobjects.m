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
		% No objects are selected:
		set(GV_H.text_waitbar,'String','No plot objects selected.');
		APP.Mod_Polygons_PlotNo1_EditField.Value			= 0;
		APP.Mod_Polygons_PlotNo2_EditField.Value			= 0;
		% APP.Mod_AddPrevToOutput_ObjNo_EditField.Value	= 0;		% Keep the last value
	else
		% At least one object is selected:
		imapobj_v		= GV.selected_plotobjects;
		obj_info_str	= '';
		% Get information about the objects to be deleted:
		imax_objno		= 1;
		imax_colno		= 2;
		imax_dscr		= 1;
		imax_text		= 1;
		imax_disp		= 1;
		[...
			objno_v,...							% numerical array:	object number
			colno_v,...							% numerical array:	color number
			dscr_v,...							% string array:		description
			text_v,...							% string array:		text
			disp_v...							% string array:		display as
			]=get_mapobj_information(...
			imapobj_v,...						% vector of indices in MAP_OBJECTS
			imax_objno+1,...						% maximum length of objno_v
			imax_colno+1,...						% maximum length of colno_v
			imax_dscr+1,...						% maximum length of dscr_v
			imax_text+1,...						% maximum length of text_v
			imax_disp+1);						% maximum length of disp_v
		% Object information: object number:
		if (size(objno_v,1)>=1)&(size(objno_v,1)<=imax_objno)
			if isempty(obj_info_str)
				obj_info_str		= sprintf('ObjNo: %1.0f',objno_v);
			else
				obj_info_str		= sprintf('%s  /  ObjNo %1.0f',obj_info_str,objno_v);
			end
		end
		% Object information: color number:
		if (size(colno_v,1)>=1)&(size(colno_v,1)<=imax_colno)
			d_side_v	= [];
			for i_colno=1:size(colno_v,1)
				colno		= colno_v(i_colno,1);
				if colno>0
					icolspec		= PP.color(colno).spec;
					d_side		= PP.colorspec(icolspec).d_side;
					d_side_v		= [d_side_v;d_side];
				end
			end
			d_side_v	= unique(d_side_v);
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
		% Object information: description:
		if (size(dscr_v,1)>=1)&(size(dscr_v,1)<=imax_dscr)
			if ~isequal(dscr_v(1,1),"")
				if isempty(obj_info_str)
					obj_info_str		= sprintf('%s',dscr_v(1,1));
				else
					obj_info_str		= sprintf('%s  /  %s',obj_info_str,dscr_v(1,1));
				end
			end
		end
		% Object information: Text/Tag:
		if (size(text_v,1)>=1)&(size(text_v,1)<=imax_text)
			if ~isequal(text_v(1,1),"")
				if isempty(obj_info_str)
					obj_info_str		= sprintf('%s',text_v(1,1));
				else
					obj_info_str		= sprintf('%s  /  %s',obj_info_str,text_v(1,1));
				end
			end
		end
		% Object information: display as:
		if (size(disp_v,1)>=1)&(size(disp_v,1)<=imax_disp)
			if ~isequal(disp_v(1,1),"")
				if isempty(obj_info_str)
					obj_info_str		= sprintf('%s',disp_v(1,1));
				else
					obj_info_str		= sprintf('%s  /  %s',obj_info_str,disp_v(1,1));
				end
			end
		end
		% Object information:
		if ~isempty(obj_info_str)
			obj_info_str			= sprintf(' (%s)',obj_info_str);
		end
		% Additional information:
		if GV.no_selected_plotobjects==1
			% Object information: number of regions:
			no_regions					= 0;
			for i=1:size(MAP_OBJECTS(imapobj_v,1).h,1)
				if strcmp(MAP_OBJECTS(imapobj_v,1).h(i,1).Type,'polygon')
					poly_reg				= regions(MAP_OBJECTS(imapobj_v,1).h(i,1).Shape);
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
				obj_info_str		= sprintf('%s: %s',obj_info_str,no_regions_str);
			end
		elseif GV.no_selected_plotobjects==2
			% Object information: minimum distance between two polygons:
			poly1		= polyshape();
			poly2		= polyshape();
			if strcmp(MAP_OBJECTS(imapobj_v(1,1),1).h(1,1).Type,'polygon')
				poly1		= MAP_OBJECTS(imapobj_v(1,1),1).h(1,1).Shape;
			end
			if strcmp(MAP_OBJECTS(imapobj_v(2,1),1).h(1,1).Type,'polygon')
				poly2		= MAP_OBJECTS(imapobj_v(2,1),1).h(1,1).Shape;
			end
			for i=2:size(MAP_OBJECTS(imapobj_v(1,1),1).h,1)
				if strcmp(MAP_OBJECTS(imapobj_v(1,1),1).h(i,1).Type,'polygon')
					poly1		= union(poly1,MAP_OBJECTS(imapobj_v(1,1),1).h(i,1).Shape);
				end
			end
			for i=2:size(MAP_OBJECTS(imapobj_v(2,1),1).h,1)
				if strcmp(MAP_OBJECTS(imapobj_v(2,1),1).h(i,1).Type,'polygon')
					poly2		= union(poly2,MAP_OBJECTS(imapobj_v(2,1),1).h(i,1).Shape);
				end
			end
			if (numboundaries(poly1)>0)&&(numboundaries(poly2)>0)
				if overlaps(poly1,poly2)
					dmin_str		= 'overlap';
				else
					[  dmin1,...		% dmin	N*1 vector: minimum distances
						~,...			% vx_dmin	N*1 vector: nearest points of the polygon to the query points  (x coordinates)
						~,...			% vy_dmin	N*1 vector: nearest points of the polygon to the query points  (y coordinates)
						~,...			% i_dmin		N*1 vector: indices of the line segments corresponding to vx_dmin, vy_dmin
						~...			% k_dmin		N*1 vector: pos. of the point [vx_dmin vy_dmin] on the line segment i_dmin
						]=mindistance_poly_p(...
						poly1.Vertices(:,1),...		% vx			polygon vertices x
						poly1.Vertices(:,2),...		% vy			polygon vertices y
						poly2.Vertices(:,1),...		% pqx			N*1 vector: query points (x coordinates)
						poly2.Vertices(:,2),...		% pqy			N*1 vector: query points (y coordinates)
						true);							% poly_is_closed	optional (default: true):
					[  dmin2,...		% dmin	N*1 vector: minimum distances
						~,...			% vx_dmin	N*1 vector: nearest points of the polygon to the query points  (x coordinates)
						~,...			% vy_dmin	N*1 vector: nearest points of the polygon to the query points  (y coordinates)
						~,...			% i_dmin		N*1 vector: indices of the line segments corresponding to vx_dmin, vy_dmin
						~...			% k_dmin		N*1 vector: pos. of the point [vx_dmin vy_dmin] on the line segment i_dmin
						]=mindistance_poly_p(...
						poly2.Vertices(:,1),...		% vx			polygon vertices x
						poly2.Vertices(:,2),...		% vy			polygon vertices y
						poly1.Vertices(:,1),...		% pqx			N*1 vector: query points (x coordinates)
						poly1.Vertices(:,2),...		% pqy			N*1 vector: query points (y coordinates)
						true);							% poly_is_closed	optional (default: true):
					dmin1				= min(dmin1);
					dmin2				= min(dmin2);
					dmin_str			= sprintf('min. distance %1.3f mm',min(dmin1,dmin2));
				end
				obj_info_str		= sprintf('%s: %s',obj_info_str,dmin_str);
			end
		end
		% Display object information:
		if GV.no_selected_plotobjects==1
			% Exactly one object is selected:
			set(GV_H.text_waitbar,'String',sprintf('1 plot object selected: PlotNo = %s%s',plotno_str,obj_info_str));
			APP.Mod_Polygons_PlotNo1_EditField.Value			= imapobj_v;
			APP.Mod_Polygons_PlotNo2_EditField.Value			= 0;
			if MAP_OBJECTS(imapobj_v,1).iobj>0
				APP.Mod_AddPrevToOutput_ObjNo_EditField.Value	= MAP_OBJECTS(imapobj_v,1).iobj;
			end
		else
			% More than one objects are selected:
			set(GV_H.text_waitbar,'String',sprintf('%g plot objects selected: PlotNo = %s%s',...
				GV.no_selected_plotobjects,plotno_str,obj_info_str));
		end
	end
	
	% % % % Display number and PlotNo of selected map objects:
	% % % no_sel_plotobj_max	= 20;
	% % % plotno_str				= '';
	% % % for i=1:min(no_sel_plotobj_max,length(GV.selected_plotobjects))
	% % % 	if i==1
	% % % 		plotno_str		= sprintf('%g',GV.selected_plotobjects(i,1));
	% % % 	else
	% % % 		plotno_str		= sprintf('%s, %g',plotno_str,GV.selected_plotobjects(i,1));
	% % % 	end
	% % % end
	% % % if length(GV.selected_plotobjects)>no_sel_plotobj_max
	% % % 	plotno_str		= sprintf('%s ...',plotno_str);
	% % % end
	% % % if GV.no_selected_plotobjects==0
	% % % 	% No objects are selected:
	% % % 	set(GV_H.text_waitbar,'String','No plot objects selected.');
	% % % 	APP.Mod_Polygons_PlotNo1_EditField.Value			= 0;
	% % % 	APP.Mod_Polygons_PlotNo2_EditField.Value			= 0;
	% % % 	% APP.Mod_AddPrevToOutput_ObjNo_EditField.Value	= 0;		% Keep the last value
	% % % elseif GV.no_selected_plotobjects==1
	% % % 	% Exact one object is selected:
	% % % 	imapobj					= GV.selected_plotobjects;
	% % % 	obj_info_str		= '';
	% % % 	% Object information: object number:
	% % % 	if MAP_OBJECTS(imapobj,1).iobj>0
	% % % 		obj_info_str		= sprintf('ObjNo %1.0f',MAP_OBJECTS(imapobj,1).iobj);
	% % % 	end
	% % % 	% Object information: color number:
	% % % 	if MAP_OBJECTS(imapobj,1).iobj>=0
	% % % 		colno_v	= [];
	% % % 		d_side_v	= [];
	% % % 		if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'color_no')
	% % % 			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
	% % % 				colno			= MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no;
	% % % 				colno_v		= [colno_v;colno];
	% % % 				if colno>0
	% % % 					icolspec		= PP.color(colno).spec;
	% % % 					d_side		= PP.colorspec(icolspec).d_side;
	% % % 					d_side_v		= [d_side_v;d_side];
	% % % 				end
	% % % 			end
	% % % 		end
	% % % 		colno_v	= unique(colno_v);
	% % % 		d_side_v	= unique(d_side_v);
	% % % 		if (length(colno_v)>=1)&&(length(colno_v)<=2)
	% % % 			if isscalar(colno_v)
	% % % 				colno_str	= sprintf('ColNo: %g',colno_v);
	% % % 			else
	% % % 				colno_str	= sprintf('ColNo: %g, %g',colno_v(1),colno_v(2));
	% % % 			end
	% % % 			d_side		= max(d_side_v);
	% % % 			if isempty(d_side)
	% % % 				d_side_str	= '';
	% % % 			else
	% % % 				d_side_str	= sprintf(' (d_side=%gmm)',d_side);
	% % % 			end
	% % % 			if isempty(obj_info_str)
	% % % 				obj_info_str		= sprintf('%s%s',colno_str,d_side_str);
	% % % 			else
	% % % 				obj_info_str		= sprintf('%s  /  %s%s',obj_info_str,colno_str,d_side_str);
	% % % 			end
	% % % 		end
	% % % 	end
	% % % 	% Object information: description:
	% % % 	if ~isempty(MAP_OBJECTS(imapobj,1).dscr)
	% % % 		if isempty(obj_info_str)
	% % % 			obj_info_str		= sprintf('%s',MAP_OBJECTS(imapobj,1).dscr);
	% % % 		else
	% % % 			obj_info_str		= sprintf('%s  /  %s',obj_info_str,MAP_OBJECTS(imapobj,1).dscr);
	% % % 		end
	% % % 	end
	% % % 	% Object information: Text/Tag:
	% % % 	text_tag_str		= '';
	% % % 	for itext=1:size(MAP_OBJECTS(imapobj,1).text,1)
	% % % 		if itext==1
	% % % 			text_tag_str	= MAP_OBJECTS(imapobj,1).text{itext,1};
	% % % 		else
	% % % 			text_tag_str	= strcat(text_tag_str," ",MAP_OBJECTS(imapobj,1).text{itext,1});
	% % % 		end
	% % % 	end
	% % % 	if ~isempty(text_tag_str)
	% % % 		if isempty(obj_info_str)
	% % % 			obj_info_str		= sprintf('%s',text_tag_str);
	% % % 		else
	% % % 			obj_info_str		= sprintf('%s  /  %s',obj_info_str,text_tag_str);
	% % % 		end
	% % % 	end
	% % % 	% Object information: display as:
	% % % 	if ~isempty(MAP_OBJECTS(imapobj,1).disp)
	% % % 		if isempty(obj_info_str)
	% % % 			obj_info_str		= sprintf('%s',MAP_OBJECTS(imapobj,1).disp);
	% % % 		else
	% % % 			obj_info_str		= sprintf('%s  /  %s',obj_info_str,MAP_OBJECTS(imapobj,1).disp);
	% % % 		end
	% % % 	end
	% % % 	% Object information:
	% % % 	if ~isempty(obj_info_str)
	% % % 		obj_info_str			= sprintf(' (%s)',obj_info_str);
	% % % 	end
	% % % 	% Object information: number of regions:
	% % % 	no_regions					= 0;
	% % % 	for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
	% % % 		if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
	% % % 			poly_reg				= regions(MAP_OBJECTS(imapobj,1).h(i,1).Shape);
	% % % 			no_regions			= no_regions+size(poly_reg,1);
	% % % 		end
	% % % 	end
	% % % 	if no_regions==0
	% % % 		no_regions_str			= '';			% Line object
	% % % 	elseif no_regions==1
	% % % 		no_regions_str			= '1 region';
	% % % 	else
	% % % 		no_regions_str			= sprintf('%1.0f regions',no_regions);
	% % % 	end
	% % % 	if ~isempty(no_regions_str)
	% % % 		obj_info_str		= sprintf(': %s%s',no_regions_str,obj_info_str);
	% % % 	end
	% % % 	% Display object information:
	% % % 	set(GV_H.text_waitbar,'String',sprintf('1 plot object selected: PlotNo = %s%s',plotno_str,obj_info_str));
	% % % 	APP.Mod_Polygons_PlotNo1_EditField.Value			= imapobj;
	% % % 	APP.Mod_Polygons_PlotNo2_EditField.Value			= 0;
	% % % 	if MAP_OBJECTS(imapobj,1).iobj>0
	% % % 		APP.Mod_AddPrevToOutput_ObjNo_EditField.Value	= MAP_OBJECTS(imapobj,1).iobj;
	% % % 	end
	% % % else
	% % % 	% More than one objects are selected:
	% % % 	set(GV_H.text_waitbar,'String',sprintf('%g plot objects selected: PlotNo = %s',...
	% % % 		GV.no_selected_plotobjects,plotno_str));
	% % % end
	
catch ME
	errormessage('',ME);
end

