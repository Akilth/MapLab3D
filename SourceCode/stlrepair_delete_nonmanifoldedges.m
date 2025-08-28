function T=stlrepair_delete_nonmanifoldedges(T,testplot,plotvertno)
% Remove non-manifold edges:
% Find edges that are connected to exactly one or at least three triangles and form a closed line.
% Delete all triangles within this closed line.

try

	% It is possible that the closed line is a small hole, in which case the
	% algorithm would delete all existing triangles one after the other.
	% Therefore, a termination condition is defined here.
	% It is possible that when deleting triangles, the number of edges contained in the closed line
	% initially increases before it decreases again:
	max_no_edges_ratio = 3;				% (maximum number of edges in the closed line) divided by
	%											  (number of edges at the beginning)
	% Cancel the number of triangles to be deleted becomes too large:
	max_no_triangles_ratio = 1;		% (maximum number of triangles to be deleted) divided by
	%											  (total number of triangles at the beginning)
	%											  0.02: A maximum of 2% of the structure is deleted.
	%											  1   : deactivated

	% Testing:
	testout					= false;
	plotvertno_local		= false;

	% Because triangles are deleted here, points remain that are not referenced by the triangulation.
	% Switch off warnings:
	warning('off','MATLAB:triangulation:PtsNotInTriWarnId');		% triangulation

	% Testplot:
	if testplot
		[h_title,ha,tp_patch1]		= stlrepair_show_testplot(T,plotvertno,45322554,...
			'stlrep nmg','Removing non-manifold geometries');
		tp_line2				= plot3(ha,nan,nan,nan,...
			'LineWidth',2,'LineStyle','-','Color','r',...
			'Marker','.','MarkerSize',20);
		tp_line3				= plot3(ha,nan,nan,nan,...
			'LineWidth',5,'LineStyle','-','Color','r',...
			'Marker','.','MarkerSize',30);
		tp_line4				= plot3(ha,nan,nan,nan,...
			'LineWidth',2,'LineStyle','-','Color','m',...
			'Marker','.','MarkerSize',20);
	else
		ha				= [];
		h_title		= [];
		tp_patch1	= [];
		tp_line2		= [];
		tp_line3		= [];
		tp_line4		= [];
	end

	% Consider only edges that have exactly one triangle or at least 3 triangles attached:
	TR							= triangulation(T.ConnectivityList,T.Points);
	E							= edges(TR);
	ID							= edgeAttachments(TR,E);
	ie_1tr_logical			= false(size(E,1),1);
	ie_3tr_logical			= false(size(E,1),1);
	for i=1:size(ID,1)
		if isscalar(ID{i,1})
			ie_1tr_logical(i,1)	= true;
		end
		if length(ID{i,1})>=3
			ie_3tr_logical(i,1)	= true;
		end
	end
	ie_1tr	= find(ie_1tr_logical);
	ie_3tr	= find(ie_3tr_logical);

	% Start with the first open edge E(ie_start,1) and search in both directions for connected open edges or
	% connected non-manifold edges, that have at least 3 triangles attached.
	% If connected edges are found, the vertex identifications numbers are saved in the structure "closed_lines".
	% If the connected edges do not form a closed line, the result is not applied.
	% In the next step, the triangles inside the smallest closed line are deleted.
	% Then the process is restarted until no more closed lines are detected, that consists of at least one open edge.
	no_deleted_nonmanifold_geometries	= 0;
	ie_1tr_lasttry						= [];
	ie_3tr_lasttry						= [];
	closed_lines_sorted				= struct('ie_cline',[],'ip_cline',[]);
	while (~isequal(ie_1tr,ie_1tr_lasttry)||~isequal(ie_3tr,ie_3tr_lasttry))&&(size(ie_1tr,1)>0)
		ie_1tr_lasttry						= ie_1tr;
		ie_3tr_lasttry						= ie_3tr;
		closed_lines_sorted_lasttry	= closed_lines_sorted;

		% Recursive search for closed_lines starting from the edge E(ie_start,:):
		i_ie_1tr		= 1;
		ie_start		= ie_1tr(i_ie_1tr,1);
		if testout
			disp('---------------------------------------------------------------------');
			fprintf(1,'ie_start     = %1.0f (%1.0f/%1.0f)\n',ie_start,i_ie_1tr,size(ie_1tr,1));
		end
		closed_lines			= struct('ie_cline',[],'ip_cline',[]);
		closed_lines(1,:)		= [];
		ip_start1				= E(ie_start,1);
		closed_lines			= stlrepair_search_for_closed_lines_recursion(...	% recursive search for closed lines:
			E,...																						% forward
			ie_1tr_logical,...
			ie_3tr_logical,...
			1,...						% nmin_e_1tr
			1,...						% nmin_e_3tr
			ie_start,...
			ip_start1,...
			closed_lines);
		ip_start2				= E(ie_start,2);
		closed_lines			= stlrepair_search_for_closed_lines_recursion(...	% recursive search for closed lines:
			E,...																						% backwards
			ie_1tr_logical,...
			ie_3tr_logical,...
			1,...						% nmin_e_1tr
			1,...						% nmin_e_3tr
			ie_start,...
			ip_start2,...
			closed_lines);

		% To prevent the same calculation being performed several times:
		% Compare closed_lines_sorted with the last value of closed_lines_sorted.
		closed_lines_sorted	= struct('ie_cline',[],'ip_cline',[]);
		no_edges					= zeros(size(closed_lines,1),1);
		for i=1:size(closed_lines,1)
			no_edges(i,1)								= size(closed_lines(i,1).ie_cline,1);
			closed_lines_sorted(i,1).ie_cline	= sort(closed_lines(i,1).ie_cline);
			closed_lines_sorted(i,1).ip_cline	= sort(closed_lines(i,1).ip_cline);
		end
		[~,i_no_edges]			= sort(no_edges);
		closed_lines_sorted	= closed_lines_sorted(i_no_edges,:);
		iCL_delete				= zeros(0,1);
		CL_add					= zeros(0,3);
		if ~isempty(closed_lines)&&~isequal(closed_lines_sorted,closed_lines_sorted_lasttry)
			% The structure closed_lines contains the edges that form a closed line:
			% Delete all triangles inside the closed line.
			% Start with the smallest closed line, if this is not successful try the next one:
			no_edges_smallest_closed_line	= zeros(size(closed_lines,1),1);
			for i=1:size(closed_lines,1)
				no_edges_smallest_closed_line(i,1)	= size(closed_lines(i,1).ie_cline,1);
			end
			[~,i_closed_lines_v]	= sort(no_edges_smallest_closed_line);
			i_closed_lines			= 1;
			while (i_closed_lines<=size(i_closed_lines_v,1))&&isempty(iCL_delete)&&isempty(CL_add)
				i_smallest_closed_line	= i_closed_lines_v(i_closed_lines,1);

				% Indices of the edges in E of the smallest closed line:
				E_cline					= E(closed_lines(i_smallest_closed_line,1).ie_cline,:);
				ID_cline					= edgeAttachments(TR,E_cline);

				% Delete a single non-manifold geometry inside the edges E_cline:
				iCL_delete=stlrepair_delete_single_nonmanifold_geometry(...
					T,...
					E,...
					ID,...
					E_cline,...
					ID_cline,...
					max_no_edges_ratio,...
					max_no_triangles_ratio,...
					testplot,...
					testout,...
					plotvertno,...
					plotvertno_local,...
					ha,...							% testplot=false: []
					h_title,...						% testplot=false: []
					tp_patch1,...					% testplot=false: []
					tp_line2,...					% testplot=false: []
					tp_line3,...					% testplot=false: []
					tp_line4);						% testplot=false: []

				if isempty(iCL_delete)
					% A solution has not been found:
					if i_closed_lines<size(i_closed_lines_v,1)
						% Try the next closed line:
						i_closed_lines		= i_closed_lines+1;
					else
						% All closed lines have been tried.
						% There is probably a hole in the large structure instead of a small structure to be deleted.
						% Fill the hole in the smallest closed line and delete all triangles outside the hole that are
						% onnected to the edges of the closed line that touch at least 3 triangles.

						i_closed_lines			= 1;
						i_smallest_closed_line	= i_closed_lines_v(i_closed_lines,1);

						% Indices of the edges in E of the smallest closed line:
						E_cline					= E(closed_lines(i_smallest_closed_line,1).ie_cline,:);

						% Sort the vertices in E_cline in consecutive order:
						ip_cline			= zeros(size(E_cline,1),1);
						if ~any(E_cline(1,2)==E_cline(2,:))
							E_cline(1,:)		= E_cline(1,[2 1]);
						end
						ip_cline(1,1)		= E_cline(1,1);
						for i=2:size(E_cline,1)
							if E_cline(i,1)~=E_cline(i-1,2)
								E_cline(i,:)		= E_cline(i,[2 1]);
							end
							ip_cline(i,1)		= E_cline(i,1);
						end

						% Close the hole:
						if size(ip_cline,1)==3
							% Close a hole of 3 vertices:
							CL_add		= [ip_cline(1,1) ip_cline(2,1) ip_cline(3,1)];
						elseif size(ip_cline,1)==4
							% Close a hole of 4 vertices:
							CL_add		= [ip_cline(1,1) ip_cline(2,1) ip_cline(3,1)];
							CL_add		= [CL_add;ip_cline(1,1) ip_cline(3,1) ip_cline(4,1)];
						else
							% % % % Close a greater hole:
							% % % fa_hole_max			= 1e100;
							% % % [~,CL_add,status,~]	= stlrepair_close_single_hole(T,E,E_cline,fa_hole_max);
							% % % if isempty(CL_add)||(status==0)
							% % % 	% Closing the hole was not successfull: end of the while-loop:
							% % % 	i_closed_lines		= size(i_closed_lines_v,1)+1;
							% % % end
							% % % % Maybe not reliable, therefore disabled
						end
						% End of the while-loop:
						i_closed_lines		= size(i_closed_lines_v,1)+1;

						set_breakpoint=1;
					end
				end

			end

		end

		if ~isempty(iCL_delete)||~isempty(CL_add)
			% A solution has been found:
			no_deleted_nonmanifold_geometries	= no_deleted_nonmanifold_geometries+1;

			if ~isempty(iCL_delete)
				% Delete the triangles iCL_delete:
				T.ConnectivityList(iCL_delete,:)		= [];
			elseif ~isempty(CL_add)
				% Add the triangles i_add
				T.ConnectivityList		= [T.ConnectivityList;CL_add];
			end

			% Simplify T:
			% Delete triangles that contain identical vertices:
			T	= triangulation_delete_empty_triangles(T);
			% Delete idential triangles, with different sorting of the vertices:
			T	= triangulation_delete_identical_triangles(T);
			% Delete points that are not referenced by the triangulation:
			[T,~]	= triangulation_delete_not_referenced_points(T);

			% Restart searching for non-manifold edges:
			% Consider only edges that have exactly one triangle or at least 3 triangles attached:
			TR							= triangulation(T.ConnectivityList,T.Points);
			E							= edges(TR);
			ID							= edgeAttachments(TR,E);
			ie_1tr_logical			= false(size(E,1),1);
			ie_3tr_logical			= false(size(E,1),1);
			for i=1:size(ID,1)
				if isscalar(ID{i,1})
					ie_1tr_logical(i,1)	= true;
				end
				if length(ID{i,1})>=3
					ie_3tr_logical(i,1)	= true;
				end
			end
			ie_1tr	= find(ie_1tr_logical);
			ie_3tr	= find(ie_3tr_logical);

		else
			% The deletion was not successful: Try the next open edge:
			% Delete the first element of ie_1tr, because in the next try only the first element of ie_1tr is used:
			ie_1tr(1,:)		= [];

		end

	end		% end of "while (~isequal(ie_1tr,ie_1tr_lasttry)||~isequal(ie_3tr,ie_3tr_lasttry))&&(size(ie_1tr,1)>0)"

	% Simplify T:
	% Delete triangles that contain identical vertices:
	T	= triangulation_delete_empty_triangles(T);
	% Delete idential triangles, with different sorting of the vertices:
	T	= triangulation_delete_identical_triangles(T);
	% Delete points that are not referenced by the triangulation:
	[T,~]	= triangulation_delete_not_referenced_points(T);

	% Testplot:
	if testplot
		TR							= triangulation(T.ConnectivityList,T.Points);
		E							= edges(TR);
		ID							= edgeAttachments(TR,E);
		ie_1tr_logical			= false(size(E,1),1);
		ie_3tr_logical			= false(size(E,1),1);
		for i=1:size(ID,1)
			if isscalar(ID{i,1})
				ie_1tr_logical(i,1)	= true;
			end
			if length(ID{i,1})>=3
				ie_3tr_logical(i,1)	= true;
			end
		end
		ie_1tr	= find(ie_1tr_logical);
		ie_3tr	= find(ie_3tr_logical);
		[~,ha,~]		= stlrepair_show_testplot(TR,plotvertno,45322554,'stlrep nme',...
			sprintf(['After removing non-manifold edges\n',...
			'%g non-manifold geometries removed\n',...
			'%g remaining open edges\n',...
			'%g remaining non-manifold edges'],...
			no_deleted_nonmanifold_geometries,...
			size(ie_1tr,1),...
			size(ie_3tr,1)));
		% Mark faulty edges and triangles:
		if ~isempty(ie_1tr)
			i						= 1;
			ie						= ie_1tr(i,1);
			xdata					= [T.Points(E(ie,1),1);T.Points(E(ie,2),1)];
			ydata					= [T.Points(E(ie,1),2);T.Points(E(ie,2),2)];
			zdata					= [T.Points(E(ie,1),3);T.Points(E(ie,2),3)];
			iCL_1tr				= ID{ie,1}(:);
			for i=2:size(ie_1tr,1)
				ie						= ie_1tr(i,1);
				xdata					= [xdata;nan;T.Points(E(ie,1),1);T.Points(E(ie,2),1)];
				ydata					= [ydata;nan;T.Points(E(ie,1),2);T.Points(E(ie,2),2)];
				zdata					= [zdata;nan;T.Points(E(ie,1),3);T.Points(E(ie,2),3)];
				iCL_1tr				= [iCL_1tr;ID{ie,1}(:)];
			end
			plot3(ha,xdata,ydata,zdata,...
				'LineWidth',2,'LineStyle','-','Color',[0 1 1],...			% 'c': [0 1 1]
				'Marker','.','MarkerSize',20);
			iCL_1tr		= unique(iCL_1tr);
			F=[T.ConnectivityList(iCL_1tr,1) ...
				T.ConnectivityList(iCL_1tr,2) ...
				T.ConnectivityList(iCL_1tr,3) ...
				T.ConnectivityList(iCL_1tr,1)];
			patch(ha,'faces',F,'vertices',T.Points,...
				'EdgeColor',[0 1 1],'FaceColor',[0 1 1],'FaceAlpha',0.075,'EdgeAlpha',1);
		end
		if ~isempty(ie_3tr)
			i						= 1;
			ie						= ie_3tr(i,1);
			xdata					= [T.Points(E(ie,1),1);T.Points(E(ie,2),1)];
			ydata					= [T.Points(E(ie,1),2);T.Points(E(ie,2),2)];
			zdata					= [T.Points(E(ie,1),3);T.Points(E(ie,2),3)];
			iCL_3tr				= ID{ie,1}(:);
			for i=2:size(ie_3tr,1)
				ie						= ie_3tr(i,1);
				xdata					= [xdata;nan;T.Points(E(ie,1),1);T.Points(E(ie,2),1)];
				ydata					= [ydata;nan;T.Points(E(ie,1),2);T.Points(E(ie,2),2)];
				zdata					= [zdata;nan;T.Points(E(ie,1),3);T.Points(E(ie,2),3)];
				iCL_3tr				= [iCL_3tr;ID{ie,1}(:)];
			end
			plot3(ha,xdata,ydata,zdata,...
				'LineWidth',2,'LineStyle','-','Color',[1 0 1],...			% 'm': [1 0 1]
				'Marker','.','MarkerSize',20);
			iCL_3tr		= unique(iCL_3tr);
			F=[T.ConnectivityList(iCL_3tr,1) ...
				T.ConnectivityList(iCL_3tr,2) ...
				T.ConnectivityList(iCL_3tr,3) ...
				T.ConnectivityList(iCL_3tr,1)];
			patch(ha,'faces',F,'vertices',T.Points,...
				'EdgeColor',[1 0 1],'FaceColor',[1 0 1],'FaceAlpha',0.075,'EdgeAlpha',1);
		end
		drawnow;
		setbreakpoint=1;
	end

	% Switch on the warnings:
	warning('on','MATLAB:triangulation:PtsNotInTriWarnId');		% triangulation

catch ME
	errormessage('',ME);
end

