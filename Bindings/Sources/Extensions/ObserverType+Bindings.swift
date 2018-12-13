//
//  ObserverType+ExpenseTracker.swift
//  Bindings
//
//  Created by Marc Bauer on 21/02/2017.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import NSMFoundation
import RxSwift

public typealias ObservableTransformer<In, Out> = (Observable<In>) -> Observable<Out>

extension ObserverType where Self: ObservableType {
  internal func bnd_bidiSubscribe<O>(
    _ source: O
  ) -> Disposable where O: ObserverType & ObservableType, O.E == E {
    return self.bnd_bidiSubscribe(
      source,
      sourceToTarget: { $0 },
      targetToSource: { $0 }
    )
  }

  internal func bnd_bidiSubscribe<O>(
    _ source: O,
    sourceToTarget: ObservableTransformer<O.E, E>,
    targetToSource: ObservableTransformer<E, O.E>
  ) -> Disposable where O: ObserverType & ObservableType {
    return self.bnd_bidiSubscribe(
      source,
      sourceToTarget: sourceToTarget,
      targetToSource: targetToSource,
      sourceApplier: { source.on(.next($0)) },
      targetApplier: { self.on(.next($0)) }
    )
  }
}


extension ObservableType {
  internal func bnd_bidiSubscribe<O>(
    _ source: O,
    sourceToTarget: ObservableTransformer<O.E, E>,
    targetToSource: ObservableTransformer<E, O.E>,
    sourceApplier: @escaping (O.E) -> (),
    targetApplier: @escaping (E) -> ()
  ) -> Disposable where O: ObservableType {
    var updatingObserver: Bool = false
    var updatingSelf: Bool = false

    let sourceSubscription = sourceToTarget(source as! Observable<O.E>)
      .subscribe(
        onNext: { value in
          DispatchQueue.nsm_syncOnMainThread {
            guard !updatingObserver else { return }
            updatingSelf = true
            targetApplier(value)
            updatingSelf = false
          }
        }
      )

    let targetSubscription = targetToSource(self as! Observable<E>)
      .skip(1)
      .subscribe(
        onNext: { value in
          DispatchQueue.nsm_syncOnMainThread {
            guard !updatingSelf else { return }
            updatingObserver = true
            sourceApplier(value)
            updatingObserver = false
          }
        }
      )

    return CompositeDisposable(sourceSubscription, targetSubscription)
  }
}
