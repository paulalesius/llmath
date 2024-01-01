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

(defun export-org-to-md-in-same-dir ()
  "Export all org files in the same directory as this script and subdirectories to Markdown."
  (let ((src-dir (file-name-directory load-file-name)))
    (dolist (file (find-org-files src-dir))
      (export-org-to-md file))))

(export-org-to-md-in-same-dir)
