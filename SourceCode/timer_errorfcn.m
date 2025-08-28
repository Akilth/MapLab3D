function timer_errorfcn

% Because this function can be called through a callback, a try/catch statement must be used here:
try
	
	% disp('call of timer_errorfcn !!!');
	setbreakpoint	= 1;
	
catch ME
	errormessage('',ME);
end

