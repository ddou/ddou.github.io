+++
date = "2016-03-19T11:43:26+08:00"
title = "函数式编程初体验 (3)"
tags = ["Functional Programming", "Haskell"]
+++

书接上回。在[上篇文章](/posts/functional-programming-in-real-world-2/)中，我们的火星探测器已经可以解析命令字符串，并且按照命令执行探测任务。新的功能要求我们在这个基础上，增加记录探测器历史位置信息的功能，以保留一份活动位置记录，以避免后期在某个区域重复探测。

### 分析
使用我们主流的编程语言，上述功能可以很简单的实现，比如采用如下两个方式：

1. 定义一个全局变量，保存历史位置信息，每次移动探测器时，添加最近的位置信息
1. 在MarsRover类中新添一个变量，保存历史位置信息，每次移动都将最近的位置信息添加到变量中

上述两种方式都可以正确的实现功能。但是在我们函数式编程的大背景下，使用是上述任一种方式，都是与函数式编程的理念相违背的： 纯函数的实现是没有副作用的，即不会修改全局状态，也不会修改参数的状态。那有什么办法呢？

不论使用何种范式的编程语言，有一些公共的问题都是在程序中需要解决的，例如异常处理，IO，全局状态等需要副作用的场景。只是不同的语言解决问题的方式不同。函数式编程在解决如上述问题时，有自己的思路。[Monad](https://www.haskell.org/tutorial/monads.html)就是函数式编程语言用来解决上述问题的利器。

###  Monad
从本质上理解Monad，需要范畴论（Category Theory）的知识，这也导致了Monad不太容易理解。简单的讲，Monad是封装了一个计算上下文(Computation Context), 正是因为这一点，monad也被称为“可编程的分号”。

有一个类型的Monad，大部分人都应该都有过了解。那就是[Maybe Monad](https://en.wikibooks.org/wiki/Haskell/Understanding_monads/Maybe)。Maybe在很多语言里面都有对应的实现。Java 8中对应的实现为[java.util.Optional](https://docs.oracle.com/javase/8/docs/api/java/util/Optional.html)。Optional代表一个可能存在的值，针对两种不同的存在状态，同一个方法调用会有不同的执行逻辑， 例如：

```java
Optional<Integer> integer = Optional.of("123").map(str -> Integer.parseInt(str));
Optional<Integer> empty = Optional.<String>empty().map(str -> Integer.parseInt(str));
```

如果我们查看Optional的源码，可以看到map方法的实现，针对了两种不同的存在状态做了不同的处理。这就是Optional所包含的所谓计算上下文，也是Monad的价值所在。

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

类似的，我们也可以通过Monad来实现保存MarsRover的历史位置数据。

### 实现

首先，我们先定义Log数据类型。 按照功能要求，我们的Log是一些列的坐标点。

```haskell
type Log = [Point]
```

然后，我们定义一个自己的monad：

```haskell
newtype Logger a =  Logger (a, Log)
    deriving (Show)

execLogger :: Logger a -> (a, Log)
execLogger (Logger (a, log)) = (a, log)

record :: MarsRover -> Logger MarsRover
record marsRover = Logger (marsRover, [point])
    where point = getPosition marsRover
```

我们定义的monad是一个新的数据类型Logger，包含了MarsRover实例，和它对应的历史位置信息。同时，我们定义了:

- execLogger方法

    > 用来从Logger中提取出rover和历史位置数据。

- record方法

    > 记录rover当前位置信息，返回包含当前rover和当前坐标的Logger对象

下面是Logger monad的实现：

```haskell
instance Monad Logger where
    return a = Logger (a, [])
    m >>= k = let (a, x) = execLogger m
                  n     = k a
                  (b, y) = execLogger n
              in Logger (b, x ++ y)
```

我们实现了两个monad typeclass定义的方法：

- return

    > 用来将MarsRover，转换成一个Logger，也是我们monad实例的创建函数

- (>>=)

    > 这里封装了我们的计算上下文，也就是累积保存位置信息的逻辑。(>>=)函数接受两个参数，第一个参数是Logger，亦即当前状态数据（rover+历史位置数据）。第二个参数是下一步要执行的操作。从(>>=)的实现来看，首先使用execLogger提取出当前状态，历史状态信息保存为x，rover信息保存为a；然后，执行下一步操作，操作结果为n；再次用execLogger提取出操作结果，得到这一步产生的状态信息y和新的rover信息b，然后将最终结果b和累积的位置数据x++y返回出去。

定义好了我们的monad后，对应的我们的run方法也要做些许的修改：

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

在新版本的run方法中，方法的返回值改成了我们的Logger类型，毕竟返回值里面是要包含我们的历史位置信息的。内部实现上并没有太大的变化，只是通过return来把返回值转换为Logger，对于move操作来说，move之后，记录下当前位置。

因为我们是要解析命令字符串，执行一系列指令，我们定义了一个用来将一系列指令顺序在rover上执行的方法apply：

```haskell
apply :: Logger MarsRover -> [MarsRover -> Logger MarsRover] -> Logger MarsRover
apply rover actions = case actions of
    [] ->  rover
    (x:xs) -> apply (rover >>= x) xs
```
apply函数接受2个参数，第一个是一个Logger对象，包含rover的初始状态。第二个参数是一个数组，代表要执行在rover上的指令。返回的是Logger对象，包含了rover的最终状态和历史位置信息。

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
