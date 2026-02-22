function [poly_bgd,poly_obj,poly_lrp,ud_bgd,ud_obj,ud_lrp,pos_refpoints]=texteqtags2poly(...
	iobj,iteqt,text_eqtags,connways_eqtags,text_symb,chstsettings,userdata_pp,textpar_pp,obj_purpose)
% Converts the text strings given in text_eqtags to a polygon. The unit of the values of the polygon is mm.
% poly_bgd				N*1 polyshape object of the text background.
%							If there is no visible background, poly_bgd and poly_obj are equal.
% poly_obj				N*1 polyshape object of the text.
% poly_lrp				N*1 polyshape object of the connection line to the reference point.
%							These lines connect texts and symbols, so that they do not have to be printed separatly.
%							Bigger parts are more easy to print and to place into the map.
%							If the reference point is inside poly_bgd, the connection line poly_l2rp is an empty polygon.
% ud_bgd,				corresponding N*1 Userdata:
% ud_obj,				ud_xxx(i,1).color_no			color number
% ud_lrp 				ud_xxx(i,1).color_no_pp		color number
%							ud_xxx(i,1).dz					change in altitude compared to elevation (>0 higher, <0 lower)
%							ud_xxx(i,1).prio				object priority
%							ud_xxx(i,1).in					index in OSMDATA.node
%							ud_xxx(i,1).iw					index in OSMDATA.way
%							ud_xxx(i,1).ir					index in OSMDATA.relation
%							ud_xxx(i,1).iobj				index in PP.obj
%							ud_xxx(i,1).level				0: background, 1: foreground (text)
%							ud_xxx(i,1).surftype			surface type
%							ud_xxx(i,1).iteqt				index in PLOTDATA.obj(iobj,1).text_eqtags
%							ud_xxx(i,1).text_eqtags		text_eqtags: This is needed to change the text manually.
%							ud_xxx(i,1).chstno			character style number
%							ud_xxx(i,1).chstsettings	character style settings
%							ud_xxx(i,1).rotation			rotation angle
%							ud_xxx(i,1).obj_purpose		cell array: information about the usage of the object
%																(see get_pp_mapobjsettings.m)
%							poly_bgd, poly_obj, poly_lrp, ud_bgd, ud_obj, ud_lrp have the same number of rows N!
% pos_refpoints		N*2 matrix: corresponding positions of all reference points: column 1: x, column 2: y
% iobj					index in PP.obj
% iteqt					index in PLOTDATA.obj(iobj,1).text_eqtags, where text_eqtags is saved.
%							iteqt=[]: the text is not included in PLOTDATA.obj(iobj,1).text_eqtags and
%							the field iteqt is not save in ud_bgd, ud_obj, ud_lrp (texts of the legend)
% text_eqtags			cell array of strings. Every row of the cell array is one line of the output text.
% connways_eqtags		structure with the coordinates of all nodes, ways and relations with equal tags
%							(see connect_ways)
% text_symb				settings for getdata_refpoints.m:
%							'text'							placing_on_margin_randposvar is activ
%							'change_text'					placing_on_margin_randposvar=0 (do not change the text position)
% chstsettings			character style settings				PP.charstyle(chstno,1)
% userdata				userdata project parameters: see get_pp_mapobjsettings.m
% textpar_pp			text project parameters:				Example:
%							textpar_pp.charstyle_no					PP.obj(iobj).textpar.charstyle_no
%							textpar_pp.rotation						PP.obj(iobj).textpar.rotation
%							textpar_pp.horizontalalignment		PP.obj(iobj).textpar.horizontalalignment
%							textpar_pp.verticalalignment			PP.obj(iobj).textpar.verticalalignment
%							textpar_pp.dist2refpoint				PP.obj(iobj).textpar.dist2refpoint
%							textpar_pp.line2refpoint_display		PP.obj(iobj).textpar.line2refpoint_display
%							textpar_pp.line2refpoint_width		PP.obj(iobj).textpar.line2refpoint_width
% obj_purpose			cell array: information about the usage of the object
%							(see get_pp_mapobjsettings.m)

global PP OSMDATA GV

try
	
	% Testplot:
	testplot	= 0;
	ha			= [];
	if testplot==1
		if ~isempty(iteqt)
			hf=figure(100000+iobj*100+iteqt);
		else
			hf=figure(100000+iobj*100);
		end
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha=axes;
		hold(ha,'on');
		axis(ha,'equal');
		plot(ha,[...
			OSMDATA.bounds.xmin_mm ...
			OSMDATA.bounds.xmax_mm ...
			OSMDATA.bounds.xmax_mm ...
			OSMDATA.bounds.xmin_mm ...
			OSMDATA.bounds.xmin_mm],[...
			OSMDATA.bounds.ymin_mm ...
			OSMDATA.bounds.ymin_mm ...
			OSMDATA.bounds.ymax_mm ...
			OSMDATA.bounds.ymax_mm ...
			OSMDATA.bounds.ymin_mm],'-g');
		if ~isempty(connways_eqtags.nodes)
			plot(ha,...
				connways_eqtags.nodes.xy(:,1),...
				connways_eqtags.nodes.xy(:,2),...
				'xr','LineWidth',1.5,'MarkerSize',8);
		end
		for k=1:size(connways_eqtags.lines,1)
			plot(ha,connways_eqtags.lines(k,1).xy(:,1),connways_eqtags.lines(k,1).xy(:,2),'.-c')
		end
		for k=1:size(connways_eqtags.areas,1)
			plot(ha,connways_eqtags.areas(k,1).xy(:,1),connways_eqtags.areas(k,1).xy(:,2),'.-m')
		end
		title_str	= text_eqtags{1,1};
		for i=2:size(text_eqtags,1)
			title_str	= sprintf('%s\n%s',title_str,text_eqtags{i,1});
		end
		title(ha,title_str,'Interpreter','none');
	end
	
	% Create empty polygons:
	poly0_obj		= polyshape();
	poly0_bgd		= polyshape();
	poly0_lrp		= polyshape();
	poly_obj			= polyshape();
	poly_bgd			= polyshape();
	poly_lrp			= polyshape();
	
	% Assign the indices in the OSM data:
	% see connect_ways:
	% connways_eqtags.nodes.in							nodes: index in OSMDATA.node
	% connways_eqtags.nodes.ir							nodes: index in OSMDATA.relation (0: no relation)
	% connways_eqtags.lines(k_line,1).iw_v			lines: indices in OSMDATA.way
	% connways_eqtags.lines(k_line,1).ir			lines: index in OSMDATA.relation (0: no relation)
	%																	 Lines with different indices ir will not get connected.
	% connways_eqtags.areas(k_area,1).iw_v			areas: indices in OSMDATA.way
	% connways_eqtags.areas(k_area,1).ir			areas: index in OSMDATA.relation (0: no relation)
	in_v			= [];
	iw_v			= [];
	ir_v			= [];
	if isfield(connways_eqtags,'nodes')
		if isfield(connways_eqtags.nodes,'in')
			in_v	= [in_v;connways_eqtags.nodes.in];
		end
		if isfield(connways_eqtags.nodes,'ir')
			ir_v	= [ir_v;connways_eqtags.nodes.ir];
		end
	end
	if isfield(connways_eqtags,'lines')
		for k_line=1:size(connways_eqtags.lines,1)
			if isfield(connways_eqtags.lines(k_line,1),'iw_v')
				iw_v	= [iw_v;connways_eqtags.lines(k_line,1).iw_v];
			end
			if isfield(connways_eqtags.lines(k_line,1),'ir')
				ir_v	= [ir_v;connways_eqtags.lines(k_line,1).ir];
			end
		end
	end
	if isfield(connways_eqtags,'areas')
		for k_area=1:size(connways_eqtags.areas,1)
			if isfield(connways_eqtags.areas(k_area,1),'iw_v')
				iw_v	= [iw_v;connways_eqtags.areas(k_area,1).iw_v];
			end
			if isfield(connways_eqtags.areas(k_area,1),'ir')
				ir_v	= [ir_v;connways_eqtags.areas(k_area,1).ir];
			end
		end
	end
	in_v(in_v==0,:)		= [];
	iw_v(iw_v==0,:)		= [];
	ir_v(ir_v==0,:)		= [];
	in_v						= unique(in_v);
	iw_v						= unique(iw_v);
	ir_v						= unique(ir_v);
	
	% Text-settings:
	chstno				= textpar_pp.charstyle_no;
	text_namevalue		= {...
		'FontName'           ;chstsettings.fontname;...
		'FontWeight'         ;chstsettings.fontweight;...
		'FontAngle'          ;chstsettings.fontangle;...
		'HorizontalAlignment';textpar_pp.horizontalalignment;...
		'VerticalAlignment'  ;textpar_pp.verticalalignment;...
		'Interpreter'        ;'none'};
	text_eqtags_uplo	= text_eqtags;
	for i=1:size(text_eqtags,1)
		switch chstsettings.upperlowercase
			case 'upper'
				text_eqtags_uplo{i,1}	= upper(text_eqtags{i,1});
			case 'lower'
				text_eqtags_uplo{i,1}	= lower(text_eqtags{i,1});
			otherwise
				text_eqtags_uplo{i,1}	= text_eqtags{i,1};
		end
	end
	
	% Convert to polygon: i in poly0_bgd, poly0_obj is the text line number
	for i=1:size(text_eqtags,1)
		[poly0_bgd(i,1),...								% poly_bgd
			poly0_obj(i,1)...								% poly_obj
			]=text2poly(...
			0,...												% x
			0,...												% y
			text_eqtags_uplo{i,1},...					% text_str
			chstsettings.fontsize/10,...				% fontsize_cm
			0,...												% rotation
			chstsettings.print_res,...					% print_res
			chstsettings.no_frame,...					% no_frame
			chstsettings.par_frame,...					% par_frame
			chstsettings.no_bgd,...						% no_bgd
			chstsettings.par_bgd,...					% par_bgd
			text_namevalue,...							% text_namevalue
			iobj,...
			iteqt);
	end
	
	% Line spacing:
	switch textpar_pp.verticalalignment
		case {'top','cap'}
			for i=2:size(text_eqtags,1)
				dy					= -(i-1)*chstsettings.line_spacing;
				poly0_bgd(i,1)	= translate(poly0_bgd(i,1),0,dy);
				poly0_obj(i,1)	= translate(poly0_obj(i,1),0,dy);
			end
		case {'bottom','baseline'}
			for i=1:(size(text_eqtags,1)-1)
				dy					= (size(text_eqtags,1)-i)*chstsettings.line_spacing;
				poly0_bgd(i,1)	= translate(poly0_bgd(i,1),0,dy);
				poly0_obj(i,1)	= translate(poly0_obj(i,1),0,dy);
			end
		otherwise
			% 'middle'
			for i=1:size(text_eqtags,1)
				% i=1:							(size(text_eqtags,1)+1)/2-1                   =  size(text_eqtags,1)/2-0.5
				% i=size(text_eqtags,1):	(size(text_eqtags,1)+1)/2-size(text_eqtags,1) = -size(text_eqtags,1)/2+0.5
				dy					= ((size(text_eqtags,1)+1)/2-i)*chstsettings.line_spacing;
				poly0_bgd(i,1)	= translate(poly0_bgd(i,1),0,dy);
				poly0_obj(i,1)	= translate(poly0_obj(i,1),0,dy);
			end
	end
	
	% Font widening:
	if chstsettings.fontwidening~=0
		fontwidening	= max(0,chstsettings.fontwidening);
		% Widening of every line i:
		for i=1:size(poly0_obj,1)
			% Widening of every single region ir (letter): if surftype_letters==1: the letters must remain unconnected.
			poly0_obj_reg	= regions(poly0_obj(i,1));
			ir_max			= size(poly0_obj_reg,1);
			% Sort by x-values:
			xleft_v			= zeros(ir_max,1);
			for ir=1:ir_max
				[xlim,~]		= boundingbox(poly0_obj_reg(ir,1));
				xleft_v(ir,1)	= xlim(1);
			end
			[~,ir_sort] = sort(xleft_v);
			poly0_obj_reg	= poly0_obj_reg(ir_sort,1);
			% Subtract letters to the left from letters to the right:
			poly_ir_buff	= polyshape();
			for ir=1:ir_max
				poly0_obj_reg(ir,1)	= polybuffer(poly0_obj_reg(ir,1),fontwidening/2,'JointType','miter');
				poly_ir_buff(ir,1)	= polybuffer(poly0_obj_reg(ir,1),GV.d_forebackgrd_plotobj,...
					'JointType','miter','MiterLimit',2);
			end
			for ir1=2:ir_max
				for ir2=(ir1-1):-1:1
					poly0_obj_reg(ir1,1)	= subtract(poly0_obj_reg(ir1,1),poly_ir_buff(ir2,1));
				end
			end
			% Create a single polygon object like before:
			poly0_obj(i,1)		= polyshape();
			for ir=1:ir_max
				poly0_obj(i,1)	= union(poly0_obj(i,1),poly0_obj_reg(ir,1));
			end
			poly0_bgd(i,1)		= union(poly0_bgd(i,1),poly0_obj(i,1));
		end
	end
	
	% Rotation:
	if textpar_pp.rotation~=0
		poly0_obj	= rotate(poly0_obj,textpar_pp.rotation);
		poly0_bgd	= rotate(poly0_bgd,textpar_pp.rotation);
	end
	
	% Referencepoints of the text (all positions where to print the text):
	pos_refpoints_0	= getdata_refpoints(iobj,connways_eqtags,text_symb,testplot,ha);
	
	% Distance to the reference point:
	switch textpar_pp.verticalalignment
		case {'top','cap'}
			dy				= -textpar_pp.dist2refpoint;
			poly0_bgd	= translate(poly0_bgd,0,dy);
			poly0_obj	= translate(poly0_obj,0,dy);
		case {'bottom','baseline'}
			dy				= textpar_pp.dist2refpoint;
			poly0_bgd	= translate(poly0_bgd,0,dy);
			poly0_obj	= translate(poly0_obj,0,dy);
		otherwise
			% 'middle'
	end
	switch textpar_pp.horizontalalignment
		case 'left'
			dx				= textpar_pp.dist2refpoint;
			poly0_bgd	= translate(poly0_bgd,dx,0);
			poly0_obj	= translate(poly0_obj,dx,0);
		case 'right'
			dx				= -textpar_pp.dist2refpoint;
			poly0_bgd	= translate(poly0_bgd,dx,0);
			poly0_obj	= translate(poly0_obj,dx,0);
		otherwise
			% 'center'
	end
	
	% Connection line to the reference point:
	if textpar_pp.line2refpoint_display~=0
		if PP.obj(iobj).symbolpar.display~=0
			poly0_bgd_all_lines	= polyshape();
			for i=1:size(text_eqtags,1)
				poly0_bgd_all_lines	= union(poly0_bgd_all_lines,poly0_bgd(i,1));
			end
			% if ~isinterior(poly0_bgd_all_lines,0,0)
			if ~inpolygon(...											% faster than isinterior
					0,...													% query points
					0,...
					poly0_bgd_all_lines.Vertices(:,1),...		% polygon area
					poly0_bgd_all_lines.Vertices(:,2))
				% The reference point is not inside poly_bgd:
				% Increase resolution:
				dmax						= 0.1;
				poly0_bgd_all_lines	= changeresolution_poly(poly0_bgd_all_lines,dmax,[],[]);
				% Create a line between poly_bgd and the reference point:
				[vertexid,~,~]	= nearestvertex(poly0_bgd_all_lines,0,0);
				x_vertex			= poly0_bgd_all_lines.Vertices(vertexid,1);
				y_vertex			= poly0_bgd_all_lines.Vertices(vertexid,2);
				poly0_lrp		= line2poly([0 x_vertex],[0 y_vertex],{textpar_pp.line2refpoint_width;6});
			end
		end
	end
	
	% Translate the text to all reference points pos_refpoints_0:
	% Each line of text should be a separate plot object, so the size of poly_bgd and pos_refpoints must be equal:
	ipoly		= 0;
	pos_refpoints	= zeros(size(pos_refpoints_0,1)*size(poly0_bgd,1),2);
	for irp=1:size(pos_refpoints_0,1)
		for i=1:size(poly0_bgd,1)		% i in poly0_bgd, poly0_obj is the text line number
			ipoly							= ipoly+1;
			poly_bgd(ipoly,1)			= translate(poly0_bgd(i,1),pos_refpoints_0(irp,1),pos_refpoints_0(irp,2));
			poly_obj(ipoly,1)			= translate(poly0_obj(i,1),pos_refpoints_0(irp,1),pos_refpoints_0(irp,2));
			if i==1
				% First text line:
				poly_lrp(ipoly,1)		= translate(poly0_lrp(i,1),pos_refpoints_0(irp,1),pos_refpoints_0(irp,2));
			else
				poly_lrp(ipoly,1)		= polyshape();
			end
			pos_refpoints(ipoly,:)	= [pos_refpoints_0(irp,1) pos_refpoints_0(irp,2)];
		end
	end
	
	% Assign output arguments: text:
	ud_obj_0.color_no			= userdata_pp.color_no_fgd;
	ud_obj_0.color_no_pp		= userdata_pp.color_no_fgd;
	ud_obj_0.dz					= userdata_pp.dz_fgd;
	ud_obj_0.prio				= userdata_pp.prio_fgd;
	ud_obj_0.in					= in_v;
	ud_obj_0.iw					= iw_v;
	ud_obj_0.ir					= ir_v;
	ud_obj_0.iobj				= iobj;
	ud_obj_0.level				= 1;
	ud_obj_0.surftype			= userdata_pp.surftype_fgd;
	if ~isempty(iteqt)
		ud_obj_0.iteqt			= iteqt;
	end
	ud_obj_0.text_eqtags		= {text_eqtags{1,1}};					% i=1: first line
	ud_obj_0.chstno			= chstno;
	ud_obj_0.chstsettings	= chstsettings;
	ud_obj_0.rotation			= textpar_pp.rotation;
	ud_obj_0.obj_purpose		= obj_purpose;
	for i=2:size(text_eqtags,1)
		ud_obj_0(i,1)					= ud_obj_0(1,1);
		ud_obj_0(i,1).text_eqtags	= {text_eqtags{i,1}};			% i is the text line number
	end
	ud_obj		= ud_obj_0;
	for irp=2:size(pos_refpoints_0,1)
		ud_obj	= [ud_obj;ud_obj_0];
	end
	
	% Assign output arguments: background:
	% The object priority of the background MUST:
	% 1) be smaller the the object priority of the foreground AND
	% 2) be non integer: In this way the object is recognized as background in map2stl.
	% 3) differ from the foreground object priority by LESS than 0.5.
	ud_bgd_0.color_no			= userdata_pp.color_no_bgd;
	ud_bgd_0.color_no_pp		= userdata_pp.color_no_bgd;
	ud_bgd_0.dz					= userdata_pp.dz_bgd;
	ud_bgd_0.prio				= userdata_pp.prio_bgd;
	ud_bgd_0.in					= in_v;
	ud_bgd_0.iw					= iw_v;
	ud_bgd_0.ir					= ir_v;
	ud_bgd_0.iobj				= iobj;
	ud_bgd_0.level				= 0;
	ud_bgd_0.surftype			= userdata_pp.surftype_bgd;
	if ~isempty(iteqt)
		ud_bgd_0.iteqt			= iteqt;
	end
	ud_bgd_0.text_eqtags		= {text_eqtags{1,1}};					% i=1: first line
	ud_bgd_0.chstno			= chstno;
	ud_bgd_0.chstsettings	= chstsettings;
	ud_bgd_0.rotation			= textpar_pp.rotation;
	ud_bgd_0.obj_purpose		= obj_purpose;
	for i=2:size(text_eqtags,1)
		ud_bgd_0(i,1)					= ud_bgd_0(1,1);
		ud_bgd_0(i,1).text_eqtags	= {text_eqtags{i,1}};			% i is the text line number
	end
	ud_bgd		= ud_bgd_0;
	for irp=2:size(pos_refpoints_0,1)
		ud_bgd	= [ud_bgd;ud_bgd_0];
	end
	
	% Assign output arguments: connection line to the reference point:
	% The object priority of the background MUST:
	% 1) be smaller the the object priority of the foreground AND
	% 2) be non integer: In this way the object is recognized as background in map2stl.
	% 3) differ from the foreground object priority by LESS than 0.5.
	ud_lrp_0.color_no		= userdata_pp.color_no_bgd;
	ud_lrp_0.color_no_pp	= userdata_pp.color_no_bgd;
	ud_lrp_0.dz				= userdata_pp.dz_bgd;
	ud_lrp_0.prio				= userdata_pp.prio_bgd;
	ud_lrp_0.in				= in_v;
	ud_lrp_0.iw				= iw_v;
	ud_lrp_0.ir				= ir_v;
	ud_lrp_0.iobj				= iobj;
	ud_lrp_0.level			= 0;
	ud_lrp_0.surftype		= 100;
	if ~isempty(iteqt)
		ud_lrp_0.iteqt		= iteqt;
	end
	ud_lrp_0.text_eqtags	= {text_eqtags{1,1}};					% i=1: first line
	ud_lrp_0.chstno			= chstno;
	ud_lrp_0.chstsettings	= chstsettings;
	ud_lrp_0.rotation		= 0;
	ud_lrp_0.obj_purpose	= obj_purpose;
	for i=2:size(text_eqtags,1)
		ud_lrp_0(i,1)					= ud_lrp_0(1,1);
		ud_lrp_0(i,1).text_eqtags	= {text_eqtags{i,1}};			% i is the text line number
	end
	ud_lrp		= ud_lrp_0;
	for irp=2:size(pos_refpoints_0,1)
		ud_lrp	= [ud_lrp;ud_lrp_0];
	end
	
	% Testplot:
	if testplot==1
		for irp=1:size(pos_refpoints_0,1)
			plot(ha,pos_refpoints_0(irp,1),pos_refpoints_0(irp,2),...
				'LineWidth',1.5,'LineStyle','none','Color','b','Marker','x','MarkerSize',11);
		end
		plot(ha,poly_bgd);
		plot(ha,poly_obj);
		plot(ha,poly_lrp);
		set_breakpoint=1;
	end
	
catch ME
	errormessage('',ME);
end

