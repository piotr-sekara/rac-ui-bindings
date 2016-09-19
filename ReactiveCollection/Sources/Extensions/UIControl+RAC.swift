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
    fileprivate struct AssociatedKeys {
        static var rac_enabledKey = "rac_enabledKey"
        static var rac_selectedKey = "rac_selectedKey"
    }
}

public extension Reactive where Base: UIControl {
    
    public var enabled: MutableProperty<Bool> {
        guard let property = objc_getAssociatedObject(self.base, &UIControl.AssociatedKeys.rac_enabledKey) as? MutableProperty<Bool> else {
            let property = MutableProperty<Bool>(self.base.isEnabled)
            property.producer.take(during: (self.base as UIControl).rac.lifetime).startWithNext { [weak base] value in
                base?.isEnabled = value
            }
            objc_setAssociatedObject(self.base, &UIButton.AssociatedKeys.rac_enabledKey, property, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return property
        }
        
        return property
    }
    
    public var selected: MutableProperty<Bool> {
        guard let property = objc_getAssociatedObject(self.base, &UIControl.AssociatedKeys.rac_selectedKey) as? MutableProperty<Bool> else {
            let property = MutableProperty<Bool>(self.base.isSelected)
            property.producer.take(during: (self.base as UIControl).rac.lifetime).startWithNext { [weak base] value in
                base?.isSelected = value
            }
            objc_setAssociatedObject(self.base, &UIButton.AssociatedKeys.rac_selectedKey, property, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return property
        }
        
        return property
    }
}

