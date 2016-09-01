//
//  HelperExtensions.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 12.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ObjectiveC.runtime
import UIKit
import ReactiveCocoa
import Result

public protocol DataReloadable: class {
    static var optionalDataSourceSelectors: [String] { get }
    
    func reloadData()
}

extension UITableView: DataReloadable {
    @nonobjc public static var optionalDataSourceSelectors: [String] = DelegateProxy.optionalSelectorsFor(UITableViewDataSource)
}

extension UICollectionView: DataReloadable {
    @nonobjc public static var optionalDataSourceSelectors: [String] = DelegateProxy.optionalSelectorsFor(UICollectionViewDataSource)
}


extension NSObject {
    
    var methodsAndSelectors: (UnsafeMutablePointer<Method>, [String]) {
        var outCount: UInt32 = 0
        let forwardMethods = class_copyMethodList(self.dynamicType, &outCount)
        var forwardMethodStrings: [String] = []
        for i in 0 ..< Int(outCount) {
            forwardMethodStrings.append(String(method_getName(forwardMethods[i])))
        }
        return (forwardMethods, forwardMethodStrings)
    }
    
    func rac_willDeallocSignal() -> SignalProducer<(), NoError> {
        return self.rac_willDeallocSignal().toSignalProducer().map { _ -> () in }.flatMapError { _ -> SignalProducer<(), NoError> in
            return SignalProducer<(), NoError>.empty
        }
    }
    
}

extension DelegateProxy {
    
    public class func displayWarningsIfNeeded(selfDataSource: AnyObject?, newDataSource: AnyObject?) {
        if newDataSource is DelegateProxy && !(selfDataSource is DelegateProxy) && selfDataSource != nil {
            print("Warning: Binding dataSource with RAC will override one that is already set.")
            print("         Setting dataSource to nil before binding will silence this warning.")
        } else if selfDataSource is DelegateProxy && newDataSource != nil {
            print("Warning: Setting dataSource will override RAC bindings.")
            print("         If you would like to keep RAC bindings and use other dataSource methods, please use forwardDataSource property instead.")
            print("         If you are sure you want to override RAC bindings, set dataSource to nil before setting new one.")
        }
    }
}

extension DelegateProxy {
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
