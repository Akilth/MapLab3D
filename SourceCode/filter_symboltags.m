function [isym_symbol_eqtags,tag_symbol_eqtags,itable_symbol_eqtags,text_tag_symbol_eqtags]	= ...
	filter_symboltags(i_table_plot,manual_select_key,manual_select_val,key_for_display,msg)
% Searches the table OSMDATA_TABLE(i_table_plot,:) for complete tags given in
% PP.obj(iobj).tag_incl or PP.obj(iobj).symbolpar.tag_incl
% The first complete tag:						PP.obj(iobj).tag_incl(r,c).k	= PP.obj(iobj).tag_incl(r,c).v
% with a corresponding existing symbol:	SY(isym).k							= SY(isym).v
% is saved as element i in isym_symbol_eqtags(i,1).
% inputs:
% -	i_table_plot:			Line numbers in the table OSMDATA_TABLE of the objects to be printed
% -	manual_select_key:	manual selection of symbols: key:	PP.obj(iobj,1).symbolpar.manual_select_key
%									manual_select_key='':					deactivated
% -	manual_select_val:	manual selection of symbols: value:	PP.obj(iobj,1).symbolpar.manual_select_val
%									manual_select_val='':					deactivated
% -	key_for_display:		1*K cell array:							PP.obj(iobj,1).symbolpar.key_for_display
% -	msg:						Message, used in the waitbar
% outputs:
% -	isym_symbol_eqtags					N*1 vector:			symbol number isym in SY(isym,1)
%		isym_symbol_eqtags(i,1)=isym								There are N different symbol numbers isym.
% -	tag_symbol_eqtags						N*1 cell array:	tags with corresponding symbol
%
% -	itable_symbol_eqtags					N*1 cell array:	corresponding indices in OSMDATA_TABLE
%		itable_symbol_eqtags{i,1}			vector of indices in OSMDATA_TABLE corresponding to isym_symbol_eqtags
% -	text_tag_symbol_eqtags				N*1 cell array:
% Example:
% -	i_table_plot =
%     [1;2;3;...]
% -	PP.obj(iobj,1).symbolpar.key_for_display = 1×4 cell array
% 	   {'short_name'}    {'name'}    {'name:de'}    {'alt_name'}
% -	msg =
% 	   'Get plot data of ObjNo 57 (DHBW) ... '
% -	isym_symbol_eqtags =
% 	   2
% -	tag_symbol_eqtags = 1×1 cell array
% 	   {'name=DHBW Mannheim: Duale Hochschule Baden-Württemberg'}
% -	itable_symbol_eqtags = 1×1 cell array
% 	   {[10;34]}
% -	text_tag_symbol_eqtags = 1×1 cell array
% 	   {37×2 cell}
% -	text_tag_symbol_eqtags{1,1} = 37×2 cell array
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {'name'      }    {'DHBW Mannheim: Duale Hochschule Baden-Wü…'}
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {'short_name'}    {'DHBW Mannheim'                             }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }
% 	   {0×0 char    }    {0×0 char                                    }

global OSMDATA_TABLE SY WAITBAR GV GV_H

try

	% Testing:
	if nargin==0
		pp_obj_tag_incl			= struct('k','','v','');
		pp_obj_tag_excl			= struct('k','','v','');
		filter_incl_1				= struct('crit','','lolim','','uplim','');
		filter_excl_1				= struct('crit','','lolim','','uplim','');
		filter_incl_2				= struct('crit','','lolim','','uplim','');
		filter_excl_2				= struct('crit','','lolim','','uplim','');
		filter_osmdata(...
			1,...
			pp_obj_tag_incl,...
			pp_obj_tag_excl,...
			filter_incl_1,filter_incl_2,...
			filter_excl_1,filter_excl_2,...
			msg);
		i_table_plot				= (1:height(OSMDATA_TABLE))';
		key_for_display{1,1}		= 'short_name';
		key_for_display{1,2}		= 'name';
		key_for_display{1,3}		= 'name:de';
		key_for_display{1,4}		= 'alt_name';
		msg							= 'Test';
		% Results:
		% isym_symbol_eqtags =
		%      4
		%      9
		% tag_symbol_eqtags =
		%   2×1 cell array
		%     {'natural=peak'}
		%     {'place=town'  }
		% itable_symbol_eqtags =
		%   2×1 cell array
		%     {48×1 double}
		%     {11×1 double}
		% text_tag_symbol_eqtags =
		%   2×1 cell array
		%     {59×2 cell}
		%     {59×2 cell}
		% text_tag_symbol_eqtags{1,1}
		% ans =
		%   59×2 cell array
		%     {'name'  }    {'Königstuhl'       }
		%     {0×0 char}    {0×0 char           }
		%     {0×0 char}    {0×0 char           }
		%     {0×0 char}    {0×0 char           }
		%     {0×0 char}    {0×0 char           }
		%     {0×0 char}    {0×0 char           }
		%     {'name'  }    {'Michaelsberg'     }
		%     {'name'  }    {'Ölberg'           }
		%     {'name'  }    {'Wendenkopf'       } ...
		% text_tag_symbol_eqtags{2,1}
		% ans =
		%   59×2 cell array
		%     {0×0 char    }    {0×0 char              }
		%     {'name'      }    {'Viernheim'           }
		%     {'name'      }    {'Schifferstadt'       }
		%     {'name'      }    {'Brühl'               }
		%     {'name'      }    {'Eppelheim'           }
		%     {'name'      }    {'Weinheim'            }
		%     {0×0 char    }    {0×0 char              }
		%     {0×0 char    }    {0×0 char              }
		%     {0×0 char    }    {0×0 char              } ...
	end

	% Maximum number of tags in OSMDATA_TABLE:
	no_tags_table	= 0;
	for i=1:length(OSMDATA_TABLE.Properties.VariableNames)
		varname	= OSMDATA_TABLE.Properties.VariableNames{i};
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

	% % Manual selection of symbols:
	% if isempty(manual_select_key)||isempty(manual_select_val)
	% 	manual_sym_select	= false;
	% else
	% 	manual_sym_select	= true;
	% end

	% % Test:
	% for i=1:size(itagtable_v,1)
	% 	fprintf(1,'% 4.0f     %s     %s\n',itagtable_v(i,1),varname_key_c{i,1},varname_val_c{i,1});
	% end

	% Search the table OSMDATA_TABLE for symbol tags:
	isym_symbol_eqtags		= zeros(0,1);
	tag_symbol_eqtags			= cell(0,1);
	itable_symbol_eqtags		= cell(0,1);
	text_tag_symbol_eqtags	= cell(0,1);
	for i_i_table_plot=1:length(i_table_plot)
		itable				= i_table_plot(i_i_table_plot);
		symbol_found		= false;
		text_found			= false;
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			set(GV_H.text_waitbar,'String',sprintf('%s Symbols %g/%g',msg,i_i_table_plot,length(i_table_plot)));
			drawnow;
		end
		itt					= 0;
		while (itt<length(itagtable_v))&&~symbol_found
			itt				= itt+1;
			if isempty(manual_select_key)||isempty(manual_select_val)
				% Search every tag in the element itable for a corresponding symbol:
				varname_key_c_itt_itable	= OSMDATA_TABLE.(varname_key_c{itt,1})(itable);
				varname_val_c_itt_itable	= OSMDATA_TABLE.(varname_val_c{itt,1})(itable);
			else
				% Use the same symbol for every element itable:
				varname_key_c_itt_itable	= string(manual_select_key);
				varname_val_c_itt_itable	= string(manual_select_val);
			end
			if ~isequal(varname_key_c_itt_itable,"")
				% Search every symbol for matches of the keys and values:
				isym				= 0;
				while (isym<length(SY))&&~symbol_found
					isym			= isym+1;
					out_key		= regexpi(varname_key_c_itt_itable,...
						regexptranslate('wildcard',SY(isym).k),'match');
					if strcmp(varname_key_c_itt_itable,out_key)
						% Match of the keys:
						out_val	= regexpi(varname_val_c_itt_itable,...
							regexptranslate('wildcard',SY(isym).v),'match');
						if strcmp(varname_val_c_itt_itable,out_val)
							% Match of the values
							i		= find(isym_symbol_eqtags==isym);
							if isempty(i)
								% First element itable with this symbol:
								isym_symbol_eqtags(end+1,1)		= isym;
								tag_symbol_eqtags{end+1,1}			= sprintf('%s=%s',out_key,out_val);
								itable_symbol_eqtags{end+1,1}		= itable;
								text_tag_symbol_eqtags{end+1,1}	= cell(length(i_table_plot),2);
								for k=1:length(i_table_plot)
									text_tag_symbol_eqtags{end,1}{k,1}		= '';
									text_tag_symbol_eqtags{end,1}{k,2}		= '';
								end
								i											= size(text_tag_symbol_eqtags,1);
							else
								% Add itable to existing elements:
								itable_symbol_eqtags{i,1}			= [itable_symbol_eqtags{i,1};itable];
							end
							% Only one symbol at every element itable (otherwise overlapping symbols):
							symbol_found	= true;
							% Search every tag in the element itable for a corresponding text, that will be displayed:
							for k=1:size(key_for_display,2)
								itt2					= 0;
								while (itt2<length(itagtable_v))&&~text_found
									itt2				= itt2+1;
									varname_key_c_itt2_itable	= OSMDATA_TABLE.(varname_key_c{itt2,1})(itable);
									if ~isequal(varname_key_c_itt2_itable,"")
										out_key2			= regexpi(varname_key_c_itt2_itable,...
											regexptranslate('wildcard',key_for_display{1,k}),'match');
										if strcmp(varname_key_c_itt2_itable,out_key2)
											% Match of the keys:
											text_tag_symbol_eqtags{i,1}{itable,1}	= ...
												char(varname_key_c_itt2_itable);
											text_tag_symbol_eqtags{i,1}{itable,2}	= ...
												char(OSMDATA_TABLE.(varname_val_c{itt2,1})(itable));
											text_found	= true;
										end
									else
										break
									end
								end
								if text_found
									break
								end
							end




							% 							text_tag_symbol_eqtags{i,1}{itable,:}	= ...
							% 								get_text_tag(key_for_display,varname_key_c,varname_val_c);
						end
					end
				end
			else
				break
			end
		end
	end

	% % Test : output
	% for i=1:size(isym_symbol_eqtags,1)
	% 	symbol_eqtags_i1=isym_symbol_eqtags(i,1)
	% 	itable_symbol_eqtags_i1=itable_symbol_eqtags{i,1}
	% end

	% Test:
	if nargin==0
		clc
		isym_symbol_eqtags
		tag_symbol_eqtags
		itable_symbol_eqtags
		text_tag_symbol_eqtags
		for i=1:size(text_tag_symbol_eqtags,1)
			for i_i_table_plot=1:length(i_table_plot)
				itable				= i_table_plot(i_i_table_plot);
				fprintf(1,'%4.0f   %4.0f   %s%s   %s%s\n',i,itable,...
					text_tag_symbol_eqtags{i,1}{itable,1},blanks(40-length(text_tag_symbol_eqtags{i,1}{itable,1})),...
					text_tag_symbol_eqtags{i,1}{itable,2},blanks(40-length(text_tag_symbol_eqtags{i,1}{itable,2})));
			end
		end
	end

catch ME
	errormessage('',ME);
end


% function text_tag_symbol_eqtags_i_itable=get_text_tag(key_for_display,varname_key_c,varname_val_c)
% % Search every tag in the element itable for a corresponding text, that will be displayed:
% global OSMDATA_TABLE
% try
% text_tag_symbol_eqtags_i_itable			= cell(1,2);
% text_tag_symbol_eqtags_i_itable{1,1}	= '';
% text_tag_symbol_eqtags_i_itable{1,2}	= '';
% text_found										= false;
% for k=1:size(key_for_display,2)
% 	itt2					= 0;
% 	while (itt2<length(itagtable_v))&&~text_found
% 		itt2				= itt2+1;
% 		varname_key_c_itt2_itable	= OSMDATA_TABLE.(varname_key_c{itt2,1})(itable);
% 		if ~isequal(varname_key_c_itt2_itable,"")
% 			out_key2			= regexpi(varname_key_c_itt2_itable,...
% 				regexptranslate('wildcard',key_for_display{1,k}),'match');
% 			if strcmp(varname_key_c_itt2_itable,out_key2)
% 				% Match of the keys:
% 				text_tag_symbol_eqtags_i_itable{1,1}	= ...
% 					char(varname_key_c_itt2_itable);
% 				text_tag_symbol_eqtags_i_itable{1,2}	= ...
% 					char(OSMDATA_TABLE.(varname_val_c{itt2,1})(itable));
% 				text_found	= true;
% 			end
% 		else
% 			break
% 		end
% 	end
% 	if text_found
% 		break
% 	end
% end
% catch ME
% 	errormessage('',ME);
% end

