#lang racket

(require net/url
         json
         "./gen.rkt")

(provide search-netease-web
         search-lyric
         download-netease-music)

(define BASE_WEB_URL
  (string->url "https://music.163.com/api/search/get/web"))

(define BASE_QUERY
  '((csrf_token . #f)
    (offset . "0")
    (type . "1")
    (limit . "20")))

(define BASE_LYRIC_URL
  (string->url "https://music.163.com/api/song/lyric"))

(define BASE_LYRIC_QUERY
  '((os . "osx")
    (lv . "-1")
    (kv . "-1")
    (tv . "-1")))

(define/contract (->song-singer json)
  (-> jsexpr? song-singer/c)
  (match json
    [(hash-table ('id id) ('name name))
     (song-singer id name)]))

(define/contract (->song-album json)
  (-> jsexpr? song-album/c)
  (match json
    [(hash-table ('id id) ('name name))
     (song-album id name)]))

(define/contract (->song-detail json)
  (-> jsexpr? song-detail/c)
  (match json
    [(hash-table ('id id) ('name name) ('artists artist-list) ('album album))
     (let ([artist-list (map ->song-singer artist-list)]
           [album (->song-album album)])
       (song-detail id name artist-list album))]))

(define/contract (->search-result json)
  (-> jsexpr? (or/c #f search-result/c))
  (match json
    [(hash-table ('songs song-list))
     (let ([song-list (map ->song-detail song-list)])
       (search-result song-list))]
    [else #f]))

(struct search-lrc [lrc]
  #:transparent)

(define search-lrc/c
  (struct/c search-lrc
            string?))

(define/contract (->search-lrc json)
  (-> jsexpr? search-lrc/c)
  (match json
    [(hash-table ('lyric msg))
     (search-lrc msg)]))

(struct search-lrc-result [lrc]
  #:transparent)

(define search-lrc-result/c
  (struct/c search-lrc-result search-lrc/c))

(define/contract (->search-lrc-result json)
  (-> jsexpr? (or/c #f search-lrc-result/c))
  (match json
    [(hash-table ('lrc lrc))
     (search-lrc-result (->search-lrc lrc))]
    [else #f]))

(define/contract (search-netease-web name singer)
  (-> string? string? (or/c #f search-result))
  (let* ([s (format "~a+~a" name singer)]
         [query (cons `(s . ,s) BASE_QUERY)]
         [url (struct-copy url BASE_WEB_URL [query query])])
    (begin
      (define json (read-json (get-pure-port url)))
      (->search-result (hash-ref json 'result)))))

(define/contract (search-lyric id)
  (-> integer? (or/c #f string?))
  (let* ([id (number->string id)]
         [query (cons `(id . ,id) BASE_LYRIC_QUERY)]
         [url (struct-copy url BASE_LYRIC_URL [query query])])
    (begin
      (let* ([in (get-pure-port url)]
             [json (read-json in)]
             [lrc-result (->search-lrc-result json)])
        (and lrc-result
             (search-lrc-lrc (search-lrc-result-lrc lrc-result)))))))

(define/contract (download-netease-music id save-file)
  (-> integer? path-string? void?)
  (let* ([url (format "http://music.163.com/song/media/outer/url?id=~a.mp3" id)]
         [port (get-pure-port (string->url url)
                              #:redirections 2)]
         [data (port->bytes port)]
         [file-port (open-output-file save-file)])
    (begin
      (write-bytes data file-port)
      (close-output-port file-port))))

(module+ test
  (define in (open-input-file "./sample/neteast-search.json"))
  (define json (read-json in))
  (close-input-port in)
  (define result
    (->search-result (hash-ref json 'result)))
  (displayln result))
