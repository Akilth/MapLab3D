function errortext=verify_pp(T)
% This function checks whether all project parameters contained in the reference file
% (e.g. MapLab3D_PP_Reference.xlsx) are also contained in the current project parameter file.
% It also searches for superfluous project parameters and checks the version number.

global VER GV

try
	
	errortext		= '';
	
	if nargin==0
		% Read file:
		opts	= detectImportOptions(GV.pp_pathfilename,'Sheet','PP');
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
	end
	
	% Load the reference project parameters table:
	[pathname_ppref_mat,~,~]	= fileparts(mfilename('fullpath'));
	pathfilename_ppref_mat		= [pathname_ppref_mat '\pp_ref.mat'];
	try
		load(pathfilename_ppref_mat,'-mat','T_ref','filename_ppref_xlsx');
	catch
		errormessage(sprintf([...
			'It was not possible to load the file "pp_ref.mat".\n',...
			'The program should be reinstalled.']));
	end
	
	% Indexing of the project parameters table:
	T_index			= verify_pp_create_T_index(T);
	T_ref_index		= verify_pp_create_T_index(T_ref);
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Extend the reference parameters:
	% Some fields can have several elements, e.g. color(R1,C1).
	% To ensure that the higher numbers R1 and C1 in the project parameters are also checked, the reference parameters
	% must have the same number of fields as the current project parameters.
	
	T_ref0			= T_ref;
	fn1_ref_c		= fieldnames(T_ref_index.f1);
	fn2_ref_c		= fieldnames(T_ref_index.f2);
	fn3_ref_c		= fieldnames(T_ref_index.f3);
	
	% Extend data in field 1:
	for i_fn1_ref=1:size(fn1_ref_c,1)
		fn1_ref			= fn1_ref_c{i_fn1_ref,1};
		if    ~strcmp(fn1_ref,'emptyfields')&&...
				~strcmp(fn1_ref,'obj')
			if isfield(T_index.f1,fn1_ref)&&isfield(T_index.f2,'emptyfields')
				
				% i_ref_l, i_l: data in field 1 and 2
				i_ref_l		= ...
					T_ref_index.f1.(fn1_ref)&...
					~T_ref_index.f2.emptyfields;
				if any(i_ref_l)
					r1_ref_max	= max(T_ref_index.r1(i_ref_l));
					c1_ref_max	= max(T_ref_index.c1(i_ref_l));
					i_l			= ...
						T_index.f1.(fn1_ref)&...
						~T_index.f2.emptyfields;
					r1_max		= max(T_index.r1(i_l));
					c1_max		= max(T_index.c1(i_l));
					if ~isempty(r1_max)&&~isempty(c1_max)
						% The reference parameters are also included in the current project parameters:
						if r1_ref_max>1
							r1_min		= 2;
							r1_max		= max(r1_ref_max,r1_max);
						else
							r1_min		= 1;
							r1_max		= 1;
						end
						if c1_ref_max>1
							c1_min		= 2;
							c1_max		= max(c1_ref_max,c1_max);
						else
							c1_min		= 1;
							c1_max		= 1;
						end
						if (r1_max>1)||(c1_max>1)
							T_ref_ext		= T_ref0(i_ref_l&(T_ref_index.r1==1)&(T_ref_index.c1==1),:);
							for r1=r1_min:r1_max
								for c1=c1_min:c1_max
									T_ref_ext.R1(:,1)									= r1;
									T_ref_ext.C1(:,1)									= c1;
									T_ref((end+1):(end+height(T_ref_ext)),:)	= T_ref_ext;
								end
							end
						end
					end
				end
				
				% Extend data in field 2:
				for i_fn2_ref=1:size(fn2_ref_c,1)
					fn2_ref			= fn2_ref_c{i_fn2_ref,1};
					if    ~strcmp(fn2_ref,'emptyfields')&&...
							~strcmp(fn1_ref,'legend')&&~strcmp(fn2_ref,'element')
						
						if isfield(T_index.f2,fn2_ref)&&isfield(T_index.f3,'emptyfields')
							% i_ref_l, i_l: data in field 1,2 and 3:
							i_ref_l		= ...
								T_ref_index.f1.(fn1_ref)&...
								T_ref_index.f2.(fn2_ref)&...
								~T_ref_index.f3.emptyfields;
							if any(i_ref_l)
								r2_ref_max	= max(T_ref_index.r2(i_ref_l));
								c2_ref_max	= max(T_ref_index.c2(i_ref_l));
								i_l			= ...
									T_index.f1.(fn1_ref)&...
									T_index.f2.(fn2_ref)&...
									~T_index.f3.emptyfields;
								if any(i_l)
									r2_max		= max(T_index.r2(i_l));
									c2_max		= max(T_index.c2(i_l));
									if ~isempty(r2_max)&&~isempty(c2_max)
										% The reference parameters are also included in the current project parameters:
										if r2_ref_max>1
											r2_max		= max(r2_ref_max,r2_max);
										else
											r2_max		= 1;
										end
										if c2_ref_max>1
											c2_max		= max(c2_ref_max,c2_max);
										else
											c2_max		= 1;
										end
										if (r2_max>1)||(c2_max>1)
											T_ref_ext		= T_ref0(i_ref_l&(T_ref_index.r2==1)&(T_ref_index.c2==1),:);
											for r2=1:r2_max
												for c2=1:c2_max
													T_ref_ext.R2(:,1)									= r2;
													T_ref_ext.C2(:,1)									= c2;
													T_ref((end+1):(end+height(T_ref_ext)),:)	= T_ref_ext;
												end
											end
										end
									end
								end
							end
							
						end
					end
				end
				
				% Extend data in field 3:
				for i_fn3_ref=1:size(fn3_ref_c,1)
					fn3_ref			= fn3_ref_c{i_fn3_ref,1};
					if    ~strcmp(fn3_ref,'emptyfields')
						
						if isfield(T_index.f3,fn3_ref)&&isfield(T_index.f3,'emptyfields')
							% i_ref_l, i_l: data in field 1,2,3 and 4:
							i_ref_l		= ...
								T_ref_index.f1.(fn1_ref)&...
								T_ref_index.f2.(fn2_ref)&...
								T_ref_index.f3.(fn3_ref)&...
								~T_ref_index.f4.emptyfields;
							if any(i_ref_l)
								r3_ref_max	= max(T_ref_index.r3(i_ref_l));
								c3_ref_max	= max(T_ref_index.c3(i_ref_l));
								i_l			= ...
									T_index.f1.(fn1_ref)&...
									T_index.f2.(fn2_ref)&...
									T_index.f3.(fn3_ref)&...
									~T_index.f4.emptyfields;
								if any(i_l)
									r3_max		= max(T_index.r3(i_l));
									c3_max		= max(T_index.c3(i_l));
									if ~isempty(r3_max)&&~isempty(c3_max)
										% The reference parameters are also included in the current project parameters:
										if r3_ref_max>1
											r3_max		= max(r3_ref_max,r3_max);
										else
											r3_max		= 1;
										end
										if c3_ref_max>1
											c3_max		= max(c3_ref_max,c3_max);
										else
											c3_max		= 1;
										end
										if (r3_max>1)||(c3_max>1)
											T_ref_ext		= T_ref0(i_ref_l&(T_ref_index.r3==1)&(T_ref_index.c3==1),:);
											for r3=1:r3_max
												for c3=1:c3_max
													T_ref_ext.R3(:,1)									= r3;
													T_ref_ext.C3(:,1)									= c3;
													T_ref((end+1):(end+height(T_ref_ext)),:)	= T_ref_ext;
												end
											end
										end
									end
								end
							end
							
						end
					end
				end
				
			end
		end
	end
	
	% Indexing of the modified reference project parameters table:
	T_ref_index		= verify_pp_create_T_index(T_ref);
	
	% Delete duplicate lines in T_ref:
	f1_ref_c			= T_ref.FIELD1(:);
	f2_ref_c			= T_ref.FIELD2(:);
	f3_ref_c			= T_ref.FIELD3(:);
	f4_ref_c			= T_ref.FIELD4(:);
	snmc1_ref_c		= T_ref.SNMC1(:);
	snmc2_ref_c		= T_ref.SNMC2(:);
	snmc3_ref_c		= T_ref.SNMC3(:);
	snmc4_ref_c		= T_ref.SNMC4(:);
	r_ref_delete	= false(size(T_ref_index.r1,1),1);
	for r_ref=1:size(T_ref_index.r1,1)
		if ~r_ref_delete(r_ref)
			f1_ref			= f1_ref_c{r_ref,1};
			f2_ref			= f2_ref_c{r_ref,1};
			f3_ref			= f3_ref_c{r_ref,1};
			f4_ref			= f4_ref_c{r_ref,1};
			snmc1_ref		= snmc1_ref_c{r_ref,1};
			snmc2_ref		= snmc2_ref_c{r_ref,1};
			snmc3_ref		= snmc3_ref_c{r_ref,1};
			snmc4_ref		= snmc4_ref_c{r_ref,1};
			if isempty(f1_ref),    f1_ref='emptyfields';    end
			if isempty(f2_ref),    f2_ref='emptyfields';    end
			if isempty(f3_ref),    f3_ref='emptyfields';    end
			if isempty(f4_ref),    f4_ref='emptyfields';    end
			if isempty(snmc1_ref), snmc1_ref='emptyfields'; end
			if isempty(snmc2_ref), snmc2_ref='emptyfields'; end
			if isempty(snmc3_ref), snmc3_ref='emptyfields'; end
			if isempty(snmc4_ref), snmc4_ref='emptyfields'; end
			i_l		= ...
				T_ref_index.f1.(f1_ref) & ...
				T_ref_index.f2.(f2_ref) & ...
				T_ref_index.f3.(f3_ref) & ...
				T_ref_index.f4.(f4_ref) & ...
				T_ref_index.snmc1.(snmc1_ref) & ...
				T_ref_index.snmc2.(snmc2_ref) & ...
				T_ref_index.snmc3.(snmc3_ref) & ...
				T_ref_index.snmc4.(snmc4_ref) & ...
				(T_ref_index.r1(r_ref,1)==T_ref_index.r1) & ...
				(T_ref_index.r2(r_ref,1)==T_ref_index.r2) & ...
				(T_ref_index.r3(r_ref,1)==T_ref_index.r3) & ...
				(T_ref_index.r4(r_ref,1)==T_ref_index.r4) & ...
				(T_ref_index.c1(r_ref,1)==T_ref_index.c1) & ...
				(T_ref_index.c2(r_ref,1)==T_ref_index.c2) & ...
				(T_ref_index.c3(r_ref,1)==T_ref_index.c3) & ...
				(T_ref_index.c4(r_ref,1)==T_ref_index.c4);
			r_ref_v	= find(i_l);
			if size(r_ref_v,1)>1
				r_ref_delete(r_ref_v(2:end,:),:)	= true;
			end
		end
	end
	T_ref(r_ref_delete,:)		= [];
	
	% Indexing of the modified reference project parameters table:
	T_ref_index		= verify_pp_create_T_index(T_ref);
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Search for missing project parameters that need to be added:
	r_ref_missing	= search_for_missing_pp(T_ref,T_ref_index,T_index);
	
	% Correction suggestion:
	textout_missing		= '';
	if any(r_ref_missing)
		textout_missing	= sprintf('%s\nMissing project parameters which have to be added:\n',textout_missing);
		textout_missing	= sprintf('%s(see %s)\n',textout_missing,filename_ppref_xlsx);
		
		% Variable names of T:
		s						= summary(T);
		fn_s					= fieldnames(s);
		textout_missing	= sprintf('%srow\t',textout_missing);
		for ifn=1:size(fn_s,1)
			textout_missing	= sprintf('%s%s',textout_missing,fn_s{ifn,1});
			if ifn<size(fn_s,1)
				textout_missing	= sprintf('%s\t',textout_missing);
			else
				textout_missing	= sprintf('%s\n',textout_missing);
			end
		end
		
		% Missing project parameters:
		i_ref_missing	= find(r_ref_missing);
		for k=1:length(i_ref_missing)
			r_ref		= i_ref_missing(k,1);
			textout_missing	= sprintf('%s%g\t',textout_missing,r_ref+1);
			for ifn=1:size(fn_s,1)
				if isequal(strfind(fn_s{ifn,1},'DATASET_'),1)
					textout_missing	= sprintf('%s%s',textout_missing,T_ref.DATASET_1{r_ref,1});
				elseif isequal(strfind(fn_s{ifn,1},'CMP_DS'),1)
					% nop
				elseif strcmp(fn_s{ifn,1},'PERSONAL_REMARKS_1')
					% nop
				elseif strcmp(fn_s{ifn,1},'PERSONAL_REMARKS_2')
					% nop
				else
					if isnumeric(T_ref.(fn_s{ifn,1}))
						if ~isnan(T_ref.(fn_s{ifn,1})(r_ref,1))
							textout_missing	= sprintf('%s%s',textout_missing,...
								number2str(T_ref.(fn_s{ifn,1})(r_ref,1),'%g'));
						end
					else
						if ~isempty(T_ref.(fn_s{ifn,1}){r_ref,1})
							textout_missing	= sprintf('%s%s',textout_missing,...
								T_ref.(fn_s{ifn,1}){r_ref,1});
						end
					end
				end
				if ifn<size(fn_s,1)
					textout_missing	= sprintf('%s\t',textout_missing);
				else
					textout_missing	= sprintf('%s\n',textout_missing);
				end
			end
		end
		
	end
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Search for project parameters which can be deleted:
	r_delete			= search_for_unnecessary_pp(T,T_index,T_ref_index);
	
	% Correction suggestion:
	textout_delete		= '';
	if any(r_delete)
		textout_delete	= sprintf('%s\nUnnecessary project parameters which can be deleted:\n',textout_delete);
		
		% Variable names of T:
		s					= summary(T);
		fn_s				= fieldnames(s);
		textout_delete	= sprintf('%srow\t',textout_delete);
		for ifn=1:size(fn_s,1)
			textout_delete	= sprintf('%s%s',textout_delete,fn_s{ifn,1});
			if ifn<size(fn_s,1)
				textout_delete	= sprintf('%s\t',textout_delete);
			else
				textout_delete	= sprintf('%s\n',textout_delete);
			end
		end
		
		% Project parameters which can be deleted:
		i_delete	= find(r_delete);
		for k=1:length(i_delete)
			r		= i_delete(k,1);
			textout_delete	= sprintf('%s%g\t',textout_delete,r+1);
			for ifn=1:size(fn_s,1)
				if isnumeric(T.(fn_s{ifn,1}))
					if ~isnan(T.(fn_s{ifn,1})(r,1))
						textout_delete	= sprintf('%s%s',textout_delete,number2str(T.(fn_s{ifn,1})(r,1),'%g'));
					end
				else
					if ~isempty(T.(fn_s{ifn,1}){r,1})
						if    isequal(strfind(fn_s{ifn,1},'DATASET_'),1)                                                          &&(...
								strcmp(T.SNMC4(r,1),'N')                                                                       ||...
								(strcmp(T.SNMC3(r,1),'N')&&isempty(T.SNMC4(r,1))                                              )||...
								(strcmp(T.SNMC2(r,1),'N')&&isempty(T.SNMC3(r,1))&&isempty(T.SNMC4(r,1))                       )||...
								(strcmp(T.SNMC1(r,1),'N')&&isempty(T.SNMC2(r,1))&&isempty(T.SNMC3(r,1))&&isempty(T.SNMC3(r,1)))           )
							textout_delete	= sprintf('%s%s',textout_delete,number2str(T.(fn_s{ifn,1}){r,1},'%s'));
						else
							textout_delete	= sprintf('%s%s',textout_delete,T.(fn_s{ifn,1}){r,1});
						end
					end
				end
				if ifn<size(fn_s,1)
					textout_delete	= sprintf('%s\t',textout_delete);
				else
					textout_delete	= sprintf('%s\n',textout_delete);
				end
			end
		end
		
	end
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Search for duplicate project parameters which can be deleted:
	r_duplicate		= verify_pp_search_for_duplicate_pp(T,T_index);
	
	% Correction suggestion:
	textout_duplicate		= '';
	if any(r_duplicate)
		textout_duplicate	= sprintf('%s\nDuplicate project parameters:\n',textout_duplicate);
		
		% Variable names of T:
		s						= summary(T);
		fn_s					= fieldnames(s);
		textout_duplicate	= sprintf('%srow\t',textout_duplicate);
		for ifn=1:size(fn_s,1)
			textout_duplicate	= sprintf('%s%s',textout_duplicate,fn_s{ifn,1});
			if ifn<size(fn_s,1)
				textout_duplicate	= sprintf('%s\t',textout_duplicate);
			else
				textout_duplicate	= sprintf('%s\n',textout_duplicate);
			end
		end
		
		% Duplicate project parameters:
		i_duplicate	= find(r_duplicate);
		for k=1:length(i_duplicate)
			r		= i_duplicate(k,1);
			textout_duplicate	= sprintf('%s%g\t',textout_duplicate,r+1);
			for ifn=1:size(fn_s,1)
				if isnumeric(T.(fn_s{ifn,1}))
					if ~isnan(T.(fn_s{ifn,1})(r,1))
						textout_duplicate	= sprintf('%s%s',textout_duplicate,number2str(T.(fn_s{ifn,1})(r,1),'%g'));
					end
				else
					if ~isempty(T.(fn_s{ifn,1}){r,1})
						if    isequal(strfind(fn_s{ifn,1},'DATASET_'),1)                                                          &&(...
								strcmp(T.SNMC4(r,1),'N')                                                                       ||...
								(strcmp(T.SNMC3(r,1),'N')&&isempty(T.SNMC4(r,1))                                              )||...
								(strcmp(T.SNMC2(r,1),'N')&&isempty(T.SNMC3(r,1))&&isempty(T.SNMC4(r,1))                       )||...
								(strcmp(T.SNMC1(r,1),'N')&&isempty(T.SNMC2(r,1))&&isempty(T.SNMC3(r,1))&&isempty(T.SNMC3(r,1)))           )
							textout_duplicate	= sprintf('%s%s',textout_duplicate,number2str(T.(fn_s{ifn,1}){r,1},'%s'));
						else
							textout_duplicate	= sprintf('%s%s',textout_duplicate,T.(fn_s{ifn,1}){r,1});
						end
					end
				end
				if ifn<size(fn_s,1)
					textout_duplicate	= sprintf('%s\t',textout_duplicate);
				else
					textout_duplicate	= sprintf('%s\n',textout_duplicate);
				end
			end
		end
		
	end
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Check the version number:
	
	r					= find(...
		T_index.f1.project   &T_index.snmc1.N&...
		T_index.f2.version_no&T_index.snmc2.S    );
	ver_str			= T.PROJECT{r,1};			% e.g.: '0.5.0.0'
	k					= strfind(ver_str,'.');
	ver_isvalid		= true;
	if  ~( isscalar(k)  ||...			% 1.1
			(length(k)==2)||...			% 1.1.0
			(length(k)==3)     )			% 1.1.0.0
		ver_isvalid		= false;
	else
		no1				= str2double(ver_str(      1 :(k(1)-1)));
		if isscalar(k)
			no2			= str2double(ver_str((k(1)+1):end     ));
		else
			no2			= str2double(ver_str((k(1)+1):(k(2)-1)));
		end
		if isnan(no1)||isnan(no2)
			ver_isvalid		= false;
		else
			if ~isequal(no1,VER.no1)||~isequal(no2,VER.no2)
				ver_isvalid		= false;
			end
		end
	end
	
	textout_ver		= '';
	if ~ver_isvalid
		textout_ver	= sprintf('%s\nWrong version number. Enter the following number:\n',textout_ver);
		
		% Variable names of T:
		s				= summary(T);
		fn_s			= fieldnames(s);
		textout_ver	= sprintf('%srow\t',textout_ver);
		for ifn=1:size(fn_s,1)
			textout_ver	= sprintf('%s%s',textout_ver,fn_s{ifn,1});
			if ifn<size(fn_s,1)
				textout_ver	= sprintf('%s\t',textout_ver);
			else
				textout_ver	= sprintf('%s\n',textout_ver);
			end
		end
		
		% Version number:
		textout_ver	= sprintf('%s%g\t',textout_ver,r+1);
		for ifn=1:size(fn_s,1)
			if strcmp(fn_s{ifn,1},'PROJECT')
				textout_ver	= sprintf('%s%g.%g',textout_ver,VER.no1,VER.no2);
			else
				if isequal(strfind(fn_s{ifn,1},'DATASET_'),1)
					textout_ver	= sprintf('%s%s',textout_ver,T.DATASET_1{r,1});
				else
					if isnumeric(T.(fn_s{ifn,1}))
						if ~isnan(T.(fn_s{ifn,1})(r,1))
							textout_ver	= sprintf('%s%s',textout_ver,number2str(T.(fn_s{ifn,1})(r,1),'%g'));
						end
					else
						if ~isempty(T.(fn_s{ifn,1}){r,1})
							textout_ver	= sprintf('%s%s',textout_ver,T.(fn_s{ifn,1}){r,1});
						end
					end
				end
			end
			if ifn<size(fn_s,1)
				textout_ver	= sprintf('%s\t',textout_ver);
			else
				textout_ver	= sprintf('%s\n',textout_ver);
			end
		end
		
	end
	
	
	% -----------------------------------------------------------------------------------------------------------------
	% Summary:
	
	if ~isempty(textout_ver)||~isempty(textout_missing)||~isempty(textout_delete)||~isempty(textout_duplicate)
		
		% The project parameter file needs to be revised:
		textout				= sprintf([...
			'Error in %s:\n',...
			'The project parameter file contains errors and needs to be updated manually.\n',...
			'Copy the text to a spreadsheet for better readability (for example Excel).\n',...
			'Timestamp: %s\n%s%s%s%s'],GV.pp_pathfilename,datestr(now),...
			textout_ver,...
			textout_missing,...
			textout_delete,...
			textout_duplicate);
		ppcorr_pathfilename	= [GV.pp_pathfilename ' - corrections.txt'];
		errortext				= sprintf([...
			'Error in the project parameter file\n',...
			'%s:\n',...
			'\n',...
			'You can use the project parameter file that comes with the\n',...
			'current version %g.%g.x.x, or you can manually update your own\n',...
			'project parameter file to the current version %g.%g.x.x.\n',...
			'\n',...
			'The necessary corrections are saved in:\n',...
			'%s%s'],...
			GV.pp_pathfilename,...
			VER.no1,VER.no2,...
			VER.no1,VER.no2,...
			ppcorr_pathfilename);
		
		% Save textout:
		fileID			= fopen(ppcorr_pathfilename,'w');
		fprintf(fileID,'%s',textout);
		fclose(fileID);
		
	end
	
catch ME
	errormessage('',ME);
end



% -----------------------------------------------------------------------------------------------------------------
% Search for missing project parameters that need to be added:
function r_ref_missing=search_for_missing_pp(T_ref,T_ref_index,T_index)
% check_all_elements_of_a_matrix=1:
% All elements of a matrix that are contained in T_ref must also be contained in T

try
	
	% Create cell arrays and vectors (faster than working with tables):
	f1_ref_c			= T_ref.FIELD1(:);
	f2_ref_c			= T_ref.FIELD2(:);
	f3_ref_c			= T_ref.FIELD3(:);
	f4_ref_c			= T_ref.FIELD4(:);
	snmc1_ref_c		= T_ref.SNMC1(:);
	snmc2_ref_c		= T_ref.SNMC2(:);
	snmc3_ref_c		= T_ref.SNMC3(:);
	snmc4_ref_c		= T_ref.SNMC4(:);
	
	r_ref_missing		= false(height(T_ref),1);
	for r_ref=1:height(T_ref)
		
		f1_ref		= f1_ref_c{r_ref};
		f2_ref		= f2_ref_c{r_ref};
		f3_ref		= f3_ref_c{r_ref};
		f4_ref		= f4_ref_c{r_ref};
		snmc1_ref	= snmc1_ref_c{r_ref};
		snmc2_ref	= snmc2_ref_c{r_ref};
		snmc3_ref	= snmc3_ref_c{r_ref};
		snmc4_ref	= snmc4_ref_c{r_ref};
		
		r1_ref		= T_ref_index.r1(r_ref);
		r2_ref		= T_ref_index.r2(r_ref);
		r3_ref		= T_ref_index.r3(r_ref);
		r4_ref		= T_ref_index.r4(r_ref);
		c1_ref		= T_ref_index.c1(r_ref);
		c2_ref		= T_ref_index.c2(r_ref);
		c3_ref		= T_ref_index.c3(r_ref);
		c4_ref		= T_ref_index.c4(r_ref);
		
		if   ~isempty(f1_ref)&&~isempty(snmc1_ref)
			
			% -----------------------------------------------------------------------------------------------------------
			% Data in field 1:
			
			if isempty(f2_ref)||isempty(snmc2_ref)
				% No data in field 2:
				
				i_ref_l		= ...
					T_ref_index.f1.(f1_ref)          & ...
					T_ref_index.f2.emptyfields       & ...
					T_ref_index.f3.emptyfields       & ...
					T_ref_index.f4.emptyfields       & ...
					T_ref_index.snmc1.(snmc1_ref)    & ...
					T_ref_index.snmc2.emptyfields    & ...
					T_ref_index.snmc3.emptyfields    & ...
					T_ref_index.snmc4.emptyfields;
				i_ref_v		= find(i_ref_l);
				kmax			= length(i_ref_v);
				
				if    (kmax==1)||(...
						(r1_ref==1)&&(c1_ref==1))
					% This is the first or only element:
					
					for k=1:kmax
						i_ref		= i_ref_v(k);
						if    ~isfield(T_index.f1  ,f1_ref    )||...
								~isfield(T_index.snmc1,snmc1_ref)
							% The field name does not exist in the project parameters:
							r_ref_missing(i_ref,1)		= true;
						else
							% The field name exists in the project parameters:
							if strcmp(f1_ref,'obj')
								% Do not check for missing parameters:
								i_l		= true;
							else
								i_l		= ...
									T_index.f1.(f1_ref)                  & ...
									T_index.f2.emptyfields               & ...
									T_index.f3.emptyfields               & ...
									T_index.f4.emptyfields               & ...
									T_index.snmc1.(snmc1_ref)            & ...
									T_index.snmc2.emptyfields            & ...
									T_index.snmc3.emptyfields            &...
									T_index.snmc4.emptyfields            &...
									(T_index.r1==T_ref_index.r1(i_ref,1))&...
									(T_index.c1==T_ref_index.c1(i_ref,1));
							end
							if ~any(i_l)
								% The complete combination of field names and snmc does not exist in the project parameters:
								r_ref_missing(i_ref,1)		= true;
							end
						end
					end
					
				end
				
			else
				
				% --------------------------------------------------------------------------------------------------------
				% Data in field 1 and 2:
				if isempty(f3_ref)||isempty(snmc3_ref)
					% No data in field 3:
					
					i_ref_l		= ...
						T_ref_index.f1.(f1_ref)          & ...
						T_ref_index.f2.(f2_ref)          & ...
						T_ref_index.f3.emptyfields       & ...
						T_ref_index.f4.emptyfields       & ...
						T_ref_index.snmc1.(snmc1_ref)    & ...
						T_ref_index.snmc2.(snmc2_ref)    & ...
						T_ref_index.snmc3.emptyfields    & ...
						T_ref_index.snmc4.emptyfields;
					i_ref_v		= find(i_ref_l);
					kmax			= length(i_ref_v);
					
					if    (kmax==1)||(...
							(r1_ref==1)&&(c1_ref==1)&&...
							(r2_ref==1)&&(c2_ref==1)     )
						% This is the first or only element:
						
						for k=1:kmax
							i_ref		= i_ref_v(k);
							if    ~isfield(T_index.f1   ,f1_ref   )||...
									~isfield(T_index.f2   ,f2_ref   )||...
									~isfield(T_index.snmc1,snmc1_ref)||...
									~isfield(T_index.snmc2,snmc2_ref)
								% The field names does not exist in the project parameters:
								r_ref_missing(i_ref,1)		= true;
							else
								% The field names exist in the project parameters:
								if strcmp(f1_ref,'obj')
									% Do not check for missing parameters:
									i_l		= true;
								else
									if strcmp(f1_ref,'legend')&&strcmp(f2_ref,'element')
										% Do not check for missing parameters:
										i_l		= true;
									else
										i_l		= ...
											T_index.f1.(f1_ref)                  & ...
											T_index.f2.(f2_ref)                  & ...
											T_index.f3.emptyfields               & ...
											T_index.f4.emptyfields               & ...
											T_index.snmc1.(snmc1_ref)            & ...
											T_index.snmc2.(snmc2_ref)            & ...
											T_index.snmc3.emptyfields            &...
											T_index.snmc4.emptyfields            &...
											(T_index.r1==T_ref_index.r1(i_ref,1))&...
											(T_index.r2==T_ref_index.r2(i_ref,1))&...
											(T_index.c1==T_ref_index.c1(i_ref,1))&...
											(T_index.c2==T_ref_index.c2(i_ref,1));
									end
								end
								if ~any(i_l)
									% The complete combination of field names and snmc does not exist in the project parameters:
									r_ref_missing(i_ref,1)		= true;
								end
							end
						end
						
					end
					
				else
					
					% -----------------------------------------------------------------------------------------------------
					% Data in field 1,2 and 3:
					
					if isempty(f4_ref)||isempty(snmc4_ref)
						% No data in field 4:
						
						i_ref_l		= ...
							T_ref_index.f1.(f1_ref)          & ...
							T_ref_index.f2.(f2_ref)          & ...
							T_ref_index.f3.(f3_ref)          & ...
							T_ref_index.f4.emptyfields       & ...
							T_ref_index.snmc1.(snmc1_ref)    & ...
							T_ref_index.snmc2.(snmc2_ref)    & ...
							T_ref_index.snmc3.(snmc3_ref)    & ...
							T_ref_index.snmc4.emptyfields;
						i_ref_v		= find(i_ref_l);
						kmax			= length(i_ref_v);
						
						if    (kmax==1)||(...
								(r1_ref==1)&&(c1_ref==1)&&...
								(r2_ref==1)&&(c2_ref==1)&&...
								(r3_ref==1)&&(c3_ref==1)     )
							% This is the first or only element:
							
							for k=1:kmax
								i_ref		= i_ref_v(k);
								if    ~isfield(T_index.f1   ,f1_ref   )||...
										~isfield(T_index.f2   ,f2_ref   )||...
										~isfield(T_index.f3   ,f3_ref   )||...
										~isfield(T_index.snmc1,snmc1_ref)||...
										~isfield(T_index.snmc2,snmc2_ref)||...
										~isfield(T_index.snmc3,snmc3_ref)
									% The field names does not exist in the project parameters:
									r_ref_missing(i_ref,1)		= true;
								else
									% The field names exist in the project parameters:
									if strcmp(f1_ref,'obj')
										% Do not check for missing parameters:
										i_l		= true;
									else
										if strcmp(f1_ref,'legend')&&strcmp(f2_ref,'element')
											% Do not check for missing parameters:
											i_l		= true;
										else
											i_l		= ...
												T_index.f1.(f1_ref)                  & ...
												T_index.f2.(f2_ref)                  & ...
												T_index.f3.(f3_ref)                  & ...
												T_index.f4.emptyfields               & ...
												T_index.snmc1.(snmc1_ref)            & ...
												T_index.snmc2.(snmc2_ref)            & ...
												T_index.snmc3.(snmc3_ref)            & ...
												T_index.snmc4.emptyfields            &...
												(T_index.r1==T_ref_index.r1(i_ref,1))&...
												(T_index.r2==T_ref_index.r2(i_ref,1))&...
												(T_index.r3==T_ref_index.r3(i_ref,1))&...
												(T_index.c1==T_ref_index.c1(i_ref,1))&...
												(T_index.c2==T_ref_index.c2(i_ref,1))&...
												(T_index.c3==T_ref_index.c3(i_ref,1));
										end
									end
									if ~any(i_l)
										% The complete combination of field names and snmc does not exist in the project parameters:
										r_ref_missing(i_ref,1)		= true;
									end
								end
							end
							
						end
						
					else
						
						% --------------------------------------------------------------------------------------------------
						% Data in field 1,2,3 and 4:
						
						i_ref_l		= ...
							T_ref_index.f1.(f1_ref)          & ...
							T_ref_index.f2.(f2_ref)          & ...
							T_ref_index.f3.(f3_ref)          & ...
							T_ref_index.f4.(f4_ref)          & ...
							T_ref_index.snmc1.(snmc1_ref)    & ...
							T_ref_index.snmc2.(snmc2_ref)    & ...
							T_ref_index.snmc3.(snmc3_ref)    & ...
							T_ref_index.snmc4.(snmc4_ref);
						i_ref_v		= find(i_ref_l);
						kmax			= length(i_ref_v);
						
						if    (kmax==1)||(...
								(r1_ref==1)&&(c1_ref==1)&&...
								(r2_ref==1)&&(c2_ref==1)&&...
								(r3_ref==1)&&(c3_ref==1)&&...
								(r4_ref==1)&&(c4_ref==1)     )
							% This is the first or only element:
							
							for k=1:kmax
								i_ref		= i_ref_v(k);
								if    ~isfield(T_index.f1   ,f1_ref   )||...
										~isfield(T_index.f2   ,f2_ref   )||...
										~isfield(T_index.f3   ,f3_ref   )||...
										~isfield(T_index.f4   ,f4_ref   )||...
										~isfield(T_index.snmc1,snmc1_ref)||...
										~isfield(T_index.snmc2,snmc2_ref)||...
										~isfield(T_index.snmc3,snmc3_ref)||...
										~isfield(T_index.snmc4,snmc4_ref)
									% The field names does not exist in the project parameters:
									r_ref_missing(i_ref,1)		= true;
								else
									% The field names exist in the project parameters:
									if strcmp(f1_ref,'obj')
										% Do not check for missing parameters:
										i_l		= true;
									else
										if strcmp(f1_ref,'legend')&&strcmp(f2_ref,'element')
											% Do not check for missing parameters:
											i_l		= true;
										else
											i_l		= ...
												T_index.f1.(f1_ref)                  & ...
												T_index.f2.(f2_ref)                  & ...
												T_index.f3.(f3_ref)                  & ...
												T_index.f4.(f4_ref)                  & ...
												T_index.snmc1.(snmc1_ref)            & ...
												T_index.snmc2.(snmc2_ref)            & ...
												T_index.snmc3.(snmc3_ref)            &...
												T_index.snmc4.(snmc4_ref)            &...
												(T_index.r1==T_ref_index.r1(i_ref,1))&...
												(T_index.r2==T_ref_index.r2(i_ref,1))&...
												(T_index.r3==T_ref_index.r3(i_ref,1))&...
												(T_index.r4==T_ref_index.r4(i_ref,1))&...
												(T_index.c1==T_ref_index.c1(i_ref,1))&...
												(T_index.c2==T_ref_index.c2(i_ref,1))&...
												(T_index.c3==T_ref_index.c3(i_ref,1))&...
												(T_index.c4==T_ref_index.c4(i_ref,1));
										end
									end
									if ~any(i_l)
										% The complete combination of field names and snmc does not exist in the project parameters:
										r_ref_missing(i_ref,1)		= true;
									end
								end
							end
							
						end
						
					end
					
				end
				
			end
			
		end
		
	end
	
catch ME
	errormessage('',ME);
end



% -----------------------------------------------------------------------------------------------------------------
% Search for project parameters which can be deleted:
function r_unnecessary=search_for_unnecessary_pp(T,T_index,T_ref_index)

try
	
	% Create cell arrays and vectors (faster than working with tables):
	f1_c			= T.FIELD1(:);
	f2_c			= T.FIELD2(:);
	f3_c			= T.FIELD3(:);
	f4_c			= T.FIELD4(:);
	snmc1_c		= T.SNMC1(:);
	snmc2_c		= T.SNMC2(:);
	snmc3_c		= T.SNMC3(:);
	snmc4_c		= T.SNMC4(:);
	
	r_unnecessary		= false(height(T),1);
	r_tested				= false(height(T),1);
	for r=1:height(T)
		
		f1			= f1_c{r};
		f2			= f2_c{r};
		f3			= f3_c{r};
		f4			= f4_c{r};
		snmc1		= snmc1_c{r};
		snmc2		= snmc2_c{r};
		snmc3		= snmc3_c{r};
		snmc4		= snmc4_c{r};
		
		if   ~isempty(f1)&&~isempty(snmc1)
			
			% -----------------------------------------------------------------------------------------------------------
			% Data in field 1:
			if isempty(f2)||isempty(snmc2)
				% No data in field 2:
				
				i_l		= ...
					T_index.f1.(f1)              & ...
					T_index.f2.emptyfields       & ...
					T_index.f3.emptyfields       & ...
					T_index.f4.emptyfields       & ...
					T_index.snmc1.(snmc1)		  & ...
					T_index.snmc2.emptyfields    & ...
					T_index.snmc3.emptyfields;
				T_index.snmc4.emptyfields;
				i_v		= find(i_l);
				kmax		= length(i_v);
				
				if    ~isfield(T_ref_index.f1   ,f1   )||...
						~isfield(T_ref_index.snmc1,snmc1)
					% The field name does not exist in the reference project parameters:
					r_unnecessary(i_v,1)		= true;
				else
					% The field name exists in the reference project parameters:
					if strcmp(f1,'obj')&&isfield(T_ref_index.f1,'defobj')
						% If f1=T.FIELD1{r}='obj':
						% Check whether the element exists in T_ref_index.f1.defobj:
						i_ref_l		= ...
							T_ref_index.f1.defobj            & ...
							T_ref_index.f2.emptyfields       & ...
							T_ref_index.f3.emptyfields       & ...
							T_ref_index.f4.emptyfields       & ...
							T_ref_index.snmc1.(snmc1)        & ...
							T_ref_index.snmc2.emptyfields    & ...
							T_ref_index.snmc3.emptyfields    & ...
							T_ref_index.snmc4.emptyfields;
						r1_ref_max	= 2;
						c1_ref_max	= 1;
					else
						i_ref_l		= ...
							T_ref_index.f1.(f1)              & ...
							T_ref_index.f2.emptyfields       & ...
							T_ref_index.f3.emptyfields       & ...
							T_ref_index.f4.emptyfields       & ...
							T_ref_index.snmc1.(snmc1)        & ...
							T_ref_index.snmc2.emptyfields    & ...
							T_ref_index.snmc3.emptyfields    & ...
							T_ref_index.snmc4.emptyfields;
						r1_ref_max	= max(T_ref_index.r1(i_ref_l,1));
						c1_ref_max	= max(T_ref_index.c1(i_ref_l,1));
					end
					
					if ~any(i_ref_l)
						% The complete combination of field names and snmc does not exist in the reference project parameters:
						r_unnecessary(i_v,1)		= true;
					else
						for k=1:kmax
							i		= i_v(k);
							if ~r_tested(i,1)
								r_tested(i,1)	= true;
								r1					= T_index.r1(i,1);
								c1					= T_index.c1(i,1);
								if (r1_ref_max==1)&&(r1>1)
									% The reference project parameters have only one row and
									% the project parameters have more than one row:
									r_unnecessary(i,1)		= true;
								else
									if (c1_ref_max==1)&&(c1>1)
										% The reference project parameters have only one column and
										% the project parameters have more than one column:
										r_unnecessary(i,1)		= true;
									end
								end
							end
						end
					end
					
				end
				
			else
				
				% --------------------------------------------------------------------------------------------------------
				% Data in field 1 and 2:
				if isempty(f3)||isempty(snmc3)
					% No data in field 3:
					
					i_l		= ...
						T_index.f1.(f1)              & ...
						T_index.f2.(f2)              & ...
						T_index.f3.emptyfields       & ...
						T_index.f4.emptyfields       & ...
						T_index.snmc1.(snmc1)        & ...
						T_index.snmc2.(snmc2)        & ...
						T_index.snmc3.emptyfields    & ...
						T_index.snmc4.emptyfields;
					i_v		= find(i_l);
					kmax			= length(i_v);
					
					if    ~isfield(T_ref_index.f1   ,f1   )||...
							~isfield(T_ref_index.f2   ,f2   )||...
							~isfield(T_ref_index.snmc1,snmc1)||...
							~isfield(T_ref_index.snmc2,snmc2)
						% The field names does not exist in the reference project parameters:
						r_unnecessary(i_v,1)		= true;
					else
						% The field names exist in the reference project parameters:
						if strcmp(f1,'obj')&&isfield(T_ref_index.f1,'defobj')
							% If f1=T.FIELD1{r}='obj':
							% Check whether the element exists in T_ref_index.f1.defobj:
							i_ref_l		= ...
								T_ref_index.f1.defobj            & ...
								T_ref_index.f2.(f2)              & ...
								T_ref_index.f3.emptyfields       & ...
								T_ref_index.f4.emptyfields       & ...
								T_ref_index.snmc1.(snmc1)        & ...
								T_ref_index.snmc2.(snmc2)        & ...
								T_ref_index.snmc3.emptyfields    & ...
								T_ref_index.snmc4.emptyfields;
							r1_ref_max	= 2;
							r2_ref_max	= max(T_ref_index.r2(i_ref_l,1));
							c1_ref_max	= 1;
							c2_ref_max	= max(T_ref_index.c2(i_ref_l,1));
						else
							if    strcmp(f1,'legend') &&isfield(T_ref_index.f1,'legend')    &&...
									strcmp(f2,'element')&&isfield(T_ref_index.f2,'defelement')
								% If f1=T.FIELD1{r}='legend' and f2=T.FIELD2{r}='element':
								% Check whether the element exists in T_ref_index.f1.legend and T_ref_index.f2.defelement:
								i_ref_l		= ...
									T_ref_index.f1.legend            & ...
									T_ref_index.f2.defelement        & ...
									T_ref_index.f3.emptyfields       & ...
									T_ref_index.f4.emptyfields       & ...
									T_ref_index.snmc1.(snmc1)        & ...
									T_ref_index.snmc2.(snmc2)        & ...
									T_ref_index.snmc3.emptyfields    & ...
									T_ref_index.snmc4.emptyfields;
								r1_ref_max	= 1;
								r2_ref_max	= 2;
								c1_ref_max	= 1;
								c2_ref_max	= 2;
							else
								i_ref_l		= ...
									T_ref_index.f1.(f1)              & ...
									T_ref_index.f2.(f2)              & ...
									T_ref_index.f3.emptyfields       & ...
									T_ref_index.f4.emptyfields       & ...
									T_ref_index.snmc1.(snmc1)        & ...
									T_ref_index.snmc2.(snmc2)        & ...
									T_ref_index.snmc3.emptyfields    & ...
									T_ref_index.snmc4.emptyfields;
								r1_ref_max	= max(T_ref_index.r1(i_ref_l,1));
								r2_ref_max	= max(T_ref_index.r2(i_ref_l,1));
								c1_ref_max	= max(T_ref_index.c1(i_ref_l,1));
								c2_ref_max	= max(T_ref_index.c2(i_ref_l,1));
							end
						end
						
						if ~any(i_ref_l)
							% The complete combination of field names and snmc does not exist in the reference project parameters:
							r_unnecessary(i_v,1)		= true;
						else
							for k=1:kmax
								i		= i_v(k);
								if ~r_tested(i,1)
									r_tested(i,1)	= true;
									r1					= T_index.r1(i,1);
									r2					= T_index.r2(i,1);
									c1					= T_index.c1(i,1);
									c2					= T_index.c2(i,1);
									if    ((r1_ref_max==1)&&(r1>1))||...
											((r2_ref_max==1)&&(r2>1))
										% The reference project parameters have only one row and
										% the project parameters have more than one row:
										r_unnecessary(i,1)		= true;
									else
										if    ((c1_ref_max==1)&&(c1>1))||...
												((c2_ref_max==1)&&(c2>1))
											% The reference project parameters have only one column and
											% the project parameters have more than one column:
											r_unnecessary(i,1)		= true;
										end
									end
								end
							end
						end
						
					end
					
				else
					
					% -----------------------------------------------------------------------------------------------------
					% Data in field 1,2 and 3:
					if isempty(f4)||isempty(snmc4)
						% No data in field 4:
						
						i_l		= ...
							T_index.f1.(f1)          & ...
							T_index.f2.(f2)          & ...
							T_index.f3.(f3)          & ...
							T_index.f4.emptyfields   & ...
							T_index.snmc1.(snmc1)    & ...
							T_index.snmc2.(snmc2)    & ...
							T_index.snmc3.(snmc3)    & ...
							T_index.snmc4.emptyfields;
						i_v		= find(i_l);
						kmax		= length(i_v);
						
						if    ~isfield(T_ref_index.f1   ,f1   )||...
								~isfield(T_ref_index.f2   ,f2   )||...
								~isfield(T_ref_index.f3   ,f3   )||...
								~isfield(T_ref_index.snmc1,snmc1)||...
								~isfield(T_ref_index.snmc2,snmc2)||...
								~isfield(T_ref_index.snmc3,snmc3)
							% The field names does not exist in the reference project parameters:
							r_unnecessary(i_v,1)		= true;
						else
							
							% The field names exist in the reference project parameters:
							if strcmp(f1,'obj')&&isfield(T_ref_index.f1,'defobj')
								% If f1=T.FIELD1{r}='obj':
								% Check whether the element exists in T_ref_index.f1.defobj:
								i_ref_l		= ...
									T_ref_index.f1.defobj            & ...
									T_ref_index.f2.(f2)              & ...
									T_ref_index.f3.(f3)              & ...
									T_ref_index.f4.emptyfields       & ...
									T_ref_index.snmc1.(snmc1)        & ...
									T_ref_index.snmc2.(snmc2)        & ...
									T_ref_index.snmc3.(snmc3)        & ...
									T_ref_index.snmc4.emptyfields;
								r1_ref_max	= 2;
								r2_ref_max	= max(T_ref_index.r2(i_ref_l,1));
								r3_ref_max	= max(T_ref_index.r3(i_ref_l,1));
								c1_ref_max	= 1;
								c2_ref_max	= max(T_ref_index.c2(i_ref_l,1));
								c3_ref_max	= max(T_ref_index.c3(i_ref_l,1));
							else
								if    strcmp(f1,'legend') &&isfield(T_ref_index.f1,'legend')    &&...
										strcmp(f2,'element')&&isfield(T_ref_index.f2,'defelement')
									% If f1=T.FIELD1{r}='legend' and f2=T.FIELD2{r}='element':
									% Check whether the element exists in T_ref_index.f1.legend and T_ref_index.f2.defelement:
									i_ref_l		= ...
										T_ref_index.f1.legend            & ...
										T_ref_index.f2.defelement        & ...
										T_ref_index.f3.(f3)              & ...
										T_ref_index.f4.emptyfields       & ...
										T_ref_index.snmc1.(snmc1)        & ...
										T_ref_index.snmc2.(snmc2)        & ...
										T_ref_index.snmc3.(snmc3)        & ...
										T_ref_index.snmc4.emptyfields;
									r1_ref_max	= 1;
									r2_ref_max	= 2;
									r3_ref_max	= max(T_ref_index.r3(i_ref_l,1));
									c1_ref_max	= 1;
									c2_ref_max	= 2;
									c3_ref_max	= max(T_ref_index.c3(i_ref_l,1));
								else
									i_ref_l		= ...
										T_ref_index.f1.(f1)              & ...
										T_ref_index.f2.(f2)              & ...
										T_ref_index.f3.(f3)              & ...
										T_ref_index.f4.emptyfields       & ...
										T_ref_index.snmc1.(snmc1)        & ...
										T_ref_index.snmc2.(snmc2)        & ...
										T_ref_index.snmc3.(snmc3)        & ...
										T_ref_index.snmc4.emptyfields;
									r1_ref_max	= max(T_ref_index.r1(i_ref_l,1));
									r2_ref_max	= max(T_ref_index.r2(i_ref_l,1));
									r3_ref_max	= max(T_ref_index.r3(i_ref_l,1));
									c1_ref_max	= max(T_ref_index.c1(i_ref_l,1));
									c2_ref_max	= max(T_ref_index.c2(i_ref_l,1));
									c3_ref_max	= max(T_ref_index.c3(i_ref_l,1));
								end
							end
							
							if ~any(i_ref_l)
								% The complete combination of field names and snmc does not exist in the reference project parameters:
								r_unnecessary(i_v,1)		= true;
							else
								for k=1:kmax
									i		= i_v(k);
									if ~r_tested(i,1)
										r_tested(i,1)	= true;
										r1					= T_index.r1(i,1);
										r2					= T_index.r2(i,1);
										r3					= T_index.r3(i,1);
										c1					= T_index.c1(i,1);
										c2					= T_index.c2(i,1);
										c3					= T_index.c3(i,1);
										if    ((r1_ref_max==1)&&(r1>1))||...
												((r2_ref_max==1)&&(r2>1))||...
												((r3_ref_max==1)&&(r3>1))
											% The reference project parameters have only one row and
											% the project parameters have more than one row:
											r_unnecessary(i,1)		= true;
										else
											if    ((c1_ref_max==1)&&(c1>1))||...
													((c2_ref_max==1)&&(c2>1))||...
													((c3_ref_max==1)&&(c3>1))
												% The reference project parameters have only one column and
												% the project parameters have more than one column:
												r_unnecessary(i,1)		= true;
											end
										end
									end
								end
							end
							
						end
						
					else
						
						% -----------------------------------------------------------------------------------------------------
						% Data in field 1,2,3 and 4:
						
						i_l		= ...
							T_index.f1.(f1)          & ...
							T_index.f2.(f2)          & ...
							T_index.f3.(f3)          & ...
							T_index.f4.(f4)          & ...
							T_index.snmc1.(snmc1)    & ...
							T_index.snmc2.(snmc2)    & ...
							T_index.snmc3.(snmc3)    & ...
							T_index.snmc4.(snmc4);
						i_v		= find(i_l);
						kmax		= length(i_v);
						
						if    ~isfield(T_ref_index.f1   ,f1   )||...
								~isfield(T_ref_index.f2   ,f2   )||...
								~isfield(T_ref_index.f3   ,f3   )||...
								~isfield(T_ref_index.f4   ,f4   )||...
								~isfield(T_ref_index.snmc1,snmc1)||...
								~isfield(T_ref_index.snmc2,snmc2)||...
								~isfield(T_ref_index.snmc3,snmc3)||...
								~isfield(T_ref_index.snmc4,snmc4)
							% The field names does not exist in the reference project parameters:
							r_unnecessary(i_v,1)		= true;
						else
							
							% The field names exist in the reference project parameters:
							if strcmp(f1,'obj')&&isfield(T_ref_index.f1,'defobj')
								% If f1=T.FIELD1{r}='obj':
								% Check whether the element exists in T_ref_index.f1.defobj:
								i_ref_l		= ...
									T_ref_index.f1.defobj        & ...
									T_ref_index.f2.(f2)          & ...
									T_ref_index.f3.(f3)          & ...
									T_ref_index.f4.(f4)          & ...
									T_ref_index.snmc1.(snmc1)    & ...
									T_ref_index.snmc2.(snmc2)    & ...
									T_ref_index.snmc3.(snmc3)    & ...
									T_ref_index.snmc4.(snmc4);
								r1_ref_max	= 2;
								r2_ref_max	= max(T_ref_index.r2(i_ref_l,1));
								r3_ref_max	= max(T_ref_index.r3(i_ref_l,1));
								r4_ref_max	= max(T_ref_index.r4(i_ref_l,1));
								c1_ref_max	= 1;
								c2_ref_max	= max(T_ref_index.c2(i_ref_l,1));
								c3_ref_max	= max(T_ref_index.c3(i_ref_l,1));
								c4_ref_max	= max(T_ref_index.c4(i_ref_l,1));
							else
								if    strcmp(f1,'legend') &&isfield(T_ref_index.f1,'legend')    &&...
										strcmp(f2,'element')&&isfield(T_ref_index.f2,'defelement')
									% If f1=T.FIELD1{r}='legend' and f2=T.FIELD2{r}='element':
									% Check whether the element exists in T_ref_index.f1.legend and T_ref_index.f2.defelement:
									i_ref_l		= ...
										T_ref_index.f1.legend        & ...
										T_ref_index.f2.defelement    & ...
										T_ref_index.f3.(f3)          & ...
										T_ref_index.f4.(f4)          & ...
										T_ref_index.snmc1.(snmc1)    & ...
										T_ref_index.snmc2.(snmc2)    & ...
										T_ref_index.snmc3.(snmc3)    & ...
										T_ref_index.snmc4.(snmc4);
									r1_ref_max	= 1;
									r2_ref_max	= 2;
									r3_ref_max	= max(T_ref_index.r3(i_ref_l,1));
									r4_ref_max	= max(T_ref_index.r4(i_ref_l,1));
									c1_ref_max	= 1;
									c2_ref_max	= 2;
									c3_ref_max	= max(T_ref_index.c3(i_ref_l,1));
									c4_ref_max	= max(T_ref_index.c4(i_ref_l,1));
								else
									i_ref_l		= ...
										T_ref_index.f1.(f1)          & ...
										T_ref_index.f2.(f2)          & ...
										T_ref_index.f3.(f3)          & ...
										T_ref_index.f4.(f4)          & ...
										T_ref_index.snmc1.(snmc1)    & ...
										T_ref_index.snmc2.(snmc2)    & ...
										T_ref_index.snmc3.(snmc3)    & ...
										T_ref_index.snmc4.(snmc4);
									r1_ref_max	= max(T_ref_index.r1(i_ref_l,1));
									r2_ref_max	= max(T_ref_index.r2(i_ref_l,1));
									r3_ref_max	= max(T_ref_index.r3(i_ref_l,1));
									r4_ref_max	= max(T_ref_index.r4(i_ref_l,1));
									c1_ref_max	= max(T_ref_index.c1(i_ref_l,1));
									c2_ref_max	= max(T_ref_index.c2(i_ref_l,1));
									c3_ref_max	= max(T_ref_index.c3(i_ref_l,1));
									c4_ref_max	= max(T_ref_index.c4(i_ref_l,1));
								end
							end
							
							if ~any(i_ref_l)
								% The complete combination of field names and snmc does not exist in the reference project parameters:
								r_unnecessary(i_v,1)		= true;
							else
								for k=1:kmax
									i		= i_v(k);
									if ~r_tested(i,1)
										r_tested(i,1)	= true;
										r1					= T_index.r1(i,1);
										r2					= T_index.r2(i,1);
										r3					= T_index.r3(i,1);
										r4					= T_index.r4(i,1);
										c1					= T_index.c1(i,1);
										c2					= T_index.c2(i,1);
										c3					= T_index.c3(i,1);
										c4					= T_index.c4(i,1);
										if    ((r1_ref_max==1)&&(r1>1))||...
												((r2_ref_max==1)&&(r2>1))||...
												((r3_ref_max==1)&&(r3>1))||...
												((r4_ref_max==1)&&(r4>1))
											% The reference project parameters have only one row and
											% the project parameters have more than one row:
											r_unnecessary(i,1)		= true;
										else
											if    ((c1_ref_max==1)&&(c1>1))||...
													((c2_ref_max==1)&&(c2>1))||...
													((c3_ref_max==1)&&(c3>1))||...
													((c4_ref_max==1)&&(c4>1))
												% The reference project parameters have only one column and
												% the project parameters have more than one column:
												r_unnecessary(i,1)		= true;
											end
										end
									end
								end
							end
							
						end
						
					end
					
				end
				
			end
			
		end
		
	end
	
catch ME
	errormessage('',ME);
end

