//
//  DelegateProxy.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 10.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ObjectiveC.runtime
import ReactiveCocoa

public protocol DelegateProxyType {
    static func associatedProxy(object: AnyObject) -> AnyObject?
    static func setAssociatedProxy(proxy: AnyObject, to object: AnyObject)
    static func createProxy(forObject object: AnyObject) -> AnyObject
}

public extension DelegateProxyType {
    
    public static func proxy(forObject object: AnyObject) -> Self {
        if let proxy = Self.associatedProxy(object) as? Self {
            return proxy
        }
        
        let createdProxy = Self.createProxy(forObject: object)
        guard let returnVal = createdProxy as? Self else {
            fatalError("Could not cast proxy to required type")
        }
        
        Self.setAssociatedProxy(createdProxy, to: object)
        
        return returnVal
    }
    
}

public class DelegateProxy: NSObject, DelegateProxyType {
    private struct AssociatedKeys {
        static var rac_delegateProxyKey = "rac_delegateProxyKey"
    }
    
    public weak var forwardDelegate: NSObject? 
    
    public class func associatedProxy(object: AnyObject) -> AnyObject? {
        return objc_getAssociatedObject(object, &AssociatedKeys.rac_delegateProxyKey)
    }
    
    public class func setAssociatedProxy(proxy: AnyObject, to object: AnyObject) {
        objc_setAssociatedObject(object, &AssociatedKeys.rac_delegateProxyKey, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public class func createProxy(forObject object: AnyObject) -> AnyObject {
        fatalError("Abstract function, should not be used directly")
    }
}
