function get_building_topside_testplot_nwr(type,inwr,x,y,ax1)
% Display tags in the command window and plot the xy data in the axis ax1.

global GV

x = x(:);
y = y(:);

[tags_full_str,tags_str] = get_tags_str(type,inwr);
fprintf(1,'%s',tags_full_str);

if size(x,1) == 1
	
	% node:
	plot(ax1,x,y,'.r','MarkerSize',20);
	
elseif (abs(x(1,1)-x(end,1))<GV.tol_1) && (abs(y(1,1)-y(end,1))<GV.tol_1)
	
	% closed way:
	poly_way	= polyshape(x,y);
	plot(ax1,poly_way,'FaceAlpha',0,'EdgeColor','r');
	plot(ax1,poly_way.Vertices(:,1),poly_way.Vertices(:,2),'.r','MarkerSize',10);
	
else
	
	% open way:
	plot(ax1,x(:,1),y(:,1),'.-r','MarkerSize',10);
	
end

title(ax1,tags_str,'Interpreter','none');
pause(0.001);
setbreakpoint = 1;					% Set breakpoint here in order to see every single way of the relation.

for ic=1:size(ax1.Children,1)
	if strcmp(ax1.Children(ic,1).Type,'polygon')
		ax1.Children(ic,1).EdgeColor = [1 1 1]*0.8;
	elseif strcmp(ax1.Children(ic,1).Type,'line')
		ax1.Children(ic,1).Color = [1 1 1]*0.8;
	end
end

