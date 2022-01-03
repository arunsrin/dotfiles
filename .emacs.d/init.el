;; init.el --- Emacs configuration


;; INSTALL PACKAGES
;; --------------------------------------

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

(setq package-check-signature nil)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(defvar myPackages
  '(better-defaults
    elfeed
    elfeed-org
    elfeed-goodies
    ein ;; (emacs ipython notebook)
    epc
    sml-mode
    auto-complete
    anaconda-mode
    markdown-mode
    persistent-scratch
    python-mode
    flycheck
    paredit
    geiser
    ;; color-theme
    py-autopep8
    elscreen
    smooth-scrolling
    htmlize
    magit
    fzf
    deft
    which-key
    helpful
    ;; color-theme-solarized
    go-mode
    go-autocomplete
    exec-path-from-shell
    material-theme))

(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)

;; BASIC CUSTOMIZATION
;; --------------------------------------

(setq inhibit-startup-message t) ;; hide the startup message
;; (load-theme 'material t) ;; load material theme

;; (set-frame-parameter nil 'background-mode 'light)
(if (display-graphic-p) 
    (load-theme 'tsdh-light t) 
  ;; use a different theme on the terminal
  (load-theme 'wheatgrass t))

(defun on-frame-open (frame)
  (if (not (display-graphic-p frame))
      (set-face-background 'default "unspecified-bg" frame)))

(on-frame-open (selected-frame))
(add-hook 'after-make-frame-functions 'on-frame-open)
; (global-linum-mode t) ;; enable line numbers globally

;;Turn off crappy scrollbar and toolbar
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode 1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode 1))
;; Next few lines prevent those stupid backup files from appearing in
;; the working folder. Then now appear in special backup folders.  Put
;; autosave files (ie #foo#) in one place, *not* scattered all over
;; the file system! (The make-autosave-file-name function is invoked
;; to determine the filename of an autosave file.)
;; set backup directories
(cond 
 ((string-match "linux" system-configuration)
  (message "customizing GNU Emacs for Linux")
  ;; anything special about Linux begins here
  (setq deft-directory "~/notes")
  (defvar autosave-dir "~/.emacs.d/emacs_autosaves/")
  (defvar backup-dir "~/.emacs.d/emacs_backups/" ) (setq
                                                    backup-directory-alist
                                                    (list (cons "." backup-dir)))
  ;; golang stuff
  ;; Dependencies:
  ;; go get github.com/rogpeppe/godef
  ;; go get golang.org/x/tools/cmd/godoc
  ;; go get -u github.com/nsf/gocode
  (defun set-exec-path-from-shell-PATH ()
    (let ((path-from-shell (replace-regexp-in-string
			    "[ \t\n]*$"
			    ""
			    (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
      (setenv "PATH" path-from-shell)
      (setq eshell-path-env path-from-shell) ; for eshell users
      (setq exec-path (split-string path-from-shell path-separator))))

  (when window-system (set-exec-path-from-shell-PATH))
  (setenv "GOPATH" "/home/arunsrin/go")
  (add-to-list 'exec-path "/home/arunsrin/go/bin")
  )
 ((string-match "mingw32" system-configuration)
  (setq deft-directory "C:/mystuff/notes")
  (defvar autosave-dir "C:/.emacs.d/emacs_autosaves/")
  (defvar backup-dir "C:/.emacs.d/emacs_backups/" ) (setq 
                                                     backup-directory-alist
                                                     (list (cons "." backup-dir)))

  (setenv "PATH" (concat "C:/Program Files (x86)/SMLNJ/bin:" (getenv "PATH")))
  (setq exec-path (cons "C:/Program Files (x86)/SMLNJ/bin" exec-path))
  )

 ((string-match "mingw" system-configuration)
  (defvar autosave-dir "C:/.emacs.d/emacs_autosaves/")
  (defvar backup-dir "C:/.emacs.d/emacs_backups/" ) (setq 
                                                     backup-directory-alist
                                                     (list (cons "." backup-dir)))))
(make-directory autosave-dir t)
(defun auto-save-file-name-p (filename) (string-match
                                         "^#.*#$" 
                                         (file-name-nondirectory filename)))

(defun make-auto-save-file-name () (concat
                                    autosave-dir 
                                    (if buffer-file-name (concat
                                                          "#"
                                                          (file-name-nondirectory buffer-file-name) 
                                                          "#")
                                      (expand-file
                                       -name (concat "#%" (buffer-name) "#")))))

(setq display-time-24hr-format t)
(setq display-time-day-and-date t)
(display-time)
;; Bind F5 to Last-keyb-macro (which is otherwise C-x e)
;; Also remember that C-x ( starts recording, and C-x ) stops
(global-set-key [f5] 'call-last-kbd-macro)
;; Set highlighting on for marked regions
(setq transient-mark-mode 1)

;; Set C-w to delete word backwards, and move the original C-w to C-x C-k
(fset 'delete-word-backward
      "\342\344")
(global-unset-key "")
(global-set-key "" (quote delete-word-backward))
(global-set-key "" 'kill-region)

;; Scroll only by one line and not half a page
(setq scroll-step 1)

(mouse-avoidance-mode 'animate)

;;Invoke M-x without hitting Alt:
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)

(require 'htmlize)

(defun insert-date-string ()
  "Insert a nicely formated date string."
  (interactive)
  (insert (format-time-string "%A %Y%m%d")))

(fset 'my-insert-date
      [?\M-< ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- return ?\C-x ?\C-m ?i ?n ?s ?e ?r ?t ?- ?d ?a ?t ?e ?- ?s ?t ?r ?e ?i backspace backspace ?i ?n ?g return return ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- ?- return ?\C-o])
;; Require C-x C-c prompt. I've closed too often by accident.
;; http://www.dotemacs.de/dotfiles/KilianAFoth.emacs.html
(global-set-key [(control x) (control c)] 
                (function 
                 (lambda () (interactive) 
                   (cond ((y-or-n-p "Quit? ")
                          (save-buffers-kill-emacs))))))


;; shortening of often used commands
(defalias 'sh 'eshell)
(defalias 'qrr 'query-replace-regexp)
(defalias 'lml 'list-matching-lines)
(defalias 'dml 'delete-matching-lines)

;; WINDOW SPLITING
(global-set-key (kbd "M-3") 'split-window-horizontally) 
(global-set-key (kbd "M-2") 'split-window-vertically) 
(global-set-key (kbd "M-1") 'delete-other-windows)
(global-set-key (kbd "M-0") 'delete-window) 
(global-set-key (kbd "M-o") 'other-window) 

(require 'elscreen)
(require 'smooth-scrolling)


;; Replace "no or yes" with y or n
(defun yes-or-no-p (arg)
  "An alias for y-or-n-p, because I hate having to type 'yes' or 'no'."
  (y-or-n-p arg))

;; enable autopep8 on save
(require 'py-autopep8)
;; (add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)

(add-hook 'python-mode-hook 'anaconda-mode)
(add-hook 'python-mode-hook 'anaconda-eldoc-mode)
(add-hook 'after-init-hook #'global-flycheck-mode)

;; show recently used files with C-xC-r
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)
(elscreen-start)
;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(display-time-mode t)
 '(package-selected-packages
   (quote
    (go-autocomplete markdown-mode persistent-scratch smooth-scrolling python-mode py-autopep8 material-theme htmlize flycheck epc elscreen ein deft better-defaults auto-complete anaconda-mode)))
 '(safe-local-variable-values
   (quote
    ((org-export-html-style . "<link rel=\"stylesheet\" type=\"text/css\" href=\"css/stylesheet.css\" />"))))
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Hack" :foundry "outline" :slant normal :weight normal :height 98 :width normal)))))

;;deft for notes
(require 'deft)
(setq deft-extensions '("txt" "tex" "org" "md"))
(setq deft-recursive t)
(global-set-key [f8] 'deft)
(setq deft-use-filename-as-title t)
(setq deft-file-naming-rules
      '((noslash . "-")
        (nospace . "-")
        (case-fn . downcase)))
(global-set-key (kbd "C-x C-g") 'deft-find-file)
(setq deft-default-extension "md")
(setq deft-text-mode 'markdown-mode)


;;org-publish for notes
(require 'ox-publish)
(setq org-publish-project-alist
      '(
        ("org-notes"
         :base-directory "~/notes/"
         :base-extension "org"
         :publishing-directory "~/notes/public_html/"
         :recursive t
         :exclude "Incoming.org"
         :publishing-function org-html-publish-to-html
         :headline-levels 4             ; Just the default for this project.
         :auto-preamble t
         :auto-sitemap t                ; Generate sitemap.org automagically...
         :sitemap-filename "sitemap.org"  ; ... call it sitemap.org (it's the default)...
         :sitemap-title "Sitemap"         ; ... with title 'Sitemap'.
         )
        ("org-static"
         :base-directory "~/notes/"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
         :publishing-directory "~/notes/public_html/"
         :recursive t
         :publishing-function org-publish-attachment
         )
        ("notes" :components ("org-notes" "org-static"))
        ))

;; persistent-scratch
(persistent-scratch-setup-default)

;; format json
(defun json-format ()
  (interactive)
  (save-excursion
    (shell-command-on-region (mark) (point) "python -m json.tool" (buffer-name) t)
    )
  )

;; gtags/gnu globals
(setq load-path (cons "/usr/share/emacs/site-lisp/" load-path))
(autoload 'gtags-mode "gtags" "" t)
(setq c-mode-hook
      '(lambda ()
         (gtags-mode 1)
         ))
(setq gtags-suggested-key-mapping t)
(setq gtags-auto-update t)

;; server mode
;; (server-mode)


;; FMT before Save , godef jump
(defun my-go-mode-hook ()
					; Call Gofmt before saving                                                    
  (add-hook 'before-save-hook 'gofmt-before-save)
					; Godef jump key binding                                                      
  (local-set-key (kbd "M-.") 'godef-jump)
  (local-set-key (kbd "M-*") 'pop-tag-mark)
  )
(add-hook 'go-mode-hook 'my-go-mode-hook)

;; Autocomplete
(defun auto-complete-for-go ()
  (auto-complete-mode 1))
(add-hook 'go-mode-hook 'auto-complete-for-go)

(with-eval-after-load 'go-mode
  (require 'go-autocomplete))

;; build on M-x compile
(defun my-go-mode-hook ()
					; Call Gofmt before saving
  (add-hook 'before-save-hook 'gofmt-before-save)
					; Customize compile command to run go build
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
           "go build -v && go test -v && go vet"))
					; Godef jump key binding
  (local-set-key (kbd "M-.") 'godef-jump)
  (local-set-key (kbd "M-*") 'pop-tag-mark)
  )
(add-hook 'go-mode-hook 'my-go-mode-hook)

;; elfeed and elfeed-org stuff
;; Load elfeed-org
(require 'elfeed-org)

;; Initialize elfeed-org
;; This hooks up elfeed-org to read the configuration when elfeed
;; is started with =M-x elfeed=
(elfeed-org)

;; Optionally specify a number of files containing elfeed
;; configuration. If not set then the location below is used.
;; Note: The customize interface is also supported.
(setq rmh-elfeed-org-files (list "~/.emacs.d/elfeed.org"))

