//
//  UIButton+RAC.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 26.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ReactiveSwift

public extension UIButton {
    fileprivate struct AssociatedKeys {
        static var rac_titleForState = "rac_titleForState"
        static var rac_attributedTitleForState = "rac_attributedTitleForState"
    }
}

public extension Reactive where Base: UIButton {
    
    public func title(for state: UIControlState) -> MutableProperty<String?> {
        var properties: NSMutableDictionary
        if let obj = objc_getAssociatedObject(self.base, &UIButton.AssociatedKeys.rac_titleForState) as? NSMutableDictionary {
            properties = obj
        } else {
            properties = NSMutableDictionary()
            objc_setAssociatedObject(self.base, &UIButton.AssociatedKeys.rac_titleForState, properties, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        guard let property = properties.object(forKey: state.stringValue) as? MutableProperty<String?> else {
            
            let property = MutableProperty<String?>(self.base.title(for: state))
            property.producer.take(during: (self.base as UIButton).rac.lifetime).startWithNext { [weak base] value in
                base?.setTitle(value, for: state)
            }
            properties.setObject(property, forKey: state.stringValue as NSString)
            
            return property
        }
    
        return property
    }
    
    public func attributedTitle(for state: UIControlState) -> MutableProperty<NSAttributedString?> {
        var properties: NSMutableDictionary
        if let obj = objc_getAssociatedObject(self.base, &UIButton.AssociatedKeys.rac_attributedTitleForState) as? NSMutableDictionary {
            properties = obj
        } else {
            properties = NSMutableDictionary()
            objc_setAssociatedObject(self, &UIButton.AssociatedKeys.rac_attributedTitleForState, properties, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        guard let property = properties.object(forKey: state.stringValue) as? MutableProperty<NSAttributedString?> else {
            
            let property = MutableProperty<NSAttributedString?>(self.base.attributedTitle(for: state))
            property.producer.take(during: (self.base as UIButton).rac.lifetime).startWithNext { [weak base] value in
                base?.setAttributedTitle(value, for: state)
            }
            properties.setObject(property, forKey: state.stringValue as NSString)
            
            return property
        }
        return property
    }
}

extension UIControlState: Hashable {
    public var hashValue: Int {
        return Int(self.rawValue)
    }
    
    public var stringValue: String {
        return String(Int(self.rawValue))
    }
}
