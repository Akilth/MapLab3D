function [...
	objno_v,...							% numerical array:	object number
	colno_v,...							% numerical array:	color number
	dscr_v,...							% string array:		description
	text_v,...							% string array:		text
	disp_v...							% string array:		display as
	]=get_mapobj_information(...
	imapobj_v,...						% vector of indices in MAP_OBJECTS
	imax_objno,...						% maximum length of objno_v
	imax_colno,...						% maximum length of colno_v
	imax_dscr,...						% maximum length of dscr_v
	imax_text,...						% maximum length of text_v
	imax_disp)							% maximum length of disp_v
% Get information about map objects.

global MAP_OBJECTS

try
	
	objno_v		= zeros(0,1);
	colno_v		= zeros(0,1);
	dscr_v		= strings(0,1);
	text_v		= strings(0,1);
	disp_v		= strings(0,1);
	get_objno	= true;
	get_colno	= true;
	get_dscr		= true;
	get_text		= true;
	get_disp		= true;
	for i_imapobj_v=1:length(imapobj_v)
		imapobj		= imapobj_v(i_imapobj_v);
		% Object information: object number:
		if get_objno
			if MAP_OBJECTS(imapobj,1).iobj>0
				objno_v(end+1,1)		= MAP_OBJECTS(imapobj,1).iobj;
			end
			objno_v		= unique(objno_v);
			if size(objno_v,1)>=imax_objno
				get_objno	= false;
			end
		end
		% Object information: color number:
		if get_colno
			if MAP_OBJECTS(imapobj,1).iobj>=0
				if isfield(MAP_OBJECTS(imapobj,1).h(1,1).UserData,'color_no')
					for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
						colno_v(end+1,1)		= MAP_OBJECTS(imapobj,1).h(i,1).UserData.color_no;
					end
				end
			end
			colno_v		= unique(colno_v);
			if size(colno_v,1)>=imax_colno
				get_colno	= false;
			end
		end
		% Object information: description:
		if get_dscr
			if ~isempty(MAP_OBJECTS(imapobj,1).dscr)
				dscr_v(end+1,1)		= string(MAP_OBJECTS(imapobj,1).dscr);
			end
			dscr_v		= unique(dscr_v);
			if size(dscr_v,1)>=imax_dscr
				get_dscr	= false;
			end
		end
		% Object information: Text/Tag:
		if get_text
			text_tag_str		= '';
			for itext=1:size(MAP_OBJECTS(imapobj,1).text,1)
				if itext==1
					text_tag_str	= string(MAP_OBJECTS(imapobj,1).text{itext,1});
				else
					text_tag_str	= strcat(text_tag_str," ",string(MAP_OBJECTS(imapobj,1).text{itext,1}));
				end
			end
			if ~isempty(text_tag_str)
				text_v(end+1,1)		= text_tag_str;
			end
			text_v		= unique(text_v);
			if size(text_v,1)>=imax_text
				get_text	= false;
			end
		end
		% Object information: display as:
		if get_disp
			if ~isempty(MAP_OBJECTS(imapobj,1).disp)
				disp_v(end+1,1)		= string(MAP_OBJECTS(imapobj,1).disp);
			end
			disp_v		= unique(disp_v);
			if size(disp_v,1)>=imax_disp
				get_disp	= false;
			end
		end
	end
	
catch ME
	errormessage('',ME);
end
