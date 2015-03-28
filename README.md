# markdown_slideshow

用markdown语法编写幻灯片演示文件，最终生成的文件为PDF格式。

## 安装依赖工具

    $ sudo apt-get install pandoc
    $ sudo apt-get install texlive-xetex
    $ sudo apt-get install texlive-latex-recommended
    $ sudo apt-get install texlive-fronts-recommended
    $ sudo apt-get install texlive-latex-extra
    $ sudo apt-get install fonts-arphic-gbsn00lp fronts-arphic-ukai # arphic 
    $ sudo apt-get install ttf-wqy-microhei ttf-wqy-zenhei # WenQuanYi中文字体


## 编译

    $ make

## 新增一个项目

### 用模板创建新项目

运行如下命令：

    $ make newproj M=proj_name


### 修改幻灯片标题等

用文本编辑器打开文件`projects/proj_name/title.tex`，可以编辑主标题、副标题、作者和日期等信息，这些信息会显示在幻灯片的首页上。

### 编辑幻灯片内容

用文本编辑器打开文件`projects/proj_name/content.md`进行编辑，采用markdown语法。引用的图片必须放置在目录`projects/proj_name/figures`下。

### 将新项目加入编译系统

用文本编辑器打开`Makefile`文件, 在`MODULES`中增加该项目的目录名称：

    MODULES += proj_name 

然后执行`make`编译，最终的PDF文件生成在`out`目录下。

