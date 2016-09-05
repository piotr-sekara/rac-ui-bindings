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
    
    public weak private(set) var textField: UITextField!
    
    public var rac_editingStarted: Signal<Void, NoError> {
        return self.rac_textFieldDidBeginEditing.0
    }
    
    public var rac_editingEnded: Signal<Void, NoError> {
        return self.rac_textFieldDidEndEditing.0
    }
    
    public var rac_textSignal: SignalProducer<String, NoError> {
        let textObserver = self.textField.rac_valuesForKeyPath("text", observer: self)
            .toSignalProducer()
            .ignoreNil()
            .map(String.init)
            .flatMapError { _ in SignalProducer<String, NoError>.empty }
            .takeUntil(self.textField.rac_willDeallocSignal())
        return SignalProducer.merge(self.rac_textDidChangeProperty.producer, textObserver).skipRepeats()
    }
    
    public init(textField: UITextField) {
        super.init()
        self.textField = textField
        self.forwardDelegate = self.textField?.delegate as? NSObject
        self.textField?.delegate = self //some forward delegate
        
    }

    func contentDidChange(textField: UITextField) {
        self.rac_textDidChangeProperty.value = textField.text ?? ""
    }
    
    public override static func createProxy(forObject object: AnyObject) -> AnyObject {
        guard let textField = object as? UITextField else {
            fatalError("Invalid object specified")
        }
        
        return TextFieldDelegateProxy(textField: textField)
    }
    
    private let rac_textFieldDidBeginEditing    = Signal<Void, NoError>.pipe()
    private let rac_textFieldDidEndEditing      = Signal<Void, NoError>.pipe()
    private let rac_textDidChangeProperty       = MutableProperty<String>("")
}

extension TextFieldDelegateProxy: UITextFieldDelegate {
    
    public var _forwardDelegate: UITextFieldDelegate? {
        get {
            return super.forwardDelegate as? UITextFieldDelegate
        }
        set {
            super.forwardDelegate = newValue as? NSObject
        }
    }
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return self._forwardDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldShouldClear(textField: UITextField) -> Bool {
        return self._forwardDelegate?.textFieldShouldClear?(textField) ?? true
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        return self._forwardDelegate?.textFieldShouldReturn?(textField) ?? true
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return self._forwardDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        self.rac_textDidChangeProperty.swap(((textField.text ?? "") as NSString).stringByReplacingCharactersInRange(range, withString: string))
        
        return self._forwardDelegate?.textField?(textField, shouldChangeCharactersInRange: range, replacementString: string) ?? true
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        self.rac_textFieldDidBeginEditing.1.sendNext(())
        self._forwardDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        self.rac_textFieldDidEndEditing.1.sendNext(())
        self._forwardDelegate?.textFieldDidEndEditing?(textField)
    }
    
}
