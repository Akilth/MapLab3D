function [command]=extent_pp(T,i,level,command,filename,dataset_no)
% dataset_no>=1		Assign the values of the column DATASET_x
% dataset_no =0		Assign the values of the column PROJECT

try

	feldi_str	= sprintf('FIELD%1.0f',level);
	snmci_str	= sprintf('SNMC%1.0f',level);
	ri_str		= sprintf('R%1.0f',level);
	ci_str		= sprintf('C%1.0f',level);
	if dataset_no>=1
		value_str	= sprintf('DATASET_%1.0f',dataset_no);
	elseif dataset_no==0
		value_str	= 'PROJECT';
	else
		errormessage;
	end

	if ~isvarname(T.(feldi_str){i})
		errormessage(sprintf('Error in %s: Column FIELD%1.0f, row %1.0f.',filename,level,i+1));
	end
	if isnan(T.(ri_str)(i))
		zi	= 1;
	else
		zi	= T.(ri_str)(i);
	end
	if isnan(T.(ci_str)(i))
		si	= 1;
	else
		si	= T.(ci_str)(i);
	end
	if strcmp(T.(snmci_str){i},'N')
		% The field i is a number or matrix:
		command	= sprintf('%s.%s(%1.0f,%1.0f)',command,T.(feldi_str){i},zi,si);
	elseif strcmp(T.(snmci_str){i},'C')||strcmp(T.(snmci_str){i},'M')
		% The field i is a cell array:
		command	= sprintf('%s.%s{%1.0f,%1.0f}',command,T.(feldi_str){i},zi,si);
	else
		% The field i is a string:
		command	= sprintf('%s.%s',command,T.(feldi_str){i});
	end

	further_fields	= 1;
	if level+1>4
		further_fields	= 0;
	elseif ~iscell(T.(sprintf('FIELD%1.0f',level+1)))
		further_fields	= 0;
	elseif isempty(T.(sprintf('FIELD%1.0f',level+1)){i})
		further_fields	= 0;
	end
	if further_fields==1
		% There are further fields:
		[command]=extent_pp(T,i,level+1,command,filename,dataset_no);
	else

		% Assign the value:
		if strcmp(T.(snmci_str){i},'S')
			% The value is a string:
			command	= sprintf('%s = ''%s'';',command,double_apostrophe(T.(value_str){i}));
		elseif ~isnan(str2double(T.(value_str){i}))&&(strcmp(T.(snmci_str){i},'N')||strcmp(T.(snmci_str){i},'C'))
			% The value is a scalar:
			% command	= sprintf('%s = %g;',command,str2double(T.(value_str){i}));		% lower accuracy
			command	= sprintf('%s = %s;',command,T.(value_str){i});
		elseif ~isempty(str2num(T.(value_str){i}))&&strcmp(T.(snmci_str){i},'M')
			% The value is a vector or matrix:
			command	= sprintf('%s = [%s];',command,T.(value_str){i});
		elseif strcmp(T.(snmci_str){i},'C')
			% The value is a string:
			command	= sprintf('%s = ''%s'';',command,double_apostrophe(T.(value_str){i}));
		else
			errormessage(sprintf([...
				'Error in:\n',...
				'%s:\n',...
				'Line number %g:\n',...
				'%s'],filename,i+1,command));
		end

	end

catch ME
	errormessage('',ME);
end

