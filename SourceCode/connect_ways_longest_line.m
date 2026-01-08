function connways=...
	connect_ways_longest_line(...
	connways,ways,iobj,lino,liwi,l2a,s,lino_new_min,tol)
% Adds the paths in the structure ways to an existing structure connways according to the following principles:
% -	Only individual ways with identical relid, role and tag values are connected.
% -	Closed paths found in ways are added first. Among all closed paths, the longest ones are added first.
% -	After all closed paths have been added to connways, the longest open path is added,
%		then the second longest among the remaining paths, and so on.
% The background is the connection of ways contained in relations of rivers.
% For display with variable line width, a river must be completely contained in an unbranched line.
% Sometimes there are small branches that prevent this if the order of connection with connect_ways is incorrect.
%
% Inputs:
% connways						see connect_ways
% ways(iw,1).xy				two-column matrix of vertices
% ways(iw,1).relid			uint64 number: OpenStreetMap dataset ID
% ways(iw,1).role				character array
% ways(iw,1).tag				character array
% ways(iw,1).iw_osmdata		index in OSMDATA.way
% ways(iw,1).ir_osmdata		index in OSMDATA.relation (0: no relation)
% ways(iw,1).connect			connect lines with matching startpoints and/or endpoints (true/false)
% iobj							see connect_ways
% lino
% liwi
% l2a
% s
% lino_new_min
% tol

global GV PP

try
	
	% Testing:
	testplot						= false;
	if nargin==0
		clc
		connways						= connect_ways([]);
		iobj							= 1;
		lino							= [];
		liwi							= [];
		l2a							= 1;
		s								= 1;
		lino_new_min				= 1;
		tol							= GV.tol_1;
		% Create testdata:
		testdata_no					= 1;
		switch testdata_no
			case 1
				testplot						= true;
				iw								= 0;
				role							= 'inner';
				iw=iw+1;	ways(iw,1).xy	= [0 0;0 2]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [0 2;1 3]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [1 3;2 3]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [0 0;2 3]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [0 0;2 1]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [2 1;3 3]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [2 3;3 3]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [3 3;3 5]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [3 5;5 5]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [3 3;5 5]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [3 3;4 2]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [4 2;4 1]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [4 1;5 1]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [5 1;5 3]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [5 3;5 5]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [5 5;7 5]; ways(iw,1).role=role;
				
				iw=iw+1;	ways(iw,1).xy	= [0 3;0 2]; ways(iw,1).role=role;
				
				iw=iw+1;	ways(iw,1).xy	= [5 5;4 7]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [4 7;3 5]; ways(iw,1).role=role;
				
				iw=iw+1;	ways(iw,1).xy	= [5 5;5 8]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [5 8;2 8]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [2 8;3 3]; ways(iw,1).role=role;
				
				% unbranched way:
				iw=iw+1;	ways(iw,1).xy	= [0 4;0 5]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [0 5;2 5]; ways(iw,1).role=role;
				role							= 'outer';
				iw=iw+1;	ways(iw,1).xy	= [0 0;3 0]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [3 0;7 0]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [7 0;7 5]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [7 5;6 6]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [6 6;0 6]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [6 6;6 7]; ways(iw,1).role=role;
				iw=iw+1;	ways(iw,1).xy	= [6 7;6 8]; ways(iw,1).role=role; ways(iw,1).connect	= false;
				
				% different relation ids:
				relid							= uint64(123);
				iw=iw+1;	ways(iw,1).xy	= [8 1;8 3]; ways(iw,1).role=role; ways(iw,1).relid=relid;
				iw=iw+1;	ways(iw,1).xy	= [8 3;9 2]; ways(iw,1).role=role; ways(iw,1).relid=relid;
				iw=iw+1;	ways(iw,1).xy	= [9 2;8 1]; ways(iw,1).role=role; ways(iw,1).relid=relid;
				relid							= uint64(456);
				iw=iw+1;	ways(iw,1).xy	= [8 3;8 5]; ways(iw,1).role=role; ways(iw,1).relid=relid;
				relid							= uint64(789);
				iw=iw+1;	ways(iw,1).xy	= [8 5;8 8]; ways(iw,1).role=role; ways(iw,1).relid=relid;
				
				% Different tags
				iw=iw+1;	ways(iw,1).xy	= [9 3;9 5]; ways(iw,1).tag='Testtag 1';
				iw=iw+1;	ways(iw,1).xy	= [9 5;9 7]; ways(iw,1).tag='Testtag 2';
				
				for iw=1:size(ways,1)
					ways(iw,1).iw_osmdata	= iw;			% index in OSMDATA.way
					ways(iw,1).ir_osmdata	= 1;			% index in OSMDATA.relation (0: no relation)
					if isempty(ways(iw,1).connect)
						ways(iw,1).connect	= true;		% connect line (true/false)
					end
					if isempty(ways(iw,1).relid)
						ways(iw,1).relid		= uint64(0);
					end
				end
				
			case 2
				% see plotosmdata_getdata.m 764:
				global connways_eqtags_main_filt connways_eqtags_main ways_main
				ways=ways_main;
		end
	end
	
	if testplot
		% Create testplot:
		hf=figure(43235662);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha1		= subplot(2,2,1);
		ha2		= subplot(2,2,2);
		ha3		= subplot(2,2,3);
		ha4		= subplot(2,2,4);
	end
	
	% Initializations:
	if isempty(lino_new_min)
		lino_new_min	= 1;
	end
	if isempty(ways)
		return
	end
	if    ~isfield(ways,'xy'        )||...
			~isfield(ways,'relid'     )||...
			~isfield(ways,'role'      )||...
			~isfield(ways,'tag'       )||...
			~isfield(ways,'iw_osmdata')||...
			~isfield(ways,'ir_osmdata')||...
			~isfield(ways,'connect')
		errormessage;
	end
	for iw=1:size(ways,1)
		if ~isnumeric(ways(iw,1).relid)
			errormessage;
		end
		if isempty(ways(iw,1).relid)
			errormessage;
		end
		if isnumeric(ways(iw,1).role)
			ways(iw,1).role			= '';
		end
		if isnumeric(ways(iw,1).tag)
			ways(iw,1).tag				= '';
		end
		if ~isnumeric(ways(iw,1).iw_osmdata)
			errormessage;
		end
		if isempty(ways(iw,1).iw_osmdata)
			errormessage;
		end
		if ~isnumeric(ways(iw,1).ir_osmdata)
			errormessage;
		end
		if isempty(ways(iw,1).ir_osmdata)
			errormessage;
		end
		if ~islogical(ways(iw,1).connect)
			errormessage;
		end
		if isempty(ways(iw,1).connect)
			errormessage;
		end
	end
	
	% First try to connect all ways without reversal (necessary for rivers):
	conn_with_rev	= false;
	
	% Get the graph:
	% -	ways sorted by roles and tags
	% -	list of all vertices
	% -	list of all edges and edge lengths
	G		= get_graph(ways);
	if testplot
		show_testplot(ha1,'G',G,connways);
	end
	for iG=1:size(G,1)
		
		% Connect unbranched lines:
		G(iG,1)		= connect_unbranched_lines(G(iG,1));
		
		% Add lines to connways:
		% - that are not connected to any other line or
		% - that should not be connected to any other line.
		iw_delete	= false(size(G(iG,1).ways,1),1);
		for iw=1:size(G(iG,1).ways,1)
			if    ~G(iG,1).ways(iw,1).connect||(...
					isscalar(find(G(iG,1).E(iw,1)==G(iG,1).E))&&...
					isscalar(find(G(iG,1).E(iw,2)==G(iG,1).E))     )
				% The way iw is not connected to any other way: Add way iw to connways and delete way iw from G:
				connways		= connect_ways(...
					connways,...									%
					[],...											% connways_merge
					G(iG,1).ways(iw,1).xy(:,1),...			% x
					G(iG,1).ways(iw,1).xy(:,2),...			% y
					iobj,...											% iobj
					lino,...											% lino
					liwi,...											% liwi
					0,...												% in
					G(iG,1).ways(iw,1).iw_v_osmdata,...		% iw_v
					G(iG,1).ir,...									% ir
					l2a,...											% l2a
					s,...												% s
					lino_new_min,...								% lino_new_min
					G(iG,1).role,...								% role
					G(iG,1).relid,...								% relid
					G(iG,1).tag,...								% tag
					tol,...											% tol
					conn_with_rev,...								% conn_with_rev
					G(iG,1).ways(iw,1).connect);				% connect
				iw_delete(iw,1)	= true;
			end
		end
		G(iG,1).ways(iw_delete,:)				= [];
		G(iG,1).E(iw_delete,:)					= [];
		G(iG,1).L(iw_delete,:)					= [];
		if testplot
			show_testplot(ha2,sprintf('iG=%g: before creating graph object',iG),G,connways);
			pause(0.25)
		end
		
		% The remaining lines form one or more networks and G(iG,1).ways(iw,1).connect is true for all remaining ways.
		% Search for the longest route within the network:
		if ~isempty(G(iG,1).ways)
			
			size_ways_0		= size(G(iG,1).ways,1)+1;
			while (size(G(iG,1).ways,1)>0)&&(size_ways_0~=size(G(iG,1).ways,1))
				size_ways_0		= size(G(iG,1).ways,1);
				
				% Create a graph object with directed edges:
				Weight		= -G(iG,1).L;	% negative weights:	The longest path becomes the shortest path.
				%																This is not exactly the same, but here it seems to work.
				iw				= (1:size(G(iG,1).E,1))';
				EdgeTable	= table(Weight,iw);
				GO = digraph(...
					G(iG,1).E(:,1),...		% s: source nodes
					G(iG,1).E(:,2),...		% t: target nodes
					EdgeTable);
				if testplot
					iPmax		= max(G(iG,1).E,[],"all");
					nLabels	= cell(iPmax,1);
					for i=1:iPmax
						nLabels{i,1}	= num2str(i);
					end
					hGO4		= plot(ha4,GO,'Layout','force','NodeLabel',nLabels);
					hGO4.XData=G(iG,1).P(1:iPmax,1);
					hGO4.YData=G(iG,1).P(1:iPmax,2);
				end
				
				% If the graph contains a closed path: use this path as the solution.
				if hascycles(GO)
					% The graph consists of one or more closed lines:
					% cycles			Graph cycles, returned as a cell array.
					%					Each element cycles{k} contains the nodes that belong to one of the cycles in GO.
					% edgecycles	Edges in each cycle, returned as a cell array.
					%					Each element edgecycles{k} contains the edge indices for edges in the cycle cycles{k}.
					[  ~,...						% cycles
						edgecycles]=...		% edgecycles
						allcycles(GO,'MaxNumCycles',100);
					% Search for the longest cycle:
					N_cycles		= size(edgecycles,1);
					L_cycles		= zeros(N_cycles,1);
					for i_cycle=1:N_cycles
						iw_v						= GO.Edges.iw(edgecycles{i_cycle,1},1);
						L_cycles(i_cycle,1)	= sum(G(iG,1).L(iw_v,1));
					end
					[~,i_cycle_Lmax]		= max(L_cycles);
					iw_solution_v			= GO.Edges.iw(edgecycles{i_cycle_Lmax,1},1);
				else
					% The graph does not consist of closed lines:
					% If there are starting points that occur only once in the entire network (start of open lines):
					% Start the search at the starting points of all open lines.
					InDeg		= indegree(GO);			% In -degree of vertices: number of edges with that vertex as the target.
					OutDeg	= outdegree(GO);			% Out-degree of vertices: number of edges with that vertex as the source.
					iP_start_v	= find((InDeg==0)&(OutDeg>0));
					if isempty(iP_start_v)
						% There are no open lines.
						iP_start_v			= find(OutDeg>0);
					end
					% Limit the number of loops:
					maxsize_iP_start_v	= 100;
					if size(iP_start_v,1)>maxsize_iP_start_v
						iP_start_v			= iP_start_v(1:maxsize_iP_start_v,1);
					end
					% Calculate all longest paths starting from the source nodes:
					min_D_lp		= 0;
					iw_GO_lp		= [];
					for i_iP=1:size(iP_start_v,1)
						iP_start		= iP_start_v(i_iP,1);
						[  ~,...			% TR: directed graph, that contains the longest path from source node s to all other nodes
							D,...			% D:  longest path distance
							E]=...		% E:  logical vector E that indicates whether each graph edge is in TR
							shortestpathtree(GO,iP_start,'OutputForm','cell');
						[min_D,ip_end]	= min(D);						% Target node of the longest path
						if min_D<min_D_lp
							% The current path is longer than the previous longest path:
							min_D_lp			= min_D;
							ip_end_lp		= ip_end;
							iw_GO_lp			= E{ip_end_lp,1};				% Graph edges of the longest path in GO.Edges
						end
					end
					if isempty(iw_GO_lp)
						% This should not happen:
						errormessage;
					end
					iw_solution_v		= GO.Edges.iw(iw_GO_lp);	% Graph edges of the longest path in G(iG,1).E
				end
				
				% Add the solution (closed line or longest open line) of the previous steps to connways:
				% First connect the ways of the solution only:
				connways_solution	= connect_ways([]);
				if isempty(connways.lino_max)
					lino_solution_min	= lino_new_min;
				else
					lino_solution_min	= max(connways.lino_max+1,lino_new_min);
				end
				for i_iw=1:size(iw_solution_v,1)
					iw		= iw_solution_v(i_iw,1);
					connways_solution		= connect_ways(...
						connways_solution,...						%
						[],...											% connways_merge
						G(iG,1).ways(iw,1).xy(:,1),...			% x
						G(iG,1).ways(iw,1).xy(:,2),...			% y
						iobj,...											% iobj
						lino,...											% lino
						liwi,...											% liwi
						0,...												% in
						G(iG,1).ways(iw,1).iw_v_osmdata,...		% iw_v
						G(iG,1).ir,...									% ir
						l2a,...											% l2a
						s,...												% s
						lino_solution_min,...						% lino_new_min
						G(iG,1).role,...								% role
						G(iG,1).relid,...								% relid
						G(iG,1).tag,...								% tag
						tol,...											% tol
						conn_with_rev,...								% conn_with_rev
						G(iG,1).ways(iw,1).connect);				% connect
				end
				G(iG,1).ways(iw_solution_v,:)				= [];
				G(iG,1).E(iw_solution_v,:)					= [];
				G(iG,1).L(iw_solution_v,:)					= [];
				
				% Merge the solution with the other already connected ways:
				connways=connect_ways(...							%								Defaultvalues:			required
					connways,...										% connways					-							X
					connways_solution,...							% connways_merge			[]							X
					[],...												% x							[]
					[],...												% y							[]
					[],...												% iobj						[]
					[],...												% lino						[]
					[],...												% liwi						[]
					0,...													% in							0
					0,...													% iw							0
					0,...													% ir							0
					1,...													% l2a							1
					1,...													% s							1
					1,...													% lino_new_min				1
					'outer',...											% role						'outer'
					uint64(0),...										% relid						uint64(0)
					'',...												% tag							''
					GV.tol_1,...										% tol							GV.tol_1
					conn_with_rev,...									% conn_with_rev			true						X
					true);												% connect					true
				
			end
			if testplot
				show_testplot(ha3,sprintf('iG=%g: after adding solution',iG),G,connways);
				pause(0.25)
			end
			
		end
		
		% Add the remaining ways to connways (this should not be necessary):
		for iw=1:size(G(iG,1).ways,1)
			connways		= connect_ways(...
				connways,...									%
				[],...											% connways_merge
				G(iG,1).ways(iw,1).xy(:,1),...			% x
				G(iG,1).ways(iw,1).xy(:,2),...			% y
				iobj,...											% iobj
				lino,...											% lino
				liwi,...											% liwi
				0,...												% in
				G(iG,1).ways(iw,1).iw_v_osmdata,...		% iw_v
				G(iG,1).ir,...									% ir
				l2a,...											% l2a
				s,...												% s
				lino_new_min,...								% lino_new_min
				G(iG,1).role,...								% role
				G(iG,1).relid,...								% relid
				G(iG,1).tag,...								% tag
				tol,...											% tol
				conn_with_rev,...								% conn_with_rev
				G(iG,1).ways(iw,1).connect);				% connect
		end
		
		% Now try to connect the remaining open lines with reversal:
		if (iobj>=1)&&(iobj<=size(PP.obj,1))
			if PP.obj(iobj,1).connect_ways_with_rev~=0
				conn_with_rev		= true;
			else
				conn_with_rev		= false;
			end
			connect_ways_tol	= PP.obj(iobj,1).connect_ways_tol;
		else
			conn_with_rev		= true;
			connect_ways_tol	= 0;
		end
		if conn_with_rev
			connways		= connect_ways_apply_tol(...
				connways,...						% connways
				tol,...								% tol
				conn_with_rev);					% conn_with_rev
		end
		
		% Now try to connect the remaining open lines with increased tolerance:
		if connect_ways_tol>GV.tol_1
			connways		= connect_ways_apply_tol(...
				connways,...						% connways
				connect_ways_tol,...				% tol
				conn_with_rev);					% conn_with_rev
		end
		
		test=1;
		
	end
	test=1;
	
catch ME
	errormessage('',ME);
end


% --------------------------------------------------------------------------------------------------------------------
function G=get_graph(ways)
% Input:
% ways(iw_in,1).xy						two-column matrix of vertices
% ways(iw_in,1).relid					uint64 number: OpenStreetMap dataset ID
% ways(iw_in,1).role						character array: lines with different roles are not connected
% ways(iw_in,1).tag						character array: lines with different tags  are not connected
% ways(iw_in,1).iw_osmdata				index in OSMDATA.way
% ways(iw_in,1).ir_osmdata				index in OSMDATA.relation (0: no relation)
% ways(iw_in,1).connect					connect line (true/false)
% Output:
% G(iG,1).relid
% G(iG,1).role
% G(iG,1).tag
% G(iG,1).ir
% G(iG,1).ways(iw,1).xy					two-column matrix of vertices
% G(iG,1).ways(iw,1).iw_v_osmdata	indices in OSMDATA.way
% G(iG,1).ways(iw,1).connect			connect line (true/false)
% G(iG,1).P(iP,:)							All vertices or nodes or points.
%												column 1: x-value
%												column 2: y-value
% G(iG,1).E(iw,:)							Edges of the Graph:	matrix of vertex identification numbers iP
%												row iw, column 1: ID of the first vertex (iP1) of the way iw
%												row iw, column 2: ID of the last  vertex (iP2) of the way iw
% G(iG,1).L(iw,1)							Edge lengths

% Initialization of G: Assign the first way in G:
iG											= 1;
iw											= 1;
iw_in										= 1;
G(iG,1).ways(iw,1).xy				= ways(iw_in,1).xy;
G(iG,1).ways(iw,1).iw_v_osmdata	= ways(iw_in,1).iw_osmdata;
G(iG,1).ways(iw,1).connect			= ways(iw_in,1).connect;
G(iG,1).relid							= ways(iw_in,1).relid;
G(iG,1).role							= ways(iw_in,1).role;
G(iG,1).tag								= ways(iw_in,1).tag;
G(iG,1).ir								= ways(iw_in,1).ir_osmdata;
G(iG,1).P(1,:)							= ways(iw_in,1).xy(  1,:);
G(iG,1).P(2,:)							= ways(iw_in,1).xy(end,:);
G(iG,1).E(iw,:)						= [1 2];
if size(ways(iw_in,1).xy,2)>=2
	G(iG,1).L(iw,1)					= sum(sqrt(...
		(ways(iw_in,1).xy(2:end,1)-ways(iw_in,1).xy(1:(end-1),1)).^2+...
		(ways(iw_in,1).xy(2:end,2)-ways(iw_in,1).xy(1:(end-1),2)).^2    ));
else
	G(iG,1).L(iw,1)					= 0;
end
for iw_in=2:size(ways,1)
	% Get iG:
	iG					= 1;
	while iG<=size(G,1)
		if    isequal(G(iG,1).relid,ways(iw_in,1).relid     )&&...
				strcmp( G(iG,1).role ,ways(iw_in,1).role      )&&...
				strcmp( G(iG,1).tag  ,ways(iw_in,1).tag       )&&...
				isequal(G(iG,1).ir   ,ways(iw_in,1).ir_osmdata)
			break
		end
		iG				= iG+1;
	end
	
	% Add way iw_in to G:
	if iG>size(G,1)
		% Add the way iw_in as first way in G(iG,1):
		iw											= 1;
		G(iG,1).ways(iw,1).xy				= ways(iw_in,1).xy;
		G(iG,1).ways(iw,1).iw_v_osmdata	= ways(iw_in,1).iw_osmdata;
		G(iG,1).ways(iw,1).connect			= ways(iw_in,1).connect;
		G(iG,1).relid							= ways(iw_in,1).relid;
		G(iG,1).role							= ways(iw_in,1).role;
		G(iG,1).tag								= ways(iw_in,1).tag;
		G(iG,1).ir								= ways(iw_in,1).ir_osmdata;
		G(iG,1).P(1,:)							= ways(iw_in,1).xy(  1,:);
		G(iG,1).P(2,:)							= ways(iw_in,1).xy(end,:);
		G(iG,1).E(iw,:)						= [1 2];
		if size(ways(iw_in,1).xy,2)>=2
			G(iG,1).L(iw,1)					= sum(sqrt(...
				(ways(iw_in,1).xy(2:end,1)-ways(iw_in,1).xy(1:(end-1),1)).^2+...
				(ways(iw_in,1).xy(2:end,2)-ways(iw_in,1).xy(1:(end-1),2)).^2    ));
		else
			G(iG,1).L(iw,1)					= 0;
		end
	else
		% Add the way iw_in to existing ways in G(iG,1):
		iw											= size(G(iG,1).ways,1)+1;
		G(iG,1).ways(iw,1).xy				= ways(iw_in,1).xy;
		G(iG,1).ways(iw,1).iw_v_osmdata	= ways(iw_in,1).iw_osmdata;
		G(iG,1).ways(iw,1).connect			= ways(iw_in,1).connect;
		% First vertex of the way iw_in:
		iP1				= find(...
			(ways(iw_in,1).xy(1,1)==G(iG,1).P(:,1))&...
			(ways(iw_in,1).xy(1,2)==G(iG,1).P(:,2)),1);
		if isempty(iP1)
			% New vertex:
			iP1			= size(G(iG,1).P,1)+1;
			G(iG,1).P(iP1,:)		= ways(iw_in,1).xy(1,:);
		end
		% Last vertex of the way iw_in:
		iP2				= find(...
			(ways(iw_in,1).xy(end,1)==G(iG,1).P(:,1))&...
			(ways(iw_in,1).xy(end,2)==G(iG,1).P(:,2)),1);
		if isempty(iP2)
			% New vertex:
			iP2			= size(G(iG,1).P,1)+1;
			G(iG,1).P(iP2,:)		= ways(iw_in,1).xy(end,:);
		end
		% Edges of the Graph:
		G(iG,1).E(iw,1)			= iP1;
		G(iG,1).E(iw,2)			= iP2;
		% Edge length:
		if size(ways(iw_in,1).xy,2)>=2
			G(iG,1).L(iw,1)	= sum(sqrt(...
				(ways(iw_in,1).xy(2:end,1)-ways(iw_in,1).xy(1:(end-1),1)).^2+...
				(ways(iw_in,1).xy(2:end,2)-ways(iw_in,1).xy(1:(end-1),2)).^2    ));
		else
			G(iG,1).L(iw,1)	= 0;
		end
	end
end


% --------------------------------------------------------------------------------------------------------------------
function G=connect_unbranched_lines(G)
for iG=1:size(G,1)
	for iP=1:size(G(iG,1).P,1)
		iw1		= find((G(iG,1).E(:,2)==iP));
		iw2		= find((G(iG,1).E(:,1)==iP));
		if    isscalar(iw1)              &&...
				isscalar(iw2)              &&...
				~isequal(iw1,iw2)          &&...
				G(iG,1).ways(iw1,1).connect&&...
				G(iG,1).ways(iw2,1).connect
			% The point iP connects exactly two different ways:   x----->-----x----->-----x
			%                                                          iw1    iP   iw2
			% Append way iw2 to way iw1 and delete way iw2:
			G(iG,1).ways(iw1,1).xy				= [G(iG,1).ways(iw1,1).xy;G(iG,1).ways(iw2,1).xy(2:end,:)];
			G(iG,1).ways(iw1,1).iw_v_osmdata	= unique([...
				G(iG,1).ways(iw1,1).iw_v_osmdata;...
				G(iG,1).ways(iw2,1).iw_v_osmdata]);
			if ~isequal(G(iG,1).ways(iw1,1).iw_v_osmdata,0)
				G(iG,1).ways(iw1,1).iw_v_osmdata(G(iG,1).ways(iw1,1).iw_v_osmdata==0,:)	= [];
			end
			G(iG,1).ways(iw2,:)					= [];
			G(iG,1).E(iw1,2)						= G(iG,1).E(iw2,2);
			G(iG,1).E(iw2,:)						= [];
			G(iG,1).L(iw1,1)						= G(iG,1).L(iw1,1)+G(iG,1).L(iw2,1);
			G(iG,1).L(iw2,:)						= [];
		else
			iw1		= find((G(iG,1).E(:,1)==iP));
			iw2		= find((G(iG,1).E(:,2)==iP));
			if    isscalar(iw1)              &&...
					isscalar(iw2)              &&...
					~isequal(iw1,iw2)          &&...
					G(iG,1).ways(iw1,1).connect&&...
					G(iG,1).ways(iw2,1).connect
				% The point iP connects exactly two different ways:   x----->-----x----->-----x
				%                                                          iw2    iP   iw1
				% Append way iw1 to way iw2 and delete way iw1:
				G(iG,1).ways(iw2,1).xy				= [G(iG,1).ways(iw2,1).xy;G(iG,1).ways(iw1,1).xy(2:end,:)];
				G(iG,1).ways(iw2,1).iw_v_osmdata	= unique([...
					G(iG,1).ways(iw2,1).iw_v_osmdata;...
					G(iG,1).ways(iw1,1).iw_v_osmdata]);
				if ~isequal(G(iG,1).ways(iw2,1).iw_v_osmdata,0)
					G(iG,1).ways(iw2,1).iw_v_osmdata(G(iG,1).ways(iw2,1).iw_v_osmdata==0,:)	= [];
				end
				G(iG,1).ways(iw1,:)					= [];
				G(iG,1).E(iw2,2)						= G(iG,1).E(iw1,2);
				G(iG,1).E(iw1,:)						= [];
				G(iG,1).L(iw2,1)						= G(iG,1).L(iw2,1)+G(iG,1).L(iw1,1);
				G(iG,1).L(iw1,:)						= [];
			end
		end
	end
end


% --------------------------------------------------------------------------------------------------------------------
function show_testplot(ha,title_str,G,connways)
cla(ha,'reset');
hold(ha,'on');
axis(ha,'equal');
title(ha,title_str);
linestyle_c	= {'-';'--';':';'-.'};
fontsize		= 8;
for k_area=1:size(connways.areas,1)
	poly	= polyshape(connways.areas(k_area,1).xy(2:end,1),connways.areas(k_area,1).xy(2:end,2),...
		'KeepCollinearPoints',true);
	plot(ha,poly,...
		'FaceColor',[0 0 0],'FaceAlpha',0.05,...
		'EdgeColor',[0 0 0],'EdgeAlpha',0);
end
for k_line=1:size(connways.lines,1)
	plot(ha,connways.lines(k_line,1).xy(:,1),connways.lines(k_line,1).xy(:,2),...
		'Marker','.','MarkerSize',15,...
		'LineWidth',5,'Color',[1 1 1]*0.85);
end
for iG=1:size(G,1)
	ils	= mod(iG-1,4)+1;
	for iw=1:size(G(iG,1).ways,1)
		hl=plot(ha,G(iG,1).ways(iw,1).xy(:,1),G(iG,1).ways(iw,1).xy(:,2),...
			'Marker','.','MarkerSize',15,'LineStyle',linestyle_c{ils,1});
		ht=text(ha,mean(G(iG,1).ways(iw,1).xy(1:2,1)),mean(G(iG,1).ways(iw,1).xy(1:2,2)),num2str(iw),...
			'Color',hl.Color,...
			'BackgroundColor','w',...
			'HorizontalAlignment','center',...
			'VerticalAlignment','middle',...
			'FontSize',fontsize);
	end
	if isfield(G(iG,1),'P')
		for iP=1:size(G(iG,1).P,1)
			ht=text(ha,G(iG,1).P(iP,1),G(iG,1).P(iP,2),num2str(iP),...
				'Color',[0 0 0],...
				'BackgroundColor','w',...
				'HorizontalAlignment','center',...
				'VerticalAlignment','middle',...
				'FontSize',fontsize);
		end
	end
end
display_G		= false;
if display_G
	fprintf(1,'%s   ----------------------------\n',title_str);
	for iG=1:size(G,1)
		fprintf(1,'iG= %g',iG);
		if isfield(G(iG,1),'relid')
			fprintf(1,'  ,   relid=''%s''',G(iG,1).relid);
		end
		if isfield(G(iG,1),'role')
			fprintf(1,'  ,   role=''%s''',G(iG,1).role);
		end
		if isfield(G(iG,1),'tag')
			fprintf(1,'  ,   tag=''%s''',G(iG,1).tag);
		end
		if isfield(G(iG,1),'ir')
			fprintf(1,'  ,   ir=''%s''',G(iG,1).ir);
		end
		fprintf(1,'\n');
		if isfield(G(iG,1),'P')
			P_m=[(1:size(G(iG,1).P,1))' G(iG,1).P]
		end
		if isfield(G(iG,1),'E')
			E_m=[(1:size(G(iG,1).E,1))' G(iG,1).E]
		end
		if isfield(G(iG,1),'L')
			L_m=[(1:size(G(iG,1).L,1))' G(iG,1).L]
		end
	end
end


