function save_current_figure
% Saves the current figure as image or vector graphics file.

global GV SETTINGS

try
	
	% Current figure:
	fig		= gcf;
	
	% Display state:
	stateisbusy	= display_on_gui('state','','isbusy');
	if ~stateisbusy
		display_on_gui('state',sprintf('Save current figure "%s" ...',fig.Name),'busy','add');
	end
	
	% File formats (see MATLAB command "print"):
	file_formats	= {...
		'*.png'    '-dpng'    '-image';...
		'*.jpg'    '-djpeg'   '-image';...
		'*.tif'    '-dtiff'   '-image';...
		'*.pdf'    '-dpdf'    '-image';...
		'*.svg'    '-dsvg'    '-vector'};
	
	% Get the default directory, file name and file format:
	if ~isfield(GV,'savecurrfigdirectory')
		% The path name has not yet been requested:
		defname			= SETTINGS.savecurrfigdirectory;
	else
		% The path name has already been requested:
		defname			= GV.savecurrfigdirectory;
	end
	if    (exist(defname,'file')==0)&&...
			(exist(defname,'dir' )==0)
		defname			= SETTINGS.default_pathname;
	end
	if exist(defname,'file')==2
		def_file_extension		= defname((end-3):end);
		i_file_formats				= 0;
		for i=1:size(file_formats,1)
			if strcmp(file_formats{i,1}((end-3):end),def_file_extension)
				i_file_formats		= i;
				break
			end
		end
		if i_file_formats~=0
			% Set line i_file_formats als first line (default file format):
			file_formats_i							= file_formats(i_file_formats,:);
			file_formats(i_file_formats,:)	= [];
			file_formats							= [file_formats_i;file_formats];
		end
	end

	% Get the file name and extension:
	filter_c		= file_formats(:,1);
	[filename,pathname]	= uiputfile_local(filter_c,'Select destination file',defname);
	
	% If the user clicks Cancel or the window close button (X):
	if isequal(filename,0)||isequal(pathname,0)
		if ~stateisbusy
			display_on_gui('state',sprintf('Save current figure "%s" ... canceled',fig.Name),'notbusy','replace');
		end
		return
	end
	
	% Get the selected file format:
	file_extension		= filename((end-3):end);
	i_file_formats		= 0;
	for i=1:size(file_formats,1)
		if strcmp(file_formats{i,1}((end-3):end),file_extension)
			i_file_formats		= i;
			break
		end
	end
	if i_file_formats==0
		if ~stateisbusy
			display_on_gui('state',sprintf('Save current figure "%s" ... canceled',fig.Name),'notbusy','replace');
		end
		return
	end
	formattype										= file_formats{i_file_formats,2};
	contenttype										= file_formats{i_file_formats,3};
	
	% Save the figure:
	fig_settings				= figure_theme(fig,'set',[],'light');
	fig_PaperPositionMode	= fig.PaperPositionMode;
	fig.PaperPositionMode	= 'auto';		% Otherwise the option '-r0' does not work
	if strcmp(formattype,'-dpdf')
		print(fig,[pathname filename],formattype,contenttype,...
			'-r0',...					% screen resolution
			'-fillpage');				% '-fillpage' / '-bestfit'
	else
		print(fig,[pathname filename],formattype,contenttype,...
			'-r0');						% screen resolution
	end
	figure_theme(fig,'reset',fig_settings);
	fig.PaperPositionMode	= fig_PaperPositionMode;
	
	% Save the settings:
	GV.savecurrfigdirectory			= [pathname filename];
	SETTINGS.savecurrfigdirectory	= pathname;
	set_settings('save');
	
	% Display state:
	if ~stateisbusy
		display_on_gui('state',sprintf('Figure "%s" saved as "%s"',fig.Name,filename),'notbusy','replace');
	end
	
catch ME
	errormessage('',ME);
end

