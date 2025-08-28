function T=triangulation_delete_empty_triangles(T)
% Triangulation data: Delete triangles that contain identical vertices.

try

	r_delete_logical			= false(size(T.ConnectivityList,1),1);
	for r=1:size(T.ConnectivityList,1)
		if    (T.ConnectivityList(r,1)==T.ConnectivityList(r,2))||...
				(T.ConnectivityList(r,1)==T.ConnectivityList(r,3))||...
				(T.ConnectivityList(r,2)==T.ConnectivityList(r,3))
			r_delete_logical(r)		= true;
		end
	end
	T.ConnectivityList(r_delete_logical,:)	= [];

catch ME
	errormessage('',ME);
end

