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





;;; as-monomial/1
(defun as-monomial (e)
  (reduce-m (sort-m (as-ms e))))


;;;funzioni ausiliarie a as-monomial:

;;;as-ms/1:
(defun as-ms (e)
  (cond ((is-number e) (list 'm (eval e) 0 nil))
        ((atom e) (list 'm 1 1 (list (list 'v 1 e))))
        (t (let ((head (first e)) (tail (rest e)))
             (if (is-operator head)
                 (cond ((equal head '-)
                        (if (listp (second e))
                            (parse-power-negative-coeff (second e))
			  (list 'm -1 1 (list 'v 1 (second e)))))
                       ((equal head '*)
                        (if (eql (get-coefficient tail) 0) (list 'm 0 0 nil)
			  (let ((vps (get-var-powers tail 0)))
			    (append (list 'm) (list (get-coefficient tail))
				    (list (first vps)) (list (rest vps))))))
                       ((equal head '+)
                        nil))
	       (if (is-power-not-parsed head)
		   (parse-power head)
		 (list 'm 1 1 (list (list 'v 1 head)))))))))

;;;reduce-m/1:
(defun reduce-m (m)
  (if (null (var-powers m)) m
    (let ((vps (var-powers mono))
	  (c (monomial-coefficient m))
	  (td (monomial-degree m)))
      (append (list 'm c td) (list (reduce-vps vps))))))

;;; sort-m/1:
(defun sort-m (m)
  (let ((new-var-powers (copy-list (var-powers m))))
    (append (list (first m) (second m) (third m))
	    (list (stable-sort new-var-powers 'string< :key 'third)))))
