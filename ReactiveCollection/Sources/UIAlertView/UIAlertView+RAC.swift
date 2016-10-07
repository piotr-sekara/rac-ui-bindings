//
//  UIAlertView+RAC.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 07.10.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result


public extension UIAlertView {
    
    public weak var forwardDelegate: UIAlertViewDelegate? {
        get {
            guard let proxy = self.delegate as? AlertViewDelegateProxy else {
                return nil
            }
            return proxy._forwardDelegate
        }
        set {
            let proxy = AlertViewDelegateProxy.proxy(forObject: self)
            proxy.forwardDelegate = newValue as? NSObject
        }
    }
    
}

public extension Reactive where Base: UIAlertView {
    
    public func buttonClicked() -> Signal<Int, NoError> {
        let proxy = AlertViewDelegateProxy.proxy(forObject: self.base)
        return proxy.rac_buttonClickedPipe.0
    }
    
    public func buttonClicked() -> Signal<(buttonIndex: Int, textField: UITextField), NoError> {
        let proxy = AlertViewDelegateProxy.proxy(forObject: self.base)
        return proxy.rac_buttonClickedWithTextFieldsPipe.0.map { (idx, textFields) -> (Int, UITextField) in
            return (idx, textFields[0])
        }
    }
    
    public func buttonClicked() -> Signal<(buttonIndex: Int, login: UITextField, password: UITextField), NoError> {
        let proxy = AlertViewDelegateProxy.proxy(forObject: self.base)
        return proxy.rac_buttonClickedWithTextFieldsPipe.0.map { (idx, textFields) -> (Int, UITextField, UITextField) in
            return (idx, textFields[0], textFields[1])
        }
    }
    
}

