function T=triangulation_simplify(p,cl,tol_tp,testplot_xlimits,testplot_ylimits,msg)
% Simplification of 2D triangulation data:
% T						simplified triangulation data
%							T.Points
%							T.ConnectivityList
% p						Points, specified as a matrix whose columns are the x-coordinates, y-coordinates,
%							and z-coordinates of the triangulation points.
%							The row numbers of P are the vertex IDs in the triangulation.
% cl						Triangulation connectivity list, specified as an m-by-3 matrix, where m is the
%							number of triangles.
%							Each row of T contains the vertex IDs that define a triangle or tetrahedron.
%							The vertex IDs are the row numbers of the input points.
%							The ID of a triangle in the triangulation is the corresponding row number in cl.
% tol_tp					Minimum distance between two points.
%							If two points have a smaller distance than tol_tp, they are merged.
% testplot_xlimits	x- and y-limits of the test plots. Default: []
% testplot_ylimits	The testplot is shown, if the mean value of the points to be merged is within the limits.
% msg						message string for the waitbar

global GV GV_H WAITBAR

try

	% Initializations:
	if nargin==0
		% Testing:
		p		= [...
			0 0 0;...			% 1
			0 1 0;...			% 2
			1 1 0;...			% 3
			1 0 0;...			% 4
			1.025 0.95 0;...	% 5
			0.95  1.025 0;...	% 6
			1.025 1.025 0;...	% 7
			0.05  1.025 0;...	% 8
			0.99  0.5   0];	% 9		[0.975  0.5   0] or [0.99  0.5   0]
		cl		= [...
			1 2 3;...
			3 4 5;...
			2 3 6;...
			2 8 6;...
			1 3 9;...
			1 4 9;...
			3 4 9];
		testplot				= 0;
		testplot_xlimits	= [];
		testplot_ylimits	= [];
		msg					= 'Test';
		tol_tp				= 0.2;			% 0.07: 2 points / 0.2: more than 2 points
		view_no				= 2;				% testplot: 2d-view
	else
		testplot				= 0;
		view_no				= 3;				% testplot: 3d-view
	end
	t_testplot_pause		= 0.1;			% Duration of the display of test plots if no breakpoints are set.
	T0							= [];				% T0 is used to compare the data before and after simplification
	T0.Points				= p;
	T0.ConnectivityList	= cl;
	T							= T0;				% T will be simplified
	WAITBAR.t1				= clock;

	% Tolerance for the use of uniquetol: Conversion of the absolute tolerance:
	% C = uniquetol(A,tol): Two values, u and v, are within tolerance if abs(u-v) <= tol*max(abs(A(:)))
	% tol_tp=tol*max(abs(A(:)))  ==>  tol=tol_tp/max(abs(A(:)))
	tol_uniquetol			= tol_tp/max(abs(T0.Points),[],'all');


	% -----------------------------------------------------------------------------------------------------------------
	% Testplot: data before the simplification:
	if testplot~=0
		hf=figure(7472375);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha=axes;
		hold(ha,'on');
		cameratoolbar(hf,'Show');
		facealpha	= 0.8;
		edgealpha	= 0.2;
		F_patch=[T0.ConnectivityList(:,1) ...
			T0.ConnectivityList(:,2) ...
			T0.ConnectivityList(:,3) ...
			T0.ConnectivityList(:,1)];
		patch(ha,'faces',F_patch,'vertices',T0.Points,...
			'EdgeColor',[1 1 1]*0.6,'FaceColor',[1 1 1],'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
		if size(T0.Points,1)<=30
			plot3(ha,T0.Points(:,1),T0.Points(:,2),T0.Points(:,3),'.r','MarkerSize',15)
			for i=1:size(T0.Points,1)
				text(ha,T0.Points(i,1),T0.Points(i,2),T0.Points(i,3),num2str(i),'FontSize',16,...
					'HorizontalAlignment','center');
			end
		end
		axis(ha,'equal');
		title(ha,'T0');
		view(ha,view_no);
		pause(t_testplot_pause);
	end


	% -----------------------------------------------------------------------------------------------------------------
	% Identical points are saved in T.Points at different positions and can differ slightly.
	% This can lead to open edges. Delete equal points:
	method	= 3;
	switch method

		case 1
			r_delete_p_logical			= false(size(T.Points,1),1);
			r_notdelete_p_logical		= false(size(T.Points,1),1);
			r									= 0;
			r_delete_p_r					= -1;
			while (r<size(T.Points,1))||~isempty(r_delete_p_r)
				r		= r+1;
				r_notdelete_p_logical(r)	= true;

				r_delete_p_r_logical			= ...
					(abs(T.Points(:,1)-T.Points(r,1))<tol_tp)&...
					(abs(T.Points(:,2)-T.Points(r,2))<tol_tp)&...
					(abs(T.Points(:,3)-T.Points(r,3))<tol_tp);
				r_delete_p_r_logical(r)	= false;														% Do not delete the current row
				r_delete_p_r_logical		= r_delete_p_r_logical&~r_notdelete_p_logical;	% Do not delete previous rows
				r_delete_p_r				= find(r_delete_p_r_logical,1);
				if ~isempty(r_delete_p_r)
					% Replace point in r_delete_p_r with point in row r:
					iCL											= T.ConnectivityList==r_delete_p_r;
					T.ConnectivityList(iCL)					= r;
					% Delete point in r_delete_p_r:
					iCL											= T.ConnectivityList>r_delete_p_r;
					T.ConnectivityList(iCL)					= T.ConnectivityList(iCL)-1;
					T.Points(r_delete_p_r,:)				= [];
					r_delete_p_logical(r_delete_p_r)		= [];
					r_notdelete_p_logical(r_delete_p_r)	= [];
					r		= r-1;
				end
			end

		case 2
			% 100 times faster than method 1, same functionality:
			% [T.Points_new,ia,ic]=uniquetol(T.Points_old,tol,'ByRows',true);
			% T.Points_new = T.Points_old(ia,:)
			% T.Points_old = T.Points_new(ic,:)
			T.Points						= round(T.Points/tol_tp)*tol_tp;
			[T.Points,~,ic]			= uniquetol(T.Points,tol_uniquetol,'ByRows',true);
			% The element k of ic is the old number of the point in the ConnectivityList.
			% ==> ic(k) is the new number of the point
			% The ConnectivityList contains the indices k of the old points ==> replace with ic(k)
			T.ConnectivityList(:,1)	= ic(T.ConnectivityList(:,1));
			T.ConnectivityList(:,2)	= ic(T.ConnectivityList(:,2));
			T.ConnectivityList(:,3)	= ic(T.ConnectivityList(:,3));

		case 3
			% Better functionality than method 1 and 2:
			% Rounding all points (method 2) can cause the direction of area vectors to reverse.
			% - This allows triangles to overlap
			% - If triangles overlap at an edge, points may lie outside the edge line
			% Procedure:
			% Phase 1:
			% - Identification of groups of points with too small a distance (uniquetol function)
			% - These points are merged.
			%   The possible new position is the position of the points in a group or the mean position.
			%   Condition: The area vector of the adjacent triangles must not be reversed due to the simplification
			%   Of all possible new positions, the position is selected that:
			%   - meets this condition,
			%   - leads to the largest area of ​​the individual adjacent triangles.
			% - If the condition cannot be met, the point group is not simplified in this phase.
			% Phase 2:
			% - In the 2nd phase, all groups of points with too small a distance are merged that do not meet the
			%   condition. The new point is the average of all points in a group.
			% In this way there are no numerical problems in determining the edge of the surface.
			% However, it can happen that triangles overlap.

			% If two points are exactly equal: Merge the points without the detailed plausibility checks below:
			% [T.Points_new,ia,ic]=uniquetol(T.Points_old,'rows');
			% T.Points_new = T.Points_old(ia,:)
			% T.Points_old = T.Points_new(ic,:)
			[T.Points,~,ic]			= unique(T.Points,'rows');
			% The element k of ic is the old number of the point in the ConnectivityList.
			% ==> ic(k) is the new number of the point
			% The ConnectivityList contains the indices k of the old points ==> replace with ic(k)
			T.ConnectivityList(:,1)	= ic(T.ConnectivityList(:,1));
			T.ConnectivityList(:,2)	= ic(T.ConnectivityList(:,2));
			T.ConnectivityList(:,3)	= ic(T.ConnectivityList(:,3));

			for accept_invalid_simplifications=0:1
				% accept_invalid_simplifications=0: Phase 1
				% accept_invalid_simplifications=1: Phase 2

				% ip_up:						cell array: Indices of the points in T.Points of all groups of points with
				%								too small a distance (unique points).
				% choice_isvalid_up_v:	logical array corresponding to ip_up:
				%								True if a group of equal points has been successfully merged.
				ip_up							= {1};
				choice_isvalid_up_v		= true;
				k_while_nisempty_ip_up	= 0;
				while ~isempty(ip_up)&&...
						~isequal(choice_isvalid_up_v,false(size(choice_isvalid_up_v,1),1))
					% Termination condition:
					% - there are no longer any points with too small a distance or
					% - no points were merged in the last loop run, for example because triangles overlap in
					%   all groups of points with too small a distance.
					% ==>
					% Combine points with too small a distance as long as the following applies:
					% - In the last loop run there were points with too small a distance and
					% - in the last loop run, points were combined.
					k_while_nisempty_ip_up	= k_while_nisempty_ip_up+1;

					% vertex attachments:
					% Maybe there are points that are not referenced by the triangulation. These will be deleted at the end.
					if GV.warnings_off
						warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
					end
					TR		= triangulation(T.ConnectivityList,T.Points);
					if GV.warnings_off
						warning('on','MATLAB:triangulation:PtsNotInTriWarnId');
					end
					V			= vertexAttachments(TR);

					% Find points with too small a distance:
					T_uniquetol				= T;
					% [T_uniquetol.Points,ia,ic]=uniquetol(T.Points,tol,'ByRows',true);
					% T_uniquetol.Points	= T.Points(ia,:)
					% T.Points	         = T_uniquetol.Points(ic,:)
					[T_uniquetol.Points,ia,ic]				= uniquetol(T.Points,tol_uniquetol,'ByRows',true);
					% The element k of ic is the old number of the point in the ConnectivityList.
					% ==> ic(k) is the new number of the point
					% The ConnectivityList contains the indices k of the old points ==> replace with ic(k)
					T_uniquetol.ConnectivityList(:,1)	= ic(T_uniquetol.ConnectivityList(:,1));
					T_uniquetol.ConnectivityList(:,2)	= ic(T_uniquetol.ConnectivityList(:,2));
					T_uniquetol.ConnectivityList(:,3)	= ic(T_uniquetol.ConnectivityList(:,3));

					% Calculation of ip_replaced_logical: Indices in T.Points, that are replaced by other points:
					ip_kept_logical		= false(size(T.Points,1),1);
					ip_kept_logical(ia)	= true;
					ip_replaced_logical	= ~ip_kept_logical;

					% Calculation of ic_unique_points_v: Indices in T_uniquetol.Points, that have replaced other points:
					ic_unique_points_v	= unique(ic(ip_replaced_logical));

					% Calculation of:
					% ip_v			cell array: indices of ALL points in a group that are to be merged.
					% dmin_up		vector: smallest distance between the points of a group:
					%					The points with the smallest distance between each other are merged first.
					ip_up			= cell(size(ic_unique_points_v,1),1);
					dmin_up		= ones(size(ic_unique_points_v,1),1)*1e12;
					T_CL_unique	= unique(T.ConnectivityList);

					% Points in T.Points that are referenced by the triangulation:
					ip_v_refbytriang	= false(size(T.Points,1),1);
					ip_v_refbytriang(T_CL_unique)	= true;

					for k_up=1:size(ic_unique_points_v,1)
						% group of points no k_up:

						% Waitbar:
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',sprintf(...
								'%s: %g/2 - %g - 1/2 - %g/%g',msg,...
								accept_invalid_simplifications+1,...
								k_while_nisempty_ip_up,...
								k_up,size(ic_unique_points_v,1)));
							drawnow;
						end

						% ip_up(k_up): all indices in T.Points, that are to be merged:
						% Exclude points in ip_v that are not referenced by the triangulation (because of previous steps).
						ip_v		= find(ip_v_refbytriang&(ic==ic_unique_points_v(k_up,1)));

						% If two points are exactly equal: Merge the points without the detailed plausibility checks below:
						% This should not happen any more.
						k_ip_delete_v	= false(size(ip_v,1),1);
						for k1=1:(size(ip_v,1)-1)
							for k2=(k1+1):size(ip_v,1)
								if isequal(T.Points(ip_v(k1),:),T.Points(ip_v(k2),:))
									% The 2 points are equal: replace point ip_v(k2) by ip_v(k1):
									iCL_ip2_v		= V{ip_v(k2),1};
									for k_iCL_ip2_v=1:length(iCL_ip2_v)
										iCL_ip2		= iCL_ip2_v(k_iCL_ip2_v);
										c	= T.ConnectivityList(iCL_ip2,:)==ip_v(k2);
										T.ConnectivityList(iCL_ip2,c)		= ip_v(k1);
									end
									ip_v_refbytriang(ip_v(k2),1)								= false;
									k_ip_delete_v(k2,1)											= true;
								end
							end
						end
						ip_v(k_ip_delete_v,:)	= [];

						% ip_up{k_up,1} and
						% dmin_up(k_up,1): minimum distance between the points
						if size(ip_v,1)>1
							ip_up{k_up,1}		= ip_v;
							for i1=1:length(ip_up{k_up,1})
								ip1	= ip_up{k_up,1}(i1,1);
								p1		= T.Points(ip1,:);
								for i2=(i1+1):length(ip_up{k_up,1})
									ip2	= ip_up{k_up,1}(i2,1);
									p2		= T.Points(ip2,:);
									dmin_up(k_up,1)	= min(...
										dmin_up(k_up,1),...
										sqrt((p1(1,1)-p2(1,1))^2+(p1(1,2)-p2(1,2))^2+(p1(1,3)-p2(1,3))^2));
								end
							end
						end

					end

					% Delete entries in ip_up that are empty: This can happen because all points except one are not
					% referenced by the triangulation (because of previous steps).
					k_up			= (dmin_up<1e12);
					ip_up			= ip_up(k_up);
					dmin_up		= dmin_up(k_up);
					% The points are now sorted into groups of points with too small a distance between them.
					% ip_up{k_up,1}		all indices in T.Points, that are to be merged
					% dmin_up(k_up,1)		smallest distance between the points in group k_up
					% Sort the groups by dmin_up so that the points with the smallest distance are merged first:
					[~,k_up_sort_v]	= sort(dmin_up);
					ip_up					= ip_up(k_up_sort_v);

					choice_isvalid_up_v	= false(size(ip_up,1),1);
					for k_up=1:size(ip_up,1)
						% k_up: No of the group of points with too small a distance:

						% Waitbar:
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',sprintf(...
								'%s: %g/2 - %g - 2/2 - %g/%g',msg,...
								accept_invalid_simplifications+1,...
								k_while_nisempty_ip_up,...
								k_up,size(ip_up,1)));
							drawnow;
						end

						% ip_v: all indices in T.Points, that are to be merged:
						ip_v		= ip_up{k_up,1};

						% Indices of all triangles in T.ConnectivityList that touch the points in ip_v and consist of
						% three different points (triangles can disappear by merging points, these will be deleted later):
						iCL_v				= [];
						iCL_all_v		= [];
						for k_ip=1:size(ip_v,1)
							ip				= ip_v(k_ip,1);
							iCL0_v		= V{ip,1};							% IDs of the triangles attached to the vertex ip
							iCL_all_v	= [iCL_all_v iCL0_v];
							for k_iCL=1:length(iCL0_v)
								if    (T.ConnectivityList(iCL0_v(k_iCL),1)~=T.ConnectivityList(iCL0_v(k_iCL),2))&&...
										(T.ConnectivityList(iCL0_v(k_iCL),1)~=T.ConnectivityList(iCL0_v(k_iCL),3))&&...
										(T.ConnectivityList(iCL0_v(k_iCL),2)~=T.ConnectivityList(iCL0_v(k_iCL),3))
									% The current triangle consists of three different vertex indices:
									iCL_v		= [iCL_v;iCL0_v(k_iCL)];
								end
							end
						end
						iCL_v				= unique(iCL_v);
						iCL_all_v		= unique(iCL_all_v);
						iCL_all_v		= iCL_all_v(:);
						[fa,fn,~]		= facedata_local(T,iCL_v);			% [fa,fn,minel]=
						% Do not consider triangles that previously had an area of zero:
						kred_v			= find(fa>0);
						iCL_v				= iCL_v(kred_v);
						fa					= fa(kred_v);
						fn					= fn(kred_v,:);
						if isempty(iCL_v)&&~isdeployed
							setbreakpoint=1;
							errormessage;
						end

						% Testplot:
						testplot_xylimits_p_inside	= false;
						if ~isempty(testplot_xlimits)&&~isempty(testplot_ylimits)
							px_min	= min(T.Points(ip_v,1));
							px_max	= max(T.Points(ip_v,1));
							py_min	= min(T.Points(ip_v,2));
							py_max	= max(T.Points(ip_v,2));
							if  ~((px_max<testplot_xlimits(1))||...
									(px_min>testplot_xlimits(2))||...
									(py_max<testplot_ylimits(1))||...
									(py_min>testplot_ylimits(2))     )
								testplot_xylimits_p_inside	= true;
							end
						end

						% Testplot:
						if (testplot~=0)||testplot_xylimits_p_inside
							% Show all solutions step by step:
							ip_cl_v	= unique(T.ConnectivityList(iCL_v,:));
							ip_cl_v	= ip_cl_v(:);
							hf=figure(7472376);
							clf(hf,'reset');
							set(hf,'Tag','maplab3d_figure');
							ha=axes;
							hold(ha,'on');
							cameratoolbar(hf,'Show');
							axis(ha,'equal');
							% Show T0:
							facealpha	= 0;
							edgealpha	= 0.2;
							F_patch=[T0.ConnectivityList(:,1) ...
								T0.ConnectivityList(:,2) ...
								T0.ConnectivityList(:,3) ...
								T0.ConnectivityList(:,1)];
							patch(ha,'faces',F_patch,'vertices',T0.Points,...
								'EdgeColor',[1 1 1]*0.6,'FaceColor',[1 1 1],'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
							% Show T:
							F_patch=[T.ConnectivityList(:,1) ...
								T.ConnectivityList(:,2) ...
								T.ConnectivityList(:,3) ...
								T.ConnectivityList(:,1)];
							patch(ha,'faces',F_patch,'vertices',T.Points,...
								'EdgeColor',[0 0 1],'FaceColor',[1 1 1]*0.95,'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
							plot3(ha,T.Points(:,1),T.Points(:,2),T.Points(:,3),...
								'LineWidth',0.5,'LineStyle','none','Color','b',...
								'Marker','.','MarkerSize',10);
							% Show points with too small a distance: red
							plot3(ha,T.Points(ip_v,1),T.Points(ip_v,2),T.Points(ip_v,3),...
								'LineWidth',1.5,'LineStyle','none','Color','r',...
								'Marker','x','MarkerSize',10);
							if ip_v<=30
								for i=1:size(ip_v,1)
									text(ha,T.Points(ip_v(i,1),1),T.Points(ip_v(i,1),2),num2str(ip_v(i,1)),'FontSize',16,...
										'HorizontalAlignment','left');
								end
							end
							% Show all neighboring triangles: red
							color_nt			= [1 0.75 0.75];
							facealpha_nt	= 0.2;
							F_patch_nt	= [T.ConnectivityList(iCL_v,1) ...
								T.ConnectivityList(iCL_v,2) ...
								T.ConnectivityList(iCL_v,3) ...
								T.ConnectivityList(iCL_v,1)];
							patch_nt		= patch(ha,'faces',F_patch_nt,'vertices',T.Points,...
								'EdgeColor',color_nt,'FaceColor',color_nt,'FaceAlpha',facealpha_nt,'EdgeAlpha',1,'LineWidth',1);
							% Set axis lilmits:
							if ~isempty(ip_cl_v)
								xmin		= min(T.Points(ip_cl_v(:,1),1));
								xmax		= max(T.Points(ip_cl_v(:,1),1));
								ymin		= min(T.Points(ip_cl_v(:,1),2));
								ymax		= max(T.Points(ip_cl_v(:,1),2));
							else
								xmin		= min(T.Points(ip_v(:,1),1));
								xmax		= max(T.Points(ip_v(:,1),1));
								ymin		= min(T.Points(ip_v(:,1),2));
								ymax		= max(T.Points(ip_v(:,1),2));
							end
							dx			= xmax-xmin;
							dy			= xmax-xmin;
							if dx==0
								dx=1;
							end
							if dy==0
								dy=1;
							end
							ha.XLim	= [xmin xmax]+[-1 1]*dx*0.02;
							ha.YLim	= [ymin ymax]+[-1 1]*dy*0.02;
							title(ha,sprintf([...
								'Initial state']),...
								'Interpreter','none');
							view(ha,view_no);
							pause(t_testplot_pause);
							setbreakpoint=1;
						end

						% The new positions of the points are tested with T_test:
						% Old: T_test	= T;
						% New: The size of T_test is reduced because otherwise the assignment of the new positions requires
						% a long computing time.
						ip_v_with_triangles			= unique([...
							T.ConnectivityList(iCL_v,1);...
							T.ConnectivityList(iCL_v,2);...
							T.ConnectivityList(iCL_v,3);...
							ip_v]);
						T_test							= struct;
						ip_v_T_test						= zeros(size(ip_v,1),1);
						for r=1:size(ip_v,1)
							ip_v_T_test(r,1)			= find(ip_v_with_triangles==ip_v(r,1));
						end
						iCL_v_T_test					= (1:size(iCL_v,1))';
						T_test.Points					= T.Points(ip_v_with_triangles,:);
						T_test.ConnectivityList		= T.ConnectivityList(iCL_v,:);
						for r=1:size(ip_v_with_triangles,1)
							T_test.ConnectivityList(T_test.ConnectivityList==ip_v_with_triangles(r,1))	= r;
						end

						% Change the position of the points one after the other to the values in p_test_m:
						% Results:
						% isvalid_test_v		false if the new position of the points is not valid
						% min_fatest_v			Minimum area of the neighboring triangles when all points
						%							are moved to the new position.
						p_test_m					= sum(T.Points(ip_v,:),1)/size(ip_v,1);		% mean value
						if (accept_invalid_simplifications==0)&&~isempty(iCL_v)
							p_test_m				= [p_test_m;T.Points(ip_v,1) T.Points(ip_v,2) T.Points(ip_v,3)];
						end
						isvalid_test_v			= true(size(p_test_m,1),1);
						min_fatest_v			= zeros(size(p_test_m,1),1);
						for k_ptest=1:size(p_test_m,1)
							% New position No k_ptest:
							T_test.Points(ip_v_T_test,:)		= ones(size(ip_v_T_test,1),1)*p_test_m(k_ptest,:);
							if ~isempty(iCL_v)
								[fa_test,fn_test,minel_test]	= facedata_local(T_test,iCL_v_T_test);
								% If a triangle disappears because the adjacent points are merged, this is what is desired:
								% Don't take these triangles into account (minimum edge length =0):
								kred_v								= find(minel_test>0);
								min_fatest_v(k_ptest,1)			= min(fa_test(kred_v,1));	% smallest area of neighboring triangles
								% Check whether a face normal vector reverses:
								for k=1:size(kred_v,1)
									% Triangle No k:
									kred		= kred_v(k,1);
									if (fn(kred,:)*fn_test(kred,:)')<=0
										% The new position is invalid because:
										% - The area is zero (because |fn_test(kred,:)|=0)
										%   This can happen if the three points of a triangle lie on a line.
										%   Then all three edge lengths are not =0, but the area is still =0.
										% - The face normal vector has folded (because dot product <0):
										isvalid_test_v(k_ptest,1)	= false;
										break
									end
								end
							else

							end
							% Testplot:
							if (testplot~=0)||testplot_xylimits_p_inside
								% Show all neighboring triangles: orange
								color_nt		= [1 0.75 0];
								delete(patch_nt);
								if ~isempty(iCL_v_T_test)
									F_patch_nt	= [T_test.ConnectivityList(iCL_v_T_test,1) ...
										T_test.ConnectivityList(iCL_v_T_test,2) ...
										T_test.ConnectivityList(iCL_v_T_test,3) ...
										T_test.ConnectivityList(iCL_v_T_test,1)];
									patch_nt		= patch(ha,'faces',F_patch_nt,'vertices',T_test.Points,...
										'EdgeColor',color_nt,'FaceColor',color_nt,...
										'FaceAlpha',facealpha_nt,'EdgeAlpha',1,'LineWidth',1);
								end
								title(ha,sprintf([...
									'Point %g/%g\n',...
									'min_fatest_v(k_ptest,1)=%g\n',...
									'isvalid_test_v(k_ptest,1)=%g'],...
									k_ptest,size(p_test_m,1),min_fatest_v(k_ptest,1),isvalid_test_v(k_ptest,1)),...
									'Interpreter','none');
								pause(t_testplot_pause);
								setbreakpoint=1;
							end
						end

						% Assign the valid solution with the maximum remaining area of the triangles:
						if accept_invalid_simplifications==0
							% Phase 1: Do not accept invalid positions:
							min_fatest_v(~isvalid_test_v,:)			= [];
							p_test_m(~isvalid_test_v,:)				= [];
							if ~isempty(min_fatest_v)
								% There is a valid solution:
								choice_isvalid								= true;
								[choice_min_fatest_v,k_ptest_opt]	= max(min_fatest_v);
								% Change T.Points:
								T.Points(ip_v,:)							= ones(size(ip_v,1),1)*p_test_m(k_ptest_opt,:);
								% Change T.ConnectivityList:
								% Remark: The indices iCL_v only contains triangles that consist of three different points.
								% However, the indices ip_v can also belong to triangles that consist of fewer than three
								% points, which have therefore already been eliminated. So iCL_all_v must be used.
								T_CL_iCLv											= T.ConnectivityList(iCL_all_v,:);
								for i_ip_v=2:size(ip_v,1)
									T_CL_iCLv(T_CL_iCLv==ip_v(i_ip_v,1))	= ip_v(1,1);
								end
								T.ConnectivityList(iCL_all_v,:)				= T_CL_iCLv;
							else
								choice_isvalid								= false;
								choice_min_fatest_v						= 999999;
							end
							choice_isvalid_up_v(k_up,1)				= choice_isvalid;
						else
							% Phase 2: Accept invalid positions:
							choice_min_fatest_v								= min_fatest_v;
							% Change T.Points:
							T.Points(ip_v,:)									= ones(size(ip_v,1),1)*p_test_m;
							% Change T.ConnectivityList:
							T_CL_iCLv											= T.ConnectivityList(iCL_all_v,:);
							for i_ip_v=2:size(ip_v,1)
								T_CL_iCLv(T_CL_iCLv==ip_v(i_ip_v,1))	= ip_v(1,1);
							end
							T.ConnectivityList(iCL_all_v,:)				= T_CL_iCLv;
							choice_isvalid_up_v(k_up,1)					= true;
						end

						% Testplot:
						if (testplot~=0)||testplot_xylimits_p_inside
							% Show all neighboring triangles: green
							color_nt		= [146 208 80]/255;
							F_patch_nt	= [T.ConnectivityList(iCL_v,1) ...
								T.ConnectivityList(iCL_v,2) ...
								T.ConnectivityList(iCL_v,3) ...
								T.ConnectivityList(iCL_v,1)];
							delete(patch_nt);
							patch_nt		= patch(ha,'faces',F_patch_nt,'vertices',T.Points,...
								'EdgeColor',color_nt,'FaceColor',color_nt,'FaceAlpha',facealpha_nt,'EdgeAlpha',1,'LineWidth',1);
							title(ha,sprintf([...
								'Choice:\n',...
								'choice_min_fatest_v=%g\n',...
								'choice_isvalid=%g'],...
								choice_min_fatest_v,choice_isvalid),'Interpreter','none');
							pause(t_testplot_pause);
							setbreakpoint=1;
						end

					end			% End of: for k_up=1:size(ip_up,1)

					% Delete points that are not referenced by the triangulation:
					[T,~]	= triangulation_delete_not_referenced_points(T);

				end				% End of: while ~isempty(ip_up)

			end					% End of: for accept_invalid_simplifications=0:1

	end							% End of: switch method


	% -----------------------------------------------------------------------------------------------------------------
	% A triangle can contain two identical vertices: Delete these traingles:
	T	= triangulation_delete_empty_triangles(T);


	% -----------------------------------------------------------------------------------------------------------------
	% T.ConnectivityList can contain idential triangles, with different sorting of the vertices:
	% Delete these traingles:
	T	= triangulation_delete_identical_triangles(T);


	% -----------------------------------------------------------------------------------------------------------------
	% Delete points that are not referenced by the triangulation:
	[T,~]	= triangulation_delete_not_referenced_points(T);


	% -----------------------------------------------------------------------------------------------------------------
	% Testplot: Show result:
	if testplot~=0
		hf=figure(7472377);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha=axes;
		hold(ha,'on');
		cameratoolbar(hf,'Show');
		facealpha	= 0.8;
		edgealpha	= 0.2;
		F_patch=[T.ConnectivityList(:,1) ...
			T.ConnectivityList(:,2) ...
			T.ConnectivityList(:,3) ...
			T.ConnectivityList(:,1)];
		patch(ha,'faces',F_patch,'vertices',T.Points,...
			'EdgeColor',[1 1 1]*0.6,'FaceColor',[1 1 1],'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
		if size(T.Points,1)<=30
			plot3(ha,T.Points(:,1),T.Points(:,2),T.Points(:,3),'.r','MarkerSize',15)
			for i=1:size(T.Points,1)
				text(ha,T.Points(i,1),T.Points(i,2),T.Points(i,3),num2str(i),'FontSize',16,...
					'HorizontalAlignment','center');
			end
		end
		axis(ha,'equal');
		title(ha,'T');
		view(ha,view_no);
		pause(t_testplot_pause);
	end

catch ME
	errormessage('',ME);
end



% -----------------------------------------------------------------------------------------------------------------
function [fa,fn,minel]=facedata_local(T,id)
% fa			face area
% fn			face normal vector
% minel		minimum edge length
% T			triangulation data
%				T.Points
%				T.ConnectivityList
% id			row number of the corresponding triangle in TR.ConnectivityList

try

	id			= id(:);
	fa			= zeros(size(id,1),1);
	fn			= zeros(size(id,1),3);
	minel		= zeros(size(id,1),1);
	for i=1:size(id,1)
		cl				= T.ConnectivityList(id(i,1),:);
		if    (cl(1,1)~=cl(1,2))&&...
				(cl(1,2)~=cl(1,3))&&...
				(cl(1,1)~=cl(1,3))
			p1				= T.Points(cl(1,1),:);
			p2				= T.Points(cl(1,2),:);
			p3				= T.Points(cl(1,3),:);
			p12			= p2-p1;
			p13			= p3-p1;
			p23			= p3-p2;
			p12xp13		= cross(p12,p13)/2;
			fa(i,1)		= sqrt(p12xp13(1,1)^2+p12xp13(1,2)^2+p12xp13(1,3)^2);
			if fa(i,1)>0
				fn(i,:)	= p12xp13/fa(i,1);
			end
			minel(i,1)	= min([...
				sqrt(p12(1,1)^2+p12(1,2)^2+p12(1,3)^2);...
				sqrt(p13(1,1)^2+p13(1,2)^2+p13(1,3)^2);...
				sqrt(p23(1,1)^2+p23(1,2)^2+p23(1,3)^2)    ]);
		end
	end

catch ME
	errormessage('',ME);
end

