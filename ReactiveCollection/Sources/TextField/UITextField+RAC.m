//
//  UITextField+RAC.m
//  ReactiveCollection
//
//  Created by Paweł Sękara on 31.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

#import "UITextField+RAC.h"
#import <objc/runtime.h>
#import <ReactiveUIBindings/ReactiveUIBindings-Swift.h>

@implementation UITextField (RAC)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = [self class];
        
        Method originalMethod = class_getInstanceMethod(clazz, @selector(setDelegate:));
        Method swizzledMethod = class_getInstanceMethod(clazz, @selector(rac_setDelegate:));
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)rac_setDelegate:(id<UITextFieldDelegate>)delegate {
    if (self.delegate != nil) {
        if ([self.delegate isKindOfClass:TextFieldDelegateProxy.class] && (![delegate isKindOfClass:TextFieldDelegateProxy.class])) {
            ((TextFieldDelegateProxy *) self.delegate).forwardDelegate = delegate;
        } else if (![self.delegate isKindOfClass:TextFieldDelegateProxy.class] && ([delegate isKindOfClass:TextFieldDelegateProxy.class])) {
            ((TextFieldDelegateProxy *) delegate).forwardDelegate = self.delegate;
            [self rac_setDelegate:delegate];
        }
    } else {
        [self rac_setDelegate:delegate];
    }
}

@end
