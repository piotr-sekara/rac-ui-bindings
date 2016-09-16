//
//  UIControl+RAC.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 26.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ReactiveSwift

public extension UIControl {
    private struct AssociatedKeys {
        static var rac_enabledKey = "rac_enabledKey"
        static var rac_selectedKey = "rac_selectedKey"
    }
    
    public var rac_enabled: MutableProperty<Bool> {
        guard let property = objc_getAssociatedObject(self, &UIControl.AssociatedKeys.rac_enabledKey) as? MutableProperty<Bool> else {
            let property = MutableProperty<Bool>(self.isEnabled)
            property.producer.take(during: self.rac.lifetime).startWithNext { [weak self] value in
                self?.isEnabled = value
            }
            objc_setAssociatedObject(self, &UIButton.AssociatedKeys.rac_enabledKey, property, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return property
        }
        
        return property
    }
    
    public var rac_selected: MutableProperty<Bool> {
        guard let property = objc_getAssociatedObject(self, &UIControl.AssociatedKeys.rac_selectedKey) as? MutableProperty<Bool> else {
            let property = MutableProperty<Bool>(self.isSelected)
            property.producer.take(during: self.rac.lifetime).startWithNext { [weak self] value in
                self?.isSelected = value
            }
            objc_setAssociatedObject(self, &UIButton.AssociatedKeys.rac_selectedKey, property, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return property
        }
        
        return property
    }
}
