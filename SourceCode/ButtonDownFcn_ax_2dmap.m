function ButtonDownFcn_ax_2dmap(clicked_object,event_data,rbbox_pos)

global MAP_OBJECTS GV_H GV APP

% Because this function can be called directly by the user through a callback,
% a try/catch statement must be used here:
try
	
	% Delete an existing contextmenu, otherwise it will be displayed instead of the new one:
	% Doing this at the beginning of this function seems to work.
	
	% if isprop(clicked_object,'ContextMenu')&&(event_data.Button==1)
	
	% The contextmenu calculated here cannot be displayed at the same time.
	% The "open" function does not work, because the map figure was not created with the uifigure function.
	% Solution: The user must click two times on the same object at the same position.
	% Delete the existing context menu if:
	% -	the last left-clicked point was different to the actual clicked intersection point
	% -	the clicked object is different to the last clicked object
	if isprop(clicked_object,'ContextMenu')
		if    (event_data.IntersectionPoint(1,1)<GV.fig_2dmap_cm.lc_xmin)||...		% x_ip
				(event_data.IntersectionPoint(1,1)>GV.fig_2dmap_cm.lc_xmax)||...
				(event_data.IntersectionPoint(1,2)<GV.fig_2dmap_cm.lc_ymin)||...		% y_ip
				(event_data.IntersectionPoint(1,2)>GV.fig_2dmap_cm.lc_ymax)||...
				~isequal(clicked_object,GV.fig_2dmap_cm.clicked_object)
			GV.fig_2dmap_cm.lc_xmin						= 1;
			GV.fig_2dmap_cm.lc_xmax						= -1;
			GV.fig_2dmap_cm.lc_ymin						= 1;
			GV.fig_2dmap_cm.lc_ymax						= -1;
			GV.fig_2dmap_cm.clicked_object			= [];
			GV.fig_2dmap_cm.poly_outside_spec		= polyshape();
			GV.fig_2dmap_cm.poly_dzmax					= polyshape();
			delete(clicked_object.ContextMenu);
		end
	end
	
	imapobj				= [];
	cancelsearching	= false;
	for i=1:size(MAP_OBJECTS,1)
		for r=1:size(MAP_OBJECTS(i,1).h,1)
			for c=1:size(MAP_OBJECTS(i,1).h,2)
				if isequal(clicked_object,MAP_OBJECTS(i,1).h(r,c))
					% if MAP_OBJECTS(imapobj,1).h(r,c).Selected
					imapobj				= i;
					cancelsearching	= true;
					break
				end
			end
			if cancelsearching
				break
			end
		end
		if cancelsearching
			break
		end
	end
	
	% Rubberband box:
	if GV.mouse_interaction_method==1
		rbbox_method		= 4;
		switch rbbox_method
			case 1
				rbbox_pos	= rbbox;
			case 2
				% Disabling HandleVisibility for all objects except the figure of the 2D map speeds up execution.
				% discovered through trial and error
				objects_all		= findobj('HandleVisibility','on','-not','Name','2D map');
				set(objects_all,'HandleVisibility','off');
				rbbox_pos	= rbbox;
				set(objects_all,'HandleVisibility','on');
		end
	elseif GV.mouse_interaction_method==2
		% rbbox_pos already exists
	end
	
	% Example parameters:
	% rbbox_pos =
	%    239   199    55    52
	% 	rbbox_pos = [220   228     0     0]
	% 	clicked_object = Polygon with properties:
	%     FaceColor: [0.8627 0.8627 0.8627]
	%     FaceAlpha: 0.3500
	%     EdgeColor: [0 0 0]
	%     LineWidth: 0.5000
	%     LineStyle: '-'
	%         Shape: [1×1 polyshape]
	% event_data = Hit with properties:
	%                Button: 1
	%     IntersectionPoint: [-120.8314 137.0865 9.4118e-07]
	%                Source: [1×1 Polygon]
	%             EventName: 'Hit'
	
	tol_pixel	= 10;
	% Conversion between axis data units and figure pixel:
	%                              +------------------------------------------------------------------+
	%                              |                                                           figure |
	%                              |                                                                  |
	%                          -   |     ylim(2) +-------------------------------------------+        |
	%                          ^   |             |                                      axis |        |
	%                          |   |             |                                           |        |
	%                          |   |             |                                           |        |
	%                          |   |             |                                           |        |
	%                          |   |             |                                           |        |
	%                 axpos(4) |   |             |                                           |        |
	%                          |   |             |                                           |        |
	%                          |   |           y +-------------+                             |        |
	%                          |   |             |             |                             |        |
	%                          |   |             |             |                             |        |
	%                          v   |             |             |                             |        |
	%                axpos(2)---   |     ylim(1) +-------------+-----------------------------+        |
	%                =45pixel      |          xlim(1)          x                          xlim(2)     |
	%                              |                                                                  |
	%                              +------------------------------------------------------------------+
	%
	%                                            |                  axpos(3)                 |
	%                                            |<----------------------------------------->|
	%                                         axpos(1)=75pixel
	% Equation of a line:
	% x_pixel = axpos(1)+     axpos(3)    /(xlim(2)-xlim(1))*(x      -xlim(1) )
	% x       = xlim(1) +(xlim(2)-xlim(1))/    axpos(3)     *(x_pixel-axpos(1))
	% x_pixel = axpos(1)+ mx *(x      -xlim(1) )
	% x       = xlim(1) +1/mx*(x_pixel-axpos(1))
	mx	= GV_H.ax_2dmap.Position(3)/(GV_H.ax_2dmap.XLim(2)-GV_H.ax_2dmap.XLim(1));
	my	= GV_H.ax_2dmap.Position(4)/(GV_H.ax_2dmap.YLim(2)-GV_H.ax_2dmap.YLim(1));
	% Clicked points:
	% Make the point 1 (x1,y1) the start point of the line and the point 2 (x2,y2) the end point of the line:
	x_ip			= event_data.IntersectionPoint(1,1);
	y_ip			= event_data.IntersectionPoint(1,2);
	x_ip_pixel	= GV_H.ax_2dmap.Position(1)+mx*(x_ip-GV_H.ax_2dmap.XLim(1));
	y_ip_pixel	= GV_H.ax_2dmap.Position(2)+my*(y_ip-GV_H.ax_2dmap.YLim(1));
	x1_pixel		= rbbox_pos(1);
	x2_pixel		= rbbox_pos(1)+rbbox_pos(3);
	if     abs(x1_pixel-x_ip_pixel)<=tol_pixel
		% nop
	elseif abs(x2_pixel-x_ip_pixel)<=tol_pixel
		x1_pixel		= rbbox_pos(1)+rbbox_pos(3);
		x2_pixel		= rbbox_pos(1);
	else
		% This happens, if the axis position has changed:
		% Set the axis position:
		SizeChangedFcn_fig_2dmap([],[],0,0);
		errormessage('Error: Try again.');
	end
	y1_pixel		= rbbox_pos(2);
	y2_pixel		= rbbox_pos(2)+rbbox_pos(4);
	if     abs(y1_pixel-y_ip_pixel)<=tol_pixel
		% nop
	elseif abs(y2_pixel-y_ip_pixel)<=tol_pixel
		y1_pixel		= rbbox_pos(2)+rbbox_pos(4);
		y2_pixel		= rbbox_pos(2);
	else
		% This happens, if the axis position has changed:
		% Set the axis position:
		SizeChangedFcn_fig_2dmap([],[],0,0);
		errormessage('Error: Try again.');
	end
	x1		= GV_H.ax_2dmap.XLim(1)+1/mx*(x1_pixel-GV_H.ax_2dmap.Position(1));	% start point
	y1		= GV_H.ax_2dmap.YLim(1)+1/my*(y1_pixel-GV_H.ax_2dmap.Position(2));
	x2		= GV_H.ax_2dmap.XLim(1)+1/mx*(x2_pixel-GV_H.ax_2dmap.Position(1));	% end point
	y2		= GV_H.ax_2dmap.YLim(1)+1/my*(y2_pixel-GV_H.ax_2dmap.Position(2));	% (possibly equal to the start point)
	
	% Show the context menu:
	switch event_data.Button
		case 1
			% Left-click:
			% If there is no context menu or the wrong context menu:
			% Update the context menu, so it will be displayed at the second click:
			[  GV.fig_2dmap_cm.poly_outside_spec,...
				GV.fig_2dmap_cm.poly_dzmax,...
				GV.fig_2dmap_cm.xy_liwimin,...
				GV.fig_2dmap_cm.xy_liwimax]=...
				create_contextmenu_mapobjects(imapobj,clicked_object,event_data.IntersectionPoint);		% without animations
			% Tolerance window around the intersection point:
			GV.fig_2dmap_cm.lc_xmin		= GV_H.ax_2dmap.XLim(1)+1/mx*(x_ip_pixel-tol_pixel-GV_H.ax_2dmap.Position(1));
			GV.fig_2dmap_cm.lc_xmax		= GV_H.ax_2dmap.XLim(1)+1/mx*(x_ip_pixel+tol_pixel-GV_H.ax_2dmap.Position(1));
			GV.fig_2dmap_cm.lc_ymin		= GV_H.ax_2dmap.YLim(1)+1/my*(y_ip_pixel-tol_pixel-GV_H.ax_2dmap.Position(2));
			GV.fig_2dmap_cm.lc_ymax		= GV_H.ax_2dmap.YLim(1)+1/my*(y_ip_pixel+tol_pixel-GV_H.ax_2dmap.Position(2));
			GV.fig_2dmap_cm.clicked_object	= clicked_object;
			
		case 3
			% Right-click:
			if isprop(clicked_object,'ContextMenu')
				if    (event_data.IntersectionPoint(1,1)>GV.fig_2dmap_cm.lc_xmin)&&...		% x_ip
						(event_data.IntersectionPoint(1,1)<GV.fig_2dmap_cm.lc_xmax)&&...
						(event_data.IntersectionPoint(1,2)>GV.fig_2dmap_cm.lc_ymin)&&...		% y_ip
						(event_data.IntersectionPoint(1,2)<GV.fig_2dmap_cm.lc_ymax)&&...
						isequal(clicked_object,GV.fig_2dmap_cm.clicked_object)
					
					htemp		= [];
					i_htemp	= 0;
					if    (size(GV.fig_2dmap_cm.xy_liwimin,1)>0)&&...
							(size(GV.fig_2dmap_cm.xy_liwimax,1)>0)
						% Colors see also create_contextmenu_mapobjects (change line width).
						i_htemp	= i_htemp+1;
						htemp(i_htemp)	= plot(GV_H.ax_2dmap,...
							GV.fig_2dmap_cm.xy_liwimax(:,1),GV.fig_2dmap_cm.xy_liwimax(:,2),...
							'Color'     ,[1 0 1]*0.5,...
							'Visible'   ,'on',...
							'LineStyle' ,'none',...
							'LineWidth' ,GV.preview.LineWidth,...
							'Marker'    ,GV.preview.Marker,...
							'MarkerSize',GV.preview.MarkerSizeFlash,...
							'DisplayName','maximum line width',...
							'UserData',[]);
						i_htemp	= i_htemp+1;
						htemp(i_htemp)	= plot(GV_H.ax_2dmap,...
							GV.fig_2dmap_cm.xy_liwimin(1,1),GV.fig_2dmap_cm.xy_liwimin(1,2),...
							'Color'     ,[0 1 1]*0.5,...
							'Visible'   ,'on',...
							'LineStyle' ,'none',...
							'LineWidth' ,GV.preview.LineWidth,...
							'Marker'    ,GV.preview.Marker,...
							'MarkerSize',GV.preview.MarkerSizeFlash,...
							'DisplayName','minimum line width',...
							'UserData',[]);
					else
						if numboundaries(GV.fig_2dmap_cm.poly_outside_spec)>0
							i_htemp	= i_htemp+1;
							htemp(i_htemp)	= plot(GV_H.ax_2dmap,GV.fig_2dmap_cm.poly_outside_spec,...
								'EdgeColor','r',...
								'FaceColor','r',...
								'EdgeAlpha', GV.visibility.show.edgealpha,...
								'FaceAlpha',GV.visibility.show.facealpha,...
								'Visible'  ,'on',...
								'LineStyle',GV.preview.LineStyle,...
								'LineWidth',GV.preview.LineWidth,...
								'DisplayName','Size out of specification',...
								'UserData',[]);
						end
						if numboundaries(GV.fig_2dmap_cm.poly_dzmax)>0
							i_htemp	= i_htemp+1;
							htemp(i_htemp)	= plot(GV_H.ax_2dmap,GV.fig_2dmap_cm.poly_dzmax,...
								'EdgeColor','m',...
								'FaceColor','m',...
								'EdgeAlpha', GV.visibility.show.edgealpha,...
								'FaceAlpha',GV.visibility.show.facealpha,...
								'Visible'  ,'on',...
								'LineStyle',GV.preview.LineStyle,...
								'LineWidth',GV.preview.LineWidth,...
								'DisplayName','dz is maximal',...
								'UserData',[]);
						end
					end
					if ~isempty(htemp)
						pause(4);
						delete(htemp);
					end
				end
			end
			
			
			
			
			
			
			
			
			
			
			
			
			% If there is no context menu or the wrong context menu:
			% Update the context menu, so it will be displayed at the second click:
			% hcmenu	= create_contextmenu_mapobjects(imapobj,clicked_object,event_data.IntersectionPoint);		% with animations
	end
	
	% Actions:
	if (rbbox_pos(3)>tol_pixel)||(rbbox_pos(4)>tol_pixel)
		% A rubberband box has been created:
		
		if APP.MapView_In_Button.Value==1
			
			% Zoom in:
			ax_2dmap_zoom('set',x1,y1,x2,y2);
			
			% Reset the Zoom in button:
			APP.MapView_In_Button.Value	= 0;
			ax_2dmap_zoominbutton_bgdcolor;
			
		else
			% Do not zoom in:
			
			if strcmp(APP.Mod_LiReVe_ButtonGroup.SelectedObject.Text,'Off')
				% Create preview lines is switched off: do nothing
				
			else
				
				% If the clicked object is selected: try to modify the existing line:
				switch APP.Mod_LiReVe_ButtonGroup.SelectedObject.Text
					case {'Draw line','Move','Move vertex'}
						existing_line_modified	= false;
						if clicked_object.Selected
							if length(imapobj)==1
								if length(MAP_OBJECTS(imapobj,1).h)==1
									if strcmp(MAP_OBJECTS(imapobj,1).h.Type,'line')
										xv_sel_line		= MAP_OBJECTS(imapobj,1).h.XData';
										yv_sel_line		= MAP_OBJECTS(imapobj,1).h.YData';
									elseif strcmp(MAP_OBJECTS(imapobj,1).h.Type,'polygon')
										% Use the boundary-function (same method as in plot_modify('mod_vertex',imapobj,...):
										[xv_sel_line,yv_sel_line]	= boundary(MAP_OBJECTS(imapobj,1).h.Shape);
									else
										errormessage;
									end
									xv_sel_line_pixel	= GV_H.ax_2dmap.Position(1)+mx*(xv_sel_line-GV_H.ax_2dmap.XLim(1));
									yv_sel_line_pixel	= GV_H.ax_2dmap.Position(2)+my*(yv_sel_line-GV_H.ax_2dmap.YLim(1));
									i1	= find(...
										(abs(x1_pixel-xv_sel_line_pixel)<=tol_pixel)&...
										(abs(y1_pixel-yv_sel_line_pixel)<=tol_pixel)    );
									i2	= find(...
										(abs(x2_pixel-xv_sel_line_pixel)<=tol_pixel)&...
										(abs(y2_pixel-yv_sel_line_pixel)<=tol_pixel)    );
									if ~isempty(i2)
										% The end point of the rubberband box is identical to a vertex of the line:
										% Move the vertex i1 to the vertex i2:
										i2		= i2(1);			% If the start- and endpoint of a closed line has been clicked
										x2		= xv_sel_line(i2);
										y2		= yv_sel_line(i2);
									end
									if ~isempty(i1)
										% The start point of the rubberband box is identical to a vertex of the line:
										i1	= i1(1);			% If the start- and endpoint of a closed line has been clicked
										switch APP.Mod_LiReVe_ButtonGroup.SelectedObject.Text
											case 'Draw line'
												if ~strcmp(MAP_OBJECTS(imapobj,1).h.Type,'polygon')
													if i1==1
														plot_modify('mod_vertex',imapobj,'add','first',...
															x2,...			% x-value of the new vertex
															y2);				% y-value of the new vertex
														existing_line_modified	= true;
													elseif i1==size(xv_sel_line,1)
														plot_modify('mod_vertex',imapobj,'add','last',...
															x2,...			% x-value of the new vertex
															y2);				% y-value of the new vertex
														existing_line_modified	= true;
													else
														% nop
													end
												end
											case 'Move'
												plot_modify('move',imapobj,x2-x1,y2-y1);
											case 'Move vertex'
												plot_modify('mod_vertex',imapobj,'move',i1,...
													x2,...			% x-value of the new vertex
													y2);				% y-value of the new vertex
											otherwise
												errormessage;
										end
									end
								else
									% length(MAP_OBJECTS(imapobj,1).h)~=1:
									if strcmp(APP.Mod_LiReVe_ButtonGroup.SelectedObject.Text,'Move')
										plot_modify('move',imapobj,x2-x1,y2-y1);
									end
								end
							end
						end
						
						% Draw a new line:
						if strcmp(APP.Mod_LiReVe_ButtonGroup.SelectedObject.Text,'Draw line')&&...
								~existing_line_modified
							plot_modify('new_line',0,...
								[x1 x2],...						% x-value of the new vertex/vertices
								[y1 y2]);						% y-value of the new vertex/vertices
						end
						
					case 'Draw rectangle'
						% Draw a new rectangle:
						plot_modify('new_line',0,...
							[x1 x2 x2 x1 x1],...			% x-value of the new vertex/vertices
							[y1 y1 y2 y2 y1]);        	% y-value of the new vertex/vertices
						
					case 'Delete vertices'
						% Delete alle vertices inside the rubberband box:
						plot_modify('mod_vertex',-1,'delvertices',...
							x1,...							% Rubberband box start point x
							y1,...							% Rubberband box start point y
							x2,...							% Rubberband box end   point x
							y2);								% Rubberband box end   point y
						
					case 'Split'
						% Delete alle vertices inside the rubberband box:
						plot_modify('mod_vertex',-1,'split',...
							x1,...							% Rubberband box start point x
							y1,...							% Rubberband box start point y
							x2,...							% Rubberband box end   point x
							y2);								% Rubberband box end   point y
						
					case 'Insert vertex'
						errormessage('Insert a vertex by clicking on the selected line.');
					otherwise
						errormessage;
				end
			end
			
			% Achse: units=data
			
			
			% 			plot_modify('new_line',0,...
			% 				app.Mod_LV_xmm_EditField.Value,...			% x-value of the new vertex/vertices
			% 				app.Mod_LV_ymm_EditField.Value);         	% y-value of the new vertex/vertices
			
			
			% 			if strcmp(app.Mod_LV_FirstLast_ButtonGroup.SelectedObject.Text,'First')
			% 				par2='first';
			% 			else
			% 				par2='last';
			% 			end
			% 			plot_modify('mod_vertex',...
			% 				-1,...												% imapobj_v
			% 				'add',par2,...
			% 				app.Mod_LV_xmm_EditField.Value,...			% x-value of the new vertex
			% 				app.Mod_LV_ymm_EditField.Value);				% y-value of the new vertex
			
			
		end
		
	else
		% Clicking without creating a rubberband box:
		
		if isempty(imapobj)
			if ~isempty(MAP_OBJECTS)
				plot_modify('deselect',-1);
				set(GV_H.text_waitbar,'String','No plot objects selected.');
			end
			return
		end
		
		switch event_data.Button
			case 1
				% Left-click
				% Select only one object:
				
				if clicked_object.Selected
					% The clicked object is selected:
					if ~strcmp(APP.Mod_LiReVe_ButtonGroup.SelectedObject.Text,'Insert vertex')
						plot_modify('deselect',-1);
						set(GV_H.text_waitbar,'String','No plot objects selected.');
					else
						% Possibly insert new vertex into the selected object:
						if length(MAP_OBJECTS(imapobj,1).h)>1
							errormessage(sprintf(['Error:\n',...
								'Insert vertex:\n',...
								'The selected object PlotNo=%g consists\n',...
								'of a group of %g objects.\n',...
								'First you have to ungroup the object.'],imapobj,length(MAP_OBJECTS(imapobj,1).h)));
						end
						% Point on the selected object, that has the minimum distance to the intersection point:
						% [vx_dmin_pixel vy_dmin_pixel]
						if strcmp(MAP_OBJECTS(imapobj,1).h.Type,'line')
							x_mapobj				= MAP_OBJECTS(imapobj,1).h.XData';
							y_mapobj				= MAP_OBJECTS(imapobj,1).h.YData';
						elseif strcmp(MAP_OBJECTS(imapobj,1).h.Type,'polygon')
							[x_mapobj,y_mapobj]	= boundary(MAP_OBJECTS(imapobj,1).h.Shape);
						else
							errormessage;
						end
						x_mapobj_pixel	= GV_H.ax_2dmap.Position(1)+mx*(x_mapobj-GV_H.ax_2dmap.XLim(1));
						y_mapobj_pixel	= GV_H.ax_2dmap.Position(2)+my*(y_mapobj-GV_H.ax_2dmap.YLim(1));
						[  dmin_pixel,...				% minimum distance
							vx_dmin_pixel,...			% possibly new polygon vertex x
							vy_dmin_pixel,...			% possibly new polygon vertex x
							i_dmin,...					% index of the line segment of the polygon
							~]=...						% position of the point [vx_dmin vy_dmin] on the line segment i_dmin
							mindistance_poly_p(...
							x_mapobj_pixel,...		% vertices x
							y_mapobj_pixel,...		% vertices y
							x_ip_pixel,...				% query point x
							y_ip_pixel);				% query point y
						d_first_pixel		= sqrt(...								% distance to the first point of the line segment
							(vx_dmin_pixel-x_mapobj_pixel(i_dmin))^2+...
							(vy_dmin_pixel-y_mapobj_pixel(i_dmin))^2    );
						d_last_pixel		= sqrt(...								% distance to the last point of the line segment
							(vx_dmin_pixel-x_mapobj_pixel(i_dmin+1))^2+...
							(vy_dmin_pixel-y_mapobj_pixel(i_dmin+1))^2    );
						if    (dmin_pixel   <=tol_pixel)&&...
								(d_first_pixel>=tol_pixel)&&...
								(d_last_pixel >=tol_pixel)
							% Insert vertex:
							vx_dmin		= GV_H.ax_2dmap.XLim(1)+1/mx*(vx_dmin_pixel-GV_H.ax_2dmap.Position(1));
							vy_dmin		= GV_H.ax_2dmap.YLim(1)+1/my*(vy_dmin_pixel-GV_H.ax_2dmap.Position(2));
							x_mapobj((i_dmin+2):(end+1))	= x_mapobj((i_dmin+1):end);
							y_mapobj((i_dmin+2):(end+1))	= y_mapobj((i_dmin+1):end);
							x_mapobj((i_dmin+1),1)			= vx_dmin;
							y_mapobj((i_dmin+1),1)			= vy_dmin;
							if strcmp(MAP_OBJECTS(imapobj,1).h.Type,'line')
								MAP_OBJECTS(imapobj,1).h.XData	= x_mapobj';
								MAP_OBJECTS(imapobj,1).h.YData	= y_mapobj';
							elseif strcmp(MAP_OBJECTS(imapobj,1).h.Type,'polygon')
								MAP_OBJECTS(imapobj,1).h.Shape	= addboundary(polyshape(),x_mapobj,y_mapobj,...
									'KeepCollinearPoints',true);
								% MAP_OBJECTS(imapobj,1).h.Shape.Vertices	= [xdata ydata];
							end
							% Switch to "Move vertex" mode:
							APP.Mod_LiReVe_ButtonGroup.SelectedObject		= APP.MoveVerticesButton;
						end
						% Often the new point is not visible, even if the object is selected: switch directly to
						% 'move vertex' while the mouse pointer is still in the same place to be able to move the vertex:
						% This does not work:
						% APP.Mod_LiReVe_ButtonGroup.SelectedObject.Text	= 'Move vertex';
					end
				else
					% The clicked object is not selected:
					plot_modify('deselect',-1);
					if ~isempty(imapobj)
						plot_modify('select',imapobj,0);
						APP.Mod_Polygons_PlotNo1_EditField.Value			= imapobj;
						APP.Mod_Polygons_PlotNo2_EditField.Value			= 0;
					end
				end
				
			case 2
				% Mouse wheel
				% Select more than one object:
				
				if ~isempty(imapobj)
					if clicked_object.Selected
						% clicked_object.Selected	= 'off';
						plot_modify('deselect',imapobj,0);
						APP.Mod_Polygons_PlotNo2_EditField.Value	= 0;
					else
						% clicked_object.Selected	= 'on';
						plot_modify('select',imapobj,0);
						APP.Mod_Polygons_PlotNo2_EditField.Value	= imapobj;
					end
				end
				
			case 3
				% Right-click:
				% When doing a Right-click on a plot object, the already assigned context menu will be displayed.
				
				
				
				
				
				
				
				
				
				% old:
				
				% Funktion schreiben: plot_modify_menu(src,event,action,imapobj,par1,par2,par3,par4)
				% plot_modify('hide',-1);
				
				% Write Callbacks for Apps Created Programmatically
				%
				% Specify a Cell Array
				% Use a cell array to specify a callback function that accepts additional input arguments that you want to use in
				% the function. The first element in the cell array is a function handle. The other elements in the cell array are
				% the additional input arguments you want to use, separated by commas. The function you specify must define the same
				% two input arguments as described in Specify a Function Handle. However, you can define additional inputs in your
				% function declaration after the first two arguments.
				%
				% This uicontrol command creates a push button and specifies the Callback property to be a cell array. In this
				% case, the name of the function is pushbutton_callback, and the value of the additional input argument is 5.
				%
				% b = uicontrol('Style','pushbutton','Callback',{@pushbutton_callback,5});
				% Here is the function definition for pushbutton_callback:
				%
				% function pushbutton_callback(src,event,x)
				%    display(x);
				% end
				% Like callbacks specified as function handles, MATLAB checks callbacks specified as cell arrays for syntax
				% errors and missing dependencies when you assign the callback to the component. If there is a problem in the
				% callback function, then MATLAB returns an error immediately instead of waiting for the user to trigger the
				% callback. This behavior helps you to find problems in your code before the user encounters them.
				
				
				
				
				% Plot No anzeigen
				% PlotNo 1 setzen
				% PlotNo 2 setzen
				% Hide
				% alle Markierungen aufheben
				
		end
		
	end
	% end
	
	% You can attach context menus to handle graphics objects. These menus can display multiple selections and even let your script respond to user selections. Take a look at the following example:
	%
	% x = [1:10];
	% y = x.^2;
	%
	% plot(x,y); hold on;
	% h = plot(x(5), y(5),'ro'); %% save the handle to the point we want to annotate
	%
	% hcmenu = uicontextmenu;
	% item_01 = uimenu(hcmenu, 'Label', 'info 1');
	% item_02 = uimenu(hcmenu, 'Label', 'info 2');
	% item_03 = uimenu(hcmenu, 'Label', 'info 2');
	%
	% set(h, 'uicontextmenu', hcmenu);
	%
	% When you right click on the 'o' point, you get the context menu:
	
	
catch ME
	errormessage('',ME);
end

