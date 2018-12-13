//
//  ChangeTracker.swift
//  Bindings
//
//  Created by Marc Bauer on 21.08.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import RxSwift

public protocol ObservableChangeSet {
  var hasChanges: Bool { get }
}



fileprivate class ChangeSet<T>: ObservableChangeSet {
  private let comparer: (T, T) -> Bool

  private var initialValue: T? {
    didSet { self.initialValueSet = true }
  }
  private var currentValue: T? {
    didSet { self.currentValueSet = true }
  }

  private var initialValueSet: Bool = false
  private var currentValueSet: Bool = false

  init(comparer: @escaping (T, T) -> Bool) {
    self.comparer = comparer
  }

  func applyValue(_ value: T?) {
    if !self.initialValueSet {
      self.initialValue = value
      return
    }
    self.currentValue = value
  }

  var hasChanges: Bool {
    guard self.initialValueSet, self.currentValueSet else {
      return false
    }
    switch (self.initialValue, self.currentValue) {
      case (.some, .none), (.none, .some):
        return true

      case (.none, .none):
        return false

      case let (.some(lhs), .some(rhs)):
        return !self.comparer(lhs, rhs)
    }
  }
}



public struct ChangeTracker {
  public static func observe(_ observables: Observable<ObservableChangeSet>...)
    -> Observable<Bool> {
    return self.observe(observables)
  }

  public static func observe(_ observables: [Observable<ObservableChangeSet>]) -> Observable<Bool> {
    return Observable.create { observer in
      var hasChanges: [Bool] = observables.map { _ in false }

      let subscriptions = observables
        .enumerated()
        .map { args -> Disposable in
          let (idx, observable) = args
          return observable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { changeSet in
              hasChanges[idx] = changeSet.hasChanges
              observer.on(.next(hasChanges.contains(true)))
            })
        }

      return Disposables.create(subscriptions)
    }
    .startWith(false)
    .distinctUntilChanged()
  }

  public static func trackChanges<T: Equatable>(_ binding: Binding<T?>)
    -> Observable<ObservableChangeSet> {
    return self.trackChanges(binding.asObservable())
  }

  public static func trackChanges<T: Equatable>(_ binding: Binding<T>)
    -> Observable<ObservableChangeSet> {
    return self.trackChanges(binding.asObservable())
  }

  public static func trackChanges<T>(
    _ observable: Observable<T?>,
    comparer: @escaping (T, T) -> Bool) -> Observable<ObservableChangeSet> {
    return observable
      .observeOn(MainScheduler.instance)
      .scan(ChangeSet(comparer: comparer) as ChangeSet<T>) { oldValue, newValue in
        let changeSet = oldValue as! ChangeSet<T>
        changeSet.applyValue(newValue)
        return changeSet
      }
  }

  public static func trackChanges<T>(
    _ observable: Observable<T>,
    comparer: @escaping (T, T) -> Bool) -> Observable<ObservableChangeSet> {
    return self.trackChanges(observable.map { .some($0) }, comparer: comparer)
  }

  public static func trackChanges<T: Equatable>(_ observable: Observable<T?>)
    -> Observable<ObservableChangeSet> {
    return self.trackChanges(observable, comparer: ==)
  }

  public static func trackChanges<T: Equatable>(_ observable: Observable<T>)
    -> Observable<ObservableChangeSet> {
    return self.trackChanges(observable.map { .some($0) }, comparer: ==)
  }
}

