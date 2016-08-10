//
//  UITableView+ReactiveCollection.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 08.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import ObjectiveC.runtime
import Result

public protocol RACDelegateProxyType {
    static func associatedProxy(object: AnyObject) -> AnyObject?
    static func setAssociatedProxy(proxy: AnyObject, to object: AnyObject)
    static func createProxy(forObject object: AnyObject) -> AnyObject
}

public extension RACDelegateProxyType {
    
    public static func proxy(forObject object: AnyObject) -> Self {
        if let proxy = Self.associatedProxy(object) as? Self {
            return proxy
        }
        
        let createdProxy = Self.createProxy(forObject: object)
        guard let returnVal = createdProxy as? Self else {
            fatalError("Could not cast proxy to appropriate type")
        }
        
        Self.setAssociatedProxy(createdProxy, to: object)
        
        return returnVal
    }
    
}

public class RACDelegateProxy: NSObject {
    private struct AssociatedKeys {
        static var rac_delegateProxyKey = "rac_delegateProxyKey"
    }
    
    public class func associatedProxy(object: AnyObject) -> AnyObject? {
        return objc_getAssociatedObject(object, &AssociatedKeys.rac_delegateProxyKey)
    }
    
    public class func setAssociatedProxy(proxy: AnyObject, to object: AnyObject) {
        objc_setAssociatedObject(object, &AssociatedKeys.rac_delegateProxyKey, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

class RACTableViewDataSourceProxy: RACDelegateProxy, RACDelegateProxyType, UITableViewDataSource {
    
    weak private(set) var tableView: UITableView?
    var retainedDataSources: [(cellIdentifier: String, dataSource: _RACTableViewCellProvider)] = []
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView?.dataSource = self
    }
    
    func registerDataSource<DS: protocol<RACTableViewDataSourceType, _RACTableViewCellProvider>>(dataSource: DS, forObject object: UITableView) -> Disposable {
        
        self.removeDataSource(dataSource.cellIdentifier)
        self.retainedDataSources.append((cellIdentifier: dataSource.cellIdentifier, dataSource: dataSource))
        
        dump(dataSource)
        
        return ActionDisposable { [weak self] in
            self?.removeDataSource(dataSource.cellIdentifier)
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cellProvider = self.retainedDataSources.first?.dataSource {
            return cellProvider._tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
        
        return UITableViewCell()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cellProvider = self.retainedDataSources.first?.dataSource {
            return cellProvider._tableView(tableView, numberOfRowsInSection: section)
        }
        
        return 0
    }
    
}

protocol _RACTableViewCellProvider: NSObjectProtocol {
    func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
}

protocol RACTableViewDataSourceType {
    associatedtype E
    associatedtype Cell
    
    var models: [E]? { get }
    var cellIdentifier: String { get }
    var cellConfiguration: (UITableView, NSIndexPath, E) -> Cell { get }
    
    func handleEvent(event: Event<[E], NoError>, forTableView tableView: UITableView)
}

class RACTableViewDataSource<E, Cell: UITableViewCell>: NSObject, RACTableViewDataSourceType, _RACTableViewCellProvider {
    
    typealias CellConfiguration = (UITableView, NSIndexPath, E) -> Cell
    
    let cellIdentifier: String
    let cellConfiguration: CellConfiguration
    var models: [E]?
    
    init(identifier: String, cellConfiguration: CellConfiguration) {
        self.cellIdentifier = identifier
        self.cellConfiguration = cellConfiguration
    }
    
    func handleEvent(event: Event<[E], NoError>, forTableView tableView: UITableView) {
        if case let .Next(val) = event {
            self.models = val
        }
        
        tableView.reloadData()
    }
    
    func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let models = self.models else { return 0 }
        return models.count
    }
    
    func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let models = self.models else { return UITableViewCell() }
        return self.cellConfiguration(tableView, indexPath, models[indexPath.row])
    }
}


extension UITableView {
    private struct AssociatedKeys {
        static var rac_delegateKey = "rac_delegateKey"
        static var rac_dataSourceKey = "rac_dataSourceKey"
    }
    
//    func rac_items<Cell: UITableViewCell, S: SequenceType, P: PropertyType where Cell: ReusableView, P.Value == S>
//        (cellType cellType: Cell.Type)
//        -> (source: P)
//        -> (configuration: (NSIndexPath, Cell, S.Generator.Element) -> Void)
//        -> Disposable {
//            return { source in
//                return { config in
//                    //let dataSource = get the data source from somewhere
//                    
//                    //return observer
//                    
//                    return SimpleDisposable()
//                }
//            }
//    }
    
    func rac_items<Cell: UITableViewCell, S: SequenceType, P: PropertyType where P.Value == S>
        (cellIdentifier cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (source: P)
        -> (configuration: (NSIndexPath, Cell, S.Generator.Element) -> Void)
        -> Disposable {
            return { source in
                return { config in
                    //let dataSource = create the data source for this combination of params
                    let dataSource = RACTableViewDataSource<S.Generator.Element, Cell>(identifier: cellIdentifier, cellConfiguration: { (tv, idxPath, elem) -> Cell in
                        let cell: Cell = tv.dequeueReusableCell(forIndexPath: idxPath)
                        config(idxPath, cell, elem)
                        return cell
                    })
                    
                    return self.rac_items(dataSource: dataSource)(source: source)
                }
            }
    }
    
    func rac_items<DS: protocol<RACTableViewDataSourceType, _RACTableViewCellProvider>, S: SequenceType, P: PropertyType where P.Value == S, DS.E == S.Generator.Element>
        (dataSource dataSource: DS)
        -> (source: P)
        -> Disposable {
            return { source in
                let proxy = RACTableViewDataSourceProxy.proxy(forObject: self)
                
                let compositeDisposable = CompositeDisposable()
                
                proxy.registerDataSource(dataSource, forObject: self).addTo(compositeDisposable)
                
                source.producer.map(Array.init).start { [weak dataSource, weak self] evt in
                    guard let slf = self else { return }
                    dataSource?.handleEvent(evt, forTableView: slf)
                }.addTo(compositeDisposable)
                
                
                
                return compositeDisposable
            }
    }

}


extension PropertyType where Value: SequenceType {
    
    func bindTo<R1, R2>(binding: Self -> R1 -> R2, curriedArg: R1) -> R2 {
        return binding(self)(curriedArg)
    }

}

extension Disposable {
    func addTo(compositeDisposable: CompositeDisposable) -> Disposable {
        compositeDisposable.addDisposable(self)
        return self
    }
}



