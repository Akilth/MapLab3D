function [length_mm,length_lines_v_mm,length_areas_v_mm]=connways_length(connways)
% Cumulate the length of all ways and areas:

try

	length_mm			= 0;
	length_lines_v_mm	= zeros(size(connways.lines));
	length_areas_v_mm	= zeros(size(connways.areas));
	if ~isempty(connways)
		for k=1:size(connways.lines,1)
			length_lines_v_mm(k,1)	= 0;
			x			= connways.lines(k,1).xy(:,1);
			y			= connways.lines(k,1).xy(:,2);
			[xc,yc]	= polysplit(x,y);
			for ic=1:size(xc,1)
				imax	= size(xc{ic,1},1);
				i		= 1:(imax-1);
				ip1	= 2:imax;
				length_lines_v_mm(k,1)	= length_lines_v_mm(k,1) + sum(sqrt(...
					(xc{ic,1}(ip1,1)-xc{ic,1}(i,1)).^2+...
					(yc{ic,1}(ip1,1)-yc{ic,1}(i,1)).^2    ));
			end
			length_mm	= length_mm + length_lines_v_mm(k,1);
		end
		for k=1:size(connways.areas,1)
			length_areas_v_mm(k,1)	= 0;
			x			= connways.areas(k,1).xy(:,1);
			y			= connways.areas(k,1).xy(:,2);
			[xc,yc]	= polysplit(x,y);
			for ic=1:size(xc,1)
				imax	= size(xc{ic,1},1);
				i		= 1:(imax-1);
				ip1	= 2:imax;
				length_areas_v_mm(k,1)	= length_areas_v_mm(k,1) + sum(sqrt(...
					(xc{ic,1}(ip1,1)-xc{ic,1}(i,1)).^2+...
					(yc{ic,1}(ip1,1)-yc{ic,1}(i,1)).^2    ));
			end
			length_mm	= length_mm + length_areas_v_mm(k,1);
		end
	end

catch ME
	errormessage('',ME);
end

