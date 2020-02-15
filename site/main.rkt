#lang racket/base

(require (rename-in "./netease.rkt"
                    (site netease-site))
         (rename-in "./kugou.rkt"
                    (site kugou-site)))
(provide site-hash)

(define site-hash
  (make-hash `((网易云音乐 . ,(netease-site))
               (酷狗音乐 . ,(kugou-site)))))
