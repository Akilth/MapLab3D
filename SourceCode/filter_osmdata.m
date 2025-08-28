function filter_osmdata(...
	update_osmdata_table,...
	obj_tag_incl,...
	obj_tag_excl,...
	filter_incl_1,filter_incl_2,...
	filter_excl_1,filter_excl_2,...
	msg,...										% event display message
	filter_n,...								% filter nodes
	filter_w,...								% filter ways
	filter_r)									% filter relations
% The function filter_osmdata creates:
% 1)	The table OSMDATA_TABLE with the following fields:
%		No				consecutive number
%		ID				ID of the OSM-Object
%		Type			node, way or relation
%		ObjNo			object number (row-index in PP.obj) when OSM-data is displayed, otherwise =0
%		NoN			number of nodes
%		NoW			number of ways
%		NoR			number of relations
%		Dimx			width in x-direction
%		Dimy			depth in y-direction
%		Diag			length of the diagonal of the bounding box
%		Length		total length
%		Area			total area of all closed polygons
%		Key1			variable number of tags and values
%		Val1
%		Key2
%		Val2			...
% 2)	The corresponding indices of the node, way or relation in the OSMDATA structure:
%		OSMDATA_TABLE_INWR
%
% All elements in OSMDATA_TABLE meet the criteria given by:
% -	the include and exclude tags
% -	the include and exclude additional filters
%		The first additional include and exclude filter (filter_incl_1, filter_excl_1) were inteded originally as
%		"general filter", to be applied on all objects of the OSM-data. However, that makes no sense, as e g. lines
%		have to be connected before plotting to be able to calculate the total size.
% -	The tags and filters are two-dimensional structs:
%		The criteria of all columns of ONE row are combined by a logical OR.
%		The criteria of all rows               are combined by a logical AND.
%		E.g.: If crit(r,c) means the result of the logical operation defined in the include/exclude tags or filters:
%		The respective result is calculated by: (crit(1,1) or crit(1,2)) and ((crit(2,1) or crit(2,2))
%
% Variables:
% Update the table:
%		update_osmdata_table	 (0/1)
% Include tags:
%	 	obj_tag_incl(r_tag,c_tag).k
% 		obj_tag_incl(r_tag,c_tag).v
% Exclude tags:
% 		obj_tag_excl(r_tag,c_tag).k
% 		obj_tag_excl(r_tag,c_tag).v
% Include filters (1 or 2):
% 		filter_incl(r_filt,c_filt).crit
% 		filter_incl(r_filt,c_filt).lolim
% 		filter_incl(r_filt,c_filt).uplim
% Exclude filters(1 or 2):
% 		filter_excl(r_filt,c_filt).crit
% 		filter_excl(r_filt,c_filt).lolim
% 		filter_excl(r_filt,c_filt).uplim
% Syntax e.g.:
% 1)	filter_osmdata(...
%			0,...
% 			PP.obj(iobj,1).tag_incl,...
% 			PP.obj(iobj,1).tag_excl,...
% 			PP.general.filter_incl,PP.obj(iobj,1).filter_incl,...
% 			PP.general.filter_excl,PP.obj(iobj,1).filter_excl);
% 2)	obj_tag_incl			= [];
% 		obj_tag_incl(1,1).k	= 'highway';
% 		obj_tag_incl(1,1).v	= 'secondary';
% 		obj_tag_excl			= [];
% 		filter_incl_1			= [];
% 		filter_incl_2			= [];
% 		filter_excl_1			= [];
% 		filter_excl_2			= [];
% 		filter_osmdata(...
%			1,...
% 			obj_tag_incl,...
% 			obj_tag_excl,...
% 			filter_incl_1,filter_incl_2,...
% 			filter_excl_1,filter_excl_2);
% 3)	Call with only the first argument "update_osmdata_table" clears the Table OSMDATA_TABLE:
%		filter_osmdata(0);
%		filter_osmdata(1);

global APP OSMDATA GV GV_H I_OSMDATA_TABLE_TEMPPREV WAITBAR OSMDATA_TABLE OSMDATA_TABLE_INWR

try
	
	testout	= 0;
	
	if nargin<8
		msg	= '';
	end
	if nargin<9
		filter_n	= true;
	end
	if nargin<10
		filter_w	= true;
	end
	if nargin<11
		filter_r	= true;
	end
	
	% Tests:
	if nargin==0
		clc
		msg									= 'Test';
		update_osmdata_table				= 1;
		% 	for ik=1:length(OSMDATA.keys)
		% 		fprintf(1,'ik=%5.0f  |  N=%5.0f  |  N_in=%5.0f  |  N_iw=%5.0f  |  N_ir=%5.0f  |  key= %s\n',...
		% 			ik,OSMDATA.keys(ik,1).N,...
		% 			length(OSMDATA.keys(ik,1).in),length(OSMDATA.keys(ik,1).iw),length(OSMDATA.keys(ik,1).ir),OSMDATA.keys(ik,1).k);
		% 	end
		for r=1:3
			for c=1:3
				obj_tag_incl(r,c).k		= '';		% ref highway *speed* *way landuse
				obj_tag_incl(r,c).op		= '==';	% secondary residential track path footway service 100 L*
				obj_tag_incl(r,c).v		= '';		%
				obj_tag_excl(r,c).k		= '';		% cycle*
				obj_tag_excl(r,c).op		= '==';	%
				obj_tag_excl(r,c).v		= '';		%
				filter_incl_1(r,c).crit	= '';		%
				filter_incl_1(r,c).lolim	= '';		%
				filter_incl_1(r,c).uplim	= '';		%
				filter_excl_1(r,c).crit	= '';		%
				filter_excl_1(r,c).lolim	= '';		%
				filter_excl_1(r,c).uplim	= '';		%
			end
		end
		filter_incl_2				= filter_incl_1;
		filter_excl_2				= filter_excl_1;
		test=12;
		switch test
			case 1
				obj_tag_incl(1,1).k	= 'name';		% highway railway
				obj_tag_incl(1,1).v	= 'weschnitz';		% secondary
			case 2
				obj_tag_incl(1,1).k	= 'railway';		% highway railway
				obj_tag_incl(1,1).v	= '';					% secondary
				obj_tag_excl(1,1).k	= 'tunnel';			%
				obj_tag_excl(1,1).v	= 'yes';				%
			case 3
				obj_tag_incl(1,1).k	= 'landuse';		%
				obj_tag_incl(1,1).v	= 'residential';	%
				obj_tag_incl(1,2).k	= 'highway';		%
				obj_tag_incl(1,2).v	= 'pedestrian';	%
				obj_tag_incl(1,3).k	= '';		% building
				obj_tag_incl(1,3).v	= '';				% yes
				% 			obj_tag_incl(2,1).k	= 'name';		% building
				% 			obj_tag_incl(2,1).v	= '';					%
				% 			obj_tag_excl(1,1).k	= '';		%
				% 			obj_tag_excl(1,1).v	= 'garage';	% garage
				% 			obj_tag_excl(2,1).k	= '';		%
				% 			obj_tag_excl(2,1).v	= 'shed';	% garage
				
				% 			filter_incl_1(1,1).crit	= 'ID';
				% 			filter_incl_1(1,1).lolim	= '181560121';
				% 			filter_incl_1(1,1).uplim	= '181560121';
				% 			filter_incl_1(1,2).crit	= 'ID';
				% 			filter_incl_1(1,2).lolim	= '788943828';
				% 			filter_incl_1(1,2).uplim	= '788943828';
				% 			filter_incl_1(2,1).crit	= 'Area';
				% 			filter_incl_1(2,1).lolim	= '400';
				% 			filter_incl_1(2,1).uplim	= '4000';
				
				% 			filter_excl_1(1,1).crit	= 'ID';
				% 			filter_excl_1(1,1).lolim	= '181560121';
				% 			filter_excl_1(1,1).uplim	= '181560121';
				% 			filter_excl_1(1,2).crit	= 'ID';
				% 			filter_excl_1(1,2).lolim	= '788943829';
				% 			filter_excl_1(1,2).uplim	= '788943829';
				% 			filter_excl_1(2,1).crit	= 'Area';
				% 			filter_excl_1(2,1).lolim	= '500';
				% 			filter_excl_1(2,1).uplim	= '4000';
			case 4
				obj_tag_incl(1,1).k	= 'landuse';		%
				obj_tag_incl(1,1).v	= '';	%
				obj_tag_incl(1,2).k	= '';		%
				obj_tag_incl(1,2).v	= '';					%
				obj_tag_excl(1,1).k	= 'landuse';		%
				obj_tag_excl(1,1).v	= 'forest';	%
				obj_tag_excl(1,2).k	= 'landuse';		%
				obj_tag_excl(1,2).v	= 'meadow';	%
			case 5
				% Stadt-/Ortsnamen: z. B. name=Kreidach
				obj_tag_incl(1,1).k	= 'ele';				% place ele
				obj_tag_incl(1,1).v	= '';					% village *kreidach* *Feuerwehr*
				obj_tag_incl(2,1).k	= '';					%
				obj_tag_incl(2,1).v	= '';					%
				obj_tag_excl(1,1).k	= '';					%
				obj_tag_excl(1,1).v	= '';					%
			case 6
				% Stadt-/Ortsnamen: z. B. name=Kreidach
				obj_tag_incl(1,1).k	= 'place';				% place ele
				obj_tag_incl(1,1).v	= '';					% village *kreidach* *Feuerwehr*
				obj_tag_incl(2,1).k	= '';					%
				obj_tag_incl(2,1).v	= '';					%
				obj_tag_excl(1,1).k	= '';					%
				obj_tag_excl(1,1).v	= '';					%
			case 10
				obj_tag_incl(1,1).k	= 'landuse';		%
				obj_tag_incl(1,1).v	= '';	%
				filter_incl_1(1,1).crit	= 'ID';
				filter_incl_1(1,1).lolim	= '0';
				filter_incl_1(1,1).uplim	= '3000000';
				filter_incl_1(1,2).crit	= 'ID';
				filter_incl_1(1,2).lolim	= '70000000';
				filter_incl_1(1,2).uplim	= '90000000';
				filter_incl_1(2,1).crit	= 'Area';
				filter_incl_1(2,1).lolim	= '0';
				filter_incl_1(2,1).uplim	= '30';
				filter_incl_1(2,2).crit	= 'Length';
				filter_incl_1(2,2).lolim	= '0';
				filter_incl_1(2,2).uplim	= '40';
			case 11
				obj_tag_incl(1,1).k	= 'landuse';		%
				obj_tag_incl(1,1).v	= '';	%
				filter_excl_1(1,1).crit	= 'ID';
				filter_excl_1(1,1).lolim	= '0';
				filter_excl_1(1,1).uplim	= '100000000';
				filter_excl_1(1,2).crit	= 'ID';
				filter_excl_1(1,2).lolim	= '200000000';
				filter_excl_1(1,2).uplim	= '800000000';
			case 12
				obj_tag_incl(1,1).k	= 'natural';
				obj_tag_incl(1,1).op	= '==';
				obj_tag_incl(1,1).v	= 'peak';
				obj_tag_incl(2,1).k	= 'ele';
				obj_tag_incl(2,1).op	= '>=';
				obj_tag_incl(2,1).v	= '375';
				obj_tag_excl(1,1).k	= 'natural';
				obj_tag_excl(1,1).op	= '==';
				obj_tag_excl(1,1).v	= 'peak';
				obj_tag_excl(2,1).k	= 'ele';
				obj_tag_excl(2,1).op	= '>=';
				obj_tag_excl(2,1).v	= '450';
		end
		
	end
	
	if (nargin==1)||~isfield(obj_tag_incl,'k')||~isfield(obj_tag_incl,'v')
		obj_tag_incl			= [];
		obj_tag_excl			= [];
		filter_incl_1			= [];
		filter_incl_2			= [];
		filter_excl_1			= [];
		filter_excl_2			= [];
	end
	
	% Delete the temporary preview from the map:
	plot_osmdata_preview([],'temp');
	I_OSMDATA_TABLE_TEMPPREV	= [];
	
	% Combine filter 1 and 2:
	if isempty(filter_incl_1)
		if isempty(filter_incl_2)
			filter_incl	= [];
		else
			filter_incl	= filter_incl_2;
		end
	else
		if isempty(filter_incl_2)
			filter_incl	= filter_incl_1;
		else
			c_max	= max(size(filter_incl_1,2),size(filter_incl_2,2));
			for r=1:size(filter_incl_1,1)
				for c=1:c_max
					if c<=size(filter_incl_1,2)
						filter_incl(r,c)			= filter_incl_1(r,c);
					else
						filter_incl(r,c).crit	= '';
						filter_incl(r,c).lolim	= '';
						filter_incl(r,c).uplim	= '';
					end
				end
			end
			for r=1:size(filter_incl_2,1)
				r2	= r+size(filter_incl_1,1);
				for c=1:c_max
					if c<=size(filter_incl_2,2)
						filter_incl(r2,c)			= filter_incl_2(r,c);
					else
						filter_incl(r2,c).crit	= '';
						filter_incl(r2,c).lolim	= '';
						filter_incl(r2,c).uplim	= '';
					end
				end
			end
		end
	end
	if isempty(filter_excl_1)
		if isempty(filter_excl_2)
			filter_excl	= [];
		else
			filter_excl	= filter_excl_2;
		end
	else
		if isempty(filter_excl_2)
			filter_excl	= filter_excl_1;
		else
			c_max	= max(size(filter_excl_1,2),size(filter_excl_2,2));
			for r=1:size(filter_excl_1,1)
				for c=1:c_max
					if c<=size(filter_excl_1,2)
						filter_excl(r,c)			= filter_excl_1(r,c);
					else
						filter_excl(r,c).crit	= '';
						filter_excl(r,c).lolim	= '';
						filter_excl(r,c).uplim	= '';
					end
				end
			end
			for r=1:size(filter_excl_2,1)
				r2	= r+size(filter_excl_1,1);
				for c=1:c_max
					if c<=size(filter_excl_2,2)
						filter_excl(r2,c)			= filter_excl_2(r,c);
					else
						filter_excl(r2,c).crit	= '';
						filter_excl(r2,c).lolim	= '';
						filter_excl(r2,c).uplim	= '';
					end
				end
			end
		end
	end
	
	% Check whether obj_tag_incl is empty:
	isempty_objtagincl	= true;
	for r=1:size(obj_tag_incl,1)
		for c=1:size(obj_tag_incl,2)
			if ~isempty(obj_tag_incl(r,c).k)||~isempty(obj_tag_incl(r,c).v)
				isempty_objtagincl	= false;
				break
			end
		end
		if ~isempty_objtagincl
			break
		end
	end
	% At the moment in this function OSMDATA_TABLE is calculated first and then the additional filters are applied.
	% If obj_tag_incl is empty, all map objects would be contained in OSMDATA_TABLE, including all nodes without tags.
	% obj_tag_incl must therefore not be empty so that OSMDATA_TABLE and the execution time are not too long.
	% If a certain object without a tag is searched for, it should be done in a different way.
	if isempty_objtagincl&&(nargin~=1)
		errortext	= sprintf([...
			'Error:\n',...
			'%s\n',...
			'Filtering of the OpenStreetMap data without any\n',...
			'include key or include value is not possible.\n',...
			'You have to define at least one include key or\n',...
			'one include value.'],msg);
		errormessage(errortext);
	end
	
	% Example: use of the functions regexpi and regexptranslate:
	% MAP_keys_k='maxspeed:backward';
	% out=regexpi(MAP_keys_k,regexptranslate('wildcard','*speed*'),'match')
	% isequal({MAP_keys_k},out)
	
	% Inclusion of	objects:
	in_logical		= false(max(1,size(obj_tag_incl,1)),size(OSMDATA.node,2));
	iw_logical		= false(max(1,size(obj_tag_incl,1)),size(OSMDATA.way,2));
	ir_logical		= false(max(1,size(obj_tag_incl,1)),size(OSMDATA.relation,2));
	for r_tags=1:size(obj_tag_incl,1)
		rowcontainsfilter	= false;
		for c_tags=1:size(obj_tag_incl,2)
			if ~isempty(obj_tag_incl(r_tags,c_tags).k)||~isempty(obj_tag_incl(r_tags,c_tags).v)
				% In the current row of obj_tag_incl there are filters applied:
				rowcontainsfilter	= true;
			end
			if ~isempty(obj_tag_incl(r_tags,c_tags).k) && ~isempty(obj_tag_incl(r_tags,c_tags).v)
				% If key and value are both specified:
				% Inclusion of all objects in whose tags the condition key=value is fulfilled in the same tag:
				for ik=1:size(OSMDATA.keys,1)
					% Waitbar:
					if ~isempty(msg)
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',sprintf('%s Filter OSM-data: tag_incl %g/%g',...
								msg,ik,size(OSMDATA.keys,1)));
							drawnow;
						end
					end
					out=regexpi(OSMDATA.keys(ik,1).k,...
						regexptranslate('wildcard',obj_tag_incl(r_tags,c_tags).k),'match');
					if testout~=0
						if isempty(out)
							out_str	= '{}';
						else
							out_str	= out{1,1};
						end
						MAP_keys_ik_k	= sprintf('OSMDATA.keys(%5.0f,1).k=%s',ik,OSMDATA.keys(ik,1).k);
						fprintf(1,'ik=%5.0f    %s%s    obj_tag_incl(%2.0f,%2.0f).k=%s    out=%s\n',...
							ik,...
							MAP_keys_ik_k,blanks(60-length(MAP_keys_ik_k)),...
							r_tags,...
							c_tags,...
							obj_tag_incl(r_tags,c_tags).k,...
							out_str);
					end
					if isequal({OSMDATA.keys(ik,1).k},out)
						op_equal_to		= false;
						op_notequal_to	= false;
						if     strcmp(obj_tag_incl(r_tags,c_tags).op,'==')
							op_equal_to		= true;
						elseif strcmp(obj_tag_incl(r_tags,c_tags).op,'~=')
							op_notequal_to	= true;
						end
						if op_equal_to||op_notequal_to
							if filter_n
								for i=1:size(OSMDATA.keys(ik,1).in,2)
									in				= OSMDATA.keys(ik,1).in(1,i);
									int			= OSMDATA.keys(ik,1).int(1,i);
									out=regexpi(OSMDATA.node(1,in).tag(1,int).v,...
										regexptranslate('wildcard',obj_tag_incl(r_tags,c_tags).v),'match');
									if isequal({OSMDATA.node(1,in).tag(1,int).v},out)
										if op_equal_to
											in_logical(r_tags,in)	= true;
										end
									else
										if op_notequal_to
											in_logical(r_tags,in)	= true;
										end
									end
								end
							end
							if filter_w
								for i=1:size(OSMDATA.keys(ik,1).iw,2)
									iw				= OSMDATA.keys(ik,1).iw(1,i);
									iwt			= OSMDATA.keys(ik,1).iwt(1,i);
									out=regexpi(OSMDATA.way(1,iw).tag(1,iwt).v,...
										regexptranslate('wildcard',obj_tag_incl(r_tags,c_tags).v),'match');
									if isequal({OSMDATA.way(1,iw).tag(1,iwt).v},out)
										if op_equal_to
											iw_logical(r_tags,iw)	= true;
										end
									else
										if op_notequal_to
											iw_logical(r_tags,iw)	= true;
										end
									end
								end
							end
							if filter_r
								for i=1:size(OSMDATA.keys(ik,1).ir,2)
									ir				= OSMDATA.keys(ik,1).ir(1,i);
									irt			= OSMDATA.keys(ik,1).irt(1,i);
									out=regexpi(OSMDATA.relation(1,ir).tag(1,irt).v,...
										regexptranslate('wildcard',obj_tag_incl(r_tags,c_tags).v),'match');
									if isequal({OSMDATA.relation(1,ir).tag(1,irt).v},out)
										if op_equal_to
											ir_logical(r_tags,ir)	= true;
										end
									else
										if op_notequal_to
											ir_logical(r_tags,ir)	= true;
										end
									end
								end
							end
						else
							value_ref	= str2num(obj_tag_incl(r_tags,c_tags).v);
							if isequal(length(value_ref),1)
								if filter_n
									for i=1:size(OSMDATA.keys(ik,1).in,2)
										in				= OSMDATA.keys(ik,1).in(1,i);
										int			= OSMDATA.keys(ik,1).int(1,i);
										value_osm	= str2num(OSMDATA.node(1,in).tag(1,int).v);
										if isequal(length(value_osm),1)
											eval(sprintf('condition_met=(value_osm%svalue_ref);',obj_tag_incl(r_tags,c_tags).op));
											if condition_met
												in_logical(r_tags,in)	= true;
											end
										end
									end
								end
							end
							if filter_w
								for i=1:size(OSMDATA.keys(ik,1).iw,2)
									iw				= OSMDATA.keys(ik,1).iw(1,i);
									iwt			= OSMDATA.keys(ik,1).iwt(1,i);
									value_osm	= str2num(OSMDATA.way(1,iw).tag(1,iwt).v);
									if isequal(length(value_osm),1)
										eval(sprintf('condition_met=(value_osm%svalue_ref);',obj_tag_incl(r_tags,c_tags).op));
										if condition_met
											iw_logical(r_tags,iw)	= true;
										end
									end
								end
								if filter_r
									for i=1:size(OSMDATA.keys(ik,1).ir,2)
										ir				= OSMDATA.keys(ik,1).ir(1,i);
										irt			= OSMDATA.keys(ik,1).irt(1,i);
										value_osm	= str2num(OSMDATA.relation(1,ir).tag(1,irt).v);
										if isequal(length(value_osm),1)
											eval(sprintf('condition_met=(value_osm%svalue_ref);',obj_tag_incl(r_tags,c_tags).op));
											if condition_met
												ir_logical(r_tags,ir)	= true;
											end
										end
									end
								end
							end
						end
					end
				end
			elseif ~isempty(obj_tag_incl(r_tags,c_tags).k)
				% If only key is specified: Inclusion of all objects in which key occurs in any tag:
				for ik=1:size(OSMDATA.keys,1)
					% Waitbar:
					if ~isempty(msg)
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',sprintf('%s Filter OSM-data %g/%g',msg,ik,size(OSMDATA.keys,1)));
							drawnow;
						end
					end
					out=regexpi(OSMDATA.keys(ik,1).k,...
						regexptranslate('wildcard',obj_tag_incl(r_tags,c_tags).k),'match');
					if isequal({OSMDATA.keys(ik,1).k},out)
						if filter_n
							in_logical(r_tags,OSMDATA.keys(ik,1).in)		= true;
						end
						if filter_w
							iw_logical(r_tags,OSMDATA.keys(ik,1).iw)		= true;
						end
						if filter_r
							ir_logical(r_tags,OSMDATA.keys(ik,1).ir)		= true;
						end
					end
				end
			elseif ~isempty(obj_tag_incl(r_tags,c_tags).v)
				% If only value is specified: Inclusion of all objects in which value occurs in any tag:
				for iv=1:size(OSMDATA.values,1)
					% Waitbar:
					if ~isempty(msg)
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',sprintf('%s Filter OSM-data %g/%g',msg,iv,size(OSMDATA.values,1)));
							drawnow;
						end
					end
					out=regexpi(OSMDATA.values(iv,1).v,...
						regexptranslate('wildcard',obj_tag_incl(r_tags,c_tags).v),'match');
					if isequal({OSMDATA.values(iv,1).v},out)
						if filter_n
							in_logical(r_tags,OSMDATA.values(iv,1).in)	= true;
						end
						if filter_w
							iw_logical(r_tags,OSMDATA.values(iv,1).iw)	= true;
						end
						if filter_r
							ir_logical(r_tags,OSMDATA.values(iv,1).ir)	= true;
						end
					end
				end
			end
		end
		% 	if    isempty(in_logical(r_tags,in_logical(r_tags,:)))&&...
		% 			isempty(iw_logical(r_tags,iw_logical(r_tags,:)))&&...
		% 			isempty(ir_logical(r_tags,ir_logical(r_tags,:)))
		if ~rowcontainsfilter
			% If in the current row of obj_tag_incl there are no filters applied:
			% The logical AND of all rows should only be used for objects with a tag.
			% Otherwise the list could become too long, because there are much nodes without a tag.
			% 		in_logical(r_tags,:)	= OSMDATA.istag.node(1,:);
			% 		iw_logical(r_tags,:)	= OSMDATA.istag.way(1,:);
			% 		ir_logical(r_tags,:)	= OSMDATA.istag.relation(1,:);
			
			in_logical(r_tags,:)	= true(1,max(1,size(OSMDATA.istag.node    ,2)));
			iw_logical(r_tags,:)	= true(1,max(1,size(OSMDATA.istag.way     ,2)));
			ir_logical(r_tags,:)	= true(1,max(1,size(OSMDATA.istag.relation,2)));
			
		end
	end
	% Perform logical AND of all rows:
	% If there are no filter criteria in obj_tag_incl, all objects are included.
	if size(obj_tag_incl,1)>=2
		for r_tags=2:size(obj_tag_incl,1)
			in_logical(1,:)	= in_logical(1,:) & in_logical(r_tags,:);
			iw_logical(1,:)	= iw_logical(1,:) & iw_logical(r_tags,:);
			ir_logical(1,:)	= ir_logical(1,:) & ir_logical(r_tags,:);
		end
	end
	in_logical_incl	= in_logical(1,:);
	iw_logical_incl	= iw_logical(1,:);
	ir_logical_incl	= ir_logical(1,:);
	
	% Exclusion of objects:
	in_logical			= false(max(1,size(obj_tag_excl,1)),size(OSMDATA.node,2));
	iw_logical			= false(max(1,size(obj_tag_excl,1)),size(OSMDATA.way,2));
	ir_logical			= false(max(1,size(obj_tag_excl,1)),size(OSMDATA.relation,2));
	tagscontainfilter	= false;
	for r_tags=1:size(obj_tag_excl,1)
		rowcontainsfilter	= false;
		for c_tags=1:size(obj_tag_excl,2)
			if ~isempty(obj_tag_excl(r_tags,c_tags).k)||~isempty(obj_tag_excl(r_tags,c_tags).v)
				% In the current row of obj_tag_excl there are filters applied:
				rowcontainsfilter	= true;
				tagscontainfilter	= true;
			end
			if ~isempty(obj_tag_excl(r_tags,c_tags).k) && ~isempty(obj_tag_excl(r_tags,c_tags).v)
				% If key and value are both specified:
				% Inclusion of all objects in whose tags the condition key=value is fulfilled in the same tag:
				for ik=1:size(OSMDATA.keys,1)
					% Waitbar:
					if ~isempty(msg)
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',sprintf('%s Filter OSM-data: tag_excl %g/%g',...
								msg,ik,size(OSMDATA.keys,1)));
							drawnow;
						end
					end
					out=regexpi(OSMDATA.keys(ik,1).k,...
						regexptranslate('wildcard',obj_tag_excl(r_tags,c_tags).k),'match');
					if isequal({OSMDATA.keys(ik,1).k},out)
						op_equal_to		= false;
						op_notequal_to	= false;
						if     strcmp(obj_tag_excl(r_tags,c_tags).op,'==')
							op_equal_to		= true;
						elseif strcmp(obj_tag_excl(r_tags,c_tags).op,'~=')
							op_notequal_to	= true;
						end
						if op_equal_to||op_notequal_to
							if filter_n
								for i=1:size(OSMDATA.keys(ik,1).in,2)
									in		= OSMDATA.keys(ik,1).in(1,i);
									int	= OSMDATA.keys(ik,1).int(1,i);
									out=regexpi(OSMDATA.node(1,in).tag(1,int).v,...
										regexptranslate('wildcard',obj_tag_excl(r_tags,c_tags).v),'match');
									if isequal({OSMDATA.node(1,in).tag(1,int).v},out)
										if op_equal_to
											in_logical(r_tags,in)	= true;
										end
									else
										if op_notequal_to
											in_logical(r_tags,in)	= true;
										end
									end
								end
							end
							if filter_w
								for i=1:size(OSMDATA.keys(ik,1).iw,2)
									iw		= OSMDATA.keys(ik,1).iw(1,i);
									iwt	= OSMDATA.keys(ik,1).iwt(1,i);
									out=regexpi(OSMDATA.way(1,iw).tag(1,iwt).v,...
										regexptranslate('wildcard',obj_tag_excl(r_tags,c_tags).v),'match');
									if isequal({OSMDATA.way(1,iw).tag(1,iwt).v},out)
										if op_equal_to
											iw_logical(r_tags,iw)	= true;
										end
									else
										if op_notequal_to
											iw_logical(r_tags,iw)	= true;
										end
									end
								end
							end
							if filter_r
								for i=1:size(OSMDATA.keys(ik,1).ir,2)
									ir		= OSMDATA.keys(ik,1).ir(1,i);
									irt	= OSMDATA.keys(ik,1).irt(1,i);
									out=regexpi(OSMDATA.relation(1,ir).tag(1,irt).v,...
										regexptranslate('wildcard',obj_tag_excl(r_tags,c_tags).v),'match');
									if isequal({OSMDATA.relation(1,ir).tag(1,irt).v},out)
										if op_equal_to
											ir_logical(r_tags,ir)	= true;
										end
									else
										if op_notequal_to
											ir_logical(r_tags,ir)	= true;
										end
									end
								end
							end
						else
							value_ref	= str2num(obj_tag_excl(r_tags,c_tags).v);
							if isequal(length(value_ref),1)
								if filter_n
									for i=1:size(OSMDATA.keys(ik,1).in,2)
										in				= OSMDATA.keys(ik,1).in(1,i);
										int			= OSMDATA.keys(ik,1).int(1,i);
										value_osm	= str2num(OSMDATA.node(1,in).tag(1,int).v);
										if isequal(length(value_osm),1)
											eval(sprintf('condition_met=(value_osm%svalue_ref);',obj_tag_excl(r_tags,c_tags).op));
											if condition_met
												in_logical(r_tags,in)	= true;
											end
										end
									end
								end
								if filter_w
									for i=1:size(OSMDATA.keys(ik,1).iw,2)
										iw				= OSMDATA.keys(ik,1).iw(1,i);
										iwt			= OSMDATA.keys(ik,1).iwt(1,i);
										value_osm	= str2num(OSMDATA.way(1,iw).tag(1,iwt).v);
										if isequal(length(value_osm),1)
											eval(sprintf('condition_met=(value_osm%svalue_ref);',obj_tag_excl(r_tags,c_tags).op));
											if condition_met
												iw_logical(r_tags,iw)	= true;
											end
										end
									end
								end
								if filter_r
									for i=1:size(OSMDATA.keys(ik,1).ir,2)
										ir				= OSMDATA.keys(ik,1).ir(1,i);
										irt			= OSMDATA.keys(ik,1).irt(1,i);
										value_osm	= str2num(OSMDATA.relation(1,ir).tag(1,irt).v);
										if isequal(length(value_osm),1)
											eval(sprintf('condition_met=(value_osm%svalue_ref);',obj_tag_excl(r_tags,c_tags).op));
											if condition_met
												ir_logical(r_tags,ir)	= true;
											end
										end
									end
								end
							end
						end
					end
				end
			elseif ~isempty(obj_tag_excl(r_tags,c_tags).k)
				% If only key is specified: Inclusion of all objects in which key occurs in any tag:
				for ik=1:size(OSMDATA.keys,1)
					% Waitbar:
					if ~isempty(msg)
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',sprintf('%s Filter OSM-data %g/%g',msg,ik,size(OSMDATA.keys,1)));
							drawnow;
						end
					end
					out=regexpi(OSMDATA.keys(ik,1).k,...
						regexptranslate('wildcard',obj_tag_excl(r_tags,c_tags).k),'match');
					if isequal({OSMDATA.keys(ik,1).k},out)
						if filter_n
							in_logical(r_tags,OSMDATA.keys(ik,1).in)		= true;
						end
						if filter_w
							iw_logical(r_tags,OSMDATA.keys(ik,1).iw)		= true;
						end
						if filter_r
							ir_logical(r_tags,OSMDATA.keys(ik,1).ir)		= true;
						end
					end
				end
			elseif ~isempty(obj_tag_excl(r_tags,c_tags).v)
				% If only value is specified: Inclusion of all objects in which value occurs in any tag:
				for iv=1:size(OSMDATA.values,1)
					% Waitbar:
					if ~isempty(msg)
						if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
							WAITBAR.t1	= clock;
							set(GV_H.text_waitbar,'String',sprintf('%s Filter OSM-data %g/%g',msg,iv,size(OSMDATA.values,1)));
							drawnow;
						end
					end
					out=regexpi(OSMDATA.values(iv,1).v,...
						regexptranslate('wildcard',obj_tag_excl(r_tags,c_tags).v),'match');
					if isequal({OSMDATA.values(iv,1).v},out)
						if filter_n
							in_logical(r_tags,OSMDATA.values(iv,1).in)	= true;
						end
						if filter_w
							iw_logical(r_tags,OSMDATA.values(iv,1).iw)	= true;
						end
						if filter_r
							ir_logical(r_tags,OSMDATA.values(iv,1).ir)	= true;
						end
					end
				end
			end
		end
		% 	if    isempty(in_logical(r_tags,in_logical(r_tags,:)))&&...
		% 			isempty(iw_logical(r_tags,iw_logical(r_tags,:)))&&...
		% 			isempty(ir_logical(r_tags,ir_logical(r_tags,:)))
		if ~rowcontainsfilter
			% If in the current row of obj_tag_excl there are no filters applied:
			% 		in_logical(r_tags,:)	= true(size(OSMDATA.istag.node));
			% 		iw_logical(r_tags,:)	= true(size(OSMDATA.istag.way));
			% 		ir_logical(r_tags,:)	= true(size(OSMDATA.istag.relation));
			
			in_logical(r_tags,:)	= true(1,max(1,size(OSMDATA.istag.node    ,2)));
			iw_logical(r_tags,:)	= true(1,max(1,size(OSMDATA.istag.way     ,2)));
			ir_logical(r_tags,:)	= true(1,max(1,size(OSMDATA.istag.relation,2)));
			
		end
	end
	% Perform logical AND of all rows:
	% If there are no filter criteria in obj_tag_excl, no objects are excluded.
	if tagscontainfilter
		% In obj_tag_excl there are filters applied:
		% Include only those objects that meet the filter criteria:
		if size(obj_tag_excl,1)>=2
			for r_tags=2:size(obj_tag_excl,1)
				in_logical(1,:)	= in_logical(1,:) & in_logical(r_tags,:);
				iw_logical(1,:)	= iw_logical(1,:) & iw_logical(r_tags,:);
				ir_logical(1,:)	= ir_logical(1,:) & ir_logical(r_tags,:);
			end
		end
	else
		% In obj_tag_excl there are no filter criteria applied:
		% Exlude no objects:
		in_logical(1,:)	= false(size(OSMDATA.node));
		iw_logical(1,:)	= false(size(OSMDATA.way));
		ir_logical(1,:)	= false(size(OSMDATA.relation));
	end
	
	% Perform the logic operation of include and exclude tags:
	in_logical	= in_logical_incl & ~in_logical(1,:);
	iw_logical	= iw_logical_incl & ~iw_logical(1,:);
	ir_logical	= ir_logical_incl & ~ir_logical(1,:);
	
	% Save the objects as a table:
	obj_in	= find(in_logical);
	obj_iw	= find(iw_logical);
	obj_ir	= find(ir_logical);
	inmax		= length(obj_in);
	iwmax		= length(obj_iw);
	irmax		= length(obj_ir);
	imax		= inmax+iwmax+irmax;
	
	% Create an empty table:
	varNames	= {...
		'No',...				% itable
		'ID',...				% id
		'Type',...			% type
		'ObjNo',...			% object number
		'NoN',...			% no_nodes
		'NoW',...			% no_ways
		'NoR',...			% no_relations
		'Dimx',...			% dx_mm
		'Dimy',...			% dy_mm
		'Diag',...			% diag_mm
		'Length',...		% length_mm
		'Area'};				% area_mm2
	columns_tags0			= length(varNames);
	for it=1:OSMDATA.no_tags
		varNames{1,end+1}	= sprintf('Key%1.0f',it);
		varNames{1,end+1}	= sprintf('Val%1.0f',it);
	end
	varTypes	= {...
		'double',...		% itable
		'uint64',...		% id
		'string',...		% type
		'double',...		% object number
		'double',...		% no_nodes
		'double',...		% no_ways
		'double',...		% no_relations
		'double',...		% dx_mm
		'double',...		% dy_mm
		'double',...		% diag_mm
		'double',...		% length_mm
		'double'};			% area_mm2
	for it=1:OSMDATA.no_tags
		varTypes{1,end+1}	= 'string';
		varTypes{1,end+1}	= 'string';
	end
	sz							= [imax length(varNames)];
	OSMDATA_TABLE			= table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
	% Replace <missing> by "":
	for c=1:width(OSMDATA_TABLE)
		if strcmp(varTypes(1,c),'string')
			OSMDATA_TABLE.(c)(:)	= "";
		end
	end
	OSMDATA_TABLE_INWR	= zeros(imax,1);
	
	% Nodes:
	for i=1:length(obj_in)
		% Waitbar:
		if ~isempty(msg)
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1	= clock;
				set(GV_H.text_waitbar,'String',sprintf('%s Filter OSM-data, assign results: No %g/%g',...
					msg,i,imax));
				drawnow;
			end
		end
		in												= obj_in(i);
		itable										= i;
		OSMDATA_TABLE_INWR(itable,1)			= in;
		OSMDATA_TABLE.No(itable,1)				= itable;
		OSMDATA_TABLE.ID(itable,1)				= OSMDATA.id.node(1,in);
		OSMDATA_TABLE.Type{itable,1}			= 'node';
		OSMDATA_TABLE.ObjNo(itable,1)			= OSMDATA.iobj.node(1,in);
		OSMDATA_TABLE.NoN(itable,1)			= 1;
		% OSMDATA_TABLE.NoW(itable,1)			= 0;
		% OSMDATA_TABLE.NoR(itable,1)			= 0;
		% OSMDATA_TABLE.Dimx(itable,1)		= 0;
		% OSMDATA_TABLE.Dimy(itable,1)		= 0;
		% OSMDATA_TABLE.Diag(itable,1)		= 0;
		% OSMDATA_TABLE.Length(itable,1)		= 0;
		% OSMDATA_TABLE.Area(itable,1)		= 0;
		if ~ismissing(OSMDATA.node(1,in).tag(1,1))
			for int=1:OSMDATA.no_tags
				if int<=size(OSMDATA.node(1,in).tag,2)
					OSMDATA_TABLE.(columns_tags0+2*int-1){itable,1}	= OSMDATA.node(1,in).tag(1,int).k;
					OSMDATA_TABLE.(columns_tags0+2*int  ){itable,1}	= OSMDATA.node(1,in).tag(1,int).v;
				else
					break
				end
			end
		end
	end
	
	% Ways:
	for i=1:length(obj_iw)
		% Waitbar:
		if ~isempty(msg)
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1	= clock;
				set(GV_H.text_waitbar,'String',sprintf('%s Filter OSM-data, assign results: No %g/%g',...
					msg,inmax+i,imax));
				drawnow;
			end
		end
		iw												= obj_iw(i);
		itable										= i+inmax;
		OSMDATA_TABLE_INWR(itable,1)			= iw;
		OSMDATA_TABLE.No(itable,1)				= itable;
		OSMDATA_TABLE.ID(itable,1)				= OSMDATA.id.way(1,iw);
		OSMDATA_TABLE.Type{itable,1}			= 'way';
		OSMDATA_TABLE.ObjNo(itable,1)			= OSMDATA.iobj.way(1,iw);
		OSMDATA_TABLE.NoN(itable,1)			= OSMDATA.way(1,iw).no_nodes;
		OSMDATA_TABLE.NoW(itable,1)			= 1;
		% OSMDATA_TABLE.NoR(itable,1)			= 0;
		OSMDATA_TABLE.Dimx(itable,1)			= OSMDATA.way_xmax_mm(1,iw)-OSMDATA.way_xmin_mm(1,iw);
		OSMDATA_TABLE.Dimy(itable,1)			= OSMDATA.way_ymax_mm(1,iw)-OSMDATA.way_ymin_mm(1,iw);
		OSMDATA_TABLE.Diag(itable,1)			= sqrt(...
			OSMDATA_TABLE.Dimx(itable,1)^2+...
			OSMDATA_TABLE.Dimy(itable,1)^2    );
		OSMDATA_TABLE.Length(itable,1)		= OSMDATA.way(1,iw).length_mm;
		OSMDATA_TABLE.Area(itable,1)			= OSMDATA.way(1,iw).area_mm2;
		if ~ismissing(OSMDATA.way(1,iw).tag(1,1))
			for iwt=1:OSMDATA.no_tags
				if iwt<=size(OSMDATA.way(1,iw).tag,2)
					OSMDATA_TABLE.(columns_tags0+2*iwt-1){itable,1}	= OSMDATA.way(1,iw).tag(1,iwt).k;
					OSMDATA_TABLE.(columns_tags0+2*iwt  ){itable,1}	= OSMDATA.way(1,iw).tag(1,iwt).v;
				else
					break
				end
			end
		end
	end
	
	% Relations:
	for i=1:length(obj_ir)
		% Waitbar:
		if ~isempty(msg)
			if etime(clock,WAITBAR.t1)>=GV.waitbar_dtupdate
				WAITBAR.t1	= clock;
				set(GV_H.text_waitbar,'String',sprintf('%s Filter OSM-data, assign results: No %g/%g',...
					msg,inmax+iwmax+i,imax));
				drawnow;
			end
		end
		ir												= obj_ir(i);
		itable										= i+inmax+iwmax;
		OSMDATA_TABLE_INWR(itable,1)			= ir;
		OSMDATA_TABLE.No(itable,1)				= itable;
		OSMDATA_TABLE.ID(itable,1)				= OSMDATA.id.relation(1,ir);
		OSMDATA_TABLE.Type{itable,1}			= 'relation';
		OSMDATA_TABLE.ObjNo(itable,1)			= OSMDATA.iobj.relation(1,ir);
		OSMDATA_TABLE.NoN(itable,1)			= OSMDATA.relation(1,ir).no_nodes;
		OSMDATA_TABLE.NoW(itable,1)			= OSMDATA.relation(1,ir).no_ways;
		OSMDATA_TABLE.NoR(itable,1)			= OSMDATA.relation(1,ir).no_relations;
		OSMDATA_TABLE.Dimx(itable,1)			= OSMDATA.relation_xmax_mm(1,ir)-OSMDATA.relation_xmin_mm(1,ir);
		OSMDATA_TABLE.Dimy(itable,1)			= OSMDATA.relation_ymax_mm(1,ir)-OSMDATA.relation_ymin_mm(1,ir);
		OSMDATA_TABLE.Diag(itable,1)			= sqrt(...
			OSMDATA_TABLE.Dimx(itable,1)^2+...
			OSMDATA_TABLE.Dimy(itable,1)^2    );
		OSMDATA_TABLE.Length(itable,1)		= OSMDATA.relation(1,ir).length_mm;
		OSMDATA_TABLE.Area(itable,1)			= OSMDATA.relation(1,ir).area_mm2;
		if ~ismissing(OSMDATA.relation(1,ir).tag(1,1))
			for irt=1:OSMDATA.no_tags
				if irt<=size(OSMDATA.relation(1,ir).tag,2)
					OSMDATA_TABLE.(columns_tags0+2*irt-1){itable,1}	= OSMDATA.relation(1,ir).tag(1,irt).k;
					OSMDATA_TABLE.(columns_tags0+2*irt  ){itable,1}	= OSMDATA.relation(1,ir).tag(1,irt).v;
				else
					break
				end
			end
		end
	end
	
	% Additional include filters:
	r_table_filtercrit	= false(size(OSMDATA_TABLE,1),size(filter_incl,1));
	crit_is_valid			= false(1                    ,size(filter_incl,1));
	for r_filt=1:size(filter_incl,1)
		for c_filt=1:size(filter_incl,2)
			crit		= filter_incl(r_filt,c_filt).crit;
			if ~isempty(crit)
				lolim		= filter_incl(r_filt,c_filt).lolim;
				uplim		= filter_incl(r_filt,c_filt).uplim;
				switch crit
					case 'Type'
						if ~(...
								(strcmp(lolim,'node'    )&&strcmp(uplim,'node'    ))||...
								(strcmp(lolim,'way'     )&&strcmp(uplim,'way')     )||...
								(strcmp(lolim,'relation')&&strcmp(uplim,'relation'))     )
							crit		= '';
						end
					case {'ID','NoN','NoW','NoR','Dimx','Dimy','Diag','Length','Area'}
						lolim		= str2double(lolim);
						uplim		= str2double(uplim);
					otherwise
						crit		= '';
				end
				% Identify the rows, that do not meet the criterion:
				if ~isempty(crit)
					switch crit
						case 'Type'
							crit_is_valid(1,r_filt)	= true;
							for r_table=1:size(OSMDATA_TABLE,1)
								if strcmp(OSMDATA_TABLE.(crit)(r_table),lolim)
									r_table_filtercrit(r_table,r_filt)	= true;
								end
							end
						otherwise
							% crit = 'ID','NoN','NoW','NoR','Dimx','Dimy','Diag','Length','Area':
							if ~isnan(lolim)&&~isnan(uplim)
								crit_is_valid(1,r_filt)	= true;
								for r_table=1:size(OSMDATA_TABLE,1)
									if (OSMDATA_TABLE.(crit)(r_table)>=lolim)&&(OSMDATA_TABLE.(crit)(r_table)<=uplim)
										r_table_filtercrit(r_table,r_filt)	= true;
									end
								end
							end
					end
				end
			end
		end
	end
	% Assigne the rows of the table to include:
	r_table_filtercrit_incl	= true(size(OSMDATA_TABLE,1),1);
	for r_filt=1:size(filter_incl,1)
		if crit_is_valid(1,r_filt)
			r_table_filtercrit_incl	= r_table_filtercrit_incl & r_table_filtercrit(:,r_filt);
		end
	end
	
	% Additional exclude filters:
	r_table_filtercrit	= false(size(OSMDATA_TABLE,1),size(filter_excl,1));
	crit_is_valid			= false(1                    ,size(filter_excl,1));
	for r_filt=1:size(filter_excl,1)
		for c_filt=1:size(filter_excl,2)
			crit		= filter_excl(r_filt,c_filt).crit;
			if ~isempty(crit)
				lolim		= filter_excl(r_filt,c_filt).lolim;
				uplim		= filter_excl(r_filt,c_filt).uplim;
				switch crit
					case 'Type'
						if ~(...
								(strcmp(lolim,'node'    )&&strcmp(uplim,'node'    ))||...
								(strcmp(lolim,'way'     )&&strcmp(uplim,'way')     )||...
								(strcmp(lolim,'relation')&&strcmp(uplim,'relation'))     )
							crit		= '';
						end
					case {'ID','NoN','NoW','NoR','Dimx','Dimy','Diag','Length','Area'}
						lolim		= str2double(lolim);
						uplim		= str2double(uplim);
					otherwise
						crit		= '';
				end
				% Identify the rows, that do not meet the criterion:
				if ~isempty(crit)
					switch crit
						case 'Type'
							crit_is_valid(1,r_filt)	= true;
							for r_table=1:size(OSMDATA_TABLE,1)
								if strcmp(OSMDATA_TABLE.(crit)(r_table),lolim)
									r_table_filtercrit(r_table,r_filt)	= true;
								end
							end
						otherwise
							% crit = 'ID','NoN','NoW','NoR','Dimx','Dimy','Diag','Length','Area':
							if ~isnan(lolim)&&~isnan(uplim)
								crit_is_valid(1,r_filt)	= true;
								for r_table=1:size(OSMDATA_TABLE,1)
									if (OSMDATA_TABLE.(crit)(r_table)>=lolim)&&(OSMDATA_TABLE.(crit)(r_table)<=uplim)
										r_table_filtercrit(r_table,r_filt)	= true;
									end
								end
							end
					end
				end
			end
		end
	end
	% Assign the rows of the table to exclude:
	if isempty(crit_is_valid(crit_is_valid))
		% There is no valid exclude criterion specified:
		r_table_filtercrit_excl	= false(size(OSMDATA_TABLE,1),1);
	else
		% There are valid exclude critera specified:
		r_table_filtercrit_excl	= true(size(OSMDATA_TABLE,1),1);
		for r_filt=1:size(filter_excl,1)
			if crit_is_valid(1,r_filt)
				r_table_filtercrit_excl	= r_table_filtercrit_excl & r_table_filtercrit(:,r_filt);
			end
		end
	end
	
	% Perform the logic operation of include and exclude tags:
	r_table_filtercrit	= ~r_table_filtercrit_incl | r_table_filtercrit_excl;
	
	% Delete the rows in the table, that do not meet the criterion:
	OSMDATA_TABLE(r_table_filtercrit,:)	= [];
	
	% Display the table:
	if update_osmdata_table~=0
		create_new_tablefigure	= false;
		if isempty(APP)
			% Only for testing, without app:
			if ~isfield(GV_H,'OSMDATA_TABLE')
				create_new_tablefigure	= true;
			else
				if isempty(GV_H.osmdata_table)
					create_new_tablefigure	= true;
				else
					if ~ishandle(GV_H.osmdata_table)
						create_new_tablefigure	= true;
					end
				end
			end
		end
		if create_new_tablefigure
			% Only for testing: Create a new table:
			testfig_OSMDATA_TABLE		= uifigure;
			testfig_OSMDATA_TABLE.Name	= 'OSMDATA_TABLE';
			GV_H.osmdata_table	= uitable(testfig_OSMDATA_TABLE,...
				'Data',OSMDATA_TABLE,...
				'ColumnName',varNames',...
				'ColumnSortable',true(1,size(OSMDATA_TABLE,2)),...
				'ColumnWidth','fit');
		else
			% Replace the data in the existing table:
			GV_H.osmdata_table.Data				= OSMDATA_TABLE;
			GV_H.osmdata_table.ColumnWidth	= 'fit';
		end
		drawnow;
	end
	% Always update the columns of the uitable, because after loading the OSM-data, the number
	% of tags can change (OSMDATA.no_tags):
	if ~isempty(APP)
		GV_H.osmdata_table.ColumnName		= varNames';
	end
	
catch ME
	errormessage('',ME);
end

