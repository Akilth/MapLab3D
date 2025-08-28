function create_legend_map
% Create legend map objects
% All elements of the legend meet the conditions:
% -	iobj=0					In this way it is recognized whether a plot object belongs to the legend.
% -	prio>=prio_legbgd		In this way it is recognized whether a plot object belongs to the legend.
%									Get the legend priority: [poly_legbgd,prio_legbgd]=get_poly_legbgd;

global APP GV GV_H PP MAP_OBJECTS PLOTDATA SY ELE

try
	
	% Display state:
	stateisbusy	= display_on_gui('state','','isbusy');
	if ~stateisbusy
		t_start_statebusy	= clock;
		set(GV_H.text_waitbar,'String','');
		display_on_gui('state','Create legend ...','busy','add');
	end
	
	% Initializations:
	testplot		= 0;
	testout		= 0;
	if APP.CreatemapSettingsShowLegendTestplotMenu.Checked
		testplot		= 1;
	end
	
	%------------------------------------------------------------------------------------------------------------------
	% Clear an existing legend:
	%------------------------------------------------------------------------------------------------------------------
	
	% Delete all map objects with an equal or higher priority than prio_legbgd:
	[~,prio_legbgd,~]		= get_poly_legbgd;
	if prio_legbgd>0
		% The legend background exists:
		imapobj_delete_v	= [];
		for imapobj=1:size(MAP_OBJECTS,1)
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'prio')
					if MAP_OBJECTS(imapobj,1).h(i,1).UserData.prio>=prio_legbgd
						imapobj_delete_v	= [imapobj_delete_v;imapobj];
					end
				end
			end
		end
		plot_modify('delete',unique(imapobj_delete_v));		% Includes also display_map_objects
	end
	
	% Update MAP_OBJECTS_TABLE:
	display_map_objects;
	
	% If the legend is switched off: return:
	if strcmp(PP.legend.location,'none')
		% Display state:
		if ~stateisbusy
			set(GV_H.text_waitbar,'String','');
			display_on_gui('state',sprintf('Create legend ... done.'),'notbusy','replace');
		end
		return
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Create legend polygon objects:
	%------------------------------------------------------------------------------------------------------------------
	% Results:
	% Polygons of symbols and texts and the userdata
	% nr					number of rows
	% nc					number of columns
	% w_sym_m			width of every symbol																				nr x nc matrix
	% h_sym_m			height of every symbol																				nr x nc matrix
	% w_txt_m			width of every text																					nr x nc matrix
	% h_txt_m			height of every text																					nr x nc matrix
	% h_row_v			height of every row, all columns																	nr x 1  vector
	%						= number of lines * text_spacing_line
	% ls_row_v			line spacing to the row above, all columns													nr x 1  vector
	%						= text_spacing_para
	
	% Maximum object priority:
	prio_max	= -1;
	for iobj=1:size(PP.obj,1)
		if ~isempty(PP.obj(iobj,1).prio)
			prio_max		= max(prio_max,PP.obj(iobj,1).prio);
			prio_max		= max(prio_max,PP.obj(iobj,1).textpar.prio);
			prio_max		= max(prio_max,PP.obj(iobj,1).symbolpar.prio);
		end
	end
	% Reserved to be able to add objects with prio<prio_max later:
	% (poly_legbgd_extension in map2stl_preparation)
	prio_max	= prio_max+10;
	
	% Legend priority:
	prio_legbgd			= 10^ceil(log10(prio_max));
	
	% Object numbers that exist on the map:
	imapobj_exist_on_map_v		= false(size(PP.obj,1),1);
	for imapobj=1:size(MAP_OBJECTS,1)
		if MAP_OBJECTS(imapobj,1).iobj>0
			imapobj_exist_on_map_v(MAP_OBJECTS(imapobj,1).iobj,1)	= true;
		end
	end
	
	% Create legend polygon objects:
	nr								= size(PP.legend.element,1);
	nc								= find(~GV.pp_legend_element_col_is_empty_v,1,'last');
	ud_init						= struct;
	ud_init.color_no			= 999999;		% color number
	ud_init.color_no_pp		= 999999;		% color number project parameters
	ud_init.dz					= 999999;		% change in altitude compared to the elevation (>0 higher, <0 lower)
	ud_init.prio				= 999999;		% object priority
	ud_init.iobj				= 0;				% index in PP.obj
	ud_init.level				= 999999;		% 0: background, 1: foreground
	ud_init.surftype			= 0;				% surface type
	ud_init.shape0				= polyshape();	% original shape
	ud_init.rotation			= 0;				% rotation angle
	ud_init.obj_purpose		= cell(0,0);	% cell array: information about the usage of the object
	ud_init_text					= ud_init;
	ud_init_text.text_eqtags	= {};					% cell array of strings. Every row of the cell array is one line.
	ud_init_text.chstno			= 0;					% character style number
	ud_init_text.chstsettings	= [];					% character style settings
	ud_init_text.rotation		= 0;					% rotation angle
	ud_init_text.obj_purpose	= cell(0,0);		% cell array: information about the usage of the object
	w_txt_m				= zeros(size(PP.legend.element));	% Legend text
	h_txt_m				= zeros(size(PP.legend.element));
	ymin_txt_m			= zeros(size(PP.legend.element));
	ymax_txt_m			= zeros(size(PP.legend.element));
	w_sym_m				= zeros(size(PP.legend.element));	% Legend sample line, area, symbol
	h_sym_m				= zeros(size(PP.legend.element));
	ymin_sym_m			= zeros(size(PP.legend.element));
	ymax_sym_m			= zeros(size(PP.legend.element));
	lift_sym_txt_m		= zeros(size(PP.legend.element));	% lifting of the symbol center compared to the text baseline
	text_fgd_m			= struct;									% Legend text
	text_bgd_m			= struct;
	liar_fgd_m			= struct;									% Legend sample line or area
	liar_bgd_m			= struct;
	symb_fgd_m			= struct;									% Legend sample symbol
	symb_bgd_m			= struct;
	mapobj_m				= struct;									% DispAs, Description and Text/Tag
	prio_fgd				= prio_legbgd;
	h_row_v				= zeros(nr,1);		% Total height of the last line to the line number 2 of the row r
	for r=1:nr
		h_row_v(r,1)			= 0;
		for c=1:nc
			
			% Initializations:
			obj_purpose				= {'legend element';r;c};
			text_fgd_m(r,c).poly	= polyshape();
			text_bgd_m(r,c).poly	= polyshape();
			liar_fgd_m(r,c).poly	= polyshape();
			liar_bgd_m(r,c).poly	= polyshape();
			symb_fgd_m(r,c).poly	= polyshape();
			symb_bgd_m(r,c).poly	= polyshape();
			text_fgd_m(r,c).ud	= ud_init_text;
			text_bgd_m(r,c).ud	= ud_init_text;
			liar_fgd_m(r,c).ud	= ud_init;
			liar_bgd_m(r,c).ud	= ud_init;
			symb_fgd_m(r,c).ud	= ud_init;
			symb_bgd_m(r,c).ud	= ud_init;
			mapobj_m(r,c).disp	= '';					% Display as line or area
			mapobj_m(r,c).dscr	= '';
			mapobj_m(r,c).text	= '';
			
			if ~GV.pp_legend_element_row_is_empty_v(r,1)
				
				imapobj_exist_on_map	= false;
				iobj_v					= PP.legend.element(r,c).legsymb_objno{1,1};		% Legend: symbol: object number (0=deactiv)
				for i_iobj=1:length(iobj_v)
					iobj		= iobj_v(i_iobj);
					% If iobj==0, the text and the manually selected symbol (if specified) are always displayed.
					% If iobj>0 is specified and no object with this number exists on the map, the legend element
					% will not be displayed. In this way, a universal legend can be defined, from which only the
					% existing elements are displayed.
					if iobj>0
						imapobj_exist_on_map	= imapobj_exist_on_map_v(iobj,1);
						if imapobj_exist_on_map
							% If more than one object number is specified, the number of the first object
							% that actually appears in the map is used for the display in the legend:
							break
						end
					end
				end
				
				if ~strcmp(PP.legend.element(r,c).text_type,'map scale bar')
					
					% Description and Text/Tag:
					mapobj_m(r,c).dscr	= sprintf('Legend: element (%g,%g)',r,c);
					if    (iobj>=1             )&&...
							(iobj<=size(PP.obj,1))
						mapobj_m(r,c).dscr	= sprintf('%s: ObjNo %g',...
							mapobj_m(r,c).dscr,...
							iobj);
					end
					mapobj_m(r,c).text	= PP.legend.element(r,c).text{1,1};
					for itext=2:size(PP.legend.element(r,c).text,1)
						mapobj_m(r,c).text	= [mapobj_m(r,c).text ' ' PP.legend.element(r,c).text{itext,1}];
					end
					
					%------------------------------------------------------------------------------------------------------------
					% Create the legend symbols:
					
					% Use the settings of the object number iobj for creating the legend symbol (iobj>0):
					if imapobj_exist_on_map
						
						% Description and Text/Tag:
						mapobj_m(r,c).dscr	= sprintf('Legend: element (%g,%g)',r,c);
						if (iobj>=1             )&&...
								(iobj<=size(PP.obj,1))
							mapobj_m(r,c).dscr	= sprintf('%s: ObjNo %g',...
								mapobj_m(r,c).dscr,...
								iobj);
						end
						mapobj_m(r,c).text	= PP.legend.element(r,c).text{1,1};
						for itext=2:size(PP.legend.element(r,c).text,1)
							mapobj_m(r,c).text	= [mapobj_m(r,c).text ' ' PP.legend.element(r,c).text{itext,1}];
						end
						
						% Sample lines and areas:
						switch PP.legend.element(r,c).legsymb_type
							case {'keep free','empty'}
								% keep free:     no legend symbol, the space is not used for other elements
								% empty:         no legend symbol, the space is used for legend texts
								% nop
							case {'line','line+symbol'}
								% line:          show sample line, without line symbol
								% line+symbol:   show sample line, with line symbol if available
								if    (PP.obj(iobj).display==1)&&(PP.obj(iobj).display_as_line~=0)
									% Display as line:
									mapobj_m(r,c).disp	= 'line';
									% Line parameters:
									par		= PP.obj(iobj).linepar;
									[~,~,~,~,...
										liwi_min,...								% constant line width or minimum line width
										liwi_max,...								% constant line width or maximum line width
										~,~,...
										ip_sampling...								% ip_sampling
										]	= line2poly(...
										[],...										% x
										[],...										% y
										par,...										% par
										PP.obj(iobj).linestyle,...				% style
										iobj);										% iobj
									if PP.obj(iobj).linestyle==2
										% Reduce the minimum gap length at the beginning and end of the line (par{8})
										% so that 2 consecutive dashs are visible and not overlapped by a symbol.
										par{8}	= min(0.07,par{8});
									end
									if PP.obj(iobj).linestyle==3
										% Changing of the line width from minimum to maximum:
										par{8}	= 1;	% The maximum line width is always reached at the end of the line (0/1)
									end
									% Set the parameter sampling:
									sampling					= max(1,round(PP.legend.element(r,c).legsymb_linesampling));
									par{ip_sampling}		= sampling;
									% Adjust the line length depending on sampling:
									linelength				= PP.legend.element(r,c).legsymb_linelength;
									if sampling==1
										% sampling=1:          +-------------------------------
										%                      |                    ^
										%                      |                    |
										%                      |                    |
										%                      |                    |
										%                      |                    |liwi
										%                      |                    |
										%                      |                    |
										%                      |                    |
										%                      |                    v
										%                      +-------------------------------
										linelength_margin			= 0;
									else
										if sampling==2*round(sampling/2)
											% Sampling is an even number:
											% sampling=2:       +-------------------------------
											%                 /                      ^
											%               /                        |
											%             /                          |
											%           /  liwi/2                    |
											%         +<------->+                    |liwi
											%           \                            |
											%             \                          |
											%               \                        |
											%                 \                      v
											%                   +-------------------------------
											liwi						= (liwi_min+liwi_max)/2;
											linelength_margin		= liwi/2;
										else
											% Sampling is an odd number:
											% sampling=3:       +-------------------------------
											%                /                       ^
											%             /                          |
											%          +                             |
											%          |  linelength_margin          |
											%          |<------>+                    |liwi
											%          |                             |
											%          +                             |
											%             \                          |
											%                \                       v
											%                   +-------------------------------
											liwi						= (liwi_min+liwi_max)/2;
											linelength_margin		= liwi/2*cos(pi/2/sampling);
										end
									end
									linelength				= linelength-2*linelength_margin;
									% Create the line:
									[poly_liar_bgd,poly_liar_fgd,ud_liar_bgd,ud_liar_fgd]	= ...
										line2poly(...
										[-1;1]/2*linelength,...					% x
										[ 0;0],...									% y
										par,...										% par
										PP.obj(iobj).linestyle,...				% style
										iobj,...										% iobj
										obj_purpose,...							% obj_purpose
										'miter',...									% jointtype
										1);											% miterlimit
									prio_fgd						= prio_fgd+1;
									prio_bgd						= prio_fgd-0.25;
									if (numboundaries(poly_liar_bgd)>0)&&~isempty(ud_liar_bgd)
										liar_bgd_m(r,c).poly			= poly_liar_bgd;
										liar_bgd_m(r,c).ud			= ud_liar_bgd;
										liar_bgd_m(r,c).ud.prio		= prio_bgd;
										liar_bgd_m(r,c).ud.shape0	= poly_liar_bgd;
									end
									if (numboundaries(poly_liar_fgd)>0)&&~isempty(ud_liar_fgd)
										liar_fgd_m(r,c).poly			= poly_liar_fgd;
										liar_fgd_m(r,c).ud			= ud_liar_fgd;
										liar_fgd_m(r,c).ud.prio		= prio_fgd;
										liar_fgd_m(r,c).ud.shape0	= poly_liar_fgd;
									end
								end
							case {'area','area+symbol'}
								% area:          show sample area, without area symbol
								% area+symbol:   show sample area, with area symbol if available
								if (PP.obj(iobj).display==1)&&(PP.obj(iobj).display_as_area~=0)
									% Display as area:
									mapobj_m(r,c).disp	= 'area';
									% Create the area:
									[poly_liar_bgd,poly_liar_fgd,ud_liar_bgd,ud_liar_fgd]	= ...
										area2poly(polyshape(...
										[-1; 1;1;-1;-1]/2*PP.legend.element(r,c).legsymb_areawidth,...		% x
										[-1;-1;1; 1;-1]/2*PP.legend.element(r,c).legsymb_areadepth),...	% y
										PP.obj(iobj).areapar,...						% par
										PP.obj(iobj).areastyle,...						% style
										iobj,...												% iobj
										obj_purpose);										% obj_purpose
									% If the sample area is not rectangular: Overwrite poly_liar_bgd;
									sampling						= max(1,round(PP.legend.element(r,c).legsymb_areasampling));
									if sampling~=1
										par						= cell(3,1);
										par{1}					= PP.legend.element(r,c).legsymb_areadepth;		% line width
										par{2}					= sampling;													% sampling
										par{3}					= 0;															% lifting dz
										% Adjust the area width depending on sampling:
										areawidth				= PP.legend.element(r,c).legsymb_areawidth;
										if sampling==2*round(sampling/2)
											% Sampling is an even number:
											areawidth_margin		= PP.legend.element(r,c).legsymb_areadepth/2;
										else
											% Sampling is an odd number:
											areawidth_margin		= PP.legend.element(r,c).legsymb_areadepth/2*cos(pi/2/sampling);
										end
										areawidth				= areawidth-2*areawidth_margin;
										% Create the area:
										[poly_liar_bgd,~,~,~]	= ...
											line2poly(...
											[-1;1]/2*areawidth,...					% x
											[ 0;0],...									% y
											par,...										% par
											1,...											% style
											iobj,...										% iobj
											obj_purpose,...							% obj_purpose
											'miter',...									% jointtype
											1);											% miterlimit
									end
									% Assign the results:
									prio_fgd						= prio_fgd+1;
									prio_bgd						= prio_fgd-0.25;
									if (numboundaries(poly_liar_bgd)>0)&&~isempty(ud_liar_bgd)
										liar_bgd_m(r,c).poly			= poly_liar_bgd;
										liar_bgd_m(r,c).ud			= ud_liar_bgd;
										liar_bgd_m(r,c).ud.prio		= prio_bgd;
										liar_bgd_m(r,c).ud.shape0	= poly_liar_bgd;
									end
									if (numboundaries(poly_liar_fgd)>0)&&~isempty(ud_liar_fgd)
										liar_fgd_m(r,c).poly			= poly_liar_fgd;
										liar_fgd_m(r,c).ud			= ud_liar_fgd;
										liar_fgd_m(r,c).ud.prio		= prio_fgd;
										liar_fgd_m(r,c).ud.shape0	= poly_liar_fgd;
									end
								end
						end
						
						% Sample symbols:
						switch PP.legend.element(r,c).legsymb_type
							case {'line+symbol','area+symbol','symbol'}
								% line+symbol:   show sample line, with line symbol if available
								% area+symbol:   show sample area, with area symbol if available
								% symbol:        show only symbol
								if PP.obj(iobj).symbolpar.display~=0
									% The symbol is selected according to the tags of the filtered data. One object number
									% can have several symbols (for example object "route"="hiking" with several hiking signs like
									% "osmc:symbol"="Red cross on white background", "osmc:symbol"="...", ...).
									% To use a specific symbol, use the manual selection.
									% Here: use the first symbol:
									iseqt		= 1;
									ipoly		= 1;
									if ~isempty(PLOTDATA.obj(iobj,1).symb)
										if    ~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd)&&...
												~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_obj)&&...
												~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_bgd)&&...
												~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_obj)
											symb_fgd_m(r,c).poly		= PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_obj(ipoly,1);
											symb_bgd_m(r,c).poly		= PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd(ipoly,1);
											% Userdata:
											[symbuserdata_pp,~,errortext]	= get_pp_mapobjsettings(iobj,'symbol',obj_purpose);
											if ~isempty(errortext)
												errormessage(errortext);
											end
											% Assign userdata: symbol:
											prio_fgd						= prio_fgd+1;
											symb_fgd_m(r,c).ud.color_no		= symbuserdata_pp.color_no_fgd;
											symb_fgd_m(r,c).ud.color_no_pp	= symbuserdata_pp.color_no_fgd;
											symb_fgd_m(r,c).ud.dz				= symbuserdata_pp.dz_fgd;
											symb_fgd_m(r,c).ud.prio				= prio_fgd;
											symb_fgd_m(r,c).ud.iobj				= iobj;
											symb_fgd_m(r,c).ud.level			= 1;
											symb_fgd_m(r,c).ud.surftype		= symbuserdata_pp.surftype_fgd;
											symb_fgd_m(r,c).ud.rotation		= 0;
											symb_fgd_m(r,c).ud.obj_purpose	= obj_purpose;
											symb_fgd_m(r,c).ud.shape0			= symb_fgd_m(r,c).poly;
											% Assign userdata: background:
											prio_bgd						= prio_fgd-0.25;
											symb_bgd_m(r,c).ud.color_no		= symbuserdata_pp.color_no_bgd;
											symb_bgd_m(r,c).ud.color_no_pp	= symbuserdata_pp.color_no_bgd;
											symb_bgd_m(r,c).ud.dz				= symbuserdata_pp.dz_bgd;
											symb_bgd_m(r,c).ud.prio				= prio_bgd;
											symb_bgd_m(r,c).ud.iobj				= iobj;
											symb_bgd_m(r,c).ud.level			= 0;
											symb_bgd_m(r,c).ud.surftype		= symbuserdata_pp.surftype_bgd;
											symb_bgd_m(r,c).ud.rotation		= 0;
											symb_bgd_m(r,c).ud.obj_purpose	= obj_purpose;
											symb_bgd_m(r,c).ud.shape0			= symb_bgd_m(r,c).poly;
											% Translate to the origin:
											[xlim,ylim]					= boundingbox(union(symb_bgd_m(r,c).poly,symb_fgd_m(r,c).poly));
											symb_bgd_m(r,c).poly		= translate(symb_bgd_m(r,c).poly,-mean(xlim),-mean(ylim));
											symb_fgd_m(r,c).poly		= translate(symb_fgd_m(r,c).poly,-mean(xlim),-mean(ylim));
										end
									end
								end
						end
					end						% end of "if imapobj_exist_on_map"
					
					% Use the manual selection for creating the legend symbol:
					% The symbol assigned above will be overwritten if necessary.
					if    ~isempty(PP.legend.element(r,c).legsymb_mansel_key)&&...
							~isempty(PP.legend.element(r,c).legsymb_mansel_val)
						symbol_found	= false;
						isym				= 0;
						while (isym<length(SY))&&~symbol_found
							isym			= isym+1;
							out_key		= regexpi(PP.legend.element(r,c).legsymb_mansel_key,...
								regexptranslate('wildcard',SY(isym).k),'match');
							if strcmp(PP.legend.element(r,c).legsymb_mansel_key,out_key)
								% Match of the keys:
								out_val	= regexpi(PP.legend.element(r,c).legsymb_mansel_val,...
									regexptranslate('wildcard',SY(isym).v),'match');
								if strcmp(PP.legend.element(r,c).legsymb_mansel_val,out_val)
									% Match of the values:
									% Assign the symbol:
									symb_fgd_m(r,c).poly	= SY(isym).poly_sym;
									symb_bgd_m(r,c).poly	= SY(isym).poly_bgd;
									% Userdata:
									obj_purpose_mansel		= {'legend symbol manual selection';r;c};
									[symbuserdata_pp,~,errortext]	= get_pp_mapobjsettings(iobj,'symbol',obj_purpose_mansel);
									if ~isempty(errortext)
										errormessage(errortext);
									end
									% Assign userdata: symbol:
									prio_fgd									= prio_fgd+1;
									symb_fgd_m(r,c).ud.color_no		= symbuserdata_pp.color_no_fgd;
									symb_fgd_m(r,c).ud.color_no_pp	= symbuserdata_pp.color_no_fgd;
									symb_fgd_m(r,c).ud.dz				= symbuserdata_pp.dz_fgd;
									symb_fgd_m(r,c).ud.prio				= prio_fgd;
									symb_fgd_m(r,c).ud.level			= 1;
									symb_fgd_m(r,c).ud.surftype		= symbuserdata_pp.surftype_fgd;
									symb_fgd_m(r,c).ud.rotation		= 0;
									symb_fgd_m(r,c).ud.obj_purpose	= obj_purpose_mansel;
									symb_fgd_m(r,c).ud.shape0			= symb_fgd_m(r,c).poly;
									% Assign userdata: background:
									prio_bgd									= prio_fgd-0.25;
									symb_bgd_m(r,c).ud.color_no		= symbuserdata_pp.color_no_bgd;
									symb_bgd_m(r,c).ud.color_no_pp	= symbuserdata_pp.color_no_bgd;
									symb_bgd_m(r,c).ud.dz				= symbuserdata_pp.dz_bgd;
									symb_bgd_m(r,c).ud.prio				= prio_bgd;
									symb_bgd_m(r,c).ud.level			= 0;
									symb_bgd_m(r,c).ud.surftype		= symbuserdata_pp.surftype_bgd;
									symb_bgd_m(r,c).ud.rotation		= 0;
									symb_bgd_m(r,c).ud.obj_purpose	= obj_purpose_mansel;
									symb_bgd_m(r,c).ud.shape0			= symb_bgd_m(r,c).poly;
									% Translate to the origin:
									[xlim,ylim]					= boundingbox(union(symb_bgd_m(r,c).poly,symb_fgd_m(r,c).poly));
									symb_bgd_m(r,c).poly		= translate(symb_bgd_m(r,c).poly,-mean(xlim),-mean(ylim));
									symb_fgd_m(r,c).poly		= translate(symb_fgd_m(r,c).poly,-mean(xlim),-mean(ylim));
									% Scale:
									Kw								= PP.legend.element(r,c).legsymb_areawidth/(xlim(2)-xlim(1));
									Kh								= PP.legend.element(r,c).legsymb_areadepth/(ylim(2)-ylim(1));
									K								= min(Kw,Kh);
									symb_bgd_m(r,c).poly		= scale(symb_bgd_m(r,c).poly,K,[0 0]);
									symb_fgd_m(r,c).poly		= scale(symb_fgd_m(r,c).poly,K,[0 0]);
									symbol_found				= true;
								end
							end
						end
					end
					% Legend symbols width and height:
					poly					= liar_fgd_m(r,c).poly;
					poly					= union(poly,liar_bgd_m(r,c).poly);
					poly					= union(poly,symb_fgd_m(r,c).poly);
					poly					= union(poly,symb_bgd_m(r,c).poly);
					if numboundaries(poly)>0
						[xlim,ylim]			= boundingbox(poly);
						w_sym_m(r,c)		= xlim(2)-xlim(1);
						h_sym_m(r,c)		= ylim(2)-ylim(1);
						ymin_sym_m(r,c)	= ylim(1);
						ymax_sym_m(r,c)	= ylim(2);
					end
					
					%------------------------------------------------------------------------------------------------------------
					% Create the legend texts:
					
					% Text-settings:
					if imapobj_exist_on_map||...		% There exist objects on the map or
							(iobj==0)						% use the manually selected symbol
						[textuserdata_pp,textpar_pp,errortext]	= get_pp_mapobjsettings(iobj,'text',obj_purpose);
						if ~isempty(errortext)
							errormessage(errortext);
						end
						chstno								= textpar_pp.charstyle_no;
						text_namevalue						= {...
							'FontName'           ;PP.charstyle(chstno,1).fontname;...
							'FontWeight'         ;PP.charstyle(chstno,1).fontweight;...
							'FontAngle'          ;PP.charstyle(chstno,1).fontangle;...
							'HorizontalAlignment';textpar_pp.horizontalalignment;...
							'VerticalAlignment'  ;textpar_pp.verticalalignment;...
							'Interpreter'        ;'none'};
						for itext=1:size(PP.legend.element(r,c).text,1)
							if ~isempty(PP.legend.element(r,c).text{itext,1})
								% old:
								% lift_sym_txt_m(r,c)		= PP.charstyle(chstno,1).fontsize*0.3;
								xtext							= 0;
								ytext							= 0-(itext-1)*PP.legend.element(r,c).text_spacing_line;
								h_row_v(r,1)				= max(h_row_v(r,1) ,(itext-1)*PP.legend.element(r,c).text_spacing_line);
								% Convert to polygon:
								[	poly_bgd,...											% poly_bgd
									poly_obj...												% poly_obj
									]=text2poly(...
									xtext,...												% x
									ytext,...												% y
									PP.legend.element(r,c).text{itext,1},...		% text_str
									PP.charstyle(chstno,1).fontsize/10,...			% fontsize_cm
									textpar_pp.rotation,...								% rotation
									PP.charstyle(chstno,1).print_res,...			% print_res
									PP.charstyle(chstno,1).no_frame,...				% no_frame
									PP.charstyle(chstno,1).par_frame,...			% par_frame
									PP.charstyle(chstno,1).no_bgd,...				% no_bgd
									PP.charstyle(chstno,1).par_bgd,...				% par_bgd
									text_namevalue);										% text_namevalue
								% Font widening:
								if PP.charstyle(chstno,1).fontwidening~=0
									fontwidening	= max(0,PP.charstyle(chstno,1).fontwidening);
									poly_obj		= polybuffer(poly_obj,fontwidening/2,'JointType','miter');
									poly_bgd		= union(poly_bgd,poly_obj);
								end
								% Assign text:
								text_fgd_m(r,c).poly(itext,1)							= poly_obj;
								text_bgd_m(r,c).poly(itext,1)							= poly_bgd;
								% Assign userdata: text:
								prio_fgd														= prio_fgd+1;
								text_fgd_m(r,c).ud(itext,1).color_no				= textuserdata_pp.color_no_fgd;
								text_fgd_m(r,c).ud(itext,1).color_no_pp			= textuserdata_pp.color_no_fgd;
								text_fgd_m(r,c).ud(itext,1).dz						= textuserdata_pp.dz_fgd;
								text_fgd_m(r,c).ud(itext,1).prio						= prio_fgd;
								text_fgd_m(r,c).ud(itext,1).iobj						= 0;
								text_fgd_m(r,c).ud(itext,1).level					= 1;
								text_fgd_m(r,c).ud(itext,1).surftype				= textuserdata_pp.surftype_fgd;
								text_fgd_m(r,c).ud(itext,1).text_eqtags{1,1}		= PP.legend.element(r,c).text{itext,1};
								text_fgd_m(r,c).ud(itext,1).chstno					= chstno;
								text_fgd_m(r,c).ud(itext,1).chstsettings			= PP.charstyle(chstno,1);
								text_fgd_m(r,c).ud(itext,1).rotation				= textpar_pp.rotation;
								text_fgd_m(r,c).ud(itext,1).obj_purpose			= obj_purpose;
								text_fgd_m(r,c).ud(itext,1).shape0					= text_fgd_m(r,c).poly(itext,1);
								% Assign userdata: background:
								prio_bgd														= prio_fgd-0.25;
								text_bgd_m(r,c).ud(itext,1).color_no				= textuserdata_pp.color_no_bgd;
								text_bgd_m(r,c).ud(itext,1).color_no_pp			= textuserdata_pp.color_no_bgd;
								text_bgd_m(r,c).ud(itext,1).dz						= textuserdata_pp.dz_bgd;
								text_bgd_m(r,c).ud(itext,1).prio						= prio_bgd;
								text_bgd_m(r,c).ud(itext,1).iobj						= 0;
								text_bgd_m(r,c).ud(itext,1).level					= 0;
								text_bgd_m(r,c).ud(itext,1).surftype				= textuserdata_pp.surftype_bgd;
								text_bgd_m(r,c).ud(itext,1).text_eqtags{1,1}		= PP.legend.element(r,c).text{itext,1};
								text_bgd_m(r,c).ud(itext,1).chstno					= chstno;
								text_bgd_m(r,c).ud(itext,1).chstsettings			= PP.charstyle(chstno,1);
								text_bgd_m(r,c).ud(itext,1).rotation				= textpar_pp.rotation;
								text_bgd_m(r,c).ud(itext,1).obj_purpose			= obj_purpose;
								text_bgd_m(r,c).ud(itext,1).shape0					= text_bgd_m(r,c).poly(itext,1);
							end
						end
						% Text width and height:
						poly					= union(text_fgd_m(r,c).poly,text_bgd_m(r,c).poly);
						if sum(numboundaries(poly))>0
							[xlim,ylim]			= boundingbox(poly);
							w_txt_m(r,c)		= xlim(2)-xlim(1);
							h_txt_m(r,c)		= ylim(2)-ylim(1);
							ymin_txt_m(r,c)	= ylim(1);
							ymax_txt_m(r,c)	= ylim(2);
						end
					end		% end of: if imapobj_exist_on_map||(iobj==0)
					
				end			% end of: if ~strcmp(PP.legend.element(r,c).text_type,'map scale bar')
				
			end				% end of: if ~GV.pp_legend_element_row_is_empty_v(r,1)
			
		end					% end of: for c=1:nc
	end						% end of: for r=1:nr
	
	% Not empty rows:
	row_is_not_empty		= false(nr,1);
	for r=1:nr
		for c=1:nc
			if    (sum(numboundaries(text_bgd_m(r,c).poly))>0)||...
					(sum(numboundaries(text_fgd_m(r,c).poly))>0)||...
					(    numboundaries(liar_bgd_m(r,c).poly )>0)||...
					(    numboundaries(liar_fgd_m(r,c).poly )>0)||...
					(    numboundaries(symb_bgd_m(r,c).poly )>0)||...
					(    numboundaries(symb_fgd_m(r,c).poly )>0)
				row_is_not_empty(r,1)		= true;
				break
			end
		end
	end
	
	% Symbol center position with respect to text baseline of line 1:
	method			= 2;
	switch method
		case 1
			for r=1:nr
				for c=1:nc
					lift_sym_txt_m(r,c)		= PP.legend.element(r,c).legsymb_dy;
				end
				c_nez		= lift_sym_txt_m(r,:)~=0;			% columns where legsymb_dy is not equal to zero
				if any(c_nez)
					% If there are in row r any values legsymb_dy not equal to zero:
					c_ez		= lift_sym_txt_m(r,:)==0;		% columns where legsymb_dy is equal to zero
					lift_sym_txt_m(r,c_ez)	= min(lift_sym_txt_m(r,c_nez));
				end
			end
		case 2
			for r=1:nr
				for c=1:nc
					lift_sym_txt_m(r,c)		= PP.legend.element(r,c).legsymb_dy;
				end
			end
	end
	
	% Line spacing of the first line of the row r to the last line of the row r-1 (ls_row_v):
	ls_row_v				= zeros(nr,1);
	for r=1:nr
		% Get the next non empty row above row r:
		r_above			= r-1;
		while (r_above>0)&&~row_is_not_empty(r_above,1)
			% The complete row above row r is empty and will not be displayed:
			r_above		= r_above-1;
		end
		for c=1:nc
			% ymin of the row above r, column c:
			if r_above>0
				% There are non empty rows above row r:
				ymin_txt_r_above	= ymin_txt_m(r_above,c);
				ymin_sym_r_above	= ymin_sym_m(r_above,c)+lift_sym_txt_m(r_above,c);
			end
			% ymax of the row r, column c:
			ymax_txt_r				= ymax_txt_m(r,c);
			ymax_sym_r				= ymax_sym_m(r,c)+lift_sym_txt_m(r,c);
			% Minimum line spacing ls_row between texts and symbols:
			if r_above==0
				% r is the topmost row:
				ls_row_r_c_txt_min		= -1e10;
				ls_row_r_c_sym_min		= -1e10;
			else
				ls_row_r_c_txt_min		= ymax_txt_r+PP.legend.dmin_legelements-(ymin_txt_r_above+h_row_v(r_above,1));
				ls_row_r_c_sym_min		= ymax_sym_r+PP.legend.dmin_legelements-(ymin_sym_r_above+h_row_v(r_above,1));
			end
			% Line spacing:
			if r==44
				test=1;
			end
			ls_row_v(r,1)			= max([...
				ls_row_v(r,1),...
				ls_row_r_c_txt_min,...
				ls_row_r_c_sym_min,...
				PP.legend.element(r,c).text_spacing_para]);
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Calculation of the column widths of texts and symbols:
	%
	% Values required for "Translate the polygons and testplot":
	% w_colsym_l_v		width of every symbol column, all rows, legsymb_position=left						1  x nc vector
	% w_colsym_r_v		width of every symbol column, all rows, legsymb_position=right						1  x nc vector
	% w_coltxt_l_v		width of every text column, all rows, legsymb_position=right (textpos=left)	1  x nc vector
	% w_coltxt_r_v		width of every text column, all rows, legsymb_position=left (textpos=right)	1  x nc vector
	%
	% Values required for "Translate the polygons and testplot" and "Map scale bar":
	% xl_txt_m			text box, x-value left side																	nr x nc matrix
	% xr_txt_m			text box, x-value right side																	nr x nc matrix
	%
	% Intermediate results (values not required for subsequent steps):
	% xleft_m					left position in the cell r,c, symbol or text									nr x nc matrix
	% w_txt_m_0					=w_txt_m, will not be changed															nr x nc matrix
	% unused_textwidth_m		unused textwidths																			nr x nc matrix
	% w_txt_min_m				minimum textwidths																		nr x nc matrix
	%
	% legsymb_position=left:
	% +------------------------------------------------------------------------------+
	% |                                       fw                                     |
	% |  +------------------------------------------------------------------------+  |
	% |fw|      dft                                                               |fw|
	% |  |    +------+    +---------------+      +------+    +---------------+    |  |
	% |  |dfl |legend|dst |legend Text    | dco  |legend|dst |legend Text    |dfr |  |
	% |  |    |symbol|    |row 1, column 1|      |symbol|    |row 1, column 2|    |  |
	% |  |    +------+    +---------------+   -  +------+    +---------------+    |  |
	% |  |      ^                             ^                                   |  |
	% |  |      v dmin_legelements            |text_spacing_para                  |  |
	% |  |    +------+    +---------------+   |  +------+    +---------------+    |  |
	% |  |    |legend|    |legend Text    |   |  |legend|    |legend Text    |    |  |
	% |  |    |symbol|    |row 2, column 1|   v  |symbol|    |row 2, column 2|    |  |
	% |  |    +------+    +---------------+   -  +------+    +---------------+    |  |
	% |  |      dfb                                                               |  |
	% |  +------------------------------------------------------------------------+  |
	% |                                       fw                                     |
	% +------------------------------------------------------------------------------+
	%
	% legsymb_position=right:
	% +------------------------------------------------------------------------------+
	% |                                       fw                                     |
	% |  +------------------------------------------------------------------------+  |
	% |fw|      dft                                                               |fw|
	% |  |    +---------------+    +------+      +---------------+    +------+    |  |
	% |  |dfl |legend Text    |dst |legend| dco  |legend Text    |dst |legend|dfr |  |
	% |  |    |row 1, column 1|    |symbol|      |row 1, column 2|    |symbol|    |  |
	% |  |    +---------------+    +------+   -  +---------------+    +------+    |  |
	% |  |      ^                             ^                                   |  |
	% |  |      v dmin_legelements            |text_spacing_para                  |  |
	% |  |    +---------------+    +------+   |  +---------------+    +------+    |  |
	% |  |    |legend Text    |    |legend|   |  |legend Text    |    |legend|    |  |
	% |  |    |row 2, column 1|    |symbol|      |row 2, column 2|    |symbol|    |  |
	% |  |    +---------------+    +------+   v  +---------------+    +------+    |  |
	% |  |      dfb                                                               |  |
	% |  +------------------------------------------------------------------------+  |
	% |                                       fw                                     |
	% +------------------------------------------------------------------------------+
	%         |
	%         xl_txt_m=0
	%
	%                                    w_txt_m(1,1)
	%                     |<-------------------------------------->|
	%   w_colsym_l_v(1,1) w_coltxt_r_v(1,1)   w_colsym_l_v(1,2) w_coltxt_r_v(1,2)
	%         |<---->|    |<------------->|      |<---->|    |<------------------>|
	%
	%         +------+    +-------------------------------------------------------+   -
	%         |symbol|    |texttexttexttexttexttexttexttexttexttext               |   ^ h_txt_m
	%         |      |    |line 1, row  1, symbol and text of column 2 are empty  |   v
	%         +------+    +-------------------------------------------------------+   - y_row_v(1,1) <-- text base line
	%                                                                                 ^
	%                                                                                 | ls_row_v(2,1)
	%         +------+    +---------------+      +------+    +--------------------+   |
	%         |symbol|    |texttexttext   |      |symbol|    |texttexttexttexttext|   |
	%         |      |    |line 1, row  2 |      |      |    |line 1, row  2      |   v
	%         +------+    +---------------+   -  +------+    +--------------------+   - y_row_v(2,1) <-- text base line
	%                                         ^                                       ^
	%                                         |text_spacing_line                      | h_row_v(2,1)
	%         +------+    +---------------+   |  +------+    +--------------------+   |
	%         |symbol|    |texttexttexttex|   |   symbol|    |text                |   |
	%         |      |    |line 2, row  2 |   v  |      |    |line 2, row  2      |   |
	%         +------+    +---------------+   -  +------+    +--------------------+   |              <-- text base line
	%                                         ^                                       |
	%                                         |text_spacing_line                      |
	%         +------+    +---------------+   |  +------+    +--------------------+   |
	%         |symbol|    |text           |   |   symbol|    |texttext            |   |
	%         |      |    |line 3, row  2 |   v  |      |    |line 3, row  2      |   v
	%         +------+    +---------------+   -  +------+    +--------------------+   -              <-- text base line
	
	w_txt_m_0				= w_txt_m;
	xleft_m					= zeros(size(PP.legend.element));			% left position in the cell r,c, symbol or text
	xl_txt_m					= zeros(size(PP.legend.element));			% text box, x-value left side
	xr_txt_m					= zeros(size(PP.legend.element));			% text box, x-value right side
	itest						= 0;													% iteration step
	f							= 1e6;												% iteration fault
	f_itestm1				= 0;
	while (f>1e-6)&&(abs(f-f_itestm1)>1e-6)&&(itest<250)
		itest						= itest+1;
		unused_textwidth_m	= ones(size(PP.legend.element))*1e20;	% unused textwidths
		w_txt_min_m				= w_txt_m_0;									% minimum textwidths
		
		% Symbol and text column width, depending on the symbol position:
		w_colsym_l_v			= zeros(1,nc);
		w_colsym_r_v			= zeros(1,nc);
		w_coltxt_l_v			= zeros(1,nc);
		w_coltxt_r_v			= zeros(1,nc);
		for r=1:nr
			if ~GV.pp_legend_element_row_is_empty_v(r,1)
				for c=1:nc
					if     strcmp(PP.legend.element(r,c).legsymb_position,'left')
						% Symbol left, text right:
						w_colsym_l_v(1,c)		= max(w_colsym_l_v(1,c),w_sym_m(r,c));
						w_coltxt_r_v(1,c)		= max(w_coltxt_r_v(1,c),w_txt_m(r,c));
					elseif strcmp(PP.legend.element(r,c).legsymb_position,'right')
						% Symbol right, text left:
						w_colsym_r_v(1,c)		= max(w_colsym_r_v(1,c),w_sym_m(r,c));
						w_coltxt_l_v(1,c)		= max(w_coltxt_l_v(1,c),w_txt_m(r,c));
					end
					w_colsymtxt				= max(w_colsym_l_v(1,c)+w_coltxt_r_v(1,c),w_colsym_r_v(1,c)+w_coltxt_l_v(1,c));
					w_coltxt_r_v(1,c)		= w_colsymtxt-w_colsym_l_v(1,c);
					w_coltxt_l_v(1,c)		= w_colsymtxt-w_colsym_r_v(1,c);
				end
			end
		end
		
		% Previous steps:
		w_txt_m_itestm1		= w_txt_m;
		xl_txt_m_itestm1		= xl_txt_m;
		xr_txt_m_itestm1		= xr_txt_m;
		f_itestm1				= f;
		
		for r=1:nr			% First r=1:nr, then c=1:nc
			if ~GV.pp_legend_element_row_is_empty_v(r,1)
				for c=1:nc
					
					% xleft_m(r,c): left position in the cell r,c, symbol or text:
					for cleft=1:c
						if cleft==1
							xleft_m(r,c)	= 0;
						else
							if strcmp(PP.legend.element(r,cleft-1).legsymb_position,'left')
								xleft_m(r,c)	= xleft_m(r,c)+...
									w_colsym_l_v(1,cleft-1)+PP.legend.dst+w_coltxt_r_v(1,cleft-1)+PP.legend.dco;
							elseif strcmp(PP.legend.element(r,cleft-1).legsymb_position,'right')
								xleft_m(r,c)	= xleft_m(r,c)+...
									w_coltxt_l_v(1,cleft-1)+PP.legend.dst+w_colsym_r_v(1,cleft-1)+PP.legend.dco;
							end
						end
					end
					
					% xl_txt_m, xr_txt_m: left and right limits of the text box, cell r,c:
					c_text					= c;											% column numbers where to place the current text
					if strcmp(PP.legend.element(r,c).legsymb_position,'left')
						if (w_sym_m(r,c)==0)&&strcmp(PP.legend.element(r,c).legsymb_type,'empty')
							% Symbol is left and empty:
							xl_txt_m(r,c)		= xleft_m(r,c);
							xr_txt_m(r,c)		= xl_txt_m(r,c)   +w_colsym_l_v(1,c)+PP.legend.dst+w_coltxt_r_v(1,c);
							w_txt_min_m(r,c)	= w_txt_min_m(r,c)-w_colsym_l_v(1,c)-PP.legend.dst;
						else
							% Symbol is left and not empty:
							xl_txt_m(r,c)		= xleft_m(r,c)+w_colsym_l_v(1,c)+PP.legend.dst;
							xr_txt_m(r,c)		= xl_txt_m(r,c)+w_coltxt_r_v(1,c);
						end
					elseif strcmp(PP.legend.element(r,c).legsymb_position,'right')
						if (w_sym_m(r,c)==0)&&strcmp(PP.legend.element(r,c).legsymb_type,'empty')
							% Symbol is right and empty:
							xl_txt_m(r,c)		= xleft_m(r,c);
							xr_txt_m(r,c)		= xl_txt_m(r,c)   +w_coltxt_l_v(1,c)+PP.legend.dst+w_colsym_r_v(1,c);
							w_txt_min_m(r,c)	= w_txt_min_m(r,c)-w_coltxt_l_v(1,c)-PP.legend.dst;
						else
							% Symbol is right and not empty:
							xl_txt_m(r,c)		= xleft_m(r,c);
							xr_txt_m(r,c)		= xl_txt_m(r,c)+w_coltxt_l_v(1,c);
						end
					end
					
					% Free space to the left:
					if    strcmp(PP.legend.element(r,c).legsymb_position,'right')    ||(...
							strcmp(PP.legend.element(r,c).legsymb_position,'left')&&...
							(w_sym_m(r,c)==0)                                     &&...
							strcmp(PP.legend.element(r,c).legsymb_type,'empty')              )
						% Symbol position at r,c is right or
						% Symbol position at r,c is left  and the symbol is empty
						for cl=(c-1):-1:1
							if     (w_txt_m_0(r,cl)==0)                                  &&...
									strcmp(PP.legend.element(r,cl).legsymb_position,'left')&&...
									strcmp(PP.legend.element(r,cl).text_type,'empty')
								% Symbol position at r,cl is left and the text is empty:
								xl_txt_m(r,c)			= xl_txt_m(r,c)   -PP.legend.dco-w_coltxt_r_v(1,cl);
								w_txt_min_m(r,c)		= w_txt_min_m(r,c)-PP.legend.dco-w_coltxt_r_v(1,cl);
								c_text					= [cl;c_text];
								if     (w_sym_m(r,cl)==0)                                 &&...
										strcmp(PP.legend.element(r,cl).legsymb_type,'empty')
									xl_txt_m(r,c)			= xl_txt_m(r,c)   -PP.legend.dst-w_colsym_l_v(1,cl);
									w_txt_min_m(r,c)		= w_txt_min_m(r,c)-PP.legend.dst-w_colsym_l_v(1,cl);
								else
									break
								end
							elseif (w_sym_m(r,cl)==0)                                     &&...
									strcmp(PP.legend.element(r,cl).legsymb_position,'right')&&...
									strcmp(PP.legend.element(r,cl).legsymb_type,'empty')
								% Symbol position at r,cl is right and the symbol is empty:
								xl_txt_m(r,c)			= xl_txt_m(r,c)   -PP.legend.dco-w_colsym_r_v(1,cl);
								w_txt_min_m(r,c)		= w_txt_min_m(r,c)-PP.legend.dco-w_colsym_r_v(1,cl);
								if     (w_txt_m_0(r,cl)==0)                               &&...
										strcmp(PP.legend.element(r,cl).text_type,'empty')
									xl_txt_m(r,c)			= xl_txt_m(r,c)   -PP.legend.dst-w_coltxt_l_v(1,cl);
									w_txt_min_m(r,c)		= w_txt_min_m(r,c)-PP.legend.dst-w_coltxt_l_v(1,cl);
									c_text					= [cl;c_text];
								else
									break
								end
							else
								break
							end
						end
					end
					
					% Free space to the right:
					if    strcmp(PP.legend.element(r,c).legsymb_position,'left')      ||(...
							strcmp(PP.legend.element(r,c).legsymb_position,'right')&&...
							(w_sym_m(r,c)==0)                                      &&...
							strcmp(PP.legend.element(r,c).legsymb_type,'empty')               )
						% Symbol position at r,c is left  or
						% Symbol position at r,c is right and the symbol is empty
						for cr=(c+1):nc
							if     (w_sym_m(r,cr)==0)                                     &&...
									strcmp(PP.legend.element(r,cr).legsymb_position,'left' )&&...
									strcmp(PP.legend.element(r,cr).legsymb_type,'empty')
								% Symbol position at r,cr is left and the symbol is empty:
								if strcmp(PP.legend.element(r,cr-1).legsymb_position,'left')
									xr_txt_m(r,c)			= ...
										xr_txt_m(r,c)   +PP.legend.dco+w_colsym_l_v(1,cr);
									w_txt_min_m(r,c)		= ...
										w_txt_min_m(r,c)-PP.legend.dco-w_colsym_l_v(1,cr);
								elseif strcmp(PP.legend.element(r,cr-1).legsymb_position,'right')
									xr_txt_m(r,c)			= ...
										xr_txt_m(r,c)   +PP.legend.dst+w_colsym_r_v(1,cr-1)+PP.legend.dco+w_colsym_l_v(1,cr);
									w_txt_min_m(r,c)		= ...
										w_txt_min_m(r,c)-PP.legend.dst-w_colsym_l_v(1,cr-1)-PP.legend.dco-w_colsym_l_v(1,cr);
								end
								if     (w_txt_m_0(r,cr)==0)                               &&...
										strcmp(PP.legend.element(r,cr).text_type,'empty')
									xr_txt_m(r,c)			= xr_txt_m(r,c)   +PP.legend.dst+w_coltxt_r_v(1,cr);
									w_txt_min_m(r,c)		= w_txt_min_m(r,c)-PP.legend.dst-w_coltxt_r_v(1,cr);
									c_text					= [c_text;cr];
								else
									break
								end
							elseif (w_txt_m_0(r,cr)==0)                                   &&...
									strcmp(PP.legend.element(r,cr).legsymb_position,'right')&&...
									strcmp(PP.legend.element(r,cr).text_type,'empty')
								% Symbol position at r,cr is right and the text is empty:
								if strcmp(PP.legend.element(r,cr-1).legsymb_position,'left')
									xr_txt_m(r,c)			= ...
										xr_txt_m(r,c)   +PP.legend.dco+w_coltxt_l_v(1,cr);
									w_txt_min_m(r,c)		= ...
										w_txt_min_m(r,c)-PP.legend.dco-w_coltxt_l_v(1,cr);
								elseif strcmp(PP.legend.element(r,cr-1).legsymb_position,'right')
									xr_txt_m(r,c)			= ...
										xr_txt_m(r,c)   +PP.legend.dst+w_colsym_r_v(1,cr-1)+PP.legend.dco+w_coltxt_l_v(1,cr);
									w_txt_min_m(r,c)		= ...
										w_txt_min_m(r,c)-PP.legend.dst-w_coltxt_l_v(1,cr-1)-PP.legend.dco-w_coltxt_l_v(1,cr);
								end
								c_text					= [c_text;cr];
								if     (w_sym_m(r,cr)==0)                                 &&...
										strcmp(PP.legend.element(r,cr).legsymb_type,'empty')
									xr_txt_m(r,c)			= xr_txt_m(r,c)   +PP.legend.dst+w_colsym_r_v(1,cr);
									w_txt_min_m(r,c)		= w_txt_min_m(r,c)-PP.legend.dst-w_colsym_r_v(1,cr);
								else
									break
								end
							else
								break
							end
						end
					end
					
					% The available space must be at least equal to the actual text width:
					% xr_txt_m(r,c)-xl_txt_m(r,c) >= w_txt_m_0(r,c)
					% The difference is the unused textwidth:
					unused_textwidth_m(r,c)	= xr_txt_m(r,c)-xl_txt_m(r,c)-w_txt_m_0(r,c);
					if testout~=0
						fprintf(1,[...
							'itest=%2.0f   r=%2.0f   c=%2.0f   w_txt_min_m(r,c)=%g   ',...
							'w_txt_m(r,c)=%g   w_txt_m_0(r,c)=%g   xr-xl(r,c)=%g   utw=%g\n'],...
							itest,r,c,w_txt_min_m(r,c),...
							w_txt_m(r,c),w_txt_m_0(r,c),xr_txt_m(r,c)-xl_txt_m(r,c),unused_textwidth_m(r,c));
					end
					
				end
			end
		end
		
		% The text width is reduced by the minimum value of the unused textwidth.
		% This is done column by column. In this way the minimum unused textwidth becomes zero.
		min_unused_textwidth_v	= min(unused_textwidth_m,[],1);		% 1 x nc vector
		for c=1:nc
			w_txt_m(:,c)			= w_txt_m(:,c)-min_unused_textwidth_v(1,c);
		end
		% The text width must not be smaller than w_txt_min_m:
		w_txt_m(w_txt_m<w_txt_min_m)		= w_txt_min_m(w_txt_m<w_txt_min_m);
		
		% Fault value of the current step:
		f		= max([...
			max(abs(w_txt_m_itestm1    -w_txt_m    ),[],'all');...
			max(abs(xl_txt_m_itestm1   -xl_txt_m   ),[],'all');...
			max(abs(xr_txt_m_itestm1   -xr_txt_m   ),[],'all')    ]);
		if testout~=0
			fprintf(1,'itest=%g   f=%g\n',itest,f);
			setbreakpoint	= 1;
		end
		
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Map scale bar:
	%------------------------------------------------------------------------------------------------------------------
	
	project_scale		= PP.project.scale;
	for r=1:nr
		for c=1:nc
			if strcmp(PP.legend.element(r,c).text_type,'map scale bar')
				
				% Map scale bar:
				if sum(numboundaries(text_fgd_m(r,c).poly))~=0
					errormessage;
				end
				obj_purpose							= {'legend map scale bar';r;c};
				prio_fgd								= prio_fgd+1;
				prio_bgd								= prio_fgd-0.25;
				[textuserdata_pp,textpar_pp,errortext]	= get_pp_mapobjsettings(iobj,'text',obj_purpose);
				if ~isempty(errortext)
					errormessage(errortext);
				end
				chstno								= textpar_pp.charstyle_no;
				text_namevalue						= {...
					'FontName'           ;PP.charstyle(chstno,1).fontname;...
					'FontWeight'         ;PP.charstyle(chstno,1).fontweight;...
					'FontAngle'          ;PP.charstyle(chstno,1).fontangle;...
					'HorizontalAlignment';textpar_pp.horizontalalignment;...
					'VerticalAlignment'  ;textpar_pp.verticalalignment;...
					'Interpreter'        ;'none'};
				xl_msb				= xl_txt_m(r,c);
				xr_msb				= xr_txt_m(r,c);
				w_msb					= xr_msb-xl_msb;								% max. width of the map scale bar
				w_msb_realscale	= w_msb/1000*project_scale;
				exponent				= floor(log10(w_msb_realscale))-1;
				
				% Calculate the minor and major tick distances:
				% 			d_tick_mantissa__n_miticks__m	= [...
				% 				1 10;...
				% 				2 10;...
				% 				5 10;...
				% 				1  5;...
				% 				2  5;...
				% 				5  5;...
				% 				4  4;...
				% 				3  3;...
				% 				1  2;...
				% 				2  2;...
				% 				5  2];
				d_tick_mantissa__n_miticks__m	= [...		% d_tick_mantissa/n_miticks=
					1 10;...											% 1
					1  5;...											% 2
					2 10;...											% 2
					2  5;...											% 4
					1  2;...											% 5
					5 10;...											% 5
					2  2;...											% 10
					5  5;...											% 10
					5  2];											% 20
				dmin_mitick_realscale	= PP.legend.mapscalebar_dmin_mitick/1000*project_scale;
				d_mitick_realscale		= dmin_mitick_realscale-1;
				while (exponent<250)&&(d_mitick_realscale<dmin_mitick_realscale)
					exponent		= exponent+1;
					% d_tick_mantissa_v		= d_tick_mantissa__n_miticks__m(:,1)
					% n_miticks_v				= d_tick_mantissa__n_miticks__m(:,2)
					% d_mitick_realscale_v	= d_tick_mantissa_v./n_miticks_v*10^exponent
					for i=1:size(d_tick_mantissa__n_miticks__m,1)
						d_tick_mantissa		= d_tick_mantissa__n_miticks__m(i,1);
						n_miticks				= d_tick_mantissa__n_miticks__m(i,2);
						d_mitick_realscale	= d_tick_mantissa/n_miticks*10^exponent;
						if testout~=0
							fprintf(1,'exponent=%g  d_tick_mantissa=%g  n_miticks=%g\n',...
								exponent,d_tick_mantissa,n_miticks);
						end
						if d_mitick_realscale>=dmin_mitick_realscale
							break
						end
					end
				end
				if exponent>=3
					factor_unit		= 1000;
					msb_unit			= 'km';
				else
					factor_unit		= 1;
					msb_unit			= 'm';
				end
				% Results:
				% d_mitick_realscale															% minor tick distance real scale
				d_tick_realscale	= d_mitick_realscale*n_miticks;					% major tick distance real scale
				d_mitick				= d_mitick_realscale*1000/project_scale;		% minor tick distance model scale
				d_tick				= d_mitick*n_miticks;								% major tick distance model scale
				if testout~=0
					fprintf(1,'d_mitick_realscale=%g  d_tick_realscale=%g  d_mitick=%g  d_tick=%g\n',...
						d_mitick_realscale,d_tick_realscale,d_mitick,d_tick);
				end
				
				% mi_ma_ticks_m: major and minor ticks, model scale (column 1,2) and real (column 3,4) scale:
				% Example:
				% project_scale      = 50000
				% factor_unit        =  1000
				% d_mitick_realscale =   200
				% d_tick_realscale   =  1000
				% d_mitick           =     4
				% d_tick             =    20
				% n_miticks          =     5
				% mi_ma_ticks_m =
				%      0     0     0     0
				%    NaN     4   NaN   0.2
				%    NaN     8   NaN   0.4
				%    NaN    12   NaN   0.6
				%    NaN    16   NaN   0.8
				%     20    20     1     1
				%     40   NaN     2   NaN
				%     60   NaN     3   NaN
				%     80   NaN     4   NaN
				n_ticks				= floor(w_msb_realscale/d_tick_realscale);
				mi_ma_ticks_m		= zeros(0,4);
				for i1=0:n_ticks
					if i1==0
						for i2=0:n_miticks
							if i2==0
								mi_ma_ticks_m(end+1,:)	= [0 0 0 0];
							elseif i2==n_miticks
								mi_ma_ticks_m(end+1,:)	= [...
									d_tick i2*d_mitick ...
									d_tick_realscale/factor_unit i2*d_mitick_realscale/factor_unit];
							else
								mi_ma_ticks_m(end+1,:)	= [...
									nan i2*d_mitick ...
									nan i2*d_mitick_realscale/factor_unit];
							end
						end
					elseif i1>1
						mi_ma_ticks_m(end+1,:)	= [...
							i1*d_tick nan ...
							i1*d_tick_realscale/factor_unit nan];
					end
				end
				
				% Create the tick labels and ticks.
				% If the map scale bar with tick labels does not fit, reduce by one tick and repeat:
				msb_fits				= false;
				while (size(mi_ma_ticks_m,1)>=2)&&~msb_fits
					
					% Tick position ticks_v     and
					% tick labels   ticklabel_v:
					nisnan_ticks_v			= ~isnan(mi_ma_ticks_m(:,1));
					ticks_v					= mi_ma_ticks_m(nisnan_ticks_v,1);
					ticks_realscale_v		= mi_ma_ticks_m(nisnan_ticks_v,3);
					if isscalar(ticks_v)
						% Use only the minor ticks:
						nisnan_ticks_v			= ~isnan(mi_ma_ticks_m(:,2));
						ticks_v					= mi_ma_ticks_m(nisnan_ticks_v,2);
						ticks_realscale_v		= mi_ma_ticks_m(nisnan_ticks_v,4);
						% Tick labels at the first and last minor ticks:
						i_ticklabel_v		= [1;size(ticks_v,1);size(ticks_v,1)+1];
					else
						% Tick labels at the major ticks:
						if size(ticks_v,1)==2
							i_ticklabel_v		= [1;2;                size(ticks_v,1)+1];
						else
							i_ticklabel_v		= [1;2;size(ticks_v,1);size(ticks_v,1)+1];
						end
					end
					ticklabel_v				= cell(size(ticks_realscale_v,1)+1,1);
					for i=1:size(ticks_realscale_v,1)
						ticklabel_v{i,1}	= sprintf('%g',ticks_realscale_v(i,1));
					end
					ticklabel_v{end,1}	= msb_unit;
					
					% Initialize the tick labels:
					poly_text_all								= polyshape();
					text_fgd_m(r,c).poly						= polyshape();
					text_bgd_m(r,c).poly						= polyshape();
					text_fgd_m(r,c).ud						= ud_init_text;
					text_bgd_m(r,c).ud						= ud_init_text;
					
					% Initialize the ticks:
					liar_fgd_m(r,c).poly						= polyshape();
					liar_bgd_m(r,c).poly						= polyshape();
					liar_fgd_m(r,c).ud						= ud_init;
					liar_bgd_m(r,c).ud						= ud_init;
					
					% Assign area userdata:
					[areauserdata_pp,~,errortext]			= get_pp_mapobjsettings(iobj,'area',obj_purpose);
					if ~isempty(errortext)
						errormessage(errortext);
					end
					
					% Assign userdata: foreground:
					liar_fgd_m(r,c).ud.color_no			= areauserdata_pp.color_no_fgd;
					liar_fgd_m(r,c).ud.color_no_pp		= areauserdata_pp.color_no_fgd;
					liar_fgd_m(r,c).ud.dz					= areauserdata_pp.dz_fgd;
					liar_fgd_m(r,c).ud.prio					= prio_fgd;
					liar_fgd_m(r,c).ud.iobj					= 0;
					liar_fgd_m(r,c).ud.level				= 1;
					liar_fgd_m(r,c).ud.surftype			= areauserdata_pp.surftype_fgd;
					liar_fgd_m(r,c).ud.rotation			= 0;
					liar_fgd_m(r,c).ud.obj_purpose		= obj_purpose;
					
					% Assign userdata: background:
					liar_bgd_m(r,c).ud.color_no			= areauserdata_pp.color_no_bgd;
					liar_bgd_m(r,c).ud.color_no_pp		= areauserdata_pp.color_no_bgd;
					liar_bgd_m(r,c).ud.dz					= areauserdata_pp.dz_bgd;
					liar_bgd_m(r,c).ud.prio					= prio_bgd;
					liar_bgd_m(r,c).ud.iobj					= 0;
					liar_bgd_m(r,c).ud.level				= 0;
					liar_bgd_m(r,c).ud.surftype			= areauserdata_pp.surftype_bgd;
					liar_bgd_m(r,c).ud.rotation			= 0;
					liar_bgd_m(r,c).ud.obj_purpose		= obj_purpose;
					
					for i=1:size(i_ticklabel_v,1)
						i_ticklabel					= i_ticklabel_v(i,1);
						
						% x- and y-position of the tick labels:
						% (The whole map scale bar will be centered below before plotting.)
						if i_ticklabel<=size(ticks_v,1)
							if i_ticklabel==1
								xtext					= ticks_v(i_ticklabel,1)+PP.legend.mapscalebar_linewidth/2;
							elseif i_ticklabel==size(ticks_v,1)
								if (-1)^size(mi_ma_ticks_m,1)>0
									xtext				= ticks_v(i_ticklabel,1)-PP.legend.mapscalebar_linewidth/2;
								else
									xtext				= ticks_v(i_ticklabel,1)+PP.legend.mapscalebar_linewidth/2;
								end
							else
								xtext					= ticks_v(i_ticklabel,1);
							end
							text_str					= ticklabel_v(i_ticklabel,1);
						else
							if size(ticks_v,1)==2
								xtext					= (ticks_v(1,1)+ticks_v(2,1))/2;
							else
								xtext					= (ticks_v(2,1)+ticks_v(end,1))/2;
							end
							text_str					= msb_unit;
						end
						ytext							= 0;
						
						% Convert the tick labels to polygon:
						[	poly_bgd,...											% poly_bgd
							poly_obj...												% poly_obj
							]=text2poly(...
							xtext,...												% x
							ytext,...												% y
							text_str,...											% text_str
							PP.charstyle(chstno,1).fontsize/10,...			% fontsize_cm
							textpar_pp.rotation,...								% rotation
							PP.charstyle(chstno,1).print_res,...			% print_res
							PP.charstyle(chstno,1).no_frame,...				% no_frame
							PP.charstyle(chstno,1).par_frame,...			% par_frame
							PP.charstyle(chstno,1).no_bgd,...				% no_bgd
							PP.charstyle(chstno,1).par_bgd,...				% par_bgd
							text_namevalue);										% text_namevalue
						% Font widening:
						if PP.charstyle(chstno,1).fontwidening~=0
							fontwidening	= max(0,PP.charstyle(chstno,1).fontwidening);
							poly_obj		= polybuffer(poly_obj,fontwidening/2,'JointType','miter');
							poly_bgd		= union(poly_bgd,poly_obj,'KeepCollinearPoints',false);
						end
						
						% Assign the tick labels:
						if    ~overlaps(poly_text_all,poly_obj)&&...
								~overlaps(poly_text_all,poly_bgd)
							overlap_poly_text		= false;
							poly_text_all			= union(poly_text_all,poly_obj,'KeepCollinearPoints',false);
							poly_text_all			= union(poly_text_all,poly_bgd,'KeepCollinearPoints',false);
							text_fgd_m(r,c).poly(i,1)						= poly_obj;
							text_bgd_m(r,c).poly(i,1)						= poly_bgd;
							% Assign userdata: text:
							text_fgd_m(r,c).ud(i,1)							= ud_init_text;
							text_fgd_m(r,c).ud(i,1).color_no				= textuserdata_pp.color_no_fgd;
							text_fgd_m(r,c).ud(i,1).color_no_pp			= textuserdata_pp.color_no_fgd;
							text_fgd_m(r,c).ud(i,1).dz						= textuserdata_pp.dz_fgd;
							text_fgd_m(r,c).ud(i,1).prio					= prio_fgd;
							text_fgd_m(r,c).ud(i,1).iobj					= 0;
							text_fgd_m(r,c).ud(i,1).level					= 1;
							text_fgd_m(r,c).ud(i,1).surftype				= textuserdata_pp.surftype_fgd;
							text_fgd_m(r,c).ud(i,1).text_eqtags{1,1}	= text_str;
							text_fgd_m(r,c).ud(i,1).chstno				= chstno;
							text_fgd_m(r,c).ud(i,1).chstsettings		= PP.charstyle(chstno,1);
							text_fgd_m(r,c).ud(i,1).rotation				= textpar_pp.rotation;
							text_fgd_m(r,c).ud(i,1).obj_purpose			= obj_purpose;
							text_fgd_m(r,c).ud(i,1).shape0				= text_fgd_m(r,c).poly(i,1);
							% Assign userdata: background:
							text_bgd_m(r,c).ud(i,1)							= ud_init_text;
							text_bgd_m(r,c).ud(i,1).color_no				= textuserdata_pp.color_no_bgd;
							text_bgd_m(r,c).ud(i,1).color_no_pp			= textuserdata_pp.color_no_bgd;
							text_bgd_m(r,c).ud(i,1).dz						= textuserdata_pp.dz_bgd;
							text_bgd_m(r,c).ud(i,1).prio					= prio_bgd;
							text_bgd_m(r,c).ud(i,1).iobj					= 0;
							text_bgd_m(r,c).ud(i,1).level					= 0;
							text_bgd_m(r,c).ud(i,1).surftype				= textuserdata_pp.surftype_bgd;
							text_bgd_m(r,c).ud(i,1).text_eqtags{1,1}	= text_str;
							text_bgd_m(r,c).ud(i,1).chstno				= chstno;
							text_bgd_m(r,c).ud(i,1).chstsettings		= PP.charstyle(chstno,1);
							text_bgd_m(r,c).ud(i,1).rotation				= textpar_pp.rotation;
							text_bgd_m(r,c).ud(i,1).obj_purpose			= obj_purpose;
							text_bgd_m(r,c).ud(i,1).shape0				= text_bgd_m(r,c).poly(i,1);
						else
							overlap_poly_text		= true;
						end
						
						% map scale bar y-dimensions:					  ytext=0: tick label base line
						y1		= ytext-PP.legend.mapscalebar_dticktext;		% ticks top side
						y2		= y1   -PP.legend.mapscalebar_ticklength;		% map scale bar outer top side / ticks bottom side
						y3		= y2   -PP.legend.mapscalebar_linewidth;		% map scale bar inner top side
						y4		= y3   -PP.legend.mapscalebar_iysize;			% map scale bar inner bottom side
						y5		= y4   -PP.legend.mapscalebar_linewidth;		% map scale bar outer bottom side
						tol	= 1e-6;
						if i_ticklabel<=size(ticks_v,1)
							poly_tick				= line2poly([xtext xtext],[y1 y2],{PP.legend.mapscalebar_linewidth;6});
							liar_fgd_m(r,c).poly	= union(liar_fgd_m(r,c).poly,poly_tick,'KeepCollinearPoints',false);
							liar_bgd_m(r,c).poly	= union(liar_bgd_m(r,c).poly,poly_tick,'KeepCollinearPoints',false);
						end
						
						% Row height:
						h_row_v(r,1)			= max(h_row_v(r,1),abs(y5));
						
					end
					if testout~=0
						fprintf(1,'ticks_realscale_v=[%s]\n',num2str(ticks_realscale_v(:)'));
					end
					
					% Finish the variation of mi_ma_ticks_m if:
					% - no overlap of the texts and
					% - the text polygon is not larger than the available space
					[xlim,~]			= boundingbox(text_bgd_m(r,c).poly);
					if    ~overlap_poly_text       &&...
							(xlim(2)-xlim(1)<=w_msb)
						msb_fits		= true;
					else
						% Delete the last tick and repeat:
						mi_ma_ticks_m	= mi_ma_ticks_m(1:(end-1),:);
					end
					
				end
				
				% Map scale bar:
				% mi_ma_ticks_m =
				%      0     0     0     0
				%    NaN     4   NaN   0.2
				%    NaN     8   NaN   0.4
				%    NaN    12   NaN   0.6
				%    NaN    16   NaN   0.8
				%     20    20     1     1
				%     40   NaN     2   NaN
				%     60   NaN     3   NaN
				for i=1:(size(mi_ma_ticks_m,1)-1)
					if ~isnan(mi_ma_ticks_m(i,2))
						x1		= mi_ma_ticks_m(i,2);
					else
						x1		= mi_ma_ticks_m(i,1);
					end
					if ~isnan(mi_ma_ticks_m(i+1,2))
						x2		= mi_ma_ticks_m(i+1,2);
					else
						x2		= mi_ma_ticks_m(i+1,1);
					end
					if (-1)^i<0
						% black:
						poly_bgd		= polyshape(...
							[x1-tol x2+tol x2+tol x1-tol],...
							[y5-tol y5-tol y2+tol y2+tol]);
					else
						% white:
						poly_bgd_1	= polyshape(...
							[x1-tol x2+tol x2+tol x1-tol],...
							[y3-tol y3-tol y2+tol y2+tol]);
						poly_bgd_2	= polyshape(...
							[x1-tol x2+tol x2+tol x1-tol],...
							[y5-tol y5-tol y4+tol y4+tol]);
						poly_bgd		= union(poly_bgd_1,poly_bgd_2,'KeepCollinearPoints',false);
						if i==(size(mi_ma_ticks_m,1)-1)
							% close the white box:
							poly_bgd_1	= polyshape([...
								x2-tol ...
								x2+tol+PP.legend.mapscalebar_linewidth ...
								x2+tol+PP.legend.mapscalebar_linewidth ...
								x2-tol],[...
								y5-tol ...
								y5-tol ...
								y2+tol ...
								y2+tol]);
							poly_bgd		= union(poly_bgd_1,poly_bgd,'KeepCollinearPoints',false);
						end
					end
					liar_fgd_m(r,c).poly	= union(liar_fgd_m(r,c).poly,poly_bgd,'KeepCollinearPoints',false);
					liar_bgd_m(r,c).poly	= union(liar_bgd_m(r,c).poly,poly_bgd,'KeepCollinearPoints',false);
				end
				
				% Assign userdata: foreground:
				liar_fgd_m(r,c).ud.shape0			= liar_fgd_m(r,c).poly;
				% Assign userdata: background:
				liar_bgd_m(r,c).ud.shape0			= liar_bgd_m(r,c).poly;
				
				% DispAs, Description and Text/Tag:
				mapobj_m(r,c).disp	= 'area';
				mapobj_m(r,c).dscr	= sprintf('Legend: element (%g,%g): map scale bar',r,c);
				mapobj_m(r,c).text	= sprintf('%s .. %s %s',...
					ticklabel_v{1    ,1},...
					ticklabel_v{end-1,1},...
					msb_unit);
				
			end
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Foreground inside background:
	%------------------------------------------------------------------------------------------------------------------
	
	% The foreground must be inside the background (less problems in map2stl.m):
	for r=1:nr
		for c=1:nc
			for itext=1:size(text_bgd_m(r,c).poly,1)
				if numboundaries(text_bgd_m(r,c).poly(itext,1))>0
					poly_bgd_buff	= polybuffer(text_bgd_m(r,c).poly(itext,1),-GV.d_forebackgrd_plotobj,...
						'JointType','miter','MiterLimit',2);
					text_fgd_m(r,c).poly(itext,1)		= intersect(text_fgd_m(r,c).poly(itext,1),poly_bgd_buff,...
						'KeepCollinearPoints',false);
				end
			end
			if numboundaries(liar_bgd_m(r,c).poly)>0
				poly_bgd_buff	= polybuffer(liar_bgd_m(r,c).poly,-GV.d_forebackgrd_plotobj,...
					'JointType','miter','MiterLimit',2);
				liar_fgd_m(r,c).poly		= intersect(liar_fgd_m(r,c).poly,poly_bgd_buff,...
					'KeepCollinearPoints',false);
			end
			if numboundaries(symb_bgd_m(r,c).poly)>0
				poly_bgd_buff	= polybuffer(symb_bgd_m(r,c).poly,-GV.d_forebackgrd_plotobj,...
					'JointType','miter','MiterLimit',2);
				symb_fgd_m(r,c).poly		= intersect(symb_fgd_m(r,c).poly,poly_bgd_buff,...
					'KeepCollinearPoints',false);
			end
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Translate the polygons and testplot:
	%------------------------------------------------------------------------------------------------------------------
	
	if testplot==1
		hf		= figure(482895821);
		figure_theme(hf,'set',[],'light');
		clf(hf,'reset');
		figure_theme(hf,'set',[],'light');
		set(hf,'Tag','maplab3d_figure');
		ha		= axes(hf);
		hold(ha,'on');
		axis(ha,'equal');
		title(ha,'Legend testplot','Interpreter','none');
	end
	y			= ls_row_v(1,1);
	y_row_v	= zeros(nr,1);
	for r=1:nr
		c_notempty_v		= false(1,nc);
		for c=1:nc
			if    (sum(numboundaries(text_bgd_m(r,c).poly))>0)||...
					(sum(numboundaries(text_fgd_m(r,c).poly))>0)||...
					(    numboundaries(liar_bgd_m(r,c).poly )>0)||...
					(    numboundaries(liar_fgd_m(r,c).poly )>0)||...
					(    numboundaries(symb_bgd_m(r,c).poly )>0)||...
					(    numboundaries(symb_fgd_m(r,c).poly )>0)
				c_notempty_v(1,c)		= true;
			end
		end
		% Decrease y only if there is data to plot:
		if any(c_notempty_v)
			x			= 0;
			% Subtract the line spacing of the first line of the row r to the last line of the row r-1 (ls_row_v):
			y			= y-ls_row_v(r,1);
			if r>1
				% Subtract the row height (= number of lines * text_spacing_line):
				% Get the next non empty row above row r:
				r_above			= r-1;
				while (r_above>0)&&~row_is_not_empty(r_above,1)
					% The complete row above row r is empty and will not be displayed:
					r_above		= r_above-1;
				end
				y			= y-h_row_v(r_above,1);
			end
			y_row_v(r,1)	= y;
			for c=1:nc
				if ~c_notempty_v(1,c)
					% The column c is empty: increase x:
					x			= x+w_colsym_l_v(1,c)+PP.legend.dst;
					x			= x+w_coltxt_r_v(1,c)+PP.legend.dco;
				else
					% The column c is not empty:
					if ~strcmp(PP.legend.element(r,c).text_type,'map scale bar')
						if strcmp(PP.legend.element(r,c).legsymb_position,'left')
							xpoly		= x+w_colsym_l_v(1,c)/2;
							ypoly		= y+lift_sym_txt_m(r,c);
							liar_bgd_m(r,c).poly		= translate(liar_bgd_m(r,c).poly,xpoly,ypoly);
							liar_fgd_m(r,c).poly		= translate(liar_fgd_m(r,c).poly,xpoly,ypoly);
							symb_bgd_m(r,c).poly		= translate(symb_bgd_m(r,c).poly,xpoly,ypoly);
							symb_fgd_m(r,c).poly		= translate(symb_fgd_m(r,c).poly,xpoly,ypoly);
							if testplot==1
								plot(ha,liar_bgd_m(r,c).poly,'EdgeColor','k','FaceColor','g');
								plot(ha,liar_fgd_m(r,c).poly,'EdgeColor','k','FaceColor','g');
								plot(ha,symb_bgd_m(r,c).poly,'EdgeColor','k','FaceColor','g');
								plot(ha,symb_fgd_m(r,c).poly,'EdgeColor','k','FaceColor','g');
								plot(ha,x+[0 1]*w_colsym_l_v(1,c),y+[0 0],'-xr','LineWidth',1.5,'MarkerSize',10);
							end
							x			= x+w_colsym_l_v(1,c)+PP.legend.dst;
							if sum(numboundaries(text_bgd_m(r,c).poly))>0
								[xlim,~]			= boundingbox(text_bgd_m(r,c).poly);
								switch PP.legend.element(r,c).text_hor_alignment
									case 'left'
										xpoly		= xl_txt_m(r,c)-xlim(1);
									case 'right'
										xpoly		= xr_txt_m(r,c)-xlim(2);
									otherwise		% 'center'
										xpoly		= (xl_txt_m(r,c)+xr_txt_m(r,c))/2-(xlim(1)+xlim(2))/2;
								end
								ypoly		= y;
								text_bgd_m(r,c).poly		= translate(text_bgd_m(r,c).poly,xpoly,ypoly);
								text_fgd_m(r,c).poly		= translate(text_fgd_m(r,c).poly,xpoly,ypoly);
								if testplot==1
									plot(ha,text_bgd_m(r,c).poly	,'EdgeColor','k','FaceColor','b');
									plot(ha,text_fgd_m(r,c).poly,'EdgeColor','k','FaceColor','b');
								end
							end
							if testplot==1
								plot(ha,x+[0 1]*w_coltxt_r_v(1,c),y+[0 0],'-xr','LineWidth',1.5,'MarkerSize',10);
							end
							xmax		= x+w_coltxt_r_v(1,c);
							x			= x+w_coltxt_r_v(1,c)+PP.legend.dco;
						elseif strcmp(PP.legend.element(r,c).legsymb_position,'right')
							if sum(numboundaries(text_bgd_m(r,c).poly))>0
								[xlim,~]			= boundingbox(text_bgd_m(r,c).poly);
								switch PP.legend.element(r,c).text_hor_alignment
									case 'left'
										xpoly		= xl_txt_m(r,c)-xlim(1);
									case 'right'
										xpoly		= xr_txt_m(r,c)-xlim(2);
									otherwise		% 'center'
										xpoly		= (xl_txt_m(r,c)+xr_txt_m(r,c))/2-(xlim(1)+xlim(2))/2;
								end
								ypoly		= y;
								text_bgd_m(r,c).poly		= translate(text_bgd_m(r,c).poly,xpoly,ypoly);
								text_fgd_m(r,c).poly		= translate(text_fgd_m(r,c).poly,xpoly,ypoly);
								if testplot==1
									plot(ha,text_bgd_m(r,c).poly,'EdgeColor','k','FaceColor','b');
									plot(ha,text_fgd_m(r,c).poly,'EdgeColor','k','FaceColor','b');
								end
							end
							plot(ha,x+[0 1]*w_coltxt_l_v(1,c),y+[0 0],'-xr','LineWidth',1.5,'MarkerSize',10);
							x			= x+w_coltxt_l_v(1,c)+PP.legend.dst;
							xpoly		= x+w_colsym_r_v(1,c)/2;
							ypoly		= y+lift_sym_txt_m(r,c);
							liar_bgd_m(r,c).poly		= translate(liar_bgd_m(r,c).poly,xpoly,ypoly);
							liar_fgd_m(r,c).poly		= translate(liar_fgd_m(r,c).poly,xpoly,ypoly);
							symb_bgd_m(r,c).poly		= translate(symb_bgd_m(r,c).poly,xpoly,ypoly);
							symb_fgd_m(r,c).poly		= translate(symb_fgd_m(r,c).poly,xpoly,ypoly);
							if testplot==1
								plot(ha,liar_bgd_m(r,c).poly,'EdgeColor','k','FaceColor','g');
								plot(ha,liar_fgd_m(r,c).poly,'EdgeColor','k','FaceColor','g');
								plot(ha,symb_bgd_m(r,c).poly,'EdgeColor','k','FaceColor','g');
								plot(ha,symb_fgd_m(r,c).poly,'EdgeColor','k','FaceColor','g');
								plot(ha,x+[0 1]*w_colsym_r_v(1,c),y+[0 0],'-xr','LineWidth',1.5,'MarkerSize',10);
							end
							xmax		= x+w_colsym_r_v(1,c);
							x			= x+w_colsym_r_v(1,c)+PP.legend.dco;
						end
					else
						% Map scale bar:
						x			= x+w_colsym_l_v(1,c)+PP.legend.dst;
						poly_text_liar_bgd		= union(text_bgd_m(r,c).poly(1    ,1),liar_bgd_m(r,c).poly);
						for itext=2:size(text_bgd_m(r,c).poly,1)
							poly_text_liar_bgd	= union(text_bgd_m(r,c).poly(itext,1),poly_text_liar_bgd  );
						end
						if numboundaries(poly_text_liar_bgd)>0
							[xlim,~]			= boundingbox(poly_text_liar_bgd);
							switch PP.legend.mapscalebar_hor_alignment
								case 'left'
									xpoly		= xl_txt_m(r,c)-xlim(1);
								case 'right'
									xpoly		= xr_txt_m(r,c)-xlim(2);
								otherwise		% 'center'
									xpoly		= (xl_txt_m(r,c)+xr_txt_m(r,c))/2-(xlim(1)+xlim(2))/2;
							end
							ypoly		= y;
							liar_bgd_m(r,c).poly		= translate(liar_bgd_m(r,c).poly,xpoly,ypoly);	% map scale bar and ticks
							liar_fgd_m(r,c).poly		= translate(liar_fgd_m(r,c).poly,xpoly,ypoly);
							text_bgd_m(r,c).poly		= translate(text_bgd_m(r,c).poly,xpoly,ypoly);	% tick labels
							text_fgd_m(r,c).poly		= translate(text_fgd_m(r,c).poly,xpoly,ypoly);
							% symb_bgd_m(r,c).poly is empty
							% symb_fgd_m(r,c).poly is empty
							if testplot==1
								plot(ha,liar_bgd_m(r,c).poly,'EdgeColor','k','FaceColor','g');
								plot(ha,liar_fgd_m(r,c).poly,'EdgeColor','k','FaceColor','g');
								plot(ha,symb_bgd_m(r,c).poly,'EdgeColor','k','FaceColor','g');
								plot(ha,symb_fgd_m(r,c).poly,'EdgeColor','k','FaceColor','g');
								plot(ha,text_bgd_m(r,c).poly,'EdgeColor','k','FaceColor','b');
								plot(ha,text_fgd_m(r,c).poly,'EdgeColor','k','FaceColor','b');
							end
						end
						xmax		= x+w_coltxt_r_v(1,c);
						x			= x+w_coltxt_r_v(1,c)+PP.legend.dco;
						
					end
				end
			end
			if testplot==1
				plot(ha,[0 1]*xmax,[1 1]*y-h_row_v(r,1),':r','LineWidth',0.5);		% bottom side of the current row
			end
		end
	end
	
	% if testout~=0
	% 	xleft_m
	% 	w_txt_m_0
	% 	w_txt_m
	% 	i_h_ls_y_row_v	= [(1:length(ls_row_v))' h_row_v ls_row_v y_row_v]
	% 	ls_row_v
	% 	w_colsym_l_v
	% 	w_colsym_r_v
	% 	w_coltxt_l_v
	% 	w_coltxt_r_v
	% 	xl_txt_m
	% 	xr_txt_m
	% 	setbreakpoint	= 1;
	% end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Legend objects box:
	%------------------------------------------------------------------------------------------------------------------
	
	% Legend objects box:
	legobjbox_l		=  1e10;			% left
	legobjbox_r		= -1e10;			% right
	legobjbox_b		=  1e10;			% bottom
	legobjbox_t		= -1e10;			% top
	for r=1:nr
		for c=1:nc
			if sum(numboundaries(text_bgd_m(r,c).poly))>0
				[xlim,ylim]		= boundingbox(text_bgd_m(r,c).poly);
				legobjbox_l		= min(legobjbox_l,xlim(1));
				legobjbox_r		= max(legobjbox_r,xlim(2));
				legobjbox_b		= min(legobjbox_b,ylim(1));
				legobjbox_t		= max(legobjbox_t,ylim(2));
			end
			if numboundaries(liar_bgd_m(r,c).poly)>0
				[xlim,ylim]		= boundingbox(liar_bgd_m(r,c).poly);
				legobjbox_l		= min(legobjbox_l,xlim(1));
				legobjbox_r		= max(legobjbox_r,xlim(2));
				legobjbox_b		= min(legobjbox_b,ylim(1));
				legobjbox_t		= max(legobjbox_t,ylim(2));
			end
			if numboundaries(symb_bgd_m(r,c).poly)>0
				[xlim,ylim]		= boundingbox(symb_bgd_m(r,c).poly);
				legobjbox_l		= min(legobjbox_l,xlim(1));
				legobjbox_r		= max(legobjbox_r,xlim(2));
				legobjbox_b		= min(legobjbox_b,ylim(1));
				legobjbox_t		= max(legobjbox_t,ylim(2));
			end
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Legend background and frame:
	%------------------------------------------------------------------------------------------------------------------
	
	poly_legbgd		= polyshape([...
		legobjbox_l-PP.legend.dfl ...
		legobjbox_r+PP.legend.dfr ...
		legobjbox_r+PP.legend.dfr ...
		legobjbox_l-PP.legend.dfl],[...
		legobjbox_b-PP.legend.dfb ...
		legobjbox_b-PP.legend.dfb ...
		legobjbox_t+PP.legend.dft ...
		legobjbox_t+PP.legend.dft]);
	if PP.legend.fw>0
		poly_legbgd_0		= poly_legbgd;
		poly_legbgd			= polybuffer(poly_legbgd,PP.legend.fw,'JointType','miter','MiterLimit',2);
		poly_legfra			= addboundary(poly_legbgd,poly_legbgd_0.Vertices,'KeepCollinearPoints',false);
		poly_legbgd			= polybuffer(poly_legbgd,PP.legend.dist_legobj_legbgd,'JointType','miter','MiterLimit',2);
		if testplot==1
			plot(ha,poly_legfra,'EdgeColor','k','FaceColor','b','LineWidth',1.5);
		end
	else
		poly_legfra			= polyshape();
	end
	if testplot==1
		plot(ha,poly_legbgd,'EdgeColor','r','FaceColor','none','LineWidth',1.5,'LineStyle','--');
	end
	% Userdata legend background:
	obj_purpose					= {'legend background'};
	[userdata_pp,~,errortext]	= get_pp_mapobjsettings(iobj,'area',obj_purpose);
	if ~isempty(errortext)
		errormessage(errortext);
	end
	ud_legbgd					= ud_init;
	ud_legbgd.color_no		= userdata_pp.color_no_bgd;
	ud_legbgd.color_no_pp	= userdata_pp.color_no_bgd;
	ud_legbgd.dz				= userdata_pp.dz_bgd;
	ud_legbgd.prio				= prio_legbgd;
	ud_legbgd.level			= 0;
	ud_legbgd.surftype		= userdata_pp.surftype_bgd;
	ud_legbgd.islegbgd		= true;
	ud_legbgd.rotation		= 0;
	ud_legbgd.obj_purpose	= obj_purpose;
	ud_legbgd.shape0			= poly_legbgd;
	% Userdata legend frame:
	obj_purpose					= {'legend frame'};
	[userdata_pp,~,errortext]	= get_pp_mapobjsettings(iobj,'area',obj_purpose);
	if ~isempty(errortext)
		errormessage(errortext);
	end
	prio_fgd						= prio_fgd+1;
	ud_legfra					= ud_init;
	ud_legfra.color_no		= userdata_pp.color_no_bgd;
	ud_legfra.color_no_pp	= userdata_pp.color_no_bgd;
	ud_legfra.dz				= userdata_pp.dz_bgd;
	ud_legfra.prio				= prio_fgd;
	ud_legfra.level			= 0;
	ud_legfra.surftype		= userdata_pp.surftype_bgd;
	ud_legfra.rotation		= 0;
	ud_legfra.obj_purpose	= obj_purpose;
	ud_legfra.shape0			= poly_legfra;
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Legend location:
	%------------------------------------------------------------------------------------------------------------------
	
	% Legend dimensions:
	[xlim,ylim]		= boundingbox(poly_legbgd);
	legbox_l			= xlim(1);
	legbox_r			= xlim(2);
	legbox_b			= ylim(1);
	legbox_t			= ylim(2);
	
	% Printout limits:
	printout_xmin		= min(GV_H.poly_map_printout_obj_limits.Shape.Vertices(:,1));
	printout_xmax		= max(GV_H.poly_map_printout_obj_limits.Shape.Vertices(:,1));
	printout_ymin		= min(GV_H.poly_map_printout_obj_limits.Shape.Vertices(:,2));
	printout_ymax		= max(GV_H.poly_map_printout_obj_limits.Shape.Vertices(:,2));
	
	% Translate all polygons to the new location:
	dx				= (printout_xmin+printout_xmax)/2-(legbox_l+legbox_r)/2;		% Default: center
	dy				= (printout_ymin+printout_ymax)/2-(legbox_l+legbox_r)/2;
	switch PP.legend.location
		case {'west','northwest','southwest'}
			dx		= printout_xmin-legbox_l;
		case {'east','northeast','southeast'}
			dx		= printout_xmax-legbox_r;
	end
	switch PP.legend.location
		case {'south','southeast','southwest'}
			dy		= printout_ymin-legbox_b;
		case {'north','northeast','northwest'}
			dy		= printout_ymax-legbox_t;
	end
	for r=1:nr
		for c=1:nc
			text_fgd_m(r,c).poly		= translate(text_fgd_m(r,c).poly,dx,dy);
			text_bgd_m(r,c).poly		= translate(text_bgd_m(r,c).poly,dx,dy);
			liar_fgd_m(r,c).poly		= translate(liar_fgd_m(r,c).poly,dx,dy);
			liar_bgd_m(r,c).poly		= translate(liar_bgd_m(r,c).poly,dx,dy);
			symb_fgd_m(r,c).poly		= translate(symb_fgd_m(r,c).poly,dx,dy);
			symb_bgd_m(r,c).poly		= translate(symb_bgd_m(r,c).poly,dx,dy);
		end
	end
	poly_legbgd		= translate(poly_legbgd,dx,dy);
	poly_legfra		= translate(poly_legfra,dx,dy);
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Testplot: paragraph and line spacing
	%------------------------------------------------------------------------------------------------------------------
	
	if testplot==1
		x_line1		= legbox_r+  max(4,PP.legend.dfl);
		x_line2		= x_line1-2;
		x_text1		= x_line1+1;
		x_text2		= x_line2+1;
		for r=1:nr
			if row_is_not_empty(r,1)
				% ls_row_v: line spacing of the first line of the row r to the last line of the row r-1:
				plot(ha,[1 1]*x_line1,y_row_v(r,1)+[0 ls_row_v(r,1)],'-xr','LineWidth',1.5,'MarkerSize',10);
				text(ha,x_text1,y_row_v(r,1)+ls_row_v(r,1)/2,...
					[num2str(ls_row_v(r,1)) 'mm'],...
					'Color','r','Clipping','on');
				text(ha,x_text1,y_row_v(r,1),...
					['row ' num2str(r)],...
					'Color','r','Clipping','on');
				% h_row_v: height of every row, all columns:
				if h_row_v(r,1)>0
					plot(ha,[1 1]*x_line2,y_row_v(r,1)-[0 h_row_v(r,1)],':xr','LineWidth',0.5);
					text(ha,x_text2,y_row_v(r,1)-h_row_v(r,1)/2,...
						[num2str(h_row_v(r,1)) 'mm'],...
						'Color','r','Clipping','on');
				end
			end
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Plotting:
	%------------------------------------------------------------------------------------------------------------------
	% Texts of the legend are not plotted with MAP_OBJECTS(imapobj,1).disp='text'
	% so they cannot be changed after creating the legend!
	
	% Delete map figure legend:
	legend(GV_H.ax_2dmap,'off');
	
	% Plot legend background:
	plot_legend(...
		polyshape(),...				% poly_bgd
		poly_legbgd,...				% poly_fgd
		[],...							% ud_bgd
		ud_legbgd,...					% ud_fgd
		'area',...						% disp_str
		'Legend: background',...	% dscr_str
		'');								% text_str
	
	% Plot legend frame:
	plot_legend(...
		polyshape(),...				% poly_bgd
		poly_legfra,...				% poly_fgd
		[],...							% ud_bgd
		ud_legfra,...					% ud_fgd
		'area',...						% disp_str
		'Legend: frame',...			% dscr_str
		'');								% text_str
	
	% Plot legend objects:
	for r=1:nr
		for c=1:nc
			for itext=1:size(text_bgd_m(r,c).poly,1)
				plot_legend(...
					text_bgd_m(r,c).poly(itext,1),...	% poly_bgd
					text_fgd_m(r,c).poly(itext,1),...	% poly_fgd
					text_bgd_m(r,c).ud(itext,1),...		% ud_bgd
					text_fgd_m(r,c).ud(itext,1),...		% ud_fgd
					'text',...									% disp_str
					mapobj_m(r,c).dscr,...					% dscr_str
					mapobj_m(r,c).text);						% text_str
			end
			plot_legend(...
				liar_bgd_m(r,c).poly,...					% poly_bgd
				liar_fgd_m(r,c).poly,...					% poly_fgd
				liar_bgd_m(r,c).ud,...						% ud_bgd
				liar_fgd_m(r,c).ud,...						% ud_fgd
				mapobj_m(r,c).disp,...						% disp_str
				mapobj_m(r,c).dscr,...						% dscr_str
				'');												% text_str
			plot_legend(...
				symb_bgd_m(r,c).poly,...					% poly_bgd
				symb_fgd_m(r,c).poly,...					% poly_fgd
				symb_bgd_m(r,c).ud,...						% ud_bgd
				symb_fgd_m(r,c).ud,...						% ud_fgd
				'symbol',...									% disp_str
				mapobj_m(r,c).dscr,...						% dscr_str
				'');												% text_str
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Background z-value (999999 = automatic selection)
	% The legend is not higher than the terrain at the edge of the legend background.
	%------------------------------------------------------------------------------------------------------------------
	
	if PP.legend.z_topside_bgd==999999
		poly_legbgd_buff		= polybuffer(poly_legbgd,GV.tol_1,'JointType','miter','MiterLimit',2);
		poly_legbgd_buff		= changeresolution_poly(...
			poly_legbgd_buff,...					% polyin
			PP.general.dxy_ele_mm/10,...		% dmax
			[],...									% dmin
			[]);										% nmin
		% in_v						= isinterior(GV_H.poly_map_printout_obj_limits.Shape,poly_legbgd_buff.Vertices);
		in_v	= inpolygon(...															% faster than isinterior
			poly_legbgd_buff.Vertices(:,1),...										% query points
			poly_legbgd_buff.Vertices(:,2),...
			GV_H.poly_map_printout_obj_limits.Shape.Vertices(:,1),...		% polygon area
			GV_H.poly_map_printout_obj_limits.Shape.Vertices(:,2));
		if any(in_v)
			GV.legend_z_topside_bgd	= 1e100;
			for ifs=1:size(ELE.elefiltset,1)
				z_v	= interp2(...
					ELE.elefiltset(ifs,1).xm_mm,...				% coordinates of the sample points
					ELE.elefiltset(ifs,1).ym_mm,...				% coordinates of the sample points
					ELE.elefiltset(ifs,1).zm_mm,...				% function values at each sample point
					poly_legbgd_buff.Vertices(in_v,1),...		% query points
					poly_legbgd_buff.Vertices(in_v,2));
				z_v_min						= min(z_v);
				GV.legend_z_topside_bgd	= min(GV.legend_z_topside_bgd,z_v_min);
			end
		else
			% The legend is greater than the printout limits:
			GV.legend_z_topside_bgd	= 0;
		end
	else
		GV.legend_z_topside_bgd	= PP.legend.z_topside_bgd;
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% After plotting:
	%------------------------------------------------------------------------------------------------------------------
	
	% Create/modify map figure legend:
	create_legend_mapfigure;
	
	% Update MAP_OBJECTS_TABLE:
	display_map_objects;
	
	% Display state:
	if ~stateisbusy
		t_end_statebusy					= clock;
		dt_statebusy						= etime(t_end_statebusy,t_start_statebusy);
		dt_statebusy_str					= dt_string(dt_statebusy);
		set(GV_H.text_waitbar,'String','');
		display_on_gui('state',...
			sprintf('Create legend ... done (%s).',dt_statebusy_str),...
			'notbusy','replace');
	end
	
catch ME
	errormessage('',ME);
end




function plot_legend(poly_bgd,poly_fgd,ud_bgd,ud_fgd,disp_str,dscr_str,text_str)

global GV GV_H PP MAP_OBJECTS

try
	
	if (numboundaries(poly_fgd)>0)||(numboundaries(poly_bgd)>0)
		if isempty(disp_str)
			errormessage;
		end
		% Plot background:
		if numboundaries(poly_bgd)>0
			ud_bgd.shape0	= poly_bgd;
			if isequal(ud_bgd.color_no,0)
				facecolor	= 'none';
				linewidth	= GV.colorno_e0_linewidth;
			else
				facecolor	= PP.color(ud_bgd.color_no).rgb/255;
				linewidth	= GV.colorno_g0_linewidth;
			end
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
			end
			h_poly_bgd			= plot(GV_H.ax_2dmap,poly_bgd,...
				'LineWidth'    ,linewidth,...
				'EdgeColor'    ,'k',...
				'FaceColor'    ,facecolor,...
				'EdgeAlpha'    ,GV.visibility.show.edgealpha,...
				'FaceAlpha'    ,GV.visibility.show.facealpha,...
				'Visible'		,'on',...
				'UserData'     ,ud_bgd,...
				'ButtonDownFcn',@ButtonDownFcn_ax_2dmap);
		end
		% Plot foreground:
		if numboundaries(poly_fgd)>0
			ud_fgd.shape0	= poly_fgd;
			if isequal(ud_fgd.color_no,0)
				facecolor	= 'none';
				linewidth	= GV.colorno_e0_linewidth;
			else
				facecolor	= PP.color(ud_fgd.color_no).rgb/255;
				linewidth	= GV.colorno_g0_linewidth;
			end
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
			end
			h_poly_fgd			= plot(GV_H.ax_2dmap,poly_fgd,...
				'LineWidth'    ,linewidth,...
				'EdgeColor'    ,'k',...
				'FaceColor'    ,facecolor,...
				'EdgeAlpha'    ,GV.visibility.show.edgealpha,...
				'FaceAlpha'    ,GV.visibility.show.facealpha,...
				'Visible'		,'on',...
				'UserData'     ,ud_fgd,...
				'ButtonDownFcn',@ButtonDownFcn_ax_2dmap);
		end
		% Save relevant data in the structure MAP_OBJECTS:
		imapobj								= size(MAP_OBJECTS,1)+1;
		[xcenter,ycenter]					= centroid(union(poly_bgd,poly_fgd));
		MAP_OBJECTS(imapobj,1).disp	= disp_str;
		if (numboundaries(poly_fgd)>0)&&(numboundaries(poly_bgd)>0)
			MAP_OBJECTS(imapobj,1).h	= [h_poly_bgd;h_poly_fgd];
		elseif numboundaries(poly_fgd)>0
			MAP_OBJECTS(imapobj,1).h	= h_poly_fgd;
		elseif numboundaries(poly_bgd)>0
			MAP_OBJECTS(imapobj,1).h	= h_poly_bgd;
		end
		MAP_OBJECTS(imapobj,1).iobj	= 0;
		MAP_OBJECTS(imapobj,1).dscr	= dscr_str;
		MAP_OBJECTS(imapobj,1).x		= xcenter;
		MAP_OBJECTS(imapobj,1).y		= ycenter;
		MAP_OBJECTS(imapobj,1).text	= {text_str};
		MAP_OBJECTS(imapobj,1).mod		= false;
		MAP_OBJECTS(imapobj,1).cncl	= 0;
		MAP_OBJECTS(imapobj,1).cnuc	= 0;
		MAP_OBJECTS(imapobj,1).vis0	= 1;
	end
	
catch ME
	errormessage('',ME);
end

