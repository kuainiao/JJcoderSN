# Vue原理解析（二）：初始化时beforeCreate之前做了什么？

上一章节我们知道了在`new Vue()`时，内部会执行一个`this._init()`方法，这个方法是在`initMixin(Vue)`内定义的:

```
export function initMixin(Vue) {
  Vue.prototype._init = function(options) {
    ...
  }
}
复制代码
```

当执行`new Vue()`执行后，触发的一系列初始化都在`_init`方法中启动，它的实现如下：

```
let uid = 0

Vue.prototype._init = function(options) {

  const vm = this
  vm._uid = uid++  // 唯一标识
  
  vm.$options = mergeOptions(  // 合并options
    resolveConstructorOptions(vm.constructor),
    options || {},
    vm
  )
  ...
  initLifecycle(vm) // 开始一系列的初始化
  initEvents(vm)
  initRender(vm)
  callHook(vm, 'beforeCreate')
  initInjections(vm)
  initState(vm)
  initProvide(vm)
  callHook(vm, 'created')
  ...
  if (vm.$options.el) {
    vm.$mount(vm.$options.el)
  }
}
复制代码
```

先需要交代下，每一个组件都是一个`Vue`构造函数的子类，这个之后会说明为何如此。从上往下我们一步步看，首先会定义`_uid`属性，这是为每个组件每一次初始化时做的一个唯一的私有属性标识，有时候会有些作用。

有一个使用它的小例子，找到一个组件所有的兄弟组件并剔除自己：

```
<div>
  ...
  <child-components />
  <child-components />  // 找到它的兄弟组件
  ... 其他组件
  <child-components />
</div>
复制代码
```

首先要找的组件需要定义`name`属性，当然定义`name`属性也是一个好的书写习惯。首先通过自己的父组件`($parent)`的所有子组件`($children)`过滤出相同`name`集合的组件，这个时候他们就是同一个组件了，虽然它们`name`相同，但是`_uid`不同，最后在集合内根据`_uid`剔除掉自己即可。

#### 合并options配置

回到主线任务，接着会合并`options`并在实例上挂载一个`$options`属性。合并什么东西了？这里是分两种情况的：

1. 初始化new Vue

在执行`new Vue`构造函数时，参数就是一个对象，也就是用户的自定义配置；会将它和`vue`之前定义的原型方法，全局`API`属性；还有全局的`Vue.mixin`内的参数，将这些都合并成为一个新的`options`，最后赋值给一个的新的属性`$options`。

1. 子组件初始化

如果是子组件初始化，除了合并以上那些外，还会将父组件的参数进行合并，如有父组件定义在子组件上的`event`、`props`等等。

经过合并之后就可以通过`this.$options.data`访问到用户定义的`data`函数，`this.$options.name`访问到用户定义的组件名称，这个合并后的属性很重要，会被经常使用到。

接下里会顺序的执行一堆初始化方法，首先是这三个：

```
1. initLifecycle(vm)
2. initEvents(vm)
3. initRender(vm)
复制代码
```

**1. initLifecycle(vm)**: 主要作用是确认组件的父子关系和初始化某些实例属性。

```
export function initLifecycle(vm) {
  const options = vm.$options  // 之前合并的属性
  
  let parent = options.parent;
  if (parent && !options.abstract) { //  找到第一个非抽象父组件
    while (parent.$options.abstract && parent.$parent) {
      parent = parent.$parent
    }
    parent.$children.push(vm)
  }
  
  vm.$parent = parent  // 找到后赋值
  vm.$root = parent ? parent.$root : vm  // 让每一个子组件的$root属性都是根组件
  
  vm.$children = []
  vm.$refs = {}
  
  vm._watcher = null
  ...
  vm._isDestroyed = false
  vm._isBeingDestroyed = false
}
复制代码
```

`vue`是组件式开发的，所以当前实例可能会是其他组件的子组件的同时也可能是其他组件的父组件。

首先会找到当前组件第一个非抽象类型的父组件，所以如果当前组件有父级且当前组件不是抽象组件就一直向上查找，直至找到后将找到的父级赋值给实例属性`vm.$parent`，然后将当前实例`push`到找到的父级的`$children`实例属性内，从而建立组件的父子关系。接下来的一些`_`开头是私有实例属性我们记住是在这里定义的即可，具体意思也是以后用到的时候再做说明。

**2. initEvents(vm)**: 主要作用是将父组件在使用`v-on`或`@`注册的自定义事件添加到子组件的事件中心中。

首先看下这个方法定义的地方：

```
export function initEvents (vm) {
  vm._events = Object.create(null)  // 事件中心
  ...
  const listeners = vm.$options._parentListeners  // 经过合并options得到的
  if (listeners) {
    updateComponentListeners(vm, listeners) 
  }
}
复制代码
```

我们首先要知道在`vue`中事件分为两种，他们的处理方式也各有不同：

> **2.1** 原生事件

在执行`initEvents`之前的模板编译阶段，会判断遇到的是`html`标签还是组件名，如果是`html`标签会在转为真实`dom`之后使用`addEventListener`注册浏览器原生事件。绑定事件是挂载`dom`的最后阶段，这里只是初始化阶段，这里主要是处理自定义事件相关，也就是另外一种，这里声明下，大家不要理会错了执行顺序。

> **2.2** 自定义事件

在经历过合并`options`阶段后，子组件就可以从`vm.$options._parentListeners`读取到父组件传过来的自定义事件：

```
<child-components @select='handleSelect' />
复制代码
```

传过来的事件数据格式是`{select:function(){}}`这样的，在`initEvents`方法内定义`vm._events`用来存储传过来的事件集合。

内部执行的方法`updateComponentListeners(vm, listeners)`主要是执行`updateListeners`方法。这个方法有两个执行时机，首先是现在的初始化阶段，还一个就是最后`patch`时的原生事件也会用到。它的作用是比较新旧事件的列表来确定事件的添加和移除以及事件修饰符的处理，现在主要看自定义事件的添加，它的作用是借助之前定义的`$on`，`$emit`方法，完成父子组件事件的通信，(详细的原理说明会在之后的全局`API`章节统一说明)。首先使用`$on`往`vm.events`事件中心下创建一个自定义事件名的数组集合项，数组内的每一项都是对应事件名的回调函数，例如：

```
vm._events.select = [function handleSelect(){}, ...]  // 可以有多个
复制代码
```

注册完成之后，使用`$emit`方法执行事件：

```
this.$emit('select')
复制代码
```

首先会读取到事件中心内`$emit`方法第一个参数`select`的对象的数组集合，然后将数组内每个回调函数顺序执行一遍即完成了`$emit`做的事情。

不知道大家有没有注意到`this.$emit`这个方法是在当前组件实例触发的，所以事件的原理可能跟大部分人理解的不一样，并不是父组件监听，子组件往父组件去派发事件。

而是子组件往自身的实例上派发事件，只是因为回调函数是在父组件的作用域下定义的，所以执行了父组件内定义的方法，就造成了父子之间事件通信的假象。知道这个原理特性后，我们可以做一些更`cool`的事情，例如：

```
<div>
  <parent-component>  // $on添加事件
    <child-component-1>
      <child-component-2>
        <child-component-3 />  // $emit触发事件
      </child-component-2>
    </child-components-1>
  </parent-component>
</div>
复制代码
```

我们可不可以在`parent-component`内使用`$on`添加事件到当前实例的事件中心，而在`child-components-3`内找到`parent-component`的组件实例并在它的事件中心触发对应的事件实现跨组件通信了，答案是可以了！这一原理发现再开发组件库时会有一定帮助。

**3. initRender(vm)**: 主要作用是挂载可以将`render`函数转为`vnode`的方法。

```
export function initRender(vm) {
  vm._vnode = null
  ...
  vm._c = (a, b, c, d) => createElement(vm, a, b, c, d, false)  //转化编译器的
  vm.$createElement = (a, b, c, d) => createElement(vm, a, b, c, d, true)  // 转化手写的
  ...
}
复制代码
```

主要作用是挂载`vm._c`和`vm.$createElement`两个方法，它们只是最后一个参数不同，这两个方法都可以将`render`函数转为`vnode`，从命名大家应该可以看出区别，`vm._c`转换的是通过编译器将`template`转换而来的`render`函数；而`vm.$createElement`转换的是用户自定义的`render`函数，比如：

```
new Vue({
  data: {
    msg: 'hello Vue!'
  },
  render(h) { // 这里的 h 就是vm.$createElement
    return h('span', this.msg);  
  }
}).$mount('#app');
复制代码
```

`render`函数的参数`h`就是`vm.$createElement`方法，将内部定义的树形结构数据转为`Vnode`的实例。

**4. callHook(vm, 'beforeCreate')**

终于我们要执行实例的第一个生命周期钩子`beforeCreate`，这里`callHook`的原理是怎样的，我们之后的生命周期章节会说明，现在这里只需要知道它会执行用户自定义的生命周期方法，如果有`mixin`混入的也一并执行。

好吧，实例的第一个生命周期钩子阶段的初始化工作完成了，一句话来主要说明下他们做了什么事情：

- initLifecycle(vm)：确认组件(也是`vue`实例)的父子关系
- initEvents(vm)：将父组件的自定义事件传递给子组件
- initRender(vm)：提供将`render`函数转为`vnode`的方法
- beforeCreate：执行组件的`beforeCreate`钩子函数

最后还是以一道`vue`容易被问道的面试题作为本章节的结束吧：

> #### 面试官微笑而又不失礼貌的问道：

- 请问可以在`beforeCreate`钩子内通过`this`访问到`data`中定义的变量么，为什么以及请问这个钩子可以做什么？

> #### 怼回去：

- 是不可以访问的，因为在`vue`初始化阶段，这个时候`data`中的变量还没有被挂载到`this`上，这个时候访问值会是`undefined`。`beforeCreate`这个钩子在平时业务开发中用的比较少，而像插件内部的`instanll`方法通过`Vue.use`方法安装时一般会选在`beforeCreate`这个钩子内执行，`vue-router`和`vuex`就是这么干的。