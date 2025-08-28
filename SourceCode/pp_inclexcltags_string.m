function inclexcl_str=pp_inclexcltags_string
% This function converts the include and exclude tags from the project file into a more understandable expression.
% Examples:
% ----------------------------------------------------------------
% ObjNo=17: highways: living_street, pedestrian, footway
% 1) Include:
%        (    ( 'highway' = 'living_street' )
%          or ( 'highway' = 'pedestrian' )
%          or ( 'highway' = 'footway' ) )
%    and (    ( 'area' = 'yes' ) )
% 2) Exclude:
%        (    ( 'tunnel' = 'yes' )
%          or ( 'bridge' = 'yes' ) )
% ----------------------------------------------------------------
% ObjNo=18: highways: living_street, pedestrian, footway
% 1) Include:
%        (    ( 'highway' = 'living_street' )
%          or ( 'highway' = 'pedestrian' )
%          or ( 'highway' = 'footway' ) )
% 2) Exclude:
%        (    ( 'tunnel' = 'yes' )
%          or ( 'bridge' = 'yes' )
%          or ( 'area' = 'yes' ) )

global PP

try

	inclexcl_str		= '';
	for iobj=1:size(PP.obj,1)
		if ~isempty(PP.obj(iobj).display)
			% This object number exists:
			% Object number and description:
			inclexcl_str	= sprintf('%s\nObjNo=%g: %s',inclexcl_str,iobj,PP.obj(iobj,1).description);
			if (PP.obj(iobj,1).display~=0)||(PP.obj(iobj,1).symbolpar.display~=0)||(PP.obj(iobj,1).textpar.display~=0)
				% Display is on:
				inclexcl_str	= sprintf('%s\n',inclexcl_str);
				liar_incl_str_iobj	= display_tag(PP.obj(iobj,1).tag_incl);
				liar_excl_str_iobj	= display_tag(PP.obj(iobj,1).tag_excl);
				text_incl_str_iobj	= '';
				text_excl_str_iobj	= '';
				symb_incl_str_iobj	= '';
				symb_excl_str_iobj	= '';
				if ~isempty(PP.obj(iobj,1).textpar)
					if isfield(PP.obj(iobj,1).textpar,'tag_incl')
						text_incl_str_iobj	= display_tag(PP.obj(iobj,1).textpar.tag_incl);
					end
					if isfield(PP.obj(iobj,1).textpar,'tag_excl')
						text_excl_str_iobj	= display_tag(PP.obj(iobj,1).textpar.tag_excl);
					end
				end
				if ~isempty(PP.obj(iobj,1).symbolpar)
					if isfield(PP.obj(iobj,1).symbolpar,'tag_incl')
						symb_incl_str_iobj	= display_tag(PP.obj(iobj,1).symbolpar.tag_incl);
					end
					if isfield(PP.obj(iobj,1).symbolpar,'tag_excl')
						symb_excl_str_iobj	= display_tag(PP.obj(iobj,1).symbolpar.tag_excl);
					end
				end
				% Lines, areas:
				if    isempty(text_incl_str_iobj)&&isempty(text_excl_str_iobj)&&...
						isempty(symb_incl_str_iobj)&&isempty(symb_excl_str_iobj)
					% inclexcl_str	= sprintf('%sLines, areas, texts and symbols:\n',inclexcl_str);
				else
					if      isempty(text_incl_str_iobj)&& isempty(text_excl_str_iobj)&&...
							(~isempty(symb_incl_str_iobj)||~isempty(symb_excl_str_iobj))
						inclexcl_str	= sprintf('%sLines, areas and texts:\n',inclexcl_str);
					else
						if  (~isempty(text_incl_str_iobj)||~isempty(text_excl_str_iobj))&&...
								isempty(symb_incl_str_iobj)&& isempty(symb_excl_str_iobj)
							inclexcl_str	= sprintf('%sLines, areas and symbols:\n',inclexcl_str);
						else
							inclexcl_str	= sprintf('%sLines and areas:\n',inclexcl_str);
						end
					end
				end
				if ~isempty(liar_incl_str_iobj)
					inclexcl_str	= sprintf('%s1) Include:\n%s',inclexcl_str,liar_incl_str_iobj);
				end
				if ~isempty(liar_excl_str_iobj)
					inclexcl_str	= sprintf('%s2) Exclude:\n%s',inclexcl_str,liar_excl_str_iobj);
				end
				% Texts:
				if ~isempty(text_incl_str_iobj)||~isempty(text_excl_str_iobj)
					inclexcl_str	= sprintf('%sTexts:\n',inclexcl_str);
					if ~isempty(text_incl_str_iobj)
						inclexcl_str	= sprintf('%s1) Include:\n%s',inclexcl_str,text_incl_str_iobj);
					end
					if ~isempty(text_excl_str_iobj)
						inclexcl_str	= sprintf('%s2) Exclude:\n%s',inclexcl_str,text_excl_str_iobj);
					end
				end
				% Symbols:
				if ~isempty(symb_incl_str_iobj)||~isempty(symb_excl_str_iobj)
					inclexcl_str	= sprintf('%sSymbols:\n',inclexcl_str);
					if ~isempty(symb_incl_str_iobj)
						inclexcl_str	= sprintf('%s1) Include:\n%s',inclexcl_str,symb_incl_str_iobj);
					end
					if ~isempty(symb_excl_str_iobj)
						inclexcl_str	= sprintf('%s2) Exclude:\n%s',inclexcl_str,symb_excl_str_iobj);
					end
				end
			else
				% Display is off:
				inclexcl_str	= sprintf('%s: display is off',inclexcl_str);
				if    (PP.project.scale<PP.obj(iobj,1).minscale)          ||...
						(PP.project.scale>PP.obj(iobj,1).maxscale)          ||...
						(PP.project.scale<PP.obj(iobj,1).textpar.minscale)  ||...
						(PP.project.scale>PP.obj(iobj,1).textpar.maxscale)  ||...
						(PP.project.scale<PP.obj(iobj,1).symbolpar.minscale)||...
						(PP.project.scale>PP.obj(iobj,1).symbolpar.maxscale)
					inclexcl_str	= sprintf('%s, the scale is outside the specified range',inclexcl_str);
				end
				inclexcl_str	= sprintf('%s\n',inclexcl_str);
			end
		end
	end

	% Test:
	% fprintf(1,'%s\n',inclexcl_str);

catch ME
	errormessage('',ME);
end



function str_iobj=display_tag(tag)

try

	str_iobj	= '';
	for r=1:size(tag,1)
		filter_r_str	= '';
		for c=1:size(tag,2)
			if c==1
				or_str	= '   ';
			else
				or_str	= '         or';
			end
			if ~isempty(tag(r,c).k)&&~isempty(tag(r,c).v)
				if c>1
					filter_r_str	= sprintf('%s\n',filter_r_str);
				end
				filter_r_str	= sprintf('%s%s ( ''%s'' = ''%s'' )',filter_r_str,or_str,tag(r,c).k,tag(r,c).v);
			elseif ~isempty(tag(r,c).k)
				if c>1
					filter_r_str	= sprintf('%s\n',filter_r_str);
				end
				filter_r_str	= sprintf('%s%s ( key = ''%s'' )',filter_r_str,or_str,tag(r,c).k);
			elseif ~isempty(tag(r,c).v)
				if c>1
					filter_r_str	= sprintf('%s\n',filter_r_str);
				end
				filter_r_str	= sprintf('%s%s ( val = ''%s'' )',filter_r_str,or_str,tag(r,c).v);
			end
		end
		if ~isempty(filter_r_str)
			if r==1
				filter_r_str	= sprintf('       (%s',filter_r_str);
			else
				filter_r_str	= sprintf('   and (%s',filter_r_str);
			end
			filter_r_str	= sprintf('%s )\n',filter_r_str);
			str_iobj		= sprintf('%s%s',str_iobj,filter_r_str);
		end
	end

catch ME
	errormessage('',ME);
end

