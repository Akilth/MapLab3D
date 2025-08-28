function [poly_bgd,poly_obj,ud_bgd,ud_obj,pos_refpoints]=symboleqtags2poly(...
	iobj,isym,tag_symbol,itable_v,connways_eqtags,obj_purpose)
% Calculates the positions of the symbols. The unit of the values of the polygon is mm.
% poly_bgd						N*1 polyshape object of the symbol background.
% poly_obj						N*1 polyshape object of the symbol.
% ud_bgd,ud_obj				corresponding N*1 Userdata:
%									ud_xxx(i,1).color_no		color number
%									ud_xxx(i,1).color_no_pp	color number project parameters
%									ud_xxx(i,1).dz				change in altitude compared to elevation (>0 higher, <0 lower)
%									ud_xxx(i,1).prio			object priority
%									ud_xxx(i,1).in				index in OSMDATA.node
%									ud_xxx(i,1).iw				index in OSMDATA.way
%									ud_xxx(i,1).ir				index in OSMDATA.relation
%									ud_xxx(i,1).iobj			index in PP.obj
%									ud_xxx(i,1).level			0: background, 1: foreground (symbol)
%									ud_xxx(i,1).surftype		surface type
%									ud_xxx(i,1).rotation		rotation angle
%									ud_xxx(i,1).obj_purpose	cell array: information about the usage of the object
%																	(see get_pp_mapobjsettings.m)
%									ud_xxx(i,1).isym			symbol number, index in SY
%									poly_bgd, poly_obj, ud_bgd, ud_obj have the same number of rows N!
% pos_refpoints				N*2 matrix: corresponding positions of all reference points: column 1: x, column 2: y
% iobj							index in PP.obj
% isym							index in SY
% tag_symbol					character array: tag of the symbol: symbol_key=symbol_value
%									For example: 'generator:method=wind_turbine'
% itable_v						vector of indices in OSMDATA_TABLE
% connways_eqtags				structure with the coordinates of all nodes, ways and relations with equal tags
%									(see connect_ways)
% obj_purpose					cell array: information about the usage of the object
%									(see get_pp_mapobjsettings.m)

global PP OSMDATA OSMDATA_TABLE OSMDATA_TABLE_INWR SY

try

	% Testplot:
	testplot	= 0;
	ha			= [];
	if testplot==1
		hf=figure(100000+iobj*100);
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
		title_str	= sprintf('%s=%s',SY(isym).k,SY(isym).v);
		title(ha,title_str,'Interpreter','none');
	end

	% Assign the indices in the OSM data:
	in_v			= [];
	iw_v			= [];
	ir_v			= [];
	if ~isempty(itable_v)
		if ~isempty(OSMDATA_TABLE)
			for i=1:length(itable_v)
				itable	= itable_v(i);
				itable	= max(0,round(itable));
				if itable>=1
					if height(OSMDATA_TABLE)>=itable
						% index in OSMDATA.node/OSMDATA.way/OSMDATA.relation:
						switch OSMDATA_TABLE.Type(itable)						% type: 'node'/'way'/'relation'
							case 'node'
								in_v	= [in_v;OSMDATA_TABLE_INWR(itable)];
							case 'way'
								iw_v	= [iw_v;OSMDATA_TABLE_INWR(itable)];
							case 'relation'
								ir_v	= [ir_v;OSMDATA_TABLE_INWR(itable)];
						end
					end
				end
			end
		end
	end

	% Assign the symbol and scale-up:
	poly0_bgd	= SY(isym).poly_bgd;
	poly0_sym	= SY(isym).poly_sym;
	if    (PP.obj(iobj).symbolpar.scaleup_factor ~=1)||...
			(PP.obj(iobj).symbolpar.scaleup_mindimx~=0)||...
			(PP.obj(iobj).symbolpar.scaleup_mindimy~=0)||...
			(PP.obj(iobj).symbolpar.scaleup_mindiag~=0)
		poly	= polyshape();
		if ~isempty(poly0_bgd)
			if sum(numboundaries(poly0_bgd))>0
				poly	= poly0_bgd;
			end
		end
		if sum(numboundaries(poly))==0
			poly	= poly0_sym;
		end
		% Dimensions of the bounding box:
		[xlim,ylim]		= boundingbox(poly);
		poly_dimx		= xlim(2)-xlim(1);
		poly_dimy		= ylim(2)-ylim(1);
		poly_diag		= sqrt(poly_dimx^2+poly_dimy^2);
		% Scale-up-factor:
		scaleupfactor	= PP.obj(iobj).symbolpar.scaleup_factor;
		if poly_dimx<PP.obj(iobj).symbolpar.scaleup_mindimx
			scaleupfactor	= max(scaleupfactor,PP.obj(iobj).symbolpar.scaleup_mindimx/poly_dimx);
		end
		if poly_dimy<PP.obj(iobj).symbolpar.scaleup_mindimy
			scaleupfactor	= max(scaleupfactor,PP.obj(iobj).symbolpar.scaleup_mindimy/poly_dimy);
		end
		if poly_diag<PP.obj(iobj).symbolpar.scaleup_mindiag
			scaleupfactor	= max(scaleupfactor,PP.obj(iobj).symbolpar.scaleup_mindiag/poly_diag);
		end
		% Scale-up:
		if scaleupfactor~=1
			[x,y]					= centroid(poly);
			if ~isempty(poly0_bgd)
				if sum(numboundaries(poly0_bgd))>0
					poly0_bgd	= scale(poly0_bgd,scaleupfactor,[x y]);
				end
			end
			poly0_sym			= scale(poly0_sym,scaleupfactor,[x y]);
		end
	end

	% Referencepoints of the symbol (all positions where to print the symbol):
	pos_refpoints		= getdata_refpoints(iobj,connways_eqtags,'symbol',testplot,ha);

	% Translate the symbol to all reference points:
	poly_bgd	= polyshape();
	poly_obj	= polyshape();
	for i=1:size(pos_refpoints,1)
		poly_bgd(i,1)	= translate(poly0_bgd,pos_refpoints(i,1),pos_refpoints(i,2));
		poly_obj(i,1)	= translate(poly0_sym,pos_refpoints(i,1),pos_refpoints(i,2));
	end

	% Userdata:
	[userdata_pp,~,errortext]	= get_pp_mapobjsettings(...
		iobj,...														% iobj
		'symbol',...												% disp
		obj_purpose);												% obj_purpose
	if ~isempty(errortext)
		errormessage(errortext);
	end

	% Assign output arguments: symbol:
	ud_obj.color_no		= userdata_pp.color_no_fgd;
	ud_obj.color_no_pp	= userdata_pp.color_no_fgd;
	ud_obj.dz				= userdata_pp.dz_fgd;
	ud_obj.prio				= userdata_pp.prio_fgd;
	ud_obj.in				= in_v;
	ud_obj.iw				= iw_v;
	ud_obj.ir				= ir_v;
	ud_obj.iobj				= iobj;
	ud_obj.level			= 1;
	ud_obj.surftype		= userdata_pp.surftype_fgd;
	ud_obj.rotation		= 0;
	ud_obj.obj_purpose	= obj_purpose;
	ud_obj.isym				= isym;
	ud_obj.tag_symbol		= tag_symbol;
	for i=2:size(pos_refpoints,1)
		ud_obj(i,1)			= ud_obj(1,1);
	end

	% Assign output arguments: background:
	% The object priority of the background MUST:
	% 1) be smaller the the object priority of the foreground AND
	% 2) be non integer: In this way the object is recognized as background in map2stl.
	% 3) differ from the foreground object priority by LESS than 0.5.
	ud_bgd.color_no		= userdata_pp.color_no_bgd;
	ud_bgd.color_no_pp	= userdata_pp.color_no_bgd;
	ud_bgd.dz				= userdata_pp.dz_bgd;
	ud_bgd.prio				= userdata_pp.prio_bgd;
	ud_bgd.in				= in_v;
	ud_bgd.iw				= iw_v;
	ud_bgd.ir				= ir_v;
	ud_bgd.iobj				= iobj;
	ud_bgd.level			= 0;
	ud_bgd.surftype		= userdata_pp.surftype_bgd;
	ud_bgd.rotation		= 0;
	ud_bgd.obj_purpose	= obj_purpose;
	ud_bgd.isym				= isym;
	ud_bgd.tag_symbol		= tag_symbol;
	for i=2:size(pos_refpoints,1)
		ud_bgd(i,1)			= ud_bgd(1,1);
	end

	% Testplot:
	if testplot==1
		for i=1:size(pos_refpoints,1)
			plot(ha,pos_refpoints(i,1),pos_refpoints(i,2),...
				'LineWidth',1.5,'LineStyle','none','Color','b','Marker','x','MarkerSize',11);
			plot(ha,poly_bgd);
			plot(ha,poly_obj);
		end
		set_breakpoint=1;
	end

catch ME
	errormessage('',ME);
end

