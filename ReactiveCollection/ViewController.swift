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

class SomeCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}

class SomeCell2: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var data: MutableProperty<[String]> = MutableProperty<[String]>(["0"])
    var index = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.data.bindTo(self.tableView.rac_items(cellType: SomeCell.self)) { (idx, cell, elem) in
            cell.label.text = elem
        }
    }

    @IBAction func addMore(sender: AnyObject) {
        self.data.value.append("\(self.index)")
        self.index += 1
    }
}

