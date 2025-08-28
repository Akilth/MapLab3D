function ax_2dmap_zoomselection

global MAP_OBJECTS

try

	xyinit		= 1e12;
	xmin_all		= xyinit;
	ymin_all		= xyinit;
	xmax_all		= -xyinit;
	ymax_all		= -xyinit;
	for imapobj=1:size(MAP_OBJECTS,1)
		for r=1:size(MAP_OBJECTS(imapobj,1).h,1)
			for c=1:size(MAP_OBJECTS(imapobj,1).h,2)
				if MAP_OBJECTS(imapobj,1).h(r,c).Selected
					switch MAP_OBJECTS(imapobj,1).h(r,c).Type
						case 'polygon'
							x_v		= MAP_OBJECTS(imapobj,1).h(r,c).Shape.Vertices(:,1);
							y_v		= MAP_OBJECTS(imapobj,1).h(r,c).Shape.Vertices(:,2);
						case 'line'
							x_v		= MAP_OBJECTS(imapobj,1).h(r,c).XData;
							y_v		= MAP_OBJECTS(imapobj,1).h(r,c).YData;
						otherwise
							x_v		= [];
							y_v		= [];
					end
					if ~isempty(x_v)
						xmin		= min(x_v);
						xmax		= max(x_v);
						ymin		= min(y_v);
						ymax		= max(y_v);
						if xmin<xmin_all
							xmin_all		= xmin;
						end
						if xmax>xmax_all
							xmax_all		= xmax;
						end
						if ymin<ymin_all
							ymin_all		= ymin;
						end
						if ymax>ymax_all
							ymax_all		= ymax;
						end
					end
				end
			end
		end
	end
	if    ~isequal(xmin_all,xyinit)&&...
			~isequal(ymin_all,xyinit)&&...
			~isequal(xmax_all,-xyinit)&&...
			~isequal(ymax_all,-xyinit)
		K	= 0.025;			% 0.5
		x1	= xmin_all-(xmax_all-xmin_all)*K;
		x2	= xmax_all+(xmax_all-xmin_all)*K;
		y1	= ymin_all-(ymax_all-ymin_all)*K;
		y2	= ymax_all+(ymax_all-ymin_all)*K;
		ax_2dmap_zoom('set',x1,y1,x2,y2);
	end

catch ME
	errormessage('',ME);
end

