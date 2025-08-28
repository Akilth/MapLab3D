function number_str=number2str(number,formatspec)

global PP

try

	if isempty(number)
		number_str						= '[]';
	elseif isscalar(number)
		number_str						= sprintf(formatspec,number(1));
	else
		number_str						= '[';
		for r=1:size(number,1)
			for c=1:size(number,2)
				number_str_rc			= sprintf(formatspec,number(r,c));
				if c==1
					number_str			= sprintf('%s%s',number_str,number_str_rc);
				else
					number_str			= sprintf('%s %s',number_str,number_str_rc);
				end
				if c==size(number,2)
					if r<size(number,1)
						number_str		= sprintf('%s;',number_str);
					else
						number_str		= sprintf('%s]',number_str);
					end
				end
			end
		end
	end

	if ~isempty(PP)
		number_str(strfind(number_str,'.'))	= PP.general.decimalseparator;
	end

catch ME
	errormessage('',ME);
end

