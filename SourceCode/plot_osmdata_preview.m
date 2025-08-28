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

	if isempty(MAP_OBJECTS)
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

	for i_i_table_plot=1:length(i_table_plot)
		itable			= i_table_plot(i_i_table_plot);
		ud					= [];
		ud.in				= [];
		ud.iw				= [];
		ud.ir				= [];
		ud.rotation		= 0;

		% Get the plot data:
		x_nodes			= [];
		y_nodes			= [];
		x_ways			= [];
		y_ways			= [];
		switch OSMDATA_TABLE.Type(itable)
			case 'node'
				x_nodes	= OSMDATA.node_x_mm(1,OSMDATA_TABLE_INWR(itable));
				y_nodes	= OSMDATA.node_y_mm(1,OSMDATA_TABLE_INWR(itable));
				ud.in		= [ud.in;OSMDATA_TABLE_INWR(itable)];
			case 'way'
				x_ways	= OSMDATA.way(1,OSMDATA_TABLE_INWR(itable)).x_mm;
				y_ways	= OSMDATA.way(1,OSMDATA_TABLE_INWR(itable)).y_mm;
				ud.iw		= [ud.iw;OSMDATA_TABLE_INWR(itable)];
			case 'relation'
				connways_rel			= connect_ways([]);
				[~,~,~,connways_rel]	= getdata_relation(OSMDATA_TABLE_INWR(itable),connways_rel);
				if ~isempty(connways_rel.nodes)
					x_nodes	= connways_rel.nodes.xy(:,1);
					y_nodes	= connways_rel.nodes.xy(:,2);
				end
				for k_line=1:size(connways_rel.lines,1)
					if isempty(x_ways)
						x_ways	= connways_rel.lines(k_line,1).xy(:,1);
						y_ways	= connways_rel.lines(k_line,1).xy(:,2);
					else
						x_ways	= [x_ways;nan;connways_rel.lines(k_line,1).xy(:,1)];
						y_ways	= [y_ways;nan;connways_rel.lines(k_line,1).xy(:,2)];
					end
				end
				for k_line=1:size(connways_rel.areas,1)
					if isempty(x_ways)
						x_ways	= connways_rel.areas(k_line,1).xy(:,1);
						y_ways	= connways_rel.areas(k_line,1).xy(:,2);
					else
						x_ways	= [x_ways;nan;connways_rel.areas(k_line,1).xy(:,1)];
						y_ways	= [y_ways;nan;connways_rel.areas(k_line,1).xy(:,2)];
					end
				end
				ud.ir		= [ud.ir;OSMDATA_TABLE_INWR(itable)];
		end

		% Add the preview of nodes to the map:
		if ~isempty(x_nodes)&&~isempty(y_nodes)
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
			end
			if strcmp(par,'temp')
				GV_H.map_tempprevobjects(end+1,1).h	= plot(GV_H.ax_2dmap,x_nodes,y_nodes,...
					'Color'     ,GV.tempprev.Color,...
					'LineStyle' ,'none',...
					'LineWidth' ,GV.tempprev.LineWidth,...
					'Marker'    ,GV.tempprev.Marker,...
					'MarkerSize',GV.tempprev.MarkerSize);
			else
				imapobj		= size(MAP_OBJECTS,1)+1;
				ud.xy0		= [x_nodes(:) y_nodes(:)];
				h_preview	= plot(GV_H.ax_2dmap,x_nodes,y_nodes,...
					'Color'     ,GV.preview.Color,...
					'LineStyle' ,'none',...
					'LineWidth' ,GV.preview.LineWidth,...
					'Marker'    ,GV.preview.Marker,...
					'MarkerSize',GV.preview.MarkerSize,...
					'UserData'  ,ud);
				% Save relevant data in the structure MAP_OBJECTS:
				x_center	= mean(x_nodes);
				y_center	= mean(y_nodes);
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

		% Add the preview of ways to the map:
		if ~isempty(x_ways)&&~isempty(y_ways)
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
			end
			if strcmp(par,'temp')
				GV_H.map_tempprevobjects(end+1,1).h	= plot(GV_H.ax_2dmap,x_ways,y_ways,...
					'Color'     ,GV.tempprev.Color,...
					'LineStyle' ,GV.tempprev.LineStyle,...
					'LineWidth' ,GV.tempprev.LineWidth,...
					'Marker'    ,'none',...
					'MarkerSize',GV.tempprev.MarkerSize);
			else
				imapobj		= size(MAP_OBJECTS,1)+1;
				ud.xy0		= [x_ways(:) y_ways(:)];
				h_preview	= plot(GV_H.ax_2dmap,x_ways,y_ways,...
					'Color'     ,GV.preview.Color,...
					'LineStyle' ,GV.preview.LineStyle,...
					'LineWidth' ,GV.preview.LineWidth,...
					'Marker'    ,'none',...
					'MarkerSize',GV.preview.MarkerSize,...
					'UserData'  ,ud);
				% Save relevant data in the structure MAP_OBJECTS:
				x_center	= mean(x_ways(~isnan(x_ways)));
				y_center	= mean(y_ways(~isnan(y_ways)));
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

