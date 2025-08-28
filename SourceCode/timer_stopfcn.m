function timer_stopfcn
% Executes when the timer stops. The timer stops when
% - You call the timer stop method.
% - The timer finishes executing TimerFcn. In other words, the value of TasksExecuted reaches the limit
%   set by TasksToExecute.
% - An error occurs. The ErrorFcn callback is called first, followed by the StopFcn callback.
% You can use StopFcn to define clean up actions, such as deleting the timer object from memory.

global TIMERPROCESS_RESTART

% Because this function can be called through a callback, a try/catch statement must be used here:
try
	
	% disp('call of timer_stopfcn !!!');
	
	% Restart timer process:
	if TIMERPROCESS_RESTART~=0
		% disp('timer_stopfcn: timer_initialization');
		timer_initialization;
	end
	setbreakpoint	= 1;
	
catch ME
	errormessage('',ME);
end

