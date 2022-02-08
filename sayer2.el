;; SEE ALSO /var/lib/myfrdcsa/codebases/internal/kmax/frdcsa/emacs/kmax-command-log-mode/kmax-command-log-mode.el

;; use advice to wrap around functions to memoize their args and
;; results, store to sayer2

(setq sayer2-invocation-counter 0)
(setq sayer2-invocation-counter-per-function 0)

(defadvice sayer2-test-function-concat
 (around sayer2-test-function-concat-around (item1 item2))
 ""
 ;; assert the args to sayer2 perl code, for now just assert to kbs2
 (let ((item1 (concat item1 "ohh")))
  (message (prin1-to-string (list item1 item2)))
  (message (prin1-to-string ad-do-it))
  (setq sayer2-invocation-counter-per-function
   (1+ sayer2-invocation-counter-per-function))))

(defun sayer2-test-function-concat (item1 item2)
 (concat item1 item2))

;; (ad-unadvise 'sayer2-test-function-concat)

;; (ad-add-advice 
;;  'sayer2-test-function-concat 
;;  (ad-make-advice
;;   'sayer2-test-function-concat-around nil t
;;   '(advice
;;     lambda ()
;;     (ad-set-arg 0 (concat (ad-get-arg 0) "ohh "))
;;     (message (prin1-to-string (list (ad-get-arg 0) (ad-get-arg 1))))
;;     (message (prin1-to-string ad-do-it))
;;     (setq sayer2-invocation-counter-per-function
;;      (1+ sayer2-invocation-counter-per-function))))
;;  'around 'first)

;; (ad-activate 'sayer2-test-function-concat nil)

;; (ad-deactivate 'sayer2-test-function-concat)

;; (sayer2-test-function-concat "hi " "there")

(defun sayer2-test-function-concat-2 (item1 item2)
 (concat item1 item2))

(defun his-tracing-function (orig-fun &rest args)
 (message "display-buffer called with args %S" args)
 (let ((res (apply orig-fun args)))
  (message "display-buffer returned %S" res)
  res))

(if nil
 (progn

  (sayer2-test-function-concat-2 "hi " "there")

  (advice-add 'sayer2-test-function-concat-2 :around #'his-tracing-function)

  (sayer2-test-function-concat-2 "hi " "there")

  (advice-remove 'sayer2-test-function-concat-2 #'sayer2-test-function-concat-2-around)

  (sayer2-test-function-concat-2 "hi " "there")
  
  ;; this fails because interactive is a special form
  (advice-add 'interactive :around #'his-tracing-function)

  ))
