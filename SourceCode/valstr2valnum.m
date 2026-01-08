function value=valstr2valnum(value)
% Conversion of a character array that represents a scalar number into a number
% with handling of incorrect comma usage:
k_c = find(value==',');
k_p = find(value=='.');
l_c = length(k_c);
l_p = length(k_p);

if (l_c == 1) && (l_p==  0)									% 123,456

	% Incorrect use of ',' is more likely than use as a thousands separator:
	value(k_c) = '.';

elseif (l_c==1)&&(l_p>=1)&&(k_c>max(k_p))			% 1.234.567,89

	% Delete the thousands separators and replace the comma:
	value(k_p) = '';
	value(value == ',')	= '.';

elseif (l_p==1)&&(l_c>=1)&&(k_p>max(k_c))			% 1,234,567.89

	% Delete the thousands separators:
	value(k_c) = '';

end

value = str2double(value);

