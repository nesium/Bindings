//
//  ValidationTests.swift
//  BindingsTests
//
//  Created by Marc Bauer on 16.06.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import Bindings
import RxSwift
import XCTest

class MockValidationRule: ValidationRule {
  public var validateCalled: Bool
  public let result: ValidationResult

  init(_ result: ValidationResult) {
    self.result = result
    self.validateCalled = false
  }

  func validate(_ value: Any) -> Observable<ValidationResult> {
    self.validateCalled = true
    return Observable.of(self.result)
  }
}



class ValidationTests: XCTestCase {
  func testValidValue() {
    let exp = expectation(description: "Observable should emit value")

    let validator = Validator(
      AnyValidationRule(MinLengthValidationRule(3)),
      AnyValidationRule(MaxLengthValidationRule(5)))

    var nextCalled: Bool = false
    _ = Observable.just("1234")
      .flatMap { validator.validate($0) }
      .subscribe(
        onNext: {
          nextCalled = true
          XCTAssertEqual($0, .valid)
        },
        onError: { XCTFail($0.localizedDescription) },
        onCompleted: {
          XCTAssertTrue(nextCalled)
          exp.fulfill()
        }
      )

    wait(for: [exp], timeout: 1)
  }

  func testInvalidValueAndValidatorOrder() {
    let rule1 = MockValidationRule(.valid)
    let rule2 = MockValidationRule(.valid)
    let rule3 = MockValidationRule(.invalid(localizedDescription: "Failed"))
    let rule4 = MockValidationRule(.valid)
    let rule5 = MockValidationRule(.valid)

    let validator = Validator(
      AnyValidationRule(rule1),
      AnyValidationRule(rule2),
      AnyValidationRule(rule3),
      AnyValidationRule(rule4),
      AnyValidationRule(rule5)
    )

    let exp = expectation(description: "Observable should emit value")

    var nextCalled: Bool = false
    _ = Observable.just("1234")
      .flatMap { validator.validate($0) }
      .subscribe(
        onNext: {
          nextCalled = true
          XCTAssertNotEqual($0, .valid)
          XCTAssertTrue(rule1.validateCalled)
          XCTAssertTrue(rule2.validateCalled)
          XCTAssertTrue(rule3.validateCalled)
          XCTAssertFalse(rule4.validateCalled)
          XCTAssertFalse(rule5.validateCalled)
        },
        onError: { XCTFail($0.localizedDescription) },
        onCompleted: {
          XCTAssertTrue(nextCalled)
          exp.fulfill()
        }
      )

    wait(for: [exp], timeout: 1)
  }
}
