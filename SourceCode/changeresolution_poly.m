function polyout=changeresolution_poly(polyin,dmax,dmin,nmin)
% 1)	If dmax is not empty:
%		Inserts vertices to polyin, so that the distance between two vertices is less than dmax
% 2)	If dmin is not empty:
%		Deletes vertices in polyin, so that the distance between two vertices is at least dmin
%		Possibly there remains no data in polyout!
% 3)	If nmin is not empty:
%		Insert at least nmin vertices between 2 vertices in polyin (AFTER deleting vertices according dmin)

global GV

try

	if nargin==0
		% Test:
		testnr		= 1;
		switch testnr
			case 1
				polyin(1)	= polyshape([-1 -1 2 2],[-1 2 2 -1]);
				polyin(1)	= changeresolution_poly(polyin(1),0.1,[],[]);
				xy				= [...
					0		0;...
					0		0.05;...
					0		1;...
					0.45	1;...
					0.55	1;...
					1		1;...
					1		0.6;...
					1		0.5;...
					1		0.4;...
					1		0;...
					0.65	0;...
					0.55	0;...
					0.45	0;...
					0.35	0;...
					0.25	0;...
					0.15	0;...
					0.05	0];
				polyin(1)	= addboundary(polyin(1),xy(:,1),xy(:,2));
				polyin(2)	= polyshape([-0.5 0.5 0]+4,[-0.5 -0.5 1]);
				polyin(2)	= addboundary(polyin(2),[-0.5 0.5 0]*2+4,[-0.5 -0.5 1]*2);
				polyin(3)	= polyshape([2.5 2.45 2.55],[-1 2 2]);
				dmax			= 0.5;
				dmin			= [];
				nmin			= [];
			case 2
				x0 = [...
					17.1668903917402;...
					-17.1673338282598;...
					-17.1673338282598;...
					17.1668903917402];
				y0 = [...
					-17.0114648235547;...
					-17.0114648235547;...
					17.0141782564453;...
					17.0141782564453];
				dmax		= 1;
				dmin		= [];
				nmin		= [];
				polyin	= polyshape(x0,y0);
		end
		hf=figure(1111);
		clf(hf,'reset');
		set(hf,'Tag','maplab3d_figure');
		ha=subplot(2,1,1);
		lw=1.0;
		hold(ha,'on');
		plot(ha,polyin(1))
		plot(ha,polyin(1).Vertices(:,1),polyin(1).Vertices(:,2),...
			'LineStyle','none','LineWidth',lw,'Color','m','Marker','.','MarkerSize',35)
		if length(polyin)>=2
			plot(ha,polyin(2))
			plot(ha,polyin(2).Vertices(:,1),polyin(2).Vertices(:,2),...
				'LineStyle','none','LineWidth',lw,'Color','c','Marker','.','MarkerSize',20)
		end
		if length(polyin)>=3
			plot(ha,polyin(3))
			plot(ha,polyin(3).Vertices(:,1),polyin(3).Vertices(:,2),...
				'LineStyle','none','LineWidth',lw,'Color','r','Marker','.','MarkerSize',12)
		end
		axis equal
	end

	polyout	= polyin;
	if GV.warnings_off
		warning('off','MATLAB:polyshape:boundary3Points');
		warning('off','MATLAB:polyshape:repairedBySimplify');
		warning('off','MATLAB:polyshape:boolOperationFailed');
	end
	for i_poly=1:length(polyin)
		n_boundaries	= numboundaries(polyin(i_poly));
		x_boundary		= zeros(0,1);
		y_boundary		= zeros(0,1);
		for i_boundary=1:n_boundaries
			[x0,y0]		= boundary(polyin(i_poly),i_boundary);
			% Change the resolution:
			[x,y]			= changeresolution_xy(x0,y0,dmax,dmin,nmin);
			% Assign the results:
			if isempty(x_boundary)
				x_boundary		= x;
				y_boundary		= y;
			else
				x_boundary		= [x_boundary;NaN;x];
				y_boundary		= [y_boundary;NaN;y];
			end
		end
		% Possibly there remains no data in polyout!
		polyout(i_poly)	= polyshape(x_boundary,y_boundary,...
			'KeepCollinearPoints',true,'Simplify',true);
	end
	if GV.warnings_off
		warning('on','MATLAB:polyshape:boundary3Points');
		warning('on','MATLAB:polyshape:repairedBySimplify');
		warning('on','MATLAB:polyshape:boolOperationFailed');
	end

	% Test:
	if nargin==0
		% 	polyin_Vertices	 = polyin(1).Vertices
		% 	polyout_Vertices	= polyout(1).Vertices
		ha=subplot(2,1,2);
		lw=1.0;
		hold(ha,'on');
		plot(ha,polyout(1))
		plot(ha,polyout(1).Vertices(:,1),polyout(1).Vertices(:,2),...
			'LineStyle','none','LineWidth',lw,'Color','m','Marker','.','MarkerSize',35)
		eval('polyout_1	= polyout(1)');
		if length(polyin)>=2
			plot(ha,polyout(2))
			plot(ha,polyout(2).Vertices(:,1),polyout(2).Vertices(:,2),...
				'LineStyle','none','LineWidth',lw,'Color','c','Marker','.','MarkerSize',20)
			eval('polyout_2	= polyout(2)');
		end
		if length(polyin)>=3
			plot(ha,polyout(3))
			plot(ha,polyout(3).Vertices(:,1),polyout(3).Vertices(:,2),...
				'LineStyle','none','LineWidth',lw,'Color','r','Marker','.','MarkerSize',12)
			eval('polyout_3	= polyout(3)');
		end
		axis equal
	end

catch ME
	errormessage('',ME);
end

