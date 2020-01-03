如果你曾经编写过 Python，或者只是使用过 Python，你或许经常会看到 Python 源代码文件——它们的名字以 `.py` 结尾。你可能还看到过其它类型的文件，比如以 `.pyc` 结尾的文件，或许你可能听说过它们就是 Python 的 “ *字节码(bytecode)*” 文件。（在 Python 3 上这些可能不容易看到 —— 因为它们与你的 `.py` 文件不在同一个目录下，它们在一个叫 `__pycache__` 的子目录中）或者你也听说过，这是节省时间的一种方法，它可以避免每次运行 Python 时去重新解析源代码。

但是，除了 “噢，原来这就是 Python 字节码” 之外，你还知道这些文件能做什么吗？以及 Python 是如何使用它们的？

如果你不知道，那你走运了！今天我将带你了解 Python 的字节码是什么，Python 如何使用它去运行你的代码，以及知道它是如何帮助你的。

## **Python 如何工作**

Python 经常被介绍为它是一个解释型语言 —— 其中一个原因是在程序运行时，你的源代码被转换成 CPU 的原生指令 —— 但这样的看法只是部分正确。Python 与大多数解释型语言一样，确实是将源代码编译为一组虚拟机指令，并且 Python 解释器是针对相应的虚拟机实现的。这种中间格式被称为 “字节码”。

因此，这些 `.pyc` 文件是 Python 悄悄留下的，是为了让它们运行的 “更快”，或者是针对你的源代码的 “优化” 版本；它们是你的程序在 Python 虚拟机上运行的字节码指令。

我们来看一个示例。这里是用 Python 写的经典程序 “Hello, World!”：

```text
def hello()
    print("Hello, World!")
```

下面是转换后的字节码（转换为人类可读的格式）：

```text
2           0 LOAD_GLOBAL              0 (print)
            2 LOAD_CONST               1 ('Hello, World!')
            4 CALL_FUNCTION            1
```

如果你输入那个 `hello()` 函数，然后使用 [CPython](https://link.zhihu.com/?target=https%3A//github.com/python/cpython) 解释器去运行它，那么上述列出的内容就是 Python 所运行的。它看起来可能有点奇怪，因此，我们来深入了解一下它都做了些什么。

## **Python 虚拟机内幕**

CPython 使用一个基于栈的虚拟机。也就是说，它完全面向栈数据结构的（你可以 “推入” 一个东西到栈 “顶”，或者，从栈 “顶” 上 “弹出” 一个东西来）。

CPython 使用三种类型的栈：

1. *调用栈(call stack)*。这是运行 Python 程序的主要结构。它为每个当前活动的函数调用使用了一个东西 —— “ *帧(frame)*”，栈底是程序的入口点。每个函数调用推送一个新的帧到调用栈，每当函数调用返回后，这个帧被销毁。
2. 在每个帧中，有一个 *计算栈(evaluation stack)* （也称为 *数据栈(data stack)*）。这个栈就是 Python 函数运行的地方，运行的 Python 代码大多数是由推入到这个栈中的东西组成的，操作它们，然后在返回后销毁它们。
3. 在每个帧中，还有一个 *块栈(block stack)*。它被 Python 用于去跟踪某些类型的控制结构：循环、`try` / `except` 块、以及 `with` 块，全部推入到块栈中，当你退出这些控制结构时，块栈被销毁。这将帮助 Python 了解任意给定时刻哪个块是活动的，比如，一个 `continue` 或者 `break` 语句可能影响正确的块。

大多数 Python 字节码指令操作的是当前调用栈帧的计算栈，虽然，还有一些指令可以做其它的事情（比如跳转到指定指令，或者操作块栈）。

为了更好地理解，假设我们有一些调用函数的代码，比如这个：`my_function(my_variable, 2)`。Python 将转换为一系列字节码指令：

1. 一个 `LOAD_NAME` 指令去查找函数对象 `my_function`，然后将它推入到计算栈的顶部
2. 另一个 `LOAD_NAME` 指令去查找变量 `my_variable`，然后将它推入到计算栈的顶部
3. 一个 `LOAD_CONST` 指令去推入一个实整数值 `2` 到计算栈的顶部
4. 一个 `CALL_FUNCTION` 指令

这个 `CALL_FUNCTION` 指令将有 2 个参数，它表示那个 Python 需要从栈顶弹出两个位置参数；然后函数将在它上面进行调用，并且它也同时被弹出（对于函数涉及的关键字参数，它使用另一个不同的指令 —— `CALL_FUNCTION_KW`，但使用的操作原则类似，以及第三个指令 —— `CALL_FUNCTION_EX`，它适用于函数调用涉及到参数使用 `*` 或 `**` 操作符的情况）。一旦 Python 拥有了这些之后，它将在调用栈上分配一个新帧，填充到函数调用的本地变量上，然后，运行那个帧内的 `my_function` 字节码。运行完成后，这个帧将被调用栈销毁，而在最初的帧内，`my_function` 的返回值将被推入到计算栈的顶部。

## **访问和理解 Python 字节码**

如果你想玩转字节码，那么，Python 标准库中的 `dis` 模块将对你有非常大的帮助；`dis` 模块为 Python 字节码提供了一个 “反汇编”，它可以让你更容易地得到一个人类可读的版本，以及查找各种字节码指令。`href="https://docs.python.org/3/library/dis.html">dis 模块的文档 可以让你遍历它的内容，并且提供一个字节码指令能够做什么和有什么样的参数的完整清单。`

例如，获取上面的 `hello()` 函数的列表，可以在一个 Python 解析器中输入如下内容，然后运行它：

```text
import dis
dis.dis(hello)
```

函数 `dis.dis()` 将反汇编一个函数、方法、类、模块、编译过的 Python 代码对象、或者字符串包含的源代码，以及显示出一个人类可读的版本。`dis` 模块中另一个方便的功能是 `distb()`。你可以给它传递一个 Python 追溯对象，或者在发生预期外情况时调用它，然后它将在发生预期外情况时反汇编调用栈上最顶端的函数，并显示它的字节码，以及插入一个指向到引发意外情况的指令的指针。

它也可以用于查看 Python 为每个函数构建的编译后的代码对象，因为运行一个函数将会用到这些代码对象的属性。这里有一个查看 `hello()` 函数的示例：

```text
>>> hello.__code__
<code object hello at 0x104e46930, file "<stdin>", line 1>
>>> hello.__code__.co_consts
(None, 'Hello, World!')
>>> hello.__code__.co_varnames
()
>>> hello.__code__.co_names
('print',)
```

代码对象在函数中可以以属性 `__code__` 来访问，并且携带了一些重要的属性：

- `co_consts` 是存在于函数体内的任意实数的元组
- `co_varnames` 是函数体内使用的包含任意本地变量名字的元组
- `co_names` 是在函数体内引用的任意非本地名字的元组

许多字节码指令 —— 尤其是那些推入到栈中的加载值，或者在变量和属性中的存储值 —— 在这些元组中的索引作为它们参数。

因此，现在我们能够理解 `hello()` 函数中所列出的字节码：

1. `LOAD_GLOBAL 0`：告诉 Python 通过 `co_names` （它是 `print` 函数）的索引 0 上的名字去查找它指向的全局对象，然后将它推入到计算栈
2. `LOAD_CONST 1`：带入 `co_consts` 在索引 1 上的字面值，并将它推入（索引 0 上的字面值是 `None`，它表示在 `co_consts` 中，因为 Python 函数调用有一个隐式的返回值 `None`，如果没有显式的返回表达式，就返回这个隐式的值 ）。
3. `CALL_FUNCTION 1`：告诉 Python 去调用一个函数；它需要从栈中弹出一个位置参数，然后，新的栈顶将被函数调用。

“原始的” 字节码 —— 是非人类可读格式的字节 —— 也可以在代码对象上作为 `co_code` 属性可用。如果你有兴趣尝试手工反汇编一个函数时，你可以从它们的十进制字节值中，使用列出 `dis.opname` 的方式去查看字节码指令的名字。

## **字节码的用处**

现在，你已经了解的足够多了，你可能会想 “OK，我认为它很酷，但是知道这些有什么实际价值呢？”由于对它很好奇，我们去了解它，但是除了好奇之外，Python 字节码在几个方面还是非常有用的。

首先，理解 Python 的运行模型可以帮你更好地理解你的代码。人们都开玩笑说，C 是一种 “可移植汇编器”，你可以很好地猜测出一段 C 代码转换成什么样的机器指令。理解 Python 字节码之后，你在使用 Python 时也具备同样的能力 —— 如果你能预料到你的 Python 源代码将被转换成什么样的字节码，那么你可以知道如何更好地写和优化 Python 源代码。

第二，理解字节码可以帮你更好地回答有关 Python 的问题。比如，我经常看到一些 Python 新手困惑为什么某些结构比其它结构运行的更快（比如，为什么 `{}` 比 `dict()` 快）。知道如何去访问和阅读 Python 字节码将让你很容易回答这样的问题（尝试对比一下： `dis.dis("{}")` 与 `dis.dis("dict()")` 就会明白）。

最后，理解字节码和 Python 如何运行它，为 Python 程序员不经常使用的一种特定的编程方式提供了有用的视角：面向栈的编程。如果你以前从来没有使用过像 FORTH 或 Fator 这样的面向栈的编程语言，它们可能有些古老，但是，如果你不熟悉这种方法，学习有关 Python 字节码的知识，以及理解面向栈的编程模型是如何工作的，将有助你开拓你的编程视野。

## **延伸阅读**

如果你想进一步了解有关 Python 字节码、Python 虚拟机、以及它们是如何工作的更多知识，我推荐如下的这些资源：

- [Python 虚拟机内幕](https://link.zhihu.com/?target=https%3A//leanpub.com/insidethepythonvirtualmachine)，它是 Obi Ike-Nwosu 写的一本免费在线电子书，它深入 Python 解析器，解释了 Python 如何工作的细节。
- [一个用 Python 编写的 Python 解析器](https://link.zhihu.com/?target=http%3A//www.aosabook.org/en/500L/a-python-interpreter-written-in-python.html)，它是由 Allison Kaptur 写的一个教程，它是用 Python 构建的 Python 字节码解析器，并且它实现了运行 Python 字节码的全部构件。
- 最后，CPython 解析器是一个开源软件，你可以在 [GitHub](https://link.zhihu.com/?target=https%3A//github.com/python/cpython) 上阅读它。它在文件 `Python/ceval.c` 中实现了字节码解析器。[这是 Python 3.6.4 发行版中那个文件的链接](https://link.zhihu.com/?target=https%3A//github.com/python/cpython/blob/d48ecebad5ac78a1783e09b0d32c211d9754edf4/Python/ceval.c)；字节码指令是由第 1266 行开始的 `switch` 语句来处理的。

# dis-- Python 字节码反汇编器

**Source code:** [Lib/dis.py](https://github.com/python/cpython/tree/3.8/Lib/dis.py)

------

[`dis`](https://docs.python.org/zh-cn/3.8/library/dis.html#module-dis) 模块通过反汇编支持CPython的 [bytecode](https://docs.python.org/zh-cn/3.8/glossary.html#term-bytecode) 分析。该模块作为输入的 CPython 字节码在文件 `Include/opcode.h` 中定义，并由编译器和解释器使用。

**CPython implementation detail:** 字节码是 CPython 解释器的实现细节。不保证不会在Python版本之间添加、删除或更改字节码。不应考虑将此模块的跨 Python VM 或 Python 版本的使用。

*在 3.6 版更改:* `每条指令使用2个字节`。以前字节数因指令而异。

示例：给出函数 `myfunc()`:

```
def myfunc(alist):
    return len(alist)
```

可以使用以下命令显示 `myfunc()` 的反汇编

```
>>> dis.dis(myfunc)
  2           0 LOAD_GLOBAL              0 (len)
              2 LOAD_FAST                0 (alist)
              4 CALL_FUNCTION            1
              6 RETURN_VALUE
```

("2" 是行号)。

## 字节码分析

*3.4 新版功能.*

字节码分析 API 允许将 Python 代码片段包装在 [`Bytecode`](https://docs.python.org/zh-cn/3.8/library/dis.html#dis.Bytecode) 对象中，以便轻松访问已编译代码的详细信息。

class dis.Bytecode (*x*, *, *first_line=None*, *current_offset=None*)

分析的字节码对应于函数、生成器、异步生成器、协程、方法、源代码字符串或代码对象（由 [`compile()`](https://docs.python.org/zh-cn/3.8/library/functions.html#compile) 返回）。这是下面列出的许多函数的便利包装，最值得注意的是 [`get_instructions()`](https://docs.python.org/zh-cn/3.8/library/dis.html#dis.get_instructions) ，迭代于 [`Bytecode`](https://docs.python.org/zh-cn/3.8/library/dis.html#dis.Bytecode) 的实例产生字节码操作 [`Instruction`](https://docs.python.org/zh-cn/3.8/library/dis.html#dis.Instruction) 的实例。如果 *first_line* 不是 `None` ，则表示应该为反汇编代码中的第一个源代码行报告的行号。否则，源行信息（如果有的话）直接来自反汇编的代码对象。如果current_offset不是 `None` ，则它指的是反汇编代码中的指令偏移量。设置它意味着 [`dis()`](https://docs.python.org/zh-cn/3.8/library/dis.html#dis.Bytecode.dis) 将针对指定的操作码显示“当前指令”标记。*classmethod* `from_traceback`(*tb*)从给定回溯构造一个 [`Bytecode`](https://docs.python.org/zh-cn/3.8/library/dis.html#dis.Bytecode) 实例，将设置 *current_offset* 为异常负责的指令。`codeobj`已编译的代码对象。`first_line`代码对象的第一个源代码行（如果可用）`dis`()返回字节码操作的格式化视图（与 [`dis.dis()`](https://docs.python.org/zh-cn/3.8/library/dis.html#dis.dis) 打印相同，但作为多行字符串返回）。`info`()返回带有关于代码对象的详细信息的格式化多行字符串，如 [`code_info()`](https://docs.python.org/zh-cn/3.8/library/dis.html#dis.code_info) 。*在 3.7 版更改:* 现在可以处理协程和异步生成器对象。

示例:

```
>>> bytecode = dis.Bytecode(myfunc)
>>> for instr in bytecode:
...     print(instr.opname)
...
LOAD_GLOBAL
LOAD_FAST
CALL_FUNCTION
RETURN_VALUE
```

## 分析函数

[`dis`](https://docs.python.org/zh-cn/3.8/library/dis.html#module-dis) 模块还定义了以下分析函数，它们将输入直接转换为所需的输出。如果只执行单个操作，它们可能很有用，因此中间分析对象没用：

- `dis.code_info`(*x*)

    返回格式化的多行字符串，其包含详细代码对象信息的用于被提供的函数、生成器、异步生成器、协程、方法、源代码字符串或代码对象。请注意，代码信息字符串的确切内容是高度依赖于实现的，它们可能会在Python VM或Python版本中任意更改。*3.2 新版功能.在 3.7 版更改:* 现在可以处理协程和异步生成器对象。

- `dis.show_code`(*x*, *, *file=None*)

    将提供的函数、方法。源代码字符串或代码对象的详细代码对象信息打印到 *file* （如果未指定 *file* ，则为 `sys.stdout` ）。这是 `print(code_info(x), file=file)` 的便捷简写，用于在解释器提示符下进行交互式探索。*3.2 新版功能.**在 3.4 版更改:* 添加 *file* 形参。

- `dis.dis`(*x=None*, ***, *file=None*, *depth=None*)

    反汇编 *x* 对象。 *x* 可以表示模块、类、方法、函数、生成器、异步生成器、协程、代码对象、源代码字符串或原始字节码的字节序列。对于模块，它会反汇编所有功能。对于一个类，它反汇编所有方法（包括类和静态方法）。对于代码对象或原始字节码序列，它每字节码指令打印一行。它还递归地反汇编嵌套代码对象（推导式代码，生成器表达式和嵌套函数，以及用于构建嵌套类的代码）。在被反汇编之前，首先使用 [`compile()`](https://docs.python.org/zh-cn/3.8/library/functions.html#compile) 内置函数将字符串编译为代码对象。如果未提供任何对象，则此函数会反汇编最后一次回溯。如果提供的话，反汇编将作为文本写入提供的 *file* 参数，否则写入 `sys.stdout` 。递归的最大深度受 *depth* 限制，除非它是 `None` 。 `depth=0` 表示没有递归。*在 3.4 版更改:* 添加 *file* 形参。*在 3.7 版更改:* 实现了递归反汇编并添加了 *depth* 参数。*在 3.7 版更改:* 现在可以处理协程和异步生成器对象。

- `dis.distb`(*tb=None*, *, *file=None*)

    如果没有传递，则使用最后一个回溯来反汇编回溯的堆栈顶部函数。 指示了导致异常的指令。如果提供的话，反汇编将作为文本写入提供的 *file* 参数，否则写入 `sys.stdout` 。*在 3.4 版更改:* 添加 *file* 形参。

- `dis.disassemble`(*code*, *lasti=-1*, *, *file=None*)

- `dis.disco`(*code*, *lasti=-1*, *, *file=None*)

    反汇编代码对象，如果提供了 *lasti* ，则指示最后一条指令。输出分为以下几列：行号，用于每行的第一条指令当前指令，表示为 `-->` ，一个标记的指令，用 `>>` 表示，指令的地址，操作码名称，操作参数，和括号中参数的解释。参数解释识别本地和全局变量名称、常量值、分支目标和比较运算符。如果提供的话，反汇编将作为文本写入提供的 *file* 参数，否则写入 `sys.stdout` 。*在 3.4 版更改:* 添加 *file* 形参。

- `dis.get_instructions`(*x*, *, *first_line=None*)

    在所提供的函数、方法、源代码字符串或代码对象中的指令上返回一个迭代器。迭代器生成一系列 [`Instruction`](https://docs.python.org/zh-cn/3.8/library/dis.html#dis.Instruction) ，命名为元组，提供所提供代码中每个操作的详细信息。如果 *first_line* 不是 `None` ，则表示应该为反汇编代码中的第一个源代码行报告的行号。否则，源行信息（如果有的话）直接来自反汇编的代码对象。*3.4 新版功能.*

- `dis.findlinestarts`(*code*)

    此生成器函数使用代码对象 *code* 的 `co_firstlineno` 和 `co_lnotab` 属性来查找源代码中行开头的偏移量。它们生成为 `(offset, lineno)` 对。请参阅 [objects/lnotab_notes.txt](https://github.com/python/cpython/tree/3.8/objects/lnotab_notes.txt) ，了解 `co_lnotab` 格式以及如何解码它。*在 3.6 版更改:* 行号可能会减少。 以前，他们总是在增加。

- `dis.findlabels`(*code*)

    检测作为跳转目标的代码对象 *code* 中的所有偏移量，并返回这些偏移量的列表。

- `dis.stack_effect`(*opcode*, *oparg=None*, *, *jump=None*)

    使用参数 *oparg* 计算 *opcode* 的堆栈效果。如果代码有一个跳转目标并且 *jump* 是 `True` ，则 `drag_effect()` 将返回跳转的堆栈效果。如果 *jump* 是 `False` ，它将返回不跳跃的堆栈效果。如果 *jump* 是 `None` （默认值），它将返回两种情况的最大堆栈效果。*3.4 新版功能.**在 3.8 版更改:* 添加 *jump* 参数。



## Python字节码说明

[`get_instructions()`](https://docs.python.org/zh-cn/3.8/library/dis.html#dis.get_instructions) 函数和 [`Bytecode`](https://docs.python.org/zh-cn/3.8/library/dis.html#dis.Bytecode) 类提供字节码指令的详细信息的 [`Instruction`](https://docs.python.org/zh-cn/3.8/library/dis.html#dis.Instruction) 实例：

- *class* `dis.Instruction`

    字节码操作的详细信息`opcode`操作的数字代码，对应于下面列出的操作码值和 [操作码集合](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-collections) 中的字节码值。`opname`人类可读的操作名称`arg`操作的数字参数（如果有的话），否则为 `None``argval`已解析的 arg 值（如果已知），否则与 arg 相同`argrepr`人类可读的操作参数描述`offset`在字节码序列中启动操作索引`starts_line`行由此操作码（如果有）启动，否则为 `None``is_jump_target`如果其他代码跳到这里，则为 `True` ，否则为 `False`*3.4 新版功能.*

Python编译器当前生成以下字节码指令。

**一般指令**

- `NOP`

    什么都不做。 用作字节码优化器的占位符。

- `POP_TOP`

    删除堆栈顶部（TOS）项。

- `ROT_TWO`

    交换两个最顶层的堆栈项。

- `ROT_THREE`

    将第二个和第三个堆栈项向上提升一个位置，顶项移动到位置三。

- `ROT_FOUR`

    将第二个，第三个和第四个堆栈项向上提升一个位置，将顶项移动到第四个位置。*3.8 新版功能.*

- `DUP_TOP`

    复制堆栈顶部的引用。*3.2 新版功能.*

- `DUP_TOP_TWO`

    复制堆栈顶部的两个引用，使它们保持相同的顺序。*3.2 新版功能.*

**一元操作**

一元操作获取堆栈顶部元素，应用操作，并将结果推回堆栈。

- `UNARY_POSITIVE`

    实现 `TOS = +TOS` 。

- `UNARY_NEGATIVE`

    实现 `TOS = -TOS` 。

- `UNARY_NOT`

    实现 `TOS = not TOS` 。

- `UNARY_INVERT`

    实现 `TOS = ~TOS` 。

- `GET_ITER`

    实现 `TOS = iter(TOS)` 。

- `GET_YIELD_FROM_ITER`

    如果 `TOS` 是一个 [generator iterator](https://docs.python.org/zh-cn/3.8/glossary.html#term-generator-iterator) 或 [coroutine](https://docs.python.org/zh-cn/3.8/glossary.html#term-coroutine) 对象则保持原样。否则实现 `TOS = iter(TOS)` 。*3.5 新版功能.*

**二元操作**

二元操作从堆栈中删除堆栈顶部（TOS）和第二个最顶层堆栈项（TOS1）。 它们执行操作，并将结果放回堆栈。

- `BINARY_POWER`

    实现 `TOS = TOS1 ** TOS` 。

- `BINARY_MULTIPLY`

    实现 `TOS = TOS1 * TOS` 。

- `BINARY_MATRIX_MULTIPLY`

    实现 `TOS = TOS1 @ TOS` 。*3.5 新版功能.*

- `BINARY_FLOOR_DIVIDE`

    实现 `TOS = TOS1 // TOS`。

- `BINARY_TRUE_DIVIDE`

    实现 `TOS = TOS1 / TOS` 。

- `BINARY_MODULO`

    实现 `TOS = TOS1 % TOS` 。

- `BINARY_ADD`

    实现 `TOS = TOS1 + TOS` 。

- `BINARY_SUBTRACT`

    实现 `TOS = TOS1 - TOS` 。

- `BINARY_SUBSCR`

    实现 `TOS = TOS1[TOS]` 。

- `BINARY_LSHIFT`

    实现 `TOS = TOS1 << TOS` 。

- `BINARY_RSHIFT`

    实现 `TOS = TOS1 >> TOS` 。

- `BINARY_AND`

    实现 `TOS = TOS1 & TOS` 。

- `BINARY_XOR`

    实现 `TOS = TOS1 ^ TOS` 。

- `BINARY_OR`

    实现 `TOS = TOS1 | TOS` 。

**就地操作**

就地操作就像二元操作，因为它们删除了TOS和TOS1，并将结果推回到堆栈上，但是当TOS1支持它时，操作就地完成，并且产生的TOS可能是（但不一定） 原来的TOS1。

- `INPLACE_POWER`

    就地实现 `TOS = TOS1 ** TOS` 。

- `INPLACE_MULTIPLY`

    就地实现 `TOS = TOS1 * TOS` 。

- `INPLACE_MATRIX_MULTIPLY`

    就地实现 `TOS = TOS1 @ TOS` 。*3.5 新版功能.*

- `INPLACE_FLOOR_DIVIDE`

    就地实现 `TOS = TOS1 // TOS` 。

- `INPLACE_TRUE_DIVIDE`

    就地实现 `TOS = TOS1 / TOS` 。

- `INPLACE_MODULO`

    就地实现 `TOS = TOS1 % TOS` 。

- `INPLACE_ADD`

    就地实现 `TOS = TOS1 + TOS` 。

- `INPLACE_SUBTRACT`

    就地实现 `TOS = TOS1 - TOS` 。

- `INPLACE_LSHIFT`

    就地实现 `TOS = TOS1 << TOS` 。

- `INPLACE_RSHIFT`

    就地实现 `TOS = TOS1 >> TOS` 。

- `INPLACE_AND`

    就地实现 `TOS = TOS1 & TOS` 。

- `INPLACE_XOR`

    就地实现 `TOS = TOS1 ^ TOS` 。

- `INPLACE_OR`

    就地实现 `TOS = TOS1 | TOS` 。

- `STORE_SUBSCR`

    实现 `TOS1[TOS] = TOS2` 。

- `DELETE_SUBSCR`

    实现 `del TOS1[TOS]` 。

**协程操作码**

- `GET_AWAITABLE`

    实现 `TOS = get_awaitable(TOS)` ，其中 `get_awaitable(o)` 返回 `o` 如果 `o` 是一个有 CO_ITERABLE_COROUTINE 标志的协程对象或生成器对象，否则解析 `o.__await__` 。*3.5 新版功能.*

- `GET_AITER`

    实现 `TOS = TOS.__aiter__()` 。*3.5 新版功能.**在 3.7 版更改:* 已经不再支持从 `__aiter__` 返回可等待对象。

- `GET_ANEXT`

    实现 `PUSH(get_awaitable(TOS.__anext__()))` 。参见 `GET_AWAITABLE` 获取更多 `get_awaitable` 的细节*3.5 新版功能.*

- `END_ASYNC_FOR`

    终止一个 [`async for`](https://docs.python.org/zh-cn/3.8/reference/compound_stmts.html#async-for) 循环。处理等待下一个项目时引发的异常。如果 TOS 是 [`StopAsyncIteration`](https://docs.python.org/zh-cn/3.8/library/exceptions.html#StopAsyncIteration)， 从堆栈弹出7个值，并使用后三个恢复异常状态。否则，使用堆栈中的三个值重新引发异常。从块堆栈中删除异常处理程序块。*3.8 新版功能.*

- `BEFORE_ASYNC_WITH`

    从栈顶对象解析 `__aenter__` 和 `__aexit__` 。将 `__aexit__` 和 `__aenter__()` 的结果推入堆栈。*3.5 新版功能.*

- `SETUP_ASYNC_WITH`

    创建一个新的帧对象。*3.5 新版功能.*

**其他操作码**

- `PRINT_EXPR`

    实现交互模式的表达式语句。TOS从堆栈中被移除并打印。在非交互模式下，表达式语句以 [`POP_TOP`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-POP_TOP) 终止。

- `SET_ADD`(*i*)

    调用 `set.add(TOS1[-i], TOS)` 。 用于实现集合推导。

- `LIST_APPEND`(*i*)

    调用 `list.append(TOS[-i], TOS)` 。 用于实现列表推导。

- `MAP_ADD`(*i*)

    调用 `dict.__setitem__(TOS1[-i], TOS1, TOS)` 。 用于实现字典推导。*3.1 新版功能.**在 3.8 版更改:* 映射值为 TOS ，映射键为 TOS1 。之前，它们被颠倒了。

对于所有 [`SET_ADD`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-SET_ADD) 、 [`LIST_APPEND`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-LIST_APPEND) 和 [`MAP_ADD`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-MAP_ADD) 指令，当弹出添加的值或键值对时，容器对象保留在堆栈上，以便它可用于循环的进一步迭代。

- `RETURN_VALUE`

    返回 TOS 到函数的调用者。

- `YIELD_VALUE`

    弹出 TOS 并从一个 [generator](https://docs.python.org/zh-cn/3.8/glossary.html#term-generator) 生成它。

- `YIELD_FROM`

    弹出 TOS 并将其委托给它作为 [generator](https://docs.python.org/zh-cn/3.8/glossary.html#term-generator) 的子迭代器。*3.3 新版功能.*

- `SETUP_ANNOTATIONS`

    检查 `__annotations__` 是否在 `locals()` 中定义，如果没有，它被设置为空 `dict` 。只有在类或模块体静态地包含 [variable annotations](https://docs.python.org/zh-cn/3.8/glossary.html#term-variable-annotation) 时才会发出此操作码。*3.6 新版功能.*

- `IMPORT_STAR`

    将所有不以 `'_'` 开头的符号直接从模块 TOS 加载到局部命名空间。加载所有名称后弹出该模块。这个操作码实现了 `from module import *` 。

- `POP_BLOCK`

    从块堆栈中删除一个块。有一块堆栈，每帧用于表示 [`try`](https://docs.python.org/zh-cn/3.8/reference/compound_stmts.html#try) 语句等。

- `POP_EXCEPT`

    从块堆栈中删除一个块。 弹出的块必须是异常处理程序块，在进入 except 处理程序时隐式创建。除了从帧堆栈弹出无关值之外，最后三个弹出值还用于恢复异常状态。

- `POP_FINALLY`(*preserve_tos*)

    清除值堆栈和块堆栈。如果 *preserve_tos* 不是 `0` ，则在执行其他堆栈操作后，首先从堆栈中弹出 TOS 并将其推入堆栈：如果TOS是 `NULL` 或整数（由 [`BEGIN_FINALLY`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-BEGIN_FINALLY) 或 [`CALL_FINALLY`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-CALL_FINALLY) 推入），它将从堆栈中弹出。如果TOS是异常类型（在引发异常时被推入），则从堆栈中弹出6个值，最后三个弹出值用于恢复异常状态。从块堆栈中删除异常处理程序块。它类似于 [`END_FINALLY`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-END_FINALLY) ，但不会更改字节码计数器也不会引发异常。用于在 [`finally`](https://docs.python.org/zh-cn/3.8/reference/compound_stmts.html#finally) 块中实现 [`break`](https://docs.python.org/zh-cn/3.8/reference/simple_stmts.html#break) 、 [`continue`](https://docs.python.org/zh-cn/3.8/reference/simple_stmts.html#continue) 和 [`return`](https://docs.python.org/zh-cn/3.8/reference/simple_stmts.html#return) 。*3.8 新版功能.*

- `BEGIN_FINALLY`

    将 `NULL` 推入堆栈以便在以下操作中使用 [`END_FINALLY`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-END_FINALLY) 、 [`POP_FINALLY`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-POP_FINALLY) 、 [`WITH_CLEANUP_START`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-WITH_CLEANUP_START) 和 [`WITH_CLEANUP_FINISH`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-WITH_CLEANUP_FINISH) 。开始 [`finally`](https://docs.python.org/zh-cn/3.8/reference/compound_stmts.html#finally) 块。*3.8 新版功能.*

- `END_FINALLY`

    终止 [`finally`](https://docs.python.org/zh-cn/3.8/reference/compound_stmts.html#finally) 子句。解释器回溯是否有必须重新抛出异常的情况或根据 TOS 的值继续执行。如果 TOS 是 `NULL` （由 [`BEGIN_FINALLY`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-BEGIN_FINALLY) 推入）继续下一条指令。 TOS 被弹出。如果 TO S是一个整数（由 [`CALL_FINALLY`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-CALL_FINALLY) 推入），则将字节码计数器设置为 TOS 。 TOS 被弹出。如果TOS是异常类型（在引发异常时被推送），则从堆栈中弹出 6 个值，前三个弹出值用于重新引发异常，最后三个弹出值用于恢复异常状态。从块堆栈中删除异常处理程序块。

- `LOAD_BUILD_CLASS`

    将 `builtins .__ build_class__()` 推到堆栈上。它之后被 [`CALL_FUNCTION`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-CALL_FUNCTION) 调用来构造一个类。

- `SETUP_WITH`(*delta*)

    此操作码在 with 块开始之前执行多个操作。首先，它从上下文管理器加载 [`__exit__()`](https://docs.python.org/zh-cn/3.8/reference/datamodel.html#object.__exit__) 并将其推入到堆栈以供以后被 [`WITH_CLEANUP_START`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-WITH_CLEANUP_START) 使用。然后，调用 `__enter__()` ，并推入指向 *delta* 的 finally 块。最后，调用 `__enter__()` 方法的结果被压入堆栈。一个操作码将忽略它（ [`POP_TOP`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-POP_TOP) ），或将其存储在一个或多个变量（ [`STORE_FAST`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-STORE_FAST) 、 [`STORE_NAME`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-STORE_NAME) 或 [`UNPACK_SEQUENCE`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-UNPACK_SEQUENCE) ）中。*3.2 新版功能.*

- `WITH_CLEANUP_START`

    当 [`with`](https://docs.python.org/zh-cn/3.8/reference/compound_stmts.html#with) 语句块退出时，开始清理堆栈。在堆栈的顶部是 `NULL` （由 [`BEGIN_FINALLY`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-BEGIN_FINALLY) 推送）或者如果在 with 块中引发了异常，则推送 6 个值。下面是上下文管理器 [`__exit__()`](https://docs.python.org/zh-cn/3.8/reference/datamodel.html#object.__exit__) 或 [`__aexit__()`](https://docs.python.org/zh-cn/3.8/reference/datamodel.html#object.__aexit__) 绑定方法。如果TOS是 `NULL` ，则调用 `SECOND(None, None, None)` ，从堆栈中删除函数，离开 TOS ，并将 `None` 推送到堆栈。 否则调用 `SEVENTH(TOP, SECOND, THIRD)` ，将堆栈的底部3值向下移动，用 `NULL` 替换空位并推入 TOS 。最后拖入调用的结果。

- `WITH_CLEANUP_FINISH`

    当 [`with`](https://docs.python.org/zh-cn/3.8/reference/compound_stmts.html#with) 语句块退出时，完成清理堆栈。TOS 是 [`WITH_CLEANUP_START`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-WITH_CLEANUP_START) 推送的 `__exit__()` 或 `__aexit__()` 函数的结果。 SECOND是 `None` 或异常类型（引发异常时推入的）。从堆栈中弹出两个值。如果 SECOND 不为 None 并且 TOS 为 true ，则展开 EXCEPT_HANDLER 块，该块是在捕获异常时创建的，并将 `NULL` 推入堆栈。

以下所有操作码均使用其参数。

- `STORE_NAME`(*namei*)

    实现 `name = TOS`。 *namei* 是 *name* 在代码对象的 `co_names` 属性中的索引。 在可能的情况下，编译器会尝试使用 [`STORE_FAST`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-STORE_FAST) 或 [`STORE_GLOBAL`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-STORE_GLOBAL)。

- `DELETE_NAME`(*namei*)

    实现 `del name` ，其中 *namei* 是代码对象的 `co_names` 属性的索引。

- `UNPACK_SEQUENCE`(*count*)

    将 TOS 解包为 *count* 个单独的值，它们将按从右至左的顺序被放入堆栈。

- `UNPACK_EX`(*counts*)

    实现使用带星号的目标进行赋值：将 TOS 中的可迭代对象解包为单独的值，其中值的总数可以小于可迭代对象中的项数：新值之一将是由所有剩余项构成的列表。*counts* 的低字节是列表值之前的值的数量，*counts* 中的高字节则是之后的值的数量。 结果值会按从右至左的顺序入栈。

- `STORE_ATTR`(*namei*)

    实现 `TOS.name = TOS1`，其中 *namei* 是 name 在 `co_names` 中的索引号。

- `DELETE_ATTR`(*namei*)

    实现 `del TOS.name`，使用 *namei* 作为 `co_names` 中的索引号。

- `STORE_GLOBAL`(*namei*)

    类似于 [`STORE_NAME`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-STORE_NAME) 但会将 name 存储为全局变量。

- `DELETE_GLOBAL`(*namei*)

    类似于 [`DELETE_NAME`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-DELETE_NAME) 但会删除一个全局变量。

- `LOAD_CONST`(*consti*)

    将 `co_consts[consti]` 推入栈顶。

- `LOAD_NAME`(*namei*)

    将与 `co_names[namei]` 相关联的值推入栈顶。

- `BUILD_TUPLE`(*count*)

    创建一个使用了来自栈的 *count* 个项的元组，并将结果元组推入栈顶。

- `BUILD_LIST`(*count*)

    类似于 [`BUILD_TUPLE`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-BUILD_TUPLE) 但会创建一个列表。

- `BUILD_SET`(*count*)

    类似于 [`BUILD_TUPLE`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-BUILD_TUPLE) 但会创建一个集合。

- `BUILD_MAP`(*count*)

    将一个新字典对象推入栈顶。 弹出 `2 * count` 项使得字典包含 *count* 个条目: `{..., TOS3: TOS2, TOS1: TOS}`。*在 3.5 版更改:* 字典是根据栈中的项创建而不是创建一个预设大小包含 *count* 项的空字典。

- `BUILD_CONST_KEY_MAP`(*count*)

    专用于常量键的 [`BUILD_MAP`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-BUILD_MAP) 版本。 *count* 值是从栈中提取的。 栈顶的元素包含一个由键构成的元组。*3.6 新版功能.*

- `BUILD_STRING`(*count*)

    拼接 *count* 个来自栈的字符串并将结果字符串推入栈顶。*3.6 新版功能.*

- `BUILD_TUPLE_UNPACK`(*count*)

    从栈中弹出 *count* 个可迭代对象，将它们合并为单个元组，并将结果推入栈顶。 实现可迭代对象解包为元组形式 `(*x, *y, *z)`。*3.5 新版功能.*

- `BUILD_TUPLE_UNPACK_WITH_CALL`(*count*)

    这类似于 [`BUILD_TUPLE_UNPACK`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-BUILD_TUPLE_UNPACK) 但专用于 `f(*x, *y, *z)` 调用语法。 栈中 `count + 1` 位置上的项应当是相应的可调用对象 `f`。*3.6 新版功能.*

- `BUILD_LIST_UNPACK`(*count*)

    这类似于 [`BUILD_TUPLE_UNPACK`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-BUILD_TUPLE_UNPACK) 但会将一个列表而非元组推入栈顶。 实现可迭代对象解包为列表形式 `[*x, *y, *z]`。*3.5 新版功能.*

- `BUILD_SET_UNPACK`(*count*)

    这类似于 [`BUILD_TUPLE_UNPACK`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-BUILD_TUPLE_UNPACK) 但会将一个集合而非元组推入栈顶。 实现可迭代对象解包为集合形式 `{*x, *y, *z}`。*3.5 新版功能.*

- `BUILD_MAP_UNPACK`(*count*)

    从栈中弹出 *count* 个映射对象，将它们合并为单个字典，并将结果推入栈顶。 实现字典解包为字典形式 `{**x, **y, **z}`。*3.5 新版功能.*

- `BUILD_MAP_UNPACK_WITH_CALL`(*count*)

    这类似于 [`BUILD_MAP_UNPACK`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-BUILD_MAP_UNPACK) 但专用于 `f(**x, **y, **z)` 调用语法。 栈中 `count + 2` 位置上的项应当是相应的可调用对象 `f`。*3.5 新版功能.**在 3.6 版更改:* 可迭代对象的位置的确定方式是将操作码参数加 2 而不是将其编码到参数的第二个字节。

- `LOAD_ATTR`(*namei*)

    将 TOS 替换为 `getattr(TOS, co_names[namei])`。

- `COMPARE_OP`(*opname*)

    执行布尔运算操作。 操作名称可在 `cmp_op[opname]` 中找到。

- `IMPORT_NAME`(*namei*)

    导入模块 `co_names[namei]`。 会弹出 TOS 和 TOS1 以提供 *fromlist* 和 *level* 参数给 [`__import__()`](https://docs.python.org/zh-cn/3.8/library/functions.html#__import__)。 模块对象会被推入栈顶。 当前命名空间不受影响：对于一条标准 import 语句，会执行后续的 [`STORE_FAST`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-STORE_FAST) 指令来修改命名空间。

- `IMPORT_FROM`(*namei*)

    从在 TOS 内找到的模块中加载属性 `co_names[namei]`。 结果对象会被推入栈顶，以便由后续的 [`STORE_FAST`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-STORE_FAST) 指令来保存。

- `JUMP_FORWARD`(*delta*)

    将字节码计数器的值增加 *delta*。

- `POP_JUMP_IF_TRUE`(*target*)

    如果 TOS 为真值，则将字节码计数器的值设为 *target*。 TOS 会被弹出。*3.1 新版功能.*

- `POP_JUMP_IF_FALSE`(*target*)

    如果 TOS 为假值，则将字节码计数器的值设为 *target*。 TOS 会被弹出。*3.1 新版功能.*

- `JUMP_IF_TRUE_OR_POP`(*target*)

    如果 TOS 为真值，则将字节码计数器的值设为 *target* 并将 TOS 留在栈顶。 否则（如 TOS 为假值），TOS 会被弹出。*3.1 新版功能.*

- `JUMP_IF_FALSE_OR_POP`(*target*)

    如果 TOS 为假值，则将字节码计数器的值设为 *target* 并将 TOS 留在栈顶。 否则（如 TOS 为假值），TOS 会被弹出。*3.1 新版功能.*

- `JUMP_ABSOLUTE`(*target*)

    将字节码计数器的值设为 *target*。

- `FOR_ITER`(*delta*)

    TOS 是一个 [iterator](https://docs.python.org/zh-cn/3.8/glossary.html#term-iterator)。 可调用它的 [`__next__()`](https://docs.python.org/zh-cn/3.8/library/stdtypes.html#iterator.__next__) 方法。 如果产生了一个新值，则将其推入栈顶（将迭代器留在其下方）。 如果迭代器提示已耗尽则 TOS 会被弹出，并将字节码计数器的值增加 *delta*。

- `LOAD_GLOBAL`(*namei*)

    加载名称为 `co_names[namei]` 的全局对象推入栈顶。

- `SETUP_FINALLY`(*delta*)

    将一个来自 try-finally 或 try-except 子句的 try 代码块推入代码块栈顶。 相对 finally 代码块或第一个 except 代码块 *delta* 个点数。

- `CALL_FINALLY`(*delta*)

    将下一条指令的地址推入栈顶并将字节码计数器的值增加 *delta*。 用于将 finally 代码块作为一个“子例程”调用。*3.8 新版功能.*

- `LOAD_FAST`(*var_num*)

    将指向局部对象 `co_varnames[var_num]` 的引用推入栈顶。

- `STORE_FAST`(*var_num*)

    将 TOS 存放到局部对象 `co_varnames[var_num]`。

- `DELETE_FAST`(*var_num*)

    移除局部对象 `co_varnames[var_num]`。

- `LOAD_CLOSURE`(*i*)

    将一个包含在单元的第 *i* 个空位中的对单元的引用推入栈顶并释放可用的存储空间。 如果 *i* 小于 *co_cellvars* 的长度则变量的名称为 `co_cellvars[i]`。 否则为 `co_freevars[i - len(co_cellvars)]`。

- `LOAD_DEREF`(*i*)

    加载包含在单元的第 *i* 个空位中的单元并释放可用的存储空间。 将一个对单元所包含对象的引用推入栈顶。

- `LOAD_CLASSDEREF`(*i*)

    类似于 [`LOAD_DEREF`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-LOAD_DEREF) 但在查询单元之前会首先检查局部对象字典。 这被用于加载类语句体中的自由变量。*3.4 新版功能.*

- `STORE_DEREF`(*i*)

    将 TOS 存放到包含在单元的第 *i* 个空位中的单元内并释放可用存储空间。

- `DELETE_DEREF`(*i*)

    清空包含在单元的第 *i* 个空位中的单元并释放可用存储空间。 被用于 [`del`](https://docs.python.org/zh-cn/3.8/reference/simple_stmts.html#del) 语句。*3.2 新版功能.*

- `RAISE_VARARGS`(*argc*)

    使用 `raise` 语句的 3 种形式之一引发异常，具体形式取决于 *argc* 的值：0: `raise` (重新引发之前的异常)1: `raise TOS` (在 `TOS` 上引发异常实例或类型)2: `raise TOS1 from TOS` (在 `TOS1` 上引发异常实例或类型并将 `__cause__` 设为 `TOS`)

- `CALL_FUNCTION`(*argc*)

    调用一个可调用对象并传入位置参数。 *argc* 指明位置参数的数量。 栈顶包含位置参数，其中最右边的参数在最顶端。 在参数之下是一个待调用的可调用对象。 `CALL_FUNCTION` 会从栈中弹出所有参数以及可调用对象，附带这些参数调用该可调用对象，并将可调用对象所返回的返回值推入栈顶。*在 3.6 版更改:* 此操作码仅用于附带位置参数的调用。

- `CALL_FUNCTION_KW`(*argc*)

    调用一个可调用对象并传入位置参数（如果有的话）和关键字参数。 *argc* 指明位置参数和关键字参数的总数量。 栈顶元素包含一个关键字参数名称的元组。 在元组之下是根据元组排序的关键字参数。 在关键字参数之下是位置参数，其中最右边的参数在最顶端。 在参数之下是一个待调用的可调用对象。 `CALL_FUNCTION_KW` 会从栈中弹出所有参数以及可调用对象，附带这些参数调用该可调用对象，并将可调用对象所返回的返回值推入栈顶。*在 3.6 版更改:* 关键字参数会被打包为一个元组而非字典，*argc* 指明参数的总数量。

- `CALL_FUNCTION_EX`(*flags*)

    调用一个可调用对象并附带位置参数和关键字参数变量集合。 如果设置了 *flags* 的最低位，则栈顶包含一个由额外关键字参数组成的映射对象。 在该对象之下是一个包含位置参数的可迭代对象和一个待调用的可调用对象。 [`BUILD_MAP_UNPACK_WITH_CALL`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-BUILD_MAP_UNPACK_WITH_CALL) 和 [`BUILD_TUPLE_UNPACK_WITH_CALL`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-BUILD_TUPLE_UNPACK_WITH_CALL) 可用于合并多个映射对象和包含参数的可迭代对象。 在该可调用对象被调用之前，映射对象和可迭代对象会被分别“解包”并将它们的内容分别作为关键字参数和位置参数传入。 `CALL_FUNCTION_EX` 会从栈中弹出所有参数以及可调用对象，附带这些参数调用该可调用对象，并将可调用对象所返回的返回值推入栈顶。*3.6 新版功能.*

- `LOAD_METHOD`(*namei*)

    从 TOS 对象加载一个名为 `co_names[namei]` 的方法。 TOS 将被弹出，并且当解释器可以直接调用未绑定方法时，方法和 TOS 会被推入栈顶。 TOS 将被用作 [`CALL_METHOD`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-CALL_METHOD) 的第一个参数 (`self`)。 否则，`NULL` 和方法会被推入栈顶（方法是绑定方法或其他对象）。*3.7 新版功能.*

- `CALL_METHOD`(*argc*)

    调用一个方法。 *argc* 是位置参数的数量。 不支持关键字参数。 此操作码被设计用于配合 [`LOAD_METHOD`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-LOAD_METHOD) 使用。 位置参数放在栈顶。 在它们之下放在栈中的是由 [`LOAD_METHOD`](https://docs.python.org/zh-cn/3.8/library/dis.html#opcode-LOAD_METHOD) 所描述的两个条目。 它们会被全部弹出并将返回值推入栈顶。*3.7 新版功能.*

- `MAKE_FUNCTION`(*argc*)

    将一个新函数对象推入栈顶。 从底端到顶端，如果参数带有指定的旗标值则所使用的栈必须由这些值组成。`0x01` 一个默认值的元组，用于按位置排序的仅限位置形参以及位置或关键字形参`0x02` 一个仅限关键字形参的默认值的字典`0x04` 是一个标注字典`0x08` 一个包含用于自由变量的单元的元组，生成一个闭包与函数相关联的代码 (在 TOS1)函数的 [qualified name](https://docs.python.org/zh-cn/3.8/glossary.html#term-qualified-name) (在 TOS)

- `BUILD_SLICE`(*argc*)

    将一个切片对象推入栈顶。 *argc* 必须为 2 或 3。 如果为 2，则推入 `slice(TOS1, TOS)`；如果为 3，则推入 `slice(TOS2, TOS1, TOS)`。 请参阅 [`slice()`](https://docs.python.org/zh-cn/3.8/library/functions.html#slice) 内置函数了解详细信息。

- `EXTENDED_ARG`(*ext*)

    为任意带有大到无法放入默认的单字节的参数的操作码添加前缀。 *ext* 存放一个附加字节作为参数中的高比特位。 对于每个操作码，最多允许三个 `EXTENDED_ARG` 前缀，构成两字节到三字节的参数。

- `FORMAT_VALUE`(*flags*)

    用于实现格式化字面值字符串（f-字符串）。 从栈中弹出一个可选的 *fmt_spec*，然后是一个必须的 *value*。 *flags* 的解读方式如下：`(flags & 0x03) == 0x00`: *value* 按原样格式化。`(flags & 0x03) == 0x01`: 在格式化 *value* 之前调用其 [`str()`](https://docs.python.org/zh-cn/3.8/library/stdtypes.html#str)。`(flags & 0x03) == 0x02`: 在格式化 *value* 之前调用其 [`repr()`](https://docs.python.org/zh-cn/3.8/library/functions.html#repr)。`(flags & 0x03) == 0x03`: 在格式化 *value* 之前调用其 [`ascii()`](https://docs.python.org/zh-cn/3.8/library/functions.html#ascii)。`(flags & 0x04) == 0x04`: 从栈中弹出 *fmt_spec* 并使用它，否则使用空的 *fmt_spec*。使用 `PyObject_Format()` 执行格式化。 结果会被推入栈顶。*3.6 新版功能.*

- `HAVE_ARGUMENT`

    这不是一个真正的操作码。 它用于标明使用参数和不使用参数的操作码 (分别为 `< HAVE_ARGUMENT` 和 `>= HAVE_ARGUMENT`) 之间的分隔线。*在 3.6 版更改:* 现在每条指令都带有参数，但操作码 `< HAVE_ARGUMENT` 会忽略它。 之前仅限操作码 `>= HAVE_ARGUMENT` 带有参数。



## 操作码集合

提供这些集合用于字节码指令的自动内省：

- `dis.opname`

    操作名称的序列，可使用字节码来索引。

- `dis.opmap`

    映射操作名称到字节码的字典

- `dis.cmp_op`

    所有比较操作名称的序列。

- `dis.hasconst`

    访问常量的字节码序列。

- `dis.hasfree`

    访问自由变量的字节码序列（请注意这里所说的‘自由’是指在当前作用域中被内部作用域所引用的名称，或在外部作用域中被此作用域所引用的名称。 它 *并不* 包括对全局或内置作用域的引用）。

- `dis.hasname`

    按名称访问属性的字节码序列。

- `dis.hasjrel`

    具有相对跳转目标的字节码序列。

- `dis.hasjabs`

    具有绝对跳转目标的字节码序列。

- `dis.haslocal`

    访问局部变量的字节码序列。

- `dis.hascompare`

    布尔运算的字节码序列。