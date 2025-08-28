function create_map_3dpreview(resolution,show_objects,tile_no,icolspec)
% 3D preview of the map
% resolution   = 'original'					--> ELE.elefiltset(ifs,1).zom_mm
% resolution   = 'original_filtered'		--> ELE.elefiltset(ifs,1).zofm_mm
% resolution   = 'interpolated_filtered'	--> ELE.elefiltset(ifs,1).zm_mm
% show_objects =0		Show only the elevation
% show_objects =1		Show a 3D preview of the current map: show objects as lines
% show_objects =2		Show a 3D preview of the current map: show objects as patches
% tile_no      =[]	ask for tile number
% tile_no      =0		show the whole map printout
% tile_no      =5		show tile number 5
% icolspec		=1		tile base settings
% icolspec		=[]	ask for color specification number
% icolspec		=0		Consideration of all filter settings and all polygons in ele:
%							ele.elefiltset(ifs,1).xm_mm
%							ele.elefiltset(ifs,1).ym_mm
%							ele.elefiltset(ifs,1).zm_mm
%							ele.elecolor(colno,1).elepoly(ip,1).eleshape and
%							ele.elecolor(colno,1).elepoly(ip,1).elescint
%							This requires the calculation of the united equal colors.

global APP ELE GV GV_H PP MAP_OBJECTS WAITBAR OSMDATA

try
	
	if isempty(ELE)||isempty(GV)||isempty(PP)||isempty(OSMDATA)
		errormessage(sprintf([...
			'Error:\n',...
			'Before creating a 3D map preview,\n',...
			'you have to load OSM and elevation data.']));
	end
	isvalid_2dmap		= true;
	if isfield(GV_H,'ax_2dmap')
		if ~isvalid(GV_H.ax_2dmap)
			isvalid_2dmap		= false;
		end
	else
		isvalid_2dmap		= false;
	end
	if ~isvalid_2dmap
		errormessage(sprintf([...
			'Error:\n',...
			'Creating a 3D map preview is not possible,\n',...
			'because the 2D map figure does not exist.\n',...
			'Load the project parameters to create the\n',...
			'2D map figure.']));
	end
	
	% Display state:
	t_start_statebusy	= clock;
	display_on_gui('state','Creating 3D preview of the map ...','busy','add');
	
	% Waitbar:
	WAITBAR.t1			= clock;
	
	% Initializations:
	if nargin==0
		if APP.Cre3dPrevSet_re_filtint_Menu.Checked
			resolution			= 'interpolated_filtered';
		elseif APP.Cre3dPrevSet_re_origfilt_Menu.Checked
			resolution			= 'original_filtered';
		else
			resolution			= 'original';
		end
		if APP.Cre3dPrevSet_sh_patches_Menu.Checked
			show_objects		= 2;
		elseif APP.Cre3dPrevSet_sh_lines_Menu.Checked
			show_objects		= 1;
		else
			show_objects		= 0;
		end
		if APP.Cre3dPrevSet_ti_all_Menu.Checked
			tile_no				= 0;
		elseif APP.Cre3dPrevSet_ti_ask_Menu.Checked
			tile_no				= [];
		else
			tile_no				= 1;
		end
		if APP.Cre3dPrevSet_Filtersettings_Tilebase_Menu.Checked
			% Tile base colorspec:
			color_prio_v		= [PP.color.prio];
			icol_tilebase		= find(color_prio_v==0,1);
			icolspec				= PP.color(icol_tilebase,1).spec;
		elseif APP.Cre3dPrevSet_Filtersettings_Ask_Menu.Checked
			icolspec				= [];
		elseif APP.Cre3dPrevSet_Filtersettings_Finalresult_Menu.Checked
			% Consideration of all filter settings and all polygons in ele.elefiltset:
			icolspec				= 0;
		else
			errormessage;
		end
	end
	
	% plot settings:
	if isempty(tile_no)
		% Ask for the tile number:
		prompt		= {sprintf('Enter the tile number to display (1..%g):',size(GV_H.poly_tiles,1))};
		dlgtitle		= 'Enter tile number';
		dims			= 1;
		definput		= {'1'};
		answer		= inputdlg_local(prompt,dlgtitle,dims,definput);
		cancel_create_map_3dpreview	= false;
		if isempty(answer)
			cancel_create_map_3dpreview	= true;
		else
			tile_no	= str2double(answer);
			if ~isscalar(tile_no)
				cancel_create_map_3dpreview	= true;
			else
				if isnan(tile_no)
					cancel_create_map_3dpreview	= true;
				else
					tile_no		= round(tile_no);
					if (tile_no<1)||(tile_no>size(GV_H.poly_tiles,1))
						cancel_create_map_3dpreview	= true;
					end
				end
			end
		end
		if cancel_create_map_3dpreview
			% Display state:
			display_on_gui('state',...
				sprintf('Creating 3D preview of the map ... Canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			return
		end
		tile_no_str	= sprintf('3D preview: tile no %g',tile_no);
	elseif isequal(tile_no,0)
		tile_no_str	= '3D preview: whole map';
	else
		tile_no_str	= sprintf('3D preview: tile no %g',tile_no);
	end
	x	= [OSMDATA.bounds.xmin_mm OSMDATA.bounds.xmax_mm OSMDATA.bounds.xmax_mm OSMDATA.bounds.xmin_mm];
	y	= [OSMDATA.bounds.ymin_mm OSMDATA.bounds.ymin_mm OSMDATA.bounds.ymax_mm OSMDATA.bounds.ymax_mm];
	poly_limits_osmdata	= polyshape(x,y);
	
	
	if isequal(tile_no,0)
		% Show all tiles:
		poly_base_outline		= poly_limits_osmdata;
	else
		% Show only one tile:
		poly_base_outline		= intersect(poly_limits_osmdata,GV_H.poly_tiles{tile_no,1}.Shape);
	end
	
	if    isempty(icolspec)                               &&(...
			strcmp(resolution,'original_filtered')    ||...
			strcmp(resolution,'interpolated_filtered')            )
		% Ask for the tile number:
		prompt		= {sprintf([...
			'Selection of the filter settings:\n',...
			'Enter the color specification number (1..%g):'],size(PP.colorspec,1))};
		dlgtitle		= 'Enter color specification number';
		dims			= 1;
		definput		= {'1'};
		answer		= inputdlg_local(prompt,dlgtitle,dims,definput);
		cancel_create_map_3dpreview	= false;
		if isempty(answer)
			cancel_create_map_3dpreview	= true;
		else
			icolspec	= str2double(answer);
			if ~isscalar(icolspec)
				cancel_create_map_3dpreview	= true;
			else
				if isnan(icolspec)
					cancel_create_map_3dpreview	= true;
				else
					icolspec		= round(icolspec);
					if (icolspec<1)||(icolspec>size(PP.colorspec,1))
						cancel_create_map_3dpreview	= true;
					end
				end
			end
		end
		if cancel_create_map_3dpreview
			% Display state:
			display_on_gui('state',...
				sprintf('Creating 3D preview of the map ... Canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			return
		end
	elseif isequal(icolspec,0)
		% Consideration of all filter settings and all polygons in ele.elefiltset.
	else
		% Tile base colorspec:
		color_prio_v		= [PP.color.prio];
		icol_tilebase		= find(color_prio_v==0,1);
		icolspec				= PP.color(icol_tilebase,1).spec;
	end
	[xlim_tile,ylim_tile]	= boundingbox(poly_base_outline);
	xmin	= xlim_tile(1);
	xmax	= xlim_tile(2);
	ymin	= ylim_tile(1);
	ymax	= ylim_tile(2);
	if isequal(icolspec,0)
		% Consideration of all filter settings and all polygons in ele.elefiltset:
		ifs						= 1;										% Tile base
		colno_interp_ele		= (1:size(PP.color,1))';
		z_topside_legbgd		= GV.legend_z_topside_bgd;
		[poly_legbgd,~,~]		= get_poly_legbgd;
		method					= 'interp2';
		xm_mm						= ELE.elefiltset(ifs,1).xm_mm;
		ym_mm						= ELE.elefiltset(ifs,1).ym_mm;
		zm_mm						= ...			% elevation zq at the query points
			interp_ele(...
			xm_mm,...							% query points xq
			ym_mm,...							% query points yq
			ELE,...								% elevation structure
			colno_interp_ele,...				% color numbers
			z_topside_legbgd,...				% legend background z-value
			poly_legbgd,...					% legend background polygon
			method);								% interpolation method: 'interp2', 'griddata'
		title_str		= sprintf(...
			'%s / superelevation = %g / scale = %g',...
			tile_no_str,...
			PP.general.superelevation,...
			PP.project.scale);
	else
		ifs	= ELE.ifs_v(icolspec,1);
		switch resolution
			case 'original'
				xm_mm				= ELE.elefiltset(ifs,1).xom_mm;
				ym_mm				= ELE.elefiltset(ifs,1).yom_mm;
				zm_mm				= ELE.elefiltset(ifs,1).zom_mm;
			case 'original_filtered'
				xm_mm				= ELE.elefiltset(ifs,1).xofm_mm;
				ym_mm				= ELE.elefiltset(ifs,1).yofm_mm;
				zm_mm				= ELE.elefiltset(ifs,1).zofm_mm;
			case 'interpolated_filtered'
				xm_mm				= ELE.elefiltset(ifs,1).xm_mm;
				ym_mm				= ELE.elefiltset(ifs,1).ym_mm;
				zm_mm				= ELE.elefiltset(ifs,1).zm_mm;
		end
		title_str		= sprintf(...
			'%s / ColSpecNo = %g / superelevation = %g / scale = %g',...
			tile_no_str,...
			icolspec,...
			PP.general.superelevation,...
			PP.project.scale);
	end
	
	inside	= (xm_mm>=xmin)&(xm_mm<=xmax)&(ym_mm>=ymin)&(ym_mm<=ymax);
	cmin		= find(any(inside,1),1,'first');
	cmax		= find(any(inside,1),1,'last');
	rmin		= find(any(inside,2),1,'first');
	rmax		= find(any(inside,2),1,'last');
	zmin		= min(zm_mm(rmin:rmax,cmin:cmax),[],'all');
	zmax		= max(zm_mm(rmin:rmax,cmin:cmax),[],'all');
	title_str		= sprintf([...
		'%s\n',...
		'xmax-xmin = %gmm, ymax-ymin = %gmm, zmax-zmin = %gmm'],...
		title_str,...
		xmax-xmin,...
		ymax-ymin,...
		zmax-zmin);
	if isequal(icolspec,0)
		title_str		= sprintf([...
			'%s\n',...
			'Final result'],...
			title_str);
	else
		switch resolution
			case 'original'
				title_str		= sprintf([...
					'%s\n',...
					'original resolution, no filtering'],...
					title_str);
			case 'original_filtered'
				title_str		= sprintf([...
					'%s\n',...
					'original resolution and filtered: lon/lat filtersize=%g/%g sigma=%g/%g'],...
					title_str,...
					GV.ele_filtset_lon_filtersize(icolspec,1),...
					GV.ele_filtset_lat_filtersize(icolspec,1),...
					GV.ele_filtset_lon_sigma(icolspec,1),...
					GV.ele_filtset_lat_sigma(icolspec,1));
			case 'interpolated_filtered'
				title_str		= sprintf([...
					'%s\n',...
					'filtered and interpolated: lon/lat filtersize=%g/%g sigma=%g/%g\n',...
					'interpolation_method = %s, dxy_ele_mm = %gmm'],...
					title_str,...
					GV.ele_filtset_lon_filtersize(icolspec,1),...
					GV.ele_filtset_lat_filtersize(icolspec,1),...
					GV.ele_filtset_lon_sigma(icolspec,1),...
					GV.ele_filtset_lat_sigma(icolspec,1),...
					PP.general.interpolation_method,...
					PP.general.dxy_ele_mm);
		end
	end
	xv_mm		= xm_mm(:);
	yv_mm		= ym_mm(:);
	k1			= 1:length(xv_mm);
	k2			= [2:length(xv_mm) 1];
	dxymax	= min(abs((xv_mm(k2)+1i*yv_mm(k2))-(xv_mm(k1)+1i*yv_mm(k1))));
	
	% Create a new figure:
	hf=figure;
	figure_theme(hf,'set',[],'light');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','Map3D');
	set(hf,'NumberTitle','off');
	% set(hf,'Color','w');					% do not overwrite the figure theme (light/dark)
	cameratoolbar(hf,'Show');
	ha=axes;
	% set(ha,'Color','w');					% do not overwrite the figure theme (light/dark)
	hold(ha,'on');
	xlabel(ha,'x / mm');
	ylabel(ha,'y / mm');
	zlabel(ha,'z / mm');
	title(title_str,'Interpreter','none');
	
	% plotting:
	switch show_objects
		
		case 0
			% Show a surface plot of the elevation data:
			if(cmax>cmin)&&(rmax>rmin)
				surf(xm_mm(rmin:rmax,cmin:cmax),ym_mm(rmin:rmax,cmin:cmax),zm_mm(rmin:rmax,cmin:cmax),...
					'LineStyle','none');
			end
			
		case 1
			% Copy every object from the map to the new figure, show objects as lines:
			
			if(cmax>cmin)&&(rmax>rmin)
				
				surf(xm_mm(rmin:rmax,cmin:cmax),ym_mm(rmin:rmax,cmin:cmax),zm_mm(rmin:rmax,cmin:cmax),...
					'LineStyle','none',...
					'FaceAlpha',0.7);
				
				imapobj_max	= size(MAP_OBJECTS,1);
				if imapobj_max>0
					
					for imapobj=1:imapobj_max
						if    MAP_OBJECTS(imapobj,1).h(1).Visible
							kmax	= length(MAP_OBJECTS(imapobj,1).h);
							for k=1:kmax
								switch MAP_OBJECTS(imapobj,1).h(k).Type
									
									case 'polygon'
										if    isequal(MAP_OBJECTS(imapobj,1).h(k).EdgeAlpha,GV.visibility.show.edgealpha)&&...
												isequal(MAP_OBJECTS(imapobj,1).h(k).FaceAlpha,GV.visibility.show.facealpha)
											poly_k		= MAP_OBJECTS(imapobj,1).h(k).Shape;
											poly_k		= intersect(poly_base_outline,poly_k);
											ibmax			= numboundaries(poly_k);
											for ib=1:ibmax
												% Waitbar:
												if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
													WAITBAR.t1	= clock;
													if ~isempty(APP)
														progress		= min(imapobj/imapobj_max,1);
														set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
														set(GV_H.text_waitbar,'String',sprintf(...
															'Create 3D map preview: %g/%g %g/%g %g/%g',...
															imapobj,imapobj_max,k,kmax,ib,ibmax));
														drawnow;
													end
												end
												[x,y]		= boundary(poly_k,ib);
												[x,y]		= changeresolution_xy(x,y,dxymax,[],[],0);
												z			= griddata(...
													xm_mm,...							% coordinates of the sample points
													ym_mm,...							% coordinates of the sample points
													zm_mm,...							% values at each sample point
													x,...									% query points
													y,...									% query points
													'linear');							% 'linear', 'nearest', 'natural', 'cubic', 'v4'
												z(isnan(z))	= 0;
												color_rgb	= MAP_OBJECTS(imapobj,1).h(k).FaceColor;
												if ~strcmp(color_rgb,'none')
													color_rgb						= color_rgb_improve(PP,color_rgb);
													check_if_figure_exists(ha);
													plot3(ha,x,y,z,...
														'Color',color_rgb,...
														'LineWidth',1.5,...
														'LineStyle','-');
												else
													check_if_figure_exists(ha);
													plot3(ha,x,y,z,...
														'Color','k',...				% black also OK in a dark theme
														'LineWidth',0.5,...
														'LineStyle','-');
												end
											end
										end
										
									case 'line'
										if    ~isequal(MAP_OBJECTS(imapobj,1).h(k).Color,GV.preview.Color )&&...
												~isequal(MAP_OBJECTS(imapobj,1).h(k).Color,GV.tempprev.Color)
											% Waitbar:
											if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
												WAITBAR.t1	= clock;
												if ~isempty(APP)
													progress		= min(imapobj/imapobj_max,1);
													set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
													set(GV_H.text_waitbar,'String',sprintf(...
														'Create 3D map preview: %g/%g %g/%g',imapobj,imapobj_max,k,kmax));
													drawnow;
												end
											end
											x			= MAP_OBJECTS(imapobj,1).h(k).XData;
											y			= MAP_OBJECTS(imapobj,1).h(k).YData;
											% TFin		= isinterior(poly_base_outline,x,y);
											TFin		= inpolygon(...						% faster than isinterior
												x,...												% query points
												y,...
												poly_base_outline.Vertices(:,1),...		% polygon area
												poly_base_outline.Vertices(:,2));
											x(~TFin)	= nan;
											y(~TFin)	= nan;
											[x,y]		= removeExtraNanSeparators(x,y);
											if ~isempty(x)
												[x,y]		= changeresolution_xy(x,y,dxymax,[],[],0);
												z			= griddata(...
													xm_mm,...							% coordinates of the sample points
													ym_mm,...							% coordinates of the sample points
													zm_mm,...							% values at each sample point
													x,...	% query points
													y,...	% query points
													'linear');							% 'linear', 'nearest', 'natural', 'cubic', 'v4'
												z(isnan(z))	= 0;
												check_if_figure_exists(ha);
												plot3(ha,x,y,z,...
													'Color',MAP_OBJECTS(imapobj,1).h(k).Color,...
													'LineWidth',MAP_OBJECTS(imapobj,1).h(k).LineWidth,...
													'LineStyle',MAP_OBJECTS(imapobj,1).h(k).LineStyle,...
													'Marker',MAP_OBJECTS(imapobj,1).h(k).Marker,...
													'MarkerEdgeColor',MAP_OBJECTS(imapobj,1).h(k).MarkerEdgeColor,...
													'MarkerFaceColor',MAP_OBJECTS(imapobj,1).h(k).MarkerFaceColor,...
													'MarkerSize',MAP_OBJECTS(imapobj,1).h(k).MarkerSize);
											end
										end
										
								end
								drawnow;
							end
						end
					end
					
				end
			end
			
			
			
		case 2
			% Copy every object from the map the the new figure, show objects as patches:
			
			if size(MAP_OBJECTS,1)>0
				
				% plot settings:           Standard:
				edgealpha	= 1;			%	1
				facealpha	= 1;			%	0.35
				linewidth	= 0.5;		%	0.5
				linestyle	= '-';		%	'-'
				
				% Create empty polygons:
				poly_empty				= polyshape([0 2 1],[0 0 1]);
				poly_empty.Vertices	= zeros(0,2);
				
				% Sort objects by priority:
				
				imapobj_v	= find([MAP_OBJECTS.iobj]>=0);
				imapobj_v	= imapobj_v(:);
				iobj_v		= zeros(size(imapobj_v,1),1);
				cono_v		= zeros(size(imapobj_v,1),1);
				prio_v		= zeros(size(imapobj_v,1),1);
				i_delete_v	= false(size(imapobj_v,1),1);
				for i=1:length(imapobj_v)
					imapobj				= imapobj_v(i,1);
					iobj					= MAP_OBJECTS(imapobj,1).iobj;
					iobj_v(i,1)			= iobj;
					if    isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'prio'    )&&...
							isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'color_no')
						prio_v(i,1)			= MAP_OBJECTS(imapobj,1).h(1,1).UserData.prio;
						cono_v(i,1)			= MAP_OBJECTS(imapobj,1).h(1,1).UserData.color_no;
						for k=2:length(MAP_OBJECTS(imapobj,1).h)
							if MAP_OBJECTS(imapobj).h(k,1).UserData.level==0
								% level=0: background:
								cono_v(i,1)			= MAP_OBJECTS(imapobj,1).h(k,1).UserData.color_no;
								break
							end
						end
					else
						i_delete_v(i,1)	= true;
					end
				end
				imapobj_v(i_delete_v,:)	= [];
				iobj_v(i_delete_v,:)		= [];
				cono_v(i_delete_v,:)		= [];
				prio_v(i_delete_v,:)		= [];
				[~,I]			= sort(prio_v);
				iobj_v		= iobj_v(I);
				cono_v		= cono_v(I);
				imapobj_v	= imapobj_v(I);
				
				% Exclude objects with color number =0:
				I				= find(cono_v>0);
				prio_v		= prio_v(I);
				iobj_v		= iobj_v(I);
				cono_v		= cono_v(I);
				imapobj_v	= imapobj_v(I);
				
				% Subtract objects, so that there remains no overlapping:
				mapobjects_union	= [];
				for i=length(imapobj_v):-1:1
					imapobj		= imapobj_v(i,1);
					iobj			= iobj_v(i,1);
					cono			= cono_v(i,1);
					mapobjects_sort(i,1).type	= MAP_OBJECTS(imapobj,1).h(1).Type;
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						WAITBAR.t1	= clock;
						if ~isempty(APP)
							% progress		= min(imapobj/length(imapobj_v),1);
							% set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
							set(GV_H.text_waitbar,'String',sprintf(...
								'Create 3D map preview: preparation: %g/%g',length(imapobj_v)-i+1,length(imapobj_v)));
							drawnow;
						end
					end
					switch MAP_OBJECTS(imapobj,1).h(1).Type
						case 'polygon'
							if    MAP_OBJECTS(imapobj,1).h(1).Visible                                        &&...
									isequal(MAP_OBJECTS(imapobj,1).h(1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
									isequal(MAP_OBJECTS(imapobj,1).h(1).FaceAlpha,GV.visibility.show.facealpha)&&...
									(strcmp(MAP_OBJECTS(imapobj,1).disp,'line')||strcmp(MAP_OBJECTS(imapobj,1).disp,'area'))
								if cono~=0
									mapobjects_sort(i,1).poly	= MAP_OBJECTS(imapobj,1).h(1).Shape;
									mapobjects_sort(i,1).faco	= MAP_OBJECTS(imapobj,1).h(1).FaceColor;
									mapobjects_sort(i,1).edco	= 'none';
									for k=2:length(MAP_OBJECTS(imapobj,1).h)
										mapobjects_sort(i,1).poly	= union(...
											mapobjects_sort(i,1).poly,...
											MAP_OBJECTS(imapobj,1).h(k).Shape);
									end
									if isempty(mapobjects_union)
										mapobjects_union				= mapobjects_sort(i,1).poly;
									else
										mapobjects_union_new			= union(mapobjects_sort(i,1).poly,mapobjects_union);
										mapobjects_sort(i,1).poly	= subtract(mapobjects_sort(i,1).poly,mapobjects_union);
										mapobjects_union				= mapobjects_union_new;
									end
								else
									mapobjects_sort(i,1).poly	= MAP_OBJECTS(imapobj,1).h(1).Shape;
									for k=2:length(MAP_OBJECTS(imapobj,1).h)
										mapobjects_sort(i,1).poly	= union(...
											mapobjects_sort(i,1).poly,...
											MAP_OBJECTS(imapobj,1).h(k).Shape);
									end
									mapobjects_sort(i,1).faco	= 'none';
									mapobjects_sort(i,1).edco	= 'k';
								end
							else
								mapobjects_sort(i,1).poly	= polyshape();
							end
						otherwise
							mapobjects_sort(i,1).poly	= [];
					end
				end
				
				% Plot objects as patches:
				poly_base_outline_buff	= polybuffer(poly_base_outline,1e-6);
				for i=1:length(imapobj_v)
					imapobj	= imapobj_v(i,1);
					iobj		= iobj_v(i,1);
					cono		= cono_v(i,1);
					% Triangulation and plotting:
					switch mapobjects_sort(i,1).type
						case 'polygon'
							poly			= mapobjects_sort(i,1).poly;
							if numboundaries(poly)>0
								poly			= intersect(poly_base_outline,poly);
								poly			= changeresolution_poly(poly,dxymax,[],[]);
								if numboundaries(poly)>0
									if cono>=0
										T	= triang_poly_grid(poly,xm_mm,ym_mm,zm_mm,poly_base_outline_buff);
										F=[T.ConnectivityList(:,1) ...
											T.ConnectivityList(:,2) ...
											T.ConnectivityList(:,3) ...
											T.ConnectivityList(:,1)];
										check_if_figure_exists(ha);
										hp=patch(ha,'faces',F,...
											'vertices',T.Points,...
											'EdgeColor',mapobjects_sort(i,1).edco,...
											'EdgeAlpha',edgealpha,...
											'FaceColor',mapobjects_sort(i,1).faco,...
											'FaceAlpha',facealpha,...
											'LineWidth',linewidth,...
											'LineStyle',linestyle);
										material(hp,'dull');
									else
										ibmax	= numboundaries(poly);
										for ib=1:ibmax
											% Waitbar:
											if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
												WAITBAR.t1	= clock;
												if ~isempty(APP)
													progress		= min(imapobj/length(imapobj_v),1);
													set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
													set(GV_H.text_waitbar,'String',sprintf(...
														'Create 3D map preview: %g/%g %g/%g',...
														i,length(imapobj_v),ib,ibmax));
													drawnow;
												end
											end
											[x,y]			= boundary(poly,ib);
											[x,y]			= changeresolution_xy(x,y,dxymax,[],[],0);
											z				= griddata(...
												xm_mm,...		% coordinates of the sample points
												ym_mm,...		% coordinates of the sample points
												zm_mm,...		% values at each sample point
												x,...				% query points
												y,...				% query points
												'linear');		% 'linear', 'nearest', 'natural', 'cubic', 'v4'
											z(isnan(z))	= 0;
											check_if_figure_exists(ha);
											% black also OK in a dark theme:
											plot3(ha,x,y,z,'Color','k','LineWidth',0.5,'LineStyle','-');
										end
									end
								end
							end
						case 'line'
							% mapobjects_sort contains only color numbers >=0
							% ==> There are no preview lines.
							% if    MAP_OBJECTS(imapobj,1).h.Visible                                        &&...
							% 		isequal(MAP_OBJECTS(imapobj,1).h.EdgeAlpha,GV.visibility.show.edgealpha)&&...
							% 		isequal(MAP_OBJECTS(imapobj,1).h.FaceAlpha,GV.visibility.show.facealpha)
							% 	x			= MAP_OBJECTS(imapobj,1).h.XData;
							% 	y			= MAP_OBJECTS(imapobj,1).h.YData;
							% 	% TFin		= isinterior(poly_base_outline,x,y);
							% 	TFin		= inpolygon(...						% faster than isinterior
							% 		x,...												% query points
							% 		y,...
							% 		poly_base_outline.Vertices(:,1),...		% polygon area
							% 		poly_base_outline.Vertices(:,2));
							% 	x(~TFin)	= nan;
							% 	y(~TFin)	= nan;
							% 	[x,y]		= removeExtraNanSeparators(x,y);
							% 	if ~isempty(x)
							% 		[x,y]		= changeresolution_xy(x,y,dxymax,[],[],0);
							% 		z			= griddata(...
							% 			xm_mm,...							% coordinates of the sample points
							% 			ym_mm,...							% coordinates of the sample points
							% 			zm_mm,...							% values at each sample point
							% 			x,...	% query points
							% 			y,...	% query points
							% 			'linear');							% 'linear', 'nearest', 'natural', 'cubic', 'v4'
							% 		z(isnan(z))	= 0;
							% 		check_if_figure_exists(ha);
							% 		plot3(ha,x,y,z,...
							% 			'Color',MAP_OBJECTS(imapobj,1).h.Color,...
							% 			'LineWidth',MAP_OBJECTS(imapobj,1).h.LineWidth,...
							% 			'LineStyle',MAP_OBJECTS(imapobj,1).h.LineStyle,...
							% 			'Marker',MAP_OBJECTS(imapobj,1).h.Marker,...
							% 			'MarkerEdgeColor',MAP_OBJECTS(imapobj,1).h.MarkerEdgeColor,...
							% 			'MarkerFaceColor',MAP_OBJECTS(imapobj,1).h.MarkerFaceColor,...
							% 			'MarkerSize',MAP_OBJECTS(imapobj,1).h.MarkerSize);
							% 	end
							% end
					end
					drawnow;
				end
				% Triangulation and plotting of the base color:
				colno_base	= find([PP.color.prio]==0,1);
				poly_base	= subtract(poly_base_outline,mapobjects_union);
				poly_base	= intersect(poly_base_outline,poly_base);
				poly_base	= changeresolution_poly(poly_base,dxymax,[],[]);
				if numboundaries(poly_base)>0
					T	= triang_poly_grid(poly_base,xm_mm,ym_mm,zm_mm,poly_base_outline_buff);
					F=[T.ConnectivityList(:,1) ...
						T.ConnectivityList(:,2) ...
						T.ConnectivityList(:,3) ...
						T.ConnectivityList(:,1)];
					check_if_figure_exists(ha);
					hp=patch(ha,'faces',F,...
						'vertices',T.Points,...
						'EdgeColor','none',...
						'EdgeAlpha',edgealpha,...
						'FaceColor',PP.color(colno_base,1).rgb/255,...
						'FaceAlpha',facealpha,...
						'LineWidth',linewidth,...
						'LineStyle',linestyle);
					material(hp,'dull');
				end
				
			end
			
	end
	
	% Show limits and tiles:
	if APP.Cre3dPrevSet_shlimti_Menu.Checked
		
		% tile_no = -1: Limits of the OSM data: These limits cannot be changed.
		[x,y]		= boundary(poly_limits_osmdata);
		% TFin		= isinterior(poly_base_outline,x,y);
		TFin		= inpolygon(...						% faster than isinterior
			x,...												% query points
			y,...
			poly_base_outline.Vertices(:,1),...		% polygon area
			poly_base_outline.Vertices(:,2));
		x(~TFin)	= nan;
		y(~TFin)	= nan;
		[x,y]		= removeExtraNanSeparators(x,y);
		if ~isempty(x)&&~isempty(y)
			[x,y]		= changeresolution_xy(x,y,dxymax,[],[],0);
			z			= griddata(...
				xm_mm,...		% coordinates of the sample points
				ym_mm,...		% coordinates of the sample points
				zm_mm,...		% values at each sample point
				x,...				% query points
				y,...				% query points
				'linear');		% 'linear', 'nearest', 'natural', 'cubic', 'v4'
			z(isnan(z))	= 0;
			check_if_figure_exists(ha);
			plot3(ha,x,y,z,...
				'Color',GV.plotsettings.poly_limits_osmdata.EdgeColor,...
				'LineWidth',GV.plotsettings.poly_limits_osmdata.LineWidth,...
				'LineStyle',GV.plotsettings.poly_limits_osmdata.LineStyle,...
				'Marker','none');
		end
		
		% tile_no = 0: Edges of the map to be printed:
		[x,y]		= boundary(GV_H.poly_map_printout.Shape);
		% TFin		= isinterior(poly_base_outline,x,y);
		TFin		= inpolygon(...						% faster than isinterior
			x,...												% query points
			y,...
			poly_base_outline.Vertices(:,1),...		% polygon area
			poly_base_outline.Vertices(:,2));
		x(~TFin)	= nan;
		y(~TFin)	= nan;
		[x,y]		= removeExtraNanSeparators(x,y);
		if ~isempty(x)&&~isempty(y)
			[x,y]		= changeresolution_xy(x,y,dxymax,[],[],0);
			z			= griddata(...
				xm_mm,...		% coordinates of the sample points
				ym_mm,...		% coordinates of the sample points
				zm_mm,...		% values at each sample point
				x,...				% query points
				y,...				% query points
				'linear');		% 'linear', 'nearest', 'natural', 'cubic', 'v4'
			z(isnan(z))	= 0;
			check_if_figure_exists(ha);
			plot3(ha,x,y,z,...
				'Color',GV_H.poly_map_printout.EdgeColor,...
				'LineWidth',GV_H.poly_map_printout.LineWidth,...
				'LineStyle',GV_H.poly_map_printout.LineStyle,...
				'Marker','none');
		end
		
		% tile_no = i: Edges of the tiles:
		for tile_no=1:size(GV_H.poly_tiles,1)
			[x,y]		= boundary(GV_H.poly_tiles{tile_no,1}.Shape);
			[x,y]		= changeresolution_xy(x,y,dxymax,[],[],0);
			% TFin		= isinterior(poly_base_outline,x,y);
			TFin		= inpolygon(...						% faster than isinterior
				x,...												% query points
				y,...
				poly_base_outline.Vertices(:,1),...		% polygon area
				poly_base_outline.Vertices(:,2));
			x(~TFin)	= nan;
			y(~TFin)	= nan;
			[x,y]		= removeExtraNanSeparators(x,y);
			if ~isempty(x)&&~isempty(y)
				z			= griddata(...
					xm_mm,...		% coordinates of the sample points
					ym_mm,...		% coordinates of the sample points
					zm_mm,...		% values at each sample point
					x,...				% query points
					y,...				% query points
					'linear');		% 'linear', 'nearest', 'natural', 'cubic', 'v4'
				z(isnan(z))	= 0;
				check_if_figure_exists(ha);
				plot3(ha,x,y,z,...
					'Color',GV_H.poly_tiles{tile_no,1}.EdgeColor,...
					'LineWidth',GV_H.poly_tiles{tile_no,1}.LineWidth,...
					'LineStyle',GV_H.poly_tiles{tile_no,1}.LineStyle,...
					'Marker','none');
			end
		end
		
	end
	
	% plot settings:
	set(ha,'XLim',[xmin xmax]);
	set(ha,'YLim',[ymin ymax]);
	view(ha,3);
	axis(ha,'equal');
	% Light from two sides, without reflections:
	el			= 30;
	az			= el;
	hlight1	= light(ha,'Color',[1 1 1]*1);
	lightangle(hlight1,az,el),
	az			= el+180;
	hlight2	= light(ha,'Color',[1 1 1]*0.3);
	lightangle(hlight2,az,el),
	drawnow;
	
	% Reset waitbar:
	if ~isempty(APP)
		set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
		set(GV_H.text_waitbar,'String','');
		drawnow;
	end
	
	% Display state:
	display_on_gui('state',...
		sprintf('Creating 3D preview of the map ... done (%s).',dt_string(etime(clock,t_start_statebusy))),...
		'notbusy','replace');
	
catch ME
	errormessage('',ME);
end


function check_if_figure_exists(ax)
try
	if ~ishandle(ax)
		errormessage(sprintf('Error:\nThe figure has been deleted.'));
	end
catch ME
	errormessage('',ME);
end

