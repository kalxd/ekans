#lang racket/base

(require racket/contract
         racket/match
         net/url
         json
         "../base/main.rkt")

(provide site)

(define 查询url
  (string->url "https://music.163.com/api/search/get/web"))

(define 查询query
  '((csrf_token . #f)
    (offset . "0")
    (type . "1")
    (limit . "20")))

(define/contract (album->专辑 album)
  (-> jsexpr? 专辑结构?)
  (match album
    [(hash-table ('id id) ('name 名称))
     (专辑结构 id 名称)]))

(define/contract (artist->歌手 artist)
  (-> jsexpr? 歌手结构?)
  (match artist
    [(hash-table ('id id) ('name 名字))
     (歌手结构 id 名字)]))

(define/contract (song->歌曲 json)
  (-> jsexpr? 歌曲结构?)
  (match json
    [(hash-table ('id id) ('name 名称) ('artists artists) ('album album))
     (let ([歌手列表 (map artist->歌手 artists)]
           [专辑 (album->专辑 album)])
       (歌曲结构 id 名称 歌手列表 专辑))]))

(define/contract (json->搜索结果 json)
  (-> jsexpr? 搜索结果结构?)
  (let* ([result (hash-ref json 'result)]
         [songs (hash-ref result 'songs)]
         [歌曲列表 (map song->歌曲 songs)])
    (搜索结果结构 歌曲列表)))

(struct site []
  #:methods gen:Site
  [(define (->搜索 _ 查询)
     (displayln 查询))])

(module+ test
  (define in (open-input-file "./sample/neteast-search.json"))
  (define json (read-json in))
  (close-input-port in)
  (define result
    (json->搜索结果 json))
  (displayln result))
