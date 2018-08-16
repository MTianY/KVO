# KVO 的使用及其本质

## 1.KVO 的概念

- KVO 的全称: `key-Value Observing`.
- KVO 的作用: 用来监听某个对象`属性值`的改变.

## 2.KVO 的简单使用

点击控制器的 view, 监听某个对象属性的改变.如下:

- TYPerson 对象,属性 `age`

```objc
@interface TYPerson : NSObject

@property (nonatomic, assign) int age;

@end
```

- 在控制器中对其强引用后,设置 age 初始值为`10`.并对其`age`属性进行 KVO 监听.

```objc

#define TYPERSON_KEYPATH_FOR_PERSON_Age_PROPERTY @"age"
#define TYPERSON_CONTEXT_FOR_PERSON_Age_PROPERTY @"personAgeProperty_Context"

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    TYPerson *person = [[TYPerson alloc] init];
    self.person = person;
    person.age = 10;
    
    /**
     * 对 person 对象设置当前控制器监听其属性 age 的变化.
     * 如果属性 age 发生变化,就会调用控制器的 observeValueForKeyPath: ofObject: change: context 方法. 
     */
    [person addObserver:self forKeyPath:TYPERSON_KEYPATH_FOR_PERSON_Age_PROPERTY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:TYPERSON_CONTEXT_FOR_PERSON_Age_PROPERTY];
    
}
```

- 点击控制器的 view, 改变`age`属性的值

```objc
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.person setage:20];
    
}
```

- 查看监听变化的结果.

```objc
// 监听方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == TYPERSON_CONTEXT_FOR_PERSON_Age_PROPERTY) {
        NSLog(@"监听到%@属性的改变:%@",object,change);
    }
}
```

- 打印结果

```objc
监听到<TYPerson: 0x600000200440>属性的改变:{
    kind = 1;
    new = 20;
    old = 10;
}

```

## 3.KVO 的实现原理

为了验证 KVO 的实现原理,我们又创建了一个 TYPerson 的实例对象, person2.但是并没有对 person2进行监听.其他代码逻辑同 person 一样.这时点击控制器的 view, 看到打印结果.`只有 person 设置监听的属性有打印变化的值.`

```objc
监听到<TYPerson: 0x6040000104d0>属性的改变:{
    kind = 1;
    new = 20;
    old = 10;
}
```

- 通过打印 person 实例对象和 person2 实例对象的 `isa 指针`.结果如下

```objc
(lldb) p self.person.isa
(Class) $0 = NSKVONotifying_TYPerson
  Fix-it applied, fixed expression was: 
    self.person->isa
(lldb) p self.person2.isa
(Class) $1 = TYPerson
  Fix-it applied, fixed expression was: 
    self.person2->isa
```

- person 对象因为设置了监听.其 isa 指针的指向变为`NSKVONotifying_TYPerson`这个类.
- person2 对象没有设置监听.其 isa 指针的指向仍就是 `TYPerson`

**结论1**

- 通过对比得出,设置监听的属性,其实例对象的 isa 指向会发生变化.

#### 3.1 NSKVONotifying_TYPerson这个类

- 这个类是在 person 实例对象的属性添加监听之后,在运行中由 Runtime 自动生成的一个类
- `NSKVONotifying_TYPerson`类是`TYPerson`的一个`子类`.
- 这个类的 class 对象中,包含了如下信息
    - isa
    - superclass
    - setAge: 方法
    - ...等等

#### 3.2 监听方法如何被调用的?

- 因为要调用 `setAge:` 这个对象方法, 所以 person 实例对象通过其`isa 指针`找到其对应的 class 对象
- age 属性被添加监听后.  运行中 person 的父类变成了 NSKVONotifying_TYPerson.
- 所以 isa 指针指向的 class 对象就是 NSKVONotifying_TYPerson 的 class 对象.
- 找到的 `setAge:` 对象方法是`NSKVONotifying_TYPerson`中的.
    - 而这个 `setAge:` 方法会来到`_NSSetIntValueAndNotify`这个方法中
    - `_NSSetIntValueAndNotify`这个方法的`伪代码`大致如下

    ```objc
    void _NSSetIntValueAndNotify() {
        [self willChangeValueForKey:@"age"];
        // 调用父类的 setAge:方法,真正的改变 age 的值
        [super setAge:age];
        // age 的值已确定被改变了
        [self didChangeValueForKey:@"age"];
    }
    
    - (void)didChangeValueForKey:(NSString *)key {
        // 在这个方法中,通知监听器,哪个属性值发生了变化.
    }
    ```
    
- 而没有添加监听的 person2 对象,其 isa 指针指向的仍是 TYPerson 这个类.



