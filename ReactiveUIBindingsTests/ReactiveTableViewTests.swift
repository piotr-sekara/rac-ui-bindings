//
//  ReactiveTableViewTests.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 22.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import XCTest
import Nimble
import Quick

@testable import ReactiveUIBindings
import ReactiveCocoa
import Result

class TestCell1: UITableViewCell {
    var data: String?
}
class TestCell2: UITableViewCell {
    var data: String?
}

class ReactiveTableViewTests: QuickSpec {
    override func spec() {
        
        var tableView: UITableView!
        
        var ds1: MutableProperty<[String]>!
        var ds2: MutableProperty<[String]>!
        
        beforeEach {
            tableView = UITableView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 100, height: 100000)))
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "FixtureCell1")
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "FixtureCell2")
            tableView.register(TestCell1.self)
            tableView.register(TestCell2.self)
            ds1 = MutableProperty([
                "Fixture1",
                "Fixture2",
                "Fixture3",
                "Fixture4",
                "Fixture5",
                "Fixture6",
                "Fixture7",
                "Fixture8",
            ])
            
            ds2 = MutableProperty([
                "Test1",
                "Test2",
                "Test3",
                "Test4",
                "Test5",
            ])
        }
        
        afterEach {
            tableView = nil
            ds1 = nil
            ds2 = nil
        }
        
        describe("Binding data to tableView") {
            
            context("when using cellIdentifiers") {
                
                var disposable1: Disposable?
            
                beforeEach {
                    disposable1 = ds1.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell1")) { _ in
                    }
                }
            
                it("should have correct number of cells loaded") {
                    expect(tableView.numberOfRowsInSection(0)) == 8
                }
                
                it("should have correct reuse identifier") {
                    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                    expect(cell?.reuseIdentifier) == "FixtureCell1"
                }
                
                context("when binding more than one data source to table view") {
                    
                    beforeEach {
                        ds2.bindTo(tableView.rac_items(cellIdentifier: "FixtureCell2")) { _ in
                        }
                    }
                    
                    it("should have correct number of cells loaded") {
                        expect(tableView.numberOfRowsInSection(0)) == 13
                    }
                    
                    it("should have correct reuse identifier") {
                        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 9, inSection: 0))
                        expect(cell?.reuseIdentifier) == "FixtureCell2"
                    }
                    
                    context("when disposing a binding") {
                        
                        beforeEach {
                            disposable1?.dispose()
                        }
                        
                        it("should have correct number of cells loaded") {
                            expect(tableView.numberOfRowsInSection(0)) == 5
                        }
                        
                        it("should have correct reuse identifier") {
                            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                            expect(cell?.reuseIdentifier) == "FixtureCell2"
                        }
                    }
                    
                }
                
                context("when modifying data source") {
                    
                    beforeEach {
                        ds1.value = ["Fixture1", "Fixture2"]
                    }
                    
                    it("should have correct number of cells loaded") {
                        expect(tableView.numberOfRowsInSection(0)) == 2
                    }
                    
                }
                
            }
            
        }
        
    }
}
