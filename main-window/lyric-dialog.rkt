#lang racket/gui

(require "./network/netease.rkt"
         "./network/gen.rkt")

(provide (all-defined-out))

(define lyric-dialog%
  (class object%
    (init song)

    (define song-data song)

    (define main-window
      (new dialog%
           [label "查看歌词"]))

    (define lyric-edit
      (new text-field%
         [parent main-window]
         [label #f]
         [init-value "正在加载歌词……"]
         [min-height 400]
         [min-width 300]
         [enabled #f]
         [style '(multiple vertical-label)]))

    (define bottom-layout
      (new horizontal-pane%
           [parent main-window]
           [alignment '(right center)]))

    (new button%
         [parent bottom-layout]
         [label "关闭"]
         [callback (λ (_ __) (send main-window show #f))])

    (new button%
         [parent bottom-layout]
         [label "保存"]
         [callback (λ (_ __) (save-lyric))])

    (define (init-dialog song)
      (let* ([lrc (search-lyric (song-detail-id song))]
             [msg (or lrc "无歌词")])
        (send* lyric-edit
          (set-label #f)
          (set-value msg))))

    (define (save-lyric)
      (define save-path-file
        (put-file "保存歌词"
                  main-window
                  #f
                  (song-detail-name song-data)
                  "lrc"
                  null
                  '(("所有文件" "*"))))
      (when save-path-file
        (define lrc (send lyric-edit get-value))
        (display-to-file lrc save-path-file
                         #:mode 'text
                         #:exists 'truncate)
        (send main-window show #f)))

    ;;; 初始化
    (init-dialog song)
    (send main-window show #t)

    (super-new)))
