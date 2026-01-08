function connways=connect_ways_apply_tol(connways,tol,conn_with_rev)
% Tries to connect the open lines with reversal and increased tolerance.

try
		
	if ~isempty(connways.lines)
		connways_old				= connways;
		connways.lines				= [];
		connways.xy_start			= [];
		connways.xy_end			= [];
		connways.lines_isouter	= [];
		connways.lines_isinner	= [];
		connways.lines_relid		= [];
		for k_line=1:size(connways_old.lines,1)
			x_k_line			= connways_old.lines(k_line,1).xy(:,1);
			y_k_line			= connways_old.lines(k_line,1).xy(:,2);
			iobj_k_line		= connways_old.lines(k_line,1).xy(:,3);
			lino_k_line		= connways_old.lines(k_line,1).xy(:,4);
			liwi_k_line		= connways_old.lines(k_line,1).xy(:,5);
			iw_v_k_line		= connways_old.lines(k_line,1).iw_v;
			ir_k_line		= connways_old.lines(k_line,1).ir;
			if     connways_old.lines_isouter(k_line,1)==1
				role_k_line	= 'outer';
			elseif connways_old.lines_isinner(k_line,1)==1
				role_k_line	= 'inner';
			else
				% Must not be empty, otherwise it will be initialized with 'outer' when connect_ways is called!
				role_k_line	= '???';
			end
			relid_k_line	= connways_old.lines_relid(k_line,1);
			tag_k_line		= connways_old.lines(k_line,1).tag;
			connect_k_line	= connways_old.lines(k_line,1).connect;
			connways			= connect_ways(...
				connways,...				% connways
				[],...						% connways_merge
				x_k_line,...				% x
				y_k_line,...				% y
				iobj_k_line,...			% iobj
				lino_k_line,...			% lino
				liwi_k_line,...			% liwi
				0,...							% in
				iw_v_k_line,...			% iw_v
				ir_k_line,...				% ir
				1,...							% l2a
				1,...							% s
				[],...						% lino_new_min
				role_k_line,...			% role
				relid_k_line,...			% relid
				tag_k_line,...				% tag
				tol,...						% tol
				conn_with_rev,...			% conn_with_rev
				connect_k_line);			% connect
		end
	end
	
catch ME
	errormessage('',ME);
end

