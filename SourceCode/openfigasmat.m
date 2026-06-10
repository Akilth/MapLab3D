function [fig,ax]=openfigasmat(fig,ax,pathfilename,figvisible)
% Loads the data of the figure, axes and plots stored in pathfilename, assigns the figure and axes userdata and
% recreates the plots in the axes ax of figure fig.
%
% fig, ax					Figure and axes handles where to plot the data.
%								Empty: The figure and axes are created inside this function.
% figvisible:	'on'		Optional:	Open the saved figure in a visible state (default)
%					'off'						Open the saved figure in an invisible state.
%
% data.figdata.(p{ip,1})								-->	figure properties
% data.ax(ia,1).axdata.(p{ip,1})						-->	axis properties
% data.ax(ia,1).axch(iac,1).axchdata.(p{ip,1})	-->	plot properties

try
	
	% Initialization:
	if length(pathfilename)<=4
		errormessage;
	end
	if ~strcmp(pathfilename((end-3):end),'.mat')
		errormessage;
	end
	if exist(pathfilename,'file')~=2
		errormessage;
	end
	
	% Load figure data:
	load(pathfilename,'-mat','data');
	
	% Create figure and axes if necessary:
	if nargin<4
		figvisible	= 'on';
	end
	if isempty(fig)
		clear fig ax
		fig	= figure('Visible',figvisible);
		figure_theme(fig,'set',[],'light');
		set(fig,'WindowStyle','normal');		% open in a standalone window (not docked)
		set(fig,'Tag','maplab3d_figure');
		for ia=1:size(data.ax,1)
			ax(ia,1)		= axes(fig);
		end
	else
		if ~isvalid(fig)
			clear fig ax
			fig	= figure('Visible',figvisible);
			figure_theme(fig,'set',[],'light');
			set(fig,'WindowStyle','normal');		% open in a standalone window (not docked)
			set(fig,'Tag','maplab3d_figure');
			for ia=1:size(data.ax,1)
				ax(ia,1)		= axes(fig);
			end
		else
			if length(ax)~=size(data.ax,1)
				clear ax
				for ia=1:size(data.ax,1)
					ax(ia,1)		= axes(fig);
				end
			else
				ax		= ax(:);
				for ia=1:size(data.ax,1)
					if ~isvalid(ax(ia,1))
						ax(ia,1)		= axes(fig);
					end
				end
			end
		end
	end
	
	% Figure data:
	p		= fieldnames(data.figdata);
	for ip=1:size(p,1)
		if    ~strcmp(p{ip,1},'Number')&&...
				~strcmp(p{ip,1},'BeingDeleted')&&...
				~strcmp(p{ip,1},'Type')
			try
				fig.(p{ip,1})		= data.figdata.(p{ip,1});
			catch
				fprintf(1,'Load figure: Read-only property skipped: data.figdata.%s\n',p{ip,1});
			end
		end
	end
	if strcmp(figvisible,'on')
		pause(0.01);
	end
	
	% Axis data:
	for ia=1:size(data.ax,1)
		
		% Axis properties:
		p		= fieldnames(data.ax(ia,1).axdata);
		for ip=1:size(p,1)
			if    ~strcmp(p{ip,1},'CurrentPoint')&&...
					~strcmp(p{ip,1},'TightInset')&&...
					~strcmp(p{ip,1},'NextSeriesIndex')&&...
					~strcmp(p{ip,1},'BeingDeleted')&&...
					~strcmp(p{ip,1},'Type')
				try
					ax(ia,1).(p{ip,1})		= data.ax(ia,1).axdata.(p{ip,1});
				catch
					fprintf(1,'Load figure: Read-only property skipped: data.ax(%g,1).axdata.%s\n',ia,p{ip,1});
				end
			end
		end
		if strcmp(figvisible,'on')
			pause(0.01);
		end
		
		% Axis children:
		% The higher iac, the further back on the map: begin plotting with the last element!
		for iac=size(data.ax(ia,1).axch,1):-1:1
			
			% Create axis children:
			if isfield(data.ax(ia,1).axch(iac,1).axchdata,'Type')
				switch data.ax(ia,1).axch(iac,1).axchdata.Type
					case 'line'
						ch		= plot(ax(ia,1),...
							data.ax(ia,1).axch(iac,1).axchdata.XData,...
							data.ax(ia,1).axch(iac,1).axchdata.YData);
					case 'polygon'
						ch		= plot(ax(ia,1),...
							data.ax(ia,1).axch(iac,1).axchdata.Shape);
					case 'text'
						ch		= text(ax(ia,1),...
							data.ax(ia,1).axch(iac,1).axchdata.Position(1,1),...
							data.ax(ia,1).axch(iac,1).axchdata.Position(1,2),...
							data.ax(ia,1).axch(iac,1).axchdata.String);
					otherwise
						ch		= [];
						fprintf(1,'Load figure: Axis ia=%g children iac=%g skipped: type %s not implemented\n',...
							ia,iac,data.ax(ia,1).axch(iac,1).axchdata.Type);
				end
			else
				fprintf(1,'Load figure: Axis ia=%g children iac=%g skipped: no type property\n',ia,iac);
			end
			
			% Axis children properties:
			if ~isempty(ch)
				p		= fieldnames(data.ax(ia,1).axch(iac,1).axchdata);
				for ip=1:size(p,1)
					if    ~strcmp(p{ip,1},'DataTipTemplate')&&...
							~strcmp(p{ip,1},'BeingDeleted')&&...
							~strcmp(p{ip,1},'Type')&&...
							~strcmp(p{ip,1},'Extent')
						try
							ch.(p{ip,1})		= data.ax(ia,1).axch(iac,1).axchdata.(p{ip,1});
						catch
							fprintf(1,'Load figure: Read-only property skipped: data.ax(%g,1).axch(%g,1).axchdata.%s\n',...
								ia,iac,p{ip,1});
						end
					end
				end
			end
			if strcmp(figvisible,'on')
				if mod(iac,50)==0
					pause(0.01);
				end
			end
			
		end
		if strcmp(figvisible,'on')
			pause(0.01);
		end
		
	end
	
	% Set figure visibility:
	fig.Visible		= figvisible;
	
catch ME
	errormessage('',ME);
end
