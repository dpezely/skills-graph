;;;; streamgraph.lisp - visualize programming language skills

(require 'wormtrails) ;; tested with 26269ebf14f74048faaa12bd96a1db8a3fed6216
(require 'fare-csv)
(require 'split-sequence)

(defparameter *skills-path* #P"/Users/daniel/resume/")

(defparameter wormtrails:*default-name* "Programming Skills")
(defparameter wormtrails:*bucket-width* 40)
(defparameter wormtrails:*bucket-gap* 40)

(defclass skills-chart (wormtrails:chart
			wormtrails::mouseover-mixin
			wormtrails:rainbow-colored-mixin)
  ())

(defclass skills-sample (wormtrails::sample
			 wormtrails::mouseover-mixin)
  ((dialect
    :initarg :dialect
    :accessor dialect)
   (hours
    :initform 0
    :accessor hours)
   (significance
    :initform 0
    :accessor significance)))

(defclass skills-bucket (wormtrails:bucket)
  ())


(defmethod wormtrails:create-bucket (index (chart skills-chart))
  (make-instance 'skills-bucket :index index))

(defmethod wormtrails:create-sample (thing (bucket skills-bucket))
  (make-instance 'skills-sample :thing thing :bucket bucket))

(defun load-skills-data (pathname start steps)
  (let ((expected-header (list "Year" "Language" "Dialect" "Version"
			       "Mastery" "Weeks" "Hours-per-Week" "Complexity" "Power"))
	(chart (make-instance 'skills-chart :rainbow-steps steps)))
    (declare (ignorable expected-header))
    (with-open-file (stream pathname
			    :direction :input
			    :if-does-not-exist :error)
      (let ((header-row (fare-csv:read-csv-line stream)))
	(declare (ignorable header-row))
	(assert (equal header-row expected-header) nil "Mismatched header row")
	(do ((row (fare-csv:read-csv-line stream)
		  (fare-csv:read-csv-line stream))
	     (row-number 2 (incf row-number)))
	    ((or (null row) (null (cdr row))))
	  (destructuring-bind (year language dialect version
				    mastery weeks hours-per-week complexity power) row
	    (declare (ignore version))
	    (let ((date (parse-integer year)))
	      (when (>= date start)
		(let ((sample (wormtrails:add-data
			       chart date language
			       (reduce #'* (list mastery weeks hours-per-week
						 complexity power)
				       :key #'parse-integer))))
		  (setf (dialect sample) dialect
			(hours sample) (reduce #'* (list weeks hours-per-week)
					       :key #'parse-integer)
			(significance sample) (reduce #'* (list mastery complexity power)
						      :key #'parse-integer)))))))))
    chart))

(defmethod wormtrails::mouseover-banner-html ((sample skills-sample))
  (format nil
	  "~A: ~[negligible~*~;marginal use~*~:;~:*~D% of time, ~D% significance~] in ~D"
	  (dialect sample)
	  (floor (* 100 (/ (hours sample)
			   (reduce #'+ (wormtrails::table-values
					(wormtrails::samples
					 (wormtrails::bucket sample)))
				   :key 'hours))))
	  (round (* 100 (/ (significance sample)
			   (reduce #'+ (wormtrails::table-values
					(wormtrails::samples
					 (wormtrails::bucket sample)))
				   :key 'significance))))
	  (wormtrails::index (wormtrails::bucket sample))))


;; Preference for 2010 behavior of horizontal axis labeling...
;; see: git diff 168b3864e5b63cd10bbb9606d372ae44e6f7474c vecto.lisp 
(defmethod wormtrails:draw-label ((bucket skills-bucket))
  (let ((string (wormtrails:chart-label bucket)))
    (when string
      (wormtrails::set-rgba-fill 0 0 0 0.5)
      (wormtrails::box-text (wormtrails::bounding-box bucket)
                string
                :padding wormtrails:*text-padding*
                :vertical :below
                :horizontal :center))))

;; Preference for smaller gutters...
;; see: git diff 168b3864e5b63cd10bbb9606d372ae44e6f7474c wormtrails.lisp 
(defmethod wormtrails::bounding-box ((chart skills-chart))
    (wormtrails::bounding-box
     (mapcar #'wormtrails::bounding-box (wormtrails:all-buckets chart))))

;; HACK: keep "JavaScript" from getting ellipsized; YMMV
(defun wormtrails::ellipsize (string font-size width)
  (declare (ignore font-size width))
  string)

(let ((*default-pathname-defaults* *skills-path*))
  (wormtrails:output-html (load-skills-data "languages.csv" 1987 1618)
			  "skills.png"
			  :scaler (wormtrails:linear-scaler 0.0001)))
