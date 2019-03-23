;;------------------------------------------------------------------------------
;; python interpreter
(setq python-shell-interpreter "python3")

;;------------------------------------------------------------------------------
;; elpy
(use-package elpy
  :ensure t
  :init
  (setq python-indent-offset 4
        elpy-rpc-python-command "python3")
  :bind (:map elpy-mode-map
              ("M-k" . elpy-check)
              ("M-<down>" . next-error)
              ("M-<up>" . previous-error))
  :hook (python-mode . elpy-mode))

;;------------------------------------------------------------------------------
;; pyautopep8
(use-package py-autopep8
  :ensure t)
(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)