function [poly_line,...
	poly_lisy,...
	ud_line,...
	ud_lisy,...
	linewidth,...
	linewidth_max,...
	dz_fgd,...
	dz_bgd,...
	ip_sampling,...
	extra]=...
	line2poly(...
	x,...
	y,...
	par,...
	style,...
	iobj,...
	obj_purpose,...
	jointtype,...
	miterlimit,...
	in,...
	iw,...
	ir)
% Returns a polygon with a constant linewidth, defined by 2-D vertices x and y.
%
% Input:
%  1)	x					x-values of the line. The line can contain different line segments, separated by nans.
%  2)	y					y-values of the line. The line can contain different line segments, separated by nans.
%  3) par				cell array of parameters
%  4) style				Line style, see below
%  5) iobj				index in PP.obj
%  6) obj_purpose		cell array: information about the usage of the object
%							(see get_pp_mapobjsettings.m)
%  7) jointtype:		Joint type for buffer boundaries, specified as one of the following:
%							'round'		Round out boundary corners. The number of edges of a semicircle is defined by
%											sampling, the same value as for the semicircles at the ends of the polygon.
%							'miter'		Results in less vertices than jointtype='round'.
%											Every corner ist made of 1 or 2 vertices.
%							'bufferm'	Uses the bufferm function.
%											This only works with a constant line width.
%											Was for testing: the execution time was greater than jointtype='miter':
%											no advantage
%  8) miterlimit:		Specified as a positive numeric scalar greater than or equal to 1. The miter limit is the ratio
%							between the distance a joint vertex is moved and the buffer distance.
%							Setting a miter limit controls the pointiness of boundary joints.
%  9) in					Indices in OSMDATA.node(1,in)
% 10) iw					Indices in OSMDATA.way(1,iw)
% 11) ir					Indices in OSMDATA.relation(1,ir)
%							If in, iw or ir is empty: No nodes/ways/relations have been included in the line data.
%							If in, iw or ir is zero, the value is replaced by an empty matrix.
%							If in, iw or ir contains the value zero, this element is deleted.
%
% Output:
%  1) poly_line		1*1 polyshape object with boundaries that buffer the 2-D points (x,y) by a distance linewidth/2.
%  2) poly_lisy		1*1 polyshape object: line symbols (e. g. dashs): foreground
%  3) ud_line,			corresponding Userdata:
%  4) ud_lisy			ud.color_no			color number
%							ud.color_no_pp		color number project parameters
%							ud.dz					change in altitude compared to the elevation (>0 higher, <0 lower)
%							ud.prio				object priority
%							ud.iobj				index in PP.obj
%							ud.level				0: background, 1: foreground
%							ud.surftype			surface type
%							ud.rotation			rotation angle
%							ud.obj_purpose		cell array: information about the usage of the object
%													(see get_pp_mapobjsettings.m)
%							ud.in					Indices in OSMDATA.node(1,in)
%							ud.iw					Indices in OSMDATA.way(1,iw)
%							ud.ir					Indices in OSMDATA.relation(1,ir)
%													Empty: No nodes/ways/relations have been included in the line data.
%							ud.x_scint			linestyle 4:	xyz data for creating a scatteredInterpolant object:
%							ud.y_scint								elevation calculation for the given polygon area
%							ud.z_scint
%							ud.x_zmin			linestyle 4:	xyz data of the start or end point with the lower z value
%							ud.y_zmin								(outline, 2x1 vector)
%							ud.z_zmin
%							ud.x_zmax			linestyle 4:	xyz data of the start or end point with the higher z value
%							ud.y_zmax								(outline, 2x1 vector)
%							ud.z_zmax
%							If there are no symbols, ud_lisy is empty.
%  5) linewidth		constant line width or minimum line width
%  6) linewidth_max	maximum line width
%  7) dz_fgd			dz of the foreground
%  8) dz_bgd			dz of the background
%  9) ip_sampling		index of the parameter sampling (number of the edges at the ends of the line) in par
% 10) extra				Extra data:
%							1)	jointtype='miter' and style=1:
%								extra.lb		vertices of the left  border (lb) of the polyshape object
%								extra.rb		vertices of the right border (rb) of the polyshape object
%								-	N*2 matrices:	N:				number of vertices
%														column 1:	x-values
%														column 2:	y-values
%								-	There can be extra points: use 'KeepCollinearPoints'=false when creating a polygon object
%								-	There can be intersections if the polygon overlaps:
%									better use only the first and last point.
%
% Syntax for creating a polygon:
%		1)	poly_line = line2poly(x,y,par)
%			simple polygon with:	par			= linewidth
%										style			= 1
%										sampling		= 1
%										jointtype	= 'miter'
%										miterlimit	= 2
%			simple polygon with:	par			= {linewidth;sampling}
%										style			= 1
%										jointtype	= 'miter'
%										miterlimit	= 2
%		2)	poly_line                             = line2poly(x,y,par,style)
%			poly_line                             = line2poly(x,y,par,style,[]  ,[]            ,jointtype,miterlimit)
%			[poly_line,poly_lisy,ud_line,ud_lisy] = line2poly(x,y,par,style,iobj,{'map object'},jointtype,miterlimit,in,iw,ir)
%			Do not use 5 output arguments!
% Syntax for assignment of the userdata, the total line width and ip_sampling without calculating the polygon:
% (Please note that ud_lisy may be empty!)
%		1)	[~,~,ud_line,ud_lisy,linewidth,~,ip_sampling] = line2poly([],[],par,style,iobj)
%{
--------------------------------------------------------------------------------|
style      = 1
Simple line:
par{1} = line width / mm
par{2} = sampling
         The ends of the polygon consists of semicircles, the center is equal
         to the first and last point of x and y. The number of edges of a
         semicircle is defined by sampling. Examples:
         sampling=1: only one edge, no circle
                  6: should be the standard value for lines:
                     - The lines are longer:
                       Line segements will be connected automatically
                     - Higher values increase the execution time.
par{3} = lifting dz (background) / mm
cross section:
   |<-----par{1}------>|
   +-------------------+  ---
   |                   |   ^
   |                   |   |par{3}
   |                   |   v
---+  elevation level  +----------
--------------------------------------------------------------------------------|
style=2:
Dashed line:
par{1} = line width / mm
par{2} = sampling
         The ends of the polygon consists of semicircles, the center is equal
         to the first and last point of x and y. The number of edges of a
         semicircle is defined by sampling. Examples:
         sampling=1: only one edge, no circle
                  6: should be the standard value for lines:
                     - The lines are longer:
                       Line segements will be connected automatically
                     - Higher values increase the execution time.
par{3} = lifting dz of the dashs (foreground) / mm
par{4} = lifting dz of the gaps (background) / mm
par{5} = length of the dashs / mm
par{6} = length of the gaps / mm
par{7} = dash surface type  0: The dash height follows the terrain raised by dz.
                            1: Flat surface: The height is equal to the maximum
                               value of the terrain height at the edge of the
                               dashs raised by dz.
                               This applies to all individual dashs.
par{8} = minimum relative gap length at the start and end of a line segment
                           A line always begins and ends with a gap. To achieve
                           this, the length of the gaps at the start and the
                           end is adjusted. The minimum gap length at the start
                           and the end of the line segment in mm is:
                           min_gap_length = par{8}*par{6}
cross section through a dash:        longitudinal section:
   |<-----par{1}------>|                |<------par{5}------>|<--par{6}-->|
   +-------------------+  ---           +--------------------+            +---
   |                   |   ^            |   ^                |            |
   |       DASH        |   |            |   |      DASH      |    GAP     |
   |                   |   |            |   |                |            |
   |                   |   |par{3}   ---+   |par{3}          +------------+
   |                   |   |                |                    ^
   |                   |   |                |                    |par{4}
   |                   |   v                v                    v
---+  elevation level  +---------    --------- elevation level  --------------
--------------------------------------------------------------------------------|
style=3:
Continuously changing line width:
par{1} = minimum line width / mm
par{2} = maximum line width / mm
         The maximum line width must be greater than or equal to
         the minimum line width.
par{3} = sampling
         The ends of the polygon consists of semicircles, the center is equal
         to the first and last point of x and y. The number of edges of a
         semicircle is defined by sampling. Examples:
         sampling=1: only one edge, no circle
                  6: should be the standard value for lines:
                     - The lines are longer:
                       Line segements will be connected automatically
                     - Higher values increase the execution time.
par{4} = lifting dz (background) / mm
par{5} = direction reversal (0/1)
         0: The beginning of the line has the minimum line width.
            Note: In OpenStreetMap the direction of rivers is downstream
                  (the direction that the river flows).
         1: The end of the line has the minimum line width.
par{6} = increase in line width / per thousand (>=0)
         Example:
         5: With a total line length of 100 mm, the line width at the end 
            is 0.5 mm greater than the line width at the beginning.
         0: The line width is constantly equal to the minimum line width.
         If par{7}=0 and par{8}=0:
         Long line:  The maximum line width is reached before the end
                     of the line, the line width then remains constant.
         Short line: The maximum line width is not reached at the end
                     of the line.
par{7} = The maximum line width is not reached before the end of the line (0/1)
         1: long line:  The increase in line width is limited so that the
                        maximum line width is reached exactly at the end
                        of the line.
            short line: The maximum line width is not reached at the end
                        of the line.
par{8} = The maximum line width is always reached at the end of the line (0/1)
         The increase in line width is adjusted accordingly.
         This overwrites the setting of par{7}.
cross section:
   |<-par{1}...par{2}->|
   +-------------------+  ---
   |                   |   ^
   |                   |   |par{4}
   |                   |   v
---+  elevation level  +----------
--------------------------------------------------------------------------------|
style      = 4
Simple line: steady change in elevation
The elevation is linearly interpolated between the elevations at the
start and end point. The parameters are identical to those of style 1.
Notes:
- This line style can improve the appearance of bridges.
- The calculation of elevation data different from the terrain depends on the
  color number. This line style therefore does not work on transparent objects.
- The raw data of the line and the start and end points are saved together with
  the map object. It is therefore not possible to move the map object at a later
  stage. In this case, the map object must be recreated from a preview line.
- A bridge with this setting should only be cut at the edges of areas,
  not because of large differences in height.
--------------------------------------------------------------------------------|
%}

% Note: Continuously changing line width in combination with line symbols is difficult because in
% plotosmdata_plotdata_li_ar.m overlapping symbols are automatically clipped when lines overlap,
% depending on the line length. This function always takes all existing lines into account.
% If the width of an individual line is to be changed subsequently, this is no longer possible.

% next line styles ideas:
% tunnel (only symbol an begin and end)
% dashed line with larger background (e.g. railroad bridges)

global PP GV ELE

try
	
	% Default values:
	if nargin>0
		if nargin<3
			errormessage('line2poly: number of input arguments must be at least =3');
		end
		if nargin<4
			if ~iscell(par)
				linewidth				= par;
				par						= cell(2,1);
				par{1,1}					= linewidth ;		% line width
				par{2,1}					= 1;					% sampling
				par{3,1}					= 0;					% dz (>0 or <0)
			end
			if size(par,1)<=2
				par{3,1}					= 0;					% dz (>0 or <0)
			end
			style							= 1;
		end
		if nargin<5
			iobj							= 0;
		end
		if nargin<6
			obj_purpose					= {'map object'};
		end
		if nargin<7
			jointtype					= 'miter';
		end
		if nargin<8
			miterlimit					= 2;
		end
		if nargin<9
			in								= [];
		end
		if nargin<10
			iw								= [];
		end
		if nargin<11
			ir								= [];
		end
		testplot							= 0;
	else
		% Testplot:
		example							= 4;					% example
		testplot							= 1;
		t0_testplot						= clock;
		iobj								= 0;
		obj_purpose						= {'map object'};
		miterlimit						= 1;
		switch example
			case 1
				% style=1: simple line:
				ip_sampling				= 2;
				style						= 1;
				par						= cell(4,1);
				par{1,1}					= 1.5;				% line width
				par{ip_sampling,1}	= 3;					% sampling
				par{3,1}					= 0;					% dz (>0 or <0)
				x							= [2;3;1;0;0;1;1;3;3]*3;
				y							= [3;3;1;1;0;0;1;3;2]*3;
				jointtype				= 'round';
			case 2
				% style=1: simple line:
				ip_sampling				= 2;
				style						= 1;
				par						= cell(4,1);
				par{1,1}					= 1.5;				% line width
				par{ip_sampling,1}	= 6;					% sampling
				par{3,1}					= 0;					% dz (>0 or <0)
				x							= cumsum(ones(4,1)).^1.7;
				x							= [-x(end:-1:1);0;x];
				y							= (-ones(size(x))).^((1:length(x))')*5;
				x(end+1)					= x(end)+2;
				y(end+1)					= y(end);
				x(end+1)					= x(end)+2;
				y(end+1)					= y(end);
				x(end+1)					= x(end)+2;
				y(end+1)					= y(end);
				x(end+1)					= x(end);
				y(end+1)					= y(end)+2;
				jointtype				= 'bufferm';				% 'miter' 'bufferm'
			case 3
				% style=1: simple line:
				ip_sampling				= 2;
				style						= 1;
				par						= cell(4,1);
				par{1,1}					= 1.5;				% line width
				par{ip_sampling,1}	= 1;					% sampling
				par{3,1}					= 0;					% dz (>0 or <0)
				x							= [-1;-1  ;-0.8;0;0.8;1  ;1];
				y							= [ 1; 0.9; 0.5;0;0.5;0.9;1];
				jointtype				= 'miter';
			case 4
				% style=2: simple line or dashed line, higher resolution:
				ip_sampling				= 2;
				style						= 4;					% 1, 2, 4
				par{1,1}					= 0.5;				% line width
				par{ip_sampling,1}	= 6;					% sampling
				par{3,1}					= 1.2;				% dz of the dashs (>0 or <0)
				par{4,1}					= 0.6;				% dz of the gaps (>0 or <0)
				par{5,1}					= 1.0;				% length of the dashs
				par{6,1}					= 0.5;				% length of the gaps
				par{7,1}					= 1;					% dash surface type
				par{8,1}					= 0.25;				% minimum relative gap length
				% x							= cumsum(ones(4,1)).^1.7;
				% x							= [-x(end:-1:1);0;x];
				% y							= (-ones(size(x))).^((1:length(x))')*5;
				K							= 1.5;
				dphi						= 5;
				x							= (-180:dphi:115)*pi/180*K;
				y							= sin(x/K)*5;
				i_nan						= (round(length(x)/2)-3):1:(round(length(x)/2)+3);
				x(i_nan)					= nan;
				y(i_nan)					= nan;
				jointtype				= 'miter';
			case 5
				% style=2: simple line or dashed line, higher resolution:
				ip_sampling				= 2;
				style						= 2;
				par{1,1}					= 0.5;				% line width
				par{ip_sampling,1}	= 6;					% sampling
				par{3,1}					= 1.2;				% dz of the dashs (>0 or <0)
				par{4,1}					= 0.6;				% dz of the gaps (>0 or <0)
				par{5,1}					= 1.0;				% length of the dashs
				par{6,1}					= 0.8;				% length of the gaps
				par{7,1}					= 1;					% dash surface type
				par{8,1}					= 0.25;				% minimum relative gap length
				xmax						= 10;
				dx							= 0.466059;			% 0.466059 --> 1. segment has 1 dash, s_dashs_1_1/length_gap=0.25
				x							= [0:dx:xmax (xmax-dx):-dx:0]';
				ymax						= 0.5;
				dy							= ymax/((length(x)-1)/2);
				y							= (0:dy:(2*ymax))';
				i_nan						= 5:(length(x)-13):length(x);
				x(i_nan)					= nan;
				y(i_nan)					= nan;
				jointtype				= 'miter';
			case 6
				% style=3: Continuously changing line width:
				ip_sampling				= 3;
				style						= 3;					% 3
				par						= cell(8,1);
				par{1,1}					= 0.2;				% minimum line width / mm
				par{2,1}					= 1;					% maximum line width / mm
				par{ip_sampling,1}	= 6;					% sampling
				par{4,1}					= 1;					% lifting dz (background) / mm
				par{5,1}					= 0;					% direction reversal (0/1)
				par{6,1}					= 50;					% increase in line width / per thousand (>=0)
				par{7,1}					= 0;					% The maximum line width is not reached before the end of the line (0/1)
				par{8,1}					= 0;					% The maximum line width is always reached at the end of the line (0/1)
				x							= [0;3;3;6;6;10];
				y							= [0;0;1;1;0; 0];
				x							= [x;nan;x  ;nan;x  ];
				y							= [y;nan;y+4;nan;y+8];
				jointtype				= 'miter';			% 'round' / 'miter' / 'bufferm'
		end
	end
	if testplot==1
		hf=figure(10000);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha=axes;
		hold(ha,'on');
		if style==4
			% 3D-testplot:
			hf_3d=figure(20000);
			clf(hf_3d,'reset');
			set(hf_3d,'Tag','maplab3d_figure');
			ha_3d=axes;
			hold(ha_3d,'on');
		end
	end
	
	% Initializations:
	tol			= GV.tol_1;							% tolerance to check whether two points are equal
	miterlimit	= max(1,miterlimit);				% miterlimit should be at least =1
	if GV.warnings_off
		warning('off','MATLAB:polyshape:repairedBySimplify');
	end
	in						= in(:);
	in(in==0,:)			= [];
	iw						= iw(:);
	iw(iw==0,:)			= [];
	ir						= ir(:);
	ir(ir==0,:)			= [];
	poly_line			= polyshape();
	poly_lisy			= polyshape();
	ud_line				= [];
	ud_lisy				= [];							% If there are no symbols, ud_lisy must be empty!
	[x,y]					= removeExtraNanSeparators(x,y);
	x						= x(:);						% column vektors
	y						= y(:);
	
	% Assign project parameters:
	color_no_fgd	= 1;
	color_no_bgd	= 1;
	prio				= 1;
	if ~isempty(iobj)
		iobj		= max(0,round(iobj));
		if iobj>=1
			if ~isempty(PP)
				if isfield(PP,'obj')
					if size(PP.obj,1)>=iobj
						color_no_fgd	= PP.obj(iobj).color_no_fgd;
						color_no_bgd	= PP.obj(iobj).color_no_bgd;
						prio				= PP.obj(iobj).prio;
					end
				end
			end
		end
	end
	
	switch style
		
		case {1,3,4}
			%------------------------------------------------------------------------------------------------------------
			% style=1: simple line:
			% style=3: Continuously changing line width:
			
			% Initializations:
			if (style==1)||(style==4)
				% style=1: simple line:
				linewidth			= par{1};		% constant line width or minimum line width
				linewidth_max		= linewidth;	% constant line width or maximum line width
				ip_sampling			= 2;				% sampling
				dz_bgd				= par{3};		% dz of the background
				dir_reversal		= 0;				% direction reversal (0/1)
				increase_in_liwi	= 0;				% increase in line width / per thousand (>=0)
				lim_incr_in_liwi	= 0;				% The maximum line width is not reached before the end of the line (0/1)
				set_incr_in_liwi	= 0;				% The maximum line width is always reached at the end of the line (0/1)
				if style==4
					% Steady change in elevation:
					[poly_legbgd,~,~]	= get_poly_legbgd;
					ud_line.x_scint	= zeros(0,1);
					ud_line.y_scint	= zeros(0,1);
					ud_line.z_scint	= zeros(0,1);
					ud_line.x_zmin		= zeros(0,1);
					ud_line.y_zmin		= zeros(0,1);
					ud_line.z_zmin		= zeros(0,1);
					ud_line.x_zmax		= zeros(0,1);
					ud_line.y_zmax		= zeros(0,1);
					ud_line.z_zmax		= zeros(0,1);
				end
			elseif style==3
				% style=3: Continuously changing line width:
				linewidth			= par{1,1};		% minimum line width / mm
				linewidth_max		= par{2,1};		% maximum line width / mm
				ip_sampling			= 3;				% sampling
				dz_bgd				= par{4,1};		% lifting dz (background) / mm
				dir_reversal		= par{5,1};		% direction reversal (0/1)
				increase_in_liwi	= par{6,1};		% increase in line width / per thousand (>=0)
				lim_incr_in_liwi	= par{7,1};		% The maximum line width is not reached before the end of the line (0/1)
				set_incr_in_liwi	= par{8,1};		% The maximum line width is always reached at the end of the line (0/1)
				ud_line.linepar		= par;
				ud_line.x				= x;
				ud_line.y				= y;
				ud_line.liwi_min		= [];
				ud_line.liwi_max		= [];
				ud_line.xy_liwimin	= zeros(0,2);
				ud_line.xy_liwimax	= zeros(0,2);
			else
				errormessage;
			end
			dz_fgd				= [];											% dz of the foreground
			extra					= [];
			extra.lb				= [];
			extra.rb				= [];
			% The maximum line width must be greater than or equal to the minimum line width:
			linewidth_max		= max(linewidth_max,linewidth);
			% The increase in line width must be >=0:
			increase_in_liwi	= max(0,increase_in_liwi/1000);
			% sampling must be a positive integer:
			sampling				= max(1,round(par{ip_sampling}));
			dphi_sampl			= 180/sampling;
			% Background (poly_line): Line
			% The object priority of the background MUST:
			% 1) be smaller the the object priority of the foreground AND
			% 2) be non integer: In this way the object is recognized as background in map2stl.
			% 3) differ from the foreground object priority by LESS than 0.5.
			ud_line.color_no		= color_no_bgd;
			ud_line.color_no_pp	= color_no_bgd;
			ud_line.dz				= dz_bgd;
			ud_line.prio			= prio-0.25;
			ud_line.iobj			= iobj;
			ud_line.level			= 0;
			ud_line.surftype		= 100;
			ud_line.rotation		= 0;
			ud_line.obj_purpose	= obj_purpose;
			ud_line.in				= in;
			ud_line.iw				= iw;
			ud_line.ir				= ir;
			
			% Assignment of the userdata, the total line width and ip_sampling without calculating the polygon:
			if isempty(x)&&isempty(y)
				return
			end
			
			% Steady change in elevation:
			% Increase the resolution:
			% This improves the connection between the lateral slope of the neighboring lines at the beginning and end,
			% which follows the terrain, and the lateral slope of the line to be calculated, which is not  sloped.
			if style==4
				dmax			= linewidth;	% Inserts vertices, so that the distance between two vertices is less than dmax
				dmin			= [];				%
				nmin			= [];				%
				keep_flp		= 1;				% Keep the first and the last point of the line (default).
				[x,y]			= changeresolution_xy(x,y,dmax,dmin,nmin,keep_flp);
			end
			
			% The x- and y-vectors can be NaN-delimited: Divide them into parts xp/yp and calculate the linewidth:
			% xp_cell{k_xyp,1}				x-values of the vertices of line segmenbt k_xyp
			% yp_cell{k_xyp,1}				y-values of the vertices of line segmenbt k_xyp
			% linelength_cell{k_xyp,1}		line length from the start point to the vertices of segment k_xyp
			% total_linelength				length of all line segments: =linelength_cell{k_xyp,1}(end,1)
			% linewidth_cell{k_xyp,1}		line widths of segment k_xyp
			if dir_reversal~=0
				x					= x(end:-1:1);
				y					= y(end:-1:1);
			end
			i_nan_x				= find(isnan(x));
			i_nan_y				= find(isnan(y));
			if ~isequal(i_nan_x,i_nan_y)
				errormessage;
			end
			xp_cell				= cell(length(i_nan_x)+1,1);
			yp_cell				= cell(length(i_nan_x)+1,1);
			linelength_cell	= cell(length(i_nan_x)+1,1);
			linelength_0		= 0;
			for k_nan_x=0:length(i_nan_x)
				if k_nan_x==0
					i1	= 1;
				else
					i1	= i_nan_x(k_nan_x)+1;
				end
				if k_nan_x==length(i_nan_x)
					i2	= length(x);
				else
					i2	= i_nan_x(k_nan_x+1)-1;
				end
				xp_cell{k_nan_x+1,1}				= x(i1:i2);
				yp_cell{k_nan_x+1,1}				= y(i1:i2);
				dxp									= x((i1+1):i2)-x(i1:(i2-1));
				dyp									= y((i1+1):i2)-y(i1:(i2-1));
				linelength_cell{k_nan_x+1,1}	= [linelength_0;linelength_0+cumsum(sqrt(dxp.^2+dyp.^2))];
				linelength_0						= linelength_cell{k_nan_x+1,1}(end);
			end
			total_linelength		= linelength_0;
			if set_incr_in_liwi~=0
				% The maximum line width is always reached at the end of the line:
				increase_in_liwi		= (linewidth_max-linewidth)/total_linelength;
			else
				if lim_incr_in_liwi~=0
					% The maximum line width is not reached before the end of the line:
					increase_in_liwi		= min(increase_in_liwi,(linewidth_max-linewidth)/total_linelength);
				end
			end
			linewidth_cell			= cell(size(xp_cell,1),1);
			for k_xyp=1:size(xp_cell,1)
				linewidth_cell{k_xyp,1}	= linewidth+linelength_cell{k_xyp,1}*increase_in_liwi;
				i_xyp_logical		= (linewidth_cell{k_xyp,1}>linewidth_max);
				linewidth_cell{k_xyp,1}(i_xyp_logical)		= linewidth_max;
				if style==3
					i_xyp				= find(i_xyp_logical);
					if ~isempty(i_xyp)
						if size(ud_line.xy_liwimax,1)==0
							ud_line.xy_liwimax	= [xp_cell{k_xyp,1}(i_xyp(1)) yp_cell{k_xyp,1}(i_xyp(1))];
						end
					end
				end
			end
			
			% Userdata:
			if style==3
				ud_line.linelength	= total_linelength;
				ud_line.liwi_min		= linewidth_cell{1  ,1}(1  );
				ud_line.liwi_max		= linewidth_cell{end,1}(end);
				ud_line.xy_liwimin	= [xp_cell{1  ,1}(1  ) yp_cell{1  ,1}(1  )];
				xy_liwimax_end			= [xp_cell{end,1}(end) yp_cell{end,1}(end)];
				if ~isequal(ud_line.xy_liwimax,xy_liwimax_end)
					ud_line.xy_liwimax	= [ud_line.xy_liwimax;xy_liwimax_end];
				end
			end
			
			% Elevation at the start and end point:
			if style==4
				zp_start					= interp_ele(...
					xp_cell{1,1}(1,1),...					% query points x
					yp_cell{1,1}(1,1),...					% query points y
					ELE,...										% elevation structure
					color_no_bgd,...							% color numbers
					GV.legend_z_topside_bgd,...			% legend background z-value
					poly_legbgd,...							% legend background polygon
					'interp2');									% interpolation method
				zp_end					= interp_ele(...
					xp_cell{end,1}(end,1),...				% query points x
					yp_cell{end,1}(end,1),...				% query points y
					ELE,...										% elevation structure
					color_no_bgd,...							% color numbers
					GV.legend_z_topside_bgd,...			% legend background z-value
					poly_legbgd,...							% legend background polygon
					'interp2');									% interpolation method
				dzp_start_end			= zp_end-zp_start;
			end
			
			% Create the line:
			for k_xyp=1:size(xp_cell,1)
				% xp				x-values of the vertices of line segmenbt k_xyp
				% yp				y-values of the vertices of line segmenbt k_xyp
				% liwip			line widths at all vertices of line segmenbt k_xyp
				
				xp				= xp_cell{k_xyp,1};
				yp				= yp_cell{k_xyp,1};
				liwip			= linewidth_cell{k_xyp,1};
				lilep			= linelength_cell{k_xyp,1};
				
				% Delete duplicate points:
				i				= 1:(length(xp)-1);
				i_dp			= (...
					(abs(xp(i)-xp(i+1))<tol) & ...
					(abs(yp(i)-yp(i+1))<tol)       );
				xp(i_dp)		= [];
				yp(i_dp)		= [];
				liwip(i_dp)	= [];
				
				if strcmp(jointtype,'bufferm')
					% Uses the bufferm function:
					
					[xpoly,ypoly]	= bufferm(xp,yp,liwip(1,1)/2,'out',2*sampling);
					poly_line		= union(poly_line,polyshape(xpoly,ypoly));
					
				elseif strcmp(jointtype,'round')
					% Create a polygon of every segment separatly:
					
					for k=1:(length(xp)-1)
						phi_k_kp1	= angle(xp(k+1)-xp(k)+1i*(yp(k+1)-yp(k)))*180/pi;
						p				= ones(2*(sampling+1),1)*9999;
						i				= 0;
						for s=0:sampling			% vertex 1
							i			= i+1;
							phi		= 90+phi_k_kp1+dphi_sampl*s;
							p(i,1)	= xp(k)+1i*yp(k)+liwip(k)/2*exp(1i*phi*pi/180);
						end
						for s=0:sampling			% vertex 2
							i			= i+1;
							phi		= 270+phi_k_kp1+dphi_sampl*s;
							p(i,1)	= xp(k+1)+1i*yp(k+1)+liwip(k+1)/2*exp(1i*phi*pi/180);
						end
						poly_line	= union(poly_line,polyshape(real(p),imag(p)));
					end
					
				elseif strcmp(jointtype,'miter')
					% Create a polygon of every segment separatly:
					
					for k=1:(length(xp)-1)
						if k==1
							dir_kp1_kp2		= xp(k+1)-xp(k)+1i*(yp(k+1)-yp(k));
							phi_kp1_kp2		= angle(dir_kp1_kp2)*180/pi;
							p_kp1_kp2		= ones(4,1)*9999;
							p_kp1_kp2(1,1)	= xp(k  )+1i*yp(k  )+liwip(k)/2*exp(1i*( 90+phi_kp1_kp2+  0)*pi/180);
							p_kp1_kp2(2,1)	= xp(k  )+1i*yp(k  )+liwip(k)/2*exp(1i*( 90+phi_kp1_kp2+180)*pi/180);
							p_kp1_kp2(3,1)	= xp(k+1)+1i*yp(k+1)+liwip(k+1)/2*exp(1i*(270+phi_kp1_kp2+  0)*pi/180);
							p_kp1_kp2(4,1)	= xp(k+1)+1i*yp(k+1)+liwip(k+1)/2*exp(1i*(270+phi_kp1_kp2+180)*pi/180);
							poly_kp1_kp2	= polyshape(real(p_kp1_kp2),imag(p_kp1_kp2));
							poly_line		= union(poly_line,poly_kp1_kp2);
							extra.lb			= [real(p_kp1_kp2(1,1)) imag(p_kp1_kp2(1,1))];
							extra.rb			= [real(p_kp1_kp2(2,1)) imag(p_kp1_kp2(2,1))];
						end
						phi_k_kp1			= phi_kp1_kp2;
						p_k_kp1				= p_kp1_kp2;
						if k<=(length(xp)-2)
							dir_kp1_kp2		= xp(k+2)-xp(k+1)+1i*(yp(k+2)-yp(k+1));
							phi_kp1_kp2		= angle(dir_kp1_kp2)*180/pi;
							p_kp1_kp2(1,1)	= xp(k+1)+1i*yp(k+1)+liwip(k+1)/2*exp(1i*( 90+phi_kp1_kp2+  0)*pi/180);
							p_kp1_kp2(2,1)	= xp(k+1)+1i*yp(k+1)+liwip(k+1)/2*exp(1i*( 90+phi_kp1_kp2+180)*pi/180);
							p_kp1_kp2(3,1)	= xp(k+2)+1i*yp(k+2)+liwip(k+2)/2*exp(1i*(270+phi_kp1_kp2+  0)*pi/180);
							p_kp1_kp2(4,1)	= xp(k+2)+1i*yp(k+2)+liwip(k+2)/2*exp(1i*(270+phi_kp1_kp2+180)*pi/180);
							delta_x2	= (phi_kp1_kp2-phi_k_kp1);											% convert delta_x2 to +-180°  ==>
							delta		= ((delta_x2+180)-floor((delta_x2+180)/360)*360-180)/2;	% delta = +-90°
						end
						% Form the corner between two segments:
						if k<=(length(xp)-2)
							% phi_kp1_kp2>phi_k_kp1 or delta>0:                   phi_kp1_kp2<phi_k_kp1 or delta<0:
							%                      p(4,1)----k+2-----p(3,1)             p(1,1)-------------------p(4,1)----ipl
							%                        |                 |                  |                       |delta  /
							%                        | segment_kp1_kp2 |                  |   segment_k_kp1       |    /
							%                        |                 |                  |                       | /
							%       p(1,1)----------ipl------p(4,1)    |                  k            p(2,1)----k+1-----p(1,1)
							%         |              | \ delta|        |                  |              |     /  |        |
							%         |              |   \    |        |                  |              |   /    |        |
							%         |              |     \  |        |                  |              | / delta|        |
							%         k            p(1,1)----k+1-----p(2,1)            p(2,1)-----------ipr-----p(3,1)     |
							%         |                       | \                                        |                 |
							%         |   segment_k_kp1       |    \                                     | segment_kp1_kp2 |
							%         |                       |delta  \                                  |                 |
							%       p(2,1)------------------p(3,1)-----ipr                             p(3,1)----k+2-----p(4,1)
							hypotenuse	= liwip(k+1)/2/cos(delta*pi/180);
							p_rb			= xp(k+1)+1i*yp(k+1)+hypotenuse*exp(1i*(phi_k_kp1-90+delta)*pi/180);
							p_lb			= xp(k+1)+1i*yp(k+1)+hypotenuse*exp(1i*(phi_k_kp1+90+delta)*pi/180);
							hypotenuse	= min(hypotenuse,miterlimit*liwip(k+1)/2);
							p_right		= xp(k+1)+1i*yp(k+1)+hypotenuse*exp(1i*(phi_k_kp1-90+delta)*pi/180);
							p_left		= xp(k+1)+1i*yp(k+1)+hypotenuse*exp(1i*(phi_k_kp1+90+delta)*pi/180);
							% The vertex of the corner ist the intersection point of the segment edges:
							if delta>0
								poly_corner_right		= polyshape(...
									[xp(k) real(p_kp1_kp2(1,1)) real(p_kp1_kp2(4,1)) real(p_kp1_kp2(3,1)) real(p_kp1_kp2(2,1)) real(p_right) real(p_k_kp1(3,1))],...
									[yp(k) imag(p_kp1_kp2(1,1)) imag(p_kp1_kp2(4,1)) imag(p_kp1_kp2(3,1)) imag(p_kp1_kp2(2,1)) imag(p_right) imag(p_k_kp1(3,1))]);
								poly_line				= union(poly_line,poly_corner_right);
								extra.lb					= [extra.lb;real(p_lb) imag(p_lb)];
								extra.rb					= [extra.rb;...
									real(p_k_kp1(3,1))   imag(p_k_kp1(3,1))  ;...
									real(p_right)        imag(p_right)       ;...
									real(p_kp1_kp2(2,1)) imag(p_kp1_kp2(2,1))    ];
							else
								poly_corner_left		= polyshape(...
									[xp(k) real(p_kp1_kp2(2,1)) real(p_kp1_kp2(3,1)) real(p_kp1_kp2(4,1)) real(p_kp1_kp2(1,1)) real(p_left) real(p_k_kp1(4,1))],...
									[yp(k) imag(p_kp1_kp2(2,1)) imag(p_kp1_kp2(3,1)) imag(p_kp1_kp2(4,1)) imag(p_kp1_kp2(1,1)) imag(p_left) imag(p_k_kp1(4,1))]);
								poly_line				= union(poly_line,poly_corner_left);
								extra.lb					= [extra.lb;...
									real(p_k_kp1(4,1))   imag(p_k_kp1(4,1))  ;...
									real(p_left)         imag(p_left)        ;...
									real(p_kp1_kp2(1,1)) imag(p_kp1_kp2(1,1))    ];
								extra.rb					= [extra.rb;real(p_rb) imag(p_rb)];
							end
							if style==4
								% Elevation at vertex k+1:
								p_lcr					= [p_left;xp(k+1)+1i*yp(k+1);p_right];
								zp_lcr				= interp_ele(...
									real(p_lcr),...							% query points xp(k+1) left side
									imag(p_lcr),...							% query points yp(k+1) left side
									ELE,...										% elevation structure
									color_no_bgd,...							% color numbers
									GV.legend_z_topside_bgd,...			% legend background z-value
									poly_legbgd,...							% legend background polygon
									'interp2');
								zp_center			= zp_start+lilep(k+1)/total_linelength*dzp_start_end;
								ud_line.x_scint	= [ud_line.x_scint;real(p_left);real(p_right)];
								ud_line.y_scint	= [ud_line.y_scint;imag(p_left);imag(p_right)];
								method_lateral_slope		= 2;
								switch method_lateral_slope
									case 1
										% The lateral slope follows the terrain:
										ud_line.z_scint				= [ud_line.z_scint;...
											zp_lcr(1,1)+zp_center-zp_lcr(2,1);...	% left side
											zp_lcr(3,1)+zp_center-zp_lcr(2,1)];		% right side
									case 2
										ud_line.z_scint				= [ud_line.z_scint;...
											zp_center;...									% left side
											zp_center];										% right side
								end
								if (k_xyp==1)&&(k==1)
									if zp_start<zp_end
										ud_line.x_zmin		= [ud_line.x_scint((end-1):end,:)];
										ud_line.y_zmin		= [ud_line.y_scint((end-1):end,:)];
										ud_line.z_zmin		= [ud_line.z_scint((end-1):end,:)];
									else
										ud_line.x_zmax		= [ud_line.x_scint((end-1):end,:)];
										ud_line.y_zmax		= [ud_line.y_scint((end-1):end,:)];
										ud_line.z_zmax		= [ud_line.z_scint((end-1):end,:)];
									end
								end
								if (k_xyp==size(xp_cell,1))&&(k==(length(xp)-2))
									if zp_start<zp_end
										ud_line.x_zmax		= [ud_line.x_scint((end-1):end,:)];
										ud_line.y_zmax		= [ud_line.y_scint((end-1):end,:)];
										ud_line.z_zmax		= [ud_line.z_scint((end-1):end,:)];
									else
										ud_line.x_zmin		= [ud_line.x_scint((end-1):end,:)];
										ud_line.y_zmin		= [ud_line.y_scint((end-1):end,:)];
										ud_line.z_zmin		= [ud_line.z_scint((end-1):end,:)];
									end
								end
							end
						end
						% Form the beginning of the line:
						if k==1
							p				= ones(sampling+2,1)*9999;
							for i=0:sampling
								phi		= phi_k_kp1+90+dphi_sampl*i;
								p(i+1,1)	= xp(k)+1i*yp(k)+liwip(k)/2*exp(1i*phi*pi/180);
							end
							if style==4
								% Elevation at the beginning of the line:
								zp				= interp_ele(...
									real(p(1:(end-1))),...									% query points xp(k+1) left side
									imag(p(1:(end-1))),...									% query points yp(k+1) left side
									ELE,...										% elevation structure
									color_no_bgd,...							% color numbers
									GV.legend_z_topside_bgd,...			% legend background z-value
									poly_legbgd,...							% legend background polygon
									'interp2');
								zp_k			= interp_ele(...
									real(xp(k)+1i*yp(k)),...				% query points xp(k+1) left side
									imag(xp(k)+1i*yp(k)),...				% query points yp(k+1) left side
									ELE,...										% elevation structure
									color_no_bgd,...							% color numbers
									GV.legend_z_topside_bgd,...			% legend background z-value
									poly_legbgd,...							% legend background polygon
									'interp2');
								zp_center			= zp_start+lilep(k)/total_linelength*dzp_start_end;
								ud_line.x_scint	= [ud_line.x_scint;real(p(1:(end-1)))];
								ud_line.y_scint	= [ud_line.y_scint;imag(p(1:(end-1)))];
								ud_line.z_scint	= [ud_line.z_scint;zp+zp_center-zp_k];
							end
							p(end,1)		= xp(k+1)+1i*yp(k+1);
							poly_line	= union(poly_line,polyshape(real(p),imag(p)));
						end
						% Form the end of the line:
						if k==(length(xp)-1)
							p				= ones(sampling+2,1)*9999;
							for i=0:sampling
								phi		= phi_k_kp1-90+dphi_sampl*i;
								p(i+1,1)	= xp(k+1)+1i*yp(k+1)+liwip(k+1)/2*exp(1i*phi*pi/180);
							end
							if style==4
								% Elevation at the end of the line:
								zp				= interp_ele(...
									real(p(1:(end-1))),...					% query points xp(k+1) left side
									imag(p(1:(end-1))),...					% query points yp(k+1) left side
									ELE,...										% elevation structure
									color_no_bgd,...							% color numbers
									GV.legend_z_topside_bgd,...			% legend background z-value
									poly_legbgd,...							% legend background polygon
									'interp2');
								zp_kp1		= interp_ele(...
									real(xp(k+1)+1i*yp(k+1)),...			% query points xp(k+1) left side
									imag(xp(k+1)+1i*yp(k+1)),...			% query points yp(k+1) left side
									ELE,...										% elevation structure
									color_no_bgd,...							% color numbers
									GV.legend_z_topside_bgd,...			% legend background z-value
									poly_legbgd,...							% legend background polygon
									'interp2');
								zp_center			= zp_start+lilep(k+1)/total_linelength*dzp_start_end;
								ud_line.x_scint	= [ud_line.x_scint;real(p(1:(end-1)))];
								ud_line.y_scint	= [ud_line.y_scint;imag(p(1:(end-1)))];
								ud_line.z_scint	= [ud_line.z_scint;zp+zp_center-zp_kp1];
							end
							p(end,1)		= xp(k)+1i*yp(k);
							poly_line	= union(poly_line,polyshape(real(p),imag(p)));
							extra.lb		= [extra.lb;real(p((end-1),1)) imag(p((end-1),1))];
							extra.rb		= [extra.rb;real(p( 1     ,1)) imag(p( 1     ,1))];
						end
					end
					
				end
				
			end
			
			
			
		case 2
			%------------------------------------------------------------------------------------------------------------
			% style=2: dashed line:
			
			% Initializations:
			ip_sampling				= 2;
			linewidth				= par{1};									% constant line width or minimum line width
			linewidth_max			= linewidth;								% constant line width or maximum line width
			sampling					= max(1,round(par{ip_sampling}));	% sampling must be a positive integer
			dz_fgd					= par{3};									% dz of the foreground
			dz_bgd					= par{4};									% dz of the background
			length_dash				= par{5};
			length_gap				= par{6};
			surftype_dash			= par{7};
			min_gap_length_rel	= par{8};
			poly_dash				= polyshape();								% Collect all dashs
			
			% UserData:
			% Foreground (poly_dash): Dashs, Line Symbol
			ud_lisy.color_no		= color_no_fgd;
			ud_lisy.color_no_pp	= color_no_fgd;
			ud_lisy.dz				= dz_fgd;
			ud_lisy.prio			= prio;
			ud_lisy.iobj			= iobj;
			ud_lisy.level			= 1;
			ud_lisy.surftype		= 100+surftype_dash;
			ud_lisy.rotation		= 0;
			ud_lisy.obj_purpose	= obj_purpose;
			ud_lisy.in				= in;
			ud_lisy.iw				= iw;
			ud_lisy.ir				= ir;
			% Background (poly_line): Line
			% The object priority of the background MUST:
			% 1) be smaller the the object priority of the foreground AND
			% 2) be non integer: In this way the object is recognized as background in map2stl.
			% 3) differ from the foreground object priority by LESS than 0.5.
			ud_line.color_no		= color_no_bgd;
			ud_line.color_no_pp	= color_no_bgd;
			ud_line.dz				= dz_bgd;
			ud_line.prio			= prio-0.25;
			ud_line.iobj			= iobj;
			ud_line.level			= 0;
			ud_line.surftype		= 100;
			ud_line.rotation		= 0;
			ud_line.obj_purpose	= obj_purpose;
			ud_line.in				= in;
			ud_line.iw				= iw;
			ud_line.ir				= ir;
			
			% Assignment of the userdata, the total line width and ip_sampling without calculating the polygon:
			if isempty(x)&&isempty(y)
				return
			end
			
			% The x- and y-vectors can be NaN-delimited: Divide them into parts x_v, y_v:
			i_nan_x	= find(isnan(x));
			i_nan_y	= find(isnan(y));
			if ~isequal(i_nan_x,i_nan_y)
				errormessage;
			end
			for k_i_nan_x=0:length(i_nan_x)
				if k_i_nan_x==0
					i1	= 1;
				else
					i1	= i_nan_x(k_i_nan_x)+1;
				end
				if k_i_nan_x==length(i_nan_x)
					i2	= length(x);
				else
					i2	= i_nan_x(k_i_nan_x+1)-1;
				end
				x_v	= x(i1:i2);
				y_v	= y(i1:i2);
				x_v	= x_v(:);
				y_v	= y_v(:);
				
				% Delete duplicate points:
				k			= 1:(length(x_v)-1);
				i			= (...
					(abs(x_v(k)-x_v(k+1))<tol) & ...
					(abs(y_v(k)-y_v(k+1))<tol)       );
				x_v(i)		= [];
				y_v(i)		= [];
				
				% Length of the current part: smax
				nxyp		= length(x_v);
				i			= (1:(nxyp-1))';
				s_v		= [0;cumsum(sqrt((x_v(i+1)-x_v(i)).^2+(y_v(i+1)-y_v(i)).^2))];
				i_v		= (1:nxyp)';
				smax		= s_v(end);
				% Number of the dashs:
				% K = minimum relative gap length at start and end of the line (K = min_gap_length_rel = 0...1)
				% smax = n_dashs*length_dash + (n_dashs-1)*length_gap + 2*K*length_gap
				% smax = n_dashs*length_dash + n_dashs*length_gap - length_gap + 2*K*length_gap
				% smax = n_dashs*(length_dash+length_gap) + (2*K-1)*length_gap
				% smax - (2*K-1)*length_gap = n_dashs*(length_dash+length_gap)
				% n_dashs = (smax - (2*K-1)*length_gap) / (length_dash+length_gap)
				n_dashs		= floor((smax - (2*min_gap_length_rel-1)*length_gap) / (length_dash+length_gap));
				
				if (n_dashs>0)&&(length_gap>0)
					% There is at least one dasch:
					% first and last points of the dashs:
					s_dashs_1_1	= smax/2-(n_dashs*length_dash+(n_dashs-1)*length_gap)/2;
					% Ktest = s_dashs_1_1/length_gap
					s_dashs_1	= (s_dashs_1_1:(length_gap+length_dash):(smax-length_gap/2-length_dash/2))';
					s_dashs_2	= s_dashs_1+length_dash;
					i_dashs_1 = ceil(interp1(...
						s_v,...				% sample points x
						i_v,...				% sample points y
						s_dashs_1,...		% query points x
						'linear',...		% method
						'extrap'));			% extrapolation
					i_dashs_2 = floor(interp1(...
						s_v,...				% sample points x
						i_v,...				% sample points y
						s_dashs_2,...		% query points x
						'linear',...		% method
						'extrap'));			% extrapolation
					x_dashs_1 = interp1(...
						s_v,...				% sample points x
						x_v,...				% sample points y
						s_dashs_1,...		% query points x
						'linear',...		% method
						'extrap');			% extrapolation
					y_dashs_1 = interp1(...
						s_v,...				% sample points x
						y_v,...				% sample points y
						s_dashs_1,...		% query points x
						'linear',...		% method
						'extrap');			% extrapolation
					x_dashs_2 = interp1(...
						s_v,...				% sample points x
						x_v,...				% sample points y
						s_dashs_2,...		% query points x
						'linear',...		% method
						'extrap');			% extrapolation
					y_dashs_2 = interp1(...
						s_v,...				% sample points x
						y_v,...				% sample points y
						s_dashs_2,...		% query points x
						'linear',...		% method
						'extrap');			% extrapolation
					
					% Add the dashs to poly_dash:
					for id=1:length(s_dashs_1)
						x_dash_v		=  [...
							x_dashs_1(id);...
							x_v(i_dashs_1(id):i_dashs_2(id))
							x_dashs_2(id)];
						y_dash_v		=  [...
							y_dashs_1(id);...
							y_v(i_dashs_1(id):i_dashs_2(id))
							y_dashs_2(id)];
						% Delete duplicate points:
						k				= 1:(length(x_dash_v)-1);
						i				= (...
							(abs(x_dash_v(k)-x_dash_v(k+1))<tol) & ...
							(abs(y_dash_v(k)-y_dash_v(k+1))<tol)       );
						x_dash_v(i)	= [];
						y_dash_v(i)	= [];
						poly_d		= line2poly(x_dash_v,y_dash_v,linewidth);
						% Overlapping dashs should not be united:
						poly_dash_buff		= polybuffer(poly_dash,GV.d_forebackgrd_plotobj,...
							'JointType','miter','MiterLimit',2);
						poly_d				= subtract(poly_d,poly_dash_buff,...
							'KeepCollinearPoints',false);
						poly_dash			= union(poly_dash,poly_d);
					end
				end
			end
			
			% Line background:
			poly_line		= line2poly(x,y,{linewidth;sampling});
			
			% The dashs must be inside poly_gap: less problems in map2stl.m:
			poly_line_buff		= polybuffer(poly_line,-GV.d_forebackgrd_plotobj,'JointType','miter','MiterLimit',2);
			poly_dash			= intersect(poly_dash,poly_line_buff,'KeepCollinearPoints',false);
			
			% Assign output arguments:
			extra						= [];
			
			% Foreground (poly_dash): Dashs, Line Symbol
			poly_lisy				= poly_dash;
			
		otherwise
			errortext	= sprintf([...
				'The area style number %g is not defined\n',...
				'(object number %g).'],style,iobj);
			errormessage(errortext);
	end
	
	if GV.warnings_off
		warning('on','MATLAB:polyshape:repairedBySimplify');
	end
	
	% Testplot:
	if testplot==1
		t_line2poly	= etime(clock,t0_testplot);
		fprintf(1,'t_line2poly = % g\n',t_line2poly);
		switch style
			case {1,3,4}
				plot(ha,poly_line)
				plot(ha,x,y,'x-r','MarkerSize',9,'LineWidth',1)
				plot(ha,poly_line.Vertices(:,1),poly_line.Vertices(:,2),'.b','MarkerSize',15,'LineWidth',1)
				if ~isempty(extra.lb)
					plot(ha,extra.lb(:,1),extra.lb(:,2),'--+m');
					plot(ha,extra.rb(:,1),extra.rb(:,2),'--+m');
				end
				axis(ha,'equal');
				if style==3
					plot(ha,...
						ud_line.xy_liwimin(1,1),ud_line.xy_liwimin(1,2),...
						'Color'     ,[0 1 1]*0.5,...
						'Visible'   ,'on',...
						'LineStyle' ,'none',...
						'LineWidth' ,GV.preview.LineWidth,...
						'Marker'    ,GV.preview.Marker,...
						'MarkerSize',70,...
						'DisplayName','minimum line width',...
						'UserData',[]);
					plot(ha,...
						ud_line.xy_liwimax(:,1),ud_line.xy_liwimax(:,2),...
						'Color'     ,[1 0 1]*0.5,...
						'Visible'   ,'on',...
						'LineStyle' ,'none',...
						'LineWidth' ,GV.preview.LineWidth,...
						'Marker'    ,GV.preview.Marker,...
						'MarkerSize',70,...
						'DisplayName','maximum line width',...
						'UserData',[]);
				end
				if style==4
					% Steady change in elevation:
					xmin	= min(x)-1;
					xmax	= max(x)+1;
					ymin	= min(y)-1;
					ymax	= max(y)+1;
					ifs	= 1;
					inside	= ...
						(ELE.elefiltset(ifs,1).xm_mm>=xmin)&...
						(ELE.elefiltset(ifs,1).xm_mm<=xmax)&...
						(ELE.elefiltset(ifs,1).ym_mm>=ymin)&...
						(ELE.elefiltset(ifs,1).ym_mm<=ymax);
					cmin		= find(any(inside,1),1,'first');
					cmax		= find(any(inside,1),1,'last');
					rmin		= find(any(inside,2),1,'first');
					rmax		= find(any(inside,2),1,'last');
					surf(...
						ELE.elefiltset(ifs,1).xm_mm(rmin:rmax,cmin:cmax),...
						ELE.elefiltset(ifs,1).ym_mm(rmin:rmax,cmin:cmax),...
						ELE.elefiltset(ifs,1).zm_mm(rmin:rmax,cmin:cmax),...
						'LineStyle','none',...
						'FaceAlpha',0.7);
					plot3(ha_3d,ud_line.x_scint,ud_line.y_scint,ud_line.z_scint,'.r')
					plot3(ha_3d,ud_line.x_zmin,ud_line.y_zmin,ud_line.z_zmin,'Color','m','Marker','square','LineWidth',1)
					plot3(ha_3d,ud_line.x_zmax,ud_line.y_zmax,ud_line.z_zmax,'Color','b','Marker','square','LineWidth',1)
					xyz		= [ud_line.x_scint ud_line.y_scint ud_line.z_scint];
					diff_xyz	= diff(xyz,1,1);
					i_equal_xyz	= find(sum(abs(diff_xyz),2)<1e-3)
					set(ha_3d,'XLim',[xmin xmax]);
					set(ha_3d,'YLim',[ymin ymax]);
					axis(ha_3d,'equal');
					xlabel(ha_3d,'x / mm');
					ylabel(ha_3d,'y / mm');
					zlabel(ha_3d,'z / mm');
					view(ha_3d,3);
				end
			case 2
				% plot(ha,poly_line)
				plot(ha,poly_line)
				plot(ha,poly_lisy)
				plot(ha,x,y,'x-r','MarkerSize',9,'LineWidth',1)
				% plot(ha,poly_dash.Vertices(:,1),poly_dash.Vertices(:,2),'.b','MarkerSize',15,'LineWidth',1)
				% plot(ha,poly_gap.Vertices(:,1),poly_gap.Vertices(:,2),'.b','MarkerSize',15,'LineWidth',1)
				axis(ha,'equal');
		end
	end
	
catch ME
	errormessage('',ME);
end

