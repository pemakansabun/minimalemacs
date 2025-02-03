(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.
;; See `package-archive-priorities` and `package-pinned-packages`.
;; Most users will not need or want to do this.
;; (add-to-list 'package-archives
;;              '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; Enable vertico
(use-package vertico
  :init
  (vertico-mode)

  ;; Different scroll margin
  (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  (setq vertico-cycle t)
  )

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (php-mode . lsp)
		 (python-ts-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration)
         ;; Enable lsp-inlay-hints-mode when lsp-mode starts
         (lsp-mode . (lambda () (lsp-inlay-hints-mode 0))))
  :commands lsp)
;;config to supprt lsp-mode
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq lsp-log-io nil) ; if set to true can cause a performance hit

(use-package elpy
  :ensure t
  :init
  (elpy-enable)
  :hook
  (python-ts-mode . elpy-mode))

(use-package go-mode
  :ensure t
  :bind (
         ;; If you want to switch existing go-mode bindings to use lsp-mode/gopls instead
         ;; uncomment the following lines
         ;; ("C-c C-j" . lsp-find-definition)
         ;; ("C-c C-d" . lsp-describe-thing-at-point)
         )
  ;; :hook ((go-mode . lsp-deferred)
  ;;        (before-save . lsp-format-buffer)
  ;;        (before-save . lsp-organize-imports))
  )

(provide 'gopls-config)

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

(use-package pdf-tools
  :init
  (pdf-tools-install))

(add-hook 'pdf-view-mode-hook 'pdf-view-themed-minor-mode)


;; A few more useful configurations...
(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; (use-package fzf
;;   :bind
;;   ;; Don't forget to set keybinds!
;;   :config
;;   (setq fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
;;         fzf/executable "fzf"
;;         fzf/git-grep-args "-i --line-number %s"
;;         ;; command used for `fzf-grep-*` functions
;;         ;; example usage for ripgrep:
;;         ;; fzf/grep-command "rg --no-heading -nH"
;;         fzf/grep-command "grep -nrH"
;;         ;; If nil, the fzf buffer will appear at the top of the window
;;         fzf/position-bottom t
;;         fzf/window-height 15))

;; (defun my/fzf-directory-search ()
;;   "Use FZF to search directories and open the selected one."
;;   (interactive)
;;   (let* ((dir-list (split-string (shell-command-to-string "find ~ -type d") "\n"))
;;          (dir (fzf--read-from-list dir-list)))
;;     (if (and dir (not (string= dir "")))
;;         (dired dir)
;;       (message "No directory selected"))))

;; (global-set-key (kbd "C-x C-d") 'my/fzf-directory-search)

(use-package corfu
  :init
  (global-corfu-mode)

  :config
  ;; Enable auto completion and configure quitting
  (setq corfu-auto t
        corfu-quit-no-match 'separator  ;; or t
        corfu-auto-delay 0             ;; No delay for the suggestions to pop up
        corfu-auto-prefix 1            ;; Trigger completions after typing 1 character
        completion-styles '(orderless basic) ;; Enable orderless for better completion experience
  )

  (add-hook 'php-mode-hook (lambda () (corfu-mode -1)))

  ;; If you want these settings for specific buffers, you can use `setq-local`:
  (setq-local corfu-auto        t
              corfu-auto-delay  0  ;; Instant suggestion without delay
              corfu-auto-prefix 1  ;; Trigger after 1 character
              completion-styles '(orderless basic))
)

(fset #'jsonrpc-log-event #'ignore)

(use-package drag-stuff
  :init
  (drag-stuff-mode t)
  :config
    (global-set-key (kbd "C-S-n") 'drag-stuff-down)
    (global-set-key (kbd "C-S-p") 'drag-stuff-up)
  )

(use-package avy
  :bind
  ("C-s" . avy-goto-char))

(use-package expand-region
  :bind
  ("C-=" . er/expand-region))

(use-package which-key
  :init
  (which-key-mode 1))

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 0)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-e") 'evil-end-of-line)
  (define-key evil-insert-state-map (kbd "C-a") 'evil-first-non-blank)
  (define-key evil-insert-state-map (kbd "TAB") 'tab-to-tab-stop)		
  (define-key evil-visual-state-map (kbd "C-e") 'evil-end-of-line)
  (define-key evil-visual-state-map (kbd "C-a") 'evil-first-non-blank)
  (define-key evil-normal-state-map (kbd "C-e") 'evil-end-of-line)
  (define-key evil-normal-state-map (kbd "C-q") 'evil-buffer)
  (define-key evil-normal-state-map (kbd "C-a") 'evil-first-non-blank)
  (define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up))
  

(add-hook 'vterm-mode-hook 'evil-emacs-state)

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;tree-sitter;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;EMACS PATH;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match
that used by the user's shell.

This is particularly useful under Mac OS X and macOS, where GUI
apps are not started from a shell."
  (interactive)
  (let ((path-from-shell (replace-regexp-in-string
			  "[ \t\n]*$" "" (shell-command-to-string
					  "$SHELL --login -c 'echo $PATH'"
						    ))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(set-exec-path-from-shell-PATH)
'(explicit-shell-file-name "/bin/zsh")
'(explicit-zsh-args '("--interactive" "--login"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;QOL term;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun my-term-mode-setup ()
  ;; Rebind C-x to C-c in term-mode
  (define-key term-raw-map (kbd "C-x") 'term-send-raw)

  ;; Optionally, bind C-x to some specific action if needed
  ;; (define-key term-raw-map (kbd "C-x") 'some-other-function)
  )

;; Add the custom setup function to term-mode-hook
(add-hook 'term-mode-hook 'my-term-mode-setup)

(global-set-key (kbd "C-c C-d") 'flymake-show-project-diagnostics)
(global-set-key (kbd "C-c C-p") 'consult-flymake)
(global-set-key (kbd "C-c C-n") 'consult-imenu)
(global-set-key (kbd "C-c C-c") 'compile)
(global-set-key (kbd "C-c n") 'next-buffer)
(global-set-key (kbd "C-c p") 'previous-buffer)
(global-set-key (kbd "C-c C-g") 'consult-ripgrep)
(global-set-key (kbd "C-c C-f") 'consult-find)
(global-set-key (kbd "C-c b") 'consult-project-buffer)

(defun my-prog-mode-keys ()
  "Set custom keybindings for programming modes."
  (local-set-key (kbd "C-c C-d") 'flymake-show-project-diagnostics)
  (local-set-key (kbd "C-c C-p") 'consult-flymake)
  (local-set-key (kbd "C-c C-n") 'consult-imenu)
  (local-set-key (kbd "C-c C-c") 'compile)
  (local-set-key (kbd "C-c n") 'next-buffer)
  (local-set-key (kbd "C-c p") 'previous-buffer)
  (local-set-key (kbd "C-c C-g") 'consult-ripgrep)
  (local-set-key (kbd "C-c C-f") 'consult-find)
  (local-set-key (kbd "C-c b") 'consult-project-buffer))

(add-hook 'prog-mode-hook 'my-prog-mode-keys)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;QOL vterm;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "C-c C-v") 'vterm-other-window)
(global-set-key (kbd "C-c v") 'projectile-run-vterm-other-window)
(with-eval-after-load 'vterm
(define-key vterm-mode-map (kbd "C-c") 'term-send-raw)
(define-key vterm-mode-map (kbd "C-u") 'term-send-raw)
(define-key vterm-mode-map (kbd "C-SPC") 'vterm-copy-mode)
(define-key vterm-mode-map (kbd "C-x C-z") 'vterm-send-escape)
(define-key vterm-mode-map (kbd "C-x C-c")'vterm-send-C-c))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;QOL LSP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (defun lsp-booster--advice-json-parse (old-fn &rest args)
;;   "Try to parse bytecode instead of json."
;;   (or
;;    (when (equal (following-char) ?#)
;;      (let ((bytecode (read (current-buffer))))
;;        (when (byte-code-function-p bytecode)
;;          (funcall bytecode))))
;;    (apply old-fn args)))
;; (advice-add (if (progn (require 'json)
;;                        (fboundp 'json-parse-buffer))
;;                 'json-parse-buffer
;;               'json-read)
;;             :around
;;             #'lsp-booster--advice-json-parse)

;; (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
;;   "Prepend emacs-lsp-booster command to lsp CMD."
;;   (let ((orig-result (funcall old-fn cmd test?)))
;;     (if (and (not test?)                             ;; for check lsp-server-present?
;;              (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
;;              lsp-use-plists
;;              (not (functionp 'json-rpc-connection))  ;; native json-rpc
;;              (executable-find "emacs-lsp-booster"))
;;         (progn
;;           (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $PATH)
;;             (setcar orig-result command-from-exec-path))
;;           (message "Using emacs-lsp-booster for %s!" orig-result)
;;           (cons "emacs-lsp-booster" orig-result))
;;       orig-result)))
;; (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;UNDO TREE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'undo-tree)
(global-undo-tree-mode)

(setq undo-tree-history-directory-alist
      '(("." . "~/.config/emacs/undo-tree/")))

(defun create-undo-tree-directory ()
  "Create the undo tree directory if it doesn't exist."
  (let ((undo-dir "~/.config/emacs/undo-tree/"))
    (unless (file-directory-p undo-dir)
      (make-directory undo-dir t))))

(add-hook 'after-init-hook 'create-undo-tree-directory)

(add-hook 'prog-mode-hook 'undo-tree-mode)

(add-hook 'prog-mode-hook 'yas-minor-mode)

(add-hook 'prog-mode-hook (lambda ()
                            (unless (derived-mode-p 'php-mode)
                              (eglot-ensure))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TRANSPARENT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(set-frame-parameter nil 'alpha-background 100)

(add-to-list 'default-frame-alist '(alpha-background . 100))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;QOL secion;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq display-time-24hr-format t)
(tool-bar-mode -1)
(ctrlf-mode 1)
(fast-scroll-mode 1)
(global-auto-revert-mode 1)
(toggle-truncate-lines -1)
(display-time-mode 1)
(doom-modeline-mode 1)
(setq inhibit-compacting-font-caches t)
(setq find-file-visit-truename t)
(setq eglot-autoreconnect nil)
(setq eglot-autoshutdown t)
(setq vterm-timer-delay 0.001)
(setq company-idle-delay 0)
(setq company-minimum-prefix-length 0)
(setq x-select-enable-clipboard t)
(setq emacs-lock-mode t)
(setq ring-bell-function 'ignore)
(setq-default word-wrap t)
(setq-default global-visual-line-mode t)
(setq make-backup-files nil)
(setq kill-buffer-query-functions (delq 'process-kill-buffer-query-function kill-buffer-query-functions))
(setq auto-save-default nil)
(setq scroll-conservatively 100)
(setq electric-pair-pairs '(
                            (?\{ . ?\})
                            (?\( . ?\))
                            (?\[ . ?\])
                            (?\" . ?\")
                            ))
(electric-pair-mode t)
(defalias 'yes-or-no-p 'y-or-n-p)
;;(add-hook 'prog-mode-hook 'display-line-numbers-mode)
;;(add-hook 'text-mode-hook 'display-line-numbers-mode)
;;(setq display-line-numbers-type 'relative)
(setq-default tab-width 4)
(setq-default standard-indent 4)
(setq c-basic-offset tab-width)
(setq-default electric-indent-inhibit t)
(setq-default indent-tabs-mode t)
(setq backward-delete-char-untabify-method 'nil)
;;(add-hook 'after-change-major-mode-hook 'my-global-truncate-lines)
(add-to-list 'exec-path "~/go/bin/")
(add-to-list 'exec-path "/usr/bin/")




;; (defun my-global-truncate-lines ()
;;   (setq truncate-lines t))


;;(load-theme 'modus-vivendi t)

;;exwm stuf;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (require 'exwm)									 ;;
;; (require 'exwm-config)							 ;;
;; (exwm-config-example)							 ;;
;; (shell-command "setxkbmap -option ctrl:swapcaps") ;;
;; (shell-command "xset r rate 200 55")				 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; (add-hook 'window-setup-hook 'on-after-init)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(tron-legacy))
 '(custom-safe-themes
   '("821c37a78c8ddf7d0e70f0a7ca44d96255da54e613aa82ff861fe5942d3f1efc" default))
 '(default-input-method "japanese")
 '(display-battery-mode t)
 '(display-line-numbers-type 'relative)
 '(display-time-mode t)
 '(helm-minibuffer-history-key "M-p")
 '(indicate-empty-lines t)
 '(package-selected-packages
   '(fast-scroll vlf minions doom-modeline ini-mode mpv eglot company cmake-mode dotenv-mode lsp-mode zig-mode cider vertico smex drag-stuff move-text lua-mode dmenu org-superstar texfrag markdown-preview-mode clojure-ts-mode undo-tree sly react-snippets lsp-tailwindcss yeetube jtsx ctrlf yasnippet xcscope xclip which-key web-mode vterm tron-legacy-theme treesit-auto templ-ts-mode projectile php-mode pdf-tools orderless magit lsp-treemacs lsp-docker go-mode gdscript-mode exwm expand-region evil-collection eglot-java corfu consult bui auto-complete))
 '(tool-bar-mode nil)
 '(truncate-lines nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Source Code Pro" :foundry "ADBO" :slant normal :weight semi-bold :height 120 :width normal)))))

(defun close-all-buffers ()
  "Close all open buffers except for those related to vterm."
  (interactive)
  (dolist (b (buffer-list))
    (let ((buf-name (buffer-name b)))
      (unless (or (string-prefix-p "*scratch*" buf-name)
                  (and (buffer-live-p b)
                       (derived-mode-p 'vterm-mode)))
        (kill-buffer b)))))

;; Bind the function to a key combination, e.g., `C-c C-k`
(global-set-key (kbd "C-c C-k") 'close-all-buffers)

(defun serious-mode ()
  "Escape to terminal running tmux when Emacs struggles with large codebases."
  (interactive)
  (start-process "neovide" nil "neovide"))

(global-set-key (kbd "C-c C-s") 'serious-mode)

;; PROGRAMMING SECTION
;; YAML files
(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-mode))

;; Python files
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))

(remove-hook 'python-ts-mode-hook 'eglot)
(remove-hook 'python-ts-mode-hook 'corfu-mode)

(add-hook 'python-ts-mode-hook 'lsp)

;; JavaScript files
(add-to-list 'auto-mode-alist '("\\.js\\'" . js-ts-mode))

;; TypeScript files
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))

;; REAXT files
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . jtsx-jsx-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
;; Ruby files
(add-to-list 'auto-mode-alist '("\\.rb\\'" . ruby-ts-mode))

;; Go files
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))

;; C files
(add-to-list 'auto-mode-alist '("\\.c\\'" . c-mode))

;; HTML files
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

;; CSS files
(add-to-list 'auto-mode-alist '("\\.css\\'" . css-mode))

;; SCSS files
(add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode))

;; Less files
(add-to-list 'auto-mode-alist '("\\.less\\'" . less-css-mode))

;; JSON files
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-ts-mode))

;; Lua files
(add-to-list 'auto-mode-alist '("\\.lua\\'" . lua-mode))

;; Shell script files
(add-to-list 'auto-mode-alist '("\\.sh\\'" . shell-script-mode))

;; Markdown files
(add-to-list 'auto-mode-alist '("\\.md\\'" . gfm-mode))

;; LaTeX files
(add-to-list 'auto-mode-alist '("\\.tex\\'" . latex-mode))

;; Haskell files
(add-to-list 'auto-mode-alist '("\\.hs\\'" . haskell-mode))

;; PHP files
(add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode))

(remove-hook 'php-mode-hook 'eglot)
(remove-hook 'php-mode-hook 'corfu-mode)

(add-hook 'php-mode-hook 'lsp)

;; R files
(add-to-list 'auto-mode-alist '("\\.r\\'" . R-mode))

;; SQL files
(add-to-list 'auto-mode-alist '("\\.sql\\'" . sql-mode))

;; Dockerfile
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))

;; Terraform files
(add-to-list 'auto-mode-alist '("\\.tf\\'" . terraform-mode))

;; Swift files
(add-to-list 'auto-mode-alist '("\\.swift\\'" . swift-mode))

;; Rust files
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))

;; Elixir files
(add-to-list 'auto-mode-alist '("\\.ex\\'" . elixir-mode))
(add-to-list 'auto-mode-alist '("\\.exs\\'" . elixir-mode))

;; Clojure files
(add-to-list 'auto-mode-alist '("\\.clj\\'" . clojure-ts-mode))

;; Elm files
(add-to-list 'auto-mode-alist '("\\.elm\\'" . elm-mode))

;; Crystal files
(add-to-list 'auto-mode-alist '("\\.cr\\'" . crystal-mode))

;; Julia files
(add-to-list 'auto-mode-alist '("\\.jl\\'" . julia-mode))
