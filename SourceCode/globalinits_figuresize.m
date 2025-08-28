function globalinits_figuresize
% Positions of the figure and figure children: preparation to hide the map objects table:

global APP GV_H

try

	% Initializations:
	hc								= APP.MapLab3D.Children;
	h_mot							= APP.MAP_OBJECTS_TABLE.Position(4);
	GV_H.maplab3d.figure		= [];
	GV_H.maplab3d.children	= [];

	% Figure:
	GV_H.maplab3d.figure.object				= APP.MapLab3D;
	GV_H.maplab3d.figure.mot_on.pos0			= GV_H.maplab3d.figure.object.Position;
	GV_H.maplab3d.figure.mot_off.pos0		= GV_H.maplab3d.figure.object.Position;
	GV_H.maplab3d.figure.mot_off.pos0(2)	= GV_H.maplab3d.figure.object.Position(2)+h_mot;
	GV_H.maplab3d.figure.mot_off.pos0(4)	= GV_H.maplab3d.figure.object.Position(4)-h_mot;

	% Figure children:
	ic			= 0;
	for i=1:length(hc)
		if isprop(hc(i),'Position')
			if length(hc(i).Position)==4
				% hc(i) is not a uimenu:
				ic															= ic+1;
				GV_H.maplab3d.children(ic,1).object				= hc(i);
				GV_H.maplab3d.children(ic,1).mot_on.pos0		= GV_H.maplab3d.children(ic,1).object.Position;
				GV_H.maplab3d.children(ic,1).mot_on.vis		= 'on';
				GV_H.maplab3d.children(ic,1).mot_off.vis		= 'on';
				% Detect the tab group:
				hc_i_istabgroup		= false;
				if isprop(GV_H.maplab3d.children(ic,1).object,'Type')
					if strcmp(GV_H.maplab3d.children(ic,1).object.Type,'uitabgroup')
						hc_i_istabgroup		= true;
					end
				end
				if hc_i_istabgroup
					% Tab group: change the height:
					GV_H.maplab3d.children(ic,1).mot_off.pos0		= GV_H.maplab3d.children(ic,1).object.Position;
					GV_H.maplab3d.children(ic,1).mot_off.pos0(4)	= GV_H.maplab3d.children(ic,1).object.Position(4)-h_mot;
					GV_H.maplab3d.children(ic,1).ipos				= [1 2 3 4];
				else
					% All the other objects: change the bottom position:
					GV_H.maplab3d.children(ic,1).mot_off.pos0		= GV_H.maplab3d.children(ic,1).object.Position;
					GV_H.maplab3d.children(ic,1).mot_off.pos0(2)	= GV_H.maplab3d.children(ic,1).object.Position(2)-h_mot;
					GV_H.maplab3d.children(ic,1).ipos				= [1 2 3 4];
				end
			end
		end
	end

	% MAP_OBJECTS_TABLE:
	ic															= ic+1;
	GV_H.maplab3d.children(ic,1).object				= APP.MAP_OBJECTS_TABLE;
	GV_H.maplab3d.children(ic,1).mot_on.pos0		= GV_H.maplab3d.children(ic,1).object.Position;
	GV_H.maplab3d.children(ic,1).mot_off.pos0		= GV_H.maplab3d.children(ic,1).object.Position;
	GV_H.maplab3d.children(ic,1).ipos				= [1 2 3 4];
	GV_H.maplab3d.children(ic,1).mot_on.vis		= 'on';
	GV_H.maplab3d.children(ic,1).mot_off.vis		= 'off';

	% Ohter objects inside the TabGroup
	fn		= {...
		'TabGroup2';...
		'MapViewLabel';...
		'MapView_In_Button';...
		'MapView_Out_Button';...
		'MapView_UnDo_Button';...
		'MapView_Fit_Button';...
		'MapView_All_Button';...
		'MapView_Sel_Button';...
		'MapView_ReDo_Button';...
		'MapView_U1_Button';...
		'MapView_D1_Button';...
		'MapView_L1_Button';...
		'MapView_R1_Button';...
		'MapView_U2_Button';...
		'MapView_D2_Button';...
		'MapView_L2_Button';...
		'MapView_R2_Button';...
		'MapView_U3_Button';...
		'MapView_D3_Button';...
		'MapView_L3_Button';...
		'MapView_R3_Button';...
		'Mod_Vis_Label';...
		'Mod_Show_Button';...
		'Mod_Hide_Button';...
		'Mod_GrayOut_Button';...
		'Mod_DelObj_Button'};
	for ifn=1:size(fn,1)
		ic															= ic+1;
		GV_H.maplab3d.children(ic,1).object				= APP.(fn{ifn,1});
		GV_H.maplab3d.children(ic,1).mot_on.pos0		= GV_H.maplab3d.children(ic,1).object.Position;
		GV_H.maplab3d.children(ic,1).mot_off.pos0		= GV_H.maplab3d.children(ic,1).object.Position;
		GV_H.maplab3d.children(ic,1).mot_off.pos0(2)	= GV_H.maplab3d.children(ic,1).object.Position(2)-h_mot;
		GV_H.maplab3d.children(ic,1).ipos				= [1 2 3 4];
		GV_H.maplab3d.children(ic,1).mot_on.vis		= 'on';
		GV_H.maplab3d.children(ic,1).mot_off.vis		= 'on';
	end

	% At startup the map objects table is visible by default:
	GV_H.maplab3d.mapobjectstable_ison				= true;
	APP.ShowMapObjectsTable_Menu.Checked			= 'on';

catch ME
	errormessage('',ME);
end

