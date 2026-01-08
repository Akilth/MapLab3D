function display_on_gui_selectedmapobjects
% Display number and PlotNo of selected map objects:

global GV GV_H APP MAP_OBJECTS

try
	
	if isempty(MAP_OBJECTS)
		return
	end
	
	% Set GV.selected_plotobjects and GV.no_selected_plotobjects:
	GV.selected_plotobjects	= false(size(MAP_OBJECTS,1),1);
	for imapobj=1:size(MAP_OBJECTS,1)
		if isvalid(MAP_OBJECTS(imapobj,1).h)
			if MAP_OBJECTS(imapobj,1).h(1,1).Selected
				GV.selected_plotobjects(imapobj,1)	= true;
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
		set(GV_H.text_waitbar,'String',sprintf('1 plot object selected: PlotNo = %s',plotno_str));
		APP.Mod_Polygons_PlotNo2_EditField.Value			= 0;
		imapobj														= GV.selected_plotobjects;
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

