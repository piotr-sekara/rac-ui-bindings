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

public extension UICollectionView {
    
    public weak var forwardDataSource: UICollectionViewDataSource? {
        get {
            guard let proxy = self.dataSource as? DelegateProxy else {
                return nil
            }
            return proxy.forwardDelegate as? UICollectionViewDataSource
        }
        set {
            let proxy = CollectionViewDataSourceProxy.proxy(forObject: self)
            proxy.forwardDelegate = newValue as? NSObject
        }
    }
    
    func rac_items<Cell: UICollectionViewCell, S: SequenceType, P: SignalProducerType where Cell: ReusableView, P.Value == S, P.Error == NoError>
        (cellType cellType: Cell.Type)
        -> (producer: P)
        -> (configuration: (NSIndexPath, Cell, S.Generator.Element) -> Void)
        -> Disposable {
            return self.rac_items(cellIdentifier: Cell.defaultReuseIdentifier, cellType: cellType)
    }
    
    public func rac_items<Cell: UICollectionViewCell, S: SequenceType, P: PropertyType where Cell: ReusableView, P.Value == S>
        (cellType cellType: Cell.Type)
        -> (source: P)
        -> (configuration: (NSIndexPath, Cell, S.Generator.Element) -> Void)
        -> Disposable {
            return { source in
                return self.rac_items(cellIdentifier: Cell.defaultReuseIdentifier, cellType: cellType)(producer: source.producer)
            }
    }
    
    func rac_items<Cell: UICollectionViewCell, S: SequenceType, P: PropertyType where P.Value == S>
        (cellIdentifier cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (source: P)
        -> (configuration: (NSIndexPath, Cell, S.Generator.Element) -> Void)
        -> Disposable {
            return { source in
                return self.rac_items(cellIdentifier: cellIdentifier, cellType: cellType)(producer: source.producer)
            }
    }
    
    public func rac_items<Cell: UICollectionViewCell, S: SequenceType, P: SignalProducerType where P.Value == S, P.Error == NoError>
        (cellIdentifier cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (producer: P)
        -> (configuration: (NSIndexPath, Cell, S.Generator.Element) -> Void)
        -> Disposable {
            return { producer in
                return { config in
                    let dataSource = CollectionViewDataSource<S.Generator.Element, Cell>(identifier: cellIdentifier, cellConfiguration: { (cv, idxPath, elem) -> Cell in
                        guard let cell = cv.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: idxPath) as? Cell else {
                            fatalError("Could not dequeue cell with identifier \(cellIdentifier) for indexPath \(idxPath)")
                        }
                        config(idxPath, cell, elem)
                        return cell
                    })
                    
                    return self.rac_items(dataSource: dataSource)(producer: producer)
                }
            }
    }
    
    public func rac_items<DS: protocol<DataSourceType, CellProviderType>, S: SequenceType, P: PropertyType where P.Value == S, DS.E == S.Generator.Element>
        (dataSource dataSource: DS)
        -> (source: P)
        -> Disposable {
            return { source in
                return self.rac_items(dataSource: dataSource)(producer: source.producer)
            }
    }
    
    public func rac_items<DS: protocol<DataSourceType, CellProviderType>, S: SequenceType, P: SignalProducerType where P.Value == S, DS.E == S.Generator.Element, P.Error == NoError>
        (dataSource dataSource: DS)
        -> (producer: P)
        -> Disposable {
            return { producer in
                let proxy = CollectionViewDataSourceProxy.proxy(forObject: self)
                return proxy.registerDataSource(dataSource, forObject: self, signalProducer: producer)
            }
    }
}

