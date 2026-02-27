# CHANGELOG

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Version numbering follows these rules:
1. Major: Significant changes
2. Minor: Functional improvement. If changes are made in numbers 1 or 2, old project saves can no longer be loaded and 
the project parameters may need to be edited.
3. Minor: Minor functional improvement that does not affect project parameters or project saves.
4. Bug fix maintenance release number.

## Known issues

- Sometimes a text map object is significantly too large. This error can be fixed by changing the text or the font 
(open the context menu by left-clicking and then right-clicking on the text object).

- This version is not suitable for large maps with many map objects, e.g., a map of an entire state. 
It may happen that a saved project can no longer be loaded.

## [Unreleased]

### Added

### Changed
- A separate source plot (displayed as a magenta line when selecting texts and symbols) is no longer created for 
each text and symbol, but only one source plot for multiple texts and symbols with the same source data. 
In addition, the resolution of the source plots can be reduced using the parameters obj.textpar.dmin_source and 
obj.symbolpar.dmin_source. This reduces the memory requirements for project saving.

### Removed

### Fixed
- If the 2D map is saved with contour lines, these will be visible again after the project is loaded. 
The checkbox in the menu is set accordingly.

## [1.1.0.1 Public Beta] - 2026-02-22

### Fixed

- When selecting texts or symbols, the magenta-colored source data was no longer displayed.

## [1.1.0.0 Public Beta] - 2026-02-22

### Added

- New testsample: "Menu: File - Create test sample STL files - Create character style sample STL files"

- If all parts of a color assigned to the same tile are larger than the project parameters 
colorspec.cut_into_pieces.maxdimx and
colorspec.cut_into_pieces.maxdimy, 
they are split into different files. This allows printing without having to move the parts on the printing plate. 
This may be necessary for multi-material printing.

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

- With the setting "Tab: Edit map - Advanced - Preview (L/P) - Off," multiple objects can be selected by 
clicking and dragging with the mouse (instead of clicking on the objects individually).

- 2D map context menu (left-click on a map object with a right-click at the same position): 
The context menu of a map object now also displays the IDs and tags of the associated OSM objects.

- Button "Tab: Edit map - Basic - Select" now also selects preview lines and preview polygons.

- Added button "Tab: Edit map - Basic - Change text/tag"

- Added button "Tab: Edit map - Basic - Hide all" and "Restore"

- Added button "Tab: Edit map - Basic - Set Dimensions"

- Added Menu item "Menu: Extra - Save Errorlog"

### Changed

- Improved calculation of the part height:
When parts with different colors overlap, the bottom of the lower part must be lowered so that the upper part 
can be inserted. Previously, the lowering was based on the number of overlapping colors. Now, the actual 
overlaps are taken into account and the bottom is only lowered as far as necessary. 
This reduces the height of the parts and the amount of material used in printing.

- Various changes in the project parameter file to prepare for printing maps of a large area.
This includes, among other things:
	- The 2D map no longer has a toolbar. This significantly reduces the execution time of mouse actions such as 
selecting map objects when the map contains a particularly large number of map objects.
	- When dragging an area with the mouse, for example to draw a preview line, a rectangle is no longer displayed.

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

- Display of the path and file name of the saved project is now updated each time you save.

## [1.0.0.3 Public Beta] - 2025-08-28

First published version

[Unreleased]: https://github.com/Akilth/MapLab3D/compare/v1.0.0.3-beta...HEAD
[1.0.0.3 Public Beta]: https://github.com/Akilth/MapLab3D/releases/tag/v1.0.0.3-beta

