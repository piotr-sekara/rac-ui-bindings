//
//  UICollectionView+RAC.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 11.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import Result
import ObjectiveC.runtime


public extension UICollectionView {

    public var forwardDataSource: UICollectionViewDataSource? {
        get {
            guard let proxy = self.dataSource as? RACDataSourceProxy else {
                return nil
            }
            return proxy.forwardDataSource as? UICollectionViewDataSource
        }
        set {
            let proxy = RACCollectionViewDataSourceProxy.proxy(forObject: self)
            proxy.forwardDataSource = newValue as? NSObject
        }
    }
    
    public func rac_items<Cell: UICollectionViewCell, S: SequenceType, P: PropertyType where Cell: ReusableView, P.Value == S>
        (cellType cellType: Cell.Type)
        -> (source: P)
        -> (configuration: (NSIndexPath, Cell, S.Generator.Element) -> Void)
        -> Disposable {
            return self.rac_items(cellIdentifier: Cell.defaultReuseIdentifier, cellType: cellType)
    }
    
    public func rac_items<Cell: UICollectionViewCell, S: SequenceType, P: PropertyType where P.Value == S>
        (cellIdentifier cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (source: P)
        -> (configuration: (NSIndexPath, Cell, S.Generator.Element) -> Void)
        -> Disposable {
            return { source in
                return { config in
                    let dataSource = RACCollectionViewDataSource<S.Generator.Element, Cell>(identifier: cellIdentifier, cellConfiguration: { (tv, idxPath, elem) -> Cell in
                        let cell: Cell = tv.dequeueReusableCell(forIndexPath: idxPath)
                        config(idxPath, cell, elem)
                        return cell
                    })
                    
                    return self.rac_items(dataSource: dataSource)(source: source)
                }
            }
    }
    
    public func rac_items<DS: protocol<RACDataSourceType, RACCellProviderType>, S: SequenceType, P: PropertyType where P.Value == S, DS.E == S.Generator.Element>
        (dataSource dataSource: DS)
        -> (source: P)
        -> Disposable {
            return { source in
                let proxy = RACCollectionViewDataSourceProxy.proxy(forObject: self)
                return proxy.registerDataSource(dataSource, forObject: self, signalProducer: source.producer)
            }
    }
}

