function get_no_nonempty_codelines

global PP

pathname			= 'C:\Daten\Projekte\MapLab3D\SourceCode';
pathname			= 'C:\Daten\STA\abgeschlossene Arbeiten\2026 SS Braun Janik\Programm_nurBraun';
listing			= dir(pathname);
no_files			= size(listing,1);
no_lines_sum	= 0;
no_lines_min	= 1e10;
no_lines_max	= 0;
for i=1:no_files
	if ~listing(i,1).isdir
		kp		= strfind(listing(i,1).name,'.');
		if ~isempty(kp)
			switch listing(i,1).name((kp(end)+1):end)
				case {'m';'mlapp'}
					no_lines		= size(readlines([...
						listing(i,1).folder '\' ...
						listing(i,1).name],...
						'EmptyLineRule','skip'),1);			% read skip
					no_lines_sum	= no_lines_sum+no_lines;
					no_lines_min	= min(no_lines_min,no_lines);
					no_lines_max	= max(no_lines_max,no_lines);
					% fprintf(1,'%g   %s\n',no_lines,listing(i,1).name);
			end
			
		end
	end
end
no_lines_sum
no_lines_min
no_lines_max
no_files
no_lines_sum__no_files=no_lines_sum/no_files

% Number of lines in the project parameter file:
fn				= fieldnames(PP.TABLE_ROWNO.obj(end,1).symbolpar);
no_lines_pp	= 0;
for ifn=1:size(fn,1)
	no_lines_pp	= max(no_lines_pp,PP.TABLE_ROWNO.obj(end,1).symbolpar.(fn{ifn,1}));
end
no_lines_pp

