//
//  DataReloadable.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 11.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import UIKit


public protocol DataReloadable: class {
    func reloadData()
}

extension UITableView: DataReloadable {}
extension UICollectionView: DataReloadable {}
