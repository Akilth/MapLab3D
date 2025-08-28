function settings_out=set_settings(par,settings_in)
% Load and save default values.
% SETTINGS fields see par='defaults'
%
% Syntax:
% -	set_settings('load')							Load the file settings.mat in the current directory and
%															overwrite the global variable SETTINGS.
%															If the file does not exist, it will be created.
% -	settings_out=set_settings('load')		Load the file settings.mat in the current directory.
%															The global variable SETTINGS will not be changed.
%															If the file does not exist, it will be created.
% -	set_settings('save')							Save global variable SETTINGS in settings.mat in the current directory.
% -	set_settings('save',settings_in)			Save variable settings_in in settings.mat in the current directory.
% -	settings_out=set_settings('defaults')	Get the structure settings_out with default values.
% -	set_settings('init')							Initialize the global variable SETTINGS.
%															Overwrite default values with existing values in the file settings.mat.

global SETTINGS GV

try
	
	% Settings.mat pathname:
	[pathname_settings,~,~]	= fileparts(mfilename('fullpath'));
	pathfilename_settings	= [pathname_settings '\settings.mat'];
	
	% Output variable:
	settings_out							= [];
	
	switch par
		case 'init'
			% Initialize the global variable SETTINGS:
			
			% Default settings:
			defsettings			= set_settings('defaults');
			
			% Assign the default settings, if the field does not exist:
			if exist(pathfilename_settings,'file')==2
				set_settings('load');				% Assign the global variable SETTINGS
				fn			= fieldnames(defsettings);
				for ifn=1:size(fn,1)
					if ~isfield(SETTINGS,fn{ifn,1})
						SETTINGS.(fn{ifn,1})			= defsettings.(fn{ifn,1});
					end
				end
			else
				SETTINGS		= defsettings;
			end
			set_settings('save');
			
		case 'load'
			% Load the global variable SETTINGS:
			
			SETTINGS_existing			= SETTINGS;
			if exist(pathfilename_settings,'file')==2
				% Load settings:
				load(pathfilename_settings,'-mat','SETTINGS');
			else
				% Initialize settings:
				set_settings('init');
			end
			if nargout==0
				% nop
			elseif nargout==1
				% Do not overwrite the existing settings:
				settings_out			= SETTINGS;
				SETTINGS					= SETTINGS_existing;
			else
				errormessage;
			end
			
		case 'save'
			% Save the global variable SETTINGS:
			if nargin==1
				% After installing the app, the name of the project parameter file is selected first.
				% Overwrite all other directories with the directory above the project parameter file
				% if they are still equal to the default directory.
				% 1) Get the default pathname:
				%	field names of paths:						length:
				%	without:	default_pathname
				%				osmosis_installpath
				%				charstyle_sampletext
				fn_paths_cell		= {...
					'pp_pathfilename'							1;...		% pp_pathfilename first
					'projectdirectory'						1;...
					'osm_pathfilename'						1;...
					'ele_pathname'								1;...
					'savecurrfigdirectory'					1;...
					'conv_ele_pathname_source'				1;...		% possibly assigned without loading the project parameters
					'conv_ele_pathname_destination'		1;...		% possibly assigned without loading the project parameters
					'osmosis_source_pathfilename'			1;...		% possibly assigned without loading the project parameters
					'osmosis_destination_pathfilename'	1;...		% possibly assigned without loading the project parameters
					'projectdirectory_ts'					GV.testsample_no_max};		% projectdirectory_ts last
				default_pathname		= '';
				for ifn=1:size(fn_paths_cell,1)
					if ~iscell(SETTINGS.(fn_paths_cell{ifn,1}))
						if ~strcmp(SETTINGS.(fn_paths_cell{ifn,1}),SETTINGS.default_pathname)
							default_pathname		= SETTINGS.(fn_paths_cell{ifn,1});
							break
						end
					else
						for i=1:size(SETTINGS.(fn_paths_cell{ifn,1}),1)
							if ~strcmp(SETTINGS.(fn_paths_cell{ifn,1}){i,1},SETTINGS.default_pathname)
								default_pathname		= SETTINGS.(fn_paths_cell{ifn,1}){i,1};
								break
							end
						end
						if ~isempty(default_pathname)
							break
						end
					end
				end
				if ~isempty(default_pathname)
					% At least one path is not equal to the default path:
					default_pathname	= fullfile(default_pathname);		% Delete double '\\'
					if ~strcmp(default_pathname(end),'\')
						if exist(default_pathname,'dir')==7
							% default_pathname is a directory, not a file:
							default_pathname		= [default_pathname '\'];
						end
					end
					k								= strfind(default_pathname,'\');
					if isempty(k)
						default_pathname		= [default_pathname '\'];
					elseif isscalar(k)
						default_pathname		= default_pathname(1:k(end));
					else
						default_pathname		= default_pathname(1:k(end-1));
					end
					% 2) Overwrite all paths that are still equal to the default directory:
					for ifn=1:size(fn_paths_cell,1)
						if ~iscell(SETTINGS.(fn_paths_cell{ifn,1}))
							if   isempty(SETTINGS.(fn_paths_cell{ifn,1}))||...
									strcmp(SETTINGS.(fn_paths_cell{ifn,1}),SETTINGS.default_pathname)
								SETTINGS.(fn_paths_cell{ifn,1})		= default_pathname;
							end
						else
							for i=1:fn_paths_cell{ifn,2}
								if i>size(SETTINGS.(fn_paths_cell{ifn,1}),1)
									SETTINGS.(fn_paths_cell{ifn,1}){i,1}		= default_pathname;
								else
									if   isempty(SETTINGS.(fn_paths_cell{ifn,1}){i,1})||...
											strcmp(SETTINGS.(fn_paths_cell{ifn,1}){i,1},SETTINGS.default_pathname)
										SETTINGS.(fn_paths_cell{ifn,1}){i,1}		= default_pathname;
									end
								end
							end
						end
					end
				end
				% 3) Save SETTINGS:
				save(pathfilename_settings,'SETTINGS');
			elseif nargin==2
				SETTINGS_existing		= SETTINGS;
				SETTINGS					= settings_in;
				save(pathfilename_settings,'SETTINGS');
				SETTINGS					= SETTINGS_existing;
			else
				errormessage;
			end
			
		case 'defaults'
			% Default settings:
			
			% Default directory:
			if exist('C:\','dir')==7
				settings_out.default_pathname					= 'C:\';
			else
				settings_out.default_pathname					= pathfilename_settings(1:3);
			end
			% Default filename:
			settings_out.default_filename						= '';
			% Other default parameters:
			settings_out.build_datetime						= [];		% assigned when maplab3d_build is executed
			settings_out.projectdirectory						= settings_out.default_pathname;
			settings_out.pp_pathfilename						= settings_out.default_pathname;
			settings_out.osm_pathfilename						= settings_out.default_pathname;
			settings_out.ele_pathname							= settings_out.default_pathname;
			settings_out.conv_ele_pathname_source			= settings_out.default_pathname;
			settings_out.conv_ele_pathname_destination	= settings_out.default_pathname;
			settings_out.savecurrfigdirectory				= settings_out.default_pathname;
			settings_out.osmosis_installpath					= '';		% must be empty (not existing), so the user will be asked
			settings_out.charstyle_sampletext				= 'jÄ"®j:!';
			settings_out.osmosis_source_pathfilename			= settings_out.default_pathname;
			settings_out.osmosis_destination_pathfilename	= settings_out.default_pathname;
			for testsample_no=1:GV.testsample_no_max
				settings_out.projectdirectory_ts{testsample_no,1}	= settings_out.default_pathname;		% testsample_no=1
			end
			
	end
	
	
catch ME
	errormessage('',ME);
end

