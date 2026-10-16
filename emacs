(scroll-bar-mode 0)
(tool-bar-mode 0)
(menu-bar-mode 0)
;; =============================================================================
;; EMACS ORG-MODE HYBRID SETUP CONFIGURATION
;; =============================================================================

;; Package Manager Setup (use-package)
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu"   . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)

;; -----------------------------------------------------------------------------
;; 1. Global Directory Variables & Agenda Setup
;; -----------------------------------------------------------------------------
(setq org-directory "~/org/")

;; Recursively include all .org files in ~/org/ for agenda processing
(setq org-agenda-files
      (directory-files-recursively org-directory "\\.org$"))

;; -----------------------------------------------------------------------------
;; 2. Visual Line & Column Formatting for Text Files
;; -----------------------------------------------------------------------------
(use-package visual-fill-column
  :hook (text-mode . my/setup-text-view)
  :config
  (setq-default visual-fill-column-width 100
                visual-fill-column-center-text t)

  (defun my/setup-text-view ()
    "Enable soft word wrapping and centered text column for all text modes."
    (visual-line-mode 1)
    (visual-fill-column-mode 1)))

;; -----------------------------------------------------------------------------
;; 3. Evil Mode Integration
;; -----------------------------------------------------------------------------
(use-package evil
  :init
  (setq evil-want-keybinding nil)        ; Required before loading evil-collection / evil-org
  (setq evil-respect-visual-line-mode t) ; Makes j/k move across visual/wrapped lines
  (setq evil-undo-system 'undo-redo)     ; redo
  :config
  (evil-mode 1))

(use-package evil-org
  :after org
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;; -----------------------------------------------------------------------------
;; 4. Fast Completion & Search Framework (Vertico + Consult)
;; -----------------------------------------------------------------------------
(use-package vertico
  :init
  (vertico-mode 1))

(use-package consult
  :bind
  ("C-c s o" . my/org-ripgrep-search)
  :config
  (defun my/org-ripgrep-search ()
    "Search through all Org files in `org-directory` using ripgrep."
    (interactive)
    (consult-ripgrep org-directory)))

;; -----------------------------------------------------------------------------
;; 5. Org Mode Core, Capture Templates & Refile Setup
;; -----------------------------------------------------------------------------
(use-package org
  :bind
  (("C-c c" . org-capture)
   ("C-c a" . org-agenda))
  :config
  ;; Capture templates for fast input
  (setq org-capture-templates
        '(("i" "Inbox / Task" entry
           (file "inbox.org")
           "* TODO %?\n  Created: %U\n  %a")

          ("m" "Meeting Notes" entry
           (file+datetree "journal/journal.org")
           "* %? :meeting:\n  Created: %U\n"
           :tree-type month)

          ("j" "Daily Journal Entry" entry
           (file+olp+datetree "journal/journal.org")
           "* %?\n  Entered on %U\n"
           :tree-type month)))

  ;; Refiling options
  (setq org-refile-targets
        '((nil :maxlevel . 3)                   ; Target current buffer headings up to level 3
          (org-agenda-files :maxlevel . 2)))     ; Target any agenda file heading up to level 2

  (setq org-refile-use-outline-path 'file)       ; Show file path in refile targets
  (setq org-outline-path-complete-in-steps nil)  ; Single-step target completion
  (setq org-refile-allow-creating-parent-nodes 'confirm))

;; -----------------------------------------------------------------------------
;; 6. Evil Keybindings Shortcuts (Leader-style SPC)
;; -----------------------------------------------------------------------------
(with-eval-after-load 'evil
  ;; Global Normal mode shortcuts
  (evil-define-key 'normal 'global
    (kbd "SPC o c") 'org-capture
    (kbd "SPC o a") 'org-agenda
    (kbd "SPC s o") 'my/org-ripgrep-search)

  ;; Org-mode specific Normal mode shortcuts
  (evil-define-key 'normal org-mode-map
    (kbd "SPC m r") 'org-refile
    (kbd "SPC m t") 'org-todo))

; additional libraries
(use-package better-defaults)

(use-package dired
  :config
  (add-hook 'dired-load-hook
            (function (lambda () (load "dired-x")))))
(use-package python
  :ensure t)
(use-package ansi-color
  :ensure t)
(use-package eat
  :ensure t)

(use-package shell
  :ensure t
  :config
  (add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
  ; show ansi-colors by default
  (add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
  ; properly parse zsh extended history
  (add-hook 'shell-mode-hook '(lambda () (
      setq comint-input-ring-separator "\n: [0-9]*:[0-9]*;")))
  (add-hook 'shell-mode-hook '(lambda () (
      setq comint-input-ring-file-name "~/.histfile")))
  (add-hook 'shell-mode-hook '(lambda () (
      setq  comint-process-echoes t)))
  (add-hook 'shell-mode-hook
          '(lambda ()
              (add-hook 'comint-output-filter-functions
                      'comint-strip-ctrl-m
                      'python-pdbtrack-comint-output-filter-function t))))

; show ansi color in buffer when needed
(defun display-ansi-colors ()
  (interactive)
  (ansi-color-apply-on-region (point-min) (point-max)))

; customization
(setq term-prompt-regexp "^[^%]* % *")
(setq enable-recursive-minibuffers t)
; performance
(setq gc-cons-threshold 50000000)

(global-set-key (kbd "<f5>") 'redraw-display)
(global-set-key (kbd "C-x k") 'kill-current-buffer)

;;; Unbind 'C-x f'
(global-unset-key "\C-xf")
;;; Bind recompile
(global-set-key "\C-cr" 'recompile)

;; Have a nice display console
(set-display-table-slot standard-display-table 'vertical-border
                        (make-glyph-code ?│))
;; Reverse colors for the border to have nicer line
(set-face-inverse-video-p 'vertical-border nil)
(set-face-background 'vertical-border (face-background 'default))
