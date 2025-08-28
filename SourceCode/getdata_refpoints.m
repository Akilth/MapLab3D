function pos_refpoints=getdata_refpoints(iobj,connways_eqtags,text_symb,testplot,ha)
% Referencepoints of the symbols (all positions where to print the symbol): pos_refpoints(i,:)

global PP GV

try

	switch text_symb
		case 'symbol'
			dist_betw_refpoints				= PP.obj(iobj,1).symbolpar.dist_betw_symbols;
			placing_on_margin					= PP.obj(iobj,1).symbolpar.placing_on_margin;
			placing_on_node					= PP.obj(iobj,1).symbolpar.placing_on_node;
			placing_on_center					= PP.obj(iobj,1).symbolpar.placing_on_center;
			placing_on_regions				= PP.obj(iobj,1).symbolpar.placing_on_regions;
			placing_on_margin_randposvar	= 0;
			placing_on_margin_type			= PP.obj(iobj,1).symbolpar.placing_on_margin_type;
		case 'text'
			dist_betw_refpoints				= PP.obj(iobj,1).textpar.dist_betw_texts;
			placing_on_margin					= PP.obj(iobj,1).textpar.placing_on_margin;
			placing_on_node					= PP.obj(iobj,1).textpar.placing_on_node;
			placing_on_center					= PP.obj(iobj,1).textpar.placing_on_center;
			placing_on_regions				= PP.obj(iobj,1).textpar.placing_on_regions;
			placing_on_margin_randposvar	= PP.obj(iobj,1).textpar.placing_on_margin_randposvar;
			placing_on_margin_type			= PP.obj(iobj,1).textpar.placing_on_margin_type;
		case 'change_text'
			dist_betw_refpoints				= 10;
			placing_on_margin					= 0;
			placing_on_node					= 1;
			placing_on_center					= 0;
			placing_on_regions				= 0;
			placing_on_margin_randposvar	= 0;
			placing_on_margin_type			= 'lines';
		otherwise
			errormessage;
	end
	pos_refpoints	= zeros(0,2);		% column 1: x, column 2: y

	if placing_on_margin~=0

		% Calculate the center of connways_eqtags:
		[x_center,y_center]	= connways_center(iobj,connways_eqtags);
		if ~isempty(x_center)&&~isempty(y_center)

			if testplot==1
				plot(ha,x_center,y_center,...
					'LineWidth',1.5,'LineStyle','none','Color','r','Marker','x','MarkerSize',11);
			end

			% Collect all points in one matrix:
			connways_eqtags_xy		= [];
			dmin							= 0.2;	% for the calculation of the reference point: change the resolution
			dmax							= 0.2;
			nmin							= [];
			if strcmp(placing_on_margin_type,'lines')||strcmp(placing_on_margin_type,'lines and areas')
				for k=1:size(connways_eqtags.lines,1)
					[x,y]						= changeresolution_xy(...
						connways_eqtags.lines(k,1).xy(:,1),...
						connways_eqtags.lines(k,1).xy(:,2),dmax,dmin,nmin);
					connways_eqtags_xy	= [connways_eqtags_xy;[x y]];
				end
			end
			if strcmp(placing_on_margin_type,'areas')||strcmp(placing_on_margin_type,'lines and areas')
				for k=1:size(connways_eqtags.areas,1)
					if    (abs(connways_eqtags.areas(k,1).xy(1,1)-connways_eqtags.areas(k,1).xy(end,1))<GV.tol_1)&&...
							(abs(connways_eqtags.areas(k,1).xy(1,2)-connways_eqtags.areas(k,1).xy(end,2))<GV.tol_1)
						% First and last point are equal:
						[x,y]		= changeresolution_xy(...
							connways_eqtags.areas(k,1).xy(1:end,1),...
							connways_eqtags.areas(k,1).xy(1:end,2),dmax,dmin,nmin);
					else
						% First and last point are not equal:
						[x,y]		= changeresolution_xy(...
							[connways_eqtags.areas(k,1).xy(1:end,1);connways_eqtags.areas(k,1).xy(1,1)],...
							[connways_eqtags.areas(k,1).xy(1:end,2);connways_eqtags.areas(k,1).xy(1,2)],dmax,dmin,nmin);
					end
					connways_eqtags_xy	= [connways_eqtags_xy;[x y]];
				end
			end

			if ~isempty(connways_eqtags_xy)

				% Text: modification of x_center and/or y_center:
				random_number	= placing_on_margin_randposvar*exp(1i*rand*2*pi);
				x_center			= x_center+real(random_number);
				y_center			= y_center+imag(random_number);

				% pos_refpoints(1,:): "middle" point of connways_eqtags_xy:
				distance_to_refpoint					= sqrt(...
					(connways_eqtags_xy(:,1)-x_center).^2+...
					(connways_eqtags_xy(:,2)-y_center).^2    );
				[~,i_mindist]							= min(distance_to_refpoint);
				pos_refpoints(1,:)					= connways_eqtags_xy(i_mindist,:);
				if testplot==1
					plot(ha,[x_center pos_refpoints(1,1)],[y_center pos_refpoints(1,2)],...
						'LineWidth',1.5,'LineStyle','-','Color','r','Marker','+','MarkerSize',11);
				end

				% Other points on connways_eqtags_xy with a minimum distance of dist_betw_refpoints:
				if dist_betw_refpoints>0
					sidelength							= 2;		% sidelength=radius*phi, n*phi=2*pi
					n_poly_dist_betw_symbols		= max(3,ceil(2*pi*dist_betw_refpoints/sidelength));
					center_poly_dist_betw_symbols	= pos_refpoints(end,:);
					radius_poly_dist_betw_symbols	= dist_betw_refpoints;
					poly_dist_betw_symbols			= nsidedpoly(n_poly_dist_betw_symbols,...
						'Center',center_poly_dist_betw_symbols,'Radius',radius_poly_dist_betw_symbols);
					% Delete all points that are inside the circle poly_dist_betw_symbols:
					% TFin									= isinterior(poly_dist_betw_symbols,connways_eqtags_xy);
					TFin									= inpolygon(...				% faster than isinterior
						connways_eqtags_xy(:,1),...									% query points
						connways_eqtags_xy(:,2),...
						poly_dist_betw_symbols.Vertices(:,1),...					% polygon area
						poly_dist_betw_symbols.Vertices(:,2));
					connways_eqtags_xy(TFin,:)		= [];
					while size(connways_eqtags_xy,1)>0
						distance_v										= zeros(size(pos_refpoints,1),1);
						i_mindist_v										= zeros(size(pos_refpoints,1),1);
						for i=1:size(pos_refpoints,1)
							distance_to_refpoint						= sqrt(...
								(connways_eqtags_xy(:,1)-pos_refpoints(i,1)).^2+...
								(connways_eqtags_xy(:,2)-pos_refpoints(i,2)).^2    );
							[distance_v(i,1),i_mindist_v(i,1)]	= min(distance_to_refpoint);
						end
						[~,i_mindist]									= min(distance_v);
						pos_refpoints(end+1,:)						= connways_eqtags_xy(i_mindist_v(i_mindist,1),:);
						center_poly_dist_betw_symbols				= pos_refpoints(end,:);
						poly_dist_betw_symbols						= nsidedpoly(n_poly_dist_betw_symbols,...
							'Center',center_poly_dist_betw_symbols,'Radius',radius_poly_dist_betw_symbols);
						% TFin												= isinterior(poly_dist_betw_symbols,connways_eqtags_xy);
						TFin												= inpolygon(...	% faster than isinterior
							connways_eqtags_xy(:,1),...									% query points
							connways_eqtags_xy(:,2),...
							poly_dist_betw_symbols.Vertices(:,1),...					% polygon area
							poly_dist_betw_symbols.Vertices(:,2));
						connways_eqtags_xy(TFin,:)					= [];
						if testplot==1
							plot(ha,poly_dist_betw_symbols,...
								'FaceAlpha',0.05,'FaceColor','r',...
								'LineWidth',0.5,'LineStyle','-','EdgeColor','r');
						end
					end
				end
			end

		end
	end

	if placing_on_node~=0
		if ~isempty(connways_eqtags.nodes)
			pos_refpoints	= [pos_refpoints;connways_eqtags.nodes.xy(:,1) connways_eqtags.nodes.xy(:,2)];
		end
	end

	if placing_on_center~=0
		% Calculate the center of connways_eqtags:
		[x_center,y_center]				= connways_center(iobj,connways_eqtags);
		if ~isempty(x_center)&&~isempty(y_center)
			pos_refpoints	= [pos_refpoints;x_center y_center];
		end
	end

	if placing_on_regions~=0
		[x_center_v,y_center_v]			= connways_center(iobj,connways_eqtags,'regions',text_symb);
		for k=1:length(x_center_v)
			pos_refpoints	= [pos_refpoints;x_center_v(k) y_center_v(k)];
		end
	end

	% Delete duplicate points:
	pos_eqtags_refpoints_c	= pos_refpoints(:,1)+1i*pos_refpoints(:,2);
	pos_eqtags_refpoints_c	= unique(pos_eqtags_refpoints_c);
	pos_refpoints		= [real(pos_eqtags_refpoints_c) imag(pos_eqtags_refpoints_c)];

	% Delete nans:
	pos_refpoints(isnan(pos_refpoints(:,1))|isnan(pos_refpoints(:,2)))	= [];

	% If text_symb='change_text': Use only one reference point:
	if strcmp(text_symb,'change_text')
		pos_refpoints		= mean(pos_refpoints,1);
	end

catch ME
	errormessage('',ME);
end

