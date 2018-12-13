//
//  BindingsTests.swift
//  BindingsTests
//
//  Created by Marc Bauer on 03.04.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import Bindings
import NSMFoundation
import RxSwift
import XCTest

struct TestState {
  var a: String
  var b: String
}

enum TestAction {
  case updateA(String)
  case updateB(String)
}

class BindingsTests: XCTestCase {
  func testTwoWayBind() {
    let source: BehaviorSubject<Int> = BehaviorSubject(value: 1)
    let target: BehaviorSubject<Int> = BehaviorSubject(value: 2)

    let binding: Binding = Binding(target: target)
    _ = binding.twoWayBind(source)

    XCTAssertEqual(try! source.value(), 1)
    XCTAssertEqual(try! target.value(), 1)

    source.on(.next(3))
    XCTAssertEqual(try! target.value(), 3)

    target.on(.next(4))
    XCTAssertEqual(try! source.value(), 4)
  }

  func testTwoWayBindLift() {
    let source: BehaviorSubject<String> = BehaviorSubject(value: "1")
    let target: BehaviorSubject<Int> = BehaviorSubject(value: 2)

    let binding: Binding = Binding(target: target)

    let liftedBinding = binding.lift(action: Lens<Int, String>(
      view: { String($0) },
      set: { Int($0)! }
    ))
    _ = liftedBinding.twoWayBind(source)

    XCTAssertEqual(try! source.value(), "1")
    XCTAssertEqual(try! target.value(), 1)

    source.on(.next("3"))
    XCTAssertEqual(try! target.value(), 3)

    target.on(.next(4))
    XCTAssertEqual(try! source.value(), "4")
  }

  func testTwoWayBindWithTransformers() {
    let source: BehaviorSubject<Int> = BehaviorSubject(value: 1)
    let target: BehaviorSubject<String> = BehaviorSubject(value: "Hello")

    let binding: Binding = Binding(target: target)
    _ = binding.twoWayBind(source,
    	sourceToTarget: { $0.map { String($0) } },
      targetToSource: { $0.map { Int($0)! } })

    XCTAssertEqual(try! source.value(), 1)
    XCTAssertEqual(try! target.value(), "1")

    source.on(.next(2))
    XCTAssertEqual(try! target.value(), "2")

    target.on(.next("3"))
    XCTAssertEqual(try! source.value(), 3)
  }

  func testTwoWayBindWithApplier() {
    let shadowSource: BehaviorSubject<Int> = BehaviorSubject(value: 1)

    let source: Binding<Int> = Binding(
      target: shadowSource.asObserver(),
      applier: { shadowSource.on(.next($0)) })

    let target: BehaviorSubject<Int> = BehaviorSubject(value: 10)

    let binding: Binding = Binding(target: target)
    _ = binding.twoWayBind(source)

    XCTAssertEqual(try! shadowSource.value(), 1)
    XCTAssertEqual(try! target.value(), 1)

    shadowSource.on(.next(2))
    XCTAssertEqual(try! target.value(), 2)

    target.on(.next(3))
    XCTAssertEqual(try! shadowSource.value(), 3)
  }

  func testOneWayBind() {
    let source: BehaviorSubject<Int> = BehaviorSubject(value: 1)
    let target: BehaviorSubject<Int> = BehaviorSubject(value: 2)

    let binding: Binding = Binding(target: target)
    _ = binding.bind(source)

    XCTAssertEqual(try! source.value(), 1)
    XCTAssertEqual(try! target.value(), 1)

    source.on(.next(3))
    XCTAssertEqual(try! target.value(), 3)

    target.on(.next(4))
    XCTAssertEqual(try! source.value(), 3)
  }

  func testTwoWayBindingToThreadedObservable() {
    let exp = expectation(description: "Waiting…")

    let source: BehaviorSubject<Int> = BehaviorSubject(value: 3)
    let twoWayBindTarget: BehaviorSubject<Int> = BehaviorSubject(value: 2)

    let twoWayBinding: Binding = Binding(target: twoWayBindTarget)
    _ = twoWayBinding.twoWayBind(source)

    XCTAssertEqual(try! source.value(), 3)
    XCTAssertEqual(try! twoWayBindTarget.value(), 3)

    var sourceOnNextCalled: Bool = false
    var sourceOnCompletedCalled: Bool = false
    var twoWayTargetOnNextCalled: Bool = false
    var twoWayTargetOnCompletedCalled: Bool = false

    let complete: () -> () = {
      guard sourceOnCompletedCalled && twoWayTargetOnCompletedCalled else {
        return
      }
      XCTAssertTrue(sourceOnNextCalled, "source onNext should have been called")
      XCTAssertTrue(twoWayTargetOnNextCalled, "twoWayTarget onNext should have been called")
      exp.fulfill()
    }

    _ = source.skip(1).take(1).subscribe(
      onNext: {
        XCTAssertEqual($0, 100)
        XCTAssertFalse(Thread.isMainThread, "onNext should be called on background thread")
        sourceOnNextCalled = true
      },
      onCompleted: {
        XCTAssertFalse(Thread.isMainThread, "onCompleted should be called on background thread")
        DispatchQueue.main.async {
          sourceOnCompletedCalled = true
          complete()
        }
      })

    _ = twoWayBindTarget.skip(1).take(1).subscribe(
      onNext: {
        XCTAssertEqual($0, 100)
        XCTAssertTrue(Thread.isMainThread, "onNext should be called on main thread")
        twoWayTargetOnNextCalled = true
      },
      onCompleted: {
        XCTAssertTrue(Thread.isMainThread, "onCompleted should be called on main thread")
        DispatchQueue.main.async {
          twoWayTargetOnCompletedCalled = true
          complete()
        }
      })

    let producer: Observable<Int> = Observable.create { subscriber in
      DispatchQueue.global().async {
        subscriber.on(.next(100))
        subscriber.on(.completed)
      }
      return Disposables.create()
    }

    _ = producer.subscribe(source)

    waitForExpectations(timeout: 1)
  }

  func testRepeatedOneWayBinding() {
    let target: BehaviorSubject<Int> = BehaviorSubject(value: 0)

    let source1: Observable<Int> = Observable.just(1)
    let source2: Observable<Int> = Observable.just(2)

    let binding: Binding = Binding(target: target)

    let exp = expectation(description: "Waiting…")

    _ = target
      .take(3)
      .toArray()
      .subscribe(onNext: { result in
        XCTAssertEqual(result, [0, 1, 2])
        exp.fulfill()
      })

    _ = binding.bind(source1)
    _ = binding.bind(source2)

    waitForExpectations(timeout: 1)
  }

  func testOneWayBindingToThreadedObservable() {
    let exp = expectation(description: "Waiting…")

    let source: BehaviorSubject<Int> = BehaviorSubject(value: 3)
    let oneWayBindTarget: BehaviorSubject<Int> = BehaviorSubject(value: 2)

    let twoWayBinding: Binding = Binding(target: oneWayBindTarget)
    _ = twoWayBinding.bind(source)

    XCTAssertEqual(try! source.value(), 3)
    XCTAssertEqual(try! oneWayBindTarget.value(), 3)

    var sourceOnNextCalled: Bool = false
    var sourceOnCompletedCalled: Bool = false
    var oneWayTargetOnNextCalled: Bool = false
    var oneWayTargetOnCompletedCalled: Bool = false

    let complete: () -> () = {
      guard sourceOnCompletedCalled && oneWayTargetOnCompletedCalled else {
        return
      }
      XCTAssertTrue(sourceOnNextCalled, "source onNext should have been called")
      XCTAssertTrue(oneWayTargetOnNextCalled, "oneWayTarget onNext should have been called")
      exp.fulfill()
    }

    _ = source.skip(1).take(1).subscribe(
      onNext: {
        XCTAssertEqual($0, 100)
        XCTAssertFalse(Thread.isMainThread, "onNext should be called on background thread")
        sourceOnNextCalled = true
      },
      onCompleted: {
        XCTAssertFalse(Thread.isMainThread, "onCompleted should be called on background thread")
        DispatchQueue.main.async {
          sourceOnCompletedCalled = true
          complete()
        }
      })

    _ = oneWayBindTarget.skip(1).take(1).subscribe(
      onNext: {
        XCTAssertEqual($0, 100)
        XCTAssertTrue(Thread.isMainThread, "onNext should be called on main thread")
        oneWayTargetOnNextCalled = true
      },
      onCompleted: {
        XCTAssertTrue(Thread.isMainThread, "onCompleted should be called on main thread")
        DispatchQueue.main.async {
          oneWayTargetOnCompletedCalled = true
          complete()
        }
      })

    let producer: Observable<Int> = Observable.create { subscriber in
      DispatchQueue.global().async {
        subscriber.on(.next(100))
        subscriber.on(.completed)
      }
      return Disposables.create()
    }

    _ = producer.subscribe(source)

    waitForExpectations(timeout: 1)
  }
}
