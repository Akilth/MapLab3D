function [object_eqtags,itable_object_eqtags]	= filter_objecttags(iobj,i_table_plot,msg)
% Searches the table OSMDATA_TABLE(i_table_plot,:) for the keys given in PP.obj(iobj).filter_by_key.incltagkey.
% -	iobj:							Object number PP.obj(iobj,1)
% -	i_table_plot:				Line numbers in the table OSMDATA_TABLE of the objects to be printed
% -	object_eqtags:				N*1 cell array:	all tags in OSMDATA_TABLE that have equal keys and the same keys
%																given in PP.obj(iobj,1).filter_by_key.incltagkey.
% -	itable_object_eqtags:	N*1 cell array:	corresponding indices in OSMDATA_TABLE
%
% Example:
%     PP.obj(iobj,1).tag_incl( 1,1).k				= waterway'
%     PP.obj(iobj,1).tag_incl( 1,1).v				= 'river'
%     PP.obj(iobj,1).filter_by_key.incltagkey	= {'name'}
% PLOTDATA.obj(iobj,1).obj_eqtags = 21×1 cell array:
%     {'name=Aare'                 }
%     {'name=Rhein'                }
%     {'name=Limmat'               }
%     {'name=Murg'                 }
%     {'name=Rotach'               }
%     {'name=Argen'                }
%     {'name=Reuss'                }
%     {'name=Untere Argen'         }
%     {'name=Birsig'               }
%     {'name=Iller'                }
%     {'name=L'Ill'                }
%     {'name=Hauensteiner Murg'    }
%     {'name=La Doller'            }
%     {'name=Rothach'              }
%     {'name=Bregenzer Ach'        }
%     {'name=Obere Argen'          }
%     {'name=Wiese'                }
%     {'name=Leiblach'             }
%     {'name=Rickenbach'           }
%     {'name=Vieux Rhin / Altrhein'}
%     {'name=Le Steinbaechlein'    }
% itable_obj_eqtags = 21×1 cell array:
%     {13×1 double}
%     {39×1 double}
%     { 4×1 double}
%     {14×1 double}
%     { 9×1 double}
%     { 5×1 double}
%     { 5×1 double}
%     {19×1 double}
%     {11×1 double}
%     {12×1 double}
%     {15×1 double}
%     {14×1 double}
%     { 2×1 double}
%     { 2×1 double}
%     { 6×1 double}
%     {10×1 double}
%     {10×1 double}
%     {[       92]}
%     { 3×1 double}
%     {[      109]}
%     {[      196]}

global PP GV OSMDATA_TABLE WAITBAR GV_H

try
	
	testout	 = 0;
	
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
	
	% Search the table OSMDATA_TABLE for the keys given in PP.obj(iobj,1).filter_by_key.incltagkey:
	object_eqtags			= cell(0,1);
	itable_object_eqtags	= cell(0,1);
	for i1=1:length(i_table_plot)
		% Search for the keys given in PP.obj(iobj,1).filter_by_key.incltagkey and store the corresponding values:
		itable			= i_table_plot(i1);
		r_tags			= 1;
		tag				= '';
		% Waitbar:
		if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
			WAITBAR.t1	= clock;
			set(GV_H.text_waitbar,'String',sprintf('%s Objects: filter by key %g/%g',msg,i1,length(i_table_plot)));
			drawnow;
		end
		for c_tags=1:size(PP.obj(iobj,1).filter_by_key.incltagkey,2)
			if ~isempty(PP.obj(iobj,1).filter_by_key.incltagkey{r_tags,c_tags})
				for itt=1:length(itagtable_v)
					varname_key_c_itt_itable	= OSMDATA_TABLE.(varname_key_c{itt,1})(itable);
					if ~isequal(varname_key_c_itt_itable,"")
						out=regexpi(varname_key_c_itt_itable,...
							regexptranslate('wildcard',PP.obj(iobj,1).filter_by_key.incltagkey(r_tags,c_tags)),'match');
						if isequal({varname_key_c_itt_itable},out)
							tag		= [...
								PP.obj(iobj,1).filter_by_key.incltagkey{r_tags,c_tags} '=' ...
								char(OSMDATA_TABLE.(varname_val_c{itt,1})(itable))             ];
							break
						end
					else
						break
					end
				end
				if ~isempty(tag)
					break
				end
			end
		end
		if ~isempty(tag)
			if isempty(object_eqtags)
				% First element in object_eqtags:
				object_eqtags{1,1}			= tag;
				itable_object_eqtags{1,1}	= itable;
			else
				% There are already elements in object_eqtags:
				new_element	= true;
				for r_text_eqtags=1:size(object_eqtags,1)
					if strcmp(tag,object_eqtags{r_text_eqtags,1})
						% If tag is already included: Append the index itable:
						itable_object_eqtags{r_text_eqtags,1}	= [itable_object_eqtags{r_text_eqtags,1};itable];
						new_element	= false;
						break
					end
				end
				if new_element==true
					% If object_itable is not yet included: Add a new element:
					object_eqtags{end+1,1}			= tag;
					itable_object_eqtags{end+1,1}	= itable;
				end
			end
		end
	end
	
	% Add remaining indices in i_table_plot to the output variables: This has been disabled.
	% It should be possible to create only objects with defined include tags (for example, only objects with a name).
	% If all objects are to be displayed, all keys in PP.obj.tag_incl.k must also be specified in 
	% PP.obj.filter_by_key.incltagkey.
	% % % i_table_plot_rest		= i_table_plot;
	% % % for i1=1:size(itable_object_eqtags,1)
	% % % 	for i2=1:size(itable_object_eqtags{i1,1},1)
	% % % 		i_table_plot_rest(itable_object_eqtags{i1,1}(i2,1)==i_table_plot_rest)	= 0;
	% % % 	end
	% % % end
	% % % i_table_plot_rest					= i_table_plot_rest(i_table_plot_rest~=0);
	% % % if ~isempty(i_table_plot_rest)
	% % % 	object_eqtags{end+1,1}		= '';
	% % % 	itable_object_eqtags{end+1,1}	= i_table_plot_rest;
	% % % end
	
	% Test : output
	if testout~=0
		for i1=1:size(object_eqtags,1)
			fprintf(1,'%6.0f .. %6.0f (%4.0f)   %s\n',...
				itable_object_eqtags{i1,1}(1,1),...
				itable_object_eqtags{i1,1}(end,1),...
				length(itable_object_eqtags{i1,1}),...
				object_eqtags{i1,1});
		end
	end
	
catch ME
	errormessage('',ME);
end

