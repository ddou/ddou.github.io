---
title: "RSpec优雅验证之Predicate Matcher"
date: 2014-03-08T22:44:00+08:00
comments: true
tags: ["Ruby", "Test"]
---

Ruby作为动态语言，以其灵活性在测试领域大放异彩。RSpec作为Ruby中使用最广泛的测试工具之一，实在是广大码农们居家旅行测试验证之必备神器。RSpec提供了强大灵活的验证器(mather)，使用这些验证器加上Ruby灵活的语法可以写出类似于自然语言的验证，例如：

~~~ruby
    result_list.should include(item)

    result.should equal(item)

    person.name.should == 'ddou'
~~~

上述验证写法自然看起来赏心悦目，但如下的写法就太不ruby了，估计rubyist看到了多少会有些反胃：
```ruby
    person.manager?.should be_true

    detail_view.toggleable?.should == true

    detail_view.has_photo?.should == true
```

对于上述验证，一个rubyist所喜闻乐见的验证写法应该是这样的：

```ruby
    person.should be_manager

    detail_view.should be_toggleable

    detail_view.should have_photo
```

这样的写法是不是看起来更自然，更符合人类自然语言的习惯？强大如RSpec者自然支持上述语法。RSpec提供了对Predicate Matcher的支持，即可以使用被验证对象自身提供的predicate方法作为验证器。 常见的predicate方法如Array.empty?，以及我们上面例子中的
Person.manager?，DetailView.toggleable?，DetailView.has_photo?等。



#### Predicate Matcher实现

下面我们就打开RSpec源码，看看Predicate Matcher是如何实现。

上例中我们并没有定义be_manager，be_toggleable方法，RSpec自然要依赖Ruby的强大元编程能力来实现魔法。打开rspec-expectation包下lib/rspec/matchers/method_missing.rb文件，我们可以看到如下逻辑：

```ruby
    def method_missing(method, *args, &block)
        return Matchers::BuiltIn::BePredicate.new(method, *args, &block) if method.to_s =~ /^be_/
        return Matchers::BuiltIn::Has.new(method, *args, &block) if method.to_s =~ /^have_/
        super
    end
```

以上例中be_manager为例，此情况下RSpec会创建一个Matchers::BuiltIn::BePredicate实例，should会使用该BePredicate来验证我们的期望值。下面我们顺藤摸瓜看下BePredicate是如何工作的：

- 解析出验证使用的Predicate方法的名字，$3返回即是。对于上例中be_manager，此处返回"manager"。

```ruby
    def prefix_and_expected(symbol)
      symbol.to_s =~ /^(be_(an?_)?)(.*)/
      return $1, $3
    end
```

- 将上述方法名字转化为实际使用的Predicate方法对应的符号（Symbol）。根据时态的不同，还会在Predicate方法名后添加s。

```ruby
    def predicate
        "#{@expected}?".to_sym
    end

    def present_tense_predicate
        "#{@expected}s?".to_sym
    end
```

- 调用上述方法，验证结果。从具体matches方法的实现来看， RSpec会首先尝试不加s的Predicate方法，如果失败才会继续尝试加s的方法。所以，我们的例子中，be_manager会首先使用manager？方法验证，如果失败会继续使用managers？方法验证。

```ruby
    def matches?(actual)
        @actual = actual
        begin
            return @result = actual.__send__(predicate, *@args, &@block)
        rescue NameError => predicate_missing_error
            "this needs to be here or rcov will not count this branch even though it's executed in a code example"
        end

        begin
            return @result = actual.__send__(present_tense_predicate, *@args, &@block)
        rescue NameError
            raise predicate_missing_error
        end
    end
```

HasPredicate的实现与BePredicate类似，此处不再累述。

到此，我们就了解了为什么下面这样的验证能正常工作了：

```ruby
    person.should be_manager

    detail_view.should be_toggleable

    detail_view.should have_photo
```

既然了解了RSpec的Predicate Matcher功能，你还会写出本文初列出的那种non-ruby的验证代码吗？








