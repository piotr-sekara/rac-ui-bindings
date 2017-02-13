//
//  TableViewDataSource.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 10.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit


open class TableViewDataSource<E, Cell: UITableViewCell>: TableViewCellProvider, DataSourceType {
    
    public typealias CellConfiguration = (UITableView, IndexPath, E) -> Cell
    
    open let cellIdentifier: String
    open let cellConfiguration: CellConfiguration
    public private(set) var models: [E] = []
    
    init(identifier: String, cellConfiguration: @escaping CellConfiguration) {
        self.cellIdentifier = identifier
        self.cellConfiguration = cellConfiguration
    }
    
    public func handleUpdate(update: [E]) {
        self.models = update
    }
    
    public override func object(_ object: UITableView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    public override func object(_ object: UITableView, cellForItemAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        return self.cellConfiguration(object, indexPath, models[indexPath.row])
    }
    
}
