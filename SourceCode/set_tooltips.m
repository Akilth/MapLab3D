function set_tooltips(par)
% par='clear'							clear all tooltips
% par='set'								set tooltips
% par='init'							save tooltips at startup
% par='move_mapobject'				set tooltips of move map objects buttons
% par='rotate_mapobject'			set tooltips of rotate map objects buttons
% par='move_mapview'					set tooltips of move mapview buttons
% par='latlonxytab'					set tooltips of the "lon,lat - x,y" tab
% par='set_variable_tooltips'		set variable elements of GV.tooltips after loading a project
% par='get_all_tooltips'
% Maximum 58 characters in one line:
%   1         2         3         4         5
%  '123456789012345678901234567890123456789012345678'
%  |<----------------------------55-characters-->|

global APP GV PP

try

	p		= properties(APP);
	switch par
		case 'clear'
			% Clear all tooltips:
			for ip=1:size(p,1)
				if isprop(APP.(p{ip,1}),'Tooltip')
					APP.(p{ip,1}).Tooltip	= cell(0,1);
				end
			end
			APP.ShowTooltips_Menu.Checked	= 'off';
			APP.ShowTooltips_Menu.Tooltip	= {...
				'Tooltips are deactivated.';...
				'Click here to display assistance like this for all components.'};

		case 'set'
			% Set tooltips:
			for ip=1:size(p,1)
				if isprop(APP.(p{ip,1}),'Tooltip')
					APP.(p{ip,1}).Tooltip	= GV.tooltips.(p{ip,1});
				end
			end
			APP.ShowTooltips_Menu.Checked	= 'on';
			APP.ShowTooltips_Menu.Tooltip	= {...
				'Tooltips are activated.';...
				'Press here to switch off assistance like this for all components.'};

		case 'init'
			% Save tooltips at startup:
			for ip=1:size(p,1)
				if isprop(APP.(p{ip,1}),'Tooltip')
					GV.tooltips.(p{ip,1})	= APP.(p{ip,1}).Tooltip;
				end
			end

		case 'move_mapobject'
			% Set tooltips of move map objects buttons:
			dxy1		= APP.Mod_Move_mm_EditField.Value/GV.pp_stepwidth_move_object_factor;
			dxy2		= APP.Mod_Move_mm_EditField.Value;
			dxy3		= APP.Mod_Move_mm_EditField.Value*GV.pp_stepwidth_move_object_factor;
			GV.tooltips.Mod_Move_L1_Button	= {sprintf('Move to the left by %g mm.',dxy1)};
			GV.tooltips.Mod_Move_L2_Button	= {sprintf('Move to the left by %g mm.',dxy2)};
			GV.tooltips.Mod_Move_L3_Button	= {sprintf('Move to the left by %g mm.',dxy3)};
			GV.tooltips.Mod_Move_R1_Button	= {sprintf('Move to the right by %g mm.',dxy1)};
			GV.tooltips.Mod_Move_R2_Button	= {sprintf('Move to the right by %g mm.',dxy2)};
			GV.tooltips.Mod_Move_R3_Button	= {sprintf('Move to the right by %g mm.',dxy3)};
			GV.tooltips.Mod_Move_U1_Button	= {sprintf('Move upwards by %g mm.',dxy1)};
			GV.tooltips.Mod_Move_U2_Button	= {sprintf('Move upwards by %g mm.',dxy2)};
			GV.tooltips.Mod_Move_U3_Button	= {sprintf('Move upwards by %g mm.',dxy3)};
			GV.tooltips.Mod_Move_D1_Button	= {sprintf('Move downwards by %g mm.',dxy1)};
			GV.tooltips.Mod_Move_D2_Button	= {sprintf('Move downwards by %g mm.',dxy2)};
			GV.tooltips.Mod_Move_D3_Button	= {sprintf('Move downwards by %g mm.',dxy3)};
			GV.tooltips.Mod_Move_LU1_Button	= {sprintf('Move upwards to the left by %g mm.',dxy1)};
			GV.tooltips.Mod_Move_LU2_Button	= {sprintf('Move upwards to the left by %g mm.',dxy2)};
			GV.tooltips.Mod_Move_LU3_Button	= {sprintf('Move upwards to the left by %g mm.',dxy3)};
			GV.tooltips.Mod_Move_RU1_Button	= {sprintf('Move upwards to the right by %g mm.',dxy1)};
			GV.tooltips.Mod_Move_RU2_Button	= {sprintf('Move upwards to the right by %g mm.',dxy2)};
			GV.tooltips.Mod_Move_RU3_Button	= {sprintf('Move upwards to the right by %g mm.',dxy3)};
			GV.tooltips.Mod_Move_LD1_Button	= {sprintf('Move downwards to the left by %g mm.',dxy1)};
			GV.tooltips.Mod_Move_LD2_Button	= {sprintf('Move downwards to the left by %g mm.',dxy2)};
			GV.tooltips.Mod_Move_LD3_Button	= {sprintf('Move downwards to the left by %g mm.',dxy3)};
			GV.tooltips.Mod_Move_RD1_Button	= {sprintf('Move downwards to the right by %g mm.',dxy1)};
			GV.tooltips.Mod_Move_RD2_Button	= {sprintf('Move downwards to the right by %g mm.',dxy2)};
			GV.tooltips.Mod_Move_RD3_Button	= {sprintf('Move downwards to the right by %g mm.',dxy3)};
			if APP.ShowTooltips_Menu.Checked
				APP.Mod_Move_L1_Button.Tooltip	= GV.tooltips.Mod_Move_L1_Button;
				APP.Mod_Move_L2_Button.Tooltip	= GV.tooltips.Mod_Move_L2_Button;
				APP.Mod_Move_L3_Button.Tooltip	= GV.tooltips.Mod_Move_L3_Button;
				APP.Mod_Move_R1_Button.Tooltip	= GV.tooltips.Mod_Move_R1_Button;
				APP.Mod_Move_R2_Button.Tooltip	= GV.tooltips.Mod_Move_R2_Button;
				APP.Mod_Move_R3_Button.Tooltip	= GV.tooltips.Mod_Move_R3_Button;
				APP.Mod_Move_U1_Button.Tooltip	= GV.tooltips.Mod_Move_U1_Button;
				APP.Mod_Move_U2_Button.Tooltip	= GV.tooltips.Mod_Move_U2_Button;
				APP.Mod_Move_U3_Button.Tooltip	= GV.tooltips.Mod_Move_U3_Button;
				APP.Mod_Move_D1_Button.Tooltip	= GV.tooltips.Mod_Move_D1_Button;
				APP.Mod_Move_D2_Button.Tooltip	= GV.tooltips.Mod_Move_D2_Button;
				APP.Mod_Move_D3_Button.Tooltip	= GV.tooltips.Mod_Move_D3_Button;
				APP.Mod_Move_LU1_Button.Tooltip	= GV.tooltips.Mod_Move_LU1_Button;
				APP.Mod_Move_LU2_Button.Tooltip	= GV.tooltips.Mod_Move_LU2_Button;
				APP.Mod_Move_LU3_Button.Tooltip	= GV.tooltips.Mod_Move_LU3_Button;
				APP.Mod_Move_RU1_Button.Tooltip	= GV.tooltips.Mod_Move_RU1_Button;
				APP.Mod_Move_RU2_Button.Tooltip	= GV.tooltips.Mod_Move_RU2_Button;
				APP.Mod_Move_RU3_Button.Tooltip	= GV.tooltips.Mod_Move_RU3_Button;
				APP.Mod_Move_LD1_Button.Tooltip	= GV.tooltips.Mod_Move_LD1_Button;
				APP.Mod_Move_LD2_Button.Tooltip	= GV.tooltips.Mod_Move_LD2_Button;
				APP.Mod_Move_LD3_Button.Tooltip	= GV.tooltips.Mod_Move_LD3_Button;
				APP.Mod_Move_RD1_Button.Tooltip	= GV.tooltips.Mod_Move_RD1_Button;
				APP.Mod_Move_RD2_Button.Tooltip	= GV.tooltips.Mod_Move_RD2_Button;
				APP.Mod_Move_RD3_Button.Tooltip	= GV.tooltips.Mod_Move_RD3_Button;
			end

		case 'rotate_mapobject'
			% Set tooltips of rotate map objects buttons:
			phi1		= APP.Mod_Rot_deg_EditField.Value/GV.pp_stepwidth_rotate_object_factor;
			phi2		= APP.Mod_Rot_deg_EditField.Value;
			phi3		= APP.Mod_Rot_deg_EditField.Value*GV.pp_stepwidth_rotate_object_factor;
			GV.tooltips.Mod_Rot_L1_Button		= {sprintf('Turn to the left by %g°.',phi1)};
			GV.tooltips.Mod_Rot_L2_Button		= {sprintf('Turn to the left by %g°.',phi2)};
			GV.tooltips.Mod_Rot_L3_Button		= {sprintf('Turn to the left by %g°.',phi3)};
			GV.tooltips.Mod_Rot_R1_Button		= {sprintf('Turn to the right by %g°.',phi1)};
			GV.tooltips.Mod_Rot_R2_Button		= {sprintf('Turn to the right by %g°.',phi2)};
			GV.tooltips.Mod_Rot_R3_Button		= {sprintf('Turn to the right by %g°.',phi3)};
			if APP.ShowTooltips_Menu.Checked
				APP.Mod_Rot_L1_Button.Tooltip		= GV.tooltips.Mod_Rot_L1_Button;
				APP.Mod_Rot_L2_Button.Tooltip		= GV.tooltips.Mod_Rot_L2_Button;
				APP.Mod_Rot_L3_Button.Tooltip		= GV.tooltips.Mod_Rot_L3_Button;
				APP.Mod_Rot_R1_Button.Tooltip		= GV.tooltips.Mod_Rot_R1_Button;
				APP.Mod_Rot_R2_Button.Tooltip		= GV.tooltips.Mod_Rot_R2_Button;
				APP.Mod_Rot_R3_Button.Tooltip		= GV.tooltips.Mod_Rot_R3_Button;
			end

		case 'move_mapview'
			% Set tooltips of move mapview buttons:
			sw1		= GV.pp_stepwidth_move_mapview_small;
			sw2		= GV.pp_stepwidth_move_mapview_medium;
			sw3		= GV.pp_stepwidth_move_mapview_large;
			GV.tooltips.MapView_L1_Button		= {sprintf('Move map view to the left by %g%%.',sw1)};
			GV.tooltips.MapView_L2_Button		= {sprintf('Move map view to the left by %g%%.',sw2)};
			GV.tooltips.MapView_L3_Button		= {sprintf('Move map view to the left by %g%%.',sw3)};
			GV.tooltips.MapView_R1_Button		= {sprintf('Move map view to the right by %g%%.',sw1)};
			GV.tooltips.MapView_R2_Button		= {sprintf('Move map view to the right by %g%%.',sw2)};
			GV.tooltips.MapView_R3_Button		= {sprintf('Move map view to the right by %g%%.',sw3)};
			GV.tooltips.MapView_U1_Button		= {sprintf('Move map view upwards by %g%%.',sw1)};
			GV.tooltips.MapView_U2_Button		= {sprintf('Move map view upwards by %g%%.',sw2)};
			GV.tooltips.MapView_U3_Button		= {sprintf('Move map view upwards by %g%%.',sw3)};
			GV.tooltips.MapView_D1_Button		= {sprintf('Move map view downwards by %g%%.',sw1)};
			GV.tooltips.MapView_D2_Button		= {sprintf('Move map view downwards by %g%%.',sw2)};
			GV.tooltips.MapView_D3_Button		= {sprintf('Move map view downwards by %g%%.',sw3)};
			if APP.ShowTooltips_Menu.Checked
				APP.MapView_L1_Button.Tooltip		= GV.tooltips.MapView_L1_Button;
				APP.MapView_L2_Button.Tooltip		= GV.tooltips.MapView_L2_Button;
				APP.MapView_L3_Button.Tooltip		= GV.tooltips.MapView_L3_Button;
				APP.MapView_R1_Button.Tooltip		= GV.tooltips.MapView_R1_Button;
				APP.MapView_R2_Button.Tooltip		= GV.tooltips.MapView_R2_Button;
				APP.MapView_R3_Button.Tooltip		= GV.tooltips.MapView_R3_Button;
				APP.MapView_U1_Button.Tooltip		= GV.tooltips.MapView_U1_Button;
				APP.MapView_U2_Button.Tooltip		= GV.tooltips.MapView_U2_Button;
				APP.MapView_U3_Button.Tooltip		= GV.tooltips.MapView_U3_Button;
				APP.MapView_D1_Button.Tooltip		= GV.tooltips.MapView_D1_Button;
				APP.MapView_D2_Button.Tooltip		= GV.tooltips.MapView_D2_Button;
				APP.MapView_D3_Button.Tooltip		= GV.tooltips.MapView_D3_Button;
			end

		case 'latlonxytab'
			if ~isempty(PP)
				% Edit fields:
				label_text		= 'Project parameter at line %g:\n%s';
				GV.tooltips.LatLonXYTab_ScaleEditField							= {sprintf(label_text,PP.TABLE_ROWNO.project.scale,sprintf('Scale'))};
				GV.tooltips.LatLonXYTab_OriginLongitudeEditField			= {sprintf(label_text,PP.TABLE_ROWNO.general.origin_user_lon,sprintf('Origin longitude / degree'))};
				GV.tooltips.LatLonXYTab_OriginLatitudeEditField				= {sprintf(label_text,PP.TABLE_ROWNO.general.origin_user_lat,sprintf('Origin latitude / degree'))};
				GV.tooltips.LatLonXYTab_Dist_OSM_MapPrintout_EditField	= {sprintf(label_text,PP.TABLE_ROWNO.general.dist_osm_printout,sprintf('Distance between OSM-data and map printout limits / mm'))};
				GV.tooltips.LatLonXYTab_FrameWidth_EditField					= {sprintf(label_text,PP.TABLE_ROWNO.frame.b2,sprintf('Outer frame width / mm'))};
				GV.tooltips.LatLonXYTab_TileWidth_EditField					= {sprintf(label_text,PP.TABLE_ROWNO.general.tile_width_preset,sprintf('Tile width / mm'))};
				GV.tooltips.LatLonXYTab_TileHeight_EditField					= {sprintf(label_text,PP.TABLE_ROWNO.general.tile_depth_preset,sprintf('Tile depth / mm'))};
				GV.tooltips.LatLonXYTab_Osmosis_lonminEditField				= {sprintf(label_text,PP.TABLE_ROWNO.general.bounding_box.lonmin_degree,sprintf('Osmosis bounding box:\nLongitude of the left edge / degree'))};
				GV.tooltips.LatLonXYTab_Osmosis_lonmaxEditField				= {sprintf(label_text,PP.TABLE_ROWNO.general.bounding_box.lonmax_degree,sprintf('Osmosis bounding box:\nLongitude of the right edge / degree'))};
				GV.tooltips.LatLonXYTab_Osmosis_latminEditField				= {sprintf(label_text,PP.TABLE_ROWNO.general.bounding_box.latmin_degree,sprintf('Osmosis bounding box:\nLatitude of the bottom edge / degree'))};
				GV.tooltips.LatLonXYTab_Osmosis_latmaxEditField				= {sprintf(label_text,PP.TABLE_ROWNO.general.bounding_box.latmax_degree,sprintf('Osmosis bounding box:\nLatitude of the top edge / degree'))};
				GV.tooltips.LatLonXYTab_Map_xminmmEditField					= {sprintf(label_text,PP.TABLE_ROWNO.general.map_printout.xmin_mm,sprintf('Map printout limits:\nxmin / mm'))};
				GV.tooltips.LatLonXYTab_Map_xmaxmmEditField					= {sprintf(label_text,PP.TABLE_ROWNO.general.map_printout.xmax_mm,sprintf('Map printout limits:\nxmax / mm'))};
				GV.tooltips.LatLonXYTab_Map_yminmmEditField					= {sprintf(label_text,PP.TABLE_ROWNO.general.map_printout.ymin_mm,sprintf('Map printout limits:\nymin / mm'))};
				GV.tooltips.LatLonXYTab_Map_ymaxmmEditField					= {sprintf(label_text,PP.TABLE_ROWNO.general.map_printout.ymax_mm,sprintf('Map printout limits:\nymax / mm'))};
			else
				% Edit fields:
				GV.tooltips.LatLonXYTab_ScaleEditField							= {sprintf('Project parameter:\nScale')};
				GV.tooltips.LatLonXYTab_OriginLongitudeEditField			= {sprintf('Project parameter:\nOrigin longitude / degree')};
				GV.tooltips.LatLonXYTab_OriginLatitudeEditField				= {sprintf('Project parameter:\nOrigin latitude / degree')};
				GV.tooltips.LatLonXYTab_Dist_OSM_MapPrintout_EditField	= {sprintf('Project parameter:\nDistance between OSM-data and map printout limits / mm')};
				GV.tooltips.LatLonXYTab_FrameWidth_EditField					= {sprintf('Project parameter:\nOuter frame width / mm')};
				GV.tooltips.LatLonXYTab_TileWidth_EditField					= {sprintf('Project parameter:\nTile width / mm')};
				GV.tooltips.LatLonXYTab_TileHeight_EditField					= {sprintf('Project parameter:\nTile depth / mm')};
				GV.tooltips.LatLonXYTab_Osmosis_lonminEditField				= {sprintf('Project parameter:\nOsmosis bounding box:\nLongitude of the left edge / degree')};
				GV.tooltips.LatLonXYTab_Osmosis_lonmaxEditField				= {sprintf('Project parameter:\nOsmosis bounding box:\nLongitude of the right edge / degree')};
				GV.tooltips.LatLonXYTab_Osmosis_latminEditField				= {sprintf('Project parameter:\nOsmosis bounding box:\nLatitude of the bottom edge / degree')};
				GV.tooltips.LatLonXYTab_Osmosis_latmaxEditField				= {sprintf('Project parameter:\nOsmosis bounding box:\nLatitude of the top edge / degree')};
				GV.tooltips.LatLonXYTab_Map_xminmmEditField					= {sprintf('Project parameter:\nMap printout limits:\nxmin / mm')};
				GV.tooltips.LatLonXYTab_Map_xmaxmmEditField					= {sprintf('Project parameter:\nMap printout limits:\nxmax / mm')};
				GV.tooltips.LatLonXYTab_Map_yminmmEditField					= {sprintf('Project parameter:\nMap printout limits:\nymin / mm')};
				GV.tooltips.LatLonXYTab_Map_ymaxmmEditField					= {sprintf('Project parameter:\nMap printout limits:\nymax / mm')};
			end
			if APP.ShowTooltips_Menu.Checked
				% Edit fields:
				APP.LatLonXYTab_ScaleEditField.Tooltip							= GV.tooltips.LatLonXYTab_ScaleEditField;
				APP.LatLonXYTab_OriginLongitudeEditField.Tooltip			= GV.tooltips.LatLonXYTab_OriginLongitudeEditField;
				APP.LatLonXYTab_OriginLatitudeEditField.Tooltip				= GV.tooltips.LatLonXYTab_OriginLatitudeEditField;
				APP.LatLonXYTab_Dist_OSM_MapPrintout_EditField.Tooltip	= GV.tooltips.LatLonXYTab_Dist_OSM_MapPrintout_EditField;
				APP.LatLonXYTab_FrameWidth_EditField.Tooltip					= GV.tooltips.LatLonXYTab_FrameWidth_EditField;
				APP.LatLonXYTab_TileWidth_EditField.Tooltip					= GV.tooltips.LatLonXYTab_TileWidth_EditField;
				APP.LatLonXYTab_TileHeight_EditField.Tooltip					= GV.tooltips.LatLonXYTab_TileHeight_EditField;
				APP.LatLonXYTab_Osmosis_lonminEditField.Tooltip				= GV.tooltips.LatLonXYTab_Osmosis_lonminEditField;
				APP.LatLonXYTab_Osmosis_lonmaxEditField.Tooltip				= GV.tooltips.LatLonXYTab_Osmosis_lonmaxEditField;
				APP.LatLonXYTab_Osmosis_latminEditField.Tooltip				= GV.tooltips.LatLonXYTab_Osmosis_latminEditField;
				APP.LatLonXYTab_Osmosis_latmaxEditField.Tooltip				= GV.tooltips.LatLonXYTab_Osmosis_latmaxEditField;
				APP.LatLonXYTab_Map_xminmmEditField.Tooltip					= GV.tooltips.LatLonXYTab_Map_xminmmEditField;
				APP.LatLonXYTab_Map_xmaxmmEditField.Tooltip					= GV.tooltips.LatLonXYTab_Map_xmaxmmEditField;
				APP.LatLonXYTab_Map_yminmmEditField.Tooltip					= GV.tooltips.LatLonXYTab_Map_yminmmEditField;
				APP.LatLonXYTab_Map_ymaxmmEditField.Tooltip					= GV.tooltips.LatLonXYTab_Map_ymaxmmEditField;
			end

		case 'set_variable_tooltips'
			% Set variable elements of GV.tooltips after loading a project:
			set_tooltips('move_mapobject');
			set_tooltips('rotate_mapobject');
			set_tooltips('move_mapview');
			set_tooltips('latlonxytab');

		case 'get_all_tooltips'

			% Write all tooltips to:
			filename	= 'C:\Daten\Projekte\MapLab3D_Ablage\06_Docs\tooltips.xlsx';

			fn			= fieldnames(APP);
			% Tooltips table:
			tttable		= table('Size',[size(fn,1)+1 13],...
				'VariableTypes',{'cellstr','cellstr','cellstr',...
				'cellstr','cellstr','cellstr','cellstr','cellstr',...
				'cellstr','cellstr','cellstr','cellstr','cellstr'});
			ttsaved		= false(size(fn,1),1);
			it				= 1;		% line number
			rl				= 4;		% recursion level
			tttable(it,1)	= {'Type'};
			tttable(it,2)	= {'Text/Name/Title'};
			tttable(it,3)	= {'Tooltip'};
			tttable(it,4)	= {'APP.'};
			for ifn1=1:size(fn,1)
				if ~ttsaved(ifn1,1)
					fn1		= fn{ifn1,1};
					it					= it+1;
					if isprop(APP.(fn1),'Type')
						tttable(it,1)	= prop2cell(APP.(fn1).Type);
					end
					if isprop(APP.(fn1),'Text')
						tttable(it,2)	= prop2cell(APP.(fn1).Text);
					else
						if isprop(APP.(fn1),'Name')
							tttable(it,2)	= prop2cell(APP.(fn1).Name);
						else
							if isprop(APP.(fn1),'Title')
								if ischar(APP.(fn1).Title)
									tttable(it,2)	= prop2cell(APP.(fn1).Title);
								end
							end
						end
					end
					if isprop(APP.(fn1),'Tooltip')
						tttable(it,3)	= prop2cell(APP.(fn1).Tooltip);
						tttable(it,rl)	= {fn1};
					else
						tttable(it,rl)	= {fn1};
					end
					ttsaved(ifn1,1)	= true;
					if iscell(tttable(it,2))
						test=1;
					end
					% Recurse children:
					[tttable,ttsaved,it]=extend_tttable(tttable,ttsaved,it,fn,fn1,rl);
				end
			end
			writetable(tttable,filename);

	end

catch ME
	errormessage('',ME);
end



function [tttable,ttsaved,it]=extend_tttable(tttable,ttsaved,it,fn,fn1,rl)
% Recurse children:

global APP

try

	rl				= rl+1;
	if isprop(APP.(fn1),'Children')
		ch1				= APP.(fn1).Children;
		for ich1=1:size(ch1,1)
			for ifn2=1:size(fn,1)
				fn2		= fn{ifn2,1};
				if ~ttsaved(ifn2,1)
					if isequal(APP.(fn2),ch1(ich1,1))
						it					= it+1;
						if isprop(APP.(fn2),'Type')
							tttable(it,1)	= prop2cell(APP.(fn2).Type);
						end
						if isprop(APP.(fn2),'Text')
							tttable(it,2)	= prop2cell(APP.(fn2).Text);
						else
							if isprop(APP.(fn2),'Name')
								tttable(it,2)	= prop2cell(APP.(fn2).Name);
							else
								if isprop(APP.(fn2),'Title')
									if ischar(APP.(fn2).Title)
										tttable(it,2)	= prop2cell(APP.(fn2).Title);
									end
								end
							end
						end
						if isprop(APP.(fn2),'Tooltip')
							tttable(it,3)	= prop2cell(APP.(fn2).Tooltip);
							tttable(it,rl)	= {fn2};
						else
							tttable(it,rl)	= {fn2};
						end
						ttsaved(ifn2,1)	= true;
						if iscell(tttable(it,2))
							test=1;
						end
						% Recurse children:
						[tttable,ttsaved,it]=extend_tttable(tttable,ttsaved,it,fn,fn2,rl);
					end
				end
			end
		end
	end

catch ME
	errormessage('',ME);
end



function cellstr=prop2cell(prop)

try

	if iscell(prop)
		cellstr		= prop{1,1};
		for k=2:size(prop,1)
			cellstr		= sprintf('%s\n%s',cellstr,prop{k,1});
		end
		cellstr	= {cellstr};
	else
		cellstr	= {prop};
	end

catch ME
	errormessage('',ME);
end

