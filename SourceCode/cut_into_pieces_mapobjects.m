function cut_into_pieces_mapobjects
% Executed with "Menu: File - Map editing - Cut into pieces"
% Final cutting of map objects by using previously defined "cutting lines".

global GV GV_H MAP_OBJECTS

try

	% if isempty(PP)
	% 	errortext	= sprintf([...
	% 		'The project parameters have not yet been loaded.\n',...
	% 		'First load the project parameters.']);
	% 	errormessage(errortext);
	% end
	if isempty(MAP_OBJECTS)
		errortext	= sprintf([...
			'The map has not yet been created.\n',...
			'First create the map.']);
		errormessage(errortext);
	end

	% Display state:
	t_start_statebusy	= clock;
	display_on_gui_str	= 'Cut into pieces ...';
	display_on_gui('state',display_on_gui_str,'busy','add');

	% Waitbar:
	waitbar_t1			= clock;

	% Set the value of the cutting lines dropdown menu to 'None' (make the map objects visible):
	set_previewtype_dropdown(1);

	% User confirmation:
	question	= sprintf([...
		'This function uses the previously defined cutting lines.\n',...
		'The map objets of all colors will be cut into pieces.\n',...
		'\n',...
		'Use this function to cut through the objects exactly\n',...
		'where you want them to be cut.\n',...
		'If you don''t use this function, the map objects will\n',...
		'be cut automatically when you create the map STL files.\n',...
		'When you create the map STL files the remaining objects\n',...
		'that are still too large are also cut into pieces.\n',...
		'\n',...
		'All changes should be made before this step.']);
	answer	= questdlg_local(question,'Cut map objects into pieces?','Continue','Cancel','Cancel');
	if isempty(answer)||strcmp(answer,'Cancel')
		display_on_gui('state',...
			sprintf('%s Canceled (%s).',display_on_gui_str,dt_string(etime(clock,t_start_statebusy))),...
			'notbusy','replace');
		return
	end

	% Preparation: indices imapobj with cutting lines, sorted by color:
	mapobjects_cncl_v		= [MAP_OBJECTS.cncl]';
	cncl_max					= max(mapobjects_cncl_v);
	imapobj_cncl_cell		= cell(0,1);
	for cncl=1:cncl_max
		imapobj_cncl_cell{cncl,1}		= find(mapobjects_cncl_v==cncl);
		k_delete							= [];
		for k=1:length(imapobj_cncl_cell{cncl,1})
			for i=1:size(MAP_OBJECTS(imapobj_cncl_cell{cncl,1}(k),1).h,1)
				if ~strcmp(MAP_OBJECTS(imapobj_cncl_cell{cncl,1}(k),1).h(i,1).Type,'polygon')
					k_delete		= [k_delete;k];
				end
			end
		end
		k_delete		= unique(k_delete);
		imapobj_cncl_cell{cncl,1}(k_delete)	= [];
	end

	if isempty(imapobj_cncl_cell)
		% No cutting lines: nothing to do
		% Display state:
		t_end_statebusy					= clock;
		dt_statebusy						= etime(t_end_statebusy,t_start_statebusy);
		dt_statebusy_str					= dt_string(dt_statebusy);
		display_on_gui('state',...
			sprintf('%s nothing to do (%s).',display_on_gui_str,dt_statebusy_str),...
			'notbusy','replace');
		return
	else

		% Autosave:
		filename_add			= ' - before cut into pieces';
		[map_filename,~,~]	= filenames_savefiles(filename_add);
		set(GV_H.text_waitbar,'String',sprintf('Autosave "%s"',map_filename));
		save_project(0,filename_add);

		% Cutting in pieces:
		for imapobj=1:size(MAP_OBJECTS,1)
			% Waitbar:
			if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
				waitbar_t1	= clock;
				progress		= min((k-1)/length(size(MAP_OBJECTS,1)),1);
				set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
				set(GV_H.text_waitbar,'String',sprintf('Cut into pieces PlotNo %g',imapobj));
				drawnow;
			end

			if (MAP_OBJECTS(imapobj,1).cncl==0)&&(MAP_OBJECTS(imapobj,1).cnuc==0)
				% Detect the background color:
				% The foreground is cut with the same cutting lines as the background.
				colno_bgd		= [];
				cut_lines		= true;
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
						% The map object is a polygon (only polygons will be considered for printing):
						if MAP_OBJECTS(imapobj,1).h(i,1).Visible
							% The map object is visible:
							if    isequal(MAP_OBJECTS(imapobj,1).h(i,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
									isequal(MAP_OBJECTS(imapobj,1).h(i,1).FaceAlpha,GV.visibility.show.facealpha)
								% The map object is not grayed out:
								if    isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'color_no')&&...
										isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'dz'      )&&...
										isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'level'   )&&...
										isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'prio'    )
									% The map object has the necessary userdata to be printed:
									colno		= MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no;
									if colno~=0
										% The map object has its own color:
										if (colno<=size(imapobj_cncl_cell,1))&&(MAP_OBJECTS(imapobj).h(i).UserData.level==0)
											% There exist cutting lines and
											% level=0: background:
											colno_bgd	= [colno_bgd;colno];
										end
										% 									imapobj_cncl_v			= imapobj_cncl_cell{colno,1};
										% 									for k=1:length(imapobj_cncl_v)
										% 										imapobj_cncl		= imapobj_cncl_v(k);
										% 										for i_cncl=1:size(MAP_OBJECTS(imapobj_cncl,1).h,1)
										% 											% Cut the map object:
										% 											MAP_OBJECTS(imapobj,1).h(i,1).Shape	= subtract(...
										% 												MAP_OBJECTS(imapobj,1).h(i,1).Shape,...					% map objects
										% 												MAP_OBJECTS(imapobj_cncl,1).h(i_cncl,1).Shape,...		% cutting lines
										% 												'KeepCollinearPoints',false);
										% 											[xcenter,ycenter]				= centroid(MAP_OBJECTS(imapobj,1).h(i,1).Shape);
										% 											MAP_OBJECTS(imapobj,1).x	= xcenter;
										% 											MAP_OBJECTS(imapobj,1).y	= ycenter;
										% 											MAP_OBJECTS(imapobj,1).mod	= true;
										% 										end
										% 									end
									else
										% The map object has not its own color:
										cut_lines		= false;
									end
								else
									% The map object has not the necessary userdata to be printed:
									cut_lines		= false;
								end
							else
								% The map object is grayed out:
								cut_lines		= false;
							end
						else
							% The map object is not visible:
							cut_lines		= false;
						end
					else
						% The map object is not a polygon (only polygons will be considered for printing):
						cut_lines		= false;
					end
				end
				colno_bgd		= unique(colno_bgd);

				% Cut the objects:
				if cut_lines&&(length(colno_bgd)==1)
					% The map object meets all the necessary conditions:
					imapobj_cncl_v			= imapobj_cncl_cell{colno_bgd,1};
					for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
						for k=1:length(imapobj_cncl_v)
							imapobj_cncl		= imapobj_cncl_v(k);
							for i_cncl=1:size(MAP_OBJECTS(imapobj_cncl,1).h,1)
								% Cut the map object:
								MAP_OBJECTS(imapobj,1).h(i,1).Shape	= subtract(...
									MAP_OBJECTS(imapobj,1).h(i,1).Shape,...					% map objects
									MAP_OBJECTS(imapobj_cncl,1).h(i_cncl,1).Shape,...		% cutting lines
									'KeepCollinearPoints',false);
							end
						end
					end
				end

			end
		end

		% Create united equal colors plot objects:
		drawnow;
		create_unitedcolors(...
			0,...				% userconfirmation
			1,...				% calc_uec
			0,...				% reset_uec
			0);				% createplot_colno

		% Autosave:
		filename_add			= ' - after cut into pieces';
		[map_filename,~,~]	= filenames_savefiles(filename_add);
		set(GV_H.text_waitbar,'String',sprintf('Autosave "%s"',map_filename));
		save_project(0,filename_add);

	end

	% Reset waitbar:
	set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
	set(GV_H.text_waitbar,'String','');
	drawnow;

	% Display state:
	t_end_statebusy					= clock;
	dt_statebusy						= etime(t_end_statebusy,t_start_statebusy);
	dt_statebusy_str					= dt_string(dt_statebusy);
	display_on_gui('state',...
		sprintf('%s done (%s).',display_on_gui_str,dt_statebusy_str),...
		'notbusy','replace');

catch ME
	errormessage('',ME);
end

