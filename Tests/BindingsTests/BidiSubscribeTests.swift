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

  func testBidiSubscribeWithTransformers() {
    let source = BehaviorSubject<Int>(value: 1)
    let target = BehaviorSubject<String>(value: "Hello")

    _ = target.bnd_bidiSubscribe(
      source,
      sourceToTarget: { (source: Observable<Int>) -> Observable<String> in
        source.map { String($0) }
      },
      targetToSource: { (target: Observable<String>) -> Observable<Int> in
        target.map { Int($0)! }
      }
    )

    XCTAssertEqual(try! source.value(), 1)
    XCTAssertEqual(try! target.value(), "1")

    source.on(.next(2))
    XCTAssertEqual(try! target.value(), "2")

    target.on(.next("3"))
    XCTAssertEqual(try! source.value(), 3)
  }
}
