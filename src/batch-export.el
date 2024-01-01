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

(defun export-org-to-md-in-same-dir ()
  "Export all org files in the same directory as this script and subdirectories to Markdown."
  (let ((src-dir (file-name-directory load-file-name)))
    (dolist (file (find-org-files src-dir))
      (with-current-buffer (find-file-noselect file)
        (org-md-export-to-markdown)))))

(export-org-to-md-in-same-dir)
