function returnvalue=display_on_gui(object,text,value,par)

% When using a Matlab app component (like APP.stateTextArea), it should be renamed in the app designer,
% so changing the description (like 'status') does not change the field name ('stateTextArea') any more.

% object:				text:				value:							par:
% 'state'				log entry		'busy':    state=red			'add':               add line in log
%												'notbusy': state=green		'replace':           replace line in log
%												'isbusy':  query state		'' or not specified: no log entry
% 'pathfilenames'		''					''									''

global APP GV APP_UIOBJECTS

try

	if isempty(APP)||isempty(GV)
		return
	end

	if nargin<4
		par	= '';
	end

	switch object
		case 'state'
			rmax_LogTextArea	= 50;
			switch value
				case 'busy'
					% State color:
					APP.StateTextArea.BackgroundColor		= [1 0 0];		% red
					% Disable the uibuttons, uimenus, ...:
					set(APP_UIOBJECTS,'Enable','off');
					% Update log:
					switch par
						case 'add'
							if isempty(APP.LogTextArea.UserData)
								APP.LogTextArea.UserData	= string(text);
							else
								if size(APP.LogTextArea.UserData,1)==rmax_LogTextArea
									APP.LogTextArea.UserData(2: end   ,1)	= APP.LogTextArea.UserData(1:(end-1),1);
								else
									APP.LogTextArea.UserData(2:(end+1),1)	= APP.LogTextArea.UserData(1: end   ,1);
								end
								APP.LogTextArea.UserData(1,1)	= string(text);
							end
							APP.LogTextArea.Value				= APP.LogTextArea.UserData;
						case 'replace'
							if isempty(APP.LogTextArea.UserData)
								APP.LogTextArea.UserData		= string(text);
							else
								APP.LogTextArea.UserData(1,1)	= string(text);
							end
							APP.LogTextArea.Value{1,1}			= text;
					end
					drawnow;
				case 'notbusy'
					% Display number and PlotNo of selected map objects:
					display_on_gui_selectedmapobjects;
					% State color:
					APP.StateTextArea.BackgroundColor		= [0 1 0];		% green
					% Enable the uibuttons, uimenus, ...:
					set(APP_UIOBJECTS,'Enable','on');
					% Update log:
					switch par
						case 'add'
							if isempty(APP.LogTextArea.UserData)
								APP.LogTextArea.UserData	= string(text);
							else
								if size(APP.LogTextArea.UserData,1)==rmax_LogTextArea
									APP.LogTextArea.UserData(2: end   ,1)	= APP.LogTextArea.UserData(1:(end-1),1);
								else
									APP.LogTextArea.UserData(2:(end+1),1)	= APP.LogTextArea.UserData(1: end   ,1);
								end
								APP.LogTextArea.UserData(1,1)	= string(text);
							end
							APP.LogTextArea.Value				= APP.LogTextArea.UserData;
						case 'replace'
							if isempty(APP.LogTextArea.UserData)
								APP.LogTextArea.UserData		= string(text);
							else
								APP.LogTextArea.UserData(1,1)	= string(text);
							end
							APP.LogTextArea.Value{1,1}			= text;
					end
					drawnow;
				case 'isbusy'
					if isequal(APP.StateTextArea.BackgroundColor,[1 0 0])
						returnvalue	= true;
					else
						returnvalue	= false;
					end

			end

		case 'pathfilenames'
			if isfield(GV,'pp_pathfilename')
				if isfield(GV,'varname_dataset_no')
					APP.pathfilenameprojectparfileTextArea.Value	= {[GV.pp_pathfilename ' (' GV.varname_dataset_no ')']};
				else
					APP.pathfilenameprojectparfileTextArea.Value	= {GV.pp_pathfilename};
				end
			end
			if isfield(GV,'projectdirectory')
				if isfield(GV,'map_filename')&&isfield(GV,'mapdata_filename')
					if ~isempty(GV.map_filename)&&~isempty(GV.mapdata_filename)
						[~,~,mapdata_filename_ending]					= filenames_savefiles('');
						APP.projectdirectoryTextArea.Value			= ...
							{[GV.projectdirectory GV.map_filename ' ' mapdata_filename_ending]};
					else
						APP.projectdirectoryTextArea.Value			= {GV.projectdirectory};
					end
				else
					APP.projectdirectoryTextArea.Value			= {GV.projectdirectory};
				end
			end
			if isfield(GV,'osm_pathfilename')
				APP.pathfilenameOSMDataTextArea.Value			= {GV.osm_pathfilename};
			end
			if isfield(GV,'ele_pathname')
				APP.pathnameELEDataTextArea.Value				= {GV.ele_pathname};
			end
			drawnow;

	end

catch ME
	errormessage('',ME);
end

