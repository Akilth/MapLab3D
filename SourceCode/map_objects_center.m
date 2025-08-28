function [x,y]=map_objects_center(imapobj)
% Calculate the center point x, y of one index in MAP_OBJECTS:
% [x,y]=map_objects_center(imapobj);

global MAP_OBJECTS

try

	tol	= 1e-6;

	% Center point:
	if size(MAP_OBJECTS(imapobj,1).h,2)~=1
		size(MAP_OBJECTS(imapobj,1).h)
		errormessage;
	end
	x_line_v		= nan(size(MAP_OBJECTS(imapobj,1).h));
	y_line_v		= nan(size(MAP_OBJECTS(imapobj,1).h));
	poly			= polyshape();
	for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
		switch MAP_OBJECTS(imapobj,1).h(i,1).Type
			case 'polygon'
				poly				= union(poly,MAP_OBJECTS(imapobj,1).h(i,1).Shape);
			case 'line'
				x_line			= MAP_OBJECTS(imapobj,1).h(i,1).XData(:);
				y_line			= MAP_OBJECTS(imapobj,1).h(i,1).YData(:);
				x_line			= x_line(~isnan(x_line));
				y_line			= y_line(~isnan(y_line));
				if (abs(x_line(1)-x_line(end))<tol)&&(abs(y_line(1)-y_line(end))<tol)&&(length(x_line)>1)
					% The first and last vertices are identical:
					x_line_v(i)			= mean(x_line(2:end));
					y_line_v(i)			= mean(y_line(2:end));
				else
					x_line_v(i)			= mean(x_line);
					y_line_v(i)			= mean(y_line);
				end
		end
	end
	x	= nan;
	y	= nan;
	if any(~isnan(x_line_v))
		x	= mean(x_line_v(~isnan(x_line_v)));
		y	= mean(y_line_v(~isnan(y_line_v)));
	end
	if numboundaries(poly)>0
		[x_poly,y_poly]	= centroid(poly);
		x_v					= [x;x_poly];
		y_v					= [y;y_poly];
		x						= mean(x_v(~isnan(x_v)));
		y						= mean(y_v(~isnan(y_v)));
	end

catch ME
	errormessage('',ME);
end

