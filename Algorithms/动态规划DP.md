# 动态规划(DP)的整理-Python描述



> 今天整理了一下关于动态规划的内容，道理都知道，但是python来描述的方面参考较少，整理如下，希望对你有所帮助，实验代码均经过测试。

# 请先好好阅读如下内容–什么是动态规划？

> 摘录于《算法图解》

![这里写图片描述](%E5%8A%A8%E6%80%81%E8%A7%84%E5%88%92DP.assets/20170722011027750.jpeg)

> 以上的都建议自己手推一下，然后知道怎么回事，核心的部分是142页核心公式，待会代码会重现这个过程，推荐没有算法基础的小伙伴看这本书《算法图解》很有意思的书，讲的很清晰，入门足够

更深入的请阅读[python算法-动态规划](http://python.jobbole.com/81465/)写的不错，可以参考

## 为什么要使用动态规划？

From:[动态规划是什么，意义在哪里？！！！！](http://blog.csdn.net/w571523631/article/details/70132265)

 首先我们要知道为什么要使用(Dynamic programming)dp，我们在选择dp[算法](http://lib.csdn.net/base/datastructure)的时候，往往是在决策问题上，而且是在如果不使用dp，直接暴力效率会很低的情况下选择使用dp.

那么问题来了，什么时候会选择使用dp呢，一般情况下，我们能将问题抽象出来，并且问题满足无后效性，满足最优子结构，并且能明确的找出状态转移方程的话，dp无疑是很好的选择。

- 无后效性通俗的说就是只要我们得出了当前状态，而不用管这个状态怎么来的，也就是说之前的状态已经用不着了，如果我们抽象出的状态有后效性，很简单，我们只用把这个值加入到状态的表示中。
- 最优子结构(自下而上)：在决策问题中，如果，当前问题可以拆分为多个子问题，并且依赖于这些子问题，那么我们称为此问题符合子结构，而若当前状态可以由某个阶段的某个或某些状态直接得到，那么就符合最优子结构
- 重叠子问题(自上而下)：动态规划算法总是充分利用重叠子问题，通过每个子问题只解一次，把解保存在一个需要时就可以查看的表中，每次查表的时间为常数，如备忘录的递归方法。斐波那契数列的递归就是个很好的例子
- 状态转移：这个概念比较简单，在抽象出上述两点的的状态表示后，每种状态之间转移时值或者参数的变化。

## 小结

- 动态规划： 动态规划表面上很难，其实存在很简单的套路：当求解的问题满足以下两个条件时， 就应该使用动态规划：
    - 主问题的答案 包含了 可分解的子问题答案 （也就是说，问题可以被递归的思想求解）
    - 递归求解时， 很多子问题的答案会被多次重复利用
- 动态规划的本质思想就是递归， 但如果直接应用递归方法， 子问题的答案会被重复计算产生浪费， 同时递归更加耗费栈内存， 所以通常用一个二维矩阵（表格）来表示不同子问题的答案， 以实现更加高效的求解。
- 

------

# Talk is cheap ,Show me the code

> 翻阅很多资料，貌似python描述的比较少，这里总结一下，用前面的图解中的伪代码重构下

## 背包问题

多谢[rubik_wong–0/1背包问题](http://blog.csdn.net/rubik_wong/article/details/54854547)，代码参考如下

```python
# 这里使用了图解中的吉他，音箱，电脑，手机做的测试，数据保持一致
w = [0, 1, 4, 3, 1]   #n个物体的重量(w[0]无用)
p = [0, 1500, 3000, 2000, 2000]   #n个物体的价值(p[0]无用)
n = len(w) - 1   #计算n的个数
m = 4   #背包的载重量

x = []   #装入背包的物体，元素为True时，对应物体被装入(x[0]无用)
v = 0
#optp[i][j]表示在前i个物体中，能够装入载重量为j的背包中的物体的最大价值
optp = [[0 for col in range(m + 1)] for raw in range(n + 1)]
#optp 相当于做了一个n*m的全零矩阵的赶脚，n行为物件，m列为自背包载重量

def knapsack_dynamic(w, p, n, m, x):
    #计算optp[i][j]
    for i in range(1, n + 1):       # 物品一件件来
        for j in range(1, m + 1):   # j为子背包的载重量，寻找能够承载物品的子背包
            if (j >= w[i]):         # 当物品的重量小于背包能够承受的载重量的时候，才考虑能不能放进去
                optp[i][j] = max(optp[i - 1][j], optp[i - 1][j - w[i]] + p[i])    # optp[i - 1][j]是上一个单元的值， optp[i - 1][j - w[i]]为剩余空间的价值
            else:
                optp[i][j] = optp[i - 1][j]

    #递推装入背包的物体,寻找跳变的地方，从最后结果开始逆推
    j = m
    for i in range(n, 0, -1):
        if optp[i][j] > optp[i - 1][j]:
            x.append(i)
            j = j - w[i]  

    #返回最大价值，即表格中最后一行最后一列的值
    v = optp[n][m]
    return v

print '最大值为：' + str(knapsack_dynamic(w, p, n, m, x))
print '物品的索引：',x

#最大值为：4000
#物品的索引： [4, 3]12345678910111213141516171819202122232425262728293031323334353637
```

## 优化背包问题的递归方法

> 参考自：[麻省理工的 背包算法 python](http://blog.sina.com.cn/s/blog_412158930101kogk.html)

```python
def MaxVal2(memo , w, v, index, last):  
    """ 
    得到最大价值 
    w为widght 
    v为value 
    index为索引 
    last为剩余重量 
    """  

    global numCount  
    numCount = numCount + 1  

    try:  
        #以往是否计算过分支，如果计算过，直接返回分支的结果  
        return memo[(index , last)]  
    except:  
        #最底部  
        if index == 0:  
            #是否可以装入  
            if w[index] <= last:  
                return v[index]  
            else:  
                return 0  

        #寻找可以装入的分支  
        without_l = MaxVal2(memo , w, v, index - 1, last)  

        #如果当前的分支大于约束  
        #返回历史查找的最大值  
        if w[index] > last:  
            return without_l  
        else:  
            #当前分支加入背包，剪掉背包剩余重量，继续寻找  
            with_l = v[index] + MaxVal2(memo , w, v , index - 1, last - w[index])  

        #比较最大值  
        maxvalue = max(with_l , without_l)  
        #存储  
        memo[(index , last)] = maxvalue  
        return maxvalue  

w = [0, 1, 4, 3, 1]   # 东西的重量 
v = [0, 1500, 3000, 2000, 2000]       # 东西的价值

numCount = 0  
memo = {} 
n = len(w) - 1
m = 4
print MaxVal2(memo , w, v, n, m) , "caculate count : ", numCount  


# 4000 caculate count :  2012345678910111213141516171819202122232425262728293031323334353637383940414243444546474849505152
```

------

## 优化斐波那契数列的递归方法

> 多谢[Python科学实验—-动态规划](http://www.bubuko.com/infodetail_150032.html),也就是对应上面的重叠子问题的方法，备忘录的递归方法

```python
#Dynamic Method Experiment
import matplotlib.pyplot as plt
count=0;
#blank
def f(n):
    global count
    count=count+1
    if n==1:
        return 1
    elif n==0:
        return 1
    else:
        return f(n-1)+f(n-2)


# function calls count
def calc_f(n):
    global count
    count=0
    f(n)
    return count

#using memorization
mem={}

def mem_f(n):
    global count,mem
    count=count+1
    if n in mem:
        return mem[n]
    else:
        if n==1:
            result=1
        elif n==0:
            result=1
        else:
            result=mem_f(n-1)+mem_f(n-2)
        mem[n]=result
        return result


def mem_calc_f(n):
    global count
    global mem
    mem={}
    count=0
    mem_f(n)
    return count  


x=range(1,15)
y=[]
y2=[]
for i in x:

    c=mem_calc_f(i)
    y.append(c)

    c2=calc_f(i)
    y2.append(c2)
    print "规模为%d时计算了%d次 i=%d时，val=%d"%(i,c,i,mem_f(i))
    print "规模为%d时计算了%d次 i=%d时，val=%d"%(i,c2,i,f(i))
plt.plot(x,y)
plt.plot(x,y2)
plt.show()1234567891011121314151617181920212223242526272829303132333435363738394041424344454647484950515253545556575859606162636465
```

![img](%E5%8A%A8%E6%80%81%E8%A7%84%E5%88%92DP.assets/240949446858361.png)

***它的基本思想就是记录已经计算过的值，避免重复计算。\***

> 如果使用装饰器的写法，则会优雅很多

```python
from functools import wraps

def memo(func):
    cache={}
    @wraps(func)
    def wrap(*args):
        if args not in cache:
            cache[args]=func(*args)
        return cache[args]
    return wrap

@memo
def fib(i):
    if i<2: return 1
    return fib(i-1)+fib(i-2)

fib(2)1234567891011121314151617
```

# 一些利用DP的笔试题

## CPU双核问题

> [网易笔试—动态规划](http://blog.csdn.net/shashakang/article/details/69099906): 题目的大概意思：一种双核CPU的两个核能够同时的处理任务，现在有n个已知数据量的任务需要交给CPU处理，假设已知CPU的每个核1秒可以处理1kb，每个核同时只能处理一项任务。n个任务可以按照任意顺序放入CPU进行处理，现在需要设计一个方案让CPU处理完这批任务所需的时间最少，求这个最小的时间。

输入包括两行：
第一行为整数n(1 ≤ n ≤ 50)
第二行为n个整数length[i](1024 ≤ length[i] ≤ 4194304)，表示每个任务的长度为length[i]kb，每个数均为1024的倍数。
输出一个整数，表示最少需要处理的时间。
问题实质是动态规划问题，把数组分成两部分，使得两部分的和相差最小。
如何将数组分成两部分使得两部分的和的差最小？参考博客http://www.tuicool.com/articles/ZF73Af
思路：
差值最小就是说两部分的和最接近，而且各部分的和与总和的一半也是最接近的。假设用sum1表示第一部分的和，sum2表示第二部分的和，SUM表示所有数的和，那么sum1+sum2=SUM。假设sum1

```python
w = [0, 3072, 3072, 7168, 3072, 1024]  # 假设进入处理的的任务大小
w = map(lambda x:x/1024,w)  # 转化下
p = w  # 这题的价值和任务重量一致
n = sum(w)/2 +1 # 背包承重为总任务的一半

optp = [[0 for j in range(n+1)] for i in range(len(w))]

for i in range(1,len(p)):
    for j in range(1,n+1):
        if j >= p[i]:
            optp[i][j] = max(optp[i-1][j],p[i]+optp[i-1][j-w[i]])
        else:
            optp[i][j] = optp[i-1][j]


print optp[-1][-1]
print optp
123456789101112131415161718
# 背包矩阵入下所示，第一列和第一行无效占位符
[[0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
 [0, 0, 0, 3, 3, 3, 3, 3, 3, 3], 
 [0, 0, 0, 3, 3, 3, 6, 6, 6, 6], 
 [0, 0, 0, 3, 3, 3, 6, 7, 7, 7], 
 [0, 0, 0, 3, 3, 3, 6, 7, 7, 9], 
 [0, 1, 1, 3, 4, 4, 6, 7, 8, 9]]
12345678
```

## LIS问题

> longest increasing subsequence问题，
>
> - 写的很棒，不再赘述[DP动态规划（Python实现）](http://www.deeplearn.me/216.html)

```
# 讲DP基本都会讲到的一个问题LIS：longest increasing subsequence
# http://www.deeplearn.me/216.html
lis = [2 ,1, 5, 3, 6 ,4 ,8 ,9, 7]

d = [1]*len(lis)
res = 1
for i in range(len(lis)):
    for j in range(i):
        if lis[j] <= lis[i] and d[i] < d[j]+1:
            d[i] = d[j]+1
        if d[j] >  res:
            res = d[j]
print res12345678910111213
```

## LCS问题

> 一个非常好的图解教程：[动态规划 最长公共子序列 过程图解](http://blog.csdn.net/hrn1216/article/details/51534607)

```Python
# 根据图解教程写的伪代码，其实最后评论里面的代码就是我添加上去的

s1 = [1,3,4,5,6,7,7,8]
s2 = [3,5,7,4,8,6,7,8,2]

d = [[0]*(len(s2)+1) for i in range(len(s1)+1) ]

for i in range(1,len(s1)+1):
    for j in range(1,len(s2)+1):
        if s1[i-1] == s2[j-1]:
            d[i][j] = d[i-1][j-1]+1
        else:
            d[i][j] = max(d[i-1][j],d[i][j-1])


print "max LCS number:",d[-1][-1]12345678910111213141516
```

## 给定一个有n个正整数的数组A和一个整数sum

 给定一个有n个正整数的数组A和一个整数sum,求选择数组A中部分数字和为sum的方案数。
当两种选取方案有一个数字的下标不一样,我们就认为是不同的组成方案。

### 输入描述:

```
输入为两行:

第一行为两个正整数n(1 ≤ n ≤ 1000)，sum(1 ≤ sum ≤ 1000)

第二行为n个正整数A[i](32位整数)，以空格隔开。12345
```

### 输出描述:

```
输出所求的方案数1
```

### 示例1

#### 输入

```
5 15
5 5 10 2 312
```

#### 输出

```python
41
#动态规划算法。dp[i][j]代表用前i个数字凑到j最多有多少种方案。 
#dp[i][j]=dp[i-1][j];   //不用第i个数字能凑到j的最多情况 
#dp[i][j]+=dp[i-1][j-value[i]];用了i时，只需要看原来凑到j-value[i]的最多情况即可。并累加 

num_ = 5
sum_ = 10
line = [5 ,5 ,10 ,2 ,3] 

optp = [[1]+[0]*sum_ for i in range(num_+1)]  # 第一列为1的原因是和为0的时候只有一种取法，就是什么都不取

for i in range(1,num_+1):
    for j in range(1,sum_+1):
        if j - line[i-1] >=0:
            optp[i][j] = optp[i-1][j] + optp[i-1][j-line[i-1]]
        else:
            optp[i][j] = optp[i-1][j]



print optp

    0   1  2  3  4  5  6  7  8  9 10
0  [[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
5   [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], 
5   [1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 1], 
10  [1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 2], 
2   [1, 0, 1, 0, 0, 2, 0, 2, 0, 0, 2], 
3   [1, 0, 1, 1, 0, 3, 0, 2, 2, 0, 4]]

# 转化为背包问题后，开始推，（注意第一行和第一列是预至位）比如说第一个数字是5，那么从构成和为1，怎么取？当然没得取，直到构成和为5的时候，开始执行，如果用这个5，那么还剩下5-5=0的和，0的和取法只有1，而如果不用5，取法只有0，所以为1，之后重复推，再说第二个5，直到和为5之前，都是0取法，到了5之后，两种取法，一种是要不要这个新的5，如果要这个新的5，那么剩下的和即5-5=0，一种取法，如果这个新的5不取，那以前能取到和为5就上次循环中的一种取法，所以合起来两种取法123456789101112131415161718192021222324252627282930
```

## 一个数组有 N 个元素，求连续子数组的最大和

一个数组有 N 个元素，求连续子数组的最大和。 例如：[-1,2,1]，和最大的连续子数组为[2,1]，其和为 3

### 输入描述:

```
输入为两行。
第一行一个整数n(1 <= n <= 100000)，表示一共有n个元素
第二行为n个数，即每个元素,每个整数都在32位int范围内。以空格分隔。123
```

### 输出描述:

```
所有连续子数组中和最大的值。1
```

### 示例1

#### 输入

```
3
-1 2 112
```

#### 输出

```
31
# 采用动态规划的方法
# 设dp[i]表示以第 i个元素为结尾的连续子数组的最大和，则递推方程式为 dp[i]=max{dp[i-1]+a[i], a[i]};

num = raw_input("")
line = raw_input("")
line = map(lambda x:int(x),line.split(" "))
num = int(num)

d =[0]*(num-1)
d.insert(0,line[0])

for i in range(1,num):

    d[i] = max(d[i-1]+line[i],line[i])

print max(d)12345678910111213141516
```

## X*Y的网格迷宫

> 有一个X*Y的网格，小团要在此网格上从左上角到右下角，只能走格点且只能向右或向下走。请设计一个算法，计算小团有多少种走法。给定两个正整数int x,int y，请返回小团的走法数目。

### 输入描述:

```
输入包括一行，逗号隔开的两个正整数x和y，取值范围[1,10]。1
```

### 输出描述:

```
输出包括一行，为走法的数目。1
```

### 示例1

#### 输入

```
3 21
```

#### 输出

```
101
# 动态规划，使用递推方程d[i][j] = d[i-1][j] + d[i][j-1]
# 因为可能从两个方向走到同一个点，所以从上到下为一种走法，从左到右是另一种走法
# 注意题目给的是x*y方格，所以是(x+1)*(y+1)个点


line = map(int, raw_input("").split(" "))
x = line[0]
y = line[1]

d = [[0]*(y+2) for i in range(x+2)]

for i in range(1,x+2):
    for j in range(1,y+2):
        if i==j and i==1:
            d[i][j] = 1
        else:
            d[i][j] = d[i-1][j] + d[i][j-1]

print d[-1][-1]12345678910111213141516171819
```

## 暗黑字符串

> 一个只包含’A’、’B’和’C’的字符串，如果存在某一段长度为3的连续子串中恰好’A’、’B’和’C’各有一个，那么这个字符串就是纯净的，否则这个字符串就是暗黑的。例如：
>
> BAACAACCBAAA 连续子串”CBA”中包含了’A’,’B’,’C’各一个，所以是纯净的字符串
>
> AABBCCAABB 不存在一个长度为3的连续子串包含’A’,’B’,’C’,所以是暗黑的字符串
>
> 你的任务就是计算出长度为n的字符串(只包含’A’、’B’和’C’)，有多少个是暗黑的字符串。

### 输入描述:

```
输入一个整数n，表示字符串长度(1 ≤ n ≤ 30)1
```

### 输出描述:

```
输出一个整数表示有多少个暗黑字符串1
```

### 示例1

#### 输入

```
31
```

#### 输出

```
211
```

### 思路解析

![img](%E5%8A%A8%E6%80%81%E8%A7%84%E5%88%92DP.assets/964976_1473736361531_560EE1C917735D766A0A56AC2EFBB34A.png)

```python
#方式二，这么low的方式是我根据上面的解析写的。递归所以速度慢
num = int(raw_input(""))

def dark(num):
    if num == 1:
        return 3
    elif num==2:
        return 9
    else:
        return 2*dark(num-1) + dark(num-2)

print dark(num)123456789101112
# 方式一：别人家的代码
n = int(raw_input())
dp = [0]*31
dp[0] = 3
dp[1] = 9
for i in xrange(2, n):
    dp[i] = 2*dp[i-1]+dp[i-2]

print dp[n-1]123456789
```

------

# 最后

> 纸上得来终觉浅，这句话放在什么时候都一样，自己觉得动态规划比较了解了，其实了解个屁，需要重新打打基础！以后再过来更新理解。

# 致谢

- [麻省理工的 背包算法 python](http://blog.sina.com.cn/s/blog_412158930101kogk.html)
- [Python科学实验—-动态规划](http://www.bubuko.com/infodetail_150032.html)
- [动态规划是什么，意义在哪里？！！！！](http://blog.csdn.net/w571523631/article/details/70132265)
- [python算法-动态规划](http://python.jobbole.com/81465/)
- [清晰解题： 网易笔试合唱团](http://blog.csdn.net/lengxiao1993/article/details/52305420)
- 《算法图解》pdf下载地址http://download.csdn.net/detail/wangtianqt/9800583
- [牛客网-暗黑的字符串](https://www.nowcoder.com/profile/8257440/codeBookDetail?submissionId=10478266)