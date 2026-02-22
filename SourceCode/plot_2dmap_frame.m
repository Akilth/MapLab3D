function plot_2dmap_frame
% Plots the frame into the 2D-map.
% Must be executed when creating or changing the printout shape.

global GV GV_H PP

try

	if isempty(PP)
		return
	end

	if PP.frame.framestyle==0
		% Delete an existing frame:
		if isfield(GV_H,'poly_frame')
			delete(GV_H.poly_frame);
			GV_H	= rmfield(GV_H,'poly_frame');
		end
		return
	end

	if strcmp(GV.jointtype_frame,'miter')
		poly_frame_inner		= polybuffer(GV_H.poly_map_printout.Shape,PP.frame.d1,...
			'JointType',GV.jointtype_frame,'MiterLimit',GV.miterlimit_frame);
		poly_frame				= polybuffer(GV_H.poly_map_printout.Shape,PP.frame.b2,...
			'JointType',GV.jointtype_frame,'MiterLimit',GV.miterlimit_frame);
	else
		poly_frame_inner		= polybuffer(GV_H.poly_map_printout.Shape,PP.frame.d1,...
			'JointType',GV.jointtype_frame);
		poly_frame				= polybuffer(GV_H.poly_map_printout.Shape,PP.frame.b2,...
			'JointType',GV.jointtype_frame);
	end
	poly_frame = addboundary(poly_frame,poly_frame_inner.Vertices,...
		'KeepCollinearPoints',false);

	colno			= PP.frame.color_no;
	color_rgb	= PP.color(colno).rgb/255;
	color_rgb	= color_rgb_improve(PP,color_rgb);

	% tile_no = -3: Frame:
	if isfield(GV_H,'poly_frame')
		delete(GV_H.poly_frame);
	end
	ud_tile.tile_no			= -3;
	GV_H.poly_frame	= plot(GV_H.ax_2dmap,poly_frame,...
		'EdgeColor'    ,'k',...
		'FaceColor'    ,color_rgb,...
		'UserData'     ,ud_tile,...
		'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd,...
		'PickableParts','none',...
		'HitTest','off');

catch ME
	errormessage('',ME);
end

