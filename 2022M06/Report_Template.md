**报告标题：** 数据库原理课后练习

**学号：** 19200139

**姓名：** 程冬阳

**日期：** 2022-10-30

# 一、实验环境

1. 操作系统：Windows11

2. 数据库管理软件（含版本号）：postgreSQL 12

3. 其他工具：pycharm、python


# 二、实验内容及其完成情况
<pre>
采用自动生成记录的方法在Student、Course和SC中分别插入100万、1万和1000万条记录。
1.要求满足实体完整性、参照完整性约束要求。
2.采用曲线图展示不同数据量情况下完成插入记录的性能表现。
3.可以根据所用计算机性能调整记录总数。
</pre>
1. 通过python编写脚本完成实验，使用psycopg2库操纵postgreSQL数据库，使用faker库生成随机数据，使用matplotlib库绘制性能曲线图。
2. 导入库代码如下：<br>
```python
import random
import time
import psycopg2
from faker import Faker
from matplotlib import pyplot as plt
```
3. 创建数据库代码如下：<br>
```python
# 打印数据函数
def ShowData(str, data):
    arr = []
    for item in data:
        arr.append(item)
    print(str, arr)
    
def create_database(dbname):
    # 打开数据库连接
    db = psycopg2.connect(host='localhost',
                          port='5432',
                          user='postgres',
                          password='1')

    # 设置数据库连接打开自动提交模式
    db.autocommit = True

    # 创建游标对象
    cursor = db.cursor()

    # 查看现有数据库
    sql = 'SELECT DATNAME FROM PG_DATABASE;'
    cursor.execute(sql)
    ShowData("现有数据库：", cursor.fetchall())

    # 创建数据库
    sql = 'CREATE DATABASE %s;' % dbname
    cursor.execute(sql)

    # 查看新数据库创建完成后的数据库列表
    sql = 'SELECT DATNAME FROM PG_DATABASE;'
    cursor.execute(sql)
    ShowData("创建完成后的数据库：", cursor.fetchall())

    # 释放游标及数据库连接
    cursor.close()
    db.close()
```
4. 创建表格代码如下：<br>
```python
def create_table(dbname):
    # 打开数据库连接
    db = psycopg2.connect(host='localhost',
                          port='5432',
                          user='postgres',
                          password='1',
                          database=dbname)

    # 创建游标对象
    cursor = db.cursor()

    # 查看现有表
    sql = "SELECT tablename FROM PG_TABLES WHERE SCHEMANAME = 'public';"
    cursor.execute(sql)
    ShowData("现有表：", cursor.fetchall())

    # 创建Student、Course、SC表
    sql = """
    CREATE TABLE Student(
    Sno CHAR(20) PRIMARY KEY ,
    Sname CHAR(20) UNIQUE ,
    Ssex CHAR(20) ,
    Sage SMALLINT ,
    Sdept CHAR(20)
    );

    CREATE TABLE Course(
    Cno CHAR(40) PRIMARY KEY ,
    Cname CHAR(40) NOT NULL ,
    Cpno CHAR(40) ,
    Ccredit SMALLINT ,
    FOREIGN KEY (Cpno) REFERENCES Course(Cno)
    );

    CREATE TABLE SC(
    Sno CHAR(20) ,
    Cno CHAR(40) ,
    Grade SMALLINT ,
    PRIMARY KEY (Sno, Cno) ,
    FOREIGN KEY (Sno) REFERENCES Student(Sno) ,
    FOREIGN KEY (Cno) REFERENCES Course(Cno)
    );
    """
    cursor.execute(sql)

    # 查看新数据库创建完成后的数据库列表
    sql = "SELECT tablename FROM PG_TABLES WHERE SCHEMANAME = 'public';"
    cursor.execute(sql)
    ShowData("创建完成后的表：", cursor.fetchall())

    # 提交事务
    db.commit()

    # 释放游标及数据库连接
    cursor.close()
    db.close()
```
5. 随机生成记录并插入数据库，同时记录耗时，代码如下：<br>
```python
def solve(dbname):
    # 打开数据库连接
    create_database(dbname)
    create_table(dbname)
    db = psycopg2.connect(host='localhost',
                          port='5432',
                          user='postgres',
                          password='1',
                          database=dbname)

    # 创建游标对象
    cursor = db.cursor()
    num = 10000
    fake = Faker("zh-CN")
    # 生成随机姓名
    sname = [fake.unique.name() for i in range(num)]
    sname_list = []
    for i in range(num):
        print(i)
        for j in range(i + 1, num):
            sname_list.append(sname[i] + sname[j])
    print("sname生成完成")
    # 生成随机学号
    sno_list = [i for i in range(10000000, 0, -1)]
    print("sno生成完成")
    # 生成随机性别
    ssex_list = [random.choice('男女') for i in range(100)]
    print("ssex生成完成")
    # 生成随机年龄
    sage_list = [random.randint(18, 22) for i in range(100)]
    print("sage生成完成")
    # 生成随机系
    sdept_list = [fake.country_code() for i in range(100)]
    print("sdept生成完成")
    # 生成随机课程号
    cno_list = [i for i in range(1, 10000000 + 1)]
    print("cno生成完成")
    # 生成随机课程名
    cname_list = [fake.word() for i in range(100)]
    print("cname生成完成")
    # 生成随机学分
    ccredit_list = [random.randint(1, 5) for i in range(100)]
    print("ccredit生成完成")
    # 生成随机成绩
    grade_list = [random.randint(0, 100) for i in range(100)]
    print("grade生成完成")

    if dbname == 'test2':  # 一百万条记录
        num = 1000000
    elif dbname == 'test3':  # 一千万条记录
        num = 10000000
    else:  # 一万条记录
        num = 10000

    # 插入Student
    n = 1
    y1 = []
    start = time.time()
    for i in range(num):
        # 使用Faker库生成假数据,将其转为字典格式,方便插入数据库
        ctx = {
            'Sno': sno_list[i],
            'Sname': sname_list[i],
            'Ssex': ssex_list[i % 100],
            'Sage': sage_list[i % 100],
            'Sdept': sdept_list[i % 100]
        }
        sql = """insert into student (%s) VALUES (%s)""" % (','.join([k for k, v in ctx.items()]),
                                                            ','.join(['%s' for k, v in ctx.items()])
                                                            )

        cursor.execute(sql, [v for k, v in ctx.items()])
        if n == num / 10:
            end = time.time()
            y1.append(end - start)
            n = 0
        n += 1
    print("Student插入", num, "条记录")

    print(y1)
    # 插入Course
    n = 1
    y2 = []
    start = time.time()
    for i in range(num):
        # 使用Faker库生成假数据,将其转为字典格式,方便插入数据库
        ctx = {
            'Cno': cno_list[i],
            'Cname': cname_list[i % 100],
            'Ccredit': ccredit_list[i % 100]
        }
        sql = """insert into course (%s) VALUES (%s)""" % (','.join([k for k, v in ctx.items()]),
                                                           ','.join(['%s' for k, v in ctx.items()])
                                                           )

        cursor.execute(sql, [v for k, v in ctx.items()])
        if n == num / 10:
            end = time.time()
            y2.append(end - start)
            n = 0
        n += 1
    print("Course插入", num, "条记录")

    print(y2)
    # 插入SC
    n = 1
    y3 = []
    start = time.time()
    for i in range(num):
        # 使用Faker库生成假数据,将其转为字典格式,方便插入数据库
        ctx = {
            'Sno': sno_list[i],
            'Cno': cno_list[i],
            'Grade': grade_list[i % 100],
        }
        sql = """insert into sc (%s) VALUES (%s)""" % (','.join([k for k, v in ctx.items()]),
                                                       ','.join(['%s' for k, v in ctx.items()])
                                                       )

        cursor.execute(sql, [v for k, v in ctx.items()])
        if n == num / 10:
            end = time.time()
            y3.append(end - start)
            n = 0
        n += 1
    print("SC插入", num, "条记录")

    print(y3)

    show_speed(num, y1, y2, y3)

    db.commit()

    # 释放游标及数据库连接
    cursor.close()
    db.close() 
```
6. 绘制性能图函数如下：<br>
```python
def show_speed(num, y1=[], y2=[], y3=[]):
    x = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    plt.title("插入" + str(num) + "条记录")  # 折线图标题

    plt.rcParams['font.sans-serif'] = ['SimHei']  # 折线图中需显示汉字时，得加上这一行

    if num <= 10000:
        plt.xlabel('记录数/千条')  # x轴标题
    elif num <= 1000000:
        plt.xlabel('记录数/十万条')  # x轴标题
    elif num <= 10000000:
        plt.xlabel('记录数/百万条')  # x轴标题
    if num <= 10000:
        y1 = [i * 1000 for i in y1]
        y2 = [i * 1000 for i in y2]
        y3 = [i * 1000 for i in y3]
        plt.ylabel('耗时/豪秒')  # y轴标题
    else:
        plt.ylabel('耗时/秒')  # y轴标题
    y1 = [round(i, 2) for i in y1]
    y2 = [round(i, 2) for i in y2]
    y3 = [round(i, 2) for i in y3]
    plt.plot(x, y1, marker='o', markersize=3)  # 绘制折线图，添加数据点形状并设置点的大小
    plt.plot(x, y2, marker='^', markersize=3)  # ^：点的形状为三角形
    plt.plot(x, y3, marker='*', markersize=3)  # 星形

    for a, b in zip(x, y1):
        plt.text(a, b, b, ha='center', va='bottom', fontsize=10)  # 设置数据标签位置及字体大小
    for a, b in zip(x, y2):
        plt.text(a, b, b, ha='center', va='bottom', fontsize=10)
    for a, b in zip(x, y3):
        plt.text(a, b, b, ha='center', va='bottom', fontsize=10)

    plt.legend(['Student', 'Course', 'SC'])  # 设置折线名称

    plt.show()  # 显示折线图
```
7. 主函数如下：<br>
```python
solve('test1')  # 插入一万条记录
solve('test2')  # 插入一百万条记录
solve('test3')  # 插入一千万条记录
```
8. 实验结果：<br>
插入一万条记录数据库查询示例以及性能图<br>
![test1](https://github.com/kidkabukino/DB2022FALL/blob/main/2022M06/test1.jpg)<br>
![10000](https://github.com/kidkabukino/DB2022FALL/blob/main/2022M06/10000.png)<br>
插入一百万条记录数据库查询示例以及性能图<br>
![test2](https://github.com/kidkabukino/DB2022FALL/blob/main/2022M06/test2.jpg)<br>
![1000000](https://github.com/kidkabukino/DB2022FALL/blob/main/2022M06/1000000.png)<br>
插入一千万条记录数据库查询示例以及性能图<br>
![test3](https://github.com/kidkabukino/DB2022FALL/blob/main/2022M06/test3.jpg)<br>
![10000000](https://github.com/kidkabukino/DB2022FALL/blob/main/2022M06/10000000.png)<br>

# 三、实验总结
通过图片可以看到SC表格插入最慢，其次是Student表格，最后是Course表格。随着记录量不同，耗时大约成正比增长。
