function value	= get_building_topside_get_tag_value(type,inwr,key,format)
% Conversion of OSM tag values into numbers, taking into account the optional specification of units.
%
% format=number		Number without the possible specification of a unit
% format=distance		Number with the possible specification of a unit of length
% format=angle			Number with the possible specification of the unit degrees
% format=string		No change
% format=direction	...
% format=bool			roof:ridge, edge enthalten oder nicht. wenn key nicht existiert, dann leere matrix. ansonsten bool antwort.
%


global OSMDATA

value	= [];				% Default output if the value could not be converted to a number.

if ~ismissing(OSMDATA.(type)(1,inwr).tag(1,1))
	
	for it=1:size(OSMDATA.(type)(1,inwr).tag,2)
		
		if strcmp(OSMDATA.(type)(1,inwr).tag(1,it).k,key)
			
			value	= OSMDATA.(type)(1,inwr).tag(1,it).v;
			
			switch format
				
				case 'number'
					
					% Number without the possible specification of a unit:
					value		= valstr2valnum(value);						% str2double with handling of incorrect comma usage
					
					if isnan(value)
						
						value				= [];
					end
					
				case 'direction'
					
					switch value
						
						case 'N'
							
							value = 0;
							
						case 'NNE'
							
							value = 22;
							
						case 'NE'
							
							value = 45;
							
						case 'ENE'
							
							value = 67;
							
						case 'E'
							value =  90;
							
						case 'ESE'
							
							value = 112;
							
						case 'SE'
							
							value = 135;
							
						case 'SSE'
							
							value = 157;
							
						case 'S'
							
							value = 180;
							
						case 'SSW'
							
							value = 202;
							
						case 'SW'
							
							value = 225;
							
						case 'WSW'
							
							value = 247;
							
						case 'W'
							
							value = 270;
							
						case 'WNW'
							
							value = 292;
							
						case 'NW'
							
							value = 315;
							
						case 'NNW'
							
							value = 337;
							
						otherwise
							value	= valstr2valnum(value);					% str2double with handling of incorrect comma usage
					end
					
					if isnan(value)
						value	= [];
					end
					
				case 'distance'
					
					% Number with the possible specification of a unit of length:
					k_m = find(value=='m');
					k_mm = strfind(value,'mm');
					k_feet = find(value==convertStringsToChars("'"));
					k_inches	= find(value=='"');
					
					if isscalar(k_m)											% '1.2345m' or '1.2345 m'
						
						% Specifying the unit m is optional:
						value(k_m) = '';
						value	= valstr2valnum(value);						% str2double with handling of incorrect comma usage
						
					elseif isscalar(k_mm)									% '1234.5mm' or '1234.5 mm'
						
						% Specifying the unit mm is optional:
						value(k_m) = '';
						value	= valstr2valnum(value)/1000;				% str2double with handling of incorrect comma usage
						
					elseif isscalar(k_feet)||isscalar(k_inches)		% 7'4" (7 feet and 4 inches)
						
						if isscalar(k_feet)
							feet = str2double(value(1:(k_feet-1)));
							value	= value((k_feet+1):end);
							
						else
							
							feet = 0;
							
						end
						
						k_inches	= find(value=='"');
						
						if isscalar(k_inches)
							
							inches = str2double(value(1:(k_inches-1)));
							
						else
							
							inches = 0;
							
						end
						
						value	= 0.3048*feet+0.0254*inches;
						
					else
						
						value	= valstr2valnum(value);						% str2double with handling of incorrect comma usage
						
					end
					
					if isnan(value)
						
						value	= [];
						
					end
					
				case 'angle'
					
					% Number with the possible specification of the unit degrees:
					k_deg	= find(value=='°');
					
					if isscalar(k_deg)										% '1.2345°' or '1.2345 °'
						
						% Specifying the unit ° is optional:
						value(k_deg) = '';
						value	= valstr2valnum(value);						% str2double with handling of incorrect comma usage
						
					else
						
						value	= valstr2valnum(value);						% str2double with handling of incorrect comma usage
						
					end
					
					if isnan(value)
						
						value				= [];
						
					end
					
				case 'string'
					
					% no change
					
				case 'bool'
					
					switch value
						
						case 'yes'
							
							value = true;
							
						case 'no'
							
							value = false;
						otherwise
							value	= valstr2valnum(value);					% str2double with handling of incorrect comma usage
							
					end
					
					if isnan(value)
						
						value				= [];
					end
					
			end
		end
	end
end


