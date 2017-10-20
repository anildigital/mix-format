;;; mix-format.el --- Emacs plugin to mix format Elixir files

;; Copyright (C) 2017 Anil Wadghule

;; Author: Anil Wadghule <anildigital@gmail.com>
;; URL: https://github.com/anildigital/mix-format

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;;; Commentary:

;; The mix-format function formats the elixir files with Elixir's `mix format`
;; command

;; e.g.
;;
;; (require 'mix-format)
;; M-x mix-format
;;

(defcustom mixfmt-elixir "elixir"
  "Path to the Elixir interpreter."
  :type 'string
  :group 'mix-format)

(defcustom mixfmt-mix "/usr/bin/mix"
  "Path to the 'mix' executable."
  :type 'string
  :group 'mix-format)

;;; Code
(defun mix-format (&optional is-interactive)
  (interactive "p")

  (unwind-protect
      (let* (
             (in-file (make-temp-file "mix-format"))
             (out-file (make-temp-file "mix-format"))
             (err-file (make-temp-file "mix-format"))
             (contents (buffer-substring-no-properties (point-min) (point-max)))
             (_ (with-temp-file in-file (insert contents))))


        (let* ((command mixfmt-elixir)
               (error-buffer (get-buffer-create "*mix-format errors*"))
               (retcode (with-temp-buffer
                          (call-process command
                                        nil (list out-file err-file)
                                        nil
                                        mixfmt-mix
                                        "format"
                                        "--print"
                                        in-file))))

          (with-current-buffer error-buffer
            (read-only-mode 0)
            (insert-file-contents err-file nil nil nil t)
            (ansi-color-apply-on-region (point-min) (point-max))
            (special-mode))

          (if (zerop retcode )
              (let ((p (point)))
                (save-excursion
                  (erase-buffer)
                  (insert-buffer-substring out-file)
                  (message "mix format applied"))
                (goto-char p))

            (if is-interactive
                (display-buffer error-buffer)
              (message "mix-format failed: see %s" (buffer-name error-buffer)))
            ))
        (delete-file in-file)
        (delete-file err-file)
        (delete-file out-file))))

(provide 'mix-format)

;;; mix-format.el ends here
