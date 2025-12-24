;; 文件树浏览器是一个强大的Elisp工具，可以：
;; 1. 显示文件和目录的树形结构
;; 2. 智能检查文件权限并提供修复建议
;; 3. 解析Elisp文件内容
;; 4. 支持多种输出格式和自定义选项
;; 5. 提供交互式浏览体验

;;; Code:

(require 'cl-lib)
(require 'dash)
(require 'f)
(require 's)
(require 'ht)
(require 'subr-x)
(require 'time-date)
(require 'json)
(require 'xml)
(require 'seq)

;; ==================== 自定义组和变量 ====================

(defgroup file-tree nil
  "文件树浏览器"
  :group 'tools
  :group 'files
  :prefix "file-tree-")

(defcustom file-tree-max-depth 20
  "最大遍历深度。"
  :type 'integer
  :group 'file-tree)

(defcustom file-tree-max-nodes 100
  "最大节点数，达到限制时会停止遍历。"
  :type 'integer
  :group 'file-tree)

(defcustom file-tree-show-hidden nil
  "是否显示隐藏文件。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-show-size nil
  "是否显示文件大小。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-show-time nil
  "是否显示修改时间。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-show-mode nil
  "是否显示文件权限。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-show-owner nil
  "是否显示文件所有者。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-show-group nil
  "是否显示文件所属组。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-follow-links nil
  "是否跟随符号链接。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-sort-by-name t
  "是否按名称排序。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-only-dirs nil
  "是否只显示目录。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-only-files nil
  "是否只显示文件。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-human-size t
  "是否以人类可读的格式显示文件大小。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-color t
  "是否使用颜色输出。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-verbose nil
  "是否显示详细信息。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-progress t
  "是否显示进度。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-summary t
  "是否显示摘要信息。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-stats nil
  "是否显示统计信息。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-elisp-parse t
  "是否解析Elisp文件。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-json-output nil
  "是否输出JSON格式。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-xml-output nil
  "是否输出XML格式。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-markdown-output nil
  "是否输出Markdown格式。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-html-output nil
  "是否输出HTML格式。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-output-file nil
  "输出文件名，如果为nil则输出到当前缓冲区。"
  :type '(choice (const nil) string)
  :group 'file-tree)

(defcustom file-tree-ignore-list
  '(".git" ".svn" ".hg" ".DS_Store" "node_modules" "__pycache__" ".cache"
    "thumbs.db" "desktop.ini" ".Spotlight-V100" ".Trashes" "._.DS_Store"
    ".fseventsd" ".idea" ".vscode" ".emacs.d/auto-save-list" ".emacs.d/elpa"
    "*.elc" "*.pyc" "*.pyo" "__pycache__" "*.class" "*.o" "*.so" "*.dll")
  "忽略的文件和目录列表。"
  :type '(repeat string)
  :group 'file-tree)

(defcustom file-tree-exclude-dirs nil
  "排除的目录列表。"
  :type '(repeat string)
  :group 'file-tree)

(defcustom file-tree-exclude-files nil
  "排除的文件列表。"
  :type '(repeat string)
  :group 'file-tree)

(defcustom file-tree-include-only nil
  "只包含的文件模式列表。"
  :type '(repeat string)
  :group 'file-tree)

(defcustom file-tree-pattern nil
  "文件模式匹配，例如 \"*.el\"。"
  :type '(choice (const nil) string)
  :group 'file-tree)

(defcustom file-tree-max-file-size 104857600
  "最大文件大小（字节），超过此大小的文件会被跳过。"
  :type 'integer
  :group 'file-tree)

(defcustom file-tree-skip-large t
  "是否跳过大文件。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-safe-mode t
  "安全模式，避免危险操作。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-interactive nil
  "交互模式。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-quiet nil
  "安静模式，减少输出。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-debug nil
  "调试模式，显示更多信息。"
  :type 'boolean
  :group 'file-tree)

(defcustom file-tree-threads 1
  "使用的线程数（在支持多线程的Emacs中）。"
  :type 'integer
  :group 'file-tree)

(defcustom file-tree-colors
  '((directory . "blue")
    (executable . "green")
    (symlink . "cyan")
    (elisp . "magenta")
    (permission-denied . "red")
    (warning . "yellow")
    (error . "red")
    (info . "cyan")
    (success . "green"))
  "颜色定义。"
  :type '(alist :key-type symbol :value-type string)
  :group 'file-tree)

(defcustom file-tree-icons
  '((directory . "📁")
    (file . "📄")
    (symlink . "🔗")
    (executable . "⚡")
    (elisp . "λ")
    (permission-denied . "🔒")
    (warning . "⚠️")
    (error . "❌")
    (info . "💡")
    (success . "✅"))
  "图标定义。"
  :type '(alist :key-type symbol :value-type string)
  :group 'file-tree)

;; ==================== 数据结构 ====================

(cl-defstruct (file-tree-node
               (:constructor file-tree-node-create)
               (:copier nil))
  "文件树节点结构。"
  (name nil :type string :documentation "节点名称")
  (path nil :type string :documentation "完整路径")
  (type 'file :type symbol :documentation "节点类型: file, dir, symlink, elisp, permission-denied")
  (size 0 :type integer :documentation "文件大小")
  (mod-time nil :type (or null integer) :documentation "修改时间")
  (mode nil :type (or null string) :documentation "文件权限")
  (children nil :type list :documentation "子节点列表")
  (depth 0 :type integer :documentation "深度")
  (is-last t :type boolean :documentation "是否是最后一个子节点")
  (error nil :type (or null string) :documentation "错误信息")
  (owner nil :type (or null string) :documentation "所有者")
  (group nil :type (or null string) :documentation "所属组")
  (icon nil :type (or null string) :documentation "图标")
  (color nil :type (or null string) :documentation "颜色"))

(cl-defstruct (file-tree-config
               (:constructor file-tree-config-create)
               (:copier nil))
  "文件树配置结构。"
  (max-depth file-tree-max-depth)
  (max-nodes file-tree-max-nodes)
  (show-hidden file-tree-show-hidden)
  (show-size file-tree-show-size)
  (show-time file-tree-show-time)
  (show-mode file-tree-show-mode)
  (show-owner file-tree-show-owner)
  (show-group file-tree-show-group)
  (follow-links file-tree-follow-links)
  (sort-by-name file-tree-sort-by-name)
  (only-dirs file-tree-only-dirs)
  (only-files file-tree-only-files)
  (human-size file-tree-human-size)
  (color file-tree-color)
  (verbose file-tree-verbose)
  (progress file-tree-progress)
  (summary file-tree-summary)
  (stats file-tree-stats)
  (elisp-parse file-tree-elisp-parse)
  (json-output file-tree-json-output)
  (xml-output file-tree-xml-output)
  (markdown file-tree-markdown-output)
  (html file-tree-html-output)
  (output-file file-tree-output-file)
  (pattern file-tree-pattern)
  (max-file-size file-tree-max-file-size)
  (skip-large file-tree-skip-large)
  (safe-mode file-tree-safe-mode)
  (interactive file-tree-interactive)
  (quiet file-tree-quiet)
  (debug file-tree-debug)
  (ignore-list file-tree-ignore-list)
  (exclude-dirs file-tree-exclude-dirs)
  (exclude-files file-tree-exclude-files)
  (include-only file-tree-include-only)
  (threads file-tree-threads))

(cl-defstruct (file-tree-stats
               (:constructor file-tree-stats-create)
               (:copier nil))
  "文件树统计结构。"
  (total-nodes 0 :type integer)
  (dirs 0 :type integer)
  (files 0 :type integer)
  (symlinks 0 :type integer)
  (executables 0 :type integer)
  (elisp-files 0 :type integer)
  (permission-denied 0 :type integer)
  (large-files 0 :type integer)
  (hidden-files 0 :type integer)
  (empty-dirs 0 :type integer)
  (empty-files 0 :type integer)
  (broken-links 0 :type integer)
  (total-size 0 :type integer)
  (max-depth 0 :type integer)
  (start-time nil :type (or null integer))
  (end-time nil :type (or null integer))
  (extensions (ht-create) :type hash-table)
  (depth-distribution (ht-create) :type hash-table))

(cl-defstruct (file-tree-error
               (:constructor file-tree-error-create)
               (:copier nil))
  "文件树错误结构。"
  (path nil :type string)
  (operation nil :type string)
  (error nil :type (or null string))
  (advice nil :type (or null string))
  (severity 'warning :type symbol) ; warning, error, info
  (timestamp (current-time) :type list))

;; ==================== 辅助函数 ====================

(defun file-tree--color (color-name text)
  "为文本着色。"
  (if (and file-tree-color (display-color-p))
      (propertize text 'face (list :foreground color-name))
    text))

(defun file-tree--icon (icon-name)
  "获取图标。"
  (or (alist-get icon-name file-tree-icons) ""))

(defun file-tree--format-size (bytes &optional human)
  "格式化文件大小。"
  (if (or (not human) (< bytes 1024))
      (format "%d" bytes)
    (let ((units '("B" "KB" "MB" "GB" "TB" "PB" "EB"))
          (size (float bytes))
          (unit-index 0))
      (while (and (>= size 1024.0) (< unit-index (1- (length units))))
        (setq size (/ size 1024.0))
        (cl-incf unit-index))
      (format "%.1f%s" size (nth unit-index units)))))

(defun file-tree--format-time (time)
  "格式化时间。"
  (format-time-string "%Y-%m-%d %H:%M" time))

(defun file-tree--format-duration (seconds)
  "格式化时间间隔。"
  (cond
   ((< seconds 60) (format "%.1fs" seconds))
   ((< seconds 3600) (format "%dm%ds"
                             (floor (/ seconds 60))
                             (mod (floor seconds) 60)))
   (t (format "%dh%dm"
              (floor (/ seconds 3600))
              (mod (floor (/ seconds 60)) 60)))))

(defun file-tree--truncate-string (str max-length)
  "截断字符串。"
  (if (<= (length str) max-length)
      str
    (concat (substring str 0 (- max-length 3)) "...")))

(defun file-tree--confirm (prompt)
  "确认提示。"
  (y-or-n-p prompt))

(defun file-tree--get-file-owner (path)
  "获取文件所有者。"
  (condition-case err
      (if (eq system-type 'windows-nt)
          (list "SYSTEM" "SYSTEM")
        (let* ((attrs (file-attributes path 'integer))
               (uid (nth 2 attrs))
               (gid (nth 3 attrs)))
          (list
           (condition-case nil
               (user-login-name uid)
             (error (number-to-string uid)))
           (condition-case nil
               (group-name gid)
             (error (number-to-string gid))))))
    (error (list "unknown" "unknown"))))

(defun file-tree--get-file-permissions (path)
  "获取文件权限字符串。"
  (let ((attrs (file-attributes path 'string)))
    (when attrs
      (file-modes-symbolic-to-number (nth 8 attrs)))))

(defun file-tree--check-permission (path)
  "检查文件权限，返回 (can-read can-execute error-message)。"
  (condition-case err
      (if (file-readable-p path)
          (if (file-directory-p path)
              (if (file-executable-p path)
                  (list t t nil)
                (list t nil "目录无执行权限"))
            (list t nil nil))
        (list nil nil "文件不可读"))
    (error (list nil nil (error-message-string err)))))

(defun file-tree--matches-pattern (name pattern)
  "检查文件名是否匹配模式。"
  (if (or (null pattern) (string-empty-p pattern))
      t
    (string-match-p (wildcard-to-regexp pattern) name)))

(defun file-tree--in-ignore-list (name ignore-list)
  "检查文件名是否在忽略列表中。"
  (cl-some (lambda (pattern)
             (string-match-p (wildcard-to-regexp pattern) name))
           ignore-list))

(defun file-tree--get-file-type (filename)
  "根据文件名确定文件类型。"
  (let ((ext (downcase (file-name-extension filename))))
    (cond
     ((string= ext "el") 'elisp)
     ((string= ext "elc") 'elisp-compiled)
     ((string= ext "py") 'python)
     ((string= ext "go") 'go)
     ((string= ext "js") 'javascript)
     ((string= ext "ts") 'typescript)
     ((string= ext "java") 'java)
     ((string= ext "c") 'c)
     ((string= ext "cpp") 'cpp)
     ((string= ext "h") 'c-header)
     ((string= ext "rs") 'rust)
     ((string= ext "json") 'json)
     ((string= ext "yaml") 'yaml)
     ((string= ext "yml") 'yaml)
     ((string= ext "toml") 'toml)
     ((string= ext "ini") 'ini)
     ((string= ext "xml") 'xml)
     ((string= ext "html") 'html)
     ((string= ext "css") 'css)
     ((string= ext "md") 'markdown)
     ((string= ext "org") 'org)
     ((string= ext "txt") 'text)
     ((string= ext "pdf") 'pdf)
     ((string= ext "zip") 'archive)
     ((string= ext "tar") 'archive)
     ((string= ext "gz") 'archive)
     ((string= ext "jpg") 'image)
     ((string= ext "png") 'image)
     ((string= ext "gif") 'image)
     ((string= ext "mp4") 'video)
     ((string= ext "avi") 'video)
     (t 'unknown))))

(defun file-tree--get-node-icon (node)
  "获取节点图标。"
  (let ((type (file-tree-node-type node))
        (error (file-tree-node-error node)))
    (cond
     (error (file-tree--icon 'error))
     ((eq type 'dir) (file-tree--icon 'directory))
     ((eq type 'symlink) (file-tree--icon 'symlink))
     ((eq type 'elisp) (file-tree--icon 'elisp))
     ((eq type 'permission-denied) (file-tree--icon 'permission-denied))
     ((file-executable-p (file-tree-node-path node)) (file-tree--icon 'executable))
     (t (file-tree--icon 'file)))))

(defun file-tree--get-node-color (node)
  "获取节点颜色。"
  (let ((type (file-tree-node-type node))
        (error (file-tree-node-error node)))
    (cond
     (error (alist-get 'error file-tree-colors))
     ((eq type 'dir) (alist-get 'directory file-tree-colors))
     ((eq type 'symlink) (alist-get 'symlink file-tree-colors))
     ((eq type 'elisp) (alist-get 'elisp file-tree-colors))
     ((eq type 'permission-denied) (alist-get 'permission-denied file-tree-colors))
     ((file-executable-p (file-tree-node-path node)) (alist-get 'executable file-tree-colors))
     (t nil))))

;; ==================== 文件树构建 ====================

(defun file-tree-build (path &optional config)
  "从路径构建文件树。"
  (let* ((config (or config (file-tree-config-create)))
         (abs-path (expand-file-name path))
         (attrs (file-attributes abs-path 'string))
         (root-node nil)
         (stats (file-tree-stats-create))
         (errors nil))
    
    (setf (file-tree-stats-start-time stats) (current-time))
    
    (unless attrs
      (error "无法访问路径: %s" path))
    
    (let ((is-dir (eq (car attrs) t)))
      (if is-dir
          (setq root-node (file-tree-build-directory abs-path config stats errors 0 t))
        (setq root-node (file-tree-build-file abs-path config stats errors))))
    
    (setf (file-tree-stats-end-time stats) (current-time))
    
    (list root-node stats errors)))

(defun file-tree-build-directory (path config stats errors depth is-last)
  "构建目录节点。"
  (when (and (> depth (file-tree-config-max-depth config))
             (not (file-tree-config-debug config)))
    (return-from file-tree-build-directory
      (file-tree-node-create
       :name (file-name-nondirectory path)
       :path path
       :type 'dir
       :depth depth
       :is-last is-last
       :error "达到最大深度限制")))
  
  (when (>= (file-tree-stats-total-nodes stats)
            (file-tree-config-max-nodes config))
    (return-from file-tree-build-directory
      (file-tree-node-create
       :name (file-name-nondirectory path)
       :path path
       :type 'dir
       :depth depth
       :is-last is-last
       :error "达到最大节点数限制")))
  
  (cl-incf (file-tree-stats-total-nodes stats))
  (cl-incf (file-tree-stats-dirs stats))
  (setf (file-tree-stats-max-depth stats) (max (file-tree-stats-max-depth stats) depth))
  
  (let* ((owner-group (file-tree--get-file-owner path))
         (node (file-tree-node-create
                :name (file-name-nondirectory path)
                :path path
                :type 'dir
                :mod-time (nth 5 (file-attributes path 'string))
                :mode (file-tree--get-file-permissions path)
                :depth depth
                :is-last is-last
                :owner (car owner-group)
                :group (cadr owner-group)
                :children nil)))
    
    ;; 检查权限
    (let ((permission (file-tree--check-permission path)))
      (unless (car permission) ; 无读取权限
        (setf (file-tree-node-error node) (caddr permission))
        (setf (file-tree-node-type node) 'permission-denied)
        (cl-incf (file-tree-stats-permission-denied stats))
        (return-from file-tree-build-directory node)))
    
    ;; 获取目录内容
    (condition-case err
        (let* ((entries (directory-files path t nil t))
               (filtered-entries (file-tree-filter-entries entries config stats))
               (sorted-entries (if (file-tree-config-sort-by-name config)
                                   (sort filtered-entries
                                         (lambda (a b)
                                           (string-lessp (file-name-nondirectory a)
                                                         (file-name-nondirectory b))))
                                 filtered-entries))
               (children nil)
               (child-count 0))
          
          (dolist (entry sorted-entries)
            (when (and (>= (file-tree-stats-total-nodes stats)
                           (file-tree-config-max-nodes config))
                       (not (file-tree-config-debug config)))
              (push (file-tree-node-create
                     :name "..."
                     :type 'info
                     :error "更多内容被截断")
                    children)
              (cl-incf child-count)
              (cl-incf (file-tree-stats-total-nodes stats))
              (return))
            
            (let* ((is-last-child (= child-count (1- (length sorted-entries))))
                   (child (if (file-directory-p entry)
                              (file-tree-build-directory entry config stats errors
                                                         (1+ depth) is-last-child)
                            (file-tree-build-file entry config stats errors is-last-child))))
              (when child
                (setf (file-tree-node-depth child) (1+ depth))
                (setf (file-tree-node-is-last child) is-last-child)
                (push child children)
                (cl-incf child-count))))
          
          (setf (file-tree-node-children node) (nreverse children)))
      
      (error
       (setf (file-tree-node-error node) (error-message-string err))
       (push (file-tree-error-create
              :path path
              :operation "读取目录"
              :error (error-message-string err)
              :severity 'error)
             errors)
       (cl-incf (file-tree-stats-permission-denied stats))))
    
    node))

(defun file-tree-build-file (path config stats errors &optional is-last)
  "构建文件节点。"
  (when (>= (file-tree-stats-total-nodes stats)
            (file-tree-config-max-nodes config))
    (return-from file-tree-build-file nil))
  
  (cl-incf (file-tree-stats-total-nodes stats))
  (cl-incf (file-tree-stats-files stats))
  
  (let* ((attrs (file-attributes path 'string))
         (size (nth 7 attrs))
         (owner-group (file-tree--get-file-owner path))
         (node (file-tree-node-create
                :name (file-name-nondirectory path)
                :path path
                :type 'file
                :size size
                :mod-time (nth 5 attrs)
                :mode (file-tree--get-file-permissions path)
                :is-last (or is-last t)
                :owner (car owner-group)
                :group (cadr owner-group))))
    
    ;; 检查权限
    (let ((permission (file-tree--check-permission path)))
      (unless (car permission) ; 无读取权限
        (setf (file-tree-node-error node) (caddr permission))
        (setf (file-tree-node-type node) 'permission-denied)
        (cl-incf (file-tree-stats-permission-denied stats))
        (return-from file-tree-build-file node)))
    
    ;; 检查文件大小
    (when (and (file-tree-config-skip-large config)
               (> size (file-tree-config-max-file-size config)))
      (setf (file-tree-node-error node) (format "文件过大 (%s)"
                                                (file-tree--format-size size t)))
      (cl-incf (file-tree-stats-large-files stats))
      (return-from file-tree-build-file node))
    
    ;; 更新统计
    (cl-incf (file-tree-stats-total-size stats) size)
    
    ;; 检查文件类型
    (cond
     ((string-suffix-p ".el" path)
      (setf (file-tree-node-type node) 'elisp)
      (cl-incf (file-tree-stats-elisp-files stats))
      (when (file-tree-config-elisp-parse config)
        (setf (file-tree-node-children node)
              (file-tree-parse-elisp-file path config stats errors))))
     
     ((file-symlink-p path)
      (setf (file-tree-node-type node) 'symlink)
      (cl-incf (file-tree-stats-symlinks stats))
      (unless (file-exists-p path)
        (cl-incf (file-tree-stats-broken-links stats))))
     
     ((file-executable-p path)
      (cl-incf (file-tree-stats-executables stats))))
    
    ;; 检查是否为空文件
    (when (zerop size)
      (cl-incf (file-tree-stats-empty-files stats)))
    
    ;; 检查是否为隐藏文件
    (when (string-prefix-p "." (file-name-nondirectory path))
      (cl-incf (file-tree-stats-hidden-files stats)))
    
    ;; 更新扩展名统计
    (let ((ext (or (file-name-extension path) "无扩展名")))
      (ht-set (file-tree-stats-extensions stats) ext
              (1+ (or (ht-get (file-tree-stats-extensions stats) ext) 0))))
    
    node))

(defun file-tree-filter-entries (entries config stats)
  "过滤目录条目。"
  (cl-remove-if-not
   (lambda (entry)
     (let* ((name (file-name-nondirectory entry))
            (is-dir (file-directory-p entry))
            (is-hidden (string-prefix-p "." name)))
       
       ;; 跳过 . 和 ..
       (when (or (string= name ".") (string= name ".."))
         (cl-return-from lambda nil))
       
       ;; 跳过隐藏文件（如果不显示）
       (when (and is-hidden (not (file-tree-config-show-hidden config)))
         (cl-incf (file-tree-stats-hidden-files stats))
         (cl-return-from lambda nil))
       
       ;; 检查忽略列表
       (when (file-tree--in-ignore-list name (file-tree-config-ignore-list config))
         (cl-return-from lambda nil))
       
       ;; 检查排除目录
       (when (and is-dir
                  (file-tree--in-ignore-list name (file-tree-config-exclude-dirs config)))
         (cl-return-from lambda nil))
       
       ;; 检查排除文件
       (when (and (not is-dir)
                  (file-tree--in-ignore-list name (file-tree-config-exclude-files config)))
         (cl-return-from lambda nil))
       
       ;; 检查包含列表
       (when (and (file-tree-config-include-only config)
                  (not (file-tree--in-ignore-list name (file-tree-config-include-only config))))
         (cl-return-from lambda nil))
       
       ;; 检查模式匹配
       (when (and (file-tree-config-pattern config)
                  (not (file-tree--matches-pattern name (file-tree-config-pattern config))))
         (cl-return-from lambda nil))
       
       ;; 检查只显示目录/文件
       (when (and (file-tree-config-only-dirs config) (not is-dir))
         (cl-return-from lambda nil))
       
       (when (and (file-tree-config-only-files config) is-dir)
         (cl-return-from lambda nil))
       
       t))
   entries))

(defun file-tree-parse-elisp-file (path config stats errors)
  "解析Elisp文件。"
  (condition-case err
      (with-temp-buffer
        (insert-file-contents path)
        (let ((lines (split-string (buffer-string) "\n"))
              (children nil)
              (line-num 0))
          
          (dolist (line lines)
            (cl-incf line-num)
            (let ((trimmed-line (string-trim line)))
              ;; 跳过空行和注释
              (when (and (not (string-empty-p trimmed-line))
                         (not (string-prefix-p ";" trimmed-line)))
                (let* ((display-line (file-tree--truncate-string trimmed-line 50))
                       (child (file-tree-node-create
                               :name (format "行 %d: %s" line-num display-line)
                               :type 'elisp-line
                               :depth 1)))
                  
                  ;; 尝试识别函数定义
                  (when (string-match "^(def\\(un\\|var\\|custom\\|const\\|macro\\|face\\)\\s-+\\([^[:space:]]+\\)" trimmed-line)
                    (let ((def-name (match-string 2 trimmed-line)))
                      (setf (file-tree-node-name child) (format "λ %s" def-name))))
                  
                  (push child children)
                  
                  (when (>= (length children) 20) ; 限制解析的行数
                    (push (file-tree-node-create
                           :name "... 更多内容被截断"
                           :type 'info)
                          children)
                    (cl-return))))))
          
          (nreverse children)))
    
    (error
     (push (file-tree-error-create
            :path path
            :operation "解析Elisp文件"
            :error (error-message-string err)
            :severity 'warning)
           errors)
     nil)))

;; ==================== 树形打印 ====================

(defun file-tree-print (tree-result &optional config)
  "打印文件树。"
  (let* ((config (or config (file-tree-config-create)))
         (root-node (car tree-result))
         (stats (cadr tree-result))
         (errors (caddr tree-result))
         (output-buffer (if (file-tree-config-output-file config)
                            (find-file-noselect (file-tree-config-output-file config))
                          (current-buffer))))
    
    (with-current-buffer output-buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        
        ;; 打印横幅
        (unless (file-tree-config-quiet config)
          (file-tree-print-banner)
          (insert "\n"))
        
        ;; 打印摘要
        (when (file-tree-config-summary config)
          (file-tree-print-summary root-node stats config)
          (insert "\n"))
        
        ;; 打印错误和警告
        (unless (file-tree-config-quiet config)
          (file-tree-print-errors errors config)
          (insert "\n"))
        
        ;; 根据输出格式打印树
        (cond
         ((file-tree-config-json-output config)
          (file-tree-print-json root-node))
         
         ((file-tree-config-xml-output config)
          (file-tree-print-xml root-node))
         
         ((file-tree-config-markdown config)
          (file-tree-print-markdown root-node))
         
         ((file-tree-config-html config)
          (file-tree-print-html root-node))
         
         (t
          (file-tree-print-text root-node config)))
        
        ;; 打印统计信息
        (when (file-tree-config-stats config)
          (file-tree-print-statistics stats config)
          (insert "\n"))
        
        ;; 打印提示
        (unless (file-tree-config-quiet config)
          (file-tree-print-tips root-node stats config)
          (insert "\n"))
        
        ;; 保存文件
        (when (file-tree-config-output-file config)
          (save-buffer)
          (message "文件树已保存到: %s" (file-tree-config-output-file config)))))))

(defun file-tree-print-banner ()
  "打印横幅。"
  (let ((banner "
███████╗██╗██╗     ███████╗████████╗██████╗ ███████╗███████╗
██╔════╝██║██║     ██╔════╝╚══██╔══╝██╔══██╗██╔════╝██╔════╝
█████╗  ██║██║     █████╗     ██║   ██████╔╝█████╗  █████╗  
██╔══╝  ██║██║     ██╔══╝     ██║   ██╔══██╗██╔══╝  ██╔══╝  
██║     ██║███████╗███████╗   ██║   ██║  ██║███████╗███████╗
╚═╝     ╚═╝╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝"))
    (insert (file-tree--color (alist-get 'info file-tree-colors) banner))
    (insert "\n")
    (insert (file-tree--color (alist-get 'success file-tree-colors)
                              (format "文件树浏览器 v1.0.0\n")))))

(defun file-tree-print-summary (node stats config)
  "打印摘要信息。"
  (let* ((duration (if (and (file-tree-stats-start-time stats)
                            (file-tree-stats-end-time stats))
                       (time-to-seconds
                        (time-subtract (file-tree-stats-end-time stats)
                                       (file-tree-stats-start-time stats)))
                     0))
         (duration-str (file-tree--format-duration duration)))
    
    (insert (file-tree--color (alist-get 'info file-tree-colors) "📁 路径: "))
    (insert (file-tree--color 'default (file-tree-node-path node)) "\n")
    
    (insert (file-tree--color (alist-get 'info file-tree-colors) "📊 统计: "))
    (insert (format "%d 目录, %d 文件, %d 节点"
                    (file-tree-stats-dirs stats)
                    (file-tree-stats-files stats)
                    (file-tree-stats-total-nodes stats)))
    
    (when (> (file-tree-stats-permission-denied stats) 0)
      (insert (file-tree--color (alist-get 'warning file-tree-colors)
                                (format ", %d 个权限被拒绝"
                                        (file-tree-stats-permission-denied stats)))))
    (insert "\n")
    
    (when (> (file-tree-stats-total-size stats) 0)
      (insert (file-tree--color (alist-get 'info file-tree-colors) "💾 总大小: "))
      (insert (file-tree--format-size (file-tree-stats-total-size stats)
                                      (file-tree-config-human-size config)))
      (insert "\n"))
    
    (insert (file-tree--color (alist-get 'info file-tree-colors) "⏱️  耗时: "))
    (insert duration-str "\n")
    
    (insert (file-tree--color (alist-get 'info file-tree-colors) "👤 用户: "))
    (insert (user-login-name) "\n")))

(defun file-tree-print-errors (errors config)
  "打印错误和警告。"
  (let ((warnings (cl-remove-if-not
                   (lambda (e) (eq (file-tree-error-severity e) 'warning))
                   errors))
        (errors-list (cl-remove-if-not
                      (lambda (e) (eq (file-tree-error-severity e) 'error))
                      errors)))
    
    (when errors-list
      (insert (file-tree--color (alist-get 'error file-tree-colors)
                                (format "❌ 错误 (%d):\n" (length errors-list))))
      (dolist (err errors-list)
        (insert (format "  • %s: %s\n"
                        (file-tree-error-operation err)
                        (file-tree-error-error err)))
        (when (and (file-tree-config-verbose config)
                   (file-tree-error-advice err))
          (insert (file-tree--color (alist-get 'info file-tree-colors)
                                    (format "     建议: %s\n" (file-tree-error-advice err)))))))
    
    (when warnings
      (insert (file-tree--color (alist-get 'warning file-tree-colors)
                                (format "⚠️  警告 (%d):\n" (length warnings))))
      (dolist (warn warnings)
        (insert (format "  • %s: %s\n"
                        (file-tree-error-operation warn)
                        (file-tree-error-error warn)))
        (when (and (file-tree-config-verbose config)
                   (file-tree-error-advice warn))
          (insert (file-tree--color (alist-get 'info file-tree-colors)
                                    (format "     建议: %s\n" (file-tree-error-advice warn)))))))))

(defun file-tree-print-text (node config &optional prefix is-last)
  "以文本格式打印树。"
  (let* ((prefix (or prefix ""))
         (node-prefix (if is-last "└── " "├── "))
         (child-prefix (if is-last "    " "│   "))
         (node-text (file-tree-format-node node config)))
    
    ;; 打印当前节点
    (insert (format "%s%s%s\n" prefix node-prefix node-text))
    
    ;; 递归打印子节点
    (let ((child-count (length (file-tree-node-children node)))
          (child-index 0))
      (dolist (child (file-tree-node-children node))
        (let ((is-last-child (= child-index (1- child-count)))
              (new-prefix (concat prefix child-prefix)))
          (file-tree-print-text child config new-prefix is-last-child)
          (cl-incf child-index))))))

(defun file-tree-format-node (node config)
  "格式化节点显示。"
  (let ((parts '())
        (icon (file-tree--get-node-icon node))
        (color (file-tree--get-node-color node))
        (name (file-tree-node-name node)))
    
    ;; 添加图标
    (when icon
      (push icon parts))
    
    ;; 添加名称（带颜色）
    (setq name (if color
                   (file-tree--color color name)
                 name))
    (push name parts)
    
    ;; 添加错误信息
    (when (and (file-tree-node-error node)
               (file-tree-config-verbose config))
      (push (format "[%s]" (file-tree-node-error node)) parts))
    
    ;; 添加权限信息
    (when (and (file-tree-config-show-mode config)
               (file-tree-node-mode node))
      (push (file-tree-node-mode node) parts))
    
    ;; 添加所有者信息
    (when (and (file-tree-config-show-owner config)
               (file-tree-node-owner node))
      (push (format "@%s" (file-tree-node-owner node)) parts))
    
    ;; 添加组信息
    (when (and (file-tree-config-show-group config)
               (file-tree-node-group node))
      (push (format ":%s" (file-tree-node-group node)) parts))
    
    ;; 添加大小
    (when (and (file-tree-config-show-size config)
               (> (file-tree-node-size node) 0))
      (push (format "(%s)" (file-tree--format-size (file-tree-node-size node)
                                                   (file-tree-config-human-size config)))
            parts))
    
    ;; 添加时间
    (when (and (file-tree-config-show-time config)
               (file-tree-node-mod-time node))
      (push (file-tree--format-time (file-tree-node-mod-time node)) parts))
    
    (mapconcat 'identity (nreverse parts) " ")))

(defun file-tree-print-statistics (stats config)
  "打印统计信息。"
  (insert (file-tree--color (alist-get 'info file-tree-colors) "📈 详细统计:\n\n"))
  
  ;; 文件类型统计
  (insert (file-tree--color (alist-get 'info file-tree-colors) "  📁 文件类型分布:\n"))
  (insert (format "    • 目录: %d\n" (file-tree-stats-dirs stats)))
  (insert (format "    • 文件: %d\n" (file-tree-stats-files stats)))
  (insert (format "    • 符号链接: %d\n" (file-tree-stats-symlinks stats)))
  (insert (format "    • 可执行文件: %d\n" (file-tree-stats-executables stats)))
  (insert (format "    • Elisp文件: %d\n" (file-tree-stats-elisp-files stats)))
  
  (when (> (file-tree-stats-permission-denied stats) 0)
    (insert (format "    • 权限被拒绝: %d\n" (file-tree-stats-permission-denied stats))))
  
  (when (> (file-tree-stats-large-files stats) 0)
    (insert (format "    • 大文件: %d\n" (file-tree-stats-large-files stats))))
  
  (when (> (file-tree-stats-empty-files stats) 0)
    (insert (format "    • 空文件: %d\n" (file-tree-stats-empty-files stats))))
  
  (when (> (file-tree-stats-broken-links stats) 0)
    (insert (format "    • 损坏的符号链接: %d\n" (file-tree-stats-broken-links stats))))
  
  ;; 扩展名统计
  (let ((extensions (ht-items (file-tree-stats-extensions stats))))
    (when extensions
      (insert "\n  📄 扩展名统计:\n")
      (dolist (ext extensions)
        (when (> (cdr ext) 5) ; 只显示常见的扩展名
          (insert (format "    • .%s: %d\n" (car ext) (cdr ext)))))))
  
  ;; 深度统计
  (let ((depths (ht-items (file-tree-stats-depth-distribution stats))))
    (when depths
      (insert "\n  📊 深度分布:\n")
      (dolist (depth depths)
        (insert (format "    • 深度 %s: %d 个节点\n" (car depth) (cdr depth)))))))

(defun file-tree-print-tips (node stats config)
  "打印提示信息。"
  (when (>= (file-tree-stats-total-nodes stats)
            (file-tree-config-max-nodes config))
    (insert (file-tree--color (alist-get 'warning file-tree-colors)
                              (format "⚠️  节点数已达限制 (%d)，已停止遍历\n"
                                      (file-tree-config-max-nodes config))))
    (insert (file-tree--color (alist-get 'info file-tree-colors)
                              "   使用 M-x customize-variable RET file-tree-max-nodes RET 调整限制\n")))
  
  (when (> (file-tree-stats-permission-denied stats) 0)
    (insert (file-tree--color (alist-get 'info file-tree-colors) "\n💡 权限提示:\n"))
    (insert "   如果您需要访问被跳过的文件/目录:\n")
    (insert "   1. 使用管理员权限\n")
    (insert "   2. 修改文件权限: chmod -R 755 [路径]\n")
    (insert "   3. 修改文件所有者: chown -R $USER:$USER [路径]\n")
    (insert "   4. 检查SELinux状态: getenforce\n")))

;; ==================== 其他输出格式 ====================

(defun file-tree-print-json (node)
  "以JSON格式打印树。"
  (insert (json-encode (file-tree-node-to-alist node))))

(defun file-tree-node-to-alist (node)
  "将节点转换为关联列表。"
  (list
   (cons 'name (file-tree-node-name node))
   (cons 'path (file-tree-node-path node))
   (cons 'type (file-tree-node-type node))
   (cons 'size (file-tree-node-size node))
   (cons 'mod-time (file-tree-node-mod-time node))
   (cons 'mode (file-tree-node-mode node))
   (cons 'owner (file-tree-node-owner node))
   (cons 'group (file-tree-node-group node))
   (cons 'error (file-tree-node-error node))
   (cons 'depth (file-tree-node-depth node))
   (cons 'children (mapcar 'file-tree-node-to-alist
                           (file-tree-node-children node)))))

(defun file-tree-print-xml (node)
  "以XML格式打印树。"
  (let ((xml (file-tree-node-to-xml node)))
    (insert (with-temp-buffer
              (xml-print xml)
              (buffer-string)))))

(defun file-tree-node-to-xml (node)
  "将节点转换为XML节点。"
  (let ((attrs `((name . ,(file-tree-node-name node))
                 (path . ,(file-tree-node-path node))
                 (type . ,(symbol-name (file-tree-node-type node)))
                 (size . ,(number-to-string (file-tree-node-size node)))
                 (mod-time . ,(if (file-tree-node-mod-time node)
                                  (format-time-string "%Y-%m-%d %H:%M:%S"
                                                      (file-tree-node-mod-time node))
                                ""))
                 (mode . ,(or (file-tree-node-mode node) ""))
                 (owner . ,(or (file-tree-node-owner node) ""))
                 (group . ,(or (file-tree-node-group node) ""))
                 (error . ,(or (file-tree-node-error node) ""))
                 (depth . ,(number-to-string (file-tree-node-depth node))))))
    
    `(node ,attrs
           ,@(mapcar 'file-tree-node-to-xml
                     (file-tree-node-children node)))))

(defun file-tree-print-markdown (node)
  "以Markdown格式打印树。"
  (file-tree-print-markdown-recursive node ""))

(defun file-tree-print-markdown-recursive (node prefix)
  "递归打印Markdown格式的树。"
  (let* ((icon (file-tree--get-node-icon node))
         (name (file-tree-node-name node))
         (line (format "%s- %s %s" prefix icon name))
         (child-prefix (concat prefix "  ")))
    
    (insert line "\n")
    
    (dolist (child (file-tree-node-children node))
      (file-tree-print-markdown-recursive child child-prefix))))

(defun file-tree-print-html (node)
  "以HTML格式打印树。"
  (insert "<!DOCTYPE html>\n")
  (insert "<html>\n")
  (insert "<head>\n")
  (insert "  <meta charset=\"utf-8\">\n")
  (insert "  <title>文件树浏览器</title>\n")
  (insert "  <style>\n")
  (insert "    body { font-family: monospace; margin: 20px; }\n")
  (insert "    .tree { margin-left: 20px; }\n")
  (insert "    .node { margin: 2px 0; }\n")
  (insert "    .dir { color: blue; font-weight: bold; }\n")
  (insert "    .file { color: black; }\n")
  (insert "    .error { color: red; }\n")
  (insert "    .warning { color: orange; }\n")
  (insert "  </style>\n")
  (insert "</head>\n")
  (insert "<body>\n")
  (insert "<h1>文件树浏览器</h1>\n")
  (insert "<div class=\"tree\">\n")
  (file-tree-print-html-recursive node)
  (insert "</div>\n")
  (insert "</body>\n")
  (insert "</html>\n"))

(defun file-tree-print-html-recursive (node)
  "递归打印HTML格式的树。"
  (let* ((icon (file-tree--get-node-icon node))
         (name (file-tree-node-name node))
         (type (file-tree-node-type node))
         (error (file-tree-node-error node))
         (class (cond
                 (error "error")
                 ((eq type 'dir) "dir")
                 (t "file"))))
    
    (insert (format "<div class=\"node %s\">%s %s</div>\n" class icon name))
    
    (dolist (child (file-tree-node-children node))
      (file-tree-print-html-recursive child))))

;; ==================== 交互式命令 ====================

(defun file-tree-browse (path)
  "浏览文件树。"
  (interactive "DPath: ")
  (let ((config (file-tree-config-create)))
    (when (and file-tree-interactive
               (not (file-tree--confirm (format "浏览路径: %s? " path))))
      (message "操作取消")
      (cl-return))
    
    (message "正在构建文件树...")
    (let ((tree-result (file-tree-build path config)))
      (message "正在打印文件树...")
      (file-tree-print tree-result config)
      (message "完成"))))

(defun file-tree-browse-current-directory ()
  "浏览当前目录。"
  (interactive)
  (file-tree-browse default-directory))

(defun file-tree-browse-current-file ()
  "浏览当前文件所在目录。"
  (interactive)
  (if buffer-file-name
      (file-tree-browse (file-name-directory buffer-file-name))
    (file-tree-browse-current-directory)))

(defun file-tree-browse-home ()
  "浏览家目录。"
  (interactive)
  (file-tree-browse (expand-file-name "~")))

(defun file-tree-browse-root ()
  "浏览根目录。"
  (interactive)
  (file-tree-browse "/"))

(defun file-tree-browse-git-root ()
  "浏览Git仓库根目录。"
  (interactive)
  (let ((root (locate-dominating-file default-directory ".git")))
    (if root
        (file-tree-browse root)
      (error "未找到Git仓库"))))

(defun file-tree-quick-browse ()
  "快速浏览，使用默认配置。"
  (interactive)
  (let ((config (file-tree-config-create)))
    (setf (file-tree-config-show-size config) t)
    (setf (file-tree-config-show-time config) t)
    (setf (file-tree-config-show-mode config) t)
    (file-tree-browse default-directory)))

(defun file-tree-browse-with-config ()
  "使用自定义配置浏览。"
  (interactive)
  (let ((path (read-directory-name "路径: " default-directory))
        (config (file-tree-config-create)))
    ;; 这里可以添加自定义配置的界面
    (file-tree-browse path)))

;; ==================== 缓冲区模式 ====================

(define-derived-mode file-tree-mode special-mode "File Tree"
  "文件树浏览器模式。"
  (setq buffer-read-only t)
  (setq truncate-lines t)
  (font-lock-mode 1)
  (hl-line-mode 1)
  (use-local-map file-tree-mode-map))

(defvar file-tree-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "n") 'next-line)
    (define-key map (kbd "p") 'previous-line)
    (define-key map (kbd "f") 'forward-char)
    (define-key map (kbd "b") 'backward-char)
    (define-key map (kbd "v") 'scroll-up-command)
    (define-key map (kbd "V") 'scroll-down-command)
    (define-key map (kbd "g") 'revert-buffer)
    (define-key map (kbd "q") 'quit-window)
    (define-key map (kbd "RET") 'file-tree-find-file)
    (define-key map (kbd "o") 'file-tree-find-file-other-window)
    (define-key map (kbd "d") 'file-tree-delete-file)
    (define-key map (kbd "c") 'file-tree-copy-file)
    (define-key map (kbd "r") 'file-tree-rename-file)
    (define-key map (kbd "m") 'file-tree-chmod)
    (define-key map (kbd "s") 'file-tree-search)
    (define-key map (kbd "F") 'file-tree-filter)
    (define-key map (kbd "S") 'file-tree-sort)
    (define-key map (kbd "C") 'file-tree-configure)
    (define-key map (kbd "H") 'file-tree-help)
    map)
  "文件树浏览器模式键盘映射。")

(defun file-tree-find-file ()
  "在当前行打开文件。"
  (interactive)
  (let ((path (file-tree-get-path-at-point)))
    (when path
      (if (file-directory-p path)
          (dired path)
        (find-file path)))))

(defun file-tree-find-file-other-window ()
  "在其他窗口打开文件。"
  (interactive)
  (let ((path (file-tree-get-path-at-point)))
    (when path
      (if (file-directory-p path)
          (dired-other-window path)
        (find-file-other-window path)))))

(defun file-tree-get-path-at-point ()
  "获取当前点的路径。"
  (save-excursion
    (beginning-of-line)
    (when (re-search-forward "路径: \\(.+\\)" (line-end-position) t)
      (match-string 1))))

(defun file-tree-delete-file ()
  "删除当前文件。"
  (interactive)
  (let ((path (file-tree-get-path-at-point)))
    (when path
      (when (file-tree--confirm (format "确定删除 %s? " (file-name-nondirectory path)))
        (if (file-directory-p path)
            (delete-directory path t)
          (delete-file path))
        (revert-buffer)))))

(defun file-tree-copy-file ()
  "复制当前文件。"
  (interactive)
  (let ((path (file-tree-get-path-at-point)))
    (when path
      (let ((new-name (read-file-name "复制到: " (file-name-directory path))))
        (copy-file path new-name t)
        (revert-buffer)))))

(defun file-tree-rename-file ()
  "重命名当前文件。"
  (interactive)
  (let ((path (file-tree-get-path-at-point)))
    (when path
      (let ((new-name (read-file-name "新名称: " (file-name-directory path))))
        (rename-file path new-name)
        (revert-buffer)))))

(defun file-tree-chmod ()
  "修改文件权限。"
  (interactive)
  (let ((path (file-tree-get-path-at-point)))
    (when path
      (let ((mode (read-string "权限 (八进制): ")))
        (set-file-modes path (string-to-number mode 8))
        (revert-buffer)))))

(defun file-tree-search ()
  "搜索文件。"
  (interactive)
  (let ((pattern (read-string "搜索模式: ")))
    (occur pattern)))

(defun file-tree-filter ()
  "过滤文件。"
  (interactive)
  (let ((pattern (read-string "过滤模式: ")))
    (message "过滤功能尚未实现")))

(defun file-tree-sort ()
  "排序文件。"
  (interactive)
  (message "排序功能尚未实现"))

(defun file-tree-configure ()
  "配置选项。"
  (interactive)
  (customize-group 'file-tree))

(defun file-tree-help ()
  "显示帮助。"
  (interactive)
  (describe-mode))

;; ==================== 集成功能 ====================

(defun file-tree-dired-integration ()
  "集成到Dired模式。"
  (define-key dired-mode-map (kbd "C-c t") 'file-tree-browse-dired)
  (define-key dired-mode-map (kbd "C-c f") 'file-tree-browse-dired-file))

(defun file-tree-browse-dired ()
  "在Dired中浏览当前目录。"
  (interactive)
  (file-tree-browse dired-directory))

(defun file-tree-browse-dired-file ()
  "在Dired中浏览当前文件。"
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (if (file-directory-p file)
        (file-tree-browse file)
      (file-tree-browse (file-name-directory file)))))

(defun file-tree-projectile-integration ()
  "集成到Projectile。"
  (when (fboundp 'projectile-project-root)
    (defun file-tree-browse-project ()
      "浏览项目根目录。"
      (interactive)
      (let ((root (projectile-project-root)))
        (if root
            (file-tree-browse root)
          (error "未找到项目"))))
    
    (define-key projectile-mode-map (kbd "C-c p t") 'file-tree-browse-project)))

(defun file-tree-ido-integration ()
  "集成到IDO。"
  (defun ido-file-tree (dir)
    "使用IDO选择目录并浏览。"
    (interactive (list (ido-read-directory-name "浏览目录: ")))
    (file-tree-browse dir)))

;; ==================== 主入口点 ====================

;;;###autoload
(defun file-tree ()
  "启动文件树浏览器。"
  (interactive)
  (switch-to-buffer "*File Tree*")
  (file-tree-mode)
  (let ((inhibit-read-only t))
    (erase-buffer)
    (insert "文件树浏览器\n\n")
    (insert "命令:\n")
    (insert "  M-x file-tree-browse              - 浏览指定目录\n")
    (insert "  M-x file-tree-browse-current-directory - 浏览当前目录\n")
    (insert "  M-x file-tree-browse-current-file - 浏览当前文件所在目录\n")
    (insert "  M-x file-tree-browse-home         - 浏览家目录\n")
    (insert "  M-x file-tree-browse-root         - 浏览根目录\n")
    (insert "  M-x file-tree-quick-browse        - 快速浏览\n")
    (insert "\n")
    (insert "按键绑定:\n")
    (insert "  RET - 打开文件/目录\n")
    (insert "  o   - 在其他窗口打开\n")
    (insert "  d   - 删除文件\n")
    (insert "  c   - 复制文件\n")
    (insert "  r   - 重命名文件\n")
    (insert "  m   - 修改权限\n")
    (insert "  q   - 退出\n")
    (insert "\n")
    (insert "输入 M-x file-tree-browse 开始浏览。")))

;;;###autoload
(defun file-tree-from-dired ()
  "从Dired启动文件树浏览器。"
  (interactive)
  (if (derived-mode-p 'dired-mode)
      (file-tree-browse dired-directory)
    (error "不在Dired模式")))

;; ==================== 测试和示例 ====================

(defun file-tree-test ()
  "运行测试。"
  (interactive)
  (message "开始测试...")
  
  ;; 测试当前目录
  (file-tree-browse-current-directory)
  
  ;; 测试家目录
  (sleep-for 1)
  (file-tree-browse-home)
  
  ;; 测试根目录
  (sleep-for 1)
  (file-tree-browse-root)
  
  (message "测试完成！"))

(defun file-tree-example ()
  "显示使用示例。"
  (interactive)
  (switch-to-buffer "*File Tree Examples*")
  (let ((inhibit-read-only t))
    (erase-buffer)
    (insert "文件树浏览器使用示例\n\n")
    
    (insert "1. 基本使用:\n")
    (insert "   M-x file-tree-browse RET ~/projects\n")
    (insert "\n")
    
    (insert "2. 显示详细信息:\n")
    (insert "   (let ((config (file-tree-config-create)))\n")
    (insert "     (setf (file-tree-config-show-size config) t)\n")
    (insert "     (setf (file-tree-config-show-time config) t)\n")
    (insert "     (setf (file-tree-config-show-mode config) t)\n")
    (insert "     (file-tree-browse \".\" config))\n")
    (insert "\n")
    
    (insert "3. 导出到JSON:\n")
    (insert "   (let ((config (file-tree-config-create)))\n")
    (insert "     (setf (file-tree-config-json-output config) t)\n")
    (insert "     (setf (file-tree-config-output-file config) \"tree.json\")\n")
    (insert "     (file-tree-browse \".\" config))\n")
    (insert "\n")
    
    (insert "4. 自定义配置:\n")
    (insert "   (customize-group 'file-tree)\n")
    (insert "\n")
    
    (insert "5. 在配置文件中设置默认值:\n")
    (insert "   (setq file-tree-show-size t)\n")
    (insert "   (setq file-tree-show-time t)\n")
    (insert "   (setq file-tree-max-depth 10)\n")
    (insert "\n")))
  
(provide 'file-tree-browser)

;;; file-tree-browser.el ends here
