function set_maplab3d_figuresize
% Set the size of the window depending on whether the map objects table is displayed:

global GV_H APP

try

	if ~APP.ShowMapObjectsTable_Menu.Checked&&strcmp(APP.TabGroup.SelectedTab.Title,'Edit map')
		% Hide the map objects table:
		if	GV_H.maplab3d.mapobjectstable_ison
			% The map objects table is not hidden:
			for ic=1:size(GV_H.maplab3d.children,1)
				pos	= GV_H.maplab3d.children(ic,1).mot_off.pos0;
				vis	= GV_H.maplab3d.children(ic,1).mot_off.vis;
				ipos	= GV_H.maplab3d.children(ic,1).ipos;
				GV_H.maplab3d.children(ic,1).object.Position(ipos)		= pos(ipos);
				GV_H.maplab3d.children(ic,1).object.Visible				= vis;
			end
			% GV_H.maplab3d.figure.object = APP.MapLab3D !
			t_fig		= GV_H.maplab3d.figure.object.Position(2)+GV_H.maplab3d.figure.object.Position(4);	% top position
			% The order is important: first height, then bottom:
			GV_H.maplab3d.figure.object.Position(4)						= GV_H.maplab3d.figure.mot_off.pos0(4);
			GV_H.maplab3d.figure.object.Position(2)						= t_fig-GV_H.maplab3d.figure.mot_off.pos0(4);
			GV_H.maplab3d.mapobjectstable_ison								= false;
			drawnow;
		end
	else
		% Make the map objects table visible:
		if	~GV_H.maplab3d.mapobjectstable_ison
			% The map objects table is not visible:
			% GV_H.maplab3d.figure.object = APP.MapLab3D !
			t_fig		= GV_H.maplab3d.figure.object.Position(2)+GV_H.maplab3d.figure.object.Position(4);	 % top position
			% The order is important: first bottom, then height:
			GV_H.maplab3d.figure.object.Position(2)						= t_fig-GV_H.maplab3d.figure.mot_on.pos0(4);
			GV_H.maplab3d.figure.object.Position(4)						= GV_H.maplab3d.figure.mot_on.pos0(4);
			for ic=1:size(GV_H.maplab3d.children,1)
				pos	= GV_H.maplab3d.children(ic,1).mot_on.pos0;
				vis	= GV_H.maplab3d.children(ic,1).mot_on.vis;
				ipos	= GV_H.maplab3d.children(ic,1).ipos;
				GV_H.maplab3d.children(ic,1).object.Visible				= vis;
				GV_H.maplab3d.children(ic,1).object.Position(ipos)		= pos(ipos);
			end
			GV_H.maplab3d.mapobjectstable_ison								= true;
			drawnow;
		end
	end

catch ME
	errormessage('',ME);
end

