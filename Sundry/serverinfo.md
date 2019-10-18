BaseInfo:

| 字段名                   | 字段类型                  | 是否为空   | 默认值 | 键   |
| ------------------------ | ------------------------- | ---------- | ------ | ---- |
| os_name(操作系统)        | CharField(max_length=128) | null=False |        |      |
| machine(系统架构)        | CharField(max_lenght=128) | null=False |        |      |
| os_version(操作系统版本) | CharField(max_lenght=128) | null=False |        |      |
| hostname(主机名)         | CharField(max_lenght=128) | null=False |        | 主键 |
| kernel(内核信息)         | CharField(max_lenght=128) | null=False |        |      |

CpuInfo:

| 字段名                      | 字段类型                  | 是否为空   | 默认值 | 键   |
| --------------------------- | ------------------------- | ---------- | ------ | ---- |
|                             | AutoField()               |            |        | 主键 |
| model_name(cpu名称)         | CharField(max_length=128) | null=False |        |      |
| cpu_type(cpu类型)           | CharField(max_length=128) | null=False |        |      |
| physical_count(cpu物理颗数) | IntegerField()            | null=False |        |      |
| cpu_cores(每颗cpu的核心数)  | IntegerField()            | null=False |        |      |
| hostname                    |                           |            |        | 外键 |

MemInfo:

| 字段名             | 字段类型                  | 是否为空  | 默认值 | 键   |
| ------------------ | ------------------------- | --------- | ------ | ---- |
| id                 | AutoField()               |           |        | 主键 |
| capacity(内存容量) | CharField(max_length=100) | null=True |        |      |
| manufacturer(厂商) | CharField(max_length=128) | null=True |        |      |
| model(类型)        | CharField(max_length=128) | null=True |        |      |
| slot(插槽)         | CharField(max_langth=128) | null=True |        |      |
| sn(产品序列号)     | CharField(max_length=128) | null=True |        |      |
| speed(速率)        | CharField(max_length=128) | null=True |        |      |
| hostname           |                           |           |        | 外键 |

Diskinfo:

| 字段名 | 字段类型 | 是否为空 | 默认值 | 键   |
| ------ | -------- | -------- | ------ | ---- |
|        |          |          |        |      |

