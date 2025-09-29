function T...						% Triangulationsdaten des Gebäudes, ohne die Grundfläche
	=get_building_topside(...
	pp,...							% Projektparameter
	iobj,...							% Object number
	in_v,...							% Vector of indices in in OSMDATA.node(1,in)
	iw_v,...							% Vector of indices iw in OSMDATA.way(1,iw)
	ir_v,...							% Vector of indices ir in OSMDATA.relation(1,ir)
	poly_outline_map,...			% Gebäudeumriss auf der Landkarte: kann von anderen Kartenobjekten beschnitten sein.
	z_ground)						% z-Wert (Höhe) der Gebäudebasis


global OSMDATA PP GV

% Testing:
testplot		= true;
if nargin==0
	testplot		= true;
	
	% Links:
	% https://wiki.openstreetmap.org/wiki/Simple_3D_Buildings
	% https://wiki.openstreetmap.org/wiki/ProposedRoofLines
	% https://wiki.openstreetmap.org/wiki/DE:OSM-4D/Roof_table
	% https://wiki.openstreetmap.org/wiki/OSM-4D/Roof_table
	% https://wiki.openstreetmap.org/wiki/Key:building:part
	% https://wiki.openstreetmap.org/wiki/Key:roof:shape
	% https://wiki.openstreetmap.org/wiki/Key:building:levels
	% https://wiki.openstreetmap.org/wiki/Key:roof:height
	% https://wiki.openstreetmap.org/wiki/Key:height
	% https://wiki.openstreetmap.org/wiki/Key:roof:direction
	
	% 3D-Beispiele:
	% München:
	% https://demo.f4map.com/#lat=48.1383243&lon=11.5737055&zoom=18&camera.theta=53.308&camera.phi=-26.929
	% Neuschwanstein
	% https://demo.f4map.com/#lat=47.5575497&lon=10.7498066&zoom=19&camera.theta=59.66&camera.phi=-12.032
	% Mont Saint-Michel:
	% https://demo.f4map.com/#lat=48.6359145&lon=-1.5112268&zoom=19&camera.theta=58.999&camera.phi=38.961
	% Köln:
	% https://demo.f4map.com/#lat=50.9416796&lon=6.9592575&zoom=18&camera.theta=61.092&camera.phi=10.313
	
	% Beispieldaten vorbereiten:
	% -	MATLAB installieren und Einstellungen vornehmen
	%		siehe README in https://github.com/Akilth/MapLab3D/tree/Development
	% -	MapLab3D herunterladen (development branch!) und starten (maplab3d.mlapp)
	% -	Projektparameter: Maßstabszahl maximal 10000 (project.scale), sonst werden Gebäude nicht dargestellt.
	% -	Projektparameter laden
	% -	"Menu File: Load OSM- and elevation-data settings - Do not load elevation-data (flat map)" aktivieren:
	%		Dann müssen keine Höhendaten vorbereitet werden.
	% -	OSM-Daten eines Beispielgebietes laden
	% -	"Tab: Filter OSM-data": Im Drop-Down-Menü "23 Building" auswählen, Button "Filter OSM-data" drücken
	%		Wenn eine ID nicht erscheint, müssen die include-tags in den Projektparametern ergänzt werden!
	% -	IDs eines Beispielgebäudes hier eintragen
	
	id_n_v		= zeros(0,1);
	id_w_v		= zeros(0,1);
	id_r_v		= zeros(0,1);
	testnr	= 2;
	switch testnr
		case 1
			% Muenchen_Frauenkirche.osm
			id_w_v(end+1,1)=80965659;				% https://www.openstreetmap.org/way/80965659			roof:shape=gabled
		case 2
			% Muenchen_Frauenkirche.osm
			id_r_v(end+1,1)=2181619;				% https://www.openstreetmap.org/relation/2181619	Frauenkirche
		case 3
			% Muenchen_Frauenkirche.osm
			id_w_v(end+1,1)=242367319;				% https://www.openstreetmap.org/way/242367319		roof:shape=pyramidal
		case 4
			% Muenchen_Rathaus.osm																						Rathaus
			id_w_v(end+1,1)=223907278;				% https://www.openstreetmap.org/way/223907278		Dach ohne roof:shape=* !
			id_w_v(end+1,1)=222518028;				% https://www.openstreetmap.org/way/222518028
			id_w_v(end+1,1)=219431689;				% https://www.openstreetmap.org/way/219431689
			id_w_v(end+1,1)=223907282;				% https://www.openstreetmap.org/way/223907282
			id_w_v(end+1,1)=244566667;				% https://www.openstreetmap.org/way/244566667
			id_w_v(end+1,1)=244566417;				% https://www.openstreetmap.org/way/244566417
			id_w_v(end+1,1)=224138012;				% https://www.openstreetmap.org/way/224138012
			% Die ways sind hier noch unvollständig!
			id_r_v(end+1,1)=147095;					% https://www.openstreetmap.org/relation/2181619	Rathaus
		case 5
			% Muenchen_Rathaus.osm
			id_w_v(end+1,1)=80965578;				% https://www.openstreetmap.org/way/80965578			roof:shape=gabled
		case 6
			
		case 7
			
	end
	% Indices in den OSM-Daten berechnen:
	in_v		= zeros(size(id_n_v));
	iw_v		= zeros(size(id_w_v));
	ir_v		= zeros(size(id_r_v));
	for i=1:size(id_n_v,1), in_v(i,1)=find(OSMDATA.id.node    ==id_n_v(i,1),1); end
	for i=1:size(id_w_v,1), iw_v(i,1)=find(OSMDATA.id.way     ==id_w_v(i,1),1); end
	for i=1:size(id_r_v,1), ir_v(i,1)=find(OSMDATA.id.relation==id_r_v(i,1),1); end
	% Weitere Eingabevariablen:
	pp			= PP;
	z_ground	= 0;
	
	% Default-Werte:
	% Zur Zeit sind die Parameter für Gebäude noch nicht in der Projektparameter-Datei enthalten:
	% Struktur pp erweitern:
	pp.buildings.floor_height_def_m			= 3;		% Höhe eines Stockwerks in m
	%																  https://wiki.openstreetmap.org/wiki/Key:building:levels#Values
	pp.buildings.roof_angle_def_deg			= 30;		% Dachneigung in °
	%																  https://de.wikipedia.org/wiki/Dachneigung
	pp.buildings.building_levels_def			= 1;		% Number of floors: buildings
	pp.buildings.religious_levels_def		= 3;		% Number of floors: religious institutions
	pp.buildings.castle_levels_def			= 3;		% Number of floors: castles
	for iobj=1:size(pp.obj,1)
		if ~isempty(pp.obj(iobj,1).description)
			switch pp.obj(iobj,1).description
				case 'Building'
					pp.buildings.building_objno	= iobj;	% Object number of buildings
				case 'Religious Institution'
					pp.buildings.religious_objno	= iobj;	% Object number of religious institutions
				case 'Castle'
					pp.buildings.castle_objno		= iobj;	% Object number of castles
			end
		end
	end
	
	% Default-Werte ggf. in mm umrechnen:
	par.floor_height_def					= pp.buildings.floor_height_def_m/pp.project.scale*1000;
	
end
if testplot
	% Testplot: 2D-Darstellung:
	fig1		= figure(43821528);
	clf(fig1,'reset');
	set(fig1,'Tag','maplab3d_figure');
	set(fig1,'Name','Test2D');
	set(fig1,'NumberTitle','off');
	ax1		= axes;
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
	ax2		= axes(fig2);
	hold(ax2,'on');
	axis(ax2,'equal');
	xlabel(ax2,'x / mm');
	ylabel(ax2,'y / mm');
	zlabel(ax2,'z / mm');
	facealpha	= 0.8;			% Transparenz der Oberflächen		0.2
	edgealpha	= 0.2;			% Transparenz der Kanten			0.2
else
	ax1			= [];
	ax2			= [];
end

% --------------------------------------------------------------------------------------------------------------------
% Initializations:

% Toleranzen:
% -	triangulation_gapsize:
%		Spaltbreite:
%		Polygone werden um eine bestimmte Spaltbreite verkleinert, um dazwischen mit "T=triangulation(polyin)"
%		die Triangulationsdaten einer nahezu senkrechten Fläche zu erzeugen (die Wand eines Gebäudes).
% -	triangulation_tol_tp
%		Vereinfachung der Triangulationsdaten mit triangulation_simplify:
%		Minimum distance between two points: If two points have a smaller distance than tol_tp, they are merged.
testing	= true;			% true/false
if testing
	% sichtbare Spalte, Werte zum Testen:						% z. B.:
	triangulation_gapsize	= 0.05;								% 0.1
	triangulation_tol_tp		= 1*triangulation_gapsize;		% 1*triangulation_gapsize: Punkte werden nicht vereinigt
else
	% Spalte nicht mehr sichtbar, geringere Anzahl Stützstellen:
	triangulation_gapsize	= 0.001;								% 0.001
	triangulation_tol_tp		= 5*triangulation_gapsize;		% 5*triangulation_gapsize: Punkte werden vereinigt
end

% Den vollständigen Gebäudeumriss anhand der OSM-Daten bestimmen und
% alle members der relations in der Struktur nodes und ways sammeln:
% Ergebnis:
% -	poly_outline_osm							building outline
% -	nodes.in(kn,1)								vector of indices in in OSMDATA.node(1,in)
%		nodes.x(kn,1)								x-values of all nodes
%		nodes.y(kn,1)								y-values of all nodes
% -	ways.iw(kw,1)								index iw in OSMDATA.way(1,iw)
%		ways.id(kw,1)								OSM ID (OSMDATA.id.way(1,iw))
%		ways.p(kw,1).x								Nx1 vector of x-values
%		ways.p(kw,1).y								Nx1 vector of y-values
%		ways.isclosed(kw,1)						the way has identical start and end vertices (true/false)
in_v					= unique(in_v);
iw_v					= unique(iw_v);
nodes.in				= in_v;
ways.iw				= iw_v;
ways.id				= zeros(size(ways.iw,1),1);
poly_outline_osm	= polyshape;
poly_union_osm		= polyshape;
for kn=1:size(nodes.in,1)
	in						= nodes.in(kn,1);
	nodes.x(kn,1)		= OSMDATA.node_x_mm(1,in);
	nodes.y(kn,1)		= OSMDATA.node_y_mm(1,in);
	if testplot
		testplot_nwr('node',in,nodes.x(kn,1),nodes.y(kn,1),ax1);
	end
end
for kw=1:size(ways.iw,1)
	iw						= ways.iw(kw,1);
	ways.id(kw,1)		= OSMDATA.id.way(1,iw);
	ways.p(kw,1).x		= OSMDATA.way(1,iw).x_mm(:);
	ways.p(kw,1).y		= OSMDATA.way(1,iw).y_mm(:);
	if    (abs(ways.p(kw,1).x(1,1)-ways.p(kw,1).x(end,1))<GV.tol_1)&&...
			(abs(ways.p(kw,1).y(1,1)-ways.p(kw,1).y(end,1))<GV.tol_1)
		ways.isclosed(kw,1)	= true;
		poly_union_osm	= union(poly_union_osm,polyshape(ways.p(kw,1).x,ways.p(kw,1).y));
	else
		ways.isclosed(kw,1)	= false;
	end
	if testplot
		testplot_nwr('way',iw,ways.p(kw,1).x,ways.p(kw,1).y,ax1);
	end
end
for i_ir_v=1:size(ir_v,1)
	% Searching the relation recursively:
	inwr					= ir_v(i_ir_v,1);
	type					= 'relation';
	role					= '';				% only for the first call, will be overwritten because type='relation'
	[  poly_outline_osm,...				% Building outline: relation member with role=outline or role=outer
		poly_union_osm,...				% Building outline: all closed ways united
		nodes,...							% nodes stucture including the nodes of the relation
		ways...								% ways  stucture including the ways  of the relation
		]=search_relation_local(...
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
	if numboundaries(poly_union_osm)==0
		% Use poly_union_osm as building outline:
		poly_outline_osm	= poly_union_osm;
	else
		% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		% ToDo:
		% Statt Abbruch sollte hier der gegebenen Umriss poly_outline_map mit einem Flachdach verwendet werden !!!!!!!!!
		% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		id_str			= '';
		for i_iw_v=1:size(iw_v,1)
			iw				= iw_v(i_iw_v,1);
			id_str		= sprintf('%sway: ID=%1.0f\n',id_str,OSMDATA.id.way(1,iw));
		end
		for i_ir_v=1:size(ir_v,1)
			ir				= ir_v(i_ir_v,1);
			id_str		= sprintf('%srelation: ID=%1.0f\n',id_str,OSMDATA.id.relation(1,ir));
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

% Testing:
if nargin==0
	% Der Grundriss kann von anderen Kartenobjekten beschnitten sein:
	% testweise Linie durch die Mitte des Grundrisses erzeugen:
	[x,y]				= centroid(poly_outline_osm);		% Grundriss Mitte
	x_line			= [x x+1000];
	y_line			= [y y     ];
	liwi				= 3;									% LineWidth
	% Die Linie vom Grundriss subtrahieren:
	% (Den Fall, dass ein Grundriss aus zwei Hälften besteht, wird es nicht geben.)
	poly_line			= line2poly(x_line,y_line,liwi);
	poly_outline_map	= subtract(poly_outline_osm,poly_line);
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
	title(ax1,'poly_outline_map (.r) / poly_outline_osm (:k)','Interpreter','none');
end

% Alle Flächen innerhalb des Umrisses poly_outline_map, die keine Dächer sind (Gebäudewand): Initialisierung:
poly_triang		= poly_outline_map;

% Stützstellen für die Berechnung der Höhen durch Interpolation: Gebäudegrundfläche:
ScInt_xyz		= [...
	poly_outline_osm.Vertices(:,1) ...							% gesamter äußerer Gebäudeumriss der OSM-Daten
	poly_outline_osm.Vertices(:,2) ...
	z_ground*ones(size(poly_outline_osm.Vertices,1),1)];
ScInt_xyz		= [ScInt_xyz;...
	poly_outline_map.Vertices(:,1) ...							% evtl. beschnittener äußerer Gebäudeumriss
	poly_outline_map.Vertices(:,2) ...
	z_ground*ones(size(poly_outline_map.Vertices,1),1)];

% Triangulationsdaten:
T								= [];
T.Points						= zeros(0,2);
T.ConnectivityList		= zeros(0,3);


% --------------------------------------------------------------------------------------------------------------------
% Dachflächen identifizieren und Höhe berechnen:
% Bei sich überlappenden Dachflächen muss die Dachfläche mit der größeren Höhe von einer niedrigeren Dachfläche
% subtrahiert werden. Daher müssen zunächst nur die Höhen der Dachflächen bestimmt werden.

% Ergebnis:
%		ways.isroof(kw,1)							the way represents a roof (true/false)
%		ways.roof_shape{kw,1}					roof shape
%		ways.building_levels(kw,1)				number of floors
%		ways.height(kw,1)							total height from ground level to roof peak in mm
%		ways.roof_height(kw,1)					roof height in mm
%		ways.poly_outline_osm_roof(kw,1)		complete roof outline based on OSM data
ways.isroof				= false(size(ways.iw));
ways.roof_shape		= cell(size(ways.iw));
ways.building_levels	= zeros(size(ways.iw));
ways.height				= zeros(size(ways.iw));
ways.roof_height		= zeros(size(ways.iw));
for kw=1:size(ways.iw,1)
	ways.poly_outline_osm_roof(kw,1)	= polyshape;
	if ways.isclosed(kw,1)
		iw					= ways.iw(kw,1);
		roof_shape		= get_tag_value_local('way',iw,'roof:shape','string');
		
		% Dies ist nicht die einzige Variante, ein Dach zu erkennen
		% (siehe das schlecht nachgebildete Münchner Rathaus: https://www.openstreetmap.org/way/223907278)
		% Evtl. schon hier alle möglichen keys zur Struktur ways hinzufügen
		% (dafür nicht mehr in get_triangulation_roof_local)
		% und die Fläche bei Vorhandensein der benötigten Informationen als Dach kennzeichnen.
		% Ideen wie Höhen berechnet werden können:
		% https://wiki.openstreetmap.org/wiki/ProposedRoofLines#Measuring_heights
		roof_colour		= get_tag_value_local('way',iw,'roof:colour','string');
		% Der ganze Gebäudegrundriss muss durch Dächer abgedeckt sein, bis auf schmale Spalte: Sicherheitsabfrage
		
		if ~isempty(roof_shape)||~isempty(roof_colour)
			% The tag 'roof:shape' exists: The way represents a roof.
			ways.isroof(kw,1)	= true;
			[  ways...								% ways  stucture
				]=get_height_roof_local(...
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


% --------------------------------------------------------------------------------------------------------------------
% - Sich überlappende Dachflächen gegenseitig beschneiden, so dass nur die jeweils höheren Dachflächen übrig bleiben:
%   Beginne mit dem höchsten Dach kw1=kw_sort_v(1,1), subtrahiere es von allen anderen niedrigeren Dächern, usw.
% - Zusätzlich die Dachflächen auf den gegebenen Gebäudeumriss poly_outline_map beschneiden.
% Ergebnis:
%		ways.poly_outline_map_roof(kw,1)		Actual roof outline

ways.poly_outline_map_roof		= ways.poly_outline_osm_roof;
for kw=1:size(ways.iw,1)
	ways.poly_outline_map_roof(kw,1)	= intersect(...
		ways.poly_outline_map_roof(kw,1),...
		poly_outline_map                     );
end
[~,kw_sort_v]		= sort(ways.height,'descend');
for ikw1=1:(size(kw_sort_v,1)-1)
	kw1	= kw_sort_v(ikw1,1);
	if ways.isroof(kw1,1)
		for ikw2=(ikw1+1):size(kw_sort_v,1)
			kw2	= kw_sort_v(ikw2,1);
			if ways.isroof(kw2,1)
				ways.poly_outline_map_roof(kw2,1)	= subtract(...
					ways.poly_outline_map_roof(kw2,1),...
					ways.poly_outline_osm_roof(kw1,1)    );
			end
		end
	end
end
if testplot
	% Anzeige der Struktur ways im Command Window:
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
		'poly_outline_map_roof'};		% actual roof outline
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

% --------------------------------------------------------------------------------------------------------------------
% Triangulationsdaten der Dachflächen berechnen

for kw=1:size(ways.iw,1)
	ways.poly_outline_map_roof_red(kw,1)	= polyshape;
	if ways.isroof(kw,1)
		
		% Actual roof outline, reduced by the gap triangulation_gapsize to create the wall:
		ways.poly_outline_map_roof(kw,1)		= polybuffer(...
			ways.poly_outline_map_roof(kw,1),-triangulation_gapsize,'JointType','miter');

		% Verbleibende Fläche innerhalb des Gebäudeumrisses ohne die Dächer (gleich der Gebäudewand):
		poly_triang	= subtract(poly_triang,ways.poly_outline_map_roof(kw,1));

		% Triangulatiosdaten des Dachs berechnen:
		iw		= ways.iw(kw,1);
		[  T_roof,...							% Triangulationsdaten des Dachs
			z_outline_map_roof...			% z-Werte auf den Punkten von poly_outline_map_roof (Höhenverlauf des Dachumriss)
			]=get_triangulation_roof_local(...
			pp,...								% Projektparameter
			par,...								% weitere Parameter
			iw,...								% OSM-Daten: Index iw in OSMDATA.way(1,iw)
			ways,...								% ways  stucture
			triangulation_gapsize,...		% Breite des Spalts zwischen Dachflächen unterschiedlicher Höhe (Wand)
			ax1,...								% Achsenobjekt für Testplots
			testplot);							% Anzeige von Testplots (true/false)

		% Triangulationsdaten erweitern:
		% Die Punkte T_roof.Points werden an das Ende von T.Points angehängt und haben dann einen höheren Index.
		% Die Indices dieser Punkte in der connectivity list müssen entsprechend erhöht werden:
		size_T_P					= size(T.Points,1);
		% Triangulationsdaten zusammensetzen:
		T.Points					= [T.Points          ;T_roof.Points                   ];
		T.ConnectivityList	= [T.ConnectivityList;T_roof.ConnectivityList+size_T_P];

		% Stützstellen für die Interpolation der Höhenwerte der Gebäudewand erweitern:
		ScInt_xyz		= [ScInt_xyz;...
			ways.poly_outline_map_roof(kw,1).Vertices(:,1) ...							% äußerer Dachumriss
			ways.poly_outline_map_roof(kw,1).Vertices(:,2) ...
			z_outline_map_roof];
		
	end
end

% --------------------------------------------------------------------------------------------------------------------
% Triangulation der übrigen Flächen innerhalb des Gebäudeumrisses, die zu keinem Dach gehören (die Gebäudewand):

% Sicherheitsabfrage: Innerhalb des Gebäudeumrisses darf es keine leeren Teilflächen mehr geben:
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
		display_warning_local(sprintf([...
			'The area within the building outline has not been calculated completely.\n',...
			'area_poly_outline = %g mm^2\n',...
			'area_poly_inner   = %g mm^2\n',...
			'difference        = %g mm^2'],...
			area_poly_outline,area_poly_inner,area_poly_outline-area_poly_inner),[],[]);
	end
end

% poly_triang darstellen: Innerhalb des Gebäudeumrisses darf es keine leeren Teilflächen mehr geben:
if testplot
	plot(ax1,poly_triang,'FaceAlpha',0.1);
	plot(ax1,poly_triang.Vertices(:,1),poly_triang.Vertices(:,2),'.k','MarkerSize',10);
end

% Die Stützstellen können nan enthalten, verursacht von Löchern in Polygonen: löschen:
ScInt_xyz(isnan(ScInt_xyz(:,1)),:)	= [];

% Die z-Werte von doppelten xy-Stützstellen in ScInt_xyz mitteln (deren z-Werte sollten identisch sein) und
% doppelte Stützstellen löschen:
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
	% T_i ist read-only: neu zuweisen:
	T_i_P						= T_i.Points;
	T_i_CL					= T_i.ConnectivityList;
	% Die z-Werte (Höhen) durch Interpolation berechnen und als 3. Spalte T_i_P hinzufügen:
	T_i_P		= [T_i_P ScInt(T_i_P(:,1),T_i_P(:,2))];
	% Die Punkte T_P werden an das Ende von T.Points angehängt und haben dann einen höheren Index.
	% Die Indices dieser Punkte in der connectivity list müssen entsprechend erhöht werden:
	size_T_P					= size(T.Points,1);
	% Triangulationsdaten zusammensetzen:
	T.Points					= [T.Points          ;T_i_P ];
	T.ConnectivityList	= [T.ConnectivityList;T_i_CL+size_T_P];
end

% Vereinfachung der Triangulationsdaten mit triangulation_simplify:
% p						Points, specified as a matrix whose columns are the x-coordinates, y-coordinates,
%							and z-coordinates of the triangulation points.
%							The row numbers of P are the vertex IDs in the triangulation.
% cl						Triangulation connectivity list, specified as an m-by-3 matrix, where m is the
%							number of triangles.
%							Each row of T contains the vertex IDs that define a triangle or tetrahedron.
%							The vertex IDs are the row numbers of the input points.
%							The ID of a triangle in the triangulation is the corresponding row number in cl.
% tol_tp					Minimum distance between two points.
%							If two points have a smaller distance than tol_tp, they are merged.
% testplot_xlimits	x- and y-limits of the test plots. Default: []
% testplot_ylimits	The testplot is shown, if the mean value of the points to be merged is within the limits.
% msg						message string for the waitbar
T		= triangulation_simplify(...
	T.Points,...							% p
	T.ConnectivityList,...				% cl
	triangulation_tol_tp,...			% tol_tp
	[],...									% testplot_xlimits
	[],...									% testplot_ylimits
	'');										% msg

% 3D Darstellung des Ergebnisses:
if testplot
	if ~isempty(T.ConnectivityList)
		F=[T.ConnectivityList(:,1) ...
			T.ConnectivityList(:,2) ...
			T.ConnectivityList(:,3) ...
			T.ConnectivityList(:,1)];
		patch(ax2,'faces',F,'vertices',T.Points,...
			'EdgeColor',[0 0 0],'FaceColor',[1 1 1]*0.95,'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
		plot3(ax2,T.Points(:,1),T.Points(:,2),T.Points(:,3),...
			'LineWidth',0.5,'LineStyle','none','Color','k',...
			'Marker','.','MarkerSize',10);
		view(ax2,3);
	end
end



% ====================================================================================================================
% Unterfunktionen
% ====================================================================================================================



% ====================================================================================================================
function [ways...						% ways  stucture
	]=get_height_roof_local(...
	pp,...								% Projektparameter
	par,...								% weitere Parameter
	iobj,...								% Object number
	iw,...								% OSM-Daten: Index iw in OSMDATA.way(1,iw)
	ways,...								% ways  stucture
	ax1,...								% Achsenobjekt für Testplots
	testplot)							% Anzeige von Testplots (true/false)
% Calculation of:
%		ways.roof_shape{kw,1}					roof shape
%		ways.building_levels(kw,1)				number of floors
%		ways.height(kw,1)							total height from ground level to roof peak in mm
%		ways.roof_height(kw,1)					roof height in mm
%		ways.poly_outline_osm_roof(kw,1)		roof height in mm

% --------------------------------------------------------------------------------------------------------------------
% Tags zuweisen: Für andere Dachformen als roof:shape=pyramidal können noch andere Tags relevant sein.
% List of keys:
% -	https://wiki.openstreetmap.org/wiki/Key:roof:shape
%		roof:shape
%		roof:height
%		roof:levels
%		roof:angle
%		roof:direction
%		roof:orientation
%		roof:colour
%		roof:material
% -	https://wiki.openstreetmap.org/wiki/ProposedRoofLines
%		roof:ridge
%		roof:edge
%		building:eaves:levels
%		building:eaves:height
% -	https://wiki.openstreetmap.org/wiki/Key:building
%		building:architecture
%		building:colour
%		building:flats
%		building:levels
%		building:material
%		building:min_level
%		building:part

% Conversion of OSM tag values into numbers, taking into account the optional specification of units.
% Wenn der Tag nicht existiert, ist die Variable leer ([]).
roof_shape			= get_tag_value_local('way',iw,'roof:shape'     ,'string'   );
height				= get_tag_value_local('way',iw,'height'         ,'distance' )/pp.project.scale*1000;	% m -> mm
building_levels	= get_tag_value_local('way',iw,'building:levels','number'   );
roof_height			= get_tag_value_local('way',iw,'roof:height'    ,'distance' )/pp.project.scale*1000;	% m -> mm
roof_angle			= get_tag_value_local('way',iw,'roof:angle'     ,'angle'    );


% --------------------------------------------------------------------------------------------------------------------
% Berechnung der Dachhöhe:
% See also: https://wiki.openstreetmap.org/wiki/ProposedRoofLines#Measuring_heights

% complete roof outline based on OSM data:
kw								= find(ways.iw==iw,1);
poly_outline_osm_roof	= polyshape(ways.p(kw,1).x,ways.p(kw,1).y);

% Number of floors:
if isempty(building_levels)
	switch iobj
		case pp.buildings.religious_objno
			building_levels	= pp.buildings.religious_levels_def;
		case pp.buildings.castle_objno
			building_levels	= pp.buildings.castle_levels_def;
		otherwise
			building_levels	= pp.buildings.building_levels_def;
	end
end

if isempty(roof_shape)
	roof_shape	= 'flat';
end
switch roof_shape
	% -----------------------------------------------------------------------------------------------------------------
	case 'flat'
	
		roof_height		= 0;
		if isempty(height)
			height			= building_levels*par.floor_height_def+roof_height;
		end
	
	% -----------------------------------------------------------------------------------------------------------------
	case 'pyramidal'
		
		% Zentrum des Dach-Umrisses:
		[roof_center_x,roof_center_y]		= centroid(poly_outline_osm_roof);
		
		% Dach-Umriss mit identischem Anfangs- und Endpunkt:
		[poly_outline_osm_roof_x,poly_outline_osm_roof_y]	= boundary(poly_outline_osm_roof);
		
		% Calculation of roof_height:
		if isempty(roof_height)
			% Mitten der Verbindungslinien zwischen den Ecken:
			xm_v				= (poly_outline_osm_roof_x(2:end)+poly_outline_osm_roof_x(1:(end-1)))/2;
			ym_v				= (poly_outline_osm_roof_y(2:end)+poly_outline_osm_roof_y(1:(end-1)))/2;
			if testplot
				plot(ax1,xm_v,ym_v,'.r')
			end
			% Grundmaß bis First:
			ankathethe		= min(sqrt(...
				(xm_v-roof_center_x).^2+...
				(ym_v-roof_center_y).^2)   );
			if ~isempty(roof_angle)
				roof_height		= ankathethe*tan(roof_angle*pi/180);
			elseif ~isempty(height)
				roof_height		= height-building_levels*par.floor_height_def;
			else
				roof_angle		= pp.buildings.roof_angle_def_deg;
				roof_height		= ankathethe*tan(roof_angle*pi/180);
			end
		end
		
		% Calculation of height:
		if isempty(height)
			height		= building_levels*par.floor_height_def+roof_height;
		end
		
		% --------------------------------------------------------------------------------------------------------------
	otherwise
		% Die Dachform ist nicht implementiert:
		
		% Warnung ausgeben:
		if ~isdeployed
			% Ausführung innerhalb der Entwicklungsumgebung MATLAB:
			display_warning_local(sprintf('get_height_roof_local: roof_shape=%s is not implemented',roof_shape),'way',iw);
		end
		
		% Flachdach mit Standardwerten:
		roof_height		= 0;
		height			= building_levels*par.floor_height_def+roof_height;
		if testplot
			height		= height*(1+0.2*(rand));
		end
		
end

ways.roof_shape{kw,1}				= roof_shape;
ways.building_levels(kw,1)			= building_levels;
ways.height(kw,1)						= height;
ways.roof_height(kw,1)				= roof_height;
ways.poly_outline_osm_roof(kw,1)	= poly_outline_osm_roof;



% ====================================================================================================================
function [T_roof,...					% Triangulationsdaten des Dachs
	z_outline_map_roof...			% z-Werte auf den Punkten von poly_outline_map_roof (Höhenverlauf des Dachumriss)
	]=get_triangulation_roof_local(...
	pp,...								% Projektparameter
	par,...								% weitere Parameter
	iw,...								% OSM-Daten: Index iw in OSMDATA.way(1,iw)
	ways,...								% ways  stucture
	triangulation_gapsize,...		% Breite des Spalts zwischen Dachflächen unterschiedlicher Höhe (Wand)
	ax1,...								% Achsenobjekt für Testplots
	testplot)							% Anzeige von Testplots (true/false)
% Triangulationsdaten von Dächern berechnen

% --------------------------------------------------------------------------------------------------------------------
% Initializations:
kw								= find(ways.iw==iw,1);
roof_shape					= ways.roof_shape{kw,1};					% roof shape
height						= ways.height(kw,1);							% total height from ground level to roof peak in mm
roof_height					= ways.roof_height(kw,1);					% roof height in mm
poly_outline_osm_roof	= ways.poly_outline_osm_roof(kw,1);		% complete roof outline based on OSM data
poly_outline_map_roof	= ways.poly_outline_map_roof(kw,1);		% actual roof outline

% neu zu implementieren zum Beispiel:
% roof_direction		= get_tag_value_local('way',iw,'roof:direction' ,'direction');
% https://wiki.openstreetmap.org/wiki/DE:Key:roof:direction?uselang=de
% Der Wert soll als angenährte Himmelsrichtung (N, S, NW, ESE), oder als eine angenäherte Gradangabe
% zwischen 0 - 360 erfasst werden.

% --------------------------------------------------------------------------------------------------------------------
% Triangulation des Dachs vorbereiten:
% Ergebnisse:
% -	poly_triang_roof	alle Polygone, innerhalb derer trianguliert werden soll
% -	ScInt_xyz_roof		xyz-Stützstellen, um mit der Funktion scatteredInterpolant den Punkten der Polygone
%								Höhenwerte zuzuweisen. In ScInt_xyz_roof müssen nur Stützstellen innerhalb und entlang des
%								Dach-Umrisses poly_outline_map_roof enthalten sein.
switch roof_shape
	% -----------------------------------------------------------------------------------------------------------------
	case 'pyramidal'
		
		% Zentrum des Dach-Umrisses:
		[roof_center_x,roof_center_y]		= centroid(poly_outline_osm_roof);
		
		% Dach-Umriss mit identischem Anfangs- und Endpunkt:
		[poly_outline_osm_roof_x,poly_outline_osm_roof_y]	= boundary(poly_outline_osm_roof);
		
		% Ausgehend vom unveränderten OSM-Dachgrundriss poly_outline_osm_roof die Dach-Teilflächen poly_roof berechnen:
		poly_roof		= polyshape;			% Dach-Teilflächen
		for i=1:(size(poly_outline_osm_roof_x,1)-1)
			poly_roof(i,1)	= polyshape(...
				[poly_outline_osm_roof_x(i,1) poly_outline_osm_roof_x(i+1,1) roof_center_x],...
				[poly_outline_osm_roof_y(i,1) poly_outline_osm_roof_y(i+1,1) roof_center_y]);
		end
		
		% Alle anhand der OSM-Daten bestimmten Dach-Teilflächen auf den gegebenen Dach-Umriss beschneiden:
		for i=1:size(poly_roof,1)
			poly_roof(i,1)		= intersect(poly_roof(i,1),poly_outline_map_roof);
		end
		
		% Die Teilflächen um einen schmalen Spalt verkleinern, falls sich dazwischen eine senkrechte Wand
		% befinden sollte:
		% Das ist selbst dann nötig, wenn das Dach eingentlich keine senkrechten Flächen hat, zum Beispiel bei
		% roof_shape='pyramidal'. Wenn der Gebäudeumriss von anderen Kartenobjekten beschnitten wird, könnten
		% ansonsten an diesen Stellen Löcher in den Triangulationsdaten des Dachs entstehen.
		poly_gap_roof		= poly_outline_map_roof;
		for i=1:size(poly_roof,1)
			poly_roof(i,1)		= polybuffer(poly_roof(i,1),-triangulation_gapsize,'JointType','miter');
			poly_gap_roof		= subtract(poly_gap_roof,poly_roof(i,1));
		end
		
		% Der Flächeninhalt muss jew. >0 sein:
		i_delete		= false(size(poly_roof));
		for i=1:size(poly_roof,1)
			if numboundaries(poly_roof(i,1))==0
				i_delete(i,1)		= true;
			end
		end
		poly_roof(i_delete,:)	= [];
		
		% Alle zu interpolierenden Polygone in poly_triang_roof zusammenstellen:
		poly_triang_roof					= poly_roof;
		poly_triang_roof(end+1,1)		= poly_gap_roof;
		
		% Stützstellen für die Berechnung der Höhen durch Interpolation:
		% auf dem Umriss poly_outline_osm_roof:
		ScInt_xyz_roof		= [...
			poly_outline_osm_roof.Vertices(:,1) ...
			poly_outline_osm_roof.Vertices(:,2) ...
			(height-roof_height)*ones(size(poly_outline_osm_roof.Vertices,1),1)];
		% innerhalb von poly_outline_osm_roof:
		ScInt_xyz_roof		= [ScInt_xyz_roof;...
			roof_center_x ...
			roof_center_y ...
			height];
		
		% --------------------------------------------------------------------------------------------------------------
	otherwise
		% Die Dachform ist nicht implementiert:
		
		% Warnung ausgeben:
		if ~isdeployed
			% Ausführung innerhalb der Entwicklungsumgebung MATLAB:
			display_warning_local(sprintf('roof_shape=%s is not implemented',roof_shape),'way',iw);
		end
		
		% Flachdach mit Standardwerten:
		
		% Alle zu interpolierenden Polygone in poly_triang_roof zusammenstellen:
		poly_triang_roof					= poly_outline_map_roof;
		
		% Stützstellen für die Berechnung der Höhen durch Interpolation:
		% auf dem Umriss poly_outline_osm_roof:
		ScInt_xyz_roof		= [...
			poly_outline_osm_roof.Vertices(:,1) ...
			poly_outline_osm_roof.Vertices(:,2) ...
			height*ones(size(poly_outline_osm_roof.Vertices,1),1)];
		
end

% --------------------------------------------------------------------------------------------------------------------
% Triangulation des Dachs:

% scatteredInterpolant für die Interpolation der Dachhöhe berechnen:
ScInt			= scatteredInterpolant(ScInt_xyz_roof(:,1),ScInt_xyz_roof(:,2),ScInt_xyz_roof(:,3));
ScInt.Method					= 'linear';
ScInt.ExtrapolationMethod	= 'linear';

% Triangulationsdaten des Dachs erzeugen:
T_roof								= [];
T_roof.Points						= zeros(0,2);
T_roof.ConnectivityList			= zeros(0,3);
for i=1:size(poly_triang_roof,1)
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

% z-Werte auf den Punkten von poly_outline_map_roof (Höhenverlauf des Dachumrisses):
z_outline_map_roof	= ScInt(poly_outline_map_roof.Vertices(:,1),poly_outline_map_roof.Vertices(:,2));

% Sicherheitsabfrage: Innerhalb des Dachumrisses darf es keine leeren Teilflächen mehr geben:
if ~isdeployed
	% Ausführung innerhalb der Entwicklungsumgebung MATLAB:
	area_poly_outline		= area(poly_outline_map_roof);
	area_poly_triang		= 0;
	for i=1:size(poly_triang_roof,1)
		area_poly_triang	= area_poly_triang+area(poly_triang_roof(i,1));
	end
	if abs(area_poly_outline-area_poly_triang)>1e-8
		% Warnung ausgeben:
		display_warning_local(sprintf([...
			'The area within the roof outline has not been calculated completely.\n',...
			'area_poly_outline = %g mm^2\n',...
			'area_poly_triang  = %g mm^2\n',...
			'difference        = %g mm^2'],...
			area_poly_outline,area_poly_triang,area_poly_outline-area_poly_triang),'way',iw);
	end
end

% poly_triang_roof darstellen: Innerhalb des Gebäudeumrisses darf es keine leeren Teilflächen mehr geben:
if testplot
	for i=1:size(poly_triang_roof,1)
		plot(ax1,poly_triang_roof(i,1),'FaceAlpha',0.1);
		plot(ax1,poly_triang_roof(i,1).Vertices(:,1),poly_triang_roof(i,1).Vertices(:,2),'.k','MarkerSize',10);
	end
end



% ====================================================================================================================
function [poly_outline_osm,...	% Building outline: relation member with role=outline or role=outer
	poly_union_osm,...				% Building outline: all closed ways united
	nodes,...							% nodes stucture including the nodes of the relation
	ways...								% ways  stucture including the ways  of the relation
	]=search_relation_local(...
	inwr,...								% OSM-Data: Index in OSMDATA.way(1,inwr) or OSMDATA.relation(1,inwr)
	type,...								% way/relation
	role,...								% role of a relation member (inner, outer, ...)
	poly_outline_osm,...				% Building outline: relation member with role=outline or role=outer
	poly_union_osm,...				% Building outline: all closed ways united
	nodes,...							% nodes stucture
	ways,...								% ways  stucture
	testplot,...						% Test outputs (true/false)
	ax1)									% Axis for testplots
% Auslesen der Daten einer relation

global OSMDATA GV

switch type
	case 'node'
		kn		= find(inwr==nodes.in,1);
		if isempty(kn)
			kn						= size(nodes.in,1)+1;
			in						= inwr;
			nodes.in(kn,1)		= in;
			nodes.x(kn,1)		= OSMDATA.node_x_mm(1,in);
			nodes.y(kn,1)		= OSMDATA.node_y_mm(1,in);
			if testplot
				testplot_nwr('node',in,nodes.x(kn,1),nodes.y(kn,1),ax1);
			end
		end
	case 'way'
		kw		= find(inwr==ways.iw,1);
		if isempty(kw)
			kw						= size(ways.iw,1)+1;
			iw						= inwr;
			ways.iw(kw,1)		= iw;
			ways.id(kw,1)		= OSMDATA.id.way(1,iw);
			ways.p(kw,1).x		= OSMDATA.way(1,iw).x_mm(:);
			ways.p(kw,1).y		= OSMDATA.way(1,iw).y_mm(:);
			if    (abs(ways.p(kw,1).x(1,1)-ways.p(kw,1).x(end,1))<GV.tol_1)&&...
					(abs(ways.p(kw,1).y(1,1)-ways.p(kw,1).y(end,1))<GV.tol_1)
				ways.isclosed(kw,1)	= true;
				if strcmp(role,'outline')||strcmp(role,'outer')
					poly_outline_osm	= union(poly_outline_osm,polyshape(ways.p(kw,1).x,ways.p(kw,1).y));
				end
			else
				ways.isclosed(kw,1)	= false;
			end
			if testplot
				testplot_nwr('way',iw,ways.p(kw,1).x,ways.p(kw,1).y,ax1);
			end
		end
	case 'relation'
		irm_max		= size(OSMDATA.relation(1,inwr).member,2);
		% Get the data of the relation members:
		for irm=1:irm_max
			role_next	= OSMDATA.relation(1,inwr).member(1,irm).role;
			id_next		= OSMDATA.relation(1,inwr).member(1,irm).ref;
			type_next	= OSMDATA.relation(1,inwr).member(1,irm).type;
			inwr_next	= find(OSMDATA.id.(type_next)==id_next,1);
			if testplot
				fprintf(1,'Member %g/%g:\n',irm,irm_max);
			end
			% It is possible that not all objects are included in the current map section:
			if ~isempty(inwr_next)
				[  poly_outline_osm,...				% Building outline: relation member with role=outline or role=outer
					poly_union_osm,...				% Building outline: all closed ways united
					nodes,...							% nodes stucture including the nodes of the relation
					ways...								% ways  stucture including the ways  of the relation
					]=search_relation_local(...
					inwr_next,...						% OSM-Data: Index in OSMDATA.way(1,inwr) or OSMDATA.relation(1,inwr)
					type_next,...						% way/relation
					role_next,...						% role of a relation member (inner, outer, ...)
					poly_outline_osm,...				% Building outline: relation member with role=outline or role=outer
					poly_union_osm,...				% Building outline: all closed ways united
					nodes,...							% nodes stucture
					ways,...								% ways  stucture
					testplot,...						% Test outputs (true/false)
					ax1);									% Axis for testplots
			end
		end
end



% ====================================================================================================================
function display_warning_local(warntext,type,inwr)
% Display of a warning in the Command Window
global OSMDATA
fprintf(1,'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
fprintf(1,'%s\n',warntext);
if ~isempty(type)&&~isempty(inwr)
	fprintf(1,'ID:   OSMDATA.id.%s(1,%g)=%1.0f\n',type,inwr,OSMDATA.id.(type)(1,inwr));
	for it=1:size(OSMDATA.(type)(1,inwr).tag,2)
		if it==1
			fprintf(1,'Tags: ');
		else
			fprintf(1,'      ');
		end
		fprintf(1,'%s = %s\n',OSMDATA.(type)(1,inwr).tag(1,it).k,OSMDATA.(type)(1,inwr).tag(1,it).v);
	end
end
fprintf(1,'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');



% ====================================================================================================================
function value	= get_tag_value_local(type,inwr,key,format)
% Conversion of OSM tag values into numbers, taking into account the optional specification of units.
%
% format=number		Number without the possible specification of a unit
% format=distance		Number with the possible specification of a unit of length
% format=angle			Number with the possible specification of the unit degrees
% format=string		No change

global OSMDATA
value		= [];				% Default output if the value could not be converted to a number.
if ~ismissing(OSMDATA.(type)(1,inwr).tag(1,1))
	for it=1:size(OSMDATA.(type)(1,inwr).tag,2)
		if strcmp(OSMDATA.(type)(1,inwr).tag(1,it).k,key)
			value				= OSMDATA.(type)(1,inwr).tag(1,it).v;
			switch format
				case 'number'
					% Number without the possible specification of a unit:
					value		= valstr2valnum_local(value);
					if isnan(value)
						value				= [];
					end
				case 'distance'
					% Number with the possible specification of a unit of length:
					k_m		= find(value=='m');
					k_mm		= strfind(value,'mm');
					k_feet	= find(value==convertStringsToChars("'"));
					k_inches	= find(value=='"');
					if isscalar(k_m)											% '1.2345m' or '1.2345 m'
						% Specifying the unit m is optional:
						value(k_m)		= '';
						value					= valstr2valnum_local(value);
					elseif isscalar(k_mm)									% '1234.5mm' or '1234.5 mm'
						% Specifying the unit mm is optional:
						value(k_m)		= '';
						value				= valstr2valnum_local(value)/1000;
					elseif isscalar(k_feet)||isscalar(k_inches)		% 7'4" (7 feet and 4 inches)
						if isscalar(k_feet)
							feet		= str2double(value(1:(k_feet-1)));
							value		= value((k_feet+1):end);
						else
							feet		= 0;
						end
						k_inches	= find(value=='"');
						if isscalar(k_inches)
							inches	= str2double(value(1:(k_inches-1)));
						else
							inches	= 0;
						end
						value			= 0.3048*feet+0.0254*inches;
					else
						value			= valstr2valnum_local(value);
					end
					if isnan(value)
						value				= [];
					end
				case 'angle'
					% Number with the possible specification of the unit degrees:
					k_deg		= find(value=='°');
					if isscalar(k_deg)											% '1.2345°' or '1.2345 °'
						% Specifying the unit ° is optional:
						value(k_deg)		= '';
						value					= valstr2valnum_local(value);
					else
						value					= valstr2valnum_local(value);
					end
					if isnan(value)
						value				= [];
					end
				case 'string'
					% no change
			end
		end
	end
end



% ====================================================================================================================
function value=valstr2valnum_local(value)
% Handling incorrect comma usage:
k_c		= find(value==',');
k_p		= find(value=='.');
l_c		= length(k_c);
l_p		= length(k_p);
if (l_c==1)&&(l_p==0)									% 123,456
	% Incorrect use of ',' is more likely than use as a thousands separator:
	value(k_c)				= '.';
elseif (l_c==1)&&(l_p>=1)&&(k_c>max(k_p))			% 1.234.567,89
	% Delete the thousands separators and replace the comma:
	value(k_p)				= '';
	value(value==',')		= '.';
elseif (l_p==1)&&(l_c>=1)&&(k_p>max(k_c))			% 1,234,567.89
	% Delete the thousands separators:
	value(k_c)				= '';
end
value			= str2double(value);



% ====================================================================================================================
function testplot_nwr(type,inwr,x,y,ax1)
% Display tags in the command window and plot the xy data in the axis ax1.

global GV

x		= x(:);
y		= y(:);

[tags_full_str,tags_str]	= get_tags_str(type,inwr);
fprintf(1,'%s',tags_full_str);

if size(x,1)==1
	% node:
	plot(ax1,x,y,'.r','MarkerSize',20);
elseif (abs(x(1,1)-x(end,1))<GV.tol_1)&&...
		( abs(y(1,1)-y(end,1))<GV.tol_1)
	% closed way:
	poly_way	= polyshape(x,y);
	plot(ax1,poly_way,'FaceAlpha',0,'EdgeColor','r');
	plot(ax1,poly_way.Vertices(:,1),poly_way.Vertices(:,2),'.r','MarkerSize',10);
else
	% open way:
	plot(ax1,x(:,1),y(:,1),'.-r','MarkerSize',10);
end
title(ax1,tags_str,'Interpreter','none');
pause(0.01);
setbreakpoint	= 1;					% Set breakpoint here in order to see every single way of the relation.
for ic=1:size(ax1.Children,1)
	if strcmp(ax1.Children(ic,1).Type,'polygon')
		ax1.Children(ic,1).EdgeColor	= [1 1 1]*0.8;
	elseif strcmp(ax1.Children(ic,1).Type,'line')
		ax1.Children(ic,1).Color	= [1 1 1]*0.8;
	end
end



% ====================================================================================================================
function [tags_full_str,tags_str]=get_tags_str(type,inwr)
% Get the tags of an OSM map feature as character array

global OSMDATA

tags_str			= '';
tags_full_str	= sprintf('ID:   OSMDATA.id.%s(1,%g)=%1.0f\n',type,inwr,OSMDATA.id.(type)(1,inwr));
if ~ismissing(OSMDATA.(type)(1,inwr).tag(1,1))
	for it=1:size(OSMDATA.(type)(1,inwr).tag,2)
		tags_full_str	= sprintf('%s      %s = %s\n',tags_full_str,...
			OSMDATA.(type)(1,inwr).tag(1,it).k,OSMDATA.(type)(1,inwr).tag(1,it).v);
		if it==15
			tags_str		= sprintf('%s...',tags_full_str);
		end
	end
else
	tags_full_str	= sprintf('%s      no tags\n',tags_full_str);
end
if isempty(tags_str)
	tags_str		= tags_full_str;
end


