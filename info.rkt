#lang info

(define name "Ekans")
(define gracket-launcher-libraries '("main.rkt"))
(define gracket-launcher-names '("ekans"))

(define deps '("base"
               "gui-lib"))
(define build-deps '("scribble-lib"
                     "racket-doc"
                     "rackunit-lib"))
(define scribblings '(("scribblings/main.scrbl" ())))
(define pkg-desc "歌词白嫖器")
(define version "0.1.0")
(define pkg-authors '(XG.Ley))
