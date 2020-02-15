#lang racket/gui

(require "../base/main.rkt"
         "../site/main.rkt"
         "./viewer-dialog.rkt")

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
            [site (当前选择网站)])
        (查询歌曲列表 site (查询结构 歌曲 歌手))))

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

    (define (查看歌词)
      (define 一组选择 (send 查询结果表格 get-selections))
      (unless (empty? 一组选择)
        (let* ([位置 (car 一组选择)]
               [选择的歌曲 (list-ref (搜索结果结构-歌曲列表 已保存搜索结果)
                                     位置)]
               [site (当前选择网站)])
          (when 选择的歌曲
            (new viewer-dialog%
                 [site site]
                 [歌曲 选择的歌曲])))))

    (new button%
         [label "查看(&v)"]
         [parent search-side-layout]
         [callback (try-click 查看歌词)])

    (new button%
         [label "下载音乐"]
         [parent search-side-layout]
         [callback (λ (_ __) (void))])

    (super-new)

    #| 私有成员 |#
    (define 已保存搜索结果 empty)
    #| 结束 |#

    (define (当前选择网站)
      (let* ([sel (send 网站选择器 get-string-selection)]
             [sel (string->symbol sel)])
        (hash-ref site-hash sel)))

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
