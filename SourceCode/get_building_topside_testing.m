function get_building_topside_testing
% Testweise Berechnung von Übergabewerten
% pp
% iobj
% in_v
% iw_v
% ir_v
% poly_outline_map
% z_ground
% testing
% testplot
% export_stl
% und Aufruf von get_building_topside

global PP OSMDATA

% Spalte zwischen den Dachflächen (=Wandflächen von oben betrachtet) testweise verbreitern (true/false)
testing				= false;

% Ausgabe von Textplots (true/false)
testplot				= true;

% Ausgabe einer stl-Datei des Gebäudes im Projektverzeichnis (true/false)
export_stl			= true;

% Der Gebäude-Grundriss kann von anderen Kartenobjekten beschnitten sein, z. B. wenn eine Straße mit 
% höherer Priorität neben dem Gebäude verläuft. Dies kann hier simuliert werden, indem eine Linie durch die Mitte
% des Grundrisses gelegt und vom Grundriss subtrahiert wird (true/false)
trim_base_area		= false;
poly_outline_map	= trim_base_area;

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


% Spaltenvektoren: 0 Zeilen, 1 Spalte, Datentyp double
id_n_v = zeros(0,1);	% ID von nodes aus OSM
id_w_v = zeros(0,1);	% ID von ways aus OSM
id_r_v = zeros(0,1);	% ID von relations aus OSM

testnr = 2;

switch testnr
	
	case 2
		% Muenchen_Frauenkirche.osm
		% https://www.openstreetmap.org/relation/2181619
		id_r_v(end+1,1) = 2181619;
		
		
	case 5
		% Muenchen_Rathaus.osm
		% https://www.openstreetmap.org/way/80965578
		id_w_v(end+1,1) = 80965578;
		
	case 7
		% Satteldach von Frauenkirche münchen
		id_w_v(end+1,1) = 222512593;
		id_w_v(end+1,1) = 209452771;
		id_w_v(end+1,1) = 209452775;
		id_w_v(end+1,1) = 209452811;
		id_w_v(end+1,1) = 222512598;
		id_w_v(end+1,1) = 362612278;
		id_w_v(end+1,1) = 362612279;
		id_w_v(end+1,1) = 362612280;
		
	case 8
		% Pultdach von Frauenkirche Ostseite außen
		id_w_v(end+1,1) = 108429818;
		
	case 9
		% Schräges Satteldach mit Ridge Erzeugung
		id_w_v(end+1,1) = 80965581;
		
		% case 10 %keine Datei vorhanden
		% 	% Weiteres Beispiel eines Satteldachs
		% 	id_w_v(end+1,1) = 80965633;
		
	case 11
		% Beispiel eines Pyramidendachs
		id_w_v(end+1,1) = 242367319;
		
	case 12
		% Pultdach der Frauenkirche zwischen den beiden Türmen
		id_w_v(end+1,1) = 222512597;
		id_w_v(end+1,1) = 209452724;
		
	case 13
		% Beispiel Kirche Mannheim Marktplatz St. Sebastian
		id_w_v(end+1,1) =1161522614;
		id_w_v(end+1,1) =1161522606;
		id_w_v(end+1,1) =1161522607;
		id_w_v(end+1,1) =1161522608;
		id_w_v(end+1,1) =1161522609;
		id_w_v(end+1,1) =1161522610;
		id_w_v(end+1,1) =1161522611;
		id_w_v(end+1,1) =1161522612;
		id_w_v(end+1,1) =1163298945;
		id_w_v(end+1,1) =1163310397;
		id_w_v(end+1,1) =1163310398;
		id_w_v(end+1,1) =1161522606;
		id_w_v(end+1,1) =1163298942;
		id_w_v(end+1,1) =1163298943;
		id_w_v(end+1,1) =1163298944;
		id_w_v(end+1,1) =1163310398;
		id_w_v(end+1,1) =1161522613;
		
		id_w_v=unique(id_w_v);
		
	case 14
		% Kölner Dom
		id_r_v(end+1,1) = 2788226;
		id_w_v(end+1,1) =416846330;
		id_w_v(end+1,1) =416846331;
		id_w_v(end+1,1) =416846332;
		id_w_v(end+1,1) =416846333;
		id_w_v(end+1,1) =416846334;
		id_w_v(end+1,1) =416846335;
		id_w_v(end+1,1) =416846336;
		id_w_v(end+1,1) =416846337;
		id_w_v(end+1,1) =416846338;
		id_w_v(end+1,1) =416846339;
		id_w_v(end+1,1) =416846340;
		id_w_v(end+1,1) =416846342;
		id_w_v(end+1,1) =416846345;
		id_w_v(end+1,1) =416846348;
		id_w_v(end+1,1) =416846351;
		id_w_v(end+1,1) =416846355;
		id_w_v(end+1,1) =416846358;
		id_w_v(end+1,1) =416846360;
		id_w_v(end+1,1) =416846363;
		id_w_v(end+1,1) =416846366;
		id_w_v(end+1,1) =416846369;
		id_w_v(end+1,1) =416846372;
		id_w_v(end+1,1) =416846374;
		id_w_v(end+1,1) =416846377;
		id_w_v(end+1,1) =416846380;
		id_w_v(end+1,1) =416846382;
		id_w_v(end+1,1) =416846385;
		id_w_v(end+1,1) =416846388;
		id_w_v(end+1,1) =416846392;
		id_w_v(end+1,1) =416846395;
		id_w_v(end+1,1) =416846400;
		id_w_v(end+1,1) =416846407;
		id_w_v(end+1,1) =416846415;
		id_w_v(end+1,1) =207377045;
		id_w_v(end+1,1) =416846447;
		id_w_v(end+1,1) =416846429;
		id_w_v(end+1,1) =416846369;
		id_w_v(end+1,1) =416846388;
		id_w_v(end+1,1) =416846330;
		id_w_v(end+1,1) =416846332;
		id_w_v(end+1,1) =416846337;
		id_w_v(end+1,1) =416846339;
		id_w_v(end+1,1) =416846340;
		id_w_v(end+1,1) =416846345;
		id_w_v(end+1,1) =416846358;
		id_w_v(end+1,1) =416846360;
		
		id_w_v=unique(id_w_v);
		
	case 15
		% Notre Dame
		id_r_v(end+1,1) =6551963;
		
	case 16
		% Beispiel Satteldach mit Ridge Erzeugung
		id_w_v(end+1,1) = 242367318;
end

% Indizes in den OSM-Daten berechnen:
in_v = zeros(size(id_n_v));		% index der liste. das bedeutet an welcher
%												stelle in der Liste die ID im großen
%                                   Datensatz von OSM vorkommt
iw_v = zeros(size(id_w_v));		% ... für ways
ir_v = zeros(size(id_r_v));		% ... für relations

% Für jede ID, die du suchst (id_n_v(i)), wird geschaut
% Wo steht diese ID in der großen Liste OSMDATA.id.node
for i=1:size(id_n_v,1)
	in_v(i,1) = find(OSMDATA.id.node == id_n_v(i,1),1);
end
for i=1:size(id_w_v,1)
	iw_v(i,1) = find(OSMDATA.id.way == id_w_v(i,1),1);
end
for i=1:size(id_r_v,1)
	ir_v(i,1) = find(OSMDATA.id.relation == id_r_v(i,1),1);
end

% Weitere Eingabevariablen:
pp			= PP;
z_ground	=  0;

% Default-Werte:
% Zur Zeit sind die Parameter für Gebäude noch nicht in der
% Projektparameter-Datei enthalten:

% Standardhöhe eines Stockwerks in Meter (s. a. https://wiki.openstreetmap.org/wiki/Key:building:levels#Values)
pp.buildings.floor_height_def_m			= 3;

% Standardwert für Dachneigung in °Grad (s. a. https://de.wikipedia.org/wiki/Dachneigung)
pp.buildings.roof_angle_def_deg			= 30;

% Anzahl der Stockwerke in einem Gebäude
pp.buildings.building_levels_def			= 1;

% Anzahl Stockwerke im religiösen Gebäude
pp.buildings.religious_levels_def		= 3;

% Anzahl Stockwerke in Schlössern
pp.buildings.castle_levels_def			= 3;

% Abstände der Schichten bei Kuppelerzeugung
pp.buildings.dist_between_points			= 0.2;

% Zuweisung von Gebäudetypen ins Paramter iobj
% Welche Nummer in der Liste entspricht welchem Typ?
% pp.buildings.building_objno = 1 heißt:
% Der allgemeine Objekttyp "Building" steht an Position 1 in pp.obj.

for iobj=1:size(pp.obj,1)
	
	if ~isempty(pp.obj(iobj,1).description)
		
		switch pp.obj(iobj,1).description
			
			case 'Building'
				
				% Object number of buildings
				pp.buildings.building_objno	= iobj;
				
			case 'Religious Institution'
				
				% Object number of religious institutions
				pp.buildings.religious_objno	= iobj;
				
			case 'Castle'
				
				% Object number of castles
				pp.buildings.castle_objno		= iobj;
				
		end
	end
end




% Aufruf von get_building_topside:
T = get_building_topside(pp, iobj, in_v, iw_v, ir_v,...
	poly_outline_map, z_ground, testing, testplot, export_stl);

