function copy2clipboard_mapobjectstable

global APP MAP_OBJECTS_TABLE MAP_OBJECTS GV ELE GV_H PP

try
	
	% Display state:
	stateisbusy	= display_on_gui('state','','isbusy');
	if ~stateisbusy
		display_on_gui('state','Copy table to clipboard ...','busy','add');
		waitbar_t1		= clock;
	end
	
	% Table to structure array:
	if APP.ShowMapObjectsTable_Menu.Checked
		% The map objects table is enabled:
		mot		= MAP_OBJECTS_TABLE;
	else
		% The map objects table is disabled:
		mot		= display_map_objects;
	end
	map_obj_table		= table2struct(mot);
	
	% Initializations:
	data		= '';
	data		= sprintf('%sPlot objects:\t',data);
	for i=1:8
		data	= sprintf('%s\t',data);
	end
	data		= sprintf('%sOverall dimensions:\t',data);
	for i=1:12
		data	= sprintf('%s\t',data);
	end
	data		= sprintf('%sRegions dimensions:\n',data);
	% data		= sprintf(['%s\t',...
	% 	'PlotNo\t',...				%	 2
	% 	'ObjNo\t',...				%	 3
	% 	'ColNo\t',...				%	 4
	% 	'Description\t',...		%	 5
	% 	'Text\t',...				%	 6
	% 	'Mod\t',...					%	 7
	% 	'Vis\t',...					%	 8
	% 	'Group\t',...				%	 9
	% 	'Nodes\t',...				%	10
	% 	'X\t',...					%	11
	% 	'Y\t',...					%	12
	% 	'DispAs\t',...				%	13
	% 	'\t',...						%	 1
	% 	'Regions\t',...			%	 2
	% 	'xmax\t',...				%	 3
	% 	'ymax\t',...				%	 4
	% 	'zmax\t',...				%	 5
	% 	'xmin\t',...				%	 6
	% 	'ymin\t',...				%	 7
	% 	'zmin\t',...				%	 8
	% 	'Dim x\t',...				%	 9
	% 	'Dim y\t',...				%	10
	% 	'Dim z\t',...				%	11
	% 	'Diag\t',...				%	12
	% 	'Area\t',...				%	13
	% 	'\t',...						%	 1
	% 	'Dim x min\t',...			%	 2
	% 	'Dim y min\t',...			%	 3
	% 	'Dim z min\t',...			%	 4
	% 	'Diag min\t',...			%	 5
	% 	'Area min\t',...			%	 6
	% 	'Dim x max\t',...			%	 7
	% 	'Dim y max\t',...			%	 8
	% 	'Dim z max\t',...			%	 9
	% 	'Diag max\t',...			%	10
	% 	'Area max\n\n'],data);	%	11
	data		= sprintf(['%s\t',...
		'PlotNo\t',...				%	 2
		'ObjNo\t',...				%	 3
		'ColNo\t',...				%	 4
		'Description\t',...		%	 5
		'Text\t',...				%	 6
		'Vis\t',...					%	 7
		'Group\t',...				%	 8
		'DispAs\t',...				%	 9
		'\t',...						%	 1
		'Regions\t',...			%	 2
		'xmax\t',...				%	 3
		'ymax\t',...				%	 4
		'zmax\t',...				%	 5
		'xmin\t',...				%	 6
		'ymin\t',...				%	 7
		'zmin\t',...				%	 8
		'Dim x\t',...				%	 9
		'Dim y\t',...				%	10
		'Dim z\t',...				%	11
		'Diag\t',...				%	12
		'Area\t',...				%	13
		'\t',...						%	 1
		'Dim x min\t',...			%	 2
		'Dim y min\t',...			%	 3
		'Dim z min\t',...			%	 4
		'Diag min\t',...			%	 5
		'Area min\t',...			%	 6
		'Dim x max\t',...			%	 7
		'Dim y max\t',...			%	 8
		'Dim z max\t',...			%	 9
		'Diag max\t',...			%	10
		'Area max\n\n'],data);	%	11
	
	% Total number of regions:
	no_reg_max		= 0;
	for imapobj=1:size(map_obj_table,1)
		for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
			if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
				poly_reg		= regions(MAP_OBJECTS(imapobj,1).h(i,1).Shape);
				no_reg_max		= no_reg_max+size(poly_reg,1);
			end
		end
	end
	
	no_reg			= 0;
	for imapobj=1:size(map_obj_table,1)
		
		%																							Row:
		% Plot objects:												Column:		 1		1
		% 	PlotNo			= map_obj_table(imapobj,1).PlotNo;				%	 2
		% 	ObjNo				= map_obj_table(imapobj,1).ObjNo;				%	 3
		% 	ColNo				= map_obj_table(imapobj,1).ColNo;				%	 4
		% 	Description		= map_obj_table(imapobj,1).Description;		%	 5
		% 	Text				= map_obj_table(imapobj,1).Text;					%	 6
		% 	Mod				= map_obj_table(imapobj,1).Mod;					%	 7
		% 	Vis				= map_obj_table(imapobj,1).Vis;					%	 8
		% 	Group				= map_obj_table(imapobj,1).Group;				%	 9
		% 	Nodes				= map_obj_table(imapobj,1).Nodes;				%	10
		% 	X					= map_obj_table(imapobj,1).X;						%	11
		% 	Y					= map_obj_table(imapobj,1).Y;						%	12
		% 	DispAs			= map_obj_table(imapobj,1).DispAs;				%	13
		PlotNo			= map_obj_table(imapobj,1).PlotNo;				%	 2
		ObjNo				= map_obj_table(imapobj,1).ObjNo;				%	 3
		ColNo				= map_obj_table(imapobj,1).ColNo;				%	 4
		Description		= map_obj_table(imapobj,1).Description;		%	 5
		Text				= map_obj_table(imapobj,1).Text;					%	 6
		Vis				= map_obj_table(imapobj,1).Vis;					%	 7
		Group				= map_obj_table(imapobj,1).Group;				%	 8
		DispAs			= map_obj_table(imapobj,1).DispAs;				%	 9
		
		% Overall dimensions:														1		1
		% noreg_all																		2
		% xmax_all																		3
		% ymax_all																		4
		% zmax_all																		5
		% xmin_all																		6
		% ymin_all																		7
		% zmin_all																		8
		% dimx_all																		9
		% dimy_all																		10
		% dimz_all																		11
		% diag_all																		12
		% area_all																		13
		
		% Initializations:
		% Overall dimensions:
		noreg_all			= 0;
		xyinit				= 1e12;
		xmax_all				= -xyinit;
		ymax_all				= -xyinit;
		zmax_all				= -xyinit;
		xmin_all				= xyinit;
		ymin_all				= xyinit;
		zmin_all				= xyinit;
		% Regions dimensions:													1		1
		dimx_min_reg		= xyinit;												%	2
		dimy_min_reg		= xyinit;												%	3
		dimz_min_reg		= xyinit;												%	4
		diag_min_reg		= xyinit;												%	5
		area_min_reg		= xyinit;												%	6
		dimx_max_reg		= -xyinit;												%	7
		dimy_max_reg		= -xyinit;												%	8
		dimz_max_reg		= -xyinit;												%	9
		diag_max_reg		= -xyinit;												%	10
		area_max_reg		= -xyinit;												%	11
		
		poly_all				= polyshape();
		for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
			colno					= MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no;
			if colno==0
				colno_interp_ele	= 1;			% tile base filter settings
			else
				colno_interp_ele	= colno;
			end
			if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
				poly_reg				= regions(MAP_OBJECTS(imapobj,1).h(i,1).Shape);
				noreg_all			= noreg_all+size(poly_reg,1);
				for ir=1:size(poly_reg,1)
					% Waitbar:
					if ~stateisbusy
						if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
							waitbar_t1	= clock;
							progress		= min(no_reg/no_reg_max,1);
							set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
							drawnow;
						end
					end
					no_reg			= no_reg+1;
					% Current region limits:
					[xlim,ylim]		= boundingbox(poly_reg(ir,1));
					vertices_z		= interp_ele(...
						poly_reg(ir,1).Vertices(:,1),...				% query points x
						poly_reg(ir,1).Vertices(:,2),...				% query points y
						ELE,...												% elevation structure
						colno_interp_ele,...								% color numbers
						GV.legend_z_topside_bgd,...					% legend background z-value
						polyshape(),...									% legend background polygon
						'interp2');											% interpolation method
					if isnan(vertices_z)
						vertices_z	= 999999;
					end
					zlim				= [min(vertices_z) max(vertices_z)];
					% Current region dimensions:
					dimx_reg			= xlim(2)-xlim(1);
					dimy_reg			= ylim(2)-ylim(1);
					dz_reg			= zlim(2)-zlim(1);
					diag_reg			= sqrt(dimx_reg^2+dimy_reg^2);
					area_reg			= area(poly_reg(ir,1));
					% Overall dimensions:
					xmax_all			= max(xmax_all,xlim(2));
					ymax_all			= max(ymax_all,ylim(2));
					zmax_all			= max(zmax_all,zlim(2));
					xmin_all			= min(xmin_all,xlim(1));
					ymin_all			= min(ymin_all,ylim(1));
					zmin_all			= min(zmin_all,zlim(1));
					poly_all			= union(poly_all,poly_reg(ir,1),'KeepCollinearPoints',false);
					% Regions dimensions:
					dimx_max_reg	= max(dimx_max_reg,dimx_reg);
					dimy_max_reg	= max(dimy_max_reg,dimy_reg);
					diag_max_reg	= max(diag_max_reg,diag_reg);
					area_max_reg	= max(area_max_reg,area_reg);
					dimx_min_reg	= min(dimx_min_reg,dimx_reg);
					dimy_min_reg	= min(dimy_min_reg,dimy_reg);
					diag_min_reg	= min(diag_min_reg,diag_reg);
					area_min_reg	= min(area_min_reg,area_reg);
					if (dz_reg>dimz_max_reg)&&(dz_reg>0)
						dimz_max_reg	= dz_reg;
					end
					dimz_min_reg		= min(dimz_min_reg,dz_reg);
				end
			end
		end
		% Overall dimensions:
		dimx_all				= xmax_all-xmin_all;
		dimy_all				= ymax_all-ymin_all;
		dimz_all				= zmax_all-zmin_all;
		diag_all				= sqrt(dimx_all^2+dimy_all^2);
		area_all				= area(poly_all);
		
		% Create data:
		% Plot objects:
		data		= sprintf('%s\t%s',data,number2str(PlotNo,'%g'));
		data		= sprintf('%s\t%s',data,number2str(ObjNo,'%g'));
		data		= sprintf('%s\t%s',data,ColNo);
		data		= sprintf('%s\t%s',data,Description);
		data		= sprintf('%s\t%s',data,Text);
		% data		= sprintf('%s\t%s',data,Mod);
		data		= sprintf('%s\t%s',data,Vis);
		data		= sprintf('%s\t%s',data,Group);
		% data		= sprintf('%s\t%s',data,number2str(Nodes,'%g'));
		% data		= sprintf('%s\t%s',data,number2str(X,'%g'));
		% data		= sprintf('%s\t%s',data,number2str(Y,'%g'));
		data		= sprintf('%s\t%s',data,DispAs);
		data		= sprintf('%s\t',data);
		if ~isequal(xmax_all,-xyinit)
			% Overall dimensions:
			data		= sprintf('%s\t%s',data,number2str(noreg_all,'%g'));
			data		= sprintf('%s\t%s',data,number2str(xmax_all,'%g'));
			data		= sprintf('%s\t%s',data,number2str(ymax_all,'%g'));
			data		= sprintf('%s\t%s',data,number2str(zmax_all,'%g'));
			data		= sprintf('%s\t%s',data,number2str(xmin_all,'%g'));
			data		= sprintf('%s\t%s',data,number2str(ymin_all,'%g'));
			data		= sprintf('%s\t%s',data,number2str(zmin_all,'%g'));
			data		= sprintf('%s\t%s',data,number2str(dimx_all,'%g'));
			data		= sprintf('%s\t%s',data,number2str(dimy_all,'%g'));
			data		= sprintf('%s\t%s',data,number2str(dimz_all,'%g'));
			data		= sprintf('%s\t%s',data,number2str(diag_all,'%g'));
			data		= sprintf('%s\t%s',data,number2str(area_all,'%g'));
			data		= sprintf('%s\t',data);
			% Regions dimensions:
			data		= sprintf('%s\t%s',data,number2str(dimx_min_reg,'%g'));
			data		= sprintf('%s\t%s',data,number2str(dimy_min_reg,'%g'));
			data		= sprintf('%s\t%s',data,number2str(dimz_min_reg,'%g'));
			data		= sprintf('%s\t%s',data,number2str(diag_min_reg,'%g'));
			data		= sprintf('%s\t%s',data,number2str(area_min_reg,'%g'));
			data		= sprintf('%s\t%s',data,number2str(dimx_max_reg,'%g'));
			data		= sprintf('%s\t%s',data,number2str(dimy_max_reg,'%g'));
			data		= sprintf('%s\t%s',data,number2str(dimz_max_reg,'%g'));
			data		= sprintf('%s\t%s',data,number2str(diag_max_reg,'%g'));
			data		= sprintf('%s\t%s',data,number2str(area_max_reg,'%g'));
		end
		data		= sprintf('%s\n',data);
	end
	
	% Copy data to clipboard:
	clipboard('copy',data);
	
	% Display state:
	if ~stateisbusy
		display_on_gui('state','Copy table to clipboard ... done','notbusy','replace');
		set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
		set(GV_H.text_waitbar,'String','');
	end
	
catch ME
	errormessage('',ME);
end

