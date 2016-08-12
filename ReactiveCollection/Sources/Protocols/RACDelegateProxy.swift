//
//  RACDataSourceProxy.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 10.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ObjectiveC.runtime
import ReactiveCocoa

public protocol RACDataSourceProxyType {
    static func associatedProxy(object: AnyObject) -> AnyObject?
    static func setAssociatedProxy(proxy: AnyObject, to object: AnyObject)
    static func createProxy(forObject object: AnyObject) -> AnyObject
}

public extension RACDataSourceProxyType {
    
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

public class RACDataSourceProxy: NSObject, RACDataSourceProxyType {
    private struct AssociatedKeys {
        static var rac_delegateProxyKey = "rac_delegateProxyKey"
    }
    
    public weak var forwardDataSource: NSObject? 
    
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

extension RACDataSourceProxy {
    
    public class func displayWarningsIfNeeded(selfDataSource: AnyObject?, newDataSource: AnyObject?) {
        if newDataSource is RACDataSourceProxy && !(selfDataSource is RACDataSourceProxy) && selfDataSource != nil {
            print("Warning: Binding dataSource with RAC will override one that is already set.")
            print("         Setting dataSource to nil before binding will silence this warning.")
        } else if selfDataSource is RACDataSourceProxy && newDataSource != nil {
            print("Warning: Setting dataSource will override RAC bindings.")
            print("         If you would like to keep RAC bindings and use other dataSource methods, please use forwardDataSource property instead.")
            print("         If you are sure you want to override RAC bindings, set dataSource to nil before setting new one.")
        }
    }
}

extension RACDataSourceProxy {
    class func optionalSelectorsFor(proto: Protocol) -> [String] {
        var outCount: UInt32 = 0
        let protocolMethods = protocol_copyMethodDescriptionList(proto, false, true, &outCount)
        var protocolMethodStrings: [String] = []
        for i in 0 ..< Int(outCount) {
            protocolMethodStrings.append(String(protocolMethods[i].name))
        }
        return protocolMethodStrings
    }
}
