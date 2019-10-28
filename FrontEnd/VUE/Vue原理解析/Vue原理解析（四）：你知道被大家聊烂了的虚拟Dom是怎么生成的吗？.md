# Vue原理解析（四）：你知道被大家聊烂了的虚拟Dom是怎么生成的吗？

在经过初始化阶段之后，即将开始组件的挂载，不过在挂载之前很有必要提一下虚拟`Dom`的概念。这个想必大家有所耳闻，我们知道`vue@2.0`开始引入了虚拟`Dom`，主要解决的问题是，大部分情况下可以降低使用`JavaScript`去操作跨线程的庞大`Dom`所需要的昂贵性能，让`Dom`操作的性能更高；以及虚拟`Dom`可以用于`SSR`以及跨端使用。虚拟`Dom`，顾名思义并不是真实的`Dom`，而是使用`JavaScript`的对象来对真实`Dom`的一个描述。一个真实的`Dom`也无非是有标签名，属性，子节点等这些来描述它，如页面中的真实`Dom`是这样的：

```
<div id='app' class='wrap'>
  <h2>
    hello
  </h2>
</div>
复制代码
```

我们可以在`render`函数内这样描述它：

```
new Vue({
  render(h) {
    return h('div', {
      attrs: {
        id: 'app',
        class: 'wrap'
      }
    }, [
      h('h2', 'hello')
    ])
  }
})
复制代码
```

这个时候它并不是用对象来描述的，使用的是`render`函数内的数据结构去描述的真实`Dom`，而现在我们需要将这段描述转为用对象的形式，`render`函数使用的是参数`h`方法并用`VNode`这个类来实例化它们，所以我们再了解`h`的实现原理前，首先来看下`VNode`类是什么，找到它定义的地方：

```
export default class VNode {
  constructor (
    tag
    data
    children
    text
    elm
    context
    componentOptions
    asyncFactory
  ) {
    this.tag = tag  // 标签名
    this.data = data  // 属性 如id/class
    this.children = children  // 子节点
    this.text = text  // 文本内容
    this.elm = elm  // 该VNode对应的真实节点
    this.ns = undefined  // 节点的namespace
    this.context = context  // 该VNode对应实例
    this.fnContext = undefined  // 函数组件的上下文
    this.fnOptions = undefined  // 函数组件的配置
    this.fnScopeId = undefined  // 函数组件的ScopeId
    this.key = data && data.key  // 节点绑定的key 如v-for
    this.componentOptions = componentOptions  //  组件VNode的options
    this.componentInstance = undefined  // 组件的实例
    this.parent = undefined  // vnode组件的占位符节点
    this.raw = false  // 是否为平台标签或文本
    this.isStatic = false  // 静态节点
    this.isRootInsert = true  // 是否作为根节点插入
    this.isComment = false  // 是否是注释节点
    this.isCloned = false  // 是否是克隆节点
    this.isOnce = false  // 是否是v-noce节点
    this.asyncFactory = asyncFactory  // 异步工厂方法
    this.asyncMeta = undefined  //  异步meta
    this.isAsyncPlaceholder = false  // 是否为异步占位符
  }

  get child () {  // 别名
    return this.componentInstance
  }
}
复制代码
```

这是`VNode`类定义的地方，挺吓人的，它支持一共最多八个参数，其实经常用到的并不多。如`tag`是元素节点的名称，`children`为它的子节点，`text`是文本节点内的文本。实例化后的对象就有二十三个属性作为在`vue`的内部一个节点的描述，它描述的是将它创建为一个怎样的真实`Dom`。大部分属性默认是`false`或`undefined`，而通过这些属性**有效的值**就可以组装出不同的描述，如真实的`Dom`中会有元素节点、文本节点、注释节点等。而通过这样一个`VNode`类，也可以描述出相应的节点，部分节点`vue`内部还做了相应的封装：

> **注释节点** ↓

```
export const createEmptyVNode = (text = '') => {
  const node = new VNode()
  node.text = text
  node.isComment = true
  return node
}
复制代码
```

- 创建一个空的`VNode`，有效属性只有`text`和`isComment`来表示一个注释节点。

```
真实的注释节点：
<!-- 注释节点 -->

VNode描述：
createEmptyVNode ('注释节点')
{
  text: '注释节点',
  isComment: true
}
复制代码
```

> **文本节点** ↓

```
export function createTextVNode (val) {
  return new VNode(undefined, undefined, undefined, String(val))
}
复制代码
```

- 只是设置了`text`属性，描述的是标签内的文本

```
VNode描述：
createTextVNode('文本节点')
{
  text: '文本节点'
}
复制代码
```

> **克隆节点** ↓

```
export function cloneVNode (vnode) {
  const cloned = new VNode(
    vnode.tag,
    vnode.data,
    vnode.children,
    vnode.text,
    vnode.elm,
    vnode.context,
    vnode.componentOptions,
    vnode.asyncFactory
  )
  cloned.ns = vnode.ns
  cloned.isStatic = vnode.isStatic
  cloned.key = vnode.key
  cloned.isComment = vnode.isComment
  cloned.fnContext = vnode.fnContext
  cloned.fnOptions = vnode.fnOptions
  cloned.fnScopeId = vnode.fnScopeId
  cloned.asyncMeta = vnode.asyncMeta
  cloned.isCloned = true
  return cloned
}
复制代码
```

- 将一个现有的`VNode`节点拷贝一份，只是被拷贝节点的`isCloned`属性为`false`，而拷贝得到的节点的`isCloned`属性为`true`，除此之外它们完全相同。

> **元素节点** ↓

```
真实的元素节点：
<div>
  hello
  <span>Vue!</span>
</div>

VNode描述：
{
  tag: 'div',
  children: [
    {
      text: 'hello'
    }, 
    {
      tag: 'span',
      children: [
        {
          text: Vue!
        }
      ]
    }
  ],
}
复制代码
```

> **组件节点** ↓

```
渲染App组件：
new Vue({
  render(h) {
    return h(App)
  }
})

VNode描述：
{
  tag: 'vue-component-2',
  componentInstance: {...},
  componentOptions: {...},
  context: {...},
  data: {...}
}
复制代码
```

- 组件的`VNode`会和元素节点相比会有两个特有的属性`componentInstance`和`componentOptions`。`VNode`的类型有很多，它们都是从这个`VNode`类中实例化出来的，只是属性不同。

> #### 开始挂载阶段

```
this._init() 方法的最后：

... 初始化

if (vm.$options.el) {
  vm.$mount(vm.$options.el)
}
复制代码
```

如果用户有传入`el`属性，就执行`vm.$mount`方法并传入`el`开始挂载。这里的`$mount`方法在完整版和运行时版本又会有点不同，他们区别如下：

```
运行时版本：
Vue.prototype.$mount = function(el) { // 最初的定义
  return mountComponent(this, query(el));
}

完整版：
const mount = Vue.prototype.$mount
Vue.prototype.$mount = function(el) {  // 拓展编译后的

  if(!this.$options.render) {            ---|
    if(this.$options.template) {         ---|
      ...经过编译器转换后得到render函数  ---|  编译阶段
    }                                    ---|
  }                                      ---|
  
  return mount.call(this, query(el))
}

-----------------------------------------------

export function query(el) {  // 获取挂载的节点
  if(typeof el === 'string') {  // 比如#app
    const selected = document.querySelector(el)
    if(!selected) {
      return document.createElement('div')
    }
    return selected
  } else {
    return el
  }
}
复制代码
```

完整版有一个骚操作，首先将`$mount`方法缓存到`mount`变量上，然后使用函数劫持的手段重新定义`$mount`函数，并在其内部增加编译相关的代码，最后还是使用原来定义的`$mount`方法挂载。所以核心是要了解最初定义`$mount`方法时内的`mountComponent`方法：

```
export function mountComponent(vm, el) {
  vm.$el = el
  ...
  callHook(vm, 'beforeMount')
  ...
  const updateComponent = function () {
    vm._update(vm._render())
  }
  ...
}
复制代码
```

首先将传入的`el`赋值给`vm.$el`，这个时候`el`是一个真实`dom`，接着会执行用户自己定义的`beforeMount`钩子。接下来会定义一个重要的函数变量`updateComponent`，它的内部首先会执行`vm._render()`方法，将返回的结果传入`vm._update()`内再执行。我们这章主要就来分析这个`vm._render()`方法做了什么事情，来看下它的定义：

```
Vue.prototype._render = function() {
  const vm = this
  const { render } = vm.$options

  const vnode = render.call(vm, vm.$createElement)
  
  return vnode
}
复制代码
```

首先会得到自定义的`render`函数，传入`vm.$createElement`这个方法(也就是上面例子内的`h`方法)，将执行的返回结果赋值给`vnode`，这里也就完成了`render`函数内数据结构转为`vnode`的操作。而这个`vm.$createElement`是在之前初始化`initRender`方法内挂载到`vm`实例下的：

```
vm._c = (a, b, c, d) => createElement(vm, a, b, c, d, false)  // 编译
vm.$createElement = (a, b, c, d) => createElement(vm, a, b, c, d, true)  // 手写
复制代码
```

无论是编译而来还是手写的`render`函数，它们都是返回了`createElement`这个函数，继续查找它的定义：

```
const SIMPLE_NORMALIZE = 1
const ALWAYS_NORMALIZE = 2

export default createElement(
  context, 
  tag, 
  data, 
  children, 
  normalizationType, 
  alwaysNormalize) {
  if(Array.isArray(data) || isPrimitive(data)) {  // data是数组或基础类型
    normalizationType = children  --|
    children = data               --| 参数移位
    data = undefined              --|
  }
  
  if (isTrue(alwaysNormalize)) { // 如果是手写render
    normalizationType = ALWAYS_NORMALIZE
  }
  
  return _createElement(contenxt, tag, data, children, normalizationType)
}
复制代码
```

这里是对传入的参数处理，如果第三个参数传入的是数组(子元素)或者是基础类型的值，就将参数位置改变。然后对传入的最后一个参数是`true`还是`false`做处理，这会决定之后对`children`属性的处理方式。这里又是对`_createElement`做的封装，所以我们还要继续看它的定义：

```
export function _createElement(
  context, tag, data, children, normalizationType
  ) {
  
  if (normalizationType === ALWAYS_NORMALIZE) { // 手写render函数
    children = normalizeChildren(children)
  } else if (normalizationType === SIMPLE_NORMALIZE) { //编译render函数
    children = simpleNormalizeChildren(children)
  }
  
  if(typeof tag === 'string') {  // 标签
    let vnode, Ctor
    if(config.isReservedTag(tag)) {  // 如果是html标签
      vnode = new VNode(tag, data, children, undefined, undefined, context)
    }
    ...
  } else { // 就是组件了
    vnode = createComponent(tag, data, context, children)
  }
  ...
  return vnode
}
复制代码
```

首先我们会看到针对最后一个参数的布尔值对`children`做不同的处理，如果是编译的`render`函数，就将`children`格式化为一维数组：

```
function simpleNormalizeChildren(children) {  // 编译render的处理函数
  for (let i = 0; i < children.length; i++) {
    if (Array.isArray(children[i])) {
      return Array.prototype.concat.apply([], children)
    }
  }
  return children
}
复制代码
```

我们现在主要看下手写的`render`函数是怎么处理的，从接下来的`_createElement`方法我们知道，转化`VNode`是分为两种情况的：

> **1. 普通的元素节点转化为`VNode`**

以一段`children`是二维数组代码为示例，我们来说明普通元素是如何转`VNode`的：

```
render(h) {
  return h(
    "div",
    [
      [
        [h("h1", "title h1")],
        [h('h2', "title h2")]
      ],
      [
        h('h3', 'title h3')
      ]
    ]
  );
}
复制代码
```

因为`_createElement`方法是对`h`方法的封装，所以`h`方法的第一个参数对应的就是`_createElement`方法内的`tag`，第二个参数对应的是`data`。又因为`h`方法是递归的，所以首先从`h('h1', 'title h1')`开始解析，经过参数上移之后`children`就是`title h1`这段文本了，所以会在`normalizeChildren`方法将它转为`[createTextVNode(children)]`一个文本的`VNode`节点：

```
function normalizeChildren(children) {  // 手写`render`的处理函数
  return isPrimitive(children)  //原始类型 typeof为string/number/symbol/boolean之一
    ? [createTextVNode(children)]  // 转为数组的文本节点
    : Array.isArray(children)  // 如果是数组
      ? normalizeArrayChildren(children)
      : undefined
}
复制代码
```

接着会满足`_createElement`方法内的这个条件：

```
if(typeof tag === 'string'){ tag为h1标签
  if(config.isReservedTag(tag)) {  // 是html标签
    vnode = new VNode(
      tag,  // h1
      data, // undefined
      children,  转为了 [{text: 'title h1'}]
      undefined,
      undefined,
      context
    )
  }
}
...
return vnode

返回的vnode结构为：
{
  tag: h1,
  children: [
    { text: title h1 }
  ]
}
复制代码
```

然后依次处理`h('h2', "title h2")`，`h('h3', 'title h3')`会得到三个`VNode`实例的节点。接着会执行最外层的`h(div, [[VNode,VNode],[VNode]])`方法，注意它的结构是二维数组，这个时候它就满足`normalizeChildren`方法内的`Array.isArray(children)`这个条件了，会执行`normalizeArrayChildren`这个方法：

```
function normalizeArrayChildren(children) {
  const res = []  // 存放结果
  
  for(let i = 0; i < children.length; i++) {  // 遍历每一项
    let c = children[i]
    if(isUndef(c) || typeof c === 'boolean') { // 如果是undefined 或 布尔值
      continue  // 跳过
    }
    
    if(Array.isArray(c)) {  // 如果某一项是数组
      if(c.length > 0) {
        c = normalizeArrayChildren(c) // 递归结果赋值给c，结果就是[VNode]
        ... 合并相邻的文本节点
        res.push.apply(res, c)  //小操作
      }
    } else {
      ...
      res.push(c)
    }
  }
  return res
}
复制代码
```

如果`children`内的某一项是数组就递归调用自己，将自身传入并将返回的结果覆盖自身，递归内的结果就是`res.push(c)`得到的，这里`c`也是`[VNode]`数组结构。覆盖自己之后执行`res.push.apply(res, c)`，添加到`res`内。这里`vue`秀了一个小操作，在一个数组内`push`一个数组，本来应该是二维数组的，使用这个写法后`res.push.apply(res, c)`后，结果最后是就是一维数组了。`res`最后返回的结果`[VNode, VNode, VNode]`，这也是`children`最终的样子。接着执行`h('div', [VNode, VNode, VNode])`方法，又满足了之前同样的条件：

```
if (config.isReservedTag(tag)) {  // 标签为div
  vnode = new VNode(
    tag, data, children, undefined, undefined, context
  )
} 
return vnode
复制代码
```

所以最终得到的`vnode`结构就是这样的：

```
{
  tag: 'div',
  children: [VNode, VNode, VNode]
}
复制代码
```

以上就是普通元素节点转`VNode`的具体过程。

> **2. 组件转化为`VNode`**

接下来我们来了解组件`VNode`的创建过程，常见示例如下：

```
main.js
new Vue({
  render(h) {
    return h(App)
  }
})

app.vue
import Child from '@/pages/child'
export default {
  name: 'app',
  components: {
    Child
  }
}
复制代码
```

不知道大家有将引入的组件直接打印出来过没有，我们在`main.js`内打印下`App`组件：

```
{
  beforeCreate: [ƒ]
  beforeDestroy: [ƒ]
  components: {Child: {…}}
  name: "app"
  render: ƒ ()
  staticRenderFns: []
  __file: "src/App.vue"
  _compiled: true
}
复制代码
```

我们只是定义了`name`和`components`属性，打印出来为什么会多了这么多属性？这是`vue-loader`解析后添加的，例如`render: ƒ ()`就是将`App`组件的`template`模板转换而来的，我们记住这个一个组件对象即可。

让我们简单看一眼之前`_createElement`函数：

```
export function _createElement(
  context, tag, data, children, normalizationType
  ) {
  ...
  if(typeof tag === 'string') {  // 标签
    ...
  } else { // 就是组件了
    vnode = createComponent(
      tag,  // 组件对象
      data,  // undefined
      context,  // 当前vm实例
      children  // undefined
    )
  }
  ...
  return vnode
}
复制代码
```

很明显这里的`tag`并不一个`string`，转而会调用`createComponent()`方法：

```
export function createComponent (  // 上
  Ctor, data = {}, context, children, tag
) {
  const baseCtor = context.$options._base
  
  if (isObject(Ctor)) {  // 组件对象
    Ctor = baseCtor.extend(Ctor)  // 转为Vue的子类
  }
  ...
}
复制代码
```

这里要补充一点，在`new Vue()`之前定义全局`API`时：

```
export function initGlobalAPI(Vue) {
  ...
  Vue.options._base = Vue
  Vue.extend = function(extendOptions){...}
}
复制代码
```

经过初始化合并`options`之后当前实例就有了`context.$options._base`这个属性，然后执行它的`extend`这个方法，传入我们的组件对象，看下`extend`方法的定义：

```
Vue.cid = 0
let cid = 1
Vue.extend = function (extendOptions = {}) {
  const Super = this  // Vue基类构造函数
  const name = extendOptions.name || Super.options.name
  
  const Sub = function (options) {  // 定义构造函数
    this._init(options)  // _init继承而来
  }
  
  Sub.prototype = Object.create(Super.prototype)  // 继承基类Vue初始化定义的原型方法
  Sub.prototype.constructor = Sub  // 构造函数指向子类
  Sub.cid = cid++
  Sub.options = mergeOptions( // 子类合并options
    Super.options,  // components, directives, filters, _base
    extendOptions  // 传入的组件对象
  )
  Sub['super'] = Super // Vue基类

  // 将基类的静态方法赋值给子类
  Sub.extend = Super.extend
  Sub.mixin = Super.mixin
  Sub.use = Super.use

  ASSET_TYPES.forEach(function (type) { // ['component', 'directive', 'filter']
    Sub[type] = Super[type]
  })
  
  if (name) {  让组件可以递归调用自己，所以一定要定义name属性
    Sub.options.components[name] = Sub  // 将子类挂载到自己的components属性下
  }

  Sub.superOptions = Super.options
  Sub.extendOptions = extendOptions

  return Sub
}
复制代码
```

仔细观察`extend`这个方法不难发现，我们传入的组件对象相当于就是之前`new Vue(options)`里面的`options`，也就是用户自定义的配置，然后和`vue`之前就定义的原型方法以及全局`API`合并，然后返回一个新的构造函数，它拥有`Vue`完整的功能。让我们继续`createComponent`的其他逻辑：

```
export function createComponent (  // 中
  Ctor, data = {}, context, children, tag
) {
  ...
  const listeners = data.on  // 父组件v-on传递的事件对象格式
  data.on = data.nativeOn  // 组件的原生事件
  
  installComponentHooks(data)  // 为组件添加钩子方法
  ...
}
复制代码
```

之前说明初始化事件`initEvents`时，这里的`data.on`就是父组件传递给子组件的事件对象，赋值给变量`listeners`；`data.nativeOn`是绑定在组件上有`native`修饰符的事件。接着会执行一个组件比较重要的方法`installComponentHooks`，它的作用是往组件的`data`属性下挂载`hook`这个对象，里面有`init`，`prepatch`，`insert`，`destroy`四个方法，这四个方法会在之后的将`VNode`转为真实`Dom`的`patch`阶段会用到，当我们使用到时再来看它们的定义是什么。我们继续`createComponent`的其他逻辑：

```
export function createComponent (  // 下
  Ctor, data = {}, context, children, tag
) {
  ...
  const name = Ctor.options.name || tag  // 拼接组件tag用
  
  const vnode = new VNode(  // 创建组件VNode
    `vue-component-${Ctor.cid}${name ? `-${name}` : ''}`,  // 对应tag属性
    data, // 有父组件传递自定义事件和挂载的hook对象
    undefined,  // 对应children属性
    undefined,   // 对应text属性
    undefined,   // 对应elm属性
    context,  // 当前实例
    {  // 对应componentOptions属性
      Ctor,  // 子类构造函数
      propsData, // props具体值的对象集合
      listeners,   // 父组件传递自定义事件对象集合
      tag,  // 使用组件时的名称
      children // 插槽内的内容，也是VNode格式
    },  
    asyncFactory
  )
  
  return vnode
}
复制代码
```

组件生成的`VNode`如下：

```
{
  tag: 'vue-component-1-app',
  context: {...},
  componentOptions: {
    Ctor: function(){...},
    propsData: undefined,
    children: undefined,
    tag: undefined,
    children: undefined
  },
  data: {
    on: undefined,  // 为原生事件
    data: {
      init: function(){...},
      insert: function(){...},
      prepatch: function(){...},
      destroy: function(){...}
    }
  }
}
复制代码
```

如果看到`tag`属性是`vue-component`开头就是组件了，以上就组件`VNode`的初始化。简单理解就是如果`h`函数的参数是组件对象，就将它转为一个`Vue`的子类，虽然组件`VNode`的`children`，`text`，`ele`为`undefined`，但它的独有属性`componentOptions`保存了组件需要的相关信息。它们的`VNode`生成了，接下来的章节我们将使用它们，将它们变为真实的`Dom`~。

最后我们还是以一道`vue`可能会被问到的面试题作为本章的结束吧~

> #### 面试官微笑而又不失礼貌的问道：

- 请问`vue@2`为什么要引入虚拟`Dom`，谈谈对虚拟`Dom`的理解？

> #### 怼回去：

1. 随着现代应用对页面的功能要求越复杂，管理的状态越多，如果还是使用之前的`JavaScript`线程去频繁操作`GUI`线程的硕大`Dom`，对性能会有很大的损耗，而且也会造成状态难以管理，逻辑混乱等情况。引入虚拟`Dom`后，在框架的内部就将虚拟`Dom`树形结构与真实`Dom`做了映射，让我们不用在命令式的去操作`Dom`，可以将重心转为去维护这棵树形结构内的状态即可，状态的变化就会驱动`Dom`发生改变，具体的`Dom`操作`vue`帮我们完成，而且这些大部分可以在`JavaScript`线程完成，性能更高。
2. 虚拟`Dom`只是一种数据结构，可以让它不仅仅使用在浏览器环境，还可以用与`SSR`以及`Weex`等场景。