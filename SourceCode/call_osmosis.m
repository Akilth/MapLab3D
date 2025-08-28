function call_osmosis(get_osmosis_path,method)
% Create Osmosis command and optionally call Osmosis in order to reduce the file size of large pbf- or osm-files.
% This will reduce the time for loading OSM-data.
% If "Extract all include tags" is selected the include tags of the current project are used.
% Exclude tags will not be considered.
% Osmosis syntax see: https://wiki.openstreetmap.org/wiki/Osmosis#Detailed_usage
% There are 2 methods implemented:
% 1)	method='call_osmosis'
%		get_osmosis_path=0			Osmosis is called by MapLab3D.
%		get_osmosis_path=1			The user is only asked for the Osmosis install path.
% 2)	method='create_command'
%		get_osmosis_path=0			Create only the Osmosis command, Osmosis is called by the user.
%											If necessary, the user is asked for the Osmosis install path.
%											Advantages:
%											- The output of Osmosis is always visible in the command prompt, even if the
%											  Windows Command Shell of MATLAB is not activated in the standalone version.
%											- MapLab3D does not have to wait for the end of the execution of Osmosis.
%											- Osmosis is not part of MapLab3D.
%		get_osmosis_path=1			The user is only asked for the Osmosis install path.
%		get_osmosis_path=2			Opens the command prompt window.
%											If necessary, the user is asked for the Osmosis install path.

global PP GV GV_H APP SETTINGS

try
	
	% For testing:
	testout		= 0;
	if nargin==0
		get_osmosis_path	= 0;
	end
	
	
	% Initializations:
	if nargin<2
		method			= 'create_command';
	end
	lonmin_txt			= 'Longitude of the left edge of the bounding box (default -180°)';
	lonmax_txt			= 'Longitude of the right edge of the bounding box (default 180°)';
	latmin_txt			= 'Latitude of the bottom edge of the bounding box (default -90°)';
	latmax_txt			= 'Latitude of the top edge of the bounding box (default 90°)     ';
	
	% Display state:
	t_start_statebusy		= clock;
	switch method
		case 'call_osmosis'
			switch get_osmosis_path
				case 0
					display_on_gui_txt	= 'Call Osmosis ...';
				case 1
					display_on_gui_txt	= 'Enter .../osmosis/bin path ...';
			end
		case 'create_command'
			switch get_osmosis_path
				case 0
					display_on_gui_txt	= 'Create Osmosis command ...';
				case 1
					display_on_gui_txt	= 'Enter .../osmosis/bin path ...';
				case 2
					display_on_gui_txt	= 'Open command prompt at .../osmosis/bin ...';
			end
	end
	display_on_gui('state',display_on_gui_txt,'busy','add');
	
	% Query whether the call of Osmosis makes sense:
	if get_osmosis_path==0
		if    ~APP.Osmosis_Extract_Bounding_Box_Menu.Checked&&...
				~APP.Osmosis_Extract_Include_Tags_Menu.Checked&&(...
				isequal(APP.Osmosis_Dest_File_PBF_Menu.Checked,APP.Osmosis_Source_File_PBF_Menu.Checked)||...
				isequal(APP.Osmosis_Dest_File_OSM_Menu.Checked,APP.Osmosis_Source_File_OSM_Menu.Checked)     )
			if isfield(GV_H.warndlg,'callosmosis')
				if ishandle(GV_H.warndlg.callosmosis)
					close(GV_H.warndlg.callosmosis);
				end
			end
			GV_H.warndlg.callosmosis		= warndlg(sprintf([...
				'Calling Osmosis with the current settings \n',...
				'has no effect. The function was aborted.']),'Warning');
			GV_H.warndlg.callosmosis.Tag	= 'maplab3d_figure';
			display_on_gui('state',...
				sprintf('%s nothing to do.',display_on_gui_txt),...
				'notbusy','replace');
			return
		end
		if APP.Osmosis_Extract_Include_Tags_Menu.Checked&&isempty(PP)
			if isfield(GV_H.warndlg,'callosmosis')
				if ishandle(GV_H.warndlg.callosmosis)
					close(GV_H.warndlg.callosmosis);
				end
			end
			GV_H.warndlg.callosmosis	= warndlg(sprintf([...
				'Calling Osmosis with the setting\n',...
				'"%s" and without\n',...
				'loading project parameters is not possible.\n',...
				'The function was aborted.'],...
				APP.Osmosis_Extract_Include_Tags_Menu.Text),'Warning');
			GV_H.warndlg.callosmosis.Tag	= 'maplab3d_figure';
			display_on_gui('state',...
				sprintf('%s canceled (%s).',display_on_gui_txt,dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			return
		end
	end
	
	% Documentation file with all settings:
	settings	= sprintf('Osmosis settings:\n');
	
	% Get Osmosis path (e. g.: 'C:\Program Files (x86)\osmosis\bin\'):
	if    (get_osmosis_path==1)||...
			(exist(SETTINGS.osmosis_installpath,'dir')~=7)
		% Ask for the Osmosis install path and save this setting:
		if exist(SETTINGS.osmosis_installpath,'dir')~=7
			osmosis_installpath	= SETTINGS.default_pathname;
		else
			osmosis_installpath	= SETTINGS.osmosis_installpath;
		end
		figure(APP.MapLab3D);	% This is a test to prevent the uiget window from being opened behind another window.
		osmosis_installpath		= uigetdir_local(osmosis_installpath,'Enter .../osmosis/bin path');
		figure(APP.MapLab3D);	% This brings the app figure to the foreground.
		if isequal(osmosis_installpath,0)
			display_on_gui('state',...
				sprintf('%s canceled (%s).',display_on_gui_txt,dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			return
		end
		if ~strcmp(osmosis_installpath(end),'\')
			osmosis_installpath	= [osmosis_installpath '\'];
		end
		SETTINGS.osmosis_installpath	= osmosis_installpath;
		set_settings('save');
	end
	
	% Open the command prompt window:
	if (get_osmosis_path==2)&&strcmp(method,'create_command')
		previous_folder	= cd(SETTINGS.osmosis_installpath);
		!cmd &
		cd(previous_folder);
	end
	
	% Exit:
	if (get_osmosis_path==1)||(get_osmosis_path==2)
		display_on_gui('state',...
			sprintf('%s done (%s).',display_on_gui_txt,dt_string(etime(clock,t_start_statebusy))),...
			'notbusy','replace');
		return
	end
	
	% Continue with get_osmosis_path=0:
	
	% Source path and file name:
	if APP.Osmosis_Source_File_PBF_Menu.Checked
		file_extension_source	= 'pbf';
	else
		file_extension_source	= 'osm';
	end
	pathname_source				= SETTINGS.osmosis_source_pathfilename;
	if exist(pathname_source,'file')~=2
		% The file does not exist: check wether the directory exists:
		k		= strfind(pathname_source,'\');
		pathname_source			= pathname_source(1:k(end));
		if exist(pathname_source,'dir')~=7
			% The directory does not exist:
			pathname_source			= SETTINGS.default_pathname;
		end
	end
	filename_source	= '???';
	while ~strcmp(filename_source((end-length(file_extension_source)+1):end),file_extension_source)
		figure(APP.MapLab3D);	% This is a test to prevent the uiget window from being opened behind another window.
		[filename_source,pathname_source] = uigetfile_local(...
			['*.' file_extension_source],...												% filter
			sprintf('Select the source file *.%s',file_extension_source),...	% title
			pathname_source);																	% defname
		figure(APP.MapLab3D);	% This brings the app figure to the foreground.
		if isequal(filename_source,0)
			% Operation canceled:
			display_on_gui('state',...
				sprintf('%s canceled (%s).',display_on_gui_txt,dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			return
		end
	end
	settings	= sprintf('%s\nSource file:      %s%s\n',settings,pathname_source,filename_source);
	
	% Destination path and file name:
	if APP.Osmosis_Dest_File_PBF_Menu.Checked
		file_extension_destination	= 'pbf';
	else
		file_extension_destination	= 'osm';
	end
	if strcmp(SETTINGS.osmosis_destination_pathfilename,SETTINGS.default_pathname)
		pathname_destination	= pathname_source;
	else
		pathname_destination	= SETTINGS.osmosis_destination_pathfilename;
	end
	if exist(pathname_destination,'file')~=2
		% The file does not exist: check wether the directory exists:
		k		= strfind(pathname_destination,'\');
		pathname_destination			= pathname_destination(1:k(end));
		if exist(pathname_destination,'dir')~=7
			% The directory does not exist:
			pathname_destination			= SETTINGS.default_pathname;
		end
	end
	[filename_destination,pathname_destination] = uiputfile_local(...
		['*.' file_extension_destination],...		% filter
		'Select destination file',...					% title
		pathname_destination);											% defname
	if isequal(filename_destination,0)
		% Operation canceled:
		display_on_gui('state',...
			sprintf('%s canceled (%s).',display_on_gui_txt,dt_string(etime(clock,t_start_statebusy))),...
			'notbusy','replace');
		return
	end
	if ~strcmp(filename_destination((end-length(file_extension_destination)):end),['.' file_extension_destination])
		filename_destination	= [filename_destination '.' file_extension_destination];
	end
	settings	= sprintf('%sDestination file: %s%s\n',settings,pathname_destination,filename_destination);
	pathfilename_settings	= [pathname_destination filename_destination '.txt'];
	
	% Save the settings:
	pathfilename_source									= [pathname_source filename_source];
	pathfilename_destination							= [pathname_destination filename_destination];
	SETTINGS.osmosis_source_pathfilename			= pathfilename_source;
	SETTINGS.osmosis_destination_pathfilename		= pathfilename_destination;
	set_settings('save');
	
	% Boundary box settings:
	lonmin_degree	= -180;
	lonmax_degree	= 180;
	latmin_degree	= -90;
	latmax_degree	= 90;
	if APP.Osmosis_Extract_Bounding_Box_Menu.Checked
		% Default input:
		if ~isempty(PP)
			% Use the project parameters:
			definput		= {...
				sprintf('%3.15g',PP.general.bounding_box.lonmin_degree);...
				sprintf('%3.15g',PP.general.bounding_box.lonmax_degree);...
				sprintf('%3.15g',PP.general.bounding_box.latmin_degree);...
				sprintf('%3.15g',PP.general.bounding_box.latmax_degree)};
		else
			% Default values:
			if isfield(GV,'osmosis_bb_definput')
				definput		= GV.osmosis_bb_definput;
			else
				definput		= {'-180';'180';'-90';'90'};
			end
		end
		% Ask for the bounding box limits:
		prompt		= {lonmin_txt;lonmax_txt;latmin_txt;latmax_txt};
		dlgtitle		= 'Enter bounding box limits';
		warntext		= 'xxxxx';
		while ~isempty(warntext)
			answer		= inputdlg_local(prompt,dlgtitle,1,definput);
			if size(answer,1)~=4
				display_on_gui('state',...
					sprintf('%s canceled (%s).',display_on_gui_txt,dt_string(etime(clock,t_start_statebusy))),...
					'notbusy','replace');
				return
			end
			warntext		= '';
			if    ~isempty(strfind(answer{1,1},','))||...
					~isempty(strfind(answer{2,1},','))||...
					~isempty(strfind(answer{3,1},','))||...
					~isempty(strfind(answer{4,1},','))
				warntext	= sprintf([...
					'Error:\n',...
					'Invalid character '',''.\n',...
					'Use the decimal point ''.'' as decimal separator .']);
			else
				lonmin_degree	= str2double(answer{1,1});
				lonmax_degree	= str2double(answer{2,1});
				latmin_degree	= str2double(answer{3,1});
				latmax_degree	= str2double(answer{4,1});
				if isnan(lonmin_degree)||isnan(lonmax_degree)||isnan(latmin_degree)||isnan(latmax_degree)
					warntext	= sprintf([...
						'Error:\n',...
						'Invalid longitude and/or latitude.\n',...
						'You must enter four numbers.']);
				end
			end
			if ~isempty(warntext)
				if isfield(GV_H.warndlg,'callosmosis')
					if ishandle(GV_H.warndlg.callosmosis)
						close(GV_H.warndlg.callosmosis);
					end
				end
				warntext	= sprintf('%s\nPress OK to repeat.',warntext);
				GV_H.warndlg.callosmosis		= warndlg(warntext,'Warning');
				GV_H.warndlg.callosmosis.Tag	= 'maplab3d_figure';
				while ishandle(GV_H.warndlg.callosmosis)
					pause(0.2);
				end
			end
		end
		GV.osmosis_bb_definput		= {...
			sprintf('%3.15g',lonmin_degree);...
			sprintf('%3.15g',lonmax_degree);...
			sprintf('%3.15g',latmin_degree);...
			sprintf('%3.15g',latmax_degree)};
	end
	
	% Assign tagfilter_str:
	% Example: tagfilter_str = 'boundary=administrative water=* natural=water,peak'
	if APP.Osmosis_Extract_Include_Tags_Menu.Checked&&~isempty(PP)
		include_tags	= struct('key',{},'val',{});
		for iobj=1:size(PP.obj,1)
			if ~isempty(PP.obj(iobj,1).display)
				if (PP.obj(iobj,1).display~=0)||(PP.obj(iobj,1).symbolpar.display~=0)||(PP.obj(iobj,1).textpar.display~=0)
					description		= sprintf('Object number %g (%s)',iobj,PP.obj(iobj,1).description);
					[include_tags,canceled_due_to_error]	= get_includetags(...
						include_tags,...
						PP.obj(iobj,1).tag_incl,...
						description);
					if canceled_due_to_error
						display_on_gui('state',...
							sprintf('%s canceled.',display_on_gui_txt),...
							'notbusy','replace');
						return
					end
					% Texts:
					if isfield(PP.obj(iobj,1).textpar,'tag_incl')
						description		= sprintf('Object number %g (%s), Texts',iobj,PP.obj(iobj,1).description);
						[include_tags,canceled_due_to_error]	= get_includetags(...
							include_tags,...
							PP.obj(iobj,1).textpar.tag_incl,...
							description);
						if canceled_due_to_error
							display_on_gui('state',...
								sprintf('%s canceled.',display_on_gui_txt),...
								'notbusy','replace');
							return
						end
					end
					% Symbols:
					if isfield(PP.obj(iobj,1).symbolpar,'tag_incl')
						description		= sprintf('Object number %g (%s), Symbols',iobj,PP.obj(iobj,1).description);
						[include_tags,canceled_due_to_error]	= get_includetags(...
							include_tags,...
							PP.obj(iobj,1).symbolpar.tag_incl,...
							description);
						if canceled_due_to_error
							display_on_gui('state',...
								sprintf('%s canceled.',display_on_gui_txt),...
								'notbusy','replace');
							return
						end
					end
				end
			end
		end
		% tagfilter_str (e. g.: 'boundary=administrative water=* natural=water,peak'):
		% % Test:
		% for i=1:size(include_tags,1)
		% 	k=include_tags(i,1).key
		% 	v=include_tags(i,1).val
		% end
		settings	= sprintf('%s\nTags that are included in the destination file:\n',settings);
		for i=1:size(include_tags,1)
			tagfilter_str_new	= [include_tags(i,1).key '='];
			if isequal(include_tags(i,1).val,{'*'})
				tagfilter_str_new	= [tagfilter_str_new '*'];
			else
				for j=1:size(include_tags(i,1).val,1)
					if j==1
						tagfilter_str_new	= [tagfilter_str_new include_tags(i,1).val{j,1}];
					else
						tagfilter_str_new	= [tagfilter_str_new ',' include_tags(i,1).val{j,1}];
					end
				end
			end
			if i==1
				tagfilter_str	= tagfilter_str_new;
			else
				tagfilter_str	= [tagfilter_str ' ' tagfilter_str_new];
			end
			settings	= sprintf('%s% 6.0f   %s\n',settings,i,tagfilter_str_new);
		end
	else
		tagfilter_str	= '';
		settings	= sprintf('%s\nNo tags have been filtered.\n',settings);
	end
	
	% Assign boundingbox_str:
	% Example: boundingbox_str	= '--bounding-box top=49.58 left=8.32 bottom=49.36 right=8.73 '
	extract_complete_relations	= false;		% for testing
	if extract_complete_relations
		complete_wr			= 'completeRelations';
		complete_wr_str	= ' (complete relations)';
	else
		complete_wr			= 'completeWays';
		% complete_wr_str	= ' (complete ways)';
		complete_wr_str	= '';
	end
	boundingbox_str	= '';
	if APP.Osmosis_Extract_Bounding_Box_Menu.Checked
		boundingbox_str	= sprintf(['--bounding-box %s=yes ',...
			'top=%f ',...			% latmax_degree
			'left=%f ',...			% lonmin_degree
			'bottom=%f ',...		% latmin_degree
			'right=%f '],...		% lonmax_degree
			complete_wr,...
			latmax_degree,...
			lonmin_degree,...
			latmin_degree,...
			lonmax_degree);
		% Assign settings:
		settings	= sprintf('%s\nBounding box%s:\n',settings,complete_wr_str);
		settings	= sprintf(['%s',...
			'%s = %s\n',...
			'%s = %s\n',...
			'%s = %s\n',...
			'%s = %s\n'],...
			settings,...
			lonmin_txt,number2str(lonmin_degree,'%3.15g'),...
			lonmax_txt,number2str(lonmax_degree,'%3.15g'),...
			latmin_txt,number2str(latmin_degree,'%3.15g'),...
			latmax_txt,number2str(latmax_degree,'%3.15g'));
	else
		settings	= sprintf('%s\nNo bounding box specified.\n',settings);
	end
	
	% Assign read_str:
	switch pathfilename_source((end-3):end)
		case '.pbf'
			read_str		= sprintf('--read-pbf "%s"',pathfilename_source);
		case '.osm'
			read_str		= sprintf('--read-xml "%s"',pathfilename_source);
	end
	
	% Assign write_str:
	switch pathfilename_destination((end-3):end)
		case '.pbf'
			write_str	= sprintf('--write-pbf "%s" omitmetadata=true',pathfilename_destination);
		case '.osm'
			write_str	= sprintf('--write-xml "%s"',pathfilename_destination);
	end
	
	% Variables:
	% SETTINGS.osmosis_installpath		= 'C:\Program Files (x86)\osmosis\bin\'
	% file_extension_source					= 'pbf'
	% pathname_source							= 'C:\OSM\'
	% filename_source							= 'europe-latest.osm.pbf'
	% file_extension_destination			= 'osm'
	% pathname_destination					= 'C:\OSM\'
	% filename_destination					= 'DHBW.osm'
	% tagfilter_str							= 'boundary=administrative water=* natural=water,peak';
	% boundingbox_str							= '--bounding-box top=49.58 left=8.32 bottom=49.36 right=8.73 '
	% read_str
	% write_str
	
	% Osmosis command:
	if isempty(tagfilter_str)
		command		= sprintf([...
			'!osmosis ',...
			'%s ',...											% --read
			'--log-progress ',...
			'%s',...												% --bounding-box
			'%s'],...											% --write
			read_str,boundingbox_str,write_str);
	else
		% Test: Filtering of all boundary=administrative of BadenWuerttemberg:
		% extract_only_relations=true : Osmosis execution time: 3:05:60 h / File size: 456235 kB
		% extract_only_relations=false: Osmosis execution time: 3:41:49 h / File size: 456754 kB
		% ==> The restriction to relations does not bring any significant advantage.
		extract_only_relations		= false;
		if extract_only_relations
			command		= sprintf([...
				'!osmosis ',...
				'%s ',...											% read_str
				'--log-progress ',...
				'%s',...												% boundingbox_str
				'--sort type=TypeThenId ',...
				'--tag-filter accept-relations %s ',...	% tagfilter_str
				'--used-way ',...									% first --used-way, then --used-node !
				'--used-node ',...
				'%s'],...											% write_str
				read_str,boundingbox_str,tagfilter_str,...
				write_str);
		else
			command		= sprintf([...
				'!osmosis ',...
				'%s ',...											% read_str
				'--log-progress ',...
				'%s',...												% boundingbox_str
				'--sort type=TypeThenId ',...
				'--tag-filter accept-nodes %s ',...			% tagfilter_str
				'--tag-filter reject-ways ',...
				'--tag-filter reject-relations ',...
				'',...
				'%s ',...											% read_str
				'--log-progress ',...
				'%s',...												% boundingbox_str
				'--sort type=TypeThenId ',...
				'--tag-filter accept-ways %s ',...			% tagfilter_str
				'--tag-filter reject-relations ',...
				'--used-node ',...
				'',...
				'%s ',...											% read_str
				'--log-progress ',...
				'%s',...												% boundingbox_str
				'--sort type=TypeThenId ',...
				'--tag-filter accept-relations %s ',...	% tagfilter_str
				'--used-way ',...									% first --used-way, then --used-node !
				'--used-node ',...
				'',...
				'--merge --merge ',...
				'%s'],...											% write_str
				read_str,boundingbox_str,tagfilter_str,...
				read_str,boundingbox_str,tagfilter_str,...
				read_str,boundingbox_str,tagfilter_str,...
				write_str);
		end
	end
	
	if testout~=0
		fprintf(1,'\n----------------------------------------------------------');
		fprintf(1,'----------------------------------------------------------\n');
		fprintf(1,'%s',settings)
		fprintf(1,'----------------------------------------------------------');
		fprintf(1,'----------------------------------------------------------\n');
		drawnow;
	end
	
	if strcmp(method,'call_osmosis')
		
		% Delete the old OSM file:
		if isequal(exist(pathfilename_destination,'file'),2)
			delete(pathfilename_destination);
		end
		
		% Call Osmosis:
		t_start_osmosis	= clock;
		set(GV_H.text_waitbar,'String',sprintf('Calling osmosis. This may take some time ... '));
		drawnow;
		previous_folder	= cd(SETTINGS.osmosis_installpath);		% E. g.: 'C:\Program Files (x86)\osmosis\bin\'
		% start(GV_H.timer_display_diary);
		eval(command);
		% stop(GV_H.timer_display_diary);
		cd(previous_folder);
		osmosis_exectime	= dt_string(etime(clock,t_start_osmosis));
		set(GV_H.text_waitbar,'String',sprintf('Osmosis execution time: %s',osmosis_exectime));
		drawnow;
		beep;
		
		% Execution time:
		settings	= sprintf('%s\nOsmosis execution time: %s\n',settings,osmosis_exectime);
		
		% Check for java errors:
		no_lines		= 5;
		lastlines	= display_diary(no_lines);
		if ~contains(lastlines,'complete')
			no_lines		= 100;
			lastlines	= display_diary(no_lines);
			if contains(lastlines,'OutOfMemoryError')||contains(lastlines,'Execution aborted')
				if isfield(GV_H.warndlg,'callosmosis')
					if ishandle(GV_H.warndlg.callosmosis)
						close(GV_H.warndlg.callosmosis);
					end
				end
				GV_H.warndlg.callosmosis		= warndlg(sprintf([...
					'Calling Osmosis probably did not work.\n\n',...
					'See error message at the end of\n',...
					'%sdiary.txt'],GV.pathname_diary),'Warning');
				GV_H.warndlg.callosmosis.Tag	= 'maplab3d_figure';
			end
		end
		
	end
	
	% Add the Osmosis command to the settings:
	settings	= sprintf('%s\nOsmosis command:\n%s\n',settings,command(2:end));
	
	% Save settings:
	% Delete the old settings file:
	if isequal(exist(pathfilename_settings,'file'),2)
		delete(pathfilename_settings);
	end
	% Open the settings file:
	fileID	= fopen(pathfilename_settings,'w');
	% Write the settings to the file:
	fprintf(fileID,'%s',settings);
	% Close the settings file:
	fclose(fileID);
	
	if strcmp(method,'create_command')
		
		% Copy the command to the clipboard:
		clipboard('copy',command(2:end));
		
		% Open the command prompt window:
		question	= sprintf([...
			'The Osmosis command has been copied to the clipboard\n',...
			'and was also saved in:\n',...
			'%s\n',...
			'\n',...
			'Would you like to open the command prompt window?\n',...
			'The command can then simply be pasted with Ctrl+V\n',...
			'and executed with Enter.'],pathfilename_settings);
		answer	= questdlg_local(question,'Open command prompt window?','Yes','No','No');
		if strcmp(answer,'Yes')
			previous_folder	= cd(SETTINGS.osmosis_installpath);
			!cmd &
			cd(previous_folder);
		end
		
	end
	
	% Display state:
	display_on_gui('state',...
		sprintf('%s done (%s).',display_on_gui_txt,dt_string(etime(clock,t_start_statebusy))),...
		'notbusy','replace');
	
catch ME
	errormessage('',ME);
end



% -----------------------------------------------------------------------------------------------------------------
function [include_tags,canceled_due_to_error]=get_includetags(include_tags,tag_incl,description)

global GV_H

try
	
	canceled_due_to_error	= false;
	% r: row number: the criteria of all rows are combined by a logical AND.
	r	= 1;
	for c=1:size(tag_incl,2)
		% c: column number: the criteria of all columns of one row are combined by a logical OR.
		key	= tag_incl(r,c).k;
		op		= tag_incl(r,c).op;
		val	= tag_incl(r,c).v;
		% Assign the key:
		if ~isempty(key)
			if contains(key,'*')||contains(key,'?')
				% Warning if the key contains a wildcard ('*' or '?'):
				if isfield(GV_H.warndlg,'callosmosis')
					if ishandle(GV_H.warndlg.callosmosis)
						close(GV_H.warndlg.callosmosis);
					end
				end
				GV_H.warndlg.callosmosis		= warndlg(sprintf([...
					'Project parameters:\n',...
					'%s:\n',...
					'The include key in row %g, column %g\n',...
					'contains a wildcard:\n',...
					'tag_incl(%g,%g)=''%s''\n',...
					'\n',...
					'For use with Osmosis, you must specify the\n',...
					'include keys in the first row without wildcards.\n',...
					'\n',...
					'The function was aborted.'],description,r,c,r,c,key),'Warning');
				GV_H.warndlg.callosmosis.Tag	= 'maplab3d_figure';
				canceled_due_to_error			= true;
				return
			else
				i	= 1;
				while i<=size(include_tags,1)
					if strcmp(include_tags(i,1).key,key)
						% The key exists already:
						break
					end
					i	= i+1;
				end
				include_tags(i,1).key	= key;
				% Assign the value:
				if isempty(val)
					% The value is empty: Include all objects regardless of their values:
					include_tags(i,1).val	= {'*'};
				else
					if contains(val,'*')||contains(val,'?')
						% The value contains wildcards: Include all objects regardless of their values:
						include_tags(i,1).val	= {'*'};
					else
						if strcmp(op,'==')
							% op='==': Include all objects depending on their values:
							if ~isequal(include_tags(i,1).val,{'*'})
								if isempty(include_tags(i,1).val)
									include_tags(i,1).val{1,1}			= val;
								else
									j	= 1;
									while j<=size(include_tags(i,1).val,1)
										if strcmp(include_tags(i,1).val{j,1},val)
											% The value exists already:
											break
										end
										j	= j+1;
									end
									include_tags(i,1).val{j,1}	= val;
								end
							end
						else
							% op is not '==': Include all objects regardless of their values:
							include_tags(i,1).val	= {'*'};
						end
					end
				end
			end
		end
	end
	
catch ME
	errormessage('',ME);
end


