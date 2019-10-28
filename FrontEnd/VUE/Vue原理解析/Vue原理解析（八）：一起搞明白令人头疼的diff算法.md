# Vue原理解析（八）：一起搞明白令人头疼的diff算法

之前章节介绍了`VNode`如何生成真实`Dom`，这只是`patch`内首次渲染做的事，完成了一小部分功能而已，而它做的最重要的事情是当响应式触发时，让页面的重新渲染这一过程能高效完成。其实页面的重新渲染完全可以使用新生成的`Dom`去整个替换掉旧的`Dom`，然而这么做比较低效，所以就借助接下来将介绍的`diff`比较算法来完成。

> `diff`算法做的事情是比较`VNode`和`oldVNode`，再以`VNode`为标准的情况下在`oldVNode`上做小的改动，完成`VNode`对应的`Dom`渲染。

回到之前`_update`方法的实现，这个时候就会走到`else`的逻辑了：

```
Vue.prototype._update = function(vnode) {
  const vm = this
  const prevVnode = vm._vnode
  
  vm._vnode = vnode  // 缓存为之前vnode
  
  if(!prevVnode) {  // 首次渲染
    vm.$el = vm.__patch__(vm.$el, vnode)
  } else {  // 重新渲染
    vm.$el = vm.__patch__(prevVnode, vnode)
  }
}
复制代码
```

既然是在现有的`VNode`上修修补补来达到重新渲染的目的，所以无非是做三件事情：

> **创建新增节点**

> **删除废弃节点**

> **更新已有节点**

接下来我们将介绍以上三种情况分别什么情况下会遇到。

### 创建新增节点

新增节点两种情况下会遇到：

> #### `VNode`中有的节点而`oldVNode`没有

- `VNode`中有的节点而`oldVNode`中没有，最明显的场景就是首次渲染了，这个时候是没有`oldVNode`的，所以将整个`VNode`渲染为真实`Dom`插入到根节点之内即可，这一详细过程之前章节有详细说明。

> #### `VNode`和`oldVNode`完全不同

- 当`VNode`和`oldVNode`不是同一个节点时，直接会将`VNode`创建为真实`Dom`，插入到旧节点的后面，这个时候旧节点就变成了废弃节点，移除以完成替换过程。

判断两个节点是否为同一个节点，内部是这样定义的：

```
function sameVnode (a, b) {  // 是否是相同的VNode节点
  return (
    a.key === b.key && (  // 如平时v-for内写的key
      (
        a.tag === b.tag &&   // tag相同
        a.isComment === b.isComment &&  // 注释节点
        isDef(a.data) === isDef(b.data) &&  // 都有data属性
        sameInputType(a, b)  // 相同的input类型
      ) || (
        isTrue(a.isAsyncPlaceholder) &&  // 是异步占位符节点
        a.asyncFactory === b.asyncFactory &&  // 异步工厂方法
        isUndef(b.asyncFactory.error)
      )
    )
  )
}
复制代码
```

### 删除废弃节点

上面创建新增节点的第二种情况以略有提及，比较`vnode`和`oldVnode`，如果根节点不相同就将`Vnode`整颗渲染为真实`Dom`，插入到旧节点的后面，最后删除掉已经废弃的旧节点即可：



![img](Untitled%206.assets/16caf6f26aa2d5eb)

在`patch``Dom`



```
if (isDef(parentElm)) {  // 在它们的父节点内删除旧节点
  removeVnodes(parentElm, [oldVnode], 0, 0)
}

-------------------------------------------------------------

function removeVnodes (parentElm, vnodes, startIdx, endIdx) {
  for (; startIdx <= endIdx; ++startIdx) {
    const ch = vnodes[startIdx]
    if (isDef(ch)) {
      removeNode(ch.elm)
    }
  }
}  // 移除从startIdx到endIdx之间的内容

------------------------------------------------------------

function removeNode(el) {  // 单个节点移除
  const parent = nodeOps.parentNode(el)
  if(isDef(parent)) {
    nodeOps.removeChild(parent, el)
  }
}
复制代码
```

### 更新已有节点 (重点)

这个才是`diff`算法的重点，当两个节点是相同的节点时，这个时候就需要找出它们的不同之处，比较它们主要是使用`patchVnode`方法，这个方法里面主要也是处理几种分支情况：

> #### 都是静态节点

```
function patchVnode(oldVnode, vnode) {
  
  if (oldVnode === vnode) {  // 完全一样
    return
  }

  const elm = vnode.elm = oldVnode.elm
  if(isTrue(vnode.isStatic) && isTrue(oldVnode.isStatic)) {  
    vnode.componentInstance = oldVnode.componentInstance
    return  // 都是静态节点，跳过
  }
  ...
}
复制代码
```

什么是静态节点了？这是编译阶段做的事情，它会找出模板中的静态节点并做上标记(`isStatic`为`true`)，例如：

```
<template>
  <div>
    <h2>{{title}}</h2>
    <p>新鲜食材</p>
  </div>
</template>
复制代码
```

这里的`h2`标签就不是静态节点，因为是根据插值变化的，而`p`标签就是静态节点，因为不会改变。如果都是静态节点就跳过这次比较，这也是编译阶段为`diff`比对做的优化。

> #### `vnode`节点没有文本属性

```
function patchVnode(oldVnode, vnode) {

  const elm = vnode.elm = oldVnode.elm
  const oldCh = oldVnode.children
  const ch = vnode.children

  if (isUndef(vnode.text)) {  // vnode没有text属性
    
    if (isDef(oldCh) && isDef(ch)) {  // // 都有children
      if (oldCh !== ch) {  // 且children不同
        updateChildren(elm, oldCh, ch)  // 更新子节点
      }
    } 
    
    else if (isDef(ch)) {  // 只有vnode有children
      if (isDef(oldVnode.text)) {  // oldVnode有文本节点
        nodeOps.setTextContent(elm, '')  // 设置oldVnode文本为空
      }
      addVnodes(elm, null, ch, 0, ch.length - 1)
      // 往oldVnode空的标签内插入vnode的children的真实dom
    } 
    
    else if (isDef(oldCh)) {  // 只有oldVnode有children
      removeVnodes(elm, oldCh, 0, oldCh.length - 1)  // 全部移除
    } 
    
    else if (isDef(oldVnode.text)) {  // oldVnode有文本节点
      nodeOps.setTextContent(elm, '')  // 设置为空
    }
  } 
  
  else {  vnode有text属性
    ...
  }
  
  ...
  
复制代码
```

如果`vnode`没有文本节点，又会有接下来的四个分支：

**1. 都有`children`且不相同**

- 使用`updateChildren`方法更详细的比对它们的`children`，如果说更新已有节点是`patch`的核心，那这里的更新`children`就是核心中的核心，这个之后使用流程图的方式仔仔细细说明。

**2. 只有`vnode`有`children`**

- 那这里的`oldVnode`要么是一个空标签或者是文本节点，如果是文本节点就清空文本节点，然后将`vnode`的`children`创建为真实`Dom`后插入到空标签内。

**3. 只有`oldVnode`有`children`**

- 因为是以`vnode`为标准的，所以`vnode`没有的东西，`oldVnode`内就是废弃节点，需要删除掉。

**4. 只有`oldVnode`有文本**

- 只要是`oldVnode`有而`vnode`没有的，清空或移除即可。

> #### `vnode`节点有文本属性

```
function patchVnode(oldVnode, vnode, insertedVnodeQueue) {

  const elm = vnode.elm = oldVnode.elm
  const oldCh = oldVnode.children
  const ch = vnode.children

  if (isUndef(vnode.text)) {  // vnode没有text属性
    ...
  } else if(oldVnode.text !== vnode.text) {  // vnode有text属性且不同
    nodeOps.setTextContent(elm, vnode.text)  // 设置文本
  }
  
  ...
  
复制代码
```

还是那句话，以`vnode`为标准，所以`vnode`有文本节点的话，无论`oldVnode`是什么类型节点，直接设置为`vnode`内的文本即可。至此，整个`diff`比对的大致过程就算是说明完毕了，我们还是以一张流程图来理清思路：



![img](Untitled%206.assets/16cb48188c5ed824)



### 更新已有节点之更新子节点 (重点中的重点)

```
更新子节点示例：
<template>
  <ul>
    <li v-for='item in list' :key='item.id'>{{item.name}}</li>
  </ul>
</template>

export default {
  data() {
    return {
      list: [{
        id: 'a1',name: 'A'}, {
        id: 'b2',name: 'B'}, {
        id: 'c3',name: 'C'}, {
        id: 'd4',name: 'D'}
      ]
    }
  },
  mounted() {
    setTimeout(() => {
      this.list.sort(() => Math.random() - .5)
        .unshift({id: 'e5', name: 'E'})
    }, 1000)
  }
}
复制代码
```

上述代码中首先渲染一个列表，然后将其随机打乱顺序后并添加一项到列表最前面，这个时候就会触发该组件更新子节点的逻辑，之前也会有一些其他的逻辑，这里只用关注更新子节点相关，来看下它怎么更新`Dom`的：

```
function updateChildren(parentElm, oldCh, newCh) {
  let oldStartIdx = 0  // 旧第一个下标
  let oldStartVnode = oldCh[0]  // 旧第一个节点
  let oldEndIdx = oldCh.length - 1  // 旧最后下标
  let oldEndVnode = oldCh[oldEndIdx]  // 旧最后节点
  
  let newStartIdx = 0  // 新第一个下标
  let newStartVnode = newCh[0]  // 新第一个节点
  let newEndIdx = newCh.length - 1  // 新最后下标
  let newEndVnode = newCh[newEndIdx]  // 新最后节点
  
  let oldKeyToIdx  // 旧节点key和下标的对象集合
  let idxInOld  // 新节点key在旧节点key集合里的下标
  let vnodeToMove  // idxInOld对应的旧节点
  let refElm  // 参考节点
  
  checkDuplicateKeys(newCh) // 检测newVnode的key是否有重复
  
  while(oldStartIdx <= oldEndIdx && newStartIdx <= newEndIdx) {  // 开始遍历children
  
    if (isUndef(oldStartVnode)) {  // 跳过因位移留下的undefined
      oldStartVnode = oldCh[++oldStartIdx]
    } else if (isUndef(oldEndVnode)) {  // 跳过因位移留下的undefine
      oldEndVnode = oldCh[--oldEndIdx]  
    } 
    
    else if(sameVnode(oldStartVnode, newStartVnode)) {  // 比对新第一和旧第一节点
      patchVnode(oldStartVnode, newStartVnode)  // 递归调用                        
      oldStartVnode = oldCh[++oldStartIdx]  // 旧第一节点和下表重新标记后移        
      newStartVnode = newCh[++newStartIdx]  // 新第一节点和下表重新标记后移        
    }
    
    else if (sameVnode(oldEndVnode, newEndVnode)) {  // 比对旧最后和新最后节点     
      patchVnode(oldEndVnode, newEndVnode)  // 递归调用                            
      oldEndVnode = oldCh[--oldEndIdx]  // 旧最后节点和下表重新标记前移            
      newEndVnode = newCh[--newEndIdx]  // 新最后节点和下表重新标记前移            
    }
    
    else if (sameVnode(oldStartVnode, newEndVnode)) { // 比对旧第一和新最后节点
      patchVnode(oldStartVnode, newEndVnode)  // 递归调用
      nodeOps.insertBefore(parentElm, oldStartVnode.elm, nodeOps.nextSibling(oldEndVnode.elm))  
      // 将旧第一节点右移到最后，视图立刻呈现
      oldStartVnode = oldCh[++oldStartIdx]  // 旧开始节点被处理，旧开始节点为第二个
      newEndVnode = newCh[--newEndIdx]  // 新最后节点被处理，新最后节点为倒数第二个
    }
    
    else if (sameVnode(oldEndVnode, newStartVnode)) { // 比对旧最后和新第一节点
      patchVnode(oldEndVnode, newStartVnode, insertedVnodeQueue)  // 递归调用
      nodeOps.insertBefore(parentElm, oldEndVnode.elm, oldStartVnode.elm)
      // 将旧最后节点左移到最前面，视图立刻呈现
      oldEndVnode = oldCh[--oldEndIdx]  // 旧最后节点被处理，旧最后节点为倒数第二个
      newStartVnode = newCh[++newStartIdx]  // 新第一节点被处理，新第一节点为第二个
    }
    
    else {  // 不包括以上四种快捷比对方式
      if (isUndef(oldKeyToIdx)) {
        oldKeyToIdx = createKeyToOldIdx(oldCh, oldStartIdx, oldEndIdx) 
        // 获取旧开始到结束节点的key和下表集合
      }
      
      idxInOld = isDef(newStartVnode.key)  // 获取新节点key在旧节点key集合里的下标
          ? oldKeyToIdx[newStartVnode.key]
          : findIdxInOld(newStartVnode, oldCh, oldStartIdx, oldEndIdx)
      
      if (isUndef(idxInOld)) { // 找不到对应的下标，表示新节点是新增的，需要创建新dom
        createElm(
          newStartVnode, 
          insertedVnodeQueue, 
          parentElm, 
          oldStartVnode.elm, 
          false, 
          newCh, 
          newStartIdx
        )
      }
      
      else {  // 能找到对应的下标，表示是已有的节点，移动位置即可
        vnodeToMove = oldCh[idxInOld]  // 获取对应已有的旧节点
        patchVnode(vnodeToMove, newStartVnode, insertedVnodeQueue)
        oldCh[idxInOld] = undefined
        nodeOps.insertBefore(parentElm, vnodeToMove.elm, oldStartVnode.elm)
      }
      
      newStartVnode = newCh[++newStartIdx]  // 新开始下标和节点更新为第二个节点
      
    }
  }
  
  ...
  
}
复制代码
```

函数内首先会定义一堆`let`定义的变量，这些变量是随着`while`循环体而改变当前值的，循环的退出条件为只要新旧节点列表有一个处理完就退出，看着循环体代码挺复杂，其实它只是做了三件事，明白了哪三件事再看循环体，会发现其实并不复杂：

> #### 1. 跳过undefined

为什么会有`undefined`，之后的流程图会说明清楚。这里只要记住，如果旧开始节点为`undefined`，就后移一位；如果旧结束节点为`undefined`，就前移一位。

> #### 2. 快捷查找

首先会尝试四种快速查找的方式，如果不匹配，再做进一步处理：

- 2.1 新开始和旧开始节点比对

如果匹配，表示它们位置都是对的，`Dom`不用改，就将新旧节点开始的下标往后移一位即可。

- 2.2 旧结束和新结束节点比对

如果匹配，也表示它们位置是对的，`Dom`不用改，就将新旧节点结束的下标前移一位即可。

- 2.3 旧开始和新结束节点比对

如果匹配，位置不对需要更新`Dom`视图，将旧开始节点对应的真实`Dom`插入到最后一位，旧开始节点下标后移一位，新结束节点下标前移一位。

- 2.4 旧结束和新开始节点比对

如果匹配，位置不对需要更新`Dom`视图，将旧结束节点对应的真实`Dom`插入到旧开始节点对应真实`Dom`的前面，旧结束节点下标前移一位，新开始节点下标后移一位。

> #### 3. key值查找

- 3.1 如果和已有key值匹配

那就说明是已有的节点，只是位置不对，那就移动节点位置即可。

- 3.2 如果和已有key值不匹配

再已有的`key`值集合内找不到，那就说明是新的节点，那就创建一个对应的真实`Dom`节点，插入到旧开始节点对应的真实`Dom`前面即可。

这么说并不太好理解，结合之前的示例，根据以下的流程图将会明白很多：



![img](Untitled%206.assets/16cb4f706d65e80c)

↑ 示例的初始状态就是这样了，之前定义的下标以及对应的节点就是`start``end`





![img](Untitled%206.assets/16cb4f897d9a8ed9)

↑ 首先进行之前说明两两四次的快捷比对，找不到后通过旧节点的`key``E``Dom``start``Dom``A``start`





![img](Untitled%206.assets/16cb9a8c163e2821)

↑ 接着开始处理第二个，还是首先进行快捷查找，没有后进行`key``A``C``undefined``start`





![img](Untitled%206.assets/16cb9a9246bd8470)

↑ 再处理第三个节点，通过快捷查找找到了，是新开始节点对应旧开始节点，`Dom``start``start`





![img](Untitled%206.assets/16cb9a98bdac55bc)

↑ 接着处理的第四个节点，通过快捷查找，这个时候先满足了旧开始节点和新结束节点的匹配，`Dom``end``start`





![img](Untitled%206.assets/16cb9abd6092aec2)

↑ 处理最后一个节点，首先会执行跳过`undefined``start`



```
function updateChildren(parentElm, oldCh, newCh) {
  let oldStartIdx = 0
  ...
  
  while(oldStartIdx <= oldEndIdx && newStartIdx <= newEndIdx) {
    ...
  }
  
  if (oldStartIdx > oldEndIdx) {  // 如果旧节点列表先处理完，处理剩余新节点
    refElm = isUndef(newCh[newEndIdx + 1]) ? null : newCh[newEndIdx + 1].elm
    addVnodes(parentElm, refElm, newCh, newStartIdx, newEndIdx, insertedVnodeQueue)  // 添加
  } 
  
  else if (newStartIdx > newEndIdx) {  // 如果新节点列表先处理完，处理剩余旧节点
    removeVnodes(parentElm, oldCh, oldStartIdx, oldEndIdx)  // 删除废弃节点
  }
}
复制代码
```

我们之前的示例刚好是新旧节点列表同时处理完退出的循环，这里是退出循环后为还有没有处理完的节点，做不同的处理：



![img](Untitled%206.assets/16cb51516fb53987)

以新节点列表为标准，如果是新节点列表处理完，旧列表还有没被处理的废弃节点，删除即可；如果是旧节点先处理完，新列表里还有没被使用的节点，创建真实`Dom``diff`



最后按照惯例我们还是以一道`vue`可能会被问到的面试题作为本章的结束~

> #### 面试官微笑而又不失礼貌的问道：

- 为什么`v-for`里建议为每一项绑定`key`，而且最好具有唯一性，而不建议使用`index`？

> #### 怼回去：

- 在`diff`比对内部做更新子节点时，会根据`oldVnode`内没有处理的节点得到一个`key`值和下标对应的对象集合，为的就是当处理`vnode`每一个节点时，能快速查找该节点是否是已有的节点，从而提高整个`diff`比对的性能。如果是一个动态列表，`key`值最好能保持唯一性，但像轮播图那种不会变更的列表，使用`index`也是没问题的。