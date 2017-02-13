//
//  TestHelpers.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 24.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
@testable import ReactiveUIBindings
import ReactiveSwift
import Result

protocol UITestCell: class {
    var data: String? { get set }
}

protocol ReusableCell: class {
    var reuseIdentifier: String? { get }
}

enum TestError: Error {
    case error
}

class TestTableCell1: UITableViewCell, UITestCell { var data: String? }
class TestTableCell2: UITableViewCell, UITestCell { var data: String? }
class TestCollectionCell1: UICollectionViewCell, UITestCell { var data: String? }
class TestCollectionCell2: UICollectionViewCell, UITestCell { var data: String? }
extension UITableViewCell: ReusableCell {}
extension UICollectionViewCell: ReusableCell {}

protocol UITestCollection {
    static var testCellIdentifier1: String { get }
    static var testCellIdentifier2: String { get }
    
    associatedtype Instance
    associatedtype Cell
    static func createInstance() -> Instance
    
    func registerClass(_ type: AnyClass?, forIdentifier: String)
    
    @discardableResult
    func bindWith(_ property: MutableProperty<[String]>, identifier: String) -> Disposable
    @discardableResult
    func bindWith(_ producer: SignalProducer<[String], NoError>, identifier: String) -> Disposable
    
    func numberOfItems(_ section: Int) -> Int
    func cellForItem(_ indexPath: IndexPath) -> Cell?
    
}

extension UICollectionView: UITestCollection {

    @nonobjc static let testCellIdentifier1: String = "FixtureCell1"
    @nonobjc static let testCellIdentifier2: String = "FixtureCell2"
    
    static func createInstance() -> UICollectionView {
        
        let instance = UICollectionView(frame: CGRect(origin: CGPoint(), size: CGSize(width: 100, height: 100000)), collectionViewLayout: UICollectionViewFlowLayout())
        instance.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.testCellIdentifier1)
        instance.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.testCellIdentifier2)
        return instance
    }
    
    func registerClass(_ type: AnyClass?, forIdentifier: String) {
        self.register(type, forCellWithReuseIdentifier: forIdentifier)
    }
    
    @discardableResult
    func bindWith(_ property: MutableProperty<[String]>, identifier: String) -> Disposable {
        return property.bindTo(self.reactive.items(cellIdentifier: identifier)) { _ in }
    }
    
    @discardableResult
    func bindWith(_ producer: SignalProducer<[String], NoError>, identifier: String) -> Disposable {
        return producer.bindTo(self.reactive.items(cellIdentifier: identifier)) { (idx, cell: UICollectionViewCell, elem) in }
    }
    
    func numberOfItems(_ section: Int) -> Int {
        return (self.dataSource?.collectionView(self, numberOfItemsInSection: section))!
    }
    
    func cellForItem(_ indexPath: IndexPath) -> UICollectionViewCell? {
        return self.dataSource?.collectionView(self, cellForItemAt: indexPath as IndexPath)
    }
    
    
}

extension UITableView: UITestCollection {
    
    @nonobjc static let testCellIdentifier1: String = "FixtureCell1"
    @nonobjc static let testCellIdentifier2: String = "FixtureCell2"
    
    class func createInstance() -> UITableView {
        let instance = UITableView(frame: CGRect(origin: CGPoint(), size: CGSize(width: 100, height: 100000)))
        instance.register(UITableViewCell.self, forCellReuseIdentifier: self.testCellIdentifier1)
        instance.register(UITableViewCell.self, forCellReuseIdentifier: self.testCellIdentifier2)
        return instance
    }
    
    func registerClass(_ type: AnyClass?, forIdentifier: String) {
        self.register(type, forCellReuseIdentifier: forIdentifier)
    }
    
    @discardableResult
    func bindWith(_ property: MutableProperty<[String]>, identifier: String) -> Disposable {
        return property.bindTo(self.reactive.items(cellIdentifier: identifier)) { _ in }
    }
    
    @discardableResult
    func bindWith(_ producer: SignalProducer<[String], NoError>, identifier: String) -> Disposable {
        return producer.bindTo(self.reactive.items(cellIdentifier: identifier)) { _ in }
    }
    
    func numberOfItems(_ section: Int) -> Int {
        return (self.dataSource?.tableView(self, numberOfRowsInSection: section))!
    }
    
    func cellForItem(_ indexPath: IndexPath) -> UITableViewCell? {
        return self.dataSource?.tableView(self, cellForRowAt: indexPath as IndexPath)
    }
}
