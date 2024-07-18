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



;;;is-monomial/1:
(defun is-monomial (m)
 (and (listp m)
 (eq ’m (first m))
 (let ((mtd (monomial-total-degree m))
 (vps (var-powers m))
 )
 (and (integerp mtd)
 (>= mtd 0)
 (listp vps)
 (every #’is-varpower vps)))))

;;;funzioni ausiliarie per is-monomial:

;;; monomial-total-degree/1:
(defun monomial-total-degree (m)
  (if (and (= (length m) 4) (eq 'm (first m)))
      (let ((mtd (third m)))
        (if (>= mtd 0) mtd nil))
    (if (is-polynomial m) 
        nil
      (let* ((parsed-m (as-monomial m)) (mtd (third parsed-m)))
	(if (>= mtd 0) mtd nil)))))

;; var-powers/1:
(defun var-powers (m)
  (if (and (= (length m) 4) (eq 'm (first m)))
      (let ((vps (fourth m)))
	(if (listp vps)
	    vps
	  nil))
    (if (is-polynomial m) 
        nil
      (let* ((parsed-m (as-monomial m)) (vps (fourth parsed-m)))
	(if (listp vps)
	    vps
          nil)))))


;;;is-polynomial/1:
 (defun is-polynomial (p)
 (and (listp p)
 (eq ’poly (first p))
 (let ((ms (monomials p)))
 (and (listp ms)
 (every #’is-monomial ms)))))

;;;funzioni ausiliarie a is-polynomial:

;;; monomials/1:
(defun monomials (p)
  (if (equal (first p) 'poly) 
      (first (rest p)) 
    (monomials (convert-p p))))


;;;convert-p/1:
(defun convert-p (poly)
  (cond ((is-polynomial poly)
	 (append (list 'poly) (sort-poly (list (monomials poly)))))
	((is-monomial poly)
	 (append (list 'poly) (list (list poly))))
	((if (or (atom poly) (equal '* (first poly)))
	     (convert-p (as-monomial poly))
	   (as-polynomial poly)))
        (t nil)))


;;;is-zero/1:
(defun is-zero (X)
  (cond
   ((and (numberp X)(eq X 0)) T) 
   ((and (eq (first X) 'm) (eq (second X) 0)) T)
   ((and (eq (first X) 'poly) (eq (second X) '())) T)
   (t nil)))