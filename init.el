;; init.el --- Emacs configuration


;; INSTALL PACKAGES
;; --------------------------------------

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(defvar myPackages
  '(better-defaults
    ein ;; (emacs ipython notebook)
    epc
    auto-complete
    anaconda-mode
    python-mode
    flycheck 
    color-theme
    py-autopep8
    elscreen
    smooth-scrolling
    htmlize
    material-theme))

(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)

;; BASIC CUSTOMIZATION
;; --------------------------------------

(setq inhibit-startup-message t) ;; hide the startup message
;;(load-theme 'material t) ;; load material theme

(require 'color-theme)
(color-theme-initialize)
(color-theme-calm-forest)

(global-linum-mode t) ;; enable line numbers globally

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
  (defvar autosave-dir "~/.emacs.d/emacs_autosaves/")
  (defvar backup-dir "~/.emacs.d/emacs_backups/" ) (setq
                                                    backup-directory-alist
                                                    (list (cons "." backup-dir))))
 ((string-match "nt" system-configuration)
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
