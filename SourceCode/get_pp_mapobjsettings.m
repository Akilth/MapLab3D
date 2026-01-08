function [userdata_pp,textpar_pp,errortext]=get_pp_mapobjsettings(iobj,disp,obj_purpose)
% Assignment of text parameters for call of text2poly and texteqtags2poly.
% Use this function to create all editable texts on the map.
% When reloading the project parameters, the settings defined here will be used to change the text character styles
% and the text userdata (for example dz).
%
% Syntax:
% [userdata_pp,textpar_pp,errortext]=get_pp_mapobjsettings(iobj,disp,obj_purpose);
% if ~isempty(errortext)
%    errormessage(errortext);
% end
%
%														Example: obj_purpose{1,1}='map object':
%
% userdata_pp: userdata project parameters:
% If there is no foreground, the corresponding elements are empty!
% -	userdata_pp.prio_fgd						PP.obj(iobj).textpar.prio
% -	userdata_pp.prio_bgd						PP.obj(iobj).textpar.prio-0.25
% -	userdata_pp.color_no_fgd				PP.obj(iobj).textpar.color_no_letters
% -	userdata_pp.color_no_bgd				PP.obj(iobj).textpar.color_no_bgd
% -	userdata_pp.surftype_fgd				300+PP.obj(iobj).textpar.surftype_letters
% -	userdata_pp.surftype_bgd				300
% -	userdata_pp.dz_fgd						PP.obj(iobj).textpar.dz_letters
% -	userdata_pp.dz_bgd						PP.obj(iobj).textpar.dz_bgd
%
% textpar_pp:
%
% Text formatting, important when changing texts:
% -	textpar_pp.charstyle_no					PP.obj(iobj).textpar.charstyle_no
% -	textpar_pp.rotation						PP.obj(iobj).textpar.rotation
%
% Not relevant for changes to texts:
% Text position: When texts are changed, they will be centered agaion at the old position.
% -	textpar_pp.horizontalalignment		PP.obj(iobj).textpar.horizontalalignment
% -	textpar_pp.verticalalignment			PP.obj(iobj).textpar.verticalalignment
% -	textpar_pp.dist2refpoint				PP.obj(iobj).textpar.dist2refpoint
% Connection line: When texts are changed, there are no changes to the connection line.
% -	textpar_pp.line2refpoint_display		PP.obj(iobj).textpar.line2refpoint_display
% -	textpar_pp.line2refpoint_width		PP.obj(iobj).textpar.line2refpoint_width
%
% iobj					index in PP.obj
% disp					DispAs					'line'
%														'area'
%														'text'
%														'connection line'
%														'symbol'
% obj_purpose			cell array: information about the usage of the object
%							-	obj_purpose{1,1}='map object'					map objects
%							-	obj_purpose{1,1}='legend map scale bar'				legend map scale bar
%								obj_purpose{2,1}=r											legend element row number
%								obj_purpose{3,1}=c											legend element column number
%							-	obj_purpose{1,1}='legend element'						legend elements
%								obj_purpose{2,1}=r											legend element row number
%								obj_purpose{3,1}=c											legend element column number
%							-	obj_purpose{1,1}='legend symbol manual selection'	legend manually selected symbol
%								obj_purpose{2,1}=r											legend element row number
%								obj_purpose{3,1}=c											legend element column number
%							-	obj_purpose{1,1}='legend background'					legend background
%							-	obj_purpose{1,1}='legend frame'							legend frame

global PP

try
	
	userdata_pp		= [];
	textpar_pp		= [];
	errortext		= '';
	textpar_pp		= struct;
	
	switch disp
		
		%---------------------------------------------------------------------------------------------------------------
		case 'line'
			
			switch obj_purpose{1,1}
				case 'map object'
					if iobj<1
						errormessage;
					end
				case 'legend element'
					if iobj<0
						errormessage;
					end
					r			= obj_purpose{2,1};
					c			= obj_purpose{3,1};
					if (r<1)||(c<1)
						errormessage;
					end
					if    (r>size(PP.legend.element,1))||...
							(c>size(PP.legend.element,2))
						errortext		= sprintf([...
							'The project parameters of legend element\n',...
							'(R2=%g,C2=%g) are required, but the legend\n',...
							'elements size in the project file is only\n',...
							'(R2max=%g,C2max=%g).'],r,c,size(PP.legend.element,1),size(PP.legend.element,2));
						return
					end
					iobj_v		= PP.legend.element(r,c).legsymb_objno{1,1};	% Legend: symbol: object number (0=deactiv)
					for i_iobj=1:length(iobj_v)
						iobj		= iobj_v(i_iobj);
						if iobj<1
							errortext		= sprintf([...
								'The line parameters of the legend element (R2=%g,C2=%g)\n',...
								'cannot be determined because the parameter\n',...
								'legend.element(R2=%g,C2=%g).legsymb_objno is less than one.'],r,c,r,c);
							return
						end
					end
				otherwise
					errormessage;
			end
			if iobj>size(PP.obj,1)
				errortext		= sprintf([...
					'The project parameters of object number %g\n',...
					'are required, but the maximum object number\n',...
					'in the project file is only %g.'],iobj,size(PP.obj,1));
				return
			end
			
			% Because the userdata_pp values ​​depend on PP.obj(iobj,1).linestyle and PP.obj(iobj,1).linepar,
			% they are assigned in line2poly and not here:
			% The assignment of in, iw, and ir is not necessary here.
			[~,~,ud_line,ud_lisy]	= line2poly(...
				[],...									% x
				[],...									% y
				PP.obj(iobj).linepar,...			% par
				PP.obj(iobj).linestyle,...			% style
				iobj,...									% iobj
				obj_purpose);							% obj_purpose
			
			% Userdata: When texts are changed, these fields of the userdata are not changed.
			switch obj_purpose{1,1}
				case 'map object'
					
					if ~isempty(ud_lisy)
						userdata_pp.prio_fgd					= ud_lisy.prio;
						userdata_pp.color_no_fgd			= ud_lisy.color_no;
						userdata_pp.surftype_fgd			= ud_lisy.surftype;
						userdata_pp.dz_fgd					= ud_lisy.dz;
					else
						userdata_pp.prio_fgd					= [];
						userdata_pp.color_no_fgd			= [];
						userdata_pp.surftype_fgd			= [];
						userdata_pp.dz_fgd					= [];
					end
					userdata_pp.prio_bgd						= ud_line.prio;
					userdata_pp.color_no_bgd				= ud_line.color_no;
					userdata_pp.surftype_bgd				= ud_line.surftype;
					userdata_pp.dz_bgd						= ud_line.dz;
					
				case 'legend element'
					
					if ~isempty(ud_lisy)
						userdata_pp.prio_fgd					= [];					% assigned in create_legend_map.m
						userdata_pp.color_no_fgd			= ud_lisy.color_no;
						userdata_pp.surftype_fgd			= ud_lisy.surftype;
						userdata_pp.dz_fgd					= ud_lisy.dz;
					else
						userdata_pp.prio_fgd					= [];
						userdata_pp.color_no_fgd			= [];
						userdata_pp.surftype_fgd			= [];
						userdata_pp.dz_fgd					= [];
					end
					userdata_pp.prio_bgd						= [];					% assigned in create_legend_map.m
					userdata_pp.color_no_bgd				= ud_line.color_no;
					userdata_pp.surftype_bgd				= ud_line.surftype;
					userdata_pp.dz_bgd						= ud_line.dz;
					
				otherwise
					errormessage;
			end
			
			
			%---------------------------------------------------------------------------------------------------------------
		case 'area'
			
			switch obj_purpose{1,1}
				case 'map object'
					if iobj<1
						errormessage;
					end
				case 'legend element'
					if iobj<0
						errormessage;
					end
					r			= obj_purpose{2,1};
					c			= obj_purpose{3,1};
					if (r<1)||(c<1)
						errormessage;
					end
					if    (r>size(PP.legend.element,1))||...
							(c>size(PP.legend.element,2))
						errortext		= sprintf([...
							'The project parameters of legend element\n',...
							'(R2=%g,C2=%g) are required, but the legend\n',...
							'elements size in the project file is only\n',...
							'(R2max=%g,C2max=%g).'],r,c,size(PP.legend.element,1),size(PP.legend.element,2));
						return
					end
					iobj_v		= PP.legend.element(r,c).legsymb_objno{1,1};	% Legend: symbol: object number (0=deactiv)
					for i_iobj=1:length(iobj_v)
						iobj		= iobj_v(i_iobj);
						if iobj<1
							errortext		= sprintf([...
								'The area parameters of the legend element (R2=%g,C2=%g)\n',...
								'cannot be determined because the parameter\n',...
								'legend.element(R2=%g,C2=%g).legsymb_objno is less than one.'],r,c,r,c);
							return
						end
					end
				case {'legend map scale bar','legend background','legend frame'}
					% nop
				otherwise
					errormessage;
			end
			if iobj>size(PP.obj,1)
				errortext		= sprintf([...
					'The project parameters of object number %g\n',...
					'are required, but the maximum object number\n',...
					'in the project file is only %g.'],iobj,size(PP.obj,1));
				return
			end
			
			switch obj_purpose{1,1}
				case 'map object'
					
					% Because the userdata_pp values ​​depend on PP.obj(iobj,1).areastyle and PP.obj(iobj,1).areapar,
					% they are assigned in area2poly and not here:
					% The assignment of in, iw, and ir is not necessary here.
					[~,~,ud_area,ud_arsy]	= area2poly(...
						polyshape(),...						% polyin
						PP.obj(iobj).areapar,...			% par
						PP.obj(iobj).areastyle,...			% style
						iobj,...									% iobj
						obj_purpose);							% obj_purpose
					
					% Userdata: When texts are changed, these fields of the userdata are not changed.
					if ~isempty(ud_arsy)
						userdata_pp.prio_fgd					= ud_arsy.prio;
						userdata_pp.color_no_fgd			= ud_arsy.color_no;
						userdata_pp.surftype_fgd			= ud_arsy.surftype;
						userdata_pp.dz_fgd					= ud_arsy.dz;
					else
						userdata_pp.prio_fgd					= [];
						userdata_pp.color_no_fgd			= [];
						userdata_pp.surftype_fgd			= [];
						userdata_pp.dz_fgd					= [];
					end
					userdata_pp.prio_bgd						= ud_area.prio;
					userdata_pp.color_no_bgd				= ud_area.color_no;
					userdata_pp.surftype_bgd				= ud_area.surftype;
					userdata_pp.dz_bgd						= ud_area.dz;
					
				case 'legend element'
					
					% Because the userdata_pp values ​​depend on PP.obj(iobj,1).areastyle and PP.obj(iobj,1).areapar,
					% they are assigned in area2poly and not here:
					% The assignment of in, iw, and ir is not necessary here.
					[~,~,ud_area,ud_arsy]	= area2poly(...
						polyshape(),...						% polyin
						PP.obj(iobj).areapar,...			% par
						PP.obj(iobj).areastyle,...			% style
						iobj,...									% iobj
						obj_purpose);							% obj_purpose
					
					% Userdata: When texts are changed, these fields of the userdata are not changed.
					if ~isempty(ud_arsy)
						userdata_pp.prio_fgd					= [];					% assigned in create_legend_map.m
						userdata_pp.color_no_fgd			= ud_arsy.color_no;
						userdata_pp.surftype_fgd			= ud_arsy.surftype;
						userdata_pp.dz_fgd					= ud_arsy.dz;
					else
						userdata_pp.prio_fgd					= [];
						userdata_pp.color_no_fgd			= [];
						userdata_pp.surftype_fgd			= [];
						userdata_pp.dz_fgd					= [];
					end
					userdata_pp.prio_bgd						= [];					% assigned in create_legend_map.m
					userdata_pp.color_no_bgd				= ud_area.color_no;
					userdata_pp.surftype_bgd				= ud_area.surftype;
					userdata_pp.dz_bgd						= ud_area.dz;
					
				case 'legend map scale bar'
					
					userdata_pp.prio_fgd						= [];					% assigned in create_legend_map.m
					userdata_pp.prio_bgd						= [];					% assigned in create_legend_map.m
					userdata_pp.color_no_fgd				= PP.legend.mapscalebar_color_no;
					userdata_pp.color_no_bgd				= PP.legend.mapscalebar_color_no;
					userdata_pp.surftype_fgd				= 200;	% Because the legend is flat, no extra param. is needed
					userdata_pp.surftype_bgd				= 200;
					userdata_pp.dz_fgd						= PP.legend.mapscalebar_dz_fgd;
					userdata_pp.dz_bgd						= PP.legend.mapscalebar_dz_bgd;
					
				case 'legend background'
					
					userdata_pp.prio_fgd						= [];					% assigned in create_legend_map.m
					userdata_pp.prio_bgd						= [];					% assigned in create_legend_map.m
					userdata_pp.color_no_fgd				= PP.legend.color_no_bgd;
					userdata_pp.color_no_bgd				= PP.legend.color_no_bgd;
					userdata_pp.surftype_fgd				= 200;	% Because the legend is flat, no extra param. is needed
					userdata_pp.surftype_bgd				= 200;
					userdata_pp.dz_fgd						= 0;
					userdata_pp.dz_bgd						= 0;
					
				case 'legend frame'
					
					userdata_pp.prio_fgd						= [];					% assigned in create_legend_map.m
					userdata_pp.prio_bgd						= [];					% assigned in create_legend_map.m
					userdata_pp.color_no_fgd				= PP.legend.color_no_fra;
					userdata_pp.color_no_bgd				= PP.legend.color_no_fra;
					userdata_pp.surftype_fgd				= 200;	% Because the legend is flat, no extra param. is needed
					userdata_pp.surftype_bgd				= 200;
					userdata_pp.dz_fgd						= PP.legend.fh;
					userdata_pp.dz_bgd						= PP.legend.fh;
					
			end
			
			
			%---------------------------------------------------------------------------------------------------------------
		case 'symbol'
			
			switch obj_purpose{1,1}
				case 'map object'
					if iobj<1
						errormessage;
					end
				case {'legend element','legend symbol manual selection'}
					if iobj<0
						errormessage;
					end
					r			= obj_purpose{2,1};
					c			= obj_purpose{3,1};
					if (r<1)||(c<1)
						errormessage;
					end
					if    (r>size(PP.legend.element,1))||...
							(c>size(PP.legend.element,2))
						errortext		= sprintf([...
							'The project parameters of legend element\n',...
							'(R2=%g,C2=%g) are required, but the legend\n',...
							'elements size in the project file is only\n',...
							'(R2max=%g,C2max=%g).'],r,c,size(PP.legend.element,1),size(PP.legend.element,2));
						return
					end
					iobj_v		= PP.legend.element(r,c).legsymb_objno{1,1};	% Legend: symbol: object number (0=deactiv)
					for i_iobj=1:length(iobj_v)
						iobj		= iobj_v(i_iobj);
						if	  (strcmp(obj_purpose{1,1},'legend element'                )&&...
								(iobj<1)                                                             )||(...
								strcmp(obj_purpose{1,1},'legend symbol manual selection')&&(...
								isempty(PP.legend.element(r,c).legsymb_mansel_key)||...
								isempty(PP.legend.element(r,c).legsymb_mansel_val)             )     )
							errortext		= sprintf([...
								'The symbol parameters of the legend element (R2=%g,C2=%g)\n',...
								'cannot be determined because the parameter\n',...
								'legend.element(R2=%g,C2=%g).legsymb_objno is less than one\n',...
								'or there is no manually selected symbol specified.'],r,c,r,c);
							return
						end
					end
				otherwise
					errormessage;
			end
			if iobj>size(PP.obj,1)
				errortext		= sprintf([...
					'The project parameters of object number %g\n',...
					'are required, but the maximum object number\n',...
					'in the project file is only %g.'],iobj,size(PP.obj,1));
				return
			end
			
			switch obj_purpose{1,1}
				case 'map object'
					
					% Userdata: When texts are changed, these fields of the userdata are not changed.
					userdata_pp.prio_fgd						= PP.obj(iobj).symbolpar.prio;
					userdata_pp.prio_bgd						= PP.obj(iobj).symbolpar.prio-0.25;
					userdata_pp.color_no_fgd				= PP.obj(iobj).symbolpar.color_no_symbol;
					userdata_pp.color_no_bgd				= PP.obj(iobj).symbolpar.color_no_bgd;
					userdata_pp.surftype_fgd				= 400+PP.obj(iobj).symbolpar.surftype_symbol;
					userdata_pp.surftype_bgd				= 400;
					userdata_pp.dz_fgd						= PP.obj(iobj).symbolpar.dz_symbol;
					userdata_pp.dz_bgd						= PP.obj(iobj).symbolpar.dz_bgd;
					
				case 'legend element'
					
					% Userdata: When texts are changed, these fields of the userdata are not changed.
					userdata_pp.prio_fgd						= [];					% assigned in create_legend_map.m
					userdata_pp.prio_bgd						= [];					% assigned in create_legend_map.m
					userdata_pp.color_no_fgd				= PP.obj(iobj).symbolpar.color_no_symbol;
					userdata_pp.color_no_bgd				= PP.obj(iobj).symbolpar.color_no_bgd;
					userdata_pp.surftype_fgd				= 400+PP.obj(iobj).symbolpar.surftype_symbol;
					userdata_pp.surftype_bgd				= 400;
					userdata_pp.dz_fgd						= PP.obj(iobj).symbolpar.dz_symbol;
					userdata_pp.dz_bgd						= PP.obj(iobj).symbolpar.dz_bgd;
					
				case 'legend symbol manual selection'
					
					userdata_pp.prio_fgd						= [];					% assigned in create_legend_map.m
					userdata_pp.prio_bgd						= [];					% assigned in create_legend_map.m
					userdata_pp.color_no_fgd				= PP.legend.element(r,c).legsymb_mansel_color_no_sym;
					userdata_pp.color_no_bgd				= PP.legend.element(r,c).legsymb_mansel_color_no_bgd;
					userdata_pp.surftype_fgd				= 400;	% Because the legend is flat, no extra param. is needed
					userdata_pp.surftype_bgd				= 400;
					userdata_pp.dz_fgd						= PP.legend.element(r,c).legsymb_mansel_dz_symbol;
					userdata_pp.dz_bgd						= PP.legend.element(r,c).legsymb_mansel_dz_bdg;
					
			end
			
			
			%---------------------------------------------------------------------------------------------------------------
		case {'text','connection line'}
			
			switch obj_purpose{1,1}
				
				case 'map object'
					
					% Texts of map objects:
					if iobj<1
						% This should not happen:
						errormessage;
					end
					if iobj>size(PP.obj,1)
						errortext		= sprintf([...
							'The project parameters of object number %g\n',...
							'are required, but the maximum object number\n',...
							'in the project file is only %g.'],iobj,size(PP.obj,1));
						return
					end
					
					% Userdata: When texts are changed, these fields of the userdata are not changed.
					userdata_pp.prio_fgd						= PP.obj(iobj).textpar.prio;
					userdata_pp.prio_bgd						= PP.obj(iobj).textpar.prio-0.25;
					userdata_pp.color_no_fgd				= PP.obj(iobj).textpar.color_no_letters;
					userdata_pp.color_no_bgd				= PP.obj(iobj).textpar.color_no_bgd;
					userdata_pp.surftype_fgd				= 300+PP.obj(iobj).textpar.surftype_letters;
					userdata_pp.surftype_bgd				= 300;
					userdata_pp.dz_fgd						= PP.obj(iobj).textpar.dz_letters;
					userdata_pp.dz_bgd						= PP.obj(iobj).textpar.dz_bgd;
					
					% Text formatting, important when changing texts:
					textpar_pp.charstyle_no					= PP.obj(iobj).textpar.charstyle_no;
					textpar_pp.rotation						= PP.obj(iobj).textpar.rotation;
					% Text position: When texts are changed, they will be centered agaion at the old position.
					textpar_pp.horizontalalignment		= PP.obj(iobj).textpar.horizontalalignment;
					textpar_pp.verticalalignment			= PP.obj(iobj).textpar.verticalalignment;
					textpar_pp.dist2refpoint				= PP.obj(iobj).textpar.dist2refpoint;
					% Connection line: When texts are changed, there are no changes to the connection line.
					textpar_pp.line2refpoint_display		= PP.obj(iobj).textpar.line2refpoint_display;
					textpar_pp.line2refpoint_width		= PP.obj(iobj).textpar.line2refpoint_width;
					
				case 'legend map scale bar'
					
					% Tick labels of the legend map scale bar:
					r												= obj_purpose{2,1};
					c												= obj_purpose{3,1};
					if (r<1)||(c<1)
						% This should not happen:
						errormessage;
					end
					if    (r>size(PP.legend.element,1))||...
							(c>size(PP.legend.element,2))
						errortext		= sprintf([...
							'The project parameters of legend element\n',...
							'(R2=%g,C2=%g) are required, but the legend\n',...
							'elements size in the project file is only\n',...
							'(R2max=%g,C2max=%g).'],r,c,size(PP.legend.element,1),size(PP.legend.element,2));
						return
					end
					
					% Userdata: When texts are changed, these fields of the userdata are not changed.
					userdata_pp.prio_fgd						= [];					% assigned in create_legend_map.m
					userdata_pp.prio_bgd						= [];					% assigned in create_legend_map.m
					userdata_pp.color_no_fgd				= PP.legend.element(r,c).text_color_no_letters;
					userdata_pp.color_no_bgd				= PP.legend.element(r,c).text_color_no_background;
					userdata_pp.surftype_fgd				= 300;	% Because the legend is flat, no extra parameter is needed
					userdata_pp.surftype_bgd				= 300;
					userdata_pp.dz_fgd						= PP.legend.element(r,c).text_dz_letters;
					userdata_pp.dz_bgd						= PP.legend.element(r,c).text_dz_bgd;
					
					% Text formatting, important when changing texts:
					textpar_pp.charstyle_no					= PP.legend.element(r,c).text_charstyle_no;
					textpar_pp.rotation						= 0;
					% Text position: When texts are changed, they will be centered agaion at the old position.
					textpar_pp.horizontalalignment		= 'center';
					textpar_pp.verticalalignment			= 'baseline';
					textpar_pp.dist2refpoint				= 0;					% the legend texts do not have reference points
					% Connection line: When texts are changed, there are no changes to the connection line.
					textpar_pp.line2refpoint_display		= 0;					% the legend texts do not have reference points
					textpar_pp.line2refpoint_width		= 0;					% the legend texts do not have reference points
					
				case 'legend element'
					
					% Legend texts:
					r												= obj_purpose{2,1};
					c												= obj_purpose{3,1};
					if (r<1)||(c<1)
						% This should not happen:
						errormessage;
					end
					if    (r>size(PP.legend.element,1))||...
							(c>size(PP.legend.element,2))
						errortext		= sprintf([...
							'The project parameters of legend element\n',...
							'(R2=%g,C2=%g) are required, but the legend\n',...
							'elements size in the project file is only\n',...
							'(R2max=%g,C2max=%g).'],r,c,size(PP.legend.element,1),size(PP.legend.element,2));
						return
					end
					
					% Userdata: When texts are changed, these fields of the userdata are not changed.
					userdata_pp.prio_fgd						= [];					% assigned in create_legend_map.m
					userdata_pp.prio_bgd						= [];					% assigned in create_legend_map.m
					userdata_pp.color_no_fgd				= PP.legend.element(r,c).text_color_no_letters;
					userdata_pp.color_no_bgd				= PP.legend.element(r,c).text_color_no_background;
					userdata_pp.surftype_fgd				= 300;	% Because the legend is flat, no extra parameter is needed
					userdata_pp.surftype_bgd				= 300;
					userdata_pp.dz_fgd						= PP.legend.element(r,c).text_dz_letters;
					userdata_pp.dz_bgd						= PP.legend.element(r,c).text_dz_bgd;
					
					% Text formatting, important when changing texts:
					textpar_pp.charstyle_no					= PP.legend.element(r,c).text_charstyle_no;
					textpar_pp.rotation						= 0;
					% Text position: When texts are changed, they will be centered agaion at the old position.
					textpar_pp.horizontalalignment		= PP.legend.element(r,c).text_hor_alignment;
					textpar_pp.verticalalignment			= 'baseline';
					textpar_pp.dist2refpoint				= 0;					% the legend texts do not have reference points
					% Connection line: When texts are changed, there are no changes to the connection line.
					textpar_pp.line2refpoint_display		= 0;					% the legend texts do not have reference points
					textpar_pp.line2refpoint_width		= 0;					% the legend texts do not have reference points
					
				otherwise
					errormessage;
			end
			
		otherwise
			errormessage;
	end
	
catch ME
	errormessage('',ME);
end

