function set_inclexcltags_table(action)
% action='set'							set the include/exclude keys/values depending on the selected object number
% action='reset'						initialize the include and exclude tags tables
% action='init_objno_dropdown'	set the object numbers dropdown menu

global PP GV APP GV_H

try

	if isempty(PP)
		return
	end

	% Display state:
	stateisbusy	= display_on_gui('state','','isbusy');
	if ~stateisbusy
		switch action
			case 'set'
				display_on_gui('state','Set include and exclude tags ...','busy','add');
			case 'reset'
				display_on_gui('state','Reset include and exclude tags ...','busy','add');
		end
	end

	% Initializations:
	rmax_in		= max(GV.pp_obj_inclexcltags_no_row_min,GV.pp_obj_incltags_no_row_max);
	cmax_in		= max(GV.pp_obj_inclexcltags_no_row_min,GV.pp_obj_incltags_no_col_max);
	rmax_ex		= max(GV.pp_obj_inclexcltags_no_row_min,GV.pp_obj_excltags_no_row_max);
	cmax_ex		= max(GV.pp_obj_inclexcltags_no_row_min,GV.pp_obj_excltags_no_col_max);

	switch action
		case 'set'
			% Set the include and exclude keys and values depending on the selected object number:

			% Get iobj:
			items					= APP.FilterOSMDataObjNoDropDown.Items;
			ud						= APP.FilterOSMDataObjNoDropDown.UserData;
			value					= APP.FilterOSMDataObjNoDropDown.Value;
			iobj					= 0;
			for i_value=1:size(items,2)
				if strcmp(items{1,i_value},value)
					iobj		= ud.objno_v(1,i_value);
					break
				end
			end
			if iobj==0
				switch action
					case 'set'
						display_on_gui('state','Set include and exclude tags ... done','notbusy','replace');
					case 'reset'
						display_on_gui('state','Reset include and exclude tags ... done','notbusy','replace');
				end
				return
			end

			% Get tag_incl and tag_excl:
			if isequal(...
					APP.FilterOSMData_AutofillSource_ButtonGroup.SelectedObject,...
					APP.FilterOSMData_AutofillSource_LiAr_Button)
				tag_incl		= PP.obj(iobj,1).tag_incl;
				tag_excl		= PP.obj(iobj,1).tag_excl;
			elseif isequal(...
					APP.FilterOSMData_AutofillSource_ButtonGroup.SelectedObject,...
					APP.FilterOSMData_AutofillSource_Text_Button)
				if isfield(PP.obj(iobj,1).textpar,'tag_incl')
					tag_incl		= PP.obj(iobj,1).textpar.tag_incl;
				else
					tag_incl		= PP.obj(iobj,1).tag_incl;
				end
				if isfield(PP.obj(iobj,1).textpar,'tag_excl')
					tag_excl		= PP.obj(iobj,1).textpar.tag_excl;
				else
					tag_excl		= PP.obj(iobj,1).tag_excl;
				end
			elseif isequal(...
					APP.FilterOSMData_AutofillSource_ButtonGroup.SelectedObject,...
					APP.FilterOSMData_AutofillSource_Symb_Button)
				if isfield(PP.obj(iobj,1).symbolpar,'tag_incl')
					tag_incl		= PP.obj(iobj,1).symbolpar.tag_incl;
				else
					tag_incl		= PP.obj(iobj,1).tag_incl;
				end
				if isfield(PP.obj(iobj,1).symbolpar,'tag_excl')
					tag_excl		= PP.obj(iobj,1).symbolpar.tag_excl;
				else
					tag_excl		= PP.obj(iobj,1).tag_excl;
				end
			end

			% Include keys and values:
			keys_data			= cell(rmax_in,cmax_in);
			values_data			= cell(rmax_in,cmax_in);
			for r=1:rmax_in
				for c=1:cmax_in
					if    (r<=size(tag_incl,1))&&...
							(c<=size(tag_incl,2))
						keys_data{r,c}		= tag_incl(r,c).k;
						values_data{r,c}	= tag_incl(r,c).v;
					else
						keys_data{r,c}		= '';
						values_data{r,c}	= '';
					end
				end
			end
			APP.include_keys.Data		= keys_data;
			APP.include_values.Data		= values_data;

			% Exclude keys and values:
			keys_data			= cell(rmax_ex,cmax_ex);
			values_data			= cell(rmax_ex,cmax_ex);
			for r=1:rmax_ex
				for c=1:cmax_ex
					if    (r<=size(tag_excl,1))&&...
							(c<=size(tag_excl,2))
						keys_data{r,c}		= tag_excl(r,c).k;
						values_data{r,c}	= tag_excl(r,c).v;
					else
						keys_data{r,c}		= '';
						values_data{r,c}	= '';
					end
				end
			end
			APP.exclude_keys.Data		= keys_data;
			APP.exclude_values.Data		= values_data;

			% Selection description:
			filter_osmdata_filterstring([],PP.obj(iobj,1).description);

		case 'reset'
			% Initialize the include and exclude tags tables:

			% Set include_keys table:
			app_uitable.Data							= cell(rmax_in,cmax_in);
			app_uitable.RowName						= cell(rmax_in,1);
			app_uitable.ColumnName					= cell(cmax_in,1);
			for r=1:rmax_in
				for c=1:cmax_in
					app_uitable.Data{r,c}			= '';
				end
			end
			app_uitable.RowName{1,1}				= '1';
			for r=2:rmax_in
				app_uitable.RowName{r,1}			= sprintf('%1.0f and',r);
			end
			app_uitable.ColumnName{1,1}			= 'include key';
			for c=2:cmax_in
				app_uitable.ColumnName{c,1}		= sprintf('%1.0f or',c);
			end
			APP.include_keys.Data					= app_uitable.Data;
			APP.include_keys.RowName				= app_uitable.RowName;
			APP.include_keys.ColumnName			= app_uitable.ColumnName;
			APP.include_keys.ColumnEditable		= true(1,cmax_in);

			% Set include_values table:
			app_uitable.ColumnName{1,1}			= 'include value';
			APP.include_values.Data					= app_uitable.Data;
			APP.include_values.RowName				= app_uitable.RowName;
			APP.include_values.ColumnName			= app_uitable.ColumnName;
			APP.include_values.ColumnEditable	= true(1,cmax_in);

			% Set exclude keys table:
			app_uitable.Data							= cell(rmax_ex,cmax_ex);
			app_uitable.RowName						= cell(rmax_ex,1);
			app_uitable.ColumnName					= cell(cmax_ex,1);
			for r=1:rmax_ex
				for c=1:cmax_ex
					app_uitable.Data{r,c}			= '';
				end
			end
			app_uitable.RowName{1,1}				= '1';
			for r=2:rmax_ex
				app_uitable.RowName{r,1}			= sprintf('%1.0f and',r);
			end
			app_uitable.ColumnName{1,1}			= 'exclude key';
			for c=2:cmax_ex
				app_uitable.ColumnName{c,1}		= sprintf('%1.0f or',c);
			end
			APP.exclude_keys.Data					= app_uitable.Data;
			APP.exclude_keys.RowName				= app_uitable.RowName;
			APP.exclude_keys.ColumnName			= app_uitable.ColumnName;
			APP.exclude_keys.ColumnEditable		= true(1,cmax_ex);

			% Set exclude values table:
			app_uitable.ColumnName{1,1}			= 'exclude value';
			APP.exclude_values.Data					= app_uitable.Data;
			APP.exclude_values.RowName				= app_uitable.RowName;
			APP.exclude_values.ColumnName			= app_uitable.ColumnName;
			APP.exclude_values.ColumnEditable	= true(1,cmax_ex);

			% Selection description:
			filter_osmdata_filterstring([],'');

		case 'init_objno_dropdown'
			% Set the object numbers dropdown menu:

			items				= cell(1,0);
			ud					= struct;
			ud.objno_v		= zeros(1,0);
			i_value			= 0;
			if ~isempty(PP)
				nmax_objno		= ceil(log10(size(PP.obj,1)));
				for iobj=1:size(PP.obj,1)
					if ~isempty(PP.obj(iobj,1).display)
						i_value					= i_value+1;
						objno_str				= sprintf('%1.0f',iobj);
						items{1,i_value}		= sprintf('%s%s   %s',...
							blanks(nmax_objno-length(objno_str)),...
							objno_str,...
							PP.obj(iobj,1).description);
						ud.objno_v(1,i_value)	= iobj;

					end
				end
			end
			APP.FilterOSMDataObjNoDropDown.Items		= items;
			APP.FilterOSMDataObjNoDropDown.UserData	= ud;

	end

	if ~stateisbusy
		switch action
			case 'set'
				display_on_gui('state','Set include and exclude tags ... done','notbusy','replace');
			case 'reset'
				display_on_gui('state','Reset include and exclude tags ... done','notbusy','replace');
		end

		set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
		set(GV_H.text_waitbar,'String','');
	end

catch ME
	errormessage('',ME);
end

