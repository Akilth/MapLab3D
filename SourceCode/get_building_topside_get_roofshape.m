function [...
	poly_triang_roof,...			% ix1 polygon vector von Teilflächen des Dachs, innerhalb derer trianguliert werden soll
	ScInt_xyz_roof...				% Nx3 Matrix mit xyz-Werten der Dachform
	]=get_building_topside_get_roofshape(...
	pp,...							% Projektparameter
	par,...							% weitere Parameter
	iw,...							% OSM-Daten: Index iw in OSMDATA.way(1,iw)
	ways,...							% ways  stucture
	triangulation_gapsize,...	% Breite des Spalts zwischen Dachflächen unterschiedlicher Höhe (Wand)
	ax1,...							% Achsenobjekt für Testplots
	ax2,...							% Achsenobjekt für Testplots
	testplot)						% Anzeige von Testplots (true/false)

%% Triangulation des Dachs vorbereiten:
% Ergebnisse:
% -	poly_triang_roof	alle Polygone, innerhalb derer trianguliert werden soll
%								Durch das Aufteilen der Gesamt-Dachfläche in Teilflächen kann erzwungen werden, dass die
%								Kanten der Dreicke bei der Triangulation entlang der Polygonränder in poly_triang_roof
%								verlaufen (das also z. B. der Dachfirst eine Dreieckskante ist).
% -	ScInt_xyz_roof		xyz-Stützstellen, um mit der Funktion scatteredInterpolant den Punkten der Polygone
%								Höhenwerte zuzuweisen. In ScInt_xyz_roof müssen nur Stützstellen innerhalb und entlang des
%								Dach-Umrisses poly_outline_map_roof enthalten sein.

global OSMDATA

%% Initializations:
kw								= find(ways.iw == iw,1);
roof_shape					= ways.roof_shape{kw,1};						% roof shape
height						= ways.height(kw,1);								% total height from ground level to roof peak in mm
roof_height					= ways.roof_height(kw,1);						% roof height in mm
poly_outline_osm_roof	= ways.poly_outline_osm_roof(kw,1);			% complete roof outline based on OSM data
poly_outline_map_roof	= ways.poly_outline_map_roof(kw,1);			% actual roof outline
roof_direction		= get_building_topside_get_tag_value('way',iw,'roof:direction','direction'); % Neigungsrichtung des Dachs
roof_orientation	= get_building_topside_get_tag_value('way',iw,'roof:orientation' ,'string'); % Neigungsrichtung des Dachs

switch roof_shape
	
	% Berechnung von
	% poly_triang_roof(i,1)		von oben betrachtet Ringe
	%									und die oberste Scheibe mit Spitze in der Mitte wie beim Pyramidendach
	% größter Kreis innerhalb von poly_outline_osm_roof:
	% - kleine Toleranz abziehen, z. B. 1e-6
	
	
	%% Triangulation Kuppeldach
	case 'dome'
		
		% Zentrum des Dach-Umrisses
		[roof_center_x, roof_center_y] = centroid(poly_outline_osm_roof);
		
		% größter Innenkreis als Referenzradius
		r_dome = mindistance_poly_p(poly_outline_osm_roof.Vertices(:,1), ...
			poly_outline_osm_roof.Vertices(:,2), ...
			roof_center_x, roof_center_y);
		
		% Höhe der Kuppel (Fallback: Radius = Höhe) % oder ist das unnötig?
		if isempty(roof_height)
			roof_height = r_dome;
		end
		
		% Anzahl der Schichten (mind. 2)
		no_layer = max(2, ceil(roof_height ...
			/ pp.buildings.dist_between_points));
		
		% Höhenwerte von Basis bis Spitze
		z_vals = linspace(height - roof_height, height, no_layer);
		
		% Radien relativ zur Basis berechnen (Halbkugel-Formel)
		r_vals = sqrt(max(0, r_dome.^2 - (z_vals - (height...
			- roof_height)).^2));
		
		% Arrays vorbereiten
		poly_layeroutline = repmat(polyshape, no_layer, 1);
		z_layeroutline    = zeros(no_layer,1);
		
		% Basis = Gebäudepolygon
		poly_layeroutline(1,1) = poly_outline_osm_roof;
		z_layeroutline(1,1)    = z_vals(1);
		
		% Abgeleitete Polygone durch Skalieren des Grundrisses
		V = poly_outline_osm_roof.Vertices; % Original-Umriss
		
		for i_layer = 2:no_layer
			
			ri = r_vals(i_layer);
			
			if ri <= 0 || ~isfinite(ri)
				
				poly_layeroutline(i_layer,1) = polyshape(); % leer
				z_layeroutline(i_layer,1)    = z_vals(i_layer);
				continue;
				
			end
			
			% Skalierungsfaktor (aktueller Radius / Basisradius)
			scale_factor = ri / r_dome;
			
			% Alle Punkte skalieren in Richtung des Mittelpunkts
			px = roof_center_x + (V(:,1) - roof_center_x) * scale_factor;
			py = roof_center_y + (V(:,2) - roof_center_y) * scale_factor;
			
			% Polyshape speichern
			poly_layeroutline(i_layer,1) = polyshape(px, py);
			z_layeroutline(i_layer,1)    = z_vals(i_layer);
			
		end
		
		% Dach-Teilflächen (Ringe zwischen Schichten)
		poly_roof = polyshape;
		
		for i_layer = 1:(no_layer-1)
			
			% Prüfen ob beide Polygone gültig sind (haben einen Umriss)
			if (numboundaries(poly_layeroutline(i_layer)) > 0) && ...
					(numboundaries(poly_layeroutline(i_layer+1)) > 0)
				
				% Wenn beide gültig sind → Dachring erzeugen
				poly_roof(i_layer,1) = addboundary( ...
					poly_layeroutline(i_layer), ...
					poly_layeroutline(i_layer+1).Vertices);
				
			end
		end
		
		if numboundaries(poly_layeroutline(end)) > 0
			
			last_ring = poly_layeroutline(end).Vertices;
			px = [last_ring(:,1); roof_center_x];
			py = [last_ring(:,2); roof_center_y];
			poly_roof(end+1,1) = polyshape(px, py);  % Fläche mit Spitze
			
		end
		
		% Spaltkorrektur (kleine negative Buffer zur Stabilität)
		poly_gap_roof = poly_outline_map_roof;
		
		for i = 1:size(poly_roof,1)
			
			poly_roof(i,1) = polybuffer(poly_roof(i,1),...
				-triangulation_gapsize, 'JointType','miter');
			poly_gap_roof = subtract(poly_gap_roof, poly_roof(i,1));
			
		end
		
		% Triangulationspolygone sammeln
		poly_triang_roof = poly_roof;
		poly_triang_roof(end+1,1) = poly_gap_roof;
		
		% Stützstellen für Interpolation (Rand + Schichten + Spitze)
		%
		ScInt_xyz_roof = [V(:,1), V(:,2), (height...
			- roof_height)*ones(size(V,1),1)];
		
		for i_layer = 2:no_layer
			
			% Punkte (Vertices) der aktuellen Schicht holen
			Vscaled = poly_layeroutline(i_layer).Vertices;
			
			% Nur wenn Vertices vorhanden sind, etwas hinzufügen
			if ~isempty(Vscaled)
				
				ScInt_xyz_roof = [ScInt_xyz_roof; ...
					Vscaled(:,1), ...								% x-Koordinaten
					Vscaled(:,2), ...								% y-Koordinaten
					z_layeroutline(i_layer) * ones(size(Vscaled,1),1)]; % z-Höhe
				
			end
		end
		
		% Spitze hinzufügen
		ScInt_xyz_roof = [ScInt_xyz_roof; roof_center_x,...
			roof_center_y, height];
		
		
		%% Triangulation Pyramidendach
	case 'pyramidal'
		
		% Zentrum des Dach-Umrisses:
		[roof_center_x,roof_center_y]	 = centroid(poly_outline_osm_roof);
		
		% Alle Punkte, die den Rand des Gebäudes bilden mit
		% identischem Anfangs- und Endpunkt:
		[poly_outline_osm_roof_x,poly_outline_osm_roof_y]	=...
			boundary(poly_outline_osm_roof);
		
		% Ausgehend vom unveränderten OSM-Dachgrundriss poly_outline_osm_roof
		% die Dach-Teilflächen poly_roof berechnen:
		poly_roof = polyshape;
		
		% Erzeugung der Dreiecke aus zwei benachbarten Punkten
		% aus dem Umriss mit dem Mittelpunkt
		for i=1:(size(poly_outline_osm_roof_x,1)-1)
			
			poly_roof(i,1)	= polyshape([poly_outline_osm_roof_x(i,1) poly_outline_osm_roof_x(i+1,1) roof_center_x],...
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
		
		% Der Flächeninhalt muss >0 sein:
		i_delete		= false(size(poly_roof));
		
		for i=1:size(poly_roof,1)
			
			if numboundaries(poly_roof(i,1)) == 0
				
				i_delete(i,1) = true;
				
			end
		end
		
		poly_roof(i_delete,:) = [];
		
		% Alle zu interpolierenden Polygone in poly_triang_roof zusammenstellen:
		poly_triang_roof = poly_roof;
		poly_triang_roof(end+1,1) = poly_gap_roof;
		
		% Stützstellen für die Berechnung der Höhen durch Interpolation:
		% auf dem Umriss poly_outline_osm_roof:
		ScInt_xyz_roof	= [...
			poly_outline_osm_roof.Vertices(:,1) ...
			poly_outline_osm_roof.Vertices(:,2) ...
			(height-roof_height)*ones(size(poly_outline_osm_roof.Vertices,1),1)];
		
		% innerhalb von poly_outline_osm_roof:
		ScInt_xyz_roof		= [ScInt_xyz_roof;...
			roof_center_x ...
			roof_center_y ...
			height];
		
		
		%% Triangulation Pultdach
	case 'skillion'
		
		% Testplot:
		if testplot
			fig_skillion		= figure(11111);
			clf(fig_skillion,'reset');
			set(fig_skillion,'Tag','maplab3d_figure');
			set(fig_skillion,'Name','Skillion');
			set(fig_skillion,'NumberTitle','off');
			ax_skillion		= axes;
			hold(ax_skillion,'on');
			axis(ax_skillion,'equal');
			xlabel(ax_skillion,'x / mm');
			ylabel(ax_skillion,'y / mm');
			
		end
		
		% Umriss
		[roof_center_x,roof_center_y]	= centroid(poly_outline_osm_roof);
		
		[poly_outline_osm_roof_x,poly_outline_osm_roof_y]	= ...
			boundary(poly_outline_osm_roof);
		
		% Bounding Box
		width_x = max(poly_outline_osm_roof_x) - min(poly_outline_osm_roof_x);
		width_y = max(poly_outline_osm_roof_y) - min(poly_outline_osm_roof_y);
		
		% Traufhöhe
		z_eave = height - roof_height;
		
		% --- Richtung bestimmen ---
		if isempty(roof_direction)
			
			% Automatische Richtung: Gefälle quer zur längeren Seite
			if width_x >= width_y
				
				roof_direction = 0;    % Nord-Süd (Gefälle in y-Richtung)
				
			else
				
				roof_direction = 90;   % Ost-West (Gefälle in x-Richtung)
				
			end
		end
		
		% Korrektur des Winkels aus OSM zu xy-Koordinaten
		% Richtung in größer werdende Dachöhe:
		% 90 addieren um die Achse anzupassen. 0 grad zeigt nach oben (y richtung).
		% https://wiki.openstreetmap.org/wiki/File:Angles.svg
		roof_direction_xy_increasing = (90 - roof_direction) + 180;
		
		% Richtungsvektor
		u = [cosd(roof_direction_xy_increasing),...
			sind(roof_direction_xy_increasing)];
		
		% --- Projektion ---
		proj = (poly_outline_osm_roof_x - roof_center_x)*u(1) + ...
			(poly_outline_osm_roof_y - roof_center_y)*u(2);
		
		% Normalisiere Start
		proj = proj - min(proj);
		
		% Skaliere auf 0...1
		proj = proj ./ max(proj);
		
		if testplot
			
			
			plot(ax_skillion,poly_outline_osm_roof_x-roof_center_x,poly_outline_osm_roof_y-roof_center_y,'.-r',...
				'MarkerSize',15);
			axis(ax_skillion,'equal');
			
			for i=1:(size(poly_outline_osm_roof_x,1)-1)
				text(ax_skillion,poly_outline_osm_roof_x(i)-roof_center_x,poly_outline_osm_roof_y(i)-roof_center_y,num2str(proj(i)),'Color','r','VerticalAlignment','bottom',  HorizontalAlignment='center');
			end
			
		end
		
		% Höhen der Punkte
		Zv = z_eave + proj * roof_height;
		
		edge  =struct([]);
		
		% schleife in der edges gesucht werden mit x und y koordinaten informationen
		for lw = 1:size(ways.iw,1)
			
			iw = ways.iw(lw);
			roof_edge = get_building_topside_get_tag_value('way',iw,'roof:edge','bool');
			
			
			if isempty(roof_edge)
				
				roof_edge = false;
				
			end
			
			if roof_edge
				
				edge(end+1).x = OSMDATA.way(1,iw).x_mm(:);
				edge(end).y = OSMDATA.way(1,iw).y_mm(:);
				
			end
			
			roof_edge_x=zeros(0,1);
			roof_edge_y=zeros(0,1);
			
			% diese edges sollen innerhalb der fläche liegen
			
			poly_edges_all = polyshape();
			
			
			for k = 1:numel(edge)
				
				% 1) koordinaten als input nutzen
				x0 = edge(k).x;
				y0 = edge(k).y;
				
				% 2) Mitelpunkt bestimmen
				[xr, yr] = changeresolution_xy(x0, y0, [], [], 1, 1);
				
				
				% 4) Prüfen ob Edge innerhalb des Daches liegt
				[tfin, tfon] = isinterior(poly_outline_osm_roof, xr, yr);
				
				if any(tfin & ~tfon)
					
					% 5) Line in Polygon umwandeln
					roof_edge_x = [roof_edge_x; x0];
					roof_edge_y = [roof_edge_y; y0];
					liwi = triangulation_gapsize;
					poly_edge_single = line2poly(x0, y0, {liwi; 6});
					poly_edges_all = union(poly_edges_all, poly_edge_single);
					
				end
			end
		end
		
		% roof_edge_xy = unique ([roof_edge_x roof_edge_y], 'rows');
		
		% linienpolygone von gesamtfläche subtrahieren
		poly_triang_roof_multiregion_edge=subtract(poly_outline_osm_roof,poly_edges_all);
		
		poly_triang_roof=regions(poly_triang_roof_multiregion_edge);
		
		poly_triang_roof=intersect(poly_triang_roof,poly_outline_map_roof);
		
		poly_gap_roof   = poly_outline_map_roof;
		
		poly_triang_roof	 = polybuffer(poly_triang_roof,...
			-triangulation_gapsize,'JointType','miter');
		
		poly_gap_roof	 = subtract(poly_gap_roof,poly_triang_roof);
		
		% Linienpolygone wieder dazu addieren
		poly_triang_roof(end+1,1)=poly_gap_roof;
		
		% Stützstellen für Interpolation
		ScInt_xyz_roof = [poly_outline_osm_roof_x, poly_outline_osm_roof_y, Zv];
		
		% Triangulation vorbereiten
		poly_roof = intersect(poly_outline_osm_roof, poly_outline_map_roof);
		poly_roof = polybuffer(poly_roof, -triangulation_gapsize,'JointType','miter');
		poly_gap_roof = subtract(poly_outline_map_roof, poly_roof);
		poly_triang_roof = poly_roof;
		
		if numboundaries(poly_gap_roof)>0
			
			poly_triang_roof(end+1,1) = poly_gap_roof;
			
		end
		
		
		%% Triangulation Satteldach
	case 'gabled'
		
		if testplot
			
			fig_gabled_steps = figure(21000);
			clf(fig_gabled_steps,'reset');
			set(fig_gabled_steps,'Tag','maplab3d_steps_full');
			set(fig_gabled_steps,'Name','Gabled Roof - Alle Schritte');
			set(fig_gabled_steps,'NumberTitle','off');
			% ax_gabled_steps		= axes;
			% hold(ax_gabled_steps,'on');
			% axis(ax_gabled_steps,'equal');
			% xlabel(ax_gabled_steps,'x / mm');
			% ylabel(ax_gabled_steps,'y / mm');
			
		end
		
		% 1) alle roof:ridge und roof:edge finden
		% 2) [x,y] = changeresolution_xy(x0,y0,[],[],1,1) % x0, y0
		%	  sind alle punkte vom roof ridge. damit kann der mittelpunkt
		%    vom ridge schnell festgelegt sein
		% 3) Prüfen ob roof ridge in der fläche liegen
		%    ([Tfin, tfon] = isinterior Funktion) % tfin = 1 und tfon = 0 !
		%    --> roof ridge in der fläche liegt if any(TFin&~TFon)
		%    polyin = polyoutlineosmroof
		% 4) mit line2poly aus roofridge ein polygon erzeugen
		%	  liwi=triangulation_gapsize;
		%	  poly_roof_ridge = line2poly(x0,y0,{liwi;6})
		%	  for rw=1:size(ways.p,1)
		%    if roof_ridge
		%    changeresolution
		%    tfin, tfon = isinterior
		%    if tfin&~tfon
		%    line2poly
		% 5) alle ridge und edge Linie von der Dachfläche subtrahieren
		%    es entstehen teilflächen
		% 6) union alle kleinen flächen zu einer spältfläche vereinen
		% 7) poly_triang_roof = regions( übrige fläche aus 5) ) teilflächen
		%    in poly_triang_roof sammeln im vektor
		% 8) die leere teilfläche die subtrahiert wurde muss dann auch im
		%    triangroof eingefügt. poly_triang_roof(end+1,1)=
		%    intersect(umriss, spaltfläche)
		% 9) Stützstellen für die Berechnung der Höhen durch Interpolation:
		%    auf dem Umriss poly_outline_osm_roof:
		
		
		% Struct Variable wo alle ridges mit koordinaten gespeichert werden
		ridge = struct([]);
		edge  =struct([]);
		
		% schleife in der ridges gesucht werden mit x und y koordinaten
		roof_ridge_x=zeros(0,1);
		roof_ridge_y=zeros(0,1);
		roof_edge_x=zeros(0,1);
		roof_edge_y=zeros(0,1);
		liwi = triangulation_gapsize;
		for lw = 1:size(ways.iw,1)
			iw = ways.iw(lw);
			roof_ridge	= get_building_topside_get_tag_value('way',iw,'roof:ridge','bool');
			roof_edge = get_building_topside_get_tag_value('way',iw,'roof:edge','bool');
			
			if isempty(roof_ridge)
				roof_ridge = false;
				
				
			elseif isempty(roof_edge)
				roof_edge = false;
			end
			
			if roof_ridge
				ridge(end+1).x = OSMDATA.way(1,iw).x_mm(:);
				ridge(end).y = OSMDATA.way(1,iw).y_mm(:);
			end
			
			if roof_edge
				edge(end+1).x = OSMDATA.way(1,iw).x_mm(:);
				edge(end).y = OSMDATA.way(1,iw).y_mm(:);
			end
			
			
			
			% diese ridges sollen innerhalb der fläche liegen
			poly_ridges_all	= polyshape();
			poly_edges_all = polyshape();
			
			for k = 1:numel(ridge)
				
				% 1) koordinaten als input nutzen
				x0 = ridge(k).x;
				y0 = ridge(k).y;
				
				% 2) Mitelpunkt bestimmen
				[xr, yr] = changeresolution_xy(x0, y0, [], [], 1, 1);
				
				% 4) Prüfen ob Ridge innerhalb des Daches liegt
				[tfin, tfon] = isinterior(poly_outline_osm_roof, xr, yr);
				
				if any(tfin & ~tfon)
					% 5) Line in Polygon umwandeln
					roof_ridge_x = [roof_ridge_x; x0];
					roof_ridge_y = [roof_ridge_y; y0];
					
					poly_ridge_single = line2poly(x0, y0, {liwi; 6});
					poly_ridges_all = union(poly_ridges_all, poly_ridge_single);
					% plot(ax_gabled_ridge,roof_ridge_x,roof_ridge_y,'Color','r','Marker','.','MarkerSize',10)
				end
			end
			
			for k = 1:numel(edge)
				
				% 1) koordinaten als input nutzen
				x0 = edge(k).x;
				y0 = edge(k).y;
				
				% 2) Mitelpunkt bestimmen
				[xr, yr] = changeresolution_xy(x0, y0, [], [], 1, 1);
				
				% 4) Prüfen ob Ridge innerhalb des Daches liegt
				[tfin, tfon] = isinterior(poly_outline_osm_roof, xr, yr);
				
				if any(tfin & ~tfon)
					% 5) Line in Polygon umwandeln
					roof_edge_x = [roof_edge_x; x0];
					roof_edge_y = [roof_edge_y; y0];
					
					poly_edge_single = line2poly(x0, y0, {liwi; 6});
					poly_edges_all = union(poly_edges_all, poly_edge_single);
					
				end
			end
		end
		
		if testplot
			
			subplot(3,2,3);
			plot(poly_ridges_all,'FaceColor',[0.6 0.8 1],'EdgeColor','k');
			hold on
			plot(poly_edges_all,'FaceColor',[0.6 0.8 1],'EdgeColor','k');
			axis equal; grid on;
			xlabel('x / mm');
			ylabel('y / mm');
			title('3. Linien in  Polygone umwandeln');
			
		end
		
		% ridge manuell erzeugen wenn es nicht vorhanden ist
		if size(roof_ridge_x,1)==0
			
			if ~strcmp(roof_orientation, 'along')&&...
					~strcmp(roof_orientation, 'across')
				
				roof_orientation = 'along';
				
			end
			
			% Umriss
			[poly_x, poly_y] = boundary(poly_outline_osm_roof);
			
			% Schwerpunkt
			[roof_center_x, roof_center_y] = centroid(poly_outline_osm_roof);
			
			% kürzester abstand von der mitte zum umriss
			[~,x_dmin,y_dmin] = mindistance_poly_p(poly_x,poly_y,...
				roof_center_x, roof_center_y);
			
			% x-Abstand ermitteln
			across_dist_x = x_dmin - roof_center_x;
			
			% y-Abstand ermitteln
			across_dist_y = y_dmin - roof_center_y;
			
			% Vektor erzeugen und um 90° drehen
			roof_ridge_across = [across_dist_x, across_dist_y];
			
			if strcmp(roof_orientation, 'along')
				roof_ridge_along = [-roof_ridge_across(2) roof_ridge_across(1)];
				
				% Verlängern damit es den Dachumriss beschneidet
				roof_ridge_along_n = [roof_center_x roof_center_y]...
					- roof_ridge_along * 10000;
				
				roof_ridge_along_p = [roof_center_x roof_center_y]...
					+ roof_ridge_along * 10000;
				
				% Verlängerter Vektor
				ridge_along_extended	= [roof_ridge_along_n;roof_ridge_along_p];
				
				% Schnittpunkte zwischen den verlängerten Vektor und Dachumriss
				[roof_ridge_x,roof_ridge_y]=polyxpoly(poly_x,poly_y,...
					ridge_along_extended(:,1),ridge_along_extended(:,2));
				
				% Vektor --> Ridge-Linie --> Linie in ein Polygon umwandeln
				poly_ridges_all = line2poly(roof_ridge_x,...
					roof_ridge_y, {liwi; 6});
				
			else
				
				roof_ridge_across_n = [roof_center_x roof_center_y]...
					- roof_ridge_across * 10;
				roof_ridge_across_p = [roof_center_x roof_center_y]...
					+ roof_ridge_across * 10;
				ridge_across_extended	= [roof_ridge_across_n;roof_ridge_across_p];
				[roof_ridge_x,roof_ridge_y]=polyxpoly(poly_x,poly_y,...
					ridge_across_extended(:,1),ridge_across_extended(:,2));
				poly_ridges_all = line2poly(roof_ridge_x, roof_ridge_y, {liwi; 6});
				
			end
			
			fig_ridge_algo = figure(29876);
			clf(fig_ridge_algo,'reset');
			set(fig_ridge_algo,'Tag','Ridge_Algorithm');
			set(fig_ridge_algo,'Name',...
				'Alle Schritte zum Algorithmus zur Ridgeerzegung');
			set(fig_ridge_algo,'NumberTitle','off');
			
			subplot(3,2,1);
			plot(poly_outline_osm_roof, 'FaceColor','none',...
				'EdgeColor','k','LineWidth',1.5);
			hold on;
			plot(roof_center_x, roof_center_y, 'rx', 'MarkerSize',10,'LineWidth',2);
			axis equal; grid on;
			xlabel('x / mm'); ylabel('y / mm');
			title('1. Dachumriss und Schwerpunkt');
			
			subplot(3,2,2);
			plot(poly_outline_osm_roof, 'FaceColor','none','EdgeColor','k');
			hold on;
			plot([roof_center_x x_dmin], [roof_center_y y_dmin], ...
				'r-', 'LineWidth',2);
			plot(x_dmin, y_dmin, 'ro','MarkerSize',6,'LineWidth',2);
			plot(roof_center_x, roof_center_y, 'ko','MarkerFaceColor','k');
			axis equal; grid on;
			title('2. Kürzeste Richtung zum Rand (across)');
			
			subplot(3,2,3);
			plot(poly_outline_osm_roof, 'FaceColor','none',...
				'EdgeColor','k','LineWidth',1.2);
			hold on;
			% along-Richtung (90° gedreht)
			roof_ridge_along = [-roof_ridge_across(2), roof_ridge_across(1)];
			plot([roof_center_x, roof_center_x + roof_ridge_along(1)], ...
				[roof_center_y, roof_center_y + roof_ridge_along(2)], ...
				'b-','LineWidth',2);
			plot(roof_center_x, roof_center_y, 'ko','MarkerFaceColor','k');
			axis equal; grid on;
			xlabel('x / mm');
			ylabel('y / mm');
			title('3. Richtungsbestimmung: across (rot) und along (blau)');
			
			subplot(3,2,4);
			plot(poly_outline_osm_roof,'FaceColor','none',...
				'EdgeColor','k','LineWidth',1.2);
			plot([roof_ridge_along_n(1) roof_ridge_along_p(1)], ...
				[roof_ridge_along_n(2) roof_ridge_along_p(2)], ...
				'b--','LineWidth',2);
			hold on;
			plot(roof_center_x, roof_center_y,'rx','MarkerSize',10,...
				'LineWidth',2);
			plot(poly_outline_osm_roof,'FaceColor','none','EdgeColor',...
				'k','LineWidth',1.2);
			axis equal; grid on;
			xlabel('x / mm'); ylabel('y / mm');
			title('4) Verlängerte Firstlinien-Achse (durch Schwerpunkt)');
			
			subplot(3,2,5);
			plot(poly_outline_osm_roof, 'FaceColor','none','EdgeColor','k');
			hold on;
			plot(roof_ridge_x, roof_ridge_y, 'ro','MarkerSize',8,'LineWidth',2);
			plot(roof_ridge_x, roof_ridge_y, 'r-','LineWidth',2);
			axis equal; grid on;
			title('4. Tatsächliche Firstlinie (Schnittpunkte)');
			
			subplot(3,2,6);
			plot(poly_outline_osm_roof,'FaceColor','none','EdgeColor',...
				'k','LineWidth',1.2);
			hold on;
			plot(poly_ridges_all,'FaceColor',[1 0 0],'FaceAlpha',0.25,...
				'EdgeColor','r','LineWidth',1.2);
			axis equal; grid on;
			xlabel('x / mm'); ylabel('y / mm');
			title(sprintf('6) Ridge-Polygon (line2poly), liwi=%g', liwi));
			
		end
		
		% linienpolygone von gesamtfläche subtrahieren
		poly_triang_roof_multiregion = subtract(poly_outline_osm_roof,...
			poly_ridges_all);
		
		poly_triang_roof_multiregion = subtract(poly_triang_roof_multiregion,...
			poly_edges_all);
		
		if testplot
			
			subplot(3,2,4);
			if exist('poly_triang_roof_multiregion','var')
				
				plot(poly_triang_roof_multiregion,'FaceColor',[0.6 0.8 1],...
					'EdgeColor','k');
				
			end
			
			axis equal; grid on;
			xlabel('x / mm');
			ylabel('y / mm');
			title('4. Spaltfläche vom Umriss abziehen');
			
		end
		
		poly_triang_roof_multiregion=intersect(poly_triang_roof_multiregion,...
			poly_outline_map_roof);
		
		poly_gap_roof   = poly_outline_map_roof;
		
		poly_triang_roof_multiregion = polybuffer(poly_triang_roof_multiregion,...
			-triangulation_gapsize,'JointType','miter');
		
		if testplot
			subplot(3,2,5);
			plot(poly_triang_roof_multiregion,'FaceColor',[0.6 0.8 1],...
				'EdgeColor','k');
			axis equal; grid on;
		end
		
		poly_gap_roof = subtract(poly_gap_roof,poly_triang_roof_multiregion);
		
		poly_triang_roof=regions(poly_triang_roof_multiregion);
		
		% linienpolygone wieder dazu addieren
		poly_triang_roof(end+1,1)=poly_gap_roof;
		
		if testplot
			
			subplot(3,2,6);
			plot(poly_triang_roof,'FaceColor',[0.6 0.8 1],'EdgeColor','k');
			axis equal; grid on;
			xlabel('x / mm');
			ylabel('y / mm');
			title('6. Spaltfläche wird separat draufaddiert');
			
		end
		
		% Umriss
		[x,y]=boundary(poly_outline_osm_roof);
		
		% Nodes in die komplexen Ebene übertragen
		c=x+1i*y;
		
		% Zeiger zwischen zwei Punkten
		dc=-c(1:(end-1))+c(2:end);
		
		% Mit angle(dc) wird der Drehwinkel der Zeiger zur reellen Achse berechnet
		% Es sollen die Differenzen der Drehwinkel zwischen zwei
		% aufeinanderfolgenden Zeigern dc(i) berechnet werden. Damit das erste
		% Element in diff_angle_dc gleich dem ersten Punkt entspreicht
		% (der Punkt liegt dann zwischen den betreffenden Zeigern dc,
		% deren Winkel subtrahiert werden)
		% Das letzte Element wird am Anfang eingefügt:
		dc=[dc(end);dc];
		
		% Ist diff_angle_dc klein, zeigen die Zeiger dc in dieselbe Richtung
		diff_angle_dc=diff(angle(dc)*180/pi);
		
		%Umrechung auf +-180°
		diff_angle_dc=mod(diff_angle_dc+180,360)-180;
		
		% Toleranzgrenze
		diff_angle_lim=10;
		
		%Indexvektor
		k_delete=(abs(diff_angle_dc)<diff_angle_lim);
		
		ScInt_xyz_roof	= [...
			poly_outline_osm_roof.Vertices(~k_delete,1) ...
			poly_outline_osm_roof.Vertices(~k_delete,2) ...
			(height-roof_height)*ones(size(...
			poly_outline_osm_roof.Vertices(~k_delete,1),1),1)];
		
		% innerhalb von poly_outline_osm_roof:
		roof_ridge_xy = unique ([roof_ridge_x roof_ridge_y], 'rows');
		ScInt_xyz_roof	= [ScInt_xyz_roof;...
			roof_ridge_xy ...
			height*ones(size(roof_ridge_xy,1),1)];
		
		
		% --- Visualisierung aller Zwischenschritte der Dachbildung ---
		if testplot
			
			% (1) Original OSM-Dachumriss
			subplot(3,2,1);
			plot(poly_outline_osm_roof,'FaceColor',[0.85 0.85 0.85],'EdgeColor','k');
			axis equal; grid on;
			xlabel('x / mm');
			ylabel('y / mm');
			title('1. OSM-Dachumriss');
			
			% (2) Erkennung der Ridge- und Edge-Linien
			subplot(3,2,2);
			hold on;
			if exist('ridge','var') && ~isempty(ridge)
				for k = 1:numel(ridge)
					plot(ridge(k).x, ridge(k).y, 'r-', 'LineWidth', 1.2);
				end
			end
			if exist('edge','var') && ~isempty(edge)
				for k = 1:numel(edge)
					plot(edge(k).x, edge(k).y, 'b-', 'LineWidth', 1.2);
				end
			end
			plot(poly_outline_osm_roof,'FaceColor','none','EdgeColor','k');
			axis equal; grid on;
			title('2. Alle Ridge- (rot) und Edge (blau) Linien finden');
			xlabel('x / mm');
			ylabel('y / mm');
			
			% (4) Subtraktion der Linien von der Gesamtfläche
			subplot(3,2,5);
			hold on;
			if exist('poly_triang_roof_multiregion_ridge','var')
				plot(poly_triang_roof_multiregion,'FaceColor',[1 0.8 0.8],'EdgeColor','k');
			end
			xlabel('x / mm');
			ylabel('y / mm');
			plot(poly_outline_osm_roof,'FaceColor','none','EdgeColor','k','LineStyle','--');
			axis equal; grid on;
			title('5. Flächen werden geschrumpft');
			
		end
		
		%% Triangulation andere Dachformen
	otherwise
		
		% Warnung ausgeben:
		if ~isdeployed
			% Ausführung innerhalb der Entwicklungsumgebung MATLAB:
			get_building_topside_display_warning(sprintf('roof_shape=%s is not implemented',roof_shape),'way',iw);
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


setbreakpoint = 1;

