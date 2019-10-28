# Vue原理解析（一）：Vue到底是什么？

`Vue`，现在前端的当红炸子鸡，随着热度指数上升，实在是有必要从源码的角度，对它功能的实现原理一窥究竟。个人觉得看源码主要是看两样东西，从宏观上来说是它的设计思想和实现原理；微观上来说就是编程技巧，也就是俗称的骚操作。我们这次的侧重点是它的实现原理。好吧，让我们推开它那神秘的大门，进入`Vue`的世界~

### vue是什么？

`vue`究竟是什么？为什么就能实现这么多酷炫的功能，不知道大家有没有思考过这个问题。其实在每次初始化`vue`，使用`new Vue({...})`时，不难发现`vue`其实是一个类。不过即使在`ES6`已经如此普及的今天，`vue`的定义却是普通构造函数定义的，为什么没有采用`ES6`的`class`呢？这个我们稍后回答，通过层层追踪终于找到了`vue`被定义的地方：

```
function Vue(options) {
  ...
  this._init(options)
}
```

因为是原理解析，`flow`的类型检测及一些边界情况，如使用方式不对或参数不对或不是主要逻辑的代码我们就省略掉吧。比如省略号这里边界情况是使用时必须是`new Vue()`的形式，否则会报错。

其实`vue`源码就像一棵树，我们看之前最好要确定看什么功能，然后避开那些分叉逻辑，我们接下来的目标就是以`new Vue()`开始，走完一整条从初始化、数据、模板到真实`Dom`的这整个流程。

这就是`vue`最初始被定义的地方，你没看错，就是这么简单。当执行`new Vue`时，内部会执行一个方法 `this._init(options)`，将初始化的参数传入。

这里需要说明一点，在`vue`的内部，`_`符号开头定义的变量是供内部私有使用的，而`$` 符号定义的变量是供用户使用的，而且用户自定义的变量不能以`_`或`$`开头，以防止内部冲突。我们接着看：

```
import { initMixin } from './init'
import { stateMixin } from './state'
import { renderMixin } from './render'
import { eventsMixin } from './events'
import { lifecycleMixin } from './lifecycle'

function Vue(options) {
  ...
  this._init(options)
}

initMixin(Vue)
stateMixin(Vue)
eventsMixin(Vue)
lifecycleMixin(Vue)
renderMixin(Vue)
复制代码
```

现在可以回答之前的问题了，为什么不采用`ES6`的`class`来定义，因为这样可以方便的把`vue`的功能拆分到不同的目录中去维护，将`vue`的构造函数传入到以下方法内：

- initMixin(Vue)：定义`_init`方法。
- stateMixin(Vue)：定义数据相关的方法`$set`,`$delete`,`$watch`方法。
- eventsMixin(Vue)：定义事件相关的方法`$on`，`$once`，`$off`，`$emit`。
- lifecycleMixin(Vue)：定义`_update`，及生命周期相关的`$forceUpdate`和`$destroy`。
- renderMixin(Vue)：定义`$nextTick`，`_render`将render函数转为`vnode`。

这些方法都是在各自的文件内维护的，从而让代码结构更加清晰易懂可维护。如`this._init`方法被定义在：

```
export function initMixin(Vue) {
  Vue.prototype._init = function(options) {
    ...当执行new Vue时，进行一系列初始化并挂载
  }
}
复制代码
```

再这些`xxxMixin`完成后，接着会定义一些全局的`API`：

```
export function initGlobalAPI(Vue) {
  Vue.set方法
  Vue.delete方法
  Vue.nextTick方法
  
  ...
  
  内置组件：
  keep-alive
  transition
  transition-group
  
  ...
  
  initUse(Vue)：Vue.use方法
  initMixin(Vue)：Vue.mixin方法
  initExtend(Vue)：Vue.extend方法
  initAssetRegisters(Vue)：Vue.component，Vue.directive，Vue.filter方法
}
复制代码
```

这里有部分`API`和`xxxMixin`定义的原型方法功能是类似或相同的，如`this.$set`和`Vue.set`他们都是使用`set`这样一个内部定义的方法。

这里需要提一下`vue`的架构设计，它的架构是分层式的。最底层是一个`ES5`的构造函数，再上层在原型上会定义一些`_init`、`$watch`、`_render`等这样的方法，再上层会在构造函数自身定义全局的一些`API`，如`set`、`nextTick`、`use`等(以上这些是不区分平台的核心代码)，接着是跨平台和服务端渲染(这些暂时不在讨论范围)及编译器。将这些属性方法都定义好了之后，最后会导出一个完整的构造函数给到用户使用，而`new Vue`就是启动的钥匙。这就是我们陌生且又熟悉的`vue`，至于`Vue.prototype._init`内部做了啥？我们下章节再说吧，因为还有很多其他的要补充。

### 目录结构

刚才是从比较微观的角度近距离的观察了`vue`，现在我们从宏观角度来了解它内部的代码结构是如何组建起来的。 目录如下:

```
|-- dist  打包后的vue版本
|-- flow  类型检测，3.0换了typeScript
|-- script  构建不同版本vue的相关配置
|-- src  源码
    |-- compiler  编译器
    |-- core  不区分平台的核心代码
        |-- components  通用的抽象组件
        |-- global-api  全局API
        |-- instance  实例的构造函数和原型方法
        |-- observer  数据响应式
        |-- util  常用的工具方法
        |-- vdom  虚拟dom相关
    |-- platforms  不同平台不同实现
    |-- server  服务端渲染
    |-- sfc  .vue单文件组件解析
    |-- shared  全局通用工具方法
|-- test 测试
复制代码
```

- flow：`javaScript`是弱类型语言，使用`flow`以定义类型和检测类型，增加代码的健壮性。
- src/compiler：将`template`模板编译为`render`函数。
- src/core：与平台无关通用的逻辑，可以运行在任何`javaScript`环境下，如`web`、`Node.js`、`weex`嵌入原生应用中。
- src/platforms：针对`web`平台和`weex`平台分别的实现，并提供统一的`API`供调用。
- src/observer：`vue`检测数据数据变化改变视图的代码实现。
- src/vdom：将`render`函数转为`vnode`从而`patch`为真实`dom`以及`diff`算法的代码实现。
- dist：存放着针对不同使用方式的不同的`vue`版本。

### vue版本

`vue`使用的是`rollup`构建的，具体怎么构建的不重要，总之会构建出很多不同版本的`vue`。按照使用方式的不同，可以分为以下三类：

- UMD：通过``标签直接在浏览器中使用。
- CommonJS：使用比较旧的打包工具使用，如`webpack1`。
- ES Module：配合现代打包工具使用，如`webpack2`及以上。

而每个使用方式内又分为了完整版和运行时版本，这里主要以`ES Module`为例，有了官方脚手架其他两类应该没多少人用了。再说明这两个版本的区别之前，抱歉我又要补充点其他的。在`vue`的内部是只认`render`函数的，我们来自己定义一个`render`函数，也就是这么个东西:

```
new Vue({
  data: {
    msg: 'hello Vue!'
  },
  render(h) {
    return h('span', this.msg);
  }
}).$mount('#app');
复制代码
```

可能有人会纳闷了，既然只认`render`函数，同时我们开发好像从来并没有写过`render`函数，而是使用的`template`模板。这是因为有`vue-loader`，它会将我们在`template`内定义的内容编译为`render`函数，而这个编译就是区分完整版和运行时版本的关键所在，完整版就自带这个编译器，而运行时版本就没有，如下面这段代码如果是在运行时版本环境下就会报错了：

```
new Vue({
  data: {
    msg: 'hello Vue!'  
  },
  template: `<div>{{msg}}</div>`
})
复制代码
```

`vue-cli`默认是使用运行时版本的，更改或覆盖脚手架内的默认配置，将其更改为完整版即可通过编译：`'vue$': 'vue/dist/vue.esm.js'`，推荐还是使用运行时版本。好吧，具体区别最后我们以一个面试时经常会被问到的问题作为本章节的结束。

> 面试官微笑而又不失礼貌的问到：

- 请问`runtime`和`runtime-only`这两个版本的区别？

> 

- 主要是两点不同：

1. 最明显的就是大小的区别，带编译器会比不带的版本大`6kb`。
2. 编译的时机不同，编译器是运行时编译，性能会有一定的损耗；运行时版本是借助`loader`做的离线编译，运行性能更高。