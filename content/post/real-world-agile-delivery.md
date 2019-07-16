---
title: "功能π的敏捷之旅"
date: "2017-08-22T17:58:10+08:00"
comments: true
tags: ["Agile"]
---

本文里会以一个功能 π 的开发流程为例，展示公司内一个敏捷团队的软件开发实践。

## 项目背景

客户 R 是澳洲最大的在线房地产广告平台。公司团队是协助 R 客户创建一个针对中国市场的房产信息广告平台，用来展示澳洲以及其他海外房产，方便国内投资者。

作为一个全功能的交付团队，整个团队的人员一共 11 人，成员包括 TL _ 1、BA _ 1、UX _ 1、QA _ 1、Ops _ 1、Dev _ 6。客户方面 Delivery Lead _ 1 和 Product Owner _ 1, 两人都在澳洲。

客户负责提供项目的 Roadmap，优先级以及初步的需求。后续由公司开发团队完成从需求分析、交互设计、功能设计、实现、测试、以及部署上线的全生命周期的工作。

## 功能 π 的敏捷之旅

下面以一个功能 π 的开发流程为例，展示笔者所在项目的开发实践。

### 计划

项目的路线图 Roadmap 是由 Trello 来管理的。Epic 需求会由客户 PO 记录在 Trello 中。Trello board 中设置的有不同的列，如 Backlog, Planned, Next, In progress, Completed 等。每列中卡片由上而下代表优先级的递减。Trello board 作为项目 high level 需求的管理工具，可以很直观的了解项目整体的进展状况。

每两周全团队会进行一次计划会议，类似 IPM，但是主要是根据 Roadmap 上的优先级，确定近期的开发计划。最终的输出是一个具体的 task 列表。其中会包括:

- 当前进行中的任务
- 新加入的功能 π
- 需要 fix 的 bug
- 技术卡

计划会议上会把上述列表中的任务逐个讨论，目的是团队对于近期的优先级有一致的认识，以及对每个任务的内容做澄清。

团队 JIRA 作为需求管理工具，并同时使用物理 Kanban 墙以方便站会时讨论。计划会议中计划的任务会在 JIRA kanban board 中挪至 Selected for Dev 列。

对于新功能 π 而言，PO 首先会在 Trello 上创建卡，并设置优先级。开发团队会按照优先级将功能 π 计划到后续的开发中。

### 需求来了

功能 π 开发的第一步就是由 BA 对客户提供的需求进行进一步的分析、细化、澄清和确认。如果功能 π 还涉及到用户交互，UX 也会参与到这一步。UX 会基于 BA 的分析，对信息流进行梳理，完成用户界面和交互设计。最终的输出结果为 Jira 上的用户故事。

用户故事一般遵从 As...I want...so that 的格式。在用户故事的内容上，一般会包含下面信息：

- 描述信息： 关于功能 π 的描述，提供更多的上下文信息
- 验收标准(Acceptance Criteria)
- 完成定义(Definition of Done)
- UI 相关设计文档

另外一些信息会在后续环节持续补充上去，如分解的子任务，受影响的模块，需要部署的模块等。

分析完成的用户故事卡片会被挪至 Ready for Dev 列，后续会有开发着手开发。

### Story Kickoff

开发人员在开始一个新的任务前，会首先进行 story kickoff。这个环节主要目标是大家对功能有正确的认识，同时避免技术坑，简言之就是确保在以正确的方式做正确的事情。kickoff 环节会有 QA，Dev, BA, UX 以及 TL 共同参与。在 kickoff 中，Dev 会首先介绍当前自己对这个功能的理解，用户如何与系统进行交互，如何验证功能完成、以及技术实现。如果是一对 Pair 在 kickoff，一般会有经验较少的 Dev 来进行介绍。

![](https://ws1.sinaimg.cn/large/5ee78c28ly1g4soiapifjj23402c0b2a.jpg)

Story kickoff 成功后，Dev 会对功能 π 进行任务分解，并按照优先级以及依赖关系排列子任务开发顺序。任务分解的结果也会更新到用户故事中，一般会在用户故事卡下建立子任务，方便追踪进度。

### 结对编程

团队一般采用结对编程(Pair programming)的方式进行开发。结对编程的优点在于快速的知识传递，无论是对于刚进入团队的新人，还是刚接触某个模块的老鸟，业务知识还是编程技能。

![](https://ws1.sinaimg.cn/large/5ee78c28ly1g4soi6z24yj210e0peu0x.jpg)

在功能 π 的开放中，这对 Pair 中的两个 Dev 会以 TDD 的方式，合作完成业务代码和测试代码的实现。测试部分包括单元测试和自动化验收测试两部分。对于验收测试的部分，Dev 有时也会和 QA 一起 pair 完成验收测试脚本的编写。

团队中也会周期性的轮换 pair，这样每个人都有机会接触到不同的模块，使得业务知识在团队内更好的传递。

### 每日站会

团队每天会使用 Always On Video 和客户一起进行站会，更新项目的进展。

![](https://ws1.sinaimg.cn/large/5ee78c28ly1g4soi6a6o1j21p414o14u.jpg)

在站会中，每个人/Pair 会更新一下三个方面的内容：

- 上一个工作日的工作内容
- 遇到哪些技术挑战，有没有风险？
- 今天的工作计划

同时，团队会更新 Kanban 物理墙上功能 π 的状态。

### 持续集成

持续集成目前应该已经是软件开发的标配实践了，什么？你的团队还没？

![](https://ws1.sinaimg.cn/large/5ee78c28ly1g4soi5aakoj210e0hfq97.jpg)

功能 π 的新代码每天都会多次提交到 git, 持续集成工具会自动检测代码提交，并触发构建流水线。流水线中的验证环节会自动执行测试，验证系统功能正常与否，将构建物发布到软件仓库, 并最终将最新版本软件部署至测试环境。

### Code Review

每个工作日的 5 点至 6 点是 code review 时间。这个环节所有的 Dev 会集中在大屏幕前，集中 review 当天提交到 git 的代码。code review 可以审查代码中的瑕疵，从基本的编码规范、代码坏味、明显的逻辑错误、以及功能实现上的疏漏等。同时，code review 也是很好的 knowledge transfer 的方式。

![](https://ws1.sinaimg.cn/large/5ee78c28ly1g4soic0m4fj22io1w0b2a.jpg)

### Story Signoff

Dev 完成功能 π 的开发后，会邀请 BA，QA，UX 和 TL 进行 story signoff。Dev 会在本地或者测试环境中准备好测试数据，向参与 Signoff 的各位同事演示功能。期间，QA 会要求 Dev 按照多个测试场景进行多次演示，以确保功能基本完整。UX 也会按照设计 Mockup 对功能实现进行比对，确保在各个屏幕尺寸下显示符合设计。

Signoff 通过后，Dev 会更新 kanban 墙上功能 π 对应的故事卡的状态至 Ready for QA。

### QA

QA 会从看板墙的 Ready for QA 列中将功能 π 对应的故事卡更新至 In QA, 并在测试环境中按照设计的测试用例进行验证。

如果发现功能问题，会记录至功能 π 的故事卡，并交由 Dev 修复，并再次 Signoff 后，继续 QA 环节。

验证无误的话，功能 π 会被部署到预生产环境（Staging 环境）。这样客户可以在预生产环境对功能进行 review。

最终，π 的故事卡会被挪至 Ready for Release，并在下次上线时部署至生产环境。

### 部署上线

团队的持续集成流水线中包含了部署上线的阶段。如前所述，每次构建成功，都会将最新的软件版本部署至测试环境。发布到预生产环境和生产环境会按照项目和业务要求，手动触发。

对于暂时不需要发布上线的功能，如需要等待销售或市场部门配合，团队会使用功能开关(Feature Toggle)，将新版本部署至生成环境，但并不上线新功能。

![](https://ws1.sinaimg.cn/large/5ee78c28ly1g4soigrk0qj21dc0sekjm.jpg)

另外，在部署流水线中，也集成了一部分的自动测试。当新版本在预生产环境和生产环境部署完成，但并未正式切换前，这些自动测试会被执行，以确保系统功能正常。

![](https://ws1.sinaimg.cn/large/5ee78c28ly1g4soi4se5bj20s60ipq4w.jpg)

至此，功能 π 就完成了它的敏捷之旅，成功上线！