function [T,ic]=triangulation_delete_not_referenced_points(T,method)
% Delete points that are not referenced by the triangulation:

global GV

try

	if nargin<2
		method	= 3;
	end
	switch method
		case 1
			r		= 0;
			while r<size(T.Points,1)
				r		= r+1;
				if ~any(T.ConnectivityList==r,'all')
					iCL								= T.ConnectivityList>r;
					T.ConnectivityList(iCL)		= T.ConnectivityList(iCL)-1;
					T.Points(r,:)					= [];
					r		= r-1;
				end
			end
			ic		= [];		% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		case 2
			% 150 times faster than method 1:
			% Tolerance for the use of uniquetol: Conversion of the absolute tolerance:
			% C = uniquetol(A,tol): Two values, u and v, are within tolerance if abs(u-v) <= tol*max(abs(A(:)))
			% GV.tol_tp=tol*max(abs(A(:)))  ==>  tol=GV.tol_tp/max(abs(A(:)))
			if isempty(GV)
				GV.tol_tp							= 1e-4;
			end
			tol_uniquetol				= GV.tol_tp/max(abs(T.Points),[],'all');
			% Before using this method, it must be ensured that the minimum distance between the points is tol_uniquetol!
			% Set the not used points equal to the first used point (preparation of uniquetol):
			r_Points_used_v						= unique([
				T.ConnectivityList(:,1);...
				T.ConnectivityList(:,2);...
				T.ConnectivityList(:,3)]);
			Points_used_v							= false(size(T.Points,1),1);
			Points_used_v(r_Points_used_v,:)	= true;
			r_firstPoint_used						= find(Points_used_v,1);
			T.Points(~Points_used_v,1)	= T.Points(r_firstPoint_used,1);
			T.Points(~Points_used_v,2)	= T.Points(r_firstPoint_used,2);
			T.Points(~Points_used_v,3)	= T.Points(r_firstPoint_used,3);
			% [T.Points_new,ia,ic]=uniquetol(T.Points_old,tol,'ByRows',true);
			% T.Points_new = T.Points_old(ia,:)
			% T.Points_old = T.Points_new(ic,:)
			[T.Points,~,ic]			= uniquetol(T.Points,tol_uniquetol/100,'ByRows',true);
			% The element k of ic is the old number of the point in the ConnectivityList.
			% ==> ic(k) is the new number of the point
			% The ConnectivityList contains the indices k of the old points ==> replace with ic(k)
			T.ConnectivityList(:,1)	= ic(T.ConnectivityList(:,1));
			T.ConnectivityList(:,2)	= ic(T.ConnectivityList(:,2));
			T.ConnectivityList(:,3)	= ic(T.ConnectivityList(:,3));

		case 3
			% 130 times faster than method 1:

			% Create a valid triangulation object:
			if GV.warnings_off
				warning('off','MATLAB:triangulation:PtsNotInTriWarnId');		% triangulation
			end
			TR		= triangulation(T.ConnectivityList,T.Points);
			if GV.warnings_off
				warning('on','MATLAB:triangulation:PtsNotInTriWarnId');		% triangulation
			end
			% Triangulation vertex normal:
			V		= vertexNormal(TR);
			% Undocumented characteristic of the “vertexNormal” function:
			% If a vertex has no connection to an edge, the length of the vertex normal vector =0.
			% These nodes are deleted:
			ip_delete_v_0		= sort(find(sum(abs(V),2)<0.1));
			ip_delete_v			= ip_delete_v_0;
			ip_is_not_in_CL	= true(size(ip_delete_v,1),1);
			for i=1:size(ip_delete_v,1)
				ip_delete		= ip_delete_v(i,1);
				% Query to ensure that this vertex really does not appear in T.ConnectivityList:
				if ~any(T.ConnectivityList==ip_delete,'all')
					% Delete this vertex:
					iCL								= T.ConnectivityList>ip_delete;
					T.ConnectivityList(iCL)		= T.ConnectivityList(iCL)-1;
					ip_delete_v						= ip_delete_v-1;
				else
					% Do not delete this vertex:
					ip_is_not_in_CL(i,1)			= false;
				end
			end
			ip_delete_v_0							= ip_delete_v_0(ip_is_not_in_CL);
			T.Points(ip_delete_v_0,:)			= [];
			ic		= [];		% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	end

catch ME
	errormessage('',ME);
end

