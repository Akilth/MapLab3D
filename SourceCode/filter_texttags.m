function [text_eqtags,itable_text_eqtags]	= filter_texttags(iobj,i_table_plot,msg)
% Searches the table OSMDATA_TABLE(i_table_plot,:) for the keys given in PP.obj(iobj).textpar.incltagkey
% -	iobj:				Object number PP.obj(iobj,1)
% -	i_table_plot:	Line numbers in the table OSMDATA_TABLE of the objects to be printed
% -	The output variable text_eqtags contains the values of all tags in OSMDATA_TABLE that have equal tags and the
%		same tags given in PP.obj(iobj,1).textpar.incltagkey
%	 	The first key found in the columns of PP.obj(iobj,1).textpar.incltagkey is included as value in text_eqtags,
%		so the keys in the columns are optional with descending order.
%		The keys in the rows of PP.obj(iobj,1).textpar.incltagkey are treated according to
%		PP.obj(iobj,1).textpar.incltagkey_logicop:
%		PP.obj(iobj,1).textpar.incltagkey_logicop='and': all given tags must be included in OSMDATA_TABLE
%                                                      and must be equal
%		PP.obj(iobj,1).textpar.incltagkey_logicop='or' : at least one given tag must be included in OSMDATA_TABLE
%                                                      and must be equal
% 		text_eqtags{i1,1}{i2,1}:	cell array of value strings
%											i1:	combination of equal tags
%											i2:	number of rows = number of text lines
% -	The output variable itable_text_eqtags contains the corresponding indices in OSMDATA_TABLE
%		itable_text_eqtags{i1,1}	cell array: vector of indices in OSMDATA_TABLE corresponding to text_eqtags
%
% Example:
% -	OSMDATA_TABLE:
%		has 38 lines and contains OSM data filtered according to the condition highway=secondary given in iobj=1
% -	iobj         = 1
% -	i_table_plot = (1:38)'
% -	PP.obj(1,1).textpar.incltagkey{1,1}='ref'
%		PP.obj(1,1).textpar.incltagkey{2,1}='name'
% -	PP.obj(1,1).textpar.incltagkey_logicop='or'   ==>
%			text_eqtags{1,1} = 1×1 cell array
%			    {'L 3409'}
%			itable_text_eqtags{1,1}' =
%			     1    12
%			text_eqtags{2,1} = 1×1 cell array
%			    {'L 3120'}
%			itable_text_eqtags{2,1}' =
%			     2     3     4     5    11    15    17    18    19    20    21    22    23    24    26    27    28
%			text_eqtags{3,1} = 2×1 cell array
%			    {'L 3120'             }
%			    {'Mörlenbacher Straße'}
%			itable_text_eqtags{3,1}' =
%			     6     7    10    14    16    25    29    32    33    34
%			text_eqtags{4,1} = 1×1 cell array
%			    {'L 535'}
%			itable_text_eqtags{4,1}' =
%			     8     9    13    30
% -	PP.obj(1,1).textpar.incltagkey_logicop='and'   ==>
%			text_eqtags{1,1} =
%			  2×1 cell array
%			    {'L 3120'             }
%			    {'Mörlenbacher Straße'}
%			itable_text_eqtags{1,1}' =
%			     6     7    10    14    16    25    29    32    33    34

global PP OSMDATA_TABLE WAITBAR GV GV_H

try

	% character style number:
	chstno	= PP.obj(iobj).textpar.charstyle_no;

	% Maximum number of tags in OSMDATA_TABLE:
	no_tags_table	= 0;
	for i1=1:length(OSMDATA_TABLE.Properties.VariableNames)
		varname	= OSMDATA_TABLE.Properties.VariableNames{i1};
		if length(varname)>=3
			if strcmp(varname(1:3),'Key')
				no_tags_table	= no_tags_table+1;
			end
		end
	end

	% Keys and values fields in OSMDATA_TABLE with data:
	itagtable_v		= zeros(0,1);
	varname_key_c	= cell(0,1);
	varname_val_c	= cell(0,1);
	for itagtable=1:no_tags_table
		varname_key			= sprintf('Key%1.0f',itagtable);
		varname_val			= sprintf('Val%1.0f',itagtable);
		for itp=1:length(i_table_plot)
			itable				= i_table_plot(itp);
			if ~isempty(OSMDATA_TABLE.(varname_key)(itable))||~isempty(OSMDATA_TABLE.(varname_val)(itable))
				itagtable_v(end+1,1)		= itable;
				varname_key_c{end+1,1}	= varname_key;
				varname_val_c{end+1,1}	= varname_val;
				break
			end
		end
	end

	% Number of keys in PP.obj(iobj,1).textpar.incltagkey:
	key_exists	= zeros(size(PP.obj(iobj,1).textpar.incltagkey,1),1);
	for r=1:size(PP.obj(iobj,1).textpar.incltagkey,1)
		for c=1:size(PP.obj(iobj,1).textpar.incltagkey,2)
			if ~isempty(PP.obj(iobj,1).textpar.incltagkey{r,c})
				key_exists(r,1)	= 1;
				break
			end
		end
	end
	no_incltagkey_pp	= sum(key_exists);

	% Search the table OSMDATA_TABLE for the keys given in PP.obj(iobj,1).textpar.incltagkey:
	text_eqtags				= cell(0,1);
	itable_text_eqtags	= cell(0,1);
	for i1=1:length(i_table_plot)
		% Search for the keys given in PP.obj(iobj,1).textpar.incltagkey and store the corresponding values:
		itable				= i_table_plot(i1);
		text_itable			= cell(0,1);
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			set(GV_H.text_waitbar,'String',sprintf('%s Texts %g/%g',msg,i1,length(i_table_plot)));
			drawnow;
		end
		for r_tags=1:size(PP.obj(iobj,1).textpar.incltagkey,1)
			text_c	= '';
			for c_tags=1:size(PP.obj(iobj,1).textpar.incltagkey,2)
				if ~isempty(PP.obj(iobj,1).textpar.incltagkey{r_tags,c_tags})
					for itt=1:length(itagtable_v)
						varname_key_c_itt_itable	= OSMDATA_TABLE.(varname_key_c{itt,1})(itable);
						if ~isequal(varname_key_c_itt_itable,"")
							out=regexpi(varname_key_c_itt_itable,...
								regexptranslate('wildcard',PP.obj(iobj,1).textpar.incltagkey(r_tags,c_tags)),'match');
							if isequal({varname_key_c_itt_itable},out)
								text_c		= char(OSMDATA_TABLE.(varname_val_c{itt,1})(itable));
								if strcmp(char(varname_key_c_itt_itable),'ele')&&...
										~isnan(str2double(text_c(end)))
									% Add 'm' to the elevation, if the last character in text_c is a number:
									% E. g.: ele='1345'   : add 'm'
									%        ele='4411 ft': do not add 'm'
									text_c	= [text_c 'm'];
								end
								break
							end
						else
							break
						end
					end
					if ~isempty(text_c)
						break
					end
				end
			end
			if ~isempty(text_c)
				text_itable{end+1,1}	= text_c;
			end
		end
		% Minimum number of keys to identify:
		if strcmp(PP.obj(iobj,1).textpar.incltagkey_logicop,'and')
			no_text_eqtags_min	= no_incltagkey_pp;
		else
			no_text_eqtags_min	= 1;
		end
		% From here: The identified texts are contained in the cell array text_itable according to the project
		% parameters. Each row in text_itable corresponds to a tag.
		if length(text_itable)>=no_text_eqtags_min
			if isempty(text_eqtags)
				% First element in text_eqtags:
				text_eqtags{1,1}			= text_itable;
				itable_text_eqtags{1,1}	= itable;
			else
				% There are already elements in text_eqtags:
				new_element	= true;
				for r_text_eqtags=1:size(text_eqtags,1)
					if isequal(text_itable,text_eqtags{r_text_eqtags,1})
						% If text_itable is already included: Append the index itable:
						itable_text_eqtags{r_text_eqtags,1}	= [itable_text_eqtags{r_text_eqtags,1};itable];
						new_element	= false;
						break
					end
				end
				if new_element==true
					% If text_itable is not yet included: Add a new element:
					text_eqtags{end+1,1}				= text_itable;
					itable_text_eqtags{end+1,1}	= itable;
				end
			end
		end
	end

	% Word-wrapping:
	% Example:	before or wordwrap=0:           	after:	wordwrap=1:                  	wordwrap=2:
	%         	text_eqtags{i1,1} =                     	text_eqtags_i1_neu =         	text_eqtags_i1_neu =
	%         	2×1 cell array	                        	4×1 cell array	               3×1 cell array
	%              {'L 3120'             }                   {'L'           }              {'L 3120'      }
	%              {'Mörlenbacher Straße'}                   {'3120'        }              {'Mörlenbacher'}
	%                                                        {'Mörlenbacher'}              {'Straße'      }
	%                                                        {'Straße'      }
	if PP.obj(iobj,1).textpar.wordwrap~=0
		for i1=1:size(text_eqtags,1)
			max_wordlength	= 0;
			if PP.obj(iobj,1).textpar.wordwrap>0
				max_wordlength	= PP.obj(iobj,1).textpar.wordwrap;
				for i2=1:size(text_eqtags{i1,1},1)
					% Divide the line at blanks and at hyphens:
					k1					= strfind([' ' text_eqtags{i1,1}{i2,1} ' '],' ');
					k2					= strfind(['-' text_eqtags{i1,1}{i2,1} '-'],'-');
					k					= unique([k1 k2]);
					[max_dk,i_dk]	= max(diff(k));
					text_eqtags_i1_i2_b	= [text_eqtags{i1,1}{i2,1} ' '];		% for testing if the last character is a '-'
					if (strcmp(text_eqtags_i1_i2_b(1),'-'))&&(strcmp(text_eqtags_i1_i2_b(k(i_dk+1)-1),'-'))
						% There is a hyphen before and after the word:
						max_wordlength	= max(max_wordlength,max_dk+1);
					elseif strcmp(text_eqtags_i1_i2_b(1),'-')
						% There is a hyphen at the beginning of the text:
						max_wordlength	= max(max_wordlength,max_dk  );
					elseif strcmp(text_eqtags_i1_i2_b(k(i_dk+1)-1),'-')
						% There is a hyphen after the word:
						max_wordlength	= max(max_wordlength,max_dk  );
					else
						% There is no hyphen before or after the word:
						max_wordlength	= max(max_wordlength,max_dk-1);
					end
				end
			end
			text_eqtags_i1				= text_eqtags{i1,1};
			text_eqtags{i1,1}			= cell(0,1);
			i3								= 1;		% line number
			text_eqtags{i1,1}{i3,1}	= '';
			for i2=1:size(text_eqtags_i1,1)
				% Delete double blanks and double hyphens:
				text_onetag			= text_eqtags_i1{i2,1};
				k						= strfind(text_onetag,'  ');
				text_onetag(k)		= '';
				k						= strfind(text_onetag,'--');
				text_onetag(k)		= '';
				% Divide the single line into several lines:
				k1						= strfind([' ' text_onetag ' '],' ');
				k2						= strfind(['-' text_onetag '-'],'-');
				k						= unique([k1 k2]);
				wordlength			= diff(k)-1;
				length_line			= 0;
				for k_word=1:length(wordlength)
					% Keep hyphens between words or at the beginning or end of a line:
					if k_word>1
						d_blank_prev	= d_blank;
					else
						d_blank_prev	= ' ';
					end
					if k_word<length(wordlength)
						delimiter	= text_onetag(k(k_word+1)-1);
					else
						delimiter	= ' ';
					end
					if strcmp(delimiter,'-')
						d_hyphen	= '-';
					else
						d_hyphen	= '';
					end
					if strcmp(delimiter,' ')
						d_blank	= ' ';
					else
						d_blank	= '';
					end
					oneword	= text_onetag(k(k_word):(k(k_word+1)-2));
					if size(text_eqtags{i1,1},1)<i3
						% The line number i3 has been increased in a previous step: write into a new line:
						text_eqtags{i1,1}{i3,1}	= [oneword d_hyphen];
						length_line					= length(oneword)+length(d_hyphen);
					else
						if isempty(text_eqtags{i1,1}{i3,1})
							% The new line text_eqtags{i1,1}{i3,1} is empty: write into a new line:
							text_eqtags{i1,1}{i3,1}	= [oneword d_hyphen];
							length_line					= length(oneword)+length(d_hyphen);
						else
							% The line text_eqtags{i1,1}{i3,1} contains text:
							if (length_line+length(d_blank_prev)+length(oneword)+length(d_hyphen)<=max_wordlength)||...
									strcmp(text_eqtags{i1,1}{i3,1},'-')
								% Add oneword to the current line:
								text_eqtags{i1,1}{i3,1}	= [text_eqtags{i1,1}{i3,1} d_blank_prev oneword d_hyphen];
								length_line					= length_line+length(d_blank_prev)+length(oneword)+length(d_hyphen);
							else
								% Add oneword to a new line:
								if ~isempty(oneword)
									i3								= i3+1;
									text_eqtags{i1,1}{i3,1}	= [oneword d_hyphen];
									length_line					= length(oneword)+length(d_hyphen);
								end
							end
						end
					end
				end
				% Begin a new line at every new tag:
				i3		= i3+1;
			end
		end
	end

	% Character spacing:
	character_spacing	= max(0,round(PP.charstyle(chstno,1).character_spacing));
	if character_spacing>0
		for i1=1:size(text_eqtags,1)
			for i2=1:size(text_eqtags{i1,1},1)
				text	= text_eqtags{i1,1}{i2,1};
				kmax	= length(text);
				if kmax>=2
					k	= 1:kmax;
					k1	= (character_spacing+1)*k-character_spacing;
					text_eqtags{i1,1}{i2,1}			= blanks(k1(end));
					text_eqtags{i1,1}{i2,1}(k1)	= text;
				end
			end
		end
	end

	% Add remaining indices in i_table_plot to the output variables:
	i_table_plot_rest		= i_table_plot;
	for i1=1:size(itable_text_eqtags,1)
		for i2=1:size(itable_text_eqtags{i1,1},1)
			i_table_plot_rest(itable_text_eqtags{i1,1}(i2,1)==i_table_plot_rest)	= 0;
		end
	end
	i_table_plot_rest					= i_table_plot_rest(i_table_plot_rest~=0);
	if ~isempty(i_table_plot_rest)
		text_eqtags{end+1,1}{1,1}		= '';
		itable_text_eqtags{end+1,1}	= i_table_plot_rest;
	end

	% % Test : output
	% for i1=1:size(text_eqtags,1)
	% 	text_eqtags{i1,1}
	% 	itable_text_eqtags{i1,1}'
	% end

catch ME
	errormessage('',ME);
end

