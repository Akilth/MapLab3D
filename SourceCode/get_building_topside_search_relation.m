function [poly_outline_osm,...	% Building outline: relation member with role=outline or role=outer
	poly_union_osm,...				% Building outline: all closed ways united
	nodes,...							% nodes stucture including the nodes of the relation
	ways...								% ways  stucture including the ways  of the relation
	]=get_building_topside_search_relation(...
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
				get_building_topside_testplot_nwr('node',in,nodes.x(kn,1),nodes.y(kn,1),ax1);
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
				get_building_topside_testplot_nwr('way',iw,ways.p(kw,1).x,ways.p(kw,1).y,ax1);
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
					]=get_building_topside_search_relation(...
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

