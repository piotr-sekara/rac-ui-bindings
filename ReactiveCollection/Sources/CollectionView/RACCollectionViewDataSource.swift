//
//  RACCollectionViewDataSource.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 11.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit

public class RACCollectionViewDataSource<E, Cell: UICollectionViewCell>: RACCollectionViewCellProvider, RACDataSourceType {
    
    public typealias CellConfiguration = (UICollectionView, NSIndexPath, E) -> Cell
    
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
    
    public override func object(object: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let models = self.models else { return 0 }
        return models.count
    }
    
    public override func object(object: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let models = self.models else { return UICollectionViewCell() }
        return self.cellConfiguration(object, indexPath, models[indexPath.row])
    }
    
}
