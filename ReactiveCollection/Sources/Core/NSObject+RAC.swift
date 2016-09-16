//
//  NSObject+RAC.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 16.09.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result


public extension NSObject {
    private struct AssociatedKeys {
        static var lifetimeToken = "lifetimeToken"
    }
    
    var methodsAndSelectors: (UnsafeMutablePointer<Method?>?, [String]) {
        var outCount: UInt32 = 0
        let forwardMethods = class_copyMethodList(type(of: self), &outCount)
        var forwardMethodStrings: [String] = []
        for i in 0 ..< Int(outCount) {
            forwardMethodStrings.append(String(describing: method_getName(forwardMethods?[i])))
        }
        
        return (forwardMethods, forwardMethodStrings)
    }
    
    
    fileprivate var rac_lifetimeToken: Lifetime.Token {
        guard let token = objc_getAssociatedObject(self, &AssociatedKeys.lifetimeToken) as? Lifetime.Token else {
            let token = Lifetime.Token()
            objc_setAssociatedObject(self, &AssociatedKeys.lifetimeToken, token, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return token
        }
        return token
    }
    
    fileprivate func rac_values(forKeyPath: String) -> SignalProducer<Any?, NoError> {
        var observers: NSMutableDictionary
        //TODO: finish implementation of valueforkeypath
    }
    
    
}

extension Reactive where Base: NSObject {
    
//    public func values(forKeyPath: String) -> SignalProducer<Any?, NoError> {
//        
//    }
    
//    public func values(forKeyPath: String) -> SignalProducer<AnyObject?, NoError> {
//        
////        return SignalProducer { obs, dis in
////            
////        }
//        return SignalProducer.empty
//    }
    
    public var lifetime: Lifetime {
        return Lifetime(self.base.rac_lifetimeToken)
    }
}


internal final class KVObserver: NSObject {
    private struct Context {
        static var context = "keyPath"
    }
    
    fileprivate var rac_value = MutableProperty<Any?>(nil)
    
    unowned let object: AnyObject
    let keyPath: String
    
    init(object: AnyObject, keyPath: String) {
        self.object = object
        self.keyPath = keyPath
        
        super.init()
        
        self.object.addObserver(self, forKeyPath: self.keyPath, options: [.new, .initial], context: &Context.context)
    }
    
    deinit {
        self.object.removeObserver(self, forKeyPath: self.keyPath, context: &Context.context)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &Context.context {
            self.rac_value.value = object
        }
    }
    
}
