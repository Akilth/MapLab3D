function [T,CL_hole,status,facearea]=stlrepair_close_single_hole(T,E,E_cline,fa_hole_max,testplot)
% Calculates triangles within the closed line E_cline to close a hole.
% CL_hole		connectivity list of the calculated triangles inside the hole
% status=0		closing hole was not successful
% status=1		closing hole was successful
% facearea		face area of the closed hole ([] if not successful)
% T				triangulation data
% E				edges: two-column matrix of vertex identification numbers
% E_cline		open edges that form a closed line: two-column matrix of vertex identification numbers
% fa_hole_max	Maximum face area of holes: holes that have a larger area will not be closed.

try

	% Testing:
	if nargin==0

		% Create a triangulation object with a open line:
		ax=10;
		ay=10;
		da=1;
		P=zeros(0,2);
		for x=0:da:ax
			P=[P;x 0];
		end
		for y=da:da:ay
			P=[P;ax y];
		end
		for x=(ax-da):-da:0
			P=[P;x ay];
		end
		for y=(ay-da):-da:da
			P=[P;0 y];
		end
		poly=polyshape(P,'KeepCollinearPoints',true);
		TR = triangulation(poly);
		T							= struct;
		T.Points					= TR.Points;
		T.ConnectivityList	= TR.ConnectivityList;
		T.Points	= [T.Points(:,1) T.Points(:,2) zeros(size(T.Points,1),1)];
		z=2;
		kumax=size(T.Points,1);
		ku		= 1;
		ko=size(T.Points,1)+1;
		T.Points(ko,:)=[T.Points(ku,1) T.Points(ku,2) z];
		for ku=2:kumax
			ko=size(T.Points,1)+1;
			kum1=ku-1;
			kom1=ko-1;
			T.Points(ko,:)=[T.Points(ku,1) T.Points(ku,2) z];
			T.ConnectivityList=[T.ConnectivityList;...
				kum1 ku kom1;...
				ku kom1 ko];
		end
		ku=1;
		ko=kumax+1;
		kum1=kumax;
		kom1=size(T.Points,1);
		T.ConnectivityList=[T.ConnectivityList;...
			kum1 ku kom1;...
			ku kom1 ko];
		% T.Points(9,1)		= 0.6;
		% T.Points(15,1)		= 1.4;
		% T.Points(16,2)		= 1.1;
		% T.Points(16,3)		= 1.8;
		TR							= triangulation(T.ConnectivityList,T.Points);

		% Testplot:
		testplot	= true;
		hf=54326721;
		hf=figure(hf);
		clf(hf,'reset');
		ha		= axes(hf);
		axis(ha,'equal');
		cameratoolbar(hf,'Show');
		hold(ha,'on');
		xlabel(ha,'x / mm');
		ylabel(ha,'y / mm');
		zlabel(ha,'z / mm');
		fontsize		= 12;
		F=[TR.ConnectivityList(:,1) ...
			TR.ConnectivityList(:,2) ...
			TR.ConnectivityList(:,3) ...
			TR.ConnectivityList(:,1)];
		tp_patch1=patch(ha,'faces',F,'vertices',TR.Points,...
			'EdgeColor',[0 0.6 0],'FaceColor',[0 0 1],'FaceAlpha',0.075,'EdgeAlpha',0.3);
		for i=1:size(TR.Points,1)
			text(ha,TR.Points(i,1),TR.Points(i,2),TR.Points(i,3),num2str(i),...
				'FontSize',fontsize,'FontWeight','bold','Color','k','HorizontalAlignment','center');
		end
		view(ha,3);
		axis(ha,'equal');

		% Call stlrepair_close_single_hole:
		E							= edges(TR);
		ID							= edgeAttachments(TR,E);
		ie_1tr_logical			= false(size(E,1),1);
		for i=1:size(ID,1)
			if isscalar(ID{i,1})
				ie_1tr_logical(i,1)	= true;
			end
		end
		ie_1tr	= find(ie_1tr_logical);
		i_ie_1tr	= 1;
		ie_start		= ie_1tr(i_ie_1tr,1);
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
		E_cline			= E(closed_lines(1,1).ie_cline,:);

		tic
		fa_hole_max				= 1e100;
		[T,CL_hole,status,facearea]	= stlrepair_close_single_hole(T,E,E_cline,fa_hole_max,testplot);
		t_stlrepair_close_single_hole	= toc

		return

	end

	if nargin<5
		testplot		= false;
	end
	
	method		= 2;
	switch method

		% --------------------------------------------------------------------------------------------------------------
		case 1
			
			% facearea and fa_hole_max not yet implemented !

			% The algorithm is too slow with a higher number of points in the open line.
			% ==> For the time being, limit to a maximum of 8 points in the open line !!!
			% ax=1, ay=1		0.000504 seconds		The open line has 4 points
			% ax=1, ay=2		0.005942 seconds		The open line has 6 points
			% ax=2, ay=2		0.248793 seconds		The open line has 8 points
			% ax=2, ay=3		9.531679 seconds		The open line has 10 points

			% Sort the vertices in E_cline in consecutive order and
			% get the vertex identification numbers of the closed line:
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
			% Initialisations:
			CL_test					= zeros(0,3);					% Connectivity list: starting value
			CL_new					= cell(0,1);					% Connectivity list: all solutions found
			F_test					= zeros(0,3);					% Face normals: starting value
			F_new						= cell(0,1);					% Face normals: corresponding to CL_new
			E_test					= zeros(0,3);					% Face normals: starting value
			height_CL				= size(ip_cline,1)-2;		% number of triangles required
			Esort_without_Ecline	= sort(E,2);					% triangulation edges: the elements of each row must
			E_cline_sort			= sort(E_cline,2);			% be sorted and must not contain the edges of E_cline.
			for i=1:size(E_cline_sort,1)
				Esort_without_Ecline(...
					(E_cline_sort(i,1)==Esort_without_Ecline(:,1))&...
					(E_cline_sort(i,2)==Esort_without_Ecline(:,2))    ,:)	= [];
			end
			debugdata							= [];
			debugdata.recursion_depth		= 0;
			debugdata.i1						= zeros(0,1);
			debugdata.i2						= zeros(0,1);
			debugdata.imax						= zeros(0,1);
			% Recursive search for Connectivity lists, that close the hole:
			[~,CL_new,~,F_new,~]	= stlrepair_close_hole_recursion(...
				T,...
				Esort_without_Ecline,...
				CL_test,...
				CL_new,...
				F_test,...
				F_new,...
				E_test,...
				ip_cline,...
				E_cline,...
				height_CL,...
				debugdata);

			% CL_new is a cell array and contains all possible combinations of triangles that fill the area
			% within ip_cline. F_new contains the corresponding face normal vectors.
			if ~isempty(CL_new)
				% The solution is selected based on:
				% - the maximum angle between all face normal vectors phi_F_max(i,1)
				% - the minimum area of all triangles mag_F_min(i,1)
				phi_F_max		= zeros(size(F_new,1),1);
				mag_F_min		= ones(size(F_new,1),1)*1e12;
				for i=1:size(CL_new,1)
					F_new_i	= F_new{i,1};
					mag_F_i	= sqrt(sum(F_new_i.^2,2));
					% Angle between all face normal vectors of the solution i:
					for i1=1:(size(F_new_i,1)-1)
						for i2=i1+1:size(F_new_i,1)
							phi_F	= acos(F_new_i(i1,:)*F_new_i(i2,:)'/...
								(sqrt(sum(F_new_i(i1,:).^2,2))*sqrt(sum(F_new_i(i2,:).^2,2))))*180/pi;
							if phi_F>phi_F_max(i,1)
								phi_F_max(i,1)		= phi_F;
							end
						end
					end
					% Minimum area of the triangles of solution i:
					mag_F_min(i,1)		= min(mag_F_i);
				end

				% Select the solution in which the angles between all surface vectors are the smallest.
				% This is the solution that forms the straightest possible surface (tolerance 5 degrees):
				min_phi_F_max		= min(phi_F_max);
				i_CL_new_locigal	= find(phi_F_max<(min_phi_F_max+5));

				% From the remaining solutions, select the one for which the minimum area of all triangles is
				% as large as possible:
				[~,i_i_CL_new_locigal]	= max(mag_F_min(i_CL_new_locigal,1));
				i_CL_new						= i_CL_new_locigal(i_i_CL_new_locigal);
				CL_hole						= CL_new{i_CL_new,1};

				% Extend the ConnectivityList:
				T.ConnectivityList	= [T.ConnectivityList;CL_hole];

				% Closing the hole was successful:
				status			= 1;
				setbreakpoint	= 1;

			else
				% Closing the hole was not successful:
				CL_hole			= zeros(0,3);
				status			= 0;
				setbreakpoint	= 1;
			end


			% -----------------------------------------------------------------------------------------------------------
		case 2


			% Initializations:
			status					= 1;

			% Step 1: Calculate the reference face normal vectors into which the face normal vectors of the triangles
			% to be created should point:

			% Sort the vertices in E_cline in consecutive order and
			% get the vertex identification numbers of the closed line:
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

			% Align the direction of rotation of the neighboring triangles with the closed line:
			TR							= triangulation(T.ConnectivityList,T.Points);
			ID_cline					= edgeAttachments(TR,E_cline);
			for ie=1:size(E_cline,1)
				if size(ID_cline{ie,1},2)==1
					iCL				= ID_cline{ie,1};
				else
					% The edge ie of the closed line has 0 or at least 2 triangles attached:
					% plotvertno		= false;
					% name_str			= 'Test';
					% title_str		= 'Test';
					% [h_title,ha,tp_patch1]		= stlrepair_show_testplot(T,plotvertno,1432654354,name_str,title_str);
					errormessage;
				end
				if (T.ConnectivityList(iCL,1)==E(ie,2))&&(T.ConnectivityList(iCL,2)==E(ie,1))
					T.ConnectivityList(iCL,1)		= E(ie,1);
					T.ConnectivityList(iCL,2)		= E(ie,2);
				else
					if (T.ConnectivityList(iCL,2)==E(ie,2))&&(T.ConnectivityList(iCL,3)==E(ie,1))
						T.ConnectivityList(iCL,2)		= E(ie,1);
						T.ConnectivityList(iCL,3)		= E(ie,2);
					else
						if (T.ConnectivityList(iCL,3)==E(ie,2))&&(T.ConnectivityList(iCL,1)==E(ie,1))
							T.ConnectivityList(iCL,3)		= E(ie,1);
							T.ConnectivityList(iCL,1)		= E(ie,2);
						end
					end
				end
			end

			% Set all points of the open line equal to the center point:
			p_center							= mean(T.Points(ip_cline,:),1);
			T_test							= T;
			for i=1:size(ip_cline,1)
				ip								= ip_cline(i,1);
				T_test.Points(ip,:)		= p_center;
			end

			% Add the face normal vectors of all triangles that touch the center point ==>
			% F_ref1, F_ref2: Preferred directions of the face normal vectors of the triangles used to fill the hole.
			TR_test							= triangulation(T_test.ConnectivityList,T_test.Points);
			V_test							= vertexAttachments(TR_test,ip_cline);
			V_test_v							= zeros(0,1);
			for i=1:size(V_test,1)
				V_test_v						= [V_test_v;V_test{i,1}(:)];
			end
			V_test_v							= unique(V_test_v);
			F_test							= faceNormal(TR_test,V_test_v);
			F_ref1							= sum(F_test,1);
			F_ref2							= -F_ref1;

			% Testplot:
			if testplot
				hf=54326722;
				hf=figure(hf);
				clf(hf,'reset');
				ha		= axes(hf);
				axis(ha,'equal');
				cameratoolbar(hf,'Show');
				hold(ha,'on');
				xlabel(ha,'x / mm');
				ylabel(ha,'y / mm');
				zlabel(ha,'z / mm');
				fontsize		= 12;
				F=[TR_test.ConnectivityList(:,1) ...
					TR_test.ConnectivityList(:,2) ...
					TR_test.ConnectivityList(:,3) ...
					TR_test.ConnectivityList(:,1)];
				tp_patch1=patch(ha,'faces',F,'vertices',TR_test.Points,...
					'EdgeColor',[0 0.6 0],'FaceColor',[0 0 1],'FaceAlpha',0.075,'EdgeAlpha',0.3);
				view(ha,3);
				axis(ha,'equal');
			end

			% Step 2: Fill the area within the closed line with triangles.
			% Always create triangles between three consecutive points of the closed line. Conditions:
			% - The area of the triangle must not be zero or the three points must not be collinear.
			% - The face vector of the triangle should point in the direction of the reference face vector F_ref.
			%   This is to prevent triangles lying “outside” the closed line if the closed line has a concave shape.
			% - The triangles that close the triangle with the shortest connection should be formed first
			%   This should also reduce the probability of overlaps with a concave shape of the closed line.

			% Solutions are first calculated for both reference face vectors:
			CL1_hole				= zeros(0,3);		% Connectivity list of the triangles that fill the hole
			CL2_hole				= zeros(0,3);
			phi_FFref1_max		= 0;					% Maximum angle between the face vectors of the triangles that
			phi_FFref2_max		= 0;					% fill the hole and the reference face vector
			for iref=1:2
				if iref==1
					F_ref			= F_ref1;
				else
					F_ref			= F_ref2;
				end
				ip_cline_rest		= ip_cline;

				while size(ip_cline_rest,1)>=3
					% Repeat until the hole has been filled:
					p_cline		= [...
						T.Points(ip_cline_rest(:,1),1) ...
						T.Points(ip_cline_rest(:,1),2) ...
						T.Points(ip_cline_rest(:,1),3)];
					kmax			= size(p_cline,1);
					F				= zeros(kmax,3);
					mag_F			= zeros(kmax,1);
					mag_p13		= zeros(kmax,1);
					phi_FFref	= zeros(kmax,1);
					for k=1:kmax
						kp1					= vindexrest(k+1,kmax);
						kp2					= vindexrest(k+2,kmax);
						p12					= p_cline(kp1,:)-p_cline(k,:);
						p13					= p_cline(kp2,:)-p_cline(k,:);
						F(k,:)				= cross(p12,p13)/2;
						mag_F(k,1)			= sqrt(sum(F(k,:).^2,2));
						mag_p13(k,1)		= sqrt(sum(p13.^2,2));
						phi_FFref(k,1)		= acos(F(k,:)*F_ref'/(sqrt(sum(F(k,:).^2,2))*sqrt(sum(F_ref.^2,2))))*180/pi;
					end
					phi_FFref_max				= min(phi_FFref)+45;
					phi_FFref_max				= min(phi_FFref_max,90);
					kvalid						= (mag_F>0)&(phi_FFref<phi_FFref_max);
					if ~any(kvalid)
						[~,kvalid]				= min(phi_FFref);
					end
					if ~any(kvalid)
						status					= 0;
						break
					end
					mag_p13_test				= nan(size(mag_p13));
					mag_p13_test(kvalid)		= mag_p13(kvalid);
					[~,ksel]						= min(mag_p13_test);
					kp1sel						= vindexrest(ksel+1,kmax);
					kp2sel						= vindexrest(ksel+2,kmax);
					CL_new						= [...
						ip_cline_rest(ksel,1) ...
						ip_cline_rest(kp1sel,1) ...
						ip_cline_rest(kp2sel,1)];
					if iref==1
						CL1_hole						= [CL1_hole;CL_new];
						phi_FFref1_max				= max(phi_FFref1_max,phi_FFref(ksel));
						ip_cline_rest(kp1sel,:)	= [];			% Delete middle point
					else
						CL2_hole						= [CL2_hole;CL_new];
						phi_FFref2_max				= max(phi_FFref2_max,phi_FFref(ksel));
						ip_cline_rest(kp1sel,:)	= [];			% Delete middle point
					end
				end
				if status==0
					break
				end
				% Testplot:
				if testplot
					hf=54326722+iref;
					hf=figure(hf);
					clf(hf,'reset');
					ha		= axes(hf);
					axis(ha,'equal');
					cameratoolbar(hf,'Show');
					hold(ha,'on');
					xlabel(ha,'x / mm');
					ylabel(ha,'y / mm');
					zlabel(ha,'z / mm');
					fontsize		= 12;
					if iref==1
						CL_new		= [TR.ConnectivityList;CL1_hole];
						tp_title1	= title(ha,sprintf('iref=%g',iref));
					else
						CL_new		= [TR.ConnectivityList;CL2_hole];
						tp_title2	= title(ha,sprintf('iref=%g',iref));
					end
					F=[CL_new(:,1) ...
						CL_new(:,2) ...
						CL_new(:,3) ...
						CL_new(:,1)];
					tp_patch1=patch(ha,'faces',F,'vertices',TR.Points,...
						'EdgeColor',[0 0.6 0],'FaceColor',[0 0 1],'FaceAlpha',0.075,'EdgeAlpha',0.3);
					view(ha,3);
					axis(ha,'equal');
				end
				setbreakpoint	= 1;
			end

			if status==0
				% Closing the hole was not successful:
				CL_hole			= zeros(0,3);
				facearea			= [];
			else
				% Use the solution with the minimum deviation from the reference face vector:
				if phi_FFref1_max<phi_FFref2_max
					CL_hole			= CL1_hole;
					if testplot
						tp_title1.String	= sprintf('iref=%g: selected',1);
					end
				else
					CL_hole			= CL2_hole;
					if testplot
						tp_title2.String	= sprintf('iref=%g: selected',2);
					end
				end
				% Extend the ConnectivityList if:
				% - The total face area is less than fa_hole_max,
				% - Safety query: The number of triangles must be ip_cline-2.
				facearea				= triangulation_facearea(T.Points,CL_hole);
				if    (facearea<=fa_hole_max)&&...
						isequal(size(CL_hole,1),(size(ip_cline,1)-2))
					% Extend the ConnectivityList:
					T.ConnectivityList	= [T.ConnectivityList;CL_hole];
				else
					% Closing the hole was not successful:
					CL_hole			= zeros(0,3);
					status			= 0;
				end
			end

			setbreakpoint	= 1;

	end

catch ME
	errormessage('',ME);
end

