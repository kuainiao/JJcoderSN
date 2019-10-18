# Linux shell 的字符串截取方法。

------

# Linux shell 的字符串截取方法

假设有变量 var=http://www.aaa.com/123.htm.

## 删除左边字符，保留右边字符

```shell
echo ${var#*//}
其中 var 是变量名，# 号是运算符，*// 表示从左边开始删除第一个 // 号及左边的所有字符
即删除 http://
结果是 ：www.aaa.com/123.htm
```

## #号截取，删除左边字符，保留右边字符

```shell
echo ${var##*/}
##*/ 表示从左边开始删除最后（最右边）一个 / 号及左边的所有字符
即删除 http://www.aaa.com/

结果是 123.htm
```

## [#](http://www.liuwq.com/views/linux基础/shell截取字符串.html#号截取，删除右边字符，保留左边字符)%号截取，删除右边字符，保留左边字符

```shell
echo ${var%/*}
%/* 表示从右边开始，删除第一个 / 号及右边的字符

结果是：http://www.aaa.com
```

## [#](http://www.liuwq.com/views/linux基础/shell截取字符串.html#号截取，删除右边字符，保留左边字符-2)%%号截取，删除右边字符，保留左边字符

```shell
echo ${var%%/*}
%%/* 表示从右边开始，删除最后（最左边）一个 / 号及右边的字符
结果是：http:
```

## [#](http://www.liuwq.com/views/linux基础/shell截取字符串.html#从左边第几个字符开始，及字符的个数)从左边第几个字符开始，及字符的个数

```shell
echo ${var:0:5}
其中的 0 表示左边第一个字符开始，5 表示字符的总个数。
结果是：http:
```

## [#](http://www.liuwq.com/views/linux基础/shell截取字符串.html#从左边第几个字符开始，一直到结束。)从左边第几个字符开始，一直到结束。

```shell
echo ${var:7}
其中的 7 表示左边第8个字符开始，一直到结束。
结果是 ：www.aaa.com/123.htm
```

## [#](http://www.liuwq.com/views/linux基础/shell截取字符串.html#从右边第几个字符开始，及字符的个数)从右边第几个字符开始，及字符的个数

```shell
echo ${var:0-7:3}
其中的 0-7 表示右边算起第七个字符开始，3 表示字符的个数。
结果是：123
```

## [#](http://www.liuwq.com/views/linux基础/shell截取字符串.html#从右边第几个字符开始，一直到结束。)从右边第几个字符开始，一直到结束。

```shell
echo ${var:0-7}
表示从右边第七个字符开始，一直到结束。
结果是：123.htm
```