//
//  ReactiveAlertViewTests.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 07.10.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import XCTest
import Nimble

@testable import ReactiveUIBindings
import ReactiveSwift
import Result

@available(iOS, deprecated: 9.0)
class FakeAlertViewDelegate: NSObject, UIAlertViewDelegate {
    var buttonClicked = -1
    var cancelled = false
    var willPresent = false
    var didPresent = false
    var willDismiss = false
    var didDismiss = false
    var shouldEnableFirstOther = false
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        buttonClicked = buttonIndex
    }
    
    func alertViewCancel(_ alertView: UIAlertView) {
        cancelled = true
    }
    
    func willPresent(_ alertView: UIAlertView) {
        willPresent = true
    }
    
    func didPresent(_ alertView: UIAlertView) {
        didPresent = true
    }
    
    func alertView(_ alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        willDismiss = true
    }
    
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        didDismiss = true
    }
    
    func alertViewShouldEnableFirstOtherButton(_ alertView: UIAlertView) -> Bool {
        shouldEnableFirstOther = true
        return true
    }

}

@available(iOS, deprecated: 9.0)
class ReactiveAlertViewTests: XCTestCase {
    
    var sut: UIAlertView!
    var delegate: FakeAlertViewDelegate!
    
    override func setUp() {
        sut = UIAlertView(title: "", message: "", delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "ok")
        delegate = FakeAlertViewDelegate()
    }
    
    override func tearDown() {
        sut = nil
        delegate = nil
    }
    
    func testAlertViewBinding_buttonClicked_shouldGetAppropriateIdx() {
        var eventObserved = -1
        self.sut.reactive.buttonClicked().observeValues { (idx: Int) in
            eventObserved = idx
        }
        
        self.sut.delegate?.alertView(self.sut, clickedButtonAt: 1)
        
        expect(eventObserved).toEventually(equal(1))
    }
    
    func testAlertViewBinding_buttonClickedWithTextField_shouldGetIdxAndTextField() {
        sut.alertViewStyle = .plainTextInput
        sut.textField(at: 0)?.text = "fixture"
        var eventObserved = (-1, Optional.some(""))
        
        self.sut.reactive.buttonClicked().observeValues { (idx, textField) in
            eventObserved = (idx, textField.text)
        }
        
        self.sut.delegate?.alertView(self.sut, clickedButtonAt: 0)
        
        expect(eventObserved.0).toEventually(equal(0))
        expect(eventObserved.1).toEventually(equal("fixture"))
    }
    
    func testAlertViewBindings_buttonClickedWithLoginAndPassword_shouldReturnAppropriateFields() {
        sut.alertViewStyle = .loginAndPasswordInput
        sut.textField(at: 0)?.text = "login"
        sut.textField(at: 1)?.text = "password"
        var eventObserved = (-1, Optional.some(""), Optional.some(""))
        
        self.sut.reactive.buttonClicked().observeValues { (idx, login, password) in
            eventObserved = (idx, login.text, password.text)
        }
        
        self.sut.delegate?.alertView(self.sut, clickedButtonAt: 0)
        
        expect(eventObserved.0).toEventually(equal(0))
        expect(eventObserved.1).toEventually(equal("login"))
        expect(eventObserved.2).toEventually(equal("password"))
    }
    
    //MARK: - Delegate already set 
    
    func testAlertViewBindingHavingDelegate_buttonClicked_shouldGetIdx() {
        self.sut.delegate = self.delegate
        var eventObserved = -1
        self.sut.reactive.buttonClicked().observeValues { (idx: Int) in
            eventObserved = idx
        }
        
        self.sut.delegate?.alertView(self.sut, clickedButtonAt: 1)
        
        expect(eventObserved).toEventually(equal(1))
        expect(self.delegate.buttonClicked).to(equal(1))
    }
    
}
