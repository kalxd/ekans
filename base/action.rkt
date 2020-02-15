#lang racket/base

(require racket/generic
         racket/gui)

(provide (all-defined-out))

(define (尚未实现)
  (message-box "不允许操作" "尚未为此网站实现该行为！"))

(define-generics Site
  (->搜索 Site)
  (->下载歌词 Site)
  (->下载音乐 Site)

  #:fallbacks [(define (->搜索 self) (尚未实现))
               (define (->下载歌词 self) (尚未实现))
               (define (->下载音乐 self) (尚未实现))])
