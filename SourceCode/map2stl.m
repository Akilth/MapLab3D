function map2stl(...
	map_tile_no,...
	map_pathname,...
	map_pathname_stl,...
	map_pathname_stl_repaired,...
	map_filename,...
	stl_filename,...
	msg,...
	maptype)
% map_tile_no						vector of the tile numbers to export to STL
%										=[]	export all tiles
% map_pathname						pathname of the map figure to be loaded
% map_pathname_stl				pathname of the files to be saved
% map_pathname_stl_repaired	pathname of the repaired files to be saved
% map_filename						filename of the map figure to be loaded
% stl_filename			standard (tiles of the map):	stl_filename='': the file name is assigned automatically
%							testsamples etc:					enter the filename here
% msg						Waitbar message
% maptype				=0		normal map
%							=1		Testsample
%
% Die Druckdaten werden von der Funktion map2stl.m erstellt. Es gilt:
% -	Es wird das Karten-Figure [map_pathname map_filename] geöffnet.
%		In der Eigenschaft 'UserData' des Figures sind die folgenden Variablen enthalten, die z. T. hier als
%		lokale Variablen zugewiesen und verwendet werden:
%			PP
%			ELE
%			MAP_OBJECTS
%			GV
%			ver_map
%			savetime_map
%		So sind alle Einstellungen in einem figure noch vorhanden, wenn es gespeichert und wieder geöffnet wird.
%
%		Inzwischen werden auch globale Variablen der Oberfläche genutzt: Das müsste überarbeitet werden!
%
% -	Es werden nur Polygone berücksichtigt.
%		In der Eigenschaft 'UserData' der Polygone müssen abhängig davon, um was es sich jeweils handelt,
%		folgende Informationen gespeichert sein:
%		1)	Objekte der Landkarte (Straßen, Flüsse, Schrift ...):
%			ud.color_no		row-number in PP.color
%			ud.dz				vertical height
%			ud.prio			priority
%			ud.surftype		surface type
%			If the object belongs to the legend:
%			ud.islegbgd		=true
%		2)	Ränder:
%			ud.tile_no     =-3:  Frame
%										Not used in map2stl.
%			ud.tile_no     =-2:  Edge of the entire map currently to be printed
%										Not used in map2stl.
%			ud.tile_no     =-1:	Edge of the entire map with the planned maximum dimensions		(poly_map_maxdim)
%										("Limits of the OSM data" or "OSM data limits")
%			ud.tile_no     =0:	Edge of the entire map currently to be printed						(poly_map)
%										("Edges of the map to be printed" or "printout limits")
%										Alle Kacheln werden auf poly_map beschnitten.
%			ud.tile_no     =i:	Edge of the tile i
% -	Die restlichen für die Auswertung benötigten Informationen stehen in der Struktur PP.
% -	Es ist möglich, einem Objekt die Farbnummer ud.color_no=0 zuzuweisen (gibt es nicht in PP.color).
%		Dann wird die Farbe der Fläche verwendet, die unterhalb dieses Objekts liegt. Beispiel:
%		Eine Straße führt über die Grundfarbe grün (Wald/Wiese) und die Farbe rot (Besiedlung). Dann erscheint sie
%		über beiden Gebieten als Erhebung (aber nur wenn sie auch eine höhere Priorität hat).
% -	Texte können mit Hilfe der Funktion text2poly in ein Polygon umgewandelt werden.
%		Die Paraemter no_frame und no_bgd sind in der Funktion image2poly erklärt (unter "Initializations").
%		text2poly kann ohne Parameter aufgerufen werden und verwendet dann die Standardeinstellung in image2poly.
%		Durch Änderung der Standardeinstellungen in image2poly lassen sich die Funktionen ausprobieren.
% -	Die Funktion line2poly wandelt eine Linie in ein Polygon mit einstellbarer Breite um.
%		line2poly lässt sich zum Testen ohne Parameter aufrufen.
%
% Relevante Daten werden in der Struktur PRINTDATA gespeichert:
% PRINTDATA wird hier neu erstellt, ein eventuell vorhandenes Feld PRINTDATA.frame aber nicht gelöscht.
% Inhalt:
% ...
% zmin		minimale Geländehöhe z auf der Fläche und dem Rand des Objekts (ohne dz)):
% ...
% stand-alone colors:
%		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmin_TPoints
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmax_TPoints
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).area
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmin
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).z_bottom
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).z_bottom_max
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).obj_bot_bh_reg
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T.Points
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T.ConnectivityList
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).iT_margin
% non-stand-alone colors:
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmin_TPoints
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmax_TPoints
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).area
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmin
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).z_bottom
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).z_bottom_max
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).obj_bot_bh_reg
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T.Points
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T.ConnectivityList
%		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).iT_margin
% Saving the data:
%		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmin_TPoints
%		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmax_TPoints
%		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).area
%		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).text_xyz(i_part_stal,:)
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).text_str{i_part_stal,:}
%		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).filename_stl
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmin_TPoints
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmax_TPoints
%		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).area
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).text_xyz(i_part,:)
% 		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).text_str{i_part,:}
%		PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).filename_stl
% Other data:
%		PRINTDATA.z_bottom
%		PRINTDATA.z_bottom_max
%		PRINTDATA.frame.xmin
%		PRINTDATA.frame.xmax
% 		PRINTDATA.frame.ymin
%		PRINTDATA.frame.ymax
%		PRINTDATA.xmin
%		PRINTDATA.xmax
%		PRINTDATA.ymin
%		PRINTDATA.ymax
% 		PRINTDATA.obj
%		PRINTDATA.obj_top_reg
%		PRINTDATA.obj_reg
% 		PRINTDATA.tile_no_all_v
% 		PRINTDATA.tile(i_tile).xmin
% 		PRINTDATA.tile(i_tile).xmax
% 		PRINTDATA.tile(i_tile).ymin
% 		PRINTDATA.tile(i_tile).ymax
%		PRINTDATA.obj_union_equalcolors
% 		PRINTDATA.col(i_colprio).obj_nextcolprio.poly(iobj)   or   .poly(i_part_ncp)
% 		PRINTDATA.col(i_colprio).obj_nextcolprio.colno(iobj)
% 		PRINTDATA.col(i_colprio).obj_nextcolprio.dz(iobj)
% 		PRINTDATA.col(i_colprio).obj_nextcolprio.z_bot(iobj)
% 		PRINTDATA.col(i_colprio).obj_nextcolprio.zbotmax(iobj)
% 		PRINTDATA.col(i_colprio).obj_nextcolprio.zmin(iobj
% 		PRINTDATA.col(i_colprio).obj_nextcolprio.zmax(iobj
% 		PRINTDATA.col(i_colprio).obj_nextcolprio.colprio(iobj)
% 		PRINTDATA.col(i_colprio).obj_nextcolprio.srftype(iobj)
%		PRINTDATA.colprio_visible										vector of all available visible colors/color priorities
% Data required for the assignment of non-stand-alone colors:
% 		PRINTDATA.stal_parts.i_tile(i,1)
% 		PRINTDATA.stal_parts.i_colprio_stal(i,1)
% 		PRINTDATA.stal_parts.i_part_stal(i,1)
% 		PRINTDATA.stal_parts.i_part_ncp(i,1)
% 		PRINTDATA.stal_parts.xmin(i,1)
% 		PRINTDATA.stal_parts.xmax(i,1)
% 		PRINTDATA.stal_parts.ymin(i,1)
% 		PRINTDATA.stal_parts.ymax(i,1)
% 		PRINTDATA.stal_parts.x_center(i,1)
% 		PRINTDATA.stal_parts.y_center(i,1)
% 		PRINTDATA.stal_parts.poly(i,1)


global GV GV_H APP PRINTDATA WAITBAR VER

try
	
	if nargin==0
		map_tile_no		= [];
	end
	if nargin<4
		stl_filename	= '';
	end
	if nargin<5
		msg				= '';
	end
	
	% Display state:
	t_start_statebusy	= clock;
	stateisbusy	= display_on_gui('state','','isbusy');
	if ~stateisbusy
		display_on_gui('state','Creating STL files ...','busy','add');
	end
	
	% Set the value of the cutting lines dropdown menu to 'None' (make the map objects visible):
	set_previewtype_dropdown(1);
	
	% Waitbar:
	WAITBAR.t1	= clock;
	msg_add		= sprintf('top side');
	if ~isempty(msg)
		msg_add	= sprintf('%s: %s',msg,msg_add);
	end
	set(GV_H.text_waitbar,'String',sprintf('%s',msg_add));
	drawnow;
	
	% Test:
	if nargin<=1
		save_project;
		map_pathname	= 'G:\Daten\STA\Themen\Reliefkartendruck\Projekte\TP\';
		map_pathname	= 'C:\Daten\STA\Themen\Reliefkartendruck\Projekte\TP\';
		map_pathname_stl	= [map_pathname '\STL'];
		map_filename	= 'TP - MAP.fig';
	end
	
	% Check if the map is saved (not necessary for test samples):
	if isempty(stl_filename)
		cancel	= false;
		if isempty(GV)
			cancel	= true;
		else
			if ~isfield(GV,'map_is_saved')
				cancel	= true;
			else
				if GV.map_is_saved==0
					cancel	= true;
				end
			end
		end
		if cancel
			errortext	= sprintf('Error: Before exporting to STL, the project must be saved.');
			errormessage(errortext);
		end
	end
	
	% Tolerance for comparison of vertex coordinates:
	tol_1		= GV.tol_1;
	
	% Tolerance for plausibility questions
	tol_2		= GV.tol_2;
	
	% Nach dem Verschieben von Polygonen um eine bestimmte Distanz nach außen oder innen (polybuffer) können Punkte
	% sehr nah beieinander liegen, so dass sie mit der gegebenen Toleranz tol_1 nicht mehr unterschieden werden können.
	
	warnings_off	= true;		% true: Warnings are off, false: Warnings are on
	
	testplot_xylimits(1,1)		= 17;			% xmin
	testplot_xylimits(2,1)		= 27;			% xmax
	testplot_xylimits(3,1)		= 11;			% ymin
	testplot_xylimits(4,1)		= 16;			% ymax
	testplot_xylimits				= [];
	
	% Testplots:
	% 0: aus
	% 1: ein
	% 2: für unterschiedliche Werte currpart_i_tile, currpart_i_colprio, currpart_i_part jew. ein Fenster
	testout						= 0;
	testout_dzbot				= 0;
	testout_topside			= testout;
	testout_botside			= testout;
	% obj_all:			Objekte mit der colprio=-1 sind noch nicht einer Farbe zugewiesen:
	testplot_obj_all			= 0;	% 10001
	testplot_obj_all_top		= 0;	% 10011 Liste aller Objekte, sort. nach Objektpriorität: nur von oben sichtbaren Teil
	% obj:	Objekten mit der colprio=-1 wurde die Farbe des darunter liegenden Teils zugewiesen:
	testplot_obj				= 0;	% 10002
	testplot_obj_top			= 0;	% 10012/10013 Liste aller Objekte, sort. nach Objektpriorität: nur von oben sichtbaren Teil
	testplot_obj_cut			= 0;	% 10014 Cut into pieces: Liste aller Objekte nach dem Zerteilen
	testplot_poly_cut			= 0;	% 10015 Cut into pieces: Schnittlinien
	testplot_obj_reg_1plot	= 0;	% 10016 Unters der mit einer anderen Farbe als die Grundfarbe einzusetz. Teile
	testplot_obj_reg			= 0;	% 10017 Unters der mit einer anderen Farbe als die Grundfarbe einzusetz. Teile
	% Berechnungen in map2stl_topside_triangulation, die für jede Farbe wiederholt werden:													Zeile
	testplot_obj_bot_reg_1plot		= 0;	% 10021 Unterseiten , alle Teile außer der Grundfarbe als einzelne Regionen		2468
	testplot_obj_bot_reg				= 0;	% 10022 =0/1/2! Unterseiten , alle Teile außer der Grundfarbe als einzelne Regionen
	testplot_obj_ncp					= 0;	% 10028 =0/1/2! obj_nextcolprio
	testplot_obj_ncp_1plot			= 0;	% 10029 obj_nextcolprio
	testplot_obj_bot_bh_1plot		= 0;	% 10024 Unterseite, Löcher vergrößert, dfamit die höherlieg. Teile hineinpassen	2800
	testplot_obj_bot_bh				= 0;	% 10023 Unterseite, Löcher vergrößert, dfamit die höherlieg. Teile hineinpassen
	testplot_obj_bot_bh_reg_1plot	= 0;	% 10026 Unterseite, Löcher vergrößert, nur einzelne Regionen, sortiert nach dz	3234
	testplot_obj_bot_bh_reg			= 0;	% 10025 Unterseite, Löcher vergrößert, nur einzelne Regionen, sortiert nach dz
	testplot_triang_hareas			= 0;	% 10027 Berechnung der Triangulation für alle horizontale Flächen						4144
	testplot_triang_top				= 0;	% 10050 Ergebnis der Triangulation der Oberseite
	% Berechnungen in map2stl_botside_triangulation, die für jede Farbe wiederholt werden:
	testplot_triang_bot				= 0;	% 10060 Ergebnis der Triangulation der Unterseite
	% Darstellung der fertigen Teile:
	testplot_triang_currpart		= 0;	% 10100: Ergebnis der Triangulation, current part
	testplot_tile						= 0;	% figure of the tiles
	testplot_tile_colno				= 0;	% figure of each color separately
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Open map:
	%------------------------------------------------------------------------------------------------------------------
	
	hf_map			= openfig([map_pathname map_filename],'invisible');
	figure_theme(hf_map,'set',[],'light');
	set(hf_map,'Tag','maplab3d_figure');
	set(hf_map,'WindowStyle','normal');		% open in a standalone window (not docked)
	
	% Projekt parameters and elevation data:
	fig_userdata	= get(hf_map,'UserData');
	if ~isfield(fig_userdata,'PP')||~isfield(fig_userdata,'ELE')
		errormessage(sprintf('Error: The map\n%s\ndoes not contain the required data.',...
			[map_pathname map_filename]));
	end
	PP_local			= fig_userdata.PP;
	ELE_local		= fig_userdata.ELE;
	
	
	%------------------------------------------------------------------------------------------------------------
	% obj, obj_top, obj_reg
	%------------------------------------------------------------------------------------------------------------
	% Hier finden Vereinfachungen der Polygone statt:
	% obj:     - Alle Polygone auf den Rand der Kachel beschnitten.
	%          - Polygone mit gleicher Höhe, Objekt- und Farbpriorität zu einem Polygon vereint.
	%          - Sortiert nach Objektpriorität
	% obj_top: - Enthält nur den von oben sichtbaren Teil
	%            Vollständig leere Objekte brauchen dann nicht mehr betrachtet werden und werden gelöscht.
	% obj_reg: - Alle Objekte mit Farbpriorität größer als die Grundfarbe sortiert nach Regionen.
	%          - Berechnung von obj.z_bot und obj.zbotmax: Hier sollte auch nach Regionen unterschieden werden, damit
	%            die Löcher nicht unnötig tief sind, um Druckzeit und Material zu sparen: Ab hier jede Region
	%            einzeln betrachten (außer die Polygone mit der Grundfarbe).
	%          - Wenn sich Objekte mit unterschiedlicher Objektpriorität aber gleicher Farbe überlappen,
	%            werden sie später verbunden. In diesem Fall muss für die Berechnung der Lochtiefe die negativere
	%            Höhe der beteiligten Objekteverwendet werden.
	% Ergebnis:
	% 1) obj			Liste aller Objekte, sortiert nach Objektpriorität
	%					obj.poly(iobj)
	%					obj.colno(iobj)
	%					obj.dz(iobj)
	%					obj.zmax(iobj)
	%					obj.objprio(iobj)
	%					obj.colprio(iobj)
	%					obj.srftype(iobj)
	% 2) obj_top	Liste aller Objekte, sortiert nach Objektpriorität: nur von oben sichtbaren Teil
	%					obj_top.poly(iobj)
	%					obj_top.colno(iobj)
	%					obj_top.dz(iobj)
	%					obj_top.zmax(iobj)
	%					obj_top.objprio(iobj)
	%					obj_top.colprio(iobj)
	%					obj_top.srftype(iobj)
	% 3) obj_reg	Alle Objekte mit Farbpriorität größer als die Grundfarbe sortiert nach Regionen
	%					obj_reg.poly(iobj)
	%					obj_reg.colno(iobj)
	%					obj_reg.dz(iobj)
	%					obj_reg.z_bot(iobj)		Absenkung der Löcher für Teile anderer Farben gegenüber der Geländehöhe
	%													enthält bereits die Wert zmin und dz aller Teile oberhalb
	%													z_bot ist der ABSOLUTE z-Wert der Oberseite des unterhalb des
	%													Objekts iobj liegenden Teils.
	%													z_bot ist also um d_bottom kleiner als die Unterseite des Objekts iobj.
	%					obj_reg.zbotmax			Maximale zulässiger Wert z_bot (entspricht z_bot_above_min)
	%													Wenn die Unterseite dem Gelände folgt, darf die Unterseite nicht höher
	%													werden als die Unterseite der darüber einzusetzenden Teile
	%													(abzüglich dz und Abstände).
	%					obj_reg.zmin(iobj)		minimale Geländehöhe z auf der Fläche und dem Rand des Objekts (ohne dz)
	%					obj_reg.zmax(iobj)		maximale Geländehöhe z auf dem Rand des Objekts (ohne dz)
	%					obj_reg.objprio(iobj)
	%					obj_reg.colprio(iobj)
	%					obj_reg.srftype(iobj)
	
	try
		[PRINTDATA.obj,...
			PRINTDATA.obj_top_reg,...
			PRINTDATA.obj_reg,...
			poly_tile,...
			PRINTDATA.tile_no_all_v,...
			PP_local,...
			ELE_local,...
			poly_legbgd...
			]=map2stl_preparation(...
			map_tile_no,hf_map,PP_local,ELE_local,msg_add,...
			testout,testout_dzbot,testplot_obj_all,testplot_obj_all_top,testplot_obj,testplot_obj_top,...
			testplot_obj_reg,testplot_obj_reg_1plot,testplot_obj_cut,testplot_poly_cut,testplot_xylimits);
	catch ME
		% The global variables defined in the function must also be defined globally outside:
		% required: global GV GV_H WAITBAR PRINTDATA
		errormessage('',ME);
	end
	
	% Save memory dump:
	if GV.save_memory_dump&&~isdeployed
		dump.no						= 1;
		[dump.pathname,dump.filename,~]	= fileparts(mfilename('fullpath'));
		C					= who;
		iC_delete		= [];
		for iC=1:size(C,1)
			if eval(sprintf('isa(%s,''matlab.ui.Figure'')',C{iC,1}))
				iC_delete		= [iC_delete;iC];
			end
		end
		C(iC_delete,:)	= [];
		[save_command,~]	= get_savecommand_errorlog(C,dump.pathname,'dump');
		eval(save_command);
	end
	
	% Figure axis limits:
	PRINTDATA.tile_axislimits	= PRINTDATA.tile;
	imax_tile						= length(poly_tile);
	
	%------------------------------------------------------------------------------------------------------------
	% Vorbereitung
	%------------------------------------------------------------------------------------------------------------
	
	% Figure wieder schließen:
	close(hf_map);
	
	% Alle vorhandenen sichtbaren Farben/Farbprioritäten bestimmen:
	PRINTDATA.colprio_visible	= sort(unique(PRINTDATA.obj_top_reg.colprio));
	PRINTDATA.colno				= zeros(length(PRINTDATA.colprio_visible),1);
	
	% Das erste Element in PRINTDATA.colprio_visible muss =0 sein (Grundfarbe),
	% selbst wenn die Grundfarbe vollständig von anderen Objekten bedeckt ist:
	if isempty(PRINTDATA.colprio_visible)
		errormessage;
	end
	if ~isequal(PRINTDATA.colprio_visible(1),0)
		errormessage;
	end
	
	% Außenabmessungen der als nächstes zu erstellenden Teile mit der nächsthöheren Farbe bzw.
	% Außenabmessungen der aktuellen Grundfarbe:
	i_colprio	= 1;
	i				= 0;
	for i_tile=1:imax_tile
		% Eine Kachel kann auch leer sein, z. B. wenn die printout limits verkleinert wurden:
		if numboundaries(poly_tile(i_tile))>0
			i		= i+1;
			PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i)		= poly_tile(i_tile);
			PRINTDATA.col(i_colprio).obj_nextcolprio.colno(i)		= PRINTDATA.obj_reg.colno(1);
			PRINTDATA.col(i_colprio).obj_nextcolprio.colprio(i)	= PRINTDATA.obj_reg.colprio(1);
			PRINTDATA.col(i_colprio).obj_nextcolprio.srftype(i)	= PRINTDATA.obj_reg.srftype(1);
			PRINTDATA.col(i_colprio).obj_nextcolprio.zmin(i)		= PRINTDATA.obj_reg.zmin(1);
		end
	end
	
	% Alle sichtbaren Farben bearbeiten:
	% Es gilt:
	% i_colprio=1 ist immer die Grundfarbe der Kachel: PRINTDATA.colprio_visible(1)=0
	
	imax_colprio			= length(PRINTDATA.colprio_visible);
	PRINTDATA.stal_parts	= [];
	for i_colprio=1:imax_colprio
		
		if i_colprio>=1
			setbreakpoint=1;
		end
		
		% In obj_nextcolprio.colprio ist der Wert der aktuellen Grundfarbe enthalten:
		% (PRINTDATA.col(i_colprio).obj_nextcolprio.colprio enthält gleiche Werte)
		if ~isempty(PRINTDATA.col(i_colprio).obj_nextcolprio)
			% Es gibt Teile der aktuellen Grundfarbe:
			% Bei der Berechnung des Bodens kann es passieren, dass wegen eines Überhangs Teile verschwinden.
			% Wenn alle Teile einer Farbe verschwinden, wird bei der Zuweisung von
			% PRINTDATA.col(i_colprio_new).obj_nextcolprio unten die Farbe übersprungen und
			% PRINTDATA.col(i_colprio).obj_nextcolprio ist leer.
			
			colprio_base							= PRINTDATA.colprio_visible(i_colprio);
			colno										= find([PP_local.color.prio]==colprio_base,1);
			PRINTDATA.colno(i_colprio)			= colno;
			icolspec									= PP_local.color(colno).spec;
			d_bottom									= PP_local.colorspec(icolspec).d_bottom;
			min_thickness							= PP_local.colorspec(icolspec).min_thickness;
			
			imax_part_ncp		= length(PRINTDATA.col(i_colprio).obj_nextcolprio.poly);
			for i_part_ncp=1:imax_part_ncp
				t_start_i_part	= clock;
				%---------------------------------------------------------------------------------------------------
				% i_part_ncp: Anfang
				%---------------------------------------------------------------------------------------------------
				
				% Save memory dump:
				if GV.save_memory_dump&&~isdeployed
					if     (i_colprio==1)              ||...
							((i_colprio >1)&&(i_part_ncp==1))
						dump.no						= 2;
						[dump.pathname,dump.filename,~]	= fileparts(mfilename('fullpath'));
						C					= who;
						iC_delete		= [];
						for iC=1:size(C,1)
							if eval(sprintf('isa(%s,''matlab.ui.Figure'')',C{iC,1}))
								iC_delete		= [iC_delete;iC];
							end
						end
						C(iC_delete,:)	= [];
						[save_command,~]	= get_savecommand_errorlog(C,dump.pathname,'dump');
						eval(save_command);
					end
				end
				
				% Test:
				if ((i_colprio==1)&&(i_part_ncp== 1))&&~isdeployed
					% %#exclude profile
					% profile off
					% profile on
					setbreakpoint=1;
				end
				
				% Fortschrittsanzeige:
				% i_colprio		= 1:imax_colprio
				% i_part_ncp	= 1:imax_part_ncp
				dx_colprio	= 0.5/imax_colprio;	% 0.5 wegen der zweiten Schleife nach Berechnung von z_bottom
				dx_part		= dx_colprio/imax_part_ncp;
				progress		= min((i_colprio-1)*dx_colprio + (i_part_ncp-1)*dx_part,1);
				msg_add		= sprintf('top side color %g/%g, part %g/%g',...
					i_colprio,imax_colprio,...
					i_part_ncp,imax_part_ncp);
				if ~isempty(msg)
					msg_add	= sprintf('%s: %s',msg,msg_add);
				end
				set(GV_H.text_waitbar,'String',sprintf('%s',msg_add));
				set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
				drawnow;
				
				% Ausgabe im Command-Window:
				fprintf(1,[...
					'top side: i_colprio = %g/%g (colno=%g)\n',...
					'          i_part    = %g/%g\n'],...
					i_colprio,imax_colprio,colno,...
					i_part_ncp,imax_part_ncp);
				
				%---------------------------------------------------------------------------------------------------
				% Triangulationsdaten der Oberseite des aktuellen Druckteils berechnen:
				%---------------------------------------------------------------------------------------------------
				
				% Das aktuelle Teil einer Kachel zuweisen, abhängig von den Außenabmessungen des aktuellen Teils:
				% (Außenabmessungen des aktuellen Teils: PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp))
				[x_center,y_center]		= centroid(PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp));
				i_tile	= [];
				for i=1:imax_tile
					% Eine Kachel kann auch leer sein, z. B. wenn die printout limits verkleinert wurden:
					if numboundaries(poly_tile(i))>0
						% Wenn die Karte Löcher enthält, hat auch die Kachel Löcher und isinterior/inpolygon
						% funktioniert eventuell nicht!
						% if isinterior(poly_tile(i),x_center,y_center)
						% if inpolygon(...									% faster than isinterior
						% 		x_center,...											% query points
						% 		y_center,...
						% 		poly_tile(i).Vertices(:,1),...		% polygon area
						% 		poly_tile(i).Vertices(:,2))
						% 	i_tile	= i;
						% 	break
						% end
						if    (x_center>=PRINTDATA.tile(i).xmin)&&...
								(x_center<=PRINTDATA.tile(i).xmax)&&...
								(y_center>=PRINTDATA.tile(i).ymin)&&...
								(y_center<=PRINTDATA.tile(i).ymax)
							i_tile	= i;
							break
						end
					end
				end
				if isempty(i_tile)
					errormessage(sprintf([...
						'The tiles possibly do not cover all\n',...
						'map objects inside the printout limits.']));
				end
				
				% Berechnung von i_colprio_stal, i_part_stal und ggf. Überschreiben von i_tile:
				% Zuordnung der non-stand-alone Farben:
				[xlim,ylim]		= boundingbox(PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp));
				xmin				= xlim(1);
				xmax				= xlim(2);
				ymin				= ylim(1);
				ymax				= ylim(2);
				i_part_stal		= 1;
				i_part			= 1;
				if i_colprio==1
					% tile base ==> colprio=0, i_colprio=1: stand-alone
					i_colprio_stal		= i_colprio;
				else
					% not tile base:
					if PP_local.color(colno).standalone_color~=0
						% The color is printed stand-alone and serves as a basis for non-stand-alone colors:
						i_colprio_stal		= i_colprio;
					else
						% The color is printed non-stand-alone in one operation together with other colors.
						i_overlap_found	= false;
						for i_colprio_stal=(i_colprio-1):-1:0
							if i_colprio_stal==0
								errormessage;
							end
							i_overlap_is_possible_v		= find(...
								(PRINTDATA.stal_parts.i_colprio_stal==i_colprio_stal)&~(...
								(PRINTDATA.stal_parts.xmin>(xmax+tol_1))|...
								(PRINTDATA.stal_parts.xmax<(xmin-tol_1))|...
								(PRINTDATA.stal_parts.ymin>(ymax+tol_1))|...
								(PRINTDATA.stal_parts.ymax<(ymin-tol_1))     ));
							if ~isempty(i_overlap_is_possible_v)
								distance_center_v				= sqrt(...
									(PRINTDATA.stal_parts.x_center(i_overlap_is_possible_v)-x_center).^2+...
									(PRINTDATA.stal_parts.y_center(i_overlap_is_possible_v)-y_center).^2);
								[~,ksort_v]							= sort(distance_center_v);
								i_overlap_is_possible_sort_v	= i_overlap_is_possible_v(ksort_v);
								for k=1:length(i_overlap_is_possible_sort_v)
									i_overlap				= i_overlap_is_possible_sort_v(k);
									% hf=4657483;
									% figure(hf);
									% clf(hf,'reset');
									% ha=axes;
									% hold(ha,'on');
									% axis(ha,'equal');
									% plot(ha,PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp));
									% plot(ha,PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp).Vertices(:,1),...
									% 	PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp).Vertices(:,2),'.k');
									% plot(ha,PRINTDATA.stal_parts.poly(i_overlap,1));
									if overlaps(...
											PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp),...
											PRINTDATA.stal_parts.poly(i_overlap,1))
										area_currpoly			= area(PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp));
										poly_intersect			= intersect(...
											PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp),...
											PRINTDATA.stal_parts.poly(i_overlap,1));
										area_intersect			= area(poly_intersect);
										if abs((area_currpoly-area_intersect)/area_intersect)<GV.tol_1
											% The current polygon PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp)
											% is completely inside PRINTDATA.stal_parts.poly(i_overlap,1):
											% Overwrite i_tile:
											i_tile		= PRINTDATA.stal_parts.i_tile(i_overlap,1);
											% Save i_part_stal:
											i_part_stal	= PRINTDATA.stal_parts.i_part_stal(i_overlap,1);
											% Keep the current value i_colprio_stal:
											i_overlap_found		= true;
											break
										end
									end
								end
								if i_overlap_found
									break
								end
							end
						end
					end
				end
				
				% Berechnung von i_part_stal, i_part:
				if isfield(PRINTDATA.tile(i_tile),'col_stal')
					if length(PRINTDATA.tile(i_tile).col_stal)>=i_colprio_stal
						if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'part_stal')
							if i_colprio_stal==i_colprio
								% The current color is stand-alone:
								% i_part is not necessary.
								i_part		= 0;
								i_part_stal	= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal)+1;
							else
								% The color is printed non-stand-alone in one operation together with other colors.
								% i_part_stal was calculated above.
								if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal),'col')
									if length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col)>=i_colprio
										if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio),'part')
											i_part	= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part)+1;
										end
									end
								end
							end
						end
					end
				end
				
				% Speicherung der für die Zuordnung der non-stand-alone Farben nötigen Daten:
				if PP_local.color(colno).standalone_color~=0
					% The color is printed stand-alone and serves as a basis for non-stand-alone colors:
					if (i_colprio==1)&&(i_part_ncp==1)
						% tile base ==> colprio=0, i_colprio=1
						i			= 1;
					else
						i			= size(PRINTDATA.stal_parts.i_tile,1)+1;
					end
					PRINTDATA.stal_parts.i_tile(i,1)				= i_tile;
					PRINTDATA.stal_parts.i_colprio_stal(i,1)	= i_colprio_stal;		% stand-alone Farbe
					PRINTDATA.stal_parts.i_part_stal(i,1)		= i_part_stal;
					PRINTDATA.stal_parts.i_part_ncp(i,1)		= i_part_ncp;
					PRINTDATA.stal_parts.xmin(i,1)				= xmin;
					PRINTDATA.stal_parts.xmax(i,1)				= xmax;
					PRINTDATA.stal_parts.ymin(i,1)				= ymin;
					PRINTDATA.stal_parts.ymax(i,1)				= ymax;
					PRINTDATA.stal_parts.x_center(i,1)			= x_center;
					PRINTDATA.stal_parts.y_center(i,1)			= y_center;
					PRINTDATA.stal_parts.poly(i,1)				= PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp);
				end
				
				% Außenabmessungen der aktuellen Kachel ggf. erweitern:
				% (Außenabmessungen des aktuellen Teils: PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp))
				PRINTDATA.tile_axislimits(i_tile).xmin	= min(PRINTDATA.tile_axislimits(i_tile).xmin,xmin);
				PRINTDATA.tile_axislimits(i_tile).xmax	= max(PRINTDATA.tile_axislimits(i_tile).xmax,xmax);
				PRINTDATA.tile_axislimits(i_tile).ymin	= min(PRINTDATA.tile_axislimits(i_tile).ymin,ymin);
				PRINTDATA.tile_axislimits(i_tile).ymax	= max(PRINTDATA.tile_axislimits(i_tile).ymax,ymax);
				
				% Das erste Polygon in obj.poly ist immer das mit den Außenabmessungen des aktuellen Teils.
				% (Außenabmessungen des aktuellen Teils: PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp))
				PRINTDATA.obj.poly(1)			= PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp);
				PRINTDATA.obj.colno(1)			= PRINTDATA.col(i_colprio).obj_nextcolprio.colno(i_part_ncp);
				PRINTDATA.obj.dz(1)				= 0;
				PRINTDATA.obj.objprio(1)		= 0;
				PRINTDATA.obj.colprio(1)		= colprio_base;
				PRINTDATA.obj.srftype(1)		= PRINTDATA.col(i_colprio).obj_nextcolprio.srftype(i_part_ncp);		% or =200
				PRINTDATA.obj_reg.poly(1)		= PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp);
				PRINTDATA.obj_reg.colno(1)		= PRINTDATA.col(i_colprio).obj_nextcolprio.colno(i_part_ncp);
				PRINTDATA.obj_reg.dz(1)			= 0;
				PRINTDATA.obj_reg.z_bot(1)		= 0;
				PRINTDATA.obj_reg.zbotmax(1)	= 0;
				PRINTDATA.obj_reg.zmin(1)		= 0;
				PRINTDATA.obj_reg.zmax(1)		= 0;
				PRINTDATA.obj_reg.objprio(1)	= 0;
				PRINTDATA.obj_reg.colprio(1)	= colprio_base;
				PRINTDATA.obj_reg.srftype(1)	= PRINTDATA.col(i_colprio).obj_nextcolprio.srftype(i_part_ncp);		% or =200
				
				% Druckdaten für die Farbe mit der Priorität colprio_base erstellen:
				partdata								= [];
				try
					[  partdata.T,...
						partdata.iT_margin,...
						obj_nextcolprio_temp,...
						partdata.obj_bot_bh_reg] = ...
						map2stl_topside_triangulation(...
						PRINTDATA.obj,...
						PRINTDATA.obj_reg,colprio_base,PP_local,ELE_local,poly_legbgd,...
						PRINTDATA.xmin,PRINTDATA.xmax,...
						PRINTDATA.ymin,PRINTDATA.ymax,...
						testout_topside,...
						testplot_obj_bot_reg_1plot,testplot_obj_bot_reg,testplot_obj_bot_bh_1plot,testplot_obj_bot_bh,...
						testplot_obj_bot_bh_reg_1plot,testplot_obj_bot_bh_reg,testplot_triang_hareas,...
						testplot_triang_top,testplot_obj_ncp,testplot_obj_ncp_1plot,testplot_xylimits,...
						i_tile,i_colprio,i_part_ncp,imax_part_ncp,msg_add);
				catch ME
					% The global variables defined in the function must also be defined globally outside:
					% required: global GV GV_H WAITBAR PRINTDATA
					errormessage('',ME);
				end
				% Sicherheitsabfrage:
				for i_margin=1:size(partdata.iT_margin,2)
					if max(partdata.iT_margin{1,i_margin})>size(partdata.T.Points,1)
						% Save errorlog:
						i_tile
						i_colprio_stal
						i_part_stal
						i_colprio
						i_part
						i_margin
						errormessage;
					end
				end
				
				% Fläche:
				partdata.area				= area(PRINTDATA.col(i_colprio).obj_nextcolprio.poly(i_part_ncp));
				
				% Höhe des Bodens:
				if colprio_base==0
					% Es handelt sich um die Kachel-Grundfläche: z_bottom anders berechnen:
					z_bottom_tilebase			= min(partdata.T.Points(:,3))-min_thickness;
					partdata.z_bottom			= z_bottom_tilebase;
					partdata.z_bottom_max	= z_bottom_tilebase;
					if ~isfield(PRINTDATA.tile(i_tile),'z_bottom')
						PRINTDATA.tile(i_tile).z_bottom	= z_bottom_tilebase;
					elseif isempty(PRINTDATA.tile(i_tile).z_bottom)
						PRINTDATA.tile(i_tile).z_bottom	= z_bottom_tilebase;
					else
						PRINTDATA.tile(i_tile).z_bottom	= min(PRINTDATA.tile(i_tile).z_bottom,z_bottom_tilebase);
					end
				else
					% Es handelt sich nicht um die Kachel-Grundfläche:
					% In z_bottom und zbotmax ist noch der Abstand zu unterlagerten Farben enthalten:
					% wieder addieren:
					partdata.z_bottom			= PRINTDATA.col(i_colprio).obj_nextcolprio.z_bot(i_part_ncp)   + d_bottom;
					partdata.z_bottom_max	= PRINTDATA.col(i_colprio).obj_nextcolprio.zbotmax(i_part_ncp) + d_bottom;
				end
				
				% zmin (minimale Geländehöhe z auf der Fläche und dem Rand des Objekts (ohne dz)):
				partdata.zmin	= PRINTDATA.col(i_colprio).obj_nextcolprio.zmin(i_part_ncp);
				
				% Daten der Struktur PRINTDATA zuweisen:
				if PP_local.color(colno).standalone_color~=0
					% The color is printed stand-alone and serves as a basis for non-stand-alone colors:
					PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal)	= partdata;
					
					% Flächen der stand-alone Farben aufsummieren (alle Teile, die in einer Datei gespeichert werden):
					if i_part_stal==1
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).area				= partdata.area;
					else
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).area				= ...
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).area + partdata.area;
					end
					
				else
					% The color is printed non-stand-alone in one operation together with other colors:
					PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part)	= partdata;
					
					% Flächen der non-stand-alone Farben aufsummieren (alle Teile, die in einer Datei gespeichert werden):
					if i_part==1
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).area				= partdata.area;
					else
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).area				= ...
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).area + partdata.area;
					end
					
					% Flächen aller Teile dieser Farbe auf der aktuellen Kachel aufsummieren (non-stand-alone Teile der
					% Farbe i_colprio, die auf allen stand-alone-Teilen der Farbe i_colprio_stal gedruckt werden):
					if length(PRINTDATA.tile(i_tile).col_stal)<i_colprio
						PRINTDATA.tile(i_tile).col_stal(i_colprio).area				= partdata.area;
					else
						if ~isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio),'area')
							PRINTDATA.tile(i_tile).col_stal(i_colprio).area				= partdata.area;
						else
							if isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio).area)
								PRINTDATA.tile(i_tile).col_stal(i_colprio).area				= partdata.area;
							else
								PRINTDATA.tile(i_tile).col_stal(i_colprio).area				= ...
									PRINTDATA.tile(i_tile).col_stal(i_colprio).area + partdata.area;
							end
						end
					end
					
				end
				
				% Außenabmessungen der Teile der nächsten Farbe zuweisen:
				if i_part_ncp==imax_part_ncp
					if i_colprio<imax_colprio
						% Dies war das letzte Teil der aktuellen Farbe:
						% Außenabmessungen der Teile der nächsten Farbe zuweisen:
						% (obj_nextcolprio_temp.colprio enthält gleiche Werte)
						if ~isempty(obj_nextcolprio_temp)
							i_colprio_new	= find(PRINTDATA.colprio_visible==obj_nextcolprio_temp.colprio(1));
						else
							i_colprio_new	= i_colprio+1;
						end
						PRINTDATA.col(i_colprio_new).obj_nextcolprio	= obj_nextcolprio_temp;
					end
				end
				
				% Ausgabe im Command-Window:
				fprintf(1,'          Execution time: %s\n',dt_string(etime(clock,t_start_i_part)));
				
				% Test:
				if (colno==1)||(colno==2)
					setbreakpoint=1;
				end
				if ((i_tile>=2)&&(i_colprio==1)&&(i_part_ncp>=1))&&~isdeployed
					% %#exclude profile
					% profile off
					% profile on
					setbreakpoint=1;
				end
				
				%---------------------------------------------------------------------------------------------------
				% i_part_ncp: Ende
				%---------------------------------------------------------------------------------------------------
				
			end		% Ende von: for i_part_ncp=1:imax_part_ncp
		end			% Ende von: if ~isempty(PRINTDATA.col(i_colprio).obj_nextcolprio)
	end				% Ende von: for i_colprio=1:imax_colprio
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Z-Wert der Unterseite der ganzen Karte z_bottom berechnen:
	%------------------------------------------------------------------------------------------------------------------
	
	% Save memory dump:
	if GV.save_memory_dump&&~isdeployed
		dump.no						= 3;
		[dump.pathname,dump.filename,~]	= fileparts(mfilename('fullpath'));
		C					= who;
		iC_delete		= [];
		for iC=1:size(C,1)
			if eval(sprintf('isa(%s,''matlab.ui.Figure'')',C{iC,1}))
				iC_delete		= [iC_delete;iC];
			end
		end
		C(iC_delete,:)	= [];
		[save_command,~]	= get_savecommand_errorlog(C,dump.pathname,'dump');
		eval(save_command);
	end
	
	% Für die ganze Karte muss der negativste z-Wert der Unterseite aller Kacheln verwendet werden.
	PRINTDATA.z_bottom	= 1e10;
	for i_tile=1:length(PRINTDATA.tile)
		if ~isempty(PRINTDATA.tile(i_tile).z_bottom)
			PRINTDATA.z_bottom	= min(PRINTDATA.z_bottom,PRINTDATA.tile(i_tile).z_bottom);
		end
	end
	if PRINTDATA.z_bottom==1e10
		errormessage;
	end
	
	% Save the calculated value z_bottom, because it can be overwritten in the next step:
	PRINTDATA.z_bottom_max	= PRINTDATA.z_bottom;
	
	% Vorgabe PP_local.general.z_bottom_tilebase übernehmen, wenn negativer als PRINTDATA.z_bottom:
	if PP_local.general.z_bottom_tilebase~=999999
		if PP_local.general.z_bottom_tilebase<=PRINTDATA.tile(i_tile).z_bottom
			PRINTDATA.z_bottom	= PP_local.general.z_bottom_tilebase;
		else
			if isfield(GV_H,'z_bottom_warndlg')
				if ishandle(GV_H.warndlg.z_bottom)
					close(GV_H.warndlg.z_bottom);
				end
			end
			GV_H.warndlg.z_bottom		= warndlg(sprintf([...
				'Warning:\n',...
				'The value general.z_bottom_tilebase = %g mm\n',...
				'specified in the project parameters must be more\n',...
				'negative than %g mm for the current map!\n',...
				'\n',...
				'The z-value of the bottom of all tiles was set to %g mm.'],...
				PP_local.general.z_bottom_tilebase,...
				PRINTDATA.z_bottom,...
				PRINTDATA.z_bottom),'Warning');
			GV_H.warndlg.z_bottom.Tag	= 'maplab3d_figure';
		end
	end
	
	% Den z-Wert der Unterseite jedem einzelnen Teil der Grundfarbe zuweisen:
	for i_tile=1:length(PRINTDATA.tile)
		if ~isempty(PRINTDATA.tile(i_tile).col_stal)
			i_colprio_stal	= 1;		% i_colprio=1 ist immer die Grundfarbe
			imax_part_stal	= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal);
			for i_part_stal=1:imax_part_stal
				PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).z_bottom		= PRINTDATA.z_bottom;
				PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).z_bottom_max	= PRINTDATA.z_bottom;
			end
		end
	end
	
	%------------------------------------------------------------------------------------------------------------------
	% Unterseiten der Objekte berechnen und als STL speichern:
	%------------------------------------------------------------------------------------------------------------------
	
	% no_nonempty_tiles neu berechnen, da:
	% nicht mehr:	Abfrage auf:		numboundaries(poly_tile(i_tile))>0
	% sondern:		Abfrage auf:		~isempty(PRINTDATA.tile(i_tile).col_stal)
	nonempty_tiles_v		= false(size(poly_tile));
	for i_tile=1:imax_tile
		if ~isempty(PRINTDATA.tile(i_tile).col_stal)
			nonempty_tiles_v(i_tile)	= true;
		end
	end
	PRINTDATA.no_nonempty_tiles	= sum(nonempty_tiles_v);
	i_lastnonempty_tile				= find(nonempty_tiles_v,1,'last');
	i_nonempty_tiles_v				= cumsum(nonempty_tiles_v);
	
	% Darstellung der ganzen Karte in einem Bild vorbereiten:
	if (PP_local.general.savefig_map==1)&&...
			(maptype==0)										% maptype=0: normal map (no testsample)
		% Die Handles werden in plot_stldata_map_frame wieder zugewiesen:
		if isfield(GV_H,'fig_stldata_map')
			if ~isempty(GV_H.fig_stldata_map)
				if isvalid(GV_H.fig_stldata_map)
					clf(GV_H.fig_stldata_map,'reset')
					figure_theme(GV_H.fig_stldata_map,'set',[],'light');
					set(GV_H.fig_stldata_map,'Tag','maplab3d_figure');
				end
			end
		end
		if isfield(GV_H,'ax_stldata_map')
			if ~isempty(GV_H.ax_stldata_map)
				if isvalid(GV_H.ax_stldata_map)
					delete(GV_H.ax_stldata_map)
				end
			end
		end
		% Create the figure and show the frame:
		plot_stldata_map_frame(PP_local,...
			0,...			% plot_mapobj
			1);			% create_axis
		ud_figure.version			= VER;
		ud_figure.tile_no			= [];					% []: the whole map
		ud_figure.colno			= [];					% []: more than one color
		ud_figure.comment			= 'MapLab3D: 3D plot of the whole map';
		set(GV_H.fig_stldata_map,'UserData',ud_figure);
	end
	
	% Unterseiten der Objekte berechnen und als STL speichern:
	for i_tile=1:length(PRINTDATA.tile)
		if ~isempty(PRINTDATA.tile(i_tile).col_stal)
			tile_no	= PRINTDATA.tile_no_all_v(i_tile,1);
			
			% Waitbar:
			msg_add		= sprintf('bottom side tile %g/%g',i_tile,imax_tile);
			if ~isempty(msg)
				msg_add	= sprintf('%s: %s',msg,msg_add);
			end
			set(GV_H.text_waitbar,'String',sprintf('%s',msg_add));
			drawnow;
			
			%------------------------------------------------------------------------------------------------------------
			% Vorbereitung
			%------------------------------------------------------------------------------------------------------------
			
			% Kachelgrenzen für Anzeige und Dateinamen:
			if PRINTDATA.tile(i_tile).xmin<0
				PRINTDATA.tile(i_tile).xmin_str	= sprintf('m%04.0f',abs(PRINTDATA.tile(i_tile).xmin));
			else
				PRINTDATA.tile(i_tile).xmin_str	= sprintf('p%04.0f',PRINTDATA.tile(i_tile).xmin);
			end
			if PRINTDATA.tile(i_tile).xmax<0
				PRINTDATA.tile(i_tile).xmax_str	= sprintf('m%04.0f',abs(PRINTDATA.tile(i_tile).xmax));
			else
				PRINTDATA.tile(i_tile).xmax_str	= sprintf('p%04.0f',PRINTDATA.tile(i_tile).xmax);
			end
			if PRINTDATA.tile(i_tile).ymin<0
				PRINTDATA.tile(i_tile).ymin_str	= sprintf('m%04.0f',abs(PRINTDATA.tile(i_tile).ymin));
			else
				PRINTDATA.tile(i_tile).ymin_str	= sprintf('p%04.0f',PRINTDATA.tile(i_tile).ymin);
			end
			if PRINTDATA.tile(i_tile).ymax<0
				PRINTDATA.tile(i_tile).ymax_str	= sprintf('m%04.0f',abs(PRINTDATA.tile(i_tile).ymax));
			else
				PRINTDATA.tile(i_tile).ymax_str	= sprintf('p%04.0f',PRINTDATA.tile(i_tile).ymax);
			end
			
			% Darstellung aller Teile einer Kachel in einem Bild vorbereiten:
			if ((testplot_tile==1)||(PP_local.general.savefig_tile==1))&&...
					(PRINTDATA.no_nonempty_tiles>1)&&...
					(maptype==0)																% maptype=0: normal map (no testsample)
				if ~isfield(GV_H,'fig_stldata_tile')
					GV_H.fig_stldata_tile	= [];
				end
				if ~isfield(GV_H,'ax_stldata_tile')
					GV_H.ax_stldata_tile		= [];
				end
				if isempty(GV_H.fig_stldata_tile)
					GV_H.fig_stldata_tile	= figure;
					figure_theme(GV_H.fig_stldata_tile,'set',[],'light');
				else
					if ~ishandle(GV_H.fig_stldata_tile)
						GV_H.fig_stldata_tile	= figure;
						figure_theme(GV_H.fig_stldata_tile,'set',[],'light');
					end
				end
				clf(GV_H.fig_stldata_tile,'reset');
				figure_theme(GV_H.fig_stldata_tile,'set',[],'light');
				ud_figure.version			= VER;
				ud_figure.tile_no			= tile_no;
				ud_figure.colno			= [];				% []: more than one color
				ud_figure.comment			= 'MapLab3D: 3D plot of one tile';
				set(GV_H.fig_stldata_tile,'UserData',ud_figure);
				set(GV_H.fig_stldata_tile,'Tag','maplab3d_figure');
				set(GV_H.fig_stldata_tile,'Name',sprintf('3D tile: T%g',tile_no));
				set(GV_H.fig_stldata_tile,'NumberTitle','off');
				cameratoolbar(GV_H.fig_stldata_tile,'Show');
				GV_H.ax_stldata_tile	= axes(GV_H.fig_stldata_tile);
				hold(GV_H.ax_stldata_tile,'on');
				axis(GV_H.ax_stldata_tile,'equal');
				set(GV_H.ax_stldata_tile,'XLim',[PRINTDATA.tile_axislimits(i_tile).xmin PRINTDATA.tile_axislimits(i_tile).xmax]);
				set(GV_H.ax_stldata_tile,'YLim',[PRINTDATA.tile_axislimits(i_tile).ymin PRINTDATA.tile_axislimits(i_tile).ymax]);
				view(GV_H.ax_stldata_tile,3);
				xlabel(GV_H.ax_stldata_tile,'x / mm');
				ylabel(GV_H.ax_stldata_tile,'y / mm');
				zlabel(GV_H.ax_stldata_tile,'z / mm');
				% Licht von zwei Seiten, ohne Reflexionen:
				el			= 30;
				az			= el;
				hlight1	= light(GV_H.ax_stldata_tile,'Color',[1 1 1]*1);
				lightangle(hlight1,az,el),
				az			= el+180;
				hlight2	= light(GV_H.ax_stldata_tile,'Color',[1 1 1]*0.3);
				lightangle(hlight2,az,el),
			end
			
			% Alle sichtbaren Farben bearbeiten:
			imax_colprio_stal	= length(PRINTDATA.tile(i_tile).col_stal);
			
			% Elements in PRINTDATA.tile(i_tile).col_stal do not contain part_stal data, if the color i_colprio_stal
			% is not stand-alone. Exclude these elements from the waitbar counter:
			i_colprio_stal_waitbar_logical	= false(size(PRINTDATA.tile(i_tile).col_stal));
			for i_colprio_stal=1:imax_colprio_stal
				imax_part_stal	= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal);
				if imax_part_stal>0
					i_colprio_stal_waitbar_logical(i_colprio_stal)		= true;
				end
			end
			k_colprio_stal_waitbar_v	= cumsum(i_colprio_stal_waitbar_logical);
			kmax_colprio_stal_waitbar	= sum(i_colprio_stal_waitbar_logical);
			
			for i_colprio_stal=1:imax_colprio_stal
				% There are stand-alone color parts:
				
				%---------------------------------------------------------------------------------------------------------
				% i_colprio_stal: Triangulationsdaten vervollständigen durch Berechnen der Unterseite
				%---------------------------------------------------------------------------------------------------------
				
				imax_part_stal	= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal);
				if imax_part_stal>0
					% Es gibt stand-alone Teile in dieser Farbe:
					% Nicht-stand-alone Teile dieser Farbe werden nur auf stand-alone-Teilen mit anderen Farben gedruckt.
					for i_part_stal=1:imax_part_stal
						
						% Data of the current stand-alone part (always the first element!):
						partdata	= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal);
						partdata(end).i_colprio	= i_colprio_stal;		% damit color_rgb korrekt ist
						partdata(end).i_part		= 0;
						
						% Add the data of corresponding non-stand-alone parts to partdata:
						if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal),'col')
							imax_colprio	= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col);
							for i_colprio=1:imax_colprio
								imax_part			= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part);
								for i_part=1:imax_part
									partdata_new	= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part);
									partdata_new.col				= [];
									partdata_new.i_colprio		= i_colprio;
									partdata_new.i_part			= i_part;
									if isfield(partdata,'zmin_TPoints')
										partdata_new.zmin_TPoints	= [];
									end
									if isfield(partdata,'zmax_TPoints')
										partdata_new.zmax_TPoints	= [];
									end
									partdata(end+1)			= partdata_new;
								end
							end
						end
						
						% Unterseiten der Objekte berechnen und als STL speichern:
						imax_partdata		= length(partdata);
						for i_partdata=1:imax_partdata
							
							t_start_i_part	= clock;
							%---------------------------------------------------------------------------------------------------
							% i_part: Anfang
							%---------------------------------------------------------------------------------------------------
							
							colprio_stal							= PRINTDATA.colprio_visible(i_colprio_stal);
							colno_stal								= find([PP_local.color.prio]==colprio_stal,1);
							% icolspec_stal						= PP_local.color(colno_stal).spec;
							% bottom_version_stal				= PP_local.colorspec(icolspec_stal).bottom_version;
							% lower_parts_individually_stal	= PP_local.colorspec(icolspec_stal).lower_parts_individually;
							
							i_colprio								= partdata(i_partdata).i_colprio;
							i_part									= partdata(i_partdata).i_part;
							colprio									= PRINTDATA.colprio_visible(i_colprio);
							colno										= find([PP_local.color.prio]==colprio,1);
							% icolspec								= PP_local.color(colno).spec;
							% bottom_version						= PP_local.colorspec(icolspec).bottom_version;
							% lower_parts_individually			= PP_local.colorspec(icolspec).lower_parts_individually;
							
							% Test:
							if (i_tile==1)&&(i_colprio==9)
								setbreakpoint=1;
							end
							
							% Für die Darstellung:
							color_rgb						= PP_local.color(colno).rgb/255;
							color_rgb						= color_rgb_improve(PP_local,color_rgb);
							
							% Fortschrittsanzeige:
							% i_tile				= 1:imax_tile
							% i_colprio_stal	= 1:kmax_colprio_stal_waitbar
							% i_part_stal		= 1:imax_part_stal
							% i_partdata		= 1:imax_partdata
							dx_tile				= 1/PRINTDATA.no_nonempty_tiles/2;	% /2 und +0.5 wegen der zweiten Schleife
							dx_colprio_stal	= dx_tile/kmax_colprio_stal_waitbar;			% vor Berechnung von z_bottom
							dx_part_stal		= dx_colprio_stal/imax_part_stal;
							dx_partdata			= dx_part_stal/imax_partdata;
							progress				= min(...
								(i_nonempty_tiles_v(i_tile)              -1)*dx_tile         + ...
								(k_colprio_stal_waitbar_v(i_colprio_stal)-1)*dx_colprio_stal + ...
								(i_part_stal                             -1)*dx_part_stal    + ...
								(i_partdata                              -1)*dx_partdata     +0.5 ,1);		% +0.5
							msg_add		= sprintf('bottom side tile %g/%g, color %g/%g, part %g/%g %g/%g',...
								i_tile,imax_tile,...
								k_colprio_stal_waitbar_v(i_colprio_stal),kmax_colprio_stal_waitbar,...
								i_part_stal,imax_part_stal,...
								i_partdata,imax_partdata);
							if ~isempty(msg)
								msg_add	= sprintf('%s: %s',msg,msg_add);
							end
							set(GV_H.text_waitbar,'String',sprintf('%s',msg_add));
							set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
							drawnow;
							
							% Ausgabe im Command-Window:
							fprintf(1,[...
								'Bottom side: i_tile         = %g/%g (tile_no   =%g)\n',...
								'             k_colprio_stal = %g/%g (i_colprio_stal = %g, colno_stal=%g)\n',...
								'             i_part_stal    = %g/%g\n',...
								'             i_part         = %g/%g (colno     =%g)\n'],...
								i_tile,imax_tile,tile_no,...
								k_colprio_stal_waitbar_v(i_colprio_stal),kmax_colprio_stal_waitbar,i_colprio_stal,colno_stal,...
								i_part_stal,imax_part_stal,...
								i_partdata,imax_partdata,colno);
							
							
							%---------------------------------------------------------------------------------------------------
							% Die Unterseite des aktuellen Teils berechnen:
							%---------------------------------------------------------------------------------------------------
							if i_partdata==1
								colprio_base	= colprio_stal;
							else
								colprio_base	= colprio;
							end
							try
								partdata(i_partdata).T	= ...
									map2stl_botside_triangulation(...
									partdata(i_partdata).T,...
									partdata(i_partdata).iT_margin,...
									partdata(i_partdata).z_bottom,...
									partdata(i_partdata).z_bottom_max,...
									partdata(i_partdata).zmin,...
									colprio_base,PP_local,ELE_local,poly_legbgd,...
									testout_botside,testplot_triang_bot,...
									testplot_xylimits,msg_add,...
									i_tile,i_colprio_stal,i_part_stal,i_colprio,i_part);
							catch ME
								% The global variables defined in the function must also be defined globally outside:
								% required: global GV GV_H WAITBAR
								errormessage('',ME);
							end
							
							%---------------------------------------------------------------------------------------------------
							% Darstellung nur des aktuellen Teils für Testzwecke (testplot_triang_currpart=1) und
							% Darstellung aller Teile der ganzen Karte und
							% Darstellung aller Teile einer Kachel
							%---------------------------------------------------------------------------------------------------
							if i_partdata==1
								colpartno_str	= sprintf('C%03.0f P%03.0f',colno_stal,i_part_stal);
							else
								colpartno_str	= sprintf('C%03.0f P%03.0f - C%03.0f P%03.0f',colno_stal,i_part_stal,colno,i_part);
							end
							if testplot_triang_currpart==1
								hf=figure(10100);
								clf(hf,'reset');
								set(hf,'Tag','maplab3d_figure');
								set(hf,'Name','triang_curr');
								set(hf,'NumberTitle','off');
								cameratoolbar(hf,'Show');
								ha	= axes(hf);
								F=[partdata(i_partdata).T.ConnectivityList(:,1) ...
									partdata(i_partdata).T.ConnectivityList(:,2) ...
									partdata(i_partdata).T.ConnectivityList(:,3) ...
									partdata(i_partdata).T.ConnectivityList(:,1)];
								hp=patch(ha,'faces',F,...
									'vertices',partdata(i_partdata).T.Points,...
									'EdgeColor','k','FaceColor',color_rgb,...
									'FaceAlpha',PP_local.general.savefig_facealpha,...
									'EdgeAlpha',PP_local.general.savefig_edgealpha,...
									'DisplayName',sprintf('T%03.0f - %s',tile_no,colpartno_str));
								axis(ha,'equal');
								set(ha,'XLim',[PRINTDATA.tile_axislimits(i_tile).xmin PRINTDATA.tile_axislimits(i_tile).xmax]);
								set(ha,'YLim',[PRINTDATA.tile_axislimits(i_tile).ymin PRINTDATA.tile_axislimits(i_tile).ymax]);
								view(ha,3);
								% Licht von zwei Seiten, ohne Reflexionen:
								material(hp,'dull');
								el			= 30;
								az			= el;
								hlight1	= light(ha,'Color',[1 1 1]*1);
								lightangle(hlight1,az,el);
								az			= el+180;
								hlight2	= light(ha,'Color',[1 1 1]*0.3);
								lightangle(hlight2,az,el);
							end
							ud_patch				= [];
							ud_patch.colno		= colno;
							ud_patch.pp_color	= PP_local.color(colno);
							if (PP_local.general.savefig_map==1)&&...
									(maptype==0)										% maptype=0: normal map (no testsample)
								% figure(GV_H.fig_stldata_map);
								F=[partdata(i_partdata).T.ConnectivityList(:,1) ...
									partdata(i_partdata).T.ConnectivityList(:,2) ...
									partdata(i_partdata).T.ConnectivityList(:,3) ...
									partdata(i_partdata).T.ConnectivityList(:,1)];
								hp=patch(GV_H.ax_stldata_map,'faces',F,...
									'vertices',partdata(i_partdata).T.Points,...
									'EdgeColor','k','FaceColor',color_rgb,...
									'FaceAlpha',PP_local.general.savefig_facealpha,...
									'EdgeAlpha',PP_local.general.savefig_edgealpha,...
									'DisplayName',sprintf('T%03.0f - %s',tile_no,colpartno_str),...
									'UserData',ud_patch);
								material(hp,'dull');
							end
							if ((testplot_tile==1)||(PP_local.general.savefig_tile==1))&&...
									(PRINTDATA.no_nonempty_tiles>1)&&...
									(maptype==0)										% maptype=0: normal map (no testsample)
								% figure(GV_H.fig_stldata_tile);
								F=[partdata(i_partdata).T.ConnectivityList(:,1) ...
									partdata(i_partdata).T.ConnectivityList(:,2) ...
									partdata(i_partdata).T.ConnectivityList(:,3) ...
									partdata(i_partdata).T.ConnectivityList(:,1)];
								hp=patch(GV_H.ax_stldata_tile,'faces',F,...
									'vertices',partdata(i_partdata).T.Points,...
									'EdgeColor','k','FaceColor',color_rgb,...
									'FaceAlpha',PP_local.general.savefig_facealpha,...
									'EdgeAlpha',PP_local.general.savefig_edgealpha,...
									'DisplayName',sprintf('T%03.0f - %s',tile_no,colpartno_str),...
									'UserData',ud_patch);
								material(hp,'dull');
							end
							
							
							%---------------------------------------------------------------------------------------------------
							% folgende Daten der Struktur PRINTDATA zuweisen:
							% partdata(i_partdata).T
							% partdata(i_partdata).zmin_TPoints
							% partdata(i_partdata).zmax_TPoints
							%---------------------------------------------------------------------------------------------------
							
							% min./max. z-Wert in den Triangulationsdaten:
							partdata(i_partdata).zmin_TPoints	= min(partdata(i_partdata).T.Points(:,3));
							partdata(i_partdata).zmax_TPoints	= max(partdata(i_partdata).T.Points(:,3));
							
							if i_partdata==1
								% The color is printed stand-alone and serves as a basis for non-stand-alone colors:
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T				= partdata(i_partdata).T;
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmin_TPoints	= partdata(i_partdata).zmin_TPoints;
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmax_TPoints	= partdata(i_partdata).zmax_TPoints;
								
								% min./max. z-Wert in den Triangulationsdaten:
								% hier nur die Berechnung von: PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmin_TPoints
								% Berechnung von PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmax_TPoints nach der Absenkung der Teile.
								if i_part_stal==1
									PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmin_TPoints	= partdata(i_partdata).zmin_TPoints;
								else
									PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmin_TPoints	= min(...
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmin_TPoints,partdata(i_partdata).zmin_TPoints);
								end
								
							else
								% The color is printed non-stand-alone in one operation together with other colors:
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T					= partdata(i_partdata).T;
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmin_TPoints	= partdata(i_partdata).zmin_TPoints;
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmax_TPoints	= partdata(i_partdata).zmax_TPoints;
								
								% min./max. z-Wert in den Triangulationsdaten:
								% wird erst später berechnet, nach der Absenkung der Teile
								
							end
							
							% Ausgabe im Command-Window:
							fprintf(1,'             z_bottom  = %g\n',partdata(i_partdata).z_bottom);
							fprintf(1,'             Execution time: %s\n',dt_string(etime(clock,t_start_i_part)));
							
						end			% Ende von: for i_partdata=1:imax_partdata
					end				% Ende von: for i_part_stal=1:imax_part_stal
					
					
					% Alle Teile der aktuellen stand-alone Farbe i_colprio_stal auf der aktuellen Kachel liegen vor
					% (inklusive überlagerte non-stand-alone Farben):
					% Ausgabe vorbereiten:
					
					%---------------------------------------------------------------------------------------------------------
					% i_colprio_stal:
					% Teile der stand-alone Farbe einzeln um den Betrag dz_i_part_stal auf die Druckplatte absenken,
					% Teile von überlagerten non-stand-alone Farben jeweils um denselben Betrag dz_i_part_stal absenken
					% Teile einer Kachel und Farbe zusammenfassen in:
					% PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print
					% PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print
					%---------------------------------------------------------------------------------------------------------
					
					PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print							= [];
					PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print.Points					= zeros(0,3);
					PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print.ConnectivityList	= zeros(0,3);
					PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).text_xyz							= zeros(imax_part_stal,3);
					PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).text_str							= cell(imax_part_stal,1);
					for i_colprio=1:length(PRINTDATA.colprio_visible)
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmin_TPoints					= [];
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmax_TPoints					= [];
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print							= [];
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print.Points					= zeros(0,3);
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print.ConnectivityList	= zeros(0,3);
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).text_xyz							= zeros(0,3);
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).text_str							= cell(0,1);
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).filename_stl					= '';
						if ~isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio),'area')
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).area							= [];
						end
					end
					
					% Berechnung des Werts dz, um den die Teile auf die Druckplatte abgesenkt werden::
					colprio_stal						= PRINTDATA.colprio_visible(i_colprio_stal);
					colno_stal							= find([PP_local.color.prio]==colprio_stal,1);
					icolspec_stal						= PP_local.color(colno_stal).spec;
					lower_parts_individually_stal	= PP_local.colorspec(icolspec_stal).lower_parts_individually;
					if lower_parts_individually_stal==2
						% Alle Teile einer Farbe i_colprio um denselben Wert z auf minimal z=0 absenken/anheben:
						% PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmin_TPoints wird in der for-Schleife
						% überschrieben, daher hier zuweisen!
						dz_i_part_stal	= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmin_TPoints;
					else
						% lower_parts_individually==0: Die z-Werte aller Teile nicht ändern:
						dz_i_part_stal	= 0;
					end
					for i_part_stal=1:imax_part_stal
						if isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T)
							errormessage;
						end
						% T_print.ConnectivityList erweitern:
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print.ConnectivityList	= [...
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print.ConnectivityList;...
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T.ConnectivityList+...
							size(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print.Points,1)];
						% Berechnung des Werts dz, um den die Teile auf die Druckplatte abgesenkt werden::
						if lower_parts_individually_stal==1
							% Alle Teile einzeln auf z=0 absenken/anheben:
							dz_i_part_stal	= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmin_TPoints;
						end
						% T_print.Points erweitern:
						T_print_Points_new	= ...
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).T.Points+[0 0 -dz_i_part_stal];
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print.Points			= [...
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print.Points;T_print_Points_new];
						% text_xyz zuweisen (Koordinaten der Teilenummer in den Plots):
						[~,row_zmax]			= max(T_print_Points_new(:,3));
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).text_xyz(i_part_stal,:)	= T_print_Points_new(row_zmax,:);
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).text_str{i_part_stal,1}	= sprintf('%g',i_part_stal);
						% zmin und zmax berechnen:
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmin_TPoints	= ...
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmin_TPoints-dz_i_part_stal;
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmax_TPoints	= ...
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmax_TPoints-dz_i_part_stal;
						if i_part_stal==1
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmin_TPoints	= ...
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmin_TPoints;
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmax_TPoints	= ...
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmax_TPoints;
						else
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmin_TPoints	= min(...
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmin_TPoints,...
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmin_TPoints);
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmax_TPoints	= max(...
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmax_TPoints,...
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).zmax_TPoints);
						end
						
						% Teile von überlagerten non-stand-alone Farben jeweils um denselben Betrag dz_i_part_stal absenken
						% und nach Farben sortiert sammeln:
						if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal),'col')
							imax_colprio	= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col);
							for i_colprio=1:imax_colprio
								imax_part	= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part);
								for i_part=1:imax_part
									if isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T)
										errormessage;
									end
									% T_print.ConnectivityList erweitern:
									PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print.ConnectivityList	= [...
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print.ConnectivityList;...
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T.ConnectivityList+...
										size(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print.Points,1)];
									% T_print.Points erweitern:
									T_print_Points_new	= ...
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).T.Points+[0 0 -dz_i_part_stal];
									PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print.Points			= [...
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print.Points;T_print_Points_new];
									% text_xyz zuweisen (Koordinaten der Teilenummer in den Plots):
									[~,row_zmax]			= max(T_print_Points_new(:,3));
									PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).text_xyz(i_part,:)	= T_print_Points_new(row_zmax,:);
									PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).text_str{i_part,:}	= sprintf('%g/%g',i_part_stal,i_part);
									% zmin und zmax aktualisieren:
									PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmin_TPoints	= ...
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmin_TPoints-dz_i_part_stal;
									PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmax_TPoints	= ...
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmax_TPoints-dz_i_part_stal;
									if isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmin_TPoints)
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmin_TPoints	= ...
											PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmin_TPoints;
									else
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmin_TPoints	= min(...
											PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmin_TPoints,...
											PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmin_TPoints);
									end
									if isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmax_TPoints)
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmax_TPoints	= ...
											PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmax_TPoints;
									else
										PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmax_TPoints	= max(...
											PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmax_TPoints,...
											PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal).col(i_colprio).part(i_part).zmax_TPoints);
									end
									
								end	% Ende von: for i_part=1:imax_part
							end		% Ende von: for i_colprio=1:imax_colprio
						end			% Ende von: if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).part_stal(i_part_stal),'col')
						
					end				% Ende von: for i_part_stal=1:imax_part_stal
					
					% Delete points that are not referenced by the triangulation:
					[PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print,~]	= ...
						triangulation_delete_not_referenced_points(...
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print);
					% Aus den Druckdaten wieder ein gültiges "triangulation object" machen:
					PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print	= triangulation(...
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print.ConnectivityList,...
						PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print.Points);
					for i_colprio=1:length(PRINTDATA.colprio_visible)
						if ~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print.Points)
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print	= triangulation(...
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print.ConnectivityList,...
								PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print.Points);
						end
					end
					
					%---------------------------------------------------------------------------------------------------------
					% i_colprio_stal: Daten speichern, vorher in coldata sammeln
					% coldata.zmin_TPoints
					% coldata.zmax_TPoints
					% coldata.area
					% coldata.no_parts
					% coldata.T_print
					% coldata.text_xyz(i_part_stal,:)
					% coldata.text_str{i_part_stal,:}
					% coldata.filename_stl					wird weiter unten zugewiesen
					% coldata.i_colprio						wird hier hinzugefügt
					%---------------------------------------------------------------------------------------------------------
					
					% Data of the current stand-alone color (always the first element!):
					i_coldata								= 1;
					coldata									= struct;
					coldata(i_coldata).zmin_TPoints	= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmin_TPoints;
					coldata(i_coldata).zmax_TPoints	= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).zmax_TPoints;
					coldata(i_coldata).area				= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).area;
					coldata(i_coldata).T_print			= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).T_print;
					coldata(i_coldata).text_xyz		= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).text_xyz;
					coldata(i_coldata).text_str		= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).text_str;
					% coldata(i_coldata).filename_stl wird weiter unten zugewiesen
					coldata(i_coldata).i_colprio		= i_colprio_stal;		% damit color_rgb korrekt ist
					
					% Add the data of corresponding non-stand-alone colors to coldata:
					if isfield(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal),'col')
						imax_colprio	= length(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col);
						for i_colprio=1:imax_colprio
							if ~isempty(PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print.Points)
								i_coldata								= i_coldata+1;
								coldata(i_coldata).zmin_TPoints	= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmin_TPoints;
								coldata(i_coldata).zmax_TPoints	= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).zmax_TPoints;
								coldata(i_coldata).area				= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).area;
								coldata(i_coldata).T_print			= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).T_print;
								coldata(i_coldata).text_xyz		= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).text_xyz;
								coldata(i_coldata).text_str		= PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).text_str;
								% coldata(i_coldata).filename_stl wird weiter unten zugewiesen
								coldata(i_coldata).i_colprio		= i_colprio;		% damit color_rgb korrekt ist
							end
						end
					end
					
					imax_coldata	= length(coldata);
					for i_coldata=1:imax_coldata
						
						colprio_stal						= PRINTDATA.colprio_visible(i_colprio_stal);
						colno_stal							= find([PP_local.color.prio]==colprio_stal,1);
						
						i_colprio							= coldata(i_coldata).i_colprio;
						colprio								= PRINTDATA.colprio_visible(i_colprio);
						colno									= find([PP_local.color.prio]==colprio,1);
						
						% Für die Darstellung:
						color_rgb							= PP_local.color(colno).rgb/255;
						color_rgb							= color_rgb_improve(PP_local,color_rgb);
						
						%------------------------------------------------------------------------------------------------------
						% Alle Teile der aktuellen Farbe darstellen:
						%------------------------------------------------------------------------------------------------------
						if ((testplot_tile_colno==1)||(PP_local.general.savefig_tile_color==1))&&...
								(maptype==0)								% maptype=0: normal map (no testsample)
							if ~isfield(GV_H,'fig_stldata_color')
								GV_H.fig_stldata_color	= [];
							end
							if ~isfield(GV_H,'ax_stldata_color')
								GV_H.ax_stldata_color	= [];
							end
							if isempty(GV_H.fig_stldata_color)
								GV_H.fig_stldata_color	= figure;
								figure_theme(GV_H.fig_stldata_color,'set',[],'light');
							else
								if ~ishandle(GV_H.fig_stldata_color)
									GV_H.fig_stldata_color	= figure;
									figure_theme(GV_H.fig_stldata_color,'set',[],'light');
								end
							end
							clf(GV_H.fig_stldata_color,'reset');
							figure_theme(GV_H.fig_stldata_color,'set',[],'light');
							ud_figure.version			= VER;
							ud_figure.tile_no			= tile_no;
							ud_figure.colno			= colno;
							ud_figure.comment			= 'MapLab3D: 3D plot of one color';
							set(GV_H.fig_stldata_color,'UserData',ud_figure);
							set(GV_H.fig_stldata_color,'Tag','maplab3d_figure');
							if i_coldata==1
								set(GV_H.fig_stldata_color,'Name',sprintf('3D color: T%g C%g',tile_no,colno_stal));
							else
								set(GV_H.fig_stldata_color,'Name',sprintf('3D color: T%g C%g C%g',tile_no,colno_stal,colno));
							end
							set(GV_H.fig_stldata_color,'NumberTitle','off');
							cameratoolbar(GV_H.fig_stldata_color,'Show');
							GV_H.ax_stldata_color	= axes(GV_H.fig_stldata_color);
							hold(GV_H.ax_stldata_color,'on');
							F=[coldata(i_coldata).T_print.ConnectivityList(:,1) ...
								coldata(i_coldata).T_print.ConnectivityList(:,2) ...
								coldata(i_coldata).T_print.ConnectivityList(:,3) ...
								coldata(i_coldata).T_print.ConnectivityList(:,1)];
							if i_coldata==1
								colno_str	= sprintf('C%03.0f',colno_stal);
							else
								colno_str	= sprintf('C%03.0f - C%03.0f',colno_stal,colno);
							end
							ud_patch				= [];
							ud_patch.colno		= colno;
							ud_patch.pp_color	= PP_local.color(colno);
							hp=patch(GV_H.ax_stldata_color,'faces',F,'vertices',coldata(i_coldata).T_print.Points,...
								'EdgeColor','k','FaceColor',color_rgb,...
								'FaceAlpha',PP_local.general.savefig_facealpha,...
								'EdgeAlpha',PP_local.general.savefig_edgealpha,...
								'DisplayName',sprintf('T%03.0f - %s',tile_no,colno_str),...
								'UserData',ud_patch);
							if testplot_tile_colno~=0
								for i=1:size(coldata(i_coldata).text_xyz,1)
									if ~isempty(coldata(i_coldata).text_str{i,1})
										text(GV_H.ax_stldata_color,...
											coldata(i_coldata).text_xyz(i,1),...
											coldata(i_coldata).text_xyz(i,2),...
											coldata(i_coldata).text_xyz(i,3),...
											coldata(i_coldata).text_str{i,1},...
											'FontSize',8,'FontWeight','bold','Color','m');
									end
								end
							end
							axis(GV_H.ax_stldata_color,'equal');
							set(GV_H.ax_stldata_color,'XLim',[PRINTDATA.tile_axislimits(i_tile).xmin PRINTDATA.tile_axislimits(i_tile).xmax]);
							set(GV_H.ax_stldata_color,'YLim',[PRINTDATA.tile_axislimits(i_tile).ymin PRINTDATA.tile_axislimits(i_tile).ymax]);
							view(GV_H.ax_stldata_color,3);
							xlabel(GV_H.ax_stldata_color,'x / mm');
							ylabel(GV_H.ax_stldata_color,'y / mm');
							zlabel(GV_H.ax_stldata_color,'z / mm');
							% Licht von zwei Seiten, ohne Reflexionen:
							material(hp,'dull');
							el			= 30;
							az			= el;
							hlight1	= light(GV_H.ax_stldata_color,'Color',[1 1 1]*1);
							lightangle(hlight1,az,el),
							az			= el+180;
							hlight2	= light(GV_H.ax_stldata_color,'Color',[1 1 1]*0.3);
							lightangle(hlight2,az,el),
						end
						
						%------------------------------------------------------------------------------------------------------
						% Export als STL-Datei:
						%------------------------------------------------------------------------------------------------------
						% color_text:
						color_text	= sprintf(' - C%03.0f',colno_stal);
						if i_coldata>1
							color_text	= sprintf('%s - C%03.0f',color_text,colno);
						end
						if PP_local.general.save_filename.brand~=0
							color_text	= sprintf('%s %s',color_text,PP_local.color(colno,1).brand);
						end
						if PP_local.general.save_filename.color~=0
							color_text	= sprintf('%s %s',color_text,PP_local.color(colno,1).color_short_text);
						end
						color_text	= validfilename(color_text);
						% tile_text:
						if PRINTDATA.no_nonempty_tiles==1
							tile_text	= '';
						else
							tile_text	= sprintf(' - T%03.0f',tile_no);
						end
						% filename_stl:
						if isempty(stl_filename)
							if PP_local.general.save_filename.tilecoordinates~=0
								filename_stl	= sprintf('%s%s%s - X%s%s Y%s%s',...
									GV.pp_projectfilename,...
									tile_text,...
									color_text,...
									PRINTDATA.tile(i_tile).xmin_str,PRINTDATA.tile(i_tile).xmax_str,...
									PRINTDATA.tile(i_tile).ymin_str,PRINTDATA.tile(i_tile).ymax_str);
							else
								filename_stl	= sprintf('%s%s%s',...
									GV.pp_projectfilename,...
									tile_text,...
									color_text);
							end
						else
							if (imax_colprio_stal==1)&&(imax_colprio==1)
								% There is only one color:
								filename_stl	= sprintf('%s%s',...
									tile_text,...
									stl_filename);
							else
								filename_stl	= sprintf('%s%s%s',...
									stl_filename,...
									tile_text,...path_backup_stl_exists
									color_text);
							end
						end
						
						% z-Koordinaten dem Dateinamen hinzufügen:
						if PP_local.general.save_filename.zmin~=0
							filename_stl			= sprintf('%s - zmin %1.3fmm',filename_stl,...
								coldata(i_coldata).zmin_TPoints);
						end
						if PP_local.general.save_filename.zcenter~=0
							filename_stl			= sprintf('%s - zcenter %1.3fmm',filename_stl,...
								(coldata(i_coldata).zmin_TPoints+coldata(i_coldata).zmax_TPoints)/2);
						end
						coldata(i_coldata).filename_stl	= [filename_stl '.stl'];
						
						% Save the STL files:
						map_path_stl_exists	= true;
						if exist(map_pathname_stl,'dir')~=7
							status_mkdir	= mkdir(map_pathname_stl);
							if status_mkdir~=1
								map_path_stl_exists	= false;
							end
						end
						if map_path_stl_exists
							path_filename_stl				= [map_pathname_stl coldata(i_coldata).filename_stl];
							stlwrite(coldata(i_coldata).T_print,path_filename_stl);
						end
						
						% Try to repair and save the STL files:
						if maptype==0
							% maptype=0: normal map (no testsample):
							map_path_stl_exists	= true;
							if exist(map_pathname_stl_repaired,'dir')~=7
								status_mkdir	= mkdir(map_pathname_stl_repaired);
								if status_mkdir~=1
									map_path_stl_exists	= false;
								end
							end
							if map_path_stl_exists
								try
									[T_print_rep,status]	= stlrepair(coldata(i_coldata).T_print);
								catch ME
									if ~isdeployed
										errormessage('',ME);
									else
										status			= 0;
									end
								end
								if status==0
									% the repair was not successful:
									T_print_rep			= coldata(i_coldata).T_print;
									path_filename_stl	= [map_pathname_stl_repaired filename_stl ' - to be repaired.stl'];
								else
									path_filename_stl	= [map_pathname_stl_repaired filename_stl '.stl'];
								end
								stlwrite(T_print_rep,path_filename_stl);
							end
						end
						
						%------------------------------------------------------------------------------------------------------
						% Figures speichern:
						%------------------------------------------------------------------------------------------------------
						
						% Preview of the whole map:
						if    (i_tile                                  ==i_lastnonempty_tile      )&&...
								(k_colprio_stal_waitbar_v(i_colprio_stal)==kmax_colprio_stal_waitbar)&&...
								(i_coldata                               ==imax_coldata             )&&...
								(maptype    ==0                  )		% maptype=0: normal map (no testsample)
							if PP_local.general.savefig_map==1
								% Save Matlab-figure:
								if isempty(stl_filename)
									if imax_tile==1
										filename_fig	= sprintf('%s%s',...
											GV.pp_projectfilename);
									else
										filename_fig	= sprintf('%s - T%03.0f to T%03.0f',...
											GV.pp_projectfilename,...
											1,imax_tile);
									end
									if PP_local.general.save_filename.tilecoordinates~=0
										filename_fig	= sprintf('%s - X%s%s Y%s%s',...
											filename_fig,...
											PRINTDATA.tile(i_tile).xmin_str,PRINTDATA.tile(i_tile).xmax_str,...
											PRINTDATA.tile(i_tile).ymin_str,PRINTDATA.tile(i_tile).ymax_str);
									end
								else
									filename_fig	= sprintf('%s - T%03.0f to T%03.0f',...
										stl_filename,...
										1,imax_tile);
								end
								savefig(GV_H.fig_stldata_map,[map_pathname_stl filename_fig '.fig']);
							end
							% Export preview:
							for i_print=1:size(PP_local.general.printfig_map,1)
								if ~isempty(PP_local.general.printfig_map(i_print,1).formattype)
									resolution_str		= sprintf('-r%1.0f',PP_local.general.printfig_map(i_print,1).resolution);
									GV_H.fig_stldata_map.PaperType			= PP_local.general.printfig_map(i_print,1).papertype;
									GV_H.fig_stldata_map.PaperPositionMode = 'manual';		% expand the figure size to fill page, before orient!
									if ((PRINTDATA.ymax-PRINTDATA.ymin)/(PRINTDATA.xmax-PRINTDATA.xmin))>1
										orient(GV_H.fig_stldata_map,'portrait');
									else
										orient(GV_H.fig_stldata_map,'landscape');
									end
									if    strcmp(PP_local.general.printfig_map(i_print,1).formattype,'dpdf')||...
											strcmp(PP_local.general.printfig_map(i_print,1).formattype,'dps')||...
											strcmp(PP_local.general.printfig_map(i_print,1).formattype,'dpsc')||...
											strcmp(PP_local.general.printfig_map(i_print,1).formattype,'dpsc2')
										print(GV_H.fig_stldata_map,[map_pathname_stl filename_fig],...
											['-' PP_local.general.printfig_map(i_print,1).formattype],...
											resolution_str,'-fillpage');				% '-fillpage' / '-bestfit'
									else
										print(GV_H.fig_stldata_map,[map_pathname_stl filename_fig],...
											['-' PP_local.general.printfig_map(i_print,1).formattype],...
											resolution_str);
									end
								end
							end
						end
						
						% Preview of the tiles:
						if    (PRINTDATA.no_nonempty_tiles             > 1                        )&&...
								(k_colprio_stal_waitbar_v(i_colprio_stal)==kmax_colprio_stal_waitbar)&&...
								(i_coldata                               ==imax_coldata             )&&...
								(maptype       ==0                )			% maptype=0: normal map (no testsample)
							if PP_local.general.savefig_tile==1
								% Save Matlab-figure:
								if isempty(stl_filename)
									filename_fig	= sprintf('%s%s',...
										GV.pp_projectfilename,...
										tile_text);
									if PP_local.general.save_filename.tilecoordinates~=0
										filename_fig	= sprintf('%s - X%s%s Y%s%s',...
											filename_fig,...
											PRINTDATA.tile(i_tile).xmin_str,PRINTDATA.tile(i_tile).xmax_str,...
											PRINTDATA.tile(i_tile).ymin_str,PRINTDATA.tile(i_tile).ymax_str);
									end
								else
									filename_fig	= sprintf('%s%s',stl_filename,tile_text);
								end
								savefig(GV_H.fig_stldata_tile,[map_pathname_stl filename_fig '.fig']);
							end
							% Export preview:
							for i_print=1:size(PP_local.general.printfig_tile,1)
								if ~isempty(PP_local.general.printfig_tile(i_print,1).formattype)
									resolution_str		= sprintf('-r%1.0f',PP_local.general.printfig_tile(i_print,1).resolution);
									GV_H.fig_stldata_tile.PaperType			= PP_local.general.printfig_tile(i_print,1).papertype;
									GV_H.fig_stldata_tile.PaperPositionMode = 'manual';		% expand the figure size to fill page, before orient!
									if ((PRINTDATA.ymax-PRINTDATA.ymin)/(PRINTDATA.xmax-PRINTDATA.xmin))>1
										orient(GV_H.fig_stldata_tile,'portrait');
									else
										orient(GV_H.fig_stldata_tile,'landscape');
									end
									if    strcmp(PP_local.general.printfig_tile(i_print,1).formattype,'dpdf')||...
											strcmp(PP_local.general.printfig_tile(i_print,1).formattype,'dps')||...
											strcmp(PP_local.general.printfig_tile(i_print,1).formattype,'dpsc')||...
											strcmp(PP_local.general.printfig_tile(i_print,1).formattype,'dpsc2')
										print(GV_H.fig_stldata_tile,[map_pathname_stl filename_fig],...
											['-' PP_local.general.printfig_tile(i_print,1).formattype],...
											resolution_str,'-fillpage');				% '-fillpage' / '-bestfit'
									else
										print(GV_H.fig_stldata_tile,[map_pathname_stl filename_fig],...
											['-' PP_local.general.printfig_tile(i_print,1).formattype],...
											resolution_str);
									end
								end
							end
						end
						
						% Preview of the colors of all tiles separatly:
						if    (PP_local.general.savefig_tile_color==1)&&...
								(maptype==0)										% maptype=0: normal map (no testsample)
							% Save Matlab-figure:
							if isempty(stl_filename)
								filename_fig	= sprintf('%s%s%s',...
									GV.pp_projectfilename,...
									tile_text,...
									color_text);
								if PP_local.general.save_filename.tilecoordinates~=0
									filename_fig	= sprintf('%s - X%s%s Y%s%s',...
										filename_fig,...
										PRINTDATA.tile(i_tile).xmin_str,PRINTDATA.tile(i_tile).xmax_str,...
										PRINTDATA.tile(i_tile).ymin_str,PRINTDATA.tile(i_tile).ymax_str);
								end
							else
								filename_fig	= sprintf('%s%s C%03.0f',stl_filename,tile_text,colno_stal);
								if i_coldata>1
									filename_fig	= sprintf('%s%s - C%03.0f',filename_fig,colno);
								end
							end
							savefig(GV_H.fig_stldata_color,[map_pathname_stl filename_fig '.fig']);
							% Export preview:
							for i_print=1:size(PP_local.general.printfig_color,1)
								if ~isempty(PP_local.general.printfig_color(i_print,1).formattype)
									resolution_str		= sprintf('-r%1.0f',PP_local.general.printfig_color(i_print,1).resolution);
									GV_H.fig_stldata_color.PaperType			= PP_local.general.printfig_color(i_print,1).papertype;
									GV_H.fig_stldata_color.PaperPositionMode = 'manual';		% expand the figure size to fill page, before orient!
									if ((PRINTDATA.ymax-PRINTDATA.ymin)/(PRINTDATA.xmax-PRINTDATA.xmin))>1
										orient(GV_H.fig_stldata_color,'portrait');
									else
										orient(GV_H.fig_stldata_color,'landscape');
									end
									if    strcmp(PP_local.general.printfig_color(i_print,1).formattype,'dpdf')||...
											strcmp(PP_local.general.printfig_color(i_print,1).formattype,'dps')||...
											strcmp(PP_local.general.printfig_color(i_print,1).formattype,'dpsc')||...
											strcmp(PP_local.general.printfig_color(i_print,1).formattype,'dpsc2')
										print(GV_H.fig_stldata_color,[map_pathname_stl filename_fig],...
											['-' PP_local.general.printfig_color(i_print,1).formattype],...
											resolution_str,'-fillpage');				% '-fillpage' / '-bestfit'
									else
										print(GV_H.fig_stldata_color,[map_pathname_stl filename_fig],...
											['-' PP_local.general.printfig_color(i_print,1).formattype],...
											resolution_str);
									end
								end
							end
						end
						
						%------------------------------------------------------------------------------------------------------
						% coldata zuweisen:
						%------------------------------------------------------------------------------------------------------
						
						if i_coldata==1
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).filename_stl						= coldata(i_coldata).filename_stl;
						else
							PRINTDATA.tile(i_tile).col_stal(i_colprio_stal).col(i_colprio).filename_stl	= coldata(i_coldata).filename_stl;
						end
						
					end		% Ende von: i_coldata=1:imax_coldata
					
				end			%  Ende von: if imax_part_stal>0
				set_breakpoint_forloop_i_colprio_stal	= 1;
			end				% Ende von: for i_colprio_stal=1:imax_colprio_stal
		end					% Ende von: if ~isempty(PRINTDATA.tile(i_tile).col_stal)
		set_breakpoint_forloop_i_tile	= 1;
	end						% Ende von: for i_tile=1:length(PRINTDATA.tile)
	
	% Execution time: before the last steps in map2stl_completion, because the execution times will be saved!
	t_end_statebusy					= clock;
	dt_statebusy						= etime(t_end_statebusy,t_start_statebusy);
	dt_statebusy_str					= dt_string(dt_statebusy);
	if dt_statebusy>GV.exec_time.map2stl.dt
		GV.exec_time.map2stl.name		= APP.CreatemapSTLfilesMenu.Text;
		GV.exec_time.map2stl.t_start	= t_start_statebusy;
		GV.exec_time.map2stl.t_end		= t_end_statebusy;
		GV.exec_time.map2stl.dt			= dt_statebusy;
		GV.exec_time.map2stl.dt_str	= dt_statebusy_str;
	end
	fprintf(1,'Creating all STL-files execution time: %s\n',dt_statebusy_str);
	
	if maptype==0
		% Normal map:
		
		% Last steps: after assigning the execution time!
		map2stl_completion(PP_local,map_pathname_stl);
		
		% Autosave: is not required because the map is already saved before “Create map STL files” is executed and
		% no changes are made to the map during execution.
		% filename_add			= ' - after create map STL files';
		% [map_filename,~,~]	= filenames_savefiles(filename_add);
		% set(GV_H.text_waitbar,'String',sprintf('Autosave "%s"',map_filename));
		% save_project(0,filename_add);
		
	end
	
	% Reset waitbar:
	set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
	set(GV_H.text_waitbar,'String','');
	drawnow;
	
	% Display state:
	if ~stateisbusy
		display_on_gui('state',sprintf('Creating STL files ... done (%s).',dt_statebusy_str),'notbusy','replace');
	end
	
catch ME
	errormessage('',ME);
end

