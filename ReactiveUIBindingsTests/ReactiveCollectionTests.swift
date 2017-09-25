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
import ReactiveSwift
import Result

class ReactiveCollectionTests<C: UITestCollection, Cell1: UITestCell, Cell2: UITestCell>: XCTestCase where C.Cell: ReusableCell {
    
    var sut: C!
    
    var ds1: MutableProperty<[String]>!
    var ds2: MutableProperty<[String]>!
    var ds3: SignalProducer<[String], NoError>!
    var ds4: SignalProducer<[String], NoError>!
    
    var ds3Obs: Signal<[String], NoError>.Observer!
    
    override func setUp() {
        sut = C.createInstance() as! C
        sut.registerClass(Cell1.self, forIdentifier: String(describing: Cell1.self))
        sut.registerClass(Cell2.self, forIdentifier: String(describing: Cell2.self))
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
            obs.send(value: self.ds1.value)
            self.ds3Obs = obs
        }
        
        ds4 = SignalProducer<[String], NoError> { (obs, disposable) in
            obs.send(value: self.ds2.value)
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
            C.testCellIdentifier1 : IndexPath(row: 0, section: 0)
        ])
    }
    
    func testBindingCollectionWithProperty_usingMoreDataSourcesWithCellIdentifiers_bindsDataCorrectly() {
        sut.bindWith(ds1, identifier: C.testCellIdentifier1)
        sut.bindWith(ds2, identifier: C.testCellIdentifier2)
        
        checkIfCorrect(sut, numberOfItems: 13, identifiersAtPath: [
            C.testCellIdentifier1 : IndexPath(row: 0, section: 0),
            C.testCellIdentifier2 : IndexPath(row: 9, section: 0)
            ])
    }

    func testBindingCollectionWithProperty_overwritingAlreadySetIdentifier_overwritesIdentifier() {
        sut.bindWith(ds1, identifier: C.testCellIdentifier1)
        sut.bindWith(ds2, identifier: C.testCellIdentifier1)
        
        checkIfCorrect(sut, numberOfItems: 5, identifiersAtPath: [
            C.testCellIdentifier1 : IndexPath(row: 0, section: 0),
            ])
    }

    func testBindingCollectionWithProperty_disposingaBinding_removesDataFromTableView() {
        let disposable1 = sut.bindWith(ds1, identifier: C.testCellIdentifier1)
        let disposable2 = sut.bindWith(ds2, identifier: C.testCellIdentifier2)
        
        checkIfCorrect(sut, numberOfItems: 13, identifiersAtPath: [
            C.testCellIdentifier1 : IndexPath(row: 0, section: 0),
            C.testCellIdentifier2 : IndexPath(row: 9, section: 0)
            ])
        
        disposable1.dispose()
        
        checkIfCorrect(sut, numberOfItems: 5, identifiersAtPath: [
            C.testCellIdentifier2 : IndexPath(row: 0, section: 0)
            ])
        
        disposable2.dispose()
        
        checkIfCorrect(sut, numberOfItems: 0)
    }

    func testBindingCollectionWithProperty_modifyingDataSource_reloadsTableView() {
        sut.bindWith(ds1, identifier: C.testCellIdentifier1)
        
        checkIfCorrect(sut, numberOfItems: 8, identifiersAtPath: [
            C.testCellIdentifier1 : IndexPath(row: 0, section: 0)
            ])
        
        ds1.value = ["Fixture1", "Fixture2"]
        
        checkIfCorrect(sut, numberOfItems: 2)
    }


    //MARK: - Binding with a signal producer
    //MARK: Binding using cell identifier
    
    func testBindingCollectionWithSignalProducer_usingOneDataSourceWithCellIdentifiers_bindsDataCorrectly() {
        sut.bindWith(ds3, identifier: C.testCellIdentifier1)
        
        checkIfCorrect(sut, numberOfItems: 8, identifiersAtPath: [
            C.testCellIdentifier1 : IndexPath(row: 0, section: 0)
            ])
    }
    
    func testBindingCollectionWithSignalProducer_usingMoreDataSourcesWithCellIdentifiers_bindsDataCorrectly() {
        sut.bindWith(ds3, identifier: C.testCellIdentifier1)
        sut.bindWith(ds4, identifier: C.testCellIdentifier2)
        
        checkIfCorrect(sut, numberOfItems: 13, identifiersAtPath: [
            C.testCellIdentifier1 : IndexPath(row: 0, section: 0),
            C.testCellIdentifier2 : IndexPath(row: 9, section: 0)
            ])
    }

    func testBindingCollectionWithSignalProducer_overwritingAlreadySetIdentifier_overwritesIdentifier() {
        sut.bindWith(ds3, identifier: C.testCellIdentifier1)
        sut.bindWith(ds4, identifier: C.testCellIdentifier1)
        
        checkIfCorrect(sut, numberOfItems: 5, identifiersAtPath: [
            C.testCellIdentifier1 : IndexPath(row: 0, section: 0),
            ])
    }

    func testBindingCollectionWithSignalProducer_disposingaBinding_removesDataFromTableView() {
        let disposable1 = sut.bindWith(ds3, identifier: C.testCellIdentifier1)
        let disposable2 = sut.bindWith(ds4, identifier: C.testCellIdentifier2)
        
        checkIfCorrect(sut, numberOfItems: 13, identifiersAtPath: [
            C.testCellIdentifier1 : IndexPath(row: 0, section: 0),
            C.testCellIdentifier2 : IndexPath(row: 9, section: 0)
            ])
        
        disposable1.dispose()
        
        checkIfCorrect(sut, numberOfItems: 5, identifiersAtPath: [
            C.testCellIdentifier2 : IndexPath(row: 0, section: 0)
            ])
        
        disposable2.dispose()
        
        checkIfCorrect(sut, numberOfItems: 0)
    }

    func testBindingCollectionWithSignalProducer_modifyingDataSource_reloadsTableView() {
        sut.bindWith(ds3, identifier: C.testCellIdentifier1)
        
        checkIfCorrect(sut, numberOfItems: 8, identifiersAtPath: [
            C.testCellIdentifier1 : IndexPath(row: 0, section: 0)
            ])
        
        ds3Obs.send(value: ["Fixture1", "Fixture2"])
        
        checkIfCorrect(sut, numberOfItems: 2)
    }
    
}

class TestRunner: XCTestCase {
    
    override init() {
        super.init()
        TestRunner.doInitialize
    }
    
    static let doInitialize: Void = {
        XCTestSuite(forTestCaseClass: ReactiveCollectionTests<UITableView, TestTableCell1, TestTableCell2>.self).run()
        XCTestSuite(forTestCaseClass: ReactiveCollectionTests<UICollectionView, TestCollectionCell1, TestCollectionCell2>.self).run()
    }()
}


extension ReactiveCollectionTests {
    
    fileprivate func checkIfCorrect(_ sut: C, numberOfItems: Int, identifiersAtPath: [String: IndexPath]? = nil) {
        expect(sut.numberOfItems(0)) == numberOfItems
        
        for (identifier, path) in identifiersAtPath ?? [:] {
            let cell = sut.cellForItem(path)
            expect(cell).notTo(beNil())
            expect(cell?.reuseIdentifier) == identifier
        }
    }
}
