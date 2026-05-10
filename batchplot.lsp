; BATCHPLOT - AutoLISP Batch Plot Utility
; Created by Piotr Iwanicki
; GitHub: PI-Prot-On
; License: GNU GPL v3.0
;
; Description: Batch plotting utility for exporting rectangular drawing regions from the "batchplot" layer to sequential PDF files

(vl-load-com)

; USER SETTINGS

(setq bp-plot-layer "batchplot")
(setq bp-pdf-printer "DWG To PDF.pc3")
(setq bp-plot-style "monochrome.ctb")
(setq bp-paper-size "ISO full bleed A3 (420.00 x 297.00 MM)")

; MAIN COMMAND

(defun c:batchplot (/ bp-selection bp-plot-region bp-plot-regions bp-lower-left bp-upper-right bp-pdf-number bp-pdf-name bp-pdf-dir bp-region bp-ll-array bp-ur-array)
	
	; Check if layer exists
	
	(if (not (tblsearch "LAYER" bp-plot-layer))
		(progn
			(princ
				(strcat
					"\nError: Layer \"" bp-plot-layer "\" does not exist."
				)
			)
		(princ)
		(exit)
		)
	)
	
	; Enter the name of the output folder for generated PDF files
		
	(setq bp-pdf-name (getstring "\nEnter the name of the new folder where the PDF will be saved (if such a folder already exists, plotting will be interrupted) : "))
			
	; Acquire the name of the directory containing the CAD file
	
	(if (= (findfile (strcat (getvar "dwgprefix") bp-pdf-name)) nil) ; Prevent overwriting existing plot folders/files.
		(and
			(vl-mkdir (strcat (getvar "dwgprefix") bp-pdf-name "\\"))
			(setq bp-pdf-dir (strcat (getvar "dwgprefix") bp-pdf-name "\\")) 
		)
		(and
			(princ "\nError: Output folder already exists.")
			(princ)
			(exit)
		)
	)
	
	; Set 0 as base for file name numbering
	
	(setq bp-pdf-number 0)
	
	; Create a list of coordinates
	
	(if

		; Search entire drawing for:
		; 0  . "LWPOLYLINE" = lightweight polylines
		; 8  . bp-plot-layer  = objects on the batch plotting layer
		; 70 . 1            = closed polyline flag
		; 90 . 4            = exactly 4 vertices

		(ssget "_X"
			(list 
				'(0 . "LWPOLYLINE") 
				(cons 8 bp-plot-layer) 
				'(70 . 1) 
				'(90 . 4)
			)
		)

		; If matching polylines were found, loop through the active selection set.

		(vlax-for bp-plot-region

			; Get AutoCAD's active selection set created by ssget. Each object in this set is treated as one plot region.

			(setq bp-selection
				(vla-get-ActiveSelectionSet
					(vla-get-ActiveDocument
						(vlax-get-acad-object)
					)
				)
			)

			; Get lower-left and Upper-Right corners of the rectangle's bounding box.

			(vla-GetBoundingBox bp-plot-region 'bp-ll-array 'bp-ur-array)

			; Convert COM SafeArray coordinates into AutoLISP lists and store them in the plot-region data list.

			(setq bp-plot-regions
				(cons
					(list
						(vlax-safearray->list bp-ll-array)
						(vlax-safearray->list bp-ur-array)
					)
				bp-plot-regions
				)
			)
		)
	)

	; Check if rectangles exist on the layer
	
	(if (not bp-plot-regions)
		(progn
			(princ (strcat "\nNo valid plot regions found on the \"" bp-plot-layer "\" layer.")) ; There are no valid rectangles on the layer.
		(princ)
		(exit)
		)
	)

	; Delete/clear the temporary ActiveSelectionSet object. This does not delete the rectangle geometry from the drawing.

	(if bp-selection
		(vla-delete bp-selection)
	)
	
	; Loop through all collected plot regions and export each region as a sequential PDF file.
	
    (foreach bp-region bp-plot-regions
		
		; Assign coordinates to values
		
		(setq bp-lower-left (car bp-region))
		(setq bp-upper-right (cadr bp-region))
		(setq bp-pdf-number (+ bp-pdf-number 1)) 	
		(command
			"-plot"
			"Y" ; Detailed plot configuration = Yes
			"Model" ; Layout name = Model
			bp-pdf-printer ; Output device name
			bp-paper-size ; Paper size
            "M" ; Paper units
			(if (>= (- (car bp-upper-right) (car bp-lower-left)) (- (cadr bp-upper-right) (cadr bp-lower-left) ) ) "L" "P") ; Compare rectangle width vs height to automatically select landscape or portrait orientation
            "N" ; Plot upside down = No
            "W" bp-lower-left bp-upper-right ; Plot area = Window -> Coordinates input
            "F" ; Plot scale = Fit
			"C" ; Plot offset = Center
			"Y" ; Plot with plot styles?
			bp-plot-style ; Plot style table
			"Y" ; Plot with lineweights?
			"" ; Shade plot setting?
			(strcat bp-pdf-dir bp-pdf-name "_" 
				(cond 
					((< bp-pdf-number 10) 
						(strcat "00" (rtos bp-pdf-number 2 0))) 
					((< bp-pdf-number 100) 
						(strcat "0" (rtos bp-pdf-number 2 0))
					)  
					(t 
						(rtos bp-pdf-number 2 0)
					)
				)
			) ; Write plot to a file + adding a sequential number to the file name
			"Y" ; Save changes to layout = Yes
			"Y" ; Proceed with plot = Yes           
        )	
    )
  (princ)
)