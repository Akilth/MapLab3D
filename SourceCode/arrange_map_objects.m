function arrange_map_objects(imapobj_new_v,imapobj_old_v)
% Changes the position of elements in MAP_OBJECTS.
%
% 1)	Change the position of a group of map objects:
%		imapobj_new_v		imapobj_new_v has one element
%		imapobj_old_v		vector of consecutive indices in MAP_OBJECTS
%								The elements imapobj_old_v are inserted at top of the element imapobj_new_v.
%		Syntax:				arrange_map_objects(42,[50;51,52]);
%
% 2)	Change the position of all map objects:
%		The size of imapobj_new_v is equal to the size of MAP_OBJECTS:
%		Syntax:				arrange_map_objects((size(MAP_OBJECTS,1):-1:1)',[]);
%
% 3)	Reorder all map objects automatically to default positions (sort map objects by object priority):
%		Syntax:				arrange_map_objects;

global GV_H MAP_OBJECTS

try

	% Display state:
	stateisbusy	= display_on_gui('state','','isbusy');
	if ~stateisbusy
		display_on_gui('state','','busy');
	end

	% Initializations:
	imapobj_max			= size(MAP_OBJECTS,1);
	ax_2dmap_Children	= GV_H.ax_2dmap.Children;		% using a local variable is much faster!

	% Reorder all map objects automatically to default positions:
	if nargin==0

		% Map object filtering:
		iobj_v			= -1*ones(imapobj_max,1);
		color_no_v		= -1*ones(imapobj_max,1);
		prio_v			= -1*ones(imapobj_max,1);
		cnuc_v			= -1*ones(imapobj_max,1);
		cncl_v			= -1*ones(imapobj_max,1);
		ispoly_v			= false(imapobj_max,1);
		isarea_v			= false(imapobj_max,1);
		isline_v			= false(imapobj_max,1);
		issymbol_v		= false(imapobj_max,1);
		istext_v			= false(imapobj_max,1);
		isconnline_v	= false(imapobj_max,1);
		for imapobj=1:imapobj_max
			iobj_v(imapobj,1)		= MAP_OBJECTS(imapobj,1).iobj;
			cnuc_v(imapobj,1)		= MAP_OBJECTS(imapobj,1).cnuc;
			cncl_v(imapobj,1)		= MAP_OBJECTS(imapobj,1).cncl;
			switch MAP_OBJECTS(imapobj,1).disp
				case 'area'
					isarea_v(imapobj,1)		= true;
				case 'line'
					isline_v(imapobj,1)		= true;
				case 'text'
					istext_v(imapobj,1)		= true;
				case 'symbol'
					issymbol_v(imapobj,1)	= true;
				case 'connection line'
					isconnline_v(imapobj,1)	= true;
			end
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				ispoly_v(imapobj,1)			= strcmp(MAP_OBJECTS(imapobj,1).h(i,1).Type,'polygon');
				ud		= MAP_OBJECTS(imapobj,1).h(i,1).UserData;
				if isfield(ud,'color_no')
					color_no_v(imapobj,1)	= ud.color_no;
				end
				if isfield(ud,'prio')
					prio_v(imapobj,1)			= max(prio_v(imapobj,1),ud.prio);
				end
			end
		end
		color_no_max				= max(color_no_v);
		issorted_v					= false(imapobj_max,1);
		imapobj_sort				= [];
		[~,imapobj_sort_prio_v]	= sort(prio_v);

		% Connection lines have the priority of the text background.
		% Set the priority of connection lines equal to the priority of the texts,
		% so that the connection lines can be displayed above texts:
		prio_v(isconnline_v)		= ceil(prio_v(isconnline_v));

		% 1) United equal colors and cutting lines: sorted by color number:
		%    - united equal colors:			cncl==0 and cnuc~=0
		%    - cutting lines:					cncl~=0 and cnuc==0
		%    - previewcutting lines:			cncl~=0 and cnuc==0
		for colno=1:color_no_max
			% united equal colors:
			imapobj_v	= find(...
				~issorted_v        &...
				(color_no_v==colno)&...
				(cnuc_v~=0)        &...
				(cncl_v==0)            );
			imapobj_sort				= [imapobj_sort;imapobj_v];
			issorted_v(imapobj_v,1)	= true;
			% cutting lines:
			imapobj_v	= find(...
				~issorted_v        &...
				ispoly_v           &...
				(color_no_v==colno)&...
				(cnuc_v==0)        &...
				(cncl_v~=0)            );
			imapobj_sort				= [imapobj_sort;imapobj_v];
			issorted_v(imapobj_v,1)	= true;
			% preview cutting lines:
			imapobj_v	= find(...
				~issorted_v        &...
				~ispoly_v          &...
				(color_no_v==colno)&...
				(cnuc_v==0)        &...
				(cncl_v~=0)            );
			imapobj_sort				= [imapobj_sort;imapobj_v];
			issorted_v(imapobj_v,1)	= true;
		end

		% 2)	Map objects except the legend: sorted by object priority:
		%		- area
		%		- line
		for k=1:imapobj_max
			imapobj		= imapobj_sort_prio_v(k);
			prio			= prio_v(imapobj);
			% 	fprintf(1,'%g\n', prio_v(imapobj));
			if prio>0
				% area:
				imapobj_v	= find(...
					~issorted_v        &...
					ispoly_v           &...
					(prio_v==prio)     &...
					isarea_v           &...
					(iobj_v>0)         &...
					(cnuc_v==0)        &...
					(cncl_v==0)            );
				imapobj_sort				= [imapobj_sort;imapobj_v];
				issorted_v(imapobj_v,1)	= true;
				% line:
				imapobj_v	= find(...
					~issorted_v        &...
					ispoly_v           &...
					(prio_v==prio)     &...
					isline_v           &...
					(iobj_v>0)         &...
					(cnuc_v==0)        &...
					(cncl_v==0)            );
				imapobj_sort				= [imapobj_sort;imapobj_v];
				issorted_v(imapobj_v,1)	= true;
			end
		end

		% 3)	Map objects except the legend: sorted by object priority:
		%		- text
		%		- connection line
		%		- symbol
		for k=1:imapobj_max
			imapobj		= imapobj_sort_prio_v(k);
			prio			= prio_v(imapobj);
			if prio>0
				% text:
				imapobj_v	= find(...
					~issorted_v        &...
					ispoly_v           &...
					(prio_v==prio)     &...
					istext_v           &...
					(iobj_v>0)         &...
					(cnuc_v==0)        &...
					(cncl_v==0)            );
				imapobj_sort				= [imapobj_sort;imapobj_v];
				issorted_v(imapobj_v,1)	= true;
				% connection line:
				imapobj_v	= find(...
					~issorted_v        &...
					ispoly_v           &...
					(prio_v==prio)     &...
					isconnline_v       &...
					(iobj_v>0)         &...
					(cnuc_v==0)        &...
					(cncl_v==0)            );
				imapobj_sort				= [imapobj_sort;imapobj_v];
				issorted_v(imapobj_v,1)	= true;
				% symbol:
				imapobj_v	= find(...
					~issorted_v        &...
					ispoly_v           &...
					(prio_v==prio)     &...
					issymbol_v         &...
					(iobj_v>0)         &...
					(cnuc_v==0)        &...
					(cncl_v==0)            );
				imapobj_sort				= [imapobj_sort;imapobj_v];
				issorted_v(imapobj_v,1)	= true;
			end
		end

		% 4)	Map objects of the legend: sorted by object priority:
		for k=1:imapobj_max
			imapobj		= imapobj_sort_prio_v(k);
			prio			= prio_v(imapobj);
			if prio>0
				% text:
				imapobj_v	= find(...
					~issorted_v        &...
					ispoly_v           &...
					(prio_v==prio)     &...
					(iobj_v==0)        &...
					(cnuc_v==0)        &...
					(cncl_v==0)            );
				imapobj_sort				= [imapobj_sort;imapobj_v];
				issorted_v(imapobj_v,1)	= true;
			end
		end

		% 5)	Rest:
		%		- preview lines with object number >=0
		%		- preview lines with object number <0
		for k=1:imapobj_max
			imapobj		= imapobj_sort_prio_v(k);
			% preview lines with  object number >=0:
			imapobj_v	= find(...
				~issorted_v        &...
				(iobj_v>=0)            );
			imapobj_sort				= [imapobj_sort;imapobj_v];
			issorted_v(imapobj_v,1)	= true;
			% rest:
			imapobj_v	= find(...
				~issorted_v            );
			imapobj_sort				= [imapobj_sort;imapobj_v];
			issorted_v(imapobj_v,1)	= true;
		end

		% Reorder all map objects automatically to default positions:
		if size(imapobj_sort,1)>1
			arrange_map_objects(imapobj_sort,[]);
		end

		% Display state and return:
		if ~stateisbusy
			display_on_gui('state','','notbusy');
		end
		return

	end

	% Initializations:
	imapobj_old_v		= round(imapobj_old_v);
	imapobj_new_v		= round(imapobj_new_v);
	imapobj_new_v		= imapobj_new_v(:);
	imapobj_old_v		= imapobj_old_v(:);

	if size(imapobj_new_v,1)==1
		% Change the position of a group of map objects:

		imapobj_old_v(imapobj_old_v>imapobj_max)	= imapobj_max;
		imapobj_new_v(imapobj_new_v>(imapobj_max+1))	= imapobj_max+1;
		imapobj_old_v(imapobj_old_v<1)				= 1;
		imapobj_new_v(imapobj_new_v<1)						= 1;
		if isequal(imapobj_old_v,imapobj_new_v)
			% Display state and return:
			if ~stateisbusy
				display_on_gui('state','','notbusy');
			end
			return
		end
		if size(imapobj_new_v,1)~=1
			errormessage;
		end
		if size(imapobj_old_v,1)<1
			errormessage;
		end

		% Example:
		% imapobj_new_v=161;
		% imapobj_old=[160;162;163];
		% arrange_map_objects(imapobj_new_v,imapobj_old)
		% imapobj	ic			imapobj_old		imapobj_new_v		ic_neworder_v
		% 159			1723												1723
		% 				1722												1722
		% 				1721												1721
		% 				1720												1720
		% 160			1719		X										1719		actually imapobj=161, but 160 is deleted
		% 				1718												1718
		% 				1717												1717
		% 				1716												1716
		% 161			1715=ic_new					X					1711
		% 				1714												1710
		% 				1713												1709
		% 				1712												1708
		% 162			1711		X										1707
		% 				1710												1706
		% 				1709												1705
		% 				1708												1704
		% 163			1707		X										1715
		% 				1706												1714
		% 				1705												1713
		% 				1704												1712
		% 164			1703												1703
		% 				1702												1702
		% 				1701												1701
		% 				1700												1700
		% 				1699												1699

		% Axes children of the elements imapobj_old:
		% The higher ic, the further back on the map!
		ic_old_all_v				= zeros(0,1);
		for i_imapobj_old=1:size(imapobj_old_v,1)
			imapobj_old			= imapobj_old_v(i_imapobj_old,1);
			ic_old_v				= zeros(0,1);
			for i=1:size(MAP_OBJECTS(imapobj_old,1).h,1)
				if ishandle(MAP_OBJECTS(imapobj_old,1).h(i,1))
					if isfield(MAP_OBJECTS(imapobj_old,1).h(i,1).UserData,'source')
						for ksource=1:size(MAP_OBJECTS(imapobj_old,1).h(i,1).UserData.source,1)
							% Source: nodes, lines and areas:
							if ishandle(MAP_OBJECTS(imapobj_old,1).h(i,1).UserData.source(ksource,1).h)
								ic_old_v(end+1,1)	= find(...
									MAP_OBJECTS(imapobj_old,1).h(i,1).UserData.source(ksource,1).h==ax_2dmap_Children);
							end
						end
					end
					ic_old_v(end+1,1)	= find(MAP_OBJECTS(imapobj_old,1).h(i,1)==ax_2dmap_Children);
				end
			end
			ic_old_v_sort		= sort(unique(ic_old_v),'descend');
			ic_old_all_v		= [ic_old_all_v;ic_old_v_sort];
		end

		% New position of the axes children: undermost element of ic_new:
		if imapobj_new_v<=imapobj_max
			ic_new_v			= zeros(0,1);
			for i=1:size(MAP_OBJECTS(imapobj_new_v,1).h,1)
				if ishandle(MAP_OBJECTS(imapobj_new_v,1).h(i,1))
					if isfield(MAP_OBJECTS(imapobj_new_v,1).h(i,1).UserData,'source')
						for ksource=1:size(MAP_OBJECTS(imapobj_new_v,1).h(i,1).UserData.source,1)
							% Source: nodes, lines and areas:
							if ishandle(MAP_OBJECTS(imapobj_new_v,1).h(i,1).UserData.source(ksource,1).h)
								ic_new_v(end+1,1)	= find(...
									MAP_OBJECTS(imapobj_new_v,1).h(i,1).UserData.source(ksource,1).h==ax_2dmap_Children);
							end
						end
					end
					ic_new_v(end+1,1)	= find(MAP_OBJECTS(imapobj_new_v,1).h(i,1)==ax_2dmap_Children);
				end
			end
			ic_new					= max(ic_new_v);
		else
			% Set as last/topmost element (imapobj_new_v=imapobj_max+1).
			ic_new		= 0;
		end

		% Rearrange the axes children:
		ic_max					= size(ax_2dmap_Children,1);
		i_delete_v				= false(ic_max,1);
		i_delete_v(ic_old_all_v,:)	= true;
		ic_all_neworder_v		= [...
			(ic_max:-1:(ic_new+1))';...
			ic_old_all_v;...
			(ic_new:-1:1)'];
		i_delete_v				= [...
			i_delete_v(ic_max:-1:(ic_new+1));...
			false(size(ic_old_all_v,1),1);...
			i_delete_v(ic_new:-1:1)];
		ic_all_neworder_v(i_delete_v,:)	= [];
		ic_all_neworder_v						= ic_all_neworder_v(ic_max:-1:1);
		% test=[(ic_max:-1:1)' ic_all_neworder_v]
		ax_2dmap_Children			= ax_2dmap_Children(ic_all_neworder_v);
		GV_H.ax_2dmap.Children	= ax_2dmap_Children;
		drawnow;

		% Rearrange MAP_OBJECTS:
		imapobj_delete_v							= false(imapobj_max,1);
		imapobj_delete_v(imapobj_old_v,:)	= true;
		imapobj_neworder_v						= [...
			(1:(imapobj_new_v-1))';...
			imapobj_old_v;...
			(imapobj_new_v:imapobj_max)'];
		imapobj_delete_v						= [...
			imapobj_delete_v(1:(imapobj_new_v-1));...
			false(size(imapobj_old_v,1),1);...
			imapobj_delete_v(imapobj_new_v:imapobj_max)];
		imapobj_neworder_v(imapobj_delete_v,:)	= [];
		% test=[(1:imapobj_max)' imapobj_neworder_v]
		MAP_OBJECTS	= MAP_OBJECTS(imapobj_neworder_v);

	elseif size(imapobj_new_v,1)==imapobj_max
		% Change the position of all map objects:

		% The higher ic,      the further back on the map!
		% The lower  imapobj, the further back on the map!
		% or:
		% the lower  ic,      the further forward on the map
		% the higher imapobj, the further forward on the map
		ic_new_v				= zeros(0,1);
		ic_sorted_v			= false(size(ax_2dmap_Children,1),1);

		% Collect map objects:
		for i_imapobj_new_v=1:imapobj_max
			imapobj_new			= imapobj_new_v(i_imapobj_new_v,1);
			ic_hi_v			= [];
			prio_hi_v		= [];
			for i=1:size(MAP_OBJECTS(imapobj_new,1).h,1)
				ic_v	= find(MAP_OBJECTS(imapobj_new,1).h(i,1)==ax_2dmap_Children);
				if size(ic_v,1)==1
					if ~any(ic_new_v==ic_v)
						ic_hi_v			= [ic_v;ic_hi_v];
						ud					= MAP_OBJECTS(imapobj_new,1).h(i,1).UserData;
						if isfield(ud,'prio')
							prio_hi_v	= [ud.prio;prio_hi_v];
						else
							prio_hi_v	= [0;prio_hi_v];
						end
					end
				end
			end
			if ~isempty(ic_hi_v)
				% Sort elements of a group by object priority:
				[~,isort]					= sort(prio_hi_v,'descend');
				ic_hi_v						= ic_hi_v(isort);
				ic_new_v						= [ic_hi_v;ic_new_v];
				ic_sorted_v(ic_hi_v,1)	= true;
			end
		end

		% Collect source objects (set on top of the map objects):
		for i_imapobj_new_v=1:imapobj_max
			imapobj_new			= imapobj_new_v(i_imapobj_new_v,1);
			for i=1:size(MAP_OBJECTS(imapobj_new,1).h,1)
				if ishandle(MAP_OBJECTS(imapobj_new,1).h(i,1))
					if isfield(MAP_OBJECTS(imapobj_new,1).h(i,1).UserData,'source')
						for ksource=1:size(MAP_OBJECTS(imapobj_new,1).h(i,1).UserData.source,1)
							% Source: nodes, lines and areas:
							if ishandle(MAP_OBJECTS(imapobj_new,1).h(i,1).UserData.source(ksource,1).h)
								ic_v	= find(...
									MAP_OBJECTS(imapobj_new,1).h(i,1).UserData.source(ksource,1).h==ax_2dmap_Children);
								if size(ic_v,1)==1
									if ~any(ic_new_v==ic_v)
										ic_new_v					= [ic_v;ic_new_v];
										ic_sorted_v(ic_v,1)	= true;
									end
								end
							end
						end
					end
				end
			end
		end

		% Set the rest of the axes children to the back of the map (frame, OSM-limits, ...):
		ic_new_v					= [ic_new_v;find(~ic_sorted_v)];

		% Rearrange the axes children:
		if ~isequal(size(ic_new_v),size(ax_2dmap_Children))
			errormessage;
		end
		ax_2dmap_Children			= ax_2dmap_Children(ic_new_v);
		GV_H.ax_2dmap.Children	= ax_2dmap_Children;
		drawnow;

		% Rearrange MAP_OBJECTS:
		MAP_OBJECTS	= MAP_OBJECTS(imapobj_new_v);

	end

	% Set imapobj in the userdata:
	for imapobj=1:imapobj_max
		for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
			if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'imapobj')
				MAP_OBJECTS(imapobj,1).h(i,1).UserData.imapobj	= imapobj;
			end
		end
	end

	% Update MAP_OBJECTS_TABLE:
	display_map_objects;

	% Display state:
	if ~stateisbusy
		display_on_gui('state','','notbusy');
	end

catch ME
	errormessage('',ME);
end

