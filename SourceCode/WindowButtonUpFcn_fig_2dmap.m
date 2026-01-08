function WindowButtonUpFcn_fig_2dmap(clicked_object,event_data)
% Executes if the mouse button in the 2D map figure is released.

global GV_H

GV_H.WindowButtonUpFcn_fig_2dmap.clicked_object		= clicked_object;
GV_H.WindowButtonUpFcn_fig_2dmap.event.data			= event_data;

GV_H.WindowButtonUpFcn_fig_2dmap.CurrentAxes			= GV_H.fig_2dmap.CurrentAxes;
GV_H.WindowButtonUpFcn_fig_2dmap.CurrentObject		= GV_H.fig_2dmap.CurrentObject;
GV_H.WindowButtonUpFcn_fig_2dmap.CurrentPoint		= GV_H.fig_2dmap.CurrentPoint;
GV_H.WindowButtonUpFcn_fig_2dmap.CurrentCharacter	= GV_H.fig_2dmap.CurrentCharacter;
GV_H.WindowButtonUpFcn_fig_2dmap.SelectionType		= GV_H.fig_2dmap.SelectionType;
GV_H.WindowButtonUpFcn_fig_2dmap.CurrentAxes			= GV_H.fig_2dmap.CurrentAxes;

% Intersection point in data units (formula see ButtonDownFcn_ax_2dmap):
mx			= GV_H.ax_2dmap.Position(3)/(GV_H.ax_2dmap.XLim(2)-GV_H.ax_2dmap.XLim(1));
my			= GV_H.ax_2dmap.Position(4)/(GV_H.ax_2dmap.YLim(2)-GV_H.ax_2dmap.YLim(1));
x_pixel	= GV_H.WindowButtonUpFcn_fig_2dmap.CurrentPoint(1,1);
y_pixel	= GV_H.WindowButtonUpFcn_fig_2dmap.CurrentPoint(1,2);
GV_H.WindowButtonUpFcn_fig_2dmap.x		= GV_H.ax_2dmap.XLim(1)+1/mx*(x_pixel-GV_H.ax_2dmap.Position(1));
GV_H.WindowButtonUpFcn_fig_2dmap.y		= GV_H.ax_2dmap.YLim(1)+1/my*(y_pixel-GV_H.ax_2dmap.Position(2));

% Call ButtonDownFcn_ax_2dmap:

% Example parameters:
% rbbox_pos =
%    239   199    55    52
% 	rbbox_pos = [220   228     0     0]
% 	clicked_object = Polygon with properties:
%     FaceColor: [0.8627 0.8627 0.8627]
%     FaceAlpha: 0.3500
%     EdgeColor: [0 0 0]
%     LineWidth: 0.5000
%     LineStyle: '-'
%         Shape: [1×1 polyshape]
% event_data = Hit with properties:
%                Button: 1
%     IntersectionPoint: [-120.8314 137.0865 9.4118e-07]
%                Source: [1×1 Polygon]
%             EventName: 'Hit'

event_data		= [];
switch GV_H.WindowButtonUpFcn_fig_2dmap.SelectionType
	case 'normal'
		% Click the left mouse button.
		event_data.Button		= 1;
	case 'extend'
		% Any of the following:
		% - Shift-click the left mouse button.
		% - Click the middle mouse button.
		% - Click both left and right mouse buttons.
		event_data.Button		= 2;
	case 'alt'
		% Either of the following:
		% - Control-click the left mouse button.
		% - Click the right mouse button.
		event_data.Button		= 3;
	case 'open'
		% Double-click any mouse button.
		event_data.Button		= 1;
end
event_data.IntersectionPoint	= [GV_H.WindowButtonDownFcn_fig_2dmap.x GV_H.WindowButtonDownFcn_fig_2dmap.y 0];
event_data.Source					= GV_H.WindowButtonDownFcn_fig_2dmap.CurrentObject;
event_data.EventName				= 'Hit';

% Points in pixels:
x1p		= GV_H.WindowButtonDownFcn_fig_2dmap.CurrentPoint(1,1);
y1p		= GV_H.WindowButtonDownFcn_fig_2dmap.CurrentPoint(1,2);
x2p		= GV_H.WindowButtonUpFcn_fig_2dmap.CurrentPoint(1,1);
y2p		= GV_H.WindowButtonUpFcn_fig_2dmap.CurrentPoint(1,2);

% Selected area, where x and y are the x and y components of the lower left corner of the box, 
% and width and height are the size of the box: see command rbbox.
rbbox_pos	= [min(x1p,x2p) min(y1p,y2p) abs(x2p-x1p) abs(y2p-y1p)];

% Call the ButtonDownFcn_ax_2dmap callback manually:
ButtonDownFcn_ax_2dmap(...
	GV_H.WindowButtonDownFcn_fig_2dmap.CurrentObject,...		% clicked_object
	event_data,...			% event_data
	rbbox_pos);		% rbbox_pos

