# KVO 的使用及其本质

## 1.KVO 的概念

- KVO 的全称: `key-Value Observing`.
- KVO 的作用: 用来监听某个对象`属性值`的改变.

## 2.KVO 的简单使用

点击控制器的 view, 监听某个对象属性的改变.如下:

- TYPerson 对象,属性 `name`

```objc
@interface TYPerson : NSObject

@property (nonatomic, copy) NSString *name;

@end
```

- 在控制器中对其强引用后,设置 name 初始值为`mty`.并对其`name`属性进行 KVO 监听.

```objc

#define TYPERSON_KEYPATH_FOR_PERSON_Name_PROPERTY @"name"
#define TYPERSON_CONTEXT_FOR_PERSON_Name_PROPERTY @"personNameProperty_Context"

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    TYPerson *person = [[TYPerson alloc] init];
    self.person = person;
    person.name = @"mty";
    
    /**
     * 对 person 对象设置当前控制器监听其属性 name 的变化.
     * 如果属性 name 发生变化,就会调用控制器的 observeValueForKeyPath: ofObject: change: context 方法. 
     */
    [person addObserver:self forKeyPath:TYPERSON_KEYPATH_FOR_PERSON_Name_PROPERTY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:TYPERSON_CONTEXT_FOR_PERSON_Name_PROPERTY];
    
}
```

- 点击控制器的 view, 改变`name`属性的值

```objc
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.person setName:@"mty-God"];
    
}
```

- 查看监听变化的结果.

```objc
// 监听方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == TYPERSON_CONTEXT_FOR_PERSON_Name_PROPERTY) {
        NSLog(@"监听到%@属性的改变:%@",object,change);
    }
}
```

- 打印结果

```objc
监听到<TYPerson: 0x600000200440>属性的改变:{
    kind = 1;
    new = "mty-God";
    old = mty;
}

```

