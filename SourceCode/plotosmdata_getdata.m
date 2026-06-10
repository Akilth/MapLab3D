function plotosmdata_getdata(iobj,msg,get_liar,get_text,get_symb)
% Assignment of:	PLOTDATA.obj(iobj,1). ...
%						PLOTDATA.obj(iobj,1).symb
%						PLOTDATA.obj(iobj,1).text
%						PLOTDATA.obj(iobj,1).ud_in_v
%						PLOTDATA.obj(iobj,1).ud_iw_v
%						PLOTDATA.obj(iobj,1).ud_ir_v
%						PLOTDATA.obj(iobj,1).colno_fgd
%						PLOTDATA.obj(iobj,1).colno_bgd
%						PLOTDATA.obj(iobj,1).colno_symb_fgd
%						PLOTDATA.obj(iobj,1).colno_symb_bgd
%						PLOTDATA.obj(iobj,1).colno_text_fgd
%						PLOTDATA.obj(iobj,1).colno_text_bgd
% iobj				index in PP.obj
% msg					message
% get_liar			get the data of lines and areas (true/false)
% get_text			get the data of texts (true/false)
% get_symb			get the data of symbols (true/false)
%
% Syntax:
% plotosmdata_getdata(iobj,msg);				Create a field PLOTDATA.obj(iobj,1) and
%														assign the data in OSMDATA_TABLE.

global PP OSMDATA APP OSMDATA_TABLE OSMDATA_TABLE_INWR PLOTDATA GV GV_H WAITBAR

try
	
	% Testplot:
	testplot			= 0;
	iobj_testplot	= 11;
	
	% "Create map" log:
	GV.log.create_map.text	= sprintf('%s%s\n',GV.log.create_map.text,GV.log.create_map.line_str);
	if get_liar&&get_text&&get_symb
		liartesy_str	= ': lines,  areas, texts and symbols';
	elseif get_liar&&get_text&&~get_symb
		liartesy_str	= ': lines,  areas and texts';
	elseif get_liar&&~get_text&&get_symb
		liartesy_str	= ': lines,  areas and symbols';
	elseif ~get_liar&&get_text&&get_symb
		liartesy_str	= ': texts and symbols';
	elseif get_liar&&~get_text&&~get_symb
		liartesy_str	= ': lines and areas';
	elseif ~get_liar&&get_text&&~get_symb
		liartesy_str	= ': texts';
	elseif ~get_liar&&~get_text&&get_symb
		liartesy_str	= ': symbols';
	else
		errormessage;
	end
	GV.log.create_map.text	= sprintf(['%s',...
		'Get plot data of ObjNo %g (%s)%s\n'],...
		GV.log.create_map.text,...
		iobj,PP.obj(iobj).description,liartesy_str);
	
	% vector of indices in OSMDATA_TABLE:
	i_table_plot		= (1:height(OSMDATA_TABLE))';
	
	% Add the colornumbers to PLOTDATA.colno_v:
	if    isequal(PP.obj(iobj).display,1)&&...
			get_liar
		PLOTDATA.obj(iobj,1).colno_fgd	= PP.obj(iobj).color_no_fgd;
		PLOTDATA.obj(iobj,1).colno_bgd	= PP.obj(iobj).color_no_bgd;
		if ~isequal(PLOTDATA.obj(iobj,1).colno_fgd,0)
			PLOTDATA.colno_v			= unique([PLOTDATA.colno_v;PLOTDATA.obj(iobj,1).colno_fgd]);
		end
		if ~isequal(PLOTDATA.obj(iobj,1).colno_bgd,0)
			PLOTDATA.colno_v			= unique([PLOTDATA.colno_v;PLOTDATA.obj(iobj,1).colno_bgd]);
		end
	end
	
	% Total line width:
	if    (PP.obj(iobj).display_as_line~=0)
		[~,~,~,~,PLOTDATA.obj(iobj,1).linewidth]	= line2poly(...
			[],...										% x
			[],...										% y
			PP.obj(iobj).linepar,...				% par
			PP.obj(iobj).linestyle,...				% style
			iobj);										% iobj
	else
		PLOTDATA.obj(iobj,1).linewidth			= [];
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Collect the data of all symbols:
	if get_symb
		if    (PP.obj(iobj).symbolpar.display==1)           &&...
				APP.CreatemapSettingsCreateSymbolsMenu.Checked
			[  isym_symbol_eqtags,...
				PLOTDATA.obj(iobj,1).symb_eqtags,...
				itable_symbol_eqtags,...
				text_tag_symbol_eqtags]	= ...
				filter_symboltags(...
				i_table_plot,...
				PP.obj(iobj,1).symbolpar.manual_select_key,...
				PP.obj(iobj,1).symbolpar.manual_select_val,...
				PP.obj(iobj,1).symbolpar.key_for_display,...
				msg);
		else
			isym_symbol_eqtags													= [];
			itable_symbol_eqtags{1,1}											= [];
		end
		for iseqt=1:length(itable_symbol_eqtags)
			PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd			= zeros(0,1);
			PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_obj			= zeros(0,1);
			PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_bgd				= zeros(0,1);
			PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_obj				= zeros(0,1);
			PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints			= zeros(0,2);
			PLOTDATA.obj(iobj,1).symb(iseqt,1).symbol_eqtags_text		= cell(0,2);
			PLOTDATA.obj(iobj,1).symb(iseqt,1).isource					= zeros(0,1);
			PLOTDATA.obj(iobj,1).symb(iseqt,1).source						= [];
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Collect the data of all texts:
	if get_text
		if    (PP.obj(iobj).textpar.display==1)           &&...
				APP.CreatemapSettingsCreateTextsMenu.Checked
			[PLOTDATA.obj(iobj,1).text_eqtags,itable_text_eqtags]		= filter_texttags(iobj,i_table_plot,msg);
		else
			itable_text_eqtags{1,1}												= [];
			PLOTDATA.obj(iobj,1).text_eqtags									= cell(0,1);		% see also plotosmdata_reducedata.m
		end
		for iteqt=1:length(itable_text_eqtags)
			PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd			= zeros(0,1);
			PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj			= zeros(0,1);
			PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_lrp			= zeros(0,1);
			PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd				= zeros(0,1);
			PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_obj				= zeros(0,1);
			PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_lrp				= zeros(0,1);
			PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints			= zeros(0,2);
			PLOTDATA.obj(iobj,1).text(iteqt,1).isource					= zeros(0,1);
			PLOTDATA.obj(iobj,1).text(iteqt,1).source						= [];
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Collect the data of all objects:
	WAITBAR.t1		= clock;
	filter_by_key	= false;
	for c=1:size(PP.obj(iobj).filter_by_key.incltagkey,2)
		if ~isempty(PP.obj(iobj).filter_by_key.incltagkey{1,c})
			filter_by_key	= true;
		end
	end
	if ~filter_by_key
		% No filtering by key:
		
		% "Create map" log:
		if    (PP.obj(iobj).textpar.display==1)           &&...
				APP.CreatemapSettingsCreateTextsMenu.Checked&&...
				get_text
			GV.log.create_map.text	= sprintf('%s      | Te/Sy | Text/Tag                                   | ',GV.log.create_map.text);
			GV.log.create_map.text	= sprintf('%s    Dimx |     Dimy |     Diag |   Length |     Area | Keep |\n',GV.log.create_map.text);
			GV.log.create_map.text	= sprintf('%sMinimum dimensions for placing the texts:                  | ',GV.log.create_map.text);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).textpar.mindimx);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).textpar.mindimy);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).textpar.mindiag);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).textpar.minlength);
			GV.log.create_map.text	= sprintf('%s%8.3f |      |\n',GV.log.create_map.text,PP.obj(iobj,1).textpar.minarea);
		end
		if    (PP.obj(iobj).symbolpar.display==1)           &&...
				APP.CreatemapSettingsCreateSymbolsMenu.Checked&&...
				get_symb
			GV.log.create_map.text	= sprintf('%s      | Te/Sy | Text/Tag                                   | ',GV.log.create_map.text);
			GV.log.create_map.text	= sprintf('%s    Dimx |     Dimy |     Diag |   Length |     Area | Keep |\n',GV.log.create_map.text);
			GV.log.create_map.text	= sprintf('%sMinimum dimensions for placing the symbols:                | ',GV.log.create_map.text);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).symbolpar.mindimx);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).symbolpar.mindimy);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).symbolpar.mindiag);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).symbolpar.minlength);
			GV.log.create_map.text	= sprintf('%s%8.3f |      |\n',GV.log.create_map.text,PP.obj(iobj,1).symbolpar.minarea);
		end
		
		PLOTDATA.obj(iobj,1).obj_eqtags		= [];
		
		% Get the data of lines and areas:
		if get_liar
			PLOTDATA.obj(iobj,1).connways			= connect_ways([]);		% Initialize the connected ways
			id_obj_node_v		= uint64([]);
			id_obj_way_v		= uint64([]);
			id_rel_node_v		= uint64([]);					% id_obj_node_v of relations
			id_rel_way_v		= uint64([]);					% id_obj_way_v  of relations
			for i_itable=1:length(i_table_plot)
				itable						= i_table_plot(i_itable);
				% Waitbar:
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					WAITBAR.t1	= clock;
					set(GV_H.text_waitbar,'String',sprintf('%s: relations %g/%g',msg,...
						i_itable,length(i_table_plot)));
					drawnow;
				end
				% Read the OSM-data:
				if strcmp(OSMDATA_TABLE.Type(itable),'relation')
					if GV.get_nodes_ways_repeatedly
						id_obj_node_v		= uint64([]);
						id_obj_way_v		= uint64([]);
					end
					[~,~,~,PLOTDATA.obj(iobj,1).connways,~,id_obj_node_v,id_obj_way_v]	= getdata_relation(...
						OSMDATA_TABLE_INWR(itable),...		% ir
						PLOTDATA.obj(iobj,1).connways,...	% connways
						iobj,...										% iobj
						[],...										% lino
						PLOTDATA.obj(iobj,1).linewidth,...	% liwi
						[],...										% in_relation_v
						id_obj_node_v,...							% id_obj_node_v
						id_obj_way_v);								% id_obj_way_v
				end
				if GV.get_nodes_ways_repeatedly
					id_rel_node_v		= unique([id_rel_node_v;id_obj_node_v]);
					id_rel_way_v		= unique([id_rel_way_v ;id_obj_way_v ]);
				end
			end
			if GV.get_nodes_ways_repeatedly
				if PP.obj(iobj).display_as_area~=0
					id_obj_node_v		= uint64([]);
					id_obj_way_v		= uint64([]);
				else
					id_obj_node_v		= id_rel_node_v;
					id_obj_way_v		= id_rel_way_v;
				end
			end
			ways		= [];
			for i_itable=1:length(i_table_plot)
				itable						= i_table_plot(i_itable);	% itable: Index in OSMDATA_TABLE_INWR and OSMDATA_TABLE
				% Waitbar:
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					WAITBAR.t1	= clock;
					set(GV_H.text_waitbar,'String',sprintf('%s: nodes, ways %g/%g',msg,...
						i_itable,length(i_table_plot)));
					drawnow;
				end
				% Read the OSM-data:
				switch OSMDATA_TABLE.Type(itable)
					case 'node'
						if ~any(OSMDATA.id.node(1,OSMDATA_TABLE_INWR(itable))==id_obj_node_v)
							x	= OSMDATA.node_x_mm(1,OSMDATA_TABLE_INWR(itable));
							y	= OSMDATA.node_y_mm(1,OSMDATA_TABLE_INWR(itable));
							if ~isnan(x)&&~isnan(y)
								PLOTDATA.obj(iobj,1).connways	= ...
									connect_ways(...							%								Defaultvalues:
									PLOTDATA.obj(iobj,1).connways,...	% connways					-
									[],...										% connways_merge			[]
									x,...											% x							[]
									y,...											% y							[]
									iobj,...										% iobj						[]
									[],...										% lino						[]
									PLOTDATA.obj(iobj,1).linewidth,...	% liwi						[]
									OSMDATA_TABLE_INWR(itable),...		% in							0
									0,...											% iw_v						0
									0,...											% ir							0
									1,...											% l2a							1
									1,...											% s							1
									1,...											% lino_new_min				1
									'outer',...									% role						'outer'
									uint64(0),...								% relid						uint64(0)
									'',...										% tag							''
									GV.tol_1,...								% tol							GV.tol_1
									true,...										% conn_with_rev			true
									true);										% connect					true
								if ~GV.get_nodes_ways_repeatedly||(PP.obj(iobj).display_as_area==0)
									id_obj_node_v(end+1,1)				= OSMDATA.id.node(1,OSMDATA_TABLE_INWR(itable));
								end
							end
						end
					case 'way'
						if ~any(OSMDATA.id.way(1,OSMDATA_TABLE_INWR(itable))==id_obj_way_v)||...
								(PP.obj(iobj,1).add_ways_only_once==0)
							x	= OSMDATA.way(1,OSMDATA_TABLE_INWR(itable)).x_mm;
							y	= OSMDATA.way(1,OSMDATA_TABLE_INWR(itable)).y_mm;
							[xc,yc]	= polysplit(x,y);
							for ic=1:size(xc,1)
								iw								= size(ways,1)+1;
								ways(iw,1).xy				= [xc{ic,1}(:) yc{ic,1}(:)];	% two-column matrix of vertices
								ways(iw,1).relid			= uint64(0);						% uint64 number: OpenStreetMap dataset ID
								ways(iw,1).role			= '';									% character array
								ways(iw,1).tag				= '';									% character array
								ways(iw,1).iw_osmdata	= OSMDATA_TABLE_INWR(itable);	% index in OSMDATA.way
								ways(iw,1).ir_osmdata	= 0;									% index in OSMDATA.relation
								ways(iw,1).connect		= true;								% connect line (true/false)
								if ~GV.get_nodes_ways_repeatedly||(PP.obj(iobj).display_as_area==0)
									if ic==1
										id_obj_way_v(end+1,1)				= OSMDATA.id.way(1,OSMDATA_TABLE_INWR(itable));
									end
								end
							end
						end
				end
			end
			% Connect the ways:
			PLOTDATA.obj(iobj,1).connways		= connect_ways_longest_line(...
				PLOTDATA.obj(iobj,1).connways,...	% connways
				ways,...										% ways
				iobj,...										% iobj
				[],...										% lino
				PLOTDATA.obj(iobj,1).linewidth,...	% liwi
				1,...											% l2a
				1,...											% s
				1,...											% lino_new_min
				GV.tol_1);									% tol
		end
		
		% Collect the data of all symbols:
		if    (PP.obj(iobj).symbolpar.display==1)           &&...
				APP.CreatemapSettingsCreateSymbolsMenu.Checked&&...
				get_symb
			force_keep_data					= false;		% Use the filter PP.obj(iobj,1).symbolpar
			filter_nla_separatly				= 0;
			id_sym_node_cv						= cell(length(itable_symbol_eqtags),1);
			id_sym_way_cv						= cell(length(itable_symbol_eqtags),1);
			for iseqt=1:length(itable_symbol_eqtags)
				id_sym_node_cv{iseqt,1}		= zeros(0,1);
				id_sym_way_cv{iseqt,1}		= zeros(0,1);
			end
			read_relations						= true;
			read_nodes_ways					= true;
			obj_eqtags_ioeqt					= [];
			msg2									= sprintf('%s: get symbols',msg);
			[~,~,~]								= plotosmdata_getdata_symbols(...
				iobj,...
				i_table_plot,...
				force_keep_data,...
				filter_nla_separatly,...
				isym_symbol_eqtags,...
				itable_symbol_eqtags,...
				text_tag_symbol_eqtags,...
				id_sym_node_cv,...
				id_sym_way_cv,...
				read_relations,...
				read_nodes_ways,...
				obj_eqtags_ioeqt,...
				msg2);
		end
		
		% Collect the data of all texts:
		if    (PP.obj(iobj).textpar.display==1)           &&...
				APP.CreatemapSettingsCreateTextsMenu.Checked&&...
				get_text
			force_keep_data					= false;		% Use the filter PP.obj(iobj,1).textpar
			filter_nla_separatly				= 0;
			read_relations						= true;
			id_txt_node_cv						= cell(length(itable_text_eqtags),1);
			id_txt_way_cv						= cell(length(itable_text_eqtags),1);
			for iteqt=1:length(itable_text_eqtags)
				id_txt_node_cv{iteqt,1}		= zeros(0,1);
				id_txt_way_cv{iteqt,1}		= zeros(0,1);
			end
			read_nodes_ways					= true;
			obj_eqtags_ioeqt					= [];
			msg2									= sprintf('%s: get texts',msg);
			[~,~,~]								= plotosmdata_getdata_texts(...
				iobj,...
				i_table_plot,...
				force_keep_data,...
				filter_nla_separatly,...
				itable_text_eqtags,...
				id_txt_node_cv,...
				id_txt_way_cv,...
				read_relations,...
				read_nodes_ways,...
				obj_eqtags_ioeqt,...
				msg2);
		end
		
	else
		% Filter by key:
		
		% --------------------------------------------------------------------------------------------------------------
		% Get data of lines and areas:
		
		% Search the table OSMDATA_TABLE(i_table_plot,:) for the keys given in PP.obj(iobj).filter_by_key.incltagkey:
		[PLOTDATA.obj(iobj,1).obj_eqtags,itable_obj_eqtags]	= filter_objecttags(iobj,i_table_plot,msg);
		
		% "Create map" log:
		if length(itable_obj_eqtags)>=1
			GV.log.create_map.text	= sprintf('%sNo    | Te/Sy | Text/Tag                                   | ',GV.log.create_map.text);
			GV.log.create_map.text	= sprintf('%s    Dimx |     Dimy |     Diag |   Length |     Area | Keep |\n',GV.log.create_map.text);
			GV.log.create_map.text	= sprintf('%sMinimum dimensions, project parameters:                    | ',GV.log.create_map.text);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).filter_by_key.mindimx);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).filter_by_key.mindimy);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).filter_by_key.mindiag);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).filter_by_key.minlength);
			GV.log.create_map.text	= sprintf('%s%8.3f |      |\n',GV.log.create_map.text,PP.obj(iobj,1).filter_by_key.minarea);
			GV.log.create_map.text	= sprintf('%sMinimum dimensions, displayed here:                        | ',GV.log.create_map.text);
			testout_mindimx	= PP.obj(iobj,1).filter_by_key.mindimx/GV.testout_minvalues_divisor;
			testout_mindimy	= PP.obj(iobj,1).filter_by_key.mindimy/GV.testout_minvalues_divisor;
			testout_mindiag	= PP.obj(iobj,1).filter_by_key.mindiag/GV.testout_minvalues_divisor;
			testout_minlength	= PP.obj(iobj,1).filter_by_key.minlength/GV.testout_minvalues_divisor;
			testout_minarea	= PP.obj(iobj,1).filter_by_key.minarea/GV.testout_minvalues_divisor;
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,testout_mindimx);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,testout_mindimy);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,testout_mindiag);
			GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,testout_minlength);
			GV.log.create_map.text	= sprintf('%s%8.3f |      |\n',GV.log.create_map.text,testout_minarea);
			if    (PP.obj(iobj).textpar.display==1)           &&...
					APP.CreatemapSettingsCreateTextsMenu.Checked&&...
					get_text
				GV.log.create_map.text	= sprintf('%sMinimum dimensions for placing the texts:                  | ',GV.log.create_map.text);
				GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).textpar.mindimx);
				GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).textpar.mindimy);
				GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).textpar.mindiag);
				GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).textpar.minlength);
				GV.log.create_map.text	= sprintf('%s%8.3f |      |\n',GV.log.create_map.text,PP.obj(iobj,1).textpar.minarea);
			end
			if    (PP.obj(iobj).symbolpar.display==1)           &&...
					APP.CreatemapSettingsCreateSymbolsMenu.Checked&&...
					get_symb
				GV.log.create_map.text	= sprintf('%sMinimum dimensions for placing the symbols:                | ',GV.log.create_map.text);
				GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).symbolpar.mindimx);
				GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).symbolpar.mindimy);
				GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).symbolpar.mindiag);
				GV.log.create_map.text	= sprintf('%s%8.3f | ',GV.log.create_map.text,PP.obj(iobj,1).symbolpar.minlength);
				GV.log.create_map.text	= sprintf('%s%8.3f |      |\n',GV.log.create_map.text,PP.obj(iobj,1).symbolpar.minarea);
			end
		end
		
		% Initializations:
		if get_liar
			% Initialize the connected ways:
			PLOTDATA.obj(iobj,1).connways		= connect_ways([]);
		end
		if get_text
			% If GV.get_nodes_ways_repeatedly_texts=false: Use each OSM ID for every text only once!
			id_txt_node_cv						= cell(length(itable_text_eqtags),1);
			id_txt_way_cv						= cell(length(itable_text_eqtags),1);
			for iteqt=1:length(itable_text_eqtags)
				id_txt_node_cv{iteqt,1}		= zeros(0,1);
				id_txt_way_cv{iteqt,1}		= zeros(0,1);
			end
			id_txt_node_cv_0					= id_txt_node_cv;
			id_txt_way_cv_0					= id_txt_way_cv;
		end
		if get_symb
			% If GV.get_nodes_ways_repeatedly_symbols=false: Use each OSM ID for every symbol only once!
			id_sym_node_cv						= cell(length(itable_symbol_eqtags),1);
			id_sym_way_cv						= cell(length(itable_symbol_eqtags),1);
			for iseqt=1:length(itable_symbol_eqtags)
				id_sym_node_cv{iseqt,1}		= zeros(0,1);
				id_sym_way_cv{iseqt,1}		= zeros(0,1);
			end
			id_sym_node_cv_0					= id_sym_node_cv;
			id_sym_way_cv_0					= id_sym_way_cv;
		end
		
		for ioeqt=1:length(itable_obj_eqtags)
			if ~isempty(GV.test_readosm)
				GV.test_readosm.ioeqt		= ioeqt;
			end
			create_map_log_firstline		= false;
			itable_obj_eqtags_ioeqt			= itable_obj_eqtags{ioeqt,1};
			
			if ~isempty(itable_obj_eqtags_ioeqt)
				
				% Check if all data found shall be printed, without filtering:
				force_keep_data	= false;
				for c_tags=1:size(PP.obj(iobj,1).filter_by_key.incltagkey,2)
					if ~isempty(PP.obj(iobj,1).filter_by_key.incltagkey{1,c_tags})
						for c_keep_val=1:size(PP.obj(iobj,1).filter_by_key.keep_values,2)
							if strcmp(...
									PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},...						% e.g.:	'name=Rotach'
									sprintf('%s=%s',...
									PP.obj(iobj,1).filter_by_key.incltagkey{1,c_tags},...			%			'name'
									PP.obj(iobj,1).filter_by_key.keep_values{1,c_keep_val}))		%			'Rotach'
								force_keep_data	= true;
								break
							end
						end
					end
					if force_keep_data
						break
					end
				end
				
				% Control repeated use of nodes and ways:
				id_obj_node_v		= uint64([]);
				id_obj_way_v		= uint64([]);
				id_rel_node_v		= uint64([]);					% id_obj_node_v of relations
				id_rel_way_v		= uint64([]);					% id_obj_way_v  of relations
				
				% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
				% Relations:
				for i_itable=1:length(itable_obj_eqtags_ioeqt)
					itable				= itable_obj_eqtags_ioeqt(i_itable,1);
					if ~isempty(GV.test_readosm)
						GV.test_readosm.itable		= itable;
					end
					
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						WAITBAR.t1	= clock;
						set(GV_H.text_waitbar,'String',sprintf('%s: Tag %g/%g (%s): relations %g/%g',msg,...
							ioeqt,length(itable_obj_eqtags),PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},...
							i_itable,length(itable_obj_eqtags_ioeqt)));
						drawnow;
					end
					
					if strcmp(OSMDATA_TABLE.Type(itable),'relation')
						
						% Get the data of lines and areas:
						if get_liar
							
							connways_eqtags	= connect_ways([]);
							if isempty(PLOTDATA.obj(iobj,1).connways)
								lino_new_min	= 1;
							else
								lino_new_min	= PLOTDATA.obj(iobj,1).connways.lino_max+1;
							end
							
							% % % if OSMDATA_TABLE.ID(itable)==390371
							% % % 	set_breakpoint=1;
							% % % end
							% % % if strcmp(PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},'name:de=Main')
							% % % 	set_breakpoint=1;
							% % % end
							
							% Read the OSM-data: relations:
							if GV.get_nodes_ways_repeatedly
								id_obj_node_v		= uint64([]);
								id_obj_way_v		= uint64([]);
							end
							[~,~,~,connways_eqtags,~,id_obj_node_v,id_obj_way_v]	= getdata_relation(...
								OSMDATA_TABLE_INWR(itable),...					% ir
								connways_eqtags,...									% connways
								iobj,...													% iobj
								[],...													% lino
								PLOTDATA.obj(iobj,1).linewidth,...				% liwi
								[],...													% in_relation_v
								id_obj_node_v,...										% id_obj_node_v
								id_obj_way_v,...										% id_obj_way_v
								lino_new_min);											% lino_new_min
							if GV.get_nodes_ways_repeatedly
								id_rel_node_v		= unique([id_rel_node_v;id_obj_node_v]);
								id_rel_way_v		= unique([id_rel_way_v ;id_obj_way_v ]);
							end
							
							% It may happen that connways_eqtags does not contain any data, for example if the values
							% defined in the project parameters for relation_role_incl and relation_role_excl
							% exclude all data contained in the relation.
							if    ~isempty(connways_eqtags.nodes)||...
									~isempty(connways_eqtags.lines)||...
									~isempty(connways_eqtags.areas)
								% connways_eqtags contains data:
								
								% Filter small objects out and save the OSM data of relations in PLOTDATA:
								filter_nla_separatly		= 0;							% Always use the dimension of the whole relation!
								msg2							= sprintf('%s: Tag %g/%g (%s): relations %g/%g: filtering',msg,...
									ioeqt,length(itable_obj_eqtags),PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},...
									i_itable,length(itable_obj_eqtags_ioeqt));
								[PLOTDATA.obj(iobj,1).connways,...
									dx_all_mm,...
									dy_all_mm,...
									diag_all_mm,...
									length_all_mm,...
									area_all_mm2,...
									~,...
									~,...
									~,...
									~,...
									~,...
									~,...
									~,...
									~,...
									~,...
									~,...
									~,...
									~]	= plotosmdata_getdata_filterout(...
									connways_eqtags,...
									PLOTDATA.obj(iobj,1).connways,...
									PP.obj(iobj,1).filter_by_key.mindimx,...
									PP.obj(iobj,1).filter_by_key.mindimy,...
									PP.obj(iobj,1).filter_by_key.mindiag,...
									PP.obj(iobj,1).filter_by_key.minlength,...
									PP.obj(iobj,1).filter_by_key.minarea,...
									filter_nla_separatly,...
									force_keep_data,...
									PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},...
									msg2);
								
								% "Create map" log:
								if    force_keep_data||(...
										(dx_all_mm    >=testout_mindimx  )&&...
										(dy_all_mm    >=testout_mindimy  )&&...
										(diag_all_mm  >=testout_mindiag  )&&...
										(length_all_mm>=testout_minlength)&&...
										(area_all_mm2 >=testout_minarea  )     )
									if ~create_map_log_firstline
										GV.log.create_map.text	= sprintf('%s%5.0f |       | ',GV.log.create_map.text,ioeqt);
										create_map_log_firstline	= true;
									else
										GV.log.create_map.text	= sprintf('%s      |       | ',GV.log.create_map.text);
									end
									obj_eqtags_ioeqt_1	= PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1};
									obj_eqtags_ioeqt_1	= obj_eqtags_ioeqt_1(1:min(33,length(obj_eqtags_ioeqt_1)));
									testout_obj				= sprintf('relat: ''%s''',obj_eqtags_ioeqt_1);
									GV.log.create_map.text	= sprintf('%s%s%s | ',GV.log.create_map.text,testout_obj,blanks(42-length(testout_obj)));
									GV.log.create_map.text	= sprintf('%s%s | ',GV.log.create_map.text,sprintf('%8.3f',dx_all_mm));
									GV.log.create_map.text	= sprintf('%s%s | ',GV.log.create_map.text,sprintf('%8.3f',dy_all_mm));
									GV.log.create_map.text	= sprintf('%s%s | ',GV.log.create_map.text,sprintf('%8.3f',diag_all_mm));
									GV.log.create_map.text	= sprintf('%s%s | ',GV.log.create_map.text,sprintf('%8.3f',length_all_mm));
									GV.log.create_map.text	= sprintf('%s%s | ',GV.log.create_map.text,sprintf('%8.3f',area_all_mm2));
									if force_keep_data
										GV.log.create_map.text	= sprintf('%s   X |\n',GV.log.create_map.text);
									else
										GV.log.create_map.text	= sprintf('%s     |\n',GV.log.create_map.text);
									end
								end
								
							end
							
						end
						
						% Collect the data of all symbols:
						if    (PP.obj(iobj).symbolpar.display==1)           &&...
								APP.CreatemapSettingsCreateSymbolsMenu.Checked&&...
								get_symb
							filter_nla_separatly			= 0;				% Always use the dimension of the whole relation!
							read_relations					= true;
							read_nodes_ways				= false;
							id_sym_node_rel_cv			= id_sym_node_cv_0;		% cell array of empty elements
							id_sym_way_rel_cv				= id_sym_way_cv_0;		% cell array of empty elements
							msg2								= sprintf('%s: Tag %g/%g (%s): relations %g/%g: get symbols',msg,...
								ioeqt,length(itable_obj_eqtags),PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},...
								i_itable,length(itable_obj_eqtags_ioeqt));
							[id_sym_node_rel_cv,id_sym_way_rel_cv,notisempty_sym_v]	= plotosmdata_getdata_symbols(...
								iobj,...
								itable,...
								force_keep_data,...
								filter_nla_separatly,...
								isym_symbol_eqtags,...
								itable_symbol_eqtags,...
								text_tag_symbol_eqtags,...
								id_sym_node_rel_cv,...
								id_sym_way_rel_cv,...
								read_relations,...
								read_nodes_ways,...
								PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},...
								msg2);
							if ~GV.get_nodes_ways_repeatedly_symbols
								for iseqt=1:size(id_sym_node_cv,1)
									if notisempty_sym_v(iseqt,1)
										id_sym_node_cv{iseqt,1}	= unique([id_sym_node_cv{iseqt,1};id_sym_node_rel_cv{iseqt,1}]);
										id_sym_way_cv{iseqt,1}	= unique([id_sym_way_cv{iseqt,1} ;id_sym_way_rel_cv{iseqt,1}]);
									end
								end
							end
						end
						
						% Collect the data of all texts:
						if    (PP.obj(iobj).textpar.display==1)           &&...
								APP.CreatemapSettingsCreateTextsMenu.Checked&&...
								get_text
							filter_nla_separatly			= 0;				% Always use the dimension of the whole relation!
							read_relations					= true;
							read_nodes_ways				= false;
							id_txt_node_rel_cv			= id_txt_node_cv_0;		% cell array of empty elements
							id_txt_way_rel_cv				= id_txt_way_cv_0;		% cell array of empty elements
							msg2								= sprintf('%s: Tag %g/%g (%s): relations %g/%g: get texts',msg,...
								ioeqt,length(itable_obj_eqtags),PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},...
								i_itable,length(itable_obj_eqtags_ioeqt));
							[id_txt_node_rel_cv,id_txt_way_rel_cv,notisempty_txt_v]	= plotosmdata_getdata_texts(...
								iobj,...
								itable,...
								force_keep_data,...
								filter_nla_separatly,...
								itable_text_eqtags,...
								id_txt_node_rel_cv,...
								id_txt_way_rel_cv,...
								read_relations,...
								read_nodes_ways,...
								PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},...
								msg2);
							if ~GV.get_nodes_ways_repeatedly_texts
								for iteqt=1:length(itable_text_eqtags)
									if notisempty_txt_v(iteqt,1)
										id_txt_node_cv{iteqt,1}	= unique([id_txt_node_cv{iteqt,1};id_txt_node_rel_cv{iteqt,1}]);
										id_txt_way_cv{iteqt,1}	= unique([id_txt_way_cv{iteqt,1};id_txt_way_rel_cv{iteqt,1}]);
									end
								end
							end
							
						end
						
					end
				end
				
				% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
				% Nodes and ways:
				
				% Get the data of lines and areas:
				if get_liar
					% Begin a new structure connways_eqtags:
					% 1) The remaining nodes and ways should not be connected with the relations.
					% 2) Optionally, every single connected line will be filtered out according to its dimension
					%    (PP.obj(iobj,1).filter_by_key.filter_nla_separatly~=0)
					
					% % % if OSMDATA_TABLE.ID(itable)==84202525
					% % % 	set_breakpoint=1;
					% % % end
					% % % if strcmp(PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},'name=Main')
					% % % 	set_breakpoint=1;
					% % % end
					
					connways_eqtags	= connect_ways([]);
					if isempty(PLOTDATA.obj(iobj,1).connways)
						lino_new_min	= 1;
					else
						lino_new_min	= PLOTDATA.obj(iobj,1).connways.lino_max+1;
					end
					if GV.get_nodes_ways_repeatedly
						if PP.obj(iobj).display_as_area~=0
							id_obj_node_v		= uint64([]);
							id_obj_way_v		= uint64([]);
						else
							id_obj_node_v		= id_rel_node_v;
							id_obj_way_v		= id_rel_way_v;
						end
					end
					ways		= [];
					for i_itable=1:length(itable_obj_eqtags_ioeqt)
						itable			= itable_obj_eqtags_ioeqt(i_itable,1);
						if ~isempty(GV.test_readosm)
							GV.test_readosm.itable		= itable;
						end
						
						% Waitbar:
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',sprintf('%s: Tag %g/%g (%s): nodes, ways %g/%g',msg,...
								ioeqt,length(itable_obj_eqtags),PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},...
								i_itable,length(itable_obj_eqtags_ioeqt)));
							drawnow;
						end
						
						% Read the OSM-data: nodes and ways:
						switch OSMDATA_TABLE.Type(itable)
							case 'node'
								if ~any(OSMDATA.id.node(1,OSMDATA_TABLE_INWR(itable))==id_obj_node_v)
									x	= OSMDATA.node_x_mm(1,OSMDATA_TABLE_INWR(itable));
									y	= OSMDATA.node_y_mm(1,OSMDATA_TABLE_INWR(itable));
									if ~isnan(x)&&~isnan(y)
										connways_eqtags	= ...
											connect_ways(...							%								Defaultvalues:
											connways_eqtags,...						% connways					-
											[],...										% connways_merge			[]
											x,...											% x							[]
											y,...											% y							[]
											iobj,...										% iobj						[]
											[],...										% lino						[]
											PLOTDATA.obj(iobj,1).linewidth,...	% liwi						[]
											OSMDATA_TABLE_INWR(itable),...		% in							0
											0,...											% iw_v						0
											0,...											% ir							0
											1,...											% l2a							1
											1,...											% s							1
											1,...											% lino_new_min				1
											'outer',...									% role						'outer'
											uint64(0),...								% relid						uint64(0)
											'',...										% tag							''
											GV.tol_1,...								% tol							GV.tol_1
											true,...										% conn_with_rev			true
											true);										% connect					true
										if ~GV.get_nodes_ways_repeatedly||(PP.obj(iobj).display_as_area==0)
											id_obj_node_v(end+1,1)				= OSMDATA.id.node(1,OSMDATA_TABLE_INWR(itable));
										end
									end
								end
							case 'way'
								if ~any(OSMDATA.id.way(1,OSMDATA_TABLE_INWR(itable))==id_obj_way_v)||...
										(PP.obj(iobj,1).add_ways_only_once==0)
									x	= OSMDATA.way(1,OSMDATA_TABLE_INWR(itable)).x_mm;
									y	= OSMDATA.way(1,OSMDATA_TABLE_INWR(itable)).y_mm;
									if ~isempty(GV.test_readosm)
										if    (sum(abs([x(1)   y(1)  ]-GV.test_readosm.p1))<1e-3)||...
												(sum(abs([x(end) y(end)]-GV.test_readosm.p1))<1e-3)
											GV.test_readosm.line(end+1).xy	= [x y];
											GV.test_readosm.iw_v(end+1)		= OSMDATA_TABLE_INWR(itable);
											GV.test_readosm.idw_v(end+1)		= OSMDATA.id.way(1,OSMDATA_TABLE_INWR(itable));
											GV.test_readosm.itable_v(end+1)	= GV.test_readosm.itable;
											GV.test_readosm.ioeqt_v(end+1)	= GV.test_readosm.ioeqt;
											set_breakpoint	= 1;
										end
									end
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
										if ~GV.get_nodes_ways_repeatedly||(PP.obj(iobj).display_as_area==0)
											if ic==1
												id_obj_way_v(end+1,1)				= OSMDATA.id.way(1,OSMDATA_TABLE_INWR(itable));
											end
										end
									end
								end
						end
						
					end		% end of: for i_itable=1:length(itable_obj_eqtags_ioeqt)
					
					% Connect the ways:
					connways_eqtags		= connect_ways_longest_line(...
						connways_eqtags,...						% connways
						ways,...										% ways
						iobj,...										% iobj
						[],...										% lino
						PLOTDATA.obj(iobj,1).linewidth,...	% liwi
						1,...											% l2a
						1,...											% s
						lino_new_min,...							% lino_new_min
						GV.tol_1);									% tol
					
					% It may happen that connways_eqtags does not contain any data, for example if the values
					% defined in the project parameters for relation_role_incl and relation_role_excl
					% exclude all data contained in the relation.
					if    ~isempty(connways_eqtags.nodes)||...
							~isempty(connways_eqtags.lines)||...
							~isempty(connways_eqtags.areas)
						% connways_eqtags contains data:
						
						% Filter small objects out and save the OSM data of nodes and ways in PLOTDATA:
						msg2					= sprintf('%s: Tag %g/%g (%s): nodes, ways: filtering',msg,...
							ioeqt,length(itable_obj_eqtags),PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1});
						[PLOTDATA.obj(iobj,1).connways,...
							~,...
							~,...
							~,...
							~,...
							~,...
							dx_node_mm,...
							dy_node_mm,...
							diag_node_mm,...
							dx_line_v_mm,...
							dy_line_v_mm,...
							diag_line_v_mm,...
							dx_area_v_mm,...
							dy_area_v_mm,...
							diag_area_v_mm,...
							length_lines_v_mm,...
							length_areas_v_mm,...
							area_v_mm2]	= plotosmdata_getdata_filterout(...
							connways_eqtags,...
							PLOTDATA.obj(iobj,1).connways,...
							PP.obj(iobj,1).filter_by_key.mindimx,...
							PP.obj(iobj,1).filter_by_key.mindimy,...
							PP.obj(iobj,1).filter_by_key.mindiag,...
							PP.obj(iobj,1).filter_by_key.minlength,...
							PP.obj(iobj,1).filter_by_key.minarea,...
							PP.obj(iobj,1).filter_by_key.filter_nla_separatly,...
							force_keep_data,...
							PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},...
							msg2);
						
						% "Create map" log:
						obj_eqtags_ioeqt_1	= PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1};
						obj_eqtags_ioeqt_1	= obj_eqtags_ioeqt_1(1:min(33,length(obj_eqtags_ioeqt_1)));
						testout_obj		= cell(0,1);
						testout_dx		= cell(0,1);
						testout_dy		= cell(0,1);
						testout_diag	= cell(0,1);
						testout_length	= cell(0,1);
						testout_area	= cell(0,1);
						if ~isempty(connways_eqtags.nodes)
							if    force_keep_data||(...
									(dx_node_mm  >=testout_mindimx  )&&...
									(dy_node_mm  >=testout_mindimy  )&&...
									(diag_node_mm>=testout_mindiag  )     )
								testout_obj{end+1,1}		= sprintf('nodes: ''%s''',obj_eqtags_ioeqt_1);
								testout_dx{end+1,1}		= sprintf('%8.3f',dx_node_mm);
								testout_dy{end+1,1}		= sprintf('%8.3f',dy_node_mm);
								testout_diag{end+1,1}	= sprintf('%8.3f',diag_node_mm);
								testout_length{end+1,1}	= '   0.000';
								testout_area{end+1,1}	= '   0.000';
							end
						end
						for k_line=1:size(connways_eqtags.lines,1)
							if    force_keep_data||(...
									(dx_line_v_mm(k_line,1)     >=testout_mindimx  )&&...
									(dy_line_v_mm(k_line,1)     >=testout_mindimy  )&&...
									(diag_line_v_mm(k_line,1)   >=testout_mindiag  )&&...
									(length_lines_v_mm(k_line,1)>=testout_minlength)     )
								testout_obj{end+1,1}		= sprintf('lines: ''%s''',obj_eqtags_ioeqt_1);
								testout_dx{end+1,1}		= sprintf('%8.3f',dx_line_v_mm(k_line,1));
								testout_dy{end+1,1}		= sprintf('%8.3f',dy_line_v_mm(k_line,1));
								testout_diag{end+1,1}	= sprintf('%8.3f',diag_line_v_mm(k_line,1));
								testout_length{end+1,1}	= sprintf('%8.3f',length_lines_v_mm(k_line,1));
								testout_area{end+1,1}	= '   0.000';
							end
						end
						for k_area=1:size(connways_eqtags.areas,1)
							if    force_keep_data||(...
									(dx_area_v_mm(k_area,1)     >=testout_mindimx  )&&...
									(dy_area_v_mm(k_area,1)     >=testout_mindimy  )&&...
									(diag_area_v_mm(k_area,1)   >=testout_mindiag  )&&...
									(length_areas_v_mm(k_area,1)>=testout_minlength)&&...
									(area_v_mm2(k_area,1)       >=testout_minarea  )     )
								testout_obj{end+1,1}		= sprintf('areas: ''%s''',obj_eqtags_ioeqt_1);
								testout_dx{end+1,1}		= sprintf('%8.3f',dx_area_v_mm(k_area,1));
								testout_dy{end+1,1}		= sprintf('%8.3f',dy_area_v_mm(k_area,1));
								testout_diag{end+1,1}	= sprintf('%8.3f',diag_area_v_mm(k_area,1));
								testout_length{end+1,1}	= sprintf('%8.3f',length_areas_v_mm(k_area,1));
								testout_area{end+1,1}	= sprintf('%8.3f',area_v_mm2(k_area,1));
							end
						end
						for k=1:size(testout_obj,1)
							if k==1
								if ~create_map_log_firstline
									GV.log.create_map.text	= sprintf('%s%5.0f |       | ',GV.log.create_map.text,ioeqt);
									create_map_log_firstline	= true;
								else
									GV.log.create_map.text	= sprintf('%s      |       | ',GV.log.create_map.text);
								end
							else
								GV.log.create_map.text	= sprintf('%s      |       | ',GV.log.create_map.text);
							end
							GV.log.create_map.text	= sprintf('%s%s%s | ',GV.log.create_map.text,testout_obj{k,1},blanks(42-length(testout_obj{k,1})));
							GV.log.create_map.text	= sprintf('%s%s | ',GV.log.create_map.text,testout_dx{k,1});
							GV.log.create_map.text	= sprintf('%s%s | ',GV.log.create_map.text,testout_dy{k,1});
							GV.log.create_map.text	= sprintf('%s%s | ',GV.log.create_map.text,testout_diag{k,1});
							GV.log.create_map.text	= sprintf('%s%s | ',GV.log.create_map.text,testout_length{k,1});
							GV.log.create_map.text	= sprintf('%s%s | ',GV.log.create_map.text,testout_area{k,1});
							if force_keep_data
								GV.log.create_map.text	= sprintf('%s   X |\n',GV.log.create_map.text);
							else
								GV.log.create_map.text	= sprintf('%s     |\n',GV.log.create_map.text);
							end
						end
						
					end
					
				end
				
				% Collect the data of all symbols:
				if    (PP.obj(iobj).symbolpar.display==1)           &&...
						APP.CreatemapSettingsCreateSymbolsMenu.Checked&&...
						get_symb
					read_relations		= false;
					read_nodes_ways	= true;
					msg2					= sprintf('%s: Tag %g/%g (%s): nodes, ways: get symbols',msg,...
						ioeqt,length(itable_obj_eqtags),PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1});
					[~,~,~]				= plotosmdata_getdata_symbols(...
						iobj,...
						itable_obj_eqtags_ioeqt,...
						force_keep_data,...
						PP.obj(iobj,1).filter_by_key.filter_nla_separatly,...
						isym_symbol_eqtags,...
						itable_symbol_eqtags,...
						text_tag_symbol_eqtags,...
						id_sym_node_cv,...
						id_sym_way_cv,...
						read_relations,...
						read_nodes_ways,...
						PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},...
						msg2);
				end
				
				% Collect the data of all texts:
				if    (PP.obj(iobj).textpar.display==1)           &&...
						APP.CreatemapSettingsCreateTextsMenu.Checked&&...
						get_text
					read_relations		= false;
					read_nodes_ways	= true;
					msg2					= sprintf('%s: Tag %g/%g (%s): nodes, ways: get texts',msg,...
						ioeqt,length(itable_obj_eqtags),PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1});
					[~,~,~]				= plotosmdata_getdata_texts(...
						iobj,...
						itable_obj_eqtags_ioeqt,...
						force_keep_data,...
						PP.obj(iobj,1).filter_by_key.filter_nla_separatly,...
						itable_text_eqtags,...
						id_txt_node_cv,...
						id_txt_way_cv,...
						read_relations,...
						read_nodes_ways,...
						PLOTDATA.obj(iobj,1).obj_eqtags{ioeqt,1},...
						msg2);
				end
				
			end		% end of: "if ~isempty(itable_obj_eqtags_ioeqt)"
			
		end			% end of: "for ioeqt=1:length(itable_obj_eqtags)"
		
	end				% end of: "if ~filter_by_key"
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Additional userdata:
	PLOTDATA.obj(iobj,1).ud_in_v			= [];
	PLOTDATA.obj(iobj,1).ud_iw_v			= [];
	PLOTDATA.obj(iobj,1).ud_ir_v			= [];
	if ~isempty(i_table_plot)
		if ~isempty(OSMDATA_TABLE)
			for i=1:length(i_table_plot)
				itable	= i_table_plot(i);
				itable	= max(0,round(itable));
				if itable>=1
					if height(OSMDATA_TABLE)>=itable
						% index in OSMDATA.node/OSMDATA.way/OSMDATA.relation:
						switch OSMDATA_TABLE.Type(itable)						% type: 'node'/'way'/'relation'
							case 'node'
								PLOTDATA.obj(iobj,1).ud_in_v	= [PLOTDATA.obj(iobj,1).ud_in_v(:);OSMDATA_TABLE_INWR(itable)];
							case 'way'
								PLOTDATA.obj(iobj,1).ud_iw_v	= [PLOTDATA.obj(iobj,1).ud_iw_v(:);OSMDATA_TABLE_INWR(itable)];
							case 'relation'
								PLOTDATA.obj(iobj,1).ud_ir_v	= [PLOTDATA.obj(iobj,1).ud_ir_v(:);OSMDATA_TABLE_INWR(itable)];
						end
					end
				end
			end
		end
	end
	PLOTDATA.obj(iobj,1).ud_in_v	= unique(PLOTDATA.obj(iobj,1).ud_in_v);
	PLOTDATA.obj(iobj,1).ud_iw_v	= unique(PLOTDATA.obj(iobj,1).ud_iw_v);
	PLOTDATA.obj(iobj,1).ud_ir_v	= unique(PLOTDATA.obj(iobj,1).ud_ir_v);
	
	% Testplot:
	if (testplot==1)&&(iobj==iobj_testplot)&&get_liar
		if size(PLOTDATA.obj(iobj,1).connways.lines,1)>0
			hf=figure(184295);
			clf(hf,'reset');
			set(hf,'Tag','maplab3d_figure');
			ha=axes;
			hold(ha,'on');
			for k=1:size(PLOTDATA.obj(iobj,1).connways.lines,1)
				% poly	= line2poly(...
				%	PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,1),...
				%	PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,2),{1;6});
				plot(ha,PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,1),PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,2))
			end
			axis(ha,'equal');
			setbreakpoint=1;
		end
	end
	
catch ME
	errormessage('',ME);
end

