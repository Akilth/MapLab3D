function [poly_legbgd,poly_legbgd_extension]=get_poly_legbgd_extended(poly_legbgd,pp)
% Gets the legend background as polygon object.
% Needed when cutting objects or calculation of the height.
% The legend background is extended to the edge of the map, so the distance between objects and printout limits
% has the same height as the legend GV.legend_z_topside_bgd.
% This works only properly, if the legend background is square.
% poly_legbgd:					extended legend background
% poly_legbgd_extension:	extension area:
%									space between GV_H.poly_map_printout_obj_limits and GV_H.poly_map_printout

global GV GV_H

try

	% Initializations:
	poly_legbgd_extension	= polyshape();

	if nargin==0
		global PP
		pp						= PP;
		[poly_legbgd,~,~]	= get_poly_legbgd;
		hf						= figure(34872364);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha						= axes;
		hold(ha,'on');
		plot(ha,poly_legbgd);
		axis(ha,'equal');
		testplot				= true;
	else
		testplot				= false;
	end

	if numboundaries(poly_legbgd)>0
		% Expand the legend background to the edge of the map:
		if size(poly_legbgd.Vertices,1)==4
			% Legend background is 	square:
			% When extending the side lines of the legend background by 2*pp.general.dist_obj_printout:
			% If the new vertex is outside of GV_H.poly_map_printout: accept the new vertex
			c			= poly_legbgd.Vertices(:,1)+1i*poly_legbgd.Vertices(:,2);
			c_new		= c;
			imax		= size(c,1);
			for i=1:imax
				if testplot
					text(ha,ha,real(c(i,1)),imag(c(i,1)),sprintf('%g',i));
				end
				ip1		= vindexrest(i+1,imax);
				dc			= 2*pp.general.dist_obj_printout*exp(1i*angle(c(ip1,1)-c(i,1)));
				% Forward:
				ctest		= c(ip1,1)+dc;
				xtest		= real(ctest);
				ytest		= imag(ctest);
				% if ~isinterior(GV_H.poly_map_printout.Shape,xtest,ytest)
				if ~inpolygon(...														% faster than isinterior
						xtest,...														% query points
						ytest,...
						GV_H.poly_map_printout.Shape.Vertices(:,1),...		% polygon area
						GV_H.poly_map_printout.Shape.Vertices(:,2))
					c_new(ip1,1)	= c_new(ip1,1)+dc;
				end
				% Backward:
				ctest		= c(i,1)-dc;
				xtest		= real(ctest);
				ytest		= imag(ctest);
				% if ~isinterior(GV_H.poly_map_printout.Shape,xtest,ytest)
				if ~inpolygon(...														% faster than isinterior
						xtest,...														% query points
						ytest,...
						GV_H.poly_map_printout.Shape.Vertices(:,1),...		% polygon area
						GV_H.poly_map_printout.Shape.Vertices(:,2))
					c_new(i,1)	= c_new(i,1)-dc;
				end
			end
			poly_legbgd							= polyshape(real(c_new),imag(c_new));
			poly_legbgd_extension			= addboundary(...
				GV_H.poly_map_printout.Shape,...
				GV_H.poly_map_printout_obj_limits.Shape.Vertices,...
				'KeepCollinearPoints',false);
			poly_legbgd_extension			= intersect(poly_legbgd_extension,poly_legbgd,...
				'KeepCollinearPoints',false);
		else
			% The legend background or the map printout limits are not rectangular:
			% This method leads to small errors at the corners of the legend background, not recommended.
			poly_map_printout_obj_limits	= polybuffer(GV_H.poly_map_printout_obj_limits.Shape,-GV.tol_1,...
				'JointType','miter','MiterLimit',2);
			poly_map_printout					= polybuffer(GV_H.poly_map_printout.Shape,GV.tol_1,...
				'JointType','miter','MiterLimit',2);
			poly_map_printout_obj_limits	= addboundary(poly_map_printout_obj_limits,poly_map_printout.Vertices,...
				'KeepCollinearPoints',false);
			poly_legbgd_buff					= polybuffer(poly_legbgd,pp.general.dist_obj_printout+GV.tol_1,...
				'JointType','miter','MiterLimit',2);
			poly_legbgd_buff					= intersect(poly_legbgd_buff,poly_map_printout_obj_limits,...
				'KeepCollinearPoints',false);
			poly_legbgd							= union(poly_legbgd,poly_legbgd_buff,...
				'KeepCollinearPoints',false);
		end
	end

	if testplot
		plot(ha,poly_legbgd,'EdgeColor','r','FaceAlpha',0);
		plot(ha,GV_H.poly_map_printout_obj_limits.Shape,'EdgeColor','c','FaceAlpha',0);
		plot(ha,GV_H.poly_map_printout.Shape,'EdgeColor','m','FaceAlpha',0);
		plot(ha,poly_legbgd_extension,'EdgeColor','b','FaceAlpha',0.2);
	end

catch ME
	errormessage('',ME);
end

