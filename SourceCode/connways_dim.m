function [xmin_all_mm,xmax_all_mm,ymin_all_mm,ymax_all_mm,...
	xmin_node_mm,xmax_node_mm,ymin_node_mm,ymax_node_mm,...
	xmin_line_mm,xmax_line_mm,ymin_line_mm,ymax_line_mm,...
	xmin_area_mm,xmax_area_mm,ymin_area_mm,ymax_area_mm]=connways_dim(connways)

try
	
	% Calculate the dimensions in x- and y-direction
	xmin_all_mm		= zeros(0,1);
	xmax_all_mm		= zeros(0,1);
	ymin_all_mm		= zeros(0,1);
	ymax_all_mm		= zeros(0,1);
	xmin_node_mm	= zeros(size(connways.nodes));
	xmax_node_mm	= zeros(size(connways.nodes));
	ymin_node_mm	= zeros(size(connways.nodes));
	ymax_node_mm	= zeros(size(connways.nodes));
	xmin_line_mm	= zeros(size(connways.lines));
	xmax_line_mm	= zeros(size(connways.lines));
	ymin_line_mm	= zeros(size(connways.lines));
	ymax_line_mm	= zeros(size(connways.lines));
	xmin_area_mm	= zeros(size(connways.areas));
	xmax_area_mm	= zeros(size(connways.areas));
	ymin_area_mm	= zeros(size(connways.areas));
	ymax_area_mm	= zeros(size(connways.areas));
	if ~isempty(connways)
		if ~isempty(connways.nodes) || ~isempty(connways.lines) || ~isempty(connways.areas)
			xmin_all_mm		=  1e10;
			xmax_all_mm		= -1e10;
			ymin_all_mm		=  1e10;
			ymax_all_mm		= -1e10;
			if ~isempty(connways.nodes)
				xmin_node_mm			= min(connways.nodes.xy(:,1));
				xmax_node_mm			= max(connways.nodes.xy(:,1));
				ymin_node_mm			= min(connways.nodes.xy(:,2));
				ymax_node_mm			= max(connways.nodes.xy(:,2));
				xmin_all_mm		= min(xmin_all_mm,xmin_node_mm);
				xmax_all_mm		= max(xmax_all_mm,xmax_node_mm);
				ymin_all_mm		= min(ymin_all_mm,ymin_node_mm);
				ymax_all_mm		= max(ymax_all_mm,ymax_node_mm);
			end
			for k=1:size(connways.lines,1)
				xmin_line_mm(k,1)			= min(connways.lines(k,1).xy(:,1));
				xmax_line_mm(k,1)			= max(connways.lines(k,1).xy(:,1));
				ymin_line_mm(k,1)			= min(connways.lines(k,1).xy(:,2));
				ymax_line_mm(k,1)			= max(connways.lines(k,1).xy(:,2));
				xmin_all_mm		= min(xmin_all_mm,xmin_line_mm(k,1));
				xmax_all_mm		= max(xmax_all_mm,xmax_line_mm(k,1));
				ymin_all_mm		= min(ymin_all_mm,ymin_line_mm(k,1));
				ymax_all_mm		= max(ymax_all_mm,ymax_line_mm(k,1));
			end
			for k=1:size(connways.areas,1)
				xmin_area_mm(k,1)			= min(connways.areas(k,1).xy(:,1));
				xmax_area_mm(k,1)			= max(connways.areas(k,1).xy(:,1));
				ymin_area_mm(k,1)			= min(connways.areas(k,1).xy(:,2));
				ymax_area_mm(k,1)			= max(connways.areas(k,1).xy(:,2));
				xmin_all_mm				= min(xmin_all_mm,xmin_area_mm(k,1));
				xmax_all_mm				= max(xmax_all_mm,xmax_area_mm(k,1));
				ymin_all_mm				= min(ymin_all_mm,ymin_area_mm(k,1));
				ymax_all_mm				= max(ymax_all_mm,ymax_area_mm(k,1));
			end
		end
	end
	
catch ME
	errormessage('',ME);
end

