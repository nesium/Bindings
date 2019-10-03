//
//  ChangeTrackerTests.swift
//  BindingsTests
//
//  Created by Marc Bauer on 21.08.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import Bindings
import RxSwift
import XCTest

class ChangeTrackerTests: XCTestCase {
  func testChangeTracker() {
    let s1: BehaviorSubject<Int?> = BehaviorSubject(value: 1)
    let s2: BehaviorSubject<String?> = BehaviorSubject(value: nil)

    let b1: Binding<Int?> = Binding(target: s1)
    let b2: Binding<String?> = Binding(target: s2)

    var hasChanges: Bool = false

    let changeTracker = ChangeTracker.observe(
      ChangeTracker.trackChanges(b1),
      ChangeTracker.trackChanges(b2)
    )
    .replay(0)

    let sub = changeTracker.connect()

    let waitForNextValue: (String) -> () = { title in
      let exp = self.expectation(description: "Waiting for \(title)…")
      _ = changeTracker
        .take(1)
        .subscribe(
          onNext: {
            print("\(title): \($0)")
            hasChanges = $0
          },
          onCompleted: { exp.fulfill() }
        )
      self.waitForExpectations(timeout: 1)
    }

    XCTAssertFalse(hasChanges)

    s1.on(.next(2))
    waitForNextValue("2")
    XCTAssertTrue(hasChanges)

    s1.on(.next(1))
    waitForNextValue("3")
    XCTAssertFalse(hasChanges)

    s1.on(.next(3))
    s2.on(.next("Hello"))
    waitForNextValue("4")
    XCTAssertTrue(hasChanges)

    s1.on(.next(1))
    s2.on(.next(nil))
    waitForNextValue("6")
    XCTAssertFalse(hasChanges)

    sub.dispose()
  }

  func testChangeTrackerWithComparerBlock() {
    let s: BehaviorSubject<Int?> = BehaviorSubject(value: 1)

    var hasChanges: Bool = false

    let changeTracker = ChangeTracker.observe(
      ChangeTracker.trackChanges(s) { (lhs: Int?, rhs: Int?) -> Bool in lhs != rhs }
    )
    .replay(0)

    let sub = changeTracker.connect()

    let waitForNextValue: (String) -> () = { title in
      let exp = self.expectation(description: "Waiting for \(title)…")
      _ = changeTracker
        .take(1)
        .subscribe(
          onNext: {
            hasChanges = $0
          },
          onCompleted: { exp.fulfill() }
        )
      self.waitForExpectations(timeout: 120)
    }

    XCTAssertFalse(hasChanges)

    s.on(.next(1))
    waitForNextValue("1")
    XCTAssertTrue(hasChanges)

    s.on(.next(2))
    waitForNextValue("2")
    XCTAssertFalse(hasChanges)

    s.on(.next(1))
    waitForNextValue("1")
    XCTAssertTrue(hasChanges)

    sub.dispose()
  }
}
