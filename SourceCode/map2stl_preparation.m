function [obj,...
	obj_top_reg,...
	obj_reg,...
	poly_tile,...
	tile_no_all_v,...
	PP_local,...
	ELE_local,...
	poly_legbgd...
	]=map2stl_preparation(...
	map_tile_no,hf_map,PP_local,ELE_local,msg,...
	testout,testout_dzbot,testplot_obj_all,testplot_obj_all_top,testplot_obj,testplot_obj_top,...
	testplot_obj_reg,testplot_obj_reg_1plot,testplot_obj_cut,testplot_poly_cut,testplot_xylimits)
% Called by map2stl
% obj:			Liste aller Objekte, sortiert nach Objektpriorität:
%					-	Polygone mit gleicher Höhe, Objekt- und Farbpriorität zu einem Polygon vereinen.
%					-	Objekte mit der colprio=-1 / colno=0 aufteilen in Gruppen,
%						abhängig von der Farbe, über der diese Objekte verlaufen
% obj_top_reg:	Liste aller Objekte getrennt nach Regionen, sortiert nach Objektpriorität: nur von oben sichtbarer Teil
% obj_reg:		Alle Objekte mit Farbpriorität größer als die Grundfarbe getrennt nach Regionen
%					-	Berechnung von obj.z_bot(iobj) und obj.zbotmax(iobj) (Unterseite)

global GV GV_H WAITBAR PRINTDATA

% The try/catch block is in the calling function!

% % OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!!
% % Fehlersuche in einem bestimmten Bereich der Karte:
% xmin		= -12;
% xmax		= -3;
% ymin		= -7;
% ymax		= 3;
% obj_test_str	= 'obj_bot_bh';	% obj obj_top_reg obj_reg
% eval(sprintf('obj_test	= %s;',obj_test_str));
% iobj_v	= [1;2;3];
% for iobj=1:length(obj_test.poly)
% 	if overlaps(obj_test.poly(iobj),polyshape(...
% 			[xmin xmax xmax xmin],...
% 			[ymin ymin ymax ymax]))
% 		iobj_v	= [iobj_v;iobj];
% 	end
% end
% imax_obj	= length(iobj_v);
% m_obj		= ceil(sqrt(imax_obj+1));
% n_obj		= ceil((imax_obj+1)/m_obj);
% hf			= figure(100250);
% clf(hf,'reset');
% set(hf,'Tag','maplab3d_figure');
% set(hf,'Name',sprintf('obj_test=%s 1',obj_test_str));
% set(hf,'NumberTitle','off');
% for k=1:length(iobj_v)
% 	iobj	= iobj_v(k);
% 	ha		= subplot(m_obj,n_obj,k);
% 	hold(ha,'on');
% 	plot(ha,obj_test.poly(iobj),...
% 		'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
% 		PP_local.color(obj_test.colno(iobj)).rgb/255);
% 	title(sprintf('i=%g, dz=%g\ncp=%g, op=%g',...
% 		iobj,obj_test.dz(iobj),obj_test.colprio(iobj),obj_test.objprio(iobj)),...
% 		'Interpreter','none');
% end
% setbreakpoint	= 1;
% % FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!!


% Initializations:
tol_1			= GV.tol_1;			% Tolerance for comparison of vertex coordinates:
tol_2			= GV.tol_2;			% Tolerance for plausibility questions
WAITBAR.t1	= clock;

% Set the value of the cutting lines dropdown menu to 'None' (make the map objects visible):
set_previewtype_dropdown(1);

% Figure Children:
hc_map			= get(hf_map,'Children');
na_map			= 0;
for i=1:length(hc_map)
	if strcmp(get(hc_map(i),'Type'),'axes')
		ha_map	= hc_map(i);
		na_map	= na_map+1;
	end
end
if na_map~=1
	errormessage(sprintf('Error: The map may only contain one axis.'));
end

% Alle enthaltenen Polygone auslesen (den Rest ignorieren), Objekte und Kachelgrenzen zunächst getrennt zuweisen
% 1)	Objekte der Landkarte (Straßen, Flüsse, ...):
%		ud.color_no		row-number in PP_local.color
%		ud.dz				vertical height
%		ud.prio			priority
%		ud.surftype		surface type
% 2)	Ränder:
%		ud.tile_no     =-1: Edge of the entire map with the planned maximum dimensions
%		ud.tile_no     =0:  Edge of the entire map currently to be printed
%		ud.tile_no     =i:  Edge of the tile i
% Ergebnisse:	poly_map
%					poly_tile
%					poly_obj_map
%					colno_obj_map
%					dz_obj_map
%					objprio_obj_map
%					colprio_obj_map
%					elescint_obj_map			% data for scatteredInterpolant objekts (linestyle=4)
hc							= get(ha_map,'Children');
poly_map_maxdim		= [];
poly_map					= [];
poly_tile				= [];
poly_obj_map			= polyshape();
poly_obj_map(1,:)		= [];					% poly_obj_map = 0×1 polyshape array
colno_obj_map			= [];
dz_obj_map				= [];
objprio_obj_map		= [];
surftype_obj_map		= [];
colprio_obj_map		= [];
elescint_obj_map		= [];
k_obj						= 0;
tile_no_all_v			= [];
poly_legbgd				= polyshape();
prio_legbgd				= -1;
for i=1:length(hc)
	if strcmp(hc(i).Type,'polygon')
		ud=hc(i).UserData;
		if strcmp(hc(i).Visible,'on')
			% The polygon is visible and not grayed out:
			if isfield(ud,'tile_no')
				if ud.tile_no==-1
					% Edge of the entire map with the planned maximum dimensions
					poly_map_maxdim	= hc(i).Shape;
				elseif ud.tile_no==0
					%  Edge of the entire map currently to be printed
					poly_map				= hc(i).Shape;
				elseif ud.tile_no>0
					% Edge of the tile i
					if isempty(map_tile_no)
						tile_no_all_v	= [tile_no_all_v;ud.tile_no ];
						poly_tile		= [poly_tile    ;hc(i).Shape];
					else
						k	= find(map_tile_no==ud.tile_no);
						if length(k)==1
							tile_no_all_v	= [tile_no_all_v;ud.tile_no ];
							poly_tile		= [poly_tile    ;hc(i).Shape];
						end
					end
				end
			elseif isfield(ud,'color_no')&&isfield(ud,'dz')&&isfield(ud,'prio')&&isfield(ud,'surftype')
				if    isequal(hc(i).EdgeAlpha,GV.visibility.show.edgealpha)&&...
						isequal(hc(i).FaceAlpha,GV.visibility.show.facealpha)
					if ud.color_no==0
						% If an object has the color number 0, it receives the color of the object below:
						color_prio	= -1;
					else
						color_prio	= PP_local.color(ud.color_no).prio;
					end
					k_obj								= k_obj+1;
					poly_obj_map(k_obj,1)		= hc(i).Shape;
					colno_obj_map(k_obj,1)		= ud.color_no;
					dz_obj_map(k_obj,1)			= ud.dz;
					objprio_obj_map(k_obj,1)	= ud.prio;
					colprio_obj_map(k_obj,1)	= color_prio;
					surftype_obj_map(k_obj,1)	= ud.surftype;
					if isfield(ud,'x_scint')
						elescint_obj_map(k_obj,1).x_scint	= ud.x_scint;
						elescint_obj_map(k_obj,1).y_scint	= ud.y_scint;
						elescint_obj_map(k_obj,1).z_scint	= ud.z_scint;
					else
						elescint_obj_map(k_obj,1).x_scint	= [];
						elescint_obj_map(k_obj,1).y_scint	= [];
						elescint_obj_map(k_obj,1).z_scint	= [];
					end
					if isfield(ud,'islegbgd')
						if ud.islegbgd
							poly_legbgd	= union(poly_legbgd,hc(i).Shape,'KeepCollinearPoints',false);
							prio_legbgd	= ud.prio;
						end
					end
				end
			end
		end
	end
end

try
	
	if numboundaries(poly_legbgd)>0
		% The legend background can span over different tiles: connect them (works only with 'JointType'='miter'!):
		poly_legbgd	= polybuffer(poly_legbgd,tol_1,...
			'JointType','miter','MiterLimit',2);
		poly_legbgd	= polybuffer(poly_legbgd,-tol_1,...
			'JointType','miter','MiterLimit',2);
	end
	if isempty(poly_map_maxdim)
		fprintf(1,'Error: The tile number -1 does not exist.\n');
	end
	if isempty(poly_map)
		fprintf(1,'Error: The tile number 0 does not exist.\n');
	end
	if isempty(poly_map_maxdim)||isempty(poly_map)
		errormessage(sprintf('Error:\nBefore you create the STL files,\nyou have to create the map.'));
	end
	if length(tile_no_all_v)<1
		errormessage(sprintf('Error:\nThere are no tiles from which\nSTL files can be generated.'));
	end
	[tile_no_all_v,I]	= sort(tile_no_all_v);
	poly_tile			= poly_tile(I,1);
	imax_tile			= length(poly_tile);
	
	% poly_map auf poly_map_maxdim beschneiden:
	poly_map	= intersect(poly_map_maxdim,poly_map);
	if numboundaries(poly_map)==0
		errormessage(sprintf('Error: The map currently to be printed is empty.'));
	end
	
	% Alle Kacheln auf poly_map beschneiden (Achtung: Es könnten auch leere Kacheln entstehen!):
	mapisempty				= true;
	no_nonempty_tiles		= 0;
	for i_tile=1:imax_tile
		poly_tile(i_tile)	= intersect(poly_map,poly_tile(i_tile));
		if numboundaries(poly_tile(i_tile))>0
			mapisempty				= false;
			no_nonempty_tiles		= no_nonempty_tiles+1;
		end
	end
	if mapisempty
		errormessage(sprintf('Error: There are no tiles to print.'));
	end
	
	% Extend the legend background to the edge of the map:
	[poly_legbgd,~]		= get_poly_legbgd_extended(poly_legbgd,PP_local);
	
	% This does not work:
	% [poly_legbgd,poly_legbgd_extension]		= get_poly_legbgd_extended(poly_legbgd,PP_local);
	% % Insert the extension area as plot object to get sharp edges at the edge of the map:
	% if numboundaries(poly_legbgd_extension)>0
	% 	poly_obj_map		= [poly_obj_map    ;poly_legbgd_extension];
	% 	colno_obj_map		= [colno_obj_map   ;0                    ];
	% 	dz_obj_map			= [dz_obj_map      ;0                    ];
	% 	objprio_obj_map	= [objprio_obj_map ;prio_legbgd-1        ];
	%	surftype_obj_map	= [surftype_obj_map;0                    ];
	% 	colprio_obj_map	= [colprio_obj_map ;-1                   ];
	% end
	
	% Subtract the area of the legend from all objects  and
	% cut all objects of the legend to the limits of the legend:
	if numboundaries(poly_legbgd)>0
		% Distance between legend and the other objects:
		dist_legobj_legbgd			= max(0,PP_local.legend.dist_legobj_legbgd);
		d_side							= 0;
		for i=1:size(poly_obj_map,1)
			colno							= colno_obj_map(i,1);
			if colno>0
				icolspec					= PP_local.color(colno).spec;
				d_side					= max(d_side,PP_local.colorspec(icolspec).d_side);
			end
		end
		dist_legobj_legbgd			= dist_legobj_legbgd+d_side+2*tol_1;		% plotosmdata_simplify: +tol_1;
		% Legend buffered (works only with 'JointType'='miter'!):
		poly_legbgd_p_buff		= polybuffer(poly_legbgd,dist_legobj_legbgd,...
			'JointType','miter','MiterLimit',2);
		poly_legbgd_m_buff		= polybuffer(poly_legbgd,-dist_legobj_legbgd,...
			'JointType','miter','MiterLimit',2);
		for i=1:size(poly_obj_map,1)
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1		= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: Cut all objects to the limits of the legend: %g/%g',msg,i,size(poly_obj_map,1)));
				drawnow;
			end
			if objprio_obj_map(i,1)>prio_legbgd
				% poly_obj_map(i,1): Legend exept background:
				% Cut all objects of the legend to the limits of the legend
				poly_obj_map(i,1)		= intersect(poly_obj_map(i,1),poly_legbgd_m_buff,'KeepCollinearPoints',false);
			elseif objprio_obj_map(i,1)<prio_legbgd
				% all other objects:
				% Subtract the area of the legend from all objects that do not belong to the legend
				poly_obj_map(i,1)		= subtract(poly_obj_map(i,1),poly_legbgd_p_buff,'KeepCollinearPoints',false);
			end
		end
	end
	
	% Offenbar nicht nötig:
	% % Legend buffered (works only with 'JointType'='miter'!):
	% % Für eine eindeutige Abfrage ob ein Punkt innerhalb oder außerhalb des Legendenhintergrunds ist:
	% poly_legbgd		= polybuffer(poly_legbgd,tol_1,'JointType','miter','MiterLimit',2);
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Calculation of areas within elevation filter settings different to the tile base settings apply:
	% ELE_local.elecolor(colno,1).elepoly(ip,1).elescint ~= [] (calculation of scatteredInterpolant objects)
	% -----------------------------------------------------------------------------------------------------------------
	
	% Delete existing polygons ELE_local.elecolor(colno,1).elepoly with scatteredInterpolant objects:
	for colno=1:size(PP_local.color,1)
		ipmax				= size(ELE_local.elecolor(colno,1).elepoly,1);
		ip_delete		= false(ipmax,1);
		for ip=1:ipmax
			if ~isempty(ELE_local.elecolor(colno,1).elepoly(ip,1).elescint)
				ip_delete(ip,1)		= true;
			end
		end
		ELE_local.elecolor(colno,1).elepoly(ip_delete,:)	= [];
	end
	
	% Create new scatteredInterpolant objects:
	for i=1:length(elescint_obj_map)
		if ~isempty(elescint_obj_map(i,1).x_scint)
			if numboundaries(poly_obj_map(i))>0
				colno		= colno_obj_map(i);
				ip			= size(ELE_local.elecolor(colno,1).elepoly,1)+1;
				ELE_local.elecolor(colno,1).elepoly(ip,1).eleshape	= poly_obj_map(i);
				ELE_local.elecolor(colno,1).elepoly(ip,1).elescint	= scatteredInterpolant(...
					elescint_obj_map(i,1).x_scint,...
					elescint_obj_map(i,1).y_scint,...
					elescint_obj_map(i,1).z_scint,...
					'natural','linear');
				% Enlarge the parts visible from above by tol so that the inpolygon function in interp_ele works reliably:
				ELE_local.elecolor(colno,1).elepoly(ip,1).eleshape	= polybuffer(...
					ELE_local.elecolor(colno,1).elepoly(ip,1).eleshape,GV.tol_1,...
					'JointType','miter','MiterLimit',2);
			end
		end
	end
	
	% Ab hier werden die Objekte poly_obj_map(i) mit gleichen Farben, aber unterschiedlichen Ojbketnummern
	% zusammengefasst oder subtrahiert. Die Daten
	% elescint_obj_map(i,1).x_scint
	% elescint_obj_map(i,1).y_scint
	% elescint_obj_map(i,1).z_scint
	% sind bestimmten Objektnummern (in der Regel Brücken) zugeordnet. Die scatteredInterpolant Objekte müssen
	% also vor den nächsten Schritten berechnet werden.
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Oberseiten der Objekte berechnen:
	%------------------------------------------------------------------------------------------------------------------
	
	% Initialize PRINTDATA:
	if isfield(PRINTDATA,'frame')
		printdata_frame	= PRINTDATA.frame;
		PRINTDATA			= struct;
		PRINTDATA.frame	= printdata_frame;
	else
		PRINTDATA			= struct;
	end
	PRINTDATA.xmin		= min(poly_map.Vertices(:,1));
	PRINTDATA.xmax		= max(poly_map.Vertices(:,1));
	PRINTDATA.ymin		= min(poly_map.Vertices(:,2));
	PRINTDATA.ymax		= max(poly_map.Vertices(:,2));
	for i_tile=1:imax_tile
		if numboundaries(poly_tile(i_tile))>0
			PRINTDATA.tile(i_tile).xmin		= min(poly_tile(i_tile).Vertices(:,1));
			PRINTDATA.tile(i_tile).xmax		= max(poly_tile(i_tile).Vertices(:,1));
			PRINTDATA.tile(i_tile).ymin		= min(poly_tile(i_tile).Vertices(:,2));
			PRINTDATA.tile(i_tile).ymax		= max(poly_tile(i_tile).Vertices(:,2));
		else
			PRINTDATA.tile(i_tile).xmin		= [];
			PRINTDATA.tile(i_tile).xmax		= [];
			PRINTDATA.tile(i_tile).ymin		= [];
			PRINTDATA.tile(i_tile).ymax		= [];
		end
	end
	PRINTDATA.obj_union_equalcolors		= [];
	
	
	%------------------------------------------------------------------------------------------------------------------
	% obj_all
	%------------------------------------------------------------------------------------------------------------------
	% Alle Polygone auf den Rand der ganzen Karte (poly_map) beschneiden,
	% Polygone mit gleicher Höhe, Objekt- und Farbpriorität zu einem Polygon vereinen,
	% dann alles nach Objektpriorität sortieren.
	% Ergebnisse:	obj_all.poly(iobj)
	%					obj_all.colno(iobj)
	%					obj_all.dz(iobj)
	%					obj_all.zmax(iobj)	maximale Geländehöhe z auf dem Rand des Objekts (ohne dz, nur srftype==xx2)
	%					obj_all.objprio(iobj)
	%					obj_all.colprio(iobj)
	%					obj_all.srftype(iobj)
	
	% Das erste Objekt ist die ganze Karte:
	colno_base			= 1;
	colprio_base		= 0;
	obj_all.poly		= poly_map;
	obj_all.colno		= colno_base;
	obj_all.dz			= 0;
	obj_all.zmax		= 0;
	obj_all.objprio	= 0;
	obj_all.colprio	= colprio_base;
	obj_all.srftype	= 200;	% Area
	
	% Bei der Kachelbasis-Farbe darf die Zuordnung zu anderen Farben nicht akzeptiert werden
	PP_local.color(colno_base).standalone_color		= 1;		% Kachelbasis: stand-alone color
	
	% Objekte zuweisen:
	for i=1:length(poly_obj_map)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1		= clock;
			set(GV_H.text_waitbar,'String',sprintf(...
				'%s: Assign objects: %g/%g',msg,i,size(poly_obj_map,1)));
			drawnow;
		end
		% Alle Objekte auf poly_map beschneiden (Achtung: Es könnten auch leere Objekete entstehen!):
		poly	= intersect(poly_obj_map(i),poly_map);
		if numboundaries(poly)>0
			% Zusammenfassung von Polygonen mit gleichen Werten Höhe, Objektpriorität, Farbpriorität, surfacetype:
			k			= find(...
				(obj_all.dz     ==dz_obj_map(i)      )&...
				(obj_all.objprio==objprio_obj_map(i) )&...
				(obj_all.colprio==colprio_obj_map(i) )&...
				(obj_all.srftype==surftype_obj_map(i)),1);
			% surfacetype=2:	Objekte nicht mit anderen Objekten zusammengeführen, damit zmax richtig berechnet wird!
			if ~isempty(k)&&(mod(surftype_obj_map(i),100)~=2)
				% aktuelles Polygon mit einem vorhandenen Polygon vereinen:
				obj_all.poly(k)	= union(obj_all.poly(k),poly);
			else
				% aktuelles Polygon der Liste hinzufügen:
				obj_all.poly		= [obj_all.poly   ;poly              ];
				obj_all.colno		= [obj_all.colno  ;colno_obj_map(i)  ];
				obj_all.dz			= [obj_all.dz     ;dz_obj_map(i)     ];
				obj_all.zmax		= [obj_all.zmax   ;0                 ];		% zmax wird später zugewiesen
				obj_all.objprio	= [obj_all.objprio;objprio_obj_map(i)];
				obj_all.colprio	= [obj_all.colprio;colprio_obj_map(i)];
				obj_all.srftype	= [obj_all.srftype;surftype_obj_map(i)];
			end
		end
	end
	
	% Sonderbehandlung Legende:
	% Über der Legende sollen sich Teile mit unterschiedlicher Farbe nicht überlappen.
	% Weil über der Legende i. d. R. viele Farben eingesetzt werden, würde die Unterseite sonst stark abgesenkt werden.
	% Sort objects by object color priority:
	[~,i]					= sort(obj_all.colprio);
	obj_all.poly		= obj_all.poly(i);
	obj_all.colno		= obj_all.colno(i);
	obj_all.dz			= obj_all.dz(i);
	obj_all.zmax		= obj_all.zmax(i);
	obj_all.objprio	= obj_all.objprio(i);
	obj_all.colprio	= obj_all.colprio(i);
	obj_all.srftype	= obj_all.srftype(i);
	iobj_legbgd			= find(obj_all.objprio==prio_legbgd);
	if length(iobj_legbgd)==1
		for iobj1=(iobj_legbgd+1):size(obj_all.poly,1)
			
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1		= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: Cut legend objects: %g/%g',msg,iobj1-(iobj_legbgd+1)+1,size(obj_all.poly,1)-(iobj_legbgd+1)+1));
				drawnow;
			end
			
			if (obj_all.objprio(iobj1)>prio_legbgd)&&(obj_all.colno(iobj1)>0)
				% Object 1: legend object
				
				for iobj2=(iobj_legbgd+1):length(obj_all.poly)
					if (obj_all.objprio(iobj2)>prio_legbgd)&&(obj_all.colno(iobj2)>0)
						% Object 2: legend object
						
						if obj_all.colprio(iobj2)>obj_all.colprio(iobj1)
							% Cut object 1 by object 2:
							
							[  obj_all.poly(iobj1),...					% poly1
								obj_all.poly(iobj2),...					% poly2 (Subtrahend)
								~...											% dbuffer
								]=subtract_dside(...
								obj_all.poly(iobj1),...					% poly1
								obj_all.poly(iobj2),...					% poly2 (Subtrahend)
								PP_local,...								% PP_local
								obj_all.colno(iobj1),...				% colno1
								obj_all.colno(iobj2));					% colno2
							
							% % old:
							% % See also plotosmdata_simplify.m
							%
							% % d_side: horizontal distance between the sides of neighboring parts:
							% d_side	= max(...
							% 	PP_local.colorspec(PP_local.color(obj_all.colno(iobj1)).spec).d_side,...
							% 	PP_local.colorspec(PP_local.color(obj_all.colno(iobj2)).spec).d_side);
							%
							% % Objects buffered by the horizontal distance between neighboring parts:
							% % +2*tol: so that no overlap is detected when calculating z_bot in map2stl.m:
							% % +GV.plotosmdata_simplify.dmin_changeresolution*1.01:
							% % the outline is changed when reducing the resolution (see below)
							% dbuffer			= d_side*1.01+2*GV.tol_1+GV.plotosmdata_simplify.dmin_changeresolution*1.01;
							%
							% % Cut object 1 by object 2:
							% if strcmp(GV.jointtype_bh,'miter')
							% 	poly_iobj2_buff	= polybuffer(obj_all.poly(iobj2),dbuffer,...
							% 		'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
							% else
							% 	poly_iobj2_buff	= polybuffer(obj_all.poly(iobj2),dbuffer,...
							% 		'JointType',GV.jointtype_bh);
							% end
							% obj_all.poly(iobj1)	= subtract(obj_all.poly(iobj1),poly_iobj2_buff,...
							% 	'KeepCollinearPoints',false);
							%
							% % Cut object 2 by the already cut object 1:
							% % (should not be necessary, but needed in some special cases)
							% if strcmp(GV.jointtype_bh,'miter')
							% 	poly_iobj1_buff	= polybuffer(obj_all.poly(iobj1),dbuffer,...
							% 		'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
							% else
							% 	poly_iobj1_buff	= polybuffer(obj_all.poly(iobj1),dbuffer,...
							% 		'JointType',GV.jointtype_bh);
							% end
							% obj_all.poly(iobj2)	= subtract(obj_all.poly(iobj2),poly_iobj1_buff,...
							% 	'KeepCollinearPoints',false);
							
						end
					end
				end
			end
		end
	end
	
	% zmax berechnen für alle Objekte mit srftype=xx2:
	% xx2: Flat surface:  All individual regions of the surface have the identical height.
	% Dies muss vor der Zuordnung von Objekten mit colprio==-1 geschehen, weil sonst die Höhe der Objektoberseite
	% von verschiedenen Farben nicht gleich ist.
	% Für den Fall srftype~=xx2 wird zmax mit obj_reg für jede Region einzeln berechnet.
	for iobj=1:size(obj_all.poly,1)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1		= clock;
			set(GV_H.text_waitbar,'String',sprintf(...
				'%s: Object height: %g/%g',msg,iobj,size(obj_all.poly,1)));
			drawnow;
		end
		colno		= obj_all.colno(iobj);
		if colno==0
			% Problem:
			% Objekte mit colno=0 und color_prio=-1 sind keiner Farbe und somit keinen Filtereinstellungen zugeordnet.
			% Da hier noch nicht bekannt ist, über welcher Farbe diese Objekte liegen, kann die korrekte
			% Filtereinstellung nicht bestimmt werden. Weil die Oberseite aber flach ist (srftype=xx2),
			% wirkt sich das evtl. nicht so stark aus.
			% Nutze die Filtereinstellungen bzw. Höhendaten der Kachelbasis:
			colno_interp_ele	= 1;
		else
			colno_interp_ele	= colno;
		end
		if mod(obj_all.srftype(iobj),100)==2
			% Auflösung erhöhen:
			poly_incres		= changeresolution_poly(obj_all.poly(iobj),...
				PP_local.general.dxy_ele_mm/4,...			% dmax
				[],...												% dmin
				[]);													% nmin
			z_margin		= interp_ele(...
				poly_incres.Vertices(:,1),...					% query points x
				poly_incres.Vertices(:,2),...					% query points y
				ELE_local,...										% elevation structure
				colno_interp_ele,...								% color numbers
				GV.legend_z_topside_bgd,...					% legend background z-value
				poly_legbgd,...									% legend background polygon
				'interp2');											% interpolation method
			% max. z-Wert auf dem Rand des Teils:
			obj_all.zmax(iobj,1)	= max(z_margin);
		else
			obj_all.zmax(iobj,1)	= 0;
		end
	end
	
	% Sort objects by object priority:
	[~,i]					= sort(obj_all.objprio);
	obj_all.poly		= obj_all.poly(i);
	obj_all.colno		= obj_all.colno(i);
	obj_all.dz			= obj_all.dz(i);
	obj_all.zmax		= obj_all.zmax(i);
	obj_all.objprio	= obj_all.objprio(i);
	obj_all.colprio	= obj_all.colprio(i);
	obj_all.srftype	= obj_all.srftype(i);
	
	% Testplots:
	if testout==1
		fprintf(1,'\n\nPolygons, original order:\n');
		fprintf(1,'      i         obj_all.colno  obj_all.dz  obj_all.objprio  obj_all.colprio\n');
		for i=1:length(obj_all.colno)
			fprintf(1,'%7.0f%22g%12g%17g%17g\n',...
				i,obj_all.colno(i),obj_all.dz(i),obj_all.objprio(i),obj_all.colprio(i));
		end
	end
	if testplot_obj_all==1
		
		if ~isempty(testplot_xylimits)
			iobj_v			= 1;
			poly_xylimits	= polyshape(...
				[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
				[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
			for iobj=1:length(obj_all.poly)
				if overlaps(obj_all.poly(iobj),poly_xylimits)
					iobj_v	= [iobj_v;iobj];
				end
			end
			iobj_v	= unique(iobj_v);
			imax_obj	= length(iobj_v);
		else
			imax_obj	= length(obj_all.poly);
			iobj_v	= (1:imax_obj)';
		end
		m_obj		= ceil(sqrt(imax_obj+1));
		n_obj		= ceil((imax_obj+1)/m_obj);
		hf=figure(100010);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		set(hf,'Name','obj_all');
		set(hf,'NumberTitle','off');
		
		for k=1:length(iobj_v)
			iobj	= iobj_v(k);
			ha=subplot(m_obj,n_obj,k);
			hold(ha,'on');
			axis(ha,'equal');
			if obj_all.colno(iobj)==0
				plot(ha,obj_all.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceAlpha',0)
				plot(ha,obj_all.poly(iobj).Vertices(:,1),obj_all.poly(iobj).Vertices(:,2),...
					'LineWidth',0.5,'LineStyle','none','Marker','.','MarkerSize',5,...
					'Color','k');
			else
				plot(ha,obj_all.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-',...
					'EdgeColor','k','FaceColor',PP_local.color(obj_all.colno(iobj)).rgb/255)
				plot(ha,obj_all.poly(iobj).Vertices(:,1),obj_all.poly(iobj).Vertices(:,2),...
					'LineWidth',0.5,'LineStyle','none','Marker','.','MarkerSize',5,...
					'Color','k');
			end
			if ~isempty(testplot_xylimits)
				set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
				set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
			else
				set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
				set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
			end
			title(sprintf('i=%g, dz=%g, zmax=%g\ncp=%g, op=%g, st=%g',...
				iobj,obj_all.dz(iobj),obj_all.zmax(iobj),...
				obj_all.colprio(iobj),obj_all.objprio(iobj),obj_all.srftype(iobj)),...
				'Interpreter','none');
		end
		
		ha			= subplot(m_obj,n_obj,imax_obj+1);
		hold(ha,'on');
		axis(ha,'equal');
		imax_obj	= length(obj_all.poly);
		for iobj=1:imax_obj
			if obj_all.colno(iobj)==0
				plot(ha,obj_all.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceAlpha',0)
			else
				plot(ha,obj_all.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-',...
					'EdgeColor','k','FaceColor',PP_local.color(obj_all.colno(iobj)).rgb/255)
			end
		end
		if ~isempty(testplot_xylimits)
			[x,y]		= boundary(poly_xylimits);
			plot(ha,x,y,'-r');
		end
		set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
		set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
		title(sprintf('i=1...%g',imax_obj),'Interpreter','none')
		
	end
	
	%------------------------------------------------------------------------------------------------------------------
	% obj_top
	%------------------------------------------------------------------------------------------------------------------
	% Oberseite:
	% Liste aller Objekte, sortiert nach Objektpriorität: obj_top enthält nur den von oben sichtbaren Teil
	% Vollständig leere Objekte/Polygone brauchen dann nicht mehr betrachtet werden.
	% Leere Objekte werden auch in obj_all gelöscht.
	% Ergebnis:		obj_top.poly(iobj)
	%					obj_top.colno(iobj)
	%					obj_top.dz(iobj)
	%					obj_top.zmax(iobj)
	%					obj_top.objprio(iobj)
	%					obj_top.colprio(iobj)
	%					obj_top.srftype(iobj)
	[obj_all_top,obj_all] = obj2objtop(obj_all,testout,testplot_obj_all_top,testplot_xylimits,...
		100110,PP_local,'obj_all_top',PRINTDATA.xmin,PRINTDATA.xmax,PRINTDATA.ymin,PRINTDATA.ymax,msg);
	
	%------------------------------------------------------------------------------------------------------------------
	% obj
	%------------------------------------------------------------------------------------------------------------------
	% Objekte mit der colprio=-1 aufteilen in Gruppen, abhängig von der Farbe, über der diese Objekte verlaufen,
	% dann zu obj_all hinzufügen
	% Polygone mit gleicher Höhe, Objekt- und Farbpriorität zu einem Polygon vereinen,
	% dann alles nach Objektpriorität sortieren.
	% Ergebnis:		obj.poly(iobj)
	%					obj.colno(iobj)
	%					obj.dz(iobj)
	%					obj.zmax(iobj)
	%					obj.objprio(iobj)
	%					obj.colprio(iobj)
	%					obj.srftype(iobj)
	
	% Das erste Element ist die Grundfläche und wird immer beibehalten:
	obj.poly			= obj_all.poly(1);
	obj.colno		= obj_all.colno(1);
	obj.dz			= obj_all.dz(1);
	obj.zmax			= obj_all.zmax(1);
	obj.objprio		= obj_all.objprio(1);
	obj.colprio		= obj_all.colprio(1);
	obj.srftype		= obj_all.srftype(1);
	iobjmax			= length(obj_all_top.poly);
	
	% Alle Objekte mit colprio>=0 zuweisen:
	for iobj=2:iobjmax
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1		= clock;
			set(GV_H.text_waitbar,'String',sprintf(...
				'%s: Assign objects with color>0: %g/%g',msg,iobj,iobjmax));
			drawnow;
		end
		if obj_all_top.colprio(iobj)>=0
			% Leere Polygone werden ausgeschlossen:
			if numboundaries(obj_all_top.poly(iobj))>0
				% Wenn eine Region vollständig unsichtbar ist, soll diese weggelassen werden:
				% surfacetype=2:	Objekte nicht mit anderen Objekten zusammenführen, damit zmax richtig berechnet wird!
				poly				= polyshape();
				poly0				= regions(obj_all.poly(iobj));
				for i_region=1:length(poly0)
					if numboundaries(intersect(poly0(i_region),obj_all_top.poly(iobj)))>0
						poly		= union(poly,poly0(i_region));
					end
				end
				if numboundaries(poly)>0
					% Die Region ist zumindest teilweise sichtbar:
					obj.poly			= [obj.poly   ;poly                 ];
					obj.colno		= [obj.colno  ;obj_all.colno(iobj)  ];
					obj.dz			= [obj.dz     ;obj_all.dz(iobj)     ];
					obj.zmax			= [obj.zmax   ;obj_all.zmax(iobj)   ];
					obj.objprio		= [obj.objprio;obj_all.objprio(iobj)];
					obj.colprio		= [obj.colprio;obj_all.colprio(iobj)];
					obj.srftype		= [obj.srftype;obj_all.srftype(iobj)];
				end
				
			end
		end
	end
	
	% Alle Objekte mit colprio==-1 zuweisen:
	for iobj=2:iobjmax
		if obj_all_top.colprio(iobj)==-1
			% Leere Polygone werden ausgeschlossen:
			if numboundaries(obj_all_top.poly(iobj))>0
				
				% Weil hier evtl. einem Objekt unterschiedliche Farben zugewiesen werden, wird nach Farben gruppiert:
				colno_v			= zeros(0,1);
				colprio_v		= zeros(0,1);
				poly_v			= polyshape();
				poly0				= regions(obj_all_top.poly(iobj));
				% Farbe bestimmen, die die einzelnen Regionen haben sollen:
				i_region_max	= length(poly0);
				for i_region=1:i_region_max
					% Die oben liegenden Teile dieser Region können über unterschiedlichen Farben liegen:
					% Aufteilen in Teilbereiche abhängig von der darunter liegenden Farbe:
					for iobj2=(iobj-1):-1:1
						% Waitbar:
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							WAITBAR.t1		= clock;
							set(GV_H.text_waitbar,'String',sprintf(...
								'%s: Assign objects with color=0: %g/%g %g/%g %g/%g',msg,...
								iobj,iobjmax,...
								i_region,i_region_max,...
								iobj-iobj2,iobj-1));
							drawnow;
						end
						if obj_all_top.colprio(iobj2)>=0
							poly2	= intersect(poly0(i_region),obj_all.poly(iobj2));
							if numboundaries(poly2)>0
								% poly2 liegt über der aktuellen Farbe iobj2: Fläche speichern:
								% ..(iobj):  Eigenschaften des Objekts übernehmen
								% ..(iobj2): Eigenschaften der darunterliegenden Farbe übernehmen
								k_colprio		= find(colprio_v==obj_all_top.colprio(iobj2));
								if isempty(k_colprio)
									colno_v(end+1,1)					= obj_all_top.colno(iobj2);
									colprio_v(end+1,1)				= obj_all_top.colprio(iobj2);
									poly_v(size(colprio_v,1),1)	= poly2;
								else
									poly_v(k_colprio,1)				= union(poly_v(k_colprio,1),poly2);
								end
							end
							poly0(i_region)	= subtract(poly0(i_region),poly2);
						end
					end
				end
				for k_colprio=1:size(colprio_v,1)
					obj.poly			= [obj.poly   ;poly_v(k_colprio,1)       ];
					obj.colno		= [obj.colno  ;colno_v(k_colprio,1)      ];
					obj.dz			= [obj.dz     ;obj_all_top.dz(iobj)      ];
					obj.zmax			= [obj.zmax   ;obj_all_top.zmax(iobj)    ];
					obj.objprio		= [obj.objprio;obj_all_top.objprio(iobj )];
					obj.colprio		= [obj.colprio;colprio_v(k_colprio,1)    ];
					obj.srftype		= [obj.srftype;obj_all_top.srftype(iobj) ];
				end
				
			end
		end
	end
	
	% Zusammenfassung von Polygonen mit gleichen Werten Höhe, zmax, Objektpriorität, Farbpriorität, surfacetype:
	iobj		= 1;
	while iobj<=(length(obj.poly)-1)
		iobj	= iobj+1;
		k	= find(...
			(obj.dz     ==obj.dz(iobj)     )&...
			(obj.zmax   ==obj.zmax(iobj)   )&...
			(obj.objprio==obj.objprio(iobj))&...
			(obj.colprio==obj.colprio(iobj))&...
			(obj.srftype==obj.srftype(iobj))    );
		k=k((k~=iobj)&(k~=1));
		for i=1:length(k)
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1	= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: preparation: color number 0 %g/%g %g/%g',msg,...
					iobj,(length(obj.poly)-1),...
					i,length(k)));
				drawnow;
			end
			obj.poly(iobj)	= union(obj.poly(iobj),obj.poly(k(i)));
		end
		obj.poly(k)			= [];
		obj.colno(k)		= [];
		obj.dz(k)			= [];
		obj.zmax(k)			= [];
		obj.objprio(k)		= [];
		obj.colprio(k)		= [];
		obj.srftype(k)		= [];
	end
	
	% Alles nach Objektpriorität und dann nach Farbpriorität sortieren, außer das erste Element.
	% Die Objekte sind eindeutig nach Objektpriorität sortiert.
	% Nur bei gleicher Objektpriorität (sollte nicht vorkommen) wird nach Farbpriorität sortiert.
	if length(obj.poly)>=2
		diffuniq_objprio		= diff(unique(obj.objprio(2:end)));
		if ~isempty(diffuniq_objprio)
			[~,i_objprio]		= sort(obj.objprio(2:end) + ...
				min(diffuniq_objprio) * obj.colprio(2:end) / (max(obj.colprio(2:end))+1));
		else
			% There is only one object priority (this should not happen): Sort by color priority:
			[~,i_objprio]		= sort(obj.colprio(2:end) / (max(obj.colprio(2:end))+1));
		end
		obj.poly(2:end)				= obj.poly(i_objprio+1);
		obj.colno(2:end)				= obj.colno(i_objprio+1);
		obj.dz(2:end)					= obj.dz(i_objprio+1);
		obj.zmax(2:end)				= obj.zmax(i_objprio+1);
		obj.objprio(2:end)			= obj.objprio(i_objprio+1);
		obj.colprio(2:end)			= obj.colprio(i_objprio+1);
		obj.srftype(2:end)			= obj.srftype(i_objprio+1);
	end
	
	% Im Index 1 stehen später die Außenabmessungen des Druckteils: erweitern:
	if length(obj.poly)>=1
		obj.poly				= [obj.poly(1)   ;obj.poly   ];
		obj.colno			= [obj.colno(1)  ;obj.colno  ];
		obj.dz				= [obj.dz(1)     ;obj.dz     ];
		obj.zmax				= [obj.zmax(1)   ;obj.zmax   ];
		obj.objprio			= [obj.objprio(1);obj.objprio];
		obj.colprio			= [obj.colprio(1);obj.colprio];
		obj.srftype			= [obj.srftype(1);obj.srftype];
	end
	
	% Testplots:
	if testplot_obj==1
		
		if ~isempty(testplot_xylimits)
			iobj_v			= 1;
			poly_xylimits	= polyshape(...
				[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
				[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
			for iobj=1:length(obj.poly)
				if overlaps(obj.poly(iobj),poly_xylimits)
					iobj_v	= [iobj_v;iobj];
				end
			end
			iobj_v	= unique(iobj_v);
			imax_obj	= length(iobj_v);
		else
			imax_obj	= length(obj.poly);
			iobj_v	= (1:imax_obj)';
		end
		m_obj		= ceil(sqrt(imax_obj+1));
		n_obj		= ceil((imax_obj+1)/m_obj);
		hf=figure(100020);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		set(hf,'Name','obj');
		set(hf,'NumberTitle','off');
		
		for k=1:length(iobj_v)
			iobj	= iobj_v(k);
			ha=subplot(m_obj,n_obj,k);
			hold(ha,'on');
			axis(ha,'equal');
			if obj.colno(iobj)==0
				plot(ha,obj.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceAlpha',0)
				plot(ha,obj.poly(iobj).Vertices(:,1),obj.poly(iobj).Vertices(:,2),...
					'LineWidth',0.5,'LineStyle','none','Marker','.','MarkerSize',5,...
					'Color','k');
			else
				plot(ha,obj.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',PP_local.color(obj.colno(iobj)).rgb/255)
				plot(ha,obj.poly(iobj).Vertices(:,1),obj.poly(iobj).Vertices(:,2),...
					'LineWidth',0.5,'LineStyle','none','Marker','.','MarkerSize',5,...
					'Color','k');
			end
			if ~isempty(testplot_xylimits)
				set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
				set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
			else
				set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
				set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
			end
			title(sprintf('i=%g, dz=%g, zmax=%g\ncp=%g, op=%g, st=%g',...
				iobj,obj.dz(iobj),obj.zmax(iobj),...
				obj.colprio(iobj),obj.objprio(iobj),obj.srftype(iobj)),'Interpreter','none')
		end
		
		ha			= subplot(m_obj,n_obj,imax_obj+1);
		hold(ha,'on');
		axis(ha,'equal');
		imax_obj	= length(obj.poly);
		for iobj=2:imax_obj
			if obj.colno(iobj)==0
				plot(ha,obj.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceAlpha',0)
			else
				plot(ha,obj.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',PP_local.color(obj.colno(iobj)).rgb/255)
			end
		end
		if ~isempty(testplot_xylimits)
			[x,y]		= boundary(poly_xylimits);
			plot(ha,x,y,'-r');
		end
		set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
		set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
		title(sprintf('i=2...%g',imax_obj),'Interpreter','none')
		
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Cut into pieces
	%------------------------------------------------------------------------------------------------------------------
	% Ergebnis:		veränderte Struktur obj: Die Regionen haben die vorgegebene maximale Größe.
	%					Die Reihenfolge und Anzahl wird nicht verändert.
	%					obj.poly(iobj)
	%					obj.colno(iobj)
	%					obj.dz(iobj)
	%					obj.zmax(iobj)
	%					obj.objprio(iobj)
	%					obj.colprio(iobj)
	%					obj.srftype(iobj)
	
	% Verbinden von sich überlappenden Objekten
	PRINTDATA.obj_union_equalcolors	= polyshape();
	for iobj=1:length(obj.poly)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			set(GV_H.text_waitbar,'String',sprintf(...
				'%s: cut into pieces: connect overlapping objects %g/%g',msg,...
				iobj,length(obj.poly)));
			drawnow;
		end
		colno		= obj.colno(iobj,1);
		if PP_local.color(colno).standalone_color~=0
			% The color is printed stand-alone and serves as a basis for non-stand-alone colors:
			if (obj.colprio(iobj,1)>0)&&(obj.colno(iobj,1)>0)
				if size(PRINTDATA.obj_union_equalcolors,1)<obj.colno(iobj,1)
					PRINTDATA.obj_union_equalcolors(colno,1)	= obj.poly(iobj,1);
				else
					PRINTDATA.obj_union_equalcolors(colno,1)	= union(...
						PRINTDATA.obj_union_equalcolors(colno,1),...
						obj.poly(iobj,1),...
						'KeepCollinearPoints',false);
				end
			end
		else
			% PRINTDATA.obj_union_equalcolors soll alle vorhandenen Farbnummern enthalten,
			% auch wenn die Felder leer sind:
			PRINTDATA.obj_union_equalcolors(colno,1)	= polyshape();
		end
	end
	
	% PRINTDATA.obj_union_equalcolors_0:
	% Possibility to reset_uec all changes to PRINTDATA.obj_union_equalcolors:
	PRINTDATA.obj_union_equalcolors_0	= PRINTDATA.obj_union_equalcolors;
	
	% After calculation of PRINTDATA.obj_union_equalcolors:
	% Set the selectable color numbers for creating cutting lines.
	% This is done in create_unitedcolors.m, otherwise the legend would be also selectable!
	% set_previewtype_dropdown(1);
	
	if nargout>0
		
		% Trennlinien berechnen:
		poly_cut	= polyshape();
		for colno=1:size(PRINTDATA.obj_union_equalcolors,1)
			msg_colno	= sprintf(...
				'%s: cut into pieces: color %g/%g',msg,...
				colno,size(PRINTDATA.obj_union_equalcolors,1));
			poly_cut(colno,1)	= polyshape();
			if numboundaries(PRINTDATA.obj_union_equalcolors(colno,1))>0
				[~,...
					poly_cut(colno,1)]	= cut_into_pieces(...
					PRINTDATA.obj_union_equalcolors(colno,1),...
					poly_cut(colno,1),...
					poly_tile,...
					colno,...
					msg_colno);
			end
		end
		
		% Objekte trennen:
		for iobj=1:length(obj.poly)
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1	= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: cut into pieces: cut object %g/%g',msg,...
					iobj,length(obj.poly)));
				drawnow;
			end
			if (obj.colprio(iobj,1)>0)&&(obj.colno(iobj,1)>0)
				colno		= obj.colno(iobj,1);
				if numboundaries(poly_cut(colno,1))>0
					if numboundaries(obj.poly(iobj,1))>0
						obj.poly(iobj,1)		= subtract(obj.poly(iobj,1),poly_cut(colno,1),'KeepCollinearPoints',false);
					end
				end
			end
		end
		
	end
	
	% Testplot: Cut into pieces: Liste aller Objekte nach dem Zerteilen (obj)
	if (testplot_obj_cut~=0)&&(nargout>0)
		
		if ~isempty(testplot_xylimits)
			iobj_v			= 1;
			poly_xylimits	= polyshape(...
				[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
				[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
			for iobj=1:length(obj.poly)
				if overlaps(obj.poly(iobj),poly_xylimits)
					iobj_v	= [iobj_v;iobj];
				end
			end
			iobj_v	= unique(iobj_v);
			imax_obj	= length(iobj_v);
		else
			imax_obj	= length(obj.poly);
			iobj_v	= (1:imax_obj)';
		end
		m_obj		= ceil(sqrt(imax_obj+1));
		n_obj		= ceil((imax_obj+1)/m_obj);
		hf=figure(100140);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		set(hf,'Name','obj');
		set(hf,'NumberTitle','off');
		
		for k=1:length(iobj_v)
			iobj	= iobj_v(k);
			ha=subplot(m_obj,n_obj,k);
			hold(ha,'on');
			axis(ha,'equal');
			if obj.colno(iobj)==0
				plot(ha,obj.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceAlpha',0)
				plot(ha,obj.poly(iobj).Vertices(:,1),obj.poly(iobj).Vertices(:,2),...
					'LineWidth',0.5,'LineStyle','none','Marker','.','MarkerSize',5,...
					'Color','k');
			else
				plot(ha,obj.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',PP_local.color(obj.colno(iobj)).rgb/255)
				plot(ha,obj.poly(iobj).Vertices(:,1),obj.poly(iobj).Vertices(:,2),...
					'LineWidth',0.5,'LineStyle','none','Marker','.','MarkerSize',5,...
					'Color','k');
			end
			if ~isempty(testplot_xylimits)
				set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
				set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
			else
				set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
				set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
			end
			title(sprintf('i=%g, dz=%g, zmax=%g\ncp=%g, op=%g, st=%g',...
				iobj,obj.dz(iobj),obj.zmax(iobj),...
				obj.colprio(iobj),obj.objprio(iobj),obj.srftype(iobj)),'Interpreter','none')
		end
		
		ha			= subplot(m_obj,n_obj,imax_obj+1);
		hold(ha,'on');
		axis(ha,'equal');
		imax_obj	= length(obj.poly);
		for iobj=1:imax_obj
			if obj.colno(iobj)==0
				plot(ha,obj.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceAlpha',0)
			else
				plot(ha,obj.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',PP_local.color(obj.colno(iobj)).rgb/255)
			end
		end
		if ~isempty(testplot_xylimits)
			[x,y]		= boundary(poly_xylimits);
			plot(ha,x,y,'-r');
		end
		set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
		set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
		title(sprintf('i=1...%g',imax_obj),'Interpreter','none')
		
	end
	
	% Testplot: Cut into pieces: Schnittlinien (PRINTDATA.obj_union_equalcolors):
	if testplot_poly_cut~=0
		
		if ~isempty(testplot_xylimits)
			colno_v			= [];
			poly_xylimits	= polyshape(...
				[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
				[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
			for colno=1:length(PRINTDATA.obj_union_equalcolors.poly)
				if overlaps(PRINTDATA.obj_union_equalcolors(colno,1),poly_xylimits)
					if numboundaries(PRINTDATA.obj_union_equalcolors(colno,1))>0
						colno_v	= [colno_v;colno];
					end
				end
			end
			colno_v	= unique(colno_v);
		else
			colno_v			= [];
			for colno=1:length(PRINTDATA.obj_union_equalcolors)
				if numboundaries(PRINTDATA.obj_union_equalcolors(colno,1))>0
					colno_v	= [colno_v;colno];
				end
			end
			colno_v	= unique(colno_v);
		end
		m_col		= ceil(sqrt(length(colno_v)+1));
		n_col		= ceil((length(colno_v)+1)/m_col);
		hf=figure(100150);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		set(hf,'Name','PRINTDATA.obj_union_equalcolors');
		set(hf,'NumberTitle','off');
		
		for k=1:length(colno_v)
			colno	= colno_v(k);
			ha=subplot(m_col,n_col,k);
			hold(ha,'on');
			axis(ha,'equal');
			plot(ha,PRINTDATA.obj_union_equalcolors(colno,1),...
				'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',PP_local.color(colno).rgb/255)
			plot(ha,poly_cut(colno,1)	,...
				'LineWidth',0.5,'LineStyle','-','EdgeColor','r','FaceAlpha',0)
			if ~isempty(testplot_xylimits)
				set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
				set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
			else
				set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
				set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
			end
			title(sprintf('colno=%g',colno),'Interpreter','none')
		end
		
		ha			= subplot(m_col,n_col,length(colno_v)+1);
		hold(ha,'on');
		axis(ha,'equal');
		for k=1:length(colno_v)
			colno	= colno_v(k);
			plot(ha,PRINTDATA.obj_union_equalcolors(colno,1),...
				'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',PP_local.color(colno).rgb/255)
		end
		if ~isempty(testplot_xylimits)
			[x,y]		= boundary(poly_xylimits);
			plot(ha,x,y,'-r');
		end
		set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
		set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
		if length(colno_v)>=1
			title(sprintf('colno=1...%g',colno_v(end)),'Interpreter','none')
		end
		
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% obj_reg: Delete objects that are too small
	%------------------------------------------------------------------------------------------------------------------
	% - Alle Objekte mit Farbpriorität größer als die Grundfarbe sortiert nach Regionen
	
	obj_reg.poly				= [];
	obj_reg.colno				= [];
	obj_reg.dz					= [];
	obj_reg.zmax				= [];
	obj_reg.objprio			= [];
	obj_reg.colprio			= [];
	obj_reg.srftype			= [];
	
	if nargout>0
		
		for iobj=1:length(obj.poly)
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1		= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: Create regions: %g/%g',msg,iobj,length(obj.poly)));
				drawnow;
			end
			if numboundaries(obj.poly(iobj))>0
				poly					= regions(obj.poly(iobj));
				for i_region=1:length(poly)
					obj_reg.poly		= [obj_reg.poly   ;poly(i_region)   ];
					obj_reg.colno		= [obj_reg.colno  ;obj.colno(iobj)  ];
					obj_reg.dz			= [obj_reg.dz     ;obj.dz(iobj)     ];
					obj_reg.zmax		= [obj_reg.zmax   ;obj.zmax(iobj)   ];
					obj_reg.objprio	= [obj_reg.objprio;obj.objprio(iobj)];
					obj_reg.colprio	= [obj_reg.colprio;obj.colprio(iobj)];
					obj_reg.srftype	= [obj_reg.srftype;obj.srftype(iobj)];
				end
			end
		end
		
		% Delete objects, that are too small:
		% 1) Delete small objects, that cannot be printed.
		% 2) Defining an overhang (dxy_overhang>0) can cause the bottom side of narrow lines (e.g. streets) to become
		%    too narrow, so that they cannot be printed.
		% To avoid these problems, all objects with a width smaller than 2*dxy_overhang+minbottomwidth_obj
		% will be deleted.
		% Criterium: The outline of the object is moved by (dxy_overhang+PP_local.general.minbottomwidth_obj/2) outwards
		% and inwards. If the area has become less than 90% of the area before, the object is deleted.
		% Changing the outline at this point is not recommended, because the lines are not exactly at the same place
		% after the shifting with polybuffer. This can cause problems with intersections of text and text-background.
		iobj_delete	= [];
		iobjmax		= size(obj_reg.poly,1);
		for iobj=1:iobjmax
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1		= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: Delete small objects: %g/%g',msg,iobj,size(obj_reg.poly,1)));
				drawnow;
			end
			if obj_reg.colprio(iobj)~=colprio_base
				colno				= obj_reg.colno(iobj);
				icolspec			= PP_local.color(colno).spec;
				dxy_overhang	= max(0,PP_local.colorspec(icolspec).dxy_overhang);
				dbuffer			= dxy_overhang+PP_local.general.minbottomwidth_obj/2;
				poly_after		= polybuffer(obj_reg.poly(iobj),-dbuffer,'JointType','miter','MiterLimit',3);
				poly_after		= polybuffer(poly_after        , dbuffer,'JointType','miter','MiterLimit',3);
				if numboundaries(poly_after)==0
					% Das Objekt ist zu klein und wird gelöscht:
					iobj_delete	= [iobj_delete iobj];
				else
					poly_after					= regions(poly_after);
					if length(poly_after)>=2
						% Es ist mindestens eine zusätzliche Region entstanden:
						obj_reg.poly(iobj)	= poly_after(1);
						for i_region=2:length(poly_after)
							obj_reg.poly		= [obj_reg.poly   ;poly_after(i_region) ];
							obj_reg.colno		= [obj_reg.colno  ;obj_reg.colno(iobj)  ];
							obj_reg.dz			= [obj_reg.dz     ;obj_reg.dz(iobj)     ];
							obj_reg.zmax		= [obj_reg.zmax   ;obj_reg.zmax(iobj)   ];
							obj_reg.objprio	= [obj_reg.objprio;obj_reg.objprio(iobj)];
							obj_reg.colprio	= [obj_reg.colprio;obj_reg.colprio(iobj)];
							obj_reg.srftype	= [obj_reg.srftype;obj_reg.srftype(iobj)];
						end
					end
				end
			end
		end
		
		% Delete empty objects or objects, that have become too small:
		if ~isempty(iobj_delete)
			obj_reg.poly(iobj_delete)		= [];
			obj_reg.colno(iobj_delete)		= [];
			obj_reg.dz(iobj_delete)			= [];
			obj_reg.zmax(iobj_delete)		= [];
			obj_reg.objprio(iobj_delete)	= [];
			obj_reg.colprio(iobj_delete)	= [];
			obj_reg.srftype(iobj_delete)	= [];
		end
		
	end
	
	
	
	%------------------------------------------------------------------------------------------------------------------
	% obj_top_reg
	% Dies ist der letzte Stand vor der Berechnung der Höhen mit interp_ele:
	% Hier müssen die Höhendaten um Polygone von Flächen erweitert werden, bei denen sich die Filtereinstellung
	% von denen der Kachelbasis unterscheiden.
	%------------------------------------------------------------------------------------------------------------------
	% Oberseite:
	% Liste aller Objekte, sortiert nach Objektpriorität: obj_top_reg enthält nur den von oben sichtbaren Teil
	% Vollständig leere Objekte/Polygone brauchen dann nicht mehr betrachtet werden.
	% Leere Objekte werden auch in obj gelöscht, daher vor "Cut into pieces" ausführen.
	% Ergebnis:		obj_top_reg.poly(iobj)
	%					obj_top_reg.colno(iobj)
	%					obj_top_reg.dz(iobj)
	%					obj_top_reg.zmax(iobj)
	%					obj_top_reg.objprio(iobj)
	%					obj_top_reg.colprio(iobj)
	%					obj_top_reg.srftype(iobj)
	[  obj_top_reg,...
		obj_reg...
		] = obj2objtop(...
		obj_reg,testout,testplot_obj_top,testplot_xylimits,100130,PP_local,'obj_top_reg',...
		PRINTDATA.xmin,PRINTDATA.xmax,PRINTDATA.ymin,PRINTDATA.ymax,msg);
	
	% Das Objekt 2 wieder zuweisen:
	obj_reg.poly(2)		= obj_reg.poly(1);
	obj_reg.colno(2)		= obj_reg.colno(1);
	obj_reg.dz(2)			= obj_reg.dz(1);
	obj_reg.zmax(2)		= obj_reg.zmax(1);
	obj_reg.objprio(2)	= obj_reg.objprio(1);
	obj_reg.colprio(2)	= obj_reg.colprio(1);
	obj_reg.srftype(2)	= obj_reg.srftype(1);
	
	% -----------------------------------------------------------------------------------------------------------------
	% Calculation of areas within elevation filter settings different to the tile base settings apply:
	% ELE_local.elecolor(colno,1).elepoly(ip,1).elescint  = []
	% -----------------------------------------------------------------------------------------------------------------
	
	% Es werden nur Polygone von Farben erstellt, die andere Filtereinstellungen haben als die Grundkachel.
	% Bei der Zuweisung der Höhendaten anhand der Polygone in interp_ele.m erfolgt die Reihenfolge anhand der
	% Farbpriorität, also dürfen sich die Polygone überlappen.
	
	% Delete existing polygons
	ip_v				= zeros(size(PP_local.color,1),1);		% Indices where to save the polygons
	for colno=1:size(PP_local.color,1)
		ipmax				= size(ELE_local.elecolor(colno,1).elepoly,1);
		ip_delete		= false(ipmax,1);
		for ip=1:ipmax
			if isempty(ELE_local.elecolor(colno,1).elepoly(ip,1).elescint)
				ip_delete(ip,1)		= true;
			end
		end
		ELE_local.elecolor(colno,1).elepoly(ip_delete,:)	= [];
		ip_v(colno,1)													= size(ELE_local.elecolor(colno,1).elepoly,1)+1;
		ip																	= ip_v(colno,1);
		ELE_local.elecolor(colno,1).elepoly(ip,:).eleshape	= polyshape();
	end
	
	% Unite all polygons obj_top_reg.poly(i), sorted by color:
	for i=1:length(obj_top_reg.poly)
		colno					= obj_top_reg.colno(i);
		ip						= ip_v(colno,1);
		ifs					= ELE_local.elecolor(colno,1).ifs;
		if ifs>1
			% Nur Polygone für Filtereinstellungen sammeln, die nicht identisch mit denen der Grundkachel sind (ifs>1):
			ELE_local.elecolor(colno,1).elepoly(ip,1).eleshape			= union(...
				ELE_local.elecolor(colno,1).elepoly(ip,1).eleshape,...
				obj_top_reg.poly(i));
		end
	end
	
	% Delete empty polygons and
	% enlarge the parts visible from above by tol so that the inpolygon function in interp_ele works reliably:
	for colno=1:size(PP_local.color,1)
		ip						= ip_v(colno,1);
		if numboundaries(ELE_local.elecolor(colno,1).elepoly(ip,1).eleshape)==0
			ELE_local.elecolor(colno,1).elepoly(ip,:)		= [];
		else
			ELE_local.elecolor(colno,1).elepoly(ip,1).eleshape	= polybuffer(...
				ELE_local.elecolor(colno,1).elepoly(ip,1).eleshape,GV.tol_1,...
				'JointType','miter','MiterLimit',2);
			ELE_local.elecolor(colno,1).elepoly(ip,1).elescint	= [];
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% obj_reg: Berechnung von obj.zmax(iobj) für den Fall srftype~=xx2
	%------------------------------------------------------------------------------------------------------------------
	% - obj.zmax(iobj): Maximale Geländehöhe z auf dem Rand des Objekts (ohne dz), für den Fall srftype~=xx2:
	%   0: The surface height follows the terrain, raised by dz.
	%   1: Flat surface: This applies to all individual regions of the surface area.
	%   Dies muss vor dem Aufteilen in Teilflächen für Multimaterial prints geschehen, damit die Flächen immer noch
	%   dieselbe Höhe haben
	% - Für den Fall srftype==xx2 wird zmax mit obj_all für das ganze Objekt berechnet.
	%   2: Flat surface:  All individual regions of the surface have the same height.
	
	if nargout>0
		
		% maximalen Wert der Geländehöhe z für jedes Objekt berechnen (obj_reg.zmax(iobj)):
		for iobj=1:length(obj_reg.poly)
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1		= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: max. Object height: %g/%g',msg,iobj,length(obj_reg.poly)));
				drawnow;
			end
			% max. z-Wert auf dem Rand des Teils:
			% Für den Fall srftype==xx2 wird zmax mit obj_all für das ganze Objekt berechnet.
			colno			= obj_reg.colno(iobj);
			% Auflösung erhöhen:
			poly_incres		= changeresolution_poly(obj_reg.poly(iobj),...
				PP_local.general.dxy_ele_mm/4,...			% dmax
				[],...												% dmin
				[]);													% nmin
			z_margin			= interp_ele(...
				poly_incres.Vertices(:,1),...		% query points x
				poly_incres.Vertices(:,2),...		% query points y
				ELE_local,...										% elevation structure
				colno,...											% color numbers
				GV.legend_z_topside_bgd,...					% legend background z-value
				poly_legbgd,...									% legend background polygon
				'interp2');											% interpolation method
			if  mod(obj_reg.srftype(iobj),100)~=2
				obj_reg.zmax(iobj,1)	= max(z_margin);
			end
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Multimaterial prints:
	%------------------------------------------------------------------------------------------------------------------
	% - Nach "Cut into pieces" und "Delete objects that are too small":
	%   Dies sind die letzten Schritte, bei denen die Form der Polygone verändert wird.
	% - Vor der Berechnung von obj.z_bot(iobj):
	%   Die Teile-Höhen von nicht eigenständigen Farben können dann unterschiedlich sein.
	% - Die Mehrfarbendruck-Farben müssen hier aufgeteilt und am Ende dem Teil zugeordnet werden:
	%   1) das sie vollständig überlappen
	%   2) das von allen Teilen, die sie vollständig überlappen, die höchste Objektpriorität hat, also von oben zu sehen ist
	%   3) das selbst keine Mehrfarbendruck-Farbe ist
	
	if nargout>0
		
		% Alles nach Objektpriorität sortieren, außer die ersten beiden Elemente:
		if length(obj_reg.objprio)>=3
			[~,i_objprio]				= sort(obj_reg.objprio(3:end));
			obj_reg.poly(3:end)		= obj_reg.poly(i_objprio+2);
			obj_reg.colno(3:end)		= obj_reg.colno(i_objprio+2);
			obj_reg.dz(3:end)			= obj_reg.dz(i_objprio+2);
			obj_reg.zmax(3:end)		= obj_reg.zmax(i_objprio+2);
			obj_reg.objprio(3:end)	= obj_reg.objprio(i_objprio+2);
			obj_reg.colprio(3:end)	= obj_reg.colprio(i_objprio+2);
			obj_reg.srftype(3:end)	= obj_reg.srftype(i_objprio+2);
		end
		
		% Aufteilen der non-stand-alone Farben:
		iobj1_max				= length(obj_reg.poly);
		xlim_m					= [-1e10*ones(iobj1_max,1) 1e10*ones(iobj1_max,1)];
		ylim_m					= xlim_m;
		for iobj1=1:iobj1_max
			[xlim_m(iobj1,:),ylim_m(iobj1,:)]	= boundingbox(obj_reg.poly(iobj1));
		end
		for iobj1=iobj1_max:-1:3
			% iobj1 (higher priority):
			colno1					= obj_reg.colno(iobj1);
			icolspec1				= PP_local.color(colno1).spec;
			dxyoverhang1			= max(0,PP_local.colorspec(icolspec1).dxy_overhang);
			dbuffer1					= dxyoverhang1+PP_local.general.minbottomwidth_obj/2;
			if PP_local.color(colno1).standalone_color==0
				% The color 1 is printed non-stand-alone in one operation together with other colors.
				for iobj2=(iobj1-1):-1:2
					% iobj2 (lower priority):
					colno2					= obj_reg.colno(iobj2);
					icolspec2				= PP_local.color(colno2).spec;
					if iobj2==2
						% Color 1 is located directly above the tile base:
						% Cut Color 1 at the tile boundaries:
						
						for i_tile=1:imax_tile
							if numboundaries(poly_tile(i_tile))>0
								intersection0	= intersect(obj_reg.poly(iobj1),poly_tile(i_tile),...
									'KeepCollinearPoints',true);
								if numboundaries(intersection0)>0
									% The objects iobj1 and poly_tile(i_tile) intersect:
									% Add the intersection as extra object to obj_reg and clear the area from object iobj1:
									
									% Delete regions that are too small:
									intersection	= polybuffer(intersection0,-dbuffer1,'JointType','miter','MiterLimit',3);
									intersection	= polybuffer(intersection , dbuffer1,'JointType','miter','MiterLimit',3);
									% The polygon should not become larger as a result of the previous commands:
									obj_reg_poly_iobj1_0		= obj_reg.poly(iobj1);
									intersection				= intersect(obj_reg_poly_iobj1_0,intersection,...
										'KeepCollinearPoints',true);
									intersection_reg			= regions(intersection);
									for i_region=1:length(intersection_reg)
										obj_reg.poly			= [obj_reg.poly   ;intersection_reg(i_region)];
										obj_reg.colno			= [obj_reg.colno  ;obj_reg.colno(iobj1)  ];
										obj_reg.dz				= [obj_reg.dz     ;obj_reg.dz(iobj1)     ];
										obj_reg.zmax			= [obj_reg.zmax   ;obj_reg.zmax(iobj1)   ];
										obj_reg.objprio		= [obj_reg.objprio;obj_reg.objprio(iobj1)];
										obj_reg.colprio		= [obj_reg.colprio;obj_reg.colprio(iobj1)];
										obj_reg.srftype		= [obj_reg.srftype;obj_reg.srftype(iobj1)];
									end
									obj_reg.poly(iobj1)	= subtract(obj_reg.poly(iobj1),intersection0,...
										'KeepCollinearPoints',true);
									
									% Avoid thin stripes:
									obj_reg.poly(iobj1)	= polybuffer(obj_reg.poly(iobj1),-GV.tol_1,...
										'JointType','miter','MiterLimit',2);
									obj_reg.poly(iobj1)	= polybuffer(obj_reg.poly(iobj1),GV.tol_1,...
										'JointType','miter','MiterLimit',2);
									% The polygon should not become larger as a result of the previous commands:
									obj_reg.poly(iobj1)	= intersect(obj_reg_poly_iobj1_0,obj_reg.poly(iobj1),...
										'KeepCollinearPoints',true);
									
									% Termination condition for color 1:
									if numboundaries(obj_reg.poly(iobj1))==0
										% Color 1 has been completely divided among the colors below it:
										break
									end
									
								end
							end
						end
						
					else
						overlap_is_possible	= overlaps_boundingbox(GV.tol_1,...
							xlim_m(iobj1,1),...		% x1min
							xlim_m(iobj1,2),...		% x1max
							ylim_m(iobj1,1),...		% y1min
							ylim_m(iobj1,2),...		% y1max
							xlim_m(iobj2,1),...		% x2min
							xlim_m(iobj2,2),...		% x2max
							ylim_m(iobj2,1),...		% y2min
							ylim_m(iobj2,2));			% y2max
						if overlap_is_possible
							if overlaps(obj_reg.poly(iobj1),obj_reg.poly(iobj2))
								
								if PP_local.color(colno2).standalone_color==0
									% The color 2 is printed also non-stand-alone in one operation together with other colors:
									
									[  obj_reg.poly(iobj2),...					% poly1
										obj_reg.poly(iobj1),...					% poly2 (Subtrahend)
										~...											% dbuffer
										]=subtract_dside(...
										obj_reg.poly(iobj2),...					% poly1
										obj_reg.poly(iobj1),...					% poly2 (Subtrahend)
										PP_local,...								% PP_local
										colno1,...									% colno1
										colno2);										% colno2
									
									% % old:
									% % Two non-stand alone colors do not have to overlap:
									% d_side_1	= PP_local.colorspec(icolspec1).d_side;
									% if strcmp(GV.jointtype_bh,'miter')
									% 	obj_reg_poly_iobj1_pdside	= polybuffer(obj_reg.poly(iobj1),d_side_1,...
									% 		'JointType','Miter','MiterLimit',miterlimit);
									% else
									% 	obj_reg_poly_iobj1_pdside	= polybuffer(obj_reg.poly(iobj1),d_side_1,...
									% 		'JointType',GV.jointtype_bh);
									% end
									% obj_reg.poly(iobj2)	= subtract(obj_reg.poly(iobj2),obj_reg_poly_iobj1_pdside,...
									% 	'KeepCollinearPoints',true);
									
								else
									% The color 2 is printed stand-alone and serves as a basis for non-stand-alone colors:
									
									% Die Ränder der Löcher nach außen setzen:
									d_side_2		= [];
									miterlimit	= 2;
									if ~isequal(obj_reg.colprio(iobj2),colprio_base)
										d_side_2	= PP_local.colorspec(icolspec2).d_side;
										if strcmp(GV.jointtype_bh,'miter')
											obj_reg_poly_iobj2_pdside	= polybuffer(obj_reg.poly(iobj2),d_side_2,...
												'JointType','Miter','MiterLimit',miterlimit);
										else
											obj_reg_poly_iobj2_pdside	= polybuffer(obj_reg.poly(iobj2),d_side_2,...
												'JointType',GV.jointtype_bh);
										end
									else
										obj_reg_poly_iobj2_pdside	= obj_reg.poly(iobj2);
									end
									
									intersection0	= intersect(obj_reg.poly(iobj1),obj_reg.poly(iobj2),...
										'KeepCollinearPoints',true);
									if numboundaries(intersection0)>0
										% The objects iobj1 and iobj2 intersect:
										% Add the intersection as extra object to obj_reg and clear the area from object iobj1:
										
										% 								if (iobj1==456)&&(iobj2==2)
										% 									hf=figure(5789234);
										% 									clf(hf,'reset');
										% 									ha=gca;
										% 									hold(ha,'on');
										% 									axis(ha,'equal');
										% 									plot(ha,obj_reg.poly(iobj1));
										% 									plot(ha,obj_reg.poly(iobj2));
										% 									test1234=1
										% 								end
										
										% Delete regions that are too small:
										intersection	= polybuffer(intersection0,-dbuffer1,'JointType','miter','MiterLimit',3);
										intersection	= polybuffer(intersection, dbuffer1,'JointType','miter','MiterLimit',3);
										% The polygon should not become larger as a result of the previous commands:
										obj_reg_poly_iobj1_0		= obj_reg.poly(iobj1);
										intersection				= intersect(obj_reg_poly_iobj1_0,intersection,...
											'KeepCollinearPoints',true);
										intersection_reg			= regions(intersection);
										for i_region=1:length(intersection_reg)
											obj_reg.poly			= [obj_reg.poly   ;intersection_reg(i_region)];
											obj_reg.colno			= [obj_reg.colno  ;obj_reg.colno(iobj1)  ];
											obj_reg.dz				= [obj_reg.dz     ;obj_reg.dz(iobj1)     ];
											obj_reg.zmax			= [obj_reg.zmax   ;obj_reg.zmax(iobj1)   ];
											obj_reg.objprio		= [obj_reg.objprio;obj_reg.objprio(iobj1)];
											obj_reg.colprio		= [obj_reg.colprio;obj_reg.colprio(iobj1)];
											obj_reg.srftype		= [obj_reg.srftype;obj_reg.srftype(iobj1)];
										end
										obj_reg.poly(iobj1)	= subtract(obj_reg.poly(iobj1),obj_reg_poly_iobj2_pdside,...
											'KeepCollinearPoints',true);
										
										% Avoid thin stripes:
										if ~isempty(d_side_2)
											if (d_side_2<GV.tol_1)||~isequal(obj_reg.colprio(iobj2),colprio_base)
												obj_reg.poly(iobj1)	= polybuffer(obj_reg.poly(iobj1),-GV.tol_1,...
													'JointType','miter','MiterLimit',2);
												obj_reg.poly(iobj1)	= polybuffer(obj_reg.poly(iobj1),GV.tol_1,...
													'JointType','miter','MiterLimit',2);
											end
										end
										% The polygon should not become larger as a result of the previous commands:
										obj_reg.poly(iobj1)	= intersect(obj_reg_poly_iobj1_0,obj_reg.poly(iobj1),...
											'KeepCollinearPoints',true);
										
										% Termination condition for color 1:
										if numboundaries(obj_reg.poly(iobj1))==0
											% Color 1 has been completely divided among the colors below it:
											break
										end
										
									end
								end
							end
						end
					end
				end
			end
		end
		
		% Ab hier gilt:
		% obj_reg.poly(1:iobj1_max)			enthält die alten Polygone, non stand-alone Farben sind jetzt leer
		% obj_reg.poly((iobj1_max+1):end)	enthält die auf unterlagerte Farben aufgeteilten non stand-alone Farben
		%
		% Durch das Aufteilen ist der Vordergrund von z. B. Texten nicht mehr innerhalb des Hintergrunds:
		% Alle neuen Elemente ab dem Index iobj1_max durchsuchen nach überlappendem Vorder- und Hintergrund
		% und den Vordergrund beschneiden:
		if length(obj_reg.poly)>iobj1_max
			xlim_m					= [-1e10*ones(length(obj_reg.poly),1) 1e10*ones(length(obj_reg.poly),1)];
			ylim_m					= xlim_m;
			for iobj1=(iobj1_max+1):length(obj_reg.poly)
				[xlim_m(iobj1,:),ylim_m(iobj1,:)]	= boundingbox(obj_reg.poly(iobj1));
			end
			for iobj1=length(obj_reg.poly):-1:(iobj1_max+1)
				for iobj2=(iobj1-1):-1:1
					% iobj1: non stand-alone color
					% iobj2: stand-alone color
					
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						WAITBAR.t1		= clock;
						set(GV_H.text_waitbar,'String',sprintf(...
							'%s: topside triangulation: divide non-stand-alone colors: %g/%g %g/%g',msg,...
							iobj1,length(obj_reg.poly),...
							iobj2-(iobj1+1)+1,length(obj_reg.poly)-(iobj1+1)+1));
						drawnow;
					end
					
					% hf=4657484;
					% figure(hf);
					% clf(hf,'reset');
					% ha=axes;
					% hold(ha,'on');
					% axis(ha,'equal');
					% plot(ha,obj_reg.poly(iobj1));
					% plot(ha,obj_reg.poly(iobj1).Vertices(:,1),...
					% 	obj_reg.poly(iobj1).Vertices(:,2),'.k');
					% plot(ha,obj_reg.poly(iobj2));
					% title(ha,sprintf('iobj1=%g / iobj2=%g',iobj1,iobj2));
					% if ~isempty(testplot_xylimits)
					% 	set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
					% 	set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
					% else
					% 	set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
					% 	set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
					% end
					
					obj1_isbgd	= ((round(obj_reg.objprio(iobj1))-obj_reg.objprio(iobj1))>GV.tol_1);
					obj2_isbgd	= ((round(obj_reg.objprio(iobj2))-obj_reg.objprio(iobj2))>GV.tol_1);
					if    ( obj1_isbgd&&~obj2_isbgd)||...
							(~obj1_isbgd&& obj2_isbgd)
						% Es handelt sich um einen Vorder- und einen Hintergrund:
						overlap_is_possible	= overlaps_boundingbox(GV.tol_1,...
							xlim_m(iobj1,1),...		% x1min
							xlim_m(iobj1,2),...		% x1max
							ylim_m(iobj1,1),...		% y1min
							ylim_m(iobj1,2),...		% y1max
							xlim_m(iobj2,1),...		% x2min
							xlim_m(iobj2,2),...		% x2max
							ylim_m(iobj2,1),...		% y2min
							ylim_m(iobj2,2));			% y2max
						if overlap_is_possible
							if overlaps(obj_reg.poly(iobj1),obj_reg.poly(iobj2))
								if ~obj1_isbgd&&obj2_isbgd
									% Objekt 1 ist Vordergrund und Objekt 2 ist Hintergrund:
									poly_fgd					= obj_reg.poly(iobj1);
									poly_bgd					= obj_reg.poly(iobj2);
								else
									% Objekt 1 ist Hintergrund und Objekt 2 ist Vordergrund:
									poly_bgd					= obj_reg.poly(iobj1);
									poly_fgd					= obj_reg.poly(iobj2);
								end
								area_fgd					= area(poly_fgd);
								poly_intersect			= intersect(poly_fgd,poly_bgd);
								area_intersect			= area(poly_intersect);
								coverage_ratio			= 1-(area_fgd-area_intersect)/area_fgd;		% see also map2stl
								% The non-stand-alone color should clearly lie completely above a stand-alone color.
								% However, it may happen that, for example, a text foreground is not completely within
								% the text background and extends slightly beyond it.
								% The non-stand-alone part is therefore assigned to the color that has the highest
								% color priority and is covered by at least half of the part:
								if coverage_ratio>0.5
									% The foreground is inside the background:
									% The foreground must be inside the background with the distance GV.d_forebackgrd_plotobj.
									% By separating the non-stand-alone colors, the foreground and background are separated
									% on the same lines and therefore touch each other.
									poly_bgd_buff	= polybuffer(poly_bgd,...
										-GV.d_forebackgrd_plotobj,'JointType','miter','MiterLimit',2);
									poly_fgd			= intersect(poly_fgd,poly_bgd_buff,'KeepCollinearPoints',false);
									if ~obj1_isbgd&&obj2_isbgd
										% Objekt 1 ist Vordergrund und Objekt 2 ist Hintergrund:
										obj_reg.poly(iobj1)		= poly_fgd;
									else
										% Objekt 1 ist Hintergrund und Objekt 2 ist Vordergrund:
										obj_reg.poly(iobj2)		= poly_fgd;
									end
									% Mache weiter mit dem nächstkleineren Index iobj1:
									break
								end
							end
						end
					end
				end
			end
		end
		
		% Am Ende die Elemente nach innen verlagern und löschen wenn leer, Fehlermeldung wenn nicht leer.
		% Nur die Elemente bis zum vorherigen Index iobj1_max löschen.
		iobj1_delete_v	= false(iobj1_max,1);
		for iobj1=1:iobj1_max
			colno1					= obj_reg.colno(iobj1);
			if PP_local.color(colno1).standalone_color==0
				% iobj1: The color is printed non-stand-alone in one operation together with other colors.
				obj_reg_poly_iobj1_buff	= polybuffer(obj_reg.poly(iobj1),-GV.tol_1,'JointType','miter','MiterLimit',2);
				if numboundaries(obj_reg_poly_iobj1_buff)==0
					iobj1_delete_v(iobj1,1)		= true;
				else
					errormessage;
				end
			end
		end
		if any(iobj1_delete_v)
			obj_reg.poly(iobj1_delete_v)		= [];
			obj_reg.colno(iobj1_delete_v)		= [];
			obj_reg.dz(iobj1_delete_v)			= [];
			obj_reg.zmax(iobj1_delete_v)		= [];
			obj_reg.objprio(iobj1_delete_v)	= [];
			obj_reg.colprio(iobj1_delete_v)	= [];
			obj_reg.srftype(iobj1_delete_v)	= [];
		end
		
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% obj_reg
	%------------------------------------------------------------------------------------------------------------------
	% - Berechnung von obj.z_bot(iobj) und obj.zbotmax(iobj)
	%   Hier sollte auch nach Regionen unterschieden werden, damit die Löcher nicht unnötig tief sind, um Druckzeit
	%   und Material zu sparen: Jetzt jede Region einzeln betrachten (außer die Polygone mit der Grundfarbe).
	% - Wenn sich Objekte mit unterschiedlicher Objektpriorität aber gleicher Farbe überlappen, werden sie später
	%   verbunden. In diesem Fall muss für die Berechnung der Lochtiefe die negativere Höhe der beteiligten Objekte
	%   verwendet werden.
	% Ergebnis:		obj_reg.poly(iobj)
	%					obj_reg.colno(iobj)
	%					obj_reg.dz(iobj)
	%					obj_reg.z_bot(iobj)		Absenkung der Löcher für Teile anderer Farben gegenüber der Geländehöhe
	%													enthält bereits die Werte zmin und dz aller Teile oberhalb
	%													z_bot ist der ABSOLUTE z-Wert der Oberseite des unterhalb des
	%													Objekts iobj liegenden Teils.
	%													z_bot ist also um d_bottom kleiner als die Unterseite des Objekts iobj.
	%					obj_reg.zbotmax			Maximal zulässiger Wert z_bot (entspricht z_bot_above_min)
	%													Wenn die Unterseite dem Gelände folgt, darf die Unterseite nicht höher
	%													werden als die Unterseite der darüber einzusetzenden Teile
	%													(abzüglich dz und Abstände).
	%					obj_reg.zmin(iobj)		minimale Geländehöhe z auf der Fläche und dem Rand des Objekts (ohne dz)
	%					obj_reg.zmax(iobj)		maximale Geländehöhe z auf dem Rand des Objekts (ohne dz)
	%					obj_reg.objprio(iobj)
	%					obj_reg.colprio(iobj)
	%					obj_reg.srftype(iobj)
	
	if nargout>0
		
		% Alles nach Farbpriorität und dann nach Objektpriorität sortieren, außer die ersten beiden Elemente.
		% Die Objekte sind eindeutig nach Farbpriorität sortiert.
		% Nur bei gleicher Farbpriorität wird nach Objektpriorität sortiert.
		% Dies ist nötig in map2stl!
		if length(obj_reg.colprio)>=3
			diffuniq_colprio		= diff(unique(obj_reg.colprio(3:end)));
			if ~isempty(diffuniq_colprio)
				[~,i_colprio]		= sort(obj_reg.colprio(3:end) + ...
					min(diffuniq_colprio)*obj_reg.objprio(3:end)/(max(obj_reg.objprio(3:end))+1));
			else
				% There is only one color priority: Sort bei object priority:
				[~,i_colprio]		= sort(obj_reg.objprio(3:end)/(max(obj_reg.objprio(3:end))+1));
			end
			obj_reg.poly(3:end)		= obj_reg.poly(i_colprio+2);
			obj_reg.colno(3:end)		= obj_reg.colno(i_colprio+2);
			obj_reg.dz(3:end)			= obj_reg.dz(i_colprio+2);
			obj_reg.zmax(3:end)		= obj_reg.zmax(i_colprio+2);
			obj_reg.objprio(3:end)	= obj_reg.objprio(i_colprio+2);
			obj_reg.colprio(3:end)	= obj_reg.colprio(i_colprio+2);
			obj_reg.srftype(3:end)	= obj_reg.srftype(i_colprio+2);
		end
		
		% minimalen Wert der Geländehöhe z für jedes Objekt berechnen (obj_reg.zmin(iobj)):
		iobj_max		= length(obj_reg.poly);
		iobj_delete_v	= false(iobj_max,1);
		for iobj=1:iobj_max
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1		= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: min. Object height: %g/%g',msg,iobj,length(obj_reg.poly)));
				drawnow;
			end
			colno			= obj_reg.colno(iobj);
			ifs			= ELE_local.elecolor(colno,1).ifs;
			
			% min. z-Wert auf der Fläche der Topologie:
			% Versuch, die Unterscheidung ob Punkte sowohl innerhalb als auch außerhalb des Legendenhintergrunds liegen
			% hier durchzuführen: aber auch in map2stl_topside_triangulation (line 2724) gibt es diesen Fall:
			% Abfrage in interp_ele durchführen!
			% % 		zmin_area1	= 1e10;
			% % 		zmin_area2	= 1e10;
			% % 		inpoly		= inpolygon(...
			% % 			ELE_local.elefiltset(ifs,1).xm_mm,...								% query points
			% % 			ELE_local.elefiltset(ifs,1).ym_mm,...								% query points
			% % 			obj_reg.poly(iobj).Vertices(:,1),...		% edges of the polygon area
			% % 			obj_reg.poly(iobj).Vertices(:,2));			% edges of the polygon area
			% % 		if any(inpoly,'all')
			% % 			% Eigentlich sind alle Objekte entweder innerhalb oder außerhalb des Legendenhintergrunds.
			% % 			% Das gilt entsprechend auch für die Punkte
			% %			% (ELE_local.elefiltset(ifs,1).xm_mm(inpoly),ELE_local.elefiltset(ifs,1).ym_mm(inpoly)).
			% % 			% Nur die Stützpunkte innerhalb der Grundkachel bilden eine Ausnahme.
			% % 			% Die Grundkachel befindet sich an Position iobj=1 und iobj=2 in obj_reg.poly(iobj).
			% % 			ELE_local_xm_mm_inpoly		= ELE_local.elefiltset(ifs,1).xm_mm(inpoly);
			% % 			ELE_local_ym_mm_inpoly		= ELE_local.elefiltset(ifs,1).ym_mm(inpoly);
			% % 			if (iobj==1)||(iobj==2)
			% % 				inlegbgd		= inpolygon(...
			% % 					ELE_local_xm_mm_inpoly,...				% query points
			% % 					ELE_local_ym_mm_inpoly,...				% query points
			% % 					poly_legbgd.Vertices(:,1),...			% edges of the polygon area
			% % 					poly_legbgd.Vertices(:,2));			% edges of the polygon area
			% % 				% An die Funktion interp_ele sollen nur die Punkte außerhalb der Legende übergeben werden,
			% % 				% weil dort nur der 1. Stützpunkt auf innerhalb/außerhalb der Legende geprüft wird:
			% % 				ELE_local_xm_mm_inpoly	= ELE_local_xm_mm_inpoly(~inlegbgd);
			% % 				ELE_local_ym_mm_inpoly	= ELE_local_ym_mm_inpoly(~inlegbgd);
			% % 				if any(inlegbgd,'all')
			% % 					% There are points inside the legend background:
			% % 					zmin_area1					= GV.legend_z_topside_bgd;
			% % 				end
			% % 			end
			% % 			if ~isempty(ELE_local_xm_mm_inpoly)
			% % 				% There are points outside the legend background:
			% % 				zmin_area2	= min(interp_ele(...
			% % 					ELE_local_xm_mm_inpoly,...					% query points x
			% % 					ELE_local_ym_mm_inpoly,...					% query points y
			% % 					ELE_local,...									% elevation structure
			% % 					colno,...										% color numbers
			% % 					GV.legend_z_topside_bgd,...				% legend background z-value
			% % 					poly_legbgd,...								% legend background polygon
			% % 					'interp2'));									% interpolation method
			% % 			end
			% % 		end
			zmin_area	= 1e10;
			inpoly		= inpolygon(...
				ELE_local.elefiltset(ifs,1).xm_mm,...						% query points
				ELE_local.elefiltset(ifs,1).ym_mm,...						% query points
				obj_reg.poly(iobj).Vertices(:,1),...						% edges of the polygon area
				obj_reg.poly(iobj).Vertices(:,2));							% edges of the polygon area
			if any(inpoly,'all')
				zmin_area	= min(interp_ele(...
					ELE_local.elefiltset(ifs,1).xm_mm(inpoly),...		% query points x
					ELE_local.elefiltset(ifs,1).ym_mm(inpoly),...		% query points y
					ELE_local,...													% elevation structure
					colno,...														% color numbers
					GV.legend_z_topside_bgd,...								% legend background z-value
					poly_legbgd,...												% legend background polygon
					'interp2'));													% interpolation method
			end
			
			% min. z-Wert auf dem Rand der Topologie:
			% % 		% Die Randlinie der Grundkachel kann auch Teil des Legendenhintergrunds sein:
			% % 		% Vorgehensweise wie oben:
			% % 		zmin_margin1	= 1e10;
			% % 		zmin_margin2	= 1e10;
			% % 		obj_reg_poly_Vert_x		= obj_reg.poly(iobj).Vertices(:,1);
			% % 		obj_reg_poly_Vert_y		= obj_reg.poly(iobj).Vertices(:,2);
			% % 		if (iobj==1)||(iobj==2)
			% % 			inlegbgd		= inpolygon(...
			% % 				obj_reg_poly_Vert_x,...					% query points
			% % 				obj_reg_poly_Vert_y,...					% query points
			% % 				poly_legbgd.Vertices(:,1),...			% edges of the polygon area
			% % 				poly_legbgd.Vertices(:,2));			% edges of the polygon area
			% % 			% An die Funktion interp_ele sollen nur die Punkte außerhalb der Legende übergeben werden,
			% % 			% weil dort nur der 1. Stützpunkt auf innerhalb/außerhalb der Legende geprüft wird:
			% % 			obj_reg_poly_Vert_x	= obj_reg_poly_Vert_x(~inlegbgd);
			% % 			obj_reg_poly_Vert_y	= obj_reg_poly_Vert_y(~inlegbgd);
			% % 			if any(inlegbgd,'all')
			% % 				% There are points inside the legend background:
			% % 				zmin_margin1				= GV.legend_z_topside_bgd;
			% % 			end
			% % 		end
			% % 		if ~isempty(obj_reg_poly_Vert_x)
			% % 			zmin_margin2	= min(interp_ele(...
			% % 				obj_reg_poly_Vert_x,...							% query points x
			% % 				obj_reg_poly_Vert_y,...							% query points y
			% % 				ELE_local,...										% elevation structure
			% % 				colno,...											% color numbers
			% % 				GV.legend_z_topside_bgd,...					% legend background z-value
			% % 				poly_legbgd,...									% legend background polygon
			% % 				'interp2'));										% interpolation method
			% % 		end
			
			% Auflösung erhöhen:
			poly_incres		= changeresolution_poly(obj_reg.poly(iobj),...
				PP_local.general.dxy_ele_mm/4,...			% dmax
				[],...												% dmin
				[]);													% nmin
			z_margin		= interp_ele(...
				poly_incres.Vertices(:,1),...					% query points x
				poly_incres.Vertices(:,2),...					% query points y
				ELE_local,...										% elevation structure
				colno,...											% color numbers
				GV.legend_z_topside_bgd,...					% legend background z-value
				poly_legbgd,...									% legend background polygon
				'interp2',...										% interpolation method
				false);												% use scatteredInterpolant objects
			zmin_margin	= min(z_margin);
			
			% min. z-Wert über Rand und Fläche des Teils:
			if ~isempty(zmin_area)&&~isempty(zmin_margin)
				obj_reg.zmin(iobj,1)		= min(zmin_area,zmin_margin);
			else
				% Dies sollte nicht passieren, kommt aber vor, wenn obj_reg.poly(iobj) leer ist.
				iobj_delete_v(iobj,1)	= true;
			end
			
		end
		if any(iobj_delete_v)
			obj_reg.poly(iobj_delete_v)		= [];
			obj_reg.colno(iobj_delete_v)		= [];
			obj_reg.dz(iobj_delete_v)			= [];
			obj_reg.zmax(iobj_delete_v)		= [];
			obj_reg.objprio(iobj_delete_v)	= [];
			obj_reg.colprio(iobj_delete_v)	= [];
			obj_reg.srftype(iobj_delete_v)	= [];
		end
		
		
		% Wenn sich Objekte mit unterschiedlicher Objektpriorität aber gleicher Farbe überlappen, werden sie später
		% verbunden. In diesem Fall muss für die Berechnung der Lochtiefe die negativere Höhe der beteiligten Objekte
		% verwendet werden.
		% Zur Berechnung der Werte zmin und z_bot müssen die sich überlappenden Objekte tatsächlich verbunden werden.
		% Die Variable obj_reg_union_ovcol wird nur für diesen Zweck benötigt.
		obj_reg_union_ovcol	= obj_reg;	% obj_reg ist nach Farbpriorität sortiert, außer die ersten beiden Elemente!
		
		% % % % zdata zur Berechnung der Absenkung der Unterseiten:
		% % % for iobj=1:size(obj_reg_union_ovcol.poly,1)
		% % %
		% % % 	colno					= obj_reg_union_ovcol.colno(iobj);
		% % % 	ifs					= 1;											% query points of the tile base
		% % % 	% Stützstellen xy von obj_reg_union_ovcol.poly auf dem Rand und innerhalb:
		% % % 	TFin					= inpolygon(...							% faster than isinterior
		% % % 		ELE_local.elefiltset(ifs,1).xm_mm,...					% query points
		% % % 		ELE_local.elefiltset(ifs,1).ym_mm,...
		% % % 		obj_reg_union_ovcol.poly(iobj,1).Vertices(:,1),...	% polygon area
		% % % 		obj_reg_union_ovcol.poly(iobj,1).Vertices(:,2));
		% % % 	size_x				= size(ELE_local.elefiltset(ifs,1).xm_mm(TFin));
		% % % 	size_x_reshape		= [size_x(1)*size_x(2) 1];
		% % % 	xy						= [obj_reg_union_ovcol.poly(iobj,1).Vertices;[...
		% % % 		reshape(ELE_local.elefiltset(ifs,1).xm_mm(TFin),size_x_reshape) ...
		% % % 		reshape(ELE_local.elefiltset(ifs,1).ym_mm(TFin),size_x_reshape)]];
		% % % 	xy						= unique(xy,'rows');
		% % % 	[r_delete,~]		= find(isnan(xy));
		% % % 	r_delete				= unique(r_delete);
		% % % 	xy(r_delete,:)		= [];
		% % % 	% Höhen z der Oberseiten von obj_reg_union_ovcol.poly:
		% % % 	% Bemerkung:
		% % % 	% Die Unterscheidung nach "Die Oberfläche folgt dem Gelände" oder "Die Oberfläche ist eben" muss
		% % % 	% hier nicht vorgenommen werden, weil es hier auf die minimale Höhe eines Bereichs ankommt.
		% % % 	% Grund: Die Oberseite wird benötigt, um evtl. die Unterseite eines überlagerten Teils abzusenken,
		% % % 	% falls die Oberseite unterhalb der Geländehöhe verläuft.
		% % % 	% Bei "Die Oberfläche ist eben" wird aber die Höhe in dem gesamten Bereich auf zmax angehoben.
		% % % 	dz						= obj_reg_union_ovcol.dz(iobj,1);
		% % % 	xyz	=  [xy ...
		% % % 		dz+interp_ele(...
		% % % 		xy(:,1),...														% query points x
		% % % 		xy(:,2),...														% query points y
		% % % 		ELE_local,...													% elevation structure
		% % % 		colno,...														% color numbers
		% % % 		GV.legend_z_topside_bgd,...								% legend background z-value
		% % % 		poly_legbgd,...												% legend background polygon
		% % % 		'interp2')];													% interpolation method
		% % % 	obj_reg_union_ovcol.poly_top(iobj,1).ScInt			= scatteredInterpolant(xyz(:,1),xyz(:,2),xyz(:,3));
		% % % 	obj_reg_union_ovcol.poly_top(iobj,1).ScInt.Method					= 'linear';
		% % % 	obj_reg_union_ovcol.poly_top(iobj,1).ScInt.ExtrapolationMethod	= 'linear';
		% % %
		% % % end
		
		% Bounding box limits:
		xlim						= cell(size(obj_reg_union_ovcol.poly,1),1);
		ylim						= cell(size(obj_reg_union_ovcol.poly,1),1);
		for iobj1=1:size(obj_reg_union_ovcol.poly,1)
			[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_reg_union_ovcol.poly(iobj1));
		end
		iobj2_v					= -9999*ones(length(obj_reg_union_ovcol.poly),1);
		for iobj1=1:length(obj_reg_union_ovcol.poly)
			if size(xlim{iobj1,1},1)>0
				x1min				= xlim{iobj1,1}(1);
				x1max				= xlim{iobj1,1}(2);
				y1min				= ylim{iobj1,1}(1);
				y1max				= ylim{iobj1,1}(2);
				x1minmt			= x1min-tol_1;
				x1maxpt			= x1max+tol_1;
				y1minmt			= y1min-tol_1;
				y1maxpt			= y1max+tol_1;
				for iobj2=(iobj1+1):length(obj_reg_union_ovcol.poly)
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						WAITBAR.t1		= clock;
						set(GV_H.text_waitbar,'String',sprintf(...
							'%s: Object bottom height (1): %g/%g %g/%g',msg,...
							iobj1,length(obj_reg_union_ovcol.poly),...
							iobj2-(iobj1+1)+1,length(obj_reg_union_ovcol.poly)-(iobj1+1)+1));
						drawnow;
					end
					% % % if    isequal(obj_reg_union_ovcol.colprio(iobj1),obj_reg_union_ovcol.colprio(iobj2))   && ...
					% % % 		(abs(obj_reg_union_ovcol.zmin(iobj1,1)-obj_reg_union_ovcol.zmin(iobj2,1))>tol_1)
					% % % 	% Die Polygone haben gleiche Farben und unterschiedliche Werte zmin:
					if    isequal(obj_reg_union_ovcol.colprio(iobj1),obj_reg_union_ovcol.colprio(iobj2))
						% Die Polygone haben gleiche Farben:
						if size(xlim{iobj2,1},1)>0
							x2min				= xlim{iobj2,1}(1);
							x2max				= xlim{iobj2,1}(2);
							y2min				= ylim{iobj2,1}(1);
							y2max				= ylim{iobj2,1}(2);
							x2minmt			= x2min-tol_1;
							x2maxpt			= x2max+tol_1;
							y2minmt			= y2min-tol_1;
							y2maxpt			= y2max+tol_1;
							if (    (x2min>=(x1minmt))&&(x2min<=(x1maxpt))&&(y2min>=(y1minmt))&&(y2min<=(y1maxpt)) ) || ...	% Bottom left  corner of 2 is within 1
									( (x2max>=(x1minmt))&&(x2max<=(x1maxpt))&&(y2min>=(y1minmt))&&(y2min<=(y1maxpt)) ) || ...	% Bottom right corner of 2 is within 1
									( (x2max>=(x1minmt))&&(x2max<=(x1maxpt))&&(y2max>=(y1minmt))&&(y2max<=(y1maxpt)) ) || ...	% top    right corner of 2 is within 1
									( (x2min>=(x1minmt))&&(x2min<=(x1maxpt))&&(y2max>=(y1minmt))&&(y2max<=(y1maxpt)) ) || ...	% Upper  left  corner of 2 is within 1
									( (x1min>=(x2minmt))&&(x1min<=(x2maxpt))&&(y1min>=(y2minmt))&&(y1min<=(y2maxpt)) ) || ...	% bottom left  corner of 1 is within 2
									( (x1max>=(x2minmt))&&(x1max<=(x2maxpt))&&(y1min>=(y2minmt))&&(y1min<=(y2maxpt)) ) || ...	% bottom right corner of 1 is within 2
									( (x1max>=(x2minmt))&&(x1max<=(x2maxpt))&&(y1max>=(y2minmt))&&(y1max<=(y2maxpt)) ) || ...	% top    right corner of 1 is within 2
									( (x1min>=(x2minmt))&&(x1min<=(x2maxpt))&&(y1max>=(y2minmt))&&(y1max<=(y2maxpt)) ) || ...	% top    left  corner of 1 is within 2
									( (x2min>=(x1minmt))&&(x2max<=(x1maxpt))&&(y1min>=(y2minmt))&&(y1max<=(y2maxpt)) ) || ...	% All x-values of 2 are within of the x-values of 1 and all y-values of 1 are within the y-values of 2
									( (x1min>=(x2minmt))&&(x1max<=(x2maxpt))&&(y2min>=(y1minmt))&&(y2max<=(y1maxpt)) )			% All x-values of 1 are within of the x-values of 2 and all y-values of 2 are within the y values of 1
								% The polygons may overlap or touch:
								if overlaps(obj_reg_union_ovcol.poly(iobj1),obj_reg_union_ovcol.poly(iobj2))
									% The polygons overlap or touch:
									% dz zuweisen:
									% dz wird zur Berechnung von poly_top benötigt. Der Einfachheit halber wird hier nicht
									% unterschieden, in welchem Bereich dz am negativsten ist
									obj_reg_union_ovcol.dz(iobj2,1)		= ...
										min(obj_reg_union_ovcol.dz(iobj1,1),obj_reg_union_ovcol.dz(iobj2,1));
									% zmin zuweisen:
									obj_reg_union_ovcol.zmin(iobj2,1)		= ...
										min(obj_reg_union_ovcol.zmin(iobj1,1),obj_reg_union_ovcol.zmin(iobj2,1));
									% zmax zuweisen:
									obj_reg_union_ovcol.zmax(iobj2,1)		= ...
										max(obj_reg_union_ovcol.zmax(iobj1,1),obj_reg_union_ovcol.zmax(iobj2,1));
									% Die folgenden Felder enthalten keine sinnvollen Informationen mehr:
									obj_reg_union_ovcol.objprio(iobj2,1)	= -1;
									obj_reg_union_ovcol.srftype(iobj2,1)	= -1;
									% Objekte verbinden und Objekt 1 löschen:
									obj_reg_union_ovcol.poly(iobj2,1)		= ...
										union(obj_reg_union_ovcol.poly(iobj1,1),obj_reg_union_ovcol.poly(iobj2,1));
									obj_reg_union_ovcol.poly(iobj1,1)		= polyshape();
									iobj2_v(iobj1)									= iobj2;
									% xlim und xlim aktualisieren:
									[xlim{iobj1,1},ylim{iobj1,1}]				= boundingbox(obj_reg_union_ovcol.poly(iobj1));
									[xlim{iobj2,1},ylim{iobj2,1}]				= boundingbox(obj_reg_union_ovcol.poly(iobj2));
									% obj1 wurde gelöscht: weiter zur nächsten Nummer iobj1:
									break
								end
							end
						end
					end
				end
			end
		end
		
		% Save testdata for testing the function map2stl_preparation_zbot.m:
		save_testdata	= false;
		stop_here		= false;
		if ~isdeployed&&save_testdata
			C=who;
			save_command=sprintf('save(''%s''','C:\Daten\Projekte\MapLab3D_Ablage\temp1.mat');
			for iC=1:size(C,1)
				if    ~strcmp(C{iC,1},'GV_H')&&...
						~isequal(strfind(C{iC,1},'ha'),1)&&...
						~isequal(strfind(C{iC,1},'hc'),1)&&...
						~isequal(strfind(C{iC,1},'hf'),1)
					save_command=sprintf('%s,''%s''',save_command,C{iC,1});
				end
			end
			save_command=sprintf('%s);',save_command);
			eval(save_command);
			if stop_here
				display_on_gui('state','','notbusy');
				setbreakpoint=1;
			end
		end
		
		% Felder z_bot und zbotmax hinzufügen:
		% Die Höhe z der Unterseite der Druckteile ergibt sich aus
		% - der min. Objekthöhe obj_reg(iobj).dz und
		% - der max. Anzahl von Farben, die über genau diesem Objekt gestapelt werden und
		% - dem Abstand zwischen Druckteilen unterschiedlicher Farben (PP_local.colorspec(icolspec).d_bottom)
		% - der min. verbleibenden Stärke eines Druckteils (PP_local.colorspec(icolspec).min_thickness)
		obj_reg		= map2stl_preparation_zbot(...
			obj_reg,...
			obj_reg_union_ovcol,...
			ELE_local,...
			PP_local,...
			iobj2_v,...
			msg,...
			poly_legbgd,...
			prio_legbgd,...
			tol_1,...
			testout_dzbot,...
			testplot_obj_reg,...
			testplot_obj_reg_1plot,...
			testplot_xylimits);
		
	end
	
	% Polygon contour ordering: obj:
	obj.poly				= poly_contour_ordering(obj.poly);
	
	% Polygon contour ordering: obj_all_top:
	obj_all_top.poly	= poly_contour_ordering(obj_all_top.poly);
	
	% Polygon contour ordering: obj_top_reg:
	obj_top_reg.poly	= poly_contour_ordering(obj_top_reg.poly);
	
	% Polygon contour ordering: obj_reg:
	obj_reg.poly		= poly_contour_ordering(obj_reg.poly);
	
	% Testplots:
	if (testplot_obj_reg==1)&&(nargout>0)
		
		if ~isempty(testplot_xylimits)
			iobj_v			= 1;
			poly_xylimits	= polyshape(...
				[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
				[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
			for iobj=1:length(obj_reg.poly)
				if overlaps(obj_reg.poly(iobj),poly_xylimits)
					iobj_v	= [iobj_v;iobj];
				end
			end
			iobj_v	= unique(iobj_v);
			imax_obj	= length(iobj_v);
		else
			imax_obj	= length(obj_reg.poly);
			iobj_v	= (1:imax_obj)';
		end
		m_obj		= ceil(sqrt(imax_obj+1));
		n_obj		= ceil((imax_obj+1)/m_obj);
		hf			= figure(100160);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		set(hf,'Name','obj_reg');
		set(hf,'NumberTitle','off');
		
		for k=1:length(iobj_v)
			iobj	= iobj_v(k);
			ha=subplot(m_obj,n_obj,k);
			hold(ha,'on');
			axis(ha,'equal');
			plot(ha,obj_reg.poly(iobj),...
				'LineWidth',0.5,'LineStyle','-',...
				'EdgeColor','k','FaceColor',PP_local.color(obj_reg.colno(iobj)).rgb/255)
			if ~isempty(testplot_xylimits)
				set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
				set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
			else
				set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
				set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
			end
			title(sprintf('i=%g, dz=%g\nzb=%g, zbmax=%g\nzmin=%g, zmax=%g\ncp=%g, op=%g, st=%g',...
				iobj,obj_reg.dz(iobj),...
				obj_reg.z_bot(iobj),obj_reg.zbotmax(iobj),...
				obj_reg.zmin(iobj),obj_reg.zmax(iobj),...
				obj_reg.colprio(iobj),obj_reg.objprio(iobj),obj_reg.srftype(iobj)),...
				'Interpreter','none');
		end
		
		ha			= subplot(m_obj,n_obj,imax_obj+1);
		hold(ha,'on');
		axis(ha,'equal');
		imax_obj	= length(obj_reg.poly);
		for iobj=2:imax_obj
			plot(ha,obj_reg.poly(iobj),...
				'LineWidth',0.5,'LineStyle','-',...
				'EdgeColor','k','FaceColor',PP_local.color(obj_reg.colno(iobj)).rgb/255)
		end
		if ~isempty(testplot_xylimits)
			[x,y]		= boundary(poly_xylimits);
			plot(ha,x,y,'-r');
		end
		set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
		set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
		title(sprintf('i=2...%g',imax_obj),'Interpreter','none')
		
	end
	
	if testplot_obj_reg_1plot==1
		imax_obj=length(obj_reg.poly);
		hf=figure(100170);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		set(hf,'Name','obj_reg');
		set(hf,'NumberTitle','off');
		ha=axes(hf);
		hold(ha,'on');
		axis(ha,'equal');
		for iobj=2:imax_obj
			plot(ha,obj_reg.poly(iobj),...
				'LineWidth',0.5,'LineStyle','-',...
				'EdgeColor','k','FaceColor',PP_local.color(obj_reg.colno(iobj)).rgb/255)
		end
		if ~isempty(testplot_xylimits)
			poly_xylimits	= polyshape(...
				[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
				[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
			[x,y]				= boundary(poly_xylimits);
			plot(ha,x,y,'-r');
		end
		set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
		set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
		title(sprintf('i=2...%g',imax_obj),'Interpreter','none')
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Plausibilitätskontrolle
	%------------------------------------------------------------------------------------------------------------------
	% Alle verbleibenden Objekte zusammenfassen, Gesamtflächen berechnen und vergleichen:
	union_obj		= obj.poly(1);
	for iobj=2:length(obj.poly)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1		= clock;
			set(GV_H.text_waitbar,'String',sprintf(...
				'%s: Plausibility check: %g/%g',msg,iobj,length(obj.poly)));
			drawnow;
		end
		union_obj		= union(union_obj,obj.poly(iobj));
	end
	union_obj_all_top	= obj_all_top.poly(1);
	for iobj=2:length(obj_all_top.poly)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1		= clock;
			set(GV_H.text_waitbar,'String',sprintf(...
				'%s: Plausibility check: %g/%g',msg,iobj,length(obj_all_top.poly)));
			drawnow;
		end
		union_obj_all_top	= union(union_obj_all_top,obj_all_top.poly(iobj));
	end
	union_obj_top_reg	= obj_top_reg.poly(1);
	for iobj=2:length(obj_top_reg.poly)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1		= clock;
			set(GV_H.text_waitbar,'String',sprintf(...
				'%s: Plausibility check: %g/%g',msg,iobj,length(obj_top_reg.poly)));
			drawnow;
		end
		union_obj_top_reg	= union(union_obj_top_reg,obj_top_reg.poly(iobj));
	end
	area_obj_all_poly1	= area(obj_all.poly(1));
	area_union_obj			= area(union_obj);
	area_union_obj_all_top	= area(union_obj_all_top);
	area_union_obj_top_reg	= area(union_obj_top_reg);
	if ~isdeployed
		if    (abs(area_obj_all_poly1-area_union_obj        )>tol_2) || ...
				(abs(area_obj_all_poly1-area_union_obj_all_top)>tol_2) || ...
				(abs(area_obj_all_poly1-area_union_obj_top_reg)>tol_2) || ...
				(testout~=0)
			fprintf(1,'\n');
			fprintf(1,'area_obj_all_poly1	     = %g\n',area_obj_all_poly1);
			fprintf(1,'area_union_obj          = %g\n',area_union_obj);
			fprintf(1,'area_union_obj_all_top  = %g\n',area_union_obj_all_top);
			fprintf(1,'area_union_obj_top_reg  = %g\n',area_union_obj_top_reg);
			fprintf(1,'area_obj_all_poly1-area_union_obj         = %g\n',...
				area_obj_all_poly1-area_union_obj);
			fprintf(1,'area_obj_all_poly1-area_union_obj_all_top = %g\n',...
				area_obj_all_poly1-area_union_obj_all_top);
			fprintf(1,'area_obj_all_poly1-area_union_obj_top_reg = %g\n',...
				area_obj_all_poly1-area_union_obj_top_reg);
			if (testout==0)&&~isdeployed
				errormessage;
			end
		end
	end
	
catch ME
	errormessage('',ME);
end


%---------------------------------------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------------------------------------
% obj2objtop
%---------------------------------------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------------------------------------
function [obj_top,obj] = obj2objtop(obj,testout,testplot,testplot_xylimits,hf_num,...
	PP_local,outputname,xmin_mm,xmax_mm,ymin_mm,ymax_mm,msg)
% Berechnet von den Objekten/Polynomen obj nur den von oben sichtbaren Teil
% Vollständig leere Objekte/Polygone brauchen dann nicht mehr betrachtet und werden auch in obj gelöscht,
% falls es sich nicht um die Grundfläche handelt.
% Die Objekte obj müssen eindeutig nach Objektpriorität sortiert sein!
% Ergebnis:		obj_top.poly(iobj)
%					obj_top.colno(iobj)
%					obj_top.dz(iobj)
%					obj_top.zmax(iobj)
%					obj_top.objprio(iobj)
%					obj_top.colprio(iobj)
%					obj_top.srftype(iobj)

global GV GV_H WAITBAR

% Tolerance for plausibility questions
tol_2		= GV.tol_2;

obj_top						= obj;
obj_top_wnsc				= obj;
poly_iobj_gr_iobj1		= polyshape();		% all polygons iobj>iobj1 united
poly_iobj_gr_iobj1_wnsc	= polyshape();		% all polygons iobj>iobj1 united, without non stand-alone colors
iobjmax						= length(obj.poly);
for iobj1=(iobjmax-1):-1:1
	% Waitbar:
	if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
		WAITBAR.t1		= clock;
		set(GV_H.text_waitbar,'String',sprintf(...
			'%s: Object top side: %g/%g',msg,iobjmax-iobj1+1,iobjmax));
		drawnow;
	end
	poly_iobj_gr_iobj1	= union(poly_iobj_gr_iobj1,obj_top.poly(iobj1+1));
	obj_top.poly(iobj1)	= subtract(obj_top.poly(iobj1),poly_iobj_gr_iobj1);
	colno_iobj_gr_iobj1	= obj.colno(iobj1+1,1);
	if colno_iobj_gr_iobj1>0
		if PP_local.color(colno_iobj_gr_iobj1).standalone_color~=0
			% the object with the higher priority iobj1+1 is printed stand-alone:
			poly_iobj_gr_iobj1_wnsc		= union(poly_iobj_gr_iobj1_wnsc,obj_top_wnsc.poly(iobj1+1));
			obj_top_wnsc.poly(iobj1)	= subtract(obj_top_wnsc.poly(iobj1),poly_iobj_gr_iobj1_wnsc);
		end
	end
end

% Wenn ein Objekt vollständig verdeckt bzw. unsichtbar ist, kann es gelöscht werden.
% Ausnahmen:
% - Objekte, die als Träger von non-stand-alone-Farben dienen, sollen nicht gelöscht werden.
% - Objekte, die die Farbe der Kachelbasis haben, sollen nicht gelöscht werden.
%   Das soll verhindern, dass das erste oder die ersten beiden Elemente gelöscht werden.
% Delete empty objects in obj_top_wnsc:
iobj_delete		= false(size(obj_top_wnsc.poly,1),1);
for iobj=1:length(obj_top_wnsc.poly)
	if (numboundaries(obj_top_wnsc.poly(iobj))==0)&&(obj_top_wnsc.colprio(iobj)~=0)
		% Das Objekt ist von oben vollständig von stand-alone-Farben verdeckt
		% und hat nicht die Farbe der Kachelbasis: löschen
		iobj_delete(iobj)	= true;
	end
end
if any(iobj_delete)
	fn		= fieldnames(obj_top);
	for ifn=1:length(fn)
		obj.(fn{ifn})(iobj_delete)				= [];
		obj_top.(fn{ifn})(iobj_delete)		= [];
		obj_top_wnsc.(fn{ifn})(iobj_delete)	= [];
	end
end

% old:
% obj_top			= obj;
% obj_poly_buff	= obj;
% command			= '';
% iobjmax			= length(obj.poly);
% for iobj1=iobjmax:-1:1
% 	[xlim1,ylim1]		= boundingbox(obj.poly(iobj1));
% 	if size(xlim1,1)>0
% 		for iobj2=(iobj1+1):iobjmax
% 			% Waitbar:
% 			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
% 				WAITBAR.t1		= clock;
% 				set(GV_H.text_waitbar,'String',sprintf(...
% 					'%s: Object top side: %g/%g %g/%g',msg,iobjmax-iobj1+1,iobjmax,iobj2,iobjmax));
% 				drawnow;
% 			end
% 			[xlim2,ylim2]	= boundingbox(obj.poly(iobj2));
% 			if size(xlim2,1)>0
% 				if overlaps_boundingbox(GV.tol_1,...
% 						xlim1(1),xlim1(2),ylim1(1),ylim1(2),...
% 						xlim2(1),xlim2(2),ylim2(1),ylim2(2))
% 					if overlaps(obj.poly(iobj1),obj_poly_buff.poly(iobj2))
% 						% 		if isequal(tol_2,0)
% 						% 			obj_top_poly_iobj2_plustol2	= obj_top.poly(iobj2);
% 						% 		else
% 						% 			% Das zu subtrahierende Objekt wird vorher um tol_2 vergrößert,
% 						% 			% damit keine schmalen Linien übrig bleiben:
% 						% 			obj_top_poly_iobj2_plustol2	= polybuffer(obj_top.poly(iobj2),tol_2,'JointType','square');
% 						% 		end
% 						command_txt			= ...
% 							sprintf(...
% 							'obj_top.poly(%4.0f)	= subtract(obj_top.poly(%4.0f),obj_top.poly(%4.0f));\n',...
% 							iobj1,iobj1,iobj2);
% 						eval(command_txt);
% 						command				= sprintf('%s%s',command,command_txt);
% 						[xlim1,ylim1]		= boundingbox(obj.poly(iobj1));
% 					end
% 				end
% 			end
% 		end
% 	end
% 	% Only for check for overlap:
% 	if strcmp(GV.jointtype_bh,'miter')
% 		obj_poly_buff.poly(iobj1)	= polybuffer(obj_poly_buff.poly(iobj1),GV.tol_1,...
% 			'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
% 	else
% 		obj_poly_buff.poly(iobj1)	= polybuffer(obj_poly_buff.poly(iobj1),GV.tol_1,...
% 			'JointType',GV.jointtype_bh);
% 	end
% end

% old:
% obj_top	= obj;
% command	= '';
% iobjmax	= length(obj.poly);
% for iobj1=(iobjmax-1):-1:1
% 	for iobj2=(iobj1+1):iobjmax
% % 		if isequal(tol_2,0)
% % 			obj_top_poly_iobj2_plustol2	= obj_top.poly(iobj2);
% % 		else
% % 			% Das zu subtrahierende Objekt wird vorher um tol_2 vergrößert,
% % 			% damit keine schmalen Linien übrig bleiben:
% % 			obj_top_poly_iobj2_plustol2	= polybuffer(obj_top.poly(iobj2),tol_2,'JointType','square');
% % 		end
% 		command_txt	= ...
% 			sprintf(...
% 			'obj_top.poly(%4.0f)	= subtract(obj_top.poly(%4.0f),obj_top.poly(%4.0f));\n',...
% 			iobj1,iobj1,iobj2);
% 		eval(command_txt);
% 		command		= sprintf('%s%s',command,command_txt);
% 	end
% end

% Testausgaben:
if testout~=0
	fprintf(1,'\n%s\n',command);
end
if testplot==1
	
	for i_fig=0:1
		if i_fig==0
			obj_top_plot		= obj_top;
			outputname_ext		= '';
		else
			obj_top_plot		= obj_top_wnsc;
			outputname_ext		= '_wnsc';
		end
		
		if ~isempty(testplot_xylimits)
			iobj_v			= 1;
			poly_xylimits	= polyshape(...
				[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
				[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
			[xb_poly_xylimits,yb_poly_xylimits]		= boundary(poly_xylimits);
			for iobj=1:length(obj_top_plot.poly)
				if overlaps(obj_top_plot.poly(iobj),poly_xylimits)
					iobj_v	= [iobj_v;iobj];
				end
			end
			iobj_v	= unique(iobj_v);
			imax_obj	= length(iobj_v);
		else
			imax_obj	= length(obj_top_plot.poly);
			iobj_v	= (1:imax_obj)';
		end
		m_obj		= ceil(sqrt(imax_obj+1));
		n_obj		= ceil((imax_obj+1)/m_obj);
		hf=figure(hf_num+i_fig);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		set(hf,'Name',[outputname outputname_ext]);
		set(hf,'NumberTitle','off');
		
		for k=1:length(iobj_v)
			iobj	= iobj_v(k);
			ha=subplot(m_obj,n_obj,k);
			hold(ha,'on');
			axis(ha,'equal');
			if obj_top_plot.colno(iobj)==0
				plot(ha,obj_top_plot.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceAlpha',0)
				plot(ha,obj_top_plot.poly(iobj).Vertices(:,1),obj_top_plot.poly(iobj).Vertices(:,2),...
					'LineWidth',0.5,'LineStyle','none','Marker','.','MarkerSize',5,...
					'Color','k');
			else
				plot(ha,obj_top_plot.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',PP_local.color(obj_top_plot.colno(iobj)).rgb/255)
				plot(ha,obj_top_plot.poly(iobj).Vertices(:,1),obj_top_plot.poly(iobj).Vertices(:,2),...
					'LineWidth',0.5,'LineStyle','none','Marker','.','MarkerSize',5,...
					'Color','k');
			end
			if ~isempty(testplot_xylimits)
				plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
				set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
				set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
			else
				set(ha,'XLim',[xmin_mm xmax_mm]);
				set(ha,'YLim',[ymin_mm ymax_mm]);
			end
			title(sprintf('i=%g, dz=%g, zmax=%g\ncp=%g, op=%g, st=%g',...
				iobj,obj_top_plot.dz(iobj),obj_top_plot.zmax(iobj),...
				obj_top_plot.colprio(iobj),obj_top_plot.objprio(iobj),obj_top_plot.srftype(iobj)),...
				'Interpreter','none')
		end
		
		ha			= subplot(m_obj,n_obj,imax_obj+1);
		hold(ha,'on');
		axis(ha,'equal');
		imax_obj	= length(obj_top.poly);
		for iobj=1:imax_obj
			if obj_top.colno(iobj)==0
				plot(ha,obj_top.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceAlpha',0)
			else
				plot(ha,obj_top.poly(iobj),...
					'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',PP_local.color(obj_top.colno(iobj)).rgb/255)
			end
		end
		if ~isempty(testplot_xylimits)
			plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
		end
		set(ha,'XLim',[xmin_mm xmax_mm]);
		set(ha,'YLim',[ymin_mm ymax_mm]);
		title(sprintf('i=1...%g',imax_obj),'Interpreter','none')
		
	end
	
end

sumarea_obj_top			= 0;
subtract_obj_top			= obj.poly(1);
for iobj=1:length(obj_top.poly)
	% Waitbar:
	if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
		WAITBAR.t1		= clock;
		set(GV_H.text_waitbar,'String',sprintf(...
			'%s: Object top side: plausibility check %g/%g',msg,iobj,length(obj_top.poly)));
		drawnow;
	end
	sumarea_obj_top		= sumarea_obj_top+area(intersect(obj.poly(1),obj_top.poly(iobj)));
	subtract_obj_top		= subtract(subtract_obj_top,obj_top.poly(iobj));
end
area_subtract_obj_top				= area(subtract_obj_top);
area_obj_poly_iobj_colprio_base	= area(obj.poly(1));
if    (abs(area_obj_poly_iobj_colprio_base-sumarea_obj_top       )>tol_2) || ...
		(testout~=0)
	fprintf(1,'tol_2                        = %g\n',tol_2);
	fprintf(1,'sumarea_obj_top              = %g\n',sumarea_obj_top);
	fprintf(1,'area_subtract_obj_top        = %g   (=0!)\n',area_subtract_obj_top);
	fprintf(1,'area_obj_poly_iobj_colprio_base-sumarea_obj_top        = %g   (=0!)\n',...
		area_obj_poly_iobj_colprio_base-sumarea_obj_top);
	if (testout==0)&&~isdeployed
		errormessage;
	end
end


