function save_project(get_userinput,filename_add)
% Adds the variables PP and ELE to the userdata of the map figure and saves the figure.
% Syntax:	1)	save_project(0) or
%					save_project					save project, use the existing project name
%				2)	save_project(0,' - text')	save project, add ' - text' to the existing project name
%				3)	save_project(1)				save project, ask for the project name

global APP PP ELE GV GV_H MAP_OBJECTS OSMDATA VER PLOTDATA PRINTDATA

try

	if ~isfield(GV,'pp_projectfilename')
		return
	end
	if isempty(GV.pp_projectfilename)
		return
	end

	% Display state:
	t_start_statebusy	= clock;
	stateisbusy	= display_on_gui('state','','isbusy');
	if ~stateisbusy
		display_on_gui('state','Saving project ...','busy','add');
	end

	% Ask for the project name:
	if nargin<1
		get_userinput	= 0;
	end
	if nargin<2
		filename_add	= '';
	end
	if get_userinput~=0
		prompt		= {'Enter the project name:'};
		dlgtitle		= 'Enter project name';
		dims			= 1;
		definput		= {GV.pp_projectfilename};
		answer		= inputdlg_local(prompt,dlgtitle,dims,definput);
		if ~isempty(answer)
			GV.pp_projectfilename	= validfilename(answer{1});
		else
			% Display state:
			display_on_gui('state',...
				sprintf('Saving project ... Canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			return
		end
		[GV.map_filename,GV.mapdata_filename,~]	= filenames_savefiles('');
		% Show path and filenames:
		display_on_gui('pathfilenames');
	end

	% If the the map figure does not exist: open or clear map figure:
	fig_2dmap_exists	= true;
	if ~isfield(GV_H,'fig_2dmap')
		fig_2dmap_exists	= false;
	else
		if ~isfield(GV_H,'ax_2dmap')
			fig_2dmap_exists	= false;
		else
			if isempty(GV_H.fig_2dmap)||isempty(GV_H.ax_2dmap)
				fig_2dmap_exists	= false;
			else
				if ~ishandle(GV_H.fig_2dmap)||~ishandle(GV_H.ax_2dmap)
					fig_2dmap_exists	= false;
				end
			end
		end
	end
	if ~fig_2dmap_exists
		create_map_figure;
	end

	% Save the current date and time:
	savetime_map			= clock;

	% Ad ud.imapobj and ud.issource to the userdata of the plot objects:
	% The source plots are made visible, if the corresponding map object is selected.
	% This makes it easier to move the texts and symbols to the right place when editing the map.
	for imapobj=1:size(MAP_OBJECTS,1)
		for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
			% MAP_OBJECTS(imapobj,1).h(i,1): visible plot objects
			% E.g.: MAP_OBJECTS(imapobj,1).h(i,1).UserData = struct with fields:
			%       color_no: 4
			%             dz: 1.8
			%           prio: 9001
			%             in: []
			%             iw: 2308
			%             ir: []
			%           iobj: 4
			%          level: 1
			%         shape0: [1×1 polyshape]
			%         source: [1×1 struct]
			MAP_OBJECTS(imapobj,1).h(i,1).UserData.imapobj	= imapobj;
			MAP_OBJECTS(imapobj,1).h(i,1).UserData.issource	= false;
			% MAP_OBJECTS(imapobj,1).h(i,1).UserData.source(k,1).h: invisible source data of texts, symbols or
			%                                                       lines with linestyle==3
			% E.g.: MAP_OBJECTS(imapobj,1).h(i,1).UserData.source(k,1).h.UserData = struct with fields:
			%       issource: 1 (true)
			%        imapobj: 0
			if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'source')
				for k=1:size(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source,1)
					if isvalid(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source(k,1).h)
						MAP_OBJECTS(imapobj,1).h(i,1).UserData.source(k,1).h.UserData.imapobj	= imapobj;
					end
				end
			end
		end
	end

	% Deselect all map objects:
	if ~isempty(MAP_OBJECTS)
		plot_modify('deselect',-1,0);
	end

	% Rename old versions:
	if isempty(filename_add)
		for i=PP.general.save_n_backups:-1:0
			if i>0
				[map_filename_src,mapdata_filename_src,~]	= filenames_savefiles(sprintf(' - %02.0f',i  ));
			else
				[map_filename_src,mapdata_filename_src,~]	= filenames_savefiles('');
			end
			[map_filename_dst,mapdata_filename_dst,~]	= filenames_savefiles(sprintf(' - %02.0f',i+1));
			pathfilename_map_src			= [GV.projectdirectory map_filename_src];
			pathfilename_map_dst			= [GV.projectdirectory map_filename_dst];
			pathfilename_mapdata_src	= [GV.projectdirectory mapdata_filename_src];
			pathfilename_mapdata_dst	= [GV.projectdirectory mapdata_filename_dst];
			if (exist(pathfilename_map_src,'file')==2)&&(exist(pathfilename_mapdata_src,'file')==2)
				% The source files exist:
				if i==PP.general.save_n_backups
					% Delete the oldest backup:
					delete(pathfilename_map_src);
					delete(pathfilename_mapdata_src);
				else
					[status,msg] = movefile(pathfilename_map_src,pathfilename_map_dst);
					if status~=1
						errortext	= sprintf([...
							'Error when renaming backup file:\n',...
							'%s\n',...
							'to\n',...
							'%s\n',...
							'\n',...
							'%s'],pathfilename_map_src,pathfilename_map_dst,msg);
						errormessage(errortext);
					end
					[status,msg] = movefile(pathfilename_mapdata_src,pathfilename_mapdata_dst);
					if status~=1
						errortext	= sprintf([...
							'Error when renaming backup file:\n',...
							'%s\n',...
							'to\n',...
							'%s\n',...
							'\n',...
							'%s'],pathfilename_mapdata_src,pathfilename_mapdata_dst,msg);
						errormessage(errortext);
					end
				end
			end
		end
	end

	% Filenames:
	[map_filename,mapdata_filename,~]	= filenames_savefiles(filename_add);

	% Save the map:
	set(GV_H.fig_2dmap,'UserData',struct(...
		'PP',PP,...			% necessary for map2stl.m
		'ELE',ELE,...		% necessary for map2stl.m
		'ver_map',VER,...
		'savetime_map',savetime_map));
	savefig(GV_H.fig_2dmap,[GV.projectdirectory map_filename]);

	% Save the map data:
	GV_savedata				= GV;
	ver_mapdata				= VER;					% Save the version number
	savetime_mapdata		= savetime_map;		% Save the current date and time
	save([GV.projectdirectory mapdata_filename],...
		'OSMDATA','MAP_OBJECTS','GV_savedata','PLOTDATA','PRINTDATA','ver_mapdata','savetime_mapdata');

	% The map has been saved:
	GV.map_is_saved		= 1;

	% Execution time:
	t_end_statebusy					= clock;
	dt_statebusy						= etime(t_end_statebusy,t_start_statebusy);
	dt_statebusy_str					= dt_string(dt_statebusy);
	if dt_statebusy>GV.exec_time.save_project.dt
		GV.exec_time.save_project.name		= APP.SaveProjectMenu.Text;
		GV.exec_time.save_project.t_start	= t_start_statebusy;
		GV.exec_time.save_project.t_end		= t_end_statebusy;
		GV.exec_time.save_project.dt			= dt_statebusy;
		GV.exec_time.save_project.dt_str		= dt_statebusy_str;
	end

	% Display state:
	if ~stateisbusy
		display_on_gui('state',...
			sprintf('Saving project ... done (%s).',dt_statebusy_str),...
			'notbusy','replace');
	end

catch ME
	errormessage('',ME);
end

