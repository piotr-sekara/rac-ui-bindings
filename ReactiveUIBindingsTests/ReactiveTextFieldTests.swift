//
//  ReactiveTextFieldTests.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 31.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import XCTest
import Nimble

@testable import ReactiveUIBindings
import ReactiveSwift
import Result

class FakeDelegate: NSObject, UITextFieldDelegate {
    var editingStarted = false
    var editingEnded = false
    var textSignal = ""
    var textFieldShouldBeginEditing = false
    var textFieldShouldClear = false
    var textFieldShouldReturn = false
    var textFieldShouldEndEditing = false
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.editingEnded = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.editingStarted = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.textSignal = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textFieldShouldBeginEditing = true
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.textFieldShouldClear = true
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textFieldShouldReturn = true
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.textFieldShouldEndEditing = true
        return true
    }
}

class ReactiveTextFieldTests: XCTestCase {
    
    var sut: UITextField!
    var delegate: FakeDelegate!
    
    override func setUp() {
        sut = UITextField()
        delegate = FakeDelegate()
    }
    
    override func tearDown() {
        sut = nil
        delegate = nil
    }
    
    func testTextFieldBinding_editingStartedSignal_shouldGetStartedEvents() {
        var eventObserved = false
        self.sut.reactive.editingStarted.observeValues {
            eventObserved = true
        }
        
        self.sut.delegate?.textFieldDidBeginEditing?(self.sut)
        
        expect(eventObserved).toEventually(beTruthy())
    }
    
    func testTextFieldBinding_editingEndedSignal_shouldGetEndedEvents() {
        var eventObserved = false
        self.sut.reactive.editingEnded.observeValues {
            eventObserved = true
        }
        
        self.sut.delegate?.textFieldDidEndEditing?(self.sut)
        
        expect(eventObserved).toEventually(beTruthy())
    }
    
    
    //MARK: - Delegate already set
    
    func testTextFieldBinding_havingDelegateAlready_shouldGetStartedSignal() {
        self.sut.delegate = self.delegate
        var eventObserved = false
        self.sut.reactive.editingStarted.observeValues {
            eventObserved = true
        }
        
        self.sut.delegate?.textFieldDidBeginEditing?(self.sut)
        
        expect(eventObserved).toEventually(beTruthy())
        expect(self.delegate.editingStarted).to(beTruthy())
    }
    
    func testTextFieldBinding_havingDelegateAlready_shouldGetEndedSignal() {
        self.sut.delegate = self.delegate
        var eventObserved = false
        self.sut.reactive.editingEnded.observeValues {
            eventObserved = true
        }
        
        self.sut.delegate?.textFieldDidEndEditing?(self.sut)
        
        expect(eventObserved).toEventually(beTruthy())
        expect(self.delegate.editingEnded).to(beTruthy())
    }
    

    
    func testTextFieldBinding_havingDelegateAlready_receivesAllOtherDelegateMethods() {
        self.sut.delegate = self.delegate
        
        var eventsObserved = 0
        self.sut.reactive.editingStarted.observeValues { eventsObserved += 1 }
        self.sut.reactive.editingEnded.observeValues { eventsObserved += 1 }
        
        self.sut.delegate?.textFieldDidBeginEditing?(self.sut)
        self.sut.delegate?.textFieldDidEndEditing?(self.sut)
        _ = self.sut.delegate?.textField?(sut, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "Fixture text")
        _ = self.sut.delegate?.textFieldShouldBeginEditing?(self.sut)
        _ = self.sut.delegate?.textFieldShouldClear?(self.sut)
        _ = self.sut.delegate?.textFieldShouldReturn?(self.sut)
        _ = self.sut.delegate?.textFieldShouldEndEditing?(self.sut)
        
        expect(eventsObserved).toEventually(equal(2))
        expect(self.delegate.textFieldShouldBeginEditing) == true
        expect(self.delegate.textFieldShouldClear) == true
        expect(self.delegate.textFieldShouldReturn) == true
        expect(self.delegate.textFieldShouldEndEditing) == true
    }
    
}
