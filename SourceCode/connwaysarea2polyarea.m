function [poly_area,...
	poly_arsy,...
	ud_area,...
	ud_arsy,...
	replaceplots_area,...
	connways_obj]=...
	connwaysarea2polyarea(...
	iobj,...
	connways_obj,...
	msg,...
	simplify_moveoutline,...
	testplot,...
	replaceplots_area,...
	oeqt,...
	ioeqt)
% Convert the area vectors in connways to formattad area polygons.
% To simplify the areas as when creating the map, the command plotosmdata_simplify_moveoutline with
% type='area_after_union' must be executed afterwards.
% Called in:	plotosmdata_plotdata_li_ar					create the map area polygons
%					getdata_refpoints/connways_center		If	placing_on_regions=1 the number of regions depends
%																		on the type of simplification.

global PP GV GV_H WAITBAR

try
	
	% Initializations:
	if nargin==2
		msg							= '';		% msg='': Do not update the waitbar.
		simplify_moveoutline		= 1;
		testplot						= 0;		% 0
		replaceplots_area			= 0;
		oeqt							= [];
		ioeqt							= [];
	end
	poly_area		= polyshape();
	poly_arsy		= polyshape();
	ud_area			= [];
	ud_arsy			= [];
	% Indices in OSMDATA:
	in_all			= zeros(0,1);
	iw_all			= zeros(0,1);
	ir_all			= zeros(0,1);
	
	% Downsampling:
	dmax				= [];
	nmin				= [];
	dmin_areas		= PP.obj(iobj).reduce_areas.dmin;
	
	% First create the area polygon of relations, then unite them.
	% So the holes remain holes, but when two relations overlap (for example the relation leisure=stadium
	% overlaps a relation amenity=university) the inner relation will not become a hole.
	k_waitbar		= 0;
	relid_v			= unique(connways_obj.areas_relid);		% numbers of all relations of all areas
	% Because the same areas can occur both in relations and as individual ways, the relations should first be created
	% with addboundary and then the rest with union:
	relid_v			= sort(relid_v,'descend');
	for i_relid_v=1:size(relid_v,1)
		relid				= relid_v(i_relid_v,1);
		poly_rel			= polyshape();
		% Add all areas to the current relation poly_rel:
		k_v_log			= (connways_obj.areas_relid==relid);
		% Sort the areas with the current relation ID
		% so that areas with role~='inner' are added first (with relid=0 using union, with relid>0 using addboundary).
		% so that areas with role ='inner' are added last (always with addboundary).
		weight							= zeros(size(k_v_log,1),1);
		k_v_log_isouter				= k_v_log&(connways_obj.areas_isouter==1);
		k_v_log_isinner				= k_v_log&(connways_obj.areas_isinner==1);
		weight(k_v_log_isouter,:)	= -1;
		weight(k_v_log_isinner,:)	= 1;
		weight(~k_v_log,:)			= 9999;
		[weight_sort,k_v]				= sort(weight);
		k_v(weight_sort==9999,:)	= [];
		for i_k_v=1:size(k_v,1)
			k					= k_v(i_k_v,1);
			% Waitbar:
			if ~isempty(msg)
				k_waitbar	= k_waitbar+1;
				if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
					if ~isempty(msg)
						WAITBAR.t1	= clock;
						set(GV_H.text_waitbar,'String',...
							sprintf('%s Create areas: %s %g/%g',msg,...
							oeqt(ioeqt,1).tag,k_waitbar,size(connways_obj.areas,1)));
						drawnow;
					end
				end
			end
			% Collect the indices in OSMDATA:
			iw_all	= unique([iw_all;connways_obj.areas(k,1).iw_v(:)]);
			ir_all	= unique([ir_all;connways_obj.areas(k,1).ir(:)]);
			% Area:
			x	= connways_obj.areas(k,1).xy(:,1);
			y	= connways_obj.areas(k,1).xy(:,2);
			% Delete duplicate points:
			kxy_v		= 1:(length(x)-1);
			i		= (...
				(abs(x(kxy_v)-x(kxy_v+1))<GV.tol_1) & ...
				(abs(y(kxy_v)-y(kxy_v+1))<GV.tol_1)       );
			x(i)	= [];
			y(i)	= [];
			% Add the current area to poly_rel:
			if length(x)>=3
				if GV.warnings_off
					warning('off','MATLAB:polyshape:boundary3Points');
					warning('off','MATLAB:polyshape:repairedBySimplify');
				end
				poly_area_k			= polyshape(x,y);
				% Simplify objects and delete or connect small objects by moving the outlines of areas:
				if (simplify_moveoutline~=0)&&(relid==uint32(0))
					% No relation: move outline of each individual area:
					[poly_area_k,replaceplots_area]	= plotosmdata_simplify_moveoutline(...
						iobj,...										% ObjColNo
						poly_area_k,...							% poly
						'area_before_union',...					% type
						testplot,...								% testplot
						replaceplots_area);						% replaceplots
				end
				if (relid>uint32(0))||(connways_obj.areas_isinner(k,1)==1)
					% relid>0: the current area belongs to a relation or the role is 'inner': use "addboundary":
					poly_rel	= addboundary(poly_rel,poly_area_k.Vertices,'Simplify',true,'KeepCollinearPoints',false);
				else
					% relid=0: the current area does not belong to a relation: use "union":
					poly_rel	= union(poly_rel,poly_area_k,'KeepCollinearPoints',false);
				end
				if GV.warnings_off
					warning('on','MATLAB:polyshape:boundary3Points');
					warning('on','MATLAB:polyshape:repairedBySimplify');
				end
			end
		end
		% Simplify objects and delete or connect small objects by moving the outlines of areas:
		if (simplify_moveoutline~=0)&&(relid>uint32(0))
			% Relation: move the outline of the whole relation:
			[poly_rel,replaceplots_area]	= plotosmdata_simplify_moveoutline(...
				iobj,...										% ObjColNo
				poly_rel,...								% poly
				'area_before_union',...					% type
				testplot,...								% testplot
				replaceplots_area);						% replaceplots
		end
		% Create the formatted area polygons:
		obj_purpose		= {'map object'};		% cell array: information about the usage of the object
		[poly_area_i,poly_arsy_i,ud_area_i,ud_arsy_i]	= area2poly(...
			poly_rel,...							% polyin
			PP.obj(iobj).areapar,...			% par
			PP.obj(iobj).areastyle,...			% style
			iobj,...									% iobj
			obj_purpose,...						% obj_purpose
			in_all,...								% in
			iw_all,...								% iw
			ir_all);									% ir
		% Add the current relation to poly_area and poly_arsy:
		if GV.warnings_off
			warning('off','MATLAB:polyshape:repairedBySimplify');
		end
		if numboundaries(poly_area_i)>0
			poly_area_i	= changeresolution_poly(poly_area_i,dmax,dmin_areas,nmin);
			poly_area	= union(poly_area,poly_area_i,'KeepCollinearPoints',false);
			ud_area		= ud_area_i;
		end
		if numboundaries(poly_arsy_i)>0
			poly_arsy_i	= changeresolution_poly(poly_arsy_i,dmax,dmin_areas,nmin);
			poly_arsy	= union(poly_arsy,poly_arsy_i,'KeepCollinearPoints',false);
			ud_arsy		= ud_arsy_i;
		end
		if GV.warnings_off
			warning('on','MATLAB:polyshape:repairedBySimplify');
		end
	end
	
catch ME
	errormessage('',ME);
end


