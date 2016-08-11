//
//  ViewController.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 08.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

class SomeCell2: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}

class SomeCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var data: MutableProperty<[String]> = MutableProperty<[String]>(["0", "1"])
    var data2: MutableProperty<[String]> = MutableProperty<[String]>(["a", "b"])
    var index = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.data.bindTo(self.collectionView.rac_items(cellType: SomeCell.self)) { (_, cell, elem) in
            cell.label.text = elem
        }
        
        self.data2.bindTo(self.collectionView.rac_items(cellType: SomeCell2.self)) { (_, cell, elem) in
            cell.label.text = elem
        }
    }

    @IBAction func addMore(sender: AnyObject) {
        self.data.value.append("\(self.index)")
        self.index += 1
    }
}

