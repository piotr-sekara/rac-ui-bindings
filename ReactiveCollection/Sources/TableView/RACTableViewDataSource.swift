//
//  RACTableViewDataSource.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 10.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit


public class _RACTableViewCellProvider: _RACCellProvider {
    
    public func _object(object: UITableView, numberOfItemsInSection section: Int) -> Int {
        fatalError("Abstract function, should not be used directly")
    }
    
    public func _object(object: UITableView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        fatalError("Abstract function, should not be used directly")
    }
    
}

public protocol RACTableViewDataSourceType: RACDataSourceType {
    var cellConfiguration: (UITableView, NSIndexPath, E) -> Cell { get }
}

public class RACTableViewDataSource<E, Cell: UITableViewCell>:  _RACTableViewCellProvider, RACTableViewDataSourceType {
    
    public typealias CellConfiguration = (UITableView, NSIndexPath, E) -> Cell
    
    public let cellIdentifier: String
    public let cellConfiguration: CellConfiguration
    public var models: [E]?
    
    init(identifier: String, cellConfiguration: CellConfiguration) {
        self.cellIdentifier = identifier
        self.cellConfiguration = cellConfiguration
    }
    
    public func handleUpdate(update: [E]) {
        self.models = update
    }
    
    public override func _object(object: UITableView, numberOfItemsInSection section: Int) -> Int {
        guard let models = self.models else { return 0 }
        return models.count
    }
    
    public override func _object(object: UITableView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let models = self.models else { return UITableViewCell() }
        return self.cellConfiguration(object, indexPath, models[indexPath.row])
    }
    
}
