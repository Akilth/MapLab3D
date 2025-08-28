function [T,iT_margin,get_iT_margin_error_occurred]=...
	get_T_margin(obj,T,PP_local,ELE_local,poly_legbgd,colprio_base,obj_bot_bh_reg,msg,testplot)
% Outer and inner margin lines of the printed part

global GV

% The try/catch block is in the calling function!

% % Test:
% save([testdata_pathname testdata_filename],'obj','obj_bot_bh_reg','T','T0','PP_local','ELE_local','poly_legbgd','colprio_base');

% Initializations:
testplot_xlimits		= [];
testplot_ylimits		= [];
if nargin==0
	testplot						= 1;
	msg							= 'Test';
	testdata_pathname	= 'C:\Daten\Projekte\Maplab3d_Ablage\00_Matlab\Test\';
	testdata_filename	= '';
	% -----------------------------------------------------------------------------------------------------------------
	error_in_get_T_margin						= false;
	error_in_map2stl_topside_triangulation	= true;
	% -----------------------------------------------------------------------------------------------------------------
	if error_in_get_T_margin
		testdata_no			= 11;
		switch testdata_no																			% Points after simplification:
			case 0																										% [4×3 double]
				T.Points=[...
					0 0 0;...
					1 0 0;...
					0 1 0;...
					1 1 0;...
					1.000001 1 0];
				T.ConnectivityList=[...
					1 2 4;...
					1 3 4;...
					2 4 5];
				obj.poly	= polyshape([0 1 1 0],[0 0 1 1]);
			case 1,	testdata_filename	= 'testdaten_get_T_margin_01.mat';								% [21308×3 double]
			case 2,	testdata_filename	= 'testdaten_get_T_margin_06.mat';								% [ 1843×3 double]
			case 3,	testdata_filename	= 'test_get_T_margin_errorlog_data_20240129_1039.mat';	% [  879×3 double]
			case 4,	testdata_filename	= 'test_get_T_margin_errorlog_data_20240205_1444.mat';	% [ 3701×3 double]
			case 5,	testdata_filename	= 'test_get_T_margin_errorlog_data_20240304_0827';			% [    3×3 double]
			case 6,	testdata_filename	= 'test_get_T_margin_klein';										% [ 1634×3 double]
			case 7,	testdata_filename	= 'test_get_T_margin_mittel';										% [17165×3 double]
			case 8,	testdata_filename	= 'test_get_T_margin_groß';										% [84954×3 double]
			case 9,	testdata_filename	= 'test_get_T_margin_errorlog_data_20240405_2022.mat';	% [37249×3 double]
			case 10,	testdata_filename	= 'test_get_T_margin_errorlog_data_20240408_0658.mat';	% [ 2025×3 double]
				testplot_xlimits	= [-253.32 -253.29];
				testplot_ylimits	= [-67.079 -67.046];
		end
		if ~isempty(testdata_filename)
			load([testdata_pathname testdata_filename]);
		end
		switch testdata_no
			case 9,	T = T0;
		end
	end
	% -----------------------------------------------------------------------------------------------------------------
	if error_in_map2stl_topside_triangulation
		testdata_no			= 2;
		switch testdata_no																			% Points after simplification:
			case 1
				load([testdata_pathname 'test_get_T_margin_errorlog_data_20250711_1200.mat'])
			case 2
				load([testdata_pathname 'test_get_T_margin_errorlog_data_20250712_1859.mat'])
		end
		testplot						= 1;
		[T,iT_margin,get_iT_margin_error_occurred]	= ...
			get_T_margin(obj,T,PP_local,ELE_local,poly_legbgd,colprio_base,obj_bot_bh_reg,msg_get_T_margin,testplot);
		set_breakpoint	= 0;
		return
	end
	% -----------------------------------------------------------------------------------------------------------------
end
testout_i_margin				= 0;
if testplot~=0
	T0								= T
end
iT_margin							= cell(1,0);
get_iT_margin_error_occurred	= false;
E										= [];
ie_startpoint						= [];
errortext							= '';
if isempty(T.Points)
	return
end


%------------------------------------------------------------------------------------------------------------------
% T.Points , T.ConnectivityList repairing:
%------------------------------------------------------------------------------------------------------------------

% % Testing:
% if testplot~=0
% 	hf=figure(7472373);
% 	clf(hf,'reset');
% 	set(hf,'Tag','maplab3d_figure');
% 	ha=axes;
% 	hold(ha,'on');
% 	cameratoolbar(hf,'Show');
% 	facealpha	= 0.8;			% Transparenz der Oberflächen		0.2
% 	edgealpha	= 0.2;			% Transparenz der Kanten			0.2
% 	F_patch=[T.ConnectivityList(:,1) ...
% 		T.ConnectivityList(:,2) ...
% 		T.ConnectivityList(:,3) ...
% 		T.ConnectivityList(:,1)];
% 	patch(ha,'faces',F_patch,'vertices',T.Points,...
% 		'EdgeColor',[0 0 0],'FaceColor',[1 1 1]*0.95,'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
% 	% Stützstellen:
% 	plot3(ha,T.Points(:,1),T.Points(:,2),T.Points(:,3),...
% 		'LineWidth',0.5,'LineStyle','none','Color','k',...
% 		'Marker','.','MarkerSize',10);
% 	view(ha,3);
% 	axis(ha,'equal');
% 	size_T_Points_before_triangulation_simplify	= size(T.Points)
% 	max_T_CL_before_triangulation_simplify			= max(T.ConnectivityList,[],'all')
% 	setbreakpoint=1;
% end

% Call triangulation_simplify:
msg_triangulation_simplify		= sprintf('%s: simplification',msg);
T	= triangulation_simplify(T.Points,T.ConnectivityList,GV.tol_tp,testplot_xlimits,testplot_ylimits,...
	msg_triangulation_simplify);

% % Testing:
% if testplot~=0
% 	hf=figure(7472374);
% 	clf(hf,'reset');
% 	set(hf,'Tag','maplab3d_figure');
% 	ha=axes;
% 	hold(ha,'on');
% 	cameratoolbar(hf,'Show');
% 	facealpha	= 0.8;			% Transparenz der Oberflächen		0.2
% 	edgealpha	= 0.2;			% Transparenz der Kanten			0.2
% 	F_patch=[T.ConnectivityList(:,1) ...
% 		T.ConnectivityList(:,2) ...
% 		T.ConnectivityList(:,3) ...
% 		T.ConnectivityList(:,1)];
% 	patch(ha,'faces',F_patch,'vertices',T.Points,...
% 		'EdgeColor',[0 0 0],'FaceColor',[1 1 1]*0.95,'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
% 	% Stützstellen:
% 	plot3(ha,T.Points(:,1),T.Points(:,2),T.Points(:,3),...
% 		'LineWidth',0.5,'LineStyle','none','Color','k',...
% 		'Marker','.','MarkerSize',10);
% 	view(ha,3);
% 	axis(ha,'equal');
% 	size_T_Points_after_triangulation_simplify	= size(T.Points)
% 	max_T_CL_after_triangulation_simplify			= max(T.ConnectivityList,[],'all')
% 	setbreakpoint=1;
% end

% Close small holes

% Maximum face area of holes: Holes that have a larger area will not be closed.
% No holes may be closed that are too large and could contain objects of a different color.
% Criterion: fa_hole_max must not be larger than general.sticks_strips_removal.minarea (=0.25)
% Note: The area of the hole in test_get_T_margin_errorlog_data_20240408_0658.mat thas has to be closed is 1.47e-5.
fa_hole_max				= min(PP_local.general.sticks_strips_removal.minarea/10,1e-3);

% Maximum number of edges at the margin of a hole: Larger holes are skipped.
% A suitable upper limit can significantly speed up the calculation.
% Note: The edge number of the hole in test_get_T_margin_errorlog_data_20240408_0658.mat thas has to be closed is 3.
no_e_cline_max			= 20;
% no_e_cline_max must be smaller than the number of edges of the outer boundary, so the outer boundary is not filled:
ishole_obj_poly_1_v	= ishole(obj.poly(1));
for ib=1:size(ishole_obj_poly_1_v,1)
	if ~ishole_obj_poly_1_v(ib,1)
		no_e_cline_max		= min(no_e_cline_max,numsides(obj.poly(1),ib)-1);
	end
end

% Count total number of closed holes:
no_closed_holes_total		= 0;
% Close holes:
plotvertno	= false;
[T,no_closed_holes,h_title,P_closedholes]	= stlrepair_close_holes(T,testplot,plotvertno,fa_hole_max,no_e_cline_max);
if testplot
	no_closed_holes_total	= no_closed_holes_total+no_closed_holes;
	h_title.String		= sprintf('%s\n%g holes closed',h_title.String,no_closed_holes_total);
end

% % Testing:
% if testplot~=0
% 	hf=figure(7472375);
% 	clf(hf,'reset');
% 	set(hf,'Tag','maplab3d_figure');
% 	ha=axes;
% 	hold(ha,'on');
% 	cameratoolbar(hf,'Show');
% 	facealpha	= 0.8;			% Transparenz der Oberflächen		0.2
% 	edgealpha	= 0.2;			% Transparenz der Kanten			0.2
% 	F_patch=[T.ConnectivityList(:,1) ...
% 		T.ConnectivityList(:,2) ...
% 		T.ConnectivityList(:,3) ...
% 		T.ConnectivityList(:,1)];
% 	patch(ha,'faces',F_patch,'vertices',T.Points,...
% 		'EdgeColor',[0 0 0],'FaceColor',[1 1 1]*0.95,'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
% 	% Stützstellen:
% 	plot3(ha,T.Points(:,1),T.Points(:,2),T.Points(:,3),...
% 		'LineWidth',0.5,'LineStyle','none','Color','k',...
% 		'Marker','.','MarkerSize',10);
% 	view(ha,3);
% 	axis(ha,'equal');
% 	size_T_Points_after_closeholes	= size(T.Points)
% 	max_T_CL_after_closeholes			= max(T.ConnectivityList,[],'all')
% 	setbreakpoint=1;
% end


%------------------------------------------------------------------------------------------------------------------
% Get the margin:
%------------------------------------------------------------------------------------------------------------------

method		= 1;
switch method
	case 1
		% -----------------------------------------------------------------------------------------------------------
		
		% Create a valid triangulation object:
		TR		=  triangulation(T.ConnectivityList,T.Points);
		
		% Triangulation edges:
		% E = edges(TR) returns the triangulation edges as a two-column matrix of vertex identification numbers.
		% Vertex identifications are the row numbers of the triangulation vertices in TR.Points.
		% The first column of E contains the starting vertex identification of each edge, and the second column
		% contains the ending vertex identification.
		E = edges(TR);
		
		% Triangles or tetrahedra attached to specified edge:
		% ID = edgeAttachments(TR,E) identifies the triangles or tetrahedra attached to the specified edges.
		% The return value ID identifies triangles by their identification numbers.
		E_id_edgeAttachments = edgeAttachments(TR,E);
		
		% Number of edge attachments at all edges:
		E_no_edgeAttachments	= zeros(size(E_id_edgeAttachments));
		for ie=1:size(E_id_edgeAttachments,1)
			E_no_edgeAttachments(ie,1)	= size(E_id_edgeAttachments{ie,1},2);
		end
		
		% Edge is at margin:
		E_is_at_margin		= false(size(E,1),1);
		
		% Example:
		% 		T.Points(1:5,:) = [30807×3 double]
		% 			-84.6806296782751         -37.4040777053927          4.57460097824702
		% 			-84.2625224482751         -36.7200019753927          4.61470081057102
		% 			-84.8466754282751         -36.3634511853927          4.57882254873505
		% 			-85.1755816482751         -37.1513970653927          4.54847449585226
		% 			-38.6296581482751         -26.8227098153927          4.61058987818048
		% 		T.ConnectivityList(1:5,:) = [35119×3 double]
		% 			1           2       11489
		% 			2       11488       11489
		% 			2           3       11488
		% 			3       11487       11488
		% 			3           4       11487
		%		E(1:5,:) = [66005x2 double]
		%        1           2
		%        1           4
		%        1          25
		%        1          26
		%        1        1822
		%		E_id_edgeAttachments{1:5,:}
		%			ans =		3883           1
		%			ans =    	7        3263
		%			ans =    3260        3272
		%			ans =    3263        3260
		%			ans =		5051        3883
		%		E_no_edgeAttachments(1:5,:)
		%     	2
		%     	2
		%     	2
		%     	2
		%     	2
		
		% Sort obj.poly(1) by area: So i_margin=1 is the outer margin:
		obj_poly1_sort				= sortboundaries(obj.poly(1),'area','descend');
		obj_poly1_sort				= poly_contour_ordering(obj_poly1_sort);
		nb_obj_poly1_sort			= numboundaries(obj_poly1_sort);
		ip_startpoint				= zeros(nb_obj_poly1_sort,1);
		ie_startpoint				= zeros(nb_obj_poly1_sort,1);
		iT_margin					= cell(1,nb_obj_poly1_sort);
		for i_margin = 1:nb_obj_poly1_sort
			
			% Search for the start point at the current boundary.
			% Result: ip_startpoint(i_margin,1): index in TR.Points
			[x,y]						= boundary(obj_poly1_sort,i_margin);
			x							= x(1:(end-1));
			y							= y(1:(end-1));
			% For testing, wether the points of the margin belong to the current polygon boundary:
			if GV.warnings_off
				warning('off','MATLAB:polyshape:repairedBySimplify');
			end
			poly1_imargin			= polyshape(x,y);
			if GV.warnings_off
				warning('on','MATLAB:polyshape:repairedBySimplify');
			end
			% Tolerance for searching the start point:
			% distance: minimum distance of the polygon boundary vertices to the points in TR.Points
			% The values of distance are normally =0, but in some cases =0.001/0.3/0.4/0.7.
			% This should be checked (repairedBySimplify?).
			distance	= ones(size(x,1),1)*1e10;
			for m=1:size(x,1)
				distance(m,1)		= min(sqrt(...
					(TR.Points(:,1)-x(m,1)).^2 + ...
					(TR.Points(:,2)-y(m,1)).^2       ));
			end
			[max_distance,~]		= max(distance);
			tol_startpoint			= max(GV.tol_1,2*max_distance);
			% Search the start point:
			startpoint_found		= false;
			margin_is_closedhole	= false;
			ixy						= 1;
			while (~startpoint_found)    &&...
					(~margin_is_closedhole)&&...
					(ixy<=size(x,1))
				% Search all points of the boundary x,y:
				ip_startpoint_v		= find(...
					(abs(TR.Points(:,1)-x(ixy,1))<tol_startpoint)&...
					(abs(TR.Points(:,2)-y(ixy,1))<tol_startpoint));
				for kp=1:size(ip_startpoint_v,1)
					% Search all points in TF.Points with the same coordinates x,y (and different z-values):
					ip_startpoint(i_margin,1)		= ip_startpoint_v(kp,1);
					if any(...
							(abs(P_closedholes(:,1)-TR.Points(ip_startpoint(i_margin,1),1))<GV.tol_1)&...
							(abs(P_closedholes(:,2)-TR.Points(ip_startpoint(i_margin,1),2))<GV.tol_1)&...
							(abs(P_closedholes(:,3)-TR.Points(ip_startpoint(i_margin,1),3))<GV.tol_1)    )
						% The current point belongs to the margin of a closed hole:
						% The boundary i_margin of obj.poly(1) does not exist any more.
						margin_is_closedhole	= true;
						break
					else
						% The current point does not belong to the margin of a closed hole:
						% Edges indices attached to the current point:
						ie_startpoint_v		= find(...
							(E(:,1)==ip_startpoint(i_margin,1))|...
							(E(:,2)==ip_startpoint(i_margin,1))    );
						for ke=1:size(ie_startpoint_v,1)
							% Search for edges at the margin:
							ie_startpoint(i_margin,1)		= ie_startpoint_v(ke,1);
							if    E_no_edgeAttachments(ie_startpoint(i_margin,1),1)==1
								startpoint_found		= true;
								break
							end
						end
						if startpoint_found
							break
						end
					end
				end
				ixy		= ixy+1;
			end
			
			if margin_is_closedhole
				% The current boundary i_margin belongs the a closed hole:
				% Skip the calculation of iT_margin{1,i_margin} and delete empty elements of iT_margin afterwards.
				
			else
				% The current boundary i_margin does not belong the a closed hole:
				
				if ~startpoint_found
					% Error:
					if isempty(errortext)
						errortext						= 'Startpoint not found';
					end
					get_iT_margin_error_occurred	= true;
					break
				end
				
				% Assign the start point:
				iT_margin{1,i_margin}	= ip_startpoint(i_margin,1);
				edge_km1						= [-1 -1];
				
				% Search for the whole boundary in TR.Points:
				boundary_found				= false;
				kmax							= size(TR.Points,1);
				kmax_cancel					= 2*size(TR.Points,1);
				k								= 0;
				ip_nextpoint_notfound	= 0;
				while (k<kmax)&&~boundary_found&&...
						(kmax<=kmax_cancel)		% maybe kmax will be increased
					k							= k+1;
					% Edges indices attached to the current point (iT_margin{1,i_margin}(end)):
					ie_v		= find(...
						(E(:,1)==iT_margin{1,i_margin}(end))|...		% Point 1 of the edge
						(E(:,2)==iT_margin{1,i_margin}(end))    );	% Point 2 of the edge
					% 				% For testing: start
					%				figure;ha=axes;title(ha,sprintf('ie=%g',ie));hold(ha,'on');plot(ha,poly1_imargin);plot(ha,T.Points(ip,1),T.Points(ip,2),'.r');
					% 				p_test					= [-14.499998 -5.46132485773004];
					% 				%                       -5.675722073546   8.87272523036021
					% 				if    (abs(p_test(1,1)-T.Points(iT_margin{1,i_margin}(end),1))<1e-4)&&...
					% 						(abs(p_test(1,2)-T.Points(iT_margin{1,i_margin}(end),2))<1e-4)
					% 					set_breakpoint		= 1;
					% 				end
					% 				% For testing: end
					dmin_poly_p_v			= ones(size(ie_v,1),1)*1e11;
					ip_v						= zeros(size(ie_v,1),1);
					for ke=1:size(ie_v,1)
						% Search for edges at the margin:
						ie		= ie_v(ke,1);
						if    (E_no_edgeAttachments(ie,1)==1)&&...		% The edge is at the margin.
								~isequal(E(ie,:),edge_km1)     &&...		% The edge is not the last added edge.
								~E_is_at_margin(ie,1)							% The edge does not belong the the margin yet.
							% Possible new point:
							edge_k										= E(ie,:);
							ip												= edge_k;			% ip: possible new point in T.Points(ip,:)
							ip(ip==iT_margin{1,i_margin}(end))	= [];
							ip_v(ke,1)									= ip;
							dmin_poly_p_v(ke,1)	= mindistance_poly_p(...
								poly1_imargin.Vertices(:,1),...		% vertices x
								poly1_imargin.Vertices(:,2),...		% vertices y
								T.Points(ip,1),...						% query points x
								T.Points(ip,2));							% query points y
						end
					end
					[dmin_poly_p,ke_dmin]	= min(dmin_poly_p_v);
					ie								= ie_v(ke_dmin,1);
					ip								= ip_v(ke_dmin,1);
					if (dmin_poly_p>1e10)||(ip==0)
						% Error:
						ip_nextpoint_notfound			= iT_margin{1,i_margin}(end);
						if isempty(errortext)
							errortext						= 'Next point not found';
						end
						get_iT_margin_error_occurred	= true;
						break
					else
						% The point ip belongs to the current polygon boundary:
						E_is_at_margin(ie,1)	= true;
					end
					% If a point appears twice on the margin: Do not stop here:
					if any(iT_margin{1,i_margin}==ip)
						kmax	= kmax+1;
					end
					% Add the new point to iT_margin and Termination criterion::
					if isequal(ip,iT_margin{1,i_margin}(1,1))
						boundary_found		= true;
					else
						iT_margin{1,i_margin}					= [iT_margin{1,i_margin};ip];
						edge_km1										= edge_k;
					end
				end
				
				while size(iT_margin{1,i_margin},1)~=size(unique(iT_margin{1,i_margin}),1)
					% There are points that appear twice on the margin.
					% This occurred in the form of narrow and tall individual triangles touching the margin at one point
					% ('test_get_T_margin_errorlog_data_20240304_0827').
					% Split the margin and use the part with the largest area:
					imax		= size(iT_margin{1,i_margin},1);
					for i=1:imax
						i_v	= find(iT_margin{1,i_margin}==iT_margin{1,i_margin}(i,1));
						if size(i_v,1)>1
							istart	= i;
							break
						end
					end
					% The point ip=iT_margin{1,i_margin}(istart,1) occurs several times on the margin:
					% Divide the margin into sections that start and end at this point:
					poly_margin		= polyshape();
					i_v_pm			= cell(0,1);
					i_pm				= 1;
					x					= [];
					y					= [];
					i_v_pm{i_pm,1}	= [];		% Indices in iT_margin{1,i_margin} of each section
					for i=(istart+1):(istart+imax)
						irest				= vindexrest(i,imax);
						ip					= iT_margin{1,i_margin}(irest,1);
						x					= [x;T.Points(ip,1)];
						y					= [y;T.Points(ip,2)];
						i_v_pm{i_pm,1}	= [i_v_pm{i_pm,1};irest];
						i_v				= find(iT_margin{1,i_margin}==iT_margin{1,i_margin}(irest,1));
						if size(i_v,1)>1
							poly_margin(i_pm,1)	= polyshape(x,y);
							if i<(istart+imax)
								i_pm						= i_pm+1;
								x							= [];
								y							= [];
								i_v_pm{i_pm,1}			= [];
							end
						end
					end
					% Assign the section with largest area:
					[~,i_pm_areamax]			= max(area(poly_margin));
					iT_margin{1,i_margin}	= iT_margin{1,i_margin}(i_v_pm{i_pm_areamax,1},1);
				end
				
				if ~boundary_found
					% Error:
					if isempty(errortext)
						errortext						= 'Boundary not found';
					end
					get_iT_margin_error_occurred	= true;
					break
				end
				if get_iT_margin_error_occurred
					break
				end
				
			end
			
		end
		
		% iT_margin is now calculated!
		
		% Delete empty elements of iT_margin.
		% This can happen, if a boundary i_margin belongs the a closed hole.
		i_delete	= false(1,size(iT_margin,2));
		for i_margin=1:size(iT_margin,2)
			if isempty(iT_margin{1,i_margin})
				i_delete(1,i_margin)	= true;
			end
		end
		iT_margin(i_delete)		= [];
		if isempty(iT_margin)
			% All boundaries seem to belong to closed holes.
			% This should not happen, because the outer boundary will not be closed
			% (see calculation of no_e_cline_maxand call of stlrepair_close_holes).
			errormessage;
		end
		
		% Delete points or triangles outside the margins:
		% This can happen because of the simplifikation with GV.tol_tp.
		if ~get_iT_margin_error_occurred
			poly_margin		= polyshape();
			warning('off','MATLAB:polyshape:repairedBySimplify');
			for i_margin = 1:size(iT_margin,2)
				poly_margin		= addboundary(poly_margin,...
					T.Points(iT_margin{1,i_margin},1),...
					T.Points(iT_margin{1,i_margin},2));
			end
			warning('on','MATLAB:polyshape:boundary3Points');
			poly_margin		= polybuffer(poly_margin,GV.tol_tp+GV.tol_1,'JointType','miter','MiterLimit',3);
			% % % 			% Testing:
			% % % 			tic
			% % % 			xtest		= max(T.Points(:,1))+1;
			% % % 			iTm		= iT_margin{1,i_margin}(1,1)
			% % % 			T.Points	= [T.Points(iTm,:);xtest 1 1;xtest 2 2;xtest 3 3;T.Points;xtest 4 4;xtest 5 5;xtest 6 6];
			% % % 			T.ConnectivityList	= T.ConnectivityList+4;
			% % % 			size_T_Points			= size(T.Points)
			% % % 			max_T_CL					= max(T.ConnectivityList,[],'all')
			method	= 2;
			switch method
				case 1
					r		= 0;
					while r<size(T.Points,1)
						r		= r+1;
						if ~inpolygon(...
								T.Points(r,1),...						% xq (query points)
								T.Points(r,2),...						% yq
								poly_margin.Vertices(:,1),...		% xv (polygon area)
								poly_margin.Vertices(:,2))			% yv
							% Delete triangles with this point:
							iCL								= any(T.ConnectivityList==r,2);
							T.ConnectivityList(iCL,:)	= [];
							% Delete this point:
							iCL								= T.ConnectivityList>r;
							T.ConnectivityList(iCL)		= T.ConnectivityList(iCL)-1;
							T.Points(r,:)					= [];
							itm								= iT_margin{1,i_margin}>r;
							iT_margin{1,i_margin}(itm)	= iT_margin{1,i_margin}(itm)-1;
							r		= r-1;
						end
					end
				case 2
					% 50 times faster:
					% Only the triangles outside the margin are deleted, not the points.
					Points_inside_v					= inpolygon(...
						T.Points(:,1),...										% xq (query points)
						T.Points(:,2),...										% yq
						poly_margin.Vertices(:,1),...						% xv (polygon area)
						poly_margin.Vertices(:,2));						% yv
					
					% % % 										% Testing:
					% % % 										figure
					% % % 										gca
					% % % 										plot(obj.poly(1))
					% % % 										hold on
					% % % 										iTni=find(~Points_inside_v)
					% % % 										plot(T.Points(iTni,1),T.Points(iTni,2),'LineWidth',2,'LineStyle','none','Color','b','Marker','+','MarkerSize',15);
					% % % 										for i_margin=1:size(iT_margin,2)
					% % % 										iT	= iT_margin{1,i_margin};
					% % % 										plot(T.Points(iT,1),T.Points(iT,2),'LineWidth',2,'LineStyle','-','Color','r','Marker','.','MarkerSize',10);
					% % % 										plot(T.Points(:,1),T.Points(:,2),'LineWidth',2,'LineStyle','none','Color','k','Marker','.','MarkerSize',10);
					% % % 										end
					% % % 										axis equal
					% % % 										setbreakpoint1	= 1;
					
					% Testplot: save the edges where the margins start:
					if (nargin==0)||(testplot~=0)
						E_startpoints	= zeros(size(iT_margin,2),6);
						for i_margin = 1:size(iT_margin,2)
							E_startpoints(i_margin,1:3)	= T.Points(E(ie_startpoint(i_margin,1),1),:);
							E_startpoints(i_margin,4:6)	= T.Points(E(ie_startpoint(i_margin,1),2),:);
							if testout_i_margin~=0
								fprintf(1,'i_margin=%g\n%s\n%s\n',...
									i_margin,...
									num2str(T.Points(E(ie_startpoint(i_margin,1),1),:)),...
									num2str(T.Points(E(ie_startpoint(i_margin,1),2),:))    );
							end
						end
					end
					
					% Delete triangles, that touch the points outside:
					% This step can cause holes at the margin if, due to rounding of positions, a point lies outside
					% the margin and does not itself belong to the margin.
					ip_delete_v	= find(~Points_inside_v);
					if ~isempty(ip_delete_v)&&~isdeployed
						% Normally this should not happen.
						% The cause maybe should be found and fixed during development and testing.
						hf=figure(7472380);
						clf(hf,'reset');
						set(hf,'Tag','maplab3d_figure');
						ha=axes;
						hold(ha,'on');
						cameratoolbar(hf,'Show');
						axis(ha,'equal');
						plot(ha,obj.poly(1))
						hold(ha,'on');
						iTni=find(~Points_inside_v);
						plot(ha,T.Points(iTni,1),T.Points(iTni,2),'LineWidth',2,'LineStyle','none','Color','b',...
							'Marker','+','MarkerSize',15);
						for i_margin=1:size(iT_margin,2)
							iT	= iT_margin{1,i_margin};
							plot(ha,T.Points(iT,1),T.Points(iT,2),'LineWidth',2,'LineStyle','-','Color','r',...
								'Marker','.','MarkerSize',10);
							plot(ha,T.Points(:,1),T.Points(:,2),'LineWidth',2,'LineStyle','none','Color','k',...
								'Marker','.','MarkerSize',10);
						end
						title('get_T_margin: points outside the margin','Interpreter','none');
						setbreakpoint	= 1;
						% Cancel and save errorlog in map2stl_topside_triangulation:
						var_cancel_1	= 0;
						var_cancel_2	= var_cancel_1(2);
						% errormessage;
					end
					for i=1:length(ip_delete_v)
						[r_delete,~]	= find(T.ConnectivityList==ip_delete_v(i));
						T.ConnectivityList(r_delete,:)	= [];
					end
					
					% Delete points outside:
					% It is possible that points remain that lie within the margin but are still not referenced by
					% the triangulation. Keep only the points that are referenced by the triangulation:
					method	= 2;
					[T,ic]	= triangulation_delete_not_referenced_points(T,method);
					
					% Update the following values ​​because T may have changed:
					% iT_margin
					% ip_nextpoint_notfound (only testplot)
					% ip_startpoint         (only testplot)
					% ie_startpoint         (only testplot)
					for i_margin = 1:size(iT_margin,2)
						iT_margin{1,i_margin}		= ic(iT_margin{1,i_margin});
					end
					if (nargin==0)||(testplot~=0)
						% ip_nextpoint_notfound:
						if ip_nextpoint_notfound>0
							ip_nextpoint_notfound		= ic(ip_nextpoint_notfound);
						end
						% ip_startpoint:
						for i_margin = 1:size(iT_margin,2)
							ip_startpoint(i_margin,1)	= ic(ip_startpoint(i_margin,1));
						end
						% ie_startpoint:
						% Create a valid triangulation object:
						TR		=  triangulation(T.ConnectivityList,T.Points);
						% Triangulation edges:
						E = edges(TR);
						for i_margin = 1:size(iT_margin,2)
							ip1		= find(...
								(abs(T.Points(:,1)-E_startpoints(i_margin,1))<GV.tol_1)&...
								(abs(T.Points(:,2)-E_startpoints(i_margin,2))<GV.tol_1)&...
								(abs(T.Points(:,3)-E_startpoints(i_margin,3))<GV.tol_1)     );
							if isempty(ip1)
								errormessage;
							end
							ip2		= find(...
								(abs(T.Points(:,1)-E_startpoints(i_margin,4))<GV.tol_1)&...
								(abs(T.Points(:,2)-E_startpoints(i_margin,5))<GV.tol_1)&...
								(abs(T.Points(:,3)-E_startpoints(i_margin,6))<GV.tol_1)     );
							if isempty(ip2)
								errormessage;
							end
							ie			= find(...
								(abs(E(:,1)-ip1)<GV.tol_1)&...
								(abs(E(:,2)-ip2)<GV.tol_1)    );
							if ~isempty(ip2)
								ie_startpoint(i_margin,1)	= ie;
							else
								errormessage;
							end
						end
						if testout_i_margin~=0
							for i_margin = 1:size(iT_margin,2)
								fprintf(1,'i_margin=%g\n%s\n%s\n',i_margin,...
									num2str(T.Points(E(ie_startpoint(i_margin,1),1),:)),...
									num2str(T.Points(E(ie_startpoint(i_margin,1),2),:)));
							end
						end
					end
					
			end
			% 			% Testing:
			% 			toc
			% 			size_T_Points			= size(T.Points)
			% 			max_T_CL					= max(T.ConnectivityList,[],'all')
			% 			iT_margin_max			= 0;
			% 			for i_margin = 1:size(iT_margin,2)
			% 				iT_margin_imargin_max	= max(iT_margin{1,i_margin});
			% 				iT_margin_max				= max(iT_margin_max,iT_margin_imargin_max);
			% 			end
			% 			iT_margin_max
			% 			setbreakpoint			= 1;
		end
		
		
	case 2
		% -----------------------------------------------------------------------------------------------------------
		% old, not reliable:
		
		% ifs_tb: Index of the tile base filter settings in ELE_local.elefiltset.
		color_prio_v		= [PP_local.color.prio];
		icol_tilebase		= find(color_prio_v==0,1);
		icolspec_tilebase	= PP_local.color(icol_tilebase,1).spec;		% should be =1
		ifs_tb				= ELE_local.ifs_v(icolspec_tilebase,1);
		
		% Bei dem Fehler, dass der geringste Abstand (min_distance) überschritten wird:
		% Versuche verschiedene Kombinationen von Einstellungen:
		tlpb_def	= 5e-6;				% tol_polybuffer: 1e-6 doesn't work reliably, 2e-6 seems to work, choice: 5e-6
		dmax_def	= min([...
			ELE_local.elefiltset(ifs_tb,1).dx_mm ...
			ELE_local.elefiltset(ifs_tb,1).dy_mm    ])/10;		% dmax
		nmin_def	= 5;															% nmin
		tolerances	= [...						% Diese Liste wird zeilenweise ausprobiert.
			tlpb_def	dmax_def	nmin_def 0;...
			1e-5		dmax_def	nmin_def 0;...
			1e-6		dmax_def	nmin_def 0;...
			1e-7		dmax_def	nmin_def 0;...
			1e-8		dmax_def	nmin_def 0;...
			1e-9		dmax_def	nmin_def 0;...
			1e-10		dmax_def	nmin_def 0;...
			1e-5		dmax_def	nmin_def 0.05;...
			1e-6		dmax_def	nmin_def 0.05;...
			1e-7		dmax_def	nmin_def 0.05;...
			1e-5		dmax_def	nmin_def 0.01;...
			1e-6		dmax_def	nmin_def 0.01;...
			1e-7		dmax_def	nmin_def 0.01;...
			1e-5		dmax_def	nmin_def 0.1;...
			1e-6		dmax_def	nmin_def 0.1;...
			1e-7		dmax_def	nmin_def 0.1];
		row_tolerances					= 0;
		margin_min_distance_error			= true;
		margin_unknown_error_occurred		= true;
		while (margin_unknown_error_occurred||margin_min_distance_error)&&(row_tolerances<size(tolerances,1))
			margin_min_distance_error		= false;
			margin_unknown_error_occurred	= false;
			row_tolerances				= row_tolerances+1;
			tol_polybuffer				= tolerances(row_tolerances,1);
			dmax							= tolerances(row_tolerances,2);
			nmin							= tolerances(row_tolerances,3);
			ktol_slivers				= tolerances(row_tolerances,4);
			
			% obj.poly(1) nach Fläche sortieren: So ist i_margin=1 der äußere Rand:
			obj_poly1_sort				= sortboundaries(obj.poly(1),'area','descend');
			nb_obj_poly1_sort			= numboundaries(obj_poly1_sort);
			obj_poly_1_mtol			= cell(nb_obj_poly1_sort,1);
			obj_poly_1_ptol			= cell(nb_obj_poly1_sort,1);
			T_margin_cell					= cell(nb_obj_poly1_sort,1);
			for i_margin = 1:nb_obj_poly1_sort
				T_margin_cell{i_margin,1}			= cell(0,1);
				[x,y]									= boundary(obj_poly1_sort,i_margin);
				x										= x(1:(end-1));
				y										= y(1:(end-1));
				% [x,y]									= poly2ccw(x,y);
				obj_poly_1							= polyshape(x,y,'KeepCollinearPoints',true);
				obj_poly_1_mtol{i_margin,1}	= polybuffer(obj_poly_1,-tol_polybuffer,'JointType','miter','MiterLimit',3);
				obj_poly_1_ptol{i_margin,1}	= polybuffer(obj_poly_1, tol_polybuffer,'JointType','miter','MiterLimit',3);
			end
			% Wenn ein kleines Objekt nur zwischen 2 Stützpunkten der Randlinie obj.poly(1) liegt, kann es passieren,
			% dass der Rand iT_margin hier nicht richtig berechnet wird.
			% Um die Wahrscheinlichkeit für diesen Fehler zu verringern, wird die Auflösung erhöht:
			for iobj=1:length(obj_bot_bh_reg.poly)
				% Increase resolution:
				poly_iobj		= changeresolution_poly(obj_bot_bh_reg.poly(iobj),dmax,[],nmin);
				for ib_obj = 1:numboundaries(poly_iobj)
					% vertices of object 1, boundary ib_obj1:
					[xb,yb]			= boundary(poly_iobj,ib_obj);
					if ktol_slivers>0
						% In one case there were slivers that leaded to unexplainable results.
						% Removing the slivers worked.
						polyb			= polyshape(xb(2:end),yb(2:end),'KeepCollinearPoints',true,'Simplify',false);
						polyb_buff1	= polybuffer(polyb      ,   tol_polybuffer,'JointType','miter','MiterLimit',3);
						polyb_buff2	= polybuffer(polyb_buff1,-2*tol_polybuffer,'JointType','miter','MiterLimit',3);
						polyb_buff3	= polybuffer(polyb_buff2,   tol_polybuffer,'JointType','miter','MiterLimit',3);
						polyb_mtol	= polybuffer(polyb_buff3,-tol_polybuffer*ktol_slivers,'JointType','miter','MiterLimit',3);
						polyb_ptol	= polybuffer(polyb_buff3, tol_polybuffer*ktol_slivers,'JointType','miter','MiterLimit',3);
						i2_in		= inpolygon(...
							xb,...										% query points
							yb,...										% query points
							polyb_mtol.Vertices(:,1),...			% edges of the polygon area
							polyb_mtol.Vertices(:,2));				% edges of the polygon area
						i2_out		= inpolygon(...
							xb,...										% query points
							yb,...										% query points
							polyb_ptol.Vertices(:,1),...			% edges of the polygon area
							polyb_ptol.Vertices(:,2));				% edges of the polygon area
						i2			= ~i2_out|i2_in;					% i2: indices of points in polyb inside of outside the tolerance
						xb(i2,:)	= [];
						yb(i2,:)	= [];
					end
					if size(xb,1)>=3
						if ishole(poly_iobj,ib_obj)
							% Convert polygon contour to clockwise vertex ordering:
							[xb_ordered,yb_ordered]	= poly2cw(xb,yb);
							xb_ordered(end)			= [];
							yb_ordered(end)			= [];
						else
							% Convert polygon contour to counterclockwise vertex ordering:
							[xb_ordered,yb_ordered]	= poly2ccw(xb,yb);
							xb_ordered(end)			= [];
							yb_ordered(end)			= [];
						end
						% Randlinien zusammensetzen:
						for i_margin = 1:nb_obj_poly1_sort
							% Find Points on the poly_map_printout of the base part obj.poly(1):
							i_in		= inpolygon(...
								xb_ordered,...												% query points
								yb_ordered,...												% query points
								obj_poly_1_mtol{i_margin,1}.Vertices(:,1),...	% edges of the polygon area
								obj_poly_1_mtol{i_margin,1}.Vertices(:,2));		% edges of the polygon area
							i_out		= inpolygon(...
								xb_ordered,...												% query points
								yb_ordered,...												% query points
								obj_poly_1_ptol{i_margin,1}.Vertices(:,1),...	% edges of the polygon area
								obj_poly_1_ptol{i_margin,1}.Vertices(:,2));		% edges of the polygon area
							i			= i_out&~i_in;		% i: Indices in [xb_ordered,yb_ordered] auf dem Rand des zu druckenden Teils
							% 					% Testing start:
							% 					if iobj==15
							% 						hf=figure(59398765);
							% 						clf(hf,'reset');
							%						set(hf,'Tag','maplab3d_figure');
							% 						ha=axes(hf);hold(ha,'on');
							% 						plot(ha,obj.poly(1));
							% 						plot(ha,obj_poly_1_mtol{i_margin,1}.Vertices(:,1),obj_poly_1_mtol{i_margin,1}.Vertices(:,2),'-.b');
							% 						plot(ha,obj_poly_1_ptol{i_margin,1}.Vertices(:,1),obj_poly_1_ptol{i_margin,1}.Vertices(:,2),'-.r');
							% 						plot(ha,xb_ordered(:),yb_ordered(:),'.-m','MarkerSize',17,'LineWidth',2)
							% 						plot(ha,xb_ordered(i),yb_ordered(i),'xm')
							% 						plot(ha,poly_iobj.Vertices(i2,1),poly_iobj.Vertices(i2,2),'xm','MarkerSize',13)
							% 						axis equal
							% 						if ib_obj>=17
							% 							length(find(i))
							% 							row_tolerances
							% 							ib_obj
							% 							set_breakpoint	= 1;
							% 						end
							% 					end
							% 					% Testing end
							if ~isempty(find(i,1))
								if isequal(i,true(size(i)))
									% Das Objekt liegt vollständig auf dem Rand:
									kstart_v	= 1;
									kend_v	= length(i);
								else
									% Zusammenhängende Abschnitte auf dem Rand in T_margin_cell{i_margin,1} sammeln:
									k_v		= (1:length(i))';
									km1_v		= vindexrest(k_v-1,length(i));
									kp1_v		= vindexrest(k_v+1,length(i));
									kstart_v	= find(i(k_v)&~i(km1_v));
									kend_v	= find(i(k_v)&~i(kp1_v));
									% Sortierung anpassen, dass die Elemente in kstart_vund kend_v zueinander korrespondieren:
									if min(kend_v)<min(kstart_v)
										kend_v	= [kend_v(2:end);kend_v(1)+length(i)];
									end
								end
								for r=1:length(kstart_v)
									k_margin	= vindexrest(kstart_v(r):kend_v(r),length(i));
									T_margin_cell{i_margin,1}{end+1,1}	= add_z_2_poly(colprio_base,...
										[xb_ordered(k_margin) yb_ordered(k_margin)],...
										obj_bot_bh_reg.zmin(iobj),...
										obj_bot_bh_reg.dz(iobj),...
										obj_bot_bh_reg.zbotmax(iobj),...
										obj_bot_bh_reg.colno(iobj),...
										PP_local,ELE_local,poly_legbgd);
									% Testplots in obj_bot_bh_reg:
									% if testplot_obj_bot_bh_reg==1
									%	if any(iobj_v_ha1_obj_bot_bh_reg==iobj)
									%		plot(ha1_obj_bot_bh_reg(iobj),xb_ordered(k_margin)   ,yb_ordered(k_margin)   ,'-r');
									%		plot(ha1_obj_bot_bh_reg(iobj),xb_ordered(kstart_v(r)),yb_ordered(kstart_v(r)),'xr');
									%		kend_v_r	= vindexrest(kend_v,length(i));
									%		plot(ha1_obj_bot_bh_reg(iobj),xb_ordered(kend_v_r)   ,yb_ordered(kend_v_r)   ,'sr');
									%	end
									% end
								end
							end
						end
					end
				end
			end
			
			% Die einzelnen zusammenhängenden Abschnitte auf dem Rand in der richtigen Reihenfolge zusammensetzen:
			for i_margin = 1:nb_obj_poly1_sort
				if size(T_margin_cell,1)<i_margin
					margin_unknown_error_occurred	= true;
					break
				end
				if isempty(T_margin_cell{i_margin,1})
					margin_unknown_error_occurred	= true;
					break
				end
				T_margin{1,i_margin}		= T_margin_cell{i_margin,1}{1,1};
				k_v							= (2:size(T_margin_cell{i_margin,1},1))';
				while ~isempty(k_v)
					distance	= ones(size(k_v))*1e10;
					for m=1:length(k_v)
						distance(m,1)		= sqrt(...
							(T_margin{1,i_margin}(end,1)-T_margin_cell{i_margin,1}{k_v(m),1}(1,1))^2 + ...
							(T_margin{1,i_margin}(end,2)-T_margin_cell{i_margin,1}{k_v(m),1}(1,2))^2       );
					end
					[min_distance,mopt]	= min(distance);
					kopt						= k_v(mopt);
					% 			% Testing start:
					% 			disp('Test -------------------------');
					% 			k_v
					% 			k_v_m=k_v(m)
					% 			distance
					% 			mopt
					% 			kopt
					% 			margin_cell_kopt=T_margin_cell{i_margin,1}{kopt,1}(end,:)
					% 			% Testing end
					if size(T_margin_cell{i_margin,1}{kopt,1},1)>1
						% Zwei Randstücke zusammensetzen.
						% Wenn ein Element in T_margin_cell{i_margin,1}{kopt,1} nur aus einer Zeile besteht: überspringen.
						T_margin{1,i_margin}	= [T_margin{1,i_margin};T_margin_cell{i_margin,1}{kopt,1}];
					end
					k_v(mopt)	= [];
					% fprintf(1,'min_distance=%g\n',min_distance)
					min_distance_tol	= GV.tol_1;
					if min_distance>GV.tol_1			% min_distance>GV.tol_1*10
						% Fehler wegen Überschreitungen des minimalen Abstands:
						testing			= false;				% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						if (row_tolerances==size(tolerances,1))&&testing
							% Das war der letzte Versuch: Abbruch:
							%---------------------------------------------------------------------------------------------------
							% Fehler beim Zusammensetzen der Randlinie: T_margin_cell{i_margin,1} ist fehlerhaft
							fprintf(1,'\nError: min_distance>%g:\n',min_distance_tol);
							fprintf(1,'currpart_i_tile   =%g\n',currpart_i_tile   );
							fprintf(1,'currpart_i_colprio=%g\n',currpart_i_colprio);
							fprintf(1,'currpart_i_part   =%g\n',currpart_i_part   );
							fprintf(1,'currpart_i_part   =%g\n',currpart_i_part   );
							fprintf(1,'row_tolerances    =%g\n',row_tolerances    );
							fprintf(1,'tol_polybuffer    =%g\n',tol_polybuffer    );
							fprintf(1,'dmax              =%g\n',dmax              );
							fprintf(1,'nmin              =%g\n',nmin              );
							fprintf(1,'min_distance      =%g\n',min_distance      );
							if testing
								haerror	= findobj('Tag','axes_error_min_distance_margin');
								if isempty(haerror)
									hferror=figure;
									clf(hferror,'reset');
									set(hferror,'Tag','maplab3d_figure');
									haerror=axes(hferror);
									set(haerror,'Tag','axes_error_min_distance_margin');
									hold(haerror,'on');
									axis(haerror,'equal');
								else
									XLim_axes	= haerror.XLim;
									YLim_axes	= haerror.YLim;
									cla(haerror);
									haerror.XLim	= XLim_axes;
									haerror.YLim	= YLim_axes;
									legend(haerror,'off');
								end
								plot(haerror,obj.poly(1));
								plot(haerror,obj_poly_1_mtol{i_margin,1});
								plot(haerror,obj_poly_1_ptol{i_margin,1});
								% blau: obj.poly(1)
								plot(haerror,obj.poly(1).Vertices(:,1),obj.poly(1).Vertices(:,2),'.-b');
								% grün: margin: o: Anfang, s: Ende
								hlegend	= plot(haerror,T_margin{1,i_margin}(:,1),T_margin{1,i_margin}(:,2),...
									'LineStyle','-','LineWidth',4,'Marker','.','MarkerSize',30,'Color','g');
								if ~isempty(hlegend)
									hlegenderror(2)	= hlegend(1);
								end
								plot(haerror,T_margin{1,i_margin}(1,1),T_margin{1,i_margin}(1,2),...
									'LineStyle','-','LineWidth',4,'Marker','o','MarkerSize',20,'Color','g');
								plot(haerror,T_margin{1,i_margin}(end,1),T_margin{1,i_margin}(end,2),...
									'LineStyle','-','LineWidth',4,'Marker','s','MarkerSize',20,'Color','g');
								% rot: T_margin_cell:
								hlegend	= plot(haerror,T_margin_cell{i_margin,1}{kopt,1}(:,1),T_margin_cell{i_margin,1}{kopt,1}(:,2),...
									'LineStyle','--','LineWidth',2,'Marker','.','MarkerSize',30,'Color','r');
								if ~isempty(hlegend)
									hlegenderror(1)	= hlegend(1);
								end
								plot(haerror,T_margin_cell{i_margin,1}{kopt,1}(1,1),T_margin_cell{i_margin,1}{kopt,1}(1,2),...
									'LineStyle','--','LineWidth',2,'Marker','o','MarkerSize',12,'Color','r');
								% cyan: obj_bot_reg
								for iobj=1:length(obj_bot_reg.poly)
									hlegend	= plot(haerror,...
										obj_bot_reg.poly(iobj).Vertices(:,1),...
										obj_bot_reg.poly(iobj).Vertices(:,2),...
										'LineStyle','-','LineWidth',0.5,'Marker','.','MarkerSize',12,'Color','c');
									if ~isempty(hlegend)
										hlegenderror(3)	= hlegend(1);
									end
								end
								% magenta: obj_bot_bh
								for iobj=1:length(obj_bot_bh.poly)
									hlegend	= plot(haerror,...
										obj_bot_bh.poly(iobj).Vertices(:,1),...
										obj_bot_bh.poly(iobj).Vertices(:,2),...
										'LineStyle','--','LineWidth',0.5,'Marker','.','MarkerSize',12,'Color','m');
									if ~isempty(hlegend)
										hlegenderror(4)	= hlegend(1);
									end
								end
								linestyle_xyb_ordered	= {'--';':';'-.'};
								color_xyb_ordered		= {'b';'g';'r'};
								marker_xyb_ordered		= {'+';'x';'o'};
								k_style_xyb_ordered		= 1;
								title_str			= 'xb_ordered, yb_ordered (obj_bot_bh_reg)';
								for iobj=1:length(obj_bot_bh_reg.poly)
									for ib_obj = 1:numboundaries(obj_bot_bh_reg.poly(iobj))
										% Auflösung erhöhen:
										poly_iobj		= changeresolution_poly(obj_bot_bh_reg.poly(iobj),dmax,[],nmin);
										% vertices of object 1, boundary ib_obj1:
										[xb,yb]			= boundary(poly_iobj,ib_obj);
										if ishole(poly_iobj,ib_obj)
											% Convert polygon contour to clockwise vertex ordering:
											[xb_ordered,yb_ordered]	= poly2cw(xb,yb);
											xb_ordered(end)			= [];
											yb_ordered(end)			= [];
										else
											% Convert polygon contour to counterclockwise vertex ordering:
											[xb_ordered,yb_ordered]	= poly2ccw(xb,yb);
											xb_ordered(end)			= [];
											yb_ordered(end)			= [];
										end
										% Find Points on the margin of the base part obj.poly(1):
										i_in		= inpolygon(...
											xb_ordered,...										% query points
											yb_ordered,...										% query points
											obj_poly_1_mtol{i_margin,1}.Vertices(:,1),...		% edges of the polygon area
											obj_poly_1_mtol{i_margin,1}.Vertices(:,2));			% edges of the polygon area
										i_out		= inpolygon(...
											xb_ordered,...										% query points
											yb_ordered,...										% query points
											obj_poly_1_ptol{i_margin,1}.Vertices(:,1),...		% edges of the polygon area
											obj_poly_1_ptol{i_margin,1}.Vertices(:,2));			% edges of the polygon area
										i			= i_out&~i_in;
										h_xyb_ordered1	= plot(haerror,xb_ordered,yb_ordered,...
											'LineStyle',linestyle_xyb_ordered{k_style_xyb_ordered},...
											'LineWidth',2,'Marker','.','MarkerSize',14,...
											'Color',color_xyb_ordered{k_style_xyb_ordered});
										h_xyb_ordered2	= plot(haerror,xb_ordered(i),yb_ordered(i),...
											'LineStyle','none','LineWidth',2,'Marker',marker_xyb_ordered{k_style_xyb_ordered},...
											'MarkerSize',10,...
											'Color',color_xyb_ordered{k_style_xyb_ordered});
										set(haerror,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
										set(haerror,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
										title(haerror,title_str,'Interpreter','none');
										legend(haerror,...
											hlegenderror,...
											sprintf('T_margin_cell{i_margin=%g,1}{kopt=%g,1}',i_margin,kopt),...
											'T_margin',...
											'obj_bot_reg',...
											'obj_bot_bh',...
											'Interpreter','none');
										figure(haerror.Parent);
										answer	= [];
										while isempty(answer)
											question	= sprintf('iobj=%g/%g, ib_obj=%g/%g',...
												iobj,length(obj_bot_bh_reg.poly),ib_obj,numboundaries(obj_bot_bh_reg.poly(iobj)));
											answer	= questdlg_local(question,'Continue?','Continue','Add','Cancel','Continue');
										end
										if strcmp(answer,'Add')
											title_str	= [title_str '  /  ' sprintf('%s: iobj=%g, ib_obj=%g',...
												color_xyb_ordered{k_style_xyb_ordered},iobj,ib_obj)];
											k_style_xyb_ordered	= vindexrest(k_style_xyb_ordered+1,3);
										else
											delete(h_xyb_ordered1);
											delete(h_xyb_ordered2);
										end
										if strcmp(answer,'Cancel')
											break
										end
									end
									if strcmp(answer,'Cancel')
										break
									end
								end
								errormessage;
							end
							%---------------------------------------------------------------------------------------------------------
						else
							% Das war noch nicht der letzte Versuch:
							% Nächste Kombination von Einstellungen ausprobieren:
							margin_min_distance_error	= true;
						end
					end
				end
				
				% doppelte Punkte in T_margin löschen:
				k_margin_delete		= [];
				for k=1:size(T_margin{1,i_margin},1)
					ktest_logical			= ...
						(abs(T_margin{1,i_margin}(:,1)-T_margin{1,i_margin}(k,1))<GV.tol_1) & ...
						(abs(T_margin{1,i_margin}(:,2)-T_margin{1,i_margin}(k,2))<GV.tol_1) & ...
						(abs(T_margin{1,i_margin}(:,3)-T_margin{1,i_margin}(k,3))<GV.tol_1);
					ktest_logical(1:k)	= false;
					ktest						= find(ktest_logical);
					if ~isempty(ktest)
						k_margin_delete				= [k_margin_delete;ktest(:)];
					end
				end
				T_margin{1,i_margin}(k_margin_delete,:)		= [];
				% iT_margin: row-indices of the margin in T.Points:
				iT_margin{1,i_margin}	= zeros(0,1);
				for k=1:size(T_margin{1,i_margin},1)
					i	= find(...
						(abs(T.Points(:,1)-T_margin{1,i_margin}(k,1))<GV.tol_1) & ...
						(abs(T.Points(:,2)-T_margin{1,i_margin}(k,2))<GV.tol_1) & ...
						(abs(T.Points(:,3)-T_margin{1,i_margin}(k,3))<GV.tol_1)       );
					if length(i)==1
						iT_margin{1,i_margin}	= [iT_margin{1,i_margin};i];
					end
				end
			end
			
		end
		
		get_iT_margin_error_occurred	= (margin_unknown_error_occurred||margin_min_distance_error);
		
end

% Plausibility check:
for i_margin=1:size(iT_margin,2)
	if max(iT_margin{1,i_margin})>size(T.Points,1)
		disp('Error: max(iT_margin{1,i_margin})>size(T.Points,1) !!!');
		get_iT_margin_error_occurred	= true;
	end
end


% Testplot:
if (nargin==0)||(testplot~=0)
	
	testplot_T(15672415,obj,T0,[]       ,[],[]           ,[]           ,'get_T_margin: T0',errortext,...
		ip_nextpoint_notfound);
	testplot_T(15672416,obj,T ,iT_margin,E ,ie_startpoint,ip_startpoint,'get_T_margin: T' ,errortext,...
		ip_nextpoint_notfound);
	get_iT_margin_error_occurred
	setbreakpoint=1;
	
end



function testplot_T(hf,obj,T,iT_margin,E,ie_startpoint,ip_startpoint,title_str,errortext,ip_nextpoint_notfound)
% testplot_T(15672416,obj,T ,iT_margin,[],[],[],'get_T_margin: T' ,[],0);
% iTni=find(~Points_inside_v);
% plot3(gca,T.Points(iTni,1),T.Points(iTni,2),T.Points(iTni,3),'LineWidth',2,'LineStyle','none','Color','b','Marker','+','MarkerSize',15);

hf		= figure(hf);
clf(hf,'reset');
set(hf,'Tag','maplab3d_figure');
set(hf,'Name','Test');
set(hf,'NumberTitle','off');
cameratoolbar(hf,'Show');
ha		= axes(hf);
hold(ha,'on');
xlabel(ha,'x / mm');
ylabel(ha,'y / mm');
zlabel(ha,'z / mm');
if ~isempty(errortext)
	title_str	= sprintf('%s\n%s',title_str,errortext);
end
title(ha,title_str,'Interpreter','none');
facealpha	= 0.8;			% Transparenz der Oberflächen		0.2
edgealpha	= 0.2;			% Transparenz der Kanten			0.2
% % Polygon obj.poly(1):
% plot(ha,obj.poly(1));
% Triangulationsdaten:
F_patch=[T.ConnectivityList(:,1) ...
	T.ConnectivityList(:,2) ...
	T.ConnectivityList(:,3) ...
	T.ConnectivityList(:,1)];
patch(ha,'faces',F_patch,'vertices',T.Points,...
	'EdgeColor',[0 0 0],'FaceColor',[1 1 1]*0.95,'FaceAlpha',facealpha,'EdgeAlpha',edgealpha);
% Stützstellen:
plot3(ha,T.Points(:,1),T.Points(:,2),T.Points(:,3),...
	'LineWidth',0.5,'LineStyle','none','Color','k',...
	'Marker','.','MarkerSize',10);
% Rand markieren:
% if ~get_iT_margin_error_occurred
for i_margin=1:size(iT_margin,2)
	% Margin:
	plot3(ha,...
		T.Points(iT_margin{1,i_margin},1),...
		T.Points(iT_margin{1,i_margin},2),...
		T.Points(iT_margin{1,i_margin},3),...
		'LineWidth',1.5,'LineStyle','-','Color','r',...
		'Marker','.','MarkerSize',15);
	% Starting point:
	if ~isempty(E)&&~isempty(ie_startpoint)&&~isempty(ip_startpoint)
		if ie_startpoint(i_margin,1)>0
			plot3(ha,...
				[T.Points(E(ie_startpoint(i_margin,1),1),1) T.Points(E(ie_startpoint(i_margin,1),2),1)],...
				[T.Points(E(ie_startpoint(i_margin,1),1),2) T.Points(E(ie_startpoint(i_margin,1),2),2)],...
				[T.Points(E(ie_startpoint(i_margin,1),1),3) T.Points(E(ie_startpoint(i_margin,1),2),3)],...
				'LineWidth',2,'LineStyle','-','Color','b',...
				'Marker','none','MarkerSize',10);
			plot3(ha,...
				T.Points(ip_startpoint(i_margin,1),1),...
				T.Points(ip_startpoint(i_margin,1),2),...
				T.Points(ip_startpoint(i_margin,1),3),...
				'LineWidth',2,'LineStyle','-','Color','b',...
				'Marker','x','MarkerSize',10);
		end
	end
end
% Error "next point not found":
if ip_nextpoint_notfound>0
	plot3(ha,...
		T.Points(ip_nextpoint_notfound,1),...
		T.Points(ip_nextpoint_notfound,2),...
		T.Points(ip_nextpoint_notfound,3),...
		'LineWidth',2,'LineStyle','-','Color','m',...
		'Marker','+','MarkerSize',20);
	set_breakpoint		= 1;
end


% end

% Test:
% 	ie_v		= find(E_no_edgeAttachments>2);
% 	for ke=1:size(ie_v,1)
% 		ie			= ie_v(ke,1);
% 		plot3(ha,...
% 			[T.Points(E(ie,1),1) T.Points(E(ie,2),1)],...
% 			[T.Points(E(ie,1),2) T.Points(E(ie,2),2)],...
% 			[T.Points(E(ie,1),3) T.Points(E(ie,2),3)],...
% 			'LineWidth',4,'LineStyle','-','Color','g',...
% 			'Marker','x','MarkerSize',20);
% 	end

% Test
% 	x_edges	= [];
% 	y_edges	= [];
% 	z_edges	= [];
% 	for ie=1:size(E,1)
% 		if    E_no_edgeAttachments(ie,1)==1
% 			x_edges	= [x_edges nan T.Points(E(ie,1),1) T.Points(E(ie,2),1)];
% 			y_edges	= [y_edges nan T.Points(E(ie,1),2) T.Points(E(ie,2),2)];
% 			z_edges	= [z_edges nan T.Points(E(ie,1),3) T.Points(E(ie,2),3)];
% 		end
% 	end
% 	plot3(ha,x_edges,y_edges,z_edges,...
% 		'LineWidth',2,'LineStyle','-','Color','r',...
% 		'Marker','none','MarkerSize',10);

view(ha,3);
axis(ha,'equal');


function [T]=simplify_edge(T,iP1,iP2,P1_0,P2_0,P1,P2,V1,V2)

test=1;

% Flächenvektoren der angrenzenden Dreiecke:
for iv1=1:size(V1,1)
	cl			= T.ConnectivityList(V1(iv1,1),:);
	if length(unique(cl))==3
		
		
		
	end
	
end

function [fa,fn]=facedata_local(T,id)
id			= id(:);
fa			= zeros(size(id,1),1);
fn			= zeros(size(id,1),3);
for i=1:size(id,1)
	cl			= T.ConnectivityList(id(i,1),:);
	if length(unique(cl))==3
		p1			= T.Points(cl(1,1),:);
		p2			= T.Points(cl(1,2),:);
		p3			= T.Points(cl(1,3),:);
		p12		= p2-p1;
		p13		= p3-p1;
		p12xp13	= cross(p12,p13)/2;
		fa(i,1)	= sqrt(p12xp13(1,1)^2+p12xp13(1,2)^2+p12xp13(1,3)^2);
		if fa(i,1)>0
			fn(i,:)	= p12xp13/fa(i,1);
		end
	end
end

