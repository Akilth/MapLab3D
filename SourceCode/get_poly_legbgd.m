function [poly_legbgd,prio_legbgd,warntext]=get_poly_legbgd
% Gets the legend background as polygon object.
% Needed when cutting objects or calculation the height.
% prio_legbgd=-1 if no legend background exists or the legend background is not visible!

global MAP_OBJECTS GV

try
	
	poly_legbgd		= polyshape();
	prio_legbgd		= -1;
	k					= 0;
	for imapobj=1:size(MAP_OBJECTS,1)
		if strcmp(MAP_OBJECTS(imapobj,1).disp,'area')&&(MAP_OBJECTS(imapobj,1).iobj==0)
			for rpoly=1:size(MAP_OBJECTS(imapobj,1).h,1)
				ud	= MAP_OBJECTS(imapobj,1).h(rpoly,1).UserData;
				if length(ud)~=1
					errormessage;
				end
				if isfield(ud,'islegbgd')
					if ud.islegbgd
						if   (MAP_OBJECTS(imapobj,1).vis0~=0)                                                  &&...
								isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
								isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).FaceAlpha,GV.visibility.show.facealpha)
							% The legend background is not grayed out and visible or temporarily hidden:
							% This displays the z-values (elevation) correctly even if united equal colors are displayed.
							k	= k+1;
							poly_legbgd(k,1)	= MAP_OBJECTS(imapobj,1).h(rpoly,1).Shape;
							prio_legbgd			= ud.prio;
						end
					end
				end
			end
		end
	end
	
	% Warntext:
	warntext		= '';
	if numboundaries(poly_legbgd)==0
		
		% There is no visible legend background. Check if there are other visible legend objects:
		imapobj_vis_legend_objects_v	= [];
		for imapobj=1:size(MAP_OBJECTS,1)
			if MAP_OBJECTS(imapobj,1).iobj==0
				% Legend object:
				for rpoly=1:size(MAP_OBJECTS(imapobj,1).h,1)
					ud	= MAP_OBJECTS(imapobj,1).h(rpoly,1).UserData;
					if length(ud)~=1
						errormessage;
					end
					if    MAP_OBJECTS(imapobj,1).h(rpoly,1).Visible                                        &&...
							isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).EdgeAlpha,GV.visibility.show.edgealpha)&&...
							isequal(MAP_OBJECTS(imapobj,1).h(rpoly,1).FaceAlpha,GV.visibility.show.facealpha)
						% The legend object is visible and not grayed out:
						imapobj_vis_legend_objects_v	= [imapobj_vis_legend_objects_v;imapobj];
					end
				end
			end
		end
		imapobj_vis_legend_objects_v	= unique(imapobj_vis_legend_objects_v);
		if ~isempty(imapobj_vis_legend_objects_v)
			if ~isempty(warntext)
				warntext		= sprintf('%s\n\n',warntext);
			else
				% warntext		= sprintf('Warning:\n\n');
			end
			warntext		= sprintf(['%s'...
				'There is no visible legend background but\n',...
				'there are other visible legend objects:\n',...
				'PlotNo = %g'],warntext,imapobj_vis_legend_objects_v(1,1));
			kmax		= 5;
			for k=2:min(kmax,size(imapobj_vis_legend_objects_v,1))
				warntext		= sprintf('%s, %g',warntext,imapobj_vis_legend_objects_v(k,1));
			end
			if size(imapobj_vis_legend_objects_v,1)>kmax
				warntext		= sprintf('%s, ...',warntext);
			end
			warntext		= sprintf(['%s\n',...
				'This can lead to undesirable results.\n',...
				'Either activate the legend background (Show) or\n',...
				'deactivate all legend objects (Gray out or Hide).'],warntext);
		end
		
	end
	
catch ME
	errormessage('',ME);
end

