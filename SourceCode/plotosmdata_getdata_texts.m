function [id_txt_node_cv,id_txt_way_cv,notisempty_txt_v]=plotosmdata_getdata_texts(...
	iobj,...
	itable_obj_eqtags_ioeqt,...		% Vektor of indices in OSMDATA_TABLE to be considered
	force_keep_data,...
	filter_nla_separatly,...
	itable_text_eqtags,...
	id_txt_node_cv,...
	id_txt_way_cv,...
	read_relations,...
	read_nodes_ways,...
	obj_eqtags_ioeqt,...
	msg)
% Collect the data of all texts
% Used in plotosmdata_getdata
%
% Note on the use of connect_ways in this function:
% The structures calculated with connect_ways are only used to calculate the reference points in texteqtags2poly.m.
% Therefore, it is not necessary to pass the values in, iw_v, and ir when calling connect_ways.
% These values are calculated in texteqtags2poly.m and added to the UserData of the map objects.

global GV PP PLOTDATA OSMDATA_TABLE OSMDATA_TABLE_INWR OSMDATA

try
	
	notisempty_txt_v	= false(size(itable_text_eqtags,1),1);
	for iteqt=1:length(itable_text_eqtags)
		create_map_log_firstline	= false;
		iteqt_has_relations			= false;
		iteqt_has_nodesways			= false;
		% old (slower): if ~isequal(PLOTDATA.obj(iobj,1).text_eqtags{iteqt,1}{1,1},'')
		if ~isempty(PLOTDATA.obj(iobj,1).text_eqtags{iteqt,1}{1,1})
			
			% Read the OSM-data:
			if GV.get_nodes_ways_repeatedly_texts
				id_txt_node_cv{iteqt,1}		= uint64([]);
				id_txt_way_cv{iteqt,1}		= uint64([]);
			end
			if read_relations
				for i_itable=1:length(itable_text_eqtags{iteqt,1})
					itable		= itable_text_eqtags{iteqt,1}(i_itable,1);
					if any(itable==itable_obj_eqtags_ioeqt)
						if strcmp(OSMDATA_TABLE.Type(itable),'relation')
							if ~iteqt_has_relations
								connways_eqtags	= connect_ways([]);
							end
							[~,~,~,connways_eqtags,~,id_txt_node_cv{iteqt,1},id_txt_way_cv{iteqt,1}] = getdata_relation(...
								OSMDATA_TABLE_INWR(itable),...		% ir
								connways_eqtags,...						% connways
								iobj,...										% iobj
								[],...										% lino
								PLOTDATA.obj(iobj,1).linewidth,...	% liwi
								[],...										% in_relation_v
								id_txt_node_cv{iteqt,1},...			% id_txt_node_cv
								id_txt_way_cv{iteqt,1});				% id_txt_way_cv
							iteqt_has_relations		= true;
						end
					end
				end
			end
			if GV.get_nodes_ways_repeatedly_texts
				id_txt_node_cv{iteqt,1}		= uint64([]);
				id_txt_way_cv{iteqt,1}		= uint64([]);
			end
			if read_nodes_ways
				ways		= [];
				for i_itable=1:length(itable_text_eqtags{iteqt,1})
					itable						= itable_text_eqtags{iteqt,1}(i_itable,1);
					if any(itable==itable_obj_eqtags_ioeqt)
						switch OSMDATA_TABLE.Type(itable)
							case 'node'
								if ~any(OSMDATA.id.node(1,OSMDATA_TABLE_INWR(itable))==id_txt_node_cv{iteqt,1})
									x	= OSMDATA.node_x_mm(1,OSMDATA_TABLE_INWR(itable));
									y	= OSMDATA.node_y_mm(1,OSMDATA_TABLE_INWR(itable));
									if ~isnan(x)&&~isnan(y)
										if ~iteqt_has_relations&&~iteqt_has_nodesways
											connways_eqtags	= connect_ways([]);
										end
										connways_eqtags		= connect_ways(connways_eqtags,[],x,y,...
											iobj,[],PLOTDATA.obj(iobj,1).linewidth,1);
										if ~GV.get_nodes_ways_repeatedly_texts
											id_txt_node_cv{iteqt,1}(end+1,1)		= OSMDATA.id.node(1,OSMDATA_TABLE_INWR(itable));
										end
										iteqt_has_nodesways		= true;
									end
								end
							case 'way'
								if ~any(OSMDATA.id.way(1,OSMDATA_TABLE_INWR(itable))==id_txt_way_cv{iteqt,1})
									if ~iteqt_has_relations&&~iteqt_has_nodesways
										connways_eqtags	= connect_ways([]);
									end
									x	= OSMDATA.way(1,OSMDATA_TABLE_INWR(itable)).x_mm;
									y	= OSMDATA.way(1,OSMDATA_TABLE_INWR(itable)).y_mm;
									[xc,yc]	= polysplit(x,y);
									for ic=1:size(xc,1)
										iw								= size(ways,1)+1;
										ways(iw,1).xy				= [xc{ic,1}(:) yc{ic,1}(:)];	% two-column matrix of vertices
										ways(iw,1).relid			= uint64(0);						% uint64 number: OSM dataset ID
										ways(iw,1).role			= '';									% character array
										ways(iw,1).tag				= '';									% character array
										ways(iw,1).iw_osmdata	= OSMDATA_TABLE_INWR(itable);	% index in OSMDATA.way
										ways(iw,1).ir_osmdata	= 0;									% index in OSMDATA.relation
										ways(iw,1).connect		= true;								% connect line (true/false)
										if ~GV.get_nodes_ways_repeatedly_texts
											if ic==1
												id_txt_way_cv{iteqt,1}(end+1,1)	= OSMDATA.id.way(1,OSMDATA_TABLE_INWR(itable));
											end
										end
									end
									iteqt_has_nodesways		= true;
								end
						end
					end
				end
				% Connect the ways:
				if iteqt_has_nodesways
					connways_eqtags		= connect_ways_longest_line(...
						connways_eqtags,...	% connways
						ways,...										% ways
						iobj,...										% iobj
						[],...										% lino
						PLOTDATA.obj(iobj,1).linewidth,...	% liwi
						1,...											% l2a
						1,...											% s
						1,...											% lino_new_min
						GV.tol_1);									% tol
				end
			end
			
			if iteqt_has_relations||iteqt_has_nodesways
				notisempty_txt_v(iteqt,1)		= true;
				
				% Filter small objects out:
				% After that, connways_eqtags_filt contains only objects that fulfill the conditions.
				%
				% Note: minarea=-999999
				% This makes it possible to filter out the areas independently of the other limit values. Reason:
				% The areas are filtered after the polygons have been calculated, since the shape of the areas
				% can change by moving the outlines: see:	call_symboleqtags2poly
				%														symboleqtags2poly
				%														getdata_refpoints
				%														connways_center
				%														plotosmdata_simplify_moveoutline
				% Disadvantage:
				% When executing "Create map," texts and symbols are also generated for areas that are too small,
				% and the function takes much longer for large maps.
				connways_eqtags_filt	= connect_ways([]);
				connways_eqtags_filt	= plotosmdata_getdata_filterout(...
					connways_eqtags,...
					connways_eqtags_filt,...
					PP.obj(iobj,1).textpar.mindimx,...
					PP.obj(iobj,1).textpar.mindimy,...
					PP.obj(iobj,1).textpar.mindiag,...
					PP.obj(iobj,1).textpar.minlength,...
					PP.obj(iobj,1).textpar.minarea,...			% See note
					filter_nla_separatly,...
					force_keep_data,...
					obj_eqtags_ioeqt,...
					msg);
				
				% Create the text polygons and add the texts to PLOTDATA:
				if    ~isempty(connways_eqtags_filt.nodes)  ||...
						(size(connways_eqtags_filt.lines,1)>0)||...
						(size(connways_eqtags_filt.areas,1)>0)
					if filter_nla_separatly==0
						call_texteqtags2poly(...
							iobj,...
							iteqt,...
							create_map_log_firstline,...
							force_keep_data,...
							filter_nla_separatly,...
							obj_eqtags_ioeqt,...
							connways_eqtags_filt,...
							msg);
					else
						if ~isempty(connways_eqtags_filt.nodes)
							connways_eqtags_select			= connect_ways([]);
							connways_eqtags_select.nodes	= connways_eqtags_filt.nodes;
							create_map_log_firstline	= call_texteqtags2poly(...
								iobj,...
								iteqt,...
								create_map_log_firstline,...
								force_keep_data,...
								filter_nla_separatly,...
								obj_eqtags_ioeqt,...
								connways_eqtags_select,...
								msg);
						end
						for k_line=1:size(connways_eqtags_filt.lines,1)
							connways_eqtags_select						= connect_ways([]);
							connways_eqtags_select.lines				= connways_eqtags_filt.lines(k_line,1);
							connways_eqtags_select.lines_isouter	= connways_eqtags_filt.lines_isouter(k_line,1);
							connways_eqtags_select.lines_isinner	= connways_eqtags_filt.lines_isinner(k_line,1);
							connways_eqtags_select.lines_relid		= connways_eqtags_filt.lines_relid(k_line,1);
							connways_eqtags_select.xy_start			= connways_eqtags_filt.xy_start(k_line,1);
							connways_eqtags_select.xy_end				= connways_eqtags_filt.xy_end(k_line,1);
							connways_eqtags_select.lino_max			= connways_eqtags_filt.lino_max;
							create_map_log_firstline	= call_texteqtags2poly(...
								iobj,...
								iteqt,...
								create_map_log_firstline,...
								force_keep_data,...
								filter_nla_separatly,...
								obj_eqtags_ioeqt,...
								connways_eqtags_select,...
								msg);
						end
						for k_area=1:size(connways_eqtags_filt.areas,1)
							connways_eqtags_select						= connect_ways([]);
							connways_eqtags_select.areas				= connways_eqtags_filt.areas(k_area,1);
							connways_eqtags_select.areas_isouter	= connways_eqtags_filt.areas_isouter(k_area,1);
							connways_eqtags_select.areas_isinner	= connways_eqtags_filt.areas_isinner(k_area,1);
							connways_eqtags_select.areas_relid		= connways_eqtags_filt.areas_relid(k_area,1);
							create_map_log_firstline	= call_texteqtags2poly(...
								iobj,...
								iteqt,...
								create_map_log_firstline,...
								force_keep_data,...
								filter_nla_separatly,...
								obj_eqtags_ioeqt,...
								connways_eqtags_select,...
								msg);
						end
					end
				end
				
			end
			
		end
		
	end
	
catch ME
	errormessage('',ME);
end



function  create_map_log_firstline=call_texteqtags2poly(...
	iobj,...
	iteqt,...
	create_map_log_firstline,...
	force_keep_data,...
	filter_nla_separatly,...
	obj_eqtags_ioeqt,...
	connways_eqtags_select,...
	msg)
% Create the text polygons and add the texts to PLOTDATA
% Called by plotosmdata_getdata_texts.m

global PLOTDATA PP GV

try
	
	% Create the text polygons:
	obj_purpose				= {'map object'};
	[userdata_pp,textpar_pp,errortext]	= get_pp_mapobjsettings(...
		iobj,...														% iobj
		'text',...													% disp
		obj_purpose);												% obj_purpose
	if ~isempty(errortext)
		errormessage(errortext);
	end
	chstno					= textpar_pp.charstyle_no;
	chstsettings			= PP.charstyle(chstno,1);
	[  pd_poly_text_bgd,...
		pd_poly_text_obj,...
		pd_poly_text_lrp,...
		pd_ud_text_bgd,...
		pd_ud_text_obj,...
		pd_ud_text_lrp,...
		pd_pos_refpoints]	= texteqtags2poly(...
		iobj,...														% iobj
		iteqt,...													% iteqt
		PLOTDATA.obj(iobj,1).text_eqtags{iteqt,1},...	% text_eqtags
		connways_eqtags_select,...								% connways_eqtags
		'text',...													% text_symb
		chstsettings,...											% chstsettings
		userdata_pp,...											% userdata_pp
		textpar_pp,...												% textpar_pp
		obj_purpose);												% obj_purpose
	
	if numboundaries(pd_poly_text_bgd)>0
		
		% Add the texts to PLOTDATA:
		PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd	= [...
			PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd;...
			pd_poly_text_bgd];
		PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj	= [...
			PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj;...
			pd_poly_text_obj];
		PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_lrp	= [...
			PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_lrp;...
			pd_poly_text_lrp];
		PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd		= [...
			PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd;...
			pd_ud_text_bgd];
		PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_obj		= [...
			PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_obj;...
			pd_ud_text_obj];
		PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_lrp		= [...
			PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_lrp;...
			pd_ud_text_lrp];
		if ~isequal(...
				size(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd),...
				size(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj)    )||~isequal(...
				size(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd),...
				size(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_lrp)    )||~isequal(...
				size(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd),...
				size(PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd)      )||~isequal(...
				size(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd),...
				size(PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_obj)      )||~isequal(...
				size(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd),...
				size(PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_lrp)      )
			errormessage;
		end
		
		% Reference points:
		PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints	= [...
			PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints;...
			pd_pos_refpoints];
		
		% Source plots:
		% The source plots are made visible, if the corresponding text or symbol is selected.
		% This makes it easier to move the texts and symbols to the right place when editing the map.
		for k=1:size(pd_poly_text_bgd,1)
			PLOTDATA.obj(iobj,1).text(iteqt,1).source(end+1,1).connways	= connways_eqtags_select;
		end
		
		% Add the colornumber to PLOTDATA.colno_v:
		PLOTDATA.obj(iobj,1).colno_text_fgd	= PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_obj.color_no;
		PLOTDATA.obj(iobj,1).colno_text_bgd	= PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd.color_no;
		if ~isequal(PLOTDATA.obj(iobj,1).colno_text_fgd,0)
			PLOTDATA.colno_v					= unique([PLOTDATA.colno_v;PLOTDATA.obj(iobj,1).colno_text_fgd]);
		end
		if ~isequal(PLOTDATA.obj(iobj,1).colno_text_bgd,0)
			PLOTDATA.colno_v					= unique([PLOTDATA.colno_v;PLOTDATA.obj(iobj,1).colno_text_bgd]);
		end
		
	end
	
	% "Create map" log:
	if ~create_map_log_firstline
		GV.log.create_map.text	= sprintf('%s      | %5.0f | ',GV.log.create_map.text,iteqt);
		i2							= 1;
		text_eqtags_iteqt_i2	= PLOTDATA.obj(iobj,1).text_eqtags{iteqt,1}{i2,1};
		for i2=2:size(PLOTDATA.obj(iobj,1).text_eqtags{iteqt,1},1)
			text_eqtags_iteqt_i2	= sprintf('%s %s',...
				text_eqtags_iteqt_i2,...
				PLOTDATA.obj(iobj,1).text_eqtags{iteqt,1}{i2,1});
		end
		text_eqtags_iteqt_i2	= text_eqtags_iteqt_i2(1:min(33,length(text_eqtags_iteqt_i2)));
		GV.log.create_map.text	= sprintf('%stexts: ''%s''%s | ',GV.log.create_map.text,text_eqtags_iteqt_i2,blanks(33-length(text_eqtags_iteqt_i2)));
		create_map_log_firstline	= true;
	else
		GV.log.create_map.text	= sprintf('%s      |       |                                            | ',GV.log.create_map.text);
	end
	connways_eqtags_filt	= connect_ways([]);
	[~,...
		dx_all_mm,...
		dy_all_mm,...
		diag_all_mm,...
		length_all_mm,...
		area_all_mm2]	= plotosmdata_getdata_filterout(...
		connways_eqtags_select,...
		connways_eqtags_filt,...
		PP.obj(iobj,1).textpar.mindimx,...
		PP.obj(iobj,1).textpar.mindimy,...
		PP.obj(iobj,1).textpar.mindiag,...
		PP.obj(iobj,1).textpar.minlength,...
		PP.obj(iobj,1).textpar.minarea,...
		filter_nla_separatly,...
		force_keep_data,...
		obj_eqtags_ioeqt,...
		msg);
	GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,dx_all_mm);
	GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,dy_all_mm);
	GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,diag_all_mm);
	GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,length_all_mm);
	GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,area_all_mm2);
	if force_keep_data
		GV.log.create_map.text	= sprintf('%s   X |\n',GV.log.create_map.text);
	else
		GV.log.create_map.text	= sprintf('%s     |\n',GV.log.create_map.text);
	end
	% OSMDATA_TABLE
	setbreakpoint=1;
	
catch ME
	errormessage('',ME);
end

