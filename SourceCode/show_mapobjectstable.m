function show_mapobjectstable(par)
% Sets the visibility of the map objects table.
% par='toggle'		Toggle the visibility of the map objects table (after selecting the menu item).
% par='update'		Udate the visibility of the map objects table (after load project).

global APP GV_H MAP_OBJECTS_TABLE

try

	if    ( APP.ShowMapObjectsTable_Menu.Checked&&strcmp(par,'toggle'))||...
			(~APP.ShowMapObjectsTable_Menu.Checked&&strcmp(par,'update'))
		% Hide the map objects table:
		APP.ShowMapObjectsTable_Menu.Checked	= 'off';
		% Clear MAP_OBJECTS_TABLE:
		MAP_OBJECTS_TABLE									= [];
		GV_H.map_objects_table.Data					= MAP_OBJECTS_TABLE;
	else
		% Diplay the map objects table:
		APP.ShowMapObjectsTable_Menu.Checked	= 'on';
		% Update MAP_OBJECTS_TABLE:
		display_map_objects;
	end
	% Set the size of the window depending on whether the map objects table is displayed:
	set_maplab3d_figuresize;

catch ME
	errormessage('',ME);
end

