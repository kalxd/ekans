33
((3) 0 () 0 () () (h ! (equal)))
struct
(struct 专辑结构 (id 名称)
    #:extra-constructor-name make-专辑结构)
  id : any/c
  名称 : string?
struct
(struct 歌手结构 (id 名字)
    #:extra-constructor-name make-歌手结构)
  id : any/c
  名字 : string?
struct
(struct 歌曲结构 (id 名称 歌手列表 专辑)
    #:extra-constructor-name make-歌曲结构)
  id : any/c
  名称 : string?
  歌手列表 : (listof 歌手结构?)
  专辑 : 专辑结构?
struct
(struct 搜索结果结构 (歌曲列表)
    #:extra-constructor-name make-搜索结果结构)
  歌曲列表 : (listof 歌曲结构?)
struct
(struct 查询结构 (歌曲 歌手)
    #:extra-constructor-name make-查询结构)
  歌曲 : string?
  歌手 : string?
procedure
(->搜索 Site 查询) -> 搜索结果结构?
  Site : any/c
  查询 : 查询结构?
procedure
(->下载歌词 Site 歌曲) -> string?
  Site : any/c
  歌曲 : 歌曲结构?
procedure
(->下载歌曲 Site 歌曲) -> input-port?
  Site : any/c
  歌曲 : 歌曲结构?
