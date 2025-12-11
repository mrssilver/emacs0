
(deftheme minimal-theme "A minimal theme for Emacs")
(custom-theme-set-faces
 'minimal-theme
 '(default ((t (:background "#282c34" :foreground "#abb2bf"))))
 '(font-lock-comment-face ((t (:foreground "#5c6370"))))
 )
(provide-theme 'minimal-theme)
;;(load-theme 'minimal-theme t)

(package-initialize)
(require 'package)
;;(add-to-list 'package-archives
;;           '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives
            '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'load-path "~/.emacs.d/elisp/")
(set-frame-position (selected-frame) 0 0)
(set-frame-width (selected-frame) 80)
(set-frame-height (selected-frame) 59)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(preview-auto gotest-ts colorful-mode lsp-ui org-pdftools go-autocomplete org-translate dot-mode org-evil go-gen-test company-go go-gopath go-complete org-ai rainbow-blocks graphviz-dot-mode go-imports general minimap org-journal async isearch-mb spell-fu ## evil ess slime commenter go-dlv gotest magithub go-eldoc go-guru go-errcheck ffmpeg-player esup use-package org-remark rainbow-mode auto-correct auto-dim-other-buffers python erc rainbow-delimiters popon multiple-cursors minibuffer-header minibuffer-line minibar company-statistics perl-doc ztree pdf-tools org emacsql gited dracula-theme diminish diff-hl magit git-modes go-mode markdown-mode memory-usage)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "Black" :foreground "dark red" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight regular :height 120 :width normal :foundry "nil" :family "Menlo"))))
 '(cursor ((t (:background "DarkOrange1"))))
 '(custom-themed ((t (:background "yellow1" :foreground "dark red"))))
 '(highlight ((t (:background "red1" :foreground "light green"))))
 '(isearch ((t (:inherit match :background "gold1" :foreground "dark red" :weight extra-bold))))
 '(isearch-fail ((t (:background "black" :foreground "yellow1"))))
 '(lazy-highlight ((t (:background "yellow1" :foreground "dark red"))))
 '(rainbow-delimiters-base-error-face ((t (:inherit rainbow-delimiters-base-face :foreground "light green"))))
 '(rainbow-delimiters-base-face ((t (:inherit nil))))
 '(rainbow-delimiters-depth-1-face ((t (:inherit rainbow-delimiters-base-face :foreground "NavajoWhite3"))))
 '(rainbow-delimiters-depth-2-face ((t (:inherit rainbow-delimiters-base-face :foreground "olive drab"))))
 '(rainbow-delimiters-depth-3-face ((t (:inherit rainbow-delimiters-base-face :foreground "firebrick"))))
 '(rainbow-delimiters-depth-4-face ((t (:inherit rainbow-delimiters-base-face :foreground "yellow1"))))
 '(rainbow-delimiters-depth-5-face ((t (:inherit rainbow-delimiters-base-face :foreground "red4"))))
 '(rainbow-delimiters-depth-6-face ((t (:inherit rainbow-delimiters-base-face :foreground "ivory1"))))
 '(rainbow-delimiters-depth-7-face ((t (:inherit rainbow-delimiters-base-face :foreground "DarkOrange4"))))
 '(rainbow-delimiters-depth-8-face ((t (:inherit rainbow-delimiters-base-face :foreground "wheat2"))))
 '(rainbow-delimiters-depth-9-face ((t (:inherit rainbow-delimiters-base-face :foreground "gold1")))))
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
;;关闭默认界面
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(menu-bar-mode 1)
(scroll-bar-mode -1)
(global-font-lock-mode  t)
;;显示时间
(display-time-mode t)
;;设置默认模式
(setq initial-major-mode 'text-mode)
;;显示空白字符
(global-whitespace-mode t)
(setq whitespace-style '(face space tabs trailing lines-tail newline empty tab-mark newline-mark))
;;最近的文件
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
(global-set-key (kbd "C-x C-r") 'recentf-open-files)
(setq cache-directory "~/.emacs_cache")
;;(setq globalautorevertnonfilebuffers nil)
;;(setq globalautoreverttailedbuffers nil)
;;globalautorevertnonfilebuffers是用于控制非文件缓冲区（如dired缓冲区等）的自动刷新；globalautoreverttailedbuffers用于控制有“tail”模式（如某些日志文件查看模式）的缓冲区自动刷新。
;;如果想完全禁止自动刷新，包括文件内容更新后的自动重新读取，可以使用如下代码：
(setq globalautorevertmode nil)
;;自动刷新
;;(global-auto-revert-mode t)
;;这样设置之后，Emacs就不会自动检查文件是否被外部修改而进行刷新了。
;;要禁止Emacs自动保存，可以在Emacs的初始化文件（.emacs或init.el）中添加以下代码：
(setq auto-save-default nil)
;;这行代码将autosavedefault变量设置为nil，从而关闭自动保存功能。这样Emacs就不会自动为正在编辑的文件创建自动保存文件了。
;; 设置org目录
(setq org-directory "~/Documents/org")
(setq org-export-directory "~/Documents/org/org-exports")


(define-key minibuffer-local-map (kbd "SPC") 'self-insert-command)

(define-key minibuffer-local-map " " 'self-insert-command)

(defun highlight-lines (m n color)
 "Highlight lines from line M to line N with COLOR."
 (interactive "nStart line: \nnEnd line: \nsColor: ")
 (let ((overlay (make-overlay (progn (goto-line m) (point))
                              (progn (goto-line n) (line-end-position)))))
   (overlay-put overlay 'face `(:background ,color))))
(defun unhighlight-lines (m n)
 "Unhighlight lines from line M to line N."
 (interactive "nStart line: \nnEnd line: ")
 (remove-overlays (progn (goto-line m) (point))
                  (progn (goto-line n) (line-end-position))))
(global-set-key (kbd "C-c h") 'highlight-lines)
(global-set-key (kbd "C-c u") 'unhighlight-lines)
;;  输入颜色（例如 `"yellow"`）。
(defun select-lines (m n)
 "Select lines from line M to line N."
 (interactive "nStart line: \nnEnd line: ")
 (let ((start (save-excursion (goto-line m) (point)))
       (end (save-excursion (goto-line n) (line-end-position))))
   (push-mark start)
   (goto-char end)
   (setq mark-active t)))
(global-set-key (kbd "C-c l") 'select-lines)
(defun make-node (value left right)
 "Create a binary tree node."
 (list :value value :left left :right right))
(defun print-tree (node indent)
 "Print a binary tree in a readable format."
 (when node
   (print-tree (plist-get node :right) (+ indent 2))
   (insert (make-string indent ?\ ))
   (insert (format "%s\n" (plist-get node :value)))
   (print-tree (plist-get node :left) (+ indent 2))))
;; 创建一个简单的二叉树
;;(setq root (make-node 5
;;                      (make-node 3 (make-node 1 nil nil) (make-node 4 nil nil))
;;                      (make-node 8 nil (make-node 9 nil nil))))
;; 打印二叉树
;;(with-output-to-temp-buffer "*Binary Tree*"
;;  (print-tree root 0))
(defun insert-newline-every-m-chars (m n)
 "Insert a newline every M characters in the current buffer."
 (interactive "nStart line: \nsEnd line: ")
 (let ((start (point-min))
       (end (point-max)))
   (save-excursion
     (goto-char start)
     (while (< (point) end)
       (forward-char m)
       (insert n )))))
;;        (insert "\n")))))






(defun batch-generate-functions-to-multiple-buffers ()
"Batch generate function definitions to multiple buffers based on the current buffer's content.
Each line should be in the format 'buffer-name:function1 function2 ...'.
This function will process each line and generate corresponding functions in specified buffers."
(interactive)
(save-excursion
 (goto-char (point-min))
 (let (line-info-list)
   ;; Collect all matching lines into a list of lists, where each sublist contains buffer name and function names
   (while (re-search-forward "^\\([^:]+\\):\\([[:alnum:] ]+\\)$" nil t)
     (push (list (match-string 1) (split-string (match-string 2))) line-info-list))
   ;; Process each collected line info
   (dolist (line-info line-info-list)
     (let* ((buffer-name (car line-info))
            (function-names (cadr line-info)))
       ;; Create or switch to the target buffer
       (with-current-buffer (get-buffer-create buffer-name)
         ;; Optionally clear the buffer if you want to start fresh for each buffer
         ;; (erase-buffer) ; Uncomment this line if you want to clear the buffer each time
         ;; Go to the end of the buffer before insertion
         (goto-char (point-max))
         ;; Insert each function definition
         (dolist (func function-names)
           (insert (format "function %s() {\n}\n\n" func)))))))))
;;- **源文件格式**：每一行都应该遵循格式 `buffer-name:function1 function2 ...`，其中 `buffer-name` 是目标 buffer 的名称，后面跟着的是要在这个 buffer 中定义的一系列函数名，它们之间用空格分隔。
;;- **功能**：该函数会遍历当前 buffer 中的所有行，对于每个符合指定格式的行，它会在对应的 buffer 中生成函数定义。如果某个目标 buffer 已经存在，则会在其末尾添加新的函数定义；如果不存在，则会创建一个新的 buffer 并插入函数定义。


;;为了创建一个 Emacs Lisp 函数，该函数可以接受用户交互式输入的单词列表，并确保这些单词在格式化时不会被分割到不同的行，同时每行不超过80个字符，我们可以使用 `interactive` 形参来获取用户输入。下面是一个完整的例子，展示了如何实现这个功能。
(defun format-buffer-with-keywords-interactive ()
"Format the buffer so that each line does not exceed 80 characters and specified keywords are not split across lines."
(interactive)
(let* ((max-width 80)
      (keywords-input (read-string "Enter keywords separated by spaces: "))
      (keywords (split-string keywords-input))
      (buffer-contents (buffer-string))
      formatted-lines)
 (with-temp-buffer
   (insert buffer-contents)
   (goto-char (point-min))
   (while (not (eobp))
     (let* ((line (buffer-substring-no-properties (point-at-bol) (point-at-eol)))
            (formatted-line (format-line line keywords max-width)))
       (setq formatted-lines (append formatted-lines (split-string formatted-line "\n")))
       (forward-line 1)))
   (erase-buffer)
   (dolist (line formatted-lines)
     (insert line "\n"))
   (switch-to-buffer (current-buffer)))))
(defun format-line (line keywords max-width)
"Format LINE ensuring no word is split across lines and each line does not exceed MAX-WIDTH characters."
(let ((words (split-string line))
     (formatted-line "")
     (current-length 0))
 (dolist (word words)
   (let ((len (length word)))
     (if (or (> (+ current-length len) max-width)
              (member word keywords))
         (progn
           (unless (string= formatted-line "")
             (setq formatted-line (concat formatted-line "\n")))
           (setq formatted-line (concat formatted-line word))
           (setq current-length len))
       (if (= current-length 0)
           (setq formatted-line word)
         (setq formatted-line (concat formatted-line " " word)))
       (setq current-length (+ current-length len (if (> current-length 0) 1 0))))))
 formatted-line))
(global-set-key (kbd "C-c f") 'format-buffer-with-keywords-interactive)


;;(require 'general)
(require 'evil)
;;(general-create-definer leader-def
;;:keymaps '(normal visual insert emacs)
;;:prefix "M-SPC")

;;(leader-def
;;"ff" 'find-file
;;"bb" 'switch-to-buffer
;;"cal" '(calc-and-display :"Calc")
;;)
;; 如果不使用 `general.el`，可以直接使用 Emacs 内置的快捷键绑定方法：
(global-set-key (kbd "C-c c") 'calc-and-display)

;; 如果希望直接在当前缓冲区插入结果
(defun calc-and-display (expr)
 "Calculate the expression and insert it in the format expr=result."
 (interactive "sEnter expression: ")
 (let ((result (calc-eval expr)))
   (insert (format "%s=%s" expr result))))




;;假设字符串中包含嵌套的括号，希望找到括号对及内容

(defun match-parentheses (str &optional start end)
  "Recursively match nested parentheses in STR.
START and END are the start and end indices of the substring to process."
  (let ((result '())
        (stack '())
        (i start))
    (while (< i end)
      (let ((char (aref str i)))
        (cond
         ((= char ?\()
          (push i stack))
         ((= char ?\))
          (when stack
            (let ((open-pos (pop stack)))
              (push (cons open-pos i) result))))
         (t
          ;; Do nothing for other characters
          )))
      (setq i (1+ i)))
    (reverse result)))

(defun find-all-parentheses (str)
  "Find all nested parentheses in STR."
  (match-parentheses str 0 (length str)))

;; 测试
;;(let ((test-str "(a (b (c) d) e) (f (g))"))
;;  (find-all-parentheses test-str))

;;可以根据需要扩展这个函数，例如处理其他类型的括号（如 `{}` 或 `[]`），或者提取括号内的内容


;;要在 Emacs 中将 `(()())` 内的所有内容设置为红色
;;_content_ color changed 
;;需要定义新的面，该面具有红色的前景色 `defface` 宏完成。
(font-lock-mode t)
;;(font-lock-mode t)
(defface paren-content-face
  '((t (:foreground "#0faa00")))
  "Face for content inside parentheses."
  :group 'faces)
(defun paren-content ()
  "Fontify content inside _ _ as red."
  (font-lock-add-keywords nil
                          ;;'(("\\(([^)]*)\\)" 1 'paren-content-face t))))
                          '(("\\(_[^0-9]*_\\)" 1 'paren-content-face t))))
(add-hook 'text-mode-hook 'paren-content)



;;not worked

(defun color-font-lock-keywords ()
"Define font-lock keywords for color codes in text mode."
(let ((color-code-regexp "#\\([0-9a-fA-F]\\{6\\}\\)"))
;;(let ((color-code-regexp "\$#\\([0-9a-fA-F]\\{6\\}\$\\)"))
  `((,color-code-regexp
     (1 (progn
          ;; 使用 match-string-no-properties 获取颜色代码并将其转换为小写
          (let* ((color-code (downcase (match-string-no-properties 1))))
            ;; 应用颜色作为前景色
            (put-text-property (match-beginning 1) (match-end 1) 'face `(:foreground ,color-code)))
          nil)))))

(add-hook 'text-mode-hook
        (lambda ()
          (font-lock-add-keywords nil (color-font-lock-keywords))
          ;; 确保 font-lock 模式已启用
;;          (font-lock-mode 1)
)))


;; 或方案二：自定义 RGB 转换
(defun color-code-to-rgb (color-code)
  "Convert hex color code to RGB tuple."
  (let* ((hex (downcase color-code))
         (r (string-to-number (substring hex 1 3) 16))
         (g (string-to-number (substring hex 3 5) 16))
         (b (string-to-number (substring hex 5 7) 16)))
    (list (/ r 255) (/ g 255) (/ b 255))))

(defun color-font-lock-keywords ()
  "Highlight hex color codes with their actual colors."
  (let ((color-code-regexp "#\\([0-9a-fA-F]\\{6\\}\\)"))
    `((,color-code-regexp
      (1 (progn
         (put-text-property (match-beginning 1) (match-end 1)
                           'foreground (color-code-to-rgb (match-string 1)))
         nil))))))

(add-hook 'text-mode-hook
          (lambda ()
            (font-lock-add-keywords nil (color-font-lock-keywords))))

(defun custom-colors ()
  "Set colors based on buffer content."
  (when (string= (buffer-name) "a")
    (if (string-match-p "^#\\+go" (buffer-string))  ; 如果是 Go 文件
        (set-face-foreground 'go-function-name "green")
      (if (string-match-p "^#\\+lisp" (buffer-string))  ; 如果是 Lisp 文件
        (set-face-foreground 'lisp-function "green")))))

(add-hook 'find-file-hook 'custom-colors)




;; 安装 Delve：go install github.com/go-delve/delve/cmd/dlv@latest
;;go install github.com/golangci/lsp/cmd/golangci-lsp@latest
;;go install golang.org/x/tools/gopls@latest
;; company-go：可选的代码补全工具（可与 lsp-go 配合使用）。
;; 调整 lsp-log-level 为 warn 减少日志输出：
;;(global-lsp-mode 1)




;; LSP 配置 确保已安装 lsp-mode 和 lsp-go，并在 lsp-go 配置中启用：

;;(require 'lsp-go)
;;(lsp-register-client
;; 'lsp-go
;; :server-id 'go-langserver'
;; :command "go run github.com/golangci/lsp/cmd/golangci-lsp"
;; :initialization-options
;; '((gopls.Config{
;;     CheckGopath: false,
;;     UsePlaceholders: true,
;;   })))

;;(require 'lsp-mode)
;;(require 'go-mode)


;; 设置 gopls 日志级别（0=错误, 1=信息, 2=调试）
;;(setq lsp-log-level 2)

;; 启用代码补全
;;(setq company-go-use-gopls t)

;; 禁用自动跳转定义（按需启用）
;;(setq lsp-enable-go-def nil)
;;M-.（需启用 lsp-enable-go-def）。

;; 自定义 gopls 命令参数
;;(setq lsp-gopls-server-args '("-rpc.trace" "stdio"))



;;· 自动：输入 . 或 import "..." 自动补全 手动：Ctrl+x Ctrl+y（company-complete）




;;(company-go-setup)))


;;# 将工具路径添加到 Emacs 的 PATH
;;(setenv "PATH" (concat "/usr/local/go/bin:" (getenv "PATH"))))
;;(setq exec-path (append exec-path '("/usr/local/go/bin")))


;;(require 'go-mode)
;;(add-hook 'go-mode-hook #'lsp)





;;(add-hook 'go-mode-hook
 ;;         (lambda ()
  ;;          (add-to-list 'company-backends 'company-go t)))



;;(require 'lsp-mode)
;;(require 'lsp-ui)

;; 配置 Go
;;(add-hook 'go-mode-hook 'lsp)
;;(setq lsp-go-gopls-path "/path/to/gopls")



;;(setq lsp-log-level 'warn)




;; 公司模式（代码补全）
;;(add-hook 'go-mode-hook 'company-mode)
;;(setq company-go-use lsp t)  ;; 使用 lsp-go 作为补全源


;;(setq lsp-go-server-command 'gopls)
;;(lsp-enable-server 'gopls)





(defun tex_index ()
 (interactive)
(if (use-region-p)
(let ((text (buffer-substring (region-beginning) (region-end)))
(anchor (format "inde-anchorx-%s"   (org-id-get-create))))
;; 插入锚点
(save-excursion
(goto-char (region-end))
 (delete-region (region-beginning) (region-end))
(insert (format "[[#%s][%s]]" anchor text))

    ;; 在文件开头添加索引条目
   ;; (save-excursion
      (goto-char (point-min))
      (if (re-search-forward "^#\\+BEGIN_INDEX" nil t)
          (progn
            (end-of-line)
            (insert (format "\n- [[#%s][%s]]" anchor  text)))
        (goto-char (point-min))
        (insert (format "#+BEGIN_INDEX\n- [[#%s][%s]]\n#+END_INDEX\n\n" anchor text)))))))

;;latex
(setq tex-engine "xelatex") ; 使用XeLaTeX以支持更多字体
(setq TeX-engine-default "xelatex") ; 设置默认引擎为XeLaTeX
;;(require 'tex) ; 加载TeX相关的功能

;;(add-to-list 'TeX-command-list '("XeLaTeX" "%`xelatex%(mode)% %t" TeX-run-TeX nil t))
(setq TeX-command-default "XeLaTeX")




