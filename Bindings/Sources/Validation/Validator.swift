//
//  Validator.swift
//  Bindings
//
//  Created by Marc Bauer on 16.06.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import RxSwift

public struct Validator<T>: ValidationRule {
  internal let rules: [AnyValidationRule<T>]

  public init(_ rules: [AnyValidationRule<T>]) {
    self.rules = rules
  }

  public init(_ rules: AnyValidationRule<T>...) {
    self.init(rules)
  }

  public func validate(_ value: T) -> Observable<ValidationResult> {
    return Observable.from(self.rules)
      .flatMap { $0.validate(value) }
      .skipWhile { $0 == .valid }
      .take(1)
      .ifEmpty(default: .valid)
  }
}
