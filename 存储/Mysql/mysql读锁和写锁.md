## MySQL中的读锁和写锁



在[数据库的锁机制](http://mp.weixin.qq.com/s?__biz=MzI3NzE0NjcwMg==&mid=401808854&idx=2&sn=2ab2388f28e86993ab0ab7b8b0c10cf5&scene=21#wechat_redirect)中介绍过，数据的锁主要用来保证数据的一致性的，数据库的锁从锁定的粒度上可以分为表级锁、[行级锁](http://mp.weixin.qq.com/s?__biz=MzI3NzE0NjcwMg==&mid=402330276&idx=1&sn=aa35ce5bdcfa659f4ee2f7890a46f479&scene=21#wechat_redirect)和页级锁。在我的博客中重点介绍过MySQL数据库的行级锁。这篇文章主要来介绍一下MySQL数据库中的表级锁。

> 本文提到的读锁和写锁都是MySQL数据库的MyISAM引擎支持的表锁的。而对于行级锁的共享读锁和互斥写锁请阅读[MySQL中的共享锁与排他锁](http://mp.weixin.qq.com/s?__biz=MzI3NzE0NjcwMg==&mid=402351172&idx=2&sn=a7b4ae968095d718643bb1875c16dffd&scene=21#wechat_redirect)。我习惯在描述表锁的时候按照读写来区分，在表述行锁的时候按照共享和互斥来区分。其实无论是表锁还是行锁。共享锁指的就是读锁！互斥锁、排他锁、独占锁值得都是写锁。

### 重点知识回顾

MySQL的锁机制比较简单，其最显著的特点是不同的存储引擎支持不同的锁机制。比如，MyISAM和MEMORY存储引擎采用的是表级锁(`table-level locking`);BDB 存储引擎采用的是页面锁(`page-level locking`)，但也支持表级锁;InnoDB存储引擎既支持行级锁(`row-level locking`)，也支持表级锁，但默认情况下是采用行级锁。

- 表级锁:开销小，加锁快;不会出现死锁;锁定粒度大，发生锁冲突的概率最高，并发度最低。
- 行级锁:开销大，加锁慢;会出现死锁;锁定粒度最小,发生锁冲突的概率最低，并发度也最高。
- 页面锁:开销和加锁时间界于表锁和行锁之间;会出现死锁;锁定粒度界于表锁和行锁之间，并发度一般。

### MyISAM表锁

MyISAM 存储引擎只支持表锁，MySQL 的表级锁有两种模式:**表共享读锁**(`Table Read Lock`)和**表独占写锁**(`Table Write Lock`)。

对于读操作，可以增加读锁，一旦数据表被加上读锁，其他请求可以对该表再次增加读锁，但是不能增加写锁。（当一个请求在读数据时，其他请求也可以读，但是不能写，因为一旦另外一个线程写了数据，就会导致当前线程读取到的数据不是最新的了。这就是不可重复读现象）

对于写操作，可以增加写锁，一旦数据表被加上写锁，其他请求无法在对该表增加读锁和写锁。（当一个请求在写数据时，其他请求不能执行任何操作，因为在当前事务提交之前，其他的请求无法看到本次修改的内容。这有可能产生脏读、不可重复读和幻读）

读锁和写锁都是阻塞锁。

**如果t1对数据表增加了写锁，这是t2请求对数据表增加写锁，这时候t2并不会直接返回，而是会一直处于阻塞状态，直到t1释放了对表的锁，这时t2便有可能加锁成功，获取到结果。**

### 表锁的加锁/解锁方式

MyISAM 在执行查询语句(`SELECT`)前,会自动给涉及的所有表加读锁,在执行更新操作 (`UPDATE`、`DELETE`、`INSERT` 等)前，会自动给涉及的表加写锁，这个过程并不需要用户干预，因此，用户一般不需要直接用`LOCK TABLE`命令给MyISAM表显式加锁。

如果用户想要显示的加锁可以使用以下命令：

```
锁定表：LOCK TABLES tbl_name {READ | WRITE},[ tbl_name {READ | WRITE},…] 

解锁表：UNLOCK TABLES 
```

> 在用 `LOCK TABLES` 给表显式加表锁时,必须同时取得所有涉及到表的锁。
>
> 在执行 `LOCK TABLES` 后，只能访问显式加锁的这些表，不能访问未加锁的表;
>
> 如果加的是读锁，那么只能执行查询操作，而不能执行更新操作。
>
> 在自动加锁的情况下也基本如此，MyISAM 总是一次获得 SQL 语句所需要的全部锁。这也正是 MyISAM 表不会出现死锁(Deadlock Free)的原因。

对表test_table增加读锁：

```
LOCK TABLES test_table READ
UNLOCK test_table
```

对表test_table增加写锁

```
LOCK TABLES test_table WRITE
UNLOCK test_table
```

> - 当使用 LOCK TABLES 时,不仅需要一次锁定用到的所有表,而且,同一个表在 SQL 语句中出现多少次,就要通过与 SQL 语句中相同的别名锁定多少次,否则也会出错!

比如如下SQL语句：

```
select a.first_name,b.first_name, from actor a,actor b where a.first_name = b.first_name;
```

该Sql语句中，actor表以别名的方式出现了两次，分别是a,b，这时如果要在该Sql执行之前加锁就要使用以下Sql:

```
lock table actor as a read,actor as b read;
```

### 并发插入

上文 到过 MyISAM 表的读和写是串行的,但这是就总体而言的。在一定条件下,MyISAM表也支持查询和插入操作的并发进行。 MyISAM存储引擎有一个系统变量`concurrent_insert`,专门用以控制其并发插入的行为,其值分别可以为0、1或2。

> 当concurrent_insert设置为0时,不允许并发插入。
>
> 当concurrent_insert设置为1时,如果MyISAM表中没有空洞(即表的中间没有被删除的 行),MyISAM允许在一个进程读表的同时,另一个进程从表尾插入记录。这也是MySQL 的默认设置。
>
> 当concurrent_insert设置为2时,无论MyISAM表中有没有空洞,都允许在表尾并发插入记录。

可以利用MyISAM存储引擎的并发插入特性,来解决应用中对同一表查询和插入的锁争用。

### MyISAM的锁调度

前面讲过,MyISAM 存储引擎的读锁和写锁是互斥的,读写操作是串行的。那么,一个进程请求某个 MyISAM 表的读锁,同时另一个进程也请求同一表的写锁,MySQL 如何处理呢? 

答案是**写进程先获得锁**。

不仅如此,即使读请求先到锁等待队列,写请求后到,写锁也会插到读锁请求之前!这是因为 MySQL 认为写请求一般比读请求要重要。这也正是 MyISAM 表不太适合于有大量更新操作和查询操作应用的原因,因为,大量的更新操作会造成查询操作很难获得读锁,从而可能永远阻塞。这种情况有时可能会变得非常糟糕!

幸好我们可以通过 一些设置来调节 MyISAM 的调度行为。

> 通过指定启动参数low-priority-updates,使MyISAM引擎默认给予读请求以优先的权利。 
>
> 通过执行命令SET LOW*PRIORITY*UPDATES=1,使该连接发出的更新请求优先级降低。 
>
> 通过指定INSERT、UPDATE、DELETE语句的LOW_PRIORITY属性,降低该语句的优先级。

另外,MySQL也 供了一种折中的办法来调节读写冲突,即给系统参数`max_write_lock_count` 设置一个合适的值,当一个表的读锁达到这个值后,MySQL就暂时将写请求的优先级降低, 给读进程一定获得锁的机会。

### 总结

数据库中的锁从锁定的粒度上分可以分为行级锁、页级锁和表级锁。

MySQL的MyISAM引擎支持表级锁。

表级锁分为两种：共享读锁、互斥写锁。这两种锁都是阻塞锁。

可以在读锁上增加读锁，不能在读锁上增加写锁。在写锁上不能增加写锁。

默认情况下，MySql在执行查询语句之前会加读锁，在执行更新语句之前会执行写锁。

如果想要显示的加锁/解锁的花可以使用`LOCK TABLES`和`UNLOCK`来进行。

在使用`LOCK TABLES`之后，在解锁之前，不能操作未加锁的表。

在加锁时，如果显示的指明是要增加读锁，那么在解锁之前，只能进行读操作，不能执行写操作。

如果一次Sql语句要操作的表以别名的方式多次出现，那么就要在加锁时都指明要加锁的表的别名。

MyISAM存储引擎有一个系统变量`concurrent_insert`,专门用以控制其并发插入的行为,其值分别可以为0、1或2。

由于读锁和写锁互斥，那么在调度过程中，默认情况下，MySql会本着写锁优先的原则。可以通过`low-priority-updates`来设置。

### 参考资料

《深入浅出MySQL》



相关推荐

[[初级\]深入理解乐观锁与悲观锁](http://mp.weixin.qq.com/s?__biz=MzI3NzE0NjcwMg==&mid=402387528&idx=1&sn=cbd6bacd77a731298cb4356df8183ec3&scene=21#wechat_redirect)

[乐观锁的一种实现方式——CAS](http://mp.weixin.qq.com/s?__biz=MzI3NzE0NjcwMg==&mid=2650120412&idx=1&sn=bbf5f5a17a27bd76ac9c47befe501338&scene=21#wechat_redirect)

[MySQL中的共享锁与排他锁](http://mp.weixin.qq.com/s?__biz=MzI3NzE0NjcwMg==&mid=402351172&idx=2&sn=a7b4ae968095d718643bb1875c16dffd&scene=21#wechat_redirect)

[Mysql中的行级锁、表级锁、页级锁](http://mp.weixin.qq.com/s?__biz=MzI3NzE0NjcwMg==&mid=402330276&idx=1&sn=aa35ce5bdcfa659f4ee2f7890a46f479&scene=21#wechat_redirect)

[数据库的读现象浅析](http://mp.weixin.qq.com/s?__biz=MzI3NzE0NjcwMg==&mid=402312019&idx=3&sn=f4ee9d0c24ebbe35f8376fee3c53c948&scene=21#wechat_redirect)