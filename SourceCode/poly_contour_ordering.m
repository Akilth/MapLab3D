function poly=poly_contour_ordering(poly)
% Polygon contour ordering.
% Outer and inner vertex ordering:
%                       <---
%      +------------------------------------+
%      |                                    |
%      |              --->                  |
%      |       +---------------+            |
%      |       |               |            |
%      |       |               |            |
%      |       |               |            |
%      |       +---------------+            |
%      |              <---                  |
%      |                                    |
%      |                                    |
%      +------------------------------------+
%                       --->

% This function is switched off because it leads to more errors in the STL-files.

return

try

	for r=1:size(poly,1)
		for c=1:size(poly,2)
			poly_new		= polyshape();
			for ib=1:numboundaries(poly(r,c))
				[x0,y0]		= boundary(poly(r,c),ib);
				if ishole(poly(r,c),ib)
					% Convert polygon contour to clockwise vertex ordering:
					[x,y]			= poly2cw(x0,y0);
				else
					% Convert polygon contour to counterclockwise vertex ordering:
					[x,y]			= poly2ccw(x0,y0);
				end
				poly_new		= addboundary(poly_new,x,y);
			end
			poly(r,c)	= poly_new;
		end
	end

catch ME
	errormessage('',ME);
end

