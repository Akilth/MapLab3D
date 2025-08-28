function [poly_area,poly_arsy,ud_area,ud_arsy]=...
	area2poly(polyin,par,style,iobj,obj_purpose)
% Returns a formatted polygon with userdata:
% poly_area			1*1 polyshape object: area outline (background)
% poly_arsy			1*1 polyshape object: area symbol (foreground)
% ud_area,ud_arsy	corresponding Userdata:
%						ud.color_no			color number
%						ud.color_no_pp		color number project parameters
%						ud.dz					change in altitude compared to the elevation (>0 higher, <0 lower)
%						ud.prio				object priority
%						ud.iobj				index in PP.obj
%						ud.level				0: background, 1: foreground
%						ud.surftype			surface type
%						ud.rotation			rotation angle
%						ud.obj_purpose		cell array: information about the usage of the object
%												(see get_pp_mapobjsettings.m)
%						If there are no symbols, ud_arsy is empty.
% polyin				input polygon
%						xy vertices are not used here, because the information of inner and outer outlines would be lost.
% par					cell array of parameters
% style				Area style, see below
% iobj				index in PP.obj
% obj_purpose		cell array: information about the usage of the object
%						(see get_pp_mapobjsettings.m)
%
% Syntax for assignment of the userdata without calculating the polygon:
% (Please note that ud_arsy may be empty!)
% [~,~,ud_area,ud_arsy]=area2poly(polyshape(),par,style,iobj,obj_purpose)
%{
--------------------------------------------------------------------------------|
style=1:
Simple area:
par{1} = lifting dz (background) / mm
par{2} = area surface type  0: The area height follows the terrain raised by dz.
                            1: Flat surface: The height is equal to the maximum 
                               value of the terrain height at the edge of every
                               individual area raised by dz. This applies to all
                               individual regions of the surface area.
                            2: Flat surface: The height is equal to the maximum 
                               value of the terrain height at the edge of all
                               areas raised by dz. All individual regions of the
                               surface have the same height.
   +-------------------+  ---
   |                   |   ^
   |                   |   |par{1}
   |                   |   v
---+  elevation level  +------------------------------------------------------------------------------------------|
%}

global PP

try

	% Initializations:
	poly_area	= polyshape();
	poly_arsy	= polyshape();
	ud_area		= [];
	ud_arsy		= [];

	% Assign project parameters:
	color_no_fgd	= 1;
	color_no_bgd	= 1;
	prio				= 1;
	if ~isempty(iobj)
		iobj		= max(0,round(iobj));
		if iobj>=1
			if ~isempty(PP)
				if isfield(PP,'obj')
					if size(PP.obj,1)>=iobj
						color_no_fgd	= PP.obj(iobj).color_no_fgd;
						color_no_bgd	= PP.obj(iobj).color_no_bgd;
						prio				= PP.obj(iobj).prio;
					end
				end
			end
		end
	end


	switch style

		case 1
			%------------------------------------------------------------------------------------------------------------
			% style=1: simple area:

			% Initializations:
			dz_bgd			= par{1};							% dz of the background
			surftype_area	= par{2};

			% Userdata:
			% Foreground:
			% ---
			% Background:
			% The object priority of the background MUST:
			% 1) be smaller the the object priority of the foreground AND
			% 2) be non integer: In this way the object is recognized as background in map2stl.
			% 3) differ from the foreground object priority by LESS than 0.5.
			ud_area.color_no		= color_no_bgd;
			ud_area.color_no_pp	= color_no_bgd;
			ud_area.dz				= dz_bgd;
			ud_area.prio			= prio-0.25;
			ud_area.iobj			= iobj;
			ud_area.level			= 0;				% 0: background
			ud_area.surftype		= 200+surftype_area;
			ud_area.rotation		= 0;
			ud_area.obj_purpose	= obj_purpose;

			% Assignment of the userdata without calculating the polygon:
			if numboundaries(polyin)==0
				return
			end

			% Assign polygon:
			poly_area		= polyin;

			% Assign output arguments:

		otherwise
			errortext	= sprintf([...
				'The area style number %g is not defined\n',...
				'(object number %g).'],style,iobj);
			errormessage(errortext);
	end

catch ME
	errormessage('',ME);
end
