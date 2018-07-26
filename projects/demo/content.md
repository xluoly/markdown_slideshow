# 标题
## Markdown 标题层次
* 一级/二级/三级/四级  

~~~
# 一级标题  
## 二级标题  
### 三级标题  
#### 四级标题  
~~~

* 一二级标题还可以这样表示

~~~
一级标题  
========

二级标题  
--------
~~~

# 列表
## 无序列表

使用星号(*)

~~~
* 北京
* 上海
~~~

或者使用减号(-)

~~~
- 北京
- 上海
~~~

或者使用加号(+)

~~~
+ 北京
+ 上海
~~~

输出效果：

+ 北京
+ 上海


## 顺序列表

~~~
1. 广东
2. 广西
~~~

甚至可以写成：

~~~
1. 广东
1. 广西
~~~

或者：

~~~
2. 广东
1. 广西
~~~

输出效果都是一样的：

1. 广东
2. 广西

## 列表嵌套

下一级插入4个空格或者一个制表符(Tab)

~~~
* 广东
    * 深圳
    * 广州
* 广西
    1. 桂林
    2. 南宁
~~~

效果：

* 广东
    * 深圳
    * 广州
* 广西
    1. 桂林
    2. 南宁

# 字体和段落
## Markdown字体 

~~~
*single asterisks as italic*   
_single underscores as italic_   
**double asterisks as bold**   
__double underscores as bold__   
~~~

输出效果：

*single asterisks as italic*   
_single underscores as italic_   
**double asterisks as bold**   
__double underscores as bold__   

- **注意**：中文没有 **黑体** 和 _斜体_ 的概念。虽然可以用文泉译微黑等字体模拟黑体效果，但是这不是正规的中文排版方式。

## 换行  

在行尾输入2个空格，  
就可以实现换行功能

# 代码引用
## 代码段

使用一对三个反引号(键盘左上角\`)或三个波浪号(\~)，可以引用大段的代码保持原有缩进格式 

```

~~~
#include <stdio.h>

int main(void)
{
    printf("hello, world\n");
    return 0;
}
~~~

```

输出效果：

```
#include <stdio.h>

int main(void)
{
    printf("hello, world\n");
    return 0;
}
```

## 行内代码

如果要标记一小段行内代码，可以用一对反引号（`）把它包起来

~~~
call `printf()` function
~~~

显示为：

call `printf()` function

# 超链接和图片
## 超链接

~~~
欢迎访问我的[Github](https://github.com/xluoly)  
欢迎访问我的Github\(<https://github.com/xluoly>\)  
~~~

输出效果：

欢迎访问我的[Github](https://github.com/xluoly)  
欢迎访问我的Github\(<https://github.com/xluoly>\)  

## 内嵌图片

~~~
![](markdown_logo.jpg)
~~~

输出效果：

![](markdown_logo.jpg)

# 表格
## 表格

~~~

  Right     Left     Center     Default
-------     ------ ----------   -------
     12     12        12            12
    123     123       123          123
      1     1          1             1
~~~

输出效果：

  Right     Left     Center     Default
-------     ------ ----------   -------
     12     12        12            12
    123     123       123          123
      1     1          1             1


## 表格

- 省略标题栏

~~~

-------     ------ ----------   -------
     12     12        12             12
    123     123       123           123
      1     1          1              1
-------     ------ ----------   -------
~~~

输出效果：

-------     ------ ----------   -------
     12     12        12             12
    123     123       123           123
      1     1          1              1
-------     ------ ----------   -------

## 表格

- 也可以写成这样

~~~

Right | Left | Center | Default
-----:|:-----|:------:|---------
12    | 12   | 12     | 12
123   | 123  | 123    | 123
1     | 1    | 1      | 1
~~~

输出效果：

Right | Left | Center | Default
-----:|:-----|:------:|---------
12    | 12   | 12     | 12
123   | 123  | 123    | 123
1     | 1    | 1      | 1


# 数学公式
## 行内公式

- 行内公式包在\$和\$之间

    ~~~
    行内公式 $\int_0^1 \sum_{i=1}^n f(x_i, \theta) d\theta$  
    $a^{(2)}$ 正确，$a^(2)$ 错误，分式 $\frac{a}{b}$
    ~~~

    输出效果：

    行内公式 $\int_0^1 \sum_{i=1}^n f(x_i, \theta) d\theta$  
    $a^{(2)}$ 正确，$a^(2)$ 错误，分式 $\frac{a}{b}$

## 独立公式

- 独立公式 (displayed formula) 包在\$\$和\$\$之间

    ~~~
    $$
    \int_0^1 \sum_{i=1}^n f(x_i, \theta) d\theta
    $$
    ~~~

    输出效果：

    $$
    \int_0^1 \sum_{i=1}^n f(x_i, \theta) d\theta
    $$


## 特殊字符

如果需要显示下面这些符号，需要在它们的前面加一个反斜杠(\\):

    \   反斜线
    `   反引号
    *   星号
    _   底线
    {}  花括号
    []  方括号
    ()  括弧
    #   井字号
    +   加号
    -   减号
    .   英文句点
    !   惊叹号
    $   美元符

# 幻灯片制作过程
## 编辑幻灯片

- 只需要写二级标题和三级标题就可以了，每个二级标题将生成一页幻灯片，二级标题就会变成该页幻灯片的标题
- 也可以直接插入一行连续的多个(至少3个)减号(-)，进行分页
    
    ~~~

    ---
    这是新的一页

    ~~~

---

这是新的一页

## 格式转换工具使用

- 使用到的工具：
    - **pandoc** 将markdown文件转成latex文件
    - **xelatex** 将latex文件转成pdf文件

- 工具的安装(ubuntu)

    ~~~
    $ sudo apt-get install pandoc
    $ sudo apt-get install texlive-xetex
    $ sudo apt-get install texlive-latex-recommended
    $ sudo apt-get install texlive-fonts-recommended
    $ sudo apt-get install texlive-latex-extra
    $ sudo apt-get install fonts-arphic-gbsn00lp fonts-arphic-ukai # arphic 
    $ sudo apt-get install ttf-wqy-microhei ttf-wqy-zenhei # WenQuanYi中文字体

    ~~~


## 使用范例
	
* markdown -> latex
    - 使用beamer模板才能生成幻灯片格式的latex文件

    ~~~
    pandoc -t beamer --slide-level 2 demo.md -o demo.tex
    ~~~

* latex -> pdf
    - 修改tex模板可以得到不同的输出效果
    - 定制幻灯片首页显示的标题，作者和日期等
    - 指定不同的内置幻灯片风格模板[beamer theme](http://www.hartwork.org/beamer-theme-matrix)

    ~~~
    xelatex slide.tex # slide.tex是预先准备好的tex模板文件
    ~~~
	

## Thanks

![](question.png)

