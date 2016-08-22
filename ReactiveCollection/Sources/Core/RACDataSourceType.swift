//
//  RACDataSourceType.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 11.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation

public protocol RACDataSourceType {
    associatedtype E
    associatedtype Cell
    associatedtype O
    
    var models: [E]? { get }
    var cellIdentifier: String { get }
    var cellConfiguration: (O, NSIndexPath, E) -> Cell { get }
    
    func handleUpdate(update: [E])
}
