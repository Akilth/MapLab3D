function filter_osmdata_filterstring(obj_tag,description)
% Sets the value of APP.PreviewdescriptionEditField.
% Syntax:
% filter_osmdata_filterstring(obj_tag,[]);
% filter_osmdata_filterstring([],description);

global APP

try

	if ~isempty(obj_tag)

		filterstring	= '';

		for r=1:size(obj_tag,1)
			col_max(r,1)	= 0;
			for c=1:size(obj_tag,2)
				if ~isempty(obj_tag(r,c).k)||~isempty(obj_tag(r,c).v)
					col_max(r,1)	= c;
				end
			end
		end
		row_max	= 0;
		for c=1:size(obj_tag,2)
			for r=1:size(obj_tag,1)
				if ~isempty(obj_tag(r,c).k)||~isempty(obj_tag(r,c).v)
					row_max	= r;
				end
			end
		end

		for r=1:row_max
			for c=1:col_max(r,1)
				cond	= '';
				if ~isempty(obj_tag(r,c).k)||~isempty(obj_tag(r,c).v)
					cond	= sprintf('%s%s%s',...
						obj_tag(r,c).k,...
						obj_tag(r,c).op,...
						obj_tag(r,c).v);
				elseif ~isempty(obj_tag(r,c).k)
					cond	= sprintf('key==%s',...
						obj_tag(r,c).k);
				elseif ~isempty(obj_tag(r,c).v)
					cond	= sprintf('val==%s',...
						obj_tag(r,c).v);
				end
				if col_max(r,1)==1
					cond_or	= cond;
				else
					if c==1
						cond_or	= sprintf('(%s)',cond);
					else
						cond_or	= sprintf('%sor(%s)',cond_or,cond);
					end
				end
			end
			if row_max==1
				filterstring	= cond_or;
			else
				if r==1
					filterstring	= sprintf('(%s)',cond_or);
				else
					filterstring	= sprintf('%sand(%s)',filterstring,cond_or);
				end
			end
		end

	else
		filterstring		= description;
	end

	APP.PreviewdescriptionEditField.Value	= filterstring;
	drawnow;

catch ME
	errormessage('',ME);
end

