function T=triangulation_delete_identical_triangles(T)
% Triangulation data: delete idential triangles, with different sorting of the vertices.

try

	method	= 2;
	switch method
		case 1
			r_delete_logical			= false(size(T.ConnectivityList,1),1);
			r_notdelete_logical		= false(size(T.ConnectivityList,1),1);
			for r=1:size(T.ConnectivityList,1)
				r_notdelete_logical(r)	= true;
				r_delete_r_logical		= ...
					((T.ConnectivityList(:,2)==T.ConnectivityList(r,1))|(T.ConnectivityList(:,3)==T.ConnectivityList(r,1)))&...
					((T.ConnectivityList(:,1)==T.ConnectivityList(r,2))|(T.ConnectivityList(:,3)==T.ConnectivityList(r,2)))&...
					((T.ConnectivityList(:,1)==T.ConnectivityList(r,3))|(T.ConnectivityList(:,2)==T.ConnectivityList(r,3)));
				r_delete_r_logical(r)	= false;													% Do not delete the current row
				r_delete_r_logical		= r_delete_r_logical&~r_notdelete_logical;	% Do not delete previous rows
				r_delete_r_v				= find(r_delete_r_logical);
				for i=1:size(r_delete_r_v)
					r_delete_r				= r_delete_r_v(i);
					r_delete_logical(r_delete_r)		= true;
				end
			end
		case 2
			% 100 times faster:
			T_CL_sort	= sort(T.ConnectivityList,2);		% [T_CL_uniq,ia,ic]	= unique(T_CL_sort,'rows');
			[~,ia,~]		= unique(T_CL_sort,'rows');		% T_CL_uniq = T_CL_sort(ia) and T_CL_sort(:) = T_CL_uniq(ic)
			r_notdelete_logical			= false(size(T.ConnectivityList,1),1);
			r_notdelete_logical(ia,1)	= true;
			r_delete_logical				= ~r_notdelete_logical;
	end
	T.ConnectivityList(r_delete_logical,:)	= [];

catch ME
	errormessage('',ME);
end

