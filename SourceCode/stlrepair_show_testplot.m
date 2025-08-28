function [h_title,ha,tp_patch1]		= stlrepair_show_testplot(T,plotvertno,hf,name_str,title_str)

try

	TR = triangulation(T.ConnectivityList,T.Points);

	hf=figure(hf);
	clf(hf,'reset');
	hf.Name	= name_str;
	hf.NumberTitle	= 'off';
	ha		= axes(hf);
	axis(ha,'equal');
	cameratoolbar(hf,'Show');
	hold(ha,'on');
	xlabel(ha,'x / mm');
	ylabel(ha,'y / mm');
	zlabel(ha,'z / mm');
	h_title	= title(ha,title_str,'Interpreter','none');
	fontsize		= 12;
	F=[TR.ConnectivityList(:,1) ...
		TR.ConnectivityList(:,2) ...
		TR.ConnectivityList(:,3) ...
		TR.ConnectivityList(:,1)];
	tp_patch1=patch(ha,'faces',F,'vertices',TR.Points,...
		'EdgeColor',[0 0.6 0],'FaceColor',[0 0 1],'FaceAlpha',0.075,'EdgeAlpha',0.3);
	plot3(ha,TR.Points(:,1),TR.Points(:,2),TR.Points(:,3),...
		'LineWidth',0.5,'LineStyle','none','Color','k',...
		'Marker','.','MarkerSize',10);
	view(ha,3);
	axis(ha,'equal');
	if plotvertno
		for i=1:size(TR.Points,1)
			text(ha,TR.Points(i,1),TR.Points(i,2),TR.Points(i,3),num2str(i),...
				'FontSize',fontsize,'FontWeight','bold','Color','k','HorizontalAlignment','center');
		end
		P = incenter(TR);
		for i=1:size(P,1)
			text(ha,P(i,1),P(i,2),P(i,3),num2str(i),...
				'FontSize',fontsize,'FontWeight','bold','Color','b','HorizontalAlignment','center');
		end
		E							= edges(TR);
		for i=1:size(E,1)
			text(ha,...
				(TR.Points(E(i,1),1)+TR.Points(E(i,2),1))/2,...
				(TR.Points(E(i,1),2)+TR.Points(E(i,2),2))/2,...
				(TR.Points(E(i,1),3)+TR.Points(E(i,2),3))/2,...
				num2str(i),...
				'FontSize',fontsize,'FontWeight','bold','Color',[0 0.6 0],'HorizontalAlignment','center');
		end
	end

catch ME
	errormessage('',ME);
end

