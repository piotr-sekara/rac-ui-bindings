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
import ReactiveCocoa
import Result

class FakeDelegate: NSObject, UITextFieldDelegate {
    var editingStarted = false
    var editingEnded = false
    var textSignal = ""
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.editingEnded = true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.editingStarted = true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        self.textSignal = ((textField.text ?? "") as NSString).stringByReplacingCharactersInRange(range, withString: string)
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
        self.sut.rac_editingStarted.observeNext {
            eventObserved = true
        }
        
        self.sut.delegate?.textFieldDidBeginEditing?(self.sut)
        
        expect(eventObserved).toEventually(beTruthy())
    }
    
    func testTextFieldBinding_editingEndedSignal_shouldGetEndedEvents() {
        var eventObserved = false
        self.sut.rac_editingEnded.observeNext {
            eventObserved = true
        }
        
        self.sut.delegate?.textFieldDidEndEditing?(self.sut)
        
        expect(eventObserved).toEventually(beTruthy())
    }
    
    func testTextFieldBinding_changingTextFieldContent_shouldGetContentViaSignal() {
        var text = ""
        self.sut.rac_textSignal.observeNext { val in
            text = val
        }
        
        self.sut.delegate?.textField?(sut, shouldChangeCharactersInRange: NSRange(location: 0, length: 0), replacementString: "Fixture text")
        
        expect(text).toEventually(equal("Fixture text"))
    }
    
    func testTextFieldBinding_havingDelegateAlready_shouldGetStartedSignal() {
        self.sut.delegate = self.delegate
        var eventObserved = false
        self.sut.rac_editingStarted.observeNext {
            eventObserved = true
        }
        
        self.sut.delegate?.textFieldDidBeginEditing?(self.sut)
        
        expect(eventObserved).toEventually(beTruthy())
        expect(self.delegate.editingStarted).to(beTruthy())
    }
    
    
    
}
