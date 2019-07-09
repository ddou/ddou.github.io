+++
date = "2016-02-27T21:58:43+08:00"
title = "函数式编程初体验 (2)"
tags = ["Functional Programming", "Haskell"]
+++

在[上篇文章](/posts/functional-programming-in-real-world/)中，我们实现的MarsRover已经支持三种基本命令操作了。这次我们来稍微完善下，添加**从字符串解析出命令**的功能。

### 分析
传入的指令是一个字符串，每个字符对应一个命令。探测器支持的命令只有L，R和M。当遇到不支持的字符时，探测器不作出任何响应。在一般的编程语言中，可能会使用异常来处理无法支持的命令的情况。那么在Haskell中，我们有什么新的武器可以使用吗？ Yes， 那就是[Maybe](https://wiki.haskell.org/Maybe) monad.

Maybe类型代表一种有状态的数据，亦即这个数据存在，也可能不存在。Maybe类型有两个值： Just a'和Nothing，分别对应了两种状态。那么在我们的问题中，我们可以让解析函数返回一个Maybe类型，当返回的是Just时，表示返回的是一个支持的命令；当返回Nothing时，表示遇到不支持的命令。

### 实现
基于上面的分析，我们的parse函数可以实现如下：

```haskell
parse :: Char -> Maybe Command
parse c = case c of
    'L' -> Just L
    'R' -> Just R
    'M' -> Just M
    _ -> Nothing
```

parse函数接收一个字符，返回一个Maybe Command。这里又一次使用了模式匹配。当遇到不支持的命令时，返回一个Nothing。

如此一来，我们的execute的实现也要做对应的改动，以支持Maybe类型的参数。之前的定义如下：
```haskell
execute :: MarsRover -> Command -> MarsRover
execute rover command =
    case command of
        L -> turnLeft rover
        R -> turnRight rover
        M -> move rover
```

为了接收Maybe类型的参数，我们修改为如下:

```haskell
run :: Maybe Command -> MarsRover -> MarsRover
run command rover =
    case command of
        Just L -> turnLeft rover
        Just R -> turnRight rover
        Just M -> move rover
        Nothing -> rover
```
新的实现中，我们把execute重命名为run，并且修改了参数的顺序和类型。当run遇到Nothing的时候，他什么都不做，只是返回原始的rover实例。

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
如果我想支持一系列命令呢？如"LMRWWWMM"？使用Haskell的内置功能，我们可以轻松实现。

首先我们先定义了一个函数(>)， 其作用于Haskell自带的组合函数(.)类似，只不过是作用的顺序相反。

```haskell
(>) :: (a -> b) -> (b -> c) -> a -> c
(>) f g = g.f
```
例如：我们有两个函数addOne和plusTwo，那么 addOne.plusTwo的结果是生成一个新的函数，对参数会先乘以2，然后对结果再加1。而addOne>plusTwo则是先对参数加1，然后对结果乘以2。

用在我们下面的代码里面，就相当于对探测器执行了如下命令：M > L > M > R > M > L > M > L > M

```haskell
main :: IO()
main = do
    let execute = foldl (.) id $ map run $ map parse "MLMRMLMRM"
    putStrLn $ show $ execute $ MarsRover (0, 0) S
    -- 输出 MarsRover (2,-3) S
```

execute定义这行需要略作解释。Haskel中($)是一个优先级较低低的右结合运算符，f $ g $ x 的计算与f(g(x))相同，都是从右向左做运算。 这行完成了以下操作：

![map-flow](https://github.com/ddou/ddou.github.io/raw/source/static/images/map-flow.png)

1. 把MLMRMLMRM的每个字符解析为Command，第一步map操作的结果是一个Maybe Command类型的List，每个元素代表一个可能的Command。
1. 对上一步生成的List继续执行map操作，map的结果是每一个Maybe Command被转化一个部分应用的函数（Partial Applied Function)。第二步的结果也是List，只是每个元素都是一个函数，每个函数代表了要在探测器上执行的一个操作。
1. 对上一步生成的List执行foldl， 将上述List转化为一个函数，通过我们自定义的函数（>）将所有操作组合从为一个函数。

最终结果为MarsRover (2,-3) S， 读到这里的你可以心算下是否正确？

这次的功能改进里面，我们使用了Haskell的Maybe monad来处理非法命令的问题，还体会到了函数式编程简洁优美的语法， 代码可以看[这里](https://raw.githubusercontent.com/yutaodou/functional-programming-via-haskell/ab484f1676fbc945bc7e652431f659f533987a3c/examples/mars-rover.hs)。

下篇我们继续，问题可以先抛出来：

> 探测器要保存路径信息，需要将操作过程中所有的坐标信息都最终打印出来，怎么实现？

本篇文章是函数式编程系列之一：

1. [函数式编程 101](/posts/functional-programming-concepts/)
2. [函数式编程 101 (续)](/posts/functional-programming-concepts-part-two/)
3. [函数式编程初体验 一](/posts/functional-programming-in-real-world/)
4. 函数式编程初体验 二
5. [函数式编程初体验 三](/posts/functional-programming-in-real-world-3/)
