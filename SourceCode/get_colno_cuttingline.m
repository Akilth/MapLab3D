function cncl=get_colno_cuttingline
% Get the current selection of the dropdown menu APP.Mod_UnitedColors_SelectColNo_DropDown.Value

global APP

try

	pattern1	= 'Color ';
	k1			= strfind(APP.Mod_UnitedColors_SelectColNo_DropDown.Value,pattern1);
	k2			= strfind(APP.Mod_UnitedColors_SelectColNo_DropDown.Value,' (');
	cncl		= 0;
	if isscalar(k1)&&(length(k2)>=1)
		k2		= k2(1);
		if (k1==1)&&(k2>=2)
			cncl_1	= str2double(APP.Mod_UnitedColors_SelectColNo_DropDown.Value((length(pattern1)+1):(k2-1)));
			if ~isnan(cncl_1)
				if isscalar(cncl_1)
					cncl	= cncl_1;
				end
			end
		end
	end

catch ME
	errormessage('',ME);
end

