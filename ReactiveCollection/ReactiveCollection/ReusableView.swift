//
//  ReusableView.swift
//  Voluum
//
//  Created by Paweł Sękara on 13.07.2016.
//  Copyright © 2016 CodeWise sp. z o.o. Sp. k. All rights reserved.
//

import Foundation
import UIKit

protocol ReusableView {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(self)
    }
}

extension UICollectionViewCell: ReusableView {}
extension UITableViewCell: ReusableView {}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell where T: ReusableView>(forIndexPath indexPath: NSIndexPath) -> T {
        guard let cell = dequeueReusableCellWithIdentifier(T.defaultReuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier). Did you forget to register it first?")
        }
        return cell
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell where T: ReusableView>(_: T.Type) {
        registerClass(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell where T: ReusableView>(forIndexPath indexPath: NSIndexPath) -> T {
        guard let cell = dequeueReusableCellWithReuseIdentifier(T.defaultReuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier). Did you forget to register it first?")
        }
        return cell
    }
}
