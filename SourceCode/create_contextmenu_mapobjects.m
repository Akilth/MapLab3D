function [poly_outside_spec,...
	poly_dzmax,...
	xy_liwimin,...
	xy_liwimax]=create_contextmenu_mapobjects(...
	imapobj_v,...
	clicked_object,...
	intersectionpoint)
% Create a context menu for the map object MAP_OBJECTS(imapobj_v,1)
% imapobj_v can be a scalar or a vector.

global MAP_OBJECTS PP GV_H GV ELE APP

try
	
	poly_outside_spec	= polyshape();
	poly_dzmax			= polyshape();
	xy_liwimin			= zeros(0,2);
	xy_liwimax			= zeros(0,2);
	if isempty(MAP_OBJECTS)||isempty(PP)
		return
	end
	if nargin<2
		intersectionpoint	= [0 0 0];
	end
	if nargin<1
		for imapobj=1:size(MAP_OBJECTS,1)
			create_contextmenu_mapobjects(imapobj,clicked_object,intersectionpoint);
		end
		return
	end
	if length(imapobj_v)>1
		for i=1:length(imapobj_v)
			create_contextmenu_mapobjects(imapobj_v(i),clicked_object,intersectionpoint);
		end
		return
	else
		imapobj	= imapobj_v;
	end
	
	% Initializations:
	if ~isempty(imapobj_v)
		% iobj:
		iobj		= MAP_OBJECTS(imapobj,1).iobj;
		% colno:
		if iobj>=0
			colno	= [];
			if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'color_no')
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					colno		= [colno MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no];
				end
			end
			colno	= unique(colno);
		end
	end
	
	% Context menu:
	hcmenu	= uicontextmenu(GV_H.fig_2dmap);
	
	% Intersection point:
	colno								= (1:size(PP.color,1))';
	[poly_legbgd,~,~]				= get_poly_legbgd;
	intersectionpoint_z			= interp_ele(...
		intersectionpoint(1,1),...						% query points x
		intersectionpoint(1,2),...						% query points y
		ELE,...												% elevation structure
		colno,...											% color numbers
		GV.legend_z_topside_bgd,...					% legend background z-value
		poly_legbgd,...									% legend background polygon
		'interp2');											% interpolation method
	% Conversion of the elevation from model scale (unit mm), to real scale:
	intersectionpoint_z_m_	= intersectionpoint_z/1000*PP.project.scale/PP.general.superelevation;
	firstentry=uimenu(hcmenu,'Label',sprintf('x = %gmm',intersectionpoint(1,1)));
	uimenu(hcmenu,'Label',sprintf('y = %gmm',intersectionpoint(1,2)));
	if any(isnan(intersectionpoint_z))
		uimenu(hcmenu,'Label',sprintf('z = ?'));
	else
		uimenu(hcmenu,'Label',sprintf('z = %gmm (%1.1fm)',...
			intersectionpoint_z,...
			intersectionpoint_z_m_));
	end
	% In 2025a, the color scheme is not always applied to context menus.
	% Therefore, the text color used by default is saved as the standard color here:
	textfgdcolor_default		= firstentry.ForegroundColor;
	
	if isempty(imapobj_v)
		set(clicked_object,'uicontextmenu',hcmenu);
		return
	end
	
	% PlotNo:
	uimenu(hcmenu,'Label',sprintf('PlotNo = %g',imapobj),'Separator','on');
	
	% ObjNo:
	if iobj>=0
		dscr_obj	= MAP_OBJECTS(imapobj,1).dscr;
		uimenu(hcmenu,'Label',sprintf('ObjNo = %g (%s)',iobj,dscr_obj));
	end
	
	% Text/Tag:
	if iobj>=0
		for itext=1:size(MAP_OBJECTS(imapobj,1).text,1)
			if itext==1
				text_tag	= MAP_OBJECTS(imapobj,1).text{itext,1};
			else
				text_tag	= strcat(...
					text_tag," ",MAP_OBJECTS(imapobj,1).text{itext,1});
			end
		end
		text_tag	= char(text_tag);
		if ~isempty(text_tag)
			uimenu(hcmenu,'Label',sprintf('Text/Tag = %s',text_tag));
		end
	elseif MAP_OBJECTS(imapobj,1).cnuc~=0
		dscr_col	= sprintf('%s %s',...
			PP.color(MAP_OBJECTS(imapobj,1).cnuc,1).brand,...
			PP.color(MAP_OBJECTS(imapobj,1).cnuc,1).color_short_text);
		uimenu(hcmenu,'Label',sprintf('ColNo = %g (%s)',MAP_OBJECTS(imapobj,1).cnuc,dscr_col));
	end
	
	% DispAs:
	label_str		= sprintf('DispAs = %s',MAP_OBJECTS(imapobj,1).disp);
	if strcmp(MAP_OBJECTS(imapobj,1).disp,'line')
		[~,~,~,~,...
			liwi_min,...								% constant line width or minimum line width
			liwi_max,...								% constant line width or maximum line width
			~,~,~...
			]	= line2poly(...
			[],...										% x
			[],...										% y
			PP.obj(iobj).linepar,...				% par
			PP.obj(iobj).linestyle,...				% style
			iobj);										% iobj
		if liwi_min==liwi_max
			label_str		= sprintf('%s / Linewidth = %g mm',label_str,liwi_min);
		else
			label_str		= sprintf('%s / Linewidth = %g mm ... %g mm',label_str,liwi_min,liwi_max);
		end
	end
	uimenu(hcmenu,'Label',label_str);
	
	% Text character style:
	chstno			= zeros(size(MAP_OBJECTS(imapobj,1).h,1),1);
	for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
		if    isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'chstno')&&...
				~isempty(MAP_OBJECTS(imapobj,1).h(i,1).UserData.chstno)
			chstno(i,1)	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.chstno;
		end
	end
	chstno		= unique(chstno);
	if length(chstno)==1
		if chstno>0
			label_str	= sprintf('Character style No. %g (%s)',chstno,PP.charstyle(chstno,1).description);
			uimenu(hcmenu,'Label',label_str,'Separator','on');
		end
	end
	
	% Symbol number and symbol tag:
	isym			= zeros(size(MAP_OBJECTS(imapobj,1).h,1),1);
	tag_symbol	= '';
	for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
		if    isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'isym'      )&&...
				isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'tag_symbol')
			isym(i,1)	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.isym;
			if i==1
				tag_symbol	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.tag_symbol;
			else
				if ~isequal(tag_symbol,MAP_OBJECTS(imapobj,1).h(i,1).UserData.tag_symbol)
					tag_symbol	= '';
					break
				end
			end
		else
			tag_symbol	= '';
			break
		end
	end
	isym		= unique(isym);
	if length(isym)==1
		if (isym>0)&&~isempty(tag_symbol)
			label_str	= sprintf('Symbol No. %g (%s)',isym,tag_symbol);
			uimenu(hcmenu,'Label',label_str,'Separator','on');
		end
	end
	
	% ColNo:
	if iobj>=0
		if (length(colno)>=1)&&(length(colno)<=2)
			if ~isequal(colno,0)
				if length(colno)==1
					label_str	= sprintf('ColNo: %g (%s %s)',...
						colno,...
						PP.color(colno,1).brand,...
						PP.color(colno,1).color_short_text);
				else
					if ~any(colno==0)
						label_str	= sprintf('ColNo: %g, %g (%s, %s)',...
							colno(1),...
							colno(2),...
							PP.color(colno(1),1).color_short_text,...
							PP.color(colno(2),1).color_short_text);
					else
						label_str	= sprintf('ColNo: %g, %g',...
							colno(1),...
							colno(2));
					end
				end
				uimenu(hcmenu,'Label',label_str,'Separator','on');
			else
				uimenu(hcmenu,'Label','ColNo = 0 (transparent, color of the object below)','Separator','on');
			end
		end
	end
	
	% ObjPrio:
	if iobj>=0
		prio	= [];
		if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'prio')
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				prio		= [prio MAP_OBJECTS(imapobj,1).h(i,1).UserData.prio];
			end
		end
		prio	= unique(prio);
		if (length(prio)>=1)&&(length(prio)<=2)
			if length(prio)==1
				label_str	= sprintf('Prio: %s',num2str(prio));
			else
				label_str	= sprintf('Prio: %s, %s',num2str(prio(1)),num2str(prio(2)));
			end
			uimenu(hcmenu,'Label',label_str);
		end
	end
	
	% dz:
	if iobj>=0
		dz	= [];
		if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'dz')
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				dz		= [dz MAP_OBJECTS(imapobj,1).h(i,1).UserData.dz];
			end
		end
		dz	= unique(dz);
		if (length(dz)>=1)&&(length(dz)<=2)
			if length(dz)==1
				label_str	= sprintf('dz: %s mm',num2str(dz));
			else
				label_str	= sprintf('dz: %s mm, %s mm',num2str(dz(1)),num2str(dz(2)));
			end
			uimenu(hcmenu,'Label',label_str);
		end
	end
	
	% surftype:
	if iobj>=0
		surftype	= [];
		if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'surftype')
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				surftype		= [surftype MAP_OBJECTS(imapobj,1).h(i,1).UserData.surftype];
			end
		end
		surftype	= unique(surftype);
		if (length(surftype)>=1)&&(length(surftype)<=2)
			if length(surftype)==1
				label_str	= sprintf('surftype: %s',...
					num2str(mod(surftype,100)));
			else
				label_str	= sprintf('surftype: %s, %s',...
					num2str(mod(surftype(1),100)),...
					num2str(mod(surftype(2),100)));
			end
			uimenu(hcmenu,'Label',label_str);
		end
	end
	
	% Rotation:
	rotation_v		= [];
	for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
		if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'rotation')
			rotation_v		= [rotation_v;MAP_OBJECTS(imapobj,1).h(i,1).UserData.rotation];
		end
	end
	rotation_v		= unique(rotation_v);
	if length(rotation_v)==1
		rotation_label	= sprintf('Rotation = %g°',rotation_v(1));
	elseif length(rotation_v)>=2
		rotation_label	= sprintf('Rotation = %g° ... %g°',min(rotation_v),max(rotation_v));
	end
	if ~isempty(rotation_v)
		if ~isequal(rotation_v,0)
			uimenu(hcmenu,'Label',rotation_label,'Separator','on');
		end
	end
	
	% Relation ID:
	relid_v						= uint64([]);
	mapobject_is_preview		= true;
	for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
		if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'relid')
			relid_v		= [relid_v;MAP_OBJECTS(imapobj,1).h(i,1).UserData.relid];
		end
		if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'line')
			if  ~(contains(lower(MAP_OBJECTS(imapobj,1).disp),'preview'          )||...
					contains(lower(MAP_OBJECTS(imapobj,1).disp),'area - not closed')     )||...
					~isequal(MAP_OBJECTS(imapobj,1).h(i,1).Color    ,GV.preview.Color    )||...
					~isequal(MAP_OBJECTS(imapobj,1).h(i,1).LineWidth,GV.preview.LineWidth)
				mapobject_is_preview		= false;
			end
		end
		if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
			if  ~(contains(lower(MAP_OBJECTS(imapobj,1).disp),'preview'          )||...
					contains(lower(MAP_OBJECTS(imapobj,1).disp),'area - not closed')     )||...
					~isequal(MAP_OBJECTS(imapobj,1).h(i,1).EdgeColor    ,GV.preview.Color)||...
					~isequal(MAP_OBJECTS(imapobj,1).h(i,1).LineWidth,GV.preview.LineWidth)
				mapobject_is_preview		= false;
			end
		end
	end
	if mapobject_is_preview
		% The selected object is a preview line or polygon
		if isempty(relid_v)
			relid_v	= uint64(0);
		else
			relid_v	= unique(relid_v);
		end
		if isscalar(relid_v)
			label_str	= sprintf('Relation ID: %s',num2str(relid_v));
		elseif length(relid_v)==2
			label_str	= sprintf('Relation ID: %s, %s ',...
				num2str(min(relid_v)),...
				num2str(max(relid_v)));
		else
			label_str	= sprintf('Relation ID: %s .. %s (no: %s)',...
				num2str(min(relid_v)),...
				num2str(max(relid_v)),...
				num2str(length(relid_v)));
		end
		item_set_relation_id		= uimenu(hcmenu,'Label',label_str,'Separator','on');
		uimenu(item_set_relation_id,...
			'Label',sprintf('Change'),...
			'MenuSelectedFcn',@(src,event)plot_modify('change_relid',imapobj,relid_v(1)));
	end
	
	% Number of regions:
	if strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'polygon')
		
		% Size:
		if MAP_OBJECTS(imapobj,1).cnuc~=0
			icolspec_cnuc	= PP.color(MAP_OBJECTS(imapobj,1).cnuc,1).spec;
			maxdimx			= PP.colorspec(icolspec_cnuc,1).cut_into_pieces.maxdimx;
			maxdimy			= PP.colorspec(icolspec_cnuc,1).cut_into_pieces.maxdimy;
			maxdiag			= PP.colorspec(icolspec_cnuc,1).cut_into_pieces.maxdiag;
			mindimx			= PP.colorspec(icolspec_cnuc,1).cut_into_pieces.mindimx;
			mindimy			= PP.colorspec(icolspec_cnuc,1).cut_into_pieces.mindimy;
			mindiag			= PP.colorspec(icolspec_cnuc,1).cut_into_pieces.mindiag;
			maxdimz			= PP.colorspec(icolspec_cnuc,1).simplify_map.divlines_dzmax+...
				2*            PP.colorspec(icolspec_cnuc,1).simplify_map.divlines_dzmin;
		else
			maxdimx			= 1e10;
			maxdimy			= 1e10;
			maxdiag			= 1e10;
			mindimx			= -1e10;
			mindimy			= -1e10;
			mindiag			= -1e10;
			maxdimz			= 1e10;
		end
		xmax				= -1e10;
		ymax				= -1e10;
		xmin				= 1e10;
		ymin				= 1e10;
		wmax				= -1e10;
		hmax				= -1e10;
		dmax				= -1e10;
		wmin				= 1e10;
		hmin				= 1e10;
		dmin				= 1e10;
		zmax				= -1e10;
		zmin				= 1e10;
		dzmax				= -1e10;
		dzmin				= 1e10;
		xywmax			= [0 0];
		xyhmax			= [0 0];
		xydmax			= [0 0];
		xydzmax			= [0 0];
		xywmin			= [0 0];
		xyhmin			= [0 0];
		xydmin			= [0 0];
		xydzmin			= [0 0];
		ir_zoom_0		= [GV_H.ax_2dmap.XLim(1) GV_H.ax_2dmap.YLim(1) GV_H.ax_2dmap.XLim(2) GV_H.ax_2dmap.YLim(2)];
		ir_zoom			= ir_zoom_0;
		z_wmax			= ir_zoom_0;
		z_hmax			= ir_zoom_0;
		z_dmax			= ir_zoom_0;
		z_dzmax			= ir_zoom_0;
		z_wmin			= ir_zoom_0;
		z_hmin			= ir_zoom_0;
		z_dmin			= ir_zoom_0;
		z_dzmin			= ir_zoom_0;
		no_regions			= 0;
		for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
			poly_reg				= regions(MAP_OBJECTS(imapobj,1).h(i,1).Shape);
			no_regions			= no_regions+size(poly_reg,1);
			if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'color_no')
				colno_i				= MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no;
				if colno_i>0
					colno_interp_ele_i		= colno_i;
				else
					colno_interp_ele_i		= 1;					% tile base filter settings
				end
			else
				colno_interp_ele_i		= 1;						% tile base filter settings
			end
			for ir=1:size(poly_reg,1)
				[xlim,ylim]		= boundingbox(poly_reg(ir,1));
				[xc,yc]			= centroid(poly_reg(ir,1));
				ir_zoom([1 3])	= xlim+[-1 1]*(xlim(2)-xlim(1))*0.5;
				ir_zoom([2 4])	= ylim+[-1 1]*(ylim(2)-ylim(1))*0.5;
				vertices_z		= interp_ele(...
					poly_reg(ir,1).Vertices(:,1),...				% query points x
					poly_reg(ir,1).Vertices(:,2),...				% query points y
					ELE,...												% elevation structure
					colno_interp_ele_i,...							% color numbers
					GV.legend_z_topside_bgd,...					% legend background z-value
					poly_legbgd,...									% legend background polygon
					'interp2');											% interpolation method
				if isnan(vertices_z)
					vertices_z	= 999999;
				end
				zlim				= [min(vertices_z) max(vertices_z)];
				xmax				= max(xmax,xlim(2));
				ymax				= max(ymax,ylim(2));
				zmax				= max(zmax,zlim(2));
				xmin				= min(xmin,xlim(1));
				ymin				= min(ymin,ylim(1));
				zmin				= min(zmin,zlim(1));
				w					= xlim(2)-xlim(1);
				h					= ylim(2)-ylim(1);
				d					= sqrt(w^2+h^2);
				dz					= zlim(2)-zlim(1);
				if w >wmax,  wmax=w;   xywmax =[xc yc]; z_wmax = ir_zoom; end
				if h >hmax,  hmax=h;   xyhmax =[xc yc]; z_hmax = ir_zoom; end
				if d >dmax,  dmax=d;   xydmax =[xc yc]; z_dmax = ir_zoom; end
				if (dz>dzmax)&&(dz>0)
					dzmax			= dz;
					xydzmax		= [xc yc];
					z_dzmax		= ir_zoom;
					poly_dzmax	= poly_reg(ir,1);
				end
				if w <wmin,  wmin=w;   xywmin =[xc yc]; z_wmin = ir_zoom; end
				if h <hmin,  hmin=h;   xyhmin =[xc yc]; z_hmin = ir_zoom; end
				if d <dmin,  dmin=d;   xydmin =[xc yc]; z_dmin = ir_zoom; end
				if dz<dzmin, dzmin=dz; xydzmin=[xc yc]; z_dzmin= ir_zoom; end
				if (w<mindimx)||(h<mindimy)||(d<mindiag)
					poly_outside_spec	= union(poly_outside_spec,poly_reg(ir,1),'KeepCollinearPoints',false);
				end
				if (w>maxdimx)||(h>maxdimy)||(d>maxdiag)
					poly_outside_spec	= union(poly_outside_spec,poly_reg(ir,1),'KeepCollinearPoints',false);
				end
			end
		end
		% Specification:
		if MAP_OBJECTS(imapobj,1).cnuc~=0
			fgdcol_regdim		= textfgdcolor_default;
			if wmax>maxdimx
				swmax				= sprintf(' > %gmm at (%g,%g) --> out of spec!',maxdimx,xywmax(1),xywmax(2));
				fgdcol_wmax		= 'r';
				fgdcol_regdim	= 'r';
			else
				swmax				= sprintf(' <= %gmm at (%g,%g)',maxdimx,xywmax(1),xywmax(2));
				fgdcol_wmax		= textfgdcolor_default;
			end
			if hmax>maxdimy
				shmax				= sprintf(' > %gmm at (%g,%g) --> out of spec!',maxdimy,xyhmax(1),xyhmax(2));
				fgdcol_hmax		= 'r';
				fgdcol_regdim	= 'r';
			else
				shmax				= sprintf(' <= %gmm at (%g,%g)',maxdimy,xyhmax(1),xyhmax(2));
				fgdcol_hmax		= textfgdcolor_default;
			end
			if dmax>maxdiag
				sdmax				= sprintf(' > %gmm at (%g,%g) --> out of spec!',maxdiag,xydmax(1),xydmax(2));
				fgdcol_dmax		= 'r';
				fgdcol_regdim	= 'r';
			else
				sdmax				= sprintf(' <= %gmm at (%g,%g)',maxdiag,xydmax(1),xydmax(2));
				fgdcol_dmax		= textfgdcolor_default;
			end
			if dzmax>maxdimz
				szmax				= sprintf(' > %gmm at (%g,%g) --> out of spec!',maxdimz,xydzmax(1),xydzmax(2));
				fgdcol_zmax		= 'r';
				fgdcol_regdim	= 'r';
			else
				szmax				= sprintf(' <= %gmm at (%g,%g)',maxdimz,xydzmax(1),xydzmax(2));
				fgdcol_zmax		= 'm';
			end
			if wmin<mindimx
				swmin				= sprintf(' < %gmm at (%g,%g) --> out of spec!',mindimx,xywmin(1),xywmin(2));
				fgdcol_wmin		= 'r';
				fgdcol_regdim	= 'r';
			else
				swmin				= sprintf(' >= %gmm at (%g,%g)',mindimx,xywmin(1),xywmin(2));
				fgdcol_wmin		= textfgdcolor_default;
			end
			if hmin<mindimy
				shmin				= sprintf(' < %gmm at (%g,%g) --> out of spec!',mindimy,xyhmin(1),xyhmin(2));
				fgdcol_hmin		= 'r';
				fgdcol_regdim	= 'r';
			else
				shmin				= sprintf(' >= %gmm at (%g,%g)',mindimy,xyhmin(1),xyhmin(2));
				fgdcol_hmin		= textfgdcolor_default;
			end
			if dmin<mindiag
				sdmin				= sprintf(' < %gmm at (%g,%g) --> out of spec!',mindiag,xydmin(1),xydmin(2));
				fgdcol_dmin		= 'r';
				fgdcol_regdim	= 'r';
			else
				sdmin				= sprintf(' >= %gmm at (%g,%g)',mindiag,xydmin(1),xydmin(2));
				fgdcol_dmin		= textfgdcolor_default;
			end
			szmin				= sprintf(' at (%g,%g)',xydzmin(1),xydzmin(2));
			fgdcol_zmin	= textfgdcolor_default;
		else
			swmax				= sprintf(' at (%g,%g)',xywmax(1),xywmax(2));
			shmax				= sprintf(' at (%g,%g)',xyhmax(1),xyhmax(2));
			sdmax				= sprintf(' at (%g,%g)',xydmax(1),xydmax(2));
			szmax				= sprintf(' at (%g,%g)',xydzmax(1),xydzmax(2));
			swmin				= sprintf(' at (%g,%g)',xywmin(1),xywmin(2));
			shmin				= sprintf(' at (%g,%g)',xyhmin(1),xyhmin(2));
			sdmin				= sprintf(' at (%g,%g)',xydmin(1),xydmin(2));
			szmin				= sprintf(' at (%g,%g)',xydzmin(1),xydzmin(2));
			fgdcol_regdim	= textfgdcolor_default;
			fgdcol_wmax		= textfgdcolor_default;
			fgdcol_hmax		= textfgdcolor_default;
			fgdcol_dmax		= textfgdcolor_default;
			fgdcol_zmax		= 'm';
			fgdcol_wmin		= textfgdcolor_default;
			fgdcol_hmin		= textfgdcolor_default;
			fgdcol_dmin		= textfgdcolor_default;
			fgdcol_zmin		= textfgdcolor_default;
		end
		% xmin, xmax, ymin, ymax:
		item_overall_dim	= uimenu(hcmenu,'Label','Bounding box limits','Separator','on');
		uimenu(item_overall_dim,'Label',sprintf('xmin = %gmm',xmin));
		uimenu(item_overall_dim,'Label',sprintf('xmax = %gmm',xmax));
		uimenu(item_overall_dim,'Label',sprintf('ymin = %gmm',ymin));
		uimenu(item_overall_dim,'Label',sprintf('ymax = %gmm',ymax));
		uimenu(item_overall_dim,'Label',sprintf('zmin = %gmm',zmin));
		uimenu(item_overall_dim,'Label',sprintf('zmax = %gmm',zmax));
		% Regions width, depth/height, diag:
		if strcmp(fgdcol_regdim,'r')
			item_regions_dim		= uimenu(hcmenu,'Label','Regions number and dimensions --> out of spec',...
				'ForegroundColor',fgdcol_regdim,'Separator','on');
		else
			item_regions_dim		= uimenu(hcmenu,'Label','Regions number and dimensions',...
				'ForegroundColor',fgdcol_regdim,'Separator','on');
		end
		uimenu(item_regions_dim,'Label',sprintf('Regions: number = %g',no_regions));
		uimenu(item_regions_dim,'Label',sprintf('Regions: max Dim x = %gmm%s',wmax,swmax) ,...
			'ForegroundColor',fgdcol_wmax,...
			'MenuSelectedFcn',@(src,event)ax_2dmap_zoom('set',z_wmax(1),z_wmax(2),z_wmax(3),z_wmax(4)));
		uimenu(item_regions_dim,'Label',sprintf('Regions: max Dim y = %gmm%s',hmax,shmax) ,...
			'ForegroundColor',fgdcol_hmax,...
			'MenuSelectedFcn',@(src,event)ax_2dmap_zoom('set',z_hmax(1),z_hmax(2),z_hmax(3),z_hmax(4)));
		uimenu(item_regions_dim,'Label',sprintf('Regions: max Diag = %gmm%s' ,dmax,sdmax) ,...
			'ForegroundColor',fgdcol_dmax,...
			'MenuSelectedFcn',@(src,event)ax_2dmap_zoom('set',z_dmax(1),z_dmax(2),z_dmax(3),z_dmax(4)));
		% The maximum dz value is important for cutting into pieces: show also at top level:
		uimenu(hcmenu,'Label',sprintf('Regions: max dz = %gmm%s'   ,dzmax,szmax),...
			'ForegroundColor',fgdcol_zmax,...
			'MenuSelectedFcn',@(src,event)ax_2dmap_zoom('set',z_dzmax(1),z_dzmax(2),z_dzmax(3),z_dzmax(4)));
		uimenu(item_regions_dim,'Label',sprintf('Regions: max dz = %gmm%s'   ,dzmax,szmax),...
			'ForegroundColor',fgdcol_zmax,...
			'MenuSelectedFcn',@(src,event)ax_2dmap_zoom('set',z_dzmax(1),z_dzmax(2),z_dzmax(3),z_dzmax(4)));
		uimenu(item_regions_dim,'Label',sprintf('Regions: min Dim x = %gmm%s',wmin,swmin) ,...
			'ForegroundColor',fgdcol_wmin,...
			'MenuSelectedFcn',@(src,event)ax_2dmap_zoom('set',z_wmin(1),z_wmin(2),z_wmin(3),z_wmin(4)));
		uimenu(item_regions_dim,'Label',sprintf('Regions: min Dim y = %gmm%s',hmin,shmin) ,...
			'ForegroundColor',fgdcol_hmin,...
			'MenuSelectedFcn',@(src,event)ax_2dmap_zoom('set',z_hmin(1),z_hmin(2),z_hmin(3),z_hmin(4)));
		uimenu(item_regions_dim,'Label',sprintf('Regions: min Diag = %gmm%s' ,dmin,sdmin) ,...
			'ForegroundColor',fgdcol_dmin,...
			'MenuSelectedFcn',@(src,event)ax_2dmap_zoom('set',z_dmin(1),z_dmin(2),z_dmin(3),z_dmin(4)));
		uimenu(item_regions_dim,'Label',sprintf('Regions: min dz = %gmm%s'   ,dzmin,szmin),...
			'ForegroundColor',fgdcol_zmin,...
			'MenuSelectedFcn',@(src,event)ax_2dmap_zoom('set',z_dzmin(1),z_dzmin(2),z_dzmin(3),z_dzmin(4)));
	end
	
	% Change visibility:
	checked_show		= 'off';
	checked_grayout	= 'off';
	checked_hide		= 'off';
	if ~MAP_OBJECTS(imapobj,1).h(1,1).Visible
		checked_hide	= 'on';
	else
		if strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'polygon')
			if    isequal(MAP_OBJECTS(imapobj,1).h(1,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
					isequal(MAP_OBJECTS(imapobj,1).h(1,1).FaceAlpha,GV.visibility.show.facealpha)
				checked_show		= 'on';
			else
				checked_grayout	= 'on';
			end
		else
			checked_show		= 'on';
		end
	end
	% See "Write Callbacks for Apps Created Programmatically": "Specify an Anonymous Function"
	uimenu(hcmenu,'Label','Show','Checked',checked_show,'Separator','on',...
		'MenuSelectedFcn',@(src,event)plot_modify('show',imapobj));
	if iobj>=0
		uimenu(hcmenu,'Label','Gray out','Checked',checked_grayout,...
			'MenuSelectedFcn',@(src,event)plot_modify('gray_out',imapobj));
	end
	uimenu(hcmenu,'Label','Hide','Checked',checked_hide,...
		'MenuSelectedFcn',@(src,event)plot_modify('hide',imapobj));
	
	% Change text:
	if iobj>=0
		if strcmp(MAP_OBJECTS(imapobj,1).disp,'text')
			uimenu(hcmenu,'Label','Change text','Separator','on',...
				'MenuSelectedFcn',@(src,event)plot_modify('change_text',imapobj,'text'));
			item_Change_charstyle	= uimenu(hcmenu,'Label','Change character style');
			item_Change_charstyle_no	= struct;
			for chstno=1:size(PP.charstyle,1)
				item_Change_charstyle_no(chstno,1).uimenu	= uimenu(item_Change_charstyle,...
					'Label',sprintf('Character style: %g (%s)',chstno,PP.charstyle(chstno,1).description),...
					'MenuSelectedFcn',@(src,event)plot_modify('change_text',imapobj,'charstyle',chstno));
				if isequal(chstno,MAP_OBJECTS(imapobj,1).h(1,1).UserData.chstno)
					item_Change_charstyle_no(chstno,1).uimenu.Checked	= 'on';
				end
			end
		end
	end
	
	% Change line width:
	if iobj>0
		if PP.obj(iobj).linestyle==3
			if    isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'xy_liwimin')&&...
					isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'xy_liwimax')
				xy_liwimin		= MAP_OBJECTS(imapobj,1).h(1,1).UserData.xy_liwimin;
				xy_liwimax		= MAP_OBJECTS(imapobj,1).h(1,1).UserData.xy_liwimax;
				% Colors see also ButtonDownFcn_ax_2dmap.m (right-click).
				uimenu(hcmenu,...
					'Label',sprintf('Minimum line width = %gmm',MAP_OBJECTS(imapobj,1).h(1,1).UserData.liwi_min),...
					'ForegroundColor',[0 1 1]*0.5,'Separator','on');
				uimenu(hcmenu,...
					'Label',sprintf('Maximum line width = %gmm',MAP_OBJECTS(imapobj,1).h(1,1).UserData.liwi_max),...
					'ForegroundColor',[1 0 1]*0.5);
				uimenu(hcmenu,'Label','Change line width',...
					'MenuSelectedFcn',@(src,event)plot_modify('change_liwi',imapobj));
			end
		end
	end
	
	% Change color:
	if iobj>=0
		% Color numbers of the selected map object:
		colno_fgd		= [];
		colno_bgd		= [];
		colno_pp_fgd	= [];
		colno_pp_bgd	= [];
		if    isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'color_no'   )&&...
				isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'color_no_pp')
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				if MAP_OBJECTS(imapobj,1).h(i,1).UserData.level==0
					% level=0: background:
					colno_bgd			= [colno_bgd    MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no   ];
					colno_pp_bgd		= [colno_pp_bgd MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no_pp];
				else
					% level=1: foreground:
					colno_fgd			= [colno_fgd    MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no   ];
					colno_pp_fgd		= [colno_pp_fgd MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no_pp];
				end
			end
		end
		colno_fgd		= unique(colno_fgd);
		colno_bgd		= unique(colno_bgd);
		colno_pp_fgd	= unique(colno_pp_fgd);
		colno_pp_bgd	= unique(colno_pp_bgd);
		% colno_fgd    or colno_bgd    can be empty!
		% colno_pp_fgd or colno_pp_bgd can be empty!
		if (length(colno_fgd   )<=1)&&(length(colno_bgd   )<=1)&&...		% - There is at most one foreground and
				(length(colno_pp_fgd)<=1)&&(length(colno_pp_bgd)<=1)&&(...		%   one background color
				(length(colno_fgd   )==1)||(length(colno_bgd   )==1))&&(...		% - There is at least one foreground or
				(length(colno_pp_fgd)==1)||(length(colno_pp_bgd)==1))				%   one background color
			if iobj>0
				switch MAP_OBJECTS(imapobj,1).disp
					case 'text'
						color_no_pp_fgd	= PP.obj(iobj,1).textpar.color_no_letters;
						color_no_pp_bgd	= PP.obj(iobj,1).textpar.color_no_bgd;
					case 'connection line'
						color_no_pp_fgd	= PP.obj(iobj,1).textpar.color_no_letters;
						color_no_pp_bgd	= PP.obj(iobj,1).textpar.color_no_bgd;
					case 'symbol'
						color_no_pp_fgd	= PP.obj(iobj,1).symbolpar.color_no_symbol;
						color_no_pp_bgd	= PP.obj(iobj,1).symbolpar.color_no_bgd;
					case 'line'
						color_no_pp_fgd	= PP.obj(iobj,1).color_no_fgd;
						color_no_pp_bgd	= PP.obj(iobj,1).color_no_bgd;
					case 'area'
						color_no_pp_fgd	= PP.obj(iobj,1).color_no_fgd;
						color_no_pp_bgd	= PP.obj(iobj,1).color_no_bgd;
					otherwise
						% for example a text, that has been converted to a line:
						color_no_pp_fgd	= colno_pp_fgd;
						color_no_pp_bgd	= colno_pp_bgd;
				end
			else
				% Legend:
				color_no_pp_fgd	= colno_pp_fgd;
				color_no_pp_bgd	= colno_pp_bgd;
			end
			% color_no_pp_fgd or color_no_pp_bgd can be empty!
			color_no_pp_sort			= unique([color_no_pp_fgd color_no_pp_bgd]);
			if ~isempty(color_no_pp_sort)&&~any(color_no_pp_sort==0)
				item_Change_color_no_0	= uimenu(hcmenu,'Separator','on',...
					'Label','Color number: 0 (transparent, color of the object below)',...
					'MenuSelectedFcn',@(src,event)plot_modify('change_color',imapobj,0,0));
				if length(color_no_pp_sort)==1
					if isempty(PP.color(color_no_pp_sort,1))
						errormessage(sprintf('Error: Color number %g is not defined.',color_no_pp_sort));
					end
					label_str	= sprintf('Color number: %g (%s %s)',...
						color_no_pp_sort,...
						PP.color(color_no_pp_sort,1).brand,...
						PP.color(color_no_pp_sort,1).color_short_text);
				else
					label_str	= sprintf('Color number: %g, %g (%s, %s)',...
						color_no_pp_sort(1),...
						color_no_pp_sort(2),...
						PP.color(color_no_pp_sort(1),1).color_short_text,...
						PP.color(color_no_pp_sort(2),1).color_short_text);
				end
				item_Change_color_no_x	= uimenu(hcmenu,...
					'Label',label_str,...
					'MenuSelectedFcn',@(src,event)plot_modify('change_color',imapobj,color_no_pp_fgd,color_no_pp_bgd));
				if isequal(colno_fgd,0)||isequal(colno_bgd,0)
					% colno_fgd or colno_bgd can be empty!
					item_Change_color_no_0.Checked	= 'on';
				elseif isequal(colno_fgd,color_no_pp_fgd)||isequal(colno_bgd,color_no_pp_bgd)
					% color_no_pp_fgd or color_no_pp_bgd  can be empty!
					item_Change_color_no_x.Checked	= 'on';
				else
					errormessage;
				end
			end
		end
	end
	
	for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
		set(MAP_OBJECTS(imapobj,1).h(i,1),'uicontextmenu',hcmenu);
	end
	
catch ME
	errormessage('',ME);
end


