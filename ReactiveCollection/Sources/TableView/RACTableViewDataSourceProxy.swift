//
//  RACTableViewDataSourceProxy.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 10.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import Result


public class RACTableViewDataSourceProxy: RACCollectionDataSourceProxy<UITableView, _RACTableViewCellProvider>, UITableViewDataSource {
    
    public init(tableView: UITableView) {
        super.init(parent: tableView)
        self.parent?.dataSource = self
    }
    
    override public class func createProxy(forObject object: AnyObject) -> AnyObject {
        guard let tableView = object as? UITableView else {
            fatalError("Invalid object specified")
        }
        
        return RACTableViewDataSourceProxy(tableView: tableView)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self._object(tableView, cellForItemAtIndexPath: indexPath)
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._object(tableView, numberOfItemsInSection: section)
    }
    
}
