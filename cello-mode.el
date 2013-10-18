;;; libcello-mode.el --- Minor mode for libcello syntax
;; 
;; Filename: libcello-mode.el
;; Description: Minor mode for extending C syntax highlighting to support libcello's fancy syntax
;; Author: Jordon Biondo <biondoj@mail.gvsu.edu>
;; Created: Sat Sep 14 21:39:32 2013 (-0400)
;; Version: 0.1.1
;; Package-Requires: ()
;; Last-Updated: Fri Oct 18 14:42:49 2013 (-0400)
;;           By: Jordon Biondo
;;     Update #: 8
;; URL: http://github.com/jordonbiondo/libcello-mode.git
;; Keywords: c, languages, tools, libcello
;; Compatibility: Emacs 24.x
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Commentary: 
;; Minor mode for extending C syntax highlighting to support libcello's fancy syntax
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(defvar libcello/use-active-smart-enable t
  "Non-nil mean that libcello-mode will actively scan cc-mode buffers for libcello \
#include's or syntax and automatically activate `libcello-mode'.")

(defconst libcello-font-lock-keywords
  `(("\\(\\$\\)\\( *( *\\)\\(\[A-Z][A-Za-z_0-9]*\\)"
      (1 font-lock-constant-face)
      (3 font-lock-type-face))
    ("\\(\\new\\)\\( *( *\\)\\(\[A-Z][A-Za-z_0-9]*\\)"
     (1 font-lock-builtin-face)
     (3 font-lock-type-face))
    ("\\(\\lambda\\)\\( *( *\\)\\(\[a-zA-Z_][A-Za-z_0-9]*\\)"
     (1 font-lock-keyword-face)
     (3 font-lock-function-name-face))
    ("\\([A-Za-z_][A-Za-z0-9_]* +\\)\\(in +\\)\\([A-Za-z_][A-Za-z0-9_]* *\\)"
     (1 font-lock-variable-name-face)
     (2 font-lock-keyword-face)
     (3 font-lock-variable-name-face))
    ;; keywords
    (,(regexp-opt (list "var" "is" "with" "not" "and" "or" "foreach" "try" "catch" "throw" "if_eq" 
			"if_neq" "if_gt" "if_lt" "if_ge" "if_le" "as" "local" "global" "in"
			"va_list*" "var*" "va_list"  "volatile" "module" "class" "data" 
			"instance" "methods" "methods_begin" "method" "methods_end" "defined" 
			"lambda" "lambda_id" "lambda_const" "lambda_compose" "lambda_flip" 
			"lambda_partial" "lambda_partial_l" "lambda_partial_r" "lambda_void" 
			"lambda_uncurry" "lambda_void_uncurry" "lambda_pipe" "lambda_method_pipe" )
		  'words) . font-lock-keyword-face)
    (,(regexp-opt (list "True" "False" "None" )
		  'words) . font-lock-constant-face)
    ;; libcello functions
    (,(regexp-opt (list "lit" "cast" "delete" "allocate" "deallocate" "construct" 
			"destruct" "assign" "copy" "eq" "neq" "gt" "lt" "ge" "le" "len" "clear" 
			"contains" "discard" "is_empty" "sort" "maximum" "minimum" "reverse" 
			"iter_start" "iter_end" "iter_next" "hash" "push" "push_at" "push_back" 
			"push_front" "pop" "pop_at" "pop_back" "pop_front" "at" "set" "get" "put" 
			"as_char" "as_str" "as_long" "as_double" "enter_with" "exit_with" "open" 
			"close" "seek" "tell" "flush" "eof" "read" "write" "parse_read" "parse_write" 
			"type_class" "type_implements" "type_of" "add" "sub" "mul" "divide" "negate" 
			"absolute" "map" "new_map" "new_filter" "new_foldl" "new_foldr" "new_sum" 
			"new_product" "call_with" "call" "call_with_ptr" "release" "retain" "assert" 
			"format_to" "format_from" "format_to_va" "format_from_va" "show" "show_to" 
			"print" "print_to" "print_va" "print_to_va" "look" "look_from" "scan" 
			"scan_from" "scan_va" "scan_from_va" "println" "scanln" "current" "join" 
			"terminate" "lock" "unlock" "lock_try" "New" "Assign" "Copy" "Eq" "Ord" 
			"Hash" "Serialize" "AsLong" "AsDouble" "AsStr" "AsChar" "Num" "Collection" 
			"Reverse" "Iter" "Push" "At" "Dict" "With" "Stream" "Call" "Retain" "Sort" 
			"Append" "Show" "Format" "Process" "Lock") 
		  'words) . font-lock-builtin-face))
  "A list of Cello keywords.")

(define-minor-mode libcello-mode
  "Minor mode to extend font-lock highlighting for C mode for libcello's special syntax elements. 

To enable for all c-mode buffers:
  (add-hook 'c-mode-hook 'libcello-mode)

`libcello-mode' can be automatically activated on files that
use libcello by setting `libcello/use-active-smart-enable' to a non-nil value.
  (setq cello/use-active-smart-enable t)"
  :init-value nil
  :lighter "cello"
  :keymap nil
  :global nil
  (if libcello-mode
      (font-lock-add-keywords nil cello-font-lock-keywords)
    (font-lock-remove-keywords nil cello-font-lock-keywords))
  (font-lock-fontify-buffer))


(defun libcello/buffer-might-be-using-libcello()
  "Returns true if there is a good chance the current buffer is using libCello."
  (interactive)
  (and (member major-mode '(c-mode c++-mode))
       (save-excursion
         (goto-char (point-min))
         (search-forward-regexp
          "\\(\\(^ *#include +\"Cello.h\" *$\\)\\|\\(\\(\\lambda\\)\\( *( *\\)\\(\[a-zA-Z_][A-Za-z_0-9]*\\)\\)\\|\\(\\(\\new\\)\\( *( *\\)\\(\[A-Z][A-Za-z_0-9]*\\)\\)\\|\\(\\(\\$\\)\\( *( *\\)\\(\[A-Z][A-Za-z_0-9]*\\)\\)\\)"
          nil t))))


(defun libcello/smart-enable()
  "If `libcello-mode' in the current `c-mode' or `c++-mode' buffer then look at the \
file's syntax, if libcello elements are found, enable the `libcello-mode'"
  (interactive)
  (unless libcello-mode (when (cello/buffer-might-be-using-libcello) (libcello-mode t))))


(defadvice c-after-change (after check-for-libcello activate)
  "If `cello/use-active-smart-enable' is non-nil, run `cello/smart-enable' after changes are made."
  (when libcello/use-active-smart-enable (libcello/smart-enable)))
    
  
(ad-unadvise 'c-after-change)
  
			       
			       
			       
	
			       
	 
(provide 'cello-mode)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; cello-mode.el ends here
  
