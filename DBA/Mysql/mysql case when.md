# mysql case when

------



# SQL:select case when

> CASE 可能是 SQL 中被误用最多的关键字之一。虽然你可能以前用过这个关键字来创建字段，但是它还具有更多用法。例如，你可以在 WHERE 子句中使用 CASE。 首先让我们看一下 CASE 的语法。在一般的 SELECT 中，其语法如下：

```sql
SELECT <myColumnSpec> =
CASE
WHEN <A> THEN <somethingA>
WHEN <B> THEN <somethingB>
ELSE <somethingE>
END  
```

> 在上面的代码中需要用具体的参数代替尖括号中的内容。下面是一个简单的例子：

```sql
USE pubs
GO
SELECT
    Title,
    'Price Range' =
    CASE
        WHEN price IS NULL THEN 'Unpriced'
        WHEN price < 10 THEN 'Bargain'
        WHEN price BETWEEN 10 and 20 THEN 'Average'
        ELSE 'Gift to impress relatives'
    END
FROM titles
ORDER BY price
GO  
```


这是 CASE 的典型用法，但是使用 CASE 其实可以做更多的事情。比方说下面的 GROUP BY 子句中的 CASE：

```sql
SELECT 'Number of Titles', Count(*)
FROM titles
GROUP BY
    CASE
        WHEN price IS NULL THEN 'Unpriced'
        WHEN price < 10 THEN 'Bargain'
        WHEN price BETWEEN 10 and 20 THEN 'Average'
        ELSE 'Gift to impress relatives'
    END
GO  
```



> 你甚至还可以组合这些选项，添加一个 ORDER BY 子句，如下所示：

```sql
USE pubs
GO
SELECT
    CASE
        WHEN price IS NULL THEN 'Unpriced'
        WHEN price < 10 THEN 'Bargain'
        WHEN price BETWEEN 10 and 20 THEN 'Average'
        ELSE 'Gift to impress relatives'
    END AS Range,
    Title
FROM titles
GROUP BY
    CASE
        WHEN price IS NULL THEN 'Unpriced'
        WHEN price < 10 THEN 'Bargain'
        WHEN price BETWEEN 10 and 20 THEN 'Average'
        ELSE 'Gift to impress relatives'
    END,
    Title
ORDER BY
    CASE
        WHEN price IS NULL THEN 'Unpriced'
        WHEN price < 10 THEN 'Bargain'
        WHEN price BETWEEN 10 and 20 THEN 'Average'
        ELSE 'Gift to impress relatives'
    END,
    Title
GO  
```



> 注意，为了在 GROUP BY 块中使用 CASE，查询语句需要在 GROUP BY 块中重复 SELECT 块中的 CASE 块。 除了选择自定义字段之外，在很多情况下 CASE 都非常有用。再深入一步，你还可以得到你以前认为不可能得到的分组排序结果集