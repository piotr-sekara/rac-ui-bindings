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
    private struct AssociatedKeys {
        static var rac_titleForState = "rac_titleForState"
        static var rac_attributedTitleForState = "rac_attributedTitleForState"
    }
    
    public var rac_titleForState: (UIControlState) -> MutableProperty<String?> {
        return { [unowned self] state in
            var properties: NSMutableDictionary
            if let obj = objc_getAssociatedObject(self, &AssociatedKeys.rac_titleForState) as? NSMutableDictionary {
                properties = obj
            } else {
                properties = NSMutableDictionary()
                objc_setAssociatedObject(self, &AssociatedKeys.rac_titleForState, properties, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            guard let property = properties.object(forKey: state.stringValue) as? MutableProperty<String?> else {
                
                //TODO: add takeUntil
                let property = MutableProperty<String?>(self.title(for: state))
                property.producer.startWithNext { [weak self] value in
                    self?.setTitle(value, for: state)
                }
                properties.setObject(property, forKey: state.stringValue as NSString)
                
                return property
            }
            
            return property
        }
    }
    
    public var rac_attributedTitleForState: (UIControlState) -> MutableProperty<NSAttributedString?> {
        return { [unowned self] state in
            var properties: NSMutableDictionary
            if let obj = objc_getAssociatedObject(self, &AssociatedKeys.rac_attributedTitleForState) as? NSMutableDictionary {
                properties = obj
            } else {
                properties = NSMutableDictionary()
                objc_setAssociatedObject(self, &AssociatedKeys.rac_attributedTitleForState, properties, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            guard let property = properties.object(forKey: state.stringValue) as? MutableProperty<NSAttributedString?> else {
                
                //TODO: add takeUntil
                let property = MutableProperty<NSAttributedString?>(self.attributedTitle(for: state))
                property.producer.startWithNext { [weak self] value in
                    self?.setAttributedTitle(value, for: state)
                }
                properties.setObject(property, forKey: state.stringValue as NSString)
                
                return property
            }
            return property
        }
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
