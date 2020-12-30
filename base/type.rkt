#lang racket/base

(require racket/contract)

(provide (all-defined-out))

#| 网站返回结构 |#
(struct 专辑结构 [id 名称]
  #:transparent)

(define 专辑结构/c
  (struct/c 专辑结构
            any/c
            string?))

(struct 歌手结构 [id 名字]
  #:transparent)

(define 歌手结构/c
  (struct/c 歌手结构
            any/c
            string?))

(struct 歌曲结构 [id 名称 歌手列表 专辑]
  #:transparent)

(define 歌曲结构/c
  (struct/c 歌曲结构
            any/c
            string?
            (listof 歌手结构/c)
            专辑结构/c))

(struct 搜索结果结构 [歌曲列表]
  #:transparent)

(define 搜索结果结构/c
  (struct/c 搜索结果结构
            (listof 歌曲结构/c)))
#| 结束 |#

#| 用户输入 |#
[struct 查询结构 [歌曲 歌手]
  #:transparent]

(define 查询结构/c
  (struct/c 查询结构
            string?
            string?))
#| 结束 |#
