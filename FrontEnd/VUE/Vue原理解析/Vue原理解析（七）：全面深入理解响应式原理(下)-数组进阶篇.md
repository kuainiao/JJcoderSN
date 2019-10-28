# Vue原理解析（七）：全面深入理解响应式原理(下)-数组进阶篇

再初步了解了响应式的原理后，接下来我们深入响应式，解析数组响应式的原理。

### 数组更新

首先来看下改变数组的两种方式：

```
export default {
  data() {
    list: [1, 2, 3]
  },
  methods: {
    changeArr1() {  // 重新赋值
      this.list = [4, 5, 6]
    },
    changeArr2() {  // 方法改变
      this.list.push(7)
    }
  }
}
复制代码
```

对于这两种改变数据的方式，`vue`内部的实现并不相同。

> #### 方式一：重新赋值

- 实现原理和对象是一样的，再`vm._render()`时有用到`list`，就将依赖收集起来，重新赋值后走对象派发更新的那一套。

> #### 方式二：方法改变

- 走对象的那一套就不行了，因为并不是重新赋值，虽然改变了数组自身但并不会触发`set`，原有的响应式系统根本感知不到，所以我们接下来就分析，`vue`是如何解决使用数组方法改变自身触发视图的。

### Dep收集依赖的位置

上一篇它的声音并不大，现在我们来重新认识它。`Dep`类的主要作用就是管理依赖，在响应式系统中会有两个地方要实例化它，当然它们都会进行依赖的收集，首先是之前具体包装的时候：

```
function defineReactive(obj, key, val) {
  const dep = new Dep()  // 自动依赖管理器
  ...
  Object.defineProperty(obj, key, {
    get() {...},
    set() {...}
  })
}
复制代码
```

这里它会对每个读取到的`key`都进行依赖收集，无论是对象/数组/原始类型，如果是通过重新赋值触发`set`就会使用这里收集到的依赖进行更新，笔者这里就把它命名为自动依赖管理器，方便和之后的区分。

还有一个地方也会对它进行实例化就是`Observer`类中：

```
class Observer {
  constructor(value) {
    this.dep = new Dep() //  手动依赖管理器
    ...
  }
}
复制代码
```

这个依赖管理器并不能通过`set`触发，而且是只会收集对象/数组的依赖。也就是说对象的依赖会被收集两次，一次在自动依赖管理器内，一次在这里，为什么要收集两次，本章之后说明。而最重要的是数组使用方法改变自身去触发更新的依赖就是再这收集的，这个前提还是很有必要交代下的。

### 数组的响应式原理

> #### 数组响应式数据的创建

```
数组示例：
export default {
  data() {
    return {
      list: [{
        name: 'cc',
        sex: 'man'
      }, {
        name: 'ww',
        sex: 'woman'
      }]
    }
  }
}
复制代码
```

流程开始还是执行`observe`方法，接下来我们更加详细分析响应式系统：

```
function observe(value) {
  if (!isObject(value) { //不是数组或对象，再见
    return
  }
  
  let ob
  if(hasOwn(value, '__ob__') && value.__ob__ instanceof Observer) {  // 避免重复包装
    ob = value.__ob__
  } else {
    ob = new Observer(value)
  }
  return ob
}
复制代码
```

只要是响应式的数据都会有一个`__ob__`的属性，它是在`Observer`类中挂载的，如果已经有`__ob__`属性就直接赋值给`ob`，不会再次去创建`Observer`实例，避免重复包装。首次肯定没`__ob__`属性了，所以再重新看下`Observer`类的定义：

```
class Observer {
  constructor(value) {
    this.value = value
    this.dep = new Dep()  // 手动依赖管理器
    
    def(value, '__ob__', this)  // 挂载__ob__属性，三个参数
    ...
  }
}
复制代码
```

首先定义一个手动依赖管理器，然后挂载一个不可枚举的`__ob__`属性到传入的`value`下，表示它的一个响应式的数据，而且`__ob__`的值就是当前`Observer`类的实例，它拥有实例上的所有属性和方法，这很重要，我们接下来看下`def`是如何完成属性挂载的：

```
function def (obj, key, val, enumerable) {
  Object.defineProperty(obj, key, {
    value: val,
    enumerable: !!enumerable,
    writable: true,
    configurable: true
  })
}
复制代码
```

其实就是一个简单的封装，如果第四个参数不传，`enumerable`项就是不可枚举的了。接着看`Observer`类的定义：

```
class Observer {
  constructor(value) {
	...
    if (Array.isArray(value)) {  // 数组
      ...
    } else {  // 对象
      this.walk(value)  // {list: [{...}, {...}]}
    }
  }
  
  walk (obj) {
    const keys = Object.keys(obj)
    for (let i = 0; i < keys.length; i++) {
      defineReactive(obj, keys[i])
    }
  }
}
复制代码
```

首次传入还是对象的格式，所以会执行`walk`遍历的将对象每个属性包装为响应式的，再来看下`defineReactive`方法：

```
function defineReactive(obj, key, val) { 

  const dep = new Dep()  // 自动依赖管理器
  
  val = obj[key]  // val为数组 [{...}, {...}]
  
  let childOb = observe(val)  // 传入到observe里，返回Observer类实例
  
  Object.defineProperty(obj, key, {
    enumerable: true,
    configurable: true,
    get() {  // 依赖收集
      if (Dep.target) {
        dep.depend()  // 自动依赖管理器收集依赖
        if (childOb) {  // 只有对象或数组才有返回值
          childOb.dep.depend()  // 手动依赖管理器收集依赖
          if (Array.isArray(val)) { 如果是数组
            dependArray(val) // 将数组每一项包装为响应式
          }
        }
      }
      return value
    },
    set(newVal) {
      ...
    }
  }
}
复制代码
```

首先递归执行`observe(val)`会有一个返回值了，如果是对象或数组的话，`childOb`就是`Observer`类的实例，以数组格式在`observe`内做了什么，我们之后分析。接下来在`get`内的`childOb.dep.depend()`执行的就是`Observer`类里定义的`dep`进行依赖收集，收集的`render-watcher`跟自动依赖管理器是一样的。接下来如果是数组就执行`dependArray`方法：

```
function dependArray (value) {
  for (let e, i = 0, i < value.length; i++) {
    e = value[i]
    e && e.__ob__ && e.__ob__.dep.depend()  // 是响应式数据
    if (Array.isArray(e)) {  // 如果是嵌套数组
      dependArray(e)  // 递归调用自己
    }
  }
}
复制代码
```

这个方法的作用就是递归的为每一项收集依赖，这里每一项都必须要有`__ob__`属性，然后执行`Observer`类里的`dep`手动依赖收集器进行依赖收集。我们现在知道数组的依赖是放在`Observer`类里的`dep`属性内，现在来看下怎么去更新这个收集到的依赖。

### 数组方法更新依赖

在之前`defineReactive`方法里有这么一句，`let childOb = observe(val)`，通过求值，`val`现在就是具体的数组，以数组的形式传入到`observe`方法内，我们来看下在`Observer`类中做什么：

```
class Observer {
  constructor(value) {
    if (Array.isArray(value)) {  // 数组
      
      const augment = hasProto ? protoAugment : copyAugment  // 第一句
      
      augment(value, arrayMethods, arrayKeys)  // 第二句
      
      this.observeArray(value)  // 第三句
      
    }
  }
}
复制代码
```

主要就是执行了三句逻辑，所以我们首先来看下分别做了什么。

> 数组方法改变自身触发视图原理：首先覆盖数组的`__proto__`隐式原型，借用数组原生的方法，定义`vue`内部自定义的数组异变方法拦截原生方法，再调用异变方法改变自身之后手动触发依赖。

有了这只指向月亮的手，我们现在就一起去往心中的月亮。首先分析第一句：

```
const augment = hasProto ? protoAugment : copyAugment

--------------------------------------------------------

const hasProto = '__proto__' in {}

function protoAugment (target, src) {  // src为拦截器
  target.__proto__ = src
}

function copyAugment (target, src, keys) {  // src为拦截器
  for (let i = 0; i < keys.length; i++) {
    const key = keys[i]
    def(target, key, src[key])
  }
}
复制代码
```

`__proto__`这个属性并不是所有浏览器都有的，笔者之前也一直以为这是一个通用属性，原来`IE11`才开始有这个属性，通过`'__protp__' in {}`也可以快速判断当前浏览浏览器是否`IE10`以上？确实用过，好用！

是否有`__proto__`属性处理方法也不相同，如果有的的话，直接在`protoAugment`方法内使用拦截器覆盖；如果没有`__proto__`属性，那就在当前调用数组下挂载拦截器里的异变数组方法。

实现原理都是根据原型链的特性，再数组使用原生方法之前加一个拦截器，拦截器内定义的都是可以改变数组自身的异变方法，如果拦截器内没有就向一层去找。

接下来分析第二句，也是整个数组方法实现的核心：

```
augment(value, arrayMethods, arrayKeys)

----------------------------------------------------------------------------

const arrayProto = Array.prototype  // 数组原型，有所有数组原生方法
const arrayMethods = Object.create(arrayProto)  // 创建空对象拦截器

const methodsToPatch = [  // 七个数组使用会改变自身的方法
  'push','pop','shift','unshift','splice','sort','reverse'
]

methodsToPatch.forEach(function (method) {  // 往拦截器下挂载异变方法

  const original = arrayProto[method]  // 过滤出七个数组原生原始方法
  
  def(arrayMethods, method, function mutator (...args) {  // 不定参数
  
    const result = original.apply(this, args)  // 借用原生方法，this就是调用的数组
    
    const ob = this.__ob__  // 之前Observer类下挂载的__ob__
    
    let inserted  // 临时保存数组新增的值
    switch (method) {
      case 'push':
      case 'unshift':
        inserted = args
        break
      case 'splice':
        inserted = args.slice(2)
        break
    }
    if (inserted) {
      ob.observeArray(inserted)  // 执行Observer类中的observeArray方法
    }
    ob.dep.notify()  // 触发手动依赖收集器内的依赖
    
    return result  // 返回数组执行结果
  })
})

const arrayKeys = Object.getOwnPropertyNames(arrayMethods) 
// 获取拦截器内挂载好的七个方法key的数组集合，用于没有__proto__的情况

复制代码
```

首先获取数组的所有原生方法，从中过滤出七个调用可以改变自身的方法，然后创建拦截器在它下面挂载七个经过异变的方法，这个异变方法的使用效果和原生方法是一致的，因为就是使用`apply`借用的，将执行后的结果保存给`result`，比如：

```
const arr = [1, 2, 3]
const result = arr.push(4)
复制代码
```

这个时候`arr`就变成了`[1,2,3,4]`，`result`保存的就是新数组的长度，既然模仿就模仿的像一点。

接下来的赋值`const ob = this.__ob__`，之前定义的`__ob__`不仅仅是标记位，保存的也是`Observer`类的实例。

有三个操作数组的方法是会添加新值的，使用`inserted`变量保存新添的值。如果是使用`splice`方法，就将前面两个表示位置的参数截取掉。然后使用`observeArray`方法将新添加的参数包装为响应式的。

最后通知手动依赖管理器内收集到的依赖派发更新，返回数组执行后的结果。

最后执行第三句：

```
this.observeArray(value)

observeArray(items) {
  for (let i = 0, i < items.length; i++) {
    observe(items[i])
  }
}
复制代码
```

将数组内的是数组或对象的每一项都包装成响应式的。所以当数组再使用方法时，首先会去`arrayMethods`拦截器内查找是否是异变方法，不是的话才去调用数组原生方法：

```
export default {
  data() {
    return {
      list: [1, 2, 3]
    }
  },
  methods: {
    changeArr1() {
      this.list.push(4)  // 调用拦截器里的异变方法
    },
    changeArr2() {
      this.list = this.list.concat(5) 
      // 调用原生方法，因为拦截器里没有，必须重新赋值因为不会改变自身
    }
  }
}
复制代码
```

至此数组响应式系统相关的也讲解完毕，整个响应式系统也分析完了。

> 数组响应式总结：数组的依赖收集还是在`get`方法里，不过依赖的存放位置会有不同，不是在`defineReactive`方法的`dep`里，而是在`Observer`类中的`dep`里，依赖的更新是在拦截器里的数组异变方法最后手动更新的。

同样数组响应式也是不是完美的，它也有缺点：

```
export default {
  data() {
    return {
      list: [1, 2, 3]
    }
  },
  methods: {
    changeListItem() {  // 改变数组某一项
      this.list[1] = 5
    },
    changeListLength() {  // 改变数组长度
      this.list.length = 0
    }
  }
}
复制代码
```

以上两种方式都改变了数组，但响应式是无法监听到的，因为不会触发`set`也没用使用数组方法去改变。不过大家还记得我们之前介绍的手动依赖管理器么？我们可以手动去通知它更新依赖然后触发视图变更~

```
export default {
  data() {
    return {
      list: [1, 2, 3],
      info: { name: 'cc' }
    }
  },
  methods: {
    changeListItem() {  // 改变数组某一项
      this.list[1] = 5
      this.list.__ob__.dep.notify()  // 手动通知
    },
    changeListLength() {  // 改变数组长度
      this.list.length = 0
      this.list.__ob__.dep.notify()  // 手动通知
    },
    changeInfo() {
      this.info.sex = 'man'
      this.info.__ob__.dep.notify()  // 对象也可以
    }
  }
}
复制代码
```

常规的对象增加属性是不会被感知到的，也可以使用手动通知的形式触发依赖，知道这个原理还是很`cool`的~

### 官方填坑

上面的奇技淫巧并不被推荐使用，我们还是介绍下官方推荐的弥补响应式不足的两个`API`，`$set`和`$delete`，其实它们只是处理一些情况，都不满足的最后还是调了一下手动依赖管理器来实现，只是进行了简单的二次封装。

> this.$set || Vue.set

```
function set(target, key, val) {
  if(Array.isArray(target)) {  // 数组
    target.length = Math.max(target.length, key)  // 最大值为长度
    target.splice(key, 1, val)  // 移除一位，异变方法派发更新
    return val
  }
  
  if(key in target && !(key in Object.prototype)) {  // key属于target
    target[key] = val  // 赋值操作触发set
    return val
  }
  
  if(!target.__ob__) {  // 普通对象赋值操作
    target[key] = val
    return val
  }
  
  defineReactive(target.__ob__.value, key, val)  // 将新值包装为响应式
  
  target.__ob__.dep.notify()  // 手动触发通知
  
  return val
}
复制代码
```

首先判断`target`是否是数组，是数组的话第二个参数就是长度了，设置数组的长度，然后使用`splice`这个异变方法插入`val`。 然后是判断`key`是否属于`target`，属于的话就是赋值操作了，这个会触发`set`去派发更新。接下来如果`target`并不是响应式数据，那就是普通对象，那就设置一个对应`key`吧。最后以上情况都不满足，说明是在响应式数据上新增了一个属性，把新增的属性转为响应式数据，然后通知手动依赖管理器派发更新。

> this.$delete || Vue.delete

```
function del (target, key) {
  if (Array.isArray(target)) {  // 数组
    target.splice(key, 1)  // 移除指定下表
    return
  }
  
  if (!hasOwn(target, key)) {  // key不属于target，再见
    return
  }
  
  delete target[key]  // 删除对象指定key
  
  if (!target.__ob__) {  // 普通对象，再见
    return
  }
  target.__ob__.dep.notify()  // 手动派发更新
}
复制代码
```

`this.$delete`就更加简单了，首先如果是数组就使用异变方法`splice`移除指定下标值。如果`target`是对象但`key`不属于它，再见。然后删除制定`key`的值，如果`target`不是响应式对象，删除的就是普通对象一个值，删了就删了。否则通知手动依赖管理器派发更新视图。

最后按照惯例我们还是以一道`vue`可能会被问到的面试题作为本章的结束~

> #### 面试官微笑而又不失礼貌的问道：

- 请简单描述下`vue`响应式系统？

> #### 怼回去：

- 简单来说就是使用`Object.defineProperty`这个`API`为数据设置`get`和`set`。当读取到某个属性时，触发`get`将读取它的组件对应的`render watcher`收集起来；当重置赋值时，触发`set`通知组件重新渲染页面。如果数据的类型是数组的话，还做了单独的处理，对可以改变数组自身的方法进行重写，因为这些方法不是通过重新赋值改变的数组，不会触发`set`，所以要单独处理。响应系统也有自身的不足，所以官方给出了`$set`和`$delete`来弥补。