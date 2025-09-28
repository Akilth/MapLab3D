# CHANGELOG

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Version numbering follows these rules:
1. Major: Significant changes
2. Minor: Functional improvement. If changes are made in numbers 1 or 2, old project saves can no longer be loaded and 
the project parameters may need to be edited.
3. Minor: Minor functional improvement that does not affect project parameters or project saves.
4. Bug fix maintenance release number.

## [Unreleased]

### Added

- "Menu: Extra - Convert georaster data":
If a bounding box is extracted and the source data is in .mat format, only the relevant files are loaded based on 
their file names. This significantly speeds up the extraction of a bounding box.
The recommended procedure is as follows:
	1) Download the elevation data for a large area in GeoTIFF format, for example a whole contry
	2) Convert the GeoTIFF files into individual .mat files.
	3) Extract sub-areas for specific projects.

- New option: "Menu: Extra - Convert georaster data: Settings - Replace missing data with zeros".
This allows the creation of a complete mat file with elevation data if GeoTIFF files of areas above sea level are 
missing.

### Changed

- Various changes in the project parameter file to prepare for printing maps of a large area.

- Connecting ways into a longer line when executing "Menu: Create map":  
	- First step: The direction of ways when connecting them into a longer line is no longer reversed as before if 
the endpoints or starting points of two ways are identical.
At junctions, individual ways are connected to form the longest possible line. This ensures that a continuous line 
is created, important for the representation of rivers with variable line widths.
	- Second step: After that, the remaining lines are connected if two start points or two end points are identical.

### Removed

### Fixed

- In dark mode, context menus were incorrectly displayed in light colors, as was some of the text, making it 
unreadable. In this case, the text is now dark and therefore readable.

- "Menu: Create map": Fixed crash in case a relation contains no data.

- "Tab: Filter OSM-data - Copy table to clipboard": Crash fixed

## [1.0.0.3 Public Beta] - 2025-08-28

First published version

[Unreleased]: https://github.com/Akilth/MapLab3D/compare/v1.0.0.3-beta...HEAD
[1.0.0.3 Public Beta]: https://github.com/Akilth/MapLab3D/releases/tag/v1.0.0.3-beta

