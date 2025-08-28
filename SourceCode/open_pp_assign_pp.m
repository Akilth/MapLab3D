function PP_temp=open_pp_assign_pp(PP_temp,T,dataset_no,assign_projectpar)

global GV GV_H

try

	% Assign the structure PP_temp:
	imax						= length(T.FIELD1);
	dt_update				= 0.5;						% Time between two updates of the waitbar
	t_update					= clock;
	testout					= false;						% false
	for i=1:imax
		if ~isempty(T.FIELD1{i})
			field1_is_project	= strcmp(T.FIELD1{i},'project');
			if ~field1_is_project||(assign_projectpar==1)
				level	= 1;

				% Assign the values:
				command	= 'PP_temp';
				if ~field1_is_project
					% assign_projectpar=0:
					% When loading the project parameters, the field PP.project is assigned before.
					[command]=extent_pp(T,i,level,command,GV.pp_pathfilename,dataset_no);
				else
					% assign_projectpar=1: loading the reference project parameters
					% dataset_no=0:
					[command]=extent_pp(T,i,level,command,GV.pp_pathfilename,0);
				end
				if testout
					fprintf(1,'1)             %s\n',command);
				end
				if contains(command,newline)
					errormessage(sprintf([...
						'Error when loading the project file:\n',...
						'%s\n\n',...
						'Line number %g:\n',...
						'Error when evaluation the command:\n',...
						'"%s"\n\n',...
						'The values of the project parameters must not contain line breaks.'],...
						GV.pp_pathfilename,i+1,command));
				end
				try
					eval(command);
				catch ME
					errormessage(sprintf([...
						'Error when loading the project file:\n',...
						'%s\n\n',...
						'Line number %g:\n',...
						'Error when evaluation the command:\n',...
						'"%s"'],GV.pp_pathfilename,i+1,command),ME);
				end

				% Assign the description:
				k								= strfind(command,'=');
				command2						= [command(1:7) '.DESCRIPTION.' command(9:(k(1)-2))];
				command2(command2=='(')	= '{';
				command2(command2==')')	= '}';
				if ~strcmp(command2(end),'}')
					command2					= [command2 '{1,1}'];
				end
				command2						= [command2 ' = ''' double_apostrophe(T.DESCRIPTION{i}) ''';'];
				if testout
					fprintf(1,'2) %s\n',command2);
				end
				try
					eval(command2);
				catch ME
					errormessage(sprintf([...
						'Error when loading the project file:\n',...
						'%s\n\n',...
						'Line number %g:\n',...
						'Error when evaluation the command:\n',...
						'"%s"'],GV.pp_pathfilename,i+1,command2),ME);
				end

				% Assign the row number:
				k								= strfind(command,'=');
				command3						= [command(1:7) '.TABLE_ROWNO.' command(9:(k(1)-2))];
				command3(command3=='{')	= '(';
				command3(command3=='}')	= ')';
				if ~strcmp(command3(end),')')
					command3					= [command3 '(1,1)'];
				end
				command3						= [command3 ' = ' sprintf('%1.0f',i+1) ';'];
				if testout
					fprintf(1,'2) %s\n',command3);
				end
				try
					eval(command3);
				catch ME
					errormessage(sprintf([...
						'Error when loading the project file:\n',...
						'%s\n\n',...
						'Line number %g:\n',...
						'Error when evaluation the command:\n',...
						'"%s"'],GV.pp_pathfilename,i+1,command3),ME);
				end

			end
		end
		% Waitbar:
		if etime(clock,t_update)>=dt_update
			% fprintf(1,'Test open_pp: i=%g, imax=%g\n',i,imax);
			t_update		= clock;
			progress		= min(i/imax,1);
			set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
			drawnow;
		end
	end

	% Reset waitbar:
	set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
	set(GV_H.text_waitbar,'String','');
	drawnow;

catch ME
	errormessage('',ME);
end

