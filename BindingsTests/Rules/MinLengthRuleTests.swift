//
//  MinLengthRuleTests.swift
//  BindingsTests
//
//  Created by Marc Bauer on 16.06.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import Bindings
import RxSwift
import XCTest

class MinLengthRuleTests: XCTestCase {
  func testInvalidValue() {
    let exp = expectation(description: "Observable should emit value")

    let rule = MinLengthValidationRule(5)

    _ = Observable.just("123")
      .flatMap { rule.validate($0) }
      .subscribe(
        onNext: { XCTAssertNotEqual($0, .valid) },
        onError: { XCTFail($0.localizedDescription) },
        onCompleted: { exp.fulfill() }
      )

    wait(for: [exp], timeout: 1)
  }

  func testValidValue() {
    let exp = expectation(description: "Observable should emit value")

    let rule = MinLengthValidationRule(5)

    _ = Observable.just("12345")
      .flatMap { rule.validate($0) }
      .subscribe(
        onNext: { XCTAssertEqual($0, .valid) },
        onError: { XCTFail($0.localizedDescription) },
        onCompleted: { exp.fulfill() }
      )

    wait(for: [exp], timeout: 1)
  }
}
