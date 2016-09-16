//
//  RACExtensions.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 10.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ReactiveSwift


public extension PropertyProtocol where Value: Sequence {
    
    func bindTo<R1, R2>(binding: (Self) -> (R1) -> R2, curriedArg: R1) -> R2 {
        return binding(self)(curriedArg)
    }
}

public extension SignalProducerProtocol where Value: Sequence {
    
    func bindTo<R1, R2>(binding: (Self) -> (R1) -> R2, curriedArg: R1) -> R2 {
        return binding(self)(curriedArg)
    }
}

public extension Disposable {
    @discardableResult
    func addTo(compositeDisposable: CompositeDisposable) -> Disposable {
        compositeDisposable.add(self)
        return self
    }
}
