function calculate_symbols
% not used any more

try

	key	= 'generator:method';
	value	= 'wind_turbine';

	switch key

		%---------------------------------------------------------------------------------------------------------------
		case 'generator:method'

			switch value

				%---------------------------------------------------------------------------------------------------------
				case 'wind_turbine'

					rbl				= 1.7;			% rotor blade length
					rbwo				= 0.7;			% rotor blade width outer
					rbwi				= 1;				% rotor blade width inside
					sampling			= 6;
					rb1_c	= [...
						+rbwi/2;...
						+rbwo/2+1i*rbl];
					k		= (1:(sampling-1))';
					rb1_c	= [rb1_c;1i*rbl+rbwo/2*exp(1i*k/sampling*pi)];
					rb1_c	= [rb1_c;
						-rbwo/2+1i*rbl;...
						-rbwi/2];
					rb2_c	= rb1_c*exp( 1i*2*pi/3);
					rb3_c	= rb1_c*exp(-1i*2*pi/3);
					poly0(1,1)	= polyshape(real(rb1_c),imag(rb1_c));
					poly0(1,1)	= union(poly0,polyshape(real(rb2_c),imag(rb2_c)));
					poly0(1,1)	= union(poly0,polyshape(real(rb3_c),imag(rb3_c)));
					% Circle:
					poly_circle = nsidedpoly(12,'Radius',0.35);
					poly_circle = addboundary(nsidedpoly(12,'Radius',0.8),poly_circle.Vertices);
					% Rotor blades, front:
					poly0(2,1)	= poly0(1,1);
					poly0(1,1)	= subtract(poly0(1,1),poly_circle);

					figure
					set(hf,'Tag','maplab3d_figure');
					ha=axes;
					hold(ha,'on');
					plot(ha,poly0)
					plot(ha,poly0(1,1).Vertices(:,1),poly0(1,1).Vertices(:,2),'.r')
					axis(ha,'equal');


			end
	end

	poly0(1,1).Vertices

	poly0(2,1).Vertices

catch ME
	errormessage('',ME);
end



