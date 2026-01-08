function table_out=display_map_objects(imapobj)
% The function display_map_objects uses the data in MAP_OBJECTS and creates the table MAP_OBJECTS_TABLE
% with the following fields:
%		PlotNo			consecutive number
%		ObjNo				index of the object in the project parameters: PP.obj(iboj,1)
%							or negative number if disp='preview ...' or disp='cutting line number ...'
%		ColNo				Color number of the object
%		Description		brief description of this object number (PP.obj(iboj,1).description)
%		Text				if MAP_OBJECTS(imapobj,1).disp='text': the displayed text
%		Vis				visibility
%		Group				object is grouped
%		DispAs			'symbol', 'line', 'area', 'text', 'connection line'
%							'preview', 'preview node', 'preview line', 'preview polygon'
%							'preview cutting line', 'cutting line', 'united equal colors'
% The following fields are no longer used in order to save computation time:
%		Mod				object is modified
%		X					x-value of the center
%		Y					y-value of the center
%
% Syntax:
% 1)	Create the table the first time or anew:
%		display_map_objects;
% 2)	Update only on row in the table:
%		display_map_objects(imapobj);
% 3)	Return the map objects table without updating the uitable
%		table_out=display_map_objects;

global APP GV MAP_OBJECTS MAP_OBJECTS_TABLE GV_H

try

	% If the map objects table is disabled (faster): skip:
	if ~APP.ShowMapObjectsTable_Menu.Checked
		if ~isempty(MAP_OBJECTS_TABLE)
			% Clear MAP_OBJECTS_TABLE:
			MAP_OBJECTS_TABLE									= [];
			GV_H.map_objects_table.Data					= MAP_OBJECTS_TABLE;
		end
		if nargout==0
			return
		end
	end

	if nargin==1
		if isempty(MAP_OBJECTS_TABLE)
			create_MAP_OBJECTS_TABLE	= true;
		else
			create_MAP_OBJECTS_TABLE	= false;
		end
	else
		create_MAP_OBJECTS_TABLE	= true;
	end
	% old:
	% ColumnNames	= {...
	% 	'PlotNo',...		% imapobj
	% 	'ObjNo',...			% MAP_OBJECTS(imapobj,1).iobj
	% 	'ColNo',...			% Color number
	% 	'Description',...	% MAP_OBJECTS(imapobj,1).dscr
	% 	'Text/Tag',...		% MAP_OBJECTS(imapobj,1).text
	% 	'Mod',...			% MAP_OBJECTS(imapobj,1).mod
	% 	'Vis',...			% visibility
	% 	'Group',...			% grouped: number of elements
	% 	'Nodes',...			% number of nodes
	% 	'X',...				% MAP_OBJECTS(imapobj,1).x
	% 	'Y',...				% MAP_OBJECTS(imapobj,1).y
	% 	'DispAs'};			% MAP_OBJECTS(imapobj,1).disp
	% VarNames	= {...
	% 	'PlotNo',...		% imapobj
	% 	'ObjNo',...			% MAP_OBJECTS(imapobj,1).iobj
	% 	'ColNo',...			% Color number
	% 	'Description',...	% MAP_OBJECTS(imapobj,1).dscr
	% 	'Text',...			% MAP_OBJECTS(imapobj,1).text
	% 	'Mod',...			% MAP_OBJECTS(imapobj,1).mod
	% 	'Vis',...			% visibility
	% 	'Group',...			% grouped: number of elements
	% 	'Nodes',...			% number of nodes
	% 	'X',...				% MAP_OBJECTS(imapobj,1).x
	% 	'Y',...				% MAP_OBJECTS(imapobj,1).y
	% 	'DispAs'};			% MAP_OBJECTS(imapobj,1).disp
	% VarTypes	= {...
	% 	'double',...		% imapobj
	% 	'double',...		% MAP_OBJECTS(imapobj,1).iobj
	% 	'string',...		% Color number
	% 	'string',...		% MAP_OBJECTS(imapobj,1).dscr
	% 	'string',...		% MAP_OBJECTS(imapobj,1).text
	% 	'string',...		% MAP_OBJECTS(imapobj,1).mod
	% 	'string',...		% visibility
	% 	'string',...		% grouped: number of elements
	% 	'double',...		% number of nodes
	% 	'double',...		% MAP_OBJECTS(imapobj,1).x
	% 	'double',...		% MAP_OBJECTS(imapobj,1).y
	% 	'string'};			% MAP_OBJECTS(imapobj,1).disp
	ColumnNames	= {...
		'PlotNo',...		% imapobj
		'ObjNo',...			% MAP_OBJECTS(imapobj,1).iobj
		'ColNo',...			% Color number
		'Description',...	% MAP_OBJECTS(imapobj,1).dscr
		'Text/Tag',...			% MAP_OBJECTS(imapobj,1).text
		'Vis',...			% visibility
		'Group',...			% grouped: number of elements
		'DispAs'};			% MAP_OBJECTS(imapobj,1).disp
	VarNames	= {...
		'PlotNo',...		% imapobj
		'ObjNo',...			% MAP_OBJECTS(imapobj,1).iobj
		'ColNo',...			% Color number
		'Description',...	% MAP_OBJECTS(imapobj,1).dscr
		'Text',...			% MAP_OBJECTS(imapobj,1).text
		'Vis',...			% visibility
		'Group',...			% grouped: number of elements
		'DispAs'};			% MAP_OBJECTS(imapobj,1).disp
	VarTypes	= {...
		'double',...		% imapobj
		'double',...		% MAP_OBJECTS(imapobj,1).iobj
		'string',...		% Color number
		'string',...		% MAP_OBJECTS(imapobj,1).dscr
		'string',...		% MAP_OBJECTS(imapobj,1).text
		'string',...		% visibility
		'string',...		% grouped: number of elements
		'string'};			% MAP_OBJECTS(imapobj,1).disp
	MAP_OBJECTS_TABLE_1row	= table('Size',[1 length(VarNames)],'VariableTypes',VarTypes,'VariableNames',VarNames);
	if create_MAP_OBJECTS_TABLE
		% Create MAP_OBJECTS_TABLE:
		imapobj_max			= size(MAP_OBJECTS,1);
		sz						= [imapobj_max length(VarNames)];
		MAP_OBJECTS_TABLE	= table('Size',sz,'VariableTypes',VarTypes,'VariableNames',VarNames);
		imapobj_v	= 1:imapobj_max;
	else
		imapobj_v	= imapobj;
	end

	% Assign the data to MAP_OBJECTS_TABLE:
	for k=1:length(imapobj_v)
		imapobj												= imapobj_v(k);

		% Check if these fields exist and are not empty:
		% This is intended to fix programming errors.
		if isfield(MAP_OBJECTS(imapobj,1),'mod')
			if isempty(MAP_OBJECTS(imapobj,1).mod)
				MAP_OBJECTS(imapobj,1).mod		= false;
			end
		else
			MAP_OBJECTS(imapobj,1).mod		= false;
		end
		if isfield(MAP_OBJECTS(imapobj,1),'cncl')
			if isempty(MAP_OBJECTS(imapobj,1).cncl)
				MAP_OBJECTS(imapobj,1).cncl		= 0;
			end
		else
			MAP_OBJECTS(imapobj,1).cncl		= 0;
		end
		if isfield(MAP_OBJECTS(imapobj,1),'cnuc')
			if isempty(MAP_OBJECTS(imapobj,1).cnuc)
				MAP_OBJECTS(imapobj,1).cnuc		= 0;
			end
		else
			MAP_OBJECTS(imapobj,1).cnuc		= 0;
		end
		if isfield(MAP_OBJECTS(imapobj,1),'vis0')
			if isempty(MAP_OBJECTS(imapobj,1).vis0)
				MAP_OBJECTS(imapobj,1).vis0		= 1;
			end
		else
			MAP_OBJECTS(imapobj,1).vis0		= 1;
		end

		% imapobj:
		for i=(height(MAP_OBJECTS_TABLE)+1):imapobj
			MAP_OBJECTS_TABLE(i,:)=MAP_OBJECTS_TABLE_1row;
		end

		% PlotNo:
		MAP_OBJECTS_TABLE.PlotNo(imapobj,1)			= imapobj;

		% ObjNo:
		MAP_OBJECTS_TABLE.ObjNo(imapobj,1)			= MAP_OBJECTS(imapobj,1).iobj;
		if MAP_OBJECTS(imapobj,1).iobj>0
			if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'iobj')
				for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
					if MAP_OBJECTS(imapobj,1).iobj~=MAP_OBJECTS(imapobj,1).h(i,1).UserData.iobj
						errormessage;
					end
				end
			end
		end

		% ColNo:
		if MAP_OBJECTS(imapobj,1).cncl~=0
			MAP_OBJECTS_TABLE.ColNo(imapobj,1)			= sprintf('%g',MAP_OBJECTS(imapobj,1).cncl);
		else
			if MAP_OBJECTS(imapobj,1).cnuc~=0
				MAP_OBJECTS_TABLE.ColNo(imapobj,1)			= sprintf('%g',MAP_OBJECTS(imapobj,1).cnuc);
			else
				if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'color_no')
					colno_v	= MAP_OBJECTS(imapobj,1).h(1,1).UserData.color_no;
					for i=2:size(MAP_OBJECTS(imapobj,1).h,1)
						colno_v	= [colno_v;MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no];
					end
					colno_v			= unique(colno_v);
					colno_str		= sprintf('%g',colno_v(1,1));
					for i=2:size(colno_v,1)
						colno_str		= sprintf('%s, %g',colno_str,colno_v(i,1));
					end
					MAP_OBJECTS_TABLE.ColNo(imapobj,1)			= colno_str;
				else
					MAP_OBJECTS_TABLE.ColNo(imapobj,1)			= '';
				end
			end
		end

		% Description:
		MAP_OBJECTS_TABLE.Description(imapobj,1)	= MAP_OBJECTS(imapobj,1).dscr;

		% Text/Tag:
		for itext=1:size(MAP_OBJECTS(imapobj,1).text,1)
			if itext==1
				MAP_OBJECTS_TABLE.Text(imapobj,1)	= MAP_OBJECTS(imapobj,1).text{itext,1};
			else
				MAP_OBJECTS_TABLE.Text(imapobj,1)	= strcat(...
					MAP_OBJECTS_TABLE.Text(imapobj,1)," ",MAP_OBJECTS(imapobj,1).text{itext,1});
			end
		end

		% 	% Mod:
		% 	if MAP_OBJECTS(imapobj,1).mod
		% 		MAP_OBJECTS_TABLE.Mod(imapobj,1)			= 'X';
		% 	else
		% 		MAP_OBJECTS_TABLE.Mod(imapobj,1)			= '';
		% 	end

		% Vis:
		if MAP_OBJECTS(imapobj,1).h(1,1).Visible
			switch MAP_OBJECTS(imapobj,1).h(1,1).Type
				case 'line'
					MAP_OBJECTS_TABLE.Vis(imapobj,1)			= '';
				case 'polygon'
					if 	isequal(MAP_OBJECTS(imapobj,1).h(1,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
							isequal(MAP_OBJECTS(imapobj,1).h(1,1).FaceAlpha,GV.visibility.show.facealpha)
						MAP_OBJECTS_TABLE.Vis(imapobj,1)		= '';
					else
						MAP_OBJECTS_TABLE.Vis(imapobj,1)		= 'GO';
					end
			end
		else
			if MAP_OBJECTS(imapobj,1).vis0==0
				MAP_OBJECTS_TABLE.Vis(imapobj,1)			= 'H';
			else
				MAP_OBJECTS_TABLE.Vis(imapobj,1)			= 'HT';
			end
		end

		% Group:
		no_elements	= length(MAP_OBJECTS(imapobj,1).h);
		if no_elements>1
			MAP_OBJECTS_TABLE.Group(imapobj,1)		= sprintf('%g',no_elements);
		else
			MAP_OBJECTS_TABLE.Group(imapobj,1)		= '';
		end

		% Type, Nodes, x, y, disp:
		% 	no_nodes		= 0;
		% 	for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
		% 		switch MAP_OBJECTS(imapobj,1).h(i,1).Type
		% 			case 'line'
		% 				no_nodes	= no_nodes+length(MAP_OBJECTS(imapobj,1).h(i,1).XData);
		% 			case 'polygon'
		% 				no_nodes	= no_nodes+numsides(MAP_OBJECTS(imapobj,1).h(i,1).Shape);
		% 		end
		% 	end
		% 	MAP_OBJECTS_TABLE.Nodes(imapobj,1)			= no_nodes;
		% 	MAP_OBJECTS_TABLE.X(imapobj,1)				= MAP_OBJECTS(imapobj,1).x;
		% 	MAP_OBJECTS_TABLE.Y(imapobj,1)				= MAP_OBJECTS(imapobj,1).y;
		MAP_OBJECTS_TABLE.DispAs(imapobj,1)			= MAP_OBJECTS(imapobj,1).disp;

	end

	% If the map objects table is disabled (faster): return the map objects table without updating the uitable:
	if ~APP.ShowMapObjectsTable_Menu.Checked
		table_out			= MAP_OBJECTS_TABLE;
		MAP_OBJECTS_TABLE	= [];
		return
	end

	% Display or update the table:
	create_new_tablefigure	= false;
	if isempty(APP)
		% Only for testing, without app:
		if ~isfield(GV_H,'map_objects_table')
			create_new_tablefigure	= true;
		else
			if isempty(GV_H.map_objects_table)
				create_new_tablefigure	= true;
			else
				if ~ishandle(GV_H.map_objects_table)
					create_new_tablefigure	= true;
				end
			end
		end
	end
	if create_new_tablefigure
		% Only for testing: Create a new table:
		testfig_MAP_OBJECTS_TABLE			= uifigure;
		testfig_MAP_OBJECTS_TABLE.Name	= 'MAP_OBJECTS_TABLE';
		GV_H.map_objects_table	= uitable(testfig_MAP_OBJECTS_TABLE,...
			'Data',MAP_OBJECTS_TABLE,...
			'ColumnSortable',true(1,size(MAP_OBJECTS_TABLE,2)),...
			'ColumnWidth','fit');
	else
		% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		% If MAP_OBJECTS_TABLE or GV_H.map_objects_table.Data are assigned outside this function:
		% Query APP.ShowMapObjectsTable_Menu.Checked !
		% ~APP.ShowMapObjectsTable_Menu.Checked  -->  The map objects table is disabled.
		% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		if create_MAP_OBJECTS_TABLE
			% Replace the whole data in the existing table:
			GV_H.map_objects_table.Data			= MAP_OBJECTS_TABLE;
		else

			% Change only the specified data in the existing table:
			GV_H.map_objects_table.Data(imapobj_v,:)	= MAP_OBJECTS_TABLE(imapobj_v,:);

			% 		% Changing single values is not faster:
			% 		for k=1:length(imapobj_v)
			% 			imapobj			= imapobj_v(k);
			% 			for c=1:width(GV_H.map_objects_table.Data)
			% 				if ~isequal(GV_H.map_objects_table.Data.(c)(imapobj),MAP_OBJECTS_TABLE.(c)(imapobj))
			% 					GV_H.map_objects_table.Data.(c)(imapobj)	= MAP_OBJECTS_TABLE.(c)(imapobj);
			% 				end
			% 			end
			% 		end

		end
		GV_H.map_objects_table.ColumnWidth	= 'fit';
		drawnow;
	end
	GV_H.map_objects_table.ColumnName	= ColumnNames;

catch ME
	errormessage('',ME);
end

