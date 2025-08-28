function [dmin,vx_dmin,vy_dmin,i_dmin,k_dmin]=mindistance_poly_p(vx,vy,pqx,pqy)
% Find the minimum distances from query points to a polygon.
% dmin		N*1 vector: minimum distances
% vx_dmin	N*1 vector: nearest points of the polygon to the query points  (x coordinates)
% vy_dmin	N*1 vector: nearest points of the polygon to the query points  (y coordinates)
% i_dmin		N*1 vector: indices of the line segments of the polygon corresponding to vx_dmin, vy_dmin
% k_dmin		N*1 vector: position of the point [vx_dmin vy_dmin] on the line segment i_dmin of the polygon:
%				k_dmin=0:	the point [vx_dmin vy_dmin] is identical to the first point of the line segment i_dmin
%				k_dmin=1:	the point [vx_dmin vy_dmin] is identical to the last  point of the line segment i_dmin
% vx			polygon vertices x
% vy			polygon vertices y
% pqx			N*1 vector: query points (x coordinates)
% pqy			N*1 vector: query points (y coordinates)

try

	if nargin==0
		vx			= [0 1 1 0];
		vy			= [0 0 1 1];
		pqx		= [2.15 0.6];
		pqy		= [0.6  2.15];
		pqx		= [0 0.2 2 2 0.6  0.4 0.5 -0.2 1.2];
		pqy		= [0 0.1 1 2 1.15 0.8 0.5  1.2 0.5];
	end

	vx				= vx(:);
	vy				= vy(:);
	pqx			= pqx(:);
	pqy			= pqy(:);
	ipqmax		= size(pqx,1);
	dmin			= ones(ipqmax,1)*999999;
	vx_dmin		= ones(ipqmax,1)*999999;
	vy_dmin		= ones(ipqmax,1)*999999;
	i_dmin		= ones(ipqmax,1)*999999;
	k_dmin		= ones(ipqmax,1)*999999;

	p_poly_c		= vx+1i*vy;
	imax			= size(p_poly_c,1);
	i				= (1:imax)';
	ip1			= vindexrest(i+1,imax);
	dp_poly		= p_poly_c(ip1,:)-p_poly_c;

	% p_poly_c		polygon vertices in the complex plane
	% p_q_c			query point in the complex plane
	% px_c			point in the complex plane with the shortest distance to the query point
	% dp_poly		distance between two polygon vertices in the complex plane
	% calculation of K_poly and K_q:
	% px_c = p_poly_c+K_poly*dp_poly = p_q_c-K_q*1i*dp_poly
	% p_poly_c+K_poly*dp_poly-p_q_c+K_q*1i*dp_poly = 0
	% (K_poly+K_q*1i)*dp_poly = p_q_c-p_poly_c
	% (K_poly+K_q*1i) = (p_q_c-p_poly_c)/dp_poly
	for ipq=1:ipqmax
		p_q_c			= pqx(ipq,1)+1i*pqy(ipq,1);
		K				= (p_q_c-p_poly_c)./dp_poly;
		K_poly		= real(K);
		% K_q			= imag(K);
		K_poly(K_poly<0)	= 0;
		K_poly(K_poly>1)	= 1;
		d_v					= abs((p_poly_c+K_poly.*dp_poly)-p_q_c);
		[dmin(ipq,1),i_dmin(ipq,1)]	= min(d_v);
		k_dmin(ipq,1)	= K_poly(i_dmin(ipq,1),1);
		px_c					= p_poly_c(i_dmin(ipq,1))+k_dmin(ipq,1)*dp_poly(i_dmin(ipq,1));
		vx_dmin(ipq,1)		= real(px_c);
		vy_dmin(ipq,1)		= imag(px_c);
	end


	% Test:
	if nargin==0
		i_dmin
		k_dmin
		hf				= 47832965;
		hf				= figure(hf);
		clf(hf,'reset');
		ha				= axes;
		hold(ha,'on');
		plot(ha,vx,vy,'x-g','LineWidth',2);
		for ipq=1:ipqmax
			text(ha,pqx(ipq,1),pqy(ipq,1),num2str(ipq));
			plot(ha,pqx(ipq,1),pqy(ipq,1),'.r','MarkerSize',12);							% query point
			plot(ha,vx_dmin(ipq,1),vy_dmin(ipq,1),'xb');										% vertex with the shortest distance
			plot(ha,[vx_dmin(ipq,1) pqx(ipq,1)],[vy_dmin(ipq,1) pqy(ipq,1)],'-b');	% shortest distance
		end
	end

catch ME
	errormessage('',ME);
end

