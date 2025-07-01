; Function to create a layer if it doesn't exist.
(defun CreateLayer (layerName color)
  (if (not (tblsearch "LAYER" layerName)) ; Check if the layer DOES NOT exist
      (progn
        (entmake
         (list
          (cons 0 "LAYER") ; Entity type: LAYER
          (cons 100 "AcDbSymbolTableRecord")
          (cons 100 "AcDbLayerTableRecord")
          (cons 2 layerName) ; Layer name
          (cons 70 0)  ; Layer flags (0 = on, not frozen/locked)
          (cons 62 color) ; ACI color number
          (cons 6 "Continuous") ; Linetype name
          )
         )
        (princ (strcat "\nLayer " layerName " created."))
        )
      (princ (strcat "\nLayer " layerName " already exists.")) ; If it exists, print a message
      )
  (princ)
  )

; Function to create a layer with True Color if it doesn't exist.
(defun CreateLayerTrueColor (layerName red green blue)
  (if  (not (tblsearch "LAYER" layerName)) ; Check if the layer DOES NOT exist
      (progn
        (entmake
         (list
          (cons 0 "LAYER") ; Entity type: LAYER
          (cons 100 "AcDbSymbolTableRecord")
          (cons 100 "AcDbLayerTableRecord")
          (cons 2 layerName) ; Layer name
          (cons 70 0)  ; Layer flags (0 = on, not frozen/locked)
          (cons 62 0)   ; ACI color number (0 = ByLayer for True Color)
          (cons 420 (+ (* red 65536) (* green 256) blue))   ; True Color as a single integer
          (cons 6 "Continuous") ; Linetype name
          )
         )
        (princ (strcat "\nLayer " layerName " created with True Color."))
        )
      (princ (strcat "\nLayer " layerName " already exists.")) ; If it exists, print a message
      )
  (princ)
  )

; Main function to create all the layers.
(defun C:CreateLayers () 
  ; Original layers
  (CreateLayer "_Dummy Equipment" 10)
  (CreateLayer "_Dummy Structure" 242)
  (CreateLayer "_Dummy Support" 20)
  (CreateLayer "Grid" 250)
  (CreateLayer "Helplines" 2)  ; Yellow
  (CreateLayer "Helptext" 2)  ; Yellow
  (CreateLayer "Service Area" 250)
  (CreateLayer "Xref" 8)
  (CreateLayer "Instrumentation" 3)  ; Green

  ; True Color layers
  (CreateLayerTrueColor "Black Water" 36 39 132)
  (CreateLayerTrueColor "CIP" 233 53 223)
  (CreateLayerTrueColor "Compressed Air" 64 64 64)
  (CreateLayerTrueColor "Condensate" 108 163 208)
  (CreateLayerTrueColor "Cooling Return" 126 189 189)
  (CreateLayerTrueColor "Cooling Supply" 0 255 183)
  (CreateLayerTrueColor "Drinking Water" 0 0 129)
  (CreateLayerTrueColor "Drinking Water Hot" 0 127 255)
  (CreateLayerTrueColor "Ferric Chloride FeCl3" 145 255 71)
  (CreateLayerTrueColor "Heat Hot Return" 255 223 127)
  (CreateLayerTrueColor "Heat Hot Supply" 238 129 129)
  (CreateLayerTrueColor "Heat Return" 0 37 245)
  (CreateLayerTrueColor "Heat Supply" 255 0 0)
  (CreateLayerTrueColor "Hygienized Biomass" 169 130 0)
  (CreateLayerTrueColor "Liquid Biomass (Substrate)" 240 130 40)
  (CreateLayerTrueColor "Liquid Manure (Slurry)" 128 0 255)
  (CreateLayerTrueColor "Nature Gas" 0 255 127)
  (CreateLayerTrueColor "Oxygen" 0 128 255)
  (CreateLayerTrueColor "Process Water" 170 170 255)
  (CreateLayerTrueColor "Process Biomass" 165 103 82)
  (CreateLayerTrueColor "Raw Biogas" 255 255 0)
  (CreateLayerTrueColor "Recirculated Biomass" 165 103 82)
  (CreateLayerTrueColor "Return, reject Gas" 116 118 4)
  (CreateLayerTrueColor "Steam" 255 82 82)
  (CreateLayerTrueColor "Steam Condensate" 189 0 0)
  (CreateLayerTrueColor "Technical Water" 69 78 104)
  (CreateLayerTrueColor "Ventilation Fresh Air" 199 199 199)
  (CreateLayerTrueColor "Ventilation Odour Treatment" 199 199 199)

  (princ)
)
