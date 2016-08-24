//
//  TestHelpers.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 24.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
@testable import ReactiveUIBindings
import ReactiveCocoa
import Result

protocol UITestCell: class, ReusableView {
    var data: String? { get set }
}

class TestTableCell1: UITableViewCell, UITestCell { var data: String? }
class TestTableCell2: UITableViewCell, UITestCell { var data: String? }
class TestCollectionCell1: UICollectionViewCell, UITestCell { var data: String? }
class TestCollectionCell2: UICollectionViewCell, UITestCell { var data: String? }

protocol UITestCollection {
    static var testCellIdentifier1: String { get }
    static var testCellIdentifier2: String { get }
    
    associatedtype Instance
    associatedtype Cell
    static func createInstance() -> Instance
    
    func registerClass(type: AnyClass?, forIdentifier: String)
    
    func bindWith(property: MutableProperty<[String]>, identifier: String) -> Disposable
    func bindWith(property: MutableProperty<[String]>, cellType: UITestCell.Type) -> Disposable
    func bindWith(producer: SignalProducer<[String], NoError>, identifier: String) -> Disposable
    func bindWith(producer: SignalProducer<[String], NoError>, cellType: UITestCell.Type) -> Disposable
    
    func numberOfItems(section: Int) -> Int
    func cellForItem(indexPath: NSIndexPath) -> Cell?
    
}

extension UICollectionView: UITestCollection {
    @nonobjc static let testCellIdentifier1: String = "FixtureCell1"
    @nonobjc static let testCellIdentifier2: String = "FixtureCell2"
    
    class func createInstance() -> UICollectionView {
        let instance = UICollectionView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 100, height: 100000)), collectionViewLayout: UICollectionViewFlowLayout())
        instance.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: self.testCellIdentifier1)
        instance.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: self.testCellIdentifier2)
        return instance
    }
    
    func registerClass(type: AnyClass?, forIdentifier: String) {
        self.registerClass(type, forCellWithReuseIdentifier: forIdentifier)
    }
    
    func bindWith(property: MutableProperty<[String]>, identifier: String) -> Disposable {
        return property.bindTo(self.rac_items(cellIdentifier: identifier)) { _ in }
    }
    
    func bindWith(property: MutableProperty<[String]>, cellType: UITestCell.Type) -> Disposable {
        return property.bindTo(self.rac_items(cellIdentifier: cellType.defaultReuseIdentifier, cellType: cellType as! UICollectionViewCell.Type)) { (_, cell, data) in
            let cell = cell as! UITestCell
            cell.data = data
        }
    }
    
    func bindWith(producer: SignalProducer<[String], NoError>, identifier: String) -> Disposable {
        return producer.bindTo(self.rac_items(cellIdentifier: identifier)) { (idx, cell: UICollectionViewCell, elem) in }
    }
    
    func bindWith(producer: SignalProducer<[String], NoError>, cellType: UITestCell.Type) -> Disposable {
        return producer.bindTo(self.rac_items(cellIdentifier: cellType.defaultReuseIdentifier, cellType: cellType as! UICollectionViewCell.Type)) { (_, cell, data) in
            let cell = cell as! UITestCell
            cell.data = data
        }
    }
    
    func numberOfItems(section: Int) -> Int {
        return (self.dataSource?.collectionView(self, numberOfItemsInSection: section))!
    }
    
    func cellForItem(indexPath: NSIndexPath) -> UICollectionViewCell? {
        return self.dataSource?.collectionView(self, cellForItemAtIndexPath: indexPath)
    }
    
    
}

extension UITableView: UITestCollection {
    
    @nonobjc static let testCellIdentifier1: String = "FixtureCell1"
    @nonobjc static let testCellIdentifier2: String = "FixtureCell2"
    
    class func createInstance() -> UITableView {
        let instance = UITableView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 100, height: 100000)))
        instance.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.testCellIdentifier1)
        instance.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.testCellIdentifier2)
        return instance
    }
    
    func registerClass(type: AnyClass?, forIdentifier: String) {
        self.registerClass(type, forCellReuseIdentifier: forIdentifier)
    }
    
    func bindWith(property: MutableProperty<[String]>, identifier: String) -> Disposable {
        return property.bindTo(self.rac_items(cellIdentifier: identifier)) { _ in }
    }
    
    func bindWith(property: MutableProperty<[String]>, cellType: UITestCell.Type) -> Disposable {
        return property.bindTo(self.rac_items(cellIdentifier: cellType.defaultReuseIdentifier, cellType: cellType as! UITableViewCell.Type)) { (_, cell, data) in
            let cell = cell as! UITestCell
            cell.data = data
        }
    }
    
    func bindWith(producer: SignalProducer<[String], NoError>, identifier: String) -> Disposable {
        return producer.bindTo(self.rac_items(cellIdentifier: identifier)) { _ in }
    }
    
    func bindWith(producer: SignalProducer<[String], NoError>, cellType: UITestCell.Type) -> Disposable {
        return producer.bindTo(self.rac_items(cellIdentifier: cellType.defaultReuseIdentifier, cellType: cellType as! UITableViewCell.Type)) { (_, cell, data) in
            let cell = cell as! UITestCell
            cell.data = data
        }
    }
    
    func numberOfItems(section: Int) -> Int {
        return (self.dataSource?.tableView(self, numberOfRowsInSection: section))!
    }
    
    func cellForItem(indexPath: NSIndexPath) -> UITableViewCell? {
        return self.dataSource?.tableView(self, cellForRowAtIndexPath: indexPath)
    }
}
