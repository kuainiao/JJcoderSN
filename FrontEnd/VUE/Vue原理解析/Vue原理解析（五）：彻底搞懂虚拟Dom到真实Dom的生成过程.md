# Vue原理解析（五）：彻底搞懂虚拟Dom到真实Dom的生成过程

再有一棵树形结构的`JavaScript`对象后，我们现在需要做的就是将这棵树跟真实的`Dom`树形成映射关系，首先简单回顾之前遇到的`mountComponent`方法：

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

我们已经执行完了`vm._render`方法拿到了`VNode`，现在将它作为参数传给`vm._update`方法并执行。`vm._update`这个方法的作用就是就是将`VNode`转为真实的`Dom`，不过它有两个执行的时机：

> #### 首次渲染

- 当执行`new Vue`到此时就是首次渲染了，会将传入的`VNode`对象映射为真实的`Dom`。

> #### 更新页面

- 数据变化会驱动页面发生变化，这也是`vue`最独特的特性之一，数据改变之前和之后会生成两份`VNode`进行比较，而怎么样在旧的`VNode`上做最小的改动去渲染页面，这样一个`diff`算法还是挺复杂的。如再没有先说清楚数据响应式是怎么回事之前，而直接讲`diff`对理解`vue`的整体流程并不太好。所以我们这章分析完首次渲染后，下一章就是数据响应式，之后才是`diff`比对，如此排序，万望理解。

我们现在先来看下`vm._update`方法的定义：

```
Vue.prototype._update = function(vnode) {
  ... 首次渲染
  vm.$el = vm.__patch__(vm.$el, vnode)  // 覆盖原来的vm.$el
  ...
}
复制代码
```

这里的`vm.$el`是之前在`mountComponent`方法内就挂载的，一个真实`Dom`元素。首次渲染会传入`vm.$el`以及得到的`VNode`，所以看下`vm.__patch__`定义：

```
Vue.prototype.__patch__ = createPatchFunction({ nodeOps, modules }) 
复制代码
```

`__patch__`是`createPatchFunction`方法内部返回的一个方法，它接受一个对象：

`nodeOps`属性：封装了操作原生`Dom`的一些方法的集合，如创建、插入、移除这些，再使用到的地方再详解。

`modules`属性：创建真实`Dom`也需要生成它的如`class`/`attrs`/`style`等属性。`modules`是一个数组集合，数组的每一项都是这些属性对应的钩子方法，这些属性的创建、更新、销毁等都有对应钩子方法，当某一时刻需要做某件事，执行对应的钩子即可。比如它们都有`create`这个钩子方法，如将这些`create`钩子收集到一个数组内，需要在真实`Dom`上创建这些属性时，依次执行数组的每一项，也就是依次创建了它们。

> Ps: 这里`modules`属性内的钩子方法是区分平台的，`web`、`weex`以及`SSR`它们调用`VNode`方法方式并不相同，所以`vue`在这里又使用了函数柯里化这个骚操作，在`createPatchFunction`内将平台的差异化抹平，从而`__patch__`方法只用接收新旧`node`即可。

### 生成Dom

这里大家记住一句话即可，无论`VNode`是什么类型的节点，只有三种类型的节点会被创建并插入到的`Dom`中：元素节点、注释节点、和文本节点。

我们接着来看下`createPatchFunction`它究竟返回一个什么样的方法：

```
export function createPatchFunction(backend) {
  ...
  const { modules, nodeOps } = backend  // 解构出传入的集合
  
  return function (oldVnode, vnode) {  // 接收新旧vnode
    ...
    
    const isRealElement = isDef(oldVnode.nodeType) // 是否是真实Dom
    if(isRealElement) {  // $el是真实Dom
      oldVnode = emptyNodeAt(oldVnode)  // 转为VNode格式覆盖自己
    }
    ...
  }
}
复制代码
```

首次渲染时没有`oldVnode`，`oldVnode`就是`$el`，一个真实的`dom`，经过`emptyNodeAt(oldVnode)`方法包装：

```
function emptyNodeAt(elm) {
  return new VNode(
    nodeOps.tagName(elm).toLowerCase(), // 对应tag属性
    {},  // 对应data
    [],   // 对应children
    undefined,  //对应text
    elm  // 真实dom赋值给了elm属性
  )
}

包装后的：
{
  tag: 'div',
  elm: '<div id="app"></div>' // 真实dom
}

-------------------------------------------------------

nodeOps：
export function tagName (node) {  // 返回节点的标签名
  return node.tagName  
}
复制代码
```

再将传入的`$el`属性转为了`VNode`格式之后，我们继续：

```
export function createPatchFunction(backend) { 
  ...
  
  return function (oldVnode, vnode) {  // 接收新旧vnode
  
    const insertedVnodeQueue = []
    ...
    const oldElm = oldVnode.elm  //包装后的真实Dom <div id='app'></div>
    const parentElm = nodeOps.parentNode(oldElm)  // 首次父节点为<body></body>
  	
    createElm(  // 创建真实Dom
      vnode, // 第二个参数
      insertedVnodeQueue,  // 空数组
      parentElm,  // <body></body>
      nodeOps.nextSibling(oldElm)  // 下一个节点
    )
    
    return vnode.elm // 返回真实Dom覆盖vm.$el
  }
}
                                              
------------------------------------------------------

nodeOps：
export function parentNode (node) {  // 获取父节点
  return node.parentNode 
}

export function nextSibling(node) {  // 获取下一个节点
  return node.nextSibing  
}
复制代码
```

`createElm`方法开始生成真实的`Dom`，`VNode`生成真实的`Dom`的方式还是分为元素节点和组件两种方式，所以我们使用上一章生成的`VNode`分别说明。

> ### 1. 元素节点生成Dom

```
{  // 元素节点VNode
  tag: 'div',
  children: [{
      tag: 'h1',
      children: [
        {text: 'title h1'}
      ]
    }, {
      tag: 'h2',
      children: [
        {text: 'title h2'}
      ]
    }, {
      tag: 'h3',
      children: [
        {text: 'title h3'}
      ]
    }
  ]
}
复制代码
```

大家可以先看下这个流程图有一个印象即可，接下来再看具体实现时相信思路会清晰很多：

![img](Untitled%203.assets/16c67a97632d39c9)



开始创建`Dom`，我们来看下它的定义：

```
function createElm(vnode, insertedVnodeQueue, parentElm, refElm, nested, ownerArray, index) { 
  ...
  const children = vnode.children  // [VNode, VNode, VNode]
  const tag = vnode.tag  // div
  
  if (createComponent(vnode, insertedVnodeQueue, parentElm, refElm)) {
    return  // 如果是组件结果返回true，不会继续，之后详解createComponent
  }
  
  if(isDef(tag)) {  // 元素节点
    vnode.elm = nodeOps.createElement(tag)  // 创建父节点
    createChildren(vnode, children, insertedVnodeQueue)  // 创建子节点
    insert(parentElm, vnode.elm, refElm)  // 插入
    
  } else if(isTrue(vnode.isComment)) {  // 注释节点
    vnode.elm = nodeOps.createComment(vnode.text)  // 创建注释节点
    insert(parentElm, vnode.elm, refElm); // 插入到父节点
    
  } else {  // 文本节点
    vnode.elm = nodeOps.createTextNode(vnode.text)  // 创建文本节点
    insert(parentElm, vnode.elm, refElm)  // 插入到父节点
  }
  
  ...
}

------------------------------------------------------------------

nodeOps：
export function createElement(tagName) {  // 创建节点
  return document.createElement(tagName)
}

export function createComment(text) {  //创建注释节点
  return document.createComment(text)
}

export function createTextNode(text) {  // 创建文本节点
  return document.createTextNode(text)
}

function insert (parent, elm, ref) {  //插入dom操作
  if (isDef(parent)) {  // 有父节点
    if (isDef(ref)) { // 有参考节点
      if (ref.parentNode === parent) {  // 参考节点的父节点等于传入的父节点
        nodeOps.insertBefore(parent, elm, ref)  // 在父节点内的参考节点之前插入elm
      }
    } else {
      nodeOps.appendChild(parent, elm)  //  添加elm到parent内
    }
  }  // 没有父节点什么都不做
}
这算一个比较重要的方法，因为很多地方会用到。
复制代码
```

依次判断是否是元素节点、注释节点、文本节点，分别创建它们然后插入到父节点里面，这里主要介绍创建元素节点，另外两个并没有复杂的逻辑。我们来看下`createChild`方法定义：

```
function createChild(vnode, children, insertedVnodeQueue) {
  if(Array.isArray(children)) {  // 是数组
    for(let i = 0; i < children.length; ++i) {  // 遍历vnode每一项
      createElm(  // 递归调用
        children[i], 
        insertedVnodeQueue, 
        vnode.elm, 
        null, 
        true, // 不是根节点插入
        children, 
        i
      )
    }
  } else if(isPrimitive(vnode.text)) {  //typeof为string/number/symbol/boolean之一
    nodeOps.appendChild(  // 创建并插入到父节点
      vnode.elm, 
      nodeOps.createTextNode(String(vnode.text))
    )
  }
}

-------------------------------------------------------------------------------

nodeOps:
export default appendChild(node, child) {  // 添加子节点
  node.appendChild(child)
}
复制代码
```

开始创建子节点，遍历`VNode`的每一项，每一项还是使用之前的`createElm`方法创建`Dom`。如果某一项又是数组，继续调用`createChild`创建某一项的子节点；如果某一项不是数组，创建文本节点并将它添加到父节点内。像这样使用递归的形式将嵌套的`VNode`全部创建为真实的`Dom`。

再看一遍流程图，相信大家疑惑已经减少很多：



![img](Untitled%203.assets/16c67a9b9c773928)

简单来说就是由里向外的挨个创建出真实的`Dom``Dom``body`



> ### 2. 组件VNode生成Dom

```
{  // 组件VNode
  tag: 'vue-component-1-app',
  context: {...},
  componentOptions: {
    Ctor: function(){...},  // 子组件构造函数
    propsData: undefined,
    children: undefined,
    tag: undefined,
    children: undefined
  },
  data: {
    on: undefined,  // 原生事件
    hook: {  // 组件钩子
      init: function(){...},
      insert: function(){...},
      prepatch: function(){...},
      destroy: function(){...}
    }
  }
}

-------------------------------------------

<template>  // app组件内模板
  <div>app text</div>
</template>
复制代码
```

首先还是看张简易流程图，留个印象即可，方便理清之后的逻辑顺序：



![img](Untitled%203.assets/16c6700b90a9d618)

我们使用上一章组件生成的`VNode``createElm``Dom`



```
function createElm(vnode, insertedVnodeQueue, parentElm, refElm) { 
  ...
  if (createComponent(vnode, insertedVnodeQueue, parentElm, refElm)) { // 组件分支
    return  
  }
  ...
复制代码
```

执行`createComponent`方法，如果是元素节点不会返回任何东西，所以是`undefined`，会继续走接下来的创建元素节点的逻辑。现在是组件，我们看下`createComponent`的实现：

```
function createComponent(vnode, insertedVnodeQueue, parentElm, refElm) {
  let i = vnode.data
  if(isDef(i)) {
    if(isDef(i = i.hook) && isDef(i = i.init)) {
      i(vnode)  // 执行init方法
    }
    
    ...
  }
}
复制代码
```

首先会将组件的`vnode.data`赋值给`i`，是否有这个属性就能判断是否是组件`vnode`。之后的`if(isDef(i = i.hook) && isDef(i = i.init))`集判断和赋值为一体，`if`内的`i(vnode)`就是执行的组件`init(vnode)`方法。这个时候我们来看下组件的`init`钩子方法做了什么：

```
import activeInstance  // 全局变量

const init = vnode => {
  const child = vnode.componentInstance = 
    createComponentInstanceForVnode(vnode, activeInstance)
  ...
}
复制代码
```

`activeInstance`是一个全局的变量，再`update`方法内赋值为当前实例，再当前实例做`__patch__`的过程中作为子组件的父实例传入，在子组件的`initLifecycle`时构建组件关系。将`createComponentInstanceForVnode`执行的结果赋值给了`vnode.componentInstance`，所以看下它的返回的结果是什么：

```
export  createComponentInstanceForVnode(vnode, parent) {  // parent为全局变量activeInstance
  const options = {  // 组件的options
    _isComponent: true,  // 设置一个标记位，表明是组件
    _parentVnode: vnode, 
    parent  // 子组件的父vm实例，让初始化initLifecycle可以建立父子关系
  }
  
  return new vnode.componentOptions.Ctor(options)  // 子组件的构造函数定义为Ctor
}
复制代码
```

再组件的`init`方法内首先执行`createComponentInstanceForVnode`方法，这个方法的内部就会将子组件的构造函数实例化，因为子组件的构造函数继承了基类`Vue`的所有能力，这个时候相当于执行`new Vue({...})`，接下来又会执行`_init`方法进行一系列的子组件的初始化逻辑，我们回到`_init`方法内，因为它们之间还是有些不同的地方：

```
Vue.prototype._init = function(options) {
  if(options && options._isComponent) {  // 组件的合并options，_isComponent为之前定义的标记位
    initInternalComponent(this, options)  // 区分是因为组件的合并项会简单很多
  }
  
  initLifecycle(vm)  // 建立父子关系
  ...
  callHook(vm, 'created')
  
  if (vm.$options.el) { // 组件是没有el属性的，所以到这里咋然而止
    vm.$mount(vm.$options.el)
  }
}

----------------------------------------------------------------------------------------

function initInternalComponent(vm, options) {  // 合并子组件options
  const opts = vm.$options = Object.create(vm.constructor.options)
  opts.parent = options.parent  // 组件init赋值，全局变量activeInstance
  opts._parentVnode = options._parentVnode  // 组件init赋值，组件的vnode 
  ...
}
复制代码
```

前面都还执行的好好的，最后却因为没有`el`属性，所以没有挂载，`createComponentInstanceForVnode`方法执行完毕。这个时候我们回到组件的`init`方法，补全剩下的逻辑：

```
const init = vnode => {
  const child = vnode.componentInstance = // 得到组件的实例
    createComponentInstanceForVnode(vnode, activeInstance)
    
  child.$mount(undefined)  // 那就手动挂载呗
}
复制代码
```

我们在`init`方法内手动挂载这个组件，接着又会执行组件的`_render()`方法得到组件内元素节点`VNode`，然后执行`vm._update()`，执行组件的`__patch__`方法，因为`$mount`方法传入的是`undefined`，`oldVnode`也是`undefined`，会执行`__patch__`内的这段逻辑：

```
return function patch(oldVnode, vnode) {
  ...
  if (isUndef(oldVnode)) {
    createElm(vnode, insertedVnodeQueue)
  }
  ...
}

复制代码
```

这次执行`createElm`时没有传入第三个参数父节点的，那组件创建好的`Dom`放哪生效了？没有父节点也要生成`Dom`不是，这个时候执行的是组件的`__patch__`，所以参数`vnode`就是组件内元素节点的`vnode`了：

```
<template> // app组件内模板
  <div>app text</div>
</template>

-------------------------

{  // app内元素vnode
  tag: 'div',
  children: [
    {text: app text}
  ],
  parent: {  // 子组件_init时执行initLifecycle建立的关系
    tag: 'vue-component-1-app',
    componentOptions: {...}
  }
}
复制代码
```

很明显这个时候不是组件了，即使是组件也没关系，大不了还是执行一遍`createComponent`创建组件的逻辑，因为总会有组件是由元素节点组成的。这个时候我们执行一遍创建元素节点的逻辑，因为没有第三个参数父节点，所以组件的`Dom`虽然创建好了，并不会在这里插入。请注意这个时候组件的`init`已经完成，但是组件的`createComponent`方法并没有完成，我们补全它的逻辑：

```
function createComponent(vnode, insertedVnodeQueue, parentElm, refElm) {
  let i = vnode.data;
  if (isDef(i)) {
    if (isDef(i = i.hook) && isDef(i = i.init)) {
      i(vnode)  // init已经完成
    }
    
    if (isDef(vnode.componentInstance)) {  // 执行组件init时被赋值
    
      initComponent(vnode)  // 赋值真实dom给vnode.elm
      
      insert(parentElm, vnode.elm, refElm)  // 组件Dom在这里插入
      ...
      return true  // 所以会直接return
    }
  }
}

-----------------------------------------------------------------------

function initComponent(vnode) {
  ...
  vnode.elm = vnode.componentInstance.$el  // __patch__返回的真实dom
  ...
}
复制代码
```

无论是嵌套多么深的组件，遇到组件的后就执行`init`，在`init`的`__patch__`过程中又遇到嵌套组件，那就再执行嵌套组件的`init`，嵌套组件完成`__patch__`后将真实的`Dom`插入到它的父节点内，接着执行完外层组件的`__patch__`又插入到它的父节点内，最后插入到`body`内，完成嵌套组件的创建过程，总之还是一个由里及外的过程。

再回过头来看这张图，相信会好理解很多~

![img](Untitled%203.assets/16c6769db1243c4a)

我们再将本章最初的`mountComponent`



```
export function mountComponent(vm, el) {
  ...
  const updateComponent = () => {
    vm._update(vm._render())
  }
  
  new Watcher(vm, updateComponent, noop, {
    before() {
      if(vm._isMounted) {
        callHook(vm, 'beforeUpdate')
      }
    }   
  }, true)
  
  ...
  callHook(vm, 'mounted')
  
  return vm
}
复制代码
```

接下来会将`updateComponent`传入到一个`Watcher`的类中，这个类是干嘛的，我们下一章再说明，接下来执行`mounted`钩子方法。至此`new Vue`的整个流程就全部走完了。我们回顾下从`new Vue`开始它的执行顺序：

```
new Vue ==> vm._init() ==> vm.$mount(el) ==> vm._render()  ==> vm.update(vnode) 
复制代码
```

最后我们还是以一道`vue`可能会被问到的面试题作为本章的结束吧~

> #### 面试官微笑而又不失礼貌的问道：

- 父子两个组件同时定义了`beforeCreate`、`created`、`beforeMounte`、`mounted`四个钩子，它们的执行顺序是怎么样的？

> #### 怼回去：

- 如果大家看完前面的章节，相信这个问题已经了然于胸了。首先会执行父组件的初始化过程，所以会依次执行`beforeCreate`、`created`、在执行挂载前又会执行`beforeMount`钩子，不过在生成真实`dom`的`__patch__`过程中遇到嵌套子组件后又会转为去执行子组件的初始化钩子`beforeCreate`、`created`，子组件在挂载前会执行`beforeMounte`，再完成子组件的`Dom`创建后执行`mounted`。这个父组件的`__patch__`过程才算完成，最后执行父组件的`mounted`钩子，这就是它们的执行顺序。执行顺序如下：

```
parent beforeCreate
parent created
parent beforeMounte
    child beforeCreate
    child created
    child beforeMounte
    child mounted
parent mounted
```