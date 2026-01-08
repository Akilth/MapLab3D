function [T,iT_margin,obj_nextcolprio,obj_bot_bh_reg]=map2stl_topside_triangulation(...
	obj,obj_reg,colprio_base,PP_local,ELE_local,poly_legbgd,...
	xmin_mm,xmax_mm,ymin_mm,ymax_mm,...
	testout_topside,...
	testplot_obj_bot_reg_1plot,testplot_obj_bot_reg,testplot_obj_bot_bh_1plot,testplot_obj_bot_bh,...
	testplot_obj_bot_bh_reg_1plot,testplot_obj_bot_bh_reg,testplot_triang_hareas,...
	testplot_triang_top,testplot_obj_ncp,testplot_obj_ncp_1plot,testplot_xylimits,...
	currpart_i_tile,currpart_i_colprio,currpart_i_part,imax_part,msg)
% obj.poly(iobj)
% obj.colno(iobj)
% obj.dz(iobj)
% obj.objprio(iobj)
% obj.colprio(iobj)
% obj.srftype(iobj)

% % OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!! OK !!!
% % Fehlersuche in einem bestimmten Bereich der Karte:
% xmin		= -16;
% xmax		= 21;
% ymin		= -16;
% ymax		= 21;
% obj_test_str	= 'obj_bot_bh';	% obj_reg obj_bot_reg obj_bot_bh obj_bot_bh_reg
% eval(sprintf('obj_test	= %s;',obj_test_str));
% iobj_v	= [1];
% for iobj=1:length(obj_test.poly)
% 	[xlim,ylim] = boundingbox(obj_test.poly(iobj));
% 	if isempty(xlim)
% 		iobj_v	= [iobj_v;iobj];
% 	else
% 		if (xlim(1)>xmin)&&(xlim(2)<xmax)&&(ylim(1)>ymin)&&(ylim(2)<ymax)
% 			iobj_v	= [iobj_v;iobj];
% 		end
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
% 	if k==1
% 		set(ha,'XLim',[xmin_mm xmax_mm]);
% 		set(ha,'YLim',[ymin_mm ymax_mm]);
% 	else
% 		set(ha,'XLim',[xmin xmax]);
% 		set(ha,'YLim',[ymin ymax]);
% 	end
% 	title(sprintf('i=%g, cp=%g, st=%g\ndz=%g, dzb=%g, zmin=%1.4f, zmax=%1.4f',...
% 		iobj,obj_test.colprio(iobj),obj_test.srftype(iobj),...
% 		obj_test.dz(iobj),obj_test.z_bot(iobj),obj_test.zmin(iobj)),obj_test.zmax(iobj)),'Interpreter','none')
% end
% setbreakpoint	= 1;
% % FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!! FEHLER !!!

global GV GV_H WAITBAR PRINTDATA

% The try/catch block is in the calling function!

% Waitbar:
if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
	WAITBAR.t1	= clock;
	set(GV_H.text_waitbar,'String',sprintf('%s: topside triangulation',msg));
	drawnow;
end

% Tolerance for comparison of vertex coordinates:
tol_1		= GV.tol_1;
% Tolerance for plausibility questions
tol_2		= GV.tol_2;

if colprio_base>0
	test=1;
end
if (currpart_i_tile==1)&&(currpart_i_colprio==6)&&(currpart_i_part==5)
	test=1;
end

plot_color_v	= {...		% base colors without red [1 0 0], black [0 0 0], white [1 1 1], yellow [1 1 0]
	[0 1 0],...			% g
	[0 0 1],...			% b
	[1 0 1],...			% m
	[0 1 1],...			% c
	[0.5 1 0.5],...	% g2
	[0.5 0.5 1],...	% b2
	[0.5 0 0.5],...	% m2
	[0 0.5 0.5]};		% c2
plot_marker_v	= {...
	'o',...		% Circle
	'+',...		% Plus sign
	'x',...		% Cross
	's',...		% Square
	'd',...		% Diamond
	'^',...		% Upward-pointing triangle
	'v',...		% Downward-pointing triangle
	'>',...		% Right-pointing triangle
	'<'};		% Left-pointing triangle
% plot_marker_v	= {...
% 	'o',...		% Circle
% 	'+',...		% Plus sign
% 	'*',...		% Asterisk
% 	'.',...		% Point
% 	'x',...		% Cross
% 	'_',...		% Horizontal line
% 	'|',...		% Vertical line
% 	's',...		% Square
% 	'd',...		% Diamond
% 	'^',...		% Upward-pointing triangle
% 	'v',...		% Downward-pointing triangle
% 	'>',...		% Right-pointing triangle
% 	'<',...		% Left-pointing triangle
% 	'p',...		% Five-pointed star (pentagram)
% 	'h'};			% Six-pointed star (hexagram)

% ifs_tb: Index of the tile base filter settings in ELE_local.elefiltset.
color_prio_v		= [PP_local.color.prio];
icol_tilebase		= find(color_prio_v==0,1);
icolspec_tilebase	= PP_local.color(icol_tilebase,1).spec;		% should be =1
ifs_tb				= ELE_local.ifs_v(icolspec_tilebase,1);


%------------------------------------------------------------------------------------------------------------------
% obj_reg reduzieren
% nur Elemente behalten, die die Außenabmessungen überlappen: wesentlich schnellere Rechnung.
%------------------------------------------------------------------------------------------------------------------

% If i_part==imax_part: calculate obj_nextcolprio using the whole data!
if currpart_i_part~=imax_part
	obj_reg_red					= obj_reg;
	obj_poly1_ptol				= polybuffer(obj.poly(1),max(tol_1,tol_2),'JointType','miter'); % probably not necessary
	[xlim_base,ylim_base]	= boundingbox(obj_poly1_ptol);
	xmin_base					= xlim_base(1);
	xmax_base					= xlim_base(2);
	ymin_base					= ylim_base(1);
	ymax_base					= ylim_base(2);
	iobj_delete_v				= false(size(obj_reg_red.poly));
	for iobj=3:length(obj_reg_red.poly)
		[xlim_iobj,ylim_iobj]	= boundingbox(obj_reg_red.poly(iobj));
		xmin_iobj					= xlim_iobj(1);
		xmax_iobj					= xlim_iobj(2);
		ymin_iobj					= ylim_iobj(1);
		ymax_iobj					= ylim_iobj(2);
		if xmax_iobj<xmin_base
			iobj_delete_v(iobj)	= true;
		else
			if xmin_iobj>xmax_base
				iobj_delete_v(iobj)	= true;
			else
				if ymax_iobj<ymin_base
					iobj_delete_v(iobj)	= true;
				else
					if ymin_iobj>ymax_base
						iobj_delete_v(iobj)	= true;
					else
						if ~overlaps(obj_reg_red.poly(iobj),obj_poly1_ptol)
							iobj_delete_v(iobj)	= true;
						end
					end
				end
			end
		end
	end
	obj_reg_red.poly(iobj_delete_v)		= [];
	obj_reg_red.colno(iobj_delete_v)		= [];
	obj_reg_red.dz(iobj_delete_v)			= [];
	obj_reg_red.z_bot(iobj_delete_v)		= [];
	obj_reg_red.zbotmax(iobj_delete_v)	= [];
	obj_reg_red.zmin(iobj_delete_v)		= [];
	obj_reg_red.zmax(iobj_delete_v)		= [];
	obj_reg_red.objprio(iobj_delete_v)	= [];
	obj_reg_red.colprio(iobj_delete_v)	= [];
	obj_reg_red.srftype(iobj_delete_v)	= [];
	obj_reg										= obj_reg_red;
end


%------------------------------------------------------------------------------------------------------------------
% obj_bot_reg
%------------------------------------------------------------------------------------------------------------------
% Unterseite der oberhalb des aktuellen Teils liegenden Teile anderer Farben:
% Die Unterseiten der Teile sollen so wenig verwinkelt sein wie möglich ==>
% Die Unterseiten sollen der ursprünglichen Form entsprechen, außer das Objekt gibt es nicht mehr.
% Hierzu werden sich überlappende Objekte obj_reg einer Farbe verundet, wenn das Objekt in obj_top noch
% vorhanden ist.
% Ergebnis:		obj_bot_reg.poly(iobj)
%					obj_bot_reg.colno(iobj)
%					obj_bot_reg.dz(iobj)
%					obj_bot_reg.z_bot(iobj)
%					obj_bot_reg.zbotmax(iobj)
%					obj_bot_reg.zmin(iobj)
%					obj_bot_reg.zmax(iobj)
%					obj_bot_reg.colprio(iobj)
%					obj_bot_reg.srftype(iobj)
% Hinweise:	-	obj_reg.colprio(iobj)==colprio_base  -->	obj_bot_reg.dz(iobj) = obj_reg.dz(iobj)
%					obj_reg.colprio(iobj)~=colprio_base  -->	obj_bot_reg.dz(iobj) = obj_reg.z_bot(iobj)
%																			dz ist damit wie z_bot der ABSOLUTE z-Wert der Unterseite
%				-	Wenn Objekte zur Unterseite gehören, sind die Werte in srftype wegen der Verundung 
%					nicht mehr gültig!

% Änderung der Geländehöhe dz zuweisen:
% obj_reg.colprio(iobj)==colprio_base:  vorgegebenen Wert dz übernehmen
% obj_reg.colprio(iobj)> colprio_base:  Objekte mit höherer Farbpriorität bilden Löcher in der Grundfarbe:
%                                       dz der Grundfarbe ist gleich z_bot (Unterseite) des höherliegenden Teils
obj_bot_reg.poly					= obj_reg.poly;
obj_bot_reg.colno					= obj_reg.colno;
for iobj=1:length(obj_reg.poly)
	if obj_reg.colprio(iobj)==colprio_base
		obj_bot_reg.dz(iobj,1)	= obj_reg.dz(iobj);
	else
		obj_bot_reg.dz(iobj,1)	= obj_reg.z_bot(iobj);
	end
end
obj_bot_reg.z_bot					= obj_reg.z_bot;
obj_bot_reg.zbotmax				= obj_reg.zbotmax;
obj_bot_reg.zmin					= obj_reg.zmin;
obj_bot_reg.zmax					= obj_reg.zmax;
obj_bot_reg.colprio				= obj_reg.colprio;
obj_bot_reg.srftype				= obj_reg.srftype;
obj_bot_reg.objprio				= obj_reg.objprio;		% Dieses Feld wird in obj_bot_reg wieder entfernt!
command								= '';

% Nach der folgenden Rechnung sollen außer der Grundfarbe colprio_base nur noch die Objekte übrig bleiben,
% die direkt oberhalb der Grundfarbe eingesetzt werden.

% Wenn es Objekte mit einer Farbe <=colprio_base, aber einer höheren Objektpriorität gibt, sollen diese durch
% die nächsthöhere Farbe hinduch ragen und müssen entsprechend subtrahiert werden:
xlim							= cell(size(obj_bot_reg.poly,1),1);
ylim							= cell(size(obj_bot_reg.poly,1),1);
for iobj1=1:size(obj_bot_reg.poly,1)
	[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_reg.poly(iobj1));
end
for iobj1=2:length(obj_bot_reg.poly)
	% Waitbar:
	if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
		WAITBAR.t1		= clock;
		set(GV_H.text_waitbar,'String',sprintf(...
			'%s: topside triangulation: prepare areas with base color priority: %g/%g',msg,...
			iobj1,length(obj_bot_reg.poly)));
		drawnow;
	end
	if size(xlim{iobj1,1},1)>0
		for iobj2=1:length(obj_bot_reg.poly)
			if size(xlim{iobj2,1},1)>0
				if overlaps_boundingbox(tol_1,...
					xlim{iobj1,1}(1),...		% x1min
					xlim{iobj1,1}(2),...		% x1max
					ylim{iobj1,1}(1),...		% y1min
					ylim{iobj1,1}(2),...		% y1max
					xlim{iobj2,1}(1),...		% x2min
					xlim{iobj2,1}(2),...		% x2max
					ylim{iobj2,1}(1),...		% y2min
					ylim{iobj2,1}(2))			% y2max
					% The polygons may overlap or touch:
					if    (obj_bot_reg.colprio(iobj1)> colprio_base)        && ...		% Objekt 1: colprio >  colprio_base
							(obj_bot_reg.colprio(iobj2)<=colprio_base)        && ...		% Objekt 2: colprio <= colprio_base
							(obj_reg.objprio(iobj2)>obj_reg.objprio(iobj1))   && ...
							(numboundaries(obj_bot_reg.poly(iobj1))>0)        && ...
							(numboundaries(obj_bot_reg.poly(iobj2))>0)
						command_txt	= ...
							sprintf('obj_bot_reg.poly(%4.0f)	= subtract(obj_bot_reg.poly(%4.0f),obj_bot_reg.poly(%4.0f));\n',...
							iobj1,iobj1,iobj2);
						eval(command_txt);
						if testout_topside~=0
							command		= sprintf('%s%s',command,command_txt);
						end
						[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_reg.poly(iobj1));
					end
				end
			end
		end
	end
end
if testout_topside~=0
	command		= sprintf('%s\n',command);
end

% Wenn sich Objekte einer Farbe >colprio_base überlappen:
% zusammenfassen (union), die Absenkung dz ist gleich dem negativsten Wert dz der beiden Objekte, zmin entspr.
% Alle Objekte nach Farben zusammenfassen
% (außer die Grundfarbe, da hier die Details auf der Oberseite erhalten bleiben müssen):
empty_poly					= polyshape([1 2 2 1],[1 1 2 2]);
empty_poly.Vertices		= zeros(0,2);
% % % xlim							= cell(size(obj_bot_reg.poly,1),1);
% % % ylim							= cell(size(obj_bot_reg.poly,1),1);
% % % for iobj1=1:size(obj_bot_reg.poly,1)
% % % 	[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_reg.poly(iobj1));
% % % end
obj_bot_reg_poly_ptol				= obj_bot_reg.poly;
obj_bot_reg_poly_mtol				= obj_bot_reg.poly;
for iobj1=2:length(obj_bot_reg.poly)
	obj_bot_reg_poly_ptol(iobj1)		= polybuffer(obj_bot_reg.poly(iobj1), tol_1,'JointType','miter');
	obj_bot_reg_poly_mtol(iobj1)		= polybuffer(obj_bot_reg.poly(iobj1),-tol_1,'JointType','miter');
end
for iobj1=2:length(obj_bot_reg.poly)
	colno1					= obj_bot_reg.colno(iobj1);
	if    (obj_bot_reg.colprio(iobj1)>colprio_base) &&...
			(numboundaries(obj_bot_reg.poly(iobj1))>0)
		for iobj2=(iobj1+1):length(obj_bot_reg.poly)
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1		= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: topside triangulation: prepare areas with higher color priority: %g/%g %g/%g',msg,...
					iobj1,length(obj_bot_reg.poly),...
					iobj2-(iobj1+1)+1,length(obj_bot_reg.poly)-(iobj1+1)+1));
				drawnow;
			end
			if    (obj_bot_reg.colprio(iobj2)>colprio_base)&&...
					(numboundaries(obj_bot_reg.poly(iobj2))>0)
				if    isequal(obj_bot_reg.colprio(iobj1),obj_bot_reg.colprio(iobj2))&&...
						~isequal(iobj1,iobj2)
					% Es handelt sich um unterschiedliche, nicht leere Objekte mit gleichen Farben,
					% die nicht gleich der Grundfarbe ist:
					
					% Objekte vereinen:
					% 1) wenn sie aus einer stand-alone Farbe bestehen ODER
					% 2) wenn sie nicht aus einer stand-alone Farbe bestehen:
					%    - wenn es sich um eine Vordergrundfläche handelt, die sich vollständig innerhalb einer
					%      Hintergrundfläche befindet.
					%    - wenn beide direkt neben- oder übereinander auf dieselbe unterhalb liegende Farbe gedruckt
					%      werden. Beispiel: Symbol, text and connection line.
					obj1_isbgd	= ((round(obj_bot_reg.objprio(iobj1))-obj_bot_reg.objprio(iobj1))>tol_1);
					obj2_isbgd	= ((round(obj_bot_reg.objprio(iobj2))-obj_bot_reg.objprio(iobj2))>tol_1);
					if size(xlim{iobj1,1},1)>0
						if size(xlim{iobj2,1},1)>0
							if overlaps_boundingbox(tol_1,...
								xlim{iobj1,1}(1),...		% x1min
								xlim{iobj1,1}(2),...		% x1max
								ylim{iobj1,1}(1),...		% y1min
								ylim{iobj1,1}(2),...		% y1max
								xlim{iobj2,1}(1),...		% x2min
								xlim{iobj2,1}(2),...		% x2max
								ylim{iobj2,1}(1),...		% y2min
								ylim{iobj2,1}(2))			% y2max
								% The polygons may overlap or touch:
								
								unite_obj1_obj2		= false;
								objprio_iobj2_new		= [];
								if (PP_local.color(colno1).standalone_color~=0)
									% Normally, if the color is stand-alone, unite the objects if they overlap:
									unite_obj1_obj2	= overlaps(obj_bot_reg.poly(iobj1),obj_bot_reg.poly(iobj2));
								else
									% If the color is non-stand-alone:
									% 1) Unite the objects if the foreground is inside the background:
									if 	( obj1_isbgd&&~obj2_isbgd)||...
											(~obj1_isbgd&& obj2_isbgd)
										if ~obj1_isbgd&&obj2_isbgd
											% Objekt 1 ist Vordergrund und Objekt 2 ist Hintergrund:
											poly_fgd					= obj_bot_reg.poly(iobj1);
											poly_bgd					= obj_bot_reg.poly(iobj2);
											objprio_iobj2_new		= obj_bot_reg.objprio(iobj2);
										elseif obj1_isbgd&&~obj2_isbgd
											% Objekt 1 ist Hintergrund und Objekt 2 ist Vordergrund:
											poly_bgd					= obj_bot_reg.poly(iobj1);
											poly_fgd					= obj_bot_reg.poly(iobj2);
											objprio_iobj2_new		= obj_bot_reg.objprio(iobj1);
										end
										area_fgd				= area(poly_fgd);
										poly_intersect		= intersect(poly_fgd,poly_bgd);
										area_intersect		= area(poly_intersect);
										if abs((area_fgd-area_intersect)/area_intersect)<tol_1
											% The foreground is inside the background:
											unite_obj1_obj2		= true;
										end
									end
									% 2) Die Objekte vereinen, wenn beide direkt neben- oder übereinander auf dieselbe 
									%    unterhalb liegende Farbe gedruckt werden:
									% Zur Erinnerung: Die Objekte sind eindeutig nach Farbpriorität sortiert.
									% Nur bei gleicher Farbpriorität wird nach Objektpriorität sortiert.
									if ~unite_obj1_obj2
										if overlaps(obj_bot_reg_poly_ptol(iobj1),obj_bot_reg.poly(iobj2))
											% The objects 1 and 2 overlap or touch:
											% Find the object below object 1:
											% 1) that is stand-alone and
											% 2) with the highest color priority
											iobj3_overlap_with_iobj1		= 0;
											for iobj3=(iobj1-1):-1:2
												if size(xlim{iobj3,1},1)>0
													colno3					= obj_bot_reg.colno(iobj3);
													if PP_local.color(colno3).standalone_color~=0
														if overlaps_boundingbox(tol_1,...
																xlim{iobj1,1}(1),...		% x1min
																xlim{iobj1,1}(2),...		% x1max
																ylim{iobj1,1}(1),...		% y1min
																ylim{iobj1,1}(2),...		% y1max
																xlim{iobj3,1}(1),...		% x2min
																xlim{iobj3,1}(2),...		% x2max
																ylim{iobj3,1}(1),...		% y2min
																ylim{iobj3,1}(2))			% y2max
															% The objects 1 and 3 may overlap or touch:
															if overlaps(obj_bot_reg_poly_mtol(iobj1),obj_bot_reg.poly(iobj3))
																% The objects 1 and 3 overlap (and do not only touch):
																iobj3_overlap_with_iobj1		= iobj3;
																break
															end
														end
													end
												end
											end
											% Find the object below object 2:
											% 1) that is stand-alone and
											% 2) with the highest color priority
											iobj3_overlap_with_iobj2		= 0;
											for iobj3=(iobj1-1):-1:2
												if size(xlim{iobj3,1},1)>0
													colno3					= obj_bot_reg.colno(iobj3);
													if PP_local.color(colno3).standalone_color~=0
														if overlaps_boundingbox(tol_1,...
																xlim{iobj2,1}(1),...		% x1min
																xlim{iobj2,1}(2),...		% x1max
																ylim{iobj2,1}(1),...		% y1min
																ylim{iobj2,1}(2),...		% y1max
																xlim{iobj3,1}(1),...		% x2min
																xlim{iobj3,1}(2),...		% x2max
																ylim{iobj3,1}(1),...		% y2min
																ylim{iobj3,1}(2))			% y2max
															% The objects 2 and 3 may overlap or touch:
															if overlaps(obj_bot_reg_poly_mtol(iobj2),obj_bot_reg.poly(iobj3))
																% The objects 2 and 3 overlap (and do not only touch):
																iobj3_overlap_with_iobj2		= iobj3;
																break
															end
														end
													end
												end
											end
											if    (iobj3_overlap_with_iobj1==iobj3_overlap_with_iobj2)&&...
													(iobj3_overlap_with_iobj1~=0)
												% The objects 1, 2 (non-stand-alone) overlap the same object 3 (stand-alone).
												% Because non-stand-alone objects overlap only one stand-alone object directly
												% below, the objects 1 and 2 both overlap completely the same object 3.
												% Unite them:
												% Example: Symbol, text and connection line should be united,
												%          otherwise the connection line will cut through the symbol.
												unite_obj1_obj2		= true;
											end
										end
									end
								end
								
								if unite_obj1_obj2
									
									% Wenn PP_local.color(colno1).standalone_color==0 (keine stand-alone-Farbe):
									% Nach dem Vereinen wird das Objekt 1 gelöscht, dann geht auch die Information
									% verloren, welches der Objekte Vordergrund und welches Hintergrund war.
									if (PP_local.color(colno1).standalone_color==0)&&~isempty(objprio_iobj2_new)
										% Es werden ein zusammengehörender Vorder- und Hintergrund verbunden:
										% Object 2 soll nicht noch einmal verbunden werden: als Hintergrund deklarieren:
										obj_bot_reg.objprio(iobj2)		= objprio_iobj2_new;
									end
									
									% Polygone verbinden:
									command_txt	= ...
										sprintf('obj_bot_reg.poly(%4.0f) = union(   obj_bot_reg.poly(%4.0f),obj_bot_reg.poly(%4.0f) );\n',...
										iobj2,iobj1,iobj2);
									eval(command_txt);
									if testout_topside~=0
										command		= sprintf('%s%s',command,command_txt);
									end
									% resultierende Werte dz und zmin: jeweils der negativere Wert:
									
									command_txt	= ...
										sprintf('obj_bot_reg.dz(%6.0f) = min(    [obj_bot_reg.dz(%6.0f) obj_bot_reg.dz(%6.0f)]);\n',...
										iobj2,iobj1,iobj2);
									eval(command_txt);
									if testout_topside~=0
										command		= sprintf('%s%s',command,command_txt);
									end
									
									command_txt	= ...
										sprintf('obj_bot_reg.z_bot(%6.0f) = min(    [obj_bot_reg.z_bot(%6.0f) obj_bot_reg.z_bot(%6.0f)]);\n',...
										iobj2,iobj1,iobj2);
									eval(command_txt);
									if testout_topside~=0
										command		= sprintf('%s%s',command,command_txt);
									end
									
									command_txt	= ...
										sprintf('obj_bot_reg.zbotmax(%6.0f) = min(    [obj_bot_reg.zbotmax(%6.0f) obj_bot_reg.zbotmax(%6.0f)]);\n',...
										iobj2,iobj1,iobj2);
									eval(command_txt);
									if testout_topside~=0
										command		= sprintf('%s%s',command,command_txt);
									end
									
									command_txt	= ...
										sprintf('obj_bot_reg.zmin(%4.0f) = min(    [obj_bot_reg.zmin(%4.0f) obj_bot_reg.zmin(%4.0f)]);\n',...
										iobj2,iobj1,iobj2);
									eval(command_txt);
									if testout_topside~=0
										command		= sprintf('%s%s',command,command_txt);
									end
									
									% Polygon iobj1 löschen:
									command_txt	= sprintf('obj_bot_reg.poly(%4.0f) = empty_poly;\n',iobj1);
									eval(command_txt);
									if testout_topside~=0
										command		= sprintf('%s%s',command,command_txt);
									end
									obj_bot_reg_poly_ptol(iobj1)	= empty_poly;
									obj_bot_reg_poly_mtol(iobj1)	= empty_poly;
									
									% xlim und xlim aktualisieren:
									[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_reg.poly(iobj1));
									[xlim{iobj2,1},ylim{iobj2,1}]	= boundingbox(obj_bot_reg.poly(iobj2));
									obj_bot_reg_poly_ptol(iobj2)	= polybuffer(obj_bot_reg.poly(iobj2), tol_1,'JointType','miter');
									obj_bot_reg_poly_mtol(iobj2)	= polybuffer(obj_bot_reg.poly(iobj2),-tol_1,'JointType','miter');
									
									% obj1 wurde gelöscht: weiter zur nächsten Nummer iobj1:
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
% Feld objprio enthält keine sinnvollen Informationen mehr: entfernen:
obj_bot_reg		= rmfield(obj_bot_reg,'objprio');
if testout_topside~=0
	command		= sprintf('%s\n',command);
end

% Flächen löschen, die nicht auf der Unterseite der Objekte vorkommen:
for iobj1=2:size(obj_bot_reg.poly,1)
	[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_reg.poly(iobj1));
	for iobj2=(iobj1-1):-1:1
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1		= clock;
			set(GV_H.text_waitbar,'String',sprintf(...
				'%s: topside triangulation: delete irrelevant areas: %g/%g %g/%g',msg,...
				iobj1,size(obj_bot_reg.poly,1),...
				(iobj1-1)-iobj2+1,(iobj1-1)));
			drawnow;
		end
		if    (obj_bot_reg.colprio(iobj1)>colprio_base) && ...
				(obj_bot_reg.colprio(iobj2)>colprio_base)
			if size(xlim{iobj1,1},1)>0
				if size(xlim{iobj2,1},1)>0
					if overlaps_boundingbox(tol_1,...
						xlim{iobj1,1}(1),...		% x1min
						xlim{iobj1,1}(2),...		% x1max
						ylim{iobj1,1}(1),...		% y1min
						ylim{iobj1,1}(2),...		% y1max
						xlim{iobj2,1}(1),...		% x2min
						xlim{iobj2,1}(2),...		% x2max
						ylim{iobj2,1}(1),...		% y2min
						ylim{iobj2,1}(2))			% y2max
						% The polygons may overlap or touch:
						command_txt	= ...
							sprintf('obj_bot_reg.poly(%4.0f)	= subtract(obj_bot_reg.poly(%4.0f),obj_bot_reg.poly(%4.0f));\n',...
							iobj1,iobj1,iobj2);
						eval(command_txt);																										% 23%
						if testout_topside~=0
							command		= sprintf('%s%s',command,command_txt);
						end
						[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_reg.poly(iobj1));
					end
				end
			end
		end
	end
end
if testout_topside~=0
	command		= sprintf('%s\n',command);
end
if (currpart_i_tile==1)&&(currpart_i_colprio==4)
	test=1;
end

% Auch in der Grundfarbe soll es keine überlappenden Objekte mehr geben:
% xlim und ylim liegen bereits aus dem oberen Abschnitt vor.
for iobj1=2:size(obj_bot_reg.poly,1)
	for iobj2=(iobj1+1):size(obj_bot_reg.poly,1)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1		= clock;
			set(GV_H.text_waitbar,'String',sprintf(...
				'%s: topside triangulation: delete irrelevant areas, base color: %g/%g %g/%g',msg,...
				iobj1,size(obj_bot_reg.poly,1),...
				iobj2-(iobj1+1)+1,size(obj_bot_reg.poly,1)-(iobj1+1)+1));
			drawnow;
		end
		if isequal(obj_bot_reg.colprio(iobj1),colprio_base)
			if size(xlim{iobj1,1},1)>0
				if size(xlim{iobj2,1},1)>0
					if overlaps_boundingbox(tol_1,...
						xlim{iobj1,1}(1),...		% x1min
						xlim{iobj1,1}(2),...		% x1max
						ylim{iobj1,1}(1),...		% y1min
						ylim{iobj1,1}(2),...		% y1max
						xlim{iobj2,1}(1),...		% x2min
						xlim{iobj2,1}(2),...		% x2max
						ylim{iobj2,1}(1),...		% y2min
						ylim{iobj2,1}(2))			% y2max
						% The polygons may overlap or touch:
						command_txt	= ...
							sprintf('obj_bot_reg.poly(%4.0f)	= subtract(obj_bot_reg.poly(%4.0f),obj_bot_reg.poly(%4.0f));\n',...
							iobj1,iobj1,iobj2);
						eval(command_txt);
						if testout_topside~=0
							command		= sprintf('%s%s',command,command_txt);
						end
						[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_reg.poly(iobj1));
					end
				end
			end
		end
	end
end
if testout_topside~=0
	command		= sprintf('%s\n',command);
end
if (currpart_i_tile==1)&&(currpart_i_colprio==7)
	test=1;
end

% Alle Objekte mit einer kleineren Farbpriorität als colprio_base löschen:
for iobj=1:length(obj_bot_reg.poly)
	if (obj_bot_reg.colprio(iobj)<colprio_base)
		command_txt	= sprintf('obj_bot_reg.poly(%4.0f)	= empty_poly;\n',iobj);
		eval(command_txt);
		if testout_topside~=0
			command		= sprintf('%s%s',command,command_txt);
		end
	end
end
if testout_topside~=0
	command		= sprintf('%s\n',command);
end

% Testausgaben:
if testout_topside~=0
	fprintf(1,'%s\n',command);
end

% Leere Polygone ab iobj=2 löschen:
% Das erste Element ist die Grundfläche und wird immer beibehalten, auch wenn sie vollständig von anderen
% Objeckten bedeckt ist.
iobj_delete	= [];
for iobj=2:length(obj_bot_reg.poly)
	if numboundaries(obj_bot_reg.poly(iobj))==0
		iobj_delete	= [iobj_delete;iobj];
	end
end
obj_bot_reg.poly(iobj_delete)		= [];
obj_bot_reg.colno(iobj_delete)	= [];
obj_bot_reg.dz(iobj_delete)		= [];
obj_bot_reg.z_bot(iobj_delete)	= [];
obj_bot_reg.zbotmax(iobj_delete)	= [];
obj_bot_reg.zmin(iobj_delete)		= [];
obj_bot_reg.zmax(iobj_delete)		= [];
obj_bot_reg.colprio(iobj_delete)	= [];
obj_bot_reg.srftype(iobj_delete)	= [];

% Alles nach Farbpriorität sortieren.
[~,i_colprio]			= sort(obj_bot_reg.colprio);
obj_bot_reg.poly		= obj_bot_reg.poly(i_colprio);
obj_bot_reg.colno		= obj_bot_reg.colno(i_colprio);
obj_bot_reg.dz			= obj_bot_reg.dz(i_colprio);
obj_bot_reg.z_bot		= obj_bot_reg.z_bot(i_colprio);
obj_bot_reg.zbotmax	= obj_bot_reg.zbotmax(i_colprio);
obj_bot_reg.zmin		= obj_bot_reg.zmin(i_colprio);
obj_bot_reg.zmax		= obj_bot_reg.zmax(i_colprio);
obj_bot_reg.colprio	= obj_bot_reg.colprio(i_colprio);
obj_bot_reg.srftype	= obj_bot_reg.srftype(i_colprio);

% Alle Farben mit Farbpriorität >colprio_base nach z_bot sortieren, damit bei der Berechnung von obj_bot_bh
% die Überlappungen in der richtigen Reihenfolge beschnitten werden:
dz_bot_sort				= obj_bot_reg.z_bot;
i							= length(dz_bot_sort):-1:1;
i_cpb						= (obj_bot_reg.colprio==colprio_base);
dz_bot_sort(i_cpb)	= min(obj_bot_reg.z_bot)-i(i_cpb);
[~,i_dzbot]				= sort(dz_bot_sort);
obj_bot_reg.poly		= obj_bot_reg.poly(i_dzbot);
obj_bot_reg.colno		= obj_bot_reg.colno(i_dzbot);
obj_bot_reg.dz			= obj_bot_reg.dz(i_dzbot);
obj_bot_reg.z_bot		= obj_bot_reg.z_bot(i_dzbot);
obj_bot_reg.zbotmax	= obj_bot_reg.zbotmax(i_dzbot);
obj_bot_reg.zmin		= obj_bot_reg.zmin(i_dzbot);
obj_bot_reg.zmax		= obj_bot_reg.zmax(i_dzbot);
obj_bot_reg.colprio	= obj_bot_reg.colprio(i_dzbot);
obj_bot_reg.srftype	= obj_bot_reg.srftype(i_dzbot);

% Polygon contour ordering: obj_bot_reg:
obj_bot_reg.poly		= poly_contour_ordering(obj_bot_reg.poly);

% Testplots:
if testplot_obj_bot_reg>0
	
	if ~isempty(testplot_xylimits)
		iobj_v			= 1;
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		[xb_poly_xylimits,yb_poly_xylimits]		= boundary(poly_xylimits);
		for iobj=1:length(obj_bot_reg.poly)
			if overlaps(obj_bot_reg.poly(iobj),poly_xylimits)
				iobj_v	= [iobj_v;iobj];
			end
		end
		iobj_v	= unique(iobj_v);
		imax_obj	= length(iobj_v);
	else
		imax_obj	= length(obj_bot_reg.poly);
		iobj_v	= (1:imax_obj)';
	end
	m_obj		= ceil(sqrt(imax_obj+1));
	n_obj		= ceil((imax_obj+1)/m_obj);
	
	hf			= 100220;
	if testplot_obj_bot_reg==1
		hf=figure(hf);
	else
		hf=figure(hf+currpart_i_tile*10000+currpart_i_colprio*100+currpart_i_part);
	end
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	if testplot_obj_bot_reg==1
		set(hf,'Name','obj_bot_reg');
	else
		set(hf,'Name',sprintf('obj_bot_reg %1.0f/%1.0f/%1.0f',currpart_i_tile,currpart_i_colprio,currpart_i_part));
	end
	set(hf,'NumberTitle','off');
	
	for k=1:length(iobj_v)
		iobj	= iobj_v(k);
		ha=subplot(m_obj,n_obj,k);
		hold(ha,'on');
		axis(ha,'equal');
		plot(ha,obj_bot_reg.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_bot_reg.colno(iobj)).rgb/255)
		plot(ha,obj_bot_reg.poly(iobj).Vertices(:,1),obj_bot_reg.poly(iobj).Vertices(:,2),...
			'LineWidth',0.5,'LineStyle','none','Marker','.','MarkerSize',5,...
			'Color','k');
		if ~isempty(testplot_xylimits)
			plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
			set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
			set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
		else
			set(ha,'XLim',[xmin_mm xmax_mm]);
			set(ha,'YLim',[ymin_mm ymax_mm]);
		end
		title(sprintf('i=%g, cp=%g, st=%g\ndz=%g\nzb=%g, zbmax=%g\nzmin=%1.4f, zmax=%1.4f',...
			iobj,obj_bot_reg.colprio(iobj),obj_bot_reg.srftype(iobj),...
			obj_bot_reg.dz(iobj),...
			obj_bot_reg.z_bot(iobj),obj_bot_reg.zbotmax(iobj),...
			obj_bot_reg.zmin(iobj),obj_bot_reg.zmax(iobj)),'Interpreter','none')
	end
	
	ha=subplot(m_obj,n_obj,imax_obj+1);
	hold(ha,'on');
	axis(ha,'equal');
	imax_obj	= length(obj_bot_reg.poly);
	for iobj=2:imax_obj
		plot(ha,obj_bot_reg.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_bot_reg.colno(iobj)).rgb/255)
	end
	if ~isempty(testplot_xylimits)
		plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
	end
	set(ha,'XLim',[xmin_mm xmax_mm]);
	set(ha,'YLim',[ymin_mm ymax_mm]);
	title(sprintf('i=2...%g',imax_obj),'Interpreter','none')
	
end

if testplot_obj_bot_reg_1plot==1
	hf=figure(100210);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','obj_bot_reg');
	set(hf,'NumberTitle','off');
	ha=axes(hf);
	hold(ha,'on');
	axis(ha,'equal');
	imax_obj	= length(obj_bot_reg.poly);
	for iobj=2:imax_obj
		plot(ha,obj_bot_reg.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_bot_reg.colno(iobj)).rgb/255)
	end
	if ~isempty(testplot_xylimits)
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		[xb_poly_xylimits,yb_poly_xylimits]		= boundary(poly_xylimits);
		plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
	end
	set(ha,'XLim',[xmin_mm xmax_mm]);
	set(ha,'YLim',[ymin_mm ymax_mm]);
	title(sprintf('i=2...%g',imax_obj),'Interpreter','none')
end


%------------------------------------------------------------------------------------------------------------------
% obj_nextcolprio
%------------------------------------------------------------------------------------------------------------------
% Außenabmessungen der als nächstes zu erstellenden Teile mit der nächsthöheren Farbe:
% Ergebnis:		obj_nextcolprio.poly(iobj)
%					obj_nextcolprio.colno(iobj)
% 					obj_nextcolprio.dz(iobj)
% 					obj_nextcolprio.z_bot(iobj)
% 					obj_nextcolprio.zbotmax(iobj)
% 					obj_nextcolprio.zmin(iobj
% 					obj_nextcolprio.zmax(iobj
% 					obj_nextcolprio.colprio(iobj)
% 					obj_nextcolprio.srftype(iobj)

if (currpart_i_tile==1)&&(currpart_i_colprio==4)&&(currpart_i_part==3)
	test=1;
end
if (currpart_i_tile==1)&&(currpart_i_colprio==4)
	test=1;
end

obj_nextcolprio	= [];
colprio_sort		= sort(unique(obj_bot_reg.colprio));
i_colprio_base		= find(colprio_sort==colprio_base);
if (length(i_colprio_base)<length(colprio_sort))&&(currpart_i_part==imax_part)
	% Es ist noch eine weitere Farbe vorhanden:
	colprio_next	= colprio_sort(i_colprio_base+1);
	iobj	= 0;
	for iobj_reg=1:length(obj_bot_reg.poly)
		if obj_bot_reg.colprio(iobj_reg)==colprio_next
			% Der Einfachheit halber sollen nur einzelne Regionen bearbeitet werden.
			% So gibt es nur einen äußeren und ggf. mehrere innere Ränder eines Druckteils.
			if GV.warnings_off
				warning('off','MATLAB:polyshape:tinyBoundaryDropped');
			end
			poly1		= regions(obj_bot_reg.poly(iobj_reg));
			if GV.warnings_off
				warning('on','MATLAB:polyshape:tinyBoundaryDropped');
			end
			for i_region1=1:length(poly1)
				
				% Die Randlinie des nächsten Objekts wird um tol_1 verkleinert,
				% damit keine schmalen Linien am Rand übrig bleiben, die bei der Triangulation Probleme machen:
				poly1_i_region1_mtol1		= polybuffer(poly1(i_region1),-tol_1,'JointType','miter');
				
				% In der Funktion get_T_margin/triangulation_simplify werden Punkte mit einem Abstand kleiner als
				% GV.tol_tp zu einem Punkt zusammengefasst, um die Triangulationsdaten zu vereinfachen und um
				% Fehler bei der Bestimmung der Randlinie zu minimieren.
				% Dafür muss verhindert werden, dass sich das Teil am Rand nicht selbst berührt, sonst könnten
				% Punkte zusammengefasst werden, die nicht zusammengehören.
				% Vorgehensweise:
				% Um poly1_i_region1_mtol1 wird ein 3*GV.tol_tp breiter Streifen gelegt und dann dieser Streifen
				% von poly1_i_region1_mtol1 subtrahiert. Normalerweise sollte das Polygon poly1_i_region1_mtol1
				% dadurch nicht verändert werden.
				poly1_i_region1_ptoltp		= polybuffer(poly1_i_region1_mtol1,3*GV.tol_tp,'JointType','miter');
				poly_strip						= subtract(poly1_i_region1_ptoltp,poly1_i_region1_mtol1,...
					'KeepCollinearPoints',false);
				poly_strip						= polybuffer(poly_strip,-tol_1,'JointType','miter');
				poly1_i_region1				= subtract(poly1_i_region1_mtol1,poly_strip,...
					'KeepCollinearPoints',false);
				
				% In Regionen aufteilen und die Regionen einzeln in obj_nextcolprio speichern:
				if GV.warnings_off
					warning('off','MATLAB:polyshape:tinyBoundaryDropped');
				end
				poly2		= regions(poly1_i_region1);
				if GV.warnings_off
					warning('on','MATLAB:polyshape:tinyBoundaryDropped');
				end
				for i_region2=1:length(poly2)
					if numboundaries(poly2(i_region2))>0
						iobj	= iobj+1;
						obj_nextcolprio.poly(iobj)			= poly2(i_region2);
						obj_nextcolprio.colno(iobj)		= obj_bot_reg.colno(iobj_reg);
						obj_nextcolprio.dz(iobj)			= obj_bot_reg.dz(iobj_reg);
						obj_nextcolprio.z_bot(iobj)		= obj_bot_reg.z_bot(iobj_reg);
						obj_nextcolprio.zbotmax(iobj)		= obj_bot_reg.zbotmax(iobj_reg);
						obj_nextcolprio.zmin(iobj)			= obj_bot_reg.zmin(iobj_reg);
						obj_nextcolprio.zmax(iobj)			= obj_bot_reg.zmax(iobj_reg);
						obj_nextcolprio.colprio(iobj)		= obj_bot_reg.colprio(iobj_reg);
						obj_nextcolprio.srftype(iobj)		= obj_bot_reg.srftype(iobj_reg);
					end
				end
				
			end
		end
	end
else
	% Die aktuelle Grundfarbe ist bereits die letzte Farbe:
	obj_nextcolprio	= [];
end

% Testplots:
if (testplot_obj_ncp>0)&&~isempty(obj_nextcolprio)
	
	if ~isempty(testplot_xylimits)
		iobj_v			= 1;
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		[xb_poly_xylimits,yb_poly_xylimits]		= boundary(poly_xylimits);
		for iobj=1:length(obj_nextcolprio.poly)
			if overlaps(obj_nextcolprio.poly(iobj),poly_xylimits)
				iobj_v	= [iobj_v;iobj];
			end
		end
		iobj_v	= unique(iobj_v);
		imax_obj	= length(iobj_v);
	else
		imax_obj	= length(obj_nextcolprio.poly);
		iobj_v	= (1:imax_obj)';
	end
	m_obj		= ceil(sqrt(imax_obj+1));
	n_obj		= ceil((imax_obj+1)/m_obj);
	hf			= 100280;
	if testplot_obj_bot_reg==1
		hf=figure(hf);
	else
		hf=figure(hf+currpart_i_tile*10000+currpart_i_colprio*100+currpart_i_part);
	end
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	if testplot_obj_ncp==1
		set(hf,'Name','obj_ncp');
	else
		set(hf,'Name',sprintf('obj_ncp %1.0f/%1.0f/%1.0f',currpart_i_tile,currpart_i_colprio,currpart_i_part));
	end
	set(hf,'NumberTitle','off');
	
	for k=1:length(iobj_v)
		iobj	= iobj_v(k);
		ha=subplot(m_obj,n_obj,k);
		hold(ha,'on');
		axis(ha,'equal');
		plot(ha,obj_nextcolprio.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_nextcolprio.colno(iobj)).rgb/255)
		plot(ha,obj_nextcolprio.poly(iobj).Vertices(:,1),obj_nextcolprio.poly(iobj).Vertices(:,2),...
			'LineWidth',0.5,'LineStyle','none','Marker','.','MarkerSize',5,...
			'Color','k');
		if ~isempty(testplot_xylimits)
			plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
			set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
			set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
		else
			set(ha,'XLim',[xmin_mm xmax_mm]);
			set(ha,'YLim',[ymin_mm ymax_mm]);
		end
		title(sprintf('i=%g, cp=%g, st=%g\ndz=%g\nzb=%g, zbmax=%g\nzmin=%1.4f, zmax=%1.4f',...
			iobj,obj_nextcolprio.colprio(iobj),obj_nextcolprio.srftype(iobj),...
			obj_nextcolprio.dz(iobj),...
			obj_nextcolprio.z_bot(iobj),obj_nextcolprio.zbotmax(iobj),...
			obj_nextcolprio.zmin(iobj),obj_nextcolprio.zmax(iobj)),'Interpreter','none')
	end
	
	ha=subplot(m_obj,n_obj,imax_obj+1);
	hold(ha,'on');
	axis(ha,'equal');
	imax_obj	= length(obj_nextcolprio.poly);
	for iobj=1:imax_obj
		plot(ha,obj_nextcolprio.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_nextcolprio.colno(iobj)).rgb/255)
	end
	if ~isempty(testplot_xylimits)
		plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
	end
	set(ha,'XLim',[xmin_mm xmax_mm]);
	set(ha,'YLim',[ymin_mm ymax_mm]);
	title(sprintf('i=1...%g',imax_obj),'Interpreter','none')
	
	setbreakpoint	= 1;
end

if testplot_obj_ncp_1plot==1
	hf=figure(100290);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','obj_ncp');
	set(hf,'NumberTitle','off');
	ha=axes(hf);
	hold(ha,'on');
	axis(ha,'equal');
	if ~isempty(obj_nextcolprio)
		imax_obj	= length(obj_nextcolprio.poly);
		for iobj=1:imax_obj
			plot(ha,obj_nextcolprio.poly(iobj),...
				'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
				PP_local.color(obj_nextcolprio.colno(iobj)).rgb/255)
		end
	end
	if ~isempty(testplot_xylimits)
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		[xb_poly_xylimits,yb_poly_xylimits]		= boundary(poly_xylimits);
		plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
	end
	set(ha,'XLim',[xmin_mm xmax_mm]);
	set(ha,'YLim',[ymin_mm ymax_mm]);
	title(sprintf('i=1...%g',imax_obj),'Interpreter','none')
	setbreakpoint	= 1;
end


%------------------------------------------------------------------------------------------------------------------
% obj_bot_bh		objects, bottom, bigger holes
%------------------------------------------------------------------------------------------------------------------
% Unterseite, Löcher vergrößert, damit die höherliegenden Teile hineinpassen
% Ergebnis:		obj_bot_bh.poly(iobj)
%					obj_bot_bh.colno(iobj)
%					obj_bot_bh.dz(iobj)
%					obj_bot_bh.z_bot(iobj)
%					obj_bot_bh.zbotmax(iobj)
%					obj_bot_bh.zmin(iobj)
%					obj_bot_bh.zmax(iobj)
%					obj_bot_bh.colprio(iobj)
%					obj_bot_bh.srftype(iobj)

if (currpart_i_tile==1)&&(currpart_i_colprio==4)&&(currpart_i_part==3)
	test=1;
end
if (currpart_i_tile==1)&&(currpart_i_colprio==4)
	test=1;
end
if colprio_base>0
	test=1;
end

% Die Ränder der Löcher nach außen setzen:
obj_bot_bh		= obj_bot_reg;
% alle Löcher vergrößern:
% Joint type for buffer boundaries, specified as one of the following:
% 'round'	Round out boundary corners.
% 'square'	Square off boundary corners.
% 'miter'	Limit the ratio between the distance a joint vertex is moved and the buffer distance to 3.
%				This limit prevents excessive pointiness.
% Miter limit, specified as a positive numeric scalar greater than or equal to 2. The miter limit is the ratio
% between the distance a joint vertex is moved and the buffer distance. Setting a miter limit controls the
% pointiness of boundary joints.
miterlimit=2;
for iobj=1:length(obj_bot_bh.poly)
	if ~isequal(obj_bot_bh.colprio(iobj),colprio_base)
		colno		= obj_bot_bh.colno(iobj);
		icolspec	= PP_local.color(colno).spec;
		d_side	= PP_local.colorspec(icolspec).d_side;
		if strcmp(GV.jointtype_bh,'miter')
			obj_bot_bh.poly(iobj)	= polybuffer(obj_bot_bh.poly(iobj),d_side,'JointType','Miter',...
				'MiterLimit',miterlimit);
		else
			obj_bot_bh.poly(iobj)	= polybuffer(obj_bot_bh.poly(iobj),d_side,'JointType',GV.jointtype_bh);
		end
	end
end

% Die Überlappungen in der richtigen Reihenfolge beschneiden:
% vorher: Sortierung nach Farbpriorität obj_bot_reg.colprio:
%         Die Löcher/Objekte mit geringerer Priorität von den Objekten mit höherer Priorität subtrahieren:
% jetzt:  Sortierung nach Höhe der Unterseite obj_bot_reg.z_bot (bis auf die Kachel-Grundfarbe):
%         Tiefer liegende Löcher/Objekte von höher liegenden Objekten subtrahieren:
command	= '';
xlim										= cell(size(obj_bot_bh.poly,1),1);
ylim										= cell(size(obj_bot_bh.poly,1),1);
for iobj1=1:size(obj_bot_bh.poly,1)
	[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_bh.poly(iobj1));
end
for iobj1=size(obj_bot_bh.poly,1):-1:1
	% beginnen mit dem höchsten Wert z_bot
	if ~isequal(obj_bot_bh.colprio(iobj1),colprio_base)
		% iobj1 hat nicht die Grundfarbe:
		for iobj2=(iobj1-1):-1:1
			% z_bot von iobj2 ist kleiner als von iobj1
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1		= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: topside triangulation: cut overlapping areas: %g/%g %g/%g',msg,...
					size(obj_bot_bh.poly,1)-iobj1+1,size(obj_bot_bh.poly,1),...
					(iobj1-1)-iobj2+1,(iobj1-1)));
				drawnow;
			end
			if    ~isequal(obj_bot_bh.colprio(iobj2),colprio_base)
				% iobj2 hat nicht die Grundfarbe:
				if size(xlim{iobj1,1},1)>0
					if size(xlim{iobj2,1},1)>0
						if overlaps_boundingbox(tol_1,...
							xlim{iobj1,1}(1),...		% x1min
							xlim{iobj1,1}(2),...		% x1max
							ylim{iobj1,1}(1),...		% y1min
							ylim{iobj1,1}(2),...		% y1max
							xlim{iobj2,1}(1),...		% x2min
							xlim{iobj2,1}(2),...		% x2max
							ylim{iobj2,1}(1),...		% y2min
							ylim{iobj2,1}(2))			% y2max
							% The polygons may overlap or touch:
							command_txt	= ...
								sprintf('obj_bot_bh.poly(%4.0f)	= subtract(obj_bot_bh.poly(%4.0f),obj_bot_bh.poly(%4.0f));\n',...
								iobj1,iobj1,iobj2);
							eval(command_txt);																										%  4%
							if testout_topside~=0
								command		= sprintf('%s%s',command,command_txt);
							end
							[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_bh.poly(iobj1));
						end
					end
				end
			end
		end
	end
end
if testout_topside~=0
	command		= sprintf('%s\n',command);
end
for iobj1=(size(obj_bot_bh.poly,1)-1):-1:2
	if isequal(obj_bot_bh.colprio(iobj1),colprio_base)
		% iobj1 hat die Grundfarbe:
		for iobj2=(iobj1+1):size(obj_bot_bh.poly,1)
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1		= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: topside triangulation: cut overlapping areas, base color: %g/%g %g/%g',msg,...
					size(obj_bot_bh.poly,1)-iobj1+1,size(obj_bot_bh.poly,1),...
					iobj2-(iobj1+1)+1,size(obj_bot_bh.poly,1)-(iobj1+1)+1));
				drawnow;
			end
			if    ~isequal(obj_bot_bh.colprio(iobj2),colprio_base)
				% iobj2 hat nicht die Grundfarbe:
				if size(xlim{iobj1,1},1)>0
					if size(xlim{iobj2,1},1)>0
						if overlaps_boundingbox(tol_1,...
							xlim{iobj1,1}(1),...		% x1min
							xlim{iobj1,1}(2),...		% x1max
							ylim{iobj1,1}(1),...		% y1min
							ylim{iobj1,1}(2),...		% y1max
							xlim{iobj2,1}(1),...		% x2min
							xlim{iobj2,1}(2),...		% x2max
							ylim{iobj2,1}(1),...		% y2min
							ylim{iobj2,1}(2))			% y2max
							% The polygons may overlap or touch:
							command_txt	= ...
								sprintf('obj_bot_bh.poly(%4.0f)	= subtract(obj_bot_bh.poly(%4.0f),obj_bot_bh.poly(%4.0f));\n',...
								iobj1,iobj1,iobj2);
							eval(command_txt);																										% 10%
							if testout_topside~=0
								command		= sprintf('%s%s',command,command_txt);
							end
							[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_bh.poly(iobj1));
						end
					end
				end
			end
		end
	end
end
% Testausgaben:
if testout_topside~=0
	command		= sprintf('%s\n',command);
	fprintf(1,'%s\n',command);
end

% Alle Polygone auf die Grundfläche beschneiden:
% Hier können noch einmal schmale Streifen übrigbleiben: obj.poly(1) um 2*tol_1 verkleinern:
obj.poly(1)	= polybuffer(obj.poly(1),-2*tol_1,'JointType','miter','MiterLimit',3);
for iobj=1:length(obj_bot_bh.poly)
	obj_bot_bh.poly(iobj)	= intersect(obj_bot_bh.poly(iobj),obj.poly(1),'KeepCollinearPoints',true);
end

% Polygon contour ordering: obj_bot_bh:
obj_bot_bh.poly		= poly_contour_ordering(obj_bot_bh.poly);

% Testplots:
if testplot_obj_bot_bh==1
	
	if ~isempty(testplot_xylimits)
		iobj_v			= 1;
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		[xb_poly_xylimits,yb_poly_xylimits]		= boundary(poly_xylimits);
		for iobj=1:length(obj_bot_bh.poly)
			if overlaps(obj_bot_bh.poly(iobj),poly_xylimits)
				iobj_v	= [iobj_v;iobj];
			end
		end
		iobj_v	= unique(iobj_v);
		imax_obj	= length(iobj_v);
	else
		imax_obj	= length(obj_bot_bh.poly);
		iobj_v	= (1:imax_obj)';
	end
	m_obj		= ceil(sqrt(imax_obj+1));
	n_obj		= ceil((imax_obj+1)/m_obj);
	hf=figure(100230);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','obj_bot_bh');
	set(hf,'NumberTitle','off');
	
	for k=1:length(iobj_v)
		iobj	= iobj_v(k);
		ha=subplot(m_obj,n_obj,k);
		hold(ha,'on');
		axis(ha,'equal');
		plot(ha,obj_bot_bh.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_bot_bh.colno(iobj)).rgb/255)
		plot(ha,obj_bot_bh.poly(iobj).Vertices(:,1),obj_bot_bh.poly(iobj).Vertices(:,2),...
			'LineWidth',0.5,'LineStyle','none','Marker','.','MarkerSize',5,...
			'Color','k');
		if ~isempty(testplot_xylimits)
			plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
			set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
			set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
		else
			set(ha,'XLim',[xmin_mm xmax_mm]);
			set(ha,'YLim',[ymin_mm ymax_mm]);
		end
		title(sprintf('i=%g, cp=%g, st=%g\ndz=%g\nzb=%g, zbmax=%g\nzmin=%1.4f, zmax=%1.4f',...
			iobj,obj_bot_bh.colprio(iobj),obj_bot_bh.srftype(iobj),...
			obj_bot_bh.dz(iobj),...
			obj_bot_bh.z_bot(iobj),obj_bot_bh.zbotmax(iobj),...
			obj_bot_bh.zmin(iobj),obj_bot_bh.zmax(iobj)),'Interpreter','none')
	end
	
	ha			= subplot(m_obj,n_obj,imax_obj+1);
	hold(ha,'on');
	axis(ha,'equal');
	imax_obj	= length(obj_bot_bh.poly);
	for iobj=2:imax_obj
		plot(ha,obj_bot_bh.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_bot_bh.colno(iobj)).rgb/255)
	end
	if ~isempty(testplot_xylimits)
		plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
	end
	set(ha,'XLim',[xmin_mm xmax_mm]);
	set(ha,'YLim',[ymin_mm ymax_mm]);
	title(sprintf('i=2...%g',imax_obj),'Interpreter','none')
	
end

if testplot_obj_bot_bh_1plot==1
	hf=figure(100240);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','obj_bot_bh');
	set(hf,'NumberTitle','off');
	ha=axes(hf);
	hold(ha,'on');
	axis(ha,'equal');
	for iobj=2:length(obj_bot_bh.poly)
		plot(ha,obj_bot_bh.poly(iobj),...
			'LineWidth',1,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_bot_bh.colno(iobj)).rgb/255)
	end
	for iobj=2:length(obj_bot_reg.poly)
		if ~isequal(obj_bot_reg.colprio(iobj),colprio_base)
			plot(ha,obj_bot_reg.poly(iobj),...
				'LineWidth',2,'LineStyle',':','EdgeColor','r','FaceAlpha',0)
		end
	end
	for iobj=length(obj_bot_reg.poly):-1:2
		if ~isequal(obj_bot_reg.colprio(iobj),colprio_base)
			color			= PP_local.color(obj_bot_reg.colno(iobj)).rgb/255;
			linewidth	= 2;
			marker		= plot_marker_v{vindexrest(iobj,length(plot_marker_v))};
			markersize	= 12;
			plot(ha,obj_bot_reg.poly(iobj).Vertices(:,1),obj_bot_reg.poly(iobj).Vertices(:,2),...
				'LineWidth',linewidth,'LineStyle','none','Color',color,'Marker',marker,'MarkerSize',markersize);
		end
	end
	for iobj=length(obj_bot_reg.poly):-1:2
		if isequal(obj_bot_reg.colprio(iobj),colprio_base)
			color			= 'k';
			linewidth	= 2;
			marker		= '.';
			markersize	= 15;
			plot(ha,obj_bot_reg.poly(iobj).Vertices(:,1),obj_bot_reg.poly(iobj).Vertices(:,2),...
				'LineWidth',linewidth,'LineStyle','none','Color',color,'Marker',marker,'MarkerSize',markersize);
		end
	end
	if ~isempty(testplot_xylimits)
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		[xb_poly_xylimits,yb_poly_xylimits]		= boundary(poly_xylimits);
		plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
	end
	set(ha,'XLim',[xmin_mm xmax_mm]);
	set(ha,'YLim',[ymin_mm ymax_mm]);
	set(ha,'Clipping','off');
	axis(ha,'equal');
	title(sprintf('red lines: obj_bot_reg / black lines: obj_bot_bh'),'Interpreter','none')
end


%------------------------------------------------------------------------------------------------------------------
% obj_bot_bh_reg		objects, bottom, bigger holes, single regions
%------------------------------------------------------------------------------------------------------------------
% Unterseite, Löcher vergrößert damit die höherliegenden Teile hineinpassen, Regionen einzeln,
% Anzahl der Stützpunkte erhöht, evtl. doppelte Stützpunkte gelöscht
% Ergebnis:		obj_bot_bh_reg.poly(iobj)
%					obj_bot_bh_reg.colno(iobj)
%					obj_bot_bh_reg.dz(iobj)
%					obj_bot_bh_reg.z_bot(iobj)
%					obj_bot_bh_reg.zbotmax(iobj)
%					obj_bot_bh_reg.zmin(iobj)
%					obj_bot_bh_reg.zmax(iobj)
%					obj_bot_bh_reg.colprio(iobj)
%					obj_bot_bh_reg.srftype(iobj)

if (currpart_i_tile==1)&&(currpart_i_colprio==4)&&(currpart_i_part==3)
	test=1;
end
if (currpart_i_tile==1)&&(currpart_i_colprio==4)
	test=1;
end

obj_bot_bh_reg.poly				= [];
obj_bot_bh_reg.colno				= [];
obj_bot_bh_reg.dz					= [];
obj_bot_bh_reg.z_bot				= [];
obj_bot_bh_reg.zbotmax			= [];
obj_bot_bh_reg.zmin				= [];
obj_bot_bh_reg.zmax				= [];
obj_bot_bh_reg.colprio			= [];
obj_bot_bh_reg.srftype			= [];
for iobj=1:length(obj_bot_bh.poly)
	if GV.warnings_off
		warning('off','MATLAB:polyshape:tinyBoundaryDropped');
	end
	poly								= regions(obj_bot_bh.poly(iobj));
	if GV.warnings_off
		warning('on','MATLAB:polyshape:tinyBoundaryDropped');
	end
	for i_region=1:length(poly)
		obj_bot_bh_reg.poly		= [obj_bot_bh_reg.poly   ;poly(i_region)          ];
		obj_bot_bh_reg.colno		= [obj_bot_bh_reg.colno  ;obj_bot_bh.colno(iobj)  ];
		obj_bot_bh_reg.dz			= [obj_bot_bh_reg.dz     ;obj_bot_bh.dz(iobj)     ];
		obj_bot_bh_reg.z_bot		= [obj_bot_bh_reg.z_bot  ;obj_bot_bh.z_bot(iobj)  ];
		obj_bot_bh_reg.zbotmax	= [obj_bot_bh_reg.zbotmax;obj_bot_bh.zbotmax(iobj)];
		obj_bot_bh_reg.zmin		= [obj_bot_bh_reg.zmin   ;obj_bot_bh.zmin(iobj)   ];
		obj_bot_bh_reg.zmax		= [obj_bot_bh_reg.zmax   ;obj_bot_bh.zmax(iobj)   ];
		obj_bot_bh_reg.colprio	= [obj_bot_bh_reg.colprio;obj_bot_bh.colprio(iobj)];
		obj_bot_bh_reg.srftype	= [obj_bot_bh_reg.srftype;obj_bot_bh.srftype(iobj)];
	end
end

% Es kann passieren, dass Löcher in boundarys wieder gefüllt werden, wenn nur ein Punkt des Lochs auf der
% äußeren Randlinie liegt (in diesem Fall wird im command window eine Warnung ausgegeben):
% Zur Sicherheit alle Polygone wieder voneinaner abziehen:
xlim											= cell(size(obj_bot_bh_reg.poly,1),1);
ylim											= cell(size(obj_bot_bh_reg.poly,1),1);
for iobj1=1:size(obj_bot_bh_reg.poly,1)
	[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_bh_reg.poly(iobj1));
end
if GV.warnings_off
	warning('off','MATLAB:polyshape:boundary3Points');
end
for iobj1=2:length(obj_bot_bh_reg.poly)
	for iobj2=2:length(obj_bot_bh_reg.poly)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			set(GV_H.text_waitbar,'String',sprintf(...
				'%s: topside triangulation: prevent overlapping of regions %g/%g %g/%g',msg,...
				iobj1,length(obj_bot_bh_reg.poly),...
				iobj2,length(obj_bot_bh_reg.poly)));
			drawnow;
		end
		if iobj1~=iobj2
			if size(xlim{iobj1,1},1)>0
				if size(xlim{iobj2,1},1)>0
					if overlaps_boundingbox(tol_1,...
						xlim{iobj1,1}(1),...		% x1min
						xlim{iobj1,1}(2),...		% x1max
						ylim{iobj1,1}(1),...		% y1min
						ylim{iobj1,1}(2),...		% y1max
						xlim{iobj2,1}(1),...		% x2min
						xlim{iobj2,1}(2),...		% x2max
						ylim{iobj2,1}(1),...		% y2min
						ylim{iobj2,1}(2))			% y2max
						% The polygons may overlap or touch:
						obj_bot_bh_reg.poly(iobj1)	= ...
							subtract(obj_bot_bh_reg.poly(iobj1),obj_bot_bh_reg.poly(iobj2),'KeepCollinearPoints',true);
						[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_bh_reg.poly(iobj1));
					end
				end
			end
		end
	end
end
if GV.warnings_off
	warning('on','MATLAB:polyshape:boundary3Points');
end

% Alles nach dz und dann nach Farbpriorität sortieren (weiter unten noch einmal):
if length(obj_bot_bh_reg.poly)>1
	min_diff_dz		= min(diff(sort(unique(obj_bot_bh_reg.dz))));
	if isempty(min_diff_dz)
		min_diff_dz	= 1;
	end
	dz_v			= obj_bot_bh_reg.dz + ...
		min_diff_dz * obj_bot_bh_reg.colprio / (max(obj_bot_bh_reg.colprio)+1);
	dz_v(1)		= min(dz_v)-1;			% keep the first element at the first place
	[~,i_dz]		= sort(dz_v);
	obj_bot_bh_reg.poly			= obj_bot_bh_reg.poly(i_dz);
	obj_bot_bh_reg.colno			= obj_bot_bh_reg.colno(i_dz);
	obj_bot_bh_reg.dz				= obj_bot_bh_reg.dz(i_dz);
	obj_bot_bh_reg.z_bot			= obj_bot_bh_reg.z_bot(i_dz);
	obj_bot_bh_reg.zbotmax		= obj_bot_bh_reg.zbotmax(i_dz);
	obj_bot_bh_reg.zmin			= obj_bot_bh_reg.zmin(i_dz);
	obj_bot_bh_reg.zmax			= obj_bot_bh_reg.zmax(i_dz);
	obj_bot_bh_reg.colprio		= obj_bot_bh_reg.colprio(i_dz);
	obj_bot_bh_reg.srftype		= obj_bot_bh_reg.srftype(i_dz);
end

% Auflösung der Polygone erhöhen, damit die Topologie richtig abgebildet wird.
% Bedingung:	Die Stützstellen sich berührender Polygone sollen genau übereinander liegen, um die Berechnung
%					der senkrechten Flächen zu ermöglichen.
% Für die Abfrage, ob ein Punkt auf dem Rand eines Polygons liegt:
% shift outside the edges of the polygon area by tol_1
for iobj2=1:length(obj_bot_bh_reg.poly)
	obj_bot_bh_reg_mtol.poly(iobj2)	= ...
		polybuffer(obj_bot_bh_reg.poly(iobj2),-tol_1,'JointType','miter','MiterLimit',3);
	obj_bot_bh_reg_ptol.poly(iobj2)	= ...
		polybuffer(obj_bot_bh_reg.poly(iobj2) ,tol_1,'JointType','miter','MiterLimit',3);
end
dmax		= min([...
	ELE_local.elefiltset(ifs_tb,1).dx_mm ...
	ELE_local.elefiltset(ifs_tb,1).dy_mm]);
xlim		= cell(size(obj_bot_bh_reg.poly,1),1);
ylim		= cell(size(obj_bot_bh_reg.poly,1),1);
for iobj1=1:length(obj_bot_bh_reg.poly)
	[xlim{iobj1,1},ylim{iobj1,1}]	= boundingbox(obj_bot_bh_reg.poly(iobj1));
end
tol_1_2	= 2*tol_1;		% Sicherheitsfaktor (ohne dass vorher Fehler auftraten)
for iobj1=2:length(obj_bot_bh_reg.poly)
	% Auflösung erhöhen:
	obj_bot_bh_reg.poly(iobj1)	= changeresolution_poly(obj_bot_bh_reg.poly(iobj1),dmax,[],[]);
	% Die Stützstellen des Polynomes iobj1 allen anderen Polynomen hinzufügen, wenn sie auf deren Rand liegen:
	if size(xlim{iobj1,1},1)>0
		for iobj2=2:length(obj_bot_bh_reg.poly)
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1	= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: topside triangulation: increase resolution %g/%g %g/%g',msg,...
					iobj1,length(obj_bot_bh_reg.poly),...
					iobj2,length(obj_bot_bh_reg.poly)));
				drawnow;
			end
			if iobj1~=iobj2
				if size(xlim{iobj2,1},1)>0
					overlap_is_possible	= false;
					if overlaps_boundingbox(tol_1_2,...
							xlim{iobj1,1}(1),...		% x1min
							xlim{iobj1,1}(2),...		% x1max
							ylim{iobj1,1}(1),...		% y1min
							ylim{iobj1,1}(2),...		% y1max
							xlim{iobj2,1}(1),...		% x2min
							xlim{iobj2,1}(2),...		% x2max
							ylim{iobj2,1}(1),...		% y2min
							ylim{iobj2,1}(2))			% y2max
						overlap_is_possible	= true;
					end
% 					% a little bit faster:
% 					overlap_is_possible	= true;
% 					if xlim{iobj2,1}(1)>(xlim{iobj1,1}(2)+tol_1_2)
% 						overlap_is_possible	= false;
% 					else
% 						if xlim{iobj2,1}(2)<(xlim{iobj1,1}(1)-tol_1_2)
% 							overlap_is_possible	= false;
% 						else
% 							if ylim{iobj2,1}(1)>(ylim{iobj1,1}(2)+tol_1_2)
% 								overlap_is_possible	= false;
% 							else
% 								if ylim{iobj2,1}(2)<(ylim{iobj1,1}(1)-tol_1_2)
% 									overlap_is_possible	= false;
% 								end
% 							end
% 						end
% 					end
					if overlap_is_possible
						% The polygons may overlap or touch:
						% Finde die Stützstellen von Objekt 1, die auf dem Rand von Objekt 2 liegen, und fügen sie dem
						% Objekt 2 hinzu:
						i_in		= inpolygon(...
							obj_bot_bh_reg.poly(iobj1).Vertices(:,1),...				% query points
							obj_bot_bh_reg.poly(iobj1).Vertices(:,2),...				% query points
							obj_bot_bh_reg_mtol.poly(iobj2).Vertices(:,1),...		% edges of the polygon area
							obj_bot_bh_reg_mtol.poly(iobj2).Vertices(:,2));			% edges of the polygon area
						i_out		= inpolygon(...
							obj_bot_bh_reg.poly(iobj1).Vertices(:,1),...				% query points
							obj_bot_bh_reg.poly(iobj1).Vertices(:,2),...				% query points
							obj_bot_bh_reg_ptol.poly(iobj2).Vertices(:,1),...		% edges of the polygon area
							obj_bot_bh_reg_ptol.poly(iobj2).Vertices(:,2));			% edges of the polygon area
						i_vert_obj1			= i_out&~i_in;
						% i_vert_obj1: Indices in obj_bot_bh_reg.poly(iobj1) der Stützpunkte:
						if ~isempty(find(i_vert_obj1,1))
							if GV.warnings_off
								warning('off','MATLAB:polyshape:repairedBySimplify');
							end
							obj_bot_bh_reg.poly(iobj2)=insertvertex_poly(...
								obj_bot_bh_reg.poly(iobj2),obj_bot_bh_reg.poly(iobj1).Vertices(i_vert_obj1,:),tol_1);
							if GV.warnings_off
								warning('on','MATLAB:polyshape:repairedBySimplify');
							end
						end
					end
				end
			end
		end
	end
end

% Evtl. doppelte Stützpunkte löschen:
% Ein Abstand der Stützstellen tol_1 soll weiterhin zulässig sein: Verwendung von tol_1/2
% Dies ist nötig, da bei "Alle Polygone auf die Grundfläche beschneiden" sich die Randlinien um tol_1 verschieben
% und neue Punkte im Abstand tol_1 entstehen können.
if GV.warnings_off
	warning('off','MATLAB:polyshape:boundary3Points');
	warning('off','MATLAB:polyshape:repairedBySimplify');
	warning('off','MATLAB:polyshape:boolOperationFailed');
end
for iobj=2:length(obj_bot_bh_reg.poly)
	for ib_obj	= 1:numboundaries(obj_bot_bh_reg.poly(iobj))
		% vertices of object 1, boundary ib_obj1:
		[x,y]				= boundary(obj_bot_bh_reg.poly(iobj),ib_obj);
		x					= x(1:(end-1));
		y					= y(1:(end-1));
		k					= (1:size(x,1))';
		kp1				= vindexrest(k+1,size(x,1));
		k_doppelt		= (abs(x(k)-x(kp1))<(tol_1/2)) & (abs(y(k)-y(kp1))<(tol_1/2));
		x(k_doppelt)	= [];
		y(k_doppelt)	= [];
		if ib_obj==1
			poly_neu		= polyshape(x,y,'KeepCollinearPoints',true);
		else
			poly_neu		= addboundary(poly_neu,x,y,'KeepCollinearPoints',true);
		end
	end
	if numboundaries(obj_bot_bh_reg.poly(iobj))>0
		obj_bot_bh_reg.poly(iobj)	= poly_neu;
	end
end
if GV.warnings_off
	warning('on','MATLAB:polyshape:boundary3Points');
	warning('on','MATLAB:polyshape:repairedBySimplify');
	warning('on','MATLAB:polyshape:boolOperationFailed');
end

% Teilflächen in der aktuellen Grundfarbe, die zu klein sind, einer anderen Farbe zuordnen:
% Es kann passieren, dass nach dem Vergrößern der Löcher in der aktuellen Grundfarbe sehr kleine Stellen
% übrig bleiben, die als hohe "Säule" nach dem Drucken leicht abbrechen können.
% Diese Teilflächen sollen der Farbe des angrenzenden "Lochs" zugeordnet werden.
% Nicht auf Texte und Symbole anwenden!
if (currpart_i_tile==1)&&(currpart_i_colprio==4)&&(currpart_i_part==3)
	test=1;
end
for iobj1=2:length(obj_bot_bh_reg.poly)
	% Waitbar:
	if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
		WAITBAR.t1		= clock;
		set(GV_H.text_waitbar,'String',sprintf(...
			'%s: topside triangulation: handling of small areas: %g/%g',msg,iobj1,length(obj_bot_bh_reg.poly)));
		drawnow;
	end
	
	% Wichtig: die Werte srftype sind nur für colprio_base noch gültig, da die Unterseiten der Farben mit
	% höherer Farbpriorität verundet wurden.
	if		(numboundaries(obj_bot_bh_reg.poly(iobj1))                           ==           1)           &&((...
		   (obj_bot_bh_reg.colprio(iobj1)                                       ==colprio_base)&&...
			(obj_bot_bh_reg.srftype(iobj1)-mod(obj_bot_bh_reg.srftype(iobj1),100)~=         300)&&...
			(obj_bot_bh_reg.srftype(iobj1)-mod(obj_bot_bh_reg.srftype(iobj1),100)~=         400)     )||...
			(obj_bot_bh_reg.colprio(iobj1)                                       > colprio_base)                  )
		
		% Es werden nur folgende Teilflächen neu zugeordnet:
		% -	die nur eine Randlinie haben und
		%		(Die Einschränkung "numboundaries(obj_bot_bh_reg.poly(iobj1))==1" ist zwar in der Regel bei
		%		kleinen Flächen gegeben, erleichtert aber die Programmierung.)
		% -	die die aktuelle Grundfarbe haben und die keine Texte sind und die keine Symbole sind oder
		% -	die nicht die aktuelle Grundfarbe haben
		[xlim,ylim]		= boundingbox(obj_bot_bh_reg.poly(iobj1));
		diag_iobj		= sqrt((xlim(2)-xlim(1))^2+(ylim(2)-ylim(1))^2);
		area_iobj		= area(obj_bot_bh_reg.poly(iobj1));
		poly_iobj		= polybuffer(obj_bot_bh_reg.poly(iobj1),-PP_local.general.sticks_strips_removal.minwidth/2,...
			'JointType','miter','MiterLimit',3);
		if    (diag_iobj<PP_local.general.sticks_strips_removal.mindiag)||...
				(area_iobj<PP_local.general.sticks_strips_removal.minarea)||...
				(numboundaries(poly_iobj)==0)
			% Die Teilfläche ist zu klein:
			ib1					= 1;			% Es gibt nur eine boundary, siehe oben
			[x1,y1]				= boundary(obj_bot_bh_reg.poly(iobj1),ib1);
			xy1					= [x1(1:(end-1)) y1(1:(end-1))];
			if (obj_bot_bh_reg.colprio(iobj1)>colprio_base)||(mod(obj_bot_bh_reg.srftype(iobj1),100)==0)
				% - colprio>colprio_base ==> dz ist gleich z_bot (Unterseite des höherliegenden Teils) ODER
				% - Die Oberfläche folgt dem Gelände
				xyz1	= add_z_2_poly(...
					colprio_base,...
					xy1,...
					obj_bot_bh_reg.zmin(iobj1),...
					obj_bot_bh_reg.dz(iobj1),...
					obj_bot_bh_reg.zbotmax(iobj1),...
					obj_bot_bh_reg.colno(iobj1),...
					PP_local,ELE_local,poly_legbgd);
			else
				% - colprio=colprio_base ==> dz gibt die Anhebung relativ zu dem Gelände an UND
				% - Die Oberfläche ist eben (srftype~=xx0: Vordergrund von Texten und Symbolen)
				xyz1	= [xy1 (obj_bot_bh_reg.zmax(iobj1)+obj_bot_bh_reg.dz(iobj1))*ones(size(xy1,1),1)];
			end
			
			% Suche nach angrenzenden Teilflächen mit derselben Farbpriorität:
			neighboring_area_is_lower	= true;
			for iobj2=2:length(obj_bot_bh_reg.poly)
				if (iobj2~=iobj1)&&(obj_bot_bh_reg.colprio(iobj2)==colprio_base)
					for ib2=1:numboundaries(obj_bot_bh_reg.poly(iobj2))
						[x2,y2]				= boundary(obj_bot_bh_reg.poly(iobj2),ib2);
						xy2					= [x2(1:(end-1)) y2(1:(end-1))];
						if (obj_bot_bh_reg.colprio(iobj2)>colprio_base)||(mod(obj_bot_bh_reg.srftype(iobj2),100)==0)
							% - colprio>colprio_base ==> dz ist gleich z_bot (Unterseite des höherliegenden Teils) ODER
							% - Die Oberfläche folgt dem Gelände
							xyz2	= add_z_2_poly(...
								colprio_base,...
								xy2,...
								obj_bot_bh_reg.zmin(iobj2),...
								obj_bot_bh_reg.dz(iobj2),...
								obj_bot_bh_reg.zbotmax(iobj2),...
								obj_bot_bh_reg.colno(iobj2),...
								PP_local,ELE_local,poly_legbgd);
						else
							% - colprio=colprio_base ==> dz gibt die Anhebung relativ zu dem Gelände an UND
							% - Die Oberfläche ist eben (srftype~=xx0: Vordergrund von Texten und Symbolen)
							xyz2	= [xy2 (obj_bot_bh_reg.zmax(iobj2)+obj_bot_bh_reg.dz(iobj2))*ones(size(xy2,1),1)];
						end
						% Alle Punkte der kleinen Fläche iobj1 einzeln durchgehen und nach gleichen Punkten in der
						% angrenzenden Fläche gleicher Farbe suchen:
						for k1=1:size(xy1,1)
							k2_v			= find(...
								(abs(x1(k1)-x2)<tol_1)&...
								(abs(y1(k1)-y2)<tol_1)    );
							if ~isempty(k2_v)
								% Es gibt eine angrenzende Fläche:
								[~,ik2v]		= min(sqrt((x1(k1)-x2(k2_v)).^2+(y1(k1)-y2(k2_v)).^2));
								k2				= k2_v(ik2v);
								if xyz2(k2,3)>xyz1(k1,3)
									% Mindestend ein Punkt der angrenzenden Fläche gleicher Farbe liegt höher: Abbruch
									neighboring_area_is_lower	= false;
									break
								end
							end
						end
						if ~neighboring_area_is_lower
							break
						end
					end
				end
				if ~neighboring_area_is_lower
					break
				end
			end
			
			% Das zu kleine Objekt einer anderen Farbe zuordnen:
			if neighboring_area_is_lower
				% Es gibt keine angrenzenden Teilflächen mit derselben Farbpriorität, die höher liegen:
				% Suche eine angrenzende Teilfläche mit derselben oder der nächsthöheren Farbpriorität:
				colprio_v	= unique(obj_bot_bh_reg.colprio);
				% colprio_v(colprio_v==colprio_base)		= [];		% auch dieselbe Farbe zulassen
				neighboring_area_found		= false;
				for icpv=1:length(colprio_v)
					colprio2			= colprio_v(icpv);
					for iobj2=2:length(obj_bot_bh_reg.poly)
						if (obj_bot_bh_reg.colprio(iobj2)==colprio2)&&(iobj2~=iobj1)
							for ib2=1:numboundaries(obj_bot_bh_reg.poly(iobj2))
								[x2,y2]				= boundary(obj_bot_bh_reg.poly(iobj2),ib2);
								% Alle Punkte der kleinen Fläche iobj1 einzeln durchgehen und nach gleichen Punkten in der
								% angrenzenden Fläche suchen:
								for k1=1:size(xy1,1)
									if any(...
											(abs(x1(k1)-x2)<tol_1)&...
											(abs(y1(k1)-y2)<tol_1)    )
										% Es gibt eine angrenzende Fläche:
										neighboring_area_found	= true;
										break
									end
								end
								if neighboring_area_found
									break
								end
							end
						end
						if neighboring_area_found
							break
						end
					end
					if neighboring_area_found
						% Alle Eigenschaften des Objekts iobj2 dem Objekt iobj1 zuweisen (außer .poly):
						% obj_bot_bh_reg.poly(iobj1)		= obj_bot_bh_reg.poly(iobj2);
						obj_bot_bh_reg.colno(iobj1)		= obj_bot_bh_reg.colno(iobj2);
						obj_bot_bh_reg.dz(iobj1)			= obj_bot_bh_reg.dz(iobj2);
						obj_bot_bh_reg.z_bot(iobj1)		= obj_bot_bh_reg.z_bot(iobj2);
						obj_bot_bh_reg.zbotmax(iobj1)		= obj_bot_bh_reg.zbotmax(iobj2);
						obj_bot_bh_reg.zmin(iobj1)			= obj_bot_bh_reg.zmin(iobj2);
						obj_bot_bh_reg.zmax(iobj1)			= obj_bot_bh_reg.zmax(iobj2);
						obj_bot_bh_reg.colprio(iobj1)		= obj_bot_bh_reg.colprio(iobj2);
						obj_bot_bh_reg.srftype(iobj1)		= obj_bot_bh_reg.srftype(iobj2);
					end
					if neighboring_area_found
						break
					end
				end
			end
			
		end
	end
end

% Wieder alles nach dz und dann nach Farbpriorität sortieren (wie oben):
if length(obj_bot_bh_reg.poly)>1
	min_diff_dz		= min(diff(sort(unique(obj_bot_bh_reg.dz))));
	if isempty(min_diff_dz)
		min_diff_dz	= 1;
	end
	dz_v			= obj_bot_bh_reg.dz + ...
		min_diff_dz * obj_bot_bh_reg.colprio / (max(obj_bot_bh_reg.colprio)+1);
	dz_v(1)		= min(dz_v)-1;			% keep the first element at the first place
	[~,i_dz]		= sort(dz_v);
	obj_bot_bh_reg.poly			= obj_bot_bh_reg.poly(i_dz);
	obj_bot_bh_reg.colno			= obj_bot_bh_reg.colno(i_dz);
	obj_bot_bh_reg.dz				= obj_bot_bh_reg.dz(i_dz);
	obj_bot_bh_reg.z_bot			= obj_bot_bh_reg.z_bot(i_dz);
	obj_bot_bh_reg.zbotmax		= obj_bot_bh_reg.zbotmax(i_dz);
	obj_bot_bh_reg.zmin			= obj_bot_bh_reg.zmin(i_dz);
	obj_bot_bh_reg.zmax			= obj_bot_bh_reg.zmax(i_dz);
	obj_bot_bh_reg.colprio		= obj_bot_bh_reg.colprio(i_dz);
	obj_bot_bh_reg.srftype		= obj_bot_bh_reg.srftype(i_dz);
end

% leere Polygone löschen:
iobj_delete	= [];
for iobj=2:length(obj_bot_bh_reg.poly)
	if numboundaries(obj_bot_bh_reg.poly(iobj))==0
		iobj_delete	= [iobj_delete;iobj];
	end
end
obj_bot_bh_reg.poly(iobj_delete)		= [];
obj_bot_bh_reg.colno(iobj_delete)	= [];
obj_bot_bh_reg.dz(iobj_delete)		= [];
obj_bot_bh_reg.z_bot(iobj_delete)	= [];
obj_bot_bh_reg.zbotmax(iobj_delete)	= [];
obj_bot_bh_reg.zmin(iobj_delete)		= [];
obj_bot_bh_reg.zmax(iobj_delete)		= [];
obj_bot_bh_reg.colprio(iobj_delete)	= [];
obj_bot_bh_reg.srftype(iobj_delete)	= [];

% Polygon contour ordering: obj_bot_bh:
obj_bot_bh_reg.poly		= poly_contour_ordering(obj_bot_bh_reg.poly);


%------------------------------------------------------------------------------------------------------------------
% Alle Stützstellen der Objektränder in T.Points sammeln
%------------------------------------------------------------------------------------------------------------------
% T.Points		Liste aller Stützpunkte mit x,y und z-Koordinaten, jeder Punkt kommt nur einmal vor
%										

if colprio_base>0
	test=1;
end
if (currpart_i_tile==1)&&(currpart_i_colprio==4)&&(currpart_i_part==3)
	test=1;
end

% Jeder Punkt muss hier einzeln betrachtet werden, da in den Polygonen doppelte Punkte vorkommen können.
% obj_bot_bh_reg.dz:		Grundfarbe:     =0
%								andere Objekte: =obj_bot_bh_reg.z_bot
%										  Zuordnung der Punkte in T.Points zu:
tp_iobj_mapping	= [];			% Objektnummer iobj
tp_ib_mapping		= [];			% Index ib_obj in obj_bot_bh_reg_vert_obj(iobj,1).ib
tp_k_mapping		= [];			% Index k      in obj_bot_bh_reg_vert_obj(iobj,1).ib(ib_obj,1).xyz
T						= zeros(0,1);
T.Points				= zeros(0,3);
obj_bot_bh_reg_vert_obj	= struct;
for iobj=2:length(obj_bot_bh_reg.poly)
	% Waitbar:
	if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
		WAITBAR.t1		= clock;
		set(GV_H.text_waitbar,'String',sprintf(...
			'%s: topside triangulation: Initialize triangulation data: %g/%g',msg,iobj,length(obj_bot_bh_reg.poly)));
		drawnow;
	end
	for ib_obj	= 1:numboundaries(obj_bot_bh_reg.poly(iobj))
		[x,y]														= boundary(obj_bot_bh_reg.poly(iobj),ib_obj);
		obj_bot_bh_reg_vert_obj(iobj,1).ib(ib_obj,1).xy	= [x(1:(end-1)) y(1:(end-1))];
		if (obj_bot_bh_reg.colprio(iobj)>colprio_base)||(mod(obj_bot_bh_reg.srftype(iobj),100)==0)
			% - colprio>colprio_base ==> dz ist gleich z_bot (Unterseite des höherliegenden Teils) ODER
			% - Die Oberfläche folgt dem Gelände
			obj_bot_bh_reg_vert_obj(iobj,1).ib(ib_obj,1).xyz	= add_z_2_poly(...
				colprio_base,...
				obj_bot_bh_reg_vert_obj(iobj,1).ib(ib_obj,1).xy,...
				obj_bot_bh_reg.zmin(iobj),...
				obj_bot_bh_reg.dz(iobj),...
				obj_bot_bh_reg.zbotmax(iobj),...
				obj_bot_bh_reg.colno(iobj),...
				PP_local,ELE_local,poly_legbgd);
		else
			% - colprio=colprio_base ==> dz gibt die Anhebung relativ zu dem Gelände an UND
			% - Die Oberfläche ist eben (srftype~=xx0: Vordergrund von Texten und Symbolen)
			obj_bot_bh_reg_vert_obj(iobj,1).ib(ib_obj,1).xyz	= [obj_bot_bh_reg_vert_obj(iobj,1).ib(ib_obj,1).xy ...
				(obj_bot_bh_reg.zmax(iobj)+...
				obj_bot_bh_reg.dz(iobj))*ones(size(obj_bot_bh_reg_vert_obj(iobj,1).ib(ib_obj,1).xy,1),1)];
		end
		% Alle Punkte zu T.Points hinzufügen:
		kmax					= size(obj_bot_bh_reg_vert_obj(iobj,1).ib(ib_obj,1).xyz,1);
		T.Points				= [T.Points       ;obj_bot_bh_reg_vert_obj(iobj,1).ib(ib_obj,1).xyz];
		tp_iobj_mapping	= [tp_iobj_mapping;iobj  *ones(kmax,1)                         ];
		tp_ib_mapping		= [tp_ib_mapping	;ib_obj*ones(kmax,1)                         ];
		tp_k_mapping		= [tp_k_mapping	;(1:kmax)'                                   ];
	end
end

% Testplots:
if testplot_obj_bot_bh_reg==1
	
	if ~isempty(testplot_xylimits)
		iobj_v			= 1;
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		[xb_poly_xylimits,yb_poly_xylimits]		= boundary(poly_xylimits);
		for iobj=1:length(obj_bot_bh_reg.poly)
			if overlaps(obj_bot_bh_reg.poly(iobj),poly_xylimits)
				iobj_v	= [iobj_v;iobj];
			end
		end
		iobj_v	= unique(iobj_v);
		imax_obj	= length(iobj_v);
	else
		imax_obj	= length(obj_bot_bh_reg.poly);
		iobj_v	= (1:imax_obj)';
	end
	m_obj		= ceil(sqrt(imax_obj+1));
	n_obj		= ceil((imax_obj+1)/m_obj);
	hf=figure(100250);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','obj_bot_bh_reg');
	set(hf,'NumberTitle','off');
	
	iobj_v_ha1_obj_bot_bh_reg	= iobj_v;
	for k=1:length(iobj_v)
		iobj	= iobj_v(k);
		ha=subplot(m_obj,n_obj,k);
		ha1_obj_bot_bh_reg(iobj)=ha;
		hold(ha,'on');
		axis(ha,'equal');
		plot(ha,obj_bot_bh_reg.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_bot_bh_reg.colno(iobj)).rgb/255);
		i	= find(tp_iobj_mapping==iobj);
		plot(ha,T.Points(i,1),T.Points(i,2),'LineWidth',2,'LineStyle','none',...
			'Color','k','Marker','.','MarkerSize',5);
		if ~isempty(testplot_xylimits)
			plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
			set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
			set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
		else
			set(ha,'XLim',[xmin_mm xmax_mm]);
			set(ha,'YLim',[ymin_mm ymax_mm]);
		end
		title(sprintf('i=%g, cp=%g, st=%g\ndz=%g\nzb=%g, zbmax=%g\nzmin=%1.4f, zmax=%1.4f',...
			iobj,obj_bot_bh_reg.colprio(iobj),obj_bot_bh_reg.srftype(iobj),...
			obj_bot_bh_reg.dz(iobj),...
			obj_bot_bh_reg.z_bot(iobj),obj_bot_bh_reg.zbotmax(iobj),...
			obj_bot_bh_reg.zmin(iobj),obj_bot_bh_reg.zmax(iobj)),'Interpreter','none')
	end
	
	ha			= subplot(m_obj,n_obj,imax_obj+1);
	hold(ha,'on');
	axis(ha,'equal');
	imax_obj	= length(obj_bot_bh_reg.poly);
	for iobj=2:imax_obj
		plot(ha,obj_bot_bh_reg.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_bot_bh_reg.colno(iobj)).rgb/255);
	end
	if ~isempty(testplot_xylimits)
		plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
	end
	set(ha,'XLim',[xmin_mm xmax_mm]);
	set(ha,'YLim',[ymin_mm ymax_mm]);
	title(sprintf('i=2...%g',imax_obj),'Interpreter','none')
	
end

if testplot_obj_bot_bh_reg_1plot==1
	hf=figure(100260);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','obj_bot_bh_reg');
	set(hf,'NumberTitle','off');
	ha							= axes(hf);
	ha2_obj_bot_bh_reg	= ha;
	hold(ha,'on');
	axis(ha,'equal');
	for iobj=2:length(obj_bot_bh_reg.poly)
		plot(ha,obj_bot_bh_reg.poly(iobj),...
			'LineWidth',1,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_bot_bh_reg.colno(iobj)).rgb/255);
	end
	for iobj=length(obj_bot_bh_reg.poly):-1:2
		if ~isequal(obj_bot_bh_reg.colprio(iobj),colprio_base)
			color			= PP_local.color(obj_bot_bh_reg.colno(iobj)).rgb/255;
			linewidth	= 2;
			marker		= plot_marker_v{vindexrest(iobj,length(plot_marker_v))};
			markersize	= 12;
			plot(ha,obj_bot_bh_reg.poly(iobj).Vertices(:,1),obj_bot_bh_reg.poly(iobj).Vertices(:,2),...
				'LineWidth',linewidth,'LineStyle','none','Color',color,'Marker',marker,'MarkerSize',markersize);
		end
	end
	for iobj=length(obj_bot_bh_reg.poly):-1:2
		if isequal(obj_bot_bh_reg.colprio(iobj),colprio_base)
			color			= 'k';
			linewidth	= 2;
			marker		= '.';
			markersize	= 15;
			plot(ha,obj_bot_bh_reg.poly(iobj).Vertices(:,1),obj_bot_bh_reg.poly(iobj).Vertices(:,2),...
				'LineWidth',linewidth,'LineStyle','none','Color',color,'Marker',marker,'MarkerSize',markersize);
		end
	end
	if ~isempty(testplot_xylimits)
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		[xb_poly_xylimits,yb_poly_xylimits]		= boundary(poly_xylimits);
		plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
	end
	set(ha,'XLim',[xmin_mm xmax_mm]);
	set(ha,'YLim',[ymin_mm ymax_mm]);
	set(ha,'Clipping','off');
end


%------------------------------------------------------------------------------------------------------------------
% Triangulation der senkrechten Flächen zwischen den Polygonrändern
%------------------------------------------------------------------------------------------------------------------
% -	alle Ränder der Polygone Punkt für Punkt durchgehen.
% -	wenn bei zwei aufeinanderfolgenden Punkten es übereinstimmende Punkte eines anderen Polygons gibt: "vernähen"
% Ergebnis:
% T.ConnectivityList:		Ränder der Objekte

if colprio_base>0
	test=1;
end
if (currpart_i_tile==1)&&(currpart_i_colprio==4)&&(currpart_i_part==3)
	test=1;
end

% Testplots:
if testplot_obj_bot_bh_reg_1plot==1
	testplot_lokal	= 0;				% 0: off / 1: show current points / 2: show all points
else
	testplot_lokal	= 0;
end
if testplot_lokal==1
	hvertex1a	= plot(ha2_obj_bot_bh_reg,xmin_mm,ymin_mm,...
		'LineWidth',2,'LineStyle','none','Color','r','Marker','>','MarkerSize',20);
	hvertex1b	= plot(ha2_obj_bot_bh_reg,xmin_mm,ymin_mm,...
		'LineWidth',2,'LineStyle','none','Color','r','Marker','<','MarkerSize',20);
	hvertex2a	= plot(ha2_obj_bot_bh_reg,xmin_mm,ymin_mm,...
		'LineWidth',2,'LineStyle','none','Color','g','Marker','>','MarkerSize',8);
	hvertex2b	= plot(ha2_obj_bot_bh_reg,xmin_mm,ymin_mm,...
		'LineWidth',2,'LineStyle','none','Color','g','Marker','<','MarkerSize',8);
end

% Alle Stützstellen aller Objekte nacheinander durchsuchen:
T.ConnectivityList				= [];
no_testplot_cursordata_k1ab	= 0;
no_testplot_cursordata_k2ab	= 0;
for iobj1=2:size(obj_bot_bh_reg_vert_obj,1)
	for ib_obj1	= 1:size(obj_bot_bh_reg_vert_obj(iobj1,1).ib,1)
		% vertices of object 1, boundary ib_obj1:
		for k1a=1:size(obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy,1)
			tp_mapping_equalto_iobj1		= (tp_iobj_mapping==iobj1);
			tp_mapping_notequalto_iobj1	= ~tp_mapping_equalto_iobj1;
			
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1	= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: topside triangulation: triangulation of the vertical surfaces %g/%g %g/%g %g/%g',msg,...
					iobj1,size(obj_bot_bh_reg_vert_obj,1),...
					ib_obj1,size(obj_bot_bh_reg_vert_obj(iobj1,1).ib,1),...
					k1a,size(obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy,1)));
				drawnow;
			end
			
			% k1a, k1b:		two consecutive vertices in obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy:
			% i_tp_k1a:		to k1a corresponding row number in T.Points
			% i_tp_k1b:		to k1b corresponding row number in T.Points
			k1b				= vindexrest(k1a+1,size(obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy,1));
			% Distances of all points to the vertices k1a and k1b of object iobj1:
			distance_k1a_v	= sqrt(...
				(T.Points(:,1)-obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,1)).^2+...
				(T.Points(:,2)-obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,2)).^2);
			distance_k1b_v	= sqrt(...
				(T.Points(:,1)-obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,1)).^2+...
				(T.Points(:,2)-obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,2)).^2);
			% Search only for points in T.Points that belong to object 1:
			distance_k1a_iobj1_v											= distance_k1a_v;
			distance_k1b_iobj1_v											= distance_k1b_v;
			distance_k1a_iobj1_v(tp_mapping_notequalto_iobj1)	= 1e10;
			distance_k1b_iobj1_v(tp_mapping_notequalto_iobj1)	= 1e10;
			[distance_k1a_iobj1_min,i_tp_k1a]						= min(distance_k1a_iobj1_v);
			[distance_k1b_iobj1_min,i_tp_k1b]						= min(distance_k1b_iobj1_v);
			
			% Test (set preferences - text display - numeric format: long):
			testplot				= 0;
			show_testplotdata	= 0;
			if testplot~=0
				cursordata1	   = [4.798145330081461e+02 1.906540112159914e+02 10.655111937805827];
				% cursordata1  = [4.798145095381461e+02 1.906540211359914e+02 10.655111937805827];
				% cursordata2	= [4.798145330081461e+02 1.906540112159914e+02 21.611231251169599];
				cursordata2	   = [4.793522225735816e+02 1.908494405831716e+02 10.655111937805827];
				% cursordata1	= [4.793522225735816e+02 1.908494405831716e+02 21.599606110354394];
				cursordata1	= [1 1 1]*1e6;
				cursordata2	= [1 1 1]*1e6;
				tol_test			= 1e-3;
				if   ((abs(obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,1)-cursordata1(1))<tol_test)&&...
						(abs(obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,2)-cursordata1(2))<tol_test)&&...
						(abs(obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,1)-cursordata2(1))<tol_test)&&...
						(abs(obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,2)-cursordata2(2))<tol_test)     )||(...
						(abs(obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,1)-cursordata2(1))<tol_test)&&...
						(abs(obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,2)-cursordata2(2))<tol_test)&&...
						(abs(obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,1)-cursordata1(1))<tol_test)&&...
						(abs(obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,2)-cursordata1(2))<tol_test)     )||(...
						(iobj1==49)&&(ib_obj1==16)&&(k1a==145))
					% 						(abs(obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,2)-cursordata1(2))<tol_test)     )
					show_testplotdata					= 1;
					no_testplot_cursordata_k1ab	= no_testplot_cursordata_k1ab+1;
					hftest	= figure(54297680+no_testplot_cursordata_k1ab);
					clf(hftest,'reset');
					set(hftest,'Tag','maplab3d_figure');
					hatest_k1	= gca;
					hold(hatest_k1,'on');
					plot(hatest_k1,obj_bot_bh_reg.poly(iobj1),...
						'DisplayName','obj_bot_bh_reg.poly(iobj1)');
					plot(hatest_k1,...
						obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(:,1),...
						obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(:,2),'.-b',...
						'DisplayName','obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1.xy(:,:))');
					plot(hatest_k1,...
						obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,1),...
						obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,2),...
						'Color','m','LineWidth',2,'Marker','+','MarkerSize',12,...
						'DisplayName','obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,:)');
					plot(hatest_k1,...
						obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,1),...
						obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,2),...
						'Color','c','LineWidth',2,'Marker','+','MarkerSize',12,...
						'DisplayName','obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,:)');
					title_k1_str	= sprintf('iobj1=%g, ib_obj1=%g, k1a=%g, k1b=%g',...
						iobj1,ib_obj1,k1a,k1b);
					title(hatest_k1,title_k1_str,'Interpreter','none');
					% axis(hatest_k1,'equal');
					setbreakpoint	= 1;
				end
			end
			
			if (distance_k1a_iobj1_min<tol_1)&&(distance_k1b_iobj1_min<tol_1)&&(i_tp_k1a~=i_tp_k1b)
				
				% Testplots:
				if testplot_lokal==1
					set(hvertex1a,...
						'XData',obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,1),...
						'YData',obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,2));
					set(hvertex1b,...
						'XData',obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,1),...
						'YData',obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,2));
					set(hvertex2a,'XData',[],'YData',[]);
					set(hvertex2b,'XData',[],'YData',[]);
				end
				if testplot_lokal==2
					plot(ha2_obj_bot_bh_reg,...
						obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,1),...
						obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,2),...
						'LineWidth',2,'LineStyle','none','Color','r','Marker','>','MarkerSize',20);
					plot(ha2_obj_bot_bh_reg,...
						obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,1),...
						obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,2),...
						'LineWidth',2,'LineStyle','none','Color','r','Marker','<','MarkerSize',20);
				end
				
				% Alle Stützstellen aller Objekte außer iobj1 nacheinander durchsuchen, ob die Punkte mit den Indices
				% k1a und k1b noch einmal in einem anderen Objekt existieren:
				% k2a, k2b:		two vertices in obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy:
				% i_tp_k2a:		to k2a corresponding row number in T.Points
				% i_tp_k2b:		to k2b corresponding row number in T.Points
				
				% Es werden nur Punkte in T.Points berücksichtigt, die:
				% -	nicht zu iobj1 gehören
				% -	einen Abstand zu den Punkten k1a, k1b von weniger als tol_1 haben
				% i_tp_k2:		Vektor aller Indices der Punkte in T.Points, die diese Bedingungen erfüllen
				distance_k1a_v(tp_mapping_equalto_iobj1)	= 1e10;
				distance_k1b_v(tp_mapping_equalto_iobj1)	= 1e10;
				i_tp_k2	= find((abs(distance_k1a_v)<tol_1)|(abs(distance_k1b_v)<tol_1));
				if show_testplotdata==1
					title_k1_str	= sprintf('%s\ni_tp_k2= %s',title_k1_str,...
						num2str(i_tp_k2(:)'));
					title(hatest_k1,title_k1_str,'Interpreter','none');
					setbreakpoint	= 1;
				end
				% Bedingung: In der gesuchten Objektnummer iobj2 muss es zwei übereinstimmende Punkte geben.
				
				i_tp_k2ab_found	= false;
				if size(i_tp_k2,1)>=2
					iobj2_i_tp_k2			= tp_iobj_mapping(i_tp_k2);
					iobj2_unique_v			= unique(iobj2_i_tp_k2);
					for i_iobj2_v=1:length(iobj2_unique_v)
						iobj2_test			= iobj2_unique_v(i_iobj2_v);
						i_tp_k2_iobj2		= i_tp_k2(iobj2_i_tp_k2==iobj2_test);
						
						% In der gesuchten Objektnummer iobj2 gibt es zwei übereinstimmende Punkte:
						% Suche zwei Punkte, die evtl. noch bestimmte Bedingungen erfüllen (hier nicht mehr nötig):
						[~,i1]	= min(distance_k1a_v(i_tp_k2_iobj2));
						[~,i2]	= min(distance_k1b_v(i_tp_k2_iobj2));
						i_tp_k2a_test		= i_tp_k2_iobj2(i1);
						i_tp_k2b_test		= i_tp_k2_iobj2(i2);
						iobj2_k2a_test		= tp_iobj_mapping(i_tp_k2a_test,1);
						iobj2_k2b_test		= tp_iobj_mapping(i_tp_k2b_test,1);
						ib_obj2_k2a_test	= tp_ib_mapping(i_tp_k2a_test,1);
						ib_obj2_k2b_test	= tp_ib_mapping(i_tp_k2b_test,1);
						if    (iobj2_k2a_test  ==iobj2_k2b_test  )&&...
								(ib_obj2_k2a_test==ib_obj2_k2b_test)
							% Die beiden Punkte gehören zu demselben Objekt iobj2 und zu derselben boundary:
							iobj2					= iobj2_k2a_test;
							ib_obj2				= ib_obj2_k2a_test;
							k2a_test				= tp_k_mapping(i_tp_k2a_test,1);
							k2b_test				= tp_k_mapping(i_tp_k2b_test,1);
							
							% Problem: in obj2 können zusätzliche Punkte existieren, dies es in obj1 nicht gibt.
							% Z. B.: k2a=191, k2b=193, der Punkt k2=192 liegt auf der Verbindungslinie
							%        zwischen k2a und k2b.
							% Die beiden Punkte i_tp_k2a_test und i_tp_k2b_test sollen daher nicht zwingend
							% aufeinander folgen. Eine zusätzliche Bedingung ist hier also nicht mehr nötig!
							% Weil ein Punkt übersprungen wird könnte dies zu offenen Rändern führen!
							vertices_are_equal	= false;
							if (distance_k1a_v(i_tp_k2a_test)<tol_1)&&(distance_k1b_v(i_tp_k2b_test)<tol_1)
								i_tp_k2a					= i_tp_k2a_test;
								i_tp_k2b					= i_tp_k2b_test;
								k2a						= k2a_test;
								k2b						= k2b_test;
								vertices_are_equal	= true;
							elseif (distance_k1a_v(i_tp_k2b_test)<tol_1)&&(distance_k1b_v(i_tp_k2a_test)<tol_1)
								i_tp_k2a					= i_tp_k2b_test;
								i_tp_k2b					= i_tp_k2a_test;
								k2a						= k2b_test;
								k2b						= k2a_test;
								vertices_are_equal	= true;
							end
							
							if vertices_are_equal
								% Die Punkte k1a/k1b sind deckungsgleich mit k2a/k2b:
								
								kmax	= size(obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy,1);
								if    (abs(k2a-k2b)==1     )||...
										(abs(k2a-k2b)==kmax-1)
									% Die beiden Punkte k2a und k2b sind aufeinander folgend:
									i_tp_k2ab_found	= true;
									k2_v			= [k2a     ;k2b     ];
									i_tp_k2_v	= [i_tp_k2a;i_tp_k2b];
								else
									% Die beiden Punkte k2a und k2b sind nicht aufeinander folgend.
									% Dies wird zugelassen. Da die Differenz somit nicht =1 ist, muss geprüft werden,
									% in welcher Richtung sich die restlichen Punkte ZWISCHEN k2a und k2b befinden.
									% Bedingung: Die Strecke von Punkt k2a zu Punkt k2b muss deckungsgleich sein
									%            mit der Strecke von Punkt k1a zu Punkt k1b.
									if testplot~=0
										if (show_testplotdata~=0)||...
												(length(k2_v)>2)
											set_breakpoint	= 1;
										end
									end
									
									% k1a, k1b:
									k1_v	= [k1a;k1b];
									c_k1_v	= ...
										1* obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1_v,1)+...
										1i*obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1_v,2);
									dc1		= diff(c_k1_v);
									ang1	= angle(dc1);
									
									% 1. Möglichkeit: k2a:k2b
									if k2a<k2b
										k2_v	= vindexrest(k2a:k2b,kmax);
									else
										k2_v	= vindexrest(k2a:(k2b+kmax),kmax);
									end
									c_k2_v	= ...
										1* obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2_v,1)+...
										1i*obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2_v,2);
									dc2_v		= diff(c_k2_v);
									ang2_v	= angle(dc2_v);
									if ~any(abs(ang2_v-ang1)>GV.tol_angle)										% !!!!!!!!!!!!!!
										% Die Strecken sind deckungsgleich:
										% Abfrage mit tol_1 kann dazu führen, dass Flächen nicht trianguliert werden!
										% In einem speziellen Fall musste folgende Kombination zugelassen werden:
										% abs(ang2_v-ang1) =
										%    1.0e-04 *
										%    0.475207118748600
										%    0.000024125461628
										i_tp_k2ab_found	= true;
										i_tp_k2_v			= zeros(size(k2_v));
										for i_k2v=1:size(k2_v,1)
											k2				= k2_v(i_k2v);
											i_tp_k2_v(i_k2v,1)	= find(...
												(tp_iobj_mapping==iobj2  )&...
												(tp_ib_mapping  ==ib_obj2)&...
												(tp_k_mapping   ==k2     )     ,1);
										end
									else
										% Die Strecken sind nicht deckungsgleich:
										% 2. Möglichkeit: k2a:-1:k2b
										if k2a>k2b
											k2_v	= vindexrest(k2a:-1:k2b,kmax);
										else
											k2_v	= vindexrest((k2a+kmax):-1:k2b,kmax);
										end
										c_k2_v	= ...
											1* obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2_v,1)+...
											1i*obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2_v,2);
										dc2_v		= diff(c_k2_v);
										ang2_v	= angle(dc2_v);
										if ~any(abs(ang2_v-ang1)>GV.tol_angle)									% !!!!!!!!!!!!!!
											% Die Strecken sind deckungsgleich:
											% Abfrage mit tol_1 kann dazu führen, dass Flächen nicht trianguliert werden!
											i_tp_k2ab_found	= true;
											i_tp_k2_v			= zeros(size(k2_v));
											for i_k2v=1:size(k2_v,1)
												k2				= k2_v(i_k2v);
												i_tp_k2_v(i_k2v,1)	= find(...
													(tp_iobj_mapping==iobj2  )&...
													(tp_ib_mapping  ==ib_obj2)&...
													(tp_k_mapping   ==k2     )     ,1);
											end
										end
									end
								end
								
								if testplot~=0
									if (show_testplotdata~=0)||...
											((length(k2_v)>2)&&i_tp_k2ab_found)
										show_testplotdata					= 1;
										no_testplot_cursordata_k2ab	= no_testplot_cursordata_k2ab+1;
										hftest	= figure(793819693+no_testplot_cursordata_k2ab);
										clf(hftest,'reset');
										set(hftest,'Tag','maplab3d_figure');
										hatest_k2	= gca;
										hold(hatest_k2,'on');
										plot(hatest_k2,obj_bot_bh_reg.poly(iobj1),...
											'DisplayName','obj_bot_bh_reg.poly(iobj1)');
										plot(hatest_k2,...
											obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(:,1),...
											obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(:,2),'.-b',...
											'DisplayName','obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1.xy(:,:))');
										plot(hatest_k2,...
											obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,1),...
											obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,2),...
											'Color','m','LineWidth',2,'Marker','+','MarkerSize',12,...
											'DisplayName','obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,:)');
										plot(hatest_k2,...
											obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,1),...
											obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,2),...
											'Color','c','LineWidth',2,'Marker','+','MarkerSize',12,...
											'DisplayName','obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,:)');
										plot(hatest_k2,...
											obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(:,1),...
											obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(:,2),'.--g',...
											'DisplayName','obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(:,:)');
										plot(hatest_k2,...
											obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2a,1),...
											obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2a,2),...
											'Color','m','LineWidth',2,'Marker','x','MarkerSize',12,...
											'DisplayName','obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2a,1)');
										plot(hatest_k2,...
											obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2b,1),...
											obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2b,2),...
											'Color','c','LineWidth',2,'Marker','x','MarkerSize',12,...
											'DisplayName','obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2b,1)');
										testplot_title_str	= sprintf([...
											'iobj1=%g, ib_obj1=%g, k1a=%g, k1b=%g\n',...
											'iobj2=%g, ib_obj1=%g, k2a=%g, k2b=%g, kmax=%g'],...
											iobj1,ib_obj1,k1a,k1b,...
											iobj2,ib_obj2,k2a_test,k2b_test,size(obj_bot_bh_reg.poly(iobj2).Vertices,1));
										title(hatest_k2,testplot_title_str,'Interpreter','none');
										legend('Interpreter','none');
										setbreakpoint			= 1;
									end
								end
								
							end
						end
						if i_tp_k2ab_found
							break
						end
					end
					
				end
				
				% Ränder der Objekte "vernähen":
				if i_tp_k2ab_found
					% Der Punkt obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2a,:) deckt sich mit
					% dem Punkt obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1a,:)                und
					% Der Punkt obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2b,:) deckt sich mit
					% dem Punkt obj_bot_bh_reg_vert_obj(iobj1,1).ib(ib_obj1,1).xy(k1b,:)
					% i_tp_k1a:		to k1a corresponding row number in T.Points
					% i_tp_k1b:		to k1b corresponding row number in T.Points
					% i_tp_k2a:		to k2a corresponding row number in T.Points
					% i_tp_k2b:		to k2b corresponding row number in T.Points
					
					% Sicherheitsabfrage, ob sich die gefundenen Punkte tatsächlich decken:
					testa1=abs(T.Points(i_tp_k1a,1)-T.Points(i_tp_k2a,1));
					testa2=abs(T.Points(i_tp_k1a,2)-T.Points(i_tp_k2a,2));
					testb1=abs(T.Points(i_tp_k1b,1)-T.Points(i_tp_k2b,1));
					testb2=abs(T.Points(i_tp_k1b,2)-T.Points(i_tp_k2b,2));
					if (testa1>tol_1)||(testa2>tol_1)||(testb1>tol_1)||(testb2>tol_1)
						iobj1
						ib_obj1
						k1a
						iobj2
						ib_obj2
						testa1
						testa2
						testb1
						testb2
						i_tp_k1a
						i_tp_k1b
						i_tp_k2a
						i_tp_k2b
						tp_k1a	= T.Points(i_tp_k1a,:)
						tp_k2a	= T.Points(i_tp_k2a,:)
						tp_k1b	= T.Points(i_tp_k1b,:)
						tp_k2b	= T.Points(i_tp_k2b,:)
						errormessage;
					end
					
					% Punkte "vernähen":
					if length(k2_v)==2
						% Vorherige Version, als Vorlage gelassen:
						%   	1)	k2a     k2b		2)	k2a--<--k2b
						%         | \                 \     |
						%         v   \                 \   ^
						%         |     \                 \ |
						%      	k1a-->--k1b	   	k1a     k1b
						if abs(T.Points(i_tp_k1a,3)-T.Points(i_tp_k2a,3))>tol_1
							T.ConnectivityList	= [T.ConnectivityList;...
								i_tp_k1a i_tp_k1b i_tp_k2a];			% 1)
						end
						if abs(T.Points(i_tp_k1b,3)-T.Points(i_tp_k2b,3))>tol_1
							T.ConnectivityList	= [T.ConnectivityList;...
								i_tp_k1b i_tp_k2b i_tp_k2a];			% 2)
						end
					else
						% There are always only 2 vertices k1a and k1b, but sometimes more vertices k2_v=k2a...k2b:
						%   1) k2_v(1)   k2_v(2)      k2_v(end)	2)      k2_v(end)
						%   	  	k2a                     k2b		   k2a----<---X--<--X---<--k2b
						%         |  \                                   \       \     \      |
						%         |    \                                   \       \    |     |
						%         |       \                                   \     \   \     |
						%         v         \                                   \     \  |    ^
						%         |           \                                   \    \  \   |
						%         |             \                                   \   \  |  |
						%         |               \                                   \   \ \ |
						%         |                 \                                   \  \| |
						%         |                    \                                   \ \|
						%      	k1a--------->-----------k1b	      k1a                     k1b
						if abs(T.Points(i_tp_k1a,3)-T.Points(i_tp_k2_v(1,1),3))>tol_1
							T.ConnectivityList	= [T.ConnectivityList;...
								i_tp_k1a i_tp_k1b i_tp_k2_v(1,1)];								% 1) (i_tp_k2_v(1,1)=i_tp_k2a)
						end
						for i_k2v=1:(length(k2_v)-1)
							if (abs(T.Points(i_tp_k1a,3)-T.Points(i_tp_k2a,3))>tol_1)||(i_k2v>1)
								T.ConnectivityList	= [T.ConnectivityList;...
									i_tp_k1b i_tp_k2_v(i_k2v+1,1) i_tp_k2_v(i_k2v,1)];		% 2) (i_tp_k2_v(end,1)=i_tp_k2b)
							end
						end
					end
					
					% Testplots:
					if show_testplotdata~=0
						plot(hatest_k2,T.Points(i_tp_k2_v,1),T.Points(i_tp_k2_v,2),...
							'Color','r','LineWidth',2,'Marker','.','MarkerSize',20,...
							'DisplayName','triangulation');
						legend('Interpreter','none');		% ,'Location','best'
						setbreakpoint			= 1;
					end
					if testplot_lokal==1
						set(hvertex2a,...
							'XData',obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2a,1),...
							'YData',obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2a,2));
						set(hvertex2b,...
							'XData',obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2b,1),...
							'YData',obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2b,2));
					end
					if testplot_lokal==2
						plot(ha2_obj_bot_bh_reg,...
							obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2a,1),...
							obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2a,2),...
							'LineWidth',2,'LineStyle','none','Color','g','Marker','>','MarkerSize',8);
						plot(ha2_obj_bot_bh_reg,...
							obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2b,1),...
							obj_bot_bh_reg_vert_obj(iobj2,1).ib(ib_obj2,1).xy(k2b,2),...
							'LineWidth',2,'LineStyle','none','Color','g','Marker','<','MarkerSize',8);
					end
					
				end
			end
		end
	end
end


%------------------------------------------------------------------------------------------------------------------
% Triangulation der horizontalen Flächen zwischen den Polygonrändern
%------------------------------------------------------------------------------------------------------------------
% -	schrittweise die Grenzen der Polygone nach innen verlagern und dazwischen triangulieren
% Ergebnis:
% T.Points					Erweiterte Triangulationsdaten
% T.ConnectivityList

if colprio_base>0
	test=1;
end
if (currpart_i_tile==1)&&(currpart_i_colprio==4)&&(currpart_i_part==3)
	test=1;
end

% Testplots:
if testplot_triang_hareas==1
	hf=figure(100270);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','T areas');
	set(hf,'NumberTitle','off');
	ha1	= subplot(2,2,1);
	set(ha1,'XLim',[xmin_mm xmax_mm]);
	set(ha1,'YLim',[ymin_mm ymax_mm]);
	axis(ha1,'equal');
	ha2	= subplot(2,2,2);
	set(ha2,'XLim',[xmin_mm xmax_mm]);
	set(ha2,'YLim',[ymin_mm ymax_mm]);
	axis(ha2,'equal');
	ha3	= subplot(2,2,3);
	view(ha3,3);
	ha4	= subplot(2,2,4);
	view(ha4,3);
end

% Joint type for buffer boundaries, specified as one of the following:
% 'round'	Round out boundary corners.
% 'square'	Square off boundary corners.
% 'miter'	Limit the ratio between the distance a joint vertex is moved and the buffer distance to 3.
%				This limit prevents excessive pointiness.
jointtype='square';		% 'round' (default) | 'square' | 'miter'
% Miter limit, specified as a positive numeric scalar greater than or equal to 2. The miter limit is the ratio
% between the distance a joint vertex is moved and the buffer distance. Setting a miter limit controls the
% pointiness of boundary joints.
miterlimit=2;
% Distance between the inner polygons:
dmax_start	= min([...
	ELE_local.elefiltset(ifs_tb,1).dx_mm ...
	ELE_local.elefiltset(ifs_tb,1).dy_mm]);
for iobj=2:length(obj_bot_bh_reg.poly)
	
	% Waitbar:
	if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
		WAITBAR.t1	= clock;
		set(GV_H.text_waitbar,'String',sprintf(...
			'%s: topside triangulation: triangulation of the horizontal surfaces %g/%g',msg,...
			iobj,length(obj_bot_bh_reg.poly)));
		drawnow;
	end
	
	dmax								= dmax_start;
	poly_out							= obj_bot_bh_reg.poly(iobj);
	poly_out_is_inner_polygon	= 0;
	while dmax>0
		icolspec	= PP_local.color(obj_bot_bh_reg.colno(iobj)).spec;
		if ((PP_local.colorspec(icolspec).bottom_version~=1)||(obj_bot_bh_reg.colprio(iobj)==colprio_base))&&...
				(mod(obj_bot_bh_reg.srftype(iobj),100)==0)
			% - Die Unterseite ist nicht eben oder die Farbe ist die Grundfarbe UND
			% - Die Oberseite folgt dem Gelände:
			% Mit Stützstellen ausfüllen:
			
			% poly_in: poly_out nach innen verschieben:
			if GV.warnings_off
				warning('off','MATLAB:polyshape:boundary3Points');
				warning('off','MATLAB:polyshape:repairedBySimplify');
				warning('off','MATLAB:polyshape:boolOperationFailed');
				warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
			end
			if strcmp(jointtype,'miter')
				poly_in	= polybuffer(poly_out,-dmax,'JointType',jointtype,'MiterLimit',miterlimit);
			else
				poly_in	= polybuffer(poly_out,-dmax,'JointType',jointtype);
			end
			if numboundaries(poly_in)==0
				if abs(dmax-dmax_start)<tol_1
					% 2. Versuch mit halbem Abstand:
					dmax	= dmax_start/2;
					if strcmp(jointtype,'miter')
						poly_in	= polybuffer(poly_out,-dmax,'JointType',jointtype,'MiterLimit',miterlimit);
					else
						poly_in	= polybuffer(poly_out,-dmax,'JointType',jointtype);
					end
					if numboundaries(poly_in)==0
						% letzten Durchlauf starten:
						dmax	= 0;
					end
				else
					% letzten Durchlauf starten:
					dmax	= 0;
				end
			end
			if GV.warnings_off
				warning('on','MATLAB:polyshape:boundary3Points');
				warning('on','MATLAB:polyshape:repairedBySimplify');
				warning('on','MATLAB:polyshape:boolOperationFailed');
				warning('on','MATLAB:triangulation:PtsNotInTriWarnId');
			end
			if numboundaries(poly_in)>0
				% Calcuate the minimum distance between points:
				dmin			= dmax_start/3;
				% Set the max. and min. distance between points:
				% In the case there remains no data, switch off the warnings in order to avoid confusion:
				poly_in	= changeresolution_poly(poly_in,dmax,dmin,[]);
				% Possibly there remains no data in polyout:
				if GV.warnings_off
					warning('off','MATLAB:polyshape:boundary3Points');
					warning('off','MATLAB:polyshape:repairedBySimplify');
					warning('off','MATLAB:polyshape:boolOperationFailed');
					warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
				end
				if numboundaries(poly_in)>0
					poly		= addboundary(poly_out,poly_in.Vertices,'KeepCollinearPoints',true);
				else
					% letzter Durchlauf, ohne poly_in:
					poly		= poly_out;
					dmax	= 0;
				end
				if GV.warnings_off
					warning('on','MATLAB:polyshape:boundary3Points');
					warning('on','MATLAB:polyshape:repairedBySimplify');
					warning('on','MATLAB:polyshape:boolOperationFailed');
					warning('on','MATLAB:triangulation:PtsNotInTriWarnId');
				end
			else
				% letzter Durchlauf, ohne poly_in:
				poly		= poly_out;
			end
		else
			% Nur ein Durchlauf, nicht mit Stützstellen auffüllen:
			poly		= poly_out;
			dmax	= 0;
		end
		% Triangulation zwischen poly_in und poly_out:
		if numboundaries(poly)==0
			errormessage;
		end
		t_poly1		= triangulation(poly);
		% t_poly2: because tshe property 'Points' of t_poly1 is read only
		t_poly2							= [];
		t_poly2.Points					= t_poly1.Points;
		t_poly2.ConnectivityList	= t_poly1.ConnectivityList;
		
		if (obj_bot_bh_reg.colprio(iobj)>colprio_base)||(mod(obj_bot_bh_reg.srftype(iobj),100)==0)
			% - colprio>colprio_base ==> dz ist gleich z_bot (Unterseite des höherliegenden Teils) ODER
			% - Die Oberfläche folgt dem Gelände
			t_poly2.Points	= add_z_2_poly(colprio_base,...					% add the z-value
				t_poly2.Points,...
				obj_bot_bh_reg.zmin(iobj),...
				obj_bot_bh_reg.dz(iobj),...
				obj_bot_bh_reg.zbotmax(iobj),...
				obj_bot_bh_reg.colno(iobj),...
				PP_local,ELE_local,poly_legbgd);
		else
			% - colprio=colprio_base ==> dz gibt die Anhebung relativ zu dem Gelände an UND
			% - Die Oberfläche ist eben (srftype~=xx0: Vordergrund von Texten und Symbolen)
			t_poly2.Points	= [t_poly2.Points ...
				(obj_bot_bh_reg.zmax(iobj)+obj_bot_bh_reg.dz(iobj))*ones(size(t_poly2.Points,1),1)];
		end
		
		% t_poly: will be modified:
		t_poly		= t_poly2;
		% Add the results to T:
		if testplot_triang_hareas==1
			cla(ha1);
			cla(ha2);
			cla(ha3);
			cla(ha4);
			hold(ha2,'on');
			plot(ha2,t_poly2.Points(:,1),t_poly2.Points(:,2),...
				'LineWidth',1,'LineStyle','none','Color','k','Marker','x','MarkerSize',11);
			title(ha2,sprintf('iobj=%g',iobj),'Interpreter','none');
		end
		if poly_out_is_inner_polygon==0
			for i_t=1:size(t_poly.Points,1)
				% Row of current point in T.Points:
				i_TP		= find(...
					(abs(T.Points(:,1)-t_poly.Points(i_t,1))<tol_1)&...
					(abs(T.Points(:,2)-t_poly.Points(i_t,2))<tol_1)&...
					(abs(T.Points(:,3)-t_poly.Points(i_t,3))<tol_1)    );
				if isempty(i_TP)
					% The current point with the index i_t does not yet exist in T.Points:
					T.Points		= [T.Points;t_poly.Points(i_t,:)];
					i_TP			= size(T.Points,1);
					if testplot_triang_hareas==1
						plot(ha2,T.Points(i_TP,1),T.Points(i_TP,2),...
							'LineWidth',1,'LineStyle','none','Color','b','Marker','.','MarkerSize',15);
					end
				elseif length(i_TP)==1
					% The current point with the index i_t already exists in T.Points:
					if testplot_triang_hareas==1
						plot(ha2,T.Points(i_TP,1),T.Points(i_TP,2),...
							'LineWidth',1,'LineStyle','none','Color','r','Marker','.','MarkerSize',15);
					end
				else
					% Zur Zeit lassen sich Ungenauigkeiten nicht vermeiden: kein Abbruch.
					i_TP	= i_TP(1);
					% eval('i_TP,size_i_TP=size(i_TP)');
					% for i=1:length(i_TP)
					% 	fprintf(1,'T.Points(%g,1)=[%g   %g   %g]\n',i_TP(i),...
					% 		T.Points(i_TP(i),1),...
					% 		T.Points(i_TP(i),2),...
					% 		T.Points(i_TP(i),3));
					% end
					% for i=2:length(i_TP)
					% 	fprintf(1,'T.Points(%g,:)-T.Points(%g,:)=[%g   %g   %g]\n',i_TP(i-1),i_TP(i),...
					% 		T.Points(i_TP(i-1),1)-T.Points(i_TP(i),1),...
					% 		T.Points(i_TP(i-1),2)-T.Points(i_TP(i),2),...
					% 		T.Points(i_TP(i-1),3)-T.Points(i_TP(i),3));
					% end
					% errormessage;
				end
				% Replace the index in t_poly.Points with the index in T.Points:
				t_poly.ConnectivityList(t_poly2.ConnectivityList==i_t)	= i_TP;
			end
		else
			t_poly.ConnectivityList	= t_poly.ConnectivityList+size(T.Points,1);
			T.Points						= [T.Points;t_poly.Points];
		end
		% Indices der neu hinzugefügten Dreiecke in T.ConnectivityList:
		i_TCL					= ...
			((size(T.ConnectivityList,1)+1):(size(T.ConnectivityList,1)+size(t_poly.ConnectivityList,1)))';
		% T.ConnectivityList erweitern:
		T.ConnectivityList	= [T.ConnectivityList;t_poly.ConnectivityList];
		% Sicherheitsabfrage:
		test1=[T.ConnectivityList(i_TCL,1);T.ConnectivityList(i_TCL,2);T.ConnectivityList(i_TCL,3)];
		test2=[t_poly2.ConnectivityList(:,1);t_poly2.ConnectivityList(:,2);t_poly2.ConnectivityList(:,3)];
		if size(unique(test1),1)~=size(unique(test2),1)
			% Dieser Fall kann eintreten, wenn z. B. ein Objekt den Kachelrand mit nur einem Stützpunkt berührt.
			% Das Erzeugen der Druckdaten funktioniert trotzdem ==> keine Fehlermeldung ausgeben.
			if testout_topside~=0
				for k=1:size(t_poly2.Points,1)
					i = isvertexmember(t_poly2.Points,t_poly2.Points(k,:),tol_1);
					if length(find(i))~=1
						fprintf(1,'find(i) = [ %s ]\n',num2str(find(i)));
						fprintf(1,'t_poly2.Points(k,:) = [ %s ]\n',num2str(t_poly2.Points(k,:)));
					end
				end
				fprintf(1,['iobj=%g   dmax=%g   size(test1,1)=%g   size(test2,1)=%g   ',...
					'size(unique(test1),1)=%g   size(unique(test2),1)=%g\n'],...
					iobj,dmax,size(test1,1),size(test2,1),size(unique(test1),1),size(unique(test2),1));
			end
			% errormessage;
		end
		
		% Testplots:
		if testplot_triang_hareas==1
			% ha1:
			axes(ha1);
			triplot(t_poly1);
			hold(ha1,'on');
			plot(ha1,obj_bot_bh_reg.poly(iobj).Vertices(:,1),obj_bot_bh_reg.poly(iobj).Vertices(:,2),...
				'LineWidth',0.5,'LineStyle','-','Color','k','Marker','.','MarkerSize',15);
			plot(ha1,poly_out.Vertices(:,1),poly_out.Vertices(:,2),...
				'LineWidth',0.5,'LineStyle','-','Color','m','Marker','.','MarkerSize',15);
			if (PP_local.colorspec(icolspec).bottom_version~=1)||(obj_bot_bh_reg.colprio(iobj)==colprio_base)
				plot(ha1,poly_in.Vertices(:,1),poly_in.Vertices(:,2),...
					'LineWidth',0.5,'LineStyle','-','Color','c','Marker','.','MarkerSize',15);
			end
			hold(ha1,'off');
			% ha3:
			Tplot3=triangulation(t_poly2.ConnectivityList,t_poly2.Points);
			axes(ha3);
			trisurf(Tplot3);
			% ha4:
			Tplot4=triangulation(T.ConnectivityList(i_TCL,:),T.Points);
			facealpha	= 0.2;			% Transparenz der Oberflächen
			edgealpha	= 0.2;			% Transparenz der Kanten
			axes(ha4);
			trisurf(Tplot4,'EdgeColor',[0 0 0],'FaceColor',[1 1 1]*0.95,'FaceAlpha',facealpha,'EdgeAlpha',edgealpha,...
				'Marker','.','MarkerEdgeColor','r','MarkerSize',8);
			set_breakpoint	= 1;
		end
		
		% nächste Triangulation vorbereiten:
		if ((PP_local.colorspec(icolspec).bottom_version~=1)||(obj_bot_bh_reg.colprio(iobj)==colprio_base))&&...
				(mod(obj_bot_bh_reg.srftype(iobj),100)==0)
			% - Die Unterseite ist nicht eben oder die Farbe ist die Grundfarbe UND
			% - Die Oberseite folgt dem Gelände:
			if numboundaries(poly_in)>0
				poly_out							= poly_in;
				poly_out_is_inner_polygon	= 1;
			end
		end
		
	end
end


%------------------------------------------------------------------------------------------------------------------
% äußere und innere Randlinien des Druckteils
%------------------------------------------------------------------------------------------------------------------
% Gesucht:	Welche Punkt in den bereits vorliegenden Triangulationsdaten T.Points gehören zu der Randlinie des
%				aktuellen Teils?
% Die Randlinie des aktuellen Teils ist das Polynom obj.poly(1).
% Diese Randlinie wird um tol_polybuffer nach innen und nach außen verlagert, dadurch entsteht ein Toleranzband.
% Anschließend werden alle Punkte in allen Polynomen obj_bot_bh_reg.poly daraufhin überprüft, ob sie innerhalb
% dieses Toleranzbands liegen.
% Solche zusammenhängende Abschnitte auf dem Rand werden in T_margin_cell{i_margin,1} gesammelt.
% Anschließend werden die einzelnen zusammenhängenden Abschnitte auf dem Rand in der richtigen Reihenfolge
% zusammengesetzt:
% Diejenigen Start- und Endpunkte zweier Abschnitt, die jeweils den geringsten Abstand zueinander haben, werden
% zusammengesetzt. Dieser geringste Abstand (min_distance) sollte kleiner 1e-10 sein.
% Wenn min_distance zu groß ist, liegt ein Fehler vor. Mögliche Ursachen sind:
% -	Ein Objekt liegt teilweise auf dem Rand und verlässt den Rand unter einem sehr spitzen Winkel.
%		Dann kann ein Punkt, der eigentlich nicht mehr auf dem Rand liegt, als noch auf dem Rand erkannt werden.
% Aus diesem Grund kann es Sinn machen, die Toleranzen zu variieren, bis kein Fehler mehr erkannt wird.
%
% Ergebnis:
% iT_margin{1,i_margin}		row-indices of the margin in T.Points, logical array
%									i_margin:		boundary index in obj.poly(1)
%									i_margin=1:		outer margin
%									i_margin>=2:	inner margins

if (currpart_i_tile==1)&&(currpart_i_colprio==4)&&(currpart_i_part==3)
	% 	[pathname_test,~,~]	= fileparts(mfilename('fullpath'))
	% 	filename_test			=sprintf('test_%g_%g_%g.mat',currpart_i_tile,currpart_i_colprio,currpart_i_part)
	% 	save([pathname_test '\' filename_test]);
	test=1;
end

% Waitbar:
msg_get_T_margin	= sprintf('%s: topside triangulation: calculation of the object margin',msg);
set(GV_H.text_waitbar,'String',sprintf('%s: start',msg_get_T_margin));
drawnow;

try
	T0		= T;			% for testing
	[T,iT_margin,get_iT_margin_error_occurred]	= ...
		get_T_margin(obj,T,PP_local,ELE_local,poly_legbgd,colprio_base,obj_bot_bh_reg,msg_get_T_margin,0);
	set(GV_H.text_waitbar,'String',sprintf('%s: done',msg_get_T_margin));
catch ME
	% The global variables defined in the function must also be defined globally outside:
	% required: global GV
	errormessage('',ME);
end

%------------------------------------------------------------------------------------------------------------------
% 3d-Darstellung des Ergebnisses
%------------------------------------------------------------------------------------------------------------------

if (currpart_i_tile==1)&&(currpart_i_colprio==4)&&(currpart_i_part==3)
	test=1;
end

% Testplots:
if    (testplot_triang_top==1)||get_iT_margin_error_occurred
	hf		= figure(100500);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','triang');
	set(hf,'NumberTitle','off');
	cameratoolbar(hf,'Show');
	ha		= axes(hf);
	hold(ha,'on');
	xlabel(ha,'x / mm');
	ylabel(ha,'y / mm');
	zlabel(ha,'z / mm');
	facealpha	= 0.8;			% Transparenz der Oberflächen		0.2
	edgealpha	= 0.2;			% Transparenz der Kanten			0.2
	if ~isempty(T.ConnectivityList)
		F=[T.ConnectivityList(:,1) ...
			T.ConnectivityList(:,2) ...
			T.ConnectivityList(:,3) ...
			T.ConnectivityList(:,1)];
		patch(ha,'faces',F,'vertices',T.Points,...
			'EdgeColor',[0 0 0],'FaceColor',[1 1 1]*0.95,'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
		% Stützstellen:
		plot3(ha,T.Points(:,1),T.Points(:,2),T.Points(:,3),...
			'LineWidth',0.5,'LineStyle','none','Color','k',...
			'Marker','.','MarkerSize',10);
		% Rand markieren:
		if ~get_iT_margin_error_occurred
			for i_margin=1:size(iT_margin,2)
				plot3(ha,...
					T.Points(iT_margin{1,i_margin},1),...
					T.Points(iT_margin{1,i_margin},2),...
					T.Points(iT_margin{1,i_margin},3),...
					'LineWidth',0.5,'LineStyle','-','Color','r',...
					'Marker','.','MarkerSize',15);
			end
		end
	end
	% Title:
	if ~get_iT_margin_error_occurred
		title(ha,sprintf('i_tile=%g, i_colprio=%g, i_part=%g',...
			currpart_i_tile,currpart_i_colprio,currpart_i_part),'Interpreter','none');
	else
		% Error when calculating the margin:
		title(ha,sprintf([...
			'The margin of this object could not be calculated due to numerical\n',...
			'problems. Try this: Move, rotate or scale this object a little,\n',...
			'simplify the map again, then create the map STL files again.']),'Interpreter','none');
	end
	view(ha,3);
	axis(ha,'equal');
end
if get_iT_margin_error_occurred
	% Error when calculating the margin:
	T		= T0;
	clear T0
	errormessage;			% Without the errortext (nargin=0) also the errorlog is saved!
else
	clear T0
end

sumarea_obj_bot_reg		= 0;
sumarea_obj_bot_bh		= 0;
sumarea_obj_bot_bh_reg	= 0;
subtract_obj_bot_reg		= obj.poly(1);
subtract_obj_bot_bh		= obj.poly(1);
subtract_obj_bot_bh_reg	= obj.poly(1);
for iobj=2:length(obj_bot_reg.poly)
	% Waitbar:
	if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
		WAITBAR.t1	= clock;
		set(GV_H.text_waitbar,'String',sprintf('%s: topside triangulation: plausibility checks %g/%g',msg,...
			iobj,length(obj_bot_reg.poly)));
		drawnow;
	end
	sumarea_obj_bot_reg	= sumarea_obj_bot_reg+area(intersect(obj.poly(1),obj_bot_reg.poly(iobj)));
	subtract_obj_bot_reg	= subtract(subtract_obj_bot_reg,obj_bot_reg.poly(iobj));
end
for iobj=2:length(obj_bot_bh.poly)
	% Waitbar:
	if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
		WAITBAR.t1	= clock;
		set(GV_H.text_waitbar,'String',sprintf('%s: topside triangulation: plausibility checks %g/%g',msg,...
			iobj,length(obj_bot_bh.poly)));
		drawnow;
	end
	sumarea_obj_bot_bh	= sumarea_obj_bot_bh+area(intersect(obj.poly(1),obj_bot_bh.poly(iobj)));
	subtract_obj_bot_bh	= subtract(subtract_obj_bot_bh,obj_bot_bh.poly(iobj));
end
for iobj=2:length(obj_bot_bh_reg.poly)
	% Waitbar:
	if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
		WAITBAR.t1	= clock;
		set(GV_H.text_waitbar,'String',sprintf('%s: topside triangulation: plausibility checks %g/%g',msg,...
			iobj,length(obj_bot_bh_reg.poly)));
		drawnow;
	end
	sumarea_obj_bot_bh_reg	= sumarea_obj_bot_bh_reg+area(intersect(obj.poly(1),obj_bot_bh_reg.poly(iobj)));
	subtract_obj_bot_bh_reg	= subtract(subtract_obj_bot_bh_reg,obj_bot_bh_reg.poly(iobj));
end
area_subtract_obj_bot_reg			= area(subtract_obj_bot_reg);
area_subtract_obj_bot_bh			= area(subtract_obj_bot_bh);
area_subtract_obj_bot_bh_reg		= area(subtract_obj_bot_bh_reg);
area_obj_poly_iobj_colprio_base	= area(obj.poly(1));
if ~isfield(PRINTDATA,'plausiblitycheck')
	PRINTDATA.plausiblitycheck		= [];
end
if ~isfield(PRINTDATA.plausiblitycheck,'map2stl_topside_triangulation')
	PRINTDATA.plausiblitycheck.map2stl_topside_triangulation		= zeros(0,6);
end
PRINTDATA.plausiblitycheck.map2stl_topside_triangulation(end+1,:)	= [...
	currpart_i_tile ...
	currpart_i_colprio ...
	currpart_i_part ...
	area_obj_poly_iobj_colprio_base-sumarea_obj_bot_reg ...
	area_obj_poly_iobj_colprio_base-sumarea_obj_bot_bh ...
	area_obj_poly_iobj_colprio_base-sumarea_obj_bot_bh_reg];
if    (abs(area_obj_poly_iobj_colprio_base-sumarea_obj_bot_reg   )>tol_2) || ...
		(abs(area_obj_poly_iobj_colprio_base-sumarea_obj_bot_bh    )>1e-3 ) || ...		% typically 1..10e-5
		(abs(area_obj_poly_iobj_colprio_base-sumarea_obj_bot_bh_reg)>tol_2) || ...
		(testout_topside~=0)
	fprintf(1,'---------------------------------------------------\n');
	fprintf(1,'currpart_i_tile   = %g\n',currpart_i_tile);
	fprintf(1,'currpart_i_colprio = %g\n',currpart_i_colprio);
	fprintf(1,'currpart_i_part    = %g\n',currpart_i_part);
	fprintf(1,'\n');
	fprintf(1,'area(obj.poly(1)) = %g\n',area(obj.poly(1)));
	fprintf(1,'sumarea_obj_bot_reg          = %g\n',sumarea_obj_bot_reg);
	fprintf(1,'sumarea_obj_bot_bh           = %g\n',sumarea_obj_bot_bh);
	fprintf(1,'sumarea_obj_bot_bh_reg       = %g\n',sumarea_obj_bot_bh_reg);
	fprintf(1,'area_subtract_obj_bot_reg    = %g   (=0!)\n',area_subtract_obj_bot_reg);
	fprintf(1,'area_subtract_obj_bot_bh     = %g   (=0!)\n',area_subtract_obj_bot_bh);
	fprintf(1,'area_subtract_obj_bot_bh_reg = %g   (=0!)\n',area_subtract_obj_bot_bh_reg);
	fprintf(1,'area_obj_poly_iobj_colprio_base-sumarea_obj_bot_reg    = %g   (=0!)\n',...
		area_obj_poly_iobj_colprio_base-sumarea_obj_bot_reg);
	fprintf(1,'area_obj_poly_iobj_colprio_base-sumarea_obj_bot_bh     = %g   (=0!)\n',...
		area_obj_poly_iobj_colprio_base-sumarea_obj_bot_bh);
	fprintf(1,'area_obj_poly_iobj_colprio_base-sumarea_obj_bot_bh_reg = %g   (=0!)\n',...
		area_obj_poly_iobj_colprio_base-sumarea_obj_bot_bh_reg);
	fprintf(1,'\n');
	if (testout_topside==0)&&~isdeployed
		errormessage;
	end
end

if (currpart_i_tile==1)&&(currpart_i_colprio==8)&&(currpart_i_part==8)
	test=1;
end

length_isinf_TP	= length(find(isinf(T.Points)          ));
length_isnan_TP	= length(find(isnan(T.Points)          ));
length_isinf_TC	= length(find(isinf(T.ConnectivityList)));
length_isnan_TC	= length(find(isnan(T.ConnectivityList)));
if (length_isinf_TP>0)||(length_isnan_TP>0)||(length_isinf_TC>0)||(length_isnan_TC>0)
	% Fehler in den Triangulationsdaten:
	fprintf(1,'\n');
	fprintf(1,'currpart_i_tile  =%g\n',currpart_i_tile  );
	fprintf(1,'currpart_i_colprio=%g\n',currpart_i_colprio);
	fprintf(1,'currpart_i_part   =%g\n',currpart_i_part   );
	fprintf(1,'length_isinf_TP   =%g\n',length_isinf_TP   );
	fprintf(1,'length_isnan_TP   =%g\n',length_isnan_TP   );
	fprintf(1,'length_isinf_TC   =%g\n',length_isinf_TC   );
	fprintf(1,'length_isnan_TC   =%g\n',length_isnan_TC   );
	errormessage;
end


