function lineout=insertvertex_line(linein,vertices,tol)
% Adds vertices to an existing line, if their position is on the path of the line.
% linein			line without extra points
% vertices		new points to be checked and added: N-y-2 matrix, where N is the number of points.
% lineout		line with extra points

try

	% Test:
	if nargin==0
		vx				= [0;1  ;1.5;0.5;0.5;1];
		vy				= [0;0.5;1.5;0.5;1  ;0];
		vertices		= [vx vy];
		linein		= [...
			0 0;...
			0 1;...
			1 1;...
			1 0];
		tol		= 1e-7;
		hf=figure(1111);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha=subplot(2,1,1);
		lw=1.0;
		hold(ha,'on');
		plot(ha,linein(:,1),linein(:,2),...
			'LineStyle','-','LineWidth',lw,'Color','m','Marker','.','MarkerSize',35)
		plot(ha,vx,vy,...
			'LineStyle','none','LineWidth',lw,'Color','b','Marker','x','MarkerSize',10);
	end

	vx		= vertices(:,1);
	vy		= vertices(:,2);
	x		= linein(:,1);
	y		= linein(:,2);
	for iv=1:length(vx)
		ib	= 1;
		while ib<length(x)
			% vertex to be inserted: vx(iv), vy(iv)
			% existing vertices:     x(ib), y(ib)
			db	= ( x(ib+1)+1i* y(ib+1))-(x(ib)+1i*y(ib));
			dx	= (vx(iv  )+1i*vy(iv  ))-(x(ib)+1i*y(ib));
			K	= dx/db;
			if ~isnan(K)
				if (abs(K)>tol)&&(abs(K)<(1-tol))&&(abs(angle(K))<tol)
					% insert vertex:
					x((ib+2):(length(x)+1))	= x((ib+1):length(x));
					x(ib+1)						= vx(iv);
					y((ib+2):(length(y)+1))	= y((ib+1):length(y));
					y(ib+1)						= vy(iv);
					break
				end
			end
			ib	= ib+1;
		end
	end
	lineout	= [x y];


	% Test:
	if nargin==0
		ha=subplot(2,1,2);
		lw=1.0;
		hold(ha,'on');
		plot(ha,lineout(:,1),lineout(:,2),...
			'LineStyle','-','LineWidth',lw,'Color','m','Marker','.','MarkerSize',35)
		plot(ha,vx,vy,...
			'LineStyle','none','LineWidth',lw,'Color','b','Marker','x','MarkerSize',10);
	end

catch ME
	errormessage('',ME);
end

