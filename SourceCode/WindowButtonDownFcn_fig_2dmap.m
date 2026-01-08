function WindowButtonDownFcn_fig_2dmap(clicked_object,event_data)
% Executes if the mouse button in the 2D map figure is pressed.

global GV_H

GV_H.WindowButtonDownFcn_fig_2dmap.clicked_object		= clicked_object;
GV_H.WindowButtonDownFcn_fig_2dmap.event_data			= event_data;

GV_H.WindowButtonDownFcn_fig_2dmap.CurrentAxes			= GV_H.fig_2dmap.CurrentAxes;
GV_H.WindowButtonDownFcn_fig_2dmap.CurrentObject		= GV_H.fig_2dmap.CurrentObject;
GV_H.WindowButtonDownFcn_fig_2dmap.CurrentPoint			= GV_H.fig_2dmap.CurrentPoint;
GV_H.WindowButtonDownFcn_fig_2dmap.CurrentCharacter	= GV_H.fig_2dmap.CurrentCharacter;
GV_H.WindowButtonDownFcn_fig_2dmap.SelectionType		= GV_H.fig_2dmap.SelectionType;
GV_H.WindowButtonDownFcn_fig_2dmap.CurrentAxes			= GV_H.fig_2dmap.CurrentAxes;

% Intersection point in data units (formula see ButtonDownFcn_ax_2dmap):
mx			= GV_H.ax_2dmap.Position(3)/(GV_H.ax_2dmap.XLim(2)-GV_H.ax_2dmap.XLim(1));
my			= GV_H.ax_2dmap.Position(4)/(GV_H.ax_2dmap.YLim(2)-GV_H.ax_2dmap.YLim(1));
x_pixel	= GV_H.WindowButtonDownFcn_fig_2dmap.CurrentPoint(1,1);
y_pixel	= GV_H.WindowButtonDownFcn_fig_2dmap.CurrentPoint(1,2);
GV_H.WindowButtonDownFcn_fig_2dmap.x		= GV_H.ax_2dmap.XLim(1)+1/mx*(x_pixel-GV_H.ax_2dmap.Position(1));
GV_H.WindowButtonDownFcn_fig_2dmap.y		= GV_H.ax_2dmap.YLim(1)+1/my*(y_pixel-GV_H.ax_2dmap.Position(2));


