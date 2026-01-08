function [ways...						% ways  stucture
	] = get_building_topside_get_roofheight(...
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
%		ways.poly_outline_osm_roof(kw,1)		roof outline


%% Tags zuweisen: Für andere Dachformen als roof:shape=pyramidal können
%  noch andere Tags relevant sein.
%  List of keys:

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

% Conversion of OSM tag values into numbers, taking into account the
% optional specification of units.
% Wenn der Tag nicht existiert, ist die Variable leer ([]).

roof_shape			= get_building_topside_get_tag_value('way',iw,...
	'roof:shape','string');

height				= get_building_topside_get_tag_value('way',iw,'height','distance')...
	/pp.project.scale*1000;	% m -> mm

building_levels	= get_building_topside_get_tag_value('way',iw,...
	'building:levels','number');

roof_height			= get_building_topside_get_tag_value('way',iw,'roof:height',...
	'distance')/pp.project.scale*1000;	% m -> mm

roof_angle			= get_building_topside_get_tag_value('way',iw,...
	'roof:angle','angle');


%% Berechnung der Dachhöhe:
% See also:
% https://wiki.openstreetmap.org/wiki/ProposedRoofLines#Measuring_heights

% complete roof outline based on OSM data:
% sucht in der Liste ways.iw, an welcher Stelle dieser Way gespeichert ist.
% Ergebnis ist kw.
kw	= find(ways.iw == iw,1);
poly_outline_osm_roof = polyshape(ways.p(kw,1).x,ways.p(kw,1).y);

% Number of floors. Falls die Anzahl der Stockwerk aus OSM nicht bekannt ist,
% nehmen wir den Standardwert aus pp
if isempty(building_levels)
	
	% Je nach Objekt wird das richtige pp benutzt für das Gebäude
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
	
	%% Höhe Flachdach
	case 'flat'
		
		roof_height = 0;
		
		if isempty(height)
			
			height	= building_levels*par.floor_height_def+roof_height;
			
		end
		
		
		%% Höhe Pyramidendach
	case 'pyramidal'
		
		% Zentrum des Dach-Umrisses:
		[roof_center_x,roof_center_y]	= centroid(poly_outline_osm_roof);
		
		% Dach-Umriss mit identischem Anfangs- und Endpunkt:
		[poly_outline_osm_roof_x,poly_outline_osm_roof_y] = ...
			boundary(poly_outline_osm_roof);
		
		% Calculation of roof_height:
		if isempty(roof_height)
			
			% Mitten der Verbindungslinien zwischen den Ecken:
			xm_v = (poly_outline_osm_roof_x(2:end)...
				+ poly_outline_osm_roof_x(1:(end-1)))/2;
			
			ym_v = (poly_outline_osm_roof_y(2:end)...
				+ poly_outline_osm_roof_y(1:(end-1)))/2;
			
			if testplot
				
				plot(ax1,xm_v,ym_v,'.r')
			end
			
			% Grundmaß bis First:
			
			ankathethe = min(sqrt((xm_v-roof_center_x).^2+(ym_v-roof_center_y).^2));
			
			if ~isempty(roof_angle)
				
				roof_height	= ankathethe*tan(roof_angle*pi/180);
				
			elseif ~isempty(height)
				
				roof_height	= height-building_levels*par.floor_height_def;
				
			else
				
				roof_angle = pp.buildings.roof_angle_def_deg;
				
				roof_height	= ankathethe*tan(roof_angle*pi/180);
				
			end
		end
		
		% Calculation of height:
		if isempty(height)
			
			height = building_levels*par.floor_height_def+roof_height;
			
		end
		
		
		%% Höhe Satteldach
	case 'gabled'
		
		% Dach-Umriss mit identischem Anfangs- und Endpunkt:
		[poly_outline_osm_roof_x,poly_outline_osm_roof_y]	= ...
			boundary(poly_outline_osm_roof);
		
		if isempty(roof_height)
			
			width_x = max(poly_outline_osm_roof_x) - min(poly_outline_osm_roof_x);
			width_y = max(poly_outline_osm_roof_y) - min(poly_outline_osm_roof_y);
			
			roof_base_width = min(width_x, width_y);
			
			if ~isempty(roof_angle)
				
				roof_height= (roof_base_width/2) * tan(roof_angle * pi/180);
				
			elseif ~isempty(height)
				
				roof_height	= height-building_levels*par.floor_height_def;
			else
				
				roof_angle= pp.buildings.roof_angle_def_deg;
				roof_height = (roof_base_width/2) * tan(roof_angle * pi/180);
				
			end
		end
		
		if isempty(height)
			
			height = building_levels*par.floor_height_def+roof_height;
		end
		
		
		%% Höhe Pultdach
	case 'skillion'
		
		% Dach-Umriss mit identischem Anfangs- und Endpunkt:
		[poly_outline_osm_roof_x,poly_outline_osm_roof_y] =...
			boundary(poly_outline_osm_roof);
		
		width_x = max(poly_outline_osm_roof_x) - min(poly_outline_osm_roof_x);
		width_y = max(poly_outline_osm_roof_y) - min(poly_outline_osm_roof_y);
		
		% längere Seite ist die Neigungsrichtung
		roof_base_length = max(width_x, width_y);
		
		if isempty(roof_height)
			
			if  ~isempty(roof_angle)
				
				roof_height = roof_base_length * tan(roof_angle *pi/180);
				
			elseif ~isempty(height)
				
				roof_height = height - building_levels...
					* par.floor_height_def;
				
			else
				
				roof_angle = pp.buildings.roof_angle_def_deg;
				roof_height = roof_base_length * tan(roof_angle *pi/180);
				
			end
		end
		
		if isempty(height)
			
			height = building_levels*par.floor_height_def+roof_height;
			
		end
		
		
		%% Höhe Kuppeldach
	case 'dome'
		
		% Unnötig, weil bei Zeile 1537 roof_height durch r_dome überschrieben wird?
		[poly_outline_osm_roof_x,poly_outline_osm_roof_y]	=...
			boundary(poly_outline_osm_roof);
		
		if isempty(roof_height)
			
			width_x = max(poly_outline_osm_roof_x)...
				- min(poly_outline_osm_roof_x);
			
			width_y = max(poly_outline_osm_roof_y)...
				- min(poly_outline_osm_roof_y);
			
			% Annäherung an runde Basis
			roof_base_diameter = (width_x + width_y) / 2;
			
			roof_height = roof_base_diameter/2;
			
		end
		
		
		%% Alle andere Dachformenhöhen:
	otherwise
		
		% Warnung ausgeben:
		
		if ~isdeployed
			% Ausführung innerhalb der Entwicklungsumgebung MATLAB:
			get_building_topside_display_warning(...
				sprintf('get_building_topside_get_roofheight: roof_shape=%s is not implemented',roof_shape),'way',iw);
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


