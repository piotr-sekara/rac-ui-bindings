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

protocol UITestCollection {
    associatedtype Reusable
    init(frame: CGRect)
    
    func registerClass(type: Reusable, forCellReuseIdentifier: String)
}

extension UITableView: UITestCollection {}
extension UICollectionView: UITestCollection {
    func registerClass(type: AnyClass?, forCellReuseIdentifier: String) {
        self.registerClass(type, forCellWithReuseIdentifier: forCellReuseIdentifier)
    }
}

class ReactiveCollectionTests<C: UITestCollection>: XCTestCase {
    var tableView: UITableView!
    
    var ds1: MutableProperty<[String]>!
    var ds2: MutableProperty<[String]>!
    var ds3: SignalProducer<[String], NoError>!
    var ds4: SignalProducer<[String], NoError>!
    
    var ds3Obs: Signal<[String], NoError>.Observer!

    

}

class TestRunner: XCTestCase {
    override class func initialize() {
        super.initialize()
        let wtf = XCTestSuite(forTestCaseClass: ReactiveCollectionTests<UITableView>.self)
        wtf.runTest()
    }
}


extension ReactiveCollectionTests {
    
    private func checkIfCorrect(tableView: UITableView, numberOfItems: Int, identifiersAtPath: [String: NSIndexPath]? = nil) {
        expect(tableView.numberOfRowsInSection(0)) == numberOfItems
        
        for (identifier, path) in identifiersAtPath ?? [:] {
            expect(tableView.cellForRowAtIndexPath(path)?.reuseIdentifier) == identifier
        }
    }
}
