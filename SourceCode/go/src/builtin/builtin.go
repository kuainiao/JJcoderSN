// Copyright 2011 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

/*
	内置的软件包为Go的预定义标识符提供了文档。
	此处记录的项目实际上并不是内置于软件包中的，但此处的描述使godoc可以提供有关语言特殊标识符的文档。
*/
package builtin

// bool是布尔值（真和假）的集合。
type bool bool

// true和false是两个无类型的布尔值。
const (
	true  = 0 == 0 // 无类型的布尔。
	false = 0 != 0 // 无类型的布尔
)

// uint8是所有无符号的8位整数的集合。 范围：0到255
type uint8 uint8

// uint16是所有无符号16位整数的集合。 范围：0到65535。
type uint16 uint16

// uint32是所有无符号32位整数的集合。 范围：0到4294967295。
type uint32 uint32

// uint64是所有无符号64位整数的集合。 范围：0到18446744073709551615。
type uint64 uint64

// int8是所有带符号的8位整数的集合。 范围：-128至127。
type int8 int8

// int16是所有带符号的16位整数的集合。 范围：-32768至32767。
type int16 int16

// int32是所有带符号的32位整数的集合。 范围：-2147483648至2147483647。
type int32 int32

// int64是所有带符号的64位整数的集合。 范围：-9223372036854775808至9223372036854775807。
type int64 int64

// float32是所有IEEE-754 32位浮点数的集合。
type float32 float32

// float64是所有IEEE-754 64位浮点数的集合。
type float64 float64

// complex64是由float32实部和/或虚部组成的所有复数的集合。
type complex64 complex64

// omplex128是具有float64实部和/或虚部的所有复数的集合。
type complex128 complex128

// string是8位字节的所有字符串的集合，按惯例，但不一定必须表示UTF-8编码的文本。字符串可以为空，但不为零。字符串类型的值是不可变的。
type string string

// int是有符号整数类型，其大小至少为32位。但是，它是不同的类型，而不是int32的别名。
type int int

// uint是无符号整数类型，其大小至少为32位。但是，它是不同的类型，而不是uint32的别名。
type uint uint

// uintptr是一个整数类型，其大小足以容纳任何指针的位模式。
type uintptr uintptr

// byte是uint8的别名，在所有方面都等同于uint8。按照惯例，它用于将字节值与8位无符号整数值区分开。
type byte = uint8

// rune是int32的别名，代表字符的Unicode编码，采用4个字节存储，将string转成rune就意味着任何一个字符都用4个字节来存储
// 其unicode值，这样每次遍历的时候返回的就是unicode值，而不再是字节了，这样就可以解决乱码问题了(中文是三个字节，所以可以存储)
type rune = int32 // r := []rune(str)

// iota是一个预先声明的标识符，表示（通常带括号的）const声明中当前const规范的无类型整数序号。它是零索引的。
const iota = 0 // 无类型的int。

// nil是预先声明的标识符，表示指针，通道，函数，接口，映射或切片类型的零值。
var nil Type // 类型必须是指针，通道，函数，接口，映射或切片类型

// Type仅在此处用于文档目的。是任何Go类型的替代，代表任何给定函数调用的相同类型。
type Type int

// Type1此处仅用于文档目的。是任何Go类型的替代，代表任何给定函数调用的相同类型。
type Type1 int

// IntegerType此处仅用于文档目的。它是任何整数类型的替代品：int，uint，int8等。
type IntegerType int

// FloatType此处仅用于文档目的。它是浮点类型的代表float32或float64。
type FloatType float32

// ComplexType在这里仅用于文档目的。是复数类型（complex64或complex128）的替代。
type ComplexType complex64

// append内置函数将元素追加到切片的末尾。如果具有足够的容量，则将目标切片以容纳新元素。如果没有，将分配一个新的基础数组。
// 追加返回更新的切片。因此，必须将的结果存储在通常包含切片本身的变量中：
//	slice = append(slice, elem1, elem2)
//	slice = append(slice, anotherSlice...)
// 作为一种特殊情况，将字符串附加到字节片是合法的，如下所示：
//	slice = append([]byte("hello "), "world"...)
func append(slice []Type, elems ...Type) []Type

// 复制内置函数将元素从源切片复制到目标切片。（作为一种特殊情况，它还会将字符串中的字节复制到字节的一部分。）
// 源和目标可能会重叠。复制返回复制的元素数，这将是len（src）和len（dst）的最小值。
func copy(dst, src []Type) int

// delete内置函数从地图中删除具有指定键（m [key]）的元素。如果m为nil或没有此类元素，则delete为无操作。
func delete(m map[Type]Type1, key Type)

// len内置函数根据其类型返回v的长度：
//	数组：v中的元素数。
//	指向数组的指针：*v中的元素数（即使v为零）。
//	Slice, or map: v中的元素数；如果v为零，则len（v）为零。
//	String: v中的字节数。(utf8中，字母占一个字节， 汉字占3个字节)
//	Channel: 通道缓冲区中排队（未读）的元素数； 如果v为零，则len（v）为零。
//  对于某些参数，例如字符串文字或简单的数组表达式，结果可以是常量。有关详细信息，请参见Go语言规范的“长度和/或容量”部分。
func len(v Type) int

// cap内置函数根据其类型返回v的容量：
//	Array: v中的元素数（与len（v）相同）。
//	Pointer to array: *v中的元素数（与len（v）相同）。
//	Slice: 切片后切片可以达到的最大长度； 如果v为零，则cap（v）为零。
//	Channel: 信道缓冲容量，以元素为单位； 如果v为零，则cap（v）为零。
// 对于某些参数，例如简单的数组表达式，结果可以是常量。有关详细信息，请参见Go语言规范的“长度和容量”部分。
func cap(v Type) int

// make内置函数分配和初始化切片，映射或channel类型的对象（仅）。像new一样，第一个参数是类型，而不是值。
// 与new不同，make的返回类型与其参数的类型相同，而不是指向它的指针。结果的规格取决于类型：
//	Slice: size指定长度。切片的容量等于其长度。可以提供第二个整数参数来指定不同的容量；它必须不小于长度。
//	例如，make（[] int，0，10）分配一个大小为10的基础数组，并返回一个长度为0且容量为10的切片，该切片由该基础数组支持。
//	Map: 为空映射分配足够的空间来容纳指定数量的元素。该大小可以省略，在这种情况下将分配较小的起始大小。
//	Channel: 用指定的缓冲区容量初始化通道的缓冲区。如果为零，或者省略大小，则通道不缓冲。
func make(t Type, size ...IntegerType) Type

// 新的内置函数分配内存。第一个参数是类型，不是值，返回的值是指向该类型新分配的零值的指针。
func new(Type) *Type

// 复数的内置函数根据两个浮点值构造一个复杂的值。实部和虚部必须具有相同的大小float32或float64（或可分配给它们），
// 并且返回值将是对应的复数类型（对于float32为complex64，对于float64为complex128）。
func complex(r, i FloatType) ComplexType

// 实数内置函数返回复数c的实数部分。 返回值将是对应于c类型的浮点类型。
func real(c ComplexType) FloatType

// imag内置函数返回复数c的虚部。返回值将是对应于c类型的浮点类型。
func imag(c ComplexType) FloatType

// close内置函数关闭一个通道，该通道必须为双向或仅发送。应该仅由发送者执行，而不是接收者执行，
// 并且具有在接收到最后一个发送的值之后关闭通道的作用。从封闭的通道c接收到最后一个值之后，从c的任何接收都将成功不会阻塞，
// 返回通道元素的零值。 x，ok：= <-c 的形式也将封闭通道的ok设置为false。
func close(c chan<- Type)

// panic内置函数停止当前goroutine的正常执行。当函数F调用恐慌时，F的正常执行立即停止。由F推迟执行的所有函数都以常规方式运行，
// 然后F返回其调用者。对于调用者G，的调用随后就像对panic的调用一样，终止G的执行并运行任何延迟的函数。
// 这将继续执行，直到执行的goroutine中的所有函数以相反的顺序停止为止。此时，程序以非零退出代码终止。
// 此终止序列称为恐慌，可以通过内置函数restore控制。
func panic(v interface{})

// 恢复内置函数允许程序管理恐慌goroutine的行为。在恢复的函数中执行恢复的调用（但不是由它调用的任何函数），
// 通过恢复正常执行来停止恐慌序列，并检索传递给panic调用的错误值。如果在延迟函数之外调用了restore，则将不会停止恐慌序列。
// 在这种情况下，或者当goroutine不是惊慌的或提供给panic的参数为nil时，recover将返回nil。
// 因此，来自recovery的返回值将报告goroutine是否处于恐慌状态。
func recover() interface{}

// print内置函数以实现特定的方式格式化其参数，并将结果写入标准错误。打印对于引导和调试很有用；不保证保留语言。
func print(args ...Type)

// 内置的println函数以实现特定的方式格式化其参数，并将结果写入标准错误。始终在参数之间添加空格，并添加换行符。
// Println对于引导和调试很有用；不保证保留语言。
func println(args ...Type)

// 错误内置接口类型是用于表示错误状态的常规接口，nil值表示没有错误。
type error interface {
	Error() string
}
