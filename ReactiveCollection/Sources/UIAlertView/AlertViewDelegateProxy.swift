//
//  UIAlertViewDelegateProxy.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 06.10.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result


class AlertViewDelegateProxy: DelegateProxy {
    
    weak private(set) var alertView: UIAlertView!
    
    init(alertView: UIAlertView) {
        super.init()
        self.alertView = alertView
        self.forwardDelegate = self.alertView.delegate as? NSObject
        self.alertView.delegate = self
    }
    
    override static func createProxy(forObject object: AnyObject) -> AnyObject {
        guard let alertView = object as? UIAlertView else {
            fatalError("Invalid object specified")
        }
        return AlertViewDelegateProxy(alertView: alertView)
    }
    
    let rac_buttonClickedPipe = Signal<Int, NoError>.pipe()
    let rac_buttonClickedWithTextFieldsPipe = Signal<(Int, [UITextField]), NoError>.pipe()
    
}

extension AlertViewDelegateProxy: UIAlertViewDelegate {
    
    var _forwardDelegate: UIAlertViewDelegate? {
        get {
            return super.forwardDelegate as? UIAlertViewDelegate
        }
        set {
            super.forwardDelegate = newValue as? NSObject
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        self.rac_buttonClickedPipe.1.send(value: buttonIndex)
        if self.alertView.alertViewStyle == .loginAndPasswordInput {
            self.rac_buttonClickedWithTextFieldsPipe.1.send(value: (buttonIndex, [self.alertView.textField(at: 0)!, self.alertView.textField(at: 1)!]))
        } else if self.alertView.alertViewStyle != .default {
            self.rac_buttonClickedWithTextFieldsPipe.1.send(value: (buttonIndex, [self.alertView.textField(at: 0)!]))
        }
        
        self._forwardDelegate?.alertView?(alertView, clickedButtonAt: buttonIndex)
    }
    
    func alertViewCancel(_ alertView: UIAlertView) {
        self.rac_buttonClickedPipe.1.sendInterrupted()
        self.rac_buttonClickedWithTextFieldsPipe.1.sendInterrupted()
        
        self._forwardDelegate?.alertViewCancel?(alertView)
    }
    
    func willPresent(_ alertView: UIAlertView) {
        self._forwardDelegate?.willPresent?(alertView)
    }
    
    func didPresent(_ alertView: UIAlertView) {
        self._forwardDelegate?.didPresent?(alertView)
    }
    
    func alertView(_ alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        self._forwardDelegate?.alertView?(alertView, willDismissWithButtonIndex: buttonIndex)
    }
    
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        self.rac_buttonClickedPipe.1.sendCompleted()
        self.rac_buttonClickedWithTextFieldsPipe.1.sendCompleted()
        
        self._forwardDelegate?.alertView?(alertView, didDismissWithButtonIndex: buttonIndex)
    }
    
    func alertViewShouldEnableFirstOtherButton(_ alertView: UIAlertView) -> Bool {
        return self._forwardDelegate?.alertViewShouldEnableFirstOtherButton?(alertView) ?? true
    }
}
