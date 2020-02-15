#lang racket/base

(require racket/generic
         racket/gui

         "./error.rkt")

(provide (all-defined-out))

(define (尚未实现)
  (发生错误 "尚未为此网站实现该行为！"))

(define-generics Site
  (->搜索 Site 查询)
  (->下载歌词 Site 歌曲)
  (->下载歌曲 Site 歌曲)

  #:fallbacks [(define (->搜索 self 查询) (尚未实现))
               (define (->下载歌词 self 歌曲) (尚未实现))
               (define (->下载歌曲 self 歌曲) (尚未实现))])
