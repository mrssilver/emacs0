(deftheme mrsilver
  "Created 2024-12-18.")

(custom-theme-set-variables
 'mrsilver
 '(custom-safe-themes '("603a831e0f2e466480cdc633ba37a0b1ae3c3e9a4e90183833bc4def3421a961" default))
 '(package-selected-packages '(q-mode readable-numbers evil ess slime commenter go-dlv gotest magithub go-eldoc go-guru go-errcheck ffmpeg-player esup use-package org-remark rainbow-mode auto-correct auto-dim-other-buffers python erc rainbow-delimiters popon multiple-cursors minibuffer-header minibuffer-line minibar company-statistics perl-doc preview-auto ztree pdf-tools org emacsql gited dracula-theme diminish diff-hl magit git-modes go-mode markdown-mode memory-usage))
 '(display-time-mode t)
 '(tool-bar-mode nil)
 '(connection-local-profile-alist '((eshell-connection-default-profile (eshell-path-env-list)) (tramp-adb-connection-local-default-ps-profile (tramp-process-attributes-ps-args) (tramp-process-attributes-ps-format (user . string) (pid . number) (ppid . number) (vsize . number) (rss . number) (wchan . string) (pc . string) (state . string) (args))) (tramp-adb-connection-local-default-shell-profile (shell-file-name . "/system/bin/sh") (shell-command-switch . "-c")) (tramp-connection-local-darwin-ps-profile (tramp-process-attributes-ps-args "-acxww" "-o" "pid,uid,user,gid,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" "-o" "state=abcde" "-o" "ppid,pgid,sess,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etime,pcpu,pmem,args") (tramp-process-attributes-ps-format (pid . number) (euid . number) (user . string) (egid . number) (comm . 52) (state . 5) (ppid . number) (pgrp . number) (sess . number) (ttname . string) (tpgid . number) (minflt . number) (majflt . number) (time . tramp-ps-time) (pri . number) (nice . number) (vsize . number) (rss . number) (etime . tramp-ps-time) (pcpu . number) (pmem . number) (args))) (tramp-connection-local-busybox-ps-profile (tramp-process-attributes-ps-args "-o" "pid,user,group,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" "-o" "stat=abcde" "-o" "ppid,pgid,tty,time,nice,etime,args") (tramp-process-attributes-ps-format (pid . number) (user . string) (group . string) (comm . 52) (state . 5) (ppid . number) (pgrp . number) (ttname . string) (time . tramp-ps-time) (nice . number) (etime . tramp-ps-time) (args))) (tramp-connection-local-bsd-ps-profile (tramp-process-attributes-ps-args "-acxww" "-o" "pid,euid,user,egid,egroup,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" "-o" "state,ppid,pgid,sid,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etimes,pcpu,pmem,args") (tramp-process-attributes-ps-format (pid . number) (euid . number) (user . string) (egid . number) (group . string) (comm . 52) (state . string) (ppid . number) (pgrp . number) (sess . number) (ttname . string) (tpgid . number) (minflt . number) (majflt . number) (time . tramp-ps-time) (pri . number) (nice . number) (vsize . number) (rss . number) (etime . number) (pcpu . number) (pmem . number) (args))) (tramp-connection-local-default-shell-profile (shell-file-name . "/bin/sh") (shell-command-switch . "-c")) (tramp-connection-local-default-system-profile (path-separator . ":") (null-device . "/dev/null"))))
 '(connection-local-criteria-alist '(((:application eshell) eshell-connection-default-profile) ((:application tramp :protocol "adb") tramp-adb-connection-local-default-shell-profile tramp-adb-connection-local-default-ps-profile) ((:application tramp :machine "localhost") tramp-connection-local-darwin-ps-profile) ((:application tramp :machine "macbook.local") tramp-connection-local-darwin-ps-profile) ((:application tramp) tramp-connection-local-default-system-profile tramp-connection-local-default-shell-profile))))

(custom-theme-set-faces
 'mrsilver
 '(default ((t (:inherit nil :extend nil :stipple nil :background "Black" :foreground "dark red" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight regular :height 120 :width normal :foundry "nil" :family "Menlo"))))
 '(cursor ((t (:background "DarkOrange1"))))
 '(custom-themed ((t (:background "yellow1" :foreground "dark red"))))
 '(highlight ((t (:background "red1" :foreground "light green"))))
 '(isearch ((t (:inherit match :background "gold1" :foreground "dark red" :weight extra-bold))))
 '(isearch-fail ((t (:background "black" :foreground "yellow1"))))
 '(lazy-highlight ((t (:background "yellow1" :foreground "dark red")))))

(provide-theme 'mrsilver)
