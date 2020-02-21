#lang racket/base

(require net/url
         racket/contract
         json
         "../base/main.rkt")

(provide site)

(define 查询url
  (string->url "https://songsearch.kugou.com/song_search_v2"))

(define 查询query
  '((filter . "2")
    (platform . "WebFilter")))

(define/contract (json->歌手 json)
  (-> jsexpr? 歌手结构?)
  (let ([名字 (hash-ref json 'SingerName)])
    (歌手结构 #f 名字)))

(define/contract (json->歌曲 json)
  (-> jsexpr? 歌曲结构?)
  (let ([id (hash-ref json 'FileHash)]
        [名称 (hash-ref json 'OriSongName)]
        [歌手结构 (list (json->歌手 json))]
        [专辑 (专辑结构 #f (hash-ref json 'AlbumName))])
    (歌曲结构 id 名称 歌手结构 专辑)))

(define/contract (json->搜索结果 json)
  (-> jsexpr? 搜索结果结构?)
  (let* ([r (hash-ref json 'data)]
         [r (hash-ref r 'lists)]
         [歌手列表 (map json->歌曲 r)])
    (搜索结果结构 歌手列表)))

(define/contract (获取歌曲详情 歌曲)
  (-> 歌曲结构? jsexpr?)
  (let* ([hash-id (歌曲结构-id 歌曲)]
         [url (string->url (format "https://www.kugou.com/yy/index.php?r=play/getdata&hash=~a" hash-id))]
         [port (get-pure-port url '("Cookie: kg_mid=123"))]
         [json (read-json port)])
    (close-input-port port)
    json))

(struct site []
  #:methods gen:Site
  [(define (->搜索 _ 查询)
     (let* ([歌曲 (查询结构-歌曲 查询)]
            [歌手 (查询结构-歌手 查询)]
            [keyword (format "~a-~a" 歌曲 歌手)]
            [query (cons `(keyword . ,keyword) 查询query)]
            [url (struct-copy url 查询url [query query])]
            [port (get-pure-port url)]
            [json (read-json port)]
            [r (json->搜索结果 json)])
       (close-input-port port)
       r))

   (define (->下载歌词 _ 歌曲)
     (let* ([json (获取歌曲详情 歌曲)]
            [data-json (hash-ref json 'data #f)])
       (and data-json (hash-ref data-json 'lyrics #f))))

   (define (->下载歌曲 _ 歌曲)
     (let* ([json (获取歌曲详情 歌曲)]
            [data-json (hash-ref json 'data)]
            [r (hash-ref data-json 'play_url)]
            [音乐链接 (string->url r)])
       (get-pure-port 音乐链接)))])

(module+ test
  (let* ([in (open-input-file "./sample/kugou/search.json")]
         [json (read-json in)]
         [result (json->搜索结果 json)])
    (close-input-port in)
    (displayln result)))
