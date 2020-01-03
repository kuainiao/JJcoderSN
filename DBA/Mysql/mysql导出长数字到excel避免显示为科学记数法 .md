# mysql导出长数字到excel避免显示为科学记数法 解决方法

## 现象描述

经常遇到MYSQL导出长数字或纯数字字符串（如身份证、卡券号、条码、流水号等）到csv或excel文件，用excel打开会显示为科学记数法，甚至后几位转为0。这是由Excel的特性决定的：Excel显示11位以上的数字时，会自动转化为科学计数法，如果长度大于15位，15位以后数字还会转成0。

网上搜到的解决办法是在该长数字前增加tab字符： 即： `CONCAT("\t",str)` 其中 \t 为制表符（即键盘上的Tab键）的转义符

实践时发现按此方法导出的文件打开后虽然显示为文本字符，但长度多了1，在字符前多了一个不可见空格（制表符），删掉才是原来的字符。

> 如果只是展示、打印倒无妨，但如果需要后续引用该字符串（如用VLOOKUP匹配），因为前面多了一个不可见的空格，长度也多了一位，则可能会出错。

后来想起excel输入长数字的可在数字前输入单引号”‘”强制转为文本，在 mysql输出时也可以试试，测试可用： 即： `CONCAT("'",str)` 或者 `CONCAT("\'",str)` 另外注意需保存为excel文件,即xls或xlsx文件，该数字即已强转为文本格式；如保存为csv，用excel打开则显示为可见单引号+数字形式，原因尚不明。

## 总结：

- 如果只需要导出展示、打印：可使用 `CONCAT("\t",str)`
- 如果需要后续处理，引用，最好使用`CONCAT("'",str)`或者`CONCAT("\'",str)`，并导出为EXCEL文件。

## 解决办法：在导出查询时，使用MySQL中concat函数给长数字的字段加上单引号","，再点击【导出向导】导出excel，excel打开就显示正常的长数字了，

```sql
SELECT CONCAT("`",p_card_num),card_num FROM ppos_member_card_src WHERE p_card_num=002580986

SELECT CONCAT("\t",p_card_num),card_num FROM ppos_member_card_src WHERE p_card_num=002580986
```