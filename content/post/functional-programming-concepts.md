+++
date = "2016-01-12T21:07:54+08:00"
title = "函数式编程 101"
tags = ["Functional Programming","Haskell"]
keywords= ["Functional Programming", "Haskell","函数式编程"]
description = "分享了函数式编程的一些基本概念，使用 Haskell 编写简单函数演示函数式编程基本概念"
+++

函数式编程这几年变得越来越流行起来，越来越多的语音融入了函数式编程的语法，就连更新缓慢如 Java 也不例外，在 Java8 中引入了函数式编程的语法。JVM 平台的后起之秀 Scala，Groovy 更是出生之初就有内置了对函数式编程的支持。作为最经常被拿来与 Java 做比较的 C#，更是抢先一步在.NET 3.5 版本时就有了对函数式编程的支持。后来.NET 平台上更是直接引入了函数式编程语言 F#。

函数式编程的兴起并非没有原因。

- **函数式编程语言一般极具表现力**. 相比主流的面向对象语言能以极少的代码完成相同的工作。与代码量的减少相对应的就是维护成本的降低。
- 相对于命令式编程，**函数式编程语言都是采用声明式编程的方式**，能在更高的抽象级别上编程，代码更易于理解。
- **纯函数是没有副作用的，既不会修改全局状态，也不会修改传入的参数。**在进行多线程编程时，就从根本上避免死锁，活锁或者是线程饥饿的问题。

## 函数式编程语言的特征

### 高阶函数

在函数式编程语言中，函数终于成为一等公民，可以跟变量一样作为参数传递，同时也可以作为函数返回值返回。这个功能带来的直接好处就是当我们需要传递**行为**的时候，不必在跟之前一样为了传递行为而引入一个对象。例如在 Java 8 之前，当我们想排序一个 List 时：

```java
	List<Integer> values = newArrayList(11, 2, 43, 14, 5, 76, 6);
	Collections.sort(values, new Comparator<Integer>() {
	    @Override
	    public int compare(Integer one, Integer other) {
	        return one.compareTo(other);
	    }
	});

```

Java 8 引入了 Lambda 之后，我们不必再引入一个对象来封装我们的排序逻辑：

```java
	Collections.sort(values, (a, b) -> a.compareTo(b));
```

本质上讲，传递进来的还是一个对象，只不过是因为 Functional Interface 的存在，我们可以**假装**传入的是一个函数。这一点在我们使用传入的对象时就更为明显: 我们不得不像使用对象一样通过调用 apply 方法来应用传入的*函数*。

```java
    public static <T> T create(String stringValue, Function<String, T> instantiator) {
        return instantiator.apply(stringValue);
    }
```

在纯粹的函数式编程语言中，高阶函数的使用则更为自然， 如在 haskell 中，

```haskell
	add :: a -> a -> a
	add a b = a + b

	perform :: a -> a -> (a -> a -> a) -> a
	perform a b action = action a b

	let result = perform 1 1 add
	// result = 2

```

既然函数可以作为参数传递，也可以作为返回值，那么函数之间的**运算**也就不足为奇了。以下是 Haskell 中用来组合（compose）函数的函数(对，这里没有写错，就是通过组合函数来生成更强大函数)。

```haskell
	(.) :: (b -> c) -> (a -> b) -> a -> c
	(.) f g x = f(g(x))
```

利用(.)，我们可以对函数进行组合：

```haskell
	plus :: a -> a
	plus x = x + 1

	double :: a -> a
	double x = x * 2

	plusThenDouble = double.plus

	let result = plusThenDouble 1
	// result = 4
```

### 科里化(Currying)

[科里化](https://en.wikipedia.org/wiki/Currying)把一个（接收多个参数的函数）的运算转化为多个（只接收一个参数的函数）的运算。例如：

```haskell
	add :: a -> a -> a
	add a b = a + b
```

函数 add 接收两个参数，返回两者的和。我们可以把函数 add 理解为接收一个参数 a，然后返回一个函数 addA。函数 B 接收另外一个参数 B, 返回值则是 A+B。那么 1+2 的例子就可以如下所示：

```haskell
   add1 :: a -> a
   add1 = add 1

   let result = add1 2 // result = 3
```

上面的例子中 add1 其实就是一个部分应用函数(Partial Applied Function)。

其实这就是函数式编程语言中代码重用的方式。面向对象语言通过继承和组合重用已有逻辑，函数式语言可以通过部分应用函数以及函数组合来实现代码复用。

本篇文章是函数式编程系列之一：

1. 函数式编程 101
2. [函数式编程 101 (续)](/posts/functional-programming-concepts-part-two/)
3. [函数式编程初体验 一](/posts/functional-programming-in-real-world/)
4. [函数式编程初体验 二](/posts/functional-programming-in-real-world-2/)
5. [函数式编程初体验 三](/posts/functional-programming-in-real-world-3/)
