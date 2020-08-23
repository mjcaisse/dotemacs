;;------------------------------------------------------------------------------
;; python interpreter
(setq python-shell-interpreter "python3")

;;------------------------------------------------------------------------------
;; make a string into an fstring or vice versa
(defun toggle-string-to-fstring ()
  "Toggle between string and fstring at point"
  (interactive)
  (when (nth 3 (syntax-ppss))
    (save-excursion
      (goto-char (nth 8 (syntax-ppss)))
      (if (eq (char-before) ?f)
          (delete-char -1)
        (insert "f")))))

(add-hook 'python-mode-hook
          (lambda () (bind-keys :map python-mode-map
                           ("C-c s" . toggle-string-to-fstring))))

;;------------------------------------------------------------------------------
;; elpy
(use-package elpy
  :ensure t
  :init
  (setq python-indent-offset 4
        elpy-rpc-python-command "python3"
        elpy-rpc-timeout 10)
  :bind (:map elpy-mode-map
              ("M-k" . elpy-check)
              ("C-c f" . elpy-black-fix-code))
  :hook (python-mode . elpy-mode))

;;------------------------------------------------------------------------------

;; blacken
(use-package blacken
  :ensure t
  :hook (python-mode . blacken-mode))

;;------------------------------------------------------------------------------
;; pyautopep8
(use-package py-autopep8
  :ensure t
  :config
  (setq py-autopep8-options (list "--global-config=~/.config/flake8")))

;;------------------------------------------------------------------------------
;; manage python imports
(use-package pyimpsort
  :ensure t)

;;------------------------------------------------------------------------------
;; on save: remove unused imports, sort them, then format with black
;;(defun my-python-before-save-hook ()
;;  (save-excursion
;;    (elpy-black-fix-code)
;;    (pyimpsort-buffer)))

;;(add-hook 'elpy-mode-hook
;;          (lambda () (add-hook 'before-save-hook 'my-python-before-save-hook t 'local)
;;            (define-key elpy-mode-map (kbd "<M-up>") nil)
;;            (define-key elpy-mode-map (kbd "<M-down>") nil)))


;;------------------------------------------------------------------------------
;; jupyter
(defun my-ein-keybindings ()
  (bind-keys :map ein:notebook-mode-map
             ("C-c M-l" . ein:worksheet-clear-all-output)))

(use-package ein
  :ensure t
  :config
  (setq ein:notebook-autosave-frequency 0)
  :hook (ein:notebook-mode . my-ein-keybindings))


;;------------------------------------------------------------------------------
;; symboly things
;;
(set-fontset-font "fontset-default" '(#x2131 . #x2757) "Symbola")
(add-hook
 'python-mode-hook
 (lambda ()
   (mapc (lambda (pair) (push pair prettify-symbols-alist))
         '(;; Syntax
           ("def" .      #x1d487)
           ;; ("not" .      #x2757)
           ("in" .       #x2208)
           ("not in" .   #x2209)
           ("!=" . #x2260)
           ("<=" . #x2264)
           (">=" . #x2265)
           ;; ("return" .   #x27fc)
           ;; ("yield" .    #x27fb)
           ;; ("for" .      #x2200)
           ;; Base Types
           ;; ("int" .      #x2124)
           ;; ("float" .    #x211d)
           ;; ("str" .      #x1d54a)
           ("True" .    #x1d54b)
           ("False" .   #x1d53d)
           ("None" .    #x2205)
           ;; Mypy
           ;; ("Dict" .     #x1d507)
           ;; ("List" .     #x2112)
           ;; "Tuple" .    #x2a02)
           ;; ("Set" .      #x2126)
           ;; ("Iterable" . #x1d50a)
           ;; ("Any" .      #x2754)
           ;; ("Union" .    #x22c3)
           ))))
;;------------------------------------------------------------------------------
;;------------------------------------------------------------------------------
