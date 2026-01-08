function testsamples(...
	testsample_no,...
	projectdirectory,...
	par)
% This function creates STL-files of test samples. First a project file has to be loaded.
% testsamples.m uses the same function map2stl.m as for creating the STL-files of a map.
% Syntax:	testsamples(testsample_no);
%				testsample_no=1:		Color samples
%				testsample_no=2:		Text samples
%				testsample_no=3:		Symbol samples
%				testsample_no=4:		Character style samples

global PP GV GV_H VER WAITBAR SY

try
	
	% Display state:
	t_start_statebusy	= clock;
	display_on_gui('state','Creating test sample ...','busy','add');
	
	% Set the value of the cutting lines dropdown menu to 'None' (make the map objects visible):
	set_previewtype_dropdown(1);
	
	% For testing:
	if nargin==0
		% 30 Diamond Painting cup coaster
		% 31 Cross-stitch fabric clamp
		testsample_no		= 31;
		projectdirectory	= 'C:\Daten\Projekte\MapLab3D_Daten\Projects\temp\';
	end
	
	% The test sample number must not exceed the maximum number. If necessary, the maximum number must be increased.
	if testsample_no>GV.testsample_no_max
		errormessage;
	end
	
	% Waitbar:
	msg					= 'Test sample';
	WAITBAR.t1			= clock;										% Time of the last update
	
	%------------------------------------------------------------------------------------------------------------------
	% Assign the project parameters:
	if isempty(PP)
		errortext	= sprintf([...
			'The project parameters have not yet been loaded.\n',...
			'First load the project parameters.']);
		errormessage(errortext);
	else
		PP_ts	= PP;
	end
	PP_ts.general.z_bottom_tilebase		= 999999;
	PP_ts.colorspec(1,1).dxy_overhang	= 0;
	
	% Get the name of the project directory (location of the output files):
	if nargin==1
		projectdirectory	= get_projectdirectory(1,testsample_no);
	end
	
	% If the user clicks Cancel or the window close button (X):
	if isequal(projectdirectory,0)
		display_on_gui('state',...
			sprintf('Creating test sample ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
			'notbusy','replace');
		return
	else
		GV.projectdirectory_ts{testsample_no,1}	= projectdirectory;
	end
	
	
	%------------------------------------------------------------------------------------------------------------
	% Create the test sample:
	% The test sample is created as normal map. All objects to be printed must be polygons.
	% The 'UserData' property of the polygons must contain the following values:
	% 1)	objects of the map (streets, rivers, ...):
	% 		ud_obj.color_no		row-number in PP_ts.color
	% 		ud_obj.dz				vertical height
	% 		ud_obj.prio				priority
	% 		ud_obj.surftype		surface type
	% 2)	boundaries:
	%		ud_tile.tile_no      =-1: Edge of the entire map with the planned maximum dimensions
	%		ud_tile.tile_no      =0:  Edge of the entire map currently to be printed
	%		ud_tile.tile_no      =i:  Edge of the tile i
	% The objects of the map must have the following properties:
	% -	'EdgeAlpha' = GV.visibility.show.edgealpha
	% -	'FaceAlpha' = GV.visibility.show.facealpha
	
	
	% Open a new figure or overwrite the old one:
	map_tag	= sprintf('map2stl_mapfigure_testsample_%1.0f',testsample_no);
	hf_map	= findobj('Tag',map_tag);
	if isempty(hf_map)
		hf_map	= figure;
		figure_theme(hf_map,'set',[],'light');
	end
	hf_map	= hf_map(1);
	figure(hf_map);
	clf(hf_map,'reset');
	figure_theme(hf_map,'set',[],'light');
	set(hf_map,'Tag',map_tag);
	set(hf_map,'Name','Test sample');
	set(hf_map,'NumberTitle','off');
	cameratoolbar(hf_map,'Show');
	ha_map	= axes(hf_map);
	hold(ha_map,'on');
	
	switch testsample_no
		
		
		%------------------------------------------------------------------------------------------------------------
		case 1
			% Color sample:
			
			% Test data (no need to open the project parameters every time):
			testdata	= 0;
			switch testdata
				case 1
					PP_ts.testsample.colorsample.totallength					= 130;
					PP_ts.testsample.colorsample.totalheight					= 2.1;
					PP_ts.testsample.colorsample.letterheight					= 0.75;
					PP_ts.testsample.colorsample.framewidth					= 2;
					PP_ts.testsample.colorsample.distframetext				= 0.5;
					PP_ts.testsample.colorsample.holediameter					= 8;
					PP_ts.testsample.colorsample.widtharoundhole				= 6;
					PP_ts.testsample.colorsample.fontname						= 'Arial black';
					PP_ts.testsample.colorsample.fontsize						= 5;
					PP_ts.testsample.colorsample.fontweight					= 'bold';
					PP_ts.testsample.colorsample.fontwidening					= 0;
					PP_ts.testsample.colorsample.print_res						= 300;
					PP_ts.testsample.colorsample.ln_col_short_text			= 1;
					PP_ts.testsample.colorsample.ln_col_property				= 2;
					PP_ts.testsample.colorsample.ln_col_identification		= 6;
					PP_ts.testsample.colorsample.ln_material					= 1;
					PP_ts.testsample.colorsample.ln_brand						= 3;
					PP_ts.testsample.colorsample.ln_manufacturer				= 4;
					PP_ts.testsample.colorsample.ln_weblink					= 5;
				case 2
					PP_ts.testsample.colorsample.totallength					= 130;
					PP_ts.testsample.colorsample.totalheight					= 2.1;
					PP_ts.testsample.colorsample.letterheight					= 0.75;
					PP_ts.testsample.colorsample.framewidth					= 2;
					PP_ts.testsample.colorsample.distframetext				= 0.5;
					PP_ts.testsample.colorsample.holediameter					= 8;
					PP_ts.testsample.colorsample.widtharoundhole				= 6;
					PP_ts.testsample.colorsample.fontname						= 'Arial black';
					PP_ts.testsample.colorsample.fontsize						= 5;
					PP_ts.testsample.colorsample.fontweight					= 'bold';
					PP_ts.testsample.colorsample.fontwidening					= 0;
					PP_ts.testsample.colorsample.print_res						= 300;
					PP_ts.testsample.colorsample.ln_col_short_text			= 1;
					PP_ts.testsample.colorsample.ln_col_property				= 0;
					PP_ts.testsample.colorsample.ln_col_identification		= 0;
					PP_ts.testsample.colorsample.ln_material					= 1;
					PP_ts.testsample.colorsample.ln_brand						= 0;
					PP_ts.testsample.colorsample.ln_manufacturer				= 0;
					PP_ts.testsample.colorsample.ln_weblink					= 0;
			end
			
			% Prompt for the color number to be printed:
			prompt	= sprintf([...
				'Enter the color number of the testsample to be printed\n',...
				'(a value between 1 and %g)'],size(PP_ts.color,1));
			dlgtitle	= 'Enter color number';
			answer = inputdlg_local(prompt,dlgtitle);
			if isempty(answer)
				display_on_gui('state',...
					sprintf('Creating test sample ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
					'notbusy','replace');
				return
			end
			colno			= round(str2double(answer{1,1}));
			errortext	= sprintf([...
				'Invalid input:\n',...
				'The color number %s is probably not a valid value\n',...
				'or not defined properly in the project file:\n',...
				'%s'],answer{1,1},GV.pp_pathfilename);
			if isempty(colno)
				errormessage(errortext);
			end
			if (colno<1)||(colno>size(PP_ts.color,1))
				errormessage(errortext);
			end
			if isempty(PP_ts.color(colno).prio)||isempty(PP_ts.color(colno).rgb/255)||isempty(PP_ts.color(colno).spec)
				errormessage(errortext);
			end
			
			% Texts:
			weblink		= sprintf('%s',PP_ts.color(colno,1).weblink);	% print only the homepage
			k				= strfind(weblink,'//');
			if ~isempty(k)
				weblink		= weblink((k(1)+2):end);
				k				= strfind(weblink,'/');
				if ~isempty(k)
					weblink		= weblink(1:(k(1)-1));
				end
			end
			text_lino	= {...
				PP_ts.color(colno,1).material						PP_ts.testsample.colorsample.ln_material;...
				PP_ts.color(colno,1).color_short_text			PP_ts.testsample.colorsample.ln_col_short_text;...
				PP_ts.color(colno,1).color_property				PP_ts.testsample.colorsample.ln_col_property;...
				PP_ts.color(colno,1).brand							PP_ts.testsample.colorsample.ln_brand;...
				PP_ts.color(colno,1).manufacturer				PP_ts.testsample.colorsample.ln_manufacturer;...
				weblink													PP_ts.testsample.colorsample.ln_weblink;...
				PP_ts.color(colno,1).color_identification		PP_ts.testsample.colorsample.ln_col_identification};
			lino_max		= max([text_lino{:,2}]);
			text_cell	= cell(lino_max,1);
			for r=1:lino_max
				text_cell{r,1}	= '';
			end
			for r=1:size(text_lino,1)
				text	= text_lino{r,1};
				lino	= text_lino{r,2};
				if lino>0
					if isempty(text_cell{lino,1})
						text_cell{lino,1}	= text;
					else
						text_cell{lino,1}	= [text_cell{lino,1} ' / ' text];
					end
				end
			end
			
			% Dimensions:
			height_mm		= PP_ts.testsample.colorsample.totalheight;
			fontsize_mm		= PP_ts.testsample.colorsample.fontsize;
			framewidth		= PP_ts.testsample.colorsample.framewidth;
			distframetext	= PP_ts.testsample.colorsample.distframetext;
			xmin_mm			= 0;
			xmax_mm			= PP_ts.testsample.colorsample.totallength;
			ymin_mm			= 0;
			ymax_mm			= lino_max*fontsize_mm+2*framewidth+2*distframetext;
			ystart			= ymax_mm-framewidth-distframetext-fontsize_mm/2;
			
			% Outer outline (boundary, "tile base"):
			% ud_tile.tile_no=0:  Edge of the entire map currently to be printed
			r2		= PP_ts.testsample.colorsample.holediameter/2;				% r2 = hole radius
			if r2==0
				% no hole: simple rectangle:
				x		= [xmin_mm;xmin_mm;xmax_mm;xmax_mm];
				y		= [ymin_mm;ymax_mm;ymax_mm;ymin_mm];
				poly_boundary	= polyshape(x,y);
			else
				% Get the outer outline by combining some polygons:
				r1		= r2+PP_ts.testsample.colorsample.widtharoundhole;		% r1 = corner radius
				x		= [xmin_mm+r1;xmin_mm+r1;xmax_mm;xmax_mm];
				y		= [ymin_mm   ;ymax_mm   ;ymax_mm;ymin_mm];
				poly_boundary	= polyshape(x,y);
				if (2*r1)<=ymax_mm
					x		= [xmin_mm;xmin_mm   ;xmax_mm   ;xmax_mm];
					y		= [ymin_mm;ymax_mm-r1;ymax_mm-r1;ymin_mm];
					poly_boundary	= union(polyshape(x,y),poly_boundary);
				else
					x		= [xmin_mm+r1;xmin_mm+r1;xmin_mm+2*r1;xmin_mm+2*r1];
					y		= [ymax_mm   ;ymax_mm-r1;ymax_mm-r1  ;ymax_mm     ];
					poly_boundary	= union(polyshape(x,y),poly_boundary);
				end
				ds		= 0.5;						% mm  distance between vertices of the circle
				dphi	= min(ds/r1,pi/12);		% rad
				dphi	= pi/2/round(pi/2/dphi);
				phi	= 0:dphi:(2*pi-dphi/2);
				poly_boundary	= union(polyshape(r1*cos(phi)+r1,r1*sin(phi)+ymax_mm-r1),poly_boundary);
				dphi	= min(ds/r2,pi/12);
				dphi	= pi/2/round(pi/2/dphi);
				phi	= 0:dphi:(2*pi-dphi/2);
				poly_boundary	= addboundary(polyshape(r2*cos(phi)+r1,r2*sin(phi)+ymax_mm-r1),poly_boundary.Vertices);
			end
			% Plot boundary:
			ud_tile.tile_no	= 0;
			plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
			
			% Inner outline (letter background):
			if ~isempty(text_cell)
				distframehole	= framewidth;
				r3					= r2+distframehole;			% r3 = hole radius + distframehole = radius of the inner outline
				xy_rectframe	= [...
					xmin_mm+framewidth		ymin_mm+framewidth;...
					xmin_mm+framewidth		ymax_mm-framewidth;...
					xmax_mm-framewidth		ymax_mm-framewidth;...
					xmax_mm-framewidth		ymin_mm+framewidth];
				% For a small hole or a large framewidth, the distance between the hole and the inner outline is large.
				% In this case the inner outline will be a simple rectangle.
				% sqrt(2)*(framewidth-r1)	= distance between center of the hole and corner of the inner outline
				if (r2==0)||((sqrt(2)*(framewidth-r1))>r3)
					yu_lim	= 2*ymax_mm;
					poly_bgd	= polyshape(xy_rectframe(:,1),xy_rectframe(:,2));
				else
					yu_lim	= ymax_mm-r1-r2-distframehole-distframetext;
					xy	= [...
						xmin_mm+r1+r2+distframehole	ymax_mm-framewidth;...
						xmax_mm-framewidth				ymax_mm-framewidth;...
						xmax_mm-framewidth				ymin_mm+framewidth;...
						xmin_mm+framewidth				ymin_mm+framewidth;...
						xmin_mm+framewidth				ymax_mm-r1-r2-distframehole;...
						xmin_mm+r1							ymax_mm-r1-r2-distframehole;...
						xmin_mm+r1							ymax_mm-r1;...
						xmin_mm+r1+r2+distframehole	ymax_mm-r1];
					poly_bgd	= polyshape(xy(:,1),xy(:,2));
					dphi		= min(ds/r3,pi/12);
					dphi		= pi/2/round(pi/2/dphi);
					phi		= 0:dphi:(2*pi-dphi/2);
					poly_bgd	= subtract(poly_bgd,polyshape(r3*cos(phi)+r1,r3*sin(phi)+ymax_mm-r1));
					poly_bgd	= intersect(poly_bgd,polyshape(xy_rectframe(:,1),xy_rectframe(:,2)));
				end
				if numboundaries(poly_bgd)==0
					errortext	= sprintf([...
						'There was a problem when creating the color sample.\n',...
						'Please check the project parameters on plausibility:\n',...
						'%s'],GV.pp_pathfilename);
					errormessage(errortext);
				end
				% Plot inner outline (letter background):
				ud_obj.color_no	= 0;
				ud_obj.dz			= -PP_ts.testsample.colorsample.letterheight;
				ud_obj.prio			= 5001;
				ud_obj.surftype	= 200;
				plot(ha_map,poly_bgd,'LineWidth',0.5,'EdgeColor','k','UserData',ud_obj,...
					'EdgeAlpha',GV.visibility.show.edgealpha,...
					'FaceAlpha',GV.visibility.show.facealpha);
				% TFin = isinterior(poly_boundary,poly_bgd.Vertices);
				TFin	= inpolygon(...						% faster than isinterior
					poly_bgd.Vertices(:,1),...				% query points
					poly_bgd.Vertices(:,2),...
					poly_boundary.Vertices(:,1),...		% polygon area
					poly_boundary.Vertices(:,2));
				if any(~TFin&~isnan(poly_bgd.Vertices(:,1))&~isnan(poly_bgd.Vertices(:,2)))
					errortext	= sprintf([...
						'There was a problem when creating the color sample.\n',...
						'Please check the project parameters on plausibility:\n',...
						'%s'],GV.pp_pathfilename);
					errormessage(errortext);
				end
			end
			
			% Plot letters:
			text_namevalue		= {...
				'FontName'           ;PP_ts.testsample.colorsample.fontname;...		% 'Arial', ...
				'FontWeight'         ;PP_ts.testsample.colorsample.fontweight;...		% 'normal', 'bold'
				'HorizontalAlignment';'left';...			% 'left' (default) | 'center' | 'right'
				'VerticalAlignment'  ;'middle';...;		% 'middle' (default) | 'top' | 'bottom' | 'baseline' | 'cap'
				'Interpreter'        ;'none'};
			print_res			= PP_ts.testsample.colorsample.print_res;
			for i=1:size(text_cell,1)
				y	= ystart-(i-1)*fontsize_mm;			% y-position at the middle of the textbox
				yu	= y+fontsize_mm/2;						% y-position at the upper side of the textbox
				if (r2==0)||((sqrt(2)*(framewidth-r1))>r3)||(yu<=yu_lim)
					x	= xmin_mm+0.5+framewidth+distframetext;
				else
					x	= xmin_mm+0.5+r1+r2+distframehole+distframetext;
				end
				if ~isempty(text_cell{i,1})
					[~,poly_obj]=text2poly(...
						x,...										% data point x where to place the text / mm
						y,...										% data point y where to place the text / mm
						text_cell{i,1},...					% text string to convert
						fontsize_mm/10,...					% fontsize / cm
						0,...										% rotation / degrees
						print_res,...							% print resolution / dpi
						1,...										% number: frame around the objects (methods see image2poly.m)
						{},...									% cell array of parameters to create the frame around the object
						1,...										% number: background polygon (methods see image2poly.m)
						{},...									% cell array of parameters to create the background polygon
						text_namevalue);						% cell array of additional name/value-pairs of text properties
					% Font widening:
					if PP_ts.testsample.colorsample.fontwidening~=0
						fontwidening	= max(0,PP_ts.testsample.colorsample.fontwidening);
						poly_obj			= polybuffer(poly_obj,fontwidening/2,'JointType','miter');
					end
					% Plot letters:
					ud_obj.color_no	= 0;
					ud_obj.dz			= 0;
					ud_obj.prio			= 5002;
					ud_obj.surftype	= 300;
					plot(ha_map,poly_obj,'EdgeColor','k','UserData',ud_obj,...
						'EdgeAlpha',GV.visibility.show.edgealpha,...
						'FaceAlpha',GV.visibility.show.facealpha);
					plot(ha_map,poly_obj.Vertices(:,1),poly_obj.Vertices(:,2),'Color','k','LineStyle','none','Marker','.');
					
				end
			end
			
			% File name:
			filename	= sprintf('CoSa %1.0f - %s - %s - %s',...
				colno,PP_ts.color(colno,1).color_short_text,PP_ts.color(colno,1).brand,PP_ts.color(colno,1).material);
			% old:
			% filename	= sprintf('CoSa - C%1.0f - %s - %s - %s',...
			% 	colno,PP_ts.color(colno,1).material,PP_ts.color(colno,1).color_short_text,PP_ts.color(colno,1).brand);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 2
			% Text sample:
			
			% Test data (no need to open the project parameters every time):
			testdata	= 0;
			testplot	= 1;
			switch testdata
				case 1
					testplot	= 1;														%		konst linewidth
					% fontname		= 'Arial black';								%
					% fontname		= 'Arial Rounded MT Bold';					%		x
					% fontname		= 'Bahnschrift SemiBold Condensed';		%		x
					% fontname		= 'Berlin Sans FB Demi';					%
					% fontname		= 'DFGothic-EB';								%
					% fontname		= 'Geometr415 Blk BT';						% +
					% fontname		= 'Geometr706 BlkCn BT';					% +
					% fontname		= 'Haettenschweiler';						%
					% fontname		= 'Humnst777 Blk BT';						% +
					% fontname		= 'Segoe UI Black';							%
					% fontname		= 'Square721 BT';								% +
					% fontname		= 'Square721 Cn BT';							%
					% fontname		= 'Swis721 Blk BT';							% +
					% fontname		= 'Swis721 BlkCn BT';						% +
					% fontname		= 'Swis721 Hv BT';							% +
					% fontname		= 'TechnicBold'								%		x
					% fontname		= 'Tw Cen MT Condensed Extra Bold';		% +
					% fontname		= 'Verdana Pro Black';						% +
					% fontname		= 'Verdana Pro Cond Semibold';			%
					% fontname		= 'Verdana Pro Semibold';					% +
					% fontname		= 'Verdana Pro Black';						% ++
					% fontname		= 'Harlow Solid Italic';					% +			Schmuckschrift
					PP_ts.testsample.textsample.sampletext					= 'Aj!%®';
					PP_ts.testsample.textsample.totalheight				= 2.1;
					PP_ts.testsample.textsample.letterheight				= 0.75;
					PP_ts.testsample.textsample.framewidth					= 2;
					PP_ts.testsample.textsample.distframetext				= 1;
					PP_ts.testsample.textsample.disttexttext_h			= 3;
					PP_ts.testsample.textsample.disttexttext_v			= 0.5;
					PP_ts.testsample.textsample.legend_fontname			= 'Arial black';
					PP_ts.testsample.textsample.legend_fontsize			= 5;
					PP_ts.testsample.textsample.legend_fontweight		= 'bold';
					PP_ts.testsample.textsample.legend_fontwidening		= 0;
					PP_ts.testsample.textsample.fontname					= 'Arial';		% Arial, Arial black
					PP_ts.testsample.textsample.fontweight					= 'bold';				% normal, bold
					PP_ts.testsample.textsample.fontangle					= 'normal';				% normal, italic
					
					% Simple Tfb Schriftart
					
					PP_ts.testsample.textsample.fontsize_start			= 2.5;	% 2.5
					PP_ts.testsample.textsample.fontsize_step				= 0.5;	% 0.5
					PP_ts.testsample.textsample.fontsize_end				= 7;		% 7
					PP_ts.testsample.textsample.fontwidening_start		= 0.0;	% 0
					PP_ts.testsample.textsample.fontwidening_step		= 0.1;	% 0.1
					PP_ts.testsample.textsample.fontwidening_end			= 0.6;	% 0.6
					
					% 				PP_ts.testsample.textsample.fontsize_start			= 8;		% 2.5
					% 				PP_ts.testsample.textsample.fontsize_step				= 1;		% 0.5
					% 				PP_ts.testsample.textsample.fontsize_end				= 13;		% 7
					% 				PP_ts.testsample.textsample.fontwidening_start		= 0.0;	% 0
					% 				PP_ts.testsample.textsample.fontwidening_step		= 0.25;	% 0.1
					% 				PP_ts.testsample.textsample.fontwidening_end			= 0.75;	% 0.6
					
					% 				PP_ts.testsample.textsample.fontsize_v	= '2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 8 9 10 12 14';
					% 				. durch , ersetzen
					% 				',' oder ';' durch ' ' ersetzen
					
					PP_ts.testsample.textsample.print_res					= 300;	% 0.6
			end
			
			% Initializations:
			height_mm	= PP_ts.testsample.textsample.totalheight;
			fontsize_v	= (...
				PP_ts.testsample.textsample.fontsize_start:...
				PP_ts.testsample.textsample.fontsize_step:...
				PP_ts.testsample.textsample.fontsize_end)';
			fontwidening_v	= (...
				PP_ts.testsample.textsample.fontwidening_start:...
				PP_ts.testsample.textsample.fontwidening_step:...
				PP_ts.testsample.textsample.fontwidening_end)';
			text_namevalue		= {...
				'FontName'           ;PP_ts.testsample.textsample.fontname;...
				'HorizontalAlignment';'left';...			% 'left' (default) | 'center' | 'right'
				'VerticalAlignment'  ;'baseline';...	% 'middle' (default) | 'top' | 'bottom' | 'baseline' | 'cap'
				'Interpreter'        ;'none'};
			text_namevalue{end+1,1}	= 'FontWeight';
			if ~isempty(PP_ts.testsample.textsample.fontweight)
				text_namevalue{end+1,1}	= PP_ts.testsample.textsample.fontweight;
			else
				text_namevalue{end+1,1}	= 'normal';
			end
			text_namevalue{end+1,1}	= 'FontAngle';
			if ~isempty(PP_ts.testsample.textsample.fontangle)
				text_namevalue{end+1,1}	= PP_ts.testsample.textsample.fontangle;
			else
				text_namevalue{end+1,1}	= 'normal';
			end
			text_namevalue_legend		= {...
				'FontName'           ;PP_ts.testsample.textsample.legend_fontname;...
				'FontWeight'         ;PP_ts.testsample.textsample.legend_fontweight;...
				'FontAngle'          ;'normal';...		% normal, italic
				'HorizontalAlignment';'left';...			% 'left' (default) | 'center' | 'right'
				'VerticalAlignment'  ;'baseline';...	% 'middle' (default) | 'top' | 'bottom' | 'baseline' | 'cap'
				'Interpreter'        ;'none'};
			
			% Legend:
			text_cell			= {...
				'Name:' PP_ts.testsample.textsample.fontname};
			if ~isempty(PP_ts.testsample.textsample.fontweight)
				text_cell{end+1,1}	= 'Weight:';
				text_cell{end  ,2}	= PP_ts.testsample.textsample.fontweight;
			end
			if ~isempty(PP_ts.testsample.textsample.fontangle)
				text_cell{end+1,1}	= 'Angle:';
				text_cell{end  ,2}	= PP_ts.testsample.textsample.fontangle;
			end
			if ~isempty(PP_ts.testsample.textsample.print_settings)
				text_cell{end+1,1}	= 'Settings:';
				text_cell{end  ,2}	= PP_ts.testsample.textsample.print_settings;
			end
			text_cell{end+1,1}		= 'Size:';
			if length(fontsize_v)==1
				text_cell{end  ,2}		= sprintf('%g',fontsize_v);
			else
				text_cell{end  ,2}		= sprintf('%g..%g',fontsize_v(1),fontsize_v(end));
			end
			text_cell{end+1,1}			= 'Widening:';
			if length(fontwidening_v)==1
				text_cell{end  ,2}		= sprintf('%g',fontwidening_v);
			else
				text_cell{end  ,2}		= sprintf('%g..%g',fontwidening_v(1),fontwidening_v(end));
			end
			poly_legend			= polyshape();
			legend_fontsize	= PP_ts.testsample.textsample.legend_fontsize;
			print_res			= PP_ts.testsample.textsample.print_res;
			imax_legend			= size(text_cell,1)*size(text_cell,2);
			for r=1:size(text_cell,1)
				for c=1:size(text_cell,2)
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						WAITBAR.t1	= clock;
						set(GV_H.text_waitbar,'String',sprintf('%s: converting legend texts to polygons %g/%g',...
							msg,(r-1)*size(text_cell,2)+c,imax_legend));
						drawnow;
					end
					% Legend polygon:
					[~,poly_legend(r,c)]=text2poly(...
						0,...										% data point x where to place the text / mm
						0,...										% data point y where to place the text / mm
						text_cell{r,c},...					% text string to convert
						legend_fontsize/10,...				% fontsize / cm
						0,...										% rotation / degrees
						print_res,...							% print resolution / dpi
						1,...										% number: frame around the objects (methods see image2poly.m)
						{},...									% cell array of parameters to create the frame around the object
						1,...										% number: background polygon (methods see image2poly.m)
						{},...									% cell array of parameters to create the background polygon
						text_namevalue_legend);						% cell array of additional name/value-pairs of text properties
					% Font widening:
					if PP_ts.testsample.textsample.legend_fontwidening~=0
						fontwidening			= max(0,PP_ts.testsample.textsample.legend_fontwidening);
						poly_legend(r,c)		= polybuffer(poly_legend(r,c),fontwidening/2,'JointType','miter');
					end
				end
			end
			
			% Texts:
			poly_text	= polyshape();
			rmax			= (size(fontsize_v,1)+1);
			cmax			= (size(fontwidening_v,1)+1);
			imax_texts	= rmax*cmax;
			for r=1:rmax
				i_fs		= r-1;
				for c=1:cmax
					i_fw		= c-1;
					
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						WAITBAR.t1	= clock;
						set(GV_H.text_waitbar,'String',sprintf('%s: converting sample texts to polygons %g/%g',...
							msg,(r-1)*cmax+c,imax_texts));
						drawnow;
					end
					
					% font widening legend:
					if (r==1)&&(i_fw>=1)
						% Legend polygon:
						[~,poly_text(r,c)]=text2poly(...
							0,...											% data point x where to place the text / mm
							0,...											% data point y where to place the text / mm
							num2str(fontwidening_v(i_fw)),...	% text string to convert
							legend_fontsize/10,...					% fontsize / cm
							0,...											% rotation / degrees
							print_res,...								% print resolution / dpi
							1,...											% number: frame around the objects (methods see image2poly.m)
							{},...										% cell array of parameters to create the frame around the object
							1,...											% number: background polygon (methods see image2poly.m)
							{},...										% cell array of parameters to create the background polygon
							text_namevalue_legend);					% cell array of additional name/value-pairs of text properties
						% Font widening:
						if PP_ts.testsample.textsample.legend_fontwidening~=0
							fontwidening		= max(0,PP_ts.testsample.textsample.legend_fontwidening);
							poly_text(r,c)		= polybuffer(poly_text(r,c),fontwidening/2,'JointType','miter');
						end
					end
					
					% font size legend:
					if (c==1)&&(i_fs>=1)
						% Legend polygon:
						[~,poly_text(r,c)]=text2poly(...
							0,...											% data point x where to place the text / mm
							0,...											% data point y where to place the text / mm
							num2str(fontsize_v(i_fs)),...			% text string to convert
							legend_fontsize/10,...					% fontsize / cm
							0,...											% rotation / degrees
							print_res,...								% print resolution / dpi
							1,...											% number: frame around the objects (methods see image2poly.m)
							{},...										% cell array of parameters to create the frame around the object
							1,...											% number: background polygon (methods see image2poly.m)
							{},...										% cell array of parameters to create the background polygon
							text_namevalue_legend);					% cell array of additional name/value-pairs of text properties
						% Font widening:
						if PP_ts.testsample.textsample.legend_fontwidening~=0
							fontwidening		= max(0,PP_ts.testsample.textsample.legend_fontwidening);
							poly_text(r,c)		= polybuffer(poly_text(r,c),fontwidening/2,'JointType','miter');
						end
					end
					
					% Sampletext:
					if (i_fs>=1)&&(i_fw>=1)
						% Sampletext polygon:
						sampletext	= PP_ts.testsample.textsample.sampletext;
						[~,poly_text(r,c)]=text2poly(...
							0,...											% data point x where to place the text / mm
							0,...											% data point y where to place the text / mm
							sampletext,...								% text string to convert
							fontsize_v(i_fs)/10,...					% fontsize / cm
							0,...											% rotation / degrees
							print_res,...								% print resolution / dpi
							1,...											% number: frame around the objects (methods see image2poly.m)
							{},...										% cell array of parameters to create the frame around the object
							1,...											% number: background polygon (methods see image2poly.m)
							{},...										% cell array of parameters to create the background polygon
							text_namevalue);							% cell array of additional name/value-pairs of text properties
						% Font widening:
						if fontwidening_v(i_fw)~=0
							fontwidening		= max(0,fontwidening_v(i_fw));
							poly_text(r,c)		= polybuffer(poly_text(r,c),fontwidening/2,'JointType','miter');
						end
					end
					
				end
			end
			
			% Plot poly_text:
			% Height of all rows:
			ymin_text_v		= zeros(size(poly_legend,1),1);
			ymax_text_v		= zeros(size(poly_legend,1),1);
			for r=1:size(poly_text,1)
				ymin_text_v(r,1)	= 1e6;
				ymax_text_v(r,1)	= 1e-6;
				for c=1:size(poly_text,2)
					if ~isempty(poly_text(r,c).Vertices)
						ymin_text_v(r,1)	= min(ymin_text_v(r,1),min(poly_text(r,c).Vertices(:,2)));
						ymax_text_v(r,1)	= max(ymax_text_v(r,1),max(poly_text(r,c).Vertices(:,2)));
					end
				end
			end
			% Width of all columns:
			w_col_text_v		= zeros(size(poly_text,2),1);
			for c=1:size(poly_text,2)
				xmin_text	= 1e6;
				xmax_text	= 1e-6;
				for r=1:size(poly_text,1)
					if ~isempty(poly_text(r,c).Vertices)
						xmin_text	= min(xmin_text,min(poly_text(r,c).Vertices(:,1)));
						xmax_text	= max(xmax_text,max(poly_text(r,c).Vertices(:,1)));
					end
				end
				w_col_text_v(c,1)	= xmax_text-xmin_text;
			end
			% Add poly_text to poly:
			if testplot~=0
				baselines_y_v	= zeros(0,1);
			end
			xmax_ts	= 1e-6;
			poly	= polyshape();
			xoff	= PP_ts.testsample.textsample.framewidth+PP_ts.testsample.textsample.distframetext;
			yoff	= PP_ts.testsample.textsample.framewidth+PP_ts.testsample.textsample.distframetext;
			rmax	= size(poly_text,1);
			cmax	= size(poly_text,2);
			for r=rmax:-1:1
				if testplot~=0
					baselines_y_v	= [baselines_y_v;yoff];
				end
				yoff	= yoff-ymin_text_v(r);
				xcoff		= xoff;
				for c=1:cmax
					if ~isempty(poly_text(r,c).Vertices)
						% Waitbar:
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',sprintf('%s: combining sample text polygons %g/%g',...
								msg,(rmax-r)*cmax+c,rmax*cmax));
							drawnow;
						end
						poly	= union(poly,translate(poly_text(r,c),...
							xcoff-min(poly_text(r,c).Vertices(:,1)),...
							yoff));
					end
					xmax_ts		= max(xmax_ts,xcoff+w_col_text_v(c,1));
					xcoff		= xcoff+w_col_text_v(c,1)+PP_ts.testsample.textsample.disttexttext_h;
				end
				yoff	= yoff+ymax_text_v(r)+PP_ts.testsample.textsample.disttexttext_v;
			end
			yoff	= yoff+PP_ts.testsample.textsample.disttexttext_v*2;
			
			% Plot poly_legend:
			% Height of all rows:
			ymin_leg		= 1e6;
			ymax_leg		= 1e-6;
			for r=1:size(poly_legend,1)
				for c=1:size(poly_legend,2)
					if ~isempty(poly_legend(r,c).Vertices)
						ymin_leg	= min(ymin_leg,min(poly_legend(r,c).Vertices(:,2)));
						ymax_leg	= max(ymax_leg,max(poly_legend(r,c).Vertices(:,2)));
					end
				end
			end
			% Width of all columns:
			w_col_leg_v		= zeros(size(poly_legend,2),1);
			for c=1:size(poly_legend,2)
				xmin_text	= 1e6;
				xmax_text	= 1e-6;
				for r=1:size(poly_legend,1)
					if ~isempty(poly_legend(r,c).Vertices)
						xmin_text	= min(xmin_text,min(poly_legend(r,c).Vertices(:,1)));
						xmax_text	= max(xmax_text,max(poly_legend(r,c).Vertices(:,1)));
					end
				end
				w_col_leg_v(c,1)	= xmax_text-xmin_text;
			end
			% Add poly_legend to poly:
			rmax	= size(poly_legend,1);
			cmax	= size(poly_legend,2);
			for r=rmax:-1:1
				if testplot~=0
					baselines_y_v	= [baselines_y_v;yoff];
				end
				yoff	= yoff-ymin_leg;
				xcoff		= xoff;
				for c=1:cmax
					if ~isempty(poly_legend(r,c).Vertices)
						% Waitbar:
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',sprintf('%s: combining legend text polygons %g/%g',...
								msg,(rmax-r)*cmax+c,rmax*cmax));
							drawnow;
						end
						poly	= union(poly,translate(poly_legend(r,c),...
							xcoff-min(poly_legend(r,c).Vertices(:,1)),...
							yoff));
					end
					xmax_ts		= max(xmax_ts,xcoff+w_col_leg_v(c,1));
					xcoff		= xcoff+w_col_leg_v(c,1)+PP_ts.testsample.textsample.disttexttext_h;
				end
				yoff	= yoff+ymax_leg+PP_ts.testsample.textsample.disttexttext_v;
			end
			xmax_ts	= xmax_ts+PP_ts.testsample.textsample.distframetext;
			ymax_ts	= yoff+PP_ts.testsample.textsample.distframetext-PP_ts.testsample.textsample.disttexttext_v;
			
			% Plot boundary:
			fw	= PP_ts.testsample.textsample.framewidth;
			xmin_mm			= 0;
			xmax_mm			= xmax_ts+fw;
			ymin_mm			= 0;
			ymax_mm			= ymax_ts+fw;
			poly_boundary	= polyshape(...
				[xmin_mm xmax_mm xmax_mm xmin_mm],...
				[ymin_mm ymin_mm ymax_mm ymax_mm]);
			ud_tile.tile_no	= 0;
			plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
			
			% Plot inner outline (letter background):
			poly_bgd	= polyshape(...
				[fw xmax_ts xmax_ts fw     ],...
				[fw fw      ymax_ts ymax_ts]);
			ud_obj.color_no	= 0;
			ud_obj.dz			= -PP_ts.testsample.colorsample.letterheight;
			ud_obj.prio			= 5001;
			ud_obj.surftype	= 200;
			plot(ha_map,poly_bgd,'LineWidth',0.5,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			
			% Plot letters:
			ud_obj.color_no	= 0;
			ud_obj.dz			= 0;
			ud_obj.prio			= 5002;
			ud_obj.surftype	= 300;
			plot(ha_map,poly,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			plot(ha_map,poly.Vertices(:,1),poly.Vertices(:,2),'Color','k','LineStyle','none','Marker','.');
			
			% File name:
			fontsize_start			= sprintf('%g',PP_ts.testsample.textsample.fontsize_start);
			fontsize_step			= sprintf('%g',PP_ts.testsample.textsample.fontsize_step);
			fontsize_end			= sprintf('%g',PP_ts.testsample.textsample.fontsize_end);
			fontwidening_start	= sprintf('%g',PP_ts.testsample.textsample.fontwidening_start);
			fontwidening_step		= sprintf('%g',PP_ts.testsample.textsample.fontwidening_step);
			fontwidening_end		= sprintf('%g',PP_ts.testsample.textsample.fontwidening_end);
			fontsize_start(strfind(fontsize_start,'.'))				= 'p';
			fontsize_step(strfind(fontsize_step,'.'))					= 'p';
			fontsize_end(strfind(fontsize_end,'.'))					= 'p';
			fontwidening_start(strfind(fontwidening_start,'.'))	= 'p';
			fontwidening_step(strfind(fontwidening_step,'.'))		= 'p';
			fontwidening_end(strfind(fontwidening_end,'.'))			= 'p';
			if ~isempty(PP_ts.testsample.textsample.fontweight)
				filename_fontweight	= sprintf('%s - ',PP_ts.testsample.textsample.fontweight);
			else
				filename_fontweight	= '';
			end
			if ~isempty(PP_ts.testsample.textsample.fontangle)
				filename_fontangle	=  sprintf('%s - ',PP_ts.testsample.textsample.fontangle);
			else
				filename_fontangle	= '';
			end
			filename	= sprintf('TxtSa - %s%s%s - FS %s %s %s - FW %s %s %s',...
				PP_ts.testsample.textsample.fontname,...
				filename_fontweight,...
				filename_fontangle,...
				fontsize_start,...
				fontsize_step,...
				fontsize_end,...
				fontwidening_start,...
				fontwidening_step,...
				fontwidening_end);
			
			if testplot~=0
				for i=1:size(baselines_y_v,1)
					plot(ha_map,[fw xmax_ts],baselines_y_v(i)*[1 1],'-r')
				end
				% return
			end
			
			
			%------------------------------------------------------------------------------------------------------------
		case 3
			% Symbol sample:
			
			if isempty(SY)
				errortext	= sprintf([...
					'There exist no symbols.\n',...
					'First load the symbols.']);
				errormessage(errortext);
			end
			
			% Prompt for the symbol numbers to be printed:
			GV_H.create_symbolsample_getuserinput	= [];
			create_symbolsample_getuserinput;
			% Polling:
			pause(0.1);
			while isempty(GV_H.create_symbolsample_getuserinput)
				pause(0.1);
			end
			while isvalid(GV_H.create_symbolsample_getuserinput)
				pause(0.1);
			end
			if ~GV.create_symsamp.input_ok
				display_on_gui('state',...
					sprintf('Creating test sample ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
					'notbusy','replace');
				set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
				set(GV_H.text_waitbar,'String','');
				return
			end
			symb_no_v			= GV.create_symsamp.Symbols_ListBox.ValueIndex;
			scaleup_factor		= GV.create_symsamp.ScaleUpFactor_EditField.Value;
			dz_symbol			= GV.create_symsamp.LiftingForeground_EditField.Value;
			dz_bgd				= GV.create_symsamp.LiftingBackground_EditField.Value;
			distmarginsymbol	= GV.create_symsamp.DistanceMarginSymbol_EditField.Value;
			height_mm			= GV.create_symsamp.TotalSymbolHeight_EditField.Value-max(dz_symbol,dz_bgd);
			
			% Collect all texts (symbol numbers) and symbols:
			poly_bgd_v		= polyshape();
			poly_sym_v		= polyshape();
			poly_txt_v		= polyshape();
			wsymb				= 0;
			hsyte_v			= zeros(length(symb_no_v),1);
			xlim_bgd_v		= zeros(length(symb_no_v),2);
			ylim_bgd_v		= zeros(length(symb_no_v),2);
			xlim_sym_v		= zeros(length(symb_no_v),2);
			ylim_sym_v		= zeros(length(symb_no_v),2);
			ylim_txt_v		= zeros(length(symb_no_v),2);
			xlim_txt_v		= zeros(length(symb_no_v),2);
			fontsize_mm		= PP_ts.testsample.symbolsample.legend_fontsize;
			print_res		= PP_ts.testsample.symbolsample.print_res;
			letterheight	= PP_ts.testsample.symbolsample.legend_letterheight;
			for ksym=1:length(symb_no_v)
				symb_no		= symb_no_v(ksym);
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					WAITBAR.t1	= clock;
					set(GV_H.text_waitbar,'String',sprintf('%s: convert texts to polygons %g/%g',...
						msg,ksym,length(symb_no_v)));
					drawnow;
				end
				
				% Get sybmols and scale-up:
				poly_bgd_v(ksym,1)				= SY(symb_no,1).poly_bgd;
				poly_sym_v(ksym,1)				= SY(symb_no,1).poly_sym;
				if scaleup_factor~=1
					poly_bgd_v(ksym,1)			= scale(poly_bgd_v(ksym,1),scaleup_factor);
					poly_sym_v(ksym,1)			= scale(poly_sym_v(ksym,1),scaleup_factor);
				end
				
				% Get texts (symbol numbers):
				text_namevalue		= {...
					'FontName'           ;PP_ts.testsample.symbolsample.legend_fontname;...		% 'Arial', ...
					'FontWeight'         ;PP_ts.testsample.symbolsample.legend_fontweight;...	% 'normal', 'bold'
					'HorizontalAlignment';'right';...		% 'left' (default) | 'center' | 'right'
					'VerticalAlignment'  ;'middle';...;		% 'middle' (default) | 'top' | 'bottom' | 'baseline' | 'cap'
					'Interpreter'        ;'none'};
				[~,poly_txt_v(ksym,1)]=text2poly(...
					0,...										% data point x where to place the text / mm
					0,...										% data point y where to place the text / mm
					num2str(symb_no),...					% text string to convert
					fontsize_mm/10,...					% fontsize / cm
					0,...										% rotation / degrees
					print_res,...							% print resolution / dpi
					1,...										% number: frame around the objects (methods see image2poly.m)
					{},...									% cell array of parameters to create the frame around the object
					1,...										% number: background polygon (methods see image2poly.m)
					{},...									% cell array of parameters to create the background polygon
					text_namevalue);						% cell array of additional name/value-pairs of text properties
				if PP_ts.testsample.symbolsample.legend_fontwidening~=0
					fontwidening	= max(0,PP_ts.testsample.symbolsample.legend_fontwidening);
					poly_txt_v(ksym,1)			= polybuffer(poly_txt_v(ksym,1),fontwidening/2,'JointType','miter');
				end
				
				% Row and column widths of texts and symbols:
				[xlim_bgd_v(ksym,:),ylim_bgd_v(ksym,:)]	= boundingbox(poly_bgd_v(ksym,1));
				[xlim_sym_v(ksym,:),ylim_sym_v(ksym,:)]	= boundingbox(poly_sym_v(ksym,1));
				[xlim_txt_v(ksym,:),ylim_txt_v(ksym,:)]	= boundingbox(poly_txt_v(ksym,1));
				wsymb													= max(wsymb,...
					max(xlim_bgd_v(ksym,2),xlim_sym_v(ksym,2))-...
					min(xlim_bgd_v(ksym,1),xlim_sym_v(ksym,1))    );
				hsyte_v(ksym,1)									= max(hsyte_v(ksym,1),...
					max(ylim_bgd_v(ksym,2),ylim_sym_v(ksym,2))-...
					min(ylim_bgd_v(ksym,1),ylim_sym_v(ksym,1))    );
				hsyte_v(ksym,1)									= max(hsyte_v(ksym,1),diff(ylim_txt_v(ksym,:)));
				
			end
			
			% Waitbar
			set(GV_H.text_waitbar,'String',sprintf('%s: create STL files',msg));
			drawnow;
			
			% Combine the texts and symbols:
			poly_bgd		= polyshape();
			poly_sym				= polyshape();
			poly_txt			= polyshape();
			x_text			= 0;
			x_symb			= distmarginsymbol+wsymb/2;
			y_syte			= -hsyte_v(1,1)/2;
			for ksym=1:length(symb_no_v)
				% Centering of the symbol:
				x_tr			= -(min(xlim_bgd_v(ksym,1),xlim_sym_v(ksym,1))+max(xlim_bgd_v(ksym,2),xlim_sym_v(ksym,2)))/2;
				y_tr			= -(min(ylim_bgd_v(ksym,1),ylim_sym_v(ksym,1))+max(ylim_bgd_v(ksym,2),ylim_sym_v(ksym,2)))/2;
				poly_bgd_v(ksym,1) = translate(poly_bgd_v(ksym,1),x_tr,y_tr);
				poly_sym_v(ksym,1) = translate(poly_sym_v(ksym,1),x_tr,y_tr);
				% Centering of the text:
				x_tr			= -xlim_txt_v(ksym,2);
				y_tr			= -(ylim_txt_v(ksym,1)+ylim_txt_v(ksym,2))/2;
				poly_txt_v(ksym,1) = translate(poly_txt_v(ksym,1),x_tr,y_tr);
				% Combine all polygons:
				poly_bgd		= union(poly_bgd,translate(poly_bgd_v(ksym,1),x_symb,y_syte));
				poly_sym		= union(poly_sym,translate(poly_sym_v(ksym,1),x_symb,y_syte));
				poly_txt		= union(poly_txt,translate(poly_txt_v(ksym,1),x_text,y_syte));
				% Next line:
				if ksym<length(symb_no_v)
					y_syte	= y_syte-hsyte_v(ksym,1)/2-distmarginsymbol-hsyte_v(ksym+1,1)/2;
				end
			end
			
			% Plot boundary:
			poly_all			= union(poly_bgd,poly_sym);
			poly_all			= union(poly_all,poly_txt);
			[xlim,ylim]		= boundingbox(poly_all);
			xmin_mm			= xlim(1)-distmarginsymbol;
			xmax_mm			= xlim(2)+distmarginsymbol;
			ymin_mm			= ylim(1)-distmarginsymbol;
			ymax_mm			= ylim(2)+distmarginsymbol;
			poly_boundary	= polyshape(...
				[xmin_mm xmax_mm xmax_mm xmin_mm],...
				[ymin_mm ymin_mm ymax_mm ymax_mm]);
			ud_tile.tile_no	= 0;
			plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
			
			% Plot background:
			ud_obj.color_no	= 0;
			ud_obj.dz			= dz_bgd;
			ud_obj.prio			= 5001;
			ud_obj.surftype	= 400;
			plot(ha_map,poly_bgd,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			plot(ha_map,poly_bgd.Vertices(:,1),poly_bgd.Vertices(:,2),'Color','k','LineStyle','none','Marker','.');
			
			% Plot symbols:
			ud_obj.color_no	= 0;
			ud_obj.dz			= dz_symbol;
			ud_obj.prio			= 5002;
			ud_obj.surftype	= 402;
			plot(ha_map,poly_sym,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			plot(ha_map,poly_sym.Vertices(:,1),poly_sym.Vertices(:,2),'Color','k','LineStyle','none','Marker','.');
			
			% Plot texts (symbol numbers):
			ud_obj.color_no	= 0;
			ud_obj.dz			= letterheight;
			ud_obj.prio			= 5003;
			ud_obj.surftype	= 402;
			plot(ha_map,poly_txt,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			plot(ha_map,poly_txt.Vertices(:,1),poly_txt.Vertices(:,2),'Color','k','LineStyle','none','Marker','.');
			
			% Filename:
			if isscalar(symb_no_v)
				symb_no_str				= sprintf('%g',symb_no_v);
				scaleup_factor_str	= sprintf('%g',symb_no_v);
			else
				symb_no_str				= sprintf('%g-%g',min(symb_no_v),max(symb_no_v));
				scaleup_factor_str	= sprintf('%g-%g',min(symb_no_v),max(symb_no_v));
			end
			symb_no_str(strfind(symb_no_str,'.'))						= 'p';
			scaleup_factor_str(strfind(scaleup_factor_str,'.'))	= 'p';
			filename	= sprintf('SySa - No %s - SF %s',symb_no_str,scaleup_factor_str);
			
			
		case 4
			% Character style sample:
			
			% Prompt for the character style numbers to be printed:
			GV_H.create_charstylesample_getuserinput	= [];
			create_charstylesample_getuserinput;
			% Polling:
			pause(0.1);
			while isempty(GV_H.create_charstylesample_getuserinput)
				pause(0.1);
			end
			while isvalid(GV_H.create_charstylesample_getuserinput)
				pause(0.1);
			end
			if ~GV.create_charstylesamp.input_ok
				display_on_gui('state',...
					sprintf('Creating test sample ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
					'notbusy','replace');
				set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
				set(GV_H.text_waitbar,'String','');
				return
			end
			chst_no_v			= GV.create_charstylesamp.CharStyles_ListBox.ValueIndex;
			dz_symbol			= GV.create_charstylesamp.LiftingForeground_EditField.Value;
			dz_bgd				= GV.create_charstylesamp.LiftingBackground_EditField.Value;
			distmargintext		= GV.create_charstylesamp.DistanceMarginText_EditField.Value;
			height_mm			= GV.create_charstylesamp.TotalTextHeight_EditField.Value-max(dz_symbol,dz_bgd);
			
			% Collect all texts (character style numbers) and sampletexts:
			poly_bgd_v		= polyshape();
			poly_sat_v		= polyshape();
			poly_txt_v		= polyshape();
			wsat_v			= zeros(length(chst_no_v),1);
			hsat_v			= zeros(length(chst_no_v),1);
			xlim_bgd_v		= zeros(length(chst_no_v),2);
			ylim_bgd_v		= zeros(length(chst_no_v),2);
			xlim_sat_v		= zeros(length(chst_no_v),2);
			ylim_sat_v		= zeros(length(chst_no_v),2);
			ylim_txt_v		= zeros(length(chst_no_v),2);
			xlim_txt_v		= zeros(length(chst_no_v),2);
			fontsize_mm		= PP_ts.testsample.charstylesample.legend_fontsize;
			print_res		= PP_ts.testsample.charstylesample.print_res;
			letterheight	= PP_ts.testsample.charstylesample.legend_letterheight;
			for kchst=1:length(chst_no_v)
				chstno		= chst_no_v(kchst);
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					WAITBAR.t1	= clock;
					set(GV_H.text_waitbar,'String',sprintf('%s: convert texts to polygons %g/%g',...
						msg,kchst,length(chst_no_v)));
					drawnow;
				end
				
				% Get sampletexts:
				% Upper and lower case:
				switch PP.charstyle(chstno,1).upperlowercase
					case 'upper'
						sampletext	= upper(GV.create_charstylesamp.SampleText_EditField.Value);
					case 'lower'
						sampletext	= lower(GV.create_charstylesamp.SampleText_EditField.Value);
					otherwise
						sampletext	= GV.create_charstylesamp.SampleText_EditField.Value;
				end
				% Character spacing:
				character_spacing	= max(0,round(PP.charstyle(chstno,1).character_spacing));
				if character_spacing>0
					text_str	= sampletext;
					kmax		= length(text_str);
					if kmax>=2
						k	= 1:kmax;
						k1	= (character_spacing+1)*k-character_spacing;
						sampletext		= blanks(k1(end));
						sampletext(k1)	= text_str;
					end
				end
				% Other settings:
				text_namevalue		= {...
					'FontName'           ;PP.charstyle(chstno,1).fontname;...
					'FontWeight'         ;PP.charstyle(chstno,1).fontweight;...
					'FontAngle'          ;PP.charstyle(chstno,1).fontangle;...
					'HorizontalAlignment';'left';...										% left, center, right
					'VerticalAlignment'  ;'middle';...									% middle, top, bottom, baseline, cap
					'Interpreter'        ;'none'};
				% Convert to polygons:
				[  poly_bgd_v(kchst,1),...								% poly_bgd
					poly_sat_v(kchst,1)...								% poly_obj
					]=text2poly(...
					0,...														% x
					0,...														% y
					sampletext,...											% text_str
					PP.charstyle(chstno,1).fontsize/10,...			% fontsize_cm
					0,...														% rotation
					PP.charstyle(chstno,1).print_res,...			% print_res
					PP.charstyle(chstno,1).no_frame,...				% no_frame
					PP.charstyle(chstno,1).par_frame,...			% par_frame
					PP.charstyle(chstno,1).no_bgd,...				% no_bgd
					PP.charstyle(chstno,1).par_bgd,...				% par_bgd
					text_namevalue);										% text_namevalue
				% Font widening:
				if PP.charstyle(chstno,1).fontwidening~=0
					fontwidening			= max(0,PP.charstyle(chstno,1).fontwidening);
					poly_sat_v(kchst,1)	= polybuffer(poly_sat_v(kchst,1),fontwidening/2,'JointType','miter');
					poly_bgd_v(kchst,1)	= union(poly_bgd_v(kchst,1),poly_sat_v(kchst,1));
				end
				% The text foreground must be inside the text background (less problems in map2stl.m):
				poly_bgd_buff	= polybuffer(poly_bgd_v(kchst,1),-GV.d_forebackgrd_plotobj,'JointType','miter','MiterLimit',2);
				poly_sat_v(kchst,1)	= intersect(poly_sat_v(kchst,1),poly_bgd_buff,'KeepCollinearPoints',false);
				
				% Get character style numbers:
				text_namevalue		= {...
					'FontName'           ;PP_ts.testsample.charstylesample.legend_fontname;...		% 'Arial', ...
					'FontWeight'         ;PP_ts.testsample.charstylesample.legend_fontweight;...	% 'normal', 'bold'
					'HorizontalAlignment';'right';...		% 'left' (default) | 'center' | 'right'
					'VerticalAlignment'  ;'middle';...;		% 'middle' (default) | 'top' | 'bottom' | 'baseline' | 'cap'
					'Interpreter'        ;'none'};
				[~,poly_txt_v(kchst,1)]=text2poly(...
					0,...										% data point x where to place the text / mm
					0,...										% data point y where to place the text / mm
					num2str(chstno),...					% text string to convert
					fontsize_mm/10,...					% fontsize / cm
					0,...										% rotation / degrees
					print_res,...							% print resolution / dpi
					1,...										% number: frame around the objects (methods see image2poly.m)
					{},...									% cell array of parameters to create the frame around the object
					1,...										% number: background polygon (methods see image2poly.m)
					{},...									% cell array of parameters to create the background polygon
					text_namevalue);						% cell array of additional name/value-pairs of text properties
				if PP_ts.testsample.charstylesample.legend_fontwidening~=0
					fontwidening	= max(0,PP_ts.testsample.charstylesample.legend_fontwidening);
					poly_txt_v(kchst,1)			= polybuffer(poly_txt_v(kchst,1),fontwidening/2,'JointType','miter');
				end
				
				% Row and column widths of character style numbers and sampletexts:
				[xlim_bgd_v(kchst,:),ylim_bgd_v(kchst,:)]	= boundingbox(poly_bgd_v(kchst,1));
				[xlim_sat_v(kchst,:),ylim_sat_v(kchst,:)]	= boundingbox(poly_sat_v(kchst,1));
				[xlim_txt_v(kchst,:),ylim_txt_v(kchst,:)]	= boundingbox(poly_txt_v(kchst,1));
				wsat_v(kchst,1)									= ...
					max(xlim_bgd_v(kchst,2),xlim_sat_v(kchst,2))-...
					min(xlim_bgd_v(kchst,1),xlim_sat_v(kchst,1));
				hsat_v(kchst,1)									= ...
					max(ylim_bgd_v(kchst,2),ylim_sat_v(kchst,2))-...
					min(ylim_bgd_v(kchst,1),ylim_sat_v(kchst,1));
				hsat_v(kchst,1)									= max(hsat_v(kchst,1),diff(ylim_txt_v(kchst,:)));
				
			end
			
			% Waitbar
			set(GV_H.text_waitbar,'String',sprintf('%s: create STL files',msg));
			drawnow;
			
			% Combine the texts and symbols:
			poly_bgd				= polyshape();
			poly_sat				= polyshape();
			poly_txt				= polyshape();
			poly_boundary		= polyshape();
			y_txtsat				= -hsat_v(1,1)/2;
			xmin_boundary_mm	= 1e10;
			for kchst=1:length(chst_no_v)
				% Left-Alignement of the sampletext:
				x_tr					= -min(xlim_bgd_v(kchst,1),xlim_sat_v(kchst,1));
				y_tr					= -(min(ylim_bgd_v(kchst,1),ylim_sat_v(kchst,1))+max(ylim_bgd_v(kchst,2),ylim_sat_v(kchst,2)))/2;
				poly_bgd_v(kchst,1) = translate(poly_bgd_v(kchst,1),x_tr+distmargintext,y_tr+y_txtsat);
				poly_sat_v(kchst,1) = translate(poly_sat_v(kchst,1),x_tr+distmargintext,y_tr+y_txtsat);
				% Right-Alignement of the text:
				x_tr					= -xlim_txt_v(kchst,2);
				y_tr					= -(ylim_txt_v(kchst,1)+ylim_txt_v(kchst,2))/2;
				poly_txt_v(kchst,1) = translate(poly_txt_v(kchst,1),x_tr,y_tr+y_txtsat);
				% Combine all polygons:
				poly_bgd				= union(poly_bgd,poly_bgd_v(kchst,1));
				poly_sat				= union(poly_sat,poly_sat_v(kchst,1));
				poly_txt				= union(poly_txt,poly_txt_v(kchst,1));
				% Next line:
				if kchst<length(chst_no_v)
					y_txtsat			= y_txtsat-hsat_v(kchst,1)/2-distmargintext-hsat_v(kchst+1,1)/2;
				end
				% Boundary:
				[xlim,~]			= boundingbox(poly_txt_v(kchst,1));
				xmin_boundary_mm	= min(xmin_boundary_mm,xlim(1)-distmargintext);
			end
			
			% Boundary:
			for kchst=1:length(chst_no_v)
				poly_all			= union(poly_bgd_v(kchst,1),poly_sat_v(kchst,1));
				poly_all			= union(poly_all,poly_txt_v(kchst,1));
				[xlim,ylim]		= boundingbox(poly_all);
				xmin_mm			= xmin_boundary_mm;		% xlim(1)-distmargintext
				xmax_mm			= xlim(2)+distmargintext;
				ymin_mm			= ylim(1)-distmargintext;
				ymax_mm			= ylim(2)+distmargintext;
				poly_boundary	= union(poly_boundary,polyshape(...
					[xmin_mm xmax_mm xmax_mm xmin_mm],...
					[ymin_mm ymin_mm ymax_mm ymax_mm]));
			end
			
			% Plot boundary:
			ud_tile.tile_no	= 0;
			plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
			
			% Plot background:
			ud_obj.color_no	= 0;
			ud_obj.dz			= dz_bgd;
			ud_obj.prio			= 5001;
			ud_obj.surftype	= 400;
			plot(ha_map,poly_bgd,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			plot(ha_map,poly_bgd.Vertices(:,1),poly_bgd.Vertices(:,2),'Color','k','LineStyle','none','Marker','.');
			
			% Plot symbols:
			ud_obj.color_no	= 0;
			ud_obj.dz			= dz_symbol;
			ud_obj.prio			= 5002;
			ud_obj.surftype	= 402;
			plot(ha_map,poly_sat,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			plot(ha_map,poly_sat.Vertices(:,1),poly_sat.Vertices(:,2),'Color','k','LineStyle','none','Marker','.');
			
			% Plot texts (symbol numbers):
			ud_obj.color_no	= 0;
			ud_obj.dz			= letterheight;
			ud_obj.prio			= 5003;
			ud_obj.surftype	= 402;
			plot(ha_map,poly_txt,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			plot(ha_map,poly_txt.Vertices(:,1),poly_txt.Vertices(:,2),'Color','k','LineStyle','none','Marker','.');
			
			% Filename:
			if isscalar(chst_no_v)
				symb_no_str				= sprintf('%g',chst_no_v);
			else
				symb_no_str				= sprintf('%g-%g',min(chst_no_v),max(chst_no_v));
			end
			symb_no_str(strfind(symb_no_str,'.'))						= 'p';
			filename	= sprintf('ChStSa - No %s',symb_no_str);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 11
			% Stringing:
			% !!! under construction !!!
			
			% Abkürzungen: Druckereinstellulngen - Einzug
			% L		Länge				(auch wenn keine Angabe)
			% ZH		Z Hebung
			% NZA		Nur Z anheben
			% EG		Einzugsgeschwindigkeit
			% WEG		Wiedereinzugsgeschwindigkeit
			% ELBN	Extra Länge bei Neustart
			% MNE		Minimalbewegung nach Einziehen
			% BSE		Bei Schichtwechsel einziehen
			% WER		Während Einzug reinigen
			% EVER	Einzugslänge vor einer Reinigung
			filament_str			= 'Ampertec PLA';		% should be also a valid variablename and filename
			settings_cell{1,1}	= '200°C/L2,0mm';	% should be also a valid variablename and filename
			settings_cell{2,1}	= 'EG65mm/s';	% should be also a valid variablename and filename
			%  		settings_cell{3,1}	= '200°C/L2,0mm';	% should be also a valid variablename and filename
			%  		settings_cell{4,1}	= '200°C/L2,0mm';	% should be also a valid variablename and filename
			%  		settings_cell{5,1}	= '200°C/L2,0mm';	% should be also a valid variablename and filename
			fontsize_cm				= 0.5;			% Schrifthöhe
			lw_border				= 0.8;			% Linien zur Versteifung
			% ebene Fläche:
			xmin_mm			= 0;						% Grenzen der Topographiedaten
			xmax_mm			= 50;
			ymin_mm			= 0;
			ymax_mm			= 10+size(settings_cell,1)*fontsize_cm*10;
			height_mm		= 0.6;
			
			% Boundary:
			% ud_tile.tile_no=0:  Edge of the entire map currently to be printed
			x	= [xmin_mm;xmin_mm;xmax_mm;xmax_mm];
			y	= [ymin_mm;ymax_mm;ymax_mm;ymin_mm];
			poly_boundary	= polyshape(x,y);
			ud_tile.tile_no	= 0;
			plot(ha_map,poly_boundary,'LineWidth',2,'EdgeColor','m','FaceAlpha',0,'UserData',ud_tile);
			
			% Linien zur Versteifung:
			dz						= 0.6;
			x	= [xmin_mm;xmax_mm];
			y	= [1;1]*lw_border/2;
			poly		= line2poly(x,y,{lw_border,12});
			y	= ymax_mm-5+[1;1]*lw_border/2;
			poly		= union(poly,line2poly(x,y,{lw_border,12}));
			y	= ymax_mm-[1;1]*lw_border/2;
			poly		= union(poly,line2poly(x,y,{lw_border,12}));
			x	= [1;1]*lw_border/2;
			y	= [ymin_mm,ymax_mm];
			poly		= union(poly,line2poly(x,y,{lw_border,12}));
			x	= xmax_mm-[1;1]*lw_border/2;
			poly		= union(poly,line2poly(x,y,{lw_border,12}));
			ud_obj.color_no	= 0;
			ud_obj.dz			= dz;
			ud_obj.prio			= 5000;
			ud_obj.surftype	= 100;
			plot(ha_map,poly,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			
			% Towers:
			height				= 10;
			y_towers				= size(settings_cell,1)*fontsize_cm*10+7.5;
			n						= 6;
			distance_start_mm	= 1.5;
			distance_end_mm	= 9;
			width_start_mm		= 1;
			width_end_mm		= 3.5;
			xb_im1				= [];
			for i=1:n
				distance_mm	= distance_start_mm+(i-1)/(n-1)*(distance_end_mm-distance_start_mm);
				width_mm		= width_start_mm   +(i-1)/(n-1)*(width_end_mm   -width_start_mm);
				x				= [-1;1;1;-1]*width_mm/2;
				y				= [-1;-1;1;1]*width_mm/2;
				poly			= polyshape(x,y);
				poly			= rotate(poly,45);
				[xlim,ylim] = boundingbox(poly);
				if i==1
					xb_im1		= xlim(2);
					poly			= translate(poly,xlim(2),y_towers);
					poly_towers	= poly;
				elseif i==n
					poly			= translate(poly,xb_im1+distance_mm+xlim(2),y_towers);
					poly_towers	= union(poly,poly_towers);
					x				= [xb_im1+distance_mm+xlim(2);xmax_mm;xmax_mm;xb_im1+distance_mm+xlim(2)];
					y				= [ylim(1);ylim(1);ylim(2);ylim(2)]+y_towers;
					poly_towers	= union(poly_towers,polyshape(x,y));
				else
					poly			= translate(poly,xb_im1+distance_mm+xlim(2),y_towers);
					poly_towers	= union(poly,poly_towers);
					xb_im1		= xb_im1+distance_mm+(xlim(2)-xlim(1));
				end
			end
			ud_obj.color_no	= 0;
			ud_obj.dz			= height;
			ud_obj.prio			= 5001;
			ud_obj.surftype	= 200;
			plot(ha_map,poly_towers,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			
			% Texte:
			fontname		= 'Arial black';
			fontweight	= 'bold';				% 'normal', 'bold'
			text_namevalue			= {...
				'FontName';fontname;...
				'FontWeight';fontweight;...
				'HorizontalAlignment';'center';...			% 'left' (default) | 'center' | 'right'
				'VerticalAlignment';'baseline';...;			% 'middle' (default) | 'top' | 'bottom' | 'baseline' | 'cap'
				'Interpreter';'none'};
			text_cell{1,1}	= filament_str;
			for i=1:size(settings_cell,1)
				text_cell{end+1,1}	= settings_cell{i};
			end
			dz					= 0.6;
			dy_text_margin	= 0.8;
			dy					= ((1+size(settings_cell,1))*5-lw_border-2*dy_text_margin)/(1+size(settings_cell,1));
			% 		dy					= fontsize_cm*10;
			ystart			= dy_text_margin+1.5;
			for i=1:size(text_cell,1)
				if ~isempty(text_cell{i,1})
					[~,poly_obj]=text2poly(...
						(xmax_mm+xmin_mm)/2,...						% data point x where to place the text / mm
						ystart+(i-1)*dy,...							% data point y where to place the text / mm
						text_cell{i,1},...							% text string to convert
						fontsize_cm,...								% fontsize / cm
						0,...												% rotation / degrees
						300,...											% print resolution / dpi
						1,...												% number: frame around the objects (methods see image2poly.m)
						{},...											% cell array of parameters to create the frame around the object
						1,...												% number: background polygon (methods see image2poly.m)
						{},...											% cell array of parameters to create the background polygon
						text_namevalue);								% cell array of additional name/value-pairs of text properties
					ud_obj.color_no	= 0;
					ud_obj.dz			= dz;
					ud_obj.prio			= 5002;
					ud_obj.surftype	= 300;
					plot(ha_map,poly_obj,'EdgeColor','k','UserData',ud_obj,...
						'EdgeAlpha',GV.visibility.show.edgealpha,...
						'FaceAlpha',GV.visibility.show.facealpha);
					plot(ha_map,poly_obj.Vertices(:,1),poly_obj.Vertices(:,2),'Color','k','LineStyle','none','Marker','.');
				end
			end
			
			% Dateiname
			filename	= sprintf('Stringing - %s',filament_str);
			for i=1:size(settings_cell,1)
				filename	= sprintf('%s - %s',filename,settings_cell{i});
			end
			
			
			%------------------------------------------------------------------------------------------------------------
		case 12			% Testteile:
			% !!! under construction !!!
			
			xmin_mm			= 0;
			xmax_mm			= 60;
			ymin_mm			= 0;
			ymax_mm			= 40;
			
			
			%------------------------------------------------------------------------------------------------------------
		case 13
			% minimale Strichbreite
			% !!! under construction !!!
			
			dz_text		= 0.75;
			dz_dreieck	= 3;
			a				= 9;						% edge length of one test object
			lw_v			= [(0.3:0.05:0.6)';0.7;0.8;0.9;1;1.2;1.4];	%
			spacing		= 3;
			n_lw			= length(lw_v);
			y_text		= 3;
			y1				= 2*y_text;
			y2				= y1+2*sqrt(2)*spacing;
			y3				= y2+a+spacing;
			
			xmin_mm		= 0;
			xmax_mm		= n_lw*(a+2*spacing);
			ymin_mm		= 0;
			ymax_mm		= y3;
			
			PP_ts.general.minbottomwidth_obj					= 0;
			PP_ts.general.sticks_strips_removal.mindiag	= 0;
			PP_ts.general.sticks_strips_removal.minarea	= 0;
			PP_ts.general.sticks_strips_removal.minwidth	= 0;
			
			
			
			% ebene Fläche:
			height_mm	= 0.9;
			
			% Text-settings:
			text_namevalue			= {...
				'FontName';'Arial black';...
				'FontWeight';'bold';...
				'HorizontalAlignment';'center';...			% 'left' (default) | 'center' | 'right'
				'VerticalAlignment';'middle';...;			% 'middle' (default) | 'top' | 'bottom' | 'baseline' | 'cap'
				'Interpreter';'none'};
			
			% Boundary:
			% ud_tile.tile_no=0:  Edge of the entire map currently to be printed
			x	= [xmin_mm;xmax_mm;xmax_mm;xmin_mm];
			y	= [ymin_mm;ymin_mm;ymax_mm;ymax_mm];
			poly_boundary	= polyshape(x,y);
			ud_tile.tile_no	= 0;
			plot(ha_map,poly_boundary,'LineWidth',2,'EdgeColor','m','FaceAlpha',0,'UserData',ud_tile);
			
			% Texte:
			for i=1:size(lw_v,1)
				x0			= (i-0.5)*(a+2*spacing);
				[poly_bgd,poly_obj]=text2poly(...
					x0,...												% data point x where to place the text / mm
					y_text,...										% data point y where to place the text / mm
					sprintf('%1.0f',(lw_v(i,1)*100)),...					% text string to convert
					0.5,...											% fontsize / cm
					0,...												% rotation / degrees
					300,...											% print resolution / dpi
					1,...												% number: frame around the objects (methods see image2poly.m)
					{},...											% cell array of parameters to create the frame around the object
					1,...												% number: background polygon (methods see image2poly.m)
					{},...											% cell array of parameters to create the background polygon
					text_namevalue);								% cell array of additional name/value-pairs of text properties
				ud_obj.color_no	= 0;
				ud_obj.dz			= dz_text;
				ud_obj.prio			= 5000;
				ud_obj.surftype	= 300;
				plot(ha_map,poly_obj,'EdgeColor','k','UserData',ud_obj,...
					'EdgeAlpha',GV.visibility.show.edgealpha,...
					'FaceAlpha',GV.visibility.show.facealpha);
				plot(ha_map,poly_obj.Vertices(:,1),poly_obj.Vertices(:,2),'Color','k','LineStyle','none','Marker','.');
				
				% unteres Dreieck:
				poly	= line2poly(...
					[x0 x0+a/2 x0-a/2 x0-a/2 x0],...
					[y1 y1     y1+a   y1     y1],{lw_v(i,1);6});
				ud_obj.color_no	= 0;
				ud_obj.dz			= dz_dreieck;
				ud_obj.prio			= 5011;
				ud_obj.surftype	= 200;
				plot(ha_map,poly,'EdgeColor','k','UserData',ud_obj,...
					'EdgeAlpha',GV.visibility.show.edgealpha,...
					'FaceAlpha',GV.visibility.show.facealpha);
				% unterer Kreis:
				phi	= (0:5:360)*pi/180;
				x		= cos(phi);
				y		= sin(phi);
				xc		= x0-a/2+a/(2+sqrt(2));
				yc		= y1    +a/(2+sqrt(2));
				poly	= polyshape(xc+lw_v(i,1)/2*x,yc+lw_v(i,1)/2*y);
				ud_obj.color_no	= 0;
				ud_obj.dz			= dz_dreieck;
				ud_obj.prio			= 5012;
				ud_obj.surftype	= 200;
				plot(ha_map,poly,'EdgeColor','k','UserData',ud_obj,...
					'EdgeAlpha',GV.visibility.show.edgealpha,...
					'FaceAlpha',GV.visibility.show.facealpha);
				
				
				% Erhöhung oberes Dreieck:
				s		= spacing;
				s2s	= sqrt(2)*s;
				poly	= polyshape(...
					[x0   x0-a/2-s x0-a/2-s   x0+a/2+s x0+a/2+s x0  ],...
					[y3   y3       y3-s2s     y1-s+s2s y3       y3  ]);
				ud_obj.color_no	= 0;
				ud_obj.dz			= dz_dreieck;
				ud_obj.prio			= 5001;
				ud_obj.surftype	= 200;
				plot(ha_map,poly,'EdgeColor','k','UserData',ud_obj,...
					'EdgeAlpha',GV.visibility.show.edgealpha,...
					'FaceAlpha',GV.visibility.show.facealpha);
				% oberes Dreieck:
				poly	= line2poly(...
					[x0   x0-a/2 x0+a/2 x0+a/2 x0  ],...
					[y2+a y2+a   y2     y2+a   y2+a],{lw_v(i,1);6});
				ud_obj.color_no	= 0;
				ud_obj.dz			= 0;
				ud_obj.prio			= 5021;
				ud_obj.surftype	= 200;
				plot(ha_map,poly,'EdgeColor','k','UserData',ud_obj,...
					'EdgeAlpha',GV.visibility.show.edgealpha,...
					'FaceAlpha',GV.visibility.show.facealpha);
				% oberer Kreis:
				xc		= x0+a/2-a/(2+sqrt(2));
				yc		= y2+a  -a/(2+sqrt(2));
				poly	= polyshape(xc+lw_v(i,1)/2*x,yc+lw_v(i,1)/2*y);
				ud_obj.color_no	= 0;
				ud_obj.dz			= 0;
				ud_obj.prio			= 5022;
				ud_obj.surftype	= 200;
				plot(ha_map,poly,'EdgeColor','k','UserData',ud_obj,...
					'EdgeAlpha',GV.visibility.show.edgealpha,...
					'FaceAlpha',GV.visibility.show.facealpha);
				
				
				
				
			end
			
			% Dateiname
			filename	='LineWidths 1';
			
			
			
			%------------------------------------------------------------------------------------------------------------
		case {15,16,17,18,19}
			% Card index box DIN A8:
			% https://www.printables.com/model/1313184-index-card-box-din-a8-with-register
			% Syntax:
			% projectdirectory='C:\Daten\Projekte\MapLab3D_Daten\Projects\temp\';
			% testsamples(15,projectdirectory,[]);
			% testsamples(16,projectdirectory,[]);
			% testsamples(17,projectdirectory,[]);
			% for i=65:96,testsamples(18,projectdirectory,i);end
			% for i=94:96,testsamples(19,projectdirectory,i);end
			
			PP_ts.general.save_filename.zcenter	= 0;
			PP_ts.general.save_filename.zmin		= 0;
			% Top, bottom:
			tol	= 0.2;						% gap widths										conditions:
			th		= 4;							% wand thickness of bottom and top
			hb		= 37;							% inner bottom height
			ht		= 30;							% inner top height								hb+ht > indh+indhlf
			hp		= 5;							% pedestal height
			iw		= 79;							% inner width										DIN A8: 52mm x 74mm
			th2a	= 1.5;						% thickness pedestal bottom part
			th2b	= th2a-tol;					% thickness pedestal top part
			% Spacer, slots:
			spth	= 2.4;						% spacer thickness
			sw		= spth+tol;					% slot_width
			sd		= 1.5;						% slot depth
			ss		= 45;							% distance betwee slots
			sn		= 3;							% no of slots
			% Index sheets:
			indw		= 76;						% width												indw < iw
			indh		= 53;						% height												DIN A8: 52mm x 74mm
			indno		= 6;						% no of letter fields
			indth		= 0.6;					% thickness
			indwlf	= indw/indno;			% width letter field
			indhlf	= 11;						% height letter field
			
			one_slot_poly	= polyshape(...
				[-iw/2-sd -iw/2+1 -iw/2+1 -iw/2-sd nan iw/2-1 iw/2+sd iw/2+sd iw/2-1],...
				[ss       ss      ss+sw   ss+sw    nan ss     ss      ss+sw   ss+sw ]);
			one_slot_poly_transl		= one_slot_poly;
			slot_poly					= one_slot_poly;
			for i=1:(sn-1)
				one_slot_poly_transl = translate(one_slot_poly_transl,0,ss+sw);
				slot_poly				= union(slot_poly,one_slot_poly_transl);
			end
			[~,ylim]			= boundingbox(slot_poly);
			ymin_i			= ylim(1)-ss;
			ymax_i			= ylim(2)+ss;
			xmin_i			= -iw/2;
			xmax_i			= iw/2;
			poly_i			= polyshape([xmin_i xmax_i xmax_i xmin_i],[ymin_i ymin_i ymax_i ymax_i]);
			poly_boundary1	= polybuffer(poly_i,th);
			poly_1			= addboundary(poly_boundary1,poly_i.Vertices);
			% testsample_no==15: bottom
			poly_1s			= subtract(poly_1,slot_poly);
			poly_2a			= polybuffer(poly_i,th-th2a);
			poly_2a			= addboundary(poly_boundary1,poly_2a.Vertices);
			% testsample_no==16: top
			poly_2b			= polybuffer(poly_i,th-th2b);
			poly_2b			= addboundary(poly_boundary1,poly_2b.Vertices);
			% testsample_no=17: spacer:
			poly_3			= polyshape(...
				[-iw/2-sd+tol iw/2+sd-tol iw/2+sd-tol -iw/2-sd+tol],...
				[0            0           hb          hb          ]);
			% testsample_no=18: index sheet:
			poly_4			= polyshape(...
				[0 indw indw 0   ],...
				[0 0    indh indh]);
			for i=1:indno
				poly_5(i,1)	= polyshape(...
					[(i-1)*indwlf  i*indwlf  i*indwlf  i*indwlf-2   (i-1)*indwlf+2  (i-1)*indwlf],...
					[indh-1        indh-1    indh      indh+indhlf  indh+indhlf     indh        ]);
				poly_5(i,1)	= union(poly_5(i,1),poly_4);
			end
			for i=1:indno/2
				poly_6(i,1)	= polyshape(...
					[(i-1)*indwlf  i*indwlf  i*indwlf  i*indwlf-2   (i-1)*indwlf+2  (i-1)*indwlf]*2,...
					[indh-1        indh-1    indh      indh+indhlf  indh+indhlf     indh        ]);
				poly_6(i,1)	= union(poly_6(i,1),poly_4);
			end
			
			if testsample_no==15			% bottom
				height_mm			= th;
				poly_boundary	= poly_boundary1;
				% Plot boundary:
				ud_tile.tile_no	= 0;
				plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
				% Plot wall:
				ud_obj.color_no	= 0;
				ud_obj.dz			= hb;
				ud_obj.prio			= 5001;
				ud_obj.surftype	= 200;
				plot(ha_map,poly_1s,'LineWidth',0.5,'EdgeColor','k','UserData',ud_obj,...
					'EdgeAlpha',GV.visibility.show.edgealpha,...
					'FaceAlpha',GV.visibility.show.facealpha);
				% Plot pedestal:
				ud_obj.color_no	= 0;
				ud_obj.dz			= hb-hp;
				ud_obj.prio			= 5002;
				ud_obj.surftype	= 200;
				plot(ha_map,poly_2a,'LineWidth',0.5,'EdgeColor','k','UserData',ud_obj,...
					'EdgeAlpha',GV.visibility.show.edgealpha,...
					'FaceAlpha',GV.visibility.show.facealpha);
				% File name:
				filename	= sprintf('CIB Bottom');
			elseif testsample_no==16		% top
				height_mm			= th;
				poly_boundary		= poly_boundary1;
				% Plot boundary:
				ud_tile.tile_no	= 0;
				plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
				% Plot wall:
				ud_obj.color_no	= 0;
				ud_obj.dz			= ht;
				ud_obj.prio			= 5001;
				ud_obj.surftype	= 200;
				plot(ha_map,poly_1,'LineWidth',0.5,'EdgeColor','k','UserData',ud_obj,...
					'EdgeAlpha',GV.visibility.show.edgealpha,...
					'FaceAlpha',GV.visibility.show.facealpha);
				% Plot pedestal:
				ud_obj.color_no	= 0;
				ud_obj.dz			= ht+hp;
				ud_obj.prio			= 5002;
				ud_obj.surftype	= 200;
				plot(ha_map,poly_2b,'LineWidth',0.5,'EdgeColor','k','UserData',ud_obj,...
					'EdgeAlpha',GV.visibility.show.edgealpha,...
					'FaceAlpha',GV.visibility.show.facealpha);
				% File name:
				filename	= sprintf('CIB-Top');
			elseif testsample_no==17		% spacer
				height_mm			= spth;
				poly_boundary		= poly_3;
				% Plot boundary:
				ud_tile.tile_no	= 0;
				plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
				% File name:
				filename	= sprintf('CIB Spacer');
			elseif testsample_no==18		% index sheet
				height_mm			= indth;
				% par=65: 'A'
				% par=90: 'Z'
				i		= mod(par-65,indno)+1;
				poly_boundary	= poly_5(i,1);
				% Plot boundary:
				ud_tile.tile_no	= 0;
				plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
				% Plot text:
				if par<=90
					par_str				= char(par);
					text_namevalue		= {...
						'FontName'           ;'Arial black';...	% 'Arial', ...
						'FontWeight'         ;'bold';...				% 'normal', 'bold'
						'HorizontalAlignment';'center';...		% 'left' (default) | 'center' | 'right'
						'VerticalAlignment'  ;'middle';...;		% 'middle' (default) | 'top' | 'bottom' | 'baseline' | 'cap'
						'Interpreter'        ;'none'};
					[~,poly_txt]=text2poly(...
						(i-0.5)*indwlf,...							% data point x where to place the text / mm
						indh+5.5,...							% data point y where to place the text / mm
						par_str,...								% text string to convert
						0.7,...									% fontsize / cm
						0,...										% rotation / degrees
						300,...									% print resolution / dpi
						1,...										% number: frame around the objects (methods see image2poly.m)
						{},...									% cell array of parameters to create the frame around the object
						1,...										% number: background polygon (methods see image2poly.m)
						{},...									% cell array of parameters to create the background polygon
						text_namevalue);						% cell array of additional name/value-pairs of text properties
					ud_obj.color_no	= 0;
					ud_obj.dz			= 0.6;
					ud_obj.prio			= 5003;
					ud_obj.surftype	= 302;
					plot(ha_map,poly_txt,'EdgeColor','k','UserData',ud_obj,...
						'EdgeAlpha',GV.visibility.show.edgealpha,...
						'FaceAlpha',GV.visibility.show.facealpha);
					plot(ha_map,poly_txt.Vertices(:,1),poly_txt.Vertices(:,2),'Color','k','LineStyle','none','Marker','.')
				else
					% par=91..96
					par_str				= num2str(par-88);
				end
			elseif testsample_no==19		% index sheet
				height_mm			= indth;
				% par=65: 'A'
				% par=90: 'Z'
				i		= mod(par-65,indno/2)+1;
				poly_boundary	= poly_6(i,1);
				% Plot boundary:
				ud_tile.tile_no	= 0;
				plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
				% Plot text:
				if par<=90
					par_str				= char(par);
					text_namevalue		= {...
						'FontName'           ;'Arial black';...	% 'Arial', ...
						'FontWeight'         ;'bold';...				% 'normal', 'bold'
						'HorizontalAlignment';'center';...		% 'left' (default) | 'center' | 'right'
						'VerticalAlignment'  ;'middle';...;		% 'middle' (default) | 'top' | 'bottom' | 'baseline' | 'cap'
						'Interpreter'        ;'none'};
					[~,poly_txt]=text2poly(...
						(i-0.5)*indwlf,...							% data point x where to place the text / mm
						indh+5.5,...							% data point y where to place the text / mm
						par_str,...								% text string to convert
						0.7,...									% fontsize / cm
						0,...										% rotation / degrees
						300,...									% print resolution / dpi
						1,...										% number: frame around the objects (methods see image2poly.m)
						{},...									% cell array of parameters to create the frame around the object
						1,...										% number: background polygon (methods see image2poly.m)
						{},...									% cell array of parameters to create the background polygon
						text_namevalue);						% cell array of additional name/value-pairs of text properties
					ud_obj.color_no	= 0;
					ud_obj.dz			= 0.6;
					ud_obj.prio			= 5003;
					ud_obj.surftype	= 302;
					plot(ha_map,poly_txt,'EdgeColor','k','UserData',ud_obj,...
						'EdgeAlpha',GV.visibility.show.edgealpha,...
						'FaceAlpha',GV.visibility.show.facealpha);
					plot(ha_map,poly_txt.Vertices(:,1),poly_txt.Vertices(:,2),'Color','k','LineStyle','none','Marker','.')
				else
					% par=91..96
					par_str				= num2str(par-88);
				end
				% File name:
				filename	= sprintf('CIB Index %s',par_str);
			end
			[xlim,ylim] = boundingbox(poly_boundary1);
			xmin_mm		= xlim(1,1);
			xmax_mm		= xlim(1,2);
			ymin_mm		= ylim(1,1);
			ymax_mm		= ylim(1,2);
			width			= xmax_mm-xmin_mm
			height		= ymax_mm-ymin_mm
			
			
			
			
			
			
			
			%------------------------------------------------------------------------------------------------------------
		case 30
			% Diamond Painting Cup Coaster
			
			height_mm			= 5;			% margin height
			h_innergrid			= 0.6;		% inner height
			h_innerlevel		= 1.0;		% inner height
			w_margin				= 2;			% width margin
			d						= 93.0;			% outer diameter		93: 933 pixel  /
			%	di+w_margin		pixel
			%	92.4				917
			%	92.5				917
			%	92.6				917
			%	92.7				933
			%	92.8				933
			%	92.9				933
			%	93.0				933
			%	93.1				933
			%	93.2				933
			g						= 0.3;		% gap width
			a						= 2.5;		% size of one diamond (height 1.2mm)
			
			poly_5x5				= polyshape(...
				[0  1  1  0]*5*a,...
				[0  0  1  1]*5*a);
			poly_5x5
			poly_5x5				= polybuffer(poly_5x5,g/2);
			poly_5x5				= addboundary(polybuffer(poly_5x5,-g),poly_5x5.Vertices);
			poly_5x5_all		= polyshape();
			rcmax					= ceil((d/2)/(5*a)+1);
			for r=-rcmax:rcmax
				for c=-rcmax:rcmax
					poly_5x5_all	= union(poly_5x5_all,translate(poly_5x5,[r c]*5*a-2.5*a));
				end
			end
			
			sidelength			= 1;
			n_sides				= ceil(2*pi*d/2/sidelength);
			dphi					= 2*pi/n_sides;
			phi_v					= 0:dphi:(2*pi-dphi/2);
			xy_c					= d/2*exp(1i*phi_v);
			poly_margin_outer	= polyshape(real(xy_c),imag(xy_c));
			poly_margin_inner	= polybuffer(poly_margin_outer,-w_margin);
			poly_margin			= poly_margin_outer;
			poly_margin			= addboundary(poly_margin,poly_margin_inner.Vertices);
			
			poly_margin_outer_ext	= polybuffer(poly_margin_outer,10*d);
			poly_margin_outer_ext	= addboundary(poly_margin_outer_ext,poly_margin_inner.Vertices);
			poly_grid					= subtract(poly_5x5_all,poly_margin_outer_ext);
			
			poly_1x1				= polyshape(...
				[0  1  1  0]*a,...
				[0  0  1  1]*a);
			poly_1x1_all		= polyshape();
			rcmax					= ceil((d/2)/a+1);
			n_pixel				= 0;
			for r=-rcmax:rcmax
				for c=-rcmax:rcmax
					poly_1x1_trans	= translate(poly_1x1,[r c]*a-0.5*a);
					if overlaps(poly_1x1_trans,poly_margin_outer_ext)
						poly_1x1_all	= union(poly_1x1_all,poly_1x1_trans);
					else
						n_pixel			= n_pixel+1;
					end
				end
			end
			n_pixel
			poly_1x1_all		= subtract(poly_1x1_all,poly_margin_outer_ext);
			
			% Plot boundary:
			ud_tile.tile_no	= 0;
			poly_boundary		= poly_margin_outer;
			plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
			% Plot inner level:
			ud_obj.color_no	= 0;
			ud_obj.dz			= -(height_mm-h_innerlevel);
			ud_obj.prio			= 5001;
			ud_obj.surftype	= 200;
			plot(ha_map,poly_margin_outer,'LineWidth',0.5,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			% Plot grid:
			ud_obj.color_no	= 0;
			ud_obj.dz			= -(height_mm-h_innergrid);
			ud_obj.prio			= 5002;
			ud_obj.surftype	= 200;
			plot(ha_map,poly_grid,'LineWidth',0.5,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			% Plot grid:
			ud_obj.color_no	= 0;
			ud_obj.dz			= -(height_mm-h_innergrid);
			ud_obj.prio			= 5003;
			ud_obj.surftype	= 200;
			plot(ha_map,poly_1x1_all,'LineWidth',0.5,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			% Plot margin:
			ud_obj.color_no	= 0;
			ud_obj.dz			= 0;
			ud_obj.prio			= 5004;
			ud_obj.surftype	= 200;
			plot(ha_map,poly_margin,'LineWidth',0.5,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			% File name:
			filename	= sprintf('Diamond Painting Cup Coaster');
			
			[xlim,ylim] = boundingbox(poly_margin_outer);
			xmin_mm		= xlim(1,1);
			xmax_mm		= xlim(1,2);
			ymin_mm		= ylim(1,1);
			ymax_mm		= ylim(1,2);
			width			= xmax_mm-xmin_mm
			height		= ymax_mm-ymin_mm
			
			
			%------------------------------------------------------------------------------------------------------------
		case 31
			% Cross-stitch fabric clamp
			muster	= 4;
			switch muster
				case 1
					height_mm			= 30;			% clamp height / mm
					ds						= 0.5;		% distance of vertices / mm
					alpha_deg			= 250;		% angle / degrees						250		/ 260 / 270
					w						= 2.0;		% material width / mm				>=2.0 bei d_circle_slots=0.9 und 2 Perimeter
					d_handles			= 3;			% diameter of the handles / mm
					d_inner				= 20;		% inner diameter / mm					20.5		/ 19.5 / 20
					d_circle_slots		= 0.9;
				case 2
					height_mm			= 30;			% clamp height / mm
					ds						= 0.5;		% distance of vertices / mm
					alpha_deg			= 250;		% angle / degrees						250		/ 260 / 270
					w						= 2.0;		% material width / mm				>=2.0 bei d_circle_slots=0.9 und 2 Perimeter
					d_handles			= 3;			% diameter of the handles / mm
					d_inner				= 19.2;		% inner diameter / mm					20.5		/ 19.5 / 20
					d_circle_slots		= 0.9;
				case 3
					height_mm			= 100;		% clamp height / mm
					ds						= 0.5;		% distance of vertices / mm
					alpha_deg			= 250;		% angle / degrees						250		/ 260 / 270
					w						= 2.0;		% material width / mm				>=2.0 bei d_circle_slots=0.9 und 2 Perimeter
					d_handles			= 3;			% diameter of the handles / mm
					d_inner				= 19.5;		% inner diameter / mm					20.5		/ 19.5 / 20
					d_circle_slots		= 0.9;
				case 4									% gedruckt: 21St*75mm und 6St*40mm		!!!!!!!!!! VERWENDET !!!!!!!!!!
					height_mm			= 40;			% clamp height / mm
					ds						= 0.5;		% distance of vertices / mm
					alpha_deg			= 250;		% angle / degrees						250		/ 260 / 270
					w						= 2.0;		% material width / mm				>=2.0 bei d_circle_slots=0.9 und 2 Perimeter
					d_handles			= 3;			% diameter of the handles / mm
					d_inner				= 19.5;		% inner diameter / mm					20.5		/ 19.5 / 20
					d_circle_slots		= 0.9;
			end
			
			alpha					= alpha_deg*pi/180;
			
			dphi1					= ds/(d_inner+2*w)*2;			% ds=r*dphi1=(d_inner+2*w)/2*dphi1
			n1_vertices			= ceil(alpha/dphi1);
			dphi1					= alpha/n1_vertices;
			phi1_start			= (2*pi-alpha)/2;
			phi1_v				= (phi1_start:dphi1:(2*pi-phi1_start))';
			poly1_c				= [d_inner/2*exp(1i*phi1_v);(d_inner+2*w)/2*exp(1i*phi1_v(end:-1:1))];
			poly1					= polyshape(real(poly1_c),imag(poly1_c));
			
			ds2					= ds/2;
			dphi2					= ds2/d_handles*2;			% ds2=r*dphi2=d_handles/2*dphi2
			n2_vertices			= ceil(2*pi/dphi2);
			dphi2					= 2*pi/n2_vertices;
			phi2_v				= (0:dphi2:(2*pi))';
			poly2_c				= d_handles/2*exp(1i*phi2_v);
			poly2a_c				= poly2_c+(d_inner+d_handles)/2*exp(1i*phi1_start);
			poly2a				= polyshape(real(poly2a_c),imag(poly2a_c));
			poly2b_c				= poly2_c+(d_inner+d_handles)/2*exp(-1i*phi1_start);
			poly2b				= polyshape(real(poly2b_c),imag(poly2b_c));
			
			poly_margin			= poly1;
			poly_margin			= union(poly_margin,poly2a);
			poly_margin			= union(poly_margin,poly2b);
			
			dist_slots			= 2*d_circle_slots;
			
			circle0_c			= d_circle_slots/2*exp(1i*(0:15:360)*pi/180)';
			dphi					= dist_slots/d_inner*2;
			phi					= pi+dphi;
			while phi>(pi-alpha/2)
				phi				= phi-dphi;
				circle_c			= circle0_c+d_inner/2*exp(1i*phi);
				circle_poly		= polyshape(real(circle_c),imag(circle_c));
				poly_margin		= subtract(poly_margin,circle_poly);
				circle_c			= circle0_c+d_inner/2*exp(-1i*phi);
				circle_poly		= polyshape(real(circle_c),imag(circle_c));
				poly_margin		= subtract(poly_margin,circle_poly);
			end
			
			
			% Plot boundary:
			ud_tile.tile_no	= 0;
			poly_boundary		= poly_margin;
			plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
			
			% Plot margin:
			ud_obj.color_no	= 0;
			ud_obj.dz			= 0;
			ud_obj.prio			= 5000;
			ud_obj.surftype	= 200;
			plot(ha_map,poly_margin,'LineWidth',0.5,'EdgeColor','k','UserData',ud_obj,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha);
			
			% File name:
			filename	= sprintf('CrossStitchFabricClamp_v%g',muster);
			% filename	= sprintf('CrossStitchFabricClamp_H%g_A%g_W%g_DI%g_DH%g_DSL%g',...
			% 	1000*height_mm,...			% clamp height / µm
			% 	alpha_deg,...					% angle / degrees
			% 	1000*w,...						% material width / µm
			% 	1000*d_inner,...				% inner diameter / µm
			% 	1000*d_handles,...				% diameter of the handles / µm
			% 	1000*d_circle_slots);			%
			
			[xlim,ylim] = boundingbox(poly_margin);
			xmin_mm		= xlim(1,1);
			xmax_mm		= xlim(1,2);
			ymin_mm		= ylim(1,1);
			ymax_mm		= ylim(1,2);
			
			
		otherwise
			errormessage;
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Assign elevation data:
	
	% Initialization:
	ELE_ts			= [];
	ifs				= 1;
	
	% Maybe the polygons are bigger than the dimensions xmin_mm, xmax_mm, ymin_mm, ymax_mm calculated at the beginning:
	hc_map			= get(hf_map,'Children');
	na_map			= 0;
	for i=1:length(hc_map)
		if strcmp(get(hc_map(i),'Type'),'axes')
			ha_map	= hc_map(i);
			na_map	= na_map+1;
		end
	end
	if na_map~=1
		errormessage(sprintf('Unknows error'));
	end
	hc					= get(ha_map,'Children');
	for i=1:length(hc)
		if strcmp(hc(i).Type,'polygon')
			poly		= hc(i).Shape;
			xmin_mm	= min(xmin_mm,min(poly.Vertices(:,1)));
			xmax_mm	= max(xmax_mm,max(poly.Vertices(:,1)));
			ymin_mm	= min(ymin_mm,min(poly.Vertices(:,2)));
			ymax_mm	= max(ymax_mm,max(poly.Vertices(:,2)));
		end
	end
	
	% Grid spacing:
	switch testsample_no
		case 10
			% für Testteile:
			ELE_ts.elefiltset(ifs,1).dx_mm	= 0.5;
			ELE_ts.elefiltset(ifs,1).dy_mm	= 0.5;
		otherwise
			% Standard: :
			ELE_ts.elefiltset(ifs,1).dx_mm	= 5;
			ELE_ts.elefiltset(ifs,1).dy_mm	= 5;
	end
	
	% Elevation:
	ELE_ts.elefiltset(ifs,1).xv_mm	= (...
		(xmin_mm-2*ELE_ts.elefiltset(ifs,1).dx_mm):...
		ELE_ts.elefiltset(ifs,1).dx_mm:...
		(xmax_mm+2*ELE_ts.elefiltset(ifs,1).dx_mm) )';
	ELE_ts.elefiltset(ifs,1).yv_mm	= (...
		(ymin_mm-2*ELE_ts.elefiltset(ifs,1).dy_mm):...
		ELE_ts.elefiltset(ifs,1).dy_mm:...
		(ymax_mm+2*ELE_ts.elefiltset(ifs,1).dy_mm) )';
	ELE_ts.elefiltset(ifs,1).xmin_mm	= min(ELE_ts.elefiltset(ifs,1).xv_mm);
	ELE_ts.elefiltset(ifs,1).xmax_mm	= max(ELE_ts.elefiltset(ifs,1).xv_mm);
	ELE_ts.elefiltset(ifs,1).ymin_mm	= min(ELE_ts.elefiltset(ifs,1).yv_mm);
	ELE_ts.elefiltset(ifs,1).ymax_mm	= max(ELE_ts.elefiltset(ifs,1).yv_mm);
	ELE_ts.elefiltset(ifs,1).nx		= length(ELE_ts.elefiltset(ifs,1).xv_mm);
	ELE_ts.elefiltset(ifs,1).ny		= length(ELE_ts.elefiltset(ifs,1).yv_mm);
	[ELE_ts.elefiltset(ifs,1).xm_mm,...
		ELE_ts.elefiltset(ifs,1).ym_mm]	= meshgrid(...
		ELE_ts.elefiltset(ifs,1).xv_mm,...
		ELE_ts.elefiltset(ifs,1).yv_mm);
	switch testsample_no
		case 10
			% für Testteile: Maximum bei x=40, y=30:
			a=1500;		% Streckung
			y0=15;		% Wert bei x=0
			ELE_ts.elefiltset(ifs,1).zm_mm	= ...
				a./((ELE_ts.elefiltset(ifs,1).xm_mm-40).^2 +a/y0) .* ...
				cos((ELE_ts.elefiltset(ifs,1).yv_mm-30)*pi/2/10);
			ELE_ts.elefiltset(ifs,1).zm_mm(ELE_ts.elefiltset(ifs,1).zm_mm<0)	= 0;		% z-Werte minimal =0
		otherwise
			% Standard: flat surface:
			ELE_ts.elefiltset(ifs,1).zm_mm	= ones(size(ELE_ts.elefiltset(ifs,1).xm_mm))*height_mm;
	end
	ELE_ts.elefiltset(ifs,1).icolspec_v	= (1:size(PP_ts.colorspec,1))';
	ELE_ts.ifs_v									= ones(size(PP_ts.colorspec,1),1);
	for colno=1:size(PP_ts.color,1)
		ELE_ts.elecolor(colno,1).icolspec	= PP_ts.color(colno,1).spec;
		ELE_ts.elecolor(colno,1).colprio		= PP_ts.color(colno,1).prio;
		ELE_ts.elecolor(colno,1).ifs			= ifs;
		ELE_ts.elecolor(colno,1).elepoly		= [];
	end
	
	% 			ipmax				= size(ELE_local.elecolor(colno,1).elepoly,1);
	%
	%
	% colno_T_Points																= 1;
	% ifs_T_Points																= 1;
	% colprio_T_Points															= 1;
	% ele_T_Points_i_griddata													= struct;
	% ele_T_Points_i_griddata.ifs_v											= ifs_T_Points;
	% ele_T_Points_i_griddata.elefiltset.xm_mm							= T.Points(i_griddata,1);
	% ele_T_Points_i_griddata.elefiltset.ym_mm							= T.Points(i_griddata,2);
	% ele_T_Points_i_griddata.elefiltset.zm_mm							= T.Points(i_griddata,3);
	% ele_T_Points_i_griddata.elecolor(colno_T_Points,1).elepoly	= [];
	% ele_T_Points_i_griddata.elecolor(colno_T_Points,1).colprio	= colprio_T_Points;
	% ele_T_Points_i_griddata.elecolor(colno_T_Points,1).ifs		= ifs_T_Points;
	
	PP_ts.general.z_bottom_tilebase			= 0;
	
	% testplot: ELE_ts.elefiltset(ifs,1).zm_mm:
	plot_fig1002	= 0;
	if plot_fig1002==1
		hf		= figure(1002);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		set(hf,'Name','zm_mm');
		set(hf,'NumberTitle','off');
		cameratoolbar(hf,'Show');
		ha		= axes;
		title(sprintf('ELE_ts.elefiltset(%g,1).zm_mm','Interpreter',ifs),'none');
		surf(ELE_ts.elefiltset(ifs,1).xv_mm,ELE_ts.elefiltset(ifs,1).yv_mm,ELE_ts.elefiltset(ifs,1).zm_mm);
		axis(ha,'equal');
		view(ha,3);
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Create the following boundary polygons (necessary for the function map2stl):
	% ud_tile.tile_no=-1: Edge of the entire map with the planned maximum dimensions
	% ud_tile.tile_no=i:  Edge of the tile i
	
	% tile_no = -1: Edge of the entire map with the planned maximum dimensions:
	ud_tile.tile_no	= -1;
	plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
	
	% tile_no = 1: Edges of the tiles:
	% The min and max values can be outside the edge of the entire map.
	ud_tile.tile_no	= 1;
	plot(ha_map,poly_boundary,'EdgeColor','k','FaceAlpha',0,'UserData',ud_tile);
	
	% Set the axis limits:
	axis(ha_map,'equal');
	
	
	%------------------------------------------------------------------------------------------------------------------
	% The 3D representations in MATLAB format maybe do not need to be saved:
	PP_ts.general.savefig_tile				= PP_ts.testsample.savefig_tile;
	PP_ts.general.savefig_tile_color		= PP_ts.testsample.savefig_tile_color;
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Add the variables PP_ts and ELE_ts to the userdata of the figure with the handle hf_map and save the figure:
	set(hf_map,'UserData',struct(...
		'PP',PP_ts,...
		'ELE',ELE_ts,...
		'MAP_OBJECTS',[],...
		'GV',[],...
		'ver_map',VER,...
		'savetime_map',clock));
	filename	= validfilename(filename);
	savefig(hf_map,[GV.projectdirectory_ts{testsample_no,1} filename]);
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Create the STL-file:
	map_tile_no		= 1;
	map_filename	= [filename '.fig'];
	stl_filename	= filename;					% '.stl' will be added in map2stl
	msg				= sprintf('%s: create STL files',msg);
	map2stl(...
		map_tile_no,...										% map_tile_no
		GV.projectdirectory_ts{testsample_no,1},...	% map_pathname
		GV.projectdirectory_ts{testsample_no,1},...	% map_pathname_stl
		GV.projectdirectory_ts{testsample_no,1},...	% map_pathname_stl_repaired
		map_filename,...										% map_filename
		stl_filename,...										% stl_filename
		msg,...													% msg
		1);														% maptype
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Maybe delete the figure that contains the 2D representation:
	if PP_ts.testsample.savefig_2d==0
		delete([GV.projectdirectory_ts{testsample_no,1} filename '.fig']);
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Display state:
	display_on_gui('state',...
		sprintf('Creating test sample ... done (%s).',dt_string(etime(clock,t_start_statebusy))),...
		'notbusy','replace');
	
catch ME
	errormessage('',ME);
end

