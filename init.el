

;; 最佳实践：双稳定源 + 备用最新源
(require 'package)
(setq package-check-signature nil)
(setq package-check-signature nil)  ;; 禁用签名验证
(setq package-archives '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))  ;; 备用

;; 设置优先从稳定源安装
(setq package-archive-priorities '(("gnu"    . 10)
                                   ("nongnu" . 9)
                                   ("melpa"  . 0)))

(package-initialize)









