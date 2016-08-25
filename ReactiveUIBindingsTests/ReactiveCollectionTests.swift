//
//  ReactiveCollectionTests.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 23.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import XCTest
import Nimble

@testable import ReactiveUIBindings
import ReactiveCocoa
import Result

class ReactiveCollectionTests<C: UITestCollection, Cell1: UITestCell, Cell2: UITestCell>: XCTestCase {
    
    var sut: C!
    
    var ds1: MutableProperty<[String]>!
    var ds2: MutableProperty<[String]>!
    var ds3: SignalProducer<[String], NoError>!
    var ds4: SignalProducer<[String], NoError>!
    
    var ds3Obs: Signal<[String], NoError>.Observer!
    
    override func setUp() {
        sut = C.createInstance() as! C
        sut.registerClass(Cell1.self, forIdentifier: Cell1.defaultReuseIdentifier)
        sut.registerClass(Cell2.self, forIdentifier: Cell2.defaultReuseIdentifier)
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
        
        ds3 = SignalProducer<[String], NoError> { (obs, disposable) in
            obs.sendNext(self.ds1.value)
            self.ds3Obs = obs
        }
        
        ds4 = SignalProducer<[String], NoError> { (obs, disposable) in
            obs.sendNext(self.ds2.value)
        }
        
    }
    
    override func tearDown() {
        sut = nil
        ds1 = nil
        ds2 = nil
        ds3 = nil
        ds4 = nil
    }
    
    //MARK: - Binding with a property
    //MARK: Binding using cell identifier
    
    func testBindingCollectionWithProperty_usingOneDataSourceWithCellIdentifiers_bindsDataCorrectly() {
        sut.bindWith(ds1, identifier: C.testCellIdentifier1)
        
        checkIfCorrect(sut, numberOfItems: 8, identifiersAtPath: [
            C.testCellIdentifier1 : NSIndexPath(forRow: 0, inSection: 0)
        ])
    }
    
    func testBindingCollectionWithProperty_usingMoreDataSourcesWithCellIdentifiers_bindsDataCorrectly() {
        sut.bindWith(ds1, identifier: C.testCellIdentifier1)
        sut.bindWith(ds2, identifier: C.testCellIdentifier2)
        
        checkIfCorrect(sut, numberOfItems: 13, identifiersAtPath: [
            C.testCellIdentifier1 : NSIndexPath(forRow: 0, inSection: 0),
            C.testCellIdentifier2 : NSIndexPath(forRow: 9, inSection: 0)
            ])
    }

    func testBindingCollectionWithProperty_overwritingAlreadySetIdentifier_overwritesIdentifier() {
        sut.bindWith(ds1, identifier: C.testCellIdentifier1)
        sut.bindWith(ds2, identifier: C.testCellIdentifier1)
        
        checkIfCorrect(sut, numberOfItems: 5, identifiersAtPath: [
            C.testCellIdentifier1 : NSIndexPath(forRow: 0, inSection: 0),
            ])
    }

    func testBindingCollectionWithProperty_disposingaBinding_removesDataFromTableView() {
        let disposable1 = sut.bindWith(ds1, identifier: C.testCellIdentifier1)
        let disposable2 = sut.bindWith(ds2, identifier: C.testCellIdentifier2)
        
        checkIfCorrect(sut, numberOfItems: 13, identifiersAtPath: [
            C.testCellIdentifier1 : NSIndexPath(forRow: 0, inSection: 0),
            C.testCellIdentifier2 : NSIndexPath(forRow: 9, inSection: 0)
            ])
        
        disposable1.dispose()
        
        checkIfCorrect(sut, numberOfItems: 5, identifiersAtPath: [
            C.testCellIdentifier2 : NSIndexPath(forRow: 0, inSection: 0)
            ])
        
        disposable2.dispose()
        
        checkIfCorrect(sut, numberOfItems: 0)
    }

    func testBindingCollectionWithProperty_modifyingDataSource_reloadsTableView() {
        sut.bindWith(ds1, identifier: C.testCellIdentifier1)
        
        checkIfCorrect(sut, numberOfItems: 8, identifiersAtPath: [
            C.testCellIdentifier1 : NSIndexPath(forRow: 0, inSection: 0)
            ])
        
        ds1.value = ["Fixture1", "Fixture2"]
        
        checkIfCorrect(sut, numberOfItems: 2)
    }

    //MARK: Binding using cell type

    func testBindingCollectionWithProperty_usingOneDataSourceWithCellType_bindsDataCorrectly() {
        sut.bindWith(ds1, cellType: Cell1.self)
        
        checkIfCorrect(sut, numberOfItems: 8, identifiersAtPath: [
            Cell1.defaultReuseIdentifier: NSIndexPath(forRow: 0, inSection: 0)
            ])
    }
    
    func testBindingCollectionWithProperty_usingMoreDataSourcesWithCellType_bindsDataCorrectly() {
        sut.bindWith(ds1, cellType: Cell1.self)
        sut.bindWith(ds2, cellType: Cell2.self)
        
        checkIfCorrect(sut, numberOfItems: 13, identifiersAtPath: [
            Cell1.defaultReuseIdentifier: NSIndexPath(forRow: 0, inSection: 0),
            Cell2.defaultReuseIdentifier: NSIndexPath(forRow: 9, inSection: 0)
            ])
    }
    
    func testBindingCollectionWithProperty_usingCellType_cellConfigurationIsCorrect() {
        sut.bindWith(ds1, cellType: Cell1.self)
        
        let cell = sut.cellForItem(NSIndexPath(forRow: 0, inSection: 0))
        
        expect((cell as? Cell1)?.data) == "Fixture1"
    }

    //MARK: - Binding with a signal producer
    //MARK: Binding using cell identifier
    
    func testBindingCollectionWithSignalProducer_usingOneDataSourceWithCellIdentifiers_bindsDataCorrectly() {
        sut.bindWith(ds3, identifier: C.testCellIdentifier1)
        
        checkIfCorrect(sut, numberOfItems: 8, identifiersAtPath: [
            C.testCellIdentifier1 : NSIndexPath(forRow: 0, inSection: 0)
            ])
    }
    
    func testBindingCollectionWithSignalProducer_usingMoreDataSourcesWithCellIdentifiers_bindsDataCorrectly() {
        sut.bindWith(ds3, identifier: C.testCellIdentifier1)
        sut.bindWith(ds4, identifier: C.testCellIdentifier2)
        
        checkIfCorrect(sut, numberOfItems: 13, identifiersAtPath: [
            C.testCellIdentifier1 : NSIndexPath(forRow: 0, inSection: 0),
            C.testCellIdentifier2 : NSIndexPath(forRow: 9, inSection: 0)
            ])
    }

    func testBindingCollectionWithSignalProducer_overwritingAlreadySetIdentifier_overwritesIdentifier() {
        sut.bindWith(ds3, identifier: C.testCellIdentifier1)
        sut.bindWith(ds4, identifier: C.testCellIdentifier1)
        
        checkIfCorrect(sut, numberOfItems: 5, identifiersAtPath: [
            C.testCellIdentifier1 : NSIndexPath(forRow: 0, inSection: 0),
            ])
    }

    func testBindingCollectionWithSignalProducer_disposingaBinding_removesDataFromTableView() {
        let disposable1 = sut.bindWith(ds3, identifier: C.testCellIdentifier1)
        let disposable2 = sut.bindWith(ds4, identifier: C.testCellIdentifier2)
        
        checkIfCorrect(sut, numberOfItems: 13, identifiersAtPath: [
            C.testCellIdentifier1 : NSIndexPath(forRow: 0, inSection: 0),
            C.testCellIdentifier2 : NSIndexPath(forRow: 9, inSection: 0)
            ])
        
        disposable1.dispose()
        
        checkIfCorrect(sut, numberOfItems: 5, identifiersAtPath: [
            C.testCellIdentifier2 : NSIndexPath(forRow: 0, inSection: 0)
            ])
        
        disposable2.dispose()
        
        checkIfCorrect(sut, numberOfItems: 0)
    }

    func testBindingCollectionWithSignalProducer_modifyingDataSource_reloadsTableView() {
        sut.bindWith(ds3, identifier: C.testCellIdentifier1)
        
        checkIfCorrect(sut, numberOfItems: 8, identifiersAtPath: [
            C.testCellIdentifier1 : NSIndexPath(forRow: 0, inSection: 0)
            ])
        
        ds3Obs.sendNext(["Fixture1", "Fixture2"])
        
        checkIfCorrect(sut, numberOfItems: 2)
    }
    
    //MARK: Binding using cell type
    
    func testBindingCollectionWithSignalProducer_usingOneDataSourceWithCellType_bindsDataCorrectly() {
        sut.bindWith(ds3, cellType: Cell1.self)
        
        checkIfCorrect(sut, numberOfItems: 8, identifiersAtPath: [
            Cell1.defaultReuseIdentifier: NSIndexPath(forRow: 0, inSection: 0)
            ])
    }
    
    func testBindingCollectionWithSignalProducer_usingMoreDataSourcesWithCellType_bindsDataCorrectly() {
        sut.bindWith(ds3, cellType: Cell1.self)
        sut.bindWith(ds4, cellType: Cell2.self)
        
        checkIfCorrect(sut, numberOfItems: 13, identifiersAtPath: [
            Cell1.defaultReuseIdentifier: NSIndexPath(forRow: 0, inSection: 0),
            Cell2.defaultReuseIdentifier: NSIndexPath(forRow: 9, inSection: 0)
            ])
    }
    
    func testBindingCollectionWithSignalProducer_usingCellType_cellConfigurationIsCorrect() {
        sut.bindWith(ds3, cellType: Cell1.self)
        
        let cell = sut.cellForItem(NSIndexPath(forRow: 0, inSection: 0))
        
        expect((cell as? Cell1)?.data) == "Fixture1"
    }
}

class TestRunner: XCTestCase {
    
    override class func initialize() {
        super.initialize()
        XCTestSuite(forTestCaseClass: ReactiveCollectionTests<UITableView, TestTableCell1, TestTableCell2>.self).runTest()
        XCTestSuite(forTestCaseClass: ReactiveCollectionTests<UICollectionView, TestCollectionCell1, TestCollectionCell2>.self).runTest()
    }
}


extension ReactiveCollectionTests {
    
    private func checkIfCorrect(sut: C, numberOfItems: Int, identifiersAtPath: [String: NSIndexPath]? = nil) {
        expect(sut.numberOfItems(0)) == numberOfItems
        
        for (identifier, path) in identifiersAtPath ?? [:] {
            let cell = sut.cellForItem(path) as? ReusableView
            expect(cell).notTo(beNil())
            expect(cell?.reuseIdentifier) == identifier
        }
    }
}
