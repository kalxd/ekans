#lang racket/base

(require racket/generic
         racket/contract)

(provide (all-defined-out))

(struct 专辑结构 [id 名称]
  #:transparent)

(define 专辑/c
  (struct/c 专辑结构 any/c string?))

(struct 歌手结构 [id 名字]
  #:transparent)

(define 歌手/c
  (struct/c 歌手结构 any/c string?))

(struct 歌曲结构 [id 名称 歌手列表 专辑]
  #:transparent)

(define 歌曲/c
  (struct/c 歌曲结构
            any/c
            string?
            (listof 歌手/c)
            专辑/c))

(struct 搜索结构 [歌曲列表]
  #:transparent)

(define 搜索/c
  (struct/c 搜索结构 (listof 歌曲/c)))
