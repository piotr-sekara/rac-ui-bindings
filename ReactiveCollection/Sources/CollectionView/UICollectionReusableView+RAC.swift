//
//  UICollectionViewCell+RAC.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 18.10.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit
import enum Result.Result
import enum Result.NoError
import ReactiveSwift
import ObjectiveC.runtime


extension UICollectionReusableView {
    fileprivate struct Swizzle {
        static var prepareForReuse: Void = {
            let original = class_getInstanceMethod(UICollectionReusableView.self, #selector(UICollectionReusableView.prepareForReuse))
            let fake = class_getInstanceMethod(UICollectionReusableView.self, #selector(UICollectionReusableView.cw_prepareForReuse))
            
            method_exchangeImplementations(original, fake)
        }()
    }
    
    fileprivate struct AssociatedKeys {
        static var rac_prepareForReuse = "rac_prepareForReuse"
    }
    
    fileprivate var rac_prepareForReuseTuple: [AnyObject] {
        _ = UICollectionReusableView.Swizzle.prepareForReuse
        guard let tuple = objc_getAssociatedObject(self, &UICollectionViewCell.AssociatedKeys.rac_prepareForReuse) as? [AnyObject] else {
            let tuple = Signal<Void, NoError>.pipe()
            objc_setAssociatedObject(self, &UICollectionViewCell.AssociatedKeys.rac_prepareForReuse, [tuple.0, tuple.1], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return [tuple.0, tuple.1]
        }
        return tuple
    }

    @objc(cw_prepareForReuse)
    fileprivate dynamic func cw_prepareForReuse() {
        (self.rac_prepareForReuseTuple[1] as! Signal<Void, NoError>.Observer).send(value: ())
        self.cw_prepareForReuse()
    }
}

public extension Reactive where Base: UICollectionReusableView {

    public var prepareForReuse: Signal<Void, NoError> {
        return self.base.rac_prepareForReuseTuple[0] as! Signal
    }
    
}
