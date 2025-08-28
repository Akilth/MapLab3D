function [poly_line,poly_area,dividing_poly]=divide_line(...
	poly_line,poly_area,colno_line,colno_area,divpoly_blocked,liwi,dmin_changeresolution,tol)
% Divide lines: Syntax:
% 1)	[poly_line,poly_area,dividing_poly]=divide_line(...
%			poly_line,poly_area,colno_line,colno_area,liwi,dmin_changeresolution,tol);
%		Cut the area by the line, if the line just runs over the edge of the area
%		Cut lines at the edges of areas
% 2)	[poly_line,~,dividing_poly]=divide_line(poly_line,[],colno_line,[],liwi,[],[]);
%		Cut lines that have large differences in height

try
	
	% Testing:
	if nargin==0
		load('C:\Daten\Projekte\Maplab3d\temp\test.mat');
	else
		global PP ELE GV
		% save('C:\Daten\Projekte\Maplab3d\temp\test.mat');
		setbreakpoint=1;
	end
	
	dividing_poly		= polyshape();
	icolspec_line		= PP.color(colno_line,1).spec;
	ifs_line				= ELE.ifs_v(icolspec_line,1);
	
	%------------------------------------------------------------------------------------------------------------------
	% Cut the area by the line, if the line just runs over the edge of the area:
	
	if ~isempty(poly_area)
		
		% Test:
		testplot1=0;
		if testplot1~=0
			hf1=123467;
			figure(hf1);
			clf(hf1,'reset');
			set(hf1,'Tag','maplab3d_figure');
			ha1(1)=subplot(2,2,1);
			ha1(2)=subplot(2,2,2);
			ha1(3)=subplot(2,2,3);
			ha1(4)=subplot(2,2,4);
			hold(ha1,'on');
			plot(ha1(1),poly_line);
			plot(ha1(1),poly_area);
			title(ha1(1),'original','Interpreter','none')
			plot(ha1(2),poly_line);
			plot(ha1(3),poly_line);
			plot(ha1(4),poly_line);
		end
		
		% d_side: horizontal distance between the sides of neighboring parts:
		% d_side must be determined depending on the color priority of the two parts involved.
		% The part with the higher color priority cuts a hole in the part with the lower color priority.
		colprio_area	= PP.color(colno_area,1).prio;
		colprio_line	= PP.color(colno_line,1).prio;
		if colprio_area>colprio_line
			icolspec		= PP.color(colno_area,1).spec;
		else
			icolspec		= PP.color(colno_line,1).spec;
		end
		d_side			= PP.colorspec(icolspec,1).d_side;
		
		% Line buffered by the horizontal distance between neighboring parts:
		% +2*tol: so that no overlap is detected when calculating z_bot in map2stl.m:
		% +dmin_changeresolution*1.001: the outline is changed when reducing the resolution (see below)
		dbuffer_line		= d_side+2*tol+dmin_changeresolution*1.01;
		dbuffer_area		= 2*dbuffer_line+liwi;
		if strcmp(GV.jointtype_bh,'miter')
			poly_line_buff		= polybuffer(poly_line,dbuffer_line,'JointType',GV.jointtype_bh,...
				'MiterLimit',GV.miterlimit_bh);
		else
			poly_line_buff		= polybuffer(poly_line,dbuffer_line,'JointType',GV.jointtype_bh);
		end
		% If the line just runs over the edge of the area: cut the area by the line:
		poly_area_reg	= regions(poly_area);
		poly_area_new	= polyshape();
		for ir=1:length(poly_area_reg)
			poly_area_reg_ir	= poly_area_reg(ir);
			if overlaps(poly_area_reg_ir,poly_line_buff)
				poly_area_reg_ir_test			= subtract(poly_area_reg_ir,poly_line_buff,'KeepCollinearPoints',false);
				numreg_poly_area_reg_ir_test	= length(regions(poly_area_reg_ir_test));
				if testplot1~=0
					fprintf(1,'ir=%g\n',ir);
					text(ha1(1),poly_area_reg_ir.Vertices(1,1),poly_area_reg_ir.Vertices(1,2),num2str(ir));
					fprintf(1,'numreg_poly_area_reg_ir_test=%g\n',numreg_poly_area_reg_ir_test);
					plot(ha1(2),poly_area);
					plot(ha1(2),poly_area_reg_ir_test);
					title(ha1(2),sprintf('poly_area_reg_ir_test'),'Interpreter','none')
				end
				if numreg_poly_area_reg_ir_test==1
					% The number of regions has not changed:
					if strcmp(GV.jointtype_bh,'miter')
						poly_area_reg_ir_buff	= polybuffer(poly_area_reg_ir,dbuffer_area,'JointType',GV.jointtype_bh,...
							'MiterLimit',GV.miterlimit_bh);
					else
						poly_area_reg_ir_buff	= polybuffer(poly_area_reg_ir,dbuffer_area,'JointType',GV.jointtype_bh);
					end
					poly_area_reg_ir_test2	= subtract(poly_area_reg_ir_buff,poly_line_buff,'KeepCollinearPoints',false);
					numreg_poly_area_reg_ir_buff_test	= length(regions(poly_area_reg_ir_test2));
					if testplot1~=0
						fprintf(1,'numreg_poly_area_reg_ir_buff_test=%g\n',numreg_poly_area_reg_ir_buff_test);
						plot(ha1(3),poly_area);
						plot(ha1(3),poly_area_reg_ir_buff);
						plot(ha1(3),poly_area_reg_ir_test2);
						title(ha1(3),sprintf('poly_area_reg_ir_buff\npoly_area_reg_ir_test2'),'Interpreter','none')
					end
					if numreg_poly_area_reg_ir_buff_test>1
						% The number of regions has been increased:
						% The line only runs along the edge of the area. There should be no overlap:
						poly_area_new	= addboundary(poly_area_new,poly_area_reg_ir_test.Vertices,...
							'Simplify',true,'KeepCollinearPoints',false);
					else
						% The line runs completely over the area: No change:
						poly_area_new	= addboundary(poly_area_new,poly_area_reg_ir.Vertices,...
							'Simplify',true,'KeepCollinearPoints',false);
					end
				else
					% The line runs completely over the area: No change:
					poly_area_new	= addboundary(poly_area_new,poly_area_reg_ir.Vertices,...
						'Simplify',true,'KeepCollinearPoints',false);
				end
				% OLD:
				% 			poly_area_reg_ir_test		= subtract(poly_area_reg_ir,poly_line_buff,'KeepCollinearPoints',false);
				%			if strcmp(GV.jointtype_bh,'miter')
				%				poly_area_reg_ir_buff		= polybuffer(poly_area_reg_ir,dbuffer_area,'JointType',GV.jointtype_bh,...
				%					'MiterLimit',GV.miterlimit_bh);
				%			else
				%				poly_area_reg_ir_buff		= polybuffer(poly_area_reg_ir,dbuffer_area,'JointType',GV.jointtype_bh);
				%			end
				% 			poly_area_reg_ir_buff_test	= subtract(poly_area_reg_ir_buff,poly_line_buff,'KeepCollinearPoints',false);
				% 			numregions_poly_area_reg_ir_test			= length(regions(poly_area_reg_ir_test));
				% 			numregions_poly_area_reg_ir_buff_test	= length(regions(poly_area_reg_ir_buff_test));
				% 			if testplot1~=0
				% 				fprintf(1,'ir=%g\n',ir);
				% 				text(ha1(1),poly_area_reg_ir.Vertices(1,1),poly_area_reg_ir.Vertices(1,2),num2str(ir));
				% 				fprintf(1,'numregions_poly_area_reg_ir_test=%g\n',numregions_poly_area_reg_ir_test);
				% 				fprintf(1,'numregions_poly_area_reg_ir_buff_test=%g\n',numregions_poly_area_reg_ir_buff_test);
				% 				plot(ha1(2),poly_area_reg_ir_test);
				% 				plot(ha1(2),poly_area_reg_ir_buff_test);
				% 				title(ha1(2),sprintf('poly_area_reg_ir_test\npoly_area_reg_ir_buff_test'),'Interpreter','none')
				% 			end
				% 			if numregions_poly_area_reg_ir_test~=numregions_poly_area_reg_ir_buff_test
				% 				% The number of boundaries is not equal: The line possibly only runs along the edge of the area.
				% 				% Delete the narrow stripes that occured when poly_area_reg_ir was enlarged by dbuffer_area:
				% 				% Without these narrow stripes, the number of regions must be the same as before.
				%				if strcmp(GV.jointtype_bh,'miter')
				%					poly_area_reg_ir_test2	= polybuffer(poly_area_reg_ir_buff_test,-dbuffer_area/2-tol,...
				%						'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
				%				else
				%					poly_area_reg_ir_test2	= polybuffer(poly_area_reg_ir_buff_test,-dbuffer_area/2-tol,...
				%						'JointType',GV.jointtype_bh);
				%				end
				% 				numregions_poly_area_reg_ir_test2		= length(regions(poly_area_reg_ir_test2));
				% 				if testplot1~=0
				% 					fprintf(1,'numregions_poly_area_reg_ir_test2=%g\n',numregions_poly_area_reg_ir_test2);
				% 					plot(ha1(3),poly_area);
				% 					plot(ha1(3),poly_area_reg_ir_test2);
				% 					title(ha1(3),'poly_area_reg_ir_test2','Interpreter','none')
				% 				end
				% 				if numregions_poly_area_reg_ir_test==numregions_poly_area_reg_ir_test2
				% 					% The line only runs along the edge of the area. There should be no overlap:
				% 					poly_area_new	= addboundary(poly_area_new,poly_area_reg_ir_test.Vertices,...
				% 						'Simplify',true,'KeepCollinearPoints',false);
				% 				else
				% 					% The line runs completely over the area: No change:
				% 					poly_area_new	= addboundary(poly_area_new,poly_area_reg_ir.Vertices,...
				% 						'Simplify',true,'KeepCollinearPoints',false);
				% 				end
				% 			else
				% 				% The line runs completely over the area: No change:
				% 				poly_area_new	= addboundary(poly_area_new,poly_area_reg_ir.Vertices,...
				% 					'Simplify',true,'KeepCollinearPoints',false);
				% 			end
			else
				% No overlap:
				poly_area_new	= addboundary(poly_area_new,poly_area_reg_ir.Vertices,...
					'Simplify',true,'KeepCollinearPoints',false);
			end
		end
		if testplot1~=0
			title(ha1(4),'poly_area_new','Interpreter','none')
			plot(ha1(4),poly_area_new);
			axis(ha1,'equal');
			setbreakpoint=1;
		end
		poly_area	= poly_area_new;
		
	end
	
	%------------------------------------------------------------------------------------------------------------------
	% Cut lines at the edges of areas:
	
	if ~isempty(poly_area)
		
		% Test:
		testplot2=0;
		if testplot2~=0
			hf2=123468;
			figure(hf2);
			clf(hf2,'reset');
			set(hf2,'Tag','maplab3d_figure');
			ha2=axes;
			hold(ha2,'on');
			plot(ha2,poly_area);
		end
		
		dbuffer_area			= dbuffer_line-tol;
		if strcmp(GV.jointtype_bh,'miter')
			poly_area_buff		= polybuffer(poly_area,dbuffer_area,'JointType',GV.jointtype_bh,...
				'MiterLimit',GV.miterlimit_bh);
		else
			poly_area_buff		= polybuffer(poly_area,dbuffer_area,'JointType',GV.jointtype_bh);
		end
		if testplot2~=0
			plot(ha2,poly_area_buff,'EdgeColor','k','EdgeAlpha',0.25,'FaceColor','k','FaceAlpha',0);
		end
		poly_area_buff_reg	= regions(poly_area_buff);
		poly_line_reg			= polyshape();
		for ir_area=1:length(poly_area_buff_reg)
			poly_line_reg		= regions(poly_line);
			for ir_line=1:length(poly_line_reg)
				if overlaps(poly_line_reg(ir_line),poly_area_buff_reg(ir_area))
					% Calculate the Intersection points between line and area:
					[poly_line_reg_ir_line_vx     ,poly_line_reg_ir_line_vy     ] = boundary(poly_line_reg(ir_line));
					[poly_area_buff_reg_ir_area_vx,poly_area_buff_reg_ir_area_vy] = boundary(poly_area_buff_reg(ir_area));
					[xi,yi,ii]	= polyxpoly(...
						poly_line_reg_ir_line_vx     ,poly_line_reg_ir_line_vy     ,...		% x1,y1
						poly_area_buff_reg_ir_area_vx,poly_area_buff_reg_ir_area_vy    );		% x2,y2
					if ~isempty(ii)
						% There exist intersection points:
						if testplot2~=0
							plot(ha2,xi,yi,'.r','MarkerSize',14);
						end
						[poly_line_reg(ir_line),divpoly]	= divide_line_local(...
							poly_line_reg_ir_line_vx,...
							poly_line_reg_ir_line_vy,...
							poly_area_buff_reg(ir_area),...
							colno_line,...
							divpoly_blocked,...
							liwi,xi,yi,ii(:,1));
						dividing_poly		= union(dividing_poly,divpoly,'KeepCollinearPoints',false);
					end
				end
			end
		end
		poly_line		= polyshape();
		for ir=1:length(poly_line_reg)
			poly_line	= union(poly_line,poly_line_reg(ir),'KeepCollinearPoints',false);
		end
		if testplot2~=0
			plot(ha2,poly_line);
		end
		
	end
	
	%------------------------------------------------------------------------------------------------------------------
	% Cut lines that have large differences in height:
	
	if isempty(poly_area)
		
		% Test:
		testplot3=0;
		if testplot3~=0
			hf3=123469;
			figure(hf3);
			clf(hf3,'reset');
			set(hf3,'Tag','maplab3d_figure');
			ha3=axes;
			poly_line_0=poly_line;
		end
		
		poly_line_reg		= regions(poly_line);
		poly_line			= polyshape();
		while ~isempty(poly_line_reg)
			ir						= 1;
			poly_line_reg_ir	= poly_line_reg(ir);
			if testplot3~=0
				cla(ha3,'reset');
				hold(ha3,'on');
				hp1=plot(ha3,poly_line       ,'EdgeColor','b','EdgeAlpha',1   ,'FaceColor','b','FaceAlpha',0  ,'DisplayName','poly_line');
				hp2=plot(ha3,poly_line_reg   ,'EdgeColor','g','EdgeAlpha',1   ,'FaceColor','g','FaceAlpha',0  ,'DisplayName','poly_line_reg');
				hp3=plot(ha3,poly_line_reg_ir,'EdgeColor','r','EdgeAlpha',0  ,'FaceColor','r','FaceAlpha',0.25,'DisplayName','poly_line_reg_ir');
				axis(ha3,'equal');
				ha3.XLimMode='manual';
				ha3.YLimMode='manual';
				legend(ha3,'Location','eastoutside','Interpreter','none')
				setbreakpoint=1;
			end
			poly_line_reg(ir)	= [];		% The divided lines will be added at the end of poly_line_reg
			z_line_reg_ir				= interp2(...
				ELE.elefiltset(ifs_line,1).xm_mm,...		% X  coordinates of the sample points
				ELE.elefiltset(ifs_line,1).ym_mm,...		% Y  coordinates of the sample points
				ELE.elefiltset(ifs_line,1).zm_mm,...		% Z  function values at each sample point
				poly_line_reg_ir.Vertices(:,1),...			% Xq query points
				poly_line_reg_ir.Vertices(:,2));				% Yq query points
			min_z_line_reg_ir		= min(z_line_reg_ir);
			max_z_line_reg_ir		= max(z_line_reg_ir);
			if (max_z_line_reg_ir-min_z_line_reg_ir)<=PP.colorspec(icolspec_line,1).simplify_map.divlines_dzmax
				% The difference in height is smaller than divlines_dzmax: The line does not have to be divided:
				poly_line			= union(poly_line,poly_line_reg_ir,'KeepCollinearPoints',false);
				setbreakpoint=1;
			else
				
				% Search for the optimal height range where most of the points are located:
				% (simply strategy, could be optimized to reduce the number of dividing lines)
				z_stepsize	= 0.5;												% step size
				z1				= min_z_line_reg_ir;								% lower z-limit
				z2				= z1+PP.colorspec(icolspec_line,1).simplify_map.divlines_dzmax;	% higher z-limit
				n_opt			= 0;													% number of points between z1 and z2
				while z2<=max_z_line_reg_ir
					n	= sum((z_line_reg_ir>=z1)&(z_line_reg_ir<=z2));
					if n>n_opt
						z1_opt	= z1;
						z2_opt	= z2;
						n_opt	= n;
					end
					z1	= z1+z_stepsize;
					z2	= z1+PP.colorspec(icolspec_line,1).simplify_map.divlines_dzmax;
				end
				
				% Try to divide the region poly_line_reg_ir:
				% If the region cannot be divided, the remaining partial areas may be too small because
				% the terrain is too steep. In this case, test increasing the height range [z1_opt z1_opt]
				% until z1_opt<min_z_line_reg_ir and z2_opt>max_z_line_reg_ir or
				% until numreg>1
				numreg		= 1;
				z1_opt	= z1_opt+z_stepsize;
				z2_opt	= z2_opt-z_stepsize;
				while ((z1_opt>min_z_line_reg_ir)||(z2_opt<max_z_line_reg_ir))&&(numreg==1)
					z1_opt	= z1_opt-z_stepsize;
					z2_opt	= z2_opt+z_stepsize;
					
					% Contour lines where to divide the line:
					% cont: N-by-2 matrix, where N is the number of vertices.
					cont	= zeros(0,2);
					C1 = contourc(...
						ELE.elefiltset(ifs_line,1).xv_mm,...
						ELE.elefiltset(ifs_line,1).yv_mm,...
						ELE.elefiltset(ifs_line,1).zm_mm,...
						[z1_opt z1_opt]);		% see "ContourMatrix" property
					while ~isempty(C1)
						k1	= 2;
						k2	= k1+C1(2,1)-1;
						if isempty(cont)
							cont	= [C1(1,k1:k2)' C1(2,k1:k2)'];
						else
							cont	= [cont;[nan nan];[C1(1,k1:k2)' C1(2,k1:k2)']];
						end
						C1(:,1:k2)	= [];
					end
					C2 = contourc(...
						ELE.elefiltset(ifs_line,1).xv_mm,...
						ELE.elefiltset(ifs_line,1).yv_mm,...
						ELE.elefiltset(ifs_line,1).zm_mm,...
						[z2_opt z2_opt]);		% see "ContourMatrix" property
					while ~isempty(C2)
						k1	= 2;
						k2	= k1+C2(2,1)-1;
						if isempty(cont)
							cont	= [C2(1,k1:k2)' C2(2,k1:k2)'];
						else
							cont	= [cont;[nan nan];[C2(1,k1:k2)' C2(2,k1:k2)']];
						end
						C2(:,1:k2)	= [];
					end
					if testplot3~=0
						plot(ha3,cont(:,1),cont(:,2),'DisplayName',sprintf('countour z1_opt=%g, z2_opt=%g',z1_opt,z2_opt));
						setbreakpoint=1;
					end
					
					% Calculate the Intersection points between line and the contour lines:
					[poly_line_reg_ir_vx,poly_line_reg_ir_vy] = boundary(poly_line_reg_ir);
					[xi,yi,ii]	= polyxpoly(...
						poly_line_reg_ir_vx,poly_line_reg_ir_vy,...			% x1,y1
						cont(:,1)          ,cont(:,2)              );		% x2,y2
					zi				= interp2(...
						ELE.elefiltset(ifs_line,1).xm_mm,...					% X  coordinates of the sample points
						ELE.elefiltset(ifs_line,1).ym_mm,...					% Y  coordinates of the sample points
						ELE.elefiltset(ifs_line,1).zm_mm,...					% Z  function values at each sample point
						xi,...															% Xq query points
						yi);																% Yq query points
					
					% Delete points that are near to the minimum or maximum countour lines:
					idelete	= (...
						(abs(zi-min_z_line_reg_ir)<(z_stepsize)/100)|...
						(abs(zi-max_z_line_reg_ir)<(z_stepsize)/100));
					xi(idelete,:)	= [];
					yi(idelete,:)	= [];
					ii(idelete,:)	= [];
					
					% If there are intersection points: divide the line:
					if ~isempty(ii)
						[poly_line_reg_ir,divpoly]	= divide_line_local(...
							poly_line_reg_ir_vx,...
							poly_line_reg_ir_vy,...
							[],...
							colno_line,...
							divpoly_blocked,...
							liwi,xi,yi,ii(:,1));
						dividing_poly	= union(dividing_poly,divpoly,'KeepCollinearPoints',false);
						if testplot3~=0
							plot(ha3,xi,yi,'.r','MarkerSize',14,'DisplayName','Intersection points');
							plot(ha3,divpoly,'EdgeColor','b','EdgeAlpha',0.25,'FaceColor','b','FaceAlpha',0.25,'DisplayName','divpoly');
							setbreakpoint=1;
						end
					end
					poly_line_reg_ir	= regions(poly_line_reg_ir);
					numreg				= length(poly_line_reg_ir);
					
				end
				
				if numreg==1
					% The number of regions did not increase:
					poly_line		= union(poly_line,poly_line_reg_ir,'KeepCollinearPoints',false);
				else
					% The number of regions has increased: continue:
					if ~isempty(poly_line_reg)
						poly_line_reg((end+1):(end+numreg),1)	= poly_line_reg_ir(1:numreg);
					else
						poly_line_reg							= poly_line_reg_ir;
					end
				end
				if testplot3~=0
					fprintf(1,'length(poly_line_reg)=%g\n',length(poly_line_reg));
					setbreakpoint=1;
				end
				
			end
			
		end
		
	end
	
	%------------------------------------------------------------------------------------------------------------------
	% Cut lines that are too long:
	% maybe not necessary
	
	
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Testplot of the results:
	
	testplot4=0;
	if testplot4~=0
		hf4=123470;
		figure(hf4);
		clf(hf4,'reset');
		set(hf4,'Tag','maplab3d_figure');
		ha4=axes;
		hold(ha4,'on');
		if ~isempty(poly_area)
			plot(ha4,poly_area);
		end
		plot(ha4,poly_line);
		axis(ha4,'equal');
		setbreakpoint=1;
	end
	
catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
function 	[poly_line_divided,dividing_poly]=divide_line_local(...
	poly_line_vx,...
	poly_line_vy,...
	poly_area,...
	colno_line,...
	divpoly_blocked,...
	liwi,...
	x_v,...					% intersection points x between poly_line and poly_area
	y_v,...					% intersection points y between poly_line and poly_area
	i_v)						% intersection points indices in poly_line_vx, poly_line_vy
% 1)	poly_area =[]
%		Divide the line at the intersection points x_v, y_v
% 2)	poly_area~=[]
%		poly_area: polygon object
%		Divide the line at the intersection points x_v, y_v with poly_area
%		The line will be divided if it rises as it enters the area.

global PP ELE

try
	
	icolspec_line		= PP.color(colno_line,1).spec;
	poly_line			= polyshape(poly_line_vx,poly_line_vy);
	ifs_line				= ELE.ifs_v(icolspec_line,1);
	
	% Testplot:
	testplot				= 0;
	if testplot~=0
		hf1=123460;
		figure(hf1);
		clf(hf1,'reset');
		set(hf1,'Tag','maplab3d_figure');
		ha1=axes;
		hold(ha1,'on');
		plot(ha1,poly_line,'EdgeColor','r','FaceColor','r','FaceAlpha',0.25);
		h_divli=plot(ha1,1,1,'x-b');
		h_divli.LineWidth=2;
		h_divli.XData= [];
		h_divli.YData= [];
		axis(ha1,'equal');
		hf2=123461;
		figure(hf2);
		clf(hf2,'reset');
		set(hf2,'Tag','maplab3d_figure');
		ha2=axes;
		hold(ha2,'on');
		axis(ha2,'equal');
	end
	
	% The dividing line must overlap the line to divide:
	divli_overlap		= liwi/100;			% mm
	
	poly_line_divided	= poly_line;
	dividing_poly		= polyshape;
	imax					= size(poly_line_vx,1);
	ip1_v					= vindexrest(i_v+1,imax);
	if ~isempty(poly_area)
		no_ovli_0			= number_lines_overlap_area(poly_line,poly_area);
	else
		no_ovli_0			= 0;
	end
	for i_i_v=1:length(i_v)
		i					= i_v(i_i_v);		% i:   row number in poly_line_vx, poly_line_vy
		ip1				= ip1_v(i_i_v);	% ip1: row number in poly_line_vx, poly_line_vy
		x					= x_v(i_i_v);		% x:   intersection point, between index i and ip1
		y					= y_v(i_i_v);		% y:   intersection point, between index i and ip1
		z_v				= interp2(...
			ELE.elefiltset(ifs_line,1).xm_mm,...				% X  coordinates of the sample points
			ELE.elefiltset(ifs_line,1).ym_mm,...				% Y  coordinates of the sample points
			ELE.elefiltset(ifs_line,1).zm_mm,...				% Z  function values at each sample point
			[poly_line_vx(i,1) poly_line_vx(ip1,1)],...		% Xq query points
			[poly_line_vy(i,1) poly_line_vy(ip1,1)]);			% Yq query points
		z_i	= z_v(1);
		z_ip1	= z_v(2);
		if ~isempty(poly_area)
			% condition1=true: The line rises as it enters the area.
			isintarea_i	= inpolygon(...					% faster than isinterior
				poly_line_vx(i,1),...						% query points
				poly_line_vy(i,1),...
				poly_area.Vertices(:,1),...				% polygon area
				poly_area.Vertices(:,2));
			isintarea_ip1	= inpolygon(...				% faster than isinterior
				poly_line_vx(ip1,1),...						% query points
				poly_line_vy(ip1,1),...
				poly_area.Vertices(:,1),...				% polygon area
				poly_area.Vertices(:,2));
			condition1		= (isintarea_i&&~isintarea_ip1&&(z_i>z_ip1))||(~isintarea_i&&isintarea_ip1&&(z_i<z_ip1));
		else
			condition1		= true;
		end
		if condition1
			% Test whether the intersection points (x,y) lie within blocked areas (linestyle 4 = bridges):
			idpbl			= 1;
			while idpbl<=size(divpoly_blocked,1)
				if inpolygon(...				% faster than isinterior
						x,...						% query points
						y,...
						divpoly_blocked(idpbl,1).polybuff.Vertices(:,1),...				% polygon area
						divpoly_blocked(idpbl,1).polybuff.Vertices(:,2))
					break
				end
				idpbl		= idpbl+1;
			end
			if idpbl<=size(divpoly_blocked,1)
				% The intersection point (x,y) lies within a blocked area (bridges):
				% Replace the point of intersection with the lower point of the bridge:
				x						= divpoly_blocked(idpbl,1).x_zmin(1,1);
				x2						= divpoly_blocked(idpbl,1).x_zmin(2,1);
				y						= divpoly_blocked(idpbl,1).y_zmin(1,1);
				y2						= divpoly_blocked(idpbl,1).y_zmin(2,1);
				divli_norm_c_v		= (x2+1i*y2)-(x+1i*y);
				liseg_i_c			= [];			% testplot
			else
				% Line segment:
				liseg_i_c			= poly_line_vx(i  ,1)+1i*poly_line_vy(i  ,1);
				liseg_ip1_c			= poly_line_vx(ip1,1)+1i*poly_line_vy(ip1,1);
				liseg_i_ip1_c		= liseg_ip1_c-liseg_i_c;
				phi_v					= [-1;1]*(pi/2);								% turn the line segment by -90°
				divli_norm_c_v		= liseg_i_ip1_c*exp(1i*phi_v);
			end
			divli_norm_c_v	= divli_norm_c_v./abs(divli_norm_c_v);
			for i_divli_norm_c=1:size(divli_norm_c_v,1)
				% Dividing line and polygon:
				divli_norm_c	= divli_norm_c_v(i_divli_norm_c,1);
				divli_c_1		= x+1i*y-divli_norm_c*divli_overlap;
				divli_c_2		= x+1i*y+divli_norm_c*(liwi+divli_overlap);
				divli	= [...
					real(divli_c_1) imag(divli_c_1);...
					real(divli_c_2) imag(divli_c_2)    ];
				[~,~,ii]	= polyxpoly(...
					divli(:,1)  ,divli(:,2)  ,...			% x1,y1
					poly_line_vx,poly_line_vy    );		% x2,y2
				if testplot~=0
					h_divli.XData=divli(:,1);
					h_divli.YData=divli(:,2);
					setbreakpoint=1;
				end
				if size(ii,1)==2
					% The dividing line has 2 points of intersection with the line: Divide the line:
					divpoly	= line2poly(...
						divli(:,1),...
						divli(:,2),...
						PP.colorspec(icolspec_line,1).simplify_map.divlines_gapwidth);
					poly_line_test		= subtract(poly_line_divided,divpoly,'KeepCollinearPoints',false);
					if testplot~=0
						cla(ha2,'reset');
						hold(ha2,'on');
						if ~isempty(poly_area)
							plot(ha2,poly_area,'EdgeColor','g','FaceColor','g','FaceAlpha',0.25);
						end
						if ~isempty(liseg_i_c)
							plot(ha2,...
								real([liseg_i_c liseg_i_c+divli_norm_c]),...
								imag([liseg_i_c liseg_i_c+divli_norm_c]),'-r');
							plot(ha2,real(liseg_i_c)  ,imag(liseg_i_c)  ,'xr');
							plot(ha2,real(liseg_ip1_c),imag(liseg_ip1_c),'.r');
						end
						plot(ha2,divli(:,1),divli(:,2),'.-c');
						plot(ha2,divpoly,'EdgeColor','c','FaceColor','c','FaceAlpha',0.25);
						plot(ha2,poly_line_test);
						axis(ha2,'equal');
						setbreakpoint=1;
					end
					if ~isempty(poly_area)
						% condition2=true: After dividing, the number of lines overlapping the area does not increase.
						%                  The new line segment is outside the area.
						no_ovli			= number_lines_overlap_area(poly_line_test,poly_area);
						condition2		= (no_ovli==no_ovli_0);
					else
						condition2		= true;
					end
					if condition2
						% Divide the line if:
						% - the dimensions            of the divided lines is >= PP.colorspec(icolspec_line,1).simplify_map.divlines_mindiag and
						% - the differences in height of the divided lines is >= PP.colorspec(icolspec_line,1).simplify_map.divlines_dzmin
						mindiag_linereg		= mindiag_line_regions(poly_line_test);
						[mindz_linereg,~]		= minmaxdz_line_regions(poly_line_test,ifs_line);
						if testplot~=0
							fprintf(1,'i_i_v=%g ,  i_divli_norm_c=%g ,  mindiag_linereg=%g(%g) ,  mindz_linereg=%g(%g)',...
								i_i_v,i_divli_norm_c,...
								mindiag_linereg,PP.colorspec(icolspec_line,1).simplify_map.divlines_mindiag,...
								mindz_linereg,PP.colorspec(icolspec_line,1).simplify_map.divlines_dzmin);
						end
						if    (mindiag_linereg>=PP.colorspec(icolspec_line,1).simplify_map.divlines_mindiag)&&...
								(mindz_linereg  >=PP.colorspec(icolspec_line,1).simplify_map.divlines_dzmin  )
							poly_line_divided	= poly_line_test;
							dividing_poly		= union(dividing_poly,divpoly,'KeepCollinearPoints',false);
							if testplot~=0
								fprintf(1,' --> OK\n');
							end
						else
							if testplot~=0
								fprintf(1,'\n');
							end
						end
					end
				end
				
			end
			
		end
	end
	if testplot~=0
		h_divli.XData= [];
		h_divli.YData= [];
		plot(ha1,poly_line_divided,'EdgeColor','r','FaceColor','r','FaceAlpha',0.25);
		setbreakpoint=1;
	end
	
catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
function no_ovli=number_lines_overlap_area(poly_line,poly_area)

try
	
	poly_line_reg	= regions(poly_line);
	no_ovli			= 0;
	for ir=1:length(poly_line_reg)
		if overlaps(poly_line_reg(ir),poly_area)
			no_ovli	= no_ovli+1;
		end
	end
	
catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
function mindiag_linereg=mindiag_line_regions(poly_line)
% Minimum diagonal of the bounding box of all regions inside poly_line:

try
	
	poly_line_reg			= regions(poly_line);
	irmax						= length(poly_line_reg);
	if irmax>0
		mindiag_linereg	= 1e6;
		for ir=1:irmax
			[xlim,ylim]		= boundingbox(poly_line_reg(ir));
			diag_linereg	= sqrt((xlim(2)-xlim(1))^2+(ylim(2)-ylim(1))^2);
			if diag_linereg<mindiag_linereg
				mindiag_linereg	= diag_linereg;
			end
		end
	else
		mindiag_linereg	= 0;
	end
	
catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
function [mindz_linereg,maxdz_linereg]=minmaxdz_line_regions(poly_line,ifs_line)
% Minimum differences in height of all regions inside poly_line:

global ELE

try
	
	poly_line_reg			= regions(poly_line);
	irmax						= length(poly_line_reg);
	if irmax>0
		mindz_linereg		= 1e6;
		maxdz_linereg		= 0;
		for ir=1:irmax
			z_poly_line		= interp2(...
				ELE.elefiltset(ifs_line,1).xm_mm,...			% X  coordinates of the sample points
				ELE.elefiltset(ifs_line,1).ym_mm,...			% Y  coordinates of the sample points
				ELE.elefiltset(ifs_line,1).zm_mm,...			% Z  function values at each sample point
				poly_line_reg(ir).Vertices(:,1),...			% Xq query points
				poly_line_reg(ir).Vertices(:,2));			% Yq query points
			dz_linereg		= max(z_poly_line)-min(z_poly_line);
			if dz_linereg<mindz_linereg
				mindz_linereg	= dz_linereg;
			end
			if dz_linereg>maxdz_linereg
				maxdz_linereg	= dz_linereg;
			end
		end
	else
		mindz_linereg	= 0;
		maxdz_linereg	= 1e6;
	end
	
catch ME
	errormessage('',ME);
end


