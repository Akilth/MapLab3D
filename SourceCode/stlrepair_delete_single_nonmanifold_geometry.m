function iCL_delete=stlrepair_delete_single_nonmanifold_geometry(...
	T,...
	E,...
	ID,...
	E_cline,...
	ID_cline,...
	max_no_edges_ratio,...
	max_no_triangles_ratio,...
	testplot,...					% testplot
	testout,...						% testplot
	plotvertno,...					% testplot
	plotvertno_local,...			% testplot
	ha,...							% testplot=false: []
	h_title,...						% testplot=false: []
	tp_patch1,...					% testplot=false: []
	tp_line2,...					% testplot=false: []
	tp_line3,...					% testplot=false: []
	tp_line4)						% testplot=false: []
% Delete a single non-manifold geometry inside the edges E_cline
% iCL_delete:	identification numbers of the triangles inside E_cline to be deleted
% if deleting the non-manifold geometry was not successfull, iCL_delete is empty.

try

	% Testplot:
	testplot_local		= false;

	% Initializations:
	iCL_delete			= zeros(0,1);
	E_sort				= sort(E,2);
	E_cline_sort		= sort(E_cline,2);
	E_cline_sort_0		= E_cline_sort;

	% Preparation to reduce computing time: Data corresponding to T.ConnectivityList(iCL,:):
	% ID_num(ie,:)				Indices iCL of the triangles connected to the edges E.
	% CL_ie(iCL,1:3)			Indices ie of the three edges of a triangle
	%								= line numbers of the triangle iCL in ID_num
	% cID=CL_cID(iCL,1:3)	Column numbers of the triangle iCL in ID_num
	[...
		ID_num,...
		CL_ie,...
		CL_cID]=...
		stlrepair_get_triangleedges(T,ID);

	% notr_min(ie,1)		minimum number of connected triangles to every edge
	notr_min				= zeros(size(E_sort,1),1);
	for ie_cline=1:size(E_cline_sort,1)
		if size(ID_cline{ie_cline,1},2)>=3
			% The edge E_cline_sort(ie_cline,:) has 3 connected triangles:
			ie						= (...
				(E_cline_sort(ie_cline,1)==E_sort(:,1))&...
				(E_cline_sort(ie_cline,2)==E_sort(:,2))    );
			notr_min(ie,1)		= 2;
		end
	end

	% Get the first triangle to be deleted:
	% The same code is also below.
	% ID_cline_stacked: Indices iCL of all triangles connected to the edges of the closed line E_cline.
	ID_cline_stacked		= [];
	for ie_cline=1:size(ID_cline,1)
		ID_cline_stacked		= [ID_cline_stacked;ID_cline{ie_cline,1}(:)];
	end
	% no_tr_edges_on_Ecline:	If the edge is open:
	%									Number of edges of the only adjacent triangle that lie on the closed line
	no_tr_edges_on_Ecline	= zeros(size(E_cline_sort,1),1);
	notr_cline					= zeros(size(E_cline_sort,1),1);
	notr_cline_min				= zeros(size(E_cline_sort,1),1);
	for ie_cline=1:size(ID_cline,1)
		iCL			= ID_cline{ie_cline,1};
		if isscalar(iCL)
			% The edge E_cline(i,:) is connected to only one triangle, so it is an open edge.
			% Delete the triangle that lies with most of its edges on the closed line.
			% This is the fastest way to reduce the length of the closed line.
			triangle_may_be_deleted		= true;
			for i=1:3
				ie		= CL_ie(iCL,i);			% Edge of the triangle that may need to be deleted
				if size(ID{ie,1},2)<=notr_min(ie,1)
					triangle_may_be_deleted		= false;
					break
				end
			end
			if triangle_may_be_deleted
				no_tr_edges_on_Ecline(ie_cline,1)	= length(find(iCL==ID_cline_stacked));
			end
		end
		% An edge on the closed line that was initially connected with three triangles,
		% should not become an open edge and should notbe deleted completely.
		% Calculate the number of triangles connected to each edge E_cline:
		notr_cline(ie_cline,1)	= size(iCL,2);
		% Calculation of the minimum number of triangles connected to each edge E_cline:
		ie_logical		= (...
			(E_sort(:,1)==E_cline_sort(ie_cline,1))&...
			(E_sort(:,2)==E_cline_sort(ie_cline,2))    );
		notr_cline_min(ie_cline,1)	= notr_min(ie_logical,1);
	end
	% Valid next triangles to be deleted are:
	% - There is only one triangle connected to this edge (this edge is an open edge).
	% - The number of triangles connected to this edge is greater than the minimum value.
	ie_cline_valid		= ...
		(notr_cline==1)            &...
		(notr_cline>notr_cline_min);
	no_tr_edges_on_Ecline(~ie_cline_valid)				= 0;
	[max_no_tr_edges_on_Ecline,ie_cline_1tr_del]		= max(no_tr_edges_on_Ecline);

	% Testplot:
	if testplot&&testplot_local&&plotvertno_local&&~plotvertno
		TR						= triangulation(T.ConnectivityList,T.Points);
		P						= incenter(TR);
		E_cline_unique		= unique(E_cline_sort);
		ID_cline_unique	= unique(ID_cline_stacked);
		fontsize				= 12;
		for i=1:size(E_cline_unique,1)
			text(ha,...
				T.Points(E_cline_unique(i,1),1),...
				T.Points(E_cline_unique(i,1),2),...
				T.Points(E_cline_unique(i,1),3),num2str(E_cline_unique(i,1)),...
				'FontSize',fontsize,'FontWeight','bold','Color','k','HorizontalAlignment','center');
		end
		for i=1:size(ID_cline_unique,1)
			text(ha,...
				P(ID_cline_unique(i,1),1),...
				P(ID_cline_unique(i,1),2),...
				P(ID_cline_unique(i,1),3),num2str(ID_cline_unique(i,1)),...
				'FontSize',fontsize,'FontWeight','bold','Color','b','HorizontalAlignment','center');
		end
		for i=1:size(E_cline_sort,1)
			text(ha,...
				(T.Points(E_cline_sort(i,1),1)+T.Points(E_cline_sort(i,2),1))/2,...
				(T.Points(E_cline_sort(i,1),2)+T.Points(E_cline_sort(i,2),2))/2,...
				(T.Points(E_cline_sort(i,1),3)+T.Points(E_cline_sort(i,2),3))/2,...
				num2str(E_cline_sort(i,1)),...
				'FontSize',fontsize,'FontWeight','bold','Color',[0 0.6 0],'HorizontalAlignment','center');
		end
		drawnow;
		set_breakpoint	= 1;
	end


	% --------------------------------------------------------------------------------------------------------

	% Strategy:
	% E_cline_sort contains at least one open edge.
	% Starting from an open edge, the only triangle iCL_delete_current that is connected to this edge is deleted.
	% Of all open edges, the one whose adjacent triangle has the most edges on the closed line is selected.
	% Treatment of the two other edges e_iCL(k,:) of the triangle iCL_delete_current:
	% - If the edge e_iCL(k,:) lies on the closed line E_cline_sort:
	% The deletion of triangles is finished at this point.
	% - If the edge e_iCL(k,:) is not on the closed line E_cline_sort:
	% Save this edge as an open edge and continue from there.

	% no_tr_edges_on_Ecline: If the edge is an open edge:
	continue_deleting_triangles	= true;
	while continue_deleting_triangles

		% Current triangle to be deleted:
		iCL_delete_current			= ID_cline{ie_cline_1tr_del,:};
		iCL_delete						= [iCL_delete;iCL_delete_current];

		% Testplot:
		if testplot&&testplot_local
			T_testplot			= T;
			T_testplot.ConnectivityList(iCL_delete(1:(end-1)),:)	= [];
			TR_testplot			= triangulation(T_testplot.ConnectivityList,T_testplot.Points);
			F=[TR_testplot.ConnectivityList(:,1) ...
				TR_testplot.ConnectivityList(:,2) ...
				TR_testplot.ConnectivityList(:,3) ...
				TR_testplot.ConnectivityList(:,1)];
			tp_patch1.Faces	= F;
			ie						= find(no_tr_edges_on_Ecline>=1);
			if ~isempty(ie)
				i						= 1;
				xdata					= [T.Points(E_cline_sort(ie(i,1),1),1);T.Points(E_cline_sort(ie(i,1),2),1)];
				ydata					= [T.Points(E_cline_sort(ie(i,1),1),2);T.Points(E_cline_sort(ie(i,1),2),2)];
				zdata					= [T.Points(E_cline_sort(ie(i,1),1),3);T.Points(E_cline_sort(ie(i,1),2),3)];
				for i=2:size(ie,1)
					xdata					= [xdata;nan;T.Points(E_cline_sort(ie(i,1),1),1);T.Points(E_cline_sort(ie(i,1),2),1)];
					ydata					= [ydata;nan;T.Points(E_cline_sort(ie(i,1),1),2);T.Points(E_cline_sort(ie(i,1),2),2)];
					zdata					= [zdata;nan;T.Points(E_cline_sort(ie(i,1),1),3);T.Points(E_cline_sort(ie(i,1),2),3)];
				end
				tp_line2.XData	= xdata;
				tp_line2.YData	= ydata;
				tp_line2.ZData	= zdata;
			else
				tp_line2.XData	= nan;
				tp_line2.YData	= nan;
				tp_line2.ZData	= nan;
			end
			tp_line3.XData	= [T.Points(E_cline_sort(ie_cline_1tr_del,1),1);T.Points(E_cline_sort(ie_cline_1tr_del,2),1)];
			tp_line3.YData	= [T.Points(E_cline_sort(ie_cline_1tr_del,1),2);T.Points(E_cline_sort(ie_cline_1tr_del,2),2)];
			tp_line3.ZData	= [T.Points(E_cline_sort(ie_cline_1tr_del,1),3);T.Points(E_cline_sort(ie_cline_1tr_del,2),3)];
			ie						= find(no_tr_edges_on_Ecline==0);
			if ~isempty(ie)
				i						= 1;
				xdata					= [T.Points(E_cline_sort(ie(i,1),1),1);T.Points(E_cline_sort(ie(i,1),2),1)];
				ydata					= [T.Points(E_cline_sort(ie(i,1),1),2);T.Points(E_cline_sort(ie(i,1),2),2)];
				zdata					= [T.Points(E_cline_sort(ie(i,1),1),3);T.Points(E_cline_sort(ie(i,1),2),3)];
				for i=2:size(ie,1)
					xdata					= [xdata;nan;T.Points(E_cline_sort(ie(i,1),1),1);T.Points(E_cline_sort(ie(i,1),2),1)];
					ydata					= [ydata;nan;T.Points(E_cline_sort(ie(i,1),1),2);T.Points(E_cline_sort(ie(i,1),2),2)];
					zdata					= [zdata;nan;T.Points(E_cline_sort(ie(i,1),1),3);T.Points(E_cline_sort(ie(i,1),2),3)];
				end
				tp_line4.XData	= xdata;
				tp_line4.YData	= ydata;
				tp_line4.ZData	= zdata;
			else
				tp_line4.XData	= nan;
				tp_line4.YData	= nan;
				tp_line4.ZData	= nan;
			end
			h_title.String		= sprintf(['Removing non-manifold geometries\n',...
				'closed line with %g edges\n',...
				'triangle %g to delete'],size(E_cline_sort,1),iCL_delete_current);
			drawnow;
			if isscalar(iCL_delete)
				set_breakpoint	= 1;
			else
				set_breakpoint	= 1;
			end
		end

		% Consider all 3 edges of the triangle to be deleted iCL_delete_current individually:
		ie_cline_delete		= zeros(0,2);
		ie_delete				= zeros(0,2);
		e_iCL						= zeros(3,2);
		ie_iCL					= zeros(3,1);
		ie_cline_iCL			= zeros(3,1);
		for k=1:3
			% Index of the edge e_iCL(k,:) in E (all edges):
			ie_iCL(k,1)				= CL_ie(iCL_delete_current,k);
			% Edge of the triangle iCL_delete_current:
			e_iCL(k,:)				= E_sort(ie_iCL(k,1),:);
			% Index of the edge e_iCL(k,:) in E_cline_sort (edges of the closed line):
			ie_cline_iCL_k			= find((E_cline_sort(:,1)==e_iCL(k,1))&(E_cline_sort(:,2)==e_iCL(k,2)),1);
			% Testing:
			if testout
				fprintf(1,'------------------------------------------\n');
				k
				iCL_delete_current
				ek_iCL=e_iCL(k,:)
				no_tr_edges_on_Ecline
				E_cline_sort
				ID_cline
				ie_cline_1tr_del
				ID_cline{ie_cline_1tr_del,1}
				ie_cline_iCL_k
				ID_cline{ie_cline_iCL_k,1}
				iek_iCL=ie_iCL(k,1)
				ID{ie_iCL(k,1),1}
			end
			if size(ID{ie_iCL(k,1),1},2)<=1
				% The edge e_iCL(k,:) is connected to only one triangle (the one to be deleted):
				% It is an open edge to be deleted:
				ie_cline_delete	= [ie_cline_delete;ie_cline_iCL_k];
				ie_delete			= [ie_delete      ;ie_iCL(k,1)      ];
				set_breakpoint		= 1;
			else
				% The edge e_iCL(k,:) is connected to more than one triangle:
				if isempty(ie_cline_iCL_k)
					% The edge e_iCL(k,:) does not yet exist in E_cline_sort, so it must be added to E_cline_sort:
					% Add the edge e_iCL(k,:) to the closed line:
					no_tr_edges_on_Ecline			= [no_tr_edges_on_Ecline      ;1     ];
					E_cline								= [E_cline                    ;e_iCL(k,:)];
					E_cline_sort						= [E_cline_sort               ;e_iCL(k,:)];
					ie_cline_iCL(k,1)					= size(E_cline_sort,1);
					% Also extend the list of triangles ID_cline that are connected to the closed line:
					ID_cline{end+1,1}					= ID{ie_iCL(k,1),1};
					set_breakpoint	= 1;
				else
					% The edge e_iCL(k,:) already exists in the closed line E_cline_sort:
					ie_cline_iCL(k,1)					= ie_cline_iCL_k;
					set_breakpoint	= 1;
				end
			end
		end			% end of "for k=1:3"
		set_breakpoint	= 1;
		% Remove the triangle iCL_delete_current from ID_cline:
		for ie=1:size(ID_cline,1)
			ID_cline{ie,1}(:,ID_cline{ie,1}==iCL_delete_current)		= [];
		end
		% Remove the triangle iCL_delete_current from ID:
		for i_ie=1:3
			ie					= CL_ie(iCL_delete_current,i_ie);
			ID{ie,1}(:,ID{ie,1}==iCL_delete_current)		= [];
		end
		for k=1:3
			% ID_num(ie,:)				Indices iCL of the triangles connected to the edges E.
			ID_num(ie_iCL(k,1),ID_num(ie_iCL(k,1),:)==iCL_delete_current)		= 0;
		end
		% CL_ie(iCL,1:3)			Indices ie of the three edges of a triangle
		%								= line numbers of the triangle iCL in ID_num
		CL_ie(iCL_delete_current,:)					= [0 0 0];
		% cID=CL_cID(iCL,1:3)	Column numbers of the triangle iCL in ID_num
		CL_cID(iCL_delete_current,:)					= [0 0 0];
		% The size of the closed line maybe has changed: delete elements of the closed line:
		E_cline(ie_cline_delete,:)						= [];
		E_cline_sort(ie_cline_delete,:)				= [];
		ID_cline(ie_cline_delete,:)					= [];
		% Set edges that no longer exist in E and E_sort =0.
		% The elements should not be deleted here so that the numbering of the edges and triangles does not change.
		for i=1:size(ie_delete,1)
			E(ie_delete(i,1),:)							= [0 0];
			E_sort(ie_delete(i,1),:)					= [0 0];
		end

		% Get the next triangle to be deleted:
		% The same code is also above.
		% ID_cline_stacked: Indices iCL of all triangles connected to the edges of the closed line E_cline.
		ID_cline_stacked		= [];
		for ie_cline=1:size(ID_cline,1)
			ID_cline_stacked		= [ID_cline_stacked;ID_cline{ie_cline,1}(:)];
		end
		% no_tr_edges_on_Ecline:	If the edge is open:
		%									Number of edges of the only adjacent triangle that lie on the closed line
		no_tr_edges_on_Ecline	= zeros(size(E_cline_sort,1),1);
		notr_cline					= zeros(size(E_cline_sort,1),1);
		notr_cline_min				= zeros(size(E_cline_sort,1),1);
		for ie_cline=1:size(ID_cline,1)
			iCL			= ID_cline{ie_cline,1};
			if isscalar(iCL)
				% The edge E_cline(i,:) is connected to only one triangle, so it is an open edge.
				% Delete the triangle that lies with most of its edges on the closed line.
				% This is the fastest way to reduce the length of the closed line.
				triangle_may_be_deleted		= true;
				for i=1:3
					ie		= CL_ie(iCL,i);			% Edge of the triangle that may need to be deleted
					if size(ID{ie,1},2)<=notr_min(ie,1)
						triangle_may_be_deleted		= false;
						break
					end
				end
				if triangle_may_be_deleted
					no_tr_edges_on_Ecline(ie_cline,1)	= length(find(iCL==ID_cline_stacked));
				end
			end
			% An edge on the closed line that was initially connected with three triangles,
			% should not become an open edge and should notbe deleted completely.
			% Calculate the number of triangles connected to each edge E_cline:
			notr_cline(ie_cline,1)	= size(iCL,2);
			% Calculation of the minimum number of triangles connected to each edge E_cline:
			ie_logical		= (...
				(E_sort(:,1)==E_cline_sort(ie_cline,1))&...
				(E_sort(:,2)==E_cline_sort(ie_cline,2))    );
			notr_cline_min(ie_cline,1)	= notr_min(ie_logical,1);
		end
		% Valid next triangles to be deleted are:
		% - There is only one triangle connected to this edge (this edge is an open edge).
		% - The number of triangles connected to this edge is greater than the minimum value.
		ie_cline_valid		= ...
			(notr_cline==1)            &...
			(notr_cline>notr_cline_min);
		no_tr_edges_on_Ecline(~ie_cline_valid)				= 0;
		[max_no_tr_edges_on_Ecline,ie_cline_1tr_del]		= max(no_tr_edges_on_Ecline);

		% Termination conditions:
		if testout
			disp('next step: -------------------------------------');
			notr_cline
			notr_cline_min
			no_tr_edges_on_Ecline
			ie_cline_valid
			max_no_tr_edges_on_Ecline
			ie_cline_1tr_del
			E_cline_sort
			if ~isempty(ie_cline_1tr_del)
				iCL_delete_nextstep	= ID_cline{ie_cline_1tr_del,:}
			end
			size_E_cline_sort_0	= size(E_cline_sort_0  ,1)
			size_E_cline_sort		= size(E_cline_sort    ,1)
			size_iCL_delete_all	= size(iCL_delete,1)
			ie_delete
			if length(iCL_delete_nextstep)>1
				set_breakpoint	= 1;
			end
		end
		if isempty(E_cline_sort)
			% This should not happen because there is always at least one edge that was connected
			% to at least  three triangles at the beginning and must not be deleted completely:
			errormessage;
		else
			if    (length(ID_cline{ie_cline_1tr_del,:})~=1)                                 ||...
					(max_no_tr_edges_on_Ecline==0)                                            ||...
					(size(E_cline_sort,1)>(max_no_edges_ratio    *size(E_cline_sort_0    ,1)))||...
					(size(iCL_delete  ,1)>(max_no_triangles_ratio*size(T.ConnectivityList,1)))
				continue_deleting_triangles	= false;
			end
		end
		set_breakpoint	= 1;

	end			% end of "while continue_deleting_triangles"

	if any(notr_cline<=1)
		% There are open edges left: deleting the non-manifold geometry was not successfull:
		iCL_delete			= zeros(0,1);
	else
		set_breakpoint	= 1;
	end

catch ME
	errormessage('',ME);
end

