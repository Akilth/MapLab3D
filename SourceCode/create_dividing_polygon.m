function poly=create_dividing_polygon(x_v,y_v,colorspec)
% Dividing polygon
% x_v,y_v:		Vertices
% colorspec:	PP.colorspec(icolspec)

try

	testplot	= false;
	if nargin==0
		testplot	= true;
		x_v	= [-3 -2 -1 1 -1 -1 -2 -3]*10;
		y_v	= [0  -1 -1 0  1  2  2  0]*0.5;
		x_v	= [1 3 3 1 1]*10;
		y_v	= [1 1 2 2 1]*10;
		colorspec.cut_into_pieces.gap_style						= 2;			% 2
		colorspec.cut_into_pieces.gap_width						= 0.25;		%
		% interp1 function: 'linear', 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic', 'makima', 'spline'
		% interp1 function: 'linear', 'nearest', 'pchip', 'cubic', 'v5cubic', 'makima', 'spline'
		colorspec.cut_into_pieces.gap_pattern_style			= 'linear';	% 'linear'
		colorspec.cut_into_pieces.gap_pattern_pulsespacing	= 2;			%
		colorspec.cut_into_pieces.gap_pattern_width			= 3;			% 3
		colorspec.cut_into_pieces.gap_pattern_dmin			= 0.25;		%
		colorspec.cut_into_pieces.gap_pattern_regularity	= 0.5;		%
	end

	tol_1								= 1e-6;
	gap_style						= colorspec.cut_into_pieces.gap_style;
	gap_width						= max(colorspec.cut_into_pieces.gap_width,tol_1);
	% interp1 function: 'linear', 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic', 'makima', 'spline'
	% interp1 function: 'linear', 'nearest', 'pchip', 'cubic', 'v5cubic', 'makima', 'spline'
	gap_pattern_style				= colorspec.cut_into_pieces.gap_pattern_style;
	gap_pattern_pulsespacing	= max(colorspec.cut_into_pieces.gap_pattern_pulsespacing,tol_1);
	gap_pattern_width				= abs(colorspec.cut_into_pieces.gap_pattern_width);
	gap_pattern_dmin				= max(colorspec.cut_into_pieces.gap_pattern_dmin,tol_1);
	gap_pattern_regularity		= colorspec.cut_into_pieces.gap_pattern_regularity;

	switch gap_style
		case 1
			% Cut at the tile boundaries: realized elsewhere
			errormessage;
		case 2
			% Automatic linear division lines:
			if gap_pattern_width==0
				poly	= line2poly(x_v,y_v,{gap_width;6});
			else
				x_v			= x_v(:);
				y_v			= y_v(:);
				poly			= polyshape();
				for k=1:(size(x_v,1)-1)
					cstart		= x_v(1  ,1)+1i*y_v(1  ,1);	% first point of the whole line
					c1				= x_v(k  ,1)+1i*y_v(k  ,1);	% first point of the current segment
					c2				= x_v(k+1,1)+1i*y_v(k+1,1);	% last  point of the current segment
					cend			= x_v(end,1)+1i*y_v(end,1);	% last point of the whole line
					d12			= c2-c1;
					c1c2_mean	= (c1+c2)/2;
					phi12			= angle(d12);
					% a1: angle between the current and the previous segment / 2
					% a2: angle between the current and the next     segment / 2
					if k==1
						if abs(cend-c1)<tol_1
							c1_km1			= x_v(end-1,1)+1i*y_v(end-1,1);
							c2_km1			= x_v(end  ,1)+1i*y_v(end  ,1);
							d12_km1			= c2_km1-c1_km1;
							phi12_km1		= angle(d12_km1);
							a1					= (pi-abs(phi12-phi12_km1))/2;
							a1					= mod(a1+pi,2*pi)-pi;
						else
							a1					= pi/4;
						end
					else
						c1_km1			= x_v(k-1,1)+1i*y_v(k-1,1);
						c2_km1			= x_v(k  ,1)+1i*y_v(k  ,1);
						d12_km1			= c2_km1-c1_km1;
						phi12_km1		= angle(d12_km1);
						a1					= (pi-abs(phi12-phi12_km1))/2;
						a1					= mod(a1+pi,2*pi)-pi;
					end
					if k==size(x_v,1)-1
						if abs(cstart-c2)<tol_1
							c1_kp1			= x_v(1,1)+1i*y_v(1,1);
							c2_kp1			= x_v(2,1)+1i*y_v(2,1);
							d12_kp1			= c2_kp1-c1_kp1;
							phi12_kp1		= angle(d12_kp1);
							a2					= (pi-abs(phi12_kp1-phi12))/2;
							a2					= mod(a2+pi,2*pi)-pi;
						else
							a2					= pi/4;
						end
					else
						c1_kp1			= x_v(k+1,1)+1i*y_v(k+1,1);
						c2_kp1			= x_v(k+2,1)+1i*y_v(k+2,1);
						d12_kp1			= c2_kp1-c1_kp1;
						phi12_kp1		= angle(d12_kp1);
						a2					= (pi-abs(phi12_kp1-phi12))/2;
						a2					= mod(a2+pi,2*pi)-pi;
					end
					% Vertices shifted and rotated:
					c1_sr			= (c1-c1c2_mean)*exp(-1i*phi12);
					c2_sr			= (c2-c1c2_mean)*exp(-1i*phi12);
					x1_sr			= real(c1_sr);
					x2_sr			= real(c2_sr);
					% Create the line:
					n_pulses		= max(1,round((x2_sr-x1_sr)/gap_pattern_pulsespacing));
					line_x		= x1_sr+(0:n_pulses)'/n_pulses*(x2_sr-x1_sr);
					imax			= size(line_x,1);
					i_v			= (1:imax)';
					line_x		= line_x + (2*rand(imax,1)-1)*0.25*gap_pattern_pulsespacing*(1-gap_pattern_regularity);
					line_x(1)	= x1_sr;
					line_x(end)	= x2_sr;
					line_y		= (...
						(gap_pattern_regularity*(-1).^i_v)+...
						((1-gap_pattern_regularity)*(rand(imax,1)*2-1)) )*gap_pattern_width*0.5;
					switch gap_pattern_style
						case 'linear'
							line_int_x	= line_x;
							line_int_y	= line_y;
						otherwise
							line_int_x	= (line_x(1):gap_pattern_dmin:line_x(end))';
							line_int_y	= interp1(line_x,line_y,line_int_x,gap_pattern_style);
					end
					% Limit the y-values of the line to a1 and a2 at the first and last  point of the current segment:
					a1					= 0.25*a1;				% not necessary, but seems to look better at the edges of the line
					a2					= 0.25*a2;
					ma1				=  abs(tan(a1));		% slope
					ma2				= -abs(tan(a2));
					line_ymax_a1	= ma1*(line_x-x1_sr);
					line_ymax_a2	= ma2*(line_x-x2_sr);
					i	= (line_int_y> line_ymax_a1);	line_int_y(i)	=  line_ymax_a1(i);
					i	= (line_int_y<-line_ymax_a1);	line_int_y(i)	= -line_ymax_a1(i);
					i	= (line_int_y> line_ymax_a2);	line_int_y(i)	=  line_ymax_a2(i);
					i	= (line_int_y<-line_ymax_a2);	line_int_y(i)	= -line_ymax_a2(i);
					% Create the polygon:
					poly_tol		= polyshape(...
						[line_int_x;flip(line_int_x)],...
						[line_int_y+tol_1;flip(line_int_y)-tol_1],'Simplify',false);
					poly1			= polybuffer(poly_tol,gap_width/2,'JointType','miter','MiterLimit',2);
					poly1			= simplify(poly1,'KeepCollinearPoints',false);
					poly1			= rotate(poly1,phi12*180/pi,[0 0]);
					poly1			= translate(poly1,real(c1c2_mean),imag(c1c2_mean));
					poly			= union(poly,poly1,'KeepCollinearPoints',false);
				end
			end
		otherwise
			errormessage;
	end

	if testplot
		hf	= figure(85202394);
		figure(hf);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha=axes(hf);
		hold(ha,'on');
		plot(ha,x_v,y_v,'.-r');
		plot(ha,poly);
		title(sprintf('gap_pattern_regularity=%g',gap_pattern_regularity),'Interpreter','none');
		axis equal;
		setbreakpoint	= 1;
	end

catch ME
	errormessage('',ME);
end

