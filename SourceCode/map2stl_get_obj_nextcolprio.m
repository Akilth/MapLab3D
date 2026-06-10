function obj_nextcolprio=...
	map2stl_get_obj_nextcolprio(...
	obj_bot_reg,...
	colprio_base,...
	PP_local,tol_1,...
	xmin_mm,xmax_mm,ymin_mm,ymax_mm,...
	testplot_obj_bot_reg,testplot_obj_ncp,testplot_obj_ncp_1plot,testplot_xylimits,...
	currpart_i_tile,currpart_i_colprio,currpart_i_part,imax_part)
% Berechnung der Struktur obj_nextcolprio, die die Kartenobjekte der nächsthöheren Farbpriorität enthält.
% Diese Funktion wurde aus map2stl_topside_triangulation.m.m ausgelagert, um sie mit Testdaten separat ausführen
% zu können.

global GV

% Testing:
testplot		= false;
if nargin==0
	testplot		= true;
	testdata_no	= 1;
	switch testdata_no
		case 1
			load('C:\Daten\Projekte\MapLab3D_Ablage\00_Matlab\Test\test_map2stl_get_obj_nextcolprio_001.mat');
			iobj_reg_test		= 5;
			i_region1_test		= 1;
			xmin_mm	= -116.618364184781;
			xmax_mm	= -116.618352917471;
			ymin_mm	= 154.901676644165;
			ymax_mm	= 154.901690676927;
	end
	testplot_obj_ncp		= 1;
	% Testplot:
	tp_fig_h		= figure(100270);
	clf(tp_fig_h,'reset');
	set(tp_fig_h,'Tag','maplab3d_figure');
	set(tp_fig_h,'Name','test_obj_ncp');
	set(tp_fig_h,'NumberTitle','off');
	for i=1:6
		tp_ax(i,1).h		= subplot(3,2,i);
		axis(tp_ax(i,1).h,'equal');
		hold(tp_ax(i,1).h,'on');
		tp_ax(i,1).h.XLim		= [xmin_mm xmax_mm];
		tp_ax(i,1).h.YLim		= [ymin_mm ymax_mm];
	end
end

%------------------------------------------------------------------------------------------------------------------
% obj_nextcolprio
%------------------------------------------------------------------------------------------------------------------
% Außenabmessungen der als nächstes zu erstellenden Teile mit der nächsthöheren Farbe:
% Ergebnis:		obj_nextcolprio.poly(iobj)
%					obj_nextcolprio.colno(iobj)
% 					obj_nextcolprio.dz(iobj)
% 					obj_nextcolprio.z_bot(iobj)
% 					obj_nextcolprio.zbotmax(iobj)
% 					obj_nextcolprio.zmin(iobj
% 					obj_nextcolprio.zmax(iobj
% 					obj_nextcolprio.colprio(iobj)
% 					obj_nextcolprio.srftype(iobj)

if (currpart_i_tile==1)&&(currpart_i_colprio==2)&&(currpart_i_part==1)
	test=1;
end
if (currpart_i_tile==1)&&(currpart_i_colprio==4)
	test=1;
end

obj_nextcolprio	= [];
colprio_sort		= sort(unique(obj_bot_reg.colprio));
i_colprio_base		= find(colprio_sort==colprio_base);
if (length(i_colprio_base)<length(colprio_sort))&&(currpart_i_part==imax_part)
	% Es ist noch eine weitere Farbe vorhanden:
	colprio_next	= colprio_sort(i_colprio_base+1);
	iobj	= 0;
	for iobj_reg=1:length(obj_bot_reg.poly)
		if obj_bot_reg.colprio(iobj_reg)==colprio_next
			% Der Einfachheit halber sollen nur einzelne Regionen bearbeitet werden.
			% So gibt es nur einen äußeren und ggf. mehrere innere Ränder eines Druckteils.
			if GV.warnings_off
				warning('off','MATLAB:polyshape:tinyBoundaryDropped');
			end
			poly1		= regions(obj_bot_reg.poly(iobj_reg));
			if GV.warnings_off
				warning('on','MATLAB:polyshape:tinyBoundaryDropped');
			end
			for i_region1=1:length(poly1)
				
				% Die Randlinie des nächsten Objekts wird verkleinert,
				% damit keine schmalen Linien am Rand übrig bleiben, die bei der Triangulation Probleme machen:
				
				% Problem: Wenn Punkte einen sehr kleinen Abstand haben, kann polybuffer an dieser Stelle
				%          schmale Einschnitte oder kleine zusätzliche Regionen erzeugen (siehe Testdaten Nr. 1).
				% Daher wird zunächst die Auflösung reduziert, um dieses Problem bei polybuffer zu vermeiden:
				% 1)	If dmax is not empty:
				%		Inserts vertices to polyin, so that the distance between two vertices is less than dmax
				% 2)	If dmin is not empty:
				%		Deletes vertices in polyin, so that the distance between two vertices is at least dmin
				%		Possibly there remains no data in polyout!
				% 3)	If nmin is not empty:
				%		Insert at least nmin vertices between 2 vertices in polyin (AFTER deleting vertices according dmin)
				dmax		= [];
				dmin		= tol_1/5;
				nmin		= [];
				
				% Verringere die Auflösung, damit polybuffer besser funktioniert:
				poly1_i_region1_mtol1		= poly1(i_region1);
				poly1_i_region1_mtol1		= changeresolution_poly(poly1_i_region1_mtol1,dmax,dmin,nmin);
				if testplot
					poly1_i_region1_mtol1_tp(1,1)	= poly1_i_region1_mtol1;
				end
				for i=1:10
					% Die Randlinie verkleinern und die Schnittfläche mit dem Original poly1(i_region1) bilden:
					poly1_i_region1_mtol1		= polybuffer(poly1_i_region1_mtol1,-tol_1,...
						'JointType','miter','MiterLimit',2);
					poly1_i_region1_mtol1		= intersect(poly1_i_region1_mtol1,poly1(i_region1));
					% Die Auflösung wiederum reduzieren:
					poly1_i_region1_mtol1		= changeresolution_poly(poly1_i_region1_mtol1,dmax,dmin,nmin);
					if testplot
						poly1_i_region1_mtol1_tp(end+1,1)	= poly1_i_region1_mtol1;
					end
					% Wiederhole dies solange, bis poly1_i_region1_mtol1 vollständig innerhalb von poly1(i_region1) liegt:
					if numboundaries(subtract(poly1_i_region1_mtol1,poly1(i_region1)))==0
						break
					end
				end
				% Testing:
				if i==10
					% save('C:\Daten\Projekte\MapLab3D_Ablage\00_Matlab\Test\test_map2stl_get_obj_nextcolprio_002.mat',...
					% 	'obj_bot_reg','colprio_base','PP_local','tol_1',...
					% 	'xmin_mm','xmax_mm','ymin_mm','ymax_mm',...
					% 	'testplot_obj_bot_reg','testplot_obj_ncp','testplot_obj_ncp_1plot','testplot_xylimits',...
					% 	'currpart_i_tile','currpart_i_colprio','currpart_i_part','imax_part');
					setbreakpoint=1;
				end
				% Verkleinere die Randlinie ein letztes Mal (ohne Reduzierung der Auflösung):
				poly1_i_region1_mtol1		= polybuffer(poly1_i_region1_mtol1,-tol_1,...
					'JointType','miter','MiterLimit',2);
				if testplot
					poly1_i_region1_mtol1_tp(end+1,1)	= poly1_i_region1_mtol1;
				end
				% poly1_i_region1_mtol1 liegt nun sicher mit Abstand innerhalb von poly1(i_region1)!
				
				% In der Funktion get_T_margin/triangulation_simplify werden Punkte mit einem Abstand kleiner als
				% GV.tol_tp zu einem Punkt zusammengefasst, um die Triangulationsdaten zu vereinfachen und um
				% Fehler bei der Bestimmung der Randlinie zu minimieren.
				% Dafür muss verhindert werden, dass sich das Teil am Rand selbst berührt, sonst könnten
				% Punkte zusammengefasst werden, die nicht zusammengehören.
				% Vorgehensweise:
				% Um poly1_i_region1_mtol1 wird ein 3*GV.tol_tp breiter Streifen gelegt und dann dieser Streifen
				% von poly1_i_region1_mtol1 subtrahiert. Normalerweise sollte das Polygon poly1_i_region1_mtol1
				% dadurch nicht verändert werden.
				poly1_i_region1_ptoltp		= polybuffer(poly1_i_region1_mtol1,3*GV.tol_tp,...
					'JointType','miter','MiterLimit',2);
				poly_strip						= subtract(poly1_i_region1_ptoltp,poly1_i_region1_mtol1,...
					'KeepCollinearPoints',false);
				poly_strip_buff				= polybuffer(poly_strip,-tol_1,...
					'JointType','miter','MiterLimit',2);
				poly1_i_region1				= subtract(poly1_i_region1_mtol1,poly_strip_buff,...
					'KeepCollinearPoints',false);
				
				% Testing:
				if testplot
					if (any(iobj_reg==iobj_reg_test)&&any(i_region1==i_region1_test))||...
							(isempty(iobj_reg_test)      &&isempty(i_region1_test)       )
						% 1: poly1(i_region1)
						cla(tp_ax(1,1).h);
						plot(tp_ax(1,1).h,poly1(i_region1));
						plot(tp_ax(1,1).h,poly1(i_region1).Vertices(:,1),poly1(i_region1).Vertices(:,2),'.-k');
						title(tp_ax(1,1).h,'poly1(i_region1)','Interpreter','none');
						% 2: poly1_i_region1_mtol1_tp
						cla(tp_ax(2,1).h);
						plot(tp_ax(2,1).h,poly1(i_region1));
						for i=1:(size(poly1_i_region1_mtol1_tp,1)-1)
							plot(tp_ax(2,1).h,poly1_i_region1_mtol1_tp(i,1).Vertices(:,1),poly1_i_region1_mtol1_tp(i,1).Vertices(:,2),'.-b');
						end
						plot(tp_ax(2,1).h,poly1_i_region1_mtol1.Vertices(:,1),poly1_i_region1_mtol1.Vertices(:,2),'.-r');
						title(tp_ax(2,1).h,sprintf('poly1_i_region1_mtol1'),'Interpreter','none');
						% 3: poly1_i_region1_ptoltp
						cla(tp_ax(3,1).h);
						plot(tp_ax(3,1).h,poly1_i_region1_ptoltp);
						plot(tp_ax(3,1).h,poly1_i_region1_mtol1.Vertices(:,1),poly1_i_region1_mtol1.Vertices(:,2),'.-r');
						title(tp_ax(3,1).h,sprintf('poly1_i_region1_ptoltp'),'Interpreter','none');
						% 4: poly_strip
						cla(tp_ax(4,1).h);
						plot(tp_ax(4,1).h,poly_strip);
						plot(tp_ax(4,1).h,poly1_i_region1_mtol1.Vertices(:,1),poly1_i_region1_mtol1.Vertices(:,2),'.-r');
						title(tp_ax(4,1).h,sprintf('poly_strip'),'Interpreter','none');
						% 5: poly_strip_buff
						cla(tp_ax(5,1).h);
						plot(tp_ax(5,1).h,poly_strip_buff);
						plot(tp_ax(5,1).h,poly1_i_region1_mtol1.Vertices(:,1),poly1_i_region1_mtol1.Vertices(:,2),'.-r');
						title(tp_ax(5,1).h,sprintf('poly_strip_buff'),'Interpreter','none');
						% 6: poly1_i_region1
						cla(tp_ax(6,1).h);
						plot(tp_ax(6,1).h,poly1_i_region1);
						plot(tp_ax(6,1).h,poly1_i_region1_mtol1.Vertices(:,1),poly1_i_region1_mtol1.Vertices(:,2),'.-r');
						title(tp_ax(6,1).h,sprintf('poly1_i_region1'),'Interpreter','none');
						setbreakpoint=1;
					end
				end
				
				% In Regionen aufteilen und die Regionen einzeln in obj_nextcolprio speichern:
				if GV.warnings_off
					warning('off','MATLAB:polyshape:tinyBoundaryDropped');
				end
				poly2		= regions(poly1_i_region1);
				if GV.warnings_off
					warning('on','MATLAB:polyshape:tinyBoundaryDropped');
				end
				for i_region2=1:length(poly2)
					% Durch numerische Probleme können kleine Regionen entstehen:
					[xlim,ylim] = boundingbox(poly2(i_region2));
					diag			= sqrt((xlim(2)-xlim(1))^2+(ylim(2)-ylim(1))^2);
					if (numboundaries(poly2(i_region2))>0)&&(diag>10*tol_1)
						iobj	= iobj+1;
						obj_nextcolprio.poly(iobj)			= poly2(i_region2);
						obj_nextcolprio.colno(iobj)		= obj_bot_reg.colno(iobj_reg);
						obj_nextcolprio.dz(iobj)			= obj_bot_reg.dz(iobj_reg);
						obj_nextcolprio.z_bot(iobj)		= obj_bot_reg.z_bot(iobj_reg);
						obj_nextcolprio.zbotmax(iobj)		= obj_bot_reg.zbotmax(iobj_reg);
						obj_nextcolprio.zmin(iobj)			= obj_bot_reg.zmin(iobj_reg);
						obj_nextcolprio.zmax(iobj)			= obj_bot_reg.zmax(iobj_reg);
						obj_nextcolprio.colprio(iobj)		= obj_bot_reg.colprio(iobj_reg);
						obj_nextcolprio.srftype(iobj)		= obj_bot_reg.srftype(iobj_reg);
					end
				end
				
			end
		end
	end
else
	% Die aktuelle Grundfarbe ist bereits die letzte Farbe:
	obj_nextcolprio	= [];
end

% Testplots:
if (testplot_obj_ncp>0)&&~isempty(obj_nextcolprio)
	
	if ~isempty(testplot_xylimits)
		iobj_v			= 1;
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		[xb_poly_xylimits,yb_poly_xylimits]		= boundary(poly_xylimits);
		for iobj=1:length(obj_nextcolprio.poly)
			if overlaps(obj_nextcolprio.poly(iobj),poly_xylimits)
				iobj_v	= [iobj_v;iobj];
			end
		end
		iobj_v	= unique(iobj_v);
		imax_obj	= length(iobj_v);
	else
		imax_obj	= length(obj_nextcolprio.poly);
		iobj_v	= (1:imax_obj)';
	end
	m_obj		= ceil(sqrt(imax_obj+1));
	n_obj		= ceil((imax_obj+1)/m_obj);
	hf			= 100280;
	if testplot_obj_bot_reg==1
		hf=figure(hf);
	else
		hf=figure(hf+currpart_i_tile*10000+currpart_i_colprio*100+currpart_i_part);
	end
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	if testplot_obj_ncp==1
		set(hf,'Name','obj_ncp');
	else
		set(hf,'Name',sprintf('obj_ncp %1.0f/%1.0f/%1.0f',currpart_i_tile,currpart_i_colprio,currpart_i_part));
	end
	set(hf,'NumberTitle','off');
	
	for k=1:length(iobj_v)
		iobj	= iobj_v(k);
		ha=subplot(m_obj,n_obj,k);
		hold(ha,'on');
		axis(ha,'equal');
		plot(ha,obj_nextcolprio.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_nextcolprio.colno(iobj)).rgb/255)
		plot(ha,obj_nextcolprio.poly(iobj).Vertices(:,1),obj_nextcolprio.poly(iobj).Vertices(:,2),...
			'LineWidth',0.5,'LineStyle','none','Marker','.','MarkerSize',5,...
			'Color','k');
		if ~isempty(testplot_xylimits)
			plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
			set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
			set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
		else
			set(ha,'XLim',[xmin_mm xmax_mm]);
			set(ha,'YLim',[ymin_mm ymax_mm]);
		end
		title(sprintf('i=%g, cp=%g, st=%g\ndz=%g\nzb=%g, zbmax=%g\nzmin=%1.4f, zmax=%1.4f',...
			iobj,obj_nextcolprio.colprio(iobj),obj_nextcolprio.srftype(iobj),...
			obj_nextcolprio.dz(iobj),...
			obj_nextcolprio.z_bot(iobj),obj_nextcolprio.zbotmax(iobj),...
			obj_nextcolprio.zmin(iobj),obj_nextcolprio.zmax(iobj)),'Interpreter','none')
	end
	
	ha=subplot(m_obj,n_obj,imax_obj+1);
	hold(ha,'on');
	axis(ha,'equal');
	imax_obj	= length(obj_nextcolprio.poly);
	for iobj=1:imax_obj
		plot(ha,obj_nextcolprio.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
			PP_local.color(obj_nextcolprio.colno(iobj)).rgb/255)
	end
	if ~isempty(testplot_xylimits)
		plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
	end
	set(ha,'XLim',[xmin_mm xmax_mm]);
	set(ha,'YLim',[ymin_mm ymax_mm]);
	title(sprintf('i=1...%g',imax_obj),'Interpreter','none')
	
	setbreakpoint	= 1;
end

if testplot_obj_ncp_1plot==1
	hf=figure(100290);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','obj_ncp');
	set(hf,'NumberTitle','off');
	ha=axes(hf);
	hold(ha,'on');
	axis(ha,'equal');
	if ~isempty(obj_nextcolprio)
		imax_obj	= length(obj_nextcolprio.poly);
		for iobj=1:imax_obj
			plot(ha,obj_nextcolprio.poly(iobj),...
				'LineWidth',0.5,'LineStyle','-','EdgeColor','k','FaceColor',...
				PP_local.color(obj_nextcolprio.colno(iobj)).rgb/255)
		end
	end
	if ~isempty(testplot_xylimits)
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		[xb_poly_xylimits,yb_poly_xylimits]		= boundary(poly_xylimits);
		plot(ha,xb_poly_xylimits,yb_poly_xylimits,'-r');
	end
	set(ha,'XLim',[xmin_mm xmax_mm]);
	set(ha,'YLim',[ymin_mm ymax_mm]);
	title(sprintf('i=1...%g',imax_obj),'Interpreter','none')
	setbreakpoint	= 1;
end
