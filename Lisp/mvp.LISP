;;;Mazzeo Alessia 899612

;;;FUNZIONI DI CONTROLLO:

;;;is-varpower/1:
(defun is-varpower(vp)
 (and (listp vp)
 (eq 'v (first vp))
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
(defun is-monomial (mn)
 (and (listp mn)
 (eq 'm (first mn))
 (let ((mtd (monomial-degree mn))
 (vps (var-powers mn))
 )
 (and (integerp mtd)
 (>= mtd 0)
 (listp vps)
 (every #'is-varpower vps)))))

;;;funzioni ausiliarie per is-monomial:

;;; monomial-degree/1:
(defun monomial-degree (mn)
  (if (and (= (length mn) 4) (eq 'm (first mn)))
      (let ((mtd (third mn)))
        (if (>= mtd 0) mtd nil))
    (if (is-polynomial mn) 
        nil
      (let* ((parsed-m (as-monomial mn)) (mtd (third parsed-m)))
	(if (>= mtd 0) mtd nil)))))

;; var-powers/1:
(defun var-powers (mn)
  (if (and (= (length mn) 4) (eq 'm (first mn)))
      (let ((vps (fourth mn)))
	(if (listp vps)
	    vps
	  nil))
    (if (is-polynomial mn) 
        nil
      (let* ((parsed-m (as-monomial mn)) (vps (fourth parsed-m)))
	(if (listp vps)
	    vps
          nil)))))


;;;is-polynomial/1:
 (defun is-polynomial (p)
 (and (listp p)
 (eq 'poly (first p))
 (let ((ms (monomials p)))
 (and (listp ms)
 (every #'is-monomial ms)))))

;;;funzioni ausiliarie a is-polynomial:

;;; monomials/1:
(defun monomials (p)
  (if (equal (first p) 'poly) 
      (first (rest p)) 
    (monomials (convert-p p))))


;;;convert-p/1:
(defun convert-p (poly)
  (cond ((is-polynomial poly)
	 (append (list 'poly) (sort-p (list (monomials poly)))))
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
  (cond ((is-num e) (list 'm (eval e) 0 nil))
        ((atom e) (list 'm 1 1 (list (list 'v 1 e))))
        (t (let ((head (first e)) (tail (rest e)))
             (if (is-op head)
                 (cond ((equal head '-)
                        (if (listp (second e))
                            (parse-p-neg (second e))
			  (list 'm -1 1 (list 'v 1 (second e)))))
                       ((equal head '*)
                        (if (eql (get-c tail) 0) (list 'm 0 0 nil)
			  (let ((vps (get-vp tail 0)))
			    (append (list 'm) (list (get-c tail))
				    (list (first vps)) (list (rest vps))))))
                       ((equal head '+)
                        nil))
	       (if (check-p head)
		   (parse-p head)
		 (list 'm 1 1 (list (list 'v 1 head)))))))))

;;;reduce-m/1:
(defun reduce-m (mn)
  (if (null (var-powers mn)) mn
    (let ((vps (var-powers mn))
	  (c (monomial-coefficient mn))
	  (td (monomial-degree mn)))
      (append (list 'm c td) (list (reduce-vps vps))))))

;;; sort-m/1:
(defun sort-m (mn)
  (let ((new-var-powers (copy-list (var-powers mn))))
    (append (list (first mn) (second mn) (third mn))
	    (list (stable-sort new-var-powers 'string< :key 'third)))))

;;;is-num/1:
(defun is-num (e)
  (let ((result 
         (handler-case 
             (eval e)
	   (error () nil)
	   (warning () nil))))
    (if (numberp result) 
        result 
      nil)))

;;; is-op/1
(defun is-op (operator)
  (if (or (eql operator '*) (eql operator '/)
	  (eql operator '-) (eql operator '+))
      T nil))



;;;parse-p-neg/1:
(defun parse-p-neg (e)
  (if (check-p e)
      (list 'm -1 (third e) (list 'v (third e) (second e))) nil))


;;;get-c/1:
(defun get-c (e)
  (if (null e) 1
    (if (is-num (first e))
	(* 1 (eval (first e)) (get-c (rest e)))
      (* 1 (get-c (rest e))))))


;;;get-vp/2
(defun get-vp (e td)
  (let ((head (first e)) (tail (rest e)))
    (cond ((and (listp head)
		(not (null head))
		(not (eq (third head) 0))
		(equal (first head) 'expt))
           (append (get-vp tail (+ (eval td) (eval (third head))))
		   (list (list 'v (third head) (second head)))))
          ((and (listp head)
		(not (null head))
		(eq (third head) 0)
		(equal (first head) 'expt))
           (append (get-vp tail (+ (eval td) (eval (third head))))
		   nil))
          ((and (symbolp head) (not (null head)))
           (append (get-vp tail (+ 1 (eval td)))
		   (list (list 'v 1 head))))
          ((numberp (eval head)) (get-vp tail td))
          ((null head) (list td)))))



;;; check-p/1
(defun check-p (e)
  (if (not (listp e)) nil
    (if (and (equal (first e) 'expt) (symbolp (second e))
	     (numberp (third e)))
	T NIL)))

;;;parse-p/1:
(defun parse-p (e)
  (if (check-p e)
      (if (not (eq (third e) 0))
	  (list 'm 1 (third e)
		(list 'v (third e)
		      (second e)))
	(list 'm 1 '0 nil))
    nil))


;;; monomial-coefficient/1
(defun monomial-coefficient (mn)
  (if (null mn) 0
    (if (and (= (length mn) 4) (eq 'm (first mn)))
	(let ((coeff (second mn)))
	  (if (numberp coeff) coeff nil))
      (let* ((parsed-m (as-monomial mn)) (coeff (second parsed-m)))
	(if (numberp coeff) coeff nil)))))

;;;sort-p/2:
(defun sort-p (mns)
  (let ((poly-c (copy-list mns)))
    (stable-sort poly-c #'order-d)))

;;; order-d/2
(defun order-d (first-mono rest-monos)
  (when (not (null first-mono))
    (let ((degrees
	   (list (monomial-degree first-mono)
		 (monomial-degree rest-monos))))
      (cond ((null first-mono) (not (null rest-monos)))
            ((null rest-monos) nil)
            ((= (first degrees) (second degrees))
	     (order-p (var-powers first-mono)
				 (var-powers rest-monos)))
            (t (< (first degrees) (second degrees)))))))

;;;order-p/2:
(defun order-p (vars1 vars2)
  (cond ((null vars1) (not (null vars2)))
	((null vars2) nil)
	(t
         (let ((v1 (first vars1)) (v2 (first vars2)))
           (cond
	    ((string< (third v1) (third v2)) t)
	    ((string> (third v1) (third v2)) nil)
	    ((and (equal (third v1) (third v2)) (= (second v1) (second v2)))
	     (order-p (rest vars1) (rest vars2)))
	    (t (< (second (first vars1)) (second (first vars2)))))))))


;;;reduce-vps/1:
(defun reduce-vps (vps)
  (if (null vps) nil
    (if (null (second vps)) vps
      (let* ((vp1 (first vps))
	     (vp2 (second vps))
	     (expt1 (varpower-power vp1))
	     (expt2 (varpower-power vp2))
	     (var1 (varpower-symbol vp1))
	     (var2 (varpower-symbol vp2))
	     (tail (rest (rest vps))))
	(if (not (null tail))
	    (if (not (null vp2))
		(if (equal var1 var2)
		    (reduce-vps (append
				   (list (list 'v (+ (eval expt1)
						     (eval expt2))
					       var1))
				   tail))
		  (append (list (list 'v expt1 var1))
			  (reduce-vps (rest vps)))))
	  (if (equal var1 var2) (list (list 'v (+ (eval expt1)
						  (eval expt2))
					    var1))
	    (append (list (list 'v expt1 var1))
		    (list (list 'v expt2 var2)))))))))




;;; as-polynomial/1
(defun as-polynomial (e)
  (if (is-monomial e) (parse-p e)
    (append (list 'poly)
	    (list
	     (remove-zero
	      (sum-similar-monos
	       (sort-p (as-pe e))))))))


;;;funzioni ausiliarie per as-polynomial:

;;; as-pe/1
(defun as-pe (e)
  (when (not (null e))
    (if (atom e) (list (as-monomial e))
      (let ((head (first e)) (tail (rest e)))
	(if (is-op head)
	    (if (equal head '+)
		(as-pe tail)
	      (list (as-monomial e)))
	  (if (and (listp expr) (not (null tail)))
	      (append (list (as-monomial head)) (as-pe tail))
	    (list (as-monomial head))))))))







;;; vars-of/1
(defun vars-of (mn)
  (if (not (and (equal (first mono) 'm) (= (length mn) 4)))
      (vars-of (as-monomial mn))
    (apply #'append
	   (let ((vps (var-powers mn)))
	     (append (list (mapcar (lambda (x) (third x)) vps)))))))


;;;coefficients/1:
(defun coefficients (p)
  (let* ((parsed-p (convert-p p)) 
         (monomials (monomials parsed-p)))
    (if (null monomials) 
        '(0)
      (mapcar 'monomial-coefficient monomials))))



;;; variables/1
(defun variables (p)
  (let ((parsed-p (convert-p p)))
    (remove-duplicates (mapcar #'varpower-symbol
			       (apply #'append
				      (mapcar #'var-powers
					      (monomials parsed-p)))))))


;;;max-degree/1:

(defun max-degree (p)
  (let* ((parsed-p (convert-p p)))
    (monomial-degree (first (last (monomials parsed-p))))))


;;;min-degree/1:
(defun min-degree (p)
  (let* ((parsed-p (convert-p p)))
    (monomial-degree (first (monomials parsed-p)))))




;;;pprint-polynomial/1:
(defun pprint-polynomial (poly)
  (format t "~a"
	  (format nil "~a"
		  (pprint-pe
		   (second (convert-p poly))))))

;;;funzioni ausiliarie per pprint-polynomial:

;;;pprint-pe/1:
(defun pprint-pe (mn)
  (let ((m1 (first mn)) (c2 (second (second mn))))
    (if (not (null c2))
        (if (> c2 0)
            (append (pprint-pc m1)
		    (list '+)
		    (pprint-pe (rest mn)))
	  (append (pprint-pc m1)
		  (pprint-pe (rest mn))))
      (append (pprint-pc m1)))))

;;;pprint-pc/1:
(defun pprint-pc (m1)
  (let ((c1 (second m1)) (v&p (fourth m1)))
    (if (equal v&p nil)
        (append (list c1))
      (append (list c1)
	      (list '*)
	      (pprint-pv v&p)))))



;;;pprint-pv/1:
(defun pprint-pv (vp)
  (if (null vp) nil
    (let ((exp (second (first vp))) (var (third (first vp))))
      (if (equal (rest vp) nil)
	  (if (= exp 1)
	      (append (list var)) (append (list var '^ exp)))
	(if (= exp 1)
	    (append (list var '*)
		    (pprint-pv (rest vp)))
	  (append (list var '^ exp '*)
		  (pprint-pv
		   (rest vp))))))))



;;;operazioni per polinomi e monomi: