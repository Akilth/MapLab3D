function closed_lines=stlrepair_search_for_closed_lines_recursion(...
	E,...
	ie_1tr_logical,...
	ie_3tr_logical,...
	nmin_e_1tr,...
	nmin_e_3tr,...
	ie_cline_0,...
	ip_cline_0,...
	closed_lines)
% Search for edges that form a closed line, starting from a list of edges ie_cline_0 and points ip_cline_0.
% E						edges: two-column matrix of vertex identification numbers
% ie_1tr_logical		indices of open edges in E to which exactly 1 triangle is connected
%							if these edges are not searched for: ie_1tr_logical=[]
% ie_3tr_logical		indices of open edges in E to which at least 3 triangles are connected
%							if these edges are not searched for: ie_3tr_logical=[]
% nmin_e_1tr			minimum number of edges in the closed line that are connected to exactly 1 triangle
% nmin_e_3tr			minimum number of edges in the closed line that are connected to at least three triangles.
% ie_cline_0			indices of the open edges in E that form a contiguous line
% ip_cline_0			vertex identification numbers between the edges ie_cline_0
% closed_lines(i_hole,1).ie_cline	indices of the open edges in E that form a closed line
% closed_lines(i_hole,1).ip_cline		vertex identification numbers between the edges closed_lines(i_hole,1).ie_cline

try

	ip_k						= ip_cline_0(end,1);
	ie_k						= ie_cline_0(end,1);

	% ip_kp1: Endpoint of the edge ie_k
	ip_kp1		= E(ie_k,:);
	ip_kp1		= ip_kp1(ip_kp1~=ip_k);
	if ~isscalar(ip_kp1)
		% This should not happen:
		errormessage;
	end
	i_ip_cline_0	= find(ip_kp1==ip_cline_0);
	if length(i_ip_cline_0)>1
		% This should not happen:
		errormessage;
	end
	if isscalar(i_ip_cline_0)
		% The hole is closed:
		%                              X ip_kp1=ip_cline_0(i_ip_cline_0,1)
		%                             / \
		%                            /   \ ie_start
		%                           /     \
		%                          /       X
		%                    ie_k /         \
		%                        /           .
		%                       /             .
		%                      /               .
		%                     /                 \
		%               ip_k X-------------------X ip_km1
		%                            ie_km1
		% The hole is closed:
		ie_cline						= ie_cline_0(i_ip_cline_0:end);
		ip_cline						= ip_cline_0(i_ip_cline_0:end);
		% Check if the solution found is new:
		hole_is_new					= true;
		ie_cline_unique				= unique(ie_cline);
		for i=1:size(closed_lines,1)
			if isequal(unique(closed_lines(i,1).ie_cline),ie_cline_unique)
				hole_is_new			= false;
			end
		end
		% Check if the solution found contains at least nmin_e_1tr open edges:
		n_e_1tr		= 0;
		if ~isempty(ie_1tr_logical)
			n_e_1tr		= sum(ie_1tr_logical(ie_cline));
		end
		% Check if the solution found contains at least nmin_e_3tr edges that are connected to at least three triangles:
		n_e_3tr		= 0;
		if ~isempty(ie_3tr_logical)
			n_e_3tr		= sum(ie_3tr_logical(ie_cline));
		end
		% If the solution found is valid: add the detected hole to the structure closed_lines:
		if hole_is_new&&(n_e_1tr>=nmin_e_1tr)&&(n_e_3tr>=nmin_e_3tr)
			i							= size(closed_lines,1)+1;
			closed_lines(i,1).ie_cline		= ie_cline;
			closed_lines(i,1).ip_cline		= ip_cline;
		end
	else
		%             ip_kp1 X                   X ip_cline(1,1)
		%                    |                   |
		%                    |                   | ie_cline(1,1)
		%                    |                   |
		%                    |                   X
		%               ie_k |                   |
		%                    |                   .
		%                    |                   .
		%                    |                   .
		%                    |                   |
		%               ip_k X-------------------X ip_km1
		%                            ie_km1
		% Search for the next open edge:
		if ~isempty(ie_1tr_logical)
			ie_kp1_1tr				= find(...
				((E(:,1)==ip_kp1)&ie_1tr_logical)|...
				((E(:,2)==ip_kp1)&ie_1tr_logical)    );
		else
			ie_kp1_1tr			= [];
		end
		if ~isempty(ie_3tr_logical)
			ie_kp1_3tr			= find(...
				((E(:,1)==ip_kp1)&ie_3tr_logical)|...
				((E(:,2)==ip_kp1)&ie_3tr_logical)    );
		else
			ie_kp1_3tr			= [];
		end
		ie_kp1					= unique([ie_kp1_1tr;ie_kp1_3tr]);
		ie_kp1(ie_kp1==ie_k)	= [];
		if isempty(ie_kp1)
			% There is no further open edge: this is a dead end: Cancel
		else
			% Continue searching for a hole:
			for i=1:size(ie_kp1,1)
				closed_lines=stlrepair_search_for_closed_lines_recursion(...
					E,...
					ie_1tr_logical,...
					ie_3tr_logical,...
					nmin_e_1tr,...
					nmin_e_3tr,...
					[ie_cline_0;ie_kp1(i,1)],...
					[ip_cline_0;ip_kp1     ],...
					closed_lines);
			end
		end
	end

catch ME
	errormessage('',ME);
end

