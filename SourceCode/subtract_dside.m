function [poly1,poly2,dbuffer]=subtract_dside(PP_local,colno1,colno2,poly1,poly2)
% Cut polygon object 1 by polygon object 2 taking into account the parameter PP_local.colorspec.d_side
% (Horizontal distance between the sides of this color and neighboring parts)
% Syntax:
% 1)	[poly1,poly2,~]=subtract_dside(PP_local,colno1,colno2,poly1,poly2)
%				poly1	= poly1-(poly2 increased by dbuffer)
%				poly2	= poly2-(poly1 increased by dbuffer)
% 2)	[~,~,dbuffer]=subtract_dside(PP_local,colno1,colno2)
%				returns only dbuffer

global GV

% d_side: horizontal distance between the sides of neighboring parts:
method_1	= 3;
switch method_1
	case 1
		% was used in plotosmdata_simplify.m:
		% With this method, areas may still overlap slightly.
		% d_side must be determined depending on the color priority of the two parts involved.
		% The part with the higher color priority cuts a hole in the part with the lower color priority.
		if colno1>0
			colprio1	= PP_local.color(colno1,1).prio;
			colprio2	= PP_local.color(colno2,1).prio;
			if colprio1>colprio2
				icolspec	= PP_local.color(colno1).spec;
			else
				icolspec	= PP_local.color(colno2).spec;
			end
			d_side		= PP_local.colorspec(icolspec).d_side;
		else
			% No distinction should be made here as to which objects the objects with colno1=0 lie over:
			d_side		= max([PP_local.colorspec(:).d_side]);
		end
	case 2
		% was used in map2stl_preparation.m:
		% With this method, the gaps may be unnecessarily wide.
		% Use the maximum value d_side of the two colors involved:
		icolspec1	= PP_local.color(colno1).spec;
		icolspec2	= PP_local.color(colno2).spec;
		d_side		= max(...
			PP_local.colorspec(icolspec1).d_side,...
			PP_local.colorspec(icolspec2).d_side);
	case 3
		% In map2stl_topside_triangulation.m, obj_bot_bh.poly(iobj) is calculated with d_side of the respective color.
		% These areas are then subtracted from each other  ==>  Always use d_side of the subtrahend (poly2):
		if colno2>0
			icolspec2	= PP_local.color(colno2).spec;
			d_side		= PP_local.colorspec(icolspec2).d_side;
		else
			% No distinction should be made here as to which objects the objects with colno1=0 lie over:
			d_side		= max([PP_local.colorspec(:).d_side]);
		end
end

% Objects buffered by the horizontal distance between neighboring parts:
% +2*GV.tol_1: so that no overlap is detected when calculating z_bot in map2stl.m:
% +GV.plotosmdata_simplify.dmin_changeresolution*1.01:
% the outline is changed when reducing the resolution (see below)
method_2	= 1;
switch method_2
	case 1
		% was used in plotosmdata_simplify.m:
		dbuffer			= d_side     +2*GV.tol_1+GV.plotosmdata_simplify.dmin_changeresolution*1.01;
	case 2
		% was used in map2stl_preparation.m:
		dbuffer			= d_side*1.01+2*GV.tol_1+GV.plotosmdata_simplify.dmin_changeresolution*1.01;
end
if nargin==3
	poly1		= polyshape();
	poly2		= polyshape();
	return
end

% Cut object 1 by object 2:
if strcmp(GV.jointtype_bh,'miter')
	poly2_buff	= polybuffer(poly2,dbuffer,'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
else
	poly2_buff	= polybuffer(poly2,dbuffer,'JointType',GV.jointtype_bh);
end
poly1			= subtract(poly1,poly2_buff,'KeepCollinearPoints',false);

% Cut object 2 by the already cut object 1:
% (should not be necessary, but needed in some special cases)
if strcmp(GV.jointtype_bh,'miter')
	poly1_buff	= polybuffer(poly1,dbuffer,'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
else
	poly1_buff	= polybuffer(poly1,dbuffer,'JointType',GV.jointtype_bh);
end
poly2			= subtract(poly2,poly1_buff,'KeepCollinearPoints',false);





