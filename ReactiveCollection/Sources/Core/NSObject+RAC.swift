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
import ReactiveCocoa


public extension NSObject {
    private struct AssociatedKeys {
        static var lifetimeToken = "lifetimeToken"
        static var observers = "observers"
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
    
}

extension Reactive where Base: NSObject {
    
    public func values(forKeyPath: String) -> SignalProducer<AnyObject?, NoError> {
        return self.base.values(forKeyPath: forKeyPath)
    }
    
    public var lifetime: Lifetime {
        return self.base.rac_lifetime
    }
}
