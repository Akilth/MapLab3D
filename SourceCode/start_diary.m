function start_diary(pathname)
% Delete an existing diary file and start a new one

global GV

try

	if ~strcmp(pathname(end),'\')
		pathname		= [pathname '\'];
	end
	if ~strcmp(GV.pathname_diary,pathname)
		% Start a new diary at a new location:
		% An existing diary there will be overwritten.
		GV.pathname_diary		= pathname;
		pathfilename_diary 	= [pathname 'diary.txt'];
		diary off;
		if exist(pathfilename_diary,'file')==2
			delete(pathfilename_diary);
		end
		pause(0.1);
		diary(pathfilename_diary);
		diary on;
	end

catch ME
	errormessage('',ME);
end

