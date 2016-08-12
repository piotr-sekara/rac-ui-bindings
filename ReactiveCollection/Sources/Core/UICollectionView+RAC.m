//
//  UICollectionView+RAC.m
//  ReactiveCollection
//
//  Created by Paweł Sękara on 11.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

#import "UICollectionView+RAC.h"
#import <objc/runtime.h>
#import "ReactiveCollection-Swift.h"

@implementation UICollectionView (RAC)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = [self class];
        
        Method originalMethod = class_getInstanceMethod(clazz, @selector(setDataSource:));
        Method swizzledMethod = class_getInstanceMethod(clazz, @selector(rac_setDataSource:));
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
    });
}

- (void)rac_setDataSource:(id<UICollectionViewDataSource>)dataSource {
    [RACDataSourceProxy displayWarningsIfNeeded:self.dataSource
                                  newDataSource:dataSource];
    
    [self rac_setDataSource:dataSource];
}

@end
