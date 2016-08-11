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


public class RACTableViewDataSourceProxy: RACCollectionDataSourceProxy<UITableView, RACTableViewCellProvider>, UITableViewDataSource {
    
    public init(tableView: UITableView) {
        super.init(parent: tableView)
        self.parent?.dataSource = self
    }
    
    public override static func createProxy(forObject object: AnyObject) -> AnyObject {
        guard let tableView = object as? UITableView else {
            fatalError("Invalid object specified")
        }
        
        return RACTableViewDataSourceProxy(tableView: tableView)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.object(tableView, cellForItemAtIndexPath: indexPath)
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.object(tableView, numberOfItemsInSection: section)
    }
    
}

//Generics <-> Objc stuff
public class RACTableViewCellProvider: RACCellProviderType {
    
    public func object(object: UITableView, numberOfItemsInSection section: Int) -> Int {
        fatalError("Abstract function, should not be used directly")
    }
    
    public func object(object: UITableView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        fatalError("Abstract function, should not be used directly")
    }
}
