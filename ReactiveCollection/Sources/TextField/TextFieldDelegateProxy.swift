//
//  TextFieldDelegateProxy.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 30.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result


public class TextFieldDelegateProxy: DelegateProxy {
    
    public weak private(set) var textField: UITextField?
    
    public var rac_editingStarted: Signal<Void, NoError> {
        return self.rac_textFieldDidBeginEditing.0
    }
    
    public var rac_editingEnded: Signal<Void, NoError> {
        return self.rac_textFieldDidEndEditing.0
    }
    
    public var rac_textSignal: Signal<String, NoError> {
        return self.rac_textDidChangeSignal.0
    }
    
    
    public init(textField: UITextField) {
        super.init()
        self.textField = textField
        self.forwardDelegate = self.textField?.delegate as? NSObject
        self.textField?.delegate = self //some forward delegate
    }
    
    
    public override static func createProxy(forObject object: AnyObject) -> AnyObject {
        guard let textField = object as? UITextField else {
            fatalError("Invalid object specified")
        }
        
        return TextFieldDelegateProxy(textField: textField)
    }
    
    private let rac_textFieldDidBeginEditing    = Signal<Void, NoError>.pipe()
    private let rac_textFieldDidEndEditing      = Signal<Void, NoError>.pipe()
    private let rac_textDidChangeSignal         = Signal<String, NoError>.pipe()
}

extension TextFieldDelegateProxy: UITextFieldDelegate {
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        self.rac_textDidChangeSignal.1.sendNext(((textField.text ?? "") as NSString).stringByReplacingCharactersInRange(range, withString: string))
        
        return (self.forwardDelegate as? UITextFieldDelegate)?.textField?(textField, shouldChangeCharactersInRange: range, replacementString: string) ?? true
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        self.rac_textFieldDidBeginEditing.1.sendNext(())
        (self.forwardDelegate as? UITextFieldDelegate)?.textFieldDidBeginEditing?(textField)
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        self.rac_textFieldDidEndEditing.1.sendNext(())
        (self.forwardDelegate as? UITextFieldDelegate)?.textFieldDidEndEditing?(textField)
    }
    
}
