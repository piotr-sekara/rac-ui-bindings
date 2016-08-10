//
//  RACTableViewDataSource.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 10.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit


protocol _RACTableViewCellProvider: class {
    func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
}

protocol RACTableViewDataSourceType: RACDataSourceType {
    var cellConfiguration: (UITableView, NSIndexPath, E) -> Cell { get }
}

class RACTableViewDataSource<E, Cell: UITableViewCell>: RACTableViewDataSourceType, _RACTableViewCellProvider {
    
    typealias CellConfiguration = (UITableView, NSIndexPath, E) -> Cell
    
    let cellIdentifier: String
    let cellConfiguration: CellConfiguration
    var models: [E]?
    
    init(identifier: String, cellConfiguration: CellConfiguration) {
        self.cellIdentifier = identifier
        self.cellConfiguration = cellConfiguration
    }
    
    func handleUpdate(update: [E]) {
        self.models = update
    }
    
    func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let models = self.models else { return 0 }
        return models.count
    }
    
    func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let models = self.models else { return UITableViewCell() }
        return self.cellConfiguration(tableView, indexPath, models[indexPath.row])
    }
}
