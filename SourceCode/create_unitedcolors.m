function create_unitedcolors(userconfirmation,calc_uec,reset_uec,createplot_colno)
% Creates polygon objects for every color number as printed and saves them in
% PRINTDATA.obj_union_equalcolors(colno,1)
% This can be executed before and after "Simplify map".
%
% userconfirmation			user confirmation (0/1)
% calc_uec						calculate PRINTDATA.obj_union_equalcolors (0/1)
% reset_uec						reset PRINTDATA.obj_union_equalcolors (0/1)
% createplot_colno			color number:
%									-	of the element PRINTDATA.obj_union_equalcolors(colno,1) to reset
%									-	of the plot objects to create or update
%									0:	reset all and plot all

global PP ELE GV GV_H PRINTDATA MAP_OBJECTS

try
	
	if isempty(MAP_OBJECTS)
		return
	end
	
	% Initializations:
	if nargin==0
		userconfirmation			= 0;
		reset_uec					= 0;
	end
	if ~isfield(PRINTDATA,'obj_union_equalcolors')
		if reset_uec~=0
			return
		end
	else
		if isempty(PRINTDATA.obj_union_equalcolors)&&(reset_uec~=0)
			return
		end
	end
	if ~isfield(PRINTDATA,'obj_union_equalcolors_0')
		if reset_uec~=0
			return
		end
	else
		if isempty(PRINTDATA.obj_union_equalcolors_0)&&(reset_uec~=0)
			return
		end
	end
	
	% Display state:
	stateisbusy	= display_on_gui('state','','isbusy');
	if ~stateisbusy
		t_start_statebusy	= clock;
		set(GV_H.text_waitbar,'String','');
		display_on_gui('state','Create united colors ...','busy','add');
	end
	
	% User confirmation:
	if userconfirmation~=0
		question	= sprintf(['Create united equal colors:\n',...
			'This combines all overlapping equal colors of visible pieces\n',...
			'into a single area, just like when creating the STL files.\n',...
			'\n',...
			'This may take some time!\n',...
			'\n',...
			'Do this before simplifying the map, for example:\n',...
			'1) to detect objects that are too small or too large\n',...
			'2) to detect holes or fragile pieces\n',...
			'3) to recognize whether objects need to be connected\n',...
			'4) to set preview cutting lines\n',...
			'\n',...
			'The creation of united equal colors will be executed again\n',...
			'automatically after simplifying the map, the result may\n',...
			'differ slightly.\n',...
			'The final setting of the preview cutting lines and\n',...
			'cutting lines and the cutting of the map objects\n',...
			'should be done after the simplification.']);
		answer	= questdlg_local(question,'Create united equal colors?','Continue','Cancel','Cancel');
		if isempty(answer)||strcmp(answer,'Cancel')
			if ~stateisbusy
				display_on_gui('state',...
					sprintf('Create united colors ... canceled (%s).',...
					dt_string(etime(clock,t_start_statebusy))),'notbusy','replace');
			end
			drawnow;
			return
		end
	end
	
	if calc_uec~=0
		% Calculation of:
		% - PRINTDATA.obj_union_equalcolors
		% - PRINTDATA.obj_union_equalcolors_0
		% - execution of set_previewtype_dropdown(1)
		msg_add							= 'Simplify map: merge equal colors';
		testplot_xylimits				= [];
		% testplot_xylimits(1,1)		= -70;			% xmin
		% testplot_xylimits(2,1)		= -54;			% xmax
		% testplot_xylimits(3,1)		= 62;				% ymin
		% testplot_xylimits(4,1)		= 74;				% ymax
		try
			
			% Calculation of PRINTDATA.obj_union_equalcolors:
			[  ~,...									% obj
				~,...									% obj_top_reg
				~,...									% obj_reg
				~,...									% poly_tile
				~,...									% tile_no_all_v
				~,...									% PP_local
				ELE,...								% ELE_local			--> zurückgeben: in ELE wurden evtl. Polygone hinzugefügt.
				~...									% poly_legbgd
				] = map2stl_preparation(...
				[],...								% map_tile_no
				GV_H.fig_2dmap,...				% hf_map
				PP,...								% PP_local
				ELE,...								% ELE_local
				msg_add,...							% msg_add
				0,...									% testout
				0,...									% testout_dzbot
				0,...									% testplot_obj_all
				0,...									% testplot_obj_all_top
				0,...									% testplot_obj
				0,...									% testplot_obj_top
				0,...									% testplot_obj_reg
				0,...									% testplot_obj_reg_1plot
				0,...									% testplot_obj_cut
				0,...									% testplot_poly_cut
				testplot_xylimits);				% testplot_xylimits
			
			% Color numbers:
			if isempty(PRINTDATA.obj_union_equalcolors)
				errormessage;
			end
			if createplot_colno==0
				colno_v	= (1:size(PRINTDATA.obj_union_equalcolors,1))';
			else
				colno_v	= createplot_colno;
			end
			
			% Modification of PRINTDATA.obj_union_equalcolors:
			% Get the legend background:
			[poly_legbgd,~,~]		= get_poly_legbgd;
			% Do not consider legend objects:
			if numboundaries(poly_legbgd)>0
				for k=1:size(colno_v,1)
					if numboundaries(PRINTDATA.obj_union_equalcolors(colno_v(k),1))>0
						PRINTDATA.obj_union_equalcolors(colno_v(k),1)	= subtract(...
							PRINTDATA.obj_union_equalcolors(colno_v(k),1),...
							poly_legbgd,...
							'KeepCollinearPoints',false);
					end
				end
			end
			
			% Execution of set_previewtype_dropdown(1): Set the selectable color numbers for creating cutting lines.
			% After modification of PRINTDATA.obj_union_equalcolors, otherwise the legend would be also selectable!
			set_previewtype_dropdown(1);
			
			% PRINTDATA.obj_union_equalcolors_0:
			% Possibility to reset_uec all changes to PRINTDATA.obj_union_equalcolors:
			PRINTDATA.obj_union_equalcolors_0	= PRINTDATA.obj_union_equalcolors;
			
		catch ME
			% The global variables defined in the function must also be defined globally outside:
			% required: global GV GV_H WAITBAR PRINTDATA
			global WAITBAR
			errormessage('',ME);
		end
	end
	
	% Color numbers to reset or update:
	if isempty(PRINTDATA.obj_union_equalcolors_0)
		errormessage;
	end
	if createplot_colno==0
		colno_v	= (1:size(PRINTDATA.obj_union_equalcolors_0,1))';
	else
		colno_v	= createplot_colno;
	end
	
	if reset_uec~=0
		% Reset all changes to PRINTDATA.obj_union_equalcolors:
		for k=1:size(colno_v,1)
			PRINTDATA.obj_union_equalcolors(colno_v(k),1)	= PRINTDATA.obj_union_equalcolors_0(colno_v(k),1);
		end
	end
	
	% Delete legend:
	legend(GV_H.ax_2dmap,'off');
	
	% Print the united equal colors to the map for setting the cuttings lines manually,
	% replace it if the plot already exists:
	colno_cuttingline		= get_colno_cuttingline;
	imapobj_delete_v		= [];
	size_map_objects_0	= size(MAP_OBJECTS,1);
	for k=1:size(colno_v,1)
		% Delete an existing plot (MAP_OBJECTS_TABLE will be updated also):
		imapobj				= find([MAP_OBJECTS.cnuc]==colno_v(k));
		imapobj_delete_v	= [imapobj_delete_v;imapobj];
		if numboundaries(PRINTDATA.obj_union_equalcolors(colno_v(k),1))>0
			% New entry:
			imapobj			= size(MAP_OBJECTS,1)+1;
			% Extend the userdata:
			ud				= [];
			ud.in			= [];
			ud.iw			= [];
			ud.ir			= [];
			ud.color_no	= colno_v(k);
			ud.rotation	= 0;
			ud.shape0	= PRINTDATA.obj_union_equalcolors(colno_v(k),1);
			ud.level		= 0;
			% Plot the polygon:
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
			end
			if colno_cuttingline==0
				visibility		= 'off';
			else
				visibility		= 'on';
			end
			h_poly		= plot(GV_H.ax_2dmap,PRINTDATA.obj_union_equalcolors(colno_v(k),1),...
				'EdgeColor'    ,'k',...
				'FaceColor'    ,PP.color(colno_v(k)).rgb/255,...
				'EdgeAlpha'    ,GV.visibility.show.edgealpha,...
				'FaceAlpha'    ,GV.visibility.show.facealpha,...
				'Visible'		,visibility,...
				'UserData'     ,ud,...
				'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
			% Save relevant data in the structure MAP_OBJECTS:
			[xcenter,ycenter]						= centroid(PRINTDATA.obj_union_equalcolors(colno_v(k),1));
			MAP_OBJECTS(imapobj,1).disp		= 'united equal colors';
			MAP_OBJECTS(imapobj,1).h			= h_poly;
			MAP_OBJECTS(imapobj,1).iobj		= min([[MAP_OBJECTS.iobj] 0])-1;
			MAP_OBJECTS(imapobj,1).dscr		= sprintf('Color %1.0f as printed, for setting the cutting lines',colno_v(k));
			MAP_OBJECTS(imapobj,1).x			= xcenter;
			MAP_OBJECTS(imapobj,1).y			= ycenter;
			MAP_OBJECTS(imapobj,1).text		= {sprintf('(%s)',PP.color(colno_v(k),1).description)};
			MAP_OBJECTS(imapobj,1).mod			= false;
			MAP_OBJECTS(imapobj,1).cncl		= 0;
			MAP_OBJECTS(imapobj,1).cnuc		= colno_v(k);
			MAP_OBJECTS(imapobj,1).vis0		= 0;
		end
	end
	
	% Create/modify legend:
	create_legend_mapfigure;			% Do not delete, is used by other actions!
	
	% Number of new map objects:
	no_new_map_objects	= size(MAP_OBJECTS,1)-size_map_objects_0;
	
	% Delete old objects:
	imapobj_delete_v		= unique(imapobj_delete_v);
	if ~isempty(imapobj_delete_v)
		% Delete objects (MAP_OBJECTS_TABLE will be updated also):
		plot_modify('delete',imapobj_delete_v);		% Includes also display_map_objects
	end
	
	% Arrange all existing united equal colors:
	cnuc_v				= [MAP_OBJECTS.cnuc]';
	imapobj_v			= (1:size(MAP_OBJECTS,1))';
	i_no_uc_v			= (cnuc_v==0);
	cnuc_v(i_no_uc_v)	= 10^(ceil(log10(max(cnuc_v)))+1)+imapobj_v(i_no_uc_v);
	[~,imapobj_new_v]	= sort(cnuc_v);
	arrange_map_objects(imapobj_new_v,[]);				% Change the position of all map objects
	
	% Display state:
	if ~stateisbusy
		t_end_statebusy					= clock;
		dt_statebusy						= etime(t_end_statebusy,t_start_statebusy);
		dt_statebusy_str					= dt_string(dt_statebusy);
		set(GV_H.text_waitbar,'String','');
		display_on_gui('state',...
			sprintf('Create united colors ... done (%s).',dt_statebusy_str),...
			'notbusy','replace');
	end
	
catch ME
	errormessage('',ME);
end

