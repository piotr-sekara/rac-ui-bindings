//
//  ReactiveButtonTests.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 29.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import XCTest
import Nimble
@testable import ReactiveUIBindings
import ReactiveCocoa
import ReactiveSwift
import Result

class ReactiveButtonTests: XCTestCase {
    
    var sut: UIButton!
    
    var titleNormal 		= MutableProperty<String>("titleNormal")
    var titleHighlighted 	= MutableProperty<String>("titleHighlighted")
    var titleDisabled 		= MutableProperty<String>("titleDisabled")
    var titleSelected 		= MutableProperty<String>("titleSelected")
    var titleFocused 		= MutableProperty<String>("titleFocused")
    var enabledProperty     = MutableProperty<Bool>(true)
    
    var window: UIWindow!
    var ctrl: UIViewController!
    
    override func setUp() {
        window = UIWindow()
        ctrl = UIViewController()
        sut = UIButton()
        
        window.rootViewController = ctrl
        
        ctrl.view.addSubview(sut)
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func testButtonTitle_setNoTitle_shouldBeNil() {
        expect(self.sut.title(for: .normal)).to(beNil())
    }
    
    func testButtonTitle_bindingTitlesToStates_shouldSetTitle() {
        self.setupBindings()
        
        expect(self.sut.title(for: .normal)) == "titleNormal"
        expect(self.sut.title(for: .highlighted)) == "titleHighlighted"
        expect(self.sut.title(for: .disabled)) == "titleDisabled"
        expect(self.sut.title(for: .selected)) == "titleSelected"
        expect(self.sut.title(for: .focused)) == "titleFocused"
    }
    
    func testButtonTitle_bindingTitlesAndUpdatingStrings_shouldUpdateTitle() {
        self.setupBindings()
        
        self.titleNormal.swap("updatedNormal")
        self.titleSelected.swap("updatedSelected")
        self.titleDisabled.swap("updatedDisabled")
        
        expect(self.sut.title(for: .normal)) == "updatedNormal"
        expect(self.sut.title(for: .highlighted)) == "titleHighlighted"
        expect(self.sut.title(for: .disabled)) == "updatedDisabled"
        expect(self.sut.title(for: .selected)) == "updatedSelected"
        expect(self.sut.title(for: .focused)) == "titleFocused"
    }
    
    func testButtonEnabled_bindVariable_shouldSetAndUpdateEnabledState() {
        sut.reactive.isEnabled <~ self.enabledProperty
        
        expect(self.sut.isEnabled) == true
        
        self.enabledProperty.value = false
        
        expect(self.sut.isEnabled) == false
    }
    
    func testButtonSelected_bindVariable_shouldSetAndUpdateSelectedState() {
        sut.reactive.isSelected <~ self.enabledProperty
        
        expect(self.sut.isSelected) == true
        
        self.enabledProperty.value = false
        
        expect(self.sut.isSelected) == false
    }
    
//    func testControlEvents_bindSignalToEvent_shouldSendValueWhenReceivedEvent() {
//        var eventReceived = false
//        
//        sut.reactive.actions(for: .touchUpInside).observeValues { _ in
//            eventReceived = true
//        }
//        let obs = Observer()
//    
//        sut.addTarget(obs, action: #selector(Observer.observed(_:)), for: .touchUpInside)
//        
//        print(sut.allControlEvents)
//        print(sut.allTargets)
//        
//
//        expect(eventReceived).toEventually(beTruthy())
//    }
    
}


extension ReactiveButtonTests {
    fileprivate func setupBindings() {
        sut.reactive.title(for: .normal) <~ self.titleNormal
        sut.reactive.title(for: .highlighted) <~ self.titleHighlighted
        sut.reactive.title(for: .disabled) <~ self.titleDisabled
        sut.reactive.title(for: .selected) <~ self.titleSelected
        sut.reactive.title(for: .focused) <~ self.titleFocused
    }
}
