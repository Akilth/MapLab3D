function connways=connect_ways(connways,connways_merge,x,y,iobj,lino,liwi,l2a,s,lino_new_min,role,norel,tag,tol)
% Adds the ways defined by the x-coordinates and the y-coordinates contained in the vectors x and y to already
% existing ways. Ways with the same start and end points are connected.
%
% Inputs:
% 1)	connways				structure (see below), contains connected ways, will be extended by x and y
% 2)	connways_merge		will be added to connways
% 3)	x						x-values of the new way
% 4)	y						y-values of the new way
% 5)	iobj					object number of the new way
% 6)	lino					line number, for identification when lines of different object numbers are mixed
% 7)	liwi					line width of the new way
% 8)	l2a					l2a=1:	If the start and end points of one connected way are equal, this way is stored
%											as area (default).
%								l2a=0:	a closed way will not be stored as area.
% 9)	s						Scale all data in connways by s
% 10)	lino_new_min		The numbering of new lines in connways begins with this number.
% 11) role					Function of a member in a multipolygon relation:
%								'outer':	Way forms an outer part of a multipolygon relation and default value of areas.
%								'inner':	Way forms an inner part of a multipolygon relation.
% 12) norel					number of the relation
%								The areas must be plotted sorted by the number of the relation.
% 13) tag					character array: Lines with different tags are not connected, but saved separatly.
% 14)	tol					Maximum distance at which the start and end points of two lines are connected.
%
% Output:
% The field .xy has 5 columns:
% 													column 1: x-values
%													column 2: y-values
%													column 3: iobj: object number (when connecting lines of different objects)
%													column 4: lino: line number   (counted up every time a new way is added)
%													column 5: liwi: line width    (when connecting lines with different widths)
% connways.nodes.xy							nodes: all single points [x,y]
%													There are no nodes: connways.nodes=[]
% connways.lines(k_line,1).xy				lines: set of ways, that have the same start- and endpoint
%													There are no lines: connways.lines=[]
% connways.xy_start(k_line,:)				corresponding start points as one vector: [x(1)   y(1)  ]
% connways.xy_end(k_line,:)				corresponding end   points as one vector: [x(end) y(end)]
% connways.lino_max							maximum line number in connways.lines(:,1).xy(:,4)
% connways.areas(k_area,1).xy				areas: set of closed ways
%													There are no areas: connways.areas=[]
% connways.lines_role(k_line,1)			lines: role (in case the line is closed later):
%													1:		outer
%													0:		inner
% connways.areas_role(k_area,1)			areas: role:
%													1:		outer
%													0:		inner
% connways.nodes_norel(k_node,1)			nodes: number of the relation
%													0:		The node does not belong to a relation
% connways.lines_norel(k_line,1)			lines: number of the relation
%													0:		The line does not belong to a relation
% connways.areas_norel(k_area,1)			areas: number of the relation
%													0:		The area does not belong to a relation
% connways.lines(k_line,:).tag			tags of lines and
% connways.areas(k_area,1).tag			tags of areas: objects with equal tags:
%													defined in:		PP.obj(iobj,1).filter_by_key.incltagkey
%													calculated in:	filter_objecttags: values of object_eqtags
%													added in:		plotosmdata_getdata_filterout
%													='':				no incltagkey has been defined
%													Lines with different tags will not get connected.
%
% Syntax, e.g.:
% connways=connect_ways([]);																	Initialization of connways
% connways=connect_ways(connways,connways_merge);										Merge two structures connways
% connways=connect_ways(connways,[]            ,x ,y);								Add a way to connways
% connways=connect_ways(connways,[]            ,x ,y ,iobj,lino,liwi);			Add a way to connways and add iobj,
%																										lino and liwi to
%																										connways.lines(k_line,1).xy
% connways=connect_ways(connways);															connways will not be modified
% connways=connect_ways(connways,[]            ,[],[],[]  ,[]  ,[]  ,[],s);	Scale all data in connways by s

global PP GV

try

	% Initialization of the structure connways:
	if isempty(connways)
		connways.nodes			= [];
		connways.nodes_norel	= [];
		connways.lines			= [];
		connways.lines_role	= [];
		connways.lines_norel	= [];
		connways.xy_start		= [];
		connways.xy_end		= [];
		connways.lino_max		= [];
		connways.areas			= [];
		connways.areas_role	= [];
		connways.areas_norel	= [];
		if nargin==1
			return
		end
	end

	% Default values:
	if nargin<1
		errormessage;
	end
	if nargin<2
		connways_merge	= [];
	end
	if nargin<3
		x	= [];
	end
	if nargin<4
		y	= [];
	end
	if nargin<5
		iobj	= [];
	end
	if nargin<6
		lino	= [];
	end
	if nargin<7
		liwi	= [];
	end
	if nargin<8
		l2a	= 1;
	else
		if isempty(l2a)
			l2a	= 1;
		end
	end
	if nargin<9
		s		= 1;
	else
		if isempty(s)
			s		= 1;
		end
	end
	if nargin<10
		lino_new_min	= 1;
	else
		if isempty(lino_new_min)
			lino_new_min	= 1;
		end
	end
	if nargin<11
		role	= 'outer';
	else
		if isempty(role)
			role	= 'outer';
		end
	end
	if nargin<12
		norel	= 0;
	else
		if isempty(norel)
			norel	= 0;
		end
	end
	if nargin<13
		tag		= '';
	else
		if isempty(tag)
			tag		= '';
		end
	end
	if nargin<14
		tol	= GV.tol_1;
	end

	% Scale all data in connways:
	if s~=1
		% Calculate the reference point x0,y0:
		[x0,y0]									= connways_center(iobj,connways);
		% Scale all data in connways with respect to x0,y0:
		if ~isempty(connways.nodes)
			connways.nodes.xy(:,1)			= s*(connways.nodes.xy(:,1)     -x0)+x0;
			connways.nodes.xy(:,2)			= s*(connways.nodes.xy(:,2)     -y0)+y0;
		end
		for k=1:size(connways.lines,1)
			connways.lines(k,1).xy(:,1)	= s*(connways.lines(k,1).xy(:,1)-x0)+x0;
			connways.lines(k,1).xy(:,2)	= s*(connways.lines(k,1).xy(:,2)-y0)+y0;
			connways.xy_start(k,:)			= connways.lines(k,1).xy(1,:);
			connways.xy_end(k,:)				= connways.lines(k,1).xy(end,:);
		end
		for k=1:size(connways.areas,1)
			connways.areas(k,1).xy(:,1)	= s*(connways.areas(k,1).xy(:,1)-x0)+x0;
			connways.areas(k,1).xy(:,2)	= s*(connways.areas(k,1).xy(:,2)-y0)+y0;
		end
	end

	% Merge the structure connways_merge with connways:
	if (nargin>2)&&~isempty(connways)&&~isempty(connways_merge)
		errormessage;
	end
	if ~isempty(connways_merge)
		% Plausibility check:
		connways_lino_max	= zeros(size(PP.obj,1),1);
		for k=1:size(connways.lines,1)
			iobj_v	= unique(connways.lines(k,1).xy(:,3));
			for i_iobj=1:length(iobj_v)
				kobj	= iobj_v(i_iobj);
				connways_lino_max(kobj,1)	= max(...
					connways_lino_max(kobj,1),...
					max(connways.lines(k,1).xy(:,4)));
			end
		end
		connways_merge_lino_min	= ones(size(PP.obj,1),1)*1e10;
		for k=1:size(connways_merge.lines,1)
			iobj_v	= unique(connways_merge.lines(k,1).xy(:,3));
			for i_iobj=1:length(iobj_v)
				kobj	= iobj_v(i_iobj);
				connways_merge_lino_min(kobj,1)	= min(...
					connways_merge_lino_min(kobj,1),...
					min(connways_merge.lines(k,1).xy(:,4)));
			end
		end
		for kobj=1:size(PP.obj,1)
			if connways_merge_lino_min(kobj,1)<connways_lino_max(kobj,1)
				errormessage;
			end
		end
		% Merge:
		if ~isempty(connways_merge.nodes)
			if size(connways.nodes,1)==0
				connways.nodes				= connways_merge.nodes;
				connways.nodes_norel		= connways_merge.nodes_norel;
			else
				connways.nodes.xy			= [connways.nodes.xy   ;connways_merge.nodes.xy   ];
				connways.nodes_norel		= [connways.nodes_norel;connways_merge.nodes_norel];
			end
		end
		for k=1:size(connways_merge.lines,1)
			% Do not change the line numbers when merging two structures!
			connways		= connect_ways(connways,[],...
				connways_merge.lines(k,1).xy(:,1),...							% x
				connways_merge.lines(k,1).xy(:,2),...							% y
				connways_merge.lines(k,1).xy(:,3),...							% iobj
				connways_merge.lines(k,1).xy(:,4),...							% lino
				connways_merge.lines(k,1).xy(:,5),...							% liwi
				l2a,...																	% l2a
				[],...																	% s
				[],...																	% lino_new_min
				connways_merge.lines_role(k,1),...								% role
				connways_merge.lines_norel(k,1),...								% norel
				connways_merge.lines(k,1).tag);									% tag
		end
		if size(connways.lino_max,1)==0
			connways.lino_max		= connways_merge.lino_max;
		else
			connways.lino_max		= max(connways.lino_max,connways_merge.lino_max);
		end
		for k=1:size(connways_merge.areas,1)
			k_new										= size(connways.areas,1)+1;
			connways.areas(k_new,1).xy			= connways_merge.areas(k,1).xy;
			connways.areas(k_new,1).tag		= connways_merge.areas(k,1).tag;
			connways.areas_role(k_new,1)		= connways_merge.areas_role(k,1);
			connways.areas_norel(k_new,1)		= connways_merge.areas_norel(k,1);
		end
	end

	% Add the new way [x y] to connways:
	if ~isempty(x)
		if ~isequal(size(x),size(y))
			errormessage;
		end
		x		= x(:);
		y		= y(:);
		iobj	= iobj(:);
		lino	= lino(:);
		liwi	= liwi(:);
		if isempty(iobj)
			iobj	= zeros(size(x));
		end
		if length(iobj)==1
			iobj	= ones(size(x))*iobj;
		end
		if isempty(liwi)
			liwi	= zeros(size(x));
		end
		if length(liwi)==1
			liwi	= ones(size(x))*liwi;
		end
		if size(x,1)==1
			% The data consists of only one node:
			if isempty(lino)
				lino	= zeros(size(x));
			end
			if length(lino)==1
				lino	= ones(size(x))*lino;
			end
			if isempty(connways.nodes)
				connways.nodes.xy			= [x y iobj lino liwi];
				connways.nodes_norel		= norel;
			else
				connways.nodes.xy			= [connways.nodes.xy   ;x y iobj lino liwi];
				connways.nodes_norel		= [connways.nodes_norel;norel             ];
			end

		else
			% The data has more than one node:

			% % % 		% Check whether the new way has intersections points with existing lines:
			% % % 		x1	= connways.lines(k1,1).xy(:,1);
			% % % 		y1	= connways.lines(k1,1).xy(:,2);
			% % % 		x2	= connways.lines(k2,1).xy(:,1);
			% % % 		y2	= connways.lines(k2,1).xy(:,2);
			% % %
			% % %
			% % % 		for k=1:size(connways.lines,1)
			% % % 			[xi,yi,ii] = polyxpoly(...
			% % % 				connways.lines(k,1).xy(:,1),connways.lines(k,1).xy(:,2),...		% x1,y1
			% % % 				x,y);																				% x2,y2
			% % % 			for xi=1:size(xi,1)
			% % %
			% % % 				% If the point is not included in connways.lines(k,1).xy: add the point to connways.lines(k,1).xy:
			% % %
			% % %
			% % %
			% % %
			% % %
			% % % % function i = isvertexmember(va,vb,tol)
			% % % % i = isvertexmember(va,vb,tol) returns an array containing logical 1 (true) where the vertices in va are found
			% % % % in vb. Elsewhere, the array contains logical 0 (false).
			% % % % i has the same number of rows as va.
			% % % % va, vb		N-by-2 matrices, where N is the number of vertices.
			% % % %				va(:,1), vb(:,1)		x-values
			% % % %				va(:,2), vb(:,2)		y-values
			% % % %				va(:,3), vb(:,3)		z-values (optional)
			% % % % tol			Tolerance
			% % %
			% % %
			% % %
			% % % 				lineout=insertvertex_line(linein,vertices,tol)
			% % %
			% % % 				connways.lines(k,1).xy
			% % %
			% % % 			end
			% % % 		end
			% % %
			% % %
			% % % 		[xi,yi,ii] = polyxpoly(x1,y1,x2,y2)
			% % %
			% % % 		wenn ii leer ist: weiter (wird als neue Linie hinzugefügt)
			% % % 		for i2=1:size(ii,1)
			% % % 			wenn der Punkt nicht in Linie 1 enthalten ist: Linie 1 hinzufügen
			% % % 			wenn der Punkt nicht in Linie 2 enthalten ist: Linie 2 hinzufügen
			% % % 			wenn der Punkt der Start- oder Endpunkt von Linie 2 ist:
			% % % 			- nichts machen
			% % % 			- ansonsten: Linie 2 an diesem Punkt auftrennen (nan)
			% % % 			alle Teilstücke von Linie 2 einzeln Linie 1 hinzufügen
			% % %
			% % %
			% % %
			% % %
			% % %
			% % %
			% % %
			% % % 		end



			% Add a line without NaNs [x y] to connways.lines(k,1).xy:
			k_con	= [];				% k_con: connected line
			kmax	= size(connways.lines,1);
			if kmax==0
				% Add the first line:
				k_con								= 1;
				if isempty(lino)
					lino	= ones(size(x))*lino_new_min;
				end
				if length(lino)==1
					lino	= ones(size(x))*lino;
				end
				connways.lines(k_con,1).xy			= [x      y      iobj lino liwi];
				connways.lines(k_con,1).tag		= tag;
				if strcmp(role,'outer')
					connways.lines_role(k_con,1)	= 1;
				else
					connways.lines_role(k_con,1)	= 0;
				end
				connways.lines_norel(k_con,1)		= norel;
				connways.xy_start(k_con,:)			= [x(1)   y(1)  ];
				connways.xy_end(k_con,:)			= [x(end) y(end)];
				connways.lino_max						= max(lino_new_min,max(lino));
			else
				% New line number:
				if isempty(lino)
					connways.lino_max	= max(connways.lino_max+1,lino_new_min);
					lino					= ones(size(x))*connways.lino_max;
				end
				if length(lino)==1
					lino	= ones(size(x))*lino;
				end
				% Connect line segments, that have the same tags:
				if isempty(k_con)
					k	= find(...
						(abs(connways.xy_end(:,1)-x(1))<tol) & ...
						(abs(connways.xy_end(:,2)-y(1))<tol)       );
					if ~isempty(k)
						% The first point of [x,y] is the last point of a previous line:
						for ik=1:length(k)
							if strcmp(connways.lines(k(ik),1).tag,tag)
								% Except at the start or end point, the lines to be connected should not touch:
								connect_lines					= true;
								if length(x)>=3
									[xi,~]		= polyxpoly(...
										connways.lines(k(ik),1).xy(:,1),...			% x1
										connways.lines(k(ik),1).xy(:,2),...			% y1
										x(2:(end-1)),...									% x2
										y(2:(end-1)));										% y2
									if ~isempty(xi)
										connect_lines			= false;
									end
								end
								if connect_lines
									% The lines do not intersect:
									k_con								= k(ik);
									connways.lines(k_con,1).xy	= [connways.lines(k_con,1).xy;[  ...
										x(2:end)    ...
										y(2:end)    ...
										iobj(2:end) ...
										lino(2:end) ...
										liwi(2:end)     ]];
									connways.xy_end(k_con,:)	= [x(end) y(end)];
									break
								end
							end
						end
					end
				end
				if isempty(k_con)
					k	= find(...
						(abs(connways.xy_start(:,1)-x(end))<tol) & ...
						(abs(connways.xy_start(:,2)-y(end))<tol)       );
					if ~isempty(k)
						% The last point of [x,y] is the first point of a previous line:
						for ik=1:length(k)
							if strcmp(connways.lines(k(ik),1).tag,tag)
								% Except at the start or end point, the lines to be connected should not touch:
								connect_lines					= true;
								if length(x)>=3
									[xi,~]		= polyxpoly(...
										connways.lines(k(ik),1).xy(:,1),...			% x1
										connways.lines(k(ik),1).xy(:,2),...			% y1
										x(2:(end-1)),...									% x2
										y(2:(end-1)));										% y2
									if ~isempty(xi)
										connect_lines			= false;
									end
								end
								if connect_lines
									% The lines do not intersect:
									k_con								= k(ik);
									connways.lines(k_con,1).xy	= [[  ...
										x(1:(end-1))    ...
										y(1:(end-1))    ...
										iobj(1:(end-1)) ...
										lino(1:(end-1)) ...
										liwi(1:(end-1))     ];connways.lines(k_con,1).xy];
									connways.xy_start(k_con,:)	= [x(1) y(1)];
									break
								end
							end
						end
					end
				end
				if isempty(k_con)
					k	= find(...
						(abs(connways.xy_end(:,1)-x(end))<tol) & ...
						(abs(connways.xy_end(:,2)-y(end))<tol)       );
					if ~isempty(k)
						% The last point of [x,y] is the last point of a previous line:
						for ik=1:length(k)
							if strcmp(connways.lines(k(ik),1).tag,tag)
								% Except at the start or end point, the lines to be connected should not touch:
								connect_lines					= true;
								if length(x)>=3
									[xi,~]		= polyxpoly(...
										connways.lines(k(ik),1).xy(:,1),...			% x1
										connways.lines(k(ik),1).xy(:,2),...			% y1
										x(2:(end-1)),...									% x2
										y(2:(end-1)));										% y2
									if ~isempty(xi)
										connect_lines			= false;
									end
								end
								if connect_lines
									% The lines do not intersect:
									k_con								= k(ik);
									connways.lines(k_con,1).xy	= [connways.lines(k_con,1).xy;[  ...
										x((end-1):-1:1)    ...
										y((end-1):-1:1)    ...
										iobj((end-1):-1:1) ...
										lino((end-1):-1:1) ...
										liwi((end-1):-1:1)     ]];
									connways.xy_end(k_con,:)	= [x(1) y(1)];
									break
								end
							end
						end
					end
				end
				if isempty(k_con)
					k	= find(...
						(abs(connways.xy_start(:,1)-x(1))<tol) & ...
						(abs(connways.xy_start(:,2)-y(1))<tol)       );
					if ~isempty(k)
						% The first point of [x,y] is the first point of a previous line:
						for ik=1:length(k)
							if strcmp(connways.lines(k(ik),1).tag,tag)
								% Except at the start or end point, the lines to be connected should not touch:
								connect_lines					= true;
								if length(x)>=3
									[xi,~]		= polyxpoly(...
										connways.lines(k(ik),1).xy(:,1),...			% x1
										connways.lines(k(ik),1).xy(:,2),...			% y1
										x(2:(end-1)),...									% x2
										y(2:(end-1)));										% y2
									if ~isempty(xi)
										connect_lines			= false;
									end
								end
								if connect_lines
									% The lines do not intersect:
									k_con								= k(ik);
									connways.lines(k_con,1).xy	= [[  ...
										x(end:-1:2)    ...
										y(end:-1:2)    ...
										iobj(end:-1:2) ...
										lino(end:-1:2) ...
										liwi(end:-1:2)     ];connways.lines(k_con,1).xy];
									connways.xy_start(k_con,:)	= [x(end) y(end)];
									break
								end
							end
						end
					end
				end

				if isempty(k_con)
					% The current way does not continue a previous way: store separatly as a new way:
					k_con										= kmax+1;
					connways.lines(k_con,1).xy			= [x      y     iobj lino liwi];
					connways.lines(k_con,1).tag		= tag;
					if strcmp(role,'outer')
						connways.lines_role(k_con,1)	= 1;
					else
						connways.lines_role(k_con,1)	= 0;
					end
					connways.lines_norel(k_con,1)		= norel;
					connways.xy_start(k_con,:)			= [x(1)   y(1)  ];
					connways.xy_end(k_con,:)			= [x(end) y(end)];
				else
					% Test whether the currently connected way touches another way that has the same tag:
					k_con2					= [];
					x							= connways.lines(k_con,1).xy(:,1);
					y							= connways.lines(k_con,1).xy(:,2);
					iobj						= connways.lines(k_con,1).xy(:,3);
					lino						= connways.lines(k_con,1).xy(:,4);
					liwi						= connways.lines(k_con,1).xy(:,5);
					excl_k_con				= true(size(connways.lines,1),1);
					excl_k_con(k_con,1)	= false;
					k_v						= (1:size(connways.lines,1))';
					if isempty(k_con2)
						k	= find(...
							(abs(connways.xy_end(:,1)-x(1))<tol) & ...
							(abs(connways.xy_end(:,2)-y(1))<tol) & excl_k_con );
						if ~isempty(k)
							% The first point of [x,y] is the last point of a previous line:
							for ik=1:length(k)
								if strcmp(connways.lines(k(ik),1).tag,tag)
									% Except at the start or end point, the lines to be connected should not touch:
									connect_lines					= true;
									if length(x)>=3
										[xi,~]		= polyxpoly(...
											connways.lines(k(ik),1).xy(:,1),...			% x1
											connways.lines(k(ik),1).xy(:,2),...			% y1
											x(2:(end-1)),...									% x2
											y(2:(end-1)));										% y2
										if ~isempty(xi)
											connect_lines			= false;
										end
									end
									if connect_lines
										% The lines do not intersect:
										k_con2								= k(ik);
										connways.lines(k_con2,1).xy	= [connways.lines(k_con2,1).xy;[  ...
											x(2:end)    ...
											y(2:end)    ...
											iobj(2:end) ...
											lino(2:end) ...
											liwi(2:end)     ]];
										connways.xy_end(k_con2,:)		= [x(end) y(end)];
										connways.lines(k_con,:)			= [];
										connways.lines_role(k_con,:)	= [];
										connways.lines_norel(k_con,:)	= [];
										connways.xy_start(k_con,:)		= [];
										connways.xy_end(k_con,:)		= [];
										k_v(k_con,:)						= [];
										k_con									= find(k_v==k_con2,1);
										break
									end
								end
							end
						end
					end
					if isempty(k_con2)
						k	= find(...
							(abs(connways.xy_start(:,1)-x(end))<tol) & ...
							(abs(connways.xy_start(:,2)-y(end))<tol) & excl_k_con );
						if ~isempty(k)
							% The last point of [x,y] is the first point of a previous line:
							for ik=1:length(k)
								if strcmp(connways.lines(k(ik),1).tag,tag)
									% Except at the start or end point, the lines to be connected should not touch:
									connect_lines					= true;
									if length(x)>=3
										[xi,~]		= polyxpoly(...
											connways.lines(k(ik),1).xy(:,1),...			% x1
											connways.lines(k(ik),1).xy(:,2),...			% y1
											x(2:(end-1)),...									% x2
											y(2:(end-1)));										% y2
										if ~isempty(xi)
											connect_lines			= false;
										end
									end
									if connect_lines
										% The lines do not intersect:
										k_con2								= k(ik);
										connways.lines(k_con2,1).xy	= [[  ...
											x(1:(end-1))    ...
											y(1:(end-1))    ...
											iobj(1:(end-1)) ...
											lino(1:(end-1)) ...
											liwi(1:(end-1))     ];connways.lines(k_con2,1).xy];
										connways.xy_start(k_con2,:)	= [x(1) y(1)];
										connways.lines(k_con,:)			= [];
										connways.lines_role(k_con,:)	= [];
										connways.lines_norel(k_con,:)	= [];
										connways.xy_start(k_con,:)		= [];
										connways.xy_end(k_con,:)		= [];
										k_v(k_con,:)						= [];
										k_con									= find(k_v==k_con2,1);
										break
									end
								end
							end
						end
					end
					if isempty(k_con2)
						k	= find(...
							(abs(connways.xy_end(:,1)-x(end))<tol) & ...
							(abs(connways.xy_end(:,2)-y(end))<tol) & excl_k_con );
						if ~isempty(k)
							% The last point of [x,y] is the last point of a previous line:
							for ik=1:length(k)
								if strcmp(connways.lines(k(ik),1).tag,tag)
									% Except at the start or end point, the lines to be connected should not touch:
									connect_lines					= true;
									if length(x)>=3
										[xi,~]		= polyxpoly(...
											connways.lines(k(ik),1).xy(:,1),...			% x1
											connways.lines(k(ik),1).xy(:,2),...			% y1
											x(2:(end-1)),...									% x2
											y(2:(end-1)));										% y2
										if ~isempty(xi)
											connect_lines			= false;
										end
									end
									if connect_lines
										% The lines do not intersect:
										k_con2								= k(ik);
										connways.lines(k_con2,1).xy	= [connways.lines(k_con2,1).xy;[  ...
											x((end-1):-1:1)    ...
											y((end-1):-1:1)    ...
											iobj((end-1):-1:1) ...
											lino((end-1):-1:1) ...
											liwi((end-1):-1:1)     ]];
										connways.xy_end(k_con2,:)		= [x(1) y(1)];
										connways.lines(k_con,:)			= [];
										connways.lines_role(k_con,:)	= [];
										connways.lines_norel(k_con,:)	= [];
										connways.xy_start(k_con,:)		= [];
										connways.xy_end(k_con,:)		= [];
										k_v(k_con,:)						= [];
										k_con									= find(k_v==k_con2,1);
										break
									end
								end
							end
						end
					end
					if isempty(k_con2)
						k	= find(...
							(abs(connways.xy_start(:,1)-x(1))<tol) & ...
							(abs(connways.xy_start(:,2)-y(1))<tol) & excl_k_con );
						if ~isempty(k)
							for ik=1:length(k)
								if strcmp(connways.lines(k(ik),1).tag,tag)
									% Except at the start or end point, the lines to be connected should not touch:
									connect_lines					= true;
									if length(x)>=3
										[xi,~]		= polyxpoly(...
											connways.lines(k(ik),1).xy(:,1),...			% x1
											connways.lines(k(ik),1).xy(:,2),...			% y1
											x(2:(end-1)),...									% x2
											y(2:(end-1)));										% y2
										if ~isempty(xi)
											connect_lines			= false;
										end
									end
									if connect_lines
										% The lines do not intersect:
										k_con2								= k(ik);
										% The first point of [x,y] is the first point of a previous line:
										connways.lines(k_con2,1).xy	= [[  ...
											x(end:-1:2)    ...
											y(end:-1:2)    ...
											iobj(end:-1:2) ...
											lino(end:-1:2) ...
											liwi(end:-1:2)     ];connways.lines(k_con2,1).xy];
										connways.xy_start(k_con2,:)	= [x(end) y(end)];
										connways.lines(k_con,:)			= [];
										connways.lines_role(k_con,:)	= [];
										connways.lines_norel(k_con,:)	= [];
										connways.xy_start(k_con,:)		= [];
										connways.xy_end(k_con,:)		= [];
										k_v(k_con,:)						= [];
										k_con									= find(k_v==k_con2,1);
										break
									end
								end
							end
						end
					end
				end

			end

			% Test whether the currently added or connected way is a closed line (area):
			if    (abs(connways.xy_start(k_con,1)-connways.xy_end(k_con,1))<tol) && ...
					(abs(connways.xy_start(k_con,2)-connways.xy_end(k_con,2))<tol)
				if l2a==1
					% Save the closed line als area:
					k_new									= size(connways.areas,1)+1;
					connways.areas(k_new,1).xy		= connways.lines(k_con,1).xy;
					connways.areas(k_new,1).tag	= connways.lines(k_con,1).tag;
					if strcmp(role,'outer')
						connways.areas_role(k_new,1)	= 1;
					else
						connways.areas_role(k_new,1)	= 0;
					end
					connways.areas_norel(k_new,1)	= norel;
					connways.lines(k_con,:)			= [];
					connways.lines_role(k_con,:)	= [];
					connways.lines_norel(k_con,:)	= [];
					connways.xy_start(k_con,:)		= [];
					connways.xy_end(k_con,:)		= [];
				end
			end

		end
	end

catch ME
	errormessage('',ME);
end

