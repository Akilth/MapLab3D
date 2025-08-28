function copy2clipboard_table(uitableobject)
% Copy the data of an uitable object to the clipboard.

global GV_H GV

try

	% Display state:
	stateisbusy	= display_on_gui('state','','isbusy');
	if ~stateisbusy
		display_on_gui('state','Copy table to clipboard ...','busy','add');
		waitbar_t1		= clock;
	end

	% Initializations:
	data		= '';
	rmax		= size(uitableobject.Data,1);
	cmax		= size(uitableobject.Data,2);
	for c=1:cmax
		if c<=size(uitableobject.ColumnName,1)
			data		= sprintf('%s%s',data,uitableobject.ColumnName{c,1});
		end
		if c<cmax
			data		= sprintf('%s\t',data);
		else
			data		= sprintf('%s\n',data);
		end
	end
	for r=1:rmax

		% Waitbar:
		if ~stateisbusy
			if etime(clock,waitbar_t1)>=GV.waitbar_dtupdate
				waitbar_t1	= clock;
				progress		= min((imapobj-1)/size(map_obj_table,1),1);
				set(GV_H.patch_waitbar,'XData',[0 progress progress 0]);
				drawnow;
			end
		end

		for c=1:cmax
			if isnumeric(uitableobject.Data{r,c})
				data		= sprintf('%s%s',data,number2str(uitableobject.Data{r,c},'%g'));
			else
				data		= sprintf('%s%s',data,uitableobject.Data{r,c});
			end
			if c<cmax
				data		= sprintf('%s\t',data);
			else
				data		= sprintf('%s\n',data);
			end
		end

	end

	% Copy data to clipboard:
	clipboard('copy',data);

	% Display state:
	if ~stateisbusy
		display_on_gui('state','Copy table to clipboard ... done','notbusy','replace');
		set(GV_H.patch_waitbar,'XData',[0 0 0 0]);
		set(GV_H.text_waitbar,'String','');
	end

catch ME
	errormessage('',ME);
end

