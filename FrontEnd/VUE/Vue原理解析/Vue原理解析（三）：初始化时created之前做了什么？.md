# Vue原理解析（三）：初始化时created之前做了什么？

让我们继续`this._init()`的初始化之旅，接下来又会执行这样的三个初始化方法：

```
initInjections(vm)
initState(vm)
initProvide(vm)
复制代码
```

**5. initInjections(vm)**: 主要作用是初始化`inject`，可以访问到对应的依赖。

`inject`和`provide`这里需要简单的提一下，这是`vue@2.2`版本添加的一对需要一起使用的`API`，它允许父级组件向它之后的所有子孙组件提供依赖，让子孙组件无论嵌套多深都可以访问到，很`cool`有木有~

- `provide`：提供一个对象或是返回一个对象的函数。
- `inject`：是一个字符串数组或对象。

这一对`API`在`vue`官网有给出两条食用提示：

> `provide` 和 `inject` 主要为高阶插件/组件库提供用例。并不推荐直接用于应用程序代码中。

- 大概是因为会让组件数据层级关系变的混乱的缘故，但在开发组件库时会很好使。

> `provide` 和 `inject` 绑定并不是可响应的。这是刻意为之的。然而，如果你传入了一个可监听的对象，那么其对象的属性还是可响应的。

- 有个小技巧，这里可以将根组件`data`内定义的属性提供给子孙组件，这样在不借助`vuex`的情况下就可以实现简单的全局状态管理，还是很`cool`的~

```
app.vue 根组件

export default {
  provide() {
    return {
      app: this
    }
  },
  data() {
    return {
      info: 'hello world!'
    }
  }
}

child.vue 子孙组件

export default {
  inject: ['app'],
  methods: {
    handleClick() {
      this.app.info = 'hello vue!'
    }
  }
}
复制代码
```

一但触发`handleClick`事件之后，无论嵌套多深的子孙组件只要是使用了`inject`注入`this.app.info`变量的地方都会被响应，这就完成了简易的`vuex`。更多的示例大家可以去`vue`的官网翻阅，这里就不码字了，现在我们来分析下这么`cool`的功能它究竟是怎么实现的~

虽然`inject`和`provide`是成对使用的，但是二者在内部是分开初始化的。从上面三个初始化方法就能看出，先初始化`inject`，然后初始化`props/data`状态相关，最后初始化`provide`。这样做的目的是可以在`props/data`中使用`inject`内所注入的内容。

我们首先来看一下初始化`inject`时的方法定义：

```
export function initInjections(vm) {
  const result = resolveInject(vm.$options.inject, vm) // 找结果
  
  ...
}
复制代码
```

`vm.$options.inject`为之前合并后得到的用户自定义的`inject`，然后使用`resolveInject`方法找到我们想要的结果,我们看下`resolveInject`方法的定义：

```
export function resolveInject (inject, vm) {
  if (inject) {
    const result = Object.create(null)
    const keys = Object.keys(inject)  //省略Symbol情况

    for (let i = 0; i < keys.length; i++) {
      const key = keys[i]
      const provideKey = inject[key].from
      let source = vm
      while (source) {
        if (source._provided && hasOwn(source._provided, provideKey)) { //hasOwn为是否有
          result[key] = source._provided[provideKey]
          break
        }
        source = source.$parent
      }
    ... vue@2.5后新增设置inject默认参数相关逻辑
    }
    return result
  }
}
复制代码
```

首先定义一个`result`返回找到的结果。接下来使用双循环查找，外层的for循环会遍历`inject`的每一项，然后再内层使用`while`循环自底向上的查找`inject`该项的父级是否有提供对应的依赖。

`Ps:`这里可能有人会有疑问，之前`inject`的定义明明是数组，这里怎么可以通过`Object.keys`取值？这是因为上一章再做`options`合并时，也会对参数进行格式化，如`props`的格式，定义为数组也会被转为对象格式，`inject`被定义时是这样的：

```
定义时：
{
  inject: ['app']
}

格式化后：
{
  inject: {
    app: {
      from: 'app'
    }
  }
}
复制代码
```

书接上文，`source`就是当前的实例，而`source._provided`内保存的就是当前`provide`提供的值。首先从当前实例查找，接着将它的父组件实例赋值给`source`，在它的父组件查找。找到后使用`break`跳出循环，将搜索的结果赋值给`result`，接着查找下一个。

`Ps:`可能有人又会有疑问，这个时候是先初始化的`inject`再初始化的`provide`，怎么访问父级的`provide`了？它根本就没初始化阿，这个时候我们就要再思考下了，因为`vue`是组件式的，首先就会初始化父组件，然后才是初始化子组件，所以这个时候是有`source._provided`属性的。

找到了想到的结果之后，我们补全之前`initInjections`的定义：

```
export function initInjections(vm) {
  const result = resolveInject(vm.$options.inject, vm)

  if(result) { // 如果有结果
    toggleObserving(false)  // 刻意为之不被响应式
    Object.keys(result).forEach(key => {
      ...
      defineReactive(vm, key, result[key])
    })
    toggleObserving(true)
  }
}
复制代码
```

如果有搜索结果，首先会调用`toggleObserving(false)`，具体实现不用理会，只用知道这个方法的作用是设置一个标志位，将决定`defineReactive()`方法是否将它的第三个参数设置为响应式数据，也就是决定`result[key]`这个值是否会被设置为响应式数据，这里的参数为`false`，只是在`vm`下挂载`key`对应普通的值，不过这样就可以在当前实例使用`this`访问到`inject`内对应的依赖项了，设置完毕之后再调用`toggleObserving(true)`，改变标志位，让`defineReactive()`可以设置第三个参数为响应式数据（`defineReactive`是响应式原理很重要的方法，这里了解即可），也就是它该有的样子。以上就是`inject`实现的相关原理，一句话来说就是，首先遍历每一项，然后挨个遍历每一项父级是否有依赖。

**6. initState(vm)**: 初始化会被使用到的状态，状态包括`props`，`methods`，`data`，`computed`，`watch`五个选项。

首先看下`initState(vm)`方法的定义：

```
export function initState(vm) {
  ...
  const opts = vm.$options
  if(opts.props) initProps(vm, opts.props)
  if(opts.methods) initMethods(vm, opts.methods)
  if(opts.data) initData(vm)
  ...
  if(opts.computed) initComputed(vm, opts.computed)
  if(opts.watch && opts.watch !== nativeWatch) {
    initWatch(vm, opts.watch)
  }
}
复制代码
```

现在这里的话只会介绍前面三类状态的初始化做了什么，也就是`props`，`methods`，`data`，因为`computed`和`watch`会涉及到响应式相关的`watcher`，这里先略过。接下来我们依次有请这三位的初始化方法登场：

> **6.1** initProps (vm, propsOptions)：

- 主要作用是检测子组件接受的值是否符合规则，以及让对应的值可以用`this`直接访问。

```
function initProps(vm, propsOptions) {  // 第二个参数为验证规则
  const propsData = vm.$options.propsData || {}  // props具体的值
  const props = vm._props = {}  // 存放props
  const isRoot = !vm.$parent // 是否是根节点
  if (!isRoot) {
    toggleObserving(false)
  }
  for (const key in propsOptions) {
    const value = validateProp(key, propsOptions, propsData, vm)
    defineReactive(props, key, value)
    if (!(key in vm)) {
      proxy(vm, `_props`, key)
    }
  }
  toggleObserving(true)
}
复制代码
```

我们知道`props`是作为父组件向子组件通信的重要方式，而`initProps`内的第二个参数`propsOptions`，就是当前实例也就是通信角色里的子组件，它所定义的接受参数的规则。子组件的`props`规则是可以使用数组形式的定义的，不过再经过合并`options`之后会被格式化为对象的形式：

```
定义时：
{
  props: ['name', 'age']
}

格式化后：
{
  name: {
    type: null
  },
  age: {
    type: null
  }
}
复制代码
```

所以在定义`props`规则时，直接使用对象格式吧，这也是更好的书写规范。

知道了规则之后，接下来需要知道父组件传递给子组件具体的值，它以对象的格式被放在`vm.$options.propsData`内，这也是合并`options`时得到的。接下来在实例下定义了一个空对象`vm._props`，它的作用是将符合规格的值挂载到它下面。`isRoot`的作用是判断当前组件是否是根组件，如果不是就不将`props`的转为响应式数据。

接下来遍历格式化后的`props`验证规则，通过`validateProp`方法验证规则并得到相应的值，将得到的值挂载到`vm._props`下。这个时候就可以通过`this._props`访问到`props`内定义的值了：

```
props: ['name'],
methods: {
  handleClick() {
    console.log(this._props.name)
  }
}
复制代码
```

不过直接访问内部的私有变量这种方式并不友好，所以`vue`内部做了一层代理，将对`this.name`的访问转而为对`this._props.name`的访问。这里的`proxy`需要介绍下，因为之后的`data`也会使用到，看下它的定义：

```
格式化了一下：
export function proxy(target, sourceKey, key) {
  Object.defineProperty(target, key, {
    enumerable: true,
    configurable: true,
    get: function () {
      return this[sourceKey][key]
    },
    set: function () {
      this[sourceKey][key] = val
    }
  })
}
复制代码
```

其实很简单，只是定义一个对象值的`get`方法，读取时让其返回另外的一个值，这里就完成了`props`的初始化。

> **6.2** initMethods (vm, methods)：

- 主要作用是将`methods`内的方法挂载到`this`下。

```
function initMethods(vm, methods) {
  const props = vm.$options.props
  for(const key in methods) {
    
    if(methods[key] == null) {  // methods[key] === null || methods[key] === undefined 的简写
      warn(`只定义了key而没有相应的value`)
    }
    
    if(props && hasOwn(props, key)) {
      warn(`方法名和props的key重名了`)
    }
    
    if((key in vm) && isReserved(key)) {
      warn(`方法名已经存在而且以_或$开头`)
    }
    
    vm[key] = methods[key] == null
      ? noop  // 空函数
      : bind(methods[key], vm)  //  相当于methods[key].bind(vm)
  }
}
复制代码
```

`methods`的初始化相较而言就简单了很多。不过它也有很多边界情况，如只定义了`key`而没有方法具体的实现、`key`和`props`重名了、`key`已经存在且命名不规范，以`_`或`$`开头，至于为什么不行，我们第一章的时候有说明了。最后将`methods`内的方法挂载到`this`下，就完成了`methods`的初始化。

> **6.3** initData (vm)：

- 主要作用是初始化`data`，还是老套路，挂载到`this`下。有个重要的点，之所以`data`内的数据是响应式的，是在这里初始化的，这个大家得有个印象~。

```
function initData (vm: Component) {
  let data = vm.$options.data
  data = vm._data = typeof data === 'function'
    ? getData(data, vm) // 通过data.call(vm, vm)得到返回的对象
    : data || {}
  if (!isPlainObject(data)) { // 如果不是一个对象格式
    data = {}
    warn(`data得是一个对象`)
  }
  const keys = Object.keys(data)
  const props = vm.$options.props  // 得到props
  const methods = vm.$options.methods  // 得到methods
  let i = keys.length
  while (i--) {
    const key = keys[i]
    if (methods && hasOwn(methods, key)) {
      warn(`和methods内的方法重名了`)
    }
    
    if (props && hasOwn(props, key)) {
      warn(`和props内的key重名了`)
    } else if (!isReserved(key)) { // key不能以_或$开头
      proxy(vm, `_data`, key)
    }
  }
  observe(data, true)
}
复制代码
```

首先通过`vm.$options.data`得到用户定义的`data`，如果是`function`格式就执行它，并返回执行之后的结果，否则返回`data`或`{}`，将结果赋值给`vm._data`这个私有属性。和`props`一样的套路，最后用来做一层代理，如果得到的结果不是对象格式就是报错了。

然后遍历`data`内的每一项，不能和`methods`以及`props`内的`key`重名，然后使用`proxy`做一层代理。注意最后会执行一个方法`observe(data, true)`，它的作用了是递归的让`data`内的每一项数据都变成响应式的。

其实不难发现它们仨主要做的事情差不多，首先不要相互之间有重名，然后可以被`this`直接访问到。

**7. initProvide(vm)**: 主要作用是初始化`provide`为子组件提供依赖。

`provide`选项应该是一个对象或是函数，所以对它取值即可，就像取`data`内的值类似，看下它的定义：

```
export function initProvide (vm) {
  const provide = vm.$options.provide
  if (provide) {
    vm._provided = typeof provide === 'function'
      ? provide.call(vm)
      : provide
  }
}
复制代码
```

首先通过`vm.$options.provide`取得用户定义的`provide`选项，如果是一个`function`类型就执行一下，得到返回后的结果，将其赋值给了`vm._provided`私有属性，所以子组件在初始化`inject`时就可以访问到父组件提供的依赖了；如果不是`function`类型就直接返回定义的`provide`。

**8. callHook(vm, 'created')**: 执行用户定义的`created`钩子函数，有`mixin`混入的也一并执行。

终于我们越过了`created`钩子函数，还是分别用一句话来介绍它们主要都干了什么事：

- initInjections(vm)：让子组件`inject`的项可以访问到正确的值
- initState(vm)：将组件定义的状态挂载到`this`下。
- initProvide(vm)：初始化父组件提供的`provide`依赖。
- created：执行组件的`created`钩子函数

初始化的阶段算是告一段落了，接下来我们会进入组件的挂载阶段。按照惯例我们还是以一道`vue`容易被问道的面试题作为本章的结束吧~：

> #### 面试官微笑而又不失礼貌的问道：

- 请问`methods`内的方法可以使用箭头函数么，会造成什么样的结果？

> #### 怼回去：

- 是不可以使用箭头函数的，因为箭头函数的`this`是定义时就绑定的。在`vue`的内部，`methods`内每个方法的上下文是当前的`vm`组件实例，`methods[key].bind(vm)`，而如果使用使用箭头函数，函数的上下文就变成了父级的上下文，也就是`undefined`了，结果就是通过`undefined`访问任何变量都会报错。