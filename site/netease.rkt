#lang racket/base

(require "../base/main.rkt")

(provide site)

(struct site []
  #:methods gen:Site
  [(define (->搜索 _ 查询)
     (displayln 查询))])
