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
import Result

class ReactiveButtonTests: XCTestCase {
    
    var sut: UIButton!
    
    var titleNormal 		= MutableProperty<String?>("titleNormal")
    var titleHighlighted 	= MutableProperty<String?>("titleHighlighted")
    var titleDisabled 		= MutableProperty<String?>("titleDisabled")
    var titleSelected 		= MutableProperty<String?>("titleSelected")
    var titleFocused 		= MutableProperty<String?>("titleFocused")
    var enabledProperty     = MutableProperty<Bool>(true)
    
    override func setUp() {
        sut = UIButton()
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func testButtonTitle_setNoTitle_shouldBeNil() {
        expect(self.sut.titleForState(.Normal)).to(beNil())
    }
    
    func testButtonTitle_bindingTitlesToStates_shouldSetTitle() {
        self.setupBindings()
        
        expect(self.sut.titleForState(.Normal)) == "titleNormal"
        expect(self.sut.titleForState(.Highlighted)) == "titleHighlighted"
        expect(self.sut.titleForState(.Disabled)) == "titleDisabled"
        expect(self.sut.titleForState(.Selected)) == "titleSelected"
        expect(self.sut.titleForState(.Focused)) == "titleFocused"
    }
    
    func testButtonTitle_bindingTitlesAndUpdatingStrings_shouldUpdateTitle() {
        self.setupBindings()
        
        self.titleNormal.swap("updatedNormal")
        self.titleSelected.swap("updatedSelected")
        self.titleDisabled.swap("updatedDisabled")
        
        expect(self.sut.titleForState(.Normal)) == "updatedNormal"
        expect(self.sut.titleForState(.Highlighted)) == "titleHighlighted"
        expect(self.sut.titleForState(.Disabled)) == "updatedDisabled"
        expect(self.sut.titleForState(.Selected)) == "updatedSelected"
        expect(self.sut.titleForState(.Focused)) == "titleFocused"
    }
    
    func testButtonEnabled_bindVariable_shouldSetAndUpdateEnabledState() {
        sut.rac_enabled <~ self.enabledProperty
        
        expect(self.sut.enabled) == true
        
        self.enabledProperty.value = false
        
        expect(self.sut.enabled) == false
    }
    
    func testButtonSelected_bindVariable_shouldSetAndUpdateSelectedState() {
        sut.rac_selected <~ self.enabledProperty
        
        expect(self.sut.selected) == true
        
        self.enabledProperty.value = false
        
        expect(self.sut.selected) == false
    }
    
}


extension ReactiveButtonTests {
    private func setupBindings() {
        sut.rac_titleForState(.Normal) <~ self.titleNormal
        sut.rac_titleForState(.Highlighted) <~ self.titleHighlighted
        sut.rac_titleForState(.Disabled) <~ self.titleDisabled
        sut.rac_titleForState(.Selected) <~ self.titleSelected
        sut.rac_titleForState(.Focused) <~ self.titleFocused
    }
}
