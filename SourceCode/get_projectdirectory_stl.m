function [projectdirectory_stl,projectdirectory_stl_repaired]=...
	get_projectdirectory_stl(projectdirectory,testsample_no)

try

	if testsample_no==0
		projectdirectory_stl	= [projectdirectory 'STL\'];
		if exist(projectdirectory_stl,'dir')~=7
			[status,msg] = mkdir(projectdirectory_stl);
			if status~=1
				errortext	= sprintf([...
					'Error when creating the directory:\n',...
					'%s\n',...
					'\n',...
					'%s'],projectdirectory_stl,msg);
				errormessage(errortext);
			end
		end
		projectdirectory_stl_repaired	= [projectdirectory 'STL_repaired\'];
		if exist(projectdirectory_stl_repaired,'dir')~=7
			[status,msg] = mkdir(projectdirectory_stl_repaired);
			if status~=1
				errortext	= sprintf([...
					'Error when creating the directory:\n',...
					'%s\n',...
					'\n',...
					'%s'],projectdirectory_stl_repaired,msg);
				errormessage(errortext);
			end
		end
	else
		projectdirectory_stl				= projectdirectory;
		projectdirectory_stl_repaired	= projectdirectory;
	end

catch ME
	errormessage('',ME);
end

