function T=triang_poly_grid(poly,xm,ym,zm,poly_limit)
% Calculates triangulation data of the polygon poly
% -	x- and y-values of the grid defined by xm, ym that are inside poly will be added to T.
% -	z-values are added to T by interpolating zm.
% -	If poly_limit is specified, alle points and edges of T outside poly_limit will be deleted.

global GV

try

	T			= [];
	T.P		= zeros(0,3);
	T.CL		= zeros(0,3);

	xv			= xm(:);
	yv			= ym(:);

	poly_reg	= regions(poly);
	for ireg=1:size(poly_reg,1)

		% Calculate constraint:
		xC	= zeros(0,1);
		yC	= zeros(0,1);
		C	= zeros(0,2);
		for ib=1:numboundaries(poly_reg(ireg,1))
			[x_ib,y_ib] = boundary(poly_reg(ireg,1),ib);
			x_ib			= x_ib(1:(end-1));
			y_ib			= y_ib(1:(end-1));
			rows_x_ib	= length(x_ib);
			rows_xyC_0	= length(xC);
			xC				= [xC;x_ib];
			yC				= [yC;y_ib];
			C				= [C;rows_xyC_0+(1:rows_x_ib)' rows_xyC_0+[(2:rows_x_ib)';1]];
		end

		% Add points of the grid:
		% TFin	= isinterior(poly_reg(ireg,1),xv,yv);
		TFin	= inpolygon(...				% faster than isinterior
			xv,...								% query points
			yv,...
			poly_reg(ireg,1).Vertices(:,1),...		% polygon area
			poly_reg(ireg,1).Vertices(:,2));
		x		= [xC;xv(TFin)];		% der letzte Punkt ist doppelt
		y		= [yC;yv(TFin)];

		% Triangulation:
		DT		= delaunayTriangulation(x,y,C);

		% Delete points:
		P12	= DT.Points(DT.ConnectivityList(:,1),:)+...
			(DT.Points(DT.ConnectivityList(:,2),:)-DT.Points(DT.ConnectivityList(:,1),:))/2;
		P23	= DT.Points(DT.ConnectivityList(:,2),:)+...
			(DT.Points(DT.ConnectivityList(:,3),:)-DT.Points(DT.ConnectivityList(:,2),:))/2;
		P31	= DT.Points(DT.ConnectivityList(:,3),:)+...
			(DT.Points(DT.ConnectivityList(:,1),:)-DT.Points(DT.ConnectivityList(:,3),:))/2;
		% Delete edges that are outside poly_reg(ireg,1) (also edges inside holes will be deleted):
		% CLrows_delete	= ~(...
		% 	isinterior(poly_reg(ireg,1),P12)&...
		% 	isinterior(poly_reg(ireg,1),P23)&...
		% 	isinterior(poly_reg(ireg,1),P31)    );
		TFin_P12	= inpolygon(...						% faster than isinterior
			P12(:,1),...									% query points
			P12(:,2),...
			poly_reg(ireg,1).Vertices(:,1),...		% polygon area
			poly_reg(ireg,1).Vertices(:,2));
		TFin_P23	= inpolygon(...						% faster than isinterior
			P23(:,1),...									% query points
			P23(:,2),...
			poly_reg(ireg,1).Vertices(:,1),...		% polygon area
			poly_reg(ireg,1).Vertices(:,2));
		TFin_P31	= inpolygon(...						% faster than isinterior
			P31(:,1),...									% query points
			P31(:,2),...
			poly_reg(ireg,1).Vertices(:,1),...		% polygon area
			poly_reg(ireg,1).Vertices(:,2));
		CLrows_delete	= ~(...
			TFin_P12&...
			TFin_P23&...
			TFin_P31);
		if nargin==5
			% Delete edges and points that are outside poly_limit:
			% CLrows_delete	= CLrows_delete | ~(...
			% 	isinterior(poly_limit,P12)&...
			% 	isinterior(poly_limit,P23)&...
			% 	isinterior(poly_limit,P31)&...
			% 	isinterior(poly_limit,DT.Points(DT.ConnectivityList(:,1),:))&...
			%	isinterior(poly_limit,DT.Points(DT.ConnectivityList(:,2),:))&...
			% 	isinterior(poly_limit,DT.Points(DT.ConnectivityList(:,3),:))    );
			TFin_P12	= inpolygon(...								% faster than isinterior
				P12(:,1),...											% query points
				P12(:,2),...
				poly_limit.Vertices(:,1),...						% polygon area
				poly_limit.Vertices(:,2));
			TFin_P23	= inpolygon(...								% faster than isinterior
				P23(:,1),...											% query points
				P23(:,2),...
				poly_limit.Vertices(:,1),...						% polygon area
				poly_limit.Vertices(:,2));
			TFin_P31	= inpolygon(...								% faster than isinterior
				P31(:,1),...											% query points
				P31(:,2),...
				poly_limit.Vertices(:,1),...						% polygon area
				poly_limit.Vertices(:,2));
			TFin_DTP1	= inpolygon(...							% faster than isinterior
				DT.Points(DT.ConnectivityList(:,1),1),...		% query points
				DT.Points(DT.ConnectivityList(:,1),2),...
				poly_limit.Vertices(:,1),...						% polygon area
				poly_limit.Vertices(:,2));
			TFin_DTP2	= inpolygon(...							% faster than isinterior
				DT.Points(DT.ConnectivityList(:,2),1),...		% query points
				DT.Points(DT.ConnectivityList(:,2),2),...
				poly_limit.Vertices(:,1),...						% polygon area
				poly_limit.Vertices(:,2));
			TFin_DTP3	= inpolygon(...							% faster than isinterior
				DT.Points(DT.ConnectivityList(:,3),1),...		% query points
				DT.Points(DT.ConnectivityList(:,3),2),...
				poly_limit.Vertices(:,1),...						% polygon area
				poly_limit.Vertices(:,2));
			CLrows_delete	= CLrows_delete | ~(...
				TFin_P12 &...
				TFin_P23 &...
				TFin_P31 &...
				TFin_DTP1&...
				TFin_DTP2&...
				TFin_DTP3    );
		end
		CL							= DT.ConnectivityList;
		CL(CLrows_delete,:)	= [];

		% Add z-data:
		P							= [DT.Points griddata(...
			xm,...						% coordinates of the sample points
			ym,...						% coordinates of the sample points
			zm,...						% values at each sample point
			DT.Points(:,1),...		% query points
			DT.Points(:,2),...		% query points
			'linear')];					% 'linear', 'nearest', 'natural', 'cubic', 'v4'
		P(isnan(P(:,3)),3)	= 0;

		% Add triangulation data to T:
		T.CL	= [T.CL;CL+size(T.P,1)];
		T.P	= [T.P ;P ];

	end

	% Make T a valid triangulation object:
	if GV.warnings_off
		warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
	end
	T	= triangulation(T.CL,T.P);
	if GV.warnings_off
		warning('on','MATLAB:triangulation:PtsNotInTriWarnId');
	end

catch ME
	errormessage('',ME);
end

