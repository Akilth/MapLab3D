function [save_command,errortext]=get_savecommand_errorlog(C,pathname,filename)
% Syntax:
% % Save errorlog:
% [pathname,~,~]	= fileparts(mfilename('fullpath'));
% C					= who;
% iC_delete		= [];
% for iC=1:size(C,1)
% 	if eval(sprintf('isa(%s,''matlab.ui.Figure'')',C{iC,1}))
% 		iC_delete		= [iC_delete;iC];
% 	end
% end
% C(iC_delete,:)	= [];
% [save_command,errortext]	= get_savecommand_errorlog(C,pathname);
% eval(save_command);
% errormessage(errortext);

global GV

try

	if nargin==2
		filename	= 'errorlog_data';
	end

	if ~strcmp(pathname(end),'\')
		pathname	= [pathname '\'];
	end

	variables_str	= '';
	for iC=1:size(C,1)
		if    ~strcmp(C{iC,1},'app')&&...
				~strcmp(C{iC,1},'APP')&&...
				~strcmp(C{iC,1},'GV_H')
			if isempty(variables_str)
				variables_str	= C{iC,1};
			else
				variables_str	= sprintf('%s'',''%s',variables_str,C{iC,1});
			end
		end
	end
	variables_str	= sprintf('''%s''',variables_str);
	use_projectdirectory			= true;
	if ~isfield(GV,'projectdirectory')

		use_projectdirectory			= false;
	else
		if exist(GV.projectdirectory,'dir')~=7
			use_projectdirectory			= false;
		end
	end
	if use_projectdirectory
		srce_data		= sprintf('%s%s.mat',pathname,filename);
		dest_data		= sprintf('%s%s.mat',GV.projectdirectory,filename);
		save_command	= sprintf([...
			'save(''%s'',%s);',...
			'copyfile(''%s'',''%s'');'],...
			srce_data,variables_str,...
			srce_data,dest_data);
		errortext		= sprintf([...
			'Use\n',...
			'%s%s.mat\n',...
			'for debugging.'],GV.projectdirectory,filename);
	else
		save_command	= sprintf('save(''%s%s.mat'',%s);',pathname,filename,variables_str);
		errortext		= sprintf([...
			'Use\n',...
			'%s%s.mat\n',...
			'for debugging.'],pathname,filename);
	end

catch ME
	errormessage('',ME);
end

