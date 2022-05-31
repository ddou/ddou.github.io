---
title: "闲谈软件系统中的复杂度"
date: 2020-04-21T22:50:34+08:00
publishdate: 2020-04-22
lastmod: 2020-04-22
tags: ["Design", "OO", "Java", "Architecture"]
description: "面向对象设计与模块设计"
keywords: ["面向对象设计", "模块化"]
---

现在的软件项目大多越来越复杂，随着上线时间日久，业务持续变更，开发人员一波一波的轮换，产品到后期时，改动日渐困难，上线时间遥遥无期。类似的系统之所以复杂， 其中部分原因是由于业务本身的复杂性，另外一部分的复杂度则是来自于开发阶段，也就是说由开发阶段不合理的设计和实现引入的。 不合理的设计和实现导致系统僵硬和脆弱，难以修改，难以重用，容易出错。模块化是应对复杂系统的一种常用办法。

## 模块化

分而治之是我们在面临复杂问题时常用的应对手法。按照[MECE](https://wiki.mbalib.com/wiki/MECE%E5%88%86%E6%9E%90%E6%B3%95)的原则，我们把复杂问题分解为一个个更简单的小问题，然后各个击破。微服务设计中的做法是把整个问题域划分为多个子域，每个子域对应一个受限上下文(bounded context), 进而每个受限上下文可以对应到一个微服务。每个微服务有各自的职责，包含该问题子域内的业务逻辑。多个微服务之间协作共同为上层提供业务能力。

在单个组件内部，代码被组织到不同的模块内。模块级别的实现上，则是把模块职责做更细的划分，对应到不同的类实现不同的职责。

![lego-bricks](/image/lego-bricks.webp)

模块之间通过提供的接口彼此交互。模块可以以不同的形式对外提供接口：

- API
- 外部可访问的数据结构
- 外部可访问的函数
- 共享文件或内存

模块之间的耦合的方式也会因不同的接口方式而有所不同。模块化带来最大的好处是通过接口来提供其功能，而隐藏了功能的实现细节。模块的使用者仅仅关心接口的使用，而不必关注于功能的实现方式。基于模块化的系统设计，能带来显而易见的好处：

**高层次快速理解系统结构**

通过梳理系统模块结构，理清各个模块的职责，对外提供的接口，我们可以快速从高层次快速理解系统的结构。[C4 模型](https://c4model.com/)是经常用来可视化系统架构一个工具。其中的组件图(Component Diagram)就展示了系统模块结构：

![Component Diagram](https://c4model.com/img/bigbankplc-Components.png)

**细节层面的功能开发**

当深入代码细节时，开发人员这更多关注于当前模块，而不必关心所依赖模块的细节。这样就避免了将太多逻辑装载进脑中，降低认知复杂度。

有了模块和接口，模块间互相配合也完成了功能，然后呢？

## 简单接口

Java 开发人员对 Java 中文件读取的操作应该都有很深刻的印象：

```java
	FileInputStream fileStream = new FileInputStream(fileName);
	BufferedInputStream bufferedStream = new BufferedInputStream(fileStream);
	ObjectInputStream objectStream = new ObjectInputStream(bufferedStream);
```

当我们想读取一个包含序列化对象的文件时，必须要手动构建一个`FileInputStream`, `BufferedInputStream`， 然后才是`ObjectInputStream`。虽然这样的设计提供了足够的灵活度，但对用户而言，这是非常的不友好。

在《软件设计的哲学》中，John Ousterhout 提出 Deep Module 的概念：

> “The best modules are deep: they allow a lot of functionality to be accessed through a simple interface. A shallow module is one with a relatively complex interface, but not much functionality: it doesn’t hide much complexity.”
>
> 一个设计良好的模块通过简单接口提供其功能。浅模块则提供相对复杂的接口，却没有太多功能，它没有隐藏太多复杂度。

![Deep module](/image/deep-module.webp)

简单接口的一个好的例子是 Jackson 中`ObjectMapper`。在大部分的场景下， 当我们需要在 JSON 和 java 对象间转化时， 通过默认构造函数创建的`ObjectMapper`实例可以完全胜任。在另外一些特殊场景下，则可以通过`ObjectMappperBuilder`定制 objectMapper 实例的特性:

```java
	ObjectMapper mapper = ObjectMapper.builder()
	    .disable(MapperFeature.INFER_PROPERTY_MUTATORS)
	    .build();
```

通过简单接口，将更多交互细节隐藏在模块内，简化模块间交互。

## 隔离变化

“唯一不变的是变化本身”。每个程序员对这句话都有深刻的领悟。[敏捷宣言](http://agilemanifesto.org/iso/zhchs/manifesto.html)教导我们要响应变化。那么在设计层面怎么响应变化，拥抱变化呢？

```java
public class Calculator {
    private final ConsoleOutputter outputter;
    public Calculator(ConsoleOutputter outputter) {
        this.outputter = outputter;
    }

    public String output() {
        return this.outputter.out(this.getResult());
    }

    //......
}
```

这个上面代码里面， `Calculator`依赖于`Output`模块。`Output`模块对外暴露了一个`ConsoleOutputter`类，能将结果转化为适合在命令行下输出的格式。

如果业务变化的方向是需要支持不同的输出格式，如 JSON/XML 等，上述实现是不能让我们拥抱变化的。SOLID 中的 DIP(依赖倒置原则)要求应该依赖于稳定的抽象，而不是具体的实现。面向对象语言的多态特性能很方便的实现上述抽象，类似的，动态类型语言因为 duck typing 也可以实现：

```java
interface Outputter {
     String output(Result result);
}

public class Calculator {
    private final Outputter outputter;
    public Calculator(Outputter outputter) {
        this.outputter = outputter;
    }

    public String output() {
        return this.outputter.out(this.getResult());
    }

    //......
}
```

当需要支持其他不同类型的输出格式时，我们可以很方便的添加`Outputter`的实现，而不必修改`Calculator`。如此，我们在遵循了 DIP 的同时，代码也更加符合 OCP(开闭原则)。

通过引入一个间接层（`Outputter`接口）来隔离变化，这是面向对象中非常普遍的做法。它能带来隔离变化的好处，但也导致了额外的复杂度。在引入间接层时，应该保持克制，只在必要的时候才这么做。

> There is no problem in computer science that can't be solved using another level of indirection...except too many levels of indiretion.

在 Ports and Adapters 架构中，通过 Port 来提供接口给外部，同时隔离外部变化，外部系统需要通过提供 Adapter 的方式与 Port 交互。

类似的，在领域驱动设计中，防腐层(anti-corruption layer)也是一个间接层。防腐层对两套系统之间的数据模型以及功能行为的转换进行了合理封装，并且能够确保其中一个系统的领域层不会依赖于另一系统。引入防腐层后，外部系统中模型和功能的变化不会传递到本系统中，降低了系统开发和维护的复杂度。

## 简单设计

最好的解决问题的办法就是不要引入问题。也就是降低实现中不必要的复杂度。遵循整洁代码可以让我们在细节层面写出更清晰易懂的代码。遵循 Simple Design 的原则，减少不必要的复杂度。简单设计中提出了 4 个要求：

1. 通过所有测试
2. 代码的意图表达清晰
3. 没有重复
4. 最少的元素

首先保证功能正确，在这个前提下确保代码意图表达清晰。最后，消除重复以及不必要的元素，以确保设计简单并且够用。

在面向对象编程领域，有很多的原则(如 SOLID)和模式可以用来指导我们的实现。但抛开其中面向对象的部分，很多原则如模块化、抽象、封装、简单设计等在其他编程范式下同样适用。遵循这些原则，并且经常用这些原则审视我们的设计可以帮我们更深入的领会这些原则的同时，改进我们的设计。

## 参考

1. [https://book.douban.com/subject/30218046/](https://book.douban.com/subject/30218046/)
2. [https://docs.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer](https://docs.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer)
3. [https://web.archive.org/web/20060711221010/http://alistair.cockburn.us:80/index.php/Hexagonal_architectur](https://web.archive.org/web/20060711221010/http://alistair.cockburn.us:80/index.php/Hexagonal_architectur)
4. [https://www.martinfowler.com/bliki/BeckDesignRules.html](https://www.martinfowler.com/bliki/BeckDesignRules.html)
