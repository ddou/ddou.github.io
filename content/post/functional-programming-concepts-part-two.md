+++
date = "2016-01-18T21:57:55+08:00"
title = "函数式编程 101 (续)"
tags = ["Functional Programming", "Haskell"]
+++

[上一篇](http://ddou.github.io/posts/functional-programming-concepts/)提到了函数式编程语言的两个特点。这里书接上回，我们继续探讨函数式编程语言的其他特点。

### 尾递归

递归是我们在编程中处理集合时经常用的到的一个技巧，使用递归相对于循环来说可以更容易的实现功能。比如说求一个整数num的阶乘，采用递归可以实现如下：

```java
private static Integer factorial(int num) {
    if (num == 1) {
        return 1;
    }
    return num * factorial(num - 1);
}

Integer result = factorial(10);
// result = 3628800
```

上述递归的实现清晰易懂，结果正确。但是一个问题是，每当factorial调用自身时，如当num=8时，都会在调用堆栈上保存当前的执行上下文，当回调结束时以计算当前num(8)和factorial(7)的乘积。我们知道
每个程序在执行时，系统分配的堆栈大小都是有限制的。当回调足够多时，如num大，就可能出现堆栈溢出的错误。

一个解决该问题的办法就是采用尾递归。比如采用尾递归的方式实现阶乘计算如下：

```java
private static Integer factorial2(int accu, int num) {
    if (num == 1) {
        return accu;
    }
    return factorial2(accu * num, num - 1);
}

Integer result = factorial2(1, 10);
// result = 3628800
```

上述factorial2的实现中，中间的计算结果是以参数accu的方式传递给递归调用的函数，此时无需等递归函数调用结束再计算，故无需保存调用上下文，避免了堆栈操作，也就避免了因递归调用太多而导致的堆栈溢出问题。

对集合进行操作是编程中的一个永恒主题。函数式编程语言中内置了许多对集合进行操作的函数，其中很多都是采用尾递归式的实现。如haskell中求阶乘:

```haskell

let values = [1..10]
let result = foldl (\x y -> x * y) 1 values
// result = 3628800

```

### 模式匹配（Pattern Matching）

我们大部分程序都是在对数据进行解构，并基于数据内容进行不同的处理。函数式编程语言一般都支持模式匹配，模式匹配可以方便我们解构数据，并对不同的数据采用不同的处理方式。假设我们有如下数据定义：

```haskell

data Category = Book | Food | Medical | Other

data Product = Product String Float Category

```
这里我们定义了两个数据结构，Category和Product。Product具有三个属性，name, price和category。假设对不同商品，我们有不同的消费税计算逻辑，在支持模式匹配的语言中我们可以如下实现：

```haskell
getTax :: Product -> Float
getTax product = case product of
	(Product _ price Book) -> price * 0.05 // 书籍适用税率0.05
	(Product _ _ Food) -> 0.0	// 食品免税
	(Product _ _ Medical) -> 0.0 // 药品免税
	(Product _ price _) -> price 0.1 // 其他商品 0.1消费税
```

### 纯函数(Pure Function)
我们可以利用高中时代学到的函数的知识理解纯函数，例如y=x \* x。对于函数y=x \* x，它的执行结果只依赖于输入参数x，与执行上下文无关；它的执行也不会对执行上下文有任何的影响。在函数式编程语言中，纯函数也有与此类似的属性。我们可以说一个函数是纯函数，如果它满足一下两个[条件](https://en.wikipedia.org/wiki/Pure_function)：

- 输出结果只依赖于输入参数，相同的输入参数总能得到相同的输出结果。
- 函数的执行不对对外产生任何副作用，基本修改可变对象状态或者输出。

我们当年学到的三角函数都是纯函数的典型：

```java

let value = Math.Sin(90);
let abs = Math.abs(-1);
let min = Math.min(1,2);

```

### 声明式编程(Declarative Programming)
我们经常见到的Java， C#， C++都是采用命令式编程。当我们要只执行一个操作的适合，需要通过一行行代码告诉计算机怎么去执行我们想要的操作，如最简单的求和：

```java
private Integer sum(List<Integer> value){
    int total = 0;
    for (int i = 0; i < value.size(); i++) {
        total + = value.get(i);
    }
    return total;
}
```

声明式编程则是在更抽象的级别进行编程，只需告诉计算机要做什么。如：

```haskell

let values = [1..10]

let result = sum values // 55

let even_numbers = filter even [1..10] // [2,4,6,8,10]

let first_even = take 1 even_numbers // 2

let sumOfEvenSquares = sum $ map (\x -> x*x) $ filter even [1..10] // 220

let squareTriangles = [(a,b,c) | a<-[1..10], b <- [1..10], c <-[1..10], a*a + b*b = c*c] // [(3,4,5),(4,3,5),(6,8,10),(8,6,10)]


```

相对于命令式编程，采用声明式编程的函数式编程语言更富有表现力，能通过更少的代码实现更多的逻辑，同时代码也更清晰易懂。这估计也是函数式编程语言能够流行的一个原因。

上面简单的介绍了函数式编程语言的一些基本特征。

本篇文章是函数式编程系列之一：

1. [函数式编程 101](/posts/functional-programming-concepts/)
2. 函数式编程 101 (续)
3. [函数式编程初体验 一](/posts/functional-programming-in-real-world/)
4. [函数式编程初体验 二](/posts/functional-programming-in-real-world-2/)
5. [函数式编程初体验 三](/posts/functional-programming-in-real-world-3/)
