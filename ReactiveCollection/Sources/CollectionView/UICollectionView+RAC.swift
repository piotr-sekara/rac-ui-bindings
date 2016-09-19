//
//  UICollectionView+RAC.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 11.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
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
    
}

public extension Reactive where Base: UICollectionView {
    
    public func items<Cell: UICollectionViewCell, S: Sequence, P: PropertyProtocol>
        (cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (_: P)
        -> (_: @escaping (IndexPath, Cell, S.Iterator.Element) -> Void)
        -> Disposable where P.Value == S {
            return { source in
                return self.items(cellIdentifier: cellIdentifier, cellType: cellType)(source.producer)
            }
    }
    
    public func items<Cell: UICollectionViewCell, S: Sequence, P: SignalProducerProtocol>
        (cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (_: P)
        -> (_: @escaping (IndexPath, Cell, S.Iterator.Element) -> Void)
        -> Disposable where P.Value == S, P.Error == NoError {
            return { producer in
                return { config in
                    let dataSource = CollectionViewDataSource<S.Iterator.Element, Cell>(identifier: cellIdentifier, cellConfiguration: { (cv, idxPath, elem) -> Cell in
                        guard let cell = cv.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: idxPath) as? Cell else {
                            fatalError("Could not dequeue cell with identifier \(cellIdentifier) for indexPath \(idxPath)")
                        }
                        
                        config(idxPath, cell, elem)
                        return cell
                    })
                    
                    return self.items(dataSource: dataSource)(producer)
                }
            }
    }
    
    public func items<DS: DataSourceType & CellProviderType, S: Sequence, P: PropertyProtocol>
        (dataSource: DS)
        -> (_: P)
        -> Disposable  where P.Value == S, DS.E == S.Iterator.Element {
            return { source in
                return self.items(dataSource: dataSource)(source.producer)
            }
    }
    
    public func items<DS: DataSourceType & CellProviderType, S: Sequence, P: SignalProducerProtocol>
        (dataSource: DS)
        -> (_: P)
        -> Disposable  where P.Value == S, DS.E == S.Iterator.Element, P.Error == NoError {
            return { producer in
                let proxy = CollectionViewDataSourceProxy.proxy(forObject: self.base)
                return proxy.registerDataSource(dataSource: dataSource, forObject: self.base, signalProducer: producer)
            }
    }
}


