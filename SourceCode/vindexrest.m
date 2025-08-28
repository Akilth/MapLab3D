function y=vindexrest(i,n)
% vindexrest converts a vector index i according to the modulo principle to the permissible range 1..n.
% Remarks:
% a) The variables i and n must heve values of the INTEGER type.
% b) The index i can also be negative.
% c) If n = 0, the function returns the value 1 in order to avoid a program error.
%    However, this case should be caught before the function is called.
% d) i can also be a vector.
% The result ist always a column vector.
%
% Example:
% n = 10;
% k = 1:n;
% x = k-5
% y = vindexrest(x,n)

% without try/catch: a little bit faster

% try

	i=i(:);
	if n==0
		y=1;
	else
		y=i-floor((i-1)/n)*n;
	end

% catch ME
% 	errormessage('',ME);
% end

