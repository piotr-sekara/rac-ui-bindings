//
//  UITableView+RAC.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 10.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result

public extension UITableView {
    
    public weak var forwardDataSource: UITableViewDataSource? {
        get {
            guard let proxy = self.dataSource as? DelegateProxy else {
                return nil
            }
            return proxy.forwardDelegate as? UITableViewDataSource
        }
        set {
            let proxy = TableViewDataSourceProxy.proxy(forObject: self)
            proxy.forwardDelegate = newValue as? NSObject
        }
    }
    
    func rac_items<Cell: UITableViewCell, S: Sequence, P: PropertyProtocol>
        (cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (_: P)
        -> (_: @escaping (IndexPath, Cell, S.Iterator.Element) -> Void)
        -> Disposable where P.Value == S {
            return { source in
                return self.rac_items(cellIdentifier: cellIdentifier, cellType: cellType)(source.producer)
            }
    }
    
    func rac_items<Cell: UITableViewCell, S: Sequence, P: SignalProducerProtocol>
        (cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (_: P)
        -> (_: @escaping (IndexPath, Cell, S.Iterator.Element) -> Void)
        -> Disposable where P.Value == S, P.Error == NoError {
            return { producer in
                return { config in
                    let dataSource = TableViewDataSource<S.Iterator.Element, Cell>(identifier: cellIdentifier, cellConfiguration: { (tv, idxPath, elem) -> Cell in
                        guard let cell = tv.dequeueReusableCell(withIdentifier: cellIdentifier) as? Cell else {
                            fatalError("Could not dequeue cell with identifier \(cellIdentifier) for indexPath \(idxPath)")
                        }
                        config(idxPath, cell, elem)
                        return cell
                    })
                    
                    return self.rac_items(dataSource: dataSource)(producer)
                }
            }
    }
    
    func rac_items<DS: DataSourceType & CellProviderType, S: Sequence, P: PropertyProtocol>
        (dataSource: DS)
        -> (_ source: P)
        -> Disposable where P.Value == S, DS.E == S.Iterator.Element {
            return { source in
                return self.rac_items(dataSource: dataSource)(source.producer)
            }
    }
    
    func rac_items<DS: DataSourceType & CellProviderType, S: Sequence, P: SignalProducerProtocol>
        (dataSource: DS)
        -> (_ producer: P)
        -> Disposable where P.Value == S, DS.E == S.Iterator.Element, P.Error == NoError {
            return { producer in
                let proxy = TableViewDataSourceProxy.proxy(forObject: self)
                return proxy.registerDataSource(dataSource: dataSource, forObject: self, signalProducer: producer)
            }
    }
    
}
