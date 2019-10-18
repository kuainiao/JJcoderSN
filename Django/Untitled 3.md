# Django学习之ORM练习题

2019-08-03 10:51:14  阅读：24  来源： **互联网**



**标签：**[练习题](https://www.icode9.com/tags-练习题-0.html) [ORM](https://www.icode9.com/tags-ORM-0.html) [SMS](https://www.icode9.com/tags-SMS-0.html) [Django](https://www.icode9.com/tags-Django-0.html) [course](https://www.icode9.com/tags-course-0.html) [score](https://www.icode9.com/tags-score-0.html) [student](https://www.icode9.com/tags-student-0.html) [classes](https://www.icode9.com/tags-classes-0.html) [id](https://www.icode9.com/tags-id-0.html)





创建表关系，并创建约束

|                       |            |           |       |                 |                     |            |          |
| --------------------- | ---------- | --------- | ----- | --------------- | ------------------- | ---------- | -------- |
| 班级表：class         |            |           |       | 学生表：student |                     |            |          |
| cid                   | caption    | grade_id  |       | sid             | sname               | gender     | class_id |
| 1                     | 一年一班   | 1         |       | 1               | 乔丹                | 女         | 1        |
| 2                     | 二年一班   | 2         |       | 2               | 艾弗森              | 女         | 1        |
| 3                     | 三年二班   | 3         |       | 3               | 科比                | 男         | 2        |
|                       |            |           |       |                 |                     |            |          |
| 老师表：teacher       |            |           |       | 课程表：course  |                     |            |          |
| tid                   | tname      |           |       | cid             | cname               | teacher_id |          |
| 1                     | 张三       |           |       | 1               | 生物                | 1          |          |
| 2                     | 李四       |           |       | 2               | 体育                | 1          |          |
| 3                     | 王五       |           |       | 3               | 物理                | 2          |          |
|                       |            |           |       |                 |                     |            |          |
| 成绩表：score         |            |           |       |                 | 年级表：class_grade |            |          |
| sid                   | student_id | course_id | score |                 | gid                 | gname      |          |
| 1                     | 1          | 1         | 60    |                 | 1                   | 一年级     |          |
| 2                     | 1          | 2         | 59    |                 | 2                   | 二年级     |          |
| 3                     | 2          | 2         | 99    |                 | 3                   | 三年级     |          |
|                       |            |           |       |                 |                     |            |          |
| 班级任职表：teach2cls |            |           |       |                 |                     |            |          |
| tcid                  | tid        | cid       |       |                 |                     |            |          |
| 1                     | 1          | 1         |       |                 |                     |            |          |
| 2                     | 1          | 2         |       |                 |                     |            |          |
| 3                     | 2          | 1         |       |                 |                     |            |          |
| 4                     | 3          | 2         |       |                 |                     |            |          |

## **二.****创建测试数据**

### **1.****创建项目****准备环境**

步骤:

(1)在终端使用mkvirtualenv命令创建一个新的虚拟环境,然后使用pip3命令下载安装django

mkvirtualenv ORMtest -p python3

pip3 install django

(2)使用django-admin命令创建django项目

django-admin startproject ORMtest

(3)在pycharm打开该项目,配置python编译器

(4)在pycharm的终端使用startapp新建子应用

python3 manage.py startapp SMS

(5)在配置文件settings.py中注册新建的子应用SMS

\# Application definition

 

INSTALLED_APPS = [

​    'django.contrib.admin',

​    'django.contrib.auth',

​    'django.contrib.contenttypes',

​    'django.contrib.sessions',

​    'django.contrib.messages',

​    'django.contrib.staticfiles',

​    'SMS.apps.SmsConfig',  # <---注册新应用

]

### **2.创建模型**

步骤:

(1)在子应用SMS文件内的模型文件models.py中创建模型类

![img](https://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)

```
from django.db import models

# Create your models here.
class Classes(models.Model):
    cid = models.AutoField(primary_key=True)
    caption = models.CharField(max_length=32)
    grade = models.ForeignKey("ClassGrade", on_delete=models.CASCADE)


class ClassGrade(models.Model):
    gid = models.AutoField(primary_key=True)
    gname = models.CharField(max_length=32)


class Student(models.Model):
    sid = models.AutoField(primary_key=True)
    sname = models.CharField(max_length=32)
    gender_choice = ((0, "女"), (1, "男"))
    gender = models.SmallIntegerField(choices=gender_choice, default=1)
    classes = models.ForeignKey("Classes", on_delete=models.CASCADE)


class Teacher(models.Model):
    tid = models.AutoField(primary_key=True)
    tname = models.CharField(max_length=32)
    classes = models.ManyToManyField("Classes")


class Course(models.Model):
    cid = models.AutoField(primary_key=True)
    cname = models.CharField(max_length=32)
    teacher = models.ForeignKey("Teacher", on_delete=models.CASCADE)


class Score(models.Model):
    sid = models.AutoField(primary_key=True)
    student = models.ForeignKey("Student", on_delete=models.CASCADE)
    course = models.ForeignKey('Course', on_delete=models.CASCADE)
    score = models.IntegerField()
```

models.

(2)执行数据库迁移命令

```
python3 manage.py makemigrations
python3 manage.py migrate
```

### **3.添加数据**

(1)班级表

```
INSERT INTO SMS_classes (cid, caption, grade_id) VALUES (1, '一年1班', 1);
INSERT INTO SMS_classes (cid, caption, grade_id) VALUES (2, '一年2班', 1);
INSERT INTO SMS_classes (cid, caption, grade_id) VALUES (3, '二年1班', 2);
INSERT INTO SMS_classes (cid, caption, grade_id) VALUES (4, '二年2班', 2);
INSERT INTO SMS_classes (cid, caption, grade_id) VALUES (5, '三年1班', 3);
INSERT INTO SMS_classes (cid, caption, grade_id) VALUES (6, '三年2班', 3);
INSERT INTO SMS_classes (cid, caption, grade_id) VALUES (7, '三年3班', 3);
INSERT INTO SMS_classes (cid, caption, grade_id) VALUES (8, '四年1班', 4);
```

(2)年级表

```
INSERT INTO SMS_classgrade (gid, gname) VALUES (1, '一年级');
INSERT INTO SMS_classgrade (gid, gname) VALUES (2, '二年级');
INSERT INTO SMS_classgrade (gid, gname) VALUES (3, '三年级');
INSERT INTO SMS_classgrade (gid, gname) VALUES (4, '四年级');
```

(3)学生表

```
INSERT INTO SMS_student (sid, sname, classes_id, gender) VALUES (1, '张无忌', 2, 1);
INSERT INTO SMS_student (sid, sname, classes_id, gender) VALUES (2, '赵敏', 1, 0);
INSERT INTO SMS_student (sid, sname, classes_id, gender) VALUES (3, '令狐冲', 3, 1);
INSERT INTO SMS_student (sid, sname, classes_id, gender) VALUES (4, '任盈盈', 4, 0);
INSERT INTO SMS_student (sid, sname, classes_id, gender) VALUES (5, '方世玉', 5, 1);
INSERT INTO SMS_student (sid, sname, classes_id, gender) VALUES (6, '张飞', 6, 1);
INSERT INTO SMS_student (sid, sname, classes_id, gender) VALUES (7, '武松', 8, 1);
INSERT INTO SMS_student (sid, sname, classes_id, gender) VALUES (8, '鲁智深', 7, 1);
INSERT INTO SMS_student (sid, sname, classes_id, gender) VALUES (9, '金莲', 6, 0);
INSERT INTO SMS_student (sid, sname, classes_id, gender) VALUES (10, '西门庆', 8, 1);
INSERT INTO SMS_student (sid, sname, classes_id, gender) VALUES (11, '林冲', 7, 1);
```

(4)教师表

```
INSERT INTO SMS_teacher (tid, tname) VALUES (1, '乔峰');
INSERT INTO SMS_teacher (tid, tname) VALUES (2, '任盈盈');
INSERT INTO SMS_teacher (tid, tname) VALUES (3, '任我行');
INSERT INTO SMS_teacher (tid, tname) VALUES (4, '岳不群');
INSERT INTO SMS_teacher (tid, tname) VALUES (5, '唐僧');
```

(5)课程表

```
INSERT INTO SMS_course (cid, cname, teacher_id) VALUES (1, '物理', 3);
INSERT INTO SMS_course (cid, cname, teacher_id) VALUES (2, '生物', 1);
INSERT INTO SMS_course (cid, cname, teacher_id) VALUES (3, '语文', 5);
INSERT INTO SMS_course (cid, cname, teacher_id) VALUES (4, '数学', 4);
INSERT INTO SMS_course (cid, cname, teacher_id) VALUES (5, '日语', 1);
INSERT INTO SMS_course (cid, cname, teacher_id) VALUES (6, '体育', 2);
```

(6)成绩表

```
INSERT INTO SMS_score (sid, score, course_id, student_id) VALUES (1, 80, 1, 2);
INSERT INTO SMS_score (sid, score, course_id, student_id) VALUES (2, 60, 1, 3);
INSERT INTO SMS_score (sid, score, course_id, student_id) VALUES (3, 72, 2, 1);
INSERT INTO SMS_score (sid, score, course_id, student_id) VALUES (4, 58, 3, 1);
INSERT INTO SMS_score (sid, score, course_id, student_id) VALUES (5, 91, 4, 5);
INSERT INTO SMS_score (sid, score, course_id, student_id) VALUES (6, 84, 5, 5);
INSERT INTO SMS_score (sid, score, course_id, student_id) VALUES (7, 78, 6, 8);
INSERT INTO SMS_score (sid, score, course_id, student_id) VALUES (8, 82, 4, 7);
INSERT INTO SMS_score (sid, score, course_id, student_id) VALUES (9, 87, 4, 6);
INSERT INTO SMS_score (sid, score, course_id, student_id) VALUES (10, 57, 2, 3);
INSERT INTO SMS_score (sid, score, course_id, student_id) VALUES (11, 68, 3, 2);
insert into SMS_score (sid, score, course_id, student_id) values (12, 73, 2, 2);
```

(7)班级任职表

```
INSERT INTO SMS_teacher_classes (id, teacher_id, classes_id) VALUES (1, 1, 8);
INSERT INTO SMS_teacher_classes (id, teacher_id, classes_id) VALUES (2, 1, 7);
INSERT INTO SMS_teacher_classes (id, teacher_id, classes_id) VALUES (3, 1, 6);
INSERT INTO SMS_teacher_classes (id, teacher_id, classes_id) VALUES (4, 2, 5);
INSERT INTO SMS_teacher_classes (id, teacher_id, classes_id) VALUES (5, 3, 4);
INSERT INTO SMS_teacher_classes (id, teacher_id, classes_id) VALUES (6, 3, 5);
INSERT INTO SMS_teacher_classes (id, teacher_id, classes_id) VALUES (7, 4, 4);
INSERT INTO SMS_teacher_classes (id, teacher_id, classes_id) VALUES (8, 5, 3);
INSERT INTO SMS_teacher_classes (id, teacher_id, classes_id) VALUES (9, 2, 2);
INSERT INTO SMS_teacher_classes (id, teacher_id, classes_id) VALUES (10, 3, 1);
INSERT INTO SMS_teacher_classes (id, teacher_id, classes_id) VALUES (11, 4, 1);
```

## **三．习题与答案解析**

 

1.查询学生总人数；

思路:直接查,然后用聚合函数Count计算学生个数

SQL:

​    select count(sid) from student

Python:

​    res = Student.objects.all().count()

​    res = Student.objects.aggregate(Count('sid'))

 

2.查询“生物”课程和“物理”课程成绩都及格的学生id和姓名；

思路:先过滤出生物或者物理成绩大于60的学生,然后按照学生id分组,

统计课程id大于1的,即为都及格的学生

SQL:

​    (1)select cid from SMS_course where cname in ('生物','物理')

​    (2)select student_id from SMS_score where cid in(...) AND

score >= 60 GROUP BY student_id HAVING COUNT(score)>1

​    (3)select sid, sname from SMS_student where sid in(...)

Python:

​    res = Score.objects.filter(course__cname__in=['生物', '物理'],

score__gte=60).values('student_id').annotate(c=Count('student_id')).

filter(c__gt=1).values('student_id', 'student__sname')

 

3.查询每个年级的班级数，取出班级数最多的前三个年级；

思路:按年级分组,统计每个年级的总班级数,根据班级数降序排列,取前三个年级

SQL:

​    (1)select count(cid) as num, grade_id from SMS_classes group by grade_id

order by num DESC limit 3;

​    (2)select gname, num from(...)as t2 left join SMS_classgrade on t2.grade_id=gid;

Python:

​    res = Classes.objects.values('grade_id').annotate(num=Count('cid')).order_by

('-num').values('grade__gname','num')[:3]

 

4.查询平均成绩最高的学生的id和姓名以及平均成绩；

思路:按照学生id进行分组,统计每个学生的平均成绩,然后根据成绩降序排列,取第一个

SQL:

​    (1)select student_id,avg(score)as avg_score from SMS_score group by student_id

order by avg_score desc limit 1;

​    (2)select sid,sname,avg_score from(...)left join SMS_student on student_id=sid

Python:

​    res = Score.objects.values('student_id', 'student__sname').annotate

(avg_score=Avg('score')).order_by('-avg_score')[0]

 

5.查询每个年级的学生人数；

思路:按照年级分组,跨表统计学生人数

SQL:

​    (1)select count(sid) from SMS_classes left join SMS_student Ss

on SMS_classes.cid = Ss.classes_id group by grade_id;

​    (2)select gname, total from(...)left join SMS_classgrade on gid=grade_id;

Python:

​    res = Student.objects.values('classes__grade__gid',

'classes__grade__gname').annotate(total=Count('sid'))

 

6.查询每位学生的学号，姓名, 平均成绩；

思路:按照学生分组,统计平均成绩

SQL:

​    select SMS_student.sid,sname,avg(score)as avg_score from

SMS_student left join SMS_score Ss on SMS_student.sid =

Ss.student_id group by SMS_student.sid;

Python:

​    res = Score.objects.values('student_id','student__sname').

annotate(avg_score=Avg('score'))

 

7.查询学生编号为“2”的学生的姓名、该学生成绩最高的课程名及分数；

思路:先按pk值过滤出该学生,然后按照成绩排序取出成绩最高值的学科

SQL:

​    (1)select sid, sname from SMS_student where sid=2;

​    (2)select * from(...)as s2 left join SMS_score on s2.sid=student_id

order by score desc limit 1;

​    (3)select sid,sname,cname,score from(...) left join SMS_course on course_id=cid;

Python:

​    res = Student.objects.filter(pk=2).values('sid', 'sname', 'score__course__cname',

'score__score').order_by('-score__score')[0]

 

8.查询姓“任”的老师所带班级数；

思路:先过滤除姓任的老师,然后根据老师的任职表统计出班级数

SQL:

​    (1)select * from SMS_teacher where tname like '任%'

​    (2)select tid,tname,count(classes_id)as class_count from (...)left join

SMS_teacher_classes on tid=teacher_id group by tid

Python:

​    res = Teacher.objects.filter(tname__startswith='任').

values('tname').annotate(class_count=Count('classes'))

 

 

9.查询班级数小于3的年级id和年级名；

思路:先按年级进行分组,得到每个年级的班级数,再按条件进行过滤即可

SQL:

​    (1)select * from SMS_classes group by grade_id having count(cid)<3;

​    (2)select gid,gname,class_count from(...)left join SMS_classgrade

on grade_id=gid;

Python:

​    res = Classes.objects.values('grade_id', 'grade__gname').

annotate(class_count=Count('cid')).filter(class_count__lt=3)

 

 

10.查询教过课程超过2门的老师的id和姓名；

思路:按照老师分组,统计出所教的课程数,进行过滤即可

SQL:

​    (1)select teacher_id,count(cid)as course_count from SMS_course

group by teacher_id having count(cid)>=2;

(2)select tid,tname,course_count from(...)left join SMS_teacher on teacher_id=tid;

Python:

​    res = Course.objects.values('teacher__tid', 'teacher__tname').

annotate(course_count=Count('cid')).filter(course_count__gte=2)

 

 

11.查询学过编号“1”课程和编号“2”课程的同学的学号、姓名；

思路:先过滤出学过1或者学过2课程的同学,然后按照学生分组,统计课程数大于1的学生即是都学过的学生

SQL:

​    (1)select student_id from SMS_score where course_id in (1,2)

group by student_id having course_count=2;

​    (2)select sid, sname, course_count from(...)left join SMS_student on student_id=sid;

Python:

​    res = Score.objects.filter(course_id__in=[1,2]).values('student_id','student__sname').

annotate(course_count=Count('course_id')).filter(course_count=2)

 

 

12.查询所带班级数最多的老师id和姓名；

思路:先按老师进行分组,统计出每个老师所带的班级数,

按照所带班级数进行降序排列然后取第一个即可

SQL:

​    (1)select teacher_id,count(classes_id)as course_count from SMS_teacher_classes

group by teacher_id order by count(classes_id) desc;

​    (2)select tid,tname,course_count from(...)left join SMS_teacher on teacher_id=tid;

Python:

​    res = Teacher.objects.values('tid', 'tname').annotate(

class_count=Count('classes')).order_by('-class_count')[0]

 

13.查询有课程成绩小于60分的同学的学号、姓名；

思路:在成绩表中先过滤出成绩小于60的同学,然后去重即可

SQL:

​    1.select student_id, score from SMS_score where score<60;

​    2.select sid,sname,score from(...)left join SMS_student on student_id=sid;

Python:

​    res = Score.objects.filter(score__lt=60).values('student__sid',

'student__sname', 'score').distinct()

 

14.查询男生、女生的人数，按倒序排列；

思路:先按性别进行分组,进行计数,最后按降序排列即可

SQL:

​    select gender, count(sid)as gender_count from SMS_student

group by gender order by count(sid) desc;

Python:

​    res = Student.objects.values('gender').annotate

(gender_count=Count('sid')).order_by('-gender_count')

 

 

15.查询各个课程及相应的选修人数；

思路:根基成绩表,按照课程进行分组,统计选修人数即可

SQL:

​    (1)select course_id, count(student_id)as student_count from SMS_score

group by course_id;

​    (2)select cid, cname, student_count from(...)left join SMS_course

on course_id=cid;

Python:

​    res = Score.objects.values('course_id', 'course__cname'

).annotate(student_count=Count('student_id'))

 

16.查询同时选修了物理课和生物课的学生id和姓名；

思路:同第12题

SQL:

​    1.select cid from SMS_course where cname in ('物理', '生物');

​    2.select student_id from SMS_score where course_id in (...)group by

student_id HAVING count(course_id)>1;

​    3.select sid, sname from SMS_student where sid in (...);

Python:

​    res = Score.objects.filter(course__cname__in=['物理', '生物']).values(

'student__sid', 'student__sname').annotate(course_count=Count

('course_id')).filter(course_count__gt=1)

 

17.检索“3”课程分数小于60，按分数降序排列的同学学号；

思路:先按条件过滤出学生,然后按分数降序即可

SQL:

​    select student_id, score from SMS_score where course_id=3 and score<60

order by score desc;

Python:

​    res = Score.objects.filter(course_id=3, score__lt=60).values('student_id', 'score')

 

18.查询每门课程的平均成绩，结果按平均成绩升序排列，

平均成绩相同时，按课程号降序排列；

思路:按照课程分组,求出平均成绩,然后排序即可

SQL:

​    1.select course_id, avg(score)as avg_score from SMS_score group by course_id

order by avg_score,course_id desc;

​    2.select cid,cname,avg_score from(...)left join SMS_course on course_id=cid;

Python:

​    res = Score.objects.values('course_id', 'course__cname').annotate(avg_score=

Avg('score')).order_by('avg_score','-course_id')

 

19.查询各科成绩最高和最低的分：以如下形式显示：课程ID，最高分，最低分；

思路:在成绩表按照课程分组,计算出分数最高分和最低分,完成显示即可

SQL:

​    1.select *, max(score)as max_score, min(score)as min_score from SMS_score group by course_id;

​    2.select cid,cname,max_score,min_score from(...)left join SMS_course on cid=course_id;

Python:

​    res = Score.objects.values('course_id', 'course__cname').

annotate(max_score=Max('score'), min_score=Min('score'))