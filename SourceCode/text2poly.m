function [poly_bgd,poly_obj]=text2poly(...
	x,y,text_str,fontsize_cm,rotation,print_res,no_frame,par_frame,no_bgd,par_bgd,text_namevalue)
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
		text_str				= '%Äj:!"';
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
		no_bgd				= 5;
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

	% Create figure:
	rand_screen_pixel	= 10;		% Distance of the figure to the edge of the screen
	% Width and height of figure (w_f, h_f) and axis (w_a, h_a) in pixels:
	screensize			= get(0,'ScreenSize');
	% The figure should almost fill the screen at first:
	% Each additional toolbar requires 25 pixels: Provide 2 toolbars:
	w_f		= screensize(3)-2*rand_screen_pixel;
	h_f		= screensize(4)-2*rand_screen_pixel-122-2*25;	% by trying it out: -122-2*25
	hf			= figure('Visible','off');
	figure_theme(hf,'set',[],'light');
	set(hf,'Tag','maplab3d_figure');
	set(hf,'Units','pixels');
	f_pos		= [...
		rand_screen_pixel,...							% left
		40+rand_screen_pixel,...						% bottom: try out: 40
		w_f,...												% width
		h_f];													% height
	set(hf,'Position',f_pos);

	% Create text:
	ha			= axes;
	set(ha,'XLim',[-0.5 0.5]);
	set(ha,'YLim',[-0.5 0.5]);
	set(ha,'Units','normalized');
	set(ha,'Position',[0 0 1 1]);		% [left bottom width height]
	ht			= text(ha,0,0,text_str);
	set(ht,'FontUnits','centimeters');
	set(ht,'FontSize',fontsize_cm);
	set(ht,'Interpreter','none');
	set(ht,'Color','c');
	set(ht,'Clipping','off');
	for i=1:2:length(text_namevalue)
		if ~strcmpi(text_namevalue{i},'rotation')
			set(ht,text_namevalue{i},text_namevalue{i+1});
		end
	end

	% Crop the figure on the text box so that the print command does not take so long:
	set(ht,'Units','pixels');
	text_position	= get(ht,'Position');
	text_extent		= get(ht,'Extent');
	% rand_pixel		= 25;									% some fonts are more large than the text box!
	% set(hf,'Position',[...
	% 	f_pos(1),...										% left
	% 	f_pos(2),...										% bottom
	% 	2*(text_extent(3)+rand_pixel),...			% width
	% 	2*(text_extent(4)+rand_pixel)]);				% height
	set(hf,'Position',[...
		f_pos(1),...					% left
		f_pos(2),...					% bottom
		4*text_extent(3),...			% width
		4*text_extent(4)]);			% height
	set(ht,'Units','data');
	set(ht,'Position',[0 0]);
	set(ht,'Units','normalized');
	obj_extent		= get(ht,'Extent');

	% Further settings for the printout:
	set(hf,'Units','inches');
	hf_position_inches	= get(hf,'Position');
	w_f_inches				= hf_position_inches(3);
	h_f_inches				= hf_position_inches(4);
	set(hf,'PaperPositionMode','auto');
	set(hf,'PaperUnits'       ,'inches');
	set(hf,'PaperSize'        ,[w_f_inches h_f_inches]);
	set(hf,'PaperPosition'    ,[0 0 w_f_inches h_f_inches]);
	set(ha,'Box'              ,'off');
	set(ha,'XTick'            ,[]);
	set(ha,'YTick'            ,[]);
	set(ha,'XColor'           ,'none');
	set(ha,'YColor'           ,'none');
	set(ha,'Clipping'         ,'off');
	set(ha,'Color',[1 1 1]);

	% Create bitmap:
	% RGB:		Color of the pixels:						black	white	red	green	blue	yllw	mag	cyan
	%				red:		obj_image_rgb(x,y,1) =		0		255	255	0		0		255	255	0
	%				green:	obj_image_rgb(x,y,2) =		0		255	0		255	0		255	0		255
	%				blue		obj_image_rgb(x,y,3) =		0		255	0		0		255	0		255	255
	% Binary:													0		1
	% Objekts in the figure hf:	cyan
	% Objekts in obj_image:			0 or black
	% Background in obj_image:		1 or white
	print_res_str	= sprintf('-r%1.0f',print_res);		% e. g. '-r300'
	obj_image_rgb	= print(hf,'-RGBImage',print_res_str);
	obj_image		= imbinarize(obj_image_rgb(:,:,1),graythresh(obj_image_rgb(:,:,1)));
	set(hf,'Units','centimeters');
	hf_position_centimeters	= get(hf,'Position');
	height_image_mm			= hf_position_centimeters(4)*10;

	% Convert the bitmap into a polygon:
	[poly_bgd,poly_obj]=image2poly(...
		obj_image,height_image_mm,rotation,obj_extent,no_frame,par_frame,no_bgd,par_bgd,testplot);

	% Translate polygons to the given position:
	poly_bgd	= translate(poly_bgd,x,y);
	poly_obj	= translate(poly_obj,x,y);

	% Close the figure:
	close(hf);

catch ME
	errormessage('',ME);
end

