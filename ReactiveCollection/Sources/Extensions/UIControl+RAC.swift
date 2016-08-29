//
//  UIControl+RAC.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 26.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ReactiveCocoa

public extension UIControl {
    private struct AssociatedKeys {
        static var rac_enabledKey = "rac_enabledKey"
        static var rac_selectedKey = "rac_selectedKey"
    }
    
    public var rac_enabled: MutableProperty<Bool> {
        guard let property = objc_getAssociatedObject(self, &UIControl.AssociatedKeys.rac_enabledKey) as? MutableProperty<Bool> else {
            let property = MutableProperty<Bool>(self.enabled)
            property.producer.takeUntil(self.rac_willDeallocSignal()).startWithNext { [weak self] value in
                self?.enabled = value
            }
            objc_setAssociatedObject(self, &UIButton.AssociatedKeys.rac_enabledKey, property, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return property
        }
        
        return property
    }
    
    public var rac_selected: MutableProperty<Bool> {
        guard let property = objc_getAssociatedObject(self, &UIControl.AssociatedKeys.rac_selectedKey) as? MutableProperty<Bool> else {
            let property = MutableProperty<Bool>(self.selected)
            property.producer.takeUntil(self.rac_willDeallocSignal()).startWithNext { [weak self] value in
                self?.selected = value
            }
            objc_setAssociatedObject(self, &UIButton.AssociatedKeys.rac_selectedKey, property, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return property
        }
        
        return property
    }
}
