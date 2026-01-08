function get_building_topside_display_warning(warntext,type,inwr)
% Display of a warning in the Command Window

global OSMDATA

fprintf(1,'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
fprintf(1,'%s\n',warntext);
if ~isempty(type)&&~isempty(inwr)
	fprintf(1,'ID:   OSMDATA.id.%s(1,%g)=%1.0f\n',type,inwr,OSMDATA.id.(type)(1,inwr));
	for it=1:size(OSMDATA.(type)(1,inwr).tag,2)
		if it == 1
			fprintf(1,'Tags: ');
		else
			fprintf(1,'      ');
		end
		fprintf(1,'%s = %s\n',OSMDATA.(type)(1,inwr).tag(1,it).k,OSMDATA.(type)(1,inwr).tag(1,it).v);
	end
end
fprintf(1,'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');

