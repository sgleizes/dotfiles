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

;; [[file:config.org::*Workspaces][Workspaces:1]]
(defun +workspace--generate-named-id (&optional prefix)
  (or (cl-loop for name in (+workspace-list-names)
               when (string-match-p (format "^%s#[0-9]+$" prefix) name)
               maximize (string-to-number (substring name (+ (length prefix) 1))) into max
               finally return (if max (1+ max)))
      1))
(cl-defun +workspace/rename-frame (name &optional (frame (selected-frame)))
  "Create a blank, new perspective and associate it with FRAME."
  (when persp-mode
    (+workspace/rename (format "%s#%s" name (+workspace--generate-named-id name)))
    (set-frame-parameter frame 'workspace (+workspace-current-name))))
;; Workspaces:1 ends here

;; [[file:config.org::*General][General:1]]
(setq-default delete-by-moving-to-trash t  ; Delete files to trash
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
(map!
 :n "g[" #'better-jumper-jump-backward
 :n "g]" #'better-jumper-jump-forward)
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

;; [[file:config.org::*Ediff][Ediff:1]]
(after! ediff
  (setq-default ediff-keep-variants nil)
  (add-hook! 'ediff-cleanup-hook
    (defun ediff-kill-variants ()
      (ediff-janitor nil ediff-keep-variants))))
;; Ediff:1 ends here

;; [[file:config.org::*Ediff][Ediff:2]]
(after! ediff
  ;; Figure out if the session has a meta buffer during cleanup.
  ;; ediff-cleanup-mess seems to remove all possibilities of figuring that out.
  (defvar ediff--meta-session nil)
  (add-hook! 'ediff-cleanup-hook
    (defun ediff-mark-dedicated-frame-for-deletion ()
      (setq ediff--meta-session ediff-meta-buffer)))
  ;; Delete the current frame if it was dedicated to a simple ediff session.
  ;; This should be done after ediff-cleanup-mess.
  (add-hook! 'ediff-quit-hook :append
    (defun ediff-delete-dedicated-frame ()
      (unless ediff--meta-session
        (ediff-group-delete-dedicated-frame))))
  ;; Delete the current frame when quitting the last session group.
  (add-hook! 'ediff-quit-session-group-hook :append
    (defun ediff-group-delete-dedicated-frame ()
      (unless ediff-meta-session-number
        (when (string-match-p "^ediff#[0-9]+$" (frame-parameter nil 'workspace))
          (delete-frame))))))
;; Ediff:2 ends here

;; [[file:config.org::*Ediff][Ediff:3]]
(defvar evil-collection-ediff-registry-bindings
  '(("j" . ediff-next-meta-item)
    ("n" . ediff-next-meta-item)
    ("k" . ediff-previous-meta-item)
    ("p" . ediff-previous-meta-item)
    ("v" . ediff-registry-action)
    ("q" . ediff-quit-meta-buffer))
  "A list of bindings changed/added in evil-ediff-meta-buffer.")

(defun evil-collection-ediff-meta-buffer-startup-hook ()
  "Place evil-ediff-meta bindings in `ediff-meta-buffer-map'."
  (evil-make-overriding-map ediff-meta-buffer-map 'normal)
  (dolist (entry evil-collection-ediff-registry-bindings)
    (define-key ediff-meta-buffer-map (car entry) (cdr entry)))
  (evil-normalize-keymaps)
  nil)

(defun evil-collection-ediff-meta-buffer-setup ()
  "Initialize evil-ediff-meta-buffer."
  (interactive)
  (evil-set-initial-state 'ediff-meta-mode 'normal)
  (add-hook 'ediff-meta-buffer-keymap-setup-hook 'evil-collection-ediff-meta-buffer-startup-hook))
(evil-collection-ediff-meta-buffer-setup)
;; Ediff:3 ends here

;; [[file:config.org::*Ediff][Ediff:4]]
(custom-set-faces!
  '(ediff-even-diff-Ancestor    :inherit ediff-even-diff-A)
  '(ediff-odd-diff-Ancestor     :inherit ediff-even-diff-A)
  '(ediff-current-diff-Ancestor :inherit ediff-current-diff-A)
  `(ediff-current-diff-A        :background ,(doom-color 'base3))
  '(ediff-fine-diff-A           :inherit magit-diff-our-highlight :background unspecified :weight unspecified)
  '(ediff-fine-diff-B           :inherit magit-diff-their-highlight)
  '(ediff-fine-diff-C           :inherit magit-diff-base-highlight)
  `(ediff-fine-diff-Ancestor    :foreground ,(doom-color 'blue) :background ,(doom-blend 'blue 'bg 0.2) :weight bold :extend t))
;; Ediff:4 ends here

;; [[file:config.org::*Evil][Evil:1]]
(setq evil-move-cursor-back nil) ; Leave cursor in place when exiting insert-mode
(setq evil-cross-lines t)        ; Allow horizontal ops to move to the next
;; Evil:1 ends here

;; [[file:config.org::*Evil][Evil:2]]
(after! evil-multiedit
  (setq evil-multiedit-follow-matches t))
;; Evil:2 ends here

;; [[file:config.org::*Evil][Evil:3]]
(map!
 ;; Bind missing evil bindings
 :nv "gX"             #'evil-exchange-cancel
 :nv "god"            #'evil-quick-diff
 :nv "goD"            #'evil-quick-diff-cancel
 :textobj "b"         #'evil-textobj-anyblock-inner-block #'evil-textobj-anyblock-a-block
 ;; Rebind fold commands
 :m "TAB"             #'+fold/toggle
 :m "<backtab>"       #'+fold/close-all
 :m "C-<iso-lefttab>" #'+fold/open-all
 ;; Use M-/ to toggle comments (M-; for comment-dwim), rebind dabbrev-expand
 :nv "M-/"            #'evilnc-comment-or-uncomment-lines
 :g  "C-/"            #'dabbrev-expand
 ;; Rebind evil-lion to ga (align) to avoids gl conflicts with org-mode
 :nv "ga"             #'evil-lion-left
 :nv "gA"             #'evil-lion-right
 :nv "gl"             nil
 :nv "gL"             nil
 ;; Use more consistent bindings for workspaces/window navigation
 :m "] TAB"           #'+workspace/switch-right
 :m "[ TAB"           #'+workspace/switch-left
 :nm "]w"             #'evil-window-next
 :nm "[w"             #'evil-window-prev
 :map evil-window-map
 ;; Navigation
 "]"                  #'evil-window-next
 "["                  #'evil-window-prev
 "<left>"             #'evil-window-left
 "<down>"             #'evil-window-down
 "<up>"               #'evil-window-up
 "<right>"            #'evil-window-right
 ;; Moving windows
 "C-<left>"           #'+evil/window-move-left
 "C-<down>"           #'+evil/window-move-down
 "C-<up>"             #'+evil/window-move-up
 "C-<right>"          #'+evil/window-move-right
 ;; Miscellaneous
 "`"                  #'evil-window-mru     ; Consistent with SPC `
 "p"                  #'+popup/other        ; Better than C-x p
 "c"                  nil                   ; Confusing, use 'd'
 )
;; Evil:3 ends here

;; [[file:config.org::*Evil goggles][Evil goggles:1]]
(use-package! evil-goggles
  :config
  (custom-set-faces!
    '(evil-goggles-paste-face  :inherit custom-state)
    '(evil-goggles-indent-face :inherit custom-modified)
    '(evil-goggles-change-face :inherit custom-invalid)
    '(evil-goggles-delete-face :inherit custom-invalid))
  (setq evil-goggles-enable-delete t
        evil-goggles-enable-change t))
;; Evil goggles:1 ends here

;; [[file:config.org::*Flyspell][Flyspell:1]]
(defvar-local lang-ring nil
  "The list of available ispell languages.")

(let ((langs '("fr_FR" "en_US")))
  (let ((ring (make-ring (length langs))))
    (dolist (elem langs) (ring-insert ring elem))
    (setq-default lang-ring ring)))

(defun +spell/cycle-languages ()
  "Cycle between ispell languages for the current buffer."
  (interactive)
  (setq-local lang-ring (ring-copy lang-ring))
  (let ((lang (ring-ref lang-ring -1)))
    (ring-insert lang-ring lang)
    (ispell-change-dictionary lang)))

(map! :leader :prefix "n"
      :desc "Cycle ispell languages" "L" #'+spell/cycle-languages)
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
  (custom-set-faces! '(treemacs-fringe-indicator-face :inherit cursor)))
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
(setq org-directory "~/Projects/org/")
;; Org Mode:1 ends here

;; [[file:config.org::*Org Mode][Org Mode:2]]
(remove-hook! org-mode #'+literate-enable-recompile-h)
(defun +literate-recompile ()
  "Recompile literate config to `doom-private-dir"
  (interactive)
  (+literate-recompile-maybe-h))
(map! :leader :prefix "m"
      "R" #'+literate-recompile)
;; Org Mode:2 ends here

(use-package! info-colors
  :after info
  :hook (Info-selection . info-colors-fontify-node))

;; (use-package! vlf-setup
;;   :defer-incrementally vlf-tune vlf-base vlf-write vlf-search vlf-occur vlf-follow vlf-ediff vlf)

(use-package! tldr
  :config
  (add-hook! tldr-mode '(lambda () (font-lock-mode 0)))
  (map! :leader :prefix "h"
        "h" #'tldr))

(use-package! treemacs-all-the-icons
  :after treemacs)

(map! :map evil-window-map
 "\\" #'rotate-layout)
