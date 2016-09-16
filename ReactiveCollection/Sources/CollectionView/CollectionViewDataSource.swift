//
//  CollectionViewDataSource.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 11.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit

open class CollectionViewDataSource<Element, Cell: UICollectionViewCell>: CollectionViewCellProvider, DataSourceType {

    public typealias CellConfiguration = (UICollectionView, IndexPath, Element) -> Cell
    
    open let cellIdentifier: String
    open let cellConfiguration: CellConfiguration
    open fileprivate(set) var models: [Element]?
    
    init(identifier: String, cellConfiguration: @escaping CellConfiguration) {
        self.cellIdentifier = identifier
        self.cellConfiguration = cellConfiguration
    }
    
    open func handleUpdate(update: [Element]) {
        self.models = update
    }
    
    open override func object(_ object: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let models = self.models else { return 0 }
        return models.count
    }
    
    open override func object(_ object: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        guard let models = self.models else { return UICollectionViewCell() }
        return self.cellConfiguration(object, indexPath, models[(indexPath as NSIndexPath).row])
    }
    
}
