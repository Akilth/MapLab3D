function [...
	ID_num,...
	CL_ie,...
	CL_cID]=...
	stlrepair_get_triangleedges(T,ID)
% Preparation to reduce computing time: Data corresponding to T.ConnectivityList(iCL,:):
% ID_num(ie,:)				Indices iCL of the triangles connected to the edges E.
% CL_ie(iCL,1:3)			Indices ie of the three edges of a triangle
%								= line numbers of the triangle iCL in ID_num
% cID=CL_cID(iCL,1:3)	Column numbers of the triangle iCL in ID_num

try

	ID_num					= zeros(size(ID,1),2);
	for i=1:size(ID,1)
		ID_num(i,1:size(ID{i,1},2))	= ID{i,1};
	end
	ie_v						= (1:size(ID_num,1))';
	cID_v						= ones(size(ID_num,1),1);
	% ie_cID_ID_v				Column 1: Row number in ID_num or E: Index ie of the edge
	%								Column 2: Column number in ID_num or E
	%								Column 3: Row number in T.ConnectivityList: Index iCL of the triangle connected to the edge
	ie_cID_ID_v				= [ie_v cID_v ID_num(:,1)];
	for i=2:size(ID_num,2)
		cID_v					= ones(size(ID_num,1),1)*i;
		ie_cID_ID_v			= [ie_cID_ID_v;ie_v cID_v ID_num(:,i)];
	end
	cCL_v						= zeros(size(T.ConnectivityList,1),1);
	CL_ie						= zeros(size(T.ConnectivityList));
	CL_cID					= zeros(size(T.ConnectivityList));
	for k=1:size(ie_cID_ID_v,1)
		ie						= ie_cID_ID_v(k,1);
		cID					= ie_cID_ID_v(k,2);
		iCL					= ie_cID_ID_v(k,3);
		% iCL=0 means that edge ie has less connected trangles than size(ID_num,2)
		if iCL>0
			cCL_v(iCL,1)		= cCL_v(iCL,1)+1;
			cCL					= cCL_v(iCL,1);
			CL_ie(iCL,cCL)		= ie;
			CL_cID(iCL,cCL)	= cID;
		end
	end

catch ME
	errormessage('',ME);
end

