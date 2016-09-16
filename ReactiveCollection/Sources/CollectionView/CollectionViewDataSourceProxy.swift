//
//  CollectionViewDataSourceProxy.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 11.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit
import Result
import ReactiveSwift


open class CollectionViewDataSourceProxy: CollectionDataSourceProxy<UICollectionView, CollectionViewCellProvider>, UICollectionViewDataSource {

    public init(collectionView: UICollectionView) {
        super.init(parent: collectionView)
        self.parent?.dataSource = self
    }
    
    open override static func createProxy(forObject object: AnyObject) -> AnyObject {
        guard let collectionView = object as? UICollectionView else {
            fatalError("Invalid object specified")
        }
        
        return CollectionViewDataSourceProxy(collectionView: collectionView)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.object(collectionView, numberOfItemsInSection: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.object(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
}


//Generics <-> Objc stuff
open class CollectionViewCellProvider: CellProviderType {
    public func object(_ object: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError("Abstract function, should not be used directly")
    }
    
    public func object(_ object: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Abstract function, should not be used directly")
    }
}
