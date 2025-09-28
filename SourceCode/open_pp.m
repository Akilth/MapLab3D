function open_pp(get_userinput)
% Opens the project file and assigns the project parameters PP.
% The meaning of the columns in the project file is:
% FIELDi		Name of field i in structure PP
% SNMCi		indicates whether this field is:
%				S		a String
%				N		a scalar number
%				M		a matrix of numbers
%						The matrix is saved as cell array. Example: PP.legend.element(12,1).legsymb_objno={[31 32 33]}
%				C		a cell array
% Ri, Ci		If the field i is a matrix or a cell array:
%				Row and column numbers
% Syntax:	1)	open_pp(0) or
%					open_pp				open project file, use existing filename and project directory
%				2)	open_pp(1)			open project file and ask for filename and project directory

global PP GV GV_H APP MAP_OBJECTS ELE SETTINGS

try
	
	% Display state:
	t_start_statebusy	= clock;
	display_on_gui('state','Loading project parameters ...','busy','add');
	fprintf(1,'\nLoading project parameters ...\n');
	
	if nargin==0
		get_userinput_pp	=	0;
		get_userinput_pd	=	0;
	else
		get_userinput_pp	=	get_userinput;
		get_userinput_pd	=	get_userinput;
	end
	
	% Get Filename:
	if ~isfield(GV,'pp_pathfilename')
		get_userinput_pp			= 1;
		pathname						= SETTINGS.pp_pathfilename;
	else
		pathname						= GV.pp_pathfilename;
	end
	if isnumeric(pathname)
		get_userinput_pp				= 1;
		pathname							= SETTINGS.default_pathname;
	else
		if exist(pathname,'file')~=2
			% The file does not exist:
			get_userinput_pp			= 1;
			pathname						= SETTINGS.default_pathname;
		end
	end
	if get_userinput_pp~=0
		% Ask for the project file:
		figure(APP.MapLab3D);	% This is a test to prevent the uiget window from being opened behind another window.
		[filename,pathname]	= uigetfile_local('*.*','Select the project parameters file',pathname);
		figure(APP.MapLab3D);	% This brings the app figure to the foreground.
		% If the user clicks Cancel or the window close button (X):
		if isequal(filename,0)||isequal(pathname,0)
			% Display state:
			display_on_gui('state',...
				sprintf('Loading project parameters ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			return
		end
		display_on_gui('pathfilenames');
		% Check the file extension:
		extensions		= {'txt';'dat';'csv';'xls';'xlsb';'xlsm';'xlsx';'xltm';'xltx';'ods'};
		k					= find(filename=='.');
		file_extension	= filename((k(end)+1):end);
		wrong_ext		= true;
		for i=1:length(extensions)
			if strcmp(file_extension,extensions{i})
				wrong_ext	= false;
				break;
			end
		end
		if wrong_ext
			errortext	= sprintf([...
				'The file extension .%s is not supported.\n',...
				'Permitted file extensions are:\n.%s'],file_extension,extensions{1});
			for i=2:length(extensions)
				errortext	= sprintf('%s, .%s',errortext,extensions{i});
			end
			errormessage(errortext)
		end
		% The file extension is OK:
		GV.pp_pathfilename			= [pathname filename];
		SETTINGS.pp_pathfilename	= [pathname filename];
		set_settings('save');
	end
	
	% Get the name of the project directory (location of the output files):
	% Do this after "Get Filename", see set_settings('save') !
	projectdirectory	= get_projectdirectory(get_userinput_pd);
	
	% If the user clicks Cancel or the window close button (X):
	if isequal(projectdirectory,0)
		display_on_gui('state',...
			sprintf('Loading project parameters ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
			'notbusy','replace');
		return
	end
	display_on_gui('pathfilenames');
	
	% Read file:
	try
		% Waitbar:
		if ~isempty(APP)
			set(GV_H.text_waitbar,'String','Loading project parameters ...');
			drawnow;
		end
		% Load file:
		opts	= detectImportOptions(GV.pp_pathfilename,'Sheet','PP');
	catch ME
		errortext	= sprintf([...
			'Error when loading the project file:\n',...
			'%s'],GV.pp_pathfilename);
		errormessage(errortext,ME);
	end
	for i=1:length(opts.VariableNames)
		if    strcmp(opts.VariableNames{i},'R1')||strcmp(opts.VariableNames{i},'C1')||...
				strcmp(opts.VariableNames{i},'R2')||strcmp(opts.VariableNames{i},'C2')||...
				strcmp(opts.VariableNames{i},'R3')||strcmp(opts.VariableNames{i},'C3')||...
				strcmp(opts.VariableNames{i},'R4')||strcmp(opts.VariableNames{i},'C4')
			opts.VariableTypes{i}	= 'double';
		else
			opts.VariableTypes{i}	= 'char';
		end
	end
	opts.DataRange	= 'A2';
	T					= readtable(GV.pp_pathfilename,opts);
	
	% Check whether all required project parameters are included:
	errortext		= verify_pp(T);
	if ~isempty(errortext)
		errormessage(errortext);
	end
	
	% Detect zoom level:
	PP_temp										= [];
	search_project_version_no				= true;
	search_project_projectname				= true;
	search_project_filename					= true;
	search_project_scale						= true;
	search_general_row_minscale			= true;
	search_general_row_maxscale			= true;
	search_general_projectname				= true;
	for row=1:length(T.FIELD1)
		if search_project_version_no
			if strcmp(T.FIELD1{row},'project')&&strcmp(T.FIELD2{row},'version_no')
				PP_temp.project.version_no										= T.PROJECT{row};
				PP_temp.DESCRIPTION.project{1,1}.version_no{1,1}		= T.DESCRIPTION{row};
				PP_temp.TABLE_ROWNO.project.version_no						= row+1;
				search_project_version_no										= false;
			end
		end
		if search_project_projectname
			if strcmp(T.FIELD1{row},'project')&&strcmp(T.FIELD2{row},'projectname')
				PP_temp.project.projectname									= T.PROJECT{row};
				PP_temp.DESCRIPTION.project{1,1}.projectname{1,1}		= T.DESCRIPTION{row};
				PP_temp.TABLE_ROWNO.project.projectname					= row+1;
				search_project_projectname										= false;
			end
		end
		if search_project_filename
			if strcmp(T.FIELD1{row},'project')&&strcmp(T.FIELD2{row},'filename')
				PP_temp.project.filename										= validfilename(T.PROJECT{row});
				PP_temp.DESCRIPTION.project{1,1}.filename{1,1}			= T.DESCRIPTION{row};
				PP_temp.TABLE_ROWNO.project.filename						= row+1;
				search_project_filename											= false;
			end
		end
		if search_project_scale
			if strcmp(T.FIELD1{row},'project')&&strcmp(T.FIELD2{row},'scale')
				PP_temp.project.scale											= str2double(T.PROJECT{row});
				PP_temp.DESCRIPTION.project{1,1}.scale{1,1}				= T.DESCRIPTION{row};
				PP_temp.TABLE_ROWNO.project.scale							= row+1;
				search_project_scale												= false;
			end
		end
		if search_general_row_minscale
			if strcmp(T.FIELD1{row},'general')&&strcmp(T.FIELD2{row},'minscale')
				row_minscale														= row;
				search_general_row_minscale									= false;
			end
		end
		if search_general_row_maxscale
			if strcmp(T.FIELD1{row},'general')&&strcmp(T.FIELD2{row},'maxscale')
				row_maxscale														= row;
				search_general_row_maxscale									= false;
			end
		end
		if search_general_projectname
			if strcmp(T.FIELD1{row},'general')&&strcmp(T.FIELD2{row},'projectname')
				row_projectname										= row;
				search_general_projectname							= false;
			end
		end
	end
	% First search for a combination
	% scale>=general_minscale &&
	% scale<=general_maxscale &&
	% projectname==general_projectname
	dataset_no	= [];
	for i=1:width(T)
		varname	= T.Properties.VariableNames{i};
		if isequal(strfind(varname,'DATASET_'),1)
			dsno			= str2double(varname(9:end));
			if ~isnan(dsno)
				general_minscale		= str2double(T.(sprintf('DATASET_%1.0f',dsno)){row_minscale});
				general_maxscale		= str2double(T.(sprintf('DATASET_%1.0f',dsno)){row_maxscale});
				general_projectname	= T.(sprintf('DATASET_%1.0f',dsno)){row_projectname};
				if    (PP_temp.project.scale>=general_minscale)&&...
						(PP_temp.project.scale<=general_maxscale)&&...
						isequal(PP_temp.project.projectname,general_projectname)
					dataset_no	= [dataset_no dsno];
				end
			end
		end
	end
	if length(dataset_no)>1
		errormessage(sprintf([...
			'Error in %s:\nThe dataset number x (DATASET_x)\n',...
			'and project names are not unique.'],...
			GV.pp_pathfilename));
	end
	% Then search for a combination scale>=general_minscale && scale<=general_maxscale
	if isempty(dataset_no)
		for i=1:width(T)
			varname	= T.Properties.VariableNames{i};
			if isequal(strfind(varname,'DATASET_'),1)
				dsno			= str2double(varname(9:end));
				if ~isnan(dsno)
					general_minscale		= str2double(T.(sprintf('DATASET_%1.0f',dsno)){row_minscale});
					general_maxscale		= str2double(T.(sprintf('DATASET_%1.0f',dsno)){row_maxscale});
					if (PP_temp.project.scale>=general_minscale)&&(PP_temp.project.scale<=general_maxscale)
						dataset_no	= [dataset_no dsno];
					end
				end
			end
		end
	end
	if length(dataset_no)>1
		errormessage(sprintf([...
			'Error in %s:\nThe dataset number x (DATASET_x)\n',...
			'and project names are ambiguous:\nx = %s.'],...
			GV.pp_pathfilename,num2str(dataset_no)));
	end
	if isempty(dataset_no)
		errormessage(sprintf('Error in %s:\nThe scale is not included in the\nrange of minscale and maxscale.',...
			GV.pp_pathfilename));
	end
	if (dataset_no<1)||~isequal(dataset_no,round(dataset_no))
		errormessage(sprintf(...
			'Error in %s:\nThe dataset number must be a whole number greater than zero:\ndataset number = %s.',...
			GV.pp_pathfilename,num2str(dataset_no)));
	end
	
	% Check whether the map needs to be recreated:
	varname_dataset_no	= sprintf('DATASET_%1.0f',dataset_no);
	search_project_scale						= true;
	search_general_origin_user_lat		= true;
	search_general_origin_user_lon		= true;
	search_general_superelevation			= true;
	search_general_dxy_ele_mm				= true;
	search_general_interpolation_method	= true;
	for row=1:length(T.FIELD1)
		if search_project_scale
			if strcmp(T.FIELD1{row},'project')&&strcmp(T.FIELD2{row},'scale')
				if isequal(T.C2(row),2)
					PP_temp.project.scale					= str2double(T.PROJECT{row});
					search_project_scale						= false;
				end
			end
		end
		if search_general_origin_user_lat
			if strcmp(T.FIELD1{row},'general')&&strcmp(T.FIELD2{row},'origin_user_lat')
				PP_temp.general.origin_user_lat			= str2double(T.(varname_dataset_no){row});
				search_general_origin_user_lat			= false;
			end
		end
		if search_general_origin_user_lon
			if strcmp(T.FIELD1{row},'general')&&strcmp(T.FIELD2{row},'origin_user_lon')
				PP_temp.general.origin_user_lon			= str2double(T.(varname_dataset_no){row});
				search_general_origin_user_lon			= false;
			end
		end
		if search_general_superelevation
			if strcmp(T.FIELD1{row},'general')&&strcmp(T.FIELD2{row},'superelevation')
				PP_temp.general.superelevation			= str2double(T.(varname_dataset_no){row});
				search_general_superelevation				= false;
			end
		end
		if search_general_dxy_ele_mm
			if strcmp(T.FIELD1{row},'general')&&strcmp(T.FIELD2{row},'dxy_ele_mm')
				PP_temp.general.dxy_ele_mm					= str2double(T.(varname_dataset_no){row});
				search_general_dxy_ele_mm					= false;
			end
		end
		if search_general_interpolation_method
			if strcmp(T.FIELD1{row},'general')&&strcmp(T.FIELD2{row},'interpolation_method')
				PP_temp.general.interpolation_method	= T.(varname_dataset_no){row};
				search_general_interpolation_method		= false;
			end
		end
		if    strcmp(T.FIELD1{row},'colorspec')  &&...
				strcmp(T.FIELD2{row},'ele_filtset')
			if strcmp(T.FIELD3{row},'filtersize')
				PP_temp.colorspec(T.R1(row),1).ele_filtset.filtersize		= str2double(T.(varname_dataset_no){row});
			end
			if strcmp(T.FIELD3{row},'sigma')
				PP_temp.colorspec(T.R1(row),1).ele_filtset.sigma		= str2double(T.(varname_dataset_no){row});
			end
		end
	end
	pptemp_colorspec_ele_filtset_filtersize	= ones(size(PP_temp.colorspec,1),1);
	pptemp_colorspec_ele_filtset_sigma			= ones(size(PP_temp.colorspec,1),1);
	for icolspec=1:size(PP_temp.colorspec,1)
		pptemp_colorspec_ele_filtset_filtersize(icolspec,1)	= PP_temp.colorspec(icolspec,1).ele_filtset.filtersize;
		pptemp_colorspec_ele_filtset_sigma(icolspec,1)			= PP_temp.colorspec(icolspec,1).ele_filtset.sigma;
	end
	recreate_map	= 1;
	if    isfield(GV,'pp_general_origin_user_lat'         ) && ...
			isfield(GV,'pp_general_origin_user_lon'         ) && ...
			isfield(GV,'pp_general_scale'                   ) && ...
			isfield(GV,'pp_general_dxy_ele_mm'              ) && ...
			isfield(GV,'pp_general_interpolation_method'    ) && ...
			isfield(GV,'pp_colorspec_ele_filtset_filtersize') && ...
			isfield(GV,'pp_colorspec_ele_filtset_sigma'     )
		if    isequal(GV.pp_general_origin_user_lat         ,PP_temp.general.origin_user_lat        ) && ...
				isequal(GV.pp_general_origin_user_lon         ,PP_temp.general.origin_user_lon        ) && ...
				isequal(GV.pp_general_scale                   ,PP_temp.project.scale                  ) && ...
				isequal(GV.pp_general_dxy_ele_mm              ,PP_temp.general.dxy_ele_mm             ) && ...
				strcmp( GV.pp_general_interpolation_method    ,PP_temp.general.interpolation_method   ) && ...
				isequal(GV.pp_colorspec_ele_filtset_filtersize,pptemp_colorspec_ele_filtset_filtersize) && ...
				isequal(GV.pp_colorspec_ele_filtset_sigma     ,pptemp_colorspec_ele_filtset_sigma     )
			recreate_map	= 0;
			% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			% User confirmation:
			% selection	= uiconfirm(fig,message,title,Name,Value);
			% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		end
	end
	
	% Assign the structure PP_temp:
	assign_projectpar		= 0;
	PP_temp					= open_pp_assign_pp(PP_temp,T,dataset_no,assign_projectpar);
	
	% Replace the default project parameters by the specified values:
	for iobj=1:size(PP_temp.obj,1)
		if ~isempty(PP_temp.obj(iobj,1).display)
			% There is data for the object number iobj:
			PP_obj_ext(iobj,1)	= PP_temp.defobj;
		end
	end
	[PP_obj_ext,~]	= extentppobj(PP_obj_ext,PP_temp.obj);
	% If tag_incl/tag_excl of textpar/symbolpar are not specified: delete them in PP_obj_ext:
	for iobj=1:size(PP_obj_ext,1)
		if ~isempty(PP_obj_ext(iobj,1))
			% There is data for the object number iobj:
			% -----------------------------------------------------------------------------------------------------------
			% Check whether the tags tag_incl/tag_excl of textpar are empty or equal to the objects tags:
			if ~isempty(PP_obj_ext(iobj,1).textpar)
				isempty_objtagincl	= true;
				isempty_objtagexcl	= true;
				for r=1:size(PP_obj_ext(iobj,1).textpar.tag_incl,1)
					for c=1:size(PP_obj_ext(iobj,1).textpar.tag_incl,2)
						if    ~isempty(PP_obj_ext(iobj,1).textpar.tag_incl(r,c).k)||...
								~isempty(PP_obj_ext(iobj,1).textpar.tag_incl(r,c).v)
							isempty_objtagincl	= false;
							break
						end
					end
					if ~isempty_objtagincl
						break
					end
				end
				for r=1:size(PP_obj_ext(iobj,1).textpar.tag_excl,1)
					for c=1:size(PP_obj_ext(iobj,1).textpar.tag_excl,2)
						if    ~isempty(PP_obj_ext(iobj,1).textpar.tag_excl(r,c).k)||...
								~isempty(PP_obj_ext(iobj,1).textpar.tag_excl(r,c).v)
							isempty_objtagexcl	= false;
							break
						end
					end
					if ~isempty_objtagexcl
						break
					end
				end
				% Check whether the tags tag_incl/tag_excl of textpar are equal to the objects tags:
				if isempty_objtagincl&&isempty_objtagexcl
					delete_tag_inexcl	= true;
				else
					tag_empty					= struct;
					tag_empty.k					= '';
					tag_empty.op				= '';
					tag_empty.v					= '';
					txsypar_tagincl_ext		= PP_obj_ext(iobj,1).textpar.tag_incl;
					txsypar_tagexcl_ext		= PP_obj_ext(iobj,1).textpar.tag_excl;
					obj_tagincl_ext			= PP_obj_ext(iobj,1).tag_incl;
					obj_tagexcl_ext			= PP_obj_ext(iobj,1).tag_excl;
					% Equal sizes:
					for r=size(obj_tagincl_ext,1):size(txsypar_tagincl_ext,1)
						for c=size(obj_tagincl_ext,2):size(txsypar_tagincl_ext,2)
							obj_tagincl_ext(r,c)		= tag_empty;
						end
					end
					for r=size(obj_tagexcl_ext,1):size(txsypar_tagexcl_ext,1)
						for c=size(obj_tagexcl_ext,2):size(txsypar_tagexcl_ext,2)
							obj_tagexcl_ext(r,c)		= tag_empty;
						end
					end
					for r=size(txsypar_tagincl_ext,1):size(obj_tagincl_ext,1)
						for c=size(txsypar_tagincl_ext,2):size(obj_tagincl_ext,2)
							txsypar_tagincl_ext(r,c)		= tag_empty;
						end
					end
					for r=size(txsypar_tagexcl_ext,1):size(obj_tagexcl_ext,1)
						for c=size(txsypar_tagexcl_ext,2):size(obj_tagexcl_ext,2)
							txsypar_tagexcl_ext(r,c)		= tag_empty;
						end
					end
					% Compare:
					delete_tag_inexcl	= true;
					if delete_tag_inexcl
						for r=1:size(obj_tagincl_ext,1)
							for c=1:size(obj_tagincl_ext,2)
								if ~isequal(obj_tagincl_ext(r,c),txsypar_tagincl_ext(r,c))
									delete_tag_inexcl	= false;
									break
								end
							end
							if ~delete_tag_inexcl
								break
							end
						end
					end
					if delete_tag_inexcl
						for r=1:size(obj_tagexcl_ext,1)
							for c=1:size(obj_tagexcl_ext,2)
								if ~isequal(obj_tagexcl_ext(r,c),txsypar_tagexcl_ext(r,c))
									delete_tag_inexcl	= false;
									break
								end
							end
							if ~delete_tag_inexcl
								break
							end
						end
					end
				end
				% If the tags are empty or equal to the objects tags: delete the fields tag_incl/tag_excl:
				if delete_tag_inexcl
					PP_obj_ext(iobj,1).textpar	= rmfield(PP_obj_ext(iobj,1).textpar,'tag_incl');
					PP_obj_ext(iobj,1).textpar	= rmfield(PP_obj_ext(iobj,1).textpar,'tag_excl');
				else
					fprintf(1,'ObjNo=%g: special include and exclude tags of texts\n',iobj);
				end
			end
			% Check whether the tags tag_incl/tag_excl of textpar are empty or equal to the objects tags: asdf asdf
			% -----------------------------------------------------------------------------------------------------------
			if ~isempty(PP_obj_ext(iobj,1).symbolpar)
				isempty_objtagincl	= true;
				isempty_objtagexcl	= true;
				for r=1:size(PP_obj_ext(iobj,1).symbolpar.tag_incl,1)
					for c=1:size(PP_obj_ext(iobj,1).symbolpar.tag_incl,2)
						if    ~isempty(PP_obj_ext(iobj,1).symbolpar.tag_incl(r,c).k)||...
								~isempty(PP_obj_ext(iobj,1).symbolpar.tag_incl(r,c).v)
							isempty_objtagincl	= false;
							break
						end
					end
					if ~isempty_objtagincl
						break
					end
				end
				for r=1:size(PP_obj_ext(iobj,1).symbolpar.tag_excl,1)
					for c=1:size(PP_obj_ext(iobj,1).symbolpar.tag_excl,2)
						if    ~isempty(PP_obj_ext(iobj,1).symbolpar.tag_excl(r,c).k)||...
								~isempty(PP_obj_ext(iobj,1).symbolpar.tag_excl(r,c).v)
							isempty_objtagexcl	= false;
							break
						end
					end
					if ~isempty_objtagexcl
						break
					end
				end
				% Check whether the tags tag_incl/tag_excl of symbolpar are equal to the objects tags:
				if isempty_objtagincl&&isempty_objtagexcl
					delete_tag_inexcl	= true;
				else
					tag_empty					= struct;
					tag_empty.k					= '';
					tag_empty.op				= '';
					tag_empty.v					= '';
					txsypar_tagincl_ext		= PP_obj_ext(iobj,1).symbolpar.tag_incl;
					txsypar_tagexcl_ext		= PP_obj_ext(iobj,1).symbolpar.tag_excl;
					obj_tagincl_ext			= PP_obj_ext(iobj,1).tag_incl;
					obj_tagexcl_ext			= PP_obj_ext(iobj,1).tag_excl;
					% Equal sizes:
					for r=size(obj_tagincl_ext,1):size(txsypar_tagincl_ext,1)
						for c=size(obj_tagincl_ext,2):size(txsypar_tagincl_ext,2)
							obj_tagincl_ext(r,c)		= tag_empty;
						end
					end
					for r=size(obj_tagexcl_ext,1):size(txsypar_tagexcl_ext,1)
						for c=size(obj_tagexcl_ext,2):size(txsypar_tagexcl_ext,2)
							obj_tagexcl_ext(r,c)		= tag_empty;
						end
					end
					for r=size(txsypar_tagincl_ext,1):size(obj_tagincl_ext,1)
						for c=size(txsypar_tagincl_ext,2):size(obj_tagincl_ext,2)
							txsypar_tagincl_ext(r,c)		= tag_empty;
						end
					end
					for r=size(txsypar_tagexcl_ext,1):size(obj_tagexcl_ext,1)
						for c=size(txsypar_tagexcl_ext,2):size(obj_tagexcl_ext,2)
							txsypar_tagexcl_ext(r,c)		= tag_empty;
						end
					end
					% Compare:
					delete_tag_inexcl	= true;
					if delete_tag_inexcl
						for r=1:size(obj_tagincl_ext,1)
							for c=1:size(obj_tagincl_ext,2)
								if ~isequal(obj_tagincl_ext(r,c),txsypar_tagincl_ext(r,c))
									delete_tag_inexcl	= false;
									break
								end
							end
							if ~delete_tag_inexcl
								break
							end
						end
					end
					if delete_tag_inexcl
						for r=1:size(obj_tagexcl_ext,1)
							for c=1:size(obj_tagexcl_ext,2)
								if ~isequal(obj_tagexcl_ext(r,c),txsypar_tagexcl_ext(r,c))
									delete_tag_inexcl	= false;
									break
								end
							end
							if ~delete_tag_inexcl
								break
							end
						end
					end
				end
				% If the tags are empty or equal to the objects tags: delete the fields tag_incl/tag_excl:
				if delete_tag_inexcl
					PP_obj_ext(iobj,1).symbolpar	= rmfield(PP_obj_ext(iobj,1).symbolpar,'tag_incl');
					PP_obj_ext(iobj,1).symbolpar	= rmfield(PP_obj_ext(iobj,1).symbolpar,'tag_excl');
				else
					fprintf(1,'ObjNo=%g: special include and exclude tags of symbols\n',iobj);
				end
			end
			
		end
	end
	PP_temp.obj	= PP_obj_ext;
	
	% Set display depending on minscale and maxscale:
	for iobj=1:size(PP_temp.obj,1)
		if ~isempty(PP_temp.obj(iobj,1).display)
			if PP_temp.obj(iobj,1).textpar.minscale==-1
				PP_temp.obj(iobj,1).textpar.minscale	= PP_temp.obj(iobj,1).minscale;
			end
			if PP_temp.obj(iobj,1).textpar.maxscale==-1
				PP_temp.obj(iobj,1).textpar.maxscale	= PP_temp.obj(iobj,1).maxscale;
			end
			if PP_temp.obj(iobj,1).symbolpar.minscale==-1
				PP_temp.obj(iobj,1).symbolpar.minscale	= PP_temp.obj(iobj,1).minscale;
			end
			if PP_temp.obj(iobj,1).symbolpar.maxscale==-1
				PP_temp.obj(iobj,1).symbolpar.maxscale	= PP_temp.obj(iobj,1).maxscale;
			end
			if    (PP_temp.project.scale<PP_temp.obj(iobj,1).minscale)||...
					(PP_temp.project.scale>PP_temp.obj(iobj,1).maxscale)
				PP_temp.obj(iobj,1).display	= 0;
			end
			if    (PP_temp.project.scale<PP_temp.obj(iobj,1).textpar.minscale)||...
					(PP_temp.project.scale>PP_temp.obj(iobj,1).textpar.maxscale)
				PP_temp.obj(iobj,1).textpar.display	= 0;
			end
			if    (PP_temp.project.scale<PP_temp.obj(iobj,1).symbolpar.minscale)||...
					(PP_temp.project.scale>PP_temp.obj(iobj,1).symbolpar.maxscale)
				PP_temp.obj(iobj,1).symbolpar.display	= 0;
			end
		end
	end
	
	% Operator of include and exclude tags: assign default value ('==')
	% All empty keys and values must be characters (not double).
	for iobj=1:size(PP_temp.obj,1)
		if ~isempty(PP_temp.obj(iobj,1).tag_incl)
			varname_tag							= sprintf('obj(%1.0f,1).tag_incl',iobj);
			PP_temp.obj(iobj,1).tag_incl	= tag_inexcl_assign_defop(PP_temp.obj(iobj,1).tag_incl,iobj,varname_tag);
		end
		if ~isempty(PP_temp.obj(iobj,1).tag_excl)
			varname_tag							= sprintf('obj(%1.0f,1).tag_excl',iobj);
			PP_temp.obj(iobj,1).tag_excl	= tag_inexcl_assign_defop(PP_temp.obj(iobj,1).tag_excl,iobj,varname_tag);
		end
		if ~isempty(PP_temp.obj(iobj,1).textpar)
			if isfield(PP_temp.obj(iobj,1).textpar,'tag_incl')
				varname_tag										= sprintf('obj(%1.0f,1).textpar.tag_incl',iobj);
				PP_temp.obj(iobj,1).textpar.tag_incl	= tag_inexcl_assign_defop(...
					PP_temp.obj(iobj,1).textpar.tag_incl,...
					iobj,...
					varname_tag);
			end
			if isfield(PP_temp.obj(iobj,1).textpar,'tag_excl')
				varname_tag										= sprintf('obj(%1.0f,1).textpar.tag_excl',iobj);
				PP_temp.obj(iobj,1).textpar.tag_excl	= tag_inexcl_assign_defop(...
					PP_temp.obj(iobj,1).textpar.tag_excl,...
					iobj,...
					varname_tag);
			end
		end
		if ~isempty(PP_temp.obj(iobj,1).symbolpar)
			if isfield(PP_temp.obj(iobj,1).symbolpar,'tag_incl')
				varname_tag										= sprintf('obj(%1.0f,1).symbolpar.tag_incl',iobj);
				PP_temp.obj(iobj,1).symbolpar.tag_incl	= tag_inexcl_assign_defop(...
					PP_temp.obj(iobj,1).symbolpar.tag_incl,...
					iobj,...
					varname_tag);
			end
			if isfield(PP_temp.obj(iobj,1).symbolpar,'tag_excl')
				varname_tag										= sprintf('obj(%1.0f,1).symbolpar.tag_excl',iobj);
				PP_temp.obj(iobj,1).symbolpar.tag_excl	= tag_inexcl_assign_defop(...
					PP_temp.obj(iobj,1).symbolpar.tag_excl,...
					iobj,...
					varname_tag);
			end
		end
	end
	
	% Priority and color numbers of texts and symbols:
	for iobj=1:size(PP_temp.obj,1)
		if ~isempty(PP_temp.obj(iobj,1).prio)
			if ~isempty(PP_temp.obj(iobj,1).textpar)
				if isequal(PP_temp.obj(iobj,1).textpar.prio,-1)
					PP_temp.obj(iobj,1).textpar.prio					= PP_temp.obj(iobj,1).prio+PP_temp.general.textsymb_prio_offset+1;
				end
			end
			if ~isempty(PP_temp.obj(iobj,1).symbolpar)
				if isequal(PP_temp.obj(iobj,1).symbolpar.prio,-1)
					PP_temp.obj(iobj,1).symbolpar.prio				= PP_temp.obj(iobj,1).prio+PP_temp.general.textsymb_prio_offset+2;
				end
			end
		end
		if ~isempty(PP_temp.obj(iobj,1).color_no_fgd)
			if ~isempty(PP_temp.obj(iobj,1).textpar)
				if isequal(PP_temp.obj(iobj,1).textpar.color_no_letters,-1)
					PP_temp.obj(iobj,1).textpar.color_no_letters		= PP_temp.obj(iobj,1).color_no_fgd;
				end
			end
			if ~isempty(PP_temp.obj(iobj,1).symbolpar)
				if isequal(PP_temp.obj(iobj,1).symbolpar.color_no_symbol,-1)
					PP_temp.obj(iobj,1).symbolpar.color_no_symbol	= PP_temp.obj(iobj,1).color_no_fgd;
				end
			end
		end
		if ~isempty(PP_temp.obj(iobj,1).color_no_bgd)
			if ~isempty(PP_temp.obj(iobj,1).textpar)
				if isequal(PP_temp.obj(iobj,1).textpar.color_no_bgd,-1)
					PP_temp.obj(iobj,1).textpar.color_no_bgd		= PP_temp.obj(iobj,1).color_no_bgd;
				end
			end
			if ~isempty(PP_temp.obj(iobj,1).symbolpar)
				if isequal(PP_temp.obj(iobj,1).symbolpar.color_no_bgd,-1)
					PP_temp.obj(iobj,1).symbolpar.color_no_bgd	= PP_temp.obj(iobj,1).color_no_bgd;
				end
			end
		end
	end
	
	% Check the project parameter values:
	errortext		= verify_pp_values(PP_temp,varname_dataset_no);
	if ~isempty(errortext)
		errormessage(errortext);
	end
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% If there was no error up to this point:
	
	% Reload the map if necessary:
	if recreate_map==1
		globalinits;
	end
	
	% Map legend: assign the legend element default parameters and detect empty rows and columns:
	% (after globalinits)
	GV.pp_legend_element_is_empty_m	= true(size(PP_temp.legend.element));
	for r=1:size(PP_temp.legend.element,1)
		for c=1:size(PP_temp.legend.element,2)
			% Assign the legend element default parameters:
			fndef		= fieldnames(PP_temp.legend.defelement);
			for ifndef=1:size(fndef,1)
				if ~isfield(PP_temp.legend.element(r,c),fndef{ifndef,1})
					PP_temp.legend.element(r,c).(fndef{ifndef,1})	= PP_temp.legend.defelement.(fndef{ifndef,1});
				else
					if isempty(PP_temp.legend.element(r,c).(fndef{ifndef,1}))
						PP_temp.legend.element(r,c).(fndef{ifndef,1})	= PP_temp.legend.defelement.(fndef{ifndef,1});
					end
				end
			end
			% Delete empty rows:
			if ~strcmp(PP_temp.legend.element(r,c).legsymb_type,'empty')
				GV.pp_legend_element_is_empty_m(r,c)	= false;
			else
				% The symbol is empty:
				text_is_empty		= true;
				for itext=1:size(PP_temp.legend.element(r,c).text,1)
					if ~isempty(PP_temp.legend.element(r,c).text{itext,1})
						text_is_empty		= false;
						break
					end
				end
				if ~text_is_empty
					GV.pp_legend_element_is_empty_m(r,c)	= false;
				else
					% The text is empty:
					if ~strcmp(PP_temp.legend.element(r,c).text_type,'empty')
						GV.pp_legend_element_is_empty_m(r,c)	= false;
					end
				end
			end
		end
	end
	GV.pp_legend_element_row_is_empty_v		= all(GV.pp_legend_element_is_empty_m,2);
	GV.pp_legend_element_col_is_empty_v		= all(GV.pp_legend_element_is_empty_m,1);
	
	% If the the map figure does not exist: open or clear map figure (before using MAP_OBJECTS):
	fig_2dmap_exists	= true;
	if ~isfield(GV_H,'fig_2dmap')
		fig_2dmap_exists	= false;
	else
		if ~isfield(GV_H,'ax_2dmap')
			fig_2dmap_exists	= false;
		else
			if isempty(GV_H.fig_2dmap)||isempty(GV_H.ax_2dmap)
				fig_2dmap_exists	= false;
			else
				if ~ishandle(GV_H.fig_2dmap)
					% The figure GV_H.fig_2dmap does not exist:
					fig_2dmap_exists	= false;
				else
					if ~ishandle(GV_H.ax_2dmap)
						% The axis GV_H.ax_2dmap does not exist:
						fig_2dmap_exists	= false;
					else
						% The axis GV_H.ax_2dmap exists:
						if strcmp(GV_H.ax_2dmap.NextPlot,'replace')
							% This error occurred after the project was loaded for the second time without first creating
							% the map. The error could not be reproduced and was therefore not corrected. This leads to a
							% program error in a later step, so the map is recreated to be on the safe side.
							fig_2dmap_exists	= false;
						end
					end
				end
			end
		end
	end
	if ~fig_2dmap_exists||(recreate_map==1)
		create_map_figure;
	end
	
	% If the superelevation has been changed: Calculate the new z-values:
	if recreate_map~=1
		if isfield(GV,'pp_general_superelevation')
			if ~isequal(GV.pp_general_superelevation,PP_temp.general.superelevation)
				K_superelevation	= PP_temp.general.superelevation/GV.pp_general_superelevation;
				if isfield(ELE,'elefiltset')
					for ifs=1:size(ELE.elefiltset,1)
						if isfield(ELE.elefiltset(ifs,1),'zom_mm')
							ELE.elefiltset(ifs,1).zom_mm		= ELE.elefiltset(ifs,1).zom_mm*K_superelevation;
						end
						if isfield(ELE.elefiltset(ifs,1),'zofm_mm')
							ELE.elefiltset(ifs,1).zofm_mm		= ELE.elefiltset(ifs,1).zofm_mm*K_superelevation;
						end
						if isfield(ELE.elefiltset(ifs,1),'zm_mm')
							ELE.elefiltset(ifs,1).zm_mm		= ELE.elefiltset(ifs,1).zm_mm*K_superelevation;
						end
					end
				end
			end
		end
	end
	
	% Assign the structure PP:
	PP		= PP_temp;
	GV.pp_general_scale								= PP.project.scale;
	GV.pp_general_origin_user_lat					= PP.general.origin_user_lat;
	GV.pp_general_origin_user_lon					= PP.general.origin_user_lon;
	GV.pp_general_superelevation					= PP.general.superelevation;
	GV.pp_general_dxy_ele_mm						= PP.general.dxy_ele_mm;
	GV.pp_general_interpolation_method			= PP.general.interpolation_method;
	GV.pp_colorspec_ele_filtset_filtersize		= ones(size(PP.colorspec,1),1);
	GV.pp_colorspec_ele_filtset_sigma			= ones(size(PP.colorspec,1),1);
	for icolspec=1:size(PP.colorspec,1)
		GV.pp_colorspec_ele_filtset_filtersize(icolspec,1)	= PP.colorspec(icolspec,1).ele_filtset.filtersize;
		GV.pp_colorspec_ele_filtset_sigma(icolspec,1)		= PP.colorspec(icolspec,1).ele_filtset.sigma;
	end
	
	% Display the project filename together with the used column:
	GV.varname_dataset_no					= varname_dataset_no;
	display_on_gui('pathfilenames');
	
	% lon,lat-x,y-calculator reset:
	calculator_latlonxy_reset;
	
	% Assign GV.pp_projectfilename: Part of the file name that shows the project name:
	if ~isfield(GV,'pp_projectfilename')
		GV.pp_projectfilename				= validfilename(PP.project.filename);
	else
		if isempty(GV.pp_projectfilename)
			% There is no information about a previously loaded project file:
			GV.pp_projectfilename			= validfilename(PP.project.filename);
		else
			if ~strcmp(GV.pp_projectfilename,PP.project.filename)
				% The loaded project name is not equal to the current project name:
				% Ask which project name should be used:
				answer	= [];
				while isempty(answer)
					% question	= 'Select the project name:';
					question	= sprintf([...
						'The project name in the loaded project parameter\n',...
						'file differs from the current project name:\n',...
						'Current project name: %s\n',...
						'Loaded project name: %s\n',...
						'Select the project name:'],GV.pp_projectfilename,PP.project.filename);
					answer	= questdlg_local(question,'Select project name',...
						PP.project.filename,...
						GV.pp_projectfilename,...
						PP.project.filename);
				end
				GV.pp_projectfilename	= validfilename(answer);
			end
		end
	end
	
	% If the map already exists:
	% When loading the project parameters, the color numbers of the objects could have been changed.
	% The color numbers are also saved together with the map objects: Update the structure MAP_OBJECTS:
	% (If the object numbers have been changed, there will be unexpected results, this is not allowed)
	% ud.color_no
	% ud.color_no_pp
	% ud.dz
	% ud.prio
	% ud.surftype
	% Change also the character styles if they have been changed (with confirmation by the user).
	if fig_2dmap_exists
		abort_on_error		= false;
		ask_user				= true;
		% Set the color of the tile base :
		colno_base			= find([PP.color.prio]==0,1);
		set(GV_H.ax_2dmap,'Color',PP.color(colno_base,1).rgb/255);
		% Modify the map objects:
		for imapobj=1:size(MAP_OBJECTS,1)
			iobj				= MAP_OBJECTS(imapobj,1).iobj;
			% % Testing
			% if imapobj==171
			% 	set_breakpoint	= 1;
			% end
			% % Testing
			if MAP_OBJECTS(imapobj,1).iobj>=0
				% Change map objects that are not previews (iobj>0) and the legend (iobj=0):
				
				% obj_purpose: information about the usage of the object:
				obj_purpose						= [];
				for i=1:length(MAP_OBJECTS(imapobj).h)
					if length(MAP_OBJECTS(imapobj).h(i).UserData)~=1
						errormessage;
					end
					if ~isfield(MAP_OBJECTS(imapobj).h(i).UserData,'obj_purpose')
						% skip object imapobj (probably preview):
						obj_purpose						= [];
						break
					end
					if i==1
						obj_purpose		= MAP_OBJECTS(imapobj).h(i).UserData.obj_purpose;
					end
					if ~isequal(obj_purpose,MAP_OBJECTS(imapobj).h(i).UserData.obj_purpose)
						% Error, that shouldn't happen:
						if ~isdeployed
							errormessage;
						else
							% skip object imapobj:
							obj_purpose						= [];
							break
						end
					end
				end
				if ~isempty(obj_purpose)
					[userdata_pp,textpar_pp,errortext]	= get_pp_mapobjsettings(...
						iobj,...
						MAP_OBJECTS(imapobj,1).disp,...
						obj_purpose);
					if ~isempty(errortext)
						if isfield(GV_H.warndlg,'open_pp')
							if ishandle(GV_H.warndlg.open_pp)
								close(GV_H.warndlg.open_pp);
							end
						end
						msg	= sprintf([...
							'It was not possible to update\n',...
							'the settings of map object\n',...
							'PlotNo=%g (%s).\n',...
							'and maybe others (see diary or log file).\n',...
							'\n',...
							'%s\n',...
							'\n',...
							'The(se) object(s) should be recreated.'],...
							imapobj,MAP_OBJECTS(imapobj,1).disp,errortext);
						GV_H.warndlg.open_pp			= warndlg(msg,'Warning');
						GV_H.warndlg.open_pp.Tag	= 'maplab3d_figure';
						fprintf(1,'----------------------------------------------\n%s\n',msg);
					else
						% No error:
						
						%------------------------------------------------------------------------------------------------
						% Change the userdata and colors of the map objects:
						for i=1:length(MAP_OBJECTS(imapobj).h)
							if length(MAP_OBJECTS(imapobj).h(i).UserData)~=1
								errormessage;
							end
							if isfield(MAP_OBJECTS(imapobj).h(i).UserData,'level')
								if MAP_OBJECTS(imapobj).h(i).UserData.level==0
									% level=0: background:
									prio			= userdata_pp.prio_bgd;
									color_no		= userdata_pp.color_no_bgd;
									surftype		= userdata_pp.surftype_bgd;
									dz				= userdata_pp.dz_bgd;
								else
									% level=1: foreground:
									prio			= userdata_pp.prio_fgd;
									color_no		= userdata_pp.color_no_fgd;
									surftype		= userdata_pp.surftype_fgd;
									dz				= userdata_pp.dz_fgd;
								end
								% ud.color_no:
								if isfield(MAP_OBJECTS(imapobj).h(i).UserData,'color_no')&&~isempty(color_no)
									MAP_OBJECTS(imapobj).h(i).UserData.color_no		= color_no;
									if strcmp(MAP_OBJECTS(imapobj).h(i).Type,'polygon')
										if isequal(color_no,0)
											MAP_OBJECTS(imapobj).h(i).FaceColor		= 'none';
										else
											MAP_OBJECTS(imapobj).h(i).FaceColor		= PP.color(color_no,1).rgb/255;
										end
									end
								end
								% ud.color_no_pp:
								if isfield(MAP_OBJECTS(imapobj).h(i).UserData,'color_no_pp')&&~isempty(color_no)
									MAP_OBJECTS(imapobj).h(i).UserData.color_no_pp	= color_no;
								end
								% ud.dz:
								if isfield(MAP_OBJECTS(imapobj).h(i).UserData,'dz')&&~isempty(dz)
									MAP_OBJECTS(imapobj).h(i).UserData.dz				= dz;
								end
								% ud.prio:
								if isfield(MAP_OBJECTS(imapobj).h(i).UserData,'prio')&&~isempty(prio)
									MAP_OBJECTS(imapobj).h(i).UserData.prio			= prio;
								end
								% ud.surftype:
								if isfield(MAP_OBJECTS(imapobj).h(i).UserData,'surftype')&&~isempty(surftype)
									MAP_OBJECTS(imapobj).h(i).UserData.surftype		= surftype;
								end
							end
							if isfield(MAP_OBJECTS(imapobj).h(i).UserData,'iobj')
								MAP_OBJECTS(imapobj).h(i).UserData.iobj			= iobj;
							end
						end
						
						%------------------------------------------------------------------------------------------------
						% Change the character styles of the map text objects:
						if strcmp(MAP_OBJECTS(imapobj,1).disp,'text')
							charstyle_no_pp		= textpar_pp.charstyle_no;
							charstyle_no_v			= zeros(size(MAP_OBJECTS(imapobj).h,1),1);
							clear charstyle_settings_v
							imapobj_isselected	= false;
							for i=1:length(MAP_OBJECTS(imapobj).h)
								if isfield(MAP_OBJECTS(imapobj).h(i).UserData,'chstno')
									charstyle_no_v(i,1)	= MAP_OBJECTS(imapobj).h(i).UserData.chstno;
								else
									% Error, that shouldn't happen:
									if ~isdeployed
										errormessage;
									else
										% skip object imapobj:
										charstyle_no_v			= [];
										break
									end
								end
								if isfield(MAP_OBJECTS(imapobj).h(i).UserData,'chstsettings')
									charstyle_settings_v(i,1)	= MAP_OBJECTS(imapobj).h(i).UserData.chstsettings;
								else
									% Error, that shouldn't happen:
									if ~isdeployed
										errormessage;
									else
										% skip object imapobj:
										charstyle_settings_v	= [];
										break
									end
								end
								if MAP_OBJECTS(imapobj,1).h(i,1).Selected
									% The object is selected:
									imapobj_isselected	= true;
								end
								if isfield(MAP_OBJECTS(imapobj).h(i).UserData,'iobj')
									MAP_OBJECTS(imapobj).h(i).UserData.iobj			= iobj;
								end
							end
							if ~isempty(charstyle_no_v)&&~isempty(charstyle_settings_v)
								change_text		= false;
								if any(charstyle_no_v~=charstyle_no_pp)
									% The character style number has been changed:
									change_text		= true;
								else
									for i=1:size(charstyle_settings_v,1)
										if ~isequal(charstyle_settings_v(i,1),PP.charstyle(charstyle_no_pp,1))
											% The character style settings have been changed:
											change_text		= true;
											break
										end
									end
								end
								if change_text
									if ask_user
										% User confirmation:
										question	= sprintf([...
											'Text settings have changed (character style numbers\n',...
											'and/or character style settings). You can now update\n',...
											'the texts on the map automatically. In this case,\n',...
											'you should check the position of the texts and,\n',...
											'if necessary, the connection lines afterwards.\n',...
											'\n',...
											'Should the texts on the map be updated automatically?']);
										answer			= '';
										while isempty(answer)
											answer		= questdlg_local(question,...
												'Update texts?','Update all','Skip all','Update all');
										end
										if strcmp(answer,'Skip all')
											break
										end
										ask_user			= false;
									end
									% Change the text:
									plot_modify('change_text',imapobj,'charstyle',charstyle_no_pp,abort_on_error);
									if ~imapobj_isselected
										plot_modify('deselect',imapobj);
									end
								end
							end
						end
					end
					
				end
			end
		end
	end
	
	% Filenames:
	[GV.map_filename,GV.mapdata_filename,~]	= filenames_savefiles('');
	
	% Show path and filenames:
	display_on_gui('pathfilenames');
	
	% Edit map: Faktor between fast/normal/slow move/rotate steps and move mapview steps
	GV.pp_stepwidth_move_object_factor		= PP.general.change_map_stepwidth.move_object_factor;
	GV.pp_stepwidth_rotate_object_factor	= PP.general.change_map_stepwidth.rotate_object_factor;
	GV.pp_stepwidth_move_mapview_small		= PP.general.change_map_stepwidth.move_mapview_small;
	GV.pp_stepwidth_move_mapview_medium		= PP.general.change_map_stepwidth.move_mapview_medium;
	GV.pp_stepwidth_move_mapview_large		= PP.general.change_map_stepwidth.move_mapview_large;
	set_tooltips('move_mapobject');								% set tooltips of move map objects buttons
	set_tooltips('rotate_mapobject');							% set tooltips of rotate map objects buttons
	set_tooltips('move_mapview');									% set tooltips of move mapview buttons
	
	% Maximum number of include and exclude tags:
	GV.pp_obj_incltags_no_row_max		= GV.pp_obj_inclexcltags_no_row_min;
	GV.pp_obj_incltags_no_col_max		= GV.pp_obj_inclexcltags_no_col_min;
	GV.pp_obj_excltags_no_row_max		= GV.pp_obj_inclexcltags_no_row_min;
	GV.pp_obj_excltags_no_col_max		= GV.pp_obj_inclexcltags_no_col_min;
	for iobj=1:size(PP.obj,1)
		if ~isempty(PP.obj(iobj,1).tag_incl)
			GV.pp_obj_incltags_no_row_max		= max(GV.pp_obj_incltags_no_row_max,size(PP.obj(iobj,1).tag_incl,1));
			GV.pp_obj_incltags_no_col_max		= max(GV.pp_obj_incltags_no_col_max,size(PP.obj(iobj,1).tag_incl,2));
		end
		if ~isempty(PP.obj(iobj,1).tag_excl)
			GV.pp_obj_excltags_no_row_max		= max(GV.pp_obj_excltags_no_row_max,size(PP.obj(iobj,1).tag_excl,1));
			GV.pp_obj_excltags_no_col_max		= max(GV.pp_obj_excltags_no_col_max,size(PP.obj(iobj,1).tag_excl,2));
		end
		
		if ~isempty(PP.obj(iobj,1).textpar)
			if isfield(PP.obj(iobj,1).textpar,'tag_incl')
				GV.pp_obj_incltags_no_row_max	= max(GV.pp_obj_incltags_no_row_max,size(PP.obj(iobj,1).textpar.tag_incl,1));
				GV.pp_obj_incltags_no_col_max	= max(GV.pp_obj_incltags_no_col_max,size(PP.obj(iobj,1).textpar.tag_incl,2));
			end
			if isfield(PP.obj(iobj,1).textpar,'tag_excl')
				GV.pp_obj_excltags_no_row_max	= max(GV.pp_obj_excltags_no_row_max,size(PP.obj(iobj,1).textpar.tag_excl,1));
				GV.pp_obj_excltags_no_col_max	= max(GV.pp_obj_excltags_no_col_max,size(PP.obj(iobj,1).textpar.tag_excl,2));
			end
		end
		if ~isempty(PP.obj(iobj,1).symbolpar)
			if isfield(PP.obj(iobj,1).symbolpar,'tag_incl')
				GV.pp_obj_incltags_no_row_max	= max(GV.pp_obj_incltags_no_row_max,size(PP.obj(iobj,1).symbolpar.tag_incl,1));
				GV.pp_obj_incltags_no_col_max	= max(GV.pp_obj_incltags_no_col_max,size(PP.obj(iobj,1).symbolpar.tag_incl,2));
			end
			if isfield(PP.obj(iobj,1).symbolpar,'tag_excl')
				GV.pp_obj_excltags_no_row_max	= max(GV.pp_obj_excltags_no_row_max,size(PP.obj(iobj,1).symbolpar.tag_excl,1));
				GV.pp_obj_excltags_no_col_max	= max(GV.pp_obj_excltags_no_col_max,size(PP.obj(iobj,1).symbolpar.tag_excl,2));
			end
		end
	end
	
	% Initialize the include and exclude tags table:
	set_inclexcltags_table('reset');
	
	% Set the object numbers dropdown menu:
	set_inclexcltags_table('init_objno_dropdown');
	
	% Check if the OSM-data has to be reloaded, because the osmfilter-command has been changed:
	if ~isempty(GV.osmfilter_command)
		if exist([GV.osm_pathname GV.osm_filename],'file')==2
			% The OSM-file has been already loaded, with filtering:
			[osm_filename_filt,osm_pathname_filt,osmfilter_command_new]	= ...
				call_osmfilter(GV.osm_filename,GV.osm_pathname,0);
			if ~strcmp(GV.osmfilter_command,osmfilter_command_new)
				if isfield(GV_H.warndlg,'callosmfilter')
					if ishandle(GV_H.warndlg.callosmfilter)
						close(GV_H.warndlg.callosmfilter);
					end
				end
				msg	= sprintf([...
					'The project parameters have been changed,\n',...
					'so the filtered and loaded OSM-file\n',...
					'%s\n',...
					'%s\n',...
					'maybe does not contain the required data.\n',...
					'Consider to reload the OSM- and elevation-data.\n',...
					'\n',...
					'If you have loaded an OSM-file that has been\n',...
					'FILTERED with osmosis using the include tags,\n',...
					'you may want to re-run osmosis first as well.'],...
					osm_pathname_filt,osm_filename_filt);
				GV_H.warndlg.callosmfilter			= warndlg(msg,'Warning');
				GV_H.warndlg.callosmfilter.Tag	= 'maplab3d_figure';
				
			end
		end
	end
	
	% Overview of the assignment, from which other objects an object is cut:
	save_projpar_summary;
	
	% Plot the printout limits if they don't exist yet:
	% tile_no = 0: Edges of the map to be printed:
	if ~isfield(GV_H,'poly_map_printout')||~isfield(GV_H,'poly_map_printout_obj_limits')
		plot_poly_map_printout;
	else
		if ~isvalid(GV_H.poly_map_printout)||~isvalid(GV_H.poly_map_printout_obj_limits)
			plot_poly_map_printout;
		end
	end
	% Plot the frame:
	% First plot_poly_map_printout must be called!
	plot_2dmap_frame;
	% Maybe the tile origin has changed: Plot the tiles:
	% First plot_2dmap_frame must be called!
	% tile_no = i: Edges of the tiles:
	% The min and max values can be outside the edge of the entire map.
	plot_poly_tiles;
	% Create/modify legend:
	create_legend_mapfigure;
	
	% Execution time:
	t_end_statebusy					= clock;
	dt_statebusy						= etime(t_end_statebusy,t_start_statebusy);
	dt_statebusy_str					= dt_string(dt_statebusy);
	if dt_statebusy>GV.exec_time.open_pp.dt
		GV.exec_time.open_pp.name		= APP.LoadprojectparametersMenu.Text;
		GV.exec_time.open_pp.t_start	= t_start_statebusy;
		GV.exec_time.open_pp.t_end		= t_end_statebusy;
		GV.exec_time.open_pp.dt			= dt_statebusy;
		GV.exec_time.open_pp.dt_str	= dt_statebusy_str;
	end
	
	% Reset waitbar:
	set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
	set(GV_H.text_waitbar,'String','');
	drawnow;
	
	% Display state:
	msg	= sprintf('Loading project parameters ... done (%s).',dt_statebusy_str);
	display_on_gui('state',msg,'notbusy','replace');
	fprintf(1,'%s\n',msg);
	
catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
% extentppobj
%------------------------------------------------------------------------------------------------------------------
function [PP_obj_ext,PP_obj]=extentppobj(PP_obj_ext,PP_obj)

global GV

try
	
	nr			= size(PP_obj,1);
	nc			= size(PP_obj,2);
	nr_ext	= size(PP_obj_ext,1);
	nc_ext	= size(PP_obj_ext,2);
	if iscell(PP_obj)
		% PP_obj is a cell array: consider each element separately:
		for ir=1:nr
			for ic=1:nc
				if (ir<=nr_ext)&&(ic<=nc_ext)
					% The Element PP_obj{ir,ic} exists in PP_obj_ext:
					[  PP_obj_ext{ir,ic},...
						PP_obj{ir,ic}...
						]=extentppobj(...
						PP_obj_ext{ir,ic},...
						PP_obj{ir,ic});
				else
					% The element PP_obj{ir,ic} does not yet exist in PP_obj_ext:
					% Add the element PP_obj{ir,ic} to PP_obj_ext:
					PP_obj_ext{ir,ic}	= PP_obj{ir,ic};
				end
			end
		end
	else
		if ischar(PP_obj)
			% PP_obj is a character array: replace PP_obj_ext by PP_obj:
			% An empty object parameter string does not overwrite a non-empty default object parameter string,
			% so that strings can also be used in the default parameters.
			% If you do not want to use a string entered in the default parameters for a particular object,
			% enter the keyword "delete_defobj_par".
			if ~isempty(PP_obj)
				if strcmp(PP_obj,'delete_defobj_par')
					PP_obj_ext	= '';
				else
					PP_obj_ext	= PP_obj;
				end
			end
		else
			% PP_obj is a numerical array: consider each element separately:
			for ir=1:nr
				for ic=1:nc
					if (ir<=nr_ext)&&(ic<=nc_ext)
						% The Element PP_obj(ir,ic) exists in PP_obj_ext:
						if isstruct(PP_obj(ir,ic))
							% PP_obj(ir,ic) is a structure: repeated call of extentppobj:
							fn_PP_obj		= fieldnames(PP_obj(ir,ic));
							for ifn=1:length(fn_PP_obj)
								if isfield(PP_obj_ext(ir,ic),fn_PP_obj{ifn,1})
									% The field fn_PP_obj{ifn,1} alfn1y exists in PP_obj_ext:
									% Extend the field in PP_obj_ext:
									[  PP_obj_ext(ir,ic).(fn_PP_obj{ifn,1}),...
										PP_obj(ir,ic).(fn_PP_obj{ifn,1})...
										]=extentppobj(...
										PP_obj_ext(ir,ic).(fn_PP_obj{ifn,1}),...
										PP_obj(ir,ic).(fn_PP_obj{ifn,1}));
								else
									% The field fn_PP_obj{ifn,1} does not yet exist in PP_obj_ext:
									% Add the new field to PP_obj_ext:
									PP_obj_ext(ir,ic).(fn_PP_obj{ifn,1})	= PP_obj(ir,ic).(fn_PP_obj{ifn,1});
								end
							end
						else
							% PP_obj(ir,ic) is not a structure: replace PP_obj_ext(ir,ic) by PP_obj(ir,ic):
							% Only not-empty values will be copied.
							if ~isempty(PP_obj(ir,ic))
								PP_obj_ext(ir,ic)	= PP_obj(ir,ic);
							end
						end
					else
						% The element PP_obj(ir,ic) does not yet exist in PP_obj_ext:
						% Add the element PP_obj(ir,ic) to PP_obj_ext:
						if isstruct(PP_obj(ir,ic))
							if    isfield(PP_obj_ext(1,1),'k' )&&...
									isfield(PP_obj_ext(1,1),'op')&&...
									isfield(PP_obj_ext(1,1),'v' )&&...
									isfield(PP_obj(ir,ic)  ,'k' )&&...
									~isfield(PP_obj(ir,ic) ,'op')&&...
									isfield(PP_obj(ir,ic)  ,'v')
								%  tag_incl or tag_excl: add the operator, if not specified:
								PP_obj(ir,ic).op	= '==';
							end
						end
						try
							PP_obj_ext(ir,ic)	= PP_obj(ir,ic);
						catch ME
							
							ir
							ic
							PP_obj_ir_ic	= PP_obj(ir,ic)
							PP_obj_ext
							
							errortext	= sprintf([...
								'Error when loading the project file:\n',...
								'%s\n',...
								'Maybe the project file contains wrong\n',...
								'column numbers (columns C1, C2, C3).'],GV.pp_pathfilename);
							errormessage(errortext,ME);
						end
					end
				end
			end
		end
	end
	
catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
% tag_inexcl_assign_defop
%------------------------------------------------------------------------------------------------------------------
% Operator of include and exclude tags: assign default value ('==')
function tag_inexcl=tag_inexcl_assign_defop(tag_inexcl,iobj,varname_tag)

global GV

try
	
	for r=1:size(tag_inexcl,1)
		for c=1:size(tag_inexcl,2)
			if isempty(tag_inexcl(r,c).k)
				tag_inexcl(r,c).k	= '';
			end
			if isempty(tag_inexcl(r,c).v)
				tag_inexcl(r,c).v	= '';
			end
			if isempty(tag_inexcl(r,c).op)
				tag_inexcl(r,c).op	= '==';
			else
				if  ~(strcmp(tag_inexcl(r,c).op,'>') ||...
						strcmp(tag_inexcl(r,c).op,'<') ||...
						strcmp(tag_inexcl(r,c).op,'>=')||...
						strcmp(tag_inexcl(r,c).op,'>=')||...
						strcmp(tag_inexcl(r,c).op,'~=')||...
						strcmp(tag_inexcl(r,c).op,'==')     )
					errormessage(sprintf([...
						'Error in %s:\n',...
						'Object number %g:\n',...
						'%s(%g,%g).op = %s\n',...
						'is not allowed.',...
						],GV.pp_pathfilename,iobj,varname_tag,r,c,tag_inexcl(r,c).op));
				end
			end
		end
	end
	
catch ME
	errormessage('',ME);
end



%------------------------------------------------------------------------------------------------------------------
% save_projpar_summary
%------------------------------------------------------------------------------------------------------------------
function save_projpar_summary
% Overview of the assignment, from which other objects an object is cut.
% Will be saved as text file.

global PP GV

try
	
	text_str	= sprintf([...
		'Project parameters summary:\n',...
		'Copy the text to a spreadsheet for better readability (for example Excel).\n']);
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Search all project parameters for elements that are displayed on the map:
	% pp_used(i,1).iobj			iobj
	% pp_used(i,1).type			'L'		line
	%									'A'		area
	%									'T'		text
	%									'S'		symbol
	%									''			legend
	% pp_used(i,1).typeno		1			line
	%									2			area
	%									3			text
	%									4			symbol
	%									5			legend
	% pp_used(i,1).liwi			constant line width or minimum line width (999999: no line)
	% pp_used(i,1).liwi_max		constant line width or maximum line width (999999: no line)
	% pp_used(i,1).dz_fgd		dz of the foreground (of lines, areas, texts, symbols)
	% pp_used(i,1).dz_bgd		dz of the background (of lines, areas, texts, symbols)
	% pp_used(i,1).chstno		PP.obj(iobj,1).textpar.charstyle_no (999999: no text)
	% pp_used(i,1).descr			PP.obj(iobj,1).description
	% pp_used(i,1).prio			PP.obj(iobj,1).prio
	% pp_used(i,1).colno			PP.obj(iobj,1).color_no_fgd or PP.obj(iobj,1).color_no_bgd
	% pp_used(i,1).colprio		PP.color(pp_used(i,1).colno,1).prio
	% pp_used(i,1).cb_hp			PP.obj(iobj,1).simplify_lines.cut_by_obj_of_hp
	% pp_used(i,1).c_lp			PP.obj(iobj,1).simplify_lines.cut_obj_of_lp
	
	global pp_used
	
	% Legend default values:
	pp_used_leg							= struct([]);
	pp_used_leg(1,1).iobj			= 0;
	pp_used_leg(1,1).type			= '';
	pp_used_leg(1,1).typeno			= 5;
	pp_used_leg(1,1).liwi			= 999999;
	pp_used_leg(1,1).liwi_max		= 999999;
	pp_used_leg(1,1).dz_fgd			= 999999;
	pp_used_leg(1,1).dz_bgd			= 999999;
	pp_used_leg(1,1).chstno			= 999999;
	pp_used_leg(1,1).descr			= 'legend';
	pp_used_leg(1,1).prio			= 999999;
	pp_used_leg(1,1).colno			= 0;
	pp_used_leg(1,1).colprio		= 999999;
	pp_used_leg(1,1).cb_hp			= 999999;
	pp_used_leg(1,1).c_lp			= 999999;
	pp_used_leg(1,1).minscale		= 999999;
	pp_used_leg(1,1).maxscale		= 999999;
	
	pp_used		= pp_used_leg;
	i				= 0;
	
	% Legend:
	% -	Colors
	% -	Character style numbers
	if ~strcmp(PP.legend.location,'none')
		% Legend background:
		i							= i+1;
		pp_used(i,1)			= pp_used_leg;
		pp_used(i,1).colno	= PP.legend.color_no_bgd;
		if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
			pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
		else
			pp_used(i,1).colprio	= 0;
		end
		% Legend elements:
		for r=1:size(PP.legend.element,1)
			for c=1:size(PP.legend.element,2)
				switch PP.legend.element(r,c).legsymb_type
					case {'keep free','empty'}
						% nop
					case {'map scale bar'}
						% map scale bar:
						i							= i+1;
						pp_used(i,1)			= pp_used_leg;
						pp_used(i,1).colno	= PP.legend.mapscalebar_color_no;
						if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
							pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
						else
							pp_used(i,1).colprio	= 0;
						end
					otherwise
						% line, area, line+symbol, area+symbol, symbol:
						iobj_v		= PP.legend.element(r,c).legsymb_objno{1,1};
						for i_iobj=1:length(iobj_v)
							iobj		= iobj_v(i_iobj);
							if iobj>0
								if (PP.obj(iobj,1).display~=0)&&...
										((PP.obj(iobj,1).display_as_line~=0)||(PP.obj(iobj,1).display_as_area~=0))
									% Line and area background:
									i							= i+1;
									pp_used(i,1)			= pp_used_leg;
									pp_used(i,1).colno	= PP.obj(iobj,1).color_no_bgd;
									if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
										pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
									else
										pp_used(i,1).colprio	= 0;
									end
									if    PP.obj(iobj,1).color_no_fgd~=...
											PP.obj(iobj,1).color_no_bgd
										% Line and area foreground:
										i							= i+1;
										pp_used(i,1)			= pp_used_leg;
										pp_used(i,1).colno	= PP.obj(iobj,1).color_no_fgd;
										if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
											pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
										else
											pp_used(i,1).colprio	= 0;
										end
									end
								end
								if (PP.obj(iobj,1).symbolpar.display~=0)
									% Symbol background:
									i							= i+1;
									pp_used(i,1)			= pp_used_leg;
									pp_used(i,1).colno	= PP.obj(iobj,1).symbolpar.color_no_bgd;
									if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
										pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
									else
										pp_used(i,1).colprio	= 0;
									end
									if    PP.obj(iobj,1).symbolpar.color_no_symbol    ~=...
											PP.obj(iobj,1).symbolpar.color_no_bgd
										% Symbol foreground:
										i							= i+1;
										pp_used(i,1)			= pp_used_leg;
										pp_used(i,1).colno	= PP.obj(iobj,1).symbolpar.color_no_symbol;
										if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
											pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
										else
											pp_used(i,1).colprio	= 0;
										end
									end
								end
							elseif ~isempty(PP.legend.element(r,c).legsymb_mansel_key)&&...
									~isempty(PP.legend.element(r,c).legsymb_mansel_val)&&...
									contains(PP.legend.element(r,c).legsymb_type,'symbol')
								% Manually selected symbol background:
								i							= i+1;
								pp_used(i,1)			= pp_used_leg;
								pp_used(i,1).colno	= PP.legend.element(r,c).legsymb_mansel_color_no_bgd;
								if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
									pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
								else
									pp_used(i,1).colprio	= 0;
								end
								if    PP.legend.element(r,c).legsymb_mansel_color_no_sym~=...
										PP.legend.element(r,c).legsymb_mansel_color_no_bgd
									% Manually selected symbol foreground:
									i							= i+1;
									pp_used(i,1)			= pp_used_leg;
									pp_used(i,1).colno	= PP.legend.element(r,c).legsymb_mansel_color_no_sym;
									if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
										pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
									else
										pp_used(i,1).colprio	= 0;
									end
								end
							end
						end
				end
				notisempty_text	= false;
				for i_text=1:size(PP.legend.element(r,c).text,1)
					if ~isempty(PP.legend.element(r,c).text{i_text,1})
						notisempty_text	= true;
						break
					end
				end
				if notisempty_text
					% Text background:
					i							= i+1;
					pp_used(i,1)			= pp_used_leg;
					pp_used(i,1).chstno	= PP.legend.element(r,c).text_charstyle_no;
					pp_used(i,1).colno	= PP.legend.element(r,c).text_color_no_background;
					if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
						pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
					else
						pp_used(i,1).colprio	= 0;
					end
					if    PP.legend.element(r,c).text_color_no_letters   ~=...
							PP.legend.element(r,c).text_color_no_background
						% Text foreground:
						i							= i+1;
						pp_used(i,1)			= pp_used_leg;
						pp_used(i,1).chstno	= PP.legend.element(r,c).text_charstyle_no;
						pp_used(i,1).colno	= PP.legend.element(r,c).text_color_no_letters;
						if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
							pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
						else
							pp_used(i,1).colprio	= 0;
						end
					end
				end
			end
		end
	end
	% Delete duplicate legend entries with the same color number and the same character style:
	[~,isort_v]		= sort([pp_used.colno]);
	pp_used			= pp_used(isort_v,:);
	idelete_v		= false(size(pp_used));
	for i=1:size(pp_used,1)
		if ~idelete_v(i,1)
			idelete_i_v			= ([pp_used.colno]'==pp_used(i,1).colno)&([pp_used.chstno]'==pp_used(i,1).chstno);
			idelete_i_v(i,1)	= false;
			idelete_v			= idelete_v|idelete_i_v;
		end
	end
	pp_used(idelete_v,:)	= [];
	
	% Map objects:
	i		= size(pp_used,1);
	for iobj=1:size(PP.obj,1)
		if ~isempty(PP.obj(iobj,1).display)
			% If this object number exists:
			if (PP.obj(iobj,1).display~=0)
				if PP.obj(iobj,1).color_no_fgd==PP.obj(iobj,1).color_no_bgd
					level_max	= 0;
				else
					level_max	= 1;
				end
				if PP.obj(iobj,1).display_as_line~=0
					for level=0:level_max
						i								= i+1;
						pp_used(i,1).iobj			= iobj;
						pp_used(i,1).type			= 'L';
						pp_used(i,1).typeno		= 1;
						pp_used(i,1).minscale	= PP.obj(iobj,1).minscale;
						pp_used(i,1).maxscale	= PP.obj(iobj,1).maxscale;
						[~,~,...
							ud_line,...									% background
							ud_lisy,...									% foreground
							pp_used(i,1).liwi,...					% constant line width or minimum line width
							pp_used(i,1).liwi_max]=...				% constant line width or maximum line width
							line2poly(...
							[],...										% x
							[],...										% y
							PP.obj(iobj).linepar,...				% par
							PP.obj(iobj).linestyle,...				% style
							iobj,...										% iobj
							{'map object'});							% obj_purpose
						if isempty(ud_lisy)
							pp_used(i,1).dz_fgd	= [];
						else
							pp_used(i,1).dz_fgd	= ud_lisy.dz;
						end
						if isempty(ud_line)
							pp_used(i,1).dz_bgd	= [];
						else
							pp_used(i,1).dz_bgd	= ud_line.dz;
						end
						pp_used(i,1).chstno	= 999999;
						pp_used(i,1).descr	= PP.obj(iobj,1).description;
						pp_used(i,1).prio		= PP.obj(iobj,1).prio;
						if level==0
							pp_used(i,1).colno	= PP.obj(iobj,1).color_no_bgd;
						else
							pp_used(i,1).colno	= PP.obj(iobj,1).color_no_fgd;
						end
						if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
							pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
						else
							pp_used(i,1).colprio	= 0;
						end
						pp_used(i,1).cb_hp	= PP.obj(iobj,1).simplify_lines.cut_by_obj_of_hp{1,1};
						pp_used(i,1).c_lp		= PP.obj(iobj,1).simplify_lines.cut_obj_of_lp{1,1};
					end
				end
				if PP.obj(iobj,1).display_as_area~=0
					for level=0:level_max
						i								= i+1;
						pp_used(i,1).iobj			= iobj;
						pp_used(i,1).type			= 'A';
						pp_used(i,1).typeno		= 2;
						pp_used(i,1).minscale	= PP.obj(iobj,1).minscale;
						pp_used(i,1).maxscale	= PP.obj(iobj,1).maxscale;
						pp_used(i,1).liwi			= 999999;
						pp_used(i,1).liwi_max	= 999999;
						[~,~,...
							ud_area,...									% background
							ud_arsy...									% foreground
							]=area2poly(...
							polyshape(),...							% polyin
							PP.obj(iobj).areapar,...				% par
							PP.obj(iobj).areastyle,...				% style
							iobj,...										% iobj
							{'map object'});							% obj_purpose
						if isempty(ud_arsy)
							pp_used(i,1).dz_fgd	= [];
						else
							pp_used(i,1).dz_fgd	= ud_arsy.dz;
						end
						if isempty(ud_area)
							pp_used(i,1).dz_bgd	= [];
						else
							pp_used(i,1).dz_bgd	= ud_area.dz;
						end
						pp_used(i,1).chstno	= 999999;
						pp_used(i,1).descr	= PP.obj(iobj,1).description;
						pp_used(i,1).prio		= PP.obj(iobj,1).prio;
						if level==0
							pp_used(i,1).colno	= PP.obj(iobj,1).color_no_bgd;
						else
							pp_used(i,1).colno	= PP.obj(iobj,1).color_no_fgd;
						end
						if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
							pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
						else
							pp_used(i,1).colprio	= 0;
						end
						pp_used(i,1).cb_hp	= PP.obj(iobj,1).simplify_areas.cut_by_obj_of_hp{1,1};
						pp_used(i,1).c_lp		= PP.obj(iobj,1).simplify_areas.cut_obj_of_lp{1,1};
					end
				end
			end
			if (PP.obj(iobj,1).textpar.display~=0)
				if PP.obj(iobj,1).textpar.color_no_letters==PP.obj(iobj,1).textpar.color_no_bgd
					level_max	= 0;
				else
					level_max	= 1;
				end
				for level=0:level_max
					i								= i+1;
					pp_used(i,1).iobj			= iobj;
					pp_used(i,1).type			= 'T';
					pp_used(i,1).typeno		= 3;
					pp_used(i,1).liwi			= 999999;
					pp_used(i,1).liwi_max	= 999999;
					pp_used(i,1).minscale	= PP.obj(iobj,1).textpar.minscale;
					pp_used(i,1).maxscale	= PP.obj(iobj,1).textpar.maxscale;
					pp_used(i,1).dz_fgd		= PP.obj(iobj,1).textpar.dz_letters;
					pp_used(i,1).dz_bgd		= PP.obj(iobj,1).textpar.dz_bgd;
					pp_used(i,1).chstno		= PP.obj(iobj,1).textpar.charstyle_no;
					pp_used(i,1).descr		= PP.obj(iobj,1).description;
					pp_used(i,1).prio			= PP.obj(iobj,1).textpar.prio;
					if level==0
						pp_used(i,1).colno	= PP.obj(iobj,1).textpar.color_no_bgd;
					else
						pp_used(i,1).colno	= PP.obj(iobj,1).textpar.color_no_letters;
					end
					if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
						pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
					else
						pp_used(i,1).colprio	= 0;
					end
					pp_used(i,1).cb_hp	= PP.obj(iobj,1).textpar.cut_by_obj_of_hp{1,1};
					pp_used(i,1).c_lp		= PP.obj(iobj,1).textpar.cut_obj_of_lp{1,1};
				end
			end
			if (PP.obj(iobj,1).symbolpar.display~=0)
				if PP.obj(iobj,1).symbolpar.color_no_symbol==PP.obj(iobj,1).symbolpar.color_no_bgd
					level_max	= 0;
				else
					level_max	= 1;
				end
				for level=0:level_max
					i								= i+1;
					pp_used(i,1).iobj			= iobj;
					pp_used(i,1).type			= 'S';
					pp_used(i,1).typeno		= 4;
					pp_used(i,1).minscale	= PP.obj(iobj,1).symbolpar.minscale;
					pp_used(i,1).maxscale	= PP.obj(iobj,1).symbolpar.maxscale;
					pp_used(i,1).liwi			= 999999;
					pp_used(i,1).liwi_max	= 999999;
					pp_used(i,1).dz_fgd		= PP.obj(iobj,1).symbolpar.dz_symbol;
					pp_used(i,1).dz_bgd		= PP.obj(iobj,1).symbolpar.dz_bgd;
					pp_used(i,1).chstno		= 999999;
					pp_used(i,1).descr		= PP.obj(iobj,1).description;
					pp_used(i,1).prio			= PP.obj(iobj,1).symbolpar.prio;
					if level==0
						pp_used(i,1).colno	= PP.obj(iobj,1).symbolpar.color_no_bgd;
					else
						pp_used(i,1).colno	= PP.obj(iobj,1).symbolpar.color_no_symbol;
					end
					if (pp_used(i,1).colno>0)&&(pp_used(i,1).colno<size(PP.color,1))
						pp_used(i,1).colprio	= PP.color(pp_used(i,1).colno,1).prio;
					else
						pp_used(i,1).colprio	= 0;
					end
					pp_used(i,1).cb_hp	= PP.obj(iobj,1).symbolpar.cut_by_obj_of_hp{1,1};
					pp_used(i,1).c_lp		= PP.obj(iobj,1).symbolpar.cut_obj_of_lp{1,1};
				end
			end
		end
	end
	for i=1:size(pp_used,1)
		fn		= fieldnames(pp_used(i,1));
		for ifn=1:size(fn,1)
			if isempty(pp_used(i,1).(fn{ifn,1}))&&~strcmp(fn{ifn,1},'type')&&~strcmp(fn{ifn,1},'descr')
				pp_used(i,1).(fn{ifn,1})	= 999999;
			end
		end
	end
	
	%------------------------------------------------------------------------------------------------------------------
	% Colors:
	text_str	= sprintf('%s\n\n',text_str);
	text_str	= sprintf('%sColors:\n',text_str);
	text_str	= sprintf('%sRowNo\tColNo\tObjNo\tColSpec\tColPrio\tDescr\tType\tLink\n',text_str);
	[~,isort_v] = sort([pp_used.typeno]);
	pp_used		= pp_used(isort_v,:);
	[~,isort_v] = sort([pp_used.iobj]);
	pp_used		= pp_used(isort_v,:);
	[~,isort_v] = sort([pp_used.colno]);
	pp_used		= pp_used(isort_v,:);
	% All colors:
	colno			= 1;
	for i=1:size(pp_used,1)
		if pp_used(i,1).colno>0
			while colno<=pp_used(i,1).colno
				text_str	= sprintf('%s%s\t%s\t\t%s\t%s\t%s: %s %s\t\t%s\n',text_str,...
					number2str(PP.TABLE_ROWNO.color(colno,1).prio,'%g'),...
					number2str(colno,'%g'),...
					number2str(PP.color(colno,1).spec,'%g'),...
					number2str(PP.color(colno,1).prio,'%g'),...
					PP.color(colno,1).description,...
					PP.color(colno,1).brand,...
					PP.color(colno,1).color_short_text,...
					PP.color(colno,1).weblink);
				colno		= colno+1;
			end
			text_str	= sprintf('%s\t\t%s\t\t\t%s\t%s\n',text_str,...
				number2str(pp_used(i,1).iobj,'%g'),...
				pp_used(i,1).descr,...
				pp_used(i,1).type);
		end
	end
	while colno<=size(PP.color,1)
		text_str	= sprintf('%s%s\t%s\t\t%s\t%s\t%s: %s %s\t\t%s\n',text_str,...
			number2str(PP.TABLE_ROWNO.color(colno,1).prio,'%g'),...
			number2str(colno,'%g'),...
			number2str(PP.color(colno,1).spec,'%g'),...
			number2str(PP.color(colno,1).prio,'%g'),...
			PP.color(colno,1).description,...
			PP.color(colno,1).brand,...
			PP.color(colno,1).color_short_text,...
			PP.color(colno,1).weblink);
		colno		= colno+1;
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Colorspecs:
	text_str	= sprintf('%s\n\n',text_str);
	text_str	= sprintf('%sColorspecs:\n',text_str);
	text_str	= sprintf('%sRowNo\tColSpec\t\tColNo\tColPrio\tDescr\n',text_str);
	for icolspec=1:size(PP.colorspec,1)
		text_str	= sprintf('%s%s\t%s\t\t\t\t%s\n',text_str,...
			number2str(PP.TABLE_ROWNO.colorspec(icolspec,1).description,'%g'),...
			number2str(icolspec,'%g'),...
			PP.colorspec(icolspec,1).description);
		for colno=1:size(PP.color,1)
			if icolspec==PP.color(colno,1).spec
				text_str	= sprintf('%s\t\t\t%s\t%s\t%s\n',text_str,...
					number2str(colno,'%g'),...
					number2str(PP.color(colno,1).prio,'%g'),...
					PP.color(colno,1).description);
			end
		end
	end
	
	%------------------------------------------------------------------------------------------------------------------
	% Lines:
	text_str	= sprintf('%s\n\n',text_str);
	text_str	= sprintf('%sLines:\n',text_str);
	text_str	= sprintf('%sRowNo\tLinewidth\tObjNo\tdz_fgd\tdz_bgd\tDescr\tType\n',text_str);
	[~,isort_v] = sort([pp_used.iobj]);
	pp_used		= pp_used(isort_v,:);
	[~,isort_v] = sort([pp_used.liwi]);
	pp_used		= pp_used(isort_v,:);
	for i=1:size(pp_used,1)
		if strcmp(pp_used(i,1).type,'L')
			iobj		= pp_used(i,1).iobj;
			if pp_used(i,1).dz_fgd==999999
				dz_fgd_str	= '';
			else
				dz_fgd_str	= number2str(pp_used(i,1).dz_fgd,'%g');
			end
			if pp_used(i,1).dz_bgd==999999
				dz_bgd_str	= '';
			else
				dz_bgd_str	= number2str(pp_used(i,1).dz_bgd,'%g');
			end
			if isequal(pp_used(i,1).liwi,pp_used(i,1).liwi_max)
				liwi_str	= number2str(pp_used(i,1).liwi,'%g');
			else
				liwi_str	= sprintf('%s..%s',...
					number2str(pp_used(i,1).liwi    ,'%g'),...
					number2str(pp_used(i,1).liwi_max,'%g')    );
			end
			text_str	= sprintf('%s%s\t%s\t%s\t%s\t%s\t%s\t%s\n',text_str,...
				number2str(PP.TABLE_ROWNO.obj(iobj,1).linepar(1),'%g'),...
				liwi_str,...
				number2str(iobj,'%g'),...
				dz_fgd_str,...
				dz_bgd_str,...
				pp_used(i,1).descr,...
				pp_used(i,1).type);
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Areas:
	text_str	= sprintf('%s\n\n',text_str);
	text_str	= sprintf('%sAreas:\n',text_str);
	text_str	= sprintf('%sRowNo\t\tObjNo\tdz_fgd\tdz_bgd\tDescr\tType\n',text_str);
	[~,isort_v] = sort([pp_used.iobj]);
	pp_used		= pp_used(isort_v,:);
	for i=1:size(pp_used,1)
		if strcmp(pp_used(i,1).type,'A')
			iobj		= pp_used(i,1).iobj;
			if pp_used(i,1).dz_fgd==999999
				dz_fgd_str	= '';
			else
				dz_fgd_str	= number2str(pp_used(i,1).dz_fgd,'%g');
			end
			if pp_used(i,1).dz_bgd==999999
				dz_bgd_str	= '';
			else
				dz_bgd_str	= number2str(pp_used(i,1).dz_bgd,'%g');
			end
			text_str	= sprintf('%s%s\t\t%s\t%s\t%s\t%s\t%s\n',text_str,...
				number2str(PP.TABLE_ROWNO.obj(iobj,1).areapar(1),'%g'),...
				number2str(iobj,'%g'),...
				dz_fgd_str,...
				dz_bgd_str,...
				pp_used(i,1).descr,...
				pp_used(i,1).type);
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Texts and all character styles:
	text_str	= sprintf('%s\n\n',text_str);
	text_str	= sprintf('%sTexts and character styles:\n',text_str);
	text_str	= sprintf('%sRowNo\tCharstyleNo\tObjNo\tdz_fgd\tdz_bgd\tDescr\tType\n',text_str);
	[~,isort_v] = sort([pp_used.typeno]);
	pp_used		= pp_used(isort_v,:);
	[~,isort_v] = sort([pp_used.iobj]);
	pp_used		= pp_used(isort_v,:);
	[~,isort_v] = sort([pp_used.chstno]);
	pp_used		= pp_used(isort_v,:);
	chstno		= 1;
	for i=1:size(pp_used,1)
		if pp_used(i,1).chstno~=999999
			while chstno<=pp_used(i,1).chstno
				text_str	= sprintf('%s%s\t%s\t\t\t\t%s\n',text_str,...
					number2str(PP.TABLE_ROWNO.charstyle(chstno,1).description,'%g'),...
					number2str(chstno,'%g'),...
					PP.charstyle(chstno,1).description);
				chstno		= chstno+1;
			end
			if pp_used(i,1).dz_fgd==999999
				dz_fgd_str	= '';
			else
				dz_fgd_str	= number2str(pp_used(i,1).dz_fgd,'%g');
			end
			if pp_used(i,1).dz_bgd==999999
				dz_bgd_str	= '';
			else
				dz_bgd_str	= number2str(pp_used(i,1).dz_bgd,'%g');
			end
			text_str	= sprintf('%s\t\t%s\t%s\t%s\t%s\t%s\n',text_str,...
				number2str(pp_used(i,1).iobj,'%g'),...
				dz_fgd_str,...
				dz_bgd_str,...
				pp_used(i,1).descr,...
				pp_used(i,1).type);
		end
	end
	while chstno<=size(PP.charstyle,1)
		text_str	= sprintf('%s%s\t%s\t\t\t\t%s\n',text_str,...
			number2str(PP.TABLE_ROWNO.charstyle(chstno,1).description,'%g'),...
			number2str(chstno,'%g'),...
			PP.charstyle(chstno,1).description);
		chstno		= chstno+1;
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Symbols:
	text_str	= sprintf('%s\n\n',text_str);
	text_str	= sprintf('%sSymbols:\n',text_str);
	text_str	= sprintf('%s\t\tObjNo\tdz_fgd\tdz_bgd\tDescr\tType\n',text_str);
	[~,isort_v] = sort([pp_used.typeno]);
	pp_used		= pp_used(isort_v,:);
	[~,isort_v] = sort([pp_used.iobj]);
	pp_used		= pp_used(isort_v,:);
	for i=1:size(pp_used,1)
		if strcmp(pp_used(i,1).type,'S')
			if pp_used(i,1).dz_fgd==999999
				dz_fgd_str	= '';
			else
				dz_fgd_str	= number2str(pp_used(i,1).dz_fgd,'%g');
			end
			if pp_used(i,1).dz_bgd==999999
				dz_bgd_str	= '';
			else
				dz_bgd_str	= number2str(pp_used(i,1).dz_bgd,'%g');
			end
			text_str	= sprintf('%s\t\t%s\t%s\t%s\t%s\t%s\n',text_str,...
				number2str(pp_used(i,1).iobj,'%g'),...
				dz_fgd_str,...
				dz_bgd_str,...
				pp_used(i,1).descr,...
				pp_used(i,1).type);
		end
	end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Scale range:
	
	% Object numbers specified als legend symbol:
	legsymb_objno_all				= [];
	for r=1:size(PP.legend.element,1)
		for c=1:size(PP.legend.element,2)
			if    ~strcmp(PP.legend.element(r,c).legsymb_type,'keep free')&&...
					~strcmp(PP.legend.element(r,c).legsymb_type,'empty')
				legsymb_objno_all		= [legsymb_objno_all;PP.legend.element(r,c).legsymb_objno{1,1}(:)];
			end
		end
	end
	
	% Show all project parameters:
	text_str	= sprintf('%s\n\n',text_str);
	text_str	= sprintf('%sScale range, all objects:\n',text_str);
	text_str	= sprintf('%sCurrent scale: %g\n',text_str,PP.project.scale);
	text_str	= sprintf([...
		'%sThe scale of texts and symbols is only listed ',...
		'if it differs from the scale for lines and areas.\n'],text_str);
	text_str	= sprintf('%sRowNo\tObjPrio\tObjNo\tMinScale\tMaxScale\tDescr\tType\tNumber of uses in the legend\n',text_str);
	for iobj=1:size(PP.obj,1)
		if ~isempty(PP.obj(iobj,1).display)
			% If this object number exists:
			no_uses_legend	= length(find(legsymb_objno_all==iobj));
			% Lines and Areas:
			type_str		= '';
			if PP.obj(iobj,1).display_as_line~=0
				type_str		= [type_str 'L'];
			end
			if PP.obj(iobj,1).display_as_area~=0
				type_str		= [type_str 'A'];
			end
			text_str	= sprintf('%s%g\t%s\t%s\t%s\t%s\t%s\t%s\t%g',text_str,...
				PP.TABLE_ROWNO.obj(iobj,1).display,...
				number2str(PP.obj(iobj,1).prio,'%g'),...
				number2str(iobj,'%g'),...
				number2str(PP.obj(iobj,1).minscale,'%1.0f'),...
				number2str(PP.obj(iobj,1).maxscale,'%1.0f'),...
				PP.obj(iobj,1).description,...
				type_str,...
				no_uses_legend);
			if    (PP.project.scale<PP.obj(iobj,1).minscale)||...
					(PP.project.scale>PP.obj(iobj,1).maxscale)
				text_str	= sprintf('%s\tThe current scale is outside the specified range.\n',text_str);
			else
				text_str	= sprintf('%s\n',text_str);
			end
			% Texts:
			if isfield(PP.TABLE_ROWNO.obj(iobj,1).textpar,'display')&&(...
					(PP.obj(iobj,1).minscale~=PP.obj(iobj,1).textpar.minscale)||...
					(PP.obj(iobj,1).maxscale~=PP.obj(iobj,1).textpar.maxscale)     )
				text_str	= sprintf('%s%g\t%s\t%s\t%s\t%s\t\t%s\t%g',text_str,...
					PP.TABLE_ROWNO.obj(iobj,1).textpar.display,...
					number2str(PP.obj(iobj,1).textpar.prio,'%g'),...
					number2str(iobj,'%g'),...
					number2str(PP.obj(iobj,1).textpar.minscale,'%1.0f'),...
					number2str(PP.obj(iobj,1).textpar.maxscale,'%1.0f'),...
					'T',...
					no_uses_legend);
				if    (PP.project.scale<PP.obj(iobj,1).textpar.minscale)||...
						(PP.project.scale>PP.obj(iobj,1).textpar.maxscale)
					text_str	= sprintf('%s\tThe current scale is outside the specified range.\n',text_str);
				else
					text_str	= sprintf('%s\n',text_str);
				end
			end
			% Symbols:
			if isfield(PP.TABLE_ROWNO.obj(iobj,1).symbolpar,'display')&&(...
					(PP.obj(iobj,1).minscale~=PP.obj(iobj,1).symbolpar.minscale)||...
					(PP.obj(iobj,1).maxscale~=PP.obj(iobj,1).symbolpar.maxscale)     )
				text_str	= sprintf('%s%g\t%s\t%s\t%s\t%s\t\t%s\t%g',text_str,...
					PP.TABLE_ROWNO.obj(iobj,1).symbolpar.display,...
					number2str(PP.obj(iobj,1).symbolpar.prio,'%g'),...
					number2str(iobj,'%g'),...
					number2str(PP.obj(iobj,1).symbolpar.minscale,'%1.0f'),...
					number2str(PP.obj(iobj,1).symbolpar.maxscale,'%1.0f'),...
					'S',...
					no_uses_legend);
				if    (PP.project.scale<PP.obj(iobj,1).symbolpar.minscale)||...
						(PP.project.scale>PP.obj(iobj,1).symbolpar.maxscale)
					text_str	= sprintf('%s\tThe current scale is outside the specified range.\n',text_str);
				else
					text_str	= sprintf('%s\n',text_str);
				end
			end
		end
	end
	
	% Show only used project parameters:
	% text_str	= sprintf('%s\n\n',text_str);
	% text_str	= sprintf('%sScale range:\n',text_str);
	% text_str	= sprintf('%sCurrent scale: %g\n',text_str,PP.project.scale);
	% text_str	= sprintf('%sdisplay\n',text_str);
	% text_str	= sprintf('%sRowNo\tType\tObjNo\tMinScale\tMaxScale\tDescr\n',text_str);
	% for i=1:size(pp_used,1)
	% 	if pp_used(i,1).iobj>0
	% 		iobj		= pp_used(i,1).iobj;
	% 		rowno		= [];
	% 		switch pp_used(i,1).type
	% 			case 'L'
	% 				rowno		= PP.TABLE_ROWNO.obj(iobj,1).display;
	% 			case 'A'
	% 				rowno		= PP.TABLE_ROWNO.obj(iobj,1).display;
	% 			case 'T'
	% 				if isfield(PP.TABLE_ROWNO.obj(iobj,1).textpar,'display')
	% 					rowno		= PP.TABLE_ROWNO.obj(iobj,1).textpar.display;
	% 				end
	% 			case 'S'
	% 				if isfield(PP.TABLE_ROWNO.obj(iobj,1).symbolpar,'display')
	% 					rowno		= PP.TABLE_ROWNO.obj(iobj,1).symbolpar.display;
	% 				end
	% 		end
	% 		text_str	= sprintf('%s%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s',text_str,...
	% 			number2str(rowno,'%g'),...
	% 			pp_used(i,1).type,...
	% 			number2str(iobj,'%g'),...
	% 			number2str(pp_used(i,1).minscale,'%g'),...
	% 			number2str(pp_used(i,1).maxscale,'%g'),...
	% 			pp_used(i,1).descr);
	% 		if    (PP.project.scale<pp_used(i,1).minscale)||...
	% 				(PP.project.scale>pp_used(i,1).maxscale)
	% 			text_str	= sprintf('%s\tThe scale is outside the specified range.',text_str);
	% 		else
	% 			text_str	= sprintf('%s\n',text_str);
	% 		end
	% 	end
	% end
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Object priorities:
	
	% Sort objects by object priority:
	[~,i]		= sort([pp_used(:,1).prio]);
	pp_used	= pp_used(i,1);
	
	cut_by_obj_of_hp			= struct;
	cut_obj_of_lp				= struct;
	headline_cb_hp_1			= 'is cut by object (C: because of the color priority)';
	headline_c_lp_1			= 'cuts object (C: because of color the priority)';
	headline_iobj				= '';
	headline_type				= '';
	for i1=1:size(pp_used,1)
		% i1: Object with lower priority:
		if pp_used(i1,1).iobj>0
			headline_cb_hp_1				= sprintf('%s\t',headline_cb_hp_1);
			headline_iobj					= sprintf('%s%s\t',headline_iobj,number2str(pp_used(i1,1).iobj,'%g'));
			headline_type					= sprintf('%s%s\t',headline_type,pp_used(i1,1).type);
			cut_by_obj_of_hp(i1,1).str	= '';
			cut_obj_of_lp(i1,1).str		= '';
			for i2=1:size(pp_used,1)
				% i2: Object with higher priority:
				if pp_used(i2,1).iobj>0
					% Object 1 (row) is cut by object 2 (column):
					if pp_used(i1,1).colno>0
						isnonstandalone_1		= (PP.color(pp_used(i1,1).colno,1).standalone_color==0);
					else
						isnonstandalone_1		= true;		% colno_1=0: object 1 is cut by object 2
					end
					if pp_used(i2,1).colno>0
						isnonstandalone_2		= (PP.color(pp_used(i2,1).colno,1).standalone_color==0);
					else
						isnonstandalone_2		= true;		% colno_2=0: object 1 is not cut by object 2
					end
					obj1_iscutby_obj2		= ...
						isnonstandalone_1||(...				% Always cut up non-stand-alone colors or colno=0
						~isnonstandalone_2&&...				% Never let stand-alone colors be cut by non-stand-alone colors or colno=0
						(isequal(pp_used(i1,1).cb_hp,-1)||any(pp_used(i1,1).cb_hp==pp_used(i2,1).iobj))&&...		% 1 is cut by 2 and
						(isequal(pp_used(i2,1).c_lp ,-1)||any(pp_used(i2,1).c_lp ==pp_used(i1,1).iobj))     );		% 2 cuts 1
					if i1~=i2
						if    (pp_used(i2,1).prio>pp_used(i1,1).prio)       &&...	% Prio 2 > Prio 1								and
								(pp_used(i1,1).colno)~=(pp_used(i2,1).colno)  &&...	% color numbers are not equal				and
								(pp_used(i2,1).colno~=0)                      &&...	% color number 2 is not zero				and
								(obj1_iscutby_obj2||...											% ( (1 is cut by 2 and 2 cuts 1 ) or
								(pp_used(i1,1).colprio>pp_used(i2,1).colprio))			%   (Color Prio 1 > Color Prio 2)    )
							if pp_used(i1,1).colprio>pp_used(i2,1).colprio
								reason	= 'C';
							end
							if obj1_iscutby_obj2
								reason	= 'X';
							end
							cut_by_obj_of_hp(i1,1).str	= sprintf('%s\t%s',cut_by_obj_of_hp(i1,1).str,reason);
						else
							cut_by_obj_of_hp(i1,1).str	= sprintf('%s\t',cut_by_obj_of_hp(i1,1).str);
						end
					else
						cut_by_obj_of_hp(i1,1).str		= sprintf('%s\t%s',cut_by_obj_of_hp(i1,1).str,'\');
					end
					% Object 1 (row) cuts object 2 (column):
					obj2_iscutby_obj1		= ...
						isnonstandalone_2||(...				% Always cut up non-stand-alone colors or colno=0
						~isnonstandalone_1&&...				% Never let stand-alone colors be cut by non-stand-alone colors or colno=0
						(isequal(pp_used(i2,1).cb_hp,-1)||any(pp_used(i2,1).cb_hp==pp_used(i1,1).iobj))&&...	% 2 is cut by 1 and
						(isequal(pp_used(i1,1).c_lp ,-1)||any(pp_used(i1,1).c_lp ==pp_used(i2,1).iobj))     );	% 1 cuts 2
					if i1~=i2
						if    (pp_used(i2,1).prio<pp_used(i1,1).prio)       &&...	% Prio 2 < Prio 1								and
								(pp_used(i1,1).colno)~=(pp_used(i2,1).colno)  &&...	% color numbers are not equal				and
								(pp_used(i1,1).colno~=0)                      &&...	% color number 1 is not zero				and
								(obj2_iscutby_obj1||...											% ( (2 is cut by 1 and 1 cuts 2 ) or
								(pp_used(i1,1).colprio<pp_used(i2,1).colprio))			%   (Color Prio 1 < Color Prio 2)    )
							if pp_used(i1,1).colprio<pp_used(i2,1).colprio
								reason	= 'C';
							end
							if obj2_iscutby_obj1
								reason	= 'X';
							end
							cut_obj_of_lp(i1,1).str	= sprintf('%s\t%s',cut_obj_of_lp(i1,1).str,reason);
						else
							cut_obj_of_lp(i1,1).str	= sprintf('%s\t',cut_obj_of_lp(i1,1).str);
						end
					else
						cut_obj_of_lp(i1,1).str	= sprintf('%s\t%s',cut_obj_of_lp(i1,1).str,'\');
					end
				end
			end
		end
	end
	
	text_str	= sprintf('%s\n\n',text_str);
	text_str	= sprintf('%sOverview of the assignment, from which other objects an object is cut.\n',text_str);
	text_str	= sprintf('%sObject 1 (row) gets cut by object 2 (column) if:\n',text_str);
	text_str	= sprintf('%s(object priority 2 > object priority 1) and          (prio of object, text, symbol)\n',text_str);
	text_str	= sprintf('%s(color numbers are not equal          ) and          (color_no)\n',text_str);
	text_str	= sprintf('%s(color number 1 is not zero           ) and          (color_no)\n',text_str);
	text_str	= sprintf('%s(color number 2 is not zero           ) and          (color_no)\n',text_str);
	text_str	= sprintf('%s((1 is cut by 2 and 2 cuts 1 )   or                  (cut_by_obj_of_hp, cut_obj_of_lp)\n',text_str);
	text_str	= sprintf('%s (color prio 1 > color prio 2)        )              (prio of the color)\n\n',text_str);
	text_str	= sprintf('%s\t\t\t\t\t\t\t\t\t\t\t%s\t%s\n',text_str,headline_cb_hp_1,headline_c_lp_1);
	text_str	= sprintf('%s\t\t\t\t\t\t\t\t\t\tObjNo\t%s\t%s\n',text_str,headline_iobj,headline_iobj);
	text_str	= sprintf('%sRowNo\tObjPrio\tObjNo\tColNo\tColPrio\tDescr\tType\tcb_hp\tc_lp\t\tType\t%s\t%s\n',...
		text_str,headline_type,headline_type);
	for i=1:size(pp_used,1)
		if pp_used(i,1).iobj>0
			iobj		= pp_used(i,1).iobj;
			rowno		= [];
			switch pp_used(i,1).type
				case 'L'
					rowno		= PP.TABLE_ROWNO.obj(iobj,1).display;
				case 'A'
					rowno		= PP.TABLE_ROWNO.obj(iobj,1).display;
				case 'T'
					if isfield(PP.TABLE_ROWNO.obj(iobj,1).textpar,'display')
						rowno		= PP.TABLE_ROWNO.obj(iobj,1).textpar.display;
					end
				case 'S'
					if isfield(PP.TABLE_ROWNO.obj(iobj,1).symbolpar,'display')
						rowno		= PP.TABLE_ROWNO.obj(iobj,1).symbolpar.display;
					end
			end
			text_str	= sprintf('%s%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s',text_str,...
				number2str(rowno,'%g'),...
				number2str(pp_used(i,1).prio,'%g'),...
				number2str(iobj,'%g'),...
				number2str(pp_used(i,1).colno,'%g'),...
				number2str(pp_used(i,1).colprio,'%g'),...
				pp_used(i,1).descr,...
				pp_used(i,1).type,...
				number2str(pp_used(i,1).cb_hp,'%g'),...
				number2str(pp_used(i,1).c_lp,'%g'));
			text_str	= sprintf('%s\t\t%s',text_str,cut_by_obj_of_hp(i,1).str);
			text_str	= sprintf('%s\t%s\n',text_str,cut_obj_of_lp(i,1).str);
		end
	end
	% fprintf(1,'\n%s',text_str);
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Include and exclude tags:
	
	inclexcl_str		= pp_inclexcltags_string;
	text_str	= sprintf('%s\n\n',text_str);
	text_str	= sprintf('%sInclude and exclude tags:\n',text_str);
	text_str	= sprintf('%s%s',text_str,inclexcl_str);
	
	
	%------------------------------------------------------------------------------------------------------------------
	% Save text_str:
	
	pathfilename	= [GV.projectdirectory GV.pp_projectfilename ' - projpar summary.txt'];
	fileID			= fopen(pathfilename,'w');
	fprintf(fileID,'%s',text_str);
	fclose(fileID);
	
catch ME
	errormessage('',ME);
end

