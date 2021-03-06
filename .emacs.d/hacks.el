;;------------------------------------------------------------------------------
;; Org-mode customization: allow left-alignment of numeric fields

(defcustom org-table-numeric-field-alignment "r"
  "The default alignment for fields containing numbers."
  :group 'org-table-settings
  :type 'string)

(defun my-org-table-align ()
  "Align the table at point by aligning all vertical bars."
  (interactive)
  (let ((beg (org-table-begin))
	(end (copy-marker (org-table-end))))
    (org-table-save-field
     ;; Make sure invisible characters in the table are at the right
     ;; place since column widths take them into account.
     (org-font-lock-ensure beg end)
     (move-marker org-table-aligned-begin-marker beg)
     (move-marker org-table-aligned-end-marker end)
     (goto-char beg)
     (org-table-with-shrunk-columns
      (let* ((indent (progn (looking-at "[ \t]*") (match-string 0)))
	     ;; Table's rows as lists of fields.  Rules are replaced
	     ;; by nil.  Trailing spaces are removed.
	     (fields (mapcar
		      (lambda (l)
			(and (not (string-match-p org-table-hline-regexp l))
			     (org-split-string l "[ \t]*|[ \t]*")))
		      (split-string (buffer-substring beg end) "\n" t)))
	     ;; Compute number of columns.  If the table contains no
	     ;; field, create a default table and bail out.
	     (columns-number
	      (if fields (apply #'max (mapcar #'length fields))
		(kill-region beg end)
		(org-table-create org-table-default-size)
		(user-error "Empty table - created default table")))
	     (widths nil)
	     (alignments nil))
	;; Compute alignment and width for each column.
	(dotimes (i columns-number)
	  (let* ((max-width 1)
		 (fixed-align? nil)
		 (numbers 0)
		 (non-empty 0))
	    (dolist (row fields)
	      (let ((cell (or (nth i row) "")))
		(setq max-width (max max-width (org-string-width cell)))
		(cond (fixed-align? nil)
		      ((equal cell "") nil)
		      ((string-match "\\`<\\([lrc]\\)[0-9]*>\\'" cell)
		       (setq fixed-align? (match-string 1 cell)))
		      (t
		       (cl-incf non-empty)
		       (when (string-match-p org-table-number-regexp cell)
			 (cl-incf numbers))))))
	    (push max-width widths)
	    (push (cond
		   (fixed-align?)
		   ((>= numbers (* org-table-number-fraction non-empty))
                    org-table-numeric-field-alignment) ;; normally always "r"
		   (t "l"))
		  alignments)))
	(setq widths (nreverse widths))
	(setq alignments (nreverse alignments))
	;; Store alignment of this table, for later editing of single
	;; fields.
	(setq org-table-last-alignment alignments)
	(setq org-table-last-column-widths widths)
	;; Build new table rows.  Only replace rows that actually
	;; changed.
	(dolist (row fields)
	  (let ((previous (buffer-substring (point) (line-end-position)))
		(new
		 (format "%s|%s|"
			 indent
			 (if (null row)	;horizontal rule
			     (mapconcat (lambda (w) (make-string (+ 2 w) ?-))
					widths
					"+")
			   (let ((cells	;add missing fields
				  (append row
					  (make-list (- columns-number
							(length row))
						     ""))))
			     (mapconcat #'identity
					(cl-mapcar #'org-table--align-field
						   cells
						   widths
						   alignments)
					"|"))))))
	    (if (equal new previous)
		(forward-line)
	      (insert new "\n")
	      (delete-region (point) (line-beginning-position 2)))))
	(set-marker end nil)
	(when org-table-overlay-coordinates (org-table-overlay-coordinates))
	(setq org-table-may-need-update nil))))))

(advice-add #'org-table-align :override #'my-org-table-align)
