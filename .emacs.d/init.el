;; DO NOT EDIT THIS FILE DIRECTLY
;; This is a file generated from a literate programing source file located at
;; https://github.com/Zyst/dotfiles/blob/master/.emacs.d/init.org
;; You should make any changes there and regenerate it from Emacs org-mode using C-c C-v t

;; Use a hook so the message doesn't get clobbered by other messages.
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

(let ((file-name-handler-alist nil))

;;(setq debug-on-error t)

(setq gc-cons-threshold most-positive-fixnum)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(customize-set-variable 'package-archives
                        '(("gnu"       . "https://elpa.gnu.org/packages/")
                          ("marmalade" . "https://marmalade-repo.org/packages/")
                          ("melpa"     . "https://melpa.org/packages/")))

(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(when (not (package-installed-p 'use-package))
  (package-install 'use-package))

(require 'use-package)

(customize-set-variable 'use-package-always-ensure t)

(customize-set-variable 'use-package-always-defer t)

(customize-set-variable 'use-package-verbose nil)

(customize-set-variable 'load-prefer-newer t)
(use-package auto-compile
  :defer nil
  :config (auto-compile-on-load-mode))

(customize-set-variable 'mouse-yank-at-point t)

;; (setq completion-ignore-case t)
;; (customize-set-variable 'read-file-name-completion-ignore-case t)
;; (customize-set-variable 'read-buffer-completion-ignore-case t)

(when (>= emacs-major-version 26)
  (use-package display-line-numbers
    :defer nil
    :ensure nil
    :config
    (global-display-line-numbers-mode)))

(customize-set-variable 'show-trailing-whitespace t)

(show-paren-mode)

(customize-set-variable 'indent-tabs-mode nil)

(customize-set-variable 'backup-directory-alist `(("." . ,(concat user-emacs-directory "backups"))))

(when (fboundp 'winner-mode) (winner-mode))

(use-package unfill
  :bind
  ("M-q" . unfill-toggle)
  ("A-q" . unfill-paragraph))

(use-package saveplace
  :defer nil
  :config
  (save-place-mode))

(use-package imenu-anywhere
  :bind
  ("M-i" . helm-imenu-anywhere))

(use-package smooth-scrolling
  :config
  (smooth-scrolling-mode 1))

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(customize-set-variable 'ad-redefinition-action 'accept)

(setq inhibit-compacting-font-caches t)

(cond ((eq system-type 'darwin)
       
       )
      ((eq system-type 'windows-nt)
       
       )
      ((eq system-type 'gnu/linux)
       
       ))

(require 'bind-key)

(use-package which-key
  :defer nil
  :diminish which-key-mode
  :config
  (which-key-mode))

(setq evil-want-C-u-scroll t)

(use-package evil
  :ensure t
  :defer .1
  :config
  (evil-mode)

  (use-package evil-commentary
    :ensure t
    :bind (:map evil-normal-state-map
                ("gc" . evil-commentary))))

(use-package org
  :bind
    
  :custom
    (org-log-done t)
    (org-startup-indented t)
    ;; (org-confirm-babel-evaluate nil)
    (org-src-fontify-natively t)
    (org-src-tab-acts-natively t)
    (org-hide-emphasis-markers t)
    (org-tags-column 0)
    (org-todo-keyword-faces
     '(("TODO" . "red")
       ("DRAFT" . "yellow")
       ("DONE" . "green")
       ("CANCELED" . "blue")))
  :custom-face
    (variable-pitch ((t (:family "Roboto" :height 180 :weight light))))
    ;; (variable-pitch ((t (:family "Source Sans Pro" :height 180 :weight light))))
    (fixed-pitch ((t (:family "Operator Mono Medium"))))
    (org-indent ((t (:inherit (org-hide fixed-pitch)))))
  :hook
    (org-babel-after-execute . org-redisplay-inline-images)
    (org-mode . (lambda () (add-hook 'after-save-hook 'org-babel-tangle
                                     'run-at-end 'only-in-org-mode)))
    (org-babel-pre-tangle  . (lambda ()
                               (setq zz/pre-tangle-time (current-time))))
    (org-babel-post-tangle . (lambda ()
                               (message "org-babel-tangle took %s"
                                               (format "%.2f seconds"
                                                       (float-time (time-since zz/pre-tangle-time))))))
    (org-mode . visual-line-mode)
    (org-mode . variable-pitch-mode)
  :config
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((python    . t)
       (shell     . t)
       (calc      . t)))
    (font-lock-add-keywords 'org-mode
                            '(("^ *\\([-]\\) "
                               (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
    (let* ((variable-tuple
            (cond ((x-list-fonts   "Roboto")          '(:font   "Roboto"))
                  ((x-list-fonts   "Source Sans Pro") '(:font   "Source Sans Pro"))
                  ((x-list-fonts   "Lucida Grande")   '(:font   "Lucida Grande"))
                  ((x-list-fonts   "Verdana")         '(:font   "Verdana"))
                  ((x-family-fonts "Sans Serif")      '(:family "Sans Serif"))
                  (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
           (base-font-color (face-foreground 'default nil 'default))
           (headline       `(:inherit default :weight bold :foreground ,base-font-color)))
    
      (custom-theme-set-faces
       'user
       `(org-level-8        ((t (,@headline ,@variable-tuple))))
       `(org-level-7        ((t (,@headline ,@variable-tuple))))
       `(org-level-6        ((t (,@headline ,@variable-tuple))))
       `(org-level-5        ((t (,@headline ,@variable-tuple))))
       `(org-level-4        ((t (,@headline ,@variable-tuple :height 1.1))))
       `(org-level-3        ((t (,@headline ,@variable-tuple :height 1.25))))
       `(org-level-2        ((t (,@headline ,@variable-tuple :height 1.5))))
       `(org-level-1        ((t (,@headline ,@variable-tuple :height 1.75))))
       `(org-document-title ((t (,@headline ,@variable-tuple :height 2.0 :underline nil))))))
    (eval-after-load 'face-remap '(diminish 'buffer-face-mode))
    (eval-after-load 'simple '(diminish 'visual-line-mode)))

(use-package org-indent
  :ensure nil
  :diminish)

(use-package ox-md
  :ensure nil
  :defer 3
  :after org)

(use-package ox-gfm
  :defer 3
  :after org)

(use-package ox-jira
  :defer 3
  :after org)
(use-package org-jira
  :defer 3
  :after org
  :custom
  (jiralib-url "https://jira.swisscom.com"))

(use-package ox-confluence
  :defer 3
  :ensure nil
  :after org)

(defalias 'console-mode 'shell-script-mode)

(use-package org-bullets
  :disabled
  :after org
  :hook
  (org-mode . (lambda () (org-bullets-mode 1))))

(use-package toc-org
  :after org
  :hook
  (org-mode . toc-org-enable))

(defun zz/org-reformat-buffer ()
  (interactive)
  (when (y-or-n-p "Really format current buffer? ")
    (let ((document (org-element-interpret-data (org-element-parse-buffer))))
      (erase-buffer)
      (insert document)
      (goto-char (point-min)))))

(when (>= emacs-major-version 26)
  (pixel-scroll-mode))

(use-package diminish
  :defer 1)

(add-to-list
 'custom-theme-load-path "~/.emacs.d/vendor/egoist-one-theme/")
(load-theme 'atom-one-dark t)

(use-package desktop
  :defer nil
  :custom
  (desktop-restore-eager   1   "Restore only the first buffer right away")
  (desktop-lazy-idle-delay 1   "Restore the rest of the buffers 1 seconds later")
  (desktop-lazy-verbose    nil "Be silent about lazily opening buffers")
  :bind
  ("C-M-s-k" . desktop-clear)
  :config
  (desktop-save-mode))

(use-package uniquify
  :defer 1
  :ensure nil
  :custom
  (uniquify-after-kill-buffer-p t)
  (uniquify-buffer-name-style 'post-forward)
  (uniquify-strip-common-suffix t))

(use-package hl-line
  :defer nil
  :config
  (global-hl-line-mode))
(use-package col-highlight
  :disabled
  :defer nil
  :config
  (col-highlight-toggle-when-idle)
  (col-highlight-set-interval 2))
(use-package crosshairs
  :disabled
  :defer nil
  :config
  (crosshairs-mode))

(use-package recentf
  :defer 1
  :custom
  (recentf-max-menu-items 100)
  (recentf-max-saved-items 100)
  :init
  (recentf-mode))

(use-package midnight
  :defer 3
  :config
  (setq midnight-period 7200)
  (midnight-mode 1))

(use-package writeroom-mode)

(use-package neotree
  :config
  (customize-set-variable 'neo-theme (if (display-graphic-p) 'icons 'arrow))
  (customize-set-variable 'neo-smart-open t)
  (customize-set-variable 'projectile-switch-project-action 'neotree-projectile-action)
  (defun neotree-project-dir ()
    "Open NeoTree using the git root."
    (interactive)
    (let ((project-dir (projectile-project-root))
          (file-name (buffer-file-name)))
      (neotree-toggle)
      (if project-dir
          (if (neo-global--window-exists-p)
              (progn
                (neotree-dir project-dir)
                (neotree-find file-name)))
        (message "Could not find git project root."))))
  :bind
  ([f8] . neotree-project-dir))

(use-package all-the-icons
  :defer 3)

(use-package helm
  :defer 1
  :diminish helm-mode
  :bind
  (("C-x C-f"       . helm-find-files)
   ("C-x C-b"       . helm-buffers-list)
   ("C-x b"         . helm-multi-files)
   ("M-x"           . helm-M-x)
   :map helm-find-files-map
   ("C-<backspace>" . helm-find-files-up-one-level)
   ("C-f"           . helm-execute-persistent-action)
   ([tab]           . helm-ff-RET))
  :config
  (defun daedreth/helm-hide-minibuffer ()
    (when (with-helm-buffer helm-echo-input-in-header-line)
      (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
        (overlay-put ov 'window (selected-window))
        (overlay-put ov 'face
                     (let ((bg-color (face-background 'default nil)))
                       `(:background ,bg-color :foreground ,bg-color)))
        (setq-local cursor-type nil))))
  (add-hook 'helm-minibuffer-set-up-hook 'daedreth/helm-hide-minibuffer)
  (setq helm-autoresize-max-height 0
        helm-autoresize-min-height 40
        helm-M-x-fuzzy-match t
        helm-buffers-fuzzy-matching t
        helm-recentf-fuzzy-match t
        helm-semantic-fuzzy-match t
        helm-imenu-fuzzy-match t
        helm-split-window-in-side-p nil
        helm-move-to-line-cycle-in-source nil
        helm-ff-search-library-in-sexp t
        helm-scroll-amount 8
        helm-echo-input-in-header-line nil)
  :init
  (helm-mode 1))

(require 'helm-config)
(helm-autoresize-mode 1)

(use-package helm-flx
  :custom
  (helm-flx-for-helm-find-files t)
  (helm-flx-for-helm-locate t)
  :config
  (helm-flx-mode +1))

(use-package swiper-helm
  :bind
  ("C-s" . swiper))

(use-package company
  :diminish company-mode
  :hook
  (after-init . global-company-mode))

(use-package projectile
  :defer 2
  :diminish projectile-mode
  :config
  (projectile-global-mode))

(use-package flyspell
  :defer 1
  :hook (text-mode . flyspell-mode)
  :diminish
  :bind (:map flyspell-mouse-map
              ([down-mouse-3] . #'flyspell-correct-word)
              ([mouse-3]      . #'undefined)))

(use-package esup)

(defmacro measure-time (&rest body)
  "Measure the time it takes to evaluate BODY."
  `(let ((time (current-time)))
     ,@body
     (message "%.06f" (float-time (time-since time)))))

(use-package markdown-mode
  :hook
  (markdown-mode . visual-line-mode)
  (markdown-mode . variable-pitch-mode))

)

(setq gc-cons-threshold (* 2 1000 1000))
