#ifndef Py_OBJECT_H
#define Py_OBJECT_H

#include "pymem.h"   /* _Py_tracemalloc_config */

#ifdef __cplusplus
extern "C" {
#endif


/* 对象和类型对象接口 */

/*
对象是在堆上分配的结构。特殊规则适用于对象的使用，以确保正确地对其进行垃圾回收。
对象永远不会静态分配或在堆栈上分配；它们只能通过特殊的宏和函数进行访问。
（类型对象是第一个规则的例外；标准类型由静态初始化的类型对象表示，尽管对Python 2.2进行类型/类统一的工作也使得也可以具有堆分配的类型对象）。
对象的“引用计数”在复制或删除指向该对象的指针时会增加或减少。当引用计数达到零时，将没有对对象的引用，可以将其从堆中删除。
一个对象具有一个“类型”，该“类型”决定了它所代表的内容以及所包含的数据类型。对象的类型在创建时是固定的。
类型本身表示为对象；一个对象包含一个指向相应类型对象的指针。
类型本身具有指向表示类型“ type”的对象的类型指针，该类型指针包含指向自身的指针！）。
对象不会在内存中浮动；一旦分配，对象将保持相同的大小和地址。必须保存可变大小数据的对象可以包含指向对象可变大小部分的指针。
并非所有相同类型的对象都具有相同的大小。但是大小不能在分配后更改。
（这些限制是为了使对对象的引用可以只是一个指针-移动对象将需要更新所有指针，
并且如果对象旁边有另一个对象，则更改对象的大小将需要移动它。）始终通过“ PyObject *”类型的指针进行访问。
“ PyObject”类型是仅包含引用计数和类型指针的结构。为对象分配的实际内存包含其他数据，
这些数据只能在将指针转换为指向较长结构类型的指针之后才能访问。这种较长的类型必须以引用计数和类型字段开头；
宏PyObject_HEAD应该用于此目的（以适应将来的更改）。特定对象类型的实现可以将对象指针转换为正确的类型并返回。
对于包含对象数组的对象，存在一个标准接口，这些对象的数组的大小在分配对象时确定。
*/

/* Py_DEBUG表示Py_REF_DEBUG。 */
#if defined(Py_DEBUG) && !defined(Py_REF_DEBUG)
#define Py_REF_DEBUG
#endif

#if defined(Py_LIMITED_API) && defined(Py_REF_DEBUG)
#error Py_LIMITED_API is incompatible with Py_DEBUG, Py_TRACE_REFS, and Py_REF_DEBUG
#endif


#ifdef Py_TRACE_REFS
/* 定义指针以支持所有活动堆对象的双向链接列表。*/
#define _PyObject_HEAD_EXTRA            \
    struct _object *_ob_next;           \
    struct _object *_ob_prev;

#define _PyObject_EXTRA_INIT 0, 0,

#else
#define _PyObject_HEAD_EXTRA
#define _PyObject_EXTRA_INIT
#endif

/* PyObject_HEAD定义每个PyObject的初始段。 */
#define PyObject_HEAD                   PyObject ob_base;

#define PyObject_HEAD_INIT(type)        \
    { _PyObject_EXTRA_INIT              \
    1, type },

#define PyVarObject_HEAD_INIT(type, size)       \
    { PyObject_HEAD_INIT(type) size },

/* PyObject_VAR_HEAD定义所有可变大小容器对象的初始段。这些以声明具有1个元素的数组结尾，但是已经分配了足够的空间，
  因此该数组实际上有空间容纳ob_size元素。请注意，ob_size是元素计数，不一定是字节计数。
 */
#define PyObject_VAR_HEAD      PyVarObject ob_base;
#define Py_INVALID_SIZE (Py_ssize_t)-1

/* 实际上没有任何东西声明为PyObject，但是指向Python对象的每个指针都可以转换为PyObject*。
   这是手工建立的继承。类似地，指向可变大小的Python对象的每个指针也可以转换为PyVarObject*。
 */
typedef struct _object {
    _PyObject_HEAD_EXTRA
    Py_ssize_t ob_refcnt;
    struct _typeobject *ob_type;
} PyObject;

/* 将参数强制转换为PyObject *类型。 */
#define _PyObject_CAST(op) ((PyObject*)(op))

typedef struct {
    PyObject ob_base;
    Py_ssize_t ob_size; /* 可变部分中的元素数 */
} PyVarObject;

/* 将参数转换为PyVarObject *类型。 */
#define _PyVarObject_CAST(op) ((PyVarObject*)(op))

#define Py_REFCNT(ob)           (_PyObject_CAST(ob)->ob_refcnt)
#define Py_TYPE(ob)             (_PyObject_CAST(ob)->ob_type)
#define Py_SIZE(ob)             (_PyVarObject_CAST(ob)->ob_size)

/*
类型对象包含一个字符串，该字符串包含类型名称（以帮助调试），分配参数（请参见PyObject_New（）和PyObject_NewVar（））
以及用于访问该类型对象的方法。方法是可选的，nil指针表示这种类型的访问不可用。 Py_DECREF（）宏使用tp_dealloc方法而不检查nil指针。
除非实现可以保证引用计数永远不会为零（例如，对于静态分配的类型对象），否则应始终执行该操作。
注意：某些类型组的方法现在包含在单独的方法块中。
*/

typedef PyObject * (*unaryfunc)(PyObject *);
typedef PyObject * (*binaryfunc)(PyObject *, PyObject *);
typedef PyObject * (*ternaryfunc)(PyObject *, PyObject *, PyObject *);
typedef int (*inquiry)(PyObject *);
typedef Py_ssize_t (*lenfunc)(PyObject *);
typedef PyObject *(*ssizeargfunc)(PyObject *, Py_ssize_t);
typedef PyObject *(*ssizessizeargfunc)(PyObject *, Py_ssize_t, Py_ssize_t);
typedef int(*ssizeobjargproc)(PyObject *, Py_ssize_t, PyObject *);
typedef int(*ssizessizeobjargproc)(PyObject *, Py_ssize_t, Py_ssize_t, PyObject *);
typedef int(*objobjargproc)(PyObject *, PyObject *, PyObject *);

typedef int (*objobjproc)(PyObject *, PyObject *);
typedef int (*visitproc)(PyObject *, void *);
typedef int (*traverseproc)(PyObject *, visitproc, void *);


typedef void (*freefunc)(void *);
typedef void (*destructor)(PyObject *);
typedef PyObject *(*getattrfunc)(PyObject *, char *);
typedef PyObject *(*getattrofunc)(PyObject *, PyObject *);
typedef int (*setattrfunc)(PyObject *, char *, PyObject *);
typedef int (*setattrofunc)(PyObject *, PyObject *, PyObject *);
typedef PyObject *(*reprfunc)(PyObject *);
typedef Py_hash_t (*hashfunc)(PyObject *);
typedef PyObject *(*richcmpfunc) (PyObject *, PyObject *, int);
typedef PyObject *(*getiterfunc) (PyObject *);
typedef PyObject *(*iternextfunc) (PyObject *);
typedef PyObject *(*descrgetfunc) (PyObject *, PyObject *, PyObject *);
typedef int (*descrsetfunc) (PyObject *, PyObject *, PyObject *);
typedef int (*initproc)(PyObject *, PyObject *, PyObject *);
typedef PyObject *(*newfunc)(struct _typeobject *, PyObject *, PyObject *);
typedef PyObject *(*allocfunc)(struct _typeobject *, Py_ssize_t);

#ifdef Py_LIMITED_API
/* 在Py_LIMITED_API中，PyTypeObject是不透明的结构。 */
typedef struct _typeobject PyTypeObject;
#else
/* PyTypeObject在cpython / object.h中定义 */
#endif

typedef struct{
    int slot;    /* slot id, see below */
    void *pfunc; /* function pointer */
} PyType_Slot;

typedef struct{
    const char* name;
    int basicsize;
    int itemsize;
    unsigned int flags;
    PyType_Slot *slots; /* terminated by slot==0. */
} PyType_Spec;

PyAPI_FUNC(PyObject*) PyType_FromSpec(PyType_Spec*);
#if !defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x03030000
PyAPI_FUNC(PyObject*) PyType_FromSpecWithBases(PyType_Spec*, PyObject*);
#endif
#if !defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x03040000
PyAPI_FUNC(void*) PyType_GetSlot(struct _typeobject*, int);
#endif

/* Generic type check */
PyAPI_FUNC(int) PyType_IsSubtype(struct _typeobject *, struct _typeobject *);
#define PyObject_TypeCheck(ob, tp) \
    (Py_TYPE(ob) == (tp) || PyType_IsSubtype(Py_TYPE(ob), (tp)))

PyAPI_DATA(struct _typeobject) PyType_Type; /* built-in 'type' */
PyAPI_DATA(struct _typeobject) PyBaseObject_Type; /* built-in 'object' */
PyAPI_DATA(struct _typeobject) PySuper_Type; /* built-in 'super' */

PyAPI_FUNC(unsigned long) PyType_GetFlags(struct _typeobject*);

#define PyType_Check(op) \
    PyType_FastSubclass(Py_TYPE(op), Py_TPFLAGS_TYPE_SUBCLASS)
#define PyType_CheckExact(op) (Py_TYPE(op) == &PyType_Type)

PyAPI_FUNC(int) PyType_Ready(struct _typeobject *);
PyAPI_FUNC(PyObject *) PyType_GenericAlloc(struct _typeobject *, Py_ssize_t);
PyAPI_FUNC(PyObject *) PyType_GenericNew(struct _typeobject *,
                                               PyObject *, PyObject *);
PyAPI_FUNC(unsigned int) PyType_ClearCache(void);
PyAPI_FUNC(void) PyType_Modified(struct _typeobject *);

/* Generic operations on objects */
PyAPI_FUNC(PyObject *) PyObject_Repr(PyObject *);
PyAPI_FUNC(PyObject *) PyObject_Str(PyObject *);
PyAPI_FUNC(PyObject *) PyObject_ASCII(PyObject *);
PyAPI_FUNC(PyObject *) PyObject_Bytes(PyObject *);
PyAPI_FUNC(PyObject *) PyObject_RichCompare(PyObject *, PyObject *, int);
PyAPI_FUNC(int) PyObject_RichCompareBool(PyObject *, PyObject *, int);
PyAPI_FUNC(PyObject *) PyObject_GetAttrString(PyObject *, const char *);
PyAPI_FUNC(int) PyObject_SetAttrString(PyObject *, const char *, PyObject *);
PyAPI_FUNC(int) PyObject_HasAttrString(PyObject *, const char *);
PyAPI_FUNC(PyObject *) PyObject_GetAttr(PyObject *, PyObject *);
PyAPI_FUNC(int) PyObject_SetAttr(PyObject *, PyObject *, PyObject *);
PyAPI_FUNC(int) PyObject_HasAttr(PyObject *, PyObject *);
PyAPI_FUNC(PyObject *) PyObject_SelfIter(PyObject *);
PyAPI_FUNC(PyObject *) PyObject_GenericGetAttr(PyObject *, PyObject *);
PyAPI_FUNC(int) PyObject_GenericSetAttr(PyObject *,
                                              PyObject *, PyObject *);
#if !defined(Py_LIMITED_API) || Py_LIMITED_API+0 >= 0x03030000
PyAPI_FUNC(int) PyObject_GenericSetDict(PyObject *, PyObject *, void *);
#endif
PyAPI_FUNC(Py_hash_t) PyObject_Hash(PyObject *);
PyAPI_FUNC(Py_hash_t) PyObject_HashNotImplemented(PyObject *);
PyAPI_FUNC(int) PyObject_IsTrue(PyObject *);
PyAPI_FUNC(int) PyObject_Not(PyObject *);
PyAPI_FUNC(int) PyCallable_Check(PyObject *);
PyAPI_FUNC(void) PyObject_ClearWeakRefs(PyObject *);

/* PyObject_Dir(obj) acts like Python builtins.dir(obj), returning a
   list of strings.  PyObject_Dir(NULL) is like builtins.dir(),
   returning the names of the current locals.  In this case, if there are
   no current locals, NULL is returned, and PyErr_Occurred() is false.
*/
PyAPI_FUNC(PyObject *) PyObject_Dir(PyObject *);


/* Helpers for printing recursive container types */
PyAPI_FUNC(int) Py_ReprEnter(PyObject *);
PyAPI_FUNC(void) Py_ReprLeave(PyObject *);

/* Flag bits for printing: */
#define Py_PRINT_RAW    1       /* No string quotes etc. */

/*
Type flags (tp_flags)

These flags are used to change expected features and behavior for a
particular type.

Arbitration of the flag bit positions will need to be coordinated among
all extension writers who publicly release their extensions (this will
be fewer than you might expect!).

Most flags were removed as of Python 3.0 to make room for new flags.  (Some
flags are not for backwards compatibility but to indicate the presence of an
optional feature; these flags remain of course.)

Type definitions should use Py_TPFLAGS_DEFAULT for their tp_flags value.

Code can use PyType_HasFeature(type_ob, flag_value) to test whether the
given type object has a specified feature.
*/

/* Set if the type object is dynamically allocated */
#define Py_TPFLAGS_HEAPTYPE (1UL << 9)

/* Set if the type allows subclassing */
#define Py_TPFLAGS_BASETYPE (1UL << 10)

/* Set if the type implements the vectorcall protocol (PEP 590) */
#ifndef Py_LIMITED_API
#define _Py_TPFLAGS_HAVE_VECTORCALL (1UL << 11)
#endif

/* Set if the type is 'ready' -- fully initialized */
#define Py_TPFLAGS_READY (1UL << 12)

/* Set while the type is being 'readied', to prevent recursive ready calls */
#define Py_TPFLAGS_READYING (1UL << 13)

/* Objects support garbage collection (see objimpl.h) */
#define Py_TPFLAGS_HAVE_GC (1UL << 14)

/* These two bits are preserved for Stackless Python, next after this is 17 */
#ifdef STACKLESS
#define Py_TPFLAGS_HAVE_STACKLESS_EXTENSION (3UL << 15)
#else
#define Py_TPFLAGS_HAVE_STACKLESS_EXTENSION 0
#endif

/* Objects behave like an unbound method */
#define Py_TPFLAGS_METHOD_DESCRIPTOR (1UL << 17)

/* Objects support type attribute cache */
#define Py_TPFLAGS_HAVE_VERSION_TAG   (1UL << 18)
#define Py_TPFLAGS_VALID_VERSION_TAG  (1UL << 19)

/* Type is abstract and cannot be instantiated */
#define Py_TPFLAGS_IS_ABSTRACT (1UL << 20)

/* These flags are used to determine if a type is a subclass. */
#define Py_TPFLAGS_LONG_SUBCLASS        (1UL << 24)
#define Py_TPFLAGS_LIST_SUBCLASS        (1UL << 25)
#define Py_TPFLAGS_TUPLE_SUBCLASS       (1UL << 26)
#define Py_TPFLAGS_BYTES_SUBCLASS       (1UL << 27)
#define Py_TPFLAGS_UNICODE_SUBCLASS     (1UL << 28)
#define Py_TPFLAGS_DICT_SUBCLASS        (1UL << 29)
#define Py_TPFLAGS_BASE_EXC_SUBCLASS    (1UL << 30)
#define Py_TPFLAGS_TYPE_SUBCLASS        (1UL << 31)

#define Py_TPFLAGS_DEFAULT  ( \
                 Py_TPFLAGS_HAVE_STACKLESS_EXTENSION | \
                 Py_TPFLAGS_HAVE_VERSION_TAG | \
                0)

/* NOTE: The following flags reuse lower bits (removed as part of the
 * Python 3.0 transition). */

/* The following flag is kept for compatibility. Starting with 3.8,
 * binary compatibility of C extensions across feature releases of
 * Python is not supported anymore, except when using the stable ABI.
 */

/* Type structure has tp_finalize member (3.4) */
#define Py_TPFLAGS_HAVE_FINALIZE (1UL << 0)

#ifdef Py_LIMITED_API
#  define PyType_HasFeature(t,f)  ((PyType_GetFlags(t) & (f)) != 0)
#endif
#define PyType_FastSubclass(t,f)  PyType_HasFeature(t,f)


/*
The macros Py_INCREF(op) and Py_DECREF(op) are used to increment or decrement
reference counts.  Py_DECREF calls the object's deallocator function when
the refcount falls to 0; for
objects that don't contain references to other objects or heap memory
this can be the standard function free().  Both macros can be used
wherever a void expression is allowed.  The argument must not be a
NULL pointer.  If it may be NULL, use Py_XINCREF/Py_XDECREF instead.
The macro _Py_NewReference(op) initialize reference counts to 1, and
in special builds (Py_REF_DEBUG, Py_TRACE_REFS) performs additional
bookkeeping appropriate to the special build.

We assume that the reference count field can never overflow; this can
be proven when the size of the field is the same as the pointer size, so
we ignore the possibility.  Provided a C int is at least 32 bits (which
is implicitly assumed in many parts of this code), that's enough for
about 2**31 references to an object.

XXX The following became out of date in Python 2.2, but I'm not sure
XXX what the full truth is now.  Certainly, heap-allocated type objects
XXX can and should be deallocated.
Type objects should never be deallocated; the type pointer in an object
is not considered to be a reference to the type object, to save
complications in the deallocation function.  (This is actually a
decision that's up to the implementer of each new type so if you want,
you can count such references to the type object.)
*/

/* First define a pile of simple helper macros, one set per special
 * build symbol.  These either expand to the obvious things, or to
 * nothing at all when the special mode isn't in effect.  The main
 * macros can later be defined just once then, yet expand to different
 * things depending on which special build options are and aren't in effect.
 * Trust me <wink>:  while painful, this is 20x easier to understand than,
 * e.g, defining _Py_NewReference five different times in a maze of nested
 * #ifdefs (we used to do that -- it was impenetrable).
 */
#ifdef Py_REF_DEBUG
PyAPI_DATA(Py_ssize_t) _Py_RefTotal;
PyAPI_FUNC(void) _Py_NegativeRefcount(const char *filename, int lineno,
                                      PyObject *op);
PyAPI_FUNC(Py_ssize_t) _Py_GetRefTotal(void);
#define _Py_INC_REFTOTAL        _Py_RefTotal++
#define _Py_DEC_REFTOTAL        _Py_RefTotal--

/* Py_REF_DEBUG also controls the display of refcounts and memory block
 * allocations at the interactive prompt and at interpreter shutdown
 */
PyAPI_FUNC(void) _PyDebug_PrintTotalRefs(void);
#else
#define _Py_INC_REFTOTAL
#define _Py_DEC_REFTOTAL
#endif /* Py_REF_DEBUG */

#ifdef COUNT_ALLOCS
PyAPI_FUNC(void) _Py_inc_count(struct _typeobject *);
PyAPI_FUNC(void) _Py_dec_count(struct _typeobject *);
#define _Py_INC_TPALLOCS(OP)    _Py_inc_count(Py_TYPE(OP))
#define _Py_INC_TPFREES(OP)     _Py_dec_count(Py_TYPE(OP))
#define _Py_DEC_TPFREES(OP)     Py_TYPE(OP)->tp_frees--
#define _Py_COUNT_ALLOCS_COMMA  ,
#else
#define _Py_INC_TPALLOCS(OP)
#define _Py_INC_TPFREES(OP)
#define _Py_DEC_TPFREES(OP)
#define _Py_COUNT_ALLOCS_COMMA
#endif /* COUNT_ALLOCS */

/* Update the Python traceback of an object. This function must be called
   when a memory block is reused from a free list. */
PyAPI_FUNC(int) _PyTraceMalloc_NewReference(PyObject *op);

#ifdef Py_TRACE_REFS
/* Py_TRACE_REFS is such major surgery that we call external routines. */
PyAPI_FUNC(void) _Py_NewReference(PyObject *);
PyAPI_FUNC(void) _Py_ForgetReference(PyObject *);
PyAPI_FUNC(void) _Py_PrintReferences(FILE *);
PyAPI_FUNC(void) _Py_PrintReferenceAddresses(FILE *);
PyAPI_FUNC(void) _Py_AddToAllObjects(PyObject *, int force);
#else
/* Without Py_TRACE_REFS, there's little enough to do that we expand code
   inline. */
static inline void _Py_NewReference(PyObject *op)
{
    if (_Py_tracemalloc_config.tracing) {
        _PyTraceMalloc_NewReference(op);
    }
    _Py_INC_TPALLOCS(op);
    _Py_INC_REFTOTAL;
    Py_REFCNT(op) = 1;
}

static inline void _Py_ForgetReference(PyObject *op)
{
    (void)op; /* may be unused, shut up -Wunused-parameter */
    _Py_INC_TPFREES(op);
}
#endif /* !Py_TRACE_REFS */


PyAPI_FUNC(void) _Py_Dealloc(PyObject *);

static inline void _Py_INCREF(PyObject *op)
{
    _Py_INC_REFTOTAL;
    op->ob_refcnt++;
}

#define Py_INCREF(op) _Py_INCREF(_PyObject_CAST(op))

static inline void _Py_DECREF(const char *filename, int lineno,
                              PyObject *op)
{
    (void)filename; /* may be unused, shut up -Wunused-parameter */
    (void)lineno; /* may be unused, shut up -Wunused-parameter */
    _Py_DEC_REFTOTAL;
    if (--op->ob_refcnt != 0) {
#ifdef Py_REF_DEBUG
        if (op->ob_refcnt < 0) {
            _Py_NegativeRefcount(filename, lineno, op);
        }
#endif
    }
    else {
        _Py_Dealloc(op);
    }
}

#define Py_DECREF(op) _Py_DECREF(__FILE__, __LINE__, _PyObject_CAST(op))


/* Safely decref `op` and set `op` to NULL, especially useful in tp_clear
 * and tp_dealloc implementations.
 *
 * Note that "the obvious" code can be deadly:
 *
 *     Py_XDECREF(op);
 *     op = NULL;
 *
 * Typically, `op` is something like self->containee, and `self` is done
 * using its `containee` member.  In the code sequence above, suppose
 * `containee` is non-NULL with a refcount of 1.  Its refcount falls to
 * 0 on the first line, which can trigger an arbitrary amount of code,
 * possibly including finalizers (like __del__ methods or weakref callbacks)
 * coded in Python, which in turn can release the GIL and allow other threads
 * to run, etc.  Such code may even invoke methods of `self` again, or cause
 * cyclic gc to trigger, but-- oops! --self->containee still points to the
 * object being torn down, and it may be in an insane state while being torn
 * down.  This has in fact been a rich historic source of miserable (rare &
 * hard-to-diagnose) segfaulting (and other) bugs.
 *
 * The safe way is:
 *
 *      Py_CLEAR(op);
 *
 * That arranges to set `op` to NULL _before_ decref'ing, so that any code
 * triggered as a side-effect of `op` getting torn down no longer believes
 * `op` points to a valid object.
 *
 * There are cases where it's safe to use the naive code, but they're brittle.
 * For example, if `op` points to a Python integer, you know that destroying
 * one of those can't cause problems -- but in part that relies on that
 * Python integers aren't currently weakly referencable.  Best practice is
 * to use Py_CLEAR() even if you can't think of a reason for why you need to.
 */
#define Py_CLEAR(op)                            \
    do {                                        \
        PyObject *_py_tmp = _PyObject_CAST(op); \
        if (_py_tmp != NULL) {                  \
            (op) = NULL;                        \
            Py_DECREF(_py_tmp);                 \
        }                                       \
    } while (0)

/* Function to use in case the object pointer can be NULL: */
static inline void _Py_XINCREF(PyObject *op)
{
    if (op != NULL) {
        Py_INCREF(op);
    }
}

#define Py_XINCREF(op) _Py_XINCREF(_PyObject_CAST(op))

static inline void _Py_XDECREF(PyObject *op)
{
    if (op != NULL) {
        Py_DECREF(op);
    }
}

#define Py_XDECREF(op) _Py_XDECREF(_PyObject_CAST(op))

/*
These are provided as conveniences to Python runtime embedders, so that
they can have object code that is not dependent on Python compilation flags.
*/
PyAPI_FUNC(void) Py_IncRef(PyObject *);
PyAPI_FUNC(void) Py_DecRef(PyObject *);

/*
_Py_NoneStruct is an object of undefined type which can be used in contexts
where NULL (nil) is not suitable (since NULL often means 'error').

Don't forget to apply Py_INCREF() when returning this value!!!
*/
PyAPI_DATA(PyObject) _Py_NoneStruct; /* Don't use this directly */
#define Py_None (&_Py_NoneStruct)

/* Macro for returning Py_None from a function */
#define Py_RETURN_NONE return Py_INCREF(Py_None), Py_None

/*
Py_NotImplemented is a singleton used to signal that an operation is
not implemented for a given type combination.
*/
PyAPI_DATA(PyObject) _Py_NotImplementedStruct; /* Don't use this directly */
#define Py_NotImplemented (&_Py_NotImplementedStruct)

/* Macro for returning Py_NotImplemented from a function */
#define Py_RETURN_NOTIMPLEMENTED \
    return Py_INCREF(Py_NotImplemented), Py_NotImplemented

/* Rich comparison opcodes */
#define Py_LT 0
#define Py_LE 1
#define Py_EQ 2
#define Py_NE 3
#define Py_GT 4
#define Py_GE 5

/*
 * Macro for implementing rich comparisons
 *
 * Needs to be a macro because any C-comparable type can be used.
 */
#define Py_RETURN_RICHCOMPARE(val1, val2, op)                               \
    do {                                                                    \
        switch (op) {                                                       \
        case Py_EQ: if ((val1) == (val2)) Py_RETURN_TRUE; Py_RETURN_FALSE;  \
        case Py_NE: if ((val1) != (val2)) Py_RETURN_TRUE; Py_RETURN_FALSE;  \
        case Py_LT: if ((val1) < (val2)) Py_RETURN_TRUE; Py_RETURN_FALSE;   \
        case Py_GT: if ((val1) > (val2)) Py_RETURN_TRUE; Py_RETURN_FALSE;   \
        case Py_LE: if ((val1) <= (val2)) Py_RETURN_TRUE; Py_RETURN_FALSE;  \
        case Py_GE: if ((val1) >= (val2)) Py_RETURN_TRUE; Py_RETURN_FALSE;  \
        default:                                                            \
            Py_UNREACHABLE();                                               \
        }                                                                   \
    } while (0)


/*
More conventions
================

Argument Checking
-----------------

Functions that take objects as arguments normally don't check for nil
arguments, but they do check the type of the argument, and return an
error if the function doesn't apply to the type.

Failure Modes
-------------

Functions may fail for a variety of reasons, including running out of
memory.  This is communicated to the caller in two ways: an error string
is set (see errors.h), and the function result differs: functions that
normally return a pointer return NULL for failure, functions returning
an integer return -1 (which could be a legal return value too!), and
other functions return 0 for success and -1 for failure.
Callers should always check for errors before using the result.  If
an error was set, the caller must either explicitly clear it, or pass
the error on to its caller.

Reference Counts
----------------

It takes a while to get used to the proper usage of reference counts.

Functions that create an object set the reference count to 1; such new
objects must be stored somewhere or destroyed again with Py_DECREF().
Some functions that 'store' objects, such as PyTuple_SetItem() and
PyList_SetItem(),
don't increment the reference count of the object, since the most
frequent use is to store a fresh object.  Functions that 'retrieve'
objects, such as PyTuple_GetItem() and PyDict_GetItemString(), also
don't increment
the reference count, since most frequently the object is only looked at
quickly.  Thus, to retrieve an object and store it again, the caller
must call Py_INCREF() explicitly.

NOTE: functions that 'consume' a reference count, like
PyList_SetItem(), consume the reference even if the object wasn't
successfully stored, to simplify error handling.

It seems attractive to make other functions that take an object as
argument consume a reference count; however, this may quickly get
confusing (even the current practice is already confusing).  Consider
it carefully, it may save lots of calls to Py_INCREF() and Py_DECREF() at
times.
*/


/* Trashcan mechanism, thanks to Christian Tismer.

When deallocating a container object, it's possible to trigger an unbounded
chain of deallocations, as each Py_DECREF in turn drops the refcount on "the
next" object in the chain to 0.  This can easily lead to stack overflows,
especially in threads (which typically have less stack space to work with).

A container object can avoid this by bracketing the body of its tp_dealloc
function with a pair of macros:

static void
mytype_dealloc(mytype *p)
{
    ... declarations go here ...

    PyObject_GC_UnTrack(p);        // must untrack first
    Py_TRASHCAN_BEGIN(p, mytype_dealloc)
    ... The body of the deallocator goes here, including all calls ...
    ... to Py_DECREF on contained objects.                         ...
    Py_TRASHCAN_END                // there should be no code after this
}

CAUTION:  Never return from the middle of the body!  If the body needs to
"get out early", put a label immediately before the Py_TRASHCAN_END
call, and goto it.  Else the call-depth counter (see below) will stay
above 0 forever, and the trashcan will never get emptied.

How it works:  The BEGIN macro increments a call-depth counter.  So long
as this counter is small, the body of the deallocator is run directly without
further ado.  But if the counter gets large, it instead adds p to a list of
objects to be deallocated later, skips the body of the deallocator, and
resumes execution after the END macro.  The tp_dealloc routine then returns
without deallocating anything (and so unbounded call-stack depth is avoided).

When the call stack finishes unwinding again, code generated by the END macro
notices this, and calls another routine to deallocate all the objects that
may have been added to the list of deferred deallocations.  In effect, a
chain of N deallocations is broken into (N-1)/(PyTrash_UNWIND_LEVEL-1) pieces,
with the call stack never exceeding a depth of PyTrash_UNWIND_LEVEL.

Since the tp_dealloc of a subclass typically calls the tp_dealloc of the base
class, we need to ensure that the trashcan is only triggered on the tp_dealloc
of the actual class being deallocated. Otherwise we might end up with a
partially-deallocated object. To check this, the tp_dealloc function must be
passed as second argument to Py_TRASHCAN_BEGIN().
*/

/* The new thread-safe private API, invoked by the macros below. */
PyAPI_FUNC(void) _PyTrash_thread_deposit_object(PyObject*);
PyAPI_FUNC(void) _PyTrash_thread_destroy_chain(void);

#define PyTrash_UNWIND_LEVEL 50

#define Py_TRASHCAN_BEGIN_CONDITION(op, cond) \
    do { \
        PyThreadState *_tstate = NULL; \
        /* If "cond" is false, then _tstate remains NULL and the deallocator \
         * is run normally without involving the trashcan */ \
        if (cond) { \
            _tstate = PyThreadState_GET(); \
            if (_tstate->trash_delete_nesting >= PyTrash_UNWIND_LEVEL) { \
                /* Store the object (to be deallocated later) and jump past \
                 * Py_TRASHCAN_END, skipping the body of the deallocator */ \
                _PyTrash_thread_deposit_object(_PyObject_CAST(op)); \
                break; \
            } \
            ++_tstate->trash_delete_nesting; \
        }
        /* The body of the deallocator is here. */
#define Py_TRASHCAN_END \
        if (_tstate) { \
            --_tstate->trash_delete_nesting; \
            if (_tstate->trash_delete_later && _tstate->trash_delete_nesting <= 0) \
                _PyTrash_thread_destroy_chain(); \
        } \
    } while (0);

#define Py_TRASHCAN_BEGIN(op, dealloc) Py_TRASHCAN_BEGIN_CONDITION(op, \
        Py_TYPE(op)->tp_dealloc == (destructor)(dealloc))

/* For backwards compatibility, these macros enable the trashcan
 * unconditionally */
#define Py_TRASHCAN_SAFE_BEGIN(op) Py_TRASHCAN_BEGIN_CONDITION(op, 1)
#define Py_TRASHCAN_SAFE_END(op) Py_TRASHCAN_END


#ifndef Py_LIMITED_API
#  define Py_CPYTHON_OBJECT_H
#  include  "cpython/object.h"
#  undef Py_CPYTHON_OBJECT_H
#endif

#ifdef __cplusplus
}
#endif
#endif /* !Py_OBJECT_H */
