function [TR,status]=stlrepair(TR,testplot,plotarrows)
% Repairing triangulation data for 3D printing. Only the following errors are attempted to be corrected:
% - Delete identical vertices
% - Delete triangles that contain identical vertices
% - Delete idential triangles, with different sorting of the vertices
% - Delete points that are not referenced by the triangulation
% - Fill holes
% - Remove non-manifold edges: edges that are connected to at least 3 triangles
% - Allow all surface vectors to point outwards

global GV

try
	
	% Testing:
	% global TR_STLREPAIR
	% if nargin==1
	% 	TR_STLREPAIR	= TR;
	% 	set_breakpoint	= 1;
	% end
	
	% Testing:
	plotvertno		= false;
	if nargin<3
		plotarrows	= false;
	end
	if nargin<2
		testplot		= false;
	end
	if nargin<1
		testplot		= true;
		T				= struct;
		T.Points		= [...
			0 0 0;...		% 1
			0 1 0;...		% 2
			1 0 0;...		% 3
			1 1 0;...		% 4
			0 0 1;...		% 5
			0 1 1;...		% 6
			1 0 1;...		% 7
			1 1 1;...		% 8
			1.2 0.5 1.2;...		% 9
			-0.2 0 1.2;...			% 10
			-0.2 1 1.2;...			% 11
			-0.2 0 0.2;...			% 12
			0.8  1.2 1;...			% 13
			0    0   0.5;...		% 14
			-1 -1 -1;...			% 15 not referenced point
			0.2 -0.2 0.75;...		% 16
			-2 -2 -2]*20;			% 17 not referenced point
		cl_test_no	= 2;
		switch cl_test_no
			case 1
				% This cannot be repaired completely:
				plotarrows	= true;
				plotvertno	= true;
				T.ConnectivityList	= [...		% 2 holes
					1 3 14;...
					3 5 7;...
					1 3 2;...
					2 3 4;...
					3 7 4;...
					4 7 8;...
					5 6 7;...
					6 7 13;...		% without
					7 8 13;...
					2 5 14;...
					1 2 14;...
					2 1 14;...		% double facet
					2 5 6;...
					5 6 10;...		% open edges
					6 10 11;...		% open edges
					7 8 9;...		% open edges
					1 10 14;...		% open edges
					5 10 14;...		% open edges
					1 10 12;...		% open edges
					5 14 16;...		% open edges
					5 7 16];			% open edges
				T.ConnectivityList	= [T.ConnectivityList;T.ConnectivityList+size(T.Points,1)];
				T.Points					= [T.Points          ;T.Points+[40 0 0]   ];
				TR							= triangulation(T.ConnectivityList,T.Points);
			case 2
				plotarrows	= true;
				plotvertno	= true;
				T.ConnectivityList	= [...		% 2 holes
					1 3 14;...
					3 5 7;...
					1 3 2;...
					2 3 4;...
					4 7 8;...
					5 6 7;...
					6 7 13;...		% without
					7 8 13;...
					2 5 14;...
					1 2 14;...
					2 1 14;...		% double facet
					3 5 14;...
					2 5 6;...
					5 6 10;...		% open edges
					6 10 11;...		% open edges
					7 8 9;...		% open edges
					1 10 14;...		% open edges
					5 10 14;...		% open edges
					1 10 12;...		% open edges
					5 14 16;...		% open edges
					5 7 16];			% open edges
				T.ConnectivityList	= [T.ConnectivityList;T.ConnectivityList+size(T.Points,1)];
				T.Points					= [T.Points          ;T.Points+[40 0 0]   ];
				TR							= triangulation(T.ConnectivityList,T.Points);
			case 3
				global TR_STLREPAIR_1
				plotarrows	= false;
				plotvertno	= false;
				TR		= TR_STLREPAIR_1;
		end
	end
	
	% Maximum face area of holes: Holes that have a larger area will not be closed.
	fa_hole_max				= 1e100;
	
	% Maximum number of edges at the margin of a hole: Larger holes are skipped.
	no_e_cline_max			= 100;
	
	% T: editable triangulation data:
	T							= struct;
	T.Points					= TR.Points;
	T.ConnectivityList	= TR.ConnectivityList;
	
	% Testplot:
	if testplot
		[h_title,ha,tp_patch1]		= stlrepair_show_testplot(T,plotvertno,45322551,'stlrep 1','Initial data');
	end
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Simplify, first steps:
	% - Delete identical vertices
	% - Delete triangles that contain identical vertices
	% - Delete idential triangles, with different sorting of the vertices
	% - Delete points that are not referenced by the triangulation
	
	testplot_xlimits	= [];
	testplot_ylimits	= [];
	msg					= '';
	T						= triangulation_simplify(...
		T.Points,...
		T.ConnectivityList,...
		GV.tol_tp,...
		testplot_xlimits,...
		testplot_ylimits,...
		msg);
	
	% Testplot:
	if testplot
		[~,ha,~]		= stlrepair_show_testplot(T,plotvertno,45322552,'stlrep 2','After simplification (first steps)');
	end
	
	% Get the total number of individual parts:
	no_parts_start					= stlrepair_get_no_parts(T);
	
	% Count total number of closed holes:
	no_closed_holes_total		= 0;
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Close holes:
	[T,no_closed_holes,h_title,~]	= stlrepair_close_holes(T,testplot,plotvertno,fa_hole_max,no_e_cline_max);
	if testplot
		no_closed_holes_total	= no_closed_holes_total+no_closed_holes;
		h_title.String		= sprintf('%s\n%g holes closed',h_title.String,no_closed_holes_total);
	end
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Delete folded triangles:
	% Closing holes can create folded triangles, so closing holes must be executed before and afterwards.
	
	no_deleted_folded_triangles	= 0;
	iCL_delete							= -1;
	iCL_delete_laststep				= -2;
	while ~isempty(iCL_delete)&&~isequal(iCL_delete,iCL_delete_laststep)
		iCL_delete_laststep	= iCL_delete;
		
		% Testplot:
		if testplot
			[h_title,ha,tp_patch1]		= stlrepair_show_testplot(T,plotvertno,45322555,'stlrep fe',...
				'After deleting folded edges');
			tp_patch2			= patch(ha,'faces',[nan nan nan nan],'vertices',T.Points,...
				'EdgeColor',[1 0 0],'FaceColor',[1 0 0],'FaceAlpha',0.075,'EdgeAlpha',1);
			tp_line2				= plot3(ha,nan,nan,nan,...
				'LineWidth',2,'LineStyle','-','Color','r',...
				'Marker','.','MarkerSize',20);
			tp_line3				= plot3(ha,nan,nan,nan,...
				'LineWidth',5,'LineStyle','-','Color','r',...
				'Marker','.','MarkerSize',30);
		end
		
		% Consider only edges that have exactly two triangles attached:
		TR							= triangulation(T.ConnectivityList,T.Points);
		E							= edges(TR);
		ID							= edgeAttachments(TR,E);
		iCL_delete				= zeros(0,1);
		for ie=1:size(ID,1)
			if size(ID{ie,1},2)==2
				ip1		= E(ie,1);
				iCL1		= ID{ie,1}(1,1);
				CL1		= T.ConnectivityList(iCL1,:);
				p1_CL1		= [T.Points(CL1(1,1),1) T.Points(CL1(1,1),2) T.Points(CL1(1,1),3)];
				p2_CL1		= [T.Points(CL1(1,2),1) T.Points(CL1(1,2),2) T.Points(CL1(1,2),3)];
				p3_CL1		= [T.Points(CL1(1,3),1) T.Points(CL1(1,3),2) T.Points(CL1(1,3),3)];
				F1				= cross(p2_CL1-p1_CL1,p3_CL1-p2_CL1)/2;
				F1_mag		= sqrt(sum(F1.^2));
				if F1_mag==0
					% The area of triangle CL1 is zero: delete triangle CL1:
					iCL_delete		= [iCL_delete;iCL1];
				else
					ip2		= E(ie,2);
					iCL2		= ID{ie,1}(1,2);
					CL2		= T.ConnectivityList(iCL2,:);
					if vindexrest(find(ip2==CL1)-find(ip1==CL1),3)==vindexrest(find(ip2==CL2)-find(ip1==CL2),3)
						% The order of the edges in the two triangles CL1 and CL2 is identical:
						% Reverse the order in a triangle:
						CL2		= CL2([2 1 3]);
					end
					p1_CL2		= [T.Points(CL2(1,1),1) T.Points(CL2(1,1),2) T.Points(CL2(1,1),3)];
					p2_CL2		= [T.Points(CL2(1,2),1) T.Points(CL2(1,2),2) T.Points(CL2(1,2),3)];
					p3_CL2		= [T.Points(CL2(1,3),1) T.Points(CL2(1,3),2) T.Points(CL2(1,3),3)];
					F2				= cross(p2_CL2-p1_CL2,p3_CL2-p2_CL2)/2;
					F2_mag		= sqrt(sum(F2.^2));
					if F2_mag==0
						% The area of triangle CL2 is zero: delete triangle CL2:
						iCL_delete		= [iCL_delete;iCL2];
					else
						mF2				= -F2;
						phi_F1_mF2		= acos(F1*mF2'/(sqrt(sum(F1.^2,2))*sqrt(sum(mF2.^2,2))))*180/pi;
						phi_F1_mF2_max	= 1;									% Tolerance !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						if (phi_F1_mF2<phi_F1_mF2_max)
							% The angle between F1 and -F2 is too small: Delete these two folded triangles:
							iCL_delete		= [iCL_delete;iCL1;iCL2];
							if testplot
								% disp('-------------------------')
								% ie
								% phi_F1_mF2
								% p_CL1	= [p1_CL1;p2_CL1;p3_CL1]
								% p_CL2	= [p1_CL2;p2_CL2;p3_CL2]
								% test1=F1*F2'/(sqrt(sum(F1.^2,2))*sqrt(sum(F2.^2,2)))
								% test2=sum(F1.^2,2)
								% test3=sum(F2.^2,2)
								p1_E		= [T.Points(ip1,1) T.Points(ip1,2) T.Points(ip1,3)];
								p2_E		= [T.Points(ip2,1) T.Points(ip2,2) T.Points(ip2,3)];
								tp_line3.XData					= [tp_line3.XData nan p1_E(1,1) p2_E(1,1)];
								tp_line3.YData					= [tp_line3.YData nan p1_E(1,2) p2_E(1,2)];
								tp_line3.ZData					= [tp_line3.ZData nan p1_E(1,3) p2_E(1,3)];
								drawnow;
								setbreakpoint	= 1;
							end
						end
					end
				end
			end
		end
		
		% Delete the triangles iCL_delete:
		iCL_delete	= unique(iCL_delete);
		no_deleted_folded_triangles		= no_deleted_folded_triangles+size(iCL_delete,1);
		T.ConnectivityList(iCL_delete,:)	= [];
		setbreakpoint	= 1;
		
	end
	if testplot
		h_title.String		= sprintf('%s\n%g folded triangles deleted',h_title.String,no_deleted_folded_triangles);
	end
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Close holes:
	
	[T,no_closed_holes,h_title,~]	= stlrepair_close_holes(T,testplot,plotvertno,fa_hole_max,no_e_cline_max);
	if testplot
		no_closed_holes_total	= no_closed_holes_total+no_closed_holes;
		h_title.String		= sprintf('%s\n%g holes closed',h_title.String,no_closed_holes_total);
	end
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Remove non-manifold edges:
	% Find edges that are connected to exactly one or at least three triangles and form a closed line.
	% Delete all triangles within this closed line.
	
	T	= stlrepair_delete_nonmanifoldedges(T,testplot,plotvertno);
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Sometimes a small area with open edges remains, apparently caused by an unnecessary point:
	% All triangles connected to these open edges are deleted and then the resulting hole is filled again.
	
	% All "normal" holes must be closed before this step:
	[T,no_closed_holes,h_title,~]	= stlrepair_close_holes(T,testplot,plotvertno,fa_hole_max,no_e_cline_max);
	if testplot
		no_closed_holes_total	= no_closed_holes_total+no_closed_holes;
		h_title.String		= sprintf('%s\n%g holes closed',h_title.String,no_closed_holes_total);
	end
	
	% Testplot:
	if testplot
		[h_title,ha,tp_patch1]		= stlrepair_show_testplot(T,plotvertno,45322556,...
			'stlrep 4','close the remaining small holes');
		tp_patch2			= patch(ha,'faces',[nan nan nan nan],'vertices',T.Points,...
			'EdgeColor',[1 0 0],'FaceColor',[1 0 0],'FaceAlpha',0.075,'EdgeAlpha',1);
		tp_line2				= plot3(ha,nan,nan,nan,...
			'LineWidth',2,'LineStyle','-','Color','r',...
			'Marker','.','MarkerSize',20);
		tp_line3				= plot3(ha,nan,nan,nan,...
			'LineWidth',5,'LineStyle','-','Color','r',...
			'Marker','.','MarkerSize',30);
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
	no_closed_holes		= 0;
	while i_ie_1tr<=(size(ie_1tr,1)-1)
		
		% Recursive search for holes starting from the edge E(ie_start,:):
		i_ie_1tr	= i_ie_1tr+1;
		ie_start		= ie_1tr(i_ie_1tr,1);
		if testplot
			disp('---------------------------------------------------------------------');
			fprintf(1,'ie_start     = %1.0f (%1.0f/%1.0f)\n',ie_start,i_ie_1tr,size(ie_1tr,1));
		end
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
		
		if ~isempty(closed_lines)
			% The structure closed_lines contains all open edges that form a closed line:
			% Close the smallest hole:
			
			% Find the smallest closed line:
			i_smallest_closed_line			= 1;
			no_edges_smallest_closed_line	= 1e12;
			for i=1:size(closed_lines,1)
				if size(closed_lines(i,1).ie_cline,1)<no_edges_smallest_closed_line
					i_smallest_closed_line	= i;
					no_edges_smallest_closed_line	= size(closed_lines(i,1).ie_cline,1);
				end
			end
			% Indices of the open edges in E of the smallest closed line:
			ie_cline			= closed_lines(i_smallest_closed_line,1).ie_cline;
			E_cline			= E(ie_cline,:);
			
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
				tp_line2.XData	= xdata;
				tp_line2.YData	= ydata;
				tp_line2.ZData	= zdata;
				tp_line3.XData	= [T.Points(E(ie_start,1),1);T.Points(E(ie_start,2),1)];
				tp_line3.YData	= [T.Points(E(ie_start,1),2);T.Points(E(ie_start,2),2)];
				tp_line3.ZData	= [T.Points(E(ie_start,1),3);T.Points(E(ie_start,2),3)];
			end
			
			% If there is a small closed line of open edges that have not yet been closed:
			% Delete all triangles connected to the open edges and try to close the hole again.
			% For safety reasons, the closed line is limited to 4 edges.
			if size(ie_cline,1)<=4
				
				iCL_delete	= zeros(0,1);
				for i_ie=1:size(ie_cline,1)
					iCL_delete	= [iCL_delete;ID{ie_cline(i_ie,1),1}'];
				end
				iCL_delete		= unique(iCL_delete);
				% Delete the triangles iCL_delete and close the hole:
				T0												= T;
				T.ConnectivityList(iCL_delete,:)		= [];
				[T,no_clho,~,~]			= stlrepair_close_holes(T,...
					false,...				% testplot
					plotvertno,...
					fa_hole_max,...
					no_e_cline_max);
				if no_clho==0
					% Failure:
					T					= T0;
				else
					% Success:
					no_closed_holes	= no_closed_holes+1;
					
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
				
			end
			
			setbreakpoint=1;
		end
	end
	if testplot
		h_title.String		= sprintf('%s\n%g holes closed',h_title.String,no_closed_holes);
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
	end
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% All face vectors must point outwards:
	
	% Preparation to reduce computing time: Data corresponding to T.ConnectivityList(iCL,:):
	% ID_num(ie,:)				Indices iCL of the triangles connected to the edges E.
	% CL_ie(iCL,1:3)			Indices ie of the three edges of a triangle
	%								= line numbers of the triangle iCL in ID_num
	% cID=CL_cID(iCL,1:3)	Column numbers of the triangle iCL in ID_num
	TR							= triangulation(T.ConnectivityList,T.Points);
	E							= edges(TR);
	ID							= edgeAttachments(TR,E);
	[...
		ID_num,...
		CL_ie,...
		CL_cID]=...
		stlrepair_get_triangleedges(T,ID);
	
	% Start index iCL=1:
	% Use a triangle whose edges are connected with only 2 triangles each.
	% The direction of rotation of all other triangles is initially oriented to this triangle.
	% At the end, if necessary, the direction of rotation of all triangles is corrected so that all face vectors
	% point outwards.
	no_pieces_max			= 1;
	CL_piece_no				= zeros(size(T.ConnectivityList,1),1);
	ID_piece_no				= zeros(size(ID_num,1),1);
	iCL						= 0;
	use_iCL_as_start		= false;
	while ~use_iCL_as_start||(iCL>=(size(T.ConnectivityList,1)-1))
		iCL				= iCL+1;
		use_iCL_as_start		= true;
		for k=1:3
			iek		= CL_ie(iCL,k);
			if size(ID{iek,1},2)~=2
				use_iCL_as_start		= false;
				break
			end
		end
	end
	
	CL_piece_no(iCL,1)	= no_pieces_max;		% Assign the piece number
	% The order of the vertices in E should be the same as the order of the vertices in T.ConnectivityList(iCL,:):
	ID_done					= false(size(ID_num));
	ID_done(ID_num==0)			= true;
	for i=1:3
		ie							= CL_ie(iCL,i);
		ID_piece_no(ie,1)		= no_pieces_max;		% Assign the piece number
		if (T.ConnectivityList(iCL,1)==E(ie,2))&&(T.ConnectivityList(iCL,2)==E(ie,1))
			E(ie,1)				= T.ConnectivityList(iCL,1);
			E(ie,2)				= T.ConnectivityList(iCL,2);
		else
			if (T.ConnectivityList(iCL,2)==E(ie,2))&&(T.ConnectivityList(iCL,3)==E(ie,1))
				E(ie,1)			= T.ConnectivityList(iCL,2);
				E(ie,2)			= T.ConnectivityList(iCL,3);
			else
				if (T.ConnectivityList(iCL,3)==E(ie,2))&&(T.ConnectivityList(iCL,1)==E(ie,1))
					E(ie,1)		= T.ConnectivityList(iCL,3);
					E(ie,2)		= T.ConnectivityList(iCL,1);
				end
			end
		end
		ID_done(ie,CL_cID(iCL,i))		= true;
	end
	
	% Starting from triangle iCL, define the direction of rotation of all triangles connected by an edge.
	ie2do						= 1;
	while 1<2
		
		% Find the next edge that is connected to a triangle that has already been corrected:
		cID2do		= find(~ID_done(ie2do,:),1);
		while ...							% Increase ie2do if:
				isempty(cID2do)||...		% - all triangles connected to the egde ie2do have been corrected
				~any(ID_done(ie2do,:))	% - there is no corrected triangle connected to the edge ie2do
			ie2do		= ie2do+1;			% row number in E
			if ie2do>size(ID_done,1)
				break
			end
			cID2do		= find(~ID_done(ie2do,:),1);
		end
		if ie2do>size(ID_done,1)
			[ie_notdone,~]	= find(~ID_done,1);
			if ~isempty(ie_notdone)
				% If not all edges have been processed, the STL data consists of more than one individual part.
				% Increase no_pieces_max and initialize search:
				
				no_pieces_max			= no_pieces_max+1;
				ie2do						= ie_notdone;
				iCL						= ID_num(ie2do,1);
				CL_piece_no(iCL,1)	= no_pieces_max;		% Assign the piece number
				% The order of the vertices in E should be the same as the order
				% of the vertices in T.ConnectivityList(iCL,:):
				for i=1:3
					ie							= CL_ie(iCL,i);
					ID_piece_no(ie,1)		= no_pieces_max;		% Assign the piece number
					if (T.ConnectivityList(iCL,1)==E(ie,2))&&(T.ConnectivityList(iCL,2)==E(ie,1))
						E(ie,1)				= T.ConnectivityList(iCL,1);
						E(ie,2)				= T.ConnectivityList(iCL,2);
					else
						if (T.ConnectivityList(iCL,2)==E(ie,2))&&(T.ConnectivityList(iCL,3)==E(ie,1))
							E(ie,1)			= T.ConnectivityList(iCL,2);
							E(ie,2)			= T.ConnectivityList(iCL,3);
						else
							if (T.ConnectivityList(iCL,3)==E(ie,2))&&(T.ConnectivityList(iCL,1)==E(ie,1))
								E(ie,1)		= T.ConnectivityList(iCL,3);
								E(ie,2)		= T.ConnectivityList(iCL,1);
							end
						end
					end
					ID_done(ie,CL_cID(iCL,i))		= true;
				end
				
			else
				% All edges have been processed: Finish
				break
			end
			
		else
			% Not all edges have been processed yet: continue
			
			% Index of the triangle to be corrected:
			iCL						= ID_num(ie2do,cID2do);
			CL_piece_no(iCL,1)	= no_pieces_max;		% Assign the piece number
			
			% Swap the order of the vertices in the triangle if necessary:
			% The direction of rotation in neighboring triangles must be reversed!
			if (T.ConnectivityList(iCL,1)==E(ie2do,1))&&(T.ConnectivityList(iCL,2)==E(ie2do,2))
				T.ConnectivityList(iCL,1)		= E(ie2do,2);
				T.ConnectivityList(iCL,2)		= E(ie2do,1);
			end
			if (T.ConnectivityList(iCL,2)==E(ie2do,1))&&(T.ConnectivityList(iCL,3)==E(ie2do,2))
				T.ConnectivityList(iCL,2)		= E(ie2do,2);
				T.ConnectivityList(iCL,3)		= E(ie2do,1);
			end
			if (T.ConnectivityList(iCL,3)==E(ie2do,1))&&(T.ConnectivityList(iCL,1)==E(ie2do,2))
				T.ConnectivityList(iCL,3)		= E(ie2do,2);
				T.ConnectivityList(iCL,1)		= E(ie2do,1);
			end
			
			% Treatment of the three edges connected to the current triangle iCL:
			for i=1:3
				ie							= CL_ie(iCL,i);
				ID_piece_no(ie,1)		= no_pieces_max;		% Assign the piece number
				% The order of the vertices in E(ie,:) of the edges connected to the current triangle should be the same as
				% the order of the vertices in T.ConnectivityList(iCL,:) in order to be able to determine the direction of
				% rotation of the next triangle.
				% The order of the vertices in E(ie2do,:) does not need to be adjusted because both triangles connected to
				% this edge have already been handled.
				if ie~=ie2do
					if (T.ConnectivityList(iCL,1)==E(ie,2))&&(T.ConnectivityList(iCL,2)==E(ie,1))
						E(ie,1)		= T.ConnectivityList(iCL,1);
						E(ie,2)		= T.ConnectivityList(iCL,2);
					else
						if (T.ConnectivityList(iCL,2)==E(ie,2))&&(T.ConnectivityList(iCL,3)==E(ie,1))
							E(ie,1)		= T.ConnectivityList(iCL,2);
							E(ie,2)		= T.ConnectivityList(iCL,3);
						else
							if (T.ConnectivityList(iCL,3)==E(ie,2))&&(T.ConnectivityList(iCL,1)==E(ie,1))
								E(ie,1)		= T.ConnectivityList(iCL,3);
								E(ie,2)		= T.ConnectivityList(iCL,1);
							end
						end
					end
				end
				% Mark all three edges of the current triangle in ID_done as edited:
				ID_done(ie,CL_cID(iCL,i))		= true;
				% Next step:
				% If necessary, jump back to an edge ie2do that is connected to a triangle that has not yet been processed:
				if ie<ie2do
					cID2do		= find(~ID_done(ie,:),1);
					if ~isempty(isempty(cID2do))
						ie2do			= ie;
					end
				end
			end
			
		end
		
	end
	
	% All surface vectors must point outwards:
	% Criterion: The vertex normal of the lowest point should point in the negative z direction.
	% For this, the scalar product with [0;0;-1] must be positive.
	TR							= triangulation(T.ConnectivityList,T.Points);
	V							= vertexNormal(TR);
	zmax						= max(T.Points(:,3));
	for no_piece=1:no_pieces_max
		iCL_v							= CL_piece_no==no_piece;
		ip_v							= unique([...
			T.ConnectivityList(iCL_v,1);...
			T.ConnectivityList(iCL_v,2);...
			T.ConnectivityList(iCL_v,3)    ]);
		ip_v_logical				= false(size(T.Points,1),1);
		ip_v_logical(ip_v)		= true;
		z_test						= T.Points(:,3);
		z_test(~ip_v_logical)	= zmax+1;
		[~,ip_zmin]					= min(z_test);
		if (V(ip_zmin,:)*[0;0;-1])<0
			% Reverse the direction of rotation of all triangles:
			T.ConnectivityList(iCL_v,:)		= [...
				T.ConnectivityList(iCL_v,2) ...
				T.ConnectivityList(iCL_v,1) ...
				T.ConnectivityList(iCL_v,3)];
		end
	end
	
	% Create a valid triangulation object:
	TR = triangulation(T.ConnectivityList,T.Points);
	
	% Testplot:
	if testplot&&plotarrows
		P = incenter(TR);
		F = faceNormal(TR);
		quiver3(ha,P(:,1),P(:,2),P(:,3), ...
			F(:,1),F(:,2),F(:,3),0.5,'color','r');
	end
	if testplot&&plotvertno
		V = vertexNormal(TR);
		quiver3(ha,TR.Points(:,1),TR.Points(:,2),TR.Points(:,3), ...
			V(:,1),V(:,2),V(:,3),0.5,'Color','b');
	end
	
	% Get the total number of individual parts:
	no_parts_end			= stlrepair_get_no_parts(T);
	
	% Status:
	E							= edges(TR);
	ID							= edgeAttachments(TR,E);
	ie_0tr_logical			= false(size(E,1),1);
	ie_1tr_logical			= false(size(E,1),1);
	ie_3tr_logical			= false(size(E,1),1);
	for i=1:size(ID,1)
		if isempty(ID{i,1})
			ie_0tr_logical(i,1)	= true;
		end
		if isscalar(ID{i,1})
			ie_1tr_logical(i,1)	= true;
		end
		if length(ID{i,1})>=3
			ie_3tr_logical(i,1)	= true;
		end
	end
	no_0tr	= size(find(ie_0tr_logical));
	no_1tr	= size(find(ie_1tr_logical));
	no_3tr	= size(find(ie_3tr_logical));
	if    ~any(ie_0tr_logical)&&...
			~any(ie_1tr_logical)&&...
			~any(ie_3tr_logical)&&...
			isequal(no_parts_start,no_parts_end)
		status	= 1;
	else
		status	= 0;
	end
	
	setbreakpoint=1;
	
catch ME
	errormessage('',ME);
end

