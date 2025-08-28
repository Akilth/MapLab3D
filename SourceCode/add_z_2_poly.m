function vertices_xyz	= add_z_2_poly(colprio_base,vertices_xy,zmin,dz,zbotmax,colno,PP_local,ELE_local,poly_legbgd)
% Depending on the project parameters, the z-value is calculated for a point with xy coordinates and added to
% the matrix vertices_xy as the 3rd column.

global GV

try
	
	colprio		= PP_local.color(colno).prio;
	icolspec		= PP_local.color(colno).spec;
	if colprio==colprio_base
		% colprio=colprio_base: base color
		%                       dz indicates the elevation relative to the terrain (original value dz)
		vertices_xyz	= [...
			vertices_xy(:,1) ...
			vertices_xy(:,2) ...
			dz+interp_ele(...
			vertices_xy(:,1),...				% query points x
			vertices_xy(:,2),...				% query points y
			ELE_local,...						% elevation structure
			colno,...							% color numbers
			GV.legend_z_topside_bgd,...	% legend background z-value
			poly_legbgd,...					% legend background polygon
			'interp2')];						% interpolation method
	else
		% colprio~=colprio_base: no base color: there are further colors above this point.
		%                        dz=z_bot: absolute z-value of the bottom side
		if PP_local.colorspec(icolspec).bottom_version==1
			% bottom_version=1 (flat/horizontal: printing without support)
			% The underside of the color above this point is flat:
			vertices_xyz	= [...
				vertices_xy(:,1) ...
				vertices_xy(:,2) ...
				dz*ones(size(vertices_xy,1),1)];
		elseif PP_local.colorspec(icolspec).bottom_version==2
			% bottom_version=2 (follows the terrain at a constant distance from the surface):
			% The underside of the color above follows the terrain: at the lowest point the z-value must be equal to
			% dz=z_bot, otherwise follow the terrain at the same distance from the terrain.
			vertices_z				= interp_ele(...
				vertices_xy(:,1),...				% query points x
				vertices_xy(:,2),...				% query points y
				ELE_local,...						% elevation structure
				colno,...							% color numbers
				GV.legend_z_topside_bgd,...	% legend background z-value
				poly_legbgd,...					% legend background polygon
				'interp2');							% interpolation method
			vertices_z			= dz-zmin+vertices_z;
			% vertices_z nach oben begrenzen auf z_bottom_max
			vertices_zmax		= zbotmax*ones(size(vertices_xy,1),1);
			iT						= vertices_z>vertices_zmax;
			vertices_z(iT,1)	= vertices_zmax(iT,1);
			vertices_xyz	= [...
				vertices_xy(:,1) ...
				vertices_xy(:,2) ...
				vertices_z];
		else
			errormessage(sprintf([...
				'Error: The project parameter\n',...
				'colorspec(icolspec).bottom_version=%g\n',...
				'is not defined.'],...
				PP_local.colorspec(icolspec).bottom_version));
		end
	end
	
catch ME
	errormessage('',ME);
end

