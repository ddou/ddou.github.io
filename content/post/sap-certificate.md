---
title: "AWS专家级解决方案架构师认证(SAP)备考指北"
date: 2019-12-30T17:57:02+08:00
publishdate: 2019-12-30
lastmod: 2019-12-30
draft: false
tags: ["Growth","AWS"]
keywords: ["AWS", "SAP", "解决方案架构师","认证","考试"]
description: "分享AWS专家级解决方案架构师认证(SAP)，备考、复习、已经相关资料"
---

<br/>

### 一个Flag

年中上一个项目结束，回到阔别已久的西安，进入一个相对稳定的项目。 了解到AWS调整了AWS专家级解决方案架构师认证(SAP)的[条件](https://aws.amazon.com/cn/certification/faqs/?nc1=h_ls)，取消了助理级解决方案架构师(SAA)的限制条件，可以直接进行专业级别的认证。作为一个在AWS平台上摸爬滚打的大概4年的老鸟，我觉得也应该是时候经过一次考试的洗礼，全面而细致的梳理下已有知识，并重新认识AWS平台上的各种服务。于是，一个flag就这么立了起来。从8月中开始准备，到12月初通过考试，耗时大概3个月。下面就把这三个月的复习备考过程分享给需要的朋友。

<br/>
### 关于AWS解决方案架构师认证

![](https://i.loli.net/2019/12/31/Lsy8N9hRGwztZe1.png)


AWS一共推出了上图中的11个认证考试，涵盖了不同的专业方向以及难度级别。其中AWS Solution Architect解决方案架构师认证更多是关注AWS平台上的架构设计，比如使用AWS平台上的各种服务设计一个安全、稳定可靠、伸缩性好、性能优越，并且可运维的系统。除了架构设计外，系统和数据迁移、企业环境下AWS网络规划、成本控制等也是考试的要点。

AWS解决方案架构师认证有两个级别：助理级解决方案架构师(SAA)和专家级解决方案架构师(SAP)。2018年10月之后, AWS取消了参加SAP认证必须要先通过SAA认证的前提要求，给应试者更大的灵活性。在申请专业级认证前，应试者不再需要获得助理级认证，并且在申请专项认证之前，应试者不再需要获得云从业者认证或助理级认证。

<br/>

### 考试内容

![](https://i.loli.net/2019/12/31/x3S21dyPemvwtiq.png)

SAP的考试一共涵盖上述5部分内容：

- 复杂组织环境下的设计

这部分主要考察复杂组织环境下的系统设计，如一个组织，有多个业务线（Business unit),、复杂的合规要求以及多变的扩展性需求，在该环境下，如何进行鉴权以及访问控制，如何规划AWS网络以满足跨VPC、Account或者和自有数据中心网络互通等。

在平时工作中，我们更多是关注与系统的设计和实现，大部分人没有太多机会能在上述复杂环境下进行实操，这也是个人认为在学习过程中最有挑战和花费时间最多的部分。

- 设计新解决方案

如何基于AWS平台设计一个新的解决方案，在满足业务需求的同时，满足性能、可靠性、伸缩行、经济行等非功能性需求。这部分更多考察对AWS核心服务的理解，如EC2, EBS, S3, IAM, Security group, RDS, API Gateway, Lambda, SNS, SQS等。

- 迁移规划

系统和数据从自有数据中心向AWS平台迁移。 

- 成本控制

如何以最具成效比的方式架构系统

- 现有系统优化

<br/>

### 考试形式

考试题型全部为选择题，有单选题和多选题之分。如果是多选题，题目会标示有**几个**正确选项。

相比较于SAA认证，SAP在题目的难度上有非常大的提升。SAA重在于对AWS各个服务功能的理解，偏概念性，题目也较为直接，如：

![](https://i.loli.net/2019/12/31/Oa89ESJPlTBv5MI.png)

而SAP考试则更偏重知识的实际应用，场景更为复杂，如下例所示：

![](https://i.loli.net/2019/12/31/ZIoBwc28Ppkf5A1.png)

如果选择英语作为考试语言，那么SAP的考试首先面对的是3个小时的英语阅读理解，然后才是背后的AWS认证考试。

这样的题目更类似于日常工作的场景：给出一个假设的业务场景，有具体的期望目标以及各种约束，然后给出解决方案。除了理解AWS各种服务的功能、特性、使用场景、限制外，SAP还需要有更多的实战经验和更多架构上的理解，所以说SAP是难度最高的AWS认证考试也不为过。估计这也是为什么AWS建议按照推荐的学习路径逐步学习，再进行SAP认证的原因了。

![](https://i.loli.net/2019/12/31/eACHskfQalvix5y.png)

<br/>

### 复习规划

每年的AWS reinvent都是一次狂欢，大家都期盼着新的服务发布，帮大家解决实际问题。经过一轮轮狂欢，AWS的服务也涵盖了方方面面。对准备考试而言，这可不是什么值得高兴的事情，AWS服务控制台中一页已经不能完整列出所有的服务了。


![](https://i.loli.net/2019/12/31/uljgUqCpDE1osGO.png)


**关注重点**

如此之多的服务，每个服务都达到同样的熟悉程度是不现实的，那就只能重点关注了。我订阅了两个月的[acloud.gugu](https://acloud.guru)(这里真的没有广告)，基于上面SAP相关的视频，把主要的服务快速了解一遍。经过这一轮，整理出了一个学习列表，把相关服务按照领域归类，逐个学习了解。

- 对于已经比较了解的服务，快速跳过；
- 对于比较重要但之前接触不多的服务，相关的FAQ/文档/用户案例/白皮书快速看一遍。
- 对于不太常用的服务，更多是看FAQ，了解服务基本功能，以及用户案例。


**定期检查**

[acloud.gugu](https://acloud.guru)（真心没有广告）的另外一个功能是模拟考试，大概有100道题。可以通过完成这些题目，检查学习的情况，查漏补缺。另外，AWS官方也有一份例题，虽然没有答案的，按时对于了解考试题型还是非常有帮助的。

除了上述外，网上也有不少例题资源，如[www.examtopics.com](https://www.examtopics.com/), 这里有网络上收集整理的AWS考试例题。每个题目下都有评论和讨论，这里也是检查复习成果、查漏补缺的好去处。

**资料**

SAP认证并没有AWS官方的备考指南之类的资料，更多是需要自己基于个人情况复习。个人经验而言，下面几种形式的复习资料比较有效：

- SAP认证视频教程
  
    [A Cloud Guru](https://acloud.guru)和[Linux Academy](https://linuxacademy.com/)均有相关视频教程。通过这些视频教程，快速了解AWS各种服务、以及每个服务的功能要点，还是比较有效的。

- 各个服务的FAQ文档，高度浓缩的介绍每个服务
- 各个服务的开发文档。
  
    内容详实，但看起来也非常耗时，比较适合深入了解服务功能细节。对于AWS的核心服务，可以快速通读开发文档。

- AWS白皮书
  
    比如AWS well-architected framework, big data, data storage, migration等相关主题的白皮书

- [AWS官方博客](https://aws.amazon.com/blogs/architecture/)
  
    个别功能通过看文档，很难理解如何正确使用。博客里面的文章都是基于一个具体的场景，给出解决方案。比如[One to many: Evolving VPC design](https://aws.amazon.com/blogs/architecture/one-to-many-evolving-vpc-design/), 介绍了不同场景下VPC的不同设计方案。这篇文章，既可以作为VPC设计相关知识的总结，也可以做查漏补缺之用。

- [AWS官方样题](https://d0.awsstatic.com/training-and-certification/docs/AWS_certified_solutions_architect_professional_examsample.pdf)以及[www.examtopics.com](https://www.examtopics.com/)。

    通过样题，熟悉考题类型，以及查漏补缺。

<br/>

### 考试预约

SAP考试费用是$300， 考试时间为180分钟， 总计70个选择题，分数达到750分才能通过考试，也就是说每个题目两分钟半的答题时间。鉴于SAP题目的长度，2分半的答题时间还是非常紧张的。考试为机考，提交答案现场就可以得到考试结果。

如果选择考试语言为英语，对于母语非英语的考生，在预约考试前，可以申请一个30分钟的[额外加时](https://www.certmetrics.com/amazon/candidate/exam_accommodations_default.aspx)。申请完加时后，可以在预约考试时，选择使用额外加时, 考试时间会响应延长至210分钟。

<br/>

### 考试

我所选择的考点，考试在一个密闭的小房间内，布置有3台电脑，房间内有摄像头监控。进入考试前，会有严格的检查，除了证件和考场准备的白板外,其余物品都不准带入。注意：只有白板和笔，没有板擦。期间我要求给个板擦，工作人员回复只能换新白板，严苛程度简直令人发指。中间有需要去卫生间的话，可以举手示意。

答题结束后，还会有几个调查问卷问题，所以要注意预留几分钟时间给问卷调查。

最终提交后，系统会立即给出考试结果。具体考试分数会在5个工作日内，通过邮件的方式通知。另外，从[AWS Training](https://aws.training)系统，也可以查看具体考试分数。

<br/>

### 其他

- [专家级解决方案架构师认证介绍](https://aws.amazon.com/certification/certified-solutions-architect-professional/)
- [考试指南](https://d1.awsstatic.com/training-and-certification/Docs%20-%20Cloud%20Practitioner/AWS_Certified_Cloud_Practitioner-Exam_Guide_EN_v1.6.pdf)
- [AWS Training](https://aws.training)
- [AWS官方样题](https://d0.awsstatic.com/training-and-certification/docs/AWS_certified_solutions_architect_professional_examsample.pdf)
- [例题以及讨论](https://www.examtopics.com/)

<br/>
