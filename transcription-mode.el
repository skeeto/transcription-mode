;;; transcription-mode.el --- -*- lexical-binding: t; -*-

;; This is free and unencumbered software released into the public domain.

;; See the README.

;; TODO:
;; * Read status

;;; Code:

(require 'cl-lib)

(defgroup transcription-mode ()
  "Minor mode for editing transcriptions using VideoLAN."
  :group 'convenience)

(defcustom transcription-vlc-program-name "vlc"
  "Path to the VideoLAN executable"
  :group 'transcription-mode)

(defvar transcription-process nil
  "VideoLAN subprocess currently playing media.")

(defun transcription-start (file)
  "Start the transcription process with a new media file."
  (interactive "fMedia file: ")
  (cl-block :cancel
    (when (process-live-p transcription-process)
      (when (and (called-interactively-p 'interactive)
                 (not (y-or-n-p "Transcription in process. Kill it?")))
        (cl-return-from :cancel))
      (delete-process transcription-process))
    (setf transcription-process
          (start-process "vlc-transcribe" nil transcription-vlc-program-name
                          "-Irc" "--extraintf" "qt" file))
    (setf (process-get transcription-process :media-file) file)
    (transcription-play/pause)))

(defun transcription-stop ()
  "Stop the transcription process."
  (interactive)
  (kill-process transcription-process))

(defun transcription-time-filter (_ output)
  (let ((time (string-to-number
               (car (split-string output (char-to-string ?\r))))))
    (insert
     (transcription-format-time time))))

(defun transcription-format-time (time)
  (let* ((minutes (/ time 60))
         (hours   (/ minutes 60))
         (seconds (mod time 60))
         (ts (format "%02d:%02d:%02d\n" hours minutes seconds)))
    ts))

(defun transcription (&rest commands)
  "Send COMMAND to the VideoLAN subprocess."
  (if (not (processp transcription-process))
      (error "Start a media file with `transcription-start' first.")
    (unless (process-live-p transcription-process)
      (transcription-start (process-get transcription-process :media-file))))
  (with-temp-buffer
    (let ((standard-output (current-buffer)))
      (dolist (command commands)
        (if (eq command :get_time)
            (set-process-filter transcription-process
                                'transcription-time-filter)
          (set-process-filter transcription-process 'nil))
        (if (keywordp command)
            (princ (substring (symbol-name command) 1))
          (princ command))
        (princ " "))
      (princ "\n")
      (process-send-region transcription-process (point-min) (point-max)))))

(defun transcription-partial (&rest commands)
  "Return an interactive function applying COMMANDS."
  (lambda ()
    (interactive)
    (apply #'transcription commands)))

(defun transcription-play/pause ()
  "Toggle play/pause on the transcription media."
  (interactive)
  (let ((play-state (process-get transcription-process :play-state)))
    (if (eq play-state 'paused)
        (progn
          (transcription :play)
          (setf (process-get transcription-process :play-state) 'playing))
      (transcription :pause)
      (setf (process-get transcription-process :play-state) 'paused))))

(defalias 'transcription-forward-10m
  (transcription-partial :seek "+600"))

(defalias 'transcription-backward-10m
  (transcription-partial :seek "-600"))

(defalias 'transcription-forward-1m
  (transcription-partial :seek "+60"))

(defalias 'transcription-backward-1m
  (transcription-partial :seek "-60"))

(defalias 'transcription-forward-10s
  (transcription-partial :seek "+10"))

(defalias 'transcription-backward-10s
  (transcription-partial :seek "-10"))

(defalias 'transcription-forward-3s
  (transcription-partial :seek "+3"))

(defalias 'transcription-backward-3s
  (transcription-partial :seek "-3"))

(defalias 'transcription-get-time
  (transcription-partial :get_time))

(defun transcription-seek (time)
  (interactive "nSeek seconds: ")
  (transcription :seek time))

(defvar transcription-mode-map
  (let ((map (make-sparse-keymap)))
    (prog1 map
      (define-key map (kbd "C-c C-c") #'transcription-play/pause)
      (define-key map (kbd "C-c M") #'transcription-forward-1m)
      (define-key map (kbd "C-c m") #'transcription-backward-1m)
      (define-key map (kbd "C-c T") #'transcription-forward-10s)
      (define-key map (kbd "C-c t") #'transcription-backward-10s)
      (define-key map (kbd "C-c S") #'transcription-forward-3s)
      (define-key map (kbd "C-c s") #'transcription-backward-3s)
      (define-key map (kbd "C-c C-t") #'transcription-get-time)
      (define-key map (kbd "C-c C-s") #'transcription-seek)))
  "Keymap for `transcription-mode'.")

(define-minor-mode transcription-mode
  "Minor mode for editing transcriptions of audio or video media."
  :group 'transcription-mode
  :lighter " transcribe"
  :keymap transcription-mode-map)

(provide 'transcription-mode)

;;; transcription-mode.el ends here
