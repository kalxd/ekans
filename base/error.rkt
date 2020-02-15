#lang racket/base

(require racket/contract)

(provide (all-defined-out))

(struct 错误 [内容]
  #:transparent)

(define/contract 发生错误
  (-> string? 错误?)
  (compose raise 错误))
