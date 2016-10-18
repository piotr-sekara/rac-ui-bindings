//
//  RACReusableTests.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 18.10.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import XCTest
import Nimble

@testable import ReactiveUIBindings
import ReactiveSwift
import Result

class RACReusableTests: XCTestCase {
    
    var sut: UICollectionViewCell!
    var sut2: UITableViewCell!
    
    override func setUp() {
        sut = UICollectionViewCell()
        sut2 = UITableViewCell()
    }
    
    override func tearDown() {
        sut = nil
        sut2 = nil
    }
    
    func testCollectionViewCell_prepareForReuseSignal_sendsValuesWhenViewIsReused() {
        var signalReceived = false
        
        sut.rac.prepareForReuse.observeValues {
            signalReceived = true
        }
        
        sut.prepareForReuse()
        
        expect(signalReceived).to(beTruthy())
    }
    
    func testTableViewCell_prepareForReuseSignal_sendValuesWhenViewIsReused() {
        var signalReceived = false
        
        sut2.rac.prepareForReuse.observeValues {
            signalReceived = true
        }
        
        sut2.prepareForReuse()
        
        expect(signalReceived).to(beTruthy())
    }
    
}
