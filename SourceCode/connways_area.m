function [area_mm2,area_v_mm2]=connways_area(connways,msg)
% Calculate the area:

global GV GV_H WAITBAR

try
	
	if nargin>=2
		show_msg		= true;
	else
		show_msg		= false;
	end
	area_v_mm2	= zeros(size(connways.areas));
	if ~isempty(connways.areas)
		poly			= polyshape();
		if GV.warnings_off
			warning('off','MATLAB:polyshape:repairedBySimplify');
			warning('off','MATLAB:polyshape:boolOperationFailed');
		end
		for k=1:size(connways.areas,1)
			if show_msg
				% Waitbar:
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					WAITBAR.t1	= clock;
					set(GV_H.text_waitbar,'String',sprintf('%s areas: %g/%g',msg,k,size(connways.areas,1)));
					drawnow;
				end
			end
			if size(connways.areas(k,1).xy,1)>=4
				% Creating a polyshape is only possible with areas that consist of at least 4 points with
				% identical start and end points. With fewer points, the area is zero.
				area_v_mm2(k,1)	= area(polyshape(connways.areas(k,1).xy(:,1),connways.areas(k,1).xy(:,2)));
				poly					= addboundary(poly,connways.areas(k,1).xy(:,1:2));
			else
				area_v_mm2(k,1)	= 0;
			end
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

