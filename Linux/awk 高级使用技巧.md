# awk 高级使用技巧

------

> awk的函数分成数学函数、字符串函数、I/O处理函数以及用户自定义的函数，其中用户自定义的函数我们在上一篇中也有简单的介绍，下面我们一一来介绍这几类函数。

# 数学函数

## awk 中支持以下数学函数：

```
  atan2(y,x)：反正切函数；
  cos(x)：余弦函数；
  sin(x)：正弦函数；
  exp(x)：以自然对数e为底指数函数；
  log(x)：计算以e 为底的对数值；
  sqrt(x)：绝对值函数；
  int(x)：将数值转换成整数；
  rand()：返回0到1的一个随机数值，不包含1；
  srand([expr])：设置随机种子，一般与rand函数配合使用，如果参数为空，默认使用当前时间为种子；
```

例如，我们使用rand()函数生成一个随机数值：

```shell
awk 'BEGIN {print rand(),rand();}'0.237788 0.291066
awk 'BEGIN {print rand(),rand();}'0.237788 0.291066
```

但是你会发现，每次awk执行都会生成同样的随机数，但是在一次执行过程中产生的随机数又是不同的。因为每次awk执行都使用了同样的种子，所以我们可以用srand()函数来设置种子:

```shell
awk 'BEGIN {srand();print rand(),rand();}'0.171625 0.00692412
awk 'BEGIN {srand();print rand(),rand();}'0.43269 0.782984
```

这样每次生成的随机数就不一样了。

利用rand()函数我们也可以生成1到n的整数：

```shell
    [kodango@devops awk_temp]$ awk '
    > function randint(n) { return int(n*rand()); }
    > BEGIN { srand(); print randint(10);
    > }'3
```

#### 字符串函数

awk中包含大多数常见的字符串操作函数。

1. sub(ere, repl[, in])

    描述：简单地说，就是将in中匹配ere的部分替换成repl，返回值是替换的次数。如果in参数省略，默认使用$0。替换的动作会直接修改变量的值。

    下面是一个简单的替换的例子：

    ```shell
        [kodango@devops ~]$ echo "hello, world" | awk '{print sub(/ello/, "i"); print}'1
        hi, world
    ```

    在repl参数中&是一个元字符，它表示匹配的内容，例如：

    ```shell
        [kodango@devops ~]$ awk 'BEGIN {var="kodango"; sub(/kodango/, "hello, &", var); print var}'
        hello, kodango
    ```

2. gsub(ere, repl[, in])

    描述：同sub()函数功能类似，只不过是gsub()是全局替换，即替换所有匹配的内容。

3. index(s, t)

    描述：返回字符串t在s中出现的位置，注意这里位置是从1开始计算的，如果没有找到则返回0。

    例如：

    `[kodango@devops ~]$ awk 'BEGIN {print index("kodango", "o")}'2[kodango@devops ~]$ awk 'BEGIN {print index("kodango", "w")}'0`

4. length[([s])]

    描述：返回字符串的长度，如果参数s没有指定，则默认使用$0作为参数。

    例如：

    `[kodango@devops ~]$ awk 'BEGIN {print length('kodango');}'0[kodango@devops ~]$ echo "first line" | awk '{print length();}'10`

5. match(s, ere)

    描述： 返回字符串s匹配ere的起始位置，如果不匹配则返回0。该函数会定义RSTART和RLENGTH两个内置变量。RSTART与返回值相同，RLENGTH记录匹配子串的长度，如果不匹配则为-1。

    例如：

    ```shell
        [kodango@devops ~]$ awk 'BEGIN {
        print match("kodango", /dango/);
        printf "Matched at: %d, Matched substr length: %d\n", RSTART, RLENGTH;
        }'3Matched at: 3, Matched substr length: 5
    ```

6. split(s, a[, fs])

    描述：将字符串按照分隔符fs，分隔成多个部分，并存到数组a中。注意，存放的位置是从第1个数组元素开始的。如果fs为空，则默认使用FS分隔。函数返回值分隔的个数。

    例如：

    ```shell
        [kodango@devops ~]$ awk 'BEGIN {
        > split("1;2;3;4;5", arr, ";")
        > for (i in arr)
        >     printf "arr[%d]=%d\n", i, arr[i];
        > }'
        arr[4]=4
        arr[5]=5
        arr[1]=1
        arr[2]=2
        arr[3]=3
    ```

    ```
     这里有一个奇怪的地方是for..in..输出的数组不是按顺序输出的，如果要按顺序输出可以用常规的for循环:
    ```

    ```shell
        [kodango@devops ~]$ awk 'BEGIN {
        > split("1;2;3;4;5", arr, ";")
        > for (i=0;^C
        [kodango@devops ~]$ awk 'BEGIN {> n=split("1;2;3;4;5", arr, ";")> for (i=1; i<=n; i++)>     printf "arr[%d]=%d\n", i, arr[i];> }'
        arr[1]=1
        arr[2]=2
        arr[3]=3
        arr[4]=4
        arr[5]=5
    ```

7. sprintf(fmt, expr, expr, ...)

    描述：类似printf，只不过不会将格式化后的内容输出到标准输出，而是当作返回值返回。

    例如：

    ```shell
        [kodango@devops ~]$ awk 'BEGIN {
        > var=sprintf("%s=%s", "name", "value")
        > print var
        > }'
        name=value
    ```

8. substr(s, m[, n])

    描述：返回从位置m开始的，长度为n的子串，其中位置从1开始计算，如果未指定n或者n值大于剩余的字符个数，则子串一直到字符串末尾为止。

    例如：

    ```shell
        [kodango@devops ~]$ awk 'BEGIN { print substr("kodango", 2, 3); }'
        oda
        [kodango@devops ~]$ awk 'BEGIN { print substr("kodango", 2); }'
        odango
    ```

9. tolower(s)

    描述：将字符串转换成小写字符。

    例如：

    ```shell
        [kodango@devops ~]$ awk 'BEGIN {print tolower("KODANGO");}'
        kodango
    ```

10. toupper(s)

    > 描述：将字符串转换成大写字符。

    例如:

    ```shell
    [kodango@devops ~]$ awk 'BEGIN {print tolower("kodango");}'
    KODANGO
    ```

## I/O处理函数

1. getline

    getline的用法相对比较复杂，它有几种不同的形式。不过它的主要作用就是从输入中每次获取一行输入。

    a. expression | getline [var]

    这种形式将前面管道前命令输出的结果作为getline的输入，每次读取一行。如果后面跟有var，则将读取的内容保存到var变量中，否则会重新设置$0和NF。

    例如，我们将上面的statement.txt文件的内容显示作为getline的输入：

    ```shell
        [kodango@devops awk_temp]$ awk 'BEGIN { while("cat statement.txt" | getline var) print var}'
        statement
        deleteexitnext
    ```

    上面的例子中命令要用双引号，"cat statement.txt"，这一点同print/printf是一样的。

    如果不加var，则直接写到$0中，注意NF值也会被更新：

    ```shell
        [kodango@devops awk_temp]$ awk 'BEGIN { while("cat statement.txt" | getline) print $0,NF}'
        statement 1delete 1exit 1next 1
        b. getline [var]
    ```

    第二种形式是直接使用getline，它会从处理的文件中读取输入。同样地，如果var没有，则会设置$0，并且这时候会更新 NF, NR和FNR：

    ```shell
        [kodango@devops awk_temp]$ awk '{
        > while (getline)
        >    print NF, NR, FNR, $0;
        > }' statement.txt
        1 2 2 delete1 3 3 exit1 4 4 next
        c. getline [var] < expression
    ```

    第三种形式从expression中重定向输入，与第一种方法类似，这里就不加赘述了。

2. close

    close函数可以用于关闭已经打开的文件或者管道，例如getline函数的第一种形式用到管道，我们可以用close函数把这个管道关闭，close函数的参数与管道的命令一致：

    ```shell
        [kodango@devops awk_temp]$ awk 'BEGIN {
        while("cat statement.txt" | getline) {
            print $0;
            close("cat statement.txt");
            }}'
            statement
            statement
            statement
            statement
            statement
            但是每次读了一行后，关闭管道，然后重新打开又重新读取第一行就死循环了。所以要慎用，一般情况下也很少会用到close函数。
    ```

3. system

这个函数很简单，就是用于执行外部命令，例如：

```shell
    [kodango@devops awk_temp]$ awk 'BEGIN {system("uname -r");}'3.6.2-1-ARCH
```