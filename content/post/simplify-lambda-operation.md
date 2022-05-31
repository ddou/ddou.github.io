---
title: "从丑到美： 简化 Lambda 操作"
date: 2022-05-28T18:01:31+08:00
tags: ["重构", "代码匠艺", "java"]
keywords: ["重构", "代码匠艺", "java"]
description: "分享了一个重构的具体过程，把一段使用了 Java 8 Stream API 和 Lambda 的具有明显坏味道的代码通过一系列重构操作，优化为可读性更高的代码。"
---

作为软件工程师， 工作的大部分时间我都在写代码，或者阅读别人的代码。期间，看到过许多优雅的代码，也见过糟糕的实现。 这个代码匠艺系列会分享一些优雅的实现，以及代码重构的经历。

本篇为该系列的第一篇。

Java 8 为集合类操作引入了 Stream。 可以创建 Stream 或者将集合类转化为 Stream 实例，通过传入 Lambda 表达式实现一系列的过滤、转化操作。理想情况下，Stream 和 Lambda 相结合可以写出清晰易懂的代码。但现实情况并非总是如此。比如下面这段代码：

```java
    private String renderPipelineScript(JenkinsPipeline pipeline) {
        PipelineScript pipelineScript = pipeline.renderScript();
        pipelineScript.setExecutionRule(nonNull(pipeline.getExecutionRule()) ? pipeline.getExecutionRule() : "STOP");
        ofNullable(pipelineScript.getStages()).ifPresent(stages -> stages.forEach(stage -> {
            stage.setQualityGateType(isNull(stage.getQualityGateType()) ? LanguageType.Maven : stage.getQualityGateType());
            stage.setQualityGateContainer(isNull(stage.getQualityGateContainer()) ? "maven:3.8.4-jdk-11" : stage.getQualityGateContainer());
            ofNullable(stage.getSteps()).ifPresent(steps -> steps.forEach(this::renderStepScript));
        }));
        return ciScriptTemplateHelper.renderPipelineScriptByTemplate(pipelineScript, "pipeline-script.ftl");
    }
```

不难看出，这段代码是在一个持续集成流水线的限界上下文内，有一个 Pipeline 的模型大致如下。这段代码在将 Pipe 模型定义的流水线转化为 Jenkins 的流水线配置文件。

![pipeline-refactoring](/image/pipeline-refactoring.png)

代码逻辑并不复杂，但阅读起来多少还是有些障碍，不够顺畅：

1. 嵌套的 `Optional`，`isPresent`, `forEach` 操作
2. `stage`的`forEach`内 lambda 操作略显复杂，不太能清晰。

下面就对上述代码做简单重构，以简化其阅读障碍，使之更清晰易懂。

1. 避免不必要的空检查
   从上下文代码得知`pipeline.renderScript()`执行中要么直接抛出异常，要么正常返回，所以该方法内可以不考虑`pipelineScript`为空的场景，null 检查的部分可以删掉。另外，对于`pipelinescript.getStage()`和`stage.getSteps()`这两个方法，可以修改其行为在空时返回空列表，而不是`Null`。如此，我们可以将代码简化到如下：

```java
private String renderPipelineScript2(JenkinsPipeline pipeline) {
    PipelineScript pipelineScript = pipeline.renderScript();
    pipelineScript.setExecutionRule(nonNull(pipeline.getExecutionRule()) ? pipeline.getExecutionRule() : ExecutionRule.STOP);
    pipelineScript.getStages().forEach(stage -> {
        stage.setQualityGateType(isNull(stage.getQualityGateType()) ? Maven : stage.getQualityGateType());
        stage.setQualityGateContainer(isNull(stage.getQualityGateContainer()) ? "maven:3.8.4-jdk-11" : stage.getQualityGateContainer());
        stage.getSteps().forEach(step -> renderStepScript(step, stage.getId()));
    });
    return ciScriptTemplateHelper.renderPipelineScriptByTemplate(pipelineScript, "pipeline-script.ftl");
}
```

2. 简化 Optional 替换默认值职责逻辑
   上述代码中，通过使用判空以及三元运算符设置默认值，可以修改为使用`Optional.orElse`来实现，这种声明式的写法更直观，也避免判断反转的错误。调整后代码如下：

```java
private String renderPipelineScript2(JenkinsPipeline pipeline) {
    PipelineScript pipelineScript = pipeline.renderScript();
    pipelineScript.setExecutionRule(ofNullable(pipeline.getExecutionRule()).orElse(ExecutionRule.STOP));
    pipelineScript.getStages().forEach(stage -> {
        stage.setQualityGateType(ofNullable(stage.getQualityGateType()).orElse(Maven));
        stage.setQualityGateContainer(ofNullable(stage.getQualityGateContainer()).orElse("maven:3.8.4-jdk-11"));
        stage.getSteps().forEach(step -> renderStepScript(step, stage.getId()));
    });
    return ciScriptTemplateHelper.renderPipelineScriptByTemplate(pipelineScript, "pipeline-script.ftl");
}
```

3. 简化 Lambda 表达式
   虽然 Java 引入 Lambda 后可以将一个代码片段作为 lambda 传入，但从可读性的角度考虑，建议 Lambda 的行数不要超过一行。2 行以及以上的 Lambda 表达可以提取为一个方法、或者定义为局部变量。并且给方法和局部变量合理的命名。

上例中 Lambda 虽然只有三行，但却包含了 2 个职责 1. 给 `stage` 的`qualityGate`设置默认值 2. 渲染`stage`内的每个`step`

首先，我们把职责 1 相关逻辑提取为独立方法：

```java
private void ensureQualityGateDefaults(Stage stage) {
    stage.setQualityGateType(ofNullable(stage.getQualityGateType()).orElse(Maven));
    stage.setQualityGateContainer(ofNullable(stage.getQualityGateContainer()).orElse("maven:3.8.4-jdk-11"));
}
```

​ 然后，把 Lambda 内的两个职责拆分开来，并且使用方法引用来调用`renderStepScript`代码调整后如下：

```java
private String renderPipelineScript(JenkinsPipeline pipeline) {
    PipelineScript pipelineScript = pipeline.renderScript();
    pipelineScript.setExecutionRule(ofNullable(pipeline.getExecutionRule()).orElse(ExecutionRule.STOP));
    pipelineScript.getStages().forEach(this::ensureQualityGateDefaults);
    pipelineScript.getStages().stream().map(Stage::getSteps).forEach(this::renderStepScript);
    return ciScriptTemplateHelper.renderPipelineScriptByTemplate(pipelineScript, "pipeline-script.ftl");
}
```

4. 设置 QualityGate 项目默认值职责移至模型
   `renderPipelineScript`以及其所在的类职责在于将模型定义的流水线渲染为 Jenkin 流水线定义。代码中 QualityGate 相关默认值设置的职责不应该跟渲染相关逻辑耦合在一起。所以上一步中我们提取的`ensureQualityGateDefaults`应该定义在`Stage`类中。我们可以使用移动方法重构手法，将其移到合理的位置。最终代码如下：

```java
private String renderPipelineScript(JenkinsPipeline pipeline) {
    PipelineScript pipelineScript = pipeline.renderScript();
    pipelineScript.setExecutionRule(ofNullable(pipeline.getExecutionRule()).orElse(ExecutionRule.STOP));
    pipelineScript.getStages().forEach(Stage::ensureQualityGateDefaults);
    pipelineScript.getStages().stream().map(Stage::getSteps).forEach(this::renderStepScript);
    return ciScriptTemplateHelper.renderPipelineScriptByTemplate(pipelineScript, "pipeline-script.ftl");
}
```

经过以上步骤，最终代码变的更容易阅读了。我们能更清晰的看到在 `render` 前的准备数据阶段，完成了 3 件事情：

- 设置`executionRule`默认值
- 设置每个`stage`的`QualityGate` 默认值
- 渲染每个`step`

阅读时，也不用假装自己是人肉编译器，需要在脑子里模拟执行才能知道完成了什么操作。

本次重构中值得分享的几点小技巧：

1. 方法的返回值避免返回`null`。如果返回值为集合类型，可以返回空集合；如果是单个值，可以返回`Optional`。
2. 作为参数的 Lambda 如果超过 2 行，可以考虑提取为方法，或者为之定义局部变量，通过合理的命名表达操作意图。
3. `Optional.orElse`这种声明式的写法，在某些场景下替换`?:`三元运算符可以更直观，而且可以避免判断逻辑反转的错误。
