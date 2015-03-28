# markdown_slideshow
Write slideshow presentation with markdown.

## 安装依赖工具

```
$ sudo apt-get install pandoc
$ sudo apt-get install texlive-xetex
$ sudo apt-get install texlive-latex-recommended
$ sudo apt-get install texlive-fronts-recommended
$ sudo apt-get install texlive-latex-extra
$ sudo apt-get install fonts-arphic-gbsn00lp fronts-arphic-ukai # arphic 
$ sudo apt-get install ttf-wqy-microhei ttf-wqy-zenhei # WenQuanYi中文字体

```

## 编译

```
$ make
```

## 新增一个项目

    $ make newproj M=name

然后修改Makefile, 在MODULES中增加该项目的目录名称，如：

    MODULES += name 

这样就可以执行`make`编译了。

