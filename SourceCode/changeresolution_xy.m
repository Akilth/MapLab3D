function [x,y]=changeresolution_xy(x0,y0,dmax,dmin,nmin,keep_flp)
% 1)	If dmax is not empty:
%		Inserts vertices to polyin, so that the distance between two vertices is less than dmax
% 2)	If dmin is not empty:
%		Deletes vertices in polyin, so that the distance between two vertices is at least dmin
%		Possibly there remains no data in polyout!
% 3)	If nmin is not empty:
%		Insert at least nmin vertices between 2 vertices in polyin (AFTER deleting vertices according dmin)
% 4)	keep_flp=1: Keep the first and the last point of the line (default).
%		keep_flp=0: The first and the last point of the line will possibly be deleted.

try

	tol	= 1e-6;
	if nargin<=5
		keep_flp	= 1;
	end

	% There may be nothing to do:
	if isequal(dmin,0)
		dmin	= [];
	end
	if isempty(dmin)&&isempty(dmax)&&isempty(nmin)
		x		= x0;
		y		= y0;
		return
	end

	% The x- and y-vectors can be NaN-delimited: Divide them into parts:
	i_nan_x	= find(isnan(x0));
	i_nan_y	= find(isnan(y0));
	if ~isequal(i_nan_x,i_nan_y)
		errormessage;
	end
	if ~isequal(size(x0),size(y0))
		errormessage;
	end
	if isscalar(x0)
		x		= x0;
		y		= y0;
		return
	end
	[xc,yc]	= polysplit(x0,y0);
	if size(xc,1)==1
		x		= x0;
		y		= y0;
	else
		for i=1:size(xc,1)
			[xp,yp]	= changeresolution_xy(xc{i,1},yc{i,1},dmax,dmin,nmin);
			if i==1
				x		= xp;
				y		= yp;
			else
				if (size(x,1)==1)&&(size(xp,1)==1)
					x		= [x nan xp];
					y		= [y nan yp];
				else
					% i
					% xp
					% yp
					% size_xp=size(xp)
					% size_yp=size(yp)
					% size_x=size(x)
					% size_y=size(y)
					x		= [x(:);nan;xp(:)];
					y		= [y(:);nan;yp(:)];
				end
			end
		end
		return
	end

	if ~isempty(dmin)
		%---------------------------------------------------------------------------------------------------------
		% delete vertices:

		kmax		= length(x0);
		k_v		= (1:kmax)';
		km1_v		= vindexrest(k_v-1,kmax);
		kp1_v		= vindexrest(k_v+1,kmax);
		kp2_v		= vindexrest(k_v+2,kmax);
		% Vertices as complex numbers (vectors):
		vert_km1_c	= x0(km1_v)+1i*y0(km1_v);
		vert_k_c		= x0(k_v  )+1i*y0(k_v  );
		vert_kp1_c	= x0(kp1_v)+1i*y0(kp1_v);
		vert_kp2_c	= x0(kp2_v)+1i*y0(kp2_v);
		% Distances (vectors):
		dm1_v		= abs(vert_k_c  -vert_km1_c);			% from point k-1 to point k
		d01_v		= abs(vert_kp1_c-vert_k_c  );			% from point k   to point k+1
		d12_v		= abs(vert_kp2_c-vert_kp1_c);			% from point k+1 to point k+2
		% points to delete:
		k_delete	= zeros(0,1);
		k			= 1;
		while k<=kmax
			%           dm1_v       d01_v       d12_v
			% ----->|<--------->|<--------->|<--------->|<--------->|<-----
			%      k-1          k          k+1         k+2		    k+3
			% Test:
			% if    ((abs(x0(k)-14.566)<1e-4)&&(abs(y0(k)-7.66455)<1e-4))||...
			% 		((abs(x0(k)-14.439)<1e-2)&&(abs(y0(k)-7.4449)<1e-2))
			% 	x0d=zeros(size(x0));x0d(k_delete)=1;y0d=zeros(size(x0));y0d(k_delete)=1;
			% 	[k_v x0 y0 d01_v x0d y0d]
			% 	k,x0_k=x0(k),y0_k=y0(k),dm1_v_k=dm1_v(k),d01_v_k=d01_v(k),d12_v_k=d12_v(k)
			% 	test=1;
			% end
			if d01_v(k)>dmin
				% OK: nop
			elseif (dm1_v(k)>dmin) && (d01_v(k)<dmin) && (d12_v(k)>dmin)
				% only two points with small distance:
				% delete one of them and calculate the average:
				if kp1_v(k)~=kmax
					k_delete				= [k_delete;kp1_v(k)];
					if (k>1)||(keep_flp==0)
						x(k)				= (x0(k)+x0(kp1_v(k)))/2;
						y(k)				= (y0(k)+y0(kp1_v(k)))/2;
					end
					d						= abs(vert_kp2_c(k)-vert_k_c(k));
					dm1_v(kp2_v(k))	= d;
					k						= k+1;
				end
			elseif (d01_v(k)<dmin) && (d12_v(k)<dmin)

				% more than two points with small distances:
				% delete all necessary next points, so that the remaining distance ist greater than dmin:
				knext					= k+1;
				knext_rest			= vindexrest(knext,kmax);
				knextp1_rest		= vindexrest(knext+1,kmax);
				k_delete				= [k_delete;knext_rest];
				vert_knextp1		= x0(knextp1_rest)+1i*y0(knextp1_rest);
				d						= abs(vert_knextp1-vert_k_c(k));
				dm1_v(knextp1_rest)	= d;
				while (d<dmin)&&(knext<=kmax)
					knext					= knext+1;
					knext_rest			= vindexrest(knext,kmax);
					knextp1_rest		= vindexrest(knext+1,kmax);
					k_delete				= [k_delete;knext_rest];
					vert_knextp1		= x0(knextp1_rest)+1i*y0(knextp1_rest);
					d						= abs(vert_knextp1-vert_k_c(k));
					dm1_v(knextp1_rest)	= d;
				end
				k		= knext;


				% 			% more than two points with small distances:
				% 			% delete all necessary next points, so that the remaining distance ist greater than dmin:
				% 			k_delete				= [k_delete;kp1_v(k)];
				% 			knext					= k+2;
				% 			knext_rest			= kp2_v(k);
				% 			d						= abs(vert_kp2_c(k)-vert_k_c(k));
				% 			dm1_v(knext_rest)	= d;
				% 			while (d<dmin)&&(knext<=kmax)
				% 				k_delete				= [k_delete;knext_rest];
				% 				knext					= knext+1;
				% 				knext_rest			= vindexrest(knext,kmax);
				% 				vert_knext			= x0(knext_rest)+1i*y0(knext_rest);
				% 				d						= abs(vert_knext-vert_k_c(k));
				% 				dm1_v(knext_rest)	= d;
				% 			end
				% 			k		= knext-1;
			end
			k		= k+1;
		end
		% Keep the first and the last point:
		if keep_flp~=0
			k_delete(k_delete==1)		= [];
			k_delete(k_delete==kmax)	= [];
		end
		x(k_delete)		= [];
		y(k_delete)		= [];
	end
	% Test:
	% x0d=zeros(size(x0));x0d(k_delete)=1;y0d=zeros(size(x0));y0d(k_delete)=1;[k_v x0 y0 x0d y0d]

	if ~isempty(dmax) || ~isempty(nmin)
		%---------------------------------------------------------------------------------------------------------
		% add vertices:

		x0			= x;
		y0			= y;
		i			= 0;
		kmax		= length(x0);
		if (abs(x(1)-x(end))<tol)&&(abs(y(1)-y(end))<tol)
			% closed line:
			k_v		= 1:kmax;
		else
			% open line:
			if keep_flp~=0
				k_v	= 1:(kmax-1);
			else
				k_v	= 1:kmax;
			end
		end
		kp1_v		= vindexrest(k_v+1,kmax);
		d_c_v		= (x0(kp1_v)+1i*y0(kp1_v))-(x0(k_v)+1i*y0(k_v));	% vector: distance as complex number
		d_v		= abs(d_c_v);													% vector: distance
		% vector: number of vertices to insert:
		if isempty(dmax)
			n_new_v						= ones(size(d_v))*nmin;
		elseif isempty(nmin)
			n_new_v						= ceil(d_v/dmax)-1;
		else
			n_new_v						= ceil(d_v/dmax)-1;
			n_new_v(n_new_v<nmin)	= nmin;
		end

		%			n_new_v	= ceil(d_v/dmax)-1;											% vector: number of vertices to insert

		for k = 1:length(k_v)
			i			= i+1;
			if n_new_v(k)>=1
				% insert vertices:
				new_vertices_c		= (x0(k)+1i*y0(k)) + (1:n_new_v(k))'/(n_new_v(k)+1)*d_c_v(k);
				x((i+1+n_new_v(k)):(length(x)+n_new_v(k)))	= x((i+1):length(x));
				y((i+1+n_new_v(k)):(length(y)+n_new_v(k)))	= y((i+1):length(y));
				x((i+1           ):(i        +n_new_v(k)))	= real(new_vertices_c);
				y((i+1           ):(i        +n_new_v(k)))	= imag(new_vertices_c);
				i						= i+n_new_v(k);
			end
		end
	end

catch ME
	errormessage('',ME);
end

