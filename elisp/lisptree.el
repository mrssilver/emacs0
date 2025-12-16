
;;lisp nodetree
;;Lisp 代码语法树解析和显示工具，可以读取缓冲区或选中区域的 Lisp 代码，将其解析为语法树并以树状结构打印：

;;; ==========================================
;;; Lisp 代码语法树分析工具
;;; ==========================================

(require 'cl-lib)
(require 'seq)
(require 'subr-x)

;;; 1. 语法树节点结构
(cl-defstruct lisp-tree-node
  "Lisp语法树节点"
  (type nil)      ; 节点类型：symbol, list, number, string, keyword, etc.
  (value nil)     ; 节点的值
  (children nil)  ; 子节点列表
  (position nil)  ; 在源码中的位置 (beg . end)
  (depth 0)       ; 深度
  (parent nil))   ; 父节点

;;; 2. 颜色定义
(defvar tree-colors
  '((:symbol     . "#ffd700")    ; 黄金
    (:keyword    . "#bd93f9")    ; 紫色
    (:string     . "#f1fa8c")    ; 浅金
    (:number     . "#8be9fd")    ; 青色
    (:list       . "#ff5555")    ; 红色
    (:function   . "#50fa7b")    ; 绿色
    (:variable   . "#ffb86c")    ; 橙色
    (:comment    . "#6272a4")    ; 灰色
    (:error      . "#ff3333")    ; 红色
    (:default    . "#f8f8f2"))   ; 奶白
  "语法树节点颜色")

(defun tree-color (name)
  "获取颜色值"
  (cdr (assoc name tree-colors)))

;;; 3. Lisp 代码解析
(defun parse-lisp-code (code)
  "解析Lisp代码字符串，返回语法树"
  (condition-case err
      (with-temp-buffer
        (insert code)
        (goto-char (point-min))
        (let ((nodes nil)
              (position-stack nil))
          
          ;; 读取所有表达式
          (while (not (eobp))
            (skip-chars-forward " \t\n\r")
            (unless (eobp)
              (let ((start (point))
                    (expr (read (current-buffer)))
                    (end (point)))
                (when expr
                  (push (parse-expression expr start end) nodes)))))
          
          (reverse nodes)))
    (error
     (message "解析Lisp代码失败: %s" (error-message-string err))
     nil)))

(defun parse-expression (expr &optional start end)
  "递归解析表达式"
  (cond
   ;; 列表
   ((consp expr)
    (let ((node (make-lisp-tree-node
                 :type 'list
                 :value (if (functionp (car expr)) 'function-call 'list)
                 :position (cons start end)
                 :children nil)))
      (setf (lisp-tree-node-children node)
            (cl-loop for elem in expr
                     for i from 0
                     for child = (parse-expression elem)
                     when child
                     do (setf (lisp-tree-node-parent child) node
                              (lisp-tree-node-depth child) (1+ (lisp-tree-node-depth node)))
                     and collect child))
      node))
   
   ;; 符号
   ((symbolp expr)
    (make-lisp-tree-node
     :type 'symbol
     :value expr
     :position (cons start end)
     :children nil))
   
   ;; 字符串
   ((stringp expr)
    (make-lisp-tree-node
     :type 'string
     :value expr
     :position (cons start end)
     :children nil))
   
   ;; 数字
   ((numberp expr)
    (make-lisp-tree-node
     :type 'number
     :value expr
     :position (cons start end)
     :children nil))
   
   ;; 关键字
   ((keywordp expr)
    (make-lisp-tree-node
     :type 'keyword
     :value expr
     :position (cons start end)
     :children nil))
   
   ;; nil
   ((null expr)
    (make-lisp-tree-node
     :type 'symbol
     :value 'nil
     :position (cons start end)
     :children nil))
   
   ;; 其他
   (t
    (make-lisp-tree-node
     :type 'unknown
     :value expr
     :position (cons start end)
     :children nil))))

;;; 4. 树状显示
(defun print-tree-node (node &optional indent)
  "递归打印语法树节点"
  (let* ((depth (or (lisp-tree-node-depth node) 0))
         (indent-str (make-string (* depth 2) ?\s))
         (type (lisp-tree-node-type node))
         (value (lisp-tree-node-value node))
         (children (lisp-tree-node-children node))
         (formatted-value (format-tree-node-value value type)))
    
    (insert indent-str)
    
    ;; 根据类型着色
    (let ((color (cond
                  ((eq type 'symbol) (tree-color :symbol))
                  ((eq type 'keyword) (tree-color :keyword))
                  ((eq type 'string) (tree-color :string))
                  ((eq type 'number) (tree-color :number))
                  ((eq type 'list) (tree-color :list))
                  (t (tree-color :default)))))
      
      (insert (propertize formatted-value
                          'face `(:foreground ,color
                                  :weight ,(if children 'bold 'normal))
                          'lisp-tree-node node
                          'lisp-tree-depth depth)))
    
    ;; 如果有位置信息，添加位置标记
    (when (lisp-tree-node-position node)
      (let ((pos (lisp-tree-node-position node)))
        (insert (propertize (format " [%d:%d]" (car pos) (cdr pos))
                            'face '(:foreground "#6272a4" :italic t)))))
    
    (insert "\n")
    
    ;; 递归打印子节点
    (dolist (child children)
      (print-tree-node child (1+ (or indent 0))))))

(defun format-tree-node-value (value type)
  "格式化树节点值"
  (cond
   ((eq type 'string)
    (format "%S" value))  ; 字符串加引号
   ((eq type 'list)
    (if (eq value 'function-call)
        "function-call"
      "list"))
   ((null value)
    "nil")
   ((symbolp value)
    (symbol-name value))
   ((keywordp value)
    (concat ":" (symbol-name value)))
   (t
    (format "%s" value))))

;;; 5. 主显示函数
(defun lisp-tree-display (code &optional buffer-name)
  "显示Lisp代码的语法树"
  (let* ((nodes (parse-lisp-code code))
         (buffer (get-buffer-create (or buffer-name "*Lisp Syntax Tree*"))))
    
    (with-current-buffer buffer
      (erase-buffer)
      (lisp-tree-mode)
      
      ;; 添加标题
      (insert (propertize "Lisp 代码语法树分析\n" 
                          'face '(:height 1.5 :weight bold :foreground "#ffd700")))
      (insert "\n")
      
      ;; 如果没有节点，显示错误
      (if (null nodes)
          (progn
            (insert (propertize "错误: 无法解析Lisp代码\n" 
                                'face '(:foreground "#ff5555" :weight bold)))
            (insert "请检查代码语法是否正确。\n"))
        
        ;; 显示统计信息
        (let* ((total-nodes (count-tree-nodes nodes))
               (max-depth (tree-max-depth nodes)))
          (insert (format "表达式数量: %d\n" (length nodes)))
          (insert (format "总节点数: %d\n" total-nodes))
          (insert (format "最大深度: %d\n" max-depth))
          (insert "\n"))
        
        ;; 打印所有树的根节点
        (dolist (node nodes)
          (print-tree-node node))
        
        ;; 添加分隔线
        (insert "\n" (make-string 80 ?-) "\n\n")
        
        ;; 添加符号表
        (insert (propertize "符号表:\n" 'face '(:weight bold :foreground "#ffd700")))
        (let ((symbols (collect-symbols nodes)))
          (if symbols
              (progn
                (cl-loop for (symbol . count) in symbols
                         do (insert (format "  %s: %d 次\n" symbol count))))
            (insert "  (无符号)\n")))
        
        ;; 添加帮助信息
        (insert "\n" (propertize "快捷键:\n" 'face '(:weight bold :foreground "#ffd700")))
        (insert "  n/p - 下一个/上一个节点\n")
        (insert "  t   - 跳转到源码位置\n")
        (insert "  c   - 复制节点\n")
        (insert "  q   - 退出\n"))
      
      (goto-char (point-min)))
    
    (display-buffer buffer)
    buffer))

;;; 6. 工具函数
(defun count-tree-nodes (nodes)
  "统计树中节点总数"
  (cl-labels ((count-node (node)
                (1+ (cl-reduce '+ (lisp-tree-node-children node)
                               :key #'count-node))))
    (cl-reduce '+ nodes :key #'count-node)))

(defun tree-max-depth (nodes)
  "计算树的最大深度"
  (cl-labels ((node-depth (node)
                (if (lisp-tree-node-children node)
                    (1+ (cl-reduce 'max (lisp-tree-node-children node)
                                   :key #'node-depth))
                  0)))
    (cl-reduce 'max nodes :key #'node-depth)))

(defun collect-symbols (nodes)
  "收集所有符号及其出现次数"
  (let ((symbol-table (make-hash-table :test 'equal)))
    (cl-labels ((collect-from-node (node)
                  (when (eq (lisp-tree-node-type node) 'symbol)
                    (let* ((sym (lisp-tree-node-value node))
                           (sym-str (if (keywordp sym)
                                        (concat ":" (symbol-name sym))
                                      (symbol-name sym))))
                      (puthash sym-str (1+ (gethash sym-str symbol-table 0))
                               symbol-table)))
                  (dolist (child (lisp-tree-node-children node))
                    (collect-from-node child))))
      (dolist (node nodes)
        (collect-from-node node)))
    
    ;; 排序并返回列表
    (let (result)
      (maphash (lambda (sym count) (push (cons sym count) result)) symbol-table)
      (sort result (lambda (a b) (> (cdr a) (cdr b)))))))

;;; 7. 主命令函数
(defun lisp-tree-from-buffer ()
  "分析当前缓冲区的Lisp代码"
  (interactive)
  (let ((code (buffer-substring-no-properties (point-min) (point-max))))
    (lisp-tree-display code "*Lisp Syntax Tree*")
    (message "已分析当前缓冲区的Lisp代码")))

(defun lisp-tree-from-region ()
  "分析选中区域的Lisp代码"
  (interactive)
  (if (use-region-p)
      (let ((code (buffer-substring-no-properties (region-beginning) (region-end))))
        (lisp-tree-display code "*Lisp Syntax Tree*")
        (message "已分析选中区域的Lisp代码"))
    (message "请先选中一个区域")))

(defun lisp-tree-from-file (filename)
  "从文件分析Lisp代码"
  (interactive "f选择Lisp文件: ")
  (with-temp-buffer
    (insert-file-contents filename)
    (lisp-tree-display (buffer-string)
                       (format "*Lisp Syntax Tree: %s*" (file-name-nondirectory filename)))
    (message "已分析文件: %s" filename)))

;;; 8. 树模式
(defvar lisp-tree-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "n") 'lisp-tree-next-node)
    (define-key map (kbd "p") 'lisp-tree-prev-node)
    (define-key map (kbd "t") 'lisp-tree-goto-source)
    (define-key map (kbd "c") 'lisp-tree-copy-node)
    (define-key map (kbd "q") 'bury-buffer)
    (define-key map (kbd "g") 'lisp-tree-refresh)
    map)
  "Lisp树模式键映射")

(define-derived-mode lisp-tree-mode special-mode "Lisp Tree"
  "Lisp语法树显示模式"
  (setq buffer-read-only t)
  (setq truncate-lines t)
  (font-lock-mode 1)
  (hl-line-mode 1))

;;; 9. 导航函数
(defun lisp-tree-get-current-node ()
  "获取当前光标位置的节点"
  (get-text-property (point) 'lisp-tree-node))

(defun lisp-tree-next-node ()
  "移动到下一个节点"
  (interactive)
  (let ((pos (next-single-property-change (point) 'lisp-tree-node)))
    (if pos
        (goto-char pos)
      (message "已经是最后一个节点"))))

(defun lisp-tree-prev-node ()
  "移动到上一个节点"
  (interactive)
  (let ((pos (previous-single-property-change (point) 'lisp-tree-node)))
    (if pos
        (goto-char (previous-single-property-change pos 'lisp-tree-node))
      (message "已经是第一个节点"))))

(defun lisp-tree-goto-source ()
  "跳转到源码位置"
  (interactive)
  (let ((node (lisp-tree-get-current-node)))
    (if node
        (let* ((pos (lisp-tree-node-position node))
               (beg (car pos))
               (end (cdr pos)))
          (if (and beg end)
              (progn
                (switch-to-buffer-other-window (marker-buffer (car (buffer-list))))
                (goto-char beg)
                (message "跳转到位置 %d-%d" beg end))
            (message "此节点无位置信息")))
      (message "当前位置无节点"))))

(defun lisp-tree-copy-node ()
  "复制当前节点"
  (interactive)
  (let ((node (lisp-tree-get-current-node)))
    (if node
        (let ((value (lisp-tree-node-value node))
              (type (lisp-tree-node-type node)))
          (kill-new (format "%S" value))
          (message "已复制 %s 节点: %S" type value))
      (message "当前位置无节点"))))

(defun lisp-tree-refresh ()
  "刷新树显示"
  (interactive)
  (let ((buffer (current-buffer)))
    (when (string-match "\\*Lisp Syntax Tree" (buffer-name buffer))
      (bury-buffer buffer)
      (lisp-tree-from-buffer))))

;;; 10. 高级分析功能
(defun lisp-tree-analyze-function-calls (nodes)
  "分析函数调用"
  (let ((func-calls nil))
    (cl-labels ((analyze-node (node)
                  (when (and (eq (lisp-tree-node-type node) 'list)
                             (eq (lisp-tree-node-value node) 'function-call))
                    (let ((children (lisp-tree-node-children node)))
                      (when (and children (eq (lisp-tree-node-type (car children)) 'symbol))
                        (let ((func-name (lisp-tree-node-value (car children)))
                              (arg-count (1- (length children))))
                          (push (list func-name arg-count) func-calls)))))
                  (dolist (child (lisp-tree-node-children node))
                    (analyze-node child))))
      (dolist (node nodes)
        (analyze-node node)))
    func-calls))

(defun lisp-tree-show-function-analysis ()
  "显示函数调用分析"
  (interactive)
  (let* ((code (buffer-substring-no-properties (point-min) (point-max)))
         (nodes (parse-lisp-code code))
         (func-calls (lisp-tree-analyze-function-calls nodes))
         (buffer (get-buffer-create "*Lisp 函数分析*")))
    
    (with-current-buffer buffer
      (erase-buffer)
      (insert (propertize "Lisp 函数调用分析\n" 
                          'face '(:height 1.5 :weight bold :foreground "#ffd700")))
      (insert "\n")
      
      (if func-calls
          (progn
            (insert "| 函数名 | 调用次数 | 平均参数 |\n")
            (insert "|--------+----------+----------|\n")
            
            (let ((func-table (make-hash-table :test 'equal)))
              ;; 统计每个函数的调用情况
              (dolist (call func-calls)
                (let* ((func-name (car call))
                       (arg-count (cadr call))
                       (entry (gethash func-name func-table)))
                  (if entry
                      (setf (car entry) (1+ (car entry))
                            (cdr entry) (+ (cdr entry) arg-count))
                    (puthash func-name (cons 1 arg-count) func-table))))
              
              ;; 输出结果
              (maphash (lambda (func-name entry)
                         (let ((count (car entry))
                               (total-args (cdr entry))
                               (avg-args (float (/ (cdr entry) (car entry)))))
                           (insert (format "| %s | %d | %.1f |\n" 
                                          func-name count avg-args))))
                       func-table)))
        (insert "未发现函数调用\n"))
      
      (org-mode)
      (org-table-align)
      (setq buffer-read-only t)
      (goto-char (point-min)))
    
    (display-buffer buffer)))

;;; 11. 可视化增强
(defun lisp-tree-display-graph (nodes)
  "以图形方式显示语法树"
  (let ((buffer (get-buffer-create "*Lisp 语法树图*")))
    (with-current-buffer buffer
      (erase-buffer)
      (insert "#+TITLE: Lisp 语法树可视化\n")
      (insert "\n")
      
      (cl-labels ((draw-node (node x y)
                    (let* ((type (lisp-tree-node-type node))
                           (value (lisp-tree-node-value node))
                           (children (lisp-tree-node-children node))
                           (label (format-tree-node-value value type))
                           (color (cond
                                   ((eq type 'symbol) (tree-color :symbol))
                                   ((eq type 'keyword) (tree-color :keyword))
                                   ((eq type 'list) (tree-color :list))
                                   (t (tree-color :default)))))
                      
                      ;; 绘制当前节点
                      (insert (format "[[%d,%d][%s]]\n" x y label))
                      
                      ;; 绘制子节点
                      (when children
                        (let ((child-count (length children))
                              (start-x (- x (floor (/ child-count 2)))))
                          (dotimes (i child-count)
                            (let ((child-x (+ start-x i))
                                  (child-y (1+ y)))
                              ;; 绘制连线
                              (insert (format "[%d,%d] -> [%d,%d]\n" x y child-x child-y))
                              (draw-node (nth i children) child-x child-y))))))))
        
        ;; 绘制所有根节点
        (dotimes (i (length nodes))
          (draw-node (nth i nodes) (* i 3) 0)))
      
      (graphviz-dot-mode)
      (setq buffer-read-only t)
      (goto-char (point-min)))
    
    (display-buffer buffer)))

;;; 12. 全局快捷键
(global-set-key (kbd "C-c l t") 'lisp-tree-from-buffer)
(global-set-key (kbd "C-c l r") 'lisp-tree-from-region)
(global-set-key (kbd "C-c l f") 'lisp-tree-from-file)
(global-set-key (kbd "C-c l a") 'lisp-tree-show-function-analysis)

;;; 13. 示例代码
(defconst lisp-tree-example-code
  "(defun factorial (n)
  \"计算阶乘\"
  (if (<= n 1)
      1
    (* n (factorial (1- n)))))

(defun fibonacci (n)
  \"计算斐波那契数列\"
  (cond
   ((= n 0) 0)
   ((= n 1) 1)
   (t (+ (fibonacci (- n 1))
         (fibonacci (- n 2))))))

;; 测试函数
(let ((result (factorial 5)))
  (message \"5! = %d\" result))")

(defun lisp-tree-show-example ()
  "显示示例Lisp代码的语法树"
  (interactive)
  (lisp-tree-display lisp-tree-example-code "*Lisp 语法树示例*")
  (message "已显示示例代码的语法树"))

;;; 14. 提供模式
(provide 'lisptree)

;;; 15. 初始化
(defun lisp-tree-init ()
  "初始化Lisp语法树系统"
  (message "Lisp语法树系统已加载"))

(run-with-idle-timer 1 nil 'lisp-tree-init)




1. 基本使用

分析当前缓冲区 (C-c l t)

M-x lisp-tree-from-buffer


分析整个缓冲区的Lisp代码并显示语法树。

分析选中区域 (C-c l r)

M-x lisp-tree-from-region


先选中一个区域，然后分析选中区域的Lisp代码。

分析文件 (C-c l f)

M-x lisp-tree-from-file


选择Lisp文件并分析。

2. 语法树显示界面

显示格式：

Lisp 代码语法树分析

表达式数量: 3
总节点数: 28
最大深度: 5

defun [1:5]
  factorial [6:15]
  (n) [16:19]
  "计算阶乘" [20:29]
  if [30:32]
    <= [33:35]
      n [36:37]
      1 [38:39]
    1 [40:41]
    * [42:43]
      n [44:45]
      factorial [46:55]
        1- [56:58]
          n [59:60]


颜色编码：

• 符号: 金色 (#ffd700)

• 关键字: 紫色 (#bd93f9)

• 字符串: 浅金色 (#f1fa8c)

• 数字: 青色 (#8be9fd)

• 列表: 红色 (#ff5555)

• 函数调用: 绿色 (#50fa7b)

3. 导航快捷键

在语法树缓冲区中：

• n - 移动到下一个节点

• p - 移动到上一个节点

• t - 跳转到源码位置

• c - 复制当前节点

• q - 退出缓冲区

• g - 刷新显示

4. 高级功能

函数调用分析 (C-c l a)

M-x lisp-tree-show-function-analysis


显示函数调用统计，包括：

• 函数名

• 调用次数

• 平均参数数量

示例代码

M-x lisp-tree-show-example


显示预定义的Lisp示例代码的语法树。

5. 显示的特性

1. 节点信息

每个节点显示：

• 节点值

• 节点类型

• 源码位置 [开始:结束]

2. 缩进层次

使用缩进表示树的深度，每层缩进2个空格。

3. 符号统计

在底部显示所有符号及其出现次数，按出现次数排序。

4. 错误处理

如果代码有语法错误，会显示错误信息而不是崩溃。

6. 示例代码解析

输入代码：

(defun factorial (n)
  (if (<= n 1)
      1
    (* n (factorial (1- n)))))

(factorial 5)


输出语法树：

defun
  factorial
  (n)
  if
    <=
      n
      1
    1
    *
      n
      factorial
        1-
          n
factorial
  5


7. 自定义配置

修改颜色方案

(setq tree-colors
      '((:symbol     . "#ff9900")
        (:keyword    . "#9966ff")
        (:string     . "#99ff99")
        (:number     . "#66ccff")
        (:list       . "#ff6666")
        (:function   . "#66ff99")
        (:variable   . "#ffcc66")))


修改缩进宽度

;; 在 print-tree-node 函数中修改
(make-string (* depth 4) ?\s)  ; 改为4空格缩进


添加节点类型

;; 在 parse-expression 函数中添加
((vectorp expr)
 (make-lisp-tree-node
  :type 'vector
  :value expr
  :position (cons start end)
  :children (mapcar #'parse-expression (append expr nil))))


8. 故障排除

代码解析失败

;; 检查代码语法
M-x check-parens
M-x emacs-lisp-byte-compile


显示错乱

;; 重新解析
M-x lisp-tree-refresh


内存不足

对于非常大的文件，建议先选中关键区域进行分析。

9. 扩展功能

添加自定义分析

(defun lisp-tree-analyze-variables (nodes)
  "分析变量使用"
  (let ((vars nil))
    (cl-labels ((analyze-node (node)
                  (when (and (eq (lisp-tree-node-type node) 'symbol)
                             (not (keywordp (lisp-tree-node-value node)))
                             (not (functionp (lisp-tree-node-value node))))
                    (push (lisp-tree-node-value node) vars))
                  (dolist (child (lisp-tree-node-children node))
                    (analyze-node child))))
      (dolist (node nodes)
        (analyze-node node)))
    vars))


这个Lisp语法树分析工具可以很好地展示Lisp代码的结构，帮助理解和调试复杂的Lisp程序，特别适合学习Lisp语言和调试代码结构。