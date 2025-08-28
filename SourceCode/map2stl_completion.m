function map2stl_completion(PP_local,map_pathname_stl)
% Last steps when the creation of the map STL-files has been finished

global APP PP GV GV_H PRINTDATA OSMDATA

try

	if nargin==0
		PP_local				= PP;
		% Create the project directories if necessary:
		if ~isfield(GV,'projectdirectory_stl')
			get_projectdirectory;				% Assign GV.projectdirectory_stl
		else
			if exist(GV.projectdirectory_stl,'dir')~=7
				get_projectdirectory;			% Assign GV.projectdirectory_stl
			end
		end
		map_pathname_stl				= GV.projectdirectory_stl;
	end


	%------------------------------------------------------------------------------------------------------------------
	% Project parameters backup:
	%------------------------------------------------------------------------------------------------------------------

	% Save a backup copy of the project parameters file:
	status	= 1;
	i			= strfind(GV.pp_pathfilename,'\');
	if isempty(i)
		[status,msg] = copyfile(GV.pp_pathfilename,GV.projectdirectory);
	else
		if ~isequal(GV.pp_pathfilename(1:i(end)),GV.projectdirectory)
			% The directory of the project parameter file ist not equal to the project directory:
			[status,msg] = copyfile(GV.pp_pathfilename,GV.projectdirectory);
		end
	end
	if status~=1
		if isfield(GV_H.warndlg,'map2stl_completion_savepp')
			if ishandle(GV_H.warndlg.map2stl_completion_savepp)
				close(GV_H.warndlg.map2stl_completion_savepp);
			end
		end
		GV_H.warndlg.map2stl_completion_savepp			= warndlg(sprintf([...
			'Create map STL files:\n',...
			'It was not possible to save a backup copy of the project parameters\n',...
			'%s\n',...
			'in the project directory\n',...
			'%s\n',...
			'\n',...
			'%s'],GV.pp_pathfilename,GV.projectdirectory,msg),'Warning');
		GV_H.warndlg.map2stl_completion_savepp.Tag	= 'maplab3d_figure';
	end


	%------------------------------------------------------------------------------------------------------------------
	% Summary:
	%------------------------------------------------------------------------------------------------------------------

	% Tables:
	%  ─ │ ┌ ┐ └ ┘ ├ ┤ ┬ ┴ ┼
	%  ═ ║ ╔ ╗ ╝ ╚ ╠ ╣ ╦ ╩ ╬
	% ╒ ╓ ╕ ╖ ╘ ╙ ╛ ╜ ╞ ╟ ╡ ╢ ╤ ╥ ╧ ╨ ╫
	% text_str	= sprintf(  '┌───┐\n');
	% text_str	= sprintf('%s│   │\n',text_str);
	% text_str	= sprintf('%s│   │\n',text_str);
	% text_str	= sprintf('%s└───┘\n',text_str);

	% Summary:
	text_str	= sprintf('%s summary:\n',APP.CreatemapSTLfilesMenu.Text);
	text_str	= sprintf('%sCopy the text to a spreadsheet for better readability (for example Excel).\n',text_str);

	% Paths and flenames:
	text_str	= sprintf('%s\n',text_str);
	text_str	= sprintf('%sProject parameters:\t%s\n',text_str,GV.pp_pathfilename);
	text_str	= sprintf('%sSaved data:\t%s\n',text_str,[GV.projectdirectory GV.map_filename]);
	text_str	= sprintf('%s\t%s\n',text_str,[GV.projectdirectory GV.mapdata_filename]);
	text_str	= sprintf('%sOSM data:\t%s\n',text_str,GV.osm_pathfilename);
	text_str	= sprintf('%sElevation data:\t%s\n',text_str,GV.ele_pathname);

	% General data:
	text_str	= sprintf('%s\n',text_str);
	text_str	= sprintf('%sScale:\t%s\n',text_str,number2str(GV.pp_general_scale,'%g'));
	text_str	= sprintf('%sSuperelevation:\t%s\n',text_str,number2str(PP_local.general.superelevation,'%g'));
	text_str	= sprintf('%sMap size:\t%s\twidth / mm\n',text_str,number2str(PRINTDATA.xmax-PRINTDATA.xmin,'%f'));
	text_str	= sprintf('%s\t%s\theight / mm\n',text_str,number2str(PRINTDATA.ymax-PRINTDATA.ymin,'%f'));
	text_str	= sprintf('%s\t%s\txmin / mm\n',text_str,number2str(PRINTDATA.xmin,'%f'));
	text_str	= sprintf('%s\t%s\txmax / mm\n',text_str,number2str(PRINTDATA.xmax,'%f'));
	text_str	= sprintf('%s\t%s\tymin / mm\n',text_str,number2str(PRINTDATA.ymin,'%f'));
	text_str	= sprintf('%s\t%s\tymax / mm\n',text_str,number2str(PRINTDATA.ymax,'%f'));
	if isfield(PRINTDATA,'frame')
		if isfield(PRINTDATA.frame,'xmax')&&isfield(PRINTDATA.frame,'xmin')&&...
				isfield(PRINTDATA.frame,'ymax')&&isfield(PRINTDATA.frame,'ymin')
			text_str	= sprintf('%sFrame size:\t%s\twidth / mm\n',text_str,...
				number2str(PRINTDATA.frame.xmax-PRINTDATA.frame.xmin,'%f'));
			text_str	= sprintf('%s\t%s\theight / mm\n',text_str,...
				number2str(PRINTDATA.frame.ymax-PRINTDATA.frame.ymin,'%f'));
		end
	end
	text_str	= sprintf('%sBottom side of all tiles:\t%s\tz_bottom_tilebase / mm\n',text_str,...
		number2str(PRINTDATA.z_bottom,'%f'));
	text_str	= sprintf('%sLegend: background z-value:\t%s\tz_topside_bgd / mm\n',text_str,...
		number2str(GV.legend_z_topside_bgd,'%f'));
	text_str	= sprintf('%s\t%s\tz_bottom_tilebase maximum value / mm\n',text_str,...
		number2str(PRINTDATA.z_bottom_max,'%f'));

	% Lat/lon
	text_str	= sprintf('%s\n',text_str);
	text_str	= sprintf('%sMap origin:\t%s\tlongitude / degree\n',text_str,number2str(GV.map_origin(1,2),'%f'));
	text_str	= sprintf('%s\t%s\tlatitude / degree\n',text_str,number2str(GV.map_origin(1,1),'%f'));
	[lonmin_deg,lonmax_deg,latmin_deg,latmax_deg]	= calculator_xy_latlon(...
		[],...									% dataset
		PRINTDATA.xmin,...					% xmin_mm
		PRINTDATA.xmax,...					% xmax_mm
		PRINTDATA.ymin,...					% ymin_mm
		PRINTDATA.ymax,...					% ymax_mm
		GV.map_origin(1,2),...				% lonorigin_deg
		GV.map_origin(1,1),...				% latorigin_deg
		GV.pp_general_scale,...				% scale
		0);										% dist_osm_printout
	text_str	= sprintf('%sMap width:\t%s\tmin. longitude (left) / degree\n',text_str,...
		number2str(lonmin_deg,'%f'));
	text_str	= sprintf('%s\t%s\tmax. longitude (right) / degree\n',text_str,...
		number2str(lonmax_deg,'%f'));
	text_str	= sprintf('%sMap depth:\t%s\tmin. latitude (bottom) / degree\n',text_str,...
		number2str(latmin_deg,'%f'));
	text_str	= sprintf('%s\t%s\tmax. latitude (top) / degree\n',text_str,...
		number2str(latmax_deg,'%f'));
	text_str	= sprintf('%sOSM data width:\t%s\tmin. longitude (left) / degree\n',text_str,...
		number2str(OSMDATA.bounds.minlon,'%f'));
	text_str	= sprintf('%s\t%s\tmax. longitude (right) / degree\n',text_str,...
		number2str(OSMDATA.bounds.maxlon,'%f'));
	text_str	= sprintf('%sOSM data depth:\t%s\tmin. latitude (bottom) / degree\n',text_str,...
		number2str(OSMDATA.bounds.minlat,'%f'));
	text_str	= sprintf('%s\t%s\tmax. latitude (top) / degree\n',text_str,...
		number2str(OSMDATA.bounds.maxlat,'%f'));

	% Execution times:
	dt_total		= 0;
	if isfield(GV,'exec_time')
		text_str	= sprintf('%s\n',text_str);
		text_str	= sprintf('%sMaximum execution times / s:\n',text_str);
		fn			= fieldnames(GV.exec_time);
		for i_fn=1:size(fn,1)
			if    isfield(GV.exec_time.(fn{i_fn,1}),'dt'    )&&...
					isfield(GV.exec_time.(fn{i_fn,1}),'name'  )&&...
					isfield(GV.exec_time.(fn{i_fn,1}),'dt_str')
				dt_total	= dt_total+GV.exec_time.(fn{i_fn,1}).dt;
				text_str	= sprintf('%s%s\t%s\t%s\n',text_str,...
					GV.exec_time.(fn{i_fn,1}).name,...
					number2str(GV.exec_time.(fn{i_fn,1}).dt,'%g'),...
					GV.exec_time.(fn{i_fn,1}).dt_str);
			end
		end
	end
	dt_total_str	= dt_string(dt_total);
	text_str	= sprintf('%sSum:\t%s\t%s\n',text_str,number2str(dt_total,'%g'),dt_total_str);

	% Colors:
	text_str	= sprintf('%s\n',text_str);
	text_str	= sprintf('%sUsed colors:\t\t\t\tColor\tPieces\tArea/mm^2\n',text_str);
	no_parts_total	= 0;
	for i_colprio_stal=1:size(PRINTDATA.colprio_visible,1)
		colprio				= PRINTDATA.colprio_visible(i_colprio_stal);
		colno					= find([PP_local.color.prio]==colprio,1);
		area_col	= 0;
		no_parts	= 0;
		for i_tile=1:length(PRINTDATA.tile)
			if length(PRINTDATA.tile(i_tile).col_stal)>=i_colprio_stal
				if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'area')
					if ~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).area)
						area_col	= area_col+PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).area;
					end
				end
			end
			if PP_local.color(colno).standalone_color~=0
				% The color is printed stand-alone and serves as a basis for non-stand-alone colors:
				if length(PRINTDATA.tile(i_tile).col_stal)>=i_colprio_stal
					if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'part_stal')
						no_parts	= no_parts+length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal);
					end
				end
			else
				% The color is printed non-stand-alone in one operation together with other colors.
				% Do not increase no_parts.
			end
		end
		no_parts_total	= no_parts_total+no_parts;
		dscr_col	= sprintf('%s %s',...
			PP_local.color(colno,1).brand,...
			PP_local.color(colno,1).color_short_text);
		text_str	= sprintf('%s%s\t\t\t\t%1.0f\t%1.0f\t%s\n',text_str,dscr_col,colno,no_parts,number2str(area_col,'%1.0f'));
	end
	text_str	= sprintf('%s\t\t\t\tSum:\t%1.0f\n',text_str,no_parts_total);

	% Files sorted by tile number:
	text_str	= sprintf('%s\n',text_str);
	text_str	= sprintf('%sFiles sorted by tile number:\t\t\tTile\tColor\tPieces\tArea/mm^2\n',text_str);
	no_parts_total	= 0;
	for i_tile=1:length(PRINTDATA.tile)
		if ~isempty(PRINTDATA.tile(i_tile).col_stal)
			tile_no	= PRINTDATA.tile_no_all_v(i_tile,1);
			for i_colprio_stal=1:length(PRINTDATA.tile(i_tile).col_stal)
				% stand-alone colors:
				colprio_stal				= PRINTDATA.colprio_visible(i_colprio_stal);
				colno_stal					= find([PP_local.color.prio]==colprio_stal,1);
				if    isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'part_stal')   &&...
						isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'area')        &&...
						isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'filename_stl')
					if    ~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal)   &&...
							~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).area)        &&...
							~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).filename_stl)
						no_parts	= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal);
						text_str	= sprintf('%s%s\t\t\t%1.0f\t%1.0f\t%1.0f\t%s\n',text_str,...
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).filename_stl,...
							tile_no,...
							colno_stal,...
							no_parts,...
							number2str(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).area,'%1.0f'));
						no_parts_total	= no_parts_total+no_parts;
					end
				else
					errormessage;
				end
				% non-stand-alone colors:
				if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'col')
					for i_colprio=1:length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col)
						colprio				= PRINTDATA.colprio_visible(i_colprio_stal);
						colno					= find([PP_local.color.prio]==colprio,1);
						if    isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio),'area')        &&...
								isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio),'filename_stl')
							if    ~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).area)        &&...
									~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).filename_stl)
								no_parts	= 0;
								text_str	= sprintf('%s%s\t\t\t%1.0f\t%1.0f\t%1.0f\t%s\tnot stand-alone color\n',text_str,...
									PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).filename_stl,...
									tile_no,...
									colno,...
									no_parts,...
									number2str(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).area,'%1.0f'));
								% Do not increase no_parts_total.
							end
						else
							errormessage;
						end
					end
				end
			end
		end
	end
	text_str	= sprintf('%s\t\t\t\tSum:\t%1.0f\n',text_str,no_parts_total);

	% Files sorted by color:
	text_str	= sprintf('%s\n',text_str);
	text_str	= sprintf('%sFiles sorted by color:\t\t\tTile\tColor\tPieces\tArea/mm^2\n',text_str);
	no_parts_total		= 0;
	colno_stal_v		= zeros(size(PRINTDATA.colprio_visible,1),1);
	i_colprio_stal_v	= zeros(size(PRINTDATA.colprio_visible,1),1);
	for i_colprio_stal=1:size(PRINTDATA.colprio_visible,1)
		i_colprio_stal_v(i_colprio_stal,1)	= i_colprio_stal;
		colno_stal_v(i_colprio_stal,1)		= find([PP_local.color.prio]==PRINTDATA.colprio_visible(i_colprio_stal,1),1);
	end
	[colno_stal_v,isort]	= sort(colno_stal_v);
	i_colprio_stal_v		= i_colprio_stal_v(isort);
	for i_colno_stal=1:size(colno_stal_v,1)
		colno_stal			= colno_stal_v(i_colno_stal);
		i_colprio_stal		= i_colprio_stal_v(i_colno_stal);
		for i_tile=1:length(PRINTDATA.tile)
			tile_no	= PRINTDATA.tile_no_all_v(i_tile,1);
			% stand-alone colors:
			if length(PRINTDATA.tile(i_tile).col_stal)>=i_colprio_stal
				if    isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'part_stal')   &&...
						isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'area')        &&...
						isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'filename_stl')
					if    ~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal)   &&...
							~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).area)        &&...
							~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).filename_stl)
						no_parts	= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal);
						text_str	= sprintf('%s%s\t\t\t%1.0f\t%1.0f\t%1.0f\t%s\n',text_str,...
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).filename_stl,...
							tile_no,...
							colno_stal,...
							no_parts,...
							number2str(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).area,'%1.0f'));
						no_parts_total	= no_parts_total+no_parts;
					end
				else
					errormessage;
				end
			end
			% non-stand-alone colors:
			if length(PRINTDATA.tile(i_tile).col_stal)>=i_colprio_stal
				if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'col')
					for i_colno=1:size(colno_stal_v,1)
						colno			= colno_stal_v(i_colno);
						i_colprio	= i_colprio_stal_v(i_colno);
						if length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col)>=i_colprio
							if    isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio),'area')        &&...
									isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio),'filename_stl')
								if    ~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).area)        &&...
										~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).filename_stl)
									no_parts	= 0;
									text_str	= sprintf('%s%s\t\t\t%1.0f\t%1.0f\t%1.0f\t%s\tnot stand-alone color\n',text_str,...
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).filename_stl,...
										tile_no,...
										colno,...
										no_parts,...
										number2str(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).area,'%1.0f'));
									% Do not increase no_parts_total.
								end
							else
								errormessage;
							end
						end
					end
				end
			end
		end
	end
	text_str	= sprintf('%s\t\t\t\tSum:\t%1.0f\n',text_str,no_parts_total);

	% Save text_str:
	pathfilename	= [GV.projectdirectory GV.pp_projectfilename ' - map2stl summary.txt'];
	fileID			= fopen(pathfilename,'w');
	fprintf(fileID,'%s',text_str);
	fclose(fileID);


	%------------------------------------------------------------------------------------------------------------------
	% Export map top view:
	%------------------------------------------------------------------------------------------------------------------

	% Prepare the map top view:
	for i_print=1:size(PP_local.general.printfig_map2d,1)
		if ~isempty(PP_local.general.printfig_map2d(i_print,1).formattype)
			if ~isfield(GV_H,'fig_topview_map')
				GV_H.fig_topview_map	= [];
			end
			if ~isfield(GV_H,'ax_topview_map')
				GV_H.ax_topview_map		= [];
			end
			if isempty(GV_H.fig_topview_map)
				GV_H.fig_topview_map	= figure;
				figure_theme(GV_H.fig_topview_map,'set',[],'light');
			else
				if ~ishandle(GV_H.fig_topview_map)
					GV_H.fig_topview_map	= figure;
					figure_theme(GV_H.fig_topview_map,'set',[],'light');
				end
			end
			clf(GV_H.fig_topview_map,'reset');
			figure_theme(GV_H.fig_topview_map,'set',[],'light');
			set(GV_H.fig_topview_map,'Tag','maplab3d_figure');
			set(GV_H.fig_topview_map,'Name','Topview');
			set(GV_H.fig_topview_map,'NumberTitle','off');
			set(GV_H.fig_topview_map,'Color',[1 1 1]);
			GV_H.ax_topview_map	= axes(GV_H.fig_topview_map);
			hold(GV_H.ax_topview_map,'on');
			axis(GV_H.ax_topview_map,'equal');
			set(GV_H.ax_topview_map,'Box','on');
			set(GV_H.ax_topview_map,'XLim',[PRINTDATA.xmin-GV.tol_1 PRINTDATA.xmax+GV.tol_1]);
			set(GV_H.ax_topview_map,'YLim',[PRINTDATA.ymin-GV.tol_1 PRINTDATA.ymax+GV.tol_1]);
			% xlabel(GV_H.ax_topview_map,'x / mm');
			% ylabel(GV_H.ax_topview_map,'y / mm');
			GV_H.ax_topview_map.XTick		= [];
			GV_H.ax_topview_map.YTick		= [];
			% Set the figure and axis position:
			GV_H.ax_topview_map.Position	= [0 0 1 1];
			xlimits								= GV_H.ax_topview_map.XLim;
			ylimits								= GV_H.ax_topview_map.YLim;
			w_fig									= GV_H.fig_topview_map.Position(3);
			h_fig									= GV_H.fig_topview_map.Position(4);
			if (w_fig/h_fig)>((xlimits(2)-xlimits(1))/(ylimits(2)-ylimits(1)))
				% h_fig		= w_fig/((xlimits(2)-xlimits(1))/(ylimits(2)-ylimits(1)));		% figure becomes greater
				% GV_H.fig_topview_map.Position(4)	= h_fig;
				w_fig		= h_fig*((xlimits(2)-xlimits(1))/(ylimits(2)-ylimits(1)));			% figure becomes smaller
				GV_H.fig_topview_map.Position(3)	= w_fig;
			else
				% w_fig		= h_fig*((xlimits(2)-xlimits(1))/(ylimits(2)-ylimits(1)));		% figure becomes greater
				% GV_H.fig_topview_map.Position(3)	= w_fig;
				h_fig		= w_fig/((xlimits(2)-xlimits(1))/(ylimits(2)-ylimits(1)));			% figure becomes smaller
				GV_H.fig_topview_map.Position(4)	= h_fig;
			end
			if w_fig>h_fig
				GV_H.fig_topview_map.PaperOrientation='landscape';
			else
				GV_H.fig_topview_map.PaperOrientation='portrait';
			end
			% Set the base color:
			colno_base	= find([PP_local.color.prio]==0,1);
			GV_H.ax_topview_map.Color=[1 1 1];						% Same as figure!
			break
		end
	end

	% Plot the map objects:
	method	= 3;
	switch method
		case 1
			% PRINTDATA.obj_top_reg: as printed: same result as case 2 but faster
			for iobj=1:length(PRINTDATA.obj_top_reg.poly)
				if PRINTDATA.obj_top_reg.colno(iobj)==0
					plot(GV_H.ax_topview_map,PRINTDATA.obj_top_reg.poly(iobj),...
						'EdgeColor','k',...
						'EdgeAlpha',1,...
						'FaceAlpha',0);
				else
					plot(GV_H.ax_topview_map,PRINTDATA.obj_top_reg.poly(iobj),...
						'EdgeColor','k',...
						'FaceColor',PP_local.color(PRINTDATA.obj_top_reg.colno(iobj)).rgb/255,...
						'EdgeAlpha',1,...
						'FaceAlpha',1);
				end
			end
		case 2
			% PRINTDATA.obj_top_reg: as printed: same result as case 2 but faster
			for iobj=1:length(PRINTDATA.obj_top_reg.poly)
				if (PRINTDATA.obj_top_reg.srftype(iobj)-mod(PRINTDATA.obj_top_reg.srftype(iobj),100))==300
					% Text:
					if abs(PRINTDATA.obj_top_reg.objprio(iobj)-round(PRINTDATA.obj_top_reg.objprio(iobj)))>GV.tol_1
						% Text background:
						edgecolor		= 'k';
						facecolor		= PP_local.color(PRINTDATA.obj_top_reg.colno(iobj)).rgb/255;
						edgealpha		= 0;
						facealpha		= 0.15;
					else
						% Text foreground:
						edgecolor		= 'k';
						facecolor		= 'k';
						edgealpha		= 1;
						facealpha		= 1;
					end
				else
					% no text:
					if PRINTDATA.obj_top_reg.colno(iobj)==0
						edgecolor		= 'k';
						facecolor		= 'w';
						edgealpha		= 1;
						facealpha		= 0;
					else
						edgecolor		= 'k';
						facecolor		= PP_local.color(PRINTDATA.obj_top_reg.colno(iobj)).rgb/255;
						edgealpha		= 1;
						facealpha		= 0.15;
					end
				end
				plot(GV_H.ax_topview_map,PRINTDATA.obj_top_reg.poly(iobj),...
					'EdgeColor',edgecolor,...
					'FaceColor',facecolor,...
					'EdgeAlpha',edgealpha,...
					'FaceAlpha',facealpha,...
					'LineWidth',0.2);
			end
		case 3
			% Black letters without text background (better readability):

			colno_v		= unique(PRINTDATA.obj_top_reg.colno);
			for icolno_v=1:size(colno_v,1)
				poly_m(icolno_v,1)		= polyshape();		% foreground
				poly_m(icolno_v,2)		= polyshape();		% background
				poly_m(icolno_v,3)		= polyshape();		% foreground text
				poly_m(icolno_v,4)		= polyshape();		% background text
			end
			if length(PRINTDATA.obj_top_reg.poly)>=2
				poly_basecolor		= PRINTDATA.obj_top_reg.poly(2);
			else
				% The map does not contain map objects:
				poly_basecolor		= PRINTDATA.obj_top_reg.poly(1);
			end

			for iobj=3:length(PRINTDATA.obj_top_reg.poly)

				colno			= PRINTDATA.obj_top_reg.colno(iobj);
				icolno_v		= find(colno_v==colno);
				if ((PRINTDATA.obj_top_reg.srftype(iobj)-mod(PRINTDATA.obj_top_reg.srftype(iobj),100))==300)&&...
						(abs(PRINTDATA.obj_top_reg.objprio(iobj)-round(PRINTDATA.obj_top_reg.objprio(iobj)))<GV.tol_1)
					% The object type is text and the priority is a whole number:
					% Text foreground:
					poly_m(icolno_v,3)	= union(poly_m(icolno_v,3),PRINTDATA.obj_top_reg.poly(iobj));
				else
					% no text foreground:
					if colno==1
						% Base color:
						if (PRINTDATA.obj_top_reg.srftype(iobj)-mod(PRINTDATA.obj_top_reg.srftype(iobj),100))==300
							% Text (background):
							poly_basecolor(1,1)			= union(poly_basecolor(1,1),PRINTDATA.obj_top_reg.poly(iobj));
						else
							% Base color and not text (background):
							poly_basecolor(end+1,1)		= PRINTDATA.obj_top_reg.poly(iobj);
						end
					else
						if (abs(PRINTDATA.obj_top_reg.objprio(iobj)-round(PRINTDATA.obj_top_reg.objprio(iobj)))>GV.tol_1)||...
								((PRINTDATA.obj_top_reg.srftype(iobj)-mod(PRINTDATA.obj_top_reg.srftype(iobj),100))==300)
							% The priority is not a whole number:
							% Background or text (background):
							poly_m(icolno_v,2)		= union(poly_m(icolno_v,2),PRINTDATA.obj_top_reg.poly(iobj));
						else
							% The priority is a whole number:
							% Foreground:
							poly_m(icolno_v,1)		= union(poly_m(icolno_v,1),PRINTDATA.obj_top_reg.poly(iobj));
						end
					end
				end
			end

			facealpha		= 0.5;
			linewidth		= 0.1;
			for icolno_v=1:size(colno_v,1)
				colno							= colno_v(icolno_v,1);
				if colno==1
					% Base color:
					plot(GV_H.ax_topview_map,poly_basecolor,...
						'EdgeColor','k',...
						'FaceColor',PP_local.color(colno).rgb/255,...
						'EdgeAlpha',1,...
						'FaceAlpha',facealpha,...
						'LineWidth',linewidth);
				else
					% Background:
					plot(GV_H.ax_topview_map,poly_m(icolno_v,2),...
						'EdgeColor','k',...
						'FaceColor',PP_local.color(colno).rgb/255,...
						'EdgeAlpha',1,...
						'FaceAlpha',facealpha,...
						'LineWidth',linewidth);
					% Foreground:
					plot(GV_H.ax_topview_map,poly_m(icolno_v,1),...
						'EdgeColor','k',...
						'FaceColor',PP_local.color(colno).rgb/255,...
						'EdgeAlpha',1,...
						'FaceAlpha',facealpha,...
						'LineWidth',linewidth);
					% 				% Text background:
					% 				plot(GV_H.ax_topview_map,poly_m(icolno_v,4),...
					% 					'EdgeColor','k',...
					% 					'FaceColor',PP_local.color(colno).rgb/255,...
					% 					'EdgeAlpha',0,...
					% 					'FaceAlpha',facealpha,...
					% 					'LineWidth',linewidth);
				end
				% Text foreground:
				plot(GV_H.ax_topview_map,poly_m(icolno_v,3),...
					'EdgeColor','k',...
					'FaceColor','k',...
					'EdgeAlpha',1,...
					'FaceAlpha',1,...
					'LineStyle','none');
			end


		case 11
			% PRINTDATA.obj_reg: as printed
			for iobj=1:length(PRINTDATA.obj_reg.poly)
				plot(GV_H.ax_topview_map,PRINTDATA.obj_reg.poly(iobj),...
					'EdgeColor','k',...
					'FaceColor',PP_local.color(PRINTDATA.obj_reg.colno(iobj)).rgb/255,...
					'EdgeAlpha',1,...
					'FaceAlpha',1)
			end

		case 12
			% PRINTDATA.obj_union_equalcolors: no texts/symbols visible, if they have the same color as below
			colno_v		= nan(size(PRINTDATA.obj_union_equalcolors));
			colprio_v	= nan(size(PRINTDATA.obj_union_equalcolors));
			for colno=1:size(PRINTDATA.obj_union_equalcolors,1)
				if ~isempty(PP_local.color)
					colno_v(colno,1)			= colno;
					colprio_v(colno,1)		= PP_local.color(colno,1).prio;
				end
			end
			colno_v(isnan(colno_v),:)		= [];
			colprio_v(isnan(colprio_v),:)	= [];
			[colprio_v,i_sort]	= sort(colprio_v);
			colno_v					= colno_v(i_sort);
			for i=1:size(colprio_v,1)
				if numboundaries(PRINTDATA.obj_union_equalcolors(colno_v(i,1),1))>0
					plot(GV_H.ax_topview_map,PRINTDATA.obj_union_equalcolors(colno_v(i,1),1),...
						'EdgeColor','k',...
						'FaceColor',PP_local.color(colno_v(i,1),1).rgb/255,...
						'EdgeAlpha',1,...
						'FaceAlpha',1);
				end
			end
	end
	for tile_no=1:size(GV_H.poly_tiles,1)
		plot(GV_H.ax_topview_map,GV_H.poly_tiles{tile_no,1}.Shape,...
			'LineWidth',0.25,...
			'LineStyle','-',...
			'EdgeColor','k',...
			'FaceColor','w',...
			'EdgeAlpha',1,...
			'FaceAlpha',0);
	end

	% Save and print the map topview:
	filename_fig	= sprintf('%s - map topview',GV.pp_projectfilename);
	savefig(GV_H.fig_topview_map,[map_pathname_stl filename_fig '.fig']);
	for i_print=1:size(PP_local.general.printfig_map2d,1)
		if ~isempty(PP_local.general.printfig_map2d(i_print,1).formattype)
			resolution_str		= sprintf('-r%1.0f',PP_local.general.printfig_map2d(i_print,1).resolution);
			GV_H.fig_topview_map.PaperType			= PP_local.general.printfig_map2d(i_print,1).papertype;
			GV_H.fig_topview_map.PaperPositionMode = 'manual';		% expand the figure size to fill page, before orient!
			if ((PRINTDATA.ymax-PRINTDATA.ymin)/(PRINTDATA.xmax-PRINTDATA.xmin))>1
				orient(GV_H.fig_topview_map,'portrait');
			else
				orient(GV_H.fig_topview_map,'landscape');
			end
			if    strcmp(PP_local.general.printfig_map2d(i_print,1).formattype,'dpdf')||...
					strcmp(PP_local.general.printfig_map2d(i_print,1).formattype,'dps')||...
					strcmp(PP_local.general.printfig_map2d(i_print,1).formattype,'dpsc')||...
					strcmp(PP_local.general.printfig_map2d(i_print,1).formattype,'dpsc2')
				print(GV_H.fig_topview_map,[map_pathname_stl filename_fig],...
					['-' PP_local.general.printfig_map2d(i_print,1).formattype],...
					resolution_str,'-fillpage');				% '-fillpage' / '-bestfit'
			else
				print(GV_H.fig_topview_map,[map_pathname_stl filename_fig],...
					['-' PP_local.general.printfig_map2d(i_print,1).formattype],...
					resolution_str);
			end
		end
	end

catch ME
	errormessage('',ME);
end

