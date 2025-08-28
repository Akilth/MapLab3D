function create_map(iobj_v)
% This function opens the map figure and plots the objects defined in the project parameter file.
% Syntax:
% create_map;			Create the whole map, delete the existing map
% create_map(11);		Delete the existing map objects 11 and create the objects anew
%							(typically after changing the project parameters).

global APP PP OSMDATA GV GV_H OSMDATA_TABLE PLOTDATA WAITBAR MAP_OBJECTS PRINTDATA

try

	% Display state:
	t_start_statebusy	= clock;
	display_on_gui('state','Creating map ...','busy','add');

	% Testplot:
	testout	= 1;

	% Project parameters and the OSM-data must be loaded before:
	if isempty(PP)
		errortext	= sprintf([...
			'The project parameters have not yet been loaded.\n',...
			'First load the project parameters.']);
		errormessage(errortext);
	end
	if ~isfield(OSMDATA,'bounds')
		errortext	= sprintf([...
			'The OSM-data has not yet been loaded.\n',...
			'First load the OSM-data.']);
		errormessage(errortext);
	end

	% Open or clear map figure:
	if (nargin==0)||~ishandle(GV_H.ax_2dmap)
		create_map_figure;
	end

	% Clear existing map objects:
	if (nargin==1)&&~isempty(iobj_v)
		iobj_v			= unique(iobj_v);
		imapobj_del_v	= false(size(MAP_OBJECTS,1),1);
		for imapobj=1:size(MAP_OBJECTS,1)
			if any(iobj_v==MAP_OBJECTS(imapobj,1).iobj)
				% Delete source data:
				% The source plots are made visible, if the corresponding text or symbol is selected.
				% This makes it easier to move the texts and symbols to the right place when editing the map.
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if ishandle(MAP_OBJECTS(imapobj,1).h(i,1))
						if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'source')
							for ksource=1:size(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source,1)
								if ishandle(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source(ksource,1).h)
									delete(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source(ksource,1).h);
								end
							end
						end
					end
				end
				% Delete map objects:
				imapobj_del_v(imapobj,1)	= true;
				delete(MAP_OBJECTS(imapobj,1).h);
			end
		end
		MAP_OBJECTS(imapobj_del_v,:)	= [];
		display_map_objects;
	end

	% Vector of the object numbers to print:
	if nargin==0
		iobj_v	= (1:size(PP.obj,1))';
	else
		iobj_v	= iobj_v(:);
	end
	for i=1:size(iobj_v,1)
		iobj	= iobj_v(i);
		if ~isempty(PP.obj(iobj).display)
			% If this object number exists:
			if  ~(( PP.obj(iobj).display==1                                                           )||...
					((PP.obj(iobj).symbolpar.display==1)&&APP.CreatemapSettingsCreateSymbolsMenu.Checked)||...
					((PP.obj(iobj).textpar.display  ==1)&&APP.CreatemapSettingsCreateTextsMenu.Checked  )     )
				% Do not display the object and/or the texts:
				iobj_v(i,1)	= 0;
			end
		end
	end
	iobj_v(iobj_v==0,:)	= [];

	% Waitbar:
	% Calculation of the remaining time:
	% x = (t1-t0)/(tend-t0) ,  dt10 = t1-t0  ==>  tend = t0+dt10/x
	% tremaining = tend-t1 = t0+dt10/x-t1 = dt10/x-(t1-t0) = dt10/x-dt10 = dt10*(1-x)/x
	% Calibration of WAITBAR.dx: dx=WAITBAR.dt/sum(WAITBAR.dt)
	WAITBAR				= [];
	WAITBAR.dx(1,1)	= 0.68932;									% Length of each phase:	1) Get the plot data
	WAITBAR.dx(2,1)	= 0.00558;									%								2) Reduce the plot data
	WAITBAR.dx(3,1)	= 0.30507;									%								2) Plot the data into the map
	WAITBAR.dx			= WAITBAR.dx/sum(WAITBAR.dx);			%
	WAITBAR.x0			= cumsum(WAITBAR.dx)-WAITBAR.dx;		% Begin each phase at x0(i)
	WAITBAR.dt			= zeros(size(WAITBAR.dx));				% measured time of each phase, for calibration of WAITBAR.dx
	WAITBAR.i			= 0;											% Current phase index
	WAITBAR.k			= 0;											% number of loops
	WAITBAR.kmax		= 0;											% maximum number of loops
	WAITBAR.t0_phase	= clock;										% Start time of the current phase
	WAITBAR.t0			= clock;										% Start time
	WAITBAR.t1			= clock;										% Time of the last update
	WAITBAR.name		= 'Create map';							% Name of the waitbar
	% WAITBAR.formatOut	= 'yyyy-mm-dd HH:MM:SS';			% Format of the "estimated end time" (see datestr)
	WAITBAR.formatOut	= 'HH:MM:SS';								% Format of the "estimated end time" (see datestr)
	WAITBAR.inapp		= 1;											% waitbar: 1: show in the app, 0: show separatly
	WAITBAR.h			= -1;											% Handle of the waitbar

	% Delete legend (faster execution):
	legend(GV_H.ax_2dmap,'off');

	% Log file:
	if ~isempty(iobj_v)
		if nargin==0
			GV.log.create_map.pathfilename	= [GV.projectdirectory GV.pp_projectfilename ' - create map log.txt'];
		else
			GV.log.create_map.pathfilename	= [GV.projectdirectory GV.pp_projectfilename ' - create map log - ObjNo'];
			for i_iobj_v=1:size(iobj_v,1)
				iobj	= iobj_v(i_iobj_v);
				GV.log.create_map.pathfilename	= sprintf('%s %1.0f',GV.log.create_map.pathfilename,iobj);
			end
			GV.log.create_map.pathfilename		= sprintf('%s.txt',GV.log.create_map.pathfilename);
		end
		GV.log.create_map.text				= '';
	end

	% Collect the object numbers of areas, that are not closed:
	if nargin==0
		GV.areas_not_closed_iobj_v	= [];
	else
		GV.areas_not_closed_iobj_v	= -1;
	end


	%------------------------------------------------------------------------------------------------------------------
	% Phase i=1: Get the plot data of all objects defined in the project parameter file
	%------------------------------------------------------------------------------------------------------------------

	% Prepare the waitbar:
	WAITBAR.i			= 1;
	WAITBAR.k			= 0;
	WAITBAR.kmax		= size(iobj_v,1);
	WAITBAR.t0_phase	= clock;

	if ~isempty(iobj_v)
		for i_iobj_v=1:size(iobj_v,1)
			iobj	= iobj_v(i_iobj_v);

			% Waitbar:
			WAITBAR.k	= WAITBAR.k+1;
			x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
			msg			= sprintf('Get plot data of ObjNo %g (%s) ... ',iobj,PP.obj(iobj).description);
			set(GV_H.patch_waitbar,'XData',[0 x x 0]);
			set(GV_H.text_waitbar,'String',msg);
			drawnow;

			% Initializations:
			PLOTDATA.obj(iobj,1).connways				= [];
			PLOTDATA.obj(iobj,1).symb					= [];
			PLOTDATA.obj(iobj,1).text					= [];
			PLOTDATA.obj(iobj,1).ud_in_v				= [];
			PLOTDATA.obj(iobj,1).ud_iw_v				= [];
			PLOTDATA.obj(iobj,1).ud_ir_v				= [];
			PLOTDATA.obj(iobj,1).colno_fgd			= [];
			PLOTDATA.obj(iobj,1).colno_bgd			= [];
			PLOTDATA.obj(iobj,1).colno_symb_fgd		= [];
			PLOTDATA.obj(iobj,1).colno_symb_bgd		= [];
			PLOTDATA.obj(iobj,1).colno_text_fgd		= [];
			PLOTDATA.obj(iobj,1).colno_text_bgd		= [];

			% Set the selectable color numbers for creating cutting lines.
			PRINTDATA.obj_union_equalcolors	= [];	% When changing the map, the cutting into pieces must be repeated.
			set_previewtype_dropdown(1);

			% Find out whether the object number should be displayed as line/area or as symbol or as text:
			if ~isempty(PP.obj(iobj).display)
				% If this object number exists:
				if    ( PP.obj(iobj).display==1                                                           )||...
						((PP.obj(iobj).symbolpar.display==1)&&APP.CreatemapSettingsCreateSymbolsMenu.Checked)||...
						((PP.obj(iobj).textpar.display  ==1)&&APP.CreatemapSettingsCreateTextsMenu.Checked  )
					% Display the object and/or the texts/symbols:

					% Check whether PP.obj(iobj,1).tag_incl is empty:
					isempty_objtagincl	= true;
					for r=1:size(PP.obj(iobj,1).tag_incl,1)
						for c=1:size(PP.obj(iobj,1).tag_incl,2)
							if ~isempty(PP.obj(iobj,1).tag_incl(r,c).k)||~isempty(PP.obj(iobj,1).tag_incl(r,c).v)
								isempty_objtagincl	= false;
								break
							end
						end
						if ~isempty_objtagincl
							break
						end
					end

					% Filter by additional criteria like OSM-ID, length, area:
					% When creating the map in most cases the filters have to be deactivated,
					% otherwise e.g. small road sections are also eliminated!
					filter_incl_1			= struct('crit','','lolim','','uplim','');
					filter_excl_1			= struct('crit','','lolim','','uplim','');
					filter_incl_2			= PP.obj(iobj).filter_incl;
					filter_excl_2			= PP.obj(iobj).filter_excl;

					% Get the plot data based on PP.obj(iobj,1).tag_incl and PP.obj(iobj,1).tag_excl:
					if   (PP.obj(iobj).display==1)                       &&...
							~isempty_objtagincl
						get_liar		= true;
					else
						get_liar		= false;
					end
					if    (PP.obj(iobj).textpar.display==1)              &&...
							~isempty_objtagincl                            &&...
							APP.CreatemapSettingsCreateTextsMenu.Checked   &&...
							~isfield(PP.obj(iobj,1).textpar,'tag_incl')				% field exists only if not empty
						get_text		= true;
					else
						get_text		= false;
					end
					if    (PP.obj(iobj).symbolpar.display==1)            &&...
							~isempty_objtagincl                            &&...
							APP.CreatemapSettingsCreateSymbolsMenu.Checked &&...
							~isfield(PP.obj(iobj,1).symbolpar,'tag_incl')			% field exists only if not empty
						get_symb		= true;
					else
						get_symb		= false;
					end
					if get_liar||get_text||get_symb
						% Filter the OSM-data:
						filter_osmdata(...
							0,...											% update_osmdata_table
							PP.obj(iobj,1).tag_incl,...
							PP.obj(iobj,1).tag_excl,...
							filter_incl_1,filter_incl_2,...
							filter_excl_1,filter_excl_2,...
							msg);
						% Get the plot data:
						plotosmdata_getdata(iobj,msg,get_liar,get_text,get_symb);
					end

					% Get the plot data based on PP.obj(iobj,1).textpar.tag_incl and PP.obj(iobj,1).textpar.tag_excl:
					get_liar		= false;
					get_symb		= false;
					if    (PP.obj(iobj).textpar.display==1)              &&...
							APP.CreatemapSettingsCreateTextsMenu.Checked   &&...
							isfield(PP.obj(iobj,1).textpar,'tag_incl')				% field exists only if not empty
						get_text		= true;
					else
						get_text		= false;
					end
					if get_liar||get_text||get_symb
						% Filter the OSM-data:
						filter_osmdata(...
							0,...												% update_osmdata_table
							PP.obj(iobj,1).textpar.tag_incl,...		% The tag_incl and tag_excl fields can only exist both.
							PP.obj(iobj,1).textpar.tag_excl,...
							filter_incl_1,filter_incl_2,...
							filter_excl_1,filter_excl_2,...
							msg);
						% Get the plot data:
						plotosmdata_getdata(iobj,msg,get_liar,get_text,get_symb);
					end


					% Get the plot data based on PP.obj(iobj,1).symbolpar.tag_incl and PP.obj(iobj,1).symbolpar.tag_excl:
					get_liar		= false;
					get_text		= false;
					if    (PP.obj(iobj).symbolpar.display==1)            &&...
							APP.CreatemapSettingsCreateSymbolsMenu.Checked &&...
							isfield(PP.obj(iobj,1).symbolpar,'tag_incl')			% field exists only if not empty
						get_symb		= true;
					else
						get_symb		= false;
					end
					if get_liar||get_text||get_symb
						% Filter the OSM-data:
						filter_osmdata(...
							0,...													% update_osmdata_table
							PP.obj(iobj,1).symbolpar.tag_incl,...		% The tag_incl and tag_excl fields can only exist both.
							PP.obj(iobj,1).symbolpar.tag_excl,...
							filter_incl_1,filter_incl_2,...
							filter_excl_1,filter_excl_2,...
							msg);
						% Get the plot data:
						plotosmdata_getdata(iobj,msg,get_liar,get_text,get_symb);
					end

				end
			end
		end
	end

	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);

	%------------------------------------------------------------------------------------------------------------------
	% Phase i=2: Deletes lines in PLOTDATA, that are too short, and areas, that are too small
	%------------------------------------------------------------------------------------------------------------------

	% Prepare the waitbar:
	WAITBAR.i			= 2;
	WAITBAR.k			= 0;
	WAITBAR.kmax		= 1;
	WAITBAR.t0_phase	= clock;

	if ~isempty(iobj_v)

		% Waitbar:
		WAITBAR.k	= WAITBAR.k+1;
		x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
		msg			= sprintf('Reduce plot data ... ');
		set(GV_H.patch_waitbar,'XData',[0 x x 0]);
		set(GV_H.text_waitbar,'String',msg);
		drawnow;

		% Reduce plot data:
		plotosmdata_reducedata(msg);

	end

	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);

	%------------------------------------------------------------------------------------------------------------------
	% Phase i=3: Plot the data into the map
	%------------------------------------------------------------------------------------------------------------------

	% Prepare the waitbar:
	WAITBAR.i			= 3;
	WAITBAR.k			= 0;
	WAITBAR.kmax		= size(iobj_v,1);
	WAITBAR.t0_phase	= clock;

	% Plot the data:
	for i_iobj_v=1:size(iobj_v,1)
		iobj	= iobj_v(i_iobj_v);

		% Waitbar:
		WAITBAR.k	= WAITBAR.k+1;
		x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
		msg			= sprintf('Plot data of ObjNo %g (%s) ... ',iobj,PP.obj(iobj).description);
		set(GV_H.patch_waitbar,'XData',[0 x x 0]);
		set(GV_H.text_waitbar,'String',msg);
		drawnow;

		% Create polygons and plot the polygons into the map:
		if ~isempty(PP.obj(iobj).display)
			plotosmdata_plotdata(iobj,msg);
		end

		% Show every step:
		drawnow;

	end

	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);


	%------------------------------------------------------------------------------------------------------------------
	% Plot the legend into the map
	%------------------------------------------------------------------------------------------------------------------

	% Create legend map objects
	if APP.CreatemapSettingsRecreateWholeMapMenu.Checked||APP.CreatemapSettingsRecreateLegendMenu.Checked

		% Waitbar:
		set(GV_H.text_waitbar,'String','Create legend ...');
		drawnow;

		% Create legend:
		create_legend_map;

	end


	%------------------------------------------------------------------------------------------------------------------
	% Last steps
	%------------------------------------------------------------------------------------------------------------------

	% Update MAP_OBJECTS_TABLE:
	display_map_objects;

	% Set the axis limits, with zoom fit:
	SizeChangedFcn_fig_2dmap([],[],1,1);

	% Update MAP_OBJECTS_TABLE and arrange map objects:
	arrange_map_objects;				% includes also display_map_objects

	% Clear OSMDATA_TABLE:
	if size(OSMDATA_TABLE,1)==0
		filter_osmdata(0);
	else
		filter_osmdata(1);
	end

	% Create/modify legend of the figure:
	create_legend_mapfigure;

	% The map has been changed:
	GV.map_is_saved	= 0;

	% Execution time:
	t_end_statebusy					= clock;
	dt_statebusy						= etime(t_end_statebusy,t_start_statebusy);
	dt_statebusy_str					= dt_string(dt_statebusy);
	if    APP.CreatemapSettingsRecreateWholeMapMenu.Checked&&...
			APP.CreatemapSettingsCreateSymbolsMenu.Checked&&...
			APP.CreatemapSettingsCreateTextsMenu.Checked
		if dt_statebusy>GV.exec_time.create_map.dt
			GV.exec_time.create_map.name		= APP.CreatemapMenu.Text;
			GV.exec_time.create_map.t_start	= t_start_statebusy;
			GV.exec_time.create_map.t_end		= t_end_statebusy;
			GV.exec_time.create_map.dt			= dt_statebusy;
			GV.exec_time.create_map.dt_str	= dt_statebusy_str;
		end
	end
	GV.log.create_map.text	= sprintf('%s%s\n',GV.log.create_map.text,GV.log.create_map.line_str);
	GV.log.create_map.text	= sprintf('%sExecution time (h:m:s): %s\n',GV.log.create_map.text,dt_statebusy_str);

	% Save "Create map" log:
	if ~isempty(iobj_v)
		fileID			= fopen(GV.log.create_map.pathfilename,'w');
		fprintf(fileID,'%s',GV.log.create_map.text);
		fclose(fileID);
		% Testplot:
		if testout~=0
			fprintf(1,GV.log.create_map.text);
		end
	end

	% Autosave:
	if    APP.CreatemapSettingsRecreateWholeMapMenu.Checked&&...
			APP.CreatemapSettingsCreateTextsMenu.Checked     &&...
			APP.CreatemapSettingsCreateSymbolsMenu.Checked
		% Save only, if the complete map is created:
		filename_add			= ' - after create map';
		[map_filename,~,~]	= filenames_savefiles(filename_add);
		set(GV_H.text_waitbar,'String',sprintf('Autosave "%s"',map_filename));
		save_project(0,filename_add);
	end

	% Show warning, if there are areas that are not closed:
	if nargin==0
		GV.areas_not_closed_iobj_v		= unique(GV.areas_not_closed_iobj_v);
		if ~isempty(GV.areas_not_closed_iobj_v)
			area_not_closed_str		= '';
			for i_iobj=1:size(GV.areas_not_closed_iobj_v,1)
				iobj						= GV.areas_not_closed_iobj_v(i_iobj,1);
				area_not_closed_str	= sprintf('%s   ObjNo=%g  (%s)\n',...
					area_not_closed_str,...
					iobj,...
					PP.obj(iobj,1).description);
			end
			warntext1		= sprintf([...
				'%s:\n\n',...
				'The following object numbers should be displayed as areas,\n',...
				'but the OSM source data partly consists of open lines:\n',...
				'\n%s\n',...
				'The reason is incomplete OSM source data, for example from areas\n',...
				'on the edge of the map. These incomplete areas are displayed as\n',...
				'preview lines (area - not closed) in the map.'],APP.CreatemapMenu.Text,area_not_closed_str);
			warntext2		= sprintf([...
				'Remedy:\n',...
				'1) Read in a larger OSM map area (may take longer).\n',...
				'2) Create the OSM file using the Extra - Call Osmosis function:\n',...
				'   The Osmosis call contains the command "completeWays=yes", which\n',...
				'   should result in fewer cases of open areas.\n',...
				'3) Close the remaining open areas manually and convert them into a map object:\n',...
				'   - Connect the lines outside the map area so that the area is displayed correctly\n',...
				'     (tab Edit map - Preview: Move vertex, Connect, Close, ...).\n',...
				'   - Enter the map object number (e.g. by clicking on the preview line).\n',...
				'   - Activate the "Merge" checkbox\n',...
				'   - Select all edited preview lines or polygons.\n',...
				'     (first object: left click, next objects: middle mouse button)\n',...
				'   - Run "Polygon to map object":\n',...
				'     Because the "Merge" checkbox is activated, ALL objects with the selected\n',...
				'     object number are recreated!\n',...
				'     It is therefore essential that the open lines are closed BEFORE further\n',...
				'     editing of the map.\n',...
				'   - It is recommended to save the project regularly.\n',...
				'\n',...
				'Note:\n',...
				'The preview lines that have already been edited (area - not closed) are still\n',...
				'present on the map after executing "Polygon to map object" because they are still\n',...
				'present in the OSM source data. These can then simply be hidden or deleted.\n',...
				'\n',...
				'Further explanations on the execution of "Polygon to map object":\n',...
				'1) "Merge" is activated\n',...
				'   - All map objects with the entered object number are recreated,\n',...
				'     including the texts and symbols:\n',...
				'     With relations, interior areas become holes.\n',...
				'     The project parameters obj(ObjNo).reduce_areas are applied again on the existing\n',...
				'     map data and also on the selected preview lines and polygons.\n',...
				'   - "Merge" should only be activated at the beginning of editing the map, otherwise\n',...
				'     all objects previously added without activating "Merge" will be lost.\n',...
				'   - Texts and symbols are also created anew, but not taking the changes into account:\n',...
				'     For manually closed areas, the texts and symbols must therefore be repositioned.\n',...
				'   - The objects added with "Merge" are retained if the function is executed again\n',...
				'     with "Merge".\n',...
				'   - The execution time with "Merge" is longer.\n',...
				'2) "Merge" is not activated:\n',...
				'   - The existing map objects with the entered object number are not changed.\n',...
				'   - The execution time without "Merge" is shorter.\n']);
			% warntext		= sprintf('%s\nSuggested solutions see log file.',warntext1);
			warntext		= warntext1;
			logtext		= sprintf('\n%s\n\n%s\n',warntext1,warntext2);
			if isfield(GV_H.warndlg,'create_map')
				if ishandle(GV_H.warndlg.create_map)
					close(GV_H.warndlg.create_map);
				end
			end
			GV_H.warndlg.create_map			= warndlg(warntext,'Warning');
			GV_H.warndlg.create_map.Tag	= 'maplab3d_figure';
			fprintf(1,'%s',logtext);
		end
	end

	% Reset waitbar:
	set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
	set(GV_H.text_waitbar,'String','');
	drawnow;

	% Display state:
	display_on_gui('state',...
		sprintf('Creating map ... done (%s).',dt_statebusy_str),...
		'notbusy','replace');

catch ME
	errormessage('',ME);
end

