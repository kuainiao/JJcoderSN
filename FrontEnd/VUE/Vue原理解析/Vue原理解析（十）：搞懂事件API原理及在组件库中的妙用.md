# Vue原理解析（十）：搞懂事件API原理及在组件库中的妙用

在`vue`内部初始化时会为每个组件实例挂载一个`this._events`私有的空对象属性：

```
vm._events = Object.create(null) // 没有__proto__属性
复制代码
```

这个里面存放的就是当前实例上的自定义事件集合，也就是自定义事件中心，它存放着当前组件所有的自定义事件。和自定义事件相关的`API`分为以下四个：`this.$on`、`this.$emit`、`this.$off`、`this.$once`，它们会往这个事件中心中添加、触发、移除对应的自定义事件，从而组成了`vue`的自定义事件系统，接下来看下它们都是怎么实现的。

- ### this.$on

> 描述：监听当前实例上的自定义事件。事件可以由`vm.$emit`触发，回调函数会接收所有传入事件触发函数的额外参数。

```
export default {
  created() {
    this.$on('test', res => {
      console.log(res)    
    })
  },
  methods: {
    handleClick() {
      this.$emit('test', 'hello-vue~')
    }
  }
}
复制代码
```

以上示例首先在`created`钩子内往当前组件实例的事件中心`_events`中添加一个名为`test`的自定义事件，第二个参数为该自定义事件的回调函数，而触发`handleClick`这个方法后，就会在事件中心中尝试找到`test`自定义事件，触发它并传递给回调函数`hello-vue~`这个字符串，从而打印出来。我们来看下`$on`的实现：

```
Vue.prototype.$on = function (event, fn) {
  const hookRE = /^hook:/    //检测自定义事件名是否是hook:开头
  
  const vm = this
  if (Array.isArray(event)) {  // 如果第一个参数是数组
    for (let i = 0; i < event.length; i++) {
      this.$on(event[i], fn)  // 递归
    }
  } else {
    (vm._events[event] || (vm._events[event] = [])).push(fn)
    // 如果有对应事件名就push，没有创建为空数组然后push
    
    if (hookRE.test(event)) {  // 如果是hook:开头
      vm._hasHookEvent = true  // 标志位为true
    }
  }
  return vm
}
复制代码
```

以上就是`$on`的实现了，它接受两个参数，自定义事件名`event`和对应的回调函数`fn`。主要就是往事件中心`_events`下挂载对应的`event`事件名`key`，而事件名对应的`key`又是一个数组形式，这样相同事件名的回调会在一个数组之内。而接下来的`_hasHookEvent`标志位表示是否监听组件的钩子函数，这个之后示例说明。

- ### this.$emit

> 描述：触发当前实例上的事件，附加参数都会传给监听器回调。

```
Vue.prototype.$emit = function (event) {
  const vm = this
  let cbs = vm._events[event]  // 找到事件名对应的回调集合
  if (cbs) {
    const args = toArray(arguments, 1)  // 将附加参数转为数组
    
    for (let i = 0; i < cbs.length; i++) {
      cbs[i].apply(vm, args)  // 挨个执行对应的回调集合
    }
  }
  return vm
}
复制代码
```

而`$emit`的实现会更好理解些，首先从事件中心中找到`event`对应的回调集合，然后将`$emit`其余参数转为`args`数组，最后挨个执行回调集合内的回调并传入`args`。通过这么一对朴实的`API`可以帮我们理解三件小事：

> #### 1. 理解自定义事件原理

```
app.vue
<template>
  <child-component @test='handleTest' />
</template>
export default {
  methods: {
    handleTest(res) {
      console.log(res)
    }
  }
}

----------------------------------------

child.vue
<template>
  <button @click='onClick'>btn</button>
</template>
export default {
  methods: {
    onClick() {
      this.$emit('test', 'hello-vue~')
    }
  }
}
复制代码
```

以上是父子组件通过自定义事件通信，想必大家非常熟悉。自定义事件的实现原理和通常解释的会不同，它们的原理是父组件在经过编译模板后，会将定义在子组件上的自定义事件`test`及其回调`handleTest`通过`$on`添加到子组件的事件中心中，当子组件通过`$emit`触发`test`自定义事件时，会在它的事件中心中去找`test`，找到后传递`hello-vue~`给回调函数并执行，不过因为回调函数`handleTest`是在父组件作用域内定义的，所以看起来就像是父子组件之间通信般。



![img](Untitled.assets/16cf7abfde438ab4)



> #### 2. 监听组件的钩子函数

也就是`$on`内自定义事件名之前是`hook:`的情况，可以监听组件的钩子函数触发：

```
app.vue
<template>
  <child-component @hook:created='handleHookEvent' />
</template>

复制代码
```

以上示例为当子组件的`created`钩子触发时，就触发父组件内定义的`handleHookEvent`回调。接下来让我们再看一个官网的示例，使用这个特性如何帮我们写出更优雅的代码：

```
监听组件钩子之前：
mounted () {
  this.picker = new Pikaday({  // Pikaday是一个日期选择库
    field: this.$refs.input,
    format: 'YYYY-MM-DD'
  })
},
beforeDestroy () {  // 销毁日期选择器
  this.picker.destroy()
}

监听组件钩子之后：
mounted() {
  this.attachDatepicker('startDateInput')
  this.attachDatepicker('endDateInput')  // 同时为两个input添加日期选择
},
methods: {
  attachDatepicker(refName) {  // 封装为一个方法
    const picker = new Pikaday({  // Pikaday是一个日期选择库
      field: this.$refs[refName],  // 为input添加日期选择
      format: 'YYYY-MM-DD'
    })

    this.$once('hook:beforeDestroy', () => {  // 监听beforeDestroy钩子
      picker.destroy()  // 销毁日期选择器
    })  // $once和$on类似，只是只会触发一次
  }
}
复制代码
```

首先不用在当前实例下挂载一个额外的属性，其次可以封装为一个方法，复用更方便。

> #### 3. 不借助`vuex`跨组件通信

再开发组件库时，因为都是独立的组件，从而引入`vuex`这种强依赖是不现实的，而且很多时候是用插槽来放置子组件，所以子组件的位置、嵌套、数量并不会确定，从而在组件库内完成跨组件的通信就尤为重要。

通过接下来的示例介绍组件库中会运用到的一种，使用`$on`和`$emit`来实现跨组件通信，子组件通过父组件的`name`属性找到对应的实例，找到后使用`$emit`触发父组件的自定义事件，而在这之前父组件已经使用`$on`完成了自定义事件的添加：

```
export default {
  methods: {  // 混入mixin使用
    dispatch(componentName, eventName, params) {
      let parent = this.$parent || this.$root  // 找父组件
      let name = parent.$options.name  // 父组件的name属性

      while (parent && (!name || name !== componentName)) {  // 和传入的componentName进行匹配
        parent = parent.$parent  // 一直向上查找

        if (parent) {
          name = parent.$options.name  // 重新赋值name
        }
      }
      if (parent) {  // 找到匹配的组件实例
        parent.$emit.apply(parent, [eventName].concat(params))  // $emit触发自定义事件
      }
    }
  }
}
复制代码
```

接下来介绍表单验证组件内的使用案例：

![img](Untitled.assets/16cf7d76b3bfcb97)

不知道大家是否对这种表单验证好奇过，为什么点一下提交，就可以将所有的表单项全部做验证，接下来笔者试着写一个极简的表单验证组件来说明它的原理。这里会有两个组件，一个是`iForm``iFormItem`



```
iForm组件：

<template>
  <div> <slot /> </div>  // 只有一个插槽
</template>

<script>
export default {
  name: "iForm",  // 组件名很重要
  data() {
    return {
      fields: []  // 收集所有表单项的集合
    };
  },
  created() {
    this.$on("on-form-item-add", field => {  // $on必须得比$emit先执行，因为要先添加嘛
      this.fields.push(field)  // 添加到集合内
    });
  },
  methods: {
    validataAll() {  // 验证所有的接口方法
      this.fields.forEach(item => {
        item.validateVal()  // 执行每个表单项内的validateVal方法
      });
    }
  }
};
</script>
复制代码
```

模板只有一个`slot`插槽，这个组件主要是做两件事，将所有的表单项的实例收集到`fields`内，提供一个可以验证所有表单项的方法`validataAll`，然后看下`iFormItem`组件：

```
<template>
  <div>
    <input v-model="curValue" style="border: 1px solid #aaa;" />
    <span style="color: red;" v-show="showTip">输入不能为空</span>
  </div>
</template>

<script>
import emitter from "./emitter"  // 引入之前的dispatch方法

export default {
  name: "iFormItem",
  mixins: [emitter],  // 混入
  data() {
    return {
      curValue: "",  // 表单项的值
      showTip: false  // 是否验证通过
    };
  },
  created() {
    this.dispatch("iForm", "on-form-item-add", this)  // 将当前实例传给iForm组件
  },
  methods: {
    validateVal() {  // 某个表单项的验证方法
      if (this.curValue === "") {  // 不能为空
        this.showTip = true  // 验证不通过
      }
    }
  }
};
</script>
复制代码
```

看到这里我们知道了原来这种表单验证原理是将每个表单项的实例传入给`iForm`，然后在`iForm`内遍历的执行每个表单项的验证方法，从而可以一次性验证完所有的表单项。表单验证调用方式：

```
<template>
  <div>
    <i-form ref='form'>  // 引用
      <i-form-item />
      <i-form-item />
      <i-form-item />
      <i-form-item />
      <i-form-item />
    </i-form>
    <button @click="submit">提交</button>
  </div>
</template>

<script>
import iForm from "./form"
import iFormItem from "./form-item"

export default {
  methods: {
    submit() {
      this.$refs['form'].validataAll() // 验证所有
    }
  },
  components: {
    iForm, iFormItem
  }
};
</script>
复制代码
```

这里就使用了`$on`和`$emit`这么一对`API`，通过组件的名称去查找组件实例，不论嵌套以及数量，然后使用事件`API`去跨组件传递参数。

> 注意点：当`$on`和`$emit`配合使用时，`$on`要优先与`$emit`执行。因为首先要往实例的事件中心去添加事件，才能被触发。

- ### this.$off

> 描述：移除自定义事件监听器，不过根据传入的参数分为三种形式：

- 如果没有提供参数，则移除所有的事件监听器；
- 如果只提供了事件，则移除该事件所有的监听器；
- 如果同时提供了事件与回调，则只移除这个回调的监听器。

```
export default {
  created() {
    this.$on('test1', this.test1)
    this.$on('test2', this.test2)
  },
  mounted() {
    this.$off()  // 没有参数，清空事件中心
  }
}

-------------------------------------------

export default {
  created() {
    this.$on('test1', this.test1)
    this.$on('test2', this.test2)
  },
  mounted() {
    this.$off('test1')  // 在事件中心中移除test1
  }
}

-------------------------------------------

export default {
  created() {
    this.$on('test1', this.test1)
    this.$on('test1', this.test3)
    this.$on('test2', this.test2)
  },
  mounted() {
    this.$off('test1', this.test3)  // 在事件中心中移除事件test1的test3回调
  }
}
复制代码
```

知道了这个`API`的调用方式之后，接下来看下`$off`的实现方式：

```
Vue.prototype.$off = function (event, fn) {
  const vm = this
  if (!arguments.length) {  // 如果没有传递参数
    vm._events = Object.create(null)  // 重置事件中心
    return vm
  }
  
  if (Array.isArray(event)) {  // event如果是数组
    for (let i = 0, l = event.length; i < l; i++) {
      vm.$off(event[i], fn)  // 递归清空
    }
    return vm
  }
  
  if (!fn) {  // 只传递了事件名没回调
    vm._events[event] = null  // 清空对应所有的回调
    return vm
  }
  
  const cbs = vm._events[event]  // 获取回调集合
  let cb
  let i = cbs.length
  while (i--) {
    cb = cbs[i]  // 回调集合里的每一项
    if (cb === fn || cb.fn === fn) {  // cb.fn为$once时挂载的
      cbs.splice(i, 1)  // 找到对应的回调，从集合内移除
      break
    }
  }
  return vm
}
复制代码
```

也是分为了三种情况，根据参数的不同做分别处理。

- ### this.$once

> 描述：监听一个自定义事件，但是只触发一次，在第一次触发之后移除监听器。

效果和`$on`是类似的，只是说触发一次之后会从事件中心中移除。所以它的实现思路也很好理解，首先通过`$on`实现功能，当触发之后从事件中心中移除这个事件。来看下它的实现原理：

```
Vue.prototype.$once = function (event, fn) {
  const vm = this
  function on () {
    vm.$off(event, on)
    fn.apply(vm, arguments)
  }
  on.fn = fn  // 回调挂载到on下，移除时好做判断
  vm.$on(event, on)  // 将on添加到事件中心中
  return vm
}
复制代码
```

首先将回调`fn`挂载到`on`函数下，将`on`函数注册到事件中心去，触发自定义事件时首先会在`$emit`内执行`on`函数，在`on`函数内执行`$off`将`on`函数移除，然后执行传入的`fn`回调。这个时候事件中心没有了`on`函数，回调函数也执行了一次，完成`$once`功能~

> 事件`API`总结：`$on`往事件中心添加事件；`$emit`是触发事件中心里的事件；`$off`是移除事件中心里的事件；`$once`是触发一次事件中心里的事件。哪怕是如此不显眼的`API`，再理解了它们的实现原理后，也能让我们再更多场景更好的使用它们~

最后按照惯例我们还是以一道`vue`可能会被问到的面试题作为本章的结束(想不到事件相关特别好的题目~)。

> #### 面试官微笑而又不失礼貌的问道：

- 说下自定义事件的机制。

> #### 怼回去：

- 子组件使用`this.$emit`触发事件时，会在当前实例的事件中心去查找对应的事件，然后执行它。不过这个事件回调是在父组件的作用域里定义的，所以`$emit`里的参数会传递给父组件的回调函数，从而完成父子组件通信。