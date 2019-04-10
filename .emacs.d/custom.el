(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ad-redefinition-action (quote accept))
 '(backup-directory-alist (quote (("." . "~/.emacs.d/backups"))))
 '(display-line-numbers-type (quote relative))
 '(global-display-line-numbers-mode t)
 '(indent-tabs-mode nil)
 '(jiralib-url "https://jira.swisscom.com")
 '(load-prefer-newer t)
 '(mouse-yank-at-point t)
 '(org-hide-emphasis-markers t)
 '(org-log-done t)
 '(org-src-fontify-natively t)
 '(org-src-tab-acts-natively t)
 '(org-startup-indented t)
 '(org-tags-column 0)
 '(org-todo-keyword-faces
   (quote
    (("TODO" . "red")
     ("DRAFT" . "yellow")
     ("DONE" . "green")
     ("CANCELED" . "blue"))))
 '(package-archives
   (quote
    (("gnu" . "https://elpa.gnu.org/packages/")
     ("marmalade" . "https://marmalade-repo.org/packages/")
     ("melpa" . "https://melpa.org/packages/"))))
 '(package-selected-packages
   (quote
    (evil-commentary markdown-mode esup projectile company swiper-helm helm-flx helm all-the-icons neotree writeroom-mode diminish toc-org org-jira ox-jira ox-gfm evil which-key smooth-scrolling imenu-anywhere unfill auto-compile use-package)))
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(show-trailing-whitespace t)
 '(tool-bar-mode nil)
 '(tooltip-mode nil)
 '(uniquify-buffer-name-style (quote post-forward) nil (uniquify) "Customized with use-package uniquify")
 '(use-package-always-defer t)
 '(use-package-always-ensure t)
 '(use-package-verbose nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Operator Mono SSm Medium" :foundry "outline" :slant normal :weight light :height 162 :width normal))))
 '(fixed-pitch ((t (:family "Operator Mono Medium"))))
 '(org-document-title ((t (:inherit default :weight bold :foreground "SystemWindowText" :font "Roboto" :height 2.0 :underline nil))))
 '(org-indent ((t (:inherit (org-hide fixed-pitch)))))
 '(org-level-1 ((t (:inherit default :weight bold :foreground "SystemWindowText" :font "Roboto" :height 1.75))))
 '(org-level-2 ((t (:inherit default :weight bold :foreground "SystemWindowText" :font "Roboto" :height 1.5))))
 '(org-level-3 ((t (:inherit default :weight bold :foreground "SystemWindowText" :font "Roboto" :height 1.25))))
 '(org-level-4 ((t (:inherit default :weight bold :foreground "SystemWindowText" :font "Roboto" :height 1.1))))
 '(org-level-5 ((t (:inherit default :weight bold :foreground "SystemWindowText" :font "Roboto"))))
 '(org-level-6 ((t (:inherit default :weight bold :foreground "SystemWindowText" :font "Roboto"))))
 '(org-level-7 ((t (:inherit default :weight bold :foreground "SystemWindowText" :font "Roboto"))))
 '(org-level-8 ((t (:inherit default :weight bold :foreground "SystemWindowText" :font "Roboto"))))
 '(variable-pitch ((t (:family "Roboto" :height 180 :weight light)))))
