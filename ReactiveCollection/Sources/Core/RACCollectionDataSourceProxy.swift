//
//  RACCollectionDataSourceProxy.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 11.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

public protocol RACCellProviderType: class {
    associatedtype O
    associatedtype BaseCell
    
    func object(object: O, numberOfItemsInSection section: Int) -> Int
    func object(object: O, cellForItemAtIndexPath indexPath: NSIndexPath) -> BaseCell
}

public class RACCollectionDataSourceProxy<C: DataReloadable, T: RACCellProviderType where T.O == C>: RACDataSourceProxy {
    
    public weak private(set) var parent: C?
    
    public override var forwardDataSource: NSObject? {
        didSet {
            self.copyForwardDataSourceMethods()
        }
    }
    
    private var retainedDataSources: [(cellIdentifier: String, dataSource: T)] = []
    private var dataSourceRanges: [Range<Int>] = []
    
    public init(parent: C) {
        self.parent = parent
        super.init()
    }
    
    public func registerDataSource<DS: protocol<RACDataSourceType, RACCellProviderType>, S: SequenceType, P: SignalProducerType where DS.E == S.Generator.Element, P.Value == S, P.Error == NoError>(dataSource: DS, forObject object: C, signalProducer: P) -> Disposable {
        let compositeDisposable = CompositeDisposable()
        
        self.removeDataSource(dataSource.cellIdentifier)
        self.retainedDataSources.append((cellIdentifier: dataSource.cellIdentifier, dataSource: dataSource as! T))
        
        signalProducer.map(Array.init).startWithNext { [weak dataSource, weak self] seq in
            dataSource?.handleUpdate(seq)
            self?.contentDidChange()
            }.addTo(compositeDisposable)
        
        ActionDisposable { [weak self] in
            self?.removeDataSource(dataSource.cellIdentifier)
            self?.contentDidChange()
            }.addTo(compositeDisposable)
        
        return compositeDisposable
    }
    
    public override func respondsToSelector(aSelector: Selector) -> Bool {
        let dsSelectors = C.optionalDataSourceSelectors
        
        if dsSelectors.contains(String(aSelector)) && self.forwardDataSource == nil {
            return false
        }
        
        return super.respondsToSelector(aSelector)
    }
}


extension RACCollectionDataSourceProxy: RACCellProviderType {
    
    public func object(object: C, numberOfItemsInSection section: Int) -> Int {
        if let range = self.dataSourceRanges.last {
            return range.endIndex
        }
        
        return 0
    }
    
    public func object(object: C, cellForItemAtIndexPath indexPath: NSIndexPath) -> T.BaseCell {
        guard let dsIndex = self.dataSourceRanges.indexOf({ $0.contains(indexPath.row) })
            where dsIndex < self.retainedDataSources.count
            else {
                fatalError("Incorrect number of rows in collection")
        }
        
        let (_, ds) = self.retainedDataSources[dsIndex]
        let range = self.dataSourceRanges[dsIndex]
        
        return ds.object(object, cellForItemAtIndexPath: NSIndexPath(forItem: indexPath.row - range.startIndex, inSection: 0))
    }
}

//MARK: - Private
extension RACCollectionDataSourceProxy {
    
    private func copyForwardDataSourceMethods() {
        let protocolMethodStrings = C.optionalDataSourceSelectors
        if let ds = self.forwardDataSource {
            let (forwardMethods, forwardSelectors) = ds.methodsAndSelectors
            
            for i in 0 ..< forwardSelectors.count {
                if protocolMethodStrings.contains(forwardSelectors[i]) {
                    if !class_addMethod(self.dynamicType, NSSelectorFromString(forwardSelectors[i]), method_getImplementation(forwardMethods[i]), method_getTypeEncoding(forwardMethods[i])) {
                        
                        method_setImplementation(class_getInstanceMethod(self.dynamicType, NSSelectorFromString(forwardSelectors[i])), method_getImplementation(forwardMethods[i]))
                    }
                }
            }
        }
    }
    
    private func contentDidChange() {
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
    
    private func removeDataSource(cellIdentifier: String) -> T? {
        if let idx = self.retainedDataSources.indexOf({ $0.cellIdentifier == cellIdentifier }) {
            return self.retainedDataSources.removeAtIndex(idx).dataSource
        }
        return nil
    }
}