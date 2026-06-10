function	checked=plot_poly_contour
% Create contour lines on the 2D map.

global GV_H GV ELE APP

if isempty(ELE)||isempty(GV)
	errormessage(sprintf(['Error:\n',...
		'Before creating contour lines,\n',...
		'you have to load the OSM and elevation data.']));
end

% Delete an existing contour plot and ask for the Contour lines distance:
checked				= 'off';
definput{1,1}		= num2str(GV.contour_stepsize(1,1));
if APP.View_ShowContourLines_Minor_Menu.Checked
	definput{2,1}	= num2str(GV.contour_stepsize(2,1));
end
prompt{1,1}	= 'Contour lines level step / mm:';
if APP.View_ShowContourLines_Minor_Menu.Checked
	prompt{1,1}	= 'Major contour lines level step / mm:';
	prompt{2,1}	= 'Minor contour lines level step / mm:';
end
dlgtitle		= 'Enter coutour lines parameters';
dims			= 1;
answer		= inputdlg_local(prompt,dlgtitle,dims,definput);
if ~isempty(answer)
	dz_major	= str2double(answer{1});
	if isnan(dz_major)||isempty(dz_major)||(length(dz_major)>1)
		return
	end
	if APP.View_ShowContourLines_Minor_Menu.Checked
		dz_minor	= str2double(answer{2});
		if isnan(dz_minor)||isempty(dz_minor)||(length(dz_minor)>1)
			return
		end
	end
else
	return
end
if isfield(GV_H,'poly_contour')
	for i=1:size(GV_H.poly_contour,1)
		if ishandle(GV_H.poly_contour{i,1})
			delete(GV_H.poly_contour{i,1});
		end
	end
end

% Major contour lines:
ifs		= 1;												% Use the tile base elevation data.
zmin		= floor(min(ELE.elefiltset(ifs,1).zm_mm,[],'all')/dz_major)*dz_major;
zmax		= ceil(max(ELE.elefiltset(ifs,1).zm_mm,[],'all')/dz_major)*dz_major;
zmajor_v	= zmin:dz_major:zmax;
GV_H.poly_contour		= [];
ud							= [];
ud.contour			= 1;
if ~ishandle(GV_H.ax_2dmap)
	errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
end
if APP.View_ShowContourLines_MajorLabels_Menu.Checked
	[~,GV_H.poly_contour{1,1}]		= contour(...
		GV_H.ax_2dmap,...
		ELE.elefiltset(ifs,1).xm_mm,...
		ELE.elefiltset(ifs,1).ym_mm,...
		ELE.elefiltset(ifs,1).zm_mm,...
		'LevelList',zmajor_v,'ShowText','on','PickableParts','none','HitTest','off','UserData',ud);
else
	[~,GV_H.poly_contour{1,1}]		= contour(...
		GV_H.ax_2dmap,...
		ELE.elefiltset(ifs,1).xm_mm,...
		ELE.elefiltset(ifs,1).ym_mm,...
		ELE.elefiltset(ifs,1).zm_mm,...
		'LevelList',zmajor_v,'PickableParts','none','HitTest','off','UserData',ud);
end
% GV_H.poly_contour{1,1}.LineColor			= 'c';
GV_H.poly_contour{1,1}.ButtonDownFcn	= GV.ax_2dmap_ButtonDownFcd;
GV.contour_stepsize(1,1)					= dz_major;
checked											= 'on';

% Minor contour lines:
ud.contour			= 2;
if APP.View_ShowContourLines_Minor_Menu.Checked
	zminor_v		= zmin:dz_minor:zmax;
	i_delete		= false(size(zminor_v));
	for i=1:length(zminor_v)
		if any(zminor_v(i)==zmajor_v)
			i_delete(i)	= true;
		end
	end
	zminor_v(i_delete)	= [];
	if ~ishandle(GV_H.ax_2dmap)
		errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
	end
	if APP.View_ShowContourLines_MinorLabels_Menu.Checked
		[~,GV_H.poly_contour{2,1}]		= contour(...
		GV_H.ax_2dmap,...
		ELE.elefiltset(ifs,1).xm_mm,...
		ELE.elefiltset(ifs,1).ym_mm,...
		ELE.elefiltset(ifs,1).zm_mm,...
			'LevelList',zminor_v,'ShowText','on','PickableParts','none','HitTest','off','UserData',ud);
	else
		[~,GV_H.poly_contour{2,1}]		= contour(...
		GV_H.ax_2dmap,...
		ELE.elefiltset(ifs,1).xm_mm,...
		ELE.elefiltset(ifs,1).ym_mm,...
		ELE.elefiltset(ifs,1).zm_mm,...
			'LevelList',zminor_v,'PickableParts','none','HitTest','off','UserData',ud);
	end
	GV_H.poly_contour{1,1}.LineWidth			= 2;
	GV_H.poly_contour{2,1}.LineWidth			= 0.5;
	% 	GV_H.poly_contour{2,1}.LineColor			= 'c';
	GV_H.poly_contour{2,1}.ButtonDownFcn	= GV.ax_2dmap_ButtonDownFcd;
	GV.contour_stepsize(2,1)					= dz_minor;
end

% Create/modify legend:
create_legend_mapfigure;

