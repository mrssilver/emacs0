

;; file-tree-printer.el
;; 文件树打印工具

(defgroup file-tree nil
  "文件树打印工具"
  :group 'files
  :group 'tools)

(defcustom file-tree-max-depth 20
  "最大遍历深度"
  :type 'integer
  :group 'file-tree)

(defcustom file-tree-max-nodes 100
  "最大节点数"
  :type 'integer
  :group 'file-tree)

(defcustom file-tree-show-hidden nil
  "是否显示隐藏文件"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-show-size nil
  "是否显示文件大小"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-show-time nil
  "是否显示修改时间"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-ignore-list
  '(".git" ".svn" ".hg" ".DS_Store"
    "node_modules" "__pycache__" ".cache")
  "忽略的文件/目录列表"
  :type '(repeat string)
  :group 'file-tree)

(defcustom file-tree-sort-by-name t
  "按名称排序"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-follow-symlinks nil
  "是否跟随符号链接"
  :type 'boolean
  :group 'file-tree)

(defstruct file-node
  "文件节点结构"
  name
  path
  type        ; 'dir, 'file, 'symlink, 'elisp
  size
  mod-time
  children
  parent
  depth
  is-last)

(defun file-tree-create-node (name path type &optional size mod-time)
  "创建文件节点"
  (make-file-node
   :name name
   :path path
   :type type
   :size (or size 0)
   :mod-time (or mod-time (current-time))
   :children nil
   :parent nil
   :depth 0
   :is-last t))

(defun file-tree-build (path)
  "从路径构建文件树"
  (let* ((abs-path (expand-file-name path))
         (file-attr (file-attributes abs-path))
         (is-dir (eq (car file-attr) t))
         root
         (node-count 1))
    
    (if is-dir
        ;; 目录
        (progn
          (setq root (file-tree-create-node
                      (file-name-nondirectory abs-path)
                      abs-path
                      'dir))
          (setq node-count (file-tree-build-dir root 1 node-count))
          root)
      
      ;; 文件
      (let ((ext (file-name-extension abs-path)))
        (if (string= ext "el")
            ;; Elisp文件
            (file-tree-build-from-elisp abs-path)
          ;; 普通文件
          (file-tree-create-node
           (file-name-nondirectory abs-path)
           abs-path
           'file
           (nth 7 file-attr)
           (nth 5 file-attr)))))))

(defun file-tree-build-dir (node depth node-count)
  "递归构建目录树"
  (when (> depth file-tree-max-depth)
    (cl-return-from file-tree-build-dir node-count))
  
  (let* ((dir (file-node-path node))
         (entries (directory-files dir t nil t))
         filtered-entries
         child-count 0)
    
    ;; 过滤条目
    (dolist (entry entries)
      (let ((name (file-name-nondirectory entry)))
        ;; 跳过 . 和 ..
        (when (and (not (string-match "^\\.\\.?$" name))
                   ;; 跳过隐藏文件
                   (or file-tree-show-hidden
                       (not (string-match "^\\.\\|~$" name)))
                   ;; 跳过忽略列表
                   (not (member name file-tree-ignore-list)))
          (push entry filtered-entries))))
    
    ;; 排序
    (when file-tree-sort-by-name
      (setq filtered-entries (sort filtered-entries
                                   (lambda (a b)
                                     (string< (file-name-nondirectory a)
                                              (file-name-nondirectory b))))))
    
    ;; 处理每个条目
    (dolist (entry filtered-entries)
      (when (>= node-count file-tree-max-nodes)
        (message "节点数超过限制 (%d)，已停止遍历" file-tree-max-nodes)
        (cl-return-from file-tree-build-dir node-count))
      
      (let* ((attr (file-attributes entry))
             (is-dir (eq (car attr) t))
             (is-symlink (stringp (car attr)))
             (name (file-name-nondirectory entry))
             (type (cond
                    (is-dir 'dir)
                    (is-symlink 'symlink)
                    ((string= (file-name-extension entry) "el") 'elisp)
                    (t 'file)))
             (child (file-tree-create-node
                     name
                     entry
                     type
                     (nth 7 attr)
                     (nth 5 attr))))
        
        (setf (file-node-parent child) node)
        (setf (file-node-depth child) depth)
        (setf (file-node-is-last child) (= child-count (1- (length filtered-entries))))
        
        (push child (file-node-children node))
        (setq node-count (1+ node-count))
        (setq child-count (1+ child-count))
        
        ;; 如果是目录，递归构建
        (when (and is-dir file-tree-follow-symlinks)
          (setq node-count (file-tree-build-dir child (1+ depth) node-count)))))
    
    ;; 反转子节点列表（因为是push的）
    (setf (file-node-children node) (nreverse (file-node-children node)))
    node-count))

(defun file-tree-build-from-elisp (filepath)
  "从Elisp文件构建树"
  (let* ((content (with-temp-buffer
                    (insert-file-contents filepath)
                    (buffer-string)))
         (lines (split-string content "\n"))
         (root (file-tree-create-node
                (file-name-nondirectory filepath)
                filepath
                'elisp
                (length content)))
         (node-count 1))
    
    ;; 简单解析Elisp，这里可以扩展
    (dolist (line lines)
      (when (and (> (length line) 0)
                 (not (string-match "^[[:space:]]*;" line))) ; 跳过注释
        (let ((child (file-tree-create-node
                      (format "代码行: %s" (substring line 0 (min 40 (length line))))
                      filepath
                      'file
                      (length line))))
          (setf (file-node-parent child) root)
          (setf (file-node-depth child) 1)
          (push child (file-node-children root))
          (setq node-count (1+ node-count))
          
          (when (>= node-count file-tree-max-nodes)
            (message "节点数超过限制 (%d)，已停止解析" file-tree-max-nodes)
            (cl-return))))))
    
    (setf (file-node-children root) (nreverse (file-node-children root)))
    root))

(defun file-tree-print (node &optional prefix is-last)
  "打印文件树"
  (let* ((prefix (or prefix ""))
         (node-prefix (if is-last "└── " "├── "))
         (child-prefix (if is-last "    " "│   "))
         (node-text (file-tree-format-node node)))
    
    ;; 打印当前节点
    (message "%s%s%s" prefix node-prefix node-text)
    
    ;; 递归打印子节点
    (let ((child-count (length (file-node-children node)))
          (index 0))
      (dolist (child (file-node-children node))
        (let ((is-last-child (= index (1- child-count)))
              (new-prefix (concat prefix child-prefix)))
          (file-tree-print child new-prefix is-last-child)
          (setq index (1+ index)))))))

(defun file-tree-format-node (node)
  "格式化节点显示"
  (let ((name (file-node-name node))
        (type (file-node-type node))
        parts)
    
    ;; 添加图标
    (push (cond
           ((eq type 'dir) "📁")
           ((eq type 'symlink) "🔗")
           ((eq type 'elisp) "λ")
           (t "📄"))
          parts)
    
    ;; 添加名称（带颜色）
    (setq name (propertize name 'face
                          (cond
                           ((eq type 'dir) 'font-lock-type-face)
                           ((eq type 'symlink) 'font-lock-constant-face)
                           ((eq type 'elisp) 'font-lock-function-name-face)
                           (t 'default))))
    (push name parts)
    
    ;; 添加额外信息
    (when file-tree-show-size
      (let ((size (file-node-size node)))
        (when (> size 0)
          (push (format "(%s)" (file-tree-format-size size)) parts))))
    
    (when file-tree-show-time
      (let ((time (file-node-mod-time node)))
        (when time
          (push (format "@%s" (format-time-string "%Y-%m-%d %H:%M" time)) parts))))
    
    (string-join (reverse parts) " ")))

(defun file-tree-format-size (bytes)
  "格式化文件大小"
  (cond
   ((>= bytes (expt 1024 4)) (format "%.1fTB" (/ bytes (expt 1024.0 4))))
   ((>= bytes (expt 1024 3)) (format "%.1fGB" (/ bytes (expt 1024.0 3))))
   ((>= bytes (expt 1024 2)) (format "%.1fMB" (/ bytes (expt 1024.0 2))))
   ((>= bytes 1024) (format "%.1fKB" (/ bytes 1024.0)))
   (t (format "%dB" bytes))))

(defun file-tree-print-summary (node dir-count file-count)
  "打印摘要信息"
  (message "📁 路径: %s" (file-node-path node))
  (message "📊 统计: %d 目录, %d 文件, %d 节点" 
           dir-count file-count (+ dir-count file-count))
  (message ""))

(defun file-tree-count-nodes (node)
  "统计节点"
  (let ((dir-count 0)
        (file-count 0))
    (labels ((count-node (n)
               (if (eq (file-node-type n) 'dir)
                   (setq dir-count (1+ dir-count))
                 (setq file-count (1+ file-count)))
               (dolist (child (file-node-children n))
                 (count-node child))))
      (count-node node)
      (list dir-count file-count))))

;; 主命令
(defun file-tree-show (path)
  "显示文件树"
  (interactive "DPath: ")
  
  (message "")
  (message "构建文件树中...")
  
  (let ((tree (file-tree-build path))
        counts)
    
    (when tree
      (setq counts (file-tree-count-nodes tree))
      (file-tree-print-summary tree (car counts) (cadr counts))
      (file-tree-print tree)
      
      (when (>= (+ (car counts) (cadr counts)) file-tree-max-nodes)
        (message "")
        (message "⚠️  节点数已达限制 (%d)，已停止遍历" file-tree-max-nodes)
        (message "   使用 M-x customize-variable RET file-tree-max-nodes RET 调整限制")))))

;; 交互式命令
(defun file-tree-show-current-dir ()
  "显示当前目录的树"
  (interactive)
  (file-tree-show default-directory))

(defun file-tree-show-buffer-file ()
  "显示当前文件所在目录的树"
  (interactive)
  (if buffer-file-name
      (file-tree-show (file-name-directory buffer-file-name))
    (file-tree-show-current-dir)))

;; 在dired模式中显示树
(defun file-tree-show-dired ()
  "在dired中显示当前文件/目录的树"
  (interactive)
  (if (derived-mode-p 'dired-mode)
      (let ((file (dired-get-file-for-visit)))
        (file-tree-show file))
    (error "不在dired模式下")))

(provide 'file-tree-printer)











;; 绑定快捷键
;;(global-set-key (kbd "C-c t") 'file-tree-show-current-dir)
;;(global-set-key (kbd "C-c f") 'file-tree-show-buffer-file)

在dired模式中绑定
;;(eval-after-load 'dired
;;  '(define-key dired-mode-map (kbd "C-c t") 'file-tree-show-dired))


