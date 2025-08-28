function polyout=insertvertex_poly(polyin,vertices,tol)
% Adds vertices to an existing polygon, if their position is already on the edge of the polygon.
% polyin			polygon or polygon vector to be expanded
% vertices		new vertices to be checked and added: N-by-2 matrix, where N is the number of vertices.
% polyout		extended polygon

try

	% Test:
	if nargin==0
		vx				= [0   ;1  ;1.5;0.5;0.5;1.5];
		vy				= [-0.5;0.5;1.5;0.5;1  ;2  ];
		vertices		= [vx vy];
		polyin(1)	= polyshape([0 0 1 1],[0 1 1 0]);
		polyin(1)	= addboundary(polyin(1),[-1 -1 2 2],[-1 2 2 -1]);
		polyin(2)	= polyshape([-0.5 0.5 0],[-0.5 -0.5 0.5]);
		polyin(2)	= addboundary(polyin(2),[-0.5 0.5 0]*2,[-0.5 -0.5 0.5]*2);
		tol		= 1e-7;
		hf=figure(1111);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha=subplot(2,1,1);
		lw=1.0;
		hold(ha,'on');
		plot(ha,polyin(1))
		plot(ha,polyin(1).Vertices(:,1),polyin(1).Vertices(:,2),...
			'LineStyle','none','LineWidth',lw,'Color','m','Marker','.','MarkerSize',35)
		plot(ha,polyin(2))
		plot(ha,polyin(2).Vertices(:,1),polyin(2).Vertices(:,2),...
			'LineStyle','none','LineWidth',lw,'Color','c','Marker','.','MarkerSize',20)
		plot(ha,vx,vy,...
			'LineStyle','none','LineWidth',lw,'Color','b','Marker','x','MarkerSize',10);
	end

	polyout	= polyin;
	for ip=1:length(polyin)
		[bx,by]		= boundary(polyin(ip));
		lineout		= insertvertex_line([bx by],vertices,tol);
		polyout(ip)	= polyshape(lineout(:,1),lineout(:,2),'KeepCollinearPoints',true);
	end

	% Test:
	if nargin==0
		ha=subplot(2,1,2);
		lw=1.0;
		hold(ha,'on');
		plot(ha,polyout(1))
		plot(ha,polyout(1).Vertices(:,1),polyout(1).Vertices(:,2),...
			'LineStyle','none','LineWidth',lw,'Color','m','Marker','.','MarkerSize',35)
		plot(ha,polyout(2))
		plot(ha,polyout(2).Vertices(:,1),polyout(2).Vertices(:,2),...
			'LineStyle','none','LineWidth',lw,'Color','c','Marker','.','MarkerSize',20)
		plot(ha,vertices(:,1),vertices(:,2),...
			'LineStyle','none','LineWidth',lw,'Color','b','Marker','x','MarkerSize',10);
		polyout_1_Vertices=polyout(1).Vertices
		polyout_2_Vertices=polyout(2).Vertices
	end

catch ME
	errormessage('',ME);
end

