function overlap_is_possible=...			% scalar or vector
	overlaps_boundingbox(tol,...
	x1min,x1max,y1min,y1max,...			% scalar
	x2min,x2max,y2min,y2max)				% scalar or vector
% Given are the bounding box limits of for example two polygons.
% This function returns true, if the bounding boxes overlap.

try
	
	% Testing:
	if nargin==0
		tol				= 0.1999;
		poly1				= polyshape([-1 1 1 -1]*0.9,[-1 -1 1 1]*0.9);
		hf					= figure(4328347);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha					= gca;
		hold(ha,'on');
		plot(ha,poly1)
		plot(ha,polybuffer(poly1,tol));
		[xlim1,ylim1]	= boundingbox(poly1);
		x1min				= xlim1(1);
		x1max				= xlim1(2);
		y1min				= ylim1(1);
		y1max				= ylim1(2);
		testno			= 1;
		switch testno
			case 1
				poly2				= poly1;
				K					= 1;
				poly2				= scale(poly2,K);
				x					= 0.42;
				y					= 0.1;
				x2min				= [];
				x2max				= [];
				y2min				= [];
				y2max				= [];
				for i=1:6
					poly2				= translate(poly2,x,y);
					plot(ha,poly2)
					[xlim2,ylim2]	= boundingbox(poly2);
					x2min				= [x2min xlim2(1)];
					x2max				= [x2max xlim2(2)];
					y2min				= [y2min ylim2(1)];
					y2max				= [y2max ylim2(2)];
				end
			case 2
				x2min				= 1;
				x2max				= 2;
				y2min				= 0;
				y2max				= 1;
				plot(ha,...
					[x2min x2max x2max x2min],...
					[y2min y2min y2max y2max],'.r','MarkerSize',15);
			case 3
				[xlim2,ylim2]	= boundingbox(poly2);
				x2min				= xlim2(1);
				x2max				= xlim2(2);
				y2min				= ylim2(1);
				y2max				= ylim2(2);
		end
		axis(ha,'equal');
	end
	
	if isscalar(x2min)
		overlap_is_possible	= true;
		if x2min>(x1max+tol)
			overlap_is_possible	= false;
		else
			if x2max<(x1min-tol)
				overlap_is_possible	= false;
			else
				if y2min>(y1max+tol)
					overlap_is_possible	= false;
				else
					if y2max<(y1min-tol)
						overlap_is_possible	= false;
					end
				end
			end
		end
	else
		overlap_is_possible	= ~(...
			(x2min>(x1max+tol))|...
			(x2max<(x1min-tol))|...
			(y2min>(y1max+tol))|...
			(y2max<(y1min-tol))    );
	end
	
	% Old methods:
	
	% if ~( (x2min>(x1max+tol))||...
	% 		(x2max<(x1min-tol))||...
	% 		(y2min>(y1max+tol))||...
	% 		(y2max<(y1min-tol))     )
	% 	overlap_is_possible	= true;
	% else
	% 	overlap_is_possible	= false;
	% end
	
	% x1minmt			= x1min-tol;
	% x1maxpt			= x1max+tol;
	% y1minmt			= y1min-tol;
	% y1maxpt			= y1max+tol;
	% x2minmt			= x2min-tol;
	% x2maxpt			= x2max+tol;
	% y2minmt			= y2min-tol;
	% y2maxpt			= y2max+tol;
	% if (    (x2min>=(x1minmt))&&(x2min<=(x1maxpt))&&(y2min>=(y1minmt))&&(y2min<=(y1maxpt)) ) || ...	% Bottom left  corner of 2 is within 1
	% 		( (x2max>=(x1minmt))&&(x2max<=(x1maxpt))&&(y2min>=(y1minmt))&&(y2min<=(y1maxpt)) ) || ...	% Bottom right corner of 2 is within 1
	% 		( (x2max>=(x1minmt))&&(x2max<=(x1maxpt))&&(y2max>=(y1minmt))&&(y2max<=(y1maxpt)) ) || ...	% top    right corner of 2 is within 1
	% 		( (x2min>=(x1minmt))&&(x2min<=(x1maxpt))&&(y2max>=(y1minmt))&&(y2max<=(y1maxpt)) ) || ...	% Upper  left  corner of 2 is within 1
	% 		( (x1min>=(x2minmt))&&(x1min<=(x2maxpt))&&(y1min>=(y2minmt))&&(y1min<=(y2maxpt)) ) || ...	% bottom left  corner of 1 is within 2
	% 		( (x1max>=(x2minmt))&&(x1max<=(x2maxpt))&&(y1min>=(y2minmt))&&(y1min<=(y2maxpt)) ) || ...	% bottom right corner of 1 is within 2
	% 		( (x1max>=(x2minmt))&&(x1max<=(x2maxpt))&&(y1max>=(y2minmt))&&(y1max<=(y2maxpt)) ) || ...	% top    right corner of 1 is within 2
	% 		( (x1min>=(x2minmt))&&(x1min<=(x2maxpt))&&(y1max>=(y2minmt))&&(y1max<=(y2maxpt)) ) || ...	% top    left  corner of 1 is within 2
	% 		( (x2min>=(x1minmt))&&(x2max<=(x1maxpt))&&(y1min>=(y2minmt))&&(y1max<=(y2maxpt)) ) || ...	% All x-values of 2 are within of the x-values of 1 and all y-values of 1 are within the y-values of 2
	% 		( (x1min>=(x2minmt))&&(x1max<=(x2maxpt))&&(y2min>=(y1minmt))&&(y2max<=(y1maxpt)) )			% All x-values of 1 are within of the x-values of 2 and all y-values of 2 are within the y values of 1
	% 	overlap_is_possible	= true;
	% end
	
catch ME
	errormessage('',ME);
end

