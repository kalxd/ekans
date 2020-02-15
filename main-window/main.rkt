#lang racket/gui

(require "./network/netease.rkt"
         "./network/gen.rkt"
         "./lyric-dialog.rkt")

(provide (all-defined-out))

(define main-window%
  (class object%
    ;;; 主窗口
    (define main-window
      (new frame%
           [label "老子的歌词查找器"]
           [min-width 600]
           [min-height 400]))

    ;;; 主要布局
    (define main-layout
      (new vertical-pane%
           [parent main-window]))

    ;;; 编辑区
    (define top-group-box
      (new group-box-panel%
           [label "基本信息"]
           [parent main-layout]
           [alignment '(left center)]
           [stretchable-height #f]))

    (define song-name-edit
      (new text-field%
           [label "歌名"]
           [parent top-group-box]))

    (define song-singer-edit
      (new text-field%
           [label "歌手"]
           [parent top-group-box]))

    (define one-line-layout
      (new horizontal-pane%
           [parent top-group-box]))

    (new choice%
         [parent one-line-layout]
         [label "来源"]
         [choices '("网易")])

    (new button%
         [label "搜索(&s)"]
         [parent one-line-layout]
         [callback (λ (_ __) (start-search))])

    ;;; 结果区
    (define search-layout
      (new horizontal-pane%
           [parent main-layout]))
    (define search-table
      (new list-box%
           [label "搜索结果"]
           [style '(column-headers single vertical-label)]
           [columns '("id" . ("歌曲名" "专辑" "歌手"))]
           [choices empty]
           [parent search-layout]))

    (define search-side-layout
      (new vertical-pane%
           [parent search-layout]
           [stretchable-width #f]))

    (new button%
         [label "查看"]
         [parent search-side-layout]
         [callback (λ (_ __) (show-lyric-dialog))])

    (new button%
         [label "下载音乐"]
         [parent search-side-layout]
         [callback (λ (_ __) (download-music))])

    (super-new)

    ;;; private data
    (define song-list-data empty)

    (define (get-selected-song)
      (let* ([s (send search-table get-selections)]
             [is-empty? (empty? s)])
        (and (not is-empty?)
             (list-ref song-list-data (first s)))))

    (define (refresh-table result)
      (define-values (col1 col2 col3 col4)
        (search-result->choice result))
      (set! song-list-data (search-result-song-list result))
      (send search-table set col1 col2 col3 col4))

    (define (start-search)
      (send search-table set-label "开始搜索......")
      (let ([name (send song-name-edit get-value)]
            [singer (send song-singer-edit get-value)])
        (touch (future
                (λ ()
                  (define result (search-netease-web name singer))
                  (and result (refresh-table result))
                  (unless result (message-box "错误" "未找到歌曲")))))
        (send search-table set-label "搜索结果")))

    (define (show-lyric-dialog)
      (let ([song (get-selected-song)])
        (when song (new lyric-dialog% [song song]))))

    (define (download-music)
      (let ([song (get-selected-song)])
        (when song
          (let ([filename (format "~a.mp3" (song-detail-name song))]
                [id (song-detail-id song)])
            (define save-file
              (put-file "保存位置"
                        main-window
                        #f
                        filename
                        "mp3"
                        null
                        '(("所有文件" "*"))))
            (and save-file (download-netease-music id save-file))))))

    (send main-window show #t)))

(module+ test
  (new main-window%))
