//
//  RACCollectionViewDataSourceProxy.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 11.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit
import Result
import ReactiveCocoa


public class RACCollectionViewDataSourceProxy: RACCollectionDataSourceProxy<UICollectionView, RACCollectionViewCellProvider>, UICollectionViewDataSource {

    public init(collectionView: UICollectionView) {
        super.init(parent: collectionView)
        self.parent?.dataSource = self
    }
    
    public override static func createProxy(forObject object: AnyObject) -> AnyObject {
        guard let collectionView = object as? UICollectionView else {
            fatalError("Invalid object specified")
        }
        
        return RACCollectionViewDataSourceProxy(collectionView: collectionView)
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.object(collectionView, numberOfItemsInSection: section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.object(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
}


//Generics <-> Objc stuff
public class RACCollectionViewCellProvider: RACCellProviderType {
    public func object(object: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError("Abstract function, should not be used directly")
    }
    
    public func object(object: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        fatalError("Abstract function, should not be used directly")
    }
}
