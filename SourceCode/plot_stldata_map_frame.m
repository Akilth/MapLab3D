function plot_stldata_map_frame(pp,plot_mapobj,create_axis)
% Plots the frame into GV_H.ax_stldata_map
% In this way the overall view of the whole map is updated in map2stl and in frame2stl,
% also if the frame is modified after creating the map.

global GV_H PRINTDATA PP

try
	
	% Initializations:
	if nargin==0
		pp				= PP;
		plot_mapobj	= 1;
		create_axis	= 1;
	end
	if pp.general.savefig_map==0
		return
	end
	tol_1				= 1e-6;
	if isfield(GV_H,'poly_tiles')
		imax_tile		= size(GV_H.poly_tiles,1);
	else
		imax_tile		= -1;
	end
	
	% Only create the axis if the frame is plotted or if the map is plotted in map2stl.m:
	plot_frame		= false;
	if isfield(PRINTDATA,'frame')&&isfield(PRINTDATA,'z_bottom')
		if isfield(PRINTDATA.frame,'tile')
			if isequal(size(PRINTDATA.frame.tile,1),imax_tile)
				plot_frame		= true;
			end
		end
	end
	if ~plot_frame&&(create_axis==0)
		return
	end
	
	% Create the figure if necessary:
	if ~isfield(GV_H,'fig_stldata_map')
		GV_H.fig_stldata_map	= figure;
		figure_theme(GV_H.fig_stldata_map,'set',[],'light');
	else
		if isempty(GV_H.fig_stldata_map)
			GV_H.fig_stldata_map	= figure;
			figure_theme(GV_H.fig_stldata_map,'set',[],'light');
		else
			if ~isvalid(GV_H.fig_stldata_map)
				GV_H.fig_stldata_map	= figure;
				figure_theme(GV_H.fig_stldata_map,'set',[],'light');
			end
		end
	end
	% Create the axis if necessary:
	init_fig_stldata_map	= false;
	if ~isfield(GV_H,'ax_stldata_map')
		GV_H.ax_stldata_map	= axes(GV_H.fig_stldata_map);
		init_fig_stldata_map	= true;
	else
		if isempty(GV_H.ax_stldata_map)
			GV_H.ax_stldata_map	= axes(GV_H.fig_stldata_map);
			init_fig_stldata_map	= true;
		else
			if ~isvalid(GV_H.ax_stldata_map)
				GV_H.ax_stldata_map	= axes(GV_H.fig_stldata_map);
				init_fig_stldata_map	= true;
			else
				if ~isequal(GV_H.fig_stldata_map,GV_H.ax_stldata_map.Parent)
					GV_H.ax_stldata_map	= axes(GV_H.fig_stldata_map);
					init_fig_stldata_map	= true;
				end
			end
		end
	end
	
	% Figure to the foreground:
	figure(GV_H.fig_stldata_map);
	
	% Initialize the figure:
	if init_fig_stldata_map
		set(GV_H.fig_stldata_map,'Tag','maplab3d_figure');
		if imax_tile<=1
			set(GV_H.fig_stldata_map,'Name','3D map: T1');
		else
			set(GV_H.fig_stldata_map,'Name',sprintf('3D map: T%g to T%g',1,imax_tile));
		end
		set(GV_H.fig_stldata_map,'NumberTitle','off');
		cameratoolbar(GV_H.fig_stldata_map,'Show');
		hold(GV_H.ax_stldata_map,'on');
		axis(GV_H.ax_stldata_map,'equal');
		if    isfield(PRINTDATA,'xmin')&&...
				isfield(PRINTDATA,'xmax')&&...
				isfield(PRINTDATA,'ymin')&&...
				isfield(PRINTDATA,'ymax')
			set(GV_H.ax_stldata_map,'XLim',[PRINTDATA.xmin-pp.frame.b2-tol_1 PRINTDATA.xmax+pp.frame.b2+tol_1]);
			set(GV_H.ax_stldata_map,'YLim',[PRINTDATA.ymin-pp.frame.b2-tol_1 PRINTDATA.ymax+pp.frame.b2+tol_1]);
		end
		
		view(GV_H.ax_stldata_map,3);
		xlabel(GV_H.ax_stldata_map,'x / mm');
		ylabel(GV_H.ax_stldata_map,'y / mm');
		zlabel(GV_H.ax_stldata_map,'z / mm');
		% Licht von zwei Seiten, ohne Reflexionen:
		el			= 30;
		az			= el;
		hlight1	= light(GV_H.ax_stldata_map,'Color',[1 1 1]*1);
		lightangle(hlight1,az,el);
		az			= el+180;
		hlight2	= light(GV_H.ax_stldata_map,'Color',[1 1 1]*0.3);
		lightangle(hlight2,az,el);
		
		% Plot the map:
		if    (plot_mapobj~=0)                  &&...
				isfield(PRINTDATA,'tile_no_all_v')&&...
				isfield(PRINTDATA,'no_nonempty_tiles')
			% The map STL files have been already created:
			for i_tile=1:length(PRINTDATA.tile)
				tile_no	= PRINTDATA.tile_no_all_v(i_tile,1);
				if isfield(PRINTDATA.tile(i_tile),'col_stal')
					% stand-alone colors:
					imax_colprio_stal	= length(PRINTDATA.tile(i_tile).col_stal);
					for i_colprio_stal=1:imax_colprio_stal
						colno_stal			= find([pp.color.prio]==PRINTDATA.colprio_visible(i_colprio_stal,1),1);
						color_stal_rgb		= pp.color(colno_stal).rgb/255;
						color_stal_rgb		= color_rgb_improve(pp,color_stal_rgb);
						if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'part_stal')
							imax_part_stal		= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal);
							for i_part_stal=1:imax_part_stal
								if ~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T)
									% figure(GV_H.fig_stldata_map);
									colpartno_str	= sprintf('T%03.0f - C%03.0f P%03.0f',tile_no,colno_stal,i_part_stal);
									F=[PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T.ConnectivityList(:,1) ...
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T.ConnectivityList(:,2) ...
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T.ConnectivityList(:,3) ...
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T.ConnectivityList(:,1)];
									hp=patch(GV_H.ax_stldata_map,'faces',F,...
										'vertices',PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T.Points,...
										'EdgeColor','k','FaceColor',color_stal_rgb,...
										'FaceAlpha',pp.general.savefig_facealpha,...
										'EdgeAlpha',pp.general.savefig_edgealpha,...
										'DisplayName',colpartno_str);
									material(hp,'dull');
								end
								if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal),'col')
									% non-stand-alone colors:
									imax_colprio	= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col);
									for i_colprio=1:imax_colprio
										colno				= find([pp.color.prio]==PRINTDATA.colprio_visible(i_colprio,1),1);
										color_rgb		= pp.color(colno).rgb/255;
										color_rgb		= color_rgb_improve(pp,color_rgb);
										if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio),'part')
											imax_part		= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part);
											for i_part=1:imax_part
												if ~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T)
													% figure(GV_H.fig_stldata_map);
													colpartno_str	= sprintf('T%03.0f - C%03.0f P%03.0f - C%03.0f P%03.0f',tile_no,colno_stal,i_part_stal,colno,i_part);
													F=[PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T.ConnectivityList(:,1) ...
														PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T.ConnectivityList(:,2) ...
														PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T.ConnectivityList(:,3) ...
														PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T.ConnectivityList(:,1)];
													hp=patch(GV_H.ax_stldata_map,'faces',F,...
														'vertices',PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T.Points,...
														'EdgeColor','k','FaceColor',color_rgb,...
														'FaceAlpha',pp.general.savefig_facealpha,...
														'EdgeAlpha',pp.general.savefig_edgealpha,...
														'DisplayName',colpartno_str);
													material(hp,'dull');
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
	
	% Plot the frame:
	if plot_frame
		
		% Figure to the foreground:
		% figure(GV_H.fig_stldata_map);
		
		% Axis limits:
		PRINTDATA.frame.xmin		=  1e10;
		PRINTDATA.frame.xmax		= -1e10;
		PRINTDATA.frame.ymin		=  1e10;
		PRINTDATA.frame.ymax		= -1e10;
		for tile_no=1:imax_tile
			if ~isempty(PRINTDATA.frame.tile(tile_no,1).T)
				PRINTDATA.frame.xmin	= min(PRINTDATA.frame.xmin,min(PRINTDATA.frame.tile(tile_no,1).T.Points(:,1)));
				PRINTDATA.frame.xmax	= max(PRINTDATA.frame.xmax,max(PRINTDATA.frame.tile(tile_no,1).T.Points(:,1)));
				PRINTDATA.frame.ymin	= min(PRINTDATA.frame.ymin,min(PRINTDATA.frame.tile(tile_no,1).T.Points(:,2)));
				PRINTDATA.frame.ymax	= max(PRINTDATA.frame.ymax,max(PRINTDATA.frame.tile(tile_no,1).T.Points(:,2)));
			end
		end
		set(GV_H.ax_stldata_map,'XLim',[PRINTDATA.frame.xmin-tol_1 PRINTDATA.frame.xmax+tol_1]);
		set(GV_H.ax_stldata_map,'YLim',[PRINTDATA.frame.ymin-tol_1 PRINTDATA.frame.ymax+tol_1]);
		
		% Delete old frame plots:
		if isfield(GV_H,'frame_stldata_map')
			for tile_no=1:size(GV_H.frame_stldata_map,1)
				delete(GV_H.frame_stldata_map(tile_no,1));
			end
		end
		
		% Face color:
		colno			= pp.frame.color_no;
		color_rgb	= pp.color(colno).rgb/255;
		color_rgb	= color_rgb_improve(pp,color_rgb);
		
		% Plot the frame:
		for tile_no=1:imax_tile
			if ~isempty(PRINTDATA.frame.tile(tile_no,1).T)
				ud_patch				= [];
				ud_patch.colno		= colno;
				ud_patch.pp_color	= pp.color(colno);
				frame_t_points_offset		= zeros(size(PRINTDATA.frame.tile(tile_no,1).T.Points));
				frame_t_points_offset(:,3)	= PRINTDATA.z_bottom;
				F=[PRINTDATA.frame.tile(tile_no,1).T.ConnectivityList(:,1) ...
					PRINTDATA.frame.tile(tile_no,1).T.ConnectivityList(:,2) ...
					PRINTDATA.frame.tile(tile_no,1).T.ConnectivityList(:,3) ...
					PRINTDATA.frame.tile(tile_no,1).T.ConnectivityList(:,1)];
				GV_H.frame_stldata_map(tile_no,1)	= patch(GV_H.ax_stldata_map,'faces',F,...
					'vertices',PRINTDATA.frame.tile(tile_no,1).T.Points+frame_t_points_offset,...
					'EdgeColor','k',...
					'FaceColor',color_rgb,...
					'FaceAlpha',pp.general.savefig_facealpha,...
					'EdgeAlpha',pp.general.savefig_edgealpha,...
					'DisplayName',sprintf('T%03.0f F',tile_no),...
					'UserData',ud_patch);
				material(GV_H.frame_stldata_map(tile_no,1),'dull');
			end
		end
		
	end
	
catch ME
	errormessage('',ME);
end



