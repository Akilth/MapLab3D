function show_errorlog

try

	% load('errorlog_data.mat');
	load('C:\Daten\Projekte\Maplab3d\Projects\Testprojekt\errorlog_data.mat');
	% clc

	whos

	% stack and errortext:
	fprintf(1,'\nGV.errormessage.ST:\n');
	if ~isempty(GV.errormessage.ST)
		for k=1:length(GV.errormessage.ST)
			fprintf(1,'%1.0f) %s (%g)\n',...
				k,...
				GV.errormessage.ST(k).name,...
				GV.errormessage.ST(k).line);
		end
	end
	fprintf(1,'\nGV.errormessage.ME.stack:\n');
	if ~isempty(GV.errormessage.ME.stack)
		for k=1:length(GV.errormessage.ME.stack)
			fprintf(1,'%1.0f) %s (%g)\n',...
				k,...
				GV.errormessage.ME.stack(k).name,...
				GV.errormessage.ME.stack(k).line);
		end
	end
	fprintf(1,'\n');
	errortext	= GV.errormessage.errortext
	errorlog		= GV.errormessage.errorlog
	fprintf(1,'\n');


	% Function call stack:
	% GV.errormessage.ST(1).file		= 'errormessage.m'
	% GV.errormessage.ST(1).name		= 'errormessage'
	% GV.errormessage.ST(1).line		= 23
	% GV.errormessage.ST(2):	File name in which the errormessage function was called.
	%									The current workspace of this file was saved in errorlog_data.mat.
	errorlog_data_functionname	= GV.errormessage.ST(2).name
	errorlog_data_lineno			= GV.errormessage.ST(2).line

	MException_message			= GV.errormessage.ME.message
	MException_functionname		= GV.errormessage.ME.stack(1).name
	MException_lineno				= GV.errormessage.ME.stack(1).line


	diary_str						= GV.errormessage.diary;


	setbreakpoint=1;

catch ME
	errormessage('',ME);
end

