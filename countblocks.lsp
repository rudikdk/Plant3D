(defun c:bsize ( / l )
   (vlax-for b (vla-get-blocks (vla-get-activedocument (vlax-get-acad-object)))
       (if (and (= :vlax-false (vla-get-islayout b))
                (= :vlax-false (vla-get-isxref   b))
           )
           (setq l (cons (cons (vla-get-name b) (vla-get-count b)) l))
       )
   )
   (if l
       (progn
           (princ (LM:padbetween "\nBlock Name" "Components" "." 51))
           (princ (LM:padbetween "\n" "" "=" 51))
           (foreach x (vl-sort l '(lambda ( a b ) (> (cdr a) (cdr b))))
               (princ (LM:padbetween (strcat "\n" (car x)) (itoa (cdr x)) "." 51))
           )
           (princ (LM:padbetween "\n" "" "=" 51))
       )
       (princ "\nNo blocks found.")
   )
   (princ)
)

;; Pad Between  -  Lee Mac
;; Returns the concatenation of two supplied strings padded to a
;; desired length using a supplied character.
;; s1,s2 - [str] strings to be concatenated
;; ch    - [str] character for padding
;; ln    - [int] minimum length of returned string

(defun LM:padbetween ( s1 s2 ch ln )
   (   (lambda ( a b c )
           (repeat (- ln (length b) (length c)) (setq c (cons a c)))
           (vl-list->string (append b c))
       )
       (ascii ch)
       (vl-string->list s1)
       (vl-string->list s2)
   )
)

(vl-load-com) (princ)