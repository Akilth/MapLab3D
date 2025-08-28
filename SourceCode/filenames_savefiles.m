function [map_filename,mapdata_filename,mapdata_filename_ending]=filenames_savefiles(filename_add)

global GV VER

try

	if nargin<1
		filename_add			= '';
	end
	map_filename				= '';
	mapdata_filename			= '';
	mapdata_filename_ending	= '...MAPDATA.mat';				% display on gui

	% Filenames:
	exec_not_possible			= false;
	if ~isfield(GV,'pp_projectfilename')
		exec_not_possible		= true;
	else
		if isempty(GV.pp_projectfilename)
			exec_not_possible		= true;
		end
	end
	if exec_not_possible
		errormessage(sprintf([...
			'A project or project parameters must be\n',...
			'loaded before this function can be executed.']));
	end
	filename_map				= sprintf('%s%s - v%1.0f.%1.0f - MAP',...
		GV.pp_projectfilename,filename_add,VER.no1,VER.no2);
	map_filename				= [filename_map '.fig'];
	mapdata_filename			= [filename_map 'DATA.mat'];

catch ME
	errormessage('',ME);
end

