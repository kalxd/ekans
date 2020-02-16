#lang scribble/manual

@require[@for-label[racket/base]]

@title{添加新网站}

@filepath{site/}目录有着每个网站实现，需要添加的网站文件都能在此找到。我们以虚拟的@defterm{cc}网站为例。

@codeblock{
;;; cc.rkt
(require "../base/type.rkt") ; 引入必要的依赖。

(provide site) ; 仅导出结构体构造函数。

(struct site []  ; 置空即可，一般不会有额外参数。
  #:methods gen:Site [])
}

如此我们就能使用这个新类型。此时启动程序，我们不能看到新网站选项，需要为它定义一个网站名称，并写入到选择列表中。接下来我们打开@filepath{site/main.rkt}：

@codeblock{
(require (rename-in "./netease.rkt"
                    (site netease-site))
         (rename-in "./kugou.rkt"
                    (site kugou-site)))
		;;; 新的站点写在下面
		(rename-in "./cc.rkt"
				   (site cc-site))

;;; 省略其他代码

(define site-hash
  (make-hash `((网易云音乐 . ,(netease-site))
  			   (cc歌词下载站 . ,(cc-site))
               (酷狗音乐 . ,(kugou-site)))))

}

此时打开程序就能看到我们的新网站了，其他功能也能使用。由于全部使用默认实现，每个操作都会提示“未定义”。为了正常使用，务必要实现对应接口。

更加具体实现，可以参考@filepath{site/netease.rkt}。
