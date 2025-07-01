;; Helper function to find "Plant 3D Models" in a path
(defun find-plant-3d-models-path (path / pos)
  (setq pos (vl-string-search "Plant 3D Models" path))
  (if pos
    (substr path 1 (+ pos (strlen "Plant 3D Models")))
    path  ; Return original path if "Plant 3D Models" not found
  )
)

(defun c:InsertRevit (/ filePath xmlPath xmlData rotation x y z projectRoot currentPath plant3dPath xrefName)
  (vl-load-com)
  
  ;; Get current drawing path using DWGPREFIX command
  (command "_.DWGPREFIX")
  (setq currentPath (getvar "DWGPREFIX"))
  
  ;; Find and trim path to include "Plant 3D Models" folder
  (setq plant3dPath (find-plant-3d-models-path currentPath))
  
  ;; Prompt user to select a DWG file using a file browser, starting in the DWGPREFIX location
  (setq filePath (getfiled "Select DWG File for XREF" currentPath "dwg" 0))
  
  ;; Check if a file was selected
  (if filePath
    (progn
      ;; Get project root directory (parent directory of the selected file)
      (setq projectRoot (vl-filename-directory filePath))
      
      ;; Extract project name dynamically from the path
      ;; Assuming the project folder is one level above the DWG file's folder
      (setq projectName (vl-filename-base (vl-filename-directory projectRoot)))
      
      ;; Find Plant 3D Models path for XML file
      (setq plant3dPath (find-plant-3d-models-path currentPath))
      
      ;; Get parent directory (one folder up from Plant 3D Models path)
      (setq parentPath (vl-filename-directory plant3dPath))
      
      ;; Construct XML path using parent directory (one folder closer to root)
      (setq xmlPath (strcat parentPath "\\Related Files\\Revit import\\Import.xml"))
      
      ;; Display the XML file path in the command prompt
      (princ (strcat "\nXML File Path: " xmlPath))
      
      
      ;; Check if XML file exists
      (if (findfile xmlPath)
        (progn
          ;; Read XML file as text
          (setq xmlData (read-file xmlPath))
          
          
          ;; Extract import values from XML
          (setq rotation (extract-value xmlData "<import>" "</import>" "<rotation>" "</rotation>"))
          (setq x (extract-value xmlData "<import>" "</import>" "<x>" "</x>"))
          (setq y (extract-value xmlData "<import>" "</import>" "<y>" "</y>"))
          (setq z (extract-value xmlData "<import>" "</import>" "<z>" "</z>"))
          
          
          
          ;; Clean up values before conversion
          (setq rotation (clean-value rotation))
          (setq x (clean-value x))
          (setq y (clean-value y))
          (setq z (clean-value z))
          
          
          ;; Convert to numbers
          (setq rotation (atof rotation))
          (setq x (atof x))
          (setq y (atof y))
          (setq z (atof z))
          
          
          ;; Get the filename without path and extension for the XREF name
          (setq xrefName (vl-filename-base filePath))
          
          ;; Print the coordinates for debugging
          (princ (strcat "\nInsertion Point: " (rtos x 2 16) "," (rtos y 2 16) "," (rtos z 2 16)))
          (princ (strcat "\nRotation: " (rtos rotation 2 8)))
          
          ;; Use XREF command with the coordinates from XML
          ;; Following the exact sequence shown in the manual example
          (command "-XREF")                                  ;; Start XREF command
          (command "A")                                      ;; Attach option
          (command filePath)                                 ;; Path to the file
          (command (strcat (rtos x 2 16) "," (rtos y 2 16) "," (rtos z 2 16)))  ;; Insertion point as string "x,y,z" with high precision
          (command "1")                                      ;; X scale factor
          (command "1")                                      ;; Y scale factor
          (command (rtos rotation 2 8))                      ;; Rotation angle with high precision
          
          (princ (strcat "\nXREF '" xrefName "' inserted successfully."))
        )
        ;; Error message if XML file not found
        (princ (strcat "\nError: XML file not found at " xmlPath))
      )
    )
    ;; Error message if no DWG file was selected
    (princ "\nNo DWG file selected. Operation cancelled.")
  )
  
  ;; Exit cleanly
  (princ)
)

;; Helper function to read file contents - improved version that preserves all characters
(defun read-file (file-path / file-handle line result)
  (setq result "")
  (setq file-handle (open file-path "r"))
  (if file-handle
    (progn
      
      ;; Read file line by line and concatenate without adding newlines
      (while (setq line (read-line file-handle))
        (setq result (strcat result line))
      )
      (close file-handle)
      result
    )
    (progn
      (princ (strcat "\nError: Could not open file " file-path))
      ""
    )
  )
)

;; Helper function to extract value between section tags and then between value tags
(defun extract-value (xml-string section-start-tag section-end-tag value-start-tag value-end-tag 
                     / section-start-pos section-end-pos section-content value)
  ;; First extract the section content
  (setq section-start-pos (vl-string-search section-start-tag xml-string))
  (if section-start-pos
    (progn
      (setq section-start-pos (+ section-start-pos (strlen section-start-tag)))
      (setq section-end-pos (vl-string-search section-end-tag xml-string section-start-pos))
      (if section-end-pos
        (progn
          ;; Extract the section content
          (setq section-content (substr xml-string section-start-pos (- section-end-pos section-start-pos)))
          
          ;; Now extract the value from the section content
          (setq value (extract-simple-value section-content value-start-tag value-end-tag))
          
          
          value
        )
        ""
      )
    )
    ""
  )
)

;; Helper function to extract value between tags - simple version
(defun extract-simple-value (xml-string start-tag end-tag / start-pos end-pos value)
  (setq start-pos (vl-string-search start-tag xml-string))
  (if start-pos
    (progn
      (setq start-pos (+ start-pos (strlen start-tag)))
      (setq end-pos (vl-string-search end-tag xml-string start-pos))
      (if end-pos
        (progn
          ;; Extract the value
          (setq value (substr xml-string start-pos (- end-pos start-pos)))
          value
        )
        ""
      )
    )
    ""
  )
)

;; Helper function to clean up values before conversion
(defun clean-value (value / i char result)
  ;; Remove any non-numeric characters except for decimal point and minus sign
  (setq result "")
  (setq i 1)
  (while (<= i (strlen value))
    (setq char (substr value i 1))
    (if (or (and (>= (ascii char) 48) (<= (ascii char) 57))  ;; 0-9
            (= char ".")                                     ;; decimal point
            (= char "-"))                                    ;; minus sign
      (setq result (strcat result char))
    )
    (setq i (1+ i))
  )
  result
)
