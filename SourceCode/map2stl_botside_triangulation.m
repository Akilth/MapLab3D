function T=map2stl_botside_triangulation(T,iT_margin,z_bottom,z_bottom_max,zmin,colprio,PP_local,ELE_local,poly_legbgd,...
	testout,testplot,testplot_xylimits,msg,...
	currpart_i_tile,currpart__colprio_stal,currpart_i_part_stal,currpart_i_colprio,currpart_i_part)
% map2stl_botside_triangulation erweitert die Triangulationsdaten in T um die Unterseite eines zu druckenden Teils.
% T								Triangulationsdaten
% iT_margin{1,i_margin}		row-indices of the margin in T.Points, logical array
%									i_margin=1:	outer margin
%									i_margin=2:	inner margin
% z_bottom						fester z-Wert der Unterseite
% z_bottom_max					maximal zulässiger Wert z_bottom (wenn die Unterseite dem Gelände folgt)
% colprio						Farbpriorität des aktuellen Teils
%									colprio wird benötigt für das Auslesen der Einstellungen aus den Projektdaten.
% tol_1								Toleranz für Vergleiche der Koordinaten von Stützpunkten
% testout						Ausgabe von Meldungen im Command-Window für Testzwecke (0/1)
% testplot						Anzeige von Testplots (0/1)

global GV GV_H WAITBAR

% The try/catch block is in the calling function!

if (currpart_i_tile==1)&&(currpart_i_colprio==2)&&(currpart_i_part==4)
	test=1;
end

% Waitbar:
if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
	WAITBAR.t1	= clock;
	set(GV_H.text_waitbar,'String',sprintf('%s: bottomside triangulation',msg));
	drawnow;
end

% Tolerance for comparison of vertex coordinates:
tol_1				= GV.tol_1;

% Grenzen des aktuellen Teils
xmin_mm			= min(T.Points(:,1));
xmax_mm			= max(T.Points(:,1));
ymin_mm			= min(T.Points(:,2));
ymax_mm			= max(T.Points(:,2));

% Indices aller Zeilen in T.Points und T.ConnectivityList:
iT_top			= (1:size(T.Points,1))';
iCL_top			= (1:size(T.ConnectivityList,1))';

% Einstellungen aus der Projektdatei:
colno				= find([PP_local.color.prio]==colprio,1);
icolspec			= PP_local.color(colno).spec;
dz_margin		= PP_local.colorspec(icolspec).dz_margin;
dz_overhang		= PP_local.colorspec(icolspec).dz_overhang;
dxy_overhang	= PP_local.colorspec(icolspec).dxy_overhang;

% Indices ifs of the filter settings.
ifs				= ELE_local.ifs_v(icolspec,1);

% Interpolation der Oberfläche vorbereiten: wird benötigt für für Bildung des Überhangs am Rand des Druckteils:
% Der Überhang soll zusätzlich zur schrittweisen Absenkung auch dem Gelände folgen, damit bei einer steilen
% Topographie keine Löcher entstehen.
% Da der Überhang nicht sichtbar ist, werden die Auflösungen hier in dieser Funktion festgelegt.
% Für die Interpolation der Triangulationsdaten müssen übereinanderliegende Punkte gelöscht werden:
% Bei übereinanderliegenden Punkten soll der mit der geringeren Höhe z verbleiben, der höhere Punkt wird gelöscht:
% % % % Testing:
% % % global i_griddata
% % % T.Points	= [...
% % % 	T.Points(1,1) T.Points(1,2) T.Points(1,3)+1;...
% % % 	T.Points(2,1) T.Points(2,2) T.Points(2,3)+1;...
% % % 	T.Points(1,1) T.Points(1,2) T.Points(1,3)-1;...
% % % 	T.Points(2,1) T.Points(2,2) T.Points(2,3)-1;...
% % % 	T.Points;...
% % % 	T.Points(3,1) T.Points(3,2) T.Points(3,3)+1;...
% % % 	T.Points(4,1) T.Points(4,2) T.Points(4,3)+1];
% % % T.Points(1:6,:)
% % % T.ConnectivityList	= T.ConnectivityList+4;
% % % size(T.Points)
% % % tic
method			= 2;
switch method
	case 1
		i_griddata		= zeros(0,1);
		for k=1:size(T.Points,1)
			i_TP			= find(...
				(abs(T.Points(:,1)-T.Points(k,1))<tol_1)&...
				(abs(T.Points(:,2)-T.Points(k,2))<tol_1)    );
			[~,i]			= min(T.Points(i_TP,3));
			i_griddata	= [i_griddata;i_TP(i)];
		end
		i_griddata		= unique(i_griddata);
	case 2
		% up to 1000 times faster:
		% Tolerance for the use of uniquetol: Conversion of the absolute tolerance:
		% C = uniquetol(A,tol): Two values, u and v, are within tolerance if abs(u-v) <= tol*max(abs(A(:)))
		% GV.tol_tp=tol*max(abs(A(:)))  ==>  tol=GV.tol_tp/max(abs(A(:)))
		tol_uniquetol			= tol_1/max(abs(T.Points),[],'all');
		% [T.Points_new,ia,ic]=uniquetol(T.Points_old,GV.tol_tp,'ByRows',true);
		% T.Points_new = T.Points_old(ia,:)
		% T.Points_old = T.Points_new(ic,:)
		[~,ia,~]					= uniquetol(T.Points(:,1:2),tol_uniquetol,'ByRows',true);
		% Indices in T.Points von Punkten, von denen mind. ein anderer Punkt mit gleichen xy-Koordinaten existiert:
		r_TP_xy_unique			= false(size(T.Points,1),1);
		r_TP_xy_unique(ia,1)	= true;
		r_TP_notunique_v		= find(~r_TP_xy_unique);
		% Lösche die Punkte in i_griddata, die einen höheren z-Wert haben:
		i_griddata	= true(size(T.Points,1),1);
		while ~isempty(r_TP_notunique_v)
			r									= r_TP_notunique_v(1);
			r_TP0								= find(...
				(abs(T.Points(:,1)-T.Points(r,1))<tol_1)&...
				(abs(T.Points(:,2)-T.Points(r,2))<tol_1)    );
			r_TP								= r_TP0;
			[~,i_min]						= min(T.Points(r_TP,3));		% do not overwrite zmin
			r_TP(i_min)						= [];
			i_griddata(r_TP,1)	= false;
			k_delete							= false(size(r_TP_notunique_v,1),1);
			for i=1:size(r_TP0,1)
				k_delete(r_TP_notunique_v==r_TP0(i,1))	= true;
			end
			r_TP_notunique_v(k_delete,:)	= [];
		end
end
% % % % Testing:
% % % toc
% % % i_griddata(1:6,:)
% % % size(i_griddata)
% % % setbreakpoint=1;

% Daten für die Interpolation der Oberfläche:
top_dx_mm					= 0.125;		% 0.25																						% !!!!!
top_dy_mm					= 0.125;		% 0.25																						% !!!!!
nx								= ceil((xmax_mm-xmin_mm)/top_dx_mm);
ny								= ceil((ymax_mm-ymin_mm)/top_dy_mm);
top_dx_mm					= (xmax_mm-xmin_mm)/nx;
top_dy_mm					= (ymax_mm-ymin_mm)/ny;
top_xv_mm					= xmin_mm+(0:nx)'*top_dx_mm;
top_yv_mm					= ymin_mm+(0:ny)'*top_dy_mm;
[top_xm_mm,top_ym_mm]	= meshgrid(top_xv_mm,top_yv_mm);
colno_T_Points																= 1;
ifs_T_Points																= 1;
colprio_T_Points															= 1;
ele_T_Points_i_griddata													= struct;
ele_T_Points_i_griddata.ifs_v											= ifs_T_Points;
ele_T_Points_i_griddata.elefiltset.xm_mm							= T.Points(i_griddata,1);
ele_T_Points_i_griddata.elefiltset.ym_mm							= T.Points(i_griddata,2);
ele_T_Points_i_griddata.elefiltset.zm_mm							= T.Points(i_griddata,3);
ele_T_Points_i_griddata.elecolor(colno_T_Points,1).elepoly	= [];
ele_T_Points_i_griddata.elecolor(colno_T_Points,1).colprio	= colprio_T_Points;
ele_T_Points_i_griddata.elecolor(colno_T_Points,1).ifs		= ifs_T_Points;
top_zm_mm					= interp_ele(...
	top_xm_mm,...								% query points x
	top_ym_mm,...								% query points y
	ele_T_Points_i_griddata,...			% elevation structure
	colno_T_Points,...									% color numbers
	GV.legend_z_topside_bgd,...			% legend background z-value
	poly_legbgd,...							% legend background polygon
	'griddata');								% interpolation method
ele_top_xyzm_mm															= struct;
ele_top_xyzm_mm.ifs_v													= ifs_T_Points;
ele_top_xyzm_mm.elefiltset.xm_mm										= top_xm_mm;
ele_top_xyzm_mm.elefiltset.ym_mm										= top_ym_mm;
ele_top_xyzm_mm.elefiltset.zm_mm										= top_zm_mm;
ele_top_xyzm_mm.elecolor(colno_T_Points,1).elepoly				= [];
ele_top_xyzm_mm.elecolor(colno_T_Points,1).colprio				= colprio_T_Points;
ele_top_xyzm_mm.elecolor(colno_T_Points,1).ifs					= ifs_T_Points;


%------------------------------------------------------------------------------------------------------------------
% obere Randlinie um dz_margin nach unten versetzen.
%------------------------------------------------------------------------------------------------------------------

if (currpart_i_tile==1)&&(currpart_i_colprio==2)&&(currpart_i_part==13)
	test=1;
end

methode	= 1;
switch methode
	
	case 1
		% manuell triangulieren: Es darf nur einfache Sprünge nach oben oder unten geben:
		
		for i_margin=1:size(iT_margin,2)
			
			% Nach diesem Schritt gibt es auf dem Rand keine Punkte mit gleichen x- und y-Koordinaten mehr.
			line_no					= 1;
			kmax						= length(iT_margin{1,i_margin});
			kstart					= 1;
			% Der Startpunkt soll nicht an einer Sprungstelle liegen:
			while kstart<=kmax
				tm1			= iT_margin{1,i_margin}(vindexrest(kstart-1,kmax));
				tp0			= iT_margin{1,i_margin}(kstart);
				tp1			= iT_margin{1,i_margin}(vindexrest(kstart+1,kmax));
				if    ((abs(T.Points(tp0,1)-T.Points(tp1,1))>tol_1)||...
						( abs(T.Points(tp0,2)-T.Points(tp1,2))>tol_1)     )&&...
						((abs(T.Points(tp0,1)-T.Points(tm1,1))>tol_1)||...
						( abs(T.Points(tp0,2)-T.Points(tm1,2))>tol_1)     )
					% Die Punkte tpm1 und tp0 sowie tp1 und tp0 liegen nicht übereinander:
					tp0								= iT_margin{1,i_margin}(kstart);
					T.Points							= [T.Points;T.Points(tp0,:)-[0 0 dz_margin]];
					iT_lines{line_no,i_margin}	= size(T.Points,1);
					break
				end
				kstart		= kstart+1;
			end
			% k: Index in iT_margin{1,i_margin}
			kend						= kmax+kstart-1;
			k							= kstart;
			while k<=kend
				% Indices des oberen Rands (top) in T.Points:
				tp0			= iT_margin{1,i_margin}(vindexrest(k  ,kmax));
				tp1			= iT_margin{1,i_margin}(vindexrest(k+1,kmax));
				tp2			= iT_margin{1,i_margin}(vindexrest(k+2,kmax));
				tp3			= iT_margin{1,i_margin}(vindexrest(k+3,kmax));
				tp4			= iT_margin{1,i_margin}(vindexrest(k+4,kmax));
				if (    abs(T.Points(tp0,1)-T.Points(tp1,1))>tol_1)||...
						( abs(T.Points(tp0,2)-T.Points(tp1,2))>tol_1)
					% Die Punkte tp0 und tp1 liegen nicht übereinander:
					% Punkte 0 und 1 "vernähen":
					%   	1)	tp0     tp1		2)	tp0--<--tp1
					%         | \                 \     |
					%         v   \                 \   ^
					%         |     \                 \ |
					%      	bp0-->--bp1	   	bp0     bp1
					T.Points							= [T.Points                   ;T.Points(tp1,:)-[0 0 dz_margin]];	% bp1
					iT_lines{line_no,i_margin}	= [iT_lines{line_no,i_margin};size(T.Points,1)               ];
					bp0								= iT_lines{line_no,i_margin}(end-1);
					bp1								= iT_lines{line_no,i_margin}(end  );
					% T.ConnectivityList	= [T.ConnectivityList;...
					% 	bp0 bp1 tp0;...		% 1)
					% 	bp1 tp1 tp0];			% 2)
					% In dieser Reihenfolge werden weniger Fehler der STL-Datei angezeigt:
					% Evtl. hängt es noch von der Richtung bzw. dem Drehsinn der Linien ab und
					% diese Lösung funktioniert nicht allgemein besser.
					% ausprobiert:
					% -	Drehsinn der Polygone festlegen abhängig davon ob es ein inneres oder äußeres Polygon ist.
					% -	Alle Zuweisungen der ConnectivityList überarbeiten und jeweils die Anzahl der Fehler testen.
					% Es ergibt sich ein Widerspruch: hier führt eine Anordnung der 3 Punkte im Uhrzeigersinn
					% zu weniger Fehlern, weiter oben ist es anders herum.
					T.ConnectivityList	= [T.ConnectivityList;...
						bp0 tp0 bp1;...		% 1)
						bp1 tp0 tp1];			% 2)
					k		= k+1;
				elseif (abs(T.Points(tp1,1)-T.Points(tp0,1))<tol_1) && ...
						( abs(T.Points(tp1,2)-T.Points(tp0,2))<tol_1) && ...
						(    (T.Points(tp1,3)-T.Points(tp0,3))>tol_1) && ...
						( abs(T.Points(tp2,1)-T.Points(tp3,1))<tol_1) && ...
						( abs(T.Points(tp2,2)-T.Points(tp3,2))<tol_1) && ...
						(    (T.Points(tp2,3)-T.Points(tp3,3))>tol_1) && ...
						((abs(T.Points(tp3,1)-T.Points(tp4,1))>tol_1) ||...
						( abs(T.Points(tp3,2)-T.Points(tp4,2))>tol_1)       )
					% Ab Punkt tp1 gibt einen Sprung nach oben und direkt wieder nach unten:
					% Das muss vor den einfachen Sprüngen abgefragt werden.
					%         	   tp1---tp2
					%               | \   |
					%               |   \ |
					%        tm1---tp0---tp3---tp4
					%         | \   | \   | \   |
					%         |   \ |   \ |   \ |
					%        bm1---bp0---bp1---bp2
					T.Points							= [T.Points                  ;T.Points(tp0,:)-[0 0 dz_margin]];	% bp0
					iT_lines{line_no,i_margin}	= [iT_lines{line_no,i_margin};size(T.Points,1)               ];
					T.Points							= [T.Points                  ;T.Points(tp3,:)-[0 0 dz_margin]];	% bp1
					iT_lines{line_no,i_margin}	= [iT_lines{line_no,i_margin};size(T.Points,1)               ];
					bp0								= iT_lines{line_no,i_margin}(end-1);
					bp1								= iT_lines{line_no,i_margin}(end  );
					% T.ConnectivityList			= [T.ConnectivityList;bp0 bp1 tp0];
					% T.ConnectivityList			= [T.ConnectivityList;bp1 tp3 tp0];
					% T.ConnectivityList			= [T.ConnectivityList;tp0 tp3 tp1];
					% T.ConnectivityList			= [T.ConnectivityList;tp3 tp2 tp1];
					T.ConnectivityList			= [T.ConnectivityList;bp0 tp0 bp1];
					T.ConnectivityList			= [T.ConnectivityList;bp1 tp0 tp3];
					T.ConnectivityList			= [T.ConnectivityList;tp0 tp1 tp3];
					T.ConnectivityList			= [T.ConnectivityList;tp3 tp1 tp2];
					k		= k+3;
				elseif (abs(T.Points(tp0,1)-T.Points(tp1,1))<tol_1)         && ...
						( abs(T.Points(tp0,2)-T.Points(tp1,2))<tol_1)         && ...
						(    (T.Points(tp0,3)-T.Points(tp1,3))>tol_1)         && ...
						((abs(T.Points(tp1,1)-T.Points(tp2,1))>tol_1) ||...
						( abs(T.Points(tp1,2)-T.Points(tp2,2))>tol_1)       )
					% Ab Punkt tp1 gibt einen einfachen Sprung nach unten:
					%      	tm1---tp0
					%         |   / |
					%         | / A |
					%        bm1---tp1---tp2
					%           \ B | \   |
					%             \ |   \ |
					%              bp0---bp1
					if k==kstart
						fprintf(1,'k=%g, kstart=%g\n',k,kstart);
						errormessage;
					end
					% In dem mit A markierten Dreieck muss der Punkt rechts unten von bp0_old auf tp1 geändert werden:
					bp0_old							= size(T.Points,1);
					T.Points							= [T.Points                  ;T.Points(tp1,:)-[0 0 dz_margin]];	% bp0
					T.ConnectivityList(T.ConnectivityList==bp0_old)	= tp1;
					% Der letzte Punkt der Linie des unteren Randes mus von bp0_old auf bp0 geändert werden:
					bp0								= size(T.Points,1);
					iT_lines{line_no,i_margin}(end,1)					= bp0;
					bm1								= iT_lines{line_no,i_margin}(end-1);
					% Dreieck B triangulieren:
					T.ConnectivityList			= [T.ConnectivityList;bm1 bp0 tp1];
					k		= k+1;
				elseif (abs(T.Points(tp1,1)-T.Points(tp0,1))<tol_1)         && ...
						( abs(T.Points(tp1,2)-T.Points(tp0,2))<tol_1)         && ...
						(    (T.Points(tp1,3)-T.Points(tp0,3))>tol_1)         && ...
						((abs(T.Points(tp1,1)-T.Points(tp2,1))>tol_1) ||...
						( abs(T.Points(tp1,2)-T.Points(tp2,2))>tol_1)       )
					% Ab Punkt tp0 gibt einen einfachen Sprung nach oben:
					%         	   tp1---tp2
					%               | \   |
					%               |   \ |
					%        tm1---tp0---bp1
					%         | \   |  /
					%         |   \ | /
					%         X----bp0
					T.Points							= [T.Points                  ;T.Points(tp2,:)-[0 0 dz_margin]];	% bp1
					iT_lines{line_no,i_margin}	= [iT_lines{line_no,i_margin};size(T.Points,1)               ];
					bp0								= iT_lines{line_no,i_margin}(end-1);
					bp1								= iT_lines{line_no,i_margin}(end  );
					% T.ConnectivityList			= [T.ConnectivityList;bp1 tp0 bp0];
					% T.ConnectivityList			= [T.ConnectivityList;bp1 tp1 tp0];
					% T.ConnectivityList			= [T.ConnectivityList;bp1 tp2 tp1];
					T.ConnectivityList			= [T.ConnectivityList;bp1 bp0 tp0];
					T.ConnectivityList			= [T.ConnectivityList;bp1 tp0 tp1];
					T.ConnectivityList			= [T.ConnectivityList;bp1 tp1 tp2];
					k		= k+2;
				else
					disp('---------------------------------------------------------------------------');
					fprintf(1,'line_no = %g\n',line_no);
					fprintf(1,'k       = %g\n',k);
					fprintf(1,'line_no = %g\n',line_no);
					fprintf(1,'tp0     = %4.0f ,   T.Points(tp0,:) = [ %s ]\n',tp0,num2str(T.Points(tp0,:)));
					fprintf(1,'tp1     = %4.0f ,   T.Points(tp1,:) = [ %s ]\n',tp1,num2str(T.Points(tp1,:)));
					fprintf(1,'tp2     = %4.0f ,   T.Points(tp2,:) = [ %s ]\n',tp2,num2str(T.Points(tp2,:)));
					fprintf(1,'tp3     = %4.0f ,   T.Points(tp3,:) = [ %s ]\n',tp3,num2str(T.Points(tp3,:)));
					fprintf(1,'tp4     = %4.0f ,   T.Points(tp4,:) = [ %s ]\n',tp4,num2str(T.Points(tp4,:)));
					errormessage;
				end
			end
			
		end
		
	case 2
		% manuell triangulieren, mit der Behandlung von mehrfachen Sprüngen nach oben und unten:
		% noch Probleme, wenn 2 Sprünge direkt aufeinander folgen, ohne Zwischenwerte:
		
		for i_margin=1:size(iT_margin,2)
			
			% Nach diesem Schritt gibt es auf dem Rand keine Punkte mit gleichen x- und y-Koordinaten mehr.
			line_no					= 1;
			kmax						= length(iT_margin{1,i_margin});
			kstart					= 1;
			% Der Startpunkt soll nicht an einer Sprungstelle liegen:
			while kstart<=kmax
				tp0			= iT_margin{1,i_margin}(kstart);
				tp1			= iT_margin{1,i_margin}(vindexrest(kstart+1,kmax));
				if    (abs(T.Points(tp0,1)-T.Points(tp1,1))>tol_1)||...
						(abs(T.Points(tp0,2)-T.Points(tp1,2))>tol_1)
					tp0		= iT_margin{1,i_margin}(kstart);
					T.Points							= [T.Points;T.Points(tp0,:)-[0 0 dz_margin]];
					iT_lines{line_no,i_margin}	= size(T.Points,1);
					break
				end
				kstart		= kstart+1;
			end
			% k: Index in iT_margin{1,i_margin}
			kend						= kmax+kstart-1;
			k							= kstart;
			while k<=kend
				% Indices des oberen Rands (top) in T.Points:
				tm2			= iT_margin{1,i_margin}(vindexrest(k-2,kmax));
				tm1			= iT_margin{1,i_margin}(vindexrest(k-1,kmax));
				tp0			= iT_margin{1,i_margin}(k);
				tp1			= iT_margin{1,i_margin}(vindexrest(k+1,kmax));
				tp2			= iT_margin{1,i_margin}(vindexrest(k+2,kmax));
				tp3			= iT_margin{1,i_margin}(vindexrest(k+3,kmax));
				tp4			= iT_margin{1,i_margin}(vindexrest(k+4,kmax));
				tp5			= iT_margin{1,i_margin}(vindexrest(k+5,kmax));
				if    (abs(T.Points(tp1,1)-T.Points(tp2,1))<tol_1) && ...
						(abs(T.Points(tp1,2)-T.Points(tp2,2))<tol_1) && ...
						(   (T.Points(tp1,3)-T.Points(tp2,3))>tol_1)
					% Ab Punkt tp1 gibt mindestens einen Sprung nach unten:
					kv			= k+1;
					knext		= kv(end)+1;
					knextr	= vindexrest(knext  ,kmax);
					kvendr	= vindexrest(kv(end),kmax);
					while (abs(T.Points(iT_margin{1,i_margin}(kvendr),1)-T.Points(iT_margin{1,i_margin}(knextr),1))<tol_1) && ...
							(abs(T.Points(iT_margin{1,i_margin}(kvendr),2)-T.Points(iT_margin{1,i_margin}(knextr),2))<tol_1)
						if (   (T.Points(iT_margin{1,i_margin}(kvendr),3)-T.Points(iT_margin{1,i_margin}(knextr),3))<tol_1)
							errormessage;
						end
						kv			= [kv;knext];
						knext		= kv(end)+1;
						knextr	= vindexrest(knext  ,kmax);
						kvendr	= vindexrest(kv(end),kmax);
					end
					tv			= iT_margin{1,i_margin}(vindexrest(kv,kmax));
					tnext		= iT_margin{1,i_margin}(knextr);
					%      	tp0--tv(1)
					%         |   / |
					%         | /   |
					%      	bp0----X
					%         | \   |
					%          \  \ |
					%           | tv(end)-tnext-X
					%            \  | \   | \   |
					%             \ |   \ |   \ |
					%              bp1----X-----X
					T.Points							= [T.Points                  ;T.Points(tv(end),:)-[0 0 dz_margin]];
					iT_lines{line_no,i_margin}	= [iT_lines{line_no,i_margin};size(T.Points,1)                   ];
					bp0								= iT_lines{line_no,i_margin}(end-1);
					bp1								= iT_lines{line_no,i_margin}(end  );
					T.ConnectivityList			= [T.ConnectivityList;bp0 tv(1) tp0    ];
					for i=2:length(kv)
						T.ConnectivityList		= [T.ConnectivityList;bp0 tv(i) tv(i-1)];
					end
					T.ConnectivityList			= [T.ConnectivityList;bp0 bp1   tv(end)];
					k		= kv(end);
				elseif (abs(T.Points(tp1,1)-T.Points(tp0,1))<tol_1) && ...
						( abs(T.Points(tp1,2)-T.Points(tp0,2))<tol_1) && ...
						(    (T.Points(tp1,3)-T.Points(tp0,3))>tol_1)
					% Ab Punkt tp0 gibt mindestens einen Sprung nach oben:
					kv			= k;
					knext		= kv(end)+1;
					knextr	= vindexrest(knext  ,kmax);
					kvendr	= vindexrest(kv(end),kmax);
					while (abs(T.Points(iT_margin{1,i_margin}(knextr),1)-T.Points(iT_margin{1,i_margin}(kvendr),1))<tol_1) && ...
							(abs(T.Points(iT_margin{1,i_margin}(knextr),2)-T.Points(iT_margin{1,i_margin}(kvendr),2))<tol_1)
						if (   (T.Points(iT_margin{1,i_margin}(knextr),3)-T.Points(iT_margin{1,i_margin}(kvendr),3))<tol_1)
							errormessage;
						end
						kv			= [kv;knext];
						knext		= kv(end)+1;
						knextr	= vindexrest(knext  ,kmax);
						kvendr	= vindexrest(kv(end),kmax);
					end
					tv			= iT_margin{1,i_margin}(vindexrest(kv,kmax));
					tnext		= iT_margin{1,i_margin}(knextr);
					%         	tv(end)--tnext--X
					%               | \   | \   |
					%               |   \ |   \ |
					%               X ---bp1----X
					%               |   / |
					%               |  / /
					%      	tm1--tv(1) |
					%         | \   |  /
					%         |   \ | /
					%         X----bp0
					T.Points							= [T.Points                  ;T.Points(tnext,:)-[0 0 dz_margin]];
					iT_lines{line_no,i_margin}	= [iT_lines{line_no,i_margin};size(T.Points,1)                 ];
					bp0								= iT_lines{line_no,i_margin}(end-1);
					bp1								= iT_lines{line_no,i_margin}(end  );
					T.ConnectivityList			= [T.ConnectivityList;bp0   bp1   tv(1)  ];
					for i=1:(length(kv)-1)
						T.ConnectivityList		= [T.ConnectivityList;tv(i) bp1   tv(i+1)];
					end
					T.ConnectivityList			= [T.ConnectivityList;bp1   tnext tv(end)];
					k		= knext;
					
				elseif (abs(T.Points(tp0,1)-T.Points(tp1,1))>tol_1)||...
						( abs(T.Points(tp0,2)-T.Points(tp1,2))>tol_1)
					% Die Punkte tp0 und tp1 liegen nicht übereinander:
					% Punkte 0 und 1 "vernähen":
					%   	1)	tp0     tp1		2)	tp0--<--tp1
					%         | \                 \     |
					%         v   \                 \   ^
					%         |     \                 \ |
					%      	bp0-->--bp1	   	bp0     bp1
					T.Points							= [T.Points                   ;T.Points(tp1,:)-[0 0 dz_margin]];
					iT_lines{line_no,i_margin}	= [iT_lines{line_no,i_margin};size(T.Points,1)               ];
					bp0								= iT_lines{line_no,i_margin}(end-1);
					bp1								= iT_lines{line_no,i_margin}(end  );
					T.ConnectivityList	= [T.ConnectivityList;...
						bp0 bp1 tp0;...		% 1)
						bp1 tp1 tp0];			% 2)
					k		= k+1;
					
				else
					disp('---------------------------------------------------------------------------');
					fprintf(1,'line_no = %g\n',line_no);
					fprintf(1,'k       = %g\n',k);
					fprintf(1,'tm2     = %4.0f ,   T.Points(tm2,:) = [ %s ]\n',tm2,num2str(T.Points(tm2,:)));
					fprintf(1,'tm1     = %4.0f ,   T.Points(tm1,:) = [ %s ]\n',tm1,num2str(T.Points(tm1,:)));
					fprintf(1,'tp0     = %4.0f ,   T.Points(tp0,:) = [ %s ]\n',tp0,num2str(T.Points(tp0,:)));
					fprintf(1,'tp1     = %4.0f ,   T.Points(tp1,:) = [ %s ]\n',tp1,num2str(T.Points(tp1,:)));
					fprintf(1,'tp2     = %4.0f ,   T.Points(tp2,:) = [ %s ]\n',tp2,num2str(T.Points(tp2,:)));
					fprintf(1,'tp3     = %4.0f ,   T.Points(tp3,:) = [ %s ]\n',tp3,num2str(T.Points(tp3,:)));
					fprintf(1,'tp4     = %4.0f ,   T.Points(tp4,:) = [ %s ]\n',tp4,num2str(T.Points(tp4,:)));
					fprintf(1,'tp5     = %4.0f ,   T.Points(tp5,:) = [ %s ]\n',tp5,num2str(T.Points(tp5,:)));
					errormessage;
				end
			end
			
		end
		
	case 3
		% Den Rand "abwickeln" und die Triangulation automatisch ausführen:
		% Das Verfahren funktioniert nicht an Ecken !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		
		for i_margin=1:size(iT_margin,2)
			
			% Nach diesem Schritt gibt es auf dem Rand keine Punkte mit gleichen x- und y-Koordinaten mehr.
			kmax			= length(iT_margin{1,i_margin});
			kstart			= 1;
			% Der Startpunkt soll nicht an einer Sprungstelle liegen:
			while kstart<=kmax
				tm1			= iT_margin{1,i_margin}(vindexrest(kstart-1,kmax));
				tp0			= iT_margin{1,i_margin}(kstart);
				tp1			= iT_margin{1,i_margin}(vindexrest(kstart+1,kmax));
				if   ((abs(T.Points(tp0,1)-T.Points(tm1,1))>tol_1)||...
						(abs(T.Points(tp0,2)-T.Points(tm1,2))>tol_1)     )&&(...
						(abs(T.Points(tp0,1)-T.Points(tp1,1))>tol_1)||...
						(abs(T.Points(tp0,2)-T.Points(tp1,2))>tol_1)            )
					break
				end
				kstart		= kstart+1;
			end
			
			% Indices der Punkte des oberen Rands in T.Points:
			tp0				= iT_margin{1,i_margin}(vindexrest(kstart:(kstart+kmax-1),kmax));
			kmax				= length(tp0);
			k					= (1:length(tp0))';
			tm1				= tp0(vindexrest(k-1,kmax));
			tp1				= tp0(vindexrest(k+1,kmax));
			tp2				= tp0(vindexrest(k+2,kmax));
			
			bp0				= ((size(T.Points,1)+1):(size(T.Points,1)+kmax))';
			bm1				= bp0(vindexrest(k-1,kmax));
			bp1				= bp0(vindexrest(k+1,kmax));
			bp2				= bp0(vindexrest(k+2,kmax));
			
			T.Points(bp0,:)	= T.Points(tp0,:);
			
			
			dz_margin																									= 0.05	% Test !!!!!!!!
			
			
			% Indices der Sprünge in tp0:
			k_tp0_step		= ...
				(abs(T.Points(tp0,1)-T.Points(tp1,1))<tol_1) & ...
				(abs(T.Points(tp0,2)-T.Points(tp1,2))<tol_1) & ...
				(abs(T.Points(tp0,3)-T.Points(tp1,3))>tol_1);
			stepsize						= T.Points(tp0(k_tp0_step),3)-T.Points(tp1(k_tp0_step),3);
			k_steps						= k_tp0_step(k_tp0_step);
			
			% Den Punkt 0 des unteren Rands um 1/3 der Strecke zwischen Punkt -1 und 0 zurück verlagern:
			T.Points(bp0(k_tp0_step),1)	= ...
				T.Points(tm1(k_tp0_step),1) + 2/3*(T.Points(tp0(k_tp0_step),1)-T.Points(tm1(k_tp0_step),1));
			T.Points(bp0(k_tp0_step),2)	= ...
				T.Points(tm1(k_tp0_step),2) + 2/3*(T.Points(tp0(k_tp0_step),2)-T.Points(tm1(k_tp0_step),2));
			% 			T.Points(bp0(k_tp0_step),3)	= T.Points(tm1(k_tp0_step),3) + ...
			% 				2/3*(T.Points(tp0(k_tp0_step),3)-T.Points(tm1(k_tp0_step),3));			% !!!!!!!!!!!!!!!!!!!!!!!!!!
			%
			% 			% Bei einem Sprung nach unten soll der zurück verlagerte Punkt abgesenkt werden:
			% 			bp0_k_tp0_step		= bp0(k_tp0_step);
			% 			T.Points(bp0_k_tp0_step(stepsize>0),3)	= T.Points(bp0_k_tp0_step(stepsize>0),3)-stepsize(stepsize>0);
			
			% Den Punkt 1 des unteren Rands um 1/3 der Strecke zwischen Punkt 1 und 2 nach vorn verlagern:
			T.Points(bp1(k_tp0_step),1)	= ...
				T.Points(tp1(k_tp0_step),1) + 1/3*(T.Points(tp2(k_tp0_step),1)-T.Points(tp1(k_tp0_step),1));
			T.Points(bp1(k_tp0_step),2)	= ...
				T.Points(tp1(k_tp0_step),2) + 1/3*(T.Points(tp2(k_tp0_step),2)-T.Points(tp1(k_tp0_step),2));
			% 			T.Points(bp1(k_tp0_step),3)	= T.Points(tp1(k_tp0_step),3) + ...
			% 				1/3*(T.Points(tp2(k_tp0_step),3)-T.Points(tp1(k_tp0_step),3));			% !!!!!!!!!!!!!!!!!!!!!!!!!!
			
			% 			% Bei einem Sprung nach oben soll der nach vorn verlagerte Punkt abgesenkt werden:
			% 			bp1_k_tp0_step		= bp1(k_tp0_step);
			% 			T.Points(bp1_k_tp0_step(stepsize<0),3)	= T.Points(bp1_k_tp0_step(stepsize<0),3)+stepsize(stepsize<0);
			
			
			T.Points(bp0,3)	= T.Points(bp0,3)	- dz_margin;
			
			
			% Abstand der Punkte:
			
			% hier den Anfangspunkt festlegen !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			% es sollte auch ohne verschieben des Startpunkts funktionieren !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			
			d_t				= sqrt((T.Points(tm1,1)-T.Points(tp0,1)).^2+(T.Points(tm1,2)-T.Points(tp0,2)).^2);
			d_b				= sqrt((T.Points(bm1,1)-T.Points(bp0,1)).^2+(T.Points(bm1,2)-T.Points(bp0,2)).^2);
			cumsum_d_t		= cumsum(d_t);
			cumsum_d_b		= cumsum(d_b)+d_t(1)-d_b(1);
			z_t				= T.Points(tp0,3);
			z_b				= T.Points(bp0,3);
			hf					= figure;
			set(hf,'Tag','maplab3d_figure');
			plot(cumsum_d_t,z_t,'.-r','MarkerSize',12)
			hold on
			plot(cumsum_d_b,z_b,'.-b')
			
			
			breakpointsetzen=1;
			
			
			% % % 			% Den abgewickelten Rand in Polarkoordinaten überführen:
			% % % 			r_offset			= max([xmax_mm-xmin_mm;ymax_mm-ymin_mm])/2-min(T.Points(tp0,3))+dz_margin;
			% % % 			phi_t				= cumsum_d_t/cumsum_d_t(end)*2*pi;
			% % % 			r_t				= T.Points(tp0,3)+r_offset;
			% % % 			phi_b				= cumsum_d_b/cumsum_d_b(end)*2*pi;
			% % % 			r_b				= T.Points(bp0,3)+r_offset-dz_margin;
			% % % 			% Oberen und unteren Rand als Polygon in der Ebene darstellen:
			% % %
			% % % 			x_t				= r_t.*cos(phi_t);
			% % % 			y_t				= r_t.*sin(phi_t);
			% % % 			x_b				= r_b.*cos(phi_b);
			% % % 			y_b				= r_b.*sin(phi_b);
			% % %
			% % %
			% % % 			hf					= figure;
			% % %				set(hf,'Tag','maplab3d_figure');
			% % % 			plot(x_t,y_t)
			% % % 			hold on
			% % % 			plot(x_b,y_b)
			
		end
		
end


%------------------------------------------------------------------------------------------------------------------
% Überhang / Abschrägung des Rands
%------------------------------------------------------------------------------------------------------------------

if (currpart_i_tile==1)&&(currpart_i_colprio==3)&&(currpart_i_part==1)
	test=1;
end

% Polygon des äußeren Rands (i_margin=1) auf der geringsten Höhe z, zum Füllen des Bodens:
poly_bot_margin	= [];

% max. step size in mm: must be greater or equal to 2*top_dx_mm and 2*top_dy_mm!
max_step_size		= max([0.5 2*top_dx_mm 2*top_dy_mm]);																		% !!!!!

% Number of steps for creating the overhang:
kmax	= ceil(dxy_overhang/max_step_size);

% Steigung der Randlinien begrenzen:
limit_gradient_single	= true;		% jede Linie einzeln
limit_gradient				= true;		% am Ende nocheimal über alle Linien
if limit_gradient_single
	% Steilheit nach oben begrenzen, sonst kann bei Sprüngen der Randlinie die Wandstärke zu dünn werden:
	if dz_margin<1
		gradient_max		= 1;
	else
		gradient_max		= dz_margin;
	end
	k_line		= 1;
	kmax_lines	= length(iT_lines{k_line,i_margin});
	% 1. Durchlauf: vorwärts:
	for k_lg=1:(2*kmax_lines)
		iT0		= iT_lines{k_line,i_margin}(vindexrest(k_lg  ,kmax_lines));
		iT1		= iT_lines{k_line,i_margin}(vindexrest(k_lg+1,kmax_lines));
		TP0		= T.Points(iT0,:);
		TP1		= T.Points(iT1,:);
		dxy		= sqrt((TP1(1,1)-TP0(1,1))^2+(TP1(1,2)-TP0(1,2))^2);
		if dxy<tol_1
			% zwei gleiche aufeinanderfolgende Stützstellen:
			T.Points(iT1,3)	= TP0(1,3);
		else
			dz						= TP1(1,3)-TP0(1,3);
			gradient				= min([gradient_max dz/dxy]);
			dz						= gradient*dxy;
			T.Points(iT1,3)	= TP0(1,3)+dz;
		end
	end
	% 2. Durchlauf: rückwärts:
	for k_lg=(2*kmax_lines):-1:1
		iT0		= iT_lines{k_line,i_margin}(vindexrest(k_lg  ,kmax_lines));
		iT1		= iT_lines{k_line,i_margin}(vindexrest(k_lg-1,kmax_lines));
		TP0		= T.Points(iT0,:);
		TP1		= T.Points(iT1,:);
		dxy		= sqrt((TP1(1,1)-TP0(1,1))^2+(TP1(1,2)-TP0(1,2))^2);
		if dxy<tol_1
			% zwei gleiche aufeinanderfolgende Stützstellen:
			T.Points(iT1,3)	= TP0(1,3);
		else
			dz						= TP1(1,3)-TP0(1,3);
			gradient				= min([gradient_max dz/dxy]);
			dz						= gradient*dxy;
			T.Points(iT1,3)	= TP0(1,3)+dz;
		end
	end
end

% Wenn der innere Rand nah am  äußeren Rand liegt, muss der Überhang verringert werden, da es sonst zu
% Überlappungen kommen kann:
% Den kleinsten Abstand zwischen dem äußeren und inneren Rand bestimmen und kmax evtl. begrenzen:
if (currpart_i_tile==1)&&(currpart_i_colprio==3)&&(currpart_i_part==1)
	test=1;
end
if size(iT_lines,2)>=2
	if GV.warnings_off
		warning('off','MATLAB:polyshape:repairedBySimplify');
	end
	margin_outer_poly		= polyshape(...
		T.Points(iT_lines{1,1},1),...
		T.Points(iT_lines{1,1},2),'KeepCollinearPoints',true);
	if GV.warnings_off
		warning('on','MATLAB:polyshape:repairedBySimplify');
	end
	% Es wird der minimale Abstand zwischen den Stützpunkten des äußeren Rands und denen der inneren Ränder
	% berechnet: Auflösung des äußeren Rands erhöhen:
	dmax_outer_poly		= 0.05;
	margin_outer_poly		= changeresolution_poly(margin_outer_poly,dmax_outer_poly,dmax_outer_poly/2,[]);
	d_margin_min			= 1e10;
	for i_inner_poly=2:size(iT_lines,2)
		
		% disp('Test in map2stl: Überhang verringern:');
		% global margin_inner_poly margin_outer_poly T iT_lines
		% margin_outer_poly
		% margin_inner_poly
		% margin_outer_poly.Vertices
		% margin_inner_poly.Vertices
		% i_inner_poly=22,hf=figure,set(hf,'Tag','maplab3d_figure');ha=axes,hold(ha,'on');
		% plot(ha,T.Points(iT_lines{1,1},1),T.Points(iT_lines{1,1},2))
		% plot(ha,T.Points(iT_lines{1,i_inner_poly},1),T.Points(iT_lines{1,i_inner_poly},2))
		% title(sprintf('iT_lines=%g',i_inner_poly))
		
		if GV.warnings_off
			warning('off','MATLAB:polyshape:repairedBySimplify');
		end
		margin_inner_poly		= polyshape(...
			T.Points(iT_lines{1,i_inner_poly},1),...
			T.Points(iT_lines{1,i_inner_poly},2),'KeepCollinearPoints',true);
		if GV.warnings_off
			warning('on','MATLAB:polyshape:repairedBySimplify');
		end
		[vertexid,~,~] = ...
			nearestvertex(margin_outer_poly,margin_inner_poly.Vertices(:,1),margin_inner_poly.Vertices(:,2));
		for i=1:length(vertexid)
			d_margin_min		= min([d_margin_min sqrt(...
				(margin_outer_poly.Vertices(vertexid(i),1)-margin_inner_poly.Vertices(i,1))^2 + ...
				(margin_outer_poly.Vertices(vertexid(i),2)-margin_inner_poly.Vertices(i,2))^2       )]);
		end
	end
	% Sicherheitsfaktor, da sich die Punkte von äußerem und innerem Rand nicht gegenüberliegen:
	d_margin_min_korr	= d_margin_min/2;
	% Maximal möglicher Überhang: Exakt wäre es, den Überhang auf dxy_overhang_max=d_margin_min/2 zu begrenzen.
	% Dann könnten sich aber die Linien des äußeren und inneren Rands treffen:
	dxy_overhang_max	= d_margin_min_korr/4;
	% Anzahl Schritte evtl. begrenzen:
	if d_margin_min_korr<dmax_outer_poly
		kmax_limit	= 0;
	else
		kmax_limit	= max([0 floor(dxy_overhang_max/max_step_size)]);
	end
else
	kmax_limit	= kmax+1;
end

% kmax begrenzen:
kmax	= min([kmax kmax_limit]);

if (currpart_i_tile==1)&&(currpart_i_colprio==3)&&(currpart_i_part==1)
	test=1;
end
for i_margin=1:size(iT_lines,2)
	
	% Anzahl vorhandener Zeilen in iT_lines:
	line_no					= 1;
	
	% lower edge of the vertical margin as polygon:
	if GV.warnings_off
		warning('off','MATLAB:polyshape:repairedBySimplify');
	end
	poly_out	= polyshape(...
		T.Points(iT_lines{1,i_margin},1),...
		T.Points(iT_lines{1,i_margin},2),'KeepCollinearPoints',true);
	if GV.warnings_off
		warning('on','MATLAB:polyshape:repairedBySimplify');
	end
	
	% Die Kontur des Randes um dxy_rand_mm in mehreren Schritten nach innen (i_margin=1) oder nach außen
	% (i_margin=2) versetzen und die Höhe setzen (damit an 90°-Ecken kein horizontaler Überhang entsteht):
	if dxy_overhang>0
		% Es gibt einen Überhang:
		k		= 0;
	else
		% Es gibt keinen Überhang (kmax=0):
		% Den unteren Rand auf Bodennivea bringen, dann kann direkt die Bodenfläche erstellt werden:
		k		= 1;
		T.Points(iT_lines{1,i_margin},3)	= z_bottom;
	end
	while k<(kmax+2)
		k		= k+1;
		% 1:kmax		Überhang erstellen
		% kmax+1		Polygon auf der Höhe der unteren Kante
		% kmax+2		Boden füllen
		
		% Die Kontur nach innen versetzen:
		if k<=kmax
			d_polybuffer	= -dxy_overhang/kmax;
			if i_margin>=2
				% Bei dem Rand handelt es sich um ein Loch im Druckteil:
				% Kontur statt nach innen nach außen versetzen:
				d_polybuffer	= -d_polybuffer;
			end
			% Joint type for buffer boundaries, specified as one of the following:
			% 'round'	Round out boundary corners.
			% 'square'	Square off boundary corners.
			% 'miter'	Limit the ratio between the distance a joint vertex is moved and the buffer distance to 3.
			%				This limit prevents excessive pointiness.
			jointtype='round';		% 'round' (default) | 'square' | 'miter'
			% Miter limit, specified as a positive numeric scalar greater than or equal to 2. The miter limit is
			% the ratio between the distance a joint vertex is moved and the buffer distance. Setting a miter limit
			% controls the pointiness of boundary joints.
			miterlimit=2;
			if strcmp(jointtype,'miter')
				poly_in		= polybuffer(poly_out,d_polybuffer,'JointType',jointtype,...
					'MiterLimit',miterlimit);
			else
				poly_in		= polybuffer(poly_out,d_polybuffer,'JointType',jointtype);
			end
			% Increase the resolution of the inner polygon:
			dmax_poly_in	= max_step_size/2;																					% !!!!!
			poly_in			= changeresolution_poly(poly_in,dmax_poly_in,dmax_poly_in/2.5,[]);
			% Assign the polygon poly for triangulation or cancel the calculation of the overhead:
			if numboundaries(poly_in)==0
				% There remains no data in poly_in:
				% Cancel:
				% eval('i_margin,k,kmax,d_polybuffer,currpart_i_tile,currpart_i_colprio,currpart_i_part');
				% errormessage;
				% weiter mit: Verbindung zum Boden:
				k=kmax+1;
			else
				if numboundaries(poly_out)~=numboundaries(poly_in)
					% In the case of partially thin objects, the object can be broken down into individual parts:
					% Cancel:
					% eval('i_margin,k,kmax,d_polybuffer,currpart_i_tile,currpart_i_colprio,currpart_i_part');
					% eval('numboundaries_poly_out=numboundaries(poly_out)');
					% eval('numboundaries_poly_in=numboundaries(poly_in)');
					% errormessage;
					% weiter mit: Verbindung zum Boden:
					k=kmax+1;
				else
					poly			= addboundary(poly_out,poly_in.Vertices,'KeepCollinearPoints',true);
				end
			end
		end
		if k==(kmax+2)
			% Boden füllen:
			if size(iT_lines,2)==1
				% Es gibt nur den äußeren Rand:
				poly			= poly_out;
			else
				% Es gibt einen äußeren Rand und mindestens einen inneren Rand:
				% Test:
				% if (currpart_i_tile==3)&&(currpart_i_colprio==5)&&(currpart_i_part==5)
				% 	hf=figure(1357246);
				% 	clf(hf,'reset');
				%	set(hf,'Tag','maplab3d_figure');
				% 	ha1=subplot(3,1,1);
				% 	plot(ha1,poly_out);
				% 	title(ha1,...
				% 		sprintf('i_margin=%g, / poly_out',i_margin),...
				% 		'Interpreter','none');
				% 	test=1;
				% end
				if i_margin==1
					% Den äußeren Rand für i_margin=2 speichern, das Füllen vorerst überspringen:
					poly_bot_margin	= poly_out;
				else
					% Den inneren und äußeren Rand vereinen, so dass die Triangulation dazwischen durchgeführt wird:
					poly_bot_margin	= addboundary(poly_bot_margin,poly_out.Vertices,'KeepCollinearPoints',true);
					poly					= poly_bot_margin;
				end
				% if (currpart_i_tile==3)&&(currpart_i_colprio==5)&&(currpart_i_part==5)
				% 	ha2=subplot(3,1,2);
				% 	plot(ha2,poly_bot_margin);
				% 	title(ha2,'poly_bot_margin','Interpreter','none');
				% 	ha3=subplot(3,1,3);
				% 	hold(ha3,'on');
				% 	plot(ha3,T.Points(iT_lines{1,1},1),T.Points(iT_lines{1,1},2),'-r');
				% 	plot(ha3,poly_out);
				% 	plot(ha3,poly_bot_margin);
				% 	title(ha3,'poly_out, poly_bot_margin','Interpreter','none');
				% 	test=1;
				% end
			end
		end
		
		if k==kmax+1
			% Verbindung von der untersten Linie des Überhangs zum Boden:
			% Diese Verbindung soll genau senkrecht verlaufen, daher wird hier manuell trianguliert.
			
			% Indices des inneren Polygons für die Anzeige speichern:
			line_no_t						= line_no;
			line_no							= line_no+1;
			iT_lines{line_no,i_margin}	= zeros(0,1);
			% 1. Punkt hinzufügen:
			i									= 1;
			tp0_kstart						= iT_lines{line_no_t,i_margin}(i);
			T.Points							= [T.Points;T.Points(tp0_kstart,:)];
			T.Points(end,3)				= z_bottom;
			iT_lines{line_no,i_margin}	= size(T.Points,1);
			bp0_kstart						= iT_lines{line_no,i_margin}(end  );
			% Senkrechte Fläche triangulieren:
			imax		= size(iT_lines{line_no_t,i_margin},1);
			for i=1:imax
				% Indices der oberen (t) und unteren (b) Linien in T.Points:
				tp0									= iT_lines{line_no_t,i_margin}(i);
				tp1									= iT_lines{line_no_t,i_margin}(vindexrest(i+1,imax));
				if i<imax
					T.Points							= [T.Points;T.Points(tp1,:)];
					T.Points(end,3)				= z_bottom;
					iT_lines{line_no,i_margin}	= [iT_lines{line_no,i_margin};size(T.Points,1)];
					bp0								= iT_lines{line_no,i_margin}(end-1);
					bp1								= iT_lines{line_no,i_margin}(end  );
				else
					bp1								= bp0_kstart;
				end
				% Punkte 0 und 1 "vernähen":
				%   	1)	tp0     tp1		2)	tp0--<--tp1
				%         | \                 \     |
				%         v   \                 \   ^
				%         |     \                 \ |
				%      	bp0-->--bp1	   	bp0     bp1
				% T.ConnectivityList	= [T.ConnectivityList;...
				%	bp0 bp1 tp0;...		% 1)
				%	bp1 tp1 tp0];			% 2)
				T.ConnectivityList	= [T.ConnectivityList;...
					bp0 tp0 bp1;...		% 1)
					bp1 tp0 tp1];			% 2)
			end
			poly_out	= polyshape(...
				T.Points(iT_lines{line_no,i_margin},1),...
				T.Points(iT_lines{line_no,i_margin},2),'KeepCollinearPoints',true);
			
		else
			% Das Polynom poly triangulieren:
			
			if ~((size(iT_lines,2)>=2) && (i_margin<size(iT_lines,2)) && (k==(kmax+2)))
				% nicht ausführen wenn:
				% - Es gibt mindestens einen inneren Rand und
				% - Es soll der Boden des äußeren Rands berechnet werden
				
				% Triangulation zwischen poly_in und poly_out:
				if (currpart_i_tile==1)&&(currpart_i_colprio==3)&&(currpart_i_part==1)
					test=1;
				end
				
				% Prüfen ob die Fläche des Bodens mit Stützstellen aufgefüllt werden muss:
				if (k==(kmax+2))&&(PP_local.colorspec(icolspec).bottom_version==2)
					% Es wird der Boden trianguliert und
					% die Unterseite der aktuellen Farbschicht folgt dem Gelände:
					% poly schrittweise nach innen verlagern und dazwischen triangulieren:
					poly_v	= polyshape();
					i_poly_v	= 0;
					poly_bot_out	= poly;
					dmax				= min([...
						ELE_local.elefiltset(ifs,1).dx_mm ...
						ELE_local.elefiltset(ifs,1).dy_mm]);
					while numboundaries(poly_bot_out)>0
						i_poly_v			= i_poly_v+1;
						poly_bot_in		= polybuffer(poly_bot_out,-dmax,'JointType','square');
						if numboundaries(poly_bot_in)==0
							% 2. Versuch mit halbem Abstand:
							poly_bot_in		= polybuffer(poly_bot_out,-dmax/2,'JointType','square');
						end
						if numboundaries(poly_bot_in)==0
							poly_v(i_poly_v,1)	= poly_bot_out;
						else
							% Calcuate the minimum distance between points:
							dmin			= dmax/3;
							% Set the max. and min. distance between points:
							% In the case there remains no data, switch off the warnings in order to avoid confusion:
							if GV.warnings_off
								warning('off','MATLAB:polyshape:boundary3Points');
								warning('off','MATLAB:polyshape:repairedBySimplify');
								warning('off','MATLAB:polyshape:boolOperationFailed');
							end
							poly_bot_in	= changeresolution_poly(poly_bot_in,dmax,dmin,[]);
							if GV.warnings_off
								warning('on','MATLAB:polyshape:boundary3Points');
								warning('on','MATLAB:polyshape:repairedBySimplify');
								warning('on','MATLAB:polyshape:boolOperationFailed');
							end
							% Possibly there remains no data in poly_bot_in:
							if numboundaries(poly_bot_in)==0
								poly_v(i_poly_v,1)	= poly_bot_out;
							else
								poly_v(i_poly_v,1)	= addboundary(poly_bot_out,poly_bot_in.Vertices,...
									'KeepCollinearPoints',true);
							end
						end
						poly_bot_out			= poly_bot_in;
					end
				else
					poly_v	= poly;
				end
				
				for i_poly_v=1:size(poly_v,1)
					
					if numboundaries(poly)==0
						test=1;
					end
					
					poly			= poly_v(i_poly_v,1);
					t_poly1		= triangulation(poly);
					
					% t_poly2: because the property 'Points' of t_poly1 is read only
					t_poly2							= [];
					t_poly2.Points					= t_poly1.Points;
					t_poly2.ConnectivityList	= t_poly1.ConnectivityList;
					% t_poly: will be modified
					t_poly	= t_poly2;
					
					% Wenn es sich um den Boden handelt wird die Reihenfolge der Stützpunkte in den Dreiecken umgekehrt,
					% damit die Flächennormalen nach unten zeigen:
					if k==kmax+2
						% t_poly2 ist der Boden:
						t_poly2.ConnectivityList	= t_poly2.ConnectivityList(:,[1 3 2]);
					end
					
					% z-Koordinate hinzufügen:
					if k<=kmax
						t_poly.Points(:,3)	= -dz_margin-dz_overhang*k/kmax+interp_ele(...
							t_poly.Points(:,1),...			% query points x
							t_poly.Points(:,2),...			% query points y
							ele_top_xyzm_mm,...				% elevation structure
							colno_T_Points,...				% color numbers
							GV.legend_z_topside_bgd,...	% legend background z-value
							poly_legbgd,...					% legend background polygon
							'interp2');							% interpolation method
					else
						t_poly.Points(:,3)	= z_bottom;
					end
					
					% Werte zu den Triangulationsdaten T hinzufügen,
					% Indices des inneren Polygons für die Anzeige speichern:
					line_no							= line_no+1;
					iT_lines{line_no,i_margin}	= zeros(0,1);
					for i_t=1:size(t_poly.Points,1)
						% Zeile des aktuellen Punkts in T.Points:
						T_rows												= false(size(T.Points,1),1);
						T_rows((iT_top(end)+1):size(T.Points,1))	= true;
						i_TP_logical										= false(size(T.Points,1),1);
						i_TP_logical(T_rows,1)							= (...
							(abs(T.Points(T_rows,1)-t_poly.Points(i_t,1))<tol_1)&...
							(abs(T.Points(T_rows,2)-t_poly.Points(i_t,2))<tol_1)    );
						i_TP													= find(i_TP_logical);
						if isempty(i_TP)
							% Der aktuelle Punkt mit dem Index i_t existiert noch nicht in T.Points:
							T.Points							= [T.Points;t_poly.Points(i_t,:)];
							i_TP								= size(T.Points,1);
							iT_lines{line_no,i_margin}	= [iT_lines{line_no,i_margin};i_TP];
						elseif length(i_TP)>=1
							% Der aktuelle Punkt mit dem Index i_t existiert bereits in T.Points:
							[~,i]		= min(T.Points(i_TP,3));
							i_TP		= i_TP(i);
						end
						% Den Index in t_poly.Points durch den Index in T.Points ersetzen:
						t_poly.ConnectivityList(t_poly2.ConnectivityList==i_t)	= i_TP;
					end
					% T.ConnectivityList erweitern:
					T.ConnectivityList	= [T.ConnectivityList;t_poly.ConnectivityList];
					
					% Steilheit nach oben begrenzen, sonst kann bei Sprüngen der Randlinie die Wandstärke zu dünn werden:
					if limit_gradient_single
						if dz_margin<1
							gradient_max		= 1;
						else
							gradient_max		= dz_margin;
						end
						k_line		= line_no;
						kmax_lines	= length(iT_lines{k_line,i_margin});
						% 1. Durchlauf: vorwärts:
						for k_lg=1:(2*kmax_lines)
							iT0		= iT_lines{k_line,i_margin}(vindexrest(k_lg  ,kmax_lines));
							iT1		= iT_lines{k_line,i_margin}(vindexrest(k_lg+1,kmax_lines));
							TP0		= T.Points(iT0,:);
							TP1		= T.Points(iT1,:);
							dxy		= sqrt((TP1(1,1)-TP0(1,1))^2+(TP1(1,2)-TP0(1,2))^2);
							if dxy<tol_1
								% zwei gleiche aufeinanderfolgende Stützstellen:
								T.Points(iT1,3)	= TP0(1,3);
							else
								dz						= TP1(1,3)-TP0(1,3);
								gradient				= min([gradient_max dz/dxy]);
								dz						= gradient*dxy;
								T.Points(iT1,3)	= TP0(1,3)+dz;
							end
						end
						% 2. Durchlauf: rückwärts:
						for k_lg=(2*kmax_lines):-1:1
							iT0		= iT_lines{k_line,i_margin}(vindexrest(k_lg  ,kmax_lines));
							iT1		= iT_lines{k_line,i_margin}(vindexrest(k_lg-1,kmax_lines));
							TP0		= T.Points(iT0,:);
							TP1		= T.Points(iT1,:);
							dxy		= sqrt((TP1(1,1)-TP0(1,1))^2+(TP1(1,2)-TP0(1,2))^2);
							if dxy<tol_1
								% zwei gleiche aufeinanderfolgende Stützstellen:
								T.Points(iT1,3)	= TP0(1,3);
							else
								dz						= TP1(1,3)-TP0(1,3);
								gradient				= min([gradient_max dz/dxy]);
								dz						= gradient*dxy;
								T.Points(iT1,3)	= TP0(1,3)+dz;
							end
						end
					end
					
					% Die Punkte in poly_in
					% - dürfen nicht höher liegen bzw.
					% - müssen um einen bestimmten Betrag (hier: abs(d_polybuffer)) tiefer liegen
					% als die Punkte in poly_out, mit denen sie über die Triangulation verbunden sind:
					if k<=kmax
						for i_in=1:size(poly_in.Vertices,1)
							% Zeilennummer row_TP_in des Punkts poly_in.Vertices(i_in,:) in T.Points:
							row_TP_in	= find(...
								(abs(poly_in.Vertices(i_in,1)-T.Points(:,1))<tol_1)&...
								(abs(poly_in.Vertices(i_in,2)-T.Points(:,2))<tol_1)    );
							row_TP_in(row_TP_in<=iT_top(end))	= [];
							for i_row_TP_in=1:size(row_TP_in,1)
								% Die ConnectivityList nach row_TP_in(i_row_TP_in) durchsuchen:
								% Ergebnis: Zeilennummern row_CL_in in der ConnectivityList
								%           Dreiecke, in denen der Punkt poly_in.Vertices(i_in,:) eine Ecke ist
								[row_CL_in,col_CL_in]	= find(T.ConnectivityList==row_TP_in(i_row_TP_in));
								% Höhe des Punkts in poly_out mit Verbindung zum aktuellen Punkt poly_in.Vertices(i_in,:):
								for i_row_CL_in=1:size(row_CL_in,1)
									z_poly_out	= 1e10;
									for col=1:3
										if col~=col_CL_in
											row_TP_out	= T.ConnectivityList(row_CL_in(i_row_CL_in),col);
											i_TP_out	= find(...
												(abs(poly_out.Vertices(:,1)-T.Points(row_TP_out,1))<tol_1)&...
												(abs(poly_out.Vertices(:,2)-T.Points(row_TP_out,2))<tol_1)    );
											if isscalar(i_TP_out)
												% Der Punkt T.Points(row_TP_out,:) gehört zu poly_out:
												z_poly_out	= min(z_poly_out,T.Points(row_TP_out,3));
											else
												if ~isempty(i_TP_out)
													errormessage;
												end
											end
										end
									end
								end
								% Höhe des aktuellen Punkts poly_in.Vertices(i_in,:) in T.Points anpassen:
								T.Points(row_TP_in(i_row_TP_in),3)	= min(...
									T.Points(row_TP_in(i_row_TP_in),3),...
									z_poly_out+d_polybuffer);			% d_polybuffer<0!
							end
						end
					end
					
				end		% Ende von: for i_poly_v=1:size(poly_v,1)
				
				% nächster Durchlauf:
				if k<kmax
					poly_out		= poly_in;
				end
				
			end			% Ende von: if ~((size(iT_lines,2)>=2) && (i_margin<size(iT_lines,2)) && (k==(kmax+2)))
		end				% Ende von: if k==kmax+1, else
	end					% Ende von: while k<(kmax+2)
	
	if (currpart_i_tile==1)&&(currpart_i_colprio==2)&&(currpart_i_part==4)
		test=1;
	end
	
	% Steilheit nach oben begrenzen, sonst kann bei Sprüngen der Randlinie die Wandstärke zu dünn werden:
	if limit_gradient
		if dz_margin<1
			gradient_max		= 1;
		else
			gradient_max		= dz_margin;
		end
		for k_line = 1:size(iT_lines,1)
			kmax_lines	= length(iT_lines{k_line,i_margin});
			% 1. Durchlauf: vorwärts:
			for k_lg=1:(2*kmax_lines)
				iT0		= iT_lines{k_line,i_margin}(vindexrest(k_lg  ,kmax_lines));
				iT1		= iT_lines{k_line,i_margin}(vindexrest(k_lg+1,kmax_lines));
				TP0		= T.Points(iT0,:);
				TP1		= T.Points(iT1,:);
				dxy		= sqrt((TP1(1,1)-TP0(1,1))^2+(TP1(1,2)-TP0(1,2))^2);
				if dxy<tol_1
					% zwei gleiche aufeinanderfolgende Stützstellen:
					T.Points(iT1,3)	= TP0(1,3);
				else
					dz						= TP1(1,3)-TP0(1,3);
					gradient				= min([gradient_max dz/dxy]);
					dz						= gradient*dxy;
					T.Points(iT1,3)	= TP0(1,3)+dz;
				end
			end
			% 2. Durchlauf: rückwärts:
			for k_lg=(2*kmax_lines):-1:1
				iT0		= iT_lines{k_line,i_margin}(vindexrest(k_lg  ,kmax_lines));
				iT1		= iT_lines{k_line,i_margin}(vindexrest(k_lg-1,kmax_lines));
				TP0		= T.Points(iT0,:);
				TP1		= T.Points(iT1,:);
				dxy		= sqrt((TP1(1,1)-TP0(1,1))^2+(TP1(1,2)-TP0(1,2))^2);
				if dxy<tol_1
					% zwei gleiche aufeinanderfolgende Stützstellen:
					T.Points(iT1,3)	= TP0(1,3);
				else
					dz						= TP1(1,3)-TP0(1,3);
					gradient				= min([gradient_max dz/dxy]);
					dz						= gradient*dxy;
					T.Points(iT1,3)	= TP0(1,3)+dz;
				end
			end
		end
	end
	
end

% Alle z-Werte auf den minimalen Wert der Unterseite begrenzen:
if PP_local.colorspec(icolspec).bottom_version==1
	% Die Unterseite der aktuellen Farbschicht ist eben:
	T_Points_zmin	= z_bottom*ones(size(T.Points,1),1);
elseif PP_local.colorspec(icolspec).bottom_version==2
	% Die Unterseite der aktuellen Farbschicht folgt dem Gelände:
	% Am tiefsten Punkt muss der z-Wert gleich z_bottom sein, ansonsten mit dem gleichen Abstand zum Gelände
	% dem Gelände folgen.
	z_v				= interp_ele(...
		T.Points(:,1),...							% query points x
		T.Points(:,2),...							% query points y
		ELE_local,...								% elevation structure
		colno,...									% color numbers
		GV.legend_z_topside_bgd,...			% legend background z-value
		poly_legbgd,...							% legend background polygon
		'interp2');									% interpolation method
	T_Points_zmin			= z_bottom-zmin+z_v;
	% z_min nach oben begrenzen auf z_bottom_max
	T_Points_zmax			= z_bottom_max*ones(size(T.Points,1),1);
	iT							= T_Points_zmin>T_Points_zmax;
	T_Points_zmin(iT,1)	= T_Points_zmax(iT,1);
else
	errormessage(sprintf([...
		'Error: The project parameter\n',...
		'colorspec(icolspec).bottom_version=%g\n',...
		'is not defined.'],...
		PP_local.colorspec(icolspec).bottom_version));
end
% Die z-Werte begrenzen:
iT					= T.Points(:,3)<T_Points_zmin;
T.Points(iT,3)	= T_Points_zmin(iT);


%------------------------------------------------------------------------------------------------------------------
% 3d-Darstellung des Ergebnisses
%------------------------------------------------------------------------------------------------------------------

if (currpart_i_tile==1)&&(currpart_i_colprio==2)&&(currpart_i_part==3)
	test=1;
end

% Testplots:
if testplot==1
	
	iT_bot			= ((iT_top(end) +1):size(T.Points          ,1))';
	iCL_bot			= ((iCL_top(end)+1):size(T.ConnectivityList,1))';
	
	hf		= figure(10060);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','triang');
	set(hf,'NumberTitle','off');
	cameratoolbar(hf,'Show');
	ha		= axes(hf);
	hold(ha,'on');
	
	% 	% Top side:
	% 	facealpha	= 0.2;			% Transparenz der Oberflächen		0.2
	% 	edgealpha	= 0.2;			% Transparenz der Kanten			0.2
	% 	F=[T.ConnectivityList(iCL_top,1) ...
	% 		T.ConnectivityList(iCL_top,2) ...
	% 		T.ConnectivityList(iCL_top,3) ...
	% 		T.ConnectivityList(iCL_top,1)];
	% 	patch(ha,'faces',F,'vertices',T.Points,...
	% 		'EdgeColor',[0 0 0],'FaceColor',[1 1 1]*0.95,'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
	% 	% Stützstellen der Oberseite:
	% 	plot3(ha,T.Points(iT_top,1),T.Points(iT_top,2),T.Points(iT_top,3),...
	% 		'LineWidth',0.5,'LineStyle','none','Color',[1 1 1]*0.85,...
	% 		'Marker','.','MarkerSize',8);
	
	% upper margin:
	for i_margin=1:size(iT_margin,2)
		plot3(ha,...
			T.Points(iT_margin{1,i_margin},1),...
			T.Points(iT_margin{1,i_margin},2),...
			T.Points(iT_margin{1,i_margin},3),...
			'LineWidth',0.5,'LineStyle','-','Color','r',...
			'Marker','.','MarkerSize',10);
	end
	
	% Bottom side:
	facealpha	= 0.4;			% Transparenz der Oberflächen		0.2
	edgealpha	= 0.4;			% Transparenz der Kanten			0.2
	F=[T.ConnectivityList(iCL_bot,1) ...
		T.ConnectivityList(iCL_bot,2) ...
		T.ConnectivityList(iCL_bot,3) ...
		T.ConnectivityList(iCL_bot,1)];
	patch(ha,'faces',F,'vertices',T.Points,...
		'EdgeColor',[0 0 0],'FaceColor',[1 1 1]*0.65,'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
	% Stützstellen der Unterseite:
	plot3(ha,T.Points(iT_bot,1),T.Points(iT_bot,2),T.Points(iT_bot,3),...
		'LineWidth',1.5,'LineStyle','none','Color',[1 1 1]*0.65,...
		'Marker','.','MarkerSize',8);
	% Linien auf der Unterseite:
	for i_margin=1:size(iT_lines,2)
		% lower margin:
		line_no=1;
		plot3(ha,...
			T.Points(iT_lines{line_no,i_margin},1),...
			T.Points(iT_lines{line_no,i_margin},2),...
			T.Points(iT_lines{line_no,i_margin},3),...
			'LineWidth',1.5,'LineStyle','-','Color','b',...
			'Marker','.','MarkerSize',10);
		plot3(ha,...
			T.Points(iT_lines{line_no,i_margin}(1,1),1),...
			T.Points(iT_lines{line_no,i_margin}(1,1),2),...
			T.Points(iT_lines{line_no,i_margin}(1,1),3),...
			'LineWidth',1.5,'LineStyle','none','Color','b',...
			'Marker','+','MarkerSize',8);
		plot3(ha,...
			T.Points(iT_lines{line_no,i_margin}(end,1),1),...
			T.Points(iT_lines{line_no,i_margin}(end,1),2),...
			T.Points(iT_lines{line_no,i_margin}(end,1),3),...
			'LineWidth',1.5,'LineStyle','none','Color','b',...
			'Marker','o','MarkerSize',8);
		% lines
		for line_no=2:size(iT_lines,1)
			plot3(ha,...
				T.Points(iT_lines{line_no,i_margin},1),...
				T.Points(iT_lines{line_no,i_margin},2),...
				T.Points(iT_lines{line_no,i_margin},3),...
				'LineWidth',1.5,'LineStyle','-','Color','k',...
				'Marker','.','MarkerSize',10);
		end
	end
	
	view(ha,3);
	title(ha,sprintf('i_tile=%g, i_colprio=%g, i_part=%g',...
		currpart_i_tile,currpart_i_colprio,currpart_i_part),'Interpreter','none');
	axis(ha,'equal');
	
	setbreakpoint	= 1;
	if (currpart_i_tile==1)&&(currpart_i_colprio==3)&&(currpart_i_part==1)
		test=1;
	end
	
end

if (currpart_i_tile==1)&&(currpart_i_colprio==7)&&(currpart_i_part==1)
	test=1;
end
if    ~isempty(find(isinf(T.Points)          ,1))||...
		~isempty(find(isnan(T.Points)          ,1))||...
		~isempty(find(isinf(T.ConnectivityList),1))||...
		~isempty(find(isnan(T.ConnectivityList),1))
	currpart_i_tile
	currpart_i_colprio
	currpart_i_part
	test=1;
end


