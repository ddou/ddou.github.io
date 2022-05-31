+++
date = "2016-02-27T21:58:43+08:00"
title = "函数式编程初体验 (2)"
tags = ["Functional Programming", "Haskell"]
keywords= ["Functional Programming", "Haskell","函数式编程"]
description = "分享了函数式编程的一些基本概念，使用 Haskell 编写简单函数演示函数式编程基本概念"
+++

在[上篇文章](/posts/functional-programming-in-real-world/)中，我们实现的 MarsRover 已经支持三种基本命令操作了。这次我们来稍微完善下，添加**从字符串解析出命令**的功能。

### 分析

传入的指令是一个字符串，每个字符对应一个命令。探测器支持的命令只有 L，R 和 M。当遇到不支持的字符时，探测器不作出任何响应。在一般的编程语言中，可能会使用异常来处理无法支持的命令的情况。那么在 Haskell 中，我们有什么新的武器可以使用吗？ Yes， 那就是[Maybe](https://wiki.haskell.org/Maybe) monad.

Maybe 类型代表一种有状态的数据，亦即这个数据存在，也可能不存在。Maybe 类型有两个值： Just a'和 Nothing，分别对应了两种状态。那么在我们的问题中，我们可以让解析函数返回一个 Maybe 类型，当返回的是 Just 时，表示返回的是一个支持的命令；当返回 Nothing 时，表示遇到不支持的命令。

### 实现

基于上面的分析，我们的 parse 函数可以实现如下：

```haskell
parse :: Char -> Maybe Command
parse c = case c of
    'L' -> Just L
    'R' -> Just R
    'M' -> Just M
    _ -> Nothing
```

parse 函数接收一个字符，返回一个 Maybe Command。这里又一次使用了模式匹配。当遇到不支持的命令时，返回一个 Nothing。

如此一来，我们的 execute 的实现也要做对应的改动，以支持 Maybe 类型的参数。之前的定义如下：

```haskell
execute :: MarsRover -> Command -> MarsRover
execute rover command =
    case command of
        L -> turnLeft rover
        R -> turnRight rover
        M -> move rover
```

为了接收 Maybe 类型的参数，我们修改为如下:

```haskell
run :: Maybe Command -> MarsRover -> MarsRover
run command rover =
    case command of
        Just L -> turnLeft rover
        Just R -> turnRight rover
        Just M -> move rover
        Nothing -> rover
```

新的实现中，我们把 execute 重命名为 run，并且修改了参数的顺序和类型。当 run 遇到 Nothing 的时候，他什么都不做，只是返回原始的 rover 实例。

验证一下, 正确。

```haskell
main :: IO()
main = do
    let cmd = parse 'L'
    putStrLn $ show $ run cmd $ MarsRover (0, 0) S
    -- 输出 MarsRover (0,0) E

    let cmd = parse 'W'
    putStrLn $ show $ run cmd $ MarsRover (0, 0) S
    -- 输出 MarsRover (0,0) S
```

### 更近一步

如果我想支持一系列命令呢？如"LMRWWWMM"？使用 Haskell 的内置功能，我们可以轻松实现。

首先我们先定义了一个函数(>)， 其作用于 Haskell 自带的组合函数(.)类似，只不过是作用的顺序相反。

```haskell
(>) :: (a -> b) -> (b -> c) -> a -> c
(>) f g = g.f
```

例如：我们有两个函数 addOne 和 plusTwo，那么 addOne.plusTwo 的结果是生成一个新的函数，对参数会先乘以 2，然后对结果再加 1。而 addOne>plusTwo 则是先对参数加 1，然后对结果乘以 2。

用在我们下面的代码里面，就相当于对探测器执行了如下命令：M > L > M > R > M > L > M > L > M

```haskell
main :: IO()
main = do
    let execute = foldl (.) id $ map run $ map parse "MLMRMLMRM"
    putStrLn $ show $ execute $ MarsRover (0, 0) S
    -- 输出 MarsRover (2,-3) S
```

execute 定义这行需要略作解释。Haskel 中($)是一个优先级较低低的右结合运算符，f $ g $ x 的计算与 f(g(x))相同，都是从右向左做运算。 这行完成了以下操作：

![map-flow](https://github.com/ddou/ddou.github.io/raw/source/static/images/map-flow.png)

1. 把 MLMRMLMRM 的每个字符解析为 Command，第一步 map 操作的结果是一个 Maybe Command 类型的 List，每个元素代表一个可能的 Command。
1. 对上一步生成的 List 继续执行 map 操作，map 的结果是每一个 Maybe Command 被转化一个部分应用的函数（Partial Applied Function)。第二步的结果也是 List，只是每个元素都是一个函数，每个函数代表了要在探测器上执行的一个操作。
1. 对上一步生成的 List 执行 foldl， 将上述 List 转化为一个函数，通过我们自定义的函数（>）将所有操作组合从为一个函数。

最终结果为 MarsRover (2,-3) S， 读到这里的你可以心算下是否正确？

这次的功能改进里面，我们使用了 Haskell 的 Maybe monad 来处理非法命令的问题，还体会到了函数式编程简洁优美的语法， 代码可以看[这里](https://raw.githubusercontent.com/yutaodou/functional-programming-via-haskell/ab484f1676fbc945bc7e652431f659f533987a3c/examples/mars-rover.hs)。

下篇我们继续，问题可以先抛出来：

> 探测器要保存路径信息，需要将操作过程中所有的坐标信息都最终打印出来，怎么实现？

本篇文章是函数式编程系列之一：

1. [函数式编程 101](/posts/functional-programming-concepts/)
2. [函数式编程 101 (续)](/posts/functional-programming-concepts-part-two/)
3. [函数式编程初体验 一](/posts/functional-programming-in-real-world/)
4. 函数式编程初体验 二
5. [函数式编程初体验 三](/posts/functional-programming-in-real-world-3/)
