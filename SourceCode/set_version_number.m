function set_version_number
% Version number:
% 
% The version number sequence of the app consists of 4 individual parts: 1.2.3.4
% 1: Major: Significant changes to the program.
% 2: Minor: Functional improvement of the program
% 3: Minor: Minor functional improvement to the program that does not affect
%           project parameters or project saves. Therefore, only the first two
%           numbers need to be entered here.
% 4: Bug fix maintenance release number.
% 
% Increase the version number by 1 or 2 if any of these variables have been changed:
% -  PP
% -  GV
% -  ELE
% -  OSMDATA
% -  MAP_OBJECTS
% -  PLOTDATA
% -  PRINTDATA
% -  MATLAB version

global VER

% Numeric version numbers:
% https://de.wikipedia.org/wiki/Versionsnummer
% https://en.wikipedia.org/wiki/Software_versioning
VER.no1		= 1;
VER.no2		= 1;
VER.no3		= 0;
VER.no4		= 1;

% Optional alphanumeric identifier:
% https://de.wikipedia.org/wiki/Entwicklungsstadium_(Software)
% https://en.wikipedia.org/wiki/Software_release_life_cycle
VER.str		= ' - Public Beta';			% Text added to the version number
VER.str_fn	= '_Public_Beta';				% File name extension
% Example: VER.str    = '  - Public Beta'  ==>  Version is displayed as '1.0.0.0 - Public Beta'
% Example: VER.str    = ''                 ==>  Version is displayed as '1.0.0.0'
% Example: VER.str_fn = '_Public_Beta'     ==>  Filename is 'MapLab3D_1_0_0_0_Public_Beta.zip'
% Example: VER.str_fn = ''                 ==>  Filename is 'MapLab3D_1_0_0_0.zip'



