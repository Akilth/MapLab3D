function [poly,replaceplots]=plotosmdata_simplify_moveoutline(ObjColNo,poly,type,testplot,replaceplots,area_limits)
% Simplify objects and delete or connect small objects by moving the outlines.
% ObjColNo			color or object number, depending on type
% poly				Polygon before and after simplify
% type				'general'				Used in plotosmdata_simplify.m			ObjColNo: color number
%						'line_symbols'			Used in plotosmdata_plotdata_li_ar.m	ObjColNo: object number
%						'area_before_union'	Used in plotosmdata_plotdata_li_ar.m	ObjColNo: object number
%						'area_after_union'	Used in plotosmdata_plotdata_li_ar.m	ObjColNo: object number
%													In this case, lats must be defined!
% testplot			0: Do not show the figures.
% replaceplots		0: The figure has been created: Do not overwrite on next call.
% area_limits		Only necessary if type='area_after_union'. In this step, areas that are too small are deleted.
%						Assignment of the limit values:
%						'object'					mindiag=PP.obj(iobj).reduce_areas.mindiag
%													minarea=PP.obj(iobj).reduce_areas.minarea
%						'text'					mindiag=PP.obj(iobj).textpar.mindiag
%													minarea=PP.obj(iobj).textpar.minarea
%						'symbol'					mindiag=PP.obj(iobj).symbolpar.mindiag
%													minarea=PP.obj(iobj).symbolpar.minarea

global PP GV

try

	% Testplot:
	tpio_EdgeColor		= 'k';
	tpio_EdgeAlpha		= 0.25;
	tpio_FaceColor		= 'k';
	tpio_FaceAlpha		= 0;

	if nargin<4
		testplot			= 1;
	end
	if nargin<5
		replaceplots	= 1;
	end
	show_testplot1		= true;
	show_testplot2		= true;
	show_testplot3		= true;
	switch type
		case 'general'
			% Used in plotosmdata_simplify.m:
			colno						= ObjColNo;
			icolspec					= PP.color(colno).spec;
			firstmoveoutwards		= 0;
			moveinwards_forth		= PP.colorspec(icolspec,1).simplify_map.minimum_linewidth/2;
			moveinwards_back		= PP.colorspec(icolspec,1).simplify_map.minimum_linewidth/2;
			moveoutwards_forth	= 0;
			moveoutwards_back		= 0;
			if colno>0
				mindiag				= PP.colorspec(icolspec,1).simplify_map.mindiag;
			else
				mindiag				= 0;
			end
			minarea					= 0;
			dmin						= 0;		% Do not change the objects shape at this last step of simplification
			show_testplot			= (testplot==1)&&any(colno==GV.colno_testplot_simplify_v);
			if show_testplot
				ud_figtp				= sprintf('testplot2_plotosmdata_simplify_moveoutline_ColNo_%1.0f',colno);
				name_figtp			= sprintf('ColNo=%g',colno);
				title_str			= sprintf([...
					'Simplification of map objects: ColNo=%g:\n',...
					'%s\n',...
					'minimum_linewidth=%gmm, mindiag=%gmm, dmin=%gmm'],...
					colno,...
					PP.color(colno).description,...
					PP.colorspec(icolspec,1).simplify_map.minimum_linewidth,...
					mindiag,...
					dmin);
			end
		case 'area_before_union'
			% Used in plotosmdata_plotdata_li_ar.m:
			% "Simplify objects and delete or connect small objects by moving the outlines of areas"
			iobj						= ObjColNo;
			show_testplot			= (testplot==1)&&any(iobj==GV.iobj_testplot_simplify_v);
			if show_testplot
				ud_figtp				= sprintf('testplot2_plotosmdata_simplify_moveoutline_area_ObjNo_%1.0f',iobj);
				name_figtp			= sprintf('ObjNo=%g',iobj);
				title_str			= sprintf([...
					'Data reduction of areas: ObjNo=%g:\n',...
					'%s\n',...
					'firstmoveoutwards=%g\n',...
					'moveinwards=%gmm/%gmm (f/b), moveoutwards=%gmm/%gmm (f/b)\n',...
					'mindiag=%gmm, min. area: minarea=%gmm^2, dmin=%gmm'],...
					iobj,...
					PP.obj(iobj).description,...
					PP.obj(iobj).reduce_areas.firstmoveoutwards,...
					PP.obj(iobj).reduce_areas.moveinwards_forth,PP.obj(iobj).reduce_areas.moveinwards_back,...
					PP.obj(iobj).reduce_areas.moveoutwards_forth,PP.obj(iobj).reduce_areas.moveoutwards_back,...
					PP.obj(iobj).reduce_areas.mindiag,...
					PP.obj(iobj).reduce_areas.minarea,...
					PP.obj(iobj).reduce_areas.dmin);
			end
			firstmoveoutwards		= PP.obj(iobj).reduce_areas.firstmoveoutwards;
			if firstmoveoutwards==1
				% First move outwards: Do nothing:
				% Do not set replaceplots=0.
				return
			else
				% First move inwards:
				moveinwards_forth		= PP.obj(iobj).reduce_areas.moveinwards_forth;
				moveinwards_back		= PP.obj(iobj).reduce_areas.moveinwards_back;
				moveoutwards_forth	= 0;
				moveoutwards_back		= 0;
				mindiag					= 0;
				minarea					= 0;
				dmin						= 0;
				show_testplot2			= false;
				show_testplot3			= false;
			end
		case 'area_after_union'
			% Used in plotosmdata_plotdata_li_ar.m:
			% "Simplify objects and delete or connect small objects by moving the outlines of areas"
			iobj						= ObjColNo;
			show_testplot			= (testplot==1)&&any(iobj==GV.iobj_testplot_simplify_v);
			if show_testplot
				ud_figtp				= sprintf('testplot2_plotosmdata_simplify_moveoutline_area_ObjNo_%1.0f',iobj);
				name_figtp			= sprintf('ObjNo=%g',iobj);
				title_str			= sprintf([...
					'Data reduction of areas: ObjNo=%g:\n',...
					'%s\n',...
					'firstmoveoutwards=%g\n',...
					'moveinwards=%gmm/%gmm (f/b), moveoutwards=%gmm/%gmm (f/b)\n',...
					'mindiag=%gmm, min. area: minarea=%gmm^2, dmin=%gmm'],...
					iobj,...
					PP.obj(iobj).description,...
					PP.obj(iobj).reduce_areas.firstmoveoutwards,...
					PP.obj(iobj).reduce_areas.moveinwards_forth,PP.obj(iobj).reduce_areas.moveinwards_back,...
					PP.obj(iobj).reduce_areas.moveoutwards_forth,PP.obj(iobj).reduce_areas.moveoutwards_back,...
					PP.obj(iobj).reduce_areas.mindiag,...
					PP.obj(iobj).reduce_areas.minarea,...
					PP.obj(iobj).reduce_areas.dmin);
			end
			firstmoveoutwards		= PP.obj(iobj).reduce_areas.firstmoveoutwards;
			if firstmoveoutwards==1
				% First move outwards:
				moveinwards_forth		= PP.obj(iobj).reduce_areas.moveinwards_forth;
				moveinwards_back		= PP.obj(iobj).reduce_areas.moveinwards_back;
				moveoutwards_forth	= PP.obj(iobj).reduce_areas.moveoutwards_forth;
				moveoutwards_back		= PP.obj(iobj).reduce_areas.moveoutwards_back;
			else
				% First move inwards:
				moveinwards_forth		= 0;
				moveinwards_back		= 0;
				moveoutwards_forth	= PP.obj(iobj).reduce_areas.moveoutwards_forth;
				moveoutwards_back		= PP.obj(iobj).reduce_areas.moveoutwards_back;
				show_testplot1			= false;
			end
			switch area_limits
				case 'object'
					mindiag				= PP.obj(iobj).reduce_areas.mindiag;
					minarea				= PP.obj(iobj).reduce_areas.minarea;
				case 'text'
					mindiag				= PP.obj(iobj).textpar.mindiag;
					minarea				= PP.obj(iobj).textpar.minarea;
				case 'symbol'
					mindiag				= PP.obj(iobj).symbolpar.mindiag;
					minarea				= PP.obj(iobj).symbolpar.minarea;
				case 'change_text'
					mindiag				= 0;
					minarea				= 0;
				otherwise
					errormessage;
			end
			dmin							= PP.obj(iobj).reduce_areas.dmin;
		case 'line_symbols'
			% Used in plotosmdata_plotdata_li_ar.m:
			% "If there are line symboles, combine the lines in such a way that longer lines overlap shorter lines"
			iobj						= ObjColNo;
			colno_fgd				= PP.obj(iobj).color_no_fgd;		% line symbols are the line foreground
			if colno_fgd>0
				icolspec_fgd			= PP.color(colno_fgd).spec;
				moveinwards_forth		= PP.colorspec(icolspec_fgd,1).simplify_map.minimum_linewidth/2;
				moveinwards_back		= PP.colorspec(icolspec_fgd,1).simplify_map.minimum_linewidth/2;
			else
				simplify_map_minimum_linewidth		= 1e20;
				for icolspec=1:size(PP.colorspec,1)
					simplify_map_minimum_linewidth		= min(...
						simplify_map_minimum_linewidth,...
						PP.colorspec(icolspec,1).simplify_map.minimum_linewidth);
				end
				moveinwards_forth		= simplify_map_minimum_linewidth/2;
				moveinwards_back		= simplify_map_minimum_linewidth/2;
			end
			firstmoveoutwards		= 0;
			moveoutwards_forth	= 0;
			moveoutwards_back		= 0;
			mindiag					= 0;
			minarea					= 0;
			dmin						= 0;
			show_testplot			= (testplot==1)&&any(iobj==GV.iobj_testplot_simplify_v);
			if show_testplot
				ud_figtp				= sprintf('testplot2_plotosmdata_simplify_moveoutline_lisy_ObjNo_%1.0f',iobj);
				name_figtp			= sprintf('ObjNo=%g',iobj);
				title_str			= sprintf([...
					'Data reduction of line symbols: ObjNo=%g:\n',...
					'%s\n',...
					'firstmoveoutwards=%g\n',...
					'moveinwards=%gmm/%gmm (f/b), moveoutwards=%gmm/%gmm (f/b)\n',...
					'mindiag=%gmm, min. area: minarea=%gmm^2, dmin=%gmm'],...
					iobj,...
					PP.obj(iobj).description,...
					firstmoveoutwards,...
					moveinwards_forth,moveinwards_back,...
					moveoutwards_forth,moveoutwards_back,...
					mindiag,...
					minarea,...
					dmin);
			end
		otherwise
			errormessage;
	end
	dmax				= [];
	nmin				= [];

	if ~isempty(poly)
		if show_testplot
			% Get figure handle:
			h_figtp		= findobj('Type','figure','-and','UserData',ud_figtp);
			if isequal(size(h_figtp),[1 1])
				figure(h_figtp);
			else
				if ~isempty(h_figtp)
					delete(h_figtp);
				end
				h_figtp	= figure;
				figure_theme(h_figtp,'set',[],'light');
				set(h_figtp,'Tag','maplab3d_figure');
			end
			if replaceplots==0
				% Get axes handle:
				ha_tpar	= [];
				figtp_ch	= h_figtp.Children;
				for i=1:length(figtp_ch)
					if strcmp(figtp_ch(i).Type,'axes')
						ha_tpar	= figtp_ch(i);
					end
				end
				if isempty(ha_tpar)
					replaceplots	= 1;
				end
			end
			if replaceplots~=0
				clf(h_figtp,'reset');
				figure_theme(h_figtp,'set',[],'light');
				set(h_figtp,'Tag','maplab3d_figure');
				set(h_figtp,'NumberTitle','off');
				set(h_figtp,'Name',name_figtp);
				set(h_figtp,'UserData',ud_figtp);
				ha_tpar		= gca;
				hold(ha_tpar,'on');
				title(ha_tpar,title_str,'Interpreter','none');
			end
			legend_str={...
				'Original',...
				'After deleting or connecting small objects by moving the outlines',...
				'After deleting small objects depending on the size'};
			hplot_tpsimplify		= get(ha_tpar,'UserData');
			if show_testplot1
				hplot_tpsimplify(1)	= plot(ha_tpar,poly,'EdgeColor','k','FaceColor','b');
			end
			axis(ha_tpar,'equal');
			setbreakpoint=1;
		end
		dbuffer_outwards_forth	= max(0,moveoutwards_forth);
		dbuffer_outwards_back	= max(0,moveoutwards_back);
		dbuffer_inwards_forth	= max(0,moveinwards_forth);
		dbuffer_inwards_back		= max(0,moveinwards_back);
		if firstmoveoutwards~=0
			% First move the outlines outwards:
			if dbuffer_outwards_forth~=0
				poly					= polybuffer(poly,dbuffer_outwards_forth,'JointType','miter','MiterLimit',2);
				if show_testplot
					plot(ha_tpar,poly,...
						'EdgeColor',tpio_EdgeColor,'EdgeAlpha',tpio_EdgeAlpha,...
						'FaceColor',tpio_FaceColor,'FaceAlpha',tpio_FaceAlpha);
					setbreakpoint=1;
				end
			end
			dbuffer		= dbuffer_outwards_back+dbuffer_inwards_forth;
			if dbuffer~=0
				poly					= polybuffer(poly,-dbuffer,'JointType','miter','MiterLimit',2);
				if show_testplot
					plot(ha_tpar,poly,...
						'EdgeColor',tpio_EdgeColor,'EdgeAlpha',tpio_EdgeAlpha,...
						'FaceColor',tpio_FaceColor,'FaceAlpha',tpio_FaceAlpha);
					setbreakpoint=1;
				end
			end
			if dbuffer_inwards_back~=0
				poly					= polybuffer(poly,dbuffer_inwards_back,'JointType','miter','MiterLimit',2);
			end
			% Downsampling:
			if   ((dbuffer_outwards_forth~=0)||...
					(dbuffer               ~=0)||...
					(dbuffer_inwards_back  ~=0)     )&&(dmin>0)
				poly			= changeresolution_poly(poly,dmax,dmin,nmin);
			end
		else
			% First move the outlines inwards:
			dbuffer			= dbuffer_inwards_back+dbuffer_outwards_forth;
			if (dbuffer_inwards_forth~=0)||(dbuffer~=0)
				dbuffer_limits	= -dbuffer_inwards_forth+dbuffer;
				poly_limits		= polybuffer(poly,dbuffer_limits,'JointType','miter','MiterLimit',2);
			end
			if dbuffer_inwards_forth~=0
				poly			= polybuffer(poly,-dbuffer_inwards_forth ,'JointType','miter','MiterLimit',2);
				if show_testplot
					plot(ha_tpar,poly,...
						'EdgeColor',tpio_EdgeColor,'EdgeAlpha',tpio_EdgeAlpha,...
						'FaceColor',tpio_FaceColor,'FaceAlpha',tpio_FaceAlpha);
					setbreakpoint=1;
				end
			end
			if dbuffer~=0
				poly					= polybuffer(poly,dbuffer,'JointType','miter','MiterLimit',2);
			end
			if (dbuffer_inwards_forth~=0)||(dbuffer~=0)
				% The aim of moving inwards and then outwards could be to reduce the size by a certain amount
				% (e.g. for buildings). Therefore, after shifting inwards and then outwards, the polygon should not be
				% greater than when shifting directly outwards: The area size should not be greater than poly_limits:
				poly	= intersect(poly,poly_limits,'KeepCollinearPoints',false);
			end
			if dbuffer~=0
				if show_testplot
					plot(ha_tpar,poly,...
						'EdgeColor',tpio_EdgeColor,'EdgeAlpha',tpio_EdgeAlpha,...
						'FaceColor',tpio_FaceColor,'FaceAlpha',tpio_FaceAlpha);
					setbreakpoint=1;
				end
			end
			if dbuffer_outwards_back~=0
				poly					= polybuffer(poly,-dbuffer_outwards_back,'JointType','miter','MiterLimit',2);
			end
			% Downsampling:
			if   ((dbuffer_inwards_forth~=0)||...
					(dbuffer              ~=0)||...
					(dbuffer_outwards_back~=0)     )&&(dmin>0)
				poly			= changeresolution_poly(poly,dmax,dmin,nmin);
			end
		end
		if show_testplot&&show_testplot2
			hplot_tpsimplify(2)=plot(ha_tpar,poly,'EdgeColor','k','FaceColor','r');
			setbreakpoint=1;
		end
	end

	% Delete small pieces: minimum dimensions
	% (deleting short lines see also plotosmdata_reducedata.m:):
	% Delete single boundaries of the polygon:
	if GV.warnings_off
		warning('off','MATLAB:polyshape:repairedBySimplify');
	end
	poly			= sortboundaries(poly,'area','ascend');
	poly			= simplify(poly,'KeepCollinearPoints',false);
	ib				= 0;
	while ib<numboundaries(poly)
		ib		= ib+1;
		if (minarea>0)||show_testplot
			area_boundary	= abs(area(poly,ib));	% The area of holes is negative
		else
			area_boundary	= 1;
		end
		[xlim,ylim]		= boundingbox(poly,ib);
		poly_diag		= sqrt((xlim(2)-xlim(1))^2+(ylim(2)-ylim(1))^2);
		if show_testplot&&show_testplot3
			[x,y]			= boundary(poly,ib);
			text(ha_tpar,mean(x),mean(y),sprintf('%1.1fmm/%1.1fmm^2',poly_diag,area_boundary),...
				'Color','r','HorizontalAlignment','center');
		end
		if (poly_diag<mindiag)||(area_boundary<minarea)
			poly			= rmboundary(poly,ib,'Simplify',false);
			% poly			= rmboundary(poly,ib);
			% poly			= rmboundary(poly,ib,'Simplify',true);
			ib				= ib-1;
		end
	end
	if GV.warnings_off
		warning('on','MATLAB:polyshape:repairedBySimplify');
	end
	if ~isempty(poly)
		if show_testplot
			if show_testplot3
				hplot_tpsimplify(3)=plot(ha_tpar,poly,'EdgeColor','k','FaceColor','g');
				legend(ha_tpar,hplot_tpsimplify,legend_str);
			end
			setbreakpoint=1;
		end
	end

	% Save the testplot axis userdata:
	if show_testplot
		set(ha_tpar,'UserData',hplot_tpsimplify);
	end

	% The figure has been created: Do not overwrite on next call:
	replaceplots		= 0;

catch ME
	errormessage('',ME);
end

