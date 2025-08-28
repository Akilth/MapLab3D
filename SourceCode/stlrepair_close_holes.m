function [T,no_closed_holes,h_title,P_closedholes]=...
	stlrepair_close_holes(T,testplot,plotvertno,fa_hole_max,no_e_cline_max)
% Closes holes in triangulation data.
% T						triangulation data
% no_closed_holes		number of closed holes
% h_title				testplot title object
% P_closedholes		Nx3 vector of all vertices of the margins of closed holes
% testplot				create testplot (true/false)
% plotvertno			testplot: plot vertex numbers (true/false)
% fa_hole_max			Maximum face area of holes: holes that have a larger area will not be closed.
% no_e_cline_max		Maximum number of edges at the margin of a hole: Larger holes are skipped.
%							A suitable upper limit can significantly speed up the calculation.

global GV

try
	
	% Initializations:
	no_closed_holes		= 0;
	h_title					= [];
	P_closedholes			= zeros(0,3);
	
	% Testplot:
	if testplot
		[h_title,ha,tp_patch1]		= stlrepair_show_testplot(T,plotvertno,45322553,'stlrep 3','After closing holes');
		h_title_String_0	= h_title.String;
		tp_patch2			= patch(ha,'faces',[nan nan nan nan],'vertices',T.Points,...
			'EdgeColor',[1 0 0],'FaceColor',[1 0 0],'FaceAlpha',0.075,'EdgeAlpha',1);
		tp_line2				= plot3(ha,nan,nan,nan,...
			'LineWidth',2,'LineStyle','-','Color','r',...
			'Marker','.','MarkerSize',20);
		tp_line3				= plot3(ha,nan,nan,nan,...
			'LineWidth',5,'LineStyle','-','Color','m',...
			'Marker','.','MarkerSize',30);
		no_edges_cline_hole_closed_v				= zeros(0,1);
		no_edges_cline_hole_not_closed_v			= zeros(0,1);
	end
	
	% Consider only edges that have exactly one triangle attached:
	TR							= triangulation(T.ConnectivityList,T.Points);
	E							= edges(TR);
	ID							= edgeAttachments(TR,E);
	ie_1tr_logical			= false(size(E,1),1);
	for i=1:size(ID,1)
		if isscalar(ID{i,1})
			ie_1tr_logical(i,1)	= true;
		end
	end
	ie_1tr	= find(ie_1tr_logical);
	i_ie_1tr	= 0;
	
	% Start with the first open edge E(ie_start,1) and search in both directions for connected open edges.
	% If connected open edges are found, the vertex identifications numbers are save in the structure "closed_lines".
	% If the connected open edges do not form a closed line, the result is not applied.
	% In the next step, the area between the smallest hole is filled with triangles and added to the triangulation
	% data. Then the process is restarted until no more holes are detected.
	closed_lines_sorted	= struct('ie_cline',[],'ip_cline',[]);
	while i_ie_1tr<=(size(ie_1tr,1)-1)
		closed_lines_sorted_lasttry	= closed_lines_sorted;
		
		% Recursive search for holes starting from the edge E(ie_start,:):
		i_ie_1tr	= i_ie_1tr+1;
		ie_start		= ie_1tr(i_ie_1tr,1);
		% if testplot
		% 	disp('---------------------------------------------------------------------');
		% 	fprintf(1,'ie_start     = %1.0f (%1.0f/%1.0f)\n',ie_start,i_ie_1tr,size(ie_1tr,1));
		% end
		closed_lines			= struct('ie_cline',[],'ip_cline',[]);
		closed_lines(1,:)		= [];
		ip_start1				= E(ie_start,1);
		closed_lines			= stlrepair_search_for_closed_lines_recursion(...	% recursive search for holes: forward
			E,...
			ie_1tr_logical,...
			[],...					% ie_3tr_logical
			1,...						% nmin_e_1tr
			0,...						% nmin_e_3tr
			ie_start,...
			ip_start1,...
			closed_lines);
		ip_start2				= E(ie_start,2);
		closed_lines			= stlrepair_search_for_closed_lines_recursion(...	% recursive search for holes: backwards
			E,...
			ie_1tr_logical,...
			[],...					% ie_3tr_logical
			1,...						% nmin_e_1tr
			0,...						% nmin_e_3tr
			ie_start,...
			ip_start2,...
			closed_lines);
		
		% To prevent the same calculation being performed several times:
		% Compare closed_lines_sorted with the last value of closed_lines_sorted.
		closed_lines_sorted		= struct('ie_cline',[],'ip_cline',[]);
		no_edges						= zeros(size(closed_lines,1),1);
		for i=1:size(closed_lines,1)
			no_edges(i,1)								= size(closed_lines(i,1).ie_cline,1);
			closed_lines_sorted(i,1).ie_cline	= sort(closed_lines(i,1).ie_cline);
			closed_lines_sorted(i,1).ip_cline	= sort(closed_lines(i,1).ip_cline);
		end
		[~,i_no_edges]				= sort(no_edges);
		closed_lines_sorted		= closed_lines_sorted(i_no_edges,:);
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
			status					= 0;
			while (i_closed_lines<=size(i_closed_lines_v,1))&&(status==0)
				i_smallest_closed_line	= i_closed_lines_v(i_closed_lines,1);
				
				% Indices of the open edges in E of the smallest closed line:
				E_cline			= E(closed_lines(i_smallest_closed_line,1).ie_cline,:);
				
				% Testplot:
				if testplot
					i						= 1;
					xdata					= [T.Points(E_cline(i,1),1);T.Points(E_cline(i,2),1)];
					ydata					= [T.Points(E_cline(i,1),2);T.Points(E_cline(i,2),2)];
					zdata					= [T.Points(E_cline(i,1),3);T.Points(E_cline(i,2),3)];
					for i=2:size(E_cline,1)
						xdata					= [xdata;nan;T.Points(E_cline(i,1),1);T.Points(E_cline(i,2),1)];
						ydata					= [ydata;nan;T.Points(E_cline(i,1),2);T.Points(E_cline(i,2),2)];
						zdata					= [zdata;nan;T.Points(E_cline(i,1),3);T.Points(E_cline(i,2),3)];
					end
					% Closed line:
					tp_line2.XData	= xdata;
					tp_line2.YData	= ydata;
					tp_line2.ZData	= zdata;
					% Start edge:
					tp_line3.XData	= [T.Points(E(ie_start,1),1);T.Points(E(ie_start,2),1)];
					tp_line3.YData	= [T.Points(E(ie_start,1),2);T.Points(E(ie_start,2),2)];
					tp_line3.ZData	= [T.Points(E(ie_start,1),3);T.Points(E(ie_start,2),3)];
				end
				
				% Close the hole within the closed line E_cline:
				if size(E_cline,1)<=no_e_cline_max
					[T,CL_hole,status,facearea]	= stlrepair_close_single_hole(T,E,E_cline,fa_hole_max);
					facearea_str		= sprintf('%g mm^2',facearea);
				else
					% The number of edges at the margin of a hole is greater than the maximum number: Skip the hole:
					status				= 0;
					facearea_str		= '?';
				end
				
				if status==0
					% Closing the hole was not successful: try the next closed line:
					i_closed_lines		= i_closed_lines+1;
					if testplot
						h_title.String		= sprintf('%s\nhole not closed\nfacearea = %s\nno_e_cline = %g',...
							h_title_String_0,facearea_str,size(E_cline,1));
						no_edges_cline_hole_not_closed_v(end+1,1)		= size(E_cline,1);
						drawnow;
						setbreakpoint=1;
					end
					
					% All edges of the current closed line should no longer be used as start edges E(ie_start,:)
					% for the search for closed lines
					% Otherwise the outer while loop can take a very long time if the hole is very large.
					% This is the case when the function is applied to the triangulation data of the top sides,
					% to improve the calculation in get_T_margin.
					% In the current vector ie_1tr, delete all indices that are part of:
					ie_1tr_delete		= false(size(ie_1tr,1),1);
					imax					= size(closed_lines(i_smallest_closed_line,1).ie_cline,1);
					for i=1:imax
						ie_1tr_delete(closed_lines(i_smallest_closed_line,1).ie_cline(i,1)==ie_1tr)	= true;
					end
					ie_1tr(ie_1tr_delete)	=  [];
					% Start the search for closed lines in the remaining starting edges at the beginning again:
					i_ie_1tr						= 0;
					
					% Note:
					% This works until a hole is closed and E and ie_1tr are recalculated.
					% Then an attempt is made again to close the large holes.
					% It would be better not to collect the indices in E, but the non-working starting edges
					% (E_not_working) and exclude them from the next recalculation of E.
					
				else
					% Closing the hole was successful:
					no_closed_holes		= no_closed_holes+1;
					if testplot
						h_title.String		= sprintf('%s\nhole closed\nfacearea = %s\nno_e_cline = %g',...
							h_title_String_0,facearea_str,size(E_cline,1));
						F=[CL_hole(:,1) ...
							CL_hole(:,2) ...
							CL_hole(:,3) ...
							CL_hole(:,1)];
						tp_patch2.Faces	= F;
						no_edges_cline_hole_closed_v(end+1,1)		= size(E_cline,1);
						drawnow;
						setbreakpoint=1;
					end
					
					% Collect the vertices at the margin of the closed hole:
					P_closedholes	= [P_closedholes;T.Points(unique([CL_hole(:,1);CL_hole(:,2);CL_hole(:,3)]),:)];
					P_closedholes	= uniquetol(P_closedholes,GV.tol_1/10,'ByRows',true);
					
					% Simplify T:
					% Delete triangles that contain identical vertices:
					T	= triangulation_delete_empty_triangles(T);
					% Delete idential triangles, with different sorting of the vertices:
					T	= triangulation_delete_identical_triangles(T);
					% Delete points that are not referenced by the triangulation:
					[T,~]	= triangulation_delete_not_referenced_points(T);
					
					% Recalculate the edges and restart:
					TR							= triangulation(T.ConnectivityList,T.Points);
					E							= edges(TR);
					ID							= edgeAttachments(TR,E);
					ie_1tr_logical			= false(size(E,1),1);
					for i=1:size(ID,1)
						if isscalar(ID{i,1})
							ie_1tr_logical(i,1)	= true;
						end
					end
					ie_1tr	= find(ie_1tr_logical);
					i_ie_1tr	= 0;
					
				end
				
				setbreakpoint=1;
			end
			
		end
		
	end
	
	if testplot
		h_title.String		= h_title_String_0;
		F=[T.ConnectivityList(:,1) ...
			T.ConnectivityList(:,2) ...
			T.ConnectivityList(:,3) ...
			T.ConnectivityList(:,1)];
		tp_patch1.Faces	= F;
		tp_patch2.Faces	= [nan nan nan nan];
		tp_line2.XData		= nan;
		tp_line2.YData		= nan;
		tp_line2.ZData		= nan;
		tp_line3.XData		= nan;
		tp_line3.YData		= nan;
		tp_line3.ZData		= nan;
		% no_edges_cline_hole_closed_v
		% no_edges_cline_hole_not_closed_v
		% no_edges_cline_hole_closed_v_max			= max(no_edges_cline_hole_closed_v)
		% no_edges_cline_hole_not_closed_v_min	= min(no_edges_cline_hole_not_closed_v)
	end
	
	setbreakpoint=1;
	
catch ME
	errormessage('',ME);
end

