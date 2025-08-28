function [poly0,poly_cut,hplot_temp,cdte,piece_no]=...
	cut_into_pieces(poly0,poly_cut,poly_tile,color_no,msg,hf_testplot,ha_testplot,hplot_temp,cdte,piece_no)
% Syntax:	poly_cut	= polyshape();
%				[poly0,poly_cut,hplot_temp,cdte,piece_no]	= cut_into_pieces(poly0,poly_cut,poly_tile,color_no,msg);
%				[poly0,poly_cut,~         ,~   ,~       ]	= cut_into_pieces(poly0,poly_cut,poly_tile,color_no,msg);
%				[poly0,poly_cut]									= cut_into_pieces(poly0,poly_cut,poly_tile,color_no,msg);
%
% input variables:
%		poly0				polygon before cutting
%		poly_cut			cutting lines:			initialization:
%														poly_cut	= polyshape();
%		poly_tile		tiles						Nx1 vector of polyshape objects:		poly_tile(i_tile,1)
%														or cell array:								GV_H.poly_tiles{i_tile,1}
%		color_no			color number
%		msg				waitbar message
%		hf_testplot		only for testing:		testplot figure handle
%		ha_testplot									testplot axes handle
%		hplot_temp									testplot plot handles
%		cdte											cancel due to error (structure cdte.tf)
%		piece_no										cutting line counter
%
% output variables:
%		poly0				polygon after cutting
%		poly_cut			cutting lines
%		hplot_temp		only for testing:		testplot plot handles
%		cdte											cancel due to error (structure cdte.tf)
%		piece_no										cutting line counter


global PP GV GV_H WAITBAR

try

	% Initializations:
	if nargin<=5
		% First call of cut_into_pieces:
		hf_testplot		= [];
		ha_testplot		= [];
		hplot_temp		= [];
		cdte.tf			= false;				% Cancel due to error
		piece_no			= 1;					% Piece number
		firstcall		= true;
	else
		firstcall		= false;
	end
	testplot				= 0;
	testplot2			= 0;					% Show steps of dividing line variation
	tol_1					= 1e-6;
	collect_all_data	= false;				% false: faster execution time
	WAITBAR.t1			= clock;
	if iscell(poly_tile)
		poly_tile_1		= polyshape();
		for i_tile=1:size(GV_H.poly_tiles,1)
			poly_tile_1(i_tile,1)	= poly_tile{i_tile,1}.Shape;
		end
		poly_tile		= poly_tile_1;
	end
	if nargin==0
		% Testing:
		profile_activ	= false;
		poly_cut			= polyshape();
		color_no			= 2;
		msg				= 'Testing';
		testdaten		= 1;
		if profile_activ&&~isdeployed
			%#exclude profile
			profile off
			profile on
		end
		switch testdaten
			case 1
				poly0_vertices	= [...
					32.514	382.571;	34.768	381.037;	44.504	374.036;	53.813	363.562;...
					53.187	356.303;	56.731	354.452;	60.179	357.322;	65.733	352.517;...
					69.388	348.465;	105.138	304.319;	109.721	298.493;	105.253	292.371;...
					96.369	295.683;	91.174	299.307;	88.813	301.255;	76.037	314.006;...
					45.354	352.067;	36.819	345.018;	80.256	291.872;	83.921	291.037;...
					83.7	287.673;	86.488	284.278;	26.353	235.143;	28.99	232.069;...
					34.249	225.646;	43.501	214.411;	47.73	209.308;	21.422	184.293;...
					14.032	193.476;	0.9108	189.436;	0.7775	190.948;	-18.132	169.644;...
					-27.314	180.851;	-34.239	171.468;	-38.961	173.225;	-42.326	171.044;...
					-41.665	167.152;	-34.44	165.392;	-31.707	155.977;	-28.223	158.696;...
					-20.92	149.765;	-35.513	138.454;	-42.5	135.469;	-45.605	160.525;...
					-45.755	168.147;	-42.552	171.024;	-46.998	179.323;	-46.408	181.565;...
					-51.584	188.008;	-55.757	186.248;	-54.869	178.97;	-54.201	173.579;...
					-54.201	173.579;	-50.984	138.599;	-50.627	125.242;	-51.185	120.428;...
					-56.474	110.455;	-51.473	107.557;	-46.538	115.386;	-41.489	122.429;...
					-34.443	130.288;	-25.98	137.878;	26.736	181.139;	28.384	179.184;...
					46.887	194.525;	76.971	218.432;	79.519	219.86;	82.205	221.61;...
					84.98	223.881;	88.203	226.649;	92.741	230.596;	98.827	235.384;...
					106.173	240.593;	120.153	249.359;	124.923	252.017;	130.385	254.433;...
					139.433	259.39;	143.866	247.552;	143.866	247.552;	146.988	238.632;...
					151.425	227.073;	153.62	222.06;	158.878	222.564;	160.66	218.19;...
					175.99	177.657;	185.087	147.4;	188.278	142.917;	193.664	127.62;...
					195.263	122.13;	207.107	89.523;	208.828	82.349;	225.003	41.15;...
					141.356	41.15;	135.182	48.577;	132.161	41.397;	132.343	41.15;...
					-27.722	41.15;	-32.238	46.904;	-37.726	42.429;	-52.205	55.225;...
					-59.326	49.141;	-68.842	43.03;	-67.925	41.15;	-87.73	41.15;...
					-85.93	47.655;	-64.834	82.99;	-63.51	85.695;	-58.593	94.145;...
					-63.354	98.988;	-80.184	71.359;	-93.732	48.289;	-98.97	41.15;...
					-249.311	41.15;	-253.925	43.144;	-266.993	50.509;	-255.889	70.916;...
					-247.243	70.916;	-245.493	71.385;	-244.212	72.666;	-243.743	74.416;...
					-243.743	102.091;	-244.212	103.841;	-245.493	105.123;	-247.243	105.591;...
					-354.103	105.591;	-385.917	121.403;	-427.987	142.727;	-437.31	151.856;...
					-439.697	155.023;	-441.137	158.431;	-444.118	165.538;	-446.38	177.247;...
					-454.075	195.231;	-460.896	209.195;	-463.481	216.629;	-464.295	223.476;...
					-455.492	238.137;	-436.122	258.529;	-440.353	262.416;	-443.389	265.864;...
					-443.053	270.454;	-423.488	296.492;	-408.095	314.631;	-412.472	318.527;...
					-423.489	306.722;	-434.855	294.044;	-437.038	289.135;	-442.872	282.285;...
					-453.695	268.432;	-456.447	264.13;	-461.936	256.196;	-465.121	248.266;...
					-468.743	242.001;	-473.463	233.835;	-474.335	232.525;	-474.335	313.592;...
					-472.327	314.935;	-469.652	316.511;	-464.312	319.449;	-455.933	312.66;...
					-455.657	312.643;	-455.361	312.411;	-453.875	312.533;	-452.661	312.457;...
					-452.491	312.646;	-451.747	312.707;	-409.88	359.931;	-400.691	369.916;...
					-404.161	373.963;	-455.392	339.607;	-474.335	326.838;	-474.335	369.912;...
					-433.783	397.037;	-376.91	434.564;	-362.459	446.234;	-349.527	457.572;...
					-338.081	469.993;	-334.19	475.134;	-279.006	475.134;	-281.311	472.639;...
					-293.202	457.86;	-292.752	451.433;	-294.917	445.731;	-313.991	425.033;...
					-302.519	413.96;	-295.517	406.601;	-291.993	407.65;	-291.172	412.108;...
					-234.828	416.039;	-223.181	400.496;	-216.691	349.258;	-181.168	358.523;...
					-183.109	382.223;	-155.293	396.519;	-150.985	388.172;	-141.152	382.273;...
					-137.923	374.324;	-116.748	384.718;	-96.306	333.749;	-91.902	318.995;...
					-89.781	311.894;	-86.739	301.749;	-85.65	298.066;	-81.605	284.515;...
					-72.781	261.386;	-71.44	257.868;	-68.948	247.986;	-73.307	245.345;...
					-72.629	241.326;	-65.872	239.885;	-58.182	206.137;	-56.188	189.784;...
					-40.34	196.751;	-47.895	205.972;	-51.537	210.384;	-53.378	214.865;...
					-56.6	229.03;	-59.196	241.277;	-62.712	254.936;	-66.619	265.075;...
					-67.554	272.058;	-73.861	289.349;	-62.273	299.316;	-59.721	296.683;...
					-38.542	314.536;	-47.165	324.788;	-38.787	332.049;	-49.768	345.038;...
					-0.8408	380.791;	0.0135	387.305;	0.819	393.361;	14.386	391.424;...
					21.605	388.564;	26.352	386.394;	 NaN	 NaN;	-153.691	191.068;...
					-149.368	210.394;	-138.645	244.607;	-145.126	249.387;	-147.661	250.038;...
					-151.499	252.763;	-156.574	253.649;	-159.56	253.178;	-163.843	251.566;...
					-170.365	248.151;	-174.585	247.527;	-184.386	253.467;	-209.233	258.015;...
					-205.89	277.179;	-201.313	279.096;	-192.864	279.043;	-185.994	284.312;...
					-184.31	285.602;	-179.475	290.441;	-172.791	288.985;	-168.376	286.442;...
					-158.744	265.516;	-152.507	264.875;	-149.375	267.167;	-129.165	273.109;...
					-126.857	283.795;	-129.778	289.686;	-125.643	316.715;	-128.919	326.516;...
					-175.42	311.171;	-192.782	314.926;	-189.262	334.331;	-216.869	339.495;...
					-215.78	344.534;	-226.353	346.216;	-231.017	329.028;	-238.27	332.216;...
					-257.177	326.674;	-263.759	314.447;	-242.767	312.767;	-245.586	291.859;...
					-268.612	296.356;	-271.715	279.622;	-306.975	286.233;	-317.942	288.199;...
					-316.519	262.742;	-311.011	227.647;	-307.745	214.643;	-305.242	206.548;...
					-279.96	206.973;	-283.871	237.892;	-270.625	239.525;	-267.684	215.847;...
					-265.131	216.229;	-253.567	214.178;	-250.578	231.795;	-234.431	229.002;...
					-225.085	227.386;	-229.667	204.16;	-159.634	191.685];
				poly0	= polyshape(poly0_vertices(:,1),poly0_vertices(:,2));
				poly0	= scale(poly0,1);
			case 2
				poly0	= polyshape([1 4 4 1],[2 2 3 3]);
				poly0 = rotate(poly0,50);
				poly0	= scale(poly0,500);
			case 3
				poly0_0	= nsidedpoly(18);
				poly0		= polyshape();
				poly0(1,1)	= scale(poly0_0,110);
				poly0(2,1)	= scale(poly0_0,120);
				poly0(1,2)	= scale(poly0_0,130);
				poly0(2,2)	= scale(poly0_0,140);
				poly0			= translate(poly0,0,270);
		end
		K_tiles			= 4;
		offset_tiles	= [-130 130;-130 130;-130 130;-130 130];
		poly_tile	= polyshape();
		poly_tile(1,1) = polyshape(offset_tiles+K_tiles*[...
			-90 33;...
			-90 93;...
			-30 93;...
			-30 33]);
		poly_tile(2,1) = polyshape(offset_tiles+K_tiles*[...
			-30 33;...
			-30 93;...
			30 93;...
			30 33]);
		poly_tile(3,1) = polyshape(offset_tiles+K_tiles*[...
			30 33;...
			30 93;...
			90 93;...
			90 33]);
		poly_tile(4,1) = polyshape(offset_tiles+K_tiles*[...
			-90 -27;...
			-90 33;...
			-30 33;...
			-30 -27]);
		poly_tile(5,1) = polyshape(offset_tiles+K_tiles*[...
			-30 -27;...
			-30 33;...
			30 33;...
			30 -27]);
		poly_tile(6,1) = polyshape(offset_tiles+K_tiles*[...
			30 -27;...
			30 33;...
			90 33;...
			90 -27]);
	end
	if nargin==0
		gap_style						= 2;			%
		gap_width						= 0.25;		%
		dist_gap_margin				= 3;			%
		% interp1 function: 'linear', 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic', 'makima', 'spline'
		% interp1 function: 'linear', 'nearest', 'pchip', 'cubic', 'v5cubic', 'makima', 'spline'
		gap_pattern_style			= 'linear';	% 'linear'
		gap_pattern_pulsespacing	= 2;			%
		gap_pattern_width				= 3;			% 3
		gap_pattern_dmin				= 0.25;		%
		gap_pattern_regularity		= 0.5;		%
		maxdimx							= 208;		%
		maxdimy							= 198;		%
		maxdiag							= 1000;		%
		mindimx							= 10;			%
		mindimy							= 10;			%
		mindiag							= 15;			%
		use_rand							= true;		% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	else
		icolspec							= PP.color(color_no,1).spec;
		gap_style						= PP.colorspec(icolspec).cut_into_pieces.gap_style;
		gap_width						= max(PP.colorspec(icolspec).cut_into_pieces.gap_width,2*tol_1);
		dist_gap_margin				= max(PP.colorspec(icolspec).cut_into_pieces.dist_gap_margin,2*tol_1);
		% interp1 function: 'linear', 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic', 'makima', 'spline'
		% interp1 function: 'linear', 'nearest', 'pchip', 'cubic', 'v5cubic', 'makima', 'spline'
		gap_pattern_style				= PP.colorspec(icolspec).cut_into_pieces.gap_pattern_style;
		gap_pattern_pulsespacing	= PP.colorspec(icolspec).cut_into_pieces.gap_pattern_pulsespacing;
		gap_pattern_width				= PP.colorspec(icolspec).cut_into_pieces.gap_pattern_width;
		gap_pattern_dmin				= PP.colorspec(icolspec).cut_into_pieces.gap_pattern_dmin;
		gap_pattern_regularity		= PP.colorspec(icolspec).cut_into_pieces.gap_pattern_regularity;
		maxdimx							= PP.colorspec(icolspec).cut_into_pieces.maxdimx;
		maxdimy							= PP.colorspec(icolspec).cut_into_pieces.maxdimy;
		maxdiag							= PP.colorspec(icolspec).cut_into_pieces.maxdiag;
		mindimx							= PP.colorspec(icolspec).cut_into_pieces.mindimx;
		mindimy							= PP.colorspec(icolspec).cut_into_pieces.mindimy;
		mindiag							= PP.colorspec(icolspec).cut_into_pieces.mindiag;
		use_rand							= true;		% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	end
	colorspec														= [];
	colorspec.cut_into_pieces.gap_style						= gap_style;
	colorspec.cut_into_pieces.gap_width						= gap_width;
	colorspec.cut_into_pieces.dist_gap_margin				= dist_gap_margin;
	colorspec.cut_into_pieces.gap_pattern_style			= gap_pattern_style;
	colorspec.cut_into_pieces.gap_pattern_pulsespacing	= gap_pattern_pulsespacing;
	colorspec.cut_into_pieces.gap_pattern_width			= gap_pattern_width;
	colorspec.cut_into_pieces.gap_pattern_dmin			= gap_pattern_dmin;
	colorspec.cut_into_pieces.gap_pattern_regularity	= gap_pattern_regularity;
	colorspec.cut_into_pieces.maxdimx						= maxdimx;
	colorspec.cut_into_pieces.maxdimy						= maxdimy;
	colorspec.cut_into_pieces.maxdiag						= maxdiag;
	colorspec.cut_into_pieces.mindimx						= mindimx;
	colorspec.cut_into_pieces.mindimy						= mindimy;
	colorspec.cut_into_pieces.mindiag						= mindiag;

	% Testplot:
	if testplot~=0
		if nargin<=5
			hf_testplot		= 57892983;
			hf_testplot		= figure(hf_testplot);
			clf(hf_testplot,'reset');
			set(hf_testplot,'Tag','maplab3d_figure');
			hplot_temp		= [];
		end
		if nargin<=6
			ha_testplot		= axes(hf_testplot);
			hold(ha_testplot,'on');
			axis(ha_testplot,'equal');
			for r_poly0=1:size(poly0,1)
				for c_poly0=1:size(poly0,2)
					plot(ha_testplot,poly0(r_poly0,c_poly0));
				end
			end
			for i_tile=1:size(poly_tile,1)
				plot(ha_testplot,poly_tile(i_tile,1),...
					'LineWidth'    ,2,...
					'LineStyle'    ,'-',...
					'EdgeColor'    ,'c',...
					'FaceAlpha'    ,0);
			end
		end
	end

	for r_poly0=1:size(poly0,1)
		for c_poly0=1:size(poly0,2)
			switch gap_style
				case 0
					% Do not cut into pieces.

				case 1
					% Cut at the tile boundaries:
					poly		= polyshape();
					for i_tile=1:size(poly_tile,1)
						poly_tile_buff	= polybuffer(poly_tile(i_tile),-gap_width/2,'JointType','miter','MiterLimit',2);
						poly_is			= intersect(poly0(r_poly0,c_poly0),poly_tile_buff,'KeepCollinearPoints',false);
						poly				= addboundary(poly,poly_is.Vertices,'KeepCollinearPoints',false);
					end
					poly0(r_poly0,c_poly0)		= poly;

				case 2
					% Automatic linear division lines:

					% Variation of the regions of poly0(r_poly0,c_poly0):
					poly0_reg				= regions(poly0(r_poly0,c_poly0));
					poly0(r_poly0,c_poly0)						= polyshape();
					for i_poly0_reg=1:length(poly0_reg)

						% Size of the current region:
						poly					= poly0_reg(i_poly0_reg);		% for better readability
						if collect_all_data
							[x_poly,y_poly]	= boundary(poly);
						end
						[xlim_bb,ylim_bb]	= boundingbox(poly);
						dxlim_bb				= xlim_bb(2)-xlim_bb(1);
						dylim_bb				= ylim_bb(2)-ylim_bb(1);
						diag_bb				= sqrt(dxlim_bb^2+dylim_bb^2);
						if      ((dxlim_bb>maxdimx)||(dylim_bb>maxdimy)||(diag_bb>maxdiag)            )&&...
								~(((dxlim_bb<mindimx)||(dylim_bb<mindimy)||(diag_bb<mindiag))&&firstcall)

							% The current region is too big: cut it:
							% If it is the first call and the current region is too small:
							% It has not been cutted: Ignore it.

							% Bounding box length of the diagonal diag_bb:
							diag_bb				= sqrt((xlim_bb(2)-xlim_bb(1))^2+(ylim_bb(2)-ylim_bb(1))^2);
							dl_poly_length		= 2.1*diag_bb;

							% Dividing polygon:
							dl_poly_0			= create_dividing_polygon(...
								[-1 1]*dl_poly_length/2,...		% x_v
								[0 0],...								% y_v
								colorspec);

							% Variation of the number of center points:
							n_xyc_v				= [20;40;80];			% number of center points target values !!!!!!!!!!!!!!!!!!!!!
							row_solution		= [];
							i_n_xyc_v			= 0;
							while (i_n_xyc_v<length(n_xyc_v))&&isempty(row_solution)
								i_n_xyc_v		= i_n_xyc_v+1;

								% Calculation of the center points:
								n_xyc					= n_xyc_v(i_n_xyc_v,1);
								convhull_poly		= convhull(poly);
								nbb_xyc				= (dxlim_bb*dylim_bb)/area(convhull_poly)*n_xyc;
								nbbx_xyc				= round(sqrt(nbb_xyc*dxlim_bb/dylim_bb))+2;
								nbby_xyc				= round(nbb_xyc/nbbx_xyc)+2;
								dx_xyc				= dxlim_bb/nbbx_xyc;
								dy_xyc				= dylim_bb/nbby_xyc;
								x_xyc_v				= ((xlim_bb(1)-0.5*dx_xyc):dx_xyc:(xlim_bb(2)+dx_xyc))';
								y_xyc_v				= ((ylim_bb(1)-0.5*dy_xyc):dy_xyc:(ylim_bb(2)+dy_xyc))';
								[x_xyc_m,y_xyc_m]	= meshgrid(x_xyc_v,y_xyc_v);
								n_xyc_m				= size(x_xyc_v,1)*size(y_xyc_v,1);
								xcenter_divli_v	= reshape(x_xyc_m,[n_xyc_m 1]);
								ycenter_divli_v	= reshape(y_xyc_m,[n_xyc_m 1]);
								% TFin					= isinterior(convhull_poly,xcenter_divli_v,ycenter_divli_v);
								TFin					= inpolygon(...		% faster than isinterior
									xcenter_divli_v,...						% query points
									ycenter_divli_v,...
									convhull_poly.Vertices(:,1),...		% polygon area
									convhull_poly.Vertices(:,2));
								xcenter_divli_v	= xcenter_divli_v(TFin);
								ycenter_divli_v	= ycenter_divli_v(TFin);
								n_xyc					= size(xcenter_divli_v,1);			% number of center points

								% Variation of dist_gap_margin:
								% The bigger the better, but if it is too big there is possibly no solution:
								dist_gap_margin_v	= [...
									4*dist_gap_margin;...
									3*dist_gap_margin;...
									2*dist_gap_margin;...
									dist_gap_margin];
								for i_dgm=size(dist_gap_margin_v,1):-1:1
									if i_dgm==size(dist_gap_margin_v,1)
										dgm_pattern_height	= dist_gap_margin_v(i_dgm);
									else
										dgm_pattern_height	= dist_gap_margin_v(i_dgm)-dist_gap_margin_v(i_dgm+1);
									end
									dgm_pattern_stepwidth	= 1.5*dgm_pattern_height;
									dl_line_dgm_0_x	= (...
										-(diag_bb*1.05+2*dgm_pattern_stepwidth):...
										dgm_pattern_stepwidth:...
										(diag_bb*1.05+3*dgm_pattern_stepwidth))';
									imax	= size(dl_line_dgm_0_x,1);
									i_v	= (1:imax)';
									dl_line_dgm_0_y	= ((-1).^i_v)*dgm_pattern_height*0.5+...
										gap_width/2+gap_pattern_width/2+dist_gap_margin_v(i_dgm)-dgm_pattern_height/2;
									dl_poly_dgm_0		= polyshape(...
										[dl_line_dgm_0_x;flip(dl_line_dgm_0_x)],...
										[dl_line_dgm_0_y;-flip(dl_line_dgm_0_y)],'Simplify',false);
									dl_poly_dgm_buff_0(i_dgm,1)		= simplify(dl_poly_dgm_0,'KeepCollinearPoints',false);
								end
								i_dist_gap_margin	= 0;
								while (i_dist_gap_margin<length(dist_gap_margin_v))&&isempty(row_solution)
									i_dist_gap_margin	= i_dist_gap_margin+1;

									% Select the solution: Try these settings before switching to a smaller dist_gap_margin:
									noreg_poly_divided_max	= 1e6;	% noreg_poly_divided_max:	max. number of regions
									Kcv_nrowmin_m				= [...	% Kcv:		minimum ratio area_min/area_max of all regions
										0.7	20;...						% nrowmin:	minimum number of remaining solutions before
										0.6	20;...						%				selecting the solution with the smallest
										0.5	20;...						%				intersection area with the dividing poly
										0.7	5;...
										0.6	5;...
										0.5	5;...
										0.7	1;...
										0.6	1;...
										0.5	1;...
										0.4	20;...
										0.4	5;...
										0.4	1];
									if i_dist_gap_margin>=2
										noreg_poly_divided_max		= 1e6;
										Kcv_nrowmin_m	= [Kcv_nrowmin_m;...
											0.3	20;...
											0.3	5;...
											0.3	1];
									end
									if i_dist_gap_margin>=3
										noreg_poly_divided_max		= 1e6;
										Kcv_nrowmin_m	= [Kcv_nrowmin_m;...
											0.2	20;...
											0.2	5;...
											0.2	1];
									end
									if i_dist_gap_margin>=4
										noreg_poly_divided_max		= 1e6;
									end

									% Variation of the center points:
									i_phi_dl				= 0;
									result_m				= zeros(0,16);
									row					= 0;
									for i_xyc=1:n_xyc
										xcenter_divli		= xcenter_divli_v(i_xyc,1);
										ycenter_divli		= ycenter_divli_v(i_xyc,1);

										% Waitbar:
										if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
											WAITBAR.t1	= clock;
											set(GV_H.text_waitbar,'String',sprintf(...
												'%s: piece %g: %g/%g %g/%g %g/%g',msg,piece_no,...
												i_n_xyc_v,length(n_xyc_v),...
												i_dist_gap_margin,length(dist_gap_margin_v),...
												i_xyc,n_xyc));
											drawnow;
										end

										% Variation of the dividing lines angles of the first part to divide:
										dl_poly_trans		= translate(dl_poly_0,xcenter_divli,ycenter_divli);
										for i_dgm=i_dist_gap_margin:size(dist_gap_margin_v,1)
											dl_poly_dgm_trans(i_dgm,1)			= translate(dl_poly_dgm_buff_0(i_dgm,1),...
												xcenter_divli,ycenter_divli);
										end
										if collect_all_data
											dl_line0_c	= [-1;1]*dist_max*2.5+1i*([0;0]);
										end
										dphi_dl_deg	= 10;								% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
										phi_dl_deg	= 0;
										while phi_dl_deg<360
											i_phi_dl					= i_phi_dl+1;
											if use_rand
												phi_dl_deg			= phi_dl_deg+(0.5+rand)*dphi_dl_deg;
											else
												phi_dl_deg			= phi_dl_deg+           dphi_dl_deg;
											end
											dl_poly					= rotate(dl_poly_trans,phi_dl_deg,[xcenter_divli ycenter_divli]);
											poly_divided			= subtract(poly,dl_poly,'KeepCollinearPoints',false);
											poly_divided_reg		= regions(poly_divided);
											noreg_poly_divided	= size(poly_divided_reg,1);
											if (noreg_poly_divided>1)&&(noreg_poly_divided<=noreg_poly_divided_max)

												if collect_all_data
													% Intersection points with the dividing line:
													dl_line_c	= dl_line0_c*exp(1i*phi_dl_deg*pi/180);
													dl_line_x	= xcenter_divli+real(dl_line_c);
													dl_line_y	= ycenter_divli+imag(dl_line_c);
													[x_ip_v,~]	= polyxpoly(x_poly,y_poly,dl_line_x,dl_line_y);
													no_intersection_points	= size(x_ip_v,1);
												else
													no_intersection_points	= -1;
												end

												% Collect the results:

												% Dimensions:
												dx_v						= zeros(size(poly_divided_reg,1),1);
												dy_v						= zeros(size(poly_divided_reg,1),1);
												diag_v					= zeros(size(poly_divided_reg,1),1);
												dx_min					= 1e10;
												dy_min					= 1e10;
												diag_min					= 1e10;
												for i_reg=1:size(poly_divided_reg,1)
													[xlim,ylim]				= boundingbox(poly_divided_reg(i_reg,1));
													dx_v(i_reg,1)			= xlim(2)-xlim(1);
													dy_v(i_reg,1)			= ylim(2)-ylim(1);
													diag_v(i_reg,1)		= sqrt(dx_v(i_reg,1)^2+dy_v(i_reg,1)^2);
													dx_min					= min(dx_min,dx_v(i_reg,1));
													dy_min					= min(dy_min,dy_v(i_reg,1));
													diag_min					= min(diag_min,diag_v(i_reg,1));
												end
												if    (dx_min  >=mindimx)&&...
														(dy_min  >=mindimy)&&...
														(diag_min>=mindiag)
													% The minimum dimensions are not too small and
													% the number of regions is greater than one

													% Intersection polygon:
													poly_is					= intersect(poly,dl_poly,'KeepCollinearPoints',false);

													% Intersection area with the dividing poly, min-max-dimensions:
													area_is					= area(poly_is);
													area_cv_min				= 1e10;
													area_is_min				= 1e10;
													dx_max					= -1e10;
													dy_max					= -1e10;
													diag_max					= -1e10;
													area_cv_max				= -1e10;
													area_is_max				= -1e10;
													area_cv_v				= zeros(size(poly_divided_reg,1),1);
													for i_reg=1:size(poly_divided_reg,1)
														% Convex hull area:
														% area_cv_v(i_reg,1)	= dx_v(i_reg,1)*dy_v(i_reg,1);					% do not use
														% area_cv_v(i_reg,1)	= area(convhull(poly_divided_reg(i_reg,1)));	% slow
														area_cv_v(i_reg,1)	= area(poly_divided_reg(i_reg,1));				% fast
														% Intersection area with the dividing poly:
														area_is_min				= min(area_is_min,area_is);
														area_is_max				= max(area_is_max,area_is);
														% Min-Max-values:
														area_cv_min				= min(area_cv_min,area_cv_v(i_reg,1));
														dx_max					= max(dx_max,dx_v(i_reg,1));
														dy_max					= max(dy_max,dy_v(i_reg,1));
														diag_max					= max(diag_max,diag_v(i_reg,1));
														area_cv_max				= max(area_cv_max,area_cv_v(i_reg,1));
													end

													% minimum ratio area_min/area_max of all regions:
													K_cv							= min(Kcv_nrowmin_m(:,1));
													area_cv_min_max_ratio	= area_cv_min/area_cv_max;
													if area_cv_min_max_ratio>=K_cv
														% area_cv_min_max_ratio is greater than K_cv in the current
														% step i_dist_gap_margin:

														% Check the distance to the margin:
														% This is the last step because of the high execution time.
														poly_is_buff			= polybuffer(poly_is,tol_1,...
															'JointType','miter','MiterLimit',2);
														dl_poly_outside		= subtract(dl_poly,poly_is_buff,...
															'KeepCollinearPoints',false);
														equal_numboundaries				= true;
														numboundaries_dl_poly_outside	= numboundaries(dl_poly_outside);
														numboundaries_poly_is			= numboundaries(poly_is);
														for i_dgm=i_dist_gap_margin:size(dist_gap_margin_v,1)
															dl_poly_dgm				= rotate(dl_poly_dgm_trans(i_dgm,1),phi_dl_deg,...
																[xcenter_divli ycenter_divli]);
															poly_is_dgm				= intersect(poly,dl_poly_dgm,...
																'KeepCollinearPoints',false);
															poly_is_dgm_buff		= polybuffer(poly_is_dgm,tol_1,...
																'JointType','miter','MiterLimit',2);
															dl_poly_dgm_outside	= subtract(dl_poly_dgm,poly_is_dgm_buff,...
																'KeepCollinearPoints',false);
															if (numboundaries_dl_poly_outside~=numboundaries(dl_poly_dgm_outside))||...
																	(numboundaries_poly_is     ~=numboundaries(poly_is_dgm)        )
																equal_numboundaries		= false;
																break
															end
														end
														if equal_numboundaries
															% Number of boundaries of the wide dividing line (dl_poly_dgm) and narrow
															% dividing line (dl_poly) inside and outside poly is equal.
															% Therefore probably the dividing line has sufficient distance to the
															% margin of the current region.

															for i_reg=1:size(poly_divided_reg,1)
																row						= row+1;
																result_m(row,:)		= [...
																	i_phi_dl ...							%  1)	number i_phi_dl
																	xcenter_divli ...						%  2)	xcenter_divli
																	ycenter_divli ...						%  3)	ycenter_divli
																	phi_dl_deg ...							%  4)	phi_dl_deg
																	no_intersection_points ...			%  5)	number of intersection points
																	size(poly_divided_reg,1) ...		%  6)	noreg: number of regions
																	dx_min ...								%  7)	dx_min
																	dy_min ...								%  8)	dy_min
																	diag_min ...							%  9)	diag_min
																	area_cv_min ...						% 10)	area_cv_min
																	area_is_min ...						% 11)	area_is_min
																	dx_max ...								% 12)	dx_max
																	dy_max ...								% 13)	dy_max
																	diag_max ...							% 14)	diag_max
																	area_cv_max ...						% 15)	area_cv_max
																	area_is_max];							% 16)	area_is_max
																if testplot2~=0
																	if testplot~=0
																		for k=1:length(hplot_temp)
																			delete(hplot_temp(k).h);
																		end
																		hplot_temp	= [];
																	end
																	htemp1	= plot(ha_testplot,poly_divided_reg(i_reg,1));
																	htemp2	= plot(ha_testplot,convhull(poly_divided_reg(i_reg,1)));
																	htemp3	= plot(ha_testplot,poly_is);
																	htemp4	= plot(ha_testplot,xcenter_divli,ycenter_divli,...
																		'xr','MarkerSize',8,'LineWidth',2);
																	htemp5	= plot(ha_testplot,xcenter_divli_v,ycenter_divli_v,'.r');
																	test_showrow(result_m,row);
																	drawnow;
																	setbreakpoint	= 1;
																	delete(htemp1);
																	delete(htemp2);
																	delete(htemp3);
																	delete(htemp4);
																	delete(htemp5);
																end
															end
														end
													end
												end
											end
										end

										% End of variation of the center points:
									end

									% Select the solution:
									if size(result_m,1)>0
										% At least one solution has been found: Select the dividing line from the results:

										% Select between K_cv and nrowmin:
										i_test			= 1;
										K_cv				= Kcv_nrowmin_m(i_test,1);
										nrowmin			= Kcv_nrowmin_m(i_test,2);
										row_delete_v	= true(size(result_m,1),1);
										while (i_test<=size(Kcv_nrowmin_m,1))&&...
												(sum(row_delete_v)>(size(result_m,1)-nrowmin))
											% Example: K_cv=0.5:
											% The area of the smallest piece is half the area of the greatest piece:
											K_cv	= Kcv_nrowmin_m(i_test,1);
											% Select the solution with the smallest difference between min. and max. convex hull:
											area_cv_min_max_ratio		= result_m(:,10)./result_m(:,15);	% area_cv_min/area_cv_max
											% Select among all solutions with a area_cv_min_max_ratio bigger than
											% K_cv*100% of area_cv_min_max_ratio_max:
											row_delete_v	= (area_cv_min_max_ratio<K_cv);
											% Now the pieces have nearly equal size.
											i_test	= i_test+1;
											if i_test<=size(Kcv_nrowmin_m,1)
												nrowmin	= Kcv_nrowmin_m(i_test,2);
											end
										end
										result_m(row_delete_v,:)	= [];

										if size(result_m,1)>0
											% Select the solution with the smallest intersection area with the dividing poly:
											[~,row_solution]	= min(result_m(:,11));		% area_is_min

											% Divide poly:
											xcenter_divli	= result_m(row_solution,2);			% 2)	xcenter_divli
											ycenter_divli	= result_m(row_solution,3);			% 3)	ycenter_divli
											phi_dl_deg		= result_m(row_solution,4);			% 4)	phi_dl_deg
											dl_poly_trans	= translate(dl_poly_0,xcenter_divli,ycenter_divli);
											dl_poly			= rotate(dl_poly_trans,phi_dl_deg,[xcenter_divli ycenter_divli]);
											poly_is			= intersect(poly,dl_poly,'KeepCollinearPoints',false);
											poly_is_buff	= polybuffer(poly_is,tol_1,'JointType','miter','MiterLimit',2);
											poly				= subtract(poly,poly_is_buff,'KeepCollinearPoints',false);
											poly_cut			= union(poly_cut,poly_is_buff,'KeepCollinearPoints',false);

											% Testplot:
											if testplot~=0
												for k=1:length(hplot_temp)
													delete(hplot_temp(k).h);
													drawnow;
												end
												hplot_temp	= [];
												poly_divided_reg		= regions(poly);
												poly_is					= intersect(poly,dl_poly,'KeepCollinearPoints',false);
												for i_dgm=i_dist_gap_margin:size(dist_gap_margin_v,1)
													dl_poly_dgm_trans(i_dgm,1)	= translate(dl_poly_dgm_buff_0(i_dgm,1),...
														xcenter_divli,ycenter_divli);
													dl_poly_dgm			= rotate(dl_poly_dgm_trans(i_dgm,1),phi_dl_deg,...
														[xcenter_divli ycenter_divli]);
													poly_is_dgm			= intersect(poly,dl_poly_dgm,'KeepCollinearPoints',false);
													hplot_temp(end+1).h	= plot(ha_testplot,dl_poly_dgm);
													hplot_temp(end+1).h	= plot(ha_testplot,poly_is_dgm);
												end
												hplot_temp(end+1).h	= plot(ha_testplot,xcenter_divli_v,ycenter_divli_v,'.r');
												hplot_temp(end+1).h	= plot(ha_testplot,dl_poly);
												hplot_temp(end+1).h	= plot(ha_testplot,poly_is);
												hplot_temp(end+1).h	= plot(ha_testplot,poly);
												for i_reg=1:size(poly_divided_reg,1)
													hplot_temp(end+1).h	= plot(ha_testplot,poly_divided_reg(i_reg,1));
												end
												% test_showrow(result_m,row_solution);
												text(ha_testplot,xcenter_divli,ycenter_divli,sprintf('%g',piece_no),...
													'Color','b','FontSize',11,'FontWeight','bold','HorizontalAlignment','center');
												fprintf(1,'Line %3.0f:',piece_no);
												fprintf(1,'   i_test=%3.0f',i_test);
												fprintf(1,'   K_cv=%4.2f',K_cv);
												fprintf(1,'   nrowmin=%3.0f',nrowmin);
												fprintf(1,'   i_dist_gap_margin=%3.0f\n',i_dist_gap_margin);
												pause(0.01);
												setbreakpoint	= 1;
											end

											% Continue to divide the rest:
											piece_no	= piece_no+1;
											[poly,poly_cut,hplot_temp,cdte,piece_no]	= ...
												cut_into_pieces(poly,poly_cut,poly_tile,color_no,msg,...
												hf_testplot,ha_testplot,hplot_temp,cdte,piece_no);

										end

										% End of select the solution:
									end

									% End of variation of dist_gap_margin:
								end

								% End of variation of n_xyc:
							end

							if isempty(row_solution)
								% row_solution is empty: cancel due to error:
								cdte.tf						= true;
								cdte.i_dist_gap_margin	= i_dist_gap_margin;
								cdte.i_xyc					= i_xyc;
								cdte.phi_dl_deg			= phi_dl_deg;
							end

							% End of cutting the current region:
						end

						% Add all boundaries to poly0(r_poly0,c_poly0):
						[x,y]		= boundary(poly);
						poly0(r_poly0,c_poly0)		= addboundary(poly0(r_poly0,c_poly0),x,y,'KeepCollinearPoints',false);

					end
					if cdte.tf&&firstcall
						% Cancel due to error:
						cdte
						hf_error	= figure;
						set(hf_error,'Tag','maplab3d_figure');
						ha_error	= axes(hf_error);
						plot(ha_error,poly0(r_poly0,c_poly0));
						axis(ha_error,'equal');
						xlabel(ha_error,'x / mm');
						ylabel(ha_error,'x / mm');
						errortext	= sprintf([...
							'It was not possible to cut this object\n',...
							'into pieces (color number = %g). Try to:\n',...
							'- Change the minimum sizes\n',...
							'  colorspec(%g,1).mindimx=%gmm,\n',...
							'  colorspec(%g,1).mindimy=%gmm,\n',...
							'  colorspec(%g,1).mindiag=%gmm\n',...
							'- Or decrease dist_gap_margin=%gmm\n',...
							'- Or try to cut this object manually\n',...
							'  so that the maximum dimensions are:\n',...
							'  colorspec(%g,1).maxdimx=%gmm,\n',...
							'  colorspec(%g,1).maxdimy=%gmm,\n',...
							'  colorspec(%g,1).maxdiag=%gmm'],...
							color_no,...
							icolspec,mindimx,...
							icolspec,mindimy,...
							icolspec,mindiag,...
							dist_gap_margin,...
							icolspec,maxdimx,...
							icolspec,maxdimy,...
							icolspec,maxdiag);
						title(ha_error,errortext,'Interpreter','none');
						errormessage(errortext);
					end

				otherwise
					errormessage;
			end
		end
	end

	% Testplot:
	if nargin==0
		% Last step when testing:
		if profile_activ&&~isdeployed
			%#exclude profile
			profile off
			profile report
			beep
		end
		if testplot~=0
			for k=1:length(hplot_temp)
				delete(hplot_temp(k).h);
			end
			drawnow;
			cla(ha_testplot,'reset');
			hold(ha_testplot,'on');
			axis(ha_testplot,'equal');
			for r_poly0=1:size(poly0,1)
				for c_poly0=1:size(poly0,2)
					plot(ha_testplot,poly0(r_poly0,c_poly0));
				end
			end
			plot(ha_testplot,poly_cut,...
				'LineWidth'    ,1,...
				'LineStyle'    ,'--',...
				'EdgeColor'    ,'r',...
				'FaceAlpha'    ,0);
			for i_tile=1:size(poly_tile,1)
				plot(ha_testplot,poly_tile(i_tile,1),...
					'LineWidth'    ,2,...
					'LineStyle'    ,'-',...
					'EdgeColor'    ,'c',...
					'FaceAlpha'    ,0);
			end
			drawnow;
			setbreakpoint	= 1;
		end
		for r_poly0=1:size(poly0,1)
			for c_poly0=1:size(poly0,2)
				poly0_reg				= regions(poly0(r_poly0,c_poly0));
				for i_poly0_reg=1:length(poly0_reg)
					% Size of the regions:
					[xlim_bb,ylim_bb]	= boundingbox(poly0_reg(i_poly0_reg));
					dxlim_bb				= xlim_bb(2)-xlim_bb(1);
					dylim_bb				= ylim_bb(2)-ylim_bb(1);
					diag_bb				= sqrt(dxlim_bb^2+dylim_bb^2);
					if (size(poly0,1)>1)||(size(poly0,2)>1)
						fprintf(1,'poly0(%1.0f,%1.0f):\n',r_poly0,c_poly0);
					end
					fprintf(1,'Region %3.0f:',i_poly0_reg);
					if (dxlim_bb<mindimx)||(dxlim_bb>maxdimx)
						size_is_ok_str	= 'Error !';
					else
						size_is_ok_str	= '';
					end
					fprintf(1,'   dx  =%6.2f (>%6.2f  ,  <%7.2f)  %s\n',...
						dxlim_bb,mindimx,maxdimx,size_is_ok_str);
					if (dylim_bb<mindimy)||(dylim_bb>maxdimy)
						size_is_ok_str	= 'Error !';
					else
						size_is_ok_str	= '';
					end
					fprintf(1,'              dy  =%6.2f (<%6.2f  ,  >%7.2f)  %s\n',...
						dylim_bb,mindimy,maxdimy,size_is_ok_str);
					if (diag_bb<mindiag)||(diag_bb>maxdiag)
						size_is_ok_str	= 'Error !';
					else
						size_is_ok_str	= '';
					end
					fprintf(1,'              diag=%6.2f (<%6.2f  ,  >%7.2f)  %s\n',...
						diag_bb ,mindiag,maxdiag,size_is_ok_str);
				end
			end
		end
	end

catch ME
	errormessage('',ME);
end



function test_showrow(result_m,row)

try

	k=0;
	fprintf(1,'--------------------------------------------------------------------------\n');
	fprintf(1,'Row %g\n',row);
	k=k+1; fprintf(1,'%2.0f) number:                     %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) xcenter_divli:              %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) ycenter_divli:              %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) phi_dl_deg:                 %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) number of intersection points:  %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) number of regions:              %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) dx_min:                     %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) dy_min:                     %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) diag_min:                   %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) area_cv_min:                %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) area_is_min:                %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) dx_max:                         %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) dy_max:                         %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) diag_max:                       %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) area_cv_max:                    %g\n',k,result_m(row,k));
	k=k+1; fprintf(1,'%2.0f) area_is_max:                    %g\n',k,result_m(row,k));

catch ME
	errormessage('',ME);
end

