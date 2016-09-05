//
//  UITextField+RAC.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 30.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import Result


public extension UITextField {
    
    public weak var forwardDelegate: UITextFieldDelegate? {
        get {
            guard let proxy = self.delegate as? TextFieldDelegateProxy else {
                return nil
            }
            return proxy.forwardDelegate as? UITextFieldDelegate
        }
        set {
            let proxy = TextFieldDelegateProxy.proxy(forObject: self)
            proxy.forwardDelegate = newValue as? NSObject
        }
    }
    
    public var rac_editingStarted: Signal<Void, NoError> {
        let proxy = TextFieldDelegateProxy.proxy(forObject: self)
        return proxy.rac_editingStarted
    }
    
    public var rac_editingEnded: Signal<Void, NoError> {
        let proxy = TextFieldDelegateProxy.proxy(forObject: self)
        return proxy.rac_editingEnded
    }
    
    public var rac_textSignal: SignalProducer<String, NoError> {
        let proxy = TextFieldDelegateProxy.proxy(forObject: self)
        return proxy.rac_textSignal
    }
    
}
