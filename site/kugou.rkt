#lang racket/base

(require "../base/main.rkt")

(provide site)

(struct site []
  #:methods gen:Site [])
