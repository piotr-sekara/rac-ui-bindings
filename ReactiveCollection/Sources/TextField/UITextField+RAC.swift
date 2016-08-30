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
    
    public var rac_editingStarted: Signal<Void, NoError> {
        let proxy = TextFieldDelegateProxy.proxy(forObject: self)
        return proxy.rac_editingStarted
    }
    
    public var rac_editingEnded: Signal<Void, NoError> {
        let proxy = TextFieldDelegateProxy.proxy(forObject: self)
        return proxy.rac_editingEnded
    }
    
}
