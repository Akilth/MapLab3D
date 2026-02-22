function set_previewtype_dropdown(set_dropdown_items)
% Set the selectable color numbers for creating cutting lines.
% set_previewtype_dropdown(1)			Set the Item property of:	APP.Mod_UnitedColors_SelectColNo_DropDown
%												Set the value to the first entry (nothing else to do).
% set_previewtype_dropdown(0)			Called if the value of APP.Mod_UnitedColors_SelectColNo_DropDown has changed.

global GV_H PP APP PRINTDATA MAP_OBJECTS

try
	
	if nargin<1
		set_dropdown_items	= 1;
	end
	
	% Display state:
	stateisbusy	= display_on_gui('state','','isbusy');
	if ~stateisbusy
		display_on_gui('state','','busy');
	end
	
	% Items and Value of the dropdown menu:
	if set_dropdown_items~=0
		delete_obj_union_equalcolors	= false;
		if isfield(PRINTDATA,'obj_union_equalcolors')
			used_colno		= [];
			if ~isempty(PP)&&~isempty(PRINTDATA.obj_union_equalcolors)
				% Search all object numbers:
				% The cutting into pieces should be possible only after simplification of the map:
				for imapobj=1:size(MAP_OBJECTS,1)
					for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
						ud		= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
						if isfield(ud,'color_no')
							used_colno		= [used_colno ud.color_no];
						end
					end
				end
				for iobj=1:size(PP.obj,1)
					if ~isempty(PP.obj(iobj,1).display)
						if PP.obj(iobj,1).display~=0
							color_no_fgd		= PP.obj(iobj,1).color_no_fgd;
							color_no_bgd		= PP.obj(iobj,1).color_no_bgd;
							if color_no_fgd>0
								if PP.color(color_no_fgd,1).prio~=0
									used_colno		= [used_colno color_no_fgd];
								end
							end
							if color_no_bgd>0
								if PP.color(color_no_bgd,1).prio~=0
									used_colno		= [used_colno color_no_bgd];
								end
							end
						end
						if PP.obj(iobj,1).symbolpar.display~=0
							color_no_symbol	= PP.obj(iobj,1).symbolpar.color_no_symbol;
							color_no_bgd		= PP.obj(iobj,1).symbolpar.color_no_bgd;
							if color_no_symbol>0
								if PP.color(color_no_symbol,1).prio~=0
									used_colno		= [used_colno color_no_symbol];
								end
							end
							if color_no_bgd>0
								if PP.color(color_no_bgd,1).prio~=0
									used_colno		= [used_colno color_no_bgd];
								end
							end
						end
						if PP.obj(iobj,1).textpar.display~=0
							color_no_letters	= PP.obj(iobj,1).textpar.color_no_letters;
							color_no_bgd		= PP.obj(iobj,1).textpar.color_no_bgd;
							if color_no_letters>0
								if PP.color(color_no_letters,1).prio~=0
									used_colno		= [used_colno color_no_letters];
								end
							end
							if color_no_bgd>0
								if PP.color(color_no_bgd,1).prio~=0
									used_colno		= [used_colno color_no_bgd];
								end
							end
						end
					end
				end
				used_colno			= unique(used_colno);
				% used_colno_max		= max(used_colno);
				used_colno(used_colno==0)	= [];
				% Do not show color numbers that do not exist in the map:
				for colno=1:size(PRINTDATA.obj_union_equalcolors,1)
					if numboundaries(PRINTDATA.obj_union_equalcolors(colno,1))==0
						used_colno(used_colno==colno)	= [];
					end
				end
				used_colno(used_colno>size(PRINTDATA.obj_union_equalcolors,1))	= [];
				% Items united colors dropdown:
				Items_UC					= cell(1,length(used_colno)+1);
				Items_UC{1,1}			= 'None';
				for i=1:length(used_colno)
					color_description	= PP.color(used_colno(i),1).description;
					% see also get_colno_cuttingline.m!
					Items_UC{1,i+1}	= sprintf('Color %1.0f (%s)',used_colno(i),color_description);
				end
			else
				% No data:
				delete_obj_union_equalcolors	= true;
			end
		else
			% No data:
			delete_obj_union_equalcolors	= true;
		end
		if delete_obj_union_equalcolors
			% No data:
			Items_UC					= {'None'};
			if ~isempty(MAP_OBJECTS)&&isfield(PRINTDATA,'obj_union_equalcolors')
				for colno=size(PRINTDATA.obj_union_equalcolors,1):-1:1
					imapobj		= find([MAP_OBJECTS.cnuc]==colno);
					if ~isempty(imapobj)
						plot_modify('delete',imapobj);		% Includes also display_map_objects
					end
				end
			end
		end
		APP.Mod_UnitedColors_SelectColNo_DropDown.Items	= Items_UC;
		APP.Mod_UnitedColors_SelectColNo_DropDown.Value	= APP.Mod_UnitedColors_SelectColNo_DropDown.Items{1,1};
	end
	
	% Modify the map:
	if ~isempty(MAP_OBJECTS)
		if ~strcmp(APP.Mod_UnitedColors_SelectColNo_DropDown.Value,'None')
			% Show the united equal colors and the cutting lines:
			cnuc		= get_colno_cuttingline;
			if cnuc~=0
				% The color number cnuc has been selected:
				% Show this color number and all other colors with a lower priority,
				% that are possibly covered by the color number cnuc
				prio_cnuc	= PP.color(cnuc,1).prio;
				imapobj_show	= false(size(MAP_OBJECTS));
				imapobj_show(...
					( [MAP_OBJECTS.cncl]==cnuc                        )|...
					(([MAP_OBJECTS.cnuc]<=cnuc)&([MAP_OBJECTS.cnuc]>0))    ) = true;
				for imapobj=1:size(MAP_OBJECTS,1)
					if imapobj_show(imapobj)
						% The map object is a cutting line or a united equal color:
						for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
							if    (MAP_OBJECTS(imapobj,1).cnuc==cnuc)||...
									(MAP_OBJECTS(imapobj,1).cncl==cnuc)
								% Show cutting lines und united colors:
								MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'on';
							else
								if MAP_OBJECTS(imapobj,1).cnuc>0
									prio	= PP.color(MAP_OBJECTS(imapobj,1).cnuc,1).prio;
									if prio<prio_cnuc
										% Show colors with a lower priority:
										MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'on';
									else
										MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'off';
									end
								else
									MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'off';
								end
							end
						end
					else
						% The map object is not a cutting line an not a united equal color:
						method		= 2;
						switch method
							case 1
								% Do not show texts and symbols:
								for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
									MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'off';
								end
							case 2
								% Show also texts and symbols that have the same color:
								% Displaying text allows lines to be cut at the correct position.
								% It also prevents a cutting line from accidentally cutting through texts or symbols.
								if MAP_OBJECTS(imapobj,1).vis0~=0
									% The object is visible:
									if   (strcmp(MAP_OBJECTS(imapobj,1).disp,'text')           ||...
											strcmp(MAP_OBJECTS(imapobj,1).disp,'symbol')         ||...
											strcmp(MAP_OBJECTS(imapobj,1).disp,'connection line')     )&&...
											(MAP_OBJECTS(imapobj,1).iobj>0)
										% The object is a text or symbol:
										if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'color_no')
											set_visible_on		= false;
											for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
												if MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no==cnuc
													set_visible_on		= true;
												end
											end
											if set_visible_on
												for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
													MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'on';
												end
											else
												for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
													MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'off';
												end
											end
										else
											for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
												MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'off';
											end
										end
									else
										% The object is not a text or symbol:
										for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
											MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'off';
										end
									end
								else
									% The object is not visible:
									for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
										MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'off';
									end
								end
						end
					end
				end
				% Show the maximum size limits:
				if isfield(GV_H,'poly_tiles')
					if iscell(GV_H.poly_tiles)
						column_tiles_cnuc			= cnuc+2;
						icolspec						= PP.color(cnuc,1).spec;
						maxdimx						= PP.colorspec(icolspec,1).cut_into_pieces.maxdimx;
						maxdimy						= PP.colorspec(icolspec,1).cut_into_pieces.maxdimy;
						% maxdiag						= PP.colorspec(icolspec,1).cut_into_pieces.maxdiag;
						for tile_no=1:size(GV_H.poly_tiles,1)
							for column_tiles=2:max(column_tiles_cnuc,size(GV_H.poly_tiles,2))
								if column_tiles~=column_tiles_cnuc
									% Delete existing plots:
									if column_tiles<=size(GV_H.poly_tiles,2)
										if ~isempty(GV_H.poly_tiles{tile_no,column_tiles})
											if isvalid(GV_H.poly_tiles{tile_no,column_tiles})
												delete(GV_H.poly_tiles{tile_no,column_tiles});
												GV_H.poly_tiles{tile_no,column_tiles}	= [];
											end
										end
									end
								else
									% Create maximum size limits plots:
									if isvalid(GV_H.poly_tiles{tile_no,1})
										[xlim_tile,ylim_tile]	= boundingbox(GV_H.poly_tiles{tile_no,1}.Shape);
										xcenter_tile				= (xlim_tile(2)+xlim_tile(1))/2;
										ycenter_tile				= (ylim_tile(2)+ylim_tile(1))/2;
										tile_width					= xlim_tile(2)-xlim_tile(1);
										tile_height					= ylim_tile(2)-ylim_tile(1);
										n_maxdimx					= ceil(tile_width /maxdimx);
										n_maxdimy					= ceil(tile_height/maxdimy);
										maxdim_x1					= xcenter_tile-n_maxdimx*maxdimx/2;
										maxdim_x2					= xcenter_tile+n_maxdimx*maxdimx/2;
										maxdim_y1					= ycenter_tile-n_maxdimy*maxdimy/2;
										maxdim_y2					= ycenter_tile+n_maxdimy*maxdimy/2;
										for ix=1:(n_maxdimx+1)
											if ix==1
												x_maxdim_v					= [...
													maxdim_x1+(ix-1)*maxdimx;...
													maxdim_x1+(ix-1)*maxdimx];
												y_maxdim_v					= [
													maxdim_y1;
													maxdim_y2];
											else
												x_maxdim_v					= [x_maxdim_v;nan;...
													maxdim_x1+(ix-1)*maxdimx;...
													maxdim_x1+(ix-1)*maxdimx];
												y_maxdim_v					= [y_maxdim_v;nan;...
													maxdim_y1;
													maxdim_y2];
											end
										end
										for iy=1:(n_maxdimy+1)
											x_maxdim_v					= [x_maxdim_v;nan;...
												maxdim_x1;...
												maxdim_x2];
											y_maxdim_v					= [y_maxdim_v;nan;...
												maxdim_y1+(iy-1)*maxdimy;...
												maxdim_y1+(iy-1)*maxdimy];
										end
										% Plot maximum dimensions (minimum colno united equal colors cnuc = 0):
										GV_H.poly_tiles{tile_no,column_tiles_cnuc}	= ...
											plot(GV_H.ax_2dmap,x_maxdim_v,y_maxdim_v,...
											'LineWidth',1.5,...
											'LineStyle',':',...
											'Color'    ,'m',...
											'UserData' ,[]);
									end
								end
							end
						end
					end
				end
				% Create/modify legend:
				create_legend_mapfigure;
				
			else
				errormessage;
			end
			% Execution times when loading a large project:
			% drawnow nocallbacks;		% 24.849s
			pause(0.001);					% s
		else
			% Hide all cutting lines and united equal colors, show the rest depending on MAP_OBJECTS(imapobj,1).vis0:
			imapobj_hide	= false(size(MAP_OBJECTS));
			imapobj_hide(([MAP_OBJECTS.cncl]~=0)|([MAP_OBJECTS.cnuc]~=0)) = true;
			for imapobj=1:size(MAP_OBJECTS,1)
				if imapobj_hide(imapobj)
					for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
						MAP_OBJECTS(imapobj,1).h(i,1).Visible		= 'off';
					end
				else
					if MAP_OBJECTS(imapobj,1).vis0~=0
						for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
							MAP_OBJECTS(imapobj,1).h(i,1).Visible	= 'on';
						end
					end
				end
			end
			% Delete all maximum size limits:
			if isfield(GV_H,'poly_tiles')
				if iscell(GV_H.poly_tiles)
					for tile_no=1:size(GV_H.poly_tiles,1)
						for column_tiles=2:size(GV_H.poly_tiles,2)
							if ~isempty(GV_H.poly_tiles{tile_no,column_tiles})
								if isvalid(GV_H.poly_tiles{tile_no,column_tiles})
									delete(GV_H.poly_tiles{tile_no,column_tiles});
									GV_H.poly_tiles{tile_no,column_tiles}	= [];
								end
							end
						end
					end
				end
			end
			% Execution times when loading a large project:
			% drawnow nocallbacks;		% 83.967s
			pause(0.001);					% 26.447s
		end
	end
	
	% Update MAP_OBJECTS_TABLE:
	display_map_objects;
	
	% Display state:
	if ~stateisbusy
		% t_plot_modify	= etime(clock,t_start_statebusy)
		display_on_gui('state','','notbusy');
	end
	
catch ME
	errormessage('',ME);
end

