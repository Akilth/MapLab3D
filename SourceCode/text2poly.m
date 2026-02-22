function [poly_bgd,poly_obj]=text2poly(...
	x,y,text_str,fontsize_cm,rotation,print_res,no_frame,par_frame,no_bgd,par_bgd,text_namevalue,iobj,iteqt)
% Converts a text string to a polygon. The unit of the values of the polygon is mm.
%
% poly_obj				polygon of all the objects in the image / mm
% poly_bgd				polygon that connects all single regions in poly_obj / mm
% x						data point x where to place the text / mm
% y						data point y where to place the text / mm
% text_str				text string to convert
% fontsize_cm			fontsize / cm
% rotation				text orientation, specified as a scalar value in degrees
% print_res				print resolution / dpi
% no_frame				number of the method to create the frame around the objects (methods see image2poly.m)
% par_frame				cell array of parameters to create the frame around the object
% no_bgd					number of the method to create the background polygon (methods see image2poly.m)
% par_bgd				cell array of parameters to create the background polygon
% text_namevalue		cell array of additional name/value-pairs of text properties
%
% For test purposes the function can be called without arguments.

try
	
	% Initializations, testdata:
	if nargin<1
		testplot				= 1;
		x						= 0;
	else
		testplot				= 0;
	end
	if nargin<2
		y						= 0;
	end
	if nargin<3
		text_str				= '©ÀÝ‡j:®';
		text_str				= 'iÄ"®i:!';
		text_str				= 'Albüberleitung';
		text_str				= 'Albüberleitung Albüberleitung Albübe';		% OK
		text_str				= 'Albüberleitung Albüberleitung Albüberleitung Albüberleitung Albüberleitung';
		text_str				= 'Albüberleitung Albüberleitung Albüberleitung Albüberleitung Albüberleitung Albüberleitung Albüberleitung';
		text_str				= 'Albüberleitung Albüb';		% method=2   size(im)=[394  3272     3]   t=0.316335
		text_str				= 'Albüberleitung Albübe';		% method=1   size(im)=[394  3469     3]   t=0.827142
		text_str				= 'Albüberleitung';				% method=1   size(im)=[394  2269     3]   t=0.822372
		text_str				= '%Äj:!"';							% ohne testplot: method=2   size(im)=[394  956    3]   t=0.185061
		text_str				= '%Äj:!"';							% ohne testplot: method=1   size(im)=[394  957    3]   t=0.346731
		text_str				= 'Albüberlei';				% method=2   size(im)=[394  2269     3]   t=0.258515
		text_str				= 'Albüberleitung Albüberleitung Albüberleitung Albüberleitung Albüberleitung Albüberleitung Albüberleitung';
	end
	if nargin<4
		fontsize_cm			= 1;
	end
	if nargin<5
		rotation				= 0;
	end
	if nargin<6
		print_res			= 300;					% Test: 20 dots/cm = 20 dots/(1/2.54inch) = 20*2.54 dots/inch
	end
	if nargin<7
		no_frame				= 1;
	end
	if nargin<8
		par_frame			= cell(0,0);
	end
	if nargin<9
		no_bgd				= 2;
	end
	if nargin<10
		par_bgd				= cell(0,0);
	end
	if nargin<11
		text_namevalue		= cell(0,0);
		text_namevalue{end+1,1}	= 'FontName';
		text_namevalue{end+1,1}									= 'Arial';	% 'Old English Text MT' 'Arial' 'Harlow Solid Italic'
		text_namevalue{end+1,1}	= 'HorizontalAlignment';				%
		text_namevalue{end+1,1}									= 'left';	% 'left' | 'center' | 'right'
		text_namevalue{end+1,1}	= 'VerticalAlignment';					%
		text_namevalue{end+1,1}									= 'top';		% 'middle' | 'top' | 'bottom' | 'baseline' | 'cap'
		text_namevalue{end+1,1}	= 'Margin';									% Space around text within the text box
		text_namevalue{end+1,1}									= 3;			% >=1, default: 3
	end
	t_pause_test		= 0.02;							% Sometimes the font size is too large, reason unknown: Test
	
	% Create figure:
	% The figure should almost fill the screen at first:
	% Each additional toolbar requires 25 pixels: Provide 2 toolbars:
	if testplot~=0
		hf		= figure('Visible','off');
	else
		hf		= figure('Visible','off');
	end
	figure_theme(hf,'set',[],'light');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Units','pixels');
	% Width and height of figure (w_f_max_pixel, h_f_max_pixel) and axis (w_a, h_a) in pixels:
	screensize			= get(0,'ScreenSize');
	rand_screen_pixel	= 10;		% Distance of the figure to the edge of the screen
	w_f_max_pixel		= screensize(3)-2*rand_screen_pixel;
	h_f_max_pixel		= screensize(4)-2*rand_screen_pixel-122-2*25;	% by trying it out: -122-2*25
	fig_pos_pixel		= [...
		rand_screen_pixel,...							% left
		47+rand_screen_pixel,...						% bottom: try out: 47
		w_f_max_pixel,...									% width
		h_f_max_pixel];									% height
	set(hf,'Position',fig_pos_pixel);
	
	% Create text:
	ha			= axes;
	set(ha,'XLim',[-0.5 0.5]);
	set(ha,'YLim',[-0.5 0.5]);
	set(ha,'Units','normalized');
	set(ha,'Position',[0 0 1 1]);						% [left bottom width height]
	ht			= text(ha,0,0,text_str);
	set(ht,'FontUnits','centimeters');
	set(ht,'Interpreter','none');
	set(ht,'Color','c');
	set(ht,'Clipping','off');
	
	% Set text properties:
	for i=1:2:length(text_namevalue)
		if ~strcmpi(text_namevalue{i},'rotation')
			set(ht,text_namevalue{i},text_namevalue{i+1});
		end
	end
	set(ht,'FontSize',fontsize_cm);
	pause(t_pause_test);									% Sometimes the font size is too large, reason unknown: Test
	
	% Crop the figure on the text box so that the print command does not take so long:
	set(ht,'Units','pixels');
	text_extent_pixel		= get(ht,'Extent');
	
	% % % % Test !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	% % % if nargin>=13
	% % % 	% global T_TEST_WEGEN_ABSTURZ
	% % % 	% if isempty(T_TEST_WEGEN_ABSTURZ)
	% % % 	% 	T_TEST_WEGEN_ABSTURZ	= clock;
	% % % 	% end
	% % % 	% if etime(clock,T_TEST_WEGEN_ABSTURZ)>=5
	% % % 	% 	T_TEST_WEGEN_ABSTURZ	= clock;
	% % % 		[userview,systemview] = memory;
	% % % 		fprintf(1,'text2poly: iobj=%g iteqt=%g text_extent_pixel=[%s] text_str=''%s'' MemUsedMATLAB=%gGB SystemMemory=%gGB\n',...
	% % % 			iobj,iteqt,num2str(round(text_extent_pixel)),text_str,...
	% % % 			userview.MemUsedMATLAB/1e9,systemview.SystemMemory.Available/1e9);
	% % % 		drawnow;
	% % % 	% end
	% % % end
	% % % % Test !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	% Some fonts are more large than the text box: Enlarge the text box:
	% if contains(ht.FontName,'Arial')
	K_enlarge_textbox			= 2;			% 1.5   -->   no gain in time
	% else
	% 	K_enlarge_textbox			= 2;
	% end
	K_scale_reduce				= max([1;...
		2*K_enlarge_textbox*text_extent_pixel(3)/w_f_max_pixel;...
		2*K_enlarge_textbox*text_extent_pixel(4)/h_f_max_pixel]);
	set(hf,'Position',[...
		fig_pos_pixel(1),...										% left
		fig_pos_pixel(2),...										% bottom
		2*K_enlarge_textbox*text_extent_pixel(3)/K_scale_reduce,...			% width
		2*K_enlarge_textbox*text_extent_pixel(4)/K_scale_reduce]);			% height
	ht.FontSize					= ht.FontSize/K_scale_reduce;
	set(ht,'Units','data');
	set(ht,'Position',[0 0]);
	set(ht,'Units','normalized');
	pause(t_pause_test);											% Sometimes the font size is too large, reason unknown: Test
	text_extent_normalized	= get(ht,'Extent');
	
	% Further settings for the printout:
	hf_position_pixel			= get(hf,'Position');
	w_fig_pixel					= hf_position_pixel(3);
	h_fig_pixel					= hf_position_pixel(4);
	set(hf,'Units','inches');
	hf_position_inches		= get(hf,'Position');
	w_fig_inches				= hf_position_inches(3);
	h_fig_inches				= hf_position_inches(4);
	set(hf,'PaperPositionMode','auto');
	set(hf,'PaperUnits'       ,'inches');
	set(hf,'PaperSize'        ,[w_fig_inches h_fig_inches]);
	set(hf,'PaperPosition'    ,[0 0 w_fig_inches h_fig_inches]);
	set(ha,'Box'              ,'off');
	set(ha,'XTick'            ,[]);
	set(ha,'YTick'            ,[]);
	set(ha,'XColor'           ,'none');
	set(ha,'YColor'           ,'none');
	set(ha,'Clipping'         ,'on');
	set(ha,'Color',[1 1 1]);
	
	% Create bitmap:
	% RGB:		Color of the pixels:						black	white	red	green	blue	yllw	mag	cyan
	%				red:		obj_image_rgb(x,y,1) =		0		255	255	0		0		255	255	0
	%				green:	obj_image_rgb(x,y,2) =		0		255	0		255	0		255	0		255
	%				blue		obj_image_rgb(x,y,3) =		0		255	0		0		255	0		255	255
	% Binary:													0		1
	% Objects in the figure hf:	cyan
	% Objects in obj_image:			0 or black
	% Background in obj_image:		1 or white
	% print_res			= round(print_res*K_scale_reduce);		% Error at long texts
	print_res_str		= sprintf('-r%1.0f',print_res);			% e. g. '-r300'
	% method_print=1: 0.4s .. 0.6s
	% method_print=2: 0.2s				Text kann abgeschnitten werden, sobald das Figure größer als der Bildschirm ist!
	K_scale_method2	= print_res/(w_fig_pixel/w_fig_inches);
	no_attempts			= 1;
	no_attempts_max	= 3;
	set_method_print	= 1;			%	0:	Use at first method 2, then method 1 if there are errors
	%												With method 2, the text may be larger and truncated!
	%											1:	Use only method 1
	while no_attempts<=no_attempts_max
		if    (w_fig_pixel*K_scale_method2<=w_f_max_pixel)&&...
				(h_fig_pixel*K_scale_method2<=h_f_max_pixel)
			method_print	= 2;		% Resulted in termination, possibly because the image was empty?
		else
			method_print	= 1;
		end
		if set_method_print~=0
			method_print	= set_method_print;
		end
		if testplot~=0
			% w_fig_pixel*K_scale_method2
			% w_f_max_pixel
			% method_print	= 1;
			% 1: 0.4s .. 0.6s
			% 2: 0.2s				Text kann abgeschnitten werden, sobald das Figure größer als der Bildschirm ist!
			tic
		end
		if method_print==2
			hf_Position_0	= hf.Position;
			ht_FontSize_0	= ht.FontSize;
			hf.Position		= [...
				hf_position_inches(1) ...
				hf_position_inches(2) ...
				w_fig_inches*K_scale_method2 ...
				h_fig_inches*K_scale_method2];
			ht.FontSize		= ht.FontSize*K_scale_method2;
			try
				% pause(t_pause_test);								% Sometimes the font size is too large, reason unknown: Test
				drawnow;
				F					= getframe(ha);
				obj_image_rgb	= F.cdata;
			catch ME
				fprintf(1,'Warning: getframe failed, trying print: %s\n', ME.message);
				method_print	= 1;
			end
			hf.Position		= hf_Position_0;
			ht.FontSize		= ht_FontSize_0;
		end
		if method_print==1
			try
				% pause(t_pause_test);								% Sometimes the font size is too large, reason unknown: Test
				drawnow;
				obj_image_rgb	= print(hf,'-RGBImage',print_res_str);
			catch ME
				fprintf(1,'!!!\nWarning: print failed, trying again: %s\n!!!\n', ME.message);
				no_attempts		= no_attempts+1;
			end
		end
		if testplot~=0
			fprintf(1,'method=%g   size(im)=[%s]   t=%g\n',method_print,num2str(size(obj_image_rgb)),toc);
			% figure,imshow(obj_image_rgb)
		end
		obj_image			= imbinarize(obj_image_rgb(:,:,1),graythresh(obj_image_rgb(:,:,1)));
		obj_image_left		= obj_image(:,1);
		obj_image_right	= obj_image(:,end);
		obj_image_bottom	= obj_image(end,:);
		obj_image_top		= obj_image(1,:);
		if   ~any(~obj_image,'all') ||...
				any(~obj_image_left)  ||...
				any(~obj_image_right) ||...
				any(~obj_image_bottom)||...
				any(~obj_image_top)
			% The image is completely empty or the margin is not empty: warning and try again:
			if no_attempts<no_attempts_max
				% Try again:
				fprintf(1,'!!!\nWarning: method_print=%g %g/%g: The image is empty: try again\n!!!\n',...
					method_print,no_attempts,no_attempts_max);
				no_attempts		= no_attempts+1;
			else
				% no_attempts=no_attempts_max:
				if method_print==2
					% Try again using method_print=1:
					fprintf(1,'!!!\nWarning: method_print=%g %g/%g: The image is empty: try again\n!!!\n',...
						method_print,no_attempts,no_attempts_max);
					no_attempts			= 1;
					set_method_print	= 1;
				else
					errormessage;
				end
			end
		else
			% Continue:
			no_attempts		= no_attempts_max+1;
		end
	end
	
	% Convert the bitmap into a polygon:
	set(hf,'Units','centimeters');
	hf_position_centimeters	= get(hf,'Position');
	height_image_mm			= hf_position_centimeters(4)*10*K_scale_reduce;
	switch method_print
		case 1
			% nop
		case 2
			height_image_mm	= height_image_mm/K_scale_method2;
	end
	[poly_bgd,poly_obj]=image2poly(...
		obj_image,height_image_mm,rotation,text_extent_normalized,no_frame,par_frame,no_bgd,par_bgd,testplot);
	
	% Translate polygons to the given position:
	poly_bgd	= translate(poly_bgd,x,y);
	poly_obj	= translate(poly_obj,x,y);
	
	% Close the figure:
	close(hf);
	
catch ME
	errormessage('',ME);
end

