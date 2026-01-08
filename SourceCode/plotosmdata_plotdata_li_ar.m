function plotosmdata_plotdata_li_ar(...
	iobj,...
	connways_obj_all,...
	ud_in_v,...
	ud_iw_v,...
	ud_ir_v,...
	msg,...
	simplify_moveoutline)
% This function plots lines and areas in the map.
% It is called by plotosmdata_plotdata.m and plotosmdata_convprev2mapobj.

global MAP_OBJECTS PP GV GV_H OSMDATA WAITBAR PLOTDATA

try
	
	% Parameters for line plots (see also plot_modify('change_liwi',imapobj)):
	jointtype		= 'miter';
	miterlimit		= 1;
	
	% Downsampling (see also plot_modify('change_liwi',imapobj)):
	dmax				= [];
	nmin				= [];
	dmin_lines		= PP.obj(iobj).reduce_lines.dmin;			% minimum distance between vertices
	dmin_areas		= PP.obj(iobj).reduce_areas.dmin;
	
	% Downsampling of areas and lines:
	if dmin_areas>0
		for k=1:size(connways_obj_all.areas,1)
			[x,y]	= changeresolution_xy(...
				connways_obj_all.areas(k,1).xy(:,1),...
				connways_obj_all.areas(k,1).xy(:,2),dmax,dmin_areas,nmin);
			connways_obj_all.areas(k,1).xy		= [x y];
		end
	end
	if dmin_lines>0
		for k=1:size(connways_obj_all.lines,1)
			[x,y]	= changeresolution_xy(...
				connways_obj_all.lines(k,1).xy(:,1),...
				connways_obj_all.lines(k,1).xy(:,2),dmax,dmin_lines,nmin);
			connways_obj_all.lines(k,1).xy		= [x y];
		end
	end
	
	% Objects with equal tags: Collect all tags:
	% oeqt(ioeqt,1).tag:
	oeqt		= struct([]);
	if PP.obj(iobj,1).filter_by_key.plot_mapobj_separatly==0
		% The objects are not intended to be plotted separatly:
		oeqt(1,1).tag				= '';
	else
		% The objects are intended to be plotted separatly:
		
		if isempty(PLOTDATA.obj(iobj,1).obj_eqtags)
			% There are no tags:
			oeqt(1,1).tag				= '';
		else
			ioeqt_emptytag				= 0;
			ioeqt							= 0;
			for i=1:size(PLOTDATA.obj(iobj,1).obj_eqtags,1)
				if ~isempty(PLOTDATA.obj(iobj,1).obj_eqtags{i,1})
					ioeqt						= ioeqt+1;
					oeqt(ioeqt,1).tag		= PLOTDATA.obj(iobj,1).obj_eqtags{i,1};
				else
					% This should not happen. But if there are empty tags in PLOTDATA.obj(iobj,1).obj_eqtags, only one
					% element in oeqt(ioeqt,1).tag should be empty.
					if ioeqt_emptytag==0
						ioeqt						= ioeqt+1;
						ioeqt_emptytag			= ioeqt;
						oeqt(ioeqt,1).tag		= '';
					end
				end
			end
			% Detect if there are empty tags in connways_obj_all.lines;
			if ioeqt_emptytag==0
				for k_line=1:size(connways_obj_all.lines,1)
					if isempty(connways_obj_all.lines(k_line,1).tag)
						if isempty(oeqt)
							ioeqt_emptytag					= 1;
						else
							ioeqt_emptytag					= size(oeqt,1)+1;
						end
						oeqt(ioeqt_emptytag,1).tag	= '';
						break
					end
				end
			end
			% Detect if there are empty tags in connways_obj_all.areas;
			if ioeqt_emptytag==0
				for k_area=1:size(connways_obj_all.areas,1)
					if isempty(connways_obj_all.areas(k_area,1).tag)
						if isempty(oeqt)
							ioeqt_emptytag					= 1;
						else
							ioeqt_emptytag					= size(oeqt,1)+1;
						end
						oeqt(ioeqt_emptytag,1).tag	= '';
						break
					end
				end
			end
		end
		
		% Objects with equal tags: Get indices k_lines, k_areas:
		% oeqt(ioeqt,1).k_lines
		% oeqt(ioeqt,1).k_areas
		for ioeqt=1:size(oeqt,1)
			oeqt(ioeqt,1).k_lines	= false(size(connways_obj_all.lines,1),1);
			oeqt(ioeqt,1).k_areas	= false(size(connways_obj_all.areas,1),1);
		end
		for k_line=1:size(connways_obj_all.lines,1)
			for ioeqt=1:size(oeqt,1)
				if strcmp(connways_obj_all.lines(k_line,1).tag,oeqt(ioeqt,1).tag)
					oeqt(ioeqt,1).k_lines(k_line,1)	= true;
					break
				end
			end
		end
		for k_area=1:size(connways_obj_all.areas,1)
			for ioeqt=1:size(oeqt,1)
				if strcmp(connways_obj_all.areas(k_area,1).tag,oeqt(ioeqt,1).tag)
					oeqt(ioeqt,1).k_areas(k_area,1)	= true;
					break
				end
			end
		end
		
	end
	
	replaceplots_area				= 1;
	replaceplots_line_symbols	= 1;
	for ioeqt=1:size(oeqt,1)
		
		if PP.obj(iobj,1).filter_by_key.plot_mapobj_separatly==0
			% The objects are not intended to be plotted separatly:
			connways_obj						= connways_obj_all;
		else
			% The objects are intended to be plotted separatly:
			% connways_obj is a part of connways_obj_all:
			% The fields nodes, xy_start, xy_end, lino_max are not necessary here.
			connways_obj						= connect_ways([]);
			if ~isempty(oeqt(ioeqt,1).k_lines)
				connways_obj.lines				= connways_obj_all.lines(oeqt(ioeqt,1).k_lines,1);
				connways_obj.lines_isouter		= connways_obj_all.lines_isouter(oeqt(ioeqt,1).k_lines,1);
				connways_obj.lines_isinner		= connways_obj_all.lines_isinner(oeqt(ioeqt,1).k_lines,1);
				connways_obj.lines_relid		= connways_obj_all.lines_relid(oeqt(ioeqt,1).k_lines,1);
			end
			if ~isempty(oeqt(ioeqt,1).k_areas)
				connways_obj.areas				= connways_obj_all.areas(oeqt(ioeqt,1).k_areas,1);
				connways_obj.areas_isouter		= connways_obj_all.areas_isouter(oeqt(ioeqt,1).k_areas,1);
				connways_obj.areas_isinner		= connways_obj_all.areas_isinner(oeqt(ioeqt,1).k_areas,1);
				connways_obj.areas_relid		= connways_obj_all.areas_relid(oeqt(ioeqt,1).k_areas,1);
			end
		end
		
		% Create polygons from connways_obj and further downsampling:
		ud_area				= [];
		ud_arsy				= [];
		ud_line				= cell(0,1);
		ud_lisy				= cell(0,1);
		% A single area is plotted with individual regions if necessary.
		% It makes no sense to collect individual areas before plotting them, because otherwise holes will be filled.
		poly_area			= polyshape();
		poly_arsy			= polyshape();
		% lines are initially created individually.
		% Then they are combined in such a way that longer lines overlap shorter lines.
		% This way the line symbols are better preserved.
		poly_line_v			= polyshape();
		poly_lisy_v			= polyshape();
		length_line_v		= [];
		if PP.obj(iobj).display==1
			
			% --------------------------------------------------------------------------------------------------------------
			% Areas:
			if PP.obj(iobj).display_as_area~=0
				if ~isequal(size(connways_obj.areas_relid),size(connways_obj.areas))
					errormessage;
				end
				
				% Convert the area vectors in connways to formattad area polygons:
				[poly_area,poly_arsy,ud_area,ud_arsy,replaceplots_area,connways_obj]	= connwaysarea2polyarea(...
					iobj,...
					connways_obj,...
					msg,...
					simplify_moveoutline,...
					1,...								% testplot
					replaceplots_area,...
					oeqt,...
					ioeqt);
				
				% Plot areas that are not closed:
				for k=1:size(connways_obj.lines,1)

					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						if ~isempty(msg)
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',...
								sprintf('%s plot areas (not closed): %s %g/%g',msg,...
								oeqt(ioeqt,1).tag,k,size(connways_obj.lines,1)));
							drawnow;
						end
					end
					x	= connways_obj.lines(k,1).xy(:,1);
					y	= connways_obj.lines(k,1).xy(:,2);
					% Plot the way as preview:
					imapobj				= size(MAP_OBJECTS,1)+1;
					ud						= [];
					ud.in					= [];
					ud.iw					= connways_obj.lines(k,1).iw_v(:);
					ud.ir					= connways_obj.lines(k,1).ir(:);
					ud.iw(ud.iw==0,:)	= [];
					ud.ir(ud.ir==0,:)	= [];
					ud.rotation			= 0;
					ud.xy0				= [x(:) y(:)];
					ud.relid				= connways_obj.lines_relid(k,1);
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
					end
					h_preview	= plot(GV_H.ax_2dmap,x,y,...
						'Color'        ,GV.preview.Color,...
						'LineStyle'    ,GV.preview.LineStyle,...
						'LineWidth'    ,GV.preview.LineWidth,...
						'UserData'     ,ud,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
					% Save relevant data in the structure MAP_OBJECTS:
					MAP_OBJECTS(imapobj,1).disp	= 'area - not closed';
					MAP_OBJECTS(imapobj,1).h		= h_preview;
					MAP_OBJECTS(imapobj,1).iobj	= iobj;
					MAP_OBJECTS(imapobj,1).dscr	= PP.obj(iobj,1).description;
					MAP_OBJECTS(imapobj,1).x		= mean(x(~isnan(x)));
					MAP_OBJECTS(imapobj,1).y		= mean(y(~isnan(y)));
					MAP_OBJECTS(imapobj,1).text	= {oeqt(ioeqt,1).tag};
					MAP_OBJECTS(imapobj,1).mod		= false;
					MAP_OBJECTS(imapobj,1).cncl	= 0;
					MAP_OBJECTS(imapobj,1).cnuc	= 0;
					MAP_OBJECTS(imapobj,1).vis0	= 1;
					% Collect the object numbers of not closed areas:
					if ~isequal(GV.areas_not_closed_iobj_v,-1)
						% The whole map is being created:
						GV.areas_not_closed_iobj_v		= [GV.areas_not_closed_iobj_v;iobj];
					end
				end
				
			end
			
			% --------------------------------------------------------------------------------------------------------------
			% Lines:
			if PP.obj(iobj).display_as_line~=0
				obj_purpose		= {'map object'};			% cell array: information about the usage of the object
				i_poly_line			= 0;
				for k=1:size(connways_obj.lines,1)
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						if ~isempty(msg)
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',...
								sprintf('%s Create lines: %s %g/%g',msg,...
								oeqt(ioeqt,1).tag,k,size(connways_obj.lines,1)));
							drawnow;
						end
					end
					x										= connways_obj.lines(k,1).xy(:,1);
					y										= connways_obj.lines(k,1).xy(:,2);
					i_poly_line							= i_poly_line+1;
					poly_line_v(i_poly_line,1)		= polyshape();
					poly_lisy_v(i_poly_line,1)		= polyshape();
					[  poly_line_v(i_poly_line,1),...
						poly_lisy_v(i_poly_line,1),...
						ud_line{i_poly_line,1},...
						ud_lisy{i_poly_line,1}]		= line2poly(...
						x,...											% x
						y,...											% y
						PP.obj(iobj).linepar,...				% par
						PP.obj(iobj).linestyle,...				% style
						iobj,...										% iobj
						obj_purpose,...							% obj_purpose
						jointtype,...								% jointtype
						miterlimit,...								% miterlimit
						[],...										% in
						connways_obj.lines(k,1).iw_v,...		% iw
						connways_obj.lines(k,1).ir);			% ir
					poly_line_v(i_poly_line,1)		= changeresolution_poly(poly_line_v(i_poly_line,1),dmax,dmin_lines,nmin);
					poly_lisy_v(i_poly_line,1)		= changeresolution_poly(poly_lisy_v(i_poly_line,1),dmax,dmin_lines,nmin);
					% Line length:
					if any(isnan(x))
						errormessage;
					end
					imax	= size(x,1);
					i		= 1:(imax-1);
					ip1	= 2:imax;
					length_line_v(i_poly_line,1)	= sum(sqrt(...
						(x(ip1,1)-x(i,1)).^2+...
						(y(ip1,1)-y(i,1)).^2    ));
				end
				for k=1:size(connways_obj.areas,1)
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						if ~isempty(msg)
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',...
								sprintf('%s Create closed lines: %s %g/%g',msg,...
								oeqt(ioeqt,1).tag,k,size(connways_obj.areas,1)));
							drawnow;
						end
					end
					x										= connways_obj.areas(k,1).xy(:,1);
					y										= connways_obj.areas(k,1).xy(:,2);
					i_poly_line							= i_poly_line+1;
					poly_line_v(i_poly_line,1)		= polyshape();
					poly_lisy_v(i_poly_line,1)		= polyshape();
					[  poly_line_v(i_poly_line,1),...
						poly_lisy_v(i_poly_line,1),...
						ud_line{i_poly_line,1},...
						ud_lisy{i_poly_line,1}]		= line2poly(...
						x,...											% x
						y,...											% y
						PP.obj(iobj).linepar,...				% par
						PP.obj(iobj).linestyle,...				% style
						iobj,...										% iobj
						obj_purpose,...							% obj_purpose
						jointtype,...								% jointtype
						miterlimit,...								% miterlimit
						[],...										% in
						connways_obj.areas(k,1).iw_v,...		% iw
						connways_obj.areas(k,1).ir);			% ir
					poly_line_v(i_poly_line,1)		= changeresolution_poly(poly_line_v(i_poly_line,1),dmax,dmin_lines,nmin);
					poly_lisy_v(i_poly_line,1)		= changeresolution_poly(poly_lisy_v(i_poly_line,1),dmax,dmin_lines,nmin);
					% Line length:
					if any(isnan(x))
						errormessage;
					end
					imax	= size(x,1);
					i		= 1:(imax-1);
					ip1	= 2:imax;
					length_line_v(i_poly_line,1)	= sum(sqrt(...
						(x(ip1,1)-x(i,1)).^2+...
						(y(ip1,1)-y(i,1)).^2    ));
				end
			end
		end
		
		% Scale-up:
		if    (PP.obj(iobj).scaleup.factor   ~=1)||...
				(PP.obj(iobj).scaleup.mindiag  ~=0)||...
				(PP.obj(iobj).scaleup.minarea  ~=0)
			
			% Scale-up of lines (this normally does not make any sense):
			for i_poly_line=1:size(poly_line_v,1)
				poly_line_reg					= regions(poly_line_v(i_poly_line,1));
				poly_lisy_reg					= polyshape();
				poly_line_v(i_poly_line,1)	= polyshape();
				for ir=1:length(poly_line_reg)
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						if ~isempty(msg)
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',...
								sprintf('%s Scale-up of lines: %s %g/%g',msg,...
								oeqt(ioeqt,1).tag,ir,length(poly_line_reg)));
							drawnow;
						end
					end
					% Greatest area of all boundaries:
					area_boundary	= 0;
					for ib=1:numboundaries(poly_line_reg(ir))
						area_boundary	= max(area_boundary,abs(area(poly_line_reg(ir),ib)));	% The area of holes is negative
					end
					% Diagonal of the bounding box:
					[xlim,ylim]		= boundingbox(poly_line_reg(ir));
					area_diag		= sqrt((xlim(2)-xlim(1))^2+(ylim(2)-ylim(1))^2);
					% Scale-up-factor:
					scaleupfactor	= PP.obj(iobj).scaleup.factor;
					if area_diag<PP.obj(iobj).scaleup.mindiag
						scaleupfactor	= max(scaleupfactor,PP.obj(iobj).scaleup.mindiag/area_diag);
					end
					if area_boundary<PP.obj(iobj).scaleup.minarea
						scaleupfactor	= max(scaleupfactor,sqrt(PP.obj(iobj).scaleup.minarea/area_boundary));
					end
					if scaleupfactor~=1
						% Scale the line:
						[x,y]					= centroid(poly_line_reg(ir));
						poly_line_reg(ir)	= scale(poly_line_reg(ir),scaleupfactor,[x y]);
						% Scale the connected ways:
						if PP.obj(iobj).linestyle==3
							% Continuously changing line width:
							ud_line{i_poly_line,1}.x	= x+(ud_line{i_poly_line,1}.x-x)*scaleupfactor;
							ud_line{i_poly_line,1}.y	= y+(ud_line{i_poly_line,1}.y-y)*scaleupfactor;
						end
						if PP.obj(iobj).linestyle==4
							% Steady change in elevation:
							ud_line{i_poly_line,1}.x_scint	= x+(ud_line{i_poly_line,1}.x_scint-x)*scaleupfactor;
							ud_line{i_poly_line,1}.y_scint	= y+(ud_line{i_poly_line,1}.y_scint-y)*scaleupfactor;
						end
						% Scale the line symbols with respect to the same reference point as the line:
						if numboundaries(poly_lisy_v(i_poly_line,1))>0
							poly_lisy_reg_ir	= scale(poly_lisy_v(i_poly_line,1),scaleupfactor,[x y]);
							poly_lisy_reg		= union(...
								poly_lisy_reg,...
								intersect(poly_lisy_reg_ir,poly_line_reg(ir),'KeepCollinearPoints',false),...
								'KeepCollinearPoints',false);
						end
						% Scale the line length:
						length_line_v(i_poly_line,1)	= length_line_v(i_poly_line,1)*scaleupfactor;
					end
				end
				for ir=1:length(poly_line_reg)
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						if ~isempty(msg)
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',...
								sprintf('%s Scale-up of lines: %s %g/%g %g/%g',msg,...
								oeqt(ioeqt,1).tag,...
								i_poly_line,size(poly_line_v,1),...
								ir,length(poly_line_reg)));
							drawnow;
						end
					end
					poly_line_v(i_poly_line,1)	= union(poly_line_v(i_poly_line,1),poly_line_reg(ir));
				end
				if numboundaries(poly_lisy_v(i_poly_line,1))>0
					poly_lisy_v(i_poly_line,1)	= poly_lisy_reg;
				end
			end
			
			% Scale-up of areas (e. g. castles, churches):
			poly_area_reg	= regions(poly_area);
			for ir=1:length(poly_area_reg)
				% Waitbar:
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					if ~isempty(msg)
						WAITBAR.t1	= clock;
						set(GV_H.text_waitbar,'String',...
							sprintf('%s Scale-up of areas: %s %g/%g',msg,...
							oeqt(ioeqt,1).tag,ir,length(poly_area_reg)));
						drawnow;
					end
				end
				% Greatest area of all boundaries:
				area_boundary	= 0;
				for ib=1:numboundaries(poly_area_reg(ir))
					area_boundary	= max(area_boundary,abs(area(poly_area_reg(ir),ib)));	% The area of holes is negative
				end
				% Diagonal of the bounding box:
				[xlim,ylim]		= boundingbox(poly_area_reg(ir));
				area_diag		= sqrt((xlim(2)-xlim(1))^2+(ylim(2)-ylim(1))^2);
				% Scale-up-factor:
				scaleupfactor	= PP.obj(iobj).scaleup.factor;
				if area_diag<PP.obj(iobj).scaleup.mindiag
					scaleupfactor	= max(scaleupfactor,PP.obj(iobj).scaleup.mindiag/area_diag);
				end
				if area_boundary<PP.obj(iobj).scaleup.minarea
					scaleupfactor	= max(scaleupfactor,sqrt(PP.obj(iobj).scaleup.minarea/area_boundary));
				end
				if scaleupfactor~=1
					[x,y]					= centroid(poly_area_reg(ir));
					poly_area_reg(ir)	= scale(poly_area_reg(ir),scaleupfactor,[x y]);
				end
			end
			poly_area		= polyshape();
			for ir=1:length(poly_area_reg)
				% Waitbar:
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					if ~isempty(msg)
						WAITBAR.t1	= clock;
						set(GV_H.text_waitbar,'String',...
							sprintf('%s Scale-up of areas: %s %g/%g',msg,...
							oeqt(ioeqt,1).tag,ir,length(poly_area_reg)));
						drawnow;
					end
				end
				poly_area	= union(poly_area,poly_area_reg(ir));
			end
			
		end
		
		% Simplify objects and delete or connect small objects by moving the outlines of areas:
		if (PP.obj(iobj).display==1)&&(PP.obj(iobj).display_as_area~=0)&&(simplify_moveoutline~=0)
			[poly_area,replaceplots_area]	= plotosmdata_simplify_moveoutline(...
				iobj,...										% ObjColNo
				poly_area,...								% poly
				'area_after_union',...					% type
				1,...											% testplot
				replaceplots_area,...					% replaceplots
				'object');									% area_limits
		end
		
		% If there are line symboles, combine the lines in such a way that longer lines overlap shorter lines:
		poly_line	= polyshape();
		poly_lisy	= polyshape();
		lisy_exist		= true;
		if isempty(ud_lisy)
			lisy_exist		= false;
		else
			if isempty(ud_lisy{1,1})
				lisy_exist		= false;
			end
		end
		if ~lisy_exist
			% There are no line symbols:
			if (PP.obj(iobj).linestyle==3)||(PP.obj(iobj).linestyle==4)
				% - linestyle=3: Continuously changing line width:
				%   In order to be able to change the line width subsequently, the lines in the map
				%   may only have one start and end point and may therefore not be united:
				% - linestyle=4: Steady change in elevation:
				%   Each line segment has its own elevation data.
				poly_line			= poly_line_v;
				poly_lisy			= poly_lisy_v;
			else
				for i_poly_line=1:size(poly_line_v,1)
					poly_line			= union(poly_line,poly_line_v(i_poly_line,1),'KeepCollinearPoints',false);
					poly_lisy			= union(poly_lisy,poly_lisy_v(i_poly_line,1),'KeepCollinearPoints',false);
				end
			end
		else
			% There are line symbols:
			[~,i_poly_line_sort]	= sort(length_line_v,'descend');
			for i=1:size(i_poly_line_sort,1)
				i_poly_line			= i_poly_line_sort(i,1);
				if i==1
					poly_line		= poly_line_v(i_poly_line,1);
					poly_lisy		= poly_lisy_v(i_poly_line,1);
				else
					% The line symbols (poly_lisy=foreground, e. g. dashs) must be inside the line (poly_line=background):
					% less problems in map2stl.m:
					poly_line_buff			= polybuffer(poly_line,GV.d_forebackgrd_plotobj,'JointType','miter','MiterLimit',2);
					poly_lisy_v(i_poly_line,1)	= subtract(poly_lisy_v(i_poly_line,1),poly_line_buff,...
						'KeepCollinearPoints',false);
					poly_line				= union(poly_line,poly_line_v(i_poly_line,1),'KeepCollinearPoints',false);
					poly_lisy				= union(poly_lisy,poly_lisy_v(i_poly_line,1),'KeepCollinearPoints',false);
				end
			end
			% The line symbols have been cut by other lines. Delete small pieces:
			[poly_lisy,replaceplots_line_symbols]	= plotosmdata_simplify_moveoutline(...
				iobj,...										% ObjColNo
				poly_lisy,...								% poly
				'line_symbols',...						% type
				1,...											% testplot
				replaceplots_line_symbols);			% replaceplots
		end
		
		% Change the resolution a last time.
		% The line/area symbols must be inside the lines/areas (less problems in map2stl.m):
		poly_line		= changeresolution_poly(poly_line,dmax,dmin_lines,nmin);
		poly_lisy		= changeresolution_poly(poly_lisy,dmax,dmin_lines,nmin);
		poly_line_buff	= polybuffer(poly_line,-GV.d_forebackgrd_plotobj,...
			'JointType','miter','MiterLimit',2);
		for i_poly_line=1:size(poly_line,1)
			poly_lisy(i_poly_line,1)		= intersect(poly_lisy(i_poly_line,1),poly_line_buff(i_poly_line,1),...
				'KeepCollinearPoints',false);
		end
		poly_area_buff	= polybuffer(poly_area,-GV.d_forebackgrd_plotobj,...
			'JointType','miter','MiterLimit',2);
		poly_arsy		= intersect(poly_arsy,poly_area_buff,...
			'KeepCollinearPoints',false);
		
		% Plot the polygons, lines and areas:
		if PP.obj(iobj).display==1
			if strcmp(PP.obj(iobj).visibility,'gray out')
				facealpha		= GV.visibility.grayout.facealpha;
				edgealpha		= GV.visibility.grayout.edgealpha;
				visible			= 'on';
			else
				facealpha		= GV.visibility.show.facealpha;
				edgealpha		= GV.visibility.show.edgealpha;
				if strcmp(PP.obj(iobj).visibility,'hide')
					visible		= 'off';
				else
					visible		= 'on';
				end
			end
			
			% Areas:
			if (numboundaries(poly_area)>0)||(numboundaries(poly_arsy)>0)
				imapobj		= size(MAP_OBJECTS,1)+1;
				h_poly_area	= [];
				h_poly_arsy	= [];
				
				% Plot the areas:
				if numboundaries(poly_area)>0
					% Extend the userdata:
					ud_area.shape0	= poly_area;
					% Plot the polygon:
					if isequal(ud_area.color_no,0)
						facecolor	= 'none';
						linewidth	= GV.colorno_e0_linewidth;
					else
						facecolor	= PP.color(ud_area.color_no).rgb/255;
						linewidth	= GV.colorno_g0_linewidth;
					end
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
					end
					h_poly_area		= plot(GV_H.ax_2dmap,poly_area,...
						'LineWidth'    ,linewidth,...
						'EdgeColor'    ,'k',...
						'FaceColor'    ,facecolor,...
						'EdgeAlpha'    ,edgealpha,...
						'FaceAlpha'    ,facealpha,...
						'Visible'		,visible,...
						'UserData'     ,ud_area,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
				end
				
				% Plot the area symbols:
				if numboundaries(poly_arsy)>0
					% Extend the userdata:
					ud_arsy.shape0	= poly_arsy;
					% Plot the polygon:
					if isequal(ud_arsy.color_no,0)
						facecolor	= 'none';
						linewidth	= GV.colorno_e0_linewidth;
					else
						facecolor	= PP.color(ud_arsy.color_no).rgb/255;
						linewidth	= GV.colorno_g0_linewidth;
					end
					if ~ishandle(GV_H.ax_2dmap)
						errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
					end
					h_poly_arsy		= plot(GV_H.ax_2dmap,poly_arsy,...
						'LineWidth'    ,linewidth,...
						'EdgeColor'    ,'k',...
						'FaceColor'    ,facecolor,...
						'EdgeAlpha'    ,edgealpha,...
						'FaceAlpha'    ,facealpha,...
						'Visible'		,visible,...
						'UserData'     ,ud_arsy,...
						'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
				end
				
				% Save relevant data in the structure MAP_OBJECTS:
				[xcenter,ycenter]						= centroid(poly_area);
				MAP_OBJECTS(imapobj,1).disp		= 'area';
				if ~isempty(h_poly_area)&&~isempty(h_poly_arsy)
					MAP_OBJECTS(imapobj,1).h		= [h_poly_area;h_poly_arsy];
				else
					if ~isempty(h_poly_area)
						MAP_OBJECTS(imapobj,1).h	= h_poly_area;
					else
						MAP_OBJECTS(imapobj,1).h	= h_poly_arsy;
					end
				end
				MAP_OBJECTS(imapobj,1).iobj		= iobj;
				MAP_OBJECTS(imapobj,1).dscr		= PP.obj(iobj,1).description;
				MAP_OBJECTS(imapobj,1).x			= xcenter;
				MAP_OBJECTS(imapobj,1).y			= ycenter;
				MAP_OBJECTS(imapobj,1).text		= {oeqt(ioeqt,1).tag};
				MAP_OBJECTS(imapobj,1).mod			= false;
				MAP_OBJECTS(imapobj,1).cncl		= 0;
				MAP_OBJECTS(imapobj,1).cnuc		= 0;
				if strcmp(visible,'on')
					MAP_OBJECTS(imapobj,1).vis0	= 1;
				else
					MAP_OBJECTS(imapobj,1).vis0	= 0;
				end
				
			end
			
			% Lines:
			for i_poly_line=1:size(poly_line,1)
				if (numboundaries(poly_line(i_poly_line,1))>0)||(numboundaries(poly_lisy(i_poly_line,1))>0)
					imapobj		= size(MAP_OBJECTS,1)+1;
					h_poly_line	= [];
					h_poly_lisy	= [];
					
					% Plot the lines:
					if numboundaries(poly_line(i_poly_line,1))>0
						% Extend the userdata:
						ud_line{i_poly_line,1}.shape0	= poly_line(i_poly_line,1);
						% Plot the polygon:
						if isequal(ud_line{i_poly_line,1}.color_no,0)
							facecolor	= 'none';
							linewidth	= GV.colorno_e0_linewidth;
						else
							facecolor	= PP.color(ud_line{i_poly_line,1}.color_no).rgb/255;
							linewidth	= GV.colorno_g0_linewidth;
						end
						if ~ishandle(GV_H.ax_2dmap)
							errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
						end
						h_poly_line		= plot(GV_H.ax_2dmap,poly_line(i_poly_line,1),...
							'LineWidth'    ,linewidth,...
							'EdgeColor'    ,'k',...
							'FaceColor'    ,facecolor,...
							'EdgeAlpha'    ,edgealpha,...
							'FaceAlpha'    ,facealpha,...
							'Visible'		,visible,...
							'UserData'     ,ud_line{i_poly_line,1},...
							'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
					end
					
					% Plot the line symbols:
					if numboundaries(poly_lisy(i_poly_line,1))>0
						% Extend the userdata:
						ud_lisy{i_poly_line,1}.shape0	= poly_lisy(i_poly_line,1);
						% Plot the polygon:
						if isequal(ud_lisy{i_poly_line,1}.color_no,0)
							facecolor	= 'none';
							linewidth	= GV.colorno_e0_linewidth;
						else
							facecolor	= PP.color(ud_lisy{i_poly_line,1}.color_no).rgb/255;
							linewidth	= GV.colorno_g0_linewidth;
						end
						if ~ishandle(GV_H.ax_2dmap)
							errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
						end
						h_poly_lisy		= plot(GV_H.ax_2dmap,poly_lisy(i_poly_line,1),...
							'LineWidth'    ,linewidth,...
							'EdgeColor'    ,'k',...
							'FaceColor'    ,facecolor,...
							'EdgeAlpha'    ,edgealpha,...
							'FaceAlpha'    ,facealpha,...
							'Visible'		,visible,...
							'UserData'     ,ud_lisy{i_poly_line,1},...
							'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
					end
					
					% Save relevant data in the structure MAP_OBJECTS:
					[xcenter,ycenter]						= centroid(poly_line(i_poly_line,1));
					MAP_OBJECTS(imapobj,1).disp		= 'line';
					if ~isempty(h_poly_line)&&~isempty(h_poly_lisy)
						MAP_OBJECTS(imapobj,1).h		= [h_poly_line;h_poly_lisy];
					else
						if ~isempty(h_poly_line)
							MAP_OBJECTS(imapobj,1).h	= h_poly_line;
						else
							MAP_OBJECTS(imapobj,1).h	= h_poly_lisy;
						end
					end
					MAP_OBJECTS(imapobj,1).iobj		= iobj;
					MAP_OBJECTS(imapobj,1).dscr		= PP.obj(iobj,1).description;
					MAP_OBJECTS(imapobj,1).x			= xcenter;
					MAP_OBJECTS(imapobj,1).y			= ycenter;
					MAP_OBJECTS(imapobj,1).text		= {oeqt(ioeqt,1).tag};
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
	
	% Set OSMDATA.iobj:
	if ~isempty(ud_in_v)
		OSMDATA.iobj.node(1,ud_in_v)			= iobj;
	end
	if ~isempty(ud_iw_v)
		OSMDATA.iobj.way(1,ud_iw_v)			= iobj;
	end
	if ~isempty(ud_ir_v)
		OSMDATA.iobj.relation(1,ud_ir_v)		= iobj;
	end
	
catch ME
	errormessage('',ME);
end

