#lang racket

(require racket/generic)

(provide (all-defined-out))

;;; 歌曲专辑
(struct song-album [id name]
  #:transparent)

(define song-album/c
  (struct/c song-album
            integer?
            string?))

;;; 歌手
(struct song-singer [id name]
  #:transparent)

(define song-singer/c
  (struct/c song-singer
            integer?
            string?))

;;; 歌曲详细信息
(struct song-detail [id name artist-list album]
  #:transparent)

(define song-detail/c
  (struct/c song-detail
            integer?
            string?
            (listof song-singer/c)
            song-album/c))

;;; 搜索结果
(struct search-result [song-list]
  #:transparent)

(define search-result/c
  (struct/c search-result
            (listof song-detail/c)))

(define/contract (search-result->choice result)
  (-> search-result/c any)
  (define song-list (search-result-song-list result))
  (let ([col1 (map (compose number->string song-detail-id) song-list)]
        [col2 (map song-detail-name song-list)]
        [col3 (map (compose song-album-name song-detail-album) song-list)]
        [col4 (map (compose (λ (xs) (string-join xs "/"))
                            (λ (xs) (map song-singer-name xs))
                            song-detail-artist-list)
                   song-list)])
    (values col1 col2 col3 col4)))
