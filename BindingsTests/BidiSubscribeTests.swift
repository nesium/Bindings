//
//  BidiSubscribeTests.swift
//  BindingsTests
//
//  Created by Marc Bauer on 04.04.18.
//  Copyright © 2018 nesiumdotcom. All rights reserved.
//

import Foundation
import RxSwift
import XCTest

@testable import Bindings

class BidiSubscribeTests: XCTestCase {
  func testBidiSubscribe() {
    let source = BehaviorSubject<Int>(value: 1)
    let target = BehaviorSubject<Int>(value: 2)

    _ = target.bnd_bidiSubscribe(source)

    XCTAssertEqual(try! source.value(), 1)
    XCTAssertEqual(try! target.value(), 1)

    source.on(.next(3))
    XCTAssertEqual(try! target.value(), 3)

    target.on(.next(4))
    XCTAssertEqual(try! source.value(), 4)
  }

  // For a reason I have yet to figure out, this test produces a build error:
  //  Undefined symbols for architecture x86_64:
  //    "(extension in Bindings):RxSwift.ObserverType< where A: RxSwift.ObservableType>.bnd_bidiSubscribe<A where A1: RxSwift.ObservableType, A1: RxSwift.ObserverType>(_: A1, sourceToTarget: (RxSwift.Observable<A1.E>) -> RxSwift.Observable<A.E>, targetToSource: (RxSwift.Observable<A.E>) -> RxSwift.Observable<A1.E>) -> RxSwift.Disposable", referenced from:
  //        BindingsTests.BidiSubscribeTests.testBidiSubscribeWithTransformers() -> () in BidiSubscribeTests.o
  //  ld: symbol(s) not found for architecture x86_64

//  func testBidiSubscribeWithTransformers() {
//    let source = BehaviorSubject<Int>(value: 1)
//    let target = BehaviorSubject<String>(value: "Hello")
//
//    _ = target.bnd_bidiSubscribe(
//      source,
//      sourceToTarget: { (source: Observable<Int>) -> Observable<String> in
//        source.map { String($0) }
//      },
//      targetToSource: { (target: Observable<String>) -> Observable<Int> in
//        target.map { Int($0)! }
//      }
//    )
//
//    XCTAssertEqual(try! source.value(), 1)
//    XCTAssertEqual(try! target.value(), "1")
//
//    source.on(.next(2))
//    XCTAssertEqual(try! target.value(), "2")
//
//    target.on(.next("3"))
//    XCTAssertEqual(try! source.value(), 3)
//  }
}
