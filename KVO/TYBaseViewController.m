//
//  TYBaseViewController.m
//  KVO
//
//  Created by 马天野 on 2018/8/16.
//  Copyright © 2018年 Maty. All rights reserved.
//

#import "TYBaseViewController.h"
#import "TYPerson.h"

#define TYPERSON_KEYPATH_FOR_PERSON_Age_PROPERTY @"age"
#define TYPERSON_CONTEXT_FOR_PERSON_Age_PROPERTY @"personAgeProperty_Context"

@interface TYBaseViewController ()

@property (nonatomic, strong) TYPerson *person;
@property (nonatomic, strong) TYPerson *person2;

@end

@implementation TYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    TYPerson *person = [[TYPerson alloc] init];
    self.person = person;
    person.age = 10;
    
    TYPerson *person2 = [[TYPerson alloc] init];
    person2.age = 15;
    self.person2 = person2;
    
    [person addObserver:self forKeyPath:TYPERSON_KEYPATH_FOR_PERSON_Age_PROPERTY options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:TYPERSON_CONTEXT_FOR_PERSON_Age_PROPERTY];
    
}

- (void)dealloc
{
    [self.person removeObserver:self forKeyPath:TYPERSON_KEYPATH_FOR_PERSON_Age_PROPERTY];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.person setAge:20];
    
    [self.person2 setAge:30];
}

// 监听方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == TYPERSON_CONTEXT_FOR_PERSON_Age_PROPERTY) {
        NSLog(@"监听到%@属性的改变:%@",object,change);
    }
}

@end
