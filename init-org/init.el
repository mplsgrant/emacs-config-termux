(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))

(load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(use-package doom-themes
  :straight t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-dracula t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(menu-bar-mode -1)

(use-package avy
  :straight t)

(global-set-key (kbd "C-t") 'avy-goto-char)

(setq org-startup-folded t)

(use-package undo-tree
    :straight t
    :config
    (global-undo-tree-mode +1)
    (setq undo-tree-visualizer-diff nil) ; - Show diffs when browsing through the undo tree
    (setq undo-tree-visualizer-timestamps t) ; - Show relative times in the undo tree visualizer
    (setq undo-tree-auto-save-history nil ); - Save history to a file
    )

(setq backup-directory-alist '(("." . "~/.emacs_backups"))
        backup-by-copying t    ; Don't delink hardlinks
        version-control t      ; Use version numbers on backups
        delete-old-versions t  ; Automatically delete excess backups
        kept-new-versions 20   ; how many of the newest versions to keep
        kept-old-versions 5    ; and how many of the old
        )
(setq auto-save-file-name-transforms
          `((".*" ,"~/.emacs_backups" t)))

(show-paren-mode t)  ;; activate the needed timer
(setq show-paren-delay 0)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(use-package smartparens
  :straight t
  :bind (("M-]" . sp-slurp-hybrid-sexp)
             )
   )

(require 'smartparens-config)

(add-hook 'elisp-mode 'turn-on-smartparens-strict-mode)

(sp-with-modes sp-lisp-modes
  ;; disable ', it's the quote character!
  (sp-local-pair "'" nil :actions nil))

(use-package magit
  :straight t
  :config
  (global-set-key (kbd "C-x g") 'magit-status))

(use-package rainbow-delimiters
  :straight t
  )
(add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode)

(global-set-key (kbd "C-z") 'undo)

;;https://stackoverflow.com/questions/384284/how-do-i-rename-an-open-file-in-emacs
(defun rename-file-and-buffer ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let* ((name (buffer-name))
        (filename (buffer-file-name))
        (basename (file-name-nondirectory filename)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " (file-name-directory filename) basename nil basename)))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message "File '%s' successfully renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))

;; based on http://emacsredux.com/blog/2013/04/03/delete-file-and-buffer/
(defun delete-file-and-buffer ()
  "Kill the current buffer and deletes the file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if filename
        (if (y-or-n-p (concat "Do you really want to delete file " filename " ?"))
            (progn
              (delete-file filename)
              (message "Deleted file %s." filename)
              (kill-buffer)))
      (message "Not a file visiting buffer!"))))

(defun move-file (new-location)
"Write this file to NEW-LOCATION, and delete the old one."
(interactive (list (expand-file-name
                    (if buffer-file-name
                        (read-file-name "Move file to: ")
                      (read-file-name "Move file to: "
                                      default-directory
                                      (expand-file-name (file-name-nondirectory (buffer-name))
                                                        default-directory))))))
(when (file-exists-p new-location)
  (delete-file new-location))
(let ((old-location (expand-file-name (buffer-file-name))))
  (write-file new-location t)
  (when (and old-location
             (file-exists-p new-location)
             (not (string-equal old-location new-location)))
    (delete-file old-location))))

(find-file "~/.emacs.d/init-org/init.org")

(defalias 'yes-or-no-p 'y-or-n-p)
