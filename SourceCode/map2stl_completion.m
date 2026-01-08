function map2stl_completion(...
	PP_local,...
	map_pathname_stl,...		% Only required if save_maptopview=true
	save_ppbackup,...
	save_summary,...
	save_maptopview)
% Last steps when the creation of the map STL-files has been finished

global APP PP GV GV_H PRINTDATA OSMDATA

try
	
	% Testing:
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
		map_pathname_stl		= GV.projectdirectory_stl;
		save_ppbackup			= false;
		save_summary			= true;
		save_maptopview		= false;
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Project parameters backup:
	%------------------------------------------------------------------------------------------------------------------
	
	if save_ppbackup
		
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
		
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Summary:
	%------------------------------------------------------------------------------------------------------------------
	
	if save_summary
		
		% Tables:
		%  ─ │ ┌ ┐ └ ┘ ├ ┤ ┬ ┴ ┼
		%  ═ ║ ╔ ╗ ╝ ╚ ╠ ╣ ╦ ╩ ╬
		% ╒ ╓ ╕ ╖ ╘ ╙ ╛ ╜ ╞ ╟ ╡ ╢ ╤ ╥ ╧ ╨ ╫
		% text_str	= sprintf(  '┌───┐\n');
		% text_str	= sprintf('%s│   │\n',text_str);
		% text_str	= sprintf('%s│   │\n',text_str);
		% text_str	= sprintf('%s└───┘\n',text_str);
		
		text_str	= sprintf('%s summary:\n',APP.CreatemapSTLfilesMenu.Text);
		text_str	= sprintf('%sCopy the text to a spreadsheet for better readability (for example Excel).\n',text_str);
		
		
		%------------------------------------------------------------------------------------------------------------------
		% Paths and flenames:
		
		text_str	= sprintf('%s\n',text_str);
		text_str	= sprintf('%sProject parameters:\t%s\n',text_str,GV.pp_pathfilename);
		text_str	= sprintf('%sSaved data:\t%s\n',text_str,[GV.projectdirectory GV.map_filename]);
		text_str	= sprintf('%s\t%s\n',text_str,[GV.projectdirectory GV.mapdata_filename]);
		text_str	= sprintf('%sOSM data:\t%s\n',text_str,GV.osm_pathfilename);
		text_str	= sprintf('%sElevation data:\t%s\n',text_str,GV.ele_pathname);
		
		
		%------------------------------------------------------------------------------------------------------------------
		% General data:
		
		text_str	= sprintf('%s\n',text_str);
		text_str	= sprintf('%sScale:\t%s\n',text_str,number2str(GV.pp_general_scale,'%g'));
		text_str	= sprintf('%sSuperelevation:\t%s\n',text_str,number2str(PP_local.general.superelevation,'%g'));
		if    isfield(PRINTDATA,'xmin')&&isfield(PRINTDATA,'xmax')&&...
				isfield(PRINTDATA,'ymin')&&isfield(PRINTDATA,'ymax')
			text_str	= sprintf('%sMap size:\t%s\twidth / mm\n',text_str,number2str(PRINTDATA.xmax-PRINTDATA.xmin,'%f'));
			text_str	= sprintf('%s\t%s\theight / mm\n',text_str,number2str(PRINTDATA.ymax-PRINTDATA.ymin,'%f'));
			text_str	= sprintf('%s\t%s\txmin / mm\n',text_str,number2str(PRINTDATA.xmin,'%f'));
			text_str	= sprintf('%s\t%s\txmax / mm\n',text_str,number2str(PRINTDATA.xmax,'%f'));
			text_str	= sprintf('%s\t%s\tymin / mm\n',text_str,number2str(PRINTDATA.ymin,'%f'));
			text_str	= sprintf('%s\t%s\tymax / mm\n',text_str,number2str(PRINTDATA.ymax,'%f'));
		end
		if isfield(PRINTDATA,'frame')
			if isfield(PRINTDATA.frame,'xmax')&&isfield(PRINTDATA.frame,'xmin')&&...
					isfield(PRINTDATA.frame,'ymax')&&isfield(PRINTDATA.frame,'ymin')
				text_str	= sprintf('%sFrame size:\t%s\twidth / mm\n',text_str,...
					number2str(PRINTDATA.frame.xmax-PRINTDATA.frame.xmin,'%f'));
				text_str	= sprintf('%s\t%s\theight / mm\n',text_str,...
					number2str(PRINTDATA.frame.ymax-PRINTDATA.frame.ymin,'%f'));
			end
		end
		if isfield(PRINTDATA,'z_bottom')
			text_str	= sprintf('%sBottom side of all tiles:\t%s\tz_bottom_tilebase / mm\n',text_str,...
				number2str(PRINTDATA.z_bottom,'%f'));
		end
		if isfield(GV,'legend_z_topside_bgd')
			text_str	= sprintf('%sLegend: background z-value:\t%s\tz_topside_bgd / mm\n',text_str,...
				number2str(GV.legend_z_topside_bgd,'%f'));
		end
		if isfield(PRINTDATA,'z_bottom_max')
			text_str	= sprintf('%s\t%s\tz_bottom_tilebase maximum value / mm\n',text_str,...
				number2str(PRINTDATA.z_bottom_max,'%f'));
		end
		
		
		%------------------------------------------------------------------------------------------------------------------
		% Lat/lon
		
		if    isfield(PRINTDATA,'xmin')&&isfield(PRINTDATA,'xmax')&&...
				isfield(PRINTDATA,'ymin')&&isfield(PRINTDATA,'ymax')
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
		end
		
		
		%------------------------------------------------------------------------------------------------------------------
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
		
		
		%------------------------------------------------------------------------------------------------------------------
		% List of all files:
		% files.i_tile(i_file,1)
		% files.i_colprio_stal(i_file,1)
		% files.fileno(i_file,1)
		% files.filename_stl{i_file,1}
		% files.area_stal(i_file,1)					0: non stand-alone color
		% files.kmax_part_stal(i_file,1)				0: non stand-alone color
		% files.i_colprio_nonstal(i_file,1)			0: stand-alone color
		% files.area_nonstal(i_file,1)				0: stand-alone color
		
		% Frame:
		files		= struct;
		i_file	= 0;
		colprio_visible_local	= PRINTDATA.colprio_visible;
		if isfield(PRINTDATA,'frame')
			if    isfield(PRINTDATA.frame,'tile')&&...
					isfield(PRINTDATA.frame,'color_no')
				colno_frame			= PRINTDATA.frame.color_no;
				colprio_frame		= PP_local.color(colno_frame,1).prio;
				i_colprio_frame	= find(colprio_visible_local==colprio_frame,1);
				if isempty(i_colprio_frame)
					colprio_visible_local(end+1)	= colprio_frame;
					i_colprio_frame					= length(colprio_visible_local);
				end
				for tile_no=1:size(PRINTDATA.frame.tile,1)
					i_file		= i_file+1;
					files.i_tile(i_file,1)					= tile_no;
					files.i_colprio_stal(i_file,1)		= i_colprio_frame;
					files.fileno(i_file,1)					= 1;
					files.filename_stl{i_file,1}			= PRINTDATA.frame.tile(tile_no,1).filename_stl;
					files.area_stal(i_file,1)				= PRINTDATA.frame.tile(tile_no,1).area;
					files.kmax_part_stal(i_file,1)		= PRINTDATA.frame.tile(tile_no,1).no_regions;
					files.i_colprio_nonstal(i_file,1)	= 0;		% stand-alone color
					files.area_nonstal(i_file,1)			= 0;		% stand-alone color
				end
			end
		end
		if i_file==0
			% No frame has been created yet:
			without_frame_text	= '(without frame)';
		else
			without_frame_text	= '';
		end
		
		% Map:
		if isfield(PRINTDATA,'tile')
			for i_tile=1:length(PRINTDATA.tile)
				
				% Elements of PRINTDATA.tile:
				if isfield(PRINTDATA.tile(i_tile),'col_stal')
					if ~isempty(PRINTDATA.tile(i_tile).col_stal)
						for i_colprio_stal=1:length(PRINTDATA.tile(i_tile).col_stal)
							
							% Elements of PRINTDATA.tile(i_tile).col_stal:
							if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'file')
								if ~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file)
									for fileno=1:length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file)
										
										% Elements of PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file:
										
										% Stand-alone color:
										if    isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno),'i_part_stal_v')&&...
												isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno),'area')         &&...
												isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno),'filename_stl')
											if    ~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).i_part_stal_v)&&...
													~isequal(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).area,0)       &&...
													~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).filename_stl)
												i_file		= i_file+1;
												files.i_tile(i_file,1)					= i_tile;
												files.i_colprio_stal(i_file,1)		= i_colprio_stal;
												files.fileno(i_file,1)					= fileno;
												files.filename_stl{i_file,1}			= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).filename_stl;
												files.area_stal(i_file,1)				= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).area;
												files.kmax_part_stal(i_file,1)		= size(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).i_part_stal_v,1);
												files.i_colprio_nonstal(i_file,1)	= 0;		% stand-alone color
												files.area_nonstal(i_file,1)			= 0;		% stand-alone color
											end
										end
										
										% Non stand-alone colors:
										if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno),'col')
											if ~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).col)
												for i_colprio=1:length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).col)
													if    isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).col(i_colprio),'area')        &&...
															isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).col(i_colprio),'filename_stl')
														if 	~isequal(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).col(i_colprio).area,0)      &&...
																~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).col(i_colprio).filename_stl)
															i_file		= i_file+1;
															files.i_tile(i_file,1)					= i_tile;
															files.i_colprio_stal(i_file,1)		= i_colprio_stal;
															files.fileno(i_file,1)					= fileno;
															files.filename_stl{i_file,1}			= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).col(i_colprio).filename_stl;
															files.area_stal(i_file,1)				= 0;		% non stand-alone color
															files.kmax_part_stal(i_file,1)		= 0;		% non stand-alone color
															files.i_colprio_nonstal(i_file,1)	= i_colprio;
															files.area_nonstal(i_file,1)			= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).file(fileno).col(i_colprio).area;
														end
													end
												end
											end
										end
										
									end
								end
							end
							
						end
					end
				end
				
			end
		end
		
		
		%------------------------------------------------------------------------------------------------------------------
		% Colors:
		
		text_str	= sprintf('%s\n',text_str);
		text_str	= sprintf('%sUsed colors (Estimation of material requirements):\n',text_str);
		text_str	= sprintf('%s\t\tColor\tColor\tColor\tColor\t\t\tColor\tPieces\tArea\n',text_str);
		text_str	= sprintf('%s\t\tDescription\tBrand\tShort text\tstand-alone\t\t\tnon stand-alone\t\tmm^2\n',text_str);
		no_parts_total	= 0;
		for i_colprio=1:size(colprio_visible_local,1)
			
			colprio				= colprio_visible_local(i_colprio);
			colno					= find([PP_local.color.prio]==colprio,1);
			if PP_local.color(colno,1).standalone_color~=0
				colno_stal_str			= sprintf('%1.0f',colno);
				colno_nonstal_str		= '';
			else
				colno_stal_str			= '';
				colno_nonstal_str		= sprintf('%1.0f',colno);
			end
			area_col	= 0;
			no_parts	= 0;
			
			% Stand-alone colors:
			i_file_v		= find(files.i_colprio_stal==i_colprio);
			for k=1:size(i_file_v,1)
				i_file		= i_file_v(k,1);
				area_col		= area_col+files.area_stal(i_file,1);
				no_parts		= no_parts+files.kmax_part_stal(i_file,1);
			end
			
			% Non stand-alone colors:
			i_file_v		= find(files.i_colprio_nonstal==i_colprio);
			for k=1:size(i_file_v,1)
				i_file		= i_file_v(k,1);
				area_col		= area_col+files.area_nonstal(i_file,1);
			end
			
			% Add data to text_str:
			no_parts_total	= no_parts_total+no_parts;
			text_str	= sprintf('%s\t\t%s\t%s\t%s\t%s\t\t\t%s\t%1.0f\t%s\n',...
				text_str,...
				PP_local.color(colno,1).description,...
				PP_local.color(colno,1).brand,...
				PP_local.color(colno,1).color_short_text,...
				colno_stal_str,...
				colno_nonstal_str,...
				no_parts,...
				number2str(area_col,'%1.0f'));
			
		end
		text_str	= sprintf('%s\t\t\t\t\t\t\t\tSum:\t%1.0f\t%s\n',text_str,...
			no_parts_total,...
			without_frame_text);
		
		
		%------------------------------------------------------------------------------------------------------------------
		% Files:
		
		% file rank for sorting:
		% rank: [files.i_colprio_stal files.i_tile files.fileno files.i_colprio_nonstal]
		i_colprio_nonstal_max	= 10^ceil(log10(max(files.i_colprio_nonstal)));
		fileno_max					= 10^ceil(log10(max(files.fileno)));
		i_tile_max					= 10^ceil(log10(max(files.i_tile)));
		rank							= ...
			files.i_colprio_nonstal + ...
			files.fileno            *(i_colprio_nonstal_max) + ...
			files.i_tile            *(i_colprio_nonstal_max*fileno_max) + ...
			files.i_colprio_stal    *(i_colprio_nonstal_max*fileno_max*i_tile_max);
		
		% Add data to text_str:
		text_str					= sprintf('%s\n',text_str);
		text_str					= sprintf('%sFiles (Creation of a checklist for printing):\n',text_str);
		text_str					= sprintf('%sFilename\tPrint\tColor\tColor\tColor\tColor\tTile\tFile\tColor\tPieces\tArea\n',text_str);
		text_str					= sprintf('%s\t\tDescription\tBrand\tShort text\tstand-alone\t\t\tnon stand-alone\t\tmm^2\n',text_str);
		no_parts_total			= 0;
		[~,i_file_sort_v]		= sort(rank);
		printno					= 0;
		colprio_stal_last		= 0;
		i_tile_last				= 0;
		fileno_last				= 0;
		for k=1:size(i_file_sort_v,1)
			i_file					= i_file_sort_v(k,1);
			
			% Stand-alone color number:
			colprio_stal_i_file			= colprio_visible_local(files.i_colprio_stal(i_file,1),1);
			colno_stal_i_file				= find([PP_local.color.prio]==colprio_stal_i_file,1);
			colno_stal_i_file_str		= sprintf('%1.0f',colno_stal_i_file);
			
			% Area, number of parts and non stand-alone color number:
			colno_nonstal_i_file_str	= '';
			if files.area_stal(i_file,1)~=0
				% The color of the current file is stand-alone:
				colno_i_file					= colno_stal_i_file;
				area_i_file						= files.area_stal(i_file,1);
				no_parts_i_file				= files.kmax_part_stal(i_file,1);
				if files.area_nonstal(i_file,1)~=0
					errormessage;
				end
			elseif (files.area_nonstal(i_file,1)     ~=0)&&...
					( files.i_colprio_nonstal(i_file,1)>=1)
				% The color of the current file is non stand-alone:
				colprio_nonstal_i_file		= colprio_visible_local(files.i_colprio_nonstal(i_file,1),1);
				colno_nonstal_i_file			= find([PP_local.color.prio]==colprio_nonstal_i_file,1);
				colno_nonstal_i_file_str	= sprintf('%1.0f',colno_nonstal_i_file);
				colno_i_file					= colno_nonstal_i_file;
				area_i_file						= files.area_nonstal(i_file,1);
				no_parts_i_file				= 0;
				if files.area_stal(i_file,1)~=0
					errormessage;
				end
			else
				errormessage;
			end
			
			% Print consecutive number:
			if    ~isequal(colprio_stal_last,colprio_stal_i_file)||...
					~isequal(i_tile_last,files.i_tile(i_file,1))   ||...
					~isequal(fileno_last,files.fileno(i_file,1))
				printno		= printno+1;
				printno_str	= sprintf('%1.0f',printno);
			else
				printno_str	= ' ';
			end
			colprio_stal_last		= colprio_stal_i_file;
			i_tile_last				= files.i_tile(i_file,1);
			fileno_last				= files.fileno(i_file,1);
			
			% Add data to text_str:
			text_str	= sprintf('%s%s\t%s\t%s\t%s\t%s\t%s\t%1.0f\t%1.0f\t%s\t%1.0f\t%s\n',text_str,...
				files.filename_stl{i_file,1},...
				printno_str,...
				PP_local.color(colno_i_file,1).description,...
				PP_local.color(colno_i_file,1).brand,...
				PP_local.color(colno_i_file,1).color_short_text,...
				colno_stal_i_file_str,...
				files.i_tile(i_file,1),...
				files.fileno(i_file,1),...
				colno_nonstal_i_file_str,...
				no_parts_i_file,...
				number2str(area_i_file,'%1.0f'));
			no_parts_total	= no_parts_total+no_parts_i_file;
			
		end
		text_str	= sprintf('%s\t\t\t\t\t\t\t\tSum:\t%1.0f\t%s\n',text_str,...
			no_parts_total,...
			without_frame_text);
		
		% Testing:
		if nargin==0
			clipboard('copy',text_str)
		end
		
		
		%------------------------------------------------------------------------------------------------------------------
		% Save text_str:
		
		pathfilename	= [GV.projectdirectory GV.pp_projectfilename ' - map2stl summary.txt'];
		fileID			= fopen(pathfilename,'w');
		fprintf(fileID,'%s',text_str);
		fclose(fileID);
		
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Export map top view:
	%------------------------------------------------------------------------------------------------------------------
	
	if save_maptopview
		
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
		
	end
	
catch ME
	errormessage('',ME);
end

