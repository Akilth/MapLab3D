function zq=...				% elevation z at the query points
	interp_ele(...
	xq,...						% query points x
	yq,...						% query points y
	ele,...						% elevation structure
	colno,...					% color numbers
	z_topside_legbgd,...		% legend background z-value
	poly_legbgd,...			% legend background polygon
	method,...					% interpolation method
	use_scint)					% use scatteredInterpolant objects
% Interpolation of the elevation data
% zq						elevation at the query points
% xq, yq					query points (scalars, vectors, matrices)
% ele						elevation structure:
%							ele.elecolor(colno,1).ifs								index of the filter settings
%							ele.elecolor(colno,1).colprio							color priority
%							ele.elecolor(ifs,1).elepoly(ip,1).eleshape		area within which the filter settings apply
%							ele.elecolor(ifs,1).elepoly(ip,1).elescint		-	scatteredInterpolant: elevation for the
%																															 given polygon area
%																							-	[]:
%																								Uses the sample poionts xm_mm, ym_mm, zm_mm.
%							ele.elefiltset(ifs,1).xm_mm							sample points
%							ele.elefiltset(ifs,1).ym_mm
%							ele.elefiltset(ifs,1).zm_mm
% colno					color numbers
%							[] or 1					use the tile base elevation data: ele.elefiltset(1,1)
%							scalar or vector		First, the indices ifs are determined for all specified color numbers.
%														-	If sample points lie within a polygon
%															ele.elecolor(colno,1).elepoly(ip,1).eleshape,
%															the elevation data of this polygon is used.
%															The calculation method depends on
%															ele.elecolor(colno,1).elepoly(ip,1).elescint:
%															-	empty:		Use the filtered data:	      ele.elefiltset(ifs,1). ..
%															-	not empty:	Use the scatteredInterpolant:	.. .elescint
%														-	Otherwise the elevation data of the tile base (ifs=1) is used.
% z_topside_legbgd	legend background z-value
% poly_legbgd			legend background polygon
% method					interpolation method: 'interp2', 'griddata'
% use_scint 			Use scatteredInterpolant objects:
%							true		Use  ele.elecolor(colno,1).elepoly(ip,1).elescint if not empty (default)
%							false		Skip ele.elecolor(colno,1).elepoly(ip,1).elescint
%										Necessary to calculate the minimum z-value of the terrain for such objects.

% global:
% Do not use global variables here, because interp_ele is called with different elevation and project parameters!

try
	
	% Initializations:
	if nargin<8
		use_scint		= true;			% use scatteredInterpolant objects
	end
	
	% Convert the query points to column vectors:
	size_xq		= size(xq);
	xq				= reshape(xq,[size_xq(1)*size_xq(2) 1]);
	yq				= reshape(yq,[size_xq(1)*size_xq(2) 1]);
	i_isnan_xq	= isnan(xq);
	
	% Indices ifs of the filter settings:
	if isempty(colno)
		% Use elevation data with tile base filter settings:
		colno			= 1;
		ifs			= 1;
	else
		% Sort colno by color priority:
		% The color number 1 is always included (tile base), because the elevation data of all remaining points is
		% calculated using the tile base filter settings:
		colno					= unique([1;colno(:)]);
		colno(colno==0)	= [];									% Exclude colno=0 (should not happen)
		colprio				= [ele.elecolor(colno,1).colprio];
		colprio				= colprio(:);
		[~,i_sort]			= sort(colprio);
		colno					= colno(i_sort);
		% Indices ifs of the filter settings:
		ifs					= ones(size(colno,1),1);
		for i_colno=1:size(colno,1)
			colno_i				= colno(i_colno,1);
			ifs(i_colno,1)		= ele.elecolor(colno_i,1).ifs;
		end
	end
	
	% Check wether vertices are inside the legend bounds.
	% To consider only the first vertex of xq and yq does not work, because the tile base overlaps the area
	% inside and outside the legend background!
	xyq_inside_legend_bgd		= false(size(xq));
	if numboundaries(poly_legbgd)>0
		try
			% xyq_inside_legend_bgd	= isinterior(poly_legbgd,xq,yq);
			xyq_inside_legend_bgd	= inpolygon(...							% faster than isinterior
				xq,...																	% query points
				yq,...
				poly_legbgd.Vertices(:,1),...										% polygon area
				poly_legbgd.Vertices(:,2));
		catch ME
			% Maybe out of memory error:
			errormessage('Error when interpolating the elevation data.',ME);
		end
	end
	
	% Legend background elevation:
	zq										= zeros(size(xq));
	zq(xyq_inside_legend_bgd,:)	= z_topside_legbgd;
	
	% Interpolation inside polygons and outside the legend background:
	i_xyzq_logical						= ~xyq_inside_legend_bgd;
	for i_colno=size(colno,1):-1:1
		colno_i		= colno(i_colno,1);
		ifs_i			= ifs(i_colno,1);
		for ip=size(ele.elecolor(colno_i,1).elepoly,1):-1:1
			if numboundaries(ele.elecolor(colno_i,1).elepoly(ip,1).eleshape)>0
				xyq_inside_poly			= false(size(xq));
				xyq_inside_poly(i_xyzq_logical,:)	= inpolygon(...							% faster than isinterior
					xq(i_xyzq_logical,1),...															% query points
					yq(i_xyzq_logical,1),...
					ele.elecolor(colno_i,1).elepoly(ip,1).eleshape.Vertices(:,1),...		% polygon area
					ele.elecolor(colno_i,1).elepoly(ip,1).eleshape.Vertices(:,2));
				if ~isempty(ele.elecolor(colno_i,1).elepoly(ip,1).elescint)&&use_scint
					zq(xyq_inside_poly,:)	= ele.elecolor(colno_i,1).elepoly(ip,1).elescint(...
						xq(xyq_inside_poly,1),...
						yq(xyq_inside_poly,1));
				else
					switch method
						case 'interp2'
							zq(xyq_inside_poly,:)	= interp2(...
								ele.elefiltset(ifs_i,1).xm_mm,...									% coordinates of the sample points
								ele.elefiltset(ifs_i,1).ym_mm,...									% (matrices, vectors)
								ele.elefiltset(ifs_i,1).zm_mm,...
								xq(xyq_inside_poly,1),...												% query points
								yq(xyq_inside_poly,1));
						case 'griddata'
							size_x						= size(ele.elefiltset(ifs_i,1).xm_mm);
							size_x_reshape				= [size_x(1)*size_x(2) 1];
							zq(xyq_inside_poly,:)	= griddata(...
								reshape(ele.elefiltset(ifs_i,1).xm_mm,size_x_reshape),...	% scattered surface data (vectors)
								reshape(ele.elefiltset(ifs_i,1).ym_mm,size_x_reshape),...
								reshape(ele.elefiltset(ifs_i,1).zm_mm,size_x_reshape),...
								xq(xyq_inside_poly,1),...												% query points
								yq(xyq_inside_poly,1),...
								'linear');
					end
				end
				% In the next step, the interpolation points that have just been calculated should no longer be considered:
				i_xyzq_logical(xyq_inside_poly,:)	= false;
			end
		end
	end
	
	% Interpolation outside polygons and outside the legend background of all remaining points:
	ifs_i					= 1;																% elevation data of the tile base
	switch method
		case 'interp2'
			zq(i_xyzq_logical,:)	= interp2(...
				ele.elefiltset(ifs_i,1).xm_mm,...									% coordinates of the sample points
				ele.elefiltset(ifs_i,1).ym_mm,...									% (matrices, vectors)
				ele.elefiltset(ifs_i,1).zm_mm,...
				xq(i_xyzq_logical,1),...												% query points
				yq(i_xyzq_logical,1));
		case 'griddata'
			size_x					= size(ele.elefiltset(ifs_i,1).xm_mm);
			size_x_reshape			= [size_x(1)*size_x(2) 1];
			zq(i_xyzq_logical,:)	= griddata(...
				reshape(ele.elefiltset(ifs_i,1).xm_mm,size_x_reshape),...	% scattered surface data (vectors)
				reshape(ele.elefiltset(ifs_i,1).ym_mm,size_x_reshape),...
				reshape(ele.elefiltset(ifs_i,1).zm_mm,size_x_reshape),...
				xq(i_xyzq_logical,1),...												% query points
				yq(i_xyzq_logical,1),...
				'linear');
	end
	
	% Reshape zq:
	zq(i_isnan_xq)	= nan;
	zq					= reshape(zq,size_xq);
	
catch ME
	errormessage('',ME);
end



% old:
%
% function zq=interp_ele(xq,yq,x,y,z,z_topside_legbgd,poly_legbgd,method)
% % Interpolation of the elevation data
% % xq, yq					query points (scalars, vectors, matrices)
% % x,y,z					sample points
% % z_topside_legbgd	legend background z-value
% % poly_legbgd			legend background polygon
% % method					interpolation method: 'interp2', 'griddata'
%
% try
%
% 	% Convert to column vectors:
% 	size_xq		= size(xq);
% 	xq				= reshape(xq,[size_xq(1)*size_xq(2) 1]);
% 	yq				= reshape(yq,[size_xq(1)*size_xq(2) 1]);
% 	i_isnan_xq	= isnan(xq);
%
% 	% Check wether the vertices are inside the legend bounds.
% 	% To consider only the first vertex of xq and yq does not work, because the tile base overlaps the area
% 	% inside and outside the legend background!
% 	xyq_inside_legend_bgd		= false(size(xq));
% 	if numboundaries(poly_legbgd)>0
% 		try
% 			% xyq_inside_legend_bgd	= isinterior(poly_legbgd,xq,yq);
% 			xyq_inside_legend_bgd	= inpolygon(...							% faster than isinterior
% 				xq,...																	% query points
% 				yq,...
% 				poly_legbgd.Vertices(:,1),...										% polygon area
% 				poly_legbgd.Vertices(:,2));
% 		catch ME
% 			% Maybe out of memory error:
% 			errormessage('Error when interpolating the elevation data.',ME);
% 		end
% 	end
%
% 	% Interpolation:
% 	zq										= zeros(size(xq));
% 	zq(xyq_inside_legend_bgd,:)	= z_topside_legbgd;
% 	switch method
% 		case 'interp2'
% 			zq(~xyq_inside_legend_bgd,:)	= interp2(...
% 				x,...											% coordinates of the sample points (matrices, vectors)
% 				y,...
% 				z,...
% 				xq(~xyq_inside_legend_bgd,1),...		% query points
% 				yq(~xyq_inside_legend_bgd,1));
% 		case 'griddata'
% 			size_x						= size(x);
% 			size_x_reshape				= [size_x(1)*size_x(2) 1];
% 			zq(~xyq_inside_legend_bgd,:)	= griddata(...
% 				reshape(x,size_x_reshape),...			% scattered surface data (vectors)
% 				reshape(y,size_x_reshape),...
% 				reshape(z,size_x_reshape),...
% 				xq(~xyq_inside_legend_bgd,1),...		% query points
% 				yq(~xyq_inside_legend_bgd,1),...
% 				'linear');
% 	end
% 	zq(i_isnan_xq)	= nan;
%
% 	% Reshape z:
% 	zq					= reshape(zq,size_xq);
%
% catch ME
% 	errormessage('',ME);
% end
%
