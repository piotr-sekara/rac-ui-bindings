//
//  CollectionDataSourceProxy.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 11.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public protocol CellProviderType: class {
    associatedtype O
    associatedtype BaseCell
    
    func object(_ object: O, numberOfItemsInSection section: Int) -> Int
    func object(_ object: O, cellForItemAtIndexPath indexPath: IndexPath) -> BaseCell
}

open class CollectionDataSourceProxy<C: DataReloadable, T: CellProviderType>: DelegateProxy where T.O == C {
    
    open weak private(set) var parent: C?
    
    open override var forwardDelegate: NSObject? {
        didSet {
            self.copyforwardDelegateMethods()
        }
    }
    
    fileprivate var retainedDataSources: [(cellIdentifier: String, dataSource: T)] = []
    fileprivate var dataSourceRanges: [Range<Int>] = []
    
    public init(parent: C) {
        self.parent = parent
        super.init()
    }
    
    open func registerDataSource<DS: DataSourceType & CellProviderType, S: Sequence, P: SignalProducerProtocol>(dataSource: DS, forObject object: C, signalProducer: P) -> Disposable where DS.E == S.Iterator.Element, P.Value == S, P.Error == NoError {
        let compositeDisposable = CompositeDisposable()
        
        self.removeDataSource(cellIdentifier: dataSource.cellIdentifier)
        self.retainedDataSources.append((cellIdentifier: dataSource.cellIdentifier, dataSource: dataSource as! T))
        
        
        signalProducer.producer.map(Array.init).startWithValues { [weak dataSource, weak self] seq in
            dataSource?.handleUpdate(update: seq)
            self?.contentDidChange()
            }.addTo(compositeDisposable)
        
        AnyDisposable { [weak self] in
            _ = self?.removeDataSource(cellIdentifier: dataSource.cellIdentifier)
            self?.contentDidChange()
            }.addTo(compositeDisposable)
        
        return compositeDisposable
    }
    
    open override func responds(to aSelector: Selector!) -> Bool {
        let dsSelectors = C.optionalDataSourceSelectors
        
        if dsSelectors.contains(String(describing: aSelector)) && self.forwardDelegate == nil {
            return false
        }
        
        return super.responds(to: aSelector)
    }
}


extension CollectionDataSourceProxy: CellProviderType {
    
    public func object(_ object: C, numberOfItemsInSection section: Int) -> Int {
        if let range = self.dataSourceRanges.last {
            return range.upperBound
        }
        
        return 0
    }
    
    public func object(_ object: C, cellForItemAtIndexPath indexPath: IndexPath) -> T.BaseCell {
        guard let dsIndex = self.dataSourceRanges.index(where: { $0.contains(indexPath.row) })
            , dsIndex < self.retainedDataSources.count
            else {
                fatalError("Incorrect number of rows in collection")
        }
        
        let (_, ds) = self.retainedDataSources[dsIndex]
        let range = self.dataSourceRanges[dsIndex]
        
        return ds.object(object, cellForItemAtIndexPath: IndexPath(item: indexPath.row - range.lowerBound, section: 0))
    }
}

//MARK: - Private
extension CollectionDataSourceProxy {
    
    fileprivate func copyforwardDelegateMethods() {
        let protocolMethodStrings = C.optionalDataSourceSelectors
        if let ds = self.forwardDelegate {
            let (forwardMethods, forwardSelectors) = ds.methodsAndSelectors
            if let forwardMethods = forwardMethods {
                for i in 0 ..< forwardSelectors.count {
                    if protocolMethodStrings.contains(forwardSelectors[i]) {
                        if !class_addMethod(type(of: self), NSSelectorFromString(forwardSelectors[i]), method_getImplementation(forwardMethods[i]), method_getTypeEncoding(forwardMethods[i])) {
                            
                            method_setImplementation(class_getInstanceMethod(type(of: self), NSSelectorFromString(forwardSelectors[i]))!, method_getImplementation(forwardMethods[i]))
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func contentDidChange() {
        var ranges: [Range<Int>] = []
        var currentMax = 0
        for (_, dataSource) in self.retainedDataSources {
            let numberOfRows = dataSource.object(self.parent!, numberOfItemsInSection: 0)
            ranges.append(currentMax ..< currentMax + numberOfRows)
            currentMax += numberOfRows
        }
        self.dataSourceRanges = ranges
        self.parent?.reloadData()
    }
    
    @discardableResult
    fileprivate func removeDataSource(cellIdentifier: String) -> T? {
        if let idx = self.retainedDataSources.index(where: { $0.cellIdentifier == cellIdentifier }) {
            return self.retainedDataSources.remove(at: idx).dataSource
        }
        return nil
    }
}
