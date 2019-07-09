+++
date = "2016-02-27T21:58:43+08:00"
title = "函数式编程初体验 （1）"
tags = ["Functional Programming", "Haskell"]
+++

在之前的两篇函数式编程语言特性的文章（[上篇](/posts/functional-programming-concepts/)和[下篇](/posts/functional-programming-concepts-part-two/)）中简单介绍了一些基本的函数式编程的概念。对函数式编程有了一些基本的概念，那现实中的函数式编程是什么样子的呢？这里就选取一个比较简单的问题，使用Haskell尝试解决一下，以求近距离的感受下函数之美。

### 问题
这里采用的是我司一个废弃了很久的面试题目MarsRover，题目内容如下：

> A squad of robotic rovers are to be landed by NASA on a plateau on Mars. This plateau, which is curiously rectangular, must be navigated by the rovers so that their on-board cameras can get a complete view of the surrounding terrain to send back to Earth. A rover's position and location is represented by a combination of x and y co-ordinates and a letter representing one of the four cardinal compass points. The plateau is divided up into a grid to simplify navigation. An example position might be 0, 0, N, which means the rover is in the bottom left corner and facing North. In order to control a rover, NASA sends a simple string of letters. The possible letters are 'L', 'R' and 'M'. 'L' and 'R' makes the rover spin 90 degrees left or right respectively, without moving from its current spot. 'M' means move forward one grid point, and maintain the same heading.

> Assume that the square directly North from (x, y) is (x, y+1).

大意是

> 在直角坐标系内，有一个探测器，探测器有三个状态，X和Y标记探测器所在位置，Direction标记了探测器的前进方向。科学家发送指令L, R, M给探测器，分别表示左转90度，右转90度和前进。 问题就是给定一个初始条件，和一系列命令，求解探测器最终状态。

下面我们看使用Haskell如何解决上述问题。

### 求解

首先，我们需要定义一些基本的数据类型。

```haskell
-- 北，东，南，西
data Direction = N | E | S | W
    deriving (Show)

-- 左转，右转，和移动
data Command = L | R | M
    deriving (Show)

-- 位置
type Point = (Int, Int)

-- 探测器
data MarsRover = MarsRover Point Direction
    deriving (Show)
```
上述定义中的deriving (Show)类似于我们常见的toString。Haskll中定义的类型只有加了上述定义后，才会把对应的数据结构转换成字符串，输出到控制台，才能方便调试以及查看结果。


然后，我们可以定义三个函数turnLeft、turnRight和move，分别对应对探测器的三个操作。

```haskell
turnLeft :: MarsRover -> MarsRover
turnLeft rover = case rover of
        MarsRover p N -> MarsRover p W
        MarsRover p W -> MarsRover p S
        MarsRover p S -> MarsRover p E
        MarsRover p E -> MarsRover p N

turnRight :: MarsRover -> MarsRover
turnRight rover =
    case rover of
        MarsRover p N -> MarsRover p E
        MarsRover p W -> MarsRover p N
        MarsRover p S -> MarsRover p W
        MarsRover p E -> MarsRover p S

move :: MarsRover -> MarsRover
move rover =
    case rover of
        MarsRover (x, y) N -> MarsRover (x, y+1) N
        MarsRover (x, y) E -> MarsRover (x+1, y) E
        MarsRover (x, y) W -> MarsRover (x-1, y) W
        MarsRover (x, y) S -> MarsRover (x, y-1) S
```
三个函数定义都是我们之前提到的**纯函数**，函数中使用了**模式匹配**以获取结构体中数据。下述模式匹配的部分实现虽略有繁琐，但逻辑清晰明了。与我们常用的if-else或者switch语句相比较，模式匹配的语法也更简洁。MarsRover类型也是**不可变**的，每次操作都会返回一个新的实例。

我们下面再定义个execute函数，略微做下封装。execute函数本身并没有太多逻辑，只是针对不同command做分发，调用对应的操作函数。

```haskell
execute :: MarsRover -> Command -> MarsRover
execute rover command =
    case command of
        L -> turnLeft rover
        R -> turnRight rover
        M -> move rover
```

上述定义了我们所需函数，到了展示我们工作成果的时候了：

```haskell
main :: IO()
main = do
    putStrLn $ show $ move.turnLeft.move.turnRight.move $ MarsRover (0, 0) S
    -- 输出结果: MarsRover (-1,-2) S
```
上面我们给定了探测器的初始条件为**坐标(0，0)南向**，然后执行了下列操作：

1. 前移
2. 右转
3. 前移
4. 左转
5. 前移

然后我们将探测器的状态转换为字符串输出至控制台，结果为MarsRover (-1,-2) S， 完全正确。

太棒了，简单43行代码，我们就用hanskell完成了题目的功能。我们完成了以下任务：

- 定义了基本几个**数据类型**
- 定义一系列**纯函数**
- 使用了**模式匹配**来实现代码功能。
- 在最后验证的部分，我们利用了函数式编程中**高阶函数**的特性，使用haskll中的**函数组合**函数(.)把对探测器的多步操作组合为一个函数。 比起Java等其他语言中一个一个的函数调用是不是酷帅多了？

有兴趣看代码的同学，可以查看[完整代码](https://github.com/yutaodou/functional-programming-via-haskell/blob/3758effe6b2b97a60d7fc4b9b1ac6aae287da58b/examples/mars-rover.hs)

这里我们只实现了部分功能，[下篇](/posts/functional-programming-in-real-world-2/)我们来尝试下从字符串解析命令来执行!

本篇文章是函数式编程系列之一：

1. [函数式编程 101](/posts/functional-programming-concepts/)
2. [函数式编程 101 (续)](/posts/functional-programming-concepts-part-two/)
3. 函数式编程初体验 一
4. [函数式编程初体验 二](/posts/functional-programming-in-real-world-2/)
5. [函数式编程初体验 三](/posts/functional-programming-in-real-world-3/)
