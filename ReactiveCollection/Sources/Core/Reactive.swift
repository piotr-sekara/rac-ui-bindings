//
//  Reactive.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 16.09.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation

//Concept taken from RxSwift project

public struct Reactive<Base> {
    public let base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol ReactiveProtocol {
    associatedtype BaseType
    var rac: Reactive<BaseType> { get }
}

public extension ReactiveProtocol {
    public var rac: Reactive<Self> {
        return Reactive(self)
    }
}

extension NSObject: ReactiveProtocol {}
