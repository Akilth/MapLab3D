function status=save_ppref(pathname_ppref_xlsx,filename_ppref_xlsx)
% This function saves the reference project parameters in a mat file so that the project parameters can be
% checked for completeness when loading a project file. The function must be executed once after creating
% new project parameters.

global APP GV_H

try
	
	% Initializations:
	status	= 1;
	
	% MapLab3D_PP_Reference.xlsx pathname:
	if nargin==0
		filename_ppref_xlsx		= 'MapLab3D_ProjectParameters_1_0_1_0_Reference';
		pathname_ppref_xlsx		= 'G:\Daten\Projekte\MapLab3D\';
		pathname_ppref_xlsx		= 'C:\Daten\Projekte\MapLab3D\';
	end
	pathfilename_ppref_xlsx		= fullfile(pathname_ppref_xlsx,filename_ppref_xlsx);
	
	% ppref.mat pathname:
	[pathname_ppref_mat,~,~]	= fileparts(mfilename('fullpath'));
	pathfilename_ppref_mat		= [pathname_ppref_mat '\pp_ref.mat'];
	
	% Make this function work also without the app:
	isvalid_APP						= true;
	if isempty(APP)
		isvalid_APP					= false;
	else
		if ~isvalid(APP)
			isvalid_APP				= false;
		end
	end
	
	% Read file:
	try
		disp_str		= 'Execute save_ppref ...';
		if isvalid_APP
			set(GV_H.text_waitbar,'String',disp_str);
		else
			disp(disp_str);
		end
		drawnow;
		% Load file:
		opts	= detectImportOptions(pathfilename_ppref_xlsx,'Sheet','PP ref');
	catch ME
		errortext	= sprintf([...
			'Error when loading the project file:\n',...
			'%s'],pathfilename_ppref_xlsx);
		if isvalid_APP
			errormessage(errortext,ME);
		else
			status	= 0;
			disp(errortext);
			disp(ME.message);
			for k=1:length(ME.stack)
				fprintf(1,'%1.0f %s (%g)\n',...
					k,...
					ME.stack(k).name,...
					ME.stack(k).line);
			end
			return
		end
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
	opts.DataRange	= 'A3';
	T_ref						= readtable(pathfilename_ppref_xlsx,opts);
	
	% % Assign the structure PP_ref:
	% PP_ref					= [];
	% dataset_no			= 1;
	% assign_projectpar	= 1;
	% PP_ref					= open_pp_assign_pp(PP_ref,T_ref,dataset_no,assign_projectpar);
	
	% Search for duplicate project parameters which can be deleted:
	T_ref_index		= verify_pp_create_T_index(T_ref);
	r_duplicate		= verify_pp_search_for_duplicate_pp(T_ref,T_ref_index);
	if any(r_duplicate)
		rows_duplicate_ref_pp	= find(r_duplicate)+1
		errortext					= 'Error: Duplicate reference project parameters!';
		if isvalid_APP
			errormessage(errortext);
		else
			status	= 0;
			disp(errortext);
		end
	end
	
	% Save PP_ref:
	save(pathfilename_ppref_mat,'T_ref','filename_ppref_xlsx');
	if isvalid_APP
		set(GV_H.text_waitbar,'String','');
		drawnow;
	end
	
catch ME
	if isvalid_APP
		errormessage('',ME);
	else
		status	= 0;
		disp(ME.message);
		for k=1:length(ME.stack)
			fprintf(1,'%1.0f %s (%g)\n',...
				k,...
				ME.stack(k).name,...
				ME.stack(k).line);
		end
		return
	end
end

