# Vue原理解析（六）：全面深入理解响应式原理(上)-对象基础篇

`vue`之所以能数据驱动视图发生变更的关键，就是依赖它的响应式系统了。响应式系统如果根据数据类型区分，对象和数组它们的实现会有所不同；解释响应式原理，如果只是为了说明响应式原理而说，但不是从整体流程出发，不在`vue`组件化的整体流程中找到响应式原理的位置，对深刻理解响应式原理并不太好。接下来笔者会从整体流程出发，试着站在巨人的肩膀上分别说明对象和数组的实现原理。

### 对象的响应式原理

> #### 对象响应式数据的创建

- 在组件的初始化阶段，将对传入的状态进行初始化，以下以`data`为例，会将传入的数据包装为响应式的数据。

```
对象示例：

main.js
new Vue({  // 根组件
  render: h => h(App)
})

---------------------------------------------------

app.vue
<template>
  <div>{{info.name}}</div>  // 只用了info.name属性
</template>
export default {  // app组件
  data() {
    return {
      info: {
        name: 'cc',
        sex: 'man'  // 即使是响应式数据，没被使用就不会进行依赖收集
      }
    }
  }
}
复制代码
```

接下来的分析将以上面代码为示例，这种结构其实是一个嵌套组件，只不过根组件一般定义的参数比较少而已，理解这个还是很重要的。

在组件`new Vue()`后的执行`vm._init()`初始化过程中，当执行到`initState(vm)`时就会对内部使用到的一些状态，如`props`、`data`、`computed`、`watch`、`methods`分别进行初始化，再对`data`进行初始化的最后有这么一句：

```
function initData(vm) {  //初始化data
  ...
  observe(data) //  info:{name:'cc',sex:'man'}
}
复制代码
```

这个`observe`就是将用户定义的`data`变成响应式的数据，接下来看下它的创建过程：

```
export function observe(value) {
  if(!isObject(value)) {  // 不是数组或对象，再见
    return
  }
  return new Observer(value)
}
复制代码
```

简单理解这个`observe`方法就是`Observer`这个类的工厂方法，所以还是要看下`Observer`这个类的定义：

```
export class Observer {
  constructor(value) {
    this.value = value
    this.walk(value)  // 遍历value
  }
  
  walk(obj) {
    const keys = Object.keys(obj)
    for(let i = 0; i < keys.length; i++) {
      defineReactive(obj, keys[i])  // 只传入了两个参数
    }
  }
}
复制代码
```

当执行`new Observer`时，首先将传入的对象挂载到当前`this`下，然后遍历当前对象的每一项，执行`defineReactive`这个方法，看下它的定义：

```
export function defineReactive(obj, key, val) {

  const dep = new Dep()  // 依赖管理器
  
  val = obj[key]  // 计算出对应key的值
  observe(val)  // 递归包装对象的嵌套属性
  
  Object.defineProperty(obj, key, {
    enumerable: true,
    configurable: true,
    get() {
      ... 收集依赖
    },
    set(newVal) {
      ... 派发更新
    }
  })
}
复制代码
```

这个方法的作用就是使用`Object.defineProperty`创建响应式数据。首先根据传入的`obj`和`key`计算出`val`具体的值；如果`val`还是对象，那就使用`observe`方法进行递归创建，在递归的过程中使用`Object.defineProperty`将对象的**每一个**属性都变成响应式数据：

```
...
data() {
  return {
    info: {
      name: 'cc',
      sex: 'man'
    } 
  }
}
这段代码就会有三个响应式数据：
  info, info.name, info.sex
复制代码
```

> 知识点：`Object.defineProperty`内的`get`方法，它的作用就是谁访问到当前`key`的值就用`defineReactive`内的`dep`将它收集起来，也就是依赖收集的意思。`set`方法的作用就是当前`key`的值被赋值了，就通知`dep`内收集到的依赖项，`key`的值发生了变更，视图请变更吧~

这个时候`get`和`set`只是定义了，并不会触发。什么是依赖我们接下来说明，首先还是用一张图帮大家理清响应式数据的创建过程：



![img](Untitled%204.assets/16c90a72355f9e70)



> #### 依赖收集

什么是依赖了？我们看下之前`mountComponent`的定义：

```
function mountComponent(vm, el) {
  ...
  const updateComponent = function() {
    vm._update(vm._render())
  }
  
  new Watcher(vm, updateComponent, noop, {  // 渲染watcher
    ...
  }, true)  // true为标志，表示是否是渲染watcher
  ...
}
复制代码
```

我们首先说明下这个`Watcher`类，它类似与之前的`VNode`类，根据传入的参数不同，可以分别实例化出三种不同的`Watcher`实例，它们分别是用户`watcher`，计算`watcher`以及渲染`watcher`：

> 用户`(user) watcher`

- 也就是用户自己定义的，如：

```
new Vue({
  data {
    msg: 'hello Vue!'
  }
  created() {
    this.$watch('msg', cb())  // 定义用户watcher
  },
  watch: {
    msg() {...}  // 定义用户watcher
  }
})
复制代码
```

这里的两种方式内部都是使用`Watcher`这个类实例化的，只是参数不同，具体实现我们之后章节说明，这里大家只用知道这个是用户`watcher`即可。

> 计算`(computed) watcher`

- 顾名思义，这个是当定义计算属性实例化出来的一种：

```
new Vue({
  data: {
    msg: 'hello'  
  },
  computed() {
    sayHi() {  // 计算watcher
      return this.msg + 'vue!'
    }
  }
})
复制代码
```

> 渲染`(render) watcher`

- 只是用做视图渲染而定义的`Watcher`实例，再组件执行`vm.$mount`的最后会实例化`Watcher`类，这个时候就是以渲染`watcher`的格式定义的，收集的就是当前渲染`watcher`的实例，我们来看下它内部是如何定义的：

```
class Watcher {
  constructor(vm, expOrFn, cb, options, isRenderWatcher) {
    this.vm = vm
    if(isRenderWatcher) {  // 是否是渲染watcher
      vm._watcher = this  // 当前组件下挂载vm._watcher属性
    }
    vm._watchers.push(this)  //vm._watchers是之前初始化initState时定义的[]
    this.before = options.before  // 渲染watcher特有属性
    this.getter = expOrFn  // 第二个参数
    this.get()  // 实例化就会执行this.get()方法
  }
  
  get() {
    pushTarget(this)  // 添加
    ...
    this.getter.call(this.vm, this.vm)  // 执行vm._update(vm._render())
    ...
    popTarget()  // 移除
  }
  
  addDep(dep) {
    ...
    dep.addSub(this)  // 将当前watcher收集到dep实例中
  }
}
复制代码
```

当执行`new Watcher`的时候内部会挂载一些属性，然后执行`this.get()`这个方法，首先会执行一个全局的方法`pushTarget(this)`，传入当前`watcher`的实例，我们看下这个方法定义的地方：

```
Dep.target = null
const targetStack = []  // 组件从父到子对应的watcher实例集合

export function pushTarget (_target) {  // 添加
  if (Dep.target) {
    targetStack.push(Dep.target)  // 添加到集合内
  }
  Dep.target = _target  // 当前的watcher实例
}

export function popTarget() {  // 移除
  targetStack.pop()  // 移除数组最后一项
  Dep.target = targetStack[targetStack.length - 1]  // 赋值为数组最后一项
}
复制代码
```

首先会定义一个`Dep`类的静态属性`Dep.target`为`null`，这是一个全局会用到的属性，保存的是当前组件对应渲染`watcher`的实例；`targetStack`内存储的是再执行组件化的过程中每个组件对应的渲染`watcher`实例集合，使用的是一个先进后出的形式来管理数组的数据，这里可能有点不太好懂，稍等再看到最后的流程图后自然就明白了；然后将传入的`watcher`实例赋值给全局属性`Dep.target`，再之后的依赖收集过程中就是收集的它。

`watcher`的`get`这个方法然后会执行`getter`这个方法，它是`new Watcher`时传入的第二个参数，这个参数就是之前的`updateComponent`变量：

```
function mountComponent(vm, el) {
  ...
  const updateComponent = function() {  //第二个参数
    vm._update(vm._render())
  }
  ...
}
复制代码
```

只要一执行就会执行当前组件实例上的`vm._update(vm._render())`将`render`函数转为`VNode`，这个时候如果`render`函数内有使用到`data`中已经转为了响应式的数据，就会触发`get`方法进行依赖的收集，补全之前依赖收集的逻辑：

```
export function defineReactive(obj, key, val) {
  const dep = new Dep()  // 依赖管理器
  
  val = obj[key]  // 计算出对应key的值
  observe(val)  // 递归的转化对象的嵌套属性
  
  Object.defineProperty(obj, key, {
    enumerable: true,
    configurable: true,
    get() {  // 触发依赖收集
      if(Dep.target) {  // 之前赋值的当前watcher实例
        dep.depend()  // 收集起来，放入到上面的dep依赖管理器内
        ...
      }
      return val
    },
    set(newVal) {
      ... 派发更新
    }
  })
}
复制代码
```

这个时候我们知道`watcher`是个什么东西了，简单理解就是数据和组件之间一个通信工具的封装，当某个数据被组件读取时，就将依赖数据的组件使用`Dep`这个类给收集起来。

当前例子`data`内的属性是只有一个渲染`watcher`的，因为没有被其他组件所使用。但如果该属性被其他组件使用到，也会将使用它的组件收集起来，例如作为了`props`传递给了子组件，再`dep`的数组内就会存在多个渲染`watcher`。我们来看下`Dep`类这个依赖管理器的定义：

```
let uid = 0
export default class Dep {
  constructor() {
    this.id = uid++
    this.subs = []  // 对象某个key的依赖集合
  }
  
  addSub(sub) {  // 添加watcher实例到数组内
    this.subs.push(sub)
  }
  
  depend() {
    if(Dep.target) {  // 已经被赋值为了watcher的实例
      Dep.target.addDep(this)  // 执行watcher的addDep方法
    }
  }
}

----------------------------------------------------------
class Watcher{
  ...
  addDep(dep) {  // 将当前watcher实例添加到dep内
    ...
    dep.addSub(this)  // 执行dep的addSub方法
  }
}
复制代码
```

这个`Dep`类的作用就是管理属性对应的`watcher`，如添加/删除/通知。至此，依赖收集的过程算是完成了，还是以一张图片加深对过程的理解：



![img](Untitled%204.assets/16c8143d362069b2)



> #### 派发更新

如果只是收集依赖，那其实是没任何意义的，将收集到的依赖在数据发生变化时通知到并引起视图变化，这样才有意义。如现在我们对数据重新赋值：

```
app.vue
export default {  // app组件
  ...
  methods: {
    changeInfo() {
      this.info.name = 'ww';
    }
  }
}
复制代码
```

这个时候就会触发创建响应式数据时的`set`方法了，我们再补全那里的逻辑：

```
export function defineReactive(obj, key, val) {
  const dep = new Dep()  // 依赖管理器
  
  val = obj[key]  // 计算出对应key的值
  observe(val)  // 递归转化对象的嵌套属性
  
  Object.defineProperty(obj, key, {
    enumerable: true,
    configurable: true,
    get() {
      ... 依赖收集
    },
    set(newVal) {  // 派发更新
      if(newVal === val) {  // 相同
        return
      }
      val = newVal  // 赋值
      observer(newVal)  // 如果新值是对象也递归包装
      dep.notify()  // 通知更新
    }
  })
}
复制代码
```

当赋值触发`set`时，首先会检测新值和旧值，不能相同；然后将新值赋值给旧值；如果新值是对象则将它变成响应式的；最后让对应属性的依赖管理器使用`dep.notify`发出更新视图的通知。我们看下它的实现：

```
let uid = 0
class Dep{
  constructor() {
    this.id = uid++
    this.subs = []
  }
  
  notify() {  // 通知
    const subs = this.subs.slice()
    for(let i = 0, i < subs.length; i++) {
      subs[i].update()  // 挨个触发watcher的update方法
    }
  }
}
复制代码
```

这里做的事情只有一件，将收集起来的`watcher`挨个遍历触发`update`方法：

```
class Watcher{
  ...
  update() {
    queueWatcher(this)
  }
}

---------------------------------------------------------
const queue = []
let has = {}

function queueWatcher(watcher) {
  const id = watcher.id
  if(has[id] == null) {  // 如果某个watcher没有被推入队列
    ...
    has[id] = true  // 已经推入
    queue.push(watcher)  // 推入到队列
  }
  ...
  nextTick(flushSchedulerQueue)  // 下一个tick更新
}
复制代码
```

执行`update`方法时将当前`watcher`实例传入到定义的`queueWatcher`方法内，这个方法的作用是把将要执行更新的`watcher`收集到一个队列`queue`之内，保证如果同一个`watcher`内触发了多次更新，只会更新一次对应的`watcher`，我们举两个小示例：

```
export default {
  data() {
    return {  // 都被模板引用了
      num: 0,
      name: 'cc',
      sex: 'man'
    }
  },
  methods: {
    changeNum() {  // 赋值100次
      for(let i = 0; i < 100; i++) {
        this.num++
      }
    },
    changeInfo() {  // 一次赋值多个属性的值
      this.name = 'ww'
      this.sex = 'woman'
    }
  }
}
复制代码
```

这里的三个响应式属性它们收集都是同一个渲染`watcher`。所以当赋值100次的情况出现时，再将当前的渲染`watcher`推入到的队列之后，之后赋值触发的`set`队列内并不会添加任何渲染`watcher`；当同时赋值多个属性时也是，因为它们收集的都是同一个渲染`watcher`，所以推入到队列一次之后就不会添加了。

> 知识点：`vue`还是挺聪明的，通过这两个实例大家也看出来了，派发更新通知的粒度是组件级别，至于组件内是哪个属性赋值了，派发更新并不关心，而且怎么高效更新这个视图，那是之后`diff`比对做的事情。

队列有了，执行`nextTick(flushSchedulerQueue)`再下一次`tick`时更新它，这里的`nextTick`就是我们经常使用的`this.$nextTick`方法的原始方法，它们作用一致，实现原理之后章节说明。看下参数`flushSchedulerQueue`是个啥？

```
let index = 0

function flushSchedulerQueue() {
  let watcher, id
  queue.sort((a, b) => a.id - b.id)  // watcher 排序
  
  for(index = 0; index < queue.length; index++) {  // 遍历队列
    watcher = queue[index]  
    if(watcher.before) {  // 渲染watcher独有属性
      watcher.before()  // 触发 beforeUpdate 钩子
    }
    id = watcher.id
    has[id] = null
    watcher.run()  // 真正的更新方法
    ...
  }
}
复制代码
```

原来是个函数，再`nextTick`方法的内部会执行第一个参数。首先会将`queue`这个队列进行一次排序，依据是每次`new Watcher`生成的`id`，以从小到大的顺序。当前示例只是做渲染，而且队列内只存在了一个渲染`watcher`，所以是不存在顺序的。但是如果有定义`user watcher`和`computed watcher`加上`render watcher`后，它们之间就会存在一个执行顺序的问题了。

> 知识点：`watcher`的执行顺序是先父后子，然后是从`computed watcher`到`user watcher`最后`render watcher`，这从它们的初始化顺序就能看出。

然后就是遍历这个队列，因为是渲染`watcher`，所有是有`before`属性的，执行传入的`before`方法触发`beforeUpdate`钩子。最后执行`watcher.run()`方法，执行真正的派发更新方法。我们去看下`run`干了啥：

```
class Watcher {
  ...
  run () {  
    if (this.active) {
      this.getAndInvoke(this.cb) // 有一种要抓狂的感觉
    }
  }
  
  getAndInvoke(cb) {  // 渲染watcher的cb为noop空函数
    const value = this.get()
    
    ... 后面是用户watcher逻辑
  }
}
复制代码
```

执行`run`就是执行`getAndInvoke`方法，因为是渲染`watcher`，参数`cb`是`noop`空函数。看了这么多，其实...就是重新执行一次`this.get()`方法，让`vm._update(vm._render())`再走一遍而已。然后生成新旧`VNode`，最后进行`diff`比对以更新视图。

最后我们来说下`vue`基于`Object.defineProperty`响应式系统的一些不足。如只能监听到数据的变化，所以有时`data`中要定义一堆的初始值，因为加入了响应式系统后才能被感知到；还有就是常规`JavaScript`操作对象的方式，并不能监听到增加以及删除，例如：

```
export default {
  data() {
    return {
      info: {
        name: 'cc'
      }
    }
  },
  methods: {
    addInfo() {  // 增加属性
      this.info.sex = 'man'
    },
    delInfo() {  // 删除属性
      delete info.name
    }
  }
}
复制代码
```

数据是被赋值了，但是视图并不会发生变更。`vue`为了解决这个问题，提供了两个`API`：`$set`和`$delete`，它们又是怎么办到的了？原理之后章节分析。

最后惯例的面试问答就扯扯最近工作中遇到趣事吧。对于一个数据不会变更的列表，笔者把它定义再了`created`钩子内，很少结对编程，这次例外。

```
created() {
  this.list = [...]
}
复制代码
```

旁边的妹子接过后：

```
妹子： 这个列表怎么data里没有阿？在哪定义的？
我：我定义在created钩子里了。
妹子：你怎么定义在这了？
我：因为它是不会被变更的，所以不需要... 算了，那你移到data里吧。
妹子：嗯！？ 好。 小声说道：我还是第一次看见这么写的。
我：...有种被嫌弃了的感觉
复制代码
```

> #### 面试官微笑而又不失礼貌的问道：

- 当前组件模板中用到的变量一定要定义在`data`里么？

> #### 怼回去：

- `data`中的变量都会被代理到当前`this`下，所以我们也可以在`this`下挂载属性，只要不重名即可。而且定义在`data`中的变量在`vue`的内部会将它包装成响应式的数据，让它拥有变更即可驱动视图变化的能力。但是如果这个数据不需要驱动视图，定义在`created`或`mounted`钩子内也是可以的，因为不会执行响应式的包装方法，对性能也是一种提升。