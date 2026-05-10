# BatchPlot AutoLISP

AutoLISP utility for batch plotting user-defined rectangular areas from AutoCAD drawings to sequential PDF files.

## Purpose

BatchPlot was created for situations where the standard Publish workflow is unavailable or impractical.

The user marks drawing areas with closed rectangular polylines on a dedicated layer, and the script exports each region as a separate PDF file.

## Features

- Uses a dedicated `batchplot` layer to define plotting regions
- Detects closed 4-vertex lightweight polylines
- Reads each rectangle as a plotting window
- Follows the creation order of plot rectangles when generating PDFs
- Automatically selects portrait or landscape orientation
- Exports sequential PDF files using 3-digit numbering, e.g. `drawing_001.pdf`
- Keeps the workflow lightweight and easy to adjust

## Basic Workflow

1. Load the `.lsp` file in AutoCAD.
2. Create a layer named `batchplot` and disable plotting for this layer.
3. Use this layer to draw closed rectangular polylines around the areas to be plotted.
4. Run the command: `BATCHPLOT`
5. Enter the output folder / file base name.
6. The script exports PDF files as: `name_001.pdf`, `name_002.pdf`, `name_003.pdf`, etc.
7. Depending on drawing size and number of plot regions, export may take a minute or two.

## Configuration

The main settings are placed near the top of the script and can be adjusted manually:
```lisp
(setq bp-plot-layer "batchplot")
(setq bp-paper-size "ISO full bleed A3 (420.00 x 297.00 MM)")
(setq bp-plot-style "monochrome.ctb")
(setq bp-pdf-printer "DWG To PDF.pc3")
```
These values may need adjustment depending on AutoCAD version, printer configuration, language version, or installed plot styles.

## Notes

- AutoLISP is not supported in AutoCAD LT.
- Plot regions must be closed lightweight polylines with exactly 4 vertices.
- The script uses bounding boxes, so rectangles should be aligned with the intended plotting area.
- Plot sequence follows object creation order; copy/paste can be used to duplicate regions while keeping predictable sequence behavior.
- Existing output folders with the same name are not overwritten.
- The script was developed as a practical engineering workflow utility, not as a full publishing system.

## Author

Created by Piotr Iwanicki (`PI-Prot-On`) as a practical CAD workflow automation utility for engineering documentation work.

## Professional Profile

LinkedIn: https://www.linkedin.com/in/pi-prot-on

## License

Released under the GNU GPLv3 License.
