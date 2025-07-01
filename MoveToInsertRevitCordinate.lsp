;; Helper function to read file contents
(defun read-file (file-path / file-handle line result)
  (setq result "")
  (setq file-handle (open file-path "r"))
  (if file-handle
    (progn
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

;; Helper function to write to file
(defun write-file (file-path content / file-handle)
  (setq file-handle (open file-path "w"))
  (if file-handle
    (progn
      (write-line content file-handle)
      (close file-handle)
      T
    )
    (progn
      (princ (strcat "\nError: Could not write to file " file-path))
      nil
    )
  )
)

;; Helper function to extract value between section tags and then between value tags
(defun extract-value (xml-string section-start-tag section-end-tag value-start-tag value-end-tag 
                     / section-start-pos section-end-pos section-content value)
  (setq section-start-pos (vl-string-search section-start-tag xml-string))
  (if section-start-pos
    (progn
      (setq section-start-pos (+ section-start-pos (strlen section-start-tag)))
      (setq section-end-pos (vl-string-search section-end-tag xml-string section-start-pos))
      (if section-end-pos
        (progn
          (setq section-content (substr xml-string section-start-pos (- section-end-pos section-start-pos)))
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
  (setq result "")
  (setq i 1)
  (while (<= i (strlen value))
    (setq char (substr value i 1))
    (if (or (and (>= (ascii char) 48) (<= (ascii char) 57))
            (= char ".")
            (= char "-"))
      (setq result (strcat result char))
    )
    (setq i (1+ i))
  )
  result
)

;; Helper function to find "Plant 3D Models" in a path
(defun find-plant-3d-models-path (path / pos)
  (setq pos (vl-string-search "Plant 3D Models" path))
  (if pos
    (substr path 1 (+ pos (strlen "Plant 3D Models")))
    path  ; Return original path if "Plant 3D Models" not found
  )
)

;; Helper function to get the config file path
(defun get-config-file-path (/ config-dir)
  (setq config-dir (getvar "ROAMABLEROOTPREFIX"))
  (strcat config-dir "Support\\ImportXmlPath.cfg")
)

;; Helper function to save the XML path to config file
(defun save-xml-path (xml-path)
  (write-file (get-config-file-path) xml-path)
)

;; Helper function to load the XML path from config file
(defun load-xml-path (/ config-path)
  (setq config-path (get-config-file-path))
  (if (findfile config-path)
    (read-file config-path)
    nil
  )
)

;; Helper function to prompt user to select Import.xml file
(defun prompt-for-import-xml (/ xml-path)
  (setq xml-path (getfiled "Select Import.xml file" "" "xml" 0))
  (if (and xml-path (= (strcase (vl-filename-extension xml-path)) ".XML"))
    xml-path
    (progn
      (princ "\nInvalid file selected. Please select an XML file.")
      (prompt-for-import-xml)
    )
  )
)

;; Helper function to confirm XML path with user
(defun confirm-xml-path (xml-path / response)
  (princ (strcat "\nSelected Import.xml path: " xml-path))
  (setq response (getstring "\nIs this the correct Import.xml file? (Y/N): "))
  (if (or (= (strcase response) "Y") (= (strcase response) "YES"))
    T
    nil
  )
)

;; Helper function to get and confirm Import.xml path
(defun get-confirmed-xml-path (/ xml-path confirmed)
  (setq xml-path (prompt-for-import-xml))
  (setq confirmed (confirm-xml-path xml-path))
  (if confirmed
    (progn
      (save-xml-path xml-path)
      xml-path
    )
    (get-confirmed-xml-path)
  )
)

(defun c:MoveToPlantCordinate ( / def enx inc lst sel angleInDegrees angleInRadians newPos blockName xmlPath xmlData x y z saved-path response)
   (vl-load-com)
   
   ;; Try to load saved XML path
   (setq saved-path (load-xml-path))
   
   ;; If saved path exists, ask user if they want to use it
   (if saved-path
     (progn
       (princ (strcat "\nPreviously used Import.xml path: " saved-path))
       (setq response (getstring "\nUse this path? (Y/N): "))
       (if (or (= (strcase response) "Y") (= (strcase response) "YES"))
         (setq xmlPath saved-path)
         (setq xmlPath (get-confirmed-xml-path))
       )
     )
     ;; If no saved path, prompt user to select file
     (setq xmlPath (get-confirmed-xml-path))
   )
   
   ;; Display the XML file path in the command prompt
   (princ (strcat "\nUsing XML File Path: " xmlPath))
   
   ;; Check if XML file exists
   (if (findfile xmlPath)
     (progn
       (setq xmlData (read-file xmlPath))
       
       ;; Extract import values from XML
       (setq angleInDegrees (atof (clean-value (extract-value xmlData "<import>" "</import>" "<rotation>" "</rotation>"))))
       (setq x (atof (clean-value (extract-value xmlData "<import>" "</import>" "<x>" "</x>"))))
       (setq y (atof (clean-value (extract-value xmlData "<import>" "</import>" "<y>" "</y>"))))
       (setq z (atof (clean-value (extract-value xmlData "<import>" "</import>" "<z>" "</z>"))))
       
       ;; Print the coordinates and rotation for verification
       (princ (strcat "\nImport Values from XML:"))
       (princ (strcat "\nRotation: " (rtos angleInDegrees 2 8) " degrees"))
       (princ (strcat "\nPosition: X=" (rtos x 2 16) ", Y=" (rtos y 2 16) ", Z=" (rtos z 2 16)))
       
       ;; Set the position from XML values
       (setq newPos (list x y z))
     )
     (progn
       (princ "\nError: Import.xml file not found")
       (exit)
     )
   )
   
   (setq angleInRadians (* angleInDegrees (/ pi 180.0)))  ; Convert degrees to radians

   (while (setq def (tblnext "block" (null def)))
       (if (= 4 (logand 4 (cdr (assoc 70 def))))
           (setq lst (vl-list* "," (cdr (assoc 2 def)) lst))
       )
   )
   (if
       (and lst
           (setq sel
               (ssget "_X"
                   (list '(0 . "INSERT")
                       (cons 2 (apply 'strcat (cdr lst)))
                   )
               )
           )
       )
        (repeat (setq inc (sslength sel))
            (setq enx (entget (ssname sel (setq inc (1- inc)))))  
            (setq blockName (cdr (assoc 2 enx)))  ; Get the block name

            (entmod 
                (list
                    (cons 10 newPos)       ; Move to position
                    (cons 50 angleInRadians)  ; Apply calculated rotation
                    (assoc -1 enx)
                )
            )

            ;; Print block name and transformation info
            (princ "\nMoved block: ")
            (princ blockName)  ; Print block name
            (princ " to position: ")
            (princ newPos)  ; Print new position
            (princ " with rotation: ")
            (princ angleInDegrees)  ; Print rotation in degrees
            (princ " degrees.")
        )
   )
   (princ "\nOperation completed successfully.")
   (princ)
)
