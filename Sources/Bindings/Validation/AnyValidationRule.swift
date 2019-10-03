//
//  AnyValidationRule.swift
//  Bindings
//
//  Created by Marc Bauer on 16.06.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import RxSwift

public struct AnyValidationRule<T> {
  let validate: (T) -> Observable<ValidationResult>

  public init<R: ValidationRule>(_ rule: R) where R.T == T {
    self.validate = { rule.validate($0) }
  }

  public func validate(_ value: T) -> Observable<ValidationResult> {
    return self.validate(value)
  }
}
