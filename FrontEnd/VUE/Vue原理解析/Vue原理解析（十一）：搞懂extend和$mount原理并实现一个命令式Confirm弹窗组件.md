# Vue原理解析（十一）：搞懂extend和$mount原理并实现一个命令式Confirm弹窗组件

在学习老黄的[Vue2.0开发企业级移动端音乐Web App](https://coding.imooc.com/class/107.html)课程时，里面有一个精美的确认弹窗组件，如下：

![img](Untitled%201.assets/16d495d9c4d222bc)

不过使用起来并不是很方便，如每个使用的地方需要引入该组件，需要注册，需要给组件加`ref`



```
this.$Confirm({...})
  .then(confirm => {
    ...
  })
  .catch(cancel => {
    ...
  })
复制代码
```

### 原理解析之extend和$mount

这两个都是`vue`提供的`API`，不过在平时的业务开发中使用并不多。在`vue`的内部也有使用过这一对`API`。遇到嵌套组件时，首先将子组件转为组件形式的`VNode`时，会将引入的组件对象使用`extend`转为子组件的构造函数，作为`VNode`的一个属性`Ctor`；然后在将`VNode`转为真实的`Dom`的时候实例化这个构造函数；最后实例化完成后手动调用`$mount`进行挂载，将真实`Dom`插入到父节点内完成渲染。

> 所以这个弹窗组件可以这样实现，我们自己对组件对象使用`extend`转为构造函数，然后手动调用`$mount`转为真实`Dom`，由我们来指定一个父节点让它插入到指定的位置。

在动手前，我们再多花点时间深入理解下流程细节：

#### extend

> 接受的是一个组件对象，再执行`extend`时将继承基类构造器上的一些属性、原型方法、静态方法等，最后返回`Sub`这么一个构造好的子组件构造函数。拥有和`vue`基类一样的能力，并在实例化时会执行继承来的`_init`方法完成子组件的初始化。

```
Vue.extend = function (extendOptions = {}) {
  const Super = this  // Vue基类构造函数
  const name = extendOptions.name || Super.options.name
  
  const Sub = function (options) {  // 定义构造函数
    this._init(options)  // _init继承而来
  }
  
  Sub.prototype = Object.create(Super.prototype)  // 继承基类Vue初始化定义的原型方法
  Sub.prototype.constructor = Sub  // 构造函数指向子类
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

  return Sub  // 返回子组件的构造函数
}
复制代码
```

#### 实例化Sub

> 执行`_init`组件初始化的一系列操作，初始化事件、生命周期、状态等等。将`data`或`props`内定义的变量挂载到当前`this`实例下，最后返回一个实例化后的对象。

```
Vue.prototype._init = function(options) {  // 初始化
  ...
  initLifecycle(vm)
  initEvents(vm)
  initRender(vm)
  callHook(vm, 'beforeCreate')
  initInjections(vm)
  initState(vm)
  initProvide(vm)
  callHook(vm, 'created')  // 初始化阶段完成
  ...
  
  if (vm.$options.el) {  // 开始挂载阶段
    vm.$mount(vm.$options.el)  // 执行挂载
  }
}
复制代码
```

#### $mount

> 在得到初始化后的对象后，开始组件的挂载。首先将当前`render`函数转为`VNode`，然后将`VNode`转为真实`Dom`插入到页面完成渲染。再完成挂载之后，会在当前组件实例`this`下挂载`$el`属性，它就是完成挂载后对应的真实`Dom`，我们就需要使用这个属性。

### 组件改造

#### 1. 写出组件 (完整代码在最后)

> 因为是`Promise`的方式调用的，所以显示后返回`Promise`对象，这里只放出主要的`JavaScript`部分：

```
export default {
  data() {
    return {
      showFlag: false,
      title: "确认清空所有历史纪录吗?",  // 可以使用props
      ConfirmBtnText: "确定",  // 为什么不用props接受参数
      cancelBtnText: "取消"  // 之后会明白
    };
  },
  methods: {
    show(cb) {  // 加入一个在执行Promise前的回调
      this.showFlag = true;
      typeof cb === "function" && cb.call(this, this);
      return new Promise((resolve, reject) => { // 返回Promise
        this.reject = reject;  // 给取消按钮使用
        this.resolve = resolve;  // 给确认按钮使用
      });
    },
    cancel() {
      this.reject("cancel");  // 抛个字符串
      this.hide();
    },
    confirm() {
      this.resolve("confirm");
      this.hide();
    },
    hide() {
      this.showFlag = false;
      document.body.removeChild(this.$el);  // 结束移除Dom
      this.$destroy();  // 执行组件销毁
    }
  }
};
复制代码
```

#### 2. 转换调用方式

> 组件对象已经有了，接下来就是将它转为命令式可调用的：

```
confirm/index.js

import Vue from 'vue';
import Confirm from './confirm';  // 引入组件

let newInstance;
const ConfirmInstance = Vue.extend(Confirm);  // 创建构造函数

const initInstance = () => { // 执行方法后完成挂载
  newInstance = new ConfirmInstance();  // 实例化
  document.body.appendChild(newInstance.$mount().$el);
  // 实例化后手动挂载，得到$el真实Dom，将其添加到body最后
}

export default options => { 导出一个方法，接受配置参数
  if (!newInstance) {
    initInstance(); // 挂载
  }
  Object.assign(newInstance, options);
  // 实例化后newInstance就是一个对象了，所以data内的数据会
  // 挂载到this下，传入一个对象与之合并
  
  return newInstance.show(vm => {  // 显示弹窗
    newInstance = null;  // 将实例对象清空
  })
}
复制代码
```

这里其实可以使用`install`做成一个插件，还没介绍它就略过了。首先使用`extend`将组件对象转换为组件构造函数，执行`initInstance`方法后就会将真实`Dom`挂载到`body`的最后。为什么之前不使用`props`而是用的`data`，因为它们初始化后都会挂载到`this`下，不过`data`代码量少。导出一个方法给到外部使用，接受配置参数，调用后返回一个`Promise`对象。

#### 3. 挂载到全局

> 在`main.js`内将导出的方法挂载到`Vue`的原型上，让其成为一个全局方法：

```
import Confirm from './base/confirm/index';

Vue.prototype.$Confirm = Confirm;

试试这样调用吧~
this.$Confirm({
  title: 'vue大法好!'
}).then(confirm => {
  console.log(confirm)  
}).catch(cancel => {
  console.log(cancel)
})
复制代码
```

组件完整代码如下：

```
confirm/confirm.vue

<template>
  <transition name="confirm-fade">
    <div class="confirm" v-show="showFlag">
      <div class="confirm-wrapper">
        <div class="confirm-content">
          <p class="text">{{title}}</p>
          <div class="operate" @click.stop>
            <div class="operate-btn left" @click="cancel">{{cancelBtnText}}</div>
            <div class="operate-btn" @click="confirm">{{ConfirmBtnText}}</div>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  data() {
    return {
      showFlag: false,
      title: "确认清空所有历史纪录吗?", 
      ConfirmBtnText: "确定",
      cancelBtnText: "取消"
    };
  },
  methods: {
    show(cb) {
      this.showFlag = true;
      typeof cb === "function" && cb.call(this, this);
      return new Promise((resolve, reject) => {
        this.reject = reject;
        this.resolve = resolve;
      });
    },
    cancel() {
      this.reject("cancel");
      this.hide();
    },
    confirm() {
      this.resolve("confirm");
      this.hide();
    },
    hide() {
      this.showFlag = false;
      document.body.removeChild(this.$el);
      this.$destroy();
    }
  }
};
</script>

<style scoped lang="stylus">
.confirm {
  position: fixed;
  left: 0;
  right: 0;
  top: 0;
  bottom: 0;
  z-index: 998;
  background-color: rgba(0, 0, 0, 0.3);
  &.confirm-fade-enter-active {
    animation: confirm-fadein 0.3s;
    .confirm-content {
      animation: confirm-zoom 0.3s;
    }
  }
  .confirm-wrapper {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    z-index: 999;
    .confirm-content {
      width: 270px;
      border-radius: 13px;
      background: #333;
      .text {
        padding: 19px 15px;
        line-height: 22px;
        text-align: center;
        font-size: 18px;
        color: rgba(255, 255, 255, 0.5);
      }
      .operate {
        display: flex;
        align-items: center;
        text-align: center;
        font-size: 18px;
        .operate-btn {
          flex: 1;
          line-height: 22px;
          padding: 10px 0;
          border-top: 1px solid rgba(0, 0, 0, 0.3);
          color: rgba(255, 255, 255, 0.3);
          &.left {
            border-right: 1px solid rgba(0, 0, 0, 0.3);
          }
        }
      }
    }
  }
}
@keyframes confirm-fadein {
  0% {opacity: 0;}
  100% {opacity: 1;}
}
@keyframes confirm-zoom {
  0% {transform: scale(0);}
  50% {transform: scale(1.1);}
  100% {transform: scale(1);}
}
</style>
复制代码
```

> 试着实现一个全局的提醒组件吧，原理差不多的~

最后按照惯例我们还是以一道`vue`可能会被问到的面试题作为本章的结束~

> #### 面试官微笑而又不失礼貌的问道：

- 请说明下组件库中命令式弹窗组件的原理？

> #### 怼回去：

- 使用`extend`将组件转为构造函数，在实例化这个这个构造函数后，就会得到`$el`属性，也就是组件的真实`Dom`，这个时候我们就可以操作得到的真实的`Dom`去任意挂载，使用命令式也可以调用。