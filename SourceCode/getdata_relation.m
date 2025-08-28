function [no_nodes,no_ways,no_rel,connways,in_relation_v,id_node_v,id_way_v]=...
	getdata_relation(ir,connways,iobj,lino,liwi,in_relation_v,id_node_v,id_way_v,lino_new_min)
% getdata_relation searches a relation recursively
% inputs:	ir					index of the relation: OSMDATA.relation(1,ir)
%				connways			coordinates of all "connected ways": see function connect_ways
%				iobj				optional:	object number, will be added to the structure connways
%				lino				optional:	line number, for identification when lines of diff. object numbers are mixed
%				liwi				optional:	line width of the new way
%				in_relation_v	optional:	initialization: in_relation_v=false(1,size(OSMDATA.node,2));
%													The element of all nodes that are used by the relation is set true.
%													[]: default
%				id_node_v,		optional:	vectors of OSM-ID values, that are already part of connways. If the relation
%				id_way_v							contains data with the same ID, it will not be added to connways.
%													[]: all data will be added to connways
%				lino_new_min	optional:	The numbering of new lines in connways begins with this number.
% outputs:	no_nodes			total number of nodes
%				no_ways			total number of ways
%									no_ways is not the same as the size of connways or the number of members:
%									- It is possible that not all members are included in the current map section.
%									- In connways, ways that have the same start- and endpoint are connected.
%				no_rel			total number of relations
%				connways			coordinates of all "connected ways": see function connect_ways
%				in_relation_v	optional:	logical array:	in_relation_v(1,inwr)
%													vector of the same size as OSMDATA.node
%													true  if the single node is part of the relation (not as way)
%													false if the single node is not part of the relation
%													This is used to delete nodes that are not used when loading the OSM-data.
%				id_node_v,		optional:	vectors of OSM-ID values, that are already part of connways. If the relation
%				id_way_v							contains data with the same ID, it will not be added to connways.
%													[]: all data will be added to connways

global OSMDATA GV PP

try

	% Testplot:
	testplot	= 0;

	% Initializations:
	if nargin==0
		% Test:
		ir					= 10;			% OSMDATA.relation(1,ir)			7 9 15     |     10: Sommerrodelbahn
		connways			= connect_ways([]);
	end
	if nargin<3
		iobj				= 0;
	end
	if nargin<4
		lino				= [];
	end
	if nargin<5
		liwi				= 0;
	end
	if nargin<6
		in_relation_v	= [];
	end
	if nargin<7
		id_node_v		= [];
	end
	if nargin<8
		id_way_v			= [];
	end
	if nargin<9
		lino_new_min	= 1;
	else
		if isempty(lino_new_min)
			lino_new_min	= 1;
		end
	end
	if size(OSMDATA.relation,2)<ir
		errortext	= sprintf([...
			'Error in getdata_relation:\n',...
			'ir=%g must be equal or less to\n',...
			'size(OSMDATA.relation,2)=%g'],...
			ir,size(OSMDATA.relation,2));
		errormessage(errortext)
	end
	inwr				= ir;
	type				= 'relation';
	roles_incl		= cell(0,1);
	roles_excl		= cell(0,1);
	if iobj>0
		for i=1:size(PP.obj(iobj).relation_role_incl,2)
			if ~isempty(PP.obj(iobj).relation_role_incl{1,i})
				roles_incl{end+1,1}	= PP.obj(iobj).relation_role_incl{1,i};
			end
		end
		for i=1:size(PP.obj(iobj).relation_role_excl,2)
			if ~isempty(PP.obj(iobj).relation_role_excl{1,i})
				roles_excl{end+1,1}	= PP.obj(iobj).relation_role_excl{1,i};
			end
		end
	end

	% number of nodes, ways and relations inside this relation:
	no_nodes	= 0;				% total number of nodes
	no_ways	= 0;				% total number of ways
	norel		= double(OSMDATA.id.relation(1,inwr));			% relation ID

	% Searching the relation recursively:
	role				= 'outer';		% only for the first call, will be overwritten because type='relation'
	[no_nodes,no_ways,norel,connways,in_relation_v,id_node_v,id_way_v]=...
		getdata_relation_local(...
		inwr,type,no_nodes,no_ways,norel,connways,iobj,lino,liwi,...
		in_relation_v,id_node_v,id_way_v,roles_incl,roles_excl,lino_new_min,role);

	% total number of relations:
	no_rel	= length(unique([...
		connways.nodes_norel;...
		connways.lines_norel;...
		connways.areas_norel]));

	% Testplot:
	if testplot==1
		clc
		% Plot title: show all keys/values:
		title_str=sprintf('getdata_relation_local: %s\n',GV.osm_pathfilename);
		if isfield(OSMDATA.relation(1,ir),'tag')
			if ~ismissing(OSMDATA.relation(1,ir).tag(1,1))
				for irt=1:size(OSMDATA.relation(1,ir).tag,2)
					if mod(irt,2)==0
						title_str=sprintf('%s%s=%s\n',title_str,...
							OSMDATA.relation(1,ir).tag(1,irt).k,OSMDATA.relation(1,ir).tag(1,irt).v);
					else
						title_str=sprintf('%s%s=%s   /   ',title_str,...
							OSMDATA.relation(1,ir).tag(1,irt).k,OSMDATA.relation(1,ir).tag(1,irt).v);
					end
				end
			end
		end
		if mod(irt,4)~=0
			title_str=sprintf('%s\n',title_str);
		end
		title_str=sprintf('%sir=%g  /  Members: %g',title_str,ir,size(OSMDATA.relation(1,ir).member,2));
		% Show the type of the members and if they are included in the map data in the command window:
		counter	= 0;
		for irm=1:size(OSMDATA.relation(1,ir).member,2)
			type	= OSMDATA.relation(1,ir).member(1,irm).type;
			ref	= OSMDATA.relation(1,ir).member(1,irm).ref;
			inwr	= find(OSMDATA.id.(type)==ref,1);
			if ~isempty(inwr)
				counter	= counter+1;
				fprintf(1,'getdata_relation: member %04.0f: type=%s   included:      counter=%g\n',irm,type,counter);
			else
				fprintf(1,'getdata_relation: member %04.0f: type=%s   not included\n',irm,type);
			end
		end
		% Show the plot:
		hf		= figure(200010);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha		= axes;
		hold(ha,'on');
		set(hf,'Name','getdata_relation_local');
		set(hf,'NumberTitle','off');
		pos=get(ha,'Position');
		pos(4)=pos(4)*0.8;
		set(ha,'Position',pos);
		plot(ha,[...
			OSMDATA.bounds.xmin_mm ...
			OSMDATA.bounds.xmax_mm ...
			OSMDATA.bounds.xmax_mm ...
			OSMDATA.bounds.xmin_mm ...
			OSMDATA.bounds.xmin_mm],[...
			OSMDATA.bounds.ymin_mm ...
			OSMDATA.bounds.ymin_mm ...
			OSMDATA.bounds.ymax_mm ...
			OSMDATA.bounds.ymax_mm ...
			OSMDATA.bounds.ymin_mm],'-m');
		if ~isempty(connways.nodes)
			plot(ha,connways.nodes.xy(:,1),connways.nodes.xy(:,2),...
				'xr','LineWidth',1.5,'MarkerSize',8);
		end
		for k=1:size(connways.lines,1)
			plot(ha,connways.lines(k,1).xy(:,1),connways.lines(k,1).xy(:,2),'.-b')
		end
		for k=1:size(connways.areas,1)
			plot(ha,connways.areas(k,1).xy(:,1),connways.areas(k,1).xy(:,2),'.-g')
		end
		title_str=sprintf('%s  /  no_nodes=%g  /  no_ways=%g  /  norel=%g',...
			title_str,no_nodes,no_ways,norel);
		title(title_str,'Interpreter','none');
		xlabel(ha,'x / mm');
		ylabel(ha,'x / mm');
		axis(ha,'equal');
	end

catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
function [no_nodes,no_ways,norel,connways,in_relation_v,id_node_v,id_way_v]=...
	getdata_relation_local(...
	inwr,type,no_nodes,no_ways,norel,connways,iobj,lino,liwi,...
	in_relation_v,id_node_v,id_way_v,roles_incl,roles_excl,lino_new_min,role)
% In contrast to no_nodes and no_ways, norel is not incremented, but is the ID of the relation!

global OSMDATA GV

try

	switch type

		case 'node'
			if ~any(OSMDATA.id.node(1,inwr)==id_node_v)
				x			= OSMDATA.node_x_mm(1,inwr);
				y			= OSMDATA.node_y_mm(1,inwr);
				if ~isnan(x)&&~isnan(y)
					no_nodes	= no_nodes+1;
					% Add the current node to connways:
					connways	= connect_ways(connways,[],x,y,iobj,lino,liwi,1);
					id_node_v(end+1,1)	= OSMDATA.id.node(1,inwr);
					if ~isempty(in_relation_v)
						in_relation_v(1,inwr)	= true;
					end
				end
			end
		case 'way'
			if ~any(OSMDATA.id.way(1,inwr)==id_way_v)
				no_ways	= no_ways+1;
				no_nodes	= no_nodes+OSMDATA.way(1,inwr).no_nodes;
				% Add the current way to connways:
				x			= OSMDATA.way(1,inwr).x_mm(:);
				y			= OSMDATA.way(1,inwr).y_mm(:);
				if ~isempty(GV.test_readosm)
					if    (sum(abs([x(1)   y(1)  ]-GV.test_readosm.p1))<1e-3)||...
							(sum(abs([x(end) y(end)]-GV.test_readosm.p1))<1e-3)
						GV.test_readosm.line(end+1).xy	= [x y];
						GV.test_readosm.iw_v(end+1)		= inwr;
						GV.test_readosm.idw_v(end+1)		= OSMDATA.id.way(1,inwr);
						GV.test_readosm.itable_v(end+1)	= GV.test_readosm.itable;
						GV.test_readosm.ioeqt_v(end+1)	= GV.test_readosm.ioeqt;
						set_breakpoint	= 1;
					end
				end
				[xc,yc]	= polysplit(x,y);
				for ic=1:size(xc,1)
					connways	= connect_ways(...
						connways,[],xc{ic,1},yc{ic,1},iobj,lino,liwi,1,1,lino_new_min,role,norel);
					if ic==1
						id_way_v(end+1,1)					= OSMDATA.id.way(1,inwr);
					end
				end
			end
		case 'relation'
			norel			= double(OSMDATA.id.relation(1,inwr));
			for irm=1:size(OSMDATA.relation(1,inwr).member,2)
				role			= OSMDATA.relation(1,inwr).member(1,irm).role;
				incl_member	= false;
				if isempty(roles_incl)
					incl_member	= true;
				else
					for i=1:size(roles_incl,1)
						if strcmp(roles_incl{i,1},role)
							incl_member	= true;
						end
					end
				end
				for i=1:size(roles_excl,1)
					if strcmp(roles_excl{i,1},role)
						incl_member	= false;
					end
				end
				if incl_member
					ref_next		= OSMDATA.relation(1,inwr).member(1,irm).ref;
					type_next	= OSMDATA.relation(1,inwr).member(1,irm).type;
					inwr_next	= find(OSMDATA.id.(type_next)==ref_next,1);
					% It is possible that not all objects are included in the current map section:
					if ~isempty(inwr_next)
						[no_nodes,no_ways,norel,connways,in_relation_v,id_node_v,id_way_v]=...
							getdata_relation_local(...
							inwr_next,type_next,no_nodes,no_ways,norel,connways,iobj,lino,liwi,...
							in_relation_v,id_node_v,id_way_v,roles_incl,roles_excl,lino_new_min,role);
					end
				end
			end

	end

catch ME
	errormessage('',ME);
end

