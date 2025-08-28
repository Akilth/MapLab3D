function programming_hints

%------------------------------------------------------------------------------------------------------------------
% Notes:

% The name "height" has various meanings in the app:
% - Height in the z-direction in three-dimensional space: for example letterheight
% - Height of a figure or a button in the two-dimensional plane: for example Figure height: 
%   Distance between the top and bottom inner edges of the window.
% - In 2D plots, the dimension in the y-direction is also referred to as height in the code, 
%   which is actually the depth in three-dimensional space. Example:
%   Tile dimension in y-direction:
%   Code: height (not visible to the user)
%   App surface: depth (visible to the user)

%------------------------------------------------------------------------------------------------------------------
% Create figure: always assign this tag (after "clf(hf,'reset');"):
set(hf,'Tag','maplab3d_figure');

% Set the figure theme to light:
figure_theme(hf,'set',[],'light');

% Set the figure theme to light before exporting:
fig_settings=figure_theme(hf,'set',[],'light');
print / copygraphics / exportgraphics / saveas / savefig
figure_theme(hf,'reset',fig_settings);

% Always use 'WindowStyle'='normal' (open in a standalone window, not docked):
set(0,'DefaultFigureWindowStyle','normal');
% or:
% figure:
hf		= figure('WindowStyle','normal');	% standalone window
% figure:
hf					= 1234;
hf					= figure(hf);
hf.WindowStyle	= 'normal';						% standalone window
% openfig:
hf		= openfig([fig_pathname fig_filename],'invisible');
set(hf,'WindowStyle','normal');				% open in a standalone window (not docked)
set(hf,'Tag','maplab3d_figure');
set(hf,'Visible','on');


%------------------------------------------------------------------------------------------------------------------
% Always use ME after catch, otherwise a second error dialog box will be opened here
try
catch ME
	errormessage('',ME);
end

%------------------------------------------------------------------------------------------------------------------
% Insert try/catch:c
% in all callbacks that are called by the app (for example by buttons) and also 
% in other callbacks such as those from the following objects:
uicontextmenu	% Create context menu component
uimenu			% Create menu or menu items
dragrect			% Drag rectangles with mouse
rbbox				% Create rubberband box for area selection
refresh			% Redraw current figure
shg				% Show current figure

% The names of the callbacks are for example:
MenuSelectedFcn
ButtonDownFcn
SizeChangedFcn
TimerFcn
ErrorFcn
StopFcn

% Therefore, try/catch statements must be inserted in the following functions, for example:
ax_2dmap_zoom
plot_modify
ButtonDownFcn_ax_2dmap
SizeChangedFcn_fig_2dmap
timer_timerfcn
timer_errorfcn
timer_stopfcn

% In this way, the buttons are reactivated after all errors.
% However, the error log then usually only contains the workspace of the calling callback in the app designer,
% i.e. it does not contain any data. Therefore, a try/catch block must also be inserted in all other functions.
% Insert try/catch in ALL functions (also subfunctions)!
% With these functions, the try/catch block is placed around the call:
% Note that the global variables defined in the function must also be defined globally outside!
get_T_margin
map2stl_preparation
map2stl_topside_triangulation
map2stl_botside_triangulation

% No try/catch in errormessage.m


%------------------------------------------------------------------------------------------------------------------
% Switch off warnings:

w = warning('query','last')

if GV.warnings_off
	warning('off','MATLAB:polyshape:boundary3Points');				% polyshape
	warning('off','MATLAB:polyshape:repairedBySimplify');			% polyshape
	warning('off','MATLAB:triangulation:PtsNotInTriWarnId');		% triangulation
end
% Code
if GV.warnings_off
	warning('on','MATLAB:polyshape:boundary3Points');
	warning('on','MATLAB:polyshape:repairedBySimplify');
	warning('on','MATLAB:triangulation:PtsNotInTriWarnId');		% triangulation
end

%------------------------------------------------------------------------------------------------------------------
% Check if data is loaded or ready:

if isempty(PP)
	errortext	= sprintf([...
		'The project parameters have not yet been loaded.\n',...
		'First load the project parameters.']);
	errormessage(errortext);
end

if isempty(MAP_OBJECTS)
	errortext	= sprintf([...
		'The map has not yet been created.\n',...
		'First create the map.']);
	errormessage(errortext);
end

if isempty(ELE)||isempty(GV)||isempty(PP)
	errormessage(sprintf(['Error:\n',...
		'Before creating a OSM raw data preview,\n',...
		'you have to load the OSM and elevation data.']));
end

%------------------------------------------------------------------------------------------------------------------
% Names:
MATLAB
MapLab3D
event display
signal lamp













