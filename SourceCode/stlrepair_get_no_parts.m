function no_parts=stlrepair_get_no_parts(T)
% The function returns the number of individual parts that have common vertices.

try

	TR							= triangulation(T.ConnectivityList,T.Points);
	ID							= vertexAttachments(TR);
	iCL_v_done				= false(size(T.ConnectivityList,1),1);
	iCL_conn					= false(size(T.ConnectivityList,1),1);
	iCL						= 1;
	no_parts					= 1;
	while ~isempty(iCL)
		% Mark all triangles connected to the vertices of iCL in iCL_conn:
		iCL_conn(ID{T.ConnectivityList(iCL,1)})	= true;
		iCL_conn(ID{T.ConnectivityList(iCL,2)})	= true;
		iCL_conn(ID{T.ConnectivityList(iCL,3)})	= true;
		% Cancel the marking of the triangles already edited in iCL_conn:
		iCL_conn(iCL_v_done)				= false;
		% Mark the triangle iCL as edited:
		iCL_v_done(iCL)					= true;
		% Mark the iCL triangle as no longer to be edited:
		iCL_conn(iCL)						= false;
		% Next triangle to be edited:
		iCL_next								= find(iCL_conn,1);
		if ~isempty(iCL_next)
			iCL						= iCL_next;
		else
			iCL						= find(~iCL_v_done,1);
			if ~isempty(iCL)
				no_parts				= no_parts+1;
			end
		end
	end

catch ME
	errormessage('',ME);
end

