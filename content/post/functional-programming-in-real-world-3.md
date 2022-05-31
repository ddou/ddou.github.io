+++
date = "2016-03-19T11:43:26+08:00"
title = "函数式编程初体验 (3)"
tags = ["Functional Programming", "Haskell"]
keywords= ["Functional Programming", "Haskell","函数式编程"]
description = "分享了函数式编程的一些基本概念，使用 Haskell 编写简单函数演示函数式编程基本概念"
+++

书接上回。在[上篇文章](/posts/functional-programming-in-real-world-2/)中，我们的火星探测器已经可以解析命令字符串，并且按照命令执行探测任务。新的功能要求我们在这个基础上，增加记录探测器历史位置信息的功能，以保留一份活动位置记录，以避免后期在某个区域重复探测。

### 分析

使用我们主流的编程语言，上述功能可以很简单的实现，比如采用如下两个方式：

1. 定义一个全局变量，保存历史位置信息，每次移动探测器时，添加最近的位置信息
1. 在 MarsRover 类中新添一个变量，保存历史位置信息，每次移动都将最近的位置信息添加到变量中

上述两种方式都可以正确的实现功能。但是在我们函数式编程的大背景下，使用是上述任一种方式，都是与函数式编程的理念相违背的： 纯函数的实现是没有副作用的，即不会修改全局状态，也不会修改参数的状态。那有什么办法呢？

不论使用何种范式的编程语言，有一些公共的问题都是在程序中需要解决的，例如异常处理，IO，全局状态等需要副作用的场景。只是不同的语言解决问题的方式不同。函数式编程在解决如上述问题时，有自己的思路。[Monad](https://www.haskell.org/tutorial/monads.html)就是函数式编程语言用来解决上述问题的利器。

### Monad

从本质上理解 Monad，需要范畴论（Category Theory）的知识，这也导致了 Monad 不太容易理解。简单的讲，Monad 是封装了一个计算上下文(Computation Context), 正是因为这一点，monad 也被称为“可编程的分号”。

有一个类型的 Monad，大部分人都应该都有过了解。那就是[Maybe Monad](https://en.wikibooks.org/wiki/Haskell/Understanding_monads/Maybe)。Maybe 在很多语言里面都有对应的实现。Java 8 中对应的实现为[java.util.Optional](https://docs.oracle.com/javase/8/docs/api/java/util/Optional.html)。Optional 代表一个可能存在的值，针对两种不同的存在状态，同一个方法调用会有不同的执行逻辑， 例如：

```java
Optional<Integer> integer = Optional.of("123").map(str -> Integer.parseInt(str));
Optional<Integer> empty = Optional.<String>empty().map(str -> Integer.parseInt(str));
```

如果我们查看 Optional 的源码，可以看到 map 方法的实现，针对了两种不同的存在状态做了不同的处理。这就是 Optional 所包含的所谓计算上下文，也是 Monad 的价值所在。

```java
public<U> Optional<U> map(Function<? super T, ? extends U> mapper) {
    Objects.requireNonNull(mapper);
    if (!isPresent())
        return empty();
    else {
        return Optional.ofNullable(mapper.apply(value));
    }
}
```

类似的，我们也可以通过 Monad 来实现保存 MarsRover 的历史位置数据。

### 实现

首先，我们先定义 Log 数据类型。 按照功能要求，我们的 Log 是一些列的坐标点。

```haskell
type Log = [Point]
```

然后，我们定义一个自己的 monad：

```haskell
newtype Logger a =  Logger (a, Log)
    deriving (Show)

execLogger :: Logger a -> (a, Log)
execLogger (Logger (a, log)) = (a, log)

record :: MarsRover -> Logger MarsRover
record marsRover = Logger (marsRover, [point])
    where point = getPosition marsRover
```

我们定义的 monad 是一个新的数据类型 Logger，包含了 MarsRover 实例，和它对应的历史位置信息。同时，我们定义了:

- execLogger 方法

  > 用来从 Logger 中提取出 rover 和历史位置数据。

- record 方法

  > 记录 rover 当前位置信息，返回包含当前 rover 和当前坐标的 Logger 对象

下面是 Logger monad 的实现：

```haskell
instance Monad Logger where
    return a = Logger (a, [])
    m >>= k = let (a, x) = execLogger m
                  n     = k a
                  (b, y) = execLogger n
              in Logger (b, x ++ y)
```

我们实现了两个 monad typeclass 定义的方法：

- return

  > 用来将 MarsRover，转换成一个 Logger，也是我们 monad 实例的创建函数

- (>>=)

  > 这里封装了我们的计算上下文，也就是累积保存位置信息的逻辑。(>>=)函数接受两个参数，第一个参数是 Logger，亦即当前状态数据（rover+历史位置数据）。第二个参数是下一步要执行的操作。从(>>=)的实现来看，首先使用 execLogger 提取出当前状态，历史状态信息保存为 x，rover 信息保存为 a；然后，执行下一步操作，操作结果为 n；再次用 execLogger 提取出操作结果，得到这一步产生的状态信息 y 和新的 rover 信息 b，然后将最终结果 b 和累积的位置数据 x++y 返回出去。

定义好了我们的 monad 后，对应的我们的 run 方法也要做些许的修改：

```haskell
run :: Maybe Command -> MarsRover -> Logger MarsRover
run command rover =
    case command of
        Just L -> return $ turnLeft rover
        Just L -> return $ turnRight rover
        Just M -> (move' rover) >>= record
        Nothing -> return rover
    where move' rover = return (move rover)
```

在新版本的 run 方法中，方法的返回值改成了我们的 Logger 类型，毕竟返回值里面是要包含我们的历史位置信息的。内部实现上并没有太大的变化，只是通过 return 来把返回值转换为 Logger，对于 move 操作来说，move 之后，记录下当前位置。

因为我们是要解析命令字符串，执行一系列指令，我们定义了一个用来将一系列指令顺序在 rover 上执行的方法 apply：

```haskell
apply :: Logger MarsRover -> [MarsRover -> Logger MarsRover] -> Logger MarsRover
apply rover actions = case actions of
    [] ->  rover
    (x:xs) -> apply (rover >>= x) xs
```

apply 函数接受 2 个参数，第一个是一个 Logger 对象，包含 rover 的初始状态。第二个参数是一个数组，代表要执行在 rover 上的指令。返回的是 Logger 对象，包含了 rover 的最终状态和历史位置信息。

我们可以通过如下方式验证结果：

```haskell
main :: IO()
main = do
    let rover = MarsRover (0, 0) S
    let actions = map run $ map parse "MLMRMLMRM"
    let result = apply (record rover) actions
    putStrLn $ show result
    -- Logger (MarsRover (2,-3) S,[(0,0),(0,-1),(1,-1),(1,-2),(2,-2),(2,-3)])
```

上述输出中的[(0,0),(0,-1),(1,-1),(1,-2),(2,-2),(2,-3)]即为探测器的历史位置信息。

查看完整代码，看[这里](https://raw.githubusercontent.com/yutaodou/functional-programming-via-haskell/f5b9f9246c319821a9c9523e210608bf98c77cb5/examples/mars-rover.hs)

本篇文章是函数式编程系列之一：

1. [函数式编程 101](/posts/functional-programming-concepts/)
2. [函数式编程 101 (续)](/posts/functional-programming-concepts-part-two/)
3. [函数式编程初体验 一](/posts/functional-programming-in-real-world/)
4. [函数式编程初体验 二](/posts/functional-programming-in-real-world-2/)
5. 函数式编程初体验 三
