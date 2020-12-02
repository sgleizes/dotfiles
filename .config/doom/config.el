;;; config.el -*- lexical-binding: t; -*-

;; [[file:config.org::*Personal information][Personal information:1]]
(setq user-full-name "Stéphane Gleizes"
      user-mail-address "stephane.gleizes@gmail.com")
;; Personal information:1 ends here

;; [[file:config.org::*Fonts][Fonts:1]]
(setq doom-font (font-spec :family "Fira Code" :size 12)
      doom-variable-pitch-font (font-spec :family "Fira Sans")
      doom-unicode-font (font-spec :family "Noto Sans Mono")
      doom-big-font (font-spec :family "Fira Code" :size 18))
;; Fonts:1 ends here

;; [[file:config.org::*Theme and modeline][Theme and modeline:1]]
(setq doom-theme 'doom-tomorrow-night)
(delq! t custom-theme-load-path) ; Remove default emacs theme from search path
;; Theme and modeline:1 ends here

;; [[file:config.org::*Theme and modeline][Theme and modeline:2]]
(add-to-list 'default-frame-alist '(alpha . (90 . 90)))
;; Theme and modeline:2 ends here

;; [[file:config.org::*Theme and modeline][Theme and modeline:3]]
(defun doom-modeline-conditional-buffer-encoding ()
  "We expect the encoding to be LF UTF-8, so only show the modeline when this is not the case"
  (setq-local doom-modeline-buffer-encoding
              (unless (or (eq buffer-file-coding-system 'utf-8-unix)
                          (eq buffer-file-coding-system 'utf-8)))))
(add-hook 'after-change-major-mode-hook #'doom-modeline-conditional-buffer-encoding)
;; Theme and modeline:3 ends here

;; [[file:config.org::*Dashboard][Dashboard:1]]
(setq fancy-splash-image nil
      +doom-dashboard-banner-dir (concat doom-private-dir "banner/")
      +doom-dashboard-banner-file "black-hole.png")
;; Dashboard:1 ends here

;; [[file:config.org::*Dashboard][Dashboard:2]]
(defun doom-dashboard-hl-button ()
  (cons (- (point) 5) (line-end-position)))
(add-hook! +doom-dashboard-mode
           '(lambda () (setq-local hl-line-range-function #'doom-dashboard-hl-button)))
;; Dashboard:2 ends here

;; [[file:config.org::*Terminal][Terminal:1]]
(defun +doom-disable-graphical-modes (&optional frame)
  "Disable undesired minor-modes in FRAME (default: selected frame)
if in terminal."
  (interactive)
  (unless (display-graphic-p frame)
    (remove-hook! doom-first-file #'centaur-tabs-mode)
    (remove-hook! doom-first-input #'evil-goggles-mode)
    (remove-hook! '(doom-dashboard-mode-hook
                    term-mode-hook
                    vterm-mode-hook)
      #'centaur-tabs-local-mode)
    (remove-hook! '(org-mode-hook
                    markdown-mode-hook
                    TeX-mode-hook
                    rst-mode-hook
                    mu4e-compose-mode-hook
                    message-mode-hook
                    git-commit-mode-hook)
      #'flyspell-mode)
    (setq +ligatures-in-modes nil)))
(add-hook! 'after-make-frame-functions '+doom-disable-graphical-modes)
;; Terminal:1 ends here

;; [[file:config.org::*General][General:1]]
(setq-default delete-by-moving-to-trash t  ; Delete files to trash
              window-combination-resize t  ; take new window space from all other windows (not just current)
              x-stretch-cursor t)          ; Stretch cursor to the glyph width

(setq undo-limit 80000000                  ; Raise undo-limit to 80Mb
      evil-want-fine-undo t                ; By default while in insert all changes are one big blob. Be more granular
      auto-save-default t                  ; Nobody likes to loose work, I certainly don't
      truncate-string-ellipsis "…"         ; Unicode ellispis are nicer than "...", and also save precious space
      uniquify-buffer-name-style 'forward) ; Use path to uniquify buffer names

(global-subword-mode 1)                    ; Iterate through CamelCase words
;; General:1 ends here

;; [[file:config.org::*Indentation][Indentation:1]]
(setq-default tab-width 2
              ;; List of language-specific variables from dtrt-indent
              c-basic-offset          tab-width  ; C/C++/D/PHP/Java/...
              js-indent-level         tab-width  ; JavaScript/JSON
              js2-basic-offset        tab-width  ; JavaScript-IDE
              js3-indent-level        tab-width  ; JavaScript-IDE
              lua-indent-level        tab-width  ; Lua
              perl-indent-level       tab-width  ; Perl
              cperl-indent-level      tab-width  ; Perl
              raku-indent-offset      tab-width  ; Perl6/Raku
              erlang-indent-level     tab-width  ; Erlang
              ada-indent              tab-width  ; Ada
              sgml-basic-offset       tab-width  ; SGML
              nxml-child-indent       tab-width  ; XML
              pascal-indent-level     tab-width  ; Pascal
              typescript-indent-level tab-width  ; Typescript
              ;; Languages that use SMIE-based indent
              sh-basic-offset         tab-width  ; Shell Script
              ruby-indent-level       tab-width  ; Ruby
              enh-ruby-indent-level   tab-width  ; Ruby
              crystal-indent-level    tab-width  ; Crystal (Ruby)
              css-indent-offset       tab-width  ; CSS
              rust-indent-offset      tab-width  ; Rust
              rustic-indent-offset    tab-width  ; Rust
              scala-indent:step       tab-width  ; Scala
              ;; Default fallback
              standard-indent         tab-width
              smie-indent-basic       tab-width)
;; Indentation:1 ends here

;; [[file:config.org::*Frames][Frames:1]]
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(defun raise-frame-and-give-focus (&optional frame)
  (when (display-graphic-p frame)
    (raise-frame frame)
    (x-focus-frame frame)))
(add-hook 'after-make-frame-functions 'raise-frame-and-give-focus)
;; Frames:1 ends here

;; [[file:config.org::*Windows][Windows:1]]
(setq evil-vsplit-window-right t
      evil-split-window-below t)
;; Windows:1 ends here

;; [[file:config.org::*Windows][Windows:2]]
(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (+ivy/switch-workspace-buffer))
;; Windows:2 ends here

;; [[file:config.org::*Line numbers][Line numbers:1]]
(setq display-line-numbers-type 'relative)
;; Line numbers:1 ends here

;; [[file:config.org::*Ace window][Ace window:1]]
(after! ace-window
  (map! :leader :prefix "w"
        "a" #'ace-window))
;; Ace window:1 ends here

;; [[file:config.org::*Better jumper][Better jumper:1]]
(map! :leader
      :desc "Jump to previous location" "[" #'better-jumper-jump-backward
      :desc "Jump to next location" "]" #'better-jumper-jump-forward)
;; Better jumper:1 ends here

;; [[file:config.org::*Centaur tabs][Centaur tabs:1]]
(use-package! centaur-tabs
  :config
  (setq centaur-tabs-style "bar"
        centaur-tabs-height 32
        centaur-tabs-gray-out-icons nil
        centaur-tabs-set-bar 'under
        x-underline-at-descent-line t)
  (centaur-tabs-headline-match)
  ;; Override rules for grouping buffers.
  (defun centaur-tabs-buffer-groups ()
    "`centaur-tabs-buffer-groups' control buffers' group rules.

Group centaur-tabs with mode if buffer is derived from `vterm-mode'
`dired-mode' `org-mode' `magit-mode'.
All buffer name start with * will group to \"Emacs\".
Other buffer group by `centaur-tabs-get-group-name' with project name."
    (list
     (cond
      ((or (string-equal "*" (substring (buffer-name) 0 1))
           (memq major-mode '(magit-process-mode
                              magit-status-mode
                              magit-diff-mode
                              magit-log-mode
                              magit-file-mode
                              magit-blob-mode
                              magit-blame-mode
                              )))
       "Emacs")
      ((derived-mode-p 'term-mode 'vterm-mode)
       "Term")
      ;; ((derived-mode-p 'prog-mode)
      ;;  "Coding")
      ((derived-mode-p 'dired-mode)
       "Dired")
      ((memq major-mode '(org-mode org-agenda-mode diary-mode))
       "Org")
      (t
       (centaur-tabs-get-group-name (current-buffer))))))
  ;; Override centaur tabs to use workspace buffers as input list.
  (defun centaur-tabs-buffer-list ()
    "Return the list of buffers to show in tabs.
Exclude buffers whose name starts with a space, when they are not
visiting a file.  The current buffer is always included."
    (centaur-tabs-filter-out
     'centaur-tabs-hide-tab-cached
     (delq nil
           (cl-mapcar #'(lambda (b)
                          (cond
                           ;; Always include the current buffer.
                           ((eq (current-buffer) b) b)
                           ((buffer-file-name b) b)
                           ((char-equal ?\  (aref (buffer-name b) 0)) nil)
                           ((buffer-live-p b) b)))
                      (doom-buffer-list)))))
  :hook
  (doom-dashboard-mode . centaur-tabs-local-mode)
  (term-mode . centaur-tabs-local-mode)
  (vterm-mode . centaur-tabs-local-mode))
;; Centaur tabs:1 ends here

;; [[file:config.org::*Centaur tabs][Centaur tabs:2]]
(map!
 ;; Rebind buffer switching to tab switching commands.
 :g [remap previous-buffer] #'centaur-tabs-backward
 :g [remap next-buffer]     #'centaur-tabs-forward
 ;; Tab manipulation
 :g "C-<next>"    #'centaur-tabs-forward
 :g "C-<prior>"   #'centaur-tabs-backward
 :g "C-M-<next>"  #'centaur-tabs-forward-group
 :g "C-M-<prior>" #'centaur-tabs-backward-group
 :n "gt"   #'centaur-tabs-forward
 :n "gb"   #'centaur-tabs-backward
 :n "gT"   #'centaur-tabs-forward-group
 :n "gB"   #'centaur-tabs-backward-group
 :n "]B"   #'centaur-tabs-forward-group
 :n "[B"   #'centaur-tabs-backward-group
 :g "C-S-<prior>" #'centaur-tabs-move-current-tab-to-left
 :g "C-S-<next>"  #'centaur-tabs-move-current-tab-to-right

 :leader :prefix "b"
 ;; Buffer group navigation
 :desc "Switch buffer group"   "g" #'centaur-tabs-counsel-switch-group
 :desc "Next buffer group"     "L" #'centaur-tabs-forward-group
 :desc "Previous buffer group" "H" #'centaur-tabs-backward-group
 ;; Tab movement
 :desc "Move tab right"  "l" #'centaur-tabs-move-current-tab-to-right
 :desc "Move tab left"   "h" #'centaur-tabs-move-current-tab-to-left
 ;; Numbered buffer navigation
 :desc "Select tab 1..9" "1" #'centaur-tabs-select-visible-tab
 :desc "Select tab 1..9" "2" #'centaur-tabs-select-visible-tab
 :desc "Select tab 1..9" "3" #'centaur-tabs-select-visible-tab
 :desc "Select tab 1..9" "4" #'centaur-tabs-select-visible-tab
 :desc "Select tab 1..9" "5" #'centaur-tabs-select-visible-tab
 :desc "Select tab 1..9" "6" #'centaur-tabs-select-visible-tab
 :desc "Select tab 1..9" "7" #'centaur-tabs-select-visible-tab
 :desc "Select tab 1..9" "8" #'centaur-tabs-select-visible-tab
 :desc "Select tab 1..9" "9" #'centaur-tabs-select-visible-tab
 :desc "Select last tab" "0" #'centaur-tabs-select-end-tab
 )
;; Centaur tabs:2 ends here

;; [[file:config.org::*Company][Company:1]]
(after! company
  (add-hook 'evil-insert-state-exit-hook #'company-abort))
;; Company:1 ends here

;; [[file:config.org::*Evil][Evil:1]]
(map!
 ;; Use more consistent bindings for workspaces/window navigation
 :m "] TAB"   #'+workspace/switch-right
 :m "[ TAB"   #'+workspace/switch-left
 :nm "]w"     #'evil-window-next
 :nm "[w"     #'evil-window-prev
 :map evil-window-map
 ;; Navigation
 "]"          #'evil-window-next
 "["          #'evil-window-prev
 "<left>"     #'evil-window-left
 "<down>"     #'evil-window-down
 "<up>"       #'evil-window-up
 "<right>"    #'evil-window-right
 ;; Moving windows
 "C-<left>"   #'+evil/window-move-left
 "C-<down>"   #'+evil/window-move-down
 "C-<up>"     #'+evil/window-move-up
 "C-<right>"  #'+evil/window-move-right
 ;; Miscellaneous
 "`"          #'evil-window-mru     ; Consistent with SPC `
 "p"          #'+popup/other        ; Better than C-x p
 "c"          nil                   ; Confusing, use 'd'
 )
;; Evil:1 ends here

;; [[file:config.org::*Evil goggles][Evil goggles:1]]
(use-package! evil-goggles
  :config
  (custom-set-faces
   '(evil-goggles-paste-face  ((t (:inherit custom-state))))
   '(evil-goggles-indent-face ((t (:inherit custom-modified))))
   '(evil-goggles-change-face ((t (:inherit custom-invalid))))
   '(evil-goggles-delete-face ((t (:inherit custom-invalid)))))
  (setq evil-goggles-enable-delete t
        evil-goggles-enable-change t))
;; Evil goggles:1 ends here

;; [[file:config.org::*Flyspell][Flyspell:1]]
(after! flyspell
  (setq flyspell-lazy-idle-seconds 2))
;; Flyspell:1 ends here

;; [[file:config.org::*Format][Format:1]]
(setq +format-on-save-enabled-modes
      '(not sql-mode         ; sqlformat is currently broken
            tex-mode         ; latexindent is broken
            latex-mode))
;; Format:1 ends here

;; [[file:config.org::*Format][Format:2]]
(add-hook! 'sh-set-shell-hook
  (defun +sh-shell-zsh-no-format ()
    (if (string= sh-shell "zsh")
        (setq +format-with :none)
      (setq +format-with nil))))
;; Format:2 ends here

;; [[file:config.org::*Format][Format:3]]
(set-formatter! 'shfmt
  '("shfmt"
    "-s"
    ("-i" "%d" tab-width)
    ("-ln" "%s" (cl-case (and (eql major-mode 'sh-mode)
                              (boundp 'sh-shell)
                              (symbol-value 'sh-shell))
                  (zsh "bash")
                  (bash "bash")
                  (mksh "mksh")
                  (t "posix"))))
  :modes 'sh-mode)
;; Format:3 ends here

;; [[file:config.org::*Ivy][Ivy:1]]
(setq +ivy-buffer-preview t)
;; Ivy:1 ends here

;; [[file:config.org::*Ivy][Ivy:2]]
(after! ivy
  (setf (alist-get 't ivy-format-functions-alist)
        #'ivy-format-function-line))
;; Ivy:2 ends here

;; [[file:config.org::*Ivy][Ivy:3]]
(after! ivy-rich
  (defvar ivy-rich--ivy-switch-buffer-cache
    (make-hash-table :test 'equal))

  (define-advice ivy-rich--ivy-switch-buffer-transformer
      (:around (old-fn x) cache)
    (let ((ret (gethash x ivy-rich--ivy-switch-buffer-cache)))
      (unless ret
        (setq ret (funcall old-fn x))
        (puthash x ret ivy-rich--ivy-switch-buffer-cache))
      ret))

  (define-advice +ivy/switch-buffer
      (:before (&rest _) ivy-rich-reset-cache)
    (clrhash ivy-rich--ivy-switch-buffer-cache)))
;; Ivy:3 ends here

;; [[file:config.org::*Ligatures][Ligatures:1]]
(setq +ligatures-fira-font-alist (delete '("[]" . 57609) +ligatures-fira-font-alist))
;; Ligatures:1 ends here

;; [[file:config.org::*Ranger][Ranger:1]]
(use-package! ranger
  :config
  (setq ranger-cleanup-eagerly t)
  (setq ranger-show-hidden t)
  (setq ranger-modify-header nil)
  (setq ranger-hide-cursor t)
  )
;; Ranger:1 ends here

;; [[file:config.org::*Terminal cursor][Terminal cursor:1]]
(remove-hook 'tty-setup-hook #'evil-terminal-cursor-changer-activate)
;; Terminal cursor:1 ends here

;; [[file:config.org::*Treemacs][Treemacs:1]]
(use-package! treemacs
  :init
  (setq +treemacs-git-mode 'deferred)
  (setq doom-themes-treemacs-theme "all-the-icons")
  :config
  (treemacs-follow-mode 1)
  (custom-set-faces '(treemacs-fringe-indicator-face ((t (:inherit cursor))))))
;; Treemacs:1 ends here

;; [[file:config.org::*Undo tree][Undo tree:1]]
(use-package! undo-tree
  :config
  (setq undo-tree-visualizer-diff nil)
  :bind (:map evil-normal-state-map
         ("U" . undo-tree-visualize)))
;; Undo tree:1 ends here

;; [[file:config.org::*Vterm][Vterm:1]]
(use-package! vterm
  :config
  (setq vterm-buffer-name-string "vterm %s"))
;; Vterm:1 ends here

;; [[file:config.org::*Which-key][Which-key:1]]
(after! which-key
  (setq which-key-idle-delay 0.5))
;; Which-key:1 ends here

;; [[file:config.org::*Which-key][Which-key:2]]
(setq which-key-allow-multiple-replacements t)
(after! which-key
  (pushnew!
   which-key-replacement-alist
   '(("" . "\\`+?evil[-/:]?\\(?:a-\\)?\\(.*\\)") . (nil . "‹\\1"))
   '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)") . (nil . "«\\1"))
   ))
;; Which-key:2 ends here

;; [[file:config.org::*YASnippet][YASnippet:1]]
(use-package! yasnippet
  :config
  (setq yas-triggers-in-field t))
;; YASnippet:1 ends here

;; [[file:config.org::*YASnippet][YASnippet:2]]
(use-package! auto-yasnippet
  :config
  (map!
   :nvi [C-tab] nil
   (:leader :prefix "c"
    :desc "Expand auto-snippet" "y" #'aya-expand
    :desc "Create auto-snippet" "Y" #'aya-create)))
;; YASnippet:2 ends here

;; [[file:config.org::*Org Mode][Org Mode:1]]
(setq org-directory "~/org/")
(remove-hook! org-mode #'+literate-enable-recompile-h)
;; Org Mode:1 ends here

;; (use-package! guess-language
;;   :after flyspell-lazy
;;   :hook (text-mode . guess-language-mode)
;;   ;; :defer t
;;   ;; :init (add-hook 'text-mode-hook #'guess-language-mode)
;;   :config
;;   (setq guess-language-langcodes '((en . ("en_US" "English"))
;;                                    (fr . ("fr_FR" "French")))
;;         guess-language-languages '(en fr)
;;         guess-language-min-paragraph-length 45))

(use-package! info-colors
  :after info
  :hook (Info-selection . info-colors-fontify-node))

;; (use-package! vlf-setup
;;   :defer-incrementally vlf-tune vlf-base vlf-write vlf-search vlf-occur vlf-follow vlf-ediff vlf)

(use-package! treemacs-all-the-icons
  :after treemacs)

(map! :map evil-window-map
 "\\" #'rotate-layout)
