;;; package --- Summary
;;; Commentary:
;;;  need print lisp-tree weather support chinese projectile bookmarks cache

(setq package-archives '(("gnu"    . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                        ("nongnu" . "https://mirrors.ustc.edu.cn/elpa/nongnu/")
                    ("melpa"  . "https://mirrors.ustc.edu.cn/elpa/melpa/")))
;; 设置优先从稳定源安装
(setq package-archive-priorities '(("gnu"    . 10)
                                   ("nongnu" . 9)
                                   ("melpa"  . 0)))

(package-initialize)

(add-to-list 'custom-theme-load-path "~/.emacs.d/theme/")
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))



(global-set-key (kbd "M-<down>") 'next-error)
(global-set-key (kbd "M-<up>") 'previous-error)
(global-set-key (kbd "M-<left>") 'beginning-of-buffer)
(global-set-key (kbd "M-<right>") 'end-of-buffer)




;; 优先使用 UTF-8
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
;; 文件编码
(setq default-buffer-file-coding-system 'utf-8)
(modify-coding-system-alist 'file "\\.txt\\'" 'utf-8)


;; 方法1：设置制表符宽度为 8
(setq-default tab-width 8) ; 制表符显示宽度
;; 方法2：缩进宽度设置为 8 tab is spc
;;(setq-default standard-indent 8)
(setq-default tab-first-completion 'word-or-paren-or-punct)

(global-hl-line-mode 1)
(delete-selection-mode 1)  ; Typing replaces selection



(setq default-directory "~/Documents/github/")


;;duplicate
;;; 2. 颜色系统
(defvar gold-theme-colors
  '((:night-bg      . "#0a0a0a")
    (:night-bg-alt  . "#1a1a1a")
    (:milky-fg      . "#f8f8f2")
    (:milky-fg-alt  . "#e2e2dc")
    (:gold-primary  . "#fff700")
    (:gold-secondary . "#f1fa8c")
    (:blood-red     . "#ff5555")
    (:aux-purple    . "#bd93f9")
    (:aux-purple-alt . "#9370DB")
    (:cyan          . "#8be9fd")
    (:green         . "#50fa00")
    (:orange        . "#ffb86c")
    (:pink          . "#ff79c6")
    (:gray          . "#6272a4")
    (:gray-light    . "#44475a")
    (:gray-dark     . "#2b2b2b")
    (:info-blue     . "#3399ff")
    (:success-green . "#00cc66")
    (:warning-orange . "#ff9900")
    (:error-red     . "#ff3333")
    (:type-blue     . "#66b2ff")
    (:func-yellow   . "#ffff99")
    (:const-cyan    . "#99ffff")
    (:string-green  . "#99ff99")
    (:org-code-bg   . "#2a2a00"))  ; 深黄金色背景
  "黄金主题颜色调色板")

(defun gold-color (name)
  "获取颜色值"
  (cdr (assoc name gold-theme-colors)))




;; 在定义完 gold-color 函数后，或者在主题启用函数中调用
;;(set-face-attribute 'region  nil :foreground (gold-color :green) :background (gold-color :blood-red))
;;'(region ((t (:extend t :background "dark magenta" :foreground "#0a0a0a"))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(cape consult corfu doom-modeline flycheck go-imports go-mode
	  indent-guide lsp-ui orderless projectile rainbow-blocks
	  rainbow-delimiters rainbow-mode spell-fu stock-ticker
	  undo-tree))
 '(warning-suppress-log-types '((use-package))))

;;; ==========================================
;;; Emacs 初始化配置 - 性能与外观优化版
;;; ==========================================

;;; 0. 性能优化
(setq gc-cons-threshold (* 1024 1024 512)) ; 提高GC阈值
(setq read-process-output-max (* 1024 1024 32))
(setq inhibit-compacting-font-caches t)
(setq byte-compile-warnings nil)
(setq native-comp-async-report-warnings-errors nil)
(setq load-prefer-newer t)
(setq file-name-handler-alist nil)

;; 禁用启动时的杂项
(setq inhibit-startup-screen t)
(setq inhibit-startup-echo-area-message t)
(setq inhibit-startup-buffer-menu t)
(setq initial-scratch-message nil)
(setq initial-major-mode 'fundamental-mode)



;;; 3. 核心界面设置
(use-package emacs
  :custom
  ;; 全屏
  (default-frame-alist '((fullscreen . maximized)))

  ;; 禁用 GUI 元素
  (tool-bar-mode nil)
  (scroll-bar-mode nil)
  (menu-bar-mode t)

  ;; 窗口设置
  (frame-title-format "Emacs - %b")
  (column-number-mode t)
  (line-number-mode t))


;;; 5. 黄金主题
(use-package gold-theme
  :load-path "~/.emacs.d/theme/"
  :demand t
  :config
  (load-theme 'gold t))

;; 设置分隔符颜色
(setq rainbow-delimiters-colors
  '("#ffd700"    ; 黄金
    "#bd93f9"    ; 辅助紫色
    "#ff5555"    ; 血红
    "#8be9fd"    ; 青色
    "#50fa7b"))  ; 绿色




;;显示时间
;;(display-time-mode t)
;;设置默认模式
(setq initial-major-mode 'text-mode)

;;自动刷新
(global-auto-revert-mode nil)
;;最近的文件
;;(recentf-mode nil)
;;(setq recentf-max-menu-items 25)
;;(setq recentf-max-saved-items 25)
;;(global-set-key (kbd "C-x C-r") 'recentf-open-files)

;;; 7. 基础
(use-package hl-line
  :hook (after-init . global-hl-line-mode)
  :config
  (set-face-attribute 'hl-line nil
                      :background (gold-color :night-bg-alt)
                      :underline (gold-color :gold-primary)))

(use-package isearch
  :ensure nil
  :bind
  (("C-s" . occur)
   ("C-r" . isearch-backward-regexp)
   ("C-M-s" . isearch-forward)
   ("C-M-r" . isearch-backward)
   ("M-%" . query-replace-regexp)
   ("C-M-%" . query-replace))
  :config
  ;; 在搜索模式中
  (define-key isearch-mode-map (kbd "M-%") 'isearch-query-replace-regexp)
  (define-key isearch-mode-map (kbd "C-%") 'isearch-query-replace)
  (setq isearch-wrap t))
;;; 8. 行号设置
(use-package display-line-numbers
  :hook ((prog-mode text-mode conf-mode) . display-line-numbers-mode)
  :config
  (setq display-line-numbers-type 'relative
        display-line-numbers-width 1
        display-line-numbers-grow-only t)
  (set-face-attribute 'line-number nil
                      :foreground (gold-color :gold-secondary)
                      :background (gold-color :night-bg))
  (set-face-attribute 'line-number-current-line nil
                      :foreground (gold-color :gold-primary)
                      :background (gold-color :night-bg-alt)
                      :weight 'bold))

;;; 9. 软换行设置
(setq-default truncate-lines nil)      ; 启用软换行
(setq word-wrap t)                     ; 在单词边界换行
(setq-default visual-line-mode t)      ; 启用 visual-line-mode
(global-visual-line-mode 1)            ; 全局启用软换行

;; 在某些模式下禁用软换行
(add-hook 'prog-mode-hook
          (lambda ()
            (setq truncate-lines t)    ; 编程模式下禁用软换行
            (visual-line-mode -1)))


;;; 10. Tab 和缩进设置
(setq-default tab-width 8)             ; Tab 宽度为 8

;; 显示空格和 Tab
(setq whitespace-style '(face tabs spaces space-before-tab
                              indentation  space-after-tab
                             tab-mark));;trailing
(setq whitespace-display-mappings
      '((space-mark 32 [183] [46])     ; 空格显示为中间点
        (newline-mark 10 [182 10])     ; 换行符
        (tab-mark 9 [9654 9] [92 9]))) ; Tab 显示为三角形
(global-whitespace-mode 1)             ; 启用全局空白显示


;; Undotree~~
(use-package undo-tree
  :demand t
  :config
  (global-undo-tree-mode t)

  ;; 设置 undo-tree/Emacs 原生撤销限制 (单位: 字节)
(setq undo-limit (* 1024 1024 128))          ;; 128 MB (软限制)
(setq undo-strong-limit (* 1024 1024 256))  ;; 256 MB (限制，约为 soft 的 1.5 倍)
(setq undo-outer-limit (* 1024 1024 512))  ;; 512 MB (硬限制，防止单次操作崩溃)
;; 1. 禁用默认的时间戳显示（减少节点数据量）
(setq undo-tree-visualizer-timestamps nil)
  (setq undo-tree-visualizer-diff nil);;expensive
  (setq undo-tree-auto-save-history nil)
  (setq undo-tree-visualizer-relative-timestamps t)
  (set-face-attribute 'undo-tree-visualizer-current-face nil
                      :foreground (gold-color :gold-primary)
                      :weight 'bold)
  (set-face-attribute 'undo-tree-visualizer-active-branch-face nil
                      :foreground (gold-color :aux-purple))
  (set-face-attribute 'undo-tree-visualizer-default-face nil
                      :foreground (gold-color :red))
  :bind
  (("C-x U" . undo-tree-visualize)     ; 可视化 undo
   ("C-x C-u" . undo-tree-undo)            ; 撤销
   ("C-x C-r" . undo-tree-redo)))          ; 重做
;;
;;; 12. 文件保存设置
(setq auto-save-default nil)           ; 禁用自动保存
(setq make-backup-files nil)           ; 禁用备份文件
(setq create-lockfiles nil)            ; 禁用锁文件
(setq auto-save-list-file-name nil)    ; 禁用自动保存列表
(setq auto-save-list-file-prefix nil)  ; 禁用自动保存列表文件
(setq version-control nil)             ; 不使用版本控制
(setq delete-old-versions t)           ; 删除旧版本
(setq kept-old-versions 0)             ; 不保留旧版本
(setq kept-new-versions 0)             ; 不保留新版本
(setq backup-directory-alist nil)      ; 无备份目录
(setq backup-by-copying nil)           ; 不复制备份
(setq vc-make-backup-files nil)        ; 版本控制下不备份





;; 保存时自动删除尾部空格
(add-hook 'before-save-hook 'delete-trailing-whitespace)




(setq ring-bell-function 'ignore)











;;; 13. Org Mode 配置
(use-package org
   :defer t
  :config
  ;; 基本设置
  (setq org-startup-indented t)        ; 启用缩进
  (setq org-adapt-indentation t)       ; 自适应缩进
  (setq org-src-preserve-indentation t) ; 保留源代码缩进
  (setq org-edit-src-content-indentation 0) ; 源代码内容缩进
  (setq org-startup-folded 'content)
  ;; 代码块设置
  (setq org-src-fontify-natively t)    ; 语法高亮
  (setq org-src-tab-acts-natively t)   ; Tab 键行为
  (setq org-src-window-setup 'current-window) ; 在当前窗口编辑

  ;; 代码块边框和背景色
  (set-face-attribute 'org-block-begin-line nil
                      :foreground (gold-color :gold-primary)
                      :background (gold-color :org-code-bg)
                      :overline (gold-color :gold-primary)
                      :underline (gold-color :gold-primary)
                      :weight 'bold)

  (set-face-attribute 'org-block-end-line nil
                      :foreground (gold-color :gold-primary)
                      :background (gold-color :org-code-bg)
                      :overline (gold-color :gold-primary)
                      :underline (gold-color :gold-primary)
                      :weight 'bold)

  (set-face-attribute 'org-block nil
                      :foreground (gold-color :milky-fg)
                      :background (gold-color :org-code-bg)
                      :extend t)

  (set-face-attribute 'org-code nil
                      :foreground (gold-color :gold-secondary)
                      :background (gold-color :org-code-bg))

  ;; 标题设置
  (set-face-attribute 'org-level-1 nil
                      :foreground (gold-color :gold-primary)
                      :height 1.3
                      :weight 'bold)
  (set-face-attribute 'org-level-2 nil
                      :foreground (gold-color :gold-secondary)
                      :height 1.2
                      :weight 'bold)
  (set-face-attribute 'org-level-3 nil
                      :foreground (gold-color :aux-purple)
                      :height 1.1)

  ;; 列表设置
  (set-face-attribute 'org-list-dt nil
                      :foreground (gold-color :cyan))

  ;; 链接设置
  (set-face-attribute 'org-link nil
                      :foreground (gold-color :cyan)
                      :underline t)

  ;; 待办事项
  (set-face-attribute 'org-todo nil
                      :foreground (gold-color :blood-red)
                      :weight 'bold)
  (set-face-attribute 'org-done nil
                      :foreground (gold-color :green)
                      :weight 'bold)

  ;; 元数据
  (set-face-attribute 'org-meta-line nil
                      :foreground (gold-color :gray))
  (set-face-attribute 'org-document-info-keyword nil
                      :foreground (gold-color :gray))

  ;; 日期
  (set-face-attribute 'org-date nil
                      :foreground (gold-color :pink)
                      :underline t)

  ;; 表格
  (set-face-attribute 'org-table nil
                      :foreground (gold-color :milky-fg-alt))

  ;; 引用
  (set-face-attribute 'org-quote nil
                      :foreground (gold-color :gold-secondary)
                      :slant 'italic
                      :extend t)

  :custom
  (org-src-block-faces '((nil . (:background "#e0f2e0"
                          :extend t
                          :box (:line-width 1 :color "#c0e0c0" :style rounded)
                          :padding "0.5em"))))
  :bind
  (:map org-mode-map
        ("C-c C-c" . org-ctrl-c-ctrl-c)
        ("C-c C-e" . org-export-dispatch)
        ("C-c C-l" . org-insert-link)))

;;; 14. LSP 模式 - 性能优化
(use-package lsp-mode
  :demand t
  :commands (lsp lsp-deferred)
  :custom
  ;; 性能优化设置
  (lsp-enable-symbol-highlighting t)   ; 启用符号高亮
  (lsp-semantic-tokens-enable t)       ; 启用语义标记
;;  (lsp-enable-on-type-formatting nil)  ; 禁用输入时格式化（提高性能）;;funciton definition is void
  (lsp-enable-text-document-color nil) ; 禁用文档颜色
  (lsp-enable-indentation nil)         ; 禁用缩进
  (lsp-enable-imenu t)                 ; 启用 imenu
  (lsp-enable-snippet t)               ; 启用代码片段
  (lsp-enable-file-watchers nil)       ; 禁用文件监视（提高性能）
  (lsp-file-watch-threshold nil)       ; 禁用文件监视阈值
  (lsp-lens-enable nil)                ; 禁用镜头
  (lsp-headerline-breadcrumb-enable nil) ; 禁用标题栏面包屑
  (lsp-modeline-diagnostics-enable t)  ; 启用诊断状态
  (lsp-modeline-code-actions-enable t) ; 启用代码操作状态
  (lsp-signature-auto-activate t)      ; 启用签名帮助
  (lsp-signature-render-documentation t) ; 渲染文档
  (lsp-completion-provider :none)      ; 禁用内置补全
  (lsp-idle-delay 0.5)                 ; 空闲延迟
  (lsp-log-io nil)                     ; 禁用日志
  (lsp-eldoc-enable-hover t)           ; 启用悬停
  (lsp-eldoc-render-all t)             ; 渲染所有

  ;; 字体锁定优化
(lsp-semantic-tokens-enable t)       ; 语义标记
  (lsp-semantic-tokens-apply-modifiers t) ; 应用修改器
  (lsp-semantic-tokens-apply-adjustments t) ; 应用调整
;; 禁用不必要的 LSP 功能以提高性能
(lsp-lens-enable nil)                ; 禁用镜头
;; 启用必要的优化

  :init
  (setq lsp-completion-enable t
        lsp-completion-show-detail t
        lsp-completion-show-kind t)

  :config

  ;; 快捷键
  (define-key lsp-mode-map (kbd "C-c  d") 'lsp-describe-thing-at-point)
  (define-key lsp-mode-map (kbd "C-c  r") 'lsp-rename)
  (define-key lsp-mode-map (kbd "C-c l f") 'lsp-format-buffer)
  (define-key lsp-mode-map (kbd "C-c l a") 'lsp-execute-code-action)
  (define-key lsp-mode-map (kbd "C-c l h") 'lsp-ui-doc-show)

  ;; 颜色配置
  (set-face-attribute 'lsp-face-highlight-textual nil
                      :background (gold-color :milky-fg)
                      :foreground (gold-color :night-bg-alt))
  (set-face-attribute 'lsp-face-highlight-read nil
                      :background (gold-color :gold-primary)
                      :foreground (gold-color :night-bg))
  (set-face-attribute 'lsp-face-highlight-write nil
                      :background (gold-color :blood-red)
                      :foreground (gold-color :milky-fg)))

;; LSP UI
(use-package lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-enable nil)            ; 禁用窥视（提高性能）
  (lsp-ui-sideline-enable nil)        ; 禁用侧边栏（提高性能）
  (lsp-ui-doc-enable t)               ; 启用文档
  (lsp-ui-doc-header t)               ; 启用文档头
  (lsp-ui-doc-include-signature t)    ; 包含签名
  (lsp-ui-doc-position 'top)          ; 文档位置
  (lsp-ui-doc-max-width 80)           ; 最大宽度
  (lsp-ui-doc-max-height 20)          ; 最大高度
  (lsp-ui-imenu-enable t)             ; 启用 imenu
  (lsp-ui-imenu-kind-position 'top)   ; imenu 位置
  :config
  (set-face-attribute 'lsp-ui-doc-background nil
                      :background (gold-color :night-bg-alt)
                      :foreground (gold-color :milky-fg))
  (set-face-attribute 'lsp-ui-doc-header nil
                      :background (gold-color :night-bg)
                      :foreground (gold-color :gold-primary)))

;;; 15. CORFU 补全系统
(use-package corfu
  :demand t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.5)
  (corfu-auto-prefix 2)
  (corfu-quit-at-boundary t)
  (corfu-quit-no-match t)
  (corfu-preview-current nil)
  (corfu-preselect-first t)
  (corfu-cycle t)
  (corfu-max-width 80)
  (corfu-min-width 30)
  (corfu-count 10)
  (corfu-scroll-margin 2)
  :bind
  (:map corfu-map
        ("M-TAB" . corfu-next)
;;        ([tab] . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous)
        ("RET" . corfu-insert))
  :init
  (global-corfu-mode)
  :config
  (set-face-attribute 'corfu-current nil
                      :background (gold-color :aux-purple)
                      :foreground (gold-color :night-bg)
                      :weight 'bold)
  (set-face-attribute 'corfu-default nil
                      :background (gold-color :night-bg-alt)
                      :foreground (gold-color :milky-fg)))



;; Cape
(use-package cape
  :demand t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-history)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
)

;;; 16. 语法检查
(use-package flycheck
  ;;:demand t
  :defer t
  :hook (after-init . global-flycheck-mode)
  :config
  (setq flycheck-check-syntax-automatically '(save mode-enabled idle-change))
  (setq flycheck-idle-change-delay 2.0)
  (setq flycheck-display-errors-delay 0.2))

;;; 17. 项目管理
;;(use-package projectile
;;  :init
;;  (projectile-mode t)
;;  :custom
;;  (bookmark-save-flag nil)
;;  (projectile-save-buffers-always nil)
;;  (projectile-completion-system 'default)
;;  (projectile-switch-project-action 'projectile-dired)
;;  (projectile-bookmark-file nil)
;;(projectile-enable-caching nil)
;;  (projectile-persist-bookmarks nil)
;;(project-list-file nil)
;;  (projectile-cache-file nil)
;;  (projectile-indexing-method 'native))
;;
;;; 18. 搜索
(use-package consult
  :demand t
  :bind
  (
  ( "C-l" . consult-line)
  ("C-x b" . consult-buffer)
   ("M-g" . consult-goto-line)
   ("M-y" . consult-yank-pop)))

(use-package orderless
  :demand t
  :config
  (setq completion-styles '(orderless basic)))

;;; 19. 其他工具
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
  :config
  (setq rainbow-delimiters-colors
        (list (gold-color :gold-primary)
              (gold-color :aux-purple)
              (gold-color :blood-red)
              (gold-color :cyan)
              (gold-color :green))))






(use-package which-key
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.5))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 25
        doom-modeline-bar-width 3
        doom-modeline-minor-modes t
        doom-modeline-buffer-encoding t
        doom-modeline-icon t
        doom-modeline-time t))

;;; 20. 平滑滚动
(setq scroll-margin 5)
(setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq scroll-preserve-screen-position 1)
(setq auto-window-vscroll nil)
(setq fast-but-imprecise-scrolling t)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-follow-mouse t)
(setq mouse-wheel-frame t)

;;; 21. 括号匹配
(show-paren-mode 1)
(setq show-paren-style 'mixed
      show-paren-delay 0)
(set-face-attribute 'show-paren-match nil
                    :background (gold-color :aux-purple)
                    :foreground (gold-color :night-bg)
                    :weight 'bold)

;;; 22. 快捷键系统
(defvar gold-keymap (make-sparse-keymap)
  "黄金主题快捷键映射")

(define-prefix-command 'gold-prefix)
(define-key global-map (kbd "C-c g") 'gold-prefix)

;; 补全相关
(define-key gold-keymap (kbd "c TAB") 'completion-at-point)
(define-key gold-keymap (kbd "c c") 'corfu-complete)

;; LSP 相关
(define-key gold-keymap (kbd "l f") 'lsp-format-buffer)
(define-key gold-keymap (kbd "l r") 'lsp-rename)
(define-key gold-keymap (kbd "l d") 'lsp-find-definition)
(define-key gold-keymap (kbd "l h") 'lsp-ui-doc-show)

;; 文件操作
(define-key gold-keymap (kbd "f f") 'find-file)
(define-key gold-keymap (kbd "f b") 'consult-buffer)
(define-key gold-keymap (kbd "f s") 'save-buffer)
(define-key gold-keymap (kbd "f u") 'undo-tree-visualize)

;; 项目管理
(define-key gold-keymap (kbd "p s") 'projectile-switch-project)
(define-key gold-keymap (kbd "p f") 'projectile-find-file)

;; 搜索相关
(define-key gold-keymap (kbd "s s") 'consult-line)
(define-key gold-keymap (kbd "s b") 'consult-buffer)
(define-key gold-keymap (kbd "s g") 'consult-goto-line)

;;; 23. 最终初始化
(defun final-init ()
  "最终初始化函数"

  (let ((init-time (float-time (time-subtract (current-time) before-init-time))))
    (message "🚀 Emacs 启动完成，耗时 %.2f 秒" init-time)

    (message "优化设置已生效:")
    (message "  • 字体: Maple Mono 13.4")
    (message "  • Tab 宽度: 8")
    (message "  • 行号: 相对行号")
    (message "  • 软换行: 已启用")
    (message "  • Undotree: 已启用")
    (message "  • 备份/自动保存: 已禁用")
    (message "  • Org 代码块: 黄金色边框")
    (message "  • LSP 字体锁定: 已优化")

    (message "使用 C-c g 查看所有快捷键")))

;; 记录启动时间
(defvar before-init-time (current-time))

;; 延迟执行最终初始化
(run-with-idle-timer 1 nil 'final-init)





;; 行号设置
(global-display-line-numbers-mode)         ; 全局启用

;; 软换行设置
(setq-default truncate-lines nil)          ; 启用软换行
(global-visual-line-mode 1)                ; 全局启用
;; 在编程模式下禁用软换行
(add-hook 'prog-mode-hook
          (lambda ()
            (setq truncate-lines t)
            (visual-line-mode -1)))



(set-face-attribute 'default nil
                    :family "Maple Mono"
                    :height 195)  ; 19.5





(setq auto-save-default nil)           ; 禁用自动保存
(setq make-backup-files nil)           ; 禁用备份
(setq create-lockfiles nil)            ; 禁用锁文件
(setq version-control nil)             ; 无版本控制




;; 延迟字体化
(setq font-lock-support-mode 'jit-lock-mode)
(setq jit-lock-defer-time 0.7)  ; 延迟 0.7 秒
(setq jit-lock-stealth-time 1)   ; 空闲 1 秒后字体化
;; 只字体化可见区域
(setq font-lock-support-mode 'lazy-lock-mode)
(setq lazy-lock-defer-time 1.2)
(setq lazy-lock-defer-on-the-fly t)
(setq lazy-lock-defer-on-scrolling t)


(defun benchmark-font-lock ()
  "测试字体化性能"
  (interactive)
  (let ((start-time (current-time)))
    (font-lock-fontify-buffer)
    (message "字体化耗时: %.3f 秒"
             (float-time (time-since start-time)))))


(defun test-font-lock-performance ()
  "运行一系列性能测试"
  (interactive)
  ;; 测试 1: 基本字体化
  (message "=== 测试 1: 基本字体化 ===")
  (benchmark-font-lock)

  ;; 测试 2: 禁用字体化
  (message "\n=== 测试 2: 禁用字体化 ===")
  (let ((font-lock-mode nil))
    (benchmark-font-lock))

  ;; 测试 3: 不同级别
  (message "\n=== 测试 3: 不同装饰级别 ===")
  (dotimes (level 4)
    (let ((font-lock-maximum-decoration level))
      (message "级别 %d:" level)
      (benchmark-font-lock))))




;; 根据系统负载动态调整
(defun dynamic-font-lock-adjust ()
  (cond ((> (car (load-average)) 2.0)
         ;; 高负载时降低质量
         (setq jit-lock-defer-time 1.9)
         (setq font-lock-maximum-decoration 1))
        ((< (car (load-average)) 0.5)
         ;; 低负载时提高质量
         (setq jit-lock-defer-time 0.1)
         (setq font-lock-maximum-decoration 3))
        (t
         ;; 中等负载
         (setq jit-lock-defer-time 0.5)
         (setq font-lock-maximum-decoration 2))))

(run-with-idle-timer 15 t 'dynamic-font-lock-adjust)

(setq lazy-lock-defer-time 0.2)
(setq lazy-lock-defer-on-the-fly t)
(setq lazy-lock-defer-on-scrolling t)


;;m-x list-faces-display to investigate face



(use-package indent-guide
  :ensure t
  :hook (prog-mode . indent-guide-mode)
  :config
  (setq indent-guide-char "│")
  (setq indent-guide-recursive t)
;; 显示 80 列边界线
(setq-default display-fill-column-indicator-column 80)
(global-display-fill-column-indicator-mode 1)
;; 在左侧边缘显示竖线
(setq indicate-empty-lines t)
(setq indicate-buffer-boundaries 'left)
;; 显示行号时添加分隔线
(setq linum-format "%3d │ "))

(message "iiss 783")


;;;  拼写检查 (Spell-fu)
(use-package spell-fu
  :ensure t
 ;; :demand t
  :config
  ;; 设置字典路径
  (setq spell-fu-directory (expand-file-name "spell-fu-dicts" user-emacs-directory))

  ;; 自动创建字典目录
  (unless (file-exists-p spell-fu-directory)
    (make-directory spell-fu-directory t))

  ;; 下载英语字典
  (unless (file-exists-p (expand-file-name "en" spell-fu-directory))
    (spell-fu-get-dictionary "en"))

  ;; 基本配置
  (setq spell-fu-idle-delay 0.5
        spell-fu-faces-include '(markdown-mode
                                 org-mode
                                 text-mode
                                 prog-mode
                                 fundamental-mode))

  ;; 颜色配置
  (set-face-attribute 'spell-fu-incorrect-word nil
                      :foreground (gold-color :blood-red)
                      :underline `(:color ,(gold-color :blood-red) :style wave))
  (set-face-attribute 'spell-fu-flagged-word nil
                      :foreground (gold-color :warning-orange)
                      :underline `(:color ,(gold-color :warning-orange) :style wave))

  )

;;occur pre line


( toggle-frame-fullscreen)

(message "sir only you sir")
