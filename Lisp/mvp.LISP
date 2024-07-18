;;;Mazzeo Alessia 899612

;;;FUNZIONI DI CONTROLLO:

;;;is-varpower/1:

(defun is-varpower(vp)
 (and (listp vp)
 (eq ’v (first vp))
 (let ((p (varpower-power vp))
 (v (varpower-symbol vp))
 )
 (and (integerp p)
 (>= p 0)
 (symbolp v)))))

;;;funzioni ausiliarie per is-varpower:
;;;varpower-power/1:
(defun varpower-power (vp)
  (let ((pow (second vp)))
    (if (numberp pow) pow)))

;;;varpower-symbol/1:
(defun varpower-symbol (vp)
  (let ((vs (third vp)))
    (cond ((and
	    (atom vs)
	    (not (numberp vs))) vs)
	  (T nil))))
