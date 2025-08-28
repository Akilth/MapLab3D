function [osm_filename_filt,osm_pathname_filt,command]=call_osmfilter(osm_filename,osm_pathname,execute_osmfilter)
% Call of osmfilter.exe in order to reduce the file size of large osm-files.
% This will reduce the time for loading OSM-data.
% For filtering the include tags of the current project are used. Exclude tags will not be considered.
% Osmfilter syntax see: https://wiki.openstreetmap.org/wiki/Osmfilter

global PP GV GV_H

try

	% Initializations:
	use_parameterfile		= true;

	% Destination directory:
	osm_pathname_filt					= GV.projectdirectory;

	% For testing:
	testout					= 1;
	if nargin==0
		execute_osmfilter	= 0;
		osm_filename		= 'BadenWuerttemberg_Sued.pbf';
		osm_pathname		= 'G:\Daten\STA\Themen\Reliefkartendruck\Maplab3d\OSM';
		osm_pathname_filt	= 'G:\Daten\STA\Themen\Reliefkartendruck\Maplab3d\OSM';

		osm_filename		= 'MAHD1.osm';
		osm_pathname		= 'E:\Daten\STA\Themen\Reliefkartendruck\Maplab3d\OSM';
		osm_pathname_filt	= 'E:\Daten\STA\Themen\Reliefkartendruck\Maplab3d\OSM';

		osm_filename		= GV.osm_filename;
		osm_pathname		= GV.osm_pathname;
		osm_pathname_filt	= GV.projectdirectory;
	end

	% Filenames and pathnames:
	[pathname_osmfilterexe,~,~]	= fileparts(mfilename('fullpath'));
	osm_filename_filt					= [osm_filename(1:(end-4)) '_filt.osm'];
	if ~strcmp(pathname_osmfilterexe(end),'\')
		pathname_osmfilterexe		= [pathname_osmfilterexe '\'];
	end
	if ~strcmp(osm_pathname(end),'\')
		osm_pathname					= [osm_pathname '\'];
	end
	if ~strcmp(osm_pathname_filt(end),'\')
		osm_pathname_filt			= [osm_pathname_filt '\'];
	end

	% Create the filter command:
	msg	= sprintf('Calling osmfilter. This may take some time ... ');
	set(GV_H.text_waitbar,'String',msg);
	drawnow;
	parfile	= sprintf('--drop-version\n');															% --drop-author --drop-version
	command	= sprintf('!osmfilter "%s%s" --drop-version',osm_pathname,osm_filename);	% --drop-author --drop-version
	if testout~=0
		fprintf(1,'------------------------------------------------------------------------------------------------\n');
		fprintf(1,'%s\n',command);
	end
	for iobj=1:size(PP.obj,1)
		if ~isempty(PP.obj(iobj).display)
			% If this object number exists:
			if (PP.obj(iobj,1).display~=0)||(PP.obj(iobj,1).symbolpar.display~=0)||(PP.obj(iobj,1).textpar.display~=0)
				[filter_str,error_str]	= keep_string(PP.obj(iobj,1).tag_incl);
				if ~isempty(error_str)
					errortext	= sprintf([...
						'Error:\n',...
						'Objekt number %g:\n',...
						'Include tag:\n',...
						'%s'],iobj,error_str);
					errormessage(errortext);
				end
				if ~isempty(filter_str)
					parfile		= sprintf('%s\n--keep=\n%s\n',parfile,filter_str);
					filter_str	= sprintf(' --keep="%s"',filter_str);
					command		= sprintf('%s%s',command,filter_str);
				end
				if testout~=0
					fprintf(1,'% 4.0f  %s\n',iobj,filter_str);
				end
				% Texts:
				if isfield(PP.obj(iobj,1).textpar,'tag_incl')
					[filter_str,error_str]	= keep_string(PP.obj(iobj,1).textpar.tag_incl);
					if ~isempty(error_str)
						errortext	= sprintf([...
							'Error:\n',...
							'Objekt number %g, Texts:\n',...
							'Include tag:\n',...
							'%s'],iobj,error_str);
						errormessage(errortext);
					end
					if ~isempty(filter_str)
						parfile		= sprintf('%s\n--keep=\n%s\n',parfile,filter_str);
						filter_str	= sprintf(' --keep="%s"',filter_str);
						command		= sprintf('%s%s',command,filter_str);
					end
					if testout~=0
						fprintf(1,'% 4.0f  %s\n',iobj,filter_str);
					end
				end
				% Symbols:
				if isfield(PP.obj(iobj,1).symbolpar,'tag_incl')
					[filter_str,error_str]	= keep_string(PP.obj(iobj,1).symbolpar.tag_incl);
					if ~isempty(error_str)
						errortext	= sprintf([...
							'Error:\n',...
							'Objekt number %g, Symbols:\n',...
							'Include tag:\n',...
							'%s'],iobj,error_str);
						errormessage(errortext);
					end
					if ~isempty(filter_str)
						parfile		= sprintf('%s\n--keep=\n%s\n',parfile,filter_str);
						filter_str	= sprintf(' --keep="%s"',filter_str);
						command		= sprintf('%s%s',command,filter_str);
					end
					if testout~=0
						fprintf(1,'% 4.0f  %s\n',iobj,filter_str);
					end
				end
			end
		end
	end
	command_dest	= sprintf('>"%s%s"',osm_pathname_filt,osm_filename_filt);
	command			= sprintf('%s %s',command,command_dest);
	if testout~=0
		fprintf(1,'%s\n',command_dest);
		fprintf(1,'------------------------------------------------------------------------------------------------\n');
	end

	% Execute the filter command:
	oldfolder		= cd(pathname_osmfilterexe);
	if use_parameterfile
		% If there are many keep statements, the osmfilter command can become too long and osmfilter returns
		% the message "Die Befehlszeile ist zu lang." and does not create a file.
		% This problem does not appear to occur with the parameter file.
		parfile_filename	= [osm_filename(1:(end-4)) '_osmfilter_parameterfile.txt'];
		% Overwrite the command:
		command	= sprintf('!osmfilter "%s%s" --parameter-file="%s%s" %s',...
			osm_pathname,osm_filename,osm_pathname_filt,parfile_filename,command_dest);
	end
	if execute_osmfilter~=0
		if use_parameterfile
			% Save the parameter file:
			fileID				= fopen([osm_pathname_filt parfile_filename],'w');
			fprintf(fileID,'%s',parfile);
			fclose(fileID);
		end
		try
			eval(command);
		catch ME
			errormessage('',ME);
		end
		cd(oldfolder);
	end
	if use_parameterfile
		% For check if the OSM-data has to be reloaded, because the osmfilter-command has been changed:
		% Compare the content of the parameter file:
		command		= parfile;
	end

catch ME
	errormessage('',ME);
end




function [filter_str,error_str]=keep_string(tag)

try

	% Create the filter string. Example:
	% waterway=river and ( name=Rhein or name=Neckar )
	filter_str	= '';
	error_str	= '';
	for r=1:size(tag,1)
		% r: row number: the criteria of all rows are combined by a logical AND.
		filter_r_str	= '';
		for c=1:size(tag,2)
			% c: column number: the criteria of all columns of one row are combined by a logical OR.
			key	= tag(r,c).k;
			op1	= tag(r,c).op;
			val	= tag(r,c).v;
			if isempty(key)
				key	= '';
			end
			if isempty(op1)
				op1	= '';
			end
			if isempty(val)
				val	= '';
			end
			% Replace blanks by '\ ':
			k_v		= strfind(val,' ');
			for i=1:length(k_v)
				val((k_v(i)+1):(end+1))	= val(k_v(i):end);
				val(k_v(i))					= '\';
				k_v							= k_v+1;
			end
			% Replace operators:
			% osmfilter accepts: = != < > <= >=
			switch op1
				case '=='
					op2	= '=';
				case '~='
					op2	= '!=';
				otherwise
					op2	= op1;
			end
			% Filter string:
			if c==1
				or_str	= '';
			else
				or_str	= ' or ';
			end
			if ~isempty(key)&&~isempty(val)
				filter_r_str	= sprintf('%s%s%s%s%s',filter_r_str,or_str,key,op2,val);
			elseif ~isempty(key)
				filter_r_str	= sprintf('%s%s%s=',filter_r_str,or_str,key);
			elseif ~isempty(val)
				error_str	= sprintf([...
					'Row = %g\n',...
					'Column = %g\n',...
					'Value = %s\n',...
					'When calling osmfilter.exe, filtering of\n',...
					'values without key is not possible.\n',...
					'You have to define also a key.\n',...
					],r,c,val);
				return
			end
		end
		if ~isempty(filter_r_str)
			if r==1
				filter_r_str	= sprintf('( %s',filter_r_str);
			else
				filter_r_str	= sprintf(' and ( %s',filter_r_str);
			end
			filter_r_str	= sprintf('%s )',filter_r_str);
			filter_str		= sprintf('%s%s',filter_str,filter_r_str);
		end
	end

catch ME
	errormessage('',ME);
end

