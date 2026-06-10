function file_ext=get_file_extension(command,formattype)

if length(formattype)>=1
	if strcmp(formattype(1),'-')
		formattype(1)	= [];
	end
end
switch command
	case 'print'
		switch formattype
			case 'djpeg'
				file_ext	= '.jpg';
			case 'dpng'
				file_ext	= '.png';
			case 'dtiff'
				file_ext	= '.tif';
			case 'dtiffn'
				file_ext	= '.tif';
			case 'dmeta'
				file_ext	= '.emf';
			case 'dpdf'
				file_ext	= '.pdf';
			case 'deps'
				file_ext	= '.eps';
			case 'depsc'
				file_ext	= '.eps';
			case 'deps2'
				file_ext	= '.eps';
			case 'depsc2'
				file_ext	= '.eps';
			case 'dsvg'
				file_ext	= '.svg';
			otherwise
				file_ext	= '';
		end
	otherwise
		errormessage;
end
