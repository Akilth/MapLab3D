function [x0,y0]=connways_center(iobj,connways,source,area_limits)
% Calculate the center x0,y0 of connways:
% 1) [x0,y0]=connways_center(iobj,connways);					Calculate the center of the whole data in connways
% 2) [x0,y0]=connways_center(iobj,connways,'nodes');		Calculate the center of all nodes
% 3) [x0,y0]=connways_center(iobj,connways,'lines');		Calculate the center of all lines
% 4) [x0,y0]=connways_center(iobj,connways,'areas');		Calculate the center of all areas
% 5) [x0,y0]=connways_center(iobj,connways,'regions',area_limits);	Calculate the center of every single region
%																							of all areas. x0 and y0 will be vectors
%																							corresponding to every region.
% area_limits		Only necessary if source='regions'.
%						area_limits is equal to text_symb in getdata_refpoints.m
%						Assignment of the limit values in plotosmdata_simplify_moveoutline:
%						'object'					mindiag=PP.obj(iobj).reduce_areas.mindiag
%													minarea=PP.obj(iobj).reduce_areas.minarea
%						'text'					mindiag=PP.obj(iobj).textpar.mindiag
%													minarea=PP.obj(iobj).textpar.minarea
%						'symbol'					mindiag=PP.obj(iobj).symbolpar.mindiag
%													minarea=PP.obj(iobj).symbolpar.minarea
%						'change_text'			mindiag=0
%													minarea=0

global GV

try

	if nargin<3
		source	= 'all';
	end
	x0				= [];
	y0				= [];
	method		= 1;
	switch method
		case 1
			% mean value of all points in connways:
			dmin		= 0.2;		% for the calculation of the reference point: change the resolution
			dmax		= 0.2;
			nmin		= [];
			if strcmp(source,'regions')

				% Calculate the area polygon: for texts and symbols in the same way as for lines and areas:
				poly_area		= connwaysarea2polyarea(iobj,connways);
				poly_area		= changeresolution_poly(poly_area,dmax,dmin,nmin);
				% Simplify objects and delete or connect small objects by moving the outlines of areas:
				poly_area		= plotosmdata_simplify_moveoutline(...
					iobj,...										% ObjColNo
					poly_area,...								% poly
					'area_after_union',...					% type
					0,...											% testplot
					0,...											% replaceplots
					area_limits);								% area_limits

				if numboundaries(poly_area)>0
					poly_regions	= regions(poly_area);
					nr					= size(poly_regions,1);
					x0					= zeros(nr,1);
					y0					= zeros(nr,1);
					for ir=1:nr
						[x0(ir,1),y0(ir,1)]			= centroid(poly_regions(ir,1));
						TFin			= inpolygon(...					% faster than isinterior
							x0(ir,1),...									% query points
							y0(ir,1),...
							poly_regions(ir,1).Vertices(:,1),...	% polygon area
							poly_regions(ir,1).Vertices(:,2));
						if ~TFin
							% The centroid is not inside the region:
							% Region vertex pos_mindist that is nearest to the centroid:
							distance_to_center		= sqrt(...
								(poly_regions(ir,1).Vertices(:,1)-x0(ir,1)).^2+...
								(poly_regions(ir,1).Vertices(:,2)-y0(ir,1)).^2    );
							[mindist,i_mindist]		= min(distance_to_center);
							[maxdist,~]					= max(distance_to_center);
							pos_mindist(1,:)			= poly_regions(ir,1).Vertices(i_mindist,:);
							% Straight line [x1 y1] through pos_mindist and the centroid:
							x1								= [...
								x0(ir,1);...
								x0(ir,1)+(pos_mindist(1,1)-x0(ir,1))/mindist*maxdist*1.1];
							y1								= [...
								y0(ir,1);...
								y0(ir,1)+(pos_mindist(1,2)-y0(ir,1))/mindist*maxdist*1.1];
							% Intersection points between [x1 y1] and the polygon:
							[xi,yi] = polyxpoly(...
								x1,...											% x1
								y1,...											% y1
								poly_regions(ir,1).Vertices(:,1),...	% x2
								poly_regions(ir,1).Vertices(:,2));	 	% y2
							if length(xi)>=2
								% There are at least 2 intersection points between [x1 y1] and the polygon:
								% The new reference point is the center point between the 2 intersection points
								% nearest to the centroid (this should always be the case):
								distance_to_center				= sqrt(...
									(xi-x0(ir,1)).^2+...
									(yi-y0(ir,1)).^2    );
								distance_to_center				= sort(distance_to_center,'ascend');
								distance_refpoint_to_center	= mean(distance_to_center(1:2));
								refpoint								= [...
									x0(ir,1)+(pos_mindist(1,1)-x0(ir,1))/mindist*distance_refpoint_to_center ...
									y0(ir,1)+(pos_mindist(1,2)-y0(ir,1))/mindist*distance_refpoint_to_center];
								testplot=0;
								if testplot~=0
									hf=figure(476286734);
									clf(hf,'reset');
									ha=axes;
									hold(ha,'on');
									axis(ha,'equal');
									plot(ha,poly_regions(ir,1));
									plot(ha,x0(ir,1),y0(ir,1),'+r');
									plot(ha,x1,y1,'x-g');
									plot(ha,xi,yi,'+b');
									plot(ha,refpoint(1,1),refpoint(1,2),'.m');
									drawnow;
									setbreakpoint=1;
								end
								if inpolygon(...										% faster than isinterior
										refpoint(1,1),...								% query points
										refpoint(1,2),...
										poly_regions(ir,1).Vertices(:,1),...	% polygon area
										poly_regions(ir,1).Vertices(:,2))
									% The new reference point is inside the region (this should always be the case):
									x0(ir,1)		= refpoint(1,1);
									y0(ir,1)		= refpoint(1,2);
								end
							end
						end
					end
				end

			else
				n_xy		= 0;
				sum_x		= 0;
				sum_y		= 0;
				if strcmp(source,'nodes')||strcmp(source,'all')
					if ~isempty(connways.nodes)
						n_xy		= n_xy+size(connways.nodes.xy,1);
						sum_x		= sum_x+sum(connways.nodes.xy(:,1));
						sum_y		= sum_y+sum(connways.nodes.xy(:,2));
					end
				end
				if strcmp(source,'lines')||strcmp(source,'all')
					for k=1:size(connways.lines,1)
						[x,y]		= changeresolution_xy(...
							connways.lines(k,1).xy(:,1),...
							connways.lines(k,1).xy(:,2),dmax,dmin,nmin);
						n_xy		= n_xy+size(x,1);
						sum_x		= sum_x+sum(x);
						sum_y		= sum_y+sum(y);
					end
				end
				if strcmp(source,'areas')||strcmp(source,'all')
					for k=1:size(connways.areas,1)
						if    (abs(connways.areas(k,1).xy(1,1)-connways.areas(k,1).xy(end,1))<GV.tol_1)&&...
								(abs(connways.areas(k,1).xy(1,2)-connways.areas(k,1).xy(end,2))<GV.tol_1)
							% First and last point are equal:
							[x,y]		= changeresolution_xy(...
								connways.areas(k,1).xy(1:end,1),...
								connways.areas(k,1).xy(1:end,2),dmax,dmin,nmin);
						else
							% First and last point are not equal:
							[x,y]		= changeresolution_xy(...
								[connways.areas(k,1).xy(1:end,1);connways.areas(k,1).xy(1,1)],...
								[connways.areas(k,1).xy(1:end,2);connways.areas(k,1).xy(1,2)],dmax,dmin,nmin);
						end
						n_xy		= n_xy+size(x,1);
						sum_x		= sum_x+sum(x);
						sum_y		= sum_y+sum(y);
					end
				end
				x0	= sum_x/n_xy;
				y0	= sum_y/n_xy;
			end
		case 2
			% center of the areas:
			% parameter source not implemented!
			n_xy		= 0;
			sum_x		= 0;
			sum_y		= 0;
			dmin		= 0.2;								% change the resolution
			dmax		= 0.2;
			nmin		= [];
			if ~isempty(connways.areas)
				poly				= polyshape([0 2 1],[0 0 1]);
				poly.Vertices	= zeros(0,2);			% empty polygon
				if GV.warnings_off
					warning('off','MATLAB:polyshape:repairedBySimplify');
					warning('off','MATLAB:polyshape:boolOperationFailed');
				end
				for k=1:size(connways.areas,1)
					poly			= addboundary(poly,connways.areas(k,1).xy(:,1:2));
				end
				if GV.warnings_off
					warning('on','MATLAB:polyshape:repairedBySimplify');
					warning('on','MATLAB:polyshape:boolOperationFailed');
				end
				[x0,y0]			= centroid(poly);
				if isnan(x0)||isnan(y0)
					for k=1:size(connways.areas,1)
						[x,y]		= changeresolution_xy(...
							connways.areas(k,1).xy(2:end,1),...
							connways.areas(k,1).xy(2:end,2),dmax,dmin,nmin);
						n_xy		= n_xy+size(x,1)-1;
						sum_x		= sum_x+sum(x);
						sum_y		= sum_y+sum(y);
					end
					x0				= sum_x/n_xy;
					y0				= sum_y/n_xy;
				end
			elseif ~isempty(connways.lines)
				for k=1:size(connways.lines,1)
					[x,y]		= changeresolution_xy(...
						connways.lines(k,1).xy(:,1),...
						connways.lines(k,1).xy(:,2),dmax,dmin,nmin);
					n_xy		= n_xy+size(x,1);
					sum_x		= sum_x+sum(x);
					sum_y		= sum_y+sum(y);
				end
				x0				= sum_x/n_xy;
				y0				= sum_y/n_xy;
			elseif ~isempty(connways.nodes)
				n_xy			= n_xy+size(connways.nodes.xy,1);
				sum_x			= sum_x+sum(connways.nodes.xy(:,1));
				sum_y			= sum_y+sum(connways.nodes.xy(:,2));
				x0				= sum_x/n_xy;
				y0				= sum_y/n_xy;
			end
	end

catch ME
	errormessage('',ME);
end

