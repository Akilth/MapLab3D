function current_figure_set_view
% Set current figure View

global GV GV_H

try
	
	if    ~isfield(GV.current_figure_view,'fig')||...
			~isfield(GV.current_figure_view,'ax')
		return
	end
	
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
	
	fig.Units					= GV.current_figure_view.fig.Units;
	fig.Position(3)			= GV.current_figure_view.fig.Position(3);
	fig.Position(4)			= GV.current_figure_view.fig.Position(4);
	
	ax.Visible					= GV.current_figure_view.ax.Visible;
	ax.Units						= GV.current_figure_view.ax.Units;
	ax.Position					= GV.current_figure_view.ax.Position;
	ax.PositionConstraint	= GV.current_figure_view.ax.PositionConstraint;
	ax.Projection				= GV.current_figure_view.ax.Projection;
	
	ax.CameraViewAngle		= GV.current_figure_view.ax.CameraViewAngle;
	ax.CameraUpVector			= GV.current_figure_view.ax.CameraUpVector;
	ax.CameraPosition			= GV.current_figure_view.ax.CameraPosition;
	
	% ax.PlotBoxAspectRatio	= GV.current_figure_view.ax.PlotBoxAspectRatio;
	% ax.CameraTargetMode	= 'auto';
	% ax.CameraTarget			= GV.current_figure_view.ax.CameraTarget;
	% ax.View					= GV.current_figure_view.ax.View;
	% ax.XLim					= GV.current_figure_view.ax.XLim;
	% ax.YLim					= GV.current_figure_view.ax.YLim;
	% ax.ZLim					= GV.current_figure_view.ax.ZLim;
	
catch ME
	errormessage('',ME);
end
