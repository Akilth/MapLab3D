function lastlines=display_diary(no_lines)
% Get the last lines of the diary file als text.
% E. g.: lastline = display_diary(10)

try

	if nargin==0
		no_lines	= 1;
	end

	fid				= fopen(get(0,'DiaryFile'),'r');
	offset			= 2;
	lastlines			= '';
	for i=1:no_lines
		status			= fseek(fid,-offset,'eof');	% Seek to the file end, minus the offset
		newchar			= fread(fid,1,'*char');			% Read one character
		while (~strcmp(newchar,newline))&&(status==0)&&(offset<(500*no_lines))		% newline=char(10)='\n'
			lastlines		= [newchar lastlines];			% Add the character to a string
			offset		= offset+1;
			status		= fseek(fid,-offset,'eof');	% Seek to the file end, minus the offset
			if status==-1
				break
			end
			newchar		= fread(fid,1,'*char');			% Read one character
		end
		if status==-1
			break
		end
		if i<no_lines
			lastlines	= [newline lastlines];
			offset		= offset+1;
		end
	end
	fclose(fid);

catch ME
	errormessage('',ME);
end


