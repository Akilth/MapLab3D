
%% VORBEREITUNG:

% 	 1. MATLAB R2025b installieren und Einstellungen vornehmen (neuere Version
%		 geht auch: jedes halbe jahr kommt neue Version):
%		 https://de.mathworks.com/products/matlab.html
%	 2. https://github.com/Akilth/MapLab3D/tree/Development Website öffnen
%   3. ZIP-Code runterladen (Grüner Buttonn --> Download ZIP)
%   4. Extrahieren in Datei-Explorer
%   5. Im Ordner "SourceCode" sind alle Matlab Quellcodes.
%   6. Matlab öffnen. Geh in der oberen blauen Leiste auf "APPS" und klicklinks
%      auf "Design App" --> maplab3d.mlapp öffnen
%	 7. Wenn sich das neue Fenster öffnet, dann auf RUN drücken
%   8. Es öffnet sich ein weiteres Fenster. Oberste Leiste "File" -->
%      "Load Project parameters. Es öffnet sich der Explorer -->
%      MapLab3D_ProjectParameters_1_1_0_0.xlsx auswählen
%	 9. Nochmal auf "File" --> "Load OSM- and elevation-data settings" -->
%      "Do not load elevation-data (flat map)" auswählen
%	10. Nochmal "File" --> "Load OSM- and elevation-data" --> hier kannst du dein
%      Beispielgebäude laden. Dafür gehst du zu: https://www.openstreetmap.org/
%      und wählst das Gebäude und drückst oben mitte links auf "Export".
%      Ein Beispiel: https://www.openstreetmap.org/way/225698612
%	11. Nochmal "File" --> "Create Map"
%  12. Jetzt musst du hier im Quellcode die ID des ausgewählten Gebäude
%      eintragen. Dafür kopierst du die ID aus osm.org und fügst es unter einem
%      neuen case bei Zeile 26 ein.
%      Wenn das Gebäude ein Way ist (das steht in osm.org dort wo du die ID
%      kopierst), musst id_w_v(end+1,1) = ID nutzen.
%      Bei Relation id_w_r(end+1,1) = ID.
%  13. Jetzt gehst du hier im Quellcode in der blauen Leiste zum Reiter
%		 "EDITOR"und drückst auf "Run". 2D und 3D Modell öffnen sich.

% -	"Tab: Filter OSM-data": Im Drop-Down-Menü "23 Building" auswählen,
%		Button "Filter OSM-data" drücken
%		Wenn eine ID nicht erscheint, müssen die include-tags in den
%		Projektparametern ergänzt werden!


%% Triangulationsdaten des Gebäudes, ohne die Grundfläche

function T = get_building_topside(pp, iobj, in_v, iw_v, ir_v,...
	poly_outline_map, z_ground, testing, testplot, export_stl)

% pp							   Projektparameter: Globale Regeln für alle Gebäude
%									(Einstellungen) z.B. Mindesthöhe eines Gebäude oder
%									Einheit

% iobj							Objektnummer: Die Nummer des Gebäudes, das
%									verarbeitet wird

% in_v							Eine Liste (Vektor) mit Nummern der Punkte (Knoten),
%									die das Gebäude bilden. In OSM besteht ein Gebäude aus
%									Knoten (nodes" genannt)
%									Einfaches Beispiel in_v = [102, 104, 105, 106, 102]
%									--> Eckpunkte des Gebäude die das Umriss bilden

% iw_v							Eine Liste (Vektor) aus Nummern der Linien ("ways"
%									genannt), also wenn 2 Punkte verbunden sind oder
%									mehrere Punkte eine geschlossene Fläche bilden.


% ir_v							Eine Liste (Vektor) aus Nummern der Gruppen oder
%									"Relations", also ein Gebäude mit mehreren Teilen
%									z.B. Einkaufszentrum mit mehreren Gebäudeteilen.
%									Wenn das Gebäude keine Relation hat --> ir_v = []

% poly_outline_map			Gebäudeumriss in 2D. Der Umriss kann beschnitten
%									sein, wenn andere Gebäude oder Straßen dieses Gebäude
%									überdecken
%									Wenn das Gebäudeumriss dargestellt werden soll
%									--> plot(poly_outline_map)

% z_ground					   Höhe der Gebäudebasis (Z-Wert)

% testplot						Ausgabe von Textplots (true/false)

% export_stl					Ausgabe einer stl-Datei des Gebäudes (true/false)

global OSMDATA GV			% Globale Variable OSMDATA, die alle Werte aus osm.org
%									aufnehmen soll

%% Tesplot und Fenster für 2D- und 3D-Darstellung vorbereiten

if testplot
	
	% Testplot: 2D-Darstellung:
	fig1 = figure(43821528);
	clf(fig1,'reset');
	set(fig1,'Tag','maplab3d_figure');
	set(fig1,'Name','Test2D');
	set(fig1,'NumberTitle','off');
	ax1 = axes;
	hold(ax1,'on');
	axis(ax1,'equal');
	xlabel(ax1,'x / mm');
	ylabel(ax1,'y / mm');
	
	% Testplot: 3D-Darstellung:
	fig2		= figure(10050);
	clf(fig2,'reset');
	set(fig2,'Tag','maplab3d_figure');
	set(fig2,'Name','Test3D');
	set(fig2,'NumberTitle','off');
	cameratoolbar(fig2,'Show');
	ax2 = axes(fig2);
	hold(ax2,'on');
	axis(ax2,'equal');
	xlabel(ax2,'x / mm');
	ylabel(ax2,'y / mm');
	zlabel(ax2,'z / mm');
	% ax2.Visible='off';
	ax2.Clipping='off';
	facealpha = 0.8;			% Transparenz der Oberflächen		0.2
	edgealpha = 0.2;			% Transparenz der Kanten			0.2
	
else
	
	ax1 = [];
	ax2 = [];
	
end

%%
% Initializations:

% Default-Werte ggf. in mm umrechnen:
par.floor_height_def	= pp.buildings.floor_height_def_m/pp.project.scale*1000;

% Toleranzen:
% -	triangulation_gapsize -> Spaltbreite:
%		Polygone werden um eine bestimmte Spaltbreite verkleinert, um dazwischen
%     mit "T=triangulation(polyin)" die Triangulationsdaten einer nahezu
%		senkrechten Fläche zu erzeugen (die Wand eines Gebäudes).
% -	triangulation_tol_tp:
%		Vereinfachung der Triangulationsdaten mit triangulation_simplify:
%		Minimum distance between two points: If two points have a smaller distance
%     than tol_tp, they are merged.
if testing
	
	% sichtbare Spalte, Werte zum Testen:
	triangulation_gapsize = 0.1;
	
	% 1*triangulation_gapsize: Punkte werden nicht vereinigt
	triangulation_tol_tp	= 1*triangulation_gapsize;
	
else
	
	% Spalte nicht mehr sichtbar bei 0.001, geringere Anzahl Stützstellen:
	triangulation_gapsize = 0.02;
	
	% 5*triangulation_gapsize: Punkte werden vereinigt
	triangulation_tol_tp	= 5*triangulation_gapsize;
	
end

% Den vollständigen Gebäudeumriss anhand der OSM-Daten bestimmen und
% alle Members der Relations in der Struktur Nodes und Ways sammeln:

% poly_outline_osm				Gebäudeumriss

% nodes.in(kn,1)					vector of indices in OSMDATA.node(1,in)

% nodes.x(kn,1)					x-values of all nodes

% nodes.y(kn,1)					y-values of all nodes

% ways.iw(kw,1)					index iw in OSMDATA.way(1,iw)

% ways.id(kw,1)					OSM ID (OSMDATA.id.way(1,iw))

% ways.p(kw,1).x					Nx1 vector of x-values

% ways.p(kw,1).y					Nx1 vector of y-values

% ways.isclosed(kw,1)			the way has identical start and end vertices:
%										(true/false)


in_v = unique(in_v);
iw_v = unique(iw_v);
nodes.in	= in_v;
ways.iw = iw_v;
ways.id = zeros(size(ways.iw,1),1);
poly_outline_osm = polyshape;
poly_union_osm	= polyshape;

% Aus den OSM-Daten die Koordinaten ins MATLAB-Modell übernommen
% Schleife über alle Nodes, die zum Gebäude gehören
% Nimmt alle Node-Indizes, die zum Gebäude gehören (nodes.in).
% Holt aus den globalen OSM-Daten (OSMDATA) die x- und y-Koordinaten.
% Speichert sie in deiner lokalen Struktur nodes.
% Zeichnet sie (falls testplot = true) zur Kontrolle.

for kn = 1:size(nodes.in,1)
	
	% in = aktueller Index des Knotens in den OSMDATA-Arrays.
	% Der Node, welcher in den globalen OSM-Daten gerade verarbeitet wird
	in	= nodes.in(kn,1);
	
	% x-Koordinate des aktuellen Index
	nodes.x(kn,1) = OSMDATA.node_x_mm(1,in);
	
	% y-Koordinate des aktuellen Index
	nodes.y(kn,1) = OSMDATA.node_y_mm(1,in);
	
	
	if testplot
		
		get_building_topside_testplot_nwr('node',in,nodes.x(kn,1),nodes.y(kn,1),ax1);
		
	end
	
end

% Schleife über alle Ways, die zum Gebäude gehören
for kw = 1:size(ways.iw,1)
	
	% iw = Index des aktuellen Ways im globalen OSM-Datensatz.
	iw						= ways.iw(kw,1);
	
	% Hol die OSM-ID des aktuellen Ways und speichere sie in ways.id
	ways.id(kw,1)		= OSMDATA.id.way(1,iw);
	
	% x-Koordinate des Ways
	ways.p(kw,1).x		= OSMDATA.way(1,iw).x_mm(:);
	
	% y-Koordinate des Ways
	ways.p(kw,1).y		= OSMDATA.way(1,iw).y_mm(:);
	
	% Ist der Way geschlossen, erzeuge ein Polygon aus den Way mit der Funktion
	% union aus den x- und y-Werten
	if (abs(ways.p(kw,1).x(1,1)-ways.p(kw,1).x(end,1))<GV.tol_1) && ...
			(abs(ways.p(kw,1).y(1,1)-ways.p(kw,1).y(end,1))<GV.tol_1)
		
		ways.isclosed(kw,1)	= true;
		poly_union_osm	= union(poly_union_osm,...
			polyshape(ways.p(kw,1).x,ways.p(kw,1).y));
		
	else
		
		ways.isclosed(kw,1)	= false;
		
	end
	
	if testplot
		
		get_building_topside_testplot_nwr('way',iw,ways.p(kw,1).x,ways.p(kw,1).y,ax1);
		
	end
end

% Schleife über alle Relations, die zum Gebäude gehören
for i_ir_v=1:size(ir_v,1)
	
	% Alle Relationen zum Gebäude werden rekursiv gesucht, damit zu einer Relation
	% die nächste auch schon gefunden wird
	% Aktueller Index:
	inwr = ir_v(i_ir_v,1);
	type = 'relation';
	
	% only for the first call, will be overwritten because type='relation'
	role = '';
	
	% Building outline: relation member with role=outline or role=outer
	[poly_outline_osm,...
		poly_union_osm,...				% Building outline: all closed ways united
		nodes,...							% nodes stucture including the nodes of the relation
		ways...								% ways  stucture including the ways  of the relation
		]= get_building_topside_search_relation(...
		inwr,...								% OSM-Data: Index in OSMDATA.way(1,inwr) or OSMDATA.relation(1,inwr)
		type,...								% way/relation
		role,...								% role of a relation member (inner, outer, ...)
		poly_outline_osm,...				% Building outline: relation member with role=outline or role=outer
		poly_union_osm,...				% Building outline: all closed ways united
		nodes,...							% nodes stucture
		ways,...								% ways  stucture
		testplot,...						% Test outputs (true/false)
		ax1);									% Axis for testplots
	
end

% Fehler wenn poly_outline_osm leer ist:
if numboundaries(poly_outline_osm)==0
	
	% There seems to be no relation member with role=outline or role=outer:
	if numboundaries(poly_union_osm)~=0
		
		% Use poly_union_osm as building outline:
		poly_outline_osm	= poly_union_osm;
		
	else
		
		% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		% ToDo:
		% Statt Abbruch sollte hier der gegebenen Umriss poly_outline_map mit einem Flachdach verwendet werden !!!!!!!!!
		% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		id_str = '';
		
		for i_iw_v=1:size(iw_v,1)
			
			iw	= iw_v(i_iw_v,1);
			id_str = sprintf('%sway: ID=%1.0f\n',id_str,OSMDATA.id.way(1,iw));
			
		end
		
		for i_ir_v=1:size(ir_v,1)
			
			ir	= ir_v(i_ir_v,1);
			id_str = sprintf('%srelation: ID=%1.0f\n',...
				id_str,OSMDATA.id.relation(1,ir));
			
		end
		
		% Get the tags of an OSM map feature as character array
		errortext		= sprintf([...
			'Error when calculating a building shape:\n',...
			'The following OpenStreetMap objects\n',...
			'do not seem to contain any areas.:\n',...
			'%s'],id_str);
		errormessage(errortext);
		
	end
end


% Fehler wenn poly_outline_osm aus mehr als einer Region besteht:
poly_outline_osm_reg = regions(poly_outline_osm);

if size(poly_outline_osm_reg,1)>1
	
	if ~isdeployed
		
		% Ausführung innerhalb der Entwicklungsumgebung MATLAB:
		fig_error=figure;
		set(fig_error,'Tag','maplab3d_figure');
		ax_error		= axes(fig_error);
		plot(ax_error,poly_outline_osm);
		axis(ax_error,'equal');
		title(ax_error,'poly_outline_osm','Interpreter','none');
		
	end
	
	errormessage;
end

%% Testing:

% Der Grundriss kann von anderen Kartenobjekten beschnitten sein:
if islogical(poly_outline_map)
	if poly_outline_map
		
		% testweise eine Linie durch die Mitte des Grundrisses erzeugen:
		% Grundriss Mitte
		[x,y]				= centroid(poly_outline_osm);
		x_line			= [x x+1000];
		y_line			= [y y     ];
		
		% LineWidth
		liwi				= 3;
		
		% Die Linie vom Grundriss subtrahieren:
		% (Den Fall, dass ein Grundriss aus zwei Hälften besteht, wird es nicht geben.)
		poly_line			= line2poly(x_line,y_line,liwi);
		poly_outline_map	= subtract(poly_outline_osm,poly_line);
		
	else
		% den vollständigen Gebäude-Grundriss verwenden:
		poly_outline_map	= poly_outline_osm;
	end
end

if testplot
	% 2D-Darstellung:
	
	for ic=1:size(ax1.Children,1)
		
		if strcmp(ax1.Children(ic,1).Type,'polygon')
			ax1.Children(ic,1).EdgeColor	= [1 1 1]*0.9;
			
		elseif strcmp(ax1.Children(ic,1).Type,'line')
			
			ax1.Children(ic,1).Color	= [1 1 1]*0.9;
			
		end
	end
	
	plot(ax1,poly_outline_osm.Vertices(:,1),poly_outline_osm.Vertices(:,2),...
		':k','MarkerSize',10);
	
	plot(ax1,poly_outline_map,'FaceAlpha',0,'EdgeColor','r');
	
	plot(ax1,poly_outline_map.Vertices(:,1),poly_outline_map.Vertices(:,2),...
		'.r','MarkerSize',10);
	
	title(ax1,'poly_outline_map (.r) / poly_outline_osm (:k)',...
		'Interpreter','none');
	
end


%% Alle Flächen innerhalb des Umrisses poly_outline_map, die keine Dächer
%  sind (Gebäudewand):
% Initialisierung:
poly_triang		= poly_outline_map;

% Stützstellen für die Berechnung der Höhen durch Interpolation:
% Gebäudegrundfläche:
ScInt_xyz		= [...
	
% gesamter äußerer Gebäudeumriss der OSM-Daten
poly_outline_osm.Vertices(:,1) ...
poly_outline_osm.Vertices(:,2) ...
z_ground * ones(size(poly_outline_osm.Vertices,1),1)];

ScInt_xyz		= [ScInt_xyz;...
	
% evtl. beschnittener äußerer Gebäudeumriss
poly_outline_map.Vertices(:,1) ...
poly_outline_map.Vertices(:,2) ...
z_ground * ones(size(poly_outline_map.Vertices,1),1)];

% Triangulationsdaten:
T								= [];
T.Points						= zeros(0,2);
T.ConnectivityList		= zeros(0,3);


%% Dachflächen identifizieren und Höhe berechnen:
% Bei sich überlappenden Dachflächen muss die Dachfläche mit der größeren Höhe
% von einer niedrigeren Dachfläche subtrahiert werden. Daher müssen zunächst
% nur die Höhen der Dachflächen bestimmt werden.

% Ergebnis:
% the way represents a roof (true/false)
% ways.isroof(kw,1)

% roof shape
% ways.roof_shape{kw,1}

% Number of floors
% ways.building_levels(kw,1)

% Total heigth from ground level to peak in mm
% ways.height(kw,1)

% Roof height in mm
% ways.roof_height(kw,1)

% Complete roof outline base on OSM data
% ways.poly_outline_osm_roof(kw,1)

% roof ridge
% ways.roof_ridge(kw,1)

% roof edge
% ways.roof_edge(kw,1)

ways.isroof				= false(size(ways.iw));
ways.roof_shape		= cell(size(ways.iw));
ways.building_levels	= zeros(size(ways.iw));
ways.height				= zeros(size(ways.iw));
ways.roof_height		= zeros(size(ways.iw));

for kw=1:size(ways.iw,1)
	
	ways.poly_outline_osm_roof(kw,1)	= polyshape;
	
	if ways.isclosed(kw,1)
		
		% Der ganze Gebäudegrundriss muss durch Dächer abgedeckt sein,
		% bis auf schmale Spalte: Sicherheitsabfrage
		iw					= ways.iw(kw,1);
		roof_shape		= get_building_topside_get_tag_value('way',iw,...
			'roof:shape','string');
		
		roof_colour		= get_building_topside_get_tag_value('way',iw,...
			'roof:colour','string');
		
		if ~isempty(roof_shape)||~isempty(roof_colour)
			
			% The tag 'roof:shape' exists
			ways.isroof(kw,1)	= true;
			
			[  ways...								% ways  stucture
				]=get_building_topside_get_roofheight(...
				pp,...								% Projektparameter
				par,...								% weitere Parameter
				iobj,...								% Object number
				iw,...								% OSM-Daten: Index iw in OSMDATA.way(1,iw)
				ways,...								% ways  stucture
				ax1,...								% Achsenobjekt für Testplots
				testplot);							% Anzeige von Testplots (true/false)
			
		end
	end
end


%% Sich überlappende Dachflächen gegenseitig beschneiden, so dass nur die
% jeweils höheren Dachflächen übrig bleiben:
% Beginne mit dem höchsten Dach kw1=kw_sort_v(1,1), subtrahiere es von allen
% anderen niedrigeren Dächern, usw.
% Zusätzlich die Dachflächen auf den gegebenen Gebäudeumriss poly_outline_map
% beschneiden. Ergebnis:
% ways.poly_outline_map_roof(kw,1)		Actual roof outline

ways.poly_outline_map_roof	= ways.poly_outline_osm_roof;

for kw = 1:size(ways.iw,1)
	
	ways.poly_outline_map_roof(kw,1) = ...
		intersect(ways.poly_outline_map_roof(kw,1),poly_outline_map);
	
end

[~,kw_sort_v] = sort(ways.height,'descend');

for ikw1=1:(size(kw_sort_v,1)-1)
	
	kw1	= kw_sort_v(ikw1,1);
	
	if ways.isroof(kw1,1)
		
		for ikw2=(ikw1+1):size(kw_sort_v,1)
			
			kw2	= kw_sort_v(ikw2,1);
			
			if ways.isroof(kw2,1)
				
				ways.poly_outline_map_roof(kw2,1) = ...
					subtract(ways.poly_outline_map_roof(kw2,1),...
					ways.poly_outline_osm_roof(kw1,1));
				
			end
		end
	end
end

%% Testing: Anzeige der Struktur ways im Command Window:

if testplot
	
	fn	= {
		'iw';...								% index iw in OSMDATA.way(1,iw)
		'id';...								% OSM ID (OSMDATA.id.way(1,iw))
		'isclosed';...						% the way has identical start and end vertices (true/false)
		'isroof';...						% the way represents a roof (true/false)
		'roof_shape';...					% roof shape
		'building_levels';...			% number of floors
		'height';...						% total height from ground level to roof peak in mm
		'roof_height';...					% roof height in mm
		'poly_outline_osm_roof';...	% complete roof outline based on OSM data
		'poly_outline_map_roof'};...	% actual roof outline
		
	l_field	= zeros(size(fn));
	for i=1:size(fn,1)
		l_field(i,1)	= length(fn{i,1});
		for kw=1:size(ways.iw,1)
			if iscell(ways.(fn{i,1}))
				l_field(i,1)	= max(l_field(i,1),length(ways.(fn{i,1}){kw,1}));
			else
				if isnumeric(ways.(fn{i,1}))||islogical(ways.(fn{i,1}))
					l_field(i,1)	= max(l_field(i,1),length(num2str(ways.(fn{i,1})(kw,1))));
				end
			end
		end
	end
	
	length_kw_max	= max(2,length(num2str(size(ways.iw,1))));
	
	fprintf(1,'\nways. ...\n');
	
	for i=1:size(fn,1)				% Table header
		
		if i==1
			
			fprintf(1,'%skw  ',blanks(length_kw_max-2));
			
		else
			
			fprintf(1,'  ');
		end
		
		fprintf(1,'%s%s',fn{i,1},blanks(l_field(i,1)-length(fn{i,1})));
		
		if i==size(fn,1)
			
			fprintf(1,'\n');
			
		end
		
	end
	
	for kw=1:size(ways.iw,1)		% Table
		
		for i=1:size(fn,1)
			
			if i==1
				
				kw_str	= num2str(kw);
				
				fprintf(1,'%s%s  ',blanks(length_kw_max-length(kw_str)),kw_str);
				
			else
				
				fprintf(1,'  ');
				
			end
			
			if iscell(ways.(fn{i,1}))
				
				value_str	= ways.(fn{i,1}){kw,1};												% character array
				
			else
				
				if isnumeric(ways.(fn{i,1}))||islogical(ways.(fn{i,1}))
					
					value_str	= num2str(ways.(fn{i,1})(kw,1));								% number
					
				else
					
					value_str	= num2str( size(ways.(fn{i,1})(kw,1).Vertices,1) );	% polygon
					
				end
			end
			
			fprintf(1,'%s%s',blanks(l_field(i,1)-length(value_str)),value_str);
			
			if i==size(fn,1)
				
				fprintf(1,'\n');
				
			end
		end
	end
	
	fprintf(1,'\n');
	
end


%% Triangulationsdaten der Dachflächen berechnen

for kw = 1:size(ways.iw,1)
	
	ways.poly_outline_map_roof_red(kw,1) = polyshape;
	
	if ways.isroof(kw,1)
		
		% Actual roof outline, reduced by the gap triangulation_gapsize
		% to create the wall: Wanddicke
		ways.poly_outline_map_roof(kw,1)	= ...
			polybuffer(ways.poly_outline_map_roof(kw,1),...
			-triangulation_gapsize,'JointType','miter');
		
		% Verbleibende Fläche innerhalb des Gebäudeumrisses ohne die Dächer
		% (gleich der Gebäudewand):
		poly_triang	= subtract(poly_triang,ways.poly_outline_map_roof(kw,1));
		
		% Triangulatiosdaten des Dachs berechnen:
		iw	= ways.iw(kw,1);
		[	poly_triang_roof,...	% ix1 polygon vector von Teilflächen des Dachs, innerhalb derer trianguliert werden soll
			ScInt_xyz_roof...		% Nx3 Matrix mit xyz-Werten der Dachform
			] = get_building_topside_get_roofshape(...
			pp,...							% Projektparameter
			par,...							% weitere Parameter
			iw,...							% OSM-Daten: Index iw in OSMDATA.way(1,iw)
			ways,...							% ways stucture
			triangulation_gapsize,...	% Breite des Spalts zwischen Dachflächen unterschiedlicher Höhe (Wand)
			ax1,...							% Achsenobjekt für Testplots
			ax2,...							% Achsenobjekt für Testplots
			testplot);						% Anzeige von Testplots (true/false)
		
		% --------------------------------------------------------------------------------------------------------------
		% war in get_building_topside_get_roofshape: Anfang:
		% Berechnung von:
		% T_roof						Triangulationsdaten des Dachs
		% z_outline_map_roof		z-Werte auf den Punkten von ways.poly_outline_map_roof(kw,1) (Höhenverlauf des Dachumriss)
		
		% Triangulation des Dachs:
		
		% scatteredInterpolant für die Interpolation der Dachhöhe berechnen:
		ScInt			= scatteredInterpolant(ScInt_xyz_roof(:,1),ScInt_xyz_roof(:,2),ScInt_xyz_roof(:,3));
		ScInt.Method					= 'linear';
		ScInt.ExtrapolationMethod	= 'linear';
		
		% Triangulationsdaten des Dachs erzeugen:
		T_roof								= [];
		T_roof.Points						= zeros(0,2);
		T_roof.ConnectivityList			= zeros(0,3);
		
		for i = 1:size(poly_triang_roof,1)
			
			if numboundaries(poly_triang_roof(i,1))>0
				% Triangulation:
				T_roof_i						= triangulation(poly_triang_roof(i,1));
				% T_roof_i ist read-only: neu zuweisen:
				T_roof_i_P					= T_roof_i.Points;
				T_roof_i_CL					= T_roof_i.ConnectivityList;
				% Die z-Werte (Höhen) durch Interpolation berechnen und als 3. Spalte T_roof_i_P hinzufügen:
				T_roof_i_P					= [T_roof_i_P ScInt(T_roof_i_P(:,1),T_roof_i_P(:,2))];
				% Die Punkte T_roof_i_P werden an das Ende von T_roof.Points angehängt und haben dann einen höheren Index.
				% Die Indices dieser Punkte in der connectivity list müssen entsprechend erhöht werden:
				size_T_roof_P				= size(T_roof.Points,1);
				% Triangulationsdaten zusammensetzen:
				T_roof.Points				= [T_roof.Points          ;T_roof_i_P ];
				T_roof.ConnectivityList	= [T_roof.ConnectivityList;T_roof_i_CL+size_T_roof_P];
			end
		end
		
		% z-Werte auf den Punkten von ways.poly_outline_map_roof(kw,1) (Höhenverlauf des Dachumrisses):
		z_outline_map_roof	= ScInt(...
			ways.poly_outline_map_roof(kw,1).Vertices(:,1),...
			ways.poly_outline_map_roof(kw,1).Vertices(:,2));
		
		% Sicherheitsabfrage: Innerhalb des Dachumrisses darf es keine leeren Teilflächen mehr geben:
		if ~isdeployed
			% Ausführung innerhalb der Entwicklungsumgebung MATLAB:
			area_poly_outline		= area(ways.poly_outline_map_roof(kw,1));
			area_poly_triang		= 0;
			
			for i=1:size(poly_triang_roof,1)
				area_poly_triang	= area_poly_triang+area(poly_triang_roof(i,1));
			end
			
			if abs(area_poly_outline-area_poly_triang)>1e-8
				% Warnung ausgeben:
				get_building_topside_display_warning(sprintf([...
					'The area within the roof outline has not been calculated completely.\n',...
					'area_poly_outline = %g mm^2\n',...
					'area_poly_triang  = %g mm^2\n',...
					'difference        = %g mm^2'],...
					area_poly_outline,area_poly_triang,area_poly_outline-area_poly_triang),'way',iw);
			end
		end
		
		% poly_triang_roof darstellen: Innerhalb des Gebäudeumrisses darf es keine leeren Teilflächen mehr geben:
		if testplot
			plot3(ax2,ScInt_xyz_roof(:,1),ScInt_xyz_roof(:,2),ScInt_xyz_roof(:,3),'.r','MarkerSize',10);
			for i=1:size(poly_triang_roof,1)
				plot(ax1,poly_triang_roof(i,1),'FaceAlpha',0.1);
				plot(ax1,poly_triang_roof(i,1).Vertices(:,1),poly_triang_roof(i,1).Vertices(:,2),'.k','MarkerSize',10);
			end
		end
		
		% war in get_building_topside_get_roofshape: Ende
		% --------------------------------------------------------------------------------------------------------------
		
		% Triangulationsdaten erweitern:
		% Die Punkte T_roof.Points werden an das Ende von T.Points angehängt
		% und haben dann einen höheren Index.
		% Die Indices dieser Punkte in der connectivity list müssen entsprechend
		% erhöht werden:
		size_T_P	= size(T.Points,1);
		
		% Triangulationsdaten zusammensetzen:
		T.Points	= [T.Points ; T_roof.Points];
		T.ConnectivityList = [T.ConnectivityList;...
			T_roof.ConnectivityList	+ size_T_P];
		
		% Stützstellen für die Interpolation der Höhenwerte der Gebäudewand
		% erweitern:
		ScInt_xyz = [ScInt_xyz;...
			ways.poly_outline_map_roof(kw,1).Vertices(:,1) ...	% äußerer Dachumriss
			ways.poly_outline_map_roof(kw,1).Vertices(:,2) ...
			z_outline_map_roof];
		
	end
end



%% Triangulation der übrigen Flächen innerhalb des Gebäudeumrisses,
%  die zu keinem Dach gehören (die Gebäudewand):

% Sicherheitsabfrage: Innerhalb des Gebäudeumrisses darf es keine
% leeren Teilflächen mehr geben:
if ~isdeployed
	
	% Ausführung innerhalb der Entwicklungsumgebung MATLAB:
	area_poly_outline		= area(poly_outline_map);
	area_poly_inner		= 0;
	area_poly_inner		= area_poly_inner+area(poly_triang);
	
	for kw=1:size(ways.iw,1)
		
		area_poly_inner	= area_poly_inner+area(ways.poly_outline_map_roof(kw,1));
		
	end
	
	if abs(area_poly_outline-area_poly_inner)>1e-8
		
		% Warnung ausgeben:
		get_building_topside_display_warning(sprintf([...
			'The area within the building outline has not been calculated completely.\n',...
			'area_poly_outline = %g mm^2\n',...
			'area_poly_inner   = %g mm^2\n',...
			'difference        = %g mm^2'],...
			area_poly_outline,area_poly_inner,...
			area_poly_outline-area_poly_inner),[],[]);
		
	end
end

% poly_triang darstellen: Innerhalb des Gebäudeumrisses darf es keine
% leeren Teilflächen mehr geben:
if testplot
	
	plot(ax1,poly_triang,'FaceAlpha',0.1);
	plot(ax1,poly_triang.Vertices(:,1),poly_triang.Vertices(:,2),...
		'.k','MarkerSize',10);
	
end

% Die Stützstellen können nan enthalten, verursacht von Löchern
% in Polygonen: löschen:
ScInt_xyz(isnan(ScInt_xyz(:,1)),:)	= [];

% Die z-Werte von doppelten xy-Stützstellen in ScInt_xyz mitteln
% (deren z-Werte sollten identisch sein) und doppelte Stützstellen löschen:

i_delete		= false(size(ScInt_xyz,1),1);

for i=1:size(ScInt_xyz,1)
	
	i_equal_logical	= ~i_delete                   &...
		(abs(ScInt_xyz(i,1)-ScInt_xyz(:,1))<GV.tol_1)&...
		(abs(ScInt_xyz(i,2)-ScInt_xyz(:,2))<GV.tol_1);
	i_equal				= find(i_equal_logical);
	
	if size(i_equal,1)>1
		ScInt_xyz(i,3)						= mean(ScInt_xyz(i_equal_logical,3));
		i_equal_logical(i,1)				= false;
		i_delete(i_equal_logical,:)	= true;
		
	end
end

ScInt_xyz(i_delete,:)	= [];

if testplot
	
	plot3(ax2,ScInt_xyz(:,1),ScInt_xyz(:,2),ScInt_xyz(:,3),'xm','MarkerSize',10,'LineWidth',2);
	
end

% scatteredInterpolant für die Interpolation der Gebäudewand berechnen:
ScInt			= scatteredInterpolant(ScInt_xyz(:,1),ScInt_xyz(:,2),ScInt_xyz(:,3));
ScInt.Method					= 'linear';
ScInt.ExtrapolationMethod	= 'linear';

% Triangulationsdaten der Gebäudewand zu T hinzufügen:
if numboundaries(poly_triang)>0
	
	% Triangulation:
	T_i						= triangulation(poly_triang);
	
	% T_i ist read-only, neu zuweisen:
	T_i_P						= T_i.Points;
	T_i_CL					= T_i.ConnectivityList;
	
	% Die z-Werte (Höhen) durch Interpolation berechnen und als
	% 3. Spalte T_i_P hinzufügen:
	T_i_P		= [T_i_P ScInt(T_i_P(:,1),T_i_P(:,2))];
	
	% Die Punkte T_P werden an das Ende von T.Points angehängt und haben dann
	% einen höheren Index. Die Indices dieser Punkte in der connectivity list
	% müssen entsprechend erhöht werden:
	size_T_P					= size(T.Points,1);
	
	% Triangulationsdaten zusammensetzen:
	T.Points					= [T.Points          ;T_i_P ];
	T.ConnectivityList	= [T.ConnectivityList;T_i_CL+size_T_P];
	
end

% Unterseite hinzufügen
if export_stl
	
	% Triangulation:
	T_i						= triangulation(poly_outline_map);
	
	% T_i ist read-only, neu zuweisen:
	T_i_P						= T_i.Points;
	T_i_CL					= T_i.ConnectivityList;
	
	% Die z-Werte (Höhen) durch Interpolation berechnen und als
	% 3. Spalte T_i_P hinzufügen:
	T_i_P		= [T_i_P ScInt(T_i_P(:,1),T_i_P(:,2))];
	
	% Die Punkte T_P werden an das Ende von T.Points angehängt und haben dann
	% einen höheren Index. Die Indices dieser Punkte in der connectivity list
	% müssen entsprechend erhöht werden:
	size_T_P					= size(T.Points,1);
	
	% Triangulationsdaten zusammensetzen:
	T.Points					= [T.Points          ;T_i_P ];
	T.ConnectivityList	= [T.ConnectivityList;T_i_CL+size_T_P];
	
end

% Vereinfachung der Triangulationsdaten mit triangulation_simplify:
% p						Points, specified as a matrix whose columns are the
%							x-coordinates, y-coordinates, and z-coordinates of the
%							triangulation points. The row numbers of P are the
%							vertex IDs in the triangulation.

% cl						Triangulation connectivity list, specified as
%							an m-by-3 matrix, where m is the number of triangles.
%							Each row of T contains the vertex IDs that define
%							a triangle or tetrahedron. The vertex IDs are the row
%							numbers of the input points. The ID of a triangle in the
%							triangulation is the corresponding row number in cl.

% tol_tp					Minimum distance between two points.
%							If two points have a smaller distance than tol_tp,
%							they are merged.

% testplot_xlimits	x- and y-limits of the test plots. Default: []

% testplot_ylimits	The testplot is shown, if the mean value of the points
%							to be merged is within the limits.

% msg						message string for the waitbar

T = triangulation_simplify(...
	T.Points,...							% p
	T.ConnectivityList,...				% cl
	triangulation_tol_tp,...			% tol_tp
	[],...									% testplot_xlimits
	[],...									% testplot_ylimits
	'');										% msg% Try to repair and save the STL file:


if export_stl
	
	try
		
		[T_rep,status] = stlrepair(T);
		
	catch ME
		
		if ~isdeployed
			
			errormessage('',ME);
			
		else
			
			status = 0;
			
		end
	end
	
	if status==0
		
		% the repair was not successful:
		T_rep = triangulation(T.ConnectivityList,T.Points);
		path_filename_stl = ...
			[GV.projectdirectory 'building' ' - to be repaired.stl'];
		
	else
		
		path_filename_stl = [GV.projectdirectory 'building' '.stl'];
		
	end
	
	stlwrite(T_rep,path_filename_stl);
end


%% 3D Darstellung des Ergebnisses:

if testplot
	
	if ~isempty(T.ConnectivityList)
		
		F = [T.ConnectivityList(:,1) ...
			T.ConnectivityList(:,2) ...
			T.ConnectivityList(:,3) ...
			T.ConnectivityList(:,1)];
		
		patch(ax2,'faces',F,'vertices',T.Points,'EdgeColor',[0 0 0],...
			'FaceColor',[1 1 1]*0.95,'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
		
		plot3(ax2,T.Points(:,1),T.Points(:,2),T.Points(:,3),...
			'LineWidth', 0.5, 'LineStyle', 'none', 'Color', 'k',...
			'Marker', '.', 'MarkerSize', 10);
		
		view(ax2,3);
		
	end
end



