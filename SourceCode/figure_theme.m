function fig_settings=figure_theme(fig,action,fig_settings,fig_theme)
% Set and reset figure theme.
% -	After creating the figure or after clf(fig,'reset'):
%		figure_theme(fig,'set',[],'light');
% -	For saving into file:
%		fig_settings=figure_theme(fig,'set',[],'light');
%		print(fig,...);
%		figure_theme(fig,'reset',fig_settings);


switch action
	case 'set'
		fig_settings					= [];
		if isprop(fig,'Theme')
			fig_settings.fig.Theme	= fig.Theme;
			fig.Theme						= fig_theme;
		end
	case 'reset'
		if ~isempty(fig_settings)&&isprop(fig,'Theme')
			fig.Theme						= fig_settings.fig.Theme;
		end
	otherwise
		errormessage;
end









