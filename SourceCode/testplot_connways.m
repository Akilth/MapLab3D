function testplot_connways(connways)

try

	% hf	= figure(7529983);
	hf	= figure;
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	ha	= axes;
	hold(ha,'on');

	for k_line=1:size(connways.lines,1)
		plot(ha,connways.lines(k_line,1).xy(:,1),connways.lines(k_line,1).xy(:,2),'-b')
	end
	for k_area=1:size(connways.areas,1)
		plot(ha,connways.areas(k_area,1).xy(:,1),connways.areas(k_area,1).xy(:,2),'-b')
	end
	if ~isempty(connways.nodes)
		plot(ha,connways.nodes.xy(:,1),connways.nodes.xy(:,2),'.r')
	end
	axis(ha,'equal');

catch ME
	errormessage('',ME);
end

