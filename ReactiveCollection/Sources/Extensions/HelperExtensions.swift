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
    
}


public protocol DataReloadable: class {
    static var optionalDataSourceSelectors: [String] { get }
    
    func reloadData()
}

extension UITableView: DataReloadable {
    @nonobjc public static var optionalDataSourceSelectors: [String] = RACDataSourceProxy.optionalSelectorsFor(UITableViewDataSource)
}

extension UICollectionView: DataReloadable {
    @nonobjc public static var optionalDataSourceSelectors: [String] = RACDataSourceProxy.optionalSelectorsFor(UICollectionViewDataSource)
}