function dt_str=dt_string(dt)
% dt			number of seconds
% dt_str		number of seconds as string

try

	d			 =floor(dt/86400);	dt	= dt-d*86400;
	h			= floor(dt/3600);		dt	= dt-h*3600;
	m			= floor(dt/60);		dt	= dt-m*60;
	s			= dt;
	if (d==0)&&(h==0)&&(m==0)
		% dt_str	= sprintf('%1.2f s',s);
		dt_str	= sprintf('%s s',number2str(s,'%1.2f'));
	elseif (d==0)&&(h==0)
		dt_str	= sprintf('%1.0f:%02.0f min',m,s);
	elseif d==0
		dt_str	= sprintf('%1.0f:%02.0f:%02.0f h',h,m,s);
	else
		dt_str	= sprintf('%1.0f d, %1.0f:%02.0f:%02.0f h',d,h,m,s);
	end

catch ME
	errormessage('',ME);
end

