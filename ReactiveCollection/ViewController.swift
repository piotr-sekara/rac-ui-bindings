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

class SomeDS: NSObject, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        fatalError()
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        print("this method got called")
        return true
    }
}

class SomeDS2: NSObject, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        fatalError()
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        print("NOW THIS")
        return true
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var data: MutableProperty<[String]> = MutableProperty<[String]>(["0", "1"])
    var data2: MutableProperty<[String]> = MutableProperty<[String]>(["a", "b"])
    var index = 2
    let ds = SomeDS()
    let ds2 = SomeDS2()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add warning flags to this methods, so user knows whats going on with datasource
        self.data.bindTo(self.collectionView.rac_items(cellType: SomeCell.self)) { (_, cell, elem) in
            cell.label.text = elem
        }
        
        self.data2.bindTo(self.collectionView.rac_items(cellType: SomeCell2.self)) { (_, cell, elem) in
            cell.label.text = elem
        }
        
        self.collectionView.forwardDataSource = ds
        self.collectionView.dataSource?.collectionView?(self.collectionView, canMoveItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        
        self.collectionView.forwardDataSource = ds2
        self.collectionView.dataSource?.collectionView?(self.collectionView, canMoveItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        
        self.collectionView.forwardDataSource = ds
        self.collectionView.dataSource?.collectionView?(self.collectionView, canMoveItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        
        self.collectionView.forwardDataSource = ds2
        self.collectionView.dataSource?.collectionView?(self.collectionView, canMoveItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    }

    @IBAction func addMore(sender: AnyObject) {
        self.data.value.append("\(self.index)")
        self.index += 1
    }
}

