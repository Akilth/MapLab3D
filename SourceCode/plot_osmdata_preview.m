function plot_osmdata_preview(i_table_plot,par,description)
% Plots nodes and ways from the OSM-data table (filtered OSM-data) as preview in the axis GV_H.ax_2dmap.
% i_table_plot		vector of indices in OSMDATA_TABLE
% par='replace'	replace preview
% par='add'			add preview
% par='temp'		show temporary preview
% description		text added to the field MAP_OBJECTS(i,1).dscr
%
% Syntax, e.g.:	plot_osmdata_preview([7:10 12],'add','highway service')
%						plot_osmdata_preview([7:10 12],'add','')			-->  description='preview line'
%						plot_osmdata_preview([7:10 12],'add')				-->  description='preview line'
%						plot_osmdata_preview([7:10 12],'temp')
%						plot_osmdata_preview([],'temp')						--> all temporary preview will be deleted

global MAP_OBJECTS GV GV_H OSMDATA_TABLE OSMDATA_TABLE_INWR OSMDATA I_OSMDATA_TABLE_TEMPPREV

try
	
	if isempty(MAP_OBJECTS)&&~strcmp(par,'temp')
		return
	end
	
	if nargin<1
		%  Test:
		i_table_plot	= 2;
		par				= 'add';
	end
	if nargin<3
		description		= 'preview';
	end
	
	% i_table_plot must be unique:
	i_table_plot	= unique(i_table_plot);
	
	% Delete existing plot objects:
	if strcmp(par,'temp')
		% If par='temp': delete all existing temporary preview objects:
		if isfield(GV_H,'map_tempprevobjects')
			for iplot=1:size(GV_H.map_tempprevobjects,1)
				if ishandle(GV_H.map_tempprevobjects(iplot,1).h)
					delete(GV_H.map_tempprevobjects(iplot,1).h);
				end
			end
		end
		GV_H.map_tempprevobjects=[];
		% Save current indices of temporary preview objects in OSMDATA_TABLE:
		I_OSMDATA_TABLE_TEMPPREV	= i_table_plot;
	else
		imapobj_v	= find([MAP_OBJECTS.iobj]<=-1);
		if strcmp(par,'replace')
			% If par='replace': delete all existing preview objects:
			for i=1:length(imapobj_v)
				delete(MAP_OBJECTS(imapobj_v(i),1).h);
			end
			MAP_OBJECTS=MAP_OBJECTS([MAP_OBJECTS.iobj]>=1);
		end
		if isempty(OSMDATA_TABLE)
			errormessage(sprintf([...
				'Error:\n',...
				'No data.']));
		end
		if isempty(i_table_plot)
			errormessage(sprintf([...
				'Error:\n',...
				'No selection.']));
		end
	end
	
	% Delete legend:
	if length(i_table_plot)>1
		legend(GV_H.ax_2dmap,'off');
	end
	
	% Get the plot data:
	ud					= [];
	ud.in				= [];
	ud.iw				= [];
	ud.ir				= [];
	ud.rotation		= 0;
	nodes				= [];
	ways				= [];
	for i_i_table_plot=1:length(i_table_plot)
		itable			= i_table_plot(i_i_table_plot);
		switch OSMDATA_TABLE.Type(itable)
			case 'node'
				in					= size(nodes,1)+1;
				nodes(in,1).x	= OSMDATA.node_x_mm(1,OSMDATA_TABLE_INWR(itable));
				nodes(in,1).y	= OSMDATA.node_y_mm(1,OSMDATA_TABLE_INWR(itable));
				ud.in				= [ud.in;OSMDATA_TABLE_INWR(itable)];
			case 'way'
				iw					= size(ways,1)+1;
				ways(iw,1).x	= OSMDATA.way(1,OSMDATA_TABLE_INWR(itable)).x_mm;
				ways(iw,1).y	= OSMDATA.way(1,OSMDATA_TABLE_INWR(itable)).y_mm;
				ud.iw				= [ud.iw;OSMDATA_TABLE_INWR(itable)];
			case 'relation'
				connways_rel			= connect_ways([]);
				[~,~,~,connways_rel]	= getdata_relation(OSMDATA_TABLE_INWR(itable),connways_rel);
				if ~isempty(connways_rel.nodes)
					in					= size(nodes,1)+1;
					nodes(in,1).x	= connways_rel.nodes.xy(:,1);
					nodes(in,1).y	= connways_rel.nodes.xy(:,2);
				end
				for k_line=1:size(connways_rel.lines,1)
					iw					= size(ways,1)+1;
					ways(iw,1).x	= connways_rel.lines(k_line,1).xy(:,1);
					ways(iw,1).y	= connways_rel.lines(k_line,1).xy(:,2);
				end
				for k_line=1:size(connways_rel.areas,1)
					iw					= size(ways,1)+1;
					ways(iw,1).x	= connways_rel.areas(k_line,1).xy(:,1);
					ways(iw,1).y	= connways_rel.areas(k_line,1).xy(:,2);
				end
				ud.ir		= [ud.ir;OSMDATA_TABLE_INWR(itable)];
		end
	end
	
	% Add the preview of nodes to the map:
	for in=1:size(nodes,1)
		if ~isempty(nodes.x)&&~isempty(nodes.y)
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
			end
			if strcmp(par,'temp')
				GV_H.map_tempprevobjects(end+1,1).h	= plot(GV_H.ax_2dmap,nodes.x,nodes.y,...
					'Color'     ,GV.tempprev.Color,...
					'LineStyle' ,'none',...
					'LineWidth' ,GV.tempprev.LineWidth,...
					'Marker'    ,GV.tempprev.Marker,...
					'MarkerSize',GV.tempprev.MarkerSize);
			else
				imapobj		= size(MAP_OBJECTS,1)+1;
				ud.xy0		= [nodes.x(:) nodes.y(:)];
				h_preview	= plot(GV_H.ax_2dmap,nodes.x,nodes.y,...
					'Color'     ,GV.preview.Color,...
					'LineStyle' ,'none',...
					'LineWidth' ,GV.preview.LineWidth,...
					'Marker'    ,GV.preview.Marker,...
					'MarkerSize',GV.preview.MarkerSize,...
					'UserData'  ,ud);
				% Save relevant data in the structure MAP_OBJECTS:
				x_center	= mean(nodes.x);
				y_center	= mean(nodes.y);
				MAP_OBJECTS(imapobj,1).disp	= 'preview node';
				MAP_OBJECTS(imapobj,1).h		= h_preview;
				MAP_OBJECTS(imapobj,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
				MAP_OBJECTS(imapobj,1).dscr	= description;
				MAP_OBJECTS(imapobj,1).x		= x_center;
				MAP_OBJECTS(imapobj,1).y		= y_center;
				MAP_OBJECTS(imapobj,1).text	= {''};
				MAP_OBJECTS(imapobj,1).mod		= false;
				MAP_OBJECTS(imapobj,1).cncl	= 0;
				MAP_OBJECTS(imapobj,1).cnuc	= 0;
				MAP_OBJECTS(imapobj,1).vis0	= 1;
			end
		end
	end
	
	% Add the preview of ways to the map:
	for iw=1:size(ways,1)
		if ~isempty(ways(iw,1).x)&&~isempty(ways(iw,1).y)
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
			end
			if strcmp(par,'temp')
				GV_H.map_tempprevobjects(end+1,1).h	= plot(GV_H.ax_2dmap,ways(iw,1).x,ways(iw,1).y,...
					'Color'     ,GV.tempprev.Color,...
					'LineStyle' ,GV.tempprev.LineStyle,...
					'LineWidth' ,GV.tempprev.LineWidth,...
					'Marker'    ,'none',...
					'MarkerSize',GV.tempprev.MarkerSize);
			else
				imapobj		= size(MAP_OBJECTS,1)+1;
				ud.xy0		= [ways(iw,1).x(:) ways(iw,1).y(:)];
				h_preview	= plot(GV_H.ax_2dmap,ways(iw,1).x,ways(iw,1).y,...
					'Color'     ,GV.preview.Color,...
					'LineStyle' ,GV.preview.LineStyle,...
					'LineWidth' ,GV.preview.LineWidth,...
					'Marker'    ,'none',...
					'MarkerSize',GV.preview.MarkerSize,...
					'UserData'  ,ud);
				% Save relevant data in the structure MAP_OBJECTS:
				x_center	= mean(ways(iw,1).x(~isnan(ways(iw,1).x)));
				y_center	= mean(ways(iw,1).y(~isnan(ways(iw,1).y)));
				MAP_OBJECTS(imapobj,1).disp	= 'preview line';
				MAP_OBJECTS(imapobj,1).h		= h_preview;
				MAP_OBJECTS(imapobj,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
				MAP_OBJECTS(imapobj,1).dscr	= description;
				MAP_OBJECTS(imapobj,1).x		= x_center;
				MAP_OBJECTS(imapobj,1).y		= y_center;
				MAP_OBJECTS(imapobj,1).text	= {''};
				MAP_OBJECTS(imapobj,1).mod		= false;
				MAP_OBJECTS(imapobj,1).cncl	= 0;
				MAP_OBJECTS(imapobj,1).cnuc	= 0;
				MAP_OBJECTS(imapobj,1).vis0	= 1;
			end
		end
	end
	
	% Create/modify legend:
	create_legend_mapfigure;
	
	if ~strcmp(par,'temp')
		
		% Update MAP_OBJECTS_TABLE:
		display_map_objects;
		
		% The map has been changed:
		GV.map_is_saved	= 0;
		
	end
	
catch ME
	errormessage('',ME);
end

