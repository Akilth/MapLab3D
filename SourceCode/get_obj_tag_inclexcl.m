function [obj_tag_incl,obj_tag_excl]=get_obj_tag_inclexcl
% Reads the content of the include and exclude keys and values uitables

global APP

try

	obj_tag_incl	= struct;
	rmax				= size(APP.include_keys.Data,1);
	cmax				= size(APP.include_keys.Data,2);
	for r=1:rmax
		for c=1:cmax
			obj_tag_incl(r,c).k		= APP.include_keys.Data{r,c};
			obj_tag_incl(r,c).v		= APP.include_values.Data{r,c};
			obj_tag_incl(r,c).op		= '==';
		end
	end

	obj_tag_excl	= struct;
	rmax				= size(APP.exclude_keys.Data,1);
	cmax				= size(APP.exclude_keys.Data,2);
	for r=1:rmax
		for c=1:cmax
			obj_tag_excl(r,c).k		= APP.exclude_keys.Data{r,c};
			obj_tag_excl(r,c).v		= APP.exclude_values.Data{r,c};
			obj_tag_excl(r,c).op		= '==';
		end
	end

catch ME
	errormessage('',ME);
end

