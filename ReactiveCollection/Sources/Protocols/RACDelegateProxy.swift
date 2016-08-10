//
//  RACDelegateProxy.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 10.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ObjectiveC.runtime
import ReactiveCocoa

public protocol RACDelegateProxyType {
    static func associatedProxy(object: AnyObject) -> AnyObject?
    static func setAssociatedProxy(proxy: AnyObject, to object: AnyObject)
    static func createProxy(forObject object: AnyObject) -> AnyObject
}

public extension RACDelegateProxyType {
    
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

public protocol RACDataSourceType {
    associatedtype E
    associatedtype Cell
    associatedtype Object
    
    var models: [E]? { get }
    var cellIdentifier: String { get }
    var cellConfiguration: (Object, NSIndexPath, E) -> Cell { get }
    
    func handleUpdate(update: [E])
}

public protocol _RACCellProvider: class {
    associatedtype O
    associatedtype Cell
    
    func _object(object: O, numberOfItemsInSection section: Int) -> Int
    func _object(object: O, cellForItemAtIndexPath indexPath: NSIndexPath) -> Cell
}

public class RACDelegateProxy: NSObject {
    private struct AssociatedKeys {
        static var rac_delegateProxyKey = "rac_delegateProxyKey"
    }
    
    public class func associatedProxy(object: AnyObject) -> AnyObject? {
        return objc_getAssociatedObject(object, &AssociatedKeys.rac_delegateProxyKey)
    }
    
    public class func setAssociatedProxy(proxy: AnyObject, to object: AnyObject) {
        objc_setAssociatedObject(object, &AssociatedKeys.rac_delegateProxyKey, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

public class RACCollectionDataSourceProxy<C: NSObject, T: _RACCellProvider>: RACDelegateProxy, RACDelegateProxyType {
    
    public weak private(set) var parent: C?
    
    var retainedDataSources: [(cellIdentifier: String, dataSource: T)] = []
    
    public init(parent: C) {
        self.parent = parent
        super.init()
    }
    
    public static func createProxy(forObject object: AnyObject) -> AnyObject {
        fatalError("Abstract object, should not be created directly")
    }
    
    func registerDataSource<DS: protocol<RACDataSourceType, T>>(dataSource: DS, forObject object: C) -> Disposable {
        
    }
}