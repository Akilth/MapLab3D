function color_rgb=color_rgb_improve(PP_local,color_rgb)
% Change the RGB values to make shades of very dark or very light colors more visible.

method_color_rgb	= 2;
switch method_color_rgb
	case 1
		if sum(color_rgb)<0.2
			color_rgb					= color_rgb+[1 1 1]*(0.2-sum(color_rgb));
		end
		if sum(color_rgb)>2.75
			color_rgb					= color_rgb*2.75/sum(color_rgb);
		end
		color_rgb(color_rgb<0)	= 0;
		color_rgb(color_rgb>1)	= 1;
	case 2
		color_hsv		= rgb2hsv(color_rgb);
		Hmin				= 0.2;
		Hmax				= 0.92;		% 2.75/3 = 0.916666666666667
		if color_hsv(1,3)<Hmin
			color_hsv(1,3)=Hmin;
		end
		if color_hsv(1,3)>Hmax
			color_hsv(1,3)=Hmax;
		end
		color_rgb		= hsv2rgb(color_hsv);
end
