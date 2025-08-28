function plotosmdata_simplify

global MAP_OBJECTS GV GV_H PP APP WAITBAR

try
	
	% % Test:
	% global map_objects_all
	% global imapobj_1 rpoly_1 iobj_1 prio_1 colno_1 isforeground_1 cut_by_obj_of_hp_1
	% global imapobj_2 rpoly_2 iobj_2 prio_2 colno_2 isforeground_2
	% global linewidth_2 tol
	% clc
	% map_pathname=GV.projectdirectory;map_filename=GV.map_filename;
	% load_project(map_pathname,map_filename);
	% GV.colno_testplot_simplify_v=[5 12 15];
	
	if isempty(PP)
		errortext	= sprintf([...
			'The project parameters have not yet been loaded.\n',...
			'First load the project parameters.']);
		errormessage(errortext);
	end
	if isempty(MAP_OBJECTS)
		errortext	= sprintf([...
			'The map has not yet been created.\n',...
			'First create the map.']);
		errormessage(errortext);
	end
	
	% Display state:
	t_start_statebusy		= clock;
	display_on_gui_str	= 'Simplify map objects ...';
	display_on_gui('state',display_on_gui_str,'busy','add');
	
	% User confirmation:
	question	= sprintf([...
		'Simplify map objects?\n',...
		'All changes should be made before this step.']);
	answer	= questdlg_local(question,'Continue?','Continue','Cancel','Cancel');
	if isempty(answer)||strcmp(answer,'Cancel')
		display_on_gui('state',...
			sprintf('%s Canceled (%s).',display_on_gui_str,dt_string(etime(clock,t_start_statebusy))),...
			'notbusy','replace');
		return
	end
	
	% Legend background:
	[poly_legbgd,prio_legbgd,warntext]	= get_poly_legbgd;
	if ~isempty(warntext)
		answer	= questdlg_local(warntext,'Continue?','Continue','Cancel','Cancel');
		if isempty(answer)||strcmp(answer,'Cancel')
			display_on_gui('state',...
				sprintf('%s Canceled (%s).',display_on_gui_str,dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			return
		end
	end
	
	% Autosave:
	filename_add			= ' - before simplify map';
	[map_filename,~,~]	= filenames_savefiles(filename_add);
	set(GV_H.text_waitbar,'String',sprintf('Autosave "%s"',map_filename));
	save_project(0,filename_add);
	
	% Set the value of the cutting lines dropdown menu to 'None' (make the map objects visible):
	set_previewtype_dropdown(1);
	
	% Clear the legend, so the changes to the axes will not be visible:
	legend(GV_H.ax_2dmap,'off');
	
	% The map has been changed:
	GV.map_is_saved	= 0;
	
	
	%------------------------------------------------------------------------------------------------------------------
	% map_objects_all: Relevant data of all plot objects, ungrouped and sorted by priority
	%------------------------------------------------------------------------------------------------------------------
	
	map_objects_all	= zeros(0,6);
	map_objects_cut	= struct;
	for imapobj=1:size(MAP_OBJECTS,1)
		if   (strcmp(MAP_OBJECTS(imapobj,1).disp,'area')           ||...
				strcmp(MAP_OBJECTS(imapobj,1).disp,'line')           ||...
				strcmp(MAP_OBJECTS(imapobj,1).disp,'text')           ||...
				strcmp(MAP_OBJECTS(imapobj,1).disp,'connection line')||...
				strcmp(MAP_OBJECTS(imapobj,1).disp,'symbol')              )&&...
				(MAP_OBJECTS(imapobj,1).iobj>=0)
			for rpoly=1:size(MAP_OBJECTS(imapobj,1).h,1)
				if    MAP_OBJECTS(imapobj,1).h(rpoly,1).Visible                                        &&...
						isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
						isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).FaceAlpha,GV.visibility.show.facealpha)
					ud	= MAP_OBJECTS(imapobj,1).h(rpoly,1).UserData;
					if length(ud)~=1
						errormessage;
					end
					if isfield(ud,'color_no')&&isfield(ud,'prio')&&isfield(ud,'iobj')
						if ud.iobj>0
							% Objects:
							switch MAP_OBJECTS(imapobj,1).disp
								case 'line'
									cut_by_obj_of_hp	= PP.obj(ud.iobj).simplify_lines.cut_by_obj_of_hp{1,1};
									cut_obj_of_lp		= PP.obj(ud.iobj).simplify_lines.cut_obj_of_lp{1,1};
								case 'area'
									cut_by_obj_of_hp	= PP.obj(ud.iobj).simplify_areas.cut_by_obj_of_hp{1,1};
									cut_obj_of_lp		= PP.obj(ud.iobj).simplify_areas.cut_obj_of_lp{1,1};
								case 'text'
									cut_by_obj_of_hp	= PP.obj(ud.iobj).textpar.cut_by_obj_of_hp{1,1};
									cut_obj_of_lp		= PP.obj(ud.iobj).textpar.cut_obj_of_lp{1,1};
								case 'connection line'
									cut_by_obj_of_hp	= PP.obj(ud.iobj).textpar.cut_by_obj_of_hp{1,1};
									cut_obj_of_lp		= PP.obj(ud.iobj).textpar.cut_obj_of_lp{1,1};
								case 'symbol'
									cut_by_obj_of_hp	= PP.obj(ud.iobj).symbolpar.cut_by_obj_of_hp{1,1};
									cut_obj_of_lp		= PP.obj(ud.iobj).symbolpar.cut_obj_of_lp{1,1};
							end
						else
							% ud.iobj==0: Legend:
							cut_by_obj_of_hp		= 0;
							cut_obj_of_lp			= 1;
						end
						map_objects_all	= [map_objects_all;...
							imapobj             ...		% 1)
							rpoly               ...		% 2)
							ud.iobj             ...		% 3)
							ud.prio             ...		% 4)
							ud.color_no         ...		% 5)
							ud.level];						% 6)
						map_objects_cut(size(map_objects_all,1),1).cb_hp	= cut_by_obj_of_hp;
						map_objects_cut(size(map_objects_all,1),1).c_lp		= cut_obj_of_lp;
					end
				end
			end
		end
	end
	[~,I]					= sort(map_objects_all(:,4));
	map_objects_all	= map_objects_all(I,:);
	map_objects_cut	= map_objects_cut(I,:);
	% The foreground of lines, areas, texts, symbols should not be deleted depending on PP.general.simplify.
	% The foreground will be limited to the background outline as last step of the simplification.
	isforeground	= zeros(size(map_objects_all,1),1);
	imapobj_v		= unique(map_objects_all(:,1));
	for k_imapobj_v=1:size(imapobj_v,1)
		i_v_level0			= find(...
			(map_objects_all(:,1)==imapobj_v(k_imapobj_v))&...
			(map_objects_all(:,6)==0                     )    ,1);
		i_v_level1			= find(...
			(map_objects_all(:,1)==imapobj_v(k_imapobj_v))&...
			(map_objects_all(:,6)==1                     )    );
		if ~isempty(i_v_level0)&&~isempty(i_v_level1)
			% The current objects consist of foreground and background polygons:
			isforeground(i_v_level1,1)		= 1;
		end
	end
	map_objects_all	= [map_objects_all isforeground];	% 7)
	
	
	%------------------------------------------------------------------------------------------------------------------
	% WAITBAR: preparation
	%------------------------------------------------------------------------------------------------------------------
	
	% Calculation of the remaining time:
	% x = (t1-t0)/(tend-t0) ,  dt10 = t1-t0  ==>  tend = t0+dt10/x
	% tremaining = tend-t1 = t0+dt10/x-t1 = dt10/x-(t1-t0) = dt10/x-dt10 = dt10*(1-x)/x
	
	% Calibration of WAITBAR.dx (Save also WAITBAR.size_map_objects_all together with dx.):
	% dx=WAITBAR.dt/sum(WAITBAR.dt),size_map_objects_all=WAITBAR.size_map_objects_all
	
	% Estimated execution times for every phase depending on smoa=size(map_objects_all,1):
	% (see plotosmdata_simplify_waitbar_setting.m)
	% measurement of WAITBAR.dt at different map sizes and approximation with the formula dt=a(1)*smoa^a(2)
	smoa	= size(map_objects_all,1);
	a_m	= [...
		1.6161e-06   1.2112e-05   3.8588e-06   1.2721e-05   8.5452e-06   1.5606e-06     0.001321;...
		2.1614       2.9429       2.3275       2.6802       2.9374       2.1249       1.1825];
	dt_v	= zeros(1,size(a_m,2));
	for k=1:size(a_m,2)
		a		= a_m(:,k);
		dt_v(1,k)	= a(1)*smoa^a(2);
	end
	% Normalization so that the sum of all elements is 1: dt --> dx
	dx_v	=dt_v/sum(dt_v);
	dx_min	= 0.07;								% Minimum value dx
	k_dx_less_than_dxmin	= dx_v<dx_min;		% Set dx_v(k_dx_less_than_dxmin) to the minimum value dx
	dx_v(k_dx_less_than_dxmin)	= dx_min;
	sum1	= sum(dx_v( k_dx_less_than_dxmin));
	sum2	= sum(dx_v(~k_dx_less_than_dxmin));
	dx_v(~k_dx_less_than_dxmin)	= dx_v(~k_dx_less_than_dxmin)*(1-sum1)/sum2;		% Decrease the other values
	
	% Assign WAITBAR:
	WAITBAR				= [];
	%                               Length of each phase:
	% new: values WAITBAR.dx depending on size(map_objects_all,1):
	WAITBAR.dx			= dx_v(:);
	% % old: fixed values WAITBAR.dx:
	% WAITBAR.dx(1,1)	= 0.044859;	% 1) Cut all polygons to the printout limits
	% WAITBAR.dx(2,1)	= 0.924320;	% 2) Cut objects -> less overlap
	% WAITBAR.dx(3,1)	= 0.010459;	% 3) In some cases there can remain small pieces: delete them
	% WAITBAR.dx(4,1)	= 0.019016;	% 4) Separation of lines: Cut lines at the edges of areas
	% WAITBAR.dx(5,1)	= 0.000972;	% 5) Separation of lines: Cut lines that have large differences in height
	% WAITBAR.dx(6,1)	= 0.000159;	% 6) The foreground of lines, areas, texts, symbols should be inside the background
	% WAITBAR.dx(7,1)	= 0.000216;	% 7) Change resolution of lines and areas
	WAITBAR.dx			= WAITBAR.dx/sum(WAITBAR.dx);			%
	WAITBAR.x0			= cumsum(WAITBAR.dx)-WAITBAR.dx;		% Begin each phase at x0(i)
	WAITBAR.dt			= zeros(size(WAITBAR.dx));				% measured time of each phase, for calibration of WAITBAR.dx
	WAITBAR.i			= 0;											% Current phase index
	WAITBAR.k			= 0;											% number of loops
	WAITBAR.kmax		= 0;											% maximum number of loops
	WAITBAR.t0_phase	= clock;										% Start time of the current phase
	WAITBAR.t0			= clock;										% Start time
	WAITBAR.t1			= clock;										% Time of the last update
	WAITBAR.name		= 'Simplify map objects ...';			% Name of the waitbar
	% WAITBAR.formatOut	= 'yyyy-mm-dd HH:MM:SS';			% Format of the "estimated end time" (see datestr)
	WAITBAR.formatOut	= 'HH:MM:SS';								% Format of the "estimated end time" (see datestr)
	WAITBAR.inapp		= 1;											% waitbar: 1: show in the app, 0: show separatly
	WAITBAR.h			= -1;											% Handle of the waitbar
	WAITBAR.size_map_objects_all	= smoa;
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Testplots:
	%------------------------------------------------------------------------------------------------------------------
	
	tp_EdgeAlpha	= 1;
	tp_FaceAlpha	= 0.35;
	colno_v			= unique(map_objects_all(:,5));
	for icol=1:length(colno_v)
		colno			= colno_v(icol);
		if colno>0
			icolspec		= PP.color(colno).spec;
			if any(colno==GV.colno_testplot_simplify_v)
				userdata_figtp	= sprintf('testplot1_plotosmdata_simplify_moveoutline_ColNo_%1.0f',colno);
				name_figtp		= sprintf('ColNo=%g',colno);
				h_figtp_icol	= findobj('Type','figure','-and','UserData',userdata_figtp);
				if isequal(size(h_figtp_icol),[1 1])
					figure(h_figtp_icol);
				else
					if ~isempty(h_figtp_icol)
						delete(h_figtp_icol);
					end
					h_figtp_icol	= figure;
				end
				if icol==1
					h_figtp				= h_figtp_icol;
				else
					h_figtp(icol,1)	= h_figtp_icol;
				end
				clf(h_figtp(icol,1),'reset');
				set(h_figtp(icol,1),'Tag','maplab3d_figure');
				set(h_figtp(icol,1),'NumberTitle','off');
				set(h_figtp(icol,1),'Name',name_figtp);
				set(h_figtp(icol,1),'UserData',userdata_figtp);
				ha_tpar(icol,1)		= gca;
				hold(ha_tpar(icol,1),'on');
				title(ha_tpar(icol,1),sprintf([...
					'Simplification of map objects: ColNo=%g:\n',...
					'%s\n',...
					'minimum_linewidth=%gmm, mindiag=%gmm'],...
					colno,...
					PP.color(colno).description,...
					PP.colorspec(icolspec,1).simplify_map.minimum_linewidth,...
					PP.colorspec(icolspec,1).simplify_map.mindiag),'Interpreter','none');
				legend_str={...
					'Before simplification',...
					'After simplification'};
				poly_allobj_icol	= polyshape();
				for i_1=1:size(map_objects_all,1)
					imapobj_1	= map_objects_all(i_1,1);
					rpoly_1		= map_objects_all(i_1,2);
					colno_1		= map_objects_all(i_1,5);
					if colno==colno_1
						poly_allobj_icol	= union(poly_allobj_icol,...
							MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...
							'KeepCollinearPoints',false);
					end
				end
				hplot_tpsimplify(icol,1)	= plot(ha_tpar(icol,1),poly_allobj_icol,...
					'EdgeColor','k','EdgeAlpha',tp_EdgeAlpha,...
					'FaceColor','b','FaceAlpha',tp_FaceAlpha);
				axis(ha_tpar(icol,1),'equal');
				setbreakpoint=1;
			end
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Phase i=1: Cut all polygons to the printout limits and
	%            Cut all objects of the legend to the limits of the legend
	%            Subtract the area of the legend from all objects that do not belong to the legend
	%------------------------------------------------------------------------------------------------------------------
	
	% Initializations:
	tol				= GV.tol_1;
	
	% Prepare the waitbar:
	WAITBAR.i			= 1;
	WAITBAR.k			= 0;
	WAITBAR.kmax		= size(map_objects_all,1);
	WAITBAR.t0_phase	= clock;
	
	% Cut all polygons to the printout limits in order to reduce complexity:
	if numboundaries(poly_legbgd)>0
		% Distance between legend and the other objects:
		dist_legobj_legbgd		= max(0,PP.legend.dist_legobj_legbgd);
		d_side						= 0;
		for i=1:size(map_objects_all,1)
			colno						= map_objects_all(i,5);
			if colno>0
				icolspec				= PP.color(colno).spec;
				d_side				= max(d_side,PP.colorspec(icolspec).d_side);
			end
		end
		dist_legobj_legbgd		= dist_legobj_legbgd+d_side+tol;				% map2stl_preparation: +2*tol
		% Legend buffered:
		if strcmp(GV.jointtype_bh,'miter')
			poly_legbgd_p_buff	= polybuffer(poly_legbgd,dist_legobj_legbgd,...
				'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
			poly_legbgd_m_buff	= polybuffer(poly_legbgd,-dist_legobj_legbgd,...
				'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
		else
			poly_legbgd_p_buff	= polybuffer(poly_legbgd,dist_legobj_legbgd,...
				'JointType',GV.jointtype_bh);
			poly_legbgd_m_buff	= polybuffer(poly_legbgd,-dist_legobj_legbgd,...
				'JointType',GV.jointtype_bh);
		end
	end
	for i=1:size(map_objects_all,1)
		
		% Waitbar:
		WAITBAR.k	= WAITBAR.k+1;
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
			set(GV_H.patch_waitbar,'XData',[0 x x 0]);
			set(GV_H.text_waitbar,'String',sprintf('Simplify map: Cut objects to printout limits %g/%g',...
				i,size(map_objects_all,1)));
			drawnow;
		end
		
		% Initializations:
		imapobj		= map_objects_all(i,1);
		rpoly			= map_objects_all(i,2);
		prio			= map_objects_all(i,4);
		
		% Cut to the printout limits:
		if (prio<=prio_legbgd)||numboundaries(poly_legbgd)==0
			MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape	= intersect(MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape,...
				GV_H.poly_map_printout_obj_limits.Shape,'KeepCollinearPoints',false);
		end
		
		% Legend:
		if numboundaries(poly_legbgd)>0
			if prio>prio_legbgd
				% poly_obj_map(i,1): Legend exept background:
				% Cut all objects of the legend to the limits of the legend
				MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape	= intersect(...
					MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape,poly_legbgd_m_buff,...
					'KeepCollinearPoints',false);
			elseif prio<prio_legbgd
				% all other objects:
				% Subtract the area of the legend from all objects that do not belong to the legend
				MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape	= subtract(...
					MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape,poly_legbgd_p_buff,...
					'KeepCollinearPoints',false);
			end
		end
		
	end
	
	% % % % Testplots:
	% % % colno_v	= unique(map_objects_all(:,5));
	% % % for icol=1:length(colno_v)
	% % % 	colno			= colno_v(icol);
	% % % 	if colno>0
	% % % 		icolspec		= PP.color(colno).spec;
	% % % 		if any(colno==GV.colno_testplot_simplify_v)
	% % % 			userdata_figtp	= sprintf('testplot1_plotosmdata_simplify_moveoutline_ColNo_%1.0f',colno);
	% % % 			name_figtp		= sprintf('ColNo=%g',colno);
	% % % 			h_figtp_icol	= findobj('Type','figure','-and','UserData',userdata_figtp);
	% % % 			if isequal(size(h_figtp_icol),[1 1])
	% % % 				figure(h_figtp_icol);
	% % % 			else
	% % % 				if ~isempty(h_figtp_icol)
	% % % 					delete(h_figtp_icol);
	% % % 				end
	% % % 				h_figtp_icol	= figure;
	% % % 			end
	% % % 			if icol==1
	% % % 				h_figtp				= h_figtp_icol;
	% % % 			else
	% % % 				h_figtp(icol,1)	= h_figtp_icol;
	% % % 			end
	% % % 			clf(h_figtp(icol,1),'reset');
	% % % 			set(h_figtp(icol,1),'Tag','maplab3d_figure');
	% % % 			set(h_figtp(icol,1),'NumberTitle','off');
	% % % 			set(h_figtp(icol,1),'Name',name_figtp);
	% % % 			set(h_figtp(icol,1),'UserData',userdata_figtp);
	% % % 			ha_tpar(icol,1)		= gca;
	% % % 			hold(ha_tpar(icol,1),'on');
	% % % 			title(ha_tpar(icol,1),sprintf([...
	% % % 				'Simplification of map objects: ColNo=%g:\n',...
	% % % 				'%s\n',...
	% % % 				'minimum_linewidth=%gmm, mindiag=%gmm'],...
	% % % 				colno,...
	% % % 				PP.color(colno).description,...
	% % % 				PP.colorspec(icolspec,1).simplify_map.minimum_linewidth,...
	% % % 				PP.colorspec(icolspec,1).simplify_map.mindiag),'Interpreter','none');
	% % % 			legend_str={...
	% % % 				'Before simplification',...
	% % % 				'After simplification'};
	% % % 			poly_allobj_icol	= polyshape();
	% % % 			for i_1=1:size(map_objects_all,1)
	% % % 				imapobj_1	= map_objects_all(i_1,1);
	% % % 				rpoly_1		= map_objects_all(i_1,2);
	% % % 				colno_1		= map_objects_all(i_1,5);
	% % % 				if colno==colno_1
	% % % 					poly_allobj_icol	= union(poly_allobj_icol,...
	% % % 						MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...
	% % % 						'KeepCollinearPoints',false);
	% % % 				end
	% % % 			end
	% % % 			hplot_tpsimplify(icol,1)	= plot(ha_tpar(icol,1),poly_allobj_icol,...
	% % % 				'EdgeColor','k','EdgeAlpha',tp_EdgeAlpha,...
	% % % 				'FaceColor','b','FaceAlpha',tp_FaceAlpha);
	% % % 			axis(ha_tpar(icol,1),'equal');
	% % % 			setbreakpoint=1;
	% % % 		end
	% % % 	end
	% % % end
	% % %
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	%------------------------------------------------------------------------------------------------------------------
	% Phase i=2: Cut objects -> less overlap:
	%------------------------------------------------------------------------------------------------------------------
	
	% Prepare the waitbar:
	WAITBAR.i			= 2;
	WAITBAR.k			= 0;
	WAITBAR.kmax		= sum(1:(size(map_objects_all,1)-1));
	WAITBAR.t0_phase	= clock;
	
	% Waitbar:
	set(GV_H.text_waitbar,'String',sprintf('Simplify: Cut objects for less overlap...'));
	
	% Cut objects -> less overlap:
	for i_1=(size(map_objects_all,1)-1):-1:1
		% i_1: objects of lower priority:
		imapobj_1					= map_objects_all(i_1,1);
		rpoly_1						= map_objects_all(i_1,2);
		iobj_1						= map_objects_all(i_1,3);
		prio_1						= map_objects_all(i_1,4);
		colno_1						= map_objects_all(i_1,5);
		isforeground_1				= map_objects_all(i_1,7);
		cut_by_obj_of_hp_1		= map_objects_cut(i_1,1).cb_hp;
		if colno_1>0
			colprio_1				= PP.color(colno_1,1).prio;
			isnonstandalone_1		= (PP.color(colno_1,1).standalone_color==0);
		else
			colprio_1				= -1;
			isnonstandalone_1		= true;		% colno_1=0: object 1 is cut by object 2
		end
		if (numboundaries(MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape)>0)&&...
				((prio_1<prio_legbgd)||(numboundaries(poly_legbgd)==0))
			for i_2=size(map_objects_all,1):-1:(i_1+1)
				% i_2: objects of higher priority:
				imapobj_2				= map_objects_all(i_2,1);
				rpoly_2					= map_objects_all(i_2,2);
				iobj_2					= map_objects_all(i_2,3);
				prio_2					= map_objects_all(i_2,4);
				colno_2					= map_objects_all(i_2,5);
				isforeground_2			= map_objects_all(i_2,7);
				cut_obj_of_lp_2		= map_objects_cut(i_2,1).c_lp;
				if colno_2>0
					colprio_2			= PP.color(colno_2,1).prio;
					isnonstandalone_2	= (PP.color(colno_2,1).standalone_color==0);
				else
					colprio_2			= -1;
					isnonstandalone_2	= true;		% colno_2=0: object 1 is not cut by object 2
				end
				if (numboundaries(MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape)>0)&&...
						((prio_2<prio_legbgd)||(numboundaries(poly_legbgd)==0))
					if (isforeground_1==0)&&(isforeground_2==0)
						if (colno_2>0)&&(colno_1~=colno_2)
							% If an object has the color number 0, it receives the color of the object below:
							% For example, continuous roads over the terrain (e.g. green) and the settlement area
							% (e.g. red) can be displayed as continuous line (with different colors).
							% Therefore such an object does not cut other objects (but can be cut itself):
							% If colno_1=0 the object can be cut, because it is not visible and it has not an own color.
							% Settings:
							% - cut_by_obj_of_hp=-1    The object is cut by all objects with a higher priority.
							% - cut_by_obj_of_hp=0     The object is not cut by any object with a higher
							%                          priority.
							% - cut_by_obj_of_hp=[8 9] The object is only cut by objects no. 8 and 9
							%                          if they have a higher priority.
							% - cut_obj_of_lp=-1       The object can cut all objects with a lower priority.
							% - cut_obj_of_lp=0        The object cannot cut any object with a lower priority.
							% - cut_obj_of_lp=[8 9]    The object can only cut objects no. 8 and 9
							%                          if they have a lower priority.
							% Handling of non-stand-alone colors:
							% - Always cut up non-stand-alone colors:
							%   If the color 1 (lower priority) at the bottom is non-stand-alone, this color is always cut
							%   because this color never has to remain as a continuous part.
							% - Never let stand-alone colors be cut by non-stand-alone colors:
							%   If the top color 2 (higher priority) is non-stand-alone, this color will be cut at the margins
							%   of the lower part 1 anyway. Part 1 can therefore remain intact and, if necessary, be cut
							%   manually at the desired points, instead of possibly being cut into many individual parts.
							obj1_iscutby_obj2		= ...
								isnonstandalone_1||(...				% Always cut up non-stand-alone colors
								~isnonstandalone_2&&...				% Never let stand-alone colors be cut by non-stand-alone colors
								(isequal(cut_by_obj_of_hp_1,-1)||any(cut_by_obj_of_hp_1==iobj_2))&&...		% 1 is cut by 2 and
								(isequal(cut_obj_of_lp_2   ,-1)||any(cut_obj_of_lp_2   ==iobj_1))     );	% 2 cuts 1
							if    obj1_iscutby_obj2    ||...
									(colprio_1>colprio_2)||...
									(colno_1==0)
								
								% Cut object 1 by object 2:
								% - (object 1 has lower priority as object 2,
								%    because map_objects_all is sorted by priority and i_1<i_2    ) and
								% - (object 1 is cut by object 2                            or
								%    the color priority of object 1 is higher than of object 2 or
								%    the color number of object 1 is equal to zero                )
								
								% Cut object 1 by object 2:
								[  ~,...									% poly1
									~,...									% poly2 (Subtrahend)
									dbuffer...							% dbuffer
									]=subtract_dside(...
									PP,...								% PP_local
									colno_1,...							% colno1
									colno_2);							% colno2
								
								% % old:
								%
								% % See also map2stl_preparation.m.m
								%
								% % 						iobj1				= map_objects_all(i_1,3);
								% % 						iobj2				= map_objects_all(i_2,3);
								% % 						if (iobj1==8)&&(iobj2==2)
								% % 							test=1
								% % 						end
								%
								% % d_side: horizontal distance between the sides of neighboring parts:
								% % d_side must be determined depending on the color priority of the two parts involved.
								% % The part with the higher color priority cuts a hole in the part with the lower color priority.
								% if colno_1>0
								% 	if colprio_1>colprio_2
								% 		icolspec	= PP.color(colno_1).spec;
								% 	else
								% 		icolspec	= PP.color(colno_2).spec;
								% 	end
								% 	d_side		= PP.colorspec(icolspec).d_side;
								% else
								% 	% No distinction should be made here as to which objects the objects with colno_1=0 lie over:
								% 	d_side		= max([PP.colorspec(:).d_side]);
								% end
								%
								% % 						% funktioniert (Teile sind niedriger):
								% % 						icolspec_1	= PP.color(colno_1).spec;
								% % 						icolspec_2	= PP.color(colno_2).spec;
								% % 						d_side		= max(...
								% % 							PP.colorspec(icolspec_1).d_side,...
								% % 							PP.colorspec(icolspec_2).d_side)
								%
								% % Objects buffered by the horizontal distance between neighboring parts:
								% % +2*tol: so that no overlap is detected when calculating z_bot in map2stl.m:
								% % +GV.plotosmdata_simplify.dmin_changeresolution*1.01:
								% % the outline is changed when reducing the resolution (see below)
								% dbuffer			= d_side+2*tol+GV.plotosmdata_simplify.dmin_changeresolution*1.01;
								
								% Detect overlap:
								dbufferpt			= 2*(dbuffer+10*tol);
								[xlim1,ylim1]		= boundingbox(MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape);
								if size(xlim1,1)>0
									[xlim2,ylim2]	= boundingbox(MAP_OBJECTS(imapobj_2,1).h(rpoly_2,1).Shape);
									if size(xlim2,1)>0
										if overlaps_boundingbox(dbufferpt,...
												xlim1(1),xlim1(2),ylim1(1),ylim1(2),...
												xlim2(1),xlim2(2),ylim2(1),ylim2(2))
											%									% old:
											% 									x1min				= xlim1(1);
											% 									x1max				= xlim1(2);
											% 									y1min				= ylim1(1);
											% 									y1max				= ylim1(2);
											% 									x1minmt			= x1min-dbufferpt;
											% 									x1maxpt			= x1max+dbufferpt;
											% 									y1minmt			= y1min-dbufferpt;
											% 									y1maxpt			= y1max+dbufferpt;
											% 									x2min				= xlim2(1);
											% 									x2max				= xlim2(2);
											% 									y2min				= ylim2(1);
											% 									y2max				= ylim2(2);
											% 									x2minmt			= x2min-dbufferpt;
											% 									x2maxpt			= x2max+dbufferpt;
											% 									y2minmt			= y2min-dbufferpt;
											% 									y2maxpt			= y2max+dbufferpt;
											% 									if (    (x2min>=(x1minmt))&&(x2min<=(x1maxpt))&&(y2min>=(y1minmt))&&(y2min<=(y1maxpt)) ) || ...	% Bottom left  corner of 2 is within 1
											% 											( (x2max>=(x1minmt))&&(x2max<=(x1maxpt))&&(y2min>=(y1minmt))&&(y2min<=(y1maxpt)) ) || ...	% Bottom right corner of 2 is within 1
											% 											( (x2max>=(x1minmt))&&(x2max<=(x1maxpt))&&(y2max>=(y1minmt))&&(y2max<=(y1maxpt)) ) || ...	% top    right corner of 2 is within 1
											% 											( (x2min>=(x1minmt))&&(x2min<=(x1maxpt))&&(y2max>=(y1minmt))&&(y2max<=(y1maxpt)) ) || ...	% Upper  left  corner of 2 is within 1
											% 											( (x1min>=(x2minmt))&&(x1min<=(x2maxpt))&&(y1min>=(y2minmt))&&(y1min<=(y2maxpt)) ) || ...	% bottom left  corner of 1 is within 2
											% 											( (x1max>=(x2minmt))&&(x1max<=(x2maxpt))&&(y1min>=(y2minmt))&&(y1min<=(y2maxpt)) ) || ...	% bottom right corner of 1 is within 2
											% 											( (x1max>=(x2minmt))&&(x1max<=(x2maxpt))&&(y1max>=(y2minmt))&&(y1max<=(y2maxpt)) ) || ...	% top    right corner of 1 is within 2
											% 											( (x1min>=(x2minmt))&&(x1min<=(x2maxpt))&&(y1max>=(y2minmt))&&(y1max<=(y2maxpt)) ) || ...	% top    left  corner of 1 is within 2
											% 											( (x2min>=(x1minmt))&&(x2max<=(x1maxpt))&&(y1min>=(y2minmt))&&(y1max<=(y2maxpt)) ) || ...	% All x-values of 2 are within of the x-values of 1 and all y-values of 1 are within the y-values of 2
											% 											( (x1min>=(x2minmt))&&(x1max<=(x2maxpt))&&(y2min>=(y1minmt))&&(y2max<=(y1maxpt)) )			% All x-values of 1 are within of the x-values of 2 and all y-values of 2 are within the y values of 1
											% The polygons may overlap or touch:
											if strcmp(GV.jointtype_bh,'miter')
												map_obj_2_buffpt	= polybuffer(...
													MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape,...
													dbufferpt,'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
											else
												map_obj_2_buffpt	= polybuffer(...
													MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape,...
													dbufferpt,'JointType',GV.jointtype_bh);
											end
											if overlaps(MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,map_obj_2_buffpt)
												% The polygons overlap or touch:
												
												% Waitbar:
												if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
													WAITBAR.t1	= clock;
													k_prev		= sum(1:(size(map_objects_all,1)-1-i_1));						% OK
													WAITBAR.k	= k_prev+size(map_objects_all,1)-i_2+1;
													x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
													set(GV_H.patch_waitbar,'XData',[0 x x 0]);
													dscr_1	= MAP_OBJECTS(imapobj_1,1).dscr;
													if ~isempty(MAP_OBJECTS(imapobj_1,1).text{1,1})
														dscr_1	= [dscr_1 ' /'];
														for itext=1:size(MAP_OBJECTS(imapobj_1,1).text,1)
															dscr_1	= [dscr_1 ' ' MAP_OBJECTS(imapobj_1,1).text{itext,1}];
														end
													end
													dscr_2	= MAP_OBJECTS(imapobj_2,1).dscr;
													if ~isempty(MAP_OBJECTS(imapobj_2,1).text{1,1})
														dscr_2	= [dscr_2 ' /'];
														for itext=1:size(MAP_OBJECTS(imapobj_2,1).text,1)
															dscr_2	= [dscr_2 ' ' MAP_OBJECTS(imapobj_2,1).text{itext,1}];
														end
													end
													set(GV_H.text_waitbar,'String',...
														sprintf('Simplify map: Cut object %g/%g (ObjNo %g: %s) by %g/%g (ObjNo %g: %s)',...
														size(map_objects_all,1)-i_1,size(map_objects_all,1)-1,...
														iobj_1,dscr_1,...
														size(map_objects_all,1)-i_2+1,size(map_objects_all,1)-i_1,...
														iobj_2,dscr_2));
													drawnow;
												end
												
												% Cut object 1 by object 2:
												[  MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...		% poly1
													MAP_OBJECTS(imapobj_2,1).h(rpoly_2,1).Shape,...		% poly2 (Subtrahend)
													~...																% dbuffer
													]=subtract_dside(...
													PP,...															% PP_local
													colno_1,...														% colno1
													colno_2,...														% colno2
													MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...		% poly1
													MAP_OBJECTS(imapobj_2,1).h(rpoly_2,1).Shape);		% poly2 (Subtrahend)
												
												% % old:
												%
												% % Cut object 1 by object 2:
												% if strcmp(GV.jointtype_bh,'miter')
												% 	map_obj_2_buff	= polybuffer(...
												% 		MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape,...
												% 		dbuffer,'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
												% else
												% 	map_obj_2_buff	= polybuffer(...
												% 		MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape,...
												% 		dbuffer,'JointType',GV.jointtype_bh);
												% end
												% MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape		= subtract(...
												% 	MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...
												% 	map_obj_2_buff,...
												% 	'KeepCollinearPoints',false);
												%
												% % Cut object 2 by the already cut object 1:
												% % (should not be necessary, but needed in some special cases)
												% if strcmp(GV.jointtype_bh,'miter')
												% 	map_obj_1_buff	= polybuffer(...
												% 		MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...
												% 		dbuffer,'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
												% else
												% 	map_obj_1_buff	= polybuffer(...
												% 		MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...
												% 		dbuffer,'JointType',GV.jointtype_bh);
												% end
												% MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape		= subtract(...
												% 	MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape,...
												% 	map_obj_1_buff,...
												% 	'KeepCollinearPoints',false);
												
												% Simplify: delete small or narrow parts:
												% colno_1=0: No need to simplify, because there are no separate parts.
												if    (colno_1>0)                                      &&(...
														strcmp(MAP_OBJECTS(imapobj_1,1).disp,'line')||...
														strcmp(MAP_OBJECTS(imapobj_1,1).disp,'area')           )
													% if (imapobj_1==5)&&(imapobj_2==21)
													% 	test=1;
													% end
													poly_mask	= create_deletemask(...
														colno_1,...
														map_objects_all,...
														tol);
													MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape	= subtract(...
														MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...
														poly_mask,...
														'KeepCollinearPoints',false);
												end
												
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	%------------------------------------------------------------------------------------------------------------------
	% Phase i=3: In some cases there can remain small pieces: delete them:
	%------------------------------------------------------------------------------------------------------------------
	
	% Prepare the waitbar:
	WAITBAR.i			= 3;
	WAITBAR.k			= 0;
	WAITBAR.kmax		= length(colno_v)+size(map_objects_all,1);
	WAITBAR.t0_phase	= clock;
	
	colno_v	= unique(map_objects_all(:,5));
	for i_colno_v=1:length(colno_v)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.k	= i_colno_v;
			WAITBAR.t1	= clock;
			x		= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
			set(GV_H.patch_waitbar,'XData',[0 x x 0]);
			set(GV_H.text_waitbar,'String',...
				sprintf('Simplify map: Cut remaining objects 1 %g/%g',...
				i_colno_v,length(colno_v)));
			drawnow;
		end
		colno			= colno_v(i_colno_v);
		if colno>0
			poly_mask(colno,1)	= create_deletemask(colno,map_objects_all,tol);
		end
	end
	for i_1=1:size(map_objects_all,1)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.k	= length(colno_v)+i_1;
			WAITBAR.t1	= clock;
			x		= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
			set(GV_H.patch_waitbar,'XData',[0 x x 0]);
			set(GV_H.text_waitbar,'String',...
				sprintf('Simplify map: Cut remaining objects 2 %g/%g',...
				i_1,size(map_objects_all,1)));
			drawnow;
		end
		imapobj_1	= map_objects_all(i_1,1);
		prio_1		= map_objects_all(i_1,4);
		if (strcmp(MAP_OBJECTS(imapobj_1,1).disp,'line')||strcmp(MAP_OBJECTS(imapobj_1,1).disp,'area'))&&...
				((prio_1<prio_legbgd)||(numboundaries(poly_legbgd)==0))
			rpoly_1		= map_objects_all(i_1,2);
			colno_1		= map_objects_all(i_1,5);
			if colno_1>0
				MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape	= subtract(...
					MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...
					poly_mask(colno_1,1),...
					'KeepCollinearPoints',false);
				% if (imapobj_1==5)
				% 	if any(colno_1==GV.colno_testplot_simplify_v)
				% 		set_breakpoint	= 1;
				% 	end
				% end
			end
		end
	end
	
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	%------------------------------------------------------------------------------------------------------------------
	% Phase i=4: Separation of lines: Cut lines at the edges of areas:
	%------------------------------------------------------------------------------------------------------------------
	
	% Prepare the waitbar:
	WAITBAR.i			= 4;
	WAITBAR.k			= 0;
	WAITBAR.kmax		= size(map_objects_all,1)-1;
	WAITBAR.t0_phase	= clock;
	
	for i_1=(size(map_objects_all,1)-1):-1:1
		% i_1: areas of lower priority:
		imapobj_1					= map_objects_all(i_1,1);
		rpoly_1						= map_objects_all(i_1,2);
		iobj_1						= map_objects_all(i_1,3);
		prio_1						= map_objects_all(i_1,4);
		colno_1						= map_objects_all(i_1,5);
		cut_by_obj_of_hp_1		= map_objects_cut(i_1,1).cb_hp;
		isforeground_1				= map_objects_all(i_1,7);
		if colno_1>0
			isnonstandalone_1			= (PP.color(colno_1,1).standalone_color==0);
		else
			isnonstandalone_1			= true;		% colno_1=0: object 1 is cut by object 2
		end
		if strcmp(MAP_OBJECTS(imapobj_1,1).disp,'area')&&(colno_1>0)&&(isforeground_1==0)&&...
				((prio_1<prio_legbgd)||(numboundaries(poly_legbgd)==0))
			% First collect all lines to be considered, each color separatly:
			i_2_v					= nan(size(map_objects_all,1),1);
			liwi_2_v				= nan(size(map_objects_all,1),1);
			colno_2_v			= nan(size(map_objects_all,1),1);
			poly_line			= polyshape();
			divpoly_blocked(1,1).color	= [];
			divpoly_blocked(1,:)			= [];
			for i_2=size(map_objects_all,1):-1:(i_1+1)
				% i_2: lines of higher priority:
				% Waitbar:
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					WAITBAR.t1	= clock;
					WAITBAR.k	= size(map_objects_all,1)-i_1;
					x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
					set(GV_H.patch_waitbar,'XData',[0 x x 0]);
					set(GV_H.text_waitbar,'String',...
						sprintf('Simplify map: Cut lines at the edges of areas 1 %g/%g %g/%g',...
						size(map_objects_all,1)-i_1,size(map_objects_all,1)-1,...
						size(map_objects_all,1)-i_2+1,size(map_objects_all,1)-i_1));
					drawnow;
				end
				imapobj_2				= map_objects_all(i_2,1);
				rpoly_2					= map_objects_all(i_2,2);
				iobj_2					= map_objects_all(i_2,3);
				prio_2					= map_objects_all(i_2,4);
				colno_2					= map_objects_all(i_2,5);
				isforeground_2			= map_objects_all(i_2,7);
				cut_obj_of_lp_2		= map_objects_cut(i_2,1).c_lp;
				if colno_2>0
					icolspec_2			= PP.color(colno_2).spec;
					isnonstandalone_2	= (PP.color(colno_2,1).standalone_color==0);
				else
					icolspec_2			= 1;
					isnonstandalone_2	= true;		% colno_2=0: object 1 is not cut by object 2
				end
				if PP.colorspec(icolspec_2,1).simplify_map.divlines_gapwidth>0
					obj1_iscutby_obj2		= ...
						isnonstandalone_1||(...				% Always cut up non-stand-alone colors
						~isnonstandalone_2&&...				% Never let stand-alone colors be cut by non-stand-alone colors
						(isequal(cut_by_obj_of_hp_1,-1)||any(cut_by_obj_of_hp_1==iobj_2))&&...		% 1 is cut by 2 and
						(isequal(cut_obj_of_lp_2   ,-1)||any(cut_obj_of_lp_2   ==iobj_1))     );	% 2 cuts 1
					if    strcmp(MAP_OBJECTS(imapobj_2,1).disp,'line')&&...
							(colno_2>0)                                 &&...
							(colno_1~=colno_2)                          &&...
							~obj1_iscutby_obj2					           &&...
							(isforeground_2==0)                         &&...
							(PP.obj(iobj_2).display_as_line~=0)         &&...
							((prio_2<prio_legbgd)||(numboundaries(poly_legbgd)==0))
						% Object 1 (area) has lower priority as object 2 (line) and is not cut by object 2:
						% Total line width:
						[~,~,~,~,...
							~,...											% constant line width or minimum line width
							linewidth_2]	= ...						% constant line width or maximum line width
							line2poly(...
							[],...										% x
							[],...										% y
							PP.obj(iobj_2).linepar,...				% par
							PP.obj(iobj_2).linestyle,...			% style
							iobj_2);										% iobj
						i_2_v(i_2,1)		= i_2;
						liwi_2_v(i_2,1)	= linewidth_2;
						colno_2_v(i_2,1)	= colno_2;
						if size(poly_line,1)<colno_2
							poly_line(colno_2,1)	= polyshape();
						end
						poly_line(colno_2,1)	= union(poly_line(colno_2,1),...
							MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape,...
							'KeepCollinearPoints',false);
						% Do not block the cutting of lines with linestyle 4 at the edges of areas
						% because otherwise the areas may become unnecessarily high:
						cut_linestyle_4_at_the_edges_of_areas	= false;
						if cut_linestyle_4_at_the_edges_of_areas
							if    (PP.obj(iobj_2,1).linestyle==4)                               &&...
									isfield(MAP_OBJECTS(imapobj_2,1).h(rpoly_2).UserData,'x_zmin')&&...
									isfield(MAP_OBJECTS(imapobj_2,1).h(rpoly_2).UserData,'y_zmin')&&...
									isfield(MAP_OBJECTS(imapobj_2,1).h(rpoly_2).UserData,'z_zmin')
								% Steady change in elevation:
								% Used for bridges: A bridge with this setting should not be cut, because then
								% the color under the bridge could be raised and become visible.
								if size(divpoly_blocked,1)>=colno_2
									idpbl		= size(divpoly_blocked(colno_2,1).color,1)+1;
								else
									idpbl		= 1;
								end
								divpoly_blocked(colno_2,1).color(idpbl,1).polybuff	=  polybuffer(...
									MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape,GV.tol_1,...
									'JointType','miter','MiterLimit',2);
								divpoly_blocked(colno_2,1).color(idpbl,1).x_zmin		= MAP_OBJECTS(imapobj_2,1).h(rpoly_2).UserData.x_zmin;
								divpoly_blocked(colno_2,1).color(idpbl,1).y_zmin		= MAP_OBJECTS(imapobj_2,1).h(rpoly_2).UserData.y_zmin;
								divpoly_blocked(colno_2,1).color(idpbl,1).z_zmin		= MAP_OBJECTS(imapobj_2,1).h(rpoly_2).UserData.z_zmin;
							end
						end
					end
				end
			end
			% Calculate the dividing polygons of every color and divide the lines of every object:
			colno_v_red								= unique(colno_2_v);
			colno_v_red(isnan(colno_v_red	))	= [];
			for i_colno_v_red=1:length(colno_v_red)
				% Waitbar:
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					WAITBAR.t1	= clock;
					WAITBAR.k	= size(map_objects_all,1)-i_1;
					x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
					set(GV_H.patch_waitbar,'XData',[0 x x 0]);
					set(GV_H.text_waitbar,'String',...
						sprintf('Simplify map: Cut lines at the edges of areas 2 %g/%g %g/%g',...
						size(map_objects_all,1)-i_1,size(map_objects_all,1)-1,...
						i_colno_v_red,length(colno_v_red)));
					drawnow;
				end
				colno_2			= colno_v_red(i_colno_v_red);
				k					= (colno_2_v==colno_2);
				i_2_v_red		= i_2_v(k);
				liwi_2_v_red	= liwi_2_v(k);
				liwi_2			= max(liwi_2_v_red);
				% if colno_2==5
				% 	test=1
				% end
				if colno_2<=size(divpoly_blocked,1)
					divpoly_blocked_colno_2_color		= divpoly_blocked(colno_2,1).color;
				else
					divpoly_blocked_colno_2_color		= [];
				end
				% Calculate the dividing polygons, using all objects of the same color
				[  ~,...																		% poly_line
					MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...				% poly_area
					dividing_poly...														% dividing_poly
					]=divide_line(...
					poly_line(colno_2,1),...											% poly_line
					MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...				% poly_area
					colno_2,...																% colno_line
					colno_1,...																% colno_area
					divpoly_blocked_colno_2_color,...								% divpoly_blocked
					liwi_2,...																% liwi
					GV.plotosmdata_simplify.dmin_changeresolution,...			% GV.plotosmdata_simplify.dmin_changeresolution
					tol);																		% tol
				% Divide the lines:
				if numboundaries(dividing_poly)>0
					for i_i_2_v_red=1:length(i_2_v_red	)
						i_2							= i_2_v_red(i_i_2_v_red);
						imapobj_2					= map_objects_all(i_2,1);
						rpoly_2						= map_objects_all(i_2,2);
						MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape	= subtract(...
							MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape,...
							dividing_poly,...
							'KeepCollinearPoints',false);
					end
				end
			end
		end
	end
	
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	%------------------------------------------------------------------------------------------------------------------
	% Phase i=5: Separation of lines: Cut lines that have large differences in height:
	%------------------------------------------------------------------------------------------------------------------
	
	% Prepare the waitbar:
	WAITBAR.i			= 5;
	WAITBAR.k			= 0;
	WAITBAR.kmax		= size(map_objects_all,1);
	WAITBAR.t0_phase	= clock;
	
	% First collect all lines to be considered, each color separatly:
	i_2_v					= nan(size(map_objects_all,1),1);
	liwi_2_v				= nan(size(map_objects_all,1),1);
	colno_2_v			= nan(size(map_objects_all,1),1);
	poly_line			= polyshape();
	divpoly_blocked	= [];
	for i_2=size(map_objects_all,1):-1:1
		% i_2: lines of higher priority:
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			WAITBAR.k	= size(map_objects_all,1)-i_2+1;
			x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
			set(GV_H.patch_waitbar,'XData',[0 x x 0]);
			set(GV_H.text_waitbar,'String',...
				sprintf('Simplify map: Cut lines that have large differences in height 1 %g/%g',...
				size(map_objects_all,1)-i_2+1,size(map_objects_all,1)));
			drawnow;
		end
		imapobj_2					= map_objects_all(i_2,1);
		rpoly_2						= map_objects_all(i_2,2);
		iobj_2						= map_objects_all(i_2,3);
		prio_2						= map_objects_all(i_2,4);
		colno_2						= map_objects_all(i_2,5);
		isforeground_2				= map_objects_all(i_2,7);
		if colno_2>0
			icolspec_2					= PP.color(colno_2).spec;
			if PP.colorspec(icolspec_2,1).simplify_map.divlines_gapwidth>0
				if strcmp(MAP_OBJECTS(imapobj_2,1).disp,'line')&&...
						(isforeground_2==0)&&(PP.obj(iobj_2).display_as_line~=0)&&...
						((prio_2<prio_legbgd)||(numboundaries(poly_legbgd)==0))
					% Total line width:
					[~,~,~,~,...
						~,...											% constant line width or minimum line width
						linewidth_2]	= ...						% constant line width or maximum line width
						line2poly(...
						[],...										% x
						[],...										% y
						PP.obj(iobj_2).linepar,...				% par
						PP.obj(iobj_2).linestyle,...			% style
						iobj_2);										% iobj
					i_2_v(i_2,1)		= i_2;
					liwi_2_v(i_2,1)	= linewidth_2;
					colno_2_v(i_2,1)	= colno_2;
					if size(poly_line,1)<colno_2
						poly_line(colno_2,1)	= polyshape();
					end
					poly_line(colno_2,1)	= union(poly_line(colno_2,1),...
						MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape,...
						'KeepCollinearPoints',false);
					% Block the cutting of lines with linestyle 4 because the parts can become higher than
					% the specified limits anyway and because the algorithm therefore cannot work:
					cut_linestyle_4_large_differences_in_height	= true;
					if cut_linestyle_4_large_differences_in_height
						if    (PP.obj(iobj_2,1).linestyle==4)                               &&...
								isfield(MAP_OBJECTS(imapobj_2,1).h(rpoly_2).UserData,'x_zmin')&&...
								isfield(MAP_OBJECTS(imapobj_2,1).h(rpoly_2).UserData,'y_zmin')&&...
								isfield(MAP_OBJECTS(imapobj_2,1).h(rpoly_2).UserData,'z_zmin')
							% Steady change in elevation:
							% Used for bridges: A bridge with this setting should not be cut, because then
							% the color under the bridge could be raised and become visible.
							idpbl		= size(divpoly_blocked,1)+1;
							divpoly_blocked(idpbl,1).polybuff	=  polybuffer(...
								MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape,GV.tol_1,...
								'JointType','miter','MiterLimit',2);
							divpoly_blocked(idpbl,1).x_zmin		= MAP_OBJECTS(imapobj_2,1).h(rpoly_2).UserData.x_zmin;
							divpoly_blocked(idpbl,1).y_zmin		= MAP_OBJECTS(imapobj_2,1).h(rpoly_2).UserData.y_zmin;
							divpoly_blocked(idpbl,1).z_zmin		= MAP_OBJECTS(imapobj_2,1).h(rpoly_2).UserData.z_zmin;
						end
					end
					
				end
			end
		end
	end
	% Calculate the dividing polygons of every color and divide the lines of every object:
	colno_v_red								= unique(colno_2_v);
	colno_v_red(isnan(colno_v_red	))	= [];
	for i_colno_v_red=1:length(colno_v_red)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			WAITBAR.k	= size(map_objects_all,1);
			x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
			set(GV_H.patch_waitbar,'XData',[0 x x 0]);
			set(GV_H.text_waitbar,'String',...
				sprintf('Simplify map: Cut lines that have large differences in height 2 %g/%g',...
				i_colno_v_red,length(colno_v_red)));
			drawnow;
		end
		colno_2			= colno_v_red(i_colno_v_red);
		k					= (colno_2_v==colno_2);
		i_2_v_red		= i_2_v(k);
		liwi_2_v_red	= liwi_2_v(k);
		liwi_2			= max(liwi_2_v_red);
		% Calculate the dividing polygons, using all objects of the same color:
		[  ~,...									% poly_line
			~,...									% poly_area
			dividing_poly...					% dividing_poly
			]=divide_line(...
			poly_line(colno_2,1),...		% poly_line
			[],...								% poly_area
			colno_2,...							% colno_line
			[],...								% colno_area
			divpoly_blocked,...				% divpoly_blocked
			liwi_2,...							% liwi
			[],...								% GV.plotosmdata_simplify.dmin_changeresolution
			[]);									% tol
		% Divide the lines:
		if numboundaries(dividing_poly)>0
			for i_i_2_v_red=1:length(i_2_v_red	)
				i_2							= i_2_v_red(i_i_2_v_red);
				imapobj_2					= map_objects_all(i_2,1);
				rpoly_2						= map_objects_all(i_2,2);
				MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape	= subtract(...
					MAP_OBJECTS(imapobj_2,1).h(rpoly_2).Shape,...
					dividing_poly,...
					'KeepCollinearPoints',false);
			end
		end
	end
	
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	%------------------------------------------------------------------------------------------------------------------
	% Phase i=6: The foreground of lines, areas, texts, symbols should be inside the background
	%            (less problems in map2stl.m):
	%------------------------------------------------------------------------------------------------------------------
	
	imapobj_v	= unique(map_objects_all(:,1));
	
	% Prepare the waitbar:
	WAITBAR.i			= 6;
	WAITBAR.k			= 0;
	WAITBAR.kmax		= size(imapobj_v,1);
	WAITBAR.t0_phase	= clock;
	
	for k_imapobj_v=1:size(imapobj_v,1)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			WAITBAR.k	= k_imapobj_v;
			x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
			set(GV_H.patch_waitbar,'XData',[0 x x 0]);
			set(GV_H.text_waitbar,'String',...
				sprintf('Simplify map: Reshape foreground polygons %g/%g',...
				k_imapobj_v,size(imapobj_v,1)));
			drawnow;
		end
		i_v_level0			= find(...
			(map_objects_all(:,1)==imapobj_v(k_imapobj_v))&...
			(map_objects_all(:,6)==0                     )    );
		i_v_level1			= find(...
			(map_objects_all(:,1)==imapobj_v(k_imapobj_v))&...
			(map_objects_all(:,6)==1                     )    );
		if ~isempty(i_v_level0)&&~isempty(i_v_level1)
			% The current objects consist of foreground and background polygons:
			% Background polygon (level=0):
			poly_bgd		= polyshape();
			for k_level0=1:length(i_v_level0)
				i				= i_v_level0(k_level0);
				imapobj		= map_objects_all(i,1);
				rpoly			= map_objects_all(i,2);
				poly_bgd		= union(poly_bgd,MAP_OBJECTS(imapobj,1).h(rpoly).Shape,...
					'KeepCollinearPoints',false);
			end
			poly_bgd_buff	= polybuffer(poly_bgd,...
				-GV.d_forebackgrd_plotobj,'JointType','miter','MiterLimit',2);
			% Limit the size of the foreground polygons (level=1):
			for k_level1=1:length(i_v_level1)
				i				= i_v_level1(k_level1);
				imapobj		= map_objects_all(i,1);
				rpoly			= map_objects_all(i,2);
				poly_bgd		= union(poly_bgd,MAP_OBJECTS(imapobj,1).h(rpoly).Shape,...
					'KeepCollinearPoints',false);
				MAP_OBJECTS(imapobj,1).h(rpoly).Shape		= ...
					intersect(MAP_OBJECTS(imapobj,1).h(rpoly).Shape,...
					poly_bgd_buff,'KeepCollinearPoints',false);
			end
		end
	end
	
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	%------------------------------------------------------------------------------------------------------------------
	% Phase i=7: Change resolution of lines and areas:
	%------------------------------------------------------------------------------------------------------------------
	
	% Prepare the waitbar:
	WAITBAR.i			= 7;
	WAITBAR.k			= 0;
	WAITBAR.kmax		= size(map_objects_all,1);
	WAITBAR.t0_phase	= clock;
	
	% Cut objects:
	for i=1:size(map_objects_all,1)
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			WAITBAR.k	= i;
			x				= WAITBAR.x0(WAITBAR.i)+WAITBAR.dx(WAITBAR.i)*WAITBAR.k/WAITBAR.kmax;
			set(GV_H.patch_waitbar,'XData',[0 x x 0]);
			set(GV_H.text_waitbar,'String',...
				sprintf('Simplify map: Change resolution of lines and areas %g/%g',...
				i,size(map_objects_all,1)));
			drawnow;
		end
		imapobj		= map_objects_all(i,1);
		rpoly			= map_objects_all(i,2);
		if    strcmp(MAP_OBJECTS(imapobj,1).disp,'line')||...
				strcmp(MAP_OBJECTS(imapobj,1).disp,'area')
			MAP_OBJECTS(imapobj,1).h(rpoly).Shape	=  changeresolution_poly(...
				MAP_OBJECTS(imapobj,1).h(rpoly).Shape,...
				GV.plotosmdata_simplify.dmax_changeresolution,...
				GV.plotosmdata_simplify.dmin_changeresolution,...
				GV.plotosmdata_simplify.nmin_changeresolution);
		end
	end
	
	% Execution time of the current phase:
	WAITBAR.dt(WAITBAR.i)	= etime(clock,WAITBAR.t0_phase);
	
	%------------------------------------------------------------------------------------------------------------------
	% Last steps before calculation of obj_union_equalcolors:
	%------------------------------------------------------------------------------------------------------------------
	
	% Waitbar:
	if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
		WAITBAR.t1	= clock;
		set(GV_H.text_waitbar,'String',sprintf('Simplify map: last steps ...'));
		drawnow;
	end
	
	% Testplots:
	colno_v	= unique(map_objects_all(:,5));
	for icol=1:length(colno_v)
		colno		= colno_v(icol);
		if (colno>0)&&(any(colno==GV.colno_testplot_simplify_v))
			poly_allobj_icol	= polyshape();
			for i_1=1:size(map_objects_all,1)
				imapobj_1	= map_objects_all(i_1,1);
				rpoly_1		= map_objects_all(i_1,2);
				colno_1		= map_objects_all(i_1,5);
				if colno==colno_1
					poly_allobj_icol	= union(poly_allobj_icol,...
						MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...
						'KeepCollinearPoints',false);
				end
			end
			hplot_tpsimplify(icol,2)	= plot(ha_tpar(icol,1),poly_allobj_icol,...
				'EdgeColor','k','EdgeAlpha',tp_EdgeAlpha,...
				'FaceColor','g','FaceAlpha',tp_FaceAlpha);
			legend(ha_tpar(icol,1),hplot_tpsimplify(icol,:),legend_str);
			setbreakpoint=1;
		end
	end
	
	% Delete empty polygons:
	imapobj_delete	= false(size(MAP_OBJECTS,1),1);
	imapobj_v		= unique(map_objects_all(:,1));
	for i_imapobj_v=1:size(imapobj_v,1)
		imapobj		= imapobj_v(i_imapobj_v);
		i_delete	= false(size(MAP_OBJECTS(imapobj,1).h,1),1);
		for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
			if numboundaries(MAP_OBJECTS(imapobj,1).h(i,1).Shape)==0
				i_delete(i,1)	= true;
			end
		end
		if any(i_delete)
			if isequal(i_delete,true(size(MAP_OBJECTS(imapobj,1).h)))
				% The whole element MAP_OBJECTS(imapobj,1).h is empty:
				imapobj_delete(imapobj,1)	= true;
			end
			
			% Delete source data:
			% - The source plots are made visible, if the corresponding text or symbol is selected.
			%   This makes it easier to move the texts and symbols to the right place when editing the map.
			% - Test if there are plot objects that use the same source plots (the do not delete them)
			%   (maybe not necessary)
			sourceplot_delete		= [];
			sourceplot_notdel		= [];
			for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
				if ishandle(MAP_OBJECTS(imapobj,1).h(i,1))
					if isfield(MAP_OBJECTS(imapobj,1).h(i,1).UserData,'source')
						for ksource=1:size(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source,1)
							if ishandle(MAP_OBJECTS(imapobj,1).h(i,1).UserData.source(ksource,1).h)
								if i_delete(i,1)
									% Delete this element:
									sourceplot_delete(end+1,1).h	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.source(ksource,1).h;
								else
									% Do not delete this element:
									sourceplot_notdel(end+1,1).h	= MAP_OBJECTS(imapobj,1).h(i,1).UserData.source(ksource,1).h;
								end
							end
						end
					end
				end
			end
			for i1=1:size(sourceplot_delete,1)
				delete_i1	= true;
				for i2=1:size(sourceplot_notdel,1)
					if isequal(sourceplot_delete(i1,1).h,sourceplot_notdel(i2,1).h)
						delete_i1	= false;
						break
					end
				end
				if delete_i1
					delete(sourceplot_delete(i1,1).h);
				end
			end
			
			% Delete the plot objects:
			delete(MAP_OBJECTS(imapobj,1).h(i_delete));
			
			% Delete the object handles in MAP_OBJECTS(imapobj,1).h:
			MAP_OBJECTS(imapobj,1).h(i_delete)	= [];
			
		end
	end
	% Delete empty lines in MAP_OBJECTS:
	MAP_OBJECTS(imapobj_delete,:)	= [];
	% Reset the "modified"-flag (all objects have been modified) and update the center point:
	for imapobj=1:size(MAP_OBJECTS,1)
		MAP_OBJECTS(imapobj,1).mod	= false;
		[x,y]								= map_objects_center(imapobj);
		MAP_OBJECTS(imapobj,1).x	= x;
		MAP_OBJECTS(imapobj,1).y	= y;
	end
	% Update ud.imapobj:
	for imapobj=1:size(MAP_OBJECTS,1)
		for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
			MAP_OBJECTS(imapobj,1).h(i,1).UserData.imapobj	= imapobj;
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Calculation of
	% -	PRINTDATA.obj_union_equalcolors: preparation of the "cutting into pieces"
	%------------------------------------------------------------------------------------------------------------------
	
	% Create united equal colors plot objects:
	drawnow;
	create_unitedcolors(...
		0,...				% userconfirmation
		1,...				% calc_uec
		0,...				% reset_uec
		0);				% createplot_colno
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Last steps:
	%------------------------------------------------------------------------------------------------------------------
	
	% Create/modify legend: already in create_unitedcolors
	% create_legend_mapfigure;
	
	% Update MAP_OBJECTS_TABLE: already in create_unitedcolors
	% display_map_objects;
	
	% Execution time:
	t_end_statebusy					= clock;
	dt_statebusy						= etime(t_end_statebusy,t_start_statebusy);
	dt_statebusy_str					= dt_string(dt_statebusy);
	if dt_statebusy>GV.exec_time.plotosmdata_simplify.dt
		GV.exec_time.plotosmdata_simplify.name		= APP.MapEdit_SimplifyMap_Menu.Text;
		GV.exec_time.plotosmdata_simplify.t_start	= t_start_statebusy;
		GV.exec_time.plotosmdata_simplify.t_end	= t_end_statebusy;
		GV.exec_time.plotosmdata_simplify.dt		= dt_statebusy;
		GV.exec_time.plotosmdata_simplify.dt_str	= dt_statebusy_str;
	end
	fprintf(1,'Execution time (h:m:s): %s\n',dt_statebusy_str);
	
	% Autosave:
	filename_add			= ' - after simplify map';
	[map_filename,~,~]	= filenames_savefiles(filename_add);
	set(GV_H.text_waitbar,'String',sprintf('Autosave "%s"',map_filename));
	save_project(0,filename_add);
	
	% Reset waitbar:
	if ~isempty(APP)
		set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
		set(GV_H.text_waitbar,'String','');
		drawnow;
	end
	
	% Display state:
	display_on_gui('state',...
		sprintf('%s done (%s).',display_on_gui_str,dt_string(etime(clock,t_start_statebusy))),...
		'notbusy','replace');
	
catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
% create_deletemask:
%------------------------------------------------------------------------------------------------------------------
function poly_mask=create_deletemask(colno,map_objects_all,tol)
% poly_mask: all objects of the same color that will be deleted.

global MAP_OBJECTS

try
	
	poly_allobj_icol_v	= polyshape();
	ipoly						= 0;
	for i_1=1:size(map_objects_all,1)
		imapobj_1			= map_objects_all(i_1,1);
		rpoly_1				= map_objects_all(i_1,2);
		colno_1				= map_objects_all(i_1,5);
		isforeground_1		= map_objects_all(i_1,7);
		if colno==colno_1
			
			if isforeground_1==0
				ipoly			= ipoly+1;
				poly_allobj_icol_v(ipoly,1)	= MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape;
			end
			
			% 		if isforeground_1==0
			% 			poly_allobj_icol	= union(poly_allobj_icol,...^
			% 				MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...
			% 				'KeepCollinearPoints',false);
			% 		end
			
			% 		poly_allobj_icol	= union(poly_allobj_icol,...^
			% 			MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...
			% 			'KeepCollinearPoints',true);
			
			% 		poly_imapobj1_rpoly1		= MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape;
			% 		poly_allobj_icol			= union(poly_allobj_icol,...^
			% 			poly_imapobj1_rpoly1,...
			% 			'KeepCollinearPoints',false);
			
			% original: 312x / 281s
			% 		poly_allobj_icol	= union(poly_allobj_icol,...^
			% 			MAP_OBJECTS(imapobj_1,1).h(rpoly_1,1).Shape,...
			% 			'KeepCollinearPoints',false);
		end
	end
	poly_allobj_icol		= union(poly_allobj_icol_v,'KeepCollinearPoints',false);
	% Delete narrow or small parts of the mask:
	poly_allobj_icol_red	= plotosmdata_simplify_moveoutline(...
		colno,...
		poly_allobj_icol,...
		'general',...
		0);							% testplot
	% Increase the size of poly_allobj_icol_red by tol:
	poly_allobj_icol_red		= polybuffer(poly_allobj_icol_red,...
		tol,'JointType','miter','MiterLimit',2);
	% poly_mask: all parts to be deleted:
	poly_mask					= subtract(poly_allobj_icol,poly_allobj_icol_red,...
		'KeepCollinearPoints',false);
	% Increase the size of the mask by 2*tol (so the mask is greater than the objects by tol):
	poly_mask					= polybuffer(poly_mask,...
		2*tol,'JointType','miter','MiterLimit',2);
	
catch ME
	errormessage('',ME);
end

