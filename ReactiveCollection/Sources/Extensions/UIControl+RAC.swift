//
//  UIControl+RAC.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 26.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.NoError

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
            property.producer.take(during: (self.base as UIControl).reactive.lifetime).startWithValues { [weak base] value in
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
            property.producer.take(during: (self.base as UIControl).reactive.lifetime).startWithValues { [weak base] value in
                base?.isSelected = value
            }
            objc_setAssociatedObject(self.base, &UIButton.AssociatedKeys.rac_selectedKey, property, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return property
        }
        
        return property
    }
    
    public func actions(for controlEvents: UIControlEvents) -> Signal<Base, NoError> {
        return Signal<Base, NoError> { obs in
            let wrapper = UIControlObserverWrapper(obs)
            
            self.base.addTarget(wrapper, action: #selector(UIControlObserverWrapper<Observer<UIControl, NoError>>.sendNext(_:)), for: controlEvents)
            
            return ActionDisposable(action: {
                wrapper.sendCompleted()
                self.base.removeTarget(wrapper, action: #selector(UIControlObserverWrapper<Observer<UIControl, NoError>>.sendNext(_:)), for: controlEvents)
            })
        }
            .take(during: (self.base as UIControl).reactive.lifetime)
            .observe(on: QueueScheduler.main)
    }
}

fileprivate class UIControlObserverWrapper<O: ObserverProtocol> where O.Value: UIControl {
    
    var observer: O
    
    init(_ observer: O, base: UIControl? = nil) {
        self.observer = observer
    }
    
    @objc
    func sendNext(_ sender: UIControl) {
        self.observer.send(value: sender as! O.Value)
    }
    
    @objc
    func sendCompleted() {
        self.observer.sendCompleted()
    }
    
}
