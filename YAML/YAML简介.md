# YAML 语法

YAML语言的设计参考了JSON，XML和SDL等语言。YAML 强调以**数据为中心**,简洁易读,编写简单。

**有意思的命名：**

YAML全称是”YAML Ain’t a Markup Language”（YAML不是一种置标语言）的递归缩写。 在开发的这种语言时，YAML 的意思其实是：”Yet Another Markup Language”（仍是一种置标语言）。

## 语法特点

- 大小写敏感
- 通过缩进表示层级关系
- **禁止使用tab缩进，只能使用空格键** （个人感觉这条最重要）
- 缩进的空格数目不重要，只要相同层级左对齐即可
- 使用#表示注释

## 支持的数据结构

- 对象：键值对的集合，又称为映射（mapping）/ 哈希（hashes） / 字典（dictionary）
- 数组：一组按次序排列的值，又称为序列（sequence） / 列表（list）
- 纯量（scalars）：单个的、不可再分的值

## 双引号和单引号的区分

双引号`""`：不会转义字符串里面的特殊字符，特殊字符作为本身想表示的意思。

```
name: "123\n123"
---------------------------
输出： 123 换行 123
```

如果`不加引号`将会转义特殊字符，当成字符串处理

## 值的写法

### **1.字符串**

使用”或”“或不使用引号

```
value0: 'hello World!'
value1: "hello World!"
value2: hello World!
```

### **2.布尔值**

`true`或`false`表示。

### **3.数字**

```
12 #整数 
014 # 八进制整数 
0xC ＃十六进制整数 
13.4 ＃浮点数 
1.2e+34 ＃指数 
.inf空值 ＃无穷大
```

### **4.空值**

`null`或`~`表示

### **5.日期**

使用 iso-8601 标准表示日期

```
date: 2018-01-01t16:59:43.10-05:00
```

**在springboot中yaml文件的时间格式 date: yyyy/MM/dd HH:mm:ss**

### **6.强制类型转换(了解)**

YAML 允许使用个感叹号`!`，强制转换数据类型，`单叹号`通常是自定义类型，`双叹号`是内置类型。

```
money: !!str
123
date: !Boolean
true
```

**内置类型列表**

```
!!int # 整数类型 
!!float # 浮点类型 
!!bool # 布尔类型 
!!str # 字符串类型 
!!binary # 也是字符串类型 
!!timestamp # 日期时间类型 
!!null # 空值 
!!set # 集合 
!!omap,!!pairs # 键值列表或对象列表
!!seq # 序列，也是列表 !!map # 键值表
```

### 7.对象（重点）

Map（属性和值）（键值对）的形式： key:(空格)v ：表示一堆键值对，空格不可省略。

```
car:
    color: red
    brand: BMW
```

一行写法

```
car:{color: red，brand: BMW}
```

相当于JSON格式：

```
{"color":"red","brand":"BMW"}
```

### 8.数组

一组连词线开头的行，构成一个数组。

```
brand:
   - audi
   - bmw
   - ferrari
```

一行写法

```
brand: [audi,bmw,ferrari]
```

相当于JSON

```
["auri","bmw","ferrari"]
```

------

### 9.**文本块**

|：使用`|`标注的文本内容缩进表示的块，可以保留块中已有的回车换行

```
value: |
   hello
   world!
输出结果：hello 换行 world！
```

`+`表示保留文字块末尾的换行，`-`表示删除字符串末尾的换行。

```
value: |
hello

value: |-
hello

value: |+
hello
输出：hello\n hello hello\n\n(有多少个回车就有多少个\n)
```

**注意 “|” 与 文本之间须另起一行**

\>：使用 `>` 标注的文本内容缩进表示的块，将块中回车替换为空格，最终连接成一行

```
value: > hello
world!
输出：hello 空格 world！
```

**注意 “>” 与 文本之间的空格**

### 10.**锚点与引用**

使用 `&` 定义数据锚点（即要复制的数据），使用 `*` 引用锚点数据（即数据的复制目的地）

```
name: &a yaml
book: *a
books: 
   - java
   - *a
   - python
输出book： yaml 
输出books：[java,yaml,python]
```

**注意\*引用部分不能追加内容**

------

## 配置文件注入数据

```
/**
 * 将配置文件中配置的每一个属性的值，映射到这个组件中
 * @ConfigurationProperties：告诉SpringBoot将本类中的所有属性和配置文件中相关的配置进行绑定；
 *      prefix = "person"：配置文件中哪个下面的所有属性进行一一映射
 *
 * 只有这个组件是容器中的组件，才能容器提供的@ConfigurationProperties功能；
 *
 */
@Component //实例化
@ConfigurationProperties(prefix = "person")//yaml或者properties的前缀
public class Person {

    private String name;
    private Integer age;
    private Boolean flag;
    private Date birthday;
    private Map<String,Object> maps;
    private List<Object> tempList;
    private Dog dog;
    //省略getter和setter以及toString方法
```

我们可以导入配置文件处理器，以后编写配置就有提示了，`@ConfigurationProperties`IDE会提示打开在线的帮助文档，配置依赖如下：

```
<!--导入配置文件处理器，配置文件进行绑定就会有提示-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

### application.yaml文件

```
person:
  name: 胖先森
  age: 18
  flag: false
  birthday: 2018/12/19 20:21:22 #Spring Boot中时间格式
  maps: {bookName: "西游记",author: '吴承恩'}
  tempList:
    - 红楼梦
    - 三国演义
    - 水浒传
  dog:
    dogName: 大黄
    dogAge: 4
```

在test中进行测试如下

```
@RunWith(SpringRunner.class)
@SpringBootTest
public class Demo03BootApplicationTests {

    @Autowired
    private Person p1;

    @Test
    public void contextLoads() {
        System.out.println(p1);
    }

}
```

输出结果为：`Person{name='胖先森', age=18, flag=false, birthday=Wed Dec 19 20:21:22 CST 2018, maps={bookName=西游记, author=吴承恩}, tempList=[红楼梦, 三国演义, 水浒传], dog=Dog{dogName='大黄', dogAge=4}}`

### application.properties文件

```
person123.name=刘备
person123.age=20
person123.birthday=2018/12/19 20:21:22
person123.maps.bookName=水浒传
person123.maps.author=罗贯中
person123.temp-list=一步教育,步步为赢
person123.dog.dogName=小白
person123.dog.dogAge=5
```

java代码修改前缀

```
@Component //实例化
@ConfigurationProperties(prefix = "person123")//yaml或者properties的前缀
public class Person {

    private String name;
    private Integer age;
    private Boolean flag;
    private Date birthday;
    private Map<String,Object> maps;
    private List<Object> tempList;
    private Dog dog;
    //省略getter和setter以及toString方法
```

在test中进行测试如下

```
@RunWith(SpringRunner.class)
@SpringBootTest
public class Demo03BootApplicationTests {

    @Autowired
    private Person p1;

    @Test
    public void contextLoads() {
        System.out.println(p1);
    }

}
```

输出结果为：`Person{name='ï¿½ï¿½ï¿½ï¿½', age=20, flag=null, birthday=Wed Dec 19 20:21:22 CST 2018, maps={bookName=Ë®ä°´ï¿½, author=ï¿½Þ¹ï¿½ï¿½ï¿½}, tempList=[Ò»ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½, ï¿½ï¿½ï¿½ï¿½ÎªÓ®], dog=Dog{dogName='Ð¡ï¿½ï¿½', dogAge=5}}`

属性文件中文乱码问题



![img](https://user-gold-cdn.xitu.io/2018/12/19/167c6b1648f25c1f?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)