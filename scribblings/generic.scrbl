#lang scribble/manual

@require[@for-label[racket/base ekans/base/type]]

@title{网站抽象}

@defterm{ekans}统一了网站行为，只要每个网站实现了接口，就能在界面上使用，无须处理其他事务。

@section{引入接口}

引入@filepath{base/main.rkt}即可，需要注意的是，一般网站文件都在@filepath{site}。可能需要这样写：

@codeblock{
(require "../base/main.rkt")

;;; 剩余逻辑……
}

然后得到了@defterm{gen:Site}、必要类型定义，可以直接引用。

@section{必要类型定义}

@defstruct[专辑结构 ([id any/c] [名称 string?])]{
歌曲所在专辑。
}

@defstruct[歌手结构 ([id any/c] [名字 string?])]{
歌曲演唱者信息。
}

@defstruct[歌曲结构 ([id any/c] [名称 string?] [歌手列表 (listof 歌手结构?)] [专辑 专辑结构?])]{
一首歌曲所有信息。

歌曲有可能由多位艺人演唱，故而是个列表。
}

@defstruct[搜索结果结构 ([歌曲列表 (listof 歌曲结构?)])]{
歌曲查询结果，不需要分页，取需要部分。
}

@defstruct[查询结构 ([歌曲 string?] [歌手 string?])]{
这是用户查询输入，用户点击“搜索”时，会将该类型传到对应函数。
}

@section{接口定义}

一共有三个接口可以实现，每个接口都有默认实现，所有默认实现都是提示“未定义”，如果要实现正确的功能，必须写出正确的实现方法，不能使用默认实现。

@defproc[(->搜索 [Site any/c] [查询 查询结构?]) 搜索结果结构?]{
实现歌曲搜索逻辑。

用户点击“搜索”，触发该接口。
}

@defproc[(->下载歌词 [Site any/c] [歌曲 歌曲结构?]) string?]{
实现歌词下载逻辑。

用户点击“查看歌词”，触发该接口。
}

@defproc[(->下载歌曲 [Site any/c] [歌曲 歌曲结构?]) input-port?]{
实现歌曲下载逻辑。
歌曲一般都由网络下载，所以仅返回一个@racket{input-port}即可，剩余部分都由其他代码处理了。

用户点击“下载歌曲”，触发该接品。
}
