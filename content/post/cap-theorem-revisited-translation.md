---
title: "[译文]再谈CAP理论"
date: "2017-05-09T23:58:10+08:00"
comments: true
tags: ["Architecture", "Distributed System", "Translation"]
keywords: ["CAP", "分布式系统", "Distributed System", "架构"]
description: "分布式系统中 CAP 是被经常讨论的一个理论。本篇翻译了 http://robertgreiner.com/2014/08/cap-theorem-revisited/。原文中对 CAP 以及其场景做了很精准的描述。"
---

最近在看分布式相关文章时，偶遇[该篇文章](http://robertgreiner.com/2014/08/cap-theorem-revisited/)，文章虽简短，但分析透彻, 故译来与大家分享，希望能读者有帮助。

_译文如下_

当今技术领域，我们经常碰到这样一种情况：希望通过增加额外的资源，如（计算能力，存储等）来横向扩展系统，以期能成功在合理的时间内完成请求处理。这是通过给系统添加商用硬件（commodity hardware）来应对不断增加的负载。该扩展策略导致的一个问题就是系统复杂度升高。该场景下 CAP 理论就要起作用了。

CAP 理论陈述如下： 在一个分布式系统中(一个由多个共享数据又互相连接的计算机节点组成的系统)，对于一次数据读/写操作对，只能得到如下三个保证中的两个： 一致性，可用性，分区容错性， 其中之一必然被牺牲。

> The CAP Theorem states that, in a distributed system (a collection of interconnected nodes that share data.), you can only have two out of the following three guarantees across a write/read pair: Consistency, Availability, and Partition Tolerance - one of them must be sacrificed.

如下图所示，我们并没有太多选择：

![](https://ws1.sinaimg.cn/large/5ee78c28ly1g4soi3a8hej20dw08f75h.jpg)

- 一致性

对于一个给定的客户端，一次读操作总是确保返回最近一次写操作。

- 可用性

一个正常工作的节点总是在合理的时间范围内返回合理的响应。

- 分区容错性

当出现网络分区时，系统也可以继续工作。

在展开讨论前，有一个点需要点明： 面向对象编程不等同网络编程！在构建共享内存的应用时一些天经地义的假设在分布式系统中并不成立。

分布式计算的一个[假象](http://en.wikipedia.org/wiki/Fallacies_of_Distributed_Computing)就是网络是可靠的。事实并非如此。网络或者其部分  总会经常出其不意的出故障。而当故障发生时，你除了接受别无他法。

鉴于网络并非完全可靠，在分布式系统中，我们必须要使系统对网络分区具有容忍性。当网络分区发生时，我们需要做出选择。基于 CAP 理论，这意味着我们要从**一致性**和**可用性**中二选一。

- **CP  一致性/分区容错性**

![](https://ws1.sinaimg.cn/large/5ee78c28ly1g4soi3fi4sj20b409kwfo.jpg)

该情况下，当发生网络分区时，客户端会持续等待响应，直至发生 Timeout 错误。根据不同的场景，系统也可以选择返回一个错误。当业务需求需要  读写操作具有原子性时，选择**一致性**而不是可用性。

- **AP 可用性/分区容错性**

![](https://ws1.sinaimg.cn/large/5ee78c28ly1g4soi2ht35j20b409kab3.jpg)

 该情况下，当发生网络分区时，系统会返回最近版本的数据，但可能是过期的数据。处于该状态的系统也继续接受写操作。当系统对数据的同步要求比较灵活时，可以优先选择**可用性**，而不是一致性。当系统在发生外部错误，有需要确保系统正常工作时，可用性是一个令人信服的选择。

CA 还是 AP，这是一个设计的折中。在发生网络分区时，你可以做出不同的选择。无论接受与否，网络故障总会发生，与软件无关。

分布式系统有很多优势，但也引入了复杂度。在网络故障下，理解不同的选项，并做出正确的选择才是系统成功的关键。 如果在起点不能正确的理解这一点，你的系统注定失败。

_译文结束_

_原文链接如下：[http://robertgreiner.com/2014/08/cap-theorem-revisited/](http://robertgreiner.com/2014/08/cap-theorem-revisited/)_
