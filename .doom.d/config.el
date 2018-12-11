;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-
;;;
;; prettier config
(require 'prettier-js)
;; (setq prettier-js-args '(
;;   "--trailing-comma" "all"
;;   "--bracket-spacing" "false"
;;   "--print-width" "80"
;; ))

(defun setup-tide-mode ()
(when (or (eq major-mode 'typescript-mode)
              (and (eq major-mode 'web-mode)
                   buffer-file-name
                   (equal (file-name-extension buffer-file-name) "tsx")))

  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (prettier-js-mode +1)
  (tide-hl-identifier-mode +1)
  (set! :company-backend ('typescript-mode 'web-mode) '(company-tide))
              (set! :jump 'typescript-mode
                :definition #'tide-jump-to-definition
                :references #'tide-references
                :documentation #'tide-documentation-at-point)


  ))

;; ## added by OPAM user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
;; ## end of OPAM user-setup addition for emacs / base ## keep this line
;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)


;; Place your private configuration here
(add-hook! typescript-mode #'setup-tide-mode)
(add-hook! web-mode #'setup-tide-mode)
(add-hook! typescript-mode #'rainbow-delimiters-mode)

(def-package! tide
              :after typescript-mode
              :config
              (set! :company-backend 'typescript-mode '(company-tide))
              (set! :jump 'typescript-mode
                :definition #'tide-jump-to-definition
                :references #'tide-references
                :documentation #'tide-documentation-at-point))

;;(setq merlin-ac-setup t)

(defmacro my/with-advice (adlist &rest body)
  "Execute BODY with temporary advice in ADLIST.

Each element of ADLIST should be a list of the form
  (SYMBOL WHERE FUNCTION [PROPS])
suitable for passing to `advice-add'.  The BODY is wrapped in an
`unwind-protect' form, so the advice will be removed even in the
event of an error or nonlocal exit."
  (declare (debug ((&rest (&rest form)) body))
           (indent 1))
  `(progn
     ,@(mapcar (lambda (adform)
                 (cons 'advice-add adform))
               adlist)
     (unwind-protect (progn ,@body)
       ,@(mapcar (lambda (adform)
                   `(advice-remove ,(car adform) ,(nth 2 adform)))
                 adlist))))
(defun my/call-logging-hooks (command &optional verbose)
  "Call COMMAND, reporting every hook run in the process.
Interactively, prompt for a command to execute.

Return a list of the hooks run, in the order they were run.
Interactively, or with optional argument VERBOSE, also print a
message listing the hooks."
  (interactive "CCommand to log hooks: \np")
  (let* ((log     nil)
         (logger (lambda (&rest hooks)
                   (setq log (append log hooks nil)))))
    (my/with-advice
        ((#'run-hooks :before logger))
      (call-interactively command))
    (when verbose
      (message
       (if log "Hooks run during execution of %s:"
         "No hooks run during execution of %s.")
       command)
      (dolist (hook log)
        (message "> %s" hook)))
    log))
;; ## added by OPAM user-setup for emacs / base ## cfd3c9b7837c85cffd0c59de521990f0 ## you can edit, but keep this line
(provide 'opam-user-setup)

;; Base configuration for OPAM

(defun opam-shell-command-to-string (command)
  "Similar to shell-command-to-string, but returns nil unless the process
  returned 0, and ignores stderr (shell-command-to-string ignores return value)"
  (let* ((return-value 0)
         (return-string
          (with-output-to-string
            (setq return-value
                  (with-current-buffer standard-output
                    (process-file shell-file-name nil '(t nil) nil
                                  shell-command-switch command))))))
    (if (= return-value 0) return-string nil)))

(defun opam-update-env (switch)
  "Update the environment to follow current OPAM switch configuration"
  (interactive
   (list
    (let ((default
            (car (split-string (opam-shell-command-to-string "opam switch show --safe")))))
      (completing-read
       (concat "opam switch (" default "): ")
       (split-string (opam-shell-command-to-string "opam switch list -s --safe") "\n")
       nil t nil nil default))))
  (let* ((switch-arg (if (= 0 (length switch)) "" (concat "--switch " switch)))
         (command (concat "opam config env --safe --sexp " switch-arg))
         (env (opam-shell-command-to-string command)))
    (when (and env (not (string= env "")))
      (dolist (var (car (read-from-string env)))
        (setenv (car var) (cadr var))
        (when (string= (car var) "PATH")
          (setq exec-path (split-string (cadr var) path-separator)))))))

(opam-update-env nil)

(defvar opam-share
  (let ((reply (opam-shell-command-to-string "opam config var share --safe")))
    (when reply (substring reply 0 -1))))

(add-to-list 'load-path (concat opam-share "/emacs/site-lisp"))
;; OPAM-installed tools automated detection and initialisation

(defun opam-setup-tuareg ()
  (add-to-list 'load-path (concat opam-share "/tuareg") t)
  (load "tuareg-site-file"))

(defun opam-setup-add-ocaml-hook (h)
  (add-hook 'tuareg-mode-hook h t)
  (add-hook 'caml-mode-hook h t))

(defun opam-setup-complete ()
  (if (require 'company nil t)
    (opam-setup-add-ocaml-hook
      (lambda ()
         (company-mode)
         (defalias 'auto-complete 'company-complete)))
    (require 'auto-complete nil t)))

(defun opam-setup-ocp-indent ()
  (opam-setup-complete)
  (autoload 'ocp-setup-indent "ocp-indent" "Improved indentation for Tuareg mode")
  (autoload 'ocp-indent-caml-mode-setup "ocp-indent" "Improved indentation for Caml mode")
  (add-hook 'tuareg-mode-hook 'ocp-setup-indent t)
  (add-hook 'caml-mode-hook 'ocp-indent-caml-mode-setup  t))

(defun opam-setup-ocp-index ()
  (autoload 'ocp-index-mode "ocp-index" "OCaml code browsing, documentation and completion based on build artefacts")
  (opam-setup-add-ocaml-hook 'ocp-index-mode))

(defun opam-setup-merlin ()
  (opam-setup-complete)
  (require 'merlin)
  (opam-setup-add-ocaml-hook 'merlin-mode)

  (defcustom ocp-index-use-auto-complete nil
    "Use auto-complete with ocp-index (disabled by default by opam-user-setup because merlin is in use)"
    :group 'ocp_index)
  (defcustom merlin-ac-setup 'easy
    "Use auto-complete with merlin (enabled by default by opam-user-setup)"
    :group 'merlin-ac)

  ;; So you can do it on a mac, where `C-<up>` and `C-<down>` are used
  ;; by spaces.
  (define-key merlin-mode-map
    (kbd "C-c <up>") 'merlin-type-enclosing-go-up)
  (define-key merlin-mode-map
    (kbd "C-c <down>") 'merlin-type-enclosing-go-down)
  (set-face-background 'merlin-type-face "skyblue"))

(defun opam-setup-utop ()
  (autoload 'utop "utop" "Toplevel for OCaml" t)
  (autoload 'utop-minor-mode "utop" "Minor mode for utop" t)
  (add-hook 'tuareg-mode-hook 'utop-minor-mode))

(defvar opam-tools
  '(("tuareg" . opam-setup-tuareg)
    ("ocp-indent" . opam-setup-ocp-indent)
    ("ocp-index" . opam-setup-ocp-index)
    ("merlin" . opam-setup-merlin)
    ("utop" . opam-setup-utop)))

(defun opam-detect-installed-tools ()
  (let*
      ((command "opam list --installed --short --safe --color=never")
       (names (mapcar 'car opam-tools))
       (command-string (mapconcat 'identity (cons command names) " "))
       (reply (opam-shell-command-to-string command-string)))
    (when reply (split-string reply))))

(defvar opam-tools-installed (opam-detect-installed-tools))

(defun opam-auto-tools-setup ()
  (interactive)
  (dolist (tool opam-tools)
    (when (member (car tool) opam-tools-installed)
     (funcall (symbol-function (cdr tool))))))

(opam-auto-tools-setup)
;; ## end of OPAM user-setup addition for emacs / base ## keep this line

;;----------------------------------------------------------------------------
;; Reason setup
;;----------------------------------------------------------------------------

(defun shell-cmd (cmd)
    "Returns the stdout output of a shell command or nil if the command returned
     an error"
       (car (ignore-errors (apply 'process-lines (split-string cmd)))))

(defun reason-cmd-where (cmd)
    (let ((where (shell-cmd cmd)))
          (if (not (string-equal "unknown flag ----where" where))
                  where)))

(let* ((refmt-bin (or (reason-cmd-where "refmt ----where")
                                            (shell-cmd "which refmt")))
              (merlin-bin (or (reason-cmd-where "ocamlmerlin ----where")
                                                     (shell-cmd "which ocamlmerlin")))
                     (merlin-base-dir (when merlin-bin
                                                                  (replace-regexp-in-string "bin/ocamlmerlin$" "" merlin-bin))))
    ;; Add merlin.el to the emacs load path and tell emacs where to find ocamlmerlin
      (when merlin-bin
            (add-to-list 'load-path (concat merlin-base-dir "share/emacs/site-lisp/"))
                (setq merlin-command merlin-bin))

        (when refmt-bin
              (setq refmt-command refmt-bin)))

(require 'reason-mode)
(require 'merlin)
(add-hook 'reason-mode-hook (lambda ()
                                                            (add-hook 'before-save-hook 'refmt-before-save)
                                                                                          (merlin-mode)))

(setq merlin-ac-setup t)
