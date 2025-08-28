function display_charstyle_preview
% Displays sample plots of every character style defined in PP.charstyle.

global PP SETTINGS GV

try

	% Display state:
	t_start_statebusy		= clock;
	display_on_gui_txt	= 'Display char. style preview ...';
	display_on_gui('state',display_on_gui_txt,'busy','add');

	% % TEST
	% pathname='G:\Daten\STA\Themen\Reliefkartendruck\Maplab3d\subfun';
	% SETTINGS.charstyle_sampletext='jÄ"®j:!';save([pathname '\settings.mat'],'SETTINGS');
	% % TEST


	% Take into account, also in the text samples:

	% fontwidening

	% Distance between the fore- and background of plot objects.
	% The outlines must not overlap (less problems in map2stl.m).
	% GV.d_forebackgrd_plotobj	= 0.02;

	if isempty(PP)
		errortext	= sprintf([...
			'The project parameters have not yet been loaded.\n',...
			'First load the project parameters.']);
		errormessage(errortext);
	end

	% Initializations:
	poly_obj	= polyshape();
	poly_bgd	= polyshape();

	% Ask for the sample text:
	prompt		= 'Enter the sample text:';
	definput		= {SETTINGS.charstyle_sampletext};
	dlgtitle		= 'Enter sample text';
	answer		= inputdlg_local(prompt,dlgtitle,1,definput);
	if size(answer,1)~=1
		display_on_gui('state',...
			sprintf('%s canceled (%s).',display_on_gui_txt,dt_string(etime(clock,t_start_statebusy))),...
			'notbusy','replace');
		return
	end
	if ~strcmp(SETTINGS.charstyle_sampletext,answer{1,1})
		SETTINGS.charstyle_sampletext	= answer{1,1};
		[pathname,~,~]	= fileparts(mfilename('fullpath'));
		save([pathname '\settings.mat'],'SETTINGS');
	end

	% Convert to polygons:
	w_max	= 0;
	h_max	= 0;
	for chstno=1:size(PP.charstyle,1)
		% upper and lower case:
		switch PP.charstyle(chstno,1).upperlowercase
			case 'upper'
				sampletext	= upper(SETTINGS.charstyle_sampletext);
			case 'lower'
				sampletext	= lower(SETTINGS.charstyle_sampletext);
			otherwise
				sampletext	= SETTINGS.charstyle_sampletext;
		end
		% Character spacing:
		character_spacing	= max(0,round(PP.charstyle(chstno,1).character_spacing));
		if character_spacing>0
			text_str	= sampletext;
			kmax		= length(text_str);
			if kmax>=2
				k	= 1:kmax;
				k1	= (character_spacing+1)*k-character_spacing;
				sampletext		= blanks(k1(end));
				sampletext(k1)	= text_str;
			end
		end
		% Other settings:
		text_namevalue		= {...
			'FontName'           ;PP.charstyle(chstno,1).fontname;...
			'FontWeight'         ;PP.charstyle(chstno,1).fontweight;...
			'FontAngle'          ;PP.charstyle(chstno,1).fontangle;...
			'HorizontalAlignment';'left';...											% left, center, right
			'VerticalAlignment'  ;'baseline';...									% middle, top, bottom, baseline, cap
			'Interpreter'        ;'none'};
		% Convert to polygons:
		[poly_bgd(chstno,1),...								% poly_bgd
			poly_obj(chstno,1)...								% poly_obj
			]=text2poly(...
			0,...														% x
			0,...														% y
			sampletext,...											% text_str
			PP.charstyle(chstno,1).fontsize/10,...			% fontsize_cm
			0,...														% rotation
			PP.charstyle(chstno,1).print_res,...			% print_res
			PP.charstyle(chstno,1).no_frame,...				% no_frame
			PP.charstyle(chstno,1).par_frame,...			% par_frame
			PP.charstyle(chstno,1).no_bgd,...				% no_bgd
			PP.charstyle(chstno,1).par_bgd,...				% par_bgd
			text_namevalue);										% text_namevalue
		% Font widening:
		if PP.charstyle(chstno,1).fontwidening~=0
			fontwidening			= max(0,PP.charstyle(chstno,1).fontwidening);
			poly_obj(chstno,1)	= polybuffer(poly_obj(chstno,1),fontwidening/2,'JointType','miter');
			poly_bgd(chstno,1)	= union(poly_bgd(chstno,1),poly_obj(chstno,1));
		end
		% The text foreground must be inside the text background (less problems in map2stl.m):
		poly_bgd_buff	= polybuffer(poly_bgd(chstno,1),-GV.d_forebackgrd_plotobj,'JointType','miter','MiterLimit',2);
		poly_obj(chstno,1)	= intersect(poly_obj(chstno,1),poly_bgd_buff,'KeepCollinearPoints',false);
		% Polygon size:
		[xlim,ylim]	= boundingbox(poly_bgd(chstno,1));
		w_max	= max(w_max,xlim(2)-xlim(1));
		h_max	= max(h_max,ylim(2)-ylim(1));
	end
	dy	= h_max*0.1;
	for chstno=1:(size(PP.charstyle,1)-1)
		poly_bgd(chstno,1)	= translate(poly_bgd(chstno,1),0,(size(PP.charstyle,1)-chstno)*(h_max+dy));
		poly_obj(chstno,1)	= translate(poly_obj(chstno,1),0,(size(PP.charstyle,1)-chstno)*(h_max+dy));
	end

	% Plot the sample text:
	hf_testplot			= figure(5492578);
	figure_theme(hf_testplot,'set',[],'light');
	clf(hf_testplot,'reset');
	figure_theme(hf_testplot,'set',[],'light');
	set(hf_testplot,'Tag','maplab3d_figure');
	hf_testplot.Name	= 'Charstyles';
	hf_testplot.NumberTitle	= 'off';
	ha_testplot			= gca;
	hold(ha_testplot,'on');
	axis(ha_testplot,'equal');
	xlabel(ha_testplot,'x / mm');
	ylabel(ha_testplot,'x / mm');
	plot(ha_testplot,poly_bgd,'FaceColor',[0     0.447 0.741])
	plot(ha_testplot,poly_obj,'FaceColor',[0.85  0.325 0.098])
	for chstno=1:size(PP.charstyle,1)
		plot(ha_testplot,poly_bgd(chstno,1).Vertices(:,1),poly_bgd(chstno,1).Vertices(:,2),...
			'LineStyle','none','Marker','.','MarkerSize',4,'MarkerEdgeColor','k');
		plot(ha_testplot,poly_obj(chstno,1).Vertices(:,1),poly_obj(chstno,1).Vertices(:,2),...
			'LineStyle','none','Marker','.','MarkerSize',4,'MarkerEdgeColor','k');
	end
	for chstno=1:size(PP.charstyle,1)
		text(ha_testplot,w_max+dy,(size(PP.charstyle,1)-chstno)*(h_max+dy),...
			sprintf('Character style %g: %s',chstno,PP.charstyle(chstno,1).description));
	end

	% Display state:
	display_on_gui('state',...
		sprintf('%s done (%s).',display_on_gui_txt,dt_string(etime(clock,t_start_statebusy))),...
		'notbusy','replace');

catch ME
	errormessage('',ME);
end

