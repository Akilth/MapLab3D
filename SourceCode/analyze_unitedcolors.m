function analyze_unitedcolors(action)
% action =	'Detect small holes'
%				'Detect small pieces'
%				'Detect fragile pieces'
%				'Detect misplaced texts and symbols'

global APP GV_H MAP_OBJECTS PP GV PLOTDATA

try

	% Initializations:
	if nargin==0
		% Testing:
		action			= 'Detect small pieces';
	end
	if isempty(MAP_OBJECTS)||isempty(PLOTDATA)
		errortext	= sprintf([...
			'The map has not yet been created.\n',...
			'First create the map.']);
		errormessage(errortext);
	end
	if ~isfield(PLOTDATA,'colno_v')
		errortext	= sprintf([...
			'The map has not yet been created.\n',...
			'First create the map.']);
		errormessage(errortext);
	end

	% Display state:
	t_start_statebusy	= clock;
	set(GV_H.text_waitbar,'String','');
	display_on_gui('state',sprintf('%s ...',action),'busy','add');

	% Waitbar:
	waitbar_t1			= clock;

	% Query color numbers:
	prompt{1,1}		= sprintf([...
		'This function uses the "united equal colors": This combines all overlapping\n',...
		'equal colors of visible pieces into a single area, just like when creating\n',...
		'the STL files. Before execution, the united equal colors must be created:\n',...
		'- if they have not yet been created or\n',...
		'- if objects on the map have been changed.\n',...
		'In this case, cancel and first create the united equal colors (this can take\n',...
		'some time for large maps).\n',...
		'The united equal colors can be created manually using:\n',...
		'- Button "%s"\n',...																				% 'Create united equal colors'
		'The united equal colors are also created automatically by e.g:\n',...
		'- Menu item "%s"\n',...																			% 'Simplify Map'
		'- Menu item "%s"\n',...																			% 'Cut into pieces'
		'Continue if you want to use existing united equal colors:\n'],...
		APP.Mod_CreateUnitedColors_Button.Text,...
		APP.MapEdit_SimplifyMap_Menu.Text,...
		APP.MapEdit_CutIntoPiecesMapobjects_Menu.Text);
	switch action
		case  'Detect small holes'
			% prompt{1,1}			= sprintf(['%s\n'...				%                            90 -->|
			% 	'If an area has a hole in it (for example a clearing in a forest), it can cause\n',...
			% 	'the underlying color to fill the hole with a tall, narrow and therefore fragile\n',...
			% 	'column. To prevent this, the hole can be removed by covering the hole with a\n',...
			% 	'polygon like a patch, which is assigned the same object number as the rest of\n',...
			% 	'the area. "Detect small holes" is only applied to lines and areas, not to \n',...
			% 	'texts, symbols and preview objects.\n',...
			% 	'\n',...
			% 	'Enter the color number(s) to be considered: E.g.: 1,2,5:7 --> ColNo 1,2,5,6,7'],...
			% 	prompt{1,1});
			prompt{1,1}			= sprintf(['%s\n'...				%                            90 -->|
				'Enter the color number(s) to be considered: E.g.: 1,2,5:7 --> ColNo 1,2,5,6,7'],...
				prompt{1,1});
			prompt{2,1}			= PP.DESCRIPTION.general{1,1}.detect_holes{1,1}.hole_mindiag{1,1};
			prompt{3,1}			= PP.DESCRIPTION.general{1,1}.detect_holes{1,1}.hole_minarea{1,1};
			definput{1,1}		= num2str(GV.analyze_unitedcolors.detect_holes.definput{1,1});
			if size(GV.analyze_unitedcolors.detect_holes.definput,1)<2
				definput{2,1}	= num2str(PP.general.detect_holes.hole_mindiag);
			else
				definput{2,1}	= num2str(GV.analyze_unitedcolors.detect_holes.definput{2,1});
			end
			if size(GV.analyze_unitedcolors.detect_holes.definput,1)<3
				definput{3,1}	= num2str(PP.general.detect_holes.hole_minarea);
			else
				definput{3,1}	= num2str(GV.analyze_unitedcolors.detect_holes.definput{3,1});
			end
			input_minlength	= [1;1;1];
			input_maxlength	= [1e10;1;1];
			input_isint			= [true;false;false];
			input_minvalue		= [1;0;0];
			input_maxvalue		= [size(PP.color,1);1e10;1e10];
		case  'Detect small pieces'
			prompt{1,1}			= sprintf(['%s\n'...				%                            90 -->|
				'Enter the color number(s) to be considered: E.g.: 1,2,5:7 --> ColNo 1,2,5,6,7'],...
				prompt{1,1});
			prompt{2,1}			= PP.DESCRIPTION.general{1,1}.detect_small_pieces{1,1}.mindiag{1,1};
			prompt{3,1}			= PP.DESCRIPTION.general{1,1}.detect_small_pieces{1,1}.minarea{1,1};
			definput{1,1}		= num2str(GV.analyze_unitedcolors.detect_small_pieces.definput{1,1});
			if size(GV.analyze_unitedcolors.detect_small_pieces.definput,1)<2
				definput{2,1}	= num2str(PP.general.detect_small_pieces.mindiag);
			else
				definput{2,1}	= num2str(GV.analyze_unitedcolors.detect_small_pieces.definput{2,1});
			end
			if size(GV.analyze_unitedcolors.detect_small_pieces.definput,1)<3
				definput{3,1}	= num2str(PP.general.detect_small_pieces.minarea);
			else
				definput{3,1}	= num2str(GV.analyze_unitedcolors.detect_small_pieces.definput{3,1});
			end
			input_minlength	= [1;1;1];
			input_maxlength	= [1e10;1;1];
			input_isint			= [true;false;false];
			input_minvalue		= [1;0;0];
			input_maxvalue		= [size(PP.color,1);1e10;1e10];
		case 'Detect fragile pieces'
			% prompt{1,1}			= sprintf(['%s\n'...				%                            90 -->|
			% 	'This function detects whether a part is fragile by shifting the contour inwards\n',...
			% 	'by half the minimum width. If this results in several individual parts, the\n',...
			% 	'part is too narrow in at least one place. "Detect fragile pieces" is only\n',...
			% 	'applied to lines and areas, not to texts, symbols and preview objects.\n',...
			% 	'\n',...
			% 	'Enter the color number(s) to be considered: E.g.: 1,2,5:7 --> ColNo 1,2,5,6,7'],...
			% 	prompt{1,1});
			prompt{1,1}			= sprintf(['%s\n'...				%                            90 -->|
				'Enter the color number(s) to be considered: E.g.: 1,2,5:7 --> ColNo 1,2,5,6,7'],...
				prompt{1,1});
			prompt{2,1}			= PP.DESCRIPTION.general{1,1}.detect_fragile_pieces{1,1}.possbreakpoint_minwidth{1,1};
			definput{1,1}		= num2str(GV.analyze_unitedcolors.detect_fragile_pieces.definput{1,1});
			if size(GV.analyze_unitedcolors.detect_fragile_pieces.definput,1)<2
				definput{2,1}		= num2str(PP.general.detect_fragile_pieces.possbreakpoint_minwidth);
			else
				definput{2,1}		= num2str(GV.analyze_unitedcolors.detect_fragile_pieces.definput{2,1});
			end
			input_minlength	= [1;1];
			input_maxlength	= [1e10;1];
			input_isint			= [true;false];
			input_minvalue		= [1;0];
			input_maxvalue		= [size(PP.color,1);1e10];
		case 'Detect misplaced texts and symbols'
			prompt{1,1}			= sprintf(['%s\n',...			%                            90 -->|
				'Enter one color number of the lines and areas to be checked for\n',...
				'overlap with texts and symbols:'],...
				prompt{1,1});
			prompt{2,1}			= sprintf([...
				'Enter the object number or numbers of the texts to be checked for\n',...
				'overlap with lines and areas:\n',...
				'E.g.: 1,2,5:7 --> ColNo 1,2,5,6,7  /  Empty: no check for missing texts']);
			prompt{3,1}			= sprintf('Enter the minimum number of overlapping texts:');
			prompt{4,1}			= sprintf('Enter the maximum number of overlapping texts:');
			prompt{5,1}			= sprintf('Search for isolated texts without overlap (0/1):');
			prompt{6,1}			= sprintf([...
				'Enter the object number or numbers of the symbols to be checked for\n',...
				'overlap with lines and areas:\n',...
				'E.g.: 1,2,5:7 --> ColNo 1,2,5,6,7  /  Empty: no check for missing symbols']);
			prompt{7,1}			= sprintf('Enter the minimum number of overlapping symbols:');
			prompt{8,1}			= sprintf('Enter the maximum number of overlapping symbols:');
			prompt{9,1}			= sprintf('Search for isolated symbols without overlap (0/1):');
			definput{1,1}		= num2str(GV.analyze_unitedcolors.detect_misstextsymb.definput{1,1});
			definput{2,1}		= num2str(GV.analyze_unitedcolors.detect_misstextsymb.definput{2,1});
			definput{3,1}		= num2str(GV.analyze_unitedcolors.detect_misstextsymb.definput{3,1});
			definput{4,1}		= num2str(GV.analyze_unitedcolors.detect_misstextsymb.definput{4,1});
			definput{5,1}		= num2str(GV.analyze_unitedcolors.detect_misstextsymb.definput{5,1});
			definput{6,1}		= num2str(GV.analyze_unitedcolors.detect_misstextsymb.definput{6,1});
			definput{7,1}		= num2str(GV.analyze_unitedcolors.detect_misstextsymb.definput{7,1});
			definput{8,1}		= num2str(GV.analyze_unitedcolors.detect_misstextsymb.definput{8,1});
			definput{9,1}		= num2str(GV.analyze_unitedcolors.detect_misstextsymb.definput{9,1});
			%									1		2		3		4		5		6		7		8		9
			input_minlength	= [      1;    0;    1;    1;    1;    0;    1;    1;    1];
			input_maxlength	= [      1; 1e10;    1;    1;    1; 1e10;    1;    1;    1];
			input_isint			= [   true; true; true; true; true; true; true; true; true];
			input_minvalue		= [      1;    1;    0;    0;    0;    1;    0;    0;    0];
			input_maxvalue		= [...
				size(PP.color,1);...		% 1		colno_uec_v
				size(PP.obj,1);...		% 2		iobj_misstext_v
				1e10;...						% 3		nmin_overlapping_texts
				1e10;...						% 4		nmax_overlapping_texts
				1;...							% 5		search_texts_without_overlap
				size(PP.obj,1);...		% 6		iobj_misssymb_v
				1e10;...						% 7		nmin_overlapping_symbs
				1e10;...						% 8		nmax_overlapping_symbs
				1];							% 9		search_symbs_without_overlap
		otherwise
			errormessage;
	end
	dlgtitle		= action;
	dims			= 1;
	answer		= inputdlg_local(prompt,dlgtitle,dims,definput);
	if ~isempty(answer)
		% Check the answers:
		input_c			= cell(size(answer,1),1);
		for k=1:size(answer,1)
			input_c{k,1}	= str2num(answer{k});
			input_c{k,1}	= input_c{k,1}(:);
			if (size(input_c{k,1},1)<input_minlength(k,1))||(size(input_c{k,1},1)>input_maxlength(k,1))
				display_on_gui('state',...
					sprintf('%s ... invalid input (%s).',action,...
					dt_string(etime(clock,t_start_statebusy))),'notbusy','replace');
				return
			end
			if ~isempty(input_c{k,1})
				if    (max(input_c{k,1})>input_maxvalue(k,1)) ||...
						(min(input_c{k,1})<input_minvalue(k,1)) ||...
						(any(input_c{k,1}~=round(input_c{k,1}))&&input_isint(k,1))
					display_on_gui('state',...
						sprintf('%s ... invalid input (%s).',action,...
						dt_string(etime(clock,t_start_statebusy))),'notbusy','replace');
					return
				end
			end
		end
		% Assign the answers:
		colno_uec_v		= input_c{1,1};
		switch action
			case  'Detect small holes'
				hole_mindiag																= input_c{2,1};
				hole_minarea																= input_c{3,1};
				GV.analyze_unitedcolors.detect_holes.definput{1,1}				= colno_uec_v';
				GV.analyze_unitedcolors.detect_holes.definput{2,1}				= hole_mindiag;
				GV.analyze_unitedcolors.detect_holes.definput{3,1}				= hole_minarea;
			case  'Detect small pieces'
				mindiag																		= input_c{2,1};
				minarea																		= input_c{3,1};
				GV.analyze_unitedcolors.detect_small_pieces.definput{1,1}	= colno_uec_v';
				GV.analyze_unitedcolors.detect_small_pieces.definput{2,1}	= mindiag;
				GV.analyze_unitedcolors.detect_small_pieces.definput{3,1}	= minarea;
			case 'Detect fragile pieces'
				possbreakpoint_minwidth													= input_c{2,1};
				GV.analyze_unitedcolors.detect_fragile_pieces.definput{1,1}	= colno_uec_v';
				GV.analyze_unitedcolors.detect_fragile_pieces.definput{2,1}	= possbreakpoint_minwidth;
			case 'Detect misplaced texts and symbols'
				iobj_misstext_v															= input_c{2,1};
				nmin_overlapping_texts													= input_c{3,1};
				nmax_overlapping_texts													= input_c{4,1};
				search_texts_without_overlap											= input_c{5,1};
				iobj_misssymb_v															= input_c{6,1};
				nmin_overlapping_symbs													= input_c{7,1};
				nmax_overlapping_symbs													= input_c{8,1};
				search_symbs_without_overlap											= input_c{9,1};
				GV.analyze_unitedcolors.detect_misstextsymb.definput{1,1}	= colno_uec_v';
				GV.analyze_unitedcolors.detect_misstextsymb.definput{2,1}	= iobj_misstext_v';
				GV.analyze_unitedcolors.detect_misstextsymb.definput{3,1}	= nmin_overlapping_texts;
				GV.analyze_unitedcolors.detect_misstextsymb.definput{4,1}	= nmax_overlapping_texts;
				GV.analyze_unitedcolors.detect_misstextsymb.definput{5,1}	= search_texts_without_overlap;
				GV.analyze_unitedcolors.detect_misstextsymb.definput{6,1}	= iobj_misssymb_v';
				GV.analyze_unitedcolors.detect_misstextsymb.definput{7,1}	= nmin_overlapping_symbs;
				GV.analyze_unitedcolors.detect_misstextsymb.definput{8,1}	= nmax_overlapping_symbs;
				GV.analyze_unitedcolors.detect_misstextsymb.definput{9,1}	= search_symbs_without_overlap;
			otherwise
				errormessage;
		end
	else
		display_on_gui('state',...
			sprintf('%s ... canceled (%s).',action,...
			dt_string(etime(clock,t_start_statebusy))),'notbusy','replace');
		return
	end

	% Map objects to consider:
	imapobj_uec_v		= zeros(size(colno_uec_v,1),1);
	for k=1:size(colno_uec_v,1)
		imapobj_uec		= find([MAP_OBJECTS.cnuc]==colno_uec_v(k,1));
		if length(imapobj_uec)==1
			imapobj_uec_v(k,1)		= imapobj_uec;
		elseif length(imapobj_uec)>1
			errortext			= sprintf([...
				'The color number %1.0f has more than one\n',...
				'united equal colors map objects\n',...
				'(plot numbers %s).\n',...
				'Delete all except one of them or\n',...
				'recreate all united equal colors.'],colno_uec_v(k,1),num2str(imapobj_uec(:)'));
			errormessage(errortext);
		end
	end
	k					= find(imapobj_uec_v==0);
	if ~isempty(k)
		% At least one color number has no united equal colors: cancel:
		colno_uec_v_k		= colno_uec_v(k);
		colno_uec_v_k_str	= num2str(colno_uec_v_k(:)');
		if length(k)==1
			warntext		= sprintf([...
				'The color number %s has no corresponding\n',...
				'united equal colors. The function was aborted.'],colno_uec_v_k_str);
		else
			warntext		= sprintf([...
				'The color numbers %s have no corresponding\n',...
				'united equal colors. The function was aborted.'],colno_uec_v_k_str);
		end
		if isfield(GV_H.warndlg,'analyze_unitedcolors')
			if ishandle(GV_H.warndlg.analyze_unitedcolors)
				close(GV_H.warndlg.analyze_unitedcolors);
			end
		end
		GV_H.warndlg.analyze_unitedcolors		= warndlg(warntext,'Warning');
		GV_H.warndlg.analyze_unitedcolors.Tag	= 'maplab3d_figure';
		display_on_gui('state',...
			sprintf('%s ... aborted.',action),...
			'notbusy','replace');
		return
	end

	% Deselect all objects:
	plot_modify('deselect',-1,0);

	% Set the value of the cutting lines dropdown menu to 'None' (make the map objects visible):
	set_previewtype_dropdown(1);

	% Legend background:
	[poly_legbgd,~,~]		= get_poly_legbgd;
	if numboundaries(poly_legbgd)>0
		% Distance between legend and the other objects:
		icolspec_v	= [PP.color(PLOTDATA.colno_v).spec];
		d_side_v		= [PP.colorspec(icolspec_v).d_side];
		d_side		= max(d_side_v);
		dist_legobj_legbgd		=  max(0,PP.legend.dist_legobj_legbgd)+d_side+GV.tol_1;
		% Legend buffered:
		if strcmp(GV.jointtype_bh,'miter')
			poly_legbgd_p_buff	= polybuffer(poly_legbgd,dist_legobj_legbgd,...
				'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
		else
			poly_legbgd_p_buff	= polybuffer(poly_legbgd,dist_legobj_legbgd,...
				'JointType',GV.jointtype_bh);
		end
	end

	% There are united equal colors:
	% colno_uec_v:		color numbers to be considered
	% imapobj_uec_v:	map object numbers corresponding to colno_uec_v
	imapobj_new_v		= zeros(size(colno_uec_v,1),1);		% indices of new elements in MAP_OBJECTS
	no_obj_detected	= 0;
	for i_imapobj_v=1:size(imapobj_uec_v,1)
		imapobj_uec		= imapobj_uec_v(i_imapobj_v,1);
		colno_uec		= colno_uec_v(i_imapobj_v,1);
		if size(imapobj_uec_v,1)==1
			text_waitbar_colno	= sprintf('%s - ColNo %1.0f',action,colno_uec);
		else
			text_waitbar_colno	= sprintf('%s - ColNo %1.0f (%1.0f/%1.0f)',action,colno_uec,...
				i_imapobj_v,size(imapobj_uec_v,1));
		end
		if length(MAP_OBJECTS(imapobj_uec,1).h)~=1
			errormessage;
		end
		poly_prev			= polyshape();
		dscr_prev_short	= sprintf('%s: ColNo %1.0f',action,colno_uec);			% description short
		dscr_prev			= sprintf('%s (%s)',dscr_prev_short,...					% description full
			PP.color(colno_uec,1).description);
		text_prev			= sprintf('created %s',datestr(now));						% text
		fprintf(1,'--------------------------------------------------------------------------\n%s\n',dscr_prev);

		% United equal colors polygon:
		% It is not necessary to subtract the legend background from poly_uec, because it has already been done.
		poly_uec				= MAP_OBJECTS(imapobj_uec,1).h.Shape;

		% Calculation of poly_prev:
		switch action
			% -----------------------------------------------------------------------------------------------------------
			case  'Detect small holes'
				% If an area has a hole in it (for example a clearing in a forest), it can cause the underlying color
				% to fill the hole with a tall, narrow and therefore fragile column. To prevent this, the hole can be
				% removed by covering the hole with a polygon like a patch, which is assigned the same object number
				% as the rest of the area.

				poly_uec_regions	= regions(poly_uec);
				for ir_uec=1:length(poly_uec_regions)

					% Waitbar:
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress_ir	= (ir_uec-1)/length(poly_uec_regions)/size(imapobj_uec_v,1);
						progress		= min((i_imapobj_v-1)/size(imapobj_uec_v,1)+progress_ir,1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						set(GV_H.text_waitbar,'String',sprintf('%s - region (%1.0f/%1.0f)',text_waitbar_colno,...
							ir_uec,length(poly_uec_regions)));
						drawnow;
					end

					% Collect all too small holes in poly_prev:
					for ib=1:numboundaries(poly_uec_regions(ir_uec))
						if ishole(poly_uec_regions(ir_uec),ib)
							[xb,yb]			= boundary(poly_uec_regions(ir_uec),ib);
							poly_hole		= polyshape(xb,yb);
							[xlim,ylim]		= boundingbox(poly_hole);
							hole_diag		= sqrt((xlim(2)-xlim(1))^2+(ylim(2)-ylim(1))^2);
							hole_area		= area(poly_hole);
							fprintf(1,'region %1.0f/%1.0f, diag=%g, area=%g',...
								ir_uec,length(poly_uec_regions),hole_diag,hole_area);
							if (hole_diag<hole_mindiag)||(hole_area<hole_minarea)
								poly_prev			= union(poly_prev,poly_hole);
								no_obj_detected	= no_obj_detected+1;
								fprintf(1,'\t!!!');
							end
							fprintf(1,'\n');
						end
					end

				end


			% -----------------------------------------------------------------------------------------------------------
			case  'Detect small pieces'
				% This function detects small pieces of the same color, based on the "united equal colors".

				poly_uec_regions	= regions(poly_uec);
				for ir_uec=1:length(poly_uec_regions)

					% Waitbar:
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress_ir	= (ir_uec-1)/length(poly_uec_regions)/size(imapobj_uec_v,1);
						progress		= min((i_imapobj_v-1)/size(imapobj_uec_v,1)+progress_ir,1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						set(GV_H.text_waitbar,'String',sprintf('%s - region (%1.0f/%1.0f)',text_waitbar_colno,...
							ir_uec,length(poly_uec_regions)));
						drawnow;
					end

					% Collect all too small regions in poly_prev:
					[xlim,ylim]		= boundingbox(poly_uec_regions(ir_uec));
					region_diag		= sqrt((xlim(2)-xlim(1))^2+(ylim(2)-ylim(1))^2);
					region_area		= area(poly_uec_regions(ir_uec));
					fprintf(1,'region %1.0f/%1.0f, diag=%g, area=%g',...
						ir_uec,length(poly_uec_regions),region_diag,region_area);
					if (region_diag<mindiag)||(region_area<minarea)
						poly_prev			= union(poly_prev,poly_uec_regions(ir_uec));
						no_obj_detected	= no_obj_detected+1;
						fprintf(1,'\t!!!');
					end
					fprintf(1,'\n');

				end


				% --------------------------------------------------------------------------------------------------------
			case 'Detect fragile pieces'
				% This function detects whether a part is fragile by shifting the contour inwards by half the minimum
				% width. If this results in several individual parts, the part is too narrow in at least one place.
				testplot	= false;

				poly_uec_regions	= regions(poly_uec);
				for ir_uec=1:length(poly_uec_regions)

					% Waitbar:
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress_ir	= (ir_uec-1)/length(poly_uec_regions)/size(imapobj_uec_v,1);
						progress		= min((i_imapobj_v-1)/size(imapobj_uec_v,1)+progress_ir,1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						set(GV_H.text_waitbar,'String',sprintf('%s - region (%1.0f/%1.0f)',text_waitbar_colno,...
							ir_uec,length(poly_uec_regions)));
						drawnow;
					end

					% Collect all fragile pieces in poly_prev:
					poly1					= poly_uec_regions(ir_uec);					% poly1 has only one region
					poly_ir_mtol		= polybuffer(poly1,-possbreakpoint_minwidth/2,...
						'JointType','miter','MiterLimit',2);
					poly_ir_mptol		= polybuffer(poly_ir_mtol,possbreakpoint_minwidth/2+GV.tol_1,...
						'JointType','miter','MiterLimit',2);
					poly_breakpoints	= subtract(poly1,poly_ir_mptol);
					poly_breakpoints	= polybuffer(poly_breakpoints,2*GV.tol_1,...
						'JointType','miter','MiterLimit',2);
					poly_breakpoints_regions	= regions(poly_breakpoints);
					no_breakpoints					= 0;
					if testplot
						hf_testplot		= 958485971;
						hf_testplot		= figure(hf_testplot);
						clf(hf_testplot,'reset');
						set(hf_testplot,'Tag','maplab3d_figure');
						ha_testplot		= axes(hf_testplot);
						hold(ha_testplot,'on');
						axis(ha_testplot,'equal');
						plot(ha_testplot,poly1);
					end
					for irbp=1:length(poly_breakpoints_regions)
						poly2					= poly_breakpoints_regions(irbp);		% poly2 has only one region
						if testplot
							plot(ha_testplot,poly2);
						end
						% Show only those too small areas that can cause the region to break into more pieces,
						% and not those too small areas at the edge of the region:
						% Number of intersection points between poly1 and poly2:
						[x1,y1] = boundary(poly1);
						[x2,y2] = boundary(poly2);
						[xi,~] = polyxpoly(x1,y1,x2,y2);
						if size(xi,1)>2
							% There are more than 2 intersection points:
							no_breakpoints		= no_breakpoints+1;
							poly_prev			= union(poly_prev,poly2);		% all preview polygons
							setbreakpoint=1;
						end
						setbreakpoint=1;
					end
					if no_breakpoints>0
						if no_breakpoints==1
							fprintf(1,'region %1.0f/%1.0f: may break into 1 part !!!\n',...
								ir_uec,length(poly_uec_regions));
						else
							fprintf(1,'region %1.0f/%1.0f: may break into %1.0f parts !!!\n',...
								ir_uec,length(poly_uec_regions),no_breakpoints);
						end
					end
					no_obj_detected	= no_obj_detected+no_breakpoints;

				end				% End of: for ir_uec=1:length(poly_uec_regions)


				% --------------------------------------------------------------------------------------------------------
			case 'Detect misplaced texts and symbols'

				% poly_prev(1,1)							  united equal color regions where texts/symbols are misplaced
				poly_prev(2,1)		= polyshape();		% texts/symbols: wrong number
				poly_prev(3,1)		= polyshape();		% texts/symbols: isolated

				% Collect all relevant texts and symbols:
				poly_text_all		= polyshape();
				poly_symb_all		= polyshape();
				for imapobj=1:size(MAP_OBJECTS,1)

					% Waitbar:
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress_imapobj	= (imapobj-1)/size(MAP_OBJECTS,1)/size(imapobj_uec_v,1)/2;
						progress		= min((i_imapobj_v-1)/size(imapobj_uec_v,1)+progress_imapobj,1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						set(GV_H.text_waitbar,'String',sprintf('%s - PlotNo (%1.0f/%1.0f)',text_waitbar_colno,...
							imapobj,size(MAP_OBJECTS,1)));
						drawnow;
					end

					% Texts:
					if any(iobj_misstext_v==MAP_OBJECTS(imapobj,1).iobj)
						if strcmp(MAP_OBJECTS(imapobj,1).disp,'text')
							for rpoly=1:size(MAP_OBJECTS(imapobj,1).h,1)
								if    MAP_OBJECTS(imapobj,1).h(rpoly,1).Visible                                        &&...
										isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
										isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).FaceAlpha,GV.visibility.show.facealpha)
									% Collect texts:
									poly_text_all	= union(poly_text_all,MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape,...
										'KeepCollinearPoints',false);
								end
							end
						end
					end

					% Symbols:
					if any(iobj_misssymb_v==MAP_OBJECTS(imapobj,1).iobj)
						if strcmp(MAP_OBJECTS(imapobj,1).disp,'symbol')
							for rpoly=1:size(MAP_OBJECTS(imapobj,1).h,1)
								if    MAP_OBJECTS(imapobj,1).h(rpoly,1).Visible                                        &&...
										isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
										isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).FaceAlpha,GV.visibility.show.facealpha)
									% Collect symbols:
									poly_symb_all	= union(poly_symb_all,MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape,...
										'KeepCollinearPoints',false);
								end
							end
						end
					end

				end

				% Cut poly_text_all and poly_symb_all to the printout limits:
				poly_text_all	= intersect(poly_text_all,...
					GV_H.poly_map_printout_obj_limits.Shape,'KeepCollinearPoints',false);
				poly_symb_all	= intersect(poly_symb_all,...
					GV_H.poly_map_printout_obj_limits.Shape,'KeepCollinearPoints',false);

				% Subtract the legend background from poly_text_all and poly_symb_all:
				if numboundaries(poly_legbgd)>0
					poly_text_all		= subtract(poly_text_all,poly_legbgd_p_buff);
					poly_symb_all		= subtract(poly_symb_all,poly_legbgd_p_buff);
				end

				% Check all regions:
				poly_uec_regions				= regions(poly_uec);
				poly_uec_regions_xlim		= zeros(size(poly_uec_regions,1),2);
				poly_uec_regions_ylim		= zeros(size(poly_uec_regions,1),2);
				poly_text_all_reg				= regions(poly_text_all);
				poly_text_all_reg_overlap	= false(size(poly_text_all_reg,1),1);
				poly_symb_all_reg				= regions(poly_symb_all);
				poly_symb_all_reg_overlap	= false(size(poly_symb_all_reg,1),1);
				for ir_uec=1:length(poly_uec_regions)

					% Waitbar:
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress_ir	= (ir_uec-1)/length(poly_uec_regions)/size(imapobj_uec_v,1)/2;
						progress		= min(((i_imapobj_v-1)/2+0.5)/size(imapobj_uec_v,1)+progress_ir,1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						set(GV_H.text_waitbar,'String',sprintf('%s - region (%1.0f/%1.0f)',text_waitbar_colno,...
							ir_uec,length(poly_uec_regions)));
						drawnow;
					end

					% poly_uec_regions bounding box:
					[  poly_uec_regions_xlim(ir_uec,:),...
						poly_uec_regions_ylim(ir_uec,:)]		= boundingbox(poly_uec_regions(ir_uec));

					% Check for text overlap:
					if numboundaries(poly_text_all)>0
						% Text bounding box:
						poly_text_all_reg_xlim		= zeros(size(poly_text_all_reg,1),2);
						poly_text_all_reg_ylim		= zeros(size(poly_text_all_reg,1),2);
						for ir=1:size(poly_text_all_reg,1)
							[  poly_text_all_reg_xlim(ir,:),...
								poly_text_all_reg_ylim(ir,:)]		= boundingbox(poly_text_all_reg(ir));
						end
						% Test for overlap of all texts with the current united equal colors region:
						overlap_v			= false(size(poly_text_all_reg,1),1);
						for ir=1:size(poly_text_all_reg,1)
							if overlaps_boundingbox(GV.tol_1,...
									poly_uec_regions_xlim(ir_uec,1),poly_uec_regions_xlim(ir_uec,2),...		% x1min,x1max
									poly_uec_regions_ylim(ir_uec,1),poly_uec_regions_ylim(ir_uec,2),...		% y1min,y1max
									poly_text_all_reg_xlim(ir,1),   poly_text_all_reg_xlim(ir,2),...			% x2min,x2max
									poly_text_all_reg_ylim(ir,1),   poly_text_all_reg_ylim(ir,2))				% y2min,y2max
								if overlaps(poly_uec_regions(ir_uec),poly_text_all_reg(ir))
									% If the two polygons:	united equal colors region:	poly_uec_regions(ir_uec) and
									%								text region:						poly_text_all_reg(ir)
									% 1) are equal:		That means that the text is probably isolated.
									%							The text should not be displayed as overlapping.
									%							Theoretically, the two polygons could belong to different colors, but
									%							that is improbable. In this case the text is displayed as isolated.
									% 2) are not equal:	That means that they overlap.
									polygons_are_not_equal				= false;
									poly_uec_regions_ir_uec_buff	= polybuffer(poly_uec_regions(ir_uec),2*GV.tol_1);
									diffpoly		= subtract(poly_text_all_reg(ir),poly_uec_regions_ir_uec_buff);
									if    (numboundaries(diffpoly)~=0)
										polygons_are_not_equal				= true;
									else
										poly_text_all_reg_ir_buff		= polybuffer(poly_text_all_reg(ir),2*GV.tol_1);
										diffpoly		= subtract(poly_uec_regions(ir_uec),poly_text_all_reg_ir_buff   );
										if (numboundaries(diffpoly)~=0)
											polygons_are_not_equal				= true;
										end
									end
									if polygons_are_not_equal
										overlap_v(ir,1)						= true;
										poly_text_all_reg_overlap(ir,1)	= true;
									end
								end
							end
						end
						% Check the number of overlaps:
						ir_overlap_v			= find(overlap_v);
						n_overlap				= size(ir_overlap_v,1);
						if (n_overlap<nmin_overlapping_texts)||(n_overlap>nmax_overlapping_texts)
							% The number of overlaps is not within the specification:
							poly_prev(1,1)		= union(poly_prev(1,1),poly_uec_regions(ir_uec));
							for k_ir=1:n_overlap
								ir					= ir_overlap_v(k_ir,1);
								poly_prev(2,1)	= union(poly_prev(2,1),poly_text_all_reg(ir));
							end
						end
					end

					% Check for symbol overlap:
					if numboundaries(poly_symb_all)>0
						% Symbol bounding box:
						poly_symb_all_reg_xlim		= zeros(size(poly_symb_all_reg,1),2);
						poly_symb_all_reg_ylim		= zeros(size(poly_symb_all_reg,1),2);
						for ir=1:size(poly_symb_all_reg,1)
							[  poly_symb_all_reg_xlim(ir,:),...
								poly_symb_all_reg_ylim(ir,:)]		= boundingbox(poly_symb_all_reg(ir));
						end
						% Test for overlap of all symbols with the current united equal colors region:
						overlap_v			= false(size(poly_symb_all_reg,1),1);
						for ir=1:size(poly_symb_all_reg,1)
							if overlaps_boundingbox(GV.tol_1,...
									poly_uec_regions_xlim(ir_uec,1),poly_uec_regions_xlim(ir_uec,2),...		% x1min,x1max
									poly_uec_regions_ylim(ir_uec,1),poly_uec_regions_ylim(ir_uec,2),...		% y1min,y1max
									poly_symb_all_reg_xlim(ir,1),   poly_symb_all_reg_xlim(ir,2),...			% x2min,x2max
									poly_symb_all_reg_ylim(ir,1),   poly_symb_all_reg_ylim(ir,2))				% y2min,y2max
								if overlaps(poly_uec_regions(ir_uec),poly_symb_all_reg(ir))
									% If the two polygons:	united equal colors region:	poly_uec_regions(ir_uec) and
									%								symbol region:						poly_symb_all_reg(ir)
									% 1) are equal:		That means that the symbol is probably isolated.
									%							The symbol should not be displayed as overlapping.
									%							Theoretically, the two polygons could belong to different colors, but
									%							that is improbable. In this case the text is displayed as isolated.
									% 2) are not equal:	That means that they overlap.
									polygons_are_not_equal				= false;
									poly_uec_regions_ir_uec_buff	= polybuffer(poly_uec_regions(ir_uec),2*GV.tol_1);
									diffpoly		= subtract(poly_symb_all_reg(ir),poly_uec_regions_ir_uec_buff);
									if    (numboundaries(diffpoly)~=0)
										polygons_are_not_equal				= true;
									else
										poly_symb_all_reg_ir_buff		= polybuffer(poly_symb_all_reg(ir),2*GV.tol_1);
										diffpoly		= subtract(poly_uec_regions(ir_uec),poly_symb_all_reg_ir_buff   );
										if (numboundaries(diffpoly)~=0)
											polygons_are_not_equal				= true;
										end
									end
									if polygons_are_not_equal
										overlap_v(ir,1)						= true;
										poly_symb_all_reg_overlap(ir,1)	= true;
									end
								end
							end
						end
						% Check the number of overlaps:
						ir_overlap_v			= find(overlap_v);
						n_overlap				= size(ir_overlap_v,1);
						if (n_overlap<nmin_overlapping_symbs)||(n_overlap>nmax_overlapping_symbs)
							% The number of overlaps is not within the specification:
							poly_prev(1,1)		= union(poly_prev(1,1),poly_uec_regions(ir_uec));
							for k_ir=1:n_overlap
								ir					= ir_overlap_v(k_ir,1);
								poly_prev(2,1)	= union(poly_prev(2,1),poly_symb_all_reg(ir));
							end
						end
					end

				end

				% Isolated texts:
				if search_texts_without_overlap~=0
					ir_no_overlap_v	= find(~poly_text_all_reg_overlap);
					for k_ir=1:size(ir_no_overlap_v,1)
						ir						= ir_no_overlap_v(k_ir,1);
						poly_prev(3,1)		= union(poly_prev(3,1),poly_text_all_reg(ir));
					end
				end

				% Isolated symbols:
				if search_symbs_without_overlap~=0
					ir_no_overlap_v	= find(~poly_symb_all_reg_overlap);
					for k_ir=1:size(ir_no_overlap_v,1)
						ir						= ir_no_overlap_v(k_ir,1);
						poly_prev(3,1)		= union(poly_prev(3,1),poly_symb_all_reg(ir));
					end
				end

				% Delete empty elements in poly_prev:
				i_delete		= false(size(poly_prev,1),1);
				for i=1:size(poly_prev,1)
					if numboundaries(poly_prev(i,1))==0
						i_delete(i,1)		= true;
					end
				end
				poly_prev(i_delete,:)	= [];

				% Number of detected objects:
				for i=1:size(poly_prev,1)
					poly_prev_i_regions		= regions(poly_prev(i,1));
					no_obj_detected			= no_obj_detected+size(poly_prev_i_regions,1);
				end

		end

		% Detect existing map object numbers with older preview polygons:
		imapobj_prev_v	= [];
		for imapobj=1:size(MAP_OBJECTS,1)
			if isequal(strfind(MAP_OBJECTS(imapobj,1).dscr,dscr_prev_short),1)
				imapobj_prev_v	= [imapobj_prev_v;imapobj];
			end
		end
		% If there is more than one preview plot object: Delete the rest:
		if length(imapobj_prev_v)>=2
			plot_modify('delete',imapobj_prev_v(2:end));		% Includes also display_map_objects
			imapobj_prev_v	= imapobj_prev_v(1);
		end
		if length(imapobj_prev_v)==1
			if    (size(MAP_OBJECTS(imapobj_prev_v,1).h,1)~=size(poly_prev,1))||...
					(size(MAP_OBJECTS(imapobj_prev_v,1).h,2)~=size(poly_prev,2))
				plot_modify('delete',imapobj_prev_v);		% Includes also display_map_objects
				imapobj_prev_v	= [];
			end
		end
		% Hide the old results:
		if ~isempty(imapobj_prev_v)
			plot_modify('hide',imapobj_prev_v);
		end

		% Add the preview to the map:
		if no_obj_detected>0
			% There is data to plot:
			if isempty(imapobj_prev_v)
				imapobj_new_v(i_imapobj_v,1)	= plot_modify('new_poly',0,...
					poly_prev,...				% preview polygon
					dscr_prev,...				% description
					text_prev,...				% text
					false);						% select (true/false)
			else
				[xcenter,ycenter]										= centroid(poly_prev);
				for i=1:size(poly_prev,1)
					MAP_OBJECTS(imapobj_prev_v,1).h(i,1).Shape	= poly_prev(i,1);
				end
				MAP_OBJECTS(imapobj_prev_v,1).dscr				= dscr_prev;
				MAP_OBJECTS(imapobj_prev_v,1).x					= xcenter;
				MAP_OBJECTS(imapobj_prev_v,1).y					= ycenter;
				MAP_OBJECTS(imapobj_prev_v,1).text				= {text_prev};
				imapobj_new_v(i_imapobj_v,1)						= imapobj_prev_v;
				plot_modify('show',imapobj_prev_v);
			end
		end

	end

	% Create/modify legend:
	create_legend_mapfigure;			% Do not delete, is used by other actions!

	% Update MAP_OBJECTS_TABLE:
	display_map_objects;					% Do not delete, is used by other actions!

	% Show the whole map (zoom fit):
	SizeChangedFcn_fig_2dmap([],[],1,1);
	figure(GV_H.fig_2dmap);

	% Display state:
	t_end_statebusy					= clock;
	dt_statebusy						= etime(t_end_statebusy,t_start_statebusy);
	dt_statebusy_str					= dt_string(dt_statebusy);
	if no_obj_detected==0
		% No preview polygon has been created:
		log_str	= 'nothing to do';
		waitbar_str				= sprintf('%s ... nothing detected, no preview polygon created.',action);
	else
		% At least one preview polygon has been created:
		log_str					= sprintf('%g detected',no_obj_detected);
		imapobj_new_red_v		= imapobj_new_v(imapobj_new_v>0);
		imapobj_new_red_v		= sort(imapobj_new_red_v);
		if size(imapobj_new_red_v,1)==1
			waitbar_str			= sprintf('%s ... %s, 1 preview polygon created (PlotNo %1.0f).',...
				action,log_str,imapobj_new_red_v);
		else
			waitbar_str			= sprintf('%s ... %s, %1.0f preview polygons created (PlotNo %1.0f',...
				action,log_str,length(imapobj_new_red_v),imapobj_new_red_v(1,1));
			for k=2:size(imapobj_new_red_v,1)
				waitbar_str		= sprintf('%s, %1.0f',waitbar_str,imapobj_new_red_v(k,1));
			end
			waitbar_str			= sprintf('%s).',waitbar_str);
		end
	end
	display_on_gui('state',...
		sprintf('%s ... %s (%s).',action,log_str,dt_statebusy_str),...
		'notbusy','replace');

	% Reset waitbar:
	set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
	set(GV_H.text_waitbar,'String',waitbar_str);

catch ME
	errormessage('',ME);
end


