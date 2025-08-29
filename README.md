## Overview

MapLab3D is a tool for creating 3D models of maps in STL format from freely available [OpenStreetMap](https://www.openstreetmap.org) data and [elevation data](https://earthexplorer.usgs.gov/) which can be printed on 3D printers without further processing. No other CAD tool is required.

### Applications

One possible application is in school lessons, as many schools already have 3D printers and can produce their own 3D relief maps for geography lessons. A 3D puzzle makes learning geography more fun. The map data can either be downloaded ready-made or created as part of projects and then made available to the general public, which also has a learning effect.

Other applications include use as a tactile map for people who are blind, tourism advertising (e. g., to show hiking trails or ski areas or to plan bike tours), a map in front of the town hall (printed in weatherproof metal), or even just as a puzzle game or for decorative purposes at home.

### Overview of the features

The data in OpenStreetMap is shown as:

 - Lines with different line styles (roads, railways, rivers, borders, etc.)
- Areas (buildings, forests, regions, etc.)
 - Text with freely selectable fonts (city names, elevation points, etc.)
- Symbols (freely definable)

 The maps can be monochrome or multicolored. For multicolored maps, there are two options:
- The map objects are printed one after the other in different colors and then fitted together like a puzzle.
- Selected colors can be printed simultaneously with other underlying colors. This requires either a dual-extruder 3D printer or a multi-material 3D printer.

Large maps can be made up of several regular tiles so you're not limited by the build space of the 3D printer. For multi-color maps, the pieces can be split up anywhere if they're too big or if you want smaller puzzle pieces.

The layout settings are made in an MS Excel file. With the default settings, quick success should be possible with just a few adjustments. However, it is possible that the optimal settings may vary from country to country, in which case further adjustments to the project parameters will be necessary. This also applies if new map objects are to be displayed, such as specific hiking trails with the corresponding hiking symbols. In this case, more intensive study of the [OpenStreetMap tags](https://wiki.openstreetmap.org/wiki/Map_features), the project parameters, and the use of MapLab3D is necessary.

Overview of the steps required to create a map:

- Import the project parameter file
- Download and import OpenStreetMap data and elevation data for the desired area
- Generate a 2D view of the map, which serves as the editing area
- Editing map objects, for example, in the case of text:
	- Move
	- Rotate
	- Show and hide
	- Change the text and font
	- Test for mutual overlap
- Generate the STL data for the map and for a frame
- Print on a 3D printer and assemble

The app has come a long way and crashes much less frequently than it did at the beginning, but development of the app and the project parameter file is still an ongoing process. Because map generation works relatively reliably, the current version has been released as a beta version. Users are invited to test the app and report bugs and suggestions for improvement.

## Requirements

- Basic computer skills are required, such as installing programs, creating directories, and copying files.
- Supported operating systems: Windows. Other operating systems have not been tested.
- MS Excel for editing project parameters and knowledge of how to use it. The project parameters may also be imported into MapLab3D after conversion to .ods format (Open Office or LibreOffice, freely available, not tested).
- The add-on program [Osmosis](https://wiki.openstreetmap.org/wiki/Osmosis) for editing large OpenStreetMap datasets. Osmosis is supported by MapLab3D by automatically generating the execution command. There are also other programs that can be used to prepare OpenStreetMap data, e.g. [Osmium](https://wiki.openstreetmap.org/wiki/Osmium).
- A mouse with 3 buttons for multiple selection of map objects.
- When editing large OpenStreetMap datasets, the size of the RAM memory can matter.
- A fast CPU is helpful, as some functions can take a long time.
- A large screen is helpful for editing the map layout.
- A 3D printer.


## Installation

The current version can be downloaded [here](https://github.com/Akilth/MapLab3D/releases). The package contains the following files:
- The installation program **MapLab3D_x_x_x_x_WebInstaller.exe**: When executed, MapLab3D is installed on the computer. If necessary the MATLAB Runtime is also downloaded from the Internet and installed.
- The directory **\Symbols**: This directory contains the source data for the predefined map symbols. You can add your own symbols to this directory and then import them into MapLab3D.
- The project parameters file **MapLab3D_ProjectParameters_x_x_x_x.xlsx**: This file contains all parameters that affect the map layout and is imported into the app in the first step of map creation.
- **MapLab3D_ProjectParameters_x_x_x_x_Reference.xlsx**: This file contains a more detailed explanation of all project parameters. It is not imported into MapLab3D, but serves only as a reference.
- **MapLab3D_ProjectParameters_x_x_x_x_Colors_Database.xlsx**: Here you can store data for different colors (for example, filaments for FDM printers) that are not currently in use.

In addition, a program for editing OpenStreetMap data should be installed. The recommended program is [Osmosis](https://wiki.openstreetmap.org/wiki/Osmosis).

You also need map data to use the app:
- Examples of sources for OpenStreetMap data:
	- [https://www.openstreetmap.org/export](https://www.openstreetmap.org/export) (only small areas)
	- [https://download.geofabrik.de](https://download.geofabrik.de)
	- Smaller sections extracted using [Osmosis](https://wiki.openstreetmap.org/wiki/Osmosis).
- A possible source for elevation data is: [https://earthexplorer.usgs.gov/](https://earthexplorer.usgs.gov/). Download the digital SRTM (Shuttle Radar Topography Mission) elevation data in GeoTIFF format.

The following directory structure is recommended for storing the data:

```
MapLab3D            →  Insert the MS Excel files from the downloaded 
│                      package here.
│                      The data directory should not be the same as the
│                      installation location of the app, because the data
│                      will also be deleted when the app is uninstalled.
├─ MyProject_01     →  Project directory
│  │                   Insert a copy of the project parameters file 
│  │                   (MapLab3D_ProjectParameters_x_x_x_x.xlsx)
│  │                   here to make project-specific changes. Project
│  │                   save states and log files are also stored here.
│  ├─ OSM           →  Reduced OSM dataset in OSM XML format (.osm):
│  │                   - Only the map area required for the project.
│  │                   - Possibly only the map content required for the
│  │                     project.
│  ├─ SRTM_GeoTIFF  →  Optional: Elevation data in GeoTIFF format
│  ├─ SRTM_mat      →  Optional: Elevation data converted to .mat format
│  ├─ STL           →  Created automatically
│  │                   STL data and preview files
│  └─ STL_repaired  →  Created automatically 
│                      repaired STL data: use for printing
├─ MyProject_02     →  Another project
│  ├─ OSM
│  ├─ STL
│  └─ STL_repaired
├─ OSM              →  Large OpenStreetMap datasets downloaded from the
│                      Internet from which sections can be extracted for
│                      specific projects.
├─ SRTM_GeoTIFF     →  GeoTIFF elevation data.
│  │                   - When importing elevation data into MapLab3D, you
│  │                     must select a directory that contains the elevation
│  │                     data for the desired area. For large areas, this
│  │                     may involve multiple files. All files contained in
│  │                     this directory will then be imported.
│  │                     The elevation data for different maps must
│  │                     therefore be stored in separate subdirectories.
│  │                   - Due to the high storage requirements for large
│  │                     areas, it may be a good idea to store elevation
│  │                     data only once rather than multiple times under
│  │                     individual projects. A set of elevation data can
│  │                     be used for multiple projects.
│  ├─ Heidelberg
│  ├─ Berlin
│  └─ Germany
├─ SRTM_mat         →  Elevation data converted to .mat format
│  │                   (this is possible with MapLab3D).
│  │                   Importing this format into MapLab3D is faster.
│  ├─ Heidelberg
│  ├─ Berlin
│  └─ Germany
├─ Symbols          →  Paste the contents of the ..\Symbols directory from
│                      the downloaded package here.
└─ Testsamples      →  MapLab3D can generate print data for various test
                       samples, such as text samples for testing font
                       settings or color samples for easier color selection.
```

## Get started

Detailed instructions can be found in the OpenStreetMap Wiki: [MapLab3D Wiki](https://wiki.openstreetmap.org/wiki/MapLab3D). The page is still under construction. A possible starting point is to follow the [Example projects](https://wiki.openstreetmap.org/wiki/MapLab3D#Example_projects) with explanations to learn the basic procedure. 

A more detailed description of individual project parameters can be found in the file MapLab3D_ProjectParameters_x_x_x_x_Reference.xlsx, which is downloaded together with the WebInstaller.

## History

The project began with student research projects in the electrical engineering program at the Baden-Wuerttemberg Cooperative State University (DHBW) in Mannheim, supervised by [Andreas Kilthau](https://github.com/Akilth):
- A feasibility study was conducted in early 2020
- The programming project was started during the first coronavirus lockdown in 2020, when the laboratories were closed and the student research projects had to be carried out at home. This allowed students to practice the MATLAB skills they had learned in the previous semester.
- From 2022, the project was continued by [Andreas Kilthau](https://github.com/Akilth).
- In 2023, a 3D-printed map was exhibited at the German National Garden Show (“Bundesgartenschau”) in Mannheim at the DHBW stand ([exhibit](https://www.printables.com/education/502996-3d-printing-of-maps-by-combining-openstreetmap-dat)).
- In 2025, the app was released as a public beta version.
- Along with the release of the app, [Kristian Kahl](https://wiki.openstreetmap.org/wiki/User:Kristian.Kahl) created a user manual in the OpenStreetMap Wiki, which he has been continuously expanding and updating since then: [MapLab3D Wiki](https://wiki.openstreetmap.org/wiki/MapLab3D).

## Development

MapLab3D is written in MATLAB. Almost all functions are commented in English, with a few exceptions.

MATLAB program version and required add-ons:
- MATLAB version: 2025a
- Mapping Toolbox
- Image Processing Toolbox
- Matlab Compiler

The following settings should be made in MATLAB Preferences under Editor/Debugger - Tab:
- Tab size: 3
- Indent size: 3
- Tab key inserts spaces: off

The source code path should be added to the MATLAB path in order to run the app maplab3d.mlapp in the MATLAB environment. The standalone version is created using the maplab3d_build.m function.

## Contributing

The original author [Andreas Kilthau](https://github.com/Akilth) currently plans to continue developing the app under the name of the Baden-Wuerttemberg Cooperative State University (DHBW) in Mannheim, possibly with the help of additional student work. Users are invited to contribute in the following ways:
- Test the app, report bugs, and make suggestions for improvement ([Issues](https://github.com/Akilth/MapLab3D/issues)).
- Create 3D maps and make them available for download, for example on [Thingiverse](https://www.thingiverse.com), [Printables](https://www.printables.com) or [Cults](https://cults3d.com) or [Cults Category Maps](https://cults3d.com/en/categories/maps). The name of the app should be included in the tags so that maps created with MapLab3D can be easily searched for. Possible tags are:
	- maplab3d
	- map
	- 3D map
	- relief map
	- topographic map
	- relief
	- topography
	- terrain
	- geography
	- puzzle
	- jigsaw
- Edit the [MapLab3D Wiki](https://wiki.openstreetmap.org/wiki/MapLab3D) or translate it into another language.
- Selected maps can be presented in [Example projects](https://wiki.openstreetmap.org/wiki/MapLab3D#Example_projects) together with instructions in the wiki.

## License

```
(C) 2020 Andreas Kilthau

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see https://www.gnu.org/licenses/.
```


