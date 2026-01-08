function [poly_bgd,poly_obj]=image2poly(...
	obj_image,height_image,rotation,obj_extent,no_frame,par_frame,no_bgd,par_bgd,testplot)
% Converts an image to a polygon.
% The origin of the data (x=0, y=0) is set to the middle of the image.
%
% poly_obj			polygon of all the objects in the image
% poly_bgd			polygon that connects all single regions in poly_obj, method see below (Initialization, no_bgd)
% obj_image			image to convert
% height_image		height of the polygon to create, data units
% rotation			object orientation, specified as a scalar value in degrees (the frame will also be rotated)
% obj_extent		Size and location of rectangle that encloses the object (units normalized)
%						If the object is a text string, this information can be used to place the baseline more precisely
%						obj_extent=[]:		objekt dimensions are used to calculate the baseline
% no_frame			number of the method to create the frame around the objects, method see below (Initialization)
% par_frame			cell array of parameters to create the frame around the object
% no_bgd				number of the method to create the background polygon, method see below (Initialization)
% par_bgd			cell array of parameters to create the background polygon
% testplot			Opens a figure and shows the result of the conversion (1=on, 0=off)
%{
--------------------------------------------------------------------------------|
no_frame=1:
No frame
--------------------------------------------------------------------------------|
no_frame=2:
Rectangular frame:
par_frame{1} = frame width (>0) / mm
par_frame{2} = distance between frame and objects / mm
par_frame{3} = radius of the frame corners (>=0) / mm
par_frame{4} = sampling     number of edges of a semicircle
                            The frame corners consist of sampling/2 edges.
                            Examples: sampling=
                            1: special case:     1 point  / 0 edges per corner
                            2: 90° miter square: 2 points / 1 edge  per corner
                            4: 90° miter square: 3 points / 2 edge  per corner
                            6: 30° miter square: 4 points / 3 edges per corner
                               higher values increase the execution time
--------------------------------------------------------------------------------|
no_bgd=1:
No background
Use background number 1 only with non stand-alone colors!
--------------------------------------------------------------------------------|
no_bgd=2:
Rectangular background:
par_bgd{1} = distance between background margin and foreground objects / mm
par_bgd{2} = radius of the background corners (>=0) / mm
par_bgd{3} = sampling       number of edges of a semicircle
                            The background corners consist of sampling/2 edges.
                            Examples: sampling=
                            1: special case:     1 point  / 0 edges per corner
                            2: 90° miter square: 2 points / 1 edge  per corner
                            4: 45° miter square: 3 points / 2 edge  per corner
                            6: 30° miter square: 4 points / 3 edges per corner
                               higher values increase the execution time
--------------------------------------------------------------------------------|
no_bgd=3:
Convex hull background:
par_bgd{1} = distance between background margin and foreground objects / mm
--------------------------------------------------------------------------------|
no_bgd=4:
Connect all objects with lines:
par_bgd{1} = draw one baseline to connect most objects(0/1)
par_bgd{2} = remove/fill holes (0/1)
par_bgd{3} = connect all remaining unconnected objects with lines (0/1)
par_bgd{4} = Position of the baseline (depends on the font) / %
par_bgd{5} = background line width (>0) / mm
par_bgd{6} = sampling       The ends of the lines consists of semicircles,
                            the center is equal to the first and last point
                            of x and y. The number of edges of a semicircle
                            is defined by sampling. Examples: sampling=
                            2: minimum value: two edges
                            6: should be the standard value for lines:
                               higher values increase the execution time
--------------------------------------------------------------------------------|
no_bgd=5:
Connect only objects with lines, whose x-values overlap:
In most cases this should result in individual letters being connected, e. g.: connect the dot on the i.
In certain cases it will not work, for example the single character " will be printed as two separate objects.
This setting could be useful when printing large fonts with extra character spacing.
par_bgd{1} = remove/fill holes (0/1)
par_bgd{2} = background line width (>0) / mm
par_bgd{3} = sampling       The ends of the lines consists of semicircles,
                            the center is equal to the first and last point
                            of x and y. The number of edges of a semicircle
                            is defined by sampling. Examples: sampling=
                            2: minimum value: two edges
                            6: should be the standard value for lines:
                               higher values increase the execution time
--------------------------------------------------------------------------------|
%}

global GV

try

	% Initializations:
	if nargin<2
		height_image	= 10;
	end
	if nargin<3
		rotation			= 0;
	end
	if nargin<4
		obj_extent		= [];
	end
	if nargin<5
		no_frame			= 1;
	end
	if nargin<6
		par_frame		= cell(0,0);
	end
	if nargin<7
		no_bgd			= 5;
	end
	if nargin<8
		par_bgd			= cell(0,0);
	end
	if nargin<9
		testplot			= 0;
	end
	switch no_frame
		case 1
			% no frame
		case 2
			% rectangular frame:
			frame_width						= 0.5;			% frame width
			frame_distance					= 0.5;			% distance from objects
			frame_radiuscorners			= 0.5;			% radius of the background corners
			frame_sampling					= 4;				% number of edges of a semicircle
			if length(par_frame)>=1; frame_width					= par_frame{1}; end
			if length(par_frame)>=2; frame_distance				= par_frame{2}; end
			if length(par_frame)>=3; frame_radiuscorners			= par_frame{3}; end
			if length(par_frame)>=4; frame_sampling				= par_frame{4}; end
			frame_width				= max(frame_width          ,0);
			frame_radiuscorners	= max(frame_radiuscorners  ,0);
			frame_sampling			= max(round(frame_sampling),1);
	end
	switch no_bgd
		case 1
			% no background
		case 2
			% Rectangular background:
			bgd_distance					= 0.5;			% distance from objects (including frame if it exists)
			bgd_radiuscorners				= 0.5;			% radius of the background corners
			bgd_sampling					= 4;				% number of edges of a semicircle
			if length(par_bgd)>=1; bgd_distance							= par_bgd{1}; end
			if length(par_bgd)>=2; bgd_radiuscorners					= par_bgd{2}; end
			if length(par_bgd)>=3; bgd_sampling							= par_bgd{3}; end
			bgd_radiuscorners		= max(bgd_radiuscorners  ,0);
			bgd_sampling			= max(round(bgd_sampling),1);
		case 3
			% Convex hull background:
			bgd_distance					= 0.5;			% bgd_distance distance from objects
			if length(par_bgd)>=1; bgd_distance							= par_bgd{1}; end
		case 4
			% Connect all the objects with lines:
			bgd_draw_baseline				= 0;				% 0/1
			bgd_remove_holes				= 0;				% 0/1
			bgd_connect_regions			= 1;				% 0/1
			bgd_pos_baseline_percent	= 20;				% unit: percent
			bgd_linewidth					= 0.8;			% data units
			bgd_sampling					= 6;				% number of edges of a semicircle
			if length(par_bgd)>=1; bgd_draw_baseline					= par_bgd{1}; end
			if length(par_bgd)>=2; bgd_remove_holes					= par_bgd{2}; end
			if length(par_bgd)>=3; bgd_connect_regions				= par_bgd{3}; end
			if length(par_bgd)>=4; bgd_pos_baseline_percent			= par_bgd{4}; end
			if length(par_bgd)>=5; bgd_linewidth						= par_bgd{5}; end
			if length(par_bgd)>=6; bgd_sampling							= par_bgd{6}; end
			bgd_pos_baseline_percent	= max(bgd_pos_baseline_percent,  0);
			bgd_pos_baseline_percent	= min(bgd_pos_baseline_percent,100);
			bgd_linewidth					= max(bgd_linewidth,             0);
			bgd_sampling					= max(round(bgd_sampling),       2);
		case 5
			% Connect only objects with lines, whose x-values overlap:
			% In most cases this should result in individual letters being connected, e. g.: connect the dot on the i.
			bgd_remove_holes				= 0;				% 0/1
			bgd_linewidth					= 0.8;			% data units
			bgd_sampling					= 6;				% number of edges of a semicircle
			if length(par_bgd)>=1; bgd_remove_holes					= par_bgd{1}; end
			if length(par_bgd)>=2; bgd_linewidth						= par_bgd{2}; end
			if length(par_bgd)>=3; bgd_sampling							= par_bgd{3}; end
			bgd_linewidth					= max(bgd_linewidth,             0);
			bgd_sampling					= max(round(bgd_sampling),       2);
	end
	smoothing		= 1;			% 0/1
	testplot1		= false;		% T,F inner and outer contour
	testplot2		= false;		% T,F contour smoothing
	testplot3		= false;		% T,F no_bgd=5
	ktest				= -1;			% select a single outline / all: -1
	ha_testplot1	= [];
	ha_testplot2	= [];
	nx					= size(obj_image,2);
	ny					= size(obj_image,1);
	w_image			= height_image*size(obj_image,2)/size(obj_image,1);
	xmin				= -w_image/2;
	ymin				= -height_image/2;
	xmax				= w_image/2;
	ymax				= height_image/2;

	% Testplots:
	if testplot==1
		hf_testplot	= figure(100000);
		clf(hf_testplot,'reset');
		set(hf_testplot,'Tag','maplab3d_figure');
		ha_testplot	= gca;
		hold(ha_testplot,'on');
		set(ha_testplot,'Clipping','off');
		axis(ha_testplot,'equal');
	end
	if testplot1
		hf_testplot1	= figure(100001);
		clf(hf_testplot1,'reset');
		set(hf_testplot1,'Tag','maplab3d_figure');
		ha_testplot1	= gca;
		map(1,:)	= [1 1 1]*0.0;				% objects
		map(2,:)	= [1 1 1];					% background (white)
		colormap(hf_testplot1,map);
		image(ha_testplot1,obj_image,'CDataMapping','scaled');
		hold(ha_testplot1,'on');
		set(ha_testplot1,'XLim',[1 nx]);
		set(ha_testplot1,'YLim',[1 ny]);
		set(ha_testplot1,'Clipping','off');
		axis(ha_testplot1,'equal');
	end
	if testplot2
		hf_testplot2	= figure(100002);
		clf(hf_testplot2,'reset');
		set(hf_testplot2,'Tag','maplab3d_figure');
		ha_testplot2	= gca;
		map(1,:)	= [1 1 1]*0.8;				% objects
		map(2,:)	= [1 1 1];					% background (white)
		colormap(hf_testplot2,map);
		image(ha_testplot2,...
			[xmin,xmax],...
			[ymin,ymax],...
			obj_image(end:-1:1,:),...
			'CDataMapping','scaled');
		set(ha_testplot2,'YDir','normal');
		hold(ha_testplot2,'on');
		set(ha_testplot2,'Clipping','off');
		axis(ha_testplot2,'equal');
		htestplot2_r	= plot(ha_testplot2,...
			[xmin xmax],...
			[ymin ymax],...
			'LineStyle','-','Marker','.','Color','r');
		htestplot2_r1	= plot(ha_testplot2,...
			xmin,...
			ymin ,...
			'LineStyle','none','Marker','x','Color','r');
	end
	if testplot3
		hf_testplot3	= figure(100003);
		clf(hf_testplot3,'reset');
		set(hf_testplot3,'Tag','maplab3d_figure');
		ha_testplot3	= gca;
		hold(ha_testplot3,'on');
		axis(ha_testplot3,'equal');
	end

	% Execute bwboundaries:
	% requirement: the boundaries have to run on the black pixels of the image.
	% b_i: inner boundary
	% b_o: outer boundary
	% xy-coordinates in b_i, b_o:
	%   1   x
	% 1 +---->
	%   |
	% y v
	contour_obj		= [];
	b1					= bwboundaries(~obj_image,4,'noholes');
	i					= 0;
	for k1=1:length(b1)
		% b1 contains black pixels or pixels on the objects or the outer bgd_distance of objects:
		if testplot2
			set(htestplot2_r,...
				'XData',xmin+(     b1{k1,1}(:,2)-1)/(nx-1)*(xmax-xmin),...
				'YData',ymin+(1+ny-b1{k1,1}(:,1)-1)/(ny-1)*(ymax-ymin));
			set(htestplot2_r1,...
				'XData',xmin+(     b1{k1,1}(1,2)-1)/(nx-1)*(xmax-xmin),...
				'YData',ymin+(1+ny-b1{k1,1}(1,1)-1)/(ny-1)*(ymax-ymin));
			set_breakpoint=1;
		end
		[b_i,b_o]			= move_the_contour_outwards(b1{k1},smoothing,nx,ny,...
			testplot1,ha_testplot1,testplot2,ha_testplot2,k1,ktest,xmin,xmax,ymin,ymax);
		if ~isempty(b_i)&&~isempty(b_o)
			if testplot2
				set(htestplot2_r,...
					'XData',xmin+(     b_i(:,1)-1)/(nx-1)*(xmax-xmin),...
					'YData',ymin+(1+ny-b_i(:,2)-1)/(ny-1)*(ymax-ymin));
				set(htestplot2_r1,...
					'XData',xmin+(     b_i(1,1)-1)/(nx-1)*(xmax-xmin),...
					'YData',ymin+(1+ny-b_i(1,2)-1)/(ny-1)*(ymax-ymin));
			end
			i	= i+1;
			contour_obj{i,1}(:,1)	=      b_i(:,1);		% b_i: black
			contour_obj{i,1}(:,2)	= 1+ny-b_i(:,2);		% b_i: black		(invert y-axis)
		end
	end
	b2		= bwboundaries(obj_image,4,'noholes');
	for k2=1:length(b2)
		% b2 contains white pixels or pixels next to the objects, or the contour of holes in the objects:
		% If this contour runs along the edge of the image, this contour has to be skipped:
		if    isempty(find(b2{k2}(:,1)==1 ,1))&&...
				isempty(find(b2{k2}(:,2)==1 ,1))&&...
				isempty(find(b2{k2}(:,1)==ny,1))&&...
				isempty(find(b2{k2}(:,2)==nx,1))
			if testplot2
				set(htestplot2_r,...
					'XData',xmin+(     b2{k2,1}(:,2)-1)/(nx-1)*(xmax-xmin),...
					'YData',ymin+(1+ny-b2{k2,1}(:,1)-1)/(ny-1)*(ymax-ymin));
				set(htestplot2_r1,...
					'XData',xmin+(     b2{k2,1}(1,2)-1)/(nx-1)*(xmax-xmin),...
					'YData',ymin+(1+ny-b2{k2,1}(1,1)-1)/(ny-1)*(ymax-ymin));
				set_breakpoint=1;
			end
			[b_i,b_o]			= move_the_contour_outwards(b2{k2},smoothing,nx,ny,...
				testplot1,ha_testplot1,testplot2,ha_testplot2,k2,ktest,xmin,xmax,ymin,ymax);
			if ~isempty(b_i)&&~isempty(b_o)
				if testplot2
					set(htestplot2_r,...
						'XData',xmin+(     b_i(:,1)-1)/(nx-1)*(xmax-xmin),...
						'YData',ymin+(1+ny-b_i(:,2)-1)/(ny-1)*(ymax-ymin));
					set(htestplot2_r1,...
						'XData',xmin+(     b_i(1,1)-1)/(nx-1)*(xmax-xmin),...
						'YData',ymin+(1+ny-b_i(1,2)-1)/(ny-1)*(ymax-ymin));
				end
				i	= i+1;
				contour_obj{i,1}(:,1)	=      b_o(:,1);		% b_o: black
				contour_obj{i,1}(:,2)	= 1+ny-b_o(:,2);		% b_o: black		(invert y-axis)
			end
		end
	end

	% Convert pixel number to mm:
	for i=1:length(contour_obj)
		contour_obj{i,1}(:,1) = xmin+(contour_obj{i,1}(:,1)-1)/(nx-1)*(xmax-xmin);
		contour_obj{i,1}(:,2) = ymin+(contour_obj{i,1}(:,2)-1)/(ny-1)*(ymax-ymin);
	end

	% Convert contour to polygon:
	if GV.warnings_off
		warning('off','MATLAB:polyshape:repairedBySimplify');
	end
	i			= 1;
	poly		= polyshape(contour_obj{i,1}(:,1),contour_obj{i,1}(:,2));
	poly_obj	= simplify(poly);
	for i=2:length(contour_obj)
		poly		= polyshape(contour_obj{i,1}(:,1),contour_obj{i,1}(:,2));
		poly		= simplify(poly);
		poly_obj	= addboundary(poly_obj,poly.Vertices);
	end
	if GV.warnings_off
		warning('on','MATLAB:polyshape:repairedBySimplify');
	end

	% Add frame:
	poly_frame	= polyshape();
	switch no_frame
		case 1
			% no frame
		case 2
			% Rectangular frame:
			if frame_width>0
				[xlim,ylim]		= boundingbox(poly_obj);
				if (frame_radiuscorners==0)||(frame_sampling==1)
					% inner boundary:
					x_i	= [...
						xlim(1)-frame_distance ...
						xlim(2)+frame_distance ...
						xlim(2)+frame_distance ...
						xlim(1)-frame_distance];
					y_i	= [...
						ylim(1)-frame_distance ...
						ylim(1)-frame_distance ...
						ylim(2)+frame_distance ...
						ylim(2)+frame_distance];
					% inner boundary:
					x_o	= [...
						xlim(1)-(frame_distance+frame_width) ...
						xlim(2)+(frame_distance+frame_width) ...
						xlim(2)+(frame_distance+frame_width) ...
						xlim(1)-(frame_distance+frame_width)];
					y_o	= [...
						ylim(1)-(frame_distance+frame_width) ...
						ylim(1)-(frame_distance+frame_width) ...
						ylim(2)+(frame_distance+frame_width) ...
						ylim(2)+(frame_distance+frame_width)];
					poly_o		= polyshape(x_o,y_o);
					poly_frame	= addboundary(poly_o,x_i,y_i);
				else
					% inner boundary:
					x_i	= [...
						xlim(1)-frame_distance+frame_radiuscorners ...
						xlim(2)+frame_distance-frame_radiuscorners ...
						xlim(2)+frame_distance-frame_radiuscorners ...
						xlim(1)-frame_distance+frame_radiuscorners ...
						xlim(1)-frame_distance+frame_radiuscorners];
					y_i	= [...
						ylim(1)-frame_distance+frame_radiuscorners ...
						ylim(1)-frame_distance+frame_radiuscorners ...
						ylim(2)+frame_distance-frame_radiuscorners ...
						ylim(2)+frame_distance-frame_radiuscorners ...
						ylim(1)-frame_distance+frame_radiuscorners];
					% inner boundary:
					x_o	= [...
						xlim(1)-(frame_distance+frame_width)+frame_radiuscorners ...
						xlim(2)+(frame_distance+frame_width)-frame_radiuscorners ...
						xlim(2)+(frame_distance+frame_width)-frame_radiuscorners ...
						xlim(1)-(frame_distance+frame_width)+frame_radiuscorners ...
						xlim(1)-(frame_distance+frame_width)+frame_radiuscorners];
					y_o	= [...
						ylim(1)-(frame_distance+frame_width)+frame_radiuscorners ...
						ylim(1)-(frame_distance+frame_width)+frame_radiuscorners ...
						ylim(2)+(frame_distance+frame_width)-frame_radiuscorners ...
						ylim(2)+(frame_distance+frame_width)-frame_radiuscorners ...
						ylim(1)-(frame_distance+frame_width)+frame_radiuscorners];
					poly_i		= rmholes(line2poly(x_i,y_i,{frame_radiuscorners*2;frame_sampling;0},1,[],[],'round'));
					poly_o		= rmholes(line2poly(x_o,y_o,{frame_radiuscorners*2;frame_sampling;0},1,[],[],'round'));
					poly_frame	= addboundary(poly_o,poly_i.Vertices);
				end
			end
	end

	% Add the frame to the text and add the background:
	% (In the case of no_bgd=5, the frame must be added after adding the background.)
	switch no_bgd
		case 1
			% no background:
			poly_obj		= union(poly_obj,poly_frame);
			poly_bgd		= poly_obj;
		case 2
			% Rectangular background:
			poly_obj		= union(poly_obj,poly_frame);
			[xlim,ylim]	= boundingbox(poly_obj);
			if (bgd_radiuscorners==0)||(bgd_sampling==1)
				x	= [...
					xlim(1)-bgd_distance ...
					xlim(2)+bgd_distance ...
					xlim(2)+bgd_distance ...
					xlim(1)-bgd_distance];
				y	= [...
					ylim(1)-bgd_distance ...
					ylim(1)-bgd_distance ...
					ylim(2)+bgd_distance ...
					ylim(2)+bgd_distance];
				poly_bgd	= polyshape(x,y);
			else
				x	= [...
					xlim(1)-bgd_distance+bgd_radiuscorners ...
					xlim(2)+bgd_distance-bgd_radiuscorners ...
					xlim(2)+bgd_distance-bgd_radiuscorners ...
					xlim(1)-bgd_distance+bgd_radiuscorners ...
					xlim(1)-bgd_distance+bgd_radiuscorners];
				y	= [...
					ylim(1)-bgd_distance+bgd_radiuscorners ...
					ylim(1)-bgd_distance+bgd_radiuscorners ...
					ylim(2)+bgd_distance-bgd_radiuscorners ...
					ylim(2)+bgd_distance-bgd_radiuscorners ...
					ylim(1)-bgd_distance+bgd_radiuscorners];
				poly_bgd	= rmholes(line2poly(x,y,{bgd_radiuscorners*2;bgd_sampling;0},1,[],[],'round'));
			end

		case 3
			% Convex hull background:
			poly_obj		= union(poly_obj,poly_frame);
			poly_bgd		= poly_obj;
			poly_bgd		= convhull(poly_bgd);
			poly_bgd		= polybuffer(poly_bgd,bgd_distance);

		case 4
			% Connect all the objects with lines:
			% Baseline (shouldn't stick out at the edges):
			poly_obj		= union(poly_obj,poly_frame);
			poly_bgd		= poly_obj;
			if bgd_draw_baseline~=0
				[xlim,ylim]	= boundingbox(poly_obj);
				if isempty(obj_extent)
					y_baseline	= ylim(1)+(ylim(2)-ylim(1))*bgd_pos_baseline_percent/100+bgd_linewidth/2;
				else
					bottom_ext	= ymin+(ymax-ymin)*obj_extent(2);
					height_ext	= (ymax-ymin)*obj_extent(4);
					y_baseline	= bottom_ext+height_ext*bgd_pos_baseline_percent/100+bgd_linewidth/2;
				end
				[xlim1,~]	= boundingbox(intersect(poly_obj,line2poly(xlim,[1 1]*y_baseline+bgd_linewidth/2,...
					{1e-3;bgd_sampling;0},1,[],[],'round')));
				[xlim2,~]	= boundingbox(intersect(poly_obj,line2poly(xlim,[1 1]*y_baseline-bgd_linewidth/2,...
					{1e-3;bgd_sampling;0},1,[],[],'round')));
				if isempty(xlim1)||isempty(xlim2)
					% if the intersection gives no result: use the limits of the boundingbox:
					xlim1		= xlim;
					xlim2		= xlim;
				else
					max_xlim12	= max(xlim1(1),xlim2(1));
					min_xlim12	= min(xlim1(2),xlim2(2));
					if (max_xlim12-min_xlim12)<((xlim(2)-xlim(1))*0.9)
						% if the result of the intersection is not plausible: use the limits of the boundingbox:
						xlim1		= xlim;
						xlim2		= xlim;
					end
				end
				max_xlim12	= max(xlim1(1),xlim2(1));
				min_xlim12	= min(xlim1(2),xlim2(2));
				xlim			= [max_xlim12+bgd_linewidth/2 min_xlim12-bgd_linewidth/2];
				poly_bgd		= union(poly_obj,line2poly(xlim,[1 1]*y_baseline,...
					{bgd_linewidth;bgd_sampling;0},1,[],[],'round'));
			end
			% Remove holes in the background :
			if bgd_remove_holes==1
				while ~isempty(holes(poly_bgd))>0
					poly_bgd		= rmholes(poly_bgd);
					poly_bgd		= union(poly_obj,poly_bgd);
				end
			end
			% Connect individual objects/regions with the baseline:
			if bgd_connect_regions==1
				[poly_bgd,~]	= connect_regions(poly_bgd,bgd_linewidth,bgd_sampling);
				if testplot2
					plot(ha_testplot2,poly_bgd.Vertices(:,1),poly_bgd.Vertices(:,2),...
						'LineStyle','-','LineWidth',1.5,'Marker','.','MarkerSize',25,'Color','m');
				end
			end

		case 5
			% Connect only objects with lines, whose x-values overlap:
			% In most cases this should result in individual letters being connected, e. g.: connect the dot on the i.
			% Remove holes in the background :
			poly_bgd		= poly_obj;
			if bgd_remove_holes==1
				while ~isempty(holes(poly_bgd))>0
					poly_bgd		= rmholes(poly_bgd);
					poly_bgd		= union(poly_obj,poly_bgd);
				end
			end
			% Connect individual objects/regions:
			conn_lines_all		= polyshape();
			poly_bgd				= sortregions(poly_bgd,'area','descend');
			poly_bgd_regions	= regions(poly_bgd);
			ir1					= 1;
			regions_connected	= false;
			while ir1<size(poly_bgd_regions,1)
				ir2				= ir1+1;
				if testplot3
					cla(ha_testplot3,'reset');
					hold(ha_testplot3,'on');
					for i=1:size(poly_bgd_regions,1)
						plot(ha_testplot3,poly_bgd_regions(i,1),'EdgeColor',[1 1 1]*0.5,'FaceColor',[1 1 1]*0.1);
						[x,y]		= centroid(poly_bgd_regions(i,1));
						text(x,y,sprintf('%g',i));
					end
					hplot1		= plot(ha_testplot3,poly_bgd_regions(ir1,1),'LineWidth',2,'EdgeColor','r');
					hplot2		= plot(ha_testplot3,poly_bgd_regions(ir2,1));
					axis(ha_testplot3,'equal');
					set_breakpoint				= 1;
				end
				while ir2<=size(poly_bgd_regions,1)
					[xlim1,~]	= boundingbox(poly_bgd_regions(ir1,1));
					[xlim2,~]	= boundingbox(poly_bgd_regions(ir2,1));
					if  ~ ( (xlim2(2)<xlim1(1)) || (xlim2(1)>xlim1(2)) )
						% The x-values of the two regions overlap: Connect them:
						if testplot3
							hplot2.Shape.Vertices	= poly_bgd_regions(ir2,1).Vertices;
							set_breakpoint				= 1;
						end
						poly_bgd_regions_ir1_new	= union(poly_bgd_regions(ir1,1),poly_bgd_regions(ir2,1));
						[poly_bgd_regions(ir1,1),conn_lines]	= connect_regions(...
							poly_bgd_regions_ir1_new,bgd_linewidth,bgd_sampling);
						conn_lines_all					= union(conn_lines_all,conn_lines);
						% Delete the region ir2:
						poly_bgd_regions(ir2,:)		= [];
						regions_connected				= true;
						if testplot3
							hplot1.Shape.Vertices	= poly_bgd_regions(ir1,1).Vertices;
							set_breakpoint				= 1;
						end
						break
					else
						if testplot3
							hplot2.Shape.Vertices	= poly_bgd_regions(ir2,1).Vertices;
							set_breakpoint		= 1;
						end
						ir2		= ir2+1;
					end
				end
				if regions_connected
					% Start the while loop again:
					ir1					= 1;
					regions_connected	= false;
				else
					ir1		= ir1+1;
				end
			end
			poly_bgd		= union(poly_bgd,conn_lines_all);
			% The frame must be added at the end, otherwise there would be detected an overlap with the letters:
			poly_obj		= union(poly_obj,poly_frame);
			poly_bgd		= union(poly_bgd,poly_frame);

	end
	% Intersect the objects with the background:
	poly_obj		= intersect(poly_obj,poly_bgd);

	% Rotate the objects:
	poly_obj		= rotate(poly_obj,rotation);
	poly_bgd		= rotate(poly_bgd,rotation);

	% Testplots:
	if testplot2
		set(htestplot2_r,'XData',[],'YData',[]);
		set(htestplot2_r1,'XData',[],'YData',[]);
		for i=1:length(contour_obj)
			plot(ha_testplot2,contour_obj{i}(:,1),contour_obj{i}(:,2),...
				'LineStyle','-','LineWidth',1.5,'Marker','.','MarkerSize',25,'Color','r');
		end
	end
	if testplot==1
		plot(ha_testplot,poly_bgd)		% ,'LineWidth',2
		plot(ha_testplot,poly_obj)
		plot(ha_testplot,...
			[xmin xmax xmax xmin xmin],...
			[ymin ymin ymax ymax ymin],':k');
	end

catch ME
	errormessage('',ME);
end



%-----------------------------------------------------------------------------------------------------------------%
function [b_i,b_o]=move_the_contour_outwards(b,smoothing,nx,ny,...
	testplot1,ha_testplot1,testplot2,ha_testplot2,k,ktest,xmin,xmax,ymin,ymax)
% Moves the line contained in b by one pixel outwards
% Results:	2-column matrices b_i,b_o:
%				The first column contains the x-coordinates of the contours, and the second column
%				contains the corresponding y-coordinates
% b_i:		inner contour
% b_o:		outer contour

try

	tol_mm		= 1e-8;					% Paths are rounded to this tolerance in order to avoid rounding errors.
	logtol		= -8;

	% testplots:
	if testplot1
		fprintf(1,'\nk=%g: size(b{k},1)=%8.0f',k,size(b,1));
	end

	% Ignore a single pixel:
	b_i_c	= [];
	if size(b,1)>3
		b_i_c	= b(:,2)+1i*b(:,1);		% Represent points as a complex number.
	end

	% Delete points with reversal of direction:
	if testplot1&&(length(b_i_c)>=3)&&((ktest==k)||(ktest==-1))
		hl_bic	= plot(ha_testplot1,real(b_i_c)   ,imag(b_i_c)   ,'m','LineWidth',1,'LineStyle',':','Marker','.');
		hp_bic	= plot(ha_testplot1,real(b_i_c(1)),imag(b_i_c(1)),'m','LineWidth',1,'Marker','^');
	end
	wiederholen	= 1;
	while (wiederholen==1)&&(length(b_i_c)>=3)
		wiederholen	= 0;
		% Delete duplicate points
		i_v	= vindexrest(1:(length(b_i_c)+1),length(b_i_c));
		b_i_c(abs(diff(b_i_c(i_v)))<tol_mm)	= [];
		% Find points with reversal of direction:
		i_v		= vindexrest(1:(length(b_i_c)+1),length(b_i_c));
		zm1_v		= vindexrest(i_v-1,length(b_i_c));
		z_v		= vindexrest(i_v  ,length(b_i_c));
		zp1_v		= vindexrest(i_v+1,length(b_i_c));
		db_m1_v	= b_i_c(z_v  )-b_i_c(zm1_v);
		db_p1_v	= b_i_c(zp1_v)-b_i_c(z_v  );
		iru_v		= vindexrest(find(db_m1_v==-db_p1_v),length(b_i_c));
		if ~isempty(iru_v)
			% Reversal of direction identified:
			if testplot1&&((ktest==k)||(ktest==-1))
				set(hp_bic,'XData',real(b_i_c(z_v)),'YData',imag(b_i_c(z_v)));
			end
			b_i_c(iru_v)	= [];		% Delete points
			wiederholen		= 1;		% Search b_i_c from the beginning
		end
	end
	if testplot1&&(length(b_i_c)>=3)&&((ktest==k)||(ktest==-1))
		if isempty(b_i_c)
			set(hp_bic,'XData',[],'YData',[]);
		else
			plot(ha_testplot1,real(b_i_c(1)),imag(b_i_c(1)),'m','LineWidth',1,'Marker','x');
			set(hp_bic,'XData',real(b_i_c(end)),'YData',imag(b_i_c(end)));
		end
		set(hl_bic,'XData',real(b_i_c),'YData',imag(b_i_c));
	end

	% Delete duplicate points in b_i_c:
	if length(b_i_c)>=3
		i_v	= vindexrest(1:(length(b_i_c)+1),length(b_i_c));
		b_i_c(abs(diff(b_i_c(i_v)))<tol_mm)	= [];
	end

	% Create outline b_o_c:
	b_o_c	= [];
	if length(b_i_c)>=3
		if testplot1&&((ktest==k)||(ktest==-1))
			hl_boc		= plot(ha_testplot1,[1 1],[1 1],'c','LineWidth',1,'LineStyle',':','Marker','.');
			hp_boc1		= plot(ha_testplot1,[1 1],[1 1],'c','LineWidth',1,'Marker','x');
			hp_boc2		= plot(ha_testplot1,[1 1],[1 1],'c','LineWidth',1,'Marker','o');
		end
		imax	= length(b_i_c);
		a		= 1i;									% conterclockwise rotation by 90°
		for i=1:imax
			z		= vindexrest(i  ,imax);
			zp1	= vindexrest(i+1,imax);
			db		= b_i_c(zp1)-b_i_c(z  );	% Vector to the next point
			% Rotate the vector to the next point outwards:
			boc_zp0_rotated	= b_i_c(z  ) - db*a;
			boc_zp1_gedreht	= b_i_c(zp1) - db*a;
			% If the two points already exist in b_o_c: delete the existing one, then add the new point:
			j		= find(b_o_c==boc_zp0_rotated);
			if ~isempty(j)
				if j(1)~=1
					b_o_c(j(end):end)	= [];
				end
			end
			if isempty(b_o_c)
				b_o_c	= boc_zp0_rotated;
			elseif (boc_zp0_rotated~=b_o_c(1))&&isempty(find(b_i_c==boc_zp0_rotated,1))
				b_o_c	= [b_o_c;boc_zp0_rotated];
			end
			j		= find(b_o_c==boc_zp1_gedreht);
			if ~isempty(j)
				if j(1)~=1
					b_o_c(j(end):end)	= [];
				end
			end
			if isempty(b_o_c)
				b_o_c	= boc_zp1_gedreht;
			elseif (boc_zp1_gedreht~=b_o_c(1))&&isempty(find(b_i_c==boc_zp1_gedreht,1))
				b_o_c	= [b_o_c;boc_zp1_gedreht];
			end
			if testplot1&&((ktest==k)||(ktest==-1))
				set(hp_boc1,'XData',real(boc_zp0_rotated),'YData',imag(boc_zp0_rotated));
				set(hp_boc2,'XData',real(boc_zp1_gedreht),'YData',imag(boc_zp1_gedreht));
				set(hl_boc,'XData',real(b_o_c),'YData',imag(b_o_c));
				test=1;
			end
		end
		if testplot1&&((ktest==k)||(ktest==-1))
			set_breakpoint=1;
		end
	end

	% Smoothing:
	if (length(b_i_c)>=3)&&(smoothing==1)
		b_i_c	= b_smoothing(b_i_c,nx,ny,testplot2,ha_testplot2,xmin,xmax,ymin,ymax);
		b_o_c	= b_smoothing(b_o_c,nx,ny,testplot2,ha_testplot2,xmin,xmax,ymin,ymax);
	end

	% Delete duplicate points:
	b_i_c	= unique(b_i_c,'stable');
	b_o_c	= unique(b_o_c,'stable');

	% Assign results:
	if length(b_i_c)>=3
		b_i	= round([real(b_i_c) imag(b_i_c)],-logtol);
		b_o	= round([real(b_o_c) imag(b_o_c)],-logtol);
	else
		b_i	= [];
		b_o	= [];
	end
	if testplot1
		fprintf(1,' ,  size(b_i,1)=%8.0f ,  size(b_o,1)=%8.0f\n',size(b_i,1),size(b_o,1));
	end

	% Testplots:
	if testplot1&&(length(b_i_c)>=3)&&(length(b_o_c)>=3)&&((ktest==k)||(ktest==-1))
		plot(ha_testplot1,real(b_i_c),imag(b_i_c),'m','LineWidth',1,'LineStyle','-' ,'Marker','o');
		plot(ha_testplot1,real(b_o_c),imag(b_o_c),'c','LineWidth',1,'LineStyle','--','Marker','s');
		set_breakpoint=1;
	end

catch ME
	errormessage('',ME);
end



%-----------------------------------------------------------------------------------------------------------------%
function b_c = b_smoothing(b_c,nx,ny,testplot2,ha_testplot2,xmin,xmax,ymin,ymax)

try

	logtol				= -8;
	no_smoothing_1		= 2;		% 2

	switch no_smoothing_1
		case 1

			% smooths the complex data in b_c with a moving average over 3 values:
			zmax	= length(b_c);
			zm1_v	= vindexrest( 0:(zmax-1),zmax);
			z_v	= vindexrest( 1:(zmax  ),zmax);
			zp1_v	= vindexrest( 2:(zmax+1),zmax);
			b_c(z_v)	= mean([b_c(zm1_v) b_c(z_v) b_c(zp1_v)],2);

		case 2

			% smooths the complex data in b_c with a moving average over 5 values:
			zmax	= length(b_c);
			zm2_v	= vindexrest(-1:(zmax-2),zmax);
			zm1_v	= vindexrest( 0:(zmax-1),zmax);
			z_v	= vindexrest( 1:(zmax  ),zmax);
			zp1_v	= vindexrest( 2:(zmax+1),zmax);
			zp2_v	= vindexrest( 3:(zmax+2),zmax);
			b_c(z_v)	= mean([b_c(zm2_v) b_c(zm1_v) b_c(z_v) b_c(zp1_v) b_c(zp2_v)],2);

		case 3

			% smooths the complex data in b_c by deleting the corner point of 90 ° corners:
			zmax	= length(b_c);
			zm2_v	= vindexrest(-1:(zmax-2),zmax);
			zm1_v	= vindexrest( 0:(zmax-1),zmax);
			z_v	= vindexrest( 1:(zmax  ),zmax);
			zp1_v	= vindexrest( 2:(zmax+1),zmax);
			zp2_v	= vindexrest( 3:(zmax+2),zmax);
			dbm2_v	= b_c(zm1_v)-b_c(zm2_v);
			dbm1_v	= b_c(z_v  )-b_c(zm1_v);
			dbp1_v	= b_c(zp1_v)-b_c(z_v  );
			dbp2_v	= b_c(zp2_v)-b_c(zp1_v);
			a		= 1i;												% conterclockwise rotation by 90°
			% Lines of the corner points to be deleted in b_c:
			z_loeschen	= ...
				(  (dbp1_v==(dbm1_v*(-a)) ) |...				% - dbp1_v rotated 90 ° to the left compared to dbm1_v
				(   dbp1_v==(dbm1_v*( a)) )      )&...		% - dbp1_v rotated 90 ° to the right compared to dbm1_v
				(   dbp2_v~=-dbm1_v              )&...		% - no inversion of the direction
				(   dbm2_v~=-dbp1_v              )&...		% - no inversion of the direction
				~( real(b_c(z_v))==1             )&...		% - The points to be deleted are not on the edges of the image.
				~( imag(b_c(z_v))==1             )&...
				~( real(b_c(z_v))==nx            )&...
				~( imag(b_c(z_v))==ny            );
			% Erase corners:
			b_c(z_loeschen)		= [];

	end

	no_smoothing_2		= 4;
	switch no_smoothing_2
		case 1

			% Reduce the number of points by deleting the middle point of three points that lie on a line.
			% The corner points remain.
			zmax			= length(b_c);
			zm1_v			= vindexrest(0:(zmax-1),zmax);
			z_v			= vindexrest(1:(zmax  ),zmax);
			zp1_v			= vindexrest(2:(zmax+1),zmax);
			dbm1_v		= b_c(z_v)-b_c(zm1_v);
			dbp1_v		= b_c(zp1_v)-b_c(z_v);
			b_c(round(dbm1_v,-logtol)==round(dbp1_v,-logtol))	= [];

		case 2

			% Reduce the number of points by deleting the middle point of three points that lie on a line.
			% The corner points remain.
			zmax			= length(b_c);
			zm1_v			= vindexrest(0:(zmax-1),zmax);
			z_v			= vindexrest(1:(zmax  ),zmax);
			zp1_v			= vindexrest(2:(zmax+1),zmax);
			dbm1_v		= b_c(z_v)-b_c(zm1_v);
			dbp1_v		= b_c(zp1_v)-b_c(z_v);
			b_c(round(dbm1_v,-logtol)==round(dbp1_v,-logtol))	= [];

			% Delete every second point:
			zmax			= length(b_c);
			b_c(1:2:zmax)	= [];

		case 3

			% Reduce the number of points by deleting the middle point of three points that lie on a line.
			% The corner points remain.
			zmax			= length(b_c);
			zm1_v			= vindexrest(0:(zmax-1),zmax);
			z_v			= vindexrest(1:(zmax  ),zmax);
			zp1_v			= vindexrest(2:(zmax+1),zmax);
			dbm1_v		= b_c(z_v)-b_c(zm1_v);
			dbp1_v		= b_c(zp1_v)-b_c(z_v);
			b_c(round(dbm1_v,-logtol)==round(dbp1_v,-logtol))	= [];

			b_c_orig		= b_c;

			if testplot2
				% invert y-axis:
				b_c_x_pixel	=      real(b_c);
				b_c_y_pixel	= 1+ny-imag(b_c);
				% Convert pixelnumber to mm:
				b_c_x_mm	= xmin+(b_c_x_pixel-1)/(nx-1)*(xmax-xmin);
				b_c_y_mm	= ymin+(b_c_y_pixel-1)/(ny-1)*(ymax-ymin);
				plot(ha_testplot2,b_c_x_mm,b_c_y_mm,'LineStyle','-' ,'Marker','.','Color','b');
			end

			% Reduce the number of points by deleting the middle point of three points if
			% the deviation x is less than tol:
			tol		= 0.25;					% unit(tol) = pixel !   Draft: 0.5, fine: 0.25
			zmax		= length(b_c);
			zmax_old	= zmax+1;
			while zmax<zmax_old

				%                    + b_c(z)
				%                   /^
				%                  / |
				%                 /  | x
				%                /   |
				%               /    v
				%     b_c(zm1) +------------------+ b_c(zp1)

				zmax_old	= zmax;

				z_v		= vindexrest(1:2:zmax,zmax);
				zm1_v		= vindexrest(z_v-1,zmax);
				zp1_v		= vindexrest(z_v+1,zmax);
				dbm1_v	= b_c(z_v  )-b_c(zm1_v);
				dbm1p1_v	= b_c(zp1_v)-b_c(zm1_v);
				phi		= angle(dbm1_v)-angle(dbm1p1_v);
				% deviation of the line to the middle point:
				x			= abs(dbm1_v).*sin(phi);
				z_delete	= z_v(abs(x)<tol);
				if length(find(z_delete))<=(length(b_c)-4)
					% delete points:
					b_c(z_delete)		= [];
				else
					% if less than 4 points remain:
					b_c					= b_c_orig;
					break
				end
				zmax		= length(b_c);

				z_v		= vindexrest(2:2:zmax,zmax);
				zm1_v		= vindexrest(z_v-1,zmax);
				zp1_v		= vindexrest(z_v+1,zmax);
				dbm1_v	= b_c(z_v  )-b_c(zm1_v);
				dbm1p1_v	= b_c(zp1_v)-b_c(zm1_v);
				phi		= angle(dbm1_v)-angle(dbm1p1_v);
				% deviation of the line to the middle point:
				x			= abs(dbm1_v).*sin(phi);
				z_delete	= z_v(abs(x)<tol);
				if length(find(z_delete))<=(length(b_c)-4)
					% delete points:
					b_c(z_delete)		= [];
				else
					% if less than 4 points remain:
					b_c					= b_c_orig;
					break
				end
				zmax		= length(b_c);

			end

		case 4

			% Do not delete a point, if the ratio of the distance to the the point before and after ist greater
			% than dbp1_dbm1_ratio_max.
			% This maintains the direction of long straight lines (for example, the sides of an "I" remain straight).
			dbp1_dbm1_ratio_max	= 6;					% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			% Reduce the number of points by deleting the middle point of three points that lie on a line.
			% The corner points remain.
			zmax			= length(b_c);
			zm1_v			= vindexrest(0:(zmax-1),zmax);
			z_v			= vindexrest(1:(zmax  ),zmax);
			zp1_v			= vindexrest(2:(zmax+1),zmax);
			dbm1_v		= b_c(z_v)-b_c(zm1_v);
			dbp1_v		= b_c(zp1_v)-b_c(z_v);
			b_c(round(dbm1_v,-logtol)==round(dbp1_v,-logtol))	= [];

			b_c_orig		= b_c;

			% Testing:
			testing_case4	= false;
			if testing_case4
				hf=figure(4672834);
				clf(hf,'reset');
				ha=axes;
				plot(ha,real(b_c),imag(b_c),'LineStyle','-' ,'Marker','.','Color','b');
				hold on
				axis equal
				setbreakpoint1	= 1;
			end

			if testplot2
				% invert y-axis:
				b_c_x_pixel	=      real(b_c);
				b_c_y_pixel	= 1+ny-imag(b_c);
				% Convert pixelnumber to mm:
				b_c_x_mm	= xmin+(b_c_x_pixel-1)/(nx-1)*(xmax-xmin);
				b_c_y_mm	= ymin+(b_c_y_pixel-1)/(ny-1)*(ymax-ymin);
				plot(ha_testplot2,b_c_x_mm,b_c_y_mm,'LineWidth',1,'LineStyle','-' ,'Marker','.','Color','b');
			end

			% Reduce the number of points by deleting the middle point of three points if
			% the deviation x is less than tol:
			tol		= 0.35;					% unit(tol) = pixel !   Draft: 0.5, fine: 0.25 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			zmax		= length(b_c);
			zmax_old	= zmax+1;
			while zmax<zmax_old

				%                    + b_c(z)
				%                   /^
				%                  / |
				%                 /  | x
				%                /   |
				%               /    v
				%     b_c(zm1) +------------------+ b_c(zp1)

				zmax_old	= zmax;

				% deviation of the line to the middle point:
				z_v		= vindexrest(1:2:zmax,zmax);
				zm1_v		= vindexrest(z_v-1,zmax);
				zp1_v		= vindexrest(z_v+1,zmax);
				dbm1_v	= b_c(z_v  )-b_c(zm1_v);
				dbm1p1_v	= b_c(zp1_v)-b_c(zm1_v);
				phi		= angle(dbm1_v)-angle(dbm1p1_v);
				x			= abs(dbm1_v).*sin(phi);
				z_delete	= z_v(abs(x)<tol);

				% Do not delete a point, if the ratio of the distance to the the point before and after ist greater
				% than dbp1_dbm1_ratio_max:
				zm1_delete	= vindexrest(z_delete-1,zmax);
				zp1_delete	= vindexrest(z_delete+1,zmax);
				dbp1_v		= b_c(zp1_delete)-b_c(z_delete  );
				dbm1_v		= b_c(z_delete  )-b_c(zm1_delete);
				dbp1_dbm1_ratio_v		= abs(dbp1_v)./abs(dbm1_v);
				dbm1_dbp1_ratio_v		= 1./dbp1_dbm1_ratio_v;
				zpm1_delete_not		= ...
					(dbp1_dbm1_ratio_v>dbp1_dbm1_ratio_max)|...
					(dbm1_dbp1_ratio_v>dbp1_dbm1_ratio_max);
				z_delete(zpm1_delete_not)		= [];
				if testing_case4
					plot(ha,real(b_c(z_delete)),imag(b_c(z_delete)),...
						'LineWidth',1.5,'LineStyle','none' ,'Marker','x','Color','c');
					setbreakpoint1	= 1;
				end

				if length(find(z_delete))<=(length(b_c)-4)
					% delete points:
					b_c(z_delete)		= [];
				else
					% if less than 4 points remain:
					b_c					= b_c_orig;
					break
				end
				zmax		= length(b_c);

				% deviation of the line to the middle point:
				z_v		= vindexrest(2:2:zmax,zmax);
				zm1_v		= vindexrest(z_v-1,zmax);
				zp1_v		= vindexrest(z_v+1,zmax);
				dbm1_v	= b_c(z_v  )-b_c(zm1_v);
				dbm1p1_v	= b_c(zp1_v)-b_c(zm1_v);
				phi		= angle(dbm1_v)-angle(dbm1p1_v);
				x			= abs(dbm1_v).*sin(phi);
				z_delete	= z_v(abs(x)<tol);

				% Do not delete a point, if the ratio of the distance to the the point before and after ist greater
				% than dbp1_dbm1_ratio_max:
				zm1_delete	= vindexrest(z_delete-1,zmax);
				zp1_delete	= vindexrest(z_delete+1,zmax);
				dbp1_v		= b_c(zp1_delete)-b_c(z_delete  );
				dbm1_v		= b_c(z_delete  )-b_c(zm1_delete);
				dbp1_dbm1_ratio_v		= abs(dbp1_v)./abs(dbm1_v);
				dbm1_dbp1_ratio_v		= 1./dbp1_dbm1_ratio_v;
				zpm1_delete_not		= ...
					(dbp1_dbm1_ratio_v>dbp1_dbm1_ratio_max)|...
					(dbm1_dbp1_ratio_v>dbp1_dbm1_ratio_max);
				z_delete(zpm1_delete_not)		= [];

				if length(find(z_delete))<=(length(b_c)-4)
					% delete points:
					b_c(z_delete)		= [];
				else
					% if less than 4 points remain:
					b_c					= b_c_orig;
					break
				end
				zmax		= length(b_c);

			end

	end

catch ME
	errormessage('',ME);
end



function [poly_bgd,conn_lines]=connect_regions(poly_bgd,bgd_linewidth,bgd_sampling)
% Connect individual objects/regions

try

	conn_lines			= polyshape();
	poly_bgd				= sortregions(poly_bgd,'area','descend');
	poly_bgd_regions	= regions(poly_bgd);
	dmax					= bgd_linewidth/10;
	dmin					= [];
	nmin					= [];
	while length(poly_bgd_regions)>1
		% Inserts vertices to poly_bgd_regions, so that the distance between two vertices is less than dmax:
		% Because poly_bgd_regions is overwritten below, this step must be executed in every loop pass.
		poly_bgd_regions	= changeresolution_poly(poly_bgd_regions,dmax,dmin,nmin);
		% Find the regions with the smallest gaps:
		min_distance		= 1e12;
		k1_min_distance	= 1;
		k2_min_distance	= 1;
		for k1=1:length(poly_bgd_regions)
			for k2=(k1+1):length(poly_bgd_regions)
				poly1	= poly_bgd_regions(k1);
				poly2	= poly_bgd_regions(k2);
				% Rotate the letters so that the lower sides are closer than the upper sides. ==>
				% The connecting lines for vertical and parallel sides are at the bottom.
				[x1,y1]		= centroid(poly1);
				[x2,y2]		= centroid(poly2);
				theta			= 0.1;
				if x1<x2
					% poly1 is to the left of poly2:
					poly1		= rotate(poly1, theta,[x1 y1]);
					poly2		= rotate(poly2,-theta,[x2 y2]);
				else
					% poly1 is to the right of poly2:
					poly1		= rotate(poly1,-theta,[x1 y1]);
					poly2		= rotate(poly2, theta,[x2 y2]);
				end
				z	= ~isnan(poly2.Vertices(:,1))&~isnan(poly2.Vertices(:,2));
				[vertexid,~,~] = nearestvertex(poly1,poly2.Vertices(z,1),poly2.Vertices(z,2));
				distance	= sqrt(...
					(poly1.Vertices(vertexid,1)-poly2.Vertices(z,1)).^2 + ...
					(poly1.Vertices(vertexid,2)-poly2.Vertices(z,2)).^2);
				[min_distance_k1k2,~] = min(distance);
				if min_distance_k1k2<min_distance
					min_distance		= min_distance_k1k2;
					k1_min_distance	= k1;
					k2_min_distance	= k2;
				end
			end
		end
		% Insert line:
		poly1	= poly_bgd_regions(k1_min_distance);
		poly2	= poly_bgd_regions(k2_min_distance);
		z	= ~isnan(poly2.Vertices(:,1))&~isnan(poly2.Vertices(:,2));
		[vertexid,~,~] = nearestvertex(poly1,poly2.Vertices(z,1),poly2.Vertices(z,2));
		distance	= sqrt(...
			(poly1.Vertices(vertexid,1)-poly2.Vertices(z,1)).^2 + ...
			(poly1.Vertices(vertexid,2)-poly2.Vertices(z,2)).^2);
		[~,i_min_distance]	= min(distance);
		x		= [poly1.Vertices(vertexid(i_min_distance),1) poly2.Vertices(i_min_distance,1)];
		y		= [poly1.Vertices(vertexid(i_min_distance),2) poly2.Vertices(i_min_distance,2)];
		conn_line				= line2poly(x,y,{bgd_linewidth;bgd_sampling;0},1,[],[],'round');
		poly_bgd					= sortregions(poly_bgd,'area','descend');
		poly_bgd_regions		= regions(poly_bgd);
		poly_bgd					= union(poly_bgd,conn_line);
		conn_lines				= union(conn_lines,conn_line);
	end

catch ME
	errormessage('',ME);
end

