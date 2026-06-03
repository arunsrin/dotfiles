;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-
;;
;; Modernized 2026: vertico/consult (Telescope-style nav), eglot+corfu (LSP+
;; completion like nvim-cmp), diff-hl (gitsigns), tab-bar (replaces elscreen).
;; Old config archived at init.el.bak. Personal keybindings/workflow preserved.

;;; ----------------------------------------------------------------------------
;;; Package bootstrap + use-package
;;; ----------------------------------------------------------------------------

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq package-check-signature nil)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; use-package ships with Emacs 29, but ensure it's loadable.
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t   ; auto-install missing packages
      use-package-always-defer nil)

;; Keep Custom's churn out of this file.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;; ----------------------------------------------------------------------------
;;; Basic UI / behavior
;;; ----------------------------------------------------------------------------

(setq inhibit-startup-message t)

;; Theme: dark in the terminal (wheatgrass), light in a GUI frame.
;; (You run emacs-nox / emacsclient -t, so this is wheatgrass in practice.)
(if (display-graphic-p)
    (load-theme 'tsdh-light t)
  (load-theme 'wheatgrass t))

(defun on-frame-open (frame)
  "Make terminal frames inherit the terminal's background."
  (unless (display-graphic-p frame)
    (set-face-background 'default "unspecified-bg" frame)))
(on-frame-open (selected-frame))
(add-hook 'after-make-frame-functions #'on-frame-open)

;; Chrome: no toolbar/scrollbar, keep menu bar (your preference).
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode 1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'menu-bar-mode) (menu-bar-mode 1))

;; Clock in the modeline.
(setq display-time-24hr-format t
      display-time-day-and-date t)
(display-time)

;; y/n instead of yes/no (modern built-in; replaces the old fn override).
(setq use-short-answers t)

;; Scroll one line at a time.
(setq scroll-step 1
      scroll-conservatively 10000)

(setq transient-mark-mode 1)
(mouse-avoidance-mode 'animate)

;; Match nvim feel: relative line numbers in programming buffers.
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Highlight matching parens (was in custom.el).
(show-paren-mode 1)

;;; ----------------------------------------------------------------------------
;;; Backups / autosaves (centralized, cross-platform — kept from your config)
;;; ----------------------------------------------------------------------------

(cond
 ((string-match "linux" system-configuration)
  (defvar autosave-dir "~/.emacs.d/emacs_autosaves/")
  (defvar backup-dir "~/.emacs.d/emacs_backups/")
  (setq backup-directory-alist (list (cons "." backup-dir))))
 ((string-match "mingw" system-configuration)
  (defvar autosave-dir "C:/.emacs.d/emacs_autosaves/")
  (defvar backup-dir "C:/.emacs.d/emacs_backups/")
  (setq backup-directory-alist (list (cons "." backup-dir)))))
(make-directory autosave-dir t)

(defun auto-save-file-name-p (filename)
  (string-match "^#.*#$" (file-name-nondirectory filename)))
(defun make-auto-save-file-name ()
  (concat autosave-dir
          (if buffer-file-name
              (concat "#" (file-name-nondirectory buffer-file-name) "#")
            (expand-file-name (concat "#%" (buffer-name) "#")))))

;;; ----------------------------------------------------------------------------
;;; PATH from shell (so Emacs sees gopls/pyright/asdf etc.)
;;; ----------------------------------------------------------------------------

(use-package exec-path-from-shell
  :config
  (when (or (memq window-system '(mac ns x pgtk))
            (daemonp))
    (exec-path-from-shell-initialize)))

;; Go environment (corrected username: was /home/arunsrin).
(setenv "GOPATH" (expand-file-name "~/go"))
(add-to-list 'exec-path (expand-file-name "~/go/bin"))

;;; ----------------------------------------------------------------------------
;;; Fuzzy navigation — the Telescope-equivalent stack
;;;   vertico   : vertical completion UI (the minibuffer list)
;;;   orderless : space-separated fuzzy matching ("foo bar" matches in any order)
;;;   marginalia: rich annotations next to candidates
;;;   consult   : commands — buffer switch, ripgrep, line search, recentf, imenu
;;;   savehist  : remember minibuffer history / sort by recency
;;; ----------------------------------------------------------------------------

(use-package vertico
  :init (vertico-mode))

(use-package savehist
  :ensure nil                      ; built-in
  :init (savehist-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

(use-package consult
  :bind (;; Telescope-style entry points
         ("C-x b"   . consult-buffer)        ; <leader>b  (fuzzy buffer switch)
         ("C-x C-r" . consult-recent-file)   ; recentf, fuzzy
         ("M-s g"   . consult-ripgrep)       ; <leader>fg (live grep, uses rg)
         ("M-s l"   . consult-line)          ; search lines in buffer
         ("M-g g"   . consult-goto-line)     ; goto-line with preview
         ("M-g i"   . consult-imenu)         ; jump to symbol/heading
         ("C-x p g" . consult-ripgrep))      ; project-wide grep
  :custom
  (consult-narrow-key "<"))

;; find-file in a project, fuzzy — closest thing to <leader>ff.
;; project.el is built in; this binds project file-find to a quick key.
(use-package project
  :ensure nil
  :bind (("C-c f" . project-find-file)       ; <leader>ff equivalent
         ("C-c p" . project-switch-project)))

;;; ----------------------------------------------------------------------------
;;; In-buffer completion — nvim-cmp equivalent
;;;   corfu : popup completion at point
;;;   cape  : extra completion sources (file paths, dabbrev, keywords)
;;; ----------------------------------------------------------------------------

(use-package corfu
  :init (global-corfu-mode)
  :custom
  (corfu-auto t)                   ; popup as you type
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-quit-no-match 'separator)
  :bind (:map corfu-map
              ("RET" . nil)))       ; don't steal RET; TAB/C-n/C-p to complete

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

;;; ----------------------------------------------------------------------------
;;; LSP — eglot (built into Emacs 29). Auto-starts for these prog modes.
;;; Install servers separately:
;;;   Python : pipx install pyright   (or npm i -g pyright)
;;;   Go     : go install golang.org/x/tools/gopls@latest
;;; ----------------------------------------------------------------------------

(use-package eglot
  :ensure nil                      ; built-in
  :hook ((python-mode . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (go-mode . eglot-ensure)
         (go-ts-mode . eglot-ensure))
  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)
              ("C-c l a" . eglot-code-actions)
              ("C-c l f" . eglot-format)
              ("C-c l d" . eldoc))
  :custom
  (eglot-autoshutdown t))

;; Syntax checking (kept). flycheck integrates with eglot automatically.
(use-package flycheck
  :init (global-flycheck-mode))

;;; ----------------------------------------------------------------------------
;;; Tree-sitter (built into Emacs 29) — better, faster highlighting.
;;; Run `M-x treesit-install-language-grammar` per language on first use,
;;; or install all configured below. Mappings route classic modes → ts modes.
;;; ----------------------------------------------------------------------------

(setq treesit-language-source-alist
      '((python     . ("https://github.com/tree-sitter/tree-sitter-python"))
        (go         . ("https://github.com/tree-sitter/tree-sitter-go"))
        (gomod      . ("https://github.com/camdencheek/tree-sitter-go-mod"))
        (bash       . ("https://github.com/tree-sitter/tree-sitter-bash"))
        (json       . ("https://github.com/tree-sitter/tree-sitter-json"))
        (yaml       . ("https://github.com/ikatyang/tree-sitter-yaml"))
        (markdown   . ("https://github.com/ikatyang/tree-sitter-markdown"))))

;; Prefer ts modes when their grammar is installed.
(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (go-mode     . go-ts-mode)
        (sh-mode     . bash-ts-mode)
        (json-mode   . json-ts-mode)
        (js-mode     . js-ts-mode)))

;;; ----------------------------------------------------------------------------
;;; Git — magit (kept) + diff-hl (gitsigns-style gutter signs)
;;; ----------------------------------------------------------------------------

(use-package magit
  :bind (("C-x g" . magit-status)))

(use-package diff-hl
  :init (global-diff-hl-mode)
  :hook ((magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (diff-hl-flydiff-mode))          ; update gutter live, without saving

;;; ----------------------------------------------------------------------------
;;; Modern tabs — tab-bar-mode (built-in), replaces abandoned elscreen.
;;; ----------------------------------------------------------------------------

(use-package tab-bar
  :ensure nil
  :init (tab-bar-mode 1)
  :custom
  (tab-bar-show 1)
  (tab-bar-new-tab-choice "*scratch*")
  :bind (("C-x t n" . tab-bar-new-tab)
         ("C-x t k" . tab-bar-close-tab)
         ("C-<tab>"   . tab-bar-switch-to-next-tab)
         ("C-S-<tab>" . tab-bar-switch-to-prev-tab)))

;;; ----------------------------------------------------------------------------
;;; Discoverability & help (kept)
;;; ----------------------------------------------------------------------------

(use-package which-key
  :init (which-key-mode))

(use-package helpful
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)
         ("C-c C-d" . helpful-at-point)))

;; recentf (kept).
(use-package recentf
  :ensure nil
  :init (recentf-mode 1)
  :custom (recentf-max-menu-items 25))

;; persistent-scratch (kept).
(use-package persistent-scratch
  :config (persistent-scratch-setup-default))

;;; ----------------------------------------------------------------------------
;;; Languages
;;; ----------------------------------------------------------------------------

;; Python: autopep8 on save (kept). anaconda superseded by eglot for nav/docs.
(use-package py-autopep8
  :hook (python-mode . py-autopep8-mode)
  :hook (python-ts-mode . py-autopep8-mode))

(use-package blacken)              ; M-x blacken-buffer when you want black

;; Go: gofmt on save + godef jumps (kept; gopls via eglot handles completion).
(use-package go-mode
  :hook (before-save . gofmt-before-save)
  :config
  (defun my-go-mode-hook ()
    (unless (string-match "go" compile-command)
      (set (make-local-variable 'compile-command)
           "go build -v && go test -v && go vet"))
    (local-set-key (kbd "M-.") #'godef-jump)
    (local-set-key (kbd "M-*") #'pop-tag-mark))
  (add-hook 'go-mode-hook #'my-go-mode-hook))

;; Markdown: editing + rendering.
;;   - markdown-mode      : highlighting, structure, live HTML preview (C-c C-c l)
;;   - grip-mode          : GitHub-accurate live preview in a browser
;;                          (needs `pip install grip`); toggle with C-c C-g
;;   - markdown-preview-glow: render current buffer with glow in a terminal popup
(use-package markdown-mode
  :mode (("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))   ; GitHub-Flavored Markdown for READMEs
  :custom
  ;; Use pandoc for the built-in eww preview if available, else multimarkdown.
  (markdown-command
   (cond ((executable-find "pandoc") "pandoc")
         ((executable-find "multimarkdown") "multimarkdown")
         (t "markdown")))
  (markdown-fontify-code-blocks-natively t)  ; syntax-highlight fenced code
  (markdown-hide-urls t)                      ; show link text, hide URLs
  :config
  ;; Soft-wrap prose and toggle markup hiding for a cleaner read.
  (add-hook 'markdown-mode-hook #'visual-line-mode))

(use-package grip-mode
  :after markdown-mode
  :bind (:map markdown-mode-command-map
              ("g" . grip-mode)))   ; C-c C-c g  → toggle GitHub-style preview

(defun markdown-preview-glow ()
  "Render the current Markdown buffer with glow in a terminal popup."
  (interactive)
  (unless (executable-find "glow")
    (user-error "glow not found on PATH (installed by initial_setup.sh)"))
  (let ((file (or buffer-file-name
                  (make-temp-file "glow" nil ".md"
                                  (buffer-substring-no-properties (point-min) (point-max))))))
    (with-current-buffer (get-buffer-create "*glow*")
      (let ((inhibit-read-only t))
        (erase-buffer)
        (call-process "glow" nil t nil "-s" "dark" file)
        (goto-char (point-min))
        (special-mode))
      (display-buffer (current-buffer)))))

;; EIN (Emacs IPython Notebook) — kept, loads on demand.
(use-package ein :defer t)

;; Lisp editing niceties (kept).
(use-package paredit
  :hook ((emacs-lisp-mode lisp-mode scheme-mode) . enable-paredit-mode))
(use-package geiser :defer t)

(use-package htmlize)

;;; ----------------------------------------------------------------------------
;;; Personal keybindings & commands (preserved from your old config)
;;; ----------------------------------------------------------------------------

;; F5 = replay last keyboard macro.
(global-set-key [f5] 'call-last-kbd-macro)

;; C-w = delete word backward; move kill-region to C-x C-k.
(global-set-key (kbd "C-w") #'backward-kill-word)
(global-set-key (kbd "C-x C-k") #'kill-region)

;; M-x without Alt.
(global-set-key (kbd "C-x C-m") #'execute-extended-command)
(global-set-key (kbd "C-c C-m") #'execute-extended-command)

;; Window splitting (your muscle memory).
(global-set-key (kbd "M-3") #'split-window-horizontally)
(global-set-key (kbd "M-2") #'split-window-vertically)
(global-set-key (kbd "M-1") #'delete-other-windows)
(global-set-key (kbd "M-0") #'delete-window)
(global-set-key (kbd "M-o") #'other-window)

;; Confirm before quitting Emacs (closed too often by accident).
(global-set-key (kbd "C-x C-c")
                (lambda () (interactive)
                  (when (y-or-n-p "Quit? ")
                    (save-buffers-kill-emacs))))

;; Handy aliases.
(defalias 'sh 'eshell)
(defalias 'qrr 'query-replace-regexp)
(defalias 'lml 'list-matching-lines)
(defalias 'dml 'delete-matching-lines)

(defun insert-date-string ()
  "Insert a nicely formatted date string."
  (interactive)
  (insert (format-time-string "%A %Y%m%d")))

(defun json-format ()
  "Pretty-print the JSON in the active region."
  (interactive)
  (save-excursion
    (shell-command-on-region (mark) (point) "python -m json.tool" (buffer-name) t)))

;;; ----------------------------------------------------------------------------
;;; org-publish for ~/notes (kept)
;;; ----------------------------------------------------------------------------

(require 'ox-publish)
(setq org-publish-project-alist
      '(("org-notes"
         :base-directory "~/notes/"
         :base-extension "org"
         :publishing-directory "~/notes/public_html/"
         :recursive t
         :exclude "Incoming.org"
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :auto-preamble t
         :auto-sitemap t
         :sitemap-filename "sitemap.org"
         :sitemap-title "Sitemap")
        ("org-static"
         :base-directory "~/notes/"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
         :publishing-directory "~/notes/public_html/"
         :recursive t
         :publishing-function org-publish-attachment)
        ("notes" :components ("org-notes" "org-static"))))

;;; init.el ends here
