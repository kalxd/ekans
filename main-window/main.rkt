#lang racket/gui

(require "../base/main.rkt"
         "../site/main.rkt")

(provide main-window%)

(define main-window%
  (class object%
    ;;; 主窗口
    (define main-window
      (new frame%
           [label "白嫖歌词查找器"]
           [min-width 600]
           [min-height 400]))

    ;;; 点击的回调，忽略不必要参数，处理错误异常。
    (define (try-click f)
      (λ (_ __)
        (with-handlers
          ([错误? (λ (错误)
                    (message-box "提示"
                                 (错误-内容 错误)
                                 main-window))]
           [exn:fail? (λ (e)
                        (message-box "错误！"
                                     (exn-message e)
                                     main-window))])
          (f))))

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

    (define 歌曲编辑器
      (new text-field%
           [label "歌曲"]
           [parent top-group-box]))

    (define 歌手编辑器
      (new text-field%
           [label "歌手"]
           [parent top-group-box]))

    (define one-line-layout
      (new horizontal-pane%
           [parent top-group-box]))

    (define 网站选择器
      (new choice%
         [parent one-line-layout]
         [label "来源"]
         [choices (map symbol->string
                       (hash-keys site-hash))]))

    (define (点击搜索)
      (let ([歌曲 (send 歌曲编辑器 get-value)]
            [歌手 (send 歌手编辑器 get-value)]
            [网站 (send 网站选择器 get-string-selection)])
        (let ([site (hash-ref site-hash (string->symbol 网站))]
              [查询 (查询结构 歌曲 歌手)])
          (查询歌曲列表 site 查询))))

    (new button%
         [label "搜索(&s)"]
         [parent one-line-layout]
         [callback (try-click 点击搜索)])

    ;;; 结果区
    (define search-layout
      (new horizontal-pane%
           [parent main-layout]))

    (define 查询结果表格
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
         [callback (λ (_ __) (void))])

    (new button%
         [label "下载音乐"]
         [parent search-side-layout]
         [callback (λ (_ __) (void))])

    (super-new)

    (define 已保存搜索结果 empty)
    ;;; 当前选择网站
    (define 已选择网站 #f)

    (define (刷新搜索列表)
      (define 歌曲列表 (搜索结果结构-歌曲列表 已保存搜索结果))
      (let ([一列 (map (compose number->string
                                歌曲结构-id)
                       歌曲列表)]
            [二列 (map 歌曲结构-名称 歌曲列表)]
            [三列 (map (compose 专辑结构-名称
                                歌曲结构-专辑)
                       歌曲列表)]
            [四列 (map (compose (λ (xs) (string-join xs "；"))
                                (λ (xs) (map 歌手结构-名字 xs))
                                歌曲结构-歌手列表)
                       歌曲列表)])
        (send 查询结果表格 set 一列 二列 三列 四列)))

    (define (查询歌曲列表 site 查询)
      (send 查询结果表格 set-label "开始搜索……")
      (define 搜索结果 (->搜索 site 查询))
      (set! 已保存搜索结果 搜索结果)
      (刷新搜索列表)
      (send 查询结果表格 set-label "搜索结果："))

    #|
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
    |#
    (send main-window show #t)))

(module+ test
  (new main-window%))
