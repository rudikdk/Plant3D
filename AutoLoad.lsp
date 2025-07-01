(defun load-support-file (filename)
  (load (strcat (getenv "APPDATA") "\\Autodesk\\Autodesk AutoCAD Plant 3D 2024\\R24.3\\enu\\Support\\Lisp Library\\" filename))
)

; Load all these .lsp files
(load-support-file "CreateLayer.lsp")
(load-support-file "InsertRevitxref.lsp")
(load-support-file "MoveToPlantCordinate.lsp")
(load-support-file "MoveToRevitCordinate.lsp")
(load-support-file "countblocks.lsp")
(load-support-file "MacAttV3-1.lsp")
(load-support-file "BatchAttributeEditorV1-5.lsp")
; Add other files to load here as needed

