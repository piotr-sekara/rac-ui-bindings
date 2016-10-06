//
//  TextFieldDelegateProxy.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 30.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result


public class TextFieldDelegateProxy: DelegateProxy {
    
    weak private(set) var textField: UITextField!
    
    var rac_editingStarted: Signal<Void, NoError> {
        return self.rac_textFieldDidBeginEditing.0
    }
    
    var rac_editingEnded: Signal<Void, NoError> {
        return self.rac_textFieldDidEndEditing.0
    }
    
    var rac_textSignal: SignalProducer<String, NoError> {
        let textObserver = self.textField.rac.values(forKeyPath: #keyPath(UITextField.text)).map { (any) -> String? in
            return any as? String
        }.skipNil()
        return SignalProducer.merge(self.rac_textDidChangeProperty.producer, textObserver).skipRepeats().take(during: self.textField.rac.lifetime)
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
    
    fileprivate let rac_textFieldDidBeginEditing    = Signal<Void, NoError>.pipe()
    fileprivate let rac_textFieldDidEndEditing      = Signal<Void, NoError>.pipe()
    fileprivate let rac_textDidChangeProperty       = MutableProperty<String>("")
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
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return self._forwardDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return self._forwardDelegate?.textFieldShouldClear?(textField) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self._forwardDelegate?.textFieldShouldReturn?(textField) ?? true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return self._forwardDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.rac_textDidChangeProperty.swap(((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string))
        
        return self._forwardDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.rac_textFieldDidBeginEditing.1.send(value: ())
        self._forwardDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.rac_textFieldDidEndEditing.1.send(value: ())
        self._forwardDelegate?.textFieldDidEndEditing?(textField)
    }
    
}
