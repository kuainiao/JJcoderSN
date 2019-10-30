# vue.js快速上手开发知识梳理（基础篇）

### 前言

> 文章涉及的内容可能不全面，但量很多，需要慢慢看。我花了很长的时间整理，用心分享心得，希望对大家有所帮助。但是难免会有打字的错误或理解的错误点，希望发现的可以邮箱告诉我1163675970@qq.com，我会及时的进行修改，只希望对你有所帮助，谢谢。

### 类库 vs 插件 vs 组件 vs 框架

> 再此之前先扫盲一下 区分框架和类库等

1. 类库

> jQuery、Zepto、underscore... 类库提供的是真实项目中常用到的方法，它是一个工具包，基于这个工具包可以快速开发任何的项目

1. 插件

> TAB选项卡插件、BANNER轮播图插件、DIALOG模态框插件、DRAG拖拽插件... iscroll局部滚动插件、jquery中有很多的插件 插件是把项目中某一个具体的功能进行封装

1. UI组件

> bootstrap、swiper、mui、妹子UI... UI组件库一般是多个插件的集合体，不仅提供了JS对应的功能，而且把结构、样式等也都实现了，我们只需要做一名CV工程师就可以快速构建一个产品

1. 框架

> vue、react、uni-app、react native、flutter、angular（ng）、backbone... 一般来说，框架是类库和组件的综合体，里面提供了大量供我们操作的方法，也有配套的UI组件库供我们快速开发；框架是具备独立编程思想的，例如：vue是MVVM思想，让我们告别传统的DOM操作，按照视图和数据的相互渲染来完成项目开发，但是不管怎么变，都一定会比我们之前基于原生操作更简单，性能更好...

**市面上常用的框架：vue（MVVM） / react（MVC）**

**APP框架：uni-app / react native / flutter**

------

### 初识VUE

Vue.js（读音 /vjuː/, 类似于 view） 是一套构建用户界面的渐进式框架。

Vue 只关注视图层， 采用自底向上增量开发的设计。

Vue 的目标是通过尽可能简单的 API 实现响应的数据绑定和组合的视图组件。

vue 我们现在学习和使用的是第二代版本

#### 参考资料:

官方文档：[vuejs.org/v2/guide/sy…](http://vuejs.org/v2/guide/syntax.html)

中文文档: [cn.vuejs.org/v2/guide/sy…](https://cn.vuejs.org/v2/guide/syntax.html) ---> 强烈推荐

基于 $npm i vue 安装

### 渐进式框架

> 渐进式：类库或者框架都是重量级的，里面包含很多方法，但是实际项目开发中，我们用不到这么多东西，所以在开啊他们的时候，会把功能按照模块进行单独开发，使用者可根据自身情况选择一个模块一个模块的导入使用

- vue：基础模块（基础语法、核心实现、组件开发、相关指令等都在这里）
- vue-router：构建SPA单页面应用的路由
- vuex：公共状态管理
- vue-cli：vue脚手架
- components：vue element、iview、vux...
- ... 这些东西就是VUE全家桶

### 声明式和命令式

- 命令式编程：命令“机器”如何去做事情(how)，这样不管你想要的是什么(what)，它都会按照你的命令实现，例如for循环
- 声明式编程：告诉“机器”你想要的是什么(what)，让机器想出如何去做(how)，例如数组内置方法forEach等



![img](vue%E5%9F%BA%E7%A1%80%E8%AF%AD%E6%B3%95.assets/16db0c4a56fb1b43)



### MVC & MVVM

- 传统操作DOM模式
- MVC：model view controller
- MVVM：model view viewModel



![img](vue%E5%9F%BA%E7%A1%80%E8%AF%AD%E6%B3%95.assets/16db0c654b952f75)



### VUE 是 MVVM框架



![img](vue%E5%9F%BA%E7%A1%80%E8%AF%AD%E6%B3%95.assets/16dabbf99e7df00d)



> MVVM是双向数据绑定的：VUE本身实现了数据和视图的相互监听影响
>
> MVC是单向数据绑定，数据更改可以渲染视图，但是视图更改没有更改数据，需要我们自己在控制层基于change事件实现数据的更改（REACT）

- m：mode数据层
- v：view视图层
- vm：viewModel 数据和视图的监听层（当数据或者视图发生改变，VM层会监听到，同时把对应的另外一层特跟着改变或者重新渲染）
    - 数据层改变：vm会帮我们重新渲染视图
    - 视图层改变：vm也会帮我们把数据重新更改

#### VUE的双向数据绑定的原理



![img](vue%E5%9F%BA%E7%A1%80%E8%AF%AD%E6%B3%95.assets/16db0c1482d9e3de)



> 当初始化Vue的实例时,会遍历data中的所有的属性，给每一个属性新增get和set方法，
>
> 当获取这个属性对应的属性值，会默认执行get方法，设置属性的属性值时，会执行set方法；
>
> vue的指令编译器，对v的指令进行解析，并初始化视图，并订阅观察者来更新视图；
>
> 并将watcher添加到Dep订阅器中，当数据发生改变，observer的set方法会被调用，
>
> 会遍历Dep订阅器中所有的订阅者，然后再更新视图；

### vue的使用

```
<!-- IMPORT JS -->
	<!--<script src="./node_modules/vue/dist/vue.min.js"></script>-->

     <!-- 开发的时候尽可能引用未压缩版本，这样有错误会抛出异常 -->
          
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		//=>每当创建一个实例，就相当于创建一个viewModel监听器：可以监听对应视图和对应数据的相互改变
		let vm1 = new Vue({
			//=>el:element 当前监听器监听的视图（基于querySelector获取）
			el: '#app',
			//=>data: 当前监听器监听的数据（这些监听的数据会挂载到vm1实例上，也就是vm1.msg=xxx来操作了）
			data: {
				msg: 'hello world~~'
			}
             
		});
               
               
});
</script>
复制代码
```

### vue 基础

> mustache（[ˈmʌstæʃ]） {{xxx}} 小胡子语法

```
<!-- IMPORT CSS -->
<body>
	<div id='app'>
		{{msg}} 
          //=>  数据绑定最常见的形式就是使用 {{...}}（双大括号 小胡子语法）的文本插值 
	</div>
	<div id="box">
		<span>{{n}}</span>
		<br>
          //=> 事件监听可以使用 v-on 指令：
               //=>v-on 可以接收一个定义的方法来调用 
		<button v-on:click="handle">点我啊~~</button>
	</div>

	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		let vm1 = new Vue({
			el: '#app',
			data: {
				msg: 'hello world~~'
			}
		});
        //需求：把MSG数据绑定在页面#APP中，一秒后，让数据更改，同时期望视图也跟着更改
		setTimeout(() => {
			vm1.msg = '你好世界~~';
		}, 1000);
	</script>
	<script>
		let vm2 = new Vue({
			el: '#box',
			data: {
				n: 0
			},
			//=>放视图中需要使用的方法 
			methods: {
				handle() {
					//this:vm2
					this.n++;
				}
			}
		});

	</script>
</body>

复制代码
<body>
	<div id="app">
		人民币：￥ <input type="text" v-model="priceRMB">
		<br>
		美元：$ <span>{{priceRMB/7.1477}}</span>
	</div>

	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
          //=>v-model 实现双向数据绑定：
		//=>v-model先实现把数据绑定到视图层（给INPUT设置VALUE值），然后监听文本框内容的改变，一旦改变，会把数据也跟着改变；数据一变，视图会重新的渲染；
		let vm = new Vue({
			el: '#app',
			data: {
				priceRMB: 0
			}
		});
	</script>
</body>
复制代码
```

### VUE基础语法

```
<body>
	<div id="app">
		{{obj}}
		<br>
		{{arr}}
		<br>
		{{'name' in obj?'OK':'no'}}
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		let obj = {
			// name: ''
		};
		let arr = [10];
		let vm = new Vue({
			//=>基于querySelector获取视图容器：指定的容器不能是HTML和BODY
			el: '#app',
			data: {
				/*
				 * 在胡子语法中绑定的数据值是对象类型，会基于JSON.stringify把其编译为字符串再呈现出来（而不是直接toString处理的）
				 * 
				 * 并不是所有的数据更改最后都会通知视图重新渲染 
				 *   1.初始数据是一个对象，对象中没有xxx键值对，后期新增的键值对是不会让视图重新渲染的，解决办法：
				 *     + 最好在初始化数据的时候，就把视图需要的数据提前声明好（可以是空值，但是要有这个属性） =>原理：只有DATA中初始化过的属性才有GET/SET
				 *     + 不要修改某个属性名，而是把对象的值整体替换（指向新的堆内存）
				 *     + 可以基于vm.$set内置方法修改数据：vm.$set(obj,key,value)
				 * 
				 *   2.如果数据是一个数组，我们修改数据基于ARR[N]=xxx或者ARR.length--等操作方式，是无法让视图重新渲染的；需要基于：
				 *     + push/pop等内置的方法
				 *     + 重新把ARR的值重写（指向新的堆内存）
				 *     + vm.$set
				 */
				obj,
				arr
			}
		});
		setTimeout(() => {
			// vm.arr[1] = 20;
			// vm.arr.length--;
			// vm.arr.push(20);
			vm.$set(vm.arr, 1, 20);


			// vm.obj.name = "珠峰培训";
			// vm.obj = {
			// 	...obj,
			// 	name: '珠峰培训'
			// };
			// vm.$set(vm.obj, 'name', '珠峰培训');
		}, 1000);
	</script>
</body>
复制代码
```

### VUE 指令

```
<body>
	<!-- 
		VUE指令：directive
			1.都是按照v-xxx处理的，它是vue中规定给元素设置的自定义属性
			2.当vue加载成功并进行处理的时候，会按照相关的规则解析和宣传视图，遇到对应的指令实现对应的功能
		v-model一般给表单元素设置的，实现表单元素和数据之间的相互绑定
			1）先把数据绑定给表单元素 ，一般把数据赋值给表单元素的value、
			2）监听表单元素的内容改变
			3）内容改变后，会把对应的数据也改变
			4）对应的数据改变，视图中所有用到数据的地方都会重新渲染
			视图 <=> 数据
			在vue框架中给表单元素设置value等属性是没有意义的

		v-html/v-text：给非表单元素设置内容，v-html支持对于标签的自动识别，v-text会把所有内容分都当做文本
			传统的胡子语法，在vue没有加载完成之前，会把{{xxx}}展示在页面中，当vue加载完才会出现真正的内容，这样体验不好

		v-bind：给元素的内置属性动态绑定数据，例如：给img绑定动态的图片路径地址
			可以简写成为 :，也就是 v-bind:src 等价于 :src
		
		v-once：绑定的数据是一次性的，后面不论数据怎么改变，视图也都不会重新渲染

		v-if：如果对应的值是TRUE，当前元素会在结构中显示，如果是FALSE，当前元素会在结构中移除（它控制的是组件的加载和卸载的操作 =>DOM的增加和删除）；还有对应的 v-else-if / v-else 等指令；
		v-show：和v-if类似，只不过它是控制元素样式的显示隐藏（display的操作）
			1）v-if是控制组件存不存在，对于结果是FALSE，不存在的组件来说，视图渲染的时候无需渲染这部分内容；而v-show则不行，因为不管是显示还是隐藏，结构都在，所以视图渲染的时候这部分也要渲染；
			2）在过于频繁的切换操作中，v-if明显要比v-show要低一些
	 -->
	<div id="app">
		<button v-html='msg' @click='handle'></button>
		<br>
		<img :src="pic" alt="" v-if='show'>
		<!-- <span v-html='msg'></span>
		<span v-once v-html='msg'></span> -->
		<!-- <input type="text" v-model="msg">
		<span v-html='msg'></span>
		<img :src="pic" alt="">
		<img v-bind:src="pic" alt="">
		<span>{{msg}}</span> -->
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		let vm = new Vue({
			el: '#app',
			data: {
				//=>这里的数据最后都会作为实例的属性挂载到实例上vm.show...
				msg: '隐藏图片',
				show: true,
				pic: '1.png'
			},
			methods: {
				//=>这里的方法最后也会挂载到实例的私有属性上
				handle() {
					//=>this:vm
					this.show = !this.show;
					this.msg = this.show ? '隐藏图片' : '显示图片';
				}
			}
		});
		/* setTimeout(() => {
			vm.msg = '哈哈哈哈';
		}, 1000); */
	</script>
</body>
复制代码
```

> v-for：循环动态绑定数据

```
<body>
	<!-- 
		v-for：循环动态绑定数据
			想循环谁就给谁设置v-for
			循环类似for/for in的语法：v-for='(item,index) in arr'
	 -->
	<div id="app">
		<table>
			<thead>
				<tr>
					<th>编号</th>
					<th>姓名</th>
					<th>年龄</th>
				</tr>
			</thead>
			<tbody>
				<tr v-for='(item,index) in arr'>
					<td v-html='item.id'></td>
					<td v-html='item.name'></td>
					<td v-html='item.age'></td>
				</tr>
			</tbody>
		</table>
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		let vm = new Vue({
			el: '#app',
			data: {
				arr: [{
					id: 1,
					name: '张三',
					age: 25
				}, {
					id: 2,
					name: '李四',
					age: 24
				}, {
					id: 3,
					name: '王五',
					age: 26
				}]
			}
		});
	</script>

	<script>
		//JS中循环的几种方式：for循环、while循环、do while循环 | for in循环 | for of循环
		let arr = [10, 20, 30, 40],
			obj = {
				name: '珠峰培训',
				year: 10,
				1: 100
			};
		Object.prototype.AA = 12;

		//=>ES6新增for of循环
		//1.获取的不是属性名是属性值
		//2.不会遍历原型上公有的属性方法（哪怕是自定义的）
		//3.只能遍历可被迭代的数据类型值（Symbol.iteratoer）：Array、String、Arguments、NodeList、Set、Map等，但是普通对象是不可被迭代的数据，所以不能用for of循环
		/* for (let item of obj) {
			console.log(item);
		} */

		/* for (let key in arr) {
			if (!arr.hasOwnProperty(key)) break;
			console.log(key, arr[key]);
		} */

		/* for (let key in obj) {
			//=>KEY遍历的属性名
			//=>OBJ[KEY]属性值
			//=>优先遍历属性名为数字的
			//=>会把所属类原型上自定义的属性方法也遍历到
			if (!obj.hasOwnProperty(key)) break;
			console.log(key);
		} */
	</script>
</body>

复制代码
```

> v-on : 用来实现事件绑定的指令 及 事件修饰符

```
<body>
	<!-- 
		v-on（简写 @）：用来实现事件绑定的指令
			v-on:click='xxx'
			@click='xxx'

		1.事件触发的时候，需要传递参数信息，把方法加小括号，$event是事件对象
			v-on:click='sum($event,10,20)'
		
		2.事件修饰符
		  常规修饰符：@click.prevent/stop = 'xxx'
		  按键修饰符：@keydown.enter/space/delete/up/right/down/left...='xxx'
		  键盘码：@keydown.13 = 'xxx'
		  组合按键：@keydown.alt.67 = 'xxx'  //=>ALT+C
	 -->
	<div id="app">
		<!-- <a href="http://www.zhufengpeixun.cn/" @click.prevent.stop='func'>
			珠峰培训
		</a> -->
		<!-- <button v-on:click='func'></button> -->
		<!-- <button v-on:click='sum($event,10,20)'></button> -->

		<input type="text" placeholder="请输入搜索内容" v-model='text' @keydown.alt.67='func'>
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		let vm = new Vue({
			el: '#app',
			data: {
				text: ''
			},
			methods: {
				func(ev) {
					alert('珠峰培训');
					/* if (ev.keyCode === 13) {
						alert('珠峰培训');
					} */
				},
				sum(ev, n, m) {
					console.log(arguments);
				}
			}
		});
	</script>
</body>
```

### VUE 表单元素的处理 -- 单选或者复选按钮

```
<body>
	<!-- 
		单选或者复选按钮
			1.按照 v-model 进行分组，单选框装备的数据是一个值，复选框准备的数据是一个数组
			2.每一个框都有自己的value，谁被选中，数据值就是被选中元素的value值；相反，值是多少，对应value的元素也会被默认选中；
	 -->
	<div id="app">
		<!-- 性别：<br>
		<input type="radio" value='0' v-model.number='sex'>男
		<input type="radio" value='1' v-model.number='sex'>女
		<br>
		<button @click='submit'>提交</button> -->

		<!-- <input type="checkbox" value="OK" v-model='all' @click='handle'>全选/全不选
		<br>
		<div @change='delegate'>
			<input type="checkbox" value="song" v-model='hobby'>唱歌
			<input type="checkbox" value="dance" v-model='hobby'>跳舞
			<input type="checkbox" value="read" v-model='hobby'>读书
			<input type="checkbox" value="javascript" v-model='hobby'>编程
		</div>
		<br>
		<button @click='submit'>提交</button> -->
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		let vm = new Vue({
			el: '#app',
			data: {
				sex: 0,
				hobby: ['javascript'],
				all: []
			},
			methods: {
				submit() {
					console.log(this.sex);
				},
				handle() {
					//=>CLICK事件处理比视图更新后数据的更改要先去做
					if (!this.all.includes('OK')) {
						this.hobby = ['song', 'dance', 'read', 'javascript'];
					} else {
						this.hobby = [];
					}
				},
				delegate() {
					//=>CHANGE事件处理，要晚于数据更新
					this.all = this.hobby.length >= 4 ? ['OK'] : [];
				}
			}
		});
	</script>
</body>
复制代码
```

### VUE - filters-过滤器

> 过滤器的语法：
>
> 按照竖线分隔，把竖线左侧的值传递给右侧的过滤器方法，经过方法的处理，把处理后的结果展示在视图中

> 过滤器方法只能在胡子语法{{}}和v-bind中使用（过滤器中的方法没有挂载到实例上）

```
<body>
	<div id="app">
		<input type="text" v-model='text'>
		<br>
		<!-- <span v-text='text.replace(/\b[a-zA-Z]+\b/g,item=>{
			return item.charAt(0).toUpperCase()+item.substring(1);
		})'></span> -->
		<!-- <span v-text='toUP(text)'></span> -->
		<!-- 
			过滤器的语法：按照竖线分隔，把竖线左侧的值传递给右侧的过滤器方法，经过方法的处理，把处理后的结果展示在视图中
			过滤器方法只能在胡子语法{{}}和v-bind中使用（过滤器中的方法没有挂载到实例上）
		 -->
		<!-- <span>{{text|toUP|filterB}}</span> -->
		<!-- <img :src="pic|picHandle" alt=""> -->
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		let vm = new Vue({
			el: '#app',
			data: {
				//=>响应式数据:DATA中准备的要在视图中渲染的数据（MODEL）
				text: ''
			},
			methods: {
				//=>都会挂载到实例上（不能和DATA中的属性名冲突）：这里的制定的方法是普通方法，可以在视图中调取使用，也可以在其它方法中调取使用
				toUP(value) {
					return value.replace(/\b[a-zA-Z]+\b/g, item => {
						return item.charAt(0).toUpperCase() + item.substring(1);
					});
				}
			},
			filters: {
				//=>设置过滤器：把需要在视图中渲染的数据进行二次或者多次的处理
				toUP(value) {
					//=>value:需要过滤的数据 return返回的是过滤后的结果
					return value.replace(/\b[a-zA-Z]+\b/g, item => {
						return item.charAt(0).toUpperCase() + item.substring(1);
					});
				},
				filterB(value) {
					return value.split('').reverse().join('');
				},
				picHandle(value){
					return value.length===0?'http://www.zhufengpeixun.cn/static/1.png':value;
				}
			}
		});
	</script>
</body>
复制代码
```

### VUE-computed-计算属性

> 计算属性：
>
> 它不是方法是一个属性，所以在视图中调取的时候不能加括号执行，toUP和DATA中的TEXT一样，
>
> 都会挂载到实例上，它存储的值是对应方法返回的结果（getter函数处理的结果）
>
> 计算属性有自己的缓存处理：
>
> 第一次获取toUP属性值，会关联某个响应式数据(text)，当第一次结果获取后，会把这个结果缓存下来；
>
> 后期视图重新渲染，首先看text值是否发生更改，如果发生更改，会重新计算toUP属性值，如果没有更改，则还会拿上次缓存的结果进行渲染;

```
<body>
	<div id="app">
		<input type="text" v-model='text'>
		<br>
		<span v-text='toUP'></span>
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		let vm = new Vue({
			el: '#app',
			data: {
				text: ''
			},
			computed: {
				//=>计算属性：它不是方法是一个属性，所以在视图中调取的时候不能加括号执行，toUP和DATA中的TEXT一样，都会挂载到实例上，它存储的值是对应方法返回的结果（getter函数处理的结果）
				//=>计算属性有自己的缓存处理：第一次获取toUP属性值，会关联某个响应式数据(text)，当第一次结果获取后，会把这个结果缓存下来；后期视图重新渲染，首先看text值是否发生更改，如果发生更改，会重新计算toUP属性值，如果没有更改，则还会拿上次缓存的结果进行渲染;
				toUP() {
					return this.text.replace(/\b[a-zA-Z]+\b/g, item => {
						return item.charAt(0).toUpperCase() + item.substring(1);
					});
				}
			},
			methods: {
				/* toUP(value) {
					return value.replace(/\b[a-zA-Z]+\b/g, item => {
						return item.charAt(0).toUpperCase() + item.substring(1);
					});
				} */
			}
		});
	</script>
</body>
```

> 真实项目中：
>
> 我们一般用一个计算属性和某些响应式数据进行关联，响应式数据发生改变，计算属性的GETTER函数会重新执行，否则使用的是上一次计算出来的缓存结果

> 计算属性中必须要关联一个响应式数据，否则GETTER函数只执行一次

```
<body>
	<div id="app">
		<p>正常结果：{{text}}</p>
		<p>反转结果：{{reverseMethod()}}</p>
		<p>反转结果：{{reverseComputed}}</p>
		<p>{{now2()}}</p>
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		//=>真实项目中：我们一般用一个计算属性和某些响应式数据进行关联，响应式数据发生改变，计算属性的GETTER函数会重新执行，否则使用的是上一次计算出来的缓存结果
		let vm = new Vue({
			el: '#app',
			data: {
				text: 'MY NAME IS ZHUFENG PEIXUN'
			},
			computed: {
				//=>GETTER函数
				reverseComputed() {
					// console.log('computed');
					return this.text.split('').reverse().join('');
				},
				now1() {
					//=>计算属性中必须要关联一个响应式数据，否则GETTER函数只执行一次
					return new Date();
				}
			},
			methods: {
				reverseMethod() {
					// console.log('methods');
					return this.text.split('').reverse().join('');
				},
				now2() {
					return new Date();
				}
			}
		});

		let n = 0;
		let timer = setInterval(() => {
			n++;
			if (n > 5) {
				clearInterval(timer);
				return;
			}
			if (n === 3) {
				vm.text = 'WELCOME TO ZHUFENG';
				return;
			}
			//=>强制更新视图的重新渲染
			vm.$forceUpdate();
		}, 1000);
	</script>
</body>
复制代码
```

> GETTER：只要获取这个属性值就会触发GET函数执行
>
> SETTER：给属性设置值的时候会触发SET函数，VALUE是给这个属性设置的值

```
<body>
	<div id="app">
		<p>正常结果：{{text}}</p>
		<p>反转结果：{{reverseComputed}}</p>
		<input type="text" v-model='reverseComputed'>
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		let vm = new Vue({
			el: '#app',
			data: {
				text: 'MY NAME IS ZHUFENG PEIXUN'
			},
			computed: {
				//=>GETTER函数
				/* reverseComputed() {
					return this.text.split('').reverse().join('');
				} */
				reverseComputed: {
					get() {
						//=>GETTER：只要获取这个属性值就会触发GET函数执行
						return this.text.split('').reverse().join('');
					},
					set(value) {
						//=>SETTER：给属性设置值的时候会触发SET函数，VALUE是给这个属性设置的值
						console.log('OK', value);
					}
				}
			}
		});

		let n = 0;
		let timer = setInterval(() => {
			n++;
			if (n > 5) {
				clearInterval(timer);
				return;
			}
			if (n === 3) {
				vm.text = 'WELCOME TO ZHUFENG';
				return;
			}
			//=>强制更新视图的重新渲染
			vm.$forceUpdate();
		}, 1000);
	</script>
</body>

复制代码
```

> 基于计算属性监听 全选/非全选

```
<body>
	<div id="app">
		<input type="checkbox" v-model='slected'>全选/非全选
		<br>
		<span v-for='item in hobbyList'>
			<input type="checkbox" :id="item.id|handleID" :value="item.value" v-model='checkList'>
			<label :for="item.id|handleID" v-text='item.name'></label>
		</span>
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		let vm = new Vue({
			el: '#app',
			data: {
				hobbyList: [{
					id: 1,
					name: '唱歌',
					value: 'song'
				}, {
					id: 2,
					name: '跳舞',
					value: 'dance'
				}, {
					id: 3,
					name: '阅读',
					value: 'read'
				}, {
					id: 4,
					name: '睡觉',
					value: 'sleep'
				}],
				//存储选中的兴趣爱好
				checkList: [],
			},
			computed: {
				//存储全选按钮的选中状态
				slected: {
					get() {
						return this.checkList.length === this.hobbyList.length;
					},
					set(value) {
						//=>点击全选框会修改slected的值
						//=>VALUE存储的是选中的状态
						if (value) {
							this.hobbyList.forEach(item => {
								this.checkList.push(item.value);
							});
							return;
						}
						this.checkList = [];
					}
				}
			},
			filters: {
				handleID(value) {
					return 'hobby' + value;
				}
			}
		});
	</script>
</body>
复制代码
```

### VUE -WACTH

> watch监听响应式数据的改变
>
> （watch中监听的响应式数据必须在data中初始化） 和 computed中的setter类似，
>
> 只不过computed是自己单独设置的计算属性（不能和DATA中的冲突），
>
> 而watch只能监听DATA中有的属性

> 监听器支持异步操作 computed的getter不支持异步获取数据

```
<body>
	<div id="app">
		<input type="checkbox" v-model='slected' @change='handle'>全选/非全选
		<br>
		<span v-for='item in hobbyList'>
			<input type="checkbox" :id="item.id|handleID" :value="item.value" v-model='checkList'>
			<label :for="item.id|handleID" v-text='item.name'></label>
		</span>
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		let vm = new Vue({
			el: '#app',
			data: {
				hobbyList: [{
					id: 1,
					name: '唱歌',
					value: 'song'
				}, {
					id: 2,
					name: '跳舞',
					value: 'dance'
				}, {
					id: 3,
					name: '阅读',
					value: 'read'
				}, {
					id: 4,
					name: '睡觉',
					value: 'sleep'
				}],
				//存储选中的兴趣爱好
				checkList: [],
				//存储全选状态
				slected: false
			},
			//=>watch监听响应式数据的改变（watch中监听的响应式数据必须在data中初始化） 和 computed中的setter类似，只不过computed是自己单独设置的计算属性（不能和DATA中的冲突），而watch只能监听DATA中有的属性
			//=>监听器支持异步操作  computed的getter不支持异步获取数据
			watch: {
				checkList() {
					this.slected = this.checkList.length === this.hobbyList.length ? true : false;
				}
			},
			methods: {
				handle() {
					if (this.slected) {
						this.hobbyList.forEach(item => {
							this.checkList.push(item.value);
						});
						return;
					}
					this.checkList = [];
				}
			},
			filters: {
				handleID(value) {
					return 'hobby' + value;
				}
			}
		});
	</script>
</body>
复制代码
```

### VUE-CLASS

```
<body>
	<div id="app">
		<!-- 
			对象方式处理动态的样式
				:class="{样式类名:响应式数据,...}"
				响应式数据为TRUE则有这个样式类，反之则没有
		 -->
		<!-- <p :class="{active:a,big:true}">欢迎来到珠峰培训，我是你们的老师~~</p>
		<button @click='handle'>切换样式</button> -->
		<!-- <button @click='a=!a'>切换样式</button> -->

		<!-- 
			数组控制样式类
				:class="[响应式数据1,....]"
				控制响应式数据的值是对应的样式类或者没有值，来控制是否有这个样式
		 -->
		<p :class="[active,big]">欢迎来到珠峰培训，我是你们的老师~~</p>
		<button @click='handle'>切换样式</button>
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		let vm = new Vue({
			el: '#app',
			data: {
				// a: false
				active: '',
				big: 'big'
			},
			methods: {
				handle() {
					this.active = this.active === '' ? 'active' : '';
					// this.a = !this.a;
				}
			}
		});
	</script>
</body>
复制代码
```

### VUE - 生命周期函数



![img](data:image/svg+xml;utf8,<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="623" height="1280"></svg>)



- beforeCreate 在实例初始化之后，数据观测 (data observer) 和 watch 配置之前被调用。
- created 在实例创建完成后被立即调用。在这一步，实例已完成数据观测、属性和方法的运算、watch/event 事件回调；但是在现阶段还没有开始挂载，即还没挂载到根 DOM 元素上，所以 this.$el 属性不可见
- beforeMount 在挂载开始之前被调用，创建虚拟 DOM（Virtual-DOM）；虚拟 DOM 不是真实的 DOM 元素，而是 js 对象，其中包含了渲染成 DOM 元素信息；
- mounted 把 Vue 的虚拟 DOM 挂载到真实的 DOM 上；如果要在 Vue 中获取 DOM 元素对象，一般在这个钩子中获取；项目中的 ajax 请求一般会在这里或者 created 里发送；
- beforeUpdate 只有当数据发生变化时，才会触发这个函数；
- updated 由于数据更改导致的虚拟 DOM 重新渲染和打补丁，在这之后会调用 updated。
- beforeDestroy 在 Vue 的实例被销毁之前调用，如果页面中有定时器，我们会在这个钩子中清除定时器；
- destroyed Vue 实例销毁后调用，实例中的属性也不再是响应式的，watch 被移除

```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Title</title>
</head>
<body>
<div id="app">
  <div @click="fn">{{msg}}</div>
</div>

<script src="vue.js"></script>
<script>
  // 生命周期：
  // Vue 的实例具有生命周期，Vue 的实例在生成的时候，会经历一系列的初始化的过程；数据的监听，编译模板，实例挂载DOM元素，或者数据更新导致 DOM 更新，在执行的过程中，会运行一些叫做生命周期的钩子函数，在 Vue 实例生命周期中特定的时间点执行的函数称为生命周期的钩子函数；

  // 如果我们需要在某个生命周期处理一些事情，我们可以把这些事情写在钩子函数中；等到 Vue 的实例生命周期到这个阶段就会执行这个钩子，而我们要做的事情也就得以处理了
  // 生命周期的钩子函数不能人为的控制其执行的顺序；

  let vm = new Vue({
    data: {
      msg: 'hello'
    },
    methods: {
      fn() {console.log(11111)}
    },
    beforeCreate() {
      // 在实例初始化之后，数据观测 (data observer) 和 watch 配置之前被调用。
      console.log(1);
      console.log(this.msg);
      console.log(this.$el); // this.$el 是根 DOM 元素
    },
    created() {
      // 在实例创建完成后被立即调用。在这一步，实例已完成数据观测、属性和方法的运算、watch/event 事件回调
      // 但是在现阶段还没有开始挂载，即还没挂载到根 DOM 元素上，所以 this.$el 属性不可见
      console.log(2);
      console.log(this.msg);
      console.log(this.$el);
    },
    beforeMount() {
      // 在挂载开始之前被调用，创建虚拟DOM（Virtual-DOM）；虚拟 DOM 不是真实的 DOM 元素，而是 js 对象，其中包含了渲染成 DOM 元素信息；
      console.log(3);
      console.log(this.msg);
      console.log(this.$el);
    },
    mounted() {
      // 把 Vue 的虚拟DOM挂载到真实的 DOM 上；
      // 如果要在 Vue 中获取 DOM 元素对象，一般在这个钩子中获取
      // 项目中的 ajax 请求一般会在这里或者 created 里发送；
      console.log(4);
      console.log(this.msg);
      console.log(this.$el);
    },
    // 只有当数据发生变化时，才会触发这个函数；
    beforeUpdate() {
      console.log(5)
    },
    updated() {
      // 由于数据更改导致的虚拟 DOM 重新渲染和打补丁，在这之后会调用该钩子。
      console.log(6);
    },
    beforeDestroy() {
      // 在 Vue 的实例被销毁之前调用，如果页面中有定时器，我们会在这个钩子中清除定时器；
      console.log(7);
    },
    destroyed() {
      // Vue 实例销毁后调用，实例中的属性也不再是响应式的，watch 被移除
      console.log(8);
    }
  });

  vm.$set(vm, 'msg', 'hello world'); // 因为 Vue 的数据都是响应式的，只有修改数据才会触发 beforeUpdate 和 updated 钩子


  vm.$mount('#app'); // 当创建实例时不传递 el 属性，可以手动挂载到 DOM 节点；

  vm.$destroy(); // 手动销毁实例；

</script>
</body>
</html>
复制代码
<body>
	<div id="app">
		<span v-html='msg' class="AAA" @click='msg=10'></span>
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		/*
		 * 生命周期函数（钩子函数）
		 * 	 beforeCreate  创建vue实例之前
		 *   created 创建实例成功（一般在这里实现数据的异步请求）
		 *   beforeMount 渲染DOM之前（加载组件第一次渲染）
		 *   mounted 渲染DOM完成（加载组件第一次渲染）
		 *   beforeUpdate 重新渲染之前（数据更新等操作控制DOM重新渲染）
		 *   updated 重现渲染完成
		 *   beforeDestroy 销毁之前
		 *   destroyed 销毁完成
		 */
		let vm = new Vue({
			el: '#app',
			/* beforeMount() {
				console.log(document.getElementById('app'));
			},
			mounted() {
				console.log(document.getElementById('app'));
			}, */
			data: {
				msg: '你好世界'
			}
		});
		// vm.$mount('#app');  //=>el:'#app' 
		//=>指定当前vm所关联的视图

		// vm.$destroy();
		//=>销毁之后，再去修改响应式数据值，视图也不会在重新的渲染了

		console.dir(vm);
	</script>
</body>
复制代码
```

### VUE-REFS

> VUE框架开发的时候，我们应该尽可能减少直接去操作DOM
>
> 我们基于REF可以把当前元素放置到 this.$refs对象中，从而实现对DOM的直接操作
>
> （只有在mounted 渲染DOM完成 及之后才可以获取到）

```
<body>
	<div id="app">
		<h3 v-html='msg' ref='titleBox'></h3>
		<p ref='pBox'></p>
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script>
		//=>VUE框架开发的时候，我们应该尽可能减少直接去操作DOM
		//=>我们基于REF可以把当前元素放置到this.$refs对象中，从而实现对DOM的直接操作（只有在mounted及之后才可以获取到）
		let vm = new Vue({
			el: '#app',
			data: {
				msg: '你好世界'
			},
			mounted() {
				console.log(this.$refs); //=>{titleBox:H3,pBox:P}
			}
		});
	</script>
</body>

复制代码
```

### VUE-TAB

```
li和div对应切换
<!-- IMPORT CSS -->
	<link rel="stylesheet" href="css/reset.min.css">
	<style>
		.tabBox {
			box-sizing: border-box;
			margin: 20px auto;
			width: 600px;
		}

		.tabBox .tab {
			display: flex;
			position: relative;
			top: 1px;
		}

		.tabBox .tab li {
			margin-right: 10px;
			padding: 0 20px;
			line-height: 35px;
			border: 1px solid #AAA;
			background: #EEE;
			cursor: pointer;
		}

		.tabBox .tab li.active {
			background: #FFF;
			border-bottom-color: #FFF;
		}

		.tabBox .content {
			box-sizing: border-box;
			padding: 10px;
			height: 300px;
			border: 1px solid #AAA;
		}
	</style>
</head>

<body>
	<div id="app">
		<div class="tabBox">
			<ul class="tab">
				<li v-for='(item,index) in TAB_DATA' v-html='item.name' :class="{active:index===curIndex}"
					@click='handle($event,index,item.id)'>
				</li>
			</ul>
			<div class="content" v-html='content'></div>
		</div>
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script src="./node_modules/axios/dist/axios.min.js"></script>
	<script>
		let TAB_DATA = [{
			id: 1,
			name: '音乐'
		}, {
			id: 2,
			name: '影视'
		}, {
			id: 3,
			name: '动漫'
		}, {
			id: 4,
			name: '纪录片'
		}];

		let vm = new Vue({
			el: '#app',
			data: {
				//选项卡数据
				TAB_DATA,
				//展示选项卡的索引
				curIndex: 0,
				//内容区域的数据
				content: ''
			},
			created() {
				//=>生命周期函数（VUE实例创建成功）
				this.queryDATA(TAB_DATA[this.curIndex]['id']);
			},
			methods: {
				queryDATA(curID) {
					axios.get('./data.json').then(response => {
						return response.data;
					}).then(result => {
						let itemDATA = result.find(item => parseInt(item.id) === parseInt(curID));
						if (itemDATA) {
							this.content = itemDATA.content;
							return;
						}
						return Promise.reject();
					}).catch(reason => {
						this.content = '查无此信息';
					});
				},
				handle(ev, index, id) {
					if (this.curIndex === index) return;
					this.curIndex = index;
					this.queryDATA(id);
				}
			}
		});
	</script>
</body>
复制代码
多个li 一个div
	<!-- IMPORT CSS -->
	<link rel="stylesheet" href="css/reset.min.css">
	<style>
		.tabBox {
			box-sizing: border-box;
			margin: 20px auto;
			width: 600px;
		}

		.tabBox .tab {
			display: flex;
			position: relative;
			top: 1px;
		}

		.tabBox .tab li {
			margin-right: 10px;
			padding: 0 20px;
			line-height: 35px;
			border: 1px solid #AAA;
			background: #EEE;
			cursor: pointer;
		}

		.tabBox .tab li.active {
			background: #FFF;
			border-bottom-color: #FFF;
		}

		.tabBox .content {
			box-sizing: border-box;
			padding: 10px;
			height: 300px;
			border: 1px solid #AAA;
		}
	</style>
</head>

<body>
	<div id="app">
		<div class="tabBox">
			<ul class="tab">
				<li v-for='(item,index) in TAB_DATA' v-html='item.name' :class="{active:index===curIndex}"
					@click='handle($event,index,item.id)'>
				</li>
			</ul>
			<div class="content" v-html='content'></div>
		</div>
	</div>
	<!-- IMPORT JS -->
	<script src="./node_modules/vue/dist/vue.js"></script>
	<script src="./node_modules/axios/dist/axios.min.js"></script>
	<script>
		let TAB_DATA = [{
			id: 1,
			name: '音乐'
		}, {
			id: 2,
			name: '影视'
		}, {
			id: 3,
			name: '动漫'
		}, {
			id: 4,
			name: '纪录片'
		}];

		let vm = new Vue({
			el: '#app',
			data: {
				//选项卡数据
				TAB_DATA,
				//展示选项卡的索引
				curIndex: 0,
				//内容区域的数据
				content: ''
			},
			created() {
				//=>生命周期函数（VUE实例创建成功）
				this.queryDATA(TAB_DATA[this.curIndex]['id']);
			},
			methods: {
				queryDATA(curID) {
					axios.get('./data.json').then(response => {
						return response.data;
					}).then(result => {
						let itemDATA = result.find(item => parseInt(item.id) === parseInt(curID));
						if (itemDATA) {
							this.content = itemDATA.content;
							return;
						}
						return Promise.reject();
					}).catch(reason => {
						this.content = '查无此信息';
					});
				},
				handle(ev, index, id) {
					if (this.curIndex === index) return;
					this.curIndex = index;
					this.queryDATA(id);
				}
			}
		});
	</script>
</body>
```