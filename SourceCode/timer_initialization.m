function timer_initialization

global GV TIMERPROCESS TIMERPROCESS_RESTART

try

	if GV.timer_activated
		TIMERPROCESS_RESTART				= 0;
		out		= timerfind('Name','timer_errorhandling_maplab3d');
		if ~isempty(out)
			stop(out);
			delete(out);
		end
		TIMERPROCESS_RESTART				= 1;
		TIMERPROCESS						= timer;
		TIMERPROCESS.Name					= 'timer_errorhandling_maplab3d';
		TIMERPROCESS.TimerFcn			= 'timer_timerfcn';
		TIMERPROCESS.ErrorFcn			= 'timer_errorfcn';
		TIMERPROCESS.StopFcn				= 'timer_stopfcn';
		TIMERPROCESS.ExecutionMode		= 'fixedSpacing';
		TIMERPROCESS.BusyMode			= 'drop';
		TIMERPROCESS.Period				= 1.5;
		TIMERPROCESS.TasksToExecute	= Inf;
		TIMERPROCESS.StartDelay			= TIMERPROCESS.Period+0.5;
		start(TIMERPROCESS);		
	end
	
catch ME
	errormessage('',ME);
end

