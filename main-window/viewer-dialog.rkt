#lang racket/gui

(require "../base/main.rkt")

(provide viewer-dialog%)

(define viewer-dialog%
  (class object%
    (init site
          歌曲)

    (define 当前site site)
    (define 当前歌曲 歌曲)

    (define main-window
      (new dialog%
           [label "查看歌词"]))

    (define 歌词编辑器
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
         [callback (λ (_ __) (保存歌词))])

    (define (保存歌词)
      (define 保存路径
        (put-file "保存歌词"
                  main-window
                  #f
                  (歌曲结构-名称 当前歌曲)
                  "lrc"
                  null
                  '(("所有文件" "*"))))
      (when 保存路径
        (define lrc (send 歌词编辑器 get-value))
        (display-to-file lrc 保存路径
                         #:mode 'text
                         #:exists 'truncate)
        (send main-window show #f)))

    (define (初始化)
      (define 歌词 (->下载歌词 当前site 当前歌曲))
      (define 结果
        (or 歌词 "无结果！"))
      (send* 歌词编辑器
        (set-label #f)
        (set-value 结果)))

    (初始化)
    (send main-window show #t)

    (super-new)))
