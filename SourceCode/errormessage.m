function errormessage(errortext,ME)
% errortext		text to display
% ME				MException object
%					Use try, catch to access the information captured in an MException object:
%					try
%					    surf
%					catch ME							% Always use ME after catch, otherwise
%					    errormessage('',ME);	% a second error dialog box will be opened here
%					end
%
% Calls of errormessage without saving errorlog data:
% 1)	errormessage(errortext);
%
% Calls of errormessage with saving errorlog data:
% 1)	errormessage;
% 2)	Inside a try-catch statement:
%		try
%			code...
%		catch ME
%			errormessage('',ME);
%		end
% 3)	Outside a try-catch statement:
%		errormessage(errortext,MException(GV.errID_general,''));

global WAITBAR APP GV_H VER GV ST

% Initializations:
if nargin==0
	errortext				= '';
end
if nargin<=1
	ME.identifier			= '';
	ME.message				= '';
	ME.stack					= struct('file','','name','','line',[]);
end
if nargin>2
	errormessage;
end
ST										= dbstack;
copy_errorlog0_to_clipboard	= true;

% Extend the error message:
[pathname,~,~]		= fileparts(mfilename('fullpath'));
[~,errortext_errorlog]	= get_savecommand_errorlog([],pathname);
if isempty(errortext)
	errortext		= 'An error has occurred.';
else
	% "An error has occurred." is not necessary.
	% errortext		= sprintf('An error has occurred.\n\n%s',errortext);
end
if ~isempty(ME.message)||isequal(ME.identifier,GV.errID_general)
	% If there is an MException object: Extend the error text using ME:
	save_errorlog	= true;		% The evalin function takes much time: save the errorlog only at unexpected errors.
	if save_errorlog
		if ~isempty(ME.message)
			errorlog0		= sprintf('Error message:\n%s\n\n',ME.message);
		else
			errorlog0		= '';
		end
	else
		errorlog0		= '';
	end
	if ~isempty(VER)
		errorlog0	=	sprintf('%sDetails: MapLab3D %1.0f.%1.0f.%1.0f.%1.0f',errorlog0,VER.no1,VER.no2,VER.no3,VER.no4);
	else
		errorlog0	= sprintf('%sDetails:',errorlog0);
	end
	if ~isempty(ME.stack)
		for k=1:length(ME.stack)
			if strcmp(ME.stack(k).name,'errormessage')
				% The exception was thrown because of an error in exactly this function errormessage.
				% Do not execute the error command a second time:
				% Rethrow preserves the original exception information and enables you to retrace the
				% source of the original error:
				rethrow(ME);
			end
			errorlog0=sprintf('%s\n%1.0f) %s (%g)',...
				errorlog0,...
				k,...
				ME.stack(k).name,...
				ME.stack(k).line);
			if isequal(strfind(lower(ME.stack(k).name),'maplab3d.'),1)
				break
			end
		end
	else
		% Constructed Mexception objects does not have a stack information:
		if ~isempty(ST)
			for k=1:length(ST)
				errorlog0=sprintf('%s\n%1.0f) %s (%g)',...
					errorlog0,...
					k,...
					ST(k).name,...
					ST(k).line);
				if isequal(strfind(lower(ST(k).name),'maplab3d.'),1)
					break
				end
			end
		end
	end
else
	% If there is no MException object:
	if nargin==0
		% The evalin function takes much time: save the errorlog only at unexpected errors.
		% Normally the function is called without an explanatory text in case of unknown errors.
		save_errorlog	= true;
	else
		save_errorlog	= false;
	end
	if ~isempty(VER)
		errorlog0	= sprintf('Details: MapLab3D %1.0f.%1.0f.%1.0f.%1.0f',VER.no1,VER.no2,VER.no3,VER.no4);
	else
		errorlog0	= 'Details:';
	end
	if ~isempty(ST)
		for k=1:length(ST)
			errorlog0=sprintf('%s\n%1.0f) %s (%g)',...
				errorlog0,...
				k,...
				ST(k).name,...
				ST(k).line);
			if isequal(strfind(lower(ST(k).name),'maplab3d.'),1)
				break
			end
		end
	end
end
% Copy the error message to the clipboard:
if save_errorlog&&copy_errorlog0_to_clipboard
	clipboard('copy',errorlog0);
	errorlog0	= sprintf('%s\n\nError message and details have been copied to the clipboard.',errorlog0);
end
% Append "Use ..\errorlog_data.mat for debugging.":
if save_errorlog
	errorlog		= sprintf('%s\n\n%s',errorlog0,errortext_errorlog);
	errortext	= sprintf('%s\n\n%s',errortext,errorlog);
	fprintf(1,'\n%s\n\n',errortext);
else
	errorlog		= errorlog0;
	fprintf(1,'\n%s\n\n%s\n\n',errortext,errorlog);
end

% Save errormessage:
GV.errormessage.ME			= ME;
GV.errormessage.ST			= ST;
GV.errormessage.errortext	= errortext;
GV.errormessage.errorlog	= errorlog;
try
	GV.errormessage.diary		= fileread([GV.pathname_diary 'diary.txt']);
catch
	GV.errormessage.diary		= sprintf('Error when loading %s',[GV.pathname_diary 'diary.txt']);
end

% Save the errorlog with the workspace of the function that called errormessage.m:
% Remark:	[pathname_error,filename_error,~]	= fileparts(mfilename('fullpath'));
%				filename_error='errormessage' ==> fileparts doesn't work properly together with evalin
if save_errorlog
	expression						= sprintf([...
		'global VER GV\n',...
		'[pathname_error,~,~]	= fileparts(mfilename(''fullpath''));\n',...
		'C						= who;\n',...
		'iC_delete			= [];\n',...
		'for iC=1:size(C,1)\n',...
		'	if eval(sprintf(''isa(%%s,''''matlab.ui.Figure'''')'',C{iC,1}))\n',...
		'		iC_delete	= [iC_delete;iC];\n',...
		'	end\n',...
		'	if strcmp(C{iC,1},''event'')\n',...
		'		iC_delete	= [iC_delete;iC];\n',...
		'	end\n',...
		'end\n',...
		'C(iC_delete,:)	= [];\n',...
		'[save_command,~]	= get_savecommand_errorlog(C,pathname_error);\n',...
		'eval(save_command);']);
	evalin('caller',expression);
end

% Close an existing "Select by filter" figure:
if isfield(GV_H,'mapobjects_select_by_filter_getuserinput')
	if isvalid(GV_H.mapobjects_select_by_filter_getuserinput)
		delete(GV_H.mapobjects_select_by_filter_getuserinput);
	end
end

% Close an existing waitbar:
if ~isempty(WAITBAR)
	if isfield(WAITBAR,'h')
		if ishandle(WAITBAR.h)
			close(WAITBAR.h);
		end
	end
end

% Reset waitbar:
if ~isempty(APP)
	if isfield(GV_H,'patch_waitbar')
		if isvalid(GV_H.patch_waitbar)
			set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
		end
	end
	if isfield(GV_H,'text_waitbar')
		if isvalid(GV_H.text_waitbar)
			set(GV_H.text_waitbar,'String','');
		end
	end
end

% Log entry:
display_on_gui('state',sprintf('Canceled due to error.'),'notbusy','add');

% Create an error dialog box:
h			= errordlg(errortext,'Error','modal');
h.Tag		= 'maplab3d_figure';
figure(h);		% Bring the error dialog box to the front.
drawnow;			% Wait that the busy state color has changed from red to green.

% Throw error and display message:
error(errortext);

