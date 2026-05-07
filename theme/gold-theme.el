;;; gold-theme.el --- A luxurious dark theme with gold accents

;; Author: yujian mrsilver
;; Version: 1.0
;; URL: https://github.com/mrssilver/gold-theme
;; Package-Requires: ((emacs "24.1"))

;;; Commentary:
;; A rich dark theme featuring:
;;   - Night black background (#0a0a0a)
;;   - Milky white foreground (#f8f8f2)
;;   - Gold accents (#ffd700, #f1fa8c)
;;   - Blood red highlights (#ff5555)
;;   - Auxiliary purple (#bd93f9)

;;; Code:

(deftheme gold
  "A luxurious dark theme with gold accents and purple auxiliary colors")

(let ((class '((class color) (min-colors 89)))
      ;; Base colors
      (night-bg      "#0a0a00")
      (night-bg-alt  "#1a1a1a")
      (milky-fg      "#f9f8f2")
      (milky-fg-alt  "#e2e2dc")

      ;; Accent colors
      (gold-primary  "#ffc900")
      (gold-secondary "#fede00")
      (blood-red     "#cc0000")
      (aux-purple    "#bd93f9")
      (aux-purple-alt "#9370DB")

      ;; Additional colors
      (cyan          "#8be9fd")
      (green         "#50fa7b")
      (orange        "#f7790c")
      (pink          "#9a1906")
      (gray          "#623211")
      (gray-light    "#55575a"))

  (custom-theme-set-faces
   'gold

   ;; ----- Basic faces -----
   `(default ((,class (:background ,night-bg :foreground ,blood-red))))
   `(cursor ((,class (:background ,blood-red))))
   `(fringe ((,class (:background ,night-bg))))
   `(highlight ((,class (:background ,gray-light))))
   `(region ((,class (:background ,pink :foreground ,night-bg))))
   `(secondary-selection ((,class (:background ,gray-light))))
   `(trailing-whitespace ((,class (:background ,blood-red))))
   `(vertical-border ((,class (:foreground ,gray-light))))



 '(corfu-bar ((t (:background "light green"))))
 '(corfu-current ((t (:extend t :background "dark red" :foreground "light green" :weight bold))))
 '(corfu-default ((t (:background "dark red" :foreground "light green"))))
 '(fill-column-indicator ((t (:foreground "#ff9900"))))
  '(match ((t (:background "dark red"))))



   ;; ----- Syntax highlighting -----
   `(font-lock-builtin-face ((,class (:foreground ,orange))))
   `(font-lock-comment-delimiter-face ((,class (:foreground ,gray))))
   `(font-lock-comment-face ((,class (:foreground ,gray :italic t))))
   `(font-lock-constant-face ((,class (:foreground ,orange))))
   `(font-lock-doc-face ((,class (:foreground ,gold-secondary))))
   `(font-lock-function-name-face ((,class (:foreground ,gold-primary :weight bold))))
   `(font-lock-keyword-face ((,class (:foreground ,gold-primary :weight bold))))
   `(font-lock-negation-char-face ((,class (:foreground ,blood-red))))
   `(font-lock-preprocessor-face ((,class (:foreground ,orange))))
   `(font-lock-regexp-grouping-backslash ((,class (:foreground ,gold-secondary))))
   `(font-lock-regexp-grouping-construct ((,class (:foreground ,gold-secondary))))
   `(font-lock-string-face ((,class (:foreground ,gold-secondary))))
   `(font-lock-type-face ((,class (:foreground ,orange))))
   `(font-lock-variable-name-face ((,class (:foreground ,milky-fg-alt))))
   `(font-lock-warning-face ((,class (:foreground ,blood-red :weight bold))))

   ;; ----- UI elements -----
   `(mode-line ((,class (:background ,night-bg-alt
                                     :foreground ,orange
                                     :box (:line-width 3 :color ,night-bg-alt)))))
   `(mode-line-inactive ((,class (:background ,night-bg
                                              :foreground ,gray
                                              :box (:line-width 3 :color ,night-bg)))))
   `(mode-line-buffer-id ((,class (:foreground ,gold-primary :weight bold))))
   `(header-line ((,class (:inherit mode-line))))

   `(minibuffer-prompt ((,class (:foreground ,gold-primary :weight bold))))
   `(link ((,class (:foreground ,cyan :underline t))))
   `(link-visited ((,class (:foreground ,pink :underline t))))
   `(button ((,class (:foreground ,cyan :underline t))))
   `(widget-field ((,class (:background ,gray-light))))
   `(custom-button ((,class (:background ,night-bg-alt :foreground ,milky-fg))))
   `(custom-button-mouse ((,class (:background ,gray-light :foreground ,milky-fg))))
   `(custom-button-pressed ((,class (:background ,blood-red :foreground ,milky-fg))))

   `(isearch ((,class (:background ,gold-primary :foreground ,night-bg))))
   `(isearch-fail ((,class (:background ,blood-red :foreground ,milky-fg))))
   `(lazy-highlight ((,class (:background ,gold-secondary :foreground ,night-bg))))

   `(show-paren-match ((,class (:background ,orange :foreground ,night-bg))))
   `(show-paren-mismatch ((,class (:background ,blood-red :foreground ,milky-fg))))

   ;; ----- Line numbers -----
   `(line-number ((,class (:foreground ,gold-primary))))
   `(line-number-current-line ((,class (:foreground ,gold-primary :weight bold))))

   ;; ----- Current line highlight -----
   `(hl-line ((,class (:background ,night-bg-alt :underline ,blood-red))))

   ;; ----- Org-mode -----
   `(org-document-title ((,class (:foreground ,gold-primary :height 1.5 :weight bold))))
   `(org-level-1 ((,class (:foreground ,gold-primary :height 1.3 :weight bold))))
   `(org-level-2 ((,class (:foreground ,gold-secondary :height 1.2 :weight bold))))
   `(org-level-3 ((,class (:foreground ,orange :height 1.1))))
   `(org-level-4 ((,class (:foreground ,cyan))))
   `(org-date ((,class (:foreground ,pink :underline t))))
   `(org-code ((,class (:foreground ,gold-secondary))))
   `(org-verbatim ((,class (:foreground ,gold-secondary))))
   `(org-todo ((,class (:foreground ,blood-red :weight bold))))
   `(org-done ((,class (:foreground ,green :weight bold))))
   `(org-special-keyword ((,class (:foreground ,gray))))
   `(org-block ((,class (:background ,night-bg-alt))))
   `(org-block-begin-line ((,class (:background ,night-bg-alt :foreground ,gray))))
   `(org-block-end-line ((,class (:background ,night-bg-alt :foreground ,gray))))
   `(org-quote ((,class (:inherit org-block :slant italic))))
   `(org-verse ((,class (:inherit org-block :slant italic))))

   ;; ----- Company -----
   `(company-tooltip ((,class (:background ,night-bg-alt :foreground ,milky-fg))))
   `(company-tooltip-common ((,class (:foreground ,gold-primary))))
   `(company-tooltip-selection ((,class (:background ,gray-light))))
   `(company-tooltip-annotation ((,class (:foreground ,gray))))
   `(company-scrollbar-bg ((,class (:background ,night-bg))))
   `(company-scrollbar-fg ((,class (:background ,orange))))
   `(company-preview ((,class (:background ,blood-red :foreground ,milky-fg))))
   `(company-preview-common ((,class (:background ,blood-red :foreground ,gold-primary))))

   ;; ----- Ivy -----
   `(ivy-current-match ((,class (:background ,orange :foreground ,night-bg))))
   `(ivy-minibuffer-match-face-1 ((,class (:foreground ,gray))))
   `(ivy-minibuffer-match-face-2 ((,class (:foreground ,gold-primary :weight bold))))
   `(ivy-minibuffer-match-face-3 ((,class (:foreground ,gold-secondary :weight bold))))
   `(ivy-minibuffer-match-face-4 ((,class (:foreground ,orange :weight bold))))
   `(ivy-virtual ((,class (:foreground ,gray))))

   ;; ----- Helm -----
   `(helm-source-header ((,class (:background ,night-bg-alt :foreground ,gold-primary :weight bold :height 1.2))))
   `(helm-selection ((,class (:background ,orange :foreground ,night-bg))))
   `(helm-match ((,class (:foreground ,gold-primary :weight bold))))
   `(helm-candidate-number ((,class (:background ,night-bg-alt :foreground ,milky-fg))))
   `(helm-ff-directory ((,class (:foreground ,orange :weight bold))))
   `(helm-ff-file ((,class (:foreground ,milky-fg))))
   `(helm-ff-executable ((,class (:foreground ,green))))
   `(helm-ff-invalid-symlink ((,class (:foreground ,blood-red))))
   `(helm-ff-symlink ((,class (:foreground ,gold-primary))))
   `(helm-ff-prefix ((,class (:foreground ,blood-red))))

   ;; ----- Error/Warning -----
   `(error ((,class (:foreground ,blood-red :weight bold))))
   `(warning ((,class (:foreground ,orange :weight bold))))
   `(success ((,class (:foreground ,green :weight bold))))

   ;; ----- Diff -----
   `(diff-added ((,class (:foreground ,green))))
   `(diff-changed ((,class (:foreground ,gold-primary))))
   `(diff-removed ((,class (:foreground ,blood-red))))
   `(diff-header ((,class (:background ,night-bg-alt))))
   `(diff-file-header ((,class (:background ,night-bg-alt :foreground ,gold-primary :weight bold))))
   `(diff-hunk-header ((,class (:background ,night-bg-alt :foreground ,orange))))

   ;; ----- Magit -----
   `(magit-section-heading ((,class (:foreground ,gold-primary :weight bold))))
   `(magit-branch-local ((,class (:foreground ,cyan))))
   `(magit-branch-remote ((,class (:foreground ,green))))
   `(magit-tag ((,class (:foreground ,gold-secondary))))
   `(magit-hash ((,class (:foreground ,gray))))
   `(magit-diff-added ((,class (:foreground ,green))))
   `(magit-diff-added-highlight ((,class (:background ,night-bg-alt :foreground ,green))))
   `(magit-diff-removed ((,class (:foreground ,blood-red))))
   `(magit-diff-removed-highlight ((,class (:background ,night-bg-alt :foreground ,blood-red))))
   `(magit-diff-context ((,class (:foreground ,milky-fg))))
   `(magit-diff-context-highlight ((,class (:background ,night-bg-alt))))
   `(magit-diff-hunk-heading ((,class (:background ,gray-light :foreground ,milky-fg))))
   `(magit-diff-hunk-heading-highlight ((,class (:background ,gray :foreground ,milky-fg))))
   `(magit-diff-lines-heading ((,class (:background ,blood-red :foreground ,milky-fg))))

   ;; ----- Terminal -----
   `(term-color-black ((,class (:background ,night-bg :foreground ,night-bg))))
   `(term-color-red ((,class (:background ,blood-red :foreground ,blood-red))))
   `(term-color-green ((,class (:background ,green :foreground ,green))))
   `(term-color-yellow ((,class (:background ,gold-primary :foreground ,gold-primary))))
   `(term-color-blue ((,class (:background ,orange :foreground ,orange))))
   `(term-color-magenta ((,class (:background ,pink :foreground ,pink))))
   `(term-color-cyan ((,class (:background ,cyan :foreground ,cyan))))
   `(term-color-white ((,class (:background ,milky-fg :foreground ,milky-fg))))

   ;; ----- Others -----
   `(rainbow-delimiters-depth-1-face ((,class (:foreground ,gold-primary))))
   `(rainbow-delimiters-depth-2-face ((,class (:foreground ,orange))))
   `(rainbow-delimiters-depth-3-face ((,class (:foreground ,cyan))))
   `(rainbow-delimiters-depth-4-face ((,class (:foreground ,green))))
   `(rainbow-delimiters-depth-5-face ((,class (:foreground ,pink))))
   `(rainbow-delimiters-depth-6-face ((,class (:foreground ,gold-secondary))))
   `(rainbow-delimiters-depth-7-face ((,class (:foreground ,blood-red))))
   `(rainbow-delimiters-depth-8-face ((,class (:foreground ,orange))))
   `(rainbow-delimiters-depth-9-face ((,class (:foreground ,gray))))

   `(highlight-indentation-face ((,class (:background ,night-bg-alt))))
   `(highlight-indentation-current-column-face ((,class (:background ,gray-light))))

   `(whitespace-space ((,class (:foreground ,gray))))
   `(whitespace-tab ((,class (:foreground ,gray))))
   `(whitespace-newline ((,class (:foreground ,gray))))
   `(whitespace-trailing ((,class (:background ,blood-red :foreground ,milky-fg))))

   `(eshell-prompt ((,class (:foreground ,gold-primary :weight bold))))
   `(eshell-ls-directory ((,class (:foreground ,orange :weight bold))))
   `(eshell-ls-executable ((,class (:foreground ,green))))
   `(eshell-ls-symlink ((,class (:foreground ,gold-primary))))
   `(eshell-ls-backup ((,class (:foreground ,gray))))
   `(eshell-ls-product ((,class (:foreground ,gray))))
   `(eshell-ls-archive ((,class (:foreground ,orange))))
   `(eshell-ls-missing ((,class (:foreground ,blood-red))))
   `(eshell-ls-special ((,class (:foreground ,pink))))
   `(eshell-ls-readonly ((,class (:foreground ,gray))))
   `(eshell-ls-unreadable ((,class (:foreground ,gray))))
   `(eshell-ls-clutter ((,class (:foreground ,gray))))

   `(flycheck-error ((,class (:underline (:style wave :color ,blood-red)))))
   `(flycheck-warning ((,class (:underline (:style wave :color ,orange)))))
   `(flycheck-info ((,class (:underline (:style wave :color ,cyan)))))
   `(flyspell-incorrect ((,class (:underline (:style wave :color ,blood-red)))))
   `(flyspell-duplicate ((,class (:underline (:style wave :color ,orange)))))

   `(ansi-color-bold ((,class (:weight bold))))
   `(ansi-color-italic ((,class (:slant italic))))
   `(ansi-color-bright-white ((,class (:foreground ,milky-fg))))
   `(ansi-color-bright-red ((,class (:foreground ,blood-red))))
   `(ansi-color-bright-green ((,class (:foreground ,green))))
   `(ansi-color-bright-yellow ((,class (:foreground ,gold-primary))))
   `(ansi-color-bright-blue ((,class (:foreground ,orange))))
   `(ansi-color-bright-magenta ((,class (:foreground ,pink))))
   `(ansi-color-bright-cyan ((,class (:foreground ,cyan))))
   `(ansi-color-bright-black ((,class (:foreground ,gray))))
   ))



(setq-default cursor-type 'hbar);; t nil box hollow bar hbar
;;(set-cursor-color (gold-color :blood-red))
(blink-cursor-mode 0)
(setq blink-cursor-blinks 0)
;;(setq blink-cursor-interval 0.5)

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'gold)
;;(provide 'gold-theme)

;;; gold-theme.el ends here
