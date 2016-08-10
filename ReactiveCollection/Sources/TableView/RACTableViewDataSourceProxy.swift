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

class RACTableViewDataSourceProxy: RACDelegateProxy, RACDelegateProxyType, UITableViewDataSource {
    
    weak private(set) var tableView: UITableView?
    
    var retainedDataSources: [(cellIdentifier: String, dataSource: _RACTableViewCellProvider)] = []
    var dataSourceRanges: [Range<Int>] = []
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView?.dataSource = self
    }
    
    func registerDataSource<DS: protocol<RACTableViewDataSourceType, _RACTableViewCellProvider>>(dataSource: DS, forObject object: UITableView) -> Disposable {
        
        self.removeDataSource(dataSource.cellIdentifier)
        self.retainedDataSources.append((cellIdentifier: dataSource.cellIdentifier, dataSource: dataSource))
        
        return ActionDisposable { [weak self] in
            self?.removeDataSource(dataSource.cellIdentifier)
            self?.cellProviderContentDidChange()
            self?.tableView?.reloadData()
        }
    }
    
    class func createProxy(forObject object: AnyObject) -> AnyObject {
        guard let tableView = object as? UITableView else {
            fatalError("Invalid object specified")
        }
        return RACTableViewDataSourceProxy(tableView: tableView)
    }
    
    private func removeDataSource(cellIdentifier: String) -> _RACTableViewCellProvider? {
        if let idx = self.retainedDataSources.indexOf({ $0.cellIdentifier == cellIdentifier }) {
            return self.retainedDataSources.removeAtIndex(idx).dataSource
        }
        return nil
    }
    
    func cellProviderContentDidChange() {
        var ranges: [Range<Int>] = []
        var currentMax = 0
        for (_, dataSource) in self.retainedDataSources {
            let numberOfRows = dataSource._tableView(self.tableView!, numberOfRowsInSection: 0)
            ranges.append(currentMax ..< currentMax + numberOfRows)
            currentMax += numberOfRows
        }
        self.dataSourceRanges = ranges
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let dataSourceIndex = self.dataSourceRanges.indexOf({ $0.contains(indexPath.row) })
            where dataSourceIndex < self.retainedDataSources.count
            else {
                fatalError("Incorrect number of rows in tableView")
        }
        
        let (_, dataSource) = self.retainedDataSources[dataSourceIndex]
        let range = self.dataSourceRanges[dataSourceIndex]
        
        return dataSource._tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forItem: indexPath.row - range.startIndex, inSection: 0))
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let range = self.dataSourceRanges.last {
            return range.endIndex
        }
        
        return 0
    }
    
}
