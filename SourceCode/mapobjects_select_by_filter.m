function mapobjects_select_by_filter
% Selection of multiple objects by filter criteria

global APP MAP_OBJECTS_TABLE MAP_OBJECTS GV GV_H

try

	% Display state:
	display_on_gui('state','Select map objects ...','busy','add');
	waitbar_t1		= clock;

	% % % % Initializations:
	% % % prompt{1,1}		= sprintf([...
	% % % 	'Enter the filter criteria (empty: no criterion):\n',...
	% % % 	'\n',...
	% % % 	'Object numbers to select:\n',...
	% % % 	'(E.g.: 1,2,5:7   -->   Select ObjNo 1,2,5,6,7)']);
	% % % prompt{2,1}		= sprintf([...
	% % % 	'Color numbers to select:\n',...
	% % % 	'(E.g.: 1,2,5:7   -->   Select ColNo 1,2,5,6,7)']);
	% % % prompt{3,1}		= 'Select hidden objects (0/1):';
	% % % prompt{4,1}		= 'Select grayed out objects (0/1):';
	% % % prompt{5,1}		= 'Select visible objects (0/1):';
	% % % prompt{6,1}		= 'Select lines (0/1):';
	% % % prompt{7,1}		= 'Select areas (0/1):';
	% % % prompt{8,1}		= 'Select texts (0/1):';
	% % % prompt{9,1}		= 'Select symbols (0/1):';
	% % % prompt{10,1}	= 'Select preview cutting lines (0/1):';
	% % % prompt{11,1}	= 'Minimum length of the bounding box diagonal / mm:';
	% % % prompt{12,1}	= 'Maximum length of the bounding box diagonal / mm:';
	% % % prompt{13,1}	= 'Minimum area / mm^2:';
	% % % prompt{14,1}	= 'Maximum area / mm^2:';
	% % % if isfield(GV,'mapobjects_select_by_filter_settings')
	% % % 	definput		= GV.mapobjects_select_by_filter_settings;
	% % % else
	% % % 	definput{1,1}	= '';			% sel_objno_v
	% % % 	definput{2,1}	= '';			% sel_colno_v
	% % % 	definput{3,1}	= '';			% sel_hi_obj
	% % % 	definput{4,1}	= '';			% sel_go_obj
	% % % 	definput{5,1}	= '1';		% sel_vi_obj
	% % % 	definput{6,1}	= '1';		% sel_line
	% % % 	definput{7,1}	= '1';		% sel_area
	% % % 	definput{8,1}	= '1';		% sel_text
	% % % 	definput{9,1}	= '1';		% sel_symb
	% % % 	definput{10,1}	= '1';		% sel_prcl
	% % % 	definput{11,1}	= '';			% sel_diag_min
	% % % 	definput{12,1}	= '';			% sel_diag_max
	% % % 	definput{13,1}	= '';			% sel_area_min
	% % % 	definput{14,1}	= '';			% sel_area_max
	% % % end
	% % %
	% % % % User input:
	% % % dlgtitle		= 'Enter filter criteria';
	% % % dims			= 1;
	% % % answer		= inputdlg_local(prompt,dlgtitle,dims,definput);
	% % % if ~isempty(answer)
	% % % 	sel_objno_v		= str2num(answer{1});	sel_objno_v	= sel_objno_v(:);
	% % % 	sel_colno_v		= str2num(answer{2});	sel_colno_v	= sel_colno_v(:);
	% % % 	sel_hi_obj		= str2double(answer{3});
	% % % 	sel_go_obj		= str2double(answer{4});
	% % % 	sel_vi_obj		= str2double(answer{5});
	% % % 	sel_line			= str2double(answer{6});
	% % % 	sel_area			= str2double(answer{7});
	% % % 	sel_text			= str2double(answer{8});
	% % % 	sel_symb			= str2double(answer{9});
	% % % 	sel_prcl			= str2double(answer{10});
	% % % 	sel_diag_min	= str2double(answer{11});
	% % % 	sel_diag_max	= str2double(answer{12});
	% % % 	sel_area_min	= str2double(answer{13});
	% % % 	sel_area_max	= str2double(answer{14});
	% % % 	sel_objno_v		= sel_objno_v(:);
	% % % 	sel_colno_v		= sel_colno_v(:);
	% % % 	if isequal(sel_hi_obj,0)||isnan(sel_hi_obj), sel_hi_obj=false; else, sel_hi_obj=true; end
	% % % 	if isequal(sel_go_obj,0)||isnan(sel_go_obj), sel_go_obj=false; else, sel_go_obj=true; end
	% % % 	if isequal(sel_vi_obj,0)||isnan(sel_vi_obj), sel_vi_obj=false; else, sel_vi_obj=true; end
	% % % 	if isequal(sel_line  ,0)||isnan(sel_line  ), sel_line  =false; else, sel_line  =true; end
	% % % 	if isequal(sel_area  ,0)||isnan(sel_area  ), sel_area  =false; else, sel_area  =true; end
	% % % 	if isequal(sel_text  ,0)||isnan(sel_text  ), sel_text  =false; else, sel_text  =true; end
	% % % 	if isequal(sel_symb  ,0)||isnan(sel_symb  ), sel_symb  =false; else, sel_symb  =true; end
	% % % 	if isequal(sel_prcl  ,0)||isnan(sel_prcl  ), sel_prcl  =false; else, sel_prcl  =true; end
	% % % 	if isnan(sel_diag_min), sel_diag_min=0;    end
	% % % 	if isnan(sel_diag_max), sel_diag_max=1e10; end
	% % % 	if isnan(sel_area_min), sel_area_min=0;    end
	% % % 	if isnan(sel_area_max), sel_area_max=1e10; end
	% % % 	% 	sel_objno_v
	% % % 	% 	sel_colno_v
	% % % 	% 	sel_hi_obj
	% % % 	% 	sel_go_obj
	% % % 	% 	sel_vi_obj
	% % % 	% 	sel_line
	% % % 	% 	sel_area
	% % % 	% 	sel_text
	% % % 	% 	sel_symb
	% % % 	% 	sel_prcl
	% % % 	% 	sel_diag_min
	% % % 	% 	sel_diag_max
	% % % 	% 	sel_area_min
	% % % 	% 	sel_area_max
	% % % else
	% % % 	display_on_gui('state','Select map objects ... canceled','notbusy','replace');
	% % % 	set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
	% % % 	set(GV_H.text_waitbar,'String','');
	% % % 	return
	% % % end
	% % % GV.mapobjects_select_by_filter_settings	= answer;
	% % %
	% % % % Plausibility checks:
	% % % if ~sel_hi_obj&&~sel_go_obj&&~sel_vi_obj
	% % % 	errortext	= sprintf([...
	% % % 		'You have to choose something from\n',...
	% % % 		'hidden, grayed out or visible objects.']);
	% % % 	errormessage(errortext);
	% % % end
	% % % if ~sel_line&&~sel_area&&~sel_text&&~sel_symb&&~sel_prcl
	% % % 	errortext	= sprintf([...
	% % % 		'You have to choose something from lines,\n',...
	% % % 		'areas, text, symbols or preview cutting lines.']);
	% % % 	errormessage(errortext);
	% % % end

	% Get user inputs:
	GV_H.mapobjects_select_by_filter_getuserinput	= [];
	mapobjects_select_by_filter_getuserinput;
	% Polling:
	pause(0.1);
	while isempty(GV_H.mapobjects_select_by_filter_getuserinput)
		pause(0.1);
	end
	while isvalid(GV_H.mapobjects_select_by_filter_getuserinput)
		pause(0.1);
	end
	% Results examples:
	% GV.selbyfilt.select =
	%   logical
	%    1
	% GV.selbyfilt.sel =
	%   struct with fields:
	%                   logic: true
	%                 visible: 1
	%               grayedout: 0
	%                  hidden: 0
	%              tempHidden: 0
	%                   lines: 1
	%                   areas: 0
	%                   texts: 0
	%                 symbols: 0
	%         connectionlines: 0
	%          previewobjects: 0
	%     previewcuttinglines: 0
	%            cuttinglines: 0
	%             description: 'asdf'
	%                 texttag: 'hgfd'
	%                 mindiag: 1
	%                 maxdiag: 2
	%                 minarea: 3
	%                 maxarea: 4
	%                  iobj_v: [10 12 15]
	%                 colno_v: [0 4 9]
	%                chstno_v: []
	%                  isym_v: [8 19]

	if ~GV.selbyfilt.select
		% Select by filter was canceled or there was an error:
		display_on_gui('state','Select map objects ... canceled','notbusy','replace');
		set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
		set(GV_H.text_waitbar,'String','');
		return
	end

	% Table to structure array:
	if APP.ShowMapObjectsTable_Menu.Checked
		% The map objects table is enabled:
		mot		= MAP_OBJECTS_TABLE;
	else
		% The map objects table is disabled:
		mot		= display_map_objects;
	end
	map_obj_table			= table2struct(mot);

	imapobj_select			= true(size(map_obj_table,1),1);
	imapobj_ambiguous_colors_v	=  [];
	for imapobj=1:size(map_obj_table,1)

		% Waitbar:
		if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
			waitbar_t1	= clock;
			progress		= min((imapobj-1)/size(map_obj_table,1),1);
			set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
			drawnow;
		end

		% Object number: objno
		if isnumeric(map_obj_table(imapobj,1).ObjNo)
			objno				= map_obj_table(imapobj,1).ObjNo;
		else
			objno				= str2double(map_obj_table(imapobj,1).ObjNo);	% maybe NaN
		end

		% Color number: colno
		colno_v				= nan(size(MAP_OBJECTS(imapobj,1).h,1),1);
		for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
			if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'color_no')
				colno_v(i,1)			= MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no;
			end
		end
		colno		= unique(colno_v);
		if any(isnan(colno))
			% There is at least one undefined color in the map object: Do not select the object in this case.
			colno		= NaN;
		end
		if length(colno)>1
			% There are at least 2 colors in the map object (e. g. foreground and background):
			% Do not select the object in this case.
			colno		= NaN;
		end
		if isnan(colno)&&~isempty(GV.selbyfilt.sel.colno_v)
			for i=1:size(colno_v,1)
				if ~isnan(colno_v(i,1))
					if any(colno_v(i,1)==GV.selbyfilt.sel.colno_v)
						imapobj_ambiguous_colors_v	= [imapobj_ambiguous_colors_v;imapobj];
					end
				end
			end
		end

		% Character style number: chstno
		% The character style number in one group is always unique.
		if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'chstno')
			chstno			= MAP_OBJECTS(imapobj,1).h(1,1).UserData.chstno;
		else
			chstno			= NaN;
		end

		% Symbol number: isym
		% The symbol number in one group is always unique.
		if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'isym')
			isym			= MAP_OBJECTS(imapobj,1).h(1,1).UserData.isym;
		else
			isym			= NaN;
		end

		% Visiblity:
		vis					= map_obj_table(imapobj,1).Vis;

		% Object type:
		dispas				= map_obj_table(imapobj,1).DispAs;

		% Description:
		descr					= map_obj_table(imapobj,1).Description;

		% Text/Tag:
		texttag				= map_obj_table(imapobj,1).Text;

		% Diagonal and area:
		poly_all				= polyshape();
		for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
			if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
				poly_all			= union(poly_all,MAP_OBJECTS(imapobj,1).h(i,1).Shape,'KeepCollinearPoints',false);
			end
		end
		if numboundaries(poly_all)>0
			[xlim,ylim]		= boundingbox(poly_all);
			diag_mm			= sqrt((xlim(2)-xlim(1))^2+(ylim(2)-ylim(1))^2);
			area_mm2			= area(poly_all);
		else
			diag_mm			= 0;
			area_mm2			= 0;
		end

		% If the condition is not met: do not select the object:
		if ~isempty(GV.selbyfilt.sel.iobj_v)
			if ~any(GV.selbyfilt.sel.iobj_v==objno)
				imapobj_select(imapobj)	= false;
			end
		end
		if ~isempty(GV.selbyfilt.sel.colno_v)
			if ~any(GV.selbyfilt.sel.colno_v==colno)
				imapobj_select(imapobj)	= false;
			end
		end
		if ~isempty(GV.selbyfilt.sel.chstno_v)
			if ~any(GV.selbyfilt.sel.chstno_v==chstno)
				imapobj_select(imapobj)	= false;
			end
		end
		if ~isempty(GV.selbyfilt.sel.isym_v)
			if ~any(GV.selbyfilt.sel.isym_v==isym)
				imapobj_select(imapobj)	= false;
			end
		end
		if  ~((GV.selbyfilt.sel.hidden    &&strcmp(vis,'H' ))||...
				(GV.selbyfilt.sel.tempHidden&&strcmp(vis,'HT'))||...
				(GV.selbyfilt.sel.grayedout &&strcmp(vis,'GO'))||...
				(GV.selbyfilt.sel.visible   &&strcmp(vis,''  ))     )
			imapobj_select(imapobj)	= false;
		end
		if  ~((GV.selbyfilt.sel.lines              &&strcmp(dispas,'line'                ))||...
				(GV.selbyfilt.sel.areas              &&strcmp(dispas,'area'                ))||...
				(GV.selbyfilt.sel.texts              &&strcmp(dispas,'text'                ))||...
				(GV.selbyfilt.sel.symbols            &&strcmp(dispas,'symbol'              ))||...
				(GV.selbyfilt.sel.connectionlines    &&strcmp(dispas,'connection line'     ))||...
				(GV.selbyfilt.sel.previewobjects     &&strcmp(dispas,'area - not closed'   ))||...
				(GV.selbyfilt.sel.previewobjects     &&strcmp(dispas,'preview node'        ))||...
				(GV.selbyfilt.sel.previewobjects     &&strcmp(dispas,'preview line'        ))||...
				(GV.selbyfilt.sel.previewobjects     &&strcmp(dispas,'preview polygon'     ))||...
				(GV.selbyfilt.sel.previewcuttinglines&&strcmp(dispas,'preview cutting line'))||...
				(GV.selbyfilt.sel.cuttinglines       &&strcmp(dispas,'cutting line'        ))     )
			imapobj_select(imapobj)	= false;
		end

		if imapobj==13
			test=1;
		end

		if ~isempty(GV.selbyfilt.sel.description)
			out_description	= regexpi(descr,...
				regexptranslate('wildcard',['*' GV.selbyfilt.sel.description '*']),'match');
			if ~isequal(descr,out_description)
				imapobj_select(imapobj)	= false;
			end
		end
		if ~isempty(GV.selbyfilt.sel.texttag)
			out_texttag			= regexpi(texttag,...
				regexptranslate('wildcard',['*' GV.selbyfilt.sel.texttag '*']),'match');
			if ~isequal(texttag,out_texttag)
				imapobj_select(imapobj)	= false;
			end
		end
		if  ~((diag_mm >=GV.selbyfilt.sel.mindiag)&&...
				(diag_mm <=GV.selbyfilt.sel.maxdiag)&&...
				(area_mm2>=GV.selbyfilt.sel.minarea)&&...
				(area_mm2<=GV.selbyfilt.sel.maxarea)     )
			imapobj_select(imapobj)	= false;
		end

	end

	% Warning if grouped objects were not selected because the color numbers in the group are not unique:
	imapobj_ambiguous_colors_v		= unique(imapobj_ambiguous_colors_v);
	if ~isempty(imapobj_ambiguous_colors_v)
		warntext		= sprintf([...
			'Some map objects partially meet the filter criteria, but this does\n',...
			'not apply to all objects in the group. The reason is that the color\n',...
			'numbers within a group are different. The map objects with the \n',...
			'following plot numbers were therefore not taken into account:']);
		rmax		= 20;
		cmax		= 10;
		r			= 1;
		c			= 1;
		for i=1:size(imapobj_ambiguous_colors_v,1)
			if (r<=rmax)&&(c<=cmax)
				if c==1
					if r==1
						warntext		= sprintf('%s\n%g',warntext,imapobj_ambiguous_colors_v(i,1));
					else
						warntext		= sprintf('%s,\n%g',warntext,imapobj_ambiguous_colors_v(i,1));
					end
				else
					warntext		= sprintf('%s, %g',warntext,imapobj_ambiguous_colors_v(i,1));
				end
				c				= c+1;
				if c>cmax
					c			= 1;
					r			= r+1;
				end
				if i==size(imapobj_ambiguous_colors_v,1)
					warntext		= sprintf('%s.',warntext);
				else
					if r>rmax
						warntext		= sprintf('%s\nand others.',warntext);
						break
					end
				end
			end
		end
		if isfield(GV_H.warndlg,'mapobjects_select_by_filter')
			if ishandle(GV_H.warndlg.mapobjects_select_by_filter)
				close(GV_H.warndlg.mapobjects_select_by_filter);
			end
		end
		GV_H.warndlg.mapobjects_select_by_filter		= warndlg(warntext,'Warning');
		GV_H.warndlg.mapobjects_select_by_filter.Tag	= 'maplab3d_figure';
	end

	% Select the objects:
	if GV.selbyfilt.sel.logic
		% Select all objects, that meet these conditions
	else
		% Select all objects, except those that meet these conditions
		imapobj_select		= ~imapobj_select;
	end
	imapobj_v	= find(imapobj_select);
	plot_modify('deselect',-1,0);
	if ~isempty(imapobj_v)
		plot_modify('select',imapobj_v,0);
	end

	% Display state:
	if length(imapobj_v)==1
		display_on_gui('state','Select map objects ... 1 object selected','notbusy','replace');
	else
		display_on_gui('state',sprintf('Select map objects ... %g objects selected',length(imapobj_v)),...
			'notbusy','replace');
	end
	set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
	% set(GV_H.text_waitbar,'String','');

catch ME
	errormessage('',ME);
end

