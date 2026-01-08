function frame2stl
%{
h1		height of the support (for raising the frame or space for a mounting plate)
h2		frame heigth
b1		inner frame width
b2		outer frame width
r1h	inner edge radius in horizontal direction
r1v	inner edge radius in vertical direction
r2h	outer edge radius in horizontal direction
r2v	outer edge radius in vertical direction
d1		vertical distance between tile bottom and frame bearing surface (Manufacturing tolerance)
d2		horizontal distance between tile and frame (Manufacturing tolerance)
ds		distance between the vertices of the inner and outer edge roundings
Sketch of the cross-section through tile and frame:
Frame style no. 1:
  -         -----------------------         |
  ^        /^                     ^\        |
  |       / |                     | \       |
  |      /  |r2v               r1v|  \      |tile
  |     /   |                     |   \     |
  |    /    v                     v    \    |
  |   |<--->+                     +<--->|   |
  |   | r2h                         r1h |   |
  |   |                                 |   |
h2|   |                                 |   |
  |   |                                 |   |
  |   |             Frame               |   |
  |   |                                 |   |
  |   |                                 |   |
  |   |                                 |   |  d1
  |   |                              -->|---|<---      |d2
  v   |                                 |   |          v         tile bottom
  -   |                                 |  0+-------------------------------
  ^   |                                 |   0          |
  |   |                                 +---------------------+
h1|   |                                                ^      |
  |   |                                                |      |
  v   |                                                       |
  -   +-------------------------------------------------------+
      |            b2 (framewidth)          |        b1       |
      |<----------------------------------->|<--------------->|
%}

global GV GV_H PP PRINTDATA

try
	
	if isempty(PP)
		errortext	= sprintf([...
			'The project parameters have not yet been loaded.\n',...
			'First load the project parameters.']);
		errormessage(errortext);
	end
	
	if PP.frame.framestyle==0
		display_on_gui('state','Creating frame canceled: frame.framestyle=0!','notbusy','add');
		return
	end
	
	if PP.frame.b2==0
		display_on_gui('state','Creating frame canceled: frame.b2=0!','notbusy','add');
		return
	end
	
	% At the moment there is only one frame style:
	if PP.frame.framestyle~=1
		display_on_gui('state','Creating frame canceled: frame.framestyle~=1!','notbusy','add');
		return
	end
	
	% Display state:
	t_start_statebusy	= clock;
	display_on_gui('state','Creating frame ...','busy','add');
	
	% Set the value of the cutting lines dropdown menu to 'None' (make the map objects visible):
	set_previewtype_dropdown(1);
	
	% Initializations:
	tol_1					= 1e-6;
	plot_whole_parts	= 1;
	
	% User input:
	testdata			= 0;
	tile_no_test	= [];							% vector of tile numbers ([]: show all)
	if testdata==1
		h1			= 13.8;
		h2			= 11.2;		% 9
		b1			= 10;
		b2			= 20;		% 10.9
		ds			= 4;
		d1			= 0.2;
		d2			= 12;
		r1h		= 8;
		r1v		= 8;
		r2h		= 8;
		r2v		= 8;
		color_no	= 30;
	elseif testdata==0
		fn		= fieldnames(PP.frame);
		prompt	= cell(1,size(fn,1));
		definput	= cell(1,size(fn,1));
		for i=1:size(fn,1)
			prompt{1,i}		= sprintf('%s: %s',fn{i,1},PP.DESCRIPTION.frame{1,1}.(fn{i,1}){1,1});
			dlgtitle			= 'Enter frame dimensions';
			dims				= [1 80];
			definput{1,i}	= num2str(PP.frame.(fn{i,1}));
		end
		answer = inputdlg_local(prompt,dlgtitle,dims,definput);
		if ~isequal(size(answer,1),size(fn,1))
			% Cancel:
			display_on_gui('state',sprintf('Creating frame ... canceled.'),'notbusy','replace');
			return
		end
		answer_num_v	= zeros(size(fn,1),1);
		for i=1:size(fn,1)
			answer_num	= str2double(answer{i,1});
			if ~isnan(answer_num)
				answer_num_v(i,1)	= answer_num;
			else
				errormessage(sprintf([...
					'Error:\n',...
					'The value "%s=%s" must be numeric and scalar.'],...
					fn{i,1},answer{i,1}));
			end
		end
		h2		= 0;
		b2		= 0;
		ds		= 0;
		for i=1:size(fn,1)
			command	= sprintf('%s=answer_num_v(%g,1);',fn{i,1},i);
			eval(command);
		end
		if (h2<=0)||(b2<=0)||(ds<=0)
			errormessage(sprintf([...
				'Error:\n',...
				'Create frame STL files:\n',...
				'The following values must be greater than zero:\n',...
				'%s = %g mm\n',...
				'%s = %g mm\n',...
				'%s = %g mm\n'],...
				PP.DESCRIPTION.frame{1,1}.b2{1,1},b2,...
				PP.DESCRIPTION.frame{1,1}.h2{1,1},h2,...
				PP.DESCRIPTION.frame{1,1}.ds{1,1},ds));
		end
		for i=1:size(fn,1)
			command	= sprintf('PP.frame.%s=answer_num_v(%g,1);',fn{i,1},i);
			eval(command);
		end
	end
	
	% Face color:
	if (color_no>=1)&&(color_no<=size(PP.color,1))
		facecolor_frame	= PP.color(color_no,1).rgb/255;
		facecolor_frame	= color_rgb_improve(PP,facecolor_frame);
	else
		facecolor_frame	= 'w';
	end
	
	% Cross section values
	tol	= 0.001;						% horizontal distance between nearly vertical lines
	
	% Limit some values to a valid range:
	h1		= max(h1,0);
	h2		= max(h2,tol);
	b1		= max(b1,0);
	b2		= max(b2,tol);
	r1h	= max(r1h,0);
	r1v	= max(r1v,0);
	r2h	= max(r2h,0);
	ds		= max(ds,tol);
	d1		= max(d1,0);
	d2		= max(d2,0);
	
	% Inner edge rounding:
	dphi1	= min([ds/r1h;ds/r1v;pi/2]);		% rad
	dphi1	= pi/2/round(pi/2/dphi1);
	phi1	= (0:dphi1:(pi/2+dphi1/2))';
	cp1_x	= -d1-r1h;
	cp1_z	= h2-r1v;
	poly1_xz		= [...
		-d1+1   h2-r1v;...
		-d1+1   h2+1;...
		-d1-r1h h2+1;...
		cp1_x+r1h.*sin(phi1)	cp1_z+r1v.*cos(phi1)];
	poly1			= polyshape(poly1_xz(:,1),poly1_xz(:,2));
	ymin			= min(poly1.Vertices(:,2));
	if ymin<(-d2)
		xmin		= min(poly1.Vertices(:,1));
		xmax		= max(poly1.Vertices(:,1));
		poly1	= subtract(poly1,polyshape(...
			[xmin-1 xmax+1 xmax+1 xmin-1],...
			[ymin-1 ymin-1 -d2    -d2   ]));
	end
	
	% Outer edge rounding:
	dphi2	= min([ds/r2h;ds/r2v;pi/2]);		% rad
	dphi2	= pi/2/round(pi/2/dphi2);
	phi2	= (0:dphi2:(pi/2+dphi2/2))';
	cp2_x	= -b2+r2h;
	cp2_z	= h2-r2v;
	poly2_xz		= [...
		-b2+r2h h2+1;...
		-b2-1   h2+1;...
		-b2-1   h2-r2v;...
		cp2_x-r2h.*cos(phi2)	cp2_z+r2v.*sin(phi2)];
	poly2			= polyshape(poly2_xz(:,1),poly2_xz(:,2));
	ymin			= min(poly2.Vertices(:,2));
	if ymin<(-d2)
		xmin		= min(poly2.Vertices(:,1));
		xmax		= max(poly2.Vertices(:,1));
		poly2	= subtract(poly2,polyshape(...
			[xmin-1 xmax+1 xmax+1 xmin-1],...
			[ymin-1 ymin-1 -d2    -d2   ]));
	end
	
	% Frame without roundings:
	poly3_xz		= [...
		b1 -h1;...
		b1 -d2;...
		-d1 -d2;...
		-d1 h2;...
		-b2 h2;...
		-b2 -h1];
	
	% Frame with roundings:
	% figure,gca;hold on,axis equal,plot(poly1),plot(poly2),plot(poly3)
	poly3			= polyshape(poly3_xz(:,1),poly3_xz(:,2));
	poly3			= subtract(poly3,poly1);
	poly3			= subtract(poly3,poly2);
	if numboundaries(poly3)==0
		errormessage(sprintf([...
			'Error:\n',...
			'Invalid frame parameters:\n',...
			'The frame cross section is empty.']));
	end
	
	% Convert polygon vertices to clockwise order:
	[x3,y3]		= poly2cw(poly3.Vertices(:,1),poly3.Vertices(:,2));
	
	% Find the outer lowest point at x=-b2 and y=-h1:
	k1					= find((abs(x3+b2)<tol_1)&(abs(y3+h1)<tol_1));
	if ~isscalar(k1)
		errormessage;
	end
	% Find the inner lowest point at x=b1 and y=-h1:
	k2					= find((abs(x3-b1)<tol_1)&(abs(y3+h1)<tol_1));
	if ~isscalar(k2)
		errormessage;
	end
	% Start the cross section outline at the outer bottom:
	if k1<k2
		frame_cross_section_xz	= [...
			x3(k1:k2,1) y3(k1:k2,1)];
	else
		frame_cross_section_xz	= [...
			x3(k1:end,1) y3(k1:end,1);...
			x3(1:k2,1)   y3(1:k2,1)];
	end
	
	% Find the last point at x=-d1 (the printout limits):
	% This point should not be changed when calculating frame(tile_no,1).poly:
	kmax			= size(frame_cross_section_xz,1);
	k_printout	= kmax;
	while frame_cross_section_xz(k_printout,1)>(-d1+tol)
		k_printout	= k_printout-1;
	end
	
	% Changing the x values
	% - so that they increase strictly monotonically and
	% - so that these three points do not change:
	% frame_cross_section_xz(1 ,:)
	% frame_cross_section_xz(k_printout,:)
	% frame_cross_section_xz(end ,:)
	x_1				= frame_cross_section_xz(1         ,1);
	x_k_printout	= frame_cross_section_xz(k_printout,1);
	x_end				= frame_cross_section_xz(end       ,1);
	% Range start to k_printout:
	% Change x-values in forward direction:
	frame_cross_section_xz(1,1)		= x_1;
	for k=2:k_printout
		frame_cross_section_xz(k,1)	= max(...
			frame_cross_section_xz(k,1),...
			frame_cross_section_xz(k-1,1)+10*GV.tol_1);
	end
	% Change x-values in reverse direction:
	frame_cross_section_xz(k_printout,1)		= x_k_printout;
	for k=(k_printout-1):-1:1
		frame_cross_section_xz(k,1)	= min(...
			frame_cross_section_xz(k,1),...
			frame_cross_section_xz(k+1,1)-10*GV.tol_1);
	end
	% Range k_printout to end:
	% Change x-values in forward direction:
	frame_cross_section_xz(k_printout,1)		= x_k_printout;
	for k=(k_printout+1):size(frame_cross_section_xz,1)
		frame_cross_section_xz(k,1)	= max(...
			frame_cross_section_xz(k,1),...
			frame_cross_section_xz(k-1,1)+10*GV.tol_1);
	end
	% Change x-values in reverse direction:
	frame_cross_section_xz(end,1)		= x_end;
	for k=(size(frame_cross_section_xz,1)-1):-1:k_printout
		frame_cross_section_xz(k,1)	= min(...
			frame_cross_section_xz(k,1),...
			frame_cross_section_xz(k+1,1)-10*GV.tol_1);
	end
	% Security check:
	if    (abs(frame_cross_section_xz(1         ,1)-x_1         )>GV.tol_1)||...
			(abs(frame_cross_section_xz(k_printout,1)-x_k_printout)>GV.tol_1)||...
			(abs(frame_cross_section_xz(end       ,1)-x_end       )>GV.tol_1)
		errormessage;
	end
	
	% Cross section plot:
	if ~isfield(GV_H,'fig_frame_crosssection')
		GV_H.fig_frame_crosssection	= [];
	end
	if ~isfield(GV_H,'ax_frame_crosssection')
		GV_H.ax_frame_crosssection	= [];
	end
	if isempty(GV_H.fig_frame_crosssection)
		GV_H.fig_frame_crosssection	= figure;
		figure_theme(GV_H.fig_frame_crosssection,'set',[],'light');
	else
		if ~ishandle(GV_H.fig_frame_crosssection)
			GV_H.fig_frame_crosssection	= figure;
			figure_theme(GV_H.fig_frame_crosssection,'set',[],'light');
		end
	end
	clf(GV_H.fig_frame_crosssection,'reset');
	figure_theme(GV_H.fig_frame_crosssection,'set',[],'light');
	figure(GV_H.fig_frame_crosssection);
	set(GV_H.fig_frame_crosssection,'Tag','maplab3d_figure');
	set(GV_H.fig_frame_crosssection,'Name','Frame CS');
	set(GV_H.fig_frame_crosssection,'NumberTitle','off');
	cameratoolbar(GV_H.fig_frame_crosssection,'Show');
	GV_H.ax_frame_crosssection	= axes(GV_H.fig_frame_crosssection);
	hold(GV_H.ax_frame_crosssection,'on');
	grid(GV_H.ax_frame_crosssection,'on');
	axis(GV_H.ax_frame_crosssection,'equal');
	xlabel(GV_H.ax_frame_crosssection,'x / mm');
	ylabel(GV_H.ax_frame_crosssection,'y / mm');
	title(GV_H.ax_frame_crosssection,'Frame cross section');
	plot(GV_H.ax_frame_crosssection,frame_cross_section_xz(:,1),frame_cross_section_xz(:,2),'.-b','MarkerSize',12)
	if testdata==1
		plot(GV_H.ax_frame_crosssection,frame_cross_section_xz(k_printout,1),frame_cross_section_xz(k_printout,2),'xr')
		plot(GV_H.ax_frame_crosssection,frame_cross_section_xz(1,1),frame_cross_section_xz(1,2),'xb')
		text(GV_H.ax_frame_crosssection,frame_cross_section_xz(k_printout,1),frame_cross_section_xz(k_printout,2),...
			sprintf('k_printout=%1.0f',k_printout),...
			'Color','r',...
			'HorizontalAlignment','center',...
			'VerticalAlignment','top',...
			'Interpreter','none');
		text(GV_H.ax_frame_crosssection,frame_cross_section_xz(1,1),frame_cross_section_xz(1,2),...
			'k=1',...
			'Color','b',...
			'HorizontalAlignment','center',...
			'VerticalAlignment','top',...
			'Interpreter','none');
		text(GV_H.ax_frame_crosssection,frame_cross_section_xz(kmax,1),frame_cross_section_xz(kmax,2),...
			sprintf('kmax=%1.0f',kmax),...
			'Color','b',...
			'HorizontalAlignment','center',...
			'VerticalAlignment','top',...
			'Interpreter','none');
	end
	plot(GV_H.ax_frame_crosssection,cp1_x,cp1_z,'+b');
	plot(GV_H.ax_frame_crosssection,cp2_x,cp2_z,'+b');
	drawnow;
	
	% 3D view plot:
	if ~isfield(GV_H,'fig_frame_3dview')
		GV_H.fig_frame_3dview	= [];
	end
	if ~isfield(GV_H,'ax_frame_3dview')
		GV_H.ax_frame_3dview	= [];
	end
	if isempty(GV_H.fig_frame_3dview)
		GV_H.fig_frame_3dview	= figure;
		figure_theme(GV_H.fig_frame_3dview,'set',[],'light');
	else
		if ~ishandle(GV_H.fig_frame_3dview)
			GV_H.fig_frame_3dview	= figure;
			figure_theme(GV_H.fig_frame_3dview,'set',[],'light');
		end
	end
	clf(GV_H.fig_frame_3dview,'reset');
	figure_theme(GV_H.fig_frame_3dview,'set',[],'light');
	set(GV_H.fig_frame_3dview,'Tag','maplab3d_figure');
	set(GV_H.fig_frame_3dview,'Name','Frame 3DV');
	set(GV_H.fig_frame_3dview,'NumberTitle','off');
	cameratoolbar(GV_H.fig_frame_3dview,'Show');
	GV_H.ax_frame_3dview	= axes(GV_H.fig_frame_3dview);
	hold(GV_H.ax_frame_3dview,'on');
	grid(GV_H.ax_frame_3dview,'on');
	axis(GV_H.ax_frame_3dview,'equal');
	xlabel(GV_H.ax_frame_3dview,'x / mm');
	ylabel(GV_H.ax_frame_3dview,'y / mm');
	zlabel(GV_H.ax_frame_3dview,'z / mm');
	title(GV_H.ax_frame_3dview,'Frame 3d view');
	drawnow;
	
	if testdata~=0
		% Top view:
		hf2	= 194002;
		hf2=figure(hf2);
		clf(hf2,'reset')
		set(hf2,'Tag','maplab3d_figure');
		ha2=gca;
		hold(ha2,'on');
		grid(ha2,'on');
		plot(ha2,GV_H.poly_map_printout.Shape,'EdgeColor','b','FaceAlpha',0);
		axis(ha2,'equal')
	end
	
	% Enlargen the tiles at the margin of the map:
	poly_tiles	= polyshape();
	x_tiles		= [];
	y_tiles		= [];
	for tile_no=1:size(GV_H.poly_tiles,1)
		poly_tiles(tile_no,1)	= GV_H.poly_tiles{tile_no,1}.Shape;
		x_tiles		= [x_tiles;poly_tiles(tile_no,1).Vertices(:,1)];
		y_tiles		= [y_tiles;poly_tiles(tile_no,1).Vertices(:,2)];
	end
	x_tiles		= unique(x_tiles);
	y_tiles		= unique(y_tiles);
	for tile_no=1:size(GV_H.poly_tiles,1)
		poly_tiles(tile_no,1).Vertices(find(poly_tiles(tile_no,1).Vertices(:,1)==x_tiles(  1)),1) = x_tiles(  1)-1.2*b2;
		poly_tiles(tile_no,1).Vertices(find(poly_tiles(tile_no,1).Vertices(:,1)==x_tiles(end)),1) = x_tiles(end)+1.2*b2;
		poly_tiles(tile_no,1).Vertices(find(poly_tiles(tile_no,1).Vertices(:,2)==y_tiles(  1)),2) = y_tiles(  1)-1.2*b2;
		poly_tiles(tile_no,1).Vertices(find(poly_tiles(tile_no,1).Vertices(:,2)==y_tiles(end)),2) = y_tiles(end)+1.2*b2;
	end
	if testdata~=0
		for tile_no=1:size(GV_H.poly_tiles,1)
			plot(ha2,poly_tiles(tile_no,1),'EdgeColor','c','FaceAlpha',0);
		end
	end
	frame			= [];
	
	% Create polygons at every cross section outline vertex:
	for tile_no=1:size(poly_tiles,1)
		for k=k_printout:kmax
			if k==k_printout
				frame(tile_no,1).poly(k,1)	= GV_H.poly_map_printout.Shape;
				d		= -frame_cross_section_xz(k,1);
				km1	= k;
			else
				if (frame_cross_section_xz(k-1,1)-frame_cross_section_xz(k,1))>-tol
					frame_cross_section_xz(k:kmax,1)=frame_cross_section_xz(k:kmax,1)+tol;
				end
				d		= frame_cross_section_xz(k-1,1)-frame_cross_section_xz(k,1);
				km1	= k-1;
			end
			if strcmp(GV.jointtype_frame,'miter')
				frame(tile_no,1).poly(k,1)	= polybuffer(frame(tile_no,1).poly(km1,1),d,...
					'JointType',GV.jointtype_frame,'MiterLimit',GV.miterlimit_frame);
			else
				frame(tile_no,1).poly(k,1)	= polybuffer(frame(tile_no,1).poly(km1,1),d,...
					'JointType',GV.jointtype_frame);
			end
			if (testdata~=0)&&(any(tile_no==tile_no_test)||isempty(tile_no_test))
				plot(ha2,frame(tile_no,1).poly(k,1),'EdgeColor','g','FaceAlpha',0);
			end
		end
		for k=(k_printout-1):-1:1
			if k==(k_printout-1)
				frame(tile_no,1).poly(k,1)	= frame(tile_no,1).poly(k_printout,1);
			end
			if (frame_cross_section_xz(k+1,1)-frame_cross_section_xz(k,1))<tol
				frame_cross_section_xz(1:k,1)=frame_cross_section_xz(1:k,1)-tol;
			end
			d		= frame_cross_section_xz(k+1,1)-frame_cross_section_xz(k,1);
			if strcmp(GV.jointtype_frame,'miter')
				frame(tile_no,1).poly(k,1)	= polybuffer(frame(tile_no,1).poly(k+1,1),d,...
					'JointType',GV.jointtype_frame,'MiterLimit',GV.miterlimit_frame);
			else
				frame(tile_no,1).poly(k,1)	= polybuffer(frame(tile_no,1).poly(k+1,1),d,...
					'JointType',GV.jointtype_frame);
			end
			if (testdata~=0)&&(any(tile_no==tile_no_test)||isempty(tile_no_test))
				plot(ha2,frame(tile_no,1).poly(k,1),'EdgeColor','m','FaceAlpha',0);
			end
		end
	end
	plot(GV_H.ax_frame_crosssection,frame_cross_section_xz(:,1),frame_cross_section_xz(:,2),'.:b')
	
	% Get the frame area and number of parts (for the map2stl summary):
	PRINTDATA.frame				= [];
	PRINTDATA.frame.tile			= [];
	PRINTDATA.frame.color_no	= color_no;
	% Structure frame at this point:
	% frame(tile_no,1).poly(1,1)			outer polygon
	% frame(tile_no,1).poly(end,1)		inner polygon
	for tile_no=1:size(poly_tiles,1)
		frame(tile_no,1).poly_bottomside	= frame(tile_no,1).poly(1,1);
		frame(tile_no,1).poly_bottomside	= addboundary(...
			frame(tile_no,1).poly_bottomside,...
			frame(tile_no,1).poly(end,1).Vertices);
		frame(tile_no,1).poly_bottomside					= intersect(...
			frame(tile_no,1).poly_bottomside,...
			poly_tiles(tile_no,1),'KeepCollinearPoints',false);
		PRINTDATA.frame.tile(tile_no,1).area			= area(frame(tile_no,1).poly_bottomside);
		PRINTDATA.frame.tile(tile_no,1).no_regions	= length(regions(frame(tile_no,1).poly_bottomside));
		if testdata~=0
			plot(ha2,frame(tile_no,1).poly_bottomside,...
				'EdgeAlpha',0,...
				'FaceAlpha',0.05);
			set_breakpoint	= 1;
		end
	end
	
	% Add the start polygon (outer) to the end of frame(tile_no,1).poly (for calculating the bottom side):
	frame_cross_section_xz					= [frame_cross_section_xz;frame_cross_section_xz(1,:)];
	for tile_no=1:size(poly_tiles,1)
		frame(tile_no,1).poly(end+1,1)	= frame(tile_no,1).poly(1,1);
	end
	
	% Triangulation:
	for tile_no=1:size(poly_tiles,1)
		PRINTDATA.frame.tile(tile_no,1).T	= [];
		connways_margin					= connect_ways([]);
		frame(tile_no,1).P				= [];
		frame(tile_no,1).CL				= [];
		
		% Triangulation of the top and bottom side:
		for k=1:kmax
			% poly: space between two frame polygons:
			if k<kmax
				% top side:
				poly		= subtract(...
					frame(tile_no,1).poly(k  ,1),...		% outer-inner
					frame(tile_no,1).poly(k+1,1));
			else
				% bottom side:
				poly		= subtract(...
					frame(tile_no,1).poly(k+1,1),...		% outer-inner
					frame(tile_no,1).poly(k  ,1));
			end
			poly			= intersect(poly,poly_tiles(tile_no,1),'KeepCollinearPoints',false);
			if numboundaries(poly)>0
				% tile_no is not an inner tile:
				
				% Collect the points on the margins:
				if size(poly_tiles,1)>1
					poly_tile_buff		= polybuffer(poly_tiles(tile_no,1),-tol_1,...
						'JointType','miter','MiterLimit',2);
					% Add one extra point between two points of poly, where poly can be divided between two margins:
					poly_higher_res	= changeresolution_poly(poly,[],[],1);
					% TFin					= isinterior(poly_tile_buff,poly_higher_res.Vertices);
					TFin	= inpolygon(...								% faster than isinterior
						poly_higher_res.Vertices(:,1),...			% query points
						poly_higher_res.Vertices(:,2),...
						poly_tile_buff.Vertices(:,1),...				% polygon area
						poly_tile_buff.Vertices(:,2));
					margin_xy			= poly_higher_res.Vertices;
					margin_xy(TFin,:)	= nan;
					if (~any(~isnan(margin_xy(:,1))))||(~any(isnan(margin_xy(:,1))))
						errormessage;
					end
					while ~isnan(margin_xy(end,1))
						margin_xy	= [margin_xy(end,:);margin_xy(1:(end-1),:)];
					end
					[xc,yc] = polysplit(margin_xy(:,1),margin_xy(:,2));
					for ixc=1:size(xc,1)
						% Delete the extra points:
						xyc_v								= xc{ixc,1}+1i*yc{ixc,1};
						imax								= length(xyc_v)-1;
						i									= 1:imax;
						direction						= angle(xyc_v(i+1)-xyc_v(i));
						i_same_direction				= find(abs(direction(1:(imax-1))-direction(2:imax))<1e-6);
						xyc_v(i_same_direction+1)	= [];
						% Assign connways_margin:
						connways_margin				= connect_ways(connways_margin,[],real(xyc_v),imag(xyc_v));
					end
				end
				% Triangulate the space between two frame polygons:
				t_poly1							= triangulation(poly);
				% t_poly2: because the property 'Points' of t_poly1 is read only:
				t_poly2							= [];
				t_poly2.Points					= t_poly1.Points;
				t_poly2.ConnectivityList	= t_poly1.ConnectivityList;
				% add the z-values:
				d		= (frame_cross_section_xz(k+1,1)-frame_cross_section_xz(k,1))/2;
				if strcmp(GV.jointtype_frame,'miter')
					poly_middle	= polybuffer(frame(tile_no,1).poly(k+1,1),d,...
						'JointType',GV.jointtype_frame,'MiterLimit',GV.miterlimit_frame);
				else
					poly_middle	= polybuffer(frame(tile_no,1).poly(k+1,1),d,...
						'JointType',GV.jointtype_frame);
				end
				% TFin = isinterior(poly_middle,poly.Vertices);
				TFin	= inpolygon(...							% faster than isinterior
					poly.Vertices(:,1),...						% query points
					poly.Vertices(:,2),...
					poly_middle.Vertices(:,1),...				% polygon area
					poly_middle.Vertices(:,2));
				poly_Vertices	= poly.Vertices;
				poly_Vertices	= [poly_Vertices zeros(size(poly_Vertices,1),1)];
				poly_Vertices( TFin,3)	= frame_cross_section_xz(k+1,2);
				poly_Vertices(~TFin,3)	= frame_cross_section_xz(k  ,2);
				t_poly2.Points	= [t_poly2.Points zeros(size(t_poly2.Points,1),1)];
				for i_p=1:size(poly_Vertices,1)
					if ~isnan(poly_Vertices(i_p,1))
						i_TP		= find(...
							(abs(poly_Vertices(i_p,1)-t_poly2.Points(:,1))<tol_1)&...
							(abs(poly_Vertices(i_p,2)-t_poly2.Points(:,2))<tol_1)    );
						if length(i_TP)==1
							t_poly2.Points(i_TP,3)	= poly_Vertices(i_p,3);
						else
							i_p
							poly_Vertices
							t_poly2.Points
							i_TP
							errormessage;
						end
					end
				end
				% t_poly: will be modified:
				t_poly		= t_poly2;
				
				% Add the results to T:
				if k==1
					frame(tile_no,1).P	= t_poly.Points;
					frame(tile_no,1).CL	= t_poly.ConnectivityList;
				else
					for i_t=1:size(t_poly.Points,1)
						% Row of current point in frame(tile_no,1).P:
						i_TP		= find(...
							(abs(frame(tile_no,1).P(:,1)-t_poly.Points(i_t,1))<tol_1)&...
							(abs(frame(tile_no,1).P(:,2)-t_poly.Points(i_t,2))<tol_1)&...
							(abs(frame(tile_no,1).P(:,3)-t_poly.Points(i_t,3))<tol_1)    );
						if isempty(i_TP)
							% The current point with the index i_t does not yet exist in frame(tile_no,1).P:
							frame(tile_no,1).P		= [frame(tile_no,1).P;t_poly.Points(i_t,:)];
							i_TP			= size(frame(tile_no,1).P,1);
							% 					if (testdata~=0)&&(any(tile_no==tile_no_test)||isempty(tile_no_test))
							% 						plot(ha2,frame(tile_no,1).P(i_TP,1),frame(tile_no,1).P(i_TP,2),...
							% 							'LineWidth',1,'LineStyle','none','Color','b','Marker','.','MarkerSize',15);
							% 					end
						elseif length(i_TP)==1
							% The current point with the index i_t already exists in frame(tile_no,1).P:
							% 					if (testdata~=0)&&(any(tile_no==tile_no_test)||isempty(tile_no_test))
							% 						plot(ha2,frame(tile_no,1).P(i_TP,1),frame(tile_no,1).P(i_TP,2),...
							% 							'LineWidth',1,'LineStyle','none','Color','r','Marker','.','MarkerSize',15);
							% 					end
						else
							canceliferror	= 1;
							if canceliferror==0
								i_TP	= i_TP(1);
							else
								% Cancel:
								eval('i_TP,size_i_TP=size(i_TP)');
								for i=1:length(i_TP)
									fprintf(1,'frame(tile_no,1).P(%g,1)=[%g   %g   %g]\n',...
										i_TP(i),...
										frame(tile_no,1).P(i_TP(i),1),...
										frame(tile_no,1).P(i_TP(i),2),...
										frame(tile_no,1).P(i_TP(i),3));
								end
								for i=2:length(i_TP)
									fprintf(1,'frame(tile_no,1).P(%g,:)-frame(tile_no,1).P(%g,:)=[%g   %g   %g]\n',...
										i_TP(i-1),i_TP(i),...
										frame(tile_no,1).P(i_TP(i-1),1)-frame(tile_no,1).P(i_TP(i),1),...
										frame(tile_no,1).P(i_TP(i-1),2)-frame(tile_no,1).P(i_TP(i),2),...
										frame(tile_no,1).P(i_TP(i-1),3)-frame(tile_no,1).P(i_TP(i),3));
								end
								errormessage;
							end
						end
						% Replace the index in t_poly.Points with the index in frame(tile_no,1).P:
						t_poly.ConnectivityList(t_poly2.ConnectivityList==i_t)	= i_TP;
					end
				end
				% 		% Indices der neu hinzugefügten Dreiecke in frame(tile_no,1).CL:
				% 		i_TCL					= (...
				% 			(size(frame(tile_no,1).CL,1)+1):(...
				% 			size(frame(tile_no,1).CL,1)+size(t_poly.ConnectivityList,1)))';
				% frame(tile_no,1).CL erweitern:
				frame(tile_no,1).CL	= [frame(tile_no,1).CL;t_poly.ConnectivityList];
				
				if plot_whole_parts==0
					if any(tile_no==tile_no_test)||isempty(tile_no_test)
						Tplot3=triangulation(t_poly2.ConnectivityList,t_poly2.Points);
						axes(GV_H.ax_frame_3dview);
						trisurf(Tplot3,'FaceColor',facecolor_frame);
						view(3);
					end
				end
				
			end
			
		end
		
		if ~isempty(connways_margin.areas)
			% tile_no is not an inner tile:
			
			% add the z-values to the margin:
			if size(poly_tiles,1)>1
				for i_area	= 1:size(connways_margin.areas,1)
					connways_margin.areas(i_area,1).xyz	= [...
						connways_margin.areas(i_area,1).xy(:,1:2) ...
						zeros(size(connways_margin.areas(i_area,1).xy,1),1)];
					for r=1:size(connways_margin.areas(i_area,1).xy,1)
						i		= find(...
							(abs(frame(tile_no,1).P(:,1)-connways_margin.areas(i_area,1).xy(r,1))<tol_1)&...
							(abs(frame(tile_no,1).P(:,2)-connways_margin.areas(i_area,1).xy(r,2))<tol_1)    );
						if length(i)==1
							connways_margin.areas(i_area,1).xyz(r,3)	= frame(tile_no,1).P(i,3);
						else
							errormessage;
						end
					end
				end
			end
			
			% Triangulation of the margin:
			if size(poly_tiles,1)>1
				for i_area	= 1:size(connways_margin.areas,1)
					
					if ~any(~(abs(connways_margin.areas(i_area,1).xyz(:,1)-connways_margin.areas(i_area,1).xyz(1,1))<tol_1))
						% All x-values are equal: triangulate the yz-plane:
						poly						= polyshape(...
							connways_margin.areas(i_area,1).xyz(:,2),...
							connways_margin.areas(i_area,1).xyz(:,3));
						t_poly1					= triangulation(poly);
						t_poly2					= [];
						t_poly2.Points			= [                                                   ...
							ones(size(t_poly1.Points,1),1)*connways_margin.areas(i_area,1).xyz(1,1) ...
							t_poly1.Points(:,1)                                                     ...
							t_poly1.Points(:,2)                                                        ];
						t_poly2.ConnectivityList	= t_poly1.ConnectivityList;
						frame(tile_no,1).CL	= [frame(tile_no,1).CL;t_poly2.ConnectivityList+size(frame(tile_no,1).P,1)];
						frame(tile_no,1).P	= [frame(tile_no,1).P ;t_poly2.Points];
					elseif ~any(~(abs(connways_margin.areas(i_area,1).xyz(:,2)-connways_margin.areas(i_area,1).xyz(1,2))<tol_1))
						% All y-values are equal: triangulate the xz-plane:
						poly						= polyshape(...
							connways_margin.areas(i_area,1).xyz(1:(end-1),1),...
							connways_margin.areas(i_area,1).xyz(1:(end-1),3));
						t_poly1					= triangulation(poly);
						t_poly2					= [];
						t_poly2.Points			= [                                                   ...
							t_poly1.Points(:,1)                                                     ...
							ones(size(t_poly1.Points,1),1)*connways_margin.areas(i_area,1).xyz(1,2) ...
							t_poly1.Points(:,2)                                                         ];
						t_poly2.ConnectivityList	= t_poly1.ConnectivityList;
						frame(tile_no,1).CL	= [frame(tile_no,1).CL;t_poly2.ConnectivityList+size(frame(tile_no,1).P,1)];
						frame(tile_no,1).P	= [frame(tile_no,1).P ;t_poly2.Points];
					else
						errormessage;
					end
					
					if plot_whole_parts==0
						if any(tile_no==tile_no_test)||isempty(tile_no_test)
							Tplot3=triangulation(t_poly2.ConnectivityList,t_poly2.Points);
							axes(GV_H.ax_frame_3dview);
							trisurf(Tplot3,'FaceColor',facecolor_frame);
							view(3);
						end
					end
					
				end
			end
			
		end
		
		% Create a valid "triangulation object":
		if ~isempty(frame(tile_no,1).P)
			% tile_no is not an inner tile:
			
			% Save the part to PRINTDATA, so the frame can be displayed together with the whole map:
			PRINTDATA.frame.tile(tile_no,1).T	= triangulation(frame(tile_no,1).CL,frame(tile_no,1).P);
			
			% For printing, the parts are lowered onto the printing plate:
			T_print							= struct;
			T_print.ConnectivityList	= frame(tile_no,1).CL;
			T_print.Points					= frame(tile_no,1).P;
			T_print.Points(:,3)			= T_print.Points(:,3)-min(T_print.Points(:,3));
			T_print							= triangulation(T_print.ConnectivityList,T_print.Points);
			if plot_whole_parts~=0
				if any(tile_no==tile_no_test)||isempty(tile_no_test)
					Tplot3=triangulation(T_print.ConnectivityList,T_print.Points);
					axes(GV_H.ax_frame_3dview);
					trisurf(Tplot3,'FaceColor',facecolor_frame);
					view(3);
				end
			end
			
			% xy range:
			PRINTDATA.frame.tile(tile_no,1).xmin	= min(T_print.Points(:,1));
			PRINTDATA.frame.tile(tile_no,1).xmax	= max(T_print.Points(:,1));
			PRINTDATA.frame.tile(tile_no,1).ymin	= min(T_print.Points(:,2));
			PRINTDATA.frame.tile(tile_no,1).ymax	= max(T_print.Points(:,2));
			if PRINTDATA.frame.tile(tile_no,1).xmin<0
				PRINTDATA.frame.tile(tile_no,1).xmin_str	= sprintf('m%04.0f',abs(PRINTDATA.frame.tile(tile_no,1).xmin));
			else
				PRINTDATA.frame.tile(tile_no,1).xmin_str	= sprintf('p%04.0f',PRINTDATA.frame.tile(tile_no,1).xmin);
			end
			if PRINTDATA.frame.tile(tile_no,1).xmax<0
				PRINTDATA.frame.tile(tile_no,1).xmax_str	= sprintf('m%04.0f',abs(PRINTDATA.frame.tile(tile_no,1).xmax));
			else
				PRINTDATA.frame.tile(tile_no,1).xmax_str	= sprintf('p%04.0f',PRINTDATA.frame.tile(tile_no,1).xmax);
			end
			if PRINTDATA.frame.tile(tile_no,1).ymin<0
				PRINTDATA.frame.tile(tile_no,1).ymin_str	= sprintf('m%04.0f',abs(PRINTDATA.frame.tile(tile_no,1).ymin));
			else
				PRINTDATA.frame.tile(tile_no,1).ymin_str	= sprintf('p%04.0f',PRINTDATA.frame.tile(tile_no,1).ymin);
			end
			if PRINTDATA.frame.tile(tile_no,1).ymax<0
				PRINTDATA.frame.tile(tile_no,1).ymax_str	= sprintf('m%04.0f',abs(PRINTDATA.frame.tile(tile_no,1).ymax));
			else
				PRINTDATA.frame.tile(tile_no,1).ymax_str	= sprintf('p%04.0f',PRINTDATA.frame.tile(tile_no,1).ymax);
			end
			
			%------------------------------------------------------------------------------------------------
			% Export as STL-file:
			% File name:			PROJECTFILENAME-Cxxx-Txxx-a-b-c-Xde-Yfg-zmin hmm-zcenter imm
			% legend:
			% T	tile number
			% C	color number
			% optional:
			% a	PP.color(colno,1).description					REPLACED BY 'Frame' !!!
			% b	PP.color(colno,1).brand
			% c	PP.color(colno,1).color_short_text
			% X	x coordinates
			% d	PRINTDATA.frame.tile(tile_no,1).xmin_str
			% e	PRINTDATA.frame.tile(tile_no,1).xmax_str
			% Y	y coordinates
			% f	PRINTDATA.frame.tile(tile_no,1).ymin_str
			% g	PRINTDATA.frame.tile(tile_no,1).ymax_str
			% h	min(T_print.Points(:,3))
			% i	(min(T_print.Points(:,3))+max(T_print.Points(:,3)))/2
			%------------------------------------------------------------------------------------------------
			
			% Filename:
			filename_text				= GV.pp_projectfilename;
			filename_text				= validfilename(filename_text);
			color_tile_file_text		= sprintf('-C%03.0f',color_no);
			if size(poly_tiles,1)==1
				tile_text				= '';
			else
				tile_text				= sprintf('-T%03.0f',tile_no);
				tile_text				= validfilename(tile_text);
			end
			color_tile_file_text		= sprintf('%s%s',color_tile_file_text,tile_text);
			color_tile_file_text		= validfilename(color_tile_file_text);
			% if PP.general.save_filename.color_description==0
			% 	color_description_text		= '';
			% else
			% 	color_description_text		= sprintf('-%s',PP.color(color_no,1).description);
			% 	color_description_text		= validfilename(color_description_text);
			% end
			color_description_text	= '-Frame';
			if PP.general.save_filename.color_brand==0
				color_brand_text		= '';
			else
				color_brand_text		= sprintf('-%s',PP.color(color_no,1).brand);
				color_brand_text		= validfilename(color_brand_text);
			end
			if PP.general.save_filename.color_short_text==0
				color_short_text		= '';
			else
				color_short_text		= sprintf('-%s',PP.color(color_no,1).color_short_text);
				color_short_text		= validfilename(color_short_text);
			end
			if PP.general.save_filename.tilecoordinates==0
				tilecoordinates_text	= '';
			else
				tilecoordinates_text	= sprintf('-X%s%s-Y%s%s',...
					PRINTDATA.frame.tile(tile_no,1).xmin_str,PRINTDATA.frame.tile(tile_no,1).xmax_str,...
					PRINTDATA.frame.tile(tile_no,1).ymin_str,PRINTDATA.frame.tile(tile_no,1).ymax_str);
				tilecoordinates_text	= validfilename(tilecoordinates_text);
			end
			if PP.general.save_filename.zmin==0
				zmin_text				= '';
			else
				zmin_text				= sprintf('-zmin %1.3fmm',min(T_print.Points(:,3)));
				% Do not use validfilename here so that the decimal point is not deleted.
			end
			if PP.general.save_filename.zcenter==0
				zcenter_text			= '';
			else
				zcenter_text			= sprintf('-zcenter %1.3fmm',(min(T_print.Points(:,3))+max(T_print.Points(:,3)))/2);
				% Do not use validfilename here so that the decimal point is not deleted.
			end
			filename_stl				= sprintf('%s%s%s%s%s%s%s%s',...
				filename_text,...
				color_tile_file_text,...
				color_description_text,...
				color_brand_text,...
				color_short_text,...
				tilecoordinates_text,...
				zmin_text,...
				zcenter_text);
			PRINTDATA.frame.tile(tile_no,1).filename_stl		= filename_stl;
			
			% Create the project directories if necessary:
			if ~isfield(GV,'projectdirectory_stl')
				get_projectdirectory;				% Assign GV.projectdirectory_stl
			else
				if exist(GV.projectdirectory_stl,'dir')~=7
					get_projectdirectory;			% Assign GV.projectdirectory_stl
				end
			end
			if ~isfield(GV,'projectdirectory_stl_repaired')
				get_projectdirectory;				% Assign GV.projectdirectory_stl_repaired
			else
				if exist(GV.projectdirectory_stl_repaired,'dir')~=7
					get_projectdirectory;			% Assign GV.projectdirectory_stl_repaired
				end
			end
			
			% Save the STL files:
			path_filename_stl	= [GV.projectdirectory_stl filename_stl '.stl'];
			stlwrite(T_print,path_filename_stl);
			fprintf(1,'File %s saved\n',path_filename_stl);
			% Try to repair and save the STL files:
			try
				[T_print_rep,status]	= stlrepair(T_print);
			catch ME
				if ~isdeployed
					errormessage('',ME);
				else
					status			= 0;
				end
			end
			if status==0
				% the repair was not successful:
				T_print_rep			= T_print;
				path_filename_stl	= [GV.projectdirectory_stl_repaired filename_stl ' - to be repaired.stl'];
			else
				path_filename_stl	= [GV.projectdirectory_stl_repaired filename_stl '.stl'];
			end
			stlwrite(T_print_rep,path_filename_stl);
			fprintf(1,'File %s saved\n',path_filename_stl);
			
		end
		
	end
	
	% Plot the frame into the 3D map (GV_H.ax_stldata_map), if it exists:
	plot_stldata_map_frame(PP,...
		1,...			% plot_mapobj
		0);			% create_axis
	
	% Plot the frame into the 2D map (GV_H.ax_2dmap):
	% Plot the frame: First plot_poly_map_printout must be called! --> here not necessary
	plot_2dmap_frame;
	% Plot the tiles: First plot_2dmap_frame must be called!
	% tile_no = i: Edges of the tiles:
	% The min and max values can be outside the edge of the entire map.
	plot_poly_tiles;
	% Create/modify legend:
	create_legend_mapfigure;
	
	% Last steps: Save '... - map2stl summary.txt':
	map_pathname_stl		= '';				% Only required if save_maptopview=true
	save_ppbackup			= false;
	save_summary			= true;
	save_maptopview		= false;
	map2stl_completion(PP,map_pathname_stl,save_ppbackup,save_summary,save_maptopview);
	
	% Display state:
	display_on_gui('state',...
		sprintf('Creating frame ... done (%s).',dt_string(etime(clock,t_start_statebusy))),...
		'notbusy','replace');
	
catch ME
	errormessage('',ME);
end

