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
    (limit . "30")))

(define 歌曲url
  (string->url "https://music.163.com/api/song/lyric"))

(define 歌曲query
  '((os . "osx")
    (lv . "-1")
    (kv . "-1")
    (tv . "-1")))

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
     (let* ([查询歌曲 (查询结构-歌手 查询)]
            [查询歌手 (查询结构-歌曲 查询)]
            [s (format "~a+~a" 查询歌曲 查询歌手)]
            [query (cons `(s ., s) 查询query)]
            [url (struct-copy url 查询url [query query])]
            [port (get-pure-port url)])
       (json->搜索结果 (read-json port))))

   (define (->下载歌词 _ 歌曲)
     (let* ([id (歌曲结构-id 歌曲)]
            [id (number->string id)]
            [query (cons `(id . ,id) 歌曲query)]
            [url (struct-copy url 歌曲url [query query])]
            [port (get-pure-port url)]
            [json (read-json port)]
            [lrc (hash-ref json 'lrc #f)]
            [歌词 (and lrc (hash-ref lrc 'lyric #f))])
       (close-input-port port)
       歌词))

   (define (->下载歌曲 _ 歌曲)
     (let* ([id (歌曲结构-id 歌曲)]
            [url (format "http://music.163.com/song/media/outer/url?id=~a.mp3" id)]
            [url (string->url url)])
       (get-pure-port url
                      #:redirections 2)))])

(module+ test
  (define in (open-input-file "./sample/neteast-search.json"))
  (define json (read-json in))
  (close-input-port in)
  (define result
    (json->搜索结果 json))
  (displayln result))
