//
//  Binding.swift
//  Bindings
//
//  Created by Marc Bauer on 03.04.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import RxSwift
import NSMFoundation

public struct Binding<T> {
  private let target: Observable<T>
  private let applier: (T) -> ()

  // MARK: - Initialization -

  public init(target: BehaviorSubject<T>) {
    self.target = target
    self.applier = { target.on(.next($0)) }
  }

  public init(value: T) {
    self.init(target: BehaviorSubject(value: value))
  }

  public init(target: Observable<T>, applier: @escaping (T) -> ()) {
    self.target = target.share(replay: 1, scope: .forever)
    self.applier = applier
  }

  // MARK: - Public Methods -

  public func twoWayBind<O>(
    _ source: O
  ) -> Disposable where O: ObserverType & ObservableType, O.Element == T {
    return self.target.bnd_bidiSubscribe(
      source,
      sourceToTarget: { $0 },
      targetToSource: { $0 },
      sourceApplier: { source.on(.next($0)) },
      targetApplier: self.applier
    )
  }

  public func twoWayBind(_ source: Binding<T>) -> Disposable {
    return self.target.bnd_bidiSubscribe(
      source.target,
      sourceToTarget: { $0 },
      targetToSource: { $0 },
      sourceApplier: source.applier,
      targetApplier: self.applier
    )
  }

  public func twoWayBind<O>(
    _ source: O,
    sourceToTarget: (Observable<O.Element>) -> Observable<T>,
    targetToSource: (Observable<T>) -> Observable<O.Element>
  ) -> Disposable where O: ObserverType & ObservableType {
    return self.target.bnd_bidiSubscribe(
      source,
      sourceToTarget: sourceToTarget,
      targetToSource: targetToSource,
      sourceApplier: { source.on(.next($0)) },
      targetApplier: self.applier
    )
  }

  public func twoWayBind<O>(_ source: Binding<O>,
    sourceToTarget: (Observable<O>) -> Observable<T>,
    targetToSource: (Observable<T>) -> Observable<O>
  ) -> Disposable {
    return self.target.bnd_bidiSubscribe(
      source.target,
      sourceToTarget: sourceToTarget,
      targetToSource: targetToSource,
      sourceApplier: source.applier,
      targetApplier: self.applier
    )
  }

  public func bind<O>(_ source: O) -> Disposable where O: ObservableType, O.Element == T {
    return source
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { value in
        self.applier(value)
      })
  }

  public func bind(_ source: Binding<T>) -> Disposable {
    return self.bind(source.target)
  }

  public func asObservable() -> Observable<T> {
    return self.target.asObservable()
  }
}



extension Binding {
  public func lift<O>(action: Lens<T, O>) -> Binding<O> {
    return Binding<O>(
      target: self.target.map(action.view),
      applier: { self.applier(action.set($0)) }
    )
  }
}
