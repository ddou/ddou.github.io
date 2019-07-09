---
title: "一个NullPointerException引发的思考"
date: 2014-10-26T16:19:35+08:00
tags: ["java"] 
---

近日在做项目中导出功能的重构，在中间执行单元测试验证功能时，出现一个java.lang.NullPointerException。这个异常对于每日与Exception和Bug打交道的同学们来说，是再熟悉不过的了。NullPointerException，亦即空指针异常，这是当在一个null对象上调用某个方法引起的。按图索骥，定位了产生异常的那行代码。错误信息和代码如下所示（写了个简单的，方便演示）：

```java
Exception in thread "main" java.lang.NullPointerException
    at BuildingFeatures.getBedRooms(BuildingFeatures.java:8)
    at Test.main(Test.java:4)
```

```java
    System.out.printl(buildingFeatures.getBedrooms());
```

### 分析
根据经验来讲，这无疑是讲buildingFeatures这个变量是null。于是乎，设断点，重新执行测试，让我意外的是buildingFeatures竟然不是null？WTF？一瞬间，我陷入了陈思、迷茫，多年编程构建起来的世界观，价值观开始慢慢地松动、塌陷。


时间还在继续，无奈，虽然简单如一个getter方法，还是跟进去一探究竟吧。BuildingFeatures只是一个简单的类，典型的贫血模型，除了几个field，默认构造函数，以及对应的getter和setter，再无其他了。

```java
public class BuildingFeatures {
    private Integer bedRooms;

    public BuildingFeatures() {
    }

    public int getBedRooms() {
        return bedRooms;
    }

    public void setBedRooms(Integer bedRooms) {
        this.bedRooms = bedRooms;
    }
}
```

狐狸再狡猾，也逃不过猎人的眼睛，终于还是被我发现了问题之所在。问题出在了getter的返回值上。getter返回的是一个int，原始类型，而bedRooms这个field的类型是Integer，在getter内会进行类型的转换，也就是所谓的“拆箱”。要将一个null的Integer值拆箱，抛出一个NullPointerException也就不足为奇了。那getter中具体执行了哪些操作导致这个NullPointerException呢？ 我们还是从编译产生的bytecode中一探究竟吧。

### 深入分析

javap是一个用来反编译java类文件的小工具，在java的默认安装中有提供。通过如下命令可以看下getter中都执行了哪些操作：

```
javap -c out/production/untitled/BuildingFeatures.class
```

以下是输出：

```
public class BuildingFeatures {
  public BuildingFeatures();
    Code:
       0: aload_0
       1: invokespecial #1       // Method java/lang/Object."<init>":()V
       4: return

  public int getBedRooms();
    Code:
       0: aload_0
       1: getfield      #2       // Field bedRooms:Ljava/lang/Integer;
       4: invokevirtual #3       // Method java/lang/Integer.intValue:()I
       7: ireturn

  public void setBedRooms(java.lang.Integer);
    Code:
       0: aload_0
       1: aload_1
       2: putfield      #2       // Field bedRooms:Ljava/lang/Integer;
       5: return
}
```

我们注意下上述代码片段中getBedRooms方法的实现：

1. aload_0 从当前的frame的局部变量数组中加载第一个变量至当前frame的操作数栈。对于实例方法调用来说，aload_0就是加载当前对象，亦即‘this’。
2. getfield，操作数栈出栈，获取出栈对象的field值，并入栈
3. invokevirtual，操作数栈出栈，在出栈对象上执行实例方法调用，本例中也就是执行了Integer.intValue()方法调用。
4. ireturn，返回int值。

从上面的分析可以看出，我们在第二步时，返回的是一个值为null的Integer类型的变量。然后，在第三部，在该Integer变量上执行intValue()方法时，抛出了NullPointerException。

至此，真相大白。

### 思考

为什么会选择Integer作为bedRooms这个field的类型呢？其原因是有业务决定的： 在将数据导出的过程中，我们希望只导出包含有效值的数据，针对bedRooms来讲，就是我们希望只有在bedRooms值大于1时才导出这个field。使用Integer而不是int作为field的类型，这样默认初始化BuildingFeatures后，bedRooms的值为null。然后使用Gson导出时，gson是基于field做导出，gson会忽略值为null的field，从而达到了不导出无效数据的业务需求。 在重构中，使用了另外的导出方式，期间会使用到getter方法，所以才暴漏出本文中的问题。

getting方法的返回值是int，竟然与field不一致，这个才是问题的原点。这或许只是作者意识的疏忽吧。

### 再思考

项目中，一直有持续进行Code Review，这样小而隐蔽而诡异的代码中的问题没有能被发现，的确是颇值的反思。Code Review频率不够，导致每次review太多代码，匆匆一扫而过，或许是其中一个需待改进之处。

另外，我料想这个getter方法必然是手写，而非IDE生成。 IDE自然是不会自己修改返回值类型的。照此来看，使用IDE生成诸如getter/setter之类的方法，除了效率之外还有另外一个好处，那就是避免手写可能引入的疏漏。

### 番外

buildingFeatures实例是null的情况，自然也会抛出NullPointerException，只是给出的调用堆栈信息不同。其实在IDE最初给出的异常信息中，已然定位了问题之所在（请注意给出的异常抛出的行号）。忍不住给[IntelliJ](https://www.jetbrains.com/idea/)点个赞！

只是在着手分析时，由于思维定势，按照自己的思路多走了些弯路罢了。惭愧啊！



