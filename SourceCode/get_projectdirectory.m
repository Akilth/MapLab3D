function projectdirectory=get_projectdirectory(get_userinput_pd,testsample_no)
% Asks the user for the project directory (location of the output files).
% Result: GV.projectdirectory
% Syntax:
% 1)	pd=get_projectdirectory(0) or
%     pd=get_projectdirectory								get the project directory, use existing project directory
% 2)	pd=get_projectdirectory(1)							get the project directory, ask for the project directory
% 3)	pd=get_projectdirectory(0,testsample_no)		get the project directory for test samples
%     pd=get_projectdirectory(1,testsample_no)		(e. g. testsample_no=1: color samples)

global GV SETTINGS APP

try

	switch nargin
		case 0
			get_userinput_pd	= 1;
			testsample_no		= 0;
		case 1
			testsample_no		= 0;
	end

	% Display state:
	stateisbusy	= display_on_gui('state','','isbusy');
	if ~stateisbusy
		if get_userinput_pd==1
			t_start_statebusy	= clock;
			if testsample_no==0
				display_on_gui('state','Changing project directory ...','busy','add');
			else
				display_on_gui('state','Changing test sample directory ...','busy','add');
			end
		end
	end

	% The last selected directory should be saved and suggested for the next query:
	projectdirectory_old	= '';
	if testsample_no==0
		if ~isfield(GV,'projectdirectory')
			% The path name has not yet been requested:
			get_userinput_pd			=	1;
			projectdirectory			= SETTINGS.projectdirectory;
		else
			% The path name has already been requested:
			projectdirectory			= GV.projectdirectory;
			projectdirectory_old		= GV.projectdirectory;
		end
	else
		% Testsamples:
		if ~isfield(GV,'projectdirectory_ts')
			% The path name has not yet been requested:
			get_userinput_pd			=	1;
			if size(SETTINGS.projectdirectory_ts,1)<testsample_no
				projectdirectory		= SETTINGS.default_pathname;
			else
				projectdirectory		= SETTINGS.projectdirectory_ts{testsample_no,1};
			end
		else
			if size(GV.projectdirectory_ts,1)<testsample_no
				% The path name has not yet been requested:
				get_userinput_pd		=	1;
				if size(SETTINGS.projectdirectory_ts,1)<testsample_no
					projectdirectory	= SETTINGS.default_pathname;
				else
					projectdirectory	= SETTINGS.projectdirectory_ts{testsample_no,1};
				end
			else
				% The path name has already been requested:
				if exist(GV.projectdirectory_ts{testsample_no,1},'dir')==7
					projectdirectory		= GV.projectdirectory_ts{testsample_no,1};
				else
					projectdirectory	= SETTINGS.default_pathname;
				end
			end
		end
	end
	if isnumeric(projectdirectory)
		get_userinput_pd			= 1;
		projectdirectory	= SETTINGS.default_pathname;
	else
		if exist(projectdirectory,'dir')~=7
			% The project directory does not exist:
			get_userinput_pd			= 1;
			projectdirectory	= SETTINGS.default_pathname;
		end
	end

	% Ask for the project directory:
	if get_userinput_pd~=0
		figure(APP.MapLab3D);	% This is a test to prevent the uiget window from being opened behind another window.
		if testsample_no==0
			projectdirectory		= uigetdir_local(projectdirectory,'Select a project directory');
		else
			projectdirectory		= uigetdir_local(projectdirectory,'Select a test sample directory');
		end
		figure(APP.MapLab3D);	% This brings the app figure to the foreground.
		if isequal(projectdirectory,0)
			% If the user clicks Cancel or the window close button (X):
			if ~stateisbusy
				if get_userinput_pd==1
					if testsample_no==0
						display_on_gui('state',...
							sprintf('Changing project directory ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
							'notbusy','replace');
					else
						display_on_gui('state',...
							sprintf('Changing test sample ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
							'notbusy','replace');
					end
				end
			end
			return
		end
	end
	if ~strcmp(projectdirectory(end),'\')
		projectdirectory	= [projectdirectory '\'];
	end

	% The map has to be saved manually:
	if testsample_no==0
		if ~strcmp(projectdirectory_old,projectdirectory)
			GV.map_is_saved	= 0;
		end
	end

	% Create projectdirectory for the STL-files:
	[projectdirectory_stl,projectdirectory_stl_repaired]	= get_projectdirectory_stl(projectdirectory,testsample_no);

	% Assign project directory:
	if testsample_no==0
		GV.projectdirectory					= projectdirectory;
		GV.projectdirectory_stl				= projectdirectory_stl;
		GV.projectdirectory_stl_repaired	= projectdirectory_stl_repaired;
		SETTINGS.projectdirectory			= projectdirectory;
		% GV.projectdirectory maybe has been changed: Begin a new diary file:
		start_diary(GV.projectdirectory);
	else
		GV.projectdirectory_ts{testsample_no,1}			= projectdirectory;
		SETTINGS.projectdirectory_ts{testsample_no,1}	= projectdirectory;
	end
	set_settings('save');
	display_on_gui('pathfilenames');

	% Display state:
	if ~stateisbusy
		if get_userinput_pd==1
			if testsample_no==0
				display_on_gui('state',...
					sprintf('Changing project directory ... done (%s).',dt_string(etime(clock,t_start_statebusy))),...
					'notbusy','replace');
			else
				display_on_gui('state',...
					sprintf('Changing test sample directory ... done (%s).',dt_string(etime(clock,t_start_statebusy))),...
					'notbusy','replace');
			end
		end
	end

catch ME
	errormessage('',ME);
end

