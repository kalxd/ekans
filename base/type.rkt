#lang racket/base

(require racket/contract)

(provide (all-defined-out))

#| 网站返回结构 |#
(define-struct/contract 专辑结构
  ([id any/c]
   [名称 string?])
  #:transparent)

(define-struct/contract 歌手结构
  ([id any/c]
   [名字 string?])
  #:transparent)

(define-struct/contract 歌曲结构
  ([id any/c]
   [名称 string?]
   [歌手列表 (listof 歌手结构?)]
   [专辑 专辑结构?])
  #:transparent)

(define-struct/contract 搜索结果结构
  ([歌曲列表 (listof 歌曲结构?)])
  #:transparent)
#| 结束 |#

#| 用户输入 |#
(define-struct/contract 查询结构
  ([歌曲 string?]
   [歌手 string?])
  #:transparent)
#| 结束 |#
