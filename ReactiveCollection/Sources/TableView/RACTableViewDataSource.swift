//
//  RACTableViewDataSource.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 10.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit


public class RACTableViewDataSource<E, Cell: UITableViewCell>: RACTableViewCellProvider, RACDataSourceType {
    
    public typealias CellConfiguration = (UITableView, NSIndexPath, E) -> Cell
    
    public let cellIdentifier: String
    public let cellConfiguration: CellConfiguration
    public private(set) var models: [E]?
    
    init(identifier: String, cellConfiguration: CellConfiguration) {
        self.cellIdentifier = identifier
        self.cellConfiguration = cellConfiguration
    }
    
    public func handleUpdate(update: [E]) {
        self.models = update
    }
    
    public override func object(object: UITableView, numberOfItemsInSection section: Int) -> Int {
        guard let models = self.models else { return 0 }
        return models.count
    }
    
    public override func object(object: UITableView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let models = self.models else { return UITableViewCell() }
        return self.cellConfiguration(object, indexPath, models[indexPath.row])
    }
    
}
