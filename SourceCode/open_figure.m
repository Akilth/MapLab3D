function open_figure
% Open figure file (.fig)

global GV SETTINGS APP

try
	
	% Display state:
	stateisbusy	= display_on_gui('state','','isbusy');
	if ~stateisbusy
		% t_start_statebusy	= clock;
		display_on_gui('state','','busy');
	end
	
	% Ask for the figure file to be loaded:
	fig_pathname	= SETTINGS.default_pathname;
	if ~isempty(GV)
		if isfield(GV,'projectdirectory')
			if ~isempty(GV.projectdirectory)
				fig_pathname			= GV.projectdirectory;
			end
		end
	end
	figure(APP.MapLab3D);	% This is a test to prevent the uiget window from being opened behind another window.
	[fig_filename,fig_pathname]	= uigetfile_local('*.fig',...
		sprintf('Select the figure file (.fig)'),fig_pathname);
	figure(APP.MapLab3D);	% This brings the app figure to the foreground.
	if isequal(fig_filename,0)||isequal(fig_pathname,0)
		% Display state and return:
		if ~stateisbusy
			display_on_gui('state','','notbusy');
		end
		return
	end
	
	% Check the file extension:
	k	= find(fig_filename=='.');
	if isempty(k)
		% Display state and return:
		if ~stateisbusy
			display_on_gui('state','','notbusy');
		end
		return
	end
	if k(end)<2
		% Display state and return:
		if ~stateisbusy
			display_on_gui('state','','notbusy');
		end
		return
	end
	fig_filename_extension	= fig_filename((k(end)+1):end);
	fig_filename_withoutext	= fig_filename(1:(k(end)-1));
	if ~strcmp(fig_filename_extension,'fig')
		errortext	= sprintf([...
			'The file extension .%s is not supported.\n',...
			'The permitted file extension is: .fig'],fig_filename_extension);
		errormessage(errortext)
	end
	
	% Open the figure:
	hf_map_new		= openfig([fig_pathname fig_filename],'invisible');
	figure_theme(hf_map_new,'set',[],'light');
	set(hf_map_new,'Tag','maplab3d_figure');
	set(hf_map_new,'WindowStyle','normal');		% open in a standalone window (not docked)
	set(hf_map_new,'Visible','on');
	% cameratoolbar(hf_map_new,'Show');
	
	% Delete callbacks of the figure:
	set(hf_map_new,'SizeChangedFcn','');
	set(hf_map_new,'ButtonDownFcn','');
	
	
	
	% Delete callbacks of the figure and axis children:
	hc1		= hf_map_new.Children;
	for ihc1=1:size(hc1,1)
		if isprop(hc1(ihc1,1),'ButtonDownFcn')
			hc1(ihc1,1).ButtonDownFcn		= '';
			if isprop(hc1(ihc1,1),'Children')
				hc2		= hc1(ihc1,1).Children;
				for ihc2=1:size(hc2,1)
					if isprop(hc2(ihc2,1),'ButtonDownFcn')
						hc2(ihc2,1).ButtonDownFcn		= '';
					end
				end
			end
		end
		% Create axes toolbar:
		if strcmp(hc1(ihc1,1).Type,'axes')
			axtoolbar(hc1(ihc1,1),{'export','datacursor','pan','zoomin','zoomout','restoreview'});
		end
	end
	
	% Change the name to prevent that it es mixed up with the existing map figure:
	if strcmp(hf_map_new.Name,'Map')
		hf_map_new.Name		= 'Map fig';
	end
	
	% Display state:
	if ~stateisbusy
		display_on_gui('state','','notbusy');
	end
	
catch ME
	errormessage('',ME);
end

