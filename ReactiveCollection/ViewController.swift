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

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var data: MutableProperty<[String]> = MutableProperty<[String]>([])
    var data2: MutableProperty<[String]> = MutableProperty<[String]>(["String0", "String1"])
    var disposable: Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.data.value = [
            "String0",
            "String1",
            "String2",
            "String3",
            "String4",
            "String5",
            "String6",
            "String7",
            "String8",
            "String9"
        ]
        
        
        
//        self.data.bindTo(self.tableView.rac_items(cellType: SomeCell.self)) { (idx, cell, elem) in
//            
//        }
//        
        
        self.disposable = self.data.bindTo(self.tableView.rac_items(cellIdentifier: "SomeCell", cellType: SomeCell.self)) { (idx, cell, elem) in
            cell.label.text = elem
        }
        
        
        self.performSelector(#selector(ViewController.makeNil), withObject: nil, afterDelay: 1)

        self.performSelector(#selector(ViewController.changeData), withObject: nil, afterDelay: 2)
        
//        dis1.dispose()
        
//        self.data.value = ["String"]
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func makeNil() {
        dispatch_async(dispatch_get_main_queue()) {
            self.disposable?.dispose()
        }
    }
    
    func changeData() {
        dispatch_async(dispatch_get_main_queue()) { 
            self.data.value = ["łehehe", "dupadupa"]
        }
        print("ChNAGE")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

