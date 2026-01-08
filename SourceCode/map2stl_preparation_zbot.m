function obj_reg=map2stl_preparation_zbot(...
	obj_reg,...
	obj_reg_union_ovcol,...
	ELE_local,...
	PP_local,...
	iobj2_v,...
	msg,...
	poly_legbgd,...
	prio_legbgd,...
	tol_1,...
	testout_dzbot,...
	testplot_obj_reg,...
	testplot_obj_reg_1plot,...
	testplot_xylimits)

global GV GV_H PRINTDATA WAITBAR

% Testing:
if nargin==0
	load('C:\Daten\Projekte\MapLab3D_Ablage\temp1.mat')
	whos
	testplot_obj_reg	= 1;
end
testplot_local		= false;
testplot_iobj_v	= [];			% Vektor aus Objektnummern iobj, deren Testplots dargestellt werden,
%										  wenn testplot_local=false ist (default: []).


% --------------------------------------------------------------------------------------------------------------------
% obj_reg: aktuelle Werte mit .zmin
% --------------------------------------------------------------------------------------------------------------------

% Testplots:
if (testplot_obj_reg==1)
	
	if ~isempty(testplot_xylimits)
		iobj_v			= 1;
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		for iobj=1:length(obj_reg.poly)
			if overlaps(obj_reg.poly(iobj),poly_xylimits)
				iobj_v	= [iobj_v;iobj];
			end
		end
		iobj_v	= unique(iobj_v);
		imax_obj	= length(iobj_v);
	else
		imax_obj	= length(obj_reg.poly);
		iobj_v	= (1:imax_obj)';
	end
	m_obj		= ceil(sqrt(imax_obj));
	n_obj		= ceil((imax_obj)/m_obj);
	hf			= figure(100160);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','obj_reg_0');
	set(hf,'NumberTitle','off');
	
	for k=1:length(iobj_v)
		iobj	= iobj_v(k);
		ha=subplot(m_obj,n_obj,k);
		hold(ha,'on');
		axis(ha,'equal');
		plot(ha,obj_reg.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-',...
			'EdgeColor','k','FaceColor',PP_local.color(obj_reg.colno(iobj)).rgb/255)
		if ~isempty(testplot_xylimits)
			set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
			set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
		else
			set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
			set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
		end
		title(sprintf('i=%g, dz=%g\nzmin=%g, zmax=%g\ncp=%g, op=%g, st=%g',...
			iobj,obj_reg.dz(iobj),...
			obj_reg.zmin(iobj),obj_reg.zmax(iobj),...
			obj_reg.colprio(iobj),obj_reg.objprio(iobj),obj_reg.srftype(iobj)),...
			'Interpreter','none');
	end
	
end

if testplot_obj_reg_1plot==1
	imax_obj=length(obj_reg.poly);
	hf=figure(100170);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','obj_reg_0');
	set(hf,'NumberTitle','off');
	ha=axes(hf);
	hold(ha,'on');
	axis(ha,'equal');
	for iobj=2:imax_obj
		plot(ha,obj_reg.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-',...
			'EdgeColor','k','FaceColor',PP_local.color(obj_reg.colno(iobj)).rgb/255)
	end
	if ~isempty(testplot_xylimits)
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		[x,y]				= boundary(poly_xylimits);
		plot(ha,x,y,'-r');
	end
	set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
	set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
	title(sprintf('i=2...%g',imax_obj),'Interpreter','none')
end

method_zbot		= 2;
switch method_zbot
	case 1
		% --------------------------------------------------------------------------------------------------------------
		% Erste Methode: Die Unterseite wird anhand der Anzahl der darüberliegenden Farben abgesenkt, unabhängig
		% davon, ob sich diese Farben überlappen oder nicht: Die Teile werden unnötig hoch!
		% --------------------------------------------------------------------------------------------------------------
		
		% Zur Überprüfung ob sich Objekte überlappen:
		% obj_reg_union_ovcol.poly(iobj) um PP_local.colorspec(icolspec).d_side vergrößern:
		for iobj=1:length(obj_reg_union_ovcol.poly)
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1		= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: Object bottom height (2): %g/%g',msg,iobj,length(obj_reg_union_ovcol.poly)));
				drawnow;
			end
			for icolspec=1:length(PP_local.colorspec)
				d_side	= PP_local.colorspec(icolspec).d_side;
				if strcmp(GV.jointtype_bh,'miter')
					obj_reg_union_ovcol.polybuffer(iobj,icolspec)	= ...
						polybuffer(obj_reg_union_ovcol.poly(iobj),d_side,'JointType',GV.jointtype_bh,...
						'MiterLimit',GV.miterlimit_bh);
				else
					obj_reg_union_ovcol.polybuffer(iobj,icolspec)	= ...
						polybuffer(obj_reg_union_ovcol.poly(iobj),d_side,'JointType',GV.jointtype_bh);
				end
			end
		end
		
		for iobj=length(obj_reg_union_ovcol.poly):-1:1
			dz_bot_legobj	= 1e10;
			
			% obj_reg_union_ovcol ist nach Farbpriorität sortiert, außer die ersten beiden Elemente!
			if numboundaries(obj_reg_union_ovcol.poly(iobj))>0
				% colorprio_above_v:	Vektor aller Farbprioritäten derselben Region und DARÜBERlieg. Objekte anderer Farbe
				% dzmin_above_v:		Vektor aller Werte dz der Region und DARÜBERlieg. Objekte anderer Farbe (min(dz))
				% zmin_above_v:		Vektor aller Werte zmin der Region und DARÜBERlieg. Objekte anderer Farbe (min(zmin))
				% min_thnss_above_v	Vektor aller Werte min_thickness der Region und DARÜBERlieg. Objekte anderer Farbe
				% d_bottom_above_v	Vektor aller Werte d_bottom der Region und DARÜBERlieg. Objekte anderer Farbe
				colno					= obj_reg_union_ovcol.colno(iobj);
				icolspec				= PP_local.color(colno).spec;
				colorprio_above_v	= obj_reg_union_ovcol.colprio(iobj);
				zmin_above_v		= obj_reg_union_ovcol.zmin(iobj);
				min_thnss_above_v	= PP_local.colorspec(icolspec).min_thickness;
				d_bottom_above_v	= PP_local.colorspec(icolspec).d_bottom;
				% minimaler Wert z_bot der oberhalb liegenden Teile:
				z_bot_above_min			= 1e10;
				% minimaler Wert z_bot der oberhalb liegenden Teile, nur bottom_version=1 (Unterseite ist flach):
				z_bot_above_min_bv1	= 1e10;
				% Wenn es nur pos. Werte dz gibt, wird hier als min. Absenkung dz=0 angenommen:
				dzmin_above_v		= min([0 obj_reg_union_ovcol.dz(iobj)]);
				% alle über obj_reg_union_ovcol.poly(iobj)) liegende Objekte, vereint, zur Kontrolle auf Überlappung:
				allpoly_above		= polyshape();
				for iobj_above=1:length(obj_reg_union_ovcol.poly)
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						WAITBAR.t1		= clock;
						set(GV_H.text_waitbar,'String',sprintf(...
							'%s: Object bottom height (3): %g/%g %g/%g',msg,...
							length(obj_reg_union_ovcol.poly)-iobj+1,length(obj_reg_union_ovcol.poly),...
							iobj_above,length(obj_reg_union_ovcol.poly)));
						drawnow;
					end
					if obj_reg_union_ovcol.colprio(iobj_above)>obj_reg_union_ovcol.colprio(iobj)
						if numboundaries(obj_reg_union_ovcol.poly(iobj_above))>0
							% Die Farbpriorität von iobj_above ist größer als von iobj:
							% iobj wird zuerst eingesetzt!
							% Damit ist bei der Prüfung auf Überlappung d_side von iobj_above zu verwenden.
							colno_above			= obj_reg_union_ovcol.colno(iobj_above);
							icolspec_above		= PP_local.color(colno_above).spec;
							ifs_above			= ELE_local.ifs_v(icolspec_above,1);
							min_thnss_above	= PP_local.colorspec(icolspec_above).min_thickness;
							d_bottom_above		= PP_local.colorspec(icolspec_above).d_bottom;
							if    (obj_reg_union_ovcol.objprio(iobj)      ==prio_legbgd)&&...
									(obj_reg_union_ovcol.objprio(iobj_above) >prio_legbgd)
								% Legend objects:
								% The objects inside the legend background do not overlap, so the colors do not stack.
								% Use the minimum values zmin, ...:
								dz_bot_legobj_test		= obj_reg_union_ovcol.zmin(iobj_above);
								for k=2:length(colorprio_above_v)
									dz_bot_legobj_test	= dz_bot_legobj_test+min([0 obj_reg_union_ovcol.dz(iobj_above)]);
									dz_bot_legobj_test	= dz_bot_legobj_test-min_thnss_above;
									dz_bot_legobj_test	= dz_bot_legobj_test-d_bottom_above;
								end
								if dz_bot_legobj_test<dz_bot_legobj
									% The current object above leads to a smaller values z_bot:
									colorprio_above_v(2,1)	= obj_reg_union_ovcol.colprio(iobj_above);
								end
								if size(dzmin_above_v,1)==1
									dzmin_above_v(2,1)		= min([0                  obj_reg_union_ovcol.dz(iobj_above)]);
								else
									dzmin_above_v(2,1)		= min([dzmin_above_v(2,1) obj_reg_union_ovcol.dz(iobj_above)]);
								end
								if size(zmin_above_v,1)==1
									zmin_above_v(2,1)			= obj_reg_union_ovcol.zmin(iobj_above);
								else
									zmin_above_v(2,1)			= min([zmin_above_v(2,1)  obj_reg_union_ovcol.zmin(iobj_above)]);
								end
								if size(min_thnss_above_v,1)==1
									min_thnss_above_v(2,1)	= min_thnss_above;
								else
									min_thnss_above_v(2,1)	= max([min_thnss_above_v(2,1) min_thnss_above]);
								end
								if size(d_bottom_above_v,1)==1
									d_bottom_above_v(2,1)	= d_bottom_above;
								else
									d_bottom_above_v(2,1)	= max([d_bottom_above_v(2,1)  d_bottom_above]);
								end
							else
								if overlaps(...
										obj_reg_union_ovcol.polybuffer(iobj,icolspec_above),...
										obj_reg_union_ovcol.poly(iobj_above))
									% Das Objekt iobj_above liegt oberhalb von iobj bzw:
									% obj_reg_union_ovcol.poly(iobj_above) liegt oberhalb von
									% obj_reg_union_ovcol.polybuffer(iobj,icolspec_above)
									% minimaler z-Wert des Polygons oberhalb: bestimmt die Absenkung der Unterseite:
									if PP_local.colorspec(icolspec_above).bottom_version==1
										% Unterseite ist flach:
										% z_bot_above_min nur für bottom_version=1:
										z_bot_above_min_bv1	= min([z_bot_above_min_bv1;obj_reg_union_ovcol.z_bot(iobj_above,1)]);
										% Das ganze Polygon oberhalb berücksichtigen:
										% der minimale Punkt kann auch außerhalb liegen:
										zmin_iobj_above		= obj_reg_union_ovcol.zmin(iobj_above);
										% minimaler z-Wert der Unterseiten von oberhalb liegenden Objekten:
										z_bot_above_min		= min([z_bot_above_min;obj_reg_union_ovcol.z_bot(iobj_above,1)]);
									else
										% Unterseite folgt dem Gelände:  Nur den Teil des Polygons oberhalb berücksichtigen,
										%                                der das Objekt iobj unterhalb bedeckt:
										poly_iobj_above_overlap	= intersect(...
											obj_reg_union_ovcol.polybuffer(iobj,icolspec_above),...
											obj_reg_union_ovcol.poly(iobj_above),...
											'KeepCollinearPoints',true);
										zmin_area	= 1e10;
										inpoly		= inpolygon(...
											ELE_local.elefiltset(ifs_above,1).xm_mm,...					% query points
											ELE_local.elefiltset(ifs_above,1).ym_mm,...					% query points
											poly_iobj_above_overlap.Vertices(:,1),...						% edges of the polygon area
											poly_iobj_above_overlap.Vertices(:,2));						% edges of the polygon area
										if any(inpoly,'all')
											zmin_area	= min(interp_ele(...
												ELE_local.elefiltset(ifs_above,1).xm_mm(inpoly),...	% query points x
												ELE_local.elefiltset(ifs_above,1).ym_mm(inpoly),...	% query points y
												ELE_local,...									% elevation structure
												colno_above,...								% color numbers
												GV.legend_z_topside_bgd,...				% legend background z-value
												poly_legbgd,...								% legend background polygon
												'interp2'));									% interpolation method
										end
										% Auflösung erhöhen:
										poly_incres		= changeresolution_poly(poly_iobj_above_overlap,...
											PP_local.general.dxy_ele_mm/4,...			% dmax
											[],...												% dmin
											[]);													% nmin
										z_margin		= interp_ele(...
											poly_incres.Vertices(:,1),...					% query points x
											poly_incres.Vertices(:,2),...					% query points y
											ELE_local,...										% elevation structure
											colno_above,...									% color numbers
											GV.legend_z_topside_bgd,...					% legend background z-value
											poly_legbgd,...									% legend background polygon
											'interp2');											% interpolation method
										zmin_margin			= min(z_margin);
										zmin_iobj_above	= min(zmin_area,zmin_margin);
										% minimaler z-Wert der Unterseiten von oberhalb liegenden Objekten:
										dz_bot_iobj_above	= obj_reg_union_ovcol.zmin(iobj_above,1)-obj_reg_union_ovcol.z_bot(iobj_above,1);
										z_bot_above_min	= min([z_bot_above_min;zmin_iobj_above-dz_bot_iobj_above]);
									end
									
									if numboundaries(allpoly_above)==0
										% erste neue Farbe hinzufügen:
										allpoly_above		= obj_reg_union_ovcol.poly(iobj_above);
										colorprio_above_v	= [colorprio_above_v;obj_reg_union_ovcol.colprio(iobj_above)    ];
										dzmin_above_v		= [dzmin_above_v    ;min([0 obj_reg_union_ovcol.dz(iobj_above)])];
										zmin_above_v		= [zmin_above_v     ;zmin_iobj_above       ];
										min_thnss_above_v	= [min_thnss_above_v;min_thnss_above                            ];
										d_bottom_above_v	= [d_bottom_above_v ;d_bottom_above                             ];
									else
										if overlaps(allpoly_above,obj_reg_union_ovcol.poly(iobj_above))
											% Überlappung mit anderen Objekten oberhalb von iobj erkannt:
											% Die Teile mit den verschiedenen Farben werden übereinander gestapelt und
											% die Werte min_thnss_above und d_bottom_above zu den anderen dazu addiert.
											k	= (colorprio_above_v==obj_reg_union_ovcol.colprio(iobj_above));
											if isempty(find(k,1))
												% neue Farbe hinzufügen:
												colorprio_above_v	= [colorprio_above_v;obj_reg_union_ovcol.colprio(iobj_above)    ];
												dzmin_above_v		= [dzmin_above_v    ;min([0 obj_reg_union_ovcol.dz(iobj_above)])];
												zmin_above_v		= [zmin_above_v     ;zmin_iobj_above       ];
												min_thnss_above_v	= [min_thnss_above_v;min_thnss_above                            ];
												d_bottom_above_v	= [d_bottom_above_v ;d_bottom_above                             ];
											else
												dzmin_above_v(k)	= min([dzmin_above_v(k);min([0 obj_reg_union_ovcol.dz(iobj_above)])]);
												zmin_above_v(k)	= min([zmin_above_v(k) ;zmin_iobj_above       ]);
											end
										else
											% Keine Überlappung mit anderen Objekten oberhalb von iobj:
											% Die z-Werte des akt. Objekts könnten niedriger oder die Abstände könnten höher sein
											% Werte ersetzen:
											% die positivsten Werte dzmin_above_v, zmin_above_v ersetzen und
											% die negativsten Werte min_thnss_above_v, d_bottom_above_versetzen
											[~,I] = max(dzmin_above_v(2:end));
											dzmin_above_v(I+1)		= ...
												min([min(dzmin_above_v(2:end)) obj_reg_union_ovcol.dz(iobj_above)]);
											[~,I] = max(zmin_above_v(2:end));
											zmin_above_v(I+1)			= ...
												min([min(zmin_above_v(2:end)) zmin_iobj_above]);
											[~,I] = min(min_thnss_above_v(2:end));
											min_thnss_above_v(I+1)	= ...
												max([max(min_thnss_above_v(2:end)) min_thnss_above]);
											[~,I] = min(d_bottom_above_v(2:end));
											d_bottom_above_v(I+1)	= ...
												max([max(d_bottom_above_v(2:end)) d_bottom_above]);
										end
									end
									% Alle Objekte oberhalb von iobj vereinen zur Prüfung auf gegenseitige Überlappung:
									allpoly_above	= union(allpoly_above,obj_reg_union_ovcol.poly(iobj_above),...
										'KeepCollinearPoints',false);
								end
							end
						end
					end
				end
				
				% Absenkung der "Löcher" für die aktuelle Grundfarbe berechnen:
				% Für alle Farbprioritäten außer der Grundfarbe: Werte z_bot zuweisen:
				% relevante Vorgaben:
				% PP_local.color(colno).prio								Druckfarbe Priorität
				% icolspec	= PP_local.color(colno).spec				Nr. von weiteren Einstellungen
				% PP_local.colorspec(icolspec).bottom_version		Nr. der Unterseite der Teile dieser Farbe
				% PP_local.colorspec(icolspec).d_side					horizontaler Abstand der Seitenwände zu benachbarten Teilen
				% PP_local.colorspec(icolspec).d_bottom				vertikaler Abstand der Unterseite zu unterlagerten Teilen
				% PP_local.colorspec(icolspec).min_thickness			minimale verbleibende Materialstärke in vertikaler Richtung
				% Für die Berechnung der absoluten z-Werte muss noch die Geländehöhe berücksichtigt werden.
				% Stärken der oberhalb liegenden Schichten addieren:
				obj_reg_union_ovcol.z_bot(iobj,1)		= min(zmin_above_v);
				for k=2:length(colorprio_above_v)
					obj_reg_union_ovcol.z_bot(iobj,1)	= obj_reg_union_ovcol.z_bot(iobj,1)+dzmin_above_v(k);
					obj_reg_union_ovcol.z_bot(iobj,1)	= obj_reg_union_ovcol.z_bot(iobj,1)-min_thnss_above_v(k);
					obj_reg_union_ovcol.z_bot(iobj,1)	= obj_reg_union_ovcol.z_bot(iobj,1)-d_bottom_above_v(k);
				end
				
				% Wenn ein oberhalb liegendes Objekt noch tiefer liegt, wird dieser Wert verwendet:
				% Das kann passieren, wenn Objekte, die z. T. weiter weg liegen, aufgrund z. B. des Geländes abgesenkt werden.
				obj_reg_union_ovcol.z_bot(iobj,1)	= min([obj_reg_union_ovcol.z_bot(iobj,1);z_bot_above_min]);
				% Stärken der aktuellen Schicht iobj addieren:
				k			= 1;
				colprio	= colorprio_above_v(k);
				colno		= find([PP_local.color.prio]==colprio,1);
				icolspec	= PP_local.color(colno).spec;
				obj_reg_union_ovcol.z_bot(iobj,1)	= obj_reg_union_ovcol.z_bot(iobj,1)+dzmin_above_v(k);
				obj_reg_union_ovcol.z_bot(iobj,1)	= obj_reg_union_ovcol.z_bot(iobj,1)-PP_local.colorspec(icolspec).min_thickness;
				obj_reg_union_ovcol.z_bot(iobj,1)	= obj_reg_union_ovcol.z_bot(iobj,1)-PP_local.colorspec(icolspec).d_bottom;
				
				% Wenn die Unterseite des Objekts dem Gelände folgt, muss der z-Wert der Unterseite auf einen max. Wert
				% begrenzt werden, der z_bot_above_min entspricht.
				% Oberhalb verlaufende Objekte, die auch dem Gelände folgen, müssen hier nicht berücksichtigt werden,
				% da die Absenkung schon berücksichtigt wurde.
				obj_reg_union_ovcol.zbotmax(iobj,1)	= z_bot_above_min_bv1;
				obj_reg_union_ovcol.zbotmax(iobj,1)	= obj_reg_union_ovcol.zbotmax(iobj,1)+dzmin_above_v(k);
				obj_reg_union_ovcol.zbotmax(iobj,1)	= obj_reg_union_ovcol.zbotmax(iobj,1)-PP_local.colorspec(icolspec).min_thickness;
				obj_reg_union_ovcol.zbotmax(iobj,1)	= obj_reg_union_ovcol.zbotmax(iobj,1)-PP_local.colorspec(icolspec).d_bottom;
				
				% Testausgaben:
				if testout_dzbot~=0
					fprintf(1,[...
						'iobj = %5.0f ,  colorprio_above_v                 = [%s]\n',...
						'                zmin_above_v                      = [%s]\n',...
						'                dzmin_above_v                     = [%s]\n',...
						'                min_thnss_above_v                 = [%s]\n',...
						'                d_bottom_above_v                  = [%s]\n',...
						'                obj_reg_union_ovcol.z_bot(iobj)   = %g\n',...
						'                obj_reg_union_ovcol.zbotmax(iobj) = %g\n'],...
						iobj,num2str(colorprio_above_v'),...
						num2str(zmin_above_v'),...
						num2str(dzmin_above_v'),...
						num2str(min_thnss_above_v'),...
						num2str(d_bottom_above_v'),...
						obj_reg_union_ovcol.z_bot(iobj),...
						obj_reg_union_ovcol.zbotmax(iobj,1));
				end
			end
		end
		
		% obj_reg die Werte zmin, z_bot und zbotmax zuweisen:
		for iobj1=length(obj_reg_union_ovcol.poly):-1:1
			if iobj2_v(iobj1)~=-9999
				obj_reg_union_ovcol.zmin(iobj1,1)		= obj_reg_union_ovcol.zmin(iobj2_v(iobj1),1);
				obj_reg_union_ovcol.z_bot(iobj1,1)		= obj_reg_union_ovcol.z_bot(iobj2_v(iobj1),1);
				obj_reg_union_ovcol.zbotmax(iobj1,1)	= obj_reg_union_ovcol.zbotmax(iobj2_v(iobj1),1);
				obj_reg.zmin(iobj1,1)						= obj_reg_union_ovcol.zmin(iobj2_v(iobj1),1);
				obj_reg.z_bot(iobj1,1)						= obj_reg_union_ovcol.z_bot(iobj2_v(iobj1),1);
				obj_reg.zbotmax(iobj1,1)					= obj_reg_union_ovcol.zbotmax(iobj2_v(iobj1),1);
			else
				obj_reg.zmin(iobj1,1)						= obj_reg_union_ovcol.zmin(iobj1,1);
				obj_reg.z_bot(iobj1,1)						= obj_reg_union_ovcol.z_bot(iobj1,1);
				obj_reg.zbotmax(iobj1,1)					= obj_reg_union_ovcol.zbotmax(iobj1,1);
			end
		end
		
	case 2
		% --------------------------------------------------------------------------------------------------------------
		% Zweite Methode: Die Unterseite wird nur soweit wie nötig abgesenkt.
		% --------------------------------------------------------------------------------------------------------------
		
		% Existierende Felder in obj_reg_union_ovcol:
		% obj_reg_union_ovcol.poly(iobj)
		% obj_reg_union_ovcol.colno(iobj)
		% obj_reg_union_ovcol.dz(iobj)
		% obj_reg_union_ovcol.zmin(iobj)			minimale Geländehöhe z auf der Fläche und dem Rand des Objekts (ohne dz)
		% obj_reg_union_ovcol.zmax(iobj)			maximale Geländehöhe z auf dem Rand des Objekts (ohne dz)
		% obj_reg_union_ovcol.objprio(iobj)
		% obj_reg_union_ovcol.colprio(iobj)
		% obj_reg_union_ovcol.srftype(iobj)
		%
		% neue Felder, die in obj_reg übernommen werden:
		% obj_reg_union_ovcol.z_bot(iobj)		Absenkung der Löcher für Teile anderer Farben gegenüber der Geländehöhe
		%													enthält bereits die Wert zmin und dz aller Teile oberhalb
		%													z_bot ist der ABSOLUTE z-Wert der Oberseite des unterhalb des
		%													Objekts iobj liegenden Teils.
		%													z_bot ist also um d_bottom kleiner als die Unterseite des Objekts iobj.
		% obj_reg_union_ovcol.zbotmax(iobj)		Maximal zulässiger Wert z_bot: Maximaler z-Wert der Unterseite des
		%													Objekts iobj abzüglich des Abstands zum darunter liegenden Teil.
		%													Der Wert zbotmax ist nur relevant, wenn die Unterseite dem Gelände folgt,
		%													(zum Beispiel bei non stand-alone Farben), aber dennoch andere Teile
		%													oberhalb eingesetzt werden sollen. In diesem Fall folgt die Unterseite
		%													nicht mehr dem Gelände, sondern wird entsprechend den oberhalb liegenden
		%													Teilen abgesenkt
		%
		% neue Felder, die nur in diesem Abschnitt benötigt werden:
		% obj_reg_union_ovcol.polybuffer(iobj)					obj_reg_union_ovcol.poly(iobj) verbreitert um d_side
		%																	zur Prüfung aufgegenseitige Überlappung
		% obj_reg_union_ovcol.poly_xmin_v(iobj)				Grenzen der Polygone für die Prüfung auf Überlappung
		% obj_reg_union_ovcol.poly_xmax_v(iobj)
		% obj_reg_union_ovcol.poly_ymin_v(iobj)
		% obj_reg_union_ovcol.poly_ymax_v(iobj)
		% obj_reg_union_ovcol.polybuffer_xmin_v(iobj)
		% obj_reg_union_ovcol.polybuffer_xmax_v(iobj)
		% obj_reg_union_ovcol.polybuffer_ymin_v(iobj)
		% obj_reg_union_ovcol.polybuffer_ymax_v(iobj)
		% obj_reg_union_ovcol.poly_top(iobj).ScInt			scatteredInterpolant Oberseite von .poly
		% obj_reg_union_ovcol.poly_bot(iobj).ScInt			scatteredInterpolant Unterseite von .poly
		% obj_reg_union_ovcol.polybuffer_top(iobj).ScInt	scatteredInterpolant Oberseite von .polybuffer
		% obj_reg_union_ovcol.polybuffer_bot(iobj).ScInt	scatteredInterpolant Unterseite von .polybuffer
		
		% Berechnung von:
		% obj_reg_union_ovcol.polybuffer(iobj)					obj_reg_union_ovcol.poly(iobj) verbreitert um d_side
		%																	zur Prüfung aufgegenseitige Überlappung
		for iobj=1:length(obj_reg_union_ovcol.poly)
			
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1		= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: Object bottom height (2): %g/%g',msg,iobj,length(obj_reg_union_ovcol.poly)));
				drawnow;
			end
			
			colno					= obj_reg_union_ovcol.colno(iobj);
			icolspec				= PP_local.color(colno).spec;
			d_side				= PP_local.colorspec(icolspec).d_side;
			if strcmp(GV.jointtype_bh,'miter')
				obj_reg_union_ovcol.polybuffer(iobj,1)	= ...
					polybuffer(obj_reg_union_ovcol.poly(iobj),d_side,'JointType',GV.jointtype_bh,...
					'MiterLimit',GV.miterlimit_bh);
			else
				obj_reg_union_ovcol.polybuffer(iobj,1)	= ...
					polybuffer(obj_reg_union_ovcol.poly(iobj),d_side,'JointType',GV.jointtype_bh);
			end
			
		end
		
		% Berechnung von:
		% obj_reg_union_ovcol.poly_xmin_v(iobj)		Grenzen der Polygone für die Prüfung auf Überlappung
		% obj_reg_union_ovcol.poly_xmax_v(iobj)
		% obj_reg_union_ovcol.poly_ymin_v(iobj)
		% obj_reg_union_ovcol.poly_ymax_v(iobj)
		% obj_reg_union_ovcol.polybuffer_xmin_v(iobj)
		% obj_reg_union_ovcol.polybuffer_xmax_v(iobj)
		% obj_reg_union_ovcol.polybuffer_ymin_v(iobj)
		% obj_reg_union_ovcol.polybuffer_ymax_v(iobj)
		obj_reg_union_ovcol.poly_xmin_v				= -1e10*ones(length(obj_reg_union_ovcol.poly),1);
		obj_reg_union_ovcol.poly_xmax_v				=  1e10*ones(length(obj_reg_union_ovcol.poly),1);
		obj_reg_union_ovcol.poly_ymin_v				= obj_reg_union_ovcol.poly_xmin_v;
		obj_reg_union_ovcol.poly_ymax_v				= obj_reg_union_ovcol.poly_xmax_v;
		obj_reg_union_ovcol.polybuffer_xmin_v		= -1e10*ones(length(obj_reg_union_ovcol.poly),1);
		obj_reg_union_ovcol.polybuffer_xmax_v		=  1e10*ones(length(obj_reg_union_ovcol.poly),1);
		obj_reg_union_ovcol.polybuffer_ymin_v		= obj_reg_union_ovcol.polybuffer_xmin_v;
		obj_reg_union_ovcol.polybuffer_ymax_v		= obj_reg_union_ovcol.polybuffer_xmax_v;
		for iobj=1:length(obj_reg_union_ovcol.poly)
			if numboundaries(obj_reg_union_ovcol.poly(iobj))>0
				[xlim,ylim]											= boundingbox(obj_reg_union_ovcol.poly(iobj));
				obj_reg_union_ovcol.poly_xmin_v(iobj,1)	= xlim(1,1);
				obj_reg_union_ovcol.poly_xmax_v(iobj,1)	= xlim(1,2);
				obj_reg_union_ovcol.poly_ymin_v(iobj,1)	= ylim(1,1);
				obj_reg_union_ovcol.poly_ymax_v(iobj,1)	= ylim(1,2);
			end
			if numboundaries(obj_reg_union_ovcol.polybuffer(iobj,1))>0
				[xlim,ylim]										= boundingbox(obj_reg_union_ovcol.polybuffer(iobj,1));
				obj_reg_union_ovcol.polybuffer_xmin_v(iobj,1)	= xlim(1,1);
				obj_reg_union_ovcol.polybuffer_xmax_v(iobj,1)	= xlim(1,2);
				obj_reg_union_ovcol.polybuffer_ymin_v(iobj,1)	= ylim(1,1);
				obj_reg_union_ovcol.polybuffer_ymax_v(iobj,1)	= ylim(1,2);
			end
		end
		
		% Geringfügige Überlappungen aufheben:
		% Wenn sich Kartenobjekte mit unterschiedlichen Farben nur geringfügig am Rand überlappen, führt dies zu einem
		% in der Regel unnötigen Übereinanderstapeln der Teile. In diesem Fall wird das untere Teil von dem oberen Teil
		% mit Berücksichtigung des seitlichen Abstands d_sied beschnitten, so dass die Teile nebeneinander eingesetzt
		% werden können.
		for iobj=1:length(obj_reg_union_ovcol.poly)
			obj_reg_subtrahend(iobj,1)				= polyshape();
		end
		for iobj_above=length(obj_reg_union_ovcol.poly):-1:1
			if numboundaries(obj_reg_union_ovcol.poly(iobj_above))>0
				colno_above					= obj_reg_union_ovcol.colno(iobj_above);
				icolspec_above				= PP_local.color(colno_above).spec;
				colorprio_above			= obj_reg_union_ovcol.colprio(iobj_above);
				d_bottom_above				= PP_local.colorspec(icolspec_above).d_bottom;
				d_side_above				= PP_local.colorspec(icolspec_above).d_side;
				for iobj_below=(iobj_above-1):-1:1
					colno_below					= obj_reg_union_ovcol.colno(iobj_below);
					icolspec_below				= PP_local.color(colno_below).spec;
					colorprio_below			= obj_reg_union_ovcol.colprio(iobj_below);
					min_thickness_below		= PP_local.colorspec(icolspec_below).min_thickness;
					d_bottom_below				= PP_local.colorspec(icolspec_below).d_bottom;
					
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						WAITBAR.t1		= clock;
						set(GV_H.text_waitbar,'String',sprintf(...
							'%s: Object bottom height (5): %g/%g %g/%g',msg,...
							length(obj_reg_union_ovcol.poly)-iobj_above+1,length(obj_reg_union_ovcol.poly),...
							(iobj_above-1)-iobj_below+1,iobj_above-1));
						drawnow;
					end
					
					if (colorprio_above>colorprio_below)&&(numboundaries(obj_reg_union_ovcol.poly(iobj_below))>0)
						% Das Objekt iobj_above liegt oberhalb von iobj_below:
						% Weil das obere Objekt in das untere eingesetzt wird, muss für das obere Objekt
						% das um d_side vergrößerte Polygon betrachtet werden!
						overlap_is_possible	= overlaps_boundingbox(tol_1,...
							obj_reg_union_ovcol.polybuffer_xmin_v(iobj_above,1),...		% x1min
							obj_reg_union_ovcol.polybuffer_xmax_v(iobj_above,1),...		% x1max
							obj_reg_union_ovcol.polybuffer_ymin_v(iobj_above,1),...		% y1min
							obj_reg_union_ovcol.polybuffer_ymax_v(iobj_above,1),...		% y1max
							obj_reg_union_ovcol.poly_xmin_v(iobj_below,1),...				% x2min
							obj_reg_union_ovcol.poly_xmax_v(iobj_below,1),...				% x2max
							obj_reg_union_ovcol.poly_ymin_v(iobj_below,1),...				% y2min
							obj_reg_union_ovcol.poly_ymax_v(iobj_below,1));					% y2max
						if overlap_is_possible
							if overlaps(...
									obj_reg_union_ovcol.polybuffer(iobj_above,1),...
									obj_reg_union_ovcol.poly(iobj_below))
								
								% Schnittfläche:
								poly_intersection_buffer		= intersect(...
									obj_reg_union_ovcol.polybuffer(iobj_above,1),...
									obj_reg_union_ovcol.poly(iobj_below),...
									'KeepCollinearPoints',true);
								
								% Kontrollieren, ob die Schnittfläche so schmal ist, dass dies zu einer unnötigen Überlappung führt:
								width_intersection_min		= d_side_above/4;
								poly_intersection_reduced	= polybuffer(poly_intersection_buffer,-width_intersection_min/2,...
									'JointType','miter');
								if numboundaries(poly_intersection_reduced)==0
									% Überlappung aufheben:
									% Die Schnittfläche ist schmaler als width_intersection_min:
									% Das kann zum Beispiel passieren, wenn eine Fläche mit einer "Cutting line" zerschnitten wird,
									% deren Breite identisch mit d_side ist. Aufgrund von Ungenauigkeiten zum Beispiel bei der
									% Reduzierung der Auflösung der Polygone kann es dann zu unerwünschten Überlappungen kommen.
									
									% Schnittfläche neu berechnen für eine sichere Subtraktion:
									poly_intersection_extended	= intersect(...
										polybuffer(obj_reg_union_ovcol.polybuffer(iobj_above,1),tol_1,'JointType','miter'),...
										obj_reg_union_ovcol.poly(iobj_below),...
										'KeepCollinearPoints',true);
									poly_intersection_extended	= polybuffer(poly_intersection_extended,tol_1,'JointType','miter');
									% Erweiterte Schnittflächen sammeln:
									obj_reg_subtrahend(iobj_below)	= union(...
										obj_reg_subtrahend(iobj_below),...
										poly_intersection_extended);
									% Am Ende dieses Abschnitts müssen alle Polygone obj_reg_subtrahend von
									% - obj_reg.poly und
									% - obj_reg_union_ovcol.poly
									% subtrahiert werden, um die Überlappungen aufzuheben.
									
									if testplot_local||any(iobj==testplot_iobj_v)
										hf			= figure(89472962);
										clf(hf,'reset');
										set(hf,'Tag','maplab3d_figure');
										set(hf,'Name','xyz');
										set(hf,'NumberTitle','off');
										ha=axes;
										hold(ha,'on');
										axis(ha,'equal');
										facealpha	= 0.2;			% Transparenz der Oberflächen		0.2
										edgealpha	= 0.2;			% Transparenz der Kanten			0.2
										plot(ha,obj_reg_union_ovcol.poly(iobj_below));
										plot(ha,obj_reg_union_ovcol.poly(iobj_above));
										plot(ha,poly_intersection_buffer);
										plot(ha,poly_intersection_extended);
										% Test:
										if (colorprio_above==4)&&(colorprio_below==3)
											setbreakpoint=1;
										end
									end
									
								end
							end
						end
					end
				end
			end
		end
		% Überlappungen aufheben:
		for iobj=1:length(obj_reg_union_ovcol.poly)
			if numboundaries(obj_reg_subtrahend(iobj))>0
				obj_reg.poly(iobj)					= subtract(obj_reg.poly(iobj),obj_reg_subtrahend(iobj));
				obj_reg_union_ovcol.poly(iobj)	= subtract(obj_reg_union_ovcol.poly(iobj),obj_reg_subtrahend(iobj));
			end
		end
		
		% Grenzen der Polygone für die Prüfung auf Überlappung neu berechnen:
		obj_reg_union_ovcol.poly_xmin_v				= -1e10*ones(length(obj_reg_union_ovcol.poly),1);
		obj_reg_union_ovcol.poly_xmax_v				=  1e10*ones(length(obj_reg_union_ovcol.poly),1);
		obj_reg_union_ovcol.poly_ymin_v				= obj_reg_union_ovcol.poly_xmin_v;
		obj_reg_union_ovcol.poly_ymax_v				= obj_reg_union_ovcol.poly_xmax_v;
		obj_reg_union_ovcol.polybuffer_xmin_v		= -1e10*ones(length(obj_reg_union_ovcol.poly),1);
		obj_reg_union_ovcol.polybuffer_xmax_v		=  1e10*ones(length(obj_reg_union_ovcol.poly),1);
		obj_reg_union_ovcol.polybuffer_ymin_v		= obj_reg_union_ovcol.polybuffer_xmin_v;
		obj_reg_union_ovcol.polybuffer_ymax_v		= obj_reg_union_ovcol.polybuffer_xmax_v;
		for iobj=1:length(obj_reg_union_ovcol.poly)
			if numboundaries(obj_reg_union_ovcol.poly(iobj))>0
				[xlim,ylim]											= boundingbox(obj_reg_union_ovcol.poly(iobj));
				obj_reg_union_ovcol.poly_xmin_v(iobj,1)	= xlim(1,1);
				obj_reg_union_ovcol.poly_xmax_v(iobj,1)	= xlim(1,2);
				obj_reg_union_ovcol.poly_ymin_v(iobj,1)	= ylim(1,1);
				obj_reg_union_ovcol.poly_ymax_v(iobj,1)	= ylim(1,2);
			end
			if numboundaries(obj_reg_union_ovcol.polybuffer(iobj,1))>0
				[xlim,ylim]										= boundingbox(obj_reg_union_ovcol.polybuffer(iobj,1));
				obj_reg_union_ovcol.polybuffer_xmin_v(iobj,1)	= xlim(1,1);
				obj_reg_union_ovcol.polybuffer_xmax_v(iobj,1)	= xlim(1,2);
				obj_reg_union_ovcol.polybuffer_ymin_v(iobj,1)	= ylim(1,1);
				obj_reg_union_ovcol.polybuffer_ymax_v(iobj,1)	= ylim(1,2);
			end
		end
		
		% Jedem einzelnen vertex der Polygone die folgenden Werte zuweisen:
		% (Die Reihenfolge ist hier egal, weil noch keine Überlappung betrachtet wird.)
		% - die Höhen z der Oberseiten:  poly_z_top = Geländehöhe + dz
		% - die Höhen z der Unterseiten: poly_z_bot = Geländehöhe + min(0,dz) - min_thickness
		%   Damit bei einem positiven Wert dz die Lochtiefe nicht kleiner als min_thickness ist,
		%   muss hier dz maximal 0 sein.
		%   Der Abstand d_bottom zum darunterliegenden Teil wird hier noch nicht berücksichtigt.
		% Bem.:
		% Wenn ein zusammenhängendes Objekt in obj_reg_union_ovcol aus mehreren einzelnen Objekten besteht mit
		% unterschiedlichen Werten dz, dann enthält obj_reg_union_ovcol.dz den kleinsten Wert dz.
		%
		% Berechnung von:
		% obj_reg_union_ovcol.poly_top(iobj).ScInt			scatteredInterpolant: Oberseite von .poly
		% obj_reg_union_ovcol.poly_bot(iobj).ScInt			scatteredInterpolant: Unterseite von .poly
		% obj_reg_union_ovcol.polybuffer_top(iobj).ScInt	scatteredInterpolant: Oberseite von .polybuffer
		% obj_reg_union_ovcol.polybuffer_bot(iobj).ScInt	scatteredInterpolant: Unterseite von .polybuffer
		ifs					= 1;											% User query points of the tile base
		for iobj=1:length(obj_reg_union_ovcol.poly)
			colno					= obj_reg_union_ovcol.colno(iobj);
			icolspec				= PP_local.color(colno).spec;
			min_thickness		= PP_local.colorspec(icolspec).min_thickness;
			
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1		= clock;
				set(GV_H.text_waitbar,'String',sprintf(...
					'%s: Object bottom height (3): %g/%g',msg,iobj,length(obj_reg_union_ovcol.poly)));
				drawnow;
			end
			
			% ScatteredInterpolant für die Interpolation der Höhendaten berechnen:
			% Felder poly_top und poly_bot:
			
			% Stützstellen xy von obj_reg_union_ovcol.poly auf dem Rand und innerhalb:
			TFin					= inpolygon(...							% faster than isinterior
				ELE_local.elefiltset(ifs,1).xm_mm,...					% query points
				ELE_local.elefiltset(ifs,1).ym_mm,...
				obj_reg_union_ovcol.poly(iobj,1).Vertices(:,1),...	% polygon area
				obj_reg_union_ovcol.poly(iobj,1).Vertices(:,2));
			size_x				= size(ELE_local.elefiltset(ifs,1).xm_mm(TFin));
			size_x_reshape		= [size_x(1)*size_x(2) 1];
			poly_incr_res		= changeresolution_poly(obj_reg_union_ovcol.poly(iobj,1),...
				PP_local.general.dxy_ele_mm/2,...		% dmax
				[],...		% dmin
				[]);			% nmin
			xy						= [poly_incr_res.Vertices;[...
				reshape(ELE_local.elefiltset(ifs,1).xm_mm(TFin),size_x_reshape) ...
				reshape(ELE_local.elefiltset(ifs,1).ym_mm(TFin),size_x_reshape)]];
			xy						= unique(xy,'rows');
			[r_delete,~]		= find(isnan(xy));
			r_delete				= unique(r_delete);
			xy(r_delete,:)		= [];
			
			% Höhen z der Oberseiten von obj_reg_union_ovcol.poly:
			dz						= obj_reg_union_ovcol.dz(iobj,1);
			xyz	=  [xy ...
				dz+interp_ele(...
				xy(:,1),...														% query points x
				xy(:,2),...														% query points y
				ELE_local,...													% elevation structure
				colno,...														% color numbers
				GV.legend_z_topside_bgd,...								% legend background z-value
				poly_legbgd,...												% legend background polygon
				'interp2')];													% interpolation method
			obj_reg_union_ovcol.poly_top(iobj,1).ScInt			= scatteredInterpolant(xyz(:,1),xyz(:,2),xyz(:,3));
			obj_reg_union_ovcol.poly_top(iobj,1).ScInt.Method					= 'linear';
			obj_reg_union_ovcol.poly_top(iobj,1).ScInt.ExtrapolationMethod	= 'nearest';
			% Höhen z der Unterseiten von obj_reg_union_ovcol.poly:
			dz						= min(0,obj_reg_union_ovcol.dz(iobj,1));
			xyz	=  [xy ...
				dz-min_thickness+interp_ele(...
				xy(:,1),...														% query points x
				xy(:,2),...														% query points y
				ELE_local,...													% elevation structure
				colno,...														% color numbers
				GV.legend_z_topside_bgd,...								% legend background z-value
				poly_legbgd,...												% legend background polygon
				'interp2')];													% interpolation method
			obj_reg_union_ovcol.poly_bot(iobj,1).ScInt			= scatteredInterpolant(xyz(:,1),xyz(:,2),xyz(:,3));
			obj_reg_union_ovcol.poly_bot(iobj,1).ScInt.Method					= 'linear';
			obj_reg_union_ovcol.poly_bot(iobj,1).ScInt.ExtrapolationMethod	= 'nearest';
			
			% ScatteredInterpolant für die Interpolation der Höhendaten berechnen:
			% Felder polybuffer_top und polybuffer_bot:
			
			% Stützstellen xy von obj_reg_union_ovcol.polybuffer auf dem Rand und innerhalb:
			xy_poly				= xy;											% auch die vorherigen Stützstellen einfügen
			TFin					= inpolygon(...							% faster than isinterior
				ELE_local.elefiltset(ifs,1).xm_mm,...					% query points
				ELE_local.elefiltset(ifs,1).ym_mm,...
				obj_reg_union_ovcol.polybuffer(iobj,1).Vertices(:,1),...	% polygon area
				obj_reg_union_ovcol.polybuffer(iobj,1).Vertices(:,2));
			size_x				= size(ELE_local.elefiltset(ifs,1).xm_mm(TFin));
			size_x_reshape		= [size_x(1)*size_x(2) 1];
			poly_incr_res		= changeresolution_poly(obj_reg_union_ovcol.polybuffer(iobj,1),...
				PP_local.general.dxy_ele_mm/2,...		% dmax
				[],...		% dmin
				[]);			% nmin
			xy						= [...
				xy_poly;...
				poly_incr_res.Vertices;[...
				reshape(ELE_local.elefiltset(ifs,1).xm_mm(TFin),size_x_reshape) ...
				reshape(ELE_local.elefiltset(ifs,1).ym_mm(TFin),size_x_reshape)]];
			xy						= unique(xy,'rows');
			[r_delete,~]		= find(isnan(xy));
			r_delete				= unique(r_delete);
			xy(r_delete,:)		= [];
			
			% Höhen z der Oberseiten von obj_reg_union_ovcol.polybuffer:
			dz						= obj_reg_union_ovcol.dz(iobj,1);
			xyz	=  [xy ...
				dz+interp_ele(...
				xy(:,1),...														% query points x
				xy(:,2),...														% query points y
				ELE_local,...													% elevation structure
				colno,...														% color numbers
				GV.legend_z_topside_bgd,...								% legend background z-value
				poly_legbgd,...												% legend background polygon
				'interp2')];													% interpolation method
			obj_reg_union_ovcol.polybuffer_top(iobj,1).ScInt		= scatteredInterpolant(xyz(:,1),xyz(:,2),xyz(:,3));
			obj_reg_union_ovcol.polybuffer_top(iobj,1).ScInt.Method						= 'linear';
			obj_reg_union_ovcol.polybuffer_top(iobj,1).ScInt.ExtrapolationMethod	= 'nearest';
			% Höhen z der Unterseiten von obj_reg_union_ovcol.polybuffer:
			dz						= min(0,obj_reg_union_ovcol.dz(iobj,1));
			xyz	=  [xy ...
				dz-min_thickness+interp_ele(...
				xy(:,1),...														% query points x
				xy(:,2),...														% query points y
				ELE_local,...													% elevation structure
				colno,...														% color numbers
				GV.legend_z_topside_bgd,...								% legend background z-value
				poly_legbgd,...												% legend background polygon
				'interp2')];													% interpolation method
			obj_reg_union_ovcol.polybuffer_bot(iobj,1).ScInt		= scatteredInterpolant(xyz(:,1),xyz(:,2),xyz(:,3));
			obj_reg_union_ovcol.polybuffer_bot(iobj,1).ScInt.Method						= 'linear';
			obj_reg_union_ovcol.polybuffer_bot(iobj,1).ScInt.ExtrapolationMethod	= 'nearest';
			
			if testplot_local||any(iobj==testplot_iobj_v)
				if numboundaries(obj_reg_union_ovcol.poly(iobj,1))>0
					hf			= figure(89472963);
					clf(hf,'reset');
					set(hf,'Tag','maplab3d_figure');
					set(hf,'Name','xyz');
					set(hf,'NumberTitle','off');
					ha=axes;
					hold(ha,'on');
					axis(ha,'equal');
					facealpha	= 0.2;			% Transparenz der Oberflächen		0.2
					edgealpha	= 0.2;			% Transparenz der Kanten			0.2
					plot3(ha,...
						obj_reg_union_ovcol.poly_top(iobj,1).ScInt.Points(:,1),...
						obj_reg_union_ovcol.poly_top(iobj,1).ScInt.Points(:,2),...
						obj_reg_union_ovcol.poly_top(iobj,1).ScInt.Values(:,1),'+r');
					plot3(ha,...
						obj_reg_union_ovcol.poly_bot(iobj,1).ScInt.Points(:,1),...
						obj_reg_union_ovcol.poly_bot(iobj,1).ScInt.Points(:,2),...
						obj_reg_union_ovcol.poly_bot(iobj,1).ScInt.Values(:,1),'+r');
					plot3(ha,...
						obj_reg_union_ovcol.polybuffer_top(iobj,1).ScInt.Points(:,1),...
						obj_reg_union_ovcol.polybuffer_top(iobj,1).ScInt.Points(:,2),...
						obj_reg_union_ovcol.polybuffer_top(iobj,1).ScInt.Values(:,1),'.b');
					plot3(ha,...
						obj_reg_union_ovcol.polybuffer_bot(iobj,1).ScInt.Points(:,1),...
						obj_reg_union_ovcol.polybuffer_bot(iobj,1).ScInt.Points(:,2),...
						obj_reg_union_ovcol.polybuffer_bot(iobj,1).ScInt.Values(:,1),'.g');
					
					xy		= obj_reg_union_ovcol.polybuffer_bot(iobj,1).ScInt.Points;
					z		= obj_reg_union_ovcol.poly_bot(iobj,1).ScInt(xy(:,1),xy(:,2));
					TR		= delaunayTriangulation(xy);
					CL		= TR.ConnectivityList;
					C						= incenter(TR);
					TFin					= inpolygon(...							% faster than isinterior
						C(:,1),...														% query points
						C(:,2),...
						obj_reg_union_ovcol.polybuffer(iobj,1).Vertices(:,1),...			% polygon area
						obj_reg_union_ovcol.polybuffer(iobj,1).Vertices(:,2));
					CL(~TFin,:)			= [];
					TR		= triangulation(CL,TR.Points);
					C						= incenter(TR);
					TFin					= inpolygon(...							% faster than isinterior
						C(:,1),...														% query points
						C(:,2),...
						obj_reg_union_ovcol.poly(iobj,1).Vertices(:,1),...					% polygon area
						obj_reg_union_ovcol.poly(iobj,1).Vertices(:,2));
					F	= [CL(TFin,1) CL(TFin,2) CL(TFin,3) CL(TFin,1)];
					h3=patch(ha,'faces',F,'vertices',[xy z],...
						'EdgeColor',[0 0 0],'FaceColor',[0 0 0],'FaceAlpha',0.2,'EdgeAlpha',edgealpha,...
						'DisplayName','Intersection area');
					F	= [CL(~TFin,1) CL(~TFin,2) CL(~TFin,3) CL(~TFin,1)];
					h3=patch(ha,'faces',F,'vertices',[xy z],...
						'EdgeColor',[0 0 0],'FaceColor',[0 0 0],'FaceAlpha',0.1,'EdgeAlpha',edgealpha,...
						'DisplayName','Intersection area');
					view(ha,3)
					drawnow;
					if iobj==20
						setbreakpoint=1;
					end
					setbreakpoint=1;
				end
			end
			
		end
		
		% Feld .zbotmax initialisieren (.z_bot wird weiter unten zugewiesen):
		for iobj=1:length(obj_reg_union_ovcol.poly)
			colno											= obj_reg_union_ovcol.colno(iobj);
			icolspec										= PP_local.color(colno).spec;
			d_bottom										= PP_local.colorspec(icolspec).d_bottom;
			if numboundaries(obj_reg_union_ovcol.poly(iobj,1))>0
				obj_reg_union_ovcol.zbotmax(iobj,1)	= max(obj_reg_union_ovcol.poly_bot(iobj,1).ScInt.Values)-d_bottom;
			end
		end
		
		% Unterseiten von ÜBERlagerten Teilen absenken, damit die Lochtiefe nicht kleiner als min_thickness ist:
		% Bei Überlappung die Unterseite des überlagerten Teils auf den z-Wert der Oberseite des unterlagerten Teil
		% abzüglich min_thickness absenken. Das berücksichtigt den Fall, dass die Oberseite des unterlagerten Teils
		% gegenüber der Geländehöhe abgesenkt ist (dz<0).
		for iobj_above=length(obj_reg_union_ovcol.poly):-1:1
			if numboundaries(obj_reg_union_ovcol.poly(iobj_above))>0
				colno_above					= obj_reg_union_ovcol.colno(iobj_above);
				icolspec_above				= PP_local.color(colno_above).spec;
				colorprio_above			= obj_reg_union_ovcol.colprio(iobj_above);
				d_bottom_above				= PP_local.colorspec(icolspec_above).d_bottom;
				for iobj_below=(iobj_above-1):-1:1
					colorprio_below			= obj_reg_union_ovcol.colprio(iobj_below);
					
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						WAITBAR.t1		= clock;
						set(GV_H.text_waitbar,'String',sprintf(...
							'%s: Object bottom height (4): %g/%g %g/%g',msg,...
							length(obj_reg_union_ovcol.poly)-iobj_above+1,length(obj_reg_union_ovcol.poly),...
							(iobj_above-1)-iobj_below+1,iobj_above-1));
						drawnow;
					end
					
					if (colorprio_above>colorprio_below)&&(numboundaries(obj_reg_union_ovcol.poly(iobj_below))>0)
						% Das Objekt iobj_above liegt oberhalb von iobj_below:
						% Weil das obere Objekt in das untere eingesetzt wird, muss für das obere Objekt
						% das um d_side vergrößerte Polygon betrachtet werden!
						overlap_is_possible	= overlaps_boundingbox(tol_1,...
							obj_reg_union_ovcol.polybuffer_xmin_v(iobj_above,1),...		% x1min
							obj_reg_union_ovcol.polybuffer_xmax_v(iobj_above,1),...		% x1max
							obj_reg_union_ovcol.polybuffer_ymin_v(iobj_above,1),...		% y1min
							obj_reg_union_ovcol.polybuffer_ymax_v(iobj_above,1),...		% y1max
							obj_reg_union_ovcol.poly_xmin_v(iobj_below,1),...				% x2min
							obj_reg_union_ovcol.poly_xmax_v(iobj_below,1),...				% x2max
							obj_reg_union_ovcol.poly_ymin_v(iobj_below,1),...				% y2min
							obj_reg_union_ovcol.poly_ymax_v(iobj_below,1));					% y2max
						if overlap_is_possible
							if overlaps(...
									obj_reg_union_ovcol.polybuffer(iobj_above,1),...
									obj_reg_union_ovcol.poly(iobj_below))
								% Die Differenz z_top_below-z_bot_above muss an jeder Stelle mindestens min_thickness_above
								% betragen, damit das obere Teil ausreichend Halt hat:
								% Die z-Werte der Unterseite des Objekts oberhalb an diesen Stellen ggf. entsprechend absenken!
								
								% Schnittfläche:
								poly_intersection				= intersect(...
									obj_reg_union_ovcol.polybuffer(iobj_above,1),...
									obj_reg_union_ovcol.poly(iobj_below),...
									'KeepCollinearPoints',true);
								
								% Auflösung erhöhen:
								poly_intersection				= changeresolution_poly(poly_intersection,...
									PP_local.general.dxy_ele_mm/4,...		% dmax
									[],...		% dmin
									[]);			% nmin
								
								% Stützstellen xy innerhalb der Schnittfläche:
								TFin					= inpolygon(...							% faster than isinterior
									ELE_local.elefiltset(ifs,1).xm_mm,...					% query points
									ELE_local.elefiltset(ifs,1).ym_mm,...
									poly_intersection.Vertices(:,1),...						% polygon area
									poly_intersection.Vertices(:,2));
								size_x				= size(ELE_local.elefiltset(ifs,1).xm_mm(TFin));
								size_x_reshape		= [size_x(1)*size_x(2) 1];
								
								% Stützstellen xy zusammensetzen und doppelte Punkte löschen:
								xy_intersection	= [...
									poly_intersection.Vertices;[...
									reshape(ELE_local.elefiltset(ifs,1).xm_mm(TFin),size_x_reshape) ...
									reshape(ELE_local.elefiltset(ifs,1).ym_mm(TFin),size_x_reshape)]];
								xy_intersection	= unique(xy_intersection,'rows');
								[r_delete,~]		= find(isnan(xy_intersection));
								r_delete				= unique(r_delete);
								xy_intersection(r_delete,:)		= [];
								
								% z-Werte der Oberseite des unterhalb liegenden Polygons auf der Schnittfläche:
								z_intersect_top_below_v		= obj_reg_union_ovcol.poly_top(iobj_below,1).ScInt(...
									xy_intersection(:,1),...
									xy_intersection(:,2));
								
								% Alle z-Werte der Unterseite des Objekts iobj_above auf den folgenden Wert begrenzen:
								[zmax_bot_above,~]		= min(z_intersect_top_below_v);
								
								% obj_reg_union_ovcol.zbotmax entsprechend verringern:
								obj_reg_union_ovcol.zbotmax(iobj_above)	= min(...
									obj_reg_union_ovcol.zbotmax(iobj_above),...
									zmax_bot_above-d_bottom_above);
								
							end
						end
					end
				end
				
				% Update the bottom side z-values in the fields .poly_bot and .polybuffer_bot:
				
				% Change obj_reg_union_ovcol.poly_bot(iobj,1).ScInt:
				xyz													= [...
					obj_reg_union_ovcol.poly_bot(iobj_above,1).ScInt.Points(:,1) ...
					obj_reg_union_ovcol.poly_bot(iobj_above,1).ScInt.Points(:,2) ...
					obj_reg_union_ovcol.poly_bot(iobj_above,1).ScInt.Values(:,1)];
				z_greater_zbotmax_poly_bot						= (xyz(:,3)>(obj_reg_union_ovcol.zbotmax(iobj_above)+d_bottom_above));
				xyz(z_greater_zbotmax_poly_bot,3)			= obj_reg_union_ovcol.zbotmax(iobj_above)+d_bottom_above;
				obj_reg_union_ovcol.poly_bot(iobj_above,1).ScInt	= scatteredInterpolant(xyz(:,1),xyz(:,2),xyz(:,3));
				obj_reg_union_ovcol.poly_bot(iobj_above,1).ScInt.Method					= 'linear';
				obj_reg_union_ovcol.poly_bot(iobj_above,1).ScInt.ExtrapolationMethod	= 'nearest';
				
				% Change obj_reg_union_ovcol.polybuffer_bot(iobj,1).ScInt:
				xyz													= [...
					obj_reg_union_ovcol.polybuffer_bot(iobj_above,1).ScInt.Points(:,1) ...
					obj_reg_union_ovcol.polybuffer_bot(iobj_above,1).ScInt.Points(:,2) ...
					obj_reg_union_ovcol.polybuffer_bot(iobj_above,1).ScInt.Values(:,1)];
				z_greater_zbotmax_polybuffer_bot				= (xyz(:,3)>(obj_reg_union_ovcol.zbotmax(iobj_above)+d_bottom_above));
				xyz(z_greater_zbotmax_polybuffer_bot,3)	= obj_reg_union_ovcol.zbotmax(iobj_above)+d_bottom_above;
				obj_reg_union_ovcol.polybuffer_bot(iobj_above,1).ScInt	= scatteredInterpolant(xyz(:,1),xyz(:,2),xyz(:,3));
				obj_reg_union_ovcol.polybuffer_bot(iobj_above,1).ScInt.Method					= 'linear';
				obj_reg_union_ovcol.polybuffer_bot(iobj_above,1).ScInt.ExtrapolationMethod	= 'nearest';
				
			end
		end
		
		% Unterseiten von UNTERlagerten Teilen absenken, damit alle überlagerten Teile hineinpassen:
		for iobj_below=length(obj_reg_union_ovcol.poly):-1:1
			% Beginnend mit der höchsten Farbpriorität: Alle Objekte oberhalb des Objekte iobj_below auf Überlappung prüfen:
			if numboundaries(obj_reg_union_ovcol.poly(iobj_below))>0
				colno_below					= obj_reg_union_ovcol.colno(iobj_below);
				icolspec_below				= PP_local.color(colno_below).spec;
				colorprio_below			= obj_reg_union_ovcol.colprio(iobj_below);
				min_thickness_below		= PP_local.colorspec(icolspec_below).min_thickness;
				d_bottom_below				= PP_local.colorspec(icolspec_below).d_bottom;
				for iobj_above=length(obj_reg_union_ovcol.poly):-1:(iobj_below+1)
					colno_above					= obj_reg_union_ovcol.colno(iobj_above);
					icolspec_above				= PP_local.color(colno_above).spec;
					colorprio_above			= obj_reg_union_ovcol.colprio(iobj_above);
					d_bottom_above				= PP_local.colorspec(icolspec_above).d_bottom;
					
					% Waitbar:
					if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
						WAITBAR.t1		= clock;
						set(GV_H.text_waitbar,'String',sprintf(...
							'%s: Object bottom height (5): %g/%g %g/%g',msg,...
							length(obj_reg_union_ovcol.poly)-iobj_above+1,length(obj_reg_union_ovcol.poly),...
							(iobj_above-1)-iobj_below+1,iobj_above-1));
						drawnow;
					end
					
					if (colorprio_above>colorprio_below)&&(numboundaries(obj_reg_union_ovcol.poly(iobj_above))>0)
						% Das Objekt iobj_above liegt oberhalb von iobj_below:
						% Weil das obere Objekt in das untere eingesetzt wird, muss für das obere Objekt
						% das um d_side vergrößerte Polygon betrachtet werden!
						overlap_is_possible	= overlaps_boundingbox(tol_1,...
							obj_reg_union_ovcol.polybuffer_xmin_v(iobj_above,1),...		% x1min
							obj_reg_union_ovcol.polybuffer_xmax_v(iobj_above,1),...		% x1max
							obj_reg_union_ovcol.polybuffer_ymin_v(iobj_above,1),...		% y1min
							obj_reg_union_ovcol.polybuffer_ymax_v(iobj_above,1),...		% y1max
							obj_reg_union_ovcol.poly_xmin_v(iobj_below,1),...				% x2min
							obj_reg_union_ovcol.poly_xmax_v(iobj_below,1),...				% x2max
							obj_reg_union_ovcol.poly_ymin_v(iobj_below,1),...				% y2min
							obj_reg_union_ovcol.poly_ymax_v(iobj_below,1));					% y2max
						if overlap_is_possible
							if overlaps(...
									obj_reg_union_ovcol.polybuffer(iobj_above,1),...
									obj_reg_union_ovcol.poly(iobj_below))
								
								% Die Objekte überlappen sich:
								% - Im Bereich der Überlappung die Unterseite des oberhalb liegenden Teils berechnen:
								%   zmin_intersect_bot_above
								% - Alle z-Werte in poly_bot(iobj_below)) werden abgesenkt auf den Wert:
								%   zmax_bot_below = zmin_intersect_bot_above - d_bottom_above - min_thickness_below
								% - zbotmax neu zuweisen:
								%   zbotmax(iobj_below) = min( zbotmax(iobj_below) , zmax_bot_below-d_bottom_below )
								
								% Unterseite poly_bot(iobj_below):
								% vorher:                             nach Absenkung durch ein überlagertes Teil:
								%
								%                                                            ~     | .poly_bot(iobj_above)
								%               terrain \                          terrain \ |     | bottom enlarged by d_side:
								%                        \                                  \| ~   | .polybuffer_bot(iobj_above)
								%                         \                                  \ |   v
								%                          \                                 |\|     | .poly_top(iobj_below)
								% .poly_bot(iobj_below) \   \                                | \     v
								%                        \   \                               | |\  ~
								%                         \   \               d_side_above   | | \ |
								%                          \   \              -------------->|-|< \| ~    ^
								%                           \   \                            + |   \ |    | z
								%                            \   \                           | |   |\|    |
								%                             \   \                          | |   | \    |
								%                       ------ \   +                         | |   | |\   |
								%                        ^      \   \                        | +   | | \  |
								%    min_thickness_below |       \   \                       |  \  | |  \ |
								%    (dz>=0)             v        \                          |   \ | |    |
								%                       ---------- +                         |    \| |    |
								%                                   \                    ----|     + +    + zmin_intersect_bot_above
								%                                    \                    ^  |       |    |
								%                                          d_bottom_above |  |       |    |
								%                                                         v  |       |    |
								%                                                        ----+-------+    |
								%                                                         ^               |
								%                                     min_thickness_below |               |
								%                   .poly_bot(iobj_below)                 v               |
								%                  ------------------------------------------------------ + zmax_bot_below =
								%                 /                                       ^               | highest level of
								%                /                         d_bottom_below |               | .poly_bot(iobj_below)
								%               /                                         v               |
								%              /                                         ---------------- + .zbotmax(iobj_below)
								%             /                                                           |
								%    --------- lowest level of .poly_bot(iobj_below)                      |
								%       ^                                                                 |
								%       | d_bottom_below                                                  |
								%       v                                                                 |
								%    ---------                                                            + .z_bot(iobj_below)
								%                                                                         |
								
								% Schnittfläche:
								poly_intersection				= intersect(...
									obj_reg_union_ovcol.poly(iobj_above,1),...
									obj_reg_union_ovcol.poly(iobj_below),...
									'KeepCollinearPoints',true);
								xi									= zeros(0,1);
								yi									= zeros(0,1);
								intersection_buffered		= false;
								if numboundaries(poly_intersection)==0
									intersection_buffered		= true;
									poly_intersection				= intersect(...
										obj_reg_union_ovcol.polybuffer(iobj_above,1),...
										obj_reg_union_ovcol.poly(iobj_below),...
										'KeepCollinearPoints',true);
									% Auch die Schnittpunkte der beiden Polygone hinzufügen, für eine sichere Interpolation der Höhen:
									[xi,yi]				= polyxpoly(...
										obj_reg_union_ovcol.polybuffer(iobj_above,1).Vertices(:,1),...		% x1
										obj_reg_union_ovcol.polybuffer(iobj_above,1).Vertices(:,2),...		% x2
										obj_reg_union_ovcol.poly(iobj_below).Vertices(:,1),...				% y1
										obj_reg_union_ovcol.poly(iobj_below).Vertices(:,2));					% y2
								end
								
								% Auflösung erhöhen:
								poly_intersection				= changeresolution_poly(poly_intersection,...
									PP_local.general.dxy_ele_mm/4,...		% dmax
									[],...		% dmin
									[]);			% nmin
								
								% Stützstellen xy innerhalb der Schnittfläche:
								TFin					= inpolygon(...							% faster than isinterior
									ELE_local.elefiltset(ifs,1).xm_mm,...					% query points
									ELE_local.elefiltset(ifs,1).ym_mm,...
									poly_intersection.Vertices(:,1),...						% polygon area
									poly_intersection.Vertices(:,2));
								size_x				= size(ELE_local.elefiltset(ifs,1).xm_mm(TFin));
								size_x_reshape		= [size_x(1)*size_x(2) 1];
								
								% Stützstellen xy zusammensetzen und doppelte Punkte löschen:
								xy_intersection	= [...
									poly_intersection.Vertices;...
									[xi yi];[...
									reshape(ELE_local.elefiltset(ifs,1).xm_mm(TFin),size_x_reshape) ...
									reshape(ELE_local.elefiltset(ifs,1).ym_mm(TFin),size_x_reshape)]];
								xy_intersection	= unique(xy_intersection,'rows');
								[r_delete,~]		= find(isnan(xy_intersection));
								r_delete				= unique(r_delete);
								xy_intersection(r_delete,:)		= [];
								
								% z-Werte der Unterseite des oberhalb liegenden Polygons auf der Schnittfläche:
								if ~intersection_buffered
									z_intersect_bot_above_v		= obj_reg_union_ovcol.poly_bot(iobj_above,1).ScInt(...
										xy_intersection(:,1),...
										xy_intersection(:,2));
								else
									z_intersect_bot_above_v		= obj_reg_union_ovcol.polybuffer_bot(iobj_above,1).ScInt(...
										xy_intersection(:,1),...
										xy_intersection(:,2));
								end
								
								% Alle z-Werte der Unterseite des Objekts iobj_below auf den Wert zmax_bot_below begrenzen:
								[zmin_intersect_bot_above,i_zmin_intersect_bot_above]		= min(z_intersect_bot_above_v);
								zmax_bot_below		= zmin_intersect_bot_above-d_bottom_above-min_thickness_below;
								
								% obj_reg_union_ovcol.zbotmax zusätzlich verringern um d_bottom_below:
								obj_reg_union_ovcol.zbotmax(iobj_below)	= min(...
									obj_reg_union_ovcol.zbotmax(iobj_below),...
									zmax_bot_below-d_bottom_below);
								
								if testplot_local||any(iobj_below==testplot_iobj_v)
									hf			= figure(89472964);
									clf(hf,'reset');
									set(hf,'Tag','maplab3d_figure');
									set(hf,'Name','xyz');
									set(hf,'NumberTitle','off');
									ha=axes;
									hold(ha,'on');
									axis(ha,'equal');
									facealpha	= 0.2;			% Transparenz der Oberflächen		0.2
									edgealpha	= 0.2;			% Transparenz der Kanten			0.2
									% Object above:
									xyz	= [...
										obj_reg_union_ovcol.poly_bot(iobj_above,1).ScInt.Points(:,1) ...
										obj_reg_union_ovcol.poly_bot(iobj_above,1).ScInt.Points(:,2) ...
										obj_reg_union_ovcol.poly_bot(iobj_above,1).ScInt.Values(:,1)];
									TR		= delaunayTriangulation(xyz(:,1:2));
									CL		= TR.ConnectivityList;
									C						= incenter(TR);
									TFin					= inpolygon(...							% faster than isinterior
										C(:,1),...														% query points
										C(:,2),...
										obj_reg_union_ovcol.poly(iobj_above,1).Vertices(:,1),...						% polygon area
										obj_reg_union_ovcol.poly(iobj_above,1).Vertices(:,2));
									CL(~TFin,:)			= [];
									F	= [CL(:,1) CL(:,2) CL(:,3) CL(:,1)];
									h2=patch(ha,'faces',F,'vertices',xyz,...
										'EdgeColor',[0 0 0],'FaceColor',[0 0 0],'FaceAlpha',0.15,'EdgeAlpha',edgealpha,...
										'DisplayName','Object bottom side above');
									% Object below:
									xyz	= [...
										obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt.Points(:,1) ...
										obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt.Points(:,2) ...
										obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt.Values(:,1)];
									TR		= delaunayTriangulation(xyz(:,1:2));
									CL		= TR.ConnectivityList;
									C						= incenter(TR);
									TFin					= inpolygon(...							% faster than isinterior
										C(:,1),...														% query points
										C(:,2),...
										obj_reg_union_ovcol.poly(iobj_below,1).Vertices(:,1),...						% polygon area
										obj_reg_union_ovcol.poly(iobj_below,1).Vertices(:,2));
									CL(~TFin,:)			= [];
									F	= [CL(:,1) CL(:,2) CL(:,3) CL(:,1)];
									h1=patch(ha,'faces',F,'vertices',xyz,...
										'EdgeColor',[0 0 0],'FaceColor',[0 0 0],'FaceAlpha',0.05,'EdgeAlpha',edgealpha,...
										'DisplayName','Object bottom side below');
									% Intersection area:
									if numboundaries(poly_intersection)>0
										TR		= delaunayTriangulation(xy_intersection);
										CL		= TR.ConnectivityList;
										C						= incenter(TR);
										TFin					= inpolygon(...							% faster than isinterior
											C(:,1),...														% query points
											C(:,2),...
											poly_intersection.Vertices(:,1),...						% polygon area
											poly_intersection.Vertices(:,2));
										CL(~TFin,:)			= [];
										F	= [CL(:,1) CL(:,2) CL(:,3) CL(:,1)];
										h3=patch(ha,'faces',F,'vertices',[xy_intersection z_intersect_bot_above_v],...
											'EdgeColor',[0 0 0],'FaceColor',[0 1 0],'FaceAlpha',0.3,'EdgeAlpha',edgealpha,...
											'DisplayName','Intersection area');
										plot3(ha,...
											xy_intersection(:,1),...
											xy_intersection(:,2),...
											z_intersect_bot_above_v(:,1),'.g');
									end
									% New Object below:
									xyz	= [...
										obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt.Points(:,1) ...
										obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt.Points(:,2) ...
										obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt.Values(:,1)];
									xyz(xyz(:,3)>zmax_bot_below,3)	= zmax_bot_below;
									TR		= delaunayTriangulation(xyz(:,1:2));
									CL		= TR.ConnectivityList;
									C						= incenter(TR);
									TFin					= inpolygon(...							% faster than isinterior
										C(:,1),...														% query points
										C(:,2),...
										obj_reg_union_ovcol.poly(iobj_below,1).Vertices(:,1),...						% polygon area
										obj_reg_union_ovcol.poly(iobj_below,1).Vertices(:,2));
									CL(~TFin,:)			= [];
									F	= [CL(:,1) CL(:,2) CL(:,3) CL(:,1)];
									h4=patch(ha,'faces',F,'vertices',xyz,...
										'EdgeColor',[0 0 1],'FaceColor',[0 0 1],'FaceAlpha',0.3,'EdgeAlpha',edgealpha,...
										'DisplayName','Object bottom side below after');
									% zmin_intersect_bot_above:
									h5=plot3(ha,...
										xy_intersection(i_zmin_intersect_bot_above,1),...
										xy_intersection(i_zmin_intersect_bot_above,2),...
										zmin_intersect_bot_above,'.r','MarkerSize',15,...
										'DisplayName',sprintf('zmin_intersect_bot_above=%g',zmin_intersect_bot_above));
									% zmax_bot_below:
									h6=plot3(ha,...
										xy_intersection(i_zmin_intersect_bot_above,1),...
										xy_intersection(i_zmin_intersect_bot_above,2),...
										zmax_bot_below,'.c','MarkerSize',15,...
										'DisplayName',sprintf('zmax_bot_below=%g',zmax_bot_below));
									% obj_reg_union_ovcol.zbotmax(iobj_below):
									h7=plot3(ha,...
										xy_intersection(i_zmin_intersect_bot_above,1),...
										xy_intersection(i_zmin_intersect_bot_above,2),...
										obj_reg_union_ovcol.zbotmax(iobj_below),'.m','MarkerSize',15,...
										'DisplayName',sprintf('obj_reg_union_ovcol.zbotmax(iobj_below)=%g',...
										obj_reg_union_ovcol.zbotmax(iobj_below)));
									% End:
									subset_legend_v	= [h1 h2 h3 h4 h5 h6 h7];
									legend(ha,subset_legend_v,'Interpreter','none');
									title(ha,sprintf([...
										'iobj_above=%g: colno=%g (%s)\n',...
										'iobj_below=%g: colno=%g (%s)\n',...
										'zmin_intersect_bot_above = %g\n',...
										'd_bottom_above = %g\n',...
										'min_thickness_below = %g\n',...
										'zmax_bot_below = %g\n',...
										'zbotmax(iobj_below) = %g'],...
										iobj_above,colno_above,PP_local.color(colno_above).description,...
										iobj_below,colno_below,PP_local.color(colno_below).description,...
										zmin_intersect_bot_above,...
										d_bottom_above,...
										min_thickness_below,...
										zmax_bot_below,...
										obj_reg_union_ovcol.zbotmax(iobj_below)),...
										'Interpreter','none');
									view(ha,3);
									cameratoolbar('show');
									drawnow;
									% Test:
									if (colorprio_above==4)&&(colorprio_below==3)
										% iobj_above
										% iobj_below
										% d_side_above=PP_local.colorspec(icolspec_above).d_side
										% d_side_below=PP_local.colorspec(icolspec_below).d_side
										setbreakpoint=1;
									end
									if (iobj_above==20)&&(iobj_below==15)
										setbreakpoint=1;
									end
								end
								setbreakpoint=1;
								
							end
						end
					end
				end
				
				% Assign the field .z_bot:
				obj_reg_union_ovcol.z_bot(iobj_below,1)	= ...
					min(obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt.Values)-d_bottom_below;
				obj_reg_union_ovcol.z_bot(iobj_below,1)	= min(...
					obj_reg_union_ovcol.z_bot(iobj_below,1),...
					obj_reg_union_ovcol.zbotmax(iobj_below));
				
				% Update the bottom side z-values in the fields .poly_bot and .polybuffer_bot:
				if PP_local.colorspec(icolspec_below).bottom_version==1
					% bottom_version=1 (flat/horizontal: printing without support):
					% Alle z-Werte der Unterseite des Objekts iobj_below gleich dem Wert .z_bot setzen.
					% Das Feld .zbotmax wird nicht benötigt und muss hier nicht angepasst werden.
					
					% Change obj_reg_union_ovcol.poly_bot(iobj,1).ScInt:
					xyz							= [...
						obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt.Points(:,1) ...
						obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt.Points(:,2) ...
						obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt.Values(:,1)];
					z_greater_z_bot			= (xyz(:,3)>(obj_reg_union_ovcol.z_bot(iobj_below,1)+d_bottom_below));
					xyz(z_greater_z_bot,3)	= obj_reg_union_ovcol.z_bot(iobj_below,1)+d_bottom_below;
					obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt	= scatteredInterpolant(xyz(:,1),xyz(:,2),xyz(:,3));
					obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt.Method					= 'linear';
					obj_reg_union_ovcol.poly_bot(iobj_below,1).ScInt.ExtrapolationMethod	= 'nearest';
					
					% Change obj_reg_union_ovcol.polybuffer_bot(iobj,1).ScInt:
					xyz							= [...
						obj_reg_union_ovcol.polybuffer_bot(iobj_below,1).ScInt.Points(:,1) ...
						obj_reg_union_ovcol.polybuffer_bot(iobj_below,1).ScInt.Points(:,2) ...
						obj_reg_union_ovcol.polybuffer_bot(iobj_below,1).ScInt.Values(:,1)];
					z_greater_z_bot			= (xyz(:,3)>(obj_reg_union_ovcol.z_bot(iobj_below,1)+d_bottom_below));
					xyz(z_greater_z_bot,3)	= obj_reg_union_ovcol.z_bot(iobj_below,1)+d_bottom_below;
					obj_reg_union_ovcol.polybuffer_bot(iobj_below,1).ScInt	= scatteredInterpolant(xyz(:,1),xyz(:,2),xyz(:,3));
					obj_reg_union_ovcol.polybuffer_bot(iobj_below,1).ScInt.Method					= 'linear';
					obj_reg_union_ovcol.polybuffer_bot(iobj_below,1).ScInt.ExtrapolationMethod	= 'nearest';
					
				elseif PP_local.colorspec(icolspec_below).bottom_version==2
					% bottom_version=2 (follows the terrain at a constant distance from the surface):
					% Nothing to do here.
				else
					errormessage(sprintf([...
						'Error: The project parameter\n',...
						'colorspec(icolspec).bottom_version=%g\n',...
						'is not defined.'],...
						PP_local.colorspec(icolspec_below).bottom_version));
				end
				
			end
		end
		
		% Letzte Schritte:	obj_reg die Werte zmin, z_bot und zbotmax zuweisen:
		% Bemerkungen:			.dz und .zmax dürfen nicht neu zugewiesen werden, da ein Teil aus unterschiedlichen
		%							Kartenobjekten mit unterschiedlichen Höhen bestehen kann!
		for iobj1=length(obj_reg_union_ovcol.poly):-1:1
			if iobj2_v(iobj1)~=-9999
				% obj_reg_union_ovcol.poly(iobj1) enthält keine Daten:
				% Verwende die Daten von obj_reg_union_ovcol.poly(iobj2_v(iobj1)):
				obj_reg_union_ovcol.zmin(iobj1,1)		= obj_reg_union_ovcol.zmin(iobj2_v(iobj1),1);
				obj_reg_union_ovcol.zbotmax(iobj1,1)	= obj_reg_union_ovcol.zbotmax(iobj2_v(iobj1),1);
				obj_reg_union_ovcol.z_bot(iobj1,1)		= obj_reg_union_ovcol.z_bot(iobj2_v(iobj1),1);
				obj_reg.zmin(iobj1,1)		= obj_reg_union_ovcol.zmin(iobj1,1);
				obj_reg.zbotmax(iobj1,1)	= obj_reg_union_ovcol.zbotmax(iobj1,1);
				obj_reg.z_bot(iobj1,1)		= obj_reg_union_ovcol.z_bot(iobj1,1);
			else
				% obj_reg_union_ovcol.poly(iobj1) enthält Daten:
				obj_reg.zmin(iobj1,1)		= obj_reg_union_ovcol.zmin(iobj1,1);
				obj_reg.zbotmax(iobj1,1)	= obj_reg_union_ovcol.zbotmax(iobj1,1);
				obj_reg.z_bot(iobj1,1)		= obj_reg_union_ovcol.z_bot(iobj1,1);
			end
		end
		
end


% --------------------------------------------------------------------------------------------------------------------
% obj_reg_union_ovcol
% --------------------------------------------------------------------------------------------------------------------

% Testplots:
if (testplot_obj_reg==1)
	
	if ~isempty(testplot_xylimits)
		iobj_v			= 1;
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		for iobj=1:length(obj_reg_union_ovcol.poly)
			if overlaps(obj_reg_union_ovcol.poly(iobj),poly_xylimits)
				iobj_v	= [iobj_v;iobj];
			end
		end
		iobj_v	= unique(iobj_v);
		imax_obj	= length(iobj_v);
	else
		imax_obj	= length(obj_reg_union_ovcol.poly);
		iobj_v	= (1:imax_obj)';
	end
	m_obj		= ceil(sqrt(imax_obj));
	n_obj		= ceil((imax_obj)/m_obj);
	hf			= figure(100161);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','obj_reg_union_ovcol');
	set(hf,'NumberTitle','off');
	
	for k=1:length(iobj_v)
		iobj	= iobj_v(k);
		ha=subplot(m_obj,n_obj,k);
		hold(ha,'on');
		axis(ha,'equal');
		plot(ha,obj_reg_union_ovcol.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-',...
			'EdgeColor','k','FaceColor',PP_local.color(obj_reg_union_ovcol.colno(iobj)).rgb/255)
		if ~isempty(testplot_xylimits)
			set(ha,'XLim',[testplot_xylimits(1,1) testplot_xylimits(2,1)]);
			set(ha,'YLim',[testplot_xylimits(3,1) testplot_xylimits(4,1)]);
		else
			set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
			set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
		end
		colno					= obj_reg_union_ovcol.colno(iobj);
		icolspec				= PP_local.color(colno).spec;
		colorprio			= obj_reg_union_ovcol.colprio(iobj);
		% zmin					= obj_reg_union_ovcol.zmin(iobj);
		min_thickness		= PP_local.colorspec(icolspec).min_thickness;
		d_bottom				= PP_local.colorspec(icolspec).d_bottom;
		d_side				= PP_local.colorspec(icolspec).d_side;
		objprio				= obj_reg_union_ovcol.objprio(iobj);
		srftype				= obj_reg_union_ovcol.srftype(iobj);
		title(sprintf([...
			'i=%g, dz=%g\n',...
			'z_bot=%g, zbotmax=%g\n',...
			'zmin=%g, zmax=%g\n',...
			'minth=%g, dbottom=%g, dside=%g\n',...
			'cp=%g, icsp=%g, op=%g, st=%g'],...
			iobj,obj_reg_union_ovcol.dz(iobj),...
			obj_reg_union_ovcol.z_bot(iobj,1),obj_reg_union_ovcol.zbotmax(iobj,1),...
			obj_reg_union_ovcol.zmin(iobj),obj_reg_union_ovcol.zmax(iobj),...
			min_thickness,d_bottom,d_side,...
			colorprio,icolspec,objprio,srftype),...
			'Interpreter','none');
	end
	
end

if testplot_obj_reg_1plot==1
	imax_obj=length(obj_reg_union_ovcol.poly);
	hf=figure(100171);
	clf(hf,'reset');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Name','obj_reg_union_ovcol');
	set(hf,'NumberTitle','off');
	ha=axes(hf);
	hold(ha,'on');
	axis(ha,'equal');
	for iobj=2:imax_obj
		plot(ha,obj_reg_union_ovcol.poly(iobj),...
			'LineWidth',0.5,'LineStyle','-',...
			'EdgeColor','k','FaceColor',PP_local.color(obj_reg_union_ovcol.colno(iobj)).rgb/255)
	end
	if ~isempty(testplot_xylimits)
		poly_xylimits	= polyshape(...
			[testplot_xylimits(1,1) testplot_xylimits(2,1) testplot_xylimits(2,1) testplot_xylimits(1,1)],...
			[testplot_xylimits(3,1) testplot_xylimits(3,1) testplot_xylimits(4,1) testplot_xylimits(4,1)]);
		[x,y]				= boundary(poly_xylimits);
		plot(ha,x,y,'-r');
	end
	set(ha,'XLim',[PRINTDATA.xmin PRINTDATA.xmax]);
	set(ha,'YLim',[PRINTDATA.ymin PRINTDATA.ymax]);
	title(sprintf('i=2...%g',imax_obj),'Interpreter','none')
end










