;;------------------------------------------------------------------------------
;; font: inconsolata
(setq my-font-height 100)
(when (eq system-type 'darwin)
  (setq my-font-height 120))

(set-face-attribute 'default nil
                    :family "Source Code Pro"
                    :height my-font-height
                    :weight 'normal
                    :width 'normal)

;;(set-fontset-font "fontset-default"
;;                  '(#x0100 . #xffff)
;;                  (font-spec :family "Source Code Pro"
;;                             :height my-font-height
;;                             :weight 'normal
;;                             :width 'normal))

;;(set-default-font "Source Code Pro")

;;------------------------------------------------------------------------------
(use-package dash
  :ensure t)

;;------------------------------------------------------------------------------
;; Sizing/docking
(setq frame-resize-pixelwise t)

(defun monitor-width (monitor)
  (nth 3 (assq 'geometry monitor)))

(defun frame-max-height (&optional frame)
  (interactive)
  (set-frame-parameter frame 'fullscreen 'fullheight))

(defun dock-frame-left (&optional frame monitor)
  (interactive)
  (setq frame (or frame (selected-frame)))
  (setq monitor (or monitor (frame-monitor-attributes frame)))
  (let* ((monitor-list (-take-while
                        (lambda (x) (not (equal monitor x)))
                        (display-monitor-attributes-list)))
         (widths (mapcar #'monitor-width monitor-list))
         (x (apply '+ widths)))
    (set-frame-parameter frame 'left x)))

(defun dock-frame-right (&optional frame monitor)
  (interactive)
  (setq frame (or frame (selected-frame)))
  (setq monitor (or monitor (frame-monitor-attributes frame)))
  (let* ((monitor-list (-take-while
                        (lambda (x) (not (equal monitor x)))
                        (display-monitor-attributes-list)))
         (widths (mapcar #'monitor-width monitor-list))
         (x (+ (apply '+ widths) (monitor-width monitor))))
    (set-frame-parameter frame 'left (- x (frame-pixel-width frame)))))

(defun size-frame-default ()
  (set-frame-parameter nil 'width column-wrap-hard)
  (frame-max-height))

(bind-key "C-S-<f11>" 'frame-max-height)
(bind-key "C-<f11>" 'dock-frame-left)
(bind-key "C-<f12>" 'dock-frame-right)

;;------------------------------------------------------------------------------
;; Frame opacity
(defun sanityinc/adjust-opacity (frame incr)
  (let* ((oldalpha (or (frame-parameter frame 'alpha) 100))
         (newalpha (+ incr oldalpha)))
    (when (and (<= frame-alpha-lower-limit newalpha) (>= 100 newalpha))
      (modify-frame-parameters frame (list (cons 'alpha newalpha))))))

(bind-key "M-C-8" (lambda () (interactive) (sanityinc/adjust-opacity nil -2)))
(bind-key "M-C-9" (lambda () (interactive) (sanityinc/adjust-opacity nil 2)))
(bind-key "M-C-0" (lambda () (interactive) (modify-frame-parameters nil `((alpha . 100)))))

;;------------------------------------------------------------------------------
;; All the icons!
(use-package all-the-icons
  :ensure t
  :config
  (unless (file-exists-p
           (concat (getenv "HOME") "/.local/share/fonts/all-the-icons.ttf"))
    (all-the-icons-install-fonts t)))
