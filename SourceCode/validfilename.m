function filename=validfilename(filename)

try

	% Delete certain special characters:
	filename(strfind(filename,'°'))	= '';
	filename(strfind(filename,'!'))	= '';
	filename(strfind(filename,'"'))	= '';
	filename(strfind(filename,'§'))	= '';
	filename(strfind(filename,'$'))	= '';
	filename(strfind(filename,'%'))	= '';
	filename(strfind(filename,'&'))	= '';
	filename(strfind(filename,'/'))	= '';
	filename(strfind(filename,'('))	= '';
	filename(strfind(filename,')'))	= '';
	filename(strfind(filename,'{'))	= '';
	filename(strfind(filename,'}'))	= '';
	filename(strfind(filename,'['))	= '';
	filename(strfind(filename,']'))	= '';
	filename(strfind(filename,'?'))	= '';
	filename(strfind(filename,'\'))	= '';
	filename(strfind(filename,'´'))	= '';
	filename(strfind(filename,'`'))	= '';
	filename(strfind(filename,'~'))	= '';
	filename(strfind(filename,'#'))	= '';
	filename(strfind(filename,''''))	= '';
	filename(strfind(filename,'<'))	= '';
	filename(strfind(filename,'>'))	= '';
	filename(strfind(filename,'|'))	= '';
	filename(strfind(filename,','))	= '';
	filename(strfind(filename,'.'))	= '';
	filename(strfind(filename,':'))	= '';
	filename(strfind(filename,';'))	= '';
	filename(strfind(filename,':'))	= '';
	filename(strfind(filename,'*'))	= '';
	% Delete double blanks:
	k	= length(filename)+1;
	while length(filename)<k
		k	= length(filename);
		filename(strfind(filename,'  '))	= '';
	end
	% Replace certain special characters:
	spec_char	= {...		% The first column must contain only single characters.
		'ä'	'ae';...
		'ü'	'ue';...
		'ö'	'oe';...
		'Ä'	'Ae';...
		'Ü'	'Ue';...
		'Ö'	'Oe';...
		'ß'	'ss'};
	for isc=1:size(spec_char,1)
		k	= strfind(filename,spec_char{isc,1});
		lsc2	= length(spec_char{isc,2});
		while ~isempty(k)
			kmax	= length(filename);
			filename((k(1)+lsc2):(kmax+lsc2-1))	= filename((k(1)+1):kmax);
			filename(k(1):(k(1)+lsc2-1))			= spec_char{isc,2};
			k		= strfind(filename,spec_char{isc,1});
		end
	end
	if isempty(filename)
		filename	= 'X';
	end

catch ME
	errormessage('',ME);
end

