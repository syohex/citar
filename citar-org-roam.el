;;; citar-org-roam.el --- Citar org-roam integration -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Bruce D'Arcus
;;
;; Author: Bruce D'Arcus <bdarcus@gmail.com>
;; Maintainer: Bruce D'Arcus <bdarcus@gmail.com>
;; Created: May 22, 2022
;; Modified: May 22, 2022
;; Version: 0.0.1
;; Homepage: https://github.com/bdarcus/citar-org-roam
;; Package-Requires: ((emacs "27.1") (org-roam "2.0") (citar "0.9"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Provides functions and setup for 'citar' integration with 'org-roam'.
;;
;;; Code:

(require 'org-roam)
(require 'citar)

;; QUESTIONS what functions do we need here?

(defun citar-org-roam--has-note-p (key &optional _entry)
  "Return non-nil if a KEY has an associated org-roam ref note."
  ;; I'm unclear where we are at this point with preferred technical details.
  ;; This is just a super simple predicate function.
  (let ((ref-node (org-roam-node-from-ref (concat "@" key))))
    (when ref-node t)))

(defun citar-org-roam--keys-with-note ()
  "Return a list of keys with associated note(s)."
  (mapcar #'car (org-roam-db-query [:select ref :from refs])))

(defun citar-org-roam--open-note (key &optional _entry)
  "Open org-roam node for KEY."
  ;; NOTE I'm unsure what happens if there are multiple notes.
  (let ((ref-node (org-roam-node-from-ref (concat "@" key))))
    (when ref-node
      (org-roam-node-open ref-node))))

(defun citar-org-roam--create-note (key entry)
  "Create org-roam node for KEY with ENTRY."
  ;; adapted from https://jethrokuan.github.io/org-roam-guide/#orgc48eb0d
  (let ((title (citar--format-entry-no-widths
                entry "${author editor} :: ${title}")))
    (org-roam-capture- :templates
                       '(("r" "reference" plain "%?" :if-new
                          (file+head
                           (concat (car citar-notes-paths)) "/${citekey}.org" ; FIX
                                     ":PROPERTIES:
:ROAM_REFS: [cite:@${citekey}]
:END:
#+title: ${title}\n")
                          :immediate-finish t
                          :unnarrowed t))
                       :info (list :citekey key
                                   :node (org-roam-node-create :title title)
                                   :props '(:finalize find-file)))))

;; TODO should this be a minor mode, to setup the 'citar' end, and maybe 'org-roam' too?

(provide 'citar-org-roam)
;;; citar-org-roam.el ends here
