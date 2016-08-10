//
//  RACExtensions.swift
//  ReactiveCollection
//
//  Created by Paweł Sękara on 10.08.2016.
//  Copyright © 2016 Codewise Sp. z o.o. Sp. K. All rights reserved.
//

import Foundation
import ReactiveCocoa


extension PropertyType where Value: SequenceType {
    
    func bindTo<R1, R2>(binding: Self -> R1 -> R2, curriedArg: R1) -> R2 {
        return binding(self)(curriedArg)
    }
}

extension Disposable {
    func addTo(compositeDisposable: CompositeDisposable) -> Disposable {
        compositeDisposable.addDisposable(self)
        return self
    }
}
