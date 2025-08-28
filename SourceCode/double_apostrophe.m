function text_out=double_apostrophe(text_in)
% Replaces ' by ''
% text_in	= sprintf('asdf''fasd''''as');		% Test

try

	k			= strfind(text_in,'''');
	text_out	= text_in;
	for i=1:length(k)
		text_out((k(i)+i):(end+1))	= text_in(k(i):length(text_in));
	end

catch ME
	errormessage('',ME);
end

