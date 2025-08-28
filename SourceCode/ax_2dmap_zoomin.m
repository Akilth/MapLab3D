function [x1,y1,x2,y2]=ax_2dmap_zoomin(x1,y1,x2,y2)

global GV_H

try

	% Zoom in:
	dx			= abs(x2-x1);
	dy			= abs(y2-y1);
	h_w		= diff(GV_H.ax_2dmap.UserData.ylim0)/diff(GV_H.ax_2dmap.UserData.xlim0);
	dy_dx		= dy/dx;
	if dy_dx>h_w
		% Set YLim:
		GV_H.ax_2dmap.YLim	= [min([y1 y2]) max([y1 y2])];
		GV_H.ax_2dmap.XLim	= (x1+x2)/2+[-0.5 0.5]*diff(GV_H.ax_2dmap.YLim)/h_w;
	else
		% Set XLim:
		GV_H.ax_2dmap.XLim	= [min([x1 x2]) max([x1 x2])];
		GV_H.ax_2dmap.YLim	= (y1+y2)/2+[-0.5 0.5]*diff(GV_H.ax_2dmap.XLim)*h_w;
	end
	x1		= GV_H.ax_2dmap.XLim(1,1);
	y1		= GV_H.ax_2dmap.YLim(1,1);
	x2		= GV_H.ax_2dmap.XLim(1,2);
	y2		= GV_H.ax_2dmap.YLim(1,2);

catch ME
	errormessage('',ME);
end

