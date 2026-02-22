function maplab3d_build
% Automatic compilation of the MapLab3D app.

global VER SETTINGS SETTINGS_BEFORE_BUILD

% for testing:
global buildOpts buildResult packageOpts
buildOpts	= [];
buildResult	= [];
packageOpts	= [];

% --------------------------------------------------------------------------------------------------------------------
% These steps must be performed to make a build and a new release:

% Projekt parameters file:
% -	Reset changes of
%		-	project.projectname		My Project 1
%		-	project.filename			MP1
%		-	project.scale				100.000
% -	Reset Columns DATASET_2 (My Project 1) up to DATASET_4 (My Project 3)
% -	"name" keys to filter by:
%		name
%		alt_name
%		short_name
% -	Hide rows with Excel formulas
% -	Clear the other sheets


% Set current version number in:
% -	MapLab3D_ProjectParameters_x_x_x_x.xlsx						and
%		MapLab3D_ProjectParameters_x_x_x_x_Reference.xlsx			and
%		MapLab3D_ProjectParameters_x_x_x_x_Colors_Database.xlsx
%		-	File name
%		-	project.version_no
%		-	Save and Close all Excel files.
% -	Check the file set_version_number.m
% -	Appdesigner
%		-	maplab3d.Name			MapLab3D_x_x_x_x
%			maplab3d.Version		x.x
%		-	app.MapLab3D.Name		MapLab3D x.x.x.x
% -	CHANGELOG.md

% Documentation of the changes contained in the new version.

% Check the directories and filenames below.

% Run this file.

% Source Control:				Add untracked files to Source Control
%									Commit
% Matlab Branch Manager:	Commit and push changes in development
%									Set main as HEAD
%									Merge development with main (development does not exist any more)
%									Commit and push changes in main

% Create new release:
% Github:						Tag:					v1.0.0.3-beta
%									Release title:		MapLab3D 1.0.0.3 Public Beta
%									Release notes:		Download the MapLab3D_1_0_0_3_Public_Beta file to install and run the program. Installation instructions can be found [here](https://github.com/Akilth/MapLab3D/blob/main/README.md) and in the [Wiki](https://wiki.openstreetmap.org/wiki/MapLab3D).
% 
%															First published version
% 
%															or enter changelog
%									Upload the zip file
% Matlab Branch Manager:	New Tag:				v1.0.0.3-beta

% Matlab Branch Manager:	create new branch development, set development as HEAD
% Matlab:						Increase version numbers
% Matlab Branch Manager:	Commit and push changes in development


% --------------------------------------------------------------------------------------------------------------------
% Notes:

% Create .gitattributes file see:
% https://de.mathworks.com/help/releases/R2025a/matlab/matlab_prog/set-up-git-source-control.html
% https://de.mathworks.com/help/releases/R2025a/simulink/ug/enable-matlab-automerge.html

% --------------------------------------------------------------------------------------------------------------------

% Directories and Filenames:                               for example:
ProjectRootDir				= 'C:\Daten\Projekte\MapLab3D';	% C:\Daten\Projekte\MapLab3D\
SourceCodeSubDir			= 'SourceCode';						% C:\Daten\Projekte\MapLab3D\SourceCode\
SymbolsSubDir				= 'Symbols';							% C:\Daten\Projekte\MapLab3D\Symbols\
StandaloneSubDirShort	= 'StandaloneApp';					% C:\Daten\Projekte\MapLab3D\StandaloneApp_0_9_0_0\
BuildSubDir					= 'AppCompiler\Build';				% C:\Daten\Projekte\MapLab3D_Versions\AppCompiler\Build
PackageSubDir				= 'AppCompiler\Package';			% C:\Daten\Projekte\MapLab3D_Versions\AppCompiler\Package
ProjectBackupRootDir		= 'C:\Daten\Projekte\MapLab3D_Versions';
FileName_PP_str			= 'MapLab3D_ProjectParameters_%g_%g_%g_%g.xlsx';
FileName_PPRef_str		= 'MapLab3D_ProjectParameters_%g_%g_%g_%g_Reference.xlsx';
FileName_PPCol_str		= 'MapLab3D_ProjectParameters_%g_%g_%g_%g_Colors_Database.xlsx';

% Load version number VER
set_version_number;

% --------------------------------------------------------------------------------------------------------------------
% Set the SETTINGS to default values:
if isempty(SETTINGS_BEFORE_BUILD)
	% The last build has been finished:
	SETTINGS_BEFORE_BUILD	= set_settings('load');
end
SETTINGS							= set_settings('defaults');
SETTINGS.build_datetime		= datetime('now');
build_datevec					= datevec(SETTINGS.build_datetime);
set_settings('save',SETTINGS);

% --------------------------------------------------------------------------------------------------------------------
% Derived settings:
% Settings:            for example:
% ver_date_dirname	= 'V_0_9_0_0-20250805-084829'
ver_date_dirname		= sprintf('V_%g_%g_%g_%g-%04.0f%02.0f%02.0f-%02.0f%02.0f%02.0f',...
	VER.no1,VER.no2,VER.no3,VER.no4,...
	build_datevec(1),...
	build_datevec(2),...
	build_datevec(3),...
	build_datevec(4),...
	build_datevec(5),...
	build_datevec(6));
% ProjectBackupDir	= 'C:\Daten\Projekte\MapLab3D_Versions\V_0_9_0_0-20250805-084829'
ProjectBackupDir		= fullfile(ProjectBackupRootDir,ver_date_dirname);
% FileName_PP			= 'MapLab3D_ProjectParameters_0_9_0_0.xlsx'
FileName_PP				= sprintf(FileName_PP_str   ,VER.no1,VER.no2,VER.no3,VER.no4);
% FileName_PPRef		= 'MapLab3D_ProjectParameters_0_9_0_0_Reference.xlsx'
FileName_PPRef			= sprintf(FileName_PPRef_str,VER.no1,VER.no2,VER.no3,VER.no4);
% FileName_PPCol		= 'MapLab3D_ProjectParameters_0_9_0_0_Colors_Database.xlsx'
FileName_PPCol			= sprintf(FileName_PPCol_str,VER.no1,VER.no2,VER.no3,VER.no4);
% StandaloneSubDir	= 'StandaloneApp_0_9_0_0'
StandaloneSubDir		= sprintf('%s_%g_%g_%g_%g',StandaloneSubDirShort,VER.no1,VER.no2,VER.no3,VER.no4);
if ~isempty(VER.str_fn)
	StandaloneSubDir	= sprintf('%s%s',StandaloneSubDir,VER.str_fn);
end
% StandaloneDir
save_standalone_in_maplab3d_repo	= false;
if save_standalone_in_maplab3d_repo
	% Save the standalone directory together with the source code, it will be part of the repo:
	% StandaloneDir		= 'C:\Daten\Projekte\MapLab3D\StandaloneApp_0_9_0_0'
	StandaloneDir			= fullfile(ProjectRootDir,StandaloneSubDir);
else
	% Save the standalone directory not together with the source code, the repo will be smaller:
	% StandaloneDir		= 'C:\Daten\Projekte\MapLab3D_Versions\V_0_9_0_0-20250805-084829\StandaloneApp_0_9_0_0'
	StandaloneDir			= fullfile(ProjectBackupDir,StandaloneSubDir);
end

% Security checks:
if    ~isequal(exist(ProjectRootDir      ,'dir'),7)||...
		~isequal(exist(ProjectBackupRootDir,'dir'),7)
	% The project directory does not exist: cancel:
	disp('!!! ProjectRootDir does not exist. !!!');
	disp('!!!         Build canceled         !!!');
	return
end

% Delete files that are not needed:
filename		= fullfile(ProjectRootDir,SourceCodeSubDir,'diary.txt');
if exist(filename,'file')==2
	delete(filename);
end
filename		= fullfile(ProjectRootDir,SourceCodeSubDir,'errorlog_data.mat');
if exist(filename,'file')==2
	delete(filename);
end

% --------------------------------------------------------------------------------------------------------------------
% This function saves the reference project parameters in a mat file so		that the project parameters can be
% checked for completeness when loading a project file. The function must be executed once after creating
% new project parameters, should not be necessary here:
status		= save_ppref(...
	ProjectRootDir,...			% pathname_ppref_xlsx
	FileName_PPRef);				% filename_ppref_xlsx
if ~isequal(status,1)
	disp('!!! save_ppref canceled !!!')
	return
end

% --------------------------------------------------------------------------------------------------------------------
% Compile:

% Compile method:
% To get a new icon file, use compiler.build once (see below):
compile_method								= 'mcc';						% 'mcc' / 'compiler.build'

% Create target build options object, set build properties:
buildOpts	= compiler.build.StandaloneApplicationOptions(...
	fullfile(ProjectRootDir,SourceCodeSubDir,'maplab3d.mlapp'));
buildOpts.AdditionalFiles				= [...
	fullfile(ProjectRootDir,SourceCodeSubDir,"timer_errorfcn.m"),...
	fullfile(ProjectRootDir,SourceCodeSubDir,"timer_stopfcn.m"),...
	fullfile(ProjectRootDir,SourceCodeSubDir,"timer_timerfcn.m"),...
	fullfile(ProjectRootDir,SourceCodeSubDir,"osmfilter.exe"),...
	fullfile(ProjectRootDir,SourceCodeSubDir,"pp_ref.mat"),...
	fullfile(ProjectRootDir,SourceCodeSubDir,"settings.mat"),...
	fullfile(ProjectRootDir,SourceCodeSubDir,"symbols.mat")];
buildOpts.AutoDetectDataFiles			= true;
buildOpts.OutputDir						= fullfile(ProjectBackupRootDir,BuildSubDir);
buildOpts.ObfuscateArchive				= false;
buildOpts.Verbose							= true;
buildOpts.EmbedArchive					= true;
switch compile_method
	case 'mcc'
		buildOpts.ExecutableIcon		= fullfile(ProjectRootDir,SourceCodeSubDir,"MapLab3D_Logo_256x256_RGB.ico");
	case 'compiler.build'
		buildOpts.ExecutableIcon		= fullfile(ProjectRootDir,SourceCodeSubDir,"MapLab3D_Logo_400x400_RGB.png");
end
buildOpts.ExecutableName				= sprintf('MapLab3D_%g_%g_%g_%g',VER.no1,VER.no2,VER.no3,VER.no4);
buildOpts.ExecutableSplashScreen		= fullfile(ProjectRootDir,SourceCodeSubDir,"MapLab3D_Logo_400x400_RGB.png");
buildOpts.ExecutableVersion			= sprintf('%g.%g.%g.%g',VER.no1,VER.no2,VER.no3,VER.no4);
buildOpts.TreatInputsAsNumeric		= false;

% Delete the old contents of buildOpts.OutputDir:
listing		= dir(buildOpts.OutputDir);
for i=1:size(listing,1)
	if ~listing(i,1).isdir
		delete(fullfile(listing(i,1).folder,listing(i,1).name));
	end
end

% Build standalone application:
% 'compiler.build'	mcc -W 'main:MapLab3D_0_9_0_0,version=0.9.0.0' -T link:exe -d C:\Daten\Projekte\MapLab3D_Versions\AppCompiler\Build -v -a C:\Daten\Projekte\MapLab3D\SourceCode\timer_errorfcn.m -a C:\Daten\Projekte\MapLab3D\SourceCode\timer_stopfcn.m -a C:\Daten\Projekte\MapLab3D\SourceCode\timer_timerfcn.m -a C:\Daten\Projekte\MapLab3D\SourceCode\osmfilter.exe -a C:\Daten\Projekte\MapLab3D\SourceCode\pp_ref.mat -a C:\Daten\Projekte\MapLab3D\SourceCode\settings.mat -a C:\Daten\Projekte\MapLab3D\SourceCode\symbols.mat -Z autodetect -o MapLab3D_0_9_0_0 -r C:\Users\telearbeit\AppData\Local\Temp\tp777b2079_1238_4c7b_8333_66f960e27f2d\icon.ico C:\Daten\Projekte\MapLab3D\SourceCode\maplab3d.mlapp
% 'mcc'					mcc -W 'main:MapLab3D_0_9_0_0,version=0.9.0.0' -T link:exe -d C:\Daten\Projekte\MapLab3D_Versions\AppCompiler\Build -v -a C:\Daten\Projekte\MapLab3D\SourceCode\timer_errorfcn.m -a C:\Daten\Projekte\MapLab3D\SourceCode\timer_stopfcn.m -a C:\Daten\Projekte\MapLab3D\SourceCode\timer_timerfcn.m -a C:\Daten\Projekte\MapLab3D\SourceCode\osmfilter.exe -a C:\Daten\Projekte\MapLab3D\SourceCode\pp_ref.mat -a C:\Daten\Projekte\MapLab3D\SourceCode\settings.mat -a C:\Daten\Projekte\MapLab3D\SourceCode\symbols.mat -Z autodetect -o MapLab3D_0_9_0_0 -r C:\Daten\Projekte\MapLab3D\SourceCode\MapLab3D_Logo_256x256_RGB.ico -R '-logfile,MapLab3D_0_9_0_0_log.txt' C:\Daten\Projekte\MapLab3D\SourceCode\maplab3d.mlapp
switch compile_method
	case 'mcc'
		% with:			log file
		% without:		buildOpts.ExecutableSplashScreen
		% see:			https://de.mathworks.com/help/compiler/mcc.html
		% logfile see: https://de.mathworks.com/matlabcentral/answers/2133916-where-is-the-log-file-created-when-the-option-is-selected-in-additional-runtime-settings-in-matlab-c
		%					https://de.mathworks.com/matlabcentral/answers/384954-creating-a-runtime-log-for-deployed-application
		command		= 'mcc';
		% -W Standalone Application (with Windows console):
		% command		= sprintf('%s -m ''maplab3d''',command);
		command		= sprintf('%s -W ''main:%s,version=%g.%g.%g.%g'' -T link:exe',...
			command,buildOpts.ExecutableName,VER.no1,VER.no2,VER.no3,VER.no4);
		% -d: Output folder:
		command		= sprintf('%s -d %s',command,buildOpts.OutputDir);
		% -v: Display verbose output:
		command		= sprintf('%s -v',command);
		% -a: Add files or folder to the deployable archive:
		for i=1:size(buildOpts.AdditionalFiles,1)
			command	= sprintf('%s -a %s',command,buildOpts.AdditionalFiles{i,1});
		end
		% -Z: Specify the method of adding support packages:
		command		= sprintf('%s -Z autodetect',command);
		% -o: name of the final executable of a standalone application:
		command		= sprintf('%s -o %s',command,buildOpts.ExecutableName);
		% -r: icon resource:
		command		= sprintf('%s -r %s',command,buildOpts.ExecutableIcon);
		% -R: Runtime options: log file:buildOpts.ExecutableName
		command		= sprintf('%s -R ''-logfile,%s_log.txt''',command,buildOpts.ExecutableName);
		% mfilename: File to be compiled
		command		= sprintf('%s %s',command,fullfile(ProjectRootDir,SourceCodeSubDir,'maplab3d.mlapp'));
		disp(command);
		eval(command);
		% Create package options object:
		packageOpts = compiler.package.InstallerOptions("ApplicationName",buildOpts.ExecutableName);
	case 'compiler.build'
		% without:		log file
		% with:			buildOpts.ExecutableSplashScreen
		% see:			https://de.mathworks.com/help/compiler/compiler.build.standaloneapplication.html
		%
		% During this command, the directory containing the icons is created and then deleted again:
		% C:\Daten\Projekte\MapLab3D\StandaloneApp\Build\MapLab3D_x_x_x_x_resources
		% Copy the directory during this time to obtain the icon files for mcc!
		% This is only necessary if the icon has been changed.
		buildResult = compiler.build.standaloneApplication(buildOpts);
		% Create package options object:
		packageOpts	= compiler.package.InstallerOptions(buildResult);
end

% --------------------------------------------------------------------------------------------------------------------
% Package:

% Set package properties:
ApplicationExe								= sprintf('%s.exe',buildOpts.ExecutableName);		% 'MapLab3D_x_x_x_x.exe'
packageOpts.OutputDir					= fullfile(ProjectBackupRootDir,PackageSubDir);
ApplicationExeFull						= fullfile(buildOpts.OutputDir,ApplicationExe);
packageOpts.ApplicationName			= buildOpts.ExecutableName;
packageOpts.AuthorName					= "";
packageOpts.DefaultInstallationDir	= sprintf('%%ProgramFiles%%/%s',buildOpts.ExecutableName);
packageOpts.Description					= [...
	'MapLab3D is a tool for creating 3D models of maps in STL format from freely available ',...
	'OpenStreetMap data and elevation data, which can be printed on 3D printers.'];
packageOpts.InstallerIcon				= fullfile(ProjectRootDir,SourceCodeSubDir,"MapLab3D_Logo_400x400_RGB.png");
packageOpts.InstallerLogo				= fullfile(ProjectRootDir,SourceCodeSubDir,"MapLab3D_Logo_112x290_RGB.png");
packageOpts.InstallerName				= sprintf('%s_WebInstaller',buildOpts.ExecutableName);
packageOpts.InstallerSplash			= fullfile(ProjectRootDir,SourceCodeSubDir,"MapLab3D_Logo_400x400_RGB.png");
packageOpts.AddRemoveProgramsIcon	= fullfile(ProjectRootDir,SourceCodeSubDir,"MapLab3D_Logo_400x400_RGB.png");
packageOpts.Summary						= "3D printing of relief maps";
packageOpts.Verbose						= true;
packageOpts.Version						= sprintf('%g.%g.%g.%g',VER.no1,VER.no2,VER.no3,VER.no4);
packageOpts.Shortcut						= ApplicationExeFull;

% Delete the old contents of packageOpts.OutputDir:
listing		= dir(packageOpts.OutputDir);
for i=1:size(listing,1)
	if ~listing(i,1).isdir
		delete(fullfile(listing(i,1).folder,listing(i,1).name));
	end
end

% Package standalone application:
switch compile_method
	case 'mcc'
		% % Warning: Using "requiredMCRProducts.txt" as an input will not be supported in a future release.
		% % Use "buildresults.json" instead.
		% RequiredMCRProductsFull	= fullfile(buildOpts.OutputDir,"requiredMCRProducts.txt");
		RequiredMCRProductsFull	= fullfile(buildOpts.OutputDir,"buildresult.json");
		compiler.package.installer(...
			ApplicationExeFull,...				% List of files and folders for installation
			RequiredMCRProductsFull,...		% Path to the requiredMCRProducts.txt file generated by MATLAB Compiler
			"Options",packageOpts);			% Installer options
	case 'compiler.build'
		compiler.package.installer(buildResult,"Options",packageOpts);
end


% --------------------------------------------------------------------------------------------------------------------
% Create release:

% Create or Rename the standalone directory:
if save_standalone_in_maplab3d_repo
	% Save the standalone directory together with the source code, it will be part of the repo:
	listing		= dir(ProjectRootDir);
	i_v			= false(size(listing,1),1);
	for i=1:size(listing,1)
		if listing(i,1).isdir
			k		= strfind(listing(i,1).name,StandaloneSubDirShort);
			if isequal(k,1)
				i_v(i,1)		= true;
			end
		end
	end
	i_v			= find(i_v);
	status		= 0;
	msg			= '';
	msgID			= '';
else
	% Save the standalone directory not together with the source code, the repo will be smaller:
	i_v			= [];
end
if isscalar(i_v)
	% There exists one old standalone directory: rename it:
	folderName_old			= fullfile(listing(i_v,1).folder,listing(i_v,1).name);
	if ~isequal(folderName_old,StandaloneDir)
		[status,msg,msgID]	= movefile(folderName_old,StandaloneDir);
	else
		status					= 1;
	end
elseif isempty(i_v)
	% There exists no old standalone directory: create it:
	[status,msg,msgID]		= mkdir(StandaloneDir);
else
	msg						= sprintf('It was not possible to rename folder %s',StandaloneDir);
end
if ~isequal(status,1)
	disp(msg)
	disp(msgID)
	disp('!!! Creating/renaming standalone directory canceled !!!')
	return
end

% Delete the old contents of StandaloneDir:
listing		= dir(StandaloneDir);
for i=1:size(listing,1)
	if ~listing(i,1).isdir
		delete(fullfile(listing(i,1).folder,listing(i,1).name));
	end
end

% Create the release zip file:
% zipfilename = 'C:\Daten\Projekte\MapLab3D\StandaloneApp_x_x_x_x\Release\MapLab3D_x_x_x_x'
% filenames   =
% {'C:\Daten\Projekte\MapLab3D\Symbols'                                                        }
% {'C:\Daten\Projekte\MapLab3D\StandaloneApp_0_9_0_0\Package\MapLab3D_0_9_0_0_WebInstaller.exe'}
% {'C:\Daten\Projekte\MapLab3D\MapLab3D_ProjectParameters_0_9.xlsx'                            }
% {'C:\Daten\Projekte\MapLab3D\MapLab3D_ProjectParameters_0_9_Reference.xlsx'                  }
% {'C:\Daten\Projekte\MapLab3D\MapLab3D_ProjectParameters_colors_database.xlsx'                }
zipfilename		= fullfile(StandaloneDir,[buildOpts.ExecutableName VER.str_fn]);
filenames		= {...
	fullfile(ProjectRootDir,SymbolsSubDir),...
	fullfile(packageOpts.OutputDir,[packageOpts.InstallerName '.exe']),...
	fullfile(ProjectRootDir,FileName_PP),...
	fullfile(ProjectRootDir,FileName_PPRef),...
	fullfile(ProjectRootDir,FileName_PPCol)};
zip(zipfilename,filenames);

% --------------------------------------------------------------------------------------------------------------------
% Create backup:
[status,msg,msgID] = copyfile(ProjectRootDir,ProjectBackupDir);
if ~isequal(status,1)
	disp(msg)
	disp(msgID)
	disp('!!! Backup canceled !!!')
	return
end

% --------------------------------------------------------------------------------------------------------------------
% Restore the settings:
SETTINGS							= SETTINGS_BEFORE_BUILD;
SETTINGS_BEFORE_BUILD		= [];
set_settings('save',SETTINGS);

% --------------------------------------------------------------------------------------------------------------------
disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
disp('!!!!!!!!!!!!!!!!!!!!!!!        COMPILATION SUCCESSFUL         !!!!!!!!!!!!!!!!!!!!!!!')
disp('!!!!!!!!!!!!!!!!!!!!!!!          NOW PUSH AND THEN            !!!!!!!!!!!!!!!!!!!!!!!')
disp('!!!!!!!!!!!!!!!!!!!!!!!      INCREASE THE VERSION NUMBER      !!!!!!!!!!!!!!!!!!!!!!!')
disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')

