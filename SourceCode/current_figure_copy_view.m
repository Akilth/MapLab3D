function current_figure_copy_view
% Copy current figure View

global GV GV_H

try
	
	fig		= gcf;
	fig_ch	= fig.Children;
	ax			= [];
	warntext	= '';
	for i_fig_ch=1:length(fig_ch)
		if strcmp(fig_ch(i_fig_ch).Type,'axes')
			if isempty(ax)
				ax		= fig_ch(i_fig_ch);
			else
				warntext		= sprintf([...
					'The figure "%s"\n',...
					'contains more than one axis.'],fig_ch.Name);
			end
		end
	end
	if ~isempty(warntext)
		if isfield(GV_H.warndlg,'maplab3d')
			if ishandle(GV_H.warndlg.maplab3d)
				close(GV_H.warndlg.maplab3d);
			end
		end
		warntext	= sprintf([...
			'%s\n',...
			'It is not possible to copy the settings of this figure.'],warntext);
		GV_H.warndlg.maplab3d		= warndlg(warntext,'Warning');
		GV_H.warndlg.maplab3d.Tag	= 'maplab3d_figure';
		return
	end
	
	GV.current_figure_view.fig.Units						= fig.Units;
	GV.current_figure_view.fig.Position					= nan(1,4);
	GV.current_figure_view.fig.Position(3)				= fig.Position(3);
	GV.current_figure_view.fig.Position(4)				= fig.Position(4);
	
	GV.current_figure_view.ax.Visible					= ax.Visible;
	GV.current_figure_view.ax.Units						= ax.Units;
	GV.current_figure_view.ax.Position					= ax.Position;
	GV.current_figure_view.ax.PositionConstraint		= ax.PositionConstraint;
	GV.current_figure_view.ax.Projection				= ax.Projection;
	
	GV.current_figure_view.ax.CameraViewAngle			= ax.CameraViewAngle;
	GV.current_figure_view.ax.CameraUpVector			= ax.CameraUpVector;
	GV.current_figure_view.ax.CameraPosition			= ax.CameraPosition;
	
	% GV.current_figure_view.ax.PlotBoxAspectRatio	= ax.PlotBoxAspectRatio;
	% GV.current_figure_view.ax.CameraTarget			= ax.CameraTarget;
	% GV.current_figure_view.ax.View						= ax.View;
	% GV.current_figure_view.ax.XLim						= ax.XLim;
	% GV.current_figure_view.ax.YLim						= ax.YLim;
	% GV.current_figure_view.ax.ZLim						= ax.ZLim;
	
catch ME
	errormessage('',ME);
end
