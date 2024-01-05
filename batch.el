;;; batch.el --- Description -*- lexical-binding: t; -*-
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

(require 'org)
(require 'ox-md)

(defun find-org-files (dir)
  "Recursively find .org files in DIR."
  (let (org-files)
    (dolist (file (directory-files dir t "\\`[^.]"))
      (cond
       ((file-directory-p file)
        (setq org-files (append org-files (find-org-files file))))
       ((string-match "\\.org$" file)
        (push file org-files))))
    org-files))

(defun my-md-export-latex-fragments (latex-fragment backend info)
  "Convert LaTeX fragments to mdbook compatible delimiters."
  (when (org-export-derived-backend-p backend 'md)
    (let* ((is-block (and (string-prefix-p "$$\n" latex-fragment)
                          (string-suffix-p "\n$$" latex-fragment))))
      (if is-block
          (concat "\\\\[" (substring (substring latex-fragment 3) 0 -3) "\\\\]")
        (concat "\\\\(" (substring (substring latex-fragment 1) 0 -1) "\\\\)")))))

(add-to-list 'org-export-filter-latex-fragment-functions
             'my-md-export-latex-fragments)

(defun export-org-to-md (file)
  "Export an org FILE to Markdown."
  (with-current-buffer (find-file-noselect file)
    (org-md-export-to-markdown)))

(defun export-src ()
  "Export all org files in the same directory as this script and subdirectories to Markdown."
  (let* ((project-dir (file-name-directory load-file-name))
         (src-dir (expand-file-name "src" project-dir)))
    (dolist (file (find-org-files src-dir))
      (export-org-to-md file))))

(defun generate-toc ()
  "Generate the table of contents."
  (let* ((project-dir (file-name-directory load-file-name))
         (toc-template-path (expand-file-name "TOC.tpl" project-dir))
         (summary-org-path (expand-file-name "src/SUMMARY.org" project-dir))
         (toc-lines (with-temp-buffer
                      (insert-file-contents toc-template-path)
                      (split-string (buffer-string) "\n" t)))
         toc-items)
    (with-temp-file summary-org-path
      ;; Inserting a headline creates a TOC in the Org export to Markdown, which
      ;; makes the resulting SUMMARY.md incompatible with mdbook.
      ;;(insert "* Summary\n")
      (dolist (line toc-lines)
        (let* ((items (split-string line ":"))
               (item-len (1- (length items)))
               (pagename (car (last items)))
               (pagepath-org (concat (string-join items "/") ".org"))
               (exists (file-exists-p (concat "src/" pagepath-org)))
               (todo (if exists "" " #TODO"))
               (formatted (format "[[file:%s][%s%s]]" pagepath-org pagename todo))
               (indent (make-string item-len ?\t)))
          (insert (format "%s- %s\n" indent formatted)))))))

(defun main ()
  (let* ((args command-line-args-left)
         (run-toc (or (member "toc" args) (null args)))
         (run-md (or (member "md" args) (null args))))
    (when run-toc
      (message "Generating TOC")
      (generate-toc))
    (when run-md
      (message "Exporting Org to Markdown")
      (export-src))))

(main)

;;; batch.el ends here
