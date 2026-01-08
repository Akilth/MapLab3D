function plotosmdata_plotdata(iobj,msg)
% Creates polygons from PLOTDATA and plots the polygons in the axis GV_H.ax_2dmap.

global PP MAP_OBJECTS GV GV_H PLOTDATA

try

	% Test:
	if iobj==4
		setbreakpoint=1;
	end

	% "Create map" log:
	GV.log.create_map.text	= sprintf('%s%s\n',GV.log.create_map.text,GV.log.create_map.line_str);
	GV.log.create_map.text	= sprintf('%sPlot data of ObjNo %g (%s)\n',GV.log.create_map.text,iobj,PP.obj(iobj).description);

	% Simplify and plot lines and areas:
	% Do this before plotting texts and symbols, so the areas do not cover texts and symbols and they can be selected
	% by clicking on the map.
	if ~isempty(PLOTDATA.obj(iobj,1).connways)
		% PLOTDATA.obj(iobj,1).connways contains only data of lines and areas, not texts and symbols:
		plotosmdata_plotdata_li_ar(...
			iobj,...
			PLOTDATA.obj(iobj,1).connways,...
			PLOTDATA.obj(iobj,1).ud_in_v,...
			PLOTDATA.obj(iobj,1).ud_iw_v,...
			PLOTDATA.obj(iobj,1).ud_ir_v,...
			msg,...
			1);											% simplify_moveoutline
	end

	% Plot the symbols:
	if strcmp(PP.obj(iobj).symbolpar.visibility,'gray out')
		facealpha		= GV.visibility.grayout.facealpha;
		edgealpha		= GV.visibility.grayout.edgealpha;
		visible			= 'on';
	else
		facealpha		= GV.visibility.show.facealpha;
		edgealpha		= GV.visibility.show.edgealpha;
		if strcmp(PP.obj(iobj).symbolpar.visibility,'hide')
			visible		= 'off';
		else
			visible		= 'on';
		end
	end
	for iseqt=1:size(PLOTDATA.obj(iobj,1).symb,1)
		if ~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_obj)
			if (sum(numboundaries(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_obj))>0) && ...
					~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_obj)
				for ipoly=1:size(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_obj,1)
					imapobj		= size(MAP_OBJECTS,1)+1;

					% Source:
					% The source plots are made visible, if the corresponding text or symbol is selected.
					% This makes it easier to move the texts and symbols to the right place when editing the map.
					source		= [];
					ud_source	= [];
					ud_source.issource	= true;	% to recognize it as source
					ud_source.imapobj		= 0;		% save_project: save the index imapobj
					%										  load_project: assign the source plot to the corresponding text/symbol
					if ~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).source(ipoly,1).connways.nodes)
						if ~ishandle(GV_H.ax_2dmap)
							errormessage(sprintf(['There exists no map where to plot the objects.\n',...
								'Create the map first.']));
						end
						source(end+1,1).h	= plot(GV_H.ax_2dmap,...
							PLOTDATA.obj(iobj,1).symb(iseqt,1).source(ipoly,1).connways.nodes.xy(:,1),...
							PLOTDATA.obj(iobj,1).symb(iseqt,1).source(ipoly,1).connways.nodes.xy(:,2),...
							'Color'     ,GV.tempprev.Color,...
							'LineStyle' ,'none',...
							'Marker'    ,GV.tempprev.Marker,...
							'MarkerSize',GV.tempprev.MarkerSize,...
							'UserData'  ,ud_source,...
							'Visible'   ,'off');
					end
					if ~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).source(ipoly,1).connways.lines)
						for k=1:size(PLOTDATA.obj(iobj,1).symb(iseqt,1).source(ipoly,1).connways.lines,1)
							if ~ishandle(GV_H.ax_2dmap)
								errormessage(sprintf(['There exists no map where to plot the objects.\n',...
									'Create the map first.']));
							end
							source(end+1,1).h	= plot(GV_H.ax_2dmap,...
								PLOTDATA.obj(iobj,1).symb(iseqt,1).source(ipoly,1).connways.lines(k,1).xy(:,1),...
								PLOTDATA.obj(iobj,1).symb(iseqt,1).source(ipoly,1).connways.lines(k,1).xy(:,2),...
								'Color'     ,GV.tempprev.Color,...
								'LineStyle' ,GV.tempprev.LineStyle,...
								'LineWidth' ,GV.tempprev.LineWidth,...
								'Marker'    ,'none',...
								'UserData'  ,ud_source,...
								'Visible'   ,'off');
						end
					end
					if ~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).source(ipoly,1).connways.areas)
						for k=1:size(PLOTDATA.obj(iobj,1).symb(iseqt,1).source(ipoly,1).connways.areas,1)
							if ~ishandle(GV_H.ax_2dmap)
								errormessage(sprintf(['There exists no map where to plot the objects.\n',...
									'Create the map first.']));
							end
							source(end+1,1).h	= plot(GV_H.ax_2dmap,...
								PLOTDATA.obj(iobj,1).symb(iseqt,1).source(ipoly,1).connways.areas(k,1).xy(:,1),...
								PLOTDATA.obj(iobj,1).symb(iseqt,1).source(ipoly,1).connways.areas(k,1).xy(:,2),...
								'Color'     ,GV.tempprev.Color,...
								'LineStyle' ,GV.tempprev.LineStyle,...
								'LineWidth' ,GV.tempprev.LineWidth,...
								'Marker'    ,'none',...
								'UserData'  ,ud_source,...
								'Visible'   ,'off');
						end
					end

					% Symbol background:
					h_poly_bgd	= [];
					if ~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd)
						if (sum(numboundaries(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd(ipoly,1)))>0) && ...
								~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_bgd(ipoly,1))
							% shape0:
							PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_bgd(ipoly,1).shape0		= ...
								PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd(ipoly,1);
							% Source data:
							PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_bgd(ipoly,1).source		= source;
							% plot-command:
							if isequal(PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_bgd(ipoly,1).color_no,0)
								facecolor	= 'none';
								linewidth	= GV.colorno_e0_linewidth;
							else
								facecolor	= PP.color(PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_bgd(ipoly,1).color_no).rgb/255;
								linewidth	= GV.colorno_g0_linewidth;
							end
							if ~ishandle(GV_H.ax_2dmap)
								errormessage(sprintf(['There exists no map where to plot the objects.\n',...
									'Create the map first.']));
							end
							h_poly_bgd		= plot(GV_H.ax_2dmap,...
								PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd(ipoly,1),...
								'LineWidth'    ,linewidth,...
								'EdgeColor'    ,'k',...
								'FaceColor'    ,facecolor,...
								'EdgeAlpha'    ,edgealpha,...
								'FaceAlpha'    ,facealpha,...
								'Visible'      ,visible,...
								'UserData'     ,PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_bgd(ipoly,1),...
								'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
							% The symbol foreground must be inside the symbol background (less problems in map2stl.m):
							poly_bgd_buff	= polybuffer(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd(ipoly,1),...
								-GV.d_forebackgrd_plotobj,'JointType','miter','MiterLimit',2);
							PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_obj(ipoly,1)		= ...
								intersect(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_obj(ipoly,1),...
								poly_bgd_buff,'KeepCollinearPoints',false);
						end
					end

					% Symbol foreground:
					% shape0:
					PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_obj(ipoly,1).shape0		= ...
						PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_obj(ipoly,1);
					% Source data:
					PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_obj(ipoly,1).source		= source;
					% plot-command:
					if isequal(PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_obj(ipoly,1).color_no,0)
						facecolor	= 'none';
						linewidth	= GV.colorno_e0_linewidth;
					else
						facecolor	= PP.color(PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_obj(ipoly,1).color_no).rgb/255;
						linewidth	= GV.colorno_g0_linewidth;
					end
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf(['There exists no map where to plot the objects.\n',...
							'Create the map first.']));
					end
					h_poly_sym		= plot(GV_H.ax_2dmap,...
						PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_obj(ipoly,1),...
						'LineWidth'    ,linewidth,...
						'EdgeColor'    ,'k',...
						'FaceColor'    ,facecolor,...
						'EdgeAlpha'    ,edgealpha,...
						'FaceAlpha'    ,facealpha,...
						'Visible'      ,visible,...
						'UserData'     ,PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_obj(ipoly,1),...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);

					% Save relevant data in the structure MAP_OBJECTS:
					[xcenter,ycenter]		= centroid(union(...
						PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_obj(ipoly,1),...
						PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd(ipoly,1)));
					MAP_OBJECTS(imapobj,1).disp		= 'symbol';
					if ~isempty(h_poly_bgd)
						MAP_OBJECTS(imapobj,1).h		= [h_poly_bgd;h_poly_sym];
					else
						MAP_OBJECTS(imapobj,1).h		= h_poly_sym;
					end
					MAP_OBJECTS(imapobj,1).iobj		= iobj;
					MAP_OBJECTS(imapobj,1).dscr		= PP.obj(iobj,1).description;
					MAP_OBJECTS(imapobj,1).x			= xcenter;
					MAP_OBJECTS(imapobj,1).y			= ycenter;
					if    ~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).symbol_eqtags_text{ipoly,1})&&...
							~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).symbol_eqtags_text{ipoly,2})
						MAP_OBJECTS(imapobj,1).text		= {PLOTDATA.obj(iobj,1).symb(iseqt,1).symbol_eqtags_text{ipoly,2}};
						% MAP_OBJECTS(imapobj,1).text		= {sprintf('%s = %s',...
						% 	PLOTDATA.obj(iobj,1).symb(iseqt,1).symbol_eqtags_text{ipoly,1},...
						% 	PLOTDATA.obj(iobj,1).symb(iseqt,1).symbol_eqtags_text{ipoly,2})};
					else
						MAP_OBJECTS(imapobj,1).text		= {''};
					end
					% old:
					% MAP_OBJECTS(imapobj,1).text		= {PLOTDATA.obj(iobj,1).symb_eqtags{iseqt,1}};
					MAP_OBJECTS(imapobj,1).mod			= false;
					MAP_OBJECTS(imapobj,1).cncl		= 0;
					MAP_OBJECTS(imapobj,1).cnuc		= 0;
					if strcmp(visible,'on')
						MAP_OBJECTS(imapobj,1).vis0	= 1;
					else
						MAP_OBJECTS(imapobj,1).vis0	= 0;
					end
				end
			end
		end
	end

	% Plot the texts:
	if strcmp(PP.obj(iobj).textpar.visibility,'gray out')
		facealpha		= GV.visibility.grayout.facealpha;
		edgealpha		= GV.visibility.grayout.edgealpha;
		visible			= 'on';
	else
		facealpha		= GV.visibility.show.facealpha;
		edgealpha		= GV.visibility.show.edgealpha;
		if strcmp(PP.obj(iobj).textpar.visibility,'hide')
			visible		= 'off';
		else
			visible		= 'on';
		end
	end
	for iteqt=1:size(PLOTDATA.obj(iobj,1).text,1)
		if ~isempty(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj)
			if (sum(numboundaries(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj))>0) && ...
					~isempty(PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_obj)
				for ipoly=1:size(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj,1)

					% Source:
					% The source plots are made visible, if the corresponding text or symbol is selected.
					% This makes it easier to move the texts and symbols to the right place when editing the map.
					source	= [];
					ud_source	= [];
					ud_source.issource	= true;	% to recognize it as source
					ud_source.imapobj		= 0;		% save_project: save the index imapobj
					%										  load_project: assign the source plot to the corresponding text/symbol
					if ~isempty(PLOTDATA.obj(iobj,1).text(iteqt,1).source(ipoly,1).connways.nodes)
						if ~ishandle(GV_H.ax_2dmap)
							errormessage(sprintf(['There exists no map where to plot the objects.\n',...
								'Create the map first.']));
						end
						source(end+1,1).h	= plot(GV_H.ax_2dmap,...
							PLOTDATA.obj(iobj,1).text(iteqt,1).source(ipoly,1).connways.nodes.xy(:,1),...
							PLOTDATA.obj(iobj,1).text(iteqt,1).source(ipoly,1).connways.nodes.xy(:,2),...
							'Color'     ,GV.tempprev.Color,...
							'LineStyle' ,'none',...
							'Marker'    ,GV.tempprev.Marker,...
							'MarkerSize',GV.tempprev.MarkerSize,...
							'UserData'  ,ud_source,...
							'Visible'   ,'off');
					end
					if ~isempty(PLOTDATA.obj(iobj,1).text(iteqt,1).source(ipoly,1).connways.lines)
						for k=1:size(PLOTDATA.obj(iobj,1).text(iteqt,1).source(ipoly,1).connways.lines,1)
							if ~ishandle(GV_H.ax_2dmap)
								errormessage(sprintf(['There exists no map where to plot the objects.\n',...
									'Create the map first.']));
							end
							source(end+1,1).h	= plot(GV_H.ax_2dmap,...
								PLOTDATA.obj(iobj,1).text(iteqt,1).source(ipoly,1).connways.lines(k,1).xy(:,1),...
								PLOTDATA.obj(iobj,1).text(iteqt,1).source(ipoly,1).connways.lines(k,1).xy(:,2),...
								'Color'     ,GV.tempprev.Color,...
								'LineStyle' ,GV.tempprev.LineStyle,...
								'LineWidth' ,GV.tempprev.LineWidth,...
								'Marker'    ,'none',...
								'UserData'  ,ud_source,...
								'Visible'   ,'off');
						end
					end
					if ~isempty(PLOTDATA.obj(iobj,1).text(iteqt,1).source(ipoly,1).connways.areas)
						for k=1:size(PLOTDATA.obj(iobj,1).text(iteqt,1).source(ipoly,1).connways.areas,1)
							if ~ishandle(GV_H.ax_2dmap)
								errormessage(sprintf(['There exists no map where to plot the objects.\n',...
									'Create the map first.']));
							end
							source(end+1,1).h	= plot(GV_H.ax_2dmap,...
								PLOTDATA.obj(iobj,1).text(iteqt,1).source(ipoly,1).connways.areas(k,1).xy(:,1),...
								PLOTDATA.obj(iobj,1).text(iteqt,1).source(ipoly,1).connways.areas(k,1).xy(:,2),...
								'Color'     ,GV.tempprev.Color,...
								'LineStyle' ,GV.tempprev.LineStyle,...
								'LineWidth' ,GV.tempprev.LineWidth,...
								'Marker'    ,'none',...
								'UserData'  ,ud_source,...
								'Visible'   ,'off');
						end
					end

					% Text background:
					h_poly_bgd	= [];
					if ~isempty(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd)
						if (sum(numboundaries(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd(ipoly,1)))>0) && ...
								~isempty(PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd(ipoly,1))
							% shape0:
							PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd(ipoly,1).shape0		= ...
								PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd(ipoly,1);
							% Source data:
							PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd(ipoly,1).source		= source;
							% plot-command:
							if isequal(PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd(ipoly,1).color_no,0)
								facecolor	= 'none';
								linewidth	= GV.colorno_e0_linewidth;
							else
								facecolor	= PP.color(PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd(ipoly,1).color_no).rgb/255;
								linewidth	= GV.colorno_g0_linewidth;
							end
							if ~ishandle(GV_H.ax_2dmap)
								errormessage(sprintf(['There exists no map where to plot the objects.\n',...
									'Create the map first.']));
							end
							h_poly_bgd		= plot(GV_H.ax_2dmap,...
								PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd(ipoly,1),...
								'LineWidth'    ,linewidth,...
								'EdgeColor'    ,'k',...
								'FaceColor'    ,facecolor,...
								'EdgeAlpha'    ,edgealpha,...
								'FaceAlpha'    ,facealpha,...
								'Visible'      ,visible,...
								'UserData'     ,PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd(ipoly,1),...
								'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
							% The text foreground must be inside the text background (less problems in map2stl.m):
							poly_bgd_buff	= polybuffer(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd(ipoly,1),...
								-GV.d_forebackgrd_plotobj,'JointType','miter','MiterLimit',2);
							PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj(ipoly,1)		= ...
								intersect(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj(ipoly,1),...
								poly_bgd_buff,'KeepCollinearPoints',false);
						end
					end

					% Text foreground:
					% shape0:
					PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_obj(ipoly,1).shape0		= ...
						PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj(ipoly,1);
					% Source data:
					PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_obj(ipoly,1).source		= source;
					% plot-command:
					if isequal(PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_obj(ipoly,1).color_no,0)
						facecolor	= 'none';
						linewidth	= GV.colorno_e0_linewidth;
					else
						facecolor	= PP.color(PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_obj(ipoly,1).color_no).rgb/255;
						linewidth	= GV.colorno_g0_linewidth;
					end
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf(['There exists no map where to plot the objects.\n',...
							'Create the map first.']));
					end
					h_poly_txt		= plot(GV_H.ax_2dmap,...
						PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj(ipoly,1),...
						'LineWidth'    ,linewidth,...
						'EdgeColor'    ,'k',...
						'FaceColor'    ,facecolor,...
						'EdgeAlpha'    ,edgealpha,...
						'FaceAlpha'    ,facealpha,...
						'Visible'      ,visible,...
						'UserData'     ,PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_obj(ipoly,1),...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);

					% Save relevant data in the structure MAP_OBJECTS:
					imapobj					= size(MAP_OBJECTS,1)+1;
					[xcenter,ycenter]		= centroid(union(...
						PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj(ipoly,1),...
						PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd(ipoly,1)    ));
					MAP_OBJECTS(imapobj,1).disp		= 'text';
					if ~isempty(h_poly_bgd)
						MAP_OBJECTS(imapobj,1).h		= [h_poly_bgd;h_poly_txt];
					else
						MAP_OBJECTS(imapobj,1).h		= h_poly_txt;
					end
					MAP_OBJECTS(imapobj,1).iobj		= iobj;
					MAP_OBJECTS(imapobj,1).dscr		= PP.obj(iobj,1).description;
					MAP_OBJECTS(imapobj,1).x			= xcenter;
					MAP_OBJECTS(imapobj,1).y			= ycenter;
					MAP_OBJECTS(imapobj,1).text		= PLOTDATA.obj(iobj,1).text_eqtags{iteqt,1};
					MAP_OBJECTS(imapobj,1).mod			= false;
					MAP_OBJECTS(imapobj,1).cncl		= 0;
					MAP_OBJECTS(imapobj,1).cnuc		= 0;
					if strcmp(visible,'on')
						MAP_OBJECTS(imapobj,1).vis0	= 1;
					else
						MAP_OBJECTS(imapobj,1).vis0	= 0;
					end

					% Connection line between text and symbol:
					if numboundaries(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_lrp(ipoly,1))>0
						% shape0:
						PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_lrp(ipoly,1).shape0		= ...
							PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_lrp(ipoly,1);
						% Source data:
						% Do not assign the same source plot to the connectine line as to the text.
						% When the connection line is deleted, the source of the text is also deleted!
						% PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_lrp(ipoly,1).source		= source;
						% plot-command:
						if isequal(PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd(ipoly,1).color_no,0)
							facecolor	= 'none';
							linewidth	= GV.colorno_e0_linewidth;
						else
							facecolor	= PP.color(PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd(ipoly,1).color_no).rgb/255;
							linewidth	= GV.colorno_g0_linewidth;
						end
						if ~ishandle(GV_H.ax_2dmap)
							errormessage(sprintf(['There exists no map where to plot the objects.\n',...
								'Create the map first.']));
						end
						h_poly_lrp		= plot(GV_H.ax_2dmap,...
							PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_lrp(ipoly,1),...
							'LineWidth',linewidth,...
							'EdgeColor','k',...
							'FaceColor',facecolor,...
							'EdgeAlpha',edgealpha,...
							'FaceAlpha',facealpha,...
							'Visible'  ,visible,...
							'UserData' ,PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_lrp(ipoly,1),...
							'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
						% Connection line: save relevant data in the structure MAP_OBJECTS:
						imapobj					= size(MAP_OBJECTS,1)+1;
						[xcenter,ycenter]		= centroid(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_lrp(ipoly,1));
						MAP_OBJECTS(imapobj,1).disp		= 'connection line';
						MAP_OBJECTS(imapobj,1).h			= h_poly_lrp;
						MAP_OBJECTS(imapobj,1).iobj		= iobj;
						MAP_OBJECTS(imapobj,1).dscr		= PP.obj(iobj,1).description;
						MAP_OBJECTS(imapobj,1).x			= xcenter;
						MAP_OBJECTS(imapobj,1).y			= ycenter;
						MAP_OBJECTS(imapobj,1).text		= PLOTDATA.obj(iobj,1).text_eqtags{iteqt,1};
						MAP_OBJECTS(imapobj,1).mod			= false;
						MAP_OBJECTS(imapobj,1).cncl		= 0;
						MAP_OBJECTS(imapobj,1).cnuc		= 0;
						if strcmp(visible,'on')
							MAP_OBJECTS(imapobj,1).vis0	= 1;
						else
							MAP_OBJECTS(imapobj,1).vis0	= 0;
						end
					end

				end
			end
		end
	end

	% Create/modify legend:
	create_legend_mapfigure;

	% The map has been changed:
	GV.map_is_saved	= 0;

catch ME
	errormessage('',ME);
end

