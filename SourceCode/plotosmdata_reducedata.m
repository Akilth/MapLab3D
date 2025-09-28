function plotosmdata_reducedata(msg)
% Deletes lines in PLOTDATA, that are too short.

global PP GV PLOTDATA WAITBAR GV_H

try

	if nargin==0
		msg	= '';
	end

	% Test:
	testplot_show_k	= 0;		% Show indices k
	testout				= 0;		% Test output in command window
	if testout==1
		fprintf(1,'%s\n',GV.log.create_map.line_str);
		fprintf(1,'Reduce plot data:\n');
	end

	% Testplot preparation:
	m_tp_subplot						= 3;
	n_tp_subplot						= 2;
	objno_testplot_simplify_v		= [];
	colno_testplot_simplify_v		= [];
	for k_tp=1:length(GV.iobj_testplot_simplify_v)
		iobj	= GV.iobj_testplot_simplify_v(k_tp);
		if (iobj>=1)&&(iobj<=length(PP.obj))&&(iobj==round(iobj))
			objno_testplot_simplify_v	= [objno_testplot_simplify_v;iobj                       ];
			colno_testplot_simplify_v	= [colno_testplot_simplify_v;PP.obj(iobj,1).color_no_bgd];
		end
	end
	objno_testplot_simplify_v	= unique(objno_testplot_simplify_v);
	colno_testplot_simplify_v	= unique(colno_testplot_simplify_v);
	if ~isempty((objno_testplot_simplify_v))||~isempty(colno_testplot_simplify_v)
		for k_tp_obj=1:length(objno_testplot_simplify_v)
			iobj	= objno_testplot_simplify_v(k_tp_obj);
			if ~isempty(PLOTDATA.obj(iobj,1).connways.lines)
				% or: if (PP.obj(iobj).display~=0)&&(PP.obj(iobj).display_as_line~=0)
				hf_tpar=149560000+iobj;
				figure(hf_tpar);
				figure_theme(hf_tpar,'set',[],'light');
				clf(hf_tpar,'reset');
				figure_theme(hf_tpar,'set',[],'light');
				set(hf_tpar,'Tag','maplab3d_figure');
				set(hf_tpar,'NumberTitle','off');
				set(hf_tpar,'Name',sprintf('ObjNo=%g',iobj));
				ha_tp(k_tp_obj,1)=subplot(m_tp_subplot,n_tp_subplot,1);
				ha_tp(k_tp_obj,2)=subplot(m_tp_subplot,n_tp_subplot,2);
				ha_tp(k_tp_obj,3)=subplot(m_tp_subplot,n_tp_subplot,3);
				ha_tp(k_tp_obj,4)=subplot(m_tp_subplot,n_tp_subplot,4);
				ha_tp(k_tp_obj,5)=subplot(m_tp_subplot,n_tp_subplot,5);
				ha_tp(k_tp_obj,6)=subplot(m_tp_subplot,n_tp_subplot,6);
				hold(ha_tp,'on');
				xlabel(ha_tp,'x / mm');
				ylabel(ha_tp,'y / mm');
			else
				objno_testplot_simplify_v(k_tp_obj)		= [];
			end
		end
	end

	% Plausibility check:
	for iobj=1:size(PLOTDATA.obj,1)
		lino_iobj_v	= zeros(0,1);
		if ~isempty(PLOTDATA.obj(iobj,1).connways)
			for k=1:size(PLOTDATA.obj(iobj,1).connways.lines,1)
				if any(PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,3)~=iobj)
					errormessage;
				end
				lino_currentline_v	= unique(PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,4));
				for ilino=1:size(lino_currentline_v,1)
					if any(lino_iobj_v==lino_currentline_v(ilino))
						errormessage;
					end
				end
				lino_iobj_v	= [lino_iobj_v;lino_currentline_v];
			end
		end
	end


	%******************************************************************************************************************
	% 1) Connect all lines of different objects but with the same color:
	%    Connect only lines with matching start- and end-points.
	%    PLOTDATA.col(icno,1).colno			background color numbers
	%    PLOTDATA.col(icno,1).connways		connected lines
	%******************************************************************************************************************

	PLOTDATA.col		= [];
	PLOTDATA.colno_v	= sort(PLOTDATA.colno_v);
	for icno=1:size(PLOTDATA.colno_v,1)
		colno										= PLOTDATA.colno_v(icno,1);
		PLOTDATA.col(icno,1).colno			= colno;
		if colno>0
			PLOTDATA.col(icno,1).colprio	= PP.color(colno,1).prio;
		else
			% If an object has the color number 0, it receives the color of the object below.
			PLOTDATA.col(icno,1).colprio	= -1;
		end
		PLOTDATA.col(icno,1).connways		= connect_ways([]);
		for iobj=1:size(PLOTDATA.obj,1)
			% Waitbar:
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				if ~isempty(msg)
					WAITBAR.t1	= clock;
					set(GV_H.text_waitbar,'String',...
						sprintf(...
						'%s Connect lines with the same color and matching start- and end-points: ColNo %g (%g/%g): %g/%g',...
						msg,...
						colno,icno,size(PLOTDATA.colno_v,1),...
						iobj,size(PLOTDATA.obj,1)));
					drawnow;
				end
			end
			if PLOTDATA.obj(iobj,1).colno_bgd==colno
				% plotosmdata_reducedata_line110_iobj	= iobj
				% plotosmdata_reducedata_line110_icno	= icno
				% global test1 test2
				% test1	= PLOTDATA.obj(iobj,1).connways;
				% test2	= PLOTDATA.col(icno,1).connways;
				% Merge two structures connways
				PLOTDATA.col(icno,1).connways=connect_ways(...
					PLOTDATA.obj(iobj,1).connways,...		% connways
					PLOTDATA.col(icno,1).connways);			% connways_merge
			end
		end
	end

	% Testplots: Before reducing data:
	for k_tp_obj=1:length(objno_testplot_simplify_v)
		iobj	= objno_testplot_simplify_v(k_tp_obj);
		colno	= PP.obj(iobj).color_no_bgd;

		% Testplot of only object number iobj:
		if ~isempty(PLOTDATA.obj(iobj,1).connways)
			for k=1:size(PLOTDATA.obj(iobj,1).connways.lines,1)
				plot(ha_tp(k_tp_obj,1),...
					PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,1),...
					PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,2))
				if testplot_show_k~=0
					text(ha_tp(k_tp_obj,1),...
						PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(1,1),...
						PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(1,2),...
						sprintf('%1.0f',k),'FontSize',8);
				end
			end
			axis(ha_tp(k_tp_obj,1),'equal');
			title(ha_tp(k_tp_obj,1),sprintf(['iobj=%g, connected ways,\n',...
				'before the data reduction\n',...
				'(%s)'],...
				iobj,PP.obj(iobj,1).description),'Interpreter','none');
		end
		dmax2lines	= PP.obj(iobj).reduce_nodes.dmax2lines_m/PP.project.scale*1000;
		labels		= cell(1,0);
		subset		= [];
		label_text	= false;
		label_symb	= false;
		if dmax2lines>=0
			for iteqt=1:size(PLOTDATA.obj(iobj,1).text,1)
				if ~isempty(PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints)
					ht	= plot(ha_tp(k_tp_obj,1),...
						PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints(:,1),...
						PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints(:,2),...
						'Color','b','Marker','+','MarkerSize',8,'LineStyle','none');
					if ~label_text
						labels{1,end+1}	= 'Texts';
						subset(1,end+1)	= ht;
						label_text			= true;
					end
				end
			end
			for iseqt=1:size(PLOTDATA.obj(iobj,1).symb,1)
				if ~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints)
					hs	= plot(ha_tp(k_tp_obj,1),...
						PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints(:,1),...
						PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints(:,2),...
						'Color','b','Marker','x','MarkerSize',8,'LineStyle','none');
					if ~label_symb
						labels{1,end+1}	= 'Symbols';
						subset(1,end+1)	= hs;
						label_symb			= true;
					end
				end
			end
			legend(ha_tp(k_tp_obj,1),subset,labels);
		end

		% Testplot of all line objects of the same color as object number iobj:
		for icno=1:size(PLOTDATA.colno_v,1)
			if isequal(PLOTDATA.colno_v(icno,1),colno)
				if ~isempty(PLOTDATA.col(icno,1).connways)
					for k=1:size(PLOTDATA.col(icno,1).connways.lines,1)
						plot(ha_tp(k_tp_obj,2),...
							PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,1),...
							PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,2))
						if testplot_show_k~=0
							text(ha_tp(k_tp_obj,2),...
								PLOTDATA.col(icno,1).connways.lines(k,1).xy(1,1),...
								PLOTDATA.col(icno,1).connways.lines(k,1).xy(1,2),...
								sprintf('%1.0f',k),'FontSize',8);
						end
					end
					axis(ha_tp(k_tp_obj,2),'equal');
					if colno~=0
						description	= PP.color(colno,1).description;
					else
						description	= '';
					end
					title(ha_tp(k_tp_obj,2),sprintf(['colno=%g, connected ways,\n',...
						'before the data reduction\n',...
						'(%s)'],...
						colno,description),'Interpreter','none');
				end
			end
		end

	end


	%******************************************************************************************************************
	% 2) Delete unbranched lines in PLOTDATA, that are too short:
	%    PLOTDATA.col(icno,1).mindiag_unbranched
	%    PLOTDATA.col(icno,1).minlength_unbranched
	%******************************************************************************************************************

	obj_delete	= [];
	for iobj=1:size(PLOTDATA.obj,1)
		obj_delete(iobj,1).lino	= [];
	end
	if testout==1
		fprintf(1,'Deleting unbranched lines in PLOTDATA.col(icno,1).connways.lines(k,1).xy:\n');
		fprintf(1,'  icno      k     x(1)     y(1)   diag_mm   length_mm   delete   colno   description\n');
	end
	for icno=1:size(PLOTDATA.colno_v,1)
		colno		= PLOTDATA.colno_v(icno,1);
		k_delete	= [];
		if ~isempty(PLOTDATA.col(icno,1).connways)
			% If there exist connected lines in PLOTDATA.col(icno,1).connways:
			for k=1:size(PLOTDATA.col(icno,1).connways.lines,1)
				% Waitbar:
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					if ~isempty(msg)
						WAITBAR.t1	= clock;
						set(GV_H.text_waitbar,'String',...
							sprintf('%s Delete unbranched lines in PLOTDATA, that are too short: ColNo %g%(g/%g): %g/%g',...
							msg,...
							colno,icno,size(PLOTDATA.colno_v,1),...
							k,size(PLOTDATA.col(icno,1).connways.lines,1)));
						drawnow;
					end
				end
				PLOTDATA.col(icno,1).mindiag_unbranched		= 1e6;
				PLOTDATA.col(icno,1).minlength_unbranched		= 1e6;
				iobj_v			= unique(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,3));
				iobj_v			= iobj_v(~isnan(iobj_v));
				for i=1:length(iobj_v)
					iobj			= iobj_v(i);
					PLOTDATA.col(icno,1).mindiag_unbranched	= min(...
						PLOTDATA.col(icno,1).mindiag_unbranched  ,PP.obj(iobj).reduce_lines.mindiag_unbranched);
					PLOTDATA.col(icno,1).minlength_unbranched	= min(...
						PLOTDATA.col(icno,1).minlength_unbranched,PP.obj(iobj).reduce_lines.minlength_unbranched);
				end
				dx_mm		= ...
					max(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,1)) - ...
					min(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,1));
				dy_mm		= ...
					max(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,2)) - ...
					min(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,2));
				diag_mm	= sqrt(dx_mm^2+dy_mm^2);
				imax	= size(PLOTDATA.col(icno,1).connways.lines(k,1).xy,1);
				i		= 1:(imax-1);
				ip1	= 2:imax;
				length_i_mm	= sqrt((...
					PLOTDATA.col(icno,1).connways.lines(k,1).xy(ip1,1)-...
					PLOTDATA.col(icno,1).connways.lines(k,1).xy(i  ,1)     ).^2+(...
					PLOTDATA.col(icno,1).connways.lines(k,1).xy(ip1,2)-...
					PLOTDATA.col(icno,1).connways.lines(k,1).xy(i  ,2)     ).^2     );
				length_mm	= sum(length_i_mm(~isnan(length_i_mm)));
				if    (diag_mm  <PLOTDATA.col(icno,1).mindiag_unbranched  )||...
						(length_mm<PLOTDATA.col(icno,1).minlength_unbranched)
					delete_str	= 'X';
					k_delete	= [k_delete;k];
					for i=1:length(iobj_v)
						iobj		= iobj_v(i);
						% Different object numbers iobj can have the same line numbers (.. .xy(:,4)).
						% Line numbers PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,4) to delete:
						r_iobj	= (PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,3)==iobj);
						obj_delete(iobj,1).lino	= unique([...
							obj_delete(iobj,1).lino;...
							PLOTDATA.col(icno,1).connways.lines(k,1).xy(r_iobj,4)]);
						obj_delete(iobj,1).lino	= obj_delete(iobj,1).lino(~isnan(obj_delete(iobj,1).lino));
					end
				else
					delete_str	= ' ';
				end
				if testout==1
					fprintf(1,'   % 3.0f',icno);
					fprintf(1,'   % 4.0f',k);
					fprintf(1,'   % 6.1f',PLOTDATA.col(icno,1).connways.lines(k,1).xy(1,1));
					fprintf(1,'   % 6.1f',PLOTDATA.col(icno,1).connways.lines(k,1).xy(1,2));
					fprintf(1,'    % 6.1f',diag_mm);
					fprintf(1,'      % 6.1f',length_mm);
					fprintf(1,'        %s',delete_str);
					fprintf(1,'     % 3.0f',colno);
					if colno~=0
						description	= PP.color(colno,1).description;
					else
						description	= '';
					end
					fprintf(1,'   %s\n',description);
				end
			end
			% Delete lines in PLOTDATA.col(icno,1).connways.lines:
			PLOTDATA.col(icno,1).connways.lines(k_delete,:)				= [];
			PLOTDATA.col(icno,1).connways.lines_isouter(k_delete,:)	= [];
			PLOTDATA.col(icno,1).connways.lines_relid(k_delete,:)		= [];
			PLOTDATA.col(icno,1).connways.xy_start(k_delete,:)			= [];
			PLOTDATA.col(icno,1).connways.xy_end(k_delete,:)			= [];
		end
	end
	% Delete lines in PLOTDATA.obj(iobj,1).connways.lines:
	for iobj=1:size(PLOTDATA.obj,1)
		if ~isempty(obj_delete(iobj,1).lino)&&~isempty(PLOTDATA.obj(iobj,1).connways)
			k_delete	= [];
			for k=1:size(PLOTDATA.obj(iobj,1).connways.lines,1)
				for i=1:size(obj_delete(iobj,1).lino,1)
					if any(...
							(PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,3)==iobj                          )&...	% unnötig !!!
							(PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,4)==obj_delete(iobj,1).lino(i,1))    )
						k_delete	= [k_delete;k];
						break
					end
				end
			end
			PLOTDATA.obj(iobj,1).connways.lines(k_delete,:)				= [];
			PLOTDATA.obj(iobj,1).connways.lines_isouter(k_delete,:)	= [];
			PLOTDATA.obj(iobj,1).connways.lines_relid(k_delete,:)		= [];
			PLOTDATA.obj(iobj,1).connways.xy_start(k_delete,:)			= [];
			PLOTDATA.obj(iobj,1).connways.xy_end(k_delete,:)			= [];
		end
	end


	% Testplots: after deleting unbranched lines:
	for k_tp_obj=1:length(objno_testplot_simplify_v)
		iobj	= objno_testplot_simplify_v(k_tp_obj);
		colno	= PP.obj(iobj).color_no_bgd;

		% Testplot of only object number iobj:
		if ~isempty(PLOTDATA.obj(iobj,1).connways)
			for k=1:size(PLOTDATA.obj(iobj,1).connways.lines,1)
				plot(ha_tp(k_tp_obj,3),...
					PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,1),...
					PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,2))
				if testplot_show_k~=0
					text(ha_tp(k_tp_obj,3),...
						PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(1,1),...
						PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(1,2),...
						sprintf('%1.0f',k),'FontSize',8);
				end
			end
			axis(ha_tp(k_tp_obj,3),'equal');
			title(ha_tp(k_tp_obj,3),sprintf(['after deleting unbranched lines\n',...
				'mindiag_unbranched=%gmm\n',...
				'minlength_unbranched=%gmm'],...
				PP.obj(iobj).reduce_lines.mindiag_unbranched,...
				PP.obj(iobj).reduce_lines.minlength_unbranched),'Interpreter','none');
		end
		dmax2lines	= PP.obj(iobj).reduce_nodes.dmax2lines_m/PP.project.scale*1000;
		labels		= cell(1,0);
		subset		= [];
		label_text	= false;
		label_symb	= false;
		if dmax2lines>=0
			for iteqt=1:size(PLOTDATA.obj(iobj,1).text,1)
				if ~isempty(PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints)
					ht	= plot(ha_tp(k_tp_obj,3),...
						PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints(:,1),...
						PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints(:,2),...
						'Color','b','Marker','+','MarkerSize',8,'LineStyle','none');
					if ~label_text
						labels{1,end+1}	= 'Texts';
						subset(1,end+1)	= ht;
						label_text			= true;
					end
				end
			end
			for iseqt=1:size(PLOTDATA.obj(iobj,1).symb,1)
				if ~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints)
					hs	= plot(ha_tp(k_tp_obj,3),...
						PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints(:,1),...
						PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints(:,2),...
						'Color','b','Marker','x','MarkerSize',8,'LineStyle','none');
					if ~label_symb
						labels{1,end+1}	= 'Symbols';
						subset(1,end+1)	= hs;
						label_symb			= true;
					end
				end
			end
			legend(ha_tp(k_tp_obj,3),subset,labels);
		end

		% Testplot of all line objects of the same color as object number iobj:
		for icno=1:size(PLOTDATA.colno_v,1)
			if isequal(PLOTDATA.colno_v(icno,1),colno)
				if ~isempty(PLOTDATA.col(icno,1).connways)
					for k=1:size(PLOTDATA.col(icno,1).connways.lines,1)
						plot(ha_tp(k_tp_obj,4),...
							PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,1),...
							PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,2))
						if testplot_show_k~=0
							text(ha_tp(k_tp_obj,4),...
								PLOTDATA.col(icno,1).connways.lines(k,1).xy(1,1),...
								PLOTDATA.col(icno,1).connways.lines(k,1).xy(1,2),...
								sprintf('%1.0f',k),'FontSize',8);
						end
					end
					axis(ha_tp(k_tp_obj,4),'equal');
					title(ha_tp(k_tp_obj,4),sprintf(['after deleting unbranched lines\n',...
						'mindiag_unbranched=%gmm\n',...
						'minlength_unbranched=%gmm'],...
						PLOTDATA.col(icno,1).mindiag_unbranched,...
						PLOTDATA.col(icno,1).minlength_unbranched),'Interpreter','none');
				end
			end
		end

	end


	%******************************************************************************************************************
	% 3) Connect all lines of different objects but with the same background color:
	%    Connect touching lines, divided by nans.
	%******************************************************************************************************************

	method	= 1;
	switch method

		case 1
			% Create a circle around the start and end point of each line
			% Only overlap of the start and end point will be detected.
			testplot_3		= 0;
			for icno=1:size(PLOTDATA.colno_v,1)
				colno		= PLOTDATA.colno_v(icno,1);
				% Minimum linewidth of all lines of this color:
				PLOTDATA.col(icno,1).minlinewidth	= 1e6;
				for iobj=1:size(PLOTDATA.obj,1)
					if isequal(PLOTDATA.obj(iobj,1).colno_bgd,PLOTDATA.colno_v(icno))&&...
							~isempty(PLOTDATA.obj(iobj,1).linewidth)
						PLOTDATA.col(icno,1).minlinewidth	= min(...
							PLOTDATA.col(icno,1).minlinewidth,...
							PLOTDATA.obj(iobj,1).linewidth);
					end
				end
				if isequal(PLOTDATA.col(icno,1).minlinewidth,1e6)
					PLOTDATA.col(icno,1).minlinewidth	= 0;
				end
				if ~isempty(PLOTDATA.col(icno,1).connways)
					k1	= size(PLOTDATA.col(icno,1).connways.lines,1);
					phi_circle_v		= 0:(2*pi/12):(2*pi);
					x_circle_v			= cos(phi_circle_v);
					y_circle_v			= sin(phi_circle_v);
					for k=1:k1
						% The linewidth in PLOTDATA.col(icno,1).connways.lines(k1,1).xy can differ,
						% so the calculation of the distance for testing for overlap is not exactly possible.
						% It is better to loose a short connected line than to keep a short unconnected line:
						% Use the minimum linewidth:
						min_linewidth	= min(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,5));
						% The distance should be at least PP.general.load_osm_data.dmin_ways
						linewidth		= max(1.05*PP.general.load_osm_data.dmin_ways,min_linewidth*0.8);
						% Creating circles of the radius ci_r:
						ci_r				= linewidth/2+PLOTDATA.col(icno,1).minlinewidth/2;
						% Circle around the start point:
						ci_sp(k,1).x	= x_circle_v*ci_r+PLOTDATA.col(icno,1).connways.lines(k,1).xy(1,1);
						ci_sp(k,1).y	= y_circle_v*ci_r+PLOTDATA.col(icno,1).connways.lines(k,1).xy(1,2);
						% Circle around the end point:
						ci_ep(k,1).x	= x_circle_v*ci_r+PLOTDATA.col(icno,1).connways.lines(k,1).xy(end,1);
						ci_ep(k,1).y	= y_circle_v*ci_r+PLOTDATA.col(icno,1).connways.lines(k,1).xy(end,2);
						% Testplot:
						if testplot_3~=0
							for k_tp_obj=1:length(objno_testplot_simplify_v)
								iobj_k_tp_obj	= objno_testplot_simplify_v(k_tp_obj);
								colno_k_tp_obj	= PP.obj(iobj_k_tp_obj).color_no_bgd;
								if colno_k_tp_obj==PLOTDATA.colno_v(icno,1)
									plot(ha_tp(k_tp_obj,4),ci_sp(k,1).x,ci_sp(k,1).y,'c')
									plot(ha_tp(k_tp_obj,4),ci_ep(k,1).x,ci_ep(k,1).y,'m')
								end
							end
						end
						% Test:
						if colno==14
							setbreakpoint	= 1;
							if k==36
								setbreakpoint	= 1;
							end
						end
					end
					% Connect lines that overlap:
					while k1>=2
						% Waitbar:
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							if ~isempty(msg)
								WAITBAR.t1	= clock;
								set(GV_H.text_waitbar,'String',...
									sprintf('%s Connect touching lines with the same color: ColNo %g (%g/%g): %g',...
									msg,...
									colno,icno,size(PLOTDATA.colno_v,1),...
									k1));
								drawnow;
							end
						end
						if testplot_3~=0
							xytest1	= [-41.6545 -3.5157];
							ktest1	= find(...
								(abs(PLOTDATA.col(icno,1).connways.lines(k1,1).xy(:,1)-xytest1(1,1))<1e-3)&...
								(abs(PLOTDATA.col(icno,1).connways.lines(k1,1).xy(:,2)-xytest1(1,2))<1e-3));
							if ~isempty(ktest1)
								fprintf(1,'1) k1=%g, ktest1=%s\n',k1,num2str(ktest1));
								figure(758923);
								clf(758923,'reset');
								set(758923,'Tag','maplab3d_figure');
								hatest1=axes;
								hold(hatest1,'on');
								plot(hatest1,...
									PLOTDATA.col(icno,1).connways.lines(k1,1).xy(:,1),...
									PLOTDATA.col(icno,1).connways.lines(k1,1).xy(:,2));
								set_breakpoint	= 1;
							end
						end
						for k2=1:size(PLOTDATA.col(icno,1).connways.lines,1)
							if k2~=k1
								if testplot_3~=0
									xytest2	= [-71.6903 15.4101];
									ktest2	= find(...
										(abs(PLOTDATA.col(icno,1).connways.lines(k2,1).xy(:,1)-xytest2(1,1))<1e-3)&...
										(abs(PLOTDATA.col(icno,1).connways.lines(k2,1).xy(:,2)-xytest2(1,2))<1e-3));
									if ~isempty(ktest2)
										fprintf(1,'2) k1=%g, k2=%g, ktest1=%s (%g), ktest2=%s (%g)\n',...
											k1,k2,...
											num2str(ktest1),size(PLOTDATA.col(icno,1).connways.lines(k1,1).xy,1),...
											num2str(ktest2),size(PLOTDATA.col(icno,1).connways.lines(k2,1).xy,1));
										set_breakpoint	= 1;
									end
									if ~isempty(ktest1)&&~isempty(ktest2)
										fprintf(1,'3) k1=%g, k2=%g, ktest1=%s (%g), ktest2=%s (%g)\n',...
											k1,k2,...
											num2str(ktest1),size(PLOTDATA.col(icno,1).connways.lines(k1,1).xy,1),...
											num2str(ktest2),size(PLOTDATA.col(icno,1).connways.lines(k2,1).xy,1));
										set_breakpoint	= 1;
									end
								end
								[xi,~] = polyxpoly(...
									ci_sp(k1,1).x,...
									ci_sp(k1,1).y,...
									PLOTDATA.col(icno,1).connways.lines(k2,1).xy(:,1),...
									PLOTDATA.col(icno,1).connways.lines(k2,1).xy(:,2));
								if ~isempty(xi)
									% The start point of line k1 overlaps line k2:
									% Add line k1 to line k2:
									PLOTDATA.col(icno,1).connways.lines(k2,1).xy	= [...
										PLOTDATA.col(icno,1).connways.lines(k2,1).xy;...
										nan(1,size(PLOTDATA.col(icno,1).connways.lines(k2,1).xy,2));...
										PLOTDATA.col(icno,1).connways.lines(k1,1).xy];
									% The end point of line k2 has changed:
									ci_ep(k2,1)												= ci_ep(k1,1);
									% Testplot:
									if testplot_3~=0
										for k_tp_obj=1:length(objno_testplot_simplify_v)
											iobj_k_tp_obj	= objno_testplot_simplify_v(k_tp_obj);
											colno_k_tp_obj	= PP.obj(iobj_k_tp_obj).color_no_bgd;
											if colno_k_tp_obj==PLOTDATA.colno_v(icno,1)
												plot(ha_tp(k_tp_obj,4),...
													PLOTDATA.col(icno,1).connways.lines(k1,1).xy(1,1),...
													PLOTDATA.col(icno,1).connways.lines(k1,1).xy(1,2),...
													'.c','MarkerSize',15);
											end
										end
									end
									% Delete line k1:
									PLOTDATA.col(icno,1).connways.lines(k1,:)				= [];
									PLOTDATA.col(icno,1).connways.lines_isouter(k1,:)	= [];
									PLOTDATA.col(icno,1).connways.lines_relid(k1,:)		= [];
									PLOTDATA.col(icno,1).connways.xy_start(k1,:)			= [];
									PLOTDATA.col(icno,1).connways.xy_end(k1,:)			= [];
									ci_sp(k1,:)														= [];
									ci_ep(k1,:)														= [];
									break
								else
									[xi,~] = polyxpoly(...
										ci_ep(k1,1).x,...
										ci_ep(k1,1).y,...
										PLOTDATA.col(icno,1).connways.lines(k2,1).xy(:,1),...
										PLOTDATA.col(icno,1).connways.lines(k2,1).xy(:,2));
									if ~isempty(xi)
										% The end point of line k1 overlaps line k2:
										% Add line k1 to line k2:
										PLOTDATA.col(icno,1).connways.lines(k2,1).xy	= [...
											PLOTDATA.col(icno,1).connways.lines(k2,1).xy;...
											nan(1,size(PLOTDATA.col(icno,1).connways.lines(k2,1).xy,2));...
											PLOTDATA.col(icno,1).connways.lines(k1,1).xy];
										% The end point of line k2 has changed:
										ci_ep(k2,1)												= ci_ep(k1,1);
										% Testplot:
										if testplot_3~=0
											for k_tp_obj=1:length(objno_testplot_simplify_v)
												iobj_k_tp_obj	= objno_testplot_simplify_v(k_tp_obj);
												colno_k_tp_obj	= PP.obj(iobj_k_tp_obj).color_no_bgd;
												if colno_k_tp_obj==PLOTDATA.colno_v(icno,1)
													plot(ha_tp(k_tp_obj,4),...
														PLOTDATA.col(icno,1).connways.lines(k1,1).xy(end,1),...
														PLOTDATA.col(icno,1).connways.lines(k1,1).xy(end,2),...
														'.m','MarkerSize',15);
												end
											end
										end
										% Delete line k1:
										PLOTDATA.col(icno,1).connways.lines(k1,:)				= [];
										PLOTDATA.col(icno,1).connways.lines_isouter(k1,:)	= [];
										PLOTDATA.col(icno,1).connways.lines_relid(k1,:)		= [];
										PLOTDATA.col(icno,1).connways.xy_start(k1,:)			= [];
										PLOTDATA.col(icno,1).connways.xy_end(k1,:)			= [];
										ci_sp(k1,:)														= [];
										ci_ep(k1,:)														= [];
										break
									end
								end
							end
						end
						k1	= k1-1;
					end
				end
			end

		case 2
			% Convert the lines to polygons for testing for overlap:
			% Every overlap will be detected (not only overlap of the start and end point),
			% but the call of line2poly causes a high execution time.
			for icno=1:size(PLOTDATA.colno_v,1)
				if ~isempty(PLOTDATA.col(icno,1).connways)
					k1	= size(PLOTDATA.col(icno,1).connways.lines,1);
					connways_lines_poly		= polyshape();
					for k=1:k1
						% The linewidth in PLOTDATA.col(icno,1).connways.lines(k1,1).xy can differ,
						% so the calculation of the buffer distance for testing for overlap is not exactly possible.
						% It is better to loose a short connected line than to keep a short unconnected line:
						% Use the minimum linewidth:
						min_linewidth	= min(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,5));
						% The buffer distance should be at least PP.general.load_osm_data.dmin_ways
						linewidth		= max(1.05*PP.general.load_osm_data.dmin_ways,min_linewidth*0.8);
						linestyle      = 1;						% style=1: simple line
						linepar{1}		= linewidth;			% line width / mm
						linepar{2}		= 6;						% sampling
						linepar{3}		= 0;						% lifting dz (>0 or <0) / mm
						jointtype		= 'miter';				% 'miter' 'bufferm'
						miterlimit		= 1;
						% Downsampling:
						dmax				= [];
						dmin				= min(1.05*PP.general.load_osm_data.dmin_ways,min_linewidth*0.05);
						nmin				= [];
						[  x_line_downsampled,...
							y_line_downsampled]	= changeresolution_xy(...
							PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,1),...
							PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,2),dmax,dmin,nmin,1);
						% Convert to polygon:
						connways_lines_poly(k,1)	= line2poly(...
							x_line_downsampled,...				% x
							y_line_downsampled,...				% y
							linepar,...								% par
							linestyle,...							% style
							iobj,...									% iobj
							{'map object'},...					% obj_purpose
							jointtype,...							% jointtype
							miterlimit);							% miterlimit
						% Downsampling:
						connways_lines_poly(k,1)	= changeresolution_poly(connways_lines_poly(k,1),dmax,dmin,nmin)			;
					end
					% Connect lines that overlap:
					while k1>=2
						for k2=1:(k1-1)
							if overlaps(connways_lines_poly(k1,1),connways_lines_poly(k2,1))
								% Add line k1 to line k2:
								PLOTDATA.col(icno,1).connways.lines(k2,1).xy	= [...
									PLOTDATA.col(icno,1).connways.lines(k2,1).xy;...
									nan(1,size(PLOTDATA.col(icno,1).connways.lines(k2,1).xy,2));...
									PLOTDATA.col(icno,1).connways.lines(k1,1).xy];
								% Delete line k1:
								PLOTDATA.col(icno,1).connways.lines(k1,:)				= [];
								PLOTDATA.col(icno,1).connways.lines_isouter(k1,:)	= [];
								PLOTDATA.col(icno,1).connways.lines_relid(k1,:)		= [];
								PLOTDATA.col(icno,1).connways.xy_start(k1,:)			= [];
								PLOTDATA.col(icno,1).connways.xy_end(k1,:)			= [];
								% Add polygon k1 to polygon k2:
								connways_lines_poly(k2,1)	= union(connways_lines_poly(k2,1),connways_lines_poly(k1,1),...
									'KeepCollinearPoints',false);
								% Delete polygon k1:
								connways_lines_poly(k1,:)	= [];
								break
							end
						end
						k1	= k1-1;
					end
				end
			end

	end

	%******************************************************************************************************************
	% 4) Delete branched/touching lines in PLOTDATA, that are too short:
	%    PLOTDATA.col(icno,1).mindiag_branched
	%    PLOTDATA.col(icno,1).minlength_branched
	%******************************************************************************************************************

	obj_delete	= [];
	for iobj=1:size(PLOTDATA.obj,1)
		obj_delete(iobj,1).lino	= [];
	end
	if testout==1
		fprintf(1,'Deleting branched lines in PLOTDATA.col(icno,1).connways.lines(k,1).xy:\n');
		fprintf(1,'  icno      k     x(1)     y(1)   diag_mm   length_mm   delete   colno   description\n');
	end
	for icno=1:size(PLOTDATA.colno_v,1)
		colno		= PLOTDATA.colno_v(icno,1);
		k_delete	= [];
		if ~isempty(PLOTDATA.col(icno,1).connways)
			% If there exist connected lines in PLOTDATA.col(icno,1).connways:
			for k=1:size(PLOTDATA.col(icno,1).connways.lines,1)
				% Waitbar:
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					if ~isempty(msg)
						WAITBAR.t1	= clock;
						set(GV_H.text_waitbar,'String',...
							sprintf('%s Delete lines, that are too short: ColNo %g (%g/%g): %g/%g',...
							msg,...
							colno,icno,size(PLOTDATA.colno_v,1),...
							k,size(PLOTDATA.col(icno,1).connways.lines,1)));
						drawnow;
					end
				end
				PLOTDATA.col(icno,1).mindiag_branched			= 1e6;
				PLOTDATA.col(icno,1).minlength_branched		= 1e6;
				iobj_v			= unique(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,3));
				iobj_v			= iobj_v(~isnan(iobj_v));
				for i=1:length(iobj_v)
					iobj			= iobj_v(i);
					PLOTDATA.col(icno,1).mindiag_branched	= min(...
						PLOTDATA.col(icno,1).mindiag_branched  ,PP.obj(iobj).reduce_lines.mindiag_branched);
					PLOTDATA.col(icno,1).minlength_branched	= min(...
						PLOTDATA.col(icno,1).minlength_branched,PP.obj(iobj).reduce_lines.minlength_branched);
				end
				dx_mm		= ...
					max(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,1)) - ...
					min(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,1));
				dy_mm		= ...
					max(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,2)) - ...
					min(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,2));
				diag_mm	= sqrt(dx_mm^2+dy_mm^2);
				imax	= size(PLOTDATA.col(icno,1).connways.lines(k,1).xy,1);
				i		= 1:(imax-1);
				ip1	= 2:imax;
				length_i_mm	= sqrt((...
					PLOTDATA.col(icno,1).connways.lines(k,1).xy(ip1,1)-...
					PLOTDATA.col(icno,1).connways.lines(k,1).xy(i  ,1)     ).^2+(...
					PLOTDATA.col(icno,1).connways.lines(k,1).xy(ip1,2)-...
					PLOTDATA.col(icno,1).connways.lines(k,1).xy(i  ,2)     ).^2     );
				length_mm	= sum(length_i_mm(~isnan(length_i_mm)));
				if    (diag_mm  <PLOTDATA.col(icno,1).mindiag_branched  )||...
						(length_mm<PLOTDATA.col(icno,1).minlength_branched)
					delete_str	= 'X';
					k_delete	= [k_delete;k];
					for i_iobj_v=1:length(iobj_v)
						% Example:
						% column 1: x-values
						% column 2: y-values
						% column 3: iobj: object number (when connecting lines of different objects)
						% column 4: lino: line number   (counted up every time a new way is added)
						% column 5: liwi: line width    (when connecting lines with different widths)
						% PLOTDATA.col(icno,1).connways.lines(k,1).xy =
						%    82.8743   52.2972   31.0000  156.0000    1.0000
						%    82.4777   52.9885   31.0000  156.0000    1.0000
						%    82.1222   53.6863   31.0000  156.0000    1.0000
						%    81.8615   54.2861   31.0000  156.0000    1.0000
						%    81.7544   54.5545   31.0000  155.0000    1.0000
						%    81.4063   55.4807   31.0000  155.0000    1.0000
						%        NaN       NaN       NaN       NaN       NaN
						%    81.4094   54.2989   16.0000   67.0000    1.0000
						%    81.5475   54.4009   16.0000   67.0000    1.0000
						%    81.7544   54.5545   16.0000  137.0000    1.0000
						%    81.4994   54.5176   16.0000  137.0000    1.0000
						%    81.2941   54.4863   16.0000  138.0000    1.0000
						%        NaN       NaN       NaN       NaN       NaN
						%    81.0541   54.1806   16.0000   70.0000    1.0000
						%    81.4696   54.0552   16.0000   66.0000    1.0000
						%    81.7657   53.8833   16.0000   66.0000    1.0000
						%        NaN       NaN       NaN       NaN       NaN
						%    80.9450   54.3230   16.0000   44.0000    1.0000
						%    80.9936   54.4194   16.0000   44.0000    1.0000
						%    81.1055   54.6416   16.0000   43.0000    1.0000
						%    81.1351   54.7390   16.0000   43.0000    1.0000
						%    81.2398   55.1879   31.0000  183.0000    1.0000
						%    81.4247   54.6992   31.0000  183.0000    1.0000
						%    81.4994   54.5176   31.0000  183.0000    1.0000
						%    81.5475   54.4009   31.0000  225.0000    1.0000
						%    81.6358   54.1879   31.0000  225.0000    1.0000
						%    81.7657   53.8833   31.0000  225.0000    1.0000
						%    82.1432   53.0957   31.0000  225.0000    1.0000
						%    82.6802   52.1209   31.0000  225.0000    1.0000
						iobj	= iobj_v(i_iobj_v);
						i		= find(PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,3)==iobj);
						obj_delete(iobj,1).lino	= unique([...
							obj_delete(iobj,1).lino;...
							PLOTDATA.col(icno,1).connways.lines(k,1).xy(i,4)]);
					end
				else
					delete_str	= ' ';
				end
				if testout==1
					fprintf(1,'   % 3.0f',icno);
					fprintf(1,'   % 4.0f',k);
					fprintf(1,'   % 6.1f',PLOTDATA.col(icno,1).connways.lines(k,1).xy(1,1));
					fprintf(1,'   % 6.1f',PLOTDATA.col(icno,1).connways.lines(k,1).xy(1,2));
					fprintf(1,'    % 6.1f',diag_mm);
					fprintf(1,'      % 6.1f',length_mm);
					fprintf(1,'        %s',delete_str);
					fprintf(1,'     % 3.0f',colno);
					if colno~=0
						description	= PP.color(colno,1).description;
					else
						description	= '';
					end
					fprintf(1,'   %s\n',description);
				end
			end
			% Delete lines in PLOTDATA.col(icno,1).connways.lines:
			PLOTDATA.col(icno,1).connways.lines(k_delete,:)				= [];
			PLOTDATA.col(icno,1).connways.lines_isouter(k_delete,:)	= [];
			PLOTDATA.col(icno,1).connways.lines_relid(k_delete,:)		= [];
			PLOTDATA.col(icno,1).connways.xy_start(k_delete,:)			= [];
			PLOTDATA.col(icno,1).connways.xy_end(k_delete,:)			= [];
		end
	end
	% Delete lines in PLOTDATA.obj(iobj,1).connways.lines:
	for iobj=1:size(PLOTDATA.obj,1)
		if ~isempty(obj_delete(iobj,1).lino)&&~isempty(PLOTDATA.obj(iobj,1).connways)
			k_delete	= [];
			for k=1:size(PLOTDATA.obj(iobj,1).connways.lines,1)
				% Waitbar:
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					if ~isempty(msg)
						WAITBAR.t1	= clock;
						set(GV_H.text_waitbar,'String',...
							sprintf('%s Delete lines, that are too short: ObjNo %g/%g: %g/%g',...
							msg,...
							iobj,size(PLOTDATA.obj,1),...
							k,size(PLOTDATA.obj(iobj,1).connways.lines,1)));
						drawnow;
					end
				end
				for i=1:size(obj_delete(iobj,1).lino,1)
					if any(PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,4)==obj_delete(iobj,1).lino(i,1))
						k_delete	= [k_delete;k];
						break
					end
				end
			end
			PLOTDATA.obj(iobj,1).connways.lines(k_delete,:)				= [];
			PLOTDATA.obj(iobj,1).connways.lines_isouter(k_delete,:)	= [];
			PLOTDATA.obj(iobj,1).connways.lines_relid(k_delete,:)		= [];
			PLOTDATA.obj(iobj,1).connways.xy_start(k_delete,:)			= [];
			PLOTDATA.obj(iobj,1).connways.xy_end(k_delete,:)			= [];
		end
	end


	%******************************************************************************************************************
	% 4) Delete symbols that are too far away from the line:
	%    PLOTDATA.obj(iobj,1).symb
	%******************************************************************************************************************

	for iobj=1:size(PLOTDATA.obj,1)
		if ~isempty(PP.obj(iobj).display)
			% If this object number exists:
			dmax2lines	= PP.obj(iobj).reduce_nodes.dmax2lines_m/PP.project.scale*1000;
			if dmax2lines>=0
				if ~isempty(PLOTDATA.obj(iobj,1).connways)
					if isempty(PLOTDATA.obj(iobj,1).connways.lines)

						% Delete all texts and symbols:
						PLOTDATA.obj(iobj,1).text				= [];
						PLOTDATA.obj(iobj,1).symb				= [];
						PLOTDATA.obj(iobj,1).text_eqtags		= cell(0,1);
						PLOTDATA.obj(iobj,1).symb_eqtags		= cell(0,1);

					else

						% Check texts:
						if ~isempty(PLOTDATA.obj(iobj,1).text)
							for iteqt=1:size(PLOTDATA.obj(iobj,1).text,1)
								if ~isempty(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd)
									if numboundaries(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd)>0
										if ~isequal(...
												size(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd,1),...
												size(PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints,1)    )||~isequal(...
												size(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd,1),...
												size(PLOTDATA.obj(iobj,1).text(iteqt,1).source,1)           )||~isequal(...
												size(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd,1),...
												size(PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd,1)      )
											errormessage;
										end
										keep_symb_v	= false(size(PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd,1),1);
										for k=1:size(PLOTDATA.obj(iobj,1).connways.lines,1)
											mindistance_v	= mindistance_poly_p(...
												PLOTDATA.obj(iobj,1).connways.lines(k,:).xy(:,1),...			% vertices x
												PLOTDATA.obj(iobj,1).connways.lines(k,:).xy(:,2),...			% vertices y
												PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints(:,1),...	% query points x
												PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints(:,2));		% query points y
											keep_symb_v	= keep_symb_v|(mindistance_v<=dmax2lines);
										end
										PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_bgd(~keep_symb_v,:)	= [];
										PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_obj(~keep_symb_v,:)	= [];
										PLOTDATA.obj(iobj,1).text(iteqt,1).poly_text_lrp(~keep_symb_v,:)	= [];
										PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_bgd(~keep_symb_v,:)		= [];
										PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_obj(~keep_symb_v,:)		= [];
										PLOTDATA.obj(iobj,1).text(iteqt,1).ud_text_lrp(~keep_symb_v,:)		= [];
										PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints(~keep_symb_v,:)	= [];
										PLOTDATA.obj(iobj,1).text(iteqt,1).source(~keep_symb_v,:)			= [];
									end
								end
							end
						end

						% Check symbols:
						if ~isempty(PLOTDATA.obj(iobj,1).symb)
							for iseqt=1:size(PLOTDATA.obj(iobj,1).symb,1)
								if ~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd)
									if numboundaries(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd)>0
										if ~isequal(...
												size(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd,1),...
												size(PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints,1)     )||~isequal(...
												size(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd,1),...
												size(PLOTDATA.obj(iobj,1).symb(iseqt,1).symbol_eqtags_text,1))||~isequal(...
												size(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd,1),...
												size(PLOTDATA.obj(iobj,1).symb(iseqt,1).source,1)            )||~isequal(...
												size(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd,1),...
												size(PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_bgd,1)       )
											errormessage;
										end
										keep_symb_v	= false(size(PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd,1),1);
										for k=1:size(PLOTDATA.obj(iobj,1).connways.lines,1)
											mindistance_v	= mindistance_poly_p(...
												PLOTDATA.obj(iobj,1).connways.lines(k,:).xy(:,1),...			% vertices x
												PLOTDATA.obj(iobj,1).connways.lines(k,:).xy(:,2),...			% vertices y
												PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints(:,1),...	% query points x
												PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints(:,2));		% query points y
											keep_symb_v	= keep_symb_v|(mindistance_v<=dmax2lines);
										end
										PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_bgd(~keep_symb_v,:)			= [];
										PLOTDATA.obj(iobj,1).symb(iseqt,1).poly_symb_obj(~keep_symb_v,:)			= [];
										PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_bgd(~keep_symb_v,:)				= [];
										PLOTDATA.obj(iobj,1).symb(iseqt,1).ud_symb_obj(~keep_symb_v,:)				= [];
										PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints(~keep_symb_v,:)			= [];
										PLOTDATA.obj(iobj,1).symb(iseqt,1).symbol_eqtags_text(~keep_symb_v,:)	= [];
										PLOTDATA.obj(iobj,1).symb(iseqt,1).source(~keep_symb_v,:)					= [];
									end
								end
							end
						end

					end
				end
			end
		end
	end


	% Testplots: after deleting branched/touching lines:
	for k_tp_obj=1:length(objno_testplot_simplify_v)
		iobj	= objno_testplot_simplify_v(k_tp_obj);
		colno	= PP.obj(iobj).color_no_bgd;

		% Testplot of only object number iobj:
		if ~isempty(PLOTDATA.obj(iobj,1).connways)
			for k=1:size(PLOTDATA.obj(iobj,1).connways.lines,1)
				plot(ha_tp(k_tp_obj,5),...
					PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,1),...
					PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(:,2))
				if testplot_show_k~=0
					text(ha_tp(k_tp_obj,5),...
						PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(1,1),...
						PLOTDATA.obj(iobj,1).connways.lines(k,1).xy(1,2),...
						sprintf('%1.0f',k),'FontSize',8);
				end
			end
			axis(ha_tp(k_tp_obj,5),'equal');
			title(ha_tp(k_tp_obj,5),sprintf(['after deleting branched/touching lines\n',...
				'mindiag_branched=%gmm\n',...
				'minlength_branched=%gmm'],...
				PP.obj(iobj).reduce_lines.mindiag_branched,...
				PP.obj(iobj).reduce_lines.minlength_branched),'Interpreter','none');
		end
		dmax2lines	= PP.obj(iobj).reduce_nodes.dmax2lines_m/PP.project.scale*1000;
		labels		= cell(1,0);
		subset		= [];
		label_text	= false;
		label_symb	= false;
		if dmax2lines>=0
			for iteqt=1:size(PLOTDATA.obj(iobj,1).text,1)
				if ~isempty(PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints)
					ht	= plot(ha_tp(k_tp_obj,5),...
						PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints(:,1),...
						PLOTDATA.obj(iobj,1).text(iteqt,1).pos_refpoints(:,2),...
						'Color','b','Marker','+','MarkerSize',8,'LineStyle','none');
					if ~label_text
						labels{1,end+1}	= 'Texts';
						subset(1,end+1)	= ht;
						label_text			= true;
					end
				end
			end
			for iseqt=1:size(PLOTDATA.obj(iobj,1).symb,1)
				if ~isempty(PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints)
					hs	= plot(ha_tp(k_tp_obj,5),...
						PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints(:,1),...
						PLOTDATA.obj(iobj,1).symb(iseqt,1).pos_refpoints(:,2),...
						'Color','b','Marker','x','MarkerSize',8,'LineStyle','none');
					if ~label_symb
						labels{1,end+1}	= 'Symbols';
						subset(1,end+1)	= hs;
						label_symb			= true;
					end
				end
			end
			legend(ha_tp(k_tp_obj,5),subset,labels);
		end

		% Testplot of all line objects of the same color as object number iobj:
		for icno=1:size(PLOTDATA.colno_v,1)
			if isequal(PLOTDATA.colno_v(icno,1),colno)
				if ~isempty(PLOTDATA.col(icno,1).connways)
					for k=1:size(PLOTDATA.col(icno,1).connways.lines,1)
						plot(ha_tp(k_tp_obj,6),...
							PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,1),...
							PLOTDATA.col(icno,1).connways.lines(k,1).xy(:,2))
						if testplot_show_k~=0
							text(ha_tp(k_tp_obj,6),...
								PLOTDATA.col(icno,1).connways.lines(k,1).xy(1,1),...
								PLOTDATA.col(icno,1).connways.lines(k,1).xy(1,2),...
								sprintf('%1.0f',k),'FontSize',8);
						end
					end
					axis(ha_tp(k_tp_obj,6),'equal');
					title(ha_tp(k_tp_obj,6),sprintf(['after deleting branched/touching lines\n',...
						'mindiag_branched=%gmm\n',...
						'minlength_branched=%gmm'],...
						PLOTDATA.col(icno,1).mindiag_branched,...
						PLOTDATA.col(icno,1).minlength_branched),'Interpreter','none');
				end
			end
		end

		drawnow;

	end

catch ME
	errormessage('',ME);
end

