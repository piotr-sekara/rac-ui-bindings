//
//  ReactiveTableViewTests.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 22.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import XCTest
import Nimble

@testable import ReactiveUIBindings
import ReactiveCocoa
import Result

class TestCell1: UITableViewCell {
    var data: String?
}
class TestCell2: UITableViewCell {
    var data: String?
}


class ReactiveTableViewTests: XCTestCase {
    
    var tableView: UITableView!
    
    var ds1: MutableProperty<[String]>!
    var ds2: MutableProperty<[String]>!
    var ds3: SignalProducer<[String], NoError>!
    var ds4: SignalProducer<[String], NoError>!
    
    var ds3Obs: Signal<[String], NoError>.Observer!
    
    override func setUp() {
        tableView = UITableView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 100, height: 100000)))
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "FixtureCell1")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "FixtureCell2")
        tableView.register(TestCell1.self)
        tableView.register(TestCell2.self)
        ds1 = MutableProperty([
            "Fixture1",
            "Fixture2",
            "Fixture3",
            "Fixture4",
            "Fixture5",
            "Fixture6",
            "Fixture7",
            "Fixture8",
            ])
        
        ds2 = MutableProperty([
            "Test1",
            "Test2",
            "Test3",
            "Test4",
            "Test5",
            ])
        
        let cv = UICollectionView()
//        cv.numberOfItemsInSection(0)
//        cv.cellForItemAtIndexPath()
        
        ds3 = SignalProducer<[String], NoError> { (obs, disposable) in
            obs.sendNext(self.ds1.value)
            self.ds3Obs = obs
        }
        
        ds4 = SignalProducer<[String], NoError> { (obs, disposable) in
            obs.sendNext(self.ds2.value)
        }

    }
    
    override func tearDown() {
        tableView = nil
        ds1 = nil
        ds2 = nil
        ds3 = nil
        ds4 = nil
    }
    
    //MARK: - Binding with a property
    //MARK: Binding using cell identifier
    
    func testBindingTableViewWithProperty_usingOneDataSourceWithCellIdentifiers_bindsDataCorrectly() {
        ds1.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 8, identifiersAtPath: [
            "FixtureCell1": NSIndexPath(forRow: 0, inSection: 0)
        ])
    }
    
    func testBindingTableViewWithProperty_usingMoreDataSourcesWithCellIdentifiers_bindsDataCorrectly() {
        ds1.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in }
        ds2.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell2")) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 13, identifiersAtPath: [
            "FixtureCell1": NSIndexPath(forRow: 0, inSection: 0),
            "FixtureCell2": NSIndexPath(forRow: 9, inSection: 0)
        ])
    }
    
    func testBindingTableViewWithProperty_overwritingAlreadySetIdentifier_overwritesIdentifier() {
        ds1.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in }
        ds2.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 5, identifiersAtPath: [
            "FixtureCell1": NSIndexPath(forRow: 0, inSection: 0),
        ])
    }
    
    func testBindingTableViewWithProperty_disposingaBinding_removesDataFromTableView() {
        let disposable1 = ds1.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in }
        let disposable2 = ds2.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell2")) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 13, identifiersAtPath: [
            "FixtureCell1": NSIndexPath(forRow: 0, inSection: 0),
            "FixtureCell2": NSIndexPath(forRow: 9, inSection: 0)
        ])
        
        disposable1.dispose()
        
        checkIfCorrect(tableView, numberOfItems: 5, identifiersAtPath: [
            "FixtureCell2": NSIndexPath(forRow: 0, inSection: 0)
        ])
        
        disposable2.dispose()
        
        checkIfCorrect(tableView, numberOfItems: 0)
    }
    
    func testBindingTableViewWithProperty_modifyingDataSource_reloadsTableView() {
        ds1.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 8, identifiersAtPath: [
            "FixtureCell1": NSIndexPath(forRow: 0, inSection: 0)
        ])
        
        ds1.value = ["Fixture1", "Fixture2"]
        
        checkIfCorrect(tableView, numberOfItems: 2)
    }
    
    //MARK: Binding using cell type
    
    func testBindingTableViewWithProperty_usingOneDataSourceWithCellType_bindsDataCorrectly() {
        ds1.bindTo(tableView.rac_items(cellType: TestCell1.self)) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 8, identifiersAtPath: [
            "TestCell1": NSIndexPath(forRow: 0, inSection: 0)
        ])
    }
    
    func testBindingTableViewWithProperty_usingMoreDataSourcesWithCellType_bindsDataCorrectly() {
        ds1.bindTo(tableView.rac_items(cellType: TestCell1.self)) { _ in }
        ds2.bindTo(tableView.rac_items(cellType: TestCell2.self)) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 13, identifiersAtPath: [
            "TestCell1": NSIndexPath(forRow: 0, inSection: 0),
            "TestCell2": NSIndexPath(forRow: 9, inSection: 0)
        ])
    }
    
    func testBindingTableViewWithProperty_usingCellType_cellConfigurationIsCorrect() {
        ds1.bindTo(tableView.rac_items(cellType: TestCell1.self)) { (_, cell, data) in
            cell.data = data
        }
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        
        expect(cell).to(beAKindOf(TestCell1))
        expect((cell as? TestCell1)?.data) == "Fixture1"
    }
    
    //MARK: - Binding with a signal producer
    //MARK: Binding using cell identifier
    
    func testBindingTableViewWithSignalProducer_usingOneDataSourceWithCellIdentifiers_bindsDataCorrectly() {
        ds3.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 8, identifiersAtPath: [
            "FixtureCell1": NSIndexPath(forRow: 0, inSection: 0)
            ])
    }
    
    func testBindingTableViewWithSignalProducer_usingMoreDataSourcesWithCellIdentifiers_bindsDataCorrectly() {
        ds3.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in }
        ds4.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell2")) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 13, identifiersAtPath: [
            "FixtureCell1": NSIndexPath(forRow: 0, inSection: 0),
            "FixtureCell2": NSIndexPath(forRow: 9, inSection: 0)
            ])
    }
    
    func testBindingTableViewWithSignalProducer_overwritingAlreadySetIdentifier_overwritesIdentifier() {
        ds3.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in }
        ds4.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 5, identifiersAtPath: [
            "FixtureCell1": NSIndexPath(forRow: 0, inSection: 0),
            ])
    }
    
    func testBindingTableViewWithSignalProducer_disposingaBinding_removesDataFromTableView() {
        let disposable1 = ds3.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in }
        let disposable2 = ds4.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell2")) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 13, identifiersAtPath: [
            "FixtureCell1": NSIndexPath(forRow: 0, inSection: 0),
            "FixtureCell2": NSIndexPath(forRow: 9, inSection: 0)
            ])
        
        disposable1.dispose()
        
        checkIfCorrect(tableView, numberOfItems: 5, identifiersAtPath: [
            "FixtureCell2": NSIndexPath(forRow: 0, inSection: 0)
            ])
        
        disposable2.dispose()
        
        checkIfCorrect(tableView, numberOfItems: 0)
    }
    
    func testBindingTableViewWithSignalProducer_modifyingDataSource_reloadsTableView() {
        ds3.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 8, identifiersAtPath: [
            "FixtureCell1": NSIndexPath(forRow: 0, inSection: 0)
            ])
        
        ds3Obs.sendNext(["Fixture1", "Fixture2"])
        
        checkIfCorrect(tableView, numberOfItems: 2)
    }
    
    //MARK: Binding using cell type
    
    func testBindingTableViewWithSignalProducer_usingOneDataSourceWithCellType_bindsDataCorrectly() {
        ds3.bindTo(tableView.rac_items(cellType: TestCell1.self)) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 8, identifiersAtPath: [
            "TestCell1": NSIndexPath(forRow: 0, inSection: 0)
            ])
    }
    
    func testBindingTableViewWithSignalProducer_usingMoreDataSourcesWithCellType_bindsDataCorrectly() {
        ds3.bindTo(tableView.rac_items(cellType: TestCell1.self)) { _ in }
        ds4.bindTo(tableView.rac_items(cellType: TestCell2.self)) { _ in }
        
        checkIfCorrect(tableView, numberOfItems: 13, identifiersAtPath: [
            "TestCell1": NSIndexPath(forRow: 0, inSection: 0),
            "TestCell2": NSIndexPath(forRow: 9, inSection: 0)
            ])
    }
    
    func testBindingTableViewWithSignalProducer_usingCellType_cellConfigurationIsCorrect() {
        ds3.bindTo(tableView.rac_items(cellType: TestCell1.self)) { (_, cell, data) in
            cell.data = data
        }
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        
        expect(cell).to(beAKindOf(TestCell1))
        expect((cell as? TestCell1)?.data) == "Fixture1"
    }
    
}

//MARK: - Private

extension ReactiveTableViewTests {
    
    private func checkIfCorrect(tableView: UITableView, numberOfItems: Int, identifiersAtPath: [String: NSIndexPath]? = nil) {
        expect(tableView.numberOfRowsInSection(0)) == numberOfItems
        
        for (identifier, path) in identifiersAtPath ?? [:] {
            expect(tableView.cellForRowAtIndexPath(path)?.reuseIdentifier) == identifier
        }
    }
}
