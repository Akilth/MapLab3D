function savefigasmat(fig,pathfilename)
% Saves the data of the axes and plots contained in a figure in the data structure,
% which can be used to recreate the figure.
% data.figdata.(p{ip,1})								-->	figure properties
% data.ax(ia,1).axdata.(p{ip,1})						-->	axis properties
% data.ax(ia,1).axch(iac,1).axchdata.(p{ip,1})	-->	plot properties
% 
% Some properties currently are not saved, for example: Annotation, ContextMenu, Theme, Legend, Axis labels


try
	
	% Initialization:
	data		= [];
	if length(pathfilename)>4
		if strcmp(pathfilename((end-3):end),'.fig')
			pathfilename((end-3):end)	= '.mat';
		end
		if ~strcmp(pathfilename((end-3):end),'.mat')
			pathfilename	= [pathfilename '.mat'];
		end
	else
		pathfilename	= [pathfilename '.mat'];
	end
	
	% Figure properties:
	p		= properties(fig);
	for ip=1:size(p,1)
		if    ~strcmp(p{ip,1},'Children')&&...
				~strcmp(p{ip,1},'ContextMenu')&&...
				~strcmp(p{ip,1},'Theme')&&...
				~strcmp(p{ip,1},'CurrentAxes')&&...
				~strcmp(p{ip,1},'CurrentObject')&&...
				~strcmp(p{ip,1},'CurrentCharacter')&&...
				~strcmp(p{ip,1},'Parent')
			data.figdata.(p{ip,1})		= fig.(p{ip,1});
		end
	end
	
	% Axis data:
	figch		= fig.Children;										% Assign the children handles only once: much faster!
	ia			= 0;
	for ifigch=1:size(figch,1)
		if strcmp(figch(ifigch,1).Type,'axes')
			ia		= ia+1;
			ax		= figch(ifigch,1);
			
			% Axis properties:
			p		= properties(ax);
			for ip=1:size(p,1)
				if    ~strcmp(p{ip,1},'Children')&&...
						~strcmp(p{ip,1},'ContextMenu')&&...
						~strcmp(p{ip,1},'InteractionOptions')&&...
						~strcmp(p{ip,1},'Interactions')&&...
						~strcmp(p{ip,1},'Layout')&&...
						~strcmp(p{ip,1},'Legend')&&...
						~strcmp(p{ip,1},'Parent')&&...
						~strcmp(p{ip,1},'Toolbar')&&...
						~strcmp(p{ip,1},'XAxis')&&...
						~strcmp(p{ip,1},'XLabel')&&...
						~strcmp(p{ip,1},'YAxis')&&...
						~strcmp(p{ip,1},'YLabel')&&...
						~strcmp(p{ip,1},'ZAxis')&&...
						~strcmp(p{ip,1},'ZLabel')
					data.ax(ia,1).axdata.(p{ip,1})		= ax.(p{ip,1});
				end
			end
			
			% Axis children:
			axch	= ax.Children;										% Assign the children handles only once: much faster!
			for iac=1:size(axch,1)
				
				% Axis children properties:
				p		= properties(axch(iac,1));
				for ip=1:size(p,1)
					if    ~strcmp(p{ip,1},'Children')&&...
							~strcmp(p{ip,1},'Annotation')&&...
							~strcmp(p{ip,1},'ContextMenu')&&...
							~strcmp(p{ip,1},'Parent')
						data.ax(ia,1).axch(iac,1).axchdata.(p{ip,1})		= axch(iac,1).(p{ip,1});
					end
				end
				
			end
			
		end
	end
	
	% Save figure as mat file:
	save(pathfilename,'data');
	
catch ME
	errormessage('',ME);
end
