function imapobj_new_v=plot_modify(action,imapobj_v,par1,par2,par3,par4,par5)
% imapobj_new_v									indices of new elements in MAP_OBJECTS
%														tested with action =			new_poly
% action			move								move object
%														par1:					displacement in x-direction
% 														par2:					displacement in y-direction
% 					rotate							rotate object
%														par1:		rotation angle in degree
% 					reset								reset position, rotation and size of the object or object group
% 					hide								hide object
%														par1								execute function display_map_objects (0/1)
%														par2								hide temporarily (0/1)
% 					restore							restore temporary visibilty
% 					show								show object
% 					gray_out							gray out object
% 					select							select object
%														par1=1 or not specified:	execute function display_map_objects
%														par1=0:							do not execute function display_map_objects
% 					deselect							deselect object (undo select)
%														par1=1 or not specified:	execute function display_map_objects
%														par1=0:							do not execute function display_map_objects
% 					duplicate						duplicate object
% 														par1:								displacement in x-direction
% 														par2:								displacement in y-direction
% 					scale								scale object
% 														par1:								scale factor in x-direction
% 														par2:								scale factor in y-direction
%					set_dim							set Dimensions
% 					delete							delete specific objects
% 					ungroup							divide a polygon into its regions
% 					group								group objects
%					mod_vertex						modify vertex:
%														only applicable on lines, imapobj_v must be a scalar!
% 														par1='add'			Add a new vertex.
%																				par2='first'	Add/delete at the beginning of the line.
% 																				par2='last'		Add/delete at the end of the line.
%																				par3:				x-value of the new vertex
%																				par4:				y-value of the new vertex
% 														par1='move'			Move a vertex.
%																				par2:				vertex index
%																				par3:				new x-value of the vertex
%																				par4:				new y-value of the vertex
% 														par1='delvertex'	Delete a vertex.
%																				par2='first'	Add/delete at the beginning of the line.
% 																				par2='last'		Add/delete at the end of the line.
% 														par1='delvertices'	Delete vertices.
%																					par2			Rubberband box start point x
%																					par3			Rubberband box start point y
%																					par4			Rubberband box end   point x
%																					par5			Rubberband box end   point y
% 														par1='split'			Delete vertices and split the line into more than
%																					one map object.
%																					par2			Rubberband box start point x
%																					par3			Rubberband box start point y
%																					par4			Rubberband box end   point x
%																					par5			Rubberband box end   point y
% 														par1='close'		Close line:		Set last vertex equal to first.
% 														par1='cut'			Cut line: If the line is closed delete the last vertex.
% 														par1='insert'		Insert one vertex between two vertices 1 and 2.
%																				par2:				vertex index 1
%																				par3:				vertex index 2
%																				no longer used
%					new_line							Create a new preview line with a single vertex or multiple vertices:
%														Syntax:	plot_modify('new_line',0,x,y);
%														par1		x-value/s of the new vertex/vertices
%														par2		y-value/s of the new vertex/vertices
%														par3		optional: description
%														par4		optional: text_prev (character array or cell array)
%					new_poly							Create a new preview polygon:
%														Syntax:	plot_modify('new_poly',0,poly,dscr_prev,text_prev,sel_prev);
%														par1		preview polygon (scalar/vector/matrix)
%														par2		optional: dscr_prev
%														par3		optional: text_prev (character array or cell array)
%														par4		optional: select the new preview polygon (true/false)
%					connect							Connect lines with matching endpoints
%					poly2line						Convert one polygon to preview lines
%					line2poly						Convert preview line to preview polygon
%					convprevline					Convert preview line:
%														par1		2connlinemapobj	to text connection line map object
%														par1		2linemapobj			to	line map object with line or area settings
%					prevcutline2cutline			Convert preview cutting line (line) to cutting line (polygon)
%					new_cutline						Create a new cutting line (polygon)
%														Syntax:							plot_modify('new_cutline',0,poly,colno);
%														poly	= par1					cutting line
%														colno	= par2					color number
%					poly								Polygon functions
%														par1='polybuffer'				Create buffer around polyshape object
%																							par2=bufferdistance
%														par1='simplify'				Set minimum distance between vertices
%														par1='dissolve_bound'		Divide into boundaries
%														par1='regions'					Divide into solid regions
%					poly12							Functions on two polygons
%														Syntax:							plot_modify('poly12',0,par1);
%														par1='union'					Union of polyshape objects
%														par1='subtract'				Difference of two polyshape objects
%														par1='subtract_dside'		Difference of two polyshape objects with
%																							manufacturing tolerance. Before the
%																							subtraction, the subtrahend is enlarged by
%																							the maximum value PP.colorspec(i,1).d_side
%																							of the colors involved.
%														par1='intersect'				Intersection of polyshape objects
%														par1='xor'						Exclusive OR of two polyshape objects
%														par1='addboundary'			Add polyshape boundary
%					arrange							Set the row imapobj_v to the last row in MAP_OBJECTS.
%														Arrange the order of MAP_OBJECTS and the axes children.
%														Useful because selection of not consecutive rows is not possible or
%														because small plot objects under big plot objects are not selectable.
%														imapobj_v must be a scalar!
%														par1='up'				Move object imapobj one row up
%														par1='down'				Move object imapobj one row down
%														par1='first'			Move object imapobj at the begin of MAP_OBJECTS
%																					or under all plots objects in the map
%														par1='last'				Move object imapobj at the end of MAP_OBJECTS
%																					or on top of all plots objects in the map
%														par1='set'				Set the new position
%																					par2=imapobj_new
%					printoutlim2poly				Create preview polygon equal to the printout limits
%														Syntax:							plot_modify('printoutlim2poly',0);
%					set_printout					Set the printout limits
%														Syntax:							plot_modify('set_printout',-1);
%					change_text						Change text
%														par1='text'						Change the text
%														par1='charstyle'				Change the character style
%																							par2=charstyle_no
%														par3								true:		abort on error
%																							false:	skip on error
%					change_color					Change color
%														par1=color_no_fgd or =[]	Color number foreground
%														par2=color_no_bgd or =[]	Color number background
%																							-1:	Reset the color numbers
%					change_liwi						Change line width (only if PP.obj(iobj).linestyle==3).
%														Syntax:							plot_modify('change_liwi',imapobj)
%					change_description			Change description
%					change_texttag					Change text/tag
%					enter_circle					Enter the data and draw a circle.
%					enter_rectangle				Enter the data and draw a rectangle.
%					textfile							Save and load map object boundaries
%														par1='to'						to text file
%														par1='from'						from text file
%					change_relid					Change the relation ID of preview lines or preview polygons.
%														This is needed to add the preview as a map object to the map.
%														All objects with the same relation ID are merged using "addboundary".
%														All objects with no relation ID or ID=0 are merged using "union".
%														par1=relid_old					existing relation ID
% 					delete_all_previews			delete alle preview objects
% 					delete_lastadded_preview	delete the last added preview object
%
% imapobj_v		index/indices in MAP_OBJECTS, can be a vector
%					imapobj_v=-1: The action is applied to all selected objects!
%					imapobj_v=0:  Fhe function does not require any marked objects!

global MAP_OBJECTS MAP_OBJECTS_TABLE GV GV_H OSMDATA APP PP SETTINGS

% Because this function can be called directly by the user through a callback,
% a try/catch statement must be used here:
try
	
	if isempty(MAP_OBJECTS)
		return
	end
	
	% Check if the axis GV_H.ax_2dmap exists:
	% if ~ishandle(GV_H.ax_2dmap)||isempty(MAP_OBJECTS)
	if ~ishandle(GV_H.ax_2dmap)
		errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
	end
	
	if isempty(MAP_OBJECTS)
		% The map is empty: Allow only commands, that add a new object to the map:
		if  ~(strcmp(action,'new_line')                       ||...
				strcmp(action,'new_poly')                       ||...
				strcmp(action,'new_cutline')                    ||...
				strcmp(action,'enter_circle')                   ||...
				strcmp(action,'enter_rectangle')                ||...
				(strcmp(action,'textfile')&&strcmp(par1,'from'))     )
			errormessage(sprintf('Error:\nTo use this function the map must not be empty.'));
		end
	end
	
	imapobj_new_v	= [];
	if nargin>1
		imapobj0_v	= imapobj_v;
		if isequal(imapobj_v,-1)
			if ~strcmp(action,'select')
				imapobj_sel_v	= false(size(MAP_OBJECTS,1),1);
				for imapobj=1:size(MAP_OBJECTS,1)
					if MAP_OBJECTS(imapobj,1).h(1,1).Selected
						imapobj_sel_v(imapobj,1)	= true;
					end
				end
				imapobj_v	= find(imapobj_sel_v);
			end
		else
			for k=1:length(imapobj_v)
				imapobj	= imapobj_v(k);
				if imapobj>size(MAP_OBJECTS,1)
					errortext	= sprintf(['Error:\n',...
						'PlotNo=%g must be less or equal to %g'],imapobj,size(MAP_OBJECTS,1));
					errormessage(errortext);
				end
			end
		end
		if isempty(imapobj_v)
			return
		end
		imapobj_v	= imapobj_v(:);
	else
		imapobj0_v	= -1;
	end
	
	% Display state:
	stateisbusy	= display_on_gui('state','','isbusy');
	% For certain actions, the status does not need to be set to busy if these actions do not require
	% a long computing time:
	stateisbusy	= stateisbusy   ||(...
		strcmp(action,'select')  || ...
		strcmp(action,'deselect')|| ...
		strcmp(action,'hide')    || ...
		strcmp(action,'restore') || ...
		strcmp(action,'show')    || ...
		strcmp(action,'gray_out')|| ...
		strcmp(action,'move')    || ...
		strcmp(action,'scale')   || ...
		strcmp(action,'rotate')        )&&(length(imapobj_v)<=20);
	if ~stateisbusy
		% t_start_statebusy	= clock;
		display_on_gui('state','','busy');
	end
	
	% Waitbar:
	waitbar_t1			= clock;
	if nargin==1
		% delete_lastadded_preview, delete_all_previews: no waitbar
		waitbar_activ		= false;
	else
		if    strcmp(action,'select')  ||...
				strcmp(action,'deselect')||...
				strcmp(action,'connect')
			waitbar_activ		= false;
		else
			if length(imapobj_v)>1
				waitbar_activ		= true;
			else
				if strcmp(action,'ungroup')
					waitbar_activ		= true;
				else
					if strcmp(action,'poly')&&strcmp(par1,'regions')
						waitbar_activ		= true;
					else
						waitbar_activ		= false;
					end
				end
			end
		end
	end
	
	switch action
		
		%------------------------------------------------------------------------------------------------------------
		case 'move'
			
			dx		= par1;
			dy		= par2;
			for k=1:length(imapobj_v)
				imapobj								= imapobj_v(k);
				MAP_OBJECTS(imapobj,1).mod		= true;
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				% Move:
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					switch MAP_OBJECTS(imapobj,1).h(i,1).Type
						case 'polygon'
							MAP_OBJECTS(imapobj,1).h(i,1).Shape = translate(MAP_OBJECTS(imapobj,1).h(i,1).Shape,dx,dy);
						case 'line'
							MAP_OBJECTS(imapobj,1).h(i,1).XData	= MAP_OBJECTS(imapobj,1).h(i,1).XData(:)+dx;
							MAP_OBJECTS(imapobj,1).h(i,1).YData	= MAP_OBJECTS(imapobj,1).h(i,1).YData(:)+dy;
					end
				end
				% Center point:
				[x,y]	= map_objects_center(imapobj);
				MAP_OBJECTS(imapobj,1).x	= x;
				MAP_OBJECTS(imapobj,1).y	= y;
			end
			% Changing .Shape, .XData, .YData, .mod, .x or .y does not require updating the table!
			% Update MAP_OBJECTS_TABLE:
			% display_map_objects(imapobj_v);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'rotate'
			
			rot		= par1;
			
			% Center point:
			x_line	= zeros(0,1);
			y_line	= zeros(0,1);
			for k=1:length(imapobj_v)
				imapobj								= imapobj_v(k);
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					switch MAP_OBJECTS(imapobj,1).h(i,1).Type
						case 'polygon'
							x_line	= [x_line;MAP_OBJECTS(imapobj,1).h(i,1).Shape.Vertices(:,1)];
							y_line	= [y_line;MAP_OBJECTS(imapobj,1).h(i,1).Shape.Vertices(:,2)];
						case 'line'
							x_line	= [x_line;MAP_OBJECTS(imapobj,1).h(i,1).XData(:)];
							y_line	= [y_line;MAP_OBJECTS(imapobj,1).h(i,1).YData(:)];
					end
				end
			end
			x_center		= mean(x_line(~isnan(x_line)));
			y_center		= mean(y_line(~isnan(y_line)));
			% Rotate objects:
			for k=1:length(imapobj_v)
				imapobj								= imapobj_v(k);
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				% Rotate:
				MAP_OBJECTS(imapobj,1).mod		= true;
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					switch MAP_OBJECTS(imapobj,1).h(i,1).Type
						case 'polygon'
							MAP_OBJECTS(imapobj,1).h(i,1).Shape = rotate(MAP_OBJECTS(imapobj,1).h(i,1).Shape,rot,...
								[x_center y_center]);
						case 'line'
							x_line					= MAP_OBJECTS(imapobj,1).h(i,1).XData(:);
							y_line					= MAP_OBJECTS(imapobj,1).h(i,1).YData(:);
							c_line					= ((x_line-x_center)+1i*(y_line-y_center))*exp(1i*rot*pi/180);
							MAP_OBJECTS(imapobj,1).h(i,1).XData	= real(c_line)+x_center;
							MAP_OBJECTS(imapobj,1).h(i,1).YData	= imag(c_line)+y_center;
					end
					if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'rotation')
						rotation_old				= MAP_OBJECTS(imapobj,1).h(i,1).UserData.rotation;
					else
						rotation_old				= 0;
					end
					rotation_new					= round(rotation_old+rot,-log10(GV.tol_1));
					MAP_OBJECTS(imapobj,1).h(i,1).UserData.rotation		= rotation_new;
				end
			end
			
			% Changing .Shape, .XData, .YData, .mod, .x or .y does not require updating the table!
			% Update MAP_OBJECTS_TABLE:
			% display_map_objects(imapobj_v);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'reset'
			
			% User confirmation:
			if isequal(imapobj0_v,-1)
				answer	= [];
				while isempty(answer)
					question	= 'Reset all selected objects?';
					answer	= questdlg_local(question,'Continue?','Continue','Cancel','Cancel');
				end
				if strcmp(answer,'Cancel')
					if ~stateisbusy
						display_on_gui('state','','notbusy');
					end
					return
				end
			end
			
			% Reset:
			for k=1:length(imapobj_v)
				imapobj								= imapobj_v(k);
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				MAP_OBJECTS(imapobj,1).mod		= false;
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					switch MAP_OBJECTS(imapobj,1).h(i,1).Type
						case 'polygon'
							MAP_OBJECTS(imapobj,1).h(i,1).Shape	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.shape0;
							% if strcmp(MAP_OBJECTS(imapobj,1).disp,'text')
							% Text strings and characters style numbers are not resetted.
							% MAP_OBJECTS(imapobj,1).h(i,1).UserData.text_eqtags contains only one line and
							% PLOTDATA.obj(iobj,1).text_eqtags{iteqt,1} contains all lines.
							% When changing the text with plot_modify('change_text',imapobj,'text'):
							% - manually or
							% - when loading the project parameters anew with different text settings
							% then:
							% - MAP_OBJECTS(imapobj,1).h(i,1).UserData.shape0 is overwritten with the new shape and
							% - MAP_OBJECTS(imapobj,1).h(i,1).UserData.text_eqtags contains the displayed and maybe
							%   modified text, not the text in PLOTDATA.obj(iobj,1).text_eqtags{iteqt,1}.
						case 'line'
							MAP_OBJECTS(imapobj,1).h(i,1).XData	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.xy0(:,1);
							MAP_OBJECTS(imapobj,1).h(i,1).YData	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.xy0(:,2);
					end
					% rotation:
					if strcmp(MAP_OBJECTS(imapobj,1).disp,'text')
						[~,textpar_pp,errortext]	= get_pp_mapobjsettings(...
							MAP_OBJECTS(imapobj,1).iobj,...									% iobj
							MAP_OBJECTS(imapobj,1).disp,...									% disp
							MAP_OBJECTS(imapobj,1).h(i,1).UserData.obj_purpose);		% obj_purpose
						if ~isempty(errortext)
							errormessage(errortext);
						end
						MAP_OBJECTS(imapobj,1).h(i,1).UserData.rotation	= textpar_pp.rotation;
					else
						MAP_OBJECTS(imapobj,1).h(i,1).UserData.rotation	= 0;
					end
				end
				% Center point:
				[x,y]	= map_objects_center(imapobj);
				MAP_OBJECTS(imapobj,1).x	= x;
				MAP_OBJECTS(imapobj,1).y	= y;
			end
			
			% Update MAP_OBJECTS_TABLE:
			display_map_objects(imapobj_v);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'hide'
			
			if nargin<3
				par1	= 1;
			end
			if nargin<4
				par2	= 0;
			end
			for k=1:length(imapobj_v)
				imapobj								= imapobj_v(k);
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				if par2==0
					% Do not hide temporarily:
					MAP_OBJECTS(imapobj,1).vis0	= 0;
				end
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if MAP_OBJECTS(imapobj,1).h(i,1).Visible
						MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'off';
					end
				end
			end
			% Deselect the hidden objects:
			plot_modify('deselect',imapobj_v);
			% Update MAP_OBJECTS_TABLE:
			if (par1~=0)&&APP.ShowMapObjectsTable_Menu.Checked&&...
					~isempty(imapobj_v)&&~isempty(MAP_OBJECTS)
				vis0_v																= [MAP_OBJECTS(imapobj_v,1).vis0];
				imapobj_vis0_0_v													= imapobj_v(vis0_v==0);
				MAP_OBJECTS_TABLE.Vis(imapobj_vis0_0_v,1)					= 'H';
				GV_H.map_objects_table.Data.Vis(imapobj_vis0_0_v,1)	= 'H';
				imapobj_vis0_1_v													= imapobj_v(vis0_v~=0);
				MAP_OBJECTS_TABLE.Vis(imapobj_vis0_1_v,1)					= 'HT';
				GV_H.map_objects_table.Data.Vis(imapobj_vis0_1_v,1)	= 'HT';
				% slower:
				% for k=1:length(imapobj_v)
				% 	imapobj								= imapobj_v(k);
				% 	if MAP_OBJECTS(imapobj,1).vis0==0
				% 		MAP_OBJECTS_TABLE.Vis(imapobj,1)					= 'H';
				% 		GV_H.map_objects_table.Data.Vis(imapobj,1)	= 'H';
				% 	else
				% 		MAP_OBJECTS_TABLE.Vis(imapobj,1)					= 'HT';
				% 		GV_H.map_objects_table.Data.Vis(imapobj,1)	= 'HT';	% 292 Aufrufe, 20.7s
				%	end
				% end
				% much slower:
				% display_map_objects(imapobj_v);
			end
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'restore'
			
			imapobj_sh_v	= false(size(imapobj_v));
			imapobj_go_v	= false(size(imapobj_v));
			for k=1:length(imapobj_v)
				imapobj			= imapobj_v(k);
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				if MAP_OBJECTS(imapobj,1).vis0~=0
					for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
						if ~MAP_OBJECTS(imapobj,1).h(i,1).Visible
							MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'on';
							if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
								if    isequal(MAP_OBJECTS(imapobj,1).h(i,1).EdgeAlpha,GV.visibility.grayout.edgealpha)&&...
										isequal(MAP_OBJECTS(imapobj,1).h(i,1).FaceAlpha,GV.visibility.grayout.facealpha)
									imapobj_go_v(k)		= true;
								else
									imapobj_sh_v(k)		= true;
								end
							else
								imapobj_sh_v(k)		= true;
							end
						end
						% Display the source data of the selected object, if the object is selected:
						if MAP_OBJECTS(imapobj,1).h(i,1).Selected
							if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'source')
								% Source plot handles:
								source		= zeros(1,size(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source,1));
								source(1,:)	= [MAP_OBJECTS(imapobj,1).h(i,1).UserData.source.h];
								k_source		= ishandle(source);
								% Make the source plots visible:
								set(source(k_source),'Visible','on');
							end
						end
					end
				end
			end
			% Update MAP_OBJECTS_TABLE:
			if APP.ShowMapObjectsTable_Menu.Checked&&...
					~isempty(imapobj_v)&&~isempty(MAP_OBJECTS)
				MAP_OBJECTS_TABLE.Vis(imapobj_v(imapobj_sh_v),1)				= '';
				MAP_OBJECTS_TABLE.Vis(imapobj_v(imapobj_go_v),1)				= 'GO';
				GV_H.map_objects_table.Data.Vis(imapobj_v(imapobj_sh_v),1)	= '';
				GV_H.map_objects_table.Data.Vis(imapobj_v(imapobj_go_v),1)	= 'GO';
			end
			% slower:
			% display_map_objects(imapobj_v);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'show'
			
			for k=1:length(imapobj_v)
				imapobj								= imapobj_v(k);
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				MAP_OBJECTS(imapobj,1).vis0	= 1;
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if ~MAP_OBJECTS(imapobj,1).h(i,1).Visible
						MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'on';
					end
					if MAP_OBJECTS(imapobj,1).iobj>=0
						if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
							MAP_OBJECTS(imapobj,1).h(i,1).EdgeAlpha	= GV.visibility.show.edgealpha;
							MAP_OBJECTS(imapobj,1).h(i,1).FaceAlpha	= GV.visibility.show.facealpha;
						end
					end
					% Display the source data of the selected object, if the object is selected:
					if MAP_OBJECTS(imapobj,1).h(i,1).Selected
						if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'source')
							% Source plot handles:
							source		= zeros(1,size(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source,1));
							source(1,:)	= [MAP_OBJECTS(imapobj,1).h(i,1).UserData.source.h];
							k_source		= ishandle(source);
							% Make the source plots visible:
							set(source(k_source),'Visible','on');
						end
					end
				end
			end
			% Update MAP_OBJECTS_TABLE:
			if APP.ShowMapObjectsTable_Menu.Checked&&~isempty(imapobj_v)&&~isempty(MAP_OBJECTS_TABLE)
				% The map objects table is enabled:
				MAP_OBJECTS_TABLE.Vis(imapobj_v,1)				= '';
				GV_H.map_objects_table.Data.Vis(imapobj_v,1)	= '';
			end
			% slower:
			% display_map_objects(imapobj_v);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'gray_out'
			
			for k=1:length(imapobj_v)
				imapobj								= imapobj_v(k);
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				MAP_OBJECTS(imapobj,1).vis0	= 1;
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if ~MAP_OBJECTS(imapobj,1).h(i,1).Visible
						MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'on';
					end
					if MAP_OBJECTS(imapobj,1).iobj>=0
						if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
							MAP_OBJECTS(imapobj,1).h(i,1).EdgeAlpha	= GV.visibility.grayout.edgealpha;
							MAP_OBJECTS(imapobj,1).h(i,1).FaceAlpha	= GV.visibility.grayout.facealpha;
						end
					end
				end
			end
			% Update MAP_OBJECTS_TABLE:
			if APP.ShowMapObjectsTable_Menu.Checked&&...
					~isempty(imapobj_v)&&~isempty(MAP_OBJECTS_TABLE)&&~isempty(MAP_OBJECTS)
				% The map objects table is enabled:
				if MAP_OBJECTS(imapobj,1).iobj>=0
					MAP_OBJECTS_TABLE.Vis(imapobj_v,1)				= 'GO';
					GV_H.map_objects_table.Data.Vis(imapobj_v,1)	= 'GO';
				else
					MAP_OBJECTS_TABLE.Vis(imapobj_v,1)				= '';
					GV_H.map_objects_table.Data.Vis(imapobj_v,1)	= '';
				end
			end
			% slower:
			% display_map_objects(imapobj_v);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'select'
			
			% if length(imapobj_v)==1
			%	if strcmp(MAP_OBJECTS(imapobj_v,1).h(1,1).Type,'line')
			%		APP.Mod_LV_No_EditField.Value	= imapobj_v;
			%	end
			% end
			
			if nargin<3
				par1	= 1;
			end
			for k=1:length(imapobj_v)
				imapobj	= imapobj_v(k);
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if ~MAP_OBJECTS(imapobj,1).h(i,1).Selected
						% Select the object:
						MAP_OBJECTS(imapobj,1).h(i,1).Selected	= 'on';
						% Display the source data of the selected object, if the object is visible:
						if MAP_OBJECTS(imapobj,1).h(i,1).Visible
							if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'source')
								% Source plot handles:
								source		= zeros(1,size(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source,1));
								source(1,:)	= [MAP_OBJECTS(imapobj,1).h(i,1).UserData.source.h];
								k_source		= ishandle(source);
								% Make the source plots visible:
								set(source(k_source),'Visible','on');
							end
						end
					end
				end
			end
			
			% Do not update MAP_OBJECTS_TABLE: not necessary!
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'deselect'
			
			if nargin<3
				par1	= 1;
			end
			for k=1:length(imapobj_v)
				imapobj	= imapobj_v(k);
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if MAP_OBJECTS(imapobj,1).h(i,1).Selected
						% Deselect the object:
						MAP_OBJECTS(imapobj,1).h(i,1).Selected	= 'off';
						% Hide the source data of the selected object:
						if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'source')
							% Source plot handles:
							source		= zeros(1,size(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source,1));
							source(1,:)	= [MAP_OBJECTS(imapobj,1).h(i,1).UserData.source.h];
							k_source		= ishandle(source);
							% Make the source plots invisible:
							set(source(k_source),'Visible','off');
						end
					end
				end
			end
			
			% Do not update MAP_OBJECTS_TABLE: not necessary!
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'duplicate'
			
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf(['There exists no map where to plot the objects.\n',...
					'Create the map first.']));
			end
			dx		= par1;
			dy		= par2;
			
			% Delete legend:
			if length(imapobj_v)>1
				legend(GV_H.ax_2dmap,'off');
			end
			
			% Delete objects in descending order!
			imapobj_v	= sort(unique(imapobj_v),'descend');
			for k=1:length(imapobj_v)
				imapobj	= imapobj_v(k);
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=max(5,GV.waitbar_dtupdate)
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				% Duplicate:
				imapobj_new						= size(MAP_OBJECTS,1)+1;
				MAP_OBJECTS(imapobj_new,1)	= MAP_OBJECTS(imapobj,1);
				if MAP_OBJECTS(imapobj_new,1).iobj<0
					MAP_OBJECTS(imapobj_new,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
				end
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					switch MAP_OBJECTS(imapobj,1).h(i,1).Type
						case 'polygon'
							poly			= translate(MAP_OBJECTS(imapobj,1).h(i,1).Shape,dx,dy);
							ud				= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
							ud.shape0	= poly;
							source		= copy_source(ud);			% Create a new source data plot
							if ~isempty(source)
								ud.source		= source;
							end
							MAP_OBJECTS(imapobj_new,1).h(i,1)	= plot(GV_H.ax_2dmap,poly,...
								'EdgeColor',MAP_OBJECTS(imapobj,1).h(i,1).EdgeColor,...
								'FaceColor',MAP_OBJECTS(imapobj,1).h(i,1).FaceColor,...
								'EdgeAlpha',MAP_OBJECTS(imapobj,1).h(i,1).EdgeAlpha,...
								'FaceAlpha',MAP_OBJECTS(imapobj,1).h(i,1).FaceAlpha,...
								'Visible',MAP_OBJECTS(imapobj,1).h(i,1).Visible,...
								'LineStyle',MAP_OBJECTS(imapobj,1).h(i,1).LineStyle,...
								'LineWidth',MAP_OBJECTS(imapobj,1).h(i,1).LineWidth,...
								'UserData',ud,...
								'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
						case 'line'
							xy_line		= [MAP_OBJECTS(imapobj,1).h(i,1).XData(:) MAP_OBJECTS(imapobj,1).h(i,1).YData(:)];
							xy_line		= xy_line+[dx*ones(size(xy_line,1),1) dy*ones(size(xy_line,1),1)];
							ud				= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
							ud.xy0		= xy_line;
							source		= copy_source(ud);			% Create a new source data plot
							if ~isempty(source)
								ud.source		= source;
							end
							MAP_OBJECTS(imapobj_new,1).h(i,1)	= plot(GV_H.ax_2dmap,xy_line(:,1),xy_line(:,2),...
								'Color'     ,MAP_OBJECTS(imapobj,1).h(i,1).Color,...
								'LineStyle' ,MAP_OBJECTS(imapobj,1).h(i,1).LineStyle,...
								'LineWidth' ,MAP_OBJECTS(imapobj,1).h(i,1).LineWidth,...
								'Marker'    ,MAP_OBJECTS(imapobj,1).h(i,1).Marker,...
								'MarkerSize',MAP_OBJECTS(imapobj,1).h(i,1).MarkerSize,...
								'UserData'  ,ud,...
								'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
					end
				end
				% Create/modify legend:
				if isscalar(imapobj_v)
					create_legend_mapfigure;
				end
				% Center point:
				[x,y]	= map_objects_center(imapobj_new);
				MAP_OBJECTS(imapobj_new,1).x	= x;
				MAP_OBJECTS(imapobj_new,1).y	= y;
				% Select the duplicated object:
				plot_modify('deselect',imapobj,0);
				plot_modify('select',imapobj_new,0);
				% Arrange imapobj_new (includes also display_map_objects):
				if APP.AutoSortNewMapObjects_Menu.Checked
					arrange_map_objects(...
						imapobj+1,...					% position after the arrangement
						imapobj_new);					% position before the arrangement
				end
			end
			
			% Create/modify legend:
			if length(imapobj_v)>1
				create_legend_mapfigure;
			end
			
			% Update MAP_OBJECTS_TABLE: already executed by arrange_map_objects
			if ~APP.AutoSortNewMapObjects_Menu.Checked
				display_map_objects;
			end
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'scale'
			
			sx		= par1;
			sy		= par2;
			for k=1:length(imapobj_v)
				imapobj								= imapobj_v(k);
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				MAP_OBJECTS(imapobj,1).mod		= true;
				% Center point:
				[x,y]	= map_objects_center(imapobj);
				% Scale:
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					switch MAP_OBJECTS(imapobj,1).h(i,1).Type
						case 'polygon'
							MAP_OBJECTS(imapobj,1).h(i,1).Shape	= scale(MAP_OBJECTS(imapobj,1).h(i,1).Shape,[sx sy],[x y]);
						case 'line'
							x_line										= MAP_OBJECTS(imapobj,1).h(i,1).XData(:);
							y_line										= MAP_OBJECTS(imapobj,1).h(i,1).YData(:);
							MAP_OBJECTS(imapobj,1).h(i,1).XData	= sx*(x_line-x)+x;
							MAP_OBJECTS(imapobj,1).h(i,1).YData	= sy*(y_line-y)+y;
					end
				end
			end
			
			% Changing .Shape, .XData, .YData, .mod, .x or .y does not require updating the table!
			% Update MAP_OBJECTS_TABLE:
			% display_map_objects(imapobj_v);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'set_dim'
			
			% Check imapobj_v:
			if length(imapobj_v)~=1
				errormessage(sprintf(['Error:\n',...
					'Exactly one object must be selected to use this function.']));
			end
			imapobj		= imapobj_v;
			
			% Current dimensions:
			xmin0				= 1e10;
			ymin0				= 1e10;
			xmax0				= -1e10;
			ymax0				= -1e10;
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				switch MAP_OBJECTS(imapobj,1).h(i,1).Type
					case 'polygon'
						[xlim,ylim]		= boundingbox(MAP_OBJECTS(imapobj,1).h(i,1).Shape);
					case 'line'
						x_line			= MAP_OBJECTS(imapobj,1).h(i,1).XData(:);
						y_line			= MAP_OBJECTS(imapobj,1).h(i,1).YData(:);
						xlim				= [min(x_line) max(x_line)];
						ylim				= [min(y_line) max(y_line)];
				end
				xmin0				= min(xmin0,xlim(1));
				ymin0				= min(ymin0,ylim(1));
				xmax0				= max(xmax0,xlim(2));
				ymax0				= max(ymax0,ylim(2));
			end
			dimx0				= xmax0-xmin0;
			dimy0				= ymax0-ymin0;
			
			% Enter the data:
			definput		= {num2str(dimx0);num2str(dimy0)};
			prompt		= {...
				'Dimension x (width) / mm';...
				'Dimension y (depth) / mm'};
			dlgtitle		= 'Enter dimensions';
			warntext		= 'xxxxx';
			while ~isempty(warntext)
				answer		= inputdlg_local(prompt,dlgtitle,1,definput);
				if size(answer,1)~=2
					if ~stateisbusy
						display_on_gui('state','','notbusy');
					end
					return
				end
				warntext		= '';
				if    ~isempty(strfind(answer{1,1},','))||...
						~isempty(strfind(answer{2,1},','))
					warntext	= sprintf([...
						'Error:\n',...
						'Invalid character '',''.\n',...
						'Use the decimal point ''.'' as decimal separator.']);
				else
					dimx		= str2double(answer{1,1});
					dimy		= str2double(answer{2,1});
					if    any(isnan(dimx))||...
							any(isnan(dimy))
						warntext	= sprintf([...
							'Error:\n',...
							'Invalid values.\n',...
							'You must enter numbers.']);
					end
				end
				if ~isempty(warntext)
					if isfield(GV_H.warndlg,'plot_modify')
						if ishandle(GV_H.warndlg.plot_modify)
							close(GV_H.warndlg.plot_modify);
						end
					end
					warntext	= sprintf('%s\nPress OK to repeat.',warntext);
					GV_H.warndlg.plot_modify		= warndlg(warntext,'Warning');
					GV_H.warndlg.plot_modify.Tag	= 'maplab3d_figure';
					while ishandle(GV_H.warndlg.plot_modify)
						pause(0.2);
					end
				end
			end
			
			% Change the dimensions:
			MAP_OBJECTS(imapobj,1).mod		= true;
			% Scale factors:
			sx		= dimx/dimx0;
			sy		= dimy/dimy0;
			% Center point:
			x		= (xmax0+xmin0)/2;
			y		= (ymax0+ymin0)/2;
			% Scale:
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				switch MAP_OBJECTS(imapobj,1).h(i,1).Type
					case 'polygon'
						MAP_OBJECTS(imapobj,1).h(i,1).Shape	= scale(MAP_OBJECTS(imapobj,1).h(i,1).Shape,[sx sy],[x y]);
					case 'line'
						x_line										= MAP_OBJECTS(imapobj,1).h(i,1).XData(:);
						y_line										= MAP_OBJECTS(imapobj,1).h(i,1).YData(:);
						MAP_OBJECTS(imapobj,1).h(i,1).XData	= sx*(x_line-x)+x;
						MAP_OBJECTS(imapobj,1).h(i,1).YData	= sy*(y_line-y)+y;
				end
			end
			
			% Changing .Shape, .XData, .YData, .mod, .x or .y does not require updating the table!
			% Update MAP_OBJECTS_TABLE:
			% display_map_objects(imapobj_v);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'delete'
			
			% User confirmation:
			if isequal(imapobj0_v,-1)
				answer	= [];
				while isempty(answer)
					question	= 'Delete all selected objects?';
					answer	= questdlg_local(question,'Continue?','Continue','Cancel','Cancel');
				end
				if strcmp(answer,'Cancel')
					if ~stateisbusy
						display_on_gui('state','','notbusy');
					end
					return
				end
			end
			
			% Delete objects in descending order!
			imapobj_v	= sort(unique(imapobj_v),'descend');
			for k=1:length(imapobj_v)
				imapobj	= imapobj_v(k);
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				iobj	= MAP_OBJECTS(imapobj).iobj;
				
				% Delete source data:
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if ishandle(MAP_OBJECTS(imapobj,1).h(i,1))
						if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'source')
							for ksource=1:size(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source,1)
								if ishandle(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source(ksource,1).h)
									% Delete source data:
									% Every map object has its own source plot, so it can be deleted:
									delete(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source(ksource,1).h);
								end
							end
						end
					end
				end
				
				% Check: is there another object on the map with this object number:
				if iobj>0
					iobj_remains_element_of_map	= false;
					for i=1:size(MAP_OBJECTS,1)
						if (i~=imapobj)&&(MAP_OBJECTS(i,1).iobj==iobj)
							iobj_remains_element_of_map	= true;
							break
						end
					end
				end
				
				% Delete:
				delete(MAP_OBJECTS(imapobj).h);
				if iobj>0
					if ~iobj_remains_element_of_map
						OSMDATA.iobj.node(    OSMDATA.iobj.node    ==iobj)	= 0;
						OSMDATA.iobj.way(     OSMDATA.iobj.way     ==iobj)	= 0;
						OSMDATA.iobj.relation(OSMDATA.iobj.relation==iobj)	= 0;
					end
				end
				MAP_OBJECTS		= MAP_OBJECTS((1:length(MAP_OBJECTS))~=imapobj);
				
			end
			
			% Update MAP_OBJECTS_TABLE:
			display_map_objects;				% Do not delete, is used by other actions!
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'ungroup'
			
			% Delete legend:
			legend(GV_H.ax_2dmap,'off');
			
			imapobj_delete_v		= [];
			size_map_objects_0	= size(MAP_OBJECTS,1);
			for k=1:length(imapobj_v)
				imapobj						= imapobj_v(k);
				if size(MAP_OBJECTS(imapobj,1).h,1)>1
					
					% Sort elements of a group by object priority:
					prio_hi_v		= [];
					for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
						ud					= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
						if isfield(ud,'prio')
							prio_hi_v	= [prio_hi_v;ud.prio];
						else
							prio_hi_v	= [prio_hi_v;0];
						end
					end
					[~,i_v]				= sort(prio_hi_v);
					for ih=1:size(MAP_OBJECTS(imapobj,1).h,1)
						% Create first the objects with the lowest priority:
						i				= i_v(ih);
						% polygons to delete:
						imapobj_delete_v		= [imapobj_delete_v;imapobj];
						% Waitbar:
						if waitbar_activ
							if etime(clock,waitbar_t1)>=max(5,GV.waitbar_dtupdate)
								waitbar_t1	= clock;
								progress_i	= (i-1)/size(MAP_OBJECTS(imapobj,1).h,1)/length(imapobj_v);
								progress		= min((k-1)/length(imapobj_v)+progress_i,1);
								set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
								drawnow;
							end
						end
						% New line:
						imapobj_new				= size(MAP_OBJECTS,1)+1;
						if MAP_OBJECTS(imapobj,1).iobj<0
							imapobj_new_iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
						else
							imapobj_new_iobj	= MAP_OBJECTS(imapobj,1).iobj;
						end
						ud							= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
						source					= copy_source(ud);			% Create a new source data plot
						if ~isempty(source)
							ud.source			= source;
						end
						switch MAP_OBJECTS(imapobj,1).h(i,1).Type
							case 'polygon'
								% Plot the preview as polygon:
								if ~ishandle(GV_H.ax_2dmap)
									errormessage(sprintf(['There exists no map where to plot the objects.\n',...
										'Create the map first.']));
								end
								h_poly	= plot(GV_H.ax_2dmap,MAP_OBJECTS(imapobj,1).h(i,1).Shape,...
									'EdgeColor',MAP_OBJECTS(imapobj,1).h(i,1).EdgeColor,...
									'FaceColor',MAP_OBJECTS(imapobj,1).h(i,1).FaceColor,...
									'EdgeAlpha',MAP_OBJECTS(imapobj,1).h(i,1).EdgeAlpha,...
									'FaceAlpha',MAP_OBJECTS(imapobj,1).h(i,1).FaceAlpha,...
									'Visible'  ,MAP_OBJECTS(imapobj,1).h(i,1).Visible,...
									'LineStyle',MAP_OBJECTS(imapobj,1).h(i,1).LineStyle,...
									'LineWidth',MAP_OBJECTS(imapobj,1).h(i,1).LineWidth,...
									'UserData',ud,...
									'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
								% Save relevant data in the structure MAP_OBJECTS:
								[xcenter,ycenter]						= centroid(MAP_OBJECTS(imapobj,1).h(i,1).Shape);
								MAP_OBJECTS(imapobj_new,1).disp	= MAP_OBJECTS(imapobj,1).disp;
								MAP_OBJECTS(imapobj_new,1).h		= h_poly;
								MAP_OBJECTS(imapobj_new,1).iobj	= imapobj_new_iobj;
								MAP_OBJECTS(imapobj_new,1).dscr	= MAP_OBJECTS(imapobj,1).dscr;
								MAP_OBJECTS(imapobj_new,1).x		= xcenter;
								MAP_OBJECTS(imapobj_new,1).y		= ycenter;
								MAP_OBJECTS(imapobj_new,1).text	= MAP_OBJECTS(imapobj,1).text;
								MAP_OBJECTS(imapobj_new,1).mod	= false;
								MAP_OBJECTS(imapobj_new,1).cncl	= MAP_OBJECTS(imapobj,1).cncl;
								MAP_OBJECTS(imapobj_new,1).cnuc	= MAP_OBJECTS(imapobj,1).cnuc;
								MAP_OBJECTS(imapobj_new,1).vis0	= 1*MAP_OBJECTS(imapobj,1).h(i,1).Visible;
							case 'line'
								% Plot the preview as line:
								xdata		= MAP_OBJECTS(imapobj,1).h(i,1).XData;
								ydata		= MAP_OBJECTS(imapobj,1).h(i,1).YData;
								if ~ishandle(GV_H.ax_2dmap)
									errormessage(sprintf(['There exists no map where to plot the objects.\n',...
										'Create the map first.']));
								end
								MAP_OBJECTS(imapobj_new,1).h	= plot(GV_H.ax_2dmap,...
									xdata,...
									ydata,...
									'Color'     ,MAP_OBJECTS(imapobj,1).h(i,1).Color,...
									'Visible'   ,MAP_OBJECTS(imapobj,1).h(i,1).Visible,...
									'LineStyle' ,MAP_OBJECTS(imapobj,1).h(i,1).LineStyle,...
									'LineWidth' ,MAP_OBJECTS(imapobj,1).h(i,1).LineWidth,...
									'Marker'    ,MAP_OBJECTS(imapobj,1).h(i,1).Marker,...
									'MarkerSize',MAP_OBJECTS(imapobj,1).h(i,1).MarkerSize,...
									'UserData'  ,ud,...
									'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
								% Center point:
								if isscalar(xdata)
									MAP_OBJECTS(imapobj_new,1).x			= xdata;
									MAP_OBJECTS(imapobj_new,1).y			= ydata;
								else
									if    (abs(xdata(1)-xdata(end))<GV.tol_1)&&...
											(abs(ydata(1)-ydata(end))<GV.tol_1)
										% Closed line:
										MAP_OBJECTS(imapobj_new,1).x		= mean(xdata(2:end));
										MAP_OBJECTS(imapobj_new,1).y		= mean(ydata(2:end));
									else
										MAP_OBJECTS(imapobj_new,1).x		= mean(xdata);
										MAP_OBJECTS(imapobj_new,1).y		= mean(ydata);
									end
								end
								% Save relevant data in the structure MAP_OBJECTS:
								MAP_OBJECTS(imapobj_new,1).disp	= MAP_OBJECTS(imapobj,1).disp;
								MAP_OBJECTS(imapobj_new,1).iobj	= imapobj_new_iobj;
								MAP_OBJECTS(imapobj_new,1).dscr	= MAP_OBJECTS(imapobj,1).dscr;
								MAP_OBJECTS(imapobj_new,1).text	= MAP_OBJECTS(imapobj,1).text;
								MAP_OBJECTS(imapobj_new,1).mod	= false;
								MAP_OBJECTS(imapobj_new,1).cncl	= MAP_OBJECTS(imapobj,1).cncl;
								MAP_OBJECTS(imapobj_new,1).cnuc	= MAP_OBJECTS(imapobj,1).cnuc;
								MAP_OBJECTS(imapobj_new,1).vis0	= 1*MAP_OBJECTS(imapobj,1).h(i,1).Visible;
						end
						
						% Select the ungrouped objects:
						plot_modify('select',imapobj_new,0);
						
					end
				end
			end
			
			% Create/modify legend:
			create_legend_mapfigure;
			
			% Number of new map objects:
			no_new_map_objects	= size(MAP_OBJECTS,1)-size_map_objects_0;
			
			% Delete original polygons:
			if ~isempty(imapobj_delete_v)
				% Delete objects (MAP_OBJECTS_TABLE will be updated also):
				plot_modify('delete',unique(imapobj_delete_v));		% Includes also display_map_objects
			else
				% Update MAP_OBJECTS_TABLE:
				display_map_objects;
			end
			
			% Arrange the new map objects:
			if no_new_map_objects>=1
				% Plot numbers of the new map objects:
				imapobj_new_v		= ((size(MAP_OBJECTS,1)-no_new_map_objects+1):size(MAP_OBJECTS,1))';
				% Arrange the new map objects (includes also display_map_objects):
				if APP.AutoSortNewMapObjects_Menu.Checked
					arrange_map_objects(...
						min(imapobj_v),...			% pos. after the arrangement
						imapobj_new_v);				% pos. before the arrangement
				end
				% Update MAP_OBJECTS_TABLE: already executed by arrange_map_objects
				if ~APP.AutoSortNewMapObjects_Menu.Checked
					display_map_objects;
				end
			end
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'group'
			
			% User confirmation:
			if isequal(imapobj0_v,-1)
				answer	= [];
				while isempty(answer)
					question	= sprintf([...
						'Only lines, areas, symbols, texts and previews\n',...
						'are grouped if they have\n',...
						'- the same type (line/polygon),\n',...
						'- the same values ObjNo (if>=0),\n',...
						'- the same values Text/Tag,\n',...
						'- the same values DispAs,\n',...
						'- the same color number of cutting lines and\n',...
						'- the same color number of united equal colors\n',...
						'Texts (DispAs=text) are only grouped if they:\n',...
						'- consist of one text foreground and\n',...
						'  one text background that overlap\n',...
						'  (more text objects in one group are not allowed),\n',...
						'- have the same character style number,\n',...
						'- have the same character style settings (fontsize,..),\n',...
						'- have the same rotation angle.\n',...
						'Symbols (DispAs=symbol) are only grouped if they:\n',...
						'- consist of one symbol foreground and\n',...
						'  one symbol background that overlap\n',...
						'  (more symbol objects in one group are not allowed),\n',...
						'- have the same symbol number,\n',...
						'- have the same rotation angle.\n',...
						'Group all selected objects?']);
					answer	= questdlg_local(question,'Continue?','Continue','Cancel','Cancel');
				end
				if strcmp(answer,'Cancel')
					if ~stateisbusy
						display_on_gui('state','','notbusy');
					end
					return
				end
			end
			
			imapobj_delete_v	= [];
			while ~isempty(imapobj_v)
				k				= 0;
				k_delete		= [];
				while k<length(imapobj_v)
					k				= k+1;
					k_delete		= [k_delete;k];
					% Waitbar:
					if waitbar_activ
						if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
							waitbar_t1	= clock;
							progress		= min((k-1)/length(imapobj_v),1);
							set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
							drawnow;
						end
					end
					
					% Create a new map object:
					imapobj_new		= size(MAP_OBJECTS,1)+1;
					MAP_OBJECTS(imapobj_new,1)			= MAP_OBJECTS(imapobj_v(k),1);
					if MAP_OBJECTS(imapobj_new,1).iobj<0
						MAP_OBJECTS(imapobj_new,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
					end
					
					% Add all similar objects to the first one:
					imapobj_delete_v	= [imapobj_delete_v;imapobj_v(k)];
					for k2=(k+1):length(imapobj_v)
						group_texts		= true;
						if    isequal(lower(MAP_OBJECTS(imapobj_v(k ),1).disp),'text')&&...
								isequal(lower(MAP_OBJECTS(imapobj_v(k2),1).disp),'text')
							% Group only texts that:
							% - overlap
							% - consist of one text foreground and one text background
							%   More text objects in one group are not allowed.
							% - have the same character style number
							% - have the same character style settings
							if    (length(MAP_OBJECTS(imapobj_v(k ),1).h)~=1)||...
									(length(MAP_OBJECTS(imapobj_v(k2),1).h)~=1)
								% The 2 text objects consist of more than 1 polygon:
								group_texts		= false;
							else
								ud		= MAP_OBJECTS(imapobj_v(k ),1).h.UserData;
								ud2	= MAP_OBJECTS(imapobj_v(k2),1).h.UserData;
								if ud.level==ud2.level
									% The 2 text objects both consist of a foreground or both of a background:
									group_texts		= false;
								else
									if ud.chstno~=ud2.chstno
										% The 2 text objects do not have the same character style number:
										group_texts		= false;
									else
										if ~isequal(ud.chstsettings,ud2.chstsettings)
											% The 2 text objects do not have the same character style settings:
											group_texts		= false;
										else
											if abs(ud.rotation-ud2.rotation)>GV.tol_1
												% The 2 text objects do not have the same rotation angle:
												group_texts		= false;
											else
												if ~overlaps(...
														MAP_OBJECTS(imapobj_v(k ),1).h.Shape,...
														MAP_OBJECTS(imapobj_v(k2),1).h.Shape)
													% The 2 text objects do not overlap:
													group_texts		= false;
												end
											end
										end
									end
								end
							end
						end
						group_symbols		= true;
						if    isequal(lower(MAP_OBJECTS(imapobj_v(k ),1).disp),'symbol')&&...
								isequal(lower(MAP_OBJECTS(imapobj_v(k2),1).disp),'symbol')
							% Group only symbols that:
							% - consist of one symbol foreground and one symbol background
							%   More symbol objects in one group are not allowed.
							% - have the same symbol number.
							if    (length(MAP_OBJECTS(imapobj_v(k ),1).h)~=1)||...
									(length(MAP_OBJECTS(imapobj_v(k2),1).h)~=1)
								% The 2 symbol objects consist of more than 1 polygon:
								group_symbols		= false;
							else
								ud		= MAP_OBJECTS(imapobj_v(k ),1).h.UserData;
								ud2	= MAP_OBJECTS(imapobj_v(k2),1).h.UserData;
								if ud.level==ud2.level
									% The 2 symbol objects both consist of a foreground or both of a background:
									group_symbols		= false;
								else
									if ud.isym~=ud2.isym
										% The 2 symbol objects do not have the same symbol number:
										group_symbols		= false;
									else
										if abs(ud.rotation-ud2.rotation)>GV.tol_1
											% The 2 symbol objects do not have the same rotation angle:
											group_symbols		= false;
										else
											if ~overlaps(...
													MAP_OBJECTS(imapobj_v(k ),1).h.Shape,...
													MAP_OBJECTS(imapobj_v(k2),1).h.Shape)
												% The 2 symbol objects do not overlap:
												group_symbols		= false;
											end
										end
									end
								end
							end
						end
						if   (isequal( MAP_OBJECTS(imapobj_v(k),1).iobj,MAP_OBJECTS(imapobj_v(k2),1).iobj)||...
								contains(lower(MAP_OBJECTS(imapobj_v(k),1).disp),'united equal colors')     ||...
								contains(lower(MAP_OBJECTS(imapobj_v(k),1).disp),'preview')                 ||...
								contains(lower(MAP_OBJECTS(imapobj_v(k),1).disp),'cutting line')                 )&&...
								group_texts                                                                       &&...
								group_symbols                                                                     &&...
								isequal( MAP_OBJECTS(imapobj_v(k),1).text,MAP_OBJECTS(imapobj_v(k2),1).text)      &&...
								strcmp(  MAP_OBJECTS(imapobj_v(k),1).disp,MAP_OBJECTS(imapobj_v(k2),1).disp)      &&...
								isequal( MAP_OBJECTS(imapobj_v(k),1).cncl,MAP_OBJECTS(imapobj_v(k2),1).cncl)      &&...
								isequal( MAP_OBJECTS(imapobj_v(k),1).cnuc,MAP_OBJECTS(imapobj_v(k2),1).cnuc)      &&...
								strcmp(  MAP_OBJECTS(imapobj_v(k),1).h(1,1).Type,MAP_OBJECTS(imapobj_v(k2),1).h(1,1).Type)
							for i=1:size(MAP_OBJECTS(imapobj_v(k2),1).h,1)
								MAP_OBJECTS(imapobj_new,1).h(end+1,1)	= MAP_OBJECTS(imapobj_v(k2),1).h(i,1);
							end
							k_delete			= [k_delete;k2];
							imapobj_delete_v	= [imapobj_delete_v;imapobj_v(k2)];
						end
					end
					
					% Assign the center point:
					[x,y]		= map_objects_center(imapobj_v(k));
					MAP_OBJECTS(imapobj_new,1).x	= x;
					MAP_OBJECTS(imapobj_new,1).y	= y;
					
					% End of the inner while-loop:
					k	= length(imapobj_v);
					
				end
				imapobj_v(k_delete)	= [];
			end
			
			% Delete lines in MAP_OBJECTS:
			MAP_OBJECTS(imapobj_delete_v,:)	= [];
			
			% Update MAP_OBJECTS_TABLE:
			display_map_objects;
			
			%------------------------------------------------------------------------------------------------------------
		case 'mod_vertex'
			
			% Check whether imapobj_v is a scalar and the map object is a line:
			if length(imapobj_v)~=1
				errormessage(sprintf(['Error:\n',...
					'Exact one object must be selected to use this function.']));
			end
			imapobj		= imapobj_v;
			if length(MAP_OBJECTS(imapobj,1).h)>1
				errormessage(sprintf(['Error:\n',...
					'The selected object PlotNo=%g consists\n',...
					'of a group of %g objects.\n',...
					'First you have to ungroup the object.'],imapobj,length(MAP_OBJECTS(imapobj,1).h)));
			end
			if ~strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'line')
				if ~(  strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'polygon')&&...
						(strcmp(par1,'move')||strcmp(par1,'insert')||strcmp(par1,'delvertices')))
					errormessage(sprintf(['Error:\n',...
						'The selected object PlotNo=%g is of the type "%s".\n',...
						'This function is only applicable on lines.'],imapobj,MAP_OBJECTS(imapobj,1).h(1,1).Type));
				end
			end
			
			delete_imapobj		= false;
			switch par1
				case 'add'
					% Add a new vertex:
					switch par2
						case 'first'
							% Add the new vertex at the beginning of the line:
							xdata				= [par3 MAP_OBJECTS(imapobj,1).h.XData];
							ydata				= [par4 MAP_OBJECTS(imapobj,1).h.YData];
						case 'last'
							xdata				= [MAP_OBJECTS(imapobj,1).h.XData par3];
							ydata				= [MAP_OBJECTS(imapobj,1).h.YData par4];
					end
					[xi,~] = polyxpoly(xdata,ydata,xdata,ydata,'unique');
					if (length(xi)~=length(xdata))           &&~(...
							(length(xi)==(length(xdata)-1))        &&...
							(abs(xdata(1,1)-xdata(end,1))<GV.tol_1)&&...
							(abs(ydata(1,1)-ydata(end,1))<GV.tol_1)     )
						errormessage(sprintf(['Error:\n',...
							'The new point (%g,%g) results in an\n',...
							'intersection with the existing line.'],par3,par4));
					end
					MAP_OBJECTS(imapobj,1).h.XData	= xdata;
					MAP_OBJECTS(imapobj,1).h.YData	= ydata;
					if length(MAP_OBJECTS(imapobj,1).h.XData)>1
						MAP_OBJECTS(imapobj,1).h.Marker		= 'none';
					end
					if    (abs(MAP_OBJECTS(imapobj,1).h.XData(1)-MAP_OBJECTS(imapobj,1).h.XData(end))<GV.tol_1)&&...
							(abs(MAP_OBJECTS(imapobj,1).h.YData(1)-MAP_OBJECTS(imapobj,1).h.YData(end))<GV.tol_1)
						% Closed line:
						MAP_OBJECTS(imapobj,1).x		= mean(MAP_OBJECTS(imapobj,1).h.XData(2:end));
						MAP_OBJECTS(imapobj,1).y		= mean(MAP_OBJECTS(imapobj,1).h.YData(2:end));
					else
						MAP_OBJECTS(imapobj,1).x		= mean(MAP_OBJECTS(imapobj,1).h.XData);
						MAP_OBJECTS(imapobj,1).y		= mean(MAP_OBJECTS(imapobj,1).h.YData);
					end
					
				case 'move'
					% Move a vertex:
					if strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'line')
						xdata0				= MAP_OBJECTS(imapobj,1).h.XData';
						ydata0				= MAP_OBJECTS(imapobj,1).h.YData';
					elseif strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'polygon')
						% Use the boundary-function (same method as in ButtonDownFcn_ax_2dmap.m):
						[xdata0,ydata0]	= boundary(MAP_OBJECTS(imapobj,1).h.Shape);
					else
						errormessage;
					end
					% Move vertex and check for intersection:
					i_v				= find(...				% if the start- and endpoint of a closed line has to be moved
						(abs(xdata0(par2,1)-xdata0)<GV.tol_1)&...
						(abs(ydata0(par2,1)-ydata0)<GV.tol_1)    );
					xdata				= xdata0;
					ydata				= ydata0;
					xdata(i_v,1)	= par3;
					ydata(i_v,1)	= par4;
					self_intersection_detected	= false;
					for i_i_v=1:length(i_v)
						i		= i_v(i_i_v);
						% Check for intersection of the line segment before vertex [xdata(i,1) ydata(i,1)]:
						if i>1
							[xi,yi] = polyxpoly(xdata,ydata,...
								[xdata(i-1,1) xdata(i,1)],...
								[ydata(i-1,1) ydata(i,1)],'unique');
							% The startpoint of the new line segment is not an intersection point:
							k_delete			= ((...
								(abs(xi-xdata(i-1,1))<GV.tol_1)&...
								(abs(yi-ydata(i-1,1))<GV.tol_1)    )|(...
								(abs(xi-xdata(i  ,1))<GV.tol_1)&...
								(abs(yi-ydata(i  ,1))<GV.tol_1)    )     );
							xi(k_delete)	= [];
							if ~isempty(xi)
								self_intersection_detected	= true;
								break
							end
						end
						% Check for intersection of the line segment after vertex [xdata(i,1) ydata(i,1)]:
						if i<(length(xdata)-1)
							[xi,yi] = polyxpoly(xdata,ydata,...
								[xdata(i,1) xdata(i+1,1)],...
								[ydata(i,1) ydata(i+1,1)],'unique');
							% The endpoint of the new line segment is not an intersection point:
							k_delete			= ((...
								(abs(xi-xdata(i  ,1))<GV.tol_1)&...
								(abs(yi-ydata(i  ,1))<GV.tol_1)    )|(...
								(abs(xi-xdata(i+1,1))<GV.tol_1)&...
								(abs(yi-ydata(i+1,1))<GV.tol_1)    )     );
							xi(k_delete)	= [];
							if ~isempty(xi)
								self_intersection_detected	= true;
								break
							end
						end
					end
					if self_intersection_detected
						errormessage(sprintf(['Error:\n',...
							'The new point (%g,%g) results in an\n',...
							'intersection with the existing line.'],par3,par4));
					end
					% Assign the result:
					if strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'line')
						MAP_OBJECTS(imapobj,1).h.XData	= xdata';
						MAP_OBJECTS(imapobj,1).h.YData	= ydata';
						if    (abs(MAP_OBJECTS(imapobj,1).h.XData(1)-MAP_OBJECTS(imapobj,1).h.XData(end))<GV.tol_1)&&...
								(abs(MAP_OBJECTS(imapobj,1).h.YData(1)-MAP_OBJECTS(imapobj,1).h.YData(end))<GV.tol_1)
							% Closed line:
							MAP_OBJECTS(imapobj,1).x		= mean(MAP_OBJECTS(imapobj,1).h.XData(2:end));
							MAP_OBJECTS(imapobj,1).y		= mean(MAP_OBJECTS(imapobj,1).h.YData(2:end));
						else
							MAP_OBJECTS(imapobj,1).x		= mean(MAP_OBJECTS(imapobj,1).h.XData);
							MAP_OBJECTS(imapobj,1).y		= mean(MAP_OBJECTS(imapobj,1).h.YData);
						end
					elseif strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'polygon')
						MAP_OBJECTS(imapobj,1).h.Shape	= polyshape(xdata,ydata,'KeepCollinearPoints',true);
						[xcenter,ycenter]						= centroid(MAP_OBJECTS(imapobj,1).h.Shape);
						MAP_OBJECTS(imapobj,1).x			= xcenter;
						MAP_OBJECTS(imapobj,1).y			= ycenter;
					else
						errormessage;
					end
					
				case 'delvertex'
					% Delete a vertex:
					if length(MAP_OBJECTS(imapobj,1).h.XData)>=2
						switch par2
							case 'first'
								% Delete the vertex at the beginning of the line:
								MAP_OBJECTS(imapobj,1).h.XData(1)		= [];
								MAP_OBJECTS(imapobj,1).h.YData(1)		= [];
							case 'last'
								% Delete the vertex at the end of the line:
								MAP_OBJECTS(imapobj,1).h.XData(end)	= [];
								MAP_OBJECTS(imapobj,1).h.YData(end)	= [];
						end
						if isscalar(MAP_OBJECTS(imapobj,1).h.XData)
							MAP_OBJECTS(imapobj,1).h.Marker		= GV.preview.Marker;
							MAP_OBJECTS(imapobj,1).h.MarkerSize	= GV.preview.MarkerSize;
							MAP_OBJECTS(imapobj,1).x				= MAP_OBJECTS(imapobj,1).h.XData;
							MAP_OBJECTS(imapobj,1).y				= MAP_OBJECTS(imapobj,1).h.YData;
						else
							if    (abs(MAP_OBJECTS(imapobj,1).h.XData(1)-MAP_OBJECTS(imapobj,1).h.XData(end))<GV.tol_1)&&...
									(abs(MAP_OBJECTS(imapobj,1).h.YData(1)-MAP_OBJECTS(imapobj,1).h.YData(end))<GV.tol_1)
								% Closed line:
								MAP_OBJECTS(imapobj,1).x		= mean(MAP_OBJECTS(imapobj,1).h.XData(2:end));
								MAP_OBJECTS(imapobj,1).y		= mean(MAP_OBJECTS(imapobj,1).h.YData(2:end));
							else
								MAP_OBJECTS(imapobj,1).x		= mean(MAP_OBJECTS(imapobj,1).h.XData);
								MAP_OBJECTS(imapobj,1).y		= mean(MAP_OBJECTS(imapobj,1).h.YData);
							end
						end
					end
					
				case 'close'
					% Close line: Set last vertex equal to first.
					if    (abs(MAP_OBJECTS(imapobj,1).h.XData(1)-MAP_OBJECTS(imapobj,1).h.XData(end))>GV.tol_1)||...
							(abs(MAP_OBJECTS(imapobj,1).h.YData(1)-MAP_OBJECTS(imapobj,1).h.YData(end))>GV.tol_1)
						% The line is not closed:
						[xi,~] = polyxpoly(...
							[MAP_OBJECTS(imapobj,1).h.XData(1);MAP_OBJECTS(imapobj,1).h.XData(end)],...
							[MAP_OBJECTS(imapobj,1).h.YData(1);MAP_OBJECTS(imapobj,1).h.YData(end)],...
							MAP_OBJECTS(imapobj,1).h.XData,...
							MAP_OBJECTS(imapobj,1).h.YData);
						if length(xi)>2
							errormessage(sprintf(['Error:\n',...
								'Closing the line results in an intersection.']));
						end
						% Close line: Set last vertex equal to first vertex:
						MAP_OBJECTS(imapobj,1).h.XData	= ...
							[MAP_OBJECTS(imapobj,1).h.XData(:);MAP_OBJECTS(imapobj,1).h.XData(1)];
						MAP_OBJECTS(imapobj,1).h.YData	= ...
							[MAP_OBJECTS(imapobj,1).h.YData(:);MAP_OBJECTS(imapobj,1).h.YData(1)];
					end
					
				case 'insert'
					% Insert one vertex between two vertices 1 and 2.
					if strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'line')
						xdata				= MAP_OBJECTS(imapobj,1).h.XData';
						ydata				= MAP_OBJECTS(imapobj,1).h.YData';
					elseif strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'polygon')
						% Use the boundary-function (same method as in ButtonDownFcn_ax_2dmap.m):
						[xdata,ydata]	= boundary(MAP_OBJECTS(imapobj,1).h.Shape);
					else
						errormessage;
					end
					imax				= length(xdata);
					i1_v				= find(...
						(abs(xdata(par2,1)-xdata)<GV.tol_1)&...
						(abs(ydata(par2,1)-ydata)<GV.tol_1)    );
					i2_v				= find(...
						(abs(xdata(par3,1)-xdata)<GV.tol_1)&...
						(abs(ydata(par3,1)-ydata)<GV.tol_1)    );
					for ii1=1:size(i1_v,1)
						i1					= i1_v(ii1,1);
						for ii2=1:size(i2_v,1)
							i2					= i2_v(ii2,1);
							if abs(i1-i2)==1
								if i1>i2
									i20	= i2;
									i2		= i1;
									i1		= i20;
								end
								% Now is: i2=i1+1
								c1		= xdata(i1,1)+1i*ydata(i1,1);
								c2		= xdata(i2,1)+1i*ydata(i2,1);
								c12	= c2-c1;
								c3		= c1+c12/2;
								xdata((i2+1):(imax+1))	= xdata(i2:imax);
								ydata((i2+1):(imax+1))	= ydata(i2:imax);
								xdata(i2,1)					= real(c3);
								ydata(i2,1)					= imag(c3);
							end
						end
					end
					if strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'line')
						MAP_OBJECTS(imapobj,1).h.XData	= xdata';
						MAP_OBJECTS(imapobj,1).h.YData	= ydata';
					elseif strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'polygon')
						MAP_OBJECTS(imapobj,1).h.Shape	= addboundary(polyshape(),xdata,ydata,'KeepCollinearPoints',true);
						% MAP_OBJECTS(imapobj,1).h.Shape.Vertices	= [xdata ydata];
					end
					
				case 'cut'
					% Cut line: If the line is closed delete the last vertex.
					if    (abs(MAP_OBJECTS(imapobj,1).h.XData(1)-MAP_OBJECTS(imapobj,1).h.XData(end))<GV.tol_1)&&...
							(abs(MAP_OBJECTS(imapobj,1).h.YData(1)-MAP_OBJECTS(imapobj,1).h.YData(end))<GV.tol_1)
						% The first point and the last point are equal: delete the last point:
						MAP_OBJECTS(imapobj,1).h.XData(end)		= [];
						MAP_OBJECTS(imapobj,1).h.YData(end)		= [];
					end
					
				case {'delvertices','split'}
					% Delete vertices and split the line (if par1='split').
					if strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'line')
						xdata				= MAP_OBJECTS(imapobj,1).h.XData';
						ydata				= MAP_OBJECTS(imapobj,1).h.YData';
					elseif strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'polygon')
						% Use the boundary-function (same method as in ButtonDownFcn_ax_2dmap.m):
						[xdata,ydata]	= boundary(MAP_OBJECTS(imapobj,1).h.Shape);
					else
						errormessage;
					end
					xleft			= min(par2,par4);
					xright		= max(par2,par4);
					ybottom		= min(par3,par5);
					ytop			= max(par3,par5);
					i_delete		= find(...
						(xdata>=xleft  )&...
						(xdata<=xright )&...
						(ydata>=ybottom)&...
						(ydata<=ytop   )    );
					if ~isempty(i_delete)
						if size(i_delete,1)<size(xdata,1)
							% The output is not empty:
							switch par1
								
								case 'delvertices'
									xdata(i_delete)	= [];
									ydata(i_delete)	= [];
									% Change the map object xy data:
									if strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'line')
										MAP_OBJECTS(imapobj,1).h.XData	= xdata';
										MAP_OBJECTS(imapobj,1).h.YData	= ydata';
										% LineStyle:
										if isscalar(xdata)
											MAP_OBJECTS(imapobj,1).h.Marker		= GV.preview.Marker;
											MAP_OBJECTS(imapobj,1).h.MarkerSize	= GV.preview.MarkerSize;
										end
									elseif strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'polygon')
										if length(xdata)>=3
											poly	= addboundary(polyshape(),xdata,ydata,...
												'KeepCollinearPoints',true,'Simplify',false);
											if ~issimplified(poly)
												errormessage(sprintf(['Error:\n',...
													'Deleting the vertices probably results in an\n',...
													'intersection with the rest of the boundary.']));
											end
											if numboundaries(poly)>=1
												MAP_OBJECTS(imapobj,1).h.Shape	= poly;
											else
												delete_imapobj		= true;
											end
										else
											delete_imapobj		= true;
										end
									end
									% Center point:
									if isscalar(xdata)
										MAP_OBJECTS(imapobj,1).x			= xdata;
										MAP_OBJECTS(imapobj,1).y			= ydata;
									else
										if    (abs(xdata(1)-xdata(end))<GV.tol_1)&&...
												(abs(ydata(1)-ydata(end))<GV.tol_1)
											% Closed line:
											MAP_OBJECTS(imapobj,1).x		= mean(xdata(2:end));
											MAP_OBJECTS(imapobj,1).y		= mean(ydata(2:end));
										else
											MAP_OBJECTS(imapobj,1).x		= mean(xdata);
											MAP_OBJECTS(imapobj,1).y		= mean(ydata);
										end
									end
									
								case 'split'
									% Split: there is only 1 preview line object, no group and no polygon
									% Split the line:
									xdata(i_delete)	= nan;
									ydata(i_delete)	= nan;
									[xdata,ydata]		= removeExtraNanSeparators(xdata,ydata);
									[xdata_c,ydata_c]	= polysplit(xdata,ydata);
									% If the first point and the last point are equal: connect the first and last segment:
									if size(xdata_c,1)>1
										if    (abs(xdata_c{1,1}(1,:)-xdata_c{end,1}(end,:))<GV.tol_1)&&...
												(abs(ydata_c{1,1}(1,:)-ydata_c{end,1}(end,:))<GV.tol_1)
											xdata_c{1,1}		= [xdata_c{end,1}(1:(end-1),:);xdata_c{1,1}];
											ydata_c{1,1}		= [ydata_c{end,1}(1:(end-1),:);ydata_c{1,1}];
											xdata_c(end,:)		= [];
											ydata_c(end,:)		= [];
										end
									end
									% Create a group of line segments:
									MAP_OBJECTS(imapobj,1).h(1,1).XData			= xdata_c{1,1}';
									MAP_OBJECTS(imapobj,1).h(1,1).YData			= ydata_c{1,1}';
									if isscalar(xdata_c{1,1})
										MAP_OBJECTS(imapobj,1).h(1,1).Marker	= GV.preview.Marker;
									else
										MAP_OBJECTS(imapobj,1).h(1,1).Marker	= 'none';
									end
									for i=2:size(xdata_c,1)
										if ~ishandle(GV_H.ax_2dmap)
											errormessage(sprintf(...
												'There exists no map where to plot the objects.\nCreate the map first.'));
										end
										if isscalar(xdata_c{i,1})
											marker		= GV.preview.Marker;
										else
											marker		= 'none';
										end
										MAP_OBJECTS(imapobj,1).h(i,1)		= plot(GV_H.ax_2dmap,...
											xdata_c{i,1}',...
											ydata_c{i,1}',...
											'Color'     ,MAP_OBJECTS(imapobj,1).h(1,1).Color,...
											'LineStyle' ,MAP_OBJECTS(imapobj,1).h(1,1).LineStyle,...
											'LineWidth' ,MAP_OBJECTS(imapobj,1).h(1,1).LineWidth,...
											'Marker'    ,marker,...
											'MarkerSize',MAP_OBJECTS(imapobj,1).h(1,1).MarkerSize,...
											'UserData'  ,MAP_OBJECTS(imapobj,1).h(1,1).UserData,...
											'ButtonDownFcn',MAP_OBJECTS(imapobj,1).h(1,1).ButtonDownFcn);
									end
									% Ugroup the line segments:
									if size(MAP_OBJECTS(imapobj,1).h,1)>1
										plot_modify('ungroup',imapobj);		% Includes also display_map_objects
									end
									
							end
						else
							% The output is empty:
							delete_imapobj		= true;
						end
						
						if delete_imapobj
							% Delete the whole object:
							answer	= [];
							while isempty(answer)
								question	= sprintf('Delete object number %1.0f?',imapobj);
								answer	= questdlg_local(question,'Continue?','Continue','Cancel','Cancel');
							end
							if strcmp(answer,'Cancel')
								if ~stateisbusy
									display_on_gui('state','','notbusy');
								end
								return
							end
							plot_modify('delete',imapobj);		% Includes also display_map_objects
						end
					end
					
			end
			
			% Update MAP_OBJECTS_TABLE:
			if ~delete_imapobj&&~strcmp(par1,'split')
				display_map_objects(imapobj);
			end
			
			%------------------------------------------------------------------------------------------------------------
		case 'new_line'
			% par1	x_v_prev				3
			% par2	y_v_prev				4
			% par3	dscr_prev			5
			% par4	text_prev			6
			
			% column vectors:
			x_v_prev				= par1(:);
			y_v_prev				= par2(:);
			if nargin>=5
				cncl				= 0;
				dscr_prev		= par3;
			else
				% Color number of cutting lines (=0: normal preview):
				cncl				= get_colno_cuttingline;
				% Preview dscr_prev:
				if cncl==0
					dscr_prev	= APP.Mod_LV_NewLine_Descr_EditField.Value;
				else
					dscr_prev	= 'Preview cutting line';
				end
			end
			if nargin<=5
				text_prev		= {''};
			else
				text_prev		= par4;
				if ~iscell(text_prev)
					text_prev	= {text_prev};
				end
			end
			% New line number in MAP_OBJECTS:
			imapobj_new	= size(MAP_OBJECTS,1)+1;
			% Userdata:
			ud					= [];
			if cncl>0
				ud.color_no		= cncl;
				ud.color_no_pp	= cncl;
			end
			ud.in				= [];
			ud.iw				= [];
			ud.ir				= [];
			ud.rotation		= 0;
			ud.xy0			= [x_v_prev y_v_prev];
			% Plot the preview as polygon:
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
			end
			if isscalar(x_v_prev)
				marker		= GV.preview.Marker;
			else
				marker		= 'none';
			end
			h_preview		= plot(GV_H.ax_2dmap,x_v_prev,y_v_prev,...
				'Color'     ,GV.preview.Color,...
				'LineStyle' ,GV.preview.LineStyle,...
				'LineWidth' ,GV.preview.LineWidth,...
				'Marker'    ,marker,...
				'MarkerSize',GV.preview.MarkerSize,...
				'UserData'  ,ud,...
				'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
			% Create/modify legend:
			create_legend_mapfigure;
			% Save relevant data in the structure MAP_OBJECTS:
			if cncl==0
				MAP_OBJECTS(imapobj_new,1).disp	= 'preview line';
			else
				MAP_OBJECTS(imapobj_new,1).disp	= 'preview cutting line';
			end
			MAP_OBJECTS(imapobj_new,1).h		= h_preview;
			if ~isfield(MAP_OBJECTS,'iobj')
				MAP_OBJECTS(imapobj_new,1).iobj	= -1;
			else
				MAP_OBJECTS(imapobj_new,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
			end
			MAP_OBJECTS(imapobj_new,1).dscr	= dscr_prev;
			MAP_OBJECTS(imapobj_new,1).x		= mean(x_v_prev);
			MAP_OBJECTS(imapobj_new,1).y		= mean(y_v_prev);
			MAP_OBJECTS(imapobj_new,1).text	= text_prev;
			MAP_OBJECTS(imapobj_new,1).mod	= false;
			MAP_OBJECTS(imapobj_new,1).cncl	= cncl;
			MAP_OBJECTS(imapobj_new,1).cnuc	= 0;
			if cncl==0
				MAP_OBJECTS(imapobj_new,1).vis0	= 1;
			else
				MAP_OBJECTS(imapobj_new,1).vis0	= 0;
			end
			
			% Update MAP_OBJECTS_TABLE:
			plot_modify('deselect',-1,0);
			plot_modify('select',imapobj_new,0);
			display_map_objects;
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'new_poly'
			% par1	preview polygon
			% par2	dscr_prev
			% par3	text_prev
			% par4	select_prev
			
			if nargin<=3
				dscr_prev		= '';
			else
				dscr_prev		= par2;
			end
			if nargin<=4
				text_prev		= {''};
			else
				text_prev		= par3;
				if ~iscell(text_prev)
					text_prev	= {text_prev};
				end
			end
			if nargin<=5
				select_prev	= false;
			else
				select_prev	= par4;
			end
			% New line number in MAP_OBJECTS:
			imapobj_new		= size(MAP_OBJECTS,1)+1;
			imapobj_new_v	= imapobj_new;
			% Userdata:
			ud					= [];
			ud.color_no		= 0;
			ud.color_no_pp	= 0;
			ud.in				= [];
			ud.iw				= [];
			ud.ir				= [];
			ud.rotation		= 0;
			preview			= struct;
			i_preview		= 0;
			for r=1:size(par1,1)
				for c=1:size(par1,2)
					if numboundaries(par1(r,c))>0
						i_preview		= i_preview+1;
						ud.shape0		= par1(r,c);
						% Plot the preview as polygon:
						if ~ishandle(GV_H.ax_2dmap)
							errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
						end
						preview(i_preview,1).h		= plot(GV_H.ax_2dmap,par1(r,c),...
							'EdgeColor',GV.preview.EdgeColor,...
							'FaceColor',GV.preview.FaceColor,...
							'EdgeAlpha', GV.visibility.show.edgealpha,...
							'FaceAlpha',GV.visibility.show.facealpha,...
							'Visible'  ,'on',...
							'LineStyle',GV.preview.LineStyle,...
							'LineWidth',GV.preview.LineWidth,...
							'UserData',ud,...
							'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
					end
				end
			end
			% Create/modify legend:
			create_legend_mapfigure;
			% Save relevant data in the structure MAP_OBJECTS:
			[xcenter,ycenter]						= centroid(par1);
			MAP_OBJECTS(imapobj_new,1).disp	= 'preview polygon';
			for i=1:size(preview,1)
				MAP_OBJECTS(imapobj_new,1).h(i,1)	= preview(i,1).h;
			end
			if ~isfield(MAP_OBJECTS,'iobj')
				MAP_OBJECTS(imapobj_new,1).iobj	= -1;
			else
				MAP_OBJECTS(imapobj_new,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
			end
			MAP_OBJECTS(imapobj_new,1).dscr	= dscr_prev;
			MAP_OBJECTS(imapobj_new,1).x		= xcenter;
			MAP_OBJECTS(imapobj_new,1).y		= ycenter;
			MAP_OBJECTS(imapobj_new,1).text	= text_prev;
			MAP_OBJECTS(imapobj_new,1).mod	= false;
			MAP_OBJECTS(imapobj_new,1).cncl	= 0;
			MAP_OBJECTS(imapobj_new,1).cnuc	= 0;
			MAP_OBJECTS(imapobj_new,1).vis0	= 1;
			
			% Update MAP_OBJECTS_TABLE:
			plot_modify('deselect',-1,0);
			if select_prev
				plot_modify('select',imapobj_new,0);
			end
			display_map_objects;
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'connect'
			
			% Delete legend:
			if length(imapobj_v)>1
				legend(GV_H.ax_2dmap,'off');
			end
			
			% User input: Maximum distance at which the start and end points of two lines are connected:
			prompt	= {sprintf([...
				'Enter the maximum distance at which the start\n',...
				'and end points of two lines will be connected:'])};
			dlgtitle	= 'Enter maximum distance';
			dims		= 1;
			definput	= {sprintf('%g',GV.tol_connectways_manually)};
			answer	= inputdlg_local(prompt,dlgtitle,dims,definput);
			if ~isempty(answer)
				tol	= str2double(answer);
				if isnan(tol)||isempty(tol)||(length(tol)>1)
					if ~stateisbusy
						display_on_gui('state','','notbusy');
					end
					return
				end
				tol	= max(GV.tol_1,tol);
			else
				if ~stateisbusy
					display_on_gui('state','','notbusy');
				end
				return
			end
			GV.tol_connectways_manually	= tol;
			
			% Connect the ways:
			imapobj_delete_v		= [];
			size_map_objects_0	= size(MAP_OBJECTS,1);
			no_lines_to_connect	= 0;
			connways_preview		= connect_ways([]);
			connways_dscr			= '';
			connways_text			= '';
			iobj_v					= [];
			cncl_v					= [];
			relid_v					= uint64([]);
			for k=1:length(imapobj_v)
				imapobj			= imapobj_v(k);
				cncl_v			= [cncl_v MAP_OBJECTS(imapobj,1).cncl];
				try_to_connect	= true;
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if ~strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'line')
						try_to_connect	= false;
					else
						if length(MAP_OBJECTS(imapobj,1).h(i,1).XData)<=1
							try_to_connect	= false;				% The line consists of a single node.
						end
						if    (abs(MAP_OBJECTS(imapobj,1).h(i,1).XData(1)-MAP_OBJECTS(imapobj,1).h(i,1).XData(end))<GV.tol_1)&&...
								(abs(MAP_OBJECTS(imapobj,1).h(i,1).YData(1)-MAP_OBJECTS(imapobj,1).h(i,1).YData(end))<GV.tol_1)
							try_to_connect	= false;				% The line is a closed line.
						end
					end
				end
				if try_to_connect
					% The map object consists only of open lines:
					for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
						% Add the preview data to connways_preview:
						no_lines_to_connect	= no_lines_to_connect+1;
						x							= MAP_OBJECTS(imapobj,1).h(i,1).XData;
						y							= MAP_OBJECTS(imapobj,1).h(i,1).YData;
						% Default values:
						iobj_v			= [iobj_v;MAP_OBJECTS(imapobj,1).iobj];
						if MAP_OBJECTS(imapobj,1).iobj>0
							iobj			= MAP_OBJECTS(imapobj,1).iobj;		% object number of the new way
						else
							iobj			= [];											% object number of the new way
						end
						% Relation number of the line:
						if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'relid')
							relid			= MAP_OBJECTS(imapobj,1).h(i,1).UserData.relid;
							ir				= find(OSMDATA.id.relation==relid,1);
						else
							relid			= uint64(0);
							ir				= 0;
						end
						relid_v			= unique([relid_v;relid]);
						% Connect only lines that have the same relation number:
						if length(relid_v)~=1
							errortext	= sprintf([...
								'The selected map objects have different relation IDs.\n',...
								'You can only connect lines that have the same relation ID:\n',...
								'1) You may have selected the wrong lines: change your selection\n',...
								'2) If you still want to connect the selected lines:\n',...
								'   change the relation IDs\n',...
								'   (left + right click on the line: "Relation ID")']);
							errormessage(errortext);
						end
						iw_v	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw(:);
						% Connect the ways:
						connways_preview		= ...
							connect_ways(...				%								Defaultvalues:
							connways_preview,...			% connways					-
							[],...							% connways_merge			[]
							x,...								% x							[]
							y,...								% y							[]
							iobj,...							% iobj						[]
							[],...							% lino						[]
							[],...							% liwi						[]
							0,...								% in							0
							iw_v,...							% iw_v						0
							ir,...							% ir							0
							1,...								% l2a							1
							1,...								% s							1
							1,...								% lino_new_min				1
							'outer',...						% role						'outer'
							relid,...						% relid						uint64(0)
							'',...							% tag							''
							tol,...							% tol							GV.tol_1
							true,...							% conn_with_rev			true
							true);							% connect					true
					end
					% Collect descriptions and texts:
					if isempty(strfind(connways_dscr,MAP_OBJECTS(imapobj,1).dscr))
						if isempty(connways_dscr)
							connways_dscr	= MAP_OBJECTS(imapobj,1).dscr;
						else
							% Change the descriptions:
							connways_dscr	= [connways_dscr ' - ' MAP_OBJECTS(imapobj,1).dscr];
							prompt	= {sprintf([...
								'The descriptions of the selected plot numbers are different.\n',...
								'The changed description of the newly created objects will be:'])};
							dlgtitle	= 'Enter object description';
							dims		= 1;
							definput	= {connways_dscr};
							answer	= inputdlg_local(prompt,dlgtitle,dims,definput);
							if ~isempty(answer)
								connways_dscr	= answer;
							else
								if ~stateisbusy
									display_on_gui('state','','notbusy');
								end
								return
							end
						end
					end
					if isempty(strfind(connways_text,MAP_OBJECTS(imapobj,1).text{1}))
						if isempty(connways_text)
							connways_text	= MAP_OBJECTS(imapobj,1).text{1};
						else
							% Change the text/tag:
							connways_text	= [connways_text ' - ' MAP_OBJECTS(imapobj,1).text{1}];
							prompt	= {sprintf([...
								'The texts/tags of the selected plot numbers are different.\n',...
								'The changed text/tag of the newly created objects will be:'])};
							dlgtitle	= 'Enter text/tag';
							dims		= 1;
							definput	= {connways_text};
							answer	= inputdlg_local(prompt,dlgtitle,dims,definput);
							if ~isempty(answer)
								connways_text	= answer;
							else
								if ~stateisbusy
									display_on_gui('state','','notbusy');
								end
								return
							end
						end
					end
					imapobj_delete_v	= [imapobj_delete_v;imapobj];
				end
			end
			cncl_v				= unique(cncl_v);
			iobj_v				= unique(iobj_v);
			
			no_lines					= size(connways_preview.lines,1);
			no_areas					= size(connways_preview.areas,1);
			no_lines_connected	= no_lines_to_connect-no_lines-no_areas;
			if no_lines_connected==0
				% No lines have been connected: Cancel:
				set(GV_H.text_waitbar,'String','No lines connected.');
				
			else
				% Lines have been connected:
				set(GV_H.text_waitbar,'String',...
					sprintf('%g/%g lines connected.',no_lines_connected+1,no_lines_to_connect));
				
				% Plot the areas:
				for k=1:size(connways_preview.areas,1)
					x	= connways_preview.areas(k,1).xy(:,1);
					y	= connways_preview.areas(k,1).xy(:,2);
					if GV.warnings_off
						warning('off','MATLAB:polyshape:repairedBySimplify');
					end
					poly		= polyshape(x,y,'Simplify',true,'KeepCollinearPoints',false);
					if GV.warnings_off
						warning('on','MATLAB:polyshape:repairedBySimplify');
					end
					% New line:
					imapobj_new			= size(MAP_OBJECTS,1)+1;
					% Userdata:
					ud						= [];
					ud.in					= [];
					ud.iw					= connways_preview.areas(k,1).iw_v(:);
					ud.ir					= connways_preview.areas(k,1).ir(:);
					ud.iw(ud.iw==0,:)	= [];
					ud.ir(ud.ir==0,:)	= [];
					ud.relid				= relid_v;
					ud.rotation			= 0;
					ud.shape0			= poly;
					% Plot the preview as polygon:
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
					end
					h_poly	= plot(GV_H.ax_2dmap,poly,...
						'EdgeColor',GV.preview.EdgeColor,...
						'FaceColor',GV.preview.FaceColor,...
						'EdgeAlpha', GV.visibility.show.edgealpha,...
						'FaceAlpha',GV.visibility.show.facealpha,...
						'Visible'  ,'on',...
						'LineStyle',GV.preview.LineStyle,...
						'LineWidth',GV.preview.LineWidth,...
						'UserData',ud,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
					% Create/modify legend:
					if length(imapobj_v)==1
						create_legend_mapfigure;
					end
					% Save relevant data in the structure MAP_OBJECTS:
					[xcenter,ycenter]						= centroid(poly);
					MAP_OBJECTS(imapobj_new,1).disp	= 'preview polygon';
					MAP_OBJECTS(imapobj_new,1).h		= h_poly;
					if length(iobj_v)==1
						MAP_OBJECTS(imapobj_new,1).iobj	= iobj_v;
					else
						MAP_OBJECTS(imapobj_new,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
					end
					MAP_OBJECTS(imapobj_new,1).dscr	= connways_dscr;
					MAP_OBJECTS(imapobj_new,1).x		= xcenter;
					MAP_OBJECTS(imapobj_new,1).y		= ycenter;
					MAP_OBJECTS(imapobj_new,1).text	= {connways_text};
					MAP_OBJECTS(imapobj_new,1).mod	= false;
					MAP_OBJECTS(imapobj_new,1).cncl	= 0;
					MAP_OBJECTS(imapobj_new,1).cnuc	= 0;
					MAP_OBJECTS(imapobj_new,1).vis0	= 1;
				end
				
				% Plot the lines:
				for k=1:size(connways_preview.lines,1)
					x	= connways_preview.lines(k,1).xy(:,1);
					y	= connways_preview.lines(k,1).xy(:,2);
					% New line:
					imapobj_new		= size(MAP_OBJECTS,1)+1;
					% Userdata:
					ud						= [];
					ud.in					= [];
					ud.iw					= connways_preview.lines(k,1).iw_v(:);
					ud.ir					= connways_preview.lines(k,1).ir(:);
					ud.iw(ud.iw==0,:)	= [];
					ud.ir(ud.ir==0,:)	= [];
					ud.relid				= relid_v;
					ud.rotation			= 0;
					ud.xy0				= [x y];
					% Plot the preview as line:
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
					end
					h_line	= plot(GV_H.ax_2dmap,x,y,...
						'Color',GV.preview.Color,...
						'LineStyle',GV.preview.LineStyle,...
						'LineWidth',GV.preview.LineWidth,...
						'Marker','none',...
						'MarkerSize',GV.preview.MarkerSize,...
						'UserData',ud,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
					% Create/modify legend:
					if length(imapobj_v)==1
						create_legend_mapfigure;
					end
					% Save relevant data in the structure MAP_OBJECTS:
					if length(cncl_v)==1
						if cncl_v>0
							MAP_OBJECTS(imapobj_new,1).disp	= 'preview cutting line';
						else
							MAP_OBJECTS(imapobj_new,1).disp	= 'preview line';
						end
					else
						MAP_OBJECTS(imapobj_new,1).disp	= 'preview line';
					end
					MAP_OBJECTS(imapobj_new,1).h		= h_line;
					if length(iobj_v)==1
						MAP_OBJECTS(imapobj_new,1).iobj	= iobj_v;
					else
						MAP_OBJECTS(imapobj_new,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
					end
					MAP_OBJECTS(imapobj_new,1).dscr	= connways_dscr;
					MAP_OBJECTS(imapobj_new,1).x		= mean(x);
					MAP_OBJECTS(imapobj_new,1).y		= mean(y);
					MAP_OBJECTS(imapobj_new,1).text	= {connways_text};
					MAP_OBJECTS(imapobj_new,1).mod	= false;
					if length(cncl_v)==1
						MAP_OBJECTS(imapobj_new,1).cncl	= cncl_v;
						MAP_OBJECTS(imapobj_new,1).vis0	= 0;
					else
						MAP_OBJECTS(imapobj_new,1).cncl	= 0;
						MAP_OBJECTS(imapobj_new,1).vis0	= 1;
					end
					MAP_OBJECTS(imapobj_new,1).cnuc	= 0;
				end
				
				% Create/modify legend:
				if length(imapobj_v)>1
					create_legend_mapfigure;
				end
				
				% Number of new map objects:
				no_new_map_objects	= size(MAP_OBJECTS,1)-size_map_objects_0;
				
				% Delete the old map objects:
				if ~isempty(imapobj_delete_v)
					% Delete objects (MAP_OBJECTS_TABLE will be updated also):
					plot_modify('delete',unique(imapobj_delete_v));		% Includes also display_map_objects
				else
					% Update MAP_OBJECTS_TABLE:
					display_map_objects;
				end
				
				% Arrange the new map objects:
				if no_new_map_objects>=1
					% Plot numbers of the new map objects:
					imapobj_new_v		= ((size(MAP_OBJECTS,1)-no_new_map_objects+1):size(MAP_OBJECTS,1))';
					% Select the new map objects:
					plot_modify('select',imapobj_new_v,0);
					% Arrange the new map objects (includes also display_map_objects):
					if APP.AutoSortNewMapObjects_Menu.Checked
						arrange_map_objects(...
							min(imapobj_v),...			% pos. after the arrangement
							imapobj_new_v);				% pos. before the arrangement
					end
					% Update MAP_OBJECTS_TABLE: already executed by arrange_map_objects
					if ~APP.AutoSortNewMapObjects_Menu.Checked
						display_map_objects;
					end
				end
				
			end
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'poly2line'
			% Convert one polygon to preview lines:
			
			% Check whether the map objects are polygons:
			for k=1:length(imapobj_v)
				imapobj								= imapobj_v(k);
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if ~strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
						errormessage(sprintf(['Error:\n',...
							'The selected object PlotNo=%g is of the type "%s".\n',...
							'This function is only applicable on polygons.'],imapobj,MAP_OBJECTS(imapobj,1).h(1,1).Type));
					end
				end
			end
			
			% Delete legend:
			if length(imapobj_v)>1
				legend(GV_H.ax_2dmap,'off');
			end
			
			% Plot the preview lines:
			imapobj_delete_v		= [];
			size_map_objects_0	= size(MAP_OBJECTS,1);
			for k=1:length(imapobj_v)
				imapobj				= imapobj_v(k);
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				imapobj_new			= size(MAP_OBJECTS,1)+1;
				if (MAP_OBJECTS(imapobj,1).iobj<0)||isequal(strfind(MAP_OBJECTS(imapobj,1).disp,'preview'),1)
					imapobj_delete_v		= [imapobj_delete_v;imapobj];
				end
				i_line	= 0;
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					for ib=1:numboundaries(MAP_OBJECTS(imapobj,1).h(i,1).Shape)
						[x,y]				= boundary(MAP_OBJECTS(imapobj,1).h(i,1).Shape,ib);
						% Userdata:
						ud					= [];
						ud.in				= [];
						ud.iw				= [];
						ud.ir				= [];
						ud.rotation		= 0;
						ud.xy0			= [x y];
						% Plot the preview as polygon:
						if ~ishandle(GV_H.ax_2dmap)
							errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
						end
						i_line			= i_line+1;
						h_line	= plot(GV_H.ax_2dmap,x,y,...
							'Color',GV.preview.Color,...
							'LineStyle',GV.preview.LineStyle,...
							'LineWidth',GV.preview.LineWidth,...
							'Marker','none',...
							'MarkerSize',GV.preview.MarkerSize,...
							'UserData',ud,...
							'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
						% Create/modify legend:
						if length(imapobj_v)==1
							create_legend_mapfigure;
						end
						% Save relevant data in the structure MAP_OBJECTS:
						MAP_OBJECTS(imapobj_new,1).disp			= 'preview line';
						MAP_OBJECTS(imapobj_new,1).h(i_line,1)	= h_line;
						if MAP_OBJECTS(imapobj,1).iobj>0
							MAP_OBJECTS(imapobj_new,1).iobj		= MAP_OBJECTS(imapobj,1).iobj;
						else
							MAP_OBJECTS(imapobj_new,1).iobj		= min([[MAP_OBJECTS.iobj] 0])-1;
						end
						MAP_OBJECTS(imapobj_new,1).dscr			= MAP_OBJECTS(imapobj,1).dscr;
						MAP_OBJECTS(imapobj_new,1).x				= mean(x);
						MAP_OBJECTS(imapobj_new,1).y				= mean(y);
						MAP_OBJECTS(imapobj_new,1).text			= MAP_OBJECTS(imapobj,1).text;
						MAP_OBJECTS(imapobj_new,1).mod			= false;
						MAP_OBJECTS(imapobj_new,1).cncl			= 0;
						MAP_OBJECTS(imapobj_new,1).cnuc			= 0;
						MAP_OBJECTS(imapobj_new,1).vis0			= 1;
					end
				end
			end
			
			% Create/modify legend:
			if length(imapobj_v)>1
				create_legend_mapfigure;
			end
			
			% Number of new map objects:
			no_new_map_objects	= size(MAP_OBJECTS,1)-size_map_objects_0;
			
			% Delete the old map objects:
			if ~isempty(imapobj_delete_v)
				% Delete objects (MAP_OBJECTS_TABLE will be updated also):
				plot_modify('delete',unique(imapobj_delete_v));		% Includes also display_map_objects
			else
				% Update MAP_OBJECTS_TABLE:
				display_map_objects;
			end
			
			% Arrange the new map objects:
			if no_new_map_objects>=1
				% Plot numbers of the new map objects:
				imapobj_new_v		= ((size(MAP_OBJECTS,1)-no_new_map_objects+1):size(MAP_OBJECTS,1))';
				% Select the new map objects:
				plot_modify('select',imapobj_new_v,0);
				% Arrange the new map objects (includes also display_map_objects):
				if APP.AutoSortNewMapObjects_Menu.Checked
					arrange_map_objects(...
						min(imapobj_v),...			% pos. after the arrangement
						imapobj_new_v);				% pos. before the arrangement
				end
				% Update MAP_OBJECTS_TABLE: already executed by arrange_map_objects
				if ~APP.AutoSortNewMapObjects_Menu.Checked
					display_map_objects;
				end
			end
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'line2poly'
			% Convert preview line to preview polygon:
			
			% Check whether imapobj_v is a scalar and the map object is a line:
			if length(imapobj_v)>1
				errormessage(sprintf(['Error:\n',...
					'Only one object must be selected to use this function.']));
			end
			for i=1:size(MAP_OBJECTS(imapobj_v,1).h,1)
				if ~strcmp(MAP_OBJECTS(imapobj_v,1).h(i,1).Type,'line')
					errormessage(sprintf(['Error:\n',...
						'The selected object PlotNo=%g is of the type "%s".\n',...
						'This function is only applicable on lines.'],imapobj_v,MAP_OBJECTS(imapobj_v,1).h(1,1).Type));
				end
			end
			if MAP_OBJECTS(imapobj_v,1).cncl>0
				errormessage(sprintf(['Error:\n',...
					'Preview cutting lines cannot be converted to polygons.']));
			end
			
			% Check whether the lines are closed:
			for i=1:size(MAP_OBJECTS(imapobj_v,1).h,1)
				if    (abs(MAP_OBJECTS(imapobj_v,1).h(i,1).XData(1)-MAP_OBJECTS(imapobj_v,1).h(i,1).XData(end))>GV.tol_1)||...
						(abs(MAP_OBJECTS(imapobj_v,1).h(i,1).YData(1)-MAP_OBJECTS(imapobj_v,1).h(i,1).YData(end))>GV.tol_1)
					plot_modify('mod_vertex',imapobj_v,'close');
					% errormessage(sprintf(['Error:\n',...
					% 	'The lines must be closed to use this function.']));
				end
			end
			
			% Delete legend:
			if size(MAP_OBJECTS(imapobj_v,1).h,1)>1
				legend(GV_H.ax_2dmap,'off');
			end
			
			% Plot the preview polygons:
			imapobj_delete_v		= [];
			size_map_objects_0	= size(MAP_OBJECTS,1);
			imapobj					= imapobj_v;
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				if GV.warnings_off
					warning('off','MATLAB:polyshape:repairedBySimplify');
				end
				poly		= polyshape(...
					MAP_OBJECTS(imapobj,1).h(i,1).XData(1:(end-1)),...
					MAP_OBJECTS(imapobj,1).h(i,1).YData(1:(end-1)),'Simplify',true,'KeepCollinearPoints',false);
				if GV.warnings_off
					warning('on','MATLAB:polyshape:repairedBySimplify');
				end
				% New line:
				imapobj_new				= size(MAP_OBJECTS,1)+1;
				imapobj_delete_v		= [imapobj_delete_v;imapobj];
				% Extend the userdata:
				ud					= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
				if isfield(ud,'xy0')
					ud				= rmfield(ud,'xy0');
				end
				ud.shape0		= poly;
				% Plot the preview as polygon:
				if ~ishandle(GV_H.ax_2dmap)
					errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
				end
				h_poly	= plot(GV_H.ax_2dmap,poly,...
					'EdgeColor',GV.preview.EdgeColor,...
					'FaceColor',GV.preview.FaceColor,...
					'EdgeAlpha', GV.visibility.show.edgealpha,...
					'FaceAlpha',GV.visibility.show.facealpha,...
					'Visible'  ,'on',...
					'LineStyle',GV.preview.LineStyle,...
					'LineWidth',GV.preview.LineWidth,...
					'UserData',ud,...
					'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
				% Create/modify legend:
				if size(MAP_OBJECTS(imapobj,1).h,1)==1
					create_legend_mapfigure;
				end
				% Save relevant data in the structure MAP_OBJECTS:
				[xcenter,ycenter]						= centroid(poly);
				MAP_OBJECTS(imapobj_new,1).disp	= 'preview polygon';
				MAP_OBJECTS(imapobj_new,1).h		= h_poly;
				if MAP_OBJECTS(imapobj,1).iobj>0
					MAP_OBJECTS(imapobj_new,1).iobj	= MAP_OBJECTS(imapobj,1).iobj;
				else
					MAP_OBJECTS(imapobj_new,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
				end
				MAP_OBJECTS(imapobj_new,1).dscr	= MAP_OBJECTS(imapobj,1).dscr;
				MAP_OBJECTS(imapobj_new,1).x		= xcenter;
				MAP_OBJECTS(imapobj_new,1).y		= ycenter;
				MAP_OBJECTS(imapobj_new,1).text	= MAP_OBJECTS(imapobj,1).text;
				MAP_OBJECTS(imapobj_new,1).mod	= false;
				MAP_OBJECTS(imapobj_new,1).cncl	= 0;
				MAP_OBJECTS(imapobj_new,1).cnuc	= 0;
				MAP_OBJECTS(imapobj_new,1).vis0	= 1;
			end
			
			% Create/modify legend:
			create_legend_mapfigure;
			
			% Number of new map objects:
			no_new_map_objects	= size(MAP_OBJECTS,1)-size_map_objects_0;
			
			% Delete the old map objects:
			if ~isempty(imapobj_delete_v)
				% Delete objects (MAP_OBJECTS_TABLE will be updated also):
				plot_modify('delete',unique(imapobj_delete_v));		% Includes also display_map_objects
			else
				% Update MAP_OBJECTS_TABLE:
				display_map_objects;
			end
			
			% Arrange the new map objects:
			if no_new_map_objects>=1
				% Plot numbers of the new map objects:
				imapobj_new_v		= ((size(MAP_OBJECTS,1)-no_new_map_objects+1):size(MAP_OBJECTS,1))';
				% Select the new map objects:
				plot_modify('select',imapobj_new_v,0);
				% Arrange the new map objects (includes also display_map_objects):
				if APP.AutoSortNewMapObjects_Menu.Checked
					arrange_map_objects(...
						min(imapobj_v),...			% pos. after the arrangement
						imapobj_new_v);				% pos. before the arrangement
				end
				% Update MAP_OBJECTS_TABLE: already executed by arrange_map_objects
				if ~APP.AutoSortNewMapObjects_Menu.Checked
					display_map_objects;
				end
			end
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'convprevline'
			% Convert preview line to map object:
			
			% Check whether the map objects are lines:
			for i_imapobj=1:length(imapobj_v)
				imapobj	= imapobj_v(i_imapobj);
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if ~strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'line')
						errormessage(sprintf(['Error:\n',...
							'The selected object PlotNo=%g is of the type "%s".\n',...
							'This function is only applicable on lines.'],imapobj,MAP_OBJECTS(imapobj,1).h(1,1).Type));
					end
					if length(MAP_OBJECTS(imapobj,1).h(i,1).XData)<2
						errormessage(sprintf(['Error:\n',...
							'The selected line PlotNo=%g\n',...
							'consists of less than 2 vertices.'],imapobj));
					end
				end
				if MAP_OBJECTS(imapobj,1).cncl>0
					errormessage(sprintf(['Error:\n',...
						'Preview cutting lines cannot be converted.']));
				end
			end
			
			% Assign the object number:
			iobj				= APP.Mod_AddPrevToOutput_ObjNo_EditField.Value;
			if iobj<1
				errormessage(sprintf(['Error:\n',...
					'The minimum object number is ObjNo=1.']));
			end
			if iobj>size(PP.obj,1)
				errormessage(sprintf(['Error:\n',...
					'The maximum object number is ObjNo=%g.'],size(PP.obj,1)));
			end
			
			% Information about the usage of the object
			obj_purpose		= {'map object'};
			
			% Parameters depending on par1:
			switch par1
				case '2connlinemapobj'
					% Convert preview line to text connection line map object(see texteqtags2poly.m):
					if PP.obj(iobj).textpar.display~=1
						errormessage(sprintf(['Error:\n',...
							'Object number ObjNo=%g\n',...
							'(%s):\n',...
							'The display of texts is switched off.'],iobj,PP.obj(iobj).description));
					end
					color_no			= PP.obj(iobj).textpar.color_no_bgd;
					linewidth_poly	= PP.obj(iobj).textpar.line2refpoint_width;
					sampling_poly	= 6;
					prio				= PP.obj(iobj).textpar.prio-0.25;
					dz_bgd			= PP.obj(iobj).textpar.dz_bgd;
					if strcmp(PP.obj(iobj).textpar.visibility,'gray out')
						facealpha		= GV.visibility.grayout.facealpha;
						edgealpha		= GV.visibility.grayout.edgealpha;
					else
						facealpha		= GV.visibility.show.facealpha;
						edgealpha		= GV.visibility.show.edgealpha;
					end
					display_as		= 'connection line';
				case '2linemapobj'
					% Convert preview line to line or area map object (see line2poly.m, plotosmdata_plotdata_li_ar.m):
					if PP.obj(iobj).display~=1
						errormessage(sprintf(['Error:\n',...
							'Object number ObjNo=%g\n',...
							'(%s):\n',...
							'The display is switched off.'],iobj,PP.obj(iobj).description));
					end
					color_no			= PP.obj(iobj).color_no_bgd;
					linewidth_poly	= APP.Mod_ConvPrevLineToLine_EditField.Value;
					sampling_poly	= 1;
					prio				= PP.obj(iobj).prio-0.25;
					if     (PP.obj(iobj).display_as_area==0)&&(PP.obj(iobj).display_as_line~=0)
						display_as		= 'line';
					elseif (PP.obj(iobj).display_as_area~=0)&&(PP.obj(iobj).display_as_line==0)
						display_as		= 'area';
					elseif (PP.obj(iobj).display_as_area==0)&&(PP.obj(iobj).display_as_line==0)
						errormessage(sprintf(['Error:\n',...
							'Object number ObjNo=%g\n',...
							'(%s):\n',...
							'is not displayed as either a line or an area.'],iobj,PP.obj(iobj).description));
					else
						question	= sprintf([...
							'Should the preview line be converted\n',...
							'using line settings or area settings\n',...
							'of object number ObjNo=%g\n',...
							'(%s)?',...
							],iobj,PP.obj(iobj).description);
						answer	= questdlg_local(question,'Select line or area settings',...
							'Line','Area','Cancel','Cancel');
						if isempty(answer)||strcmp(answer,'Cancel')
							if ~stateisbusy
								display_on_gui('state','','notbusy');
							end
							return
						end
						display_as	= lower(answer);
					end
					if strcmp(display_as,'line')
						% line2poly: The assignment of in, iw, and ir is not necessary here.
						[~,~,ud_line,~]	= line2poly(...
							[],...										% x
							[],...										% y
							PP.obj(iobj).linepar,...				% par
							PP.obj(iobj).linestyle,...				% style
							iobj,...										% iobj
							obj_purpose);								% obj_purpose
						dz_bgd				= ud_line.dz;
					elseif strcmp(display_as,'area')
						% area2poly: The assignment of in, iw, and ir is not necessary here.
						[~,~,ud_area,~]	= area2poly(...
							polyshape(),...							% polyin
							PP.obj(iobj).areapar,...				% par
							PP.obj(iobj).areastyle,...				% style
							iobj,...										% iobj
							obj_purpose);								% obj_purpose
						dz_bgd				= ud_area.dz;
					end
					if strcmp(PP.obj(iobj).visibility,'gray out')
						facealpha		= GV.visibility.grayout.facealpha;
						edgealpha		= GV.visibility.grayout.edgealpha;
					else
						facealpha		= GV.visibility.show.facealpha;
						edgealpha		= GV.visibility.show.edgealpha;
					end
			end
			
			% Delete legend:
			legend(GV_H.ax_2dmap,'off');
			
			% Plot the preview polygons:
			for i_imapobj=1:length(imapobj_v)
				imapobj			= imapobj_v(i_imapobj);
				h_poly_v			= [];
				poly				= polyshape();
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					% Downsampling:
					dmax				= [];
					nmin				= [];
					dmin				= min(PP.obj(iobj).reduce_lines.dmin,PP.obj(iobj).reduce_areas.dmin);
					xdata				= MAP_OBJECTS(imapobj,1).h(i,1).XData;
					ydata				= MAP_OBJECTS(imapobj,1).h(i,1).YData;
					if dmin>0
						[xdata,ydata]	= changeresolution_xy(xdata,ydata,dmax,dmin,nmin);
					end
					% Create the polygon:
					poly(i,1)		= line2poly(...
						xdata,...
						ydata,...
						{linewidth_poly;sampling_poly});
					% Delete the preview line:
					delete(MAP_OBJECTS(imapobj,1).h(i,1));
					% Userdata:
					ud.color_no			= color_no;
					ud.color_no_pp		= color_no;
					ud.dz					= dz_bgd;
					ud.prio				= prio;
					ud.in					= [];
					ud.iw					= [];
					ud.ir					= [];
					ud.iobj				= iobj;
					ud.level				= 0;
					ud.surftype			= 100;
					ud.iteqt				= [];
					ud.text_eqtags		= {''};
					ud.chstno			= [];
					ud.chstsettings	= [];
					ud.rotation			= 0;
					ud.obj_purpose		= obj_purpose;
					ud.shape0			= poly(i,1);
					% Settings:
					visible				= 'on';				% here always on (not PP.obj(iobj).visibility)
					if isequal(color_no,0)
						facecolor		= 'none';
						linewidth		= GV.colorno_e0_linewidth;
					else
						facecolor		= PP.color(color_no).rgb/255;
						linewidth		= GV.colorno_g0_linewidth;
					end
					% Plot the polygon:
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf(['There exists no map where to plot the objects.\n',...
							'Create the map first.']));
					end
					h_poly			= plot(GV_H.ax_2dmap,...
						poly(i,1)  ,...
						'LineWidth',linewidth,...
						'EdgeColor','k',...
						'FaceColor',facecolor,...
						'EdgeAlpha',edgealpha,...
						'FaceAlpha',facealpha,...
						'Visible'  ,visible,...
						'UserData' ,ud,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
					h_poly_v			= [h_poly_v;h_poly];
				end
				% Save relevant data in the structure MAP_OBJECTS:
				[xcenter,ycenter]						= centroid(poly);
				MAP_OBJECTS(imapobj,1).disp		= display_as;
				MAP_OBJECTS(imapobj,1).h			= h_poly_v;
				MAP_OBJECTS(imapobj,1).iobj		= iobj;
				MAP_OBJECTS(imapobj,1).dscr		= PP.obj(iobj,1).description;
				MAP_OBJECTS(imapobj,1).x			= xcenter;
				MAP_OBJECTS(imapobj,1).y			= ycenter;
				MAP_OBJECTS(imapobj,1).text		= {''};
				MAP_OBJECTS(imapobj,1).mod			= false;
				MAP_OBJECTS(imapobj,1).cncl		= 0;
				MAP_OBJECTS(imapobj,1).cnuc		= 0;
				if strcmp(visible,'on')
					MAP_OBJECTS(imapobj,1).vis0	= 1;
				else
					MAP_OBJECTS(imapobj,1).vis0	= 0;
				end
			end
			
			% Create/modify legend:
			create_legend_mapfigure;
			
			% Update MAP_OBJECTS_TABLE:
			if length(imapobj_v)==1
				display_map_objects(imapobj_v);
			else
				display_map_objects;
			end
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'prevcutline2cutline'
			% Convert preview cutting line (line) to cutting line (polygon)
			
			% Color number of cutting lines (=0: normal preview):
			cncl				= get_colno_cuttingline;
			if cncl==0
				errormessage(sprintf(['Error:\n',...
					'The creation of a cutting line is not possible with\n',...
					'the dropdown menu setting "Cutting lines: None".']));
			end
			% Check whether the map object is a line with the correct color number:
			for k=1:length(imapobj_v)
				if    (MAP_OBJECTS(imapobj_v(k),1).cncl==0   )||...
						(MAP_OBJECTS(imapobj_v(k),1).cncl~=cncl)
					errormessage(sprintf(['Error:\n',...
						'The selected object PlotNo=%g cannot.\n',...
						'be converted into a cutting line\n',...
						'with the color number %g.'],...
						imapobj_v(k),cncl));
				end
				for i=1:size(MAP_OBJECTS(imapobj_v(k),1).h,1)
					if ~strcmp(MAP_OBJECTS(imapobj_v(k),1).h(i,1).Type,'line')
						errormessage(sprintf(['Error:\n',...
							'The selected object PlotNo=%g is of the type "%s".\n',...
							'This function is only applicable on lines.'],...
							imapobj_v(k),MAP_OBJECTS(imapobj_v(k),1).h(i,1).Type));
					end
				end
			end
			
			% Delete legend:
			if length(imapobj_v)>1
				legend(GV_H.ax_2dmap,'off');
			end
			
			% Create cutting lines in descending order!
			icolspec					= PP.color(cncl,1).spec;
			imapobj_v				= sort(unique(imapobj_v),'descend');
			size_map_objects_0	= size(MAP_OBJECTS,1);
			for k=1:length(imapobj_v)
				imapobj			= imapobj_v(k);
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				imapobj_new		= size(MAP_OBJECTS,1)+1;
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					% Dividing polygon:
					poly_i			= create_dividing_polygon(...
						MAP_OBJECTS(imapobj,1).h(i,1).XData,...		% x_v
						MAP_OBJECTS(imapobj,1).h(i,1).YData,...		% y_v
						PP.colorspec(icolspec));
					if i==1
						poly			= poly_i;
					else
						poly			= union(poly,poly_i,'KeepCollinearPoints',false);
					end
					% Userdata:
					ud					= [];
					ud.color_no		= cncl;
					ud.color_no_pp	= cncl;
					ud.in				= [];
					ud.iw				= [];
					ud.ir				= [];
					ud.rotation		= 0;
					ud.shape0		= poly_i;
					% Plot the preview as polygon:
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
					end
					h_poly	= plot(GV_H.ax_2dmap,poly_i,...
						'EdgeColor','k',...
						'FaceColor',PP.color(cncl,1).rgb/255,...
						'EdgeAlpha',GV.visibility.show.edgealpha,...
						'FaceAlpha',GV.visibility.show.facealpha,...
						'Visible'  ,'on',...
						'UserData',ud,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
					% Create/modify legend:
					if length(imapobj_v)==1
						create_legend_mapfigure;
					end
					% Save relevant data in the structure MAP_OBJECTS:
					MAP_OBJECTS(imapobj_new,1).h(i,1)	= h_poly;
					if i==1
						MAP_OBJECTS(imapobj_new,1).disp		= 'cutting line';
						MAP_OBJECTS(imapobj_new,1).iobj		= min([[MAP_OBJECTS.iobj] 0])-1;
						MAP_OBJECTS(imapobj_new,1).dscr		= 'Cutting line';
						MAP_OBJECTS(imapobj_new,1).text		= {''};
						MAP_OBJECTS(imapobj_new,1).mod		= false;
						MAP_OBJECTS(imapobj_new,1).cncl		= cncl;
						MAP_OBJECTS(imapobj_new,1).cnuc		= 0;
						MAP_OBJECTS(imapobj_new,1).vis0		= 0;
					end
					if i==size(MAP_OBJECTS(imapobj,1).h,1)
						[xcenter,ycenter]							= centroid(poly);
						MAP_OBJECTS(imapobj_new,1).x			= xcenter;
						MAP_OBJECTS(imapobj_new,1).y			= ycenter;
					end
				end
				% Select the new objects:
				plot_modify('deselect',imapobj,0);
				plot_modify('select',imapobj_new,0);
			end
			
			% Create/modify legend:
			if length(imapobj_v)>1
				create_legend_mapfigure;
			end
			
			% Number of new map objects:
			no_new_map_objects	= size(MAP_OBJECTS,1)-size_map_objects_0;
			
			% Arrange the new map objects:
			if no_new_map_objects>=1
				% Plot numbers of the new map objects:
				imapobj_new_v		= ((size(MAP_OBJECTS,1)-no_new_map_objects+1):size(MAP_OBJECTS,1))';
				% Arrange the new map objects (includes also display_map_objects):
				if APP.AutoSortNewMapObjects_Menu.Checked
					arrange_map_objects(...
						min(imapobj_v),...			% pos. after the arrangement
						imapobj_new_v);				% pos. before the arrangement
				end
				% Update MAP_OBJECTS_TABLE: already executed by arrange_map_objects
				if ~APP.AutoSortNewMapObjects_Menu.Checked
					display_map_objects;
				end
			end
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'new_cutline'
			% Create a new cutting line (polygon)
			
			% Create cutting line:
			imapobj_new		= size(MAP_OBJECTS,1)+1;
			colno				= par2;
			% Userdata:
			ud					= [];
			ud.color_no		= colno;
			ud.color_no_pp	= colno;
			ud.in				= [];
			ud.iw				= [];
			ud.ir				= [];
			ud.rotation		= 0;
			ud.shape0		= par1;
			% Plot the preview as polygon:
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
			end
			h_poly	= plot(GV_H.ax_2dmap,par1,...
				'EdgeColor','k',...
				'FaceColor',PP.color(colno,1).rgb/255,...
				'EdgeAlpha',GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha,...
				'Visible'  ,'on',...
				'UserData' ,ud,...
				'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
			% Create/modify legend:
			create_legend_mapfigure;
			% Save relevant data in the structure MAP_OBJECTS:
			[xcenter,ycenter]							= centroid(par1);
			MAP_OBJECTS(imapobj_new,1).disp		= 'cutting line';
			MAP_OBJECTS(imapobj_new,1).h			= h_poly;
			MAP_OBJECTS(imapobj_new,1).iobj		= min([[MAP_OBJECTS.iobj] 0])-1;
			MAP_OBJECTS(imapobj_new,1).dscr		= 'Cutting line';
			MAP_OBJECTS(imapobj_new,1).x			= xcenter;
			MAP_OBJECTS(imapobj_new,1).y			= ycenter;
			MAP_OBJECTS(imapobj_new,1).text		= {''};
			MAP_OBJECTS(imapobj_new,1).mod		= false;
			MAP_OBJECTS(imapobj_new,1).cncl		= colno;
			MAP_OBJECTS(imapobj_new,1).cnuc		= 0;
			MAP_OBJECTS(imapobj_new,1).vis0		= 0;
			
			% Update MAP_OBJECTS_TABLE:
			plot_modify('deselect',-1,0);
			plot_modify('select',imapobj_new,0);
			display_map_objects;
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'poly'
			
			% Check whether the map objects are polygons:
			for k=1:length(imapobj_v)
				imapobj				= imapobj_v(k);
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if ~strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
						errormessage(sprintf(['Error:\n',...
							'The selected object PlotNo=%g is of the type "%s".\n',...
							'This function is only applicable on polygons.'],imapobj,MAP_OBJECTS(imapobj,1).h(1,1).Type));
					end
				end
			end
			
			% User inputs:
			if strcmp(par1,'simplify')
				dmax		= [];
				nmin		= [];
				dmin		= min(PP.defobj.reduce_lines.dmin,PP.defobj.reduce_areas.dmin);
				prompt	= {'Enter the minimum distance between consecutive vertices:'};
				dlgtitle	= 'Enter min. distance between vertices';
				dims		= 1;
				definput	= {sprintf('%g',dmin)};
				answer	= inputdlg_local(prompt,dlgtitle,dims,definput);
				if ~isempty(answer)
					dmin	= str2double(answer);
					if isnan(dmin)||isempty(dmin)||(length(dmin)>1)
						if ~stateisbusy
							display_on_gui('state','','notbusy');
						end
						return
					end
					dmin	= max(0,dmin);
				else
					if ~stateisbusy
						display_on_gui('state','','notbusy');
					end
					return
				end
			end
			
			% Delete legend:
			legend(GV_H.ax_2dmap,'off');
			
			% Deselect all, so only the new objects are selected afterwards:
			plot_modify('deselect',-1,0);
			
			% Edit objects in descending order!
			imapobj_v	= sort(unique(imapobj_v),'descend');
			for k=1:length(imapobj_v)
				imapobj				= imapobj_v(k);
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=max(5,GV.waitbar_dtupdate)
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				imapobj_new			= size(MAP_OBJECTS,1)+1;
				if MAP_OBJECTS(imapobj,1).iobj>0
					imapobj_new_iobj	= MAP_OBJECTS(imapobj,1).iobj;
				else
					imapobj_new_iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
				end
				switch par1
					% --------------------------------------------------------------------------------------------------
					case 'dissolve_bound'
						
						i_poly	= 0;
						for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
							for ib=1:numboundaries(MAP_OBJECTS(imapobj,1).h(i,1).Shape)
								[x,y]				= boundary(MAP_OBJECTS(imapobj,1).h(i,1).Shape,ib);
								if GV.warnings_off
									warning('off','MATLAB:polyshape:repairedBySimplify');
								end
								poly				= polyshape(x(1:(end-1)),y(1:(end-1)),...
									'Simplify',true,'KeepCollinearPoints',false);
								if GV.warnings_off
									warning('on','MATLAB:polyshape:repairedBySimplify');
								end
								% Extend the userdata:
								ud					= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
								ud.shape0		= poly;
								source			= copy_source(ud);			% Create a new source data plot
								if ~isempty(source)
									ud.source	= source;
								end
								% Plot the preview as polygon:
								if ~ishandle(GV_H.ax_2dmap)
									errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
								end
								i_poly			= i_poly+1;
								h_poly			= plot(GV_H.ax_2dmap,poly,...
									'EdgeColor',MAP_OBJECTS(imapobj,1).h(i,1).EdgeColor,...
									'FaceColor',MAP_OBJECTS(imapobj,1).h(i,1).FaceColor,...
									'EdgeAlpha',MAP_OBJECTS(imapobj,1).h(i,1).EdgeAlpha,...
									'FaceAlpha',MAP_OBJECTS(imapobj,1).h(i,1).FaceAlpha,...
									'Visible'  ,'on',...
									'LineStyle',MAP_OBJECTS(imapobj,1).h(i,1).LineStyle,...
									'LineWidth',MAP_OBJECTS(imapobj,1).h(i,1).LineWidth,...
									'UserData',ud,...
									'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
								% Save relevant data in the structure MAP_OBJECTS:
								[xcenter,ycenter]								= centroid(poly);
								MAP_OBJECTS(imapobj_new,1).disp			= MAP_OBJECTS(imapobj,1).disp;
								MAP_OBJECTS(imapobj_new,1).h(i_poly,1)	= h_poly;
								MAP_OBJECTS(imapobj_new,1).iobj			= imapobj_new_iobj;
								MAP_OBJECTS(imapobj_new,1).dscr			= MAP_OBJECTS(imapobj,1).dscr;
								MAP_OBJECTS(imapobj_new,1).x				= xcenter;
								MAP_OBJECTS(imapobj_new,1).y				= ycenter;
								MAP_OBJECTS(imapobj_new,1).text			= MAP_OBJECTS(imapobj,1).text;
								MAP_OBJECTS(imapobj_new,1).mod			= false;
								MAP_OBJECTS(imapobj_new,1).cncl			= MAP_OBJECTS(imapobj,1).cncl;
								MAP_OBJECTS(imapobj_new,1).cnuc			= MAP_OBJECTS(imapobj,1).cnuc;
								MAP_OBJECTS(imapobj_new,1).vis0			= 1;
							end
						end
						
						% -----------------------------------------------------------------------------------------------
					case 'regions'
						% Convert the selected map objects into groups of solid regions, each consisting of
						% only one contiguous area. In contrast to the “Boundaries” command, holes do not become
						% independent objects, but remain holes.
						% Notes on the behavior of this function:
						% - If the map object consists of foreground (for example, the dashs of dashed lines) and
						%   background, the foreground objects remain in a group with the respective underlying
						%   background regions.
						% - If there are several overlapping foreground or background objects in a map object (for
						%   example, if a group has more than two elements), the overlapping foreground and background
						%   objects are united before being split into regions.
						% - If the map object consists of foreground and background, foreground objects are trimmed to
						%   the background so that they can be clearly assigned to a background region.
						% - If the map object only consists of foreground objects (without background), the foreground
						%   is split into individual map objects.
						% Application examples:
						% - Hiding or deleting built-up areas that are too small.
						
						% Union of foreground and background objects:
						poly_bgd		= polyshape();
						poly_fgd		= polyshape();
						ud_bgd		= zeros(0,1);
						ud_fgd		= zeros(0,1);
						for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
							treat_as_background	= true;				% if map object is a preview object
							if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'level')
								if MAP_OBJECTS(imapobj,1).h(i,1).UserData.level==0
									% level=0: background:
									% nop
								else
									% level=1: foreground:
									treat_as_background	= false;
								end
							end
							if treat_as_background
								% level=0: background:
								poly_bgd		= union(...
									poly_bgd,...
									MAP_OBJECTS(imapobj,1).h(i,1).Shape,...
									'KeepCollinearPoints',false);
								if isempty(ud_bgd)
									ud_bgd		= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
									if ~isfield(ud_bgd,'in')
										MAP_OBJECTS(imapobj,1).h(i,1).UserData.in		= zeros(0,1);
									end
									if ~isfield(ud_bgd,'iw')
										MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw		= zeros(0,1);
									end
									if ~isfield(ud_bgd,'ir')
										MAP_OBJECTS(imapobj,1).h(i,1).UserData.ir		= zeros(0,1);
									end
								else
									if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'in')
										ud_bgd.in	= [ud_bgd.in;MAP_OBJECTS(imapobj,1).h(i,1).UserData.in(:)];
									end
									if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'iw')
										ud_bgd.iw	= [ud_bgd.iw;MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw(:)];
									end
									if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'ir')
										ud_bgd.ir	= [ud_bgd.ir;MAP_OBJECTS(imapobj,1).h(i,1).UserData.ir(:)];
									end
								end
							else
								% level=1: foreground:
								poly_fgd		= union(...
									poly_fgd,...
									MAP_OBJECTS(imapobj,1).h(i,1).Shape,...
									'KeepCollinearPoints',false);
								if isempty(ud_fgd)
									ud_fgd		= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
									if ~isfield(ud_fgd,'in')
										MAP_OBJECTS(imapobj,1).h(i,1).UserData.in		= zeros(0,1);
									end
									if ~isfield(ud_fgd,'iw')
										MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw		= zeros(0,1);
									end
									if ~isfield(ud_fgd,'ir')
										MAP_OBJECTS(imapobj,1).h(i,1).UserData.ir		= zeros(0,1);
									end
								else
									if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'in')
										ud_fgd.in	= [ud_fgd.in;MAP_OBJECTS(imapobj,1).h(i,1).UserData.in(:)];
									end
									if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'iw')
										ud_fgd.iw	= [ud_fgd.iw;MAP_OBJECTS(imapobj,1).h(i,1).UserData.iw(:)];
									end
									if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'ir')
										ud_fgd.ir	= [ud_fgd.ir;MAP_OBJECTS(imapobj,1).h(i,1).UserData.ir(:)];
									end
								end
							end
						end
						
						% The foreground must be inside the background (if the background exists):
						if numboundaries(poly_bgd)>0
							poly_bgd_buff	= polybuffer(poly_bgd,-GV.d_forebackgrd_plotobj,...
								'JointType','miter','MiterLimit',2);
							poly_fgd		= intersect(poly_fgd,poly_bgd_buff,...
								'KeepCollinearPoints',false);
						end
						
						% Assign the foreground objects to the background objects:
						poly_regions_bgd		= regions(poly_bgd);
						poly_regions_fgd		= regions(poly_fgd);
						irmax_bgd				= size(poly_regions_bgd,1);
						irmax_fgd				= size(poly_regions_fgd,1);
						xlim_bgd_m				= [-1e10*ones(irmax_bgd,1) 1e10*ones(irmax_bgd,1)];
						ylim_bgd_m				= [-1e10*ones(irmax_bgd,1) 1e10*ones(irmax_bgd,1)];
						xlim_fgd_m				= [-1e10*ones(irmax_fgd,1) 1e10*ones(irmax_fgd,1)];
						ylim_fgd_m				= [-1e10*ones(irmax_fgd,1) 1e10*ones(irmax_fgd,1)];
						for ir_bgd=1:length(poly_regions_bgd)
							[xlim_bgd_m(ir_bgd,:),ylim_bgd_m(ir_bgd,:)]	= boundingbox(poly_regions_bgd(ir_bgd,1));
						end
						for ir_fgd=1:length(poly_regions_fgd)
							[xlim_fgd_m(ir_fgd,:),ylim_fgd_m(ir_fgd,:)]	= boundingbox(poly_regions_fgd(ir_fgd,1));
						end
						% The foreground object ir_fgd belongs to the background object ir_bgd=irbgd_polyfgd_v(ir_fgd,1):
						irbgd_polyfgd_v		= zeros(size(poly_regions_fgd,1),1);
						for ir_bgd=1:length(poly_regions_bgd)
							for ir_fgd=1:length(poly_regions_fgd)
								if irbgd_polyfgd_v(ir_fgd,1)==0
									overlap_is_possible	= overlaps_boundingbox(GV.tol_1,...
										xlim_bgd_m(ir_bgd,1),...		% x1min
										xlim_bgd_m(ir_bgd,2),...		% x1max
										ylim_bgd_m(ir_bgd,1),...		% y1min
										ylim_bgd_m(ir_bgd,2),...		% y1max
										xlim_fgd_m(ir_fgd,1),...		% x2min
										xlim_fgd_m(ir_fgd,2),...		% x2max
										ylim_fgd_m(ir_fgd,1),...		% y2min
										ylim_fgd_m(ir_fgd,2));			% y2max
									if overlap_is_possible
										if overlaps(poly_regions_bgd(ir_bgd,1),poly_regions_fgd(ir_fgd,1))
											irbgd_polyfgd_v(ir_fgd,1)			= ir_bgd;
										end
									end
								end
							end
						end
						
						% Plot objects:
						if (size(poly_regions_bgd,1)>0)&&(size(poly_regions_fgd,1)>0)
							poly_regions_1			= poly_regions_bgd;
							poly_regions_2			= poly_regions_fgd;
							ud_1						= ud_bgd;
							ud_2						= ud_fgd;
							irmax_1					= irmax_bgd;
							% The foreground object ir_2 belongs to the background object ir_1=ir1_poly2(ir_2,1):
							ir1_poly2				= irbgd_polyfgd_v;
						elseif (size(poly_regions_bgd,1)>0)&&(size(poly_regions_fgd,1)==0)
							poly_regions_1			= poly_regions_bgd;
							ud_1						= ud_bgd;
							irmax_1					= irmax_bgd;
							ir1_poly2				= zeros(0,1);
						elseif (size(poly_regions_bgd,1)==0)&&(size(poly_regions_fgd,1)>0)
							poly_regions_1			= poly_regions_fgd;
							ud_1						= ud_fgd;
							irmax_1					= irmax_fgd;
							ir1_poly2				= zeros(0,1);
						else
							irmax_1					= 0;
						end
						for ir_1=1:irmax_1
							% Waitbar:
							% This for-loop is very fast, the waitbar will not show.
							% Most time is spent in arrange_map_objects.
							if waitbar_activ
								if etime(clock,waitbar_t1)>=max(5,GV.waitbar_dtupdate)
									waitbar_t1	= clock;
									progress_ir	= (ir_1-1)/length(poly_regions_1)/length(imapobj_v);
									progress		= min((k-1)/length(imapobj_v)+progress_ir,1);
									set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
									drawnow;
								end
							end
							
							% Underlying object (background or foreground if no background exists):
							% Create a new map object for every underlying object:
							i_poly	= 0;
							% Extend imapobj_new:
							if ir_1>1
								imapobj_new			= [imapobj_new;imapobj_new(end,1)+1];
							end
							% Extend the userdata:
							ud_1.shape0		= poly_regions_1(ir_1,1);
							source			= copy_source(ud_1);			% Create a new source data plot
							if ~isempty(source)
								ud_1.source	= source;
							end
							% Plot the preview as polygon:
							if ~ishandle(GV_H.ax_2dmap)
								errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
							end
							i_poly			= i_poly+1;
							h_poly			= plot(GV_H.ax_2dmap,poly_regions_1(ir_1,1),...
								'EdgeColor',MAP_OBJECTS(imapobj,1).h(1,1).EdgeColor,...
								'FaceColor',MAP_OBJECTS(imapobj,1).h(1,1).FaceColor,...
								'EdgeAlpha',MAP_OBJECTS(imapobj,1).h(1,1).EdgeAlpha,...
								'FaceAlpha',MAP_OBJECTS(imapobj,1).h(1,1).FaceAlpha,...
								'Visible'  ,'on',...
								'LineStyle',MAP_OBJECTS(imapobj,1).h(1,1).LineStyle,...
								'LineWidth',MAP_OBJECTS(imapobj,1).h(1,1).LineWidth,...
								'UserData',ud_1,...
								'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
							% Save relevant data in the structure MAP_OBJECTS:
							[xcenter,ycenter]											= centroid(poly_regions_1(ir_1,1));
							MAP_OBJECTS(imapobj_new(end,1),1).disp				= MAP_OBJECTS(imapobj,1).disp;
							MAP_OBJECTS(imapobj_new(end,1),1).h(i_poly,1)	= h_poly;
							MAP_OBJECTS(imapobj_new(end,1),1).iobj				= imapobj_new_iobj;
							MAP_OBJECTS(imapobj_new(end,1),1).dscr				= MAP_OBJECTS(imapobj,1).dscr;
							MAP_OBJECTS(imapobj_new(end,1),1).x					= xcenter;
							MAP_OBJECTS(imapobj_new(end,1),1).y					= ycenter;
							MAP_OBJECTS(imapobj_new(end,1),1).text				= MAP_OBJECTS(imapobj,1).text;
							MAP_OBJECTS(imapobj_new(end,1),1).mod				= false;
							MAP_OBJECTS(imapobj_new(end,1),1).cncl				= MAP_OBJECTS(imapobj,1).cncl;
							MAP_OBJECTS(imapobj_new(end,1),1).cnuc				= MAP_OBJECTS(imapobj,1).cnuc;
							MAP_OBJECTS(imapobj_new(end,1),1).vis0				= 1;
							
							% Superimposed objects (foreground, if background exists):
							% The foreground object ir_2 belongs to the background object ir_1=ir1_poly2(ir_2,1):
							ir_2_v				= find(ir_1==ir1_poly2);
							for i_ir_2_v=1:size(ir_2_v,1)
								ir_2				= ir_2_v(i_ir_2_v,1);
								% Extend the userdata:
								ud_2.shape0		= poly_regions_2(ir_2,1);
								source			= copy_source(ud_2);			% Create a new source data plot
								if ~isempty(source)
									ud_2.source	= source;
								end
								% Plot the preview as polygon:
								if ~ishandle(GV_H.ax_2dmap)
									errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
								end
								i_poly			= i_poly+1;
								h_poly			= plot(GV_H.ax_2dmap,poly_regions_2(ir_2,1),...
									'EdgeColor',MAP_OBJECTS(imapobj,1).h(1,1).EdgeColor,...
									'FaceColor',MAP_OBJECTS(imapobj,1).h(1,1).FaceColor,...
									'EdgeAlpha',MAP_OBJECTS(imapobj,1).h(1,1).EdgeAlpha,...
									'FaceAlpha',MAP_OBJECTS(imapobj,1).h(1,1).FaceAlpha,...
									'Visible'  ,'on',...
									'LineStyle',MAP_OBJECTS(imapobj,1).h(1,1).LineStyle,...
									'LineWidth',MAP_OBJECTS(imapobj,1).h(1,1).LineWidth,...
									'UserData',ud_2,...
									'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
								% Save relevant data in the structure MAP_OBJECTS:
								MAP_OBJECTS(imapobj_new(end,1),1).h(i_poly,1)	= h_poly;
							end
							
						end
						
						% -----------------------------------------------------------------------------------------------
					case {'polybuffer','simplify'}
						
						i_poly	= 0;
						for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
							switch par1
								case 'polybuffer'
									poly = polybuffer(MAP_OBJECTS(imapobj,1).h(i,1).Shape,...
										par2,'JointType','miter','MiterLimit',2);
								case 'simplify'
									poly	= changeresolution_poly(MAP_OBJECTS(imapobj,1).h(i,1).Shape,dmax,dmin,nmin);
							end
							% Extend the userdata:
							ud					= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
							ud.shape0		= poly;
							source			= copy_source(ud);			% Create a new source data plot
							if ~isempty(source)
								ud.source	= source;
							end
							% Plot the preview as polygon:
							if ~ishandle(GV_H.ax_2dmap)
								errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
							end
							i_poly			= i_poly+1;
							h_poly			= plot(GV_H.ax_2dmap,poly,...
								'EdgeColor',MAP_OBJECTS(imapobj,1).h(i,1).EdgeColor,...
								'FaceColor',MAP_OBJECTS(imapobj,1).h(i,1).FaceColor,...
								'EdgeAlpha',MAP_OBJECTS(imapobj,1).h(i,1).EdgeAlpha,...
								'FaceAlpha',MAP_OBJECTS(imapobj,1).h(i,1).FaceAlpha,...
								'Visible'  ,'on',...
								'LineStyle',MAP_OBJECTS(imapobj,1).h(i,1).LineStyle,...
								'LineWidth',MAP_OBJECTS(imapobj,1).h(i,1).LineWidth,...
								'UserData',ud,...
								'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
							% Save relevant data in the structure MAP_OBJECTS:
							[xcenter,ycenter]								= centroid(poly);
							MAP_OBJECTS(imapobj_new,1).disp			= MAP_OBJECTS(imapobj,1).disp;
							MAP_OBJECTS(imapobj_new,1).h(i_poly,1)	= h_poly;
							MAP_OBJECTS(imapobj_new,1).iobj			= imapobj_new_iobj;
							MAP_OBJECTS(imapobj_new,1).dscr			= MAP_OBJECTS(imapobj,1).dscr;
							MAP_OBJECTS(imapobj_new,1).x				= xcenter;
							MAP_OBJECTS(imapobj_new,1).y				= ycenter;
							MAP_OBJECTS(imapobj_new,1).text			= MAP_OBJECTS(imapobj,1).text;
							MAP_OBJECTS(imapobj_new,1).mod			= false;
							MAP_OBJECTS(imapobj_new,1).cncl			= MAP_OBJECTS(imapobj,1).cncl;
							MAP_OBJECTS(imapobj_new,1).cnuc			= MAP_OBJECTS(imapobj,1).cnuc;
							MAP_OBJECTS(imapobj_new,1).vis0			= 1;
						end
						
				end
				% -----------------------------------------------------------------------------------------------------
				% Select the new objects:
				plot_modify('select',imapobj_new,0);
				% Arrange imapobj_new (update MAP_OBJECTS_TABLE afterwards):
				if APP.AutoSortNewMapObjects_Menu.Checked
					arrange_map_objects(...
						imapobj+1,...					% position after the arrangement
						imapobj_new);					% position before the arrangement
				end
				% Delete the old object(MAP_OBJECTS_TABLE will be updated also):
				plot_modify('delete',imapobj);		% Includes also display_map_objects
			end
			
			% Create/modify legend:
			create_legend_mapfigure;
			
			% Update MAP_OBJECTS_TABLE:
			display_map_objects;
			
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'poly12'
			% Functions on two polygons:
			
			% Check whether the map objects are scalar polygons:
			imapobj1	= APP.Mod_Polygons_PlotNo1_EditField.Value;
			imapobj2	= APP.Mod_Polygons_PlotNo2_EditField.Value;
			if imapobj1==imapobj2
				errormessage(sprintf(['Error:\n',...
					'The plot numbers must not be equal.']));
			end
			if (imapobj1<1)||(imapobj1>size(MAP_OBJECTS,1))
				errormessage(sprintf(['Error:\n',...
					'The selected PlotNo=%g is out of range.'],imapobj1));
			end
			if (imapobj2<1)||(imapobj2>size(MAP_OBJECTS,1))
				errormessage(sprintf(['Error:\n',...
					'The selected PlotNo=%g is out of range.'],imapobj2));
			end
			if length(MAP_OBJECTS(imapobj1,1).h)>1
				errormessage(sprintf(['Error:\n',...
					'The selected object PlotNo=%g is grouped.\n',...
					'This function cannot be applied to grouped objects.'],imapobj1));
			end
			if (length(MAP_OBJECTS(imapobj2,1).h)>1)&&...
					~strcmp(par1,'subtract')&&...
					~strcmp(par1,'subtract_dside')
				errormessage(sprintf(['Error:\n',...
					'The selected object PlotNo=%g is grouped.\n',...
					'This function cannot be applied to grouped objects.'],imapobj2));
			end
			if ~strcmp(MAP_OBJECTS(imapobj1,1).h.Type,'polygon')
				errormessage(sprintf(['Error:\n',...
					'The selected object PlotNo=%g is of the type "%s".\n',...
					'This function is only applicable on polygons.'],imapobj1,MAP_OBJECTS(imapobj1,1).h.Type));
			end
			for i=1:size(MAP_OBJECTS(imapobj2,1).h,1)
				if ~strcmp(MAP_OBJECTS(imapobj2,1).h(i,1).Type,'polygon')
					errormessage(sprintf(['Error:\n',...
						'The selected object PlotNo=%g is of the type "%s".\n',...
						'This function is only applicable on polygons.'],imapobj2,MAP_OBJECTS(imapobj2,1).h(i,1).Type));
				end
			end
			if strcmp(par1,'subtract_dside')&&(MAP_OBJECTS(imapobj1,1).iobj<=0)
				errormessage(sprintf(['Error:\n',...
					'The selected object PlotNo=%g is a preview object.\n',...
					'This function cannot be applied to preview objects.'],imapobj1));
			end
			if strcmp(par1,'subtract_dside')&&(MAP_OBJECTS(imapobj2,1).iobj<=0)
				errormessage(sprintf(['Error:\n',...
					'The selected object PlotNo=%g is a preview object.\n',...
					'This function cannot be applied to preview objects.'],imapobj2));
			end
			
			% Plot the preview polygon:
			if GV.warnings_off
				warning('off','MATLAB:polyshape:repairedBySimplify');
			end
			poly0		= MAP_OBJECTS(imapobj1,1).h.Shape;
			switch par1
				case 'subtract'
					% Object 2 possibly is a group:
					poly		= poly0;
					for i=1:size(MAP_OBJECTS(imapobj2,1).h,1)
						poly		= subtract(...
							poly,...
							MAP_OBJECTS(imapobj2,1).h(i,1).Shape,...
							'KeepCollinearPoints',false);
					end
				case 'subtract_dside'
					% Object 2 possibly is a group:
					poly		= poly0;
					for i=1:size(MAP_OBJECTS(imapobj2,1).h,1)
						[  poly,...																	% poly1
							MAP_OBJECTS(imapobj2,1).h(i,1).Shape,...						% poly2 (Subtrahend)
							~...																		% dbuffer
							]=subtract_dside(...
							poly,...																	% poly1
							MAP_OBJECTS(imapobj2,1).h(i,1).Shape,...						% poly2 (Subtrahend)
							PP,...																	% PP_local
							MAP_OBJECTS(imapobj1,1).h(1,1).UserData.color_no,...		% colno1
							MAP_OBJECTS(imapobj2,1).h(i,1).UserData.color_no);			% colno2
					end
					
					% % old:
					% poly_subtrahend	= polyshape();
					% d_side				= 0;
					% colno					= MAP_OBJECTS(imapobj1,1).h(1,1).UserData.color_no;
					% if colno>0
					% 	icolspec			= PP.color(colno).spec;
					% 	d_side			= max(d_side,PP.colorspec(icolspec).d_side);
					% end
					% for i=1:size(MAP_OBJECTS(imapobj2,1).h,1)
					% 	colno				= MAP_OBJECTS(imapobj2,1).h(i,1).UserData.color_no;
					% 	if colno>0
					% 		icolspec		= PP.color(colno).spec;
					% 		d_side		= max(d_side,PP.colorspec(icolspec).d_side);
					% 	end
					% 	poly_subtrahend(i,1)	= MAP_OBJECTS(imapobj2,1).h(i,1).Shape;
					% end
					% if strcmp(GV.jointtype_bh,'miter')
					% 	poly_subtrahend	= polybuffer(poly_subtrahend,d_side+GV.tol_1,...
					% 		'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
					% else
					% 	poly_subtrahend	= polybuffer(poly_subtrahend,d_side+GV.tol_1,...
					% 		'JointType',GV.jointtype_bh);
					% end
					% poly		= MAP_OBJECTS(imapobj1,1).h.Shape;
					% for i=1:size(poly_subtrahend,1)
					% 	poly		= subtract(...
					% 		poly,poly_subtrahend(i,1),...
					% 		'KeepCollinearPoints',false);
					% end
					
				otherwise
					% Object 2 is not a group:
					poly_subtrahend	= MAP_OBJECTS(imapobj2,1).h.Shape;
			end
			switch par1
				case 'union'
					poly		= union(...
						poly0,poly_subtrahend,...
						'KeepCollinearPoints',false);
				case 'intersect'
					poly		= intersect(...
						poly0,poly_subtrahend,...
						'KeepCollinearPoints',false);
				case 'xor'
					poly		= xor(...
						poly0,poly_subtrahend,...
						'KeepCollinearPoints',false);
				case 'addboundary'
					poly		= addboundary(...
						poly0,poly_subtrahend.Vertices,...
						'Simplify',true,'KeepCollinearPoints',false);
			end
			if GV.warnings_off
				warning('on','MATLAB:polyshape:repairedBySimplify');
			end
			% Cancel if poly is empty:
			if (numboundaries(poly)==0)
				errormessage(sprintf(['Error:\n',...
					'The %s result is empty.'],par1));
			end
			% New line:
			imapobj_new		= size(MAP_OBJECTS,1)+1;
			% Extend the userdata:
			ud					= MAP_OBJECTS(imapobj1,1).h.UserData;
			if ~isfield(ud,'in')
				ud.in				= [];
				ud.in				= ud.in(:);
			end
			if ~isfield(ud,'iw')
				ud.iw				= [];
				ud.iw				= ud.iw(:);
			end
			if ~isfield(ud,'ir')
				ud.ir				= [];
				ud.ir				= ud.ir(:);
			end
			if    ~strcmp(par1,'subtract')      &&...
					~strcmp(par1,'subtract_dside')&&...
					~strcmp(par1,'intersect')
				% The result of the operation also contains parts of MAP_OBJECTS(imapobj2,1).h:
				if isfield(MAP_OBJECTS(imapobj2,1).h(1,1).UserData,'in')
					ud.in				= unique([ud.in(:);MAP_OBJECTS(imapobj2,1).h(1,1).UserData.in(:)]);
				end
				if isfield(MAP_OBJECTS(imapobj2,1).h(1,1).UserData,'iw')
					ud.iw				= unique([ud.iw(:);MAP_OBJECTS(imapobj2,1).h(1,1).UserData.iw(:)]);
				end
				if isfield(MAP_OBJECTS(imapobj2,1).h(1,1).UserData,'ir')
					ud.ir				= unique([ud.ir(:);MAP_OBJECTS(imapobj2,1).h(1,1).UserData.ir(:)]);
				end
			end
			ud.shape0		= poly0;
			if MAP_OBJECTS(imapobj1,1).iobj>0
				imapobj_new_iobj	= MAP_OBJECTS(imapobj1,1).iobj;
			else
				imapobj_new_iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
			end
			disp_new			= MAP_OBJECTS(imapobj1,1).disp;
			dscr_new			= MAP_OBJECTS(imapobj1,1).dscr;
			method_textnew	= 2;
			switch method_textnew
				case 1
					% With this method: If several changes are made to an object, the texts can become too long.
					for itext=1:size(MAP_OBJECTS(imapobj1,1).text,1)
						if itext==1
							text1	= MAP_OBJECTS(imapobj1,1).text{itext,1};
						else
							text1	= [text1,' ',MAP_OBJECTS(imapobj1,1).text{itext,1}];
						end
					end
					for itext=1:size(MAP_OBJECTS(imapobj2,1).text,1)
						if itext==1
							text2	= MAP_OBJECTS(imapobj2,1).text{itext,1};
						else
							text2	= [text2,' ',MAP_OBJECTS(imapobj2,1).text{itext,1}];
						end
					end
					if ~contains(text1,text2)
						text_new		= {[text1 ' / ' text2]};
					else
						text_new		= {text1};
					end
				case 2
					% Do not change the text of object 1:
					text_new		= MAP_OBJECTS(imapobj1,1).text;
			end
			cncl_new			= MAP_OBJECTS(imapobj1,1).cncl;
			cnuc_new			= MAP_OBJECTS(imapobj1,1).cnuc;
			% Plot the preview as polygon:
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
			end
			h_poly	= plot(GV_H.ax_2dmap,poly,...
				'EdgeColor',MAP_OBJECTS(imapobj1,1).h.EdgeColor,...
				'FaceColor',MAP_OBJECTS(imapobj1,1).h.FaceColor,...
				'EdgeAlpha',MAP_OBJECTS(imapobj1,1).h.EdgeAlpha,...
				'FaceAlpha',MAP_OBJECTS(imapobj1,1).h.FaceAlpha,...
				'Visible'  ,'on',...
				'LineStyle',MAP_OBJECTS(imapobj1,1).h.LineStyle,...
				'LineWidth',MAP_OBJECTS(imapobj1,1).h.LineWidth,...
				'UserData' ,ud,...
				'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
			% Create/modify legend:
			create_legend_mapfigure;
			% Save relevant data in the structure MAP_OBJECTS:
			[xcenter,ycenter]						= centroid(poly);
			MAP_OBJECTS(imapobj_new,1).disp	= disp_new;
			MAP_OBJECTS(imapobj_new,1).h		= h_poly;
			MAP_OBJECTS(imapobj_new,1).iobj	= imapobj_new_iobj;
			MAP_OBJECTS(imapobj_new,1).dscr	= dscr_new;
			MAP_OBJECTS(imapobj_new,1).x		= xcenter;
			MAP_OBJECTS(imapobj_new,1).y		= ycenter;
			MAP_OBJECTS(imapobj_new,1).text	= text_new;
			MAP_OBJECTS(imapobj_new,1).mod	= false;
			MAP_OBJECTS(imapobj_new,1).cncl	= cncl_new;
			MAP_OBJECTS(imapobj_new,1).cnuc	= cnuc_new;
			MAP_OBJECTS(imapobj_new,1).vis0	= 1;
			
			% Select the new object::
			% plot_modify('deselect',[imapobj1;imapobj2],0);
			plot_modify('select',imapobj_new,0);
			
			% Delete the old objects (MAP_OBJECTS_TABLE will be updated also):
			% plot_modify('delete',[imapobj1;imapobj2]);		% Includes also display_map_objects
			plot_modify('delete',imapobj1);						% Includes also display_map_objects
			
			% Arrange imapobj_new (update MAP_OBJECTS_TABLE afterwards):
			if APP.AutoSortNewMapObjects_Menu.Checked
				arrange_imapobj_old	= size(MAP_OBJECTS,1);
				arrange_imapobj_new	= min(imapobj1,size(MAP_OBJECTS,1));
				arrange_map_objects(...
					arrange_imapobj_new,...				% position after the arrangement
					arrange_imapobj_old);				% position before the arrangement
			end
			
			% Update MAP_OBJECTS_TABLE:
			display_map_objects;
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'arrange'
			% Update MAP_OBJECTS_TABLE afterwards!
			
			% Check whether imapobj_v is a scalar:
			imapobj_v		= unique(imapobj_v);
			if max(diff(imapobj_v))>1
				errormessage(sprintf(['Error:\n',...
					'Only a range of plot objects with contiguous plot\n',...
					'numbers may be selected to use this function.']));
			end
			imapobj_old		= imapobj_v;
			
			switch par1
				case 'up'
					% Move object imapobj one row up:
					imapobj_new		= max(imapobj_old)+2;
					if imapobj_new<=(size(MAP_OBJECTS,1)+1)
						arrange_map_objects(imapobj_new,imapobj_old);
					end
					
				case 'down'
					% Move object imapobj one row down:
					imapobj_new		= min(imapobj_old)-1;
					if imapobj_new>=1
						arrange_map_objects(imapobj_new,imapobj_old);
					end
					
				case 'first'
					% Move object imapobj at the begin of MAP_OBJECTS or under all plot objects in the map:
					imapobj_new		= 1;
					if imapobj_new<min(imapobj_old)
						arrange_map_objects(imapobj_new,imapobj_old);
					end
					
				case 'last'
					% Move object imapobj at the end of MAP_OBJECTS or on top of all plot objects in the map:
					imapobj_new		= size(MAP_OBJECTS,1)+1;
					if imapobj_new>(max(imapobj_old)+1)
						arrange_map_objects(imapobj_new,imapobj_old);
					end
					
				case 'set'
					% Set the position of object imapobj:
					imapobj_new		= par2;
					if isnumeric(imapobj_new)
						if length(imapobj_new)==1
							if isreal(imapobj_new)
								imapobj_new	= round(imapobj_new);
								if ~any(imapobj_old==imapobj_new)&&...
										(imapobj_new>=1)&&...
										(imapobj_new<=(size(MAP_OBJECTS,1)+1))
									arrange_map_objects(imapobj_new,imapobj_old);
								end
							end
						end
					end
					
			end
			
			% Update MAP_OBJECTS_TABLE:
			display_map_objects;
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'printoutlim2poly'
			% Create preview polygon equal to the printout limits:
			
			% New line:
			imapobj_new		= size(MAP_OBJECTS,1)+1;
			% Userdata:
			ud					= [];
			ud.in				= [];
			ud.iw				= [];
			ud.ir				= [];
			ud.rotation		= 0;
			ud.shape0		= GV_H.poly_map_printout.Shape;
			% Plot the preview as polygon:
			if ~ishandle(GV_H.ax_2dmap)
				errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
			end
			h_poly	= plot(GV_H.ax_2dmap,GV_H.poly_map_printout.Shape,...
				'EdgeColor',GV.preview.EdgeColor,...
				'FaceColor',GV.preview.FaceColor,...
				'EdgeAlpha', GV.visibility.show.edgealpha,...
				'FaceAlpha',GV.visibility.show.facealpha,...
				'Visible'  ,'on',...
				'LineStyle',GV.preview.LineStyle,...
				'LineWidth',GV.preview.LineWidth,...
				'UserData',ud,...
				'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
			% Create/modify legend:
			create_legend_mapfigure;
			% Save relevant data in the structure MAP_OBJECTS:
			[xcenter,ycenter]						= centroid(GV_H.poly_map_printout.Shape);
			MAP_OBJECTS(imapobj_new,1).disp	= 'preview polygon';
			MAP_OBJECTS(imapobj_new,1).h		= h_poly;
			MAP_OBJECTS(imapobj_new,1).iobj	= min([[MAP_OBJECTS.iobj] 0])-1;
			MAP_OBJECTS(imapobj_new,1).dscr	= 'printout limits';
			MAP_OBJECTS(imapobj_new,1).x		= xcenter;
			MAP_OBJECTS(imapobj_new,1).y		= ycenter;
			MAP_OBJECTS(imapobj_new,1).text	= {''};
			MAP_OBJECTS(imapobj_new,1).mod	= false;
			MAP_OBJECTS(imapobj_new,1).cncl	= 0;
			MAP_OBJECTS(imapobj_new,1).cnuc	= 0;
			MAP_OBJECTS(imapobj_new,1).vis0	= 1;
			% Select the new objects:
			plot_modify('select',imapobj_new,0);
			
			
			% Update MAP_OBJECTS_TABLE:
			display_map_objects(imapobj_new);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'set_printout'
			% Set the printout limits:
			
			% Check whether imapobj_v is a scalar and the map object is a non-grouped polygon:
			if length(imapobj_v)>1
				errormessage(sprintf(['Error:\n',...
					'Only one object must be selected to use this function.']));
			end
			if length(MAP_OBJECTS(imapobj_v,1).h)>1
				errormessage(sprintf(['Error:\n',...
					'The selected object PlotNo=%g is grouped.\n',...
					'This function cannot be applied to grouped objects.'],imapobj_v));
			end
			if ~strcmp(MAP_OBJECTS(imapobj_v,1).h.Type,'polygon')
				errormessage(sprintf(['Error:\n',...
					'The selected object PlotNo=%g is of the type "%s".\n',...
					'This function is only applicable on polygons.'],imapobj_v,MAP_OBJECTS(imapobj_v,1).h.Type));
			end
			
			% Set the printout limits:
			poly	= MAP_OBJECTS(imapobj_v,1).h.Shape;
			poly	= intersect(poly,GV_H.poly_limits_osmdata.Shape,'KeepCollinearPoints',false);
			GV_H.poly_map_printout.Shape	= poly;
			
			% Distance between objects and printout limits:
			poly_obj_limits			= GV_H.poly_map_printout.Shape;
			dist_obj_printout			= max(0,PP.general.dist_obj_printout);
			if strcmp(GV.jointtype_bh,'miter')
				poly_obj_limits		= polybuffer(...
					poly_obj_limits,...
					-dist_obj_printout,'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
			else
				poly_obj_limits		= polybuffer(...
					poly_obj_limits,...
					-dist_obj_printout,'JointType',GV.jointtype_bh);
			end
			GV_H.poly_map_printout_obj_limits.Shape	= poly_obj_limits;
			
			% Create/modify Frame:
			plot_2dmap_frame;
			
			% The number of tiles possibly changes:
			% First plot_2dmap_frame must be called!
			plot_poly_tiles;
			
			% Create/modify legend:
			create_legend_mapfigure;
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'change_text'
			% Change text:
			
			% Abort or skip on error:
			if nargin<5
				abort_on_error		= true;
			else
				abort_on_error		= par3;
			end
			
			% Check imapobj_v:
			if length(imapobj_v)~=1
				errormessage(sprintf(['Error:\n',...
					'Exactly one object must be selected to use this function.']));
			end
			imapobj		= imapobj_v;
			if ~strcmp(MAP_OBJECTS(imapobj,1).disp,'text')
				errormessage(sprintf(['Error:\n',...
					'The selected object PlotNo=%g is displayed as "%s".\n',...
					'This function is only applicable on texts.'],imapobj,MAP_OBJECTS(imapobj,1).disp));
			end
			
			% The selected group must have 2 elements: text foreground and background:
			warntext		= '';
			if size(MAP_OBJECTS(imapobj,1).h,1)~=2
				errortext	= sprintf([...
					'The text cannot be changed because\n',...
					'the group has not 2 elements.\n',...
					'The group must have two elements:\n',...
					'the text foreground and the text background.']);
				if abort_on_error
					errormessage(sprintf('Error:\n%s',errortext));
				else
					warntext		= sprintf([...
						'Warning:\n',...
						'The character style of the map object with\n',...
						'the number PlotNo=%g cannot be updated:\n',...
						'%s'],imapobj,errortext);
				end
			end
			if isempty(warntext)
				level_0		= false;
				level_1		= false;
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if MAP_OBJECTS(imapobj,1).h(i,1).UserData.level==0
						% level=0: background:
						level_0		= true;
					elseif MAP_OBJECTS(imapobj,1).h(i,1).UserData.level==1
						% level=1: foreground (text)
						level_1		= true;
					end
				end
				if ~(level_0&&level_1)
					errortext	= sprintf([...
						'The text cannot be changed because\n',...
						'the 2 elements of the group are not\n',...
						'the foreground and background of a text.']);
					if abort_on_error
						errormessage(sprintf('Error:\n%s',errortext));
					else
						warntext		= sprintf([...
							'Warning:\n',...
							'The character style of the map object with\n',...
							'the number PlotNo=%g cannot be updated:\n',...
							'%s'],imapobj,errortext);
					end
				end
			end
			if ~isempty(warntext)
				fprintf(1,'\n%s\n',warntext);
				if isfield(GV_H.warndlg,'plot_modify')
					if ishandle(GV_H.warndlg.plot_modify)
						close(GV_H.warndlg.plot_modify);
					end
				end
				GV_H.warndlg.plot_modify		= warndlg(warntext,'Warning');
				GV_H.warndlg.plot_modify.Tag	= 'maplab3d_figure';
				if ~stateisbusy
					display_on_gui('state','','notbusy');
				end
				return
			end
			
			% Change texts:
			iobj					= MAP_OBJECTS(imapobj,1).iobj;
			if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'iteqt')
				iteqt				= MAP_OBJECTS(imapobj,1).h(1,1).UserData.iteqt;
			else
				% Texts of the legend:
				iteqt				= [];
			end
			text_eqtags_old	= MAP_OBJECTS(imapobj,1).h(1,1).UserData.text_eqtags;		% 1x1 cell array
			charstyle_no_old	= MAP_OBJECTS(imapobj,1).h(1,1).UserData.chstno;
			chstsettings_old	= MAP_OBJECTS(imapobj,1).h(1,1).UserData.chstsettings;
			rotation_old		= MAP_OBJECTS(imapobj,1).h(1,1).UserData.rotation;
			obj_purpose_old	= MAP_OBJECTS(imapobj,1).h(1,1).UserData.obj_purpose;
			
			% Change the characer style:
			if strcmp(par1,'charstyle')
				% Change the character style:
				charstyle_no	= par2;
				chstsettings	= PP.charstyle(charstyle_no,1);
			else
				% Change the text:
				charstyle_no	= charstyle_no_old;
				chstsettings	= chstsettings_old;
			end
			
			% Change the text:
			text_eqtags		= text_eqtags_old;
			if strcmp(par1,'text')
				% Ask for the new text:
				n_lines		= size(text_eqtags_old,1)+5;
				definput		= cell(n_lines,1);
				prompt		= cell(n_lines,1);
				for i=1:n_lines
					prompt{i,1}	= sprintf('Line %g:',i);
					if i<=size(text_eqtags_old,1)
						definput{i,1}	= text_eqtags_old{i,1};
					else
						definput{i,1}	= '';
					end
				end
				dlgtitle		= 'Enter the text';
				text_eqtags		= inputdlg_local(prompt,dlgtitle,[1 30],definput);		% heigth: 1 / width: 30
				if ~isempty(text_eqtags)
					% Delete empty rows:
					isempty_text_eqtags	= true(n_lines,1);
					for i=1:n_lines
						isempty_text_eqtags(i,1)	= isempty(text_eqtags{i,1});
					end
					text_eqtags(isempty_text_eqtags,:)	= [];
				end
			end
			
			% Call texteqtags2poly:
			if ~isempty(text_eqtags)
				% Do not check for
				% isequal(charstyle_no,charstyle_no_old) end
				% isequal(text_eqtags ,text_eqtags_old )
				% because also the text settings could have changed (PP.charstyle(chstno,1)).
				
				% The text should be in the same place as before.
				% Do not use the source data, so the current position of the text will not be changed.
				
				% Center point old polygon:
				poly	= MAP_OBJECTS(imapobj,1).h(1,1).Shape;
				for i=2:size(MAP_OBJECTS(imapobj,1).h,1)
					poly	= union(poly,MAP_OBJECTS(imapobj,1).h(i,1).Shape);
				end
				[xcenter_old,ycenter_old]			= centroid(poly);
				
				% Text parameters:
				[userdata_pp,textpar_pp,errortext]		= get_pp_mapobjsettings(iobj,'text',obj_purpose_old);
				if ~isempty(errortext)
					errormessage(errortext);
				end
				textpar_pp.charstyle_no				= charstyle_no;
				textpar_pp.rotation					= rotation_old;
				textpar_pp.line2refpoint_display	= 0;					% skip this calculation
				
				% New polygon:
				% Because the reference point is only one node, the size of poly_bgd, poly_obj is equal to the
				% number of text lines!
				connways_eqtags_select		= connect_ways([]);
				connways_eqtags_select		= ...
					connect_ways(...					%								Defaultvalues:
					connways_eqtags_select,...		% connways					-
					[],...								% connways_merge			[]
					xcenter_old,...					% x							[]
					ycenter_old,...					% y							[]
					iobj,...								% iobj						[]
					[],...								% lino						[]
					[],...								% liwi						[]
					0,...									% in							0
					0,...									% iw_v						0
					0,...									% ir							0
					1,...									% l2a							1
					1,...									% s							1
					1,...									% lino_new_min				1
					'outer',...							% role						'outer'
					uint64(0),...						% relid						uint64(0)
					'',...								% tag							''
					GV.tol_1,...						% tol							GV.tol_1
					true,...								% conn_with_rev			true
					true);								% connect					true
				[poly_bgd,poly_obj,~,~,~,~]		= texteqtags2poly(...
					iobj,...								% iobj
					iteqt,...							% iteqt
					text_eqtags,...					% text_eqtags
					connways_eqtags_select,...		% connways_eqtags
					'change_text',...					% text_symb
					chstsettings,...					% chstsettings
					userdata_pp,...					% userdata_pp (not used, the existing userdata is modified below)
					textpar_pp,...						% textpar_pp
					obj_purpose_old);					% obj_purpose
				
				% The text foreground must be inside the text background (less problems in map2stl.m):
				if numboundaries(poly_bgd)~=0
					poly_bgd_buff	= polybuffer(poly_bgd,-GV.d_forebackgrd_plotobj,...
						'JointType','miter','MiterLimit',2);
					poly_obj			= intersect(poly_obj,poly_bgd_buff,'KeepCollinearPoints',false);
				end
				
				% Center point new polygon:
				if numboundaries(poly_obj)==0
					errormessage;
				end
				poly	= poly_obj(1,1);
				for ipoly=2:size(poly_obj,1)
					poly	= union(poly,poly_obj(ipoly,1));
				end
				if numboundaries(poly_bgd)~=0
					for ipoly=1:size(poly_bgd,1)
						poly	= union(poly,poly_bgd(ipoly,1));
					end
				end
				[xcenter,ycenter]	= centroid(poly);
				
				% Translate the new polygon to the position of the old polygon:
				poly_obj				= translate(poly_obj,xcenter_old-xcenter,ycenter_old-ycenter);
				if numboundaries(poly_bgd)~=0
					poly_bgd			= translate(poly_bgd,xcenter_old-xcenter,ycenter_old-ycenter);
				end
				
				% Replace the old text by the first line of the new text: change structure MAP_OBJECTS:
				% (faster than creating the line anew and deleting the old one)
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if MAP_OBJECTS(imapobj,1).h(i,1).UserData.level==0
						% level=0: background:
						ud_bgd										= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
						MAP_OBJECTS(imapobj,1).h(i,1).UserData.shape0	= poly_bgd(1,1);
						MAP_OBJECTS(imapobj,1).h(i,1).Shape					= poly_bgd(1,1);
						edgecolor_bgd								= MAP_OBJECTS(imapobj,1).h(i,1).EdgeColor;
						facecolor_bgd								= MAP_OBJECTS(imapobj,1).h(i,1).FaceColor;
						edgealpha_bgd								= MAP_OBJECTS(imapobj,1).h(i,1).EdgeAlpha;
						facealpha_bgd								= MAP_OBJECTS(imapobj,1).h(i,1).FaceAlpha;
						linestyle_bgd								= MAP_OBJECTS(imapobj,1).h(i,1).LineStyle;
						linewidth_bgd								= MAP_OBJECTS(imapobj,1).h(i,1).LineWidth;
					else
						% level=1: foreground (text)
						ud_obj										= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
						MAP_OBJECTS(imapobj,1).h(i,1).UserData.shape0	= poly_obj(1,1);
						MAP_OBJECTS(imapobj,1).h(i,1).Shape					= poly_obj(1,1);
						edgecolor_fgd								= MAP_OBJECTS(imapobj,1).h(i,1).EdgeColor;
						facecolor_fgd								= MAP_OBJECTS(imapobj,1).h(i,1).FaceColor;
						edgealpha_fgd								= MAP_OBJECTS(imapobj,1).h(i,1).EdgeAlpha;
						facealpha_fgd								= MAP_OBJECTS(imapobj,1).h(i,1).FaceAlpha;
						linestyle_fgd								= MAP_OBJECTS(imapobj,1).h(i,1).LineStyle;
						linewidth_fgd								= MAP_OBJECTS(imapobj,1).h(i,1).LineWidth;
					end
					MAP_OBJECTS(imapobj,1).h(i,1).UserData.text_eqtags		= text_eqtags(1,1);	% must be undone when calling
					if charstyle_no~=charstyle_no_old
						% If the character style has not been changed: keep the character style settings
						% Otherwise change the character style settings:
						MAP_OBJECTS(imapobj,1).h(i,1).UserData.chstno			= charstyle_no;
						MAP_OBJECTS(imapobj,1).h(i,1).UserData.chstsettings	= PP.charstyle(charstyle_no,1);
					end
				end
				MAP_OBJECTS(imapobj,1).mod			= false;
				plot_modify('select',imapobj,0);															% Should be already selected
				% Center point:
				[xcenter,ycenter]						= centroid(union(poly_obj(1,1),poly_bgd(1,1)));
				MAP_OBJECTS(imapobj,1).x			= xcenter;
				MAP_OBJECTS(imapobj,1).y			= ycenter;
				
				% Create the rest of the new lines:
				for i_line=size(text_eqtags,1):-1:2
					
					imapobj_new						= size(MAP_OBJECTS,1)+1;
					MAP_OBJECTS(imapobj_new,1)	= MAP_OBJECTS(imapobj,1);
					ud_bgd.text_eqtags			= text_eqtags(i_line,1);
					ud_obj.text_eqtags			= text_eqtags(i_line,1);
					ud_bgd.shape0					= poly_bgd(i_line,1);
					ud_obj.shape0					= poly_obj(i_line,1);
					if charstyle_no~=charstyle_no_old
						% If the character style has not been changed: keep the character style settings
						% Otherwise change the character style settings:
						ud_bgd.chstno					= charstyle_no;
						ud_obj.chstno					= charstyle_no;
						ud_bgd.chstsettings			= PP.charstyle(charstyle_no,1);
						ud_obj.chstsettings			= PP.charstyle(charstyle_no,1);
					end
					
					% Every text line must have it's own source plot:
					% If a line is deleted, the source plots of the other source plots remain:
					source			= copy_source(ud_bgd);			% Create a new source data plot
					if ~isempty(source)
						ud_bgd.source	= source;
						ud_obj.source	= source;
					end
					
					% Text background:
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf(['There exists no map where to plot the objects.\n',...
							'Create the map first.']));
					end
					h_poly_bgd		= plot(GV_H.ax_2dmap,poly_bgd(i_line,1),...
						'EdgeColor'    ,edgecolor_bgd,...
						'FaceColor'    ,facecolor_bgd,...
						'EdgeAlpha'    ,edgealpha_bgd,...
						'FaceAlpha'    ,facealpha_bgd,...
						'Visible'      ,'on',...
						'LineStyle'    ,linestyle_bgd,...
						'LineWidth'    ,linewidth_bgd,...
						'UserData'     ,ud_bgd,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
					% The text foreground must be inside the text background (less problems in map2stl.m):
					poly_bgd_buff			= polybuffer(poly_bgd(i_line,1),-GV.d_forebackgrd_plotobj,...
						'JointType','miter','MiterLimit',2);
					poly_obj(i_line,1)	= intersect(poly_obj(i_line,1),poly_bgd_buff,'KeepCollinearPoints',false);
					
					% Text foreground:
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf(['There exists no map where to plot the objects.\n',...
							'Create the map first.']));
					end
					h_poly_txt		= plot(GV_H.ax_2dmap,poly_obj(i_line,1),...
						'EdgeColor'    ,edgecolor_fgd,...
						'FaceColor'    ,facecolor_fgd,...
						'EdgeAlpha'    ,edgealpha_fgd,...
						'FaceAlpha'    ,facealpha_fgd,...
						'Visible'      ,'on',...
						'LineStyle'    ,linestyle_fgd,...
						'LineWidth'    ,linewidth_fgd,...
						'UserData'     ,ud_obj,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
					
					% Save relevant data in the structure MAP_OBJECTS:
					MAP_OBJECTS(imapobj_new,1).h		= [h_poly_bgd;h_poly_txt];
					MAP_OBJECTS(imapobj,1).mod			= false;
					% Center point:
					[xcenter,ycenter]						= centroid(union(poly_obj(i_line,1),poly_bgd(i_line,1)));
					MAP_OBJECTS(imapobj,1).x			= xcenter;
					MAP_OBJECTS(imapobj,1).y			= ycenter;
					
					% Create/modify legend:
					if length(imapobj_v)==1
						create_legend_mapfigure;
					end
					
					% Select the new object:
					plot_modify('select',imapobj_new,0);
					
					% Arrange the new map objects (includes also display_map_objects):
					if APP.AutoSortNewMapObjects_Menu.Checked
						arrange_map_objects(...
							imapobj+1,...					% position after the arrangement
							imapobj_new);					% position before the arrangement
						
					end
					
					% Update MAP_OBJECTS_TABLE: already executed by arrange_map_objects
					if ~APP.AutoSortNewMapObjects_Menu.Checked
						display_map_objects;
					end
					
				end
				
			end
			
			% Update MAP_OBJECTS_TABLE:
			% display_map_objects;
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'change_color'
			% Change color:
			
			% Check imapobj_v:
			for k=1:length(imapobj_v)
				imapobj	= imapobj_v(k);
				if ~strcmp(MAP_OBJECTS(imapobj,1).h(1,1).Type,'polygon')
					errormessage(sprintf(['Error:\n',...
						'The selected object PlotNo=%g is of the type "%s".\n',...
						'This function is only applicable on polygons.'],imapobj,MAP_OBJECTS(imapobj,1).h.Type));
				end
			end
			
			% Change color:
			for k=1:length(imapobj_v)
				imapobj	= imapobj_v(k);
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if    isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'color_no')&&...
							isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'color_no_pp')
						color_no_pp		= MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no_pp;
						if MAP_OBJECTS(imapobj,1).h(i,1).UserData.level==0
							% level=0: background:
							color_no		= par2;
						else
							% level=1: foreground:
							color_no		= par1;
						end
						if ~isempty(color_no)
							if isequal(color_no,0)
								% Set the color to the same color as the background:
								facecolor		= 'none';
								linewidth		= GV.colorno_e0_linewidth;
							else
								if isequal(color_no,-1)
									% Reset the color number:
									if isequal(color_no_pp,0)
										facecolor		= 'none';
										linewidth		= GV.colorno_e0_linewidth;
									else
										facecolor		= PP.color(color_no_pp).rgb/255;
										linewidth		= GV.colorno_g0_linewidth;
									end
								else
									% Set the color number to color_no:
									facecolor		= PP.color(color_no).rgb/255;
									linewidth		= GV.colorno_g0_linewidth;
								end
							end
							if isequal(color_no,-1)
								MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no	= color_no_pp;
							else
								MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no	= color_no;
							end
							MAP_OBJECTS(imapobj,1).h(i,1).FaceColor			= facecolor;
							MAP_OBJECTS(imapobj,1).h(i,1).LineWidth			= linewidth;
						else
							errormessage;
						end
					end
				end
			end
			
			% Update MAP_OBJECTS_TABLE:
			display_map_objects(imapobj);
			
			%------------------------------------------------------------------------------------------------------------
		case 'change_liwi'
			% Change text:
			
			if length(imapobj_v)~=1
				errormessage(sprintf(['Error:\n',...
					'Exactly one object must be selected to use this function.']));
			end
			imapobj		= imapobj_v;
			if ~strcmp(MAP_OBJECTS(imapobj,1).disp,'line')
				errormessage(sprintf(['Error:\n',...
					'The selected object PlotNo=%g is displayed as "%s".\n',...
					'This function is only applicable on lines.'],imapobj,MAP_OBJECTS(imapobj,1).disp));
			end
			if length(MAP_OBJECTS(imapobj,1).h)>1
				errormessage(sprintf(['Error:\n',...
					'The selected object PlotNo=%g consists\n',...
					'of a group of %g objects.\n',...
					'First you have to ungroup the object.'],imapobj,length(MAP_OBJECTS(imapobj,1).h)));
			end
			iobj			= MAP_OBJECTS(imapobj,1).iobj;
			if PP.obj(iobj).linestyle~=3
				errormessage(sprintf(['Error:\n',...
					'The line width can only be changed if the linestyle parameter is 3.']));
			end
			linestyle	= 3;
			ud_line		= MAP_OBJECTS(imapobj,1).h.UserData;
			
			% Get the line parameters:
			% (without ud_line.linepar{4,1}: lifting dz (background) / mm)
			prompt_one_line{1,1}		= 'Minimum line width / mm';
			prompt_one_line{2,1}		= 'Maximum line width / mm';
			prompt_one_line{3,1}		= 'Sampling';
			prompt_one_line{4,1}		= 'Direction reversal (0/1)';
			prompt_one_line{5,1}		= 'Increase in line width / per thousand (>=0)';
			prompt_one_line{6,1}		= 'The maximum line width is not reached before the end of the line (0/1)';
			prompt_one_line{7,1}		= 'The maximum line width is always reached at the end of the line (0/1)';
			prompt						= prompt_one_line;
			prompt{1,1}					= sprintf([...
				'Change line width:\n',...
				'PlotNo %g / %s / %s\n',...
				'Total line length: %g mm\n',...
				'Current minimum line width: %g mm\n',...
				'Current maximum line width: %g mm\n',...
				'\n',...
				'Note:\n',...
				'The line is recreated using the data as with "File - Create map".\n',...
				'Subsequent changes such as "Move" or "Cut into pieces" will be lost.\n',...
				'\n',...
				'%s'],...
				imapobj,...
				MAP_OBJECTS(imapobj,1).dscr,...
				MAP_OBJECTS(imapobj,1).text{1,1},...
				ud_line.linelength,...
				ud_line.liwi_min,...
				ud_line.liwi_max,...
				prompt_one_line{1,1});
			definput{1,1}	= num2str(ud_line.linepar{1,1});
			definput{2,1}	= num2str(ud_line.linepar{2,1});
			definput{3,1}	= num2str(ud_line.linepar{3,1});
			definput{4,1}	= num2str(ud_line.linepar{5,1});
			definput{5,1}	= num2str(ud_line.linepar{6,1});
			definput{6,1}	= num2str(ud_line.linepar{7,1});
			definput{7,1}	= num2str(ud_line.linepar{8,1});
			dlgtitle		= 'Enter line parameters';
			dims			= 1;
			warntext		= 'xxxxx';
			while ~isempty(warntext)
				answer		= inputdlg_local(prompt,dlgtitle,dims,definput);
				if size(answer,1)~=7
					% Cancel:
					if ~stateisbusy
						display_on_gui('state','','notbusy');
					end
					return
				end
				warntext			= '';
				ud_linepar_new	= cell(7,1);
				for i=1:7
					if ~isempty(strfind(answer{i,1},','))
						warntext	= sprintf([...
							'Error:\n',...
							'Invalid character '','' in\n',...
							'%s = %s\n',...
							'Use the decimal point ''.'' as decimal separator .'],prompt_one_line{i,1},answer{i,1});
						break
					else
						ud_linepar_new{i,1}	= str2double(answer{i,1});
						if isnan(ud_linepar_new{i,1})
							warntext	= sprintf([...
								'Error:\n',...
								'The value\n',...
								'%s = %s\n',...
								'must be numeric and scalar.'],prompt_one_line{i,1},answer{i,1});
							break
						end
					end
				end
				if ~isempty(warntext)
					if isfield(GV_H.warndlg,'plot_modify')
						if ishandle(GV_H.warndlg.plot_modify)
							close(GV_H.warndlg.plot_modify);
						end
					end
					warntext	= sprintf('%s\nPress OK to repeat.',warntext);
					GV_H.warndlg.plot_modify		= warndlg(warntext,'Warning');
					GV_H.warndlg.plot_modify.Tag	= 'maplab3d_figure';
					while ishandle(GV_H.warndlg.plot_modify)
						pause(0.2);
					end
				end
			end
			ud_line.linepar{1,1}	= ud_linepar_new{1,1};	% Minimum line width / mm
			ud_line.linepar{2,1}	= ud_linepar_new{2,1};	% Maximum line width / mm
			ud_line.linepar{3,1}	= ud_linepar_new{3,1};	% Sampling
			% ud_line.linepar{4,1}								  lifting dz (background) / mm
			ud_line.linepar{5,1}	= ud_linepar_new{4,1};	% Direction reversal (0/1)
			ud_line.linepar{6,1}	= ud_linepar_new{5,1};	% Increase in line width / per thousand (>=0)
			ud_line.linepar{7,1}	= ud_linepar_new{6,1};	% The max line width is not reached before the end of the line (0/1)
			ud_line.linepar{8,1}	= ud_linepar_new{7,1};	% The max line width is always reached at the end of the line (0/1)
			
			% Parameters for line plots (see also plotosmdata_plotdata_li_ar.m):
			jointtype		= 'miter';
			miterlimit		= 1;
			
			% Downsampling (see also plotosmdata_plotdata_li_ar.m):
			dmax				= [];
			nmin				= [];
			dmin_lines		= PP.obj(iobj).reduce_lines.dmin;			% minimum distance between vertices
			
			% Create the new line:
			% The assignment of in, iw, and ir is not necessary here.
			[  poly_line,...							% poly_line
				~,...										% poly_lisy
				ud_line_new,...						% ud_line
				~]				= ...						% ud_lisy
				line2poly(...
				ud_line.x,...							% x
				ud_line.y,...							% y
				ud_line.linepar,...					% par
				linestyle,...							% style
				iobj,...									% iobj
				ud_line.obj_purpose,...				% obj_purpose
				jointtype,...							% jointtype
				miterlimit);							% miterlimit
			poly_line		= changeresolution_poly(poly_line,dmax,dmin_lines,nmin);
			
			% Change the map object:
			MAP_OBJECTS(imapobj,1).h.Shape						= poly_line;
			
			% Save the userdata that has possibly changed and don't change the rest:
			MAP_OBJECTS(imapobj,1).h.UserData.linepar			= ud_line_new.linepar;
			MAP_OBJECTS(imapobj,1).h.UserData.liwi_min		= ud_line_new.liwi_min;
			MAP_OBJECTS(imapobj,1).h.UserData.liwi_max		= ud_line_new.liwi_max;
			MAP_OBJECTS(imapobj,1).h.UserData.xy_liwimin		= ud_line_new.xy_liwimin;
			MAP_OBJECTS(imapobj,1).h.UserData.xy_liwimax		= ud_line_new.xy_liwimax;
			MAP_OBJECTS(imapobj,1).h.UserData.rotation		= 0;
			MAP_OBJECTS(imapobj,1).h.UserData.shape0			= poly_line;
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'change_description'
			% Change description:
			
			% Check imapobj_v:
			if length(imapobj_v)~=1
				errormessage(sprintf(['Error:\n',...
					'Exactly one object must be selected to use this function.']));
			end
			imapobj		= imapobj_v;
			
			% Change the description:
			prompt	= {sprintf('Enter the new description of plot object %g:',imapobj)};
			dlgtitle	= 'Enter description';
			dims		= 1;
			definput	= {MAP_OBJECTS(imapobj,1).dscr};
			answer	= inputdlg_local(prompt,dlgtitle,dims,definput);
			if ~isempty(answer)
				MAP_OBJECTS(imapobj,1).dscr	= answer{1};
			else
				if ~stateisbusy
					display_on_gui('state','','notbusy');
				end
				return
			end
			
			% Update MAP_OBJECTS_TABLE:
			display_map_objects(imapobj);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'change_texttag'
			% Change description:
			
			% Check imapobj_v:
			if length(imapobj_v)~=1
				errormessage(sprintf(['Error:\n',...
					'Exactly one object must be selected to use this function.']));
			end
			imapobj		= imapobj_v;
			
			% Change the description:
			prompt		= cell(size(MAP_OBJECTS(imapobj,1).text,1),1);
			if size(MAP_OBJECTS(imapobj,1).text,1)==1
				prompt{1,1}	= sprintf('Enter the new text/tag of plot object %g:',imapobj);
			else
				for i=1:size(MAP_OBJECTS(imapobj,1).text,1)
					prompt{i,1}	= sprintf('Enter the new text/tag of plot object %g: Line %g',imapobj,i);
				end
			end
			dlgtitle	= 'Enter text/tag';
			dims		= 1;
			definput	= MAP_OBJECTS(imapobj,1).text;
			answer	= inputdlg_local(prompt,dlgtitle,dims,definput);
			if ~isempty(answer)
				MAP_OBJECTS(imapobj,1).text	= answer;
			else
				if ~stateisbusy
					display_on_gui('state','','notbusy');
				end
				return
			end
			
			% Update MAP_OBJECTS_TABLE:
			display_map_objects(imapobj);
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'enter_circle'
			% Enter the data and draw a circle.
			
			% Enter the data:
			definput		= GV.plotmodify.entercircle_definput;
			prompt		= {...
				'Radius / mm';...										% radius
				'Start angle / degree';...							% phi_start
				'End angle / degree';...							% phi_end
				'angle step size / degree';...					% phi_step
				'Center point: x / mm (empty: map view)';...	% centerpoint_x
				'Center point: y / mm (empty: map view)'};		% centerpoint_y
			dlgtitle		= 'Enter circle parameters';
			warntext		= 'xxxxx';
			while ~isempty(warntext)
				answer		= inputdlg_local(prompt,dlgtitle,1,definput);
				if size(answer,1)~=6
					if ~stateisbusy
						display_on_gui('state','','notbusy');
					end
					return
				end
				warntext		= '';
				if    ~isempty(strfind(answer{1,1},','))||...
						~isempty(strfind(answer{2,1},','))||...
						~isempty(strfind(answer{3,1},','))||...
						~isempty(strfind(answer{4,1},','))||...
						~isempty(strfind(answer{5,1},','))||...
						~isempty(strfind(answer{6,1},','))
					warntext	= sprintf([...
						'Error:\n',...
						'Invalid character '',''.\n',...
						'Use the decimal point ''.'' as decimal separator.']);
				else
					radius			= str2double(answer{1,1});
					phi_start		= str2double(answer{2,1});
					phi_end			= str2double(answer{3,1});
					phi_step			= str2double(answer{4,1});
					if isempty(answer{5,1})
						centerpoint_x	= mean(GV_H.ax_2dmap.XLim);
					else
						centerpoint_x	= str2double(answer{5,1});
					end
					if isempty(answer{6,1})
						centerpoint_y	= mean(GV_H.ax_2dmap.YLim);
					else
						centerpoint_y	= str2double(answer{6,1});
					end
					if    any(isnan(radius))       ||...
							any(isnan(phi_start))    ||...
							any(isnan(phi_end))      ||...
							any(isnan(phi_step))     ||...
							any(isnan(centerpoint_x))||...
							any(isnan(centerpoint_y))
						warntext	= sprintf([...
							'Error:\n',...
							'Invalid values.\n',...
							'You must enter numbers.']);
					end
				end
				if ~isempty(warntext)
					if isfield(GV_H.warndlg,'plot_modify')
						if ishandle(GV_H.warndlg.plot_modify)
							close(GV_H.warndlg.plot_modify);
						end
					end
					warntext	= sprintf('%s\nPress OK to repeat.',warntext);
					GV_H.warndlg.plot_modify		= warndlg(warntext,'Warning');
					GV_H.warndlg.plot_modify.Tag	= 'maplab3d_figure';
					while ishandle(GV_H.warndlg.plot_modify)
						pause(0.2);
					end
				end
			end
			GV.plotmodify.entercircle_definput	= answer;
			x_v	= centerpoint_x+radius*cos((phi_start:phi_step:phi_end)'*pi/180);
			y_v	= centerpoint_y+radius*sin((phi_start:phi_step:phi_end)'*pi/180);
			if    (abs(x_v(1)-x_v(end))<GV.tol_1)&&...
					(abs(y_v(1)-y_v(end))<GV.tol_1)
				x_v		= x_v(1:(end-1));
				y_v		= y_v(1:(end-1));
			end
			
			% Draw the circle:
			plot_modify('new_line',0,...
				x_v,...			% x-values of the new vertex/vertices
				y_v);        	% y-values of the new vertex/vertices
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'enter_rectangle'
			% Enter the data and draw a rectangle.
			
			% Enter the data:
			definput		= GV.plotmodify.enterrectangle_definput;
			prompt		= {...
				'Width / mm';...											% rect_width
				'Depth / mm';...											% rect_height
				sprintf('Center x / mm (empty: map view)');...	% rect_rect_center_x
				sprintf('Center y / mm (empty: map view)')};		% rect_rect_center_y
			dlgtitle		= 'Enter rectangle parameters';
			warntext		= 'xxxxx';
			while ~isempty(warntext)
				answer		= inputdlg_local(prompt,dlgtitle,1,definput);
				if size(answer,1)~=4
					if ~stateisbusy
						display_on_gui('state','','notbusy');
					end
					return
				end
				warntext		= '';
				if    ~isempty(strfind(answer{1,1},','))||...
						~isempty(strfind(answer{2,1},','))||...
						~isempty(strfind(answer{3,1},','))||...
						~isempty(strfind(answer{4,1},','))
					warntext	= sprintf([...
						'Error:\n',...
						'Invalid character '',''.\n',...
						'Use the decimal point ''.'' as decimal separator.']);
				else
					rect_width		= str2double(answer{1,1});
					rect_height		= str2double(answer{2,1});
					if isempty(answer{3,1})
						rect_center_x	= mean(GV_H.ax_2dmap.XLim);
					else
						rect_center_x	= str2double(answer{3,1});
					end
					if isempty(answer{4,1})
						rect_center_y	= mean(GV_H.ax_2dmap.YLim);
					else
						rect_center_y	= str2double(answer{4,1});
					end
					if    any(isnan(rect_width))   ||...
							any(isnan(rect_height))  ||...
							any(isnan(rect_center_x))||...
							any(isnan(rect_center_y))
						warntext	= sprintf([...
							'Error:\n',...
							'Invalid values.\n',...
							'You must enter numbers.']);
					end
				end
				if ~isempty(warntext)
					if isfield(GV_H.warndlg,'plot_modify')
						if ishandle(GV_H.warndlg.plot_modify)
							close(GV_H.warndlg.plot_modify);
						end
					end
					warntext	= sprintf('%s\nPress OK to repeat.',warntext);
					GV_H.warndlg.plot_modify		= warndlg(warntext,'Warning');
					GV_H.warndlg.plot_modify.Tag	= 'maplab3d_figure';
					while ishandle(GV_H.warndlg.plot_modify)
						pause(0.2);
					end
				end
			end
			GV.plotmodify.enterrectangle_definput	= answer;
			x_v	= [...
				rect_center_x+rect_width/2;...
				rect_center_x-rect_width/2;...
				rect_center_x-rect_width/2;...
				rect_center_x+rect_width/2];
			y_v	= [...
				rect_center_y+rect_height/2;...
				rect_center_y+rect_height/2;...
				rect_center_y-rect_height/2;...
				rect_center_y-rect_height/2];
			
			% Draw the rectangle:
			plot_modify('new_line',0,...
				x_v,...			% x-values of the new vertex/vertices
				y_v);        	% y-values of the new vertex/vertices
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'textfile'
			% Save and load map object boundaries:
			
			% Project directory:
			if ~isfield(GV,'projectdirectory')
				% The path name has not yet been requested:
				projectdirectory		= SETTINGS.projectdirectory;
			else
				% The path name has already been requested:
				projectdirectory		= GV.projectdirectory;
			end
			if isnumeric(projectdirectory)
				projectdirectory		= SETTINGS.default_pathname;
			else
				if exist(projectdirectory,'dir')~=7
					% The project directory does not exist:
					projectdirectory	= SETTINGS.default_pathname;
				end
			end
			
			switch par1
				case 'to'
					% Save map object boundaries to text file:
					
					% Get the file name:
					[filename,pathname]	= uiputfile_local('*.txt','Select destination file',projectdirectory);
					% If the user clicks Cancel or the window close button (X):
					if isequal(filename,0)||isequal(pathname,0)
						if ~stateisbusy
							display_on_gui('state','','notbusy');
						end
						return
					end
					
					% Get the xy-data of all selected objects:
					x_v		= [];
					y_v		= [];
					for i_imapobj=1:length(imapobj_v)
						imapobj		= imapobj_v(i_imapobj);
						for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
							if strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'line')
								xi_v			= MAP_OBJECTS(imapobj,1).h(i,1).XData';
								yi_v			= MAP_OBJECTS(imapobj,1).h(i,1).YData';
							elseif strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon')
								[xi_v,yi_v]	= boundary(MAP_OBJECTS(imapobj,1).h(i,1).Shape);
							end
							xi_v			= xi_v(:);
							yi_v			= yi_v(:);
							x_v			= [x_v;nan;xi_v];
							y_v			= [y_v;nan;yi_v];
						end
					end
					[x_v,y_v]		= removeExtraNanSeparators(x_v,y_v);
					
					% Save to tab-delimited ASCII file:
					if ~isempty(x_v)
						% The commands "save" and "writematrix" do not support 'DecimalSeparator'.
						if ~strcmp(filename((end-3):end),'.txt')
							filename		= [filename '.txt'];
						end
						pathfilename	= [pathname filename];
						xydata_str		= '';
						for r=1:size(x_v,1)
							if ~isnan(x_v(r,1))
								xydata_str		= sprintf('%s%s\t%s',xydata_str,num2str(x_v(r,1)),num2str(y_v(r,1)));
							end
							if r<size(x_v,1)
								xydata_str		= sprintf('%s\n',xydata_str);
							end
						end
						if ~strcmp(PP.general.decimalseparator,'.')
							k					= strfind(xydata_str,'.');
							xydata_str(k)	= PP.general.decimalseparator;
						end
						fileID				= fopen(pathfilename,'w');
						fprintf(fileID,'%s',xydata_str);
						fclose(fileID);
					end
					
				case 'from'
					% Load map object boundaries from text file:
					
					% Get the file name:
					[filename,pathname]	= uigetfile_local('*.txt','Select source file',projectdirectory);
					% If the user clicks Cancel or the window close button (X):
					if isequal(filename,0)||isequal(pathname,0)
						if ~stateisbusy
							display_on_gui('state','','notbusy');
						end
						return
					end
					
					% Load the ASCII file:
					pathfilename			= [pathname filename];
					error_wrongformat		= false;
					try
						xydata	= readmatrix(pathfilename,...
							'EmptyLineRule','read',...
							'DecimalSeparator',PP.general.decimalseparator,...
							'OutputType','double');
					catch
						xydata					= [];
					end
					if size(xydata,2)~=2
						error_wrongformat		= true;
					else
						if any(isnan(xydata(:,1))~=isnan(xydata(:,2)))
							error_wrongformat		= true;
						end
					end
					if error_wrongformat
						errormessage(sprintf([...
							'Error: The file\n',...
							'%s\n',...
							'must meet the following conditions:\n',...
							'- Text format\n',...
							'- Decimal separator: "%s"\n',...
							'  (Project parameter general.decimalseparator)\n',...
							'- Delimiter: Tab\n',...
							'- No header\n',...
							'- Exactly two columns:\n',...
							'  1. column: x-values\n',...
							'  2. column: y-values\n',...
							'  Both values ​​must be specified or empty.\n',...
							'- A new preview line begins after an empty row.'],...
							pathfilename,PP.general.decimalseparator));
					end
					
					% Draw the data:
					[xdata,ydata]					= removeExtraNanSeparators(xydata(:,1),xydata(:,2));
					[xdata_cells,ydata_cells]	= polysplit(xdata,ydata);
					for r=1:size(xdata_cells,1)
						plot_modify('new_line',0,...
							xdata_cells{r,1},...			% x-values of the new vertex/vertices
							ydata_cells{r,1},...       % y-values of the new vertex/vertices
							filename);						% optional: description
					end
				otherwise
					errormessage;
			end
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'change_relid'
			% Change the relation ID of preview lines or preview polygons:
			
			% Check imapobj_v:
			if length(imapobj_v)~=1
				errormessage(sprintf(['Error:\n',...
					'Exactly one object must be selected to use this function.']));
			end
			imapobj		= imapobj_v;
			
			% Enter the new relation ID:
			definput		= {num2str(par1)};
			prompt		= {sprintf([...
				'Enter the new relation ID:\n',...
				'This information is used to subsequently convert a preview line or a preview polygon into a map ',...
				'object using the "%s" function and the "%s" checkbox activated, in the same way as when calling ',...
				'the "%s" function.\n',...
				'This can be used, for example, to subsequently manually close incomplete lines at the margin of ',...
				'the map (DispAs=''area - not closed'') and convert them into an area.\n',...
				'The effects of the ID are:\n',...
				'- All objects with the same relation ID>0 are merged using "addboundary":\n',...
				'  You can add a hole to an existing area (for example a clearing in a forest)\n',...
				'  or you can convert an area into a hole by adding an outer boundary\n',...
				'  (for example an island in a sea to make the island a hole in the water).\n',...
				'- All objects that do not belong to a relation (ID=0) are merged using "union".\n',...
				'  If an area covers a hole, the boundary of the hole disappears.'],...
				APP.Mod_ConvPrevToMapobj_Button.Text,...				% 'Polygon to map object'
				APP.Mod_MergeWithExistObj_CheckBox.Text,...			% 'Merge'
				APP.CreatemapMenu.Text)};									% 'Create map'
			dlgtitle		= 'Enter relation ID';
			warntext		= 'xxxxx';
			while ~isempty(warntext)
				answer		= inputdlg_local(prompt,dlgtitle,1,definput);
				if size(answer,1)~=1
					if ~stateisbusy
						display_on_gui('state','','notbusy');
					end
					return
				end
				warntext		= '';
				relid			= str2double(answer{1,1});
				if    any(isnan(relid))||...
						(length(relid)~=1)
					warntext	= sprintf([...
						'Error:\n',...
						'Invalid value.\n',...
						'You must enter a number.']);
				else
					if ~isequal(relid,round(relid))
						warntext	= sprintf([...
							'Error:\n',...
							'Invalid value.\n',...
							'You must enter a whole number.']);
					end
				end
				ir		= find(OSMDATA.id.relation==relid,1);
				if isempty(ir)
					warntext	= sprintf([...
						'Error:\n',...
						'The ID %g does not exist in the loaded OSM data.'],relid);
				end
				if ~isempty(warntext)
					if isfield(GV_H.warndlg,'plot_modify')
						if ishandle(GV_H.warndlg.plot_modify)
							close(GV_H.warndlg.plot_modify);
						end
					end
					warntext	= sprintf('%s\nPress OK to repeat.',warntext);
					GV_H.warndlg.plot_modify		= warndlg(warntext,'Warning');
					GV_H.warndlg.plot_modify.Tag	= 'maplab3d_figure';
					while ishandle(GV_H.warndlg.plot_modify)
						pause(0.2);
					end
				end
			end
			relid		= uint64(relid);
			
			% Assign the relation ID:
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				MAP_OBJECTS(imapobj,1).h(i,1).UserData.relid		= relid;
				% Note:
				% The value ir is not assigned to MAP_OBJECTS(imapobj,1).h(i,1).UserData.ir
				% because preview objects should be freely combinable.
			end
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'delete_all_previews'
			
			% Color number of cutting lines (=0: normal preview):
			cncl				= get_colno_cuttingline;
			% User confirmation:
			if isequal(imapobj0_v,-1)
				answer	= [];
				while isempty(answer)
					if cncl==0
						question	= 'Delete all previews?';
					else
						question	= sprintf([...
							'Delete all preview cutting lines\n',...
							'of color number %g?'],cncl);
					end
					answer	= questdlg_local(question,'Delete preview cutting lines?','Continue','Cancel','Cancel');
				end
				if strcmp(answer,'Cancel')
					if ~stateisbusy
						display_on_gui('state','','notbusy');
					end
					return
				end
			end
			if ~isempty(MAP_OBJECTS)
				imapobj_v			= find(...
					([MAP_OBJECTS.iobj]<=-1  )&...
					([MAP_OBJECTS.cncl]==cncl)    );
				imapobj_v_delete	= false(size(MAP_OBJECTS,1),1);
			end
			for k=1:length(imapobj_v)
				% Waitbar:
				if waitbar_activ
					if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
						waitbar_t1	= clock;
						progress		= min((k-1)/length(imapobj_v),1);
						set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
						drawnow;
					end
				end
				if contains(lower(MAP_OBJECTS(imapobj_v(k),1).disp),'preview')
					delete(MAP_OBJECTS(imapobj_v(k),1).h);
					imapobj_v_delete(imapobj_v(k),1)	= true;
				end
			end
			MAP_OBJECTS		= MAP_OBJECTS(~imapobj_v_delete,1);
			
			% Update MAP_OBJECTS_TABLE:
			display_map_objects;
			
			
			%------------------------------------------------------------------------------------------------------------
		case 'delete_lastadded_preview'
			
			% User confirmation:
			% if isequal(imapobj0_v,-1)
			%	answer	= [];
			%	while isempty(answer)
			%		question	= 'Delete last added preview?';
			%		answer	= questdlg_local(question,'Delete last added preview object?','Continue','Cancel','Cancel');
			%	end
			%	if strcmp(answer,'Cancel')
			%		if ~stateisbusy
			%			display_on_gui('state','','notbusy');
			%		end
			%		return
			%	end
			% end
			
			[~,imapobj]	= min([MAP_OBJECTS.iobj]);
			if MAP_OBJECTS(imapobj,1).iobj<=-1
				delete(MAP_OBJECTS(imapobj).h);
				MAP_OBJECTS		= MAP_OBJECTS([MAP_OBJECTS.iobj]~=min([MAP_OBJECTS.iobj]));
			end
			
			% Update MAP_OBJECTS_TABLE:
			display_map_objects;
			
			
	end
	
	% The map has been changed:
	GV.map_is_saved	= 0;
	
	% Reset waitbar:
	if waitbar_activ
		set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
		set(GV_H.text_waitbar,'String','');
	end
	
	% Display state:
	if ~stateisbusy
		% t_plot_modify	= etime(clock,t_start_statebusy)
		display_on_gui('state','','notbusy');		% Includes also display_on_gui_selectedmapobjects
	else
		% Display number and PlotNo of selected map objects:
		display_on_gui_selectedmapobjects;
		if ~strcmp(action,'select')&&~strcmp(action,'deselect')&&~strcmp(action,'delete')
			drawnow;
		end
	end
	
catch ME
	errormessage('',ME);
end


