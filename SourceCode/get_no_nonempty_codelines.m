function get_no_nonempty_codelines

pathname			= 'C:\Daten\Projekte\MapLab3D\SourceCode';
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
no_lines_sum/no_files
