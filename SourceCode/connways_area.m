function [area_mm2,area_v_mm2]=connways_area(connways)
% Calculate the area:

global GV

try

	area_v_mm2	= zeros(size(connways.areas));
	if ~isempty(connways.areas)
		poly			= polyshape();
		if GV.warnings_off
			warning('off','MATLAB:polyshape:repairedBySimplify');
			warning('off','MATLAB:polyshape:boolOperationFailed');
		end
		for k=1:size(connways.areas,1)
			area_v_mm2(k,1)	= area(polyshape(connways.areas(k,1).xy(:,1),connways.areas(k,1).xy(:,2)));
			poly					= addboundary(poly,connways.areas(k,1).xy(:,1:2));
		end
		if GV.warnings_off
			warning('on','MATLAB:polyshape:repairedBySimplify');
			warning('on','MATLAB:polyshape:boolOperationFailed');
		end
		area_mm2	= area(poly);
	else
		area_mm2	= 0;
	end

catch ME
	errormessage('',ME);
end

