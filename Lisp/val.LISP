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
	(let ((c (second mn)))
	  (if (numberp c) c nil))
      (let* ((parsed-m (as-monomial mn)) (c (second parsed-m)))
	(if (numberp c) c nil)))))

;;;sort-p/2:
(defun sort-p (mns)
  (let ((poly-c (copy-list mns)))
    (stable-sort poly-c #'order-d)))

;;; order-d/2
(defun order-d (m ms)
  (when (not (null m))
    (let ((degrees
	   (list (monomial-degree m)
		 (monomial-degree ms))))
      (cond ((null m) (not (null ms)))
            ((null ms) nil)
            ((= (first degrees) (second degrees))
	     (order-p (var-powers m)
				 (var-powers ms)))
            (t (< (first degrees) (second degrees)))))))

;;;order-p/2:
(defun order-p (vs1 vs2)
  (cond ((null vs1) (not (null vs2)))
	((null vs2) nil)
	(t
         (let ((v1 (first vs1)) (v2 (first vs2)))
           (cond
	    ((string< (third v1) (third v2)) t)
	    ((string> (third v1) (third v2)) nil)
	    ((and (equal (third v1) (third v2)) (= (second v1) (second v2)))
	     (order-p (rest vs1) (rest vs2)))
	    (t (< (second (first vs1)) (second (first vs2)))))))))


;;;reduce-vps/1:
(defun reduce-vps (vps)
  (if (null vps) nil
    (if (null (second vps)) vps
      (let* ((vp1 (first vps))
	     (vp2 (second vps))
	     (expt1 (varpower-power vp1))
	     (expt2 (varpower-power vp2))
	     (v1 (varpower-symbol vp1))
	     (v2 (varpower-symbol vp2))
	     (tail (rest (rest vps))))
	(if (not (null tail))
	    (if (not (null vp2))
		(if (equal v1 v2)
		    (reduce-vps (append
				   (list (list 'v (+ (eval expt1)
						     (eval expt2))
					       v1))
				   tail))
		  (append (list (list 'v expt1 v1))
			  (reduce-vps (rest vps)))))
	  (if (equal v1 v2) (list (list 'v (+ (eval expt1)
						  (eval expt2))
					    v1))
	    (append (list (list 'v expt1 v1))
		    (list (list 'v expt2 v2)))))))))




;;; as-polynomial/1
(defun as-polynomial (e)
  (if (is-monomial e) (parse-p e)
    (append (list 'poly)
	    (list
	     (remove-zero
	      (sum-like-m
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
	  (if (and (listp e) (not (null tail)))
	      (append (list (as-monomial head)) (as-pe tail))
	    (list (as-monomial head))))))))







;;; vars-of/1
(defun vars-of (mn)
  (if (not (and (equal (first mn) 'm) (= (length mn) 4)))
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


;;;mvp-plus/2:
(defun mvp-plus (pl1 pl2)
  (let ((p1 (convert-p pl1)) (p2 (convert-p pl2)))
    (append (list 'poly)
            (list (remove-zero
                   (sort-p
                    (sum-like-m
                     (sort-p (append (monomials p1)
                                        (monomials p2))))))))))


;;;sum-like-m/1:
(defun sum-like-m (ms)
  (cond ((null ms) nil)
        ((null (second ms)) ms)
        (t
         (let* ((m1 (first ms))
		(m2 (second ms))
		(c1 (monomial-coefficient m1))
		(c2 (monomial-coefficient m2))
		(td (monomial-degree m1))
		(vp1 (var-powers m1))
		(vp2 (var-powers m2)))
           (if (not (equal vp1 vp2))
	       (append (list m1)
		       (sum-like-m (rest ms)))
	     (sum-like-m
	      (append (list (list 'm (+ c1 c2) td vp1))
		      (rest (rest ms)))))))))


;;;remove-zero/1:
(defun remove-zero (ms)
  (if (null ms) nil
    (let ((c (monomial-coefficient (first ms))))
      (if (= c 0)
	  (remove-zero (rest ms))
	(append (list (first ms)) (remove-zero (rest ms)))))))




;;;mvp-minus/2:
(defun mvp-minus (pl1 pl2)
  (let ((p1 (convert-p pl1)) (p2 (convert-p pl2)))
    (append (list 'poly)
            (list (remove-zero
                   (sort-p
                    (sum-like-m
                     (sort-p (append (monomials p1)
                                        (reverse-s
                                         (monomials p2)))))))))))


;;;reverse-s/1:
(defun reverse-s (ms)
  (if (null ms) nil
    (let* ((m1 (first ms))
	   (c1 (second m1))
	   (td (third m1))
	   (var-powers (fourth m1)))
      (append (list (list 'm (- c1) td var-powers))
	      (reverse-s (rest ms))))))





;;; mvp-times/2
(defun mvp-times (p1 p2)
  (append (list 'poly)
          (list (remove-zero
                 (sort-p (sum-like-m
                             (mvp-t
                              (monomials (convert-p p1))
                              (monomials (convert-p p2)))))))))



;;; mvp-t/2
(defun mvp-t (ms1 ms2)
  (if (or (null ms1) (null ms2)) nil
    (let* ((head1 (first ms1))
	   (head2 (first ms2))
	   (tail1 (rest ms1))
	   (tail2 (rest ms2)))
      (append (list (mul-m head1 head2))
	      (mvp-t (list head1) tail2)
	      (mvp-t tail1 ms2)))))




;;;mul-m/2
(defun mul-m (m1 m2)
  (cond ((null m1) m2)
        ((null m2) m1)
        (t (let ((c1 (monomial-coefficient m1))
                 (c2 (monomial-coefficient m2))
                 (d1 (monomial-degree m1))
                 (d2 (monomial-degree m2))
                 (vps1 (var-powers m1))
                 (vps2 (var-powers m2)))
             (if (or (= 0 c1) (= 0 c2)) (list 'm 0 0 nil)
	       (append (list 'm
			     (* c1 c2)
			     (+ d1 d2)
			     (mul-v vps1 vps2))))))))

;;;mul-v/2:
(defun mul-v (vps1 vps2)
  (cond ((null vps1) vps2)
        ((null vps2) vps1)
        (t (let* ((vp1 (first vps1))
                  (vp2 (first vps2))
                  (exp1 (varpower-power vp1))
                  (exp2 (varpower-power vp2))
                  (v1 (varpower-symbol vp1))
                  (v2 (varpower-symbol vp2)))
             (if (equal v1 v2)
                 (append (list (list 'v (+ exp1 exp2) v1))
                         (mul-v (rest vps1) (rest vps2)))
	       (if (string>= v1 v2)
		   (append (list (list 'v exp2 v2))
			   (mul-v vps1 (rest vps2)))
		 (append (list (list 'v exp1 v1))
			 (mul-v (rest vps1) vps2))))))))




(defun mvp-val (polynomial values)
  (let ((parsed-p (convert-p polynomial)))
    (reduce #'+
            (mapcar (lambda (monomial)
                      (let ((coeff (monomial-coefficient monomial))
                            (var-powers (var-powers monomial)))
                        (* coeff
                           (reduce #'* (mapcar (lambda (var-power)
                                                 (let* ((var (varpower-symbol var-power))
                                                        (power (varpower-power var-power))
                                                        (value (cdr (assoc var values))))
                                                   (if value
                                                       (expt value power)
                                                     (error "Variable ~A not found in values list" var))))
                                               var-powers)))))
                    (monomials parsed-p)))))