function source	= copy_source(ud)
% Create a new source data plot
% The source plots are made visible, if the corresponding text or symbol is selected.
% This makes it easier to move the texts and symbols to the right place when editing the map.
% Syntax:
% source			= copy_source(ud);			% Create a new source data plot
% if ~isempty(source)
% 	ud.source	= source;
% end

global GV_H

try

	source					= [];
	ud_source				= [];
	ud_source.issource	= true;	% to recognize it as source
	ud_source.imapobj		= 0;		% save_project: save the index imapobj
	%										  load_project: assign the source plot to the corresponding text/symbol
	if isfield(ud,'source')
		for ksource=1:size(ud.source,1)
			if ishandle(ud.source(ksource,1).h)
				source(end+1,1).h	= plot(GV_H.ax_2dmap,...
					ud.source(ksource,1).h.XData,...
					ud.source(ksource,1).h.YData,...
					'Color'     ,ud.source(ksource,1).h.Color,...
					'LineStyle' ,ud.source(ksource,1).h.LineStyle,...
					'LineWidth' ,ud.source(ksource,1).h.LineWidth,...
					'Marker'    ,ud.source(ksource,1).h.Marker,...
					'MarkerSize',ud.source(ksource,1).h.MarkerSize,...
					'UserData'  ,ud_source,...
					'Visible'   ,'off');
			end
		end
	end

catch ME
	errormessage('',ME);
end


