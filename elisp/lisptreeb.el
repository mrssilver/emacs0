



;;basic lisp tree


;; 树节点结构定义
(defstruct treenode
  value
  children)

;; 创建新节点
(defun make-treenode (value)
  (make-treenode :value value :children '()))

;; 添加子节点
(defun treenode-add-child (node child)
  (setf (treenode-children node)
        (append (treenode-children node) (list child)))
  node)



;; 简单的树形打印
(defun print-tree-simple (node &optional indent)
  "简单打印树结构"
  (let ((indent (or indent "")))
    ;; 打印当前节点
    (message "%s%s" indent (treenode-value node))
    ;; 递归打印子节点
    (dolist (child (treenode-children node))
      (print-tree-simple child (concat indent "  ")))))

;; 增强的树形打印（带连接线）
(defun print-tree (node &optional prefix is-last)
  "打印树形结构，带连接线"
  (let* ((prefix (or prefix ""))
         (node-prefix (if is-last "└── " "├── "))
         (child-prefix (if is-last "    " "│   ")))
    
    ;; 打印当前节点
    (message "%s%s%s" prefix node-prefix (treenode-value node))
    
    ;; 递归打印子节点
    (let ((child-count (length (treenode-children node)))
          (child-index 0))
      (dolist (child (treenode-children node))
        (let ((is-last-child (= (incf child-index) child-count))
              (new-prefix (concat prefix child-prefix)))
          (print-tree child new-prefix is-last-child))))))

;; 将树转换为字符串格式
(defun tree-to-string (node &optional prefix is-last)
  "将树转换为字符串表示"
  (let* ((prefix (or prefix ""))
         (node-prefix (if is-last "└── " "├── "))
         (child-prefix (if is-last "    " "│   "))
         (result ""))
    
    ;; 添加当前节点
    (setq result (concat result
                         prefix node-prefix
                         (treenode-value node) "\n"))
    
    ;; 递归添加子节点
    (let ((child-count (length (treenode-children node)))
          (child-index 0))
      (dolist (child (treenode-children node))
        (let ((is-last-child (= (incf child-index) child-count))
              (new-prefix (concat prefix child-prefix)))
          (setq result
                (concat result
                        (tree-to-string child new-prefix is-last-child))))))
    
    result))




;; 多种格式的树形打印
(defun print-tree-formatted (node &optional format)
  "以指定格式打印树"
  (let ((format (or format 'tree)))
    (cl-case format
      ('tree (print-tree node))
      ('lisp (print-tree-lisp node))
      ('lines (print-tree-lines node))
      ('indent (print-tree-indented node))
      (t (print-tree node)))))

;; Lisp风格打印（S表达式）
(defun print-tree-lisp (node)
  "以Lisp S表达式格式打印树"
  (if (null (treenode-children node))
      (message "%s" (treenode-value node))
    (let ((children-str ""))
      (dolist (child (treenode-children node))
        (setq children-str
              (concat children-str " " (tree-to-lisp-string child))))
      (message "(%s%s)" (treenode-value node) children-str))))

(defun tree-to-lisp-string (node)
  "将树转换为Lisp字符串"
  (if (null (treenode-children node))
      (treenode-value node)
    (let ((children-str ""))
      (dolist (child (treenode-children node))
        (setq children-str
              (concat children-str " " (tree-to-lisp-string child))))
      (format "(%s%s)" (treenode-value node) children-str))))

;; 缩进格式打印
(defun print-tree-indented (node &optional depth)
  "缩进格式打印树"
  (let ((depth (or depth 0))
        (indent (make-string (* depth 2) ? )))
    (message "%s%s" indent (treenode-value node))
    (dolist (child (treenode-children node))
      (print-tree-indented child (1+ depth)))))

;; 行格式打印（路径形式）
(defun print-tree-lines (node &optional path)
  "以路径形式打印树"
  (let* ((current-path (if path (concat path "/" (treenode-value node))
                         (treenode-value node))))
    (message "%s" current-path)
    (dolist (child (treenode-children node))
      (print-tree-lines child current-path))))




;; 带颜色的树形打印
(require 'color)

(defun print-tree-colored (node &optional prefix is-last depth)
  "彩色树形打印"
  (let* ((depth (or depth 0))
         (prefix (or prefix ""))
         (node-prefix (if is-last "└── " "├── "))
         (child-prefix (if is-last "    " "│   "))
         (colors '("#FF6B6B" "#4ECDC4" "#45B7D1" "#96CEB4" "#FFEAA7" "#DDA0DD" "#98D8C8"))
         (color (nth (mod depth (length colors)) colors)))
    
    ;; 打印当前节点（带颜色）
    (put-text-property
     0 (length (treenode-value node))
     'face `(:foreground ,color :weight bold)
     (treenode-value node))
    
    (message "%s%s%s" prefix node-prefix (treenode-value node))
    
    ;; 递归打印子节点
    (let ((child-count (length (treenode-children node)))
          (child-index 0))
      (dolist (child (treenode-children node))
        (let ((is-last-child (= (incf child-index) child-count))
              (new-prefix (concat prefix child-prefix)))
          (print-tree-colored child new-prefix is-last-child (1+ depth)))))))

;; 根据节点类型着色
(defun print-tree-by-type (node &optional prefix is-last)
  "根据节点类型着色打印"
  (let* ((prefix (or prefix ""))
         (node-prefix (if is-last "└── " "├── "))
         (child-prefix (if is-last "    " "│   "))
         (value (treenode-value node))
         (face (cond
                ((string-match "\\." value) 'font-lock-string-face)  ; 文件
                ((string-match "^[A-Z]" value) 'font-lock-type-face) ; 类型
                (t 'font-lock-function-name-face)))) ; 目录
    
    ;; 应用face
    (put-text-property 0 (length value) 'face face value)
    
    (message "%s%s%s" prefix node-prefix value)
    
    (let ((child-count (length (treenode-children node)))
          (child-index 0))
      (dolist (child (treenode-children node))
        (let ((is-last-child (= (incf child-index) child-count))
              (new-prefix (concat prefix child-prefix)))
          (print-tree-by-type child new-prefix is-last-child))))))



;; 从列表构建树
(defun list-to-tree (lst)
  "从嵌套列表构建树"
  (if (null lst)
      nil
    (let ((node (make-treenode (car lst))))
      (dolist (child (cdr lst))
        (if (listp child)
            (treenode-add-child node (list-to-tree child))
          (treenode-add-child node (make-treenode child))))
      node)))

;; 从目录结构构建树
(defun directory-to-tree (dir)
  "从目录结构构建树"
  (let ((node (make-treenode (file-name-nondirectory (directory-file-name dir)))))
    (dolist (file (directory-files dir t nil t))
      (unless (or (string-match "/\\.\\.?$" file)
                  (not (file-readable-p file)))
        (if (file-directory-p file)
            (treenode-add-child node (directory-to-tree file))
          (treenode-add-child node (make-treenode (file-name-nondirectory file))))))
    node))

;; 从字符串解析树（简单格式）
(defun parse-tree-from-string (str)
  "从字符串解析树结构"
  (let ((lines (split-string str "\n" t))
        (stack '())
        (root nil))
    (dolist (line lines)
      (let* ((indent (/ (length (string-match "^ *" line)) 2))
             (value (string-trim line))
             (node (make-treenode value)))
        
        ;; 调整堆栈
        (setq stack (nthcdr indent stack))
        
        (if (null stack)
            (setq root node
                  stack (list node))
          (treenode-add-child (car stack) node)
          (setq stack (cons node stack)))))
    root))



;; 创建示例树
(defun create-example-tree ()
  "创建示例树结构"
  (let ((root (make-treenode "project-root"))
        (src (make-treenode "src"))
        (tests (make-treenode "tests"))
        (docs (make-treenode "docs")))
    
    ;; 添加文件
    (treenode-add-child src (make-treenode "main.el"))
    (treenode-add-child src (make-treenode "utils.el"))
    (treenode-add-child src (make-treenode "config.el"))
    
    ;; src 的子目录
    (let ((lib (make-treenode "lib")))
      (treenode-add-child lib (make-treenode "helper.el"))
      (treenode-add-child src lib))
    
    ;; tests
    (treenode-add-child tests (make-treenode "test-main.el"))
    (treenode-add-child tests (make-treenode "test-utils.el"))
    
    ;; docs
    (treenode-add-child docs (make-treenode "README.md"))
    (treenode-add-child docs (make-treenode "API.md"))
    
    ;; 构建树
    (treenode-add-child root src)
    (treenode-add-child root tests)
    (treenode-add-child root docs)
    
    root))

;; 演示函数
(defun demo-tree-printing ()
  "演示树形打印的各种方法"
  (interactive)
  (let ((tree (create-example-tree)))
    
    (message "\n=== 简单树形打印 ===")
    (print-tree-simple tree)
    
    (message "\n=== 带连接线的树形打印 ===")
    (print-tree tree)
    
    (message "\n=== 字符串格式的树 ===")
    (message "%s" (tree-to-string tree))
    
    (message "\n=== Lisp格式 (S表达式) ===")
    (print-tree-lisp tree)
    
    (message "\n=== 缩进格式 ===")
    (print-tree-indented tree)
    
    (message "\n=== 路径格式 ===")
    (print-tree-lines tree)
    
    (message "\n=== 彩色打印 ===")
    (print-tree-colored tree)
    
    (message "\n=== 从列表构建树 ===")
    (let ((tree2 (list-to-tree
                  '("root" 
                    ("dir1" "file1.el" "file2.el")
                    ("dir2" 
                     ("subdir" "nested.el"))
                    "README.md"))))
      (print-tree tree2))
    
    (message "\n=== 从当前目录构建树 ===")
    (when (yes-or-no-p "从当前目录构建树? ")
      (let ((dir-tree (directory-to-tree default-directory)))
        (print-tree dir-tree)))))




;; 自定义打印函数
(defun print-tree-custom (node &optional prefix is-last
                                 node-formatter child-prefix-formatter)
  "自定义树形打印"
  (let* ((prefix (or prefix ""))
         (node-formatter (or node-formatter
                            (lambda (n p l) 
                              (format "%s%s%s" p 
                                      (if l "└── " "├── ") 
                                      (treenode-value n)))))
         (child-prefix-formatter (or child-prefix-formatter
                                     (lambda (p l) 
                                       (concat p (if l "    " "│   "))))))
    
    ;; 打印当前节点
    (message (funcall node-formatter node prefix is-last))
    
    ;; 递归打印子节点
    (let ((child-count (length (treenode-children node)))
          (child-index 0))
      (dolist (child (treenode-children node))
        (let ((is-last-child (= (incf child-index) child-count))
              (new-prefix (funcall child-prefix-formatter prefix is-last)))
          (print-tree-custom child new-prefix is-last-child
                             node-formatter child-prefix-formatter))))))

;; 使用自定义格式化
(defun demo-custom-printing ()
  "演示自定义打印"
  (interactive)
  (let ((tree (create-example-tree)))
    
    (message "\n=== 简单箭头格式 ===")
    (print-tree-custom 
     tree "" t
     (lambda (node prefix is-last)
       (format "%s%s> %s" prefix 
               (if is-last "`" "|") 
               (treenode-value node)))
     (lambda (prefix is-last)
       (concat prefix (if is-last "  " "| "))))
    
    (message "\n=== 带统计信息的格式 ===")
    (print-tree-custom
     tree "" t
     (lambda (node prefix is-last)
       (let ((child-count (length (treenode-children node))))
         (format "%s%s%s [%d child%s]" prefix
                 (if is-last "└── " "├── ")
                 (treenode-value node)
                 child-count
                 (if (= child-count 1) "" "ren"))))
     (lambda (prefix is-last)
       (concat prefix (if is-last "    " "│   "))))))


;;将树输出到buffer

;; 在buffer中显示树
(defun display-tree-in-buffer (tree buffer-name)
  "在指定buffer中显示树"
  (with-current-buffer (get-buffer-create buffer-name)
    (erase-buffer)
    (insert (tree-to-string tree))
    (special-mode)
    (display-buffer (current-buffer))))

;; 交互式树查看器
(defun view-tree ()
  "交互式查看树"
  (interactive)
  (let ((tree (create-example-tree)))
    (display-tree-in-buffer tree "*Tree View*")))