//
//  TableViewDataSourceProxy.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 10.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result


open class TableViewDataSourceProxy: CollectionDataSourceProxy<UITableView, TableViewCellProvider>, UITableViewDataSource {
    
    public init(tableView: UITableView) {
        super.init(parent: tableView)
        self.parent?.dataSource = self
    }
    
    open override static func createProxy(forObject object: AnyObject) -> AnyObject {
        guard let tableView = object as? UITableView else {
            fatalError("Invalid object specified")
        }
        
        return TableViewDataSourceProxy(tableView: tableView)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.object(tableView, cellForItemAtIndexPath: indexPath)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.object(tableView, numberOfItemsInSection: section)
    }
    
}

//Generics <-> Objc stuff
open class TableViewCellProvider: CellProviderType {
    
    public func object(_ object: UITableView, numberOfItemsInSection section: Int) -> Int {
        fatalError("Abstract function, should not be used directly")
    }
    
    public func object(_ object: UITableView, cellForItemAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        fatalError("Abstract function, should not be used directly")
    }
}
