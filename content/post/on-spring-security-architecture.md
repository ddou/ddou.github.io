---
title: "简析Spring Security"
date: 2022-05-13T16:42:02+08:00
publishdate: 2022-05-13
lastmod: 2022-05-13T16:42:02+08:00
tags: ["Java", "Spring", "Spring Security"]
keywords: ["Spring", "Spring Security", "Architecture"]
description: "简要介绍 Spring Security 实现机制"
---

Spring Security 提供了灵活简便的方式进行服务安全相关的配置。如下，只需要简单几行代码即可完成一个基于 JWT Token 的 API 服务的认证设置：

```java
@Configuration
public class SecurityConfiguration extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
                .antMatchers("/api/login").permitAll()
                .anyRequest().authenticated()
                .and()
                .addFilterAt(new JWTAuthFilter(), BasicAuthenticationFilter.class);
    }
}

```

​ 上述配置允许/api/login 匿名访问，其他所有 endpoint 都必须通过身份认证后使用。身份认证基于 JWT Token 实现， JWTAuthFilter 负责验证请求头中是否包含有效的身份认证信息。

​ 那么 Spring Security 提供灵活强大的配置方式背后，具体是怎么工作的呢？ 上述寥寥几行代码背后隐藏着哪些魔法呢？下面首先我们从 Spring Securtiy 的工作机制聊起。

## Spring Security 工作机制

​ Spring Security 对 Servlet 的安全实现时基于 Servlet `Filter` 实现的。首先，我们来看下一个典型的请求处理流程：

![filterchain](/image/filterchain.png)

SpringMVC 应用在在处理 Web 请求时，会创建一个`FilterChain`，包含了一些列的 Filter 和与该请求 URI 匹配的 Servlet （`DispatcherServlet`）。 Spring Security 通过在处理请求的 `FilterChain` 中插入 security 相关的 `Filter` 来实现其功能：

1. Spring 提供的一个 Filter 实现 `DelegatingFilterProxy`，可以作为一个标准的 Filter 在 Servelt 容器生命周期内注册，并将具体工作细节委托给实现了 Filter 接口的 Spring bean。
2. `DeletagtingFilterProxy` 将具体工作委托给 `FilterChainProxy`。 `FilterChainProxy` 是 Spring Security 提供的一个 Filter 实现，封装了用户定义的 Security 规则。
3. `FilterChainProxy` 内包含了多个 `SecurityFilterChain` 实例。每个 `SecurityFilterChain` 会匹配对应的请求。每个请求只会第一个匹配的 `SecurityFilterChain` 处理。
4. 每个 `SecurityFilterChain` 内包含多个 Filter。Filter 中包含了具体的认证和授权相关逻辑。

![multi securityfilterchain](/image/multi-securityfilterchain.png)

针对本文开头的 API 的安全配置，实际的结构如下。

![sample-filter-chain](/image/sample-filter-chain.png)

Spring Security 生成了一个 `SecurityFilterChain`。该 `SecurityFilterChain` 内包含了 多个 Filter。其中 `FilterSecurityInterceptor`是基于下述 2 行 代码生成。

```java
http.authorizeRequests()
  .antMatchers("/api/login").permitAll()
  .anyRequest().authenticated()
```

其中的 JWTAuthFilter 则是通过创建 JWTAuthFilter 实例配置的。

```java
  .and()
    .addFilterAt(new JWTAuthFilter(), BasicAuthenticationFilter.class);
```

为了支撑 Spring Security 灵活且强大的配置方式，其 `SecurityFilterChain` 的构建过程也颇有意思。下一篇介绍下 `SecurityFilterChain`的构建过程。

## 参考

- [Spring Security Reference](https://docs.spring.io/spring-security/site/docs/5.4.6/reference/html5/#servlet-architecture)
